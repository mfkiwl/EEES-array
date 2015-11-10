#ifndef ES_SIMD_ASMLINE_HH
#define ES_SIMD_ASMLINE_HH

#include <vector>
#include <string>

namespace ES_SIMD {
  struct ASMLine {
    int lineNum_;         // line number in the original source file
    std::string line_;    // non-comment content of the line
    std::string comment_; // line comment
    bool Empty() const   { return line_.empty() && comment_.empty(); }
    bool HasContent() const { return !line_.empty(); }
    bool HasComment() const { return !comment_.empty(); }
    bool IsCommentOnly() const { return line_.empty() && !comment_.empty(); }
    ASMLine() : lineNum_(0) {}
    ASMLine(int i) : lineNum_(i) {}
    ASMLine(int i, const std::string& l) : lineNum_(i), line_(l) {}
    ASMLine(int i, const char*& l) : lineNum_(i), line_(l) {}
    ASMLine(int i, const std::string& l, const std::string& c)
      : lineNum_(i), line_(l), comment_(c) {}
    ASMLine(int i, const char* l, const char* c)
      : lineNum_(i), line_(l), comment_(c) {}
  };
}// namespace ES_SIMD

#endif//ES_SIMD_ASMLINE_HH
