#ifndef ES_SIMD_BASELINEMODULEDATA_HH
#define ES_SIMD_BASELINEMODULEDATA_HH

#include "Target/TargetModuleData.hh"

namespace ES_SIMD {
  class BaselineBasicInfo;

  class BaselineModuleData : public TargetModuleData {
    const BaselineBasicInfo& target_;
  public:
    BaselineModuleData(SIRModule* m, const BaselineBasicInfo& t)
      : TargetModuleData(m), target_(t) {
      dataPtr_.resize(2, 0);
      memSegs_.resize(2);
    }
    virtual ~BaselineModuleData();

    virtual TargetFuncData*  InitTargetData(SIRFunction* f);
    virtual TargetBlockData* InitTargetData(SIRBasicBlock* b);
    virtual TargetInstrData* InitTargetData(SIRInstruction* i);

    DataMemorySegments& GetCPMemorySegments()             {return memSegs_[0];}
    const DataMemorySegments& GetCPMemorySegments() const {return memSegs_[1];}
    DataMemorySegments& GetPEMemorySegments()             {return memSegs_[0];}
    const DataMemorySegments& GetPEMemorySegments() const {return memSegs_[1];}

    int GetCPDataMemoryUsage() const { return dataPtr_[0]; }
    int GetPEDataMemoryUsage() const { return dataPtr_[1]; }
    void SetCPDataPtr(int p) { dataPtr_[0] = p; }
    void SetPEDataPtr(int p) { dataPtr_[1] = p; }
  };// class BaselineModuleData
}

#endif//ES_SIMD_BASELINEMODULEDATA_HH
