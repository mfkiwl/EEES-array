#ifndef ES_SIMD_SIMSRAM_HH
#define ES_SIMD_SIMSRAM_HH

#include <algorithm>
#include "Utils/DbgUtils.hh"
#include "Utils/StringUtils.hh"
#include "DataTypes/ContainerTypes.hh"
#include "Simulation/SimObjectBase.hh"
#include "Simulation/SimMemoryCmd.hh"

namespace ES_SIMD {
  class SimSRAMBase : public SimObjectBase {
  public:
    unsigned GetLatency() const { return latency_; }
    unsigned GetWordWidth() const { return wordWidth_; }
    unsigned GetDepth() const { return depth_; }
    virtual void InitWord(unsigned waddr, uint32_t val) = 0;
    virtual void InitByte(unsigned addr,  uint8_t val) = 0;
    virtual size_t GetByteSize() const = 0;
  protected:
    SimSRAMBase(const std::string& name, const uint64_t& clk, unsigned lat,
                unsigned wordWidth, unsigned depth, unsigned logLv,
                std::ostream& log, unsigned traceLv, std::ostream& trace,
                std::ostream& err)
      : SimObjectBase(name, logLv, log, traceLv, trace, err), latency_(lat),
        wordWidth_(wordWidth), depth_(depth), clock_(clk) {}
    virtual ~SimSRAMBase();
    static uint32_t GetByteMask(unsigned i) { return ByteMask[i]; }
    uint64_t GetTimeStamp() const { return  clock_; }
  private:
    static const uint32_t ByteMask[16];
    unsigned latency_;
    unsigned wordWidth_;
    unsigned depth_;
    const uint64_t& clock_;
  };

  template<typename T>
  class SimScalarSRAM : public SimSRAMBase {
  public:
    SimScalarSRAM(const std::string& name, const uint64_t& clk, unsigned depth,
                  unsigned lat, unsigned logLv, std::ostream& log,
                  unsigned traceLv, std::ostream& trace, std::ostream& err)
      : SimSRAMBase(name, clk, lat, 8*sizeof(T), depth, logLv, log,
                    traceLv, trace, err), data_(depth, 0) {}
    virtual ~SimScalarSRAM() {}

    virtual void Reset() {}
    virtual void InitWord(unsigned waddr, uint32_t val) {
      data_[waddr] = static_cast<T>(val);
    }
    virtual void InitByte(unsigned addr, uint8_t val) {
      ((uint8_t*)&data_[0])[addr] = val;
    }
    virtual size_t GetByteSize() const { return data_.size() * sizeof(T); }
    T& operator[](unsigned i) {
      if (i > data_.size()) {
        Error(GetTimeStamp(), SimErrorCode::InvalidMemAddr,
              "Invalid read address "+ Int2DecString(i));
        return data_[0];
      }
      return data_[i];
    }
    const T& operator[](unsigned i) const {
      if (i > data_.size()) {
        Error(GetTimeStamp(), SimErrorCode::InvalidMemAddr,
              "Invalid read address "+ Int2DecString(i));
        return data_[0];
      }
      return data_[i];
    }

    T ReadBE(unsigned addr, unsigned be) {
      unsigned byteMask = SimSRAMBase::GetByteMask(be);
      if (addr > data_.size()) {
        Error(GetTimeStamp(), SimErrorCode::InvalidMemAddr,
              "Invalid read address "+ Int2DecString(addr));
        return 0;
      }
      return data_[addr] & byteMask;
    }
    void WriteBE(unsigned addr, unsigned be, T val) {
      unsigned byteMask = SimSRAMBase::GetByteMask(be);
      if (addr > data_.size()) {
        Error(GetTimeStamp(), SimErrorCode::InvalidMemAddr,
              "Invalid write address "+ Int2DecString(addr));
        return;
      }
      data_[addr] = (val & byteMask) | (data_[addr] & ~byteMask);
    }
    void Fill(const std::vector<T>& src, unsigned start) {
      std::copy(src.begin() + start, src.end(), data_.begin());
    }
    std::vector<T>& Data() { return data_; }
    const std::vector<T>& Data() const { return data_; }
  private:
    std::vector<T> data_;
  };// class SimScalarSRAM

  template<typename T>
  class SimVectorSRAM : public SimSRAMBase {
  public:
    SimVectorSRAM(const std::string& name, const uint64_t& clk, unsigned vecLen,
                  unsigned depth,unsigned lat,unsigned logLv,std::ostream& log,
                  unsigned traceLv, std::ostream& trace, std::ostream& err)
      : SimSRAMBase(name, clk, lat, 8*sizeof(T), depth, logLv, log,
                    traceLv, trace, err),
        vectorLength_(vecLen), data_(depth*vecLen, 0) {}
    virtual void Reset() {}
    virtual void InitWord(unsigned waddr, uint32_t val) {
      data_[waddr] = static_cast<T>(val);
    }
    virtual void InitByte(unsigned addr, uint8_t val) {
      ((uint8_t*)&data_[0])[addr] = val;
    }
    unsigned GetVectorLength() const { return vectorLength_; }
    virtual size_t GetByteSize() const { return data_.size() * sizeof(T); }
    unsigned GetTotalByteSize() const {
      return data_.size() * sizeof(T);
    }

    std::vector<T>& Data() { return data_; }
    const std::vector<T>& Data() const { return data_; }
    T* operator[](unsigned i) {
      return &data_[i*vectorLength_];
    }
    const T* operator[](unsigned i) const {
      return &data_[i*vectorLength_];
    }
    /// Vector access interfaces

