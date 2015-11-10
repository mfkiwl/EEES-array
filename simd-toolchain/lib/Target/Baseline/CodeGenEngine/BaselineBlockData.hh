#ifndef ES_SIMD_BASELINEBLOCKDATA_HH
#define ES_SIMD_BASELINEBLOCKDATA_HH

#include "Target/TargetBlockData.hh"

namespace ES_SIMD {
  class SIRValue;
  class SIRInstruction;
  class BaselineBasicInfo;

  class BaselineBlockData : public TargetBlockData {
    virtual void PrintCodeGenStat(std::ostream& o) const;
  public:
    bool IsBranchDelaySlot(iterator it) const;
    bool IsBranchDelaySlot(const_iterator it) const;
  private:
    // Reg alloc related
    IntSet            liveImmRegs_;
    unsigned          numConflicts_[2];
    Int2IntMap        valConflicts_;
    BitVector         blockSpillCandidate_[2];
    IntSet            tentativeSpill_;
    std::vector<BitVector> valLiveMap_;
    std::vector<std::pair<size_t, size_t> > cycleRegPressure_;
    const BaselineBasicInfo& target_;
  public:
    BaselineBlockData(SIRBasicBlock* bb, const BaselineBasicInfo& t)
      : TargetBlockData(bb), target_(t) {}
    virtual void Reset();
    virtual ~BaselineBlockData();

    virtual void Print(std::ostream& o) const;
    virtual void ValuePrint(std::ostream& o) const;

    void ResetBypass();
    void InitValueInfo();
    void CalculateRegPressure(
      const Int2IntMap& valueRegClassMap, const IntSet& spilledValues,
      const BaselineBasicInfo& target);
    void GetSpillCandidates(
      BitVector& cpSpillCandidates, BitVector& peSpillCandidates,
      const IntSet& nonSpillVals, const Int2IntMap& valueRegClassMap,
      const BaselineBasicInfo& target);
    void InsertNoLater(iterator it, SIRInstruction* instr);
    void InsertBefore(iterator it, SIRInstruction* instr);
    void InsertBeforeWithTimingCheck(iterator it, SIRInstruction* instr);
    void InsertAfter(iterator it, SIRInstruction* instr);
    void InsertNOPBefore(iterator it);
    void InsertImmInstr(const BaselineBasicInfo& target);
    void InsertLiveImmReg(int v)  { liveImmRegs_.insert(v); }

    bool ImmRegAlive(int v) const { return IsElementOf(v, liveImmRegs_); }
    bool IsSpillCandidate(unsigned v, bool vector) const {
      return (v < blockSpillCandidate_[vector].size()) ?
        blockSpillCandidate_[vector][v] : false;
    }
    int   Length()        const { return length_;         }
    float BaseSpillCost() const { return baseSpillCost_;  }
    int   ValConflict(int v) const {
      return IsElementOf(v, valConflicts_) ? GetValue(v, valConflicts_) : 0;
    }
    int   NumConflict(unsigned i) const { return (i<2) ? numConflicts_[i] : 0; }

    size_t RegPressure(unsigned i)    const { return regPressure_[i]; }
    size_t CPRegPressure()    const { return regPressure_[0]; }
    size_t PERegPressure()    const { return regPressure_[1]; }
    const BitVector& CycleLiveValues(unsigned t)   { return valLiveMap_[t];  }
    const BitVector& BlockCPSpillCandidate() const {
      return blockSpillCandidate_[0];
    }
    const BitVector& BlockPESpillCandidate() const {
      return blockSpillCandidate_[1];
    }

    void MergeValConflicTo(Int2IntMap& conflict) const;
  };// BaselineBlockData
}// namespace ES_SIMD

#endif//ES_SIMD_BASELINEBLOCKDATA_HH
