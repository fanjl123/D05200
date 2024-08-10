#set sys_path      E:/Work/D05200/src/system_code
set sim_path      E:/Work/D05200/src/vcd_code
#set fpga_path     E:/Work/D05200/src/fpga_code


vlog $sim_path/d05200_asic_top.v
vlog $sim_path/vcd_owl_tb.v
vlog $sim_path/mcrc16.v
vlog $sim_path/POTP_HB180ELL_128X8_NISO_TKM3.v
vlog $sim_path/otp_ip.v
vlog $sim_path/otp_ram.v
vlog $sim_path/owl_mctrl.v
vlog $sim_path/owl_mtrcv.v
vlog $sim_path/analog_top.v

vsim -L work -novopt work._tb -t 1ns

add wave -position 64  sim:/_tb/cn1t
add wave -r *


#run  1600000000
run 800000000
#run 2000000000
#run 50000000000
#run 100000000000
#run 250000000000
#run 300000000000
#run 1000000000000

#run 1000000
#run 5000000
#run 60000000
#run 100000000
#run 200000000
#run 500000000
#run 1000000000
#run 10000000000
#run 15000000000
#run 20000000000
#run 25000000000
#run 30000000000
#run 35000000000
#run 60000000000
#run 80000000000
#run 100000000000
#run 200000000000
#run 1000000000000
#   0  0  0  0  0
