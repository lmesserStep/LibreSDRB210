`timescale 1ns / 10ps

////////////////////////////////////////////////////////////////////////////////
// 
// decrypt test
// 
// test data 1: (128bit)
// key:    0x00000000000000000000000000000000
// input:  0x66e94bd4ef8a2c3b884cfa59ca342b2e
// output: 0x00000000000000000000000000000000
//
// test data 2: (128bit)
// key:    0x00000000000000000000000000000000
// input:  0xf795bd4a52e29ed713d313fa20e98dbc
// output: 0x66e94bd4ef8a2c3b884cfa59ca342b2e
// 
////////////////////////////////////////////////////////////////////////////////

module aes_inv_test;

	// Inputs
	reg clk;
	reg rst;
	reg kld;
	reg ld;
	reg [127:0] key;
	reg [127:0] text_in;

	// Outputs
	wire done;
	wire [127:0] text_out;

	// Instantiate the Unit Under Test (UUT)
	aes_inv_cipher_top uut (
		.clk(clk), 
		.rst(rst), 
		.kld(kld), 
		.ld(ld), 
		.done(done), 
		.key(key), 
		.text_in(text_in), 
		.text_out(text_out)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		kld = 0;
		ld = 0;
		key = 0;
		//text_in = 128'h66e94bd4ef8a2c3b884cfa59ca342b2e;
		text_in = 128'hf795bd4a52e29ed713d313fa20e98dbc;
		
		@(posedge clk)
			#1 kld = 1;
			ld = 1;
			rst = 1;
		@(posedge clk)
			#1 kld = 0;
			ld = 0;
		
		$monitor("text_out = %h", text_out);

		#100;
        
	end
	
	always clk = #5 ~clk;
	// stop simulating
	always @(posedge clk)
		if (done) #1 $stop;
      
endmodule

