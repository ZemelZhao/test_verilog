module test(
    input gmii_txc, 
    input gmii_rxc,
    input sys_clk,
    input fifo_clk,
    input rst,

    output [63:0] sol0,
    output [63:0] sol1,
    output [63:0] sol2,
    output [63:0] sol3,    
    output [63:0] sol4,
    output [63:0] sol5,
    output [63:0] sol6,
    output [63:0] sol7,   
    output [63:0] sol8,
    output [63:0] sol9,
    output [63:0] solA,
    output [63:0] solB,    
    output [63:0] solC,
    output [63:0] solD,
    output [63:0] solE,
    output [63:0] solF,   
    output [7:0] sos0,
    output [7:0] sos1,
    output [7:0] sos2,
    output [7:0] sos3,    
    output [7:0] sos4,
    output [7:0] sos5,
    output [7:0] sos6,
    output [7:0] sos7,   
    output [7:0] sos8,
    output [7:0] sos9,
    output [7:0] sosA,
    output [7:0] sosB,    
    output [7:0] sosC,
    output [7:0] sosD,
    output [7:0] sosE,
    output [7:0] sosF,   
    output sob0,
    output sob1,
    output sob2,
    output sob3,    
    output sob4,
    output sob5,
    output sob6,
    output sob7,   
    output sob8,
    output sob9,
    output sobA,
    output sobB,    
    output sobC,
    output sobD,
    output sobE,
    output sobF   
);

// MAC
    localparam SOURCE_MAC_ADDR = 48'h00_0A_35_01_FE_C0;
    localparam SOURCE_IP_ADDR = 32'hC0_A8_00_02;
    localparam SOURCE_PORT = 16'h1F90;
    localparam DESTINATION_IP_ADDR = 32'hC0_A8_00_03;
    localparam DESTINATION_PORT = 16'h1F90;
    localparam MAC_TTL = 8'h80;

    wire [11:0] eth_rx_len;
    wire [11:0] eth_tx_len;
    wire [9:0] adc_rx_len;

    wire [15:0] udp_rx_len;
    wire [10:0] udp_rx_addr;
    wire udp_rxen;
    wire udp_txen;
    wire [7:0] udp_txd;
    wire [7:0] udp_rxd;

    wire flag_udp_tx_req, flag_udp_tx_prep;

