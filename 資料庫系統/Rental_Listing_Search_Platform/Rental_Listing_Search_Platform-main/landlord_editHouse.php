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

// ==========================================
// ★ 接收 ID
// ==========================================
$id = $_SESSION['house_id'] ?? null;

if (!$id) { 
    echo "<script>alert('請先選擇要修改的房源'); window.location.href='landlord_edit.php';</script>";
    exit;
}

// ==========================================
// 區塊 A：處理動作
// ==========================================
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    
    // --- 情況 1：按下「確認修改」 ---
    if (isset($_POST['update'])) { 
        
        // (後端雙重檢查，以防萬一 JS 被關閉)
        $check_elec = $_POST['electricity'] ?? '';
        $check_water = $_POST['water'] ?? '';
        
        if ((substr($check_elec, 0, 1) === '-') || (substr($check_water, 0, 1) === '-')) {
            echo "<script>alert('錯誤：水費與電費不能以負號(-)開頭。'); window.history.back();</script>";
            exit;
        }

        try {
            $db->beginTransaction();

            // 1. 更新 house 表
            $sql_house = "UPDATE house SET 
                           house_name=?, rent_price=?, address=?, room_type=? 
                           WHERE id=?";
            $stmt_house = $db->prepare($sql_house);
            $stmt_house->execute([
                $_POST['house_name'],
                $_POST['rent_price'], 
                $_POST['address'], 
                $_POST['room_type'], 
                $id
            ]);

            // 2. 更新 house_description 表
            $sql_desc = "UPDATE house_description SET 
                           pet=?, parking=?, internet=?, electricity=?, water=?, 
                           number_of_bathrooms=?, furnished=?, public_transport=? 
                           WHERE id=?";
            $stmt_desc = $db->prepare($sql_desc);
            $stmt_desc->execute([
                $_POST['pet'], 
                $_POST['parking'],
                $_POST['internet'], 
                $_POST['electricity'], 
                $_POST['water'], 
                $_POST['number_of_bathrooms'], 
                $_POST['furnished'], 
                $_POST['public_transport'], 
                $id
            ]);

            $db->commit();
            echo "<script>alert('修改成功！資料已同步更新。'); window.location.href='landlord_edit.php';</script>";
            exit;

        } catch (Exception $e) {
            $db->rollBack();
            die("更新失敗: " . $e->getMessage());
        }
    }

    // --- 情況 2：按下「刪除」 ---
    elseif (isset($_POST['delete'])) {
        try {
            $db->beginTransaction();
            $stmt1 = $db->prepare("DELETE FROM house_description WHERE id = ?");
            $stmt1->execute([$id]);
            $stmt2 = $db->prepare("DELETE FROM house WHERE id = ?");
            $stmt2->execute([$id]);
            $db->commit();
            
            echo "<script>alert('已刪除'); window.location.href='landlord_edit.php';</script>";
            exit;
        } catch (Exception $e) {
            $db->rollBack();
            die("刪除失敗");
        }
    }
}

// ==========================================
// 區塊 B：抓取目前資料
// ==========================================
$sql_select = "SELECT * FROM house 
               LEFT JOIN house_description ON house.id = house_description.id 
               WHERE house.id = ?";

