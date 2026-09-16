module mul(
	input logic [2:0] funct3,
	input logic [31:0] rs1_value,
	input logic [31:0] rs2_value,
	
	output logic [31:0] mul_out
	);
	`define F_MUL		3'b000
	`define F_MULH		3'b001
	`define F_MULHSU	3'b010
	`define F_MULHU	3'b011
	
	logic [63:0] product;
	
	always_comb
	begin
		unique case(funct3)
			`F_MUL:		product = $signed(rs1_value) * $signed(rs2_value);
			`F_MULH:		product = $signed(rs1_value) * $signed(rs2_value);	
			`F_MULHSU:	product = $signed($signed(rs1_value) * rs2_value);
			`F_MULHU:	product = rs1_value * rs2_value;
		endcase
	end
	
	assign mul_out = (funct3 == `F_MUL) ? product[31:0] : product[63:32];
	
endmodule