
module testbench;


	logic clk,rst;
	

risc_v a1(
	.clk(clk),
	.rst(rst)
	);

	
	always #10 clk = ~clk;
	initial begin
		clk = 0; rst = 1;
		#40 rst = 0;
		#20000 $stop;
	end
endmodule