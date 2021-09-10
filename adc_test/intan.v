module intan(
    input clk,
    input rst,

    input spi_mc, 
    input miso,
    output cs,
    output mosi,
    output sclk,

    output reg [1:0] dev_kind,

    input fs_check,
    output fd_check
);

    localparam ANS_REG40 = 8'h49;
    localparam ANS_REG41 = 8'h4E;
    localparam ANS_REG42 = 8'h54;
    localparam ANS_REG43 = 8'h41;
    localparam ANS_REG44 = 8'h4E;

    localparam CMD_CONCERT0 = 16'h0000;
    localparam CMD_CONCERTN = 16'h3F00;
    localparam CMD_CALIBRATE = 16'h5500;
    localparam CMD_CKEAR = 16'h6A00;
    localparam CMD_WRITE = 2'b10;
    localparam CMD_READ = 2'b11;

    localparam RET_WRITE = 8'hFF;
    localparam RET_READ = 8'h00;

    localparam REG00 = 6'h00, REG01 = 6'h01, REG02 = 6'h02, REG03 = 6'h03;
    localparam REG04 = 6'h04, REG05 = 6'h05, REG06 = 6'h06, REG07 = 6'h07;
    localparam REG08 = 6'h08, REG09 = 6'h09, REG10 = 6'h0A, REG11 = 6'h0B;
    localparam REG12 = 6'h0C, REG13 = 6'h0D, REG14 = 6'h0E, REG15 = 6'h0F;
    localparam REG16 = 6'h10, REG17 = 6'h11, REG18 = 6'h12, REG19 = 6'h13;
    localparam REG20 = 6'h14, REG21 = 6'h15, REG40 = 6'h28, REG41 = 6'h29;
    localparam REG42 = 6'h2A, REG43 = 6'h2B, REG44 = 6'h2C, REG59 = 6'h3B;
    localparam REG60 = 6'h3C, REG61 = 6'h3D, REG62 = 6'h3E, REG63 = 6'h3F;

    localparam MAIN_IDLE = 8'h00, MAIN_DEAD = 8'h01, DYG_CHECK = 8'h02, DYG_CONF = 8'h03;

    localparam IDLE_WAIT = 8'h06, IDLE_SKIP = 8'h07;
    localparam CHEK_WAIT = 8'h0A, CHEK_WORK = 8'h0B, CHEK_JUDGE = 8'h0C, CHEK_SKIP = 8'h0D;
    localparam KIND_WAIT = 8'h0E, KIND_WORK = 8'h0F, KIND_JUDGE = 8'h10, KIND_SKIP = 8'h11;

    localparam IDLE_CHECK = 8'h20;
    localparam CHECK_CREG40 = 8'h21, CHECK_CREG41 = 8'h22, CHECK_CREG42 = 8'h23;
    localparam CHECK_CREG43 = 8'h24, CHECK_CREG44 = 8'h25, CHECK_CHIPID = 8'h26;
    localparam CHECK_NUMAMP = 8'h27, RDREG_CHIPID = 8'h28, RDREG_NUMAMP = 8'h29;
    localparam CHECK_DRDREG = 8'h2A, CHECK_DOWAIT = 8'h2B, CHECK_DCHECK = 8'h2C;
    localparam CHECK_LAST = 8'h2D, CHECK_JUDGE = 8'h2E, CHECK_DONE = 8'h2F;


    (* MARK_DEBUG="true" *)reg [7:0] state; 
    reg [7:0] next_state;
    reg [7:0] state_goto, state_back;

    reg [1:0] dev_kind0, dev_kind1;

    (* MARK_DEBUG="true" *)reg [15:0] chip_txd; 
    (* MARK_DEBUG="true" *)wire [15:0] chip_rd0; 
    wire [15:0] chip_rd1;
    reg [15:0] data_check;

    wire fs_prd;
    wire fd_spi, fd_prd;

    reg judge_dev_kind_equal;
    reg judge_dev_kind_right;
    reg judge_check_data_equal;


    assign fd_check = (state == CHECK_DONE);
    assign fs_prd = (state == IDLE_WAIT) || (state == CHEK_WAIT) || (state == KIND_WAIT);

    always @(posedge clk or posedge rst) begin
        if(rst) state <= MAIN_IDLE;
        else state <= next_state;
    end


    always @(*) begin
        case(state)
            MAIN_IDLE: begin
                if(fs_check) next_state <= IDLE_CHECK;
                else next_state <= MAIN_IDLE;
            end

            DYG_CHECK:begin
                next_state <= CHECK_CREG40;
            end

            IDLE_WAIT: begin
                if(fd_spi) next_state <= IDLE_SKIP;
                else next_state <= IDLE_WAIT;
            end
            IDLE_SKIP: begin
                if(fd_prd) next_state <= state_goto;
                else next_state <= IDLE_SKIP;
            end

            CHEK_WAIT: begin
                if(fd_spi) next_state <= CHEK_WORK;
                else next_state <= CHEK_WAIT;
            end
            CHEK_WORK: begin
                next_state <= CHEK_JUDGE;
            end
            CHEK_JUDGE: begin
                if(fd_prd) next_state <= CHEK_SKIP;
                else next_state <= CHEK_JUDGE;
            end
            CHEK_SKIP: begin
                if(judge_check_data_equal) next_state <= state_goto;
                else next_state <= state_back;
            end

            KIND_WAIT: begin
                if(fd_spi) next_state <= KIND_WORK;
                else next_state <= KIND_WAIT;
            end
            KIND_WORK: begin
                next_state <= KIND_JUDGE;
            end
            KIND_JUDGE: begin
                if(fd_prd) next_state <= KIND_SKIP;
                else next_state <= KIND_JUDGE; 
            end
            KIND_SKIP: begin
                if(judge_dev_kind_right) next_state <= state_goto;
                else next_state <= state_back;
            end
            
            IDLE_CHECK: next_state <= CHECK_CREG40;
            CHECK_CREG40: next_state <= IDLE_WAIT;
            CHECK_CREG41: next_state <= IDLE_WAIT;
            CHECK_CREG42: next_state <= CHEK_WAIT;
            CHECK_CREG43: next_state <= CHEK_WAIT;
            CHECK_CREG44: next_state <= CHEK_WAIT;
            CHECK_CHIPID: next_state <= CHEK_WAIT;
            CHECK_NUMAMP: next_state <= CHEK_WAIT;
            RDREG_CHIPID: next_state <= KIND_WAIT;
            RDREG_NUMAMP: next_state <= KIND_WAIT;
            CHECK_LAST: next_state <= CHECK_JUDGE;
            CHECK_JUDGE: begin
                if(judge_dev_kind_equal) next_state <= CHECK_DONE;
                else next_state <= DYG_CHECK; 
            end
            CHECK_DONE: begin
                if(~fs_check) next_state <= MAIN_IDLE;
                else next_state <= CHECK_DONE;
            end

            CHECK_DRDREG: next_state <= CHECK_CREG40;

            default: next_state <= MAIN_IDLE;
        endcase
    end


    always @(posedge clk or posedge rst) begin
        if(rst) begin
            state_goto <= MAIN_IDLE;
            state_back <= MAIN_IDLE;
            data_check <= 16'h0000;
            chip_txd <= 16'h0000;
        end
        else if(state == CHECK_CREG40) begin
            state_goto <= CHECK_CREG41;
            state_back <= MAIN_IDLE;
            data_check <= 16'h0000;
            chip_txd <= {CMD_READ, REG40, RET_READ};
        end
        else if(state == CHECK_CREG41) begin
            state_goto <= CHECK_CREG42;
            state_back <= MAIN_IDLE;
            data_check <= 16'h0000;
            chip_txd <= {CMD_READ, REG41, RET_READ};
        end  
        else if(state == CHECK_CREG42) begin
            state_goto <= CHECK_CREG43;
            state_back <= CHECK_DRDREG;
            data_check <= {RET_READ, ANS_REG40};
            chip_txd <= {CMD_READ, REG42, RET_READ};
        end
        else if(state == CHECK_CREG43) begin
            state_goto <= CHECK_CREG44;
            state_back <= CHECK_DRDREG;
            data_check <= {RET_READ, ANS_REG41};
            chip_txd <= {CMD_READ, REG43, RET_READ};
        end
        else if(state == CHECK_CREG44) begin
            state_goto <= CHECK_CHIPID;
            state_back <= CHECK_DRDREG;
            data_check <= {RET_READ, ANS_REG42};
            chip_txd <= {CMD_READ, REG44, RET_READ};
        end
        else if(state == CHECK_CHIPID) begin
            state_goto <= CHECK_NUMAMP;
            state_back <= CHECK_DRDREG;
            data_check <= {RET_READ, ANS_REG43};
            chip_txd <= {CMD_READ, REG62, RET_READ};
        end
        else if(state == CHECK_NUMAMP) begin
            state_goto <= RDREG_CHIPID;
            state_back <= CHECK_DRDREG;
            data_check <= {RET_READ, ANS_REG44};
            chip_txd <= {CMD_READ, REG63, RET_READ};
        end
        else if(state == RDREG_CHIPID) begin
            state_goto <= RDREG_NUMAMP;
            state_back <= CHECK_DRDREG;
            data_check <= 16'h0000;
            chip_txd <= {CMD_READ, REG40, RET_READ};
        end
        else if(state == RDREG_NUMAMP) begin
            state_goto <= CHECK_LAST;
            state_back <= CHECK_DRDREG;
            data_check <= 16'h0000;
            chip_txd <= {CMD_READ, REG40, RET_READ};
        end
        else begin
            state_goto <= state_goto;
            state_back <= state_back;
            data_check <= data_check;
            chip_txd <= chip_txd;
        end
    end

