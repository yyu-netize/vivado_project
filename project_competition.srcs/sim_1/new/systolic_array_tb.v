`timescale 1ns / 1ps

module tb_systolic_array;

    parameter ARRAY_N = 3;
    parameter LEN_WIDTH = 8;
    parameter A_WIDTH = 8;
    parameter B_WIDTH = 8;
    parameter OUT_WIDTH = 8;
    parameter input_len = 3;

    reg clk;
    reg rst_n;
    reg start;
//    reg [LEN_WIDTH-1:0] input_len;
    reg signed [A_WIDTH*ARRAY_N-1:0] a_mul;
    reg signed [B_WIDTH*ARRAY_N-1:0] b_mul;
//    wire signed [OUT_WIDTH-1:0] pe_out;
//    reg signed [A_WIDTH*ARRAY_N-1:0] _a_mul;
//    reg signed [B_WIDTH*ARRAY_N-1:0] _b_mul;
//    reg signed [OUT_WIDTH*ARRAY_N-1:0] _pe_out;
    wire done;

    // Instantiate the systolic_array module
    systolic_array #(
        .ARRAY_N(ARRAY_N),
        .LEN_WIDTH(LEN_WIDTH),
        .A_WIDTH(A_WIDTH),
        .B_WIDTH(B_WIDTH),
        .OUT_WIDTH(OUT_WIDTH)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
//        .input_len(input_len),
        .a_mul(a_mul),
        .b_mul(b_mul),
//        .pe_out(pe_out),
//        ._a_mul(_a_mul),
//        ._b_mul(_b_mul),
//        ._pe_out(_pe_out),
        .done(done)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        start = 0;
//        input_len = 0;
        a_mul = 0;
        b_mul = 0;

        // Apply reset
        #10 rst_n = 1;

        // Test case 1: Basic multiplication
        #50
        start = 1;
//        input_len = 3;
        #10 a_mul = -2;//less than 255
        b_mul = 3;
        #10 a_mul = -55; b_mul = 4;//less than 65535
        #10 a_mul = 422; b_mul = 5;//16777215
        #10 a_mul = 41; b_mul = 14892;
        #10 a_mul = 30; b_mul = 8;

        #120 start = 0;

        //wait (done);

//        $display("Test case 1: pe_out = %d", pe_out);

//        // Test case 2: Negative values
//        #20 rst_n = 0;
//        #30 rst_n = 1; 
        
//        #50
//        start = 1;
////        input_len = 3;
//        a_mul = -102;//more than -128
//        b_mul = 24;
//        #10 a_mul = -209; b_mul = 23;//less than 65535
//        #10 a_mul = -92738; b_mul = 23;//16777215
//        #10 a_mul = 123; b_mul = 3;
//        #10 a_mul = 12; b_mul = 43;

//        #120 start = 0;

//        //wait (done);

//        $display("Test case 2: pe_out = %d", pe_out);

//        // Test case 3: Zero values
//        #10 rst_n = 0;
//        #20 rst_n = 1; 


//        #50
//        start = 1;
////        input_len = 3;
//        a_mul = 267;
//        b_mul = -468;


//        #120 start = 0;//control the time that the start was set to be 1(actually the period that last operation )

//        //wait (done);

//        #50 $display("Test case 3: pe_out = %d", pe_out);


//        // Test case 4: Zero values
//        #10 rst_n = 0;
//        #20 rst_n = 1; 


//        #50
//        start = 1;

//        a_mul = 2589;
//        b_mul = 578;


//        #120 start = 0;//control the time that the start was set to be 1(actually the period that last operation )

//        //wait (done);

//        #50 $display("Test case 3: _pe_out = %d", _pe_out);

        // End simulation
        #80 $finish;
    end

endmodule
