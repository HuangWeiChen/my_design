`timescale 1ns/100ps
module sequence_detect(
	input logic clk,
	input logic rst,
	input logic signal_in,
	input logic valid,
	input logic [7:0]target,
	output logic detect
	);
	
	
	logic [7:0] seq;
	logic [3:0] cnt;
	
	always_ff@(posedge clk) begin
		if(rst || !valid)
		begin
			detect	<=	0;
			seq 		<= 0;
			cnt 		<= 0;
      end
		else
			begin
				seq = {seq[6:0], signal_in};

            if (cnt == 7) 
				begin 
               if (seq == target) 
					begin
                    detect	= 1;
                    cnt 	= 0;
               end 
					else 
					begin
                    detect	= 0;
                    cnt 	= 4;
               end
				end 
				else 
				begin
                detect  = 0;
                cnt 		= cnt + 1;
            end
        end
    end
	 
endmodule