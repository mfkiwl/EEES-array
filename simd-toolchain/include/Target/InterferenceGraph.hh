#ifndef ES_SIMD_INTERFERENCEGRAPH_HH
#define ES_SIMD_INTERFERENCEGRAPH_HH

#include "Graph/Graph.hh"
#include "DataTypes/ContainerTypes.hh"
#include "Target/TargetLiveInterval.hh"

namespace ES_SIMD {
  class SIRInstruction;
  class SIRBasicBlock;

  struct ResourceNode {
    static bool PrintWeight;
    static void ResetLabel();
    int   valueID_;
    int   class_;
    int   color_;
    float weight_;
    bool Shaded() const { return false; }
    ResourceNode() :valueID_(-1), class_(-1), color_(-1), weight_(0.0f) {}
  };
  struct InterferenceEdge {
    bool Hide() const { return false; }
    LineStyle GetStyle() const {
      return LS_Solid;
    }
  };

  class InterferenceGraph : public Graph<ResourceNode, InterferenceEdge> {
    std::tr1::unordered_map<int, GraphNode> valueNodeMap_;
  public:
    GraphNode AddResourceNode(int v, int rc) {
      std::tr1::unordered_map<int, GraphNode>::iterator it
        = valueNodeMap_.find(v);
      if ((it != valueNodeMap_.end()) && graph_.valid(it->second))
        return valueNodeMap_[v];
      GraphNode u = AddNode();
      ResourceNode& np = nodeProperty_[u];
      np.valueID_ = v;
      np.class_   = rc;
      np.color_   = -1;
      valueNodeMap_[v] = u;
      return u;
    }
    bool HasResource(int v) const {
      std::tr1::unordered_map<int, GraphNode>::const_iterator it
        = valueNodeMap_.find(v);
      return (it != valueNodeMap_.end()) && graph_.valid(it->second);
    }
    int GetResourceColor(int v) const {
      std::tr1::unordered_map<int, GraphNode>::const_iterator it
        = valueNodeMap_.find(v);
      if ((it != valueNodeMap_.end()) && graph_.valid(it->second))
        return nodeProperty_[it->second].color_;
      return -1;
    }
    int GetNodeColor(GraphNode u) const {
      return graph_.valid(u) ? nodeProperty_[u].color_ : -1;
    }
    float GetNodeWeight(GraphNode u) const {
      return graph_.valid(u) ? nodeProperty_[u].weight_ : 0.0f;
    }
    void SetResourceColor(int v, int color) {
      std::tr1::unordered_map<int, GraphNode>::iterator it
        = valueNodeMap_.find(v);
      if ((it != valueNodeMap_.end()) && graph_.valid(it->second))
        nodeProperty_[it->second].color_ = color;
    }

    GraphNode GetResourceNode(int r) {
      std::tr1::unordered_map<int, GraphNode>::iterator it
        = valueNodeMap_.find(r);
      return (it != valueNodeMap_.end()) ? it->second : end();
    }

    void AddBlockResources(BlockLiveInterval& blockLiveInterval, int blockLen,
                           const Int2IntMap& resourceClassMap);
    bool ColorNodes(
      Int2IntMap& colorAssignment, IntSet& possibleSpills,
      const std::tr1::unordered_map<int, const IntVector*>& colors,
      const Int2IntMap& preColoredNodes,
      const std::vector<IntSet>& reservedColors);
  };//class InterferenceGraph

  std::ostream& operator<<(std::ostream& o, const ResourceNode& n);
  std::ostream& operator<<(std::ostream& o, const InterferenceEdge& n);
}// namespace ES_SIMD

#endif//ES_SIMD_INTERFERENCEGRAPH_HH
