#ifndef ES_SIMD_SIRMEMLOCATION_HH
#define ES_SIMD_SIRMEMLOCATION_HH

#include "SIR/SIRExpr.hh"
#include "DataTypes/Object.hh"
#include "DataTypes/SIROpcode.hh"
#include <memory>

namespace ES_SIMD {
  class SIRValue;
  class SIRFunction;
  class SIRRegister;

  /// \brief Class that holds address information for a memory access.
  ///
  /// This class is primarily used for analyzing vector kernel memory accesses.
  /// It contains some information that only make sense in vector context,
  /// such as row address and column offset.
  class SIRMemLocation : NonCopyable {
    SIRBinExprNode* addrExpr_;
    unsigned     shiftAmount_;
    int addrSpace_;
    SIRFunction* func_;
    SIRBinExprNode* kernelRowAddr_;
    SIRBinExprNode* kernelColOffset_;
    SIRRegister*    scalarBaseReg_;
  public:
    friend std::ostream& operator<<(std::ostream& o, const SIRMemLocation& t);
    SIRBinExprNode* GetExpr() const { return addrExpr_; }
    SIRMemLocation(SIRValue* base,SIRValue* offset,SIROpcode_t opc,
                   SIRFunction* func);
    ~SIRMemLocation();

    /// \brief Check if the memory address uses a value with the given ID.
    /// \param val The value ID to be checked.
    /// \return true if this memory location has a valid address expression that
    ///         uses a value with the given value ID, otherwise false.
    bool UsesValue(int val) const;
    /// \brief Check if the memory address uses a value with the given value.
    /// \param val The value to be checked.
    /// \return true if this memory location has a valid address expression that
    ///         uses the given value, otherwise false.
    bool UsesValue(SIRValue* val) const;
    /// \brief check if the address expression is in the form:
    ///        scalar_base + (offset << const_shift)
    bool IsStandardKernelForm() const;
    /// \brief check if the address expression is in the form:
    ///        scalar_base + (offset << const_shift) + const_shift
    bool IsShiftedStandardKernelForm() const;
    /// \brief Attempt to transform the memory address expression to standard
    ///        form.
    /// \return true if the expression is in standard form, otherwise false.
    bool TransformToStandardForm();

    void SetKernelAddress(SIRBinExprNode* ra, SIRBinExprNode* co);
    SIRRegister*    GetScalarBaseReg() const { return scalarBaseReg_;   }
    SIRBinExprNode* GetRowAddress()    const { return kernelRowAddr_;   }
    SIRBinExprNode* GetColumnOffset()  const { return kernelColOffset_; }
    unsigned              GetShiftAmount()   const { return shiftAmount_;     }


    SIRFunction* GetFunction() const { return func_; }
    int  GetAddressSpace() const { return addrSpace_; }
    std::ostream& Print(std::ostream& o) const;
  };// class SIRMemLocation()
}// namespace ES_SIMD

namespace std {
  namespace tr1 {
    /// For now, simply use the expression string for hashing
    template <> struct hash<ES_SIMD::SIRMemLocation*> {
      size_t operator()(const ES_SIMD::SIRMemLocation* e) const {
        return hash<ES_SIMD::SIRBinExprNode*>()(e->GetExpr());
      }
    };
  }// namespace tr1
}// namespace std

#endif// ES_SIMD_SIRMEMLOCATION_HH
