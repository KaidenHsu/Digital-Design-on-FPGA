`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2025 05:06:28 PM
// Design Name: 
// Module Name: tb_gcd_seq
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


`define MAX_BIT 10
`define TEST_CASES 5
`define CLK_CYCLE 10

module tb_gcd_seq();
    logic clk, rst_n;
    logic start;
    logic [`MAX_BIT-1 : 0] a, b;
    logic [`MAX_BIT-1 : 0] ans;
    logic valid;

    gcd_seq uut (
        .clk(clk), .rst_n(rst_n),

        .start_i(start),
        .a_i(a), .b_i(b),

        .ans_o(ans),
        .valid_o(valid)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        start = 0;
        a = 0;
        b = 0;

        rst_n = 1;
        #(2*`CLK_CYCLE);
        rst_n = 0;
        #(2*`CLK_CYCLE);
        rst_n = 1;

        @(posedge clk);
        @(posedge clk);
        @(negedge clk);

        repeat (`TEST_CASES) begin
            start =1;
            a = $random % 100;
            b = $random % 100;
            $display("[%t] a = %d, b = %d", $time, a, b);

            @(negedge clk);
            start = 0;
            a = 0;
            b = 0;

            @(valid);
            @(negedge clk);
            $display("[%t] ans = %d", $time, ans);
            $display("----------------");
            @(negedge clk);
        end

        #10 $finish;
    end
endmodule
