<?php
// ==========================================
// 1. 真實資料庫連線 (Real Database Connection)
// ==========================================
$host = "mysql-databaseproject.alwaysdata.net";
$port = 3306;
$username = "442082_guess"; 
$password = "@Guess0000";   
$dbname = "databaseproject_comcom"; 

try {
    // 使用 PDO 來建立連線
    $db = new PDO("mysql:host=$host;port=$port;dbname=$dbname;charset=utf8", $username, $password);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION); // 設定錯誤模式為例外
} catch (PDOException $e) {
    die("連線失敗: " . $e->getMessage());
}

// ==========================================
// 2. 搜尋邏輯處理 (Search Logic)
// ==========================================

// 接收 GET 參數
$search_loc = $_GET['location'] ?? '';
$search_name = $_GET['house_name'] ?? '';
$search_type = $_GET['type'] ?? '';
$search_budget = $_GET['budget'] ?? '';

// 建立動態 SQL 查詢
$sql = "SELECT house.*, landlord.name AS landlord_name 
        FROM house 
        JOIN landlord ON house.landlord_id = landlord.id 
        WHERE 1=1";


$params = [];




// 篩選：地點 (Address) - 使用模糊搜尋
try {
    $stmt_addr = $db->query("SELECT DISTINCT address FROM house ORDER BY address ASC");
    $all_addresses = $stmt_addr->fetchAll(PDO::FETCH_COLUMN);
} catch (Exception $e) {
    $all_addresses = [];
}

if (!empty($search_loc)) {
    $sql .= " AND address LIKE ?";
    $params[] = "%" . $search_loc . "%";
}

// 篩選：房屋名稱 (House Name) - 使用模糊搜尋
if (!empty($search_name)) {
    $sql .= " AND house_name LIKE ?";
    $params[] = "%" . $search_name . "%";
}


// 篩選：房型 (Room Type)
if (!empty($search_type)) {
    $sql .= " AND room_type = ?";
    $params[] = $search_type;
}

// 篩選：預算 (Rent Price)
if (!empty($search_budget)) {
    switch ($search_budget) {
        case '1': // 1.5萬 以下
            $sql .= " AND rent_price <= 15000";
            break;
        case '2': // 1.5萬 - 2.5萬
            $sql .= " AND rent_price > 15000 AND rent_price <= 25000";
            break;
        case '3': // 2.5萬 以上
            $sql .= " AND rent_price > 25000";
            break;
    }
}
// 抽出 WHERE 條件部分
$where_clause = substr($sql, strpos($sql, "WHERE")); // 取得 WHERE 後的條件

// count 查詢也要 JOIN
$count_sql = "SELECT COUNT(*) FROM house 
              JOIN landlord ON house.landlord_id = landlord.id 
              " . $where_clause;

try {
    $count_stmt = $db->prepare($count_sql);
    $count_stmt->execute($params);
    $total_count = $count_stmt->fetchColumn();
} catch (Exception $e) {
    $total_count = 0;
}
// 執行查詢
try {
    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
} catch (Exception $e) {
    $results = []; // 若出錯則為空陣列
}

