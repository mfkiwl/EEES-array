#ifndef ES_SIMD_PASS_HH
#define ES_SIMD_PASS_HH

#include "DataTypes/Error.hh"
#include "DataTypes/Object.hh"
#include <iostream>
#include <string>
#include <vector>

namespace ES_SIMD {
  class SIRModule;
  class SIRFunction;
  class SIRBasicBlock;

  /// \brief Base class of all passes.
  class Pass : NonCopyable {
    std::string   name_; ///< Name of the pass.
    std::string   desc_; ///< Description of the pass.
  protected:
    unsigned           logLv_;
    std::ostream&      log_;
    std::ostream&      err_;
    std::vector<Error> errors_;
    void PassError(ErrorCode_t ec, const std::string& msg) {
      errors_.push_back(Error(ec, msg));
    }
    void PassError(ErrorCode_t ec, const std::string& msg,
                   const FileLocation& fLoc) {
      errors_.push_back(Error(ec, msg, fLoc));
    }
  public:
    typedef std::vector<Error>::iterator       err_iterator;
    typedef std::vector<Error>::const_iterator err_const_iterator;
    virtual ~Pass();

    /// \brief Run for each module, before anything is processed.
    virtual void ModuleInit (SIRModule* m);
    /// \brief Run after everything is done for the module.
    virtual void ModuleFinal(SIRModule* m);

    const std::string& GetName()        const { return name_; }
    const std::string& GetDescription() const { return desc_; }
    /// \brief Process an SIRModule.
    bool RunOnModule(SIRModule* m);

    void SetLogLevel(unsigned l) { logLv_ = l; }

    // For LLVM-style RTTI
    enum PassKind {
      PK_SIRModulePass,
      PK_SIRFunctionPass,
      PK_SIRLoopPass,
      PK_SIRBasicBlockPass
    };

    bool   err_empty() const { return errors_.empty(); }
    size_t err_size()  const { return errors_.size();  }
    void   err_clear()       { errors_.clear();        }
    err_iterator       err_begin()       { return errors_.begin(); }
    err_const_iterator err_begin() const { return errors_.begin(); }
    err_iterator       err_end()         { return errors_.end();   }
    err_const_iterator err_end()   const { return errors_.end();   }
  private:
    const PassKind kind_;
  public:
    PassKind getKind() const { return kind_; }
    const std::string getKindName() const {
      switch (kind_) {
      default: return "Pass";
      case PK_SIRModulePass    : return "SIRModulePass";
      case PK_SIRFunctionPass  : return "SIRFunctionPass";
      case PK_SIRLoopPass      : return "SIRLoopPass";
      case PK_SIRBasicBlockPass: return "SIRBasicBlockPass";
      }// switch (kind_)
    }
  protected:
    Pass(const std::string& name, const std::string& desc, unsigned logLv,
         std::ostream& log, std::ostream& err, PassKind pk)
      : name_(name), desc_(desc), logLv_(logLv),
        log_(log), err_(err), kind_(pk) {}
  };// class Pass

  /// \brief Base class for passes that operation on the whole SIRModule.
  /// \note  Every pass can be implemented as a module pass.
  ///        But in principle, one should make sure that a module really need
  ///        to access the whole module when processing.
  /// \see   SIRFunctionPass
  /// \see   SIRBasicBlockPass
  class SIRModulePass : public Pass {
  public:
    virtual ~SIRModulePass();
    /// \brief The actual processing.
    virtual bool RunOnSIRModule(SIRModule* m) = 0;

    /// For LLVM-style RTTI
    static bool classof(const Pass *v) {
      return v->getKind() == PK_SIRModulePass;
    }
  protected:
    SIRModulePass(const std::string& name, const std::string& desc,
                  unsigned logLv, std::ostream& log, std::ostream& err)
      : Pass(name, desc, logLv, log, err, PK_SIRModulePass) {}
  };// class SIRModulePass

  /// \brief Base class for passes that operation on a SIRFunction.
  /// \see   SIRModulePass
  /// \see   SIRBasicBlockPass
  class SIRFunctionPass : public Pass {
  public:
    virtual ~SIRFunctionPass();
    /// \brief The actual processing.
    virtual bool RunOnSIRFunction(SIRFunction* func) = 0;

    /// For LLVM-style RTTI
    static bool classof(const Pass *v) {
      return v->getKind() == PK_SIRFunctionPass;
    }
  protected:
    SIRFunctionPass(const std::string& name, const std::string& desc,
                    unsigned logLv, std::ostream& log, std::ostream& err)
      : Pass(name, desc, logLv, log, err, PK_SIRFunctionPass) {}
  };// class SIRFunctionPass

  /// \brief Base class for passes that operation on a SIRBasicBlock.
  /// \see   SIRModulePass
  /// \see   SIRFunctionPass
  class SIRBasicBlockPass : public Pass {
  public:
    virtual ~SIRBasicBlockPass();

    /// \brief Run for each function, before the pass runs on any basic block.
    virtual void FunctionInit (SIRFunction* func);
    /// \brief Run after all basic blocks in the function are processed.
    virtual void FunctionFinal(SIRFunction* func);
    /// \brief The actual processing.
    virtual bool RunOnSIRBasicBlock(SIRBasicBlock* bb) = 0;

    /// For LLVM-style RTTI
    static bool classof(const Pass *v) {
      return v->getKind() == PK_SIRBasicBlockPass;
    }
  protected:
    SIRBasicBlockPass(const std::string& name, const std::string& desc,
                      unsigned logLv, std::ostream& log, std::ostream& err)
      : Pass(name, desc, logLv, log, err, PK_SIRBasicBlockPass) {}
  };// class SIRFunctionPass
}// namespace ES_SIMD

#endif//ES_SIMD_PASS_HH
