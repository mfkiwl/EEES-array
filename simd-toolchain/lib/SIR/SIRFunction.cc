#include "SIR/SIRModule.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRLoop.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRRegister.hh"
#include "SIR/SIRDataObject.hh"
#include "SIR/SIRKernel.hh"
#include "Utils/DbgUtils.hh"
#include "Utils/StringUtils.hh"

using namespace std;
using namespace ES_SIMD;

static ImmediateReader iRD;

bool SIRCallSite::
IsArgument(int v) const {
  for (unsigned i = 0, e = arg_size(); i < e; ++i) {
    if (arguments_[i]->GetValueID() == v) { return true; }
  }
  return false;
}// IsArgument()

bool SIRCallSite::
IsArgument(const SIRValue* v) const {
  return v ? IsArgument(v->GetValueID()) : false;
}// IsArgument()

int SIRCallSite::
GetArgumentID(const SIRValue* v) const {
  if (!v) { return -1; }
  int val = v->GetValueID();
  for (unsigned i = 0, e = arg_size(); i < e; ++i) {
    if (arguments_[i]->GetValueID() == val) { return i; }
  }
  return -1;
}// IsArgument()

SIRFunction::
SIRFunction(const std::string& name, SIRModule* parent)
  : SIRValue(name, SIRValue::VK_Function),
    solverKernel_(NULL), parent_(parent), entryBlock_(NULL),
    stackPointer_ (new SIRRegister(false, "SP", this)),
    framePointer_ (new SIRRegister(false, "FP", this)),
    globalPointer_(new SIRRegister(false, "GP", this)),
    linkRegister_ (new SIRRegister(false, "RA", this)),
    zeroRegister_ (new SIRRegister(false, "ZERO", ZERO_REG_VALUE, this)),
    numPERegister_(new SIRRegister(true,  "NUMPE", PEID_REG_VALUE, this)),
    peIDRegister_ (new SIRRegister(true,  "PEID", NUMPE_REG_VALUE, this)),
    valueCounter_(0), flagCounter_(FLAG_VALUE_BASE), basicBlockCounter_(0),
    numFormalArgs_(0), sirStackOffset_(0), targetData_(NULL) {
  SetDataType(SIRDataType::Function);
  parent_->AddFunction(this);
  AddChild(stackPointer_ );
  AddChild(framePointer_ );
  AddChild(globalPointer_);
  AddChild(linkRegister_ );
  AddChild(zeroRegister_ );
  AddChild(numPERegister_);
  AddChild(peIDRegister_ );
}// SIRFunction()

SIRFunction::
~SIRFunction() {
  for (std::vector<SIRCallSite*>::iterator it = callSites_.begin();
       it != callSites_.end(); ++it) {
    delete *it;
  }
}// ~SIRFunction()

int SIRFunction::
GetMaxBasicBlockID() const {
  int bid = -1;
  for (const_iterator it = begin(); it != end(); ++it) {
    bid = max(bid, (*it)->GetBasicBlockID());
  }
  return bid;
}

void SIRFunction::
AddMemoryAliasPair(SIRInstruction* a, SIRInstruction* b, bool alias) {
  int aid = a->GetMemoryLocationID(), bid = b->GetMemoryLocationID();
  size_t tsz = memoryAliasTable_.size();
  if (aid <= 0) { aid = tsz++; }
  if (bid <= 0) { bid = tsz++; }
  if ( tsz != memoryAliasTable_.size()) {
    memoryAliasTable_.resize(tsz);
    for (int i = 0, e = memoryAliasTable_.size(); i < e; ++i) {
      memoryAliasTable_[i].resize(tsz);
    }
  }// if ( tsz != memoryAliasTable_.size())
  memoryAliasTable_[aid][bid] = alias;
  memoryAliasTable_[bid][aid] = alias;
}// AddMemoryAliasPair()

void SIRFunction::
SetSolverKernel(SIRKernel* k) {
  solverKernel_ = k;
  AddChild(k);
}

bool SIRFunction::
UsesFramePointer() const { return !framePointer_->use_empty(); }

bool SIRFunction::
UsesGlobalPointer() const { return !globalPointer_->use_empty(); }

bool SIRFunction::
IsInvariant(const SIRValue* v) const {
  for (unsigned i = 0; i < arguments_.size(); ++i) {
    if (v->EqualsTo(arguments_[i])) { return true; }
  }
  return false;
}

void SIRFunction::
push_back(SIRBasicBlock* bb) {
  ES_ASSERT_MSG(!IsElementOf(bb->GetBasicBlockID(), blockMap_),
                "Duplicate basic block ID");
  basicBlockList_.push_back(bb);
  blockMap_[bb->GetBasicBlockID()] = bb;
  basicBlockCounter_ = max(basicBlockCounter_,
                           static_cast<unsigned>(bb->GetBasicBlockID())+1);
  AddChild(bb);
}// push_back()

void SIRFunction::
push_front(SIRBasicBlock* bb) {
  ES_ASSERT_MSG(!IsElementOf(bb->GetBasicBlockID(), blockMap_),
                "Duplicate basic block ID");
  basicBlockList_.push_front(bb);
  blockMap_[bb->GetBasicBlockID()] = bb;
  basicBlockCounter_ = max(basicBlockCounter_,
                           static_cast<unsigned>(bb->GetBasicBlockID())+1);
  AddChild(bb);
}// push_front()

