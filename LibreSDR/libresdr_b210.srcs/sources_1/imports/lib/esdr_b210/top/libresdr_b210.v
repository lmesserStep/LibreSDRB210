`default_nettype none
module libresdr_b210 (
        // AD936x - SPI Interface:
        output wire 	 		CAT_SPI_EN      ,  // Enable
        input  wire	 			CAT_SPI_DO      ,  // MISO
        output wire 	 		CAT_SPI_DI      ,  // MOSI
        output wire 	 		CAT_SPI_CLK     ,  // SPI Clk

        // AD936x - Control:
        output wire  	     	CAT_EN          ,
        output wire  	     	CAT_EN_AGC      ,
        output wire  	     	CAT_RESETn      ,
        output wire  	     	CAT_TXnRX       ,
        output wire             CAT_SYNC        ,
        output wire [3:0] 		CAT_CTL_IN      , // These should be outputs
        input  wire [7:0]	 	CAT_CTL_OUT     , // MUST BE INPUT

        // AD936x - Data:
        input  wire	 			CAT_DCLK_P      , // Clock from AD936x (RX)
        output wire 	 		CAT_FBCLK_P     , // Clock to AD936x (TX)
        input  wire [11:0]  	CAT_P0_D        , // RX data is on Port 0
        output wire [11:0] 		CAT_P1_D        , // TX data is on Port 1
        input  wire	 			CAT_RX_FR_P     ,
        output wire 	 		CAT_TX_FR_P     ,




        // GPIF, FX3 Slave FIFO
        output  wire	        IFCLK, // pclk
        input   wire	        FX3_EXTINT,
        output  wire	        GPIF_CTL0, // n_slcs
        output  wire	        GPIF_CTL1, // n_slwr
        output  wire	        GPIF_CTL2, // n_sloe
        output  wire	        GPIF_CTL3, // n_slrd
        output  wire	        GPIF_CTL7, // n_pktend
        input   wire	        GPIF_CTL4, // slfifo_flags[0]
        input   wire	        GPIF_CTL5, // slfifo_flags[1]
        input   wire	        GPIF_CTL6, // Serial settings bus from FX3. SDA
        input   wire	        GPIF_CTL8, // Serial settings bus from FX3. SCL
        output  wire	        GPIF_CTL11, // slfifo_addr[1]
        output  wire	        GPIF_CTL12, // slfifo_addr[0]
        inout   wire [31:0]     GPIF_D,
        input   wire	        GPIF_CTL9, // global_reset
        
        // UART
        // By default these provide an FX3 UART console output. Under compile time control they can alternatively
        // provide 2 (1.8V) GPIO pins which are logically bits [9:8] of the fp_gpio bus.
        // Used as a UART RXD is an input and TXD an output electrically.
        // input 	 FPGA_RXD0, // These pins goto 3 pin 0.1" header on B2x0 and
        // output 	 FPGA_TXD0, // carry FX3 UART.
        inout wire  FPGA_RXD0, // These pins goto 3 pin 0.1" header J400 on B2x0 and
        inout wire  FPGA_TXD0, // carry FX3 UART.
   

        // AD936x - Always on 40MHz clock:
        input  wire	 			CLK_40MHz_FPGA  ,

        // PPS or 10 MHz 
        input  wire             PPS_IN_EXT      ,
//        input  wire             PPS_IN_INT      ,
        input  wire             CLKIN_10MHz     ,
        output wire             REF_CLK_REQ     ,

        output wire             PPS_LED_inv         ,
        output wire             REF_LOCKED_inv      ,
        output wire             REF_IS_10M_detect_inv   ,           

//        output wire             GPS_nRST        ,
//        output wire             GPS_UART_TX     ,
//        input  wire             GPS_UART_RX     ,

   // LEDS
        output  wire LED_RX1_inv,
        output 	wire LED_RX2_inv,
        output 	wire LED_TXRX1_RX_inv,
        output 	wire LED_TXRX1_TX_inv,
        output 	wire LED_TXRX2_RX_inv,
        output 	wire LED_TXRX2_TX_inv,
        
        output  wire LED_RX1_R,
        output  wire LED_RX1_B,
        
        output  wire LED_RX2_R,
        output  wire LED_RX2_B,
        
        output 	wire LED_TXRX1_B,
        output 	wire LED_TXRX2_B,
        
        output  wire LED_USER_R,
        //output  wire LED_USER_B,
        
        
       `ifdef TARGET_B210
        inout wire [7:0] 	 fp_gpio,
        `endif

        // Clock disciplining / AD5662 controls
        output wire             CLK_40M_DAC_nSYNC,
        output wire             CLK_40M_DAC_SCLK ,
        output wire             CLK_40M_DAC_DIN ,
        //EEPROM 
        output wire             scl,
        inout  wire             sda,

        // RF Hardware Control
        output  wire            SFDX1_RX,
        output 	wire            SFDX1_TX,
        output 	wire            SFDX2_RX,
        output 	wire            SFDX2_TX,
        output 	wire            SRX1_RX,
        output 	wire            SRX1_TX,
        output 	wire            SRX2_RX,
        output 	wire            SRX2_TX,


        output 	wire            tx_enable1,
        output 	wire            tx_enable2
    );
    
    wire reset_global = GPIF_CTL9;
    
    //LED wire
    wire             PPS_LED;
    wire             REF_LOCKED;
        
    
    wire LED_RX1;
    wire LED_RX2;
    wire LED_TXRX1_RX;
    wire LED_TXRX1_TX;
    wire LED_TXRX2_RX;
    wire LED_TXRX2_TX;
    

    // Clocks
    wire bus_clk;
    wire radio_clk;
    wire gpif_clk;
    wire clk40;
    wire clk200;

    // Resets

    wire bus_rst;


    ///////////////////////////////////////////////////////////////////////
    // generate clocks from always on codec main clk
    ///////////////////////////////////////////////////////////////////////
    wire locked;
    
 gen_clks u_gen_clocks_main
 (
  // Clock out ports
  .clk_out1_40_int(int_40mhz),
  .clk_out2_100_bus(gpif_clk),
  .clk_out3_200_ref_pll(ref_pll_clk),
  // Status and control signals
  .reset(reset_global),
  .locked(locked),
 // Clock in ports
  .clk_in1_40(CLK_40MHz_FPGA)
 );
 
    // Bus Clock and GPIF Clock both same 100MHz clock.
    assign bus_clk = gpif_clk;
    /////////////////////////////////////////////////////////////////////
    //
    // Clocks and PPS
    //
    /////////////////////////////////////////////////////////////////////
//    wire clk_int40;
    wire pps_refclk;
    wire [1:0] pps_select;
    wire pps_fpga_int;
    wire ref_select;
    wire refclk_locked_busclk;

    reg [15:0] clocks_ready_count;
    reg clocks_ready;
    always @(posedge bus_clk or posedge reset_global or negedge locked) begin
        if (reset_global | !locked) begin
            clocks_ready_count <= 16'b0;
            clocks_ready <= 1'b0;
        end
        else if (!clocks_ready) begin
            clocks_ready_count <= clocks_ready_count + 1'b1;
            clocks_ready <= (clocks_ready_count == 16'hffff);
        end
    end

    ///////////////////////////////////////////////////////////////////////
    // Create sync reset signals
    ///////////////////////////////////////////////////////////////////////
    
    wire gpif_rst, radio_rst,ref_pll_rst;
    reset_sync radio_sync(.clk(radio_clk), .reset_in(!clocks_ready), .reset_out(radio_rst));
    reset_sync bus_sync(.clk(bus_clk), .reset_in(!clocks_ready), .reset_out(bus_rst));
    reset_sync ref_pll_sync(.clk(ref_pll_clk), .reset_in(!clocks_ready), .reset_out(ref_pll_rst));
    reset_sync gpif_sync(.clk(gpif_clk), .reset_in(!clocks_ready), .reset_out(gpif_rst));

    wire [1:0] refsel;
    wire ref_sel;
    wire ext_ref;
    wire ext_ref_is_pps;
    wire ext_ref_locked;
    wire lpps;
    
    // pps_select == 2'b00 ----> onboard gps module pps
    // pps_select == 2'b01 ----> external pps/10M
    // pps_select == 2'b10 ----> internal pps genreated by fpga

//    assign ext_ref =    (pps_select == 2'b01)? PPS_IN_EXT :
//                        (pps_select == 2'b10 && ref_sel == 1'b0)? PPS_IN_EXT : // ref_sel selects the external or gpsdo clock source
//                        (pps_select == 2'b10)? pps_fpga_int: 1'b0;

//    assign refsel = ref_sel?2'b10:2'b11;

    
    wire is10meg;
    wire ispps;
    wire clk10M_w;
    
    wire sync_200M;
    reg sync_10M;
    reg [8-1:0] counter_10M;
    
  BUFG BUFG_10M_inst (
      .O(clk10M_w), // 1-bit output: Clock output
      .I(CLKIN_10MHz)  // 1-bit input: Clock input
   );
//encpy FPGA bit

wire  status;

encpy encpy_i(
    .clk    (  int_40mhz    ),
    .reset  (  reset_global ),
    .wr_en  (  1'b1         ),
    .scl    (  scl          ),
    .sda    (  sda          ),
    .status (  status       )
   );
   

    
    clk_wiz_0 clk_wiz_0_10M_detect 
    (
  // Clock out ports
  .clk_out_200M  ( sync_200M    ),
  // Status and control signals
  .locked       ( is10meg     ),
 // Clock in ports
  .clk_in1_10M  ( clk10M_w     )
    );
 
always@(posedge sync_200M) begin
    if (is10meg==0) begin
        counter_10M <= 8'd0;
        sync_10M    <= 1'b0;
    end else begin
        if (counter_10M<8'd9) begin
            counter_10M <= counter_10M + 1;
        end else begin
            counter_10M <=8'd0;
            sync_10M <= ~sync_10M;
        end
    end
    
end
    assign ext_ref = is10meg?sync_10M:PPS_IN_EXT;  //ref_sel high select 10MHz low select 1pps
 
    assign REF_CLK_REQ = 1'b1;
    assign PPS_LED = lpps;
    assign REF_LOCKED = ext_ref_locked;
    
   
    wire int_40mhz;
    wire ref_pll_clk;

b205_ref_pll(
    .reset  (ref_pll_rst),
    .clk    (ref_pll_clk),      // 200 MHz sample clock
    .refclk (int_40mhz),   // 40 MHz reference clock
    .ref    (ext_ref),      // PPS or 10 MHz external reference
    .lpps   (lpps),
    .locked (ext_ref_locked),

    // SPI lines to AD5662
    .sclk   (CLK_40M_DAC_SCLK),
    .mosi   (CLK_40M_DAC_DIN),
    .sync_n (CLK_40M_DAC_nSYNC)
    );




//    ppsloop #(
//        .DEVICE("E200")
//    )u_ppsloop(
//        .reset   ( 1'b0   ),
//        .clk     (ref_pll_clk),
//        .refclk  (int_40mhz),
//        .ppsgps  ( 1'b0     ),
//        .ppsext  ( ext_ref  ),
//        .refsel ( refsel  ),
//        .lpps    ( lpps    ),
//        .is10meg ( is10meg ),
//        .ispps   ( ispps   ),
//        .reflck  ( ext_ref_locked  ),
////        .plllck  (   ),
////        .clk_int40 ( clk_int40 ),
//        .sclk    ( CLK_40M_DAC_SCLK    ),
//        .mosi    ( CLK_40M_DAC_DIN    ),
//        .sync_n  ( CLK_40M_DAC_nSYNC  ),
//        .dac_dflt  ( 16'h7ff  )
//    );

//    vio_0 u_vio_0 (
//        .clk(bus_clk),              // input wire clk
//        .probe_in0({{tx_enable1, SFDX1_RX, SFDX1_TX, SRX1_RX, SRX1_TX, LED_RX1, LED_TXRX1_RX, LED_TXRX1_TX},{tx_enable2, SFDX2_RX, SFDX2_TX, SRX2_RX, SRX2_TX, LED_RX2, LED_TXRX2_RX, LED_TXRX2_TX}}), // input wire [1 : 0] probe_in0
//        .probe_in1(pps_select),
//        .probe_in2({mimo,ref_sel})
//    //    .probe_in1(is10meg),  // input wire [0 : 0] probe_in1
//  //      .probe_in2(ispps),  // input wire [0 : 0] probe_in2
//  //      .probe_in3(ext_ref_locked),  // input wire [0 : 0] probe_in3
////        .probe_in4(ref_sel),  // input wire [0 : 0] probe_in4
// //       .probe_in5(lpps)  // input wire [0 : 0] probe_in5
//      );
    ///////////////////////////////////////////////////////////////////////
    // AD936x I/O
    ///////////////////////////////////////////////////////////////////////
    wire [31:0] rx_data0, rx_data1;
    wire [31:0] tx_data0, tx_data1;
    wire mimo;

    libresdr_b205_io  u_libresdr_b210_io (
       .areset                  ( reset_global      ),
       .mimo                    ( mimo              ),
       .rx_clk                  ( CAT_DCLK_P        ),
       .rx_frame                ( CAT_RX_FR_P       ),
       .rx_data                 ( CAT_P0_D          ),
       .rx_i0                   ( rx_data0[31:20]   ),
       .rx_q0                   ( rx_data0[15:4]    ),
       .rx_i1                   ( rx_data1[31:20]   ),
       .rx_q1                   ( rx_data1[15:4]    ),
       .radio_clk               ( radio_clk         ),
       .tx_clk                  ( CAT_FBCLK_P       ),
       .tx_frame                ( CAT_TX_FR_P        ),
       .tx_data                 ( CAT_P1_D          ),
       .tx_i0                   ( tx_data0[31:20]   ),
       .tx_q0                   ( tx_data0[15:4]    ),
       .tx_i1                   ( tx_data1[31:20]   ),
       .tx_q1                   ( tx_data1[15:4]    ),
       .radio_rst               (                   ),
       .rx_stb                  (                   ),
       .tx_stb                  (                   )
     );
    assign {rx_data0[19:16],rx_data0[3:0],rx_data1[19:16],rx_data1[3:0]} = 16'h0;


    ///////////////////////////////////////////////////////////////////////
    // SPI connections
    ///////////////////////////////////////////////////////////////////////
    wire mosi,  miso, sclk;
    wire [7:0]  sen;

    // AD936x Slave (it's the only slave for B205)
    assign CAT_SPI_EN   =  sen[0];
    assign CAT_SPI_DI   = ~sen[0] & mosi;
    assign CAT_SPI_CLK  = ~sen[0] & sclk;
    assign miso         = CAT_SPI_DO;


    ///////////////////////////////////////////////////////////////////////
    // bus signals
    ///////////////////////////////////////////////////////////////////////
    wire [63:0] ctrl_tdata, resp_tdata, rx_tdata, tx_tdata;
    wire ctrl_tlast, resp_tlast, rx_tlast, tx_tlast;
    wire ctrl_tvalid, resp_tvalid, rx_tvalid, tx_tvalid;
    wire ctrl_tready, resp_tready, rx_tready, tx_tready;

    ///////////////////////////////////////////////////////////////////////
    // frontend assignments
    ///////////////////////////////////////////////////////////////////////
    wire swap_atr_n;
    wire [7:0] radio0_gpio, radio1_gpio;
    reg [7:0] fe0_gpio, fe1_gpio;
 
    always @(posedge radio_clk) begin //Registers in the IOB
       fe0_gpio <= swap_atr_n ? radio1_gpio : radio0_gpio;
       fe1_gpio <= swap_atr_n ? radio0_gpio : radio1_gpio;
    end
    
       assign {tx_enable1, SFDX1_RX, SFDX1_TX, SRX1_RX, SRX1_TX, LED_RX1, LED_TXRX1_RX, LED_TXRX1_TX} = fe0_gpio;
       assign {tx_enable2, SFDX2_RX, SFDX2_TX, SRX2_RX, SRX2_TX, LED_RX2, LED_TXRX2_RX, LED_TXRX2_TX} = fe1_gpio;

   
 
    wire [31:0] misc_outs; reg [31:0] misc_outs_r;
 
    always @(posedge bus_clk) misc_outs_r <= misc_outs; //register misc ios to ease routing to flop
 
    wire codec_arst;
    wire tx_bandsel_a, tx_bandsel_b, rx_bandsel_a, rx_bandsel_b, rx_bandsel_c;
    
    assign { swap_atr_n, tx_bandsel_a, tx_bandsel_b, rx_bandsel_a, rx_bandsel_b, rx_bandsel_c, codec_arst, mimo, ref_sel } = misc_outs_r[8:0];
 
    assign CAT_CTL_IN = 4'b1;
    assign CAT_EN_AGC = 1'b1;
    assign CAT_TXnRX = 1'b1;
    assign CAT_EN = 1'b1;
    assign CAT_RESETn = ~codec_arst;   // Codec Reset // RESETB // Operates active-low
    assign CAT_SYNC = 1'b0;
 
    ///////////////////////////////////////////////////////////////////////
    // b200 core
    ///////////////////////////////////////////////////////////////////////
    wire [9:0] fp_gpio_in, fp_gpio_out, fp_gpio_ddr;

    b200_core #(.EXTRA_BUFF_SIZE(12)) b200_core
    (
        .bus_clk(bus_clk), .bus_rst(bus_rst),
        .tx_tdata(tx_tdata), .tx_tlast(tx_tlast), .tx_tvalid(tx_tvalid), .tx_tready(tx_tready),
        .rx_tdata(rx_tdata), .rx_tlast(rx_tlast),  .rx_tvalid(rx_tvalid), .rx_tready(rx_tready),
        .ctrl_tdata(ctrl_tdata), .ctrl_tlast(ctrl_tlast),  .ctrl_tvalid(ctrl_tvalid), .ctrl_tready(ctrl_tready),
        .resp_tdata(resp_tdata), .resp_tlast(resp_tlast),  .resp_tvalid(resp_tvalid), .resp_tready(resp_tready),

        .radio_clk(radio_clk), .radio_rst(radio_rst),
        .rx0(rx_data0), .rx1(rx_data1),
        .tx0(tx_data0), .tx1(tx_data1),
        .fe0_gpio_out(radio0_gpio), .fe1_gpio_out(radio1_gpio),
        .fp_gpio_in(fp_gpio_in), .fp_gpio_out(fp_gpio_out), .fp_gpio_ddr(fp_gpio_ddr),
        .rxd( ), .txd( ),

        .pps_ref(lpps),
        .pps_fpga_int(pps_fpga_int),
        .pps_select(pps_select),

        .sclk(sclk), .sen(sen), .mosi(mosi), .miso(miso),
        .rb_misc({31'b0, ext_ref_locked}), .misc_outs(misc_outs),


        .debug_scl(GPIF_CTL8), .debug_sda(GPIF_CTL6),
    `ifdef DEBUG_UART
            .debug_txd(FPGA_TXD0), .debug_rxd(FPGA_RXD0),
    `else
            .debug_txd(), .debug_rxd(1'b0),
    `endif
        .lock_signals(CAT_CTL_OUT[7:6]),
        .debug()
    );
    
    `ifdef TARGET_B210
   `ifdef DEBUG_UART
      gpio_atr_io #(.WIDTH(8)) gpio_atr_io_inst (   // B210 with UART
         .clk(radio_clk), .gpio_pins(fp_gpio),
         .gpio_ddr(fp_gpio_ddr[7:0]), .gpio_out(fp_gpio_out[7:0]), .gpio_in(fp_gpio_in[7:0])
      );
      assign fp_gpio_in[9:8] = 2'b00;
   `else
      gpio_atr_io #(.WIDTH(10)) gpio_atr_io_inst (  // B210 no UART
         .clk(radio_clk), .gpio_pins({FPGA_RXD0, FPGA_TXD0, fp_gpio}),
         .gpio_ddr(fp_gpio_ddr), .gpio_out(fp_gpio_out), .gpio_in(fp_gpio_in)
      );
   `endif
