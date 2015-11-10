#include "Utils/CmdUtils.hh"

using namespace std;
using namespace ES_SIMD;

void ES_SIMD::
PrintVersionInfo(std::ostream& out) {
  out << PRJ_NAME <<" ver "<< VERSION_MAJOR <<"."<< VERSION_MINOR <<"\n";
}// PrintVersion()

void ES_SIMD::
PrintToolVersion(std::ostream& out, const char* toolName, const char* desc) {
  out << PRJ_NAME <<" ver "<< VERSION_MAJOR <<"."<< VERSION_MINOR <<"\n  "
      << toolName <<": "<< desc <<"\n";
}// PrintToolVersion()
