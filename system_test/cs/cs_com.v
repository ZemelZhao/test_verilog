module cs_com(
    input sys_clk,
    input rst,
    input adc_rxc,

    inout [1:0] com0,
    input [1:0] com1,

    input fd_adc_conf,
    input dev_grp,
    output fs_adc,
    output [3:0] dat_id
);

    reg [7:0] state, next_state;
    reg [3:0] dato, dati, check;
    
    assign com0[1] = (state == CONF_BEGN) ?1'b1 :1'bz;
    assign com0[0] = (state == CONF_DONE) ?1'b1 :1'bz;
    assign fs_adc = (dev_grp) ?(state == WORK_RDGN) :adc_rxc;
    assign dat_id = (dev_grp) ?dato :dati;


    localparam MAIN_IDLE = 8'h00, MAIN_TYPE = 8'h01;
    localparam CONF_BEGN = 8'h10, CONF_DONE = 8'h11;
    localparam WORK_RDBG = 8'h20, WORK_RDGN = 8'h21; 
    localparam DTID_RD00 = 8'h40, DTID_RD01 = 8'h41, DTID_CK00 = 8'h42, DTID_CK01 = 8'h43;
    localparam DTID_JUDG = 8'h44, DTID_DONE = 8'h45; 
    localparam DTID_MAKE = 8'h80, DTID_PLUS = 8'h81, DTID_WAIT = 8'h82;

    always @(posedge sys_clk or posedge rst) begin
        if(rst) state <= MAIN_IDLE;
        else state <= next_state;
    end

    always @(*) begin
        case(state)
            MAIN_IDLE: begin
                if(fd_adc_conf) next_state <= MAIN_TYPE;
                else next_state <= MAIN_IDLE;
            end
            MAIN_TYPE: begin
                if(dev_grp) next_state <= CONF_BEGN;
                else next_state <= DTID_MAKE;
            end
            CONF_BEGN: begin
                if(com1 == 2'h3) next_state <= CONF_DONE;
                else next_state <= CONF_BEGN;
            end
            CONF_DONE: begin
                if(com1 == 2'h0) next_state <= WORK_RDBG;
                else next_state <= CONF_DONE;
            end

            WORK_RDBG: begin
                if (com0[1]) next_state <= WORK_RDGN;
                else next_state <= WORK_RDBG;
            end
            WORK_RDGN: begin
                if(~com0[1]) next_state <= DTID_RD00;
                else next_state <= WORK_RDGN;
            end
            DTID_RD00: begin
                if(com0[0]) next_state <= DTID_RD01;
                else next_state <= DTID_RD00;
            end
            DTID_RD01: begin
                if(~com0[0]) next_state <= DTID_CK00;
                else next_state <= DTID_RD01;
            end
            DTID_CK00: begin
                if(com0[0]) next_state <= DTID_CK01;
                else next_state <= DTID_CK00;
            end
            DTID_CK01: begin
                if(~com0[0]) next_state <= DTID_JUDG;
                else next_state <= DTID_CK01;
            end
            DTID_JUDG: begin
                if(dato == check && dato != 4'h0) next_state <= DTID_DONE;
                else next_state <= DTID_RD00;
            end
            DTID_DONE: next_state <= WORK_RDBG;

            DTID_MAKE: begin
                if(adc_rxc) next_state <= DTID_PLUS;
                else next_state <= DTID_MAKE;
            end
            DTID_PLUS: begin
                next_state <= DTID_WAIT;
            end
            DTID_WAIT: begin
                if(~adc_rxc) next_state <= DTID_MAKE;
                else next_state <= DTID_WAIT;
            end

            default: next_state <= MAIN_IDLE;
        endcase
    end
    
    always @(posedge sys_clk or posedge rst) begin
        if(rst) dati <= 4'h0;
        else if(state == DTID_PLUS && dati == 4'hF) dati <= 4'h1;
        else if(state == DTID_PLUS) dati <= dati + 1'b1;
        else dati <= dati;
    end


    always @(posedge sys_clk or posedge rst) begin
        if(rst) begin
            dato <= 4'h0;
            check <= 4'h0;
        end
        else if(state == DTID_RD00) begin
            dato[3:2] <= com1;
            dato[1:0] <= dato[1:0];
            check <= check;
        end
        else if(state == DTID_RD01) begin
            dato[3:2] <= dato[3:2];
            dato[1:0] <= com1;
            check <= check;
        end
        else if(state == DTID_CK00) begin
            dato <= dato;
            check[3:2] <= com1;
            check[1:0] <= check[1:0];
        end
        else if(state == DTID_CK01) begin
            dato <= dato;
            check[3:2] <= check[3:2];
            check[1:0] <= com1;
        end
        else begin
            dato <= dato;
            check <= check;
        end
    end

endmodule