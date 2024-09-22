
// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018

//-- Eyal Lev 31 Jan 2021

module	mine_mux	(	
//		--------	Clock Input	 	
					input		logic	clk,
					input		logic	resetN,
					
					input		logic	[2:0] random, // two set of inputs per unit
					
				   output	logic	[3:0] random_direction 
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			random_direction	<= 4'b0000;
	end
	
	else begin
		random_direction	<= 4'b0000;
		if (random == 3'b001 ) 
			random_direction[0] <= 1'b1; 
			
		else if (random == 3'b010 ) 
			random_direction[1] <= 1'b1;
			
		else if (random == 3'b011 ) 
			random_direction[2] <= 1'b1;
			
		else  
			random_direction[3] <= 1'b1;
		end  
	end

endmodule





