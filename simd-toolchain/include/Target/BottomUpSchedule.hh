#ifndef ES_SIMD_BOTTOMUPSCHEDULE_HH
#define ES_SIMD_BOTTOMUPSCHEDULE_HH

#include "SIR/SIRBasicBlock.hh"
#include "Target/DataDependencyGraph.hh"
#include "DataTypes/Object.hh"

namespace ES_SIMD {
  class TargetBasicInfo;
  /// Node selector base class. For bottom-up cycle scheduling
  class BUSelector : NonCopyable {
  protected:
    const TargetBasicInfo& target_;
    DataDependencyGraph* ddg_;
    std::vector<IntSet> timeSlot_;
    bool log_;
    std::ostream& logs_;
    void UpdateSrcNodes(DiGraphNode u);
  public:
    virtual ~BUSelector();
    virtual void InitSelector(DataDependencyGraph* ddg) = 0;
    virtual DiGraphNode GetNextNode(int t) const = 0;
    virtual DiGraphNode GetDelayedBranch() const;
    unsigned GetNumOfBranchDelaySlots() const;

    /// \brief Abstract interface to update status after scheduling a node.
    /// \param n The node selected to be scheduled.
    /// \return The number of nodes thta are actually scheduled.
    virtual int  PostNodeSchedUpdate(DiGraphNode n) = 0;
    virtual void PreCycleUpdate(int t);
    virtual void PostCycleUpdate(int t);
    virtual void Finalize();
  protected:
    BUSelector(const TargetBasicInfo& target, bool log, std::ostream& logs)
      : target_(target), ddg_(NULL), log_(log), logs_(logs) {}
    int NodeReady(DiGraphNode u) const;
  };// class BUSelector

  class BasicSequentialSelector : public BUSelector {
  public:
    BasicSequentialSelector(
      const TargetBasicInfo& target, bool log, std::ostream& logs)
      : BUSelector(target, log, logs) {}
    virtual void InitSelector(DataDependencyGraph* ddg);
    virtual DiGraphNode GetNextNode(int t) const;

    virtual int  PostNodeSchedUpdate(DiGraphNode n);
    virtual void PreCycleUpdate(int t);
    virtual void PostCycleUpdate(int t);
  private:
    std::tr1::unordered_set<int> usedTimeSlot_;
  };// class BasicSequentialSelector

  class IROrderSelector : public BUSelector {
  public:
    IROrderSelector(
      const TargetBasicInfo& target, bool log, std::ostream& logs)
      : BUSelector(target, log, logs) {}
    virtual void InitSelector(DataDependencyGraph* ddg);
    virtual DiGraphNode GetNextNode(int t) const;

    virtual int  PostNodeSchedUpdate(DiGraphNode n);
    virtual void PreCycleUpdate(int t);
    virtual void PostCycleUpdate(int t);
  private:
    std::tr1::unordered_set<int> usedTimeSlot_;
    SIRBasicBlock::reverse_iterator selHead_;
    int minTime_;
  };// class IROrderSelector

  int BottomUpScheduleDAG(DataDependencyGraph& ddg, BUSelector& sel);
}// namespace ES_SIMD

#endif//ES_SIMD_BOTTOMUPSCHEDULE_HH
