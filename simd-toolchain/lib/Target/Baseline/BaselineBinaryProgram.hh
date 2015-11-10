#ifndef ES_SIMD_BASELINEBINARYPROGRAM_HH
#define ES_SIMD_BASELINEBINARYPROGRAM_HH

#include "Target/TargetBinaryProgram.hh"

namespace ES_SIMD {
  class BaselineBasicInfo;

  class BaselineBinaryProgram : public TargetBinaryProgram {
  public:
    BaselineBinaryProgram(int id, const std::string& n,
                          const BaselineBasicInfo& t)
      : TargetBinaryProgram(id, n, 2), target_(t) {}
    virtual ~BaselineBinaryProgram();
    virtual bool ResolveSymbols();
    virtual FileStatus_t SaveVerilogMemHex(
      const std::string& prefix) const;
    /// \brief add data memory initialization item
    /// \param dSec Data section index, 0: CP data memory; 1: PE data memory.
    /// \param dt   data type
    /// \param addr target address
    /// \param val  actual value
    /// \return next available address
    int AddDataInit(int dSec, SIRDataType_t dt, int addr, int val);
  protected:
    const BaselineBasicInfo& target_;
  };// class BaselineBinaryProgram
}// namespace ES_SIMD

#endif//ES_SIMD_BASELINEBINARYPROGRAM_HH
