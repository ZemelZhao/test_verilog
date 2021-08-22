module test(
    input clka, 
    input gmii_rxc,
    input sys_clk,
    input rst,

    output [7:0] da0,
    output [7:0] da1,
    output [7:0] so,
    output sol
);

    assign sol = fifoc_txen;
    assign da0 = fifoe_txd;
    assign da1 = fifoc_txd;

    localparam DATA = 96'h55_AA_FF_FA_86_84_33_44_55_66_3D_8C;


    wire [95:0] mac_rx;

    wire [7:0] addra;
    wire [7:0] dina;
    wire wea;

    wire [7:0] addrb;

    wire fs_ramw;
    wire fd_ramw;

    wire fs_mac2fifoc, fs_fifoc2cs; 
    wire fd_mac2fifoc, fd_fifoc2cs;

    wire fifod_txc, fifod_rxc;
    wire fifoc_txc, fifoc_rxc;

    wire [7:0] fifoc_txd, fifoc_rxd;
    wire fifoc_txen, fifoc_rxen;
    
    wire [7:0] fifoe_txd, fifoe_rxd;
    wire fifoe_txen, fifoe_rxen;
    wire fifoe_full;

    wire [15:0] udp_rx_len;
    wire [11:0] eth_rx_len;

    assign udp_rx_len = 16'h14;
    assign fs_ramw = (state == RAMW);
    assign fs_mac2fifoc = (state == RAMR);
    assign mac_rx = DATA;
    assign so = state;

    reg [7:0] state, next_state;

    localparam IDLE = 8'h00;
    localparam RAMW = 8'h01, MID = 8'h02, RAMR = 8'h03, LAST = 8'h04;

    always @(posedge sys_clk or posedge rst) begin
        if(rst) state <= IDLE;
        else state <= next_state;
    end

    always @(*) begin
        case(state)
            IDLE: next_state <= RAMW;
            RAMW: begin
                if(fd_ramw) next_state <= MID;
                else next_state <= RAMW;
            end
            MID: next_state <= RAMR;
            RAMR: begin
                if(fd_mac2fifoc) next_state <= LAST;
                else next_state <= RAMR;
            end
            LAST: next_state <= IDLE;
            default: next_state <= IDLE;
        endcase
    end




    mac2fifoc 
    mac2fifoc_dut(
        .clk(gmii_rxc),
        .rst(rst),
        .fs(fs_mac2fifoc),
        .fd(fd_mac2fifoc),
        .udp_rxd(fifoe_rxd),
        .udp_rxen(fifoe_rxen),
        .udp_rx_len(udp_rx_len),
        .fifoc_txd(fifoc_txd),
        .fifoc_txen(fifoc_txen),
        .dev_rx_len(eth_rx_len),
        .so()
    );


    fifoe
    fifoe_dut(
        .rst(rst),

        .wr_clk(clka),
        .wr_en(fifoe_txen),
        .din(fifoe_txd),

        .rd_clk(gmii_rxc),
        .rd_en(fifoe_rxen),
        .dout(fifoe_rxd),
        .full(fifoe_full)
    );

    ramw
    ramw_dut(
        .clk(clka),
        .rst(rst),
        .data(mac_rx),
        .fs(fs_ramw),
        .fd(fd_ramw),
        .fifoe_txen(fifoe_txen),
        .fifoe_txd(fifoe_txd),
        .fifoe_full(fifoe_full)
    );


endmodule