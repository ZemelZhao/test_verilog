module cs_cmd(
    input clk,
    input rst,

    input fifoa_full,
    input fifoc_full,
    input fifod_full,

    output fd_udp_rx,
    output fs_mac2fifoc,
    output fs_fifoc2cs,
    output fs_cs_num,

    input fs_udp_rx,
    input fd_mac2fifoc,
    input fd_fifoc2cs,
    input fd_cs_num,

    input err_fifoc2cs
);

    localparam MAIN_IDLE = 8'h0, MAIN_INIT = 8'h1;
    localparam MAIN_PREP = 8'h2, MAIN_WORK = 8'h3;
    
    localparam INIT_IDLE = 8'h0, INIT_MCFC = 8'h1;
    localparam INIT_UPRX = 8'h2, INIT_FCCS = 8'h3;
    localparam INIT_CDRG = 8'h4, INIT_CSNM = 8'h5;
    localparam INIT_DONE = 8'hF;

    wire fifo_check;
    wire init_done;

    reg [7:0] main_state, next_main_state;
    reg [7:0] init_state, next_init_state;




    assign fifo_check = ~|{fifoa_full, fifoc_full, fifod_full};
    assign fs_mac2fifoc = (init_state == INIT_MCFC);
    assign fd_udp_rx = (init_state == INIT_UPRX);
    assign fs_fifoc2cs = (init_state == INIT_FCCS);
    assign fs_cs_num = (init_state == INIT_CSNM);
    assign init_done = (init_state == INIT_DONE);

    always @(posedge clk or posedge rst) begin
        if(rst) main_state <= MAIN_IDLE;
        else main_state <= next_main_state;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) init_state <= INIT_IDLE;
        else init_state <= next_init_state;
    end

    always @(*) begin
        case(main_state)
            MAIN_IDLE: begin
                if(fs_udp_rx) next_main_state <= MAIN_INIT;
                else next_main_state <= MAIN_IDLE;
            end
            MAIN_INIT: begin
                if(fifo_check) next_main_state <= MAIN_PREP;
                else next_main_state <= MAIN_PREP;
            end
            MAIN_PREP: begin
                if(init_done) next_main_state <= MAIN_WORK;
                else if(err_fifoc2cs) next_main_state <= MAIN_IDLE;
                else next_main_state <= MAIN_PREP;
            end
            MAIN_WORK: begin
                if(fs_udp_rx) next_main_state <= MAIN_INIT;
                else next_main_state <= MAIN_WORK;
            end
            default: next_main_state <= MAIN_IDLE;
        endcase
    end

    always @(*) begin
        case(init_state)
            INIT_IDLE: begin
                if(main_state == MAIN_PREP) next_init_state <= INIT_MCFC;
                else next_init_state <= INIT_IDLE;
            end
            INIT_MCFC: begin
                if(fd_mac2fifoc) next_init_state <= INIT_UPRX;
                else next_init_state <= INIT_MCFC;
            end
            INIT_UPRX: begin
                if(~fs_udp_rx) next_init_state <= INIT_FCCS;
                else next_init_state <= INIT_UPRX;
            end
            INIT_FCCS: begin
                if(fd_fifoc2cs) next_init_state <= INIT_CDRG;
                else next_init_state <= INIT_FCCS;
            end
            INIT_CDRG: begin
                if(err_fifoc2cs) next_init_state <= INIT_IDLE;
                else next_init_state <= INIT_CSNM;
            end
            INIT_CSNM: begin
                if(fd_cs_num) next_init_state <= INIT_DONE;
                else next_init_state <= INIT_CSNM;
            end
            INIT_DONE: begin
                if(main_state == MAIN_WORK) next_init_state <= INIT_IDLE;
                else next_init_state <= INIT_DONE;
            end
            default: next_init_state <= INIT_IDLE;
        endcase
    end






endmodule