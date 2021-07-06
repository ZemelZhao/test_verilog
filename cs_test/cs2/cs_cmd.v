module cs_cmd(
    input clk,
    input rst,

    input fifoa_full,
    input fifoc_full,
    input fifod_full,

    output fs_send,
    input fs_recv,

    input fs_udp_rx,
    output fs_mac2fifoc,
    output fs_fifoc2cs,
    output fs_cs_num,

    output fd_udp_rx,
    input fd_mac2fifoc,
    input fd_fifoc2cs,
    input fd_cs_num,

    output rst_all,
    output [3:0] led_cont
);

    reg [7:0] main_state, next_main_state;
    reg [7:0] int_state, next_int_state;
    wire fifo_check;



    localparam MAIN_IDLE = 8'h00, MAIN_WAIT = 8'h01, MAIN_INIT = 8'h02, MAIN_PREP = 8'h03;
    localparam MAIN_WORK = 8'h04;

    localparam INT_IDLE = 8'h00, INT_URXS = 8'h01, INT_UTOF = 8'h02, INT_FTOC = 8'h03;
    localparam INT_URXD = 8'h04, INT_CSNM = 8'h05, INT_DONE = 8'h06, INT_TEST = 8'h07;


    assign fifo_check = ~|{fifoa_full, fifoc_full, fifod_full};
    // assign fs_mac2fifoc = (int_state == INT_UTOF);
    // assign fs_fifoc2cs = (int_state == INT_FTOC);
    // assign fd_udp_rx = (int_state == INT_URXD);

    // TEST
    assign led_cont[3:0] = state;

// #region
    // always @(posedge clk or posedge rst_all) begin
    //     if(rst_all) main_state <= MAIN_IDLE;
    //     else main_state <= next_main_state;
    // end

    // always @(posedge clk or posedge rst_all) begin
    //     if(rst_all) int_state <= INT_IDLE;
    //     else int_state <= next_int_state;
    // end

    // always @(*) begin
    //     case(main_state)
    //         MAIN_IDLE: begin
    //             if(fifo_check) next_main_state <= MAIN_WAIT;
    //             else next_main_state <= MAIN_IDLE;
    //         end
    //         MAIN_WAIT: begin
    //             if(fs_udp_rx) next_main_state <= MAIN_INIT;
    //             else next_main_state <= MAIN_INIT;
    //         end
    //         MAIN_INIT: begin
    //             if(fd_udp_rx) next_main_state <= MAIN_PREP;
    //             else next_main_state <= MAIN_INIT;
    //         end
    //         MAIN_PREP: begin
    //             if(fs_udp_rx) next_main_state <= MAIN_INIT;
    //             else next_main_state <= MAIN_PREP;
    //         end
    //         default: next_main_state <= MAIN_IDLE;  
    //     endcase
    // end

    // always @(*) begin
    //     case(int_state)
    //         INT_IDLE: begin
    //             if(main_state == MAIN_INIT) next_int_state <= INT_URXS;
    //             else next_int_state <= INT_IDLE;
    //         end
    //         INT_URXS: begin
    //             if(fs_udp_rx) next_int_state <= INT_UTOF;
    //             else next_int_state <= INT_URXS;
    //         end
    //         INT_UTOF: begin
    //             if(fd_mac2fifoc) next_int_state <= INT_URXD;
    //             else next_int_state <= INT_UTOF;
    //         end
    //         INT_URXD: begin
    //             if(fs_udp_rx == 1'b0) next_int_state <= INT_FTOC;
    //             else next_int_state <= INT_URXD;
    //         end
    //         INT_FTOC: begin
    //             if(fd_fifoc2cs) next_int_state <= INT_DONE;
    //             else next_int_state <= INT_FTOC;
    //         end

    //         INT_CSNM: begin
    //             if(fd_cs_num) next_int_state <= INT_DONE;
    //             else next_int_state <= INT_FTOC;
    //         end
    //         INT_DONE: next_int_state <= INT_IDLE;
    //         default: next_int_state <= INT_IDLE;
    //     endcase
    // end

// #endregion
    
    reg [3:0] state, next_state;
    localparam IDLE = 4'h8, MCFC = 4'h9, UPRX = 4'hA, FIFR = 4'hB;
    localparam TEST = 4'h3, HAHA = 4'hF;
    localparam T0 = 4'h4, T1 = 4'h5, T2 = 4'h6, T3 = 4'h7;

    assign fs_mac2fifoc = (state == MCFC);
    assign fd_udp_rx = (state == UPRX);
    assign fs_fifoc2cs = (state == FIFR);
    assign fs_send = (state == HAHA);
    // assign fs_send = fifo_check;


// #endregion

    always @(posedge clk or posedge rst) begin
        if(rst) state <= IDLE;
        else state <= next_state;
    end

    always @(*) begin
        case(state)
            IDLE: begin
                if(fifo_check) next_state <= TEST;
                else next_state <= IDLE; 
            end
            HAHA: begin
                if(fs_recv) next_state <= T0;
                else next_state <= HAHA;
            end
            T0: next_state <= T1;
            T1: next_state <= T2;
            T2: next_state <= T3;
            T3: next_state <= IDLE;
            TEST: begin
                if(fs_udp_rx) next_state <= MCFC;
                else next_state <= TEST;
            end
            MCFC: begin
                if(fd_mac2fifoc) next_state <= UPRX;
                else next_state <= MCFC;
            end
            UPRX: begin
                if(fs_udp_rx == 1'b0) next_state <= FIFR;
                else next_state <= UPRX;
            end
            FIFR: begin
                if(fd_fifoc2cs) next_state <= IDLE;
                else next_state <= FIFR; 
            end
            default: next_state <= IDLE;
        endcase
    end


//     always@(posedge clk or posedge rst) begin
//         if(rst) state <= IDLE;
//         else begin
//             case(state)
//                 IDLE: begin
//                     if(fifo_check) begin
//                         state <= TEST;
//                     end
//                     else state <= IDLE;
//                 end
//                 TEST: begin
//                     if(fs_udp_rx) begin
//                         state <= MCFC;
//                     end
//                     else state <= TEST;
//                 end
//                 MCFC: begin
//                     if(fd_mac2fifoc) state <= UPRX;
//                     else state <= MCFC;
//                 end
//                 UPRX: begin
//                     if(fs_udp_rx == 1'b0) state <= FIFR;
//                     else state <= UPRX;
//                 end
//                 FIFR: begin
//                     if(fd_fifoc2cs) state <= IDLE;
//                     else state <= FIFR;
//                 end
//                 default: state <= IDLE;
//             endcase
//         end
//     end

endmodule