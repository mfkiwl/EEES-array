#include "BaselineBUSelector.hh"
#include "BaselineBasicInfo.hh"
#include "BaselineInstrData.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRFunction.hh"
#include "Target/DDGSubTree.hh"
#include "Target/TargetBlockData.hh"
#include "Utils/DbgUtils.hh"
#include "Utils/LogUtils.hh"
#include "Utils/InlineUtils.hh"

using namespace std;
using namespace ES_SIMD;

namespace {
  bool CmpSubTreeSize(GenericTree<DiGraphNode>::Node* x,
                      GenericTree<DiGraphNode>::Node* y) {
    return x->size() < y->size();
  }
  struct SetNodeTree {
    int tid_;
    int cnt_;
    lemon::ListDigraph::NodeMap<BaselineBypassSelector::NodeTreeInfo>* nTree_;
    void operator()(GenericTree<DiGraphNode>::Node* x) {
      x->sort(CmpSubTreeSize);
      (*nTree_)[**x].tree_     = tid_;
      (*nTree_)[**x].order_    = cnt_++;
      (*nTree_)[**x].priority_ = x->size();
    }
  };// SetNodeTree

  struct SethiUllmanLabel {
    lemon::ListDigraph::NodeMap<BaselineBypassSelector::NodeTreeInfo>* nTree_;
    void operator()(GenericTree<DiGraphNode>::Node* x) {
      ES_ASSERT(nTree_);
      BaselineBypassSelector::NodeTreeInfo& uInfo = (*nTree_)[**x];
      GenericTree<DiGraphNode>::Node* p = x->GetParent();
      if (x->IsLeaf()) {
        if (p && (x == p->back()) && (x != p->front())) {
          // x is the last children with sibling(s)
          uInfo.suLabel_ = 0;
        } else { uInfo.suLabel_ = 1; }
        return;
      }// if (x->IsLeaf())
      int maxR = (*nTree_)[**x->front()].suLabel_;
      bool allEqual = true;
      for (GenericTree<DiGraphNode>::Node::iterator it = x->begin();
           it != x->end(); ++it) {
        int r = (*nTree_)[***it].suLabel_;
        if (maxR != r) {
          allEqual = false;
          maxR = max(maxR, r);
        }// if (maxR != r)
      }
      if (!allEqual) { uInfo.suLabel_ = maxR; }
      else { uInfo.suLabel_ = maxR + x->GetNumChildren()-1; }
    }
  };// struct SethiUllmanLabel

  typedef lemon::ListDigraph::NodeMap<BaselineBypassSelector::NodeTreeInfo> \
  TreeNodeInfoMap;
  struct CmpSethiUllmanLabel {
    TreeNodeInfoMap* nTree_;
    bool operator()(GenericTree<DiGraphNode>::Node*const& a,
                    GenericTree<DiGraphNode>::Node*const& b) {
      return (*nTree_)[**a].suLabel_ < (*nTree_)[**b].suLabel_;
    }
    CmpSethiUllmanLabel() : nTree_(NULL) {}
  };

  int SetNodeSethiUllmanOrder(
    GenericTree<DiGraphNode>::Node* n, int ord,
    TreeNodeInfoMap* nTree, CmpSethiUllmanLabel& nCmp) {
    ES_ASSERT(nTree);
    (*nTree)[**n].order_ = ord;
    ++ord;
    vector<GenericTree<DiGraphNode>::Node*> nChildren;
    nChildren.reserve(n->GetNumChildren());
    for (GenericTree<DiGraphNode>::Node::iterator it = n->begin();
         it != n->end(); ++it) { nChildren.push_back(*it); }
    if (!nChildren.empty()) {
      sort(nChildren.begin(), nChildren.end(), nCmp);
      for (int i=0, e=nChildren.size(); i < e; ++i) {
        ord = SetNodeSethiUllmanOrder(nChildren[i], ord, nTree, nCmp);
      }
    }// if (!nChildren.empty())
    return ord;
  }
  void SetTreeSethiUllmanOrder(GenericTree<DiGraphNode>* tr,
                               TreeNodeInfoMap* nTree) {
    CmpSethiUllmanLabel suCmp;
    suCmp.nTree_ = nTree;
    SetNodeSethiUllmanOrder(tr->Root(), 0, nTree, suCmp);
  }

