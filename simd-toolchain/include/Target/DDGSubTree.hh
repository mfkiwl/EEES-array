#ifndef ES_SIMD_DDGSUBTREE_HH
#define ES_SIMD_DDGSUBTREE_HH

#include "Target/DataDependencyGraph.hh"
#include <limits>

namespace ES_SIMD {
  class SIRBasicBlock;

  struct DDGSubTree {
    int id_;
    GenericTree<DiGraphNode>* tree_;
    size_t size_;
    int first_;
    int last_;
    std::vector<float> predSimilarity_;
    std::vector<float> succSimilarity_;
    bool Shaded() const { return false; }
    DDGSubTree() : id_(-1), tree_(NULL),
                   first_(std::numeric_limits<int>::max()), last_(-1) {}
  };
  struct DDGSubTreeDep {
    enum EdgeType { Data, NonData, EdgeTypeEnd };
    EdgeType type_;
    bool hidden_;
    bool Hide() const { return hidden_; }
    LineStyle GetStyle() const { return (type_==Data) ? LS_Solid : LS_Dashed; }
    DDGSubTreeDep() : type_(EdgeTypeEnd), hidden_(false) {}
  };

  struct DDGTreePartition {
    virtual void Partition(
      DataDependencyGraph& ddg,
      std::vector<GenericTree<DiGraphNode>*>& trees) = 0;
  };

  class DDGSubTreeDependencyGraph : public DiGraph<DDGSubTree, DDGSubTreeDep> {
    std::vector<GenericTree<DiGraphNode>*> trees_;
    std::vector<DiGraphNode> treeNodes_;
    std::map<DiGraphNode, DiGraphNode> ddgNodeToTreeMap_;
    DataDependencyGraph* ddg_;
  public:
    DDGSubTreeDependencyGraph(DataDependencyGraph* ddg) :ddg_(ddg) {}
    ~DDGSubTreeDependencyGraph();
    DiGraphNode GetInstrNode(const SIRInstruction* instr) const;
    GenericTree<DiGraphNode>* GetDDGNodeTree(DiGraphNode u) const;
    GenericTree<DiGraphNode>* GetTree(unsigned i) const { return trees_[i]; }
    DiGraphNode GetTreeNode(unsigned i) const { return treeNodes_[i]; }
    DiGraphNode GetDDGNodeTreeNode(DiGraphNode u) const;
    void InitDDGSubTreeDepGraph(DDGTreePartition* p);
    DataDependencyGraph* GetDDG() const { return ddg_; }
    float SuccSimilarity(unsigned i, unsigned j) const {
      return ((i < treeNodes_.size()) && (j < treeNodes_.size())) ?
        nodeProperty_[treeNodes_[i]].succSimilarity_[j] : 0.0f;
    }
    float PredSimilarity(unsigned i, unsigned j) const {
      return ((i < treeNodes_.size()) && (j < treeNodes_.size())) ?
        nodeProperty_[treeNodes_[i]].predSimilarity_[j] : 0.0f;
    }
    bool IsDataEdge(DiGraphEdge e) const {
      return Valid(e) && edgeProperty_[e].type_ == DDGSubTreeDep::Data;
    }
    void UpdateTreeTime();
    void CalculateEdgeVisibility();
  };//class DDGSubTreeDependencyGraph

  struct DDGTreePartitionNoCrossDep : DDGTreePartition {
    virtual void Partition(
      DataDependencyGraph& ddg,
      std::vector<GenericTree<DiGraphNode>*>& trees);
  };

  /// \brief Partition a DDG to trees such that a non-root tree node has no
  ///        data consumer outside the tree it belongs to.
  void PartitionDDGTreeNoCrossTreeDep(DataDependencyGraph& dag,
                           std::vector<GenericTree<DiGraphNode>*>& trees);

  std::ostream& operator<<(std::ostream& o, const DDGSubTree& n);
  std::ostream& operator<<(std::ostream& o, const DDGSubTreeDep& n);
}// namespace ES_SIMD

#endif//ES_SIMD_DDGSUBTREE_HH
