`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2025 05:41:02 PM
// Design Name: 
// Module Name: gcd_rec
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: computing gcd using recursion
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: this version does not synthesize! Whether automatic functions work needs further verification.
// 
//////////////////////////////////////////////////////////////////////////////////


`define MAX_BIT 10

module gcd_rec(
    input [`MAX_BIT-1 : 0] a_i, b_i,

    output [8*4-1 : 0] ans_o
);
    assign ans_o = gcd_rec(a_i, b_i);

    // Use recursion with the automatic keyword only.
    // The number of recursions is automatically limited to prevent endless recursive calls. The default is 64.
    // Use -recursion_iteration_limit to set the number of allowed recursive calls.
    function automatic [`MAX_BIT-1 : 0] gcd_rec;
        input [`MAX_BIT-1 : 0] a, b;

        begin
            if (b == 0) gcd_rec = a;
            else gcd_rec = gcd_rec(b, a%b);
        end
    endfunction
endmodule
