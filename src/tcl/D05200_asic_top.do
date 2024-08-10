set sys_path      E:/Work/D05200/src/system_code
set sim_path      E:/Work/D05200/src/sim_code
#set fpga_path     E:/Work/D05200/src/fpga_code


vlog $sys_path/clk_burr2.v
vlog $sys_path/crc16.v
vlog $sys_path/d05200_dc_top.v
vlog $sys_path/main_ctrl.v
vlog $sys_path/mic_hclk_cnt.v
vlog $sys_path/mic_lclk_cnt.v
vlog $sys_path/otp_if.v
vlog $sys_path/owl_ctrl.v
vlog $sys_path/owl_trcv.v
vlog $sys_path/psfrm.v
vlog $sys_path/pwm_gen.v
vlog $sys_path/p_multiply_divider.v
vlog $sys_path/rcc.v
vlog $sys_path/tim1ms.v


vlog $sim_path/d05200_asic_top.v
vlog $sim_path/d05200_asic_top_tb.v
vlog $sim_path/mcrc16.v
vlog $sim_path/POTP_HB180ELL_128X8_NISO_TKM3.v
vlog $sim_path/otp_ip.v
vlog $sim_path/otp_ram.v
vlog $sim_path/owl_mctrl.v
vlog $sim_path/owl_mtrcv.v
vlog $sim_path/analog_top.v

vsim -L work -novopt work._tb -t 1ns

add wave -position insertpoint  \
sim:/_tb/u_master/owl_rdata

add wave -position insertpoint  \
sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/point0*_r 
add wave -position 33  sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/otp_ad_r
add wave -position insertpoint  \
sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/chk_cnt0 \
sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/chk_cnt1 \
sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/chk_bas0 \
sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/chk_bas1 \
sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/chk_dbd0 \
sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/chk_dbd1 \
sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/chk_sub0 \
sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/chk_sub1 \
sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/chk_sector \
sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/chk_ptsub \
sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/chk_slope \
sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/chk_sctsub \
sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/chk_slope_w
add wave -position insertpoint  \
sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/sub_rslt \
sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/chk_ratio_w \
sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/pstate \
sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/clk_cnt \
sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/pwm_width 
add wave -position 31  sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/threshold_sel0
add wave -position 32  sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/threshold_sel1
add wave -position 33  sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/holdvalue128
add wave -position 34  sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/holdvalue064
add wave -position 35  sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/holdvalue032
add wave -position 36  sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/threshold_u0
add wave -position 37  sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/threshold_u1
add wave -position 38  sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/threshold_s1
add wave -position 39  sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/threshold_s2
add wave -position 40  sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/threshold_u2
add wave -position 41  sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/threshold_u3
add wave -position 42  sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/threshold_s3
add wave -position 43  sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/smoke_trig
add wave -position 44  sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/update_trig
add wave -position 45  sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/chk_sub_r
add wave -position 46  sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/chk_sub_r1
add wave -position 47  sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/ms_cnt0
add wave -position 48  sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/ms_cnt1
add wave -position 704  sim:/_tb/u_asic_top/u_dc_top/RESET_EN
add wave -position 49  sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/chk_cnt_w
add wave -position 50  sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/sub_src0
add wave -position 51  sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/sub_src1
add wave -position 54  sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/clk
add wave -position 53  sim:/_tb/u_asic_top/u_dc_top/u_main_ctrl/pstate
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
