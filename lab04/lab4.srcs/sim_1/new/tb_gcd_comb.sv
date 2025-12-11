`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2025 05:00:27 PM
// Design Name: 
// Module Name: tb_gcd_comb
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

module tb_gcd_comb();
    logic [`MAX_BIT-1 : 0] a, b;
    logic [`MAX_BIT-1 : 0] ans;

    gcd_rec uut (
        .a_i(a), .b_i(b),
        .ans_o(ans)
    );

    initial begin
        repeat(`TEST_CASES) begin
            #10
            a = $random % (2**`MAX_BIT-1);
            b = $random % (2**`MAX_BIT-1);

            $display("a = %d, b = %d", a, b);
            $display("ans = %d", ans);
            $display("----------------");
        end

        #10 $finish;
    end
endmodule
