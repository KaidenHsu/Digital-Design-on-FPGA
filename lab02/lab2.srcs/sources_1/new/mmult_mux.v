`include "mmult_define.vh"

`define C00 C_mat[0*17 +: 17]
`define C01 C_mat[1*17 +: 17]
`define C02 C_mat[2*17 +: 17]
`define C10 C_mat[3*17 +: 17]
`define C11 C_mat[4*17 +: 17]
`define C12 C_mat[5*17 +: 17]
`define C20 C_mat[6*17 +: 17]
`define C21 C_mat[7*17 +: 17]
`define C22 C_mat[8*17 +: 17]

module mmult_mux(
    input clk, reset_n,
    input enable,
    input [0 : 9*8-1] A_mat, B_mat,
    output reg [0 : 9*17-1] C_mat,
    output reg valid
);
    reg [0 : 9*8-1] A, B;
    reg [3-1 : 0] state;

    wire [17-1 : 0] rows [3-1 : 0];
    reg [8-1 : 0] operands [3-1 : 0][6-1 : 0];

    integer i;

    // state
    always @(posedge clk, negedge reset_n) begin
        if (!reset_n) state <= 0;
        else if (state == 0) state <= (enable)? 1 : 0;
        else if (enable) state <= 1;
        else state <= state + 1;
    end

    // A
    always @(posedge clk, negedge reset_n) begin
        if (!reset_n) A <= 0;
        else if (enable) A <= A_mat;
    end

    // B
    always @(posedge clk, negedge reset_n) begin
        if (!reset_n) B <= 0;
        else if (enable) B <= B_mat;
    end

    // C_mat
    always @(posedge clk, negedge reset_n) begin
        if (!reset_n) C_mat <= 0;
        else if (enable) C_mat <= 0;
        else begin
            case (state)
                1: begin
                    `C00 <= rows[0];
                    `C10 <= rows[1];
                    `C20 <= rows[2];
                end
                2: begin
                    `C01 <= rows[0];
                    `C11 <= rows[1];
                    `C21 <= rows[2];
                end
                3: begin
                    `C02 <= rows[0];
                    `C12 <= rows[1];
                    `C22 <= rows[2];
                end
            endcase
        end
    end

    // 9 multipliers in total
    // `C00 <= `A00*`B00 + `A01*`B10 + `A02*`B20;
    // `C10 <= `A10*`B00 + `A11*`B10 + `A12*`B20;
    // `C20 <= `A20*`B00 + `A21*`B10 + `A22*`B20;

    // `C01 <= `A00*`B01 + `A01*`B11 + `A02*`B21;
    // `C11 <= `A10*`B01 + `A11*`B11 + `A12*`B21;
    // `C21 <= `A20*`B01 + `A21*`B11 + `A22*`B21;

    // `C02 <= `A00*`B02 + `A01*`B12 + `A02*`B22;
    // `C12 <= `A10*`B02 + `A11*`B12 + `A12*`B22;
    // `C22 <= `A20*`B02 + `A21*`B12 + `A22*`B22;
    assign rows[0] = operands[0][0]*operands[0][1] + operands[0][2]*operands[0][3] + operands[0][4]*operands[0][5];
    assign rows[1] = operands[1][0]*operands[1][1] + operands[1][2]*operands[1][3] + operands[1][4]*operands[1][5];
    assign rows[2] = operands[2][0]*operands[2][1] + operands[2][2]*operands[2][3] + operands[2][4]*operands[2][5];

    // operands
    always @* begin
        operands[0][0] = `A00;
        operands[1][0] = `A10;
        operands[2][0] = `A20;
        operands[0][2] = `A01;
        operands[1][2] = `A11;
        operands[2][2] = `A21;
        operands[0][4] = `A02;
        operands[1][4] = `A12;
        operands[2][4] = `A22;

        case (state)
            1: begin
                operands[0][1] = `B00;
                operands[1][1] = `B00;
                operands[2][1] = `B00;
                operands[0][3] = `B10;
                operands[1][3] = `B10;
                operands[2][3] = `B10;
                operands[0][5] = `B20;
                operands[1][5] = `B20;
                operands[2][5] = `B20;
            end
            2: begin
                operands[0][1] = `B01;
                operands[1][1] = `B01;
                operands[2][1] = `B01;
                operands[0][3] = `B11;
                operands[1][3] = `B11;
                operands[2][3] = `B11;
                operands[0][5] = `B21;
                operands[1][5] = `B21;
                operands[2][5] = `B21;
            end
            3: begin
                operands[0][1] = `B02;
                operands[1][1] = `B02;
                operands[2][1] = `B02;
                operands[0][3] = `B12;
                operands[1][3] = `B12;
                operands[2][3] = `B12;
                operands[0][5] = `B22;
                operands[1][5] = `B22;
                operands[2][5] = `B22;
            end
        endcase
    end

    // valid
    always @* begin
        valid = 0;

        case (state)
            4: valid = 1;
        endcase
    end
endmodule
