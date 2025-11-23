`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2025 04:44:13 PM
// Design Name: 
// Module Name: mul8_tb
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


`define CLK_CYCLE (10)

module mul8_tb();
    reg clk, rst_n;
    reg start;
    reg [8-1 : 0] A, B;
    wire [16-1 : 0] product;
    wire done;

    mul8 uut (
        .clk(clk), .rst_n(rst_n),
        .A_i(A), .B_i(B), .start_i(start),
        .product_o(product),
        .done(done)
    );

    // mul8_orange uut(
    //     .clk(clk), .rst_n(rst_n),
    //     .A_i(A), .B_i(B), .start_i(start),
    //     .product_o(product),
    //     .done(done)
    // );

    wire [5-1 : 0] cycle_cnt;

    counter u1 (
        .clk(clk), .rst_n(rst_n),
        .start_i(start),
        .Q(cycle_cnt)
    );

    initial begin
        clk = 0;
        forever #(`CLK_CYCLE/2) clk = ~clk;
    end

    initial begin
        #3000 
        $display("TLE");
        $finish;
    end

    reg [8-1 : 0] i, j;
    reg [16-1 : 0] golden;

    integer total_cycle_cnt;

    initial begin
        total_cycle_cnt = 0;

        {A, B, start} = 0;
        rst_n = 1;

        force clk = 0;
        #(2*`CLK_CYCLE);
        rst_n = 0;
        #(2*`CLK_CYCLE);
        rst_n = 1;
        #(2*`CLK_CYCLE);
        release clk;

        @(posedge clk);

        for (i = 0; i < 5; i=i+1) begin
            for (j = 0; j < 5; j=j+1) begin
                // manipulate input
                @(negedge clk);
                start = 1;
                A = i;
                B = j;

                @(negedge clk);
                {start, A, B} = 0;

                // check answer
                @(done & clk);
                total_cycle_cnt = total_cycle_cnt + cycle_cnt;
                golden = i * j;
                if (product !== golden) begin
                    $display("A=%d (%b), B=%d (%b), ans=%d (%b), golden=%d (%b)", i, i, j, j, product, product, golden, golden);
                    #10 $finish;
                end
            end
        end

        $display("All test cases passed!");
        $display("Average cycle = %d", total_cycle_cnt/25);
        #10 $finish;
    end
endmodule

module counter (
    input clk, rst_n,
    input start_i,
    output reg [5-1 : 0] Q
);
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) Q <= 0;
        else if (start_i) Q <= 0;
        else Q <= Q + 1;
    end
endmodule
