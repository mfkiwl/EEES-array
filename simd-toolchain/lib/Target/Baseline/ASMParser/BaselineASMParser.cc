#include "BaselineBasicInfo.hh"
#include "BaselineInstruction.hh"
#include "BaselineInstructionPacket.hh"
#include "BaselineBinaryProgram.hh"
#include "BaselineASMParser.hh"
#include "Target/TargetInstruction.hh"
#include "Utils/LogUtils.hh"
#include "Utils/DbgUtils.hh"
#include "Utils/StringUtils.hh"

using namespace std;
using namespace ES_SIMD;

RegisterTargetASMParser<BaselineASMParser> BaselineASMParser::reg_("baseline");

static bool
ProcessPredicatedOpcode(std::string& ops,
                        vector<TargetOperand>& currPredicates) {
  static vector<std::string> oTokens;
  static ImmediateReader immRd;
  oTokens.clear();
  TokenizeString(oTokens, ops, ".");
  ES_ASSERT_MSG(!oTokens.empty(), "Invalid opcode \""<< ops <<"\"");
  unsigned s = 1;
  while ((s < oTokens.size()) && (oTokens[s].find("P") != 0)) { ++s; }
  if (s >= oTokens.size()) { return false; }
  for (unsigned i = s; i < oTokens.size(); ++i) {
    if (oTokens[i].find("P") != 0) { return false; }
    int p = immRd.GetIntImmediate(oTokens[i].substr(1));
    if (immRd.error_) { return false; }
    if (p > 0) { currPredicates.push_back(
        TargetOperand(TargetOperandType::Predicate, p)); }
  }// for i = 1 to oTokens.size()-1
  // Strip the predicates
  size_t os = ops.find(".P");
  ops = ops.substr(0, os);
  return true;
}// ProcessPredicatedOpcode()

BaselineASMParser::
BaselineASMParser(const TargetBasicInfo* t, int logLv,
                  std::ostream& log, std::ostream& err)
  : TargetASMParser(logLv, log, err),
    targetInfo_(*dynamic_cast<const BaselineBasicInfo*>(t)),
    currInstr_(NULL), currPacket_(NULL) {}

BaselineASMParser::~BaselineASMParser(){}

void BaselineASMParser::
PrepParser() {
  currLabel_.clear();
  currInstr_ = NULL;
  currPacket_ = NULL;
  currDataSec_ = 0;
  currDataType_ = SIRDataType::Int32;
}// PrepParser

