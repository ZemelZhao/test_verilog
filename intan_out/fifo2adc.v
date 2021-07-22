// ## 0. DOCUMENT SECTION
// #region 
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
//                                                                              //
//      Author: ZemZhao                                                         //
//      E-mail: zemzhao@163.com                                                 //
//      Please feel free to contact me if there are BUGs in my program.         //
//      For I know they are everywhere.                                         //
//      I can do nothing but encourage you to debug desperately.                //
//      GOOD LUCK, HAVE FUN!!                                                   //
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
//                              SJTU BCI-Lab 205                                //
//                            All rights reserved                               //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////
// fifo2adc.v:
// 该文件完成 ADC-II 中的多个FIFO 向 ETH-II 中的单个FIFO进行数据传输

// ## 1. 具体功能
// * 

// ## 2. 变量综述
// * cache_fifoi_rxen 
// * fifod_txen 
// *  

//////////////////////////////////////////////////////////////////////////////////
// #endregion 
module fifo2adc( // 
    // ## 1. IO SECTION
    // #region

    // #### CRE SECTION
    input clk,
    input rst,
    output err,

    // #### CONTROL SECTION
    // ###### OPTION PART
    input fs_conf,
    output fd_conf,
    input fs_fifo,
    output fd_fifo,

    output reg fifod_txen, // fifod 的参考写入
    output reg [7:0] cache_fifoi_rxen, //intan_fifo的读入控制部分
    // ###### DATA PART

    // #### DATA_SECTION
    input [7:0] dev_kind, // 输入的需对照的各下级设备参数
    input [7:0] dev_info, // 前4位为当前设备编号，后4位为当前数据编号
    input [7:0] dev_smpr,

    input [63:0] cache_fifoi_rxd,
    output [7:0] fifod_txd,
    
    output reg [9:0] data_len
    // #endregion
);
    
    // ## 2. VARIABLE SECTION
    // #regiond
    // #### 1. REGISTER PART
    // #region
    // ###### OPTION
    reg[7:0] state_opt, next_state_opt;
    // ###### LINK
    reg [7:0] state_fifo, next_state_fifo;
    reg [7:0] cache_fifo_cmd[8:0]; // 记录当前的与INTAN部分FIFO的 0x80 // FIFO_RD_EN
    reg [8:0] cache_fifo_lor; // 记录当前FIFO读取是否为32通道
    reg [8:0] cache_fifo_end; // 记录当前是否为读取的最后一个FIFO
    reg [7:0] cache_fifo_ind[8:0]; // 0x3F // FIFO_IND
    reg [7:0] cache_fifo_num;
    reg [7:0] fifo_ind;
    reg [7:0] pprev_fifo_ind, prev_fifo_ind;
    reg flag_hord; // HEAD OR DATA

    reg flag_lort; // DATA LONG OR SHORT
    reg flag_end;
    reg [7:0] flag_cmd, nflag_cmd;
    reg [7:0] flag_ind;
    // ###### DATA
    reg [7:0] head_data;
    reg [7:0] fifo_num;
    reg [7:0] fifo_num_opt;
    reg prev_fifod_txen;
    // #endregion

    // #### 2. WIRE PART
    // #region
    // ###### LINK
    wire [7:0] fifo_cmd;
    // #endregion

    // #### 3. PARAMETER PART
    // #region
    // ###### STATE MACHINE PAGE
    // MAIN
    localparam MAIN_IDLE = 8'h00;

    // OPTION
    localparam IDLE_OPTION = 8'h10;
    localparam OPTION0 = 8'h11, OPTION1 = 8'h12, OPTION2 = 8'h13, OPTION3 = 8'h14;
    localparam OPTION_END = 8'h15, OPTION_DONE = 8'h16;

    // DATA
    localparam IDLE_READ = 8'h40;
    localparam HEAD00 = 8'h41, HEAD01 = 8'h42, DEVOPT = 8'h43, DEVSPR = 8'h44;
    localparam DEVTYE = 8'h45; 
    localparam DAT00H = 8'h50, DAT00L = 8'h51, DAT01H = 8'h52, DAT01L = 8'h53;
    localparam DAT02H = 8'h54, DAT02L = 8'h55, DAT03H = 8'h56, DAT03L = 8'h57;
    localparam DAT04H = 8'h58, DAT04L = 8'h59, DAT05H = 8'h5A, DAT05L = 8'h5B;
    localparam DAT06H = 8'h5C, DAT06L = 8'h5D, DAT07H = 8'h5E, DAT07L = 8'h5F;
    localparam DAT08H = 8'h60, DAT08L = 8'h61, DAT09H = 8'h62, DAT09L = 8'h63;
    localparam DAT10H = 8'h64, DAT10L = 8'h65, DAT11H = 8'h66, DAT11L = 8'h67;
    localparam DAT12H = 8'h68, DAT12L = 8'h69, DAT13H = 8'h6A, DAT13L = 8'h6B;
    localparam DAT14H = 8'h6C, DAT14L = 8'h6D, DAT15H = 8'h6E, DAT15L = 8'h6F;
    localparam DAT16H = 8'h70, DAT16L = 8'h71, DAT17H = 8'h72, DAT17L = 8'h73;
    localparam DAT18H = 8'h74, DAT18L = 8'h75, DAT19H = 8'h76, DAT19L = 8'h77;
    localparam DAT20H = 8'h78, DAT20L = 8'h79, DAT21H = 8'h7A, DAT21L = 8'h7B;
    localparam DAT22H = 8'h7C, DAT22L = 8'h7D, DAT23H = 8'h7E, DAT23L = 8'h7F;
    localparam DAT24H = 8'h80, DAT24L = 8'h81, DAT25H = 8'h82, DAT25L = 8'h83;
    localparam DAT26H = 8'h84, DAT26L = 8'h85, DAT27H = 8'h86, DAT27L = 8'h87;
    localparam DAT28H = 8'h88, DAT28L = 8'h89, DAT29H = 8'h8A, DAT29L = 8'h8B;
    localparam DAT30H = 8'h8C, DAT30L = 8'h8D, DAT31H = 8'h8E, DAT31L = 8'h8F;
    localparam DATACK = 8'hA0, DATA_START = 8'hA1, DATA_DONE = 8'hA2;
    // #endregion
    // #endregion

    // ## 3. LOGICAL SECTION
    // #region
    // #### 1. COMBINATIONAL LOGIC PART
    // #region
    assign fifod_txd = (flag_hord==1'b1) ?head_data :cache_fifoi_rxd[fifo_ind -: 8];
    // assign cache_fifoi_rxen = cache_fifo_cmd[fifo_num];
    assign fd_fifo = (state_fifo == DATA_DONE);
    assign fd_conf = (state_opt == OPTION_DONE);

    // #endregion

    // #### 2. SEQUENTIAL LOGIC PART
    // #region
    always @(posedge clk or posedge rst) begin // STATE
        if(rst) begin
            state_fifo <= MAIN_IDLE;
            state_opt <= MAIN_IDLE;
        end
        else begin
            state_fifo <= next_state_fifo;
            state_opt <= next_state_opt;
        end
    end

    always @(*) begin // STATE_OPT
        case(state_opt)
            MAIN_IDLE: begin
                if(fs_conf)begin
                    next_state_opt <= IDLE_OPTION;
                end
                else begin
                    next_state_opt <= MAIN_IDLE;
                end
            end
            IDLE_OPTION: next_state_opt <= OPTION0;
            OPTION0: next_state_opt <= OPTION1;
            OPTION1: next_state_opt <= OPTION2;
            OPTION2: next_state_opt <= OPTION3;
            OPTION3: next_state_opt <= OPTION_END;
            OPTION_END: next_state_opt <= OPTION_DONE;
            OPTION_DONE: begin
                if(fs_conf == 1'b0) begin
                    next_state_opt <= MAIN_IDLE;
                end
                else begin
                    next_state_opt <= OPTION_DONE;
                end
            end
        endcase
    end
    
    always @(posedge clk or posedge rst) begin // cache_fifoi_rxen
        if(rst) begin
            cache_fifoi_rxen <= 8'h00;
        end
        else if(state_fifo == DAT31H && (~flag_end)) begin
            cache_fifoi_rxen <= flag_cmd | nflag_cmd;
        end
        else if(state_fifo == DAT31H && (flag_end)) begin
            cache_fifoi_rxen <= flag_cmd;
        end
        else if(state_fifo == DAT15H &&(~flag_end) && (~flag_lort)) begin
            cache_fifoi_rxen <= flag_cmd | nflag_cmd;
        end
        else if(state_fifo == DAT15H &&(flag_end) && (~flag_lort)) begin
            cache_fifoi_rxen <= flag_cmd;
        end 
        else if(state_fifo == DAT15L &&(flag_end) && (~flag_lort)) begin
            cache_fifoi_rxen <= 8'h00;
        end
        else if(state_fifo == DAT31L && (flag_end)) begin
            cache_fifoi_rxen <= 8'h00;
        end       
        else if(state_fifo == DATACK) begin
            cache_fifoi_rxen <= 8'h00;
        end
        else begin
            cache_fifoi_rxen <= cache_fifo_cmd[fifo_num];
        end

    end
    
    always@(*) begin // STATE_READ
        case(state_fifo)
            MAIN_IDLE: begin
                if(fs_fifo)begin
                    next_state_fifo <= IDLE_READ;
                end
                else begin
                    next_state_fifo <= MAIN_IDLE;
                end
            end
            IDLE_READ: next_state_fifo <= HEAD00;
            HEAD00: next_state_fifo <= HEAD01;
            HEAD01: next_state_fifo <= DEVOPT;
            DEVOPT: next_state_fifo <= DEVSPR;
            DEVSPR: next_state_fifo <= DEVTYE;
            DEVTYE: next_state_fifo <= DATA_START;
            DATA_START: next_state_fifo <= DAT00H;
            DAT00H: next_state_fifo <= DAT00L;
            DAT00L: next_state_fifo <= DAT01H;
            DAT01H: next_state_fifo <= DAT01L;
            DAT01L: next_state_fifo <= DAT02H;
            DAT02H: next_state_fifo <= DAT02L;
            DAT02L: next_state_fifo <= DAT03H;
            DAT03H: next_state_fifo <= DAT03L;
            DAT03L: next_state_fifo <= DAT04H;
            DAT04H: next_state_fifo <= DAT04L;
            DAT04L: next_state_fifo <= DAT05H;
            DAT05H: next_state_fifo <= DAT05L;
            DAT05L: next_state_fifo <= DAT06H;
            DAT06H: next_state_fifo <= DAT06L;
            DAT06L: next_state_fifo <= DAT07H;
            DAT07H: next_state_fifo <= DAT07L;
            DAT07L: next_state_fifo <= DAT08H;
            DAT08H: next_state_fifo <= DAT08L;
            DAT08L: next_state_fifo <= DAT09H;
            DAT09H: next_state_fifo <= DAT09L;
            DAT09L: next_state_fifo <= DAT10H;
            DAT10H: next_state_fifo <= DAT10L;
            DAT10L: next_state_fifo <= DAT11H;
            DAT11H: next_state_fifo <= DAT11L;
            DAT11L: next_state_fifo <= DAT12H;
            DAT12H: next_state_fifo <= DAT12L;
            DAT12L: next_state_fifo <= DAT13H;
            DAT13H: next_state_fifo <= DAT13L;
            DAT13L: next_state_fifo <= DAT14H;
            DAT14H: next_state_fifo <= DAT14L;
            DAT14L: next_state_fifo <= DAT15H;
            DAT15H: next_state_fifo <= DAT15L;
            DAT15L: begin
                if(flag_lort) next_state_fifo <= DAT16H;
                else if(flag_end) next_state_fifo <= DATACK;
                else next_state_fifo <= DAT00H;
            end
            DAT16H: next_state_fifo <= DAT16L;
            DAT16L: next_state_fifo <= DAT17H;
            DAT17H: next_state_fifo <= DAT17L;
            DAT17L: next_state_fifo <= DAT18H;
            DAT18H: next_state_fifo <= DAT18L;
            DAT18L: next_state_fifo <= DAT19H;
            DAT19H: next_state_fifo <= DAT19L;
            DAT19L: next_state_fifo <= DAT20H;
            DAT20H: next_state_fifo <= DAT20L;
            DAT20L: next_state_fifo <= DAT21H;
            DAT21H: next_state_fifo <= DAT21L;
            DAT21L: next_state_fifo <= DAT22H;
            DAT22H: next_state_fifo <= DAT22L;
            DAT22L: next_state_fifo <= DAT23H;
            DAT23H: next_state_fifo <= DAT23L;
            DAT23L: next_state_fifo <= DAT24H;
            DAT24H: next_state_fifo <= DAT24L;
            DAT24L: next_state_fifo <= DAT25H;
            DAT25H: next_state_fifo <= DAT25L;
            DAT25L: next_state_fifo <= DAT26H;
            DAT26H: next_state_fifo <= DAT26L;
            DAT26L: next_state_fifo <= DAT27H;
            DAT27H: next_state_fifo <= DAT27L;
            DAT27L: next_state_fifo <= DAT28H;
            DAT28H: next_state_fifo <= DAT28L;
            DAT28L: next_state_fifo <= DAT29H;
            DAT29H: next_state_fifo <= DAT29L;
            DAT29L: next_state_fifo <= DAT30H;
            DAT30H: next_state_fifo <= DAT30L;
            DAT30L: next_state_fifo <= DAT31H;
            DAT31H: next_state_fifo <= DAT31L;
            DAT31L: begin
                if(flag_end) begin
                    next_state_fifo <= DATACK;
                end
                else begin
                    next_state_fifo <= DAT00H;
                end
            end
            DATACK: next_state_fifo <= DATA_DONE;
            DATA_DONE: begin
                if(fs_fifo == 1'b0) begin
                    next_state_fifo <= MAIN_IDLE;
                end
                else begin
                    next_state_fifo <= DATA_DONE;
                end
            end
        endcase
    end

    always @(posedge clk or posedge rst) begin // head_data
        if(rst) begin
            head_data <= 8'h00;
        end
        else if(state_fifo == HEAD01) begin
            head_data <= 8'h55;
        end
        else if(state_fifo == DEVOPT) begin
            head_data <= 8'hAA;
        end
        else if(state_fifo == DEVSPR) begin
            head_data <= dev_info;
        end
        else if(state_fifo == DEVTYE) begin
            head_data <= dev_smpr;
        end
        else if(state_fifo == DATA_START) begin
            head_data <= dev_kind;
        end
        else if((state_fifo == DATA_DONE) || (state_fifo == MAIN_IDLE)) begin
            head_data <= 8'h00;
        end
        else if(state_fifo == DAT00H && (fifo_num==8'h07)) begin
            head_data <= 8'h00;
        end
        else begin
            head_data <= head_data + fifod_txd;
        end
    end
    
    always @(posedge clk or posedge rst) begin // fifod_txen
        if(rst) begin
            prev_fifod_txen <= 1'b0;
            fifod_txen <= 1'b0;
        end
        else if(state_fifo == HEAD00) begin
            prev_fifod_txen <= 1'b1;
            fifod_txen <= prev_fifod_txen;
        end
        else if(state_fifo == DATACK) begin
            prev_fifod_txen <= 1'b0;
            fifod_txen <= prev_fifod_txen;
        end
        else begin
            prev_fifod_txen <= prev_fifod_txen;
            fifod_txen <= prev_fifod_txen;
        end
    end

    always @(posedge clk or posedge rst) begin // fifo_num
        if(rst) begin
            fifo_num <= 8'h08;
        end
        else if(state_fifo == DEVSPR) begin
            fifo_num <= 8'h07;
        end
        else if(state_fifo == DATACK || (state_fifo == DATA_DONE)) begin
            fifo_num <= 8'h08;
        end
        else if(state_fifo == DAT30L && (~flag_end)) begin
            fifo_num <= fifo_num - 8'h01;
        end
        else if(state_fifo == DAT14L && (~flag_end) && ~flag_lort) begin
            fifo_num <= fifo_num - 8'h01;
        end
        else begin
            fifo_num <= fifo_num;
        end
    end

    always @(posedge clk or posedge rst) begin // data_long_or_short
        if(rst) begin
            flag_lort <= 1'b0;
            flag_end <= 1'b0;
            flag_cmd <= 7'h0;
            nflag_cmd <= 7'h0;
            flag_ind <= 7'h0;
        end
        else if(state_fifo == DAT00L) begin
            flag_lort <= cache_fifo_lor[fifo_num];
            flag_end <= cache_fifo_end[fifo_num];
            flag_cmd <= cache_fifo_cmd[fifo_num];
            nflag_cmd <= cache_fifo_cmd[fifo_num-1'b1];
            flag_ind <= cache_fifo_ind[fifo_num];
        end
        else begin
            flag_lort <= flag_lort;
            flag_end <= flag_end;
            flag_cmd <= flag_cmd;
            nflag_cmd <= nflag_cmd;
            flag_ind <= flag_ind;
        end
    end

    always @(posedge clk or posedge rst) begin // fifo_ind
        if(rst) begin
            pprev_fifo_ind <= 8'h00;
            prev_fifo_ind <= 8'h00;
            fifo_ind <= 8'h00;
        end
        else begin
            pprev_fifo_ind <= cache_fifo_ind[fifo_num];
            prev_fifo_ind <= pprev_fifo_ind;
            fifo_ind <= prev_fifo_ind;
        end
    end

    always @(posedge clk or posedge rst) begin // flag_hord
        if(rst) begin
            flag_hord <= 1'b0;
        end
        else if(state_fifo == HEAD01 || (state_fifo == DATACK)) begin
            flag_hord <= 1'b1;
        end
        else if(state_fifo == DAT00H || (state_fifo == DATA_DONE)) begin
            flag_hord <= 1'b0;
        end
        else begin
            flag_hord <= flag_hord;
        end
    end

    always @(posedge clk or posedge rst) begin // option
        if(rst) begin
            cache_fifo_cmd[8] <= 8'h00;
            cache_fifo_cmd[7] <= 8'h00;
            cache_fifo_cmd[6] <= 8'h00;
            cache_fifo_cmd[5] <= 8'h00;
            cache_fifo_cmd[4] <= 8'h00;
            cache_fifo_cmd[3] <= 8'h00;
            cache_fifo_cmd[2] <= 8'h00;
            cache_fifo_cmd[1] <= 8'h00;
            cache_fifo_cmd[0] <= 8'h00;
            cache_fifo_ind[8] <= 8'h00;
            cache_fifo_ind[7] <= 8'h00;
            cache_fifo_ind[6] <= 8'h00;
            cache_fifo_ind[5] <= 8'h00;
            cache_fifo_ind[4] <= 8'h00;
            cache_fifo_ind[3] <= 8'h00;
            cache_fifo_ind[2] <= 8'h00;
            cache_fifo_ind[1] <= 8'h00;
            cache_fifo_ind[0] <= 8'h00;
            cache_fifo_lor <= 8'h00;
            cache_fifo_end <= 8'h00;
            fifo_num_opt <= 8'h07;
            data_len <= 10'h0;
        end
        case(state_opt) 
            IDLE_OPTION: begin
                cache_fifo_cmd[8] <= 8'h00;
                cache_fifo_cmd[7] <= 8'h00;
                cache_fifo_cmd[6] <= 8'h00;
                cache_fifo_cmd[5] <= 8'h00;
                cache_fifo_cmd[4] <= 8'h00;
                cache_fifo_cmd[3] <= 8'h00;
                cache_fifo_cmd[2] <= 8'h00;
                cache_fifo_cmd[1] <= 8'h00;
                cache_fifo_cmd[0] <= 8'h00;
                cache_fifo_ind[8] <= 8'h00;
                cache_fifo_ind[7] <= 8'h00;
                cache_fifo_ind[6] <= 8'h00;
                cache_fifo_ind[5] <= 8'h00;
                cache_fifo_ind[4] <= 8'h00;
                cache_fifo_ind[3] <= 8'h00;
                cache_fifo_ind[2] <= 8'h00;
                cache_fifo_ind[1] <= 8'h00;
                cache_fifo_ind[0] <= 8'h00;
                cache_fifo_lor <= 8'h00;
                cache_fifo_end <= 8'h00;
                fifo_num_opt <= 8'h07;
                data_len <= 10'h0;
            end
            OPTION0: begin
                case(dev_kind[7:6])
                    2'b00: begin
                        cache_fifo_cmd[fifo_num_opt] <= 8'h00;
                        cache_fifo_ind[fifo_num_opt] <= 8'h00;
                        cache_fifo_lor[fifo_num_opt] <= 1'b0;
                        cache_fifo_end[fifo_num_opt] <= 1'b0;
                        data_len <= data_len;
                    end
                    2'b01: begin
                        cache_fifo_cmd[fifo_num_opt] <= 8'h80;
                        cache_fifo_ind[fifo_num_opt] <= 8'h3F;
                        cache_fifo_lor[fifo_num_opt] <= 1'b0;
                        fifo_num_opt <= fifo_num_opt - 8'h1;
                        data_len <= data_len + 10'h20;
                    end
                    2'b10: begin
                        cache_fifo_cmd[fifo_num_opt] <= 8'h80;
                        cache_fifo_ind[fifo_num_opt] <= 8'h3F;
                        cache_fifo_lor[fifo_num_opt] <= 1'b1;
                        fifo_num_opt <= fifo_num_opt - 8'h1;
                        data_len <= data_len + 10'h40;
                    end
                    2'b11: begin
                        cache_fifo_cmd[fifo_num_opt] <= 8'h80;
                        cache_fifo_cmd[fifo_num_opt-1] <= 8'h40;
                        cache_fifo_ind[fifo_num_opt] <= 8'h3F;
                        cache_fifo_ind[fifo_num_opt-1] <= 8'h37;
                        cache_fifo_lor[fifo_num_opt -: 2] <= 2'b11;
                        fifo_num_opt <= fifo_num_opt - 8'h2;
                        data_len <= data_len + 10'h80;
                    end
                endcase
            end
            OPTION1: begin
                case(dev_kind[5:4])
                    2'b00: begin
                        cache_fifo_cmd[fifo_num_opt] <= 8'h00;
                        cache_fifo_ind[fifo_num_opt] <= 8'h00;
                        cache_fifo_lor[fifo_num_opt] <= 1'b0;
                        cache_fifo_end[fifo_num_opt] <= 1'b0;
                        data_len <= data_len;
                    end
                    2'b01: begin
                        cache_fifo_cmd[fifo_num_opt] <= 8'h20;
                        cache_fifo_ind[fifo_num_opt] <= 8'h2F;
                        cache_fifo_lor[fifo_num_opt] <= 1'b0;
                        fifo_num_opt <= fifo_num_opt - 8'h1;
                        data_len <= data_len + 10'h20;
                    end
                    2'b10: begin
                        cache_fifo_cmd[fifo_num_opt] <= 8'h20;
                        cache_fifo_ind[fifo_num_opt] <= 8'h2F;
                        cache_fifo_lor[fifo_num_opt] <= 1'b1;
                        fifo_num_opt <= fifo_num_opt - 8'h1;
                        data_len <= data_len + 10'h40;
                    end
                    2'b11: begin
                        cache_fifo_cmd[fifo_num_opt] <= 8'h20;
                        cache_fifo_cmd[fifo_num_opt-1] <= 8'h10;
                        cache_fifo_ind[fifo_num_opt] <= 8'h2F;
                        cache_fifo_ind[fifo_num_opt-1] <= 8'h27;
                        cache_fifo_lor[fifo_num_opt -: 2] <= 2'b11;
                        fifo_num_opt <= fifo_num_opt - 8'h2;
                        data_len <= data_len + 10'h80;
                    end
                endcase
            end
            OPTION2: begin
                case(dev_kind[3:2])
                    2'b00: begin
                        cache_fifo_cmd[fifo_num_opt] <= 8'h00;
                        cache_fifo_ind[fifo_num_opt] <= 8'h00;
                        cache_fifo_lor[fifo_num_opt] <= 1'b0;
                        cache_fifo_end[fifo_num_opt] <= 1'b0;
                        data_len <= data_len;
                    end
                    2'b01: begin
                        cache_fifo_cmd[fifo_num_opt] <= 8'h08;
                        cache_fifo_ind[fifo_num_opt] <= 8'h1F;
                        cache_fifo_lor[fifo_num_opt] <= 1'b0;
                        fifo_num_opt <= fifo_num_opt - 8'h1;
                        data_len <= data_len + 10'h20;
                    end
                    2'b10: begin
                        cache_fifo_cmd[fifo_num_opt] <= 8'h08;
                        cache_fifo_ind[fifo_num_opt] <= 8'h1F;
                        cache_fifo_lor[fifo_num_opt] <= 1'b1;
                        fifo_num_opt <= fifo_num_opt - 8'h1;
                        data_len <= data_len + 10'h40;
                    end
                    2'b11: begin
                        cache_fifo_cmd[fifo_num_opt] <= 8'h08;
                        cache_fifo_cmd[fifo_num_opt-1] <= 8'h04;
                        cache_fifo_ind[fifo_num_opt] <= 8'h1F;
                        cache_fifo_ind[fifo_num_opt-1] <= 8'h17;
                        cache_fifo_lor[fifo_num_opt -: 2] <= 2'b11;
                        fifo_num_opt <= fifo_num_opt - 8'h2;
                        data_len <= data_len + 10'h80;
                    end
                endcase
            end
            OPTION3: begin
                case(dev_kind[1:0])
                    2'b00: begin
                        cache_fifo_cmd[fifo_num_opt] <= 8'h00;
                        cache_fifo_ind[fifo_num_opt] <= 8'h00;
                        cache_fifo_lor[fifo_num_opt] <= 1'b0;
                        fifo_num_opt <= fifo_num_opt + 1'b1;
                        data_len <= data_len;
                    end
                    2'b01: begin
                        cache_fifo_cmd[fifo_num_opt] <= 8'h02;
                        cache_fifo_ind[fifo_num_opt] <= 8'h0F;
                        cache_fifo_lor[fifo_num_opt] <= 1'b0;
                        fifo_num_opt <= fifo_num_opt;
                        data_len <= data_len + 10'h20;
                    end
                    2'b10: begin
                        cache_fifo_cmd[fifo_num_opt] <= 8'h02;
                        cache_fifo_ind[fifo_num_opt] <= 8'h0F;
                        cache_fifo_lor[fifo_num_opt] <= 1'b1;
                        fifo_num_opt <= fifo_num_opt;
                        data_len <= data_len + 10'h40;
                    end
                    2'b11: begin
                        cache_fifo_cmd[fifo_num_opt] <= 8'h02;
                        cache_fifo_cmd[fifo_num_opt-1] <= 8'h01;
                        cache_fifo_ind[fifo_num_opt] <= 8'h0F;
                        cache_fifo_ind[fifo_num_opt-1] <= 8'h07;
                        cache_fifo_lor[fifo_num_opt -: 2] <= 2'b11;
                        fifo_num_opt <= fifo_num_opt - 8'h1;
                        data_len <= data_len + 10'h80;
                    end
                endcase
            end
            OPTION_END: begin
                data_len <= data_len + 10'h6;
                cache_fifo_num <= fifo_num_opt;
                cache_fifo_end[fifo_num_opt] <= 1'b1;
                fifo_num_opt <= 8'h07;
            end
        endcase
    end
    // #endregion
    // #endregion

    // ## 4. IP SECTION
    // #region
    // #endregion
endmodule