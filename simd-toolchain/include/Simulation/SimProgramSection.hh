#ifndef ES_SIMD_SIMPROGRAMSECTION_HH
#define ES_SIMD_SIMPROGRAMSECTION_HH

#include "DataTypes/EnumFactory.hh"
#include "DataTypes/Object.hh"
#include "DataTypes/ContainerTypes.hh"
#include "Simulation/SimOperation.hh"

namespace ES_SIMD {
  class SimProgramSection {
  public:
    typedef std::vector<SimOperation>::iterator iterator;
    typedef std::vector<SimOperation>::const_iterator const_iterator;

    SimProgramSection() : headAddress_(0) {}
    SimProgramSection(unsigned a) : headAddress_(a) {}
    SimProgramSection(unsigned a, unsigned size)
      : headAddress_(a), sectionCode_(size) {}
    ~SimProgramSection();

    iterator begin() { return sectionCode_.begin();}
    iterator end()   { return sectionCode_.end();  }
    const_iterator begin() const { return sectionCode_.begin();}
    const_iterator end()   const { return sectionCode_.end();  }
    unsigned size() const { return sectionCode_.size(); }
    bool empty() const { return sectionCode_.empty(); }
    void resize(unsigned n) { sectionCode_.resize(n); }
    void clear() { sectionCode_.clear(); }

    SimProgramSection& SetHeadAddress(unsigned a) {
      headAddress_ = a;
      return *this;
    }

    unsigned GetHeadAddress() const { return headAddress_; }

    bool IsInSection(unsigned a) const {
      return (a >= headAddress_)
        && ((a-headAddress_) < sectionCode_.size());
    }
    SimOperation& operator[](unsigned i) {
      return sectionCode_[i];
    }
    const SimOperation& operator[](unsigned i) const {
      return sectionCode_[i];
    }
  private:
    unsigned headAddress_;
    std::vector<SimOperation> sectionCode_;
  };// class SimProgramSection
}// namespace ES_SIMD

#endif//ES_SIMD_SIMPROGRAMSECTION_HH
