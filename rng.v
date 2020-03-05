/*
    This is an implementation of a random number generator, using a 32-bit xorshift rng http://www.jstatsoft.org/v08/i14/paper with coefficients (13, 17, 5)
    A random number is produced at each positive edge of clk.

    An 8-bit seed input and output is used for user friendliness.
    */

module rng(input clk, input [7:0] seed, output [7:0] randomnumber);
    reg [31:0] state;
    initial state = {4{seed}};

    assign randomnumber = state[7:0];

    wire [31:0] s1;
    wire [31:0] s2;
    wire [31:0] s3;

    assign s1 = state ^ (state << 13);
    assign s2 = s1 ^ (s1 >> 17);
    assign s3 = s2 ^ (s2 << 5);

    always @(posedge clk)
    begin
        state <= s3;
    end
endmodule