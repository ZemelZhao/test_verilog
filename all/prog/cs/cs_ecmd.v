module cs_ecmd(
    input clk,
    input [7:0] eth_cmd0, 
    input [7:0] eth_cmd1,
    input [7:0] eth_cmd2,
    input [7:0] eth_cmd3,
    input [7:0] eth_cmd4,
    input [7:0] eth_cmd5,
    input [7:0] eth_cmd6,
    input [7:0] eth_cmd7,
    input [7:0] eth_cmd8,

    output [7:0] dev_kind,
    output [7:0] info_sr,

    output [1:0] temps,
    output [7:0] zcheck_adc
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
*/
    wire temp_en, zcheck_en;
    reg [2:0] temps_in;
    reg [7:0] zcheck_adc_in;

    assign temp_en = eth_cmd4[3];
    assign zcheck_en = eth_cmd3[0];

    assign temps = temp_en ?temps_in :2'b00;
    assign zcheck_adc = zcheck_en ?zcheck_adc_in :8'h00;
    assign dev_kind = eth_cmd0;
    assign info_sr = eth_cmd1;






endmodule