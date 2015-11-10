#include "DataTypes/Error.hh"

using namespace std;
using namespace ES_SIMD;

void Error::
Print(ostream& o) const {
  o <<"ERROR<"<< errorCode_ <<">";
  if (!fLoc_.fileName_.empty()) {
    o << " in line "<< fLoc_.line_ << " of "<< fLoc_.fileName_;
  }
  o <<".";
  if (!msg_.empty()) { o <<" "<< msg_ ; }
}// Print()

std::ostream& ES_SIMD::
operator<<(std::ostream& o, const Error& e) {
  e.Print(o);
  return o;
}

////////////////////////////////////////////////////////////////////////////////
//                      Enum related definition
////////////////////////////////////////////////////////////////////////////////
DEFINE_ENUM(ES_SIMD, ErrorCode, ERRORCODE_ENUM)
