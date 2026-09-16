#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

typedef struct Grid *gri;
struct Grid{
	char data[6][6];
	
};

int changeGrid(char a){
	switch(a){
		case 'a':
			return 0;break;
		case 'A':
			return 0;break;
		case 'b':
			return 1;break;
		case 'B':
			return 1;break;
		case 'c':
			return 2;break;
		case 'C':
			return 2;break;
		case 'd':
			return 3;break;
		case 'D':
			return 3;break;
		case 'e':
			return 4;break;
		case 'E':
			return 4;break;
		case 'f':
			return 5;break;
		case 'F':
			return 5;break;
		default: 
			return -1;break;
	}
}
char changex(int a){
	switch(a){
		case 0:
			return 'A';break;
		case 1:
			return 'B';break;
		case 2:
			return 'C';break;
		case 3:
			return 'D';break;
		case 4:
			return 'E';break;
		case 5:
			return 'F';break;
		default: 
			return -1;break;
	}
}
char changey(int a){
	switch(a){
		case 0:
			return 'a';break;
		case 1:
			return 'b';break;
		case 2:
			return 'c';break;
		case 3:
			return 'd';break;
		case 4:
			return 'e';break;
		case 5:
			return 'f';break;
		default: 
			return -1;break;
	}
}
int countFlipPieces(char (*data)[6][6], int player, char grid[3], int dir){
	int x,y,cnt;
	x = changeGrid(grid[0]);
	y = changeGrid(grid[1]);
	cnt = 0;
	char tmp = (player == 1) ? 'O' : 'X';
	int movx[8] = {-1,-1,0,1,1,1,0,-1};
	int movy[8] = {0,1,1,1,0,-1,-1,-1};

	x+=movx[dir]; y+=movy[dir];
	while(x<6&&y<6&&x>-1&&y>-1&&(*data)[x][y]==tmp){
		cnt++;x+=movx[dir]; y+=movy[dir];
	}
	if(x==6||y==6||x==-1||y==-1||(*data)[x][y]=='+'){
		cnt = 0;
	}
	return cnt;
}
int isValidMove(gri head, int player, char grid[3]){
	for(int i = 0; i<8; i++)
		if(countFlipPieces(&(head->data),player,grid,i)>0)
        	return 1;
	return 0;
}
int passTurn(gri head, int player){
	for(int i = 0; i<6; i++)
		for(int j = 0; j<6; j++)
			if(head->data[i][j]=='+'){
				char g[3];
				g[0] = changex(i);g[1] = changey(j);
				if(isValidMove(head,player,g))
				    return 0;
			}	    
	return 1;
}
int gameover(gri head){
	return passTurn(head,1)&&passTurn(head,2);
}
void flipPieces(gri newone, gri original, int player, char grid[3]){
    int movx[8] = {-1,-1,0,1,1,1,0,-1};
    int movy[8] = {0,1,1,1,0,-1,-1,-1};
    int x, y;

    // 複製原始棋盤
    for(int i = 0; i<6; i++)
        for(int j = 0; j<6; j++)
            newone->data[i][j] = original->data[i][j];

    char self = (player == 1) ? 'X' : 'O';
    char oppo = (player == 1) ? 'O' : 'X';

    x = changeGrid(grid[0]);
    y = changeGrid(grid[1]);

    for(int dir = 0; dir < 8; dir++) {
        int nx = x + movx[dir];
        int ny = y + movy[dir];
        int step = 0;

        while (nx >= 0 && nx < 6 && ny >= 0 && ny < 6 && newone->data[nx][ny] == oppo) {
            nx += movx[dir];
            ny += movy[dir];
            step++;
        }

        if (step > 0 && nx >= 0 && nx < 6 && ny >= 0 && ny < 6 && newone->data[nx][ny] == self) {
            // 確定可以翻轉
            nx = x + movx[dir];
            ny = y + movy[dir];
            for (int i = 0; i < step; i++) {
                newone->data[nx][ny] = self;
                nx += movx[dir];
                ny += movy[dir];
            }
        }
    }

    newone->data[x][y] = self;
}


