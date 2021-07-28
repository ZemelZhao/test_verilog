///////////////////////////////////////////
// key.v:
// 具有防抖功能和连按功能
// 防抖：当按下之后超高10ms后还保持按键状态则为确认按下
// 连按：当确认按下490ms后则自动识别为抬起，确认按下990ms后开始检测第二次按键
///////////////////////////////////////////
module key(
    input clk, 
    input key,
    
    output fs
);

    localparam MS10 = 32'd500_000;
    localparam MS490 = 32'd500_000;
    localparam MS500 = 32'd20_000_000;

    localparam IDLE = 8'h00, WAIT0 = 8'h01, CHECK0 = 8'h02;
    localparam START = 8'h03, CHECK1 = 8'h04, WAIT1 = 8'h05;

    reg [7:0] state, next_state;

    reg [31:0] cnt;

    assign fs = (state == START);


    always @(posedge clk) begin
        state <= next_state;
    end

    always@(*) begin
        case(state)
            IDLE: begin
                if(~key) next_state <= WAIT0;
                else next_state <= IDLE;
            end
            WAIT0: begin
                if(cnt == MS10) next_state <= CHECK0;
                else next_state <= WAIT0;
            end
            CHECK0: begin
                if(~key) next_state <= START;
                else next_state <= IDLE;
            end
            START: begin
                if(cnt == MS490) next_state <= CHECK1;
                else next_state <= START;
            end
            CHECK1: begin
                next_state <= WAIT1;
            end
            WAIT1: begin
                if(cnt == MS500) next_state <= IDLE;
                else next_state <= WAIT1;
            end
            default: next_state <= IDLE;
        endcase
    end

    always @(posedge clk) begin
        if(state == IDLE || state == CHECK0 || state == CHECK1) cnt <= 32'h0;
        else if(state == WAIT0 || state == START || state == WAIT1) cnt <= cnt + 1'b1;
        else cnt <= cnt;
    end



endmodule