
module alu(
	input logic [3:0] op,
	input logic [31:0] alu_a,
	input logic [31:0] alu_b,
	
	output logic [31:0] alu_out
	);
	
	
	// ALU operation
	
	`define ALUOP_ADD			4'h0
	`define ALUOP_SUB			4'h1
	`define ALUOP_AND			4'h2
	`define ALUOP_OR			4'h3
	`define ALUOP_XOR			4'h4
	`define ALUOP_A			4'h5
	`define ALUOP_A_ADD_4	4'h6
	`define ALUOP_LTU			4'h7
	`define ALUOP_LT			4'h8
	`define ALUOP_SLL			4'h9
	`define ALUOP_SRL			4'hA
	`define ALUOP_SRA			4'hB
	`define ALUOP_B			4'hC
	
	always_comb begin
		unique case(op)
			`ALUOP_ADD		:alu_out = alu_a + alu_b;
			`ALUOP_SUB		:alu_out = $signed(alu_a) - $signed(alu_b);
			`ALUOP_AND		:alu_out = alu_a & alu_b;
		   `ALUOP_OR		:alu_out = alu_a | alu_b;
		   `ALUOP_XOR		:alu_out = alu_a ^ alu_b;
		   `ALUOP_A			:alu_out = alu_a;
		   `ALUOP_A_ADD_4	:alu_out = alu_a + 4;
		   `ALUOP_LTU		:alu_out = alu_a < alu_b;
		   `ALUOP_LT		:alu_out = $signed(alu_a) < $signed(alu_b);
		   `ALUOP_SLL		:alu_out = alu_a << alu_b[4:0];
		   `ALUOP_SRL		:alu_out = alu_a >> alu_b[4:0];
		   `ALUOP_SRA		:alu_out = $signed(alu_a) >>> alu_b[4:0];
		   `ALUOP_B			:alu_out = alu_b;
			default 			:alu_out = alu_a;
		endcase
	end
		
	
endmodule