
module	MatrixBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic [10:0] offsetX,
					input logic [10:0] offsetY,
					input logic [10:0] Bomb_offsetX,
					input logic [10:0] Bomb_offsetY,
					input logic InsideRectangle,
					
					input logic explosion,
					input logic [1:0] random_explosion,
					
					//outputs drawing requests
					output	logic	stoneWallDrawReq, 
					output	logic	dyWall1DrawReq, 
					output	logic	dywall2DrawReq, 
					output	logic	dywall3DrawReq, 
					output	logic	grassDrawReq,
					output	logic	EXPLOSIONDrawReq,
					output 	logic [3:0] walls_destroyed_out,
					output	logic	[7:0] RGBout //rgb value from the bitmap
 
 ) ;
 

// the screen is 640*480  or  20 * 15 squares of 32*32  bits ,  we wiil round up to 16*16 and use only the top left 16*15 squares 
// this is the bitmap  of the maze , if there is a specific value  the  whole 32*32 rectange will be drawn on the screen
// there are  16 options of differents kinds of 32*32 squares 
// all numbers here are hard coded to simplify the  understanding 


//paramaters
localparam  logic	[3:0] GRASS = 4'b0000;
localparam  logic	[3:0] DYNWALVL1 = 4'b0001;
localparam  logic	[3:0] DYNWALVL2 = 4'b0010;
localparam  logic	[3:0] DYNWALVL3 = 4'b0011;
localparam  logic	[3:0] SWALL = 4'b0110;
localparam  logic	[3:0] EXPLOSION = 4'b0111;

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// RGB value in the bitmap representing a transparent pixel 
localparam logic [7:0] COLOR_ENCODING = 8'hFF ;// RGB value in the bitmap representing the BITMAP color

logic [0:15] [0:15] [3:0]  MazeBiMapMask;
logic [3:0] walls_destroyed;
// State variables and timer declaration
logic [3:0] x_idx;
logic [3:0] y_idx;

logic explosionActive;

