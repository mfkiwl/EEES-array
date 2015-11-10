FILE(REMOVE_RECURSE
  "CMakeFiles/py_solver_codegen"
  "__init__.py"
  "solver_codegen.py"
  "../../lib/solver/python/solver_codegen/__init__.py"
  "../../lib/solver/python/solver_codegen/solver_codegen.py"
)

# Per-language clean rules from dependency scanning.
FOREACH(lang)
  INCLUDE(CMakeFiles/py_solver_codegen.dir/cmake_clean_${lang}.cmake OPTIONAL)
ENDFOREACH(lang)
