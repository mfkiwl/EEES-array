#include "BaselineCodeGenEngine.hh"
#include "BaselineInstrData.hh"
#include "BaselineBlockData.hh"
#include "BaselineFuncData.hh"
#include "BaselineBUSelector.hh"
#include "BaselineBasicInfo.hh"
#include "Target/DataDependencyGraph.hh"
#include "Target/BottomUpSchedule.hh"
#include "SIR/SIRConstant.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRModule.hh"
#include "Target/TargetModuleData.hh"
#include "Target/TargetIssuePacket.hh"
#include "Utils/LogUtils.hh"
#include "Utils/StringUtils.hh"
#include "Utils/DbgUtils.hh"

using namespace std;
using namespace ES_SIMD;

void BaselineBlockSchedulingPass::
ScheduleBaselineBasicBlock(
  SIRBasicBlock* bb, DataDependencyGraph& ddg, BUSelector& selector) {
  int length = BottomUpScheduleDAG(ddg, selector);
  ES_LOG_P(logLv_, log_, "BB_"<< bb->GetBasicBlockID()<<" scheduled in "
           << length <<" cycles\n");
  std::vector<SIRInstruction*> schedInstrs(
    2*length, static_cast<SIRInstruction*>(NULL));
  for (DataDependencyGraph::iterator u = ddg.begin(); u != ddg.end(); ++u) {
    if (ddg[u].time_ < 0) {
      stringstream ss; ddg[u].instr_->TargetPrettyPrint(ss);
      errors_.push_back(
        Error(ErrorCode::DDGSchedFailure, "Failed to schedule "+ss.str(),
              ddg[u].instr_->GetFileLocation()));
      break;
    }
    SIRInstruction* instr = ddg[u].instr_;
    int issueTime = length-ddg[u].time_-1;
    int idx = 2*issueTime + (instr->IsVectorInstr() ? 1 :0);
    schedInstrs[idx] = instr;
    // Insert broadcasting code on CP side
    if (instr->IsVectorInstr()) {
      BaselineInstrData* iData = dynamic_cast<BaselineInstrData*>(
        instr->GetTargetData());
      for (unsigned i = 0; i < instr->operand_size(); ++i ) {
        if (iData->GetOperandComm(i) == BaselineInstrData::COMM_BROADCAST) {
          SIRInstruction* bcInstr = new SIRInstruction(
            TargetOpcode::ADD, bb, false);
          bcInstr->AddOperand(instr->GetOperand(i))
            .AddOperand(bb->GetParent()->GetParent()->AddOrGetImmediate(0));
          instr->ChangeOperand(i, bcInstr);
          bcInstr->SetValueID(bb->GetParent()->AllocateValue());
          schedInstrs[idx-1] = bcInstr;
          mData_->InitTargetData(bcInstr);
          bb->push_back(bcInstr);
          SetupCommPair(bcInstr, instr);
        }
      }
    }// if (instr->IsVectorInstr())
  }// for ddg iterator u
  BaselineBlockData& bData
    = *dynamic_cast<BaselineBlockData*>(bb->GetTargetData());
  for (int i = 0; i < length; ++i) {
    TargetIssuePacket* packet = new TargetIssuePacket(i, 2);
    packet->SetInstr(schedInstrs[2*i],   0);
    packet->SetInstr(schedInstrs[2*i+1], 1);
    bData.push_back(packet);
    if (schedInstrs[2*i] || schedInstrs[2*i+1]) { continue; }
    ES_LOG_P(logLv_, log_, "Padding cycle "<< i <<"\n");
    schedInstrs[2*i] = new SIRInstruction(TargetOpcode::NOP, bb, false);
    mData_->InitTargetData(schedInstrs[2*i]);
    bb->push_back(schedInstrs[2*i]);
  }
  if (logLv_) { bData.ValuePrint(log_); }
  bData.InitIssueTime();
  SetBaselineBlockBypass(bb, target_, logLv_, log_);
  bData.SetScheduled(true);
}// ScheduleBaselineBasicBlock()


BaselineBlockSchedulingPass::~BaselineBlockSchedulingPass() {}

void BaselineBlockSchedulingPass::
ModuleInit(SIRModule* m) { mData_ = m->GetTargetData(); }


