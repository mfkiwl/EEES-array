#include "SIR/SIRMemLocation.hh"
#include "SIR/SIRExpr.hh"
#include "SIR/SIRRegister.hh"
#include "SIR/SIRConstant.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRModule.hh"
#include "Utils/DbgUtils.hh"

using namespace std;
using namespace ES_SIMD;

struct ExprLeafValues {
  vector<SIRValue*> leafValues_;
  void operator()(SIRBinExprNode* n) {
    if (n && n->IsLeaf()) { leafValues_.push_back(n->GetValue()); }
  }
};

struct ExprHasScalarReg {
  bool hasScalarReg_;
  void Reset() { hasScalarReg_ = false; }
  bool CheckExpr(SIRBinExprNode* n) {
    hasScalarReg_ = false;
    n->VisitNodesPreOrder(*this);
    return hasScalarReg_;
  }
  void operator()(SIRBinExprNode* n) {
    if (n && n->IsLeaf() && SIRRegister::classof(n->GetValue())
        && !static_cast<SIRRegister*>(n->GetValue())->IsVector()) {
      hasScalarReg_ = true;
    }
  }
  ExprHasScalarReg() : hasScalarReg_(false){}
};

SIRMemLocation::
SIRMemLocation(SIRValue* base, SIRValue* offset, SIROpcode_t opc,
               SIRFunction* func)
  : addrSpace_(0), func_(func), kernelRowAddr_(NULL), kernelColOffset_(NULL),
    scalarBaseReg_(NULL) {
  switch (opc) {
  case SIROpcode::SW: case SIROpcode::LW: shiftAmount_ = 2; break; 
  case SIROpcode::SH: case SIROpcode::LH: shiftAmount_ = 1; break; 
  case SIROpcode::SB: case SIROpcode::LB: shiftAmount_ = 0; break;
  default: ES_UNREACHABLE("Invalid memory opcode"<< opc);
  }
  SIRBinExprNode* baseExpr   = SIRBinExprNode::CreateBinExprNode(base);
  SIRBinExprNode* offsetExpr = SIRBinExprNode::CreateBinExprNode(offset);
  addrExpr_ = SIRBinExprNode::CreateBinExprNode(
    func->GetParent(), SIROpcode::ADD, baseExpr, offsetExpr);
  ES_ASSERT_MSG(addrExpr_->Valid(), "Address expression is not valid");
  ExprLeafValues lVals;
  addrExpr_->VisitNodesPreOrder(lVals);
  for (unsigned i = 0; i < lVals.leafValues_.size(); ++i) {
    if (SIRRegister::classof(lVals.leafValues_[i])) {
      SIRRegister* r = static_cast<SIRRegister*>(lVals.leafValues_[i]);
      int addrSpace = func->GetArgPointerAddrSpace(r->GetValueID());
      if (addrSpace >= 0) { addrSpace_ = addrSpace; }
    }// if (SIRRegister::classof(lVals.leafValues_[i]))
  }// for i = 0 to lVals.leafValues_.size()-1
  if (IsStandardKernelForm() || IsShiftedStandardKernelForm()) {
    scalarBaseReg_ = static_cast<SIRRegister*>(addrExpr_->GetLHS()->GetValue());
  }
}// SIRMemLocation()

SIRMemLocation::~SIRMemLocation() {}

bool SIRMemLocation::
UsesValue(int val) const { return addrExpr_ && addrExpr_->UsesValue(val); }

bool SIRMemLocation::
UsesValue(SIRValue* val) const { return addrExpr_ && addrExpr_->UsesValue(val); }

void SIRMemLocation::
SetKernelAddress(SIRBinExprNode* ra, SIRBinExprNode* co) {
  kernelRowAddr_   = (shiftAmount_ > 0) ?
    SIRBinExprNode::CreateBinExprNode(
      func_->GetParent(), SIROpcode::SLL, ra, SIRBinExprNode::CreateBinExprNode(
        func_->GetParent()->AddOrGetImmediate(shiftAmount_))) : ra;
  kernelColOffset_ = co;
}

