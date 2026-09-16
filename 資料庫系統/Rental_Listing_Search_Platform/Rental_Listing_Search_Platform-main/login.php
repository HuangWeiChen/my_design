<?php
// login.php

$host = "mysql-databaseproject.alwaysdata.net";
$port = 3306;
$username = "442082_1"; // 替換為你的資料庫使用者名稱           //442082_2
$password = "@Tsai0000";   // 替換為你的密碼                //@Hugo0000
$dbname = "databaseproject_comcom"; // 替換為你的資料庫名稱

try {
    // 使用 PDO 來建立連線
    $db = new PDO("mysql:host=$host;port=$port;dbname=$dbname;charset=utf8", $username, $password);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION); // 設定錯誤模式為例外
} catch (PDOException $e) {
    die("連線失敗: " . $e->getMessage());
}
?>
