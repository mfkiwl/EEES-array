#include "BaselineBUSelector.hh"
#include "BaselineBasicInfo.hh"
#include "BaselineInstrData.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRFunction.hh"
#include "Target/TargetBlockData.hh"
#include "Utils/DbgUtils.hh"
#include "Utils/LogUtils.hh"
#include "Utils/InlineUtils.hh"

using namespace std;
using namespace ES_SIMD;

BaselineBUSelector::
BaselineBUSelector(SIRFunction* func, const TargetBasicInfo& target,
                   bool log, std::ostream& logs)
  : BUSelector(target, log, logs), func_(func), nodeSelectData_(NULL) {
  const BaselineBasicInfo* tgt=dynamic_cast<const BaselineBasicInfo*>(&target);
  jpThreshold_[0] = tgt->IsCPExplicitBypass() ? (tgt->GetCPNumStages()-3) : 0;
  jpThreshold_[1] = tgt->IsPEExplicitBypass() ? (tgt->GetPENumStages()-3) : 0;
  timeSlot_.resize(2);
}

BaselineBUSelector::
~BaselineBUSelector() { delete nodeSelectData_; }

void BaselineBUSelector::
InitSelector(DataDependencyGraph* ddg) {
  ddg_ = ddg;
  SIRBasicBlock* bb = ddg->GetBasicBlock();
  ES_LOG_P(log_, logs_, ">> Initializing selector for "<< func_->GetName()
           <<".B"<< bb->GetBasicBlockID()<<'\n');
  if (log_) { ddg->GetBasicBlock()->ValuePrint(logs_); }
  if (nodeSelectData_) { delete nodeSelectData_; }
  nodeSelectData_=new lemon::ListDigraph::NodeMap<NodeSelData>(ddg->GetGraph());
  timeSlot_[0].clear();
  timeSlot_[1].clear();
  cpActiveFlag_ = peActiveFlag_ = -1;
  liveVars_.resize(func_->GetNumValues());
  liveVars_.reset();
  for (DataDependencyGraph::iterator u = ddg_->begin(); u != ddg_->end(); ++u) {
    (*ddg_)[u].ready_ = (ddg_->OutDegree(u) == 0) ? 0 : -1;
    (*ddg_)[u].time_ = -1;

    SIRInstruction* instr = (*ddg_)[u].instr_;
    NodeSelData& nSel = (*nodeSelectData_)[u];
    int val = instr->GetValueID();
    nSel.vect_ = instr->IsVectorInstr();
    if(bb->IsValueLiveOut(val)) {
      nSel.liveOut_ = true;
      for (SIRBasicBlock::succ_iterator sIt = bb->succ_begin();
           sIt != bb->succ_end(); ++sIt) {
        if ((*sIt)->UsesValue(val)) {
          TargetBlockData* sData = (*sIt)->GetTargetData();
          int ut = sData->IsScheduled() ? sData->ValueFirstUsedTime(val)
            : sData->GetDDG()->ValueEarlistUseTime(val);
          if ((ut>=0) && ((nSel.succUsedTime_<0)||(nSel.succUsedTime_>ut))) {
            nSel.succUsedTime_ = ut;
          }
        }// if ((*sIt)->UsesValue(val))
      }
    }// if(bb->IsValueLiveOut(val))
    nSel.height_   = (*ddg_)[u].height_;
    nSel.mobility_ = (*ddg_)[u].mobility_;
    nSel.defs_     = func_->IsValidValueID(instr->GetValueID());
    nSel.uses_ = 0;
    for (unsigned i = 0; i < instr->operand_size(); ++i) {
      if (func_->IsValidValueID(instr->GetOperand(i)->GetValueID())) {
        ++nSel.uses_;
      }
    }
    nSel.maxInLatency_ = 0;
    for (DataDependencyGraph::in_edge_iterator e = ddg->in_edge_begin(u);
         e != ddg->in_edge_end(u); ++e) {
      if (ddg->IsDataEdge(e)) {
        nSel.maxInLatency_ = max(nSel.maxInLatency_, (*ddg)[e].latency_);
      }
    }
  }// for ddg_ iterator it
}// BaselineBUSelector::InitSelector()

