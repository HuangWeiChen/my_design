module risc_v(
	input	logic clk,
	input	logic rst,
	//
	output logic [31:0] regs_31
	//
);    
  	logic [31:0] rs1_value;
	logic [31:0] rs2_value;
	logic [31:0] pc;
	logic [31:0] pc_next_;
	logic rst_pc_;
	logic sel_pc_r;
	logic flush_IDEX_r;
	logic flush_IFID_r;
	//加法器
	//assign pc_next_ = pc+4;
	logic [31:0]pc_r,pc_rr;
	//program counter
	always_ff@(posedge clk)
	begin
		if(rst|rst_pc_)
			pc<= 32'b0;
		else
			pc <= pc_next_;
	end
	
	logic [31:0] inst_;
	Program_Rom Program_Rom_1(
		.Rom_addr	(pc),
		.Rom_data	(inst_)
	);
	
	// IF/ID
	logic [31:0] inst_r;
	logic flush_IFID_;
	always_ff@(posedge clk)
   begin
		if(rst)begin
			inst_r <= 32'h13;
			pc_r <= 0;
			end
		else if(flush_IFID_r)begin
			inst_r <= 32'h13;
			pc_r <= 0;
			end
		else
		begin
			inst_r <= inst_;
			pc_r <= pc;
		end
	end
	`define F_BEQ		3'b000
	`define F_BNE		3'b001
	`define F_BLT		3'b100
	`define F_BGE		3'b101
	`define F_BLTU		3'b110
	`define F_BGEU		3'b111
	`define F_LB 		3'b000
	`define F_LH  		3'b001
	`define F_LW  		3'b010
	`define F_LBU  	3'b100
	`define F_LHU  	3'b101
	`define F_SB  		3'b000
	`define F_SH  		3'b001
	`define F_SW  		3'b010
	`define F_MUL		3'b000
	`define F_MULH		3'b001
	`define F_MULHSU	3'b010
	`define F_MULHU	3'b011
	`define F_DIV		3'b100
	`define F_DIVU		3'b101
	`define F_REM		3'b110
	`define F_REMU		3'b111
	//inst_decoder
	
	`define opcode_I			7'b0010011
	`define opcode_R			7'b0110011
	`define opcode_B			7'b1100011
	`define opcode_JAL		7'b1101111
	`define opcode_JALR		7'b1100111
	`define opcode_LUI		7'b0110111
	`define opcode_AUIPC		7'b0010111
	`define opcode_L			7'b0000011
	`define opcode_S			7'b0100011
	`define F7_M				7'b0000001
	`define opcode_M			7'b0110011
	
	logic [6:0] opcode_,funct7_;
	logic [4:0] addr_rd_;
	logic [2:0] funct3_;
	logic [4:0] addr_rs1,addr_rs2;
	logic [31:0] imm_;
	
	assign opcode_ 	= inst_r[6:0];
	assign addr_rd_ 	= inst_r[11:7]; 
	assign funct3_ 	= inst_r[14:12];
	assign addr_rs1	= inst_r[19:15];
	assign addr_rs2	= inst_r[24:20];
	assign funct7_ 	= inst_r[31:25];
	
	logic[31:0] IMM_I;
	logic[31:0] IMM_B;
	logic[31:0] IMM_JAL;
	logic[31:0] IMM_LUI_AUIPC;
	logic[31:0] IMM_S;
	assign IMM_I		= {{20{inst_r[31]}},inst_r[31:20]};
	assign IMM_B		= {{20{inst_r[31]}}, inst_r[7], inst_r[30:25], inst_r[11:8], 1'b0};
	assign IMM_JAL		= {{12{inst_r[31]}}, inst_r[19:12], inst_r[20], inst_r[30:21], 1'b0};
	assign IMM_LUI_AUIPC = {inst_r[31:12],12'b0};
	assign IMM_S		= {{20{inst_r[31]}},inst_r[31:25],inst_r[11:7]};
	
	
	always_comb begin
		unique case (opcode_)
			`opcode_I : imm_ = IMM_I;
			`opcode_B : imm_ = IMM_B;
			`opcode_JAL: imm_ = IMM_JAL;
			`opcode_JALR : imm_ = IMM_I;
			`opcode_LUI : imm_ = IMM_LUI_AUIPC;
			`opcode_AUIPC : imm_ = IMM_LUI_AUIPC;
			`opcode_L:imm_ = IMM_I;
			`opcode_S:imm_ = IMM_S;
		endcase
	end
	
	// ALU operation
	
	`define ALUOP_ADD			4'h0
	`define ALUOP_SUB			4'h1
	`define ALUOP_AND			4'h2
	`define ALUOP_OR			4'h3
	`define ALUOP_XOR			4'h4
	`define ALUOP_A			4'h5
	`define ALUOP_A_ADD_4	4'h6
	`define ALUOP_LTU			4'h7
	`define ALUOP_LT			4'h8
	`define ALUOP_SLL			4'h9
	`define ALUOP_SRL			4'hA
	`define ALUOP_SRA			4'hB
	`define ALUOP_B			4'hC
	
	//controller
	
	logic BEQ_FLAG;
	logic BNE_FLAG;
	logic BLT_FLAG;
	logic BGE_FLAG;
	logic BLTU_FLAG;
	logic BGEU_FLAG;
	
	assign BEQ_FLAG	= (rs1_value == rs2_value);
	assign BNE_FLAG	= (rs1_value != rs2_value);
	assign BLT_FLAG	= ($signed(rs1_value)  < $signed(rs2_value));
	assign BGE_FLAG	= ($signed(rs1_value)  >= $signed(rs2_value));
	assign BLTU_FLAG	= (rs1_value < rs2_value);
	assign BGEU_FLAG	= (rs1_value >= rs2_value);
	
	logic flush_IDEX_;
	logic write_regf_en_;
	logic sel_pc_;
	logic sel_alu_a_;
	logic [1:0] sel_alu_b_;
	logic sel_jump_;
	logic [3:0] op_;
	logic write_ram_;
	logic [1:0] sel_rd_value_;
	typedef enum {S0, S1, S2, S3}FSM_STATE;
	FSM_STATE ps, ns;
	
	always_ff@(posedge clk)
	begin	
		if(rst)
			ps <= #1 S0;
		else
			ps <= #1 ns;
		
	end
	always_comb 
	begin
		write_ram_		= 0;
		sel_rd_value_	= 0;
		write_regf_en_ = 0;
		sel_jump_		= 1;
		rst_pc_			= 0;
		flush_IFID_		= 0;
		flush_IDEX_		= 0;
		op_				= 0;
		sel_alu_b_ 		= 0;
		sel_alu_a_		= 0;
		sel_pc_ = 0;
		ns					= ps;
		unique case(ps)
			S0:
			begin
				flush_IFID_		= 1;
				flush_IDEX_		= 1;
				rst_pc_			= 1;
				ns					= S1;
			end
			S1:
			begin
				flush_IFID_		= 1;
				flush_IDEX_		= 1;
				rst_pc_			= 1;
				ns					= S2;
			end
			S2:
			begin
				unique case(opcode_)
					`opcode_I : begin
										write_regf_en_ = 1;
										case(funct3_)
											0: op_ = `ALUOP_ADD;
											1: op_ = `ALUOP_SLL;
											2: op_ = `ALUOP_LT;
											3: op_ = `ALUOP_LTU;
											4: op_ = `ALUOP_XOR;
											5: begin 
													if(funct7_ == 7'h0) op_ = `ALUOP_SRL;else op_ = `ALUOP_SRA;
												end
											6: op_ = `ALUOP_OR;
											7: op_ = `ALUOP_AND;
										endcase
									end
					`opcode_R : begin
										if(funct7_ != `F7_M) begin
											write_regf_en_ = 1;
											sel_alu_b_		= 1;
											case(funct3_)
												0: begin 
														if(funct7_ == 7'h0) op_ = `ALUOP_ADD;else op_ = `ALUOP_SUB;
													end
												1: op_ = `ALUOP_SLL;
												2: op_ = `ALUOP_LT;
												3: op_ = `ALUOP_LTU;
												4: op_ = `ALUOP_XOR;
												5: begin 
														if(funct7_ == 7'h0) op_ = `ALUOP_SRL;else op_ = `ALUOP_SRA;
													end
												6: op_ = `ALUOP_OR;
												7: op_ = `ALUOP_AND;
											endcase
										end
										else
										begin
										if((funct3_ == `F_MUL)&(funct7_ == `F7_M)) begin
											write_regf_en_ = 1;
											sel_rd_value_ = 2;
										end
										else if((funct3_ == `F_MULHU)&(funct7_ == `F7_M)) begin
											write_regf_en_ = 1;
											sel_rd_value_ = 2;
										end
										else if((funct3_ == `F_MULHSU)&(funct7_ == `F7_M)) begin
											write_regf_en_ = 1;
											sel_rd_value_ = 2;
										end
										else if((funct3_ == `F_MULH)&(funct7_ == `F7_M)) begin
											write_regf_en_ = 1;
											sel_rd_value_ = 2;
										end
										else if((funct3_ == `F_DIV)&(funct7_ == `F7_M)) begin
											write_regf_en_ = 1;
											sel_rd_value_ = 3;
										end
										else if((funct3_ == `F_DIVU)&(funct7_ == `F7_M)) begin
											write_regf_en_ = 1;
											sel_rd_value_ = 3;
										end
										else if((funct3_ == `F_REM)&(funct7_ == `F7_M)) begin
											write_regf_en_ = 1;
											sel_rd_value_ = 3;
										end
										else if((funct3_ == `F_REMU)&(funct7_ == `F7_M)) begin
											write_regf_en_ = 1;
											sel_rd_value_ = 3;
										end
									end
									end
					`opcode_B : begin
										case(funct3_)
											`F_BEQ : begin 
													if(BEQ_FLAG) begin
														sel_pc_ = 1;
														flush_IFID_ = 1;
														flush_IDEX_ = 1;
													end
											end
											`F_BNE : begin 
													if(BNE_FLAG) begin
														sel_pc_ = 1;
														flush_IFID_ = 1;
														flush_IDEX_ = 1;
													end
											end
											`F_BLT : begin 
													if(BLT_FLAG) begin
														sel_pc_ = 1;
														flush_IFID_ = 1;
														flush_IDEX_ = 1;
													end
											end
											`F_BGE : begin 
													if(BGE_FLAG) begin
														sel_pc_ = 1;
														flush_IFID_ = 1;
														flush_IDEX_ = 1;
													end
											end
											`F_BLTU : begin 
													if(BLTU_FLAG) begin
														sel_pc_ = 1;
														flush_IFID_ = 1;
														flush_IDEX_ = 1;
													end
											end
											`F_BGEU : begin 
													if(BGEU_FLAG) begin
														sel_pc_ = 1;
														flush_IFID_ = 1;
														flush_IDEX_ = 1;
													end
											end
											
										endcase
									end
						`opcode_JAL : begin
										sel_pc_ = 1;
										flush_IFID_ = 1;
										flush_IDEX_ = 1;
										sel_alu_a_ = 1;
										sel_alu_b_ = 2;
										sel_jump_ = 1;
										op_ = `ALUOP_ADD;
										write_regf_en_ = 1;
										
									end
						`opcode_JALR : begin
										sel_pc_ = 1;
										flush_IFID_ = 1;
										flush_IDEX_ = 1;
										sel_alu_a_ = 1;
										sel_alu_b_ = 2;
										sel_jump_ = 0;
										op_ = `ALUOP_ADD;
										write_regf_en_ = 1;
										
									end
						`opcode_LUI : begin
										sel_alu_b_ = 0;
										op_ = `ALUOP_B;
										write_regf_en_ = 1;
										
									end
						`opcode_AUIPC : begin
										sel_alu_a_ = 1;
										sel_alu_b_ = 0;
										op_ = `ALUOP_ADD;
										write_regf_en_ = 1;
										
									end
						`opcode_L : begin
										if(funct3_ == `F_LB) begin
											op_ = `ALUOP_ADD;
											sel_rd_value_ = 1;
											write_regf_en_ = 1;
										end
										else if(funct3_ == `F_LH) begin
											op_ = `ALUOP_ADD;
											sel_rd_value_ = 1;
											write_regf_en_ = 1;
										end
										else if(funct3_ == `F_LW) begin
											op_ = `ALUOP_ADD;
											sel_rd_value_ = 1;
											write_regf_en_ = 1;
										end
										else if(funct3_ == `F_LBU) begin
											op_ = `ALUOP_ADD;
											sel_rd_value_ = 1;
											write_regf_en_ = 1;
										end
										else if(funct3_ == `F_LHU) begin
											op_ = `ALUOP_ADD;
											sel_rd_value_ = 1;
											write_regf_en_ = 1;
										end
									end
						`opcode_S : begin
										if(funct3_ == `F_SB) begin
											op_ = `ALUOP_ADD;
											write_ram_ = 1;
										end
										else if(funct3_ == `F_SH) begin
											op_ = `ALUOP_ADD;
											write_ram_ = 1;
										end
										else if(funct3_ == `F_SW) begin
											op_ = `ALUOP_ADD;
											write_ram_ = 1;
										end
									end
					default;
				endcase
			end
		endcase
	end
	
	//reg_file
	logic write_regf_en_r;
	logic [4:0] addr_rd_r;
	logic [31:0] rd_value_;
	
	
	logic [31:0] regs[0:31];	
	logic addr_rd_not_0;

	integer i;

	assign addr_rd_not_0 = |addr_rd_r;
	
	assign rs1_value = regs[addr_rs1];
	assign rs2_value = regs[addr_rs2];
	
	always_ff@(posedge clk)
	begin
		if(rst) begin
			for(i = 0; i < 32; i = i+1) begin:rst_keywords
				regs[i] <= 0;
			end
		end
		else begin
			// Write
			if (write_regf_en_r && addr_rd_not_0)
				regs[addr_rd_r] <= #1 rd_value_;
		end
	end
	//
	assign regs_31 = regs[31];
	//
	// ID/EX
	logic [2:0] funct3_r;
	logic [31:0] imm_r;
	logic [31:0] rs1_value_r;
	logic [31:0] rs2_value_r;
	logic [3:0]  op_r;
	logic [1:0]sel_alu_b_r;
	logic sel_alu_a_r;
	logic sel_jump_r;
	logic write_ram_r;
	logic [1:0] sel_rd_value_r;
	always_ff@(posedge clk)
   begin
		if(rst|flush_IDEX_r)
		begin
			addr_rd_r		<= 5'b0;
			imm_r			<= 32'b0;
			rs1_value_r	<= 32'b0;
			rs2_value_r	<= 32'b0;
			write_regf_en_r <= 0;
			flush_IFID_r	<= 0;
			flush_IDEX_r	<= 0;
			pc_rr				<= 0;
			sel_pc_r			<= 0;
			sel_jump_r		<= 0;
			sel_alu_a_r		<= 0;
			sel_alu_b_r		<= 0;
			op_r				<= 0;
			write_ram_r		<= 0;
			sel_rd_value_r	<= 0;
			funct3_r			<= 0;
		end
		else
		begin
			addr_rd_r		<= addr_rd_;
			imm_r				<= imm_;
			rs1_value_r		<= rs1_value;
			rs2_value_r		<= rs2_value;
			write_regf_en_r <= write_regf_en_;
			sel_alu_b_r 	<= sel_alu_b_;
			sel_alu_a_r 	<= sel_alu_a_;
			op_r 				<= op_;
			pc_rr 			<= pc_r;
			sel_pc_r			<= sel_pc_;
			flush_IFID_r	<= flush_IFID_;
			flush_IDEX_r	<= flush_IDEX_;
			sel_jump_r		<= sel_jump_;
			write_ram_r		<= write_ram_;
			sel_rd_value_r	<= sel_rd_value_;
			funct3_r			<= funct3_;
		end
	end
	logic [31:0] base_addr_;
	logic [31:0] jump_addr_;
	logic [31:0] j_addr_;
	assign base_addr_ = sel_jump_r ? pc_rr : rs1_value_r;
	assign j_addr_ = base_addr_ + imm_r;
	assign jump_addr_ = {j_addr_[31:1], (j_addr_[0] & sel_jump_r)};
	
	always_comb
	begin
		if(sel_pc_r)
			pc_next_ = jump_addr_;
		else
			pc_next_ = pc + 4;
	end
	//ALU
	
	logic [31:0] alu_a_;
	logic [31:0] alu_b_;
	logic [31:0] alu_out_;
	logic [31:0] div_out;
	logic [31:0] mul_out;
	assign alu_a_ = sel_alu_a_r ? pc_rr : rs1_value_r;
	always_comb
	begin
		if(sel_alu_b_r == 0)
			alu_b_ = imm_r;
		else if(sel_alu_b_r == 1)
			alu_b_ = rs2_value_r;
		else if(sel_alu_b_r == 2)
			alu_b_ = 4;
		else 
			alu_b_ = 4;
	end
	
	alu alu_1	(
		.op		(op_r		),
		.alu_a	(alu_a_	),
		.alu_b	(alu_b_	),
		.alu_out	(alu_out_)
	);
	
	mul mul1		(
		.funct3		(funct3_r		),
		.rs1_value	(rs1_value_r	),
		.rs2_value	(rs2_value_r	),
		.mul_out		(mul_out			)
	);
	
	div div1		(
		.funct3		(funct3_r		),
		.rs1_value	(rs1_value_r	),
		.rs2_value	(rs2_value_r	),
		.div_out		(div_out			)
	);
	//load and store unit
	logic [31:0] read_data;
	LSU LSU1		(
		.clk			(clk	),
		.write_ram	(write_ram_r	),
		.funct3		(funct3_r		),
		.write_data	(rs2_value_r	),
		.ram_addr	(alu_out_		),
		.read_data	(read_data		)
	);
	always_comb
	begin
		if(sel_rd_value_r == 0)
			rd_value_ = alu_out_;
		else if(sel_rd_value_r == 1)
			rd_value_ = read_data;
		else if(sel_rd_value_r == 2)
			rd_value_ = mul_out;
		else 
			rd_value_ = div_out;
	end
endmodule

