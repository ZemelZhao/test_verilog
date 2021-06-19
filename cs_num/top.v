module asm();

    reg a, b, c;
    reg [3:0] state; 
    wire d;
    wire clk, rst, rst_n;

    assign d = ~|{a, b, c};
    assign rst = ~rst_n;

    always@(posedge clk or posedge rst) begin
        if(rst) state <= 4'h0;
        else begin
            case(state)
                4'h0: begin
                    state <= state + 1'b1;
                    a <= 1'b0; 
                    b <= 1'b0; 
                    c <= 1'b0;
                end
                4'h1: begin
                    state <= state + 1'b1;
                    a <= 1'b0; 
                    b <= 1'b0; 
                    c <= 1'b1;
                end
                4'h2: begin
                    state <= state + 1'b1;
                    a <= 1'b0; 
                    b <= 1'b1; 
                    c <= 1'b0;
                end
                4'h3: begin
                    state <= state + 1'b1;
                    a <= 1'b0; 
                    b <= 1'b1; 
                    c <= 1'b1;
                end
                4'h4: begin
                    state <= state + 1'b1;
                    a <= 1'b1; 
                    b <= 1'b0; 
                    c <= 1'b0;
                end
                4'h5: begin
                    state <= state + 1'b1;
                    a <= 1'b1; 
                    b <= 1'b0; 
                    c <= 1'b1;
                end
                4'h6: begin
                    state <= state + 1'b1;
                    a <= 1'b1; 
                    b <= 1'b1; 
                    c <= 1'b0;
                end
                4'h7: begin
                    state <= state + 1'b1;
                    a <= 1'b1; 
                    b <= 1'b1; 
                    c <= 1'b1;
                end
                4'h8: state <= 4'h8;
                default: state <= 4'h0;
            endcase
        end
    end

    clk_asm
    clk_asm_dut(
        .axi_clk_0(clk),
        .axi_rst_0_n(rst_n)
    );


endmodule