ASMParserState_t BaselineASMParser::
ConsumeToken(const ASMToken& tk) {
  vector<TargetOperand> currPredicates;
  static ImmediateReader immRd;
  ES_LOG_P(logLevel_>=4, log_, ">>>>>> "<< tk <<"\n");
  ASMParserState_t st = parserState_;
  switch (tk.type_) {
  case ASMTokenType::Opcode: {
    currPredicates.clear();
    bool isVec = IsVectorOpcode(tk);
    string ops(tk.val_);
    if (IsPredicatedOpcode(ops)) {ProcessPredicatedOpcode(ops, currPredicates);}
    targetInfo_.StripOpcodeStr(ops);
    TargetOpcode_t opc = GetTargetOpcode(ops);
    if (isVec) {
      if (!targetInfo_.IsValidPEOpc(opc)) {
        st = ASMParserState::ParsingErr;
        ES_ERROR_MSG_T(
          err_, "Opcode", "ln"<< tk.lineNum_ <<": invalid PE opcode "<< opc
          <<" (\""<< tk.val_ <<"\")\n");
        break;
      }// if (!targetInfo_.IsValidPEOpc(opc))
      ES_LOG_P(logLevel_>=3, log_, ">>>> Vector opcode: "<< opc <<" in packet["
               << instrPacketCounter_ <<"]\n");
    } else {
      if (!targetInfo_.IsValidCPOpc(opc)) {
        st = ASMParserState::ParsingErr;
        ES_ERROR_MSG_T(
          err_, "Opcode", "ln"<< tk.lineNum_ <<": invalid CP opcode "<< opc
          <<" (\""<< tk.val_ <<"\")\n");
        break;
      }// if (!targetInfo_.IsValidCPOpc(opc))
      ES_LOG_P(logLevel_>=3, log_, ">>>> Scalar opcode: "<< opc <<" in packet["
               << instrPacketCounter_<<"]\n");
    }// if (isVec)

    // Prepare to add new instruction
    // -- First try to store the current instruction
    if (!CloseCurrInstr()) {
      st = ASMParserState::ParsingErr;
      break;
    }// if (!CloseCurrInstr())
    // -- Try to deal with the packet
    if (parserState_ != ASMParserState::ProcessingPacket) {
      // A new packet is required
      if (!CloseCurrPacket()) {
        st = ASMParserState::ParsingErr;
        break;
      }
      currPacket_ = new BaselineInstructionPacket(targetInfo_);
      currPacket_->SetIndex(instrPacketCounter_)
        .SetAddress(instrPacketCounter_);
      if (!currLabel_.empty()) {
        for (unsigned i = 0; i < currLabel_.size(); ++i) {
          ES_LOG_P(logLevel_>=3, log_, ">>>> Label \""<< currLabel_[i]
                   <<"\" refers to " "packet["<< instrPacketCounter_ <<"]\n");
          prog_->SetSymbol(
            currLabel_[i], TargetSymbolType::Code, instrPacketCounter_);
        }
        currLabel_.clear();
      }// if (!currLabel_.empty())
    } else {
      // Next instruction is still in the same packet
      if (currPacket_ == NULL) {
        ES_ERROR_MSG_T(err_,"Syntax","ln"<< tk.lineNum_ <<": invalid packet\n");
        st = ASMParserState::ParsingErr;
        break;
      }
    }// parserState_ != ASMParserState::ProcessingPacket
    currInstr_ = new BaselineInstruction(*currPacket_, isVec);
    currInstr_->SetIndex(tk.lineNum_).SetOpcode(opc);
    for (unsigned i = 0; i < currPredicates.size(); ++i) {
      currInstr_->AppendPredicate(currPredicates[i]);
    }
    st = ASMParserState::ProcessingInstr;
    break;
  }// case ASMTokenType::Opcode
  case ASMTokenType::Operand:{
    if (parserState_ != ASMParserState::ProcessingInstr) {
      ES_ERROR_MSG_T(err_, "Syntax", "ln"<< tk.lineNum_ <<": dangling operand"
                     " \""<< tk.val_ <<"\"\n");
      st = ASMParserState::ParsingErr;
      break;
    }
    TargetOperand o;
    if (prog_->IsValidSymbol(tk.val_)) {
      o.type_  = TargetOperandType::Label;
      o.value_ = prog_->GetSymbolID(tk.val_);
    } else { o = targetInfo_.ParseTargetOperand(tk.val_, currInstr_); }
    if (o.type_ == TargetOperandType::TargetOperandTypeEnd) {
      ES_ERROR_MSG_T(err_, "Syntax", "ln"<< tk.lineNum_ <<": invalid operand"
                     " symbol \""<< tk.val_ <<"\"\n");
      st = ASMParserState::ParsingErr;
      break;
    }
    currInstr_->AppendOperand(o);
    break;
  }// case ASMTokenType::Operand
  case ASMTokenType::PacketSep: {
    if (parserState_ != ASMParserState::ProcessingInstr) {
      ES_ERROR_MSG_T(err_, "Syntax", "ln"<< tk.lineNum_ <<": instruction packet"
                     " symbol can only be put between instructions\n");
      st = ASMParserState::ParsingErr;
      break;
    }
    if (!CloseCurrInstr()) { st = ASMParserState::ParsingErr; break; }
    st = ASMParserState::ProcessingPacket;
    break;
  }// case ASMTokenType::PacketSep
  case ASMTokenType::Label: {
    currLabel_.push_back(tk.val_);
    st = ASMParserState::ProcessingLabel;
    break;
  }
  case ASMTokenType::DirectiveKey:
    if (tk.val_ == "text") { currSectionType_ = ASMSectionType::Code; }
    else if ((tk.val_ == "data") || (tk.val_ == "jumptable")) {
      currSectionType_ = ASMSectionType::Data;
      currDataSec_ = 0;
    } else if (tk.val_ == "vdata") {
      currSectionType_ = ASMSectionType::Data;
      currDataSec_ = 1;
    } else if (tk.val_ == "address") { st = ASMParserState::SetAddress; }
    else if (tk.val_ == "long") {
      currDataType_ = SIRDataType::Int32;
      st = ASMParserState::DataInit;
    } else if (tk.val_ == "short") {
      currDataType_ = SIRDataType::Int16;
      st = ASMParserState::DataInit;
    } else if (tk.val_ == "byte") {
      currDataType_ = SIRDataType::Int8;
      st = ASMParserState::DataInit;
    }
    break;
  case ASMTokenType::DirectiveOperand:
    if (parserState_ == ASMParserState::SetAddress) {
      int addr = immRd.GetIntImmediate(tk.val_);
      if (immRd.error_ || (addr < 0)) {
        ES_ERROR_MSG_T(err_, "Syntax", "ln"<< tk.lineNum_ <<": invalid address "
                       << tk.val_ <<"\n");
        st = ASMParserState::ParsingErr;
      } else {// if (!immRd.error_)
        st = ASMParserState::ProcessingDirective;
        currAddress_ = addr;
      }// if (!immRd.error_)
    } else if (parserState_ == ASMParserState::DataInit) {
      int d = immRd.GetIntImmediate(tk.val_);
      if (immRd.error_) {
        if (prog_->IsValidSymbol(tk.val_)) {
          d = prog_->GetSymbol(tk.val_).address_;
          ES_LOG_P(logLevel_>=3, log_, ">>-->>-- Init "<< d <<" @ "
                   << currAddress_ <<'\n');
          currAddress_ += dynamic_cast<BaselineBinaryProgram*>(prog_)
            ->AddDataInit(currDataType_, currDataType_, currAddress_, d);
          st = ASMParserState::ProcessingDirective;
        } else {// if (prog_->IsValidSymbol(tk.val_))
          ES_ERROR_MSG_T(err_, "Syntax", "ln"<< tk.lineNum_
                         <<": invalid init value \""<< tk.val_ <<"\"\n");
          st = ASMParserState::ParsingErr;
        }// if (prog_->IsValidSymbol(tk.val_))
      } else {// if (!immRd.error_)
        ES_LOG_P(logLevel_>=3, log_, ">>-->>-- Init "<< d <<" @ "
                 << currAddress_ <<'\n');
        currAddress_ += dynamic_cast<BaselineBinaryProgram*>(prog_)
          ->AddDataInit(currDataSec_, currDataType_, currAddress_, d);
        st = ASMParserState::ProcessingDirective;
      }// // if (!immRd.error_)
    }
    break;
  // Tokens that don't change parser state
  case ASMTokenType::EndLine:
  case ASMTokenType::Comment: break;
  // Invalid state
  default: st = ASMParserState::ParsingErr; break;
  }// switch (tk.type_)
  return st;
}// GetNextState()

