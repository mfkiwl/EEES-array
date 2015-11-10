#ifndef ES_SIMD_TARGETMODULEDATA_HH
#define ES_SIMD_TARGETMODULEDATA_HH

#include "DataTypes/ContainerTypes.hh"
#include "Target/TargetMemorySegments.hh"
#include <json/json.h>

namespace ES_SIMD {
  class SIRModule;
  class SIRFunction;
  class SIRBasicBlock;
  class SIRInstruction;
  class TargetFuncData;
  class TargetBlockData;
  class TargetInstrData;

  class TargetModuleData {
  protected:
    SIRModule* module_;
    std::tr1::unordered_map<const SIRFunction*,   TargetFuncData*>  funcData_;
    std::tr1::unordered_map<const SIRBasicBlock*, TargetBlockData*> blockData_;
    std::tr1::unordered_map<const SIRInstruction*,TargetInstrData*> instrData_;

    std::vector<DataMemorySegments> memSegs_;
    std::vector<int>                dataPtr_;// Marks the last available entry
    TargetModuleData(SIRModule* module) : module_(module) {}
  public:
    SIRModule* Module() const { return module_; }
    virtual ~TargetModuleData();

    TargetFuncData* GetTargetData(const SIRFunction* f) const {
      return IsElementOf(f, funcData_) ? GetValue(f, funcData_) : NULL;
    }
    TargetBlockData* GetTargetData(const SIRBasicBlock* b) const {
      return IsElementOf(b, blockData_) ? GetValue(b, blockData_) : NULL;
    }
    TargetInstrData* GetTargetData(const SIRInstruction* i) const {
      return IsElementOf(i, instrData_) ? GetValue(i, instrData_) : NULL;
    }

    virtual TargetFuncData*  InitTargetData(SIRFunction* f) = 0;
    virtual TargetBlockData* InitTargetData(SIRBasicBlock* b) = 0;
    virtual TargetInstrData* InitTargetData(SIRInstruction* i) = 0;

    void PrintStatistics(std::ostream& o) const;
    void PrintSymbolTable(std::ostream& o) const;
    void Dump(Json::Value& mInfo) const;

    virtual std::ostream& Print(std::ostream& o) const;
    virtual std::ostream& ValuePrint(std::ostream& o) const;
  };// class TargetModuleData
};// namespace ES_SIMD

#endif//ES_SIMD_TARGETMODULEDATA_HH

