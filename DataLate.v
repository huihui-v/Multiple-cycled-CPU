`timescale 1ns / 1ps

module DataLate(
	input [31:0] in,
	output reg [31:0] out,
	input clk
    );
	always@(negedge clk)
		out <= in;

endmodule
