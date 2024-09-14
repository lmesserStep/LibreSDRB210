// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (lin64) Build 5076996 Wed May 22 18:36:09 MDT 2024
// Date        : Fri Jun 14 21:04:01 2024
// Host        : ubuntu running 64-bit Ubuntu 18.04.6 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/lvchenyang/workspace/SDR/usrp/myusrp/b210/libresdr_b210/libresdr_b210/libresdr_b210.gen/sources_1/ip/clk_wiz_0/clk_wiz_0_stub.v
// Design      : clk_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tfbg484-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_0(clk_out_200M, locked, clk_in1_10M)
/* synthesis syn_black_box black_box_pad_pin="locked,clk_in1_10M" */
/* synthesis syn_force_seq_prim="clk_out_200M" */;
  output clk_out_200M /* synthesis syn_isclock = 1 */;
  output locked;
  input clk_in1_10M;
endmodule
