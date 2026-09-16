module spi(
	input logic clk,
	input logic mosi,
	input logic ssn,
	input logic sclk,
	input logic rst,
	output logic miso,
	output logic [7:0]address,
	output logic [15:0]data,
	output logic read_en,
	output logic write_en,
	output logic tx_req
	);
	

	//Edge Detector
	logic sclk_s;
	logic sclk_d;
	logic ssn_s;
	logic ssn_d;
	logic ssn_negedge;
	logic sclk_posedge;
	logic sclk_negedge;
	
	always_ff@(posedge clk)
	begin
		if(~rst) 
		begin
			sclk_s			<= 1'b0;
			sclk_d			<= 1'b0;
			ssn_s				<= 1'b1;
			ssn_d 			<= 1'b1;
		end
		else 
		begin
			{sclk_d, sclk_s} 	<= {sclk_s, sclk};
			{ssn_d, ssn_s} 	<= {ssn_s, ssn};
		end
	end
	
	assign ssn_negedge  = ~ssn_s & ssn_d;
	assign sclk_posedge = sclk_s & ~sclk_d;
	assign sclk_negedge = ~sclk_s & sclk_d;
	
	//Counter
	logic [31:0] receive_data_counter;
	logic sclk_data_counter_rst;
	
	always_ff@(posedge clk)
	begin
		if(~rst || ssn) 
			receive_data_counter <= 32'b0;
		else if(sclk_posedge)
			receive_data_counter <= receive_data_counter + 1'b1;
	end
	
	//Counter2
	logic [5:0] sclk_data_counter;
	
	always_ff@(posedge clk)
	begin
		if(~rst || sclk_data_counter_rst) 
			sclk_data_counter <= 32'b0;
		else if(sclk_negedge)
			sclk_data_counter <= sclk_data_counter + 1'b1;
	end
	
	//Shift Register
	logic [31:0]shift_data;
	logic shift_read_data;
	logic load_shift_read_data;
	logic [15:0]read_data_reg;
	logic [15:0]read_data;
	
	always_ff@(posedge clk)
	begin
		if(~rst) 
			shift_data 		<= 32'b0;
		else if(ssn_negedge)
			shift_data <= 32'b0;
		else if(~ssn && sclk_posedge)
			shift_data <= {shift_data[30:0], mosi};
		if(~rst) 
			read_data_reg 		<= 16'b0;
		else if(load_shift_read_data)
			read_data_reg	<= read_data;
		else if(shift_read_data && sclk_negedge) begin
			read_data_reg  <= read_data_reg << 1;
			//miso <= read_data_reg[15];
		end
		
	end                 
	assign miso = read_data_reg[15];
	//reg
	logic [15:0] reg_file [255:0];
	logic load_command;
	logic load_address;
	logic load_data;
	logic command;
	
	always_ff@(posedge clk)
	begin
		if(load_command)
			command <= shift_data[7];
		if(load_address)
			address <= shift_data[15:8];
		if(load_data)
			data <= shift_data[15:0];
		if(write_en)
			if(~command)
				reg_file[address] <= data;
		if(read_en)
			read_data <= reg_file[address];
	end
	
	//FSM
	typedef enum{ INIT, START_SPI_RX, RECEIVE_ADDRESS, DUMMY, 
		CHECK_COMMAND, TX_REQ, FINISH, RECEIVE_DATA, WRITE
   } FSM_STATE;
	FSM_STATE fsm_ns,fsm_ps;
	
	always_ff@(posedge clk) begin
        if(~rst)
            fsm_ps      <= INIT;
        else
            fsm_ps      <= fsm_ns;
   end
	 

	logic rx_finish;
	
	always_comb 
	begin
		fsm_ns							=	fsm_ps;
		load_command					=	0;
		load_address					=	0;
		load_data						=	0;
		write_en							=	0;
		tx_req							=  0;
		case(fsm_ps)
			INIT:
			begin
				fsm_ns	= START_SPI_RX;
			end
			START_SPI_RX:
			begin
				if(ssn_negedge) begin
					fsm_ns = RECEIVE_ADDRESS;
				end
				else
					fsm_ns = START_SPI_RX;
			end
			RECEIVE_ADDRESS:
			begin
				if(receive_data_counter==16) begin
					load_command = 1;
					load_address = 1;
					fsm_ns = CHECK_COMMAND;
				end
			end
			CHECK_COMMAND:
			begin
				if(command)
					fsm_ns = TX_REQ;
				else
					fsm_ns = RECEIVE_DATA;
					
			end
			TX_REQ:
			begin
				tx_req  = 1;
				fsm_ns  = FINISH;
			end
			FINISH:
			begin
				fsm_ns = INIT;
			end
			RECEIVE_DATA:
			begin
				if(receive_data_counter==32)
				begin
					load_data 	= 1;
					fsm_ns 		= WRITE;
				end
				else
					fsm_ns = RECEIVE_DATA;
			end
			WRITE:
			begin
				write_en = 1;
				fsm_ns = FINISH;
			end
			
		endcase
	end
	
	//FSM2
	typedef enum{ INIT2, START_SPI_TX, DELAY, SEND_DATA, FINISH2
   } FSM_STATE2;
	FSM_STATE2 fsm2_ns,fsm2_ps;
	
	always_ff@(posedge clk) begin
        if(~rst)
            fsm2_ps      <= INIT2;
        else
            fsm2_ps      <= fsm2_ns;
   end
	
	always_comb 
	begin
		fsm2_ns						=	fsm2_ps;
		sclk_data_counter_rst	=  0;
		shift_read_data			=	0;
		load_shift_read_data		=  0;
		read_en 						=  0;
		case(fsm2_ps)
			INIT2:
			begin
				fsm2_ns	= START_SPI_TX;
			end
			START_SPI_TX:
			begin
				if(tx_req) begin
					read_en 					 = 1;
					sclk_data_counter_rst = 1;
					fsm2_ns					 = DELAY;
				end
				else
					fsm2_ns 					 = START_SPI_TX;
			end
			DELAY:
			begin
				if(sclk_data_counter == 7) begin
					sclk_data_counter_rst = 1;
					fsm2_ns 					 = SEND_DATA;
				end
				else if(sclk_data_counter == 0) begin
					load_shift_read_data	 = 1;
					fsm2_ns 					 = SEND_DATA;
				end
				else
					fsm2_ns 					 = DELAY;
			end
			SEND_DATA:
			begin
				shift_read_data = 1;
				if(sclk_data_counter == 16) begin
					fsm2_ns = FINISH2;
				end
				else
					fsm2_ns = SEND_DATA;
			end
			FINISH2:
			begin
				fsm2_ns = INIT2;
			end
			
			
		endcase
	end
	
	
endmodule
