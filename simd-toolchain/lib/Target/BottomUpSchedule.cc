#include "Target/BottomUpSchedule.hh"
#include "Target/DataDependencyGraph.hh"
#include "Target/TargetBasicInfo.hh"
#include "SIR/SIRInstruction.hh"
#include "Utils/StringUtils.hh"

using namespace std;
using namespace ES_SIMD;

int ES_SIMD::
BottomUpScheduleDAG(DataDependencyGraph& ddg, BUSelector& sel) {
  int t = 0, dlen = 0, sched = 0, total = ddg.size();
  for (DataDependencyGraph::iterator u = ddg.begin(); u != ddg.end(); ++u) {
    ddg[u].time_  = -1;
    ddg[u].ready_ = (ddg.OutDegree(u) == 0) ? 0 : -1;
  }
  sel.InitSelector(&ddg);
  // If there is branch delay slot, handle it first. There should be only one
  // branch node. It is scheduled in the d-th slot, where d is the number of
  // branch delay slots
  DiGraphNode brNode = ddg.end();
  if ((brNode = sel.GetDelayedBranch()) != ddg.end()) {
    unsigned d = sel.GetNumOfBranchDelaySlots();
    ddg[brNode].time_ = d;
    sel.PostNodeSchedUpdate(brNode);
    dlen = d + 1;
    ++sched;
  }// if ((brNode = sel.GetDelayedBranch()) != ddg.end())
  while (sched < total) {
    sel.PreCycleUpdate(t);
    DiGraphNode nxtNode = ddg.end();
    while ((nxtNode = sel.GetNextNode(t)) != ddg.end()) {
      ddg[nxtNode].time_ = t;
      // cout << "Scheduling "<< ddg[nxtNode] <<" in "<< t <<"\n";
      sched += sel.PostNodeSchedUpdate(nxtNode);
    }// while (nxtNode = sel.GetNextNode() != ddg.end())
    sel.PostCycleUpdate(t);
    ++t;
  }// while (sched < total)
  sel.Finalize();
  return max(dlen, t);
}// BottomUpScheduleDAG()

BUSelector::~BUSelector() {}
void BUSelector::Finalize() {}
unsigned BUSelector::
GetNumOfBranchDelaySlots() const { return target_.GetNumOfBranchDelaySlots(); }

void BUSelector::
UpdateSrcNodes(DiGraphNode u) {
  for (DataDependencyGraph::in_edge_iterator e = ddg_->in_edge_begin(u);
       e != ddg_->in_edge_end(u); ++e) {
    DiGraphNode s = ddg_->GetSource(e);
    (*ddg_)[s].ready_ = NodeReady(s);
    if(log_ && ((*ddg_)[s].ready_ >= 0)) {
      logs_<<"            -- Enables [";
      (*ddg_)[s].instr_->ValuePrint(logs_)<<"]\n";
    }
  }
}// UpdateSrcNodes()

DiGraphNode BUSelector::
GetDelayedBranch() const {
  if (!ddg_ || target_.GetNumOfBranchDelaySlots() <= 0)
    return lemon::INVALID;
  for (DataDependencyGraph::iterator it = ddg_->begin();
       it != ddg_->end(); ++it) {
    if (IsTargetBranch((*ddg_)[it].instr_->GetTargetOpcode())) {
      return it;
    }// if (IsTargetBranch((*ddg_)[*it].instr_->GetTargetOpcode()))
  }// for ddg_ iterator it
  return ddg_->end();
}//GetDelayedBranch()

void BUSelector::PreCycleUpdate(int t)  {}
void BUSelector::PostCycleUpdate(int t) {}

int BUSelector::NodeReady(DiGraphNode u) const {
  int t = 0;
  for (DataDependencyGraph::out_edge_iterator e = ddg_->out_edge_begin(u);
       e != ddg_->out_edge_end(u); ++e) {
    DiGraphNode s = ddg_->GetTarget(e);
    if ((*ddg_)[s].time_ < 0) { return -1; }
    t = max(t, (*ddg_)[s].time_+(*ddg_)[e].latency_);
  }
  return t;
}

void BasicSequentialSelector::
InitSelector(DataDependencyGraph* ddg) {
  ddg_ = ddg;
  usedTimeSlot_.clear();
  for (DataDependencyGraph::iterator u = ddg_->begin(); u != ddg_->end(); ++u) {
    if (ddg_->OutDegree(u) == 0) {
      (*ddg_)[u].ready_ = 0;
    } else {
      (*ddg_)[u].ready_ = -1;
    }
    (*ddg_)[u].time_ = -1;
  }// for ddg_ iterator it
  for (DataDependencyGraph::iterator u = ddg_->begin(); u != ddg_->end(); ++u) {
    int lat = target_.GetOperationLatency((*ddg_)[u].instr_);
    (*ddg_)[u].latency_ = lat;
    for (DataDependencyGraph::out_edge_iterator e = ddg->out_edge_begin(u);
         e != ddg->out_edge_end(u); ++e) {
      if ((*ddg_)[e].type_ == DDGEdge::Data)
        (*ddg_)[e].latency_ = lat;
    }
  }
  CalculateDAGNodeHeight(*ddg_);
  CalculateDAGNodeMobility(*ddg_);
  // DDGNode::PrintHeight   = true;
  // DDGNode::PrintMobility = true;
  // static int i = 0;
  // ddg_->DrawDOT(cout, "BB"+ Int2DecString(i++));
  // DDGNode::ResetLabel();
}// BasicSequentialSelector::InitSelector()

