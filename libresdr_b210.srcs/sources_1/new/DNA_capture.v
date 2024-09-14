module DNA_capture(

    input               sys_clk,    
    input               dna_rdy,
    output  [56:0]      dna_data,
    output              dna_valid
);

    wire                dna_dout;
    wire                dna_read;
    wire                dna_shift;


    reg     [56:0]      dna_reg = 0;
    reg     [7:0]       dna_cnt = 0;



   DNA_PORT #(
      .SIM_DNA_VALUE(57'h123456789abcdef)  // Specifies a sample 57-bit DNA value for simulation
   )
   DNA_PORT_inst (
      .DOUT(dna_dout),   // 1-bit output: DNA output data.
      .CLK(sys_clk),     // 1-bit input: Clock input.
      .DIN(1'b0),     // 1-bit input: User data input pin.
      .READ(dna_read),   // 1-bit input: Active high load DNA, active low read input.
      .SHIFT(dna_shift)  // 1-bit input: Active high shift enable input.
   );

    always@(posedge sys_clk)
    if(dna_rdy)begin
        if(dna_cnt == 7'd103)
            dna_cnt <= dna_cnt;
        else 
            dna_cnt <= dna_cnt + 1'b1;
    end


    assign dna_read = dna_cnt == 8'd20;
    //
    assign dna_shift = (dna_cnt >= 8'd45) && (dna_cnt <= (8'd45+8'd57-1));

    always @ (posedge sys_clk)
    begin
        if(dna_shift)begin
        dna_reg[56:0] <= {dna_reg[55:0],dna_dout};
        end
    end

    assign dna_data = dna_reg;
    assign dna_valid = dna_cnt == (8'd45+8'd57-1);

endmodule