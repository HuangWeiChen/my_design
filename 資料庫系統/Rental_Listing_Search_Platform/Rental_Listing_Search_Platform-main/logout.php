<?php
session_start(); // 啟動 Session

// 清除所有 Session 變數
$_SESSION = array();

// 銷毀 Session
session_destroy();

// 跳轉回首頁
header("Location: index.php");
exit;
?>
