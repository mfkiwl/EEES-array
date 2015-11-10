#include "SIR/SIRParser.hh"
#include "SIR/SIRConstant.hh"
#include "SIR/SIRRegister.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRDataObject.hh"
#include "SIR/SIRKernel.hh"
#include "SIR/SIRLoop.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRModule.hh"
#include "DataTypes/SIROpcode.hh"
#include "Utils/FileUtils.hh"
#include "Utils/StringUtils.hh"
#include "Utils/LogUtils.hh"
#include "Utils/DbgUtils.hh"
#include "llvm/Support/Casting.h"
#include <sstream>
#include <cctype>

using namespace std;
using namespace ES_SIMD;

static bool RegNameWritable(const string& name) {
  return (name != "ZERO") && (name != "PEID") && (name != "NUMPE");
}

static bool IsLegalSIRSymbol(const std::string& s) {
  for (int i = 0, e=s.size(); i < e; ++i) {
    const char c = s[i];
    if (!isalpha(c) && (c != '_') && (c != '$') && (c != '.')
        && (!isdigit(c) || (i==0))) { return false; }
  }
  return true;
}

void SIRParser::
ParseSIRFile(const string& inFile, SIRModule& m) {
  ES_LOG_P(logLevel_, log_, "Parsing "<< inFile <<"\n");
  inputBuffer_.clear();
  tokenBuffer_.clear();
  FileStatus_t fStat
    = ReadASMFileLines(inputBuffer_, inFile);
  if (fStat != FileStatus::OK) {
    ParserErr(ErrorCode::FileIOError, "Cannot open SIR source " + inFile);
  }
  SIRLex(inFile);
  ES_LOG_P(logLevel_ > 1, log_, ">> Lex: "<< tokenBuffer_.size()
           <<" token(s) found in "<< inputBuffer_.size() <<" lines\n");
  // Initialize state variables
  state_ = SIRParserState::ParsingStart;
  currFunc_    = NULL;
  currBB_      = NULL;
  currInstr_   = NULL;
  currDataObj_ = NULL;
  currDataType_= SIRDataType::Unknown;
  currOperandCounter_ = 0;
  currValueCounter_   = 0;
  currMemLoccationID_ = 0;
  activeLabel_.clear();
  currDefTable_.clear();
  localSymbols_.clear();
  fileSymbols_.clear();
  unsigned tkIndex = 0;
  while ((state_ != SIRParserState::ParsingFinish)
         && (state_ != SIRParserState::ParsingErr)) {
    SIRParserState_t nextState;
    if (tkIndex < tokenBuffer_.size()) {
      nextState = ConsumeToken(tkIndex ++, m);
    } else {
      nextState = Finalize(m);
    }// if (tkIndex < tokenBuffer_.size())
    ES_LOG_P(logLevel_>3, log_, ">>>>>> * "<< state_<<"->"<< nextState <<"\n");
    state_ = nextState;
    if (!errors_.empty()) {
      state_ = SIRParserState::ParsingErr;
    }
  }// while ((state_ != ParsingFinish) && (state_ != ParsingErr))

  // Cleanup non-global symbol to prepare for next file
  m.CleanupSymbols(localSymbols_);
}// ParseSIRFile()

void SIRParser::
SIRLex(const string& filename) {
  FileLocation fl(filename, 0);
  tokenBuffer_.push_back(SIRToken(SIRTokenType::EndLine, fl));
  vector<std::string> itokens;
  itokens.reserve(4);
  for (vector<ASMLine>::iterator it = inputBuffer_.begin();
       it != inputBuffer_.end(); ++it) {
    const ASMLine& ln = *it;
    if (ln.Empty())
      continue;
    fl.line_ = ln.lineNum_;
    if (ln.HasContent()) {
      itokens.clear();
      TokenizeString(itokens, ln.line_, ", \t");
      for (vector<string>::iterator tIt = itokens.begin();
           tIt != itokens.end(); ++tIt) {
        SIRTokenType_t tt = SIRTokenType::Unknown;
        string& tk = *tIt;
        if (IsSIRLabel(tk)) {
          tt = SIRTokenType::Label;
          tk = tk.substr(0, tk.length()-1);
        } else {
          if (IsSIRDirectiveKey(tk)) {
            tt = SIRTokenType::DirectiveKey;
            tk = tk.substr(1);
          } else if (IsSIRDirectiveOperand()) {
            tt = SIRTokenType::DirectiveOperand;
          } else if (IsSIROpcode(tk)) {
            tt = SIRTokenType::Opcode;
          } else if (IsSIROperand(tk)) {
            tt = SIRTokenType::Operand;
          }
        }// if (IsSIRLabel())
        tokenBuffer_.push_back(SIRToken(tt, fl, tk));
      }// for itokens iterator tIt
    }// if (ln.HasContent())
    if (ln.HasComment()) {
      tokenBuffer_.push_back(SIRToken(SIRTokenType::Comment, fl, ln.comment_));
    }// if (ln.HasComment())
    tokenBuffer_.push_back(SIRToken(SIRTokenType::EndLine, fl));
  }// for inputBuffer_ iterator it
}// SIRLex()

