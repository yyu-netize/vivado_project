`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/06 09:40:36
// Design Name: 
// Module Name: register
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

module register #(
        parameter WIDTH = 8
    ) (
        input clk,
        input rst_n,
        input signed [WIDTH-1:0] in,
        output signed [WIDTH-1:0] out,
        input en
     );
    
    reg signed [WIDTH-1:0] in_reg;
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            in_reg <= 0;
        end else begin
            if(en) begin
                in_reg <= in;
            end
        end
    end
    

    
    assign out = in_reg;



endmodule
