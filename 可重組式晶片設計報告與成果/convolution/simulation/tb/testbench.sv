`timescale 1ns/1ps

module testbench();


	//=======================================================
    //  declarations
    //=======================================================


	//系統
	logic 		 		clk;			//系統clk(50MHz)
	logic				reset;			//系統reset

	//DE_CV
	wire [35:0]		GPIO;
	
	//SPI
	logic [15:0] 		get_data;
	logic				cmd_miso;
	logic				cmd_mosi;
	logic				cmd_ssn;		
	logic				cmd_sclk;		//10MHz
	parameter  			WRITE = 0;
	parameter  			READ = 1;
	parameter  			DIGITS = 16;	//傳輸位元數
	parameter 			SPI_T = 50;		//控制ssn的傳輸速度

	integer conv_result_file;
	logic [15:0] conv_result;
	logic update;
	bit result;
	

    //=======================================================
    //  Structural coding
    //=======================================================
	

	assign 	GPIO[0]		=	cmd_mosi;
	assign 	GPIO[1]		=	cmd_sclk;
	assign 	GPIO[2]		=	cmd_ssn;
	assign 	cmd_miso	=	GPIO[3];

	DE0_CV DE0_CV1(
		//////////// CLOCK //////////
		.CLOCK_50 			(clk),
		.CLOCK2_50			(),
		.CLOCK3_50			(),
		.CLOCK4_50			(),
		//////////// SEG7 //////////
		.HEX0				(),
		.HEX1				(),
		.HEX2				(),
		.HEX3				(),
		.HEX4				(),
		.HEX5				(),
		//////////// KEY //////////
		.KEY				(),
		.RESET_N			(~reset), //RESET_N=0時，系統重製
		//////////// LED //////////
		.LEDR				(),
		//////////// microSD Card //////////
		.SD_CLK				(),
		.SD_CMD				(),
		.SD_DATA			(),
		//////////// SW //////////
		.SW					(),
		//////////// GPIO_0, GPIO_0 connect to
		.GPIO_0				(GPIO),
		//////////// GPIO_1, GPIO_1 connect to
		.GPIO_1				(),
		.conv_result		(conv_result),
		.update				(update)
	);

	task write(
		//前16 bits寫入address+command
		//後16 bits寫入data
		input logic [7:0]	write_address,
		input logic 		command,
		input logic [15:0] 	data
		);

		//declarations
		logic [15:0] 		shift_register;
		integer				i;

		//開始傳輸
		cmd_ssn = 1;
		#100
		shift_register = {write_address, command ,7'b0};
		#200;
		cmd_ssn = 0;

		for (i=0; i<DIGITS; i=i+1) begin
			cmd_mosi = shift_register[15];
			shift_register = shift_register << 1;
			#SPI_T cmd_sclk = 1;
			#SPI_T cmd_sclk = 0;
		end
		
		shift_register = data;
		#200;

		for (i=0; i<DIGITS; i=i+1) begin
			cmd_mosi = shift_register[15];
			shift_register = shift_register << 1;
			#SPI_T cmd_sclk = 1;
			#SPI_T cmd_sclk = 0;
		end
		
		//傳輸結束復位
		cmd_mosi = 0;
		cmd_sclk = 0;
		#200;
		cmd_ssn = 1;
	endtask

	task read(
		//前16 bits寫入address+command
		//後16 bits讀取data
		input  logic [7:0]	read_address,
		input  logic 		command,
		output logic [15:0] data
		);
		
		logic [15:0] 		shift_register;
		integer				i;

		//開始傳輸  
		cmd_ssn = 1;
		#100;
		shift_register = {read_address, command , 7'b0};
		#200;
		cmd_ssn = 0;
		for (i=0; i<DIGITS; i=i+1) begin
			cmd_mosi = shift_register[15];
			shift_register = shift_register << 1;
			#SPI_T cmd_sclk = 1;
			#SPI_T cmd_sclk = 0;
		end

		cmd_mosi = 0;
		#200;

		//接收回傳
		for (i=0; i<DIGITS; i=i+1) begin
			#SPI_T cmd_sclk = 1;
			data = {data[15:0], cmd_miso};
			#SPI_T cmd_sclk = 0;
		end

		//傳輸結束復位
		#200;
		cmd_sclk = 0;
		#200;
		cmd_ssn = 1;
	endtask 

	task load_and_write_from_file(input string filename);
		integer file, status;
		string line;
		int line_num;
		reg [7:0] addr;
		reg [15:0] data;

		file = $fopen(filename, "r");
		if (file == 0) begin
			$display("ERROR: Failed to open %s", filename);
			$finish;
		end

		line_num = 0;
		while (!$feof(file)) begin
			line_num++;
			status = $fgets(line, file);
			if (status == 0) continue; // 跳過空行

			// 解析16進位的字串轉換成二進位值
			status = $sscanf(line, "%h %h", addr, data);
			if (status == 2) begin
				write(addr, WRITE, data);
			end else begin
				$display("WARNING: Failed to parse line %0d: \"%s\"", line_num, line);
			end
		end

		$fclose(file);
	endtask

	task automatic compare_files(input string file1, input string file2, output bit is_equal);
		int f1, f2;
		string line1, line2;
		is_equal = 1;

		// 開啟兩個檔案
		f1 = $fopen(file1, "r");
		f2 = $fopen(file2, "r");

		if (f1 == 0 || f2 == 0) begin
			$display("ERROR: Cannot open file(s).");
			is_equal = 0;
			return;
		end

		// 逐行讀取並比對
		while (!$feof(f1) || !$feof(f2)) begin
			$fgets(line1, f1);
			$fgets(line2, f2);


			if (line1 != line2) begin
			$display("Mismatch found:\n  File1: %s\n  File2: %s", line1, line2);
			is_equal = 0;
			break;
			end
		end

		// 確保兩個檔案都剛好結束
		if (!$feof(f1) || !$feof(f2)) begin
			$display("Files have different lengths.");
			is_equal = 0;
		end

		$fclose(f1);
		$fclose(f2);
	endtask

	logic d_update;
	always @(posedge clk) begin
		d_update <= update;
		if (d_update) begin
			$fwrite(conv_result_file, "%04h\n", conv_result);  // 4位寬十六進位，不足補0
		end
	end
	
	always begin
		#10 clk = ~clk;
	end

	initial begin
		clk = 0;
		cmd_ssn = 1;
		cmd_mosi = 0;
		cmd_sclk = 0;
		
		//RESET 
		reset = 1;
		#1000
		reset = 0;

		conv_result_file = $fopen("../tb/conv_result.txt", "w");
		if (!conv_result_file) begin
			$display("ERROR: Cannot open conv_result.txt for writing.");
			$finish;
		end
		
		load_and_write_from_file("../tb/test.txt");
		// conv
		write(8'h81, WRITE, 16'h0000);
		
		#100000
		$fclose(conv_result_file);
		compare_files("../tb/conv_result.txt", "../tb/answer.txt", result);
		if (result)
			$display("Files are identical.");
		else
			$display("Files differ.");
		$stop;
		
	end


endmodule