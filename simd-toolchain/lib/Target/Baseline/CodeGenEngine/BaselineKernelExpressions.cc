#include "BaselineKernelBuilder.hh"
#include "BaselineBasicInfo.hh"
#include "SIR/SIRRegister.hh"
#include "SIR/SIRKernel.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRExpr.hh"
#include "Utils/DbgUtils.hh"

using namespace std;
using namespace ES_SIMD;

ExprInvariantChecker::
ExprInvariantChecker(SIRFunction* func, int logLv, std::ostream& log)
  : func_(func), kernel_(func->GetSolverKernel()),logLv_(logLv), log_(log) {}

void ExprInvariantChecker::
operator()(SIRBinExprNode* n) {
  if (n->IsLeaf()) {
    if (SIRRegister::classof(n->GetValue())) {
      SIRRegister* r = static_cast<SIRRegister*>(n->GetValue());
      if (kernel_->IsGlobalCounter(r->GetValueID())) {
        globalInvariant_ = (kernel_->GetLaunchParams().GetTotalNumGroups() <= 1);
      } else if (kernel_->IsLocalCounter(r->GetValueID())) {
        globalInvariant_ = false;
      } else if (kernel_->GetGlobalDimCounterIndex(r) >= 0) {
        globalInvariant_ = false;
      } else if (func_->GetPEIDRegister()->ValueEqual(r)) {
        //globalInvariant_ = localInvariant_ = false;
      } else if (!func_->IsInvariant(n->GetValue())){
        localInvariant_ = globalInvariant_ = false;
      }
    }// if (SIRRegister::classof(n->GetValue()))
  }// if (n->IsLeaf())
}// ExprInvariantChecker::operator()

LowerKernelSpecialRegs::
LowerKernelSpecialRegs(SIRFunction* func, const BaselineBasicInfo& target,
                       int logLv, ostream& log)
  : func_(func), kernel_(func->GetSolverKernel()), target_(target),
    logLv_(logLv), log_(log) {
}// LowerKernelSpecialRegs()

void LowerKernelSpecialRegs::
operator()(SIRBinExprNode* n) {
  if (!n || !n->IsLeaf() || !SIRRegister::classof(n->GetValue())) { return; }
  SIRRegister* reg = static_cast<SIRRegister*>(n->GetValue());
  if (!kernel_->IsVirtualSpecialReg(reg->GetValueID())) { return; }
  int srID = kernel_->GetVirtualSRegID(reg->GetValueID());
  if ((srID>=SIRKernel::GLOBAL_ID_X) && (srID<=SIRKernel::GLOBAL_ID_Z)) {
    /// global_id = scalar_global_counter + PE_ID
    SIRBinExprNode* gCntNode = SIRBinExprNode::CreateBinExprNode(
      kernel_->GetGlobalCounter());
    SIRBinExprNode* peidNode = SIRBinExprNode::CreateBinExprNode(
      func_->GetPEIDRegister());
    SIRBinExprNode* nPENode  = SIRBinExprNode::CreateBinExprNode(
      func_->GetNumPERegister());
    SIRBinExprNode* m = SIRBinExprNode::CreateBinExprNode(
      func_->GetParent(), SIROpcode::MUL, gCntNode, nPENode);
    n->SetNode(SIROpcode::ADD, m, peidNode);
  } else if ((srID>=SIRKernel::LOCAL_ID_X) && (srID<=SIRKernel::LOCAL_ID_Z)) {
    // local_id = scalar_local_counter + PE_ID
    SIRBinExprNode* lCntNode = SIRBinExprNode::CreateBinExprNode(
      kernel_->GetLocalCounter());
    SIRBinExprNode* peidNode = SIRBinExprNode::CreateBinExprNode(
      func_->GetPEIDRegister());
    SIRBinExprNode* nPENode  = SIRBinExprNode::CreateBinExprNode(
      func_->GetNumPERegister());
    SIRBinExprNode* m = SIRBinExprNode::CreateBinExprNode(
      func_->GetParent(), SIROpcode::MUL, lCntNode, nPENode);
    n->SetNode(SIROpcode::ADD, m, peidNode);
  } else if ((srID>=SIRKernel::GROUP_ID_X) && (srID<=SIRKernel::GROUP_ID_Z)) {
    // group_id = scalar_group_counter
    ES_NOTIMPLEMENTED("Group ID");
  }
  ES_ASSERT_MSG(n->Valid(), "Invalid expression after SReg lowering");
}// LowerKernelSpecialRegs::operator ()

LowerSingleGroupKernelSRegs::
LowerSingleGroupKernelSRegs(SIRFunction* func, const BaselineBasicInfo& target,
                       int logLv, ostream& log)
  : func_(func), kernel_(func->GetSolverKernel()), target_(target),
    numPE_(target.GetNumPE()), logLv_(logLv), log_(log) {
  const SIRKernelLaunch& kl = kernel_->GetLaunchParams();
  for (int i = 0; i < 3; ++i) { glbSize_[i] = kl.groupSize_[i]; }
}// LowerSingleGroupKernelSRegs()

