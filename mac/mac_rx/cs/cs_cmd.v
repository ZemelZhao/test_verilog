module cs_cmd(
    input clk,
    input rst,
    output err,

    input fs_adc, 
    input [7:0] fifo2mac_num,
    output dev_grp,
    input [2:0] dev_num_ext,

    input [7:0] cmd_kdev,
    input [7:0] cmd_smpr,
    input [7:0] cmd_filt,
    input [7:0] cmd_mix0,
    input [7:0] cmd_mix1,
    input [7:0] cmd_reg4,
    input [7:0] cmd_reg5,
    input [7:0] cmd_reg6,
    input [7:0] cmd_reg7,

    output [7:0] reg00,
    output [7:0] reg01,
    output [7:0] reg02,
    output [7:0] reg03,
    output [7:0] reg04,
    output [7:0] reg05,
    output [7:0] reg06,
    output [7:0] reg07,
    output [7:0] reg08,
    output [7:0] reg09,
    output [7:0] reg10,
    output [7:0] reg11,
    output [7:0] reg12,
    output [7:0] reg13,

    output [7:0] regap, 
    output [7:0] dev_info,
    output [7:0] dev_kind,
    output [7:0] dev_smpr,

    output rst_all,
    output rst_dev,

    input fs_udp_rx,
    output fs_udp_tx,
    output fs_mac2fifoc,
    output fs_fifoc2cs,
    output fs_adc_check,
    output fs_adc_conf,
    output fs_adc_read,
    output fs_adc_fifo,
    output fs_cs_num,


    output fd_udp_rx,
    input fd_udp_tx,
    input fd_mac2fifoc,
    input fd_fifoc2cs,
    input fd_adc_check,
    input fd_adc_conf,
    input fd_adc_read,
    input fd_adc_fifo,
    input fd_cs_num
);
    wire [3:0] devid;
    wire [2:0] dev_num;

    reg [2:0] main_state, main_next_state;
    reg [2:0] init_state, init_next_state;
    reg [2:0] adc_state, adc_next_state;
    reg [2:0] mac_state, mac_next_state;


    reg prev_fs_adc;
    wire [1:0] cache_fs_adc;

    assign rst_all = rst;
    assign rst_dev = rst || fd_udp_rx;
    assign dev_num = (dev_grp) ? dev_num_ext :dev_num_int;

    assign dev_info = {devid, 1'b0, dev_num};
    assign dev_kind = cmd_kdev;
    assign dev_smpr = cmd_smpr;
    assign cache_fs_adc = {prev_fs_adc, fs_adc};

    localparam MAIN_IDLE = 3'h0, MAIN_INIT = 3'h1, MAIN_PREP = 3'h2, MAIN_OP = 3'h3;
    localparam INIT_IDLE = 3'h0, INIT_URXS = 3'h1, INIT_UTOF = 3'h2, INIT_FTOC = 3'h3;
    localparam INIT_URXD = 3'h4, INIT_CSNM = 3'h5, INIT_ADCK = 3'h6;
    localparam ADC_IDLE = 3'h0, ADC_CONF = 3'h1, ADC_PREP = 3'h2, ADC_READ = 3'h3;
    localparam ADC_FIFO = 3'h3;
    localparam MAC_IDLE = 3'h0, MAC_PREP = 3'h1, MAC_SEND = 3'h2;

    assign fs_mac2fifoc = (init_state == INIT_UTOF);
    assign fs_fifoc2cs = (init_state == INIT_FTOC);
    assign fd_udp_rx = (init_state == INIT_URXD);
    assign fs_cs_num = (init_state == INIT_CSNM);
    assign fs_adc_check = (init_state == INIT_ADCK);
    assign fs_adc_conf = (adc_state == ADC_CONF);
    assign fs_adc_read = (adc_state == ADC_READ);
    assign fs_adc_fifo = (adc_state == ADC_FIFO);
    assign fs_udp_tx = (mac_state == MAC_SEND);

    always @(posedge clk or posedge rst_dev) begin
        if(rst_all) main_state <= MAIN_IDLE;
        else if(rst_dev) main_state <= MAIN_INIT;
        else main_state <= main_next_state;
    end

    always @(posedge clk or posedge rst_all) begin
        if(rst_all) init_state <= INIT_IDLE;
        else init_state <= init_next_state; 
    end

    always @(posedge clk or posedge rst_dev) begin
        if(rst_dev) adc_state <= ADC_ADCK;
        else adc_state <= adc_next_state;
    end

    always @(posedge clk or posedge rst_dev) begin
        if(rst_dev) mac_state <= MAC_IDLE;
        else mac_state <= mac_next_state;
    end

    always @(*) begin // main_state
        case (main_state)
            MAIN_IDLE: begin
                if(fs_udp_rx) main_next_state <= MAIN_INIT;
                else main_next_state <= MAIN_IDLE;
            end
            MAIN_INIT: begin
                if(fd_adc_check) main_next_state <= MAIN_WORK;
                else main_next_state <= MAIN_INIT;
            end
            MAIN_WORK: begin
                main_next_state <= MAIN_WORK;
            end
            default: main_next_state <= MAIN_IDLE;
        endcase
    end

    always @(*) begin // init_state
        case(init_state)
            INIT_IDLE: if(main_state == MAIN_INIT) init_next_state <= INIT_URXS;
            INIT_URXS: init_next_state <= INIT_UTOF;
            INIT_UTOF: if(fd_mac2fifoc) init_next_state <= INIT_FTOC;
            INIT_FTOC: if(fd_fifoc2cs) init_next_state <= INIT_URXD;
            INIT_URXD: if(fs_udp_rx == 1'b0) init_next_state <= INIT_CSNM;
            INIT_CSNM: if(fd_cs_num) init_next_state <= INIT_ADCK;
            INIT_ADCK: if(fd_adc_check) init_next_state <= INIT_IDLE;
            default: init_next_state <= INIT_IDLE;
        endcase
    end

    always @(*) begin
        case (adc_state)
            ADC_IDLE: if(main_state == MAIN_WORK) adc_next_state <= ADC_CONF;
            ADC_CONF: if(fd_adc_conf) adc_next_state <= ADC_PREP;
            ADC_PREP: if(cache_fs_adc == 2'b01) adc_next_state <= ADC_READ;
            ADC_READ: if(fd_adc_read) adc_next_state <= ADC_FIFO;
            ADC_FIFO: if(fd_adc_fifo) adc_next_state <= ADC_PREP;
            default: adc_next_state <= ADC_IDLE;
        endcase
    end

    always @(*) begin
        case(mac_state)
            MAC_IDLE: if(main_state == MAIN_WORK) mac_next_state <= MAC_PREP;
            MAC_PREP: if(num_cnt == fifo2mac_num) mac_next_state <= MAC_SEND;
            MAC_SEND: if(fd_udp_tx) mac_next_state <= MAC_PREP;
            default: mac_next_state <= MAC_IDLE;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if(rst_dev) prev_fs_adc <= 1'b1;
        else prev_fs_adc <= fs_adc;
    end

    always @(posedge clk or posedge rst) begin
        if(rst_dev) dev_num_int <= 3'h0;
        else if(adc_state == ADC_PREP && cache_fs_adc == 2'b01) dev_num_int <= dev_num_int + 1'b1;
        else dev_num_int <= dev_num_int;
    end

    always @(posedge clk or posedge rst) begin
        if(rst_dev) num_cnt <= 4'h0;
        else if(adc_state == ADC_PREP && cache_fs_adc == 2'b01 && num_cnt < fifo2mac_num) begin
            num_cnt <= num_cnt + 1'b1;
        end
        else if(adc_state == ADC_PREP && cache_fs_adc == 2'b01 && num_cnt >= fifo2mac_num) begin
            num_cnt <= 4'h0;
        end
        else num_cnt <= num_cnt;
        
    end

    cs_cmd2reg cs_cmd2reg(
        .cmd_filt(cmd_filt),
        .cmd_mix0(cmd_mix0),
        .cmd_mix1(cmd_mix1),
        .cmd_reg4(cmd_reg4),
        .cmd_reg5(cmd_reg5),
        .cmd_reg6(cmd_reg6),
        .cmd_reg7(cmd_reg7),

        .reg00(reg00),
        .reg01(reg01),
        .reg02(reg02),
        .reg03(reg03),
        .reg04(reg04),
        .reg05(reg05),
        .reg06(reg06),
        .reg07(reg07),
        .reg08(reg08),
        .reg09(reg09),
        .reg10(reg10),
        .reg11(reg11),
        .reg12(reg12),
        .reg13(reg13),
        .regap(regap),
        .devid(devid),
        .dev_grp(dev_grp)
    );
endmodule


