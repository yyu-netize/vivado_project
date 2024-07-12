`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/28 20:08:23
// Design Name: 
// Module Name: tb_systolic_array
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


module systolic_array_tb;

    // Parameters
    parameter NUM_PES = 4;
    parameter A_WIDTH = 8;
    parameter B_WIDTH = 8;
    parameter C_WIDTH = 16;
    parameter OUT_WIDTH = 8;

    // Inputs
    reg clk;
    reg rst_n;
    reg signed [A_WIDTH-1:0] a_mul;
    reg signed [B_WIDTH-1:0] b_mul;
    reg signed [C_WIDTH-1:0] c_add;

    // Outputs
    wire signed [OUT_WIDTH-1:0] pe_out;

    // Instantiate systolic_array module
    systolic_array #(
        .NUM_PES(NUM_PES),
        .A_WIDTH(A_WIDTH),
        .B_WIDTH(B_WIDTH),
        .C_WIDTH(C_WIDTH),
        .OUT_WIDTH(OUT_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .a_mul(a_mul),
        .b_mul(b_mul),
        .c_add(c_add),
        .pe_out(pe_out)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    // Reset generation
    initial begin
        clk = 0;
        rst_n = 0;
        #10 rst_n = 1;
    end

    // Test cases
    initial begin
        // Test case 1
        #20;
        $display("Test Case 1:");
        a_mul = 3; b_mul = 4; c_add = 10;
        #10;
        $display("a_mul = %d, b_mul = %d, c_add = %d, pe_out = %d", a_mul, b_mul, c_add, pe_out);

        // Test case 2
        #20;
        $display("Test Case 2:");
        a_mul = -2; b_mul = 5; c_add = -8;
        #10;
        $display("a_mul = %d, b_mul = %d, c_add = %d, pe_out = %d", a_mul, b_mul, c_add, pe_out);

        // Add more test cases as needed

        // End simulation
        #10 $finish;
    end

endmodule
