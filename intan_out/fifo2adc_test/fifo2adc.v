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
// * fifoi_grxen 
// * adc_rxen 
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
    input fs_fifo,
    output fd_fifo,

    output reg adc_rxen, // fifod 的参考写入
    output  [7:0] fifoi_grxen, //intan_fifo的读入控制部分
    // ###### DATA PART

    // #### DATA_SECTION
    input [7:0] dev_kind, // 输入的需对照的各下级设备参数
    input [7:0] dev_info, // 前4位为当前设备编号，后4位为当前数据编号
    input [7:0] dev_smpr,

    input [63:0] fifoi_grxd,
    output [7:0] adc_rxd,

    input [63:0] intan_cmd,
    input [63:0] intan_ind,
    input [7:0] intan_lor,
    input [7:0] intan_end,
    output [7:0] sos,
    output [7:0] sos0,
    output [63:0] sol
    
    // #endregion
);
    
    // ## 2. VARIABLE SECTION
    // #regiond
    // #### 1. REGISTER PART
    // #region
    // ###### OPTION
    // ###### LINK
    reg [7:0] state, next_state;
    wire [7:0] fifoi_gcmd[8:0]; // 记录当前的与INTAN部分FIFO的 0x80 // FIFO_RD_EN
    wire [8:0] fifoi_glor; // 记录当前FIFO读取是否为32通道
    wire [8:0] fifoi_gend; // 记录当前是否为读取的最后一个FIFO
    wire [7:0] fifoi_gind[8:0]; // 0x3F // FIFO_IND
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
    reg prev_adc_rxen;

    // TEST
    assign sos = fifoi_grxen;
    assign sol = intan_cmd;
    assign sos0 = fifo_ind;
    // #endregion

    // #### 2. WIRE PART
    // #region

    // #endregion

    assign fifoi_gcmd[8] = 8'h00;
    assign fifoi_gcmd[7] = intan_cmd[63:56];
    assign fifoi_gcmd[6] = intan_cmd[55:48];
    assign fifoi_gcmd[5] = intan_cmd[47:40];
    assign fifoi_gcmd[4] = intan_cmd[39:32];
    assign fifoi_gcmd[3] = intan_cmd[31:24];
    assign fifoi_gcmd[2] = intan_cmd[23:16];
    assign fifoi_gcmd[1] = intan_cmd[15:8];
    assign fifoi_gcmd[0] = intan_cmd[7:0];

    assign fifoi_gind[8] = 8'h00;
    assign fifoi_gind[7] = intan_ind[63:56];
    assign fifoi_gind[6] = intan_ind[55:48];
    assign fifoi_gind[5] = intan_ind[47:40];
    assign fifoi_gind[4] = intan_ind[39:32];
    assign fifoi_gind[3] = intan_ind[31:24];
    assign fifoi_gind[2] = intan_ind[23:16];
    assign fifoi_gind[1] = intan_ind[15:8];
    assign fifoi_gind[0] = intan_ind[7:0];

    assign fifoi_glor = intan_lor;
    assign fifoi_gend = intan_end;

    // #### 3. PARAMETER PART
    // #region
    // ###### STATE MACHINE PAGE
    // MAIN
    localparam MAIN_IDLE = 8'h00;
    // OPTION


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
    assign adc_rxd = (flag_hord==1'b1) ?head_data :fifoi_grxd[fifo_ind -: 8];
    assign fifoi_grxen = 8'h00;
    assign fd_fifo = (state == DATA_DONE);

    // #endregion

    // #### 2. SEQUENTIAL LOGIC PART
    // #region
    always @(posedge clk or posedge rst) begin // STATE
        if(rst) begin
            state <= MAIN_IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    
    // always @(posedge clk or posedge rst) begin // fifoi_grxen
    //     if(rst) begin
    //         fifoi_grxen <= 8'h00;
    //     end
    //     else if(state == DAT31H && (~flag_end)) begin
    //         fifoi_grxen <= flag_cmd | nflag_cmd;
    //     end
    //     else if(state == DAT31H && (flag_end)) begin
    //         fifoi_grxen <= flag_cmd;
    //     end
    //     else if(state == DAT15L &&(~flag_end) && (~flag_lort)) begin
    //         fifoi_grxen <= flag_cmd | nflag_cmd;
    //     end
    //     else if(state == DAT15H &&(flag_end) && (~flag_lort)) begin
    //         fifoi_grxen <= flag_cmd;
    //     end 
    //     else if(state == DAT15L &&(flag_end) && (~flag_lort)) begin
    //         fifoi_grxen <= 8'h00;
    //     end
    //     else if(state == DAT31L && (flag_end)) begin
    //         fifoi_grxen <= 8'h00;
    //     end       
    //     else if(state == DATACK) begin
    //         fifoi_grxen <= 8'h00;
    //     end
    //     else begin
    //         fifoi_grxen <= flag_cmd;
    //     end

    // end
    
    always@(*) begin // STATE_READ
        case(state)
            MAIN_IDLE: begin
                if(fs_fifo)begin
                    next_state <= IDLE_READ;
                end
                else begin
                    next_state <= MAIN_IDLE;
                end
            end
            IDLE_READ: next_state <= HEAD00;
            HEAD00: next_state <= HEAD01;
            HEAD01: next_state <= DEVOPT;
            DEVOPT: next_state <= DEVSPR;
            DEVSPR: next_state <= DEVTYE;
            DEVTYE: next_state <= DATA_START;
            DATA_START: next_state <= DAT00H;
            DAT00H: next_state <= DAT00L;
            DAT00L: next_state <= DAT01H;
            DAT01H: next_state <= DAT01L;
            DAT01L: next_state <= DAT02H;
            DAT02H: next_state <= DAT02L;
            DAT02L: next_state <= DAT03H;
            DAT03H: next_state <= DAT03L;
            DAT03L: next_state <= DAT04H;
            DAT04H: next_state <= DAT04L;
            DAT04L: next_state <= DAT05H;
            DAT05H: next_state <= DAT05L;
            DAT05L: next_state <= DAT06H;
            DAT06H: next_state <= DAT06L;
            DAT06L: next_state <= DAT07H;
            DAT07H: next_state <= DAT07L;
            DAT07L: next_state <= DAT08H;
            DAT08H: next_state <= DAT08L;
            DAT08L: next_state <= DAT09H;
            DAT09H: next_state <= DAT09L;
            DAT09L: next_state <= DAT10H;
            DAT10H: next_state <= DAT10L;
            DAT10L: next_state <= DAT11H;
            DAT11H: next_state <= DAT11L;
            DAT11L: next_state <= DAT12H;
            DAT12H: next_state <= DAT12L;
            DAT12L: next_state <= DAT13H;
            DAT13H: next_state <= DAT13L;
            DAT13L: next_state <= DAT14H;
            DAT14H: next_state <= DAT14L;
            DAT14L: next_state <= DAT15H;
            DAT15H: next_state <= DAT15L;
            DAT15L: begin
                if(flag_lort) next_state <= DAT16H;
                else if(flag_end) next_state <= DATACK;
                else next_state <= DAT00H;
            end
            DAT16H: next_state <= DAT16L;
            DAT16L: next_state <= DAT17H;
            DAT17H: next_state <= DAT17L;
            DAT17L: next_state <= DAT18H;
            DAT18H: next_state <= DAT18L;
            DAT18L: next_state <= DAT19H;
            DAT19H: next_state <= DAT19L;
            DAT19L: next_state <= DAT20H;
            DAT20H: next_state <= DAT20L;
            DAT20L: next_state <= DAT21H;
            DAT21H: next_state <= DAT21L;
            DAT21L: next_state <= DAT22H;
            DAT22H: next_state <= DAT22L;
            DAT22L: next_state <= DAT23H;
            DAT23H: next_state <= DAT23L;
            DAT23L: next_state <= DAT24H;
            DAT24H: next_state <= DAT24L;
            DAT24L: next_state <= DAT25H;
            DAT25H: next_state <= DAT25L;
            DAT25L: next_state <= DAT26H;
            DAT26H: next_state <= DAT26L;
            DAT26L: next_state <= DAT27H;
            DAT27H: next_state <= DAT27L;
            DAT27L: next_state <= DAT28H;
            DAT28H: next_state <= DAT28L;
            DAT28L: next_state <= DAT29H;
            DAT29H: next_state <= DAT29L;
            DAT29L: next_state <= DAT30H;
            DAT30H: next_state <= DAT30L;
            DAT30L: next_state <= DAT31H;
            DAT31H: next_state <= DAT31L;
            DAT31L: begin
                if(flag_end) begin
                    next_state <= DATACK;
                end
                else begin
                    next_state <= DAT00H;
                end
            end
            DATACK: next_state <= DATA_DONE;
            DATA_DONE: begin
                if(fs_fifo == 1'b0) begin
                    next_state <= MAIN_IDLE;
                end
                else begin
                    next_state <= DATA_DONE;
                end
            end
            default: next_state <= MAIN_IDLE;
        endcase
    end

    always @(posedge clk or posedge rst) begin // head_data
        if(rst) begin
            head_data <= 8'h00;
        end
        else if(state == HEAD01) begin
            head_data <= 8'h55;
        end
        else if(state == DEVOPT) begin
            head_data <= 8'hAA;
        end
        else if(state == DEVSPR) begin
            head_data <= dev_info;
        end
        else if(state == DEVTYE) begin
            head_data <= dev_smpr;
        end
        else if(state == DATA_START) begin
            head_data <= dev_kind;
        end
        else if((state == DATA_DONE) || (state == MAIN_IDLE)) begin
            head_data <= 8'h00;
        end
        else if(state == DAT00H && (fifo_num==8'h07)) begin
            head_data <= 8'h00;
        end
        else begin
            head_data <= head_data + adc_rxd;
        end
    end
    
    always @(posedge clk or posedge rst) begin // adc_rxen
        if(rst) begin
            prev_adc_rxen <= 1'b0;
            adc_rxen <= 1'b0;
        end
        else if(state == HEAD00) begin
            prev_adc_rxen <= 1'b1;
            adc_rxen <= prev_adc_rxen;
        end
        else if(state == DATACK) begin
            prev_adc_rxen <= 1'b0;
            adc_rxen <= prev_adc_rxen;
        end
        else begin
            prev_adc_rxen <= prev_adc_rxen;
            adc_rxen <= prev_adc_rxen;
        end
    end

    always @(posedge clk or posedge rst) begin // fifo_num
        if(rst) begin
            fifo_num <= 8'h08;
        end
        else if(state == DEVTYE) begin
            fifo_num <= 8'h07;
        end
        else if(state == DATACK || (state == DATA_DONE)) begin
            fifo_num <= 8'h08;
        end
        else if(state == DAT30L && (~flag_end)) begin
            fifo_num <= fifo_num - 8'h01;
        end
        else if(state == DAT14L && (~flag_end) && ~flag_lort) begin
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
        end
        else if(state == DAT00L) begin
            flag_lort <= fifoi_glor[fifo_num];
            flag_end <= fifoi_gend[fifo_num];
            flag_cmd <= fifoi_gcmd[fifo_num];
            nflag_cmd <= fifoi_gcmd[fifo_num-1'b1];
        end
        else begin
            flag_lort <= flag_lort;
            flag_end <= flag_end;
            flag_cmd <= flag_cmd;
            nflag_cmd <= nflag_cmd;
        end
    end

    always @(posedge clk or posedge rst) begin // fifo_ind
        if(rst) begin
            prev_fifo_ind <= 8'h00;
            fifo_ind <= 8'h00;
        end
        else begin
            prev_fifo_ind <= fifoi_gind[fifo_num];
            fifo_ind <= prev_fifo_ind;
        end
    end

    always @(posedge clk or posedge rst) begin // flag_hord
        if(rst) begin
            flag_hord <= 1'b0;
        end
        else if(state == HEAD01 || (state == DATACK)) begin
            flag_hord <= 1'b1;
        end
        else if(state == DAT00H || (state == DATA_DONE)) begin
            flag_hord <= 1'b0;
        end
        else begin
            flag_hord <= flag_hord;
        end
    end

    // #endregion
    // #endregion

    // ## 4. IP SECTION
    // #region
    // #endregion
endmodule