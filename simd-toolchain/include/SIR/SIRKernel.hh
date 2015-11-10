#ifndef ES_SIMD_SIRKERNEL_HH
#define ES_SIMD_SIRKERNEL_HH

#include "SIR/SIRValue.hh"
#include "SIR/SIRExpr.hh"
#include "DataTypes/ContainerTypes.hh"
#include "DataTypes/FileLocation.hh"

namespace ES_SIMD {
  class SIRFunction;
  class SIRBasicBlock;
  class SIRRegister;

  /// \brief Struct that holds the launch parameter of a vector kernel.
  struct SIRKernelLaunch {
    int globalDim_;
    int groupDim_;
    int numGroups_[3];
    int groupSize_[3];
    /// \brief Default constructor. Parameters are initialized to invalid values
    /// to indicate launch parameters that are not known at compile time.
    SIRKernelLaunch() : globalDim_(0), groupDim_(0) {
      for (unsigned i = 0; i < 3; ++i) {
        numGroups_[i] = groupSize_[i] = 0;
      }
    }
    SIRKernelLaunch(const SIRKernelLaunch& k)
      : globalDim_(k.globalDim_), groupDim_(k.groupDim_) {
      for (int i = 0; i < 3; ++i) {
        numGroups_[i] = k.numGroups_[i];
        groupSize_[i] = k.groupSize_[i];
      }
    }
    SIRKernelLaunch& operator=(const SIRKernelLaunch& k) {
      globalDim_ = k.globalDim_;
      groupDim_  = k.groupDim_;
      for (int i = 0; i < 3; ++i) {
        numGroups_[i] = k.numGroups_[i];
        groupSize_[i] = k.groupSize_[i];
      }
      return *this;
    }
    bool Valid() const {
      if ((globalDim_ <= 0) || (groupDim_ <= 0)) { return false; }
      if ((globalDim_ >= 3) || (groupDim_ >= 3)) { return false; }
      for (int i = 0; i < globalDim_; ++i) {
        if (numGroups_[i] <= 0) { return false; }
      }
      for (int i = 0; i < groupDim_; ++i) {
        if (groupSize_[i] <= 0) { return false; }
      }
      return true;
    }
    /// Brief Should be call when initializing a kernel launch. So unlike the
    /// default constructor, default values are all valid.
    void clear() {
      globalDim_ = groupDim_ = 1;
      for (unsigned i = 0; i < 3; ++i) {
        numGroups_[i] = 1;
        groupSize_[i] = 1;
      }
    }

    unsigned GetGroupSize(unsigned i) const { return groupSize_[i]; }
    unsigned GetGroupDim()  const { return groupDim_;  }
    unsigned GetGlobalDim() const { return globalDim_; }

    unsigned GetTotalNumGroups() const {
      if ((globalDim_ <= 0) || (globalDim_ > 3)) { return  0; }
      unsigned n = numGroups_[0];
      for (int i = 1; i < globalDim_; ++i) {
        n *= numGroups_[i];
      }
      return n;
    }
    unsigned GetTotalGroupSize() const {
      if ((groupDim_ <= 0) || (groupDim_ > 3)) { return  0; }
      unsigned n = groupSize_[0];
      for (int i = 1; i < groupDim_; ++i) {
        n *= groupSize_[i];
      }
      return n;
    }
    friend std::ostream& operator<<(std::ostream& o, const SIRKernelLaunch& k);
  };// SIRKernelLaunch

  /// \brief A class that holds the information of a vector kernel.
  ///
  /// A kernel is associated with a function. This class holds the special
  /// registers, launch paramters, and helper blocks of a vector kernel.
  class SIRKernel : public SIRValue {
    friend class SIRParser;
    SIRFunction* parent_;

    SIRRegister* localID_[3];
    SIRRegister* groupID_[3];
    SIRRegister* globalID_[3];

    SIRRegister* numGroup_[3];
    SIRRegister* groupSize_[3];
    SIRRegister* globalSize_[3];

    SIRRegister* localDimCnt_ [3];  ///< Local counter for each dimension
    SIRRegister* groupDimCnt_ [3];  ///< Group counter for each dimension
    SIRRegister* globalDimCnt_[3]; ///< Global counter for each dimension

    SIRRegister* localCounter_;  ///< Unified local counter
    SIRRegister* groupCounter_;  ///< Unified group counter
    SIRRegister* globalCounter_; ///< Unified global counter

    SIRRegister* kernelStackPointer_;
    SIRRegister* launchFramePointer_;

    SIRRegister* localPredicate_;
    std::tr1::unordered_map<std::string, SIRRegister*> specialRegs_;
    IntSet     virtualSpecialRegs_;
    Int2IntMap virSRegValueLUT_;

    SIRKernelLaunch launchParams_;
    SIRBasicBlock* localHdrBlk_;
    SIRBasicBlock* localPreHdrBlk_;
    SIRBasicBlock* localExtBlk_;
    SIRBasicBlock* globalHdrBlk_;
    SIRBasicBlock* globalPreHdrBlk_;
    SIRBasicBlock* globalExtBlk_;