    /// @brief Scalar read interface. The sequential address is row-major
    T ScalarRead(unsigned addr) {
      return data_[addr];
    }
    void ScalarWrite(unsigned addr, T val) {
      data_[addr] = val;
    }

    /// @brief copy a 32-bit array to the vector memory
    /// @param val the source array
    /// @param start start address. Assumed to be row-major word address
    void WriteBlock32(const std::vector<uint32_t>& val, unsigned start) {
      if (start >= data_.size())
        return;
      unsigned size = val.size() * sizeof(uint32_t);
      unsigned maxSize = (data_.size() - start) * sizeof(T);
      memcpy(&data_[start], &val[0], std::min(size, maxSize));
    }

    /// @brief copy a 32-bit array from the vector memory
    /// @param dst the destination array
    /// @param start start address. Assumed to be row-major word address
    void ReadBlock32(std::vector<uint32_t>& dst, unsigned start) {
      if (start >= data_.size())
        return;
      unsigned size = dst.size() * sizeof(uint32_t);
      unsigned maxSize = (data_.size() - start) * sizeof(T);
      memcpy(&dst[0], &data_[start], std::min(size, maxSize));
    }

    /// Vector access interfaces
    void VectorRead(std::vector<T>& dst, unsigned addr) {
      memcpy(&dst[0], &data_[addr*vectorLength_], vectorLength_*sizeof(T));
    }
    void VectorWrite(const std::vector<T>& src, unsigned addr,
                     const BitVector& predicate) {
      for (unsigned i = 0; i < vectorLength_; ++i) {
        if (predicate[i]) { data_[i] = src[i]; }
      }
    }

    void VectorReadBE(std::vector<T>& dst, unsigned addr, unsigned be) {
      unsigned byteMask = SimSRAMBase::GetByteMask(be);
      const std::vector<T>& src = data_[addr];
      for (unsigned i = 0; i < vectorLength_; ++i) {
        dst[i] = src[i] & byteMask;
      }
    }
    void VectorWriteBE(const std::vector<T>& src, unsigned addr, unsigned be) {
      unsigned byteMask = SimSRAMBase::GetByteMask(be);
      std::vector<T>& dst = data_[addr];
      for (unsigned i = 0; i < vectorLength_; ++i) {
        dst[i] = (src[i] & byteMask) | (dst[i] & ~byteMask);
      }
    }

    void VectorRead(T* dst, const std::vector<unsigned>& addr) {
      for (unsigned i = 0; i < vectorLength_; ++i) {
        unsigned wadr = addr[i]*vectorLength_ + i;
        if (wadr >= data_.size()) {
          Error(GetTimeStamp(), SimErrorCode::InvalidMemAddr,
                "Invalid vector read address "+ Int2DecString(wadr)
                +" (PE["+ Int2DecString(i) +"]["+ Int2DecString(addr[i]) +"])");
          return;
        }// if (wadr > data_.size())
        dst[i] = data_[wadr];
      }
    }
    void VectorWrite(const T* src, const std::vector<unsigned>& addr,
                     const BitVector& predicate) {
      for (unsigned i = 0; i < vectorLength_; ++i) {
        if (predicate[i]) {
          unsigned wadr = addr[i]*vectorLength_ + i;
          if (wadr >= data_.size()) {
          Error(GetTimeStamp(), SimErrorCode::InvalidMemAddr,
                "Invalid vector read address "+ Int2DecString(wadr)
                +" (PE["+ Int2DecString(i) +"]["+ Int2DecString(addr[i]) +"])");
          return;
        }// if (wadr > data_.size())
          data_[wadr] = src[i];
        }
      }
    }

    void VectorReadBE(std::vector<T>& dst,
                      const std::vector<unsigned>& addr, unsigned be) {
      unsigned byteMask = SimSRAMBase::GetByteMask(be);
      for (unsigned i = 0; i < vectorLength_; ++i) {
        dst[i] = data_[addr[i]*vectorLength_ + i] & byteMask;
      }
    }
    void VectorReadBE(std::vector<T>& dst, const std::vector<unsigned>& addr,
                      const std::vector<unsigned>& be) {
      for (unsigned i = 0; i < vectorLength_; ++i) {
        dst[i]=data_[addr[i]*vectorLength_+i] & SimSRAMBase::GetByteMask(be[i]);
      }
    }
    void VectorWriteBE(const std::vector<T>& src,
                       const std::vector<unsigned>& addr, unsigned be) {
      unsigned byteMask = SimSRAMBase::GetByteMask(be);
      for (unsigned i = 0; i < vectorLength_; ++i) {
        T& dst = data_[addr[i]*vectorLength_ + i];
        dst = (src[i] & byteMask) | (dst & ~byteMask);
      }
    }
    void VectorWriteBE(const std::vector<T>& src,
                       const std::vector<unsigned>& addr,
                       const std::vector<unsigned>& be) {
      for (unsigned i = 0; i < vectorLength_; ++i) {
        unsigned byteMask = SimSRAMBase::GetByteMask(be[i]);
        T& dst = data_[addr[i]*vectorLength_ + i];
        dst = (src[i] & byteMask) | (dst & ~byteMask);
      }
    }
  private:
    unsigned vectorLength_;
    std::vector<T> data_;
  };// class SimVectorSRAM
}// namespace ES_SIMD

#endif//ES_SIMD_SIMMEMORY_HH
