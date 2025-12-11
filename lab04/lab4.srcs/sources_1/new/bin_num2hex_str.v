`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2025 05:54:59 PM
// Design Name: 
// Module Name: bin_num2hex_str
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


module bin_num2hex_str(
    input [10-1 : 0] bin_num_i,

    output [8*4-1 : 0] hex_str_o // 2**10 can be represented using 3 hex digits + 1 null char
);
    assign hex_str_o[8*4-1 -: 8] = bin2hex(bin_num_i[9 : 8]); // top 2 bits
    assign hex_str_o[8*3-1 -: 8] = bin2hex(bin_num_i[7 : 4]); // mid 4 bits
    assign hex_str_o[8*2-1 -: 8] = bin2hex(bin_num_i[3 : 0]); // lower 4 bits
    assign hex_str_o[8*1-1 -: 8] = 0;

    // 4 bits = 1 hex character (8 bits)
    function [8-1 : 0] bin2hex;
        input [4-1 : 0] digit;

        begin
            case (digit)
                0, 1, 2, 3, 4, 5, 6, 7, 8, 9: begin // 0 ~ 9
                    bin2hex = digit + 48;
                end
                10, 11, 12, 13, 14, 15: begin // A ~ F
                    bin2hex = digit + 55;
                end
            endcase
        end
    endfunction
endmodule
