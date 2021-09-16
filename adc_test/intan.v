module intan(
    input clk,
    input rst,

    input spi_mc, 

    input miso,
    output cs,
    output mosi,
    output sclk,
    
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
    output fd_check,
    output fd_conf
);

    localparam ANS_REG40 = 8'h49;
    localparam ANS_REG41 = 8'h4E;
    localparam ANS_REG42 = 8'h54;
    localparam ANS_REG43 = 8'h41;
    localparam ANS_REG44 = 8'h4E;

    localparam DATA_NULL = 16'h0000;

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
    assign fd_conf = (state == CONF_DONE);
    assign fs_prd = (state == IDLE_WAIT) || (state == CHEK_WAIT) || (state == KIND_WAIT);

    always @(posedge clk or posedge rst) begin
        if(rst) state <= MAIN_IDLE;
        else state <= next_state;
    end


    always @(*) begin
        case(state)
            MAIN_IDLE: begin
                if(fs_check) next_state <= IDLE_CHECK;
                else if(fs_conf) next_state <= IDLE_CONF;
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
            chip_txd <= {CMD_READ, REG40, RET_READ};
        end
        else if(state == CHECK_CREG41) begin
            state_goto <= CHECK_CREG42;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
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
            data_check <= DATA_NULL;
            chip_txd <= {CMD_READ, REG40, RET_READ};
        end
        else if(state == RDREG_NUMAMP) begin
            state_goto <= CHECK_LAST;
            state_back <= CHECK_DRDREG;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_READ, REG40, RET_READ};
        end

        else if(state == CONF_REG00) begin
            state_goto <= CONF_REG01;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_WRITE, REG00, reg00};    
        end
        else if(state == CONF_REG01) begin
            state_goto <= CONF_REG02;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_WRITE, REG01, reg01};    
        end
        else if(state == CONF_REG02) begin
            state_goto <= CONF_REG03;
            state_back <= CONF_DWREG;
            data_check <= {RET_WRITE, reg00};
            chip_txd <= {CMD_WRITE, REG02, reg02};    
        end
        else if(state == CONF_REG03) begin
            state_goto <= CONF_REG04;
            state_back <= CONF_DWREG;
            data_check <= {RET_WRITE, reg01};
            chip_txd <= {CMD_WRITE, REG03, reg03};    
        end
        else if(state == CONF_REG04) begin
            state_goto <= CONF_REG05;
            state_back <= CONF_DWREG;
            data_check <= {RET_WRITE, reg02};
            chip_txd <= {CMD_WRITE, REG04, reg04};    
        end
        else if(state == CONF_REG05) begin
            state_goto <= CONF_REG06;
            state_back <= CONF_DWREG;
            data_check <= {RET_WRITE, reg03};
            chip_txd <= {CMD_WRITE, REG05, reg05};    
        end
        else if(state == CONF_REG06) begin
            state_goto <= CONF_REG07;
            state_back <= CONF_DWREG;
            data_check <= {RET_WRITE, reg04};
            chip_txd <= {CMD_WRITE, REG06, reg06};    
        end
        else if(state == CONF_REG07) begin
            state_goto <= CONF_REG08;
            state_back <= CONF_DWREG;
            data_check <= {RET_WRITE, reg05};
            chip_txd <= {CMD_WRITE, REG07, reg07};    
        end
        else if(state == CONF_REG08) begin
            state_goto <= CONF_REG09;
            state_back <= CONF_DWREG;
            data_check <= {RET_WRITE, reg06};
            chip_txd <= {CMD_WRITE, REG02, reg08};    
        end
        else if(state == CONF_REG09) begin
            state_goto <= CONF_REG10;
            state_back <= CONF_DWREG;
            data_check <= {RET_WRITE, reg07};
            chip_txd <= {CMD_WRITE, REG02, reg09};    
        end
        else if(state == CONF_REG10) begin
            state_goto <= CONF_REG11;
            state_back <= CONF_DWREG;
            data_check <= {RET_WRITE, reg08};
            chip_txd <= {CMD_WRITE, REG02, reg10};    
        end
        else if(state == CONF_REG11) begin
            state_goto <= CONF_REG12;
            state_back <= CONF_DWREG;
            data_check <= {RET_WRITE, reg09};
            chip_txd <= {CMD_WRITE, REG02, reg11};    
        end
        else if(state == CONF_REG12) begin
            state_goto <= CONF_REG13;
            state_back <= CONF_DWREG;
            data_check <= {RET_WRITE, reg10};
            chip_txd <= {CMD_WRITE, REG02, reg12};    
        end
        else if(state == CONF_REG13) begin
            state_goto <= CONF_REG14;
            state_back <= CONF_DWREG;
            data_check <= {RET_WRITE, reg11};
            chip_txd <= {CMD_WRITE, REG02, reg13};    
        end
        else if(state == CONF_REG14) begin
            state_goto <= CONF_REG15;
            state_back <= CONF_DWREG;
            data_check <= {RET_WRITE, reg12};
            chip_txd <= {CMD_WRITE, REG02, regap};    
        end
        else if(state == CONF_REG15) begin
            if(dev_kind == 2'b01) state_goto <= CONF_CHK00;
            else if(dev_kind == 2'b10) state_goto <= CONF_REG16;
            else if(dev_kind == 2'b11) state_goto <= CONF_REG16;
            else state_goto <= DYG_CONF;

            state_back <= CONF_DWREG;
            data_check <= {RET_WRITE, reg13};
            chip_txd <= {CMD_WRITE, REG02, regap};    
        end
        else if(state == CONF_REG16) begin
            state_goto <= CONF_REG17;
            state_back <= CONF_DWREG;
            data_check <= {RET_WRITE, regap};
            chip_txd <= {CMD_WRITE, REG02, regap};    
        end
        else if(state == CONF_REG17) begin
            if(dev_kind == 2'b10) state_goto <= CONF_CHK00;
            else if(dev_kind == 2'b11) state_goto <= CONF_REG18;
            else state_goto <= DYG_CONF;

            state_back <= CONF_DWREG;
            data_check <= {RET_WRITE, regap};
            chip_txd <= {CMD_WRITE, REG17, regap};    
        end
        else if(state == CONF_REG18) begin
            state_goto <= CONF_REG19;
            state_back <= CONF_DWREG;
            data_check <= {RET_WRITE, regap};
            chip_txd <= {CMD_WRITE, REG02, regap};    
        end
        else if(state == CONF_REG19) begin
            state_goto <= CONF_REG20;
            state_back <= CONF_DWREG;
            data_check <= {RET_WRITE, regap};
            chip_txd <= {CMD_WRITE, REG02, regap};    
        end
        else if(state == CONF_REG20) begin
            state_goto <= CONF_REG21;
            state_back <= CONF_DWREG;
            data_check <= {RET_WRITE, regap};
            chip_txd <= {CMD_WRITE, REG20, regap};    
        end
        else if(state == CONF_REG21) begin
            state_goto <= CONF_CHK00;
            state_back <= CONF_DWREG;
            data_check <= {RET_WRITE, regap};
            chip_txd <= {CMD_WRITE, REG21, regap};    
        end
        else if(state == CONF_CHK00) begin
            state_goto <= CONF_CHK01;
            state_back <= CONF_DWREG;
            data_check <= {RET_WRITE, regap};
            chip_txd <= {CMD_READ, REG40, RET_READ};    
        end
        else if(state == CONF_CHK01) begin
            state_goto <= CONF_CALBT;
            state_back <= CONF_DWREG;
            data_check <= {RET_WRITE, regap};
            chip_txd <= {CMD_READ, REG40, RET_READ};    
        end

        else if(state == CONF_CALBT) begin
            state_goto <= CONF_DUMY0;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= CMD_CALIBRATE;                
        end
        else if(state == CONF_DUMY0) begin
            state_goto <= CONF_DUMY1;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_READ, REG40, RET_READ};    
        end
        else if(state == CONF_DUMY1) begin
            state_goto <= CONF_DUMY2;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_READ, REG40, RET_READ};    
        end
        else if(state == CONF_DUMY2) begin
            state_goto <= CONF_DUMY3;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_READ, REG40, RET_READ};    
        end
        else if(state == CONF_DUMY3) begin
            state_goto <= CONF_DUMY4;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_READ, REG40, RET_READ};    
        end
        else if(state == CONF_DUMY4) begin
            state_goto <= CONF_DUMY5;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_READ, REG40, RET_READ};    
        end
        else if(state == CONF_DUMY5) begin
            state_goto <= CONF_DUMY6;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_READ, REG40, RET_READ};    
        end
        else if(state == CONF_DUMY6) begin
            state_goto <= CONF_DUMY7;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_READ, REG40, RET_READ};    
        end
        else if(state == CONF_DUMY7) begin
            state_goto <= CONF_DUMY8;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_READ, REG40, RET_READ};    
        end
        else if(state == CONF_DUMY8) begin
            state_goto <= CONF_FRREG;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_READ, REG40, RET_READ};    
        end


        else if(state == CONF_FRREG) begin
            state_goto <= CONF_FWAIT;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_READ, REG41, RET_READ};    
        end
        else if(state == CONF_FWAIT) begin
            state_goto <= CONF_FCHKD;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_READ, REG42, RET_READ};    
        end
        else if(state == CONF_FCHKD) begin
            state_goto <= CONF_DONE;
            state_back <= CONF_DWREG;
            data_check <= {RET_READ, ANS_REG41};
            chip_txd <= {CMD_READ, REG42, RET_READ};    
        end
        else if(state == CONF_DWREG) begin
            state_goto <= CONF_DWAIT;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_WRITE, REG00, reg00};    
        end
        else if(state == CONF_DWAIT) begin
            state_goto <= CONF_DCHKD;
            state_back <= MAIN_IDLE;
            data_check <= DATA_NULL;
            chip_txd <= {CMD_READ, REG40, RET_READ};    
        end
        else if(state == CONF_DCHKD) begin
            state_goto <= IDLE_CONF;
            state_back <= DYG_CONF;
            data_check <= {RET_WRITE, reg00};
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