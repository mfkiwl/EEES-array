#include "SIR/SIRFunction.hh"
#include "SIR/SIRLoop.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRRegister.hh"
#include "SIR/SIRExpr.hh"
#include "Utils/StringUtils.hh"
#include "Utils/DbgUtils.hh"
#include <stack>
#include <algorithm>

using namespace std;
using namespace ES_SIMD;


std::string SIRBasicBlock::
GetNormalizedBlockName(const SIRBasicBlock* bb) {
  return string("$"+bb->GetParent()->GetName()
                + "_BB"+Int2DecString(bb->GetBasicBlockID()));
}

SIRBasicBlock::
SIRBasicBlock(int bid, SIRFunction* parent)
  : SIRValue(SIRValue::VK_BasicBlock), bbID_(bid), parent_(parent),
    domParent_(NULL), pdomParent_(NULL), isEntryBlock_(false),
    isExitBlock_(false), hasBranch_(false), lastLoop_(NULL),
    targetData_(NULL) {
  SetDataType(SIRDataType::BasicBlock);
}

SIRBasicBlock::~SIRBasicBlock() {}

SIRInstruction& SIRBasicBlock::
BuildSIRInstr(SIRBasicBlock::iterator it, bool vect, SIROpcode_t opc,
              int value, const std::string& name) {
  SIRInstruction* instr = new SIRInstruction(opc, this, vect);
  if (value >= 0) {
    std::string p = SIRFunction::IsValidValueID(value) ? "w" :
      (SIRFunction::IsValidFlagID(value) ? "f" : "v");
    instr->SetValueID(value);
    instr->SetName(name.empty() ? ("w"+Int2DecString(value)) : name);
  } else { if (!name.empty()) { instr->SetName(name); } }
  insert(it, instr);
  return *instr;
}// BuildSIRInstr()

struct SIRExprCodeGen {
  SIRBasicBlock* bb_;
  vector<SIRValue*> ops_;
  vector<SIRBinExprNode*> nodeStack_;
  bool vect_;
  SIRInstruction* lastInstr_;
  SIRBasicBlock::iterator ip_;
  SIRExprCodeGen(SIRBasicBlock* bb, bool vect, SIRBasicBlock::iterator ip)
    : bb_(bb), vect_(vect), lastInstr_(NULL), ip_(ip) { ops_.reserve(2); }
  void operator()(SIRBinExprNode* n);
};// struct SIRExprCodeGen

SIRInstruction& SIRBasicBlock::
BuildSIRInstr(SIRBasicBlock::iterator it, bool vect, SIRBinExprNode* expr) {
  expr->Simplify();
  if (expr->IsLeaf()) {
    SIRInstruction* instr = new SIRInstruction (
      SIROpcode::MOV, this, expr->GetValue()->IsVectorValue());
    instr->AddOperand(expr->GetValue()).SetValueID(parent_->AllocateValue());
    insert(it, instr);
    return *instr;
  }
  SIRExprCodeGen exprCG(this, vect, it);
  ES_ASSERT_MSG(expr, "Invalid expression");
  expr->VisitNodesPreOrder(exprCG);
  return *exprCG.lastInstr_;
  // return *exprCG.InsertInstructions(it);
}// BuildSIRInstr()

SIRBasicBlock::iterator SIRBasicBlock::
TransferTo(SIRBasicBlock::iterator fIt, SIRBasicBlock* tbb,
           SIRBasicBlock::iterator tIt) {
  (*fIt)->GetParent()->RemoveChild(*fIt);
  (*fIt)->SetParent(tbb);
  tbb->insert(tIt, *fIt);
  return instrList_.erase(fIt);
}// TransferTo()

void SIRBasicBlock::
ReplaceInstrValue(SIRBasicBlock::iterator it, SIRInstruction* replacement) {
  if ((it == end()) || !replacement || ((*it)->GetValueID() < 0)
      || (*it == replacement)) { return; }
  SIRInstruction* instr = *it;
  SIRBasicBlock* rbb = replacement->GetParent();
  if (rbb != this) { ES_NOTIMPLEMENTED("Cross-block replacement"); }
  vector<SIRInstruction*> r;
  r.reserve(instr->use_size());
  for (SIRInstruction::use_iterator uIt = instr->use_begin();
       uIt != instr->use_end(); ++uIt) {
    if (SIRInstruction::classof(*uIt)) {
      r.push_back(static_cast<SIRInstruction*>(*uIt));
    } else { ES_NOTIMPLEMENTED("Replace non-instruction user"); }
  }
  if (InstrLiveOut(find(begin(), end(), instr))) {
    ES_NOTIMPLEMENTED("Cross-block replacement");
  }
  for (int i = 0, e=r.size(); i < e; ++i) {
    r[i]->ReplaceOperand(instr, replacement);
  }
}// ReplaceInstrValue()

