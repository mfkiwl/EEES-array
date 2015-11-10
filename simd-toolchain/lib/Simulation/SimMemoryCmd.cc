#include "Simulation/SimMemoryCmd.hh"

using namespace std;
using namespace ES_SIMD;

ostream& ES_SIMD::
operator<<(ostream& o, const SimMemoryCommand& t) {
  o << MemoryCommandType::GetString(t.Type()) <<", A="<< t.Address()
    <<", dat="<< t.Value() <<",lat="<< t.Delay();
  if (t.IsLoad())
    o <<", dst="<< t.Destination();
  return o;
}

////////////////////////////////////////////////////////////////////////////////
//                      Enum related definition
////////////////////////////////////////////////////////////////////////////////
DEFINE_ENUM(ES_SIMD,MemoryCommandType,MEMORYCOMMANDTYPE_ENUM)
