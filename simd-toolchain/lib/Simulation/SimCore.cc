#include <sstream>
#include "Simulation/SimCore.hh"

using namespace std;
using namespace ES_SIMD;

SimCoreBase::~SimCoreBase() {}

void SimCoreBase::
Reset() {
  programCounter_  = nextPC_ = 0;
  terminated_ = false;
  fetchStage_.Reset();
  decodeStage_.Reset();
  executeStage_.Reset();
  commitStage_.Reset();
  for (tr1::unordered_map<unsigned, SimScalarMMapObject*>::iterator
         it = mmapObjects_.begin(); it != mmapObjects_.end(); ++it) {
    it->second->Reset();
  }
}// Reset()

void SimCoreBase::
CycleAction() {
  CycleInit();

  /// Pipeline runs in reverse order
  Commit();
  Execute();
  Decode();
  Fetch();

  CycleFinal();
}// Step()

void SimCoreBase::
CycleInit() {}

void SimCoreBase::
CycleFinal() {
  programCounter_ = nextPC_;
}

uint32_t SimCoreBase::
Communicate(unsigned dir, unsigned id) const {
  /// Default implementation assumes no communication is allowed
  stringstream ss;
  ss <<"Illegal communication in \""<<GetName()<<"\", dir="<< dir <<", id="<<id;
  Error(refTimer_, SimErrorCode::IllegalCommunication,
        ss.str());
  return 0;
}// Communicate()

uint32_t SimCoreBase::
SyncCommunicate(unsigned dir) const {
  /// Default implementation assumes no communication is allowed
  stringstream ss;
  ss <<"Illegal communication in \""<<GetName()<<"\"";
  Error(refTimer_, SimErrorCode::IllegalCommunication,
        ss.str());
  return 0;
}// SyncCommunicate()

void SimCoreBase::Synchronize() {}

////////////////////////////////////////////////////////////////////////////////
//                      Enum related definition
////////////////////////////////////////////////////////////////////////////////
DEFINE_ENUM(ES_SIMD, CommBoundaryMode, COMMBOUNDARYMODE_ENUM)
