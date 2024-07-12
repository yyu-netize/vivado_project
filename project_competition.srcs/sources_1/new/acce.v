module PE #(
    parameter A_WIDTH = 8,
    parameter B_WIDTH = 8,
    parameter C_WIDTH = 16, 
    parameter OUT_WIDTH = 8
)(
    input clk,
    input rst_n,
    input ctl, // control whether multiplication or add+multiplication
    input en,
    input relu,
    input signed [A_WIDTH-1:0] a_mul,
    input signed [B_WIDTH-1:0] b_mul,
    output signed [A_WIDTH-1:0] a_out, // the value that will be saved in the register_a
    output signed [B_WIDTH-1:0] b_out,
    output signed [OUT_WIDTH-1:0] result 
);

wire signed [OUT_WIDTH-1:0] _pe_out;
wire signed [OUT_WIDTH-1:0] pe_out;

(* use_dsp = "yes" *) wire signed [C_WIDTH-1:0] _res_mul;
wire signed [OUT_WIDTH-1:0] res_mul;
(* use_dsp = "yes" *) wire signed [C_WIDTH-1:0] _res_acc;
wire signed [OUT_WIDTH-1:0] res_acc;

assign _res_mul = a_mul * b_mul;// 单纯的乘法
assign res_mul = (_res_mul[15:7] == 9'b0 || _res_mul[15:7] == 9'b111111111) ?  _res_mul[7:0] : (_res_mul[15] == 1 ? 8'h80 : 8'h7F) ;//all bits are 0 or 1, implement the initial one 
//assign res_mul =  _res_mul[15:7] == 9'b111111111 ? 1 : 2 ;//all bits are 0 or 1, implement the initial one 

assign _res_acc = res_mul + result;// 乘加
assign res_acc = (_res_acc[15:7] == 9'b0 || _res_acc[15:7] == 9'b111111111) ?  _res_acc[7:0] : (_res_acc[15] == 1 ? 8'h80 : 8'h7F) ;
//assign res_acc = (_res_acc[15:7] == 9'b0 || _res_acc[14:7] == 8'b11111111) ?  _res_acc[7:0] : (_res_acc[15] == 1 ? 8'h80 : 8'h7F) ;

assign pe_out = ctl ? ( relu ? ((res_acc>0)?res_acc:0):res_acc) : res_mul;
//assign _pe_out = ctl ? res_acc : res_mul;
//assign pe_out = relu ? _pe_out : 0;

register #(A_WIDTH) reg_a (clk, rst_n, a_mul, a_out, en);
register #(B_WIDTH) reg_b (clk, rst_n, b_mul, b_out, en);
register #(OUT_WIDTH) reg_result (clk, rst_n, pe_out, result, en);


endmodule


