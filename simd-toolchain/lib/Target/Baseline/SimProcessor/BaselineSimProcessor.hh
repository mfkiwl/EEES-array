#ifndef ES_SIMD_BASELINESIMPROCESSOR_HH
#define ES_SIMD_BASELINESIMPROCESSOR_HH

#include "Simulation/SimProcessor.hh"
#include "Simulation/SimSRAM.hh"
#include "Simulation/SimProgramSection.hh"
#include "Utils/VerilogMemInit.hh"

namespace ES_SIMD {
  class SimProgramSection;
  class SimCoreBase;
  class BaselineBasicInfo;

  class BaselineSimProcessor : public SimProcessorBase {
  public:
    BaselineSimProcessor(
      const TargetBasicInfo* tgt, unsigned logLv, std::ostream& log,
      unsigned traceLv, std::ostream& trace, std::ostream& err);
    virtual ~BaselineSimProcessor();

    virtual void SetBranchTrace(bool t);
    virtual void Reset();
    virtual void CycleAction();
    virtual void InitProcessor();
    virtual bool AddInstructionInit(const std::string& cmd);
    virtual bool AddDataInit(const std::string& cmd);
    virtual bool AddDataBinary(const std::string& cmd);
    virtual void DumpScalarDataMemory(std::ostream& o) const;
    virtual void DumpVectorDataMemory(std::ostream& o) const;

    virtual uint32_t GetProgramCounter() const;
    virtual uint32_t GetScalarContextValue(unsigned addr) const;
    virtual void     GetVectorContextValue(unsigned addr, uint32_t* val) const;
    virtual uint32_t GetScalarMemoryValue(unsigned addr) const;
    virtual void     GetVectorMemoryValue(unsigned addr, uint32_t* val) const;
    virtual size_t GetScalarContextSize() const;
    virtual size_t GetVectorContextSize() const;
    virtual size_t GetScalarMemorySize() const;
    virtual size_t GetVectorMemorySize() const;
    virtual unsigned GetVectorLength() const;
    virtual void PrintScalarOperation(unsigned addr, std::ostream& o) const;
    virtual void PrintVectorOperation(unsigned addr, std::ostream& o) const;
    virtual void PrintSimStatistics(std::ostream& o) const;
  private:
    bool InitInstructionMemory(bool isPE, const std::string& filename);
    bool InitDataMemory(bool isPE, const std::string& filename);
    const BaselineBasicInfo& tgtInfo_;
    SimProgramSection cpCode_;
    SimProgramSection peCode_;

    SimCoreBase* cp_;
    SimCoreBase* peArray_;
    SimSRAMBase* cpDataMemory_;
    SimSRAMBase* peDataMemory_;

    static RegisterSimProcessor<BaselineSimProcessor> reg_;
  };// class BaselineSimProcessor
}// namespace ES_SIMD

#endif//ES_SIMD_BASELINESIMPROCESSOR_HH
