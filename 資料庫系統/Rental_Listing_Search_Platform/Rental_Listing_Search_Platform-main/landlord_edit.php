<?php
ob_start(); // Turn on output buffering to prevent header errors
session_start();

// Database connection
$host = "mysql-databaseproject.alwaysdata.net";
$port = 3306;
$username = "442082_landlord"; 
$password = "@Landlord0000"; 
$dbname = "databaseproject_comcom"; 

try {
    $db = new PDO("mysql:host=$host;port=$port;dbname=$dbname;charset=utf8", $username, $password);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Connection failed: " . $e->getMessage());
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['batch_update'])) {
    $current_landlord_id = $_SESSION['landlord_id'] ?? 0;
    $percent = $_POST['percentage'];

    try {
        // 呼叫 MariaDB Procedure
        $sql = "CALL batch_update_rent(?, ?)";
        $stmt = $db->prepare($sql);
        $stmt->execute([$current_landlord_id, $percent]);

        echo "<script>
                alert('調整完成！所有房源租金已更新。');
                window.location.href = 'landlord_edit.php';
              </script>";
        exit();

    } catch (PDOException $e) {
        // 捕捉 Procedure 拋出的錯誤 (例如 -100%)
        $error_msg = addslashes($e->getMessage());
        echo "<script>
                alert('調整失敗！\\n系統訊息：$error_msg');
                window.history.back();
              </script>";
        exit();
    }
}

// ==========================================
// ★ Method 1 Core Logic: Store Session and Redirect
// ==========================================
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['edit_house'])) {
    // 1. Get the ID from the hidden field
    $id_to_edit = $_POST['id_to_edit'];
    
    // 2. Store it in the Session (Must match the name used in the edit page)
    $_SESSION['house_id'] = $id_to_edit;
    
    // 3. Redirect to the edit page
    header("Location: landlord_editHouse.php");
    exit();
}
// ==========================================

// === Search and Query Logic ===
$search_keyword = $_GET['search'] ?? '';

// Ensure login, default to 1 if not set (for testing)
$landlord_id = $_SESSION['landlord_id'] ?? 0; 

// ★ [修改] 1. 取得篩選狀態
$filter = $_GET['filter'] ?? '';

$sql = "SELECT * FROM house WHERE landlord_id = ?";
$params = [$landlord_id];

// ★ [修改] 2. 如果有點按鈕，加入 SQL Function 判斷
if ($filter === 'below_avg') {
    // 呼叫資料庫中的 Function: lower_avg_rent(?)
    $sql .= " AND rent_price < lower_avg_rent(?)";
    // Function 需要一個參數 (landlord_id)，所以這裡要再加入陣列
    $params[] = $landlord_id;
}

if ($search_keyword) {
    $sql .= " AND ( house_name LIKE ?)";
    $params[] = "%$search_keyword%"; // 對應 house_name
}
    
