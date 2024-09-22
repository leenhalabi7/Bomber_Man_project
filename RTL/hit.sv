
// game controller dudy Febriary 2020
// (c) Technion IIT, Department of Electrical Engineering 2021 
//updated --Eyal Lev 2021


module	hit	(	
			input	logic	bomber_draw_req,
			input	logic	loki_draw_req,
			input	logic	thanos_draw_req,
			input logic Wall_draw_req,
			input logic explosion_draw_req,
			
			output logic collission_bomber_wall, // active in case of collision between two objects
			output logic collission_bomber_mine, // active in case of collision between two objects
			output logic collission_bomber_explosion
	
); 


assign collission_bomber_wall = ( bomber_draw_req && Wall_draw_req ); 
assign collission_bomber_mine = bomber_draw_req && (loki_draw_req || thanos_draw_req); 					 						
assign collission_bomber_explosion = bomber_draw_req && explosion_draw_req;


endmodule