SIRFunction::iterator SIRFunction::
insert(iterator it, SIRBasicBlock* bb) {
  ES_ASSERT_MSG(!IsElementOf(bb->GetBasicBlockID(), blockMap_),
                "Duplicate basic block ID");
  blockMap_[bb->GetBasicBlockID()] = bb;
  basicBlockCounter_ = max(basicBlockCounter_,
                           static_cast<unsigned>(bb->GetBasicBlockID())+1);
  AddChild(bb);
  return basicBlockList_.insert(it, bb);
}// insert()

void SIRFunction::
SetEntryBlock(SIRBasicBlock* bb) {
  ES_ASSERT_MSG(bb && (bb->GetParent()==this), "Invalid entry block");
  if (entryBlock_) { entryBlock_->SetEntryBlock(false); }
  entryBlock_ = bb;
  bb->SetEntryBlock(true);
}// SetEntryBlock()

bool SIRFunction::
IsSpecialRegister(int v) const {
  return (v==stackPointer_->GetValueID()) || (v==framePointer_->GetValueID())
    || (v==globalPointer_->GetValueID())  || (v==linkRegister_->GetValueID())
    || (v==zeroRegister_->GetValueID())   || (v==peIDRegister_->GetValueID())
    || (v==numPERegister_->GetValueID())
    || (solverKernel_ && solverKernel_->IsSpecialRegister(v));
}// IsSpecialRegister()

SIRRegister* SIRFunction::
GetSpecialRegister(const std::string& reg)  const {
  if (reg == "SP")         { return stackPointer_;  }
  else if (reg == "FP")    { return framePointer_;  }
  else if (reg == "GP")    { return globalPointer_; }
  else if (reg == "RA")    { return linkRegister_;  }
  else if (reg == "ZERO")  { return zeroRegister_;  }
  else if (reg == "PEID")  { return peIDRegister_;  }
  else if (reg == "NUMPE") { return numPERegister_; }
  else if (solverKernel_)  { return solverKernel_->GetSpecialRegister(reg); }
  return NULL;
}// GetSpecialRegister()

SIRRegister* SIRFunction::
AddOrGetReturnValue(const std::string& rv) {
  static ImmediateReader rd;
  if ((rv.size() < 2) || rv[0] != 'v') { return NULL; }
  int ridx = rd.GetIntImmediate(rv.substr(1));
  if (rd.error_ || (ridx < 0)) { return NULL; }
  if (static_cast<size_t>(ridx) >= returnValues_.size()) {
    returnValues_.resize(ridx+1, NULL);
  }
  if (!returnValues_[ridx]) {
    returnValues_[ridx] = new SIRRegister(false, rv, this);
    AddChild(returnValues_[ridx]);
  }
  return returnValues_[ridx];
}// AddOrGetReturnValue()

SIRRegister* SIRFunction::
GetReturnValue(const std::string& r) {
  for (unsigned i = 0; i < returnValues_.size(); ++i) {
    if (returnValues_[i] && (returnValues_[i]->GetName() == r)){
      return returnValues_[i];
    }
  }
  return NULL;
}

SIRRegister* SIRFunction::
GetReturnValue(unsigned i) const {
  return (i < returnValues_.size()) ? returnValues_[i] : NULL;
}// GetReturnValue()

SIRRegister* SIRFunction::
AddOrGetArgument(const string& name) {
  for (unsigned i = 0; i < arguments_.size(); ++i) {
    if (arguments_[i]->GetName() == name)
      return arguments_[i];
  }
  SIRRegister* v = new SIRRegister(false, name, this);
  arguments_.push_back(v);
  AddChild(v);
  return v;
}// AddOrGetArgument()

SIRRegister* SIRFunction::
GetArgument(const std::string& name) const {
  for (unsigned i = 0; i < arguments_.size(); ++i) {
    if (arguments_[i]->GetName() == name) { return arguments_[i]; }
  }
  return NULL;
}// GetArgument()

SIRRegister* SIRFunction::
GetArgumentFromValue(int v) const {
  for (unsigned i = 0; i < arguments_.size(); ++i) {
    if (arguments_[i]->GetValueID() == v) { return arguments_[i]; }
  }
  return NULL;
}

bool SIRFunction::
IsArgumentValue(int v) const {
  for (unsigned i = 0; i < arguments_.size(); ++i) {
    if (arguments_[i]->GetValueID() == v) { return true; }
  }
  return false;
}// IsArgumentValue()

int SIRFunction::
GetArgPointerAddrSpace(int v) const {
  for (unsigned i = 0; i < arguments_.size(); ++i) {
    if (arguments_[i]->GetValueID() == v) {
      int idx = iRD.GetIntImmediate(arguments_[i]->GetName().substr(1));
      if (IsElementOf(idx, argAddrSpace_)){return GetValue(idx, argAddrSpace_);}
    }
  }
  return -1;
}// GetArgPointerAddrSpace ()

SIRCallSite* SIRFunction::
AddOrGetCallSite(SIRInstruction* caller) {
  ES_ASSERT_MSG(
    caller && (caller->GetSIROpcode() == SIROpcode::CALL) && caller->GetParent()
    && (caller->GetParent()->GetParent() == this), "Illegal call");
  for (unsigned i = 0; i < callSites_.size(); ++i) {
    if (callSites_[i]->GetCallerInstr()->GetUID() == caller->GetUID()) {
      return callSites_[i];
    }
  }
  callSites_.push_back(new SIRCallSite(caller));
  return callSites_.back();
}// AddOrGetCallSite()

