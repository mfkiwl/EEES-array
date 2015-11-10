FILE(REMOVE_RECURSE
  "CMakeFiles/solverasmgen"
  "../../bin/s-as-gen"
)

# Per-language clean rules from dependency scanning.
FOREACH(lang)
  INCLUDE(CMakeFiles/solverasmgen.dir/cmake_clean_${lang}.cmake OPTIONAL)
ENDFOREACH(lang)
