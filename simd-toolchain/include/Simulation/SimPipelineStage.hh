#ifndef ES_SIMD_SIMPIPELINESTAGE_HH
#define ES_SIMD_SIMPIPELINESTAGE_HH

#include <algorithm>
#include "Simulation/SimObjectBase.hh"

namespace ES_SIMD {
  class SimOperation;

  /// \brief A wrapper around vector of SimOperation
  ///        [front      ---       back]
  ///        [N-th Stage --- 1-st Stage]
  class SimPipelineStage {
  public:
    SimPipelineStage()
      : subStages_(1),fill_(0),pipeInstrs_(1,static_cast<SimOperation*>(NULL)),
        prevStage_(NULL), nextStage_(NULL) {}
    SimPipelineStage(unsigned subStages)
      : subStages_(subStages), fill_(0),
        pipeInstrs_(subStages, static_cast<SimOperation*>(NULL)),
        prevStage_(NULL), nextStage_(NULL) {}
    void SetSubStages(unsigned n) {
      subStages_ = n;
      pipeInstrs_.resize(n, NULL);
    }
    void ConnectStage(const SimPipelineStage* p, const SimPipelineStage* n) {
      prevStage_ = p;
      nextStage_ = n;
    }
    unsigned GetNumOfSubStages() const { return subStages_; }
    /// \brief indicates whether a new instruction can be issue to this stage
    bool Ready() const {
      return pipeInstrs_.back() == NULL;
    }
    bool Empty() const {
      return fill_ == 0;
    }
    bool Filled() const {
      return fill_ == subStages_;
    }

    bool IssueOperation(const SimOperation* o) {
      if (Ready()) {
        pipeInstrs_.back() = o;
        ++fill_;
        return true;
      }
      return false;
    }

    void Reset(){
      std::fill(pipeInstrs_.begin(), pipeInstrs_.end(),
           static_cast<const SimOperation*>(NULL));
      fill_ = 0;
    }
    void Flush() { Reset(); }

    const SimOperation* Back() { return pipeInstrs_.back(); }
    const SimOperation* Advance() {
      const SimOperation* r = pipeInstrs_.front();
      if (fill_ > 0 ) {
        if (r != NULL) {
          if ((nextStage_ != NULL) && !nextStage_->Ready()){
            return r;
          }
          -- fill_;
        }// if (r != NULL)
        for (unsigned i = 0; i < (pipeInstrs_.size()-1); ++i) {
          pipeInstrs_[i] = pipeInstrs_[i+1];
        }
        pipeInstrs_.back() = NULL;
      }// if (fill_ > 0 )
      return r;
    }// Advance()
    const SimOperation*& operator[] (unsigned i) {
      return pipeInstrs_[i];
    }
    const SimOperation* const&  operator[] (unsigned i) const {
      return pipeInstrs_[i];
    }
  private:
    unsigned subStages_;
    unsigned fill_;
    std::vector<const SimOperation*> pipeInstrs_;
    const SimPipelineStage* prevStage_;
    const SimPipelineStage* nextStage_;
  };// class SimPipelineStage
}// namespace ES_SIMD

#endif//ES_SIMD_SIMPIPELINESTAGE_HH
















