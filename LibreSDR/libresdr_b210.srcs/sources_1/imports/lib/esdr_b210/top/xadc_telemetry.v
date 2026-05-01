//
// xadc_telemetry.v
//
// FPGA system telemetry using the internal XADC primitive of the Artix-7.
// Cycles through junction temperature and on-die supply voltages, latches
// the results in registered outputs, and exposes the XADC over-temperature
// and alarm signals directly for use as e.g. a panic indicator on a LED.
//
// The XADC primitive is configured for default continuous-sequence mode
// with on-chip references and the four internal sensors enabled. A small
// DRP read state machine periodically pulls the latest converted values
// from the XADC status registers (no DRP writes after init).
//
// Raw value conversion (per UG480, 12-bit MSB-aligned in DO[15:4]):
//     Temp [degC]   = (temp_raw * 503.975 / 4096) - 273.15
//     Voltage [V]   = (voltage_raw * 3.0) / 4096
//
// Default XADC alarm thresholds (untouched here, see INIT_50..57 of XADC):
//     OT (over temperature) trip:  ~125 degC, latched per default config
//     Temp upper warning:          ~85 degC
//     Voltage rail alarms:          +/-5% of nominal
//
// Output rate: one full sweep (~10 us with default DCLK divider) per
//              `valid` pulse. Over-temp / alarm signals are combinational.
//

`timescale 1ns / 1ps
`default_nettype none

