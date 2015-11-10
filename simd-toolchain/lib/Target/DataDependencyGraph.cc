#include "Target/DataDependencyGraph.hh"
#include "Target/DDGSubTree.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRFunction.hh"
#include "llvm/Support/Casting.h"
#include "Utils/DbgUtils.hh"
#include <tr1/unordered_map>
#include <sstream>

using namespace std;
using namespace ES_SIMD;

bool DDGNode::PrintLatency  = false;
bool DDGNode::PrintHeight   = false;
bool DDGNode::PrintReady    = false;
bool DDGNode::PrintTime     = false;
bool DDGNode::PrintMobility = false;

void DDGNode::ResetLabel() {
  PrintLatency  = PrintHeight = PrintTime = PrintReady = PrintMobility = false;
}

bool DDGEdge::PrintLatency = false;

void DDGEdge::ResetLabel() {
  PrintLatency  = false;
}

struct SIRInstrHash : public unary_function<SIRInstruction*, size_t> {
  size_t operator() (const SIRInstruction* f) const {
    static tr1::hash<unsigned> h;
    return h(f->GetUID());
  }
};
struct SIRInstrEqual
  : public binary_function<SIRInstruction*,SIRInstruction*,bool> {
  
  bool operator() (const SIRInstruction* a, const SIRInstruction* b) const {
    return a->GetUID() == b->GetUID();
  }
};

DataDependencyGraph::
DataDependencyGraph()
 :bb_(NULL), subTreeDG_(new DDGSubTreeDependencyGraph(this)) {}

DataDependencyGraph::
~DataDependencyGraph() { delete subTreeDG_; }

DiGraphNode DataDependencyGraph::
GetInstrNode(const SIRInstruction* instr) const {
  if (instr && (instr->GetParent() == bb_)) {
    tr1::unordered_map<int, DiGraphNode>::const_iterator it
      = instrNodes_.find(instr->GetUID());
    return (it == instrNodes_.end()) ? end() : it->second;
  }
  return end();
}// GetInstrNode

int DataDependencyGraph::
ValueEarlistUseTime(int v) const {
  int ut = -1;
  for (iterator u = begin(); u != end(); ++u) {
    SIRInstruction* instr = nodeProperty_[u].instr_;
    if (instr->UsesValue(v)) {
      int it = nodeProperty_[u].earlist_;
      if ((ut < 0) || (ut < it)) { ut = it; }
    }
  }
  return ut;
}// ValueEarlistUseTime()