ASMParserState_t BaselineASMParser::
Finalize() {
  if (parserState_ == ASMParserState::ProcessingPacket) {
    ES_ERROR_MSG_T(err_, "Syntax", "ends with incomplete packet\n");
    return ASMParserState::ParsingErr;
  }
  if (!CloseCurrInstr())  { return ASMParserState::ParsingErr; }
  if (!CloseCurrPacket()) { return ASMParserState::ParsingErr; }
  return ASMParserState::ParsingFinish;
}// GetNextState()

bool BaselineASMParser::
CloseCurrInstr() {
  bool closed = true;
  if (currInstr_ != NULL) {
    if (currInstr_->Valid()) {
      ++instrCounter_;
      ES_ASSERT_MSG(currPacket_!=NULL, "Current packet not initilized");
      currPacket_->AppendInstruction(currInstr_);
    } else {
      ES_ERROR_MSG_T(err_, "Syntax", "ln"<< currInstr_->GetIndex()
                   <<": invalid instruction\n");
      ES_LOG(err_, currInstr_->GetNumDstOperands() <<", "
             <<currInstr_->GetNumSrcOperands() <<"\n");
      closed = false;
    }
  }// if (currInstr_ != NULL)
  if (closed) { currInstr_ = NULL; }
  return closed;
}// CloseCurrInstr()

bool BaselineASMParser::
CloseCurrPacket() {
  bool closed = true;
  if (currPacket_ != NULL) {
    if (currPacket_->Valid()) {
      ++instrPacketCounter_;
      ES_ASSERT_MSG(prog_!=NULL, "Program not initilized in ASM parser");
      prog_->push_back(currPacket_);
    } else { closed = false; }
  }// if (currPacket_ != NULL)
  if (closed) { currPacket_ = NULL; }
  return closed;
}// CloseCurrPacket()
