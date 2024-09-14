`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/30/2024 07:52:31 AM
// Design Name: 
// Module Name: encpy
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


module encpy(
input clk,
input reset,
input wr_en,
output scl,
inout sda,
output reg status=0
   );
   
   
wire [56:0] dna_data;
wire        dna_valid;

reg dna_valid_r;
reg ld;
wire aes_done;
reg aes_done_reg = 1'b0;
wire [127:0] ency_data,check_data;
reg [127:0] ency_data_reg;
wire eeprom_done;


always@(posedge clk) begin
    dna_valid_r <= dna_valid;
    if(eeprom_done ==1'b1 && (ency_data_reg == check_data)) 
        status <= 1'b1;
     else
        status <= 1'b0;
    if(dna_valid==1'b1&&dna_valid_r==1'b0)
        ld <=1'b1;
     else
        ld <=1'b0;
        
    if (aes_done == 1'b1) begin
        aes_done_reg <= 1'b1;
        ency_data_reg <= ency_data;
    end
end
   
DNA_capture DNA_capture_i(

    .sys_clk    (   clk     ),    
    .dna_rdy    (   !reset  ),
    .dna_data   (   dna_data),
    .dna_valid  (   dna_valid)
);

aes_cipher_top aes_cipher_top_i(
    .clk        (   clk     ), 
    .rst        (   !reset   ), 
    .ld         (   ld     ),
    .done       (   aes_done), 
    .key        (   128'hf795bd4a52e29ed713d313fa20e98dbc  ),
    .text_in    (   {dna_data,71'b0}), 
    .text_out   (   ency_data)
    );
    
eeprom eeprom_i
	(
		.clk_50M  (   clk      ),
		.rst_n    (   aes_done_reg ),
		.wr_en    (   wr_en    ),
		.wr_key   (   ency_data_reg),
		.rd_key   (   check_data),
		.done     (   eeprom_done),
		.scl      (   scl ),
		.sda      (   sda )
	);
endmodule