`else
   `ifdef DEBUG_UART
      assign fp_gpio_in = 10'h000;                  // B200 with UART
   `else
      gpio_atr_io #(.WIDTH(2)) gpio_atr_io_inst (   // B200 no UART
         .clk(radio_clk), .gpio_pins({FPGA_RXD0, FPGA_TXD0}),
         .gpio_ddr(fp_gpio_ddr[9:8]), .gpio_out(fp_gpio_out[9:8]), .gpio_in(fp_gpio_in[9:8])
      );
      assign fp_gpio_in[7:0] = 8'h00;
   `endif
`endif



    ///////////////////////////////////////////////////////////////////////
    // GPIF2
    ///////////////////////////////////////////////////////////////////////

   gpif2_slave_fifo32 #(.DATA_RX_FIFO_SIZE(14), .DATA_TX_FIFO_SIZE(14)) slave_fifo32
   (
       .gpif_clk(gpif_clk), .gpif_rst(gpif_rst), .gpif_enb(1'b1),
       .gpif_ctl({GPIF_CTL8, GPIF_CTL6, GPIF_CTL5, GPIF_CTL4}), .fifoadr({GPIF_CTL11,GPIF_CTL12}),
       .slwr(GPIF_CTL1), .sloe(GPIF_CTL2), .slcs(GPIF_CTL0), .slrd(GPIF_CTL3), .pktend(GPIF_CTL7),
       .gpif_d(GPIF_D),

       .fifo_clk(bus_clk), .fifo_rst(bus_rst),
       .tx_tdata(tx_tdata), .tx_tlast(tx_tlast), .tx_tvalid(tx_tvalid), .tx_tready(tx_tready),
       .rx_tdata(rx_tdata), .rx_tlast(rx_tlast),  .rx_tvalid(rx_tvalid), .rx_tready(rx_tready),
       .ctrl_tdata(ctrl_tdata), .ctrl_tlast(ctrl_tlast),  .ctrl_tvalid(ctrl_tvalid), .ctrl_tready(ctrl_tready),
       .resp_tdata(resp_tdata), .resp_tlast(resp_tlast),  .resp_tvalid(resp_tvalid), .resp_tready(resp_tready),

       .debug()
   );

    ODDR #(
        .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
        .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
        .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
    ) ODDR_inst (
        .Q(IFCLK),   // 1-bit DDR output
        .C(gpif_clk),   // 1-bit clock input
        .CE(1'b1), // 1-bit clock enable input
        .D1(1'b1), // 1-bit data input (positive edge)
        .D2(1'b0), // 1-bit data input (negative edge)
        .R(1'b0),   // 1-bit reset
        .S(1'b0)    // 1-bit set
    );


        assign             PPS_LED_inv          =   ~PPS_LED;
        assign             REF_LOCKED_inv       =   ~status; //ency check ok
        assign             REF_IS_10M_detect_inv=   ~is10meg;  
        
        assign             LED_RX1_inv          =   ~LED_RX1;
        assign             LED_RX2_inv          =   ~LED_RX2;
        assign             LED_TXRX1_RX_inv     =   ~LED_TXRX1_RX;
        assign             LED_TXRX1_TX_inv     =   ~LED_TXRX1_TX;
        assign             LED_TXRX2_RX_inv     =   ~LED_TXRX2_RX;
        assign             LED_TXRX2_TX_inv     =   ~LED_TXRX2_TX;
        
        
        assign             LED_RX1_R = 1'b1;
        assign             LED_RX1_B = 1'b1; 
                         
        assign             LED_RX2_R = 1'b1;  
        assign             LED_RX2_B = 1'b1; 
                         
        assign             LED_TXRX1_B= 1'b1;   
        assign             LED_TXRX2_B= 1'b1;
        
        assign             LED_USER_R = ~REF_LOCKED;
        //assign             LED_USER_B = 1'b1;
        
        
        

endmodule
`default_nettype wire
