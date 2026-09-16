<?php
session_start();
include_once "login.php";

header('Content-Type: text/html; charset=utf-8');

if (!isset($_SESSION['landlord_id'])) {
    header("Location: landlord_auth.php");
    exit;
}

try {
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        
        $id = $_SESSION['landlord_id'];
        $name = $_POST['name'];
        $phone = $_POST['phone'];
        $line = $_POST['line'];
        
        $old_password_input = $_POST['old_password'];
        $new_password_input = $_POST['new_password'];

        // 先從資料庫撈出這位房東目前的密碼，用來比對
        $query_check = "SELECT password FROM landlord WHERE id = ?";
        $stmt_check = $db->prepare($query_check);
        $stmt_check->execute(array($id));
        $current_db_data = $stmt_check->fetch(PDO::FETCH_ASSOC);
        $current_password_db = $current_db_data['password'];

        // ==========================================
        // 邏輯判斷
        // ==========================================

        // 情況 A: 使用者想改密碼 (新密碼欄位不為空)
        if (!empty($new_password_input)) {
            
            // 1. 檢查是否有輸入舊密碼
            if (empty($old_password_input)) {
                echo "<script>alert('為了安全，修改密碼時請輸入「舊密碼」！'); history.back();</script>";
                exit;
            }

            // 2. 檢查舊密碼是否正確 (明碼比對)
            if ($old_password_input !== $current_password_db) {
                echo "<script>alert('舊密碼輸入錯誤，無法變更密碼。'); history.back();</script>";
                exit;
            }

            // 3. 舊密碼正確，執行更新 (含密碼)
            $query = "UPDATE landlord SET name=?, phone=?, line=?, password=? WHERE id=?";
            $stmt = $db->prepare($query);
            $result = $stmt->execute(array($name, $phone, $line, $new_password_input, $id));
        } 
        
        // 情況 B: 使用者不想改密碼 (新密碼欄位留空)
        else {
            // 即使沒改密碼，我們也可以檢查一下：
            // 如果使用者填了舊密碼卻沒填新密碼，可能是忘記填新密碼，可以提示一下，或者直接忽略舊密碼欄位。
            // 這裡我們選擇：直接更新基本資料，忽略密碼欄位。
            
            $query = "UPDATE landlord SET name=?, phone=?, line=? WHERE id=?";
            $stmt = $db->prepare($query);
            $result = $stmt->execute(array($name, $phone, $line, $id));
        }

        // ==========================================
        // 結果處理
        // ==========================================
        if ($result) {
            // 更新 Session 中的名字 (如果改名的話)
            $_SESSION['landlord_name'] = $name;

            echo "<script>
                    alert('資料修改成功！'); 
                    location.href='index.php';
                  </script>";
        } else {
            echo "<script>
                    alert('修改失敗，請稍後再試。'); 
                    history.back();
                  </script>";
        }
    }
} catch (PDOException $e) {
    echo "資料庫錯誤: " . $e->getMessage();
}
?>
