module rs232_tx(
	input logic clk,
	input logic rst,
	input logic tx_req,
	input logic [7:0]tx_data,
	output logic tx,
	output logic tx_ack
	);
	

	//baud_counter
	logic rst_baud_cnt;
	logic [15:0]baud_cnt;
	
	always_ff@(posedge clk)
	begin
		if(~rst || rst_baud_cnt) 
			baud_cnt <= 0;
		else 
			baud_cnt <= baud_cnt + 1'b1; 
	end
	
	//bit_counter
	logic [3:0] bit_cnt;
	logic rst_bit_cnt;
	logic bit_flag;
	
	always_ff@(posedge clk)
	begin
		if(~rst || rst_bit_cnt) 
			bit_cnt <= 0;
		else if(bit_flag)
			bit_cnt <= bit_cnt + 1'b1;
	end
	
	//baud_cnt_compare
	logic baud_cnt_max;
	assign baud_cnt_max  = (baud_cnt == 1301) ? 1 : 0;
	
	//shift_register
	logic [9:0] data;
	logic load_tx_data;
	
	always_ff@(posedge clk)
	begin
		if(~rst)
			data <= 9'b111111111;
		else if(load_tx_data)
			data <= {1'b1, tx_data, 1'b0};
		else if(bit_flag)
			data <= {1'b1, data[9:1]};
	end
	
	//output_register
	logic send_tx_data;
	
	always_ff@(posedge clk)
	begin
		if(~rst || tx_ack)
			tx <= 1'b1;
		else if(send_tx_data)
			tx <= data[0];
	end    
	
	//FSM
	typedef enum{ IDLE, CHK_REQ, LD_TX_D, 
	CHK_BIT_CNT, TRANS, COMP} FSM_STATE;
	FSM_STATE fsm_ns,fsm_ps;
	
	always_ff@(posedge clk) begin
        if(~rst)
            fsm_ps      <= IDLE;
        else
            fsm_ps      <= fsm_ns;
   end
	
	always_comb 
	begin
		fsm_ns			=	fsm_ps;
		rst_baud_cnt	=	0;
		rst_bit_cnt		=	0;
		bit_flag			=	0;
		load_tx_data	=	0;
		tx_ack			=	0;
		send_tx_data	=  0;
		case(fsm_ps)
			IDLE:
			begin
				fsm_ns	= CHK_REQ;
			end
			CHK_REQ:
			begin
				if(tx_req)
					fsm_ns = LD_TX_D;
			end
			LD_TX_D:
			begin
				load_tx_data = 1;
				fsm_ns = CHK_BIT_CNT;
			end
			CHK_BIT_CNT:
			begin
				rst_baud_cnt = 1;
				send_tx_data = 1;
				if(bit_cnt == 10)
					fsm_ns = COMP;
				else
					fsm_ns = TRANS;
			end
			TRANS:
			begin
				send_tx_data = 1;
				if(baud_cnt_max) begin
					bit_flag = 1;
					fsm_ns = CHK_BIT_CNT;
				end
			end
			COMP:
			begin
				rst_bit_cnt = 1;
				tx_ack	   = 1;
				fsm_ns = CHK_REQ;
			end
		endcase
	end
	
	
endmodule
