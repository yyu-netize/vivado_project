`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/25 12:00:00
// Design Name: 
// Module Name: tb_PE
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench for PE module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_PE;

reg clk;
reg rst_n;
reg ctl;
reg en;
reg signed [7:0] a_mul;
reg signed [7:0] b_mul;

wire signed [7:0] a_out;
wire signed [7:0] b_out;
wire signed [7:0] result;

// Instantiate the PE module
PE #(
    .A_WIDTH(8),
    .B_WIDTH(8),
    .C_WIDTH(16),
    .OUT_WIDTH(8)
) dut (
    .clk(clk),
    .rst_n(rst_n),
    .ctl(ctl),
    .en(en),
    .a_mul(a_mul),
    .b_mul(b_mul),
    .a_out(a_out),
    .b_out(b_out),
    .result(result)
);

// Clock generation
always begin
    #5 clk = ~clk; // 10ns clock period
end

initial begin
    // Initialize inputs
    clk = 0;
    rst_n = 0;
    ctl = 0;
    en = 1;
    a_mul = 0;
    b_mul = 0;

    // Reset the module
    #10 rst_n = 1;

    // Test case 1: Perform multiplication
    #30 a_mul = 4; b_mul = 3; ctl = 0; // Multiplication
    #50 $display("Test case 1: result = %d", result);

    // Test case 2: Perform addition + multiplication
//    #60 rst_n = 0;
//    #70 rst_n = 1;
    #30 a_mul = -10; b_mul = 2; ctl = 1; // Addition + Multiplication
    #50 $display("Test case 2: result = %d", result);

    #30 a_mul = 2; b_mul = 7; ctl = 1; // Addition + Multiplication
    #50 $display("Test case 2: result = %d", result);
    // End of simulation
    #100 $finish;
end

endmodule
