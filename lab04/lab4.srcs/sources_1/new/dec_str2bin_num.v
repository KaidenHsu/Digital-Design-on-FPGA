`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2025 06:30:04 PM
// Design Name: 
// Module Name: dec_str2bin_num
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


`define NUM_WIDTH 10

module dec_str2bin_num(
    input clk, rst_n,

    input start_i,
    input received_i,
    input enter_pressed_i,
    input [8-1 : 0] digit_char_i,

    output [`NUM_WIDTH-1 : 0] number_o, // the input number in binary
    output [3-1 : 0] digit_count_o, // number of digits of the input number
    output [8*5-1 : 0] dec_str_o, // the input number in string
    output valid_o
);
    // digit_received is asserted when the value in digit_char_i is valid
    (* mark_debug = "true" *) reg digit_received;

    always @(posedge clk) begin
        if (!rst_n) begin
            digit_received <= 0;
        end else begin
            digit_received <= received_i;
        end
    end

    // state machine
    localparam S_IDLE = 0;
    localparam S_NEW_DIGIT = 1;
    (* mark_debug = "true" *) reg state;
    (* mark_debug = "true" *) reg n_state;

    always @(posedge clk) begin
        if (!rst_n) state <= S_IDLE;
        else state <= n_state;
    end

    always @* begin
        case (state)
            S_IDLE: n_state = (start_i)? S_NEW_DIGIT : S_IDLE;
            S_NEW_DIGIT: n_state = (enter_pressed_i)? S_IDLE : S_NEW_DIGIT;
        endcase
    end

    // 1. decimal string -> binary number
    (* mark_debug = "true" *) reg [`NUM_WIDTH-1 : 0] num;

    always @(posedge clk) begin
        if (!rst_n) begin
            num <= 0;
        end else begin
            case (state)
                S_IDLE: num <= 0;
                S_NEW_DIGIT: begin
                    if (digit_received && !enter_pressed_i) begin
                        num <= 10*num + digit_char_to_num(digit_char_i);
                    end
                end
            endcase
        end
    end

    assign number_o = num;

    function [4-1 : 0] digit_char_to_num; // 9 can be represented using 4 bits
        input [8-1 : 0] digit_char;

        begin
            if (48 <= digit_char && digit_char <= 57) begin // 0 ~ 9
                digit_char_to_num = digit_char - 48;
            end else begin
                digit_char_to_num = 0; // all invalid characters will be treated as "0"
            end
        end
    endfunction

    // 2. reconstruct decimal string

    reg [8*5-1 : 0] dec_str;

    // number of digits
    // e.g. 0012 => digit_count = 2
    // e.g. 0147 => digit_count = 3
    reg [3-1 : 0] digit_count;

    always @(posedge clk) begin
        if (!rst_n) begin
            dec_str <= 0;
            digit_count <= 0;
        end else begin
            case (state)
                S_IDLE: begin
                    if (start_i) begin
                        dec_str <= 40'h30_30_30_30_30; // 00000
                        digit_count <= 0;
                    end
                end
                S_NEW_DIGIT: begin
                    if (digit_received) begin
                        if (!enter_pressed_i) begin
                            dec_str <= (dec_str << 8) | {32'b0, digit_char_i};
                            digit_count <= digit_count + 1;
                        end else begin
                            dec_str <= dec_str << 8;
                        end
                    end
                end
            endcase
        end
    end

    assign dec_str_o = dec_str;
    assign digit_count_o = digit_count;


    // valid_o
    assign valid_o = ((state == S_NEW_DIGIT) && enter_pressed_i);
endmodule
