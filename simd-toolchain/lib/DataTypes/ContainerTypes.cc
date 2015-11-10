#include "DataTypes/ContainerTypes.hh"

using namespace std;
using namespace ES_SIMD;

ostream& ES_SIMD::
PrintBitVector(std::ostream& o, const BitVector& t) {
  o <<"{";
  for (unsigned i = 0; i < t.size(); ++i) {
    if(t[i]) { o << i <<", "; }
  }
  o <<"}";
  return o;
}

ostream& ES_SIMD::
operator<<(std::ostream& o, const BitVector& t) {
  return PrintBitVector(o,t);
}