SIRCallSite* SIRFunction::
GetCallSite(const SIRInstruction* caller) const {
  for (unsigned i = 0; i < callSites_.size(); ++i) {
    if (callSites_[i]->GetCallerInstr()->GetUID() == caller->GetUID()) {
      return callSites_[i];
    }
  }
  return NULL;
}// GetCallSite()

void SIRFunction::
AddCallee(SIRFunction* f) {
  for (unsigned i = 0, e = callees_.size(); i < e; ++i) {
    if (callees_[i]->GetUID() == f->GetUID()) { return; }
  }
  callees_.push_back(f);
  for (unsigned i = 0, e = f->callers_.size(); i < e; ++i) {
    if (f->callers_[i]->GetUID() == this->GetUID()) { return; }
  }
  f->callers_.push_back(this);
}// AddCallee()

SIRLoop* SIRFunction::
AddOrGetLoop(unsigned l) {
  for (loop_iterator it = loop_begin(); it != loop_end(); ++it) {
    if ((*it)->GetLoopID() == l) { return *it; }
  }
  SIRLoop* loop = new SIRLoop(l, this);
  loopList_.push_back(loop);
  AddChild(loop);
  return loop;
}// AddOrGetLoop()

void SIRFunction::
AddDataObject(SIRDataObject* o) {
  if (!o) { return; }
  for (unsigned i = 0, e = dataObjects_.size(); i < e; ++i) {
    if (dataObjects_[i]->GetUID() == o->GetUID()) { return; }
  }
  dataObjects_.push_back(o);
  o->AddUse(this);
}// AddDataObject()

void SIRFunction::
UpdateLiveness() {
  unsigned numValues = GetNumValues();
  tr1::unordered_map<int, BitVector> blockLiveIns;
  tr1::unordered_map<int, BitVector> blockLiveOuts;
  tr1::unordered_map<int, BitVector> blockDefs;
  map<int, string>    valueNames;
  valueNames[linkRegister_->GetValueID()] = linkRegister_->GetName();
  valueNames[stackPointer_->GetValueID()] = stackPointer_->GetName();
  for (SIRFunction::iterator bIt = begin(); bIt != end(); ++bIt) {
    SIRBasicBlock* bb = *bIt;
    blockLiveIns [bb->GetBasicBlockID()].resize(numValues);
    blockLiveOuts[bb->GetBasicBlockID()].resize(numValues);
    blockDefs    [bb->GetBasicBlockID()].resize(numValues);
  }

  // Get the def and initial live-ins of each block
  for(SIRFunction::iterator bIt = begin(); bIt != end(); ++bIt) {
    SIRBasicBlock* bb = *bIt;
    int bid = bb->GetBasicBlockID();
    bb->li_clear();
    bb->lo_clear();
    // Function live-ins
    if (bb == GetEntryBlock()) {
      blockLiveIns[bid].reset();
      if (stackPointer_->UserCount() > 0) {
        blockLiveIns[bid].set(stackPointer_->GetValueID());
      }
      for (SIRFunction::arg_iterator aIt = arg_begin();aIt != arg_end();++aIt) {
        ES_ASSERT_MSG(SIRFunction::IsValidValueID((*aIt)->GetValueID()),
                      "Invalid value for "<< *aIt <<"\n");
        blockLiveIns[bid].set((*aIt)->GetValueID());
        valueNames[(*aIt)->GetValueID()] = (*aIt)->GetName();
      }
    }// if (bb == GetEntryBlock())
    // Function live-outs
    if (bb->IsExitBlock()) {
      blockLiveOuts[bid].set(linkRegister_->GetValueID());
      blockLiveOuts[bid].set(stackPointer_->GetValueID());
      for (SIRFunction::ret_iterator rIt = ret_begin();rIt != ret_end();++rIt) {
        ES_ASSERT_MSG(SIRFunction::IsValidValueID((*rIt)->GetValueID()),
                      "Invalid value for "<< *rIt <<"\n");
        blockLiveOuts[bid].set((*rIt)->GetValueID());
        valueNames[(*rIt)->GetValueID()] = (*rIt)->GetName();
      }
    }// if (bb->IsExitBlock())
    for (SIRBasicBlock::iterator iIt = bb->begin();iIt != bb->end(); ++iIt) {
      SIRInstruction* instr = *iIt;
      for (SIRInstruction::operand_iterator oIt = instr->operand_begin();
           oIt != instr->operand_end(); ++oIt) {
        int ov = (*oIt)->GetValueID();
        if (SIRFunction::IsValidValueID(ov)
            && !SIRFunction::IsGlobalStaticValue(ov) && !blockDefs[bid][ov]) {
          blockLiveIns[bid].set(ov);
          valueNames[ov] = (*oIt)->GetName();
        }
      }
      int r = instr->GetValueID();
      if (SIRFunction::IsValidValueID(r)) {
        blockDefs[bid].set(r);
        valueNames[r] = instr->GetName();
      }
    }// for bb iterator iIt
  }// for func iterator bIt
  /// Keep all return values the same value ID, as they will share the same
  /// physical anyway
  int retVal = -1;
  for (map<int, string>::const_iterator vIt=valueNames.begin();
       vIt != valueNames.end(); ++vIt) {
    if (vIt->second == "v0") { retVal = vIt->first; }
  }
  for (SIRFunction::ret_iterator rIt = ret_begin(); rIt != ret_end(); ++rIt) {
    valueNames[(*rIt)->GetValueID()] = (*rIt)->GetName();
    if((*rIt)->GetName() == "v0") { retVal = (*rIt)->GetValueID();}
  }
  for (cs_iterator cIt = cs_begin(); cIt != cs_end(); ++cIt) {
    SIRCallSite* cs = *cIt;
    SIRInstruction* instr = cs->GetCallerInstr();
    int bid = instr->GetParent()->GetBasicBlockID();
    if (cs->GetCallee() && !cs->GetCallee()->ret_empty() && (retVal >= 0)) {
      blockDefs[bid].set(retVal);
      instr->SetValueID(retVal);
    }
    // Arguments should be live-out values of the call block
    for (SIRCallSite::arg_iterator aIt = cs->arg_begin();
         aIt != cs->arg_end(); ++aIt) {
      blockLiveOuts[bid].set((*aIt)->GetValueID());
    }
  }// for cs_iterator cIt

  int numBB = size();
  BitVector nIn(numValues), nOut(numValues);
  // Solve dataflow equation
  while(1) {
    int fi = 0;
    for (SIRFunction::iterator bIt = begin();bIt != end();++bIt) {
      SIRBasicBlock* bb = *bIt;
      int bid = bb->GetBasicBlockID();
      nIn = blockLiveOuts[bid];
      nIn.reset(blockDefs[bid]);
      nIn |= blockLiveIns[bid];
      nOut = blockLiveOuts[bid];
      for (SIRBasicBlock::succ_iterator sIt = bb->succ_begin();
           sIt != bb->succ_end(); ++sIt) {
        nOut |= blockLiveIns[(*sIt)->GetBasicBlockID()];
      }// for curBB->successors iterator
      if ((nIn == blockLiveIns[bid]) && (nOut == blockLiveOuts[bid])) {
        fi ++;
      } else {
        blockLiveIns[bid]  = nIn;
        blockLiveOuts[bid] = nOut;
      }
    }// for func iterator
    if(fi == numBB) { break; }
  }// while(1)

  // Set liveness info based on the analysis result
  for(SIRFunction::iterator bIt = begin(); bIt != end(); ++bIt){
    SIRBasicBlock* bb = *bIt;
    int bid = bb->GetBasicBlockID();
    BitVector& li = blockLiveIns[bid];
    BitVector& lo = blockLiveOuts[bid];
    for (unsigned i = 0; i < numValues; ++i) {
      if (li[i]) { bb->AddLiveInValue(IsSolverKernel(), valueNames[i], i); }
    }
    for (unsigned i = 0; i < numValues; ++i) {
      if (lo[i]) { bb->AddLiveOutValue(IsSolverKernel(), valueNames[i], i); }
    }
  }// for func iterator bIt
  UpdateRegValueType();
}// UpdateLiveness()