/// @brief Initialize dependency graph of a basic block.
///
/// The following Dependency edges are added:
///   1. Data dependency
///   2. Output dependency
///   3. Anti dependency
/// Note:
///   * Control dependency is ignore since there is only one basic block
///   * False dependency introduced by def and use of flag is not added to DDG.
///     Scheduler need to handle that as a special case
///   * We rely on the front-end to provide memory alias information and assume
///     that non-alias memory references do not depend on each other
void DataDependencyGraph::
InitialBasicBlockDDG(SIRBasicBlock* bb,
                     const std::vector<BitVector>& memAliasTab) {
  bb_ = bb;
  clear();
  reserve(bb->size());
  tr1::unordered_map<SIRInstruction*, DiGraphNode,
    SIRInstrHash, SIRInstrEqual> instrNodeMap;
  for (SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end(); ++iIt) {
    DiGraphNode u = AddNode();
    nodeProperty_[u].instr_ = *iIt;
    instrNodeMap[*iIt] = u;
    instrNodes_[(*iIt)->GetUID()] = u;
    // Set live-out flag
    if (bb->IsValueLiveOut((*iIt)->GetValueID())) {
      bool lo = true;
      SIRBasicBlock::iterator iiIt = iIt;
      int v = (*iIt)->GetValueID();
      for (++iiIt; iiIt != bb->end(); ++iiIt) {
        if ((*iiIt)->GetValueID() == v) { lo = false; break; }
      }
      nodeProperty_[u].liveOut_ = lo;
    }// if (bb->IsValueLiveOut(instr_->GetValueID()))
  }// for bb iterator iIt
  // Add data dependency edges
  for (SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end(); ++iIt) {
    SIRInstruction* instr = *iIt;
    DiGraphNode t = instrNodeMap[instr];
    ES_ASSERT_MSG(Valid(t), "instruction node not properly initialized");
    for (SIRValue::use_iterator uIt = instr->use_begin();
         uIt != instr->use_end(); ++uIt) {
      if (!llvm::isa<SIRInstruction>(*uIt)) { continue; }
      SIRInstruction* uInstr = llvm::cast<SIRInstruction>(*uIt);
      if (uInstr->GetParent()->GetUID() != bb->GetUID()) { continue; }
      DiGraphNode s = instrNodeMap[uInstr];
      ES_ASSERT_MSG(Valid(s), "instruction node not properly initialized");
      DiGraphEdge e = FindEdge(t, s);
      if (!Valid(e)) { e = AddEdge(t, s); }
      edgeProperty_[e].type_ = DDGEdge::Data;
    }// for instr use_iterator uIt
  }// for bb iterator iIt
  // Add output dependency edges
  for (SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end(); ++iIt) {
    SIRInstruction* instr = *iIt;
    DiGraphNode s = instrNodeMap[instr];
    ES_ASSERT_MSG(Valid(s), "instruction node not properly initialized");
    int sid = instr->GetValueID();
    if (sid >= 0) {
      SIRBasicBlock::iterator uIt = iIt;
      for (++uIt; uIt != bb->end(); ++uIt) {
        SIRInstruction* uInstr = *uIt;
        if (sid == uInstr->GetValueID()) {
          DiGraphNode t = instrNodeMap[uInstr];
          ES_ASSERT_MSG(Valid(t), "instruction node not properly initialized");
          if (!HasEdge(s, t)) {
            edgeProperty_[AddEdge(s, t)].type_ = DDGEdge::Output;
          }
          break;
        }// if (sid == uInstr->GetValueID())
      }
    }// if (sid >= 0)
  }// for bb iterator iIt

  // Add anti dependency edges
  for (SIRBasicBlock::reverse_iterator iIt = bb->rbegin();
       iIt != bb->rend(); ++iIt) {
    SIRInstruction* instr = *iIt;
    DiGraphNode t = instrNodeMap[instr];
    ES_ASSERT_MSG(Valid(t), "instruction node not properly initialized");
    int sid = instr->GetValueID();
    if (sid >= 0) {
      SIRBasicBlock::reverse_iterator uIt = iIt;
      for (++uIt; uIt != bb->rend(); ++uIt) {
        SIRInstruction* uInstr = *uIt;
        if (uInstr->UsesValue(instr)) {
          DiGraphNode s = instrNodeMap[uInstr];
          ES_ASSERT_MSG(Valid(s), "instruction node not properly initialized");
          if (!HasEdge(s, t)) {
            edgeProperty_[AddEdge(s, t)].type_ = DDGEdge::Anti;
          }
        }// if (uInstr->UsesValue(instr))
        if (sid == uInstr->GetValueID()) { break; }
      }
    }// if (sid >= 0)
  }// for bb iterator iIt
  // Handle memory dependency
  for (SIRBasicBlock::iterator iIt = bb->begin();iIt != bb->end(); ++iIt) {
    SIRInstruction* instr = *iIt;
    DiGraphNode s = instrNodeMap[instr];
    if (instr->GetMemoryLocationID() == 0) { continue; }
    if (instr->GetMemoryLocationID() > memAliasTab.size()) { continue; }
    const BitVector& aliasSet = memAliasTab[instr->GetMemoryLocationID()];
    if (aliasSet.empty() || aliasSet.none()) { continue; }
    SIRBasicBlock::iterator iiIt = iIt;
    if (IsTargetStore(instr->GetTargetOpcode())) {
      for (++iiIt; iiIt != bb->end(); ++iiIt) {
        SIRInstruction* dInstr = *iiIt;
        unsigned did = dInstr->GetMemoryLocationID();
        if (!aliasSet[did])
          continue;
        DiGraphNode t = instrNodeMap[dInstr];
        edgeProperty_[AddEdge(s, t)].type_ = DDGEdge::MemOrder;
      }
    } else {// if (IsTargetStore(instr->GetTargetOpcode()))
      bool hasAliasStore = false;
      for (++iiIt; iiIt != bb->end(); ++iiIt) {
        SIRInstruction* dInstr = *iiIt;
        unsigned did = dInstr->GetMemoryLocationID();
        if (did<= 0)
          continue;
        if (!aliasSet[did])
          continue;
        if (hasAliasStore || IsTargetStore(dInstr->GetTargetOpcode())) {
          hasAliasStore = true;
          DiGraphNode t = instrNodeMap[dInstr];
          edgeProperty_[AddEdge(s, t)].type_ = DDGEdge::MemOrder;
        }
      }
    }// if (IsTargetStore(instr->GetTargetOpcode()))
  }// for bb iterator iIt
}// InitialBasicBlockDDG()