$stmt = $db->prepare($sql_select);
$stmt->execute([$id]);
$house = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$house) { 
    die("找不到此房源資料 (ID: $id)"); 
}
?>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>修改房源 | where is my love</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@300;400;500&family=Noto+Serif+TC:wght@400;600&display=swap" rel="stylesheet">
    <style>
        /* === 文青風格 CSS === */
        :root {
            --bg-color: #FDFCF8;
            --text-main: #464646;
            --input-bg: #EFECE4;
            --border-color: #ECEBE6;
            --btn-confirm: #C17F59;
            --btn-delete: #D9534F;
        }

        body { 
            font-family: 'Noto Sans TC', sans-serif; 
            background-color: var(--bg-color); 
            color: var(--text-main); 
            padding: 40px 10%;
            line-height: 1.6;
        }

        /* --- Header --- */
        .header { 
            border-bottom: 2px solid var(--border-color); 
            padding-bottom: 20px; 
            margin-bottom: 40px;
            font-family: 'Noto Serif TC', serif; 
            font-weight: 600; 
            display: flex;
            align-items: baseline; 
            gap: 30px; 
        }
        
        .header .site-title {
            font-size: 1.6rem; 
            letter-spacing: 0.2em;
            text-decoration: none; 
            color: var(--text-main); 
        }

        .header .nav-link {
            text-decoration: none; 
            color: var(--text-main); 
            font-size: 1.1rem;
            position: relative;
            opacity: 0.8;
        }
        
        .header a:hover { color: var(--btn-confirm); opacity: 1; }

        /* Form Hint */
        .form-hint {
            color: var(--btn-confirm);
            border: 2px dashed var(--btn-confirm);
            background-color: #FFF;
            padding: 10px 20px;
            display: inline-block;
            margin-bottom: 40px;
            font-family: 'Noto Serif TC';
            font-weight: 600;
            letter-spacing: 1.5px;
            border-radius: 8px;
        }

        /* Grid System */
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 25px 50px;
            max-width: 1000px;
            margin: 0 auto;     
        }

        /* Input Styles */
        .input-group {
            display: flex;
            align-items: center;
            background: var(--input-bg);
            padding: 12px 20px;
            border-radius: 6px;
            transition: 0.3s;
        }
        .input-group:focus-within {
            box-shadow: 0 0 0 2px #D6C6B0;
        }

        .input-group label {
            width: 140px; 
            color: #7A7A7A;
            font-family: 'Noto Serif TC';
            font-size: 1.05rem;
            font-weight: 600;
            flex-shrink: 0;
        }

        .input-group input, 
        .input-group select {
            border: none;
            background: transparent;
            font-size: 1.1rem;
            color: var(--text-main);
            width: 100%;
            outline: none;
            font-family: 'Noto Sans TC';
            -webkit-appearance: none;
            -moz-appearance: none;
            appearance: none;
            cursor: pointer;
        }

        .input-group.disabled {
            opacity: 0.6;
            background: #E0E0E0;
        }

        /* Buttons */
        .btn-area {
            margin-top: 60px;
            max-width: 1000px;
            display: flex;
            justify-content: flex-end;
            align-items: center;
            gap: 15px;
            padding-top: 20px;
            border-top: 1px solid var(--border-color);
        }

        .btn {
            padding: 10px 30px;
            font-size: 1rem;
            cursor: pointer;
            font-family: 'Noto Serif TC';
            border: 2px solid transparent;
            transition: 0.3s;
            border-radius: 4px;
            text-decoration: none;
            display: inline-block;
            text-align: center;
        }

        .btn-delete {
            background-color: transparent;
            border-color: var(--btn-delete);
            color: var(--btn-delete);
            margin-right: auto;
        }
        .btn-delete:hover { 
            background-color: var(--btn-delete); 
            color: white; 
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
            border-color: #B0B0B0;
            color: #888;
        }
        .btn-cancel:hover { 
            background-color: #EBEBEB; 
            color: #555;
        }

        @media (max-width: 768px) {
            .form-grid { grid-template-columns: 1fr; }
            .btn-area { flex-direction: column-reverse; gap: 20px; }
            .btn-delete { margin-right: 0; width: 100%; }
            .btn { width: 100%; }
            .header {
                flex-direction: column; 
                align-items: center;
                gap: 15px;
            }
            .header .site-title {
                font-size: 1.8rem;
            }
        }
    </style>

    <script>
        function checkBills() {
            // 取得電費和水費的輸入值
            var electricity = document.getElementsByName('electricity')[0].value;
            var water = document.getElementsByName('water')[0].value;

            // 檢查開頭是否為 "-"
            if (electricity.startsWith('-')) {
                alert('電費開頭不能是負數！');
                return false; // 阻止表單送出
            }
            
            if (water.startsWith('-')) {
                alert('水費開頭不能是負數！');
                return false; // 阻止表單送出
            }

            // 通過檢查，允許送出
            return true;
        }
    </script>