  /// \brief Update FU usage of each subtree, should use with post-order traverse
  struct  UpdateSubTreeFU {
    const DataDependencyGraph* ddg_;
    const BaselineBasicInfo* target_;
    lemon::ListDigraph::NodeMap<BaselineBypassSelector::NodeTreeInfo>* nTree_;
    void operator()(GenericTree<DiGraphNode>::Node* x) {
      DiGraphNode u = **x;
      if (x->IsLeaf()) { return; }
      BaselineBypassSelector::NodeTreeInfo& uInfo = (*nTree_)[u];
      for (GenericTree<DiGraphNode>::Node::iterator it = x->begin();
           it != x->end(); ++it) {
        DiGraphNode v = ***it;
        BaselineBypassSelector::NodeTreeInfo& vInfo = (*nTree_)[v];
        if (vInfo.binding_ < uInfo.treeFU_.size()) {
          uInfo.treeFU_.set(vInfo.binding_);
        }
        uInfo.treeFU_ |= vInfo.treeFU_;
      }
    }
  };
}// anonymous namespace

BaselineBypassSelector::
BaselineBypassSelector(SIRFunction* func, const TargetBasicInfo& target,
                       bool log, std::ostream& logs)
  : BaselineBUSelector(func, target, log, logs),
    nodeTree_(NULL), nodeBypassState_(NULL), treeInfo_(NULL),
    target_(dynamic_cast<const BaselineBasicInfo*>(&target)) {}

BaselineBypassSelector::~BaselineBypassSelector() {
  delete nodeBypassState_;
  delete nodeTree_;
  delete treeInfo_;
}

void BaselineBypassSelector::
PreCycleUpdate(int t) {
  BaselineBUSelector::PreCycleUpdate(t);
  /// Try to determine what would the bypass state of u be if it is scheduled
  /// in this cycle
  for (DataDependencyGraph::iterator u = ddg_->begin(); u != ddg_->end(); ++u) {
    if ((*ddg_)[u].time_ >= 0) { continue; }
    if (!NodeCommReady(u, t)) { continue; }
    if ((*nodeBypassState_)[u] == InRF) { continue; }
    if ((*nodeBypassState_)[u] == None) { continue; }
    SIRInstruction* uI = (*ddg_)[u].instr_;
    int lu = GetNodeLastUseTime(u);
    int ubid = GetBypassID(u);
    int uiid = uI->IsVectorInstr();
    int nStage = uiid ? target_->GetPENumStages() : target_->GetCPNumStages();
    int wbDelay = nStage - 2;
    (*nodeBypassState_)[u] = InFU;
    int delay = ((nStage == 5) && (ubid == 0)) ? 1 : 0;
    int exitTime = 0;
    for (list<NodePacket>::const_reverse_iterator pIt = nodeSchedList_.rbegin();
         pIt != nodeSchedList_.rend(); ++pIt) {
      DiGraphNode   v   = pIt->nodes_[uiid];
      SIRInstruction* vI = (*ddg_)[u].instr_;
      if ((GetBypassID(v) == ubid) && !IsTargetStore(vI->GetTargetOpcode())) {
        exitTime = pIt->time_ - GetNodeLatency(v) - delay;
        break;
      }
    }// for nodeSchedList_ reverse iteratoor pIt
    if (exitTime <= lu) { continue; }
    (*nodeBypassState_)[u] = InWB;
    int retireTime = 0;
    for (list<NodePacket>::const_reverse_iterator pIt = nodeSchedList_.rbegin();
         pIt != nodeSchedList_.rend(); ++pIt) {
      DiGraphNode   v   = pIt->nodes_[uiid];
      if (!ddg_->Valid(v)){ continue; }
      OpBypassState vSt = (*nodeBypassState_)[v];
      if ((vSt == InWB) || (vSt == InRF)) {
        retireTime = pIt->time_ - wbDelay;
        break;
      }
    }// for nodeSchedList_ reverse_iterator pIt
    if (retireTime > lu) { (*nodeBypassState_)[u] = InRF; }
  }// for ddg_ iterator u
}// BaselineBUSelector::PreCycleUpdate()