bool SIRMemLocation::
IsStandardKernelForm() const {
  if (func_->IsSolverKernel() && addrExpr_) {
    if (addrExpr_->GetOpcode() != SIROpcode::ADD) { return false; }
    SIRBinExprNode* base = addrExpr_->GetLHS();
    if (!base || !base->IsLeaf()
        || !SIRRegister::classof(base->GetValue())) { return false; }
    SIRRegister* baseReg = static_cast<SIRRegister*>(base->GetValue());
    if (baseReg->IsVector()) {return false;}
    SIRBinExprNode* offset = addrExpr_->GetRHS();
    if (!offset || offset->GetOpcode() != SIROpcode::SLL) { return false; }
    SIRBinExprNode* shmt = offset->GetRHS();
    if (!shmt || !shmt->IsLeaf()
        || !SIRConstant::classof(shmt->GetValue())) { return false; }
    return true;
  }// if (func_->IsSolverKernel() && addrExpr_)
  return false;
}// IsStandardKernelForm()

bool SIRMemLocation::
IsShiftedStandardKernelForm() const {
  if (func_->IsSolverKernel() && addrExpr_) {
    if (addrExpr_->GetOpcode() != SIROpcode::ADD) { return false; }
    SIRBinExprNode* base = addrExpr_->GetLHS();
    if (!base || !base->IsLeaf()
        || !SIRRegister::classof(base->GetValue())) { return false; }
    SIRRegister* baseReg = static_cast<SIRRegister*>(base->GetValue());
    if (baseReg->IsVector()) {return false;}
    SIRBinExprNode* offset = addrExpr_->GetRHS();
    if (!offset || offset->GetOpcode() != SIROpcode::ADD) { return false; }
    SIRBinExprNode* sh_offset = offset->GetRHS();
    if (!sh_offset || !sh_offset->IsLeaf()
        || !SIRConstant::classof(sh_offset->GetValue())) { return false; }
    SIRBinExprNode* ns_offset = offset->GetLHS();
    if (!ns_offset ||(ns_offset->GetOpcode() != SIROpcode::SLL)){return false;}
    SIRBinExprNode* b = ns_offset->GetLHS();
    if (!b) { return false; }
    SIRBinExprNode* s = ns_offset->GetRHS();
    if (!s || !s->IsLeaf() || !SIRConstant::classof(s->GetValue())) {
      return false;
    }
    return true;
  }// if (func_->IsSolverKernel() && addrExpr_)
  return false;
}// IsShiftedStandardKernelForm()

// Try to transform the address to scalar_base + offset
static void
RotateBase(SIRBinExprNode*& expr) {
  static ExprHasScalarReg sregChk;
  if (!sregChk.CheckExpr(expr)) { return; }
  SIROpcode_t opc = expr->GetOpcode();
  if (opc != SIROpcode::ADD) { return; }
  if (expr->GetLHS()->IsLeaf()
      && SIRRegister::classof(expr->GetLHS()->GetValue())
      && !static_cast<SIRRegister*>(expr->GetLHS()->GetValue())->IsVector()) {
    return;
  }
  if (expr->GetRHS()->IsLeaf()
      && SIRRegister::classof(expr->GetRHS()->GetValue())
      && !static_cast<SIRRegister*>(expr->GetRHS()->GetValue())->IsVector()) {
    expr = SIRBinExprNode::Commute(expr);
    return;
  }
  if (!sregChk.CheckExpr(expr->GetLHS())) {
    // scalar reg is in RHS, move it to LHS
    expr = SIRBinExprNode::Commute(expr);
  }
  if (sregChk.CheckExpr(expr->GetLHS())) {
    RotateBase(expr->GetLHSRef());
    expr = SIRBinExprNode::RotateRight(expr);
  }// if (sregChk.CheckExpr(expr->GetLHS()))
}// RotateBase()

bool SIRMemLocation::
TransformToStandardForm() {
  if (IsStandardKernelForm()) { return true; }
  if (func_->IsSolverKernel() && addrExpr_) {
    RotateBase(addrExpr_);
    if (IsStandardKernelForm() || IsShiftedStandardKernelForm()) {
      scalarBaseReg_=static_cast<SIRRegister*>(addrExpr_->GetLHS()->GetValue());
      return IsStandardKernelForm();
    }
  }// if (func_->IsSolverKernel() && addrExpr_)
  return false;
}// TransformToStandardForm()

ostream& SIRMemLocation::
Print(ostream& o) const {
  o <<"A["<< addrSpace_ <<"] ";
  return addrExpr_ ? addrExpr_->Print(o) : o;
}// SIRMemLocation::Print()

std::ostream& ES_SIMD::
operator<<(std::ostream& o, const SIRMemLocation& t) { return t.Print(o); }
