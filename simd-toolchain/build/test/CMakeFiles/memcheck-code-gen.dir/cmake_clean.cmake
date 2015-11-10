FILE(REMOVE_RECURSE
  "CMakeFiles/memcheck-code-gen"
)

# Per-language clean rules from dependency scanning.
FOREACH(lang)
  INCLUDE(CMakeFiles/memcheck-code-gen.dir/cmake_clean_${lang}.cmake OPTIONAL)
ENDFOREACH(lang)
