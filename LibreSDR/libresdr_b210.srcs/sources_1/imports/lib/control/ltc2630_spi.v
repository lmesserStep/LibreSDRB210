module ltc2630_spi  (
    input   wire            clk,
    input   wire            rst,
    input   wire  [15:0]    data,
    output  reg             sclk,
    output  wire            mosi,
    output  reg             sync_n
);

    //====================================================
    //parameter define
    //====================================================
    localparam  IDLE        = 4'b0001;
    localparam  SYNC_PRE    = 4'b0010;
    localparam  DATA        = 4'b0100;
    localparam  SYNC_END    = 4'b1000;

    //====================================================
    // internal signals and registers
    //====================================================
    reg     [3:0]   state;
    reg     [3:0]   cnt_cycle   ;
    reg     [5:0]   cnt_bit     ;
    reg     [15:0]  last_data   ;
    reg     [23:0]  data_shift  ;
    wire            rising_edge ;
    wire            falling_edge;


    //----------------state------------------
    always @(posedge clk ) begin
        if (rst==1'b1) begin
            state <= IDLE;
        end
        else  begin
            case (state)
                IDLE : begin
                    // detect a new data input, the dac value needs to be updated
                    if (last_data != data) begin
                        state <= SYNC_PRE;
                    end
                end

                SYNC_PRE : begin
                    // The SYNC is low, start to update the value
                    if (falling_edge) begin
                        state <= DATA;
                    end
                end

                DATA : begin
                    if (cnt_bit == 'd23 && falling_edge) begin
                        state <= SYNC_END;
                    end
                end

                SYNC_END : begin
                    if (rising_edge == 1'b1) begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

    //----------------cnt_cycle------------------
    always @(posedge clk ) begin
        if (rst==1'b1) begin
            cnt_cycle <= 'd0;
        end
        else if (state == SYNC_PRE || state == DATA || state == SYNC_END) begin
            cnt_cycle <= cnt_cycle + 1'b1;
        end
        else  begin
            cnt_cycle <=  'd0;
        end
    end

    assign rising_edge = cnt_cycle==4'b1000;
    assign falling_edge = cnt_cycle==4'b1111;

    //----------------data_shift------------------
    always @(posedge clk ) begin
        if (rst==1'b1) begin
            data_shift <= 'd0;
        end
        else if (state == IDLE && (last_data != data)) begin
            data_shift <= {4'b0011, 4'b0000, data};
        end
        else if (state == DATA && falling_edge) begin
            data_shift <=  {data_shift[22:0], 1'b0};
        end
    end

    //----------------cnt_bit------------------
    always @(posedge clk ) begin
        if (rst==1'b1) begin
            cnt_bit <= 'd0;
        end
        else if (state == DATA ) begin
            if (cnt_bit == 'd23 && falling_edge) begin
                cnt_bit <= 'd0;
            end
            else if(falling_edge)begin
                cnt_bit <= cnt_bit + 1'b1;
            end
        end
        else  begin
            cnt_bit <=  'd0;
        end
    end

    //----------------last_data------------------
    always @(posedge clk ) begin
        if (rst==1'b1) begin
            last_data <= 'd0;
        end
        else if (state == IDLE && (last_data != data)) begin
            last_data <= data;
        end
    end

    //-----------------sclk-----------------
    always @(posedge clk ) begin
        if (rst==1'b1) begin
            sclk <= 1'b0;
        end
        else if (state==DATA && rising_edge == 1'b1) begin
            sclk <= 1'b1;
        end
        else if (state==DATA && falling_edge == 1'b1) begin
            sclk <=  1'b0;
        end
    end

    assign mosi = data_shift[23];

    //----------------sync_n------------------
    always @(posedge clk ) begin
        if (rst==1'b1) begin
            sync_n <= 1'b1;
        end
        else if (state == SYNC_PRE && falling_edge == 1'b1) begin
            sync_n <= 1'b0;
        end
        else if (state == SYNC_END && rising_edge == 1'b1) begin
            sync_n <=  1'b1;
        end
    end
    
endmodule