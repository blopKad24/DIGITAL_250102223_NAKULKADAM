`timescale 1ns / 1ps


// MOORE
module moore(input clk, 
             input reset, 
             input in, 
             output reg out);
  
  
  
parameter START = 5'd0, S0 = 5'd1, S1 = 5'd2,
          S00   = 5'd3, 
          S01   = 5'd4, 
          S10   = 5'd5, 
          S11   = 5'd6,
  
     S000 = 5'd7,   //000
     S001 = 5'd8,   //001
     S010 = 5'd9,   //010
     S011 = 5'd10,  //011
     S100 = 5'd11,  //100
     S101 = 5'd12,  //101
     S110 = 5'd13,  //110
     S111 = 5'd14,  //111

     Sh0   = 5'd15,  //0000
     Sh1   = 5'd16,  //0001
     Sh2   = 5'd17,  //0010
     Sh3   = 5'd18,  //0011
     Sh4   = 5'd19,  //0100
     Sh5   = 5'd20,  //0101
     Sh6   = 5'd21,  //0110
     Sh7   = 5'd22,  //0111
     Sh8   = 5'd23,  //1000
     Sh9   = 5'd24,  //1001
     ShA   = 5'd25,  //1010
     ShB   = 5'd26,  //1011
     ShC   = 5'd27,  //1100
     ShD   = 5'd28,  //1101
     ShE   = 5'd29,  //1110
     ShF   = 5'd30;  //1111
            
  reg [4:0] state, next_state;
  
  
  // Moore Next state mechanism
  always@(posedge clk) begin  //State changes ONLY AT posedge
    if(reset) state<=START;
    else      state<=next_state;
  end
  
  
  always@(*) begin      //Immediately update value of next_state
        case(state)

            START : next_state = in ? S1 : S0;

            S0    : next_state = in ? S01 : S00;
            S1    : next_state = in ? S11 : S10;

            S00   : next_state = in ? S001 : S000;
            S01   : next_state = in ? S011 : S010;
            S10   : next_state = in ? S101 : S100;
            S11   : next_state = in ? S111 : S110;

            // 3-bit states -> 4-bit states
            S000 : next_state = in ? Sh1 : Sh0; //000
            S001 : next_state = in ? Sh3 : Sh2; //001
            S010 : next_state = in ? Sh5 : Sh4; //010
            S011 : next_state = in ? Sh7 : Sh6; //011
            S100 : next_state = in ? Sh9 : Sh8; //100
            S101 : next_state = in ? ShB : ShA; //101
            S110 : next_state = in ? ShD : ShC; //110
            S111 : next_state = in ? ShF : ShE; //111

            // 4-bit states maze
            Sh0 : next_state = in ? Sh1 : Sh0; //0000
            Sh1 : next_state = in ? Sh3 : Sh2; //0001
            Sh2 : next_state = in ? Sh5 : Sh4; //0010
            Sh3 : next_state = in ? Sh7 : Sh6; //0011
            Sh4 : next_state = in ? Sh9 : Sh8; //0100
            Sh5 : next_state = in ? ShB : ShA; //0101
            Sh6 : next_state = in ? ShD : ShC; //0110
            Sh7 : next_state = in ? ShF : ShE; //0111
            Sh8 : next_state = in ? Sh1 : Sh0; //1000
            Sh9 : next_state = in ? Sh3 : Sh2; //1001
            ShA : next_state = in ? Sh5 : Sh4; //1010
            ShB : next_state = in ? Sh7 : Sh6; //1011
            ShC : next_state = in ? Sh9 : Sh8; //1100
            ShD : next_state = in ? ShB : ShA; //1101
            ShE : next_state = in ? ShD : ShC; //1110
            ShF : next_state = in ? ShF : ShE; //1111

        default : next_state = START; 

        endcase
    end
  
  // Moore output logic
  always@(*) begin      //Immediately update value of out
        out=0; 
        case(state)
        
            Sh5, ShA, ShB, ShD : out=1;
                       default : out=0;
        endcase
    end

endmodule
