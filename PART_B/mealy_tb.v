`timescale 1ns/1ps

// MEALY TB
// sample sequence(in) used is 0101001101010.
// so expected output (out) is 0001100001111.

module mealy_tb;

reg clk, reset, in;
reg [12:0] input_stream, expected_stream;
wire out;
integer i;

function [80:1] state_name; //Function to return name of state using state's code. (Used in debugging)
    input [3:0] st;         //State code as function input
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
    clk = 0; //Clk starts low. First posedge at 5ns
    forever #5 clk = ~clk;
end


// Seeing the output. NOTE: view output from 5ns!
initial begin

    input_stream    = 13'b0101001101010;
    expected_stream = 13'b0001100001111;
    
    //Waveform to start from 5ns. 0ns to 5ns is kept as START state by forcing reset=1
    //reset released just after 1st posedge (reset=1 needed for 1st posedge. 
    //Else, system never reached START; it will start from arbitrary statr

    reset=1;        
    @(posedge clk);  //reset kept till 1st posedge (5ns)
    #1;              //At 6ns, release reset and start uploading input stream
    reset=0;
    
    for(i=12;i>=0;i=i-1) begin
      
      in = input_stream[i];     //1st bit uploaded at 6ns
      @(posedge clk);           //Rest all 12 bits get uploaded on posedges
    end

   
    #10; //wait 2 cycles for neatness of waveform
    $finish;
end

endmodule
