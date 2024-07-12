`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/09 14:57:26
// Design Name: 
// Module Name: accelerator
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

module accelerator(
    input clk , 
    input rst_n ,
    input start,
    
    output reg ram_en ,  //RAM 使能
    output reg ram_wea , //ram 读写使能信号,高电平写入,低电平读出
    output reg [4:0] ram_addr , 
    output reg [7:0] ram_wr_data , 
    output reg [7:0] ram_rd_data , //ram 读数据 
    output reg relu
);

// RAM IPs
wire [7:0] weight_buffer_data_out;
wire [7:0] io_buffer_data_out;
wire [7:0] instruction_buffer_data_out;

reg [7:0] weight_buffer_data_in;
reg [7:0] io_buffer_data_in;
reg [7:0] instruction_buffer_data_in;

reg [7:0] a_mul, b_mul;

// Weight Buffer
weight_buffer weight_buffer_inst (
    .clk(clk),
    .rst_n(rst_n),
    .en(ram_en),
    .wea(ram_wea),
    .addr(ram_addr),
    .data_in(weight_buffer_data_in),
    .data_out(weight_buffer_data_out)
);

// IO Buffer
IO_buffer io_buffer_inst (
    .clk(clk),
    .rst_n(rst_n),
    .en(ram_en),
    .wea(ram_wea),
    .addr(ram_addr),
    .data_in(io_buffer_data_in),
    .data_out(io_buffer_data_out)
);

// Instruction Buffer
Instruction_buffer instruction_buffer_inst (
    .clk(clk),
    .rst_n(rst_n),
    .en(ram_en),
    .wea(ram_wea),
    .addr(ram_addr),
    .data_in(instruction_buffer_data_in),
    .data_out(instruction_buffer_data_out)
);

wire done;
reg signed [256*8-1:0] a_mul_array;
reg signed [256*8-1:0] b_mul_array;
reg signed [256*8-1:0] output_result;

systolic_array #(
    .ARRAY_N(32),
    .LEN_WIDTH(8),
    .NUM_PES(32*32),
    .A_WIDTH(8),
    .B_WIDTH(8),
    .C_WIDTH(16),
    .OUT_WIDTH(8),
    .IF_WIDTH(8+8),
    .WDATA_WIDTH(32*32*8),
    .PEDATA_WIDTH(32*32*8),
    .ODATA_WIDTH(32*32*8),
    .input_len(3)
) systolic_array_inst (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .empty(1'b0), // Adjust according to your design
    .a_mul(a_mul_array),
    .b_mul(b_mul_array),
    .relu(relu),
    .done(done)
);


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ram_en <= 0;
        ram_wea <= 0;
        ram_addr <= 0;
        ram_wr_data <= 0;
    end else if (start) begin
        ram_en <= 1;
        ram_wea <= 1;
        ram_addr <= ram_addr + 1;
        ram_wr_data <= ram_wr_data + 1;
        ram_rd_data <= ram_rd_data + 1;
        
        a_mul_array[ram_addr*8 +: 8] <= weight_buffer_data_out;
        b_mul_array[ram_addr*8 +: 8] <= io_buffer_data_out;
        

    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        relu <= 0;
    end else if (done) begin
        relu <= 0;
    end
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        output_result <= 0;
    end else begin
        output_result <= weight_buffer_data_out;
    end
end

endmodule





