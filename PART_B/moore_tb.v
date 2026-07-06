`timescale 1ns / 1ps

// sample sequence(in) used is 0101001101010.
// so expected output (out) is 0001100001111.

module moore_tb;
  reg clk, reset, in;
  reg [12:0] input_stream, expected_stream; 
  wire out;
  integer i;
  
function [80:1] state_name;
    input [4:0] st;
    begin
        case(st)
            5'd0  : state_name = "START";
            5'd1  : state_name = "S0";
            5'd2  : state_name = "S1";
            
            5'd3  : state_name = "S00";
            5'd4  : state_name = "S01";
            5'd5  : state_name = "S10";
            5'd6  : state_name = "S11";
            
            5'd7  : state_name = "S000";
            5'd8  : state_name = "S001";
            5'd9  : state_name = "S010";
            5'd10 : state_name = "S011";
            5'd11 : state_name = "S100";
            5'd12 : state_name = "S101";
            5'd13 : state_name = "S110";
            5'd14 : state_name = "S111";
            
            5'd15 : state_name = "Sh0";
            5'd16 : state_name = "Sh1";
            5'd17 : state_name = "Sh2";
            5'd18 : state_name = "Sh3";
            5'd19 : state_name = "Sh4";
            5'd20 : state_name = "Sh5";
            5'd21 : state_name = "Sh6";
            5'd22 : state_name = "Sh7";
            5'd23 : state_name = "Sh8";
            5'd24 : state_name = "Sh9";
            5'd25 : state_name = "ShA";
            5'd26 : state_name = "ShB";
            5'd27 : state_name = "ShC";
            5'd28 : state_name = "ShD";
            5'd29 : state_name = "ShE";
            5'd30 : state_name = "ShF";
            
            default : state_name = "UNKNOWN";
        endcase
    end
endfunction  
  
moore dut(.clk(clk), 
          .reset(reset), 
          .in(in), 
          .out(out));
  
 
  // Clock
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  
// Seeing the output. NOTE: view output from 15ns!
initial begin

    input_stream    = 13'b0101001101010;
    expected_stream = 13'b0001100001111;

    reset=1; 
    @(posedge clk);     //(at 5ns) For 1st cycle, reset=1 needed to keep state in START

    #9; reset=0;        //(at 14ns)Just before the posedge, release reset

    for(i=12; i>=0; i=i-1) begin
    
        in = input_stream[i];     //The value of in needs to be updated just BEFORE the posedge.
        #10;                      //So that the combinational switch runs and updates the value of next_state.
                                  //The actual states will be updated AT posedge and immediately the out will be decided for it.
    end                            

    #10;
    $finish;
end
  
endmodule