module xadc_telemetry (
    input  wire        clk,            // DRP clock; recommend 100 MHz, max ~250 MHz
    input  wire        reset,          // synchronous, active high

    // Latched 12-bit raw readings (MSB-aligned in XADC; we shift to align LSBs)
    output reg  [11:0] temp_raw    = 12'd0,
    output reg  [11:0] vccint_raw  = 12'd0,
    output reg  [11:0] vccaux_raw  = 12'd0,
    output reg  [11:0] vbram_raw   = 12'd0,
    output reg         valid       = 1'b0,  // 1-cycle pulse when full sweep complete

    // Direct from XADC primitive (combinational)
    output wire        over_temp,           // OT_OUT: latched until calibrated reset
    output wire [7:0]  alarm                // ALM[7:0]
);

    // ------------------------------------------------------------
    // DRP interface signals
    // ------------------------------------------------------------
    reg  [6:0]  drp_addr  = 7'h00;
    reg         drp_en    = 1'b0;
    wire [15:0] drp_do;
    wire        drp_drdy;

    // ------------------------------------------------------------
    // Status / control signals from XADC
    // ------------------------------------------------------------
    wire        busy_xadc;
    wire        eoc;        // end of conversion (single channel)
    wire        eos;        // end of sequence (full sweep done)
    wire [4:0]  channel;

    // ------------------------------------------------------------
    // Read state machine
    // ------------------------------------------------------------
    // After eos, walk the four DRP read addresses and capture results.
    // We use eos as the trigger so we read only after a complete sweep.
    //
    // DRP read addresses (per UG480 Table 4-1):
    //   0x00 = Temperature
    //   0x01 = Vccint
    //   0x02 = Vccaux
    //   0x06 = Vbram   (7-Series Artix only)
    // ------------------------------------------------------------
    localparam ST_IDLE        = 4'd0;
    localparam ST_REQ_TEMP    = 4'd1;
    localparam ST_WAIT_TEMP   = 4'd2;
    localparam ST_REQ_VCCINT  = 4'd3;
    localparam ST_WAIT_VCCINT = 4'd4;
    localparam ST_REQ_VCCAUX  = 4'd5;
    localparam ST_WAIT_VCCAUX = 4'd6;
    localparam ST_REQ_VBRAM   = 4'd7;
    localparam ST_WAIT_VBRAM  = 4'd8;
    localparam ST_DONE        = 4'd9;

    reg [3:0] state = ST_IDLE;
    reg       eos_d = 1'b0;
    wire      eos_rise = eos & ~eos_d;

    always @(posedge clk) begin
        eos_d <= eos;
        if (reset) begin
            state    <= ST_IDLE;
            drp_en   <= 1'b0;
            drp_addr <= 7'h00;
            valid    <= 1'b0;
        end else begin
            valid  <= 1'b0;
            drp_en <= 1'b0;

            case (state)
                ST_IDLE: begin
                    if (eos_rise) state <= ST_REQ_TEMP;
                end

                ST_REQ_TEMP: begin
                    drp_addr <= 7'h00;
                    drp_en   <= 1'b1;
                    state    <= ST_WAIT_TEMP;
                end
                ST_WAIT_TEMP: begin
                    if (drp_drdy) begin
                        temp_raw <= drp_do[15:4];
                        state    <= ST_REQ_VCCINT;
                    end
                end

                ST_REQ_VCCINT: begin
                    drp_addr <= 7'h01;
                    drp_en   <= 1'b1;
                    state    <= ST_WAIT_VCCINT;
                end
                ST_WAIT_VCCINT: begin
                    if (drp_drdy) begin
                        vccint_raw <= drp_do[15:4];
                        state      <= ST_REQ_VCCAUX;
                    end
                end

                ST_REQ_VCCAUX: begin
                    drp_addr <= 7'h02;
                    drp_en   <= 1'b1;
                    state    <= ST_WAIT_VCCAUX;
                end
                ST_WAIT_VCCAUX: begin
                    if (drp_drdy) begin
                        vccaux_raw <= drp_do[15:4];
                        state      <= ST_REQ_VBRAM;
                    end
                end

                ST_REQ_VBRAM: begin
                    drp_addr <= 7'h06;
                    drp_en   <= 1'b1;
                    state    <= ST_WAIT_VBRAM;
                end
                ST_WAIT_VBRAM: begin
                    if (drp_drdy) begin
                        vbram_raw <= drp_do[15:4];
                        state     <= ST_DONE;
                    end
                end

                ST_DONE: begin
                    valid <= 1'b1;          // 1-cycle pulse
                    state <= ST_IDLE;
                end

                default: state <= ST_IDLE;
            endcase
        end
    end

    // ------------------------------------------------------------
    // XADC primitive instantiation
    //
    // Configuration (per UG480 Table 4-22):
    //   INIT_40 = 0x0000  -> Config Reg 0: no averaging override, no calib disable
    //   INIT_41 = 0x2EF0  -> Config Reg 1: continuous sequence mode (SEQ=0010),
    //                       alarm enables: 0xEF disables external (we don't use them),
    //                       internal temp/voltage alarms remain enabled
    //   INIT_42 = 0x0800  -> Config Reg 2: DCLK divider = 8
    //                       (with 100 MHz DRP clock -> 12.5 MHz ADCCLK, well within max 26 MHz)
    //   INIT_48 = 0x4F47  -> Sequencer Channel Sel 0:
    //                       bit 0  TEMP    enabled
    //                       bit 1  VCCINT  enabled
    //                       bit 2  VCCAUX  enabled
    //                       bit 6  VBRAM   enabled
    //                       bit 8  CAL0    enabled (ADC offset cal)
    //                       bit 9  CAL1    enabled (ADC offset+gain cal)
    //                       bit 11 CAL3    enabled (supply sensor cal)
    //                       bit 14 reserved (must be 1 per UG480)
    //   INIT_4A = 0x0047  -> Sequencer Avg Sel 0: enable averaging on temp/voltages
    //
    // All other INIT_* registers left at default (alarm thresholds, etc.)
    // ------------------------------------------------------------
    XADC #(
        .INIT_40(16'h0000),
        .INIT_41(16'h2EF0),
        .INIT_42(16'h0800),
        .INIT_48(16'h4F47),
        .INIT_49(16'h0000),  // no external aux channels
        .INIT_4A(16'h0047),  // averaging on temp/vccint/vccaux/vbram
        .INIT_4B(16'h0000),
        .INIT_4C(16'h0000),  // all unipolar
        .INIT_4D(16'h0000),
        .INIT_4E(16'h0000),  // no acquisition extension
        .INIT_4F(16'h0000),
        // INIT_50..57: alarm thresholds (left at FPGA defaults: ~85 degC warn / ~125 OT)
        .SIM_DEVICE("7SERIES"),
        .SIM_MONITOR_FILE("design.txt")
    ) xadc_inst (
        // DRP
        .DI       (16'h0000),
        .DO       (drp_do),
        .DADDR    (drp_addr),
        .DEN      (drp_en),
        .DWE      (1'b0),
        .DRDY     (drp_drdy),
        .DCLK     (clk),
        // Conversion clock from DRP clock (no separate CONVST needed in continuous mode)
        .CONVST   (1'b0),
        .CONVSTCLK(1'b0),
        // External analog inputs (unused on B210mini)
        .VAUXP    (16'h0000),
        .VAUXN    (16'h0000),
        .VP       (1'b0),
        .VN       (1'b0),
        // Reset
        .RESET    (reset),
        // Status / outputs
        .CHANNEL  (channel),
        .EOC      (eoc),
        .EOS      (eos),
        .BUSY     (busy_xadc),
        .JTAGLOCKED   (),
        .JTAGMODIFIED (),
        .JTAGBUSY     (),
        .MUXADDR  (),
        .ALM      (alarm),
        .OT       (over_temp)
    );

endmodule

`default_nettype wire
