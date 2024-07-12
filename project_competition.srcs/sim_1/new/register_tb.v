`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/25 12:00:00
// Design Name: 
// Module Name: tb_register
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench for register module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_register;

reg clk;
reg rst_n;
reg signed [7:0] in;
reg en;
wire signed [7:0] out;

// Instantiate the register module
register #(
    .WIDTH(8)
) uut (
    .clk(clk),
    .rst_n(rst_n),
    .in(in),
    .out(out),
    .en(en)
);

// Clock generation
always begin
    #5 clk = ~clk;  // 10ns clock period
end

initial begin
    // Initialize inputs
    clk = 0;
    rst_n = 0;
    in = 0;
    en = 0;

    // Reset the register
    #10 rst_n = 1;  // Deassert reset
    #10 rst_n = 0;  // Assert reset
    #10 rst_n = 1;  // Deassert reset
    
    // Test case 1: Write value with enable
    #10 in = 8'h55; en = 1;
    #10 en = 0;  // Disable writing
    
    // Test case 2: Change input without enable
    #10 in = 8'hAA; en = 0;
    
    // Test case 3: Write new value with enable
    #10 in = 8'hFF; en = 1;
    
    // Test case 4: Reset the register
    #10 rst_n = 0;
    #10 rst_n = 1;
    
    // Test case 5: Write after reset
    #10 in = 8'h0F; en = 1;
    
    // End of simulation
    #20 $finish;
end

// Monitor the changes
initial begin
    $monitor("Time = %0t, clk = %b, rst_n = %b, in = %h, en = %b, out = %h", $time, clk, rst_n, in, en, out);
end

endmodule
