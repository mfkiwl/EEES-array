#ifndef ES_SIMD_PROCESSINGDRIVER_HH
#define ES_SIMD_PROCESSINGDRIVER_HH

#include "DataTypes/Object.hh"
#include "DataTypes/ContainerTypes.hh"
#include "DataTypes/Error.hh"
#include <string>
#include <iostream>
#include <memory>
#include <json/json.h>

namespace ES_SIMD {
  class SIRModule;
  class SIRParser;
  class TargetBasicInfo;
  class TargetCodeGenEngine;
  class Pass;

  /// \brief A driver that controls the code generation process.
  class ProcessingDriver : NonCopyable {
  private:
    std::string name_;
    std::auto_ptr<SIRModule>           module_;
    std::auto_ptr<SIRParser>           irParser_;
    std::auto_ptr<TargetBasicInfo>     target_;
    std::auto_ptr<TargetCodeGenEngine> codeGenerator_;
    bool noSched_;
    bool printPassName_;
    bool printFuncInfo_;
    int  logLevel_;
    std::ostream& log_;
    std::ostream& err_;
    int passCount_;
    std::vector<Error> errors_;
    std::vector<Pass*> codeGenPasses_;
    bool RunPasses(std::vector<Pass*>& p, std::pair<int, int> r);
  public:
    typedef std::vector<Error>::iterator       err_iterator;
    typedef std::vector<Error>::const_iterator err_const_iterator;

    ProcessingDriver(const std::string& name, int logLevel,
                     std::ostream& log, std::ostream& err);
    ~ProcessingDriver();

    /// \brief Return the number of passes executed.
    int  GetExecutedPassCount() const { return passCount_; }
    /// \brief Return true if there is any error during the execution,
    ///        otherwise false.
    bool HasError() const { return !errors_.empty(); }
    /// \brief Print error messages.
    /// \param o The output stream for error messages.
    /// \return Returns true if there is any error during the execution,
    ///         otherwise false.
    bool PrintErrors(std::ostream& o) const;
    /// \brief Set the bare code generation mode.
    ///
    /// If bare mode is set to true, the code generator behaves differently:
    /// - No initialization code is emitted.
    /// - All functions in the IR will be preserved.
    /// - The order of the functions is the same as the IR input.
    /// \param b Whether the code generator should run in bare mode.
    void SetCodeGeneratorBareMode(bool b);
    /// \brief Instruct the code generator to preserve IR instruction order.
    ///
    /// If no-schedule is set to true, the code generator tries to preserve the
    /// instruction order in the IR input as much as possible.
    /// \param b Whether the code generator should run in no-schedule mode.
    void SetNoSchedule(bool b);
    /// \brief Initialize code generator with target name string.
    /// \param arch The name of the target architecture.
    void InitializeCodeGenerator(const std::string& arch);
    /// \brief Initialize code generator with target configuration.
    /// \param archCfg Thr JSON value of a valid target configuration.
    void InitializeCodeGenerator(const Json::Value& archCfg);
    /// \brief Set target parameter.
    /// \param param Parameter string, in the form of "key:value".
    void SetTargetParam(const std::string& param);
    /// \brief Set target parameter.
    /// \param key Name of the parameter to be set.
    /// \param val Value of the parameter to be set.
    /// \return true if the paramter is set successful, otherwise false.
    bool SetTargetParam(const std::string& key, const std::string& val);
    /// \brief Set up the code generation pipeline
    void InitTargetCodeGenPipeline();
    // Processing pipeline
    /// \brief Add a IR source file.
    /// \param src Filename of the source file to be added.
    void AddSIRSource(const std::string& src);
    /// \brief Run the code generation pipeline.
    void GenerateTargetCode();
    /// \brief Output the generated assembly code.
    /// \param out The output stream.
    void EmitTargetASM(std::ostream& out);
    /// \brief Print the symbol table
    /// \param out The output stream.
    void PrintSymbolTable(std::ostream& out) const;
    /// \brief Print the control flow table
    /// \param out The output stream.
    void PrintCFG(std::ostream& out) const;
    /// \brief Print the dot graph string of the DDG of a block
    void DrawDDG(const std::string& func, int bid, std::ostream& o) const;
    /// \brief Print the dot graph string of the sub-trees the DDG of a block
    void DrawDDGSubTrees(const std::string& func,int bid,std::ostream& o) const;
    /// \brief Run the code generation pipeline until the given pass.
    ///
    /// The code generation stops after a pass with the name passName is
    /// executed. If no such pass is in the pipeline, all passes are executed.
    /// \param passName Name of the pass.
    void RunUntil(const std::string& passName);

    // Utilities
    /// \brief Set code generator debug option.
    ///
    /// The following options are available:
    /// - translate: debug the SIR-to-Target translation process.
    /// - schedule: debug the instruction scheduling process.
    /// - trace-sched: detailed debug information of the scheduler.
    /// - regalloc: debug the register allocation.
    /// - spill: debug the early spilling.
    /// - postra: debug the post-register-allocation passes.
    /// - all: debug all above except trace-sched.
    /// - none: disable all debug info.
    // \param dbg The debug option
    bool SetCodeGenDbg(const std::string& dbg);
    const std::string& GetName() const { return name_; }
    /// \brief Print the IR parsing result.
    void PrettyPrintSIRParsing(std::ostream& o) const;
    /// \brief Print the generated code.
    void PrettyPrintTargetCode(std::ostream& o) const;
    /// \brief Print the statistics.
    void PrintCodeGenStat(std::ostream& o) const;
    /// \brief Dump detailed module information into a JSON
    void DumpModule(Json::Value& mInfo) const;
    /// \brief Print the names of all passes
    void PrintCodeGenPasses(std::ostream& o) const;
    void SetPrintPassName(bool b) { printPassName_ = (b || (logLevel_>0)); }
    void SetLogLevel(int l);
    /// \brief Set the debug level of a certain pass.
    /// \param n The name of the pass.
    /// \param l The debug level.
    void SetPassLogLevel(const std::string& n, int l);
    void SetIRParserLogLevel(int l);
    /// \brief Set whether to print the list of functions after IR finalization.
    void SetPrintFunctionInfo(bool b) { printFuncInfo_ = b; }

    bool   err_empty() const { return errors_.empty(); }
    size_t err_size()  const { return errors_.size();  }
    err_iterator       err_begin()       { return errors_.begin(); }
    err_const_iterator err_begin() const { return errors_.begin(); }
    err_iterator       err_end()         { return errors_.end();   }
    err_const_iterator err_end() const   { return errors_.end();   }
  private:
    bool SetPassesLogLv(std::pair<int, int>, int l);
    void AddCommomIRPasses();
    std::pair<int, int> irPasses_;
    std::pair<int, int> translatePasses_;
    std::pair<int, int> schedPasses_;
    std::pair<int, int> regAllocPasses_;
    std::pair<int, int> postRAPasses_;
  };// class ProcessingDriver
}// namespace ES_SIMD

#endif//ES_SIMD_PROCESSINGDRIVER_HH