bool SIRBasicBlock::
EqualsTo(const SIRValue* v) const {
  if (v && (v->GetUID() == GetUID())) { return true; }
  if (v && classof(v)) {
    const SIRBasicBlock* vb = static_cast<const SIRBasicBlock*>(v);
    return (vb->GetParent() == GetParent())
      && (vb->GetBasicBlockID() == GetBasicBlockID());
  }
  return false;
}// SIRBasicBlock

int SIRBasicBlock::
GetLoopDepth() const {
  return (lastLoop_ != NULL) ? lastLoop_->GetLoopDepth() : 0;
}

SIRRegister* SIRBasicBlock::
AddOrGetBlockRegister(int val, bool vect, const std::string& n) {
  if (!IsElementOf(val, blockRegs_)) {
    string name = n.empty() ? ("w"+Int2DecString(val)) : n;
    SIRRegister* r = new SIRRegister(vect, name, val, this);
    blockRegs_[val] = r;
    r->SetValueID(val);
    r->SetName(name);
    AddChild(r);
  }
  return GetValue(val, blockRegs_);
}// AddOrGetBlockRegister()

void SIRBasicBlock::
AddBlockRegister(SIRRegister* r) {
  if (r->GetValueID() >=0) { blockRegs_[r->GetValueID()] = r; }
  AddChild(r);
}

void SIRBasicBlock::
AddBlockPredicate(SIRValue* p) {
  push_back_uval(blockPredicates_, p);
  bool vect = p->IsVectorValue();
  iterator it = begin();
  if (SIRInstruction::classof(p)) {
    SIRInstruction* pi = static_cast<SIRInstruction*>(p);
    if (pi->GetParent() == this) { it = find(begin(), end(), pi); ++it; }
  }// if (SIRInstruction::classof(p))
  for (; it != end(); ++it) {
    if ((*it)->IsVectorInstr() == vect) { (*it)->AddPredicate(p); }
  }
}// AddBlockPredicate()

void SIRBasicBlock::
push_back(SIRInstruction* instr) {
  instrList_.push_back(instr);
  if (instr->GetSIROpcode() == SIROpcode::RET) { isExitBlock_ = true; }
  for (unsigned i = 0; i < blockPredicates_.size(); ++i) {
    if (instr->IsVectorInstr() == blockPredicates_[i]->IsVectorValue()) {
      instr->AddPredicate(blockPredicates_[i]);
    }
  }
  AddChild(instr);
  if (IsSIRBranch(instr->GetSIROpcode())
      || IsTargetBranch(instr->GetTargetOpcode())) {
    hasBranch_ = true;
  }
  if (instr->GetSIROpcode() == SIROpcode::CALL) {
    parent_->AddOrGetCallSite(instr);
  }
}// push_back()

void SIRBasicBlock::
pred_push_back(SIRBasicBlock* bb) {
  if (!bb) { return; }
  for (unsigned i = 0; i < pred_size(); ++i) {
    if (bb->GetBasicBlockID() == predecessors_[i]->GetBasicBlockID()){ return; }
  }
  predecessors_.push_back(bb);
}// pred_push_back()

void SIRBasicBlock::
pred_erase(SIRBasicBlock* bb) {
  for (pred_iterator it=predecessors_.begin(); it != predecessors_.end(); ++it){
    if (*it == bb) { predecessors_.erase(it); return; }
  }
}// pred_erase()

void SIRBasicBlock::
succ_push_back(SIRBasicBlock* bb) {
  if (!bb) { return; }
  for (unsigned i = 0; i < succ_size(); ++i) {
    if (bb->GetBasicBlockID() == successors_[i]->GetBasicBlockID()) { return; }
  }
  successors_.push_back(bb);
}// pred_push_back()

void SIRBasicBlock::
succ_erase(SIRBasicBlock* bb) {
  for (succ_iterator it=successors_.begin(); it != successors_.end(); ++it){
    if (*it == bb) { successors_.erase(it); return; }
  }
}// pred_erase()

