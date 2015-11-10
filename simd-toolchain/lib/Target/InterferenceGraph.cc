#include "Target/InterferenceGraph.hh"
#include "Utils/DbgUtils.hh"

using namespace std;
using namespace ES_SIMD;

void InterferenceGraph::
AddBlockResources(BlockLiveInterval& blockLiveInterval, int blockLen,
                  const Int2IntMap& resourceClassMap) {
  // First make sure all nodes are added to the graph
  for (BlockLiveInterval::const_iterator it = blockLiveInterval.begin();
       it != blockLiveInterval.end(); ++it) {
    ES_ASSERT_MSG(IsElementOf(it->first, resourceClassMap),
                  "No class assigned to R_"<< it->first);
    AddResourceNode(it->first, GetValue(it->first, resourceClassMap));
  }
  // Add interference edges
  for (BlockLiveInterval::const_iterator it = blockLiveInterval.begin();
       it != blockLiveInterval.end(); ++it) {
    BlockLiveInterval::const_iterator tit = it;
    int uVal = it->first;
    const TargetLiveInterval& uLI = it->second;
    GraphNode u = valueNodeMap_[uVal];
    for (++tit; tit != blockLiveInterval.end(); ++tit) {
      int vVal = tit->first;
      const TargetLiveInterval& tLI = tit->second;
      if (uLI.Overlaps(tLI)) {
        GraphNode v = valueNodeMap_[vVal];
        if (!HasEdge(u, v)) AddEdge(u, v);
      }
    }
  }
}// AddBlockResources()

struct SimplifyStackEntry {
  GraphNode u_;
  bool possibleSpill_;
  SimplifyStackEntry() { u_ = lemon::INVALID; possibleSpill_ = false; }
  SimplifyStackEntry(GraphNode u, bool sp) { u_ = u; possibleSpill_ = sp; }
};// struct SimplifyStackEntry

bool InterferenceGraph::
ColorNodes(Int2IntMap& colorAssignment, IntSet& possibleSpills,
           const tr1::unordered_map<int, const IntVector*>& colors,
           const Int2IntMap& preColoredNodes,
           const vector<IntSet>& reservedColors) {
  bool succ = true;
  const int c = size();
  // const int k = colors.size();
  Int2IntMap numColors;
  for (tr1::unordered_map<int, const IntVector*>::const_iterator it
         = colors.begin(); it != colors.end(); ++it) {
    numColors[it->first] = (it->second) ? it->second->size() : 0;
  }
  colorAssignment.clear();
  for (iterator u = begin(); u != end(); ++u) {
    ES_ASSERT_MSG(nodeProperty_[u].class_ >= 0,
                  "No class assigned to R_"<< nodeProperty_[u].valueID_);
    nodeProperty_[u].color_ = -1;
  }
  // First set pre-colored nodes
  for (Int2IntMap::const_iterator it = preColoredNodes.begin();
       it != preColoredNodes.end(); ++it) {
    SetResourceColor(it->first, it->second);
    colorAssignment[it->first] = it->second;
  }
  int n = c - preColoredNodes.size();
  lemon::ListGraph::NodeMap<bool> simplifyMask(graph_, true);
  lemon::FilterNodes<lemon::ListGraph> curIntGr(graph_, simplifyMask);
  vector<SimplifyStackEntry> sStack;
  sStack.reserve(c);
  while (n > 0) {
    // Simplify graph
    bool simplified = false;
    for (InterferenceGraph::iterator u = begin(); u != end(); ++u) {
      const int k = numColors[nodeProperty_[u].class_];
      if (simplifyMask[u] && (countIncEdges(curIntGr, u) < k)
          && (GetNodeColor(u) < 0)) {
        sStack.push_back(SimplifyStackEntry(u, false));
        simplifyMask[u] = false;
        simplified = true;
        --n;
      }
    }// for iterator u
    if (!simplified) {
      // Choose one with min priority value as spill candidate
      GraphNode sp = end();
      float spw = 0;
      for (iterator u = begin(); u != end(); ++u) {
        const int k = numColors[nodeProperty_[u].class_];
        if (simplifyMask[u] && (countIncEdges(curIntGr, u) >= k)
            && (GetNodeColor(u) < 0)) {
          if ((sp == end()) || (spw > GetNodeWeight(u))) {
            sp  = u;
            spw = GetNodeWeight(u);
          }
        }
      }// for iterator u
      if (sp != end()) {
        sStack.push_back(SimplifyStackEntry(sp, true));
        simplifyMask[sp] = false;
        --n;
      } else { ES_UNREACHABLE("Graph coloring failed!"); }// if (sp != INVALID)
    }//if (!simplified)
  }// while (n > 0)
  // Coloring phase
  IntSet neighbourColors;
  for (int i = sStack.size()-1; i >=0; --i) {
    neighbourColors.clear();
    GraphNode u = sStack[i].u_;
    const IntVector& availColors = *GetValue(nodeProperty_[u].class_, colors);
    for (inc_edge_iterator e = inc_edge_begin(u); e != inc_edge_end(u); ++e) {
      int nc = GetNodeColor(OppositeNode(u, e));
      if (nc >= 0) { neighbourColors.insert(nc); }
    }
    int nodeColor = -1, nodeClass = nodeProperty_[u].class_;
    for (unsigned j = 0; j < availColors.size(); j ++) {
      if (!IsElementOf(availColors[j], reservedColors[nodeClass])
          && !IsElementOf(availColors[j], neighbourColors)) {
        nodeColor = availColors[j];
        break;
      }
    }// for j = 0 to availColors.size()-1
    if (nodeColor >= 0) {
      colorAssignment[nodeProperty_[u].valueID_] = nodeColor;
      nodeProperty_[u].color_ = nodeColor;
    } else {
      possibleSpills.insert(nodeProperty_[u].valueID_);
      for (inc_edge_iterator e = inc_edge_begin(u); e != inc_edge_end(u); ++e) {
        possibleSpills.insert(nodeProperty_[OppositeNode(u, e)].valueID_);
      }
    }// if (nodeColor >= 0)
  }// for i = sStack.size()-1 to 0
  return succ;
}// ColorNodes()