DiGraphNode BaselineBUSelector::
GetNextNode(int t) const {
  if (!ddg_ || (IsElementOf(t, timeSlot_[0]) && IsElementOf(t, timeSlot_[1])))
    return lemon::INVALID;
  DiGraphNode sel = ddg_->end();
  for (DataDependencyGraph::iterator u = ddg_->begin(); u != ddg_->end(); ++u) {
    if ((*ddg_)[u].time_ >= 0) { continue; }
    SIRInstruction* instr = (*ddg_)[u].instr_;
    BaselineInstrData* iData = dynamic_cast<BaselineInstrData*>(
      instr->GetTargetData());
    int uf = instr->UsedFlag();
    if (instr->IsVectorInstr()) {
      // Check if the current cycle can issue PE instruction
      if (IsElementOf(t, timeSlot_[1])) { continue; }
      if (iData->HasBroadcast() && IsElementOf(t, timeSlot_[0]))   { continue; }
      if ((peActiveFlag_ >= 0)&&(uf >= 0)&&(uf != peActiveFlag_)) { continue; }
    } else {
      // Check if the current cycle can issue CP instruction
      if (IsElementOf(t, timeSlot_[0])) { continue; }
      if ((cpActiveFlag_ >= 0)&&(uf >= 0)&&(uf != cpActiveFlag_)) { continue; }
    }
    if (NodeCommReady(u, t)) {
      sel = GetBetterNode(sel, u, t);
    }// if (((*ddg_)[u].ready_ >= 0) && ((*ddg_)[u].ready_ <= t))
  }// for ddg_ iterator u
  if (log_ && (sel != ddg_->end())) {
    NodeSelData& sDat = (*nodeSelectData_)[sel];
    logs_ <<"      >> Selected: ["; (*ddg_)[sel].instr_->ValuePrint(logs_);
    logs_<<"], u="<< sDat.uses_<<", d="<< sDat.defs_<<'\n';
  }
  return sel;
}// BaselineBUSelector::GetNextNode()

int BaselineBUSelector::
PostNodeSchedUpdate(DiGraphNode u) {
  SIRInstruction* instr = (*ddg_)[u].instr_;
  BaselineInstrData* iData = dynamic_cast<BaselineInstrData*>(
      instr->GetTargetData());
  int f = instr->UsedFlag();
  int df = instr->DefinedFlag();
  int sched = 1;
  if (instr->IsVectorInstr()) {
    timeSlot_[1].insert((*ddg_)[u].time_);
    if (iData->HasBroadcast()) { timeSlot_[0].insert((*ddg_)[u].time_); }
    if (SIRInstruction* cons = iData->GetCommConsumer())  {
      if (log_) {
        logs_<<"            -- Schedules comm consumer [";
        cons->ValuePrint(logs_)<<"]\n";
      }
      timeSlot_[0].insert((*ddg_)[u].time_);
      DiGraphNode cNode = ddg_->GetInstrNode(cons);
      (*ddg_)[cNode].time_ = (*ddg_)[u].time_;
      UpdateSrcNodes(cNode);
      ++sched;
    }// if (SIRInstruction* cons = iData->GetCommConsumer())
    if (SIRInstruction* prod = iData->GetCommProducer())  {
      timeSlot_[0].insert((*ddg_)[u].time_);
      DiGraphNode pNode = ddg_->GetInstrNode(prod);
      (*ddg_)[pNode].time_ = (*ddg_)[u].time_;
      UpdateSrcNodes(pNode);
      ++sched;
    }// if (SIRInstruction* cons = iData->GetCommConsumer())
    if (f >= 0) { peActiveFlag_ = f; }
    if (df >= 0) {
      // The following assert doesn't work with flag that live across blocks
      // ES_ASSERT_MSG(peActiveFlag_==df, "Illegal flag definition V_"
      //               << df <<", expected V_"<< peActiveFlag_ <<"\n");
      peActiveFlag_ = -1;
    }
  } else {// if (instr->IsVectorInstr)
    timeSlot_[0].insert((*ddg_)[u].time_);
    if (SIRInstruction* prod = iData->GetCommProducer()) {
      timeSlot_[1].insert((*ddg_)[u].time_);
      DiGraphNode pNode = ddg_->GetInstrNode(prod);
      (*ddg_)[pNode].time_ = (*ddg_)[u].time_;
      UpdateSrcNodes(pNode);
      ++sched;
    }
    if (f >= 0) { cpActiveFlag_ = f; }
    if (df >= 0) {
      ES_ASSERT_MSG(cpActiveFlag_==df, "Illegal flag definition V_"<< df
                    <<", expected V_"<< cpActiveFlag_ <<"\n");
      cpActiveFlag_ = -1;
    }
  }
  UpdateSrcNodes(u);
  int v = instr->GetValueID();
  if ((v >= 0) && (v < static_cast<int>(liveVars_.size()))) {
    liveVars_[v] = false;
  }
  for (unsigned i = 0; i < instr->operand_size(); ++i) {
    int ov = instr->GetOperand(i)->GetValueID();
    if ((ov >= 0) && (ov < static_cast<int>(liveVars_.size()))) {
      liveVars_[ov] = true;
    }
  }
  return sched;
}// BaselineBUSelector::PostNodeSchedUpdate()

