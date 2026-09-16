module escape(
    input  logic        clk,
    input  logic        rst_n,          // active-low reset
    input  logic [1:0]  landform,       // 00 wall, 01 path, 10 trap, 11 hostage
    input  logic        valid,          // 成功傳送就 valid
    output logic        ready,          // 讀取資料
    output logic [2:0]  action,         // 0:R,1:D,2:L,3:U,4:STALL
    output logic        finish          // high when (16,16) reached AND all hostages rescued
);

	//MAZE_move_kernel
	logic [3:0]  	map [16:0][16:0];
	logic [4:0]  	cnt_x;
	logic [4:0]  	cnt_y;
	logic [10:0] 	cnt_input;	//算輸入了幾個位置了
	logic [9:0]  	cnt_money;
	logic [9:0] 	cnt_get;
	logic 			rst_get;
	logic [4:0]		x;
	logic [4:0]		y;
	logic 			start;
	logic [1:0] 	face; //right = 0 down = 1 left = 2 up = 3
	logic [1:0]		last_map; //00 wall, 01 path, 10 trap, 11 hostage
	logic				rst_pos;
	logic [8:0]		cnt_fill;
	logic 			flag_fill;
	logic 			fill_fini;
	integer			i;
	integer			j;
	always_ff@(posedge clk)
	begin
		if(~rst_n) begin	
			cnt_x 		<= 0;
			cnt_y 		<= 0;
			cnt_input   <= 0;
			cnt_money	<= 0;
			x 				<= 0;
			y 				<= 0;
			face 			<= 0;
			last_map 	<= 0;
			action		<= 4;
			cnt_fill		<= 0;
			fill_fini	<= 1;
		end 
		else begin
			if(valid && cnt_input < 289 && ready) begin
				map[cnt_x][cnt_y] <= landform;
				if(landform == 3)
					cnt_money <= cnt_money +1;
				cnt_input <= cnt_input + 1;
				if(cnt_x == 16) begin
					cnt_x <= 0;
					if(cnt_y == 16)
						cnt_y <= 0;
					else
						cnt_y <= cnt_y+1;
				end
				else
					cnt_x <= cnt_x +1;
			end
			if(rst_pos) begin
				cnt_money <= 0;
				action 	 <= 4;
				cnt_input <= 0;
				x         <= 0;
            y         <= 0;
            face      <= 0;
            last_map  <= 0;
            cnt_x     <= 0; 
            cnt_y     <= 0;
				cnt_fill	 <= 0;
				fill_fini <= 1;
         end
			if(flag_fill) begin
				cnt_fill <= cnt_fill + 1;
            fill_fini<= 0;
            for (i=0; i<17; i=i+1) begin
					for (j=0; j<17; j=j+1) begin
						if ((map[i][j] == 1 || map[i][j] == 2) && !(i==0 && j==0) && !(i==16 && j==16)) begin
							if ( ((j == 0)  ? 1'b1 : (map[i][j>0 ? j-1 : 0] == 0)) +
								((j == 16) ? 1'b1 : (map[i][j<16 ? j+1 : 16] == 0)) +
								((i == 0)  ? 1'b1 : (map[i>0 ? i-1 : 0][j] == 0)) +
								((i == 16) ? 1'b1 : (map[i<16 ? i+1 : 16][j] == 0)) >= 3 ) begin
                           fill_fini <= 1;
									map[i][j] <= 0;
							end
						end
					end
				end
         end 
			if(start) begin 
				case(face)
				0:begin
					if(map[x][y-1]!=0&&y!=0) begin//up
						if(last_map == 2) begin
							action <= 4;
							last_map <= 0;
						end 
						else begin
							face 		<= 3;
							action 	<= 3;
							last_map <= map[x][y-1];
							y			<= y-1;
							if(map[x][y-1]==3) begin
								cnt_get 		<= cnt_get +1;
								map[x][y-1] <= 1;
							end
						end
					end
					else if(map[x+1][y]!=0&&x!=16) begin//right
						if(last_map == 2) begin
							action <= 4;
							last_map <= 0;
						end 
						else begin
							face	 	<= 0;
							action	<= 0;
							last_map <= map[x+1][y];
							x			<= x+1;
							if(map[x+1][y]==3)begin
								cnt_get 		<= cnt_get +1;
								map[x+1][y] <= 1;
							end
						end
					end 
					else if(map[x][y+1]!=0&&y!=16) begin//down
						if(last_map == 2) begin
							action <= 4;
							last_map <= 0;
						end 
						else begin
							face		<= 1;
							action 	<= 1;
							last_map <= map[x][y+1];
							y			<= y+1;
							if(map[x][y+1]==3)begin
								cnt_get 		<= cnt_get +1;
								map[x][y+1] <= 1;
							end
						end
					end
					else if(map[x-1][y]!=0&&x!=0) begin//left
						if(last_map == 2) begin
							action <= 4;
							last_map <= 0;
						end 
						else begin
							face		<= 2;
							action 	<= 2;
							last_map <= map[x-1][y];
							x			<= x-1;
							if(map[x-1][y]==3)begin
								cnt_get 		<= cnt_get +1;
								map[x-1][y] <= 1;
							end
						end
					end
				end
				1:begin
					if(map[x+1][y]!=0&&x!=16) begin//right
						if(last_map == 2) begin
							action <= 4;
							last_map <= 0;
						end 
						else begin
							face	 	<= 0;
							action	<= 0;
							last_map <= map[x+1][y];
							x			<= x+1;
							if(map[x+1][y]==3)begin
								cnt_get 		<= cnt_get +1;
								map[x+1][y] <= 1;
							end
						end
					end 
					else if(map[x][y+1]!=0&&y!=16) begin//down
						if(last_map == 2) begin
							action <= 4;
							last_map <= 0;
						end 
						else begin
							face		<= 1;
							action 	<= 1;
							last_map <= map[x][y+1];
							y			<= y+1;
							if(map[x][y+1]==3)begin
								cnt_get 		<= cnt_get +1;
								map[x][y+1] <= 1;
							end
						end
					end
					else if(map[x-1][y]!=0&&x!=0) begin//left
						if(last_map == 2) begin
							action <= 4;
							last_map <= 0;
						end 
						else begin
							face		<= 2;
							action 	<= 2;
							last_map <= map[x-1][y];
							x			<= x-1;
							if(map[x-1][y]==3)begin
								cnt_get 		<= cnt_get +1;
								map[x-1][y] <= 1;
							end
						end
					end 
					else if(map[x][y-1]!=0&&y!=0) begin//up
						if(last_map == 2) begin
							action <= 4;
							last_map <= 0;
						end 
						else begin
							face 		<= 3;
							action 	<= 3;
							last_map <= map[x][y-1];
							y			<= y-1;
							if(map[x][y-1]==3)begin
								cnt_get 		<= cnt_get +1;
								map[x][y-1] <= 1;
							end
						end
					end
				end
				2:begin
					if(map[x][y+1]!=0&&y!=16) begin//down
						if(last_map == 2) begin
							action <= 4;
							last_map <= 0;
						end 
						else begin
							face		<= 1;
							action 	<= 1;
							last_map <= map[x][y+1];
							y			<= y+1;
							if(map[x][y+1]==3)begin
								cnt_get 		<= cnt_get +1;
								map[x][y+1] <= 1;
							end
						end
					end
					else if(map[x-1][y]!=0&&x!=0) begin//left
						if(last_map == 2) begin
							action <= 4;
							last_map <= 0;
						end 
						else begin
							face		<= 2;
							action 	<= 2;
							last_map <= map[x-1][y];
							x			<= x-1;
							if(map[x-1][y]==3)begin
								cnt_get 		<= cnt_get +1;
								map[x-1][y] <= 1;
							end
						end
					end 
					else if(map[x][y-1]!=0&&y!=0) begin//up
						if(last_map == 2) begin
							action <= 4;
							last_map <= 0;
						end 
						else begin
							face 		<= 3;
							action 	<= 3;
							last_map <= map[x][y-1];
							y			<= y-1;
							if(map[x][y-1]==3)begin
								cnt_get 		<= cnt_get +1;
								map[x][y-1] <= 1;
							end
						end
					end
					else if(map[x+1][y]!=0&&x!=16) begin//right
						if(last_map == 2) begin
							action <= 4;
							last_map <= 0;
						end 
						else begin
							face	 	<= 0;
							action	<= 0;
							last_map <= map[x+1][y];
							x			<= x+1;
							if(map[x+1][y]==3)begin
								cnt_get 		<= cnt_get +1;
								map[x+1][y] <= 1;
							end
						end
					end 
				end
				3:begin
					if(map[x-1][y]!=0&&x!=0) begin//left
						if(last_map == 2) begin
							action <= 4;
							last_map <= 0;
						end 
						else begin
							face		<= 2;
							action 	<= 2;
							last_map <= map[x-1][y];
							x			<= x-1;
							if(map[x-1][y]==3)begin
								cnt_get 		<= cnt_get +1;
								map[x-1][y] <= 1;
							end
						end
					end 
					else if(map[x][y-1]!=0&&y!=0) begin//up
						if(last_map == 2) begin
							action <= 4;
							last_map <= 0;
						end 
						else begin
							face 		<= 3;
							action 	<= 3;
							last_map <= map[x][y-1];
							y			<= y-1;
							if(map[x][y-1]==3)begin
								cnt_get 		<= cnt_get +1;
								map[x][y-1] <= 1;
							end
						end
					end
					else if(map[x+1][y]!=0&&x!=16) begin//right
						if(last_map == 2) begin
							action <= 4;
							last_map <= 0;
						end 
						else begin
							face	 	<= 0;
							action	<= 0;
							last_map <= map[x+1][y];
							x			<= x+1;
							if(map[x+1][y]==3)begin
								cnt_get 		<= cnt_get +1;
								map[x+1][y] <= 1;
							end
						end
					end 
					else if(map[x][y+1]!=0&&y!=16) begin//down
						if(last_map == 2) begin
							action <= 4;
							last_map <= 0;
						end 
						else begin
							face		<= 1;
							action 	<= 1;
							last_map <= map[x][y+1];
							y			<= y+1;
							if(map[x][y+1]==3)begin
								cnt_get 		<= cnt_get +1;
								map[x][y+1] <= 1;
							end
						end
					end
				end
				endcase
			end
			if(~rst_n || rst_get) 
				cnt_get	<= 0;
		end	
	end
	
	//FSM
	typedef enum{ INIT, INPUT_DATA, MOVE, OVER, FILL} FSM_STATE;
	FSM_STATE fsm_ns,fsm_ps;
	
	always_ff@(posedge clk) begin
        if(~rst_n)
            fsm_ps      <= INIT;
        else
            fsm_ps      <= fsm_ns;
   end

	always_comb 
	begin
		fsm_ns	 = fsm_ps;
		ready		 = 0;
		start		 = 0;
		rst_get	 = 0;
		finish	 = 0;
		rst_pos	 = 0;
		flag_fill = 0;
		case(fsm_ps)
			INIT:
			begin
				if(valid)
					fsm_ns = INPUT_DATA;
				rst_pos	 = 1;
			end
			INPUT_DATA:
			begin
				ready 		= 1;
				if(cnt_input == 289)	begin
					rst_get	= 1;
					fsm_ns 	= FILL;
				end
			end
			FILL:
			begin
				flag_fill = 1;
				if(cnt_fill > 0&&fill_fini == 0) 
					fsm_ns = MOVE;
			end
			MOVE:
			begin
				start = 1;
				if(x==16&&y==16&&cnt_get>=cnt_money) 
					fsm_ns = OVER;
			end
			OVER:
			begin
				finish = 1;
				fsm_ns = INIT;
			end
			
		endcase
	end
endmodule