assign walls_destroyed_out = walls_destroyed;

 always_ff @(posedge clk or negedge resetN) begin
    if (!resetN) begin
			explosionActive <= 1'b0;
			walls_destroyed <= 3'b0;
			
		  MazeBiMapMask= 
		{{SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL},
		 {SWALL, GRASS, GRASS, DYNWALVL3, GRASS, GRASS, GRASS, GRASS, GRASS, GRASS, GRASS, GRASS, GRASS, DYNWALVL3, GRASS, SWALL},
		 {SWALL, SWALL, GRASS, SWALL, DYNWALVL3, SWALL, GRASS, SWALL, GRASS, SWALL, GRASS, SWALL, DYNWALVL3, SWALL, GRASS, SWALL},
		 {SWALL, GRASS, GRASS, DYNWALVL1, GRASS,DYNWALVL2, GRASS, GRASS, GRASS, GRASS, GRASS, DYNWALVL2, GRASS, GRASS, GRASS, SWALL},
		 {SWALL, SWALL, GRASS, SWALL, GRASS, SWALL, DYNWALVL2, SWALL, GRASS, SWALL, DYNWALVL2, SWALL, GRASS, SWALL, GRASS, SWALL},
		 {SWALL, GRASS, GRASS, GRASS, GRASS, GRASS, GRASS, DYNWALVL1, GRASS, DYNWALVL1, GRASS, GRASS, GRASS, GRASS, GRASS, SWALL},
		 {SWALL, SWALL, GRASS, SWALL, GRASS, SWALL, GRASS, SWALL, DYNWALVL1, SWALL, GRASS, SWALL, GRASS, SWALL, GRASS, SWALL},
		 {SWALL, SWALL, GRASS, SWALL, GRASS, SWALL, GRASS, SWALL, GRASS, SWALL, GRASS, SWALL, GRASS, SWALL, GRASS, SWALL},
		 {SWALL, SWALL, GRASS, SWALL, GRASS, SWALL, GRASS, SWALL, DYNWALVL1, SWALL, GRASS, SWALL, GRASS, SWALL, GRASS, SWALL},
		 {SWALL, GRASS, GRASS, GRASS, GRASS, GRASS, GRASS, DYNWALVL1, GRASS, DYNWALVL1, GRASS, GRASS, GRASS, GRASS, GRASS, SWALL},
		 {SWALL, SWALL, GRASS, SWALL, GRASS, SWALL, DYNWALVL2, SWALL, GRASS, SWALL, DYNWALVL2, SWALL, GRASS, SWALL, GRASS, SWALL},
		 {SWALL, GRASS, GRASS, DYNWALVL1, GRASS,DYNWALVL2, GRASS, GRASS, GRASS, GRASS, GRASS, DYNWALVL2, GRASS, GRASS, GRASS, SWALL},
		 {SWALL, SWALL, GRASS, SWALL, DYNWALVL3, SWALL, GRASS, SWALL, GRASS, SWALL, GRASS, SWALL, DYNWALVL3, SWALL, GRASS, SWALL},
		 {SWALL, GRASS, GRASS, DYNWALVL3, GRASS, GRASS, GRASS, GRASS, GRASS, GRASS, GRASS, GRASS, GRASS, DYNWALVL3, GRASS, SWALL},
		 {SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL},
		 {SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL, SWALL,SWALL}};
	end //!resetN
	else begin
		if (explosion & !explosionActive) begin
				explosionActive <= 1'b1;
				//walls_destroyed <= 3'b0;
            x_idx = (Bomb_offsetX+16 >> 5);
            y_idx = (Bomb_offsetY+16 >> 5);
				
				case (MazeBiMapMask[y_idx][x_idx]) 
							DYNWALVL1: MazeBiMapMask[y_idx][x_idx] <= GRASS;
                     DYNWALVL2: MazeBiMapMask[y_idx][x_idx] <= DYNWALVL1;
							DYNWALVL3: MazeBiMapMask[y_idx][x_idx] <= DYNWALVL2;
                     default: 
								if (MazeBiMapMask[y_idx][x_idx] < SWALL) begin
									MazeBiMapMask[y_idx][x_idx] <= EXPLOSION;
								end //if
            endcase
				if(random_explosion) begin
				
					if (x_idx - 1 >= 0 && MazeBiMapMask[y_idx][x_idx - 1] != SWALL) begin
					// Update the cell to the left of the explosion
						
							case (MazeBiMapMask[y_idx][x_idx - 1]) 
										DYNWALVL1: begin 
												MazeBiMapMask[y_idx][x_idx - 1] <= GRASS;
												walls_destroyed  <= walls_destroyed +1; 
										end
										 DYNWALVL2: begin 
												MazeBiMapMask[y_idx][x_idx - 1] <= DYNWALVL1;
												walls_destroyed  <= walls_destroyed +1; 
										end
										 DYNWALVL3: begin 
												MazeBiMapMask[y_idx][x_idx - 1] <= DYNWALVL2;
												walls_destroyed  <= walls_destroyed +1;
										end
										 default: 
											  if (MazeBiMapMask[y_idx][x_idx - 1] < SWALL) begin
													MazeBiMapMask[y_idx][x_idx - 1] <= EXPLOSION;
												end //if
							 endcase
					end //left direction
					
					if (x_idx + 1 < 16 && MazeBiMapMask[y_idx][x_idx + 1] != SWALL) begin
							 case (MazeBiMapMask[y_idx][x_idx + 1]) 
								  DYNWALVL1: begin 
										MazeBiMapMask[y_idx][x_idx + 1] <= GRASS;
										walls_destroyed  <= walls_destroyed +1; 
								  end
								  DYNWALVL2: begin 
										MazeBiMapMask[y_idx][x_idx + 1] <= DYNWALVL1;
										walls_destroyed  <= walls_destroyed +1; 
								  end
								  DYNWALVL3: begin 
										MazeBiMapMask[y_idx][x_idx + 1] <= DYNWALVL2;
										walls_destroyed  <= walls_destroyed +1;
								  end
								  default: 
										if (MazeBiMapMask[y_idx][x_idx + 1] < SWALL) begin
											 MazeBiMapMask[y_idx][x_idx + 1] <= EXPLOSION;
										end //if
							 endcase
						end //right direction
						
				end //random_explosion(horizon) 
				
				if(random_explosion == 0) begin 
				
					if (y_idx - 1 >= 0 && MazeBiMapMask[y_idx - 1][x_idx] != SWALL) begin
							 case (MazeBiMapMask[y_idx - 1][x_idx]) 
								  DYNWALVL1: begin 
										MazeBiMapMask[y_idx - 1][x_idx] <= GRASS;
										walls_destroyed  <= walls_destroyed +1; 
								  end
								  DYNWALVL2: begin 
										MazeBiMapMask[y_idx - 1][x_idx] <= DYNWALVL1;
										walls_destroyed  <= walls_destroyed +1; 
								  end
								  DYNWALVL3: begin 
										MazeBiMapMask[y_idx - 1][x_idx] <= DYNWALVL2;
										walls_destroyed  <= walls_destroyed +1;
								  end
								  default: 
										if (MazeBiMapMask[y_idx - 1][x_idx] < SWALL) begin
											 MazeBiMapMask[y_idx - 1][x_idx] <= EXPLOSION;
										end //if
							 endcase
						end //up direction 
				
					if (y_idx + 1 < 16 && MazeBiMapMask[y_idx + 1][x_idx] != SWALL) begin
							 case (MazeBiMapMask[y_idx + 1][x_idx]) 
								  DYNWALVL1: begin 
										MazeBiMapMask[y_idx + 1][x_idx] <= GRASS;
										walls_destroyed  <= walls_destroyed +1; 
								  end
								  DYNWALVL2: begin 
										MazeBiMapMask[y_idx + 1][x_idx] <= DYNWALVL1;
										walls_destroyed  <= walls_destroyed +1; 
								  end
								  DYNWALVL3: begin 
										MazeBiMapMask[y_idx + 1][x_idx] <= DYNWALVL2;
										walls_destroyed  <= walls_destroyed +1;
								  end
								  default: 
										if (MazeBiMapMask[y_idx + 1][x_idx] < SWALL) begin
											 MazeBiMapMask[y_idx + 1][x_idx] <= EXPLOSION;
										end //if
							 endcase
					end // down direction
				end  //random_explosion(vertical)
			end // if explosion
				
        if (!explosion) begin
					
					
					if (MazeBiMapMask[y_idx][x_idx] == EXPLOSION) begin
							MazeBiMapMask[y_idx][x_idx] <= GRASS;
					end 

					if (x_idx - 1 >= 0 && MazeBiMapMask[y_idx][x_idx - 1] == EXPLOSION) begin
							MazeBiMapMask[y_idx][x_idx - 1] <= GRASS;
					end 
					if (x_idx + 1 < 16 && MazeBiMapMask[y_idx][x_idx + 1] == EXPLOSION) begin
							MazeBiMapMask[y_idx][x_idx + 1] <= GRASS;
					end
					if (y_idx - 1 >= 0 && MazeBiMapMask[y_idx - 1][x_idx] == EXPLOSION) begin
							MazeBiMapMask[y_idx - 1][x_idx] <= GRASS;
					end 
					if (y_idx + 1 >= 0 && MazeBiMapMask[y_idx + 1][x_idx] == EXPLOSION) begin
							MazeBiMapMask[y_idx + 1][x_idx] <= GRASS;
					end
					explosionActive <= 1'b0;
					//walls_destroyed <= 3'b0;
        end // if !explosion
    end
end

//stone wall object colors