    std::tr1::unordered_map<SIRBinExprNode*, SIRValue*> exprCache_;
  public:
    enum {
      GLOBAL_ID_X, GLOBAL_ID_Y, GLOBAL_ID_Z,
      GROUP_ID_X,  GROUP_ID_Y,  GROUP_ID_Z,
      LOCAL_ID_X,  LOCAL_ID_Y,  LOCAL_ID_Z
    };

    SIRKernel(SIRFunction* func);
    virtual ~SIRKernel();

    void InitCodeGen();
    // Helper for SIR parsing
    SIRRegister* GetSpecialRegister(const std::string& reg) const;
    SIRFunction* GetParent() const { return parent_; }

    SIRValue* GetCachedExprValue(SIRBinExprNode* expr) const {
      return IsElementOf(expr, exprCache_) ? GetValue(expr, exprCache_) : NULL;
    }
    void SetExprValue(SIRBinExprNode* expr, SIRValue* v) {
      exprCache_[expr] = v;
    }

    SIRKernelLaunch&       GetLaunchParams()       { return launchParams_; }
    const SIRKernelLaunch& GetLaunchParams() const { return launchParams_; }
    void SetLocalHeader    (SIRBasicBlock* bb) { localHdrBlk_     = bb; }
    void SetLocalPreHeader (SIRBasicBlock* bb) { localPreHdrBlk_  = bb; }
    void SetLocalExit      (SIRBasicBlock* bb) { localExtBlk_     = bb; }
    void SetGlobalHeader   (SIRBasicBlock* bb) { globalHdrBlk_    = bb; }
    void SetGlobalPreHeader(SIRBasicBlock* bb) { globalPreHdrBlk_ = bb; }
    void SetGlobalExit     (SIRBasicBlock* bb) { globalExtBlk_    = bb; }
    SIRBasicBlock* GetLocalHeader    () const { return localHdrBlk_;     }
    SIRBasicBlock* GetLocalPreHeader () const { return localPreHdrBlk_;  }
    SIRBasicBlock* GetLocalExit      () const { return localExtBlk_;     }
    SIRBasicBlock* GetGlobalHeader   () const { return globalHdrBlk_;    }
    SIRBasicBlock* GetGlobalPreHeader() const { return globalPreHdrBlk_; }
    SIRBasicBlock* GetGlobalExit     () const { return globalExtBlk_;    }

    SIRRegister* GetLocalCounter()   const { return localCounter_;   }
    SIRRegister* GetGroupCounter()   const { return groupCounter_;   }
    SIRRegister* GetGlobalCounter()  const { return globalCounter_;  }
    SIRRegister* GetLocalPredicate() const { return localPredicate_; }

    int GetVirtualSRegID(int v) {
      return IsElementOf(v,virSRegValueLUT_)?GetValue(v,virSRegValueLUT_) : -1;
    }

    SIRRegister* GetVirtualSRegFromID(int i) const;

    bool IsVirtualSpecialReg(int v) const {
      return IsElementOf(v, virtualSpecialRegs_);
    }

    bool IsSpecialRegister(int v) const;

    bool IsGlobalCounter(int v) const;
    bool IsLocalCounter(int v) const;
    int  GetGlobalDimCounterIndex(int v) const;
    int  GetGlobalDimCounterIndex(SIRValue* v) const;
    int  GetGlobalDimCounterMax(int i) const {
      return launchParams_.numGroups_[i]*launchParams_.groupSize_[i]-1;
    }
#undef DECALARE_DIM_ACCESS
#define DECALARE_DIM_ACCESS(N, VN)                  \
    SIRRegister* Get##N(unsigned dim) const {       \
      return (dim < 3) ? VN[dim] : NULL;          \
    }

    DECALARE_DIM_ACCESS(LocalID,          localID_)
    DECALARE_DIM_ACCESS(GroupID,          groupID_)
    DECALARE_DIM_ACCESS(GlobalID,         globalID_)
    DECALARE_DIM_ACCESS(NumGroup,         numGroup_)
    DECALARE_DIM_ACCESS(GroupSize,        groupSize_)
    DECALARE_DIM_ACCESS(GlobalSize,       globalSize_)
    DECALARE_DIM_ACCESS(LocalDimCounter,  localDimCnt_)
    DECALARE_DIM_ACCESS(GroupDimCounter,  groupDimCnt_)
    DECALARE_DIM_ACCESS(GlobalDimCounter, globalDimCnt_)
#undef DECALARE_DIM_ACCESS
    // LLVM-style RTTI
    static bool classof(const SIRValue *v) {
      return v->getKind() == VK_Kernel;
    }
  };// class SIRKernel
}// namespace ES_SIMD

#endif//ES_SIMD_SIRKERNEL_HH

