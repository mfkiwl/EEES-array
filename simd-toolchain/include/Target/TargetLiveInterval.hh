#ifndef ES_SIMD_TARGETLIVEINTERVAL_HH
#define ES_SIMD_TARGETLIVEINTERVAL_HH

#include "DataTypes/ContainerTypes.hh"
#include <algorithm>

namespace ES_SIMD {
  /// \brief A TargetLiveRange represents a continuous live range of time steps.
  ///
  /// A live range is basically a pair of time stamp start_ and end_.
  /// The live range it represents is [start_, end_)
  struct TargetLiveRange {
    int start_;
    int end_;
    /// \brief Check if a time step is within the time range
    /// \param t The time step to be checked.
    /// \return Returns true if t is in this range, otherwise false.
    bool Contains(int t) const {
      return ((t > start_) && (t < end_)) || (t == start_);
    }
    /// \brief Check if another range is completely contained by this range.
    /// \param lr The range to be checked.
    /// \return Returns true if lr is completely contained in this range,
    ///         otherwise false.
    bool Contains(const TargetLiveRange& lr) const {
      return ((lr.start_ >= start_) && (lr.end_ <= end_));
    }
    /// \brief Check if another range overlaps with this range
    /// \param lr The range to be checked.
    /// \return Returns true if lr overlaps with this range, otherwise false.
    bool Overlaps(const TargetLiveRange& lr) const {
      return Contains(lr.start_) || lr.Contains(start_);
    }
    TargetLiveRange() : start_(0), end_(0){}
    TargetLiveRange(int s, int e) : start_(s), end_(e){}
  };

  /// \brief A class to represent live interval of an SIRValue in the backend.
  ///
  /// A live interval may contain one or more live ranges.
  class TargetLiveInterval {
    std::vector<TargetLiveRange> liveRanges_;
  public:
    friend std::ostream& operator<<(std::ostream& o,
                                    const TargetLiveInterval& li) {
      for (std::vector<TargetLiveRange>::const_iterator it = li.liveRanges_.begin();
           it != li.liveRanges_.end(); ++it) {
        if (it != li.liveRanges_.begin()) { o <<", "; }
        o <<"["<< it->start_ <<","<< it->end_ <<")";
      }
      return o;
    }
    bool operator<(const TargetLiveInterval& rhs) const;
    /// \brief Insert a live range [s, e).
    /// \param s The starting point of the live range to be added.
    /// \param e The end point of the live range to be added.
    void AddLiveRange(int s, int e) {
      std::vector<TargetLiveRange>::iterator it;
      for (it = liveRanges_.begin(); it != liveRanges_.end(); ++it) {
        if (it->start_ > e) {
          break;// Insertion point found
        } else if (it->end_ >= s) {
          // There is overlap, ranges should be join
          it->start_ = std::min(it->start_, s);
          it->end_   = std::max(it->end_,   e);
          return;
        }
      }
      liveRanges_.insert(it, TargetLiveRange(s, e));
    }
    /// \brief Check if the value is alive at the specified time.
    /// \param t The time step to check.
    /// \return Returns true if t is in this live interval, otherwise false.
    bool AliveAt(int t) const {
      for (unsigned i = 0; i < liveRanges_.size(); ++i) {
        if (liveRanges_[i].Contains(t))
          return true;
      }
      return false;
    }
    /// \brief Check if another range overlaps with this interval
    /// \param lr The range to be checked.
    /// \return Returns true if lr overlaps with this interval, otherwise false.
    bool Overlaps(const TargetLiveRange& lr) const {
      for (unsigned i = 0; i < liveRanges_.size(); ++i) {
        if (liveRanges_[i].Overlaps(lr))
          return true;
      }
      return false;
    }
    /// \brief Check if another interval overlaps with this interval
    /// \param li The interval to be checked.
    /// \return Returns true if li overlaps with this interval, otherwise false.
    bool Overlaps(const TargetLiveInterval& li) const {
      for (unsigned i = 0; i < liveRanges_.size(); ++i) {
        if (li.Overlaps(liveRanges_[i]))
          return true;
      }
      return false;
    }
  };// class TargetLiveInterval

  typedef std::tr1::unordered_map<int, TargetLiveInterval> BlockLiveInterval;
}// namesapce ES_SIMD

#endif//ES_SIMD_TARGETLIVEINTERVAL_HH
