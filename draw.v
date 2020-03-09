

module draw_word(
	input [3:0] word_id, 
	input clk,
	input go,
	input delete,
	output [2:0] draw_x,
	output [2:0] draw_y,
	output [3:0] draw_colour,
	output done;
	);
	
	

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
	output [3:0] colour,
	output done
	);
	
	square(clk, go, draw_x, draw_y, done);
	
	// colour is black if delete
	assign colour = delete && 3'b000 || ~delete && 3'b111;
endmodule

module square(input clk, input go, output [2:0] x, output [2:0] y, output done);
    reg done = 1'b1;
	 
	 reg state[5:0];
    assign x = state[2:0];
    assign y = state[5:3];

    always @(posedge clk, posedge go)
	 begin
		if (go == 1'b1) begin
			done <= 1'b0;
			state <= 0;
		end
		else begin
			if (state == 6'111111)
				 done <= 1'b1;
			if (done == 1'b0) 
				 state <= state + 1'b1;
		end
    end
endmodule