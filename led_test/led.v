module led(
    input clk,
    input rst,
    input [3:0] num,
    output [3:0] lec,
    output [31:0] led,

    input fsu,
    input fsd,
    
    output fdu,
    output fdd,

    input [7:0] reg00,
    input [7:0] reg01,
    input [7:0] reg02,
    input [7:0] reg03,
    input [7:0] reg04,
    input [7:0] reg05,
    input [7:0] reg06,
    input [7:0] reg07,
    input [7:0] reg08,
    input [7:0] reg09,
    input [7:0] reg0A,
    input [7:0] reg0B,
    input [7:0] reg0C,
    input [7:0] reg0D,
    input [7:0] reg0E,
    input [7:0] reg0F,
    input [7:0] reg10,
    input [7:0] reg11,
    input [7:0] reg12,
    input [7:0] reg13,
    input [7:0] reg14,
    input [7:0] reg15,
    input [7:0] reg16,
    input [7:0] reg17,
    input [7:0] reg18,
    input [7:0] reg19,
    input [7:0] reg1A,
    input [7:0] reg1B,
    input [7:0] reg1C,
    input [7:0] reg1D,
    input [7:0] reg1E,
    input [7:0] reg1F,
    input [7:0] reg20,
    input [7:0] reg21,
    input [7:0] reg22,
    input [7:0] reg23,
    input [7:0] reg24,
    input [7:0] reg25,
    input [7:0] reg26,
    input [7:0] reg27,
    input [7:0] reg28,
    input [7:0] reg29,
    input [7:0] reg2A,
    input [7:0] reg2B,
    input [7:0] reg2C,
    input [7:0] reg2D,
    input [7:0] reg2E,
    input [7:0] reg2F,
    input [7:0] reg30,
    input [7:0] reg31,
    input [7:0] reg32,
    input [7:0] reg33,
    input [7:0] reg34,
    input [7:0] reg35,
    input [7:0] reg36,
    input [7:0] reg37,
    input [7:0] reg38,
    input [7:0] reg39,
    input [7:0] reg3A,
    input [7:0] reg3B,
    input [7:0] reg3C,
    input [7:0] reg3D,
    input [7:0] reg3E,
    input [7:0] reg3F
);

    localparam IDLE = 4'h0, WAIT = 4'h1, UP = 4'h2, DOWN = 4'h3;
    localparam LATU = 4'h4, LATD = 4'h5;
    reg [3:0] data_cnt;
    reg [1:0] state, next_state; 
    reg [31:0] rled;
    assign fdu = (state == LATU);
    assign fdd = (state == LATD);


    assign lec = ~data_cnt;
    assign led = ~rled;

    always @(posedge clk or posedge rst) begin
        if(rst) state <= IDLE;
        else state <= next_state;
    end

    always @(*) begin
        case(state)
            IDLE: next_state <= WAIT;
            WAIT: begin
                if(fsu) next_state <= UP;
                else if(fsd) next_state <= DOWN;
                else next_state <= WAIT;
            end
            UP: next_state <= LATU;
            DOWN: next_state <= LATD;
            LATU: if(fsu == 1'b0) next_state <= WAIT;
            LATD: if(fsd == 1'b0) next_state <= WAIT;
            default: next_state <= WAIT;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if(rst) rled <= 32'h0;
        else if(data_cnt == 4'h0) rled <= {reg00, reg01, reg02, reg03};
        else if(data_cnt == 4'h1) rled <= {reg04, reg05, reg06, reg07};
        else if(data_cnt == 4'h2) rled <= {reg08, reg09, reg0A, reg0B};
        else if(data_cnt == 4'h3) rled <= {reg0C, reg0D, reg0E, reg0F};
        else if(data_cnt == 4'h4) rled <= {reg10, reg11, reg12, reg13};
        else if(data_cnt == 4'h5) rled <= {reg14, reg15, reg16, reg17};
        else if(data_cnt == 4'h6) rled <= {reg18, reg19, reg1A, reg1B};
        else if(data_cnt == 4'h7) rled <= {reg1C, reg1D, reg1E, reg1F};
        else if(data_cnt == 4'h8) rled <= {reg20, reg21, reg22, reg23};
        else if(data_cnt == 4'h9) rled <= {reg24, reg25, reg26, reg27};
        else if(data_cnt == 4'hA) rled <= {reg28, reg29, reg2A, reg2B};
        else if(data_cnt == 4'hB) rled <= {reg2C, reg2D, reg2E, reg2F};
        else if(data_cnt == 4'hC) rled <= {reg30, reg31, reg32, reg33};
        else if(data_cnt == 4'hD) rled <= {reg34, reg35, reg36, reg37};
        else if(data_cnt == 4'hE) rled <= {reg38, reg39, reg3A, reg3B};
        else if(data_cnt == 4'hF) rled <= {reg3C, reg3D, reg3E, reg3F};
        else rled <= 32'h0;
    end

    always @(posedge clk) begin
        if(state == IDLE) data_cnt <= 4'h0;
        else if(state == UP) begin
            
            if(data_cnt < num) data_cnt <= data_cnt + 1'b1;
            else data_cnt <= 4'h0;
        end
        else if(state == DOWN) begin
            if(data_cnt > 1'b0) data_cnt <= data_cnt - 1'b1;
            else data_cnt <= num;
        end
        else data_cnt <= data_cnt;
    end



endmodule