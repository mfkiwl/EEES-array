#ifndef ES_SIMD_BASELINEFUNCDATA_HH
#define ES_SIMD_BASELINEFUNCDATA_HH

#include "Target/TargetFuncData.hh"
#include "Target/TargetSpillSlot.hh"
#include "DataTypes/ContainerTypes.hh"

namespace ES_SIMD {
  class BaselineBasicInfo;

  class BaselineFuncData : public TargetFuncData {
    const BaselineBasicInfo& target_;
    unsigned cpStackOffset_, peStackOffset_;
    virtual void PrintCodeGenStat(std::ostream& o) const;
  public:
    BaselineFuncData(SIRFunction* func, const BaselineBasicInfo& target);
    virtual ~BaselineFuncData();

    virtual int GetCodeSize() const;

    const BaselineBasicInfo& GetTarget() const { return target_; }

    virtual void InitRegAlloc();
    void UpdateRegPressure();
    unsigned GetLoadLatency(bool vect) const;

    unsigned GetCPStackOffset() const;
    unsigned GetPEStackOffset() const;
    unsigned GetSpillSlotOffset(unsigned idx, bool vect) {
      return vect ? GetPESpillSlotOffset(idx) : GetCPSpillSlotOffset(idx);
    }
    unsigned GetCPSpillSlotOffset(unsigned idx) const;
    unsigned GetPESpillSlotOffset(unsigned idx) const;
    virtual bool ClobbersPhyReg(int r, int rc) const;
    virtual void Print(std::ostream& o) const;
    virtual void ValuePrint(std::ostream& o) const;
  };// class BaselineFuncData
}// namespace ES_SIMD

#endif//ES_SIMD_BASELINEFUNCDATA_HH
