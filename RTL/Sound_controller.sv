

module	Sound_Controller	(	
 
					input	logic	clk,
					input	logic	resetN, 
					input logic OneSecPulse,
					input logic enable_LOSER_1,
					input logic enable_EXPLOSION_SOUND_START,
					input logic enable_ENDGAME_INTRO_1,
					output logic [3:0] sound,
					output logic sound_enable,
					output logic turbo_enable
					
);




logic [2:0] timer_ns, timer_ps;

enum logic [4:0] {
    IDLE_ST,                 // initial state
	
	 LOSER_1,  // Initial bump
    LOSER_2,   // High rebound note

    // Explosion Sound Sequence States
    EXPLOSION_SOUND_START,       // Start of the explosion sound
    EXPLOSION_SOUND_DESCEND_1,   // Descending tone 1
    EXPLOSION_SOUND_DESCEND_2,   // Descending tone 2
    EXPLOSION_SOUND_RUMBLE,      // Rumbling sound after explosion
    EXPLOSION_SOUND_END,	 // End of explosion sound sequence
	 
	 ENDGAME_INTRO_1,    // Slow buildup
    ENDGAME_INTRO_2,
    ENDGAME_ASCEND_1,   // Rising notes
    ENDGAME_ASCEND_2,
    ENDGAME_PAUSE,      // A brief pause
    ENDGAME_THEME_1,    // Main theme
    ENDGAME_THEME_2,
    ENDGAME_THEME_END
	} SM_PS, SM_NS;
	


 //---------
 
 always_ff @(posedge clk or negedge resetN)
		begin : fsm_sync_proc
			if (resetN == 1'b0) begin 
				SM_PS <= IDLE_ST ; 
				timer_ps <= 3'b0;
				
			end 	
			else begin 
				SM_PS  <= SM_NS ;
				timer_ps <= timer_ns;
				 
			end 
		end // end fsm_sync

 
 ///-----------------
 
 
always_comb 
begin
	// set default values 
		SM_NS = SM_PS ;
		timer_ns = timer_ps;		
	 	sound_enable = 1'b0; 
		sound = 0;
		turbo_enable = 1'b1;	

	case(SM_PS)
	

//------------
		IDLE_ST: begin
//------------
 
			if(enable_LOSER_1) begin 
					SM_NS = LOSER_1; 
			end
			
				
			else if ( enable_EXPLOSION_SOUND_START) begin
					SM_NS = EXPLOSION_SOUND_START;
			end

			else if(enable_ENDGAME_INTRO_1) begin
					SM_NS = ENDGAME_INTRO_1; 
			end
		
		
			
	end
	

//------------
		
		LOSER_1: begin
		  sound_enable = 1'b1;
		  sound = 4'b0001; // Assuming this is a low tone, adjust as per your sound decoder
		  if(OneSecPulse == 1'b1) SM_NS = LOSER_2; // Use a shorter pulse if you want the sound to be very quick
		end

		LOSER_2: begin
		  sound_enable = 1'b1;
		  sound = 4'b0011; // A tone that's higher than the initial bump, adjust as necessary
		  if(OneSecPulse == 1'b1) SM_NS = IDLE_ST;
		 end
		

//------------
	
		EXPLOSION_SOUND_START: begin
			 sound_enable = 1'b1;
			 sound = 4'b1110;  // High-frequency tone. This will be the loudest and sharpest part of the explosion.
			 if(OneSecPulse == 1'b1) SM_NS = EXPLOSION_SOUND_DESCEND_1;  // Move to the next state quickly
		end

		EXPLOSION_SOUND_DESCEND_1: begin
			 sound_enable = 1'b1;
			 sound = 4'b1100;  // A bit lower
			 if(OneSecPulse == 1'b1) SM_NS = EXPLOSION_SOUND_DESCEND_2;
		end

		EXPLOSION_SOUND_DESCEND_2: begin
			 sound_enable = 1'b1;
			 sound = 4'b1010;  // Even lower
			 if(OneSecPulse == 1'b1) SM_NS = EXPLOSION_SOUND_RUMBLE;  // Now move to the rumble phase
		end

		EXPLOSION_SOUND_RUMBLE: begin
			 sound_enable = 1'b1;
			 sound = 4'b1000;  // Low-frequency for rumble
			 if(OneSecPulse == 1'b1) SM_NS = EXPLOSION_SOUND_END;
		end

		EXPLOSION_SOUND_END: begin
			 sound_enable = 1'b0;  // Turn off the sound
			 SM_NS = IDLE_ST;
		end
		

//------------


		 ENDGAME_INTRO_1: begin 
			sound_enable = 1'b1;
			sound = 4'b0010;
			if(OneSecPulse == 1'b1) SM_NS = ENDGAME_INTRO_2;
		 end

		 ENDGAME_INTRO_2: begin
			sound_enable = 1'b1;
			sound = 4'b0011;
			if(OneSecPulse == 1'b1) SM_NS = ENDGAME_ASCEND_1;
		 end

		 ENDGAME_ASCEND_1: begin
			sound_enable = 1'b1;
			sound = 4'b0100;
			if(OneSecPulse == 1'b1) SM_NS = ENDGAME_ASCEND_2;
		 end

		 ENDGAME_ASCEND_2: begin
			sound_enable = 1'b1;
			sound = 4'b0101;
			if(OneSecPulse == 1'b1) SM_NS = ENDGAME_PAUSE;
		 end

		 ENDGAME_PAUSE: begin
			sound_enable = 1'b0;
			if(OneSecPulse == 1'b1) SM_NS = ENDGAME_THEME_1;
		 end

		 ENDGAME_THEME_1: begin
			sound_enable = 1'b1;
			sound = 4'b0110;
			if(OneSecPulse == 1'b1) SM_NS = ENDGAME_THEME_2;
		 end

		 ENDGAME_THEME_2: begin
			sound_enable = 1'b1;
			sound = 4'b0111;
			if(OneSecPulse == 1'b1) SM_NS = ENDGAME_THEME_END;
		 end

		 ENDGAME_THEME_END: begin
			sound_enable = 1'b0;
			SM_NS = IDLE_ST;
		 end



endcase  // case 
end		
	

endmodule	