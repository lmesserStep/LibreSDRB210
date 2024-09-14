`timescale 1ns/1ps
////////////////////////////////////////////
//module name	:	iic
//description	:	iic communication module
//Editor			:	Yongxiang
//Time			:	2019-11-25
////////////////////////////////////////////
module iic
	(
		input wire clk_50M,
		input wire rst_n,
		input wire wr_sig,	//写命令，1有效
		input wire rd_sig,	//读命令，1有效
		input wire[7:0] addr_sig,	//数据地址
		input wire[7:0] wr_data,	//写数据
		output reg[7:0] rd_data,	//读数据
		output reg done_sig,	//读写完成标志，1有效
		output reg scl,
		inout wire sda
	);
	
reg[4:0] state;
reg[4:0] state_save;
reg[8:0] cnt;
reg[7:0] data_reg;
reg is_out;
reg sda_reg;
reg is_ask_n;	//应答信号，0有效

wire sda_i;

assign sda = is_out ? sda_reg : 1'bz;	//SDA输入输出方向控制
assign sda_i = (sda==1'b0)?1'b0:1'b1;

//IIC读写数据
always @(posedge clk_50M)
begin
	if(!rst_n)begin		//系统复位
		state <= 5'd0;
		cnt <= 9'd0;
		sda_reg <= 1'b1;	//SDA置高
		scl <= 1'b1;		//SCL置高
		is_out <= 1'b1;
		is_ask_n <= 1'b1;	
		rd_data <= 8'd0;
		done_sig <= 1'b0;
	end
	else if(wr_sig)begin		//iic数据写
		case(state)
			5'd0:begin	//iic启动
				is_out <= 1'b1;		//SDA输出
				if(cnt == 9'd0)begin
					scl <= 1'b1;
					sda_reg <= 1'b1;
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd100)begin
					sda_reg <= 1'b0;	//启动信号：在SCL为1时，SDA的下降沿
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd200)begin
					scl <= 1'b0;
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd249)begin
					cnt <= 9'd0;
					state <= 5'd1;
				end
				else begin
					cnt <= cnt + 9'd1;
				end
			end
			5'd1:begin	//发送7位从机地址、1位写命令
				data_reg <= 8'hA0;
				state <= 5'd7;
				state_save <= 5'd2;
			end
			5'd2:begin	//发送数据写入地址
				data_reg <= addr_sig;
				state <= 5'd7;
				state_save <= 5'd3;
			end
			5'd3:begin	//写入数据
				data_reg <= wr_data;
				state <= 5'd7;
				state_save <= 5'd4;
			end
			5'd4:begin	//iic停止
				is_out <= 1'b1;		//SDA输出
				if(cnt == 9'd0)begin
					scl <= 1'b0;
					sda_reg <= 1'b0;
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd50)begin
					scl <= 1'b1;		
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd150)begin
					sda_reg <= 1'b1;	//停止信号：在SCL为1时，SDA的上升沿
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd249)begin
					cnt <= 9'd0;
					state <= 5'd5;
				end
				else begin
					cnt <= cnt + 9'd1;
				end
			end
			5'd5:begin	//写iic结束
				done_sig <= 1'b1;
				state <= 5'd6;
			end
			5'd6:begin
				done_sig <= 1'b0;
				state <= 5'd0;
			end
			
			5'd7,5'd8,5'd9,5'd10,5'd11,5'd12,5'd13,5'd14:begin	//发送一个字节
				is_out <= 1'b1;
				sda_reg <= data_reg[14-state];		//高位先发送
				if(cnt == 9'd0)begin
					scl <= 1'b0;
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd50)begin
					scl <= 1'b1;
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd150)begin
					scl <= 1'b0;
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd199)begin
					cnt <= 9'd0;
					state <= state + 5'd1;
				end
				else begin
					cnt <= cnt + 9'd1;
				end
			end
			5'd15:begin	//等待应答
				is_out <= 1'b0;	//SDA输入
				if(cnt == 9'd0)begin
					scl <= 1'b0;
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd50)begin
					scl <= 1'b1;
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd100)begin
					is_ask_n <= sda;
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd150)begin
					scl <= 1'b0;
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd199)begin
					cnt <= 9'd0;
					state <= state + 5'd1;
				end
				else begin
					cnt <= cnt + 9'd1;
				end
			end
			5'd16:begin
				if(!is_ask_n)begin	//接收到应答信号
					state <= state_save;
				end
				else begin
					state <= 5'd0;
				end
			end
		endcase
	end
	else if(rd_sig)begin		//iic数据读
		case(state)
			5'd0:begin	//iic启动
				is_out <= 1'b1;		//SDA输出
				if(cnt == 9'd0)begin
					scl <= 1'b1;
					sda_reg <= 1'b1;
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd100)begin
					sda_reg <= 1'b0;	//启动信号：在SCL为1时，SDA的下降沿
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd200)begin
					scl <= 1'b0;
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd249)begin
					cnt <= 9'd0;
					state <= 5'd1;
				end
				else begin
					cnt <= cnt + 9'd1;
				end
			end
			5'd1:begin	//发送7位从机地址、1位写命令
				data_reg <= 8'hA0;
				state <= 5'd9;
				state_save <= 5'd2;
			end
			5'd2:begin	//发送读取数据地址
				data_reg <= addr_sig;
				state <= 5'd9;
				state_save <= 5'd3;
			end
			5'd3:begin	//iic再次启动
				is_out <= 1'b1;		//SDA输出
				if(cnt == 9'd0)begin
					scl <= 1'b1;
					sda_reg <= 1'b1;
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd100)begin
					sda_reg <= 1'b0;	//启动信号：在SCL为1时，SDA的下降沿
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd200)begin
					scl <= 1'b0;
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd249)begin
					cnt <= 9'd0;
					state <= 5'd4;
				end
				else begin
					cnt <= cnt + 9'd1;
				end
			end
			5'd4:begin	//发送7位从机地址、1位读命令
				data_reg <= 8'hA1;
				state <= 5'd9;
				state_save <= 5'd5;
			end
			5'd5:begin	//读数据
				data_reg <= 8'd0;
				state <= 5'd19;
				state_save <= 5'd6;
			end
			5'd6:begin	//iic停止
				is_out <= 1'b1;		//SDA输出
				if(cnt == 9'd0)begin
					scl <= 1'b0;
					sda_reg <= 1'b0;
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd50)begin
					scl <= 1'b1;		
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd150)begin
					sda_reg <= 1'b1;	//停止信号：在SCL为1时，SDA的上升沿
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd249)begin
					cnt <= 9'd0;
					state <= 5'd7;
				end
				else begin
					cnt <= cnt + 9'd1;
				end
			end
			5'd7:begin	//读iic结束
				done_sig <= 1'b1;
				state <= 5'd8;
			end
			5'd8:begin
				done_sig <= 1'b0;
				state <= 5'd0;
			end
			
			5'd9,5'd10,5'd11,5'd12,5'd13,5'd14,5'd15,5'd16:begin	//发送一个字节
				is_out <= 1'b1;
				sda_reg <= data_reg[16-state];		//高位先发送
				if(cnt == 9'd0)begin
					scl <= 1'b0;
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd50)begin
					scl <= 1'b1;
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd150)begin
					scl <= 1'b0;
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd199)begin
					cnt <= 9'd0;
					state <= state + 5'd1;
				end
				else begin
					cnt <= cnt + 9'd1;
				end
			end
			5'd17:begin	//等待应答
				is_out <= 1'b0;	//SDA输入
				if(cnt == 9'd0)begin
					scl <= 1'b0;
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd50)begin
					scl <= 1'b1;
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd100)begin
					is_ask_n <= sda;
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd150)begin
					scl <= 1'b0;
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd199)begin
					cnt <= 9'd0;
					state <= state + 5'd1;
				end
				else begin
					cnt <= cnt + 9'd1;
				end
			end
			5'd18:begin
				if(!is_ask_n)begin	//接收到应答信号
					state <= state_save;
				end
				else begin
					state <= 5'd0;
				end
			end
			
			5'd19,5'd20,5'd21,5'd22,5'd23,5'd24,5'd25,5'd26:begin	//接收一个字节
				is_out <= 1'b0;
				if(cnt == 9'd0)begin
					scl <= 1'b0;
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd50)begin
					scl <= 1'b1;
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd100)begin
					data_reg[26-state] <= sda;	//高位先接收
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd150)begin
					scl <= 1'b0;
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd199)begin
					cnt <= 9'd0;
					state <= state + 5'd1;
				end
				else begin
					cnt <= cnt + 9'd1;
				end
			end
			5'd27:begin	//无应答信号
				is_out <= 1'b1;	//SDA输入
				rd_data <= data_reg;	//接收完一个字节数据
				if(cnt == 9'd0)begin
					scl <= 1'b0;
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd50)begin
					scl <= 1'b1;
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd150)begin
					scl <= 1'b0;
					cnt <= cnt + 9'd1;
				end
				else if(cnt == 9'd199)begin
					cnt <= 9'd0;
					state <= state_save;
				end
				else begin
					cnt <= cnt + 9'd1;
				end
			end
		endcase
	end
end

endmodule