void SIRFunction::
RemoveDeadValues() {
  bool change = true;
  UpdateLiveness();
  while(change) {
    change = false;
    for (iterator bIt = begin(); bIt != end(); ++bIt) {
      SIRBasicBlock* bb = *bIt;
      for (SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end();) {
        SIRInstruction* instr = *iIt;
        if ((instr->GetValueID() < 0) || (instr->use_size() > 0)
            || instr->GetBranchTarget()
            || bb->IsValueLiveOut(instr->GetValueID())) { ++iIt; continue; }
        for (unsigned i = 0; i < instr->operand_size(); ++i) {
          instr->GetOperand(i)->RemoveUse(instr);
        }
        for (unsigned i = 0; i < instr->predicate_size(); ++i) {
          instr->GetPredicate(i)->RemoveUse(instr);
        }
        iIt = bb->erase(iIt);
        change = true;
      }// for bb iterator iIt
    }// for iterator bIt
    UpdateLiveness();
  }// while(change)
}// RemoveDeadValues()

void SIRFunction::
UpdateDomTree() {
  int maxID = GetMaxBasicBlockID();
  vector<BitVector> dom(maxID+1, BitVector(maxID+1, true));
  BitVector nDom(maxID+1);
  SIRBasicBlock* entry = GetEntryBlock();
  ES_ASSERT_MSG(entry, "Function "<< GetName() <<" entry block not set");
  dom[entry->GetBasicBlockID()].reset();
  dom[entry->GetBasicBlockID()].set(entry->GetBasicBlockID());
  bool change = true;
  // Calculate the dominators for each block
  while (change) {
    change = false;
    for (reverse_iterator bIt = rbegin(); bIt != rend(); ++bIt) {
      SIRBasicBlock* bb = *bIt;
      if ((bb == entry) || bb->pred_empty()) { continue; }
      BitVector& dominator = dom[bb->GetBasicBlockID()];
      nDom.reset();
      nDom=dom[(*bb->pred_begin())->GetBasicBlockID()];
      for (SIRBasicBlock::pred_iterator pIt = bb->pred_begin();
           pIt != bb->pred_end(); ++pIt) {
        nDom &= dom[(*pIt)->GetBasicBlockID()];
      }// for bb pred_iterator pIt
      nDom.set(bb->GetBasicBlockID());
      if (dominator != nDom) {
        dominator = nDom;
        change = true;
      }
    }// // for reverse_iterator bIt
  }// while (change)

  for (iterator bIt = begin(); bIt != end(); ++bIt) { (*bIt)->dom_clear(); }
  // Now find the unique immediate dominator of each block
  for (iterator bIt = begin(); bIt != end(); ++bIt) {
    int bid = (*bIt)->GetBasicBlockID();
    BitVector& dominator = dom[bid];
    int idom = -1;
    for (int i = 0, e = dom.size(); i < e; ++i) {
      // Only check block that strictly dominates bb
      if ((i == bid) || !dominator[i]) { continue; }
      idom = i;
      for (int j = 0; j < e; ++j) {
        if ((j != i) && (bid != j) && dominator[j] && dom[j][i]) {
          idom = -1;
          break;
        }
      }
      if ((idom != bid) && (idom >= 0)) {
        GetBasicBlock(idom)->AddIDomChild(*bIt);
        break;
      }
    }// for i = 0 to dom.size()-1
    /// Any non-entry block should have an immediate dominator
    ES_ASSERT_MSG((idom>=0)||(*bIt == GetEntryBlock()),
                  "No immediate dominator found for "<<GetName()<<".B"<< bid);
  }// for iterator bIt
}// UpdateDomTree()

