`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2025 11:54:43 PM
// Design Name: 
// Module Name: tb_dec_str2bin_num
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


module tb_dec_str2bin_num();
    logic clk, rst_n;

    logic start_i;
    logic received_i;
    logic enter_pressed_i;
    logic [8-1 : 0] dec_str_i;

    logic [`NUM_WIDTH-1 : 0] number_o;
    logic valid_o;

    dec_str2bin_num uut (
        .clk(clk), .rst_n(rst_n),

        .start_i(start),
        .received_i(received),
        .enter_pressed_i(enter_pressed),
        .dec_str_i(dec_str),

        .number_o(number),
        .valid_o(valid)
    );
endmodule
