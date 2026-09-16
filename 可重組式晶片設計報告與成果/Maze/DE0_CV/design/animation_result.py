import matplotlib.pyplot as plt
import matplotlib.animation as animation
import copy
import numpy as np
import os
current_dir = os.path.dirname(os.path.abspath(__file__))
input_dir = os.path.join(current_dir, "../simulation/tb/input_file")

def read_matrix(filename):
    matrix = []
    with open(filename, 'r') as f:
        for line in f:
            matrix.append([int(x) for x in line.strip().split()])
    return matrix

def read_actions(filename):
    with open(filename, 'r') as f:
        # 讀取所有行，並透過切片 [1:] 忽略第一行
        lines = f.readlines()
        if len(lines) > 0:
            lines = lines[1:]
        return [int(line.strip()) for line in lines if line.strip().isdigit()]

def animate_maze_by_action_sequence(maze, actions):
    height, width = len(maze), len(maze[0])
    maze = copy.deepcopy(maze)
    frames = []
    px, py = 0, 0  # 初始位置
    paused = False

    for action in actions:
        frame = copy.deepcopy(maze)

        if maze[px][py] == 3:
            maze[px][py] = 4  # 踩過寶藏變腳印
        elif maze[px][py] != 2:  # 非陷阱才蓋腳印
            maze[px][py] = 4

        # 若當前是陷阱，暫停 1 次
        if maze[px][py] == 2 and not paused:
            paused = True
            frames.append(copy.deepcopy(maze))
            continue
        paused = False

        # 移動
        if action == 0 and py < width - 1:       # RIGHT
            py += 1
        elif action == 1 and px < height - 1:    # DOWN
            px += 1
        elif action == 2 and py > 0:             # LEFT
            py -= 1
        elif action == 3 and px > 0:             # UP
            px -= 1
        # 4 = STALL, stay in place

        maze[px][py] = 5  # 紅人位置
        frames.append(copy.deepcopy(maze))

    # 色碼：0=黑牆, 1=黃路, 2=綠陷阱, 3=紫寶藏, 4=淺藍腳印, 5=紅人
    cmap = plt.cm.colors.ListedColormap(['black', 'yellow', 'green', 'purple', 'lightblue', 'red'])

    def update(frame_idx):
        ax.clear()
        ax.imshow(frames[frame_idx], cmap=cmap, vmin=0, vmax=5)
        ax.set_title(f"Step {frame_idx}")
        ax.axis('off')

    fig, ax = plt.subplots()
    ani = animation.FuncAnimation(fig, update, frames=len(frames), interval=100, repeat=False)
    plt.show()

if __name__ == "__main__":
    maze = read_matrix(os.path.join(input_dir, "input1.txt"))
    actions = read_actions(os.path.join(current_dir, "../simulation/tb/log/action1.txt"))
    animate_maze_by_action_sequence(maze, actions)

    maze = read_matrix(os.path.join(input_dir, "input2.txt"))
    actions = read_actions(os.path.join(current_dir, "../simulation/tb/log/action2.txt"))
    animate_maze_by_action_sequence(maze, actions)

    maze = read_matrix(os.path.join(input_dir, "input3.txt"))
    actions = read_actions(os.path.join(current_dir, "../simulation/tb/log/action3.txt"))
    animate_maze_by_action_sequence(maze, actions)