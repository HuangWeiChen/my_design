`timescale 1ns/100ps
module btn_signal(
	input logic clk,
	input logic rst_n,
	input logic sig_filter,
	output logic trigger,
	output logic [3:0]cnt
	);
	
	//Edge Detector
	logic s_signal;
	logic d_signal;
	logic ssn_negedge;
	logic sclk_posedge;
	
	always_ff@(posedge clk)
	begin
		if(~rst_n) 
		begin
			s_signal			<= 1'b1;
			d_signal 		<= 1'b1;
			ssn_negedge		<= 1'b0;
			sclk_posedge	<= 1'b0;
		end
		else 
		begin
			{d_signal, s_signal} 	<= {s_signal, sig_filter};
			ssn_negedge 			<= ~s_signal & d_signal;
			sclk_posedge 			<= s_signal & ~d_signal;
		end
	end
	
	//Counter
	logic rst_cnt;
	
	always_ff@(posedge clk)
	begin
		if(~rst_n || rst_cnt) 
			cnt <= 4'b0;
		else if(ssn_negedge)
			cnt <= cnt + 1'b1;
	end
	
	
	
	//FSM
	typedef enum{ INIT, PLUS, FINISH
   } FSM_STATE;
	FSM_STATE fsm_ns,fsm_ps;
	
	always_ff@(posedge clk) begin
        if(~rst_n)
            fsm_ps      <= INIT;
        else
            fsm_ps      <= fsm_ns;
   end
	 
	logic receive_data_counter_rst;
	logic rx_finish;
	
	always_comb 
	begin
		fsm_ns	=	fsm_ps;
		rst_cnt	=	0;
		trigger  =  0;
		case(fsm_ps)
			INIT:
			begin
				fsm_ns	= PLUS;
			end
			PLUS:
			begin
				if(cnt == 5) begin
					fsm_ns  = FINISH;
				end
				else
					fsm_ns = PLUS;
			end
			FINISH:
			begin
				trigger = 1;
				rst_cnt = 1;
				fsm_ns  = PLUS;
			end
			
		endcase
	end
	
endmodule