void BaselineBUSelector::PreCycleUpdate(int t) {
  ES_LOG_P(log_, logs_, ">>-- Starting t = "<< t <<'\n');
  ES_LOG_P(log_ && (cpActiveFlag_>=0), logs_,
           ">>-->> CP active flag = "<< cpActiveFlag_ <<'\n');
  ES_LOG_P(log_ && (peActiveFlag_>=0), logs_,
           ">>-->> CP active flag = "<< peActiveFlag_ <<'\n');
}// BaselineBUSelector::PreCycleUpdate()

void BaselineBUSelector::PostCycleUpdate(int t) {
  ES_LOG_P(log_, logs_, ">>-- Finishing t = "<< t <<'\n');
  ES_LOG_P(log_, logs_, ">>-->> Live variables ("<< liveVars_.count()<<"): "
           << liveVars_ <<'\n');
}// BaselineBUSelector::PostCycleUpdate()

bool BaselineBUSelector::
NodeEnables(DiGraphNode u, DiGraphNode v, int t) const {
  for (DataDependencyGraph::out_edge_iterator e = ddg_->out_edge_begin(v);
       e != ddg_->out_edge_end(v); ++e) {
    DiGraphNode s = ddg_->GetTarget(e);
    if (s == u) { continue; }
    if ((*ddg_)[s].time_ < 0) { return false; }
    if (((*ddg_)[s].time_+(*ddg_)[e].latency_) > t) { return false; }
  }
  return true;
}// NodeEnables()

bool BaselineBUSelector::
NodeCommReady(DiGraphNode u, int t) const {
  if (((*ddg_)[u].ready_ < 0) || ((*ddg_)[u].ready_ > t)) { return false; }
  SIRInstruction* instr = (*ddg_)[u].instr_;
  if (IsElementOf(t, timeSlot_[instr->IsVectorInstr()])) { return false; }
  BaselineInstrData* iData
    = dynamic_cast<BaselineInstrData*>(instr->GetTargetData());
  if (SIRInstruction* prod = iData->GetCommProducer()) {
    DiGraphNode pn = ddg_->GetInstrNode(prod);
    ES_ASSERT_MSG(ddg_->Valid(pn), "Invalid node for "<<*prod);
    if (IsElementOf(t, timeSlot_[prod->IsVectorInstr()])) { return false; }
    if (!NodeEnables(u, pn, t)) { return false; }
  }// if (SIRInstruction* prod = instr->GetCommProducer())
  // if (SIRInstruction* cons = iData->GetCommConsumer()) {
  //   DiGraphNode cn = ddg_->GetInstrNode(cons);
  //   ES_ASSERT_MSG(ddg_->Valid(cn), "Invalid node for "<<*cons);
  //   int ct = (*ddg_)[cn].ready_;
  //   if ((ct < 0) || (ct > t)) { return false; }
  //   if (IsElementOf(t, timeSlot_[cons->IsVectorInstr()])) { return false; }
  // }// if (SIRInstruction* cons = instr->GetCommConsumer())
  return true;
}// NodeCommReady()

ostream& BaselineBUSelector::
PrintNodeSel(DiGraphNode u, ostream& o) const {
  const BaselineBUSelector::NodeSelData& uDat = (*nodeSelectData_)[u];
  o <<"[";(*ddg_)[u].instr_->ValuePrint(o) <<"] (u="<< uDat.uses_
    <<", d="<< uDat.defs_<<", h="<< uDat.height_<<", m="<< uDat.mobility_
    <<", live-out="<<uDat.liveOut_<<", succ_ut="<<uDat.succUsedTime_<<")";
  return o;
}

static bool NodeCausesJP(int threshold, int t, int succUsedTime) {
  int dt = threshold - t;
  if ((dt > 0) && (succUsedTime >= 0)) { return succUsedTime < dt; }
  return false;
}

DiGraphNode BaselineBUSelector::
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
  int uNumVars = uDat.uses_ - uDat.defs_, vNumVars = vDat.uses_ - vDat.defs_;
  bool uCausesJP = NodeCausesJP(jpThreshold_[uDat.vect_],t,uDat.succUsedTime_);
  bool vCausesJP = NodeCausesJP(jpThreshold_[vDat.vect_],t,vDat.succUsedTime_);
  uPriority.clear();
  vPriority.clear();
  uPriority.push_back(uCausesJP);           vPriority.push_back(vCausesJP);
  uPriority.push_back(uNumVars);            vPriority.push_back(vNumVars);
  //uPriority.push_back(uDat.maxInLatency_);  vPriority.push_back(vDat.maxInLatency_);
  //uPriority.push_back((*ddg_)[v].latency_); vPriority.push_back((*ddg_)[u].latency_);
  //uPriority.push_back(uDat.liveOut_);       vPriority.push_back(vDat.liveOut_);
  uPriority.push_back(uDat.height_);        vPriority.push_back(vDat.height_);
  uPriority.push_back(uDat.mobility_);      vPriority.push_back(vDat.mobility_);

  return PriorityCompare(uPriority, vPriority)? u : v;
}// GetBetterNode()
