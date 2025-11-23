`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/16/2025 11:49:44 PM
// Design Name: 
// Module Name: mmult_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "mmult_define.vh"

`define CLK_CYCLE 10 // 100MHz clock generator

`define G00 golden[0*17 +: 17]
`define G01 golden[1*17 +: 17]
`define G02 golden[2*17 +: 17]
`define G10 golden[3*17 +: 17]
`define G11 golden[4*17 +: 17]
`define G12 golden[5*17 +: 17]
`define G20 golden[6*17 +: 17]
`define G21 golden[7*17 +: 17]
`define G22 golden[8*17 +: 17]

module mmult_tb;
    reg clk = 1;
    reg reset_n = 1;

    reg  [0:9*8-1]  A, B;   // 3x3 matrices
    wire [0:9*17-1] C;
    reg [0:9*17-1] golden;
    reg  enable;
    wire valid;
    reg [3-1 : 0] Q;

    integer idx;
    real total_cycle;

    always #(`CLK_CYCLE/2) clk = ~clk;

    // mmult_mux uut(
    //     .clk(clk), .reset_n(reset_n),
    //     .enable(enable),
    //     .A_mat(A), .B_mat(B),
    //     .C_mat(C),
    //     .valid(valid)
    // );

    mmult_shiftreg uut(
        .clk(clk), .reset_n(reset_n),
        .enable(enable),
        .A_mat(A), .B_mat(B),
        .C_mat(C),
        .valid(valid)
    );

    always @(posedge clk, negedge reset_n) begin
        if (!reset_n) Q <= 0;
        if (enable) Q <= 0;
        else Q <= Q + 1;
    end

    initial begin
        total_cycle = 0;
        A = 0;
        B = 0;
        enable = 0;
        golden = 0;

        force clk = 0;
        #(2*`CLK_CYCLE);
        reset_n = 0;
        #(2*`CLK_CYCLE);
        reset_n = 1;
        #(2*`CLK_CYCLE);
        release clk;
        #(2*`CLK_CYCLE);

        @(posedge clk);

        repeat (5) begin
            @(negedge clk);
            enable = 1;

            // generate inputs A, B randomly
            `A00 = $random%(2**8);
            `A01 = $random%(2**8);
            `A02 = $random%(2**8);
            `A10 = $random%(2**8);
            `A11 = $random%(2**8);
            `A12 = $random%(2**8);
            `A20 = $random%(2**8);
            `A21 = $random%(2**8);
            `A22 = $random%(2**8);

            `B00 = $random%(2**8);
            `B01 = $random%(2**8);
            `B02 = $random%(2**8);
            `B10 = $random%(2**8);
            `B11 = $random%(2**8);
            `B12 = $random%(2**8);
            `B20 = $random%(2**8);
            `B21 = $random%(2**8);
            `B22 = $random%(2**8);

            A = {`A00, `A01, `A02, `A10, `A11, `A12, `A20, `A21, `A22};
            B = {`B00, `B01, `B02, `B10, `B11, `B12, `B20, `B21, `B22};

            // print A, B
            $display ("\n[%t] Matrix A is:\n", $time);

            for (idx = 0; idx < 9; idx = idx+1) begin
                $write (" %d ", A[idx*8 +: 8]);
                if (idx%3 == 2) $write("\n");
            end

            $display ("\n[%t] Matrix B is:\n", $time);

            for (idx = 0; idx < 9; idx = idx+1) begin
                $write (" %d ", B[idx*8 +: 8]);
                if (idx%3 == 2) $write("\n");
            end

            $write("\n");

            // calculate golden
            `G00 = `A00*`B00 + `A01*`B10 + `A02*`B20;
            `G10 = `A10*`B00 + `A11*`B10 + `A12*`B20;
            `G20 = `A20*`B00 + `A21*`B10 + `A22*`B20;
        
            `G01 = `A00*`B01 + `A01*`B11 + `A02*`B21;
            `G11 = `A10*`B01 + `A11*`B11 + `A12*`B21;
            `G21 = `A20*`B01 + `A21*`B11 + `A22*`B21;
        
            `G02 = `A00*`B02 + `A01*`B12 + `A02*`B22;
            `G12 = `A10*`B02 + `A11*`B12 + `A12*`B22;
            `G22 = `A20*`B02 + `A21*`B12 + `A22*`B22;

            golden = {`G00, `G01, `G02, `G10, `G11, `G12, `G20, `G21, `G22};

            // invalidate inputs
            @(negedge clk);
            A = 0;
            B = 0;
            enable = 0;

            // print answer
            @(valid);
            total_cycle = total_cycle + Q;

            $display ("\n[%t] The result of C = A x B is:\n", $time);

            for (idx = 0; idx < 9; idx = idx+1) begin
                $write (" %d ", C[idx*17 +: 17]);
                if (idx%3 == 2) $write("\n");
            end

            // check answer
            if (C !== golden) begin
                $display ("\n[%t] Wrong Answer! golden = \n", $time);

                for (idx = 0; idx < 9; idx = idx+1) begin
                    $write (" %d ", golden[idx*17 +: 17]);
                    if (idx%3 == 2) $write("\n");
                end
                $write("\n");

                #10 $finish;
            end
        end

        $display("All test cases passed!");
        $display("Average cycle = %d", total_cycle/5);
        #10 $finish;
    end
endmodule