static void
AddFlagGroupEdges(const set<DiGraphNode>& sGroup, const set<DiGraphNode>& tGroup,
                  DataDependencyGraph& ddg) {
  for (set<DiGraphNode>::const_iterator sIt = sGroup.begin();
       sIt != sGroup.end(); ++sIt) {
    if (ddg[*sIt].instr_->UsedFlag() < 0) { continue; }
    for (set<DiGraphNode>::const_iterator tIt = tGroup.begin();
         tIt != tGroup.end(); ++tIt) {
      if (ddg[*tIt].instr_->DefinedFlag() < 0) { continue; }
      if (!ddg.HasEdge(*sIt, *tIt)) {
        ddg[ddg.AddEdge(*sIt, *tIt)].type_ = DDGEdge::Anti;
      }
    }
  }
}// AddFlagGroupEdges()

void DataDependencyGraph::
SerializeDependentFlags() {
  typedef set<DiGraphNode> FlagGroup;
  tr1::unordered_map<int, FlagGroup> flagGroups;
  set<DiGraphNode> flagNodes;
  DataDependencyGraph::NodeIntMap nodeFlag(GetGraph(), -1);
  tr1::unordered_map<int, IntSet> flagEdges;
  for (DataDependencyGraph::iterator u = begin(); u != end(); ++u) {
    int df = nodeProperty_[u].instr_->DefinedFlag();
    if (df>=0) {
      flagGroups[df].insert(u);
      flagNodes.insert(u);
      nodeFlag[u] = df;
    }
    int uf = nodeProperty_[u].instr_->UsedFlag();
    if (uf>=0) {
      flagGroups[uf].insert(u);
      flagNodes.insert(u);
      nodeFlag[u] = uf;
    }
  }
  for (DataDependencyGraph::edge_iterator e=edge_begin();e != edge_end(); ++e) {
    DiGraphNode s = GetSource(e), t = GetTarget(e);
    if (!IsElementOf(s, flagNodes) || !IsElementOf(t, flagNodes)) { continue; }
    if (nodeFlag[s] == nodeFlag[t]) { continue; }
    flagEdges[nodeFlag[s]].insert(nodeFlag[t]);
  }
  for (tr1::unordered_map<int, IntSet>::iterator it = flagEdges.begin();
       it != flagEdges.end(); ++it) {
    const FlagGroup& sGroup = flagGroups[it->first];
    const IntSet& tGroups = it->second;
    for (IntSet::const_iterator tIt = tGroups.begin();
         tIt != tGroups.end(); ++tIt) {
      const FlagGroup& tGroup = flagGroups[*tIt];
      AddFlagGroupEdges(sGroup, tGroup, *this);
    }
  }
}// SerializeDependentFlags()

