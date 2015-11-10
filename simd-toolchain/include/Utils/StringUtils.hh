#ifndef ES_SIMD_STRINGUTILS_HH
#define ES_SIMD_STRINGUTILS_HH

#include "DataTypes/BasicTypes.hh"
#include <vector>
#include <string>
#include <sstream>

namespace ES_SIMD {
  /// \brief Get the size of the string in a string stream.
  unsigned GetStringStreamSize(std::stringstream& ss);
  /// \brief Convert all characters in a string to upper-case.
  /// \param str The target string.
  void ToUpperCase(std::string& str);
  /// \brief Convert all characters in a string to lower-case.
  /// \param str The target string.
  void ToLowerCase(std::string& str);
  /// \brief Trim the white-space in a string.
  ///
  /// This function considered space, \\t, \\n and \\r as white-space
  /// characters. The leading and trailing white-space characters are removed
  /// from the string.
  /// \param str The target string.
  void TrimString(std::string& str);
  /// \brief Trim the white-space in a string.
  ///
  /// This function considered all characters in whitespace as white-space
  /// characters. The leading and trailing white-space characters are removed
  /// from the string.
  /// \param str The target string.
  /// \param whitespace White-space characters.
  void TrimString(std::string& str, const std::string& whitespace);
  /// \brief Find the substring that is delimited by the given delimiter
  ///
  /// \param str The string to be searched.
  /// \param delimiter The delimiter.
  /// \param escape The delimiter can escape. 0 indicates no escape possible.
  /// \param start  Position to start the search.
  /// \return The position [start, end] of the delimited substring of str.
  ///         If no substring is found, returns [npos, npos].
  std::pair<size_t, size_t> GetDelimitedString(
    const std::string& str, const char delimeter,
    const char escape, size_t start);
  /// \brief Break a string into list of tokens.
  ///
  /// This function breaks a string into tokens using the specified separator.
  /// \param tokens The continer to store the result tokens.
  /// \param istr The input string.
  /// \param seps The separator.
  void TokenizeString(std::vector<std::string>& tokens,
                      const std::string& istr,
                      const std::string& seps);
  /// \brief Convert an integer to decimal string.
  ///
  /// \param i The integer value.
  /// \return The decimal string of i.
  std::string Int2DecString(int i);
  /// \brief Convert an integer to hex string.
  ///
  /// \param i The integer value.
  /// \return The hex string of i (without "0x").
  std::string Int2HexString(int i);
  /// \brief Parse a ASCII string and get the values. Support escape sequence.
  ///
  /// This functions store the value of each character into a integer vector.
  /// It can recognize escaped characters and octal characters.
  /// \note Hex escaped is not supported
  /// \param str The string to be parsed.
  /// \param data The vector for storing results.
  /// \return true if str is successfully parsed, otherwise false.
  bool ParseEscapedString(const std::string& str, std::vector<int>& data);
  /// \brief Convert string to immediate value.
  ///
  /// The purpose of this struct is to have a way to check whether a string
  /// to integer conversion is successful. After each conversion, the user
  /// should check the value of error_. If it is true, something is wrong.
  struct ImmediateReader {
    bool error_; ///< Whether the last conversion failed.
    /// \brief Convert a string to an integer value.
    ///
    /// This function can process hex or dec value. If a string starts with
    /// "0x" it is treated as a hex string. Otherwise it is treated as a dec
    /// string. If the conversion is successful, it sets error_ to false,
    /// otherwise it sets it to true.
    /// \param imm The string to be converted.
    /// \return The value of the integer represented by imm.
    int GetIntImmediate(const std::string& imm);
    /// \brief Convert a hex string to an integer value.
    ///
    /// The string can starts with or without "0x". If the conversion is
    /// successful, it sets error_ to false, otherwise it sets it to true.
    /// \param imm The string to be converted.
    /// \return The value of the integer represented by imm.
    unsigned GetHexUInt(const std::string& imm);
    /// \brief Convert a string to a 64-bit integer value.
    ///
    /// This function can process hex or dec value. If a string starts with
    /// "0x" it is treated as a hex string. Otherwise it is treated as a dec
    /// string. If the conversion is successful, it sets error_ to false,
    /// otherwise it sets it to true.
    /// \param imm The string to be converted.
    /// \return The value of the integer represented by imm.
    uint64_t GetUInt64Immediate(const std::string& imm);
    ImmediateReader() : error_(false) {}
  };// struct ImmediateReader
}// namespace ES_SIMD

#endif//ES_SIMD_STRINGUTILS_HH
