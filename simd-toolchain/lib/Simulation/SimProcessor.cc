#include "Simulation/SimProcessor.hh"

using namespace std;
using namespace ES_SIMD;

auto_ptr<SimProcessorFactory::TargetSimCreatorMap>
SimProcessorFactory::map_;

SimProcessorBase::~SimProcessorBase() {}

void SimProcessorBase::Reset() { simCycle_ = 0; terminated_ = false; }

void SimProcessorBase::SetBranchTrace(bool t) {}
