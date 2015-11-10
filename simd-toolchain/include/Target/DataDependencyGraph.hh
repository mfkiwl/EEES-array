#ifndef ES_SIMD_DATADEPENDENCY_HH
#define ES_SIMD_DATADEPENDENCY_HH

#include "Graph/DiGraph.hh"
#include "DataTypes/ContainerTypes.hh"
#include "DataTypes/GenericTree.hh"

namespace ES_SIMD {
  class SIRInstruction;
  class SIRBasicBlock;
  class DDGSubTreeDependencyGraph;

  struct DDGNode {
    static bool PrintLatency;
    static bool PrintHeight;
    static bool PrintReady;
    static bool PrintTime;
    static bool PrintMobility;
    static void ResetLabel();
    SIRInstruction* instr_;
    int earlist_;
    int latest_;
    int mobility_;
    int height_;
    int latency_;
    int ready_;
    int time_;
    bool liveOut_;
    bool Shaded() const { return false; }
    DDGNode() : instr_(NULL), earlist_(0), latest_(0), mobility_(0),
                height_(0), latency_(1), liveOut_(false) {}
  };
  struct DDGEdge {
    static bool PrintLatency;
    static void ResetLabel();
    enum EdgeType { Data, Anti, Output, MemOrder, Control, EdgeTypeEnd };
    EdgeType type_;
    int latency_;
    bool hidden_;
    bool Hide() const { return hidden_; }
    LineStyle GetStyle() const {
      if (type_ == Data) { return LS_Solid; }
      return LS_Dashed;
    }
    DDGEdge() : type_(EdgeTypeEnd), latency_(0), hidden_(false) {}
  };

  class DataDependencyGraph : public DiGraph<DDGNode, DDGEdge> {
  protected:
    std::tr1::unordered_map<int, DiGraphNode> instrNodes_;
    SIRBasicBlock* bb_;
    DDGSubTreeDependencyGraph* subTreeDG_;
  public:
    DataDependencyGraph();
    ~DataDependencyGraph();
    DiGraphNode GetInstrNode(const SIRInstruction* instr) const;
    void InitialBasicBlockDDG(
      SIRBasicBlock* bb, const std::vector<BitVector>& memAliasTab);
    void SerializeDependentFlags();
    SIRBasicBlock* GetBasicBlock() const { return bb_; }
    DDGSubTreeDependencyGraph* GetSubTreeDG() const { return subTreeDG_; }
    bool IsDataEdge(DiGraphEdge e) const {
      return Valid(e) && edgeProperty_[e].type_ == DDGEdge::Data;
    }
    int ValueEarlistUseTime(int v) const;
    void CalculateEdgeVisibility();
  };//class DataDependencyGraph

  void CalculateDAGNodeHeight(DataDependencyGraph& dag);
  void CalculateDAGNodeMobility(DataDependencyGraph& dag);

  std::ostream& operator<<(std::ostream& o, const DDGNode& n);
  std::ostream& operator<<(std::ostream& o, const DDGEdge& n);
}// namespace ES_SIMD

#endif//ES_SIMD_DATADEPENDENCY_HH
