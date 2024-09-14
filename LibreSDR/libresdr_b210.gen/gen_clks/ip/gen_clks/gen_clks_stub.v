// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (lin64) Build 5076996 Wed May 22 18:36:09 MDT 2024
// Date        : Fri Jun 14 21:04:02 2024
// Host        : ubuntu running 64-bit Ubuntu 18.04.6 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/lvchenyang/workspace/SDR/usrp/myusrp/b210/libresdr_b210/ip/gen_clks/gen_clks_stub.v
// Design      : gen_clks
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tfbg484-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module gen_clks(clk_out1_40_int, clk_out2_100_bus, 
  clk_out3_200_ref_pll, reset, locked, clk_in1_40)
/* synthesis syn_black_box black_box_pad_pin="reset,locked,clk_in1_40" */
/* synthesis syn_force_seq_prim="clk_out1_40_int" */
/* synthesis syn_force_seq_prim="clk_out2_100_bus" */
/* synthesis syn_force_seq_prim="clk_out3_200_ref_pll" */;
  output clk_out1_40_int /* synthesis syn_isclock = 1 */;
  output clk_out2_100_bus /* synthesis syn_isclock = 1 */;
  output clk_out3_200_ref_pll /* synthesis syn_isclock = 1 */;
  input reset;
  output locked;
  input clk_in1_40;
endmodule