// dev_kind0, dev_kind1, judge_dev_kind_right
// #region 
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            dev_kind0 <= 2'b00;
            dev_kind1 <= 2'b00;
            judge_dev_kind_right <= 1'b0;
        end
        else if(state == MAIN_IDLE) begin
            dev_kind0 <= 2'b00;
            dev_kind1 <= 2'b00;
            judge_dev_kind_right <= 1'b0;
        end
        else if(state == KIND_JUDGE && chip_rd0[7:0] == 8'h01) begin
            dev_kind0 <= 2'b10;
            dev_kind1 <= dev_kind1;
            judge_dev_kind_right <= 1'b1;
        end
        else if(state == KIND_JUDGE && chip_rd0[7:0] == 8'h02) begin
            dev_kind0 <= 2'b01;
            dev_kind1 <= dev_kind1;
            judge_dev_kind_right <= 1'b1;
        end
        else if(state == KIND_JUDGE && chip_rd0[7:0] == 8'h04) begin
            dev_kind0 <= 2'b11;
            dev_kind1 <= dev_kind1;
            judge_dev_kind_right <= 1'b1;
        end
        else if(state == KIND_JUDGE && chip_rd0[7:0] == 8'h10) begin
            dev_kind0 <= dev_kind0;
            dev_kind1 <= 2'b01;
            judge_dev_kind_right <= 1'b1;
        end
        else if(state == KIND_JUDGE && chip_rd0[7:0] == 8'h20) begin
            dev_kind0 <= dev_kind0;
            dev_kind1 <= 2'b10;
            judge_dev_kind_right <= 1'b1;
        end
        else if(state == KIND_JUDGE && chip_rd0[7:0] == 8'h40) begin
            dev_kind0 <= dev_kind0;
            dev_kind1 <= 2'b11;
            judge_dev_kind_right <= 1'b1;
        end
        else begin
            dev_kind0 <= dev_kind0;
            dev_kind1 <= dev_kind1;
            judge_dev_kind_right <= 1'b0;
        end
    end
// #endregion

// dev_kind judge_dev_kind_equal
// #region

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            dev_kind <= 2'b00;
            judge_dev_kind_equal <= 1'b0;
        end
        else if(state == CHECK_LAST && dev_kind0 == dev_kind1) begin
            dev_kind <= dev_kind0;
            judge_dev_kind_equal <= 1'b1;
        end
        else if(state == CHECK_LAST && dev_kind0 != dev_kind1) begin
            dev_kind <= 2'b00;
            judge_dev_kind_equal <= 1'b0;
        end
        else begin
            dev_kind <= dev_kind;
            judge_dev_kind_equal <= judge_dev_kind_equal;
        end
    end

// #endregion

// judge_check_data_equal
// #region

    always @(posedge clk or posedge rst) begin
        if(rst) judge_check_data_equal <= 1'b0;
        else if(state == CHEK_JUDGE && chip_rd0 == data_check) judge_check_data_equal <= 1'b1;
        else if(state == CHEK_JUDGE && chip_rd0 != data_check) judge_check_data_equal <= 1'b0;
        else judge_check_data_equal <= judge_check_data_equal; 
    end

// #endregion

    spi
    spi_dut(
        .clk(spi_mc),
        .rst(rst),

        .fs(fs_prd),
        .fd_spi(fd_spi),
        .fd_prd(fd_prd),

        .miso(miso),
        .mosi(mosi),
        .cs(cs),
        .sclk(sclk),

        .chip_txd(chip_txd),
        .chip_rxd0(chip_rd0),
        .chip_rxd1(chip_rd1)
    );




endmodule