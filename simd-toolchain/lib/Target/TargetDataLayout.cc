#include "Target/TargetDataLayout.hh"

using namespace std;
using namespace ES_SIMD;

TargetDataLayoutPass::~TargetDataLayoutPass() {}

bool TargetDataLayoutPass::
RunOnSIRModule(SIRModule* m) {
  bool changed = false;
  return changed;
}// RunOnSIRModule()
