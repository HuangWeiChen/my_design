<?php
session_start();
// 1. 資料庫連線
$host = "mysql-databaseproject.alwaysdata.net";
$port = 3306;
$username = "442082_landlord"; 
$password = "@Landlord0000";    
$dbname = "databaseproject_comcom"; 

try {
    $db = new PDO("mysql:host=$host;port=$port;dbname=$dbname;charset=utf8", $username, $password);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("連線失敗: " . $e->getMessage());
}

// 取得目前的房東 ID (預設為 1，實際運作請確保 Session 有值)
$landlord_id = $_SESSION['landlord_id'] ?? 1;

// ==========================================
// 處理表單提交 (INSERT)
// ==========================================
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    
    if (isset($_POST['insert'])) {
        // [後端雙重驗證] 雖然有前端 JS，但後端也加一道防線比較安全
        $elec = $_POST['electricity'] ?? '';
        $water = $_POST['water'] ?? '';
        
        // 檢查字串開頭是否為 "-"
        if (strpos($elec, '-') === 0 || strpos($water, '-') === 0) {
             echo "<script>
                    alert('後端驗證失敗：水費或電費不能以負號開頭。');
                    window.history.back();
                   </script>";
             exit;
        }

        try {
            // 開啟交易
            $db->beginTransaction();

            // 1. 新增至 house 表 (主表)
            $sql_house = "INSERT INTO house (landlord_id, rent_price, address, room_type) 
                          VALUES (?, ?, ?, ?)";
            $stmt_house = $db->prepare($sql_house);
            $stmt_house->execute([
                $landlord_id,
                $_POST['rent_price'],
                $_POST['address'],
                $_POST['room_type'] // 這裡會接收到下拉選單選的值
            ]);

            // 取得剛剛新增的那筆 house 的 ID
            $new_house_id = $db->lastInsertId();

            // 2. 新增至 house_description 表 (附表)
            $sql_desc = "INSERT INTO house_description 
                         (id, pet, parking, internet, electricity, water, number_of_bathrooms, furnished, public_transport) 
                         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            $stmt_desc = $db->prepare($sql_desc);
            $stmt_desc->execute([
                $new_house_id,
                $_POST['pet'],
                $_POST['parking'],
                $_POST['internet'],
                $_POST['electricity'],
                $_POST['water'],
                $_POST['number_of_bathrooms'],
                $_POST['furnished'],
                $_POST['public_transport']
            ]);

            // 提交交易
            $db->commit();

            echo "<script>alert('新增成功！已建立新房源 (ID: $new_house_id)'); window.location.href='landlord_edit.php';</script>";
            exit;

        } catch (Exception $e) {
            // 1. 發生錯誤，先回滾交易 (復原資料庫狀態)
            $db->rollBack();

            // 2. 取得 Trigger 拋出的錯誤訊息
            // $e->getMessage() 會抓到我們在 SQL 寫的：'錯誤：租金金額不能為負數...'
            $error_msg = $e->getMessage();

            // 3. 【重要】處理訊息中的特殊符號
            // 使用 addslashes() 防止錯誤訊息裡如果有單引號 ' 會導致 JavaScript 語法錯誤
            $safe_msg = addslashes($error_msg);

            // 4. 輸出 JavaScript 給瀏覽器執行
            // window.alert: 跳出警告視窗
            // window.history.back(): 讓使用者回到上一頁 (保留原本輸入的資料，不用重填)
            echo "<script>
                    alert('新增失敗！\\n系統訊息：$safe_msg');
                    window.history.back();
                </script>";
            
            // 5. 停止 PHP 繼續執行
            exit;
        }
    }
}
?>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>新增房源 | where is my love</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@300;400;500&family=Noto+Serif+TC:wght@400;600&display=swap" rel="stylesheet">
    <style>
        /* === 文青風格 CSS (與修改頁面一致) === */
        :root {
            --bg-color: #FDFCF8;       /* 米白底色 */
            --text-main: #464646;      /* 深灰文字 */
            --input-bg: #EFECE4;       /* 輸入框底色 */
            --border-color: #ECEBE6;   /* 邊框色 */
            --btn-confirm: #C17F59;    /* 陶土色 (確認) */
            --btn-cancel: #B0B0B0;     /* 灰色 (取消) */
        }

        body { 
            font-family: 'Noto Sans TC', sans-serif; 
            background-color: var(--bg-color); 
            color: var(--text-main); 
            padding: 40px 10%;
            line-height: 1.6;
        }

        /* Header 導覽列 */
        .header { 
            border-bottom: 2px solid var(--border-color); 
            padding-bottom: 20px; 
            margin-bottom: 40px;
            font-family: 'Noto Serif TC', serif; 
            font-weight: 600; 
            font-size: 1.2rem;
            display: flex;
            align-items: center;
        }
        .header a { 
            text-decoration: none; 
            color: var(--text-main); 
            margin-right: 25px; 
            position: relative;
        }
        .header a:hover { color: var(--btn-confirm); }

        /* 標題樣式 */
        .page-title {
            text-align: center;
            margin-bottom: 40px;
        }
        .form-hint {
            color: var(--btn-confirm);
            border: 2px dashed var(--btn-confirm);
            background-color: #FFF;
            padding: 10px 30px;
            display: inline-block;
            font-family: 'Noto Serif TC';
            font-weight: 600;
            letter-spacing: 2px;
            border-radius: 8px;
            font-size: 1.1rem;
        }

        /* 雙欄位 Grid 排版 */
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr; /* 左右兩欄 */
            gap: 25px 50px; 
            max-width: 1000px;
            margin: 0 auto; 
        }

        /* 輸入框群組樣式 */
        .input-group {
            display: flex;
            align-items: center;
            background: var(--input-bg);
            padding: 12px 20px;
            border-radius: 6px;
            transition: 0.3s;
            border: 1px solid transparent;
        }
        .input-group:focus-within {
            box-shadow: 0 0 0 2px #D6C6B0;
            background: #FFF;
            border-color: #D6C6B0;
        }

        .input-group label {
            width: 140px; /* 標籤寬度 */
            color: #7A7A7A;
            font-family: 'Noto Serif TC';
            font-size: 1.05rem;
            font-weight: 600;
            flex-shrink: 0;
        }

        .input-group input, 
        .input-group select { /* ★ 新增 select 的樣式設定 */
            border: none;
            background: transparent;
            font-size: 1.1rem;
            color: var(--text-main);
            width: 100%;
            outline: none;
            font-family: 'Noto Sans TC';
            /* 移除 select 預設醜醜的外觀 */
            -webkit-appearance: none;
            -moz-appearance: none;
            appearance: none;
            cursor: pointer;
        }

        /* 修正 placeholder 顏色 */
        ::placeholder { color: #BBB; font-size: 0.95rem; }

        /* ID 欄位特殊樣式 (唯讀) */
        .input-group.disabled {
            opacity: 0.7;
            background: #E8E8E8;
            cursor: not-allowed;
        }

        /* 按鈕區塊 */
        .btn-area {
            margin-top: 60px;
            max-width: 1000px;
            margin-left: auto; margin-right: auto;
            display: flex;
            justify-content: flex-end; 
            gap: 20px;
            padding-top: 20px;
            border-top: 1px solid var(--border-color);
        }

        .btn {
            padding: 10px 40px;
            font-size: 1rem;
            cursor: pointer;
            font-family: 'Noto Serif TC';
            border: 2px solid transparent;
            transition: 0.3s;
            border-radius: 4px;
            text-decoration: none;
            font-weight: 600;
            letter-spacing: 1px;
        }

        .btn-confirm {
            background-color: var(--btn-confirm);
            color: white;
            border-color: var(--btn-confirm);
        }
        .btn-confirm:hover { 
            background-color: #A6633C; 
            transform: translateY(-2px); 
            box-shadow: 0 4px 10px rgba(193, 127, 89, 0.3);
        }

        .btn-cancel {
            background-color: transparent;
            border-color: var(--btn-cancel);
            color: var(--text-main);
        }
        .btn-cancel:hover { 
            background-color: #EBEBEB; 
        }
        .logo { font-size: 1.6rem; letter-spacing: 0.2em; }
        /* 響應式 */
        @media (max-width: 768px) {
            .form-grid {
                grid-template-columns: 1fr;
            }

            .btn-area {
                padding-left: 20px;
                padding-right: 20px;
            }

            .btn {
                width: 100%;
                text-align: center;
            }
        }

    </style>
</head>
<body>

    <div class="header logo">
        <a href="index.php">where is my love</a>
        <a href="landlord_edit.php">房源管理</a>
    </div>

    <form method="POST" id="houseForm">
        <div class="page-title">
            <div class="form-hint">新增房源資料</div>
        </div>

        <div class="form-grid">
            <div class="input-group disabled">
                <label>ID</label>
                <input type="text" value="系統自動生成" disabled style="font-style: italic;">
            </div>
            
            <div class="input-group">
                <label>房屋名稱 (name)</label>
                <input type="text" name="house_name" placeholder="例如：cse">
            </div>

            <div class="input-group">
                <label>租金 (Price)</label>
                <input type="number" name="rent_price" min="0" placeholder="例如：15000" required
                    value="<?= htmlspecialchars($house['rent_price'] ?? '') ?>">
            </div>

            <div class="input-group">
                <label>地址 (Address)</label>
                <input type="text" name="address" placeholder="請輸入完整地址" required>
            </div>

            <div class="input-group">
                <label>房型 (Type)</label>
                <select name="room_type" required>
                    <option value="" disabled selected>請選擇房型...</option>
                    <option value="雅房">雅房</option>
                    <option value="分租套房">分租套房</option>
                    <option value="獨立套房">獨立套房</option>
                    <option value="整層住家">整層住家</option>
                    <option value="透天厝">透天厝</option>
                </select>
            </div>

            <div class="input-group">
                <label>寵物 (Pet)</label>
                <select name="pet" required>
                    <option value="1">可</option>
                    <option value="0">不可</option>
                </select>
            </div>

            <div class="input-group">
                <label>車位 (Parking)</label>
                <input type="number" name="parking" min="0" 
                    value="<?= htmlspecialchars($house['parking'] ?? '') ?>">
            </div>

            <div class="input-group">
                <label>網路 (Internet)</label>
                <select name="internet" required>
                    <option value="1">有</option>
                    <option value="0">無</option>
                </select>
            </div>

            <div class="input-group">
                <label>電費 (Elec.)</label>
                <input type="text" name="electricity"  placeholder="例如：台電計費/一度5元">
            </div>

            <div class="input-group">
                <label>水費 (Water)</label>
                <input type="text" name="water" placeholder="例如：含水費">
            </div>

            <div class="input-group">
                <label>衛浴數 (Bath)</label>
                <input type="number" name="number_of_bathrooms" min="0" 
                    value="<?= htmlspecialchars($house['number_of_bathrooms'] ?? '') ?>">
            </div>

            <div class="input-group">
                <label>傢俱 (Furnish)</label>
                <select name="furnished" required>
                    <option value="1">有</option>
                    <option value="0">無</option>
                </select>
            </div>

            <div class="input-group">
                <label>交通 (Trans.)</label>
                <select name="public_transport" required>
                    <option value="1">有</option>
                    <option value="0">無</option>
                </select>
            </div>

        <div class="btn-area">
            <button type="submit" name="insert" class="btn btn-confirm">確認新增</button>
            <a href="landlord_edit.php" class="btn btn-cancel">取消</a>
        </div>
    </form>

    <script>
        // 監聽表單的提交事件
        document.getElementById('houseForm').addEventListener('submit', function(e) {
            
            // 取得電費和水費的輸入框
            const elecInput = document.querySelector('input[name="electricity"]');
            const waterInput = document.querySelector('input[name="water"]');
            
            // 取得輸入的值，並用 trim() 去除前後空白
            const elecValue = elecInput.value.trim();
            const waterValue = waterInput.value.trim();

            // 檢查條件：如果開頭是 "-" 符號
            // startsWith('-') 會檢查字串是否以減號開頭
            if (elecValue.startsWith('-')) {
                alert('電費欄位不能輸入負數');
                e.preventDefault(); // 阻止表單送出
                return; // 結束函式
            }

            if (waterValue.startsWith('-')) {
                alert('水費欄位不能輸入負數');
                e.preventDefault(); // 阻止表單送出
                return;
            }
        });
    </script>

</body>
</html>