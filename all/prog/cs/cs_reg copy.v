module cs_reg( // TEST_DONE
    input [7:0] eth_cmd0,
    input [7:0] eth_cmd1,
    input [7:0] eth_cmd2, // [7:4] UPPER_BW [3:0] LOWER_BW
    input [7:0] eth_cmd3, // [7:4] ADC_OPT  3 DataCode      [2:1] Din     0 T/N
    input [7:0] eth_cmd4, // 7 Power_Sensor [5:4] Dout      3 Temp_Sensor
    input [7:0] eth_cmd5,
    input [7:0] eth_cmd6,
    input [7:0] eth_cmd7,
    input [7:0] eth_cmd8, // [7:4] ID       [3:2] HP Filter 1 Grp

    input [1:0] temps,
    input [7:0] zchk_adc,
    input [1:0] zchk_scale,

    output [7:0] reg00,
    output [7:0] reg01,
    output [7:0] reg02,
    output [7:0] reg03,
    output [7:0] reg04,
    output [7:0] reg05,
    output [7:0] reg06,
    output [7:0] reg07,
    output [7:0] reg08,
    output [7:0] reg09,
    output [7:0] reg10,
    output [7:0] reg11,
    output [7:0] reg12,
    output [7:0] reg13,
    output [7:0] regap, // Individual Amplifier Power

    output [3:0] dev_id,
    output dev_grp,
    output [7:0] dev_kind, 
    output [7:0] info_sr
);
/*              7       6       5       4       3       2       1       0    
    eth_cmd0[     DEV0      ][     DEV1     ][     DEV2     ][     DEV3     ]
    eth_cmd1[                     SAMPLING FREQUENCY                        ]
    eth_cmd2[           UPPER_BW            ][          LOWER_BW            ]
    eth_cmd3[           ADC_OPT             ][D_CODE][      DIN     ][ T/N  ]
    eth_cmd4[POWER_S][   0  ][     DOUT     ][TEMP_S][  1   ][   0  ][   1  ]
    eth_cmd5[                           Z_CHECK0                            ]  
    eth_cmd6[                           Z_CHECK1                            ]  
    eth_cmd7[                           Z_CHECK2                            ]  
    eth_cmd8[           DEV_ID              ][  DSP_OFFSET  ][ GROUP][   1  ]

    UPPER_BW   REG8    REG9    REGA    REGB
    00: 100Hz    0x26    0x1A    0x05    0x1F
    01: 150Hz    0x2C    0x11    0x08    0x15
    02: 200Hz    0x18    0x0D    0x07    0x10
    03: 250Hz    0x2A    0x0A    0x05    0x0D
    04: 300Hz    0x06    0x09    0x02    0x0B
    05: 500Hz    0x1E    0x05    0x2B    0x06
    06: 750Hz    0x29    0x03    0x24    0x04
    07: 1.0kHz   0x2E    0x02    0x1E    0x03
    08: 1.5kHz   0x01    0x02    0x17    0x02
    09: 2.0kHz   0x1B    0x01    0x2C    0x01
    0A: 2.5kHz   0x0D    0x01    0x19    0x01
    0B: 3.0kHz   0x03    0x01    0x0D    0x01
    0C: 5.0kHz   0x21    0x00    0x25    0x00
    0D: 7.5kHz   0x16    0x00    0x17    0x00
    0E: 10kHz    0x11    0x00    0x10    0x00
    0F: 15kHz    0x0B    0x00    0x08    0x00

    LOWER_BW   REGC    REGD
    00: 0.25Hz   0x38    0x36
    01: 0.50Hz   0x23    0x11
    02: 1.0Hz    0x2C    0x06
    03: 2.0Hz    0x08    0x03
    04: 2.5Hz    0x2A    0x02
    05: 3.0Hz    0x14    0x02
    06: 5.0Hz    0x28    0x01
    07: 7.5Hz    0x12    0x01
    08: 10Hz     0x05    0x01
    09: 15Hz     0x3E    0x00
    0A: 20Hz     0x36    0x00
    0B: 50Hz     0x22    0x00
    0C: 100Hz    0x19    0x00
    0D: 200Hz    0x12    0x00
    0E: 300Hz    0x0F    0x00
    0F: 500Hz    0x0D    0x00

    ADC_OPT    ADCB    MUXB
    0: 120kS/s   0x20    0x28
    1: 140kS/s   0x10    0x28
    2: 175KS/s   0x08    0x28
    3: 220kS/s   0x08    0x20
    4: 280kS/s   0x08    0x1A
    5: 350kS/s   0x04    0x12
    6: 440kS/s   0x03    0x10
    7: 525kS/s   0x03    0x07
    8: 700kS/s   0x02    0x04

    DSP cutoff      DSP[3:0]
    0x              0x00
    10              0x0A
    11              0x07
*/  

    wire [3:0] upper_bw, lower_bw;
    wire [1:0] dout, dsp, din;
    wire vdden, tempen, zchken;
    wire dcode;
    wire [3:0] adc_opt;

    reg [2:0] adc_adin;

    reg [5:0] adc_bias, mux_bias;
    reg [5:0] rh1_dac1, rh2_dac1;
    reg [4:0] rh1_dac2, rh2_dac2;
    reg [6:0] rl_dac1, rl_dac2;

    reg dspen;
    reg [3:0] dspf;

    assign dev_kind = eth_cmd0;
    assign info_sr = eth_cmd1;
    
    assign upper_bw = eth_cmd2[7:4];
    assign lower_bw = eth_cmd2[3:0];
    assign adc_opt = eth_cmd3[7:4];
    assign dcode = eth_cmd3[3];
    assign din = eth_cmd3[2:1];
    assign zchken = eth_cmd3[0];
    assign vdden = eth_cmd4[7];
    assign dout = eth_cmd4[5:4];
    assign tempen = eth_cmd4[3];
    assign dev_id = eth_cmd8[7:4];
    assign dsp = eth_cmd8[3:2];
    assign dev_grp = eth_cmd8[1];

    always@(*) begin // ADC_BIAS & MUX_BIAS
        case(adc_opt)
            4'h0: begin
                adc_bias <= 6'h20;
                mux_bias <= 6'h28;
            end
            4'h1: begin
                adc_bias <= 6'h10;
                mux_bias <= 6'h28;
            end
            4'h2: begin
                adc_bias <= 6'h08;
                mux_bias <= 6'h28;
            end
            4'h3: begin
                adc_bias <= 6'h08;
                mux_bias <= 6'h20;
            end
            4'h4: begin
                adc_bias <= 6'h08;
                mux_bias <= 6'h1A;
            end
            4'h5: begin
                adc_bias <= 6'h04;
                mux_bias <= 6'h12;
            end
            4'h6: begin
                adc_bias <= 6'h03;
                mux_bias <= 6'h10;
            end
            4'h7: begin
                adc_bias <= 6'h03;
                mux_bias <= 6'h07;
            end
            4'h8: begin
                adc_bias <= 6'h02;
                mux_bias <= 6'h04;
            end
            default: begin
                adc_bias <= 6'h02;
                mux_bias <= 6'h04;
            end
        endcase
    end

    always@(*) begin // RH1_DAC1 & RH1_DAC2 & RH2_DAC1 & RH2_DAC2
        case(upper_bw) 
            4'h0: begin
                rh1_dac1 <= 6'h26;
                rh1_dac2 <= 5'h1A;
                rh2_dac1 <= 6'h05;
                rh2_dac2 <= 5'h1F;
            end
            4'h1: begin
                rh1_dac1 <= 6'h2C;
                rh1_dac2 <= 5'h11;
                rh2_dac1 <= 6'h08;
                rh2_dac2 <= 5'h15;
            end
            4'h2: begin
                rh1_dac1 <= 6'h18;
                rh1_dac2 <= 5'h0D;
                rh2_dac1 <= 6'h07;
                rh2_dac2 <= 5'h10;
            end
            4'h3: begin
                rh1_dac1 <= 6'h2A;
                rh1_dac2 <= 5'h0A;
                rh2_dac1 <= 6'h05;
                rh2_dac2 <= 5'h0D;
            end
            4'h4: begin
                rh1_dac1 <= 6'h06;
                rh1_dac2 <= 5'h09;
                rh2_dac1 <= 6'h02;
                rh2_dac2 <= 5'h0B;
            end
            4'h5: begin
                rh1_dac1 <= 6'h1E;
                rh1_dac2 <= 5'h05;
                rh2_dac1 <= 6'h2B;
                rh2_dac2 <= 5'h06;
            end
            4'h6: begin
                rh1_dac1 <= 6'h29;
                rh1_dac2 <= 5'h03;
                rh2_dac1 <= 6'h24;
                rh2_dac2 <= 5'h04;
            end
            4'h7: begin
                rh1_dac1 <= 6'h2E;
                rh1_dac2 <= 5'h02;
                rh2_dac1 <= 6'h1E;
                rh2_dac2 <= 5'h03;
            end
            4'h8: begin
                rh1_dac1 <= 6'h01;
                rh1_dac2 <= 5'h02;
                rh2_dac1 <= 6'h17;
                rh2_dac2 <= 5'h02;
            end
            4'h9: begin
                rh1_dac1 <= 6'h1B;
                rh1_dac2 <= 5'h01;
                rh2_dac1 <= 6'h2C;
                rh2_dac2 <= 5'h01;
            end
            4'hA: begin
                rh1_dac1 <= 6'h0D;
                rh1_dac2 <= 5'h01;
                rh2_dac1 <= 6'h19;
                rh2_dac2 <= 5'h01;
            end
            4'hB: begin
                rh1_dac1 <= 6'h03;
                rh1_dac2 <= 5'h01;
                rh2_dac1 <= 6'h0D;
                rh2_dac2 <= 5'h01;
            end
            4'hC: begin
                rh1_dac1 <= 6'h21;
                rh1_dac2 <= 5'h00;
                rh2_dac1 <= 6'h25;
                rh2_dac2 <= 5'h00;
            end
            4'hD: begin
                rh1_dac1 <= 6'h16;
                rh1_dac2 <= 5'h00;
                rh2_dac1 <= 6'h17;
                rh2_dac2 <= 5'h00;
            end
            4'hE: begin
                rh1_dac1 <= 6'h11;
                rh1_dac2 <= 5'h00;
                rh2_dac1 <= 6'h10;
                rh2_dac2 <= 5'h00;
            end
            4'hF: begin
                rh1_dac1 <= 6'h0B;
                rh1_dac2 <= 5'h00;
                rh2_dac1 <= 6'h08;
                rh2_dac2 <= 5'h00;
            end
            default: begin
                rh1_dac1 <= 6'h0B;
                rh1_dac2 <= 5'h00;
                rh2_dac1 <= 6'h08;
                rh2_dac2 <= 5'h00;
            end
        endcase
    end

    always@(*) begin // RL_DAC1 & RL_DAC2
        case(lower_bw)
            4'h0: begin
                rl_dac1 <= 7'h38;
                rl_dac2 <= 7'h36;
            end
            4'h1: begin
                rl_dac1 <= 7'h23;
                rl_dac2 <= 7'h11;
            end
            4'h2: begin
                rl_dac1 <= 7'h2C;
                rl_dac2 <= 7'h06;
            end
            4'h3: begin
                rl_dac1 <= 7'h08;
                rl_dac2 <= 7'h03;
            end
            4'h4: begin
                rl_dac1 <= 7'h2A;
                rl_dac2 <= 7'h02;
            end
            4'h5: begin
                rl_dac1 <= 7'h14;
                rl_dac2 <= 7'h02;
            end
            4'h6: begin
                rl_dac1 <= 7'h28;
                rl_dac2 <= 7'h01;
            end
            4'h7: begin
                rl_dac1 <= 7'h12;
                rl_dac2 <= 7'h01;
            end
            4'h8: begin
                rl_dac1 <= 7'h05;
                rl_dac2 <= 7'h01;
            end
            4'h9: begin
                rl_dac1 <= 7'h3E;
                rl_dac2 <= 7'h00;
            end
            4'hA: begin
                rl_dac1 <= 7'h36;
                rl_dac2 <= 7'h00;
            end
            4'hB: begin
                rl_dac1 <= 7'h22;
                rl_dac2 <= 7'h00;
            end
            4'hC: begin
                rl_dac1 <= 7'h19;
                rl_dac2 <= 7'h00;
            end
            4'hD: begin
                rl_dac1 <= 7'h12;
                rl_dac2 <= 7'h00;
            end
            4'hE: begin
                rl_dac1 <= 7'h0F;
                rl_dac2 <= 7'h00;
            end
            4'hF: begin
                rl_dac1 <= 7'h0D;
                rl_dac2 <= 7'h00;
            end
        endcase
    end

    always@(*) begin // DSPen & DSP cutoff freq
        case(dsp)
            2'b00: begin
                dspen <= 1'b0;
                dspf <= 4'h7;
            end
            2'b01: begin
                dspen <= 1'b0;
                dspf <= 4'h7;
            end
            2'b10: begin
                dspen <= 1'b1;
                dspf <= 4'hA;
            end
            2'b11: begin
                dspen <= 1'b1;
                dspf <= 4'h7;
            end
            default: begin
                dspen <= 1'b0;
                dspf <= 4'h7;                
            end
        endcase
    end

    always@(*) begin // ADC_ADIN
        case(din) 
            2'b00: adc_adin <= 3'b000;
            2'b01: adc_adin <= 3'b001;
            2'b10: adc_adin <= 3'b011;
            2'b11: adc_adin <= 3'b111;
            default: adc_adin <= 3'b000;
        endcase
    end

    assign reg00 = 8'b11011110;
    assign reg01 = {1'b0, vdden, adc_bias};
    assign reg02 = {2'b00, mux_bias};
    assign reg03 = {3'b000, temps, tempen, dout};
    assign reg04 = {1'b0, dcode, 1'b0, dspen, dspf};

    assign reg05 = zchken ?{3'b011, zchk_scale, 3'b001} :8'h00;
    assign reg06 = zchken ?zchk_adc :8'h00;
    assign reg07 = zchken ?8'h00 :8'h00;

    assign reg08 = {2'b00, rh1_dac1};
    assign reg09 = {adc_adin[0], 2'b00, rh1_dac2};
    assign reg10 = {2'b00, rh2_dac1};
    assign reg11 = {adc_adin[1], 2'b00, rh2_dac2};
    assign reg12 = {1'b0, rl_dac1};
    assign reg13 = {adc_adin[2], rl_dac2};
    assign regap = 8'b1111_1111;
    assign dev_id = eth_cmd8[7:4];
    assign dev_grp = eth_cmd8[1];

endmodule