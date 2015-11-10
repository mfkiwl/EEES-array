#ifndef ES_SIMD_TARGETFUNCREGALLOCINFO_HH
#define ES_SIMD_TARGETFUNCREGALLOCINFO_HH

#include "DataTypes/ContainerTypes.hh"
#include "Target/TargetSpillSlot.hh"

namespace ES_SIMD {
  class SIRFunction;

  class TargetFuncRegAllocInfo {
  protected:
    SIRFunction* func_;
    int numRegClasses_;
    Int2IntMap preAllocatedValues_;
    Int2IntMap regAssignment_;
    Int2IntMap valueRegClassMap_;
    IntSet     preDefinedValue_;
    IntSet     nonSpillVals_;
    IntSet     spilledValues_;
    Int2IntMap spillerTempValues_;
    Int2IntMap spilledArgs_;
    IntSet     spillSlotValues_;
    Int2IntMap conflictCounter_;
    std::vector<size_t>  regPressure_;
    std::vector<IntSet>  usedPhyRegs_;
    std::vector<IntSet>  reservedPhyRegs_;
    Int2FloatMap spillCost_;

    IntVector    spillCounter_;
    std::vector<std::tr1::unordered_map<int, TargetSpillSlot> > spills_;
    std::vector<Int2IntMap>                                     spillSlotVal_;

    IntSet     immRegs_;
    std::vector<Int2IntMap> promotedImmRegs_;
  public:
    TargetFuncRegAllocInfo(SIRFunction* func): func_(func), numRegClasses_(0) {}
    virtual ~TargetFuncRegAllocInfo();

    SIRFunction* Function() const { return func_; }

    /// Immediate registers
    int  PromoteImmToReg(int imm, unsigned rc);
    const IntSet& ImmRegs() const { return immRegs_; }
    const Int2IntMap& PromotedImmRegs(unsigned rc) const {
      return promotedImmRegs_[rc];
    }
    bool IsImmReg(int v) const { return IsElementOf(v,immRegs_); }
    int  GetRegImmediate(int ireg) const;
    /// Register allocation related methods
    void InitRegAlloc(int numRegClass);
    Int2IntMap&  ConflictCounter() { return conflictCounter_; }
    int  ValueConflictCount(int v) const {
      return IsElementOf(v,conflictCounter_) ? GetValue(v,conflictCounter_) : 0;
    }
    int  GetNumStackSpills(unsigned rc) const {
      return (rc < spillCounter_.size()) ? spillCounter_[rc] : 0;
    }
    /// Register assignment
    void AssignPhyRegister(int v, int r)    { regAssignment_[v] = r; }
    int  GetValuePhyRegister(int v) const {
      return IsElementOf(v, regAssignment_) ? GetValue(v, regAssignment_) : -1;
    }
    Int2IntMap&       RegAssignment()       { return regAssignment_; }
    const Int2IntMap& RegAssignment() const { return regAssignment_; }
    void AddUsedPhyRegs(int r, int rc) {
      if (rc<static_cast<int>(usedPhyRegs_.size())){usedPhyRegs_[rc].insert(r);}
    }
    /// Pre-allocated values
    void ReservePhyReg(unsigned rc, int r) {
      if (rc < reservedPhyRegs_.size()) { reservedPhyRegs_[rc].insert(r);  }
    }
    const std::vector<IntSet>&  ReservedPhyRegs()const{return reservedPhyRegs_;}
    void AddPreAllocatedValue(int v, int r) { preAllocatedValues_[v] = r; }
    bool IsPreAllocValue(int v) const {
      return IsElementOf(v,preAllocatedValues_);
    }
    const Int2IntMap& PreAllocatedValues() const { return preAllocatedValues_; }

    void AddPreDefinedValue(int v)          { preDefinedValue_.insert(v); }
    bool IsPreDefinedValue(int v) const{return IsElementOf(v,preDefinedValue_);}
    void AddNonSpillValue(int v)            { nonSpillVals_.insert(v);    }
    bool IsNonSpillValue(int v)   const{return IsElementOf(v, nonSpillVals_);  }
    /// \brief Track the temporary value used by the spiller to avoid spilling
    ///        these values.
    /// \param t The temporary value.
    /// \param v The corresponding value of t.
    void AddSpillTempValue(int t, int v) {
      spillerTempValues_[t] = v;
    }
    bool IsValueSpilled(int v)    const {return IsElementOf(v, spilledValues_); }
    IntSet&       SpilledValues()       { return spilledValues_; }
    const IntSet& SpilledValues() const { return spilledValues_; }
    void AddSpilledValue(int v)             { spilledValues_.insert(v);   }
    void AddSpilledArg(int v, int so)       { spilledArgs_[v] = so;     }
    /// Register class methods
    void SetValueRegClass(int v, int rc)    { valueRegClassMap_[v] = rc;  }
    const Int2IntMap& ValueRegClassMap()   const { return valueRegClassMap_;   }
    int GetValueRegClass(int v) const {
      return IsElementOf(v, valueRegClassMap_)
        ? GetValue(v, valueRegClassMap_) : -1;
    }
    const IntSet&     NonSpillVals()  const { return nonSpillVals_; }
    const Int2IntMap& SpilledArgs()   const { return spilledArgs_;  }
    float GetSpillCost(int v) const {
      return IsElementOf(v, spillCost_) ? GetValue(v, spillCost_) : 0.0f;
    }
    Int2FloatMap&     SpillCost()           { return spillCost_; }
    TargetSpillSlot& GetSpillSlot(int v, unsigned rc);
    int GetSpillSlotIndex(int v, unsigned rc) {
      return GetSpillSlot(v, rc).Index();
    }
    int GetSpillSlotValue(int s, unsigned rc) const {
      return IsElementOf(s, spillSlotVal_[rc]) ?
        GetValue(s, spillSlotVal_[rc]) : -1;
    }
    /// Register pressure methods
    /// \brief Get function register pressure of a specified register class
    /// \param rc The register class under query.
    /// \return The register pressure of rc, if rc is valid, otherwise 0.
    size_t GetRegPressure(unsigned rc) const { return regPressure_[rc]; }
    size_t& GetRegPressureRef(unsigned rc)   { return regPressure_[rc]; }
    int GetValueFirstUsedTime(int v) const;

    /// \brief Interface for query of whether a physical register is used
    ///        by the target function.
    ///
    /// \param r Physical register index.
    /// \param rc Physical register class to be queried.
    /// \return true if the register is used by this function or its calles,
    ///         otherwise false.
    bool ClobbersPhyReg(int r, unsigned rc) const {
      if (rc<usedPhyRegs_.size()) { return (IsElementOf(r, usedPhyRegs_[rc])); }
      return false;
    }
  };// class TargetFuncRegAllocInfo
};// namespace ES_SIMD

#endif//ES_SIMD_TARGETFUNCREGALLOCINFO_HH