SIRBasicBlock* SIRBasicBlock::
SplitBlock(SIRBasicBlock::iterator sp) {
  SIRBasicBlock *nxtBlk
    = new SIRBasicBlock(parent_->GetNewBasicBlockID(), parent_);
  // Transfer instructions to the new block
  for (SIRBasicBlock::iterator iIt = sp; iIt != end();) {
    iIt = TransferTo(iIt, nxtBlk, nxtBlk->end());
  }
  // Transfer live out values
  for (SIRBasicBlock::lo_iterator lIt = lo_begin(); lIt != lo_end(); ++lIt) {
    SIRRegister* v = *lIt;
    bool lo = false;
    for (SIRBasicBlock::succ_iterator sIt = succ_begin();
         sIt != succ_end();++sIt) {
      if ((*sIt)->IsValueLiveIn(v->GetValueID())) { lo = true; }
    }
    if (lo) {
      nxtBlk->AddLiveOutValue(v->IsVector(), v->GetName(), v->GetValueID());
    }
  }
  lo_clear();
  for (SIRBasicBlock::iterator iIt = nxtBlk->begin();
       iIt != nxtBlk->end(); ++iIt) {
    SIRInstruction* instr= *iIt;
    for (SIRInstruction::operand_iterator oIt = instr->operand_begin();
         oIt != instr->operand_end(); ++oIt) {
      if (SIRInstruction::classof(*oIt)) {
        SIRInstruction* oInstr = static_cast<SIRInstruction*>(*oIt);
        if (oInstr->GetParent() != nxtBlk) {
          SIRRegister* li = nxtBlk->AddOrGetLiveIn(
            parent_->IsSolverKernel(), oInstr->GetValueID());
          li->SetName(oInstr->GetName());
          instr->ChangeOperand(oIt, li);
        }
      }
    }
  }// for nxtBlk iterator iIt
  // Transfer control flow
  SIRValue* btgt = back()->GetBranchTarget();
  for (SIRBasicBlock::succ_iterator sIt = succ_begin();sIt != succ_end();++sIt){
    if (*sIt != btgt) {
      (*sIt)->ChangePredecessor(this, nxtBlk);
      nxtBlk->succ_push_back(*sIt);
    }
  }
  succ_clear();
  succ_push_back(nxtBlk);
  if (SIRBasicBlock* tblk = dynamic_cast<SIRBasicBlock*>(btgt)) {
    succ_push_back(tblk);
  }
  nxtBlk->pred_push_back(this);
  if (IsExitBlock()) {
    SetExitBlock(false);
    nxtBlk->SetExitBlock(true);
  }
  return nxtBlk;
}// SplitBlock()

void SIRBasicBlock::
AddLiveIn(SIRRegister* r) {
  int rid = r->GetUID();
  for (li_iterator it = liveIns_.begin(); it != liveIns_.end(); ++it) {
    if ((*it)->GetUID() == rid)
      return;
  }
  liveIns_.push_back(r);
  if (r->GetParent() == this) { AddChild(r); }
}// AddLiveIn()

void SIRBasicBlock::
AddLiveOut(SIRRegister* r) {
  int rid = r->GetUID();
  for (lo_iterator it = liveOuts_.begin(); it != liveOuts_.end(); ++it) {
    if ((*it)->GetUID() == rid)
      return;
  }
  liveOuts_.push_back(r);
  if (r->GetParent() == this) { AddChild(r); }
}// AddLiveOut()

void SIRBasicBlock::
AddLiveInValue (bool vect, const string& name, int v) {
  for (li_iterator it = liveIns_.begin(); it != liveIns_.end(); ++it) {
    if ((*it)->GetValueID() == v) { return; }
  }
  liveIns_.push_back(AddOrGetBlockRegister(v, vect, name));
}// AddLiveInValue()

void SIRBasicBlock::
AddLiveOutValue(bool vect, const string& name, int v) {
  for (lo_iterator it = liveOuts_.begin(); it != liveOuts_.end(); ++it) {
    if ((*it)->GetValueID() == v) { return; }
  }
  liveOuts_.push_back(AddOrGetBlockRegister(v, vect, name));
}// AddLiveOutValue()

SIRRegister* SIRBasicBlock::
AddOrGetLiveIn (bool vect, int v) {
  for (li_iterator it = liveIns_.begin(); it != liveIns_.end(); ++it) {
    if ((*it)->GetValueID() == v) { return *it; }
  }
  SIRRegister* r = AddOrGetBlockRegister(v, vect);
  liveIns_.push_back(r);
  return r;
}// AddOrGetLiveIn()

