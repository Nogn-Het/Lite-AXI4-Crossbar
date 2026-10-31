transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/altera/13.0sp1/quartus/AXI4 {C:/altera/13.0sp1/quartus/AXI4/axi_arbiter.v}
vlog -vlog01compat -work work +incdir+C:/altera/13.0sp1/quartus/AXI4 {C:/altera/13.0sp1/quartus/AXI4/axi_decoder.v}
vlog -vlog01compat -work work +incdir+C:/altera/13.0sp1/quartus/AXI4 {C:/altera/13.0sp1/quartus/AXI4/axi_crossbar.v}

vlog -vlog01compat -work work +incdir+C:/altera/13.0sp1/quartus/AXI4 {C:/altera/13.0sp1/quartus/AXI4/tb_axi_crossbar.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneii_ver -L rtl_work -L work -voptargs="+acc"  tb_axi_crossbar

add wave *
view structure
view signals
run -all
