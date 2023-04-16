transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/altera/13.1/quartus/bin/all project/Final/routing.vhd}
vcom -93 -work work {C:/altera/13.1/quartus/bin/all project/Final/router_to_arbiter.vhd}
vcom -93 -work work {C:/altera/13.1/quartus/bin/all project/Final/register_file.vhd}
vcom -93 -work work {C:/altera/13.1/quartus/bin/all project/Final/NoC.vhd}
vcom -93 -work work {C:/altera/13.1/quartus/bin/all project/Final/FIFO_NODE.vhd}
vcom -93 -work work {C:/altera/13.1/quartus/bin/all project/Final/FIFO_controller.vhd}
vcom -93 -work work {C:/altera/13.1/quartus/bin/all project/Final/FIFO_BUFFER.vhd}
vcom -93 -work work {C:/altera/13.1/quartus/bin/all project/Final/arbiter.vhd}

vcom -93 -work work {C:/altera/13.1/quartus/bin/all project/Final/files/../NoC_tb.vhd}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cycloneiv_hssi -L cycloneiv_pcie_hip -L cycloneiv -L rtl_work -L work -voptargs="+acc"  NoC_tb

add wave *
view structure
view signals
run -all