</head>
<body>

    <div class="header">
        <a href="index.php" class="site-title">where is my love</a>
        <a href="landlord_edit.php" class="nav-link">上一頁</a>
    </div>

    <form method="POST">
        <div style="text-align: center;">
            <div class="form-hint">請點選要修改的內容進行編輯</div>
        </div>

        <div class="form-grid">
            <div class="input-group disabled">
                <label>ID</label>
                <input type="text" value="<?= htmlspecialchars($house['id']) ?>" disabled>
            </div>
            
            <div class="input-group">
                <label>房屋名稱</label>
                <input type="text" name="house_name" placeholder="" value="<?= htmlspecialchars($house['house_name']) ?>">
            </div>

            <div class="input-group">
                <label>網路</label>
                <select name="internet" required>
                    <option value="1" <?= ($house['internet'] == '1') ? 'selected' : '' ?>>有</option>
                    <option value="0" <?= ($house['internet'] == '0') ? 'selected' : '' ?>>無</option>
                </select>
            </div>

            <div class="input-group">
                <label>租金</label>
                <input type="number" name="rent_price" min="0" 
                    value="<?= htmlspecialchars($house['rent_price'] ?? '') ?>">
            </div>

            <div class="input-group">
                <label>電費</label>
                <input type="text" name="electricity" 
                       value="<?= htmlspecialchars($house['electricity'] ?? '') ?>">
            </div>

            <div class="input-group">
                <label>地址</label>
                <input type="text" name="address" value="<?= htmlspecialchars($house['address']) ?>">
            </div>

            <div class="input-group">
                <label>水費</label>
                <input type="text" name="water" 
                       value="<?= htmlspecialchars($house['water'] ?? '') ?>">
            </div>

            <div class="input-group">
                <label>房型</label>
                <select name="room_type" required>
                    <option value="雅房" <?= ($house['room_type'] == '雅房') ? 'selected' : '' ?>>雅房</option>
                    <option value="分租套房" <?= ($house['room_type'] == '分租套房') ? 'selected' : '' ?>>分租套房</option>
                    <option value="獨立套房" <?= ($house['room_type'] == '獨立套房') ? 'selected' : '' ?>>獨立套房</option>
                    <option value="整層住家" <?= ($house['room_type'] == '整層住家') ? 'selected' : '' ?>>整層住家</option>
                    <option value="透天厝" <?= ($house['room_type'] == '透天厝') ? 'selected' : '' ?>>透天厝</option>
                </select>
            </div>

            <div class="input-group">
                <label>衛浴數</label>
                <input type="number" name="number_of_bathrooms" min="0" 
                    value="<?= htmlspecialchars($house['number_of_bathrooms'] ?? '') ?>">
            </div>


            <div class="input-group">
                <label>寵物</label>
                <select name="pet" required>
                    <option value="1" <?= ($house['pet'] == '1') ? 'selected' : '' ?>>允許</option>
                    <option value="0" <?= ($house['pet'] == '0') ? 'selected' : '' ?>>不允許</option>
                </select>
            </div>

            <div class="input-group">
                <label>傢俱</label>
                <select name="furnished" required>
                    <option value="1" <?= ($house['furnished'] == '1') ? 'selected' : '' ?>>有</option>
                    <option value="0" <?= ($house['furnished'] == '0') ? 'selected' : '' ?>>無</option>
                </select>
            </div>

            <div class="input-group">
                <label>車位</label>
                <input type="number" name="parking" min="0" 
                    value="<?= htmlspecialchars($house['parking'] ?? '') ?>">
            </div>

            <div class="input-group">
                <label>大眾運輸</label>
                <select name="public_transport" required>
                    <option value="1" <?= ($house['public_transport'] == '1') ? 'selected' : '' ?>>有</option>
                    <option value="0" <?= ($house['public_transport'] == '0') ? 'selected' : '' ?>>無</option>
                </select>
            </div>

            
        </div>

        <div class="btn-area">
            <button type="submit" name="delete" class="btn btn-delete" onclick="return confirm('警告：確定要刪除這筆房源資料嗎？此動作無法復原。');">
                刪除此房全部資料
            </button>
            
            <button type="submit" name="update" class="btn btn-confirm" onclick="return checkBills();">確認修改</button>
            
            <a href="landlord_edit.php" class="btn btn-cancel">取消</a>
        </div>
    </form>

</body>
</html>