module test(
    input clk
);

    wire rst;
    reg fs0, fs1;
    wire fd;
    wire fclk;

    wire fs_cs, fd_cs;
	wire fs_tx, fd_tx;
	wire fs_rx, fd_rx;

    (* MARK_DEBUG="true" *)wire fifoi_full0, fifoi_full1;
    reg[15:0] chip_rxd0, chip_rxd1;

    wire [9:0] adc_rx_len;
    wire [11:0] eth_tx_len;
    wire [7:0] data_cnt;

    wire [63:0] intan_cmd;
    wire [63:0] intan_ind;
    wire [7:0] intan_lrt;
    wire [7:0] intan_end;
    wire [7:0] intan_vtb;

    (* MARK_DEBUG="true" *)wire [1:0] fifoi_txen;
    (* MARK_DEBUG="true" *)wire [15:0] fifoi_txd;

	(* MARK_DEBUG="true" *)wire [63:0] fifo_grxd;
	(* MARK_DEBUG="true" *)wire [7:0] adc_rxd;
	(* MARK_DEBUG="true" *)wire [7:0] fifo_rxen;
	(* MARK_DEBUG="true" *)wire adc_rxen;


    (* MARK_DEBUG="true" *)reg [7:0] state;
    reg [7:0] next_state;
    reg [7:0] state_goto;

// #region
    localparam IDLE = 8'h00, RXST = 8'h01, RXDN = 8'h02;
    localparam FIST = 8'h03, FIDN = 8'h04, LAST = 8'h05;
    localparam CONF = 8'h06;
    localparam TX00 = 8'h10, TX01 = 8'h11, TX02 = 8'h12, TX03 = 8'h13;
    localparam TX04 = 8'h14, TX05 = 8'h15, TX06 = 8'h16, TX07 = 8'h17;
    localparam TX08 = 8'h18, TX09 = 8'h19, TX0A = 8'h1A, TX0B = 8'h1B;
    localparam TX0C = 8'h1C, TX0D = 8'h1D, TX0E = 8'h1E, TX0F = 8'h1F;
    localparam TX10 = 8'h20, TX11 = 8'h21, TX12 = 8'h22, TX13 = 8'h23;
    localparam TX14 = 8'h24, TX15 = 8'h25, TX16 = 8'h26, TX17 = 8'h27;
    localparam TX18 = 8'h28, TX19 = 8'h29, TX1A = 8'h2A, TX1B = 8'h2B;
    localparam TX1C = 8'h2C, TX1D = 8'h2D, TX1E = 8'h2E, TX1F = 8'h2F;
    localparam TX20 = 8'h30, TX21 = 8'h31;

    localparam D000 = 16'h2F9F, D001 = 16'h7B44, D002 = 16'hE0D3, D003 = 16'hD221;
    localparam D004 = 16'hBF1F, D005 = 16'h5E3D, D006 = 16'hCF27, D007 = 16'h70C7;
    localparam D008 = 16'h80BE, D009 = 16'hED37, D00A = 16'hB6E1, D00B = 16'h443F;
    localparam D00C = 16'h23A7, D00D = 16'h97A3, D00E = 16'hA9B6, D00F = 16'hEF47;
    localparam D010 = 16'h218A, D011 = 16'hB89D, D012 = 16'hCD03, D013 = 16'h0E9E;
    localparam D014 = 16'hA682, D015 = 16'h6B84, D016 = 16'h0FD2, D017 = 16'hC0D1;
    localparam D018 = 16'hCC61, D019 = 16'h3B19, D01A = 16'h3CD5, D01B = 16'h0DE0;
    localparam D01C = 16'h3598, D01D = 16'hFE2E, D01E = 16'h6E1E, D01F = 16'hD01B;
    localparam D020 = 16'h4FC8, D021 = 16'hD79B;

    localparam D100 = 16'h6C66, D101 = 16'hF432, D102 = 16'h19F8, D103 = 16'hF57D;
    localparam D104 = 16'hC983, D105 = 16'hD871, D106 = 16'h7BB5, D107 = 16'h9EB5;
    localparam D108 = 16'hACDF, D109 = 16'h0D61, D10A = 16'hF057, D10B = 16'hAE97;
    localparam D10C = 16'hA21C, D10D = 16'h1BA0, D10E = 16'hD677, D10F = 16'h3F72;
    localparam D110 = 16'h82E6, D111 = 16'h2D70, D112 = 16'h240C, D113 = 16'h8688;
    localparam D114 = 16'hBF7C, D115 = 16'h7082, D116 = 16'hE419, D117 = 16'h758A;
    localparam D118 = 16'hE1E5, D119 = 16'h009F, D11A = 16'hD6B4, D11B = 16'hBD45;
    localparam D11C = 16'h098E, D11D = 16'h10CD, D11E = 16'hE7B3, D11F = 16'hF29B;
    localparam D120 = 16'h9A62, D121 = 16'hCB53;
