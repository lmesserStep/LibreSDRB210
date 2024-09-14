`timescale 1ns/1ps
////////////////////////////////////////////
//Module Name	:	iic_control
//Description	:	read and write eeprom using iic bus
//Editor			:	Yongxiang
//Time			:	2019-11-25
////////////////////////////////////////////
module iic_control
	(
		input wire	clk_50M,
		input wire	rst_n,
		input wire  wr_en,
		input wire [127:0] wr_key,
		output wire [127:0] rd_key,
		output reg  done,
		output reg	wr_sig,
		output reg	rd_sig,
		output reg[7:0]	addr_sig,
		output reg[7:0]	wr_data,
		input  wire[7:0] rd_data,
		input wire	done_sig
	);

reg[1:0] state;
wire [7:0] wr_key_reg[0:15];
reg [7:0] rd_key_reg[0:15];
reg [7:0] counter = 0;

genvar i;
generate
   for (i=0; i <16; i=i+1)
   begin: wire_2_reg
      assign wr_key_reg[i] = wr_key[i*8+:8];
      assign rd_key[i*8+:8]=rd_key_reg[i];
   end
endgenerate


//eeprom先写后读
always @(posedge clk_50M)
begin
	if(!rst_n)begin
	   if(wr_en) 
		state <= 2'd0;
	   else
	    state <= 2'd1;
	    
	    done <= 1'b0;
		addr_sig <= 8'd0;
		wr_data <= 8'd0;
		rd_sig <= 1'b0;
		wr_sig <= 1'b0;
		counter <= 1'b0;
	end
	else begin
		case(state)
			2'd0:begin
				if(done_sig)begin
					wr_sig <= 1'b0;
					rd_sig <= 1'b0;
					if(counter<15) begin
					   counter <= counter+1;
					   state   <= 2'd0;
					end else begin
					   counter <=  8'd0;
					   state   <=  2'd1;
					end
					
				end
				else begin
					wr_sig <= 1'b1;
					rd_sig <= 1'b0;
					wr_data <= wr_key_reg[counter];	//写入数据0Xff
					addr_sig <= counter;	//在eeprom的0X00地址写入数据
				end
			end
			2'd1:begin
				if(done_sig)begin
					wr_sig <= 1'b0;
					rd_sig <= 1'b0;
					rd_key_reg[counter] <= rd_data;
					if(counter<15) begin
					   counter <= counter+1;
					   state   <= 2'd1;
					end else begin
					   counter <=  8'd0;
					   state   <=  2'd2;
					end
				end
				else begin
					wr_sig <= 1'b0;
					rd_sig <= 1'b1;
					addr_sig <= counter;	//在eeprom地址写入addr
				end
			end
			2'd2:begin
				state <= 2'd2;
				done  <= 1'b1;
			end
		endcase
	end
end

endmodule