/// \brief Partition the DDG to tree structures
///
/// The partition is done before the actual list scheduling, and it is used to
/// assist the selector.
void BaselineBypassSelector::
InitSelector(DataDependencyGraph* ddg) {
  BaselineBUSelector::InitSelector(ddg);
  nodeSchedList_.clear();
  DDGSubTreeDependencyGraph* treeGraph = ddg->GetSubTreeDG();
  static DDGTreePartitionNoCrossDep treePt;
  treeGraph->InitDDGSubTreeDepGraph(&treePt);
  ES_LOG_P(log_, logs_, "-->> "<< ddg_->GetBasicBlock()->GetParent()->GetName()
           <<".B"<< ddg->GetBasicBlock()->GetBasicBlockID() <<" ("<< ddg->size()
           <<") has "<< treeGraph->size() <<" trees (DAG="<<treeGraph->IsDAG()<<")\n");
  delete nodeTree_;
  delete nodeBypassState_;
  delete treeInfo_;
  activeTrees_.clear();
  nodeTree_ = new lemon::ListDigraph::
    NodeMap<BaselineBypassSelector::NodeTreeInfo>(ddg->GetGraph());
  nodeBypassState_ = new lemon::ListDigraph::
    NodeMap<BaselineBypassSelector::OpBypassState>(ddg->GetGraph());
  treeInfo_ = new lemon::ListDigraph::
    NodeMap<BaselineBypassSelector::SubTreeInfo>(treeGraph->GetGraph());
  SIRBasicBlock* bb = ddg->GetBasicBlock();
  for (DataDependencyGraph::iterator u = ddg_->begin(); u != ddg_->end(); ++u) {
    SIRInstruction* uI = (*ddg_)[u].instr_;
    if ((*ddg_)[u].liveOut_) {
      (*nodeBypassState_)[u] = InRF;
    } else if (!bb->GetParent()->IsValidValueID(uI->GetValueID())) {
      (*nodeBypassState_)[u] = None;
    } else { (*nodeBypassState_)[u] = Unknown; }
  }// for ddg_ iterato ru
  SetNodeTree setNodeTree;
  setNodeTree.nTree_ = nodeTree_;
  SethiUllmanLabel treeSULabel;
  treeSULabel.nTree_ = nodeTree_;
  for (int i=0, e=treeGraph->size(); i < e; ++i) {
    GenericTree<DiGraphNode>* tr = treeGraph->GetTree(i);
    setNodeTree.tid_ = i;
    setNodeTree.cnt_ = 0;
    tr->Root()->TraversePreOrder(setNodeTree);
    tr->Root()->TraversePostOrder(treeSULabel);
    SetTreeSethiUllmanOrder(tr, nodeTree_);
  }

  bool change = true;
  // Fix-point algorithm to determine priority
  while (change) {
    change = false;
    for (DataDependencyGraph::iterator u = ddg->begin(); u !=ddg->end(); ++u) {
      BaselineBypassSelector::NodeTreeInfo& uInfo = (*nodeTree_)[u];
      int uPriority = uInfo.priority_;
      int succPrior = 0;//trees_[uInfo.tree_]->Find(u)->size();
      for (DataDependencyGraph::in_edge_iterator e=ddg->in_edge_begin(u);
           e !=ddg->in_edge_end(u); ++e) {
        DiGraphNode v = ddg->GetSource(e);
        GenericTree<DiGraphNode>::Node* vpNode
          = treeGraph->GetDDGNodeTree(v)->Find(v)->GetParent();
        if (vpNode) { succPrior = (*nodeTree_)[**vpNode].priority_; }
        else { succPrior = max(succPrior, (*nodeTree_)[v].priority_+1); }
      }// for u in_edge_iterator e
      if (uPriority < succPrior) { change = true; uInfo.priority_ = succPrior; }
    }// for ddg iterator u
  }// while(change)

  const int totFU = target_->GetNumFU(BaselineBasicInfo::CP)
    + target_->GetNumFU(BaselineBasicInfo::PE);
  const int numFU[2] = {target_->GetNumFU(BaselineBasicInfo::CP),
                     target_->GetNumFU(BaselineBasicInfo::PE)};

  const int fuOffset[2] = {0, target_->GetNumFU(BaselineBasicInfo::CP)};
  for (DataDependencyGraph::iterator u = ddg_->begin(); u != ddg_->end(); ++u) {
    SIRInstruction* uI = (*ddg_)[u].instr_;
    NodeTreeInfo& uInfo = (*nodeTree_)[u];
    uInfo.wbLabel_  = 0;
    uInfo.regLabel_ = 0;
    int binding = target_->GetOperationBinding(uI);
    if ((binding >= 0) && (binding <numFU[uI->IsVectorInstr()])) {
      uInfo.binding_ = binding+fuOffset[uI->IsVectorInstr()];
    } else { uInfo.binding_ = TargetOperationInfo::INVALID_BINDING; }
    uInfo.treeFU_.resize(totFU);
    if ((*ddg_)[u].liveOut_) { uInfo.wbLabel_  = 1; }
  }

  UpdateSubTreeFU updateTreeFU;
  updateTreeFU.nTree_ = nodeTree_;
  for (int i=0, e=treeGraph->size(); i < e; ++i) {
    GenericTree<DiGraphNode>* tr = treeGraph->GetTree(i);
    tr->Root()->TraversePostOrder(updateTreeFU);
  }
  for (DataDependencyGraph::iterator u = ddg_->begin(); u != ddg_->end(); ++u) {
    SIRInstruction* uI = (*ddg_)[u].instr_;
    if (GetTargetOpNumOutput(uI->GetTargetOpcode()) <=0 ) { continue; }
    int ubind = target_->GetOperationBinding(uI);
    int ustage = uI->IsVectorInstr() ? target_->GetPENumStages()
      : target_->GetCPNumStages();
    int uthres = ((ubind == 0) && (ustage == 5)) ? 2 : 1;
    for (DataDependencyGraph::out_edge_iterator e = ddg->out_edge_begin(u);
         e != ddg->out_edge_end(u); ++e) {
      if (!ddg->IsDataEdge(e)) { continue; }
      DiGraphNode v = ddg->GetTarget(e);
      SIRInstruction* vI = (*ddg_)[v].instr_;
      if (IsTargetStore(vI->GetTargetOpcode())) { continue; }
      int vbind = target_->GetOperationBinding(vI);
      if (ubind != vbind) { continue; }
      --uthres;
      if (uthres < 0) { (*nodeTree_)[u].wbLabel_ = 1; break; }
    }
  }// for ddg_ iterato ru
  change = true;
  while(change) {
    change = false;
    for (DataDependencyGraph::iterator u = ddg->begin(); u !=ddg->end(); ++u) {
      if ((*ddg)[u].liveOut_) { continue; }
      BaselineBypassSelector::NodeTreeInfo& uInfo = (*nodeTree_)[u];
      if (uInfo.regLabel_) { continue; }
      SIRInstruction* uI = (*ddg_)[u].instr_;
      if (GetTargetOpNumOutput(uI->GetTargetOpcode()) <=0 ) { continue; }
      int inWB = 0;
      for (DataDependencyGraph::out_edge_iterator e=ddg->out_edge_begin(u);
           e !=ddg->out_edge_end(u); ++e) {
        if (!ddg->IsDataEdge(e)) { continue; }
        const NodeTreeInfo& vInfo = (*nodeTree_)[ddg->GetTarget(e)];
        if (vInfo.wbLabel_) { ++ inWB; }
      }// for u out_edge_iterator e
      int ustage = uI->IsVectorInstr() ? target_->GetPENumStages()
        : target_->GetCPNumStages();
      int wbDelay = ustage - 2;
      if (inWB > wbDelay) {
        uInfo.regLabel_ = 1;
        change = true;
      }
    }// for ddg iterator u
  }// while (change)
}// InitSelector()

