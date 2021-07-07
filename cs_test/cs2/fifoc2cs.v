module fifoc2cs ( // WRITE_DONE
    input clk,
    input rst,
    output err,

    input fs,
    output fd,

    output reg [7:0] so,

    output reg fifoc_rxen,
    input [7:0] fifoc_rxd,

    output reg [7:0] kind_dev,
    output reg [7:0] info_sr, // SAMPLE_RATE
    output reg [7:0] cmd_filt,
    output reg [7:0] cmd_mix0,
    output reg [7:0] cmd_mix1,
    output reg [7:0] cmd_reg4,
    output reg [7:0] cmd_reg5,
    output reg [7:0] cmd_reg6,
    output reg [7:0] cmd_reg7
);

// assign so = ~state;

reg [7:0] check;
reg [7:0] state, next_state;
localparam IDLE = 8'h00, PRE0 = 8'h01, PRE1 = 8'h02, HED0 = 8'h03;
localparam HED1 = 8'h04, CMD0 = 8'h05, CMD1 = 8'h06, CMD2 = 8'h07;
localparam CMD3 = 8'h08, CMD4 = 8'h09, CMD5 = 8'h0A, CMD6 = 8'h0B;
localparam CMD7 = 8'h0C, CMD8 = 8'h0D, PART = 8'h0E, LAST = 8'h0F;
// localparam ERR0 = 5'h18;
localparam ERR0 = 8'h11, ERR1 = 8'h12, ERR2 = 8'h13;

assign fd = (state == LAST);

always@(posedge clk or posedge rst)begin // next_state => state
    if(rst)begin
        state <= IDLE;
    end
    else begin
        state <= next_state;
    end
end

always@(*) begin // state 
    case(state) 
        IDLE: begin
            if(fs) next_state <= PRE0;
            so <= IDLE;
        end
        PRE0: begin
            next_state <= PRE1;
            so <= PRE0;
        end
        PRE1: begin
            next_state <= HED0;
            so <= PRE1;
        end
        HED0: begin
            if(fifoc_rxd != 8'h55) begin
                next_state <= ERR1;
            end
            else begin
                next_state <= HED1;
            end
        end
        HED1: begin
            if(fifoc_rxd != 8'hAA) begin
                next_state <= ERR0;
            end
            else begin
                next_state <= CMD0;
            end
        end
        CMD0: begin
            next_state <= CMD1;
            so <= CMD0;
        end
        CMD1: begin
            next_state <= CMD2;
            so <= CMD1;
        end
        CMD2: begin
            next_state <= CMD3;
            so <= CMD2;
        end
        CMD3: begin
            next_state <= CMD4;
            so <= CMD3;
        end
        CMD4: begin
            next_state <= CMD5;
            so <= CMD4;
        end
        CMD5: begin
            next_state <= CMD6;
            so <= CMD5;
        end
        CMD6: begin
            next_state <= CMD7;
            so <= CMD6;
        end
        CMD7: begin
            next_state <= CMD8;
            so <= CMD7;
        end
        CMD8: begin
            next_state <= PART;
            so <= CMD8;
        end
        PART: begin
            if(check != fifoc_rxd) begin
                next_state <= ERR2;
            end
            else begin
                next_state <= LAST;
            end
        end
        ERR0: begin
            next_state <= ERR0;
            so <= ERR0;
        end
        ERR1: begin
            next_state <= ERR1;
            so <= ERR1;
        end
        ERR2: begin
            next_state <= ERR2;
            so <= ERR2;
        end
        LAST: begin
            so <= LAST;
            if(fs == 1'b0) next_state <= IDLE;
        end
        default: next_state <= IDLE;
    endcase
end

always@(posedge clk or posedge rst) begin
    if(rst) begin
        check <= 8'h0;
        fifoc_rxen <= 1'b0;
        kind_dev <= 8'h0;
        info_sr <= 8'h0;
        cmd_filt <= 8'h0;
        cmd_mix0 <= 8'h0;
        cmd_mix1 <= 8'h0;
        cmd_reg4 <= 8'h0;
        cmd_reg5 <= 8'h0;
        cmd_reg6 <= 8'h0;
        cmd_reg7 <= 8'h0;
    end
    else begin
        case(state)
            IDLE: begin
                check <= 8'h0;
            end
            PRE0: begin
                fifoc_rxen <= 1'b1;
            end
            PRE1: begin
                fifoc_rxen <= fifoc_rxen; 
            end
            CMD0: begin
                kind_dev <= fifoc_rxd;
                check <= fifoc_rxd;
            end
            CMD1: begin
                info_sr <= fifoc_rxd;
                check <= check + fifoc_rxd;
            end
            CMD2: begin
                cmd_filt <= fifoc_rxd;
                check <= check + fifoc_rxd;
            end
            CMD3: begin
                cmd_mix0 <= fifoc_rxd;
                check <= check + fifoc_rxd;
            end
            CMD4: begin
                cmd_reg4 <= fifoc_rxd;
                check <= check + fifoc_rxd;
            end
            CMD5: begin
                cmd_reg5 <= fifoc_rxd;
                check <= check + fifoc_rxd;
            end
            CMD6: begin
                cmd_reg6 <= fifoc_rxd;
                check <= check + fifoc_rxd;
            end
            CMD7: begin
                cmd_reg7 <= fifoc_rxd;
                check <= check + fifoc_rxd;
            end
            CMD8: begin
                cmd_mix1 <= fifoc_rxd;
                check <= check + fifoc_rxd;
                fifoc_rxen <= 1'b0;
            end
            default: check <= check;
        endcase
    end
    
end

endmodule