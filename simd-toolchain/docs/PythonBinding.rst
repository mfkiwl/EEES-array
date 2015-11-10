=======================
ES-SIMD Python Bindings
=======================

This pages contains a brief introduction to Python bindings for the framework.
More details can be found in the documentation of the packages.

Code Generation
---------------

The Python bindings for the code generation is in the ``solver_codegen`` package.

A class ``SolverCodeGen`` is provided to run the code generation. Below is an
example of using this class:

.. code-block:: python
   
   >> import solver_codegen
   >> cg = solver_codegen.SolverCodeGen('baseline.json')
   >> cg.add_ir('test.sir')
   >> cg.generate_target_code()
   >> cg.save_target_asm('test.s')

Alternatively, you can use the ``compile_sir_to_target`` function to compile a
list of SIR file into target assembly:

.. code-block:: python
   
   >> import solver_codegen
   >> solver_codegen.compile_sir_to_target(test.sir, arch='baseline.json', out='test.s')

Simulation
----------

The Python bindings for the simulation is in the ``solver_sim`` package.

A class ``SolverSim`` is provided to run the simulator. Below is an example of
using this class:

.. code-block:: python
   
   >> import solver_sim
   >> sim = solver_sim.SolverSim('baseline.json')
   >> sim.add_program_init('test')
   Loading test.cp.imem_init
   Loading test.pe.imem_init
   Loading test.cp.dmem_init
   Loading test.pe.dmem_init
   >> sim.reset()
   >> sim.run()
   10L
   >> sim.cycle()
   10L