SIRParserState_t SIRParser::
ConsumeToken(unsigned tkIndex, SIRModule& m) {
  const SIRToken& tk = tokenBuffer_[tkIndex];
  static ImmediateReader immRd;
  ES_LOG_P(logLevel_>3, log_, ">>>>>> "<< tk <<"\n");
  SIRParserState_t st = state_;
  switch (tk.type_) {
  default: st = SIRParserState::ParsingErr;   break;
  case SIRTokenType::EndLine:
  case SIRTokenType::Comment: break;
  case SIRTokenType::Opcode: {
    bool isVectorOp = currFunc_->IsSolverKernel();
    size_t dotPos = tk.val_.find('.');
    SIROpcode_t opc = SIROpcode::SIROpcodeEnd;
    if (dotPos != string::npos) {
      if (dotPos != 1) {
        return ParserErr(ErrorCode::IRInvalidOpcode,
                         "Invalid opcode "+tk.val_, tk.fLoc_);
      }
      switch (tk.val_[0]) {
      case 'v': isVectorOp = true;  break;
      case 's': isVectorOp = false; break;
      default:
        return ParserErr(ErrorCode::IRSyntaxError,
                         "Unknown operation type in "+tk.val_, tk.fLoc_);
      }
      opc = GetSIROpcode(tk.val_.substr(2));
    } else { opc = GetSIROpcode(tk.val_);}// if npos != tk.val_.find('.')
    ES_LOG_P(logLevel_>2, log_, ">>>> opcode: "<< opc <<"\n");
    if (opc >= SIROpcode::SIROpcodeEnd) {
      return ParserErr(ErrorCode::IRInvalidOpcode,
                       "Invalid opcode "+tk.val_, tk.fLoc_);
    }
    if (opc == SIROpcode::BB)   { st = SIRParserState::EnterBasicBlock;break; }
    if (opc == SIROpcode::MNUM) { st = SIRParserState::InitMA;         break; }
    if (opc == SIROpcode::MLOC) { st = SIRParserState::SetMLoc;        break; }
    if (opc == SIROpcode::MALIAS) {
      st = SIRParserState::SetMAEntry;
      currOperandCounter_ = 0;
      break;
    }
    if (opc == SIROpcode::ARGSPC) {
      if (!currFunc_) {
        return ParserErr(ErrorCode::IRSyntaxError,"No valid function",tk.fLoc_);
        st = SIRParserState::ParsingErr;
      } else {
        st = SIRParserState::SetArgSpc;
        currOperandCounter_ = 0;
      }
      break;
    }
    if (opc == SIROpcode::ARGS) {
      if (!currFunc_) {
        return ParserErr(ErrorCode::IRSyntaxError,"No valid function",tk.fLoc_);
      } else {
        st = SIRParserState::SetNumArgs;
        currOperandCounter_ = 0;
      }
      break;
    }
    if (opc == SIROpcode::RVALS) {
      if (!currFunc_) {
        return ParserErr(ErrorCode::IRSyntaxError,"No valid function",tk.fLoc_);
      } else {
        st = SIRParserState::SetRetVals;
        currOperandCounter_ = 0;
      }
      break;
    }
    if (!currBB_) {
      // No basic block to add the instruction to
      return ParserErr(ErrorCode::IRSyntaxError, "No valid block", tk.fLoc_);
    }
    if (opc == SIROpcode::RLI) {
      st = SIRParserState::BlockLiveIn;
      break;
    }
    currInstr_ = new SIRInstruction(opc, currBB_, isVectorOp);
    if (IsSIRMemoryOp(opc)) {
      if (currMemLoccationID_ <= 0) {
        return ParserErr(ErrorCode::IRSyntaxError,
                         "Memory access without location ID", tk.fLoc_);
      }
      currInstr_->memoryLoacation_ = currMemLoccationID_;
      currMemLoccationID_ = 0;
    }// if (IsSIRMemoryOp(opc))
    currBB_->push_back(currInstr_);
    currInstr_->fileLoc_ = tk.fLoc_;
    if (GetSIROpNumOutput(opc) > 0) {
      st = SIRParserState::InstrOutput;
      currOperandCounter_ = 0;
    } else if (GetSIROpNumInput(opc) > 0) {
      st = SIRParserState::InstrInput;
      currOperandCounter_ = 0;
    }
    break;
  }
  case SIRTokenType::Operand: {
    if (!currFunc_) {
      return ParserErr(ErrorCode::IRSyntaxError, "Un-initialized function",
                       tk.fLoc_);
    }
    if (state_ == SIRParserState::EnterBasicBlock) {
      int bid = immRd.GetIntImmediate(tk.val_);
      if (immRd.error_) {
        return ParserErr(ErrorCode::IRIllegalOperand,
                         "Illegal block ID \"" + tk.val_ +"\"", tk.fLoc_);
      }
      ES_LOG_P(logLevel_>2, log_, ">>>> new block ID = "<< bid <<"\n");
      currBB_ = new SIRBasicBlock(bid, currFunc_);
      currFunc_->push_back(currBB_);
      currDefTable_.clear();
      currBBTable_[bid] = currBB_;
      if (!activeLabel_.empty()) {
        for (unsigned i = 0; i < activeLabel_.size(); ++i) {
          const string& l = activeLabel_[i];
          ES_LOG_P(logLevel_>2, log_, ">>>> Block labeled with \""<<l<<"\"\n");
          if (currFunc_->GetName() == l) {
            if ((currFunc_->entryBlock_ != NULL)
                && (currFunc_->entryBlock_ != currBB_)) {
              // There should be only one entry block
              return ParserErr(
                ErrorCode::IRSyntaxError,
                "Multiple entry block for \"" + l +"\"", tk.fLoc_);
            }
            currFunc_->SetEntryBlock(currBB_);
            currBB_->name_ = l;
          } else { // if (currFunc_->GetName() == l)
            if (m.HasSymbol(l) && !llvm::isa<SIRConstant>(m.GetSymbolValue(l))) {
              // Redifining a symbol is not allowed
              return ParserErr(
                ErrorCode::IRSyntaxError,
                "Redefining symbol \"" + l +"\"", tk.fLoc_);
            }
            m.AddSymbol(l, currBB_);
            fileSymbols_.insert(l);
            currBB_->name_ = "$"+currBB_->GetParent()->GetName() +"_BB"
              + Int2DecString(currBB_->GetBasicBlockID());
          }// if (currFunc_->GetName() == l)
        }// for i = 0 to activeLabel_.size()-1
        activeLabel_.clear();
      }
      break;
    } else if (state_ == SIRParserState::BlockLiveIn) {
      if (tk.val_[0] != '%') {
        return ParserErr(ErrorCode::IRIllegalOperand,
                         "Non-register live-in", tk.fLoc_);
      }
      if ((tk.val_.size() < 2) || (tk.val_[1] != 'a')
          || !currFunc_->GetArgument(tk.val_.substr(1))) {
        SIRRegister* li = new SIRRegister(
          currFunc_->IsSolverKernel(), tk.val_.substr(1), currBB_);
        currBB_->AddLiveIn(li);
        currDefTable_[tk.val_.substr(1)] = li;
      }
      ES_LOG_P(logLevel_>2, log_, ">>>> live-in = "<< tk.val_ <<"\n");
    } else if (state_ == SIRParserState::InitMA) {
      if (!currFunc_->memoryAliasTable_.empty()) {
        return ParserErr(
          ErrorCode::IRSyntaxError,
          "Multiple alias table initialization in one function", tk.fLoc_);
      }// if (!currFunc_->memoryAliasTable_.empty())
      int sz = immRd.GetIntImmediate(tk.val_);
      if (immRd.error_) {
        return ParserErr(
          ErrorCode::IRIllegalOperand,
          "Illegal memory location number \"" + tk.val_ +"\"", tk.fLoc_);
      }
      currFunc_->memoryAliasTable_.resize(sz+1, BitVector(sz+1));
    } else if (state_ == SIRParserState::SetMAEntry) {
      int op = immRd.GetIntImmediate(tk.val_);
      if (immRd.error_) {
        return ParserErr(
          ErrorCode::IRIllegalOperand,
          "Illegal memory location id \"" + tk.val_ +"\"", tk.fLoc_);
      }
      if (currOperandCounter_ == 0) { memAliasOpA_ = op; }
      else if (currOperandCounter_ == 1) {
        currFunc_->memoryAliasTable_[memAliasOpA_][op] = true;
        currFunc_->memoryAliasTable_[op][memAliasOpA_] = true;
      } else {
        return ParserErr(ErrorCode::IRSyntaxError,"Too many operands",tk.fLoc_);
      }
      ++currOperandCounter_;
    } else if (state_ == SIRParserState::SetMLoc) {
      int op = immRd.GetIntImmediate(tk.val_);
      if (immRd.error_) {
        return ParserErr(
          ErrorCode::IRIllegalOperand,
          "Illegal memory location id \"" + tk.val_ +"\"", tk.fLoc_);
      }
      currMemLoccationID_ = op;
    } else if (state_ == SIRParserState::SetArgSpc) {
      int op = immRd.GetIntImmediate(tk.val_);
      if (immRd.error_) {
        return ParserErr(ErrorCode::IRIllegalOperand,
                         "Illegal operand \""+ tk.val_ +"\"", tk.fLoc_);
      }
      if (currOperandCounter_ == 0) { argSpaceID_ = op; }
      else if (currOperandCounter_ == 1) {
        currFunc_->argAddrSpace_[argSpaceID_] = op;
      } else {
        return ParserErr(ErrorCode::IRSyntaxError,"Too many operands",tk.fLoc_);
      }
      ++currOperandCounter_;
    } else if (state_ == SIRParserState::SetNumArgs) {
      int op = immRd.GetIntImmediate(tk.val_);
      if (immRd.error_) {
        return ParserErr(ErrorCode::IRIllegalOperand,
                         "Illegal operand \""+ tk.val_ +"\"", tk.fLoc_);
      }
      if (currOperandCounter_ == 0) {
        if (op > 6) {
          ES_NOTIMPLEMENTED("more than 6 function arguments ("
                            << currFunc_->GetName()<<")");
        }
        currFunc_->numFormalArgs_ = op;
        currFunc_->arguments_.clear();
        for (int i = 0; i < op; ++i) {
          stringstream ss;
          ss <<'a'<<i;
          currFunc_->AddOrGetArgument(ss.str());
        }
      } else {
        return ParserErr(ErrorCode::IRSyntaxError,"Too many operands",tk.fLoc_);
      }
      ++currOperandCounter_;
    } else if (state_ == SIRParserState::SetRetVals) {
      int op = immRd.GetIntImmediate(tk.val_);
      if (immRd.error_) {
        return ParserErr(ErrorCode::IRIllegalOperand,
                         "Illegal operand \""+ tk.val_ +"\"", tk.fLoc_);
      }
      if (currOperandCounter_ > 0) {
        return ParserErr(ErrorCode::IRSyntaxError,"Too many operands",tk.fLoc_);
      }
      currFunc_->returnValues_.clear();
      for (int i = 0, e = (op + 31)/32;  i < e; ++i) {
        stringstream ss;
        ss <<'v'<<i;
        currFunc_->AddOrGetReturnValue(ss.str());
      }
      ++currOperandCounter_;
    } else if (state_ == SIRParserState::InstrOutput) {
      if (tk.val_[0] == '%') {
        if (currOperandCounter_>=GetSIROpNumOutput(currInstr_->GetSIROpcode())) {
          return ParserErr(ErrorCode::IRSyntaxError,"Too many output",tk.fLoc_);
        }
        ES_LOG_P(logLevel_>2, log_, ">>>> output: "<< tk.val_ <<"\n");
        // currDefTable_[tk.val_.substr(1)] = currInstr_;
        currInstr_->name_ = tk.val_.substr(1);
        ++currOperandCounter_;
        if ( (currOperandCounter_==GetSIROpNumOutput(currInstr_->GetSIROpcode()))
             && (GetSIROpNumInput(currInstr_->GetSIROpcode()) > 0)) {
          st = SIRParserState::InstrInput;
          currOperandCounter_ = 0;
        }
      } else {
        // Output should be register
        return ParserErr(ErrorCode::IRIllegalOperand,
                         "Output should be a register",tk.fLoc_);
      }
    } else if (state_ == SIRParserState::InstrInput) {
      if (currOperandCounter_>=GetSIROpNumInput(currInstr_->GetSIROpcode())) {
        return ParserErr(ErrorCode::IRSyntaxError,"Too many input",tk.fLoc_);
      }
      if (tk.val_[0] == '%') {
        // This is a register value
        SIRValue* operand = currDefTable_[tk.val_.substr(1)];
        if (!operand) {
          operand = currFunc_->GetSpecialRegister(tk.val_.substr(1));
          if (operand && RegNameWritable(operand->GetName())) {
            currDefTable_[tk.val_.substr(1)] = operand;
            currBB_->AddLiveIn(llvm::cast<SIRRegister>(operand));
          }
        }// if (!operand)
        if (!operand) {
          operand = currFunc_->GetArgument(tk.val_.substr(1));
          if (operand) {
            currDefTable_[tk.val_.substr(1)] = operand;
            currBB_->AddLiveIn(llvm::cast<SIRRegister>(operand));
          }
        }// if (!operand)
        if (!operand && currFunc_->IsSolverKernel()) {
          operand = currFunc_->solverKernel_->GetSpecialRegister(
            tk.val_.substr(1));
        }
        if (!operand && (tk.val_[1] == 'v')) {
          // This is a return value that is not defined yet
          operand = new SIRRegister(false, tk.val_.substr(1), currFunc_);
          currFunc_->AddManagedValue(operand);
          currDefTable_[tk.val_.substr(1)] = operand;
        }
        if (!operand) {
          if (tk.val_.size() >=2) {
            SIRRegister* li = new SIRRegister(
              currFunc_->IsSolverKernel(), tk.val_.substr(1), currBB_);
            currBB_->AddLiveIn(li);
            currDefTable_[tk.val_.substr(1)] = li;
            operand = li;
          } else {
            return ParserErr(ErrorCode::IRParserError,
                             "Cannot find value of " + tk.val_,tk.fLoc_);
          }
        }// if (!operand)
        ES_LOG_P(logLevel_>2, log_, ">>>> operand: "<< tk.val_
                 <<"<"<< operand->getKindName() <<">\n");
        currInstr_->AddOperand(operand);
      } else {
        int imm = immRd.GetIntImmediate(tk.val_);
        if (immRd.error_) {
          // For now, treat it as a symbol, will try to resolve it latter
          string l = tk.val_;
          // Strip the symbol
          if ((tk.val_[0] == '(') && (tk.val_[tk.val_.size()-1] == ')')) {
            l = tk.val_.substr(1, tk.val_.size()-2);
          }
          ES_LOG_P(logLevel_>2, log_, ">>>> operand: "<< l <<"<Symbol>\n");
          SIRValue* s = m.AddOrGetSymbol(l);
          if (SIRDataObject::classof(s)) {
            currFunc_->AddDataObject(static_cast<SIRDataObject*>(s));
          }
          currInstr_->AddOperand(s);
        } else {
          ES_LOG_P(logLevel_>2, log_, ">>>> operand: "<< tk.val_
                   <<"<Immediate>\n");
          currInstr_->AddOperand(m.AddOrGetImmediate(imm));
        }
      }
      ++currOperandCounter_;
      if (currOperandCounter_ == GetSIROpNumInput(currInstr_->GetSIROpcode())
          && !currInstr_->GetName().empty()) {
        currDefTable_[currInstr_->GetName()] = currInstr_;
      }
    }// if (state_ == SIRParserState::InstrInput)
    break;
  }// case SIRTokenType::Operand:
  case SIRTokenType::DirectiveKey: {
    if (state_ == SIRParserState::InitData) {
      if (tk.val_ == "long") {
        currDataType_ = SIRDataType::Int32; currOperandCounter_ = 0; break;
      } if (tk.val_ == "short") {
        currDataType_ = SIRDataType::Int16; currOperandCounter_ = 0; break;
      } if (tk.val_ == "byte") {
        currDataType_ = SIRDataType::Int8; currOperandCounter_ = 0; break;
      } else if (tk.val_ == "size") {
        st = SIRParserState::SetObjSize; currOperandCounter_ = 0; break;
      } else if (tk.val_ == "ascii") {
        currDataType_ = SIRDataType::ASCIIStr; currOperandCounter_ = 0; break;
      }
    }// if (state_ == SIRParserState::InitData)
    st = SIRParserState::ProcessingDirective;
    if (tk.val_ == "section") {
      st = SIRParserState::SetSection;
      currOperandCounter_ = 0;
    }
    else  if (tk.val_ == "text") { sectionType_ = SIRSectionType::Code; }
    else if ((tk.val_=="data") || (tk.val_=="bss")){
      sectionType_ = SIRSectionType::Data;
    } else if (tk.val_=="vdata") { sectionType_ = SIRSectionType::VData; }
    else if (tk.val_ == "ent")   { st = SIRParserState::EnterFunction;   }
    else if (tk.val_ == "end")   { st = SIRParserState::ExitFunction;    }
    else if (tk.val_ == "globl") { st = SIRParserState::DeclGlobalSym;   }
    else if (tk.val_ == "local") { st = SIRParserState::DeclLocalSym;    }
    else if (tk.val_ == "solverkernel") {
      if (currFunc_ == NULL) {
        return ParserErr(ErrorCode::IRSyntaxError,
                         "No function for .solverkernel", tk.fLoc_);
      }
      currFunc_->SetSolverKernel(new SIRKernel(currFunc_));
      m.GetDataObject("__pe_array_size")->AddUse(currFunc_);
    } else if (tk.val_ == "comm") {
      st = SIRParserState::DeclData;
      currOperandCounter_ = 0;
    }
    break;
  }
  case SIRTokenType::DirectiveOperand: {
    st = SIRParserState::ProcessingDirective;
    switch (state_) {
    default: break;
    case SIRParserState::EnterFunction:
      if (currFunc_ != NULL) {
        return ParserErr(
          ErrorCode::IRSyntaxError,
          "Function "+currFunc_->GetName()+" not closed",
          currFunc_->GetFileLocation());
      }// if (currFunc_ != NULL)
      if (m.HasSymbol(tk.val_)
          && !llvm::isa<SIRConstant>(m.GetSymbolValue(tk.val_))) {
        return ParserErr(ErrorCode::IRRedefinedSymbol,
                         "Redefining "+ tk.val_,tk.fLoc_);
      }
      currFunc_ = new SIRFunction(tk.val_, &m);
      currValueCounter_ = 0;
      currBBTable_.clear();
      currFuncVars_.clear();
      fileSymbols_.insert(tk.val_);
      break;
    case SIRParserState::ExitFunction:
      // Check if .end matches last .ent
      if ((currFunc_ == NULL) || (currFunc_->GetName() != tk.val_)) {
        return ParserErr(ErrorCode::IRSyntaxError,
                         "Missmatch function directive", tk.fLoc_);
      }
      currFunc_ = NULL;
      break;
    case SIRParserState::InitData: {
      st = SIRParserState::InitData;
      if (currDataType_ == SIRDataType::ASCIIStr) {
        std::vector<int> buf;
        if (!currDataObj_ || (tk.val_[0] != '\"')
            || (tk.val_[tk.val_.size()-1] != '\"')
            || !ParseEscapedString(tk.val_.substr(1, tk.val_.size()-2), buf)) {
          return ParserErr(ErrorCode::IRIllegalOperand,
                           "Illegal ASCII string \""+ tk.val_ +"\"", tk.fLoc_);
        }
        for (unsigned i = 0, e = buf.size(); i < e; ++i) {
          currDataObj_->AddInit(SIRDataType::Int8, buf[i]);
        }
        break;
      }
      int op = immRd.GetIntImmediate(tk.val_);
      if (!currDataObj_) {
        return ParserErr(ErrorCode::IRSyntaxError,
                         "No valid data object", tk.fLoc_);
      }
      if (immRd.error_) {
        // Check if this is a symbol
        string l = tk.val_;
        // Strip the symbol
        if (!l.empty() && (tk.val_[0] == '(')
            && (tk.val_[tk.val_.size()-1] == ')'))
        { l = tk.val_.substr(1, tk.val_.size()-2); }
        if (!IsLegalSIRSymbol(l)) {
          return ParserErr(ErrorCode::IRIllegalOperand,
                           "Illegal operand \""+tk.val_+"\"", tk.fLoc_);
        }
        currDataObj_->AddInit(l, m.GetSymbolValue(l));
        break;
      }// if (immRd.error_)
      currDataObj_->AddInit(currDataType_, op);
      break;
    }
    case SIRParserState::SetObjSize:
      if (currOperandCounter_ == 0) {
        ++currOperandCounter_;
        if (tk.val_ != currDataObj_->GetName()) {
          st = SIRParserState::ProcessingDirective;
        } else { st = SIRParserState::SetObjSize; }
      } else if (currOperandCounter_ == 1) {
        int op = immRd.GetIntImmediate(tk.val_);
        if (!currDataObj_ || immRd.error_ || (op < 0)) {
          return ParserErr(ErrorCode::IRIllegalOperand,
                           "Illegal operand \""+ tk.val_ +"\"", tk.fLoc_);
        }
        ++currOperandCounter_;
        currDataObj_->SetSize(op);
      }
      break;
    case SIRParserState::DeclData:
      if (currOperandCounter_ == 0) {
        st = SIRParserState::DeclData;
        currDataObj_ = new SIRDataObject(tk.val_, &m);
        m.AddDataObject(currDataObj_);
        fileSymbols_.insert(tk.val_);
        ++currOperandCounter_;
      } else if (currOperandCounter_ == 1) {
        int op = immRd.GetIntImmediate(tk.val_);
        if (!currDataObj_ || immRd.error_ || (op < 0)) {
          return ParserErr(ErrorCode::IRIllegalOperand,
                           "Illegal operand \""+ tk.val_ +"\"", tk.fLoc_);
        }
        ++currOperandCounter_;
        currDataObj_->SetSize(op);
      }
      break;
    case SIRParserState::SetSection:
      if (currOperandCounter_ == 0) {
        st = SIRParserState::SetSection;
        if ((tk.val_ == ".rodata") || (tk.val_ == ".data") ||
            (tk.val_ == ".bss") || (tk.val_ == ".sbss"))
        { sectionType_ = SIRSectionType::Data; }
        else if (tk.val_ == ".vdata") { sectionType_ = SIRSectionType::VData; }
        else if (tk.val_ == ".text")  { sectionType_ = SIRSectionType::Code;  }
      } else if (currOperandCounter_ == 1) { st = SIRParserState::SetSection; }
      else if (currOperandCounter_ == 2) {}
    case SIRParserState::DeclGlobalSym: m.AddGlobalSymbol(tk.val_);   break;
    case SIRParserState::DeclLocalSym: localSymbols_.insert(tk.val_); break;
    }// switch (state_)
    break;
  }
  case SIRTokenType::Label: {
    if (!IsLegalSIRSymbol(tk.val_)) {
      return ParserErr(ErrorCode::IRIllegalSymbol,
                       "Illegal label \""+ tk.val_ +"\"", tk.fLoc_);
    }
    if (sectionType_ == SIRSectionType::Code) {
      st = SIRParserState::ProcessingLabel;
      activeLabel_.push_back(tk.val_);
      if ((currFunc_ != NULL) && (currFunc_->GetName() == tk.val_))
        currFunc_->fLoc_ = tk.fLoc_;
    } else if (sectionType_ == SIRSectionType::Data) {
      ES_LOG_P(logLevel_>1, log_, ">>-- Creating data object "<<tk.val_<<'\n');
      st = SIRParserState::InitData;
      currDataObj_ = new SIRDataObject(tk.val_, &m);
      fileSymbols_.insert(tk.val_);
      m.AddDataObject(currDataObj_);
    } else if (sectionType_ == SIRSectionType::VData) {
      ES_LOG_P(logLevel_>1, log_, ">>-- Creating vdata object "<<tk.val_<<'\n');
      st = SIRParserState::InitData;
      currDataObj_ = new SIRDataObject(tk.val_, &m);
      fileSymbols_.insert(tk.val_);
      m.AddDataObject(currDataObj_);
      currDataObj_->SetVector(true);
    }
    break;
  }
  }// switch (tk.type_)
  return st;
}// ConsumeToken()