// 輔助函式：產生隨機莫蘭迪色 (為了讓沒有圖片的房源也能保持美感)
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
    <title>尋找房源 | where is my love</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@300;400;500&family=Noto+Serif+TC:wght@400;600&display=swap" rel="stylesheet">
    
    <style>
        /* 文青風格 CSS (保持不變) */
        :root {
            --bg-color: #FDFCF8;
            --text-main: #464646;
            --text-light: #888888;
            --accent-color: #7A8B8B;
            --accent-hover: #5F6F6F;
            --card-bg: #FFFFFF;
            --border-color: #ECEBE6;
            --blue-accent: #9FB1BC;
        }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        
        body { 
            font-family: 'Noto Sans TC', sans-serif; 
            background-color: var(--bg-color); 
            color: var(--text-main); 
            line-height: 1.8;
            padding-top: 100px; 
        }
        
        h1, h2, h3, .serif { font-family: 'Noto Serif TC', serif; font-weight: 600; }
        a { text-decoration: none; color: var(--text-main); transition: 0.3s; }
        
        /* Header */
        header { 
            position: fixed; top: 0; left: 0; width: 100%; z-index: 1000; 
            background-color: rgba(253, 252, 248, 0.95); backdrop-filter: blur(5px); 
            border-bottom: 1px solid var(--border-color); padding: 20px 10%; 
            display: flex; justify-content: space-between; align-items: center; 
            box-shadow: 0 2px 10px rgba(0,0,0,0.02); 
        }
        .logo { font-size: 1.6rem; letter-spacing: 0.2em; }
        nav ul { list-style: none; display: flex; gap: 40px; }
        nav a { font-size: 0.9rem; color: var(--text-light); }
        
        /* 搜尋列區塊 */
        .search-section { padding: 40px 10% 0; max-width: 1000px; margin: 0 auto; }
        
        .search-bar { 
            background: #fff; border: 1px solid var(--border-color); 
            padding: 20px 30px; border-radius: 50px; 
            box-shadow: 0 5px 20px rgba(0,0,0,0.03); 
            display: flex; justify-content: space-between; align-items: center; 
            gap: 20px; flex-wrap: wrap; 
        }
        
        .filter-group { display: flex; align-items: center; gap: 10px; }
        .filter-group label { font-size: 0.85rem; color: var(--accent-color); font-family: 'Noto Serif TC'; white-space: nowrap; }
        
        .filter-group select { 
            border: none; background: transparent; font-size: 0.95rem; 
            color: var(--text-main); outline: none; cursor: pointer; 
            border-bottom: 1px dashed #ddd; padding-bottom: 2px; 
            font-family: 'Noto Sans TC'; 
        }
        
        .filter-btn { 
            background-color: var(--text-main); color: #fff; border: none; 
            padding: 10px 30px; border-radius: 25px; cursor: pointer; 
            font-size: 0.9rem; transition: 0.3s; font-family: 'Noto Serif TC'; 
        }
        .filter-btn:hover { background-color: var(--accent-color); }

        /* 列表樣式 */
        .listings { padding: 40px 10% 80px; min-height: 600px; }
        .section-header { display: flex; justify-content: space-between; align-items: end; margin-bottom: 40px; border-bottom: 1px solid var(--border-color); padding-bottom: 15px; }
        .section-title { font-size: 1.5rem; }
        
        .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 40px; }
        
        .card { background: var(--card-bg); transition: all 0.4s ease; cursor: pointer; overflow: hidden; border: 1px solid transparent; border-radius: 4px; }
        .card:hover { transform: translateY(-5px); box-shadow: 0 15px 30px rgba(0,0,0,0.04); border-color: var(--border-color); }
        .card-img { width: 100%; height: 250px; display: flex; align-items: center; justify-content: center; color: white; font-family: 'Noto Serif TC'; }
        
        .card-content { padding: 25px 20px; }
        .card-location { font-size: 0.8rem; color: var(--accent-color); margin-bottom: 8px; letter-spacing: 0.1em; }
        .card-title { font-size: 1.2rem; margin-bottom: 15px; font-weight: 500; }
        .card-details { display: flex; font-size: 0.85rem; color: var(--text-light); margin-bottom: 20px; gap: 10px; }
        .card-price { font-family: 'Noto Serif TC'; font-size: 1.1rem; text-align: right; border-top: 1px solid #f0f0f0; padding-top: 15px; }
        
        .empty-state { grid-column: 1 / -1; text-align: center; color: var(--text-light); padding: 50px 0; font-family: 'Noto Serif TC'; }
        
        footer { padding: 60px 10%; text-align: center; font-size: 0.8rem; color: var(--text-light); border-top: 1px solid var(--border-color); }

        /* === 手機選單：漢堡按鈕 === */
        .mobile-menu-toggle {
            display: none;
            font-size: 1.8rem;
            cursor: pointer;
            color: var(--text-light);
        }

        @media (max-width: 768px) {
            .mobile-menu-toggle {
                display: block;
            }

            nav {
                position: absolute; top: 60px; right: 0; width: 100%;
                background-color: var(--bg-color); border-top: 1px solid var(--border-color);
                z-index: 999;
            }

            nav ul {
                display: none; flex-direction: column; gap: 0;
                padding: 10px 20px;
            }

            nav ul.active {
                display: flex;
            }

            nav li {
                width: 100%; /* ✅ 滿版寬度 */
                border-bottom: 1px solid var(--border-color);
                padding: 12px 0;
            }
            nav a {
                display: block;
                width: 100%;
                font-size: 1rem;
                text-align: center;
                
            }
            nav a:hover {
                background-color: #f5f5f5;
                color: var(--accent-color);
            }

        }

        .btn-detail, .btn-landlord {
            display: inline-block;
            padding: 8px 16px;
            font-size: 0.85rem;
            color: white;
            background-color: var(--accent-color);
            border-radius: 20px;
            text-align: center;
            transition: background-color 0.3s ease;
            font-family: 'Noto Serif TC';
        }
        .btn-detail:hover, .btn-landlord:hover {
            background-color: var(--accent-hover);
        }

    </style>
</head>
<body>

    <header>
        <div class="logo serif"><a href="index.php">where is my love</a></div>
        <div class="mobile-menu-toggle" onclick="toggleMenu()">☰</div>
        <nav>
            <ul>
                <li><a href="search.php">尋找房源</a></li>
                <li><a href="water.php">關於我們</a></li>
            </ul>
        </nav>
    </header>


    <div class="search-section">
        <form action="" method="GET" class="search-bar">
            <div class="filter-group">
            <label>區域 (地址)</label>
            <input type="text" name="location" placeholder="輸入區域或路名..." value="<?= htmlspecialchars($search_loc) ?>" 
                list="address-list"
                style="border:none; border-bottom:1px dashed #ddd; background:transparent; outline:none; font-family:'Noto Sans TC'; color:#464646; width:150px;">
            <datalist id="address-list">
                <?php foreach ($all_addresses as $addr): ?>
                    <option value="<?= htmlspecialchars($addr) ?>"></option>
                <?php endforeach; ?>
            </datalist>
            </div>

            <div class="filter-group">
                <label>房屋名稱</label>
                <input type="text" name="house_name" placeholder="輸入關鍵字..." value="<?= htmlspecialchars($_GET['house_name'] ?? '') ?>"
                    style="border:none; border-bottom:1px dashed #ddd; background:transparent; outline:none; font-family:'Noto Sans TC'; color:#464646; width:150px;">
            </div>

            <div class="filter-group">
                <label>房型</label>
                <select name="type">
                    <option value="">不限</option>
                    <option value="雅房" <?= $search_type == '雅房' ? 'selected' : '' ?>>雅房</option>
                    <option value="分租套房" <?= $search_type == '分租套房' ? 'selected' : '' ?>>分租套房</option>
                    <option value="獨立套房" <?= $search_type == '獨立套房' ? 'selected' : '' ?>>獨立套房</option>
                    <option value="整層住家" <?= $search_type == '整層住家' ? 'selected' : '' ?>>整層住家</option>
                    <option value="共生宅" <?= $search_type == '共生宅' ? 'selected' : '' ?>>共生宅</option>
                </select>
            </div>

            <div class="filter-group">
                <label>預算</label>
                <select name="budget">
                    <option value="">隨緣</option>
                    <option value="1" <?= $search_budget == '1' ? 'selected' : '' ?>>1.5萬 以下</option>
                    <option value="2" <?= $search_budget == '2' ? 'selected' : '' ?>>1.5萬 - 2.5萬</option>
                    <option value="3" <?= $search_budget == '3' ? 'selected' : '' ?>>2.5萬 以上</option>
                </select>
            </div>
            <button type="submit" class="filter-btn">篩選結果</button>
        </form>
    </div>

    <section class="listings">
        <div class="section-header">
            <div class="section-title serif">
                <?php 
                    if($search_loc || $search_type || $search_budget) {
                        echo "資料庫搜尋結果 (" . $total_count . ")";
                    } else {
                        echo "所有房源 (" . $total_count . ")"; 
                    }
                ?>
            </div>
            <a href="search.php" style="font-size: 0.9rem; color: var(--text-light);">清除條件 ↻</a>
        </div>

        <div class="grid">
            <?php if (count($results) > 0): ?>
                <?php foreach ($results as $row): ?>
                    <div class="card">
                        <div class="card-img" style="background-color: <?= getRandomColor() ?>;">
                            影像
                        </div>
                        <div class="card-content">
                            <div class="card-location"><?= htmlspecialchars($row['address']) ?></div>
                            
                            <div class="card-title serif">
                                <?= htmlspecialchars($row['house_name']) ?: '未命名房屋' ?> <span style="font-size: 0.8rem; color: #aaa;"></span>
                            </div>
                            
                            <div class="card-details">
                                <span><?= htmlspecialchars($row['room_type']) ?></span>
                                <span>•</span>
                                <span>房東: <?= htmlspecialchars($row['landlord_name']) ?></span>
                            </div>
                            
                            <div style="font-size: 0.8rem; color: #aaa; margin-bottom: 15px;">
                                溫馨舒適的空間，等待有緣人。
                            </div>
                            
                            <div class="card-price">NT$ <?= number_format($row['rent_price']) ?> / 月</div>
                            
                            <!-- 新增按鈕 -->
                            <div style="margin-top: 15px; display: flex; justify-content: space-between; gap: 10px;">
                                <a href="house_info.php?id=<?= $row['id'] ?>" class="btn-detail">查看詳情</a>
                                <a href="landlord_detail.php?id=<?= $row['landlord_id'] ?>" class="btn-landlord">房東資訊</a>
                            </div>

                        </div>  
                    </div>
                <?php endforeach; ?>
            <?php else: ?>
                <div class="empty-state">
                    <h3>沒有找到相關的消息...</h3>
                    <p style="margin-top: 10px;">很抱歉，沒有符合條件的房源。</p>
                </div>
            <?php endif; ?>
        </div>
    </section>

    <footer>
        <p>&copy; <?php echo date("Y"); ?> where is my love . All rights reserved.</p>
    </footer>
    <script>
        function toggleMenu() {
            document.querySelector("nav ul").classList.toggle("active");
        }
    </script>

</body>
</html>