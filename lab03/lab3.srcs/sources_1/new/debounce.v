`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/22/2025 03:35:56 PM
// Design Name: 
// Module Name: debounce
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


`define BOUNCING_WINDOW 10_000_000 // 0.1s

module debounce(
    input clk, rst_n,
    input btn_i,
    output db_o
);
    localparam ZERO = 0;
    localparam ZERO_TO_ONE = 1;
    localparam ONE = 2;
    localparam ONE_TO_ZERO = 3;

    reg [2-1 : 0] state, n_state;

    reg [$clog2(`BOUNCING_WINDOW) : 0] counter;

    // state
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) state <= ZERO;
        else state <= n_state;
    end

    wire debounce_counter_expire = (counter >= `BOUNCING_WINDOW);

    always @* begin
        case (state)
            ZERO: n_state = (btn_i)? ZERO_TO_ONE : ZERO;
            ZERO_TO_ONE: n_state = (debounce_counter_expire)? ONE : ZERO_TO_ONE;
            ONE: n_state = (!btn_i)? ONE_TO_ZERO : ONE;
            ONE_TO_ZERO: n_state = (debounce_counter_expire)? ZERO : ONE_TO_ZERO;
        endcase
    end

    // counter
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) counter <= 0;
        else begin
            case (state)
                ZERO, ONE: counter <= 0;
                ZERO_TO_ONE, ONE_TO_ZERO: counter <= counter + 1;
            endcase
        end
    end

    assign db_o = (state == ZERO_TO_ONE || state == ONE);
endmodule
