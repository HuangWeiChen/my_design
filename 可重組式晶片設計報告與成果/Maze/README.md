tb與軟體除了`BATCH_MODE` 、 路徑,  其餘不得修改
tb中的`MAX_MAZES`為測試總數，可先自己調整測試，但最終結果(繳交在word上)須為5000

有任何問題請根據自身需求修改檔案中的路徑 (貼絕對路徑絕對不會錯)

請先編譯完 `BATCH_MODE = 0` , 確保 `DE0_CV\simulation\tb\log` 中有你的 `action1~3.txt`再透過軟體測試
軟體只會抓 `DE0_CV\simulation\tb\input_file` 中的 `input1.txt`, `input2.txt`, `input3.txt` 三張迷宮
可自行在 `input_total.txt` 中複製貼上想測試的input

請在 `DE0_CV\design` 這個路徑中執行軟體 `python animation_result.py`
