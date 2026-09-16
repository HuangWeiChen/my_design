module RS232(
	input logic clk,
	input logic rst,
	input logic r_LPF_threshold,
	input logic rx,
	output logic tx
	);
	//Low_Pass_Filter
	logic rx_filter;
	Low_Pass_Filter Low_Pass_Filter_1(
		.clk					(clk),                          
		.reset				(rst),            
		.r_LPF_threshold	(r_LPF_threshold	),
		.signal				(rx),
		.sig_filter 		(rx_filter)
	);   
	
	//RS232_RX
	logic tx_ack;
	logic tx_req;
	logic [7:0]addr;
	logic [7:0]data;
	logic write;
	logic [1:0]tx_cnt;
	rs232_rx rs232_rx_1(
		.clk		(clk),
		.rst		(rst),
		.tx_ack	(tx_ack),	
		.rx		(rx_filter),
		.addr		(addr),
		.data		(data),
		.write	(write),
		.tx_req	(tx_req),
		.tx_cnt	(tx_cnt)
	);
	
	//register file
	logic [7:0] reg_file [255:0];
	logic [7:0] data_r;
	always_ff@(posedge clk)
	begin
		if(write)
			reg_file[addr]	<= data;
	end
	
	assign data_r = reg_file[addr];
	
	//Multiplexer
	logic [7:0] tx_data;
	always_comb
	begin
		case(tx_cnt)
			0:	tx_data = 8'h02;
			1:	tx_data = {4'h3, data_r[7:4]};
			2:	tx_data = {4'h3, data_r[3:0]};
			3:	tx_data = 8'h03;
		endcase
	end
	
	//RS232_TX
	rs232_tx rs232_tx_1(
		.clk		(clk),
		.rst		(rst),
		.tx_ack	(tx_ack),	
		.tx_req	(tx_req),
		.tx_data	(tx_data),
		.tx		(tx)
	);
	
endmodule
