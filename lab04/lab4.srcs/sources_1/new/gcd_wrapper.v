`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2025 12:08:10 PM
// Design Name: 
// Module Name: gcd_wrapper
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


`define INIT_DELAY 100_000
`define MEM_SIZE 100 // 35 + 4 + 36 + 5 + (16 + 4)
`define NUM_WIDTH 10

module gcd_wrapper(
    input clk, reset_n,

    input uart_rx,

    output uart_tx
);
    // declare system variables
    (* mark_debug = "true" *) wire enter_pressed;
    (* mark_debug = "true" *) wire print_enable, print_done;
    (* mark_debug = "true" *) reg [$clog2(`MEM_SIZE)-1 : 0] send_counter;
    reg [$clog2(`INIT_DELAY)-1 : 0] init_counter;
    reg [8-1 : 0] data [0 : `MEM_SIZE-1];

    // helper variables for initializing strings
    integer i;
    reg [8*35-1 : 0] s1; // "Enter the first decimal number: " + CR LF + NULL = 35 bytes
    reg [8*36-1 : 0] s2; // "Enter the second decimal number: " + CR LF + NULL = 36 bytes
    reg [8*17-1 : 0] s3; // "The GCD is: 0x" + CR LF + NULL = 17 bytes

    // declare UART signals
    wire transmit;
    wire [8-1 : 0] tx_byte;

    (* mark_debug = "true" *) wire received;
    (* mark_debug = "true" *) wire [8-1 : 0] rx_byte;
    (* mark_debug = "true" *) reg  [8-1 : 0] rx_temp;

    wire is_receiving;
    wire is_transmitting;
    wire recv_error;

    // UART controller
    uart_teacher uart (
        .clk(clk), .rst(~reset_n),
        .rx(uart_rx),
        .transmit(transmit),
        .tx_byte(tx_byte),

        .tx(uart_tx),
        .received(received),
        .rx_byte(rx_byte),
        .is_receiving(is_receiving), // not used
        .is_transmitting(is_transmitting),
        .recv_error(recv_error) // not used
    );

    (* mark_debug = "true" *) wire [8*4-1 : 0] dec_str_1, dec_str_2;

    (* mark_debug = "true" *) wire [`NUM_WIDTH-1 : 0] ans;

    (* mark_debug = "true" *) wire [3-1 : 0] digit_count1, digit_count2;

    (* mark_debug = "true" *) wire first_num_ready;
    (* mark_debug = "true" *) wire second_num_ready;

    (* mark_debug = "true" *) wire first_num_valid;
    (* mark_debug = "true" *) wire second_num_valid;

    // convert decimal string into number
    wire [`NUM_WIDTH-1 : 0] a, b; // 0 ~ 1023
    (* mark_debug = "true" *) reg [`NUM_WIDTH-1 : 0] reg_a = 0; // holds the first number
    (* mark_debug = "true" *) reg [`NUM_WIDTH-1 : 0] reg_b = 0; // holds the second number

    always @(posedge clk) begin
        if (!reset_n) begin
            reg_a <= 0;
            reg_b <= 0;
        end else begin
            if (first_num_valid) reg_a <= a;
            if (second_num_ready) reg_b <= b;
        end
    end

    dec_str_preprocess dec_str_preprocess1 (
        .clk(clk), .rst_n(reset_n),
        .start_i(first_num_ready),
        .received_i(received),
        .enter_pressed_i(enter_pressed),
        .digit_char_i(rx_temp), 

        .number_o(a),
        .digit_count_o(digit_count1),
        .dec_str_o(dec_str_1),
        .valid_o(first_num_valid)
    );

    dec_str_preprocess dec_str_preprocess2 (
        .clk(clk), .rst_n(reset_n),
        .start_i(second_num_ready),
        .received_i(received),
        .enter_pressed_i(enter_pressed),
        .digit_char_i(rx_temp), 

        .number_o(b),
        .digit_count_o(digit_count2),
        .dec_str_o(dec_str_2),
        .valid_o(second_num_valid)
    );

    // gcd computation
    (* mark_debug = "true" *) wire gcd_valid;

    (* mark_debug = "true" *) reg gcd_valid_reg;

    always @(posedge clk) begin
        if (!reset_n) begin
            gcd_valid_reg <= 0;
        end else begin
            if (gcd_valid) gcd_valid_reg <= 1;
        end
    end

    gcd_seq gcd_seq (
        .clk(clk), .rst_n(reset_n),
        .start_i(second_num_valid),
        .a_i(reg_a), .b_i(reg_b),

        .ans_o(ans),
        .valid_o(gcd_valid)
    );

    (* mark_debug = "true" *) reg [`NUM_WIDTH-1 : 0] ans_reg;

    always @(posedge clk) begin
        if (!reset_n) begin
            ans_reg <= 0;
        end else begin
            if (gcd_valid) begin
                ans_reg <= ans;
            end
        end
    end

    // gcd_rec gcd_rec (
    //     .a_i(a), .b_i(b),

    //     .ans_o(ans)
    // );

    (* mark_debug = "true" *) wire [8*4-1 : 0] ans_hex_str;

    // comb ckt converting answer to a hex string
    bin_num2hex_str bin_num2hex_str (
        .bin_num_i(ans_reg),
        .hex_str_o(ans_hex_str)
    );

    // SystemVerilog has an easier way to initialize an array, but we are using Verilog 2005 :(
    // 0D: carriage return
    // 0A: line feed
    // 00 : null character
    initial begin
        // Prepare packed strings (MSB-first packing so we extract bytes in order)
        s1 = { 8'h0D, 8'h0A, "Enter the first decimal number: ", 8'h00 }; // 35 bytes
        for (i = 0; i < 35; i = i + 1) begin
            data[i] = s1[8*(35-1-i) +: 8]; // data[0 : 34]
        end

        s2 = { 8'h0D, 8'h0A, "Enter the second decimal number: ", 8'h00 }; // 36 bytes
        for (i = 0; i < 36; i = i + 1) begin
            data[39 + i] = s2[8*(36-1-i) +: 8]; // data[39 : 74]
        end

        s3 = { 8'h0D, 8'h0A, "The GCD is: 0x" }; // 16 bytes
        for (i = 0; i < 16; i = i + 1) begin
            data[80 + i] = s3[8*(16-1-i) +: 8]; // data[80 : 95]
        end
    end

    always @* begin
        // data[35 : 38] => first number (no terminating character)
        {data[35], data[36], data[37], data[38]} = dec_str_1;

        // data[75 : 79] => second number (has terminating character)
        {data[75], data[76], data[77], data[78]} = dec_str_2;
        data[79] = 8'h0;
    end

    // data[96 : 99] => ans in hex
    always @* begin
        data[96] = ans_hex_str[8*4-1 -: 8];
        data[97] = ans_hex_str[8*3-1 -: 8];
        data[98] = ans_hex_str[8*2-1 -: 8];
        data[99] = ans_hex_str[8*1-1 -: 8];
    end

    // Combinational I/O logic
    assign enter_pressed = (rx_temp == 8'h0D);
    assign tx_byte = data[send_counter];
    assign print_done = (tx_byte == 8'h0); // when NULL character is reached



    // ------------------------------------------------------------------------
    // Main FSM that reads the UART input and triggers
    // the output of the string "Hello, World!".
    localparam S_MAIN_INIT = 0;
    localparam S_MAIN_PROMPT_FIRST_NUMBER = 1;
    localparam S_MAIN_WAIT_FIRST_NUMBER = 2;
    localparam S_MAIN_PRINT_FIRST_NUMBER_AND_PROMPT_SECOND_NUMBER = 3;
    localparam S_MAIN_WAIT_SECOND_NUMBER = 4;
    localparam S_MAIN_PRINT_SECOND_NUMBER = 5;
    localparam S_MAIN_WAIT_ANS = 6;
    localparam S_MAIN_PRINT_ANS = 7;
    (* mark_debug = "true" *) reg [3-1 : 0] P;
    (* mark_debug = "true" *) reg [3-1 : 0] P_next;

    always @(posedge clk) begin
        if (~reset_n) P <= S_MAIN_INIT;
        else P <= P_next;
    end

    always @* begin
        case (P)
            S_MAIN_INIT: // Wait for initial delay of the circuit.
                if (init_counter < `INIT_DELAY) P_next = S_MAIN_INIT;
                else P_next = S_MAIN_PROMPT_FIRST_NUMBER;
            S_MAIN_PROMPT_FIRST_NUMBER:
                if (print_done) P_next = S_MAIN_WAIT_FIRST_NUMBER;
                else P_next = S_MAIN_PROMPT_FIRST_NUMBER;
            S_MAIN_WAIT_FIRST_NUMBER:
                if (enter_pressed) P_next = S_MAIN_PRINT_FIRST_NUMBER_AND_PROMPT_SECOND_NUMBER;
                else P_next = S_MAIN_WAIT_FIRST_NUMBER;
            S_MAIN_PRINT_FIRST_NUMBER_AND_PROMPT_SECOND_NUMBER:
                if (print_done) P_next = S_MAIN_WAIT_SECOND_NUMBER;
                else P_next = S_MAIN_PRINT_FIRST_NUMBER_AND_PROMPT_SECOND_NUMBER;
            S_MAIN_WAIT_SECOND_NUMBER:
                if (enter_pressed) P_next = S_MAIN_PRINT_SECOND_NUMBER;
                else P_next = S_MAIN_WAIT_SECOND_NUMBER;
            S_MAIN_PRINT_SECOND_NUMBER:
                if (print_done) P_next = S_MAIN_WAIT_ANS;
                else P_next = S_MAIN_PRINT_SECOND_NUMBER;
            S_MAIN_WAIT_ANS:
                if (gcd_valid_reg) P_next = S_MAIN_PRINT_ANS;
                else P_next = S_MAIN_WAIT_ANS;
            S_MAIN_PRINT_ANS:
                if (enter_pressed) P_next = S_MAIN_PROMPT_FIRST_NUMBER;
                else P_next = S_MAIN_PRINT_ANS;
            default: P_next = S_MAIN_INIT;
        endcase
    end

    // FSM output logic
    assign first_num_ready = (P == S_MAIN_WAIT_FIRST_NUMBER);
    assign second_num_ready = (P == S_MAIN_WAIT_SECOND_NUMBER);

    assign print_enable = (P != S_MAIN_PROMPT_FIRST_NUMBER && P_next == S_MAIN_PROMPT_FIRST_NUMBER) ||
                    (P == S_MAIN_WAIT_FIRST_NUMBER && enter_pressed) ||
                    (P == S_MAIN_WAIT_SECOND_NUMBER && enter_pressed) ||
                    (P == S_MAIN_WAIT_ANS && gcd_valid_reg);

    // initialization counter
    always @(posedge clk) begin
        if (P == S_MAIN_INIT) init_counter <= init_counter + 1;
        else init_counter <= 0;
    end
    // End of the FSM of the print string controller
    // ------------------------------------------------------------------------



    // ------------------------------------------------------------------------
    // FSM of the controller to send a string to UART. (linked state machine)
    localparam S_UART_IDLE = 0;
    localparam S_UART_WAIT = 1;
    localparam S_UART_SEND = 2;
    localparam S_UART_INCR = 3;
    (* mark_debug = "true" *) reg [2-1 : 0] Q;
    (* mark_debug = "true" *) reg [2-1 : 0] Q_next;

    always @(posedge clk) begin
        if (~reset_n) Q <= S_UART_IDLE;
        else Q <= Q_next;
    end

    always @* begin
        case (Q)
            S_UART_IDLE: // wait for the print_string flag
                if (print_enable) Q_next = S_UART_WAIT;
                else Q_next = S_UART_IDLE;
            S_UART_WAIT: // wait for the transmission of current data byte begins
                if (is_transmitting) Q_next = S_UART_SEND;
                else Q_next = S_UART_WAIT;
            S_UART_SEND: // wait for the transmission of current data byte finishes
                if (is_transmitting == 0) Q_next = S_UART_INCR; // transmit next character
                else Q_next = S_UART_SEND;
            S_UART_INCR:
                if (print_done) Q_next = S_UART_IDLE; // string transmission ends
                else Q_next = S_UART_WAIT;
        endcase
    end

    // FSM output logic
    assign transmit = ((Q_next == S_UART_WAIT) || print_enable);

    // send counter
    always @(posedge clk) begin
        send_counter <= send_counter + (Q_next == S_UART_INCR); // print the next ASCII character

        case (P_next)
            S_MAIN_INIT: send_counter <= 0; // prompt 1st number
        endcase

        case (P)
            S_MAIN_WAIT_FIRST_NUMBER: send_counter <= 35 + (4 - digit_count1); // print 1st number
            S_MAIN_WAIT_SECOND_NUMBER: send_counter <= 75 + (4 - digit_count2); // print 2nd number
            S_MAIN_PRINT_SECOND_NUMBER: if (print_done) send_counter <= 80; // The GCD is 0x???
            S_MAIN_PRINT_ANS: if (print_done) send_counter <= 0;
        endcase
    end
    // End of the FSM of the print string controller
    // ------------------------------------------------------------------------



    // ------------------------------------------------------------------------
    // The UART input character will stay in this temporary buffer for a clock cycle.
    always @(posedge clk) begin
        rx_temp <= (received)? rx_byte : 8'h0;
    end
    // End of temporary buffer
    // ------------------------------------------------------------------------
endmodule
