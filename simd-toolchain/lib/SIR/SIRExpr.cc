#include "SIR/SIRExpr.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRConstant.hh"
#include "SIR/SIRRegister.hh"
#include "SIR/SIRModule.hh"
#include "Utils/BitUtils.hh"
#include "Utils/DbgUtils.hh"
#include <sstream>

using namespace std;
using namespace ES_SIMD;

void SIRBinExprNode::
SetSIRBinExprNode(SIRBinExprNode* root, SIRBinExprNode* lhs, SIRBinExprNode* rhs) {
  ES_ASSERT_MSG(root, "Invalid root node");
  root->lhs_ = lhs;
  root->rhs_ = rhs;
  if (lhs) { lhs->parent_ = root; }
  if (rhs) { rhs->parent_ = root; }
}

SIRBinExprNode* SIRBinExprNode::
CreateBinExprNode(SIRValue* val) {
  if (SIRInstruction::classof(val)) {
    SIRInstruction* instr = static_cast<SIRInstruction*>(val);
    SIROpcode_t opc = instr->GetSIROpcode();
    if (opc == SIROpcode::MOV) {
      return CreateBinExprNode(instr->GetOperand(0));
    }// if (expr->opcode_ == SIROpcode::MOV)
    ES_ASSERT_MSG(GetSIROpNumInput(opc)==2,
                  "Cannot create address expression with opcode "<< opc);
    SIRModule* m = instr->GetParent()->GetParent()->GetParent();
    SIRBinExprNode* expr = new SIRBinExprNode(m, opc);
    m->AddBinExprNode(expr);
    SetSIRBinExprNode(expr, CreateBinExprNode(instr->GetOperand(0)),
                      CreateBinExprNode(instr->GetOperand(1)));
    return expr;
  } else {// if (SIRInstruction::classof(val))
    SIRBinExprNode* expr = new SIRBinExprNode(val);
    SIRModule::GetSIRModule(val)->AddBinExprNode(expr);
    return expr;
  }
  return NULL;
}// CreateBinExprNode()

SIRBinExprNode* SIRBinExprNode::
CreateBinExprNode(SIRModule* m, SIROpcode_t opc, SIRBinExprNode* lhs,
                  SIRBinExprNode* rhs, SIRValue* val) {
  SIRBinExprNode* expr = new SIRBinExprNode(m, opc, lhs, rhs, val);
  m->AddBinExprNode(expr);
  return expr;
}

SIRBinExprNode* SIRBinExprNode::
CreateBinExprNode(SIRBinExprNode* e) {
  SIRBinExprNode* expr = new SIRBinExprNode(*e);
  e->GetModule()->AddBinExprNode(expr);
  return expr;
}

SIRBinExprNode::
SIRBinExprNode(SIRValue* val, SIROpcode_t opc)
  : value_(val), lhs_(NULL), rhs_(NULL), parent_(NULL), opcode_(opc),
    module_(SIRModule::GetSIRModule(val)) {}

SIRBinExprNode::
SIRBinExprNode(const SIRBinExprNode& t) {
  parent_ = NULL;
  module_ = t.module_;
  opcode_ = t.opcode_;
  value_  = t.value_;
  lhs_    = t.lhs_ ? new SIRBinExprNode(*t.lhs_) : NULL;
  rhs_    = t.rhs_ ? new SIRBinExprNode(*t.rhs_) : NULL;
  if (lhs_) { lhs_->parent_ = this; module_->AddBinExprNode(lhs_);}
  if (rhs_) { rhs_->parent_ = this; module_->AddBinExprNode(rhs_);}
}// SIRBinExprNode()

SIRBinExprNode& SIRBinExprNode::
operator=(const SIRBinExprNode& t) {
  parent_ = NULL;
  opcode_ = t.opcode_;
  value_  = t.value_;
  lhs_    = t.lhs_ ? new SIRBinExprNode(*t.lhs_) : NULL;
  rhs_    = t.rhs_ ? new SIRBinExprNode(*t.rhs_) : NULL;
  if (lhs_) { lhs_->parent_ = this; module_->AddBinExprNode(lhs_); }
  if (rhs_) { rhs_->parent_ = this; module_->AddBinExprNode(rhs_); }
  return *this;
}// operator=()

SIRBinExprNode::
~SIRBinExprNode() {}

