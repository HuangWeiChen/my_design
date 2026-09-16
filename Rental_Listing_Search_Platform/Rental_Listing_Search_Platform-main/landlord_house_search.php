<?php
include 'guest_login.php'; // 資料庫連線

$landlord_id = $_GET['landlord_id'] ?? '';
$landlord_name = $_GET['landlord_name'] ?? '';

if (!$landlord_id || !$landlord_name) {
    echo "<script>alert('房東資訊錯誤'); location.href='search.php';</script>";
    exit;
}

// 查詢該房東的房源資料
try {
    $stmt = $db->prepare("SELECT * FROM house WHERE landlord_id = ?");
    $stmt->execute([$landlord_id]);
    $houses = $stmt->fetchAll(PDO::FETCH_ASSOC);
} catch (PDOException $e) {
    die("資料庫錯誤：" . $e->getMessage());
}

// 隨機莫蘭迪色
function getRandomColor() {
    $colors = ['#D3D3D3', '#Cdcab9', '#8fa0a0', '#b5b5b5', '#9fb1bc', '#E8C5A8', '#A8BFA6'];
    return $colors[array_rand($colors)];
}
?>


<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <title>我的房源 - where is my love</title>
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

        a {
            text-decoration: none;
            color: var(--text-main);
            transition: 0.3s;
        }

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

        .logo {
            font-size: 1.6rem;
            letter-spacing: 0.2em;
        }

        nav ul {
            list-style: none;
            display: flex;
            gap: 40px;
        }

        nav a {
            font-size: 0.9rem;
            color: var(--text-light);
        }

        nav a:hover {
            color: var(--accent-color);
        }

        .section-title {
            font-size: 1.5rem;
            margin-bottom: 30px;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 60px 10%;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 40px;
        }

        .card {
            background: var(--card-bg);
            transition: all 0.4s ease;
            cursor: pointer;
            overflow: hidden;
            border: 1px solid transparent;
            border-radius: 4px;
        }

        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 30px rgba(0,0,0,0.04);
            border-color: var(--border-color);
        }

        .card-img {
            width: 100%;
            height: 250px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-family: 'Noto Serif TC';
        }

        .card-content {
            padding: 25px 20px;
        }

        .card-location {
            font-size: 0.8rem;
            color: var(--accent-color);
            margin-bottom: 8px;
            letter-spacing: 0.1em;
        }

        .card-title {
            font-size: 1.2rem;
            margin-bottom: 15px;
            font-weight: 500;
        }

        .card-details {
            display: flex;
            font-size: 0.85rem;
            color: var(--text-light);
            margin-bottom: 20px;
            gap: 10px;
        }

        .card-price {
            font-family: 'Noto Serif TC';
            font-size: 1.1rem;
            text-align: right;
            border-top: 1px solid #f0f0f0;
            padding-top: 15px;
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

        .card-footer {
            margin-top: 15px;
            display: flex;
            justify-content: space-between;
            gap: 10px;
        }

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

    <!-- ✅ Header 一致化 (與 index.php 相同) -->
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
        <h2 class="section-title serif"><span style="color: #a6c015ff;"><?= htmlspecialchars($landlord_name) ?></span> 發布的房源 (<?= count($houses) ?>)</h2>
        <div class="grid">
            <?php foreach ($houses as $row): ?>
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
                            <span>房東：<?= htmlspecialchars($landlord_name) ?></span>
                        </div>
                        <div style="font-size: 0.8rem; color: #aaa; margin-bottom: 15px;">
                            <?= isset($row['description']) ? htmlspecialchars($row['description']) : '溫馨舒適的空間，等待有緣人。' ?>
                        </div>
                        <div class="card-price">NT$ <?= number_format($row['rent_price']) ?> / 月</div>
                        <div class="card-footer">
                            <a href="house_info.php?id=<?= $row['id'] ?>" class="btn-detail">查看詳情</a>
                            <a href="landlord_detail.php?id=<?= $row['landlord_id'] ?>" class="btn-landlord">房東資訊</a>

                        </div>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>
    </div>
    <script>
        function toggleMenu() {
            document.querySelector("nav ul").classList.toggle("active");
        }
    </script>
</body>
</html>
