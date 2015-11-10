#include "Target/DDGSubTree.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRFunction.hh"
#include "Utils/DbgUtils.hh"

using namespace std;
using namespace ES_SIMD;

namespace {
  struct SetNodeTreeMap {
    DiGraphNode treeNode_;
    map<DiGraphNode, DiGraphNode>* nTreeMap_;
    SetNodeTreeMap() : treeNode_(lemon::INVALID), nTreeMap_(NULL) {}
    void operator()(GenericTree<DiGraphNode>::Node* x) {
      ES_ASSERT(nTreeMap_);
      ES_ASSERT(treeNode_ != lemon::INVALID);
      (*nTreeMap_)[**x] = treeNode_;
    }
  };// SetNodeTreeMap

  struct GetTreeScheduleTime {
    const DataDependencyGraph* ddg_;
    int max_;
    int min_;
    void Reset() {
      ES_ASSERT(ddg_);
      max_ = -1;
      min_ = ddg_->size() * 100;// Some big value so the first node can update
    }
    void operator()(GenericTree<DiGraphNode>::Node* x) {
      ES_ASSERT(ddg_);
      int ut = (*ddg_)[**x].time_;
      max_ = max(ut, max_);
      min_ = min(ut, min_);
    }
  };
}// namespace()

DDGSubTreeDependencyGraph::
~DDGSubTreeDependencyGraph() {
  for (int i=0, e=trees_.size(); i < e; ++i) { delete trees_[i]; }
}

GenericTree<DiGraphNode>* DDGSubTreeDependencyGraph::
GetDDGNodeTree(DiGraphNode u) const {
  DiGraphNode uTreeNode = GetDDGNodeTreeNode(u);
  if (Valid(uTreeNode)) { return nodeProperty_[uTreeNode].tree_; }
  return NULL;
}// GetDDGNodeTree()

DiGraphNode DDGSubTreeDependencyGraph::
GetDDGNodeTreeNode(DiGraphNode u) const {
  if (ddg_->Valid(u) && IsElementOf(u, ddgNodeToTreeMap_)) {
    return GetValue(u, ddgNodeToTreeMap_);
  }
  return end();
}// GetDDGNodeTreeNode()

void DDGSubTreeDependencyGraph::
InitDDGSubTreeDepGraph(DDGTreePartition* p) {
  SetNodeTreeMap nodeMapper;
  p->Partition(*ddg_, trees_);
  clear();
  ddgNodeToTreeMap_.clear();
  treeNodes_.resize(trees_.size());
  for (int i=0, e=trees_.size(); i < e; ++i) {
    DiGraphNode u = AddNode();
    nodeProperty_[u].id_   = i;
    nodeProperty_[u].tree_ = trees_[i];
    nodeProperty_[u].size_ = trees_[i]->TreeSize();
    nodeProperty_[u].predSimilarity_.resize(e, 0.0f);
    nodeProperty_[u].succSimilarity_.resize(e, 0.0f);
    nodeMapper.treeNode_   = u;
    nodeMapper.nTreeMap_   = &ddgNodeToTreeMap_;
    trees_[i]->Root()->TraversePostOrder(nodeMapper);
    treeNodes_[i] = u;
  }// for i = 0 to trees_.size()-1
  for (DataDependencyGraph::iterator u = ddg_->begin(); u != ddg_->end(); ++u) {
    DiGraphNode uTreeNode = GetDDGNodeTreeNode(u);
    GenericTree<DiGraphNode>* uTree = nodeProperty_[uTreeNode].tree_;
    ES_ASSERT(uTree);
    for (DataDependencyGraph::out_edge_iterator e = ddg_->out_edge_begin(u);
         e != ddg_->out_edge_end(u); ++e) {
      DiGraphNode v = ddg_->GetTarget(e);
      DiGraphNode vTreeNode = GetDDGNodeTreeNode(v);
      GenericTree<DiGraphNode>* vTree = nodeProperty_[vTreeNode].tree_;
      ES_ASSERT(vTree);
      if (uTree != vTree) {
        DiGraphEdge te = FindEdge(uTreeNode, vTreeNode);
        if (!Valid(te)) {
          te = AddEdge(uTreeNode, vTreeNode);
          edgeProperty_[te].type_
            = ddg_->IsDataEdge(e)?DDGSubTreeDep::Data:DDGSubTreeDep::NonData;
        } else if (ddg_->IsDataEdge(e)) {
          edgeProperty_[te].type_ = DDGSubTreeDep::Data;
        }
      }// if (uTree != vTree)
    }// for u out_edge_iterator e
  }// for ddg_ iterator u
  BitVector uSucc(size()), uPred(size()), vSucc(size()), vPred(size());
  BitVector totSucc(size()), totPred(size()), comSucc(size()), comPred(size());
  for (int i=0, e=size(); i < e; ++i){
    DiGraphNode u = treeNodes_[i];
    DDGSubTree& uP = nodeProperty_[u];
    uP.succSimilarity_[i] = 1.0f;
    uP.predSimilarity_[i] = 1.0f;
    uSucc.reset();
    uPred.reset();
    const float uOutWeight = 1.0f/static_cast<float>(OutDegree(u));
    for (out_edge_iterator oe = out_edge_begin(u); oe != out_edge_end(u); ++oe){
      DiGraphNode t = GetTarget(oe);
      for (in_edge_iterator ie = in_edge_begin(t); ie != in_edge_end(t); ++ie) {
        DiGraphNode sib = GetSource(ie);
        if (sib == u) { continue; }
        if (HasEdge(u, sib) || HasEdge(sib, u)) { continue; }
        int sID = nodeProperty_[sib].id_;
        uP.succSimilarity_[sID] += uOutWeight;
        nodeProperty_[sib].succSimilarity_[i] += uOutWeight;
      }// for t in_edge_iterator ie
    }// for u out_edge_iterator oe

    for (in_edge_iterator ie = in_edge_begin(u); ie != in_edge_end(u); ++ie){
      DiGraphNode s = GetSource(ie);
      const float sOutWeight = 1.0f/static_cast<float>(OutDegree(s));
      for (out_edge_iterator oe = out_edge_begin(s); oe != in_edge_end(s); ++oe) {
        DiGraphNode sib = GetTarget(oe);
        if (sib == u) { continue; }
        if (HasEdge(u, sib) || HasEdge(sib, u)) { continue; }
        int sID = nodeProperty_[sib].id_;
        uP.predSimilarity_[sID] += sOutWeight;
        nodeProperty_[sib].predSimilarity_[i] += sOutWeight;
      }// for t in_edge_iterator ie
    }// for u out_edge_iterator oe
  }// for iterator u
}// InitDDGSubTreeDepGraph()