void SIRBinExprNode::
SetNode(SIROpcode_t opc,SIRBinExprNode* lhs,SIRBinExprNode* rhs,SIRValue* val) {
  opcode_ = opc;
  value_  = val;
  lhs_ = lhs;
  if (lhs) { lhs->parent_ = this; }
  rhs_ = rhs;
  if (rhs) { rhs->parent_ = this; }
}

bool SIRBinExprNode::
IsScalar() const {
  if (IsLeaf()) {
    switch (value_->getKind()) {
    case SIRValue::VK_Constant: return true;
    case SIRValue::VK_Register:
      return !static_cast<SIRRegister*>(value_)->IsVector();
    default: ES_UNREACHABLE("Invalid leaf value type"<< value_->getKindName());
    }
  } else { return (!lhs_ || lhs_->IsScalar()) && (!rhs_ || rhs_->IsScalar()); }
}

bool SIRBinExprNode::
Valid() const {
  if (!IsLeaf()) {
    if (!lhs_ || !rhs_) { return false; }
    if ((lhs_->parent_ != this) || (rhs_->parent_ != this)) { return false; }
    if (value_ && (opcode_ != SIROpcode::NOP)) { return false; }
    return lhs_->Valid() && rhs_->Valid();
  }
  return (opcode_ == SIROpcode::NOP) && value_;
}// Valid()

bool SIRBinExprNode::
operator==(const SIRBinExprNode& t) const {
  if (t.IsLeaf() && IsLeaf()) {
    ES_ASSERT_MSG(value_ && t.value_, "Invalid node");
    return (t.opcode_ == opcode_) && (*t.value_ == *value_);
  } else if (t.opcode_ == opcode_) {
    bool leq = false, req = false;
    if (lhs_ && t.lhs_ && (*lhs_ == *t.lhs_)) { leq = true; }
    else if (!lhs_ && !t.lhs_)                { leq = true; }
    if (rhs_ && t.rhs_ && (*rhs_ == *t.rhs_)) { req = true; }
    else if (!rhs_ && !t.rhs_)                { req = true; }
    if (leq && req) { return true; }

    if (!IsSIRCommutativeOp(opcode_)) { return false; }

    leq = req = false;
    if (lhs_ && t.rhs_ && (*lhs_ == *t.rhs_)) { leq = true; }
    else if (!lhs_ && !t.rhs_)                { leq = true; }
    if (rhs_ && t.lhs_ && (*rhs_ == *t.lhs_)) { req = true; }
    else if (!rhs_ && !t.lhs_)                { req = true; }
    if (leq && req) { return true; }
  }// if (t.opcode_ == opcode_)
  return false;
}// operator==()

bool SIRBinExprNode::
IsConstant() const {
  return IsLeaf() && value_ && SIRConstant::classof(value_);
}// IsConstant()

int SIRBinExprNode::
GetConstant() const {
  return IsConstant() ? static_cast<SIRConstant*>(value_)->GetImmediate() : 0;
}

bool SIRBinExprNode::
ValueEqual(const SIRValue* v) const {
  return IsLeaf() && value_->ValueEqual(v);
}// ValueEqual()

bool SIRBinExprNode::
ConstantEqual(int c) const {
  return IsConstant() && (static_cast<SIRConstant*>(value_)->GetImmediate()==c);
}// ConstantEqual()

bool SIRBinExprNode::
UsesValue(int val) const {
  if (value_ && (value_->GetValueID() == val)) { return true; }
  return (lhs_ && lhs_->UsesValue(val)) || (rhs_ && rhs_->UsesValue(val));
}// UsesValue()

bool SIRBinExprNode::
UsesValue(SIRValue* val) const {
  if (value_ && (value_->GetUID() == val->GetUID())) { return true; }
  return (lhs_ && lhs_->UsesValue(val)) || (rhs_ && rhs_->UsesValue(val));
}// UsesValue()

