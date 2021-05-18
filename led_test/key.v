module key(
    input clk,
    input key,
    
    output fs,
    input fd
);

    localparam TIME_CNT = 32'd500_000, TIME = 32'd500_000;

    localparam IDLE = 4'h0, PREP = 4'h1, WORK = 4'h2;
    reg [31:0] cnt;
    reg [3:0] state;

    reg last_key;
    assign fs = (state == WORK);

    always @(posedge clk) last_key <= key;

    always @(posedge clk) begin
        case(state)
            IDLE: begin
                if(key == 1'b0 && last_key == 1'b1) state <= PREP;
                else state <= IDLE;
            end
            PREP: begin
                if(key == 1'b1 && last_key == 1'b0) state <= WORK;
                else state <= PREP;
            end
            WORK: begin
                if(fd) state <= IDLE;
                else if(cnt == TIME) state <= IDLE;
                else state <= WORK;
            end
            default: state <= IDLE;
        endcase
    end

    always @(posedge clk) begin
        if(state == WORK) cnt <= cnt + 1'b1;
        else cnt <= 32'h0;
    end


endmodule