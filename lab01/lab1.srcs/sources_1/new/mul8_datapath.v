module mul8_datapath(
    input clk, rst_n,
    input [8-1 : 0] A_i, B_i,
    input load_i, add_i, shift_i, // control signals
    output [16-1 : 0] product_o,
    output M0_o // status signals
);
    // registers
    reg [17-1 : 0] M;
    assign product_o = M[16-1 : 0];
    assign M0_o = M[0];

    reg [8-1 : 0] mcand;

    // M
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) M <= 0;
        else begin
            if (load_i) M <= {9'b0, A_i};
            else if (add_i) M <= M + {mcand, 8'b0};
            else if (shift_i) M <= M >> 1;
        end
    end

    // mcand
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) mcand <= 0;
        else begin
            if (load_i) mcand <= B_i;
        end
    end
endmodule
