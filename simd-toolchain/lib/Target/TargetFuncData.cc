#include "Target/TargetFuncData.hh"
#include "Target/TargetBlockData.hh"
#include "Target/TargetFuncRegAllocInfo.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRBasicBlock.hh"

using namespace ES_SIMD;
using namespace std;

TargetFuncData::~TargetFuncData() { delete regAllocInfo_; }

int TargetFuncData::
GetValueFirstUsedTime(int v) const {
  int base = 0, ut = -1;
  for (SIRFunction::const_iterator it=func_->begin(); it != func_->end(); ++it){
    int bt = (*it)->GetTargetData()->ValueFirstUsedTime(v);
    if (bt >=0) { return base + bt; }
    base += (*it)->GetTargetData()->GetTargetSize();
  }
  return ut;
}

void TargetFuncData::ValuePrint(std::ostream& o) const {
  func_->ValuePrint(o);
}

void TargetFuncData::PrintCodeGenStat(std::ostream& o) const {}

void TargetFuncData::
PrintStatistics(ostream& o) const {
  int totalIR = 0;
  for (SIRFunction::const_iterator bIt = func_->begin();
       bIt != func_->end(); ++bIt) {
    totalIR += (*bIt)->size();
  }
  o <<">> BEGIN function statistics\n";
  o <<"name:"<< func_->GetName() <<'\n';
  o <<"basicblocks:"<< func_->size() <<'\n';
  o <<"loops:"<< func_->loop_size() <<'\n';
  o <<"ir:"<< totalIR <<'\n';
  o <<"address:"<< GetTargetAddress() <<'\n';
  PrintCodeGenStat(o);
  o <<'\n';
  for (SIRFunction::const_iterator bIt = func_->begin();
       bIt != func_->end(); ++bIt) {
    (*bIt)->GetTargetData()->PrintStatistics(o);
    o <<'\n';
  }
  o <<">> END function statistics\n";
}// PrintStatistics()
