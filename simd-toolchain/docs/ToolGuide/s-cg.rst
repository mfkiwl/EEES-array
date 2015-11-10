s-cg - ES-SIMD code generator
=============================

SYNOPSIS
--------

:program:`s-cg` [*options*] filename

DESCRIPTION
-----------

The :program:`s-cg` command compiles SIR source inputs into assembly language
for a specified architecture.  The assembly language output can then be passed
through a assembler to generate an executable.

The choice of architecture is determined by the :option:`-arch` option or the
:option:`-arch-cfg`.

OPTIONS
-------

The input files should be in SIR assembly format (``.sir``).

If the :option:`-o` option is omitted, then :program:`s-cg` will write the
result to a default output file ``out.s``.

Other :program:`s-cg` options are described below.

End-user Options
~~~~~~~~~~~~~~~~

.. option:: -help

 Print a summary of command line options.

.. option:: -o=<filename>

 Specify the output filename.

.. option:: -arch=<arch>

 Specify the architecture for which to generate assembly. If no architecture
 configuration file is specified by :option:`-arch-cfg`, the default target
 architecture is "baseline", which is a baseline 32-bit processor with 4 PE
 and explicit bypassing in both CP and PE.

 If the architecture is different from the one specified by the configuration
 file, this option is ignored.

.. option:: -arch-cfg=<arch.json>

 Specify an architecture configuration file in JSON format.

.. option:: -arch-param=<params>
 
 Set specific architecture architecture parameters. A paramter is specified
 with a key:value pair. Multiple parameters are separated by comma.

 For example, the following command sets the number of PE to 128 and the
 number of data memory entries to 2048:

.. code-block:: none

   s-cg -arch=baseline -arch-param pe:128,dmem-depth:2048

.. option:: -no-sched

 Scheduler keep the IR order as much as possible.

.. option:: -bare

 Run in bare mode, the code generator layout functions in IR order and does not
 try to run the linking process.

.. option:: -parse-only

 Stop after all IR files are parsed.
  
.. option::  -init-asm=<filename>
 
 Specify initalization assembly files. The content of the files will be added to
 the output file.

Debuging/Information Options
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. option:: -cg-dbg=<key>
 
  Code generator debug option

.. option:: -parser-info-level
 
 Set the information level of IR parser. The default level is *none*.
 The following options are available:

 *none*     No information.

 *quick*    Enable quick debug information.

 *info*     Enable comprehensive debug information.

 *detailed* Enable most detailed debug information.

.. option:: -print-codegen-stat

 Print code generation statistics.

.. option:: -print-generate

 Print code generation result to stdout.

.. option:: -print-parsing

 Print parsing result to stdout.

.. option:: -print-pass-name

 Print the name of each pass executed.

.. option:: -log-pass <pass>

 Enable logging of specified passes. Multiple names are separated by comma.

.. option:: -quiet

 Suppress any terminal output.

.. option:: -verbose

 Run in verbose mode.

.. option:: -version

 Display the version of this program.

EXIT STATUS
-----------

If :program:`s-cg` succeeds, it will exit with 0.  Otherwise, if an error
occurs, it will exit with a non-zero value.

SEE ALSO
--------

s-as
s-cc
