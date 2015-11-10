s-rtl-gen - ES-SIMD RTL generator
=================================

SYNOPSIS
--------

:program:`s-rtl-gen` [*options*] config.json

DESCRIPTION
-----------

The :program:`s-rtl-gen` command generates the RTL and testbench files for
a specified architecture.

The target architecture is determined by the configuration file ``config.json``.

The output of :program:`s-rtl-gen` contains:

 *rtl/*

 Folder containing all the RTL source codes.

 *define/*

 Folder containing all RTL include files.

 *testbench/*

 Folder containing all testbench files.

 *misc/*

 Miscellaneous files for various purposes, currently the following files are
 generated:
 
  * ``vsim.compile.do`` - TCL script for Modelsim compilation.

  * ``vsim.run.do`` - TCL script for Modelsim simulation.

  * ``filelist.txt`` - List of generated verilog files. It can be used by,
    for example, Icarus Verilog (:program:`iverilog`).

OPTIONS
-------

The input file is a architecture configuration file in JSON format (``.json``).

To allow :program:`s-rtl-gen` to function properly. The following path should
be set:

 *SOLVER_HOME*

 Path to the ES-SIMD toolchain installation. It can be set by environment
 variable or by :option:`--solver-prefix` option.
 If this option is not set, :option:`--solver-py-path` and :option:`--solver-rtl-root`
 has to be set to proper value.

If the :option:`-o` option is omitted, then :program:`s-rtl-gen` will send its
output to ``RTL-$target_attr`` folder in the current working directory,
where ``target_attr`` is a string describes the targets.

Other :program:`s-rtl-gen` options are described below.

End-user Options
~~~~~~~~~~~~~~~~

.. option:: -h, --help

 Show the help message and exit.

.. option:: -v, --verbose

 Run in verbose mode.

.. option:: -o OUTPUT_DIR

 Path to the output files. **All existing files in the output directory will be
 deleted.**

.. option:: --target

 Specific target platform. Some target-specific optimization may be enabled.
 Currently two options are available:

 *generic*

 Generic synthesizable RTL. It is suitable for all purposes, including ASIC.

 *xilinx*

 RTL for Xilinx FPGA. It enables the following optimization(s):

 * Use distributed RAM for small memory blocks (e.g., the RF).

 * Disable operand isolation for FUs.

.. option:: --xil-pcore

 Generate pcore package that can be used in Xilinx EDK projects.

.. option:: --xil-sys-type=XIL_SYS_TYPE

 Set the system interface type for Xilinx pcore IP. The default is axilite.
 It is only useful if :option:`--xil-pcore` is used.

.. option:: --sys-addr-size=SYS_ADR_SIZE

 System address space size for the Xilinx pcore IP. The default value is 1M.
 The option accepts a positive number of bytes or a valid size string (e.g.,
 1M, 1MB or 256 KB). It is only useful if :option:`--xil-pcore` is used.

Tool Options
~~~~~~~~~~~~

.. option:: --solver-prefix=SOLVER_HOME

 Specify path to ES-SIMD toolchain installation path (default=$SOLVER_HOME).

.. option:: --solver-py-path=SOLVER_PY_PATH

 Specify path to Solver Python modules (default=$SOLVER_HOME/lib/solver/python).

.. option:: --solver-rtl-root=SOLVER_RTL_ROOT

 Specify path to RTL root directory (default=$SOLVER_HOME/share/solver/rtl).

EXIT STATUS
-----------

If :program:`s-rtl-gen` succeeds, it will exit with 0. Otherwise, if an error
occurs, it will exit with a non-zero value.

SEE ALSO
--------

s-run-sim

