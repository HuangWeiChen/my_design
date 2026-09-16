# 計算機系統設計：RISC-V

這個專題以 SystemVerilog 建立 RISC-V 處理器相關模組，並用矩陣乘法程式檢查資料運算與記憶體存取。報告將組合語言、硬體架構與 ModelSim 波形放在同一個案例中說明。

## 設計內容

- `DE0_CV/design/` 收錄處理器頂層、ALU、暫存器檔案、程式 ROM、RAM、載入儲存單元及乘除法等模組。
- `DE0_CV/simulation/` 收錄模擬與測試相關檔案；`DE0_CV/` 亦包含 Quartus 專案設定與編譯結果。
- [RISC-V 報告](RISC-V_report.pdf)說明矩陣乘法的題目要求、硬體連接、程式與波形。案例將兩個 3×3 的有號 8 位元矩陣相乘，把有號 16 位元結果寫入記憶體，並依序載入 `x31` 供波形檢查。

## 閱讀順序

1. 從報告的矩陣資料配置與架構圖了解預期運算。
2. 查看 [`risc_v.sv`](DE0_CV/design/risc_v.sv) 及各運算、記憶體模組的連接。
3. 對照 [`Program_Rom.sv`](DE0_CV/design/Program_Rom.sv) 與 `simulation` 中的測試檔，觀察結果寫入與暫存器變化。

專案保留原始的 Quartus 與 ModelSim 工程檔；重現模擬時需依本機工具安裝位置檢查工程路徑與設定。
