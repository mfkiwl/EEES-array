#ifndef ES_SIMD_TARGETBLOCKDATA_HH
#define ES_SIMD_TARGETBLOCKDATA_HH

#include "Target/TargetLiveInterval.hh"
#include "DataTypes/ContainerTypes.hh"
#include <json/json.h>

namespace ES_SIMD {
  class SIRBasicBlock;
  class SIRInstruction;
  class TargetIssuePacket;
  class DataDependencyGraph;

  class TargetBlockData {
  protected:
    SIRBasicBlock* bb_;
    bool scheduled_;
    int targetAddress_;
    int length_;
    std::list<TargetIssuePacket*> issueList_;
    DataDependencyGraph* ddg_;
    /// RegAlloc related
    std::vector<size_t> regPressure_;
    BlockLiveInterval   liveIntervals_;
    IntSet       defs_;
    IntSet       uses_;
    Int2FloatMap spillCost_;
    float        baseSpillCost_;
    TargetBlockData(SIRBasicBlock* bb)
      : bb_(bb), scheduled_(false), targetAddress_(-1),
        length_(0), ddg_(NULL), baseSpillCost_(1.0f) {}
    virtual void PrintCodeGenStat(std::ostream& o) const;
  public:
    typedef std::list<TargetIssuePacket*>::iterator         iterator;
    typedef std::list<TargetIssuePacket*>::const_iterator   const_iterator;
    typedef std::list<TargetIssuePacket*>::reverse_iterator reverse_iterator;
    typedef std::list<TargetIssuePacket*>::const_reverse_iterator   \
    const_reverse_iterator;

    SIRBasicBlock* BasicBlock() const   { return bb_; }
    DataDependencyGraph* GetDDG() const { return ddg_; }
    void SetDDG(DataDependencyGraph* d) { ddg_ = d; }

    bool IsScheduled() const  { return scheduled_; }
    void SetScheduled(bool s) { scheduled_ = s;    }
    void SetTargetAddress(int a) { targetAddress_ = a;    }
    int GetTargetAddress() const { return targetAddress_; }
    TargetIssuePacket* FindPacket(const SIRInstruction* instr) const;

    virtual void Reset();
    virtual ~TargetBlockData();

    virtual int GetTargetSize() const { return size(); }
    virtual void InitIssueTime();
    /// \brief Gets the time a value is used for the first time in this block
    /// \param v The value to be checked
    /// \return The time when v is first used. -1 if it's never used.
    int ValueFirstUsedTime(int v) const;
    /// \brief Gets the number of instructions use a value in this block
    /// \param v The value to be checked
    /// \return The number of instructions that use v.
    int ValueUseCount(int v) const;
    /// \brief Returns the time a value is defined for the last time in this block
    /// \param v The value to be checked
    /// \return The time when v is last defined. -1 if it's never defined.
    int ValueLastDefTime(int v) const;

    BlockLiveInterval&       LiveIntervals()       { return liveIntervals_; }
    const BlockLiveInterval& LiveIntervals() const { return liveIntervals_; }

    void IncSpillCost(int v, float c) { spillCost_[v] += c; }
    Int2FloatMap&       SpillCost()           { return spillCost_; }
    const Int2FloatMap& SpillCost()     const { return spillCost_; }
    void MergeSpillCostTo(Int2FloatMap& cost) const {
      for (Int2FloatMap::const_iterator it = spillCost_.begin();
           it != spillCost_.end(); ++it) {
        cost[it->first] += it->second;
      }
    }// MergeSpillCostTo()
    IntSet&             Defs()                { return defs_;      }
    const IntSet&       Defs()          const { return defs_;      }
    IntSet&             Uses()                { return uses_;      }
    const IntSet&       Uses()          const { return uses_;      }

    void PrintStatistics(std::ostream& o) const;
    virtual void Print(std::ostream& o) const = 0;
    virtual void ValuePrint(std::ostream& o) const;
    void DrawDDG(std::ostream& o) const;
    void DrawDDGSubTrees(std::ostream& o) const;
    void Dump(Json::Value& bInfo) const;

    bool   empty() const { return issueList_.empty(); }
    size_t size()  const { return issueList_.size();  }
    void push_back(TargetIssuePacket* packet) {
      issueList_.push_back(packet);
    }
    void push_front(TargetIssuePacket* packet) {
      issueList_.push_front(packet);
    }
    iterator insert(iterator pos, TargetIssuePacket* packet) {
      return issueList_.insert(pos, packet);
    }
    iterator erase(iterator pos)            { return issueList_.erase(pos); }
    TargetIssuePacket*&       front()       { return issueList_.front();    }
    TargetIssuePacket* const& front() const { return issueList_.front();    }
    TargetIssuePacket*&       back()        { return issueList_.back();     }
    TargetIssuePacket* const& back()  const { return issueList_.back();     }

    iterator       begin()       { return issueList_.begin(); }
    const_iterator begin() const { return issueList_.begin(); }
    iterator       end()         { return issueList_.end();   }
    const_iterator end()   const { return issueList_.end();   }
    reverse_iterator       rbegin()       { return issueList_.rbegin(); }
    const_reverse_iterator rbegin() const { return issueList_.rbegin(); }
    reverse_iterator       rend()         { return issueList_.rend();   }
    const_reverse_iterator rend()   const { return issueList_.rend();   }
  };// class TargetBlockData
};// namespace ES_SIMD

#endif//ES_SIMD_TARGETBLOCKDATA_HH

