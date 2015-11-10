FILE(REMOVE_RECURSE
  "CMakeFiles/check-code-gen"
)

# Per-language clean rules from dependency scanning.
FOREACH(lang)
  INCLUDE(CMakeFiles/check-code-gen.dir/cmake_clean_${lang}.cmake OPTIONAL)
ENDFOREACH(lang)
