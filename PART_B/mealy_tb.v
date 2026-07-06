`timescale 1ns/1ps

// MEALY TB
// sample sequence(in) used is 0101001101010.
// so expected output (out) is 0001100001111.
module mealy_tb;

reg clk, reset, in;
reg [12:0] input_stream, expected_stream;
wire out;
integer i;

function [80:1] state_name;
    input [3:0] st;
    begin
        case(st)
            4'd0  : state_name = "START";
            4'd1  : state_name = "S0";
            4'd2  : state_name = "S1";
            4'd3  : state_name = "S00";
            4'd4  : state_name = "S01";
            4'd5  : state_name = "S10";
            4'd6  : state_name = "S11";
            4'd7  : state_name = "S000";
            4'd8  : state_name = "S001";
            4'd9  : state_name = "S010";
            4'd10 : state_name = "S011";
            4'd11 : state_name = "S100";
            4'd12 : state_name = "S101";
            4'd13 : state_name = "S110";
            4'd14 : state_name = "S111";
            default : state_name = "UNKNOWN";
        endcase
    end
endfunction

mealy dut(.clk(clk),
          .reset(reset),
          .in(in),
          .out(out));


// Clock
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end


// Seeing the output
initial begin

    input_stream    = 13'b0101001101010;
    expected_stream = 13'b0001100001111;

    reset=1; in=0;

    #12; reset=0; $display("time    in   out   exp     state");

    for(i=12;i>=0;i=i-1) begin

        in = input_stream[i];

        @(posedge clk);
        $display("%0t    %0d    %0d   %0d   %s", $time,in, out, expected_stream[i], state_name(dut.state));

    end

    #10;
    $finish;
end

endmodule
