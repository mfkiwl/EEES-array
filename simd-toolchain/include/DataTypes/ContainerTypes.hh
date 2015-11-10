#ifndef ES_SIMD_CONTAINERTYPES_HH
#define ES_SIMD_CONTAINERTYPES_HH

#include <vector>
#include <list>
#include <map>
#include <set>
#include <string>
#include <algorithm>
#include <iostream>
#include <stdint.h>
#include <tr1/unordered_set>
#include <tr1/unordered_map>
#include "llvm/ADT/BitVector.h"

namespace ES_SIMD {

  typedef llvm::BitVector BitVector;

  typedef std::tr1::unordered_map<int, int>   Int2IntMap;
  typedef std::tr1::unordered_map<int, float> Int2FloatMap;
  typedef std::tr1::unordered_map<int, std::string> Int2StrMap;
  typedef std::map<int, int>                  Int2IntOrderedMap;
  typedef std::tr1::unordered_set<int>        IntSet;
  typedef IntSet::iterator                    IntSetIter;
  typedef std::set<int>                       IntOrderedSet;
  typedef std::set<int>::iterator             IntOrdSetIter;
  typedef std::list<int>                      IntList;
  typedef std::vector<int>                    IntVector;
  typedef std::vector<IntVector>              IntVector2D;
  typedef std::vector<unsigned>               UIntVector;
  typedef std::vector<UIntVector>             UIntVector2D;
  typedef std::vector<int32_t>                Int32Vector;
  typedef std::vector<Int32Vector>            Int32Vector2D;
  typedef std::vector<uint32_t>               UInt32Vector;
  typedef std::vector<UInt32Vector>           UInt32Vector2D;
  typedef std::vector<int16_t>                Int16Vector;
  typedef std::vector<Int16Vector>            Int16Vector2D;
  typedef std::vector<uint16_t>               UInt16Vector;
  typedef std::vector<UInt16Vector>           UInt16Vector2D;

  typedef std::tr1::unordered_set<std::string> StrSet;
  typedef StrSet::iterator                     StrSetIter;
  typedef std::set<std::string>                StrOrderedSet;
  typedef StrOrderedSet::iterator              StrOrdSetIter;
  typedef std::list<std::string>               StrList;
  typedef std::vector<std::string>             StrVector;
  typedef std::tr1::unordered_map<std::string, int>   Str2IntMap;

  template<typename T>
  class AssignValue {
    T val_;
  public:
    AssignValue(const T& v) : val_(v) {}
    void operator()(T& t) { t = val_; }
  };

  struct Int2IntMapValueCmpLT {
    Int2IntMap& m_;
    Int2IntMapValueCmpLT(Int2IntMap& m) :m_(m) {}
    bool operator()(int lhs, int rhs) {
      return m_[lhs] < m_[rhs];
    }
  };
  struct Int2IntMapValueCmpGT {
    Int2IntMap& m_;
    Int2IntMapValueCmpGT(Int2IntMap& m) :m_(m) {}
    bool operator()(int lhs, int rhs) {
      return m_[lhs] > m_[rhs];
    }
  };

  template<typename T>
  void push_back_unique(const T& t, std::vector<T>& vec) {
    for (unsigned i = 0; i < vec.size(); ++i) {
      if (vec[i] == t) { return; }
    }
    vec.push_back(t);
  }

  template<typename T, typename Container>
  bool IsElementOf(const T& t, const Container& cont) {
    return cont.find(t) != cont.end();
  }

  template<typename T>
  bool IsElementOf(const T& t, const std::vector<T>& cont) {
    return std::find(cont.begin(), cont.end(), t) != cont.end();
  }

  template<typename K, typename T>
  const T& GetValue(const K& k, const std::tr1::unordered_map<K, T>& cont) {
    return cont.find(k)->second;
  }

  template<typename K, typename T>
  const T& GetValue(const K& k, const std::map<K, T>& cont) {
    return cont.find(k)->second;
  }

  static inline void PrintIntSet(const IntSet& s, const std::string &sep,
                                 std::ostream &out){
    for (IntSet::const_iterator it = s.begin(); it != s.end(); ++it) {
      if (it != s.begin())
        out << sep;
      out << *it;
    }
  }

  template <typename T>
  std::ostream& operator<<(std::ostream& o, const std::vector<T>& t) {
    o <<"{";
    for (unsigned i = 0; i <  t.size(); ++i) {
      o<<t[i]<<",";
    }
    o<<"}";
    return o;
  }

  template <typename T>
  std::ostream& operator<<(std::ostream& o,const std::tr1::unordered_set<T>& t){
    o <<"{";
    for (typename std::tr1::unordered_set<T>::const_iterator it = t.begin();
         it != t.end(); ++it){
      o<< *it <<",";
    }
    o<<"}";
    return o;
  }

  template <typename K, typename T>
  std::ostream& operator<<(std::ostream& o,const std::tr1::unordered_map<K, T>& t){
    o <<"{";
    for (typename std::tr1::unordered_map<K, T>::const_iterator it = t.begin();
         it != t.end(); ++it){
      o<< it->first <<"->"<< it->second <<",";
    }
    o<<"}";
    return o;
  }

  template <typename T>
  std::ostream& PrintVector(std::ostream& o, const std::vector<T>& t,
                            unsigned offset, unsigned len) {
    o <<"{";
    for (unsigned i = offset; i <  (offset + len); ++i) {
      o<<t[i]<<",";
    }
    return o<<"}";
  }
  template <typename T>
  std::ostream& PrintArray(std::ostream& o, const T* t,
                           unsigned offset, unsigned len) {
    o <<"{";
    for (unsigned i = offset; i <  (offset + len); ++i) {
      o<<t[i]<<",";
    }
    return o<<"}";
  }

  std::ostream& PrintBitVector(std::ostream& o, const BitVector& t);
  std::ostream& operator<<(std::ostream& o, const BitVector& t);

  template<class T>
  bool PriorityCompare(const std::vector<T>& lhs, const std::vector<T>& rhs) {
    for (int i=0, e=std::min(lhs.size(), rhs.size()); i < e; ++i) {
      int l=lhs[i], r=rhs[i];
      if (l < r) { return true;  }
      else if (l > r) { return false; }
    }
    return true;
  }
}// using namespace ES_SIMD

#endif//ES_SIMD_CONTAINERTYPES_HH
