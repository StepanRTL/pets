set DESIGN_NAME "../rtl" 
set verilog_files [glob -nocomplain -dir ${DESIGN_NAME} *.sv]
foreach file ${verilog_files} {
	read_hdl -sv $file
}
set_db library /tools/PDK_DDK/CORELIB8DHS_3.1.a/liberty/wc_1.20V_105C/CORELIB8DHS.lib
elaborate
define_clock -name clk_i -period 10000 clk_i

syn_generic
syn_map
syn_opt

write_hdl > netlist.sv

report timing > reports/timing.rpt
report area   > reports/area.rpt
report power  > reports/power.rpt
report qor    > reports/qor.rpt
check_timing -verbose

exit
