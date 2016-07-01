`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:18:01 05/21/2016 
// Design Name: 
// Module Name:    fifoOnSRAM 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module fifoOnSRAM(
    input wire fifoClk,
	 input wire fifoRst,
    input wire start,
    input wire [15:0] dataIn,
    output reg [15:0] DataOut,
	 inout [15:0] IO,
    output reg CE,
    output reg OE,
    output reg WE,
    output reg LB,
    output reg UB,
    
    output reg [17:0] Addr,
	 
	 output reg [3:0] state
    
    );
	 
	 parameter ST_IDLE            =0;
    parameter ST_GET_READY_READ  =1;
	 parameter ST_READ            =2;
	 parameter ST_READ_DONE       =3; 
	 parameter ST_GET_READY_WRITE =4;
    parameter ST_WRITE           =5;
	 parameter ST_INCR_ADDR       =6;
    parameter ST_DONE            =7;
	 
	 parameter sizeOfFIFO = 10;
	 

	 reg [17:0] readAddr;
    reg [17:0] writeAddr;
    reg [15:0] LastReadData;
	 
	 reg DAT_MUX;
	 
	 parameter MUX_FPGA_TO_SRAM =1; //
	 parameter MUX_SRAM_TO_FPGA =0; //
	 //DAT_MUX <=MUX_FPGA_TO_SRAM; 
	 //DAT_MUX <=MUX_SRAM_TO_FPGA;
	 assign IO = (DAT_MUX==1)?(dataIn) :(16'bzzzzzzzzzzzzzzzz) ;
	 
	 always @(posedge fifoClk)
	 begin
	   if(fifoRst==0) 
		  begin
		  // next state
        state   <= ST_IDLE;
		  // Action
        CE<=0;
        OE<=1;
        WE<=1;
        LB<=0;
        UB<=0;
		  readAddr<=1;
		  writeAddr<=0;
		  LastReadData<=0;
        		  
		  end 
	   else 
		  begin 
	     case(state)
	     ST_IDLE: 
		  begin
         if(start==0) 
			  begin 
			  // next state
			  state   <= ST_GET_READY_READ;
			  // Action
			  DataOut <= LastReadData;
			  Addr    <= readAddr;

	        DAT_MUX <=MUX_SRAM_TO_FPGA;
			  
			  WE<=1;
			  OE<=1;
			  CE<=0;
			  UB<=0;
			  LB<=0;		  
			  end 
			else 
			  begin 
			  state   <= ST_IDLE;
			  DataOut <= 16'b1111_1111_1111_1111;
			  end		  
		  end
	     ST_GET_READY_READ: 
		  begin
		    // next state
			 state   <= ST_READ;
		   // Action
			 DAT_MUX <= MUX_SRAM_TO_FPGA;
			 
		    WE<=1;
			 OE<=0;
			 CE<=0;
			 UB<=0;
			 LB<=0;	

		  end
	     ST_READ: 
		  begin
		  // next state
			 state   <= ST_READ_DONE;
		    // Action
			 LastReadData<=IO;     
		    WE<=1;
			 OE<=0;
			 CE<=0;
			 UB<=0;
			 LB<=0;
		  end
	     ST_READ_DONE: 
		  begin
		  // next state
          state   <= ST_GET_READY_WRITE;
		    // Action  
		    WE<=1;
			 OE<=1;
			 CE<=0;
			 UB<=0;
			 LB<=0;	  
		  end
		  
	     ST_GET_READY_WRITE: 
		  begin
		  // next state
		    state   <= ST_WRITE;
			 // Action
			 Addr    <= writeAddr;
			 
			 DAT_MUX <= MUX_FPGA_TO_SRAM;
			 WE<=0;
			 OE<=1;
			 CE<=0;
			 UB<=0;
			 LB<=0;
		  
		  end
	     ST_WRITE: 
		  begin
		  // next state
		    state   <= ST_INCR_ADDR;
		    // Action
		    WE<=0;
			 OE<=1;
			 
			 CE<=0;
			 UB<=0;
			 LB<=0;
		  
		  end
	     ST_INCR_ADDR: 
		  begin 
		  // next state
		    state   <= ST_DONE;
		    // Action
			 if(writeAddr==sizeOfFIFO)
			   begin 
				writeAddr<=0;
				end 
			 else 
			   begin
            writeAddr<=writeAddr+1;				
				end 
			 
			 if(readAddr==sizeOfFIFO)
			   begin 
				readAddr<=0;
				end 
			 else 
			   begin
            readAddr<=readAddr+1;				
				end  
			 
			 
		    WE<=1;
			 OE<=1;
			 
			 CE<=0;
			 UB<=0;
			 LB<=0;

		  end
		  
	     ST_DONE: 
		  begin
          if(start==0) 
			   begin 
				// next state
				state   <= ST_DONE;
				// Action
				Addr <= 18'b11_1111_1111_1111_1111;
				
				WE<=1;
			   OE<=1;
			 
			   CE<=0; 
			   UB<=0;
			   LB<=0;
				
			   end 
			 else 
			   begin
				// next state
            state   <= ST_IDLE;
				// Action
				Addr <= 18'b11_1111_1111_1111_1111;
				
				WE<=1;
			   OE<=1;
			 
			   CE<=0;
			   UB<=0;
			   LB<=0;
				
			   end		  
		  end 
		  default :
		    begin 
			 end 
	     endcase
		  end
	 
	 end
	 
	 


endmodule