$stmt = $db->prepare($sql);
$stmt->execute($params);
$houses = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Random color function
function getRandomColor() {
    $colors = ['#D3D3D3', '#Cdcab9', '#8fa0a0', '#b5b5b5', '#9fb1bc', '#E8C5A8', '#A8BFA6'];
    return $colors[array_rand($colors)];
}
?>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>房源管理 | where is my love</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@300;400;500&family=Noto+Serif+TC:wght@400;600&display=swap" rel="stylesheet">
    <style>
        /* === Global Variables: Literary Color Palette === */
        :root {
            --bg-color: #FDFCF8;       /* Creamy White */
            --text-main: #464646;      /* Dark Grey Ink */
            --text-light: #888888;     /* Light Grey */
            --accent-color: #7A8B8B;   /* Morandi Blue-Grey */
            --card-bg: #FFFFFF;
            --border-color: #ECEBE6;
            --btn-brown: #C17F59;      /* Warm Brown (Buttons) */
            --btn-blue: #5B9BD5;       /* Modify Button Blue */
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }
        
        body { 
            font-family: 'Noto Sans TC', sans-serif; 
            background-color: var(--bg-color); 
            color: var(--text-main); 
            line-height: 1.8;
            padding: 40px 10%;
        }
        
        h1, h2, h3, .serif { font-family: 'Noto Serif TC', serif; font-weight: 600; }
        a { text-decoration: none; color: var(--text-main); transition: 0.3s; }

        /* Header Navigation */
        .header { 
            display: flex; justify-content: space-between; align-items: center; 
            border-bottom: 1px solid var(--border-color); padding-bottom: 20px; margin-bottom: 40px;
        }
        .nav-links { display: flex; gap: 20px; font-size: 0.95rem; }
        .nav-links a:hover { color: var(--accent-color);  }
        
        /* Search Bar Style */
        .search-form { display: flex; align-items: center; gap: 10px; }
        .search-input { 
            border: 1px solid #ddd; background: transparent; padding: 5px 10px; 
            font-family: 'Noto Sans TC'; outline: none; border-radius: 4px;
        }
        .search-btn {
            background: var(--text-main); color: #fff; border: none; padding: 5px 15px; 
            cursor: pointer; border-radius: 4px; font-family: 'Noto Serif TC';
        }

        /* Action Buttons Area */
        .action-bar { margin-bottom: 40px; display: flex; gap: 15px; }
        .btn-main {
            background-color: var(--btn-brown); 
            color: white; 
            padding: 8px 25px; 
            border-radius: 2px;
            font-size: 0.95rem; 
            font-family: 'Noto Serif TC';
            letter-spacing: 1px;
        }
        .btn-main:hover { opacity: 0.9; transform: translateY(-2px); }

        /* === Grid & Card === */
        .grid { 
            display: grid; 
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); 
            gap: 40px; 
        }

        .card { 
            background: var(--card-bg); 
            border: 1px solid transparent; 
            transition: all 0.4s ease; 
            cursor: pointer; 
            overflow: hidden;
        }
        .card:hover { 
            transform: translateY(-5px); 
            box-shadow: 0 15px 30px rgba(0,0,0,0.05); 
            border-color: var(--border-color);
        }

        .card-img { 
            width: 100%; height: 220px; 
            display: flex; align-items: center; justify-content: center; 
            color: white; font-family: 'Noto Serif TC'; letter-spacing: 0.2em; font-size: 1.1rem;
        }

        .card-content { padding: 25px 0; }
        .card-location { font-size: 0.85rem; color: var(--text-light); margin-bottom: 8px; letter-spacing: 0.05em; }
        .card-title { font-size: 1.3rem; margin-bottom: 15px; font-weight: 500; color: var(--text-main); }
        .card-details { display: flex; font-size: 0.9rem; color: var(--text-light); margin-bottom: 15px; gap: 10px; }
        .card-footer { display: flex; justify-content: space-between; align-items: center; margin-top: 20px; border-top: 1px solid #f9f9f9; padding-top: 15px; }
        .card-price { font-family: 'Noto Serif TC'; font-size: 1.1rem; color: var(--text-main); }

        /* Modify Button (Form Style) */
        .form-modify {
            display: inline-block;
        }
        .logo { font-size: 1.6rem; letter-spacing: 0.2em; }
        .btn-modify {
            background-color: transparent;
            border: 1px solid var(--btn-blue); 
            color: var(--btn-blue); 
            padding: 4px 15px; 
            border-radius: 4px; 
            font-size: 0.85rem; 
            transition: 0.3s;
            cursor: pointer;
            font-family: 'Noto Sans TC';
        }
        .btn-modify:hover { background-color: var(--btn-blue); color: white; }

        .batch-form {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-left: 15px;
    padding-left: 15px;
    border-left: 1px solid #ddd;
}
.input-percent {
    width: 70px;
    padding: 6px 10px;
    border: 1px solid #ccc;
    border-radius: 2px;
    font-family: 'Noto Sans TC';
    text-align: center;
}
.btn-batch {
    background-color: var(--accent-color);
    color: white;
    border: none;
    padding: 7px 12px;
    border-radius: 2px;
    cursor: pointer;
    font-family: 'Noto Serif TC';
    font-size: 0.9rem;
    transition: 0.3s;
    white-space: nowrap; /* 防止文字換行 */
}
.btn-batch:hover { opacity: 0.9; }

/* ★ NEW: RWD 響應式設計 (手機版優化) */
@media (max-width: 768px) {
    body { padding: 20px 5%; } /* 縮小邊距 */
    
    .header { flex-direction: column; align-items: flex-start; gap: 15px; }
    .search-form { width: 100%; }
    .search-input { flex-grow: 1; }

    .action-bar { 
        flex-wrap: wrap; /* 允許換行 */
        gap: 15px; 
    }
    
    .batch-form {
        margin-left: 0;
        padding-left: 0;
        border-left: none;
        width: 100%; /* 手機版佔滿整行 */
        background: #f9f9f9; /* 加個底色區隔 */
        padding: 10px;
        border-radius: 4px;
    }
    
    .input-percent { flex-grow: 1; } /* 輸入框自動變寬 */
    
    /* 讓篩選按鈕也自動適應 */
    .action-bar .btn-main { flex-grow: 1; text-align: center; }
}
    </style>
</head>
<body>

    <div class="header">
        <div class="nav-links serif logo">
            <a href="index.php">where is my love</a>
            <a href="#" onclick="history.back()">上一頁</a>
        </div>
        <form class="search-form" method="GET">
            <?php if($filter): ?><input type="hidden" name="filter" value="<?= $filter ?>"><?php endif; ?>
            
            <span class="serif">search</span>
            <input type="text" name="search" class="search-input" value="<?= htmlspecialchars($search_keyword) ?>">
            <button type="submit" class="search-btn">送出</button>
        </form>
    </div>

        <div class="action-bar">
        <!-- 1. 新增按鈕 -->
        <a href="landlord_addhouse.php" class="btn-main">新增</a>

        <!-- 2. ★ NEW: 批次調漲表單 (含前端限制) -->
        <form method="POST" class="batch-form" onsubmit="return confirm('確定要調整所有房源的租金嗎？\n(正數=漲價, 負數=降價)');">
            <span class="serif" style="color: var(--text-light); font-size: 0.9rem;">調租金：</span>
            
            <!-- min="-99" 限制前端輸入，max="500" 防止誤按 -->
            <input type="number" name="percentage" class="input-percent" 
                   placeholder="%" step="0.1" required 
                   min="-99" max="500">
                   
            <button type="submit" name="batch_update" class="btn-batch">執行</button>
        </form>

        <!-- 3. 篩選按鈕 -->
        <?php if ($filter === 'below_avg'): ?>
            <a href="?" class="btn-main" style="background:transparent; border:1px solid #C17F59; color:#C17F59; margin-left:auto;">
                顯示全部
            </a>
        <?php else: ?>
            <a href="?filter=below_avg" class="btn-main" style="background:transparent; border:1px solid #7A8B8B; color:#7A8B8B; margin-left:auto;">
                顯示低於你的房屋平均價格的房屋
            </a>
        <?php endif; ?>
    </div>


    <div class="grid">
        <?php foreach ($houses as $row): ?>
            <div class="card">
                <div class="card-img" style="background-color: <?= getRandomColor() ?>;">
                    影像
                </div>
                
                <div class="card-content">
                    <div class="card-location"><?= htmlspecialchars($row['address']) ?></div>
                    <div class="card-title serif"><?= htmlspecialchars($row['house_name']) ?></div>
                    
                    <div class="card-details">
                        <span><?= htmlspecialchars($row['room_type']) ?></span>
                        <span>•</span>
                        <span>ID: <?= $row['id'] ?></span>
                    </div>
                    
                    <div class="card-footer">
                        <div class="card-price">NT$ <?= number_format($row['rent_price']) ?> / 月</div>

                        <form method="POST" class="form-modify">
                            <input type="hidden" name="id_to_edit" value="<?= $row['id'] ?>">
                            <button type="submit" name="edit_house" class="btn-modify">修改</button>
                        </form>
                        </div>
                </div>
            </div>
        <?php endforeach; ?>
        
        <?php if(empty($houses)): ?>
            <div style="color:var(--text-light); padding:20px;">
                沒有符合條件的資料。
            </div>
        <?php endif; ?>
    </div>

</body>
</html>