void SIRFunction::
UpdatePostDomTree() {
  int maxID = GetMaxBasicBlockID();
  vector<BitVector> pdom(maxID+1, BitVector(maxID+1, true));
  for (iterator bIt = begin(); bIt != end(); ++bIt) {
    if ((*bIt)->IsExitBlock()) {
      pdom[(*bIt)->GetBasicBlockID()].reset();
      pdom[(*bIt)->GetBasicBlockID()].set((*bIt)->GetBasicBlockID());
    }
  }
  BitVector nPDom(maxID+1);
  bool change = true;
  // Calculate post-dominator
  while (change) {
    change = false;
    for (iterator bIt = begin(); bIt != end(); ++bIt) {
      SIRBasicBlock* bb = *bIt;
      if (bb->IsExitBlock() || bb->succ_empty()) { continue; }
      nPDom.reset();
      nPDom = pdom[(*bb->succ_begin())->GetBasicBlockID()];
      for (SIRBasicBlock::succ_iterator sIt = bb->succ_begin();
           sIt != bb->succ_end(); ++sIt) {
        nPDom &= pdom[(*sIt)->GetBasicBlockID()];
      }// for bb succ_iterator sIt
      nPDom.set(bb->GetBasicBlockID());
      BitVector& pDominator = pdom[bb->GetBasicBlockID()];
      if (pDominator != nPDom) {
        pDominator = nPDom;
        change = true;
      }
    }// // for reverse_iterator bIt
  }// while (change)

  for (iterator bIt = begin(); bIt != end(); ++bIt) { (*bIt)->pdom_clear(); }
  // Now find the unique immediate post-dominator for each node
  for (iterator bIt = begin(); bIt != end(); ++bIt) {
    int bid = (*bIt)->GetBasicBlockID();
    BitVector& pDominator = pdom[bid];
    int ipdom = -1;
    for (int i = 0, e = pdom.size(); i < e; ++i) {
      // Only check block that strictly post-dominates bb
      if ((i == bid) || !pDominator[i]) { continue; }
      ipdom = i;
      for (int j = 0; j < e; ++j) {
        if ((j != i) && (bid != j) && pDominator[j] && pdom[j][i]) {
          ipdom = -1;
          break;
        }
      }
      /// Note: a block may not have any strict post-dominator, so we don't
      /// check if the an immediate post-dominator
      if ((ipdom != bid) && (ipdom >= 0)) {
        GetBasicBlock(ipdom)->AddIPDomChild(*bIt);
        break;
      }
    }// for i = 0 to dom.size()-1
  }// for iterator bIt
}// UpdatePostDomTree()

/// \brief Check if a path in CFG exists from src to dst without going through
///        the avoid node.
///
/// The check if done recursively, with a bit-vector to mark visited nodes.
/// \param src The source node.
/// \param dst The destination node.
/// \param avoid The node to avoid in the path.
/// \param visited Reference to the bit-vector that keep track of visited nodes.
/// \return true if there is a path from src to dst without going through avoid,
///         otherwise false.
static bool
HasCFGPathWithout(SIRBasicBlock* src, SIRBasicBlock* dst,
                  SIRBasicBlock* avoid, BitVector& visited) {
  if ((src == dst) || src->IsSuccessor(dst)) { return true; }
  if (visited[src->GetBasicBlockID()]) { return false; }
  else { visited.set(src->GetBasicBlockID()); }
  for (SIRBasicBlock::succ_iterator sIt = src->succ_begin();
       sIt != src->succ_end(); sIt ++){
    if (*sIt == avoid) { continue; }
    if(HasCFGPathWithout(*sIt, dst, avoid, visited)) { return true; }
  }
  return false;
}// HasCFGPathWithout()

static bool CmpLoopSize(const SIRLoop* l, const SIRLoop* r) {
  return l->size() < r->size();
}

static int CalculateLoopDepth(const SIRLoop* l) {
  return l->GetParentLoop() ? CalculateLoopDepth(l->GetParentLoop()) + 1 : 1;
}