// #endregion
    assign fs_cs = (state == CONF);
	assign fs_rx = (state == FIST);
	assign fifo_grxd[47:0] = 48'h0;
	assign fclk = clk;

    always @(posedge clk or posedge rst) begin
        if(rst) state <= IDLE;
        else state <= next_state;
    end
    
    always @(*) begin
        case(state)
            IDLE: next_state <= CONF; 
            CONF: begin
                if(fd_cs) next_state <= TX00;
                else next_state <= CONF;
            end
            RXST: begin
                if(fd_tx) next_state <= RXDN;
                else next_state <= RXST;
            end
            RXDN: next_state <= state_goto;
            FIST: begin
                if(fd_rx) next_state <= FIDN;
                else next_state <= FIST;
            end
            FIDN: next_state <= LAST;
            LAST: next_state <= IDLE;
            TX00: next_state <= RXST;
            TX01: next_state <= RXST;
            TX02: next_state <= RXST;
            TX03: next_state <= RXST;
            TX04: next_state <= RXST;
            TX05: next_state <= RXST;
            TX06: next_state <= RXST;
            TX07: next_state <= RXST;
            TX08: next_state <= RXST;
            TX09: next_state <= RXST;
            TX0A: next_state <= RXST;
            TX0B: next_state <= RXST;
            TX0C: next_state <= RXST;
            TX0D: next_state <= RXST;
            TX0E: next_state <= RXST;
            TX0F: next_state <= RXST;
            TX10: next_state <= RXST;
            TX11: next_state <= RXST;
            TX12: next_state <= RXST;
            TX13: next_state <= RXST;
            TX14: next_state <= RXST;
            TX15: next_state <= RXST;
            TX16: next_state <= RXST;
            TX17: next_state <= RXST;
            TX18: next_state <= RXST;
            TX19: next_state <= RXST;
            TX1A: next_state <= RXST;
            TX1B: next_state <= RXST;
            TX1C: next_state <= RXST;
            TX1D: next_state <= RXST;
            TX1E: next_state <= RXST;
            TX1F: next_state <= RXST;
            TX20: next_state <= RXST;
            TX21: next_state <= RXST;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst)begin
			state_goto <= IDLE;
			chip_rxd0 <= 16'h000;
			chip_rxd1 <= 16'h0000;
			{fs0, fs1} <= 2'b00;
        end
		else if (state == RXDN) begin
			state_goto <= state_goto;
			chip_rxd0 <= chip_rxd0;
			chip_rxd1 <= chip_rxd1;
			{fs1, fs0} <= 2'b00;
		end
		else if(state == TX00) begin
			state_goto <= TX01;
			chip_rxd0 <= D000;
			chip_rxd1 <= D100;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX01) begin
			state_goto <= TX02;
			chip_rxd0 <= D001;
			chip_rxd1 <= D101;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX02) begin
			state_goto <= TX03;
			chip_rxd0 <= D002;
			chip_rxd1 <= D102;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX03) begin
			state_goto <= TX04;
			chip_rxd0 <= D003;
			chip_rxd1 <= D103;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX04) begin
			state_goto <= TX05;
			chip_rxd0 <= D004;
			chip_rxd1 <= D104;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX05) begin
			state_goto <= TX06;
			chip_rxd0 <= D005;
			chip_rxd1 <= D105;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX06) begin
			state_goto <= TX07;
			chip_rxd0 <= D006;
			chip_rxd1 <= D106;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX07) begin
			state_goto <= TX08;
			chip_rxd0 <= D007;
			chip_rxd1 <= D107;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX08) begin
			state_goto <= TX09;
			chip_rxd0 <= D008;
			chip_rxd1 <= D108;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX09) begin
			state_goto <= TX0A;
			chip_rxd0 <= D009;
			chip_rxd1 <= D109;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX0A) begin
			state_goto <= TX0B;
			chip_rxd0 <= D00A;
			chip_rxd1 <= D10A;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX0B) begin
			state_goto <= TX0C;
			chip_rxd0 <= D00B;
			chip_rxd1 <= D10B;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX0C) begin
			state_goto <= TX0D;
			chip_rxd0 <= D00C;
			chip_rxd1 <= D10C;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX0D) begin
			state_goto <= TX0E;
			chip_rxd0 <= D00D;
			chip_rxd1 <= D10D;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX0E) begin
			state_goto <= TX0F;
			chip_rxd0 <= D00E;
			chip_rxd1 <= D10E;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX0F) begin
			state_goto <= TX10;
			chip_rxd0 <= D00F;
			chip_rxd1 <= D10F;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX10) begin
			state_goto <= TX11;
			chip_rxd0 <= D010;
			chip_rxd1 <= D110;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX11) begin
			state_goto <= TX12;
			chip_rxd0 <= D011;
			chip_rxd1 <= D111;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX12) begin
			state_goto <= TX13;
			chip_rxd0 <= D012;
			chip_rxd1 <= D112;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX13) begin
			state_goto <= TX14;
			chip_rxd0 <= D013;
			chip_rxd1 <= D113;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX14) begin
			state_goto <= TX15;
			chip_rxd0 <= D014;
			chip_rxd1 <= D114;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX15) begin
			state_goto <= TX16;
			chip_rxd0 <= D015;
			chip_rxd1 <= D115;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX16) begin
			state_goto <= TX17;
			chip_rxd0 <= D016;
			chip_rxd1 <= D116;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX17) begin
			state_goto <= TX18;
			chip_rxd0 <= D017;
			chip_rxd1 <= D117;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX18) begin
			state_goto <= TX19;
			chip_rxd0 <= D018;
			chip_rxd1 <= D118;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX19) begin
			state_goto <= TX1A;
			chip_rxd0 <= D019;
			chip_rxd1 <= D119;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX1A) begin
			state_goto <= TX1B;
			chip_rxd0 <= D01A;
			chip_rxd1 <= D11A;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX1B) begin
			state_goto <= TX1C;
			chip_rxd0 <= D01B;
			chip_rxd1 <= D11B;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX1C) begin
			state_goto <= TX1D;
			chip_rxd0 <= D01C;
			chip_rxd1 <= D11C;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX1D) begin
			state_goto <= TX1E;
			chip_rxd0 <= D01D;
			chip_rxd1 <= D11D;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX1E) begin
			state_goto <= TX1F;
			chip_rxd0 <= D01E;
			chip_rxd1 <= D11E;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX1F) begin
			state_goto <= TX20;
			chip_rxd0 <= D01F;
			chip_rxd1 <= D11F;
			{fs0, fs1} <= 2'b11;
		end
		else if(state == TX20) begin
			state_goto <= TX21;
			chip_rxd0 <= D020;
			chip_rxd1 <= D120;
			{fs0, fs1} <= 2'b10;
		end
		else if(state == TX21) begin
			state_goto <= FIST;
			// state_goto <= IDLE;
			chip_rxd0 <= D021;
			chip_rxd1 <= D121;
			{fs0, fs1} <= 2'b10;
		end
        else begin
			state_goto <= state_goto;
			chip_rxd0 <= chip_rxd0;
			chip_rxd1 <= chip_rxd1;
			{fs0, fs1} <= {fs0, fs1};
        end
    end

    fifo2adc
    fifo2adc_dut(
        .clk(fclk),
        .rst(),
        .fs_fifo(fs_rx),
        .fd_fifo(fd_rx),
        .adc_rxen(adc_rxen),
        .fifoi_grxen(fifo_rxen),
        .dev_kind(8'hC0),
        .dev_info(8'hB7),
        .dev_smpr(8'hFA),
        .fifoi_grxd(fifo_grxd),
        .adc_rxd(adc_rxd),
        .intan_cmd(intan_cmd),
        .intan_ind(intan_ind),
        .intan_lrt(intan_lrt),
        .intan_vtb(intan_vtb),
        .intan_end(intan_end)
    );

    cs_num
    cs_num_dut(
        .clk(clk),
        .rst(),
        .cmd_kdev(8'hC0),
        .adc_rx_len(adc_rx_len),
        .eth_tx_len(eth_tx_len),
        .data_cnt(data_cnt),
        .intan_cmd(intan_cmd),
        .intan_ind(intan_ind),
        .intan_lrt(intan_lrt),
        .intan_end(intan_end),
        .intan_vtb(intan_vtb),
        .fs(fs_cs),
        .fd(fd_cs)
    );



    spi2fifo
    spi2fifo_dut(
        .clk(fclk),
        .rst(rst),
        .fs0(fs0),
        .fs1(fs1),
        .fd(fd_tx),
        .fifoi_full0(fifoi_full0),
        .fifoi_full1(fifoi_full1),
        .chip_rxd0(chip_rxd0),
        .chip_rxd1(chip_rxd1),
        .fifoi_txen(fifoi_txen),
        .fifoi_txd(fifoi_txd)
    );


    fifoi
    fifoi_dut0(
        .wr_clk(fclk),
        .wr_en(fifoi_txen[0]),
        .din(fifoi_txd[7:0]),
        // .wr_en(1'b0),
        // .din(8'h0),

        .rd_clk(fclk),
        .rd_en(fifo_rxen[6]),
        .dout(fifo_grxd[55:48]),

        .full(fifoi_full0),
        .rst(rst)
    );

    fifoi
    fifoi_dut1(
        .wr_clk(fclk),
        .wr_en(fifoi_txen[1]),
        .din(fifoi_txd[15:8]),
        // .wr_en(1'b0),
        // .din(8'h0),

        .rd_clk(fclk),
        .rd_en(fifo_rxen[7]),
        .dout(fifo_grxd[63:56]),

        .full(fifoi_full1),
        .rst(rst)
    );

endmodule