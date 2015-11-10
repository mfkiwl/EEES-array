#include "Utils/DbgUtils.hh"
#include "Config.hh"

#if HAVE_EXECINFO_H
# include <execinfo.h>         // For backtrace().
#define BACKTRACE_SIZE 256
#endif

using namespace std;
using namespace ES_SIMD;

void ES_SIMD::
PrintStackTrace() {
#ifndef NDEBUG
#if HAVE_EXECINFO_H
  void *buffer[BACKTRACE_SIZE];
  char **strings;
  int nptrs = backtrace(buffer, BACKTRACE_SIZE);
  // cerr printf("backtrace() returned %d addresses\n", nptrs);

  /* The call backtrace_symbols_fd(buffer, nptrs, STDOUT_FILENO)
     would produce similar output to the following: */

  strings = backtrace_symbols(buffer, nptrs);
  if (strings) {
    // Skip the first one: it is this function
    for (int j = 1; j < nptrs; ++j) { cerr << strings[j] <<'\n'; }
    free(strings);
  }
#endif  //#if HAVE_EXECINFO_H
#endif  //#ifndef NDEBUG
}// PrintStackTrace()

