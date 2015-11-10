#uses "xillib.tcl"

proc generate {drv_handle} {
  xdefine_include_file $drv_handle "xparameters.h" "solver_{{cfg.pe.size}}pe_{{cfg.get_tgt_attr()|replace('-', '_')}}" "NUM_INSTANCES" "DEVICE_ID" "C_BASEADDR" "C_HIGHADDR" 
}