void LowerSingleGroupKernelSRegs::
operator()(SIRBinExprNode* n) {
  if (!n || !n->IsLeaf() || !SIRRegister::classof(n->GetValue())) { return; }
  SIRRegister* reg = static_cast<SIRRegister*>(n->GetValue());
  if (!kernel_->IsVirtualSpecialReg(reg->GetValueID())) { return; }
  int srID = kernel_->GetVirtualSRegID(reg->GetValueID());
  if (srID == SIRKernel::GLOBAL_ID_X) {
    if (glbSize_[0] > numPE_) {
      SIRBinExprNode* xCntNode = SIRBinExprNode::CreateBinExprNode(
        kernel_->GetGlobalDimCounter(0));
      SIRBinExprNode* peidNode = SIRBinExprNode::CreateBinExprNode(
        func_->GetPEIDRegister());
      SIRBinExprNode* nPENode  = SIRBinExprNode::CreateBinExprNode(
        func_->GetNumPERegister());
      SIRBinExprNode* m = SIRBinExprNode::CreateBinExprNode(
        func_->GetParent(), SIROpcode::MUL, xCntNode, nPENode);
      n->SetNode(SIROpcode::ADD, m, peidNode);
    } else{ n->SetValue(func_->GetPEIDRegister()); }// if (glbSize_[0] > numPE_)
  } else if (srID == SIRKernel::GLOBAL_ID_Y) {
    n->SetValue(kernel_->GetGlobalDimCounter(1));
  } else if (srID == SIRKernel::GLOBAL_ID_Z) {
    n->SetValue(kernel_->GetGlobalDimCounter(2));
  } else {
    ES_UNREACHABLE("Only global ID should be found in single group kernel");
  }
  ES_ASSERT_MSG(n->Valid(), "Invalid expression after SReg lowering");
  return;
  if ((srID>=SIRKernel::GLOBAL_ID_X) && (srID<=SIRKernel::GLOBAL_ID_Z)) {
    /// global_id = scalar_global_counter + PE_ID
    SIRBinExprNode* gCntNode = SIRBinExprNode::CreateBinExprNode(
      kernel_->GetGlobalCounter());
    SIRBinExprNode* peidNode = SIRBinExprNode::CreateBinExprNode(
      func_->GetPEIDRegister());
    SIRBinExprNode* nPENode  = SIRBinExprNode::CreateBinExprNode(
      func_->GetNumPERegister());
    SIRBinExprNode* m = SIRBinExprNode::CreateBinExprNode(
      func_->GetParent(), SIROpcode::MUL, gCntNode, nPENode);
    n->SetNode(SIROpcode::ADD, m, peidNode);
  } else {
    ES_UNREACHABLE("Only global ID should be found in single group kernel");
  }
  ES_ASSERT_MSG(n->Valid(), "Invalid expression after SReg lowering");
}// LowerStandardKernelAddress

static int
GetMinValue(SIRBinExprNode* expr, int numPE,
               SIRKernel* kernel, SIRFunction* func) {
  if (expr->IsLeaf()) {
    if (expr->IsConstant()) { return expr->GetConstant(); }
    if (expr->ValueEqual(func->GetPEIDRegister()))  { return 0;     }
    if (expr->ValueEqual(func->GetNumPERegister())) { return numPE; }
    if (kernel->GetGlobalDimCounterIndex(expr->GetValue()) >= 0) { return 0; }
  }
  return 0;
}// GetMinValue()

static int
GetMaxAbsValue(SIRBinExprNode* expr, int numPE,
            SIRKernel* kernel, SIRFunction* func) {
  if (expr->IsLeaf()) {
    if (expr->IsConstant()) { return abs(expr->GetConstant()); }
    if (expr->ValueEqual(func->GetPEIDRegister()))  { return numPE-1; }
    if (expr->ValueEqual(func->GetNumPERegister())) { return numPE;   }
    int gid = kernel->GetGlobalDimCounterIndex(expr->GetValue());
    if (gid >= 0) { return kernel->GetGlobalDimCounterMax(gid); }
  } else {// if (expr->IsLeaf())
    SIROpcode_t opc = expr->GetOpcode();
    switch (opc) {
    case SIROpcode::ADD:
      return GetMaxAbsValue(expr->GetLHS(), numPE, kernel, func)
        +GetMaxAbsValue(expr->GetRHS(), numPE, kernel, func);
    case SIROpcode::SUB:
      return GetMaxAbsValue(expr->GetLHS(), numPE, kernel, func)
        - GetMinValue(expr->GetRHS(), numPE, kernel, func);
    default: break;
    }// switch (opc)
  }// if (expr->IsLeaf())
  // Here we return the worst cast for communication distance
  return numPE - 1;
}// GetMaxAbsValue()

int ES_SIMD::
CalculateMaxCommDist(SIRBinExprNode* offset, int numPE,
                     SIRKernel* kernel, SIRFunction* func) {
  return GetMaxAbsValue(offset, numPE, kernel, func) % numPE;
}// CalculateMaxCommDist()
