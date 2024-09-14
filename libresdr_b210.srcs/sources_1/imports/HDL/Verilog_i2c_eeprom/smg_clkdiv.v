`timescale 1ns/1ps
////////////////////////////////
//module name: smg_clkdiv
////////////////////////////////

module smg_clkdiv
	(
		input clk_50MHz,
		input rst,
		output reg clk_1khz,
		output reg clk_1hz,
		output reg rdsig_nextdata
	);

reg[15:0] cnt1;
reg[9:0] cnt2;
reg clk_1hz_buf;

//1khz分频
always @(posedge clk_50MHz or negedge rst)
begin
	if(!rst)begin
		clk_1khz <= 1'b0;
		cnt1 <= 16'd0;
	end
	else if(cnt1 == 16'd24999)begin
		clk_1khz <= !clk_1khz;
		cnt1 <= 16'd0;
	end
	else begin
		cnt1 <= cnt1 + 16'd1;
	end
end

//1hz分频
always @(posedge clk_1khz or negedge rst)
begin
	if(!rst)begin
		clk_1hz <= 1'b0;
		cnt2 <= 10'd0;
	end
	else if(cnt2 == 10'd499)begin
		clk_1hz <= !clk_1hz;
		cnt2 <= 10'd0;
	end
	else begin
		cnt2 <= cnt2 + 10'd1;
	end
end

//得到fifo读取信号:1hz信号下降沿后，持续50MHz的一个时钟周期的高电平
always @(posedge clk_50MHz)
begin
	clk_1hz_buf <= clk_1hz;
	rdsig_nextdata <= clk_1hz_buf & (~clk_1hz);
end

endmodule