void BaselineBypassSelector::
Finalize() {
  DDGSubTreeDependencyGraph* treeGraph = ddg_->GetSubTreeDG();
  treeGraph->UpdateTreeTime();
  if (log_) {
    for (int i=0, e=treeGraph->size(); i < e; ++i) {
      DiGraphNode iTreeNode = treeGraph->GetTreeNode(i);
      GenericTree<DiGraphNode>* tr = treeGraph->GetTree(i);
      DDGSubTree& treeNode = (*treeGraph)[iTreeNode];
      size_t tSize = treeNode.size_;
      logs_<<"-->> Tree "<< i <<", size="<< tSize;
      if ((*ddg_)[**tr->Root()].instr_->GetValueID() >= 0) {
        logs_<<", root_value="<< (*ddg_)[**tr->Root()].instr_->GetValueID();
      }
      logs_<<", time = ["<< treeNode.first_<<", "<< treeNode.last_
           <<"] ("<<(treeNode.last_-treeNode.first_+1)<<"/"<< tSize <<")\n";
    }// for i = 0 to trees_.size()-1
    for (int i=0, e=ddg_->GetSubTreeDG()->size(); i < e; ++i) {
      for (int j=i+1, e=ddg_->GetSubTreeDG()->size(); j < e; ++j) {
        float succSim = ddg_->GetSubTreeDG()->SuccSimilarity(i, j);
        float predSim = ddg_->GetSubTreeDG()->PredSimilarity(i, j);
        if ((succSim > 0.0f) || (predSim > 0.0f)) {
          logs_<<"Similarity("<< i <<", "<< j <<") = succ: "<< succSim
               <<", pred: "<< predSim <<'\n';
        }
      }
    }
    for (int i=0, e=treeGraph->size(); i < e; ++i) {
      GenericTree<DiGraphNode>* tr = treeGraph->GetTree(i);
      logs_<<"-->> Tree "<< i <<"("
           <<(*treeGraph)[treeGraph->GetTreeNode(i)].size_ <<")\n";
      BaselineBypassSelector::BypassDDGTreePrinter prt(
        *ddg_, logs_, nodeSelectData_, nodeTree_);
      tr->Root()->TraversePreOrder(prt);
    }// for (i = 0 to trees_.size-1)
  }
}// Finalize()

