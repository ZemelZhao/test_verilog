module mac(
    input gmii_txc,
    input gmii_rxc,
    input rst,     

    // MAC_INFO
    input [7:0] mac_ttl,
    input [47:0] src_mac_addr,
    input [31:0] src_ip_addr,
    input [31:0] src_port,
    input [31:0] det_ip_addr,
    input [31:0] det_port,

    // ETH
    input mac_rxdv,
    input [7:0] mac_rxd,
    output mac_txdv,
    output [7:0] mac_txd,

    // UDP_TX
    input fs_udp_tx,
    input fd_udp_tx,

    input [11:0] udp_tx_len,
    input flag_udp_tx_req,
    input udp_txen,
    output flag_udp_tx_prep,
    input [7:0] udp_txd,

    // UDP_RX
    output fs_udp_rx,
    input fd_udp_rx, 

    output [7:0] udp_rxd,
    input udp_rxen,
    input [10:0] udp_rx_addr,
    output [15:0] udp_rx_len,

    // TEST
    input cmd_make,
    output cmd_done,
    input [95:0] cmd_rx,
    output [7:0] sos,
    output sob
);

    localparam IDLE = 8'h00, PREP = 8'h01, RAMW = 8'h02, LAST = 8'h03;
    localparam WFEX = 8'h10, GNEX = 8'h11, LTEX = 8'h12, LTXX = 8'h13;

    localparam PRNUM = 16'd10;

    wire fifoe_txen, fifoe_rxen;
    wire [7:0] fifoe_txd, fifoe_rxd;
    wire fifoe_full;

    reg [7:0] state, next_state;
    reg [15:0] wnum;

    wire fs_ramw, fd_ramw;

    assign cmd_done = (state == PREP);
    assign fs_ramw = (state == RAMW);
    assign fs_udp_rx = (state == LAST);
    assign flag_udp_tx_prep = (state == LTEX);
    assign sos = udp_rxd;
    assign sob = udp_rxen;
    assign udp_rx_len = 16'h14;



    always @(posedge gmii_rxc or posedge rst) begin
        if(rst) state <= IDLE;
        else state <= next_state;
    end

    always @(*) begin
        case(state)
            IDLE: begin
                if(cmd_make) next_state <= PREP;
                else if(fs_udp_tx) next_state <=  WFEX;
                else next_state <= IDLE;
            end
            PREP: begin
                if(~cmd_make) next_state <= RAMW;
                else next_state <= PREP;
            end
            RAMW: begin
                if(fd_ramw) next_state <= LAST;
                else next_state <= RAMW;
            end
            LAST: begin
                if(fd_udp_rx) next_state <= IDLE;
                else next_state <= LAST; 
            end
            WFEX: begin
                if(flag_udp_tx_req) next_state <= GNEX;
                else next_state <= WFEX;
            end
            GNEX: begin
                if(wnum == PRNUM) next_state <= LTEX;
                else next_state <= GNEX;
            end
            LTEX: begin
                if(~flag_udp_tx_req) next_state <= LTXX;
                else next_state <= LTEX;
            end
            LTXX: begin
                if(fd_udp_tx) next_state <= IDLE;
                else next_state <= LTXX;
            end
            default: next_state <= IDLE;
        endcase
    end

    always @(posedge gmii_rxc or posedge rst) begin
        if (rst) wnum <= 16'h0000;
        else if(state == GNEX) wnum <= wnum + 1'b1; 
        else wnum <= 16'h0000;
    end

    fifoe
    fifoe_dut(
        .rst(rst),

        .wr_clk(gmii_rxc),
        .wr_en(fifoe_txen),
        .din(fifoe_txd),

        .rd_clk(gmii_rxc),
        .rd_en(udp_rxen),
        .dout(udp_rxd),
        .full(fifoe_full)
    );

    ramw
    ramw_dut(
        .clk(gmii_rxc),
        .rst(rst),
        .data(cmd_rx),
        .fs(fs_ramw),
        .fd(fd_ramw),
        .fifoe_txen(fifoe_txen),
        .fifoe_txd(fifoe_txd),
        .fifoe_full(fifoe_full),
        .so()
    );    

endmodule