int countColorPieces(gri head, int player){
	int ans = 0;
	char tmp = (player == 1) ? 'X' : 'O';
	for(int i = 0; i<6; i++)
		for(int j = 0; j<6; j++)
			if(tmp==head->data[i][j])
				ans++;
	return ans;
}

int heuristicScore(gri head, int player){
	if(player==1) return countColorPieces(head, 1)-countColorPieces(head, 2);
	else return countColorPieces(head, 2)-countColorPieces(head, 1);
}

int maxminsearch(gri head, int depth, int nowplayer, int player){
	if (depth == 0 || gameover(head)) {
        return heuristicScore(head,player);
    }
    if(passTurn(head,nowplayer)){
    	return  maxminsearch(head,depth-1,(nowplayer==1) ? 2 : 1,player);
	}
    int ans;
    int foundmove = 0;
    if(nowplayer==player){
    	ans = -1000;
    	for(int i = 0; i<6; i++)
			for(int j = 0; j<6; j++){
				if(head->data[i][j]!='+') continue;
                char move[3];
                move[0] = changex(i); move[1] = changey(j);
                if(!isValidMove(head, nowplayer, move)) continue;
                foundmove = 1;
                gri newg = (gri)malloc(sizeof(*newg));
                flipPieces(newg,head,nowplayer,move);

                int score = maxminsearch(newg,depth-1,(nowplayer==1) ? 2 : 1,player);
                free(newg);
			
                if(score>ans)
                    ans = score;
			}
	}else{
		ans = 1000;
    	for(int i = 0; i<6; i++)
			for(int j = 0; j<6; j++){
				if(head->data[i][j]!='+') continue;
                char move[3];
                move[0] = changex(i); move[1] = changey(j);
                if(!isValidMove(head, nowplayer, move)) continue;
                foundmove = 1;
                gri newg= (gri)malloc(sizeof(*newg));
                flipPieces(newg,head,nowplayer,move);

                int score = maxminsearch(newg,depth-1,(nowplayer==1) ? 2 : 1,player);
                free(newg);
				
                if(score<ans)
                    ans = score;
			}
	}
	if(!foundmove)
        return maxminsearch(head, depth, (nowplayer == 1) ? 2 : 1, player);
	return ans;
}

int main(){
	gri head;
	head = (gri)malloc(sizeof(*head));
	char forcin[37];
	int n,player,depth,bestscore;
	char g[3],best[3];
	scanf("%d",&n);
	
	for(int k = 0; k<n; k++){
		bestscore = -1000;
		scanf("%s",forcin);
		int cnt = 0;
		for(int i = 0; i<6; i++)
			for(int j = 0; j<6; j++)
				head->data[i][j] = forcin[cnt++];
				
		scanf("%d %d",&player,&depth);
		
		int oppo = (player==1) ? 2 : 1;
		
		for(int i = 0; i<6; i++)
            for(int j = 0; j < 6; j++){
            	
                if(head->data[i][j]!='+') continue;
                char move[3];
                move[0] = changex(i); move[1] = changey(j);
                if(!isValidMove(head, player, move)) continue;

                gri newg= (gri)malloc(sizeof(*newg));
                flipPieces(newg,head,player,move);

                int score = maxminsearch(newg,depth-1,oppo,player);
                
//                printf("== Move %c%c ==\n", move[0], move[1]);
//		        printf("Score: %d\n", score);
//		        printf("After flip:\n");
//		        for (int a = 0; a < 6; a++) {
//		            for (int b = 0; b < 6; b++) {
//		                printf("%c", newg->data[a][b]);
//		            }
//		        }    
		        free(newg);
//				printf("%c%c %d\n",move[0],move[1],score);
                if(score>bestscore){
                    bestscore = score;
                    best[0] = move[0];
                    best[1] = move[1];
                }
            }
		printf("%c%c\n",best[0],best[1]);
	}
	
}
