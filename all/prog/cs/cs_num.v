module cs_num(
    input clk,
    input rst,
    input [7:0] cmd_kdev,

    output reg [9:0] adc_rx_len,
    output reg [11:0] eth_tx_len,
    output reg [7:0] data_cnt,

    input fs,
    output fd
);

    reg [7:0] state, next_state;
    localparam IDLE = 8'h00, PREP = 8'h1, WORK = 8'h2, LAST = 8'h3;

    localparam UDP_LEN = 12'd1472;
    localparam MAX_NUM = 8'd10;

    assign fd = (state == LAST);

    always @(posedge clk or posedge rst) begin
        if(rst) state <= IDLE;
        else state <= next_state;
    end

    always @(*) begin
        case(state)
            IDLE: begin
                if(fs) next_state <= PREP;
                else next_state <= IDLE;
            end
            PREP: next_state <= WORK;
            WORK: next_state <= LAST;
            LAST: begin
                if(~fs) next_state <= IDLE;
                else next_state <= LAST;
            end
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            adc_rx_len <= 10'h000;
            eth_tx_len <= 12'h000;
            data_cnt <= 8'h00;
        end
        else if(state == WORK) begin
			case(cmd_kdev)
				8'h00: begin
					adc_rx_len <= 10'h006;
					eth_tx_len <= 12'h03C;
					data_cnt <= 8'h0A;
				end
				8'h01: begin
					adc_rx_len <= 10'h026;
					eth_tx_len <= 12'h17C;
					data_cnt <= 8'h0A;
				end
				8'h02: begin
					adc_rx_len <= 10'h046;
					eth_tx_len <= 12'h2BC;
					data_cnt <= 8'h0A;
				end
				8'h03: begin
					adc_rx_len <= 10'h086;
					eth_tx_len <= 12'h53C;
					data_cnt <= 8'h0A;
				end
				8'h04: begin
					adc_rx_len <= 10'h026;
					eth_tx_len <= 12'h17C;
					data_cnt <= 8'h0A;
				end
				8'h05: begin
					adc_rx_len <= 10'h046;
					eth_tx_len <= 12'h2BC;
					data_cnt <= 8'h0A;
				end
				8'h06: begin
					adc_rx_len <= 10'h066;
					eth_tx_len <= 12'h3FC;
					data_cnt <= 8'h0A;
				end
				8'h07: begin
					adc_rx_len <= 10'h0A6;
					eth_tx_len <= 12'h530;
					data_cnt <= 8'h08;
				end
				8'h08: begin
					adc_rx_len <= 10'h046;
					eth_tx_len <= 12'h2BC;
					data_cnt <= 8'h0A;
				end
				8'h09: begin
					adc_rx_len <= 10'h066;
					eth_tx_len <= 12'h3FC;
					data_cnt <= 8'h0A;
				end
				8'h0A: begin
					adc_rx_len <= 10'h086;
					eth_tx_len <= 12'h53C;
					data_cnt <= 8'h0A;
				end
				8'h0B: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'h0C: begin
					adc_rx_len <= 10'h086;
					eth_tx_len <= 12'h53C;
					data_cnt <= 8'h0A;
				end
				8'h0D: begin
					adc_rx_len <= 10'h0A6;
					eth_tx_len <= 12'h530;
					data_cnt <= 8'h08;
				end
				8'h0E: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'h0F: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'h10: begin
					adc_rx_len <= 10'h026;
					eth_tx_len <= 12'h17C;
					data_cnt <= 8'h0A;
				end
				8'h11: begin
					adc_rx_len <= 10'h046;
					eth_tx_len <= 12'h2BC;
					data_cnt <= 8'h0A;
				end
				8'h12: begin
					adc_rx_len <= 10'h066;
					eth_tx_len <= 12'h3FC;
					data_cnt <= 8'h0A;
				end
				8'h13: begin
					adc_rx_len <= 10'h0A6;
					eth_tx_len <= 12'h530;
					data_cnt <= 8'h08;
				end
				8'h14: begin
					adc_rx_len <= 10'h046;
					eth_tx_len <= 12'h2BC;
					data_cnt <= 8'h0A;
				end
				8'h15: begin
					adc_rx_len <= 10'h066;
					eth_tx_len <= 12'h3FC;
					data_cnt <= 8'h0A;
				end
				8'h16: begin
					adc_rx_len <= 10'h086;
					eth_tx_len <= 12'h53C;
					data_cnt <= 8'h0A;
				end
				8'h17: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'h18: begin
					adc_rx_len <= 10'h066;
					eth_tx_len <= 12'h3FC;
					data_cnt <= 8'h0A;
				end
				8'h19: begin
					adc_rx_len <= 10'h086;
					eth_tx_len <= 12'h53C;
					data_cnt <= 8'h0A;
				end
				8'h1A: begin
					adc_rx_len <= 10'h0A6;
					eth_tx_len <= 12'h530;
					data_cnt <= 8'h08;
				end
				8'h1B: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'h1C: begin
					adc_rx_len <= 10'h0A6;
					eth_tx_len <= 12'h530;
					data_cnt <= 8'h08;
				end
				8'h1D: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'h1E: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'h1F: begin
					adc_rx_len <= 10'h126;
					eth_tx_len <= 12'h5BE;
					data_cnt <= 8'h05;
				end
				8'h20: begin
					adc_rx_len <= 10'h046;
					eth_tx_len <= 12'h2BC;
					data_cnt <= 8'h0A;
				end
				8'h21: begin
					adc_rx_len <= 10'h066;
					eth_tx_len <= 12'h3FC;
					data_cnt <= 8'h0A;
				end
				8'h22: begin
					adc_rx_len <= 10'h086;
					eth_tx_len <= 12'h53C;
					data_cnt <= 8'h0A;
				end
				8'h23: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'h24: begin
					adc_rx_len <= 10'h066;
					eth_tx_len <= 12'h3FC;
					data_cnt <= 8'h0A;
				end
				8'h25: begin
					adc_rx_len <= 10'h086;
					eth_tx_len <= 12'h53C;
					data_cnt <= 8'h0A;
				end
				8'h26: begin
					adc_rx_len <= 10'h0A6;
					eth_tx_len <= 12'h530;
					data_cnt <= 8'h08;
				end
				8'h27: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'h28: begin
					adc_rx_len <= 10'h086;
					eth_tx_len <= 12'h53C;
					data_cnt <= 8'h0A;
				end
				8'h29: begin
					adc_rx_len <= 10'h0A6;
					eth_tx_len <= 12'h530;
					data_cnt <= 8'h08;
				end
				8'h2A: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'h2B: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'h2C: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'h2D: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'h2E: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'h2F: begin
					adc_rx_len <= 10'h146;
					eth_tx_len <= 12'h518;
					data_cnt <= 8'h04;
				end
				8'h30: begin
					adc_rx_len <= 10'h086;
					eth_tx_len <= 12'h53C;
					data_cnt <= 8'h0A;
				end
				8'h31: begin
					adc_rx_len <= 10'h0A6;
					eth_tx_len <= 12'h530;
					data_cnt <= 8'h08;
				end
				8'h32: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'h33: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'h34: begin
					adc_rx_len <= 10'h0A6;
					eth_tx_len <= 12'h530;
					data_cnt <= 8'h08;
				end
				8'h35: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'h36: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'h37: begin
					adc_rx_len <= 10'h126;
					eth_tx_len <= 12'h5BE;
					data_cnt <= 8'h05;
				end
				8'h38: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'h39: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'h3A: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'h3B: begin
					adc_rx_len <= 10'h146;
					eth_tx_len <= 12'h518;
					data_cnt <= 8'h04;
				end
				8'h3C: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'h3D: begin
					adc_rx_len <= 10'h126;
					eth_tx_len <= 12'h5BE;
					data_cnt <= 8'h05;
				end
				8'h3E: begin
					adc_rx_len <= 10'h146;
					eth_tx_len <= 12'h518;
					data_cnt <= 8'h04;
				end
				8'h3F: begin
					adc_rx_len <= 10'h186;
					eth_tx_len <= 12'h492;
					data_cnt <= 8'h03;
				end
				8'h40: begin
					adc_rx_len <= 10'h026;
					eth_tx_len <= 12'h17C;
					data_cnt <= 8'h0A;
				end
				8'h41: begin
					adc_rx_len <= 10'h046;
					eth_tx_len <= 12'h2BC;
					data_cnt <= 8'h0A;
				end
				8'h42: begin
					adc_rx_len <= 10'h066;
					eth_tx_len <= 12'h3FC;
					data_cnt <= 8'h0A;
				end
				8'h43: begin
					adc_rx_len <= 10'h0A6;
					eth_tx_len <= 12'h530;
					data_cnt <= 8'h08;
				end
				8'h44: begin
					adc_rx_len <= 10'h046;
					eth_tx_len <= 12'h2BC;
					data_cnt <= 8'h0A;
				end
				8'h45: begin
					adc_rx_len <= 10'h066;
					eth_tx_len <= 12'h3FC;
					data_cnt <= 8'h0A;
				end
				8'h46: begin
					adc_rx_len <= 10'h086;
					eth_tx_len <= 12'h53C;
					data_cnt <= 8'h0A;
				end
				8'h47: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'h48: begin
					adc_rx_len <= 10'h066;
					eth_tx_len <= 12'h3FC;
					data_cnt <= 8'h0A;
				end
				8'h49: begin
					adc_rx_len <= 10'h086;
					eth_tx_len <= 12'h53C;
					data_cnt <= 8'h0A;
				end
				8'h4A: begin
					adc_rx_len <= 10'h0A6;
					eth_tx_len <= 12'h530;
					data_cnt <= 8'h08;
				end
				8'h4B: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'h4C: begin
					adc_rx_len <= 10'h0A6;
					eth_tx_len <= 12'h530;
					data_cnt <= 8'h08;
				end
				8'h4D: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'h4E: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'h4F: begin
					adc_rx_len <= 10'h126;
					eth_tx_len <= 12'h5BE;
					data_cnt <= 8'h05;
				end
				8'h50: begin
					adc_rx_len <= 10'h046;
					eth_tx_len <= 12'h2BC;
					data_cnt <= 8'h0A;
				end
				8'h51: begin
					adc_rx_len <= 10'h066;
					eth_tx_len <= 12'h3FC;
					data_cnt <= 8'h0A;
				end
				8'h52: begin
					adc_rx_len <= 10'h086;
					eth_tx_len <= 12'h53C;
					data_cnt <= 8'h0A;
				end
				8'h53: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'h54: begin
					adc_rx_len <= 10'h066;
					eth_tx_len <= 12'h3FC;
					data_cnt <= 8'h0A;
				end
				8'h55: begin
					adc_rx_len <= 10'h086;
					eth_tx_len <= 12'h53C;
					data_cnt <= 8'h0A;
				end
				8'h56: begin
					adc_rx_len <= 10'h0A6;
					eth_tx_len <= 12'h530;
					data_cnt <= 8'h08;
				end
				8'h57: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'h58: begin
					adc_rx_len <= 10'h086;
					eth_tx_len <= 12'h53C;
					data_cnt <= 8'h0A;
				end
				8'h59: begin
					adc_rx_len <= 10'h0A6;
					eth_tx_len <= 12'h530;
					data_cnt <= 8'h08;
				end
				8'h5A: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'h5B: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'h5C: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'h5D: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'h5E: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'h5F: begin
					adc_rx_len <= 10'h146;
					eth_tx_len <= 12'h518;
					data_cnt <= 8'h04;
				end
				8'h60: begin
					adc_rx_len <= 10'h066;
					eth_tx_len <= 12'h3FC;
					data_cnt <= 8'h0A;
				end
				8'h61: begin
					adc_rx_len <= 10'h086;
					eth_tx_len <= 12'h53C;
					data_cnt <= 8'h0A;
				end
				8'h62: begin
					adc_rx_len <= 10'h0A6;
					eth_tx_len <= 12'h530;
					data_cnt <= 8'h08;
				end
				8'h63: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'h64: begin
					adc_rx_len <= 10'h086;
					eth_tx_len <= 12'h53C;
					data_cnt <= 8'h0A;
				end
				8'h65: begin
					adc_rx_len <= 10'h0A6;
					eth_tx_len <= 12'h530;
					data_cnt <= 8'h08;
				end
				8'h66: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'h67: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'h68: begin
					adc_rx_len <= 10'h0A6;
					eth_tx_len <= 12'h530;
					data_cnt <= 8'h08;
				end
				8'h69: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'h6A: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'h6B: begin
					adc_rx_len <= 10'h126;
					eth_tx_len <= 12'h5BE;
					data_cnt <= 8'h05;
				end
				8'h6C: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'h6D: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'h6E: begin
					adc_rx_len <= 10'h126;
					eth_tx_len <= 12'h5BE;
					data_cnt <= 8'h05;
				end
				8'h6F: begin
					adc_rx_len <= 10'h166;
					eth_tx_len <= 12'h598;
					data_cnt <= 8'h04;
				end
				8'h70: begin
					adc_rx_len <= 10'h0A6;
					eth_tx_len <= 12'h530;
					data_cnt <= 8'h08;
				end
				8'h71: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'h72: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'h73: begin
					adc_rx_len <= 10'h126;
					eth_tx_len <= 12'h5BE;
					data_cnt <= 8'h05;
				end
				8'h74: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'h75: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'h76: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'h77: begin
					adc_rx_len <= 10'h146;
					eth_tx_len <= 12'h518;
					data_cnt <= 8'h04;
				end
				8'h78: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'h79: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'h7A: begin
					adc_rx_len <= 10'h126;
					eth_tx_len <= 12'h5BE;
					data_cnt <= 8'h05;
				end
				8'h7B: begin
					adc_rx_len <= 10'h166;
					eth_tx_len <= 12'h598;
					data_cnt <= 8'h04;
				end
				8'h7C: begin
					adc_rx_len <= 10'h126;
					eth_tx_len <= 12'h5BE;
					data_cnt <= 8'h05;
				end
				8'h7D: begin
					adc_rx_len <= 10'h146;
					eth_tx_len <= 12'h518;
					data_cnt <= 8'h04;
				end
				8'h7E: begin
					adc_rx_len <= 10'h166;
					eth_tx_len <= 12'h598;
					data_cnt <= 8'h04;
				end
				8'h7F: begin
					adc_rx_len <= 10'h1A6;
					eth_tx_len <= 12'h4F2;
					data_cnt <= 8'h03;
				end
				8'h80: begin
					adc_rx_len <= 10'h046;
					eth_tx_len <= 12'h2BC;
					data_cnt <= 8'h0A;
				end
				8'h81: begin
					adc_rx_len <= 10'h066;
					eth_tx_len <= 12'h3FC;
					data_cnt <= 8'h0A;
				end
				8'h82: begin
					adc_rx_len <= 10'h086;
					eth_tx_len <= 12'h53C;
					data_cnt <= 8'h0A;
				end
				8'h83: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'h84: begin
					adc_rx_len <= 10'h066;
					eth_tx_len <= 12'h3FC;
					data_cnt <= 8'h0A;
				end
				8'h85: begin
					adc_rx_len <= 10'h086;
					eth_tx_len <= 12'h53C;
					data_cnt <= 8'h0A;
				end
				8'h86: begin
					adc_rx_len <= 10'h0A6;
					eth_tx_len <= 12'h530;
					data_cnt <= 8'h08;
				end
				8'h87: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'h88: begin
					adc_rx_len <= 10'h086;
					eth_tx_len <= 12'h53C;
					data_cnt <= 8'h0A;
				end
				8'h89: begin
					adc_rx_len <= 10'h0A6;
					eth_tx_len <= 12'h530;
					data_cnt <= 8'h08;
				end
				8'h8A: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'h8B: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'h8C: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'h8D: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'h8E: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'h8F: begin
					adc_rx_len <= 10'h146;
					eth_tx_len <= 12'h518;
					data_cnt <= 8'h04;
				end
				8'h90: begin
					adc_rx_len <= 10'h066;
					eth_tx_len <= 12'h3FC;
					data_cnt <= 8'h0A;
				end
				8'h91: begin
					adc_rx_len <= 10'h086;
					eth_tx_len <= 12'h53C;
					data_cnt <= 8'h0A;
				end
				8'h92: begin
					adc_rx_len <= 10'h0A6;
					eth_tx_len <= 12'h530;
					data_cnt <= 8'h08;
				end
				8'h93: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'h94: begin
					adc_rx_len <= 10'h086;
					eth_tx_len <= 12'h53C;
					data_cnt <= 8'h0A;
				end
				8'h95: begin
					adc_rx_len <= 10'h0A6;
					eth_tx_len <= 12'h530;
					data_cnt <= 8'h08;
				end
				8'h96: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'h97: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'h98: begin
					adc_rx_len <= 10'h0A6;
					eth_tx_len <= 12'h530;
					data_cnt <= 8'h08;
				end
				8'h99: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'h9A: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'h9B: begin
					adc_rx_len <= 10'h126;
					eth_tx_len <= 12'h5BE;
					data_cnt <= 8'h05;
				end
				8'h9C: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'h9D: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'h9E: begin
					adc_rx_len <= 10'h126;
					eth_tx_len <= 12'h5BE;
					data_cnt <= 8'h05;
				end
				8'h9F: begin
					adc_rx_len <= 10'h166;
					eth_tx_len <= 12'h598;
					data_cnt <= 8'h04;
				end
				8'hA0: begin
					adc_rx_len <= 10'h086;
					eth_tx_len <= 12'h53C;
					data_cnt <= 8'h0A;
				end
				8'hA1: begin
					adc_rx_len <= 10'h0A6;
					eth_tx_len <= 12'h530;
					data_cnt <= 8'h08;
				end
				8'hA2: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'hA3: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'hA4: begin
					adc_rx_len <= 10'h0A6;
					eth_tx_len <= 12'h530;
					data_cnt <= 8'h08;
				end
				8'hA5: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'hA6: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'hA7: begin
					adc_rx_len <= 10'h126;
					eth_tx_len <= 12'h5BE;
					data_cnt <= 8'h05;
				end
				8'hA8: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'hA9: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'hAA: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'hAB: begin
					adc_rx_len <= 10'h146;
					eth_tx_len <= 12'h518;
					data_cnt <= 8'h04;
				end
				8'hAC: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'hAD: begin
					adc_rx_len <= 10'h126;
					eth_tx_len <= 12'h5BE;
					data_cnt <= 8'h05;
				end
				8'hAE: begin
					adc_rx_len <= 10'h146;
					eth_tx_len <= 12'h518;
					data_cnt <= 8'h04;
				end
				8'hAF: begin
					adc_rx_len <= 10'h186;
					eth_tx_len <= 12'h492;
					data_cnt <= 8'h03;
				end
				8'hB0: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'hB1: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'hB2: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'hB3: begin
					adc_rx_len <= 10'h146;
					eth_tx_len <= 12'h518;
					data_cnt <= 8'h04;
				end
				8'hB4: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'hB5: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'hB6: begin
					adc_rx_len <= 10'h126;
					eth_tx_len <= 12'h5BE;
					data_cnt <= 8'h05;
				end
				8'hB7: begin
					adc_rx_len <= 10'h166;
					eth_tx_len <= 12'h598;
					data_cnt <= 8'h04;
				end
				8'hB8: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'hB9: begin
					adc_rx_len <= 10'h126;
					eth_tx_len <= 12'h5BE;
					data_cnt <= 8'h05;
				end
				8'hBA: begin
					adc_rx_len <= 10'h146;
					eth_tx_len <= 12'h518;
					data_cnt <= 8'h04;
				end
				8'hBB: begin
					adc_rx_len <= 10'h186;
					eth_tx_len <= 12'h492;
					data_cnt <= 8'h03;
				end
				8'hBC: begin
					adc_rx_len <= 10'h146;
					eth_tx_len <= 12'h518;
					data_cnt <= 8'h04;
				end
				8'hBD: begin
					adc_rx_len <= 10'h166;
					eth_tx_len <= 12'h598;
					data_cnt <= 8'h04;
				end
				8'hBE: begin
					adc_rx_len <= 10'h186;
					eth_tx_len <= 12'h492;
					data_cnt <= 8'h03;
				end
				8'hBF: begin
					adc_rx_len <= 10'h1C6;
					eth_tx_len <= 12'h552;
					data_cnt <= 8'h03;
				end
				8'hC0: begin
					adc_rx_len <= 10'h086;
					eth_tx_len <= 12'h53C;
					data_cnt <= 8'h0A;
				end
				8'hC1: begin
					adc_rx_len <= 10'h0A6;
					eth_tx_len <= 12'h530;
					data_cnt <= 8'h08;
				end
				8'hC2: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'hC3: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'hC4: begin
					adc_rx_len <= 10'h0A6;
					eth_tx_len <= 12'h530;
					data_cnt <= 8'h08;
				end
				8'hC5: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'hC6: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'hC7: begin
					adc_rx_len <= 10'h126;
					eth_tx_len <= 12'h5BE;
					data_cnt <= 8'h05;
				end
				8'hC8: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'hC9: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'hCA: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'hCB: begin
					adc_rx_len <= 10'h146;
					eth_tx_len <= 12'h518;
					data_cnt <= 8'h04;
				end
				8'hCC: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'hCD: begin
					adc_rx_len <= 10'h126;
					eth_tx_len <= 12'h5BE;
					data_cnt <= 8'h05;
				end
				8'hCE: begin
					adc_rx_len <= 10'h146;
					eth_tx_len <= 12'h518;
					data_cnt <= 8'h04;
				end
				8'hCF: begin
					adc_rx_len <= 10'h186;
					eth_tx_len <= 12'h492;
					data_cnt <= 8'h03;
				end
				8'hD0: begin
					adc_rx_len <= 10'h0A6;
					eth_tx_len <= 12'h530;
					data_cnt <= 8'h08;
				end
				8'hD1: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'hD2: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'hD3: begin
					adc_rx_len <= 10'h126;
					eth_tx_len <= 12'h5BE;
					data_cnt <= 8'h05;
				end
				8'hD4: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'hD5: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'hD6: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'hD7: begin
					adc_rx_len <= 10'h146;
					eth_tx_len <= 12'h518;
					data_cnt <= 8'h04;
				end
				8'hD8: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'hD9: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'hDA: begin
					adc_rx_len <= 10'h126;
					eth_tx_len <= 12'h5BE;
					data_cnt <= 8'h05;
				end
				8'hDB: begin
					adc_rx_len <= 10'h166;
					eth_tx_len <= 12'h598;
					data_cnt <= 8'h04;
				end
				8'hDC: begin
					adc_rx_len <= 10'h126;
					eth_tx_len <= 12'h5BE;
					data_cnt <= 8'h05;
				end
				8'hDD: begin
					adc_rx_len <= 10'h146;
					eth_tx_len <= 12'h518;
					data_cnt <= 8'h04;
				end
				8'hDE: begin
					adc_rx_len <= 10'h166;
					eth_tx_len <= 12'h598;
					data_cnt <= 8'h04;
				end
				8'hDF: begin
					adc_rx_len <= 10'h1A6;
					eth_tx_len <= 12'h4F2;
					data_cnt <= 8'h03;
				end
				8'hE0: begin
					adc_rx_len <= 10'h0C6;
					eth_tx_len <= 12'h56A;
					data_cnt <= 8'h07;
				end
				8'hE1: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'hE2: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'hE3: begin
					adc_rx_len <= 10'h146;
					eth_tx_len <= 12'h518;
					data_cnt <= 8'h04;
				end
				8'hE4: begin
					adc_rx_len <= 10'h0E6;
					eth_tx_len <= 12'h564;
					data_cnt <= 8'h06;
				end
				8'hE5: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'hE6: begin
					adc_rx_len <= 10'h126;
					eth_tx_len <= 12'h5BE;
					data_cnt <= 8'h05;
				end
				8'hE7: begin
					adc_rx_len <= 10'h166;
					eth_tx_len <= 12'h598;
					data_cnt <= 8'h04;
				end
				8'hE8: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'hE9: begin
					adc_rx_len <= 10'h126;
					eth_tx_len <= 12'h5BE;
					data_cnt <= 8'h05;
				end
				8'hEA: begin
					adc_rx_len <= 10'h146;
					eth_tx_len <= 12'h518;
					data_cnt <= 8'h04;
				end
				8'hEB: begin
					adc_rx_len <= 10'h186;
					eth_tx_len <= 12'h492;
					data_cnt <= 8'h03;
				end
				8'hEC: begin
					adc_rx_len <= 10'h146;
					eth_tx_len <= 12'h518;
					data_cnt <= 8'h04;
				end
				8'hED: begin
					adc_rx_len <= 10'h166;
					eth_tx_len <= 12'h598;
					data_cnt <= 8'h04;
				end
				8'hEE: begin
					adc_rx_len <= 10'h186;
					eth_tx_len <= 12'h492;
					data_cnt <= 8'h03;
				end
				8'hEF: begin
					adc_rx_len <= 10'h1C6;
					eth_tx_len <= 12'h552;
					data_cnt <= 8'h03;
				end
				8'hF0: begin
					adc_rx_len <= 10'h106;
					eth_tx_len <= 12'h51E;
					data_cnt <= 8'h05;
				end
				8'hF1: begin
					adc_rx_len <= 10'h126;
					eth_tx_len <= 12'h5BE;
					data_cnt <= 8'h05;
				end
				8'hF2: begin
					adc_rx_len <= 10'h146;
					eth_tx_len <= 12'h518;
					data_cnt <= 8'h04;
				end
				8'hF3: begin
					adc_rx_len <= 10'h186;
					eth_tx_len <= 12'h492;
					data_cnt <= 8'h03;
				end
				8'hF4: begin
					adc_rx_len <= 10'h126;
					eth_tx_len <= 12'h5BE;
					data_cnt <= 8'h05;
				end
				8'hF5: begin
					adc_rx_len <= 10'h146;
					eth_tx_len <= 12'h518;
					data_cnt <= 8'h04;
				end
				8'hF6: begin
					adc_rx_len <= 10'h166;
					eth_tx_len <= 12'h598;
					data_cnt <= 8'h04;
				end
				8'hF7: begin
					adc_rx_len <= 10'h1A6;
					eth_tx_len <= 12'h4F2;
					data_cnt <= 8'h03;
				end
				8'hF8: begin
					adc_rx_len <= 10'h146;
					eth_tx_len <= 12'h518;
					data_cnt <= 8'h04;
				end
				8'hF9: begin
					adc_rx_len <= 10'h166;
					eth_tx_len <= 12'h598;
					data_cnt <= 8'h04;
				end
				8'hFA: begin
					adc_rx_len <= 10'h186;
					eth_tx_len <= 12'h492;
					data_cnt <= 8'h03;
				end
				8'hFB: begin
					adc_rx_len <= 10'h1C6;
					eth_tx_len <= 12'h552;
					data_cnt <= 8'h03;
				end
				8'hFC: begin
					adc_rx_len <= 10'h186;
					eth_tx_len <= 12'h492;
					data_cnt <= 8'h03;
				end
				8'hFD: begin
					adc_rx_len <= 10'h1A6;
					eth_tx_len <= 12'h4F2;
					data_cnt <= 8'h03;
				end
				8'hFE: begin
					adc_rx_len <= 10'h1C6;
					eth_tx_len <= 12'h552;
					data_cnt <= 8'h03;
				end
				8'hFF: begin
					adc_rx_len <= 10'h206;
					eth_tx_len <= 12'h40C;
					data_cnt <= 8'h02;
				end
			endcase
        end
        else begin
            adc_rx_len <= adc_rx_len;
            eth_tx_len <= eth_tx_len;
            data_cnt <= data_cnt;
        end
    end

endmodule
