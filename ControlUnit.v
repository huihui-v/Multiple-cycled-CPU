`timescale 1ns / 1ps

module ControlUnit(
	input [5:0] Op,
	input zero,
	input clk,
	input CURST,
	output reg PCWre,
	output reg ALUSrcA,
	output reg ALUSrcB,
	output reg ALUM2Reg,
	output reg RegWre,
	output reg WrRegData,
	output reg InsMemRW,
	output reg RD,
	output reg WR,
	output reg IRWre,
	output reg ExtSel,
	output reg [1:0] PCSrc,
	output reg [1:0] RegDst,
	output reg [2:0] ALUOp
    );
	 //opcode of instructions
	parameter [5:0] ADDU=6'b000000,
						 SUBU=6'b000001,
						 ADDIU=6'b000010,
						 OR=6'b010000,
						 AND=6'b010001,
						 ORI=6'b010010,
						 SLL=6'b011000,
						 SLTU=6'b100110,
						 SLTIU=6'b100111,
						 SW=6'b110000,
						 LW=6'b110001,
						 BEQ=6'b110100,
						 J=6'b111000,
						 JR=6'b111001,
						 JAL=6'b111010,
						 HALT=6'b111111;
	 
	 //code of states
	parameter [2:0] IF=3'b000,
						 ID=3'b001,
						 EXE1=3'b110,
						 EXE2=3'b101,
						 EXE3=3'b010,
						 MEM=3'b011,
						 WB1=3'b111,
						 WB2=3'b100;
	reg [2:0] state, next_state;
	 
	 //initialization
	initial begin
		PCWre = 0;
		ALUSrcA = 0;
		ALUSrcB = 0;
		ALUM2Reg = 0;
		RegWre = 0;
		WrRegData = 0;
		InsMemRW = 0;
		RD = 0;
		WR = 0;
		IRWre = 0;
		ExtSel = 0;
		PCSrc = 2'b00;
		RegDst = 2'b00;
		ALUOp = 3'b000;
		state = IF;
	end
	
	 //changing table of states

	always@(posedge clk) begin 
		if (CURST == 0)
			state <= IF;
		else 
			state <= next_state;
			$monitor("%b,",state);
	end
	
	always@(state or Op) begin
		case(state)
			IF: next_state = ID;
			ID: begin
				case (Op[5:3])
					3'b111: next_state = IF;
					3'b110: begin
						if (Op == BEQ)
							next_state = EXE2;
						else
							next_state = EXE3;
					end
					default: next_state = EXE1;
				endcase
			end
			EXE1: next_state = WB1;
			EXE2: next_state = IF;
			EXE3: next_state = MEM;
			WB1: next_state = IF;
			WB2: next_state = IF;
			MEM: next_state = (Op == LW)?WB2:IF;
		endcase
			$monitor("2,%b,%b", state, next_state);
	end
	
	always@(state) begin
		if(next_state == IF && Op != HALT) 
			PCWre = 1;
		else PCWre = 0;
		
		if(state == EXE1 && Op == SLL)
			ALUSrcA = 1;
		else ALUSrcA = 0;
		
		if(state == EXE3 || Op == ADDIU || Op == ORI)
			ALUSrcB = 1;
		else ALUSrcB = 0;
		
		if(next_state == WB2)
			ALUM2Reg = 1;
		else ALUM2Reg = 0;
		
		if(state == WB1 || state == WB2 || Op == JAL) 
			RegWre = 1;
		else RegWre = 0;
		
		if(state == WB1 || state == WB2)
			WrRegData = 1;
		else WrRegData = 0;
		
		if(state == IF)
			InsMemRW = 1;
		else InsMemRW = 0;
		
		if(state == MEM && Op == LW)
			RD = 1;
		else RD = 0;
		
		if(state == MEM && Op == SW)
			WR = 1;
		else WR = 0;
		
		if(state == IF)
			IRWre = 1;
		else IRWre = 0;
		
		if(state == EXE1 && Op == ORI)
			ExtSel = 0;
		else ExtSel = 1;
		
		if(state == ID && (Op == J || Op == JAL))
			PCSrc = 2'b11;
		else if(state == ID && Op == JR)
			PCSrc = 2'b10;
		else if(state == EXE2 && zero == 1)
			PCSrc = 2'b01;
		else PCSrc = 2'b00;
		
		if(state == ID && Op == JAL)
			RegDst = 2'b00;
		else if((state == WB1 && (Op == ADDIU || Op == ORI || Op == SLTIU)) || state == WB2)
			RegDst = 2'b01;
		else RegDst = 2'b10;
		
		case(Op)
			SUBU:ALUOp = 3'b001;
			OR:ALUOp = 3'b101;
			AND:ALUOp = 3'b110;
			ORI:ALUOp = 3'b101;
			SLTU:ALUOp = 3'b010;
			SLTIU:ALUOp = 3'b010;
			SLL:ALUOp = 3'b100;
			BEQ:ALUOp = 3'b001;
			default:ALUOp = 3'b000;
		endcase;
	end
			
	
endmodule
