`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/01/2024 12:43:48 AM
// Design Name: 
// Module Name: ency_tb
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


module ency_tb(

    );
    
    
    reg clk=0;
    reg reset=1;
    wire scl;
    wire sda;
    wire status;
    
    pullup(sda);
    
    
    encpy DUT(
    .clk    (   clk ),
    .reset  (   reset),
    .wr_en  (   1'b1),
    .scl    (   scl),
    .sda    (   sda),
    .status (   status)
   );
   
   
   M24FC04 M24FC04_dut(
   .A0      (   1'b0    ), 
   .A1      (   1'b0    ), 
   .A2      (   1'b0    ), 
   .WP      (   1'b0    ), 
   .SDA     (   sda     ), 
   .SCL     (   scl     ), 
   .RESET   (   reset   )
   );
   initial begin
     clk = 0;
     reset = 1;
     
     #200
     reset = 0;
     
   end
   
   always #20 clk=~clk;
   
endmodule
