`timescale 1ns/100ps

// 請將 DTW_test_data.txt 和 DTW_test_data_ans.txt 放置於同一資料夾中

module testbench;


	//=======================================================
    //  declarations
    //=======================================================
	
	parameter  			DIGITS = 8;	// 傳輸位元數
	parameter 			SPI_T = 100;	// 控制ssn的傳輸速度
	parameter 			DATA_N = 64 * (28);		// 測試資料的筆數

	// 系統
	logic 		 		clk;			// 系統clk(100MHz)
	logic				reset;			// 系統reset
	
	// SPI
	logic				cmd_ssn;		
	logic				cmd_sclk;		// 10MHz
	
	// TDI
	logic				update;
	logic 				calculating_n;
	logic 				start;
	logic [7:0] 		mosi;	// TDI 模組之pixel輸入
	logic [7:0] 		pixel_output;		// TDI 模組之輸出
	logic 				fin;
	
	// Verification
	logic [7:0]			answer;
	logic [DATA_N-1:0]	test_result;
	integer				test_data_cnt;
	logic [31:0] 		cnt_send;
	logic [11:0]		cnt_line;
	integer x;
  	integer file_res;
	bit result;
	

    //=======================================================
    //  Structural coding
    //=======================================================
	TDI dut(
		.rst			(reset			),
		.clk				(clk			),
		.sclk				(cmd_sclk		),
		.ssn				(cmd_ssn		),
		.mosi				(mosi			),
		.start				(start			),
		.update				(update			),
		.pixel_output	(pixel_output)
	);
	
	// 將資料組以SPI格式寫入DTW
	task automatic write(
		input logic [7:0] shift_register_row [0 : DIGITS-1]
	);
		integer i, j;
	
		// 啟動 SPI 傳輸
		cmd_ssn = 1;
		
		#200;
		cmd_ssn = 0;
	
		// 依序傳輸
		for (i = 0; i < DIGITS; i = i + 1) begin
			mosi = shift_register_row[0];


			// 使用 'for' 迴圈進行移位
			for (j = 0; j < DIGITS - 1; j = j + 1) begin
				shift_register_row[j] = shift_register_row[j + 1];
			end
			cnt_send = cnt_send + 1;
			shift_register_row[DIGITS - 1] = 0;
	
			#SPI_T cmd_sclk = 1;
			#SPI_T cmd_sclk = 0;
		end
		cnt_line = cnt_line + 1;
		#200;
		
		// 傳輸結束，復位
		mosi = 0;
		cmd_sclk = 0;
		#200;
		cmd_ssn = 1;
		#1000;
	endtask
	
	// 讀取檔案
    task automatic file_read();
		logic [7:0] data_pixel [0:DIGITS-1]; // 一組資料A
		integer file, file_ans, i, temp, line_count = 0;
		string hex_string;
		test_data_cnt = 1;
		
		// 開檔
        file = $fopen("../tb/TDI_test_data.txt", "r");
        if (file == 0) begin
            $display("Error: Unable to open TDI_test_data.txt!\n");
            $stop;
        end
		$display("Correct: TDI_test_data.txt opened successfully!\n");
		
		while (!$feof(file)) begin
			void'($fgets(hex_string, file)); // 讀取一行 data_pixel
			for (i = 0; i < DIGITS; i++) begin
				void'($sscanf(hex_string.substr(i*2, i*2+1), "%2h", temp));
				data_pixel[i] = temp[7:0];
			end
			line_count++;			
			
			$write("Line : %03d    ", line_count);
			for (i = 0; i < DIGITS; i++) begin
				$write("%02h ", data_pixel[i]);
			end
			$display("");
			write(data_pixel);	
			test_data_cnt = test_data_cnt + 1;
		end

        $fclose(file);
		start = 1;
		#SPI_T start = 0;
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
			void'($fgets(line1, f1));
			void'($fgets(line2, f2));


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

	
	always_ff @(posedge clk) begin
		if (reset) begin
			x <= 0;
		end
		else if (update) begin
			// 將資料寫入檔案（注意 %02h 表示兩位數十六進位）
			$fwrite(file_res, "%02h", pixel_output);
			x <= x + 1;
			if (x == 7) begin
				$fwrite(file_res, "\n");
				x <= 0;
			end
		end
	end
	/*
	always_ff @( posedge fin ) begin
		$fclose(file_res);
		compare_files("../tb/TDI_result.txt", "../tb/answer.txt", result);
		if (result)
			$display("Files are identical.");
		else
			$display("Files differ.");
	end
	*/
	
	always begin
		#10 clk = ~clk;
	end
	
	initial begin
		start = 0;
		cnt_send = 0;
		cnt_line = 0;
		clk = 0;
		cmd_ssn = 1;
		mosi = 0;
		cmd_sclk = 0;

		file_res = $fopen("../tb/TDI_result.txt", "w");
		if (file_res == 0) begin
			$display("Error: Unable to open TDI_result.txt!");
			$stop;
		end 
		else begin
			$display("Correct: TDI_result.txt opened successfully!");
		end

		// RESET 
		reset = 1;
		#1000
		reset = 0;

		// 傳輸
		file_read();
		
		#100000
		$fclose(file_res);
		compare_files("../tb/TDI_result.txt", "../tb/answer.txt", result);
		if (result)
			$display("Files are identical.");
		else
			$display("Files differ.");
		$stop;
	end

endmodule