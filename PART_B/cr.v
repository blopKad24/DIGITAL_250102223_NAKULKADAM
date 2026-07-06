`timescale 1ns / 1ps


module cr(input clk, 
          input reset, 
          input in,
          output reg done,
          output reg parity_err,
          output reg frame_err, 
          output reg [7:0] result);
          
parameter IDLE    = 3'd0,   
          COMMAND = 3'd1,   //Command bits is being received.
          DATA    = 3'd2,   //Data bits are being received.
          PARITY  = 3'd3,   //Parity bit is being received.
          STOP    = 3'd4,   //Stopbit is being received.
          
          LOAD_A  = 2'b00,  
          LOAD_B  = 2'b01,
          ADD     = 2'b10,
          CLEAR   = 2'b11;

reg [2:0] state;      //State of current cycle
reg parity_bit;       //We store the Parity bit, so that we can use later
reg [2:0] dbit_count; //Counter for the 8 data-bits
reg       cbit_count; //Counter for the 2 command-bits
reg [1:0] cmd;        //Command bits
reg [7:0] data;      //Data bits store kar lo to use later
reg [7:0] A, B; 


always@(posedge clk) begin
    if(reset) begin         //In reset, all parameters go to initilized values.
         state<=IDLE;       //These 8 parameters get reset only when reset=1.
         A          <=8'd0;
         B          <=8'd0;
         cmd        <=2'd0;
         dbit_count <=3'd7;
         cbit_count <=1'd1;
         parity_bit <=1'b0;
         data       <=8'd0;
         
         done       <=1'b0; //These 4 parameters get reset for every clk cycle.
         parity_err <=1'b0;
         frame_err  <=1'b0;
         result     <=8'd0;
         end
    else begin
         done       <=1'b0;
         parity_err <=1'b0;
         frame_err  <=1'b0;
         result     <=8'd0; 
         
        case(state)
        IDLE : begin                       //IDLE means waiting for the 0 start bit. 
               if(in==0)begin
                        state<=COMMAND;
                        cbit_count<=1'd1;  //We're going to take cmd bits next, initialize it's counter.
                        end
               end
     COMMAND : begin                       //COMMAND means we're receiving the 2 cmd bits.
               cmd[cbit_count]<=in;  
               
               if(cbit_count==1'd0) begin              //counter reached 0, means cmd bits received. 
                                    state<=DATA;       //Next we're gonna receive Data bits.
                                    dbit_count<=3'd7;  //Initialize counter for Data bits.
                                    end
               else cbit_count<=cbit_count-1;          //Counter didn't reach 0, so reception goes on. 
               
               end
        DATA : begin                                   //DATA means we're receiving the Data bits.
               data[dbit_count]<=in;
               
               if(dbit_count==3'd0) state<=PARITY;     //counter reached 0, means Data buts received. We next recieve the Parity bit.
               else dbit_count<= dbit_count-1'b1;      //counter hasn't reached 0, so reception goes on.
               end
      PARITY : begin                                   //PARITY means we're receiving Parity bit.
               parity_bit<=in;
               state<=STOP;                            //Next we receive the Stop bit.
               end
      STOP   : begin
               if(~in)                                 //Stop bit is NOT 1??
                    frame_err <= 1;
               if((^data) != parity_bit)               //Parity received is correct??
                    parity_err <= 1;

               if(in && ((^data) == parity_bit))  //Executes only if BOTH errors DNE. "in" here is the Stopbit
                    begin
                    
                    case(cmd)
                    LOAD_A : begin
                             A<=data;
                             result<=data;       //due to non-blocking assignment, both will get updated at the end of delta time. So we directly put data in result.
                             end
                    LOAD_B : begin
                             B<=data;
                             result<=data;       //due to non-blocking assignment, both will get updated at the end of delta time. So we directly put data in result.
                             end
                    ADD    : begin
                             result<=A+B;
                             end
                    CLEAR  : begin
                             A<=8'd0;
                             B<=8'd0;
                             result<=8'd0;
                             end
                    endcase
                    end
               done<=1;                         //Reception of the packet is done !!
               state<=IDLE;                     //Go back to being IDLE.
               end    
        endcase
    end
end
endmodule
