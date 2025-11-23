`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/22/2025 01:17:49 AM
// Design Name: 
// Module Name: golf_headlights_baseball_bat
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

`define QLEN (2**($clog2(2*`SECOND)-2)) // a quarter of the counter's output

`define PWM_100 100 // 100Hz PWM pulse
`define PWM_25 25
`define PWM_5 5
`define PWM_1 1

module golf_headlights_baseball_bat(
    input clk, rst_n,
    input BTNC, BTND, BTNL, BTNR, BTNU,
    output reg [8-1 : 0] LD
);
    // debouncer circuits for input buttons
    wire BTNC_DB, BTND_DB, BTNL_DB, BTNR_DB, BTNU_DB;

    debouncer DB1 (
        .clk(clk), .rst_n(rst_n),
        .btn_i(BTNC),
        .db_o(BTNC_DB)
    );

    brightness_pulser BP1 (
        .clk(clk), .rst_n(rst_n),
        .btn_i(BTNC_DB),
        .bp_o(BTNC_BP)
    );

    debouncer DB2 (
        .clk(clk), .rst_n(rst_n),
        .btn_i(BTND),
        .db_o(BTND_DB)
    );

    debouncer DB3 (
        .clk(clk), .rst_n(rst_n),
        .btn_i(BTNL),
        .db_o(BTNL_DB)
    );

    debouncer DB4 (
        .clk(clk), .rst_n(rst_n),
        .btn_i(BTNR),
        .db_o(BTNR_DB)
    );

    debouncer DB5 (
        .clk(clk), .rst_n(rst_n),
        .btn_i(BTNU),
        .db_o(BTNU_DB)
    );

    brightness_pulser BP2 (
        .clk(clk), .rst_n(rst_n),
        .btn_i(BTNU_DB),
        .bp_o(BTNU_BP)
    );

    // registers
    reg [$clog2(2*`SECOND)-1 : 0] light_control;

    reg [2-1 : 0] brightness;
    reg [$clog2(`PWM_100)-1 : 0] freq_threshold;
    reg [$clog2(`PWM_100)-1 : 0] freq_counter;

    localparam S_IDLE = 0;
    localparam S_LEFT_TURN = 1;
    localparam S_RIHGT_TURN = 2;
    localparam S_BATTLE = 3;

    reg [2-1 : 0] state, n_state;

    // state
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) state <= 0;
        else state <= n_state;
    end

    always @* begin
        case (state)
            S_IDLE: begin
                if (BTND_DB) n_state = S_BATTLE;
                else if (BTNL_DB && BTNR_DB) n_state = S_IDLE;
                else if (BTNL_DB) n_state = S_LEFT_TURN;
                else if (BTNR_DB) n_state = S_RIHGT_TURN;
                else n_state = S_IDLE;
            end
            S_LEFT_TURN: begin
                if (BTND_DB) n_state = S_BATTLE;
                else if (BTNR_DB) n_state = S_IDLE;
                else n_state = S_LEFT_TURN;
            end
            S_RIHGT_TURN: begin
                if (BTND_DB) n_state = S_BATTLE;
                else if (BTNL_DB) n_state = S_IDLE;
                else n_state = S_RIHGT_TURN;
            end
            S_BATTLE: begin
                if (BTNL_DB && BTNR_DB) n_state = S_IDLE;
                else if (BTNL_DB) n_state = S_LEFT_TURN;
                else if (BTNR_DB) n_state = S_RIHGT_TURN;
                else n_state = S_BATTLE;
            end
        endcase
    end

    // brightness
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) brightness <= 1;
        else if (BTNU_BP && BTNC_BP) brightness <= brightness;
        else if (brightness == 3 && BTNU_BP) brightness <= 3;
        else if (brightness == 0 && BTNC_BP) brightness <= 0;
        else if (BTNU_BP) brightness <= brightness + 1;
        else if (BTNC_BP) brightness <= brightness - 1;
    end

    // freq_threshold
    always @* begin
        case (brightness)
            0: freq_threshold = `PWM_1;
            1: freq_threshold = `PWM_5;
            2: freq_threshold = `PWM_25;
            3: freq_threshold = `PWM_100;
        endcase
    end

    // freq_counter
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) freq_counter <= `PWM_100;
        else if (freq_counter == 0) freq_counter <= `PWM_100;
        else freq_counter <= freq_counter - 1;
    end
    
    // light_control
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) light_control <= 0;
        else if (BTNL_DB || BTNR_DB || BTND_DB) light_control <= 0;
        else light_control <= light_control + 1;
    end

    // LD
    wire led_lit = (freq_counter < freq_threshold);
    
    wire Q1 = (0 <= light_control && light_control < `QLEN);
    wire Q2 = (`QLEN <= light_control && light_control < 2*`QLEN);
    wire Q3 = (2*`QLEN <= light_control && light_control < 3*`QLEN);
    wire Q4 = (3*`QLEN <= light_control && light_control < 4*`QLEN);

    integer i;

    always @* begin
        LD = 0;

        case (state)
            S_LEFT_TURN: begin
                if (Q1) LD[4] = led_lit;
                else if (Q2) LD[5] = led_lit;
                else if (Q3) LD[6] = led_lit;
                else if (Q4) LD[7] = led_lit;
            end
            S_RIHGT_TURN: begin
                if (Q1) LD[3] = led_lit;
                else if (Q2) LD[2] = led_lit;
                else if (Q3) LD[1] = led_lit;
                else if (Q4) LD[0] = led_lit;
            end
            S_BATTLE: begin
                for (i = 0; i < 8; i=i+1) begin
                    // all LEDs shine at max brightness!
                    // grab your baseball bat,
                    // get ready for a road battle!
                    if (Q1 || Q3) LD[i] = 1;
                end
            end
        endcase
    end
endmodule
