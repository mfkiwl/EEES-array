#include "Target/TargetASMParser.hh"
#include "Target/TargetBasicInfo.hh"
#include "Target/TargetBinaryProgram.hh"
#include "Utils/FileUtils.hh"
#include "Utils/LogUtils.hh"
#include "Utils/StringUtils.hh"

using namespace std;
using namespace ES_SIMD;

auto_ptr<TargetASMParserFactory::TargetASMCreatorMap>
TargetASMParserFactory::map_;

TargetASMParser* TargetASMParserFactory::
GetTargetASMParser(
  const TargetBasicInfo* tgt, int logLv, std::ostream& log, std::ostream& err) {
  const string& name = tgt->GetName();
  TargetASMParserFactory::TargetASMCreatorMap* m = GetMap();
  TargetASMCreatorMap::iterator it = m->find(name);
  return (it == m->end()) ? NULL : it->second(tgt, logLv, log, err);
}

TargetASMParser::~TargetASMParser() {}

void TargetASMParser::
ReadASMFile(const std::string& f) {
  FileStatus_t fStat = ReadASMFileLines(inputBuffer_, f);
  if (fStat != FileStatus::OK) {
  }
}// ReadASMFile()

void TargetASMParser::PrepParser() {}

void TargetASMParser::
Run() {
  if (prog_ == NULL) {
    ES_ERROR_MSG_T(err_, "Internal", "Binary program not initilized\n");
    parserState_ = ASMParserState::InitErr;
    return;
  }
  ES_LOG_P(logLevel_>=2, log_, ">> Running lexer...\n");
  ASMLex();
  ES_LOG_P(logLevel_>=2, log_, ">>  -- "<< tokenBuffer_.size()
           <<" token(s) found in "<< inputBuffer_.size() <<" lines\n");
  parserState_ = ASMParserState::ParsingStart;
  currSectionType_ = ASMSectionType::Code;
  instrCounter_ = instrPacketCounter_ = 0;
  ES_LOG_P(logLevel_>=2, log_, ">> Parsing...\n");
  while ((parserState_ != ASMParserState::ParsingFinish)
         && (parserState_ != ASMParserState::ParsingErr)) {
    ASMParserState_t nextState;
    if (!tokenBuffer_.empty()) {
      const ASMToken& t = tokenBuffer_.front();
      nextState = ConsumeToken(t);
      tokenBuffer_.pop();
    } else {
      ES_LOG_P(logLevel_>=2, log_, ">> Parser finalizing...\n");
      nextState = Finalize();
    }
    ES_LOG_P(logLevel_>=4, log_, ">>>>>> * "<< parserState_ <<"->"
             << nextState <<"\n");
    parserState_ = nextState;
  }// while ((parserState_ != ParsingFinish) && (parserState_ != ParsingErr))
}// Run()

void TargetASMParser::
ASMLex() {
  // Put a dommy EndLine token at the front
  tokenBuffer_.push(ASMToken(ASMTokenType::EndLine, 0));
  for (vector<ASMLine>::iterator it = inputBuffer_.begin();
       it != inputBuffer_.end(); ++it) {
    const ASMLine& ln = *it;
    if (ln.Empty()) { continue; }
    int lid = ln.lineNum_;
    if (ln.HasContent()) {
      vector<std::string> itokens;
      itokens.reserve(4);
      TokenizeString(itokens, ln.line_, ", \t");
      for (vector<string>::iterator tIt = itokens.begin();
           tIt != itokens.end(); ++tIt) {
        ASMTokenType_t tt = ASMTokenType::Unknown;
        string& tk = *tIt;
        if (IsASMLabel(tk)) {
          tt = ASMTokenType::Label;
          tk = tk.substr(0, tk.length()-1);
          prog_->InsertASMLabel(tk);
        } else {
          if (IsASMDirectiveKey(tk)) {
            tt = ASMTokenType::DirectiveKey;
            tk = tk.substr(1);
          } else if (IsASMDirectiveOperand()) {
            tt = ASMTokenType::DirectiveOperand;
          } else if (IsPacketSep(tk))  { tt = ASMTokenType::PacketSep; }
          else if (IsASMOpcode(tk))  { tt = ASMTokenType::Opcode; }
          else if (IsASMOperand(tk)) { tt = ASMTokenType::Operand; }
        }// if (IsASMLabel(tk))
        tokenBuffer_.push(ASMToken(tt, lid, tk));
      }//  for itokens iterator tIt
    }// if (ln.HasContent())
    if (ln.HasComment()) {
      tokenBuffer_.push(ASMToken(ASMTokenType::Comment, lid, ln.comment_));
    }// if (ln.HasComment())
    tokenBuffer_.push(ASMToken(ASMTokenType::EndLine, lid));
  }// for inputBuffer_ iterator it
}// ASMLex()

std::ostream& ES_SIMD::
operator<<(std::ostream& out, const ASMToken& t) {
  out <<"ln"<< t.lineNum_ <<": {"<< t.type_ <<"}";
  if (!t.val_.empty()) { out <<"=\""<< t.val_ <<"\""; }
  return out;
}

////////////////////////////////////////////////////////////////////////////////
//                      Enum related definition
////////////////////////////////////////////////////////////////////////////////
DEFINE_ENUM(ES_SIMD,ASMParserState, ASMPARSERSTATE_ENUM)
DEFINE_ENUM(ES_SIMD,ASMTokenType,   ASMTOKENTYPE_ENUM)
DEFINE_ENUM(ES_SIMD,ASMSectionType, ASMSECTIONTYPE_ENUM)
