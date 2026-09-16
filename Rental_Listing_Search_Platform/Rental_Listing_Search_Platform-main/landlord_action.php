<?php
// include_once "guest_login.php";
include_once "login.php"; 

header('Content-Type: text/html; charset=utf-8');

// --- 初始化變數 ---
$showAlert = false;
$iconType = 'info';
$messageTitle = '';
$messageText = '';
$redirectUrl = '';

try {
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        
        $action = $_POST['action'];

        // ==========================
        // 註冊邏輯
        // ==========================
        if ($action === 'register') {
            $id = $_POST['id'];
            $name = $_POST['name'];
            $phone = $_POST['phone'];
            $line = $_POST['line'];
            $account = $_POST['account'];
            $password = $_POST['password'];

            $query = "INSERT INTO landlord (id,name, phone, line, account, password) VALUES (?,?, ?, ?, ?, ?)";
            $stmt = $db->prepare($query);
            $result = $stmt->execute(array($id, $name, $phone, $line, $account, $password));

            if ($result) {
                $showAlert = true;
                $iconType = 'success';
                $messageTitle = 'SYSTEM AUTHORIZED';
                $messageText = '身分模組建立完成，正在重導向至認證程序...';
                $redirectUrl = 'landlord_auth.php';
            } else {
                $showAlert = true;
                $iconType = 'error';
                $messageTitle = 'REGISTRATION FAILED';
                $messageText = '伺服器連線異常，請稍後重試。';
            }
        } 
        
        // ==========================
        // 登入邏輯
        // ==========================
        elseif ($action === 'login') {
            $account = $_POST['account'];
            $password = $_POST['password'];

            $query = "SELECT * FROM landlord WHERE account = ?";
            $stmt = $db->prepare($query);
            $stmt->execute(array($account));
            $user = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($user && $password == $user['password']) {
                session_start();
                $_SESSION['landlord_id'] = $user['id'];
                $_SESSION['landlord_name'] = $user['name'];
                
                $showAlert = true;
                $iconType = 'success';
                $messageTitle = 'ACCESS GRANTED';
                $messageText = '歡迎回來，' . $user['name'] . '。系統連結中...';
                $redirectUrl = 'index.php';
            } else {
                $showAlert = true;
                $iconType = 'error';
                $messageTitle = 'ACCESS DENIED';
                $messageText = '帳號或密碼錯誤，請重新驗證身分。';
            }
        }
    }
} catch (PDOException $e) {
    $showAlert = true;
    $iconType = 'error';
    $messageTitle = 'DATABASE CRITICAL';
    
    if ($e->getCode() == 23000) {
        $error_msg = $e->getMessage();
        if (strpos($error_msg, "PRIMARY") !== false) {
            $messageText = 'ID 衝突：此身分證字號已存在資料庫中。';
        } elseif (strpos($error_msg, "account") !== false) {
            $messageText = '帳號衝突：此帳號已被他人使用。';
        } else {
            $messageText = '資料完整性錯誤 (Code: 23000)。';
        }
    } else {
        $messageText = $e->getMessage();
    }
} catch (Exception $e) {
    $showAlert = true;
    $iconType = 'error';
    $messageTitle = 'SYSTEM ERROR';
    $messageText = $e->getMessage();
}
?>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Processing...</title>
    
    <link href="https://fonts.googleapis.com/css2?family=Exo+2:wght@400;700&family=Noto+Sans+TC:wght@400;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css"/>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    
    <style>
        /* --- 1. 背景特效 --- */
        body {
            margin: 0;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            font-family: 'Exo 2', 'Noto Sans TC', sans-serif;
            background: linear-gradient(-45deg, #0f0c29, #302b63, #24243e, #000000);
            background-size: 400% 400%;
            animation: gradientBG 15s ease infinite;
            overflow: hidden;
        }

        @keyframes gradientBG {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }

        /* --- 2. SweetAlert2 Cyberpunk Style --- */
        div:where(.swal2-popup) {
            background: rgba(30, 30, 45, 0.85) !important;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.1) !important;
            border-radius: 20px !important;
            padding: 30px !important;
            box-shadow: 0 0 30px rgba(0, 242, 96, 0.2), inset 0 0 10px rgba(255,255,255,0.05) !important;
        }

        div:where(.swal2-title) {
            color: #fff !important;
            text-shadow: 0 0 10px rgba(255, 255, 255, 0.5);
            font-weight: 700 !important;
            letter-spacing: 1px;
            margin-bottom: 0.5em !important;
        }

        div:where(.swal2-html-container) {
            color: #b0b0b0 !important;
            font-size: 1.1em !important;
        }

        button.swal2-confirm {
            background: linear-gradient(90deg, #00f260, #0575e6) !important;
            border: none !important;
            box-shadow: 0 0 15px rgba(0, 242, 96, 0.6) !important;
            font-family: 'Exo 2', sans-serif !important;
            text-transform: uppercase;
            letter-spacing: 2px;
            padding: 15px 40px !important;
            border-radius: 50px !important;
            transition: transform 0.6s !important;
        }

        button.swal2-confirm:hover {
            transform: scale(1.05) !important;
            box-shadow: 0 0 25px rgba(0, 242, 96, 0.9) !important;
        }

        .swal2-timer-progress-bar {
            background: #00f260 !important;
            height: 4px !important;
            box-shadow: 0 0 10px #00f260;
        }
        
        /* Error Style Override */
        .popup-error {
            box-shadow: 0 0 30px rgba(255, 65, 108, 0.4) !important;
            border: 1px solid rgba(255, 65, 108, 0.3) !important;
        }
        .btn-error {
            background: linear-gradient(90deg, #ff416c, #ff4b2b) !important;
            box-shadow: 0 0 15px rgba(255, 65, 108, 0.6) !important;
        }
    </style>
</head>
<body>

    <audio id="bgm-success" src="login_sucess.mp3" preload="auto"></audio>
    <audio id="bgm-error" src="login_error.mp3" preload="auto"></audio>

    <script>
        <?php if ($showAlert): ?>
            
            // 判斷狀態
            const isSuccess = '<?php echo $iconType; ?>' === 'success';
            const customPopupClass = isSuccess ? '' : 'popup-error';
            const customBtnClass = isSuccess ? '' : 'btn-error';

            // 播放音效
            try {
                // 抓取對應的 audio ID
                const audio = isSuccess 
                    ? document.getElementById('bgm-success') 
                    : document.getElementById('bgm-error');
                
                audio.volume = 0.5; // 音量 50%
                
                // 執行播放
                const playPromise = audio.play();
                if (playPromise !== undefined) {
                    playPromise.then(_ => {
                        // Success
                    }).catch(error => {
                        console.log("Autoplay blocked: " + error);
                    });
                }
            } catch(e) {
                console.error("Audio Playback Error", e);
            }

            // 顯示彈窗
            Swal.fire({
                icon: '<?php echo $iconType; ?>',
                title: '<?php echo $messageTitle; ?>',
                text: '<?php echo $messageText; ?>',
                
                showClass: { popup: 'animate__animated animate__backInDown' },
                hideClass: { popup: 'animate__animated animate__backOutUp' },

                background: 'rgba(30, 30, 45, 0.9)', 
                color: '#fff',
                
                customClass: {
                    popup: customPopupClass,
                    confirmButton: customBtnClass
                },

                backdrop: `rgba(0,0,0,0.7)`, 
                confirmButtonText: 'CONFIRM',
                buttonsStyling: true,
                allowOutsideClick: false,
                
                timer: <?php echo ($iconType === 'success') ? 2500 : 'null'; ?>,
                timerProgressBar: true,

            }).then((result) => {
                <?php if (!empty($redirectUrl)): ?>
                    window.location.href = '<?php echo $redirectUrl; ?>';
                <?php else: ?>
                    if ('<?php echo $iconType; ?>' === 'error') {
                        history.back();
                    }
                <?php endif; ?>
            });

        <?php endif; ?>
    </script>
</body>
</html>