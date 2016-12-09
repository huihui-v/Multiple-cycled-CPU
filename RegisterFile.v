`timescale 1ns / 1ps

module RegisterFile(
	input clk,
	input RegWre,
	input [1:0] RegDst,
	input WrRegData,
	input [4:0] rs,
	input [4:0] rt,
	input [4:0] rd,
	input [31:0] write_data,
	input [31:0] PCLine,
	output [31:0] read_data1,
	output [31:0] read_data2
    );
	reg [31:0] register [0:31];
	
	integer i;
	initial begin
		for (i=0; i<32; i=i+1)
			register[i] <= 0;
	end
	
	assign read_data1 = (rs == 0)?0:register[rs];
	assign read_data2 = (rt == 0)?0:register[rt];
	
	wire [31:0] data;
	always@(negedge clk) begin
		if (RegWre == 1) begin
/*		
			if (WrRegData == 0) begin
				data <= PCLine + 4;
			end 
			else begin 
				data <= write_data;
			end
			if (RegDst == 2'b00) begin
				register[31] <= data;
			end
			else if (RegDst == 2'b01) begin
				if (rt != 0) begin
					register[rt] <= data;
				end
			end
			else if (RegDst == 2'b10) begin
				if (rd != 0) begin
					register[rd] <= data;
				end
			end
*/		

			case (RegDst)
				2'b00: begin
					if (WrRegData == 0) begin
						register[31] <= PCLine + 4;
					end 
					else begin 
						register[31] <= write_data;
					end
				end
				2'b01: begin
					if (rt != 0) begin
						if (WrRegData == 0) begin
							register[rt] <= PCLine + 4;
						end 
						else begin 
							register[rt] <= write_data;
						end
					end
				end
				2'b10: begin
					if (rd != 0) begin
						if (WrRegData == 0) begin
							register[rd] <= PCLine + 4;
						end 
						else begin 
							register[rd] <= write_data;
						end
					end
				end
			endcase

		end
		

		
	end
	
endmodule
