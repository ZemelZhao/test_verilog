module top(
    input sys_clk,
    input rst_n,

    output [31:0] led
);

    wire [7:0] cmd_kdev;
    wire [10:0] adc_rx_len;
    wire [11:0] eth_tx_len;
    wire [7:0] data_cnt;
    wire fs, fd;
    wire rst;

    assign cmd_kdev = 8'h03;
    assign led[31] = 1'h1;
    assign led[30:20] = ~adc_rx_len;
    assign led[19:8] = ~eth_tx_len;
    assign led[7:0] = ~data_cnt; 
    assign rst = ~rst_n;


    reg [3:0] state;
    localparam IDLE = 4'h0, WORK = 4'h1, DONE = 4'h2;
    assign fs = (state == WORK);

    always @(posedge sys_clk or posedge rst) begin
        if(rst) state <= IDLE;
        else begin
            case(state)
                IDLE: state <= WORK;
                WORK: if(fd == 1'b1) state <= DONE;
                DONE: state <= DONE;
                default: state <= IDLE;
            endcase
        end
    end



    
    cs_num
    cs_num_dut(
        .clk(sys_clk),
        .rst(rst),
        .cmd_kdev(cmd_kdev),
        .adc_rx_len(adc_rx_len),
        .eth_tx_len(eth_tx_len),
        .data_cnt(data_cnt),
        .fs(fs),
        .fd(fd)
    );


endmodule