ostream& BaselineBypassSelector::
PrintNodeSel(DiGraphNode u, ostream& o) const {
  BaselineBUSelector::PrintNodeSel(u, o);
  const BaselineBypassSelector::NodeTreeInfo& uInfo = (*nodeTree_)[u];
  return o <<" [tree="<< uInfo.tree_<<", order="<< uInfo.order_
           <<", nodePri="<< uInfo.priority_ <<", bypass_state="
           << (*nodeBypassState_)[u] <<"]";
}

static bool NodeCausesJP(int threshold, int t, int succUsedTime) {
  int dt = threshold - t;
  if ((dt > 0) && (succUsedTime >= 0)) { return succUsedTime < dt; }
  return false;
}

DiGraphNode BaselineBypassSelector::
GetBetterNode(DiGraphNode u, DiGraphNode v, int t) const {
  if (u == lemon::INVALID) { return v; }
  if (v == lemon::INVALID) { return u; }
  const NodeSelData& uDat = (*nodeSelectData_)[u];
  const NodeSelData& vDat = (*nodeSelectData_)[v];
  if (log_) {
    logs_<<"            -- Comparing\n               * ";
    PrintNodeSel(u, logs_) <<"\n               * ";
    PrintNodeSel(v, logs_) <<"\n";
  }
  static vector<int> uPriority(5);
  static vector<int> vPriority(5);
  // int uNumVars = uDat.uses_ - uDat.defs_, vNumVars = vDat.uses_ - vDat.defs_;
  bool uCausesJP = NodeCausesJP(jpThreshold_[uDat.vect_],t,uDat.succUsedTime_);
  bool vCausesJP = NodeCausesJP(jpThreshold_[vDat.vect_],t,vDat.succUsedTime_);
  int uTreeOrder = (*nodeTree_)[u].order_, vTreeOrder = (*nodeTree_)[v].order_;
  SIRInstruction* uI = (*ddg_)[u].instr_;
  SIRInstruction* vI = (*ddg_)[v].instr_;
  int uiid = uI->IsVectorInstr(), viid = vI->IsVectorInstr();
  int uKillFlag = (uI->DefinedFlag() > 0)
    &&  (((uiid>0)?peActiveFlag_:cpActiveFlag_) == uI->DefinedFlag());
  int vKillFlag = (vI->DefinedFlag() > 0)
    &&  (((viid>0)?peActiveFlag_:cpActiveFlag_) == vI->DefinedFlag());
  int uBypass = min((*nodeBypassState_)[u], InRF);
  int vBypass = min((*nodeBypassState_)[v], InRF);
  int uTreeActID = GetNodeTreeActID(u), vTreeActID = GetNodeTreeActID(v);
  DDGSubTreeDependencyGraph* treeGraph = ddg_->GetSubTreeDG();
  /// Both nodes are from unscheduled trees, try to determine tree priority
  if ((uTreeActID == treeGraph->size()) && (vTreeActID == treeGraph->size())) {
    DiGraphNode uT = treeGraph->GetDDGNodeTreeNode(u);
    DiGraphNode vT = treeGraph->GetDDGNodeTreeNode(v);
    int uTid = (*treeGraph)[uT].id_;
    int vTid = (*treeGraph)[vT].id_;
    if (treeGraph->HasEdge(uT, vT)) {
      uTreeActID = 1;
      vTreeActID = 0;
    } else if (treeGraph->HasEdge(vT, uT)) {
      uTreeActID = 0;
      vTreeActID = 1;
    } else {
      float uSimilarity = 0.0f, vSimilarity = 0.0f;
      float uSucc = 0.0f, vSucc = 0.0f;
      float baseCost = 1.0f;
      for (int i=activeTrees_.size()-1; i >=0; --i) {
        DiGraphNode aT = treeGraph->GetTreeNode(activeTrees_[i]);
        uSimilarity += baseCost * treeGraph->PredSimilarity(uTid, (*treeGraph)[aT].id_);
        uSimilarity += baseCost * treeGraph->SuccSimilarity(uTid, (*treeGraph)[aT].id_);
        vSimilarity += baseCost * treeGraph->PredSimilarity(vTid, (*treeGraph)[aT].id_);
        vSimilarity += baseCost * treeGraph->SuccSimilarity(vTid, (*treeGraph)[aT].id_);
        if (treeGraph->HasEdge(uT, aT)) { uSucc += baseCost; }
        if (treeGraph->HasEdge(vT, aT)) { vSucc += baseCost; }
        // baseCost *= 2.0f;
      }
      float uTreePrior = uSimilarity + uSucc;
      float vTreePrior = vSimilarity + vSucc;
      // if (uTreePrior > vTreePrior) {
      //   uTreeActID = 0;
      //   vTreeActID = 1;
      // } else if (uTreePrior < vTreePrior) {
      //   uTreeActID = 1;
      //   vTreeActID = 0;
      // }
      if (log_) {
        logs_<<"            -->> uTreePriority["<< uTid <<"]="<< uTreePrior <<"\n";
        logs_<<"            -->> vTreePriority["<< vTid <<"]="<< vTreePrior <<"\n";
      }
    }
  }// if (uTreeActID == treeGraph->size() && (vTreeActID == treeGraph->size())
  uPriority.clear();
  vPriority.clear();
  uPriority.push_back(uCausesJP);      /**/ vPriority.push_back(vCausesJP);
  uPriority.push_back(-uKillFlag);     /**/ vPriority.push_back(-vKillFlag);
  uPriority.push_back(uTreeActID);          vPriority.push_back(vTreeActID);
  uPriority.push_back(uTreeOrder);     /**/ vPriority.push_back(vTreeOrder);
  uPriority.push_back(uBypass);        /**/ vPriority.push_back(vBypass);
  // uPriority.push_back(uNumVars);       /**/ vPriority.push_back(vNumVars);
  uPriority.push_back(uDat.liveOut_);  /**/ vPriority.push_back(vDat.liveOut_);
  uPriority.push_back(uDat.mobility_); /**/ vPriority.push_back(vDat.mobility_);
  uPriority.push_back(uDat.height_);   /**/ vPriority.push_back(vDat.height_);

  DiGraphNode sel = PriorityCompare(uPriority, vPriority)? u : v;
  if (log_) {
    logs_<<"            -->> uPriority="<< uPriority <<"\n";
    logs_<<"            -->> vPriority="<< vPriority <<"\n";
    logs_<<"            -- Winner: [";
    (*ddg_)[sel].instr_->ValuePrint(logs_) <<"]\n";
  }
  return sel;
}// GetBetterNode()

