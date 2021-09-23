module intan(
    input clk,
    input rst,

    input spi_mc, 

    input miso,
    output cs,
    output mosi,
    output sclk,

    input pvdden,
    input tempen,
    
    input [7:0] reg00,
    input [7:0] reg01,
    input [7:0] reg02,
    input [7:0] reg03,
    input [7:0] reg04,
    input [7:0] reg05,
    input [7:0] reg06,
    input [7:0] reg07,
    input [7:0] reg08,
    input [7:0] reg09,
    input [7:0] reg10,
    input [7:0] reg11,
    input [7:0] reg12,
    input [7:0] reg13,
    input [7:0] regap,

    output reg [1:0] dev_kind,

    input fs_check,
    input fs_conf,
    input fs_read,
    output fd_check,
    output fd_conf,
    output fd_read
);

    localparam ANS_REG40 = 8'h49;
    localparam ANS_REG41 = 8'h4E;
    localparam ANS_REG42 = 8'h54;
    localparam ANS_REG43 = 8'h41;
    localparam ANS_REG44 = 8'h4E;

    localparam DATA_NULL = 16'h0000;

    localparam CMD_CONV0 = 16'h0000;
    localparam CMD_CONVN = 16'h3F00;
    localparam CMD_CALIT = 16'h5500;
    localparam CMD_CLEAR = 16'h6A00;
    localparam CMD_WREG = 2'b10;
    localparam CMD_RREG = 2'b11;
    localparam CMD_CONV = 2'b00;
    
    localparam CMD_NORM = 8'h00;
    localparam CMD_FSET = 8'h01;

    localparam RET_WREG = 8'hFF;
    localparam RET_RREG = 8'h00;

    localparam REG00 = 6'h00, REG01 = 6'h01, REG02 = 6'h02, REG03 = 6'h03;
    localparam REG04 = 6'h04, REG05 = 6'h05, REG06 = 6'h06, REG07 = 6'h07;
    localparam REG08 = 6'h08, REG09 = 6'h09, REG10 = 6'h0A, REG11 = 6'h0B;
    localparam REG12 = 6'h0C, REG13 = 6'h0D, REG14 = 6'h0E, REG15 = 6'h0F;
    localparam REG16 = 6'h10, REG17 = 6'h11, REG18 = 6'h12, REG19 = 6'h13;
    localparam REG20 = 6'h14, REG21 = 6'h15, REG40 = 6'h28, REG41 = 6'h29;
    localparam REG42 = 6'h2A, REG43 = 6'h2B, REG44 = 6'h2C, REG59 = 6'h3B;
    localparam REG60 = 6'h3C, REG61 = 6'h3D, REG62 = 6'h3E, REG63 = 6'h3F;

    localparam CH00 = 6'h00, CH01 = 6'h01, CH02 = 6'h02, CH03 = 6'h03;
    localparam CH04 = 6'h04, CH05 = 6'h05, CH06 = 6'h06, CH07 = 6'h07;
    localparam CH08 = 6'h08, CH09 = 6'h09, CH10 = 6'h0A, CH11 = 6'h0B;
    localparam CH12 = 6'h0C, CH13 = 6'h0D, CH14 = 6'h0E, CH15 = 6'h0F;
    localparam CH16 = 6'h10, CH17 = 6'h11, CH18 = 6'h12, CH19 = 6'h13;
    localparam CH20 = 6'h14, CH21 = 6'h15, CH22 = 6'h16, CH23 = 6'h17;
    localparam CH24 = 6'h18, CH25 = 6'h19, CH26 = 6'h1A, CH27 = 6'h1B;
    localparam CH28 = 6'h1C, CH29 = 6'h1D, CH30 = 6'h1E, CH31 = 6'h1F;
    localparam PVDD = 6'h30, TEMP = 8'h31, NEXT = 6'h3F;

    localparam MAIN_IDLE = 8'h00, MAIN_DEAD = 8'h01, DYG_CHECK = 8'h02, DYG_CONF = 8'h03;

    localparam IDLE_WAIT = 8'h06, IDLE_SKIP = 8'h07;
    localparam CHEK_WAIT = 8'h0A, CHEK_WORK = 8'h0B, CHEK_JUDGE = 8'h0C, CHEK_SKIP = 8'h0D;
    localparam KIND_WAIT = 8'h0E, KIND_WORK = 8'h0F, KIND_JUDGE = 8'h10, KIND_SKIP = 8'h11;
    localparam FIFO_WAIT = 8'h12, FIFO_WORK = 8'h13, FIFO_FIFO = 8'h14, FIFO_SKIP = 8'h15;
    localparam TEMP_WAIT = 8'h16, TEMP_WORK = 8'h17, TEMP_FIFO = 8'h18, TEMP_SKIP = 8'h19;
    localparam PVDD_WAIT = 8'h1A, PVDD_WORK = 8'h1B, PVDD_FIFO = 8'h1C, PVDD_SKIP = 8'h1D;

    localparam IDLE_CHECK = 8'h20;
    localparam CHECK_CREG40 = 8'h21, CHECK_CREG41 = 8'h22, CHECK_CREG42 = 8'h23;
    localparam CHECK_CREG43 = 8'h24, CHECK_CREG44 = 8'h25, CHECK_CHIPID = 8'h26;
    localparam CHECK_NUMAMP = 8'h27, RDREG_CHIPID = 8'h28, RDREG_NUMAMP = 8'h29;
    localparam CHECK_DRREG = 8'h2A, CHECK_DWAIT = 8'h2B, CHECK_DCHKD = 8'h2C;
    localparam CHECK_LAST = 8'h2D, CHECK_JUDGE = 8'h2E, CHECK_DONE = 8'h2F;

    localparam IDLE_CONF = 8'h40;
    localparam CONF_REG00 = 8'h41, CONF_REG01 = 8'h42, CONF_REG02 = 8'h43, CONF_REG03 = 8'h44;
    localparam CONF_REG04 = 8'h45, CONF_REG05 = 8'h46, CONF_REG06 = 8'h47, CONF_REG07 = 8'h48;
    localparam CONF_REG08 = 8'h49, CONF_REG09 = 8'h4A, CONF_REG10 = 8'h4B, CONF_REG11 = 8'h4C;
    localparam CONF_REG12 = 8'h4D, CONF_REG13 = 8'h4E, CONF_REG14 = 8'h4F, CONF_REG15 = 8'h50;
    localparam CONF_REG16 = 8'h51, CONF_REG17 = 8'h52, CONF_REG18 = 8'h53, CONF_REG19 = 8'h54;
    localparam CONF_REG20 = 8'h55, CONF_REG21 = 8'h56, CONF_CHK00 = 8'h57, CONF_CHK01 = 8'h58;
    localparam CONF_CALBT = 8'h59, CONF_DUMY0 = 8'h5A, CONF_DUMY1 = 8'h5B, CONF_DUMY2 = 8'h5C;
    localparam CONF_DUMY3 = 8'h5D, CONF_DUMY4 = 8'h5E, CONF_DUMY5 = 8'h5F, CONF_DUMY6 = 8'h60;
    localparam CONF_DUMY7 = 8'h61, CONF_DUMY8 = 8'h62;
    localparam CONF_FRREG = 8'h65, CONF_FWAIT = 8'h66, CONF_FCHKD = 8'h67;
    localparam CONF_DWREG = 8'h6A, CONF_DWAIT = 8'h6B, CONF_DCHKD = 8'h6C;
    localparam CONF_DONE = 8'h6F;

    localparam IDLE_CONV = 8'h80;
    localparam CONV_CH00 = 8'h81, CONV_CH01 = 8'h82, CONV_CH02 = 8'h82, CONV_CH03 = 8'h83;
    localparam CONV_CH04 = 8'h85, CONV_CH05 = 8'h86, CONV_CH06 = 8'h87, CONV_CH07 = 8'h83;
    localparam CONV_CH08 = 8'h89, CONV_CH09 = 8'h8A, CONV_CH10 = 8'h8B, CONV_CH11 = 8'h8C;
    localparam CONV_CH12 = 8'h8D, CONV_CH13 = 8'h8E, CONV_CH14 = 8'h8F, CONV_CH15 = 8'h90;
    localparam CONV_CH16 = 8'h91, CONV_CH17 = 8'h92, CONV_CH18 = 8'h93, CONV_CH19 = 8'h94;
    localparam CONV_CH20 = 8'h95, CONV_CH21 = 8'h96, CONV_CH22 = 8'h97, CONV_CH23 = 8'h98;
    localparam CONV_CH24 = 8'h99, CONV_CH25 = 8'h9A, CONV_CH26 = 8'h9B, CONV_CH27 = 8'h9C;
    localparam CONV_CH28 = 8'h9D, CONV_CH29 = 8'h9E, CONV_CH30 = 8'h9F, CONV_CH31 = 8'hA0;

    localparam CONV_CHK0 = 8'hA5, CONV_CHK1 = 8'hA6, CONV_DONE = 8'hA7;
    localparam CONV_PVDD = 8'hAA, CONV_TEMP = 8'hAB;


    (* MARK_DEBUG="true" *)reg [7:0] state; 
    reg [7:0] next_state;
    reg [7:0] state_goto, state_back;

    reg [1:0] dev_kind0, dev_kind1;

    (* MARK_DEBUG="true" *)reg [15:0] chip_txd; 
    wire [15:0] spi_rxd0; 
    wire [15:0] spi_rxd1;

    (* MARK_DEBUG="true" *)reg [15:0] chip_rxd0;
    (* MARK_DEBUG="true" *)reg [15:0] chip_rxd1;
    reg [15:0] data_check;

    wire fs_prd;
    wire fd_spi, fd_prd;
    wire fs_fifo0, fs_fifo1;
    wire fd_fifo;

    reg judge_dev_kind_equal;
    reg judge_dev_kind_right;
    reg judge_check_data_equal;


    assign fd_check = (state == CHECK_DONE);
    assign fd_conf = (state == CONF_DONE);
    assign fd_read = (state == CONV_DONE);
    assign fs_prd = (state == IDLE_WAIT) || (state == CHEK_WAIT) || (state == KIND_WAIT) || (state == FIFO_WAIT) || (state == TEMP_WAIT) || (state == PVDD_WAIT);
    assign fs_fifo1 = (state == FIFO_FIFO) || (state == TEMP_FIFO) || (state == PVDD_FIFO);
    assign fs_fifo0 = state == FIFO_FIFO;

    always @(posedge clk or posedge rst) begin
        if(rst) state <= MAIN_IDLE;
        else state <= next_state;
    end


    always @(*) begin
        case(state)
            MAIN_IDLE: begin
                if(fs_check) next_state <= IDLE_CHECK;
                else if(fs_conf) next_state <= IDLE_CONF;
                else if(fs_read) next_state <= IDLE_CONV;
                else next_state <= MAIN_IDLE;
            end

            MAIN_DEAD: begin
                next_state <= MAIN_DEAD;
            end

            DYG_CHECK:begin
                next_state <= MAIN_DEAD;
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

            FIFO_WAIT: begin
                if(fd_spi) next_state <= FIFO_WORK;
                else next_state <= FIFO_WAIT;
            end
            FIFO_WORK: begin
                next_state <= FIFO_FIFO;
            end
            FIFO_FIFO: begin
                if(fd_fifo) next_state <= FIFO_SKIP;
                else next_state <= FIFO_FIFO;
            end
            FIFO_SKIP: begin
                if(fd_prd) next_state <= state_goto;
                else next_state <= FIFO_SKIP;
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

            TEMP_WAIT: begin
                if(fd_spi) next_state <= TEMP_WORK;
                else next_state <= TEMP_WAIT;
            end
            TEMP_WORK: begin
                next_state <= TEMP_FIFO;
            end
            TEMP_FIFO: begin
                if(fd_fifo) next_state <= TEMP_SKIP;
                else next_state <= TEMP_FIFO;
            end
            TEMP_SKIP: begin
                if(fd_prd) next_state <= state_goto;
                else next_state <= TEMP_SKIP;
            end

            PVDD_WAIT: begin
                if(fd_spi) next_state <= PVDD_WORK;
                else next_state <= PVDD_WAIT;
            end
            PVDD_WORK: begin
                next_state <= PVDD_FIFO;
            end
            PVDD_FIFO: begin
                if(fd_fifo) next_state <= PVDD_SKIP;
                else next_state <= PVDD_FIFO;
            end
            PVDD_SKIP: begin
                if(fd_prd) next_state <= state_goto;
                else next_state <= PVDD_SKIP;
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

            CHECK_DRREG: next_state <= IDLE_WAIT;
            CHECK_DWAIT: next_state <= IDLE_WAIT;
            CHECK_DCHKD: next_state <= CHEK_WAIT;

            IDLE_CONF: next_state <= CONF_REG00;
            CONF_REG00: next_state <= IDLE_WAIT;
            CONF_REG01: next_state <= IDLE_WAIT;
            CONF_REG02: next_state <= CHEK_WAIT;
            CONF_REG03: next_state <= CHEK_WAIT;
            CONF_REG04: next_state <= CHEK_WAIT;
            CONF_REG05: next_state <= CHEK_WAIT;
            CONF_REG06: next_state <= CHEK_WAIT;
            CONF_REG07: next_state <= CHEK_WAIT;
            CONF_REG08: next_state <= CHEK_WAIT;
            CONF_REG09: next_state <= CHEK_WAIT;
            CONF_REG10: next_state <= CHEK_WAIT;
            CONF_REG11: next_state <= IDLE_WAIT;
            CONF_REG12: next_state <= CHEK_WAIT;
            CONF_REG13: next_state <= CHEK_WAIT;
            CONF_REG14: next_state <= CHEK_WAIT;
            CONF_REG15: next_state <= CHEK_WAIT;
            CONF_REG16: next_state <= CHEK_WAIT;
            CONF_REG17: next_state <= CHEK_WAIT;
            CONF_REG18: next_state <= CHEK_WAIT;
            CONF_REG19: next_state <= CHEK_WAIT;
            CONF_REG20: next_state <= CHEK_WAIT;
            CONF_REG21: next_state <= CHEK_WAIT;
            CONF_CHK00: next_state <= CHEK_WAIT;
            CONF_CHK01: next_state <= CHEK_WAIT;
            CONF_CALBT: next_state <= IDLE_WAIT;
            CONF_DUMY0: next_state <= IDLE_WAIT;
            CONF_DUMY1: next_state <= IDLE_WAIT;
            CONF_DUMY2: next_state <= IDLE_WAIT;
            CONF_DUMY3: next_state <= IDLE_WAIT;
            CONF_DUMY4: next_state <= IDLE_WAIT;
            CONF_DUMY5: next_state <= IDLE_WAIT;
            CONF_DUMY6: next_state <= IDLE_WAIT;
            CONF_DUMY7: next_state <= IDLE_WAIT;
            CONF_DUMY8: next_state <= IDLE_WAIT;
            CONF_FRREG: next_state <= IDLE_WAIT;
            CONF_FWAIT: next_state <= IDLE_WAIT;
            CONF_FCHKD: next_state <= CHEK_WAIT;
            CONF_DWREG: next_state <= IDLE_WAIT;
            CONF_DWAIT: next_state <= IDLE_WAIT;
            CONF_DCHKD: next_state <= CHEK_WAIT;
            CONF_DONE: begin
                if(~fs_conf) next_state <= MAIN_IDLE;
                else next_state <= CONF_DONE;
            end

            IDLE_CONV: next_state <= CONV_CH00;
            CONV_CH00: next_state <= IDLE_WAIT;
            CONV_CH01: next_state <= IDLE_WAIT;
            CONV_CH02: next_state <= FIFO_WAIT;
            CONV_CH03: next_state <= FIFO_WAIT;
            CONV_CH04: next_state <= FIFO_WAIT;
            CONV_CH05: next_state <= FIFO_WAIT;
            CONV_CH06: next_state <= FIFO_WAIT;
            CONV_CH07: next_state <= FIFO_WAIT;
            CONV_CH08: next_state <= FIFO_WAIT;
            CONV_CH09: next_state <= FIFO_WAIT;
            CONV_CH10: next_state <= FIFO_WAIT;
            CONV_CH11: next_state <= FIFO_WAIT;
            CONV_CH12: next_state <= FIFO_WAIT;
            CONV_CH13: next_state <= FIFO_WAIT;
            CONV_CH14: next_state <= FIFO_WAIT;
            CONV_CH15: next_state <= FIFO_WAIT;
            CONV_CH16: next_state <= FIFO_WAIT;
            CONV_CH17: next_state <= FIFO_WAIT;
            CONV_CH18: next_state <= FIFO_WAIT;
            CONV_CH19: next_state <= FIFO_WAIT;
            CONV_CH20: next_state <= FIFO_WAIT;
            CONV_CH21: next_state <= FIFO_WAIT;
            CONV_CH22: next_state <= FIFO_WAIT;
            CONV_CH23: next_state <= FIFO_WAIT;
            CONV_CH24: next_state <= FIFO_WAIT;
            CONV_CH25: next_state <= FIFO_WAIT;
            CONV_CH26: next_state <= FIFO_WAIT;
            CONV_CH27: next_state <= FIFO_WAIT;
            CONV_CH28: next_state <= FIFO_WAIT;
            CONV_CH29: next_state <= FIFO_WAIT;
            CONV_CH30: next_state <= FIFO_WAIT;
            CONV_CH31: next_state <= FIFO_WAIT;
            CONV_PVDD: next_state <= FIFO_WAIT;
            CONV_TEMP: next_state <= FIFO_WAIT;
            CONV_CHK0: next_state <= PVDD_WAIT;
            CONV_CHK1: next_state <= TEMP_WAIT;
            CONV_DONE: begin
                if(~fs_read) next_state <= MAIN_IDLE;
                else next_state <= CONV_DONE;
            end
            default: next_state <= MAIN_IDLE;
        endcase
    end


    always @(posedge clk or posedge rst) begin
        if(rst) begin
            state_goto <= MAIN_IDLE;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= DATA_NULL;
        end
        else if(state == CHECK_CREG40) begin
            state_goto <= CHECK_CREG41;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_RREG, REG40, RET_RREG};
        end
        else if(state == CHECK_CREG41) begin
            state_goto <= CHECK_CREG42;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_RREG, REG41, RET_RREG};
        end  
        else if(state == CHECK_CREG42) begin
            state_goto <= CHECK_CREG43;
            state_back <= CHECK_DRREG;
            data_check <= {RET_RREG, ANS_REG40};
            chip_txd <= {CMD_RREG, REG42, RET_RREG};
        end
        else if(state == CHECK_CREG43) begin
            state_goto <= CHECK_CREG44;
            state_back <= CHECK_DRREG;
            data_check <= {RET_RREG, ANS_REG41};
            chip_txd <= {CMD_RREG, REG43, RET_RREG};
        end
        else if(state == CHECK_CREG44) begin
            state_goto <= CHECK_CHIPID;
            state_back <= CHECK_DRREG;
            data_check <= {RET_RREG, ANS_REG42};
            chip_txd <= {CMD_RREG, REG44, RET_RREG};
        end
        else if(state == CHECK_CHIPID) begin
            state_goto <= CHECK_NUMAMP;
            state_back <= CHECK_DRREG;
            data_check <= {RET_RREG, ANS_REG43};
            chip_txd <= {CMD_RREG, REG62, RET_RREG};
        end
        else if(state == CHECK_NUMAMP) begin
            state_goto <= RDREG_CHIPID;
            state_back <= CHECK_DRREG;
            data_check <= {RET_RREG, ANS_REG44};
            chip_txd <= {CMD_RREG, REG63, RET_RREG};
        end
        else if(state == RDREG_CHIPID) begin
            state_goto <= RDREG_NUMAMP;
            state_back <= CHECK_DRREG;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_RREG, REG40, RET_RREG};
        end
        else if(state == RDREG_NUMAMP) begin
            state_goto <= CHECK_LAST;
            state_back <= CHECK_DRREG;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_RREG, REG40, RET_RREG};
        end
        else if(state == CHECK_DRREG) begin
            state_goto <= CHECK_DWAIT;
            state_back <= DYG_CHECK;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_RREG, REG40, RET_RREG};
        end
        else if(state == CHECK_DWAIT) begin
            state_goto <= CHECK_DCHKD;
            state_back <= DYG_CHECK;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_RREG, REG40, RET_RREG};
        end
        else if(state == CHECK_DCHKD) begin
            state_goto <= CHECK_CREG40;
            state_back <= DYG_CHECK;
            data_check <= {RET_RREG, ANS_REG40};
            chip_txd <= {CMD_RREG, REG40, RET_RREG};
        end

        else if(state == CONF_REG00) begin
            state_goto <= CONF_REG01;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_WREG, REG00, reg00};    
        end
        else if(state == CONF_REG01) begin
            state_goto <= CONF_REG02;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_WREG, REG01, reg01};    
        end
        else if(state == CONF_REG02) begin
            state_goto <= CONF_REG03;
            state_back <= CONF_DWREG;
            data_check <= {RET_WREG, reg00};
            chip_txd <= {CMD_WREG, REG02, reg02};    
        end
        else if(state == CONF_REG03) begin
            state_goto <= CONF_REG04;
            state_back <= CONF_DWREG;
            data_check <= {RET_WREG, reg01};
            chip_txd <= {CMD_WREG, REG03, reg03};    
        end
        else if(state == CONF_REG04) begin
            state_goto <= CONF_REG05;
            state_back <= CONF_DWREG;
            data_check <= {RET_WREG, reg02};
            chip_txd <= {CMD_WREG, REG04, reg04};    
        end
        else if(state == CONF_REG05) begin
            state_goto <= CONF_REG06;
            state_back <= CONF_DWREG;
            data_check <= {RET_WREG, reg03};
            chip_txd <= {CMD_WREG, REG05, reg05};    
        end
        else if(state == CONF_REG06) begin
            state_goto <= CONF_REG07;
            state_back <= CONF_DWREG;
            data_check <= {RET_WREG, reg04};
            chip_txd <= {CMD_WREG, REG06, reg06};    
        end
        else if(state == CONF_REG07) begin
            state_goto <= CONF_REG08;
            state_back <= CONF_DWREG;
            data_check <= {RET_WREG, reg05};
            chip_txd <= {CMD_WREG, REG07, reg07};    
        end
        else if(state == CONF_REG08) begin
            state_goto <= CONF_REG09;
            state_back <= CONF_DWREG;
            data_check <= {RET_WREG, reg06};
            chip_txd <= {CMD_WREG, REG02, reg08};    
        end
        else if(state == CONF_REG09) begin
            state_goto <= CONF_REG10;
            state_back <= CONF_DWREG;
            data_check <= {RET_WREG, reg07};
            chip_txd <= {CMD_WREG, REG02, reg09};    
        end
        else if(state == CONF_REG10) begin
            state_goto <= CONF_REG11;
            state_back <= CONF_DWREG;
            data_check <= {RET_WREG, reg08};
            chip_txd <= {CMD_WREG, REG02, reg10};    
        end
        else if(state == CONF_REG11) begin
            state_goto <= CONF_REG12;
            state_back <= CONF_DWREG;
            data_check <= {RET_WREG, reg09};
            chip_txd <= {CMD_WREG, REG02, reg11};    
        end
        else if(state == CONF_REG12) begin
            state_goto <= CONF_REG13;
            state_back <= CONF_DWREG;
            data_check <= {RET_WREG, reg10};
            chip_txd <= {CMD_WREG, REG02, reg12};    
        end
        else if(state == CONF_REG13) begin
            state_goto <= CONF_REG14;
            state_back <= CONF_DWREG;
            data_check <= {RET_WREG, reg11};
            chip_txd <= {CMD_WREG, REG02, reg13};    
        end
        else if(state == CONF_REG14) begin
            state_goto <= CONF_REG15;
            state_back <= CONF_DWREG;
            data_check <= {RET_WREG, reg12};
            chip_txd <= {CMD_WREG, REG02, regap};    
        end
        else if(state == CONF_REG15) begin
            if(dev_kind == 2'b01) state_goto <= CONF_CHK00;
            else if(dev_kind == 2'b10) state_goto <= CONF_REG16;
            else if(dev_kind == 2'b11) state_goto <= CONF_REG16;
            else state_goto <= DYG_CONF;

            state_back <= CONF_DWREG;
            data_check <= {RET_WREG, reg13};
            chip_txd <= {CMD_WREG, REG02, regap};    
        end
        else if(state == CONF_REG16) begin
            state_goto <= CONF_REG17;
            state_back <= CONF_DWREG;
            data_check <= {RET_WREG, regap};
            chip_txd <= {CMD_WREG, REG02, regap};    
        end
        else if(state == CONF_REG17) begin
            if(dev_kind == 2'b10) state_goto <= CONF_CHK00;
            else if(dev_kind == 2'b11) state_goto <= CONF_REG18;
            else state_goto <= DYG_CONF;

            state_back <= CONF_DWREG;
            data_check <= {RET_WREG, regap};
            chip_txd <= {CMD_WREG, REG17, regap};    
        end
        else if(state == CONF_REG18) begin
            state_goto <= CONF_REG19;
            state_back <= CONF_DWREG;
            data_check <= {RET_WREG, regap};
            chip_txd <= {CMD_WREG, REG02, regap};    
        end
        else if(state == CONF_REG19) begin
            state_goto <= CONF_REG20;
            state_back <= CONF_DWREG;
            data_check <= {RET_WREG, regap};
            chip_txd <= {CMD_WREG, REG02, regap};    
        end
        else if(state == CONF_REG20) begin
            state_goto <= CONF_REG21;
            state_back <= CONF_DWREG;
            data_check <= {RET_WREG, regap};
            chip_txd <= {CMD_WREG, REG20, regap};    
        end
        else if(state == CONF_REG21) begin
            state_goto <= CONF_CHK00;
            state_back <= CONF_DWREG;
            data_check <= {RET_WREG, regap};
            chip_txd <= {CMD_WREG, REG21, regap};    
        end
        else if(state == CONF_CHK00) begin
            state_goto <= CONF_CHK01;
            state_back <= CONF_DWREG;
            data_check <= {RET_WREG, regap};
            chip_txd <= {CMD_RREG, REG40, RET_RREG};    
        end
        else if(state == CONF_CHK01) begin
            state_goto <= CONF_CALBT;
            state_back <= CONF_DWREG;
            data_check <= {RET_WREG, regap};
            chip_txd <= {CMD_RREG, REG40, RET_RREG};    
        end

        else if(state == CONF_CALBT) begin
            state_goto <= CONF_DUMY0;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= CMD_CALIT;                
        end
        else if(state == CONF_DUMY0) begin
            state_goto <= CONF_DUMY1;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_RREG, REG40, RET_RREG};    
        end
        else if(state == CONF_DUMY1) begin
            state_goto <= CONF_DUMY2;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_RREG, REG40, RET_RREG};    
        end
        else if(state == CONF_DUMY2) begin
            state_goto <= CONF_DUMY3;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_RREG, REG40, RET_RREG};    
        end
        else if(state == CONF_DUMY3) begin
            state_goto <= CONF_DUMY4;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_RREG, REG40, RET_RREG};    
        end
        else if(state == CONF_DUMY4) begin
            state_goto <= CONF_DUMY5;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_RREG, REG40, RET_RREG};    
        end
        else if(state == CONF_DUMY5) begin
            state_goto <= CONF_DUMY6;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_RREG, REG40, RET_RREG};    
        end
        else if(state == CONF_DUMY6) begin
            state_goto <= CONF_DUMY7;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_RREG, REG40, RET_RREG};    
        end
        else if(state == CONF_DUMY7) begin
            state_goto <= CONF_DUMY8;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_RREG, REG40, RET_RREG};    
        end
        else if(state == CONF_DUMY8) begin
            state_goto <= CONF_FRREG;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_RREG, REG40, RET_RREG};    
        end


        else if(state == CONF_FRREG) begin
            state_goto <= CONF_FWAIT;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_RREG, REG41, RET_RREG};    
        end
        else if(state == CONF_FWAIT) begin
            state_goto <= CONF_FCHKD;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_RREG, REG42, RET_RREG};    
        end
        else if(state == CONF_FCHKD) begin
            state_goto <= CONF_DONE;
            state_back <= CONF_DWREG;
            data_check <= {RET_RREG, ANS_REG41};
            chip_txd <= {CMD_RREG, REG42, RET_RREG};    
        end
        else if(state == CONF_DWREG) begin
            state_goto <= CONF_DWAIT;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_WREG, REG00, reg00};    
        end
        else if(state == CONF_DWAIT) begin
            state_goto <= CONF_DCHKD;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_RREG, REG40, RET_RREG};    
        end
        else if(state == CONF_DCHKD) begin
            state_goto <= IDLE_CONF;
            state_back <= DYG_CONF;
            data_check <= {RET_WREG, reg00};
            chip_txd <= {CMD_RREG, REG40, RET_RREG};    
        end

        else if(state == CONV_CH00) begin
            state_goto <= CONV_CH01;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH00, CMD_NORM};    
        end
        else if(state == CONV_CH01) begin
            state_goto <= CONV_CH02;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH01, CMD_NORM};    
        end
        else if(state == CONV_CH02) begin
            state_goto <= CONV_CH03;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH02, CMD_NORM};    
        end
        else if(state == CONV_CH03) begin
            state_goto <= CONV_CH04;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH03, CMD_NORM};    
        end
        else if(state == CONV_CH04) begin
            state_goto <= CONV_CH05;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH04, CMD_NORM};    
        end
        else if(state == CONV_CH05) begin
            state_goto <= CONV_CH06;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH05, CMD_NORM};    
        end
        else if(state == CONV_CH06) begin
            state_goto <= CONV_CH07;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH06, CMD_NORM};    
        end
        else if(state == CONV_CH07) begin
            state_goto <= CONV_CH08;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH07, CMD_NORM};    
        end
        else if(state == CONV_CH08) begin
            state_goto <= CONV_CH09;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH08, CMD_NORM};    
        end
        else if(state == CONV_CH09) begin
            state_goto <= CONV_CH10;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH09, CMD_NORM};    
        end
        else if(state == CONV_CH10) begin
            state_goto <= CONV_CH11;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH10, CMD_NORM};    
        end
        else if(state == CONV_CH11) begin
            state_goto <= CONV_CH12;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH11, CMD_NORM};    
        end
        else if(state == CONV_CH12) begin
            state_goto <= CONV_CH13;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH12, CMD_NORM};    
        end
        else if(state == CONV_CH13) begin
            state_goto <= CONV_CH14;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH13, CMD_NORM};    
        end
        else if(state == CONV_CH14) begin
            state_goto <= CONV_CH15;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH14, CMD_NORM};    
        end
        else if(state == CONV_CH15) begin
            if (dev_kind[1]) state_goto <= CONV_CH16;
            else state_goto <= CONV_PVDD;

            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH15, CMD_NORM};    
        end
        else if(state == CONV_CH16) begin
            state_goto <= CONV_CH17;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH16, CMD_NORM};    
        end
        else if(state == CONV_CH17) begin
            state_goto <= CONV_CH18;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH17, CMD_NORM};    
        end
        else if(state == CONV_CH18) begin
            state_goto <= CONV_CH19;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH18, CMD_NORM};    
        end
        else if(state == CONV_CH19) begin
            state_goto <= CONV_CH20;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH19, CMD_NORM};    
        end
        else if(state == CONV_CH20) begin
            state_goto <= CONV_CH21;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH20, CMD_NORM};    
        end
        else if(state == CONV_CH21) begin
            state_goto <= CONV_CH22;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH21, CMD_NORM};    
        end
        else if(state == CONV_CH22) begin
            state_goto <= CONV_CH23;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH22, CMD_NORM};    
        end
        else if(state == CONV_CH23) begin
            state_goto <= CONV_CH24;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH23, CMD_NORM};    
        end
        else if(state == CONV_CH24) begin
            state_goto <= CONV_CH25;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH24, CMD_NORM};    
        end
        else if(state == CONV_CH25) begin
            state_goto <= CONV_CH26;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH25, CMD_NORM};    
        end
        else if(state == CONV_CH26) begin
            state_goto <= CONV_CH27;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH26, CMD_NORM};    
        end
        else if(state == CONV_CH27) begin
            state_goto <= CONV_CH28;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH27, CMD_NORM};    
        end
        else if(state == CONV_CH28) begin
            state_goto <= CONV_CH29;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH28, CMD_NORM};    
        end
        else if(state == CONV_CH29) begin
            state_goto <= CONV_CH30;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH29, CMD_NORM};    
        end
        else if(state == CONV_CH30) begin
            state_goto <= CONV_CH31;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH30, CMD_NORM};    
        end
        else if(state == CONV_CH31) begin
            state_goto <= CONV_PVDD;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_CONV, CH31, CMD_NORM};    
        end
        else if(state == CONV_PVDD) begin
            state_goto <= CONV_TEMP;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;

            if(pvdden) chip_txd <= {CMD_CONV, PVDD, CMD_NORM};    
            else chip_txd <= {CMD_RREG, REG40, RET_RREG};
        end
        else if(state == CONV_TEMP) begin
            state_goto <= CONV_CHK0;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;

            if(tempen) chip_txd <= {CMD_CONV, TEMP, CMD_NORM};    
            else chip_txd <= {CMD_WREG, REG03, reg03};
        end
        else if(state == CONV_CHK0) begin
            state_goto <= CONV_CHK1;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_RREG, REG40, RET_RREG};    
        end
        else if(state == CONV_CHK1) begin
            state_goto <= CONV_DONE;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_RREG, REG40, RET_RREG}; 
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
        else if(state == KIND_JUDGE && chip_rxd0[7:0] == 8'h01) begin
            dev_kind0 <= 2'b10;
            dev_kind1 <= dev_kind1;
            judge_dev_kind_right <= 1'b1;
        end
        else if(state == KIND_JUDGE && chip_rxd0[7:0] == 8'h02) begin
            dev_kind0 <= 2'b01;
            dev_kind1 <= dev_kind1;
            judge_dev_kind_right <= 1'b1;
        end
        else if(state == KIND_JUDGE && chip_rxd0[7:0] == 8'h04) begin
            dev_kind0 <= 2'b11;
            dev_kind1 <= dev_kind1;
            judge_dev_kind_right <= 1'b1;
        end
        else if(state == KIND_JUDGE && chip_rxd0[7:0] == 8'h10) begin
            dev_kind0 <= dev_kind0;
            dev_kind1 <= 2'b01;
            judge_dev_kind_right <= 1'b1;
        end
        else if(state == KIND_JUDGE && chip_rxd0[7:0] == 8'h20) begin
            dev_kind0 <= dev_kind0;
            dev_kind1 <= 2'b10;
            judge_dev_kind_right <= 1'b1;
        end
        else if(state == KIND_JUDGE && chip_rxd0[7:0] == 8'h40) begin
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
        else if(state == MAIN_DEAD) begin
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
        else if(state == CHEK_JUDGE && chip_rxd0 == data_check) judge_check_data_equal <= 1'b1;
        else if(state == CHEK_JUDGE && chip_rxd0 != data_check) judge_check_data_equal <= 1'b0;
        else judge_check_data_equal <= judge_check_data_equal; 
    end

// #endregion

// temp_resA chip_rxd0 chip_rxd1
// #region
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            chip_rxd0 <= 16'h0000;
            chip_rxd1 <= 16'h0000;
        end
        else if(state == CHEK_WORK) begin
            chip_rxd0 <= spi_rxd0;
            chip_rxd1 <= 16'h0000;
        end
        else if(state == KIND_WORK) begin
            chip_rxd0 <= spi_rxd0;
            chip_rxd1 <= 16'h0000;
        end
        else if(state == FIFO_WORK) begin
            chip_rxd0 <= spi_rxd0;
            chip_rxd1 <= spi_rxd1;
        end
        else if(state == PVDD_WORK & (pvdden)) begin
            chip_rxd0 <= 16'h0000;
            chip_rxd1 <= spi_rxd0;
        end
        else if(state == PVDD_WORK & (!pvdden)) begin
            chip_rxd0 <= 16'h0000;
            chip_rxd1 <= 16'h0000;
        end
        else if(state == TEMP_WORK & tempen) begin
            chip_rxd0 <= 16'h0000;
            chip_rxd1 <= spi_rxd0;
        end
        else if(state == TEMP_WORK & (!tempen)) begin
            chip_rxd0 <= 16'h0000;
            chip_rxd1 <= 16'h0000;
        end
        else begin
            chip_rxd0 <= chip_rxd0;
            chip_rxd1 <= chip_rxd1;
        end
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
        .chip_rxd0(spi_rxd0),
        .chip_rxd1(spi_rxd1)
    );

endmodule