void DDGSubTreeDependencyGraph::
UpdateTreeTime() {
  GetTreeScheduleTime schedTime;
  schedTime.ddg_ = ddg_;
  int len = -1;
  for (DataDependencyGraph::iterator u = ddg_->begin();
       u != ddg_->end(); ++u) {
    len = max(len, (*ddg_)[u].time_);
  }
  for (iterator u = begin(); u != end(); ++u) {
    GenericTree<DiGraphNode>* tr = nodeProperty_[u].tree_;
    schedTime.Reset();
    tr->Root()->TraversePreOrder(schedTime);
    nodeProperty_[u].first_ = len-schedTime.max_;
    nodeProperty_[u].last_  = len-schedTime.min_;
  }
}// UpdateTreeTime()

static bool HasUnprocessedCons(DiGraphNode u, DataDependencyGraph& ddg,
                               const set<DiGraphNode>& processed);

static void ProcessChildrenNoDep(
  GenericTree<DiGraphNode>::Node* root, DataDependencyGraph& ddg,
  set<DiGraphNode>& processed, list<GenericTree<DiGraphNode>::Node*>& nodeQ){
  DiGraphNode u = **root;
  GenericTree<DiGraphNode>::Node* topRoot = root->GetRoot();
  for (DataDependencyGraph::in_edge_iterator e = ddg.in_edge_begin(u);
       e != ddg.in_edge_end(u); ++e) {
    DiGraphNode s = ddg.GetSource(e);
    if (IsElementOf(s, processed)) { continue; }
    if (!ddg.IsDataEdge(e))        { continue; }
    bool outDep = false;
    for (DataDependencyGraph::out_edge_iterator ee = ddg.out_edge_begin(s);
         ee != ddg.in_edge_end(u); ++ee) {
      if (!ddg.IsDataEdge(ee)) { continue; }
      DiGraphNode st = ddg.GetTarget(ee);
      if (!topRoot->Find(st)) { outDep = true; break; }
    }
    if (outDep) { continue; }
    SIRInstruction* rI = ddg[s].instr_;
    if (rI->GetParent()->InstrLiveOut(rI)) { continue; }
    GenericTree<DiGraphNode>::Node* c = root->AddChild(s);
    processed.insert(s);
    nodeQ.push_back(c);
    // if (!HasUnprocessedCons(s, ddg, processed)) { nodeQ.push_back(s); }
  }// for ddg in_edge_iterator e
}// ProcessChildren()

