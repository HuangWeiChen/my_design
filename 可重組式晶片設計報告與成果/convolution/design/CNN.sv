module CNN(
	input logic clk,
	input logic rst,
	input logic ssn,
	input logic sclk,
	input logic mosi,
	output logic [15:0] conv_data,
	output logic update
	);
	
	//SPI_RX
	logic			 wrreq;
	logic 		 rdreq;
	logic [15:0] data;
	logic 		 write_en;
	logic [7:0]	 address;
	logic 		 conv;
	spi_rx spi_rx_1(
		.clk			(clk),
		.rst			(~rst),
		.ssn			(ssn),	
		.sclk			(sclk),
		.mosi			(mosi),
		.write_en	(write_en),
		.wrreq		(wrreq),
		.data			(data),
		.address		(address),
		.conv			(conv)
	);
	//register file
	logic [15:0] reg_file [0:8];
	always_ff@(negedge clk)
	begin
		if(write_en)
			reg_file[address]	<= data;
	end
	
	//FIFO 16 bits degree 2048
	logic [15:0] input_data;
	logic [10:0] usedw;
	logic 		 almost_empty;
	logic 		 sclr;
	logic 		 full;
	logic 	 	 empty;
	
	 
	fifo fifo_1(	
		.clock 	  	 (clk),
		.data		  	 (data),
		.rdreq   	 (rdreq),
		.sclr			 (rst),
		.wrreq		 (wrreq),
		.almost_empty(almost_empty),
		.empty		 (empty),
		.full		 	 (full),
		.q				 (input_data),
		.usedw		 (usedw)
	);
	
	//CNN
	logic rst_pos;
	logic rst_input;
	logic [4:0] x;
	logic [4:0] y;
	logic [4:0] cnt_input;
	logic [15:0] shift_reg [0:18];
	logic shift;
	logic start;
	integer i;
	integer j;
	always_ff@(posedge clk)
	begin
		if(rst) begin
			for (i=0; i<19; i=i+1)
				shift_reg[i] <= 16'b0;
		end
		if(rst || rst_pos)begin
			x			<= 0;
			y			<= 0;
		end
		if(rst || rst_input)
			cnt_input<= 0;
		if(shift) begin
			cnt_input <= cnt_input +1;
			for(j=0; j<19; j=j+1) begin
				if(j == 18)
					shift_reg[18] <= input_data;
				else
					shift_reg[j] <= shift_reg[j+1];
			end
		end
		if(start) begin
			if(x<6) begin
				if(x==5) begin
					x <= 0;
					y <= y+1;
				end
				else
					x <= x+1;
				conv_data <= shift_reg[0] *reg_file[0] +
								 shift_reg[1] *reg_file[1] +
								 shift_reg[2] *reg_file[2] +
								 shift_reg[8] *reg_file[3] +
								 shift_reg[9] *reg_file[4] +
								 shift_reg[10]*reg_file[5] +
								 shift_reg[16]*reg_file[6] +
								 shift_reg[17]*reg_file[7] +
								 shift_reg[18]*reg_file[8] ;
			
			end
		end
	end

	//FSM
	typedef enum{ INIT, READ_DATA, S1, S2, S3, CNN, FINISH
   } FSM_STATE;
	FSM_STATE fsm_ns,fsm_ps;
	
	always_ff@(posedge clk) begin
        if(rst)
            fsm_ps      <= INIT;
        else
            fsm_ps      <= fsm_ns;
   end

	
	always_comb 
	begin
		fsm_ns		= fsm_ps;
		rst_pos		= 0;
		rst_input	= 0;
		shift			= 0;
		rdreq			= 0;
		start			= 0;
		update		= 0;
		case(fsm_ps)
			INIT:
			begin
				rst_pos	 = 1;
				rst_input = 1;
				if(conv)
					fsm_ns = READ_DATA;
			end
			READ_DATA:
			begin
				shift	= 1;
				rdreq = 1;
				if(cnt_input == 20) begin
					fsm_ns = CNN;
					update = 1;
					start	 = 1;
				end
			end
			CNN:
			begin 
				start = 1;
				shift = 1;
				rdreq = 1;
				if(y == 5 && x == 5)begin
					update = 1;
					fsm_ns = FINISH;
				end
				else if(x==5)begin
					update = 1;
					fsm_ns = S1;
				end
				else 
					update = 1;
			end
			S1:
			begin
				shift  = 1;
				rdreq  = 1;
				fsm_ns = S2;
			end
			S2:
			begin
				shift  = 1;
				rdreq  = 1;
				fsm_ns = CNN;
			end
			S3:
			begin
				shift  = 1;
				rdreq  = 1;
				fsm_ns = CNN;
			end
			FINISH:
			begin
				fsm_ns = INIT;
			end
			
		endcase
	end
endmodule
