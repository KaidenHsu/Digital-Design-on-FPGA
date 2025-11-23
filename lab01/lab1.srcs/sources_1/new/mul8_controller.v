`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2025 04:24:13 PM
// Design Name: 
// Module Name: mul8_controller
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


module mul8_controller(
    input clk, rst_n,
    input M0_i, start_i,
    output reg load_o, add_o, shift_o,
    output reg done
);
    reg [4-1 : 0] K; // counter

    reg [2-1 : 0] state, next_state;
    localparam S0 = 0;
    localparam S1 = 1;
    localparam S2 = 2;

    // K
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) K <= 0;
        else begin
            case (state)
                S0: if (start_i) K <= 1;
                S1: if (!M0_i) K <= K + 1;
                S2: if (K < 8) K <= K + 1;
            endcase
        end
    end

    // state
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) state <= 0;
        else state <= next_state;
    end

    always @* begin
        next_state = S0;

        case (state)
            S0: next_state = (start_i)? S1 : S0;
            S1: begin
                if (M0_i) next_state = S2;
                else if (K < 8) next_state = S1;
                else next_state = S0;
            end
            S2: next_state = (K < 8)? S1 : S0;
        endcase
    end

    // load_o
    always @* begin
        load_o = 0 ;

        case (state)
            S0: if (start_i) load_o = 1;
        endcase
    end

    // add_o
    always @* begin
        add_o = 0;

        case (state)
            S1: if (M0_i) add_o = 1;
        endcase
    end

    // shift_o
    always @* begin
        shift_o = 0;

        case (state)
            S1: if (!M0_i) shift_o = 1;
            S2: shift_o = 1;
        endcase
    end

    // done
    always @(posedge clk) begin
        done <= 0;

        case (state)
            S1: if (!M0_i && K >= 8) done <= 1;
            S2: if (K >= 8) done <= 1;
        endcase
    end
endmodule
