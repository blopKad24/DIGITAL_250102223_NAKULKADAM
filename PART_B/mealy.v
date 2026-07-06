module mealy(input clk,
             input reset,
             input in,
             output reg out);

parameter START = 4'd0, //x
             S0 = 4'd1, //0
             S1 = 4'd2, //1

          S00 = 4'd3,   //00
          S01 = 4'd4,   //01
          S10 = 4'd5,   //10
          S11 = 4'd6,   //11

          S000 = 4'd7,   //000
          S001 = 4'd8,   //001
          S010 = 4'd9,   //010
          S011 = 4'd10,  //011
          S100 = 4'd11,  //100
          S101 = 4'd12,  //101
          S110 = 4'd13,  //110
          S111 = 4'd14;  //111

reg [3:0] state, next_state; //State of current & next cycle

// Next state WHEN?
always @(posedge clk) begin   //State updated ONLY AT posedge
    if(reset) state <= START;
    else state <= next_state;
end


// Next state HOW?
always @(*) begin       //Immediately update value of next_state

    case(state)

        //0 bits received
        START : next_state = in ? S1 : S0;

        // 1 bit received
        S0 : next_state = in ? S01 : S00;
        S1 : next_state = in ? S11 : S10;

        // 2 bits received
        S00 : next_state = in ? S001 : S000;
        S01 : next_state = in ? S011 : S010;
        S10 : next_state = in ? S101 : S100;
        S11 : next_state = in ? S111 : S110;

        // 3-bit history states
        S000 : next_state = in ? S001 : S000;  //000 -> 001:000
        S001 : next_state = in ? S011 : S010;  //001 -> 011:010
        S010 : next_state = in ? S101 : S100;  //010 -> 101:100
        S011 : next_state = in ? S111 : S110;  //011 -> 111:110
        S100 : next_state = in ? S001 : S000;  //100 -> 001:000
        S101 : next_state = in ? S011 : S010;  //101 -> 011:010
        S110 : next_state = in ? S101 : S100;  //110 -> 101:100
        S111 : next_state = in ? S111 : S110;  //111 -> 111:110

        default : next_state = START;           

    endcase
end


// Mealy output logic
always @(*) begin       //Immediately update value of out
    
    out = 0;                //out reset before computing new output
    case(state)

        S010 : if(in) out=1; //010+1
        S101 :        out=1; //101+x
        S110 : if(in) out=1; //110+1

        default : out = 0;

    endcase
end

endmodule
