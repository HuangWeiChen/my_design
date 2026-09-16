module adavanced2(
	input logic clk,
	input logic rst,
	input logic valid,
	input logic [7:0]data,
	output logic fin,
	output logic [7:0]recv
	);
	
	typedef enum{
       init, output_data, for_fin, detect_valid
   } fsm_state;

	fsm_state fsm_ps, fsm_ns;
	
	logic [7:0]recv_ns;
	always_ff@(posedge clk) begin
        if(rst)
        begin
				recv			<= 0;
            fsm_ps      <= init;
        end
        else
        begin
				recv			<= recv_ns;
            fsm_ps      <= fsm_ns;
        end
    end
	 
	 always_comb
    begin
         fsm_ns= fsm_ps;
			fin = 0;
			recv_ns = recv;
			case(fsm_ps)
				init:
				begin
					if(valid)
					begin
						recv_ns = data;
						fsm_ns = output_data;
					end
				end
				output_data:
				begin
					if(valid)
					begin
						fsm_ns = for_fin;
					end
				end
				for_fin:
				begin
					fin = 1;
					fsm_ns = detect_valid;
				end
				detect_valid:
				begin
					fin = 1;
					
					if(!valid)
					begin
						fsm_ns = init;
					end
						
				end
				
			endcase
	 end
	 
	 
endmodule