void SIRFunction::
UpdateLoopInfo() {
  typedef std::pair<SIRBasicBlock*, SIRBasicBlock*> CFGEdge;
  loop_clear();
  vector<CFGEdge> backEdges;
  for (iterator bIt = begin(); bIt != end(); ++bIt) {
    SIRBasicBlock* bb = *bIt;
    for (SIRBasicBlock::pred_iterator pIt = bb->pred_begin();
         pIt != bb->pred_end(); ++pIt) {
      if (bb->Dominates(*pIt)) { backEdges.push_back(make_pair(bb, *pIt)); }
    }
  }// for iterator bIt
  int loopNum = 0;
  int maxID = GetMaxBasicBlockID();
  vector<SIRBasicBlock*> loopBlocks;
  BitVector visited(maxID+1);
  loopBlocks.reserve(maxID);
  /// For each back-edge, construct a natural loop
  for (int i = 0, e = backEdges.size(); i < e; ++i) {
    SIRLoop* loop = AddOrGetLoop(loopNum++);
    SIRBasicBlock* h = backEdges[i].first;
    SIRBasicBlock* n = backEdges[i].second;
    loop->AddBlock(h);
    loop->SetHeader(h);
    loopBlocks.clear();
    loopBlocks.push_back(n);
    while (!loopBlocks.empty()) {
      SIRBasicBlock* bb = loopBlocks.back();
      loopBlocks.pop_back();
      visited.reset();
      if (HasCFGPathWithout(bb, n, h, visited)) {
        loop->AddBlock(bb);
        for (SIRBasicBlock::pred_iterator pIt = bb->pred_begin();
             pIt != bb->pred_end(); ++pIt) {
          if (!loop->Contains(*pIt) && h->Dominates(*pIt)) {
            loopBlocks.push_back(*pIt);
          }
        }
      }// if (HasCFGPathWithout(bb, n, h, visit))
    }// while (!loopBlocks.empty())

    // Set exit blocks (could be more than one)
    for (SIRLoop::iterator bIt = loop->begin(); bIt != loop->end(); ++bIt) {
      SIRBasicBlock* bb = *bIt;
      for (SIRBasicBlock::succ_iterator sIt = bb->succ_begin();
           sIt != bb->succ_end(); ++sIt) {
        if (!loop->Contains(*sIt)) { loop->AddExitBlock(bb); break; }
      }
    }
  }// for i = 0 to backEdges.size()-1

  /// Setup the loop nest.
  /// First sort the loops by size. The idea is that a loop can only be inside
  /// a loop that is larger (not equal!) than itself.
  loopList_.sort(CmpLoopSize);
  for (loop_iterator lIt = loop_begin(); lIt != loop_end(); ++lIt) {
    SIRLoop* loop = *lIt;
    loop_iterator plIt = lIt;
    for (++plIt; plIt != loop_end(); ++plIt) {
      bool sub = true;
      SIRLoop* pLoop = *plIt;
      for (SIRLoop::iterator bIt = loop->begin(); bIt != loop->end(); ++bIt) {
        if (!pLoop->Contains(*bIt)) { sub = false; break; }
      }
      // Stop if a parent loop is found
      if (sub) { (pLoop)->AddSubLoop(loop);loop->SetParentLoop(pLoop); break; }
    }
  }// for loop_iterator lIt
  for (loop_iterator lIt = loop_begin(); lIt != loop_end(); ++lIt) {
    (*lIt)->SetLoopDepth(CalculateLoopDepth(*lIt));
  }// for loop_iterator lIt
  for (loop_iterator lIt = loop_begin(); lIt != loop_end(); ++lIt) {
    for (SIRLoop::iterator bIt = (*lIt)->begin(); bIt != (*lIt)->end(); ++bIt) {
      (*bIt)->SetLoop(*lIt);
    }
  }// for loop_iterator lIt
}// UpdateLoopInfo()

void SIRFunction::
UpdateRegValueType() {
  Int2IntMap valTypeCache;
  for (SIRFunction::iterator bIt = begin(); bIt != end(); ++bIt) {
    SIRBasicBlock* bb = *bIt;
    for (SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end(); ++iIt) {
      SIRInstruction* instr= *iIt;
      int iVal = instr->GetValueID();
      if (iVal < 0) { continue; }
      int iType = instr->IsVectorInstr();
      if (IsElementOf(iVal, valTypeCache)) {
        ES_ASSERT_MSG(iType == GetValue(iVal, valTypeCache),
                      "IR Type mismatch");
      } else { valTypeCache[iVal] = iType; }
    }// for bb iterator iIt
  }// for func iterator bIt

  for (SIRFunction::iterator bIt = begin(); bIt != end(); ++bIt) {
    SIRBasicBlock* bb = *bIt;
    for (SIRBasicBlock::li_iterator lIt = bb->li_begin();
         lIt != bb->li_end(); ++lIt) {
      SIRRegister* r = *lIt;
      if (IsElementOf(r->GetValueID(), valTypeCache)) {
        r->SetValueType(GetValue(r->GetValueID(), valTypeCache));
      }
    }// for bb li_iterator lIt
    for (SIRBasicBlock::lo_iterator lIt = bb->lo_begin();
         lIt != bb->lo_end(); ++lIt) {
      SIRRegister* r = *lIt;
      if (IsElementOf(r->GetValueID(), valTypeCache)) {
        r->SetValueType(GetValue(r->GetValueID(), valTypeCache));
      }
    }// for bb lo_iterator lIt
    for (SIRBasicBlock::iterator iIt = bb->begin(); iIt != bb->end(); ++iIt) {
      SIRInstruction* instr= *iIt;
      for (int i = 0, e=instr->operand_size(); i < e; ++i) {
        if (SIRRegister* r = dynamic_cast<SIRRegister*>(instr->GetOperand(i))) {
          if (IsElementOf(r->GetValueID(), valTypeCache)) {
            r->SetValueType(GetValue(r->GetValueID(), valTypeCache));
          }// if (IsElementOf(r->GetValueID(), valTypeCache))
        }// if  GetOperand(i) is SIRRegister
      }// for i = 0 to instr->operand_size()-1
    }// for bb iterator iIt
  }// for func iterator bIt
}// UpdateValueType()

