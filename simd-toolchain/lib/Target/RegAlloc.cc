#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRRegister.hh"
#include "SIR/SIRFunction.hh"
#include "Target/RegAlloc.hh"
#include "Target/InterferenceGraph.hh"
#include "Utils/DbgUtils.hh"
#include <cmath>

using namespace std;
using namespace ES_SIMD;

int ES_SIMD::
CreateBlockLiveIntervals (const SIRBasicBlock* bb,
                          BlockLiveInterval& blockLiveInterval,
                          tr1::unordered_map<int, float>& costMap) {
  Int2IntMap def;
  Int2IntMap lastUse;
  blockLiveInterval.clear();
  def.clear();
  lastUse.clear();
  cout <<"BB_"<< bb->GetBasicBlockID() <<" is in loop level "
       << bb->GetLoopDepth() <<"\n";
  // Simple loop-base cost estimation: 10 times more costly for each level
  float blockCostBase = pow(10.0f, bb->GetLoopDepth());
  for (SIRBasicBlock::li_const_iterator lIt = bb->li_begin();
       lIt != bb->li_end(); ++lIt) {
    def[(*lIt)->GetValueID()] = 0;
  }
  int t = 1;
  for (SIRBasicBlock::const_iterator iIt = bb->begin();
       iIt != bb->end(); ++iIt, ++t) {
    const SIRInstruction* instr = *iIt;
    for (SIRInstruction::operand_const_iterator oIt = instr->operand_begin();
         oIt != instr->operand_end(); ++oIt) {
      int ov = (*oIt)->GetValueID();
      if (SIRFunction::IsValidValueID(ov)) {
        ES_ASSERT_MSG(IsElementOf(ov, def), "Value used before def");
        lastUse[ov] = t;
        // Add spill cost for loading
        costMap[ov] += blockCostBase;
      }
    }
    int v = instr->GetValueID();
    if(SIRFunction::IsValidValueID(v)) {
      if (IsElementOf(v, lastUse) && (lastUse[v] >= 0)) {
        ES_ASSERT_MSG(IsElementOf(v, def), "Value used before def");
        ES_ASSERT_MSG(def[v] <= lastUse[v], "Backward life range for "<< v
                      <<" ["<< def[v] <<","<< lastUse[v] <<")");
        blockLiveInterval[v].AddLiveRange(def[v], lastUse[v]);
        // cout <<"LR_"<< v <<"["<< def[v] <<","<< lastUse[v] <<")\n";
      }
      def[v] = t;
      lastUse[v] = -1;
      // Add spill cost for storing
      costMap[v] += blockCostBase;
    }
  }// for bb iterator iIt
  for (SIRBasicBlock::li_const_iterator lIt = bb->lo_begin();
       lIt != bb->lo_end(); ++lIt) {
    lastUse[(*lIt)->GetValueID()] = t;
  }
  for (Int2IntMap::iterator vIt = lastUse.begin(); vIt != lastUse.end(); ++vIt) {
    if (lastUse[vIt->second] >= 0) {
      blockLiveInterval[vIt->first].AddLiveRange(def[vIt->first], vIt->second);
      // cout <<"LR_"<< vIt->first <<"["<< def[vIt->first] <<","<< vIt->second <<")\n";
    }
  }
  return t;
}// CreateBlockLiveIntervals()
