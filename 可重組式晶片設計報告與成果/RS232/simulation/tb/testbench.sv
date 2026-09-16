`timescale 1ns/100ps
module testbench;


	logic			clk, rst;
	logic	[1:0]	buad_setting;  //0:9600 1:19200 2:38400
	logic			rx, tx_flag; //input
	logic 			tx_end_flag, tx_data; //output
	logic [13:0] r_LPF_threshold;
	logic [7:0] send_data;
	
	logic [7:0]data_debug;
	
	integer	i;
	integer	j;
	
	// 									02,   addr, data,   R/W, CHK_SUM, 03
	//logic [7:0] send_package_w [0:5] = {8'h02, 8'h12, 8'ha5, 8'h01, 8'hba, 8'h03};
	//logic [7:0] send_package_r [0:5] = {8'h02, 8'h12, 8'h00, 8'h00, 8'h14, 8'h03};
	// 02, 12, a5, 01, ba, 02
	// 02, 12, 00, 00, ba, 02
	
	
	logic [7:0] send_package_1 [0:7] = {8'h02, 8'h30, 8'h32, 8'h30, 8'h33, 8'h01, 8'hc8, 8'h03};
	logic [7:0] send_package_2 [0:7] = {8'h02, 8'h31, 8'h33, 8'h32, 8'h39, 8'h01, 8'hd3, 8'h03};
	logic [7:0] send_package_3 [0:7] = {8'h02, 8'h31, 8'h33, 8'h39, 8'h32, 8'h01, 8'hd2, 8'h03};
	logic [7:0] send_package_4 [0:7] = {8'h02, 8'h30, 8'h32, 8'h00, 8'h00, 8'h00, 8'h64, 8'h03};
	logic [7:0] send_package_5 [0:7] = {8'h02, 8'h31, 8'h33, 8'h00, 8'h00, 8'h00, 8'h66, 8'h03};
	//02, 30, 32, 30, 33, 01,  03	
	//02, 30, 32, 00, 00, 00,  03	
	
	
	
	parameter BAUD_CNT_MAX_9600  = 5208	;  // = 50000000 / 9600
	parameter BAUD_CNT_MAX_19200 = 2604	;  // = 50000000 / 19200
	parameter BAUD_CNT_MAX_38400 = 1302	;  // = 50000000 / 38400 
	
	assign r_LPF_threshold	= 14'd200;

	RS232 rs232_1(
				.clk(clk),                          
				.rst(rst),            
				.r_LPF_threshold		(r_LPF_threshold		),
				//.buad_setting(buad_setting),    
				
				.rx		(rx),
				.tx		(tx_data)
				//.data_debug(data_debug)
			);                                                                       		
				
				
	always	#10 clk = ~clk;
	
	initial begin
		rx = 1'b1; 
		clk = 0;
		buad_setting = 2'b10; 
		tx_flag = 0; 
		rst = 0;
		
		#40 rst = 1;
		
		
		for (j=0; j<8; j=j+1) begin 
				send_data = send_package_1[j];  //start bit
				tx_task;
				#100;
		end
		
		for (j=0; j<8; j=j+1) begin 
				send_data = send_package_2[j];  //start bit
				tx_task;
				#100;
		end
		
		for (j=0; j<8; j=j+1) begin 
				send_data = send_package_3[j];  //start bit
				tx_task;
				#100;
		end
		
		for (j=0; j<8; j=j+1) begin 
				send_data = send_package_4[j];  //start bit
				tx_task;
				#100;
		end
		
		#(1302 * 40 * 25 *2) 
		
		for (j=0; j<8; j=j+1) begin 
				send_data = send_package_5[j];  //start bit
				tx_task;
				#100;
		end
		
		
		#(1302 * 40 * 25 * 2) $stop;
	
	end
	
	task reset_task ; begin
		#(10); rst = 0;
		#(40); rst = 1;
		end 
	endtask
	
	
	
	task tx_task; begin  //寫
			#(1302 * 20)	rx = 1'b0;  //start bit
			for (i=0; i<8; i=i+1) 
				#(1302 * 20)	rx = send_data[i];  //start bit
			
			#(1302 * 20) 	rx = 1'b1;  //end bit
		end
	endtask
	
	
	
	
	
endmodule