SIRRegister* SIRBasicBlock::
AddOrGetLiveOut (bool vect, int v) {
  for (lo_iterator it = liveOuts_.begin(); it != liveOuts_.end(); ++it) {
    if ((*it)->GetValueID() == v) { return *it; }
  }
  SIRRegister* r = AddOrGetBlockRegister(v, vect);
  liveOuts_.push_back(r);
  return r;
}// AddOrGetLiveOut()

void SIRBasicBlock::
ChangePredecessor(SIRBasicBlock* oldPred, SIRBasicBlock* newPred) {
  for (int i = 0, e = predecessors_.size(); i < e; ++i) {
    if (predecessors_[i] == oldPred) { predecessors_[i] = newPred; }
  }
}

void SIRBasicBlock::
ChangeSuccessor(SIRBasicBlock* oldSucc, SIRBasicBlock* newSucc) {
  for (int i = 0, e = successors_.size(); i < e; ++i) {
    if (successors_[i] == oldSucc) { successors_[i] = newSucc; }
  }
}

bool SIRBasicBlock::
IsSuccessor(const SIRBasicBlock* b) const {
  for (int i = 0, e = successors_.size(); i < e; ++i) {
    if (successors_[i] == b) { return true; }
  }
  return false;
}// IsSuccessor()


bool SIRBasicBlock::
IsPredecessor(const SIRBasicBlock* b) const {
  for (int i = 0, e = predecessors_.size(); i < e; ++i) {
    if (predecessors_[i] == b) { return true; }
  }
  return false;
}

bool SIRBasicBlock::
IsValueLiveIn(int v) const {
  for (li_const_iterator it = liveIns_.begin(); it != liveIns_.end(); ++it) {
    if ((*it)->GetValueID() == v) return true;
  }
  return false;
}// IsValueLiveIn()

bool SIRBasicBlock::
IsValueLiveOut(int v) const {
  for (lo_const_iterator it = liveOuts_.begin(); it != liveOuts_.end(); ++it) {
    if ((*it)->GetValueID() == v) return true;
  }
  return false;
}// IsValueLiveOut()

bool SIRBasicBlock::
InstrLiveOut(const SIRInstruction* instr) const {
  return InstrLiveOut(find(begin(), end(), instr));
}// InstrLiveOut()

bool SIRBasicBlock::
InstrLiveOut(const_iterator it) const {
  if ((it == end()) || !IsValueLiveOut((*it)->GetValueID())) { return false; }
  const int ival = (*it)->GetValueID();
  while (++it != end()) {
    if ((*it)->GetValueID() == ival) { return false; }
  }// while (it != end())
  return true;
}// IsInstrLiveOut()

bool SIRBasicBlock::
UsesValue(int v) const {
  for (const_iterator it = begin(); it != end(); ++it) {
    if((*it)->UsesValue(v)) { return true; }
  }
  return false;
}

void SIRBasicBlock::
AddIDomChild (SIRBasicBlock* b) {
  int bid = b->GetUID();
  for (unsigned i = 0; i < domChildren_.size(); ++i) {
    if (domChildren_[i]->GetUID() == bid) { return; }
  }
  domChildren_.push_back(b);
  b->domParent_ = this;
}// AddIDom()

void SIRBasicBlock::
AddIPDomChild (SIRBasicBlock* b) {
  int bid = b->GetUID();
  for (unsigned i = 0; i < pdomChildren_.size(); ++i) {
    if (pdomChildren_[i]->GetUID() == bid)
      return;
  }
  pdomChildren_.push_back(b);
  b->pdomParent_ = this;
}// AddIPDom()

bool SIRBasicBlock::
IsIDomChild (const SIRBasicBlock* b) const {
  int bid = b->GetUID();
  for (unsigned i = 0; i < domChildren_.size(); ++i) {
    if (domChildren_[i]->GetUID() == bid) { return true; }
  }
  return false;
}// IsIDom()

bool SIRBasicBlock::
IsIPDomChild (const SIRBasicBlock* b) const{
  int bid = b->GetUID();
  for (unsigned i = 0; i < pdomChildren_.size(); ++i) {
    if (pdomChildren_[i]->GetUID() == bid) { return true; }
  }
  return false;
}// IsIPDom()

