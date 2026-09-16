<?php
// house_info.php

include_once "guest_login.php";

// 取得房源 ID
$house_id = $_GET['id'] ?? '';

// 查詢資料
if (!empty($house_id)) {
    $sql = "SELECT * 
            FROM house natural join house_description join landlord on house.landlord_id = landlord.id
            WHERE house.id = ?";
    $stmt = $db->prepare($sql);
    $stmt->execute([$house_id]);
    $house = $stmt->fetch(PDO::FETCH_ASSOC);
} else {
    $house = null;
}

// 處理圖片（用逗號分隔）
function parseImages($imageString) {
    return array_filter(array_map('trim', explode(',', $imageString)));
}

function yesNoText($value, $yes = '有', $no = '無') {
    if ($value === null || $value === '') {
        return '未說明';
    }
    return $value == 1 ? $yes : $no;
}

?>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <title>房源詳情 | where is my love</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@300;400;500&family=Noto+Serif+TC:wght@400;600&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Noto Sans TC', sans-serif;
            background-color: #fdfcf8;
            color: #333;
            padding: 60px;
        }
        h1 {
            font-family: 'Noto Serif TC', serif;
            font-size: 2rem;
            margin-bottom: 20px;
        }
        .info-box {
            background: #fff;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.05);
            max-width: 900px;
            margin: 0 auto;
        }
        .info-item {
            margin-bottom: 15px;
        }
        .info-label {
            font-weight: bold;
            color: #7A8B8B;
        }
        a.back-link {
            display: inline-block;
            margin-top: 30px;
            text-decoration: none;
            color: #7A8B8B;
        }
        a.back-link:hover {
            text-decoration: underline;
        }

        .photo-section {
            margin-top: 30px;
        }

        .photo-title {
            font-size: 1.2rem;
            font-family: 'Noto Serif TC';
            margin-bottom: 10px;
            color: #555;
        }

        .photo-gallery {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
        }

        .photo-gallery img {
            width: 250px;
            height: 180px;
            object-fit: cover;
            border-radius: 6px;
            box-shadow: 0 5px 10px rgba(0,0,0,0.05);
        }
    </style>
</head>
<body>

<?php if ($house): ?>
    <div class="info-box">
        <h1>
            <?= !empty($house['house_name']) 
                ? htmlspecialchars($house['house_name']) 
                : '未命名房屋' 
            ?>
        </h1>

        <div class="info-item">
            <span class="info-label">房東：</span><?= htmlspecialchars($house['name']) ?>
        </div>
        
        <div class="info-item">
            <span class="info-label">房型：</span><?= htmlspecialchars($house['room_type']) ?>
        </div>
        
        <div class="info-item">
            <span class="info-label">地址：</span><?= htmlspecialchars($house['address']) ?>
        </div>
        
        <div class="info-item">
            <span class="info-label">租金：</span>NT$ <?= number_format($house['rent_price']) ?> / 月
        </div>

        <div class="info-item">
            <span class="info-label">水費：</span><?=$house['water']!=null ? htmlspecialchars($house['water']) : '未說明' ?>
        </div>

        <div class="info-item">
            <span class="info-label">電費：</span><?= $house['electricity']!=null ? htmlspecialchars($house['electricity']) : '未說明'?>
        </div>
    
        <div class="info-item">
            <span class="info-label">是否可養寵物：</span><?= yesNoText($house['pet'], '可', '不可') ?>
        </div>

        <div class="info-item">
            <span class="info-label">網路：</span><?= yesNoText($house['internet']) ?>
        </div>

        <div class="info-item">
            <span class="info-label">停車位：</span><?= number_format($house['parking']) ?>
        </div>

        <div class="info-item">
            <span class="info-label">家具：</span><?= yesNoText($house['furnished']) ?>
        </div>


        <div class="info-item">
            <span class="info-label">浴室數量：</span>
            <?= $house['number_of_bathrooms'] != null 
                ? htmlspecialchars($house['number_of_bathrooms']) 
                : '未說明' ?>
        </div>

        <div class="info-item">
            <span class="info-label">大眾運輸：</span><?= yesNoText($house['public_transport']) ?>
        </div>



        <!-- 房屋照片區塊 -->
        <?php 
            $housePhotos = parseImages($house['house_photo_url'] ?? '');
            if (!empty($housePhotos)):
        ?>
            <div class="photo-section">
                <div class="photo-title">🏠 房源照片</div>
                <div class="photo-gallery">
                    <?php foreach ($housePhotos as $img): ?>
                        <img src="<?= htmlspecialchars($img) ?>" alt="房源照片">
                    <?php endforeach; ?>
                </div>
            </div>
        <?php endif; ?>

        <!-- 周圍環境照片區塊 -->
        <?php 
            $envPhotos = parseImages($house['env_photo_url'] ?? '');
            if (!empty($envPhotos)):
        ?>
            <div class="photo-section">
                <div class="photo-title">🌆 周邊環境</div>
                <div class="photo-gallery">
                    <?php foreach ($envPhotos as $img): ?>
                        <img src="<?= htmlspecialchars($img) ?>" alt="環境照片">
                    <?php endforeach; ?>
                </div>
            </div>
        <?php endif; ?>

        <a href="search.php" class="back-link">← 返回房源列表</a>
    </div>
<?php else: ?>
    <div class="info-box">
        <h1>找不到該房源</h1>
        <p>請確認網址是否正確，或回到<a href="search.php">搜尋頁面</a>重新查詢。</p>
    </div>
<?php endif; ?>

</body>
</html>
