#ifndef ES_SIMD_TIMER_HH
#define ES_SIMD_TIMER_HH

#include <iostream>
#include <string>

#ifdef _WIN32
#include <windows.h>
#else//_WIN32
#include <sys/time.h>
#endif//_WIN32

namespace ES_SIMD {
  /// \class Timer
  /// \brief A generic timer class.
  /// 
  /// The Timer class provides a generic and cross-platform timer. On *nix
  /// platforms it uses gettimeofday(). On Windows, it uses the performance
  /// counter APIs to get precise timing information.
  /// Usage:
  /// \code
  ///      Timer tmr("TestTimer");
  ///      tmr.Start();
  ///      // Do something...
  ///      tmr.Stop();
  ///      double t = tmr.GetTimerIntervalMilliSec();
  /// \endcode
  class Timer {
  public:
    /// \brief Default constructor. The default timer name is "anonymous".
    Timer() : name_("anonymous"), running_(false){}
    /// \brief Constructor with timer name.
    Timer(const std::string& n) : name_(n), running_(false) {}
    /// \brief Start the timer.
    /// \see Stop()
    void Start() {
      running_ = true;
#ifdef _WIN32
      QueryPerformanceCounter((LARGE_INTEGER*)&startTime_);
#else//_WIN32
      gettimeofday(&startTime_, 0);
#endif//_WIN32
    }
    /// \brief Stop the timer.
    /// \see Start()
    void Stop() {
      running_ = false;
#ifdef _WIN32
      QueryPerformanceCounter((LARGE_INTEGER*)&finishTime_);
#else//_WIN32
      gettimeofday(&finishTime_, 0);
#endif//_WIN32
    }
    /// \brief Get time interval of the last timing cycle in milli-second.
    /// \note This method does not stop the timer. And if Stop() is not called
    ///       properly, it cannot produce the correct result.
    /// \return The time interval between the last Stop() and Start().
    /// \see Start()
    /// \see Stop()
    double GetTimerIntervalMilliSec() const;
    friend std::ostream& operator<<(std::ostream& o, const Timer&t);
  protected:
    std::string name_; ///< Timer name
    bool running_;     ///< Flag that indicates whether the timer is running
#ifdef _WIN32
    static double freq;///< System frequency for time interval calculation

    LARGE_INTEGER startTime_;   ///< Time when last Start() is called
    LARGE_INTEGER finishTime_;  ///< Time when last Stop() is called
#else//_WIN32
    struct timeval startTime_;  ///< Time when last Start() is called
    struct timeval finishTime_; ///< Time when last Stop() is called
#endif//_WIN32
  };// class Timer

  std::ostream& operator<<(std::ostream& o, const Timer&t);
}// namespace ES_SIMD

#endif//ES_SIMD_TIMER_HH