SIRBinExprNode* SIRBinExprNode::
Simplify() {
  if (IsLeaf()) { return this; }
  if (lhs_ && !lhs_->IsLeaf()) { lhs_->Simplify(); }
  if (rhs_ && !rhs_->IsLeaf()) { rhs_->Simplify(); }
  if (lhs_ && lhs_->IsConstant() && rhs_ && rhs_->IsConstant()) {
    int lv = static_cast<SIRConstant*>(lhs_->GetValue())->GetImmediate();
    int rv = static_cast<SIRConstant*>(rhs_->GetValue())->GetImmediate();
    int ov = 0;
    switch(opcode_) {
    default: break;
    case SIROpcode::ADD: ov = lv +  rv; break;
    case SIROpcode::SUB: ov = lv -  rv; break;
    case SIROpcode::MUL: ov = lv *  rv; break;
    case SIROpcode::DIV: ov = lv /  rv; break;
    case SIROpcode::SLL: ov = lv << rv; break;
    case SIROpcode::SRA: ov = lv >> rv; break;
    case SIROpcode::SRL:
      ov = static_cast<unsigned>(lv) + static_cast<unsigned>(rv);
      break;
    }
    SetValue(module_->AddOrGetImmediate(ov));
  } else if (opcode_ == SIROpcode::SUB) {
    // X - X = 0
    if (*lhs_ == *rhs_) { SetValue(module_->AddOrGetImmediate(0)); }
    else if (lhs_->opcode_ == SIROpcode::ADD) {
      // (A+B)-A = B or (A+B)-B = A
      if (*rhs_ == *lhs_->lhs_)      { *this = *lhs_->rhs_; }
      else if (*rhs_ == *lhs_->rhs_) { *this = *lhs_->lhs_; }
    }
    // X - 0 = 0
    else if (rhs_->IsConstant() && (rhs_->GetConstant() == 0)) { *this = *lhs_; }
  } else if (opcode_ == SIROpcode::ADD) {
    // X + 0 = X
    if (rhs_->IsConstant() && (rhs_->GetConstant() == 0))      { *this=*lhs_; }
    else if (lhs_->IsConstant() && (lhs_->GetConstant() == 0)) { *this=*rhs_; }
    else if (*lhs_ == *rhs_) {
      SetNode(SIROpcode::SLL, lhs_,
              CreateBinExprNode(module_->AddOrGetImmediate(1)));
    } else if (lhs_->opcode_ == SIROpcode::SUB) {
      // (A-B)+B = A
      if (*lhs_->rhs_ == *rhs_) { *this = *lhs_->lhs_; }
    } else if (rhs_->opcode_ == SIROpcode::SUB) {
      // B+(A-B) = A
      if (*rhs_->rhs_ == *lhs_) { *this = *rhs_->lhs_; }
    }
  } else if (opcode_ == SIROpcode::MUL) {
    if (lhs_->IsConstant() || rhs_->IsConstant()) {
      int m = lhs_->IsConstant() ? lhs_->GetConstant() : rhs_->GetConstant();
      // X * 0 = 0
      if (!m) { SetValue(module_->AddOrGetImmediate(0)); }
      // X * 1 = X
      else if (m == 1) { *this = *(lhs_->IsConstant() ? rhs_ : lhs_); }
      // else if (m%2 == 0) {
      //   SIRBinExprNode* o = lhs_->IsConstant() ? rhs_ : lhs_;
      //   SetNode(SIROpcode::SLL, o,
      //           CreateBinExprNode(module_->AddOrGetImmediate(HighestBitSet(m))));
      // }
    }// if (lhs_->IsConstant() || rhs_->IsConstant())
  } else if (opcode_ == SIROpcode::SLL) {
    if ((lhs_->opcode_ == SIROpcode::SLL)
        && lhs_-rhs_->IsConstant() && rhs_->IsConstant()) {
      int s = lhs_->rhs_->GetConstant() + rhs_->GetConstant();
      *lhs_ = *lhs_->lhs_;
      rhs_->SetValue(module_->AddOrGetImmediate(s));
    }
  } else if (opcode_ == SIROpcode::DIV) {
    if (rhs_->IsConstant() ) {
      int d = rhs_->GetConstant();
      ES_ASSERT_MSG(d, "Divided by 0");
      /// X / 1 = X
      if (d == 1) { *this = *lhs_; }
      // else if (d % 2 == 0) {
      //   SetNode(SIROpcode::SRA, lhs_,
      //           CreateBinExprNode(module_->AddOrGetImmediate(HighestBitSet(d))));
      // }
    } else if (lhs_->opcode_ == SIROpcode::MUL) {
      if (*lhs_->rhs_ == *rhs_) { *this = *lhs_; }
    }// if (lhs_->opcode_ == SIROpcode::MUL)
  }// if (opcode_ == SIROpcode::DIV)
  return this;
}// Simplify ()

