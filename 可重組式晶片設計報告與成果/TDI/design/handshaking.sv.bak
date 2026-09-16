module adavanced(
	input logic clk,
	input logic rst,
	input logic fin,
	output logic valid,
	output logic [7:0]data
	);
	
	typedef enum{
       init, delay, pass_data, wait_fin, finish
   } fsm_state;
	 
	logic [39:0] regg;
	logic [4:0]  cnt1;
	logic [4:0]  data_cnt;
	logic 		 cp1;
	logic 		 left;
	logic			 dc;
	
	always_ff @(posedge clk) begin
		if(rst)
			regg <= 'h0A55BBFF00;
		else if(left)
			regg <= regg << 8;
	end
	 
	always_ff @(posedge clk) begin
		if(rst)
		begin
			cnt1 <= 5'b0;
			data_cnt <=5'b0;
		end
		else if(cp1)
			cnt1 <= cnt1+1'b1;
		else if(dc)
			data_cnt <= data_cnt+1'b1;
		else if(cnt1 == 10) 
			cnt1 <= 5'b0;
	end
	
	fsm_state fsm_ps, fsm_ns;
	
	always_ff@(posedge clk) begin
        if(rst)
        begin
            fsm_ps      <= init;
        end
        else
        begin
            fsm_ps      <= fsm_ns;
        end
    end

    always_comb
    begin
         fsm_ns= fsm_ps;
			left	= 0;
			dc		= 0;
			cp1	= 0;
			valid = 0;
			data	= regg[39:32];
			case(fsm_ps)
				init:
				begin
					valid = 0;
					fsm_ns = delay;
				end
				delay:
				begin
					valid = 0;
					if(data_cnt == 5)
						fsm_ns = finish;
					else
					begin
						if(cnt1 == 10)
						begin
							fsm_ns = pass_data;
						end
						else
							cp1 = 1;
					end
				end
				pass_data:
				begin
					data  = regg[39:32];
					left  = 1;
					valid = 1;
					dc 	= 1;
					fsm_ns = wait_fin;
				end
				wait_fin:
				begin
					data  = regg[39:32];
					if(fin)
					begin
						fsm_ns = init;
					end
				end
				finish:
				begin
					fsm_ns = finish;
				end
			endcase
	 end
endmodule
