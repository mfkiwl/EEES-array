#ifndef ES_SIMD_VERILOGMEMHEX_HH
#define ES_SIMD_VERILOGMEMHEX_HH

#include "DataTypes/ContainerTypes.hh"
#include "DataTypes/MemDataSection.hh"

namespace ES_SIMD {
  /// @brief Write the value in dat to out in a format compatible with $readmemh
  ///        in Verilog, for data with word width over 32-bit
  /// @param out the output stream
  /// @param dat input data, each row is a memory word store in a vector, in
  ///            which the element order is LITTLE-ENDIAN
  /// @param width the number of bits in one memory word
  /// @param start the start word address
  void WriteVerilogMemHex(std::ostream& out, const UInt32Vector2D& dat,
                          uint32_t width, uint32_t start);

  /// @brief Write the value in dat to out in a format compatible with $readmemh
  ///        in Verilog, for data with word width under or equals to 32-bit
  /// @param out the output stream
  /// @param dat input data, each row is a memory word store in a vector, in
  ///            which the element order is LITTLE-ENDIAN
  /// @param width the number of bits in one memory word
  /// @param start the start word address
  void WriteVerilogMemHex(std::ostream& out, const UInt32Vector& dat,
                          uint32_t width, uint32_t start);

  /// @brief Read the values of lines in a format compatible with $readmemh
  ///        in Verilog
  /// @param lines string vector, each element contains one line
  /// @param width the number of bits in one memory word
  /// @param data output data
  void ReadVerilogMemHex(
    const std::vector<std::string>& lines, unsigned width,
    std::list<MemDataSection>& data);
}// namespace ES_SIMD

#endif//ES_SIMD_VERILOGMEMHEX_HH
