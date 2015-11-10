#ifndef ES_SIMD_SPLITSIRCALLBLOCK_HH
#define ES_SIMD_SPLITSIRCALLBLOCK_HH

#include "SIR/Pass.hh"

namespace ES_SIMD {
  class SplitSIRCallBlock : public SIRFunctionPass {
  public:
    SplitSIRCallBlock(unsigned logLv, std::ostream& log, std::ostream& err)
      : SIRFunctionPass("SIRCallBlockSplit", "SIR call block splitter",
                        logLv, log, err) {}
    virtual ~SplitSIRCallBlock();
    virtual bool RunOnSIRFunction(SIRFunction* func);
  };// class SplitSIRCallBlock
}// namespace ES_SIMD

#endif//ES_SIMD_SPLITSIRCALLBLOCK_HH
