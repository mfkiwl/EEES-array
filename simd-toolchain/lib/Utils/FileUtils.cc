#include <iostream>
#include <iomanip>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include "Utils/FileUtils.hh"
#include "Utils/StringUtils.hh"
#include "Utils/InlineUtils.hh"

using namespace std;
using namespace ES_SIMD;

FileStatus_t ES_SIMD::
WriteStringToFile(const string &str, const string &filename) {
  ofstream outFile;
  outFile.open(filename.c_str());
  if (outFile.fail()) {
    cerr << "Failed to open file: " << filename << endl;
    return FileStatus::COULD_NOT_OPEN;
  }
  outFile << str;
  outFile.close();
  return FileStatus::OK;
}// WriteStringToFile()

FileStatus_t ES_SIMD::
WriteStringToFile(const stringstream &ss, const string &filename) {
  ofstream outFile;
  outFile.open(filename.c_str());
  if (outFile.fail()) {
    cerr << "Failed to open file: " << filename << endl;
    return FileStatus::COULD_NOT_OPEN;
  }
  outFile << ss.str();
  outFile.close();
  return FileStatus::OK;
}// WriteStringToFile()


FileStatus_t ES_SIMD::
ReadFileLines(vector<string> &lineList,
              const string &comment,
              const string &fileName) {
  ifstream inFile;
  inFile.open(fileName.c_str(), ios::in);
  if (inFile.fail()) {
    cerr << "Failed to open file: " << fileName << endl;
    return FileStatus::COULD_NOT_OPEN;
  }
  string line;
    
  while (getline(inFile, line)) {
    // Remove comment
    size_t p = line.find(comment);
    if (p != string::npos){
      line = line.substr(0, p);
    }
    TrimString(line);
    if (!line.empty()){
      lineList.push_back(line);
    }
  }
  inFile.close();
  return FileStatus::OK;
}// ReadFileLines()

FileStatus_t ES_SIMD::
ReadFileToString(string& str, const string& filename) {
  ifstream inFile;
  inFile.open(filename.c_str(), ios::in);
  if (inFile.fail()) {
    cerr << "Failed to open file: " << filename << endl;
    return FileStatus::COULD_NOT_OPEN;
  }
  str = string((std::istreambuf_iterator<char>(inFile)),
               std::istreambuf_iterator<char>());
  inFile.close();
  return FileStatus::OK;
}// ReadFileToString()

FileStatus_t ES_SIMD::
ReadBinaryFile(std::vector<char>& data, const std::string& filename) {
  ifstream binFile(filename.c_str(), ios::in | ios::binary);
  if (!binFile) {
    cerr << "Failed to open file: " << filename << endl;
    return FileStatus::COULD_NOT_OPEN;
  }
  binFile.seekg(0, std::ios::end);
  int fileSize = binFile.tellg();
  data.clear();
  data.resize(fileSize);
  binFile.seekg(0, std::ios::beg);
  return binFile.read((char*) &data[0], fileSize)? FileStatus::OK
    : FileStatus::UNKNOWN_ERROR ;
}// ReadBinaryFile()

FileStatus_t ES_SIMD::
ReadASMFileLines(vector<ASMLine> &lineList,
                 const string &fileName) {
  const static std::string asmWhitespace(" \t\n\r#");
  ifstream inFile;
  inFile.open(fileName.c_str(), ios::in);
  if (inFile.fail()) {
    cerr << "Failed to open file: " << fileName << endl;
    return FileStatus::COULD_NOT_OPEN;
  }
  string line;
  int n = 1;
  while (getline(inFile, line)) {
    string comm;
    size_t p = line.find('#');
    size_t cur = 0;
    while (p != string::npos) {
      // Make sure the '#' is not within a string
      pair<size_t, size_t> pq = GetDelimitedString(line, '"', '\\', cur);
      if ((pq.first != string::npos) && (pq.first < p) && (pq.second > p)) {
        cur = pq.second + 1;
        p = line.find('#', cur);
      } else { break; }// if ((pq != string::npos) || (pq < p))
    }// while (p != string::npos)
    if (p != string::npos) {
      comm = line.substr(p);
      line = line.substr(0, p);
    }
    TrimString(line, asmWhitespace);
    TrimString(comm, asmWhitespace);
    ASMLine ln(n, line, comm);
    if (!ln.Empty())
      lineList.push_back(ln);
    ++n;
  }
  inFile.close();
  return FileStatus::OK;
}// ReadASMFileLines()

FileStatus_t ES_SIMD::
ReadJSONFile(const std::string& filename, Json::Value& val) {
  static Json::Reader reader;
  ifstream inFile;
  inFile.open(filename.c_str(), ios::in);
  if (inFile.fail()) {
    cerr << "Failed to open file: " << filename << endl;
    return FileStatus::COULD_NOT_OPEN;
  }

  FileStatus_t st = FileStatus::OK;
  bool succ = reader.parse(inFile, val);
  if (!succ) {
    cerr <<"Failed to parse JSON file\n"<< reader.getFormattedErrorMessages();
    st = FileStatus::INVALID_CONTENT;
  } else {
  }
  return st;
}// ReadJSONFile()

////////////////////////////////////////////////////////////////////////////////
//                      Enum related definition
////////////////////////////////////////////////////////////////////////////////
DEFINE_ENUM(ES_SIMD,FileStatus,FILESTATUS_ENUM)