bool SIRBasicBlock::
Dominates(const SIRBasicBlock* b) const {
  int bid = b->GetUID();
  if (bid == GetUID()) { return true; }
  for (unsigned i = 0; i < domChildren_.size(); ++i) {
    if ((domChildren_[i]->GetUID()==bid) || domChildren_[i]->Dominates(b)) {
      return true;
    }
  }
  return false;
}// Dominates()

bool SIRBasicBlock::
PostDominates(const SIRBasicBlock* b) const {
  int bid = b->GetUID();
  if (bid == GetUID()) { return true; }
  for (unsigned i = 0; i < pdomChildren_.size(); ++i) {
    if ((pdomChildren_[i]->GetUID()==bid)||pdomChildren_[i]->PostDominates(b)) {
      return true;
    }
  }
  return false;
}// PostDominates()

int SIRBasicBlock::
GetDomTreeDistance(const SIRBasicBlock* b) const {
  int bid = b->GetUID();
  if (bid == GetUID()) { return 0; }
  /// Basically a dfs in the sub-tree with this node as root
  for (int i=0, e=domChildren_.size(); i < e; ++i) {
    const SIRBasicBlock* dc = domChildren_[i];
    int chDist = dc->GetDomTreeDistance(b);
    if (chDist >=0) { return chDist + 1; }
  }// for i = 0 to domChildren_.size()-1
  return -1;
}// GetDomTreeDistance()

SIRBasicBlock::iterator SIRBasicBlock::
insert(iterator it, SIRInstruction* instr) {
  if (instr->GetSIROpcode() == SIROpcode::RET) { isExitBlock_ = true; }
  for (unsigned i = 0; i < blockPredicates_.size(); ++i) {
    if (instr->IsVectorInstr() == blockPredicates_[i]->IsVectorValue()) {
      instr->AddPredicate(blockPredicates_[i]);
    }
  }
  AddChild(instr);
  if (IsSIRBranch(instr->GetSIROpcode())
      || IsTargetBranch(instr->GetTargetOpcode())) {
    hasBranch_ = true;
  }
  return instrList_.insert(it, instr);
}// insert

SIRBasicBlock::iterator SIRBasicBlock::
erase(iterator pos) {
  for (SIRInstruction::operand_iterator it = (*pos)->operand_begin();
       it != (*pos)->operand_end(); ++it) { (*it)->RemoveUse(*pos); }
  for (unsigned i = 0, e = (*pos)->predicate_size(); i < e; ++i)
  { (*pos)->GetPredicate(i)->RemoveUse(*pos); }
  return instrList_.erase(pos);
}// erase()

void SIRBasicBlock::
SetLoop(SIRLoop* lp) {
  if (!lp) { lastLoop_ = lp; }
  if (!lastLoop_ || (lastLoop_->GetLoopDepth() < lp->GetLoopDepth()))
    lastLoop_ = lp;
}// SetLoop()

std::ostream& SIRBasicBlock::
SIRPrettyPrint(std::ostream& o) const {
  o <<"        # predecessors: ";
  for (pred_const_iterator it = pred_begin(); it != pred_end(); ++it) {
    o <<(*it)->GetBasicBlockID() <<", ";
  }
  o <<"\n        # successors  : ";
  for (succ_const_iterator it = succ_begin(); it != succ_end(); ++it) {
    o <<(*it)->GetBasicBlockID() <<", ";
  }
  o <<"\n        # live-ins ("<< li_size() <<"): ";
  for (li_const_iterator it = li_begin(); it != li_end(); ++it) {
    (*it)->SIRPrettyPrint(o); o <<", ";
  }
  o <<"\n        # live-outs ("<< lo_size() <<"): ";
  for (lo_const_iterator it = lo_begin(); it != lo_end(); ++it) {
    (*it)->SIRPrettyPrint(o); o <<", ";
  }
  o <<"\n";
  for (const_iterator it = begin(); it != end(); ++it) {
    const SIRInstruction* instr = *it;
    o <<"        ";
    instr->SIRPrettyPrint(o);
    o <<"\n";
  }
  return o;
}// SIRPrettyPrint()

