module eth2mac(
    input rst,
    input gmii_txc,
    input gmii_rxc,

    input gmii_rxdv,
    input [7:0] gmii_rxd,
    output reg mac_rxdv,
    output reg [7:0] mac_rxd,

    output reg gmii_txen,
    output reg [7:0] gmii_txd,
    input mac_txdv,
    input [7:0] mac_txd
);

always@(posedge gmii_rxc or posedge rst) begin
    if(rst) begin
        mac_rxdv <= 1'b0;
        mac_rxd <= 8'd0;
    end
    else begin
        mac_rxdv <= gmii_rxdv;
        mac_rxd <= gmii_rxd;
    end
end
  
always@(posedge gmii_txc or posedge rst) begin
    if(rst) begin
        gmii_txen <= 1'b0;
        gmii_txd <= 8'd0;
    end
    else begin
        gmii_txen <= mac_txdv;
        gmii_txd <= mac_txd;
    end
end

endmodule