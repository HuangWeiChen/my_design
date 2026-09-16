module sort(
	input logic [3:0]a[0:7],
	output logic [3:0]b[0:7]
	);
	
	logic [3:0]x[0:7];
	logic [3:0] tmp;
	integer i;
	integer j;
	integer min;
	
	always_comb 
	begin
		x = a;
		for(i=0; i<8; i=i+1) begin
			tmp = x[i]; 
         min = i;
			for(j=i+1; j<8; j=j+1) begin
				if(x[j]<tmp) begin
					tmp = x[j];
					min = j;
				end
			end
			b[i] = tmp;
			x[min] = x[i];
		end
	end

	
endmodule