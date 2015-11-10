#ifndef ES_SIMD_BASELINEINSTRDATA_HH
#define ES_SIMD_BASELINEINSTRDATA_HH

#include "Target/TargetInstrData.hh"

namespace ES_SIMD {
  class SIRInstruction;
  class BaselineBasicInfo;

  class BaselineInstrData : public TargetInstrData {
    bool toWB_;
    bool toRF_;
    bool isPredicateValue_;
    SIRInstruction* commProd_;  ///< The instruction that provides communication
    SIRInstruction* commCons_;  ///< The instruction that provides communication
    IntVector operandBypassID_;
    IntVector operandComm_;
    IntVector predicatePhyID_;
    
  public:
    enum {
      COMM_NONE, COMM_BROADCAST, COMM_LEFT, COMM_RIGHT, COMM_HEAD, COMM_TAIL
    };
    BaselineInstrData(SIRInstruction* instr, const BaselineBasicInfo& target);
    virtual ~BaselineInstrData();

    virtual void Print(std::ostream& o) const;

    virtual void AssignPhyRegisters();
    virtual void ResetOperandInfo();

    SIRInstruction* GetCommProducer() const { return commProd_; }
    void SetCommProducer(SIRInstruction* p) { commProd_ = p;    }
    SIRInstruction* GetCommConsumer() const { return commCons_; }
    void SetCommConsumer(SIRInstruction* p) { commCons_ = p;    }
    void ResetBypass();
    virtual void SwapOperand(unsigned a, unsigned b);

    void SetOperandBypass(int o, int b) { operandBypassID_[o] = b;    }
    int  GetOperandBypass(int o)  const { return operandBypassID_[o]; }

    void SetOperandComm(int o, int c) { operandComm_[o] = c;    }
    int  GetOperandComm(int o)  const { return operandComm_[o]; }

    void SetToWriteback(bool w) { toWB_ = w; }
    void SetToRF(bool r)        { toRF_ = r; if (r) toWB_ = r; }
    bool ToWriteback()    const { return toWB_; }
    bool ToRF()           const { return toRF_; }

    bool HasBroadcast() const;
    bool IsBroadcastedValue(int v) const;

    void SetIsPredicateValue(bool p)  { isPredicateValue_ = p;    }
    bool IsPredicateValue()     const { return isPredicateValue_; }
    void SetPredicatePhyID(unsigned i, unsigned p) { predicatePhyID_[i] = p; }
    int  GetPredicatePhyID(unsigned i) const { return predicatePhyID_[i]; }

    void Dump(Json::Value& iInfo) const;
  };// class BaselineInstrData
  void SetupCommPair(SIRInstruction* prod, SIRInstruction* cons);
}// namespace ES_SIMD

#endif//ES_SIMD_BASELINEINSTRDATA_HH
