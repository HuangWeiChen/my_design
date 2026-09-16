module logBase2(
	input logic [5:0]x,
	output logic [2:0]y
	);
	always_comb begin
	
		if(x[5]==1) begin
			y = 5;
		end
		else if(x[4]==1) begin
			y = 4;
		end
		else if(x[3]==1) begin
			y = 3;
		end	
		else if(x[2]==1) begin
			y = 2;
		end
		else if(x[1]==1) begin
			y = 1;
		end
		else begin
			y = 0;
		end
	end
	
endmodule