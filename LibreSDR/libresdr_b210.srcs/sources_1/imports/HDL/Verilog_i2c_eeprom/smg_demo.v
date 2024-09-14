`timescale 1ns/1ps
////////////////////////////////////
//module name: smg_demo
////////////////////////////////////

module smg_demo
	(
		input clk_50MHz,
		input rst,
		input[7:0] data,
		output[5:0] smg_sig,
		output[7:0] smg_data
		//output rdsig_nextdata
	);

wire clk_1khz, clk_1hz;
	
//clkdiv
smg_clkdiv smg_clkdiv_inst
	(
		.clk_50MHz(clk_50MHz),
		.rst(rst),
		.clk_1khz(clk_1khz),
		.clk_1hz(clk_1hz)
		//.rdsig_nextdata(rdsig_nextdata)
	);
	
//display
smg_display smg_display_inst
	(
		.clk_1khz(clk_1khz),
		.clk_1hz(clk_1hz),
		.rst(rst),
		.data(data),
		.smg_sig(smg_sig),
		.smg_data(smg_data)
	);
	
endmodule