int BaselineBypassSelector::
PostNodeSchedUpdate(DiGraphNode u) {
  int sched = BaselineBUSelector::PostNodeSchedUpdate(u);
  int t = (*ddg_)[u].time_;
  int pt = nodeSchedList_.empty() ? -1 : nodeSchedList_.back().time_;
  while (pt < t) {
    nodeSchedList_.push_back(NodePacket(++pt, 2));
  }// while (pt < t)
  int iid = (*ddg_)[u].instr_->IsVectorInstr();
  nodeSchedList_.back().nodes_[iid] = u;
  // Update tree related information
  DDGSubTreeDependencyGraph* treeGraph = ddg_->GetSubTreeDG();
  DiGraphNode treeNode = treeGraph->GetDDGNodeTreeNode(u);
  int treeID = (*treeGraph)[treeNode].id_;
  if ((*treeInfo_)[treeNode].activeIndex_ < 0) {
    (*treeInfo_)[treeNode].activeIndex_ = activeTrees_.size();
    ES_LOG_P(log_, logs_, "-->> Tree "<< treeID <<" actID="
             << activeTrees_.size()<<'\n');
    activeTrees_.push_back(treeID);
  }
  (*treeGraph)[treeNode].first_ = min((*treeGraph)[treeNode].first_, t);
  (*treeGraph)[treeNode].last_  = max((*treeGraph)[treeNode].last_, t);
  return sched;
}// PostNodeSchedUpdate()


