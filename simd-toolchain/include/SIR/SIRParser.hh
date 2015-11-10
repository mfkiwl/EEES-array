#ifndef ES_SIMD_SIRPARSER_HH
#define ES_SIMD_SIRPARSER_HH

#include "DataTypes/SIRDataType.hh"
#include "DataTypes/Object.hh"
#include "DataTypes/ASMLine.hh"
#include "DataTypes/FileLocation.hh"
#include "DataTypes/EnumFactory.hh"
#include "DataTypes/Error.hh"
#include <iostream>
#include <string>
#include <tr1/unordered_map>
#include <tr1/unordered_set>

#define SIRPARSERSTATE_ENUM(DEF, DEFV) \
  DEF(ParsingStart)                    \
  DEF(ParsingFinish)                   \
  DEF(ProcessingDirective)             \
  DEF(InstrOutput)                     \
  DEF(InstrInput)                      \
  DEF(EnterFunction)                   \
  DEF(ExitFunction)                    \
  DEF(EnterBasicBlock)                 \
  DEF(BlockLiveIn)                     \
  DEF(InitMA)                          \
  DEF(SetMAEntry)                      \
  DEF(SetMLoc)                         \
  DEF(SetArgSpc)                       \
  DEF(SetNumArgs)                      \
  DEF(SetRetVals)                      \
  DEF(SetObjSize)                      \
  DEF(ProcessingLabel)                 \
  DEF(InitData)                        \
  DEF(DeclData)                        \
  DEF(DeclGlobalSym)                   \
  DEF(DeclLocalSym)                    \
  DEF(SetSection)                      \
  DEF(ParsingErr)                      \
  DEF(InitErr)

#define SIRTOKENTYPE_ENUM(DEF, DEFV)   \
  DEF(EndLine)                         \
  DEF(DirectiveKey)                    \
  DEF(DirectiveOperand)                \
  DEF(Opcode)                          \
  DEF(Operand)                         \
  DEF(Label)                           \
  DEF(Comment)                         \
  DEF(Unknown)

#define SIRSECTIONTYPE_ENUM(DEF, DEFV) \
  DEF(Code)                            \
  DEF(Data)                            \
  DEF(VData)                           \
  DEF(Unknown)

namespace ES_SIMD {
  DECLARE_ENUM(SIRParserState, SIRPARSERSTATE_ENUM)
  DECLARE_ENUM(SIRTokenType,   SIRTOKENTYPE_ENUM)
  DECLARE_ENUM(SIRSectionType, SIRSECTIONTYPE_ENUM)

  class SIRValue;
  class SIRModule;
  class SIRFunction;
  class SIRBasicBlock;
  class SIRInstruction;
  class SIRDataObject;

  struct SIRToken {
    SIRTokenType_t type_;
    FileLocation fLoc_;
    std::string val_;
    SIRToken(SIRTokenType_t t, const FileLocation& fl) : type_(t), fLoc_(fl) {}
    SIRToken(SIRTokenType_t t, const FileLocation& fl, const std::string& v)
      : type_(t), fLoc_(fl), val_(v) {}
    SIRToken(SIRTokenType_t t, const std::string& f, int l)
      : type_(t), fLoc_(f, l) {}
    SIRToken(SIRTokenType_t t, const std::string& f, int l,const std::string& v)
      : type_(t), fLoc_(f, l), val_(v) {}
    friend std::ostream& operator<<(std::ostream& out, const SIRToken& t);
  };

  class SIRParser : NonCopyable {
  private:
    SIRParserState_t state_;
    SIRSectionType_t sectionType_;
    std::vector<ASMLine>  inputBuffer_;
    std::vector<SIRToken> tokenBuffer_;
    std::vector<Error>    errors_;
  public:
    typedef std::vector<Error>::iterator       err_iterator;
    typedef std::vector<Error>::const_iterator err_const_iterator;
    SIRParser(int logLevel, std::ostream& log, std::ostream& err)
      : state_(SIRParserState::ParsingFinish),
        sectionType_(SIRSectionType::Unknown), logLevel_(logLevel),
        log_(log), err_(err) {}
    void ParseSIRFile(const std::string& inFile, SIRModule& m);
    void SetLogLevel(int l) { logLevel_ = l; }

