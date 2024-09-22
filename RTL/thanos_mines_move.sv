// (c) Technion IIT, Department of Electrical Engineering 2023 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updated Eyal Lev April 2023
// updated to state machine Dudy March 2023 


module	thanos_mines_move	(	
 
					input	logic	clk,
					input	logic	resetN,
					input	logic	startOfFrame,  // short pulse every start of frame 30Hz 

					output	 logic signed 	[10:0]	topLeftX, // output the top left corner 
					output	 logic signed	[10:0]	topLeftY  // can be negative , if the object is partliy outside 
					
					
);


// a module used to generate the  ball trajectory.  
parameter int INITIAL_X = 256;
parameter int INITIAL_Y = 256;

parameter int INITIAL_X_SPEED = 40;
const int	FIXED_POINT_MULTIPLIER	=	64; // note it must be 2^n 
// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions


// movement limits 
const int   OBJECT_WIDTH_X = 64;
const int   OBJECT_HIGHT_Y = 64;
const int	SafetyMargin =	32;

const int	x_FRAME_LEFT	=	(SafetyMargin)* FIXED_POINT_MULTIPLIER; 
const int	x_FRAME_RIGHT	=	(512  - OBJECT_WIDTH_X)* FIXED_POINT_MULTIPLIER; 
const int	y_FRAME_TOP		=	(SafetyMargin) * FIXED_POINT_MULTIPLIER;
const int	y_FRAME_BOTTOM	=	(480 - OBJECT_HIGHT_Y ) * FIXED_POINT_MULTIPLIER; //- OBJECT_HIGHT_Y

enum  logic [2:0] {IDLE_ST, // initial state
					MOVE_ST, // moving no colision  	
					POSITION_CHANGE_X_ST, 
					POSITION_LIMITS_ST //check if inside the frame  
					}  SM_PS, 
						SM_NS ;
 
 int Xspeed_PS,  Xspeed_NS  ; 
 int Xposition_PS, Xposition_NS ; //position   
 int Yposition_PS, Yposition_NS ;  

 //---------
 
 always_ff @(posedge clk or negedge resetN)
		begin : fsm_sync_proc
			if (resetN == 1'b0) begin 
				SM_PS <= IDLE_ST ;  
				Xspeed_PS <= INITIAL_X_SPEED ; 
				Xposition_PS <= INITIAL_X  ; 
				Yposition_PS <= INITIAL_Y  ; 
			
			end 	
			else begin 
				SM_PS  <= SM_NS ;
				Xspeed_PS    <=   Xspeed_NS  ; 
				Xposition_PS <=  Xposition_NS    ; 
				Yposition_PS <=  Yposition_NS    ; 
				
			end  
		end // end fsm_sync

 
 ///-----------------
 
 
always_comb 
begin
	// set default values 
		 SM_NS = SM_PS  ; 
		 Xspeed_NS  = Xspeed_PS  ; 
		 Xposition_NS =  Xposition_PS ; 
		 Yposition_NS  = Yposition_PS  ; 
	 	

	case(SM_PS)
//------------
		IDLE_ST: begin
//------------
 
		 Xspeed_NS  = INITIAL_X_SPEED  ; 
		 Xposition_NS = INITIAL_X * FIXED_POINT_MULTIPLIER ; 
		 Yposition_NS = INITIAL_Y * FIXED_POINT_MULTIPLIER ; 

		 if (startOfFrame) 
				SM_NS = MOVE_ST ;
 	
	end
	
//------------
		MOVE_ST:  begin     // moving no colision 
//------------
		
			 
				if (startOfFrame && (Yposition_NS == Yposition_PS) ) 
					SM_NS = POSITION_CHANGE_X_ST ;		
		end

//------------------------
 		POSITION_CHANGE_X_ST : begin  // position interpolate 
//------------------------
			
			Xposition_NS = Xposition_PS + Xspeed_PS;			 
			SM_NS = POSITION_LIMITS_ST;
		end	
		
//------------------------
		POSITION_LIMITS_ST : begin  //check if still inside the frame 
//------------------------

				if (Xposition_PS < x_FRAME_LEFT ) 
						begin  
							Xposition_NS = x_FRAME_LEFT; 
							if (Xspeed_PS < 0 ) // moving to the left 
									Xspeed_NS = 0- Xspeed_PS ; // change direction 
						end ; 
	
				 if (Xposition_PS > x_FRAME_RIGHT) 
						begin  
							Xposition_NS = x_FRAME_RIGHT; 
							if (Xspeed_PS > 0 ) // moving to the right 
									Xspeed_NS = 0- Xspeed_PS ; // change direction 
						end ;
			SM_NS = MOVE_ST ; 
			
		end
		
endcase  // case 
end		
//return from FIXED point  trunc back to prame size parameters 
  
assign 	topLeftX = Xposition_PS / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = Yposition_PS / FIXED_POINT_MULTIPLIER ;    

	

endmodule	
//---------------