std::ostream& SIRFunction::
SIRPrettyPrint(std::ostream& o) const {
  o <<"        .global     "<< name_ <<"\n";
  o <<"        .type       "<< name_ <<",@function\n";
  o <<"        .ent        "<< name_ <<"\n";
  if (IsSolverKernel()) { o <<"        .solverkernel\n"; }
  o << name_ <<": ";
  for (const_iterator it = begin(); it != end(); ++it) {
    const SIRBasicBlock* bb = *it;
    if ((bb != entryBlock_) && bb->HasName()) { o << bb->GetName() <<": "; }
    o <<"# BB_"<< bb->GetBasicBlockID();
    if (bb->IsExitBlock()) { o <<"<Exit>";}
    o <<"\n";
    bb->SIRPrettyPrint(o);
  }
  return o <<"        .end        "<< name_ <<"\n";
}// SIRPrettyPrint()

std::ostream& SIRFunction::
TargetPrettyPrint(std::ostream& o) const {
  o <<"        .global     "<< name_ <<"\n";
  o <<"        .type       "<< name_ <<",@function\n";
  o <<"        .ent        "<< name_ <<"\n";
  if (IsSolverKernel()) { o <<"        .solverkernel\n"; }
  o << name_ <<": ";
  for (const_iterator it = begin(); it != end(); ++it) {
    const SIRBasicBlock* bb = *it;
    if ((bb != entryBlock_) && bb->HasName()) { o << bb->GetName() <<": "; }
    o <<"# BB_"<< bb->GetBasicBlockID();
    if (bb->IsExitBlock()) { o <<"<Exit>";}
    o <<"\n";
    bb->TargetPrettyPrint(o);
  }
  return o <<"        .end        "<< name_ <<"\n";
}// SIRPrettyPrint()

std::ostream& SIRFunction::
ValuePrint(std::ostream& o) const {
  o << name_ <<": ";
  for (const_iterator it = begin(); it != end(); ++it) {
    const SIRBasicBlock* bb = *it;
    if ((bb != entryBlock_) && bb->HasName()) { o << bb->GetName() <<": "; }
    o <<"BB"<< bb->GetBasicBlockID()<<":\n";
    bb->ValuePrint(o);
  }
  return o;
}// ValuePrint()

void SIRFunction::
loop_clear() {
  for (iterator bIt = begin(); bIt != end(); ++bIt) { (*bIt)->SetLoop(NULL); }
  loopList_.clear();
}// loop_clear()

void SIRFunction::
PrintIRInfo(ostream& o) const {
  o <<"---- "<< GetName() <<"() ----\n";
  o <<"  >> Args: "<< GetNumFormalArguments()<<'\n';
  o <<"  >> BBs:  "<< size() <<'\n';
  o <<"  >> Loops:"<< loop_size() <<'\n';
}// PrintIRInfo()

void SIRFunction::
Dump(Json::Value& info) const {
  info["name"] = GetName();
  info["args"] = GetNumFormalArguments();
  info["ret"] = static_cast<int>(ret_size());
}// Dump ()