std::ostream& SIRBasicBlock::
TargetPrettyPrint(std::ostream& o) const {
  o <<"        # predecessors: ";
  for (pred_const_iterator it = pred_begin(); it != pred_end(); ++it) {
    o <<(*it)->GetBasicBlockID() <<", ";
  }
  o <<"\n        # successors  : ";
  for (succ_const_iterator it = succ_begin(); it != succ_end(); ++it) {
    o <<(*it)->GetBasicBlockID() <<", ";
  }
  o <<"\n        # live-ins ("<< li_size() <<"): ";
  for (li_const_iterator it = li_begin(); it != li_end(); ++it) {
    (*it)->TargetPrettyPrint(o); o <<", ";
  }
  o <<"\n        # live-outs ("<< lo_size() <<"): ";
  for (lo_const_iterator it = lo_begin(); it != lo_end(); ++it) {
    (*it)->TargetPrettyPrint(o); o <<", ";
  }
  o <<"\n";
  for (const_iterator it = begin(); it != end(); ++it) {
    const SIRInstruction* instr = *it;
    o <<"        ";
    instr->TargetPrettyPrint(o);
    o <<"\n";
  }
  return o;
}// TargetPrettyPrint()

std::ostream& SIRBasicBlock::
ValuePrint(std::ostream& o) const {
  o <<"        # "<< parent_->GetName() <<".B"<< GetBasicBlockID() <<"\n";
  if (HasInfo()) {
    o <<"        # Info: "<< GetInfo()<<'\n';
  }
  o <<"        # predecessors: ";
  for (pred_const_iterator it = pred_begin(); it != pred_end(); ++it) {
    o <<(*it)->GetBasicBlockID() <<", ";
  }
  o <<"\n        # successors  : ";
  for (succ_const_iterator it = succ_begin(); it != succ_end(); ++it) {
    o <<(*it)->GetBasicBlockID() <<", ";
  }
  o <<"\n        # live-ins  ("<< li_size() <<"): ";
  for (li_const_iterator it = li_begin(); it != li_end(); ++it) {
    (*it)->ValuePrint(o); o <<", ";
  }
  o <<"\n        # live-outs ("<< lo_size() <<"): ";
  for (lo_const_iterator it = lo_begin(); it != lo_end(); ++it) {
    (*it)->ValuePrint(o); o <<", ";
  }
  o <<"\n";
  for (const_iterator it = begin(); it != end(); ++it) {
    const SIRInstruction* instr = *it;
    o <<"        ";
    instr->ValuePrint(o);
    o <<"\n";
  }
  return o;
}// ValuePrettyPrint()

std::ostream& SIRBasicBlock::
Print(std::ostream& o) const { return ValuePrint(o); }

void SIRBasicBlock::
Dump(Json::Value& info) const {
  info["bb_id"] = GetBasicBlockID();
  if (HasName()) { info["name"] = GetName(); }
  if(int l = GetLoopDepth()) {
    info["loop_depth"] = l;
    info["last_loop"]  = lastLoop_->GetLoopID();
  }
  for (pred_const_iterator it = pred_begin(); it != pred_end(); ++it) {
    info["predecessors"].append((*it)->GetBasicBlockID());
  }
  for (succ_const_iterator it = succ_begin(); it != succ_end(); ++it) {
    info["successors"].append((*it)->GetBasicBlockID());
  }
  for (li_const_iterator it = li_begin(); it != li_end(); ++it) {
    info["live_in"].append((*it)->GetValueID());
  }
  for (lo_const_iterator it = lo_begin(); it != lo_end(); ++it) {
    info["live_out"].append((*it)->GetValueID());
  }
}// Dump

void SIRExprCodeGen::
operator()(SIRBinExprNode* n) {
  ES_ASSERT_MSG(n, "Invalid expression node");
  if (n->IsLeaf()) {
    ops_.push_back(n->GetValue());
    while (ops_.size() >= 2) {
      ES_ASSERT_MSG(!nodeStack_.empty(), "Invalid expression");
      SIRValue* lhs = ops_[ops_.size()-2];
      SIRValue* rhs = ops_[ops_.size()-1];
      bool lVec = lhs->IsVectorValue(), rVec = rhs->IsVectorValue();
      SIROpcode_t opc = nodeStack_.back()->GetOpcode();
      if (lVec && !rVec && IsSIRCommutativeOp(opc)) { swap(lhs, rhs); }
      nodeStack_.pop_back();
      lastInstr_ = new SIRInstruction(opc, bb_, lVec||rVec);
      lastInstr_->AddOperand(lhs).AddOperand(rhs)
        .SetValueID(bb_->GetParent()->AllocateValue());
      ops_.pop_back();
      ops_.pop_back();
      ops_.push_back(lastInstr_);
      bb_->insert(ip_, lastInstr_);
    }// while (ops_.size() >= 2)
  } else { nodeStack_.push_back(n); }
}// SIRExprCodeGen::operator()()
