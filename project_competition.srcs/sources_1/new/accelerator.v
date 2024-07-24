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

module accelerator #(
    parameter addr_width = 4,
    parameter data_width = 8,
    parameter array_width = 32,
    parameter input_len = 3    
)(
    input clk, 
    input rst_n,
//    input start,
    output reg start,
    output reg ramio_en,  // RAM 使能
    output reg ramwe_en,
    output reg ramin_en,
//    output reg ram_wea, // RAM 读写使能信号，高电平写入，低电平读出
//    output reg [addr_width-1:0] ram_addr, 
//    output reg [data_width-1:0] ram_wr_data, 
//    input [data_width-1:0] ram_rd_data, // RAM 读数据，应该是输入
    output reg ramio_wea,
    output reg ramwe_wea,
    output reg ramin_wea,
    output reg relu,
    output reg [2:0] state
);

reg [addr_width-1:0] ramio_addr;
reg [addr_width-1:0] ramwe_addr;
reg [addr_width-1:0] ramin_addr;

wire [data_width-1:0] weight_buffer_data_out;
wire [data_width-1:0] io_buffer_data_out;
wire [data_width-1:0] instruction_buffer_data_out;

reg [data_width-1:0] weight_buffer_data_in;
reg [data_width-1:0] io_buffer_data_in;
reg [data_width-1:0] instruction_buffer_data_in;

// Declare these as reg instead of wire
reg signed [data_width*array_width-1:0] a_mul_array;
reg signed [data_width*array_width-1:0] b_mul_array;
reg signed [data_width*array_width-1:0] output_result;

//reg [data_width-1:0] a_mul, b_mul;

localparam [2:0] IDLE = 3'b000,
                 READ_INSTR = 3'b001,
                 READ_DATA = 3'b010,
                 SA_COMPUTE = 3'b011,
                 FINISH = 3'b100,
                 WRITE_BUFFER = 3'b101;

// Weight Buffer
weight_buffer weight_buffer_inst (
    .clk(clk),
    .rst_n(rst_n),
    .en(ramwe_en),
    .wea(ramwe_wea),
    .addr(ramwe_addr),
    .data_in(weight_buffer_data_in),
    .data_out(weight_buffer_data_out)
);

// IO Buffer
IO_buffer io_buffer_inst (
    .clk(clk),
    .rst_n(rst_n),
    .en(ramio_en),
    .wea(ramio_wea),
    .addr(ramio_addr),
    .data_in(io_buffer_data_in),
    .data_out(io_buffer_data_out)
);

// Instruction Buffer
Instruction_buffer instruction_buffer_inst (
    .clk(clk),
    .rst_n(rst_n),
    .en(ramin_en),
    .wea(ramin_wea),
    .addr(ramin_addr),
    .data_in(instruction_buffer_data_in),
    .data_out(instruction_buffer_data_out)
);

wire done;

systolic_array #(
    .ARRAY_N(array_width),
    .LEN_WIDTH(8),
    .NUM_PES(array_width*array_width),
    .A_WIDTH(data_width),
    .B_WIDTH(data_width),
    .C_WIDTH(data_width*2),
    .OUT_WIDTH(data_width),
    .IF_WIDTH(data_width*2),
    .WDATA_WIDTH(data_width*array_width*array_width),
    .PEDATA_WIDTH(data_width*array_width*array_width),
    .ODATA_WIDTH(data_width*array_width*array_width*2),
    .input_len(input_len)
) systolic_array_inst (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .empty(1'b0),
    .a_mul(a_mul_array),
    .b_mul(b_mul_array),
    .relu(relu),
    .pe_out(output_result),
    .done(done)
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
    end else begin
        case(state)
            IDLE: begin
                ramwe_en <= 0;
                ramio_en <= 0;
                ramin_en <= 0;
                ramwe_wea <= 0;
                ramwe_addr <= 0;
                ramio_wea <= 0;
                ramio_addr <= 0;
                ramin_wea <= 0;
                ramin_addr <= 0;
                
                weight_buffer_data_in <= 0;
                io_buffer_data_in <= 0;
                instruction_buffer_data_in <= 0;
                
                a_mul_array <= 0;
                b_mul_array <= 0;
                output_result <= 0;
            end
            READ_INSTR: begin
                ramin_en <= 1;
                ramin_wea <= 0;
                ramin_addr <= ramin_addr + 1;
                ramio_en <= 1;
                ramio_addr <= instruction_buffer_data_out;
            end
            READ_DATA: begin
                ramio_en <= 1;
                ramio_wea <= 0;
                ramio_addr <= ramio_addr + 1;
                ramwe_en <= 1;
                ramwe_wea <= 0;
                a_mul_array <= io_buffer_data_out;
                b_mul_array <= weight_buffer_data_out;
            end
            SA_COMPUTE: begin
                a_mul_array <= io_buffer_data_out;
                b_mul_array <= weight_buffer_data_out;
            end
            FINISH: begin
                ramio_en <= 1;
                ramio_wea <= 1;
                ramwe_en <= 1;
                ramwe_wea <= 1;
                a_mul_array <= 0;
                b_mul_array <= 0;
            end
            WRITE_BUFFER: begin
                ramio_en <= 1;
                ramio_wea <= 1;
                io_buffer_data_in <= output_result;
            end
        endcase
    end
end



//always @(posedge clk or negedge rst_n) begin
//    if (!rst_n) begin
//        relu <= 0;
//    end else if (done) begin
//        relu <= 0;
//    end
//end

//always @(posedge clk or negedge rst_n) begin
//    if(!rst_n) begin
//        output_result <= 0;
//    end else begin
//        output_result <= weight_buffer_data_out;
//    end
//end

endmodule
