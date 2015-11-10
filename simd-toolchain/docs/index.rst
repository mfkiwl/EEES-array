.. ES-SIMD documentation master file, created by
   sphinx-quickstart on Sun Aug 18 14:33:13 2013.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to ES-SIMD's documentation!
===================================

General Documentations
----------------------

:doc:`SIRLangRef`
 Defines the Solver IR (SIR) intermediate representation used by the backend.

:doc:`PythonBinding`
 Describes the Python binding of the libraries of the framework.

``simd-toolchain/tools``
------------------------

The **tools** directory contains the executables built out of the libraries,
which form the main part of the user interface.  You can always get help for
a tool by typing ``tool_name -help``.  The following is a brief introduction
to the most important tools.  More detailed information is in
the `Tool Guide <ToolGuide/index.html>`_.

Target Documentations
---------------------

The following targets are available:

- Baseline SIMD processor

:doc:`ArchConfig`
 Defines the file format for specifying the target architecture.

Below are the documentation for each target:

Baseline SIMD Architecture
~~~~~~~~~~~~~~~~~~~~~~~~~~

:doc:`BaselineISA`
 Defines the instruction set architecture (ISA) of the baseline architecture.

:doc:`BaselineABI`
 Defines the application binary interface (ABI) of the baseline architecture.

Development Documentations
--------------------------

:doc:`Testing`
 Describe the testing infrastructure of the framework.

.. toctree::
   :hidden:
   :maxdepth: 1

   ArchConfig
   BaselineISA
   BaselineABI
   SIRLangRef
   PythonBinding
   Testing
   ToolGuide/index

