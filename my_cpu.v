`timescale 1ns / 1ps

module my_cpu();

//defination of wires and regs
	reg [31:0] PCLine;
	reg clk;
	reg PCRST;
	reg CURST;
	wire [31:0] Instruction;
	wire [5:0] Op;
	wire [4:0] rs;
	wire [4:0] rt;
	wire [4:0] rd;
	wire [15:0] immediate;
	wire [31:0] sa;
//	wire [25:0] sub_addr;
	wire [31:0] new_addr;
   wire [31:0] read_data1_DR;
	wire [31:0] read_data2_DR;
	wire zero;
	wire [31:0] extended_immediate;
	wire [31:0] result;
	wire [31:0] result_DR;
	wire [31:0] write_data;
	wire [31:0] read_data1;
	wire [31:0] read_data2;
	
	//wires of control unit
	wire PCWre;
   wire ALUSrcA;
	wire ALUSrcB;
	wire ALUM2Reg;
	wire RegWre;
	wire WrRegData;
	wire InsMemRW;
	wire RD;
	wire WR;
	wire IRWre;
	wire ExtSel;
	wire [1:0] PCSrc;
	wire [1:0] RegDst;
	wire [2:0] ALUOp;

//end of defination

	initial begin
		CURST = 0;
		PCRST = 0;
		#1000;
		CURST = 1;
		PCRST = 1;
	end
	//PC initial
	initial begin
		PCLine = 0;
	end
	//end of PC initial
	

//clock
	initial begin
		clk = 0;
	end
	
	always #500
		clk = ~clk;
//end of clock

//data path

	InstructionMemory instructionmemory(PCLine, Instruction, clk, IRWre);
	//destruction of instruction
	assign Op = Instruction [31:26];
	assign rs = Instruction [25:21];
	assign rt = Instruction [20:16];
	assign rd = Instruction [15:11];
	assign immediate = Instruction [15:0];
	assign new_addr[31:28] = PCLine[31:28];
	assign new_addr[27:2] = Instruction [25:0];
	assign new_addr[1:0] = 2'b00;
	assign sa[31:0] = {{27{1'b0}},Instruction [10:6]};
	//end of destruction
	
	
	ControlUnit controlunit(Op,zero,clk,CURST,PCWre,ALUSrcA,ALUSrcB,
									ALUM2Reg,RegWre,WrRegData,InsMemRW,RD,WR,
									IRWre,ExtSel,PCSrc,RegDst,ALUOp);
	
	RegisterFile registerfile (clk,RegWre,RegDst,WrRegData,rs,rt,rd,
										write_data,PCLine,read_data1,read_data2);
	DataLate ADR (read_data1,read_data1_DR,clk);
	DataLate BDR (read_data2,read_data2_DR,clk);
	
	Extend extend (immediate, ExtSel, extended_immediate);
	
	ALU alu (read_data1_DR,read_data2_DR,sa,extended_immediate,
				ALUSrcA,ALUSrcB,ALUOp,zero,result);
	DataLate ALUout (result,result_DR,clk);
	
	DataMemory datamemory (result,result_DR,read_data2_DR,RD,WR,ALUM2Reg,write_data,clk);
	//PC refresh
	always@(posedge clk) begin
		if (PCWre == 0)
			PCLine <= PCLine;
		else begin
			if(PCSrc == 2'b00)
				PCLine <= PCLine + 4;
			else if (PCSrc == 2'b01)
				PCLine <= PCLine + 4 + (extended_immediate<<2);
			else if (PCSrc == 2'b10)
				PCLine <= read_data1;
			else
				PCLine <= new_addr;
		end
	end
	//end of PC refresh
endmodule
