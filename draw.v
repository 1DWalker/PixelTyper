

module draw_word(
	input sh,
	input [3:0] word_id, 
	input clk,
	input go,
	input delete,
	output [7:0] draw_x,
	output [6:0] draw_y,
	output [2:0] colour,
	output done,
	output reg [6:0] shift_x
	);
	
	//reg [2:0] shift_x;
	initial shift_x = 7'b0000000;
	
	wire [2:0] x;
	
	assign draw_x = x + shift_x;
	wire prev_done;
	assign done = prev_done;
	
	draw_character(0, clk, go, delete, x, draw_y, colour, prev_done);
	
	always @(posedge prev_done) begin
		if (prev_done == 1'b1)
			shift_x <= shift_x + 8;
	end
endmodule

/*
	When go is one, draw_x, draw_y, and colour will be prepared for each positive edge of the clock.
	After the last pixel has been drawn, done will be set to high.
	*/
module draw_character(
	input [4:0] character_id, // an identifier for which charater to draw
	input clk,
	input go, 
	input delete, // high if the character is to be deleted
	output [2:0] draw_x, // relative to top left corner 
	output [2:0] draw_y, // relative to top left corner
	output [2:0] colour,
	output done
	);
	
	square(clk, go, draw_x, draw_y, done);
	
	// colour is black if delete
	assign colour = delete && 3'b000 || ~delete && 3'b111;
endmodule

module square(input clk, input go, output [2:0] x, output [2:0] y, output reg done);
	 initial done = 1'b0;
	 
	 reg [5:0] state;
    assign x = state[2:0];
    assign y = state[5:3];

    always @(posedge clk)
	 begin
	 	if (go == 1'b1 && done == 1'b1) begin
			done <= 1'b0;
			state <= 0;
		end
		
		if (state == 6'b111111)
			 done <= 1'b1;
		if (done == 1'b0) 
			 state <= state + 1'b1;
    end
endmodule