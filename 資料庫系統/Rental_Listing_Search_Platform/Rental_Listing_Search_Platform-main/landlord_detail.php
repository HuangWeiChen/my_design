<?php
include 'guest_login.php'; // 資料庫連線
header('Content-Type: text/html; charset=utf-8');

// 取得房東 ID
$id = $_GET['id'] ?? null;

if (!$id || !is_numeric($id)) {
    echo "<script>alert('房東 ID 無效'); location.href='search.php';</script>";
    exit;
}

try {
    $query = "SELECT name, phone, line FROM landlord WHERE id = ?";
    $stmt = $db->prepare($query);
    $stmt->execute([$id]);
    $landlord = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$landlord) {
        echo "<script>alert('找不到房東資料'); location.href='search.php';</script>";
        exit;
    }
} catch (PDOException $e) {
    echo "資料庫錯誤：" . $e->getMessage();
    exit;
}
?>
<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <title>房東個人資訊 - where is my love </title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@300;400;500&family=Noto+Serif+TC:wght@400;600&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-color: #FDFCF8;
            --text-main: #464646;
            --text-light: #888888;
            --accent-color: #7A8B8B;
            --accent-hover: #5F6F6F;
            --card-bg: #FFFFFF;
            --border-color: #ECEBE6;
            --green-accent: #A8BFA6;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Noto Sans TC', sans-serif;
            background-color: var(--bg-color);
            color: var(--text-main);
            line-height: 1.8;
            padding-top: 100px;
        }
        h1, h2, h3, .serif {
            font-family: 'Noto Serif TC', serif;
            font-weight: 600;
        }
        a { text-decoration: none; color: var(--text-main); transition: 0.3s; }

        header {
            position: fixed;
            top: 0; left: 0;
            width: 100%;
            z-index: 1000;
            background-color: rgba(253, 252, 248, 0.95);
            backdrop-filter: blur(5px);
            border-bottom: 1px solid var(--border-color);
            padding: 20px 10%;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.02);
        }
        .logo { font-size: 1.6rem; letter-spacing: 0.2em; }
        nav ul {
            list-style: none;
            display: flex;
            gap: 40px;
            align-items: center;
        }
        nav a {
            font-size: 0.9rem;
            color: var(--text-light);
        }
        nav a:hover { color: var(--accent-color); }

        .container {
            background-color: white;
            border-radius: 8px;
            padding: 40px;
            max-width: 600px;
            margin: 0 auto;
            box-shadow: 0 4px 12px rgba(0,0,0,0.04);
        }
        h2 { text-align: center; margin-bottom: 30px; }
        .info-item { margin-bottom: 20px; }
        .info-label { font-weight: bold; color: #666; }
        .edit-btn {
            display: block;
            width: 100%;
            padding: 12px;
            background-color: var(--green-accent);
            border: none;
            color: white;
            border-radius: 5px;
            font-size: 16px;
            margin-top: 30px;
            text-align: center;
            text-decoration: none;
        }
        .edit-btn:hover { background-color: #8da693; }

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

    <div class="container">
        <h2 class="serif">房東個人資訊</h2>
        <div class="info-item"><span class="info-label">姓名：</span><?= htmlspecialchars($landlord['name']) ?></div>
        <div class="info-item"><span class="info-label">電話：</span><?= htmlspecialchars($landlord['phone']) ?></div>
        <div class="info-item"><span class="info-label">LINE ID：</span><?= htmlspecialchars($landlord['line']) ?></div>

        <!-- 傳房東ID與名字給房源頁 -->
        <a class="edit-btn" href="landlord_house_search.php?landlord_id=<?= $id ?>&landlord_name=<?= urlencode($landlord['name']) ?>">
            查看房東房子
        </a>
    </div>
    <script>
        function toggleMenu() {
            document.querySelector("nav ul").classList.toggle("active");
        }
    </script>
</body>
</html>