void ES_SIMD::
CalculateDAGNodeMobility(DataDependencyGraph& dag) {
  DataDependencyGraph::NodeIntMap earlist(dag.GetGraph(), 0);
  bool change = true;
  // Calculate
  int late = 0;
  while (change) {
    change = false;
    for (DataDependencyGraph::iterator u = dag.begin(); u != dag.end(); ++u) {
      int ue = earlist[u];
      for (DataDependencyGraph::out_edge_iterator e = dag.out_edge_begin(u);
           e != dag.out_edge_end(u); ++e) {
        DiGraphNode v = dag.GetTarget(e);
        int ve = earlist[v];
        int l  = ue + dag[e].latency_;
        if (ve < l) {
          earlist[v] = l;
          change = true;
          late = max(late, l);
        }
      }
    }// for dag iterator u
  }// while(change)
  DataDependencyGraph::NodeIntMap latest(dag.GetGraph(), late);
  // Calculate latest start time
  change = true;
  while (change) {
    change = false;
    for (DataDependencyGraph::iterator v = dag.begin(); v != dag.end(); ++v) {
      int vl = latest[v];
      for (DataDependencyGraph::in_edge_iterator e = dag.in_edge_begin(v);
           e != dag.in_edge_end(v); ++e) {
        DiGraphNode u = dag.GetSource(e);
        int ul = latest[u];
        int l  = vl - dag[e].latency_;
        if (ul > l) {
          latest[u] = l;
          change = true;
        }
      }
    }// for dag iterator u
  }// while(change)
  for (DataDependencyGraph::iterator u = dag.begin(); u != dag.end(); ++u) {
    dag[u].earlist_  = earlist[u];
    dag[u].latest_   = latest[u];
    dag[u].mobility_ = latest[u] - earlist[u];
  }
}// CalculateDAGNodeMobility()

void ES_SIMD::
CalculateDAGNodeHeight(DataDependencyGraph& dag) {
  DataDependencyGraph::NodeIntMap height(dag.GetGraph(), 0);
  bool change = true;
  while (change) {
    change = false;
    for (DataDependencyGraph::iterator v = dag.begin(); v != dag.end(); ++v) {
      int vh = height[v];
      for (DataDependencyGraph::in_edge_iterator e = dag.in_edge_begin(v);
           e != dag.in_edge_end(v); ++e) {
        int h = vh + max(dag[e].latency_, 1);
        DiGraphNode u = dag.GetSource(e);
        int uh = height[u];
        if (uh < h) {
          change = true;
          height[u] = h;
        }
      }
    }// for dag iterator u
  }// while(change)
  for (DataDependencyGraph::iterator u = dag.begin(); u != dag.end(); ++u) {
    dag[u].height_ = height[u];
  }
}// CalculateDAGNodeHeight()

ostream& ES_SIMD::
operator<<(ostream& o, const DDGNode& n) {
  if (n.instr_) {
    if (n.instr_->HasSIROpcode()) { o << GetString(n.instr_->GetSIROpcode()); }
    else if (n.instr_->HasTargetOpcode()) {
      o << GetString(n.instr_->GetTargetOpcode());
    } else { return o <<"Unknown"; }
    if (n.instr_->GetValueID()>=0) { o <<"<V_"<< n.instr_->GetValueID() <<">"; }
  }// if (n.instr_)
  if (DDGNode::PrintLatency || DDGNode::PrintHeight || DDGNode::PrintReady
      || DDGNode::PrintTime || DDGNode::PrintMobility) {
    o <<"(";
    if (DDGNode::PrintLatency) o <<" L="<< n.latency_;
    if (DDGNode::PrintHeight) o <<" H="<< n.height_;
    if (DDGNode::PrintReady) o <<" R="<< n.ready_;
    if (DDGNode::PrintTime) o <<" T="<< n.time_;
    if (DDGNode::PrintMobility) o <<" M=["<< n.earlist_<<","<< n.latest_ <<"]";
    o <<" )";
  }
  return o;
}// operator<<(ostream& o, const DDGNode& n)

ostream& ES_SIMD::
operator<<(ostream& o, const DDGEdge& n) {
  if (DDGEdge::PrintLatency) { o <<"L="<< n.latency_; }
  return o;
}// operator<<(ostream& o, const DDGEdge& n)

void DataDependencyGraph::
CalculateEdgeVisibility() {
  for (edge_iterator e = edge_begin(); e != edge_end(); ++e) {
    if (edgeProperty_[e].type_ == DDGEdge::Data) {
      edgeProperty_[e].hidden_ = false;
      continue;
    }
    if (edgeProperty_[e].hidden_) { continue; }
    DiGraphNode s = GetSource(e), t = GetTarget(e);
    for (out_edge_iterator oe=out_edge_begin(s); oe != out_edge_end(s); ++oe) {
      DiGraphNode et = GetTarget(oe);
      if ((et != t) && Reachable(et, t)) {
        edgeProperty_[e].hidden_ = true;
        break;
      }
    }
  }// for edge_iterator e
}// CalculateEdgeVisibility()