static bool AllSuccScheduled(const SIRBasicBlock* bb) {
  int bid = bb->GetUID();
  for (SIRBasicBlock::succ_const_iterator it = bb->succ_begin();
       it != bb->succ_end(); ++it) {
    if ((*it)->GetUID() == bid) { continue; }
    if (!(*it)->GetTargetData()->IsScheduled()) { return false; }
  }
  return true;
}

bool BaselineBlockSchedulingPass::
RunOnSIRFunction(SIRFunction* func) {
  if (!func || func->empty()) { return false; }
  ES_LOG_P(logLv_, log_, ">> Scheduling "<< func->GetName() <<'\n');
  for (SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
    SIRBasicBlock* bb = *bIt;
    TargetBlockData* bData = bb->GetTargetData();
    bData->SetDDG(new DataDependencyGraph);
    DataDependencyGraph* ddg = bData->GetDDG();
    ddg->InitialBasicBlockDDG(bb, func->GetMemoryAliasTable());
    ddg->SerializeDependentFlags();
    if (!ddg->IsDAG()) {
      errors_.push_back(
        Error(ErrorCode::DDGInitFailure,
              "DDG "+func->GetName()+".B"+Int2DecString(bb->GetBasicBlockID())
              +" is not DAG", (*bb->begin())->GetFileLocation()));
      return true;
    }// if (!blockDDGs[bid]->IsDAG())
    ES_LOG_P(logLv_, log_, "BB_"<< bb->GetBasicBlockID() <<": DDG has "
             << ddg->size() <<" nodes and "<< ddg->edge_size() <<" edges\n");
    for (DataDependencyGraph::iterator u = ddg->begin(); u != ddg->end(); ++u) {
      SIRInstruction* uI = (*ddg)[u].instr_;
      int lat = target_.GetOperationLatency(uI);
      (*ddg)[u].latency_ = lat;
      for (DataDependencyGraph::out_edge_iterator e
             = ddg->out_edge_begin(u); e != ddg->out_edge_end(u); ++e) {
        if ((*ddg)[e].type_ == DDGEdge::Data) {
          SIRInstruction* vI = (*ddg)[ddg->GetTarget(e)].instr_;
          if (!uI->HasPredicate() || uI->PredicateValueEqual(vI)) {
            (*ddg)[e].latency_ = lat;
          } else {
            (*ddg)[e].latency_ = target_.GetOperationWritebackDelay(uI);
          }
        }// if ((*ddg)[e].type_ == DDGEdge::Data)
      }
    }// for ddg iterator u
    CalculateDAGNodeHeight(*ddg);
    CalculateDAGNodeMobility(*ddg);
  }// for func iterator bIt
  auto_ptr<BUSelector> selector;
  if (schedMode_ == TargetCodeGenEngine::IROrder) {
    selector.reset(new IROrderSelector(target_, (logLv_>1), log_));
  } else {
    if (target_.IsCPExplicitBypass() || target_.IsPEExplicitBypass()) {
      selector.reset(new BaselineBypassSelector(func,target_,(logLv_>1),log_));
    } else {
      selector.reset(new BaselineBypassSelector(func,target_,(logLv_>1),log_));
      // selector.reset(new BaselineBUSelector(func, target_, (logLv_>1), log_));
    }
  }
  int sched = 0;
  int numBlocks = func->size();
  while (sched < numBlocks) {
    SIRBasicBlock* nbb = NULL;
    /// Schedule the first block whose successors are all scheduled. If no such
    /// block is found, schedule the last block that is not scheduled yet.
    for (SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
      if ((*bIt)->GetTargetData()->IsScheduled()) { continue; }
      nbb = *bIt;
      if (AllSuccScheduled(nbb)) { break; }
    }
    if (nbb) {
      ScheduleBaselineBasicBlock(nbb,*nbb->GetTargetData()->GetDDG(),*selector);
      ++sched;
    } else { ES_UNREACHABLE("No next block to schecule in "+func->GetName()); }
  }// while (sched < numBlocks)
  ES_LOG_P(logLv_, log_, "Checking and fixing joint-points\n");
  BaselineFixJointPoints(func, target_, logLv_, log_);
  return true;
}// RunOnSIRFunction()
