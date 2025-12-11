`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2025 02:29:07 PM
// Design Name: 
// Module Name: gcd_seq
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


`define MAX_BIT 10

module gcd_seq(
    input clk, rst_n,
    input start_i,
    input [`MAX_BIT-1 : 0] a_i, b_i,

    output [`MAX_BIT-1 : 0] ans_o,
    output valid_o
);
    (* mark_debug = "true" *) reg [`MAX_BIT-1 : 0] a, b;

    localparam S_IDLE = 0;
    localparam S_COMPUTE = 1;
    (* mark_debug = "true" *) reg state, n_state;

    // state machine
    always @(posedge clk) begin
        if (!rst_n) begin
            state <= S_IDLE;
        end else begin
            state <= n_state;
        end
    end

    always @* begin
        case (state)
            S_IDLE: n_state = (start_i)? S_COMPUTE : S_IDLE;
            S_COMPUTE: n_state = (b == 0)? S_IDLE : S_COMPUTE;
        endcase
    end

    // datapath
    always @(posedge clk) begin
        if (!rst_n) begin
            a <= 0;
            b <= 0;
        end else begin
            case (state)
                S_IDLE: begin
                    if (start_i) begin
                        a <= a_i;
                        b <= b_i;
                    end
                end
                S_COMPUTE: begin
                    a <= b;
                    b <= a % b; // this critical path causes timing violation
                end
            endcase
        end
    end

    assign ans_o = a;
    assign valid_o = ((state == S_COMPUTE) && (b == 0));
endmodule
