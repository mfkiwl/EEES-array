#include "SIR/SIRConstant.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRModule.hh"
#include "SIRModuleVerifier.hh"

using namespace ES_SIMD;
using namespace std;

SIRModuleVerifier::~SIRModuleVerifier() {}

bool SIRModuleVerifier::
RunOnSIRModule(SIRModule* m) {
  for(SIRModule::iterator it = m->begin(); it != m->end(); ++it){
    SIRFunction* func = *it;
    if (func->GetNumFormalArguments() != static_cast<int>(func->arg_size())) {
      errors_.push_back(
        Error(ErrorCode::IRParserError,
              func->GetName() +"() has inconsistent number of arguments",
              func->GetFileLocation()));
    }// if (func->GetNumFormalArguments() != func->arg_size())
    // Non-empty function should have an entry block
    if (!func->empty() && (func->GetEntryBlock() == NULL)) {
      errors_.push_back(
        Error(ErrorCode::IRParserError,
              "Function "+ func->GetName() +" has no entry block",
              func->GetFileLocation()));
    }// if (!func->empty() && (func->GetEntryBlock() == NULL))
    for(SIRFunction::iterator bIt=(*it)->begin(); bIt != (*it)->end(); ++bIt){
      for(SIRBasicBlock::iterator iIt=(*bIt)->begin();iIt!=(*bIt)->end();++iIt){
        SIRInstruction* instr = *iIt;
        for (SIRInstruction::operand_iterator oIt = instr->operand_begin();
             oIt != instr->operand_end(); ++oIt) {
          if (SIRConstant::classof(*oIt)) {
            SIRConstant* c = static_cast<SIRConstant*>(*oIt);
            // All symbol should be resolved before code generation
            if (c->IsSymbol()) {
              errors_.push_back(
                Error(ErrorCode::IRUndefinedSymbol,
                      "Undefined symbol \""+ c->GetSymbol() +"\"",
                      instr->GetFileLocation()));
            }
          }// if (llvm::isa<SIRConstant>(*oIt))
        }// for instr operand_iterator oIt
      }// for bb iterator oIt
    }// for sunc iterator bIt
  }// for m iterator it
  return false;
}// RunOnSIRModule()
