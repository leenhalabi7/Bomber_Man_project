
// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018

//-- Eyal Lev 31 Jan 2021

module	objects_mux	(	
//		--------	Clock Input	 	
					input		logic	clk,
					input		logic	resetN,
					
					input		logic	bombDrawingRequest, // two set of inputs per unit
					input		logic	[7:0] bombRGB, 
					
					input		logic	thorDrawingRequest, // two set of inputs per unit
					input		logic	[7:0] thorRGB, 

					input		logic	stoneWallDR, // two set of inputs per unit
					input		logic	grassDR, // two set of inputs per unit
					input		logic	dynLvl1DR, // two set of inputs per unit
					input		logic	dynLvl2DR, // two set of inputs per unit
					input		logic	dynLvl3DR, // two set of inputs per unit
					input		logic	ExplosionDR, // two set of inputs per unit
					input		logic	[7:0] matrix_32RGB,
					

					input		logic	[7:0] RGB_MIF, 
					
					input		logic	lifePointsDR, // two set of inputs per unit
					input		logic	[7:0] RGB_lifePoints, 

					input		logic	scorePointsDR, // two set of inputs per unit
					input		logic	[7:0] RGB_scorePoints, 
					
					input		logic	timerlowDR, // two set of inputs per unit
					input		logic	[7:0] RGB_timerLow,
					
					input		logic	timerhighDR, // two set of inputs per unit
					input		logic	[7:0] RGB_timerHigh,
					
					input		logic	lokiDR, // two set of inputs per unit
					input		logic	[7:0] RGB_loki,
					
					input		logic	thanosDR, // two set of inputs per unit
					input		logic	[7:0] RGB_thanos,
					
				   output	logic	[7:0] RGBOut
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut	<= 8'b0;
	end
	
	
	else begin 
		
			if (bombDrawingRequest == 1'b1 )   
				RGBOut <= bombRGB;  //first priority 
				
			else if (thorDrawingRequest == 1'b1 )   
				RGBOut <= thorRGB;  //first priority 
			 
			 else if (lokiDR == 1'b1)
					RGBOut <= RGB_loki ;
					
			else if (thanosDR == 1'b1)
					RGBOut <= RGB_thanos ;
			 
			 // add logic for box here 
			else if (stoneWallDR == 1'b1 )
				RGBOut <= matrix_32RGB;

			else if (grassDR == 1'b1 )
				RGBOut <= matrix_32RGB;
				
			else if (dynLvl1DR == 1'b1 )
				RGBOut <= matrix_32RGB;
				
			else if (dynLvl2DR == 1'b1)

					RGBOut <= matrix_32RGB;
			else if (dynLvl3DR == 1'b1)
					RGBOut <= matrix_32RGB ;
					
			else if (ExplosionDR == 1'b1)
					RGBOut <= matrix_32RGB ;
					
			else if (lifePointsDR == 1'b1)
					RGBOut <= RGB_lifePoints ;
					
			else if (scorePointsDR == 1'b1)
					RGBOut <= RGB_scorePoints ;

			else if (timerlowDR == 1'b1)
					RGBOut <= RGB_timerLow ;

			else if (timerhighDR == 1'b1)
					RGBOut <= RGB_timerHigh ;
					
			else RGBOut <= RGB_MIF;

			
	end  
end

endmodule