////////////////////////////////////////////////////////////////////////////////
///                    Static transformation methods
////////////////////////////////////////////////////////////////////////////////
SIRBinExprNode* SIRBinExprNode::
Commute(SIRBinExprNode* t) {
  if (IsSIRCommutativeOp(t->opcode_)) {
    std::swap(t->lhs_, t->rhs_);
  }
  return t;
}// Commute()

/// Try to perform the following transformation:
/*                           */
/*       t              r    */ 
/*      / \            / \   */ 
/*     l   r    =>    t   rr */ 
/*        / \        / \     */ 
/*      rl   rr     l   rl   */ 
/*                           */
/// Currently we impose the following constraints:
/// 1. T and R have the same precedence
/// 2. T and R are both associative
SIRBinExprNode* SIRBinExprNode::
RotateLeft(SIRBinExprNode* t) {
  SIRBinExprNode* l = t->GetLHS();
  SIRBinExprNode* r = t->GetRHS();
  if (!l || !r) { return t; }
  if ((GetSIRPrecedence(t->opcode_) == GetSIRPrecedence(r->opcode_))
      && IsSIRAssociativeOp(t->opcode_) && IsSIRAssociativeOp(r->opcode_)) {
    SIRBinExprNode* rl = r->GetLHS();
    SIRBinExprNode* rr = r->GetRHS();
    r->parent_ = t->parent_;
    SetSIRBinExprNode(t, l, rl);
    SetSIRBinExprNode(r, t, rr);
    return r;
  }
  return t;
}// RotateLeft()

/// Mirror operation of RotateLeft()
SIRBinExprNode* SIRBinExprNode::
RotateRight(SIRBinExprNode* t) {
  SIRBinExprNode* l = t->GetLHS();
  SIRBinExprNode* r = t->GetRHS();
  if (!l || !r) { return t; }
  if ((GetSIRPrecedence(t->opcode_) == GetSIRPrecedence(l->opcode_))
      && IsSIRAssociativeOp(t->opcode_) && IsSIRAssociativeOp(l->opcode_)) {
    SIRBinExprNode* ll = l->GetLHS();
    SIRBinExprNode* lr = l->GetRHS();
    l->parent_ = t->parent_;
    SetSIRBinExprNode(l, ll, t);
    SetSIRBinExprNode(t, lr, r);
    return l;
  }
  return t;
}// RotateRight()

/// Try to perform the following transformation:
/*                                 */
/*       t               t         */ 
/*      / \            /    \      */ 
/*     l   r    =>    r      rn    */ 
/*        / \        / \    /  \   */ 
/*      rl   rr     l  rl  ln   rr */ 
SIRBinExprNode* SIRBinExprNode::
DistributeLeft(SIRBinExprNode* t) {
  SIRBinExprNode *l = t->GetLHS(), *r = t->GetRHS();
  if (IsSIRLeftDistributiveOp(t->opcode_) && r && !r->IsLeaf()
      && (GetSIRPrecedence(t->opcode_) < GetSIRPrecedence(r->opcode_))) {
    swap(t->opcode_, r->opcode_);
    SIRBinExprNode* rl = r->GetLHS();
    SIRBinExprNode* rr = r->GetRHS();
    SIRBinExprNode* rn = new SIRBinExprNode(t->GetModule(), r->GetOpcode());
    SIRBinExprNode* ln = new SIRBinExprNode(*l);
    t->GetModule()->AddBinExprNode(rn);
    t->GetModule()->AddBinExprNode(ln);
    SetSIRBinExprNode(t,  r,  rn);
    SetSIRBinExprNode(r,  l,  rl);
    SetSIRBinExprNode(rn, ln, rr);
  }// if (l && IsSIRLeftDistributiveOp(l->opcode_) && r && r->Leaf())
  return t;
}// DistributeLeft()