void ES_SIMD::
BuildLoopWithPreHeader(
  SIRBasicBlock*& preHeader, SIRBasicBlock*& hdr, SIRBasicBlock*& ext,
  SIRValue* loopBound, SIRValue* step, SIROpcode_t incOpcode,
  const list<SIRBasicBlock*>& loopBlocks, SIRBasicBlock* entryBlock,
  SIRBasicBlock* exitBlock, SIRFunction* func) {
  IntSet loopBBs;
  for (list<SIRBasicBlock*>::const_iterator it = loopBlocks.begin();
       it != loopBlocks.end(); ++it) {
    loopBBs.insert((*it)->GetBasicBlockID());
  }
  vector<SIRBasicBlock*> loopPreds, entryPreds;
  for (SIRBasicBlock::pred_iterator pIt = entryBlock->pred_begin();
       pIt != entryBlock->pred_end(); ++pIt) {
    if (!IsElementOf((*pIt)->GetBasicBlockID(), loopBBs)) {
      loopPreds.push_back(*pIt);
    } else { entryPreds.push_back(*pIt); }
  }
  vector<SIRBasicBlock*> loopSuccs, exitSuccs;
  for (SIRBasicBlock::succ_iterator sIt = exitBlock->succ_begin();
       sIt != exitBlock->succ_end(); ++sIt) {
    if (!IsElementOf((*sIt)->GetBasicBlockID(), loopBBs)) {
      loopSuccs.push_back(*sIt);
    } else { exitSuccs.push_back(*sIt); }
  }
  // Create header block
  if (!hdr) {
    hdr = new SIRBasicBlock(func->GetNewBasicBlockID(),func);
    hdr->SetName(SIRBasicBlock::GetNormalizedBlockName(hdr));
    SIRFunction::iterator entIt = find(func->begin(), func->end(), entryBlock);
    ES_ASSERT_MSG(entIt != func->end(), "Cannot find entry block");
    func->insert(entIt, hdr);
  }// if (!hdr)
  if (!preHeader) {
    // Create pre-header if there isn't one
    preHeader = new SIRBasicBlock(func->GetNewBasicBlockID(),func);
    preHeader->SetName(SIRBasicBlock::GetNormalizedBlockName(preHeader));
    SIRFunction::iterator hdrIt = find(func->begin(), func->end(), hdr);
    ES_ASSERT_MSG(hdrIt != func->end(), "Cannot find entry block");
    func->insert(hdrIt, preHeader);
  }// if (!preHeader)
  // Create exit block
  if (!ext) {
    ext = new SIRBasicBlock(func->GetNewBasicBlockID(),func);
    ext->SetName(SIRBasicBlock::GetNormalizedBlockName(ext));
    SIRFunction::iterator extIt = find(func->begin(), func->end(), exitBlock);
    ES_ASSERT_MSG(extIt != func->end(), "Cannot find exit block");
    func->insert(++extIt, ext);
  }// if (!ext)

  // Setup control flow of header and pre-header block
  preHeader->succ_push_back(hdr);
  hdr->pred_push_back(preHeader);
  if (hdr != entryBlock) {
    for (int i=0, e=loopPreds.size(); i < e; ++i) {
      preHeader->pred_push_back(loopPreds[i]);
    }
    entryBlock->pred_clear();
    for (int i=0, e=entryPreds.size(); i < e; ++i) {
      entryBlock->pred_push_back(entryPreds[i]);
    }
    hdr->succ_push_back(entryBlock);
    entryBlock->pred_push_back(hdr);
  }// if (hdr != entryBlock)

  // Setup control flow of exit block
  if (exitBlock != ext) {
    for (int i=0, e=loopSuccs.size(); i < e; ++i) {
      ext->succ_push_back(loopSuccs[i]);
    }
    exitBlock->succ_clear();
    for (int i=0, e=exitSuccs.size(); i < e; ++i) {
      exitBlock->succ_push_back(exitSuccs[i]);
    }
    exitBlock->succ_push_back(ext);
    ext->pred_push_back(exitBlock);
  }// if (exitBlock != ext)

  // The back edge
  ext->succ_push_back(hdr);
  hdr->pred_push_back(ext);
  if (!loopBound) { return; }
  int boundVal = preHeader->BuildSIRInstr(
    preHeader->end(), false, SIROpcode::MOV, func->AllocateValue())
    .AddOperand(loopBound).GetValueID();
  // Increase trip counter and branch if global loop is not finished yet
  SIRInstruction& boundInc = ext->BuildSIRInstr(
    ext->end(), false, incOpcode, boundVal)
    .AddOperand(ext->AddOrGetBlockRegister(boundVal, false)).AddOperand(step);

  ext->BuildSIRInstr(ext->end(), false, SIROpcode::BRGT)
    .AddOperand(&boundInc).AddOperand(func->GetZeroRegister()).AddOperand(hdr);
}// BuildLoopWithPreHeader()

void ES_SIMD::
BuildEmptyLoop(
  SIRFunction::iterator insIt, SIRBasicBlock*& preHeader, SIRBasicBlock*& body,
  const vector<SIRBasicBlock*>& loopSuccs, SIRValue* loopBound, SIRValue* step,
  SIROpcode_t incOpcode, SIRFunction* func) {

  if (!preHeader) {
    // Create pre-header if there isn't one
    preHeader = new SIRBasicBlock(func->GetNewBasicBlockID(),func);
    func->insert(insIt, preHeader);
  }// if (!preHeader)
  if (!preHeader->HasName()) {
    preHeader->SetName(SIRBasicBlock::GetNormalizedBlockName(preHeader));
  }
  // Create loop body block
  if (!body) {
    body = new SIRBasicBlock(func->GetNewBasicBlockID(),func);
    func->insert(insIt, body);
  }
  if (!body->HasName()) {
    body->SetName(SIRBasicBlock::GetNormalizedBlockName(body));
  }
  // Setup control flow of body and pre-header block
  preHeader->succ_push_back(body);
  body->pred_push_back(preHeader);

  // The back edge
  body->succ_push_back(body);
  body->pred_push_back(body);
  // Setup control flow of exit block
  for (int i=0, e=loopSuccs.size(); i < e; ++i) {
    body->succ_push_back(loopSuccs[i]);
  }

  if (!loopBound) { return; }
  int boundVal = preHeader->BuildSIRInstr(
    preHeader->end(), false, SIROpcode::MOV, func->AllocateValue())
    .AddOperand(loopBound).GetValueID();
  // Increase trip counter and branch if global loop is not finished yet
  SIRInstruction& boundInc = body->BuildSIRInstr(
    body->end(), false, incOpcode, boundVal)
    .AddOperand(body->AddOrGetBlockRegister(boundVal, false)).AddOperand(step);

  body->BuildSIRInstr(body->end(), false, SIROpcode::BRGT)
    .AddOperand(&boundInc).AddOperand(func->GetZeroRegister()).AddOperand(body);
}// BuildEmptyLoop()
