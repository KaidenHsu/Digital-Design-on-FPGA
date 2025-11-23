`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/22/2025 08:37:54 PM
// Design Name: 
// Module Name: tb_golf_headlights_baseball_bat
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


`define CLK_CYCLE 10

module tb_golf_headlights_baseball_bat;
    logic clk, rst_n;
    logic BTNC, BTND, BTNL, BTNR, BTNU;
    logic [8-1 : 0] LD;

    golf_headlights_baseball_bat uut (
        .clk(clk), .rst_n(rst_n),
        .BTNC(BTNC), .BTND(BTND), .BTNL(BTNL), .BTNR(BTNR), .BTNU(BTNU),
        .LD(LD)
    );

    initial begin
        clk = 0;
        forever #(CLK_CYCLE/2) clk = ~clk;
    end

    initial begin
        {BTNC, BTND, BTNL, BTNR, BTNU} = 0;
    end
endmodule
