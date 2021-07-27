module cs_num(
    input clk,
    input rst,
    input [7:0] cmd_kdev,

    output [9:0] adc_rx_len,
    output [11:0] eth_tx_len,

    input fs,
    output fd
);

    localparam UDP_LEN = 12'd1472;
    localparam MAX_NUM = 8'd10;

    assign adc_rx_len = adc_data_len;
    assign eth_tx_len = mac_data_len;
    assign fd = (state == DONE);

    reg [7:0] len_cnt;
    reg [7:0] state, next_state;
    reg [9:0] adc_data_len;
    reg [11:0] mac_data_len;
    reg fd_cmac;
    localparam IDLE = 8'h00, PREP = 8'h01;
    localparam DEV0 = 8'h10, DEV1 = 8'h11, DEV2 = 8'h12, DEV3 = 8'h13;
    localparam CADC = 8'h14, CMAC = 8'h20, DMAC = 8'h21;
    localparam DONE = 8'h40;

    always@(posedge clk or posedge rst) begin
        if(rst) state <= IDLE;
        else state <= next_state;
    end

    always @(*) begin
        case(state)
            IDLE: begin
                if(fs) next_state <= PREP;
                else next_state <= IDLE;
            end
            PREP: next_state <= DEV0;
            DEV0: next_state <= DEV1;
            DEV1: next_state <= DEV2;
            DEV2: next_state <= DEV3;
            DEV3: next_state <= CADC;
            CADC: next_state <= CMAC;
            CMAC: next_state <= DMAC;
            DMAC: next_state <= DONE;
            DONE: begin
                if(fs == 1'b0) next_state <= IDLE;
                else next_state <= DONE;
            end
            default: next_state <= IDLE;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if(rst) adc_data_len <= 10'h0;
        else if(state == PREP) adc_data_len <= 10'h0;
        else if(state == DEV0) begin
            case (cmd_kdev[7:6])
                2'b00: adc_data_len <= 10'h00;
                2'b01: adc_data_len <= 10'h20;
                2'b10: adc_data_len <= 10'h40;
                2'b11: adc_data_len <= 10'h80;
                default: adc_data_len <= 10'h00;
            endcase
        end
        else if(state == DEV1) begin
            case (cmd_kdev[5:4])
                2'b00: adc_data_len <= adc_data_len;
                2'b01: adc_data_len <= adc_data_len + 10'h20;
                2'b10: adc_data_len <= adc_data_len + 10'h40;
                2'b11: adc_data_len <= adc_data_len + 10'h80;
                default: adc_data_len <= adc_data_len;
            endcase
        end
        else if(state == DEV2) begin
            case (cmd_kdev[3:2])
                2'b00: adc_data_len <= adc_data_len;
                2'b01: adc_data_len <= adc_data_len + 10'h20;
                2'b10: adc_data_len <= adc_data_len + 10'h40;
                2'b11: adc_data_len <= adc_data_len + 10'h80;
                default: adc_data_len <= adc_data_len;
            endcase
        end
        else if(state == DEV3) begin
            case (cmd_kdev[1:0])
                2'b00: adc_data_len <= adc_data_len;
                2'b01: adc_data_len <= adc_data_len + 10'h20;
                2'b10: adc_data_len <= adc_data_len + 10'h40;
                2'b11: adc_data_len <= adc_data_len + 10'h80;
                default: adc_data_len <= adc_data_len;
            endcase
        end
        else if(state == CADC) adc_data_len <= adc_data_len + 10'h6;
        else adc_data_len <= adc_data_len;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            mac_data_len <= 12'h0;
            len_cnt <= 8'h0;
            fd_cmac <= 1'b0;
        end
        else if(state == PREP) begin
            mac_data_len <= UDP_LEN;
            len_cnt <= 8'h0;
            fd_cmac <= 1'b0;
        end
        else if(state == CMAC) begin
            len_cnt = UDP_LEN / adc_data_len;
        end
        else if (state == DMAC) begin
            if(len_cnt < MAX_NUM) mac_data_len <= len_cnt * adc_data_len;
            else mac_data_len <= MAX_NUM * adc_data_len;
        end
        else begin
            mac_data_len <= mac_data_len;
            len_cnt <= len_cnt;
        end
    end
endmodule