`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/05 00:19:32
// Design Name: 
// Module Name: DA_shiver
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module DA_shiver(
  input clk,
  input [15:0] dat,
  output  sclk,
  output  mosi,
  output  sync_n

    );
 reg [9-1:0] shiver_cnt=0;
 reg shiver_bit=0;
 reg sync_n_r=0;
 
 reg bit_cnt=1'b0;
 
 reg [15:0] dat_shiver=1'b0;
 always@(posedge clk) begin
   sync_n_r<=sync_n;
   if(sync_n==1'b1&&sync_n_r==1'b0) begin
        bit_cnt<=~bit_cnt;
        if (bit_cnt==1'b1)
        shiver_cnt<=shiver_cnt+1;
    end    
    if (shiver_cnt<=dat[8:0]) begin
        shiver_bit<=1'b1;
    end else begin
        shiver_bit<=1'b0;
    end
    
    dat_shiver<={dat[15:9],shiver_bit,8'b0};

   end
   
   
    
    
    
   DACx311_auto_spi dac
  (
    .clk(clk),
    .dat(dat_shiver),
    .sclk(sclk),
    .mosi(mosi),
    .sync_n(sync_n)
  );
  
    
  
endmodule