SIRParserState_t SIRParser::
Finalize(SIRModule& m) {
  if (currFunc_ != NULL) {
    return ParserErr(
      ErrorCode::IRSyntaxError, "Function "+currFunc_->GetName()+" not closed",
      currFunc_->GetFileLocation());
  }
  ResolveSymbols(m);
  ES_LOG_P(logLevel_ > 1, log_, ">> Parser finalized\n");
  return SIRParserState::ParsingFinish;
}// Finalize ()

void SIRParser::
ResolveSymbols(SIRModule& m) {
  ES_LOG_P(logLevel_ > 1, log_, ">> Resolving symbols locally\n");
  for(SIRModule::iterator it = m.begin(); it != m.end(); ++it) {
    SIRFunction* func = *it;
    ES_LOG_P(logLevel_ > 1, log_, ">>-- In "<< func->GetName() <<"()\n");
    for(SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
      SIRBasicBlock* bb = *bIt;
      for(SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end(); ++iIt) {
        SIRInstruction* instr = *iIt;
        if (instr->GetSIROpcode() == SIROpcode::CALL) {
          // FIXME: indirect call (JALR) needs to be handled
          if (instr->operand_size() != 1) {
            Error(ErrorCode::IRIllegalOperand,
                  "CALL should have exactly one constant operand",
                  instr->GetFileLocation());
            return;
          }
          if (SIRFunction::classof(instr->GetOperand(0))) {
            SIRValue* t = instr->GetOperand(0);
            push_back_unique(t, func->callees_);
            push_back_unique(func, static_cast<SIRFunction*>(t)->callers_);
            continue;
          } else if (!SIRConstant::classof(instr->GetOperand(0))) {
            // FIXME: indirect call (JALR) needs to be handled
            Error(ErrorCode::IRIllegalOperand,
                  "CALL should have exactly one constant operand",
                  instr->GetFileLocation());
            return;
          }
          SIRConstant* tc = static_cast<SIRConstant*>(instr->GetOperand(0));
          if (!tc->IsSymbol()) {
            Error(ErrorCode::IRIllegalOperand,"CALL operand should be a symbol",
                  instr->GetFileLocation());
            return;
          }
          if (!m.HasSymbol(tc->GetSymbol())) { continue; }
          if (!SIRFunction::classof(m.GetSymbolValue(tc->GetSymbol()))){continue;}
          SIRValue* t = m.GetSymbolValue(tc->GetSymbol());
          push_back_unique(t, func->callees_);
          push_back_unique(func, static_cast<SIRFunction*>(t)->callers_);
        }// if (instr->GetSIROpcode() == SIROpcode::CALL)
        for (SIRInstruction::operand_iterator oIt = instr->operand_begin();
             oIt != instr->operand_end(); ++oIt) {
          if (SIRConstant::classof(*oIt)) {
            SIRConstant* c = static_cast<SIRConstant*>(*oIt);
            if (!c->IsSymbol()) { continue; }
            SIRValue* val = m.GetSymbolValue(c->GetSymbol());
            if (!val) { continue; }
            if (SIRDataObject::classof(val)) {
              func->AddDataObject(static_cast<SIRDataObject*>(val));
            }
            instr->ChangeOperand(oIt, val);
            ES_LOG_P(logLevel_>2, log_, ">>-->> Symbol \""<<c->GetSymbol()<<"\""
                     <<" points to "<< val->getKindName() <<" <"
                     << val->GetName() <<">\n");
          }
        }// for instr operand_iterator oIt
      }// for bb iterator iIt
    }// for func iterator bIt
  }// for m iterator it
  for (StrSet::iterator it=fileSymbols_.begin(); it!=fileSymbols_.end(); ++it){
    SIRValue* v = m.GetSymbolValue(*it);
    if (v && SIRDataObject::classof(v)) {
      SIRDataObject* obj = static_cast<SIRDataObject*>(v);
      for (SIRDataObject::sym_iterator sIt = obj->sym_begin();
          sIt != obj->sym_end(); ++sIt) {
        const string& l = sIt->first;
        if (!sIt->second) {
          SIRValue* val = m.GetSymbolValue(l);
          if (val && (!SIRConstant::classof(val)
                      || !static_cast<SIRConstant*>(val)->IsSymbol())) {
            sIt->second = val;
            if (SIRDataObject::classof(val)) { val->AddUse(obj); }
          }
        }// if (!sIt->second)
      }// for obj sym_iterator sIt
    }// if (v && SIRDataObject::classof(v))
  }// for i = 0 to fileSymbols_.size()-1
}// ResolveSymbols()

SIRParserState_t SIRParser::
ParserErr(ErrorCode_t ec, const std::string& msg, const FileLocation& fLoc) {
  errors_.push_back(Error(ec, msg, fLoc));
  return SIRParserState::ParsingErr;
}

SIRParserState_t SIRParser::
ParserErr(ErrorCode_t ec, const std::string& msg) {
  errors_.push_back(Error(ec, msg));
  return SIRParserState::ParsingErr;
}

ostream& ES_SIMD::
operator<<(ostream& out, const SIRToken& t) {
  out <<"ln"<< t.fLoc_.line_ <<": {"<< t.type_ <<"}";
  if (!t.val_.empty()) { out <<"=\""<< t.val_ <<"\""; }
  return out;
}

////////////////////////////////////////////////////////////////////////////////
//                      Enum related definition
////////////////////////////////////////////////////////////////////////////////
DEFINE_ENUM(ES_SIMD, SIRParserState, SIRPARSERSTATE_ENUM)
DEFINE_ENUM(ES_SIMD, SIRTokenType,   SIRTOKENTYPE_ENUM)
DEFINE_ENUM(ES_SIMD, SIRSectionType, SIRSECTIONTYPE_ENUM)
