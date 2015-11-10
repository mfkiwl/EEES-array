#include "Target/TargetBlockData.hh"
#include "Target/TargetIssuePacket.hh"
#include "Target/TargetInstrData.hh"
#include "Target/DataDependencyGraph.hh"
#include "Target/DDGSubTree.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRLoop.hh"
#include "Utils/StringUtils.hh"

using namespace ES_SIMD;

TargetBlockData::~TargetBlockData() {
  delete ddg_;
}

void TargetBlockData::Reset() {}

void TargetBlockData::
InitIssueTime() {
  int t = 0;
  for (iterator it = issueList_.begin(); it != issueList_.end(); ++it, ++t) {
    TargetIssuePacket* packet = *it;
    packet->SetIssueTime(t);
  }
  length_ = t;
}// InitIssueTime()

int TargetBlockData::
ValueFirstUsedTime(int v) const {
  for (const_iterator it = begin(); it != end(); ++it) {
    if ((*it)->UsesValue(v)) { return (*it)->IssueTime(); }
  }
  return -1;
}// ValueFirstUsedTime()

TargetIssuePacket* TargetBlockData::
FindPacket(const SIRInstruction* instr) const {
  for (const_iterator pIt=issueList_.begin(); pIt != issueList_.end(); ++pIt) {
    TargetIssuePacket* packet = *pIt;
    TargetIssuePacket::iterator it=find(packet->begin(), packet->end(), instr);
    if (it != packet->end()) { return packet; }
  }
  return NULL;
}

int TargetBlockData::
ValueUseCount(int v) const {
  int c = 0;
  for (const_iterator it = begin(); it != end(); ++it) {
    c += (*it)->ValueUseCount(v);
  }
  return c;
}// ValueUseCount()

int TargetBlockData::
ValueLastDefTime(int v) const {
  for (const_reverse_iterator it = rbegin(); it != rend(); ++it) {
    if ((*it)->DefinesValue(v)) { return (*it)->IssueTime(); }
  }
  return -1;
}// ValueLastDefTime()

void TargetBlockData::ValuePrint(std::ostream& o) const {
  bb_->ValuePrint(o);
}

void TargetBlockData::
PrintStatistics(std::ostream& o) const {
  o <<">> BEGIN BB statistics\n";
  o <<"id:"<< bb_->GetBasicBlockID() <<'\n';
  o <<"address:"<< GetTargetAddress() <<'\n';
  if (SIRLoop* lastLoop = bb_->GetLoop())   {
    o <<"loop_depth:"<< lastLoop->GetLoopDepth() <<'\n';
  }
  o <<"ir:"<< bb_->size() <<'\n';
  PrintCodeGenStat(o);
  o <<">> END BB statistics\n";
}// PrintStatistics()

void TargetBlockData::PrintCodeGenStat(std::ostream& o) const {}

void TargetBlockData::
DrawDDG(std::ostream& o) const {
  if (ddg_) {
    ddg_->CalculateEdgeVisibility();
    ddg_->DrawDOT(o, bb_->GetParent()->GetName() + "_B"
                 + Int2DecString(bb_->GetBasicBlockID())+"_ddg");
  }
}// DrawDDG()

void TargetBlockData::
DrawDDGSubTrees(std::ostream& o) const {
  if (ddg_ && ddg_->GetSubTreeDG()) {
    ddg_->GetSubTreeDG()->CalculateEdgeVisibility();
    ddg_->GetSubTreeDG()->DrawDOT(
      o, bb_->GetParent()->GetName() + "_B"
      + Int2DecString(bb_->GetBasicBlockID())+"_ddg_stdg");
  }
}// DrawDDG()

void TargetBlockData::
Dump(Json::Value& bInfo) const {
  bInfo["address"] = GetTargetAddress();
  bInfo["size"] = static_cast<int>(size());
  for (const_iterator pIt = begin(); pIt != end(); ++pIt) {
    Json::Value pVal;
    const TargetIssuePacket* packet = *pIt;
    pVal["time"] = packet->IssueTime();
    for (int i=0, e=packet->size(); i < e; ++i) {
      Json::Value iVal;
      if (packet->GetInstruction(i)) {
        packet->GetInstruction(i)->Dump(iVal);
        if (packet->GetInstruction(i)->GetTargetData()) {
          packet->GetInstruction(i)->GetTargetData()->Dump(iVal);
        }
      }// if (packet->GetInstruction(i))
      else {
        iVal["opcode"] = "NOP";
        iVal["asm"] = "nop";
      }
      iVal["issue_id"] = i;
      pVal["operations"].append(iVal);
    }
    bInfo["packets"].append(pVal);
  }
}// Dump()