// FIFO
    wire fifoc_txen, fifoc_rxen;
    wire [7:0] fifoc_txd, fifoc_rxd;
    wire fifoc_full;


    wire fs_udp_tx, fd_udp_tx;
    wire fs_udp_rx, fd_udp_rx;
    wire fs_mac2fifoc, fd_mac2fifoc;
    wire fs_fifoc2cs, fd_fifoc2cs;


    wire [7:0] kind_dev;
    wire [7:0] info_sr;
    wire [7:0] cmd_filt;
    wire [7:0] cmd_mix0;
    wire [7:0] cmd_mix1;
    wire [7:0] cmd_reg4;
    wire [7:0] cmd_reg5;
    wire [7:0] cmd_reg6;
    wire [7:0] cmd_reg7;

    // TEST
    wire cmd_make, cmd_done;
    localparam ETH_CMD = 96'h55_AA_FF_14_86_84_33_44_55_66_3D_8C;
    localparam IDLE = 8'h00, MC2F = 8'h02, F2CS = 8'h03, LAST = 8'h04;
    localparam MCRX = 8'h10, MCRY = 8'h11, MCRZ = 8'h12;


    assign sos0 = kind_dev;
    assign sos1 = info_sr;
    assign sos2 = cmd_filt;
    assign sos3 = cmd_mix0;
    assign sos4 = cmd_mix1;
    assign sos5 = cmd_reg4;
    assign sos6 = cmd_reg5;
    assign sos7 = cmd_reg6;
    assign sos8 = cmd_reg7;
    assign sos9 = state;
    assign cmd_make = (state == MCRX);
    assign fd_udp_rx = (state == MCRZ);
    assign fs_mac2fifoc = (state == MC2F);
    assign fs_fifoc2cs = (state == F2CS);

    reg [7:0] state, next_state;

    always @(posedge sys_clk or posedge rst) begin
        if(rst) state <= IDLE;
        else state <= next_state;
    end

    always @(*) begin
        case(state)
            IDLE: begin
                next_state <= MCRX;
            end
            MCRX: begin
                if(cmd_done) next_state <= MCRY;
                else next_state <= MCRX;
            end
            MCRY: begin
                if(fs_udp_rx) next_state <= MC2F;
                else next_state <= MCRY;
            end
            MC2F: begin
                if(fd_mac2fifoc) next_state <= F2CS;
                else next_state <= MC2F;
            end
            F2CS: begin
                if(fd_fifoc2cs) next_state <= LAST;
                else next_state <= F2CS;
            end
            MCRZ: begin
                if(~fs_udp_rx) next_state <= LAST;
                else next_state <= MCRZ;
            end
            LAST: begin
                next_state <= LAST;
            end
            default: next_state <= IDLE;
        endcase
    end




    mac
    mac_dut(
        .gmii_txc(gmii_txc),
        .gmii_rxc(gmii_rxc),
        .rst(rst),
        .mac_ttl(MAC_TTL),
        .src_mac_addr(SOURCE_MAC_ADDR),
        .src_ip_addr(SOURCE_IP_ADDR),
        .src_port(SOURCE_PORT),
        .det_ip_addr(DESTINATION_IP_ADDR),
        .det_port(DESTINATION_PORT),
        .mac_rxdv(),
        .mac_rxd(),
        .mac_txdv(),
        .mac_txd(),
        .fs_udp_tx(fs_udp_tx),
        .fd_udp_tx(fd_udp_tx),
        .udp_tx_len(eth_tx_len),
        .flag_udp_tx_req(flag_udp_tx_req),
        .udp_txen(udp_txen),
        .flag_udp_tx_prep(flag_udp_tx_prep),
        .udp_txd(udp_txd),
        .fs_udp_rx(fs_udp_rx),
        .fd_udp_rx(fd_udp_rx),
        .udp_rxd(udp_rxd),
        .udp_rxen(udp_rxen),
        .udp_rx_addr(udp_rx_addr),
        .udp_rx_len(udp_rx_len),

        .cmd_make(cmd_make),
        .cmd_done(cmd_done),
        .cmd_rx(ETH_CMD),
        .sos(sosA),
        .sob(sob0)
    );

    fifoc
    fifoc_dut(
        .rst(rst),

        .wr_clk(gmii_rxc),
        .din(fifoc_txd),
        .wr_en(fifoc_txen),

        .rd_clk(fifo_clk),
        .dout(fifoc_rxd),
        .rd_en(fifoc_rxen),

        .full(fifoc_full)
    );

    // fifod
    // fifod_dut(
    //     .rst(),
        
    //     .wr_clk(sys_clk),
    //     .din(fifod_txd),
    //     .wr_en(fifod_txen),

    //     .rd_clk(gmii_txc),
    //     .dout(fifod_rxd),
    //     .rd_en(fifod_rxen),

    //     .full(fifod_full)
    // );

    


    mac2fifoc 
    mac2fifoc_dut(
        .clk(gmii_rxc),
        .rst(),
        .fs(fs_mac2fifoc),
        .fd(fd_mac2fifoc),
        .udp_rxd(udp_rxd),
        .udp_rx_addr(udp_rx_addr),
        .udp_rxen(udp_rxen),
        .udp_rx_len(udp_rx_len),
        .fifoc_txd(fifoc_txd),
        .fifoc_txen(fifoc_txen),
        .dev_rx_len(eth_rx_len),
        .so(sosB)
    );

    fifoc2cs
    fifoc2cs_dut(
        .clk(fifo_clk),
        .rst(rst),
        .err(),
        .fs(fs_fifoc2cs),
        .fd(fd_fifoc2cs),
        .fifoc_rxen(fifoc_rxen),
        .fifoc_rxd(fifoc_rxd),
        .data_len(eth_rx_len),
        .kind_dev(kind_dev),
        .info_sr(info_sr),
        .cmd_filt(cmd_filt),
        .cmd_mix0(cmd_mix0),
        .cmd_mix1(cmd_mix1),
        .cmd_reg4(cmd_reg4),
        .cmd_reg5(cmd_reg5),
        .cmd_reg6(cmd_reg6),
        .cmd_reg7(cmd_reg7),
        .so(sosC)
    );

    // fifod2mac 
    // fifod2mac_dut (
    //     .clk(sys_clk),
    //     .rst(rst),
    //     .fs(fs_fifod2mac),
    //     .fd(fd_fifod2mac),
    //     .data_len(eth_tx_len),
    //     .fifod_rxen(fifod_rxen),
    //     .fifod_rxd(fifod_rxd),
    //     .udp_txen(udp_txen),
    //     .udp_txd(udp_txd),
    //     .flag_udp_tx_prep(flag_udp_tx_prep),
    //     .flag_udp_tx_req(flag_udp_tx_req)
    // );



endmodule