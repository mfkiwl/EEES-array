#include "SIR/SIRLoop.hh"
#include "SIR/SIRBasicBlock.hh"

using namespace std;
using namespace ES_SIMD;

SIRLoop::~SIRLoop() {}

void SIRLoop::
AddBlock(SIRBasicBlock* b) {
  int bid = b->GetUID();
  for (iterator it = begin(); it != end(); ++it) {
    if ((*it)->GetUID() == bid)
      return;
  }
  loopBlocks_.push_back(b);
}// AddBlock()

void SIRLoop::
AddExitBlock(SIRBasicBlock* b) {
  AddBlock(b);
  int bid = b->GetUID();
  for (exit_iterator it = exit_begin(); it != exit_end(); ++it) {
    if ((*it)->GetUID() == bid)
      return;
  }
  exitBlocks_.push_back(b);
}// AddBlock()

void SIRLoop::
AddSubLoop(SIRLoop* l) {
  int lid = l->GetUID();
  for (std::vector<SIRLoop*>::iterator it = subLoops_.begin();
       it != subLoops_.end(); ++it) {
    if ((*it)->GetUID() == lid)
      return;
  }
  subLoops_.push_back(l);
}// AddSubLoop()

bool SIRLoop::
Contains(const SIRBasicBlock* b) const {
  int bid = b->GetUID();
  for (const_iterator it = begin(); it != end(); ++it) {
    if ((*it)->GetUID() == bid)
      return true;
  }
  return false;
}// Contains()

bool SIRLoop::
Contains(const SIRLoop* l) const {
  int lid = l->GetUID();
  for (std::vector<SIRLoop*>::const_iterator it = subLoops_.begin();
       it != subLoops_.end(); ++it) {
    if ((*it)->GetUID() == lid)
      return true;
  }
  return false;
}// Contains()