/// Mirror operation of DistributeLeft()
SIRBinExprNode* SIRBinExprNode::
DistributeRight(SIRBinExprNode* t) {
  SIRBinExprNode *l = t->GetLHS(), *r = t->GetRHS();
  if (IsSIRRightDistributiveOp(t->opcode_) && l && !l->IsLeaf()
      && (GetSIRPrecedence(t->opcode_) < GetSIRPrecedence(l->opcode_))) {
    swap(t->opcode_, l->opcode_);
    SIRBinExprNode* ll = l->GetLHS();
    SIRBinExprNode* lr = l->GetRHS();
    SIRBinExprNode* ln = new SIRBinExprNode(t->GetModule(), l->GetOpcode());
    SIRBinExprNode* rn = new SIRBinExprNode(*r);
    t->GetModule()->AddBinExprNode(rn);
    t->GetModule()->AddBinExprNode(ln);
    SetSIRBinExprNode(t,  l,  ln);
    SetSIRBinExprNode(l,  ll, r);
    SetSIRBinExprNode(ln, lr, rn);
  }// if (l && IsSIRLeftDistributiveOp(l->opcode_) && r && r->Leaf())
  return t;
}// DistributeRight()

/// Try to perform the following transformation:
/*                                  */
/*          t               t       */ 
/*        /    \           / \      */ 
/*       r      rn   =>   l   r     */ 
/*      / \    /  \          / \    */ 
/*     l  rl  ln  rr       rl   rr  */ 
SIRBinExprNode* SIRBinExprNode::
ExtractLeft(SIRBinExprNode* t) {
  SIRBinExprNode *r  = t->GetLHS(), *rn = t->GetRHS();
  if (r && rn && (r->opcode_ == rn->opcode_)
      && IsSIRLeftDistributiveOp(r->opcode_)
      && (GetSIRPrecedence(r->opcode_) <= GetSIRPrecedence(t->opcode_))) {
    SIRBinExprNode *l  = r->GetLHS(),  *rl = r->GetRHS();
    SIRBinExprNode *ln = rn->GetLHS(), *rr = rn->GetRHS();
    if (*l == *ln) {
      swap(t->opcode_, r->opcode_);
      SetSIRBinExprNode(t, l, r);
      SetSIRBinExprNode(r, rl, rr);
      rn->lhs_ = rn->rhs_ = NULL;
    }// if (*l == *ln)
  }
  return t;
}// ExtractLeft()

/// Mirror operation of ExtractLeft()
SIRBinExprNode* SIRBinExprNode::
ExtractRight(SIRBinExprNode* t) {
  SIRBinExprNode *l  = t->GetLHS(), *ln = t->GetRHS();
  if (l && ln && (l->opcode_ == ln->opcode_)
      && IsSIRRightDistributiveOp(l->opcode_)
      && (GetSIRPrecedence(l->opcode_) <= GetSIRPrecedence(t->opcode_))) {
    SIRBinExprNode *ll = l->GetLHS(),  *r  = l->GetRHS();
    SIRBinExprNode *lr = ln->GetLHS(), *rn = ln->GetRHS();
    if (*r == *rn) {
      swap(t->opcode_, l->opcode_);
      SetSIRBinExprNode(t, l, r);
      SetSIRBinExprNode(l, ll, lr);
      ln->lhs_ = ln->rhs_ = NULL;
    }// if (*l == *ln)
  }
  return t;
}// ExtractRight()

ostream& SIRBinExprNode::
Print(ostream& o) const {
  if (IsLeaf()) {
    if (value_) { o << *value_; }
    return o;
  }
  if (lhs_) {
    if (!lhs_->IsLeaf()) { o <<"(" << *lhs_ <<")"; }
    else { o << *lhs_; }
  }
  switch (opcode_) {
  case SIROpcode::ADD : o <<" + " ; break;
  case SIROpcode::SUB : o <<" - " ; break;
  case SIROpcode::SLL : o <<" << "; break;
  case SIROpcode::SRA :
  case SIROpcode::SRL : o <<" >> "; break;
  case SIROpcode::MULU:
  case SIROpcode::MUL : o <<" * " ; break;
  case SIROpcode::DIV : o <<" / " ; break;
  default: o <<" "<< opcode_<<" " ; break;
  }
  if (rhs_) {
    if (!rhs_->IsLeaf()) { o <<"(" << *rhs_ <<")"; }
    else { o << *rhs_; }
  }
  return o;
}// SIRBinExprNode::Print()

string SIRBinExprNode::
GetString() const {
  stringstream ss;
  Print(ss);
  return ss.str();
}// GetString()

ostream& ES_SIMD::
operator<<(ostream& o, const SIRBinExprNode& t) {
  return t.Print(o);
}
