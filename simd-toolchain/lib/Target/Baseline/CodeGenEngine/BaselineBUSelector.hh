#ifndef ES_SIMD_BASELINEBUSELECTOR_HH
#define ES_SIMD_BASELINEBUSELECTOR_HH

#include "Target/BottomUpSchedule.hh"
#include "DataTypes/ContainerTypes.hh"
#include "DataTypes/Object.hh"

namespace ES_SIMD {
  class BaselineBasicInfo;
  class SIRFunction;
  class DDGSubTreeDependencyGraph;

  class BaselineBUSelector : public BUSelector {
  public:
    struct NodeSelData {
      int  uses_;
      int  defs_;
      int  height_;
      int  mobility_;
      int  maxInLatency_;
      int  succUsedTime_;
      bool liveOut_;
      bool vect_;
      NodeSelData() : uses_(0), defs_(0), height_(0), mobility_(0),
                      succUsedTime_(-1), liveOut_(false), vect_(false) {}
    };
    BaselineBUSelector(SIRFunction* func, const TargetBasicInfo& target,
                       bool log, std::ostream& logs);
    virtual ~BaselineBUSelector();
    virtual void InitSelector(DataDependencyGraph* ddg);
    virtual DiGraphNode GetNextNode(int t) const;

    virtual int  PostNodeSchedUpdate(DiGraphNode n);
    virtual void PreCycleUpdate(int t);
    virtual void PostCycleUpdate(int t);
  protected:
    int cpActiveFlag_;
    int peActiveFlag_;
    BitVector liveVars_;
    SIRFunction* func_;
    int jpThreshold_[2];
    lemon::ListDigraph::NodeMap<NodeSelData>* nodeSelectData_;

    /// \breif Check if scheduling u at t will enable v.
    bool NodeEnables(DiGraphNode u, DiGraphNode v, int t) const;
    bool NodeCommReady(DiGraphNode u, int t) const;
    virtual DiGraphNode GetBetterNode(DiGraphNode u, DiGraphNode v, int t) const;
    virtual std::ostream& PrintNodeSel(DiGraphNode u, std::ostream& o) const;
  };// class BaselineBUSelector

  class BaselineBypassSelector : public BaselineBUSelector {
  public:
    struct NodeTreeInfo {
      int tree_;
      int order_;
      int priority_;
      // For labeling
      int suLabel_; ///< Sethi-Ullman label
      int wbLabel_; ///< Does a node requires WB as input
      int regLabel_;///< Register requires
      unsigned binding_;
      BitVector treeFU_;
    };
    struct SubTreeInfo {
      int activeIndex_; ///< The dynamic priority of a tree
      SubTreeInfo() : activeIndex_(-1) {}
    };// struct SubTreeInfo
    struct BypassDDGTreePrinter {
      DataDependencyGraph& ddg_;
      std::ostream& out_;
      lemon::ListDigraph::NodeMap<NodeSelData>* nodeSelectData_;
      lemon::ListDigraph::NodeMap<NodeTreeInfo>* nodeTree_;
      BypassDDGTreePrinter(DataDependencyGraph& ddg, std::ostream& o,
                           lemon::ListDigraph::NodeMap<NodeSelData>* nSelData,
                           lemon::ListDigraph::NodeMap<NodeTreeInfo>* nodeTree)
        : ddg_(ddg), out_(o), nodeSelectData_(nSelData), nodeTree_(nodeTree) {}
      void operator()(GenericTree<DiGraphNode>::Node*) const;
    };// BypassDDGTreePrinter
    struct NodePacket {
      int time_;
      std::vector<DiGraphNode> nodes_;
      NodePacket(int t, int sz) : time_(t), nodes_(sz, lemon::INVALID) {}
    };
    enum OpBypassState {InWB, InFU, InRF, None, Unknown};
  protected:
    lemon::ListDigraph::NodeMap<NodeTreeInfo>*  nodeTree_;
    lemon::ListDigraph::NodeMap<OpBypassState>* nodeBypassState_;
    lemon::ListDigraph::NodeMap<SubTreeInfo>*   treeInfo_;
    std::list<NodePacket> nodeSchedList_;
    std::vector<int> activeTrees_;
    const BaselineBasicInfo* target_;
  public:
    BaselineBypassSelector(SIRFunction* func, const TargetBasicInfo& target,
                           bool log, std::ostream& logs);
    virtual ~BaselineBypassSelector();

    virtual void InitSelector(DataDependencyGraph* ddg);
    virtual void PreCycleUpdate(int t);
    virtual int PostNodeSchedUpdate(DiGraphNode u);
    virtual void Finalize();
  protected:
    virtual DiGraphNode GetBetterNode(DiGraphNode u, DiGraphNode v, int t) const;
    virtual std::ostream& PrintNodeSel(DiGraphNode u, std::ostream& o) const;
    int GetBypassID(DiGraphNode u) const;
    int GetNodeLastUseTime(DiGraphNode u) const;
    int GetNodeLatency(DiGraphNode u) const;
    int GetNodeTreeActID(DiGraphNode u) const;
   };
}// namespace ES_SIMD

#endif//ES_SIMD_BASELINEBUSELECTOR_HH