void BaselineBypassSelector::BypassDDGTreePrinter::
operator()(GenericTree<DiGraphNode>::Node* x) const {
  DDGNode& n = ddg_[**x];
  bool local = true;
  GenericTree<DiGraphNode>::Node* root = x->GetRoot();
  for (DataDependencyGraph::out_edge_iterator e = ddg_.out_edge_begin(**x);
       e != ddg_.out_edge_end(**x); ++e) {
    if (ddg_.IsDataEdge(e) && !root->Find(ddg_.GetTarget(e))) { local = false; }
  }
  for (int i = 0, e=x->GetDepth(); i < e; ++i) { out_<<"  "; }
  out_<<"+ ";
  if (n.instr_) {
    if (n.instr_->HasSIROpcode()) {
      out_ << GetString(n.instr_->GetSIROpcode());
    } else if (n.instr_->HasTargetOpcode()) {
      out_ << GetString(n.instr_->GetTargetOpcode());
    } else { out_ <<"Unknown"; }
    if (n.instr_->GetValueID()>=0) {
      out_ <<"<V_"<< n.instr_->GetValueID() <<">";
      if (n.liveOut_) { out_<<"*"; }
      if (!local)     { out_<<"$"; }
    }
  }// if (n.instr_)
  const NodeTreeInfo& xTree = (*nodeTree_)[**x];
  out_<<"(size="<< x->size() <<", ord="<< xTree.order_ <<", prior="
      << xTree.priority_<<", label=[SU"<< xTree.suLabel_<<" W"<< xTree.wbLabel_
      <<" R"<< xTree.regLabel_ <<",FU="<< xTree.binding_
      <<",tFU="<<xTree.treeFU_<<"])\n";
}

int BaselineBypassSelector::
GetBypassID(DiGraphNode u) const {
  if (!ddg_->Valid(u)) { return -1; }
  const SIRInstruction* instr = (*ddg_)[u].instr_;
  return instr->IsVectorInstr() ?
    target_->GetPEOperationBinding(instr->GetTargetOpcode())
    : target_->GetCPOperationBinding(instr->GetTargetOpcode());
}// GetBypassID()

int BaselineBypassSelector::
GetNodeLastUseTime(DiGraphNode u) const {
  int lu = -1;
  for (DataDependencyGraph::out_edge_iterator e = ddg_->out_edge_begin(u);
       e != ddg_->out_edge_end(u); ++e) {
    if (!ddg_->IsDataEdge(e)) { continue; }
    int ut = (*ddg_)[ddg_->GetTarget(e)].time_;
    if ((lu < 0) || (ut < lu)) { lu = ut; }
  }
  return lu;
}// GetNodeLastUseTime()

int BaselineBypassSelector::
GetNodeLatency(DiGraphNode u) const {
  if (!ddg_->Valid(u)) { return -1; }
  return target_->GetOperationLatency((*ddg_)[u].instr_);
}// GetNodeLatency()

int BaselineBypassSelector::
GetNodeTreeActID(DiGraphNode u) const {
  DDGSubTreeDependencyGraph* treeGraph = ddg_->GetSubTreeDG();
  DiGraphNode treeNode = treeGraph->GetDDGNodeTreeNode(u);
  int aid = (*treeInfo_)[treeNode].activeIndex_;
  if (aid < 0) { aid = treeGraph->size(); }
  for (DDGSubTreeDependencyGraph::in_edge_iterator
         e = treeGraph->in_edge_begin(treeNode);
       e != treeGraph->in_edge_end(treeNode); ++e) {
    int sid = (*treeInfo_)[treeGraph->GetSource(e)].activeIndex_;
    if ((sid >=0) && (sid < aid)) { aid = sid; }
  }
  return aid;
}// GetNodeTreeActID()
