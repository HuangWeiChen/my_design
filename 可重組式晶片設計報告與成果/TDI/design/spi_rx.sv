module spi_rx(
	input logic clk,
	input logic [7:0]mosi,
	input logic ssn,
	input logic sclk,
	input logic rst,
	output logic [7:0]data,
	output logic write_en
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
	 
	always_ff@(posedge clk)
	begin
		if(~rst) 
			data 	<= 8'b0;
		else if(ssn_negedge)
			data <= 32'b0;
		else if(~ssn && sclk_posedge)
			data <= mosi;
		
	end
	
	//FSM
	typedef enum{INIT, START_SPI_RX, FINISH, RECEIVE_DATA } FSM_STATE;
	FSM_STATE fsm_ns,fsm_ps;
	
	always_ff@(posedge clk) begin
        if(~rst)
            fsm_ps      <= INIT;
        else
            fsm_ps      <= fsm_ns;
   end
	 
	
	always_comb 
	begin
		fsm_ns							=	fsm_ps;
		write_en							=	0;
		case(fsm_ps)
			INIT:
			begin
				fsm_ns	= START_SPI_RX;
			end
			START_SPI_RX:
			begin
				if(ssn_negedge) begin
					fsm_ns = RECEIVE_DATA;
				end
				else
					fsm_ns = START_SPI_RX;
			end
			RECEIVE_DATA:
			begin
				if(sclk_negedge) begin
					write_en = 1;
					if(receive_data_counter==8) 
						fsm_ns = FINISH;
				end
			end
			FINISH:
			begin
				fsm_ns = INIT;
			end
			
		endcase
	end
	
endmodule
