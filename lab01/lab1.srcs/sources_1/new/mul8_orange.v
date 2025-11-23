`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/16/2025 04:05:32 PM
// Design Name: 
// Module Name: mul8_orange
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


module mul8_orange #(
    parameter WLEN = 8 // word length
) (
    input clk, rst_n,
    input start_i,
    input [WLEN-1 : 0] A_i, B_i,
    output [2*WLEN-1 : 0] product_o,
    output reg done
);
    reg [$clog2(WLEN)-1 : 0] state;
    
    reg [WLEN-1 : 0] A;
    reg [WLEN-1 : 0] hp, lp;

    // state
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= 0;
        else begin
            if (state == 0) begin
                state <= (start_i)? 1 : 0;
            end else begin
                state <= state + 1;
            end
        end
    end

    // A
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) A <= 0;
        else if (state == 0 && start_i) A <= A_i;
    end

    // hp, lp
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) {hp, lp} <= 0;
        else if (state == 0) begin
            if (start_i) begin
                if (B_i[0]) {hp, lp} <= {1'b0, A_i, B_i[WLEN-1 : 1]};
                else {hp, lp} <=  B_i[WLEN-1 : 1];
            end
        end else begin
            if (!lp[0]) {hp, lp} <= {hp, lp} >> 1; // right shift
            else begin // add and right shift
                {hp, lp[WLEN-1]} <= hp + A;
                lp[WLEN - 2 : 0] <= lp[WLEN - 1 : 1];
            end
        end
    end

    // done
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) done <= 0;
        else done <= (state == (WLEN - 1));
    end

    assign product_o = {hp, lp};
endmodule
