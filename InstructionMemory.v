`timescale 1ns / 1ps

module InstructionMemory(
	input [31:0] PCLine,
	output reg [31:0] Instruction,
	input clk,
	input IRWre
    );
	 
	reg [7:0] Ins [0:255];
	
	initial begin
		$readmemb ("instructions.txt", Ins);
	end
	
	always@(negedge clk) begin
		if(IRWre) begin
			Instruction [31:24] <= Ins[PCLine];
			Instruction [23:16] <= Ins[PCLine+1];
			Instruction [15:8] <= Ins[PCLine+2];
			Instruction [7:0] <= Ins[PCLine+3];
		end
	end

endmodule
