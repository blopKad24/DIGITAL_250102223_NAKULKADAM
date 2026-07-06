`timescale 1ns / 1ps


module fpr(input clk, 
           input reset, 
           input in,
           output reg done,
           output reg parity_err,
           output reg frame_err, 
           output reg [7:0] data_out);

parameter IDLE   = 2'd0,
          DATA   = 2'd1,
          PARITY = 2'd2,
          STOP   = 2'd3;
          
reg [1:0] state;     //State of current cycle
reg parity_bit;      //To store the bit, so that we can use later
reg [2:0] bit_count; //Counter for the 8 data-bits
reg [7:0] temp_data; //Temporary 8bits of data. stores the data but only transferred if all ok


always @(posedge clk) begin
    if(reset) begin           //In reset, all parameters go to initilized values.
        state <= IDLE;        //These 4 parameters get reset only when reset=1.
        bit_count  <= 3'd7;
        parity_bit <= 1'b0;
        temp_data  <=8'd0;
        
        done       <= 1'b0;   //These 4 parameters get reset every clk cycle.
        parity_err <= 1'b0;
        frame_err  <= 1'b0;
        data_out   <= 8'd0;
    end
    else begin
        done       <=1'b0;
        parity_err <=1'b0;
        frame_err  <=1'b0;
        data_out   <=8'd0; 
        
        case(state)
        IDLE : begin                              //IDLE means waiting for the 0 start bit. 
               if(in==0)begin 
                        state<=DATA;              //Next we'll receive Data bits.
                        bit_count<=3'd7;          //Initialize counter for Data bits.
                        end 
               end
        DATA : begin                              //DATA means we're receiving the Data bits.
               temp_data[bit_count] <= in;
               
               if(bit_count==3'd0) state<=PARITY; //counter reached 0, means Data buts received. We next recieve the Parity bit.
               else bit_count<= bit_count-1'b1;   //counter hasn't reached 0, so reception goes on.
               
               end
      PARITY : begin                              //PARITY means we're receiving Parity bit.
               parity_bit<=in;
               state<=STOP;                       //Next we'll receive the Stop bit.
               end  
      STOP   : begin  
               if(~in)                                 //Stop bit is NOT 1??
                    frame_err <= 1;
               if((^temp_data) != parity_bit)          //Parity received is correct??
                    parity_err <= 1;
               if(in && ((^temp_data) == parity_bit))  //Executes only if BOTH errors DNE. "in" here is the Stopbit
                    data_out<=temp_data;
               else data_out<=8'd0;
               
               done<=1;                                 //Reception of the packet is done !!        
               state<=IDLE;                             //Go back to being IDLE.
               end
               
        default : state<=IDLE;
        endcase
    end
end


endmodule