logic[0:31][0:31][7:0] sWall_colors = {
	{8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24},
	{8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24},
	{8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24},
	{8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24},
	{8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h24,8'h24,8'h6d,8'h6d,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24},
	{8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h24,8'h24,8'h6d,8'h6d,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24},
	{8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24},
	{8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24},
	{8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24},
	{8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24},
	{8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h6d,8'h6d,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24},
	{8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h6d,8'h6d,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24},
	{8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24},
	{8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24},
	{8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h24,8'h24},
	{8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h24,8'h24},
	{8'h24,8'h24,8'h24,8'h24,8'h6d,8'h6d,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24},
	{8'h24,8'h24,8'h24,8'h24,8'h6d,8'h6d,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24},
	{8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24},
	{8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24},
	{8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24},
	{8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24},
	{8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24},
	{8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24},
	{8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24},
	{8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24},
	{8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24},
	{8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24},
	{8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24},
	{8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24},
	{8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24},
	{8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24}};



//dynamic wall lvl 1
logic[0:31][0:31][7:0] dynWall1_colors = {
	{8'hac,8'h00,8'h00,8'hac,8'hac,8'hac,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hac,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'hff},
	{8'hac,8'h00,8'h00,8'hac,8'hac,8'hac,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'hac,8'h00,8'h00,8'hac,8'hac,8'hb1,8'hff,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'h00},
	{8'hac,8'h00,8'h00,8'hac,8'hac,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hac,8'h00,8'h00,8'hac,8'hac,8'hac,8'hff,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hac,8'h00,8'h00,8'hac,8'hac,8'hac,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hac,8'hac,8'h00,8'hac,8'hac,8'h00,8'h00,8'h00,8'had,8'hac,8'hac,8'hac,8'hac,8'hac,8'had,8'h00,8'h00,8'h84,8'hac},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hac,8'h00,8'hac,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'had,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'h00,8'hac,8'hff},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hac,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h8c,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'h20,8'h00,8'hac,8'hac},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h8c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h8c,8'hac,8'h00,8'h00,8'h00,8'h00,8'h20,8'h20,8'h00,8'hac,8'hac},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h20,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h64,8'hac,8'h00,8'h00,8'h00,8'h20,8'h20,8'h20,8'h00,8'hac,8'hac},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hac,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h64,8'h20,8'h00,8'h00,8'h00,8'h64,8'h00,8'h00,8'h20,8'h20,8'h20,8'h20,8'h20,8'h00,8'hac,8'hac},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hac,8'hac,8'h00,8'h00,8'h20,8'h20,8'h20,8'h00,8'hac,8'hac,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h20,8'h20,8'h20,8'h20,8'h20,8'h00,8'hac,8'hac},
	{8'hac,8'h00,8'h00,8'h00,8'h00,8'h00,8'hac,8'hac,8'hac,8'h00,8'h20,8'h20,8'h20,8'h00,8'hac,8'hac,8'hac,8'hac,8'hff,8'h00,8'h00,8'h00,8'h00,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h00,8'h00,8'h00},
	{8'hac,8'h00,8'h00,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'h00,8'h20,8'h20,8'h20,8'h00,8'hac,8'hac,8'hac,8'hac,8'hff,8'h00,8'h00,8'h00,8'h00,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h00,8'h00,8'h00},
	{8'hac,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'h20,8'h20,8'h20,8'h00,8'h00,8'hac,8'hac,8'hac,8'hff,8'h00,8'h00,8'h00,8'h00,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h00,8'h00,8'h00},
	{8'hac,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'h20,8'h20,8'h20,8'h00,8'h00,8'hac,8'hac,8'hff,8'h00,8'h00,8'h00,8'h00,8'h20,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'hac,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'h20,8'h20,8'h20,8'h00,8'h00,8'hac,8'hac,8'h00,8'h00,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h20,8'h20,8'h00,8'h00,8'h00,8'hac,8'h00,8'h00,8'h00,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'had,8'hac,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'hac,8'hac,8'h84,8'hac,8'h00,8'h00,8'h20,8'h00,8'h20,8'h20,8'h00,8'h00,8'h00,8'h00,8'h00,8'hac,8'h00,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'h24,8'h20,8'h20,8'h00,8'h00,8'h20,8'h00,8'h00,8'h00,8'h00,8'h24,8'hac,8'h00,8'h00,8'h00,8'h8d,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'hac,8'hac,8'hac,8'h00,8'h20,8'h20,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hac,8'h00,8'h00,8'h00,8'had,8'hac,8'h00,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h20,8'h20,8'h20,8'h20,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hac,8'hac,8'h00,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h20,8'h20,8'h20,8'h20,8'h20,8'h00,8'h00,8'hac,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hac,8'hac,8'h00,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h20,8'h20,8'h20,8'h20,8'h20,8'h00,8'h00,8'hac,8'h00,8'hac,8'h8c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hac,8'hac,8'h00,8'h00,8'h00,8'hac,8'hac,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'h00,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'hac,8'h00,8'h00,8'h00,8'hac,8'hac,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'hff,8'h64,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'hac,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'hac,8'hac,8'hac,8'h24,8'h00,8'h00,8'h00,8'hac,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'hac,8'hac,8'h00,8'hac,8'hac,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'h00,8'hac,8'h00,8'hac,8'hac,8'h00,8'h00,8'hac,8'hac,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'hac,8'hac,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hac,8'had,8'h00,8'h00,8'hac,8'hac,8'hac,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'hac,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hac,8'h00,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}};



//dynamic wall lvl 2
logic[0:31][0:31][7:0] dynWall2_colors = {
	{8'hac,8'h00,8'h00,8'hac,8'hac,8'hac,8'had,8'hac,8'hac,8'hac,8'h00,8'hac,8'hac,8'hac,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'h20,8'h20},
	{8'hac,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'hac,8'hac,8'hac,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'h20,8'h20},
	{8'hac,8'h00,8'h00,8'hac,8'hac,8'h00,8'hac,8'hac,8'hac,8'hac,8'h00,8'hac,8'hac,8'h00,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h00,8'hac,8'hac,8'hac,8'had,8'h00,8'h00,8'h00,8'h00,8'h00,8'h20,8'h20},
	{8'h00,8'h00,8'h00,8'had,8'had,8'hac,8'had,8'hac,8'hac,8'hac,8'h00,8'h00,8'ha4,8'hac,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h00,8'h00,8'h00,8'h00,8'h20,8'h20,8'h20,8'h20,8'h00,8'h00,8'h00,8'h20},
	{8'h00,8'h00,8'h00,8'h2c,8'h2c,8'h2c,8'h2c,8'hac,8'hac,8'hac,8'h00,8'h00,8'hac,8'hac,8'hac,8'h20,8'h20,8'h20,8'h20,8'h20,8'h00,8'had,8'hac,8'hac,8'h20,8'h20,8'h20,8'h20,8'h00,8'h00,8'h00,8'h00},
	{8'hac,8'h00,8'h2c,8'h2c,8'h2c,8'h2c,8'h2c,8'h2c,8'h00,8'h00,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'h20,8'h20,8'h00,8'hac,8'h00,8'had,8'hac,8'hac,8'h20,8'h20,8'h20,8'h20,8'hac,8'h00,8'h84,8'hac},
	{8'hac,8'h00,8'h2c,8'h2c,8'h2c,8'h2c,8'h2c,8'h2c,8'hac,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'h20,8'h20,8'hac,8'hac,8'h00,8'had,8'hac,8'hac,8'h20,8'h20,8'h20,8'h20,8'hac,8'h00,8'hac,8'hf7},
	{8'hac,8'h00,8'h6c,8'h2c,8'h2c,8'h2c,8'h2c,8'h8c,8'hac,8'h00,8'h00,8'hac,8'h00,8'hac,8'hac,8'hac,8'hac,8'h64,8'hac,8'hac,8'h00,8'ha5,8'hac,8'hac,8'h20,8'h20,8'h20,8'hac,8'hac,8'h00,8'hac,8'hac},
	{8'hac,8'h00,8'h2c,8'h2c,8'h2c,8'h2c,8'h2c,8'hac,8'hac,8'h00,8'h00,8'h85,8'h00,8'had,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'h84,8'hac,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'hac,8'hac},
	{8'hac,8'h00,8'h2c,8'h2c,8'h2c,8'h2c,8'hac,8'hac,8'hac,8'h00,8'h20,8'h20,8'h20,8'h20,8'h20,8'hac,8'hac,8'hac,8'hac,8'ha4,8'h00,8'h84,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h20,8'h00,8'hac,8'hac},
	{8'hac,8'h00,8'h2c,8'h2c,8'h2c,8'h2c,8'hac,8'hac,8'hac,8'h00,8'h20,8'h20,8'h20,8'h20,8'h20,8'h00,8'h64,8'h20,8'h00,8'h00,8'h00,8'h60,8'h84,8'hac,8'hac,8'hac,8'hac,8'h20,8'h20,8'h00,8'hac,8'hac},
	{8'hac,8'h00,8'h2c,8'h2c,8'h2c,8'hac,8'hac,8'hac,8'hac,8'h00,8'h20,8'h20,8'h20,8'h20,8'h20,8'hac,8'hac,8'hf7,8'hf7,8'h00,8'h00,8'ha5,8'hac,8'hac,8'hac,8'hac,8'h20,8'h20,8'h20,8'h00,8'hac,8'hac},
	{8'hac,8'h00,8'h2c,8'h2c,8'h2c,8'hac,8'hac,8'hac,8'hac,8'h00,8'h20,8'h20,8'h20,8'h20,8'hac,8'hac,8'hac,8'hac,8'hf7,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'h20,8'h20,8'h20,8'h20,8'h00,8'h00,8'h00},
	{8'hac,8'h00,8'h2c,8'h2c,8'h2c,8'hac,8'hac,8'hac,8'hac,8'h00,8'h20,8'h20,8'h20,8'hac,8'hac,8'hac,8'hac,8'hac,8'hf7,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'h20,8'h20,8'h20,8'h20,8'h00,8'h00,8'h00},
	{8'hac,8'h00,8'h2c,8'h2c,8'hac,8'hac,8'hac,8'hac,8'hac,8'h20,8'h20,8'h20,8'hac,8'hac,8'had,8'hac,8'hac,8'hac,8'hf7,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'h20,8'h20,8'h20,8'h20,8'h00,8'h00,8'h00},
	{8'h20,8'h00,8'h2c,8'h2c,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h20,8'hac,8'hac,8'hac,8'hac,8'h00,8'hac,8'hac,8'hf7,8'h00,8'h00,8'h00,8'h00,8'h20,8'h00,8'h00,8'h2c,8'h2c,8'h00,8'h00,8'h64,8'hac},
	{8'h20,8'h00,8'h2c,8'h2c,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'h00,8'h00,8'h2c,8'h2c,8'h2c,8'h2c,8'h2c,8'h2c,8'hac,8'h00,8'h65,8'hac},
	{8'h20,8'h20,8'had,8'h2c,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h84,8'hac,8'hac,8'hac,8'hac,8'h00,8'hac,8'h00,8'h20,8'h20,8'h00,8'h2c,8'h2c,8'h2c,8'h2c,8'h2c,8'h2c,8'h2c,8'hac,8'h00,8'h84,8'hac},
	{8'h20,8'h20,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'h20,8'h20,8'h20,8'h00,8'h2c,8'h2c,8'h2c,8'h2c,8'h2c,8'h2c,8'h2c,8'hac,8'h00,8'hac,8'hac},
	{8'h20,8'h20,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'hac,8'hac,8'hac,8'hac,8'h20,8'h20,8'h20,8'h20,8'h20,8'h00,8'h00,8'h2c,8'h2d,8'h2c,8'h2c,8'h2c,8'h2c,8'hac,8'h00,8'hac,8'hac},
	{8'h20,8'h20,8'ha4,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'hac,8'hac,8'hac,8'hac,8'had,8'h20,8'h20,8'h20,8'h20,8'h00,8'h00,8'had,8'hac,8'h2c,8'h2c,8'h2c,8'h2c,8'hac,8'h00,8'hac,8'hac},
	{8'h20,8'h20,8'ha4,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'h84,8'hac,8'hac,8'hac,8'h20,8'h20,8'h20,8'h20,8'h00,8'h00,8'hac,8'hac,8'h00,8'hac,8'h2c,8'h2c,8'hac,8'h00,8'hac,8'hac},
	{8'h20,8'h20,8'h65,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'hac,8'h00,8'h00,8'had,8'hac,8'hac,8'h20,8'h20,8'h20,8'h00,8'h00,8'hac,8'hac,8'h00,8'hac,8'h2c,8'h2c,8'hac,8'h00,8'hac,8'hac},
	{8'h20,8'h20,8'h20,8'h20,8'hac,8'hac,8'hac,8'hac,8'had,8'hac,8'h00,8'hac,8'h00,8'hac,8'h85,8'h00,8'h00,8'h00,8'hac,8'h00,8'h00,8'h00,8'hac,8'hac,8'h00,8'h00,8'h00,8'hac,8'hac,8'h00,8'hac,8'hac},
	{8'h20,8'h20,8'h20,8'h20,8'h20,8'h00,8'h00,8'h00,8'hf7,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'h00,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'h00,8'hac,8'hac},
	{8'h20,8'h20,8'h20,8'h20,8'h64,8'hac,8'hac,8'hac,8'h00,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'hac,8'h00,8'h00,8'h00,8'hac,8'hac,8'h00,8'h00,8'h00,8'hac,8'hac,8'h00,8'hac,8'hac},
	{8'h20,8'h20,8'h20,8'h20,8'hac,8'hac,8'hac,8'hac,8'hf7,8'h64,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'hac,8'h00,8'h00,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'hac,8'hac},
	{8'h20,8'h20,8'h20,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'hac,8'hac,8'hac,8'h64,8'h20,8'h20,8'h00,8'hac,8'h00,8'h00,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'had,8'h64,8'hac},
	{8'h20,8'h20,8'hac,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'hac,8'hac,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hcc,8'h00,8'hac},
	{8'h20,8'h20,8'hac,8'h00,8'hac,8'hac,8'hac,8'hac,8'h00,8'h00,8'h00,8'hac,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'had,8'h00,8'h00},
	{8'h20,8'had,8'hac,8'h00,8'hac,8'hac,8'h00,8'h00,8'h00,8'h00,8'h00,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'had,8'h00,8'h00},
	{8'h20,8'hac,8'hac,8'h00,8'hac,8'h00,8'h00,8'h00,8'h00,8'h00,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'had,8'h00,8'h00}};


//dynamic wall lvl 3	
logic[0:31][0:31][7:0] dynWall3_colors = {
	{8'hac,8'h24,8'h00,8'hac,8'hac,8'hac,8'hac,8'hb0,8'hac,8'h20,8'h00,8'h8c,8'hac,8'hac,8'hac,8'hac,8'hac,8'hb0,8'hd0,8'h64,8'h00,8'h64,8'hac,8'hac,8'hac,8'hac,8'hac,8'hd0,8'h64,8'h20,8'hac,8'hd4},
	{8'hac,8'h24,8'h00,8'hac,8'hac,8'hac,8'hac,8'hd4,8'hd4,8'h20,8'h00,8'h84,8'hac,8'hac,8'hac,8'hac,8'hac,8'hb0,8'hf4,8'h64,8'h00,8'h64,8'hac,8'hac,8'hac,8'hac,8'hac,8'hd4,8'h8c,8'h20,8'hac,8'hb0},
	{8'hac,8'h24,8'h00,8'hac,8'hac,8'hac,8'hac,8'hb0,8'hd4,8'h20,8'h00,8'h84,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hf4,8'h64,8'h00,8'h64,8'hac,8'hac,8'hac,8'hac,8'hac,8'hd0,8'h8c,8'h20,8'hac,8'hac},
	{8'h20,8'h00,8'h20,8'hac,8'hac,8'hac,8'hac,8'hb0,8'hd4,8'h20,8'h00,8'h84,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h00,8'h64,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h24,8'hcc,8'hac},
	{8'h00,8'h00,8'h20,8'hac,8'hac,8'hac,8'hac,8'hac,8'hb0,8'h20,8'h00,8'h84,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h00,8'h64,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h00,8'h20,8'h20},
	{8'hac,8'h20,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h24,8'h00,8'h84,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h00,8'h64,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h00,8'h64,8'h6c},
	{8'hac,8'h20,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h24,8'h00,8'h84,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h00,8'h64,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h20,8'hd0,8'hd4},
	{8'hac,8'h20,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h24,8'h00,8'h84,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h00,8'h64,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h20,8'hac,8'hac},
	{8'hac,8'h20,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h24,8'h00,8'h8c,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hcc,8'h64,8'h00,8'h64,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h20,8'hac,8'hac},
	{8'hac,8'h20,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h24,8'h00,8'h64,8'h84,8'h64,8'h84,8'h84,8'h84,8'h84,8'h84,8'h20,8'h00,8'h64,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h20,8'hac,8'hac},
	{8'hac,8'h20,8'h00,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h24,8'h00,8'h24,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h20,8'h00,8'h64,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h20,8'hac,8'hac},
	{8'hac,8'h20,8'h20,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h00,8'h8c,8'hcc,8'hac,8'hac,8'hac,8'hac,8'hd0,8'hf4,8'h64,8'h00,8'h64,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h20,8'hac,8'hac},
	{8'hac,8'h20,8'h20,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h00,8'h84,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hf4,8'h64,8'h00,8'h64,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h20,8'hac,8'hac},
	{8'hac,8'h20,8'h20,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h00,8'h84,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hf4,8'h64,8'h00,8'h64,8'hcc,8'hac,8'hac,8'hac,8'hac,8'hcc,8'h84,8'h20,8'hac,8'hac},
	{8'hac,8'h20,8'h20,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h00,8'h84,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hf4,8'h64,8'h00,8'h20,8'h84,8'h64,8'h64,8'h64,8'h64,8'h8c,8'h64,8'h20,8'hac,8'hac},
	{8'hac,8'h20,8'h20,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h00,8'h84,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hd4,8'h64,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h20,8'hac,8'hac},
	{8'hac,8'h20,8'h20,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h00,8'h84,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h24,8'h00,8'h64,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h20,8'hac,8'hac},
	{8'hac,8'h20,8'h20,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h00,8'h84,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h24,8'h00,8'h64,8'hac,8'hac,8'hac,8'hac,8'hac,8'hf4,8'h8c,8'h20,8'hac,8'hac},
	{8'hac,8'h20,8'h20,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h00,8'h84,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h24,8'h00,8'h64,8'hac,8'hac,8'hac,8'hac,8'hac,8'hd4,8'h8c,8'h20,8'hac,8'hac},
	{8'hac,8'h20,8'h20,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h00,8'h84,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h24,8'h00,8'h64,8'hac,8'hac,8'hac,8'hac,8'hac,8'hd0,8'h8c,8'h20,8'hac,8'hac},
	{8'hac,8'h20,8'h20,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h00,8'h84,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h24,8'h00,8'h64,8'hac,8'hac,8'hac,8'hac,8'hac,8'hd0,8'h8c,8'h20,8'hac,8'hac},
	{8'hac,8'h20,8'h20,8'hcc,8'hac,8'hac,8'hac,8'hac,8'hcc,8'h64,8'h00,8'h84,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h24,8'h00,8'h64,8'hac,8'hac,8'hac,8'hac,8'hac,8'hb0,8'h8c,8'h20,8'hac,8'hac},
	{8'hac,8'h20,8'h00,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h20,8'h00,8'h84,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h24,8'h00,8'h64,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h20,8'hac,8'hac},
	{8'hac,8'h20,8'h00,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h00,8'h00,8'h84,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h24,8'h00,8'h64,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h84,8'h20,8'hac,8'hac},
	{8'hac,8'h20,8'h20,8'hac,8'hac,8'hac,8'hac,8'hd0,8'hf4,8'h64,8'h00,8'h84,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h24,8'h00,8'h64,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h84,8'h20,8'hac,8'hac},
	{8'hac,8'h20,8'h20,8'hac,8'hac,8'hac,8'hac,8'hb0,8'hf4,8'h6c,8'h00,8'h84,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h24,8'h00,8'h64,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h84,8'h20,8'hac,8'hac},
	{8'hac,8'h20,8'h20,8'hac,8'hac,8'hac,8'hac,8'hac,8'hd4,8'h6c,8'h00,8'h84,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h24,8'h00,8'h64,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h84,8'h20,8'hac,8'hac},
	{8'hac,8'h20,8'h20,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h00,8'h84,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h24,8'h00,8'h64,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h84,8'h20,8'hac,8'hac},
	{8'h24,8'h00,8'h20,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h00,8'h84,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h24,8'h00,8'h24,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h84,8'h20,8'hac,8'hac},
	{8'h00,8'h00,8'h20,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h00,8'h84,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h24,8'h00,8'h24,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h84,8'h00,8'h00,8'h00},
	{8'hac,8'h20,8'h20,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h00,8'h84,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h24,8'h00,8'h24,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h84,8'h00,8'h84,8'h84},
	{8'hac,8'h20,8'h20,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h64,8'h00,8'h84,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h24,8'h00,8'h24,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h84,8'h20,8'hac,8'hac}};



//grass
logic[0:31][0:31][7:0] grass_colors = {
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe},
	{8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe}};

	
//bomb exploded object colors
logic[0:31][0:31][7:0] EXPLOSION_colors = {
	{8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h60,8'h20,8'h20,8'h60,8'hcc,8'hcc,8'hc4,8'hc4,8'hfa,8'hd1,8'hc4,8'h84,8'h80,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84},
	{8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h60,8'h60,8'h84,8'hcc,8'hc4,8'hcc,8'hfa,8'hff,8'hd1,8'ha4,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h60,8'h80,8'h84,8'h84,8'h84,8'h84,8'h84},
	{8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h80,8'ha4,8'hcc,8'hcc,8'hc4,8'hcc,8'hff,8'hff,8'hff,8'hcc,8'ha4,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h60,8'h20,8'h60,8'h84,8'h84,8'h84,8'h84,8'h84},
	{8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'ha4,8'hcc,8'ha4,8'hd1,8'hff,8'hfe,8'hfd,8'hff,8'hcc,8'ha4,8'h84,8'h80,8'h60,8'h84,8'h84,8'h84,8'h60,8'h20,8'h60,8'h84,8'h84,8'h84,8'h84,8'h84},
	{8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h80,8'h84,8'hcc,8'ha4,8'hd1,8'hff,8'hfe,8'hfc,8'hfc,8'hff,8'hd1,8'ha4,8'h84,8'h20,8'h20,8'h80,8'h84,8'h80,8'h20,8'h20,8'h80,8'h84,8'h84,8'h84,8'h84,8'h84},
	{8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h80,8'ha4,8'hc4,8'hcc,8'hff,8'hfe,8'hfc,8'hfc,8'hfc,8'hff,8'hf6,8'hc4,8'h64,8'h20,8'h20,8'h60,8'h84,8'h84,8'h80,8'h60,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84},
	{8'h60,8'h80,8'h84,8'h84,8'h80,8'h80,8'h84,8'ha4,8'hcc,8'hff,8'hfe,8'hfc,8'hfc,8'hfc,8'hfc,8'hfe,8'hff,8'hcc,8'h84,8'h64,8'h60,8'h80,8'h84,8'h84,8'h84,8'h84,8'h80,8'h84,8'h84,8'h84,8'h84,8'h84},
	{8'h20,8'h60,8'h84,8'h84,8'ha4,8'h84,8'h84,8'ha4,8'hf6,8'hff,8'hfc,8'hfc,8'hf8,8'hb0,8'hb0,8'hf8,8'hff,8'hf6,8'hc4,8'hcc,8'ha4,8'h84,8'h80,8'h84,8'hcc,8'ha4,8'h80,8'h84,8'h84,8'h84,8'h60,8'h60},
	{8'h20,8'h20,8'ha4,8'hcc,8'hcc,8'ha4,8'h84,8'ha4,8'hff,8'hff,8'hfc,8'hfc,8'hd0,8'h00,8'h20,8'hb0,8'hfd,8'hff,8'hd1,8'hc4,8'hcc,8'ha4,8'h80,8'ha4,8'hcc,8'hcc,8'h84,8'h80,8'h84,8'h80,8'h20,8'h20},
	{8'h20,8'h60,8'ha4,8'hcc,8'hc4,8'hac,8'h84,8'ha4,8'hfa,8'hff,8'hfc,8'hfc,8'hf8,8'h64,8'h64,8'hfc,8'hfc,8'hff,8'hfa,8'hc4,8'hcc,8'hc4,8'h84,8'hcc,8'hcc,8'hcc,8'ha4,8'h80,8'h84,8'h84,8'h20,8'h20},
	{8'h80,8'h84,8'hcc,8'hcc,8'hfe,8'hd1,8'ha4,8'ha4,8'hd1,8'hff,8'hfd,8'hfc,8'hfc,8'hf8,8'hf8,8'hfc,8'hfc,8'hfd,8'hff,8'hd1,8'hc4,8'hcc,8'ha4,8'hc4,8'ha4,8'hc4,8'hcc,8'ha4,8'h80,8'h80,8'h60,8'h20},
	{8'h80,8'ha4,8'hc4,8'hd1,8'hff,8'hcc,8'hc4,8'hcc,8'hcc,8'hff,8'hfe,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hff,8'hff,8'hcc,8'hc4,8'ha4,8'hf0,8'hfa,8'hf1,8'ha4,8'hcc,8'ha4,8'ha4,8'h84,8'h80},
	{8'h84,8'hcc,8'hc4,8'hff,8'hff,8'hcc,8'hc4,8'hcc,8'ha4,8'hfa,8'hff,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hff,8'hf9,8'hc4,8'hc4,8'hf9,8'hff,8'hf5,8'h60,8'h64,8'ha4,8'hcc,8'hcc,8'h84},
	{8'ha4,8'hc4,8'hf6,8'hff,8'hff,8'hf1,8'hc4,8'hcc,8'hc4,8'hd1,8'hff,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfe,8'hff,8'hf5,8'hc4,8'hfe,8'hff,8'hfa,8'h60,8'h64,8'ha4,8'hcc,8'hcc,8'ha4},
	{8'hcc,8'hcc,8'hff,8'hfc,8'hff,8'hfa,8'ha4,8'hcc,8'hcc,8'hc4,8'hff,8'hff,8'hfc,8'hfc,8'hfc,8'hf8,8'hf8,8'hf8,8'hfc,8'hfc,8'hff,8'hfe,8'hcc,8'hff,8'hff,8'hff,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc},
	{8'hc4,8'hd1,8'hff,8'hfc,8'hfd,8'hff,8'hd1,8'hc4,8'hcc,8'ha4,8'hf5,8'hff,8'hfc,8'hfc,8'hfc,8'hf4,8'hf4,8'hf8,8'hfc,8'hfc,8'hfd,8'hff,8'hfa,8'hff,8'hfd,8'hff,8'hfa,8'ha4,8'hcc,8'hcc,8'hcc,8'hcc},
	{8'ha4,8'hfa,8'hfe,8'hf8,8'hf8,8'hff,8'hff,8'hcc,8'hc4,8'hc4,8'hcc,8'hff,8'hfd,8'hfc,8'hfc,8'hf4,8'hf4,8'hf4,8'hfc,8'hf8,8'hfc,8'hff,8'hff,8'hfe,8'hfc,8'hfe,8'hff,8'hf5,8'ha4,8'hcc,8'hcc,8'hcc},
	{8'ha4,8'hf6,8'hff,8'hf8,8'hfc,8'hfc,8'hff,8'hfa,8'hc4,8'hcc,8'hcc,8'hff,8'hfd,8'hfc,8'hfc,8'hf8,8'hf4,8'hf4,8'hfc,8'hfc,8'hfc,8'hff,8'hff,8'hfc,8'hfc,8'hfc,8'hfe,8'hff,8'hf5,8'hc4,8'hcc,8'hcc},
	{8'hc4,8'hd1,8'hff,8'hfc,8'hfc,8'hfc,8'hfd,8'hff,8'hd1,8'ha4,8'hd1,8'hff,8'hfc,8'hfc,8'hfc,8'hf4,8'hf4,8'hf4,8'hf8,8'hf8,8'hfc,8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfe,8'hff,8'hfe,8'hcc,8'hc4},
	{8'hc4,8'hcc,8'hff,8'hfc,8'hf8,8'hfc,8'hfc,8'hff,8'hff,8'ha4,8'hd6,8'hfe,8'hf8,8'hfc,8'hfc,8'hf4,8'hf4,8'hf8,8'hb0,8'h8c,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hf8,8'hfc,8'hfc,8'hfe,8'hff,8'hfe,8'hcc},
	{8'hc4,8'hd1,8'hff,8'hfc,8'hf8,8'hfc,8'hfc,8'hfd,8'hff,8'hf5,8'hb6,8'h64,8'hf8,8'hfc,8'hf8,8'hf4,8'hf4,8'hf4,8'h64,8'h20,8'hd4,8'hfc,8'hfc,8'hfc,8'hf8,8'hf4,8'hf4,8'hfc,8'hfc,8'hfd,8'hff,8'hf6},
	{8'ha4,8'hf5,8'hfe,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hff,8'hff,8'hfe,8'hd4,8'hfc,8'hfc,8'hf8,8'hf4,8'hf4,8'hf4,8'h64,8'h20,8'hf4,8'hfc,8'hfc,8'hfc,8'hf8,8'hf4,8'hf4,8'hfc,8'hfc,8'hfc,8'hff,8'hff},
	{8'hcc,8'hd5,8'h20,8'hb0,8'hfc,8'hfc,8'hf8,8'hfc,8'hff,8'hfe,8'hfc,8'hfc,8'hfc,8'hfc,8'hf8,8'hf4,8'hf4,8'hf0,8'h20,8'h20,8'hf8,8'hfc,8'hfc,8'hfc,8'hf8,8'hf4,8'hf4,8'hf8,8'hfc,8'hfc,8'hfe,8'hff},
	{8'hf6,8'h64,8'h20,8'h64,8'hf8,8'hf4,8'hf4,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hf8,8'hf4,8'hf4,8'hf4,8'hf0,8'hd0,8'hf4,8'hf8,8'hfc,8'hfc,8'hfc,8'hac,8'h84,8'hf4,8'hf8,8'hfc,8'hfc,8'hfc,8'hff},
	{8'hfe,8'hb0,8'h20,8'h20,8'hf8,8'hf4,8'hf4,8'hf8,8'hfc,8'hfc,8'hfc,8'hfc,8'hf8,8'hf4,8'hf4,8'hf0,8'hf4,8'hf4,8'hf8,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h8c,8'h00,8'h84,8'hf4,8'hf8,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hf8,8'hf4,8'hf8,8'hf4,8'hf4,8'hf8,8'hfc,8'hfc,8'hfc,8'hf8,8'hf4,8'hf4,8'hf0,8'hd0,8'hf0,8'hf4,8'hf4,8'hf4,8'hf8,8'hfc,8'hfc,8'hfc,8'hb0,8'h84,8'hd0,8'hd0,8'hf4,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hf8,8'hf4,8'hf4,8'hf8,8'hfc,8'hfc,8'hfc,8'hf8,8'hf4,8'hf4,8'hf0,8'hd0,8'hd0,8'hf0,8'hf4,8'hf4,8'hf4,8'hf4,8'hf8,8'hfc,8'hf8,8'hf4,8'hf0,8'hd0,8'hf0,8'hf4,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hf4,8'hf4,8'hf4,8'hf4,8'hfc,8'hfc,8'hf8,8'hf4,8'hf4,8'hf4,8'hf0,8'hd0,8'hf0,8'hd0,8'hf0,8'hf0,8'hf4,8'hf4,8'hf4,8'hf8,8'hf8,8'hf4,8'hd0,8'hf0,8'hf0,8'hf0,8'hf4,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hf8,8'hf4,8'hf4,8'hf4,8'hf4,8'hf8,8'hfc,8'hf4,8'hf4,8'hf4,8'hf4,8'hd0,8'hf0,8'hf0,8'hf0,8'hf0,8'hd0,8'hf0,8'hf4,8'hf4,8'hf4,8'hf8,8'hf4,8'hd0,8'hf0,8'hf0,8'hd0,8'hf0,8'hf8},
	{8'hfc,8'hfc,8'hfc,8'hf8,8'hf4,8'hf4,8'hd0,8'hf0,8'hf8,8'hfc,8'hf4,8'hf4,8'hf4,8'hf0,8'hd0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hd0,8'hf0,8'hf4,8'hf4,8'hf4,8'hd0,8'hf0,8'hf0,8'hd0,8'hf0,8'hf4},
	{8'hfc,8'hfc,8'hf8,8'hf4,8'hf4,8'hf0,8'hd0,8'hf0,8'hf4,8'hf8,8'hf4,8'hf4,8'hf4,8'hf0,8'hd0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hd0,8'hf0,8'hf4,8'hf0,8'hd0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0},
	{8'hfc,8'hf8,8'hf4,8'hf4,8'hf4,8'hf0,8'hf0,8'hd0,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hd0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hd0}};	

// pipeline (ff) to get the pixel color from the array 	 	
//==----------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'h00;
	end
	else begin
		RGBout <= TRANSPARENT_ENCODING ; // default 
		
		if (InsideRectangle == 1'b1 ) 	// only if inside the external bracket 
		begin
					case(MazeBiMapMask[offsetY[8:5] ][offsetX[8:5]]) //object code in the maze
						//-----
							SWALL:
						//-----
								RGBout <= sWall_colors[offsetY[4:0]][offsetX[4:0]];
						
						//-----
							GRASS:
						//-----
								RGBout <= grass_colors[offsetY[4:0]][offsetX[4:0]];	
						
						//-----
							DYNWALVL1:
						//-----
								RGBout <= dynWall1_colors[offsetY[4:0]][offsetX[4:0]];	
								
						//-----
							DYNWALVL2:
						//-----
								RGBout <= dynWall2_colors[offsetY[4:0]][offsetX[4:0]];
								
						//-----
							DYNWALVL3:
						//-----
								RGBout <= dynWall3_colors[offsetY[4:0]][offsetX[4:0]];
						//-----
							EXPLOSION:
						//-----
								RGBout <= EXPLOSION_colors[offsetY[4:0]][offsetX[4:0]];
						 default:
								RGBout <= TRANSPARENT_ENCODING ; // default 
					endcase
				
			end
		
	end	
end

//==----------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
/*
always_comb
	begin
		if(explosion) begin:
*/
//must add conditions 
assign grassDrawReq = ((MazeBiMapMask[offsetY[8:5] ][offsetX[8:5]] == GRASS)&(RGBout != TRANSPARENT_ENCODING )) ? 1'b1 : 1'b0 ;   
assign stoneWallDrawReq = ((MazeBiMapMask[offsetY[8:5] ][offsetX[8:5]] == SWALL)&(RGBout != TRANSPARENT_ENCODING )) ? 1'b1 : 1'b0 ;   
assign dyWall1DrawReq = ((MazeBiMapMask[offsetY[8:5] ][offsetX[8:5]] == DYNWALVL1)&(RGBout != TRANSPARENT_ENCODING )) ? 1'b1 : 1'b0 ;   
assign dywall2DrawReq = ((MazeBiMapMask[offsetY[8:5] ][offsetX[8:5]] == DYNWALVL2)&(RGBout != TRANSPARENT_ENCODING )) ? 1'b1 : 1'b0 ;   
assign dywall3DrawReq = ((MazeBiMapMask[offsetY[8:5] ][offsetX[8:5]] == DYNWALVL3)&(RGBout != TRANSPARENT_ENCODING )) ? 1'b1 : 1'b0 ;
assign EXPLOSIONDrawReq = ((MazeBiMapMask[offsetY[8:5] ][offsetX[8:5]] == EXPLOSION)&(RGBout != TRANSPARENT_ENCODING )) ? 1'b1 : 1'b0 ;   

endmodule
