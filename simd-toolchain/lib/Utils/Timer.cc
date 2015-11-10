#include "Utils/Timer.hh"

using namespace ES_SIMD;

#ifdef _WIN32
static double
GetFreq() {
  LARGE_INTEGER tmp;
  QueryPerformanceFrequency((LARGE_INTEGER*)&tmp);
  freq = (double)tmp.QuadPart/1000.0;
}

double Timer::freq = GetFreq();
#endif

double Timer::
GetTimerIntervalMilliSec() const {
  double interval = 0.0f;
#ifdef _WIN32
  interval = (double)(finishTime_.QuadPart - startTime_.QuadPart) / freq;
#else
  // time difference in milli-seconds
  interval = 1000.0*(finishTime_.tv_sec - startTime_.tv_sec)
    +(0.001*(finishTime_.tv_usec - startTime_.tv_usec));
#endif//_WIN32
  return interval;
}// GetTimerIntervalMilliSec()

std::ostream& ES_SIMD::
operator<<(std::ostream& o, const Timer&t) {
  o <<"T_"<< t.name_;
  if (t.running_) {
    o << " value undefined, timer is still running";
  } else {
    double tt = t.GetTimerIntervalMilliSec();
    // More than 10 sec, print in sec
    if (tt > 10000.0)
      o <<" = "<< tt/1000.0 << "s";
    else
      o <<" = "<< tt << "ms";
  }
  return o;
}
