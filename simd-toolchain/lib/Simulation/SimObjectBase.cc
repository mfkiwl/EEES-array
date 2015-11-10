#include "Simulation/SimObjectBase.hh"

using namespace std;
using namespace ES_SIMD;

unsigned SimObjectBase::SimObjectCounter = 0;
vector<SimulationError> SimObjectBase::
SimErrors = vector<SimulationError>();
bool SimObjectBase::Initialized = Initialize();

bool SimObjectBase::
Initialize() {
  SimObjectCounter = 0;
  return true;
}// Initialize()

SimObjectBase::
SimObjectBase(const std::string& name, unsigned logLv, std::ostream& log,
                  unsigned traceLv, std::ostream& trace, std::ostream& err)
  : logLevel_(logLv), log_(log), traceLevel_(traceLv), trace_(trace), err_(err),
    id_(SimObjectBase::SimObjectCounter++), name_(name) {}// SimObjectBase()

SimObjectBase::~SimObjectBase() {
  for (std::tr1::unordered_set<SimObjectBase*>::iterator it
         = subObjects_.begin(); it != subObjects_.end(); ++it) { delete *it; }
}

void SimObjectBase::
Error(uint64_t t, SimErrorCode_t c, const std::string& m) const {
  SimulationError err(t, this, c, m);
  SimErrors.push_back(err);
}// MachineSimObject::Error()

ostream& SimObjectBase::
PrintErrors(std::ostream& o) {
  for (unsigned i = 0; i < SimErrors.size(); ++i) { o << SimErrors[i]; }
  return o;
}// PrintErrors()

std::ostream& ES_SIMD::
operator<<(std::ostream& out, const SimulationError &t) {
  const SimObjectBase* pObj = t.GetErrorObject();
  out <<"*>>>>Error in ";
  if (pObj != NULL) {
    out <<"\""<< pObj->GetName() <<"\" (id="<< pObj->GetID() <<")";
  } else {
    out <<"UNKNOWN OBJECT";
  }
  out <<", code=["<< t.GetErrorCode() <<"], time="
      << dec << t.timeStamp_ <<"\n";
  const string& msg = t.GetMessage();
  if (!msg.empty())
    out << "message: " << msg <<"\n";
  return out;
}// operator<<(std::ostream& out, const SimulationError &t)

////////////////////////////////////////////////////////////////////////////////
//                      Enum related definition
////////////////////////////////////////////////////////////////////////////////
DEFINE_ENUM(ES_SIMD,SimErrorCode,SIMERRORCODE_ENUM)

