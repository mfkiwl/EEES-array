#ifndef ES_SIMD_SIRLOOP_HH
#define ES_SIMD_SIRLOOP_HH

#include "SIR/SIRValue.hh"

namespace ES_SIMD {
  class SIRFunction;
  class SIRBasicBlock;

  /// \brief Class for natural loops in SIR functions.
  ///
  /// An SIR loop belongs to one SIR function
  class SIRLoop : public SIRValue {
    friend class SIRParser;
    SIRFunction* parent_;   ///< The function this loop belongs to.
    unsigned loopID_;       ///< The loop ID within the function.
    unsigned loopDepth_;    ///< Depth. Equals to 1 for outter most loop.
    SIRBasicBlock* header_; ///< The header block.
    SIRLoop* upperLoop_;    ///< The loop that contains this loop.
    std::list<SIRBasicBlock*>   loopBlocks_;
    std::vector<SIRBasicBlock*> exitBlocks_;
    std::vector<SIRLoop*>       subLoops_;
  public:
    typedef std::list<SIRBasicBlock*>::iterator       iterator;
    typedef std::list<SIRBasicBlock*>::const_iterator const_iterator;
    typedef std::vector<SIRBasicBlock*>::iterator       exit_iterator;
    typedef std::vector<SIRBasicBlock*>::const_iterator exit_const_iterator;
    typedef std::vector<SIRLoop*>::iterator       sub_iterator;
    typedef std::vector<SIRLoop*>::const_iterator sub_const_iterator;

    SIRLoop(unsigned id, SIRFunction* func)
      :SIRValue(SIRValue::VK_Loop), parent_(func), loopID_(id), loopDepth_(1),
       header_(NULL), upperLoop_(NULL) {}
    ~SIRLoop();

    unsigned GetLoopID()    const { return loopID_;    }

    void SetLoopDepth(int d) { loopDepth_ = d; }
    unsigned GetLoopDepth() const { return loopDepth_; }

    SIRFunction* GetParent() const { return parent_; }

    void SetHeader(SIRBasicBlock* h) { header_ = h;    }
    SIRBasicBlock* GetHeader() const { return header_; }

    void AddBlock(SIRBasicBlock* b);
    void AddExitBlock(SIRBasicBlock* b);
    void AddSubLoop(SIRLoop* l);

    bool Contains(const SIRBasicBlock* b) const;
    bool Contains(const SIRLoop*       l) const;

    void     SetParentLoop(SIRLoop* l) { upperLoop_ = l;    }
    SIRLoop* GetParentLoop() const     { return upperLoop_; }

    /// Container interface and iterators
    bool   empty() const { return loopBlocks_.empty(); }
    size_t size()  const { return loopBlocks_.size();  }
    iterator       begin()       { return loopBlocks_.begin(); }
    const_iterator begin() const { return loopBlocks_.begin(); }
    iterator       end()         { return loopBlocks_.end();   }
    const_iterator end()   const { return loopBlocks_.end();   }

    bool   exit_empty() const { return exitBlocks_.empty(); }
    size_t exit_size()  const { return exitBlocks_.size();  }
    exit_iterator       exit_begin()       { return exitBlocks_.begin(); }
    exit_const_iterator exit_begin() const { return exitBlocks_.begin(); }
    exit_iterator       exit_end()         { return exitBlocks_.end();   }
    exit_const_iterator exit_end()   const { return exitBlocks_.end();   }

    bool   sub_empty() const { return subLoops_.empty(); }
    size_t sub_size()  const { return subLoops_.size();  }
    sub_iterator       sub_begin()       { return subLoops_.begin(); }
    sub_const_iterator sub_begin() const { return subLoops_.begin(); }
    sub_iterator       sub_end()         { return subLoops_.end();   }
    sub_const_iterator sub_end()   const { return subLoops_.end();   }
  };// class SIRLoop
}// namespace ES_SIMD

#endif//ES_SIMD_SIRLOOP_HH
