#include <iomanip>
#include <algorithm>
#include "Utils/VerilogMemInit.hh"
#include "Utils/InlineUtils.hh"
#include "Utils/StringUtils.hh"

using namespace std;
using namespace ES_SIMD;

void ES_SIMD::
WriteVerilogMemHex(std::ostream& out, const UInt32Vector2D& dat,
                   uint32_t width, uint32_t start) {
  unsigned w  = CeilDiv(width, 32u);
  unsigned dw = CeilDiv(width, 4u);
  out <<"@"<< hex << start <<"\n";
  char prev = out.fill();
  out.fill('0');
  for (unsigned i = 0; i < dat.size(); ++i) {
    const UInt32Vector& val = dat[i];
    unsigned cdw = dw;
    for (int j = w / 8; j >=0; --j) {
      uint32_t d = j < static_cast<int>(val.size()) ? val[j] : 0;
      out << hex << setw(min(cdw, 8u)) << d;
      cdw -=8;
    }
    out <<"\n";
  }// for i = 0 to dat.size()-1
  out.fill(prev);
}// WriteVerilogMemHex()

void ES_SIMD::
WriteVerilogMemHex(std::ostream& out, const UInt32Vector& dat,
                   uint32_t width, uint32_t start) {
  unsigned dw = CeilDiv(width, 4u);
  out <<"@"<< hex << start <<"\n";
  char prev = out.fill();
  out.fill('0');
  for (unsigned i = 0; i < dat.size(); ++i) {
    out << hex << setw(dw) << dat[i] <<"\n";
  }// for i = 0 to dat.size()-1
  out.fill(prev);
}// WriteVerilogMemHex()

void ES_SIMD::
ReadVerilogMemHex(const std::vector<std::string>& lines, unsigned width,
                  std::list<MemDataSection>& data) {
  static ImmediateReader immRd;
  unsigned hexWidth  = CeilDiv(width, 4U);
  unsigned wordWidth = CeilDiv(width, 32U);
  if (lines[0].find('@') != 0) {
    data.push_back(MemDataSection(0, width));
  }
  for (unsigned i = 0; i < lines.size(); ++i) {
    const string& l = lines[i];
    if (l.empty())
      continue;
    if (l.find('@') == 0) {
      unsigned s = immRd.GetHexUInt(l.substr(1));
      if (immRd.error_)
        return;
      data.push_back(MemDataSection(s, width));
    } else {
      if (l.length() != hexWidth) {
        continue;
      }
      data.back().data_.push_back(UInt32Vector(wordWidth));
      for (unsigned j = 0; j < wordWidth; ++j) {
        unsigned wlen = min(hexWidth, 8U);
        data.back().data_.back()[wordWidth-j-1] = immRd.GetHexUInt(
          l.substr(l.length() - j*8 - wlen, wlen));
        if (hexWidth > 8)
          hexWidth -= 8;
        if (immRd.error_) {
          cout << "Failed to read imm\n";
          break;
        }
      }// for j = 0 to wordWidth-1
      if (immRd.error_)
            continue;
    }// if (l.find("@") == 0)
  }// for i = 0 to lines.size()-1
}// ReadVerilogMemHex()
