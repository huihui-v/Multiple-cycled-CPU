`timescale 1ns / 1ps

module ALU(
	input [31:0] read_data1_DR,
	input [31:0] read_data2_DR,
	input [31:0] sa,
	input [31:0] extended_immediate,
	input ALUSrcA,
	input ALUSrcB,
	input [2:0] ALUOp,
	output wire zero,
	output reg [31:0] result
    );
	
//	wire [31:0] newaddr;
//	assign newaddr = {{27{1'b0}},sa};
	
	wire [31:0] alua;
	wire [31:0] alub;
	assign alua = (ALUSrcA == 0)?read_data1_DR:sa;
	assign alub = (ALUSrcB == 0)?read_data2_DR:extended_immediate;
	
	always@(alua or alub or ALUOp) begin
		case (ALUOp)
			3'b000: result <= alua + alub;
			3'b001: result <= alua - alub;
			3'b010: result <= (alua<alub)?1:0;
			3'b011: result <= alub >> alua;
			3'b100: result <= alub << alua;
			3'b101: result <= alua | alub;
			3'b110: result <= alua & alub;
			3'b111: result <= (alua & ~alub) | (~alua & alub);
		endcase
	end
	
	assign zero = (result == 0)?1:0;

endmodule
