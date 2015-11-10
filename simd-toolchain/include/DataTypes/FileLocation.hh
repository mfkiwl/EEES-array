#ifndef ES_SIMD_FILELOCATION_HH
#define ES_SIMD_FILELOCATION_HH

#include <string>

namespace ES_SIMD {
  struct FileLocation {
    std::string fileName_;
    int line_;
    FileLocation() : line_(0) {}
    FileLocation(const std::string fn, int ln)
      : fileName_(fn), line_(ln) {}
    FileLocation(const FileLocation& f)
      : fileName_(f.fileName_), line_(f.line_) {}
  };// ErrorLocation
}// namespace ES_SIMD

#endif//ES_SIMD_FILELOCATION_HH
