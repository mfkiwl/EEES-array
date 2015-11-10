#ifndef ES_SIMD_BASELINEASMPARSER_HH
#define ES_SIMD_BASELINEASMPARSER_HH

#include "Target/TargetASMParser.hh"

namespace ES_SIMD {
  class BaselineBasicInfo;
  class BaselineInstruction;
  class BaselineInstructionPacket;

  class BaselineASMParser : public TargetASMParser {
    const BaselineBasicInfo& targetInfo_;

    BaselineInstruction*       currInstr_;
    BaselineInstructionPacket* currPacket_;
  public:
    BaselineASMParser(const TargetBasicInfo* t, int logLv,
                      std::ostream& log, std::ostream& err);
    virtual ~BaselineASMParser();
  private:
    virtual void PrepParser();
    virtual ASMParserState_t ConsumeToken(const ASMToken& tk);
    virtual ASMParserState_t Finalize();

    bool CloseCurrInstr();
    bool CloseCurrPacket();
    static bool IsVectorOpcode(const ASMToken& t) {
      return (t.val_.find("v.") == 0);
    }
    static bool IsImmInstr(const ASMToken& t) {
      return !t.val_.empty()
        && ((*t.val_.rbegin() == 'i') || (*t.val_.rbegin() == 'I'));
    }
    static bool IsPredicatedOpcode(const std::string& s) {
      return s.find(".P") != std::string::npos;
    }
    static RegisterTargetASMParser<BaselineASMParser> reg_;
  };// class BaselineASMParser
}// namespace ES_SIMD

#endif//ES_SIMD_BASELINEASMPARSER_HH
