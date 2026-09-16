module alu(
	input logic [3:0]a,
	input logic [3:0]b,
	input logic [1:0]op,
	output logic [3:0]s
	);
	
	always_comb begin
	
		case (op)
			0:	s = a+b;
			1: s = a&b;
			2: s = a-b;
			3: s = a|b;
		endcase
		
	end
	
endmodule