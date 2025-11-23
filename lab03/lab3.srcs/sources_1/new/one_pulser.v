`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2025 04:16:56 PM
// Design Name: 
// Module Name: one_pulser
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


`define SECOND 100_000_000

module one_pulser(
    input clk, rst_n,
    input btn_i,
    output reg op_o
);
    localparam S_IDLE = 0;
    localparam S_ACTIVE = 1;

    reg [2-1 : 0] state, n_state;

    reg [$clog2(`SECOND)-1 : 0] Q;

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) state <= S_IDLE;
        else state <= n_state;
    end

    always @* begin
        n_state = S_IDLE;

        case (state)
            S_IDLE: n_state = (btn_i)? S_ACTIVE : S_IDLE;
            S_ACTIVE: n_state = (!btn_i)? S_IDLE : S_ACTIVE;
        endcase
    end

    always @* begin
        op_o = 0;

        case (state)
            S_IDLE: op_o = btn_i;
            S_ACTIVE: if (Q == 1) op_o = 1;
        endcase
    end

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) Q <= 0;
        else begin
            case (state)
                S_ACTIVE: Q <= Q + 1;
            endcase
        end
    end
endmodule
