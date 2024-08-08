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
    parameter instr_width = 5,
    parameter data_width = 8,
    parameter array_width = 32,
    parameter input_len = 3    
)(
    input clk, 
    input rst_acce,
    input rst_array,
//    input start,
    input start_acce,
    input start_array,


    output reg ramio_wea,
    output reg ramwe_wea,
    output reg ramin_wea,
    output wire relu,
    output reg [2:0] current_state, next_state

);



reg ramio_en;
reg ramwe_en;
reg ramin_en;



reg [addr_width-1:0] ramio_addr;
reg [addr_width-1:0] ramwe_addr;
reg [addr_width-1:0] ramin_addr;

wire [data_width-1:0] weight_buffer_data_out;
wire [data_width-1:0] io_buffer_data_out;
wire [instr_width-1:0] instruction_buffer_data_out;
wire [2:0] state_change;

reg [data_width-1:0] weight_buffer_data_in;
reg [data_width-1:0] io_buffer_data_in;
reg [instr_width-1:0] instruction_buffer_data_in;

// Declare these as reg instead of wire
reg signed [data_width*array_width-1:0] a_mul_array;
reg signed [data_width*array_width-1:0] b_mul_array;
wire signed [data_width*array_width-1:0] output_result;//应该是wireless信号吧

//reg [data_width-1:0] a_mul, b_mul;

localparam [2:0] IDLE = 3'b000,
                 READ_INSTR = 3'b001,
                 READ_DATA = 3'b010,
                 SA_COMPUTE = 3'b011,
                 FINISH = 3'b100,
                 WRITE_BUFFER = 3'b101;

// Weight Buffer
we_buffer we_buffer_inst (
    .clka(clk),
//    .rst_n(rst_n),
    .ena(ramwe_en),
    .wea(ramwe_wea),
    .addra(ramwe_addr),
    .dina(weight_buffer_data_in),
    .douta(weight_buffer_data_out)
);

// IO Buffer
io_buffer io_buffer_inst (
    .clka(clk),
//    .rst_n(rst_n),
    .ena(ramio_en),
    .wea(ramio_wea),
    .addra(ramio_addr),
    .dina(io_buffer_data_in),
    .douta(io_buffer_data_out)
);

// Instruction Buffer
in_buffer in_buffer_inst (
    .clka(clk),
//    .rst_n(rst_n),
    .ena(ramin_en),
    .wea(ramin_wea),
    .addra(ramin_addr),
    .dina(instruction_buffer_data_in),
    .douta(instruction_buffer_data_out)
);

wire done;
assign relu = ramio_addr[4:3];

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
    .rst_n(rst_array),//不同
    .start(start_array),//不同
    .empty(1'b0),//不是0
    .a_mul(a_mul_array),
    .b_mul(b_mul_array),
    .relu(relu),
    .pe_out(output_result),
    .done(done)
);

always @(posedge clk or negedge rst_acce)begin
    if(rst_acce) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end

//assign state_change = instruction_buffer_data_out[4:2];

always @(posedge clk or negedge rst_acce) begin
    case (current_state)
        IDLE:begin
            if(start_acce)
                next_state <= READ_INSTR;
            else 
                next_state <= IDLE;
            end
        READ_INSTR:begin
            if(rst_acce)
                next_state <= IDLE;
//             else if(state_change == 3'b010)
//                next_state <= READ_DATA;
//            else
//                next_state <= READ_INSTR;
//            end
            else
                next_state <= READ_DATA;
            end
        READ_DATA:begin
            if(rst_acce)
                next_state <= IDLE;
            else if (start_array)
                next_state <= SA_COMPUTE;
            else 
                next_state <= READ_DATA;
            end
        SA_COMPUTE:begin
            if(rst_acce)
                next_state <= IDLE;
            else if(done)
                next_state <= FINISH;
            else
                next_state <= SA_COMPUTE;
            end
        FINISH:begin
            if(rst_acce)
                next_state <= IDLE;
            else if(state_change ==  3'b101)
                next_state <= WRITE_BUFFER;
            else 
                next_state <= FINISH;
            end
        WRITE_BUFFER:begin
            if(rst_acce)
                next_state <= IDLE;
            else 
                next_state <= WRITE_BUFFER;
            end
        default: begin
                next_state = IDLE;
            end
        endcase
    end
            


always @(posedge clk or negedge rst_acce) begin //还有状态跳转
    case(current_state)
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
//                output_result <= 0;
        end
        READ_INSTR: begin
            ramin_en <= 1;
            ramin_wea <= 0;
            ramin_addr <= ramin_addr + 1;
            ramio_en <= 1;
            ramio_addr <= instruction_buffer_data_out;//五位信号的拆解，还要据此写relu相关的操作
            ramwe_en <= 0;
        end
        READ_DATA: begin
            ramin_en <= 0;
            ramio_en <= 1;
            ramio_wea <= 0;
            ramio_addr <= ramio_addr + 1;
            ramwe_en <= 1;
            ramwe_wea <= 0;
            a_mul_array <= io_buffer_data_out;
            b_mul_array <= weight_buffer_data_out;
        end
        SA_COMPUTE: begin
            ramwe_en <= 0;
            ramio_en <= 0;
            ramin_en <= 0;
            a_mul_array <= io_buffer_data_out;
            b_mul_array <= weight_buffer_data_out;
        end
        FINISH: begin
            ramin_en <= 0;
            ramio_en <= 1;
            ramio_wea <= 1;
            ramwe_en <= 1;
            ramwe_wea <= 1;
            a_mul_array <= 0;
            b_mul_array <= 0;
        end
        WRITE_BUFFER: begin
            ramio_en <= 0;
            ramin_en <= 0;
            ramio_en <= 1;
            ramio_wea <= 1;
            io_buffer_data_in <= output_result;
        end
    endcase
end







endmodule
