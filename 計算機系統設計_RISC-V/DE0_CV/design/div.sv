module div(
	input logic [2:0] funct3,
	input logic [31:0] rs1_value,
	input logic [31:0] rs2_value,
	
	output logic [31:0] div_out
	);
	`define F_DIV		3'b100
	`define F_DIVU		3'b101
	`define F_REM		3'b110
	`define F_REMU		3'b111
	
	always_comb
	begin
		unique case(funct3)
			`F_DIV:		div_out = $signed(rs1_value) / $signed(rs2_value);
			`F_DIVU:		div_out = rs1_value / rs2_value;
			`F_REM:		div_out = $signed(rs1_value) % $signed(rs2_value);
			`F_REMU:		div_out = rs1_value % rs2_value;
		endcase
	end
	
endmodule