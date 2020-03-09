module pixeltyper(
		CLOCK_50, 
		SW, KEY, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
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
	output[9:0] LEDR;
	output [7:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
	
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
	wire vga_writeEn;
	
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
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
	)
endmodule