// Monitor is 120 x 160

module pixeltyper(
		CLOCK_50, 
		SW, KEY, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
		
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);
	
	input CLOCK_50;
	input [3:0] KEY;
	input [19:0] SW;
	output[9:0] LEDR;
	output [7:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   	
	
	// vga wires
	wire [2:0] vga_colour;
	wire [7:0] vga_x;
	wire [6:0] vga_y; 
	wire vga_resetn;
	wire vga_writeEn;
	assign vga_writeEn = 1'b1;
	
	vga_adapter VGA(
			.resetn(vga_resetn),
			.clock(CLOCK_50),
			.colour(vga_colour),
			.x(vga_x),
			.y(vga_y),
			.plot(vga_writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
	defparam VGA.RESOLUTION = "320x240";
	defparam VGA.MONOCHROME = "FALSE";
	defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
	defparam VGA.BACKGROUND_IMAGE = "black.mif";
	
	// ram wires 
	wire [4:0] ram_address;
	wire [3:0] ram_data;
	wire ram_wren;
	wire [3:0] ram_dataout;
	
	ram32x4 ram(
			.address(ram_address),
			.clock(CLOCK_50),
			.data(ram_data),
			.wren(ram_wren),
			.q(ram_dataout)
	);
	defparam 
	
	assign vga_resetn = SW[17];
	wire done;
	
	wire one_second;
	rateDivider(CLOCK_50, 27'd15000000, one_second);
	assign LEDR[2] = one_second;
	
	wire [6:0] shift_x;
	draw_word(SW[5], 0, CLOCK_50, SW[0], SW[1], x, y, vga_colour, done, shift_x);
	assign LEDR[0] = done;
	
	wire [7:0] x;
	wire [6:0] y;
	
	//assign vga_colour = SW[10:8];
	assign vga_x = x + 100;
	assign vga_y = y + 10;
	
	wire [3:0] state;
	//control(CLOCK_50, SW[0], 1'b1, x, y, state);
	hex_display(vga_x, HEX0);
	hex_display(vga_y, HEX1);
	hex_display(shift_x, HEX4);
	
	// initialize ram with some test values
	ram_initialize(CLOCK_50, ram_address, ram_data, ram_wren);
endmodule
	
module ram_initialize(
	input clk,
	output [4:0] ram_address,
	output [3:0] ram_data, 
	output ram_wren,
);
	
	reg [5:0] state;
	initial state = 0;
	
	always @(posedge clk) begin
		if (clk == 1'b1) 
			state <= state + 1;
	end
endmodule

module hex_display(IN, OUT);
    input [3:0] IN;
	output reg [7:0] OUT;
	 
	 always @(*)
	 begin
		case(IN[3:0])
			4'b0000: OUT = 7'b1000000;
			4'b0001: OUT = 7'b1111001;
			4'b0010: OUT = 7'b0100100;
			4'b0011: OUT = 7'b0110000;
			4'b0100: OUT = 7'b0011001;
			4'b0101: OUT = 7'b0010010;
			4'b0110: OUT = 7'b0000010;
			4'b0111: OUT = 7'b1111000;
			4'b1000: OUT = 7'b0000000;
			4'b1001: OUT = 7'b0011000;
			4'b1010: OUT = 7'b0001000;
			4'b1011: OUT = 7'b0000011;
			4'b1100: OUT = 7'b1000110;
			4'b1101: OUT = 7'b0100001;
			4'b1110: OUT = 7'b0000110;
			4'b1111: OUT = 7'b0001110;
			
			default: OUT = 7'b0111111;
		endcase
	end
endmodule

module datapath(input [3:0] colour, input resetn, input [6:0] xposition, input [6:0] yposition, input [2:0] x_rel, input [2:0] y_rel, 
                output [6:0] write_x, output [6:0] write_y, output [3:0] write_colour);
    assign write_x = xposition + x_rel; // out of bounds?
    assign write_y = yposition + y_rel;
    assign write_colour = colour;
endmodule

module control(input clk, input go, input resetn, output [1:0] x, output [1:0] y, output reg [3:0] state);
    reg done = 1'b1;
    assign x = state[1:0];
    assign y = state[3:2];

    always @(posedge clk, negedge resetn)
	 begin
        if (resetn == 1'b0) begin
            state <= 4'b0000;
            done = 1'b1;
			end
        else if (go == 1'b1 && done == 1'b1) begin
            done <= 1'b0;
            state <= 4'b0000;
			end
        else begin
            if (state == 4'b1111)
                done <= 1'b1;
            if (done == 1'b0) 
                state <= state + 1'b1;
			end
    end
endmodule

module rateDivider(clock, rate, enable);
	input clock;
	input [27:0] rate;
	output enable;
	
	reg [27:0] counter;
	initial counter = rate - 1;	
	
	always @(posedge clock)
	begin
		if (enable == 1)
			counter <= rate - 1;
		else
			counter <= counter - 1'b1;
	end
	
	assign enable = (counter == 8'd0) ? 1'b1 : 1'b0;
endmodule