void DDGTreePartitionNoCrossDep::
Partition(DataDependencyGraph& ddg,
          vector<GenericTree<DiGraphNode>*>& trees) {
  for (int i=0, e=trees.size(); i < e; ++i) { delete trees[i]; }
  trees.clear();
  list<DiGraphNode> roots;
  // Get all sink nodes
  for (DataDependencyGraph::iterator u = ddg.begin(); u != ddg.end(); ++u) {
    if (ddg.OutDegree(u) == 0) { roots.push_back(u); }
  }
  set<DiGraphNode> processedNodes;
  size_t n = ddg.size();
  list<GenericTree<DiGraphNode>::Node*> nodeQueue;
  while (processedNodes.size() < n) {
    if (!roots.empty()) {
      DiGraphNode r = roots.front();
      roots.pop_front();
      GenericTree<DiGraphNode>* tree = new GenericTree<DiGraphNode>(r);
      trees.push_back(tree);
      processedNodes.insert(r);
      nodeQueue.push_back(tree->Root());
      do {
        ProcessChildrenNoDep(nodeQueue.front(), ddg, processedNodes, nodeQueue);
        nodeQueue.pop_front();
      } while(!nodeQueue.empty());
    }// if (!roots.empty())
    for (DataDependencyGraph::iterator u = ddg.begin(); u != ddg.end(); ++u) {
      if (!IsElementOf(u, processedNodes)
          && !HasUnprocessedCons(u, ddg, processedNodes))  {
        if (find(roots.begin(), roots.end(), u) == roots.end()) { 
          roots.push_back(u);
        }
      }
    }
  }// while (processedNodes.size() < n)
}// DDGTreePartitionNoCrossDep::Partition()

void ES_SIMD::
PartitionDDGTreeNoCrossTreeDep(DataDependencyGraph& ddg,
                               std::vector<GenericTree<DiGraphNode>*>& trees) {
  for (int i=0, e=trees.size(); i < e; ++i) { delete trees[i]; }
  trees.clear();
  list<DiGraphNode> roots;
  // Get all sink nodes
  for (DataDependencyGraph::iterator u = ddg.begin(); u != ddg.end(); ++u) {
    if (ddg.OutDegree(u) == 0) { roots.push_back(u); }
  }
  set<DiGraphNode> processedNodes;
  size_t n = ddg.size();
  list<GenericTree<DiGraphNode>::Node*> nodeQueue;
  while (processedNodes.size() < n) {
    if (!roots.empty()) {
      DiGraphNode r = roots.front();
      roots.pop_front();
      GenericTree<DiGraphNode>* tree = new GenericTree<DiGraphNode>(r);
      trees.push_back(tree);
      processedNodes.insert(r);
      nodeQueue.push_back(tree->Root());
      do {
        ProcessChildrenNoDep(nodeQueue.front(), ddg, processedNodes, nodeQueue);
        nodeQueue.pop_front();
      } while(!nodeQueue.empty());
    }// if (!roots.empty())
    for (DataDependencyGraph::iterator u = ddg.begin(); u != ddg.end(); ++u) {
      if (!IsElementOf(u, processedNodes)
          && !HasUnprocessedCons(u, ddg, processedNodes))  {
        if (find(roots.begin(), roots.end(), u) == roots.end()) { 
          roots.push_back(u);
        }
      }
    }
  }// while (processedNodes.size() < n)
}// PartitionDDGTreeNoCrossTreeDep()

static bool HasUnprocessedCons(DiGraphNode u, DataDependencyGraph& ddg,
                               const set<DiGraphNode>& processed) {
  for (DataDependencyGraph::out_edge_iterator e = ddg.out_edge_begin(u);
       e != ddg.out_edge_end(u); ++e) {
    if (ddg.IsDataEdge(e) && !IsElementOf(ddg.GetTarget(e), processed)) {
      return true;
    }
  }
  return false;
}// HasUnprocessedCons()

std::ostream& ES_SIMD::
operator<<(std::ostream& o, const DDGSubTree& n) {
  return o <<"Tree "<< n.id_<<"("<< n.size_
           <<")\\ntime=["<< n.first_<<", "<< n.last_<<"] ("
           <<(n.last_-n.first_+1)<<")";
}

std::ostream& ES_SIMD::
operator<<(std::ostream& o, const DDGSubTreeDep& n) {
  return o;
}

void DDGSubTreeDependencyGraph::
CalculateEdgeVisibility() {
  for (edge_iterator e = edge_begin(); e != edge_end(); ++e) {
    if (edgeProperty_[e].type_ == DDGSubTreeDep::Data) {
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
