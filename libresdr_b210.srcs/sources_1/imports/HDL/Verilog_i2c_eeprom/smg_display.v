`timescale 1ns/1ps
////////////////////////////////
//module name: smg_display
//功能说明：将串口接收的数据译码成16进制显示在两位数码管上
////////////////////////////////

module smg_display
	(
		input clk_1khz,
		input clk_1hz,
		input rst,
		input[7:0] data,
		
		output reg[5:0] smg_sig,
		output reg[7:0] smg_data
	);
	
//共阳数码管0~F编码:A~G、DP => data[0]~data[7]
parameter d0 = 8'hc0;
parameter d1 = 8'hf9;
parameter d2 = 8'ha4;
parameter d3 = 8'hb0;
parameter d4 = 8'h99;
parameter d5 = 8'h92;
parameter d6 = 8'h82;
parameter d7 = 8'hf8;
parameter d8 = 8'h80;
parameter d9 = 8'h90;
parameter da = 8'h88;
parameter db = 8'h83;
parameter dc = 8'hc6;
parameter dd = 8'ha1;
parameter de = 8'h86;
parameter df = 8'h8e;

parameter smg_sig1 = 6'b111110;
parameter smg_sig2 = 6'b111101;

reg[7:0] smg_data1, smg_data2;
reg smg_sig_cnt;

//数据译码
always @(posedge clk_1hz or negedge rst)
begin
	if(!rst)begin
		smg_data1 <= d0;
	end
	else begin
		case(data[3:0])
			4'd0:smg_data1 <= d0;
			4'd1:smg_data1 <= d1;
			4'd2:smg_data1 <= d2;
			4'd3:smg_data1 <= d3;
			4'd4:smg_data1 <= d4;
			4'd5:smg_data1 <= d5;
			4'd6:smg_data1 <= d6;
			4'd7:smg_data1 <= d7;
			4'd8:smg_data1 <= d8;
			4'd9:smg_data1 <= d9;
			4'd10:smg_data1 <= da;
			4'd11:smg_data1 <= db;
			4'd12:smg_data1 <= dc;
			4'd13:smg_data1 <= dd;
			4'd14:smg_data1 <= de;
			4'd15:smg_data1 <= df;
			default:smg_data1 <= d0;
		endcase
	end
end

always @(posedge clk_1hz or negedge rst)
begin
	if(!rst)begin
		smg_data2 <= d0;
	end
	else begin
		case(data[7:4])
			4'd0:smg_data2 <= d0;
			4'd1:smg_data2 <= d1;
			4'd2:smg_data2 <= d2;
			4'd3:smg_data2 <= d3;
			4'd4:smg_data2 <= d4;
			4'd5:smg_data2 <= d5;
			4'd6:smg_data2 <= d6;
			4'd7:smg_data2 <= d7;
			4'd8:smg_data2 <= d8;
			4'd9:smg_data2 <= d9;
			4'd10:smg_data2 <= da;
			4'd11:smg_data2 <= db;
			4'd12:smg_data2 <= dc;
			4'd13:smg_data2 <= dd;
			4'd14:smg_data2 <= de;
			4'd15:smg_data2 <= df;
			default:smg_data2 <= d0;
		endcase
	end
end


//扫描显示
always @(posedge clk_1khz)
begin
	smg_sig_cnt <= !smg_sig_cnt;
	case(smg_sig_cnt)
		1'b0:begin
			smg_sig <= smg_sig1;
			smg_data <= smg_data1;
		end
		1'b1:begin
			smg_sig <= smg_sig2;
			smg_data <= smg_data2;
		end
		default:begin
			smg_sig <= smg_sig1;
			smg_data <= smg_data1;
		end
	endcase
end


endmodule
