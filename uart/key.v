module key(
    input clk,
    input key,
    
    output fs,
    input fd
);

    localparam TIME_SHIV = 32'd500_000;
    localparam TIME_AUTO = 32'd50_000_000;

    localparam IDLE = 4'h0, PRE0 = 4'h1, PRE1 = 4'h2, WORK = 4'h3;

    reg [31:0] shiv_cnt, auto_cnt;
    reg [3:0] state, next_state;

    reg last_key;
    assign fs = (state == WORK);

    always @(posedge clk) begin
        last_key <= key;
    end


    always @(posedge clk) begin
        case(state)
            IDLE: begin
                if(key == 1'b0 && last_key == 1'b1) state <= PRE0;
                else state <= IDLE;
            end
            PRE0: begin
                if(shiv_cnt == TIME_SHIV)  state <= PRE1;
                else state <= PRE0;
            end
            PRE1: begin
                if(key == 1'b0) state <= WORK;
                else state <= IDLE;
            end
            WORK: begin
                if(fd) state <= IDLE;
                else if(auto_cnt == TIME_AUTO) state <= IDLE;
                else state <= WORK;
            end
            default: state <= IDLE;
        endcase
    end

    always @(posedge clk) begin
        if(state == PRE0) shiv_cnt <= shiv_cnt + 1'b1;
        else shiv_cnt <= 32'h0;
    end

    always @(posedge clk) begin
        if(state == WORK) auto_cnt <= auto_cnt + 1'b1;
        else auto_cnt <= 32'h0;
    end


endmodule