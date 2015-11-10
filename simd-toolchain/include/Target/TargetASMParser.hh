#ifndef ES_SIMD_TARGETASMPARSER_HH
#define ES_SIMD_TARGETASMPARSER_HH

#include "DataTypes/Object.hh"
#include "DataTypes/EnumFactory.hh"
#include "DataTypes/ASMLine.hh"
#include "DataTypes/SIRDataType.hh"

#include <iostream>
#include <string>
#include <queue>
#include <map>
#include <memory>

#define ASMPARSERSTATE_ENUM(DEF, DEFV)          \
  DEF(ParsingStart)                             \
  DEF(ParsingFinish)                            \
  DEF(ProcessingDirective)                      \
  DEF(ProcessingInstr)                          \
  DEF(ProcessingPacket)                         \
  DEF(ProcessingLabel)                          \
  DEF(DataInit)                                 \
  DEF(SetAddress)                               \
  DEF(ParsingErr)                               \
  DEF(InitErr)

#define ASMTOKENTYPE_ENUM(DEF, DEFV)            \
  DEF(EndLine)                                  \
  DEF(DirectiveKey)                             \
  DEF(DirectiveOperand)                         \
  DEF(PacketSep)                                \
  DEF(Opcode)                                   \
  DEF(Operand)                                  \
  DEF(RegOperand)                               \
  DEF(ImmOperand)                               \
  DEF(LabelOperand)                             \
  DEF(Label)                                    \
  DEF(Comment)                                  \
  DEF(Unknown)

#define ASMSECTIONTYPE_ENUM(DEF, DEFV) \
  DEF(Code)                            \
  DEF(Data)

namespace ES_SIMD {
  DECLARE_ENUM(ASMParserState, ASMPARSERSTATE_ENUM)
  DECLARE_ENUM(ASMTokenType,   ASMTOKENTYPE_ENUM)
  DECLARE_ENUM(ASMSectionType,   ASMSECTIONTYPE_ENUM)

  class TargetBinaryProgram;
  class TargetBasicInfo;

  struct ASMToken {
    ASMTokenType_t type_;
    int lineNum_;
    std::string val_;
    ASMToken(ASMTokenType_t t, int l) : type_(t), lineNum_(l) {}
    ASMToken(ASMTokenType_t t, int l, const std::string& v)
      : type_(t), lineNum_(l), val_(v) {}
    friend std::ostream& operator<<(std::ostream& out, const ASMToken& t);
  };

  // Lexer is included in this class
  class TargetASMParser : NonCopyable {
  protected:
    ASMParserState_t parserState_;
    ASMSectionType_t currSectionType_;
    std::vector<ASMLine> inputBuffer_;
    std::queue<ASMToken> tokenBuffer_;

    int instrCounter_;
    int instrPacketCounter_;
    int currAddress_;
    int currDataSec_;
    SIRDataType_t currDataType_;
    TargetBinaryProgram* prog_;
    std::vector<std::string> currLabel_;
  public:
    TargetASMParser(int logLv=0, std::ostream& log=std::cout,
                    std::ostream& err=std::cerr)
      : parserState_(ASMParserState::ParsingStart), instrCounter_(0),
        instrPacketCounter_(0), currAddress_(0), currDataSec_(0),
        prog_(NULL), logLevel_(logLv), log_(log), err_(err) {}
    virtual ~TargetASMParser();

    void SetTargetProgram(TargetBinaryProgram* prog) { prog_ = prog; }
    void Run();
    void ParseASMLine(const std::string& ln);
    void ReadASMFile(const std::string& f);

    bool TerminatedByError() const {
      return parserState_ == ASMParserState::ParsingErr;
    }
    TargetBinaryProgram* GetBinaryProgram() { return prog_; }
  protected:
    virtual void ASMLex();
    virtual void PrepParser();
    virtual ASMParserState_t ConsumeToken(
      const ASMToken& tk) = 0;
    virtual ASMParserState_t Finalize() = 0;
    bool IsASMLabel(const std::string& t) {
      return (tokenBuffer_.back().type_ == ASMTokenType::EndLine)
        && (t.rfind(":") == (t.size() - 1));
    }
    bool IsASMDirectiveKey(const std::string& t) {
      return (tokenBuffer_.back().type_ == ASMTokenType::EndLine)
        && (t.find(".") == 0);
    }
    bool IsASMDirectiveOperand() {
      return (tokenBuffer_.back().type_ ==ASMTokenType::DirectiveKey)
        || (tokenBuffer_.back().type_ ==ASMTokenType::DirectiveOperand);
    }
    bool IsPacketSep(const std::string& t) {
      return t == "||";
    }
    bool IsASMOpcode(const std::string& t) {
      return (tokenBuffer_.back().type_ == ASMTokenType::EndLine)
        || (tokenBuffer_.back().type_ == ASMTokenType::Label)
        || (tokenBuffer_.back().type_ == ASMTokenType::PacketSep);
    }
    bool IsASMOperand(const std::string& t) {
      return (tokenBuffer_.back().type_ ==ASMTokenType::Opcode)
        || (tokenBuffer_.back().type_ ==ASMTokenType::Operand)
        || (tokenBuffer_.back().type_ ==ASMTokenType::RegOperand)
        || (tokenBuffer_.back().type_ ==ASMTokenType::ImmOperand)
        || (tokenBuffer_.back().type_ ==ASMTokenType::LabelOperand);
    }

    int logLevel_;
    std::ostream& log_;
    std::ostream& err_;
  };// class TargetASMParser

  template <typename T>
  TargetASMParser* CreateTargetASMParser(
    const TargetBasicInfo* tgt,int logLv,std::ostream& log,std::ostream& err) {
    return new T(tgt, logLv, log, err);
  }

  /// \brief Factory class for TargetASMParser
  class TargetASMParserFactory {
  public:
    typedef TargetASMParser*(*TargetASMParserCreator)(
      const TargetBasicInfo* tgt,int logLv,std::ostream& log,std::ostream& err);
    typedef std::map<std::string, TargetASMParserCreator> TargetASMCreatorMap;
    /// \brief Create a target assembly parser based on a TargetBasicInfo.
    /// \param tgt   The target.
    /// \param logLv Verbose level.
    /// \param log   The log output stream.
    /// \param err   The error output stream.
    /// \return a pointer to the generated TargetASMParser for the target.
    ///         NULL if there is any error
    static TargetASMParser* GetTargetASMParser(
      const TargetBasicInfo* tgt,int logLv,std::ostream& log,std::ostream& err);
    static TargetASMCreatorMap* GetMap() {
      if (!map_.get()) { map_.reset(new TargetASMCreatorMap()); }
      return map_.get();
    }
  private:
    static std::auto_ptr<TargetASMCreatorMap> map_;
  };// class TargetASMParserFactory

  template <typename T>
  class RegisterTargetASMParser : public TargetASMParserFactory {
  public:
    RegisterTargetASMParser(const std::string name) {
      (*GetMap())[name] = CreateTargetASMParser<T>;
    }
  };
}// namespace ES_SIMD

#endif//ES_SIMD_TARGETASMPARSER_HH
