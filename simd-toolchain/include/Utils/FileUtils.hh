#ifndef ES_SIMD_FILEUTILS_HH
#define ES_SIMD_FILEUTILS_HH

#include <vector>
#include <iostream>
#include <string>
#include <json/json.h>
#include "DataTypes/ASMLine.hh"
#include "DataTypes/EnumFactory.hh"

#define FILESTATUS_ENUM(DEF, DEFV)              \
  DEF(OK)                                       \
  DEF(COULD_NOT_OPEN)                           \
  DEF(INVALID_CONTENT)                          \
  DEF(UNKNOWN_ERROR)

namespace ES_SIMD {
  DECLARE_ENUM(FileStatus, FILESTATUS_ENUM)

  /// \brief Write the content of a string to a file.
  /// \param str The string to be written.
  /// \param filename The filename of the output file.
  /// \return The status of the file operation. FileStatue::OK
  ///         if everything is fine.
  FileStatus_t WriteStringToFile(const std::string& str,
                                 const std::string& filename);
  /// \brief Write the content of a stringstring to a file.
  /// \param ss The stringstream that contains the string to be written.
  /// \param filename The filename of the output file.
  /// \return The status of the file operation. FileStatue::OK
  ///         if everything is fine.
  FileStatus_t WriteStringToFile(const std::stringstream& ss,
                                 const std::string& filename);
  /// \brief Read the lines of a file into a string vector.
  /// \param lines The vector to store the result lines.
  /// \param commentPrefix Comment prefix. A line starts with commen prefix
  ///        will be ignored.
  /// \param filename The filename of the input file.
  /// \return The status of the file operation. FileStatue::OK
  ///         if everything is fine.
  FileStatus_t ReadFileLines(std::vector<std::string>& lines,
                             const std::string& commentPrefix,
                             const std::string& fileName);
  /// \brief Read the content of a file into a string.
  /// \param str The string to store the result.
  /// \param filename The filename of the input file.
  /// \return The status of the file operation. FileStatue::OK
  ///         if everything is fine.
  FileStatus_t ReadFileToString(std::string& str, const std::string& filename);
  /// \breif Read a binary file to a char vector
  /// \param data The vector to store the result.
  /// \param filename The filename of the input file.
  /// \return The status of the file operation. FileStatue::OK
  ///         if everything is fine.
  FileStatus_t ReadBinaryFile(std::vector<char>& data, const std::string& filename);
  /// \brief Read the content of a assembly file into a vector.
  /// \param lnBuff The vector to store the result.
  /// \param filename The filename of the input file.
  /// \return The status of the file operation. FileStatue::OK
  ///         if everything is fine.
  FileStatus_t ReadASMFileLines(std::vector<ASMLine>& lnBuff,
                                const std::string& filename);
  /// \brief Read the content of a JSON file into a Json::Value.
  /// \param filename The filename of the input file.
  /// \param val The Json::Value reference to store the result.
  /// \return The status of the file operation. FileStatue::OK
  ///         if everything is fine.
  FileStatus_t ReadJSONFile(const std::string& filename, Json::Value& val);
}// namespace ES_SIMD

#endif//ES_SIMD_FILEUTILS_HH
