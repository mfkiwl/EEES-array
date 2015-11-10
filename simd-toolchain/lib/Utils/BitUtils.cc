#include "Utils/DbgUtils.hh"
#include "Utils/BitUtils.hh"

using namespace std;
using namespace ES_SIMD;

void ES_SIMD::
InsertBitsToIntVector(
  unsigned bits, unsigned lsb, uint32_t msb, vector<uint32_t>& vec) {
  ES_ASSERT_MSG((lsb <= msb), "illegal bit index ("<< lsb <<", "<< msb <<")");
  // cout <<"("<<bits<<", "<<lsb<<", "<<msb<<")\n";
  unsigned lN = lsb >> 5, mN = msb >> 5, lR = lsb & 0x1F;
  if (lN == mN) {
    vec[lN] = InsertBitsToWord(bits, vec[lN], lR, msb & 0x1F);
  } else {
    // Since bits is 32 bit, only possible to have two insert
    ES_ASSERT_MSG((mN-lN) == 1, "illegal bit index ("<< lsb <<
                ", "<< msb <<")");
    vec[lN] = InsertBitsToWord(bits, vec[lN], lR, 32);
    vec[mN] = InsertBitsToWord(bits>>(32-lR), vec[mN], 0, msb & 0x1F);
  }// if (lN == mN)
}// InsertBitsToIntVector()

uint32_t ES_SIMD::
ExtractBitsFromIntVector(
  unsigned lsb, unsigned msb, const vector<uint32_t>& vec) {
  ES_ASSERT_MSG((lsb <= msb), "illegal bit index ("<< lsb <<", "<< msb <<")");
  uint32_t bits = 0;
  unsigned lN = lsb >> 5, mN = msb >> 5, lR = lsb & 0x1F;
  if (lN == mN) {
    bits = ExtractBitsFromWord(vec[lN], lR, msb & 0x1F);
  } else {
    // Since bits is 32 bit, only possible to extract from two words
    ES_ASSERT_MSG((mN-lN) == 1, "illegal bit index ("<< lsb <<
                  ", "<< msb <<")");
    uint32_t lb = ExtractBitsFromWord(vec[lN], lR, 32);
    uint32_t hb = ExtractBitsFromWord(vec[mN], 0, msb & 0x1F);
    bits = (hb << (32-lR))|lb;
  }// if (lN == mN)
  return bits;
}// InsertBitsToIntVector()
