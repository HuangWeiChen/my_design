`timescale 1ns/100ps
module Program_Rom(
	input	logic [31:0] Rom_addr,
	output	logic [31:0] Rom_data
);    
  
    always_comb begin
        case (Rom_addr)
			32'h0  : Rom_data = 32'h00300113;
			32'h4  : Rom_data = 32'h00700193;
			32'h8  : Rom_data = 32'h01000237;
			32'hc  : Rom_data = 32'h00000013;
			32'h10 : Rom_data = 32'hfff20213;
			32'h14 : Rom_data = 32'h00202023;
			32'h18 : Rom_data = 32'h00002f83;
			32'h1c : Rom_data = 32'h00000317;
			32'h20 : Rom_data = 32'h00000013;
			32'h24 : Rom_data = 32'h020300e7;
			32'h28 : Rom_data = 32'h023f8fb3;
			32'h2c : Rom_data = 32'h00000013;
			32'h30 : Rom_data = 32'hfe4fd2e3;
			32'h34 : Rom_data = 32'h01f02023;
			32'h38 : Rom_data = 32'hfe1ff06f;
			32'h3C : Rom_data = 32'h00001537;
			32'h40 : Rom_data = 32'h38850513;
			32'h44 : Rom_data = 32'h3e800593;
			32'h48 : Rom_data = 32'h00000013;
			32'h4C : Rom_data = 32'h00000013;
			32'h50 : Rom_data = 32'hfff58593;
			32'h54 : Rom_data = 32'h00000013;
			32'h58 : Rom_data = 32'h00000013;
			32'h5C : Rom_data = 32'hfe059ae3;
			32'h60 : Rom_data = 32'hfff50513;
			32'h64 : Rom_data = 32'h00000013;
			32'h68 : Rom_data = 32'h00000013;
			32'h6C : Rom_data = 32'hfc051ce3;
			32'h70 : Rom_data = 32'h00008067;
            default: Rom_data = 32'h00000013;   //NOP
        endcase
    end
endmodule

