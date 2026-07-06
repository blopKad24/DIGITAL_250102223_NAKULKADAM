`timescale 1ns / 1ps

module cr_tb;
reg in,
    clk,
    reset;        
wire done,
     parity_err,
     frame_err;
wire [7:0] result;

cr dut(.clk(clk),
        .reset(reset),
        .in(in),
        .done(done),
        .parity_err(parity_err),
        .frame_err(frame_err),
        .result(result));


//Clock
initial begin
    clk=0; 
    forever #5 clk=~clk;
end


//HOW is the custom instream is fed? 
task send_stream;                  //task is to send the long 1bit input stream padded with ones on the right after the user's tiny custom stream.
    input [63:0] instream;         //if user wishes, they can change the max length here.
    input integer len;             //len is length of user's tiny custom stream
    integer i;
begin
    for(i=len-1; i>=0; i=i-1)
    begin
        in=instream[i];             //in updates just before the posedge so that it can be used just after posedge for combinational logic.
        @(posedge clk);
    end

    in = 1'b1;                      //this does the padding with 1s.
end
endtask


//WHEN is the custom instream is fed?
initial begin 
    reset=1; in=1;                                        //reset kept till t=15ns (2nd posedge)because there's a clash at t=5ns. 
    @(posedge clk);                                       //cr_tb updates to reset=0 but we want cr to read reset=1 and stay in IDLE
    @(posedge clk);
    reset=0;
    send_stream(31'b1110011011001001110100011101010,31);  //Here, the user can give the input bits of custom length<64.
                                                          //Keep the format same and just put the length after the comma in decimal.
                                                          //My custom stream is 111 011001001001 11 0010011101010 
                                                          //                          packet1           packet2 
                                                          //packet1 has valid parity & frame. packet2 has invalid parity AND invalid frame to check whether teh code detects both at the same packet or not.
    
    #20 $finish;                                          //wait 2 cycles for neatness of waveform
end


//Monitor. was used to see if the state accidently stayed in IDLE
//always @(posedge clk)
//begin
//    $display("t=%0t state=%0d in=%b cmd=%b data=%h done=%b", $time, dut.state, in, dut.cmd, dut.data, done);
//end
endmodule
