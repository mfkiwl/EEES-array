s-as - ES-SIMD assembler
========================

SYNOPSIS
--------

:program:`s-as` [*options*] filename

DESCRIPTION
-----------

The :program:`s-as` command translates assembly for a specified architecture
into target binary.

The choice of architecture is determined by the :option:`-arch` option or the
:option:`-arch-cfg`.

OPTIONS
-------

The input files should be in ES-SIMD assembly format (``.s``).

Other :program:`s-as` options are described below.

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

   s-as -arch=baseline -arch-param pe:128,dmem-depth:2048

.. option:: -out-format=<format>
 Set the output file format. The default format is verilog memory init file.
 The following options are available:

 *verilog*  File compatible with $readmemh in Verilog.

 *asm*      Assembly ouput.

 *binary*   Binary.

Debuging/Information Options
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. option:: -parser-info-level
 
 Set the information level of parser. The default level is *none*.
 The following options are available:

 *none*     No information.

 *quick*    Enable quick debug information.

 *info*     Enable comprehensive debug information.

 *detailed* Enable most detailed debug information.

.. option:: -print-parsing
 
 Print parsing result to stdout.

.. option:: -quiet

 Suppress any terminal output.

.. option:: -verbose

 Run in verbose mode.

.. option:: -version

 Display the version of this program.

EXIT STATUS
-----------

If :program:`s-as` succeeds, it will exit with 0.  Otherwise, if an error
occurs, it will exit with a non-zero value.

SEE ALSO
--------

s-cg
s-cc

