-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2024.1 (lin64) Build 5076996 Wed May 22 18:36:09 MDT 2024
-- Date        : Fri Jun 14 21:04:02 2024
-- Host        : ubuntu running 64-bit Ubuntu 18.04.6 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /home/lvchenyang/workspace/SDR/usrp/myusrp/b210/libresdr_b210/ip/gen_clks/gen_clks_stub.vhdl
-- Design      : gen_clks
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a200tfbg484-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity gen_clks is
  Port ( 
    clk_out1_40_int : out STD_LOGIC;
    clk_out2_100_bus : out STD_LOGIC;
    clk_out3_200_ref_pll : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in1_40 : in STD_LOGIC
  );

end gen_clks;

architecture stub of gen_clks is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_out1_40_int,clk_out2_100_bus,clk_out3_200_ref_pll,reset,locked,clk_in1_40";
begin
end;
