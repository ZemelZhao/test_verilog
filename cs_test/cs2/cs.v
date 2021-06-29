module cs(
    input clk,
    input rst,

    input fifoa_full,
    input fifoc_full,
    input fifod_full,

    input fs_udp_rx,
    output fs_mac2fifoc,
    output fs_fifoc2cs,

    output fd_udp_rx,
    input fd_mac2fifoc,
    input fd_fifoc2cs,

    output [31:0] led_cont
);

    wire fs_cs_num, fd_cs_num;

    cs_cmd
    cs_cmd_dut(
        .clk(clk),
        .rst(rst),

        .fifoa_full(fifoa_full),
        .fifoc_full(fifoc_full),
        .fifod_full(fifod_full),

        .fs_udp_rx(fs_udp_rx),
        .fs_mac2fifoc(fs_mac2fifoc),
        .fs_fifoc2cs(fs_fifoc2cs),
        .fd_udp_rx(fd_udp_rx),
        .fd_mac2fifoc(fd_mac2fifoc),
        .fd_fifoc2cs(fd_fifoc2cs),

        .led_cont(led_cont)
    );



endmodule