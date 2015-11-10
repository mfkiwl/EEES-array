#include <iostream>
#include <iomanip>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <algorithm>
#include "Utils/StringUtils.hh"
#include "Utils/InlineUtils.hh"

using namespace std;
using namespace ES_SIMD;

string ES_SIMD::
Int2DecString(int i) {
  std::stringstream ss;
  ss << std::dec << i;
  return ss.str();
}// Int2DecString()

string ES_SIMD::
Int2HexString(int i) {
  std::stringstream ss;
  ss << std::hex << i;
  return ss.str();
}// Int2DecString()

unsigned ES_SIMD::
GetStringStreamSize(std::stringstream& ss) {
   streampos orig = ss.tellg();
   ss.seekg(0, ios::end);
   int s = ss.tellg();
   ss.seekg(orig, ios::beg);
   return s;
}

void ES_SIMD::
ToUpperCase(std::string& str) {
  std::transform(str.begin(), str.end(),str.begin(), ::toupper);
}// ToUpperCase()

void ES_SIMD::
ToLowerCase(std::string& str) {
  std::transform(str.begin(), str.end(),str.begin(), ::tolower);
}// ToLowerCase()

static inline void LTrimString(string& str, const string& ws) {
  size_t found = str.find_first_not_of(ws);
  if (found != string::npos)
    str.erase(str.begin(), str.begin() + found);
  else
    str.clear();
}
inline void RTrimString(string& str, const string& ws) {
  size_t found = str.find_last_not_of(ws);
  if (found != string::npos)
    str.erase(found+1);
  else
    str.clear();
}

void ES_SIMD::
TrimString(string& str) {
  static const string whitespace(" \t\n\r");
  LTrimString(str, whitespace);
  RTrimString(str, whitespace);
}// TrimString()

void ES_SIMD::
TrimString(string& str, const string& whitespace) {
  LTrimString(str, whitespace);
  RTrimString(str, whitespace);
}// TrimString()

static size_t
FindNonEscape(const std::string& str, const char c, const char escape,
              size_t start) {
  size_t p = str.find(c, start);
  if (!escape) { return p; }
  while (p != string::npos) {
    if ((p == 0) || (str[p-1] != escape)) { return p; }
    p = str.find(c, p+1);
  }// while (p != string::npos)
  return p;
}// FindNonEscape()

std::pair<size_t, size_t> ES_SIMD::
GetDelimitedString(const std::string& str, const char delimeter,
                   const char escape, size_t start) {
  size_t s = FindNonEscape(str, delimeter, escape, start);
  if (s != string::npos) {
    size_t e = FindNonEscape(str, delimeter, escape, s+1);
    if (e != string::npos) { return make_pair(s, e); }
  }// if (s != string::npos)
  return make_pair(string::npos, string::npos);
}// GetDelimitedString()

void ES_SIMD::
TokenizeString(vector<string>& tokens, const string &str,
               const string& seps) {
  pair<size_t, size_t> pq = GetDelimitedString(str, '"', '\\', 0);
  size_t i = str.find_first_not_of(seps);
  size_t s = string::npos;
  while(i != string::npos) {
    if (str[i] == '"') { s = FindNonEscape(str, '"', '\\', i+1)+1; }
    else { s = str.find_first_of(seps, i+1); }
    if (s != string::npos) { tokens.push_back(str.substr(i, s-i)); }
    else { tokens.push_back(str.substr(i)); break; }
    i = str.find_first_not_of(seps, s+1);
    pq = GetDelimitedString(str, '"', '\\', s+1);
  }// while(i != string::npos)
}// TokenizeString

int ES_SIMD::ImmediateReader::
GetIntImmediate(const std::string& imm) {
  int  val = 0;
  bool minus = false;
  error_ = false;
  if (imm.empty()) {
    error_ = true;
    return 0;
  }
  if (imm.find("0x") == 0) {
    // Hex imm
    if (imm.length() < 3) {
      error_ = true;
      return 0;
    }// if (imm.length() < 3)
    for (unsigned i = 2; i < imm.length(); ++i) {
      char c = imm[i];
      int t;
      if ((c >= '0') && (c <='9')) {
        t = static_cast<int>(c-'0');
      } else if ((c >= 'a') && (c <='f')) {
        t = static_cast<int>(c-'a'+10);
      } else if ((c >= 'A') && (c <='F')) {
        t = static_cast<int>(c-'A'+10);
      } else {
        error_ = true;
        return 0;
      }
      val = (val<<4) + t;
    }// for i = 2 to imm.length()-1
  } else {
    // Dec imm
    minus = (imm[0] == '-');
    unsigned i = minus ? 1 : 0;
    if (i >= imm.length()) {
      error_ = true;
      return 0;
    }// if (i >= imm.length())
    for (; i < imm.length(); ++i) {
      char c = imm[i];
      if ((c >= '0') && (c <= '9')) {
        val = val * 10 + static_cast<int>(c-'0');
      } else {
        error_ = true;
        return 0;
      }
    }// for i to imm.length()
  }// if (imm.find("0x") == 0)
  return minus ? -val : val;
}// GetIntImmediate()

unsigned ES_SIMD::ImmediateReader::
GetHexUInt(const std::string& imm) {
  unsigned s = (imm.find("0x") == 0) ? 2 : 0;
  if (s >= imm.length()) {
    error_ = true;
    return 0;
  }
  unsigned val = 0;
  for (unsigned i = s; i < imm.length(); ++i) {
    char c = imm[i];
    unsigned t;
    if ((c >= '0') && (c <='9')) {
      t = static_cast<unsigned>(c-'0');
    } else if ((c >= 'a') && (c <='f')) {
      t = static_cast<unsigned>(c-'a'+10);
    } else if ((c >= 'A') && (c <='F')) {
      t = static_cast<unsigned>(c-'A'+10);
    } else {
      error_ = true;
      return 0;
    }
    val = (val<<4) + t;
  }// for i = 2 to imm.length()-1
  return val;
}// GetHexUInt

uint64_t ES_SIMD::ImmediateReader::
GetUInt64Immediate(const string& imm) {
  uint64_t val = 0;
  error_ = false;
  if (imm.empty()) {
    error_ = true;
    return 0;
  }
  if (imm.find("0x") == 0) {
    // Hex imm
    if (imm.length() < 3) {
      error_ = true;
      return 0;
    }// if (imm.length() < 3)
    for (unsigned i = 2; i < imm.length(); ++i) {
      char c = imm[i];
      int t;
      if ((c >= '0') && (c <='9')) {
        t = static_cast<int>(c-'0');
      } else if ((c >= 'a') && (c <='f')) {
        t = static_cast<int>(c-'a'+10);
      } else if ((c >= 'A') && (c <='F')) {
        t = static_cast<int>(c-'A'+10);
      } else {
        error_ = true;
        return 0;
      }
      val = (val<<4) + t;
    }// for i = 2 to imm.length()-1
  } else {
    // Dec imm
    for (unsigned i = 0; i < imm.length(); ++i) {
      char c = imm[i];
      if ((c >= '0') && (c <= '9')) {
        val = val * 10 + static_cast<int>(c-'0');
      } else {
        error_ = true;
        return 0;
      }
    }// for i to imm.length()
  }// if (imm.find("0x") == 0)
  return val;
}// GetUInt64Immediate()

bool ES_SIMD::
ParseEscapedString(const string& str, std::vector<int>& data) {
  data.clear();
  data.reserve(str.size());
  for (unsigned i = 0, e = str.size(); i != e; ++i) {
    if (str[i] != '\\') {
      data.push_back(str[i]);
      continue;
    }

    // Recognize escaped characters. Notably, it doesn't support hex escapes.
    ++i;
    // Unexpected backslash at end of string
    if (i == e) { return false; }

    // Recognize octal sequences.
    if ((unsigned) (str[i] - '0') <= 7) {
      // Consume up to three octal characters.
      int value = str[i] - '0';
      if ((i + 1 != e) && ((unsigned) (str[i + 1] - '0')) <= 7) {
        ++i;
        value = value * 8 + (str[i] - '0');

        if (i + 1 != e && ((unsigned) (str[i + 1] - '0')) <= 7) {
          ++i;
          value = value * 8 + (str[i] - '0');
        }
      }
      // Out of range
      if (value > 255) { return false; }

      data.push_back(value);
      continue;
    }// if ((unsigned) (str[i] - '0') <= 7)
    // Otherwise recognize individual escapes.
    switch (str[i]) {
    default: // Reject invalid escape sequences
      return false;
    case 'b':  data.push_back('\b'); break;
    case 'f':  data.push_back('\f'); break;
    case 'n':  data.push_back('\n'); break;
    case 'r':  data.push_back('\r'); break;
    case 't':  data.push_back('\t'); break;
    case '"':  data.push_back('"' ); break;
    case '\'': data.push_back('\''); break;
    case '\\': data.push_back('\\'); break;
    }// switch (str[i])
  }// for i = 0 to str.size()-1

  return true;
}// ParseEscapedString()
