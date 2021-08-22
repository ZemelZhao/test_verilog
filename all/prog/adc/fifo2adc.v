module fifo2adc(
    input clk, // a clock
    input rst,
    output err,

    input fs_fifo,
    output fd_fifo,

    output reg adc_rxen,
    output [7:0] fifoi_grxen,

    input [7:0] dev_kind,
    input [7:0] dev_info,
    input [7:0] dev_smpr,

    input [63:0] fifoi_grxd,
    output [7:0] adc_rxd,

    input [63:0] intan_cmd,
    input [63:0] intan_ind,
    input [7:0] intan_lrt,
    input [7:0] intan_end

);

    localparam IDLE = 8'h00;
    localparam HD00 = 8'h10, HD01 = 8'h11, DIFO = 8'h12;
    localparam DSPR = 8'h13, DTYE = 8'h14, DBGN = 8'h15;
    localparam D00H = 8'h40, D00L = 8'h41, D01H = 8'h42, D01L = 8'h43;
    localparam D02H = 8'h44, D02L = 8'h45, D03H = 8'h46, D03L = 8'h47;
    localparam D04H = 8'h48, D04L = 8'h49, D05H = 8'h4A, D05L = 8'h4B;
    localparam D06H = 8'h4C, D06L = 8'h4D, D07H = 8'h4E, D07L = 8'h4F;
    localparam D08H = 8'h50, D08L = 8'h51, D09H = 8'h52, D09L = 8'h53;
    localparam D10H = 8'h54, D10L = 8'h55, D11H = 8'h56, D11L = 8'h57;
    localparam D12H = 8'h58, D12L = 8'h59, D13H = 8'h5A, D13L = 8'h5B;
    localparam D14H = 8'h5C, D14L = 8'h5D, D15H = 8'h5E, D15L = 8'h5F;
    localparam D16H = 8'h60, D16L = 8'h61, D17H = 8'h62, D17L = 8'h63;
    localparam D18H = 8'h64, D18L = 8'h65, D19H = 8'h66, D19L = 8'h67;
    localparam D20H = 8'h68, D20L = 8'h69, D21H = 8'h6A, D21L = 8'h6B;
    localparam D22H = 8'h6C, D22L = 8'h6D, D23H = 8'h6E, D23L = 8'h6F;
    localparam D24H = 8'h70, D24L = 8'h71, D25H = 8'h72, D25L = 8'h73;
    localparam D26H = 8'h74, D26L = 8'h75, D27H = 8'h76, D27L = 8'h77;
    localparam D28H = 8'h78, D28L = 8'h79, D29H = 8'h7A, D29L = 8'h7B;
    localparam D30H = 8'h7C, D30L = 8'h7D, D31H = 8'h7E, D31L = 8'h7F;
    localparam PART = 8'hA0, DONE = 8'hA1, LAST = 8'hA2;

    reg [7:0] state, next_state;
    wire [7:0] fifoi_gcmd[8:0];
    wire [7:0] fifoi_gind[8:0];
    wire [8:0] fifoi_glrt;
    wire [8:0] fifoi_gend;

    reg [7:0] hdat;

    reg flag_hrd, flag_lrt, flag_end;
    reg [7:0] flag_cmd, flag_ind, flag_num;

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

    assign fifoi_glrt = intan_lrt;
    assign fifoi_gend = intan_end;
    assign fd_fifo = (state == LAST);
    assign fifoi_grxen = flag_cmd;

    assign adc_rxd = (flag_hrd) ?hdat : fifoi_grxd[flag_ind -: 8];

    always @(posedge clk or posedge rst) begin
        if(rst) state <= IDLE;
        else state <= next_state;
    end

    always @(*) begin
        case(state)
            IDLE: begin
                if(fs_fifo) next_state <= HD00;
                else next_state <= IDLE;
            end
            HD00: next_state <= HD01;
            HD01: next_state <= DIFO;
            DIFO: next_state <= DSPR;
            DSPR: next_state <= DTYE;
            DTYE: next_state <= DBGN;
            DBGN: next_state <= D00L;
            D00H: next_state <= D00L;
            D00L: next_state <= D01H;
            D01H: next_state <= D01L;
            D01L: next_state <= D02H;
            D02H: next_state <= D02L;
            D02L: next_state <= D03H;
            D03H: next_state <= D03L;
            D03L: next_state <= D04H;
            D04H: next_state <= D04L;
            D04L: next_state <= D05H;
            D05H: next_state <= D05L;
            D05L: next_state <= D06H;
            D06H: next_state <= D06L;
            D06L: next_state <= D07H;
            D07H: next_state <= D07L;
            D07L: next_state <= D08H;
            D08H: next_state <= D08L;
            D08L: next_state <= D09H;
            D09H: next_state <= D09L;
            D09L: next_state <= D10H;
            D10H: next_state <= D10L;
            D10L: next_state <= D11H;
            D11H: next_state <= D11L;
            D11L: next_state <= D12H;
            D12H: next_state <= D12L;
            D12L: next_state <= D13H;
            D13H: next_state <= D13L;
            D13L: next_state <= D14H;
            D14H: next_state <= D14L;
            D14L: next_state <= D15H;
            D15H: next_state <= D15L;
            D15L: begin
                if(flag_lrt) next_state <= D16H;
                else if(flag_end) next_state <= PART;
                else next_state <= D00H;
            end
            D16H: next_state <= D16L;
            D16L: next_state <= D17H;
            D17H: next_state <= D17L;
            D17L: next_state <= D18H;
            D18H: next_state <= D18L;
            D18L: next_state <= D19H;
            D19H: next_state <= D19L;
            D19L: next_state <= D20H;
            D20H: next_state <= D20L;
            D20L: next_state <= D21H;
            D21H: next_state <= D21L;
            D21L: next_state <= D22H;
            D22H: next_state <= D22L;
            D22L: next_state <= D23H;
            D23H: next_state <= D23L;
            D23L: next_state <= D24H;
            D24H: next_state <= D24L;
            D24L: next_state <= D25H;
            D25H: next_state <= D25L;
            D25L: next_state <= D26H;
            D26H: next_state <= D26L;
            D26L: next_state <= D27H;
            D27H: next_state <= D27L;
            D27L: next_state <= D28H;
            D28H: next_state <= D28L;
            D28L: next_state <= D29H;
            D29H: next_state <= D29L;
            D29L: next_state <= D30H;
            D30H: next_state <= D30L;
            D30L: next_state <= D31H;
            D31H: next_state <= D31L;
            D31L: begin
                if(flag_end) next_state <= PART;
                else next_state <= D00H;
            end
            PART: next_state <= DONE;
            DONE: next_state <= LAST;
            LAST: begin
                if(~fs_fifo) next_state <= IDLE;
                else next_state <= LAST;
            end
            default: next_state <= IDLE;
        endcase
    end


    always @(posedge clk or posedge rst) begin // flag_hrd
        if(rst) flag_hrd <= 1'b0;
        else if(state == HD00) flag_hrd <= 1'b1;
        else if(state == DBGN) flag_hrd <= 1'b0;
        else if(state == PART) flag_hrd <= 1'b1;
        else if(state == DONE) flag_hrd <= 1'b0;
        else flag_hrd <= flag_hrd; 
    end

    always @(posedge clk or posedge rst) begin // flag_num
        if(rst) flag_num <= 8'h08;
        else if(state == IDLE) flag_num <= 8'h07;
        else if(state == DONE) flag_num <= 8'h08;
        else if(flag_end) flag_num <= flag_num;
        else if(state == D15L && (~flag_lrt)) flag_num <= flag_num - 1'b1;
        else if(state == D31L) flag_num <= flag_num - 1'b1;
        else flag_num <= flag_num;
    end

    always @(posedge clk or posedge rst) begin // adc_rxen
        if(rst) adc_rxen <= 1'b0;
        else if(state == HD00) adc_rxen <= 1'b1;
        else if(state == DONE) adc_rxen <= 1'b0;
        else adc_rxen <= adc_rxen;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) hdat <= 8'h00;
        else if(state == HD00) hdat <= 8'h55;
        else if(state == HD01) hdat <= 8'hAA;
        else if(state == DIFO) hdat <= dev_info;
        else if(state == DSPR) hdat <= dev_smpr;
        else if(state == DTYE) hdat <= dev_kind;
        else if(state == DBGN || state == LAST || state == DONE) hdat <= 8'h00;
        else hdat <= hdat + adc_rxd;
    end

    always @(posedge clk or posedge rst) begin 
        if(rst) begin
            flag_lrt <= 1'b0;
            flag_end <= 1'b0;
            flag_ind <= 8'h00;
            flag_cmd <= 8'h00;
        end
        else if(state == D00H || state == DBGN) begin
            flag_lrt <= fifoi_glrt[flag_num];
            flag_end <= fifoi_gend[flag_num];
            flag_ind <= fifoi_gind[flag_num];
            flag_cmd <= fifoi_gcmd[flag_num];
        end
        else if (state == DONE) begin
            flag_lrt <= 1'b0;
            flag_end <= 1'b0;
            flag_ind <= 8'h00;
            flag_cmd <= 8'h00;
        end
        else begin
            flag_lrt <= flag_lrt;
            flag_end <= flag_end;
            flag_ind <= flag_ind;
            flag_cmd <= flag_cmd;
        end
    end

endmodule