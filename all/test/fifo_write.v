module fifo_write
(
    input clk,
    input rst,
    input err,

    input fifo_full,

    output [7:0] fifo_txd,
    output fifo_txen,

    input fs,
    output fd,
    input [11:0] data_len,
    input [7:0] part
);


    wire[7:0] cache_data[127:0];  
    reg [2:0] state, next_state;

    localparam IDLE = 3'h0, PREP = 3'h1;
    localparam WORK = 3'h2, LAST = 3'h3, HEAD = 3'h4;

    reg [11:0] bag_num, fifo_num;
    wire [7:0] data_num;
    assign fd = (state == LAST);
    assign fifo_txen = (state == WORK);
    assign fifo_txd = cache_data[bag_num];
    assign data_num = 8'h00;

    assign cache_data[0] = 8'h55;
    assign cache_data[1] = 8'hAA;
    assign cache_data[2] = part;
    assign cache_data[3] = 8'h03;
    assign cache_data[4] = 8'h04;
    assign cache_data[5] = 8'h05;
    assign cache_data[6] = 8'h06;
    assign cache_data[7] = 8'h07;
    assign cache_data[8] = 8'h08;
    assign cache_data[9] = 8'h09;
    assign cache_data[10] = 8'h0A;
    assign cache_data[11] = 8'h0B;
    assign cache_data[12] = 8'h0C;
    assign cache_data[13] = 8'h0D;
    assign cache_data[14] = 8'h0E;
    assign cache_data[15] = 8'h0F;
    assign cache_data[16] = 8'h10;
    assign cache_data[17] = 8'h11;
    assign cache_data[18] = 8'h12;
    assign cache_data[19] = 8'h13;
    assign cache_data[20] = 8'h14;
    assign cache_data[21] = 8'h15;
    assign cache_data[22] = 8'h16;
    assign cache_data[23] = 8'h17;
    assign cache_data[24] = 8'h18;
    assign cache_data[25] = 8'h19;
    assign cache_data[26] = 8'h1A;
    assign cache_data[27] = 8'h1B;
    assign cache_data[28] = 8'h1C;
    assign cache_data[29] = 8'h1D;
    assign cache_data[30] = 8'h1E;
    assign cache_data[31] = 8'h1F;
    assign cache_data[32] = 8'h20;
    assign cache_data[33] = 8'h21;
    assign cache_data[34] = 8'h22;
    assign cache_data[35] = 8'h23;
    assign cache_data[36] = 8'h24;
    assign cache_data[37] = 8'h25;
    assign cache_data[38] = 8'h26;
    assign cache_data[39] = 8'h27;    
    assign cache_data[40] = 8'h28;
    assign cache_data[41] = 8'h29;
    assign cache_data[42] = 8'h2A;
    assign cache_data[43] = 8'h2B;
    assign cache_data[44] = 8'h2C;
    assign cache_data[45] = 8'h2D;
    assign cache_data[46] = 8'h2E;
    assign cache_data[47] = 8'h2F;
    assign cache_data[48] = 8'h30;
    assign cache_data[49] = 8'h31;
    assign cache_data[50] = 8'h32;
    assign cache_data[51] = 8'h33;
    assign cache_data[52] = 8'h34;
    assign cache_data[53] = 8'h35;
    assign cache_data[54] = 8'h36;
    assign cache_data[55] = 8'h37;
    assign cache_data[56] = 8'h38;
    assign cache_data[57] = 8'h39;
    assign cache_data[58] = 8'h3A;
    assign cache_data[59] = 8'h3B;   
    assign cache_data[60] = 8'h3C;
    assign cache_data[61] = 8'h3D;
    assign cache_data[62] = 8'h3E;
    assign cache_data[63] = 8'h3F;
    assign cache_data[64] = 8'h40;
    assign cache_data[65] = 8'h41;
    assign cache_data[66] = 8'h42;
    assign cache_data[67] = 8'h43;
    assign cache_data[68] = 8'h44;
    assign cache_data[69] = 8'h45;
    assign cache_data[70] = 8'h46;
    assign cache_data[71] = 8'h47;
    assign cache_data[72] = 8'h48;
    assign cache_data[73] = 8'h49;
    assign cache_data[74] = 8'h4A;
    assign cache_data[75] = 8'h4B;
    assign cache_data[76] = 8'h4C;
    assign cache_data[77] = 8'h4D;
    assign cache_data[78] = 8'h4E;
    assign cache_data[79] = 8'h4F;   
    assign cache_data[80] = 8'h50;
    assign cache_data[81] = 8'h51;
    assign cache_data[82] = 8'h52;
    assign cache_data[83] = 8'h53;
    assign cache_data[84] = 8'h54;
    assign cache_data[85] = 8'h55;
    assign cache_data[86] = 8'h56;
    assign cache_data[87] = 8'h57;
    assign cache_data[88] = 8'h58;
    assign cache_data[89] = 8'h59;
    assign cache_data[90] = 8'h5A;
    assign cache_data[91] = 8'h5B;
    assign cache_data[92] = 8'h5C;
    assign cache_data[93] = 8'h5D;
    assign cache_data[94] = 8'h5E;
    assign cache_data[95] = 8'h5F;
    assign cache_data[96] = 8'h60;
    assign cache_data[97] = 8'h61;
    assign cache_data[98] = 8'h62;
    assign cache_data[99] = 8'h63;   
    assign cache_data[100] = 8'h64;
    assign cache_data[101] = 8'h65;
    assign cache_data[102] = 8'h66;
    assign cache_data[103] = 8'h67;
    assign cache_data[104] = 8'h68;
    assign cache_data[105] = 8'h69;
    assign cache_data[106] = 8'h6A;
    assign cache_data[107] = 8'h6B;
    assign cache_data[108] = 8'h6C;
    assign cache_data[109] = 8'h6D;
    assign cache_data[110] = 8'h6E;
    assign cache_data[111] = 8'h6F;
    assign cache_data[112] = 8'h70;
    assign cache_data[113] = 8'h71;
    assign cache_data[114] = 8'h72;
    assign cache_data[115] = 8'h73;
    assign cache_data[116] = 8'h74;
    assign cache_data[117] = 8'h75;
    assign cache_data[118] = 8'h76;
    assign cache_data[119] = 8'h77;   
    assign cache_data[120] = 8'h78;
    assign cache_data[121] = 8'h79;
    assign cache_data[122] = 8'h7A;
    assign cache_data[123] = 8'h7B;
    assign cache_data[124] = 8'h7C;
    assign cache_data[125] = 8'h7D;
    assign cache_data[126] = 8'h7E;
    assign cache_data[127] = 8'h7F;
    

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always @(*) begin
        case (state)
            IDLE: begin
                if(fs) begin
                    next_state <= PREP;
                end
                else begin
                    next_state <= IDLE;
                end
            end
            PREP: begin
                if(~fifo_full) next_state <= HEAD;
                else next_state <= PREP;
            end
            HEAD: begin
                next_state <= WORK;
            end
            WORK: begin
                if(fifo_num == (data_len - 2'h1)) begin
                    next_state <= LAST;
                end
                else next_state <= WORK;
            end
            LAST: begin
                if(~fs) begin
                    next_state <= IDLE;
                end
                else next_state <= LAST;
            end
            default: begin
                next_state <= IDLE;
            end
        endcase
    end


    always @(posedge clk or posedge rst) begin
        if(rst) begin
            fifo_num <= 12'h000;
        end
        else if(state == HEAD) begin
            fifo_num <= 12'h000;
        end
        else if(state == WORK) begin
            fifo_num <= fifo_num + 1'b1;
        end
        else begin
            fifo_num <= 12'h000;
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            bag_num <= data_num;
        end
        else if(state == WORK) begin
            bag_num <= bag_num + 1'b1;
        end
        else if(state == HEAD)begin
            bag_num <= data_num;
        end
        else begin
            bag_num <= data_num;
        end
    end

endmodule
    
