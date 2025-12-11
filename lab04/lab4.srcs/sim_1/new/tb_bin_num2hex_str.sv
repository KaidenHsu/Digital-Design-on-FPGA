`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2025 06:42:49 PM
// Design Name: 
// Module Name: tb_bin_num2hex_str
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


`define TEST_CASES 5

module tb_bin_num2hex_str();
    logic [10-1 : 0] bin_num;
    logic [8*4-1 : 0] hex_str; // 2**10 can be represented using 3 hex digits + 1 null char

    bin_num2hex_str uut (
        .bin_num_i(bin_num),

        .hex_str_o(hex_str)
    );

    int i;
    initial begin
        for (i = 0; i < `TEST_CASES; i++) begin
            #10
            bin_num = $random;

            #10
            $display("[%0t] test case #%0d", $time, i);
            $display("input = 0x%H", {2'b0, bin_num});
            $display("output = 0x%s", hex_str);
        end

        #10 $finish;
    end
endmodule