DiGraphNode BasicSequentialSelector::
GetNextNode(int t) const {
  if (!ddg_ || IsElementOf(t, usedTimeSlot_))
    return lemon::INVALID;
  DiGraphNode sel = ddg_->end();
  for (DataDependencyGraph::iterator u = ddg_->begin(); u != ddg_->end(); ++u) {
    if ((*ddg_)[u].time_ >=0)
      continue;
    if (((*ddg_)[u].ready_ >= 0) && ((*ddg_)[u].ready_ <= t)) {
      bool c = false;
      if (sel == ddg_->end()) {
        c = true;
      } else if ((*ddg_)[u].height_ < (*ddg_)[sel].height_) {
        c = true;
      } else if (((*ddg_)[u].height_ == (*ddg_)[sel].height_)
                 && ((*ddg_)[u].mobility_ > (*ddg_)[sel].mobility_)) {
        c = true;
      }
      if (c) {
        sel = u;
      }
    }// if (((*ddg_)[u].ready_ >= 0) && ((*ddg_)[u].ready_ <= t))
  }// for ddg_ iterator u
  return sel;
}// BasicSequentialSelector::GetNextNode()

int BasicSequentialSelector::
PostNodeSchedUpdate(DiGraphNode u) {
  usedTimeSlot_.insert((*ddg_)[u].time_);
  for (DataDependencyGraph::in_edge_iterator e = ddg_->in_edge_begin(u);
       e != ddg_->in_edge_end(u); ++e) {
    DiGraphNode s = ddg_->GetSource(e);
    (*ddg_)[s].ready_ = NodeReady(s);
  }
  return 1;
}// BasicSequentialSelector::PostNodeSchedUpdate()

void BasicSequentialSelector::PreCycleUpdate(int t) {}
void BasicSequentialSelector::PostCycleUpdate(int t) {}

void IROrderSelector::
InitSelector(DataDependencyGraph* ddg) {
  ddg_ = ddg;
  usedTimeSlot_.clear();
  for (DataDependencyGraph::iterator u = ddg_->begin(); u != ddg_->end(); ++u) {
    if (ddg_->OutDegree(u) == 0) {
      (*ddg_)[u].ready_ = 0;
    } else {
      (*ddg_)[u].ready_ = -1;
    }
    (*ddg_)[u].time_ = -1;
  }// for ddg_ iterator it
  for (DataDependencyGraph::iterator u = ddg_->begin(); u != ddg_->end(); ++u) {
    int lat = target_.GetOperationLatency((*ddg_)[u].instr_);
    (*ddg_)[u].latency_ = lat;
    for (DataDependencyGraph::out_edge_iterator e = ddg->out_edge_begin(u);
         e != ddg->out_edge_end(u); ++e) {
      if ((*ddg_)[e].type_ == DDGEdge::Data)
        (*ddg_)[e].latency_ = lat;
    }
  }
  selHead_ = ddg_->GetBasicBlock()->rbegin();
  minTime_ = 0;
}// IROrderSelector::InitSelector()

DiGraphNode IROrderSelector::
GetNextNode(int t) const {
  if (!ddg_ || IsElementOf(t, usedTimeSlot_) || (t < minTime_)) {
    return lemon::INVALID;
  }
  DiGraphNode u = ddg_->GetInstrNode(*selHead_);
  if (((*ddg_)[u].ready_ >=0) && ((*ddg_)[u].ready_ <=t)) {
    return u;
  }
  return ddg_->end();
}// IROrderSelector::GetNextNode()

int IROrderSelector::
PostNodeSchedUpdate(DiGraphNode u) {
  usedTimeSlot_.insert((*ddg_)[u].time_);
  minTime_ = (*ddg_)[u].time_;
  for (DataDependencyGraph::in_edge_iterator e = ddg_->in_edge_begin(u);
       e != ddg_->in_edge_end(u); ++e) {
    DiGraphNode s = ddg_->GetSource(e);
    (*ddg_)[s].ready_ = NodeReady(s);
  }
  while (selHead_ != ddg_->GetBasicBlock()->rend()) {
    if ((*ddg_)[ddg_->GetInstrNode(*selHead_)].time_ < 0) { break; }
    ++selHead_;
  }
  return 1;
}// IROrderSelector::PostNodeSchedUpdate()

void IROrderSelector::PreCycleUpdate(int t) {}
void IROrderSelector::PostCycleUpdate(int t) {}