    bool   err_empty() const { return errors_.empty(); }
    size_t err_size()  const { return errors_.size();  }
    void   err_clear()       { errors_.clear();        }
    err_iterator       err_begin()       { return errors_.begin(); }
    err_const_iterator err_begin() const { return errors_.begin(); }
    err_iterator       err_end()         { return errors_.end();   }
    err_const_iterator err_end()   const { return errors_.end();   }
  private:
    void SIRLex(const std::string& filename);
    SIRParserState_t ConsumeToken(unsigned tkIndex, SIRModule& m);
    SIRParserState_t Finalize(SIRModule& m);
    /// \brief Trying to resolve local symbols
    void ResolveSymbols(SIRModule& m);
    void ConstructFunctionCFG(SIRFunction* func);
    void UpdateFunctionStackInfo(SIRFunction* func);
    void UpdateFunctionLiveness(SIRFunction* func);
    void UpdateFunctionValueID(SIRFunction* func);
    void CleanupPrologueEpilogue(SIRFunction* func);
    void ResolveKernelLaunchParams(SIRFunction* func);
    SIRParserState_t ParserErr(ErrorCode_t ec, const std::string& msg,
                               const FileLocation& fLoc);
    SIRParserState_t ParserErr(ErrorCode_t ec, const std::string& msg);
    int logLevel_;
    std::ostream& log_;
    std::ostream& err_;

    SIRFunction*    currFunc_;
    SIRBasicBlock*  currBB_;
    SIRInstruction* currInstr_;
    SIRDataObject*  currDataObj_;
    SIRDataType_t   currDataType_;
    int currMemLoccationID_;
    int memAliasOpA_;
    int argSpaceID_;
    std::vector<std::string> activeLabel_;
    unsigned currOperandCounter_;
    unsigned currValueCounter_;
    std::tr1::unordered_map<std::string, SIRValue*> currDefTable_;
    std::tr1::unordered_map<int, SIRBasicBlock*>    currBBTable_;
    std::tr1::unordered_map<std::string, int>       currFuncVars_;

    std::tr1::unordered_map<std::string, int> funcRegValueTab_;
    std::tr1::unordered_map<int, std::string> funcRegNameTab_;
    std::tr1::unordered_set<std::string> localSymbols_;
    std::tr1::unordered_set<std::string> fileSymbols_;

    // Helper methods
    bool IsSIRLabel(const std::string& t) {
      return (tokenBuffer_.back().type_ == SIRTokenType::EndLine)
        && (t.rfind(":") == (t.size() - 1));
    }
    bool IsSIRDirectiveKey(const std::string& t) {
      return (tokenBuffer_.back().type_ == SIRTokenType::EndLine)
        && (t.find(".") == 0);
    }
    bool IsSIRDirectiveOperand() {
      return (tokenBuffer_.back().type_ == SIRTokenType::DirectiveKey)
        || (tokenBuffer_.back().type_ == SIRTokenType::DirectiveOperand);
    }
    bool IsSIROpcode(const std::string& t) {
      return (tokenBuffer_.back().type_ == SIRTokenType::EndLine)
        || (tokenBuffer_.back().type_ == SIRTokenType::Label);
    }
    bool IsSIROperand(const std::string& t) {
      return (tokenBuffer_.back().type_ == SIRTokenType::Opcode)
        || (tokenBuffer_.back().type_ == SIRTokenType::Operand);
    }
  };// class SIRParser
}// namespace ES_SIMD

#endif//ES_SIMD_SIRPARSER_HH
