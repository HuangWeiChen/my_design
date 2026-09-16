<?php
// house_edit.php
$id = $_GET['id'] ?? '';
if (!$id) die("請提供房源 ID");

// 連線
$host = "mysql-databaseproject.alwaysdata.net";
$dbname = "databaseproject_comcom";
$db = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", "442082_guess", "@Guess0000");
$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

// 抓資料
$stmt = $db->prepare("SELECT * FROM house WHERE id = ?");
$stmt->execute([$id]);
$house = $stmt->fetch(PDO::FETCH_ASSOC);
if (!$house) die("找不到資料");

// 更新
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $sql = "UPDATE house SET room_type=?, address=?, rent_price=?, landlord_id=?, cover_photo_url=?, house_photo_url=?, env_photo_url=? WHERE id=?";
    $stmt = $db->prepare($sql);
    $stmt->execute([
        $_POST['room_type'], $_POST['address'], $_POST['rent_price'], $_POST['landlord_id'],
        $_POST['cover_photo_url'], $_POST['house_photo_url'], $_POST['env_photo_url'], $id
    ]);
    echo "<script>alert('修改成功'); window.close();</script>";
    exit;
}
?>

<!-- 表單 -->
<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <title>編輯房源</title>
    <style>
        body { font-family: sans-serif; padding: 30px; background-color: #fdfcf8; }
        form { max-width: 600px; margin: auto; background: white; padding: 25px; border-radius: 6px; box-shadow: 0 5px 20px rgba(0,0,0,0.05); }
        input { width: 100%; padding: 8px; margin-top: 6px; margin-bottom: 15px; }
        button { padding: 10px 20px; background-color: #7A8B8B; color: white; border: none; border-radius: 4px; cursor: pointer; }
    </style>
</head>
<body>
    <h2>編輯房子 #<?= $id ?></h2>
    <form method="post">
        <label>房型</label><input type="text" name="room_type" value="<?= htmlspecialchars($house['room_type']) ?>">
        <label>地址</label><input type="text" name="address" value="<?= htmlspecialchars($house['address']) ?>">
        <label>租金</label><input type="number" name="rent_price" value="<?= htmlspecialchars($house['rent_price']) ?>">
        <label>房東 ID</label><input type="text" name="landlord_id" value="<?= htmlspecialchars($house['landlord_id']) ?>">
        <label>封面圖片 URL</label><input type="text" name="cover_photo_url" value="<?= htmlspecialchars($house['cover_photo_url']) ?>">
        <label>房源圖片（多張用逗號）</label><input type="text" name="house_photo_url" value="<?= htmlspecialchars($house['house_photo_url']) ?>">
        <label>環境圖片（多張用逗號）</label><input type="text" name="env_photo_url" value="<?= htmlspecialchars($house['env_photo_url']) ?>">
        <button type="submit">儲存修改</button>
    </form>
</body>
</html>
