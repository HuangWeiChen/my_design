module handshaking(
	input clk, 
	input rst, 
	output logic[3:0] c1,
	output logic[3:0] c2,
	output logic[3:0] c3,
	output logic[3:0] c4
	);
	
//////////////////FSM begin//////////////////
	logic cp1, cp2, cp3, cp4;
	logic trigger_1, trigger_2, trigger_3,trigger_4;

	typedef enum {START, PLUS_CNT1, PLUS_CNT2, PLUS_CNT3, PLUS_CNT4
			, TRG1, TRG2, TRG3, TRG4, WAIT_TRG1, WAIT_TRG2, WAIT_TRG3, WAIT_TRG4} fsm_state;
	fsm_state fsm1_ps, fsm1_ns, fsm2_ps, fsm2_ns, fsm3_ps, fsm3_ns, fsm4_ps, fsm4_ns;

	//FSM1
	always_ff @(posedge clk) begin
		if(rst)
			fsm1_ps <= START;
		else
			fsm1_ps <= fsm1_ns;
	end
	//FSM2
	always_ff @(posedge clk) begin
		if(rst)
			fsm2_ps <= START;
		else
			fsm2_ps <= fsm2_ns;
	end
	//FSM3
	always_ff @(posedge clk) begin
		if(rst)
			fsm3_ps <= START;
		else
			fsm3_ps <= fsm3_ns;
	end
	//FSM4
	always_ff @(posedge clk) begin
		if(rst)
			fsm4_ps <= START;
		else
			fsm4_ps <= fsm4_ns;
	end
	//FSM1_comb
	always_comb begin
		cp1 = 0;
		trigger_2 = 0;
		case(fsm1_ps)
			START: begin
				fsm1_ns = PLUS_CNT1;
			end
			PLUS_CNT1: begin 
				if(c1 == 10)
					fsm1_ns = TRG2;
				else begin
					cp1 = 1;
					fsm1_ns =  PLUS_CNT1;
				end
			end
			TRG2: begin
				trigger_2 = 1;
				fsm1_ns =  WAIT_TRG1;
			end
			WAIT_TRG1: begin 
				if(trigger_1 == 1) begin
					cp1 = 1;
					fsm1_ns =  PLUS_CNT1;
				end
				else
					fsm1_ns =  WAIT_TRG1;
			end
			default:
				fsm1_ns = fsm1_ps;
		endcase
	end
	
	//FSM2_comb
	always_comb begin
		cp2 = 0;
		trigger_3 = 0;
		case(fsm2_ps)
			START: begin
				fsm2_ns = WAIT_TRG2;
			end
			WAIT_TRG2: begin 
				if(trigger_2 == 1)begin
					cp2 = 1;
					fsm2_ns = PLUS_CNT2;
				end
				else
					fsm2_ns = WAIT_TRG2;
			end
			PLUS_CNT2: begin 
				if(c2==7)
					fsm2_ns = TRG3;
				else begin
					cp2 = 1;
					fsm2_ns = PLUS_CNT2;
				end
			end
			TRG3: begin 
				trigger_3 = 1;
				fsm2_ns = WAIT_TRG2;
			end
			default:
				fsm2_ns = fsm2_ps;
		endcase
	end
	
	//FSM3_comb
	always_comb begin
		cp3 = 0;
		trigger_4 = 0;
		case(fsm3_ps)
			START: begin
				fsm3_ns = WAIT_TRG3;
			end
			WAIT_TRG3: begin 
				if(trigger_3 == 1)begin
					cp3 = 1;
					fsm3_ns = PLUS_CNT3;
				end
				else
					fsm3_ns = WAIT_TRG3;
			end
			PLUS_CNT3: begin 
				if(c3==15)
					fsm3_ns = TRG4;
				else begin
					cp3 = 1;
					fsm3_ns = PLUS_CNT3;
				end
			end
			TRG4: begin 
				trigger_4 = 1;
				fsm3_ns = WAIT_TRG3;
			end
			default:
				fsm3_ns = fsm3_ps;
		endcase
	end
	
	//FSM4_comb
	always_comb begin
		cp4 = 0;
		trigger_1 = 0;
		case(fsm4_ps)
			START: begin
				fsm4_ns = WAIT_TRG4;
			end
			WAIT_TRG4: begin 
				if(trigger_4 == 1)begin
					cp4 = 1;
					fsm4_ns = PLUS_CNT4;
				end
				else
					fsm4_ns = WAIT_TRG4;
			end
			PLUS_CNT4: begin 
				if(c4==3)
					fsm4_ns = TRG1;
				else begin
					cp4 = 1;
					fsm4_ns = PLUS_CNT4;
				end
			end
			TRG1: begin 
				trigger_1 = 1;
				fsm4_ns = WAIT_TRG4;
			end
			default:
				fsm4_ns = fsm4_ps;
		endcase
	end
//////////////////FSM end//////////////////

	//cnt_1
	always_ff @(posedge clk) begin
		if(rst)
			c1 <= 4'b0;
		else if(cp1)
			c1 <= c1+1'b1;
	end

	//cnt_2
	always_ff @(posedge clk) begin
		if(rst)
			c2 <= 4'b0;
		else if(cp2)
			c2 <= c2+1'b1;
	end
	
	//cnt_3
	always_ff @(posedge clk) begin
		if(rst)
			c3 <= 4'b0;
		else if(cp3)
			c3 <= c3+1'b1;
	end

	//cnt_4
	always_ff @(posedge clk) begin
		if(rst)
			c4 <= 4'b0;
		else if(cp4)
			c4 <= c4+1'b1;
	end


endmodule
