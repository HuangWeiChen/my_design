<?php
session_start(); // 1. 啟動 Session，必須放在檔案最上方

// 模擬資料庫 (僅用於顯示精選)

?>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>where is my love Chi-Suo</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@300;400;500&family=Noto+Serif+TC:wght@400;600&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-color: #FDFCF8; --text-main: #464646; --text-light: #888888;
            --accent-color: #7A8B8B; --accent-hover: #5F6F6F; --card-bg: #FFFFFF;
            --border-color: #ECEBE6; --orange-accent: #E8C5A8;
            --blue-accent: #9FB1BC; --green-accent: #A8BFA6;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Noto Sans TC', sans-serif; background-color: var(--bg-color); color: var(--text-main); line-height: 1.8; padding-top: 100px; }
        h1, h2, h3, .serif { font-family: 'Noto Serif TC', serif; font-weight: 600; }
        a { text-decoration: none; color: var(--text-main); transition: 0.3s; }

        header {
            position: fixed; top: 0; left: 0; width: 100%; z-index: 1000;
            background-color: rgba(253, 252, 248, 0.95); backdrop-filter: blur(5px);
            border-bottom: 1px solid var(--border-color); padding: 20px 10%;
            display: flex; justify-content: space-between; align-items: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.02);
        }

        .logo { font-size: 1.6rem; letter-spacing: 0.2em; }

        nav ul {
            list-style: none; display: flex; gap: 40px; align-items: center;
        }

        nav a { font-size: 0.9rem; color: var(--text-light); }
        nav a:hover { color: var(--accent-color); }

        .user-menu { position: relative; display: inline-block; height: 100%; }
        .user-name {
            font-family: 'Noto Serif TC'; font-weight: 600; color: var(--text-main);
            cursor: pointer; padding: 10px 0; display: block;
        }
        .user-name:hover { color: var(--accent-color); }

        .dropdown-content {
            display: none; position: absolute; right: 0; top: 100%;
            background-color: var(--card-bg); min-width: 150px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.05);
            border: 1px solid var(--border-color); border-radius: 4px;
            padding: 8px 0; z-index: 2000;
        }

        .dropdown-content a {
            display: block; padding: 10px 20px; color: var(--text-main); font-size: 0.9rem;
        }
        .dropdown-content a:hover {
            background-color: #f9f9f9; color: var(--accent-color);
        }
        .user-menu:hover .dropdown-content {
            display: block; animation: fadeIn 0.3s ease;
        }

        .divider {
            height: 1px; background-color: #eee; margin: 5px 0;
        }
        .logout-link:hover {
            color: #d9534f !important; background-color: #fff5f5 !important;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(5px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .hero {
            padding: 60px 10%; max-width: 1200px; margin: 0 auto;
        }

        .hero-layout {
            display: grid; grid-template-columns: 2fr 1fr;
            grid-template-rows: auto auto; gap: 30px;
        }

        .hero-image {
            grid-row: 1 / 2; grid-column: 1 / 2;
            border: 2px solid var(--orange-accent); border-radius: 8px;
            height: 350px; box-shadow: 0 4px 8px rgba(0,0,0,0.03);
            overflow: hidden; position: relative;
        }

        .hero-image img {
            width: 100%; height: 100%; object-fit: cover; display: block;
        }

        .hero-description {
            grid-row: 2 / 3; grid-column: 1 / 2;
            background-color: var(--card-bg); border: 2px solid var(--border-color);
            border-radius: 8px; padding: 25px; text-align: center;
            color: var(--text-light); font-family: 'Noto Serif TC';
            box-shadow: 0 4px 8px rgba(0,0,0,0.03);
        }

        .hero-buttons {
            grid-row: 1 / 3; grid-column: 2 / 3;
            display: flex; flex-direction: column; gap: 30px;
        }

        .hero-btn {
            flex: 1; border-radius: 8px; display: flex; align-items: center;
            justify-content: center; font-size: 1.8rem; font-family: 'Noto Serif TC';
            color: var(--text-main); cursor: pointer; transition: 0.3s;
            box-shadow: 0 4px 8px rgba(0,0,0,0.05); text-align: center;
            letter-spacing: 0.1em;
        }

        .btn-search {
            background-color: var(--card-bg); border: 2px solid var(--blue-accent);
            color: var(--blue-accent);
        }

        .btn-search:hover {
            background-color: var(--blue-accent); color: white;
        }

        .btn-landlord {
            background-color: var(--card-bg); border: 2px solid var(--green-accent);
            color: var(--green-accent);
        }

        .btn-landlord:hover {
            background-color: var(--green-accent); color: white;
        }

        .listings {
            padding: 80px 10%; background-color: #faf9f6;
            min-height: 400px; margin-top: 60px;
        }

        .section-header {
            display: flex; justify-content: space-between;
            align-items: end; margin-bottom: 50px;
            border-bottom: 1px solid var(--border-color); padding-bottom: 20px;
        }

        .section-title { font-size: 1.5rem; }

        .grid {
            display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 40px;
        }

        .card {
            background: var(--card-bg); transition: all 0.4s ease; cursor: pointer;
            overflow: hidden; border: 1px solid transparent; border-radius: 4px;
        }

        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 30px rgba(0,0,0,0.04);
            border-color: var(--border-color);
        }

        .card-img {
            width: 100%; height: 250px; display: flex;
            align-items: center; justify-content: center;
            color: white; font-family: 'Noto Serif TC';
        }

        .card-content { padding: 25px 20px; }

        .card-location {
            font-size: 0.8rem; color: var(--accent-color);
            margin-bottom: 8px; letter-spacing: 0.1em;
        }

        .card-title { font-size: 1.2rem; margin-bottom: 15px; font-weight: 500; }

        .card-details {
            display: flex; font-size: 0.85rem; color: var(--text-light);
            margin-bottom: 20px; gap: 10px;
        }

        .card-price {
            font-family: 'Noto Serif TC'; font-size: 1.1rem;
            text-align: right; border-top: 1px solid #f0f0f0; padding-top: 15px;
        }

        footer {
            padding: 60px 10%; text-align: center; font-size: 0.8rem;
            color: var(--text-light); border-top: 1px solid var(--border-color);
        }

        /* === 漢堡選單樣式 === */
        .mobile-menu-toggle {
            display: none; font-size: 1.8rem; cursor: pointer; color: var(--text-light);
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
                border-bottom: 1px solid var(--border-color); padding: 10px 0;
            }

            .dropdown-content {
                position: static; box-shadow: none;
                border: none; background-color: transparent;
            }

            .dropdown-content a {
                padding: 8px 0;
            }

            .hero-layout {
                grid-template-columns: 1fr; grid-template-rows: auto;
            }

            .hero-image { height: 200px; }

            .hero-buttons {
                flex-direction: row; justify-content: space-between;
            }

            .hero-btn {
                height: 100px; font-size: 1.2rem;
            }

            .section-title {
                font-size: 1.2rem;
            }

            .card-img {
                height: 180px; font-size: 1rem;
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

                <?php if (isset($_SESSION['landlord_name'])): ?>
                    <li>
                        <div class="user-menu">
                            <span class="user-name"><?= htmlspecialchars($_SESSION['landlord_name']); ?> ▾</span>
                            <div class="dropdown-content">
                                <a href="landlord_edit.php">我的房屋</a>
                                <a href="landlord_profile.php">修改資訊</a>
                                <div class="divider"></div>
                                <a href="logout.php" class="logout-link">登出</a>
                            </div>
                        </div>
                    </li>
                <?php else: ?>
                    <li><a href="landlord_auth.php" style="color: var(--accent-color);">房東登入</a></li>
                <?php endif; ?>
            </ul>
        </nav>
    </header>

    <section class="hero">
        <div class="hero-layout">
            <div class="hero-image">
                <img src="pic/pokemon-snorlax.webp" alt="卡比獸">
            </div>
            <div class="hero-description">在城市的縫隙裡，安放你的日常。<br>不只是租屋，而是尋找一種生活的可能。</div>
            <div class="hero-buttons">
                <a href="search.php" class="hero-btn btn-search">尋找<br>房子</a>
                <?php if (isset($_SESSION['landlord_name'])): ?>
                    <a href="landlord_edit.php" class="hero-btn btn-landlord">進入<br>後台</a>
                <?php else: ?>
                    <a href="landlord_auth.php" class="hero-btn btn-landlord">房東<br>登入</a>
                <?php endif; ?>
            </div>
        </div>
    </section>
    
    

    <footer>
        <p>&copy; <?= date("Y"); ?> where is my love Chi-Suo. All rights reserved.</p>
    </footer>

    <script>
        function toggleMenu() {
            document.querySelector("nav ul").classList.toggle("active");
        }
    </script>
</body>
</html>
