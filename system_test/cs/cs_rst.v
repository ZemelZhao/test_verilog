module cs_rst(
    input rst_all, 
    input rst_run,

    output rst_cs_com,
    output rst_mac, 
    output rst_adc,
    output rst_fifoc,
    output rst_fifod,
    output rst_mac2fifoc,
    output rst_fifoc2cs,
    output rst_adc2fifod,
    output rst_fifod2mac
);

    assign rst_cs_com = rst_run;
    assign rst_mac = rst_all;
    assign rst_adc = rst_run;
    assign rst_fifoc = rst_all;
    assign rst_fifod = rst_run;
    assign rst_mac2fifoc = rst_run;
    assign rst_fifoc2cs = rst_run;
    assign rst_adc2fifod = rst_run;
    assign rst_fifod2mac = rst_run;


endmodule