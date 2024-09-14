`timescale 1ns/1ps
////////////////////////////////////////////
//Module Name	:	eeprom
//Description	:	top_file
//Editor			:	Yongxiang
//Time			:	2019-11-25
////////////////////////////////////////////
module eeprom
	(
		input wire	clk_50M,
		input wire	rst_n,
		input wire  wr_en,
		input wire [127:0] wr_key,
		output wire [127:0] rd_key,
		output wire done,
		output wire	scl,
		inout wire	sda
	);
	
wire wr_sig;
wire rd_sig;
wire[7:0] addr_sig;
wire[7:0] wr_data;
wire[7:0] rd_data;
wire done_sig;

//iic_control
iic_control iic_control_inst
	(
		.clk_50M  (clk_50M),
		.rst_n    (rst_n),
		.wr_en    (wr_en),
		.wr_key   (wr_key),
		.rd_key   (rd_key),
		.done     (done),
		.wr_sig   (wr_sig),
		.rd_sig   (rd_sig),
		.addr_sig (addr_sig),
		.wr_data  (wr_data),
		.rd_data  (rd_data),
		.done_sig (done_sig)
	);

//iic
iic iic_inst
	(
		.clk_50M(clk_50M),
		.rst_n(rst_n),
		.wr_sig(wr_sig),		//写命令，1有效
		.rd_sig(rd_sig),		//读命令，1有效
		.addr_sig(addr_sig),	//数据地址
		.wr_data(wr_data),	    //写数据
		.rd_data(rd_data),	    //读数据
		.done_sig(done_sig),	//读写完成标志，1有效
		.scl(scl),
		.sda(sda)
	);


endmodule
	