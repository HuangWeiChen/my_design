module TDI(
	input logic clk,
	input logic rst,
	input logic ssn,
	input logic sclk,
	input logic [7:0]mosi,
	input logic start,
	output logic [7:0] pixel_output,
	output logic update
	);
	
	//SPI_RX
	logic wrreg;
	logic rdreq;
	logic [7:0] data_in;
	spi_rx spi_rx_1(
		.clk			(clk),
		.rst			(~rst),
		.ssn			(ssn),	
		.sclk			(sclk),
		.mosi			(mosi),
		.write_en	(wrreq),
		.data			(data_in)
	);
	
	//FIFO
	logic [10:0] shift_reg [63:0];
	logic [7:0]data_out;
	logic [10:0]usedw;
	logic almost_empty;
	logic sclr;
	logic full;
	logic empty;
	
	 
	fifo fifo_1(	
		.clock 	  	 (clk),
		.data		  	 (data_in),
		.rdreq   	 (rdreq),
		.sclr			 (rst),
		.wrreq		 (wrreq),
		.almost_empty(almost_empty),
		.empty		 (empty),
		.full		 	 (full),
		.q				 (data_out),
		.usedw		 (usedw)
	);
	
	logic fifo_req;
	logic trg_tdi;
	integer i, j;
	logic [31:0] update_cnt;
	logic [2:0] x;
	logic [2:0] y;
	logic [2:0] y_plus1;
	logic add_x;
	logic add_y;
	logic add_update;
	logic shift;
	//counter
	always_ff@(posedge clk)
	begin
		if(rst) begin 
			x 				<= 0;
			y 				<= 0;
			y_plus1 		<= 1;
			update_cnt	<= 0;
		end
		if(add_x)
			x <= x+1;
		if(add_y) begin
			y <= y+1;
			y_plus1 <= y_plus1+1;
		end
		if(add_update)
			update_cnt <= update_cnt + 1;
	end
	
	logic update_req;
	
	always_ff@(posedge clk)
	begin
		if(rst) 
			update <= 0;
		else
			update <= update_req;
	end
	
	logic [10:0] deb_a;
	logic [10:0] deb_b;
	
	//TDI
	always_ff@(posedge clk)
	begin
		if(rst) 
			for (i=0; i<64; i=i+1)
				shift_reg[i] <= 11'b0;
		else if(shift) begin 
			if(y == 0) begin
				pixel_output <= shift_reg[0] >> 3;
			end
			if(y_plus1 == 0)
				shift_reg[8*y+7] <= {3'b0,data_out} + 0;
			else 
				shift_reg[8*y+7] <= {3'b0,data_out} + shift_reg[8*y_plus1+x];
			shift_reg[8*y+6] <= shift_reg[8*y+7];
			shift_reg[8*y+5] <= shift_reg[8*y+6];
			shift_reg[8*y+4] <= shift_reg[8*y+5];
			shift_reg[8*y+3] <= shift_reg[8*y+4];
			shift_reg[8*y+2] <= shift_reg[8*y+3];
			shift_reg[8*y+1] <= shift_reg[8*y+2];
			shift_reg[8*y+0] <= shift_reg[8*y+1];

		end
	end
	assign deb_a = shift_reg[8*y+7];
	assign deb_b = shift_reg[8*y_plus1+x];
	//FSM
	typedef enum{ INIT, READ_DATA, TDI, FINISH
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
		rdreq			= 0;
		shift			= 0;
		add_x			= 0;
		add_y			= 0;
		add_update 	= 0;
		update_req		= 0;
		case(fsm_ps)
			INIT:
			begin
				if(start)
					fsm_ns = READ_DATA;
			end
			READ_DATA:
			begin
				rdreq = 1;
				fsm_ns = TDI;
			end
			TDI:
			begin 
				add_x = 1;
				shift = 1;
				
				if(update_cnt >= 8*36+1) begin
					fsm_ns = FINISH;
				end
				else if(update_cnt >= 1) begin
					if(y == 0) begin
						update_req = 1;
						add_update = 1;
					end
					if(x == 7)
						add_y = 1;
					fsm_ns = READ_DATA;
				end
				else begin
					if(x==7) begin
						add_y = 1;
						add_update = 1;
					end
					fsm_ns = READ_DATA;
				end
			end
			FINISH:
			begin
				fsm_ns = INIT;
			end
			
		endcase
	end
endmodule
