<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>空間故事 | where is my love</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@300;400;500&family=Noto+Serif+TC:wght@400;600&display=swap" rel="stylesheet">
    
    <style>
        /* =========================================
           1. 共同基礎樣式 (與 index.php 相同)
           ========================================= */
        :root {
            --bg-color: #FDFCF8;
            --text-main: #464646;
            --text-light: #888888;
            --accent-color: #7A8B8B;
            --accent-hover: #5F6F6F;
            --card-bg: #FFFFFF;
            --border-color: #ECEBE6;
            --orange-accent: #E8C5A8;
        }
        
        * { box-sizing: border-box; margin: 0; padding: 0; }
        
        body { 
            font-family: 'Noto Sans TC', sans-serif; 
            background-color: var(--bg-color); 
            color: var(--text-main); 
            line-height: 1.8;
            padding-top: 100px; /* 留給 Header */
        }
        
        h1, h2, h3, .serif { font-family: 'Noto Serif TC', serif; font-weight: 600; }
        a { text-decoration: none; color: var(--text-main); transition: 0.3s; }
        
        /* Header */
        header { 
            position: fixed; top: 0; left: 0; width: 100%; z-index: 1000; 
            background-color: rgba(253, 252, 248, 0.95); backdrop-filter: blur(5px); 
            border-bottom: 1px solid var(--border-color); padding: 20px 10%; 
            display: flex; justify-content: space-between; align-items: center; 
        }
        .logo { font-size: 1.6rem; letter-spacing: 0.2em; }
        nav ul { list-style: none; display: flex; gap: 40px; }
        nav a { font-size: 0.9rem; color: var(--text-light); }
        nav a:hover { color: var(--accent-color); }

        /* =========================================
           2. 輪播圖片專用樣式 (Slider Styles)
           ========================================= */
        .story-section {
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 60px 20px;
            max-width: 800px;
            margin: 0 auto;
            text-align: center;
        }

        .story-title {
            font-size: 2rem;
            margin-bottom: 40px;
            letter-spacing: 0.1em;
            color: var(--text-main);
        }
         .story-title2 {
            font-size: 2.5rem;
            margin-bottom: 10px;
            margin
            letter-spacing: 0.1em;
            color: var(--text-main);
        }


        /* 圖片外框容器 */
        .slider-frame {
            position: relative; /* 關鍵：讓內部的 absolute 圖片以此為基準 */
            width: 100%;
            max-width: 600px;   /* 限制最大寬度 */
            height: 600px;      /* 固定高度 */
            border-radius: 8px; /* 圓角 */
            overflow: hidden;   /* 超出範圍隱藏 */
            box-shadow: 0 10px 30px rgba(0,0,0,0.05);
            background-color: #EFECE4; /* 預載背景色 */
        }

        /* 圖片本體 */
        .slider-frame img {
            position: absolute; /* 讓兩張圖疊在一起 */
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;  /* 填滿不變形 */
            opacity: 0;         /* 預設隱藏 */
            transition: opacity 1.5s ease-in-out; /* 淡入淡出時間 1.5秒 */
        }

        /* 顯示狀態的圖片 */
        .slider-frame img.active {
            opacity: 1;
        }

        .story-text {
            margin-top: 40px;
            color: var(--text-light);
            max-width: 500px;
            font-family: 'Noto Serif TC';
        }

        footer { padding: 60px 10%; text-align: center; font-size: 0.8rem; color: var(--text-light); border-top: 1px solid var(--border-color); margin-top: auto;}
    </style>
</head>
<body>

    <header>
        <div class="logo serif"><a href="index.php">where is my love</a></div>
        <nav>
            <ul>
                <li><a href="search.php">尋找房源</a></li>
                <li><a href="#">關於我們</a></li>
            </ul>
        </nav>
    </header>

    <section class="story-section">
        <h1 class="story-title serif">生活的日與夜</h1>
        <h2 class="story-title2 serif">銷冠 </h2>
        <div class="slider-frame">
            <img src="pic/water1.jpg" class="active" alt="Day">
            
            <img src="pic/water2.jpg" alt="Night">
        </div>

        <div class="story-text">
            在這個喧囂的世界裡，光頭是一種勇氣的象徵。
            <br>它不僅是對外表的放下，更是對內心的探索。
            <br>每一寸光滑的肌膚，都是對自我的坦誠，每一個反射的光芒，都是對生活的深思。
            <br>走在街頭，微風吹拂，感受陽光的溫暖，仿佛時間靜止。<br>沒有繁複的髮型，只有最真實的自己。這是一種簡約的美，一種不被世俗束縛的自由。

            <br>讓我們在這片空白中，書寫屬於自己的故事。<br>光頭，不只是外在的形象，更是心靈的解放。<br>每一次的剃髮，都是一次新生的開始，讓我們勇敢地面對每一個明天。
        
        </div>
    </section>

    <footer>
        <p>&copy; <?php echo date("Y"); ?> where is my love. All rights reserved.</p>
    </footer>

    <script>
        // 設定輪播間隔時間 (毫秒)，例如 3000 = 3秒
        const intervalTime = 1800;
        
        // 選取所有輪播圖片
        const slides = document.querySelectorAll('.slider-frame img');
        let currentSlide = 0;

        function nextSlide() {
            // 1. 移除目前圖片的 active
            slides[currentSlide].classList.remove('active');
            
            // 2. 計算下一張圖片的索引 (如果到底了就回到 0)
            currentSlide = (currentSlide + 1) % slides.length;
            
            // 3. 幫下一張圖片加上 active
            slides[currentSlide].classList.add('active');
        }

        // 啟動定時器
        setInterval(nextSlide, intervalTime);
    </script>

</body>
</html>