module systolic_array #(
    parameter ARRAY_N = 32,
    parameter LEN_WIDTH = 8,
    parameter NUM_PES = ARRAY_N * ARRAY_N,
    parameter A_WIDTH = 8,
    parameter B_WIDTH = 8,
    parameter C_WIDTH = 16, 
    parameter OUT_WIDTH = 8,
    parameter IF_WIDTH = A_WIDTH + B_WIDTH,
    parameter WDATA_WIDTH = NUM_PES * B_WIDTH,
    parameter PEDATA_WIDTH = NUM_PES * A_WIDTH,
    parameter ODATA_WIDTH = ARRAY_N * ARRAY_N * OUT_WIDTH,
    parameter input_len = 3    
) (
    input clk,
    input rst_n,
    input start,
    input empty,
    
//    input [LEN_WIDTH-1:0] input_len, 
    input signed [A_WIDTH*ARRAY_N-1:0] a_mul,
    input signed [B_WIDTH*ARRAY_N-1:0] b_mul,
    output relu,
//    output reg signed [ODATA_WIDTH-1:0] pe_out,
    output reg done
);

reg [LEN_WIDTH-1:0] counter; // Changed counter to be wide enough

wire signed [PEDATA_WIDTH-1:0] inf;
wire signed [WDATA_WIDTH-1:0] w;
wire signed [PEDATA_WIDTH-1:0] _a_mul;
wire signed [WDATA_WIDTH-1:0] _b_mul;
wire signed [ODATA_WIDTH-1:0] _pe_out;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        done <= 0;
        counter <= 0;
//        pe_out <= 0;
    end else if (start) begin
        counter <= counter + 1;
//        pe_out <= _pe_out[OUT_WIDTH-1:0]; // Output only the first element for simplicity
    end
end

wire _done;
assign _done = (counter >= input_len + 2 * (ARRAY_N-1) + 1) ? 1 : 0;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        done <= 0;
    end else begin
        done <= _done;
    end
end


genvar i, j;
generate 
    for (i = 0; i < ARRAY_N; i = i + 1) begin
        for (j = 0; j < ARRAY_N; j = j + 1) begin
            wire ctl, en1, en;
//            assign ctl = (counter > i + j + 1) ? 1 : 0;
//            assign en1 = (counter > i + j ) ? 0 : 1;
//            assign en = ctl && (!en1);
            assign ctl =  (counter > i + j) ? 1 : 0;
            assign en1 = (counter > i + j + input_len) ? 0: 1;
            assign en = ctl && en1;
//            wire count;
//            assign count = counter - i - j + 1;
//            assign en = en1 && (!ctl);
            assign _a_mul[(i*ARRAY_N+j)*A_WIDTH +: A_WIDTH] = (i == 0) ? a_mul[i*A_WIDTH +: A_WIDTH] : inf[((i-1)*ARRAY_N+j)*A_WIDTH +: A_WIDTH];
            assign _b_mul[(i*ARRAY_N+j)*B_WIDTH +: B_WIDTH] = (j == 0) ? b_mul[j*B_WIDTH +: B_WIDTH] : w[(i*ARRAY_N+j-1)*B_WIDTH +: B_WIDTH];
//            assign _a_mul[(i*ARRAY_N+j)*A_WIDTH +: A_WIDTH] = (j == 0) ? a_mul[i*A_WIDTH*count +: A_WIDTH] : inf[(i*ARRAY_N+j-1)*A_WIDTH +: A_WIDTH];
//            assign _b_mul[(i*ARRAY_N+j)*B_WIDTH +: B_WIDTH] = (i == 0) ? b_mul[j*B_WIDTH*count +: B_WIDTH] : w[((i-1)*ARRAY_N+j)*B_WIDTH +: B_WIDTH];

            PE #(
                .A_WIDTH(A_WIDTH),
                .B_WIDTH(B_WIDTH),
                .C_WIDTH(C_WIDTH),
                .OUT_WIDTH(OUT_WIDTH)
            ) PE_INST (
                .clk(clk),
                .rst_n(rst_n),
                .ctl(ctl),
                .en(en),
                .relu(relu),
                .a_mul(_a_mul[(i*ARRAY_N+j)*A_WIDTH +: A_WIDTH]),
                .b_mul(_b_mul[(i*ARRAY_N+j)*B_WIDTH +: B_WIDTH]),
                //.a_out(inf[(i*ARRAY_N+j)*A_WIDTH +: A_WIDTH]),
                .a_out(inf[(i*ARRAY_N +j)*A_WIDTH +: A_WIDTH]),
                .b_out(w[(i*ARRAY_N+j)*B_WIDTH +: B_WIDTH]),
                .result(_pe_out[(i*ARRAY_N+j)*OUT_WIDTH +: OUT_WIDTH])
            ); 
        end
    end
endgenerate


endmodule
