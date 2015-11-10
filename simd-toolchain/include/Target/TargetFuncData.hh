#ifndef ES_SIMD_TARGETFUNCDATA_HH
#define ES_SIMD_TARGETFUNCDATA_HH

#include "DataTypes/ContainerTypes.hh"

namespace ES_SIMD {
  class SIRFunction;
  class TargetFuncRegAllocInfo;

  class TargetFuncData {
  protected:
    SIRFunction* func_;
    int targetAddress_;
    TargetFuncRegAllocInfo* regAllocInfo_;
    TargetFuncData(SIRFunction* func) : func_(func), targetAddress_(-1),
                                        regAllocInfo_(NULL) {}
    virtual void PrintCodeGenStat(std::ostream& o) const;
  public:
    SIRFunction* Function() const { return func_; }
    virtual ~TargetFuncData();

    void SetTargetAddress(int a) { targetAddress_ = a;    }
    int GetTargetAddress() const { return targetAddress_; }

    /// Register allocation related methods
    virtual void InitRegAlloc() {}
    TargetFuncRegAllocInfo* GetRegAllocInfo() const { return regAllocInfo_; }
    int GetValueFirstUsedTime(int v) const;

    /// \brief Interface for query of whether a physical register is used
    ///        by the target function.
    ///
    /// \param r Physical register index.
    /// \param rc Physical register class to be queried.
    /// \return true if the register is used by this function or its calles,
    ///         otherwise false.
    virtual bool ClobbersPhyReg(int r, int rc) const { return false; }
    virtual int  GetCodeSize() const { return -1; }
    virtual void Print(std::ostream& o) const = 0;
    virtual void ValuePrint(std::ostream& o) const;
    void PrintStatistics(std::ostream& o) const;
  };// class TargetFuncData
};// namespace ES_SIMD

#endif//ES_SIMD_TARGETFUNCDATA_HH

