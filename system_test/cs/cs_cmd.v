module cs_cmd(
    input sys_clk,

    input rst_sys,
    output rst_all,
    output rst_run,

    input fs_adc,
    input [7:0] adc_cnt,

    input fifoa_full,
    input fifoc_full,
    input fifod_full,

    output [7:0] sos0,
    output [7:0] sos1,
    output [7:0] sos2,
    output [7:0] sos3,

    input fs_udp_rx,
    output fs_mac2fifoc,
    output fs_fifoc2cs,
    output fd_udp_rx,
    input fd_mac2fifoc,
    input fd_fifoc2cs,

    output fs_udp_tx,
    output fs_fifod2mac,
    input fd_udp_tx,
    input fd_fifod2mac,

    output fs_adc_check,
    output fs_adc_conf,
    output fs_adc_read,
    output fs_adc_fifo,
    input fd_adc_check,
    input fd_adc_conf,
    input fd_adc_read,
    input fd_adc_fifo
);

    localparam MAIN_IDLE = 8'h00, MAIN_RESET = 8'h01, MAIN_INIT = 8'h02, MAIN_WORK = 8'h03;

    localparam INIT_IDLE = 8'h00, INIT_FFCK = 8'h01, INIT_UTOF = 8'h02, INIT_FTOC = 8'h03;
    localparam INIT_URXD = 8'h04, INIT_ADCK = 8'h05, INIT_INIT = 8'h06, INIT_CONF = 8'h07;
    localparam INIT_LAST = 8'h08;


    localparam ADC_IDLE = 8'h00, ADC_WAIT = 8'h01, ADC_READ = 8'h02, ADC_FIFO = 8'h03;
    localparam ADC_LAST = 8'h04;

    localparam ETH_IDLE = 8'h00, ETH_WAIT = 8'h01, ETH_NMCK = 8'h02, ETH_SEND = 8'h03;

    localparam CMD_NUM = 8'h04;

    // FIFO
    wire fifo_full;

    // CMD
    wire fs_init, fd_init;
    wire fs_work, fd_work;
    wire fs_eth_check, fd_eth_check;

    reg [7:0] main_state, next_main_state;
    reg [7:0] init_state, next_init_state;
    reg [7:0] adc_state, next_adc_state;
    reg [7:0] eth_state, next_eth_state;

    // 
    reg [7:0] adc_num;
    reg [7:0] cmd_num;
    reg prev_fs_adc;

    // TEST
    assign sos0 = main_state;
    assign sos1 = init_state;
    assign sos2 = adc_state;
    assign sos3 = eth_state;


    assign fs_init = (main_state == MAIN_INIT);
    assign fs_work = (main_state == MAIN_WORK);
    assign fd_init = (adc_state == INIT_LAST);
    assign fs_eth_check = (adc_state == ADC_LAST);
    assign fd_eth_check = (eth_state == ETH_WAIT);

    assign fifo_full = |{fifoa_full, fifoc_full, fifod_full};
    assign rst_all = rst_sys;
    assign rst_run = rst_sys || (main_state == MAIN_RESET);

    always @(posedge sys_clk or posedge rst_all) begin
        if(rst_all) main_state <= MAIN_IDLE;
        else main_state <= next_main_state;
    end

    always @(posedge sys_clk or posedge rst_run) begin
        if(rst_run) init_state <= INIT_IDLE;
        else init_state <= next_init_state;
    end

    always @(posedge sys_clk or posedge rst_run) begin
        if(rst_run) adc_state <= MAIN_IDLE;
        else adc_state <= next_adc_state;
    end

    always @(posedge sys_clk or posedge rst_run) begin
        if(rst_run) eth_state <= MAIN_IDLE;
        else eth_state <= next_eth_state;
    end

    always @(*) begin
        case(main_state)
            MAIN_IDLE: begin
                if(fs_udp_rx) next_main_state <= MAIN_RESET;
                else next_main_state <= MAIN_IDLE;
            end
            MAIN_RESET: begin
                if(cmd_num == CMD_NUM) next_main_state <= MAIN_INIT;
                else next_main_state <= MAIN_RESET;
            end
            MAIN_INIT: begin
                if(fd_init) next_main_state <= MAIN_WORK;
                else next_main_state <= MAIN_INIT;
            end
            MAIN_WORK: begin
                if(fs_udp_rx) next_main_state <= MAIN_IDLE;
                else next_main_state <= MAIN_WORK;
            end
            default: next_main_state <= MAIN_IDLE;
        endcase
    end

    always @(*) begin
        case(init_state)
            INIT_IDLE: begin
                if(fs_init) next_init_state <= INIT_FFCK;
                else next_init_state <= INIT_IDLE;
            end
            INIT_FFCK: begin
                if(fifo_full) next_init_state <= INIT_UTOF;
                else next_init_state <= INIT_FFCK;
            end
            INIT_UTOF: begin
                if(fd_mac2fifoc) next_init_state <= INIT_FTOC;
                else next_init_state <= INIT_UTOF;
            end
            INIT_FTOC: begin
                if(fd_fifoc2cs) next_init_state <= INIT_URXD;
                else next_init_state <= INIT_FTOC;
            end
            INIT_URXD: begin
                if(~fs_udp_rx) next_init_state <= INIT_ADCK;
                else next_init_state <= INIT_URXD;
            end
            INIT_ADCK: begin
                if(fd_adc_check) next_init_state <= INIT_INIT;
                else next_init_state <= INIT_ADCK;
            end
            INIT_INIT: begin
                next_init_state <= INIT_CONF;
            end
            INIT_CONF: begin
                if(fd_adc_check) next_init_state <= INIT_LAST;
                else next_init_state <= INIT_CONF;
            end
            INIT_LAST: begin
                if(~fs_init) next_init_state <= INIT_IDLE;
                else next_init_state <= INIT_LAST;
            end
            default: next_init_state <= INIT_IDLE;
        endcase
    end

    always @(*) begin
        case(adc_state)
            ADC_IDLE: begin
                if(fs_work) next_adc_state <= ADC_WAIT;
                else next_adc_state <= ADC_IDLE;
            end
            ADC_WAIT: begin
                if({prev_fs_adc, fs_adc} == 2'b01) next_adc_state <= ADC_READ; 
                else next_adc_state <= ADC_WAIT;
            end
            ADC_READ: begin
                if(fd_adc_read) next_adc_state <= ADC_FIFO;
                else next_adc_state <= ADC_READ;
            end
            ADC_FIFO: begin
                if(fd_adc_fifo) next_adc_state <= ADC_LAST;
                else next_adc_state <= ADC_FIFO;
            end
            ADC_LAST: begin
                if(fd_eth_check) next_adc_state <= ADC_WAIT;
                else next_adc_state <= ADC_LAST;
            end
            default: next_adc_state <= ADC_IDLE;
        endcase
    end

    always @(*) begin
        case(eth_state)
            ETH_IDLE: begin
                if(fs_work) next_eth_state <= ETH_WAIT;
                else next_eth_state <= ETH_IDLE;
            end
            ETH_WAIT: begin
                if(~fs_eth_check) next_eth_state <= ETH_NMCK;
                else next_eth_state <= ETH_WAIT;
            end
            ETH_NMCK: begin
                if(adc_num == adc_cnt - 1'b1) next_eth_state <= ETH_SEND;
                else next_eth_state <= ETH_WAIT;
            end
            ETH_SEND: begin
                if(fd_fifod2mac) next_eth_state <= ETH_WAIT;
                else next_eth_state <= ETH_SEND; 
            end
            default: next_eth_state <= ETH_IDLE;
        endcase
    end


    always @(posedge sys_clk) begin
        prev_fs_adc <= fs_adc;
    end

    always @(posedge sys_clk or posedge rst_run) begin
        if(rst_run) adc_num <= 8'h00;
        else if(eth_state == ETH_NMCK) adc_num <= adc_num + 1'b1;
        else if(eth_state == ETH_SEND) adc_num <= 8'h00;
        else adc_num <= adc_num;
    end

    always @(posedge sys_clk or posedge rst_all) begin
        if(rst_all) cmd_num <= 8'h00;
        else if(main_state == MAIN_RESET) cmd_num <= cmd_num + 1'b1;
        else cmd_num <= 8'h00;
    end




    




endmodule