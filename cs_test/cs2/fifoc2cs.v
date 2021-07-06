module fifoc2cs ( // WRITE_DONE
    input clk,
    input rst,
    output err,

    input fs,
    output fd,

    output [7:0] check_show,

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

assign check_show[3:0] = ~state;

reg [7:0] check;
reg [4:0] state, next_state;
localparam IDLE = 5'h0, PRE0 = 5'h1, PRE1 = 5'h2, HED0 = 5'h3;
localparam HED1 = 5'h4, CMD0 = 5'h5, CMD1 = 5'h6, CMD2 = 5'h7;
localparam CMD3 = 5'h8, CMD4 = 5'h9, CMD5 = 5'hA, CMD6 = 5'hB;
localparam CMD7 = 5'hC, CMD8 = 5'hD, PART = 5'hE, LAST = 5'hF;
localparam ERR = 5'h18;

assign fd = (state == LAST);
assign err = (state == ERR);

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
        IDLE: if(fs) next_state <= PRE0;
        PRE0: next_state <= PRE1;
        PRE1: next_state <= HED0;
        HED0: begin
            if(fifoc_rxd != 8'h55) begin
                next_state  <= ERR;
            end
            else begin
                next_state <= HED1;
            end
        end
        HED1: begin
            if(fifoc_rxd != 8'hAA) begin
                next_state  <= ERR;
            end
            else begin
                next_state <= CMD0;
            end
        end
        CMD0: next_state <= CMD1;
        CMD1: next_state <= CMD2;
        CMD2: next_state <= CMD3;
        CMD3: next_state <= CMD4;
        CMD4: next_state <= CMD5;
        CMD5: next_state <= CMD6;
        CMD6: next_state <= CMD7;
        CMD7: next_state <= CMD8;
        CMD8: next_state <= PART;
        PART: begin
            if(check != fifoc_rxd) begin
                next_state <= ERR;
            end
            else begin
                next_state <= LAST;
            end
        end
        ERR: next_state <= ERR;
        LAST: if(fs == 1'b0) next_state <= IDLE;
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