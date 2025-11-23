`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2025 07:18:05 PM
// Design Name: 
// Module Name: brightness_pulser
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

module brightness_pulser(
    input clk, rst_n,
    input btn_i,
    output reg bp_o
);
    localparam S_IDLE = 0;
    localparam S_ACTIVE = 1;

    reg [2-1 : 0] state, n_state;

    reg [$clog2(`SECOND)-1 : 0] Q;

    // state
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

    // counter
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) Q <= 0;
        else begin
            case (state)
                S_ACTIVE: Q <= Q + 1;
            endcase
        end
    end

    // output
    always @* begin
        bp_o = 0;

        case (state)
            S_IDLE: bp_o = btn_i;
            S_ACTIVE: if (Q == 1) bp_o = 1;
        endcase
    end
endmodule
