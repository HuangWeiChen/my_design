<?php
// house_create.php

include 'guest_login.php';
$landlord_id = $_GET['landlord_id'] ?? '';
$message = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $room_type = $_POST['room_type'];
    $address = $_POST['address'];
    $rent_price = $_POST['rent_price'];
    $cover_photo_url = $_POST['cover_photo_url'];
    $house_photo_url = $_POST['house_photo_url'];
    $env_photo_url = $_POST['env_photo_url'];

    $sql = "INSERT INTO house (room_type, address, rent_price, landlord_id, cover_photo_url, house_photo_url, env_photo_url) 
            VALUES (?, ?, ?, ?, ?, ?, ?)";
    $stmt = $db->prepare($sql);
    $stmt->execute([$room_type, $address, $rent_price, $landlord_id, $cover_photo_url, $house_photo_url, $env_photo_url]);

    echo "<script>alert('新增成功！'); window.close();</script>";
    exit;
}
?>

<!-- HTML 表單 -->
<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <title>新增房源</title>
    <style>
        body { font-family: sans-serif; padding: 30px; background-color: #fdfcf8; }
        form { max-width: 600px; margin: auto; background: white; padding: 25px; border-radius: 6px; box-shadow: 0 5px 20px rgba(0,0,0,0.05); }
        input { width: 100%; padding: 8px; margin-top: 6px; margin-bottom: 15px; }
        button { padding: 10px 20px; background-color: #7A8B8B; color: white; border: none; border-radius: 4px; cursor: pointer; }
    </style>
</head>
<body>
    <h2>新增房子（房東 ID：<?= htmlspecialchars($landlord_id) ?>）</h2>
    <form method="post">
        <input type="hidden" name="landlord_id" value="<?= htmlspecialchars($landlord_id) ?>">
        <label>房型</label><input type="text" name="room_type" required>
        <label>地址</label><input type="text" name="address" required>
        <label>租金</label><input type="number" name="rent_price" required>
        <label>封面圖片 URL</label><input type="text" name="cover_photo_url">
        <label>房源圖片（多張用逗號）</label><input type="text" name="house_photo_url">
        <label>環境圖片（多張用逗號）</label><input type="text" name="env_photo_url">
        <button type="submit">新增</button>
    </form>
</body>
</html>
