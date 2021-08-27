module test(
    // TEST
    input gmii_txc, 
    input gmii_rxc,
    input sys_clk,
    input fifo_clk,
    input adc_rxc,

    input cmd_make,
    output cmd_done,

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
// RESET
    wire rst_mac, rst_adc;
    wire rst_fifoc, rst_fifod;
    wire rst_mac2fifoc, rst_fifod2mac;
    wire rst_fifoc2cs;

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
    wire fifoa_txc, fifoa_rxc;
    wire fifoc_txc, fifoc_rxc;
    wire fifod_txc, fifod_rxc;

    wire fifoc_txen, fifoc_rxen;
    wire fifod_txen, fifod_rxen;
    wire adc_rxen;

    wire [7:0] fifoc_txd, fifoc_rxd;
    wire [7:0] fifod_txd, fifod_rxd;
    wire [7:0] adc_rxd;

    wire fifoc_full, fifoa_full, fifod_full;

// MODE
    wire fs_udp_tx, fd_udp_tx;
    wire fs_udp_rx, fd_udp_rx;
    wire fs_mac2fifoc, fd_mac2fifoc;
    wire fs_fifoc2cs, fd_fifoc2cs;
    wire fs_fifod2mac, fd_fifod2mac;

    wire fs_adc_check, fd_adc_check;
    wire fs_adc_conf, fd_adc_conf;
    wire fs_adc_read, fd_adc_read;
    wire fs_adc_fifo, fd_adc_fifo;

// ADC
    wire [7:0] adc_reg00;
    wire [7:0] adc_reg01;
    wire [7:0] adc_reg02;
    wire [7:0] adc_reg03;
    wire [7:0] adc_reg04;
    wire [7:0] adc_reg05;
    wire [7:0] adc_reg06;
    wire [7:0] adc_reg07;
    wire [7:0] adc_reg08;
    wire [7:0] adc_reg09;
    wire [7:0] adc_reg10;
    wire [7:0] adc_reg11;
    wire [7:0] adc_reg12;
    wire [7:0] adc_reg13;
    wire [7:0] adc_regap;

// PARAMETER
    wire [7:0] kind_dev;
    wire [7:0] info_sr;
    wire [7:0] cmd_filt;
    wire [7:0] cmd_mix0;
    wire [7:0] cmd_mix1;
    wire [7:0] cmd_reg4;
    wire [7:0] cmd_reg5;
    wire [7:0] cmd_reg6;
    wire [7:0] cmd_reg7;


    wire [7:0] dev_smpr;
    wire [7:0] dev_info;
    wire [7:0] dev_kind;
    wire [7:0] dev_type;

    wire [63:0] adc_cmd;
    wire [63:0] adc_ind;
    wire [7:0] adc_lrt;
    wire [7:0] adc_end;

    // TEST
    localparam ETH_CMD = 96'h55_AA_FF_14_86_84_33_44_55_66_3D_8C;
    assign dev_kind = 8'hFF;
    assign dev_smpr = 8'hFA;

    wire [7:0] cs_sos0;
    wire [7:0] cs_sos1;
    wire [7:0] cs_sos2;
    wire [7:0] cs_sos3;

    wire [7:0] fifod2mac_sos0;

    assign sos0 = cs_sos0;
    assign sos1 = cs_sos1;
    assign sos2 = cs_sos2;
    assign sos3 = cs_sos3;
    assign sos4 = fifoc_txd;
    assign sos5 = fifoc_rxd;
    assign sos6 = fifod_txd;
    assign sos7 = fifod_rxd;
    assign sos8 = fifod2mac_sos0;

    assign sob0 = fifoc_txen;
    assign sob1 = fifoc_rxen;
    assign sob2 = fifod_txen;
    assign sob3 = fifod_rxen;
    assign sob4 = fs_udp_tx;
    assign sob5 = fd_udp_tx;
    assign sob6 = fs_fifod2mac;
    assign sob7 = fd_fifod2mac;

    // ALL  
    assign fifoa_txc = fifo_clk;
    assign fifoa_rxc = fifo_clk;
    assign fifoc_txc = gmii_rxc;
    assign fifoc_rxc = fifo_clk;
    assign fifod_txc = fifo_clk;
    assign fifod_rxc = gmii_txc;


// #region 
    // localparam IDLE = 8'h00, MC2F = 8'h02, F2CS = 8'h03, LAST = 8'h04;
    // localparam MCRX = 8'h10, MCRY = 8'h11, MCRZ = 8'h12;
    // assign sos0 = kind_dev;
    // assign sos1 = info_sr;
    // assign sos2 = cmd_filt;
    // assign sos3 = cmd_mix0;
    // assign sos4 = cmd_mix1;
    // assign sos5 = cmd_reg4;
    // assign sos6 = cmd_reg5;
    // assign sos7 = cmd_reg6;
    // assign sos8 = cmd_reg7;
    // assign sos9 = state;
    // assign cmd_make = (state == MCRX);
    // assign fd_udp_rx = (state == MCRZ);
    // assign fs_mac2fifoc = (state == MC2F);
    // assign fs_fifoc2cs = (state == F2CS);

    // reg [7:0] state, next_state;

    // always @(posedge sys_clk or posedge rst) begin
    //     if(rst) state <= IDLE;
    //     else state <= next_state;
    // end

    // always @(*) begin
    //     case(state)
    //         IDLE: begin
    //             next_state <= MCRX;
    //         end
    //         MCRX: begin
    //             if(cmd_done) next_state <= MCRY;
    //             else next_state <= MCRX;
    //         end
    //         MCRY: begin
    //             if(fs_udp_rx) next_state <= MC2F;
    //             else next_state <= MCRY;
    //         end
    //         MC2F: begin
    //             if(fd_mac2fifoc) next_state <= F2CS;
    //             else next_state <= MC2F;
    //         end
    //         F2CS: begin
    //             if(fd_fifoc2cs) next_state <= LAST;
    //             else next_state <= F2CS;
    //         end
    //         MCRZ: begin
    //             if(~fs_udp_rx) next_state <= LAST;
    //             else next_state <= MCRZ;
    //         end
    //         LAST: begin
    //             next_state <= LAST;
    //         end
    //         default: next_state <= IDLE;
    //     endcase
    // end

// #endregion

// #region
    // assign fs_adc_check = (state == CHECK);
    // assign fs_adc_conf = (state == CONF);
    // assign fs_adc_read = (state == FITX);
    // assign fs_adc_fifo = (state == FIRX);
    // assign fs_fifod2mac = (state == DTRX);
    
    // assign fs_udp_tx = fs_fifod2mac;
    // assign fd_udp_tx = fd_fifod2mac;

    // assign fifoa_txc = fifo_clk;
    // assign fifoa_rxc = fifo_clk;
    // assign fifoc_txc = gmii_rxc;
    // assign fifoc_rxc = fifo_clk;
    // assign fifod_txc = fifo_clk;
    // assign fifod_rxc = gmii_txc;

    // assign sos0 = fifod_txd;
    // assign sos1 = fifod_rxd;
    // assign sos2 = state;
    // assign sol0 = eth_tx_len;

    // localparam IDLE = 8'h00, CHECK = 8'h01, CONF = 8'h02, PREP = 8'h03;
    // localparam FITX = 8'h04, FIRX = 8'h05, CONT = 8'h06, DTRX = 8'h07;
    // localparam LAST = 8'h08;

    // always @(posedge sys_clk or posedge rst) begin
    //     if(rst) state <= IDLE;
    //     else state <= next_state;
    // end

    // always @(*) begin
    //     case(state)
    //         IDLE: begin
    //             next_state <= CHECK;
    //         end
    //         CHECK: begin
    //             if(fd_check) next_state <= CONF;
    //             else next_state <= CHECK;
    //         end
    //         CONF: begin
    //             if(fd_conf) next_state <= PREP;
    //             else next_state <= CONF;
    //         end
    //         PREP: begin
    //             if(~fifo_full) next_state <= FITX;
    //             else next_state <= PREP;
    //         end
    //         FITX: begin
    //             if(fd_read) next_state <= FIRX;
    //             else next_state <= FITX;
    //         end
    //         FIRX: begin
    //             if(fd_fifo) next_state <= CONT;
    //             else next_state <= FIRX;
    //         end
    //         CONT: begin
    //             if(adc_num < adc_cnt - 1'b1) next_state <= LAST;
    //             else next_state <= DTRX;
    //         end
    //         DTRX: begin
    //             if(fd_fifod2mac) next_state <= LAST;
    //             else next_state <= DTRX;
    //         end
    //         LAST: begin
    //             next_state <= PREP;
    //         end
    //         default: next_state <= IDLE;
    //     endcase
    // end

    // always @(posedge sys_clk or posedge rst) begin
    //     if(rst) adc_num <= 8'h0;
    //     else if(state == CONT) adc_num <= adc_num + 1'b1;
    //     else if(state == DTRX) adc_num <= 8'h0;
    //     else adc_num <= adc_num;
    // end
// #endregion

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
        .cmd_rx(ETH_CMD)
    );

    adc
    adc_dut(
        .sys_clk(sys_clk),
        .fifoa_txc(fifoa_txc),
        .fifoa_rxc(fifoa_rxc),

        .rst(rst_adc),
        .spi_mc(),

        .adc_rxen(adc_rxen),
        .adc_rxd(adc_rxd),

        .fs_check(fs_adc_check),
        .fd_check(fd_adc_check),
        .fs_conf(fs_adc_conf),
        .fd_conf(fd_adc_conf),
        .fs_read(fs_adc_read),
        .fd_read(fd_adc_read),
        .fs_fifo(fs_adc_fifo),
        .fd_fifo(fd_adc_fifo),

        .dev_smpr(dev_smpr),
        .dev_info(dev_info),
        .dev_kind(dev_kind),
        .dev_type(dev_type),

        .fifoa_full(fifoa_full),

        .adc_cmd(adc_cmd),
        .adc_ind(adc_ind),
        .adc_lrt(adc_lrt),
        .adc_end(adc_end)
    );

    fifoc
    fifoc_dut(
        .rst(rst),

        .wr_clk(fifoc_txc),
        .din(fifoc_txd),
        .wr_en(fifoc_txen),

        .rd_clk(fifoc_rxc),
        .dout(fifoc_rxd),
        .rd_en(fifoc_rxen),

        .full(fifoc_full)
    );

    fifod
    fifod_dut(
        .rst(),
        
        .wr_clk(fifod_txc),
        .din(fifod_txd),
        .wr_en(fifod_txen),

        .rd_clk(fifod_rxc),
        .dout(fifod_rxd),
        .rd_en(fifod_rxen),

        .full(fifod_full)
    );

    


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
        .dev_rx_len(eth_rx_len)
    );

    fifoc2cs
    fifoc2cs_dut(
        .clk(fifoc_rxc),
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
        .cmd_reg7(cmd_reg7)
    );

    adc2fifod
    adc2fifod_dut(
        .fifod_txd(fifod_txd),
        .fifod_txen(fifod_txen),
        .adc_rxen(adc_rxen),
        .adc_rxd(adc_rxd)
    );


    fifod2mac 
    fifod2mac_dut(
        .clk(fifod_rxc),
        .rst(rst),
        .fs(fs_fifod2mac),
        .fd(fd_fifod2mac),
        .data_len(eth_tx_len),
        .fifod_rxen(fifod_rxen),
        .fifod_rxd(fifod_rxd),
        .udp_txen(udp_txen),
        .udp_txd(udp_txd),
        .flag_udp_tx_prep(flag_udp_tx_prep),
        .flag_udp_tx_req(flag_udp_tx_req),
        .sos0(fifod2mac_sos0)
    );

    cs
    cs_dut(
        // CLK
        .osc_clk(sys_clk),
        .eth_clk(),
        .sys_clk(),
        .gmii_rxc(),
        .gmii_txc(),
        .spi_mclk(),

        .fifoa_txc(),
        .fifoa_rxc(),
        .fifoc_txc(),
        .fifoc_rxc(),
        .fifod_txc(),
        .fifod_rxc(),

        // RST
        .rst_sys(rst),
        .rst_mac(rst_mac),
        .rst_adc(rst_adc),
        .rst_fifoc(rst_fifoc),
        .rst_fifod(rst_fifod),
        .rst_mac2fifoc(rst_mac2fifoc),
        .rst_fifoc2cs(rst_fifoc2cs),
        .rst_adc2fifod(),
        .rst_fifod2mac(rst_fifod2mac),

        // TEST
        .adc_rxc(adc_rxc),
        .sos0(cs_sos0),
        .sos1(cs_sos1),
        .sos2(cs_sos2),
        .sos3(cs_sos3),

        // ERR

        // ADC_CMD
        .cmd_filt(cmd_filt),
        .cmd_mix0(cmd_mix0),
        .cmd_mix1(cmd_mix1),
        .cmd_reg4(cmd_reg4),
        .cmd_reg5(cmd_reg5),
        .cmd_reg6(cmd_reg6),
        .cmd_reg7(cmd_reg7),

        .adc_reg00(adc_reg00),
        .adc_reg01(adc_reg01),
        .adc_reg02(adc_reg02),
        .adc_reg03(adc_reg03),
        .adc_reg04(adc_reg04),
        .adc_reg05(adc_reg05),
        .adc_reg06(adc_reg06),
        .adc_reg07(adc_reg07),
        .adc_reg08(adc_reg08),
        .adc_reg09(adc_reg09),
        .adc_reg10(adc_reg10),
        .adc_reg11(adc_reg11),
        .adc_reg12(adc_reg12),
        .adc_reg13(adc_reg13),
        .adc_regap(adc_regap),

        // FIFO
        .fifoa_full(fifoa_full),
        .fifoc_full(fifoc_full),
        .fifod_full(fifod_full),

        // FLAG
        // FLAG_CMD
        .fs_udp_rx(fs_udp_rx),
        .fd_udp_rx(fd_udp_rx),
        .fs_mac2fifoc(fs_mac2fifoc),
        .fd_mac2fifoc(fd_mac2fifoc),
        .fs_fifoc2cs(fs_fifoc2cs),
        .fd_fifoc2cs(fd_fifoc2cs),

        // FLAG_DATA
        .fs_udp_tx(fs_udp_tx),
        .fd_udp_tx(fd_udp_tx),
        .fs_fifod2mac(fs_fifod2mac),
        .fd_fifod2mac(fd_fifod2mac),

        // FLAG_ADC
        .fs_adc_check(fs_adc_check),
        .fd_adc_check(fd_adc_check),
        .fs_adc_conf(fs_adc_conf),
        .fd_adc_conf(fd_adc_conf),
        .fs_adc_read(fs_adc_read),
        .fd_adc_read(fd_adc_read),
        .fs_adc_fifo(fs_adc_fifo),
        .fd_adc_fifo(fd_adc_fifo),

        // NUM
        .kind_dev(dev_type),
        .dev_info(dev_info),
        .adc_rx_len(adc_rx_len),
        .eth_tx_len(eth_tx_len),

        .intan_cmd(adc_cmd),
        .intan_ind(adc_ind),
        .intan_lrt(adc_lrt),
        .intan_end(adc_end)
    );


endmodule