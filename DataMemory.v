`timescale 1ns / 1ps

module DataMemory(
	input [31:0] result,
	input [31:0] result_DR,
	input [31:0] read_data2_DR,
	input RD,
	input WR,
	input ALUM2Reg,
	output reg [31:0] write_data,
	input clk
    );
	
	reg [7:0] register [0:255];
	reg [31:0] data_stream;
	
	integer i;
	initial begin
		data_stream <= 0;

		for (i=0; i<255; i=i+1)
			register[i] <= 0;
	end
	
	always@(RD or WR or result_DR) begin
		if (RD == 1 && WR == 0) begin
			data_stream[31:24] = register[result_DR<<2];
			data_stream[23:16] = register[(result_DR<<2)+1];
			data_stream[15:8] = register[(result_DR<<2)+2];
			data_stream[7:0] = register[(result_DR<<2)+3];			
		end
		else if (RD == 0 && WR == 1) begin
			register[(result_DR<<2)] = read_data2_DR[31:24];
			register[(result_DR<<2)+1] = read_data2_DR[23:16];
			register[(result_DR<<2)+2] = read_data2_DR[15:8];
			register[(result_DR<<2)+3] = read_data2_DR[7:0];
		end
	end
	
	always@(negedge clk) begin
		write_data = (ALUM2Reg)?data_stream:result;	
	end
	
endmodule
