

module	Game_Controller	(	
 
					input	logic	clk,
					input	logic	resetN, 
					input logic collission_bomber_wall,
					input logic explosion,
					input logic [9:0] keyispressed,
					input logic [3:0] walls_destroyed,
					input	logic	[3:0] HitEdgeCode,
					input logic [3:0] col_count_total,
					input logic collission_bomber_mine,
					input logic end_game_timer,
	
					output logic [3:0] score_out, 
					output logic [3:0] life_out,
					output logic enable_LOSER,
					output logic enable_EXPLOSION_SOUND_START,
					output logic enable_ENDGAME_INTRO_1
					
);



logic [3:0] score_ns, score_ps;


enum logic [4:0] {
    IDLE_ST,                 // initial state
	 WAIT_FOR_EXPLOSION_END_ST,
    COL_BOMBER_WALL_ST,      // Collision with wall
    COL_EXPLOSION_WALL_ST,   // Collision with wall due to explosion
    LOSER_END_GAME_ST,// Game end state
	 WIN_END_GAME_ST
	} SM_PS, SM_NS;
	

 
parameter INITIAL_life_POINTS = 4; 
parameter  INITIAL_SCORE = 0;  
parameter  WIN_SCORE = 9; 

assign life_out = (INITIAL_life_POINTS - col_count_total) > 0 ? INITIAL_life_POINTS - col_count_total : 4'b0;
assign score_out = score_ps;

 //---------
 
 always_ff @(posedge clk or negedge resetN)
		begin : fsm_sync_proc
			if (resetN == 1'b0) begin 
				SM_PS <= IDLE_ST ; 
				score_ps <= INITIAL_SCORE; 
			end 	
			else begin 
				SM_PS  <= SM_NS ;
				score_ps <= score_ns; 
				
			end 
		end // end fsm_sync

 
 ///-----------------
 
 
always_comb 
begin
	// set default values 
		SM_NS = SM_PS ;
		score_ns = score_ps;		
		enable_LOSER = 1'b0;
		enable_EXPLOSION_SOUND_START= 1'b0;
		enable_ENDGAME_INTRO_1 = 1'b0;
		
	case(SM_PS)
	
//------------
		WAIT_FOR_EXPLOSION_END_ST: begin
//------------
			
			if( !explosion ) 
				SM_NS = IDLE_ST; 
			else 
			SM_NS = WAIT_FOR_EXPLOSION_END_ST;
	end	
//------------
		IDLE_ST: begin
//------------
			if(score_ps > (WIN_SCORE-1) ) begin 
				SM_NS =  WIN_END_GAME_ST; 
			end
			else if ( (!life_out) || collission_bomber_mine || end_game_timer) begin
				SM_NS =  LOSER_END_GAME_ST;
			end

			else begin 
				if(explosion) begin
						SM_NS = COL_EXPLOSION_WALL_ST; 
				end

				else if(collission_bomber_wall) begin
						SM_NS = COL_BOMBER_WALL_ST; 
				end
			end
			
			
	end
	
//------------
		COL_BOMBER_WALL_ST:  begin     // done  
//------------
			if (HitEdgeCode [1] && keyispressed[8] || HitEdgeCode [3] && keyispressed[2] || HitEdgeCode [0] && keyispressed[4] || HitEdgeCode [2] && keyispressed[6]) begin
					enable_LOSER = 1'b1; 
					SM_NS = IDLE_ST;
			end 
			else begin 
					SM_NS = IDLE_ST; // No sound if direction does not match
			end 
		end


//------------
		COL_EXPLOSION_WALL_ST:  begin
//------------
			enable_EXPLOSION_SOUND_START = 1'b1;
			score_ns = walls_destroyed; 
			if( !explosion ) 
				SM_NS = IDLE_ST; 
			else 
			SM_NS = WAIT_FOR_EXPLOSION_END_ST;
		end		

//------------
		LOSER_END_GAME_ST:  begin     // done  
//------------
			enable_LOSER = 1'b1;
			SM_NS = LOSER_END_GAME_ST;
		end
		
//------------
		WIN_END_GAME_ST:  begin     // done  
//------------
			enable_ENDGAME_INTRO_1 = 1'b1;
			SM_NS = WIN_END_GAME_ST;
		end


endcase  // case 
end		
	

endmodule	