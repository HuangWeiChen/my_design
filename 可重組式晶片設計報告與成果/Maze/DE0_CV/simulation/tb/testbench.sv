// 修改vsim => vsim -c -sv_seed random work.testbench -do "run -all;"
`timescale 1ns/10ps

module testbench;

// Batch toggle: 1 for input_total.txt, 0 for individual files
parameter BATCH_MODE = 1; 
// Max mazes to process
parameter MAX_MAZES = 5000; 
// Random start range
parameter RAND_START_MIN = 10000;
parameter RAND_START_MAX = 15000;
// Timeout cycles
parameter TIMEOUT_CYCLES = 2000;
// Interval for printing transmission progress
parameter PRINT_INTERVAL = 10;

logic clk, rst_n;
logic [1:0] landform;
logic valid;
logic ready;
logic [2:0] action;
logic finish;

logic [1:0] map [0:288];
integer map_index, file_index;
logic start_sending;
integer clk_count, total_clk;
integer action_fd;

// -------------------------------------------------------------------------
// Tracking Variables
// -------------------------------------------------------------------------
integer curr_x, curr_y;
integer next_x_w, next_y_w; 
integer total_hostages;
integer collected_hostages;
logic [1:0] target_cell_type_w;
integer move_error_count;

// Flags and State
logic trap_triggered;
logic is_oob_w;
logic is_wall_hit_w;
logic is_trap_hit_w;
logic is_hostage_hit_w;

logic visited_hostage [0:16][0:16];
logic map_reset;
integer current_file_line;
integer current_start_line;
logic eof;

// Statistics
real avg_clk; 
integer success_count;
integer fail_count;
integer tested_mazes;
integer start_idx;

string input_files [3] = '{"../tb/input_file/input1.txt", "../tb/input_file/input2.txt", "../tb/input_file/input3.txt"};

escape dut(
    .clk(clk),
    .rst_n(rst_n),
    .landform(landform),
    .valid(valid),
    .ready(ready),
    .action(action),
    .finish(finish)
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk = ~clk;

function integer get_rand_start(input integer min_val, input integer max_val);
    return min_val;
    //return $urandom_range(max_val, min_val);
endfunction

// 命令列加速 (-c)
// initial begin
//     $dumpfile("testbench.vcd");
//     $dumpvars(0, testbench);
// end

initial begin
    clk = 0;
    rst_n = 1;
    valid = 0;
    landform = 0;
    map_index = 0;
    file_index = 0;
    start_sending = 0;
    map_reset = 0;
    current_file_line = 1;
    success_count = 0;
    fail_count = 0;
    tested_mazes = 0;

    #(CLK_PERIOD*3);
    rst_n = 0;
    #(CLK_PERIOD*3);
    rst_n = 1;

    if (BATCH_MODE) begin
        integer fd;
        fd = $fopen("../tb/input_file/input_total.txt", "r");
        if (fd == 0) begin
            $display("Error: Cannot open input_total.txt");
            $stop; 
        end
        
        current_file_line = 1;
        start_idx = get_rand_start(RAND_START_MIN, RAND_START_MAX);
        $display("Random Start Index generated: %0d", start_idx);
        $display("Skipping first %0d mazes...", start_idx);
        
        for (int i = 0; i < start_idx; i++) begin
            load_maze(fd, eof, current_start_line);
            if (eof) break;
            file_index++;
        end
        
        $display("Starting tests from Maze %0d...", file_index + 1);
        while (tested_mazes < MAX_MAZES) begin
            load_maze(fd, eof, current_start_line);
            if (eof) break;
            
            if (tested_mazes % PRINT_INTERVAL == 0) begin
                $display("Transmitting Maze %0d (Test %0d/%0d)...", file_index + 1, tested_mazes + 1, MAX_MAZES);
            end
            
            execute_maze();
            file_index++;
            tested_mazes++;
        end
        $fclose(fd);
    end else begin
        for (file_index = 0; file_index < 3 && tested_mazes < MAX_MAZES; file_index++) begin
            integer fd;
            fd = $fopen(input_files[file_index], "r");
            if (fd == 0) begin
                $display("Error: Cannot open %s", input_files[file_index]);
                $stop;
            end
            current_file_line = 1;
            load_maze(fd, eof, current_start_line);
            
            if (tested_mazes % PRINT_INTERVAL == 0) begin
                $display("Transmitting Maze %0d...", file_index + 1);
            end
            
            execute_maze();
            tested_mazes++;
            $fclose(fd);
        end
    end

    if (tested_mazes > 0) begin
        avg_clk = real'(total_clk) / real'(tested_mazes);
        $display("========================================");
        $display("All %0d maps tested.", tested_mazes);
        $display("Total SUCCESS : %0d / %0d", success_count, tested_mazes);
        $display("Total FAILURE : %0d", fail_count);
        $display("Total cycles  : %0d", total_clk);
        $display("Average cycles: %0.2f", avg_clk);
        $display("========================================");
    end
    $stop;
end

// Task: Execute and verify 1 maze
task execute_maze();
    string out_name;
    
    map_reset = 1;
    @(posedge clk);
    map_reset = 0;

    map_index = 0;
    start_sending = 1;

    out_name = $sformatf("../tb/log/action%0d.txt", file_index + 1);
    action_fd = $fopen(out_name, "w");
    if (action_fd == 0) begin
        $display("Error: Cannot open log file.");
        $stop;
    end

    $fdisplay(action_fd, "%0d", current_start_line);

    fork
        begin wait (finish == 1); end
        begin
            repeat(TIMEOUT_CYCLES) @(posedge clk);
            $display("\n========================================");
            $display("[TIMEOUT ERROR] Maze %0d Stalled!", file_index + 1);
            $display("========================================\n");
        end
    join_any
    disable fork; 
    
    if (finish == 1) begin
        if (curr_x == 16 && curr_y == 16 && collected_hostages == total_hostages && move_error_count == 0) begin
            success_count++;
        end else begin
            $display("Maze %0d FAILURE (Errors: %0d)", file_index+1, move_error_count);
            fail_count++;
        end
    end else begin
        fail_count++;
    end
    
    $fclose(action_fd);
    start_sending = 0;
    repeat(10) @(posedge clk); 
endtask

task automatic load_maze(input integer fd, output logic out_eof, output integer out_start_line);
    integer char_c;
    integer items_read;
    
    items_read = 0; 
    out_eof = 0;
    total_hostages = 0;

    while (items_read < 289) begin
        char_c = $fgetc(fd);
        if (char_c == -1) begin 
            if (items_read == 0) out_eof = 1;
            break;
        end
        if (char_c == 10) begin 
            current_file_line++;
        end else if (char_c == "0" || char_c == "1" || char_c == "2" || char_c == "3") begin
            if (items_read == 0) out_start_line = current_file_line;
            map[items_read] = char_c - "0";
            if (map[items_read] == 2'b11) total_hostages++;
            items_read++;
        end
    end
endtask

always @(negedge clk) begin
    if (start_sending && map_index < 289) begin
        landform <= map[map_index];
        valid <= 1;
        if (ready) map_index <= map_index + 1;
    end else begin
        valid <= 0;
    end
end

// =========================================================================
// Block 1: Combinational Logic 
// =========================================================================
always_comb begin
    next_x_w = curr_x;
    next_y_w = curr_y;
    
    if (action == 3'd0) next_x_w = curr_x + 1;
    if (action == 3'd1) next_y_w = curr_y + 1;
    if (action == 3'd2) next_x_w = curr_x - 1;
    if (action == 3'd3) next_y_w = curr_y - 1;

    if (next_x_w < 0 || next_x_w > 16 || next_y_w < 0 || next_y_w > 16) begin
        is_oob_w = 1'b1;
        target_cell_type_w = 2'b00;
    end else begin
        is_oob_w = 1'b0;
        target_cell_type_w = map[next_y_w * 17 + next_x_w];
    end

    is_wall_hit_w    = (target_cell_type_w == 2'b00 && action != 3'd4 && !is_oob_w);
    is_trap_hit_w    = (target_cell_type_w == 2'b10 && action != 3'd4 && !is_oob_w);
    is_hostage_hit_w = (target_cell_type_w == 2'b11 && action != 3'd4 && !is_oob_w);
end

// =========================================================================
// Block 2: Sequential Logic 
// =========================================================================
always_ff @(posedge clk) begin
    if (~rst_n) begin
        total_clk <= 0;
        clk_count <= 0;
        curr_x <= 0;
        curr_y <= 0;
        collected_hostages <= 0;
        move_error_count <= 0;
        trap_triggered <= 0;
        for(int i=0; i<17; i++) begin
            for(int j=0; j<17; j++) begin
                visited_hostage[i][j] <= 0;
            end
        end
    end else if (map_reset) begin
        clk_count <= 0;   // 單局計時歸零
        curr_x <= 0;
        curr_y <= 0;
        collected_hostages <= 0;
        move_error_count <= 0;
        trap_triggered <= 0;
        for(int i=0; i<17; i++) begin
            for(int j=0; j<17; j++) begin
                visited_hostage[i][j] <= 0;
            end
        end
    end else if (start_sending && !finish) begin
        clk_count <= clk_count + 1;
        total_clk <= total_clk + 1;

        if (map_index >= 289) begin
            $fdisplay(action_fd, "%0d", action);
            
            // Strict Trap Check
            if (trap_triggered) begin
                if (action != 3'd4) begin
                    $display("Error: Failed to STALL on trap at (%0d, %0d) cycle %0d", curr_x, curr_y, clk_count);
                    move_error_count <= move_error_count + 1;
                end
                trap_triggered <= 0; 
            end

            if (is_oob_w) begin
                $display("Error: OOB at (%0d, %0d)", next_x_w, next_y_w);
                move_error_count <= move_error_count + 1;
            end else if (is_wall_hit_w) begin
                $display("Error: Wall hit at (%0d, %0d) cycle %0d", next_x_w, next_y_w, clk_count);
                move_error_count <= move_error_count + 1;
            end else begin
                curr_x <= next_x_w;
                curr_y <= next_y_w;

                if (is_trap_hit_w) begin
                    trap_triggered <= 1;
                end

                if (is_hostage_hit_w && visited_hostage[next_y_w][next_x_w] == 0) begin
                    visited_hostage[next_y_w][next_x_w] <= 1; 
                    collected_hostages <= collected_hostages + 1; 
                end
            end
        end
    end
end

endmodule