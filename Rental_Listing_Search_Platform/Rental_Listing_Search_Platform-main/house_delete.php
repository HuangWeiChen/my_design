<?php
// delete_house.php

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    die("不允許的操作");
}

$house_id = $_POST['id'] ?? '';
if (!$house_id) {
    die("缺少房源 ID");
}

include 'guest_login.php';

// 查詢刪除前該筆資料以取得 landlord_id，方便跳轉回房東資訊頁
$stmt = $db->prepare("SELECT landlord_id FROM house WHERE id = ?");
$stmt->execute([$house_id]);
$row = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$row) {
    die("找不到該房源");
}

$landlord_id = $row['landlord_id'];

// 執行刪除
$del_stmt = $db->prepare("DELETE FROM house WHERE id = ?");
$del_stmt->execute([$house_id]);

// 刪除完後跳回該房東頁面
header("Location: landlord_info.php?id=" . urlencode($landlord_id));
exit;
