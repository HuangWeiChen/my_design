<?php
session_start();
include_once "login.php"; 

if (!isset($_SESSION['landlord_id'])) {
    header("Location: landlord_auth.php");
    exit;
}

$id = $_SESSION['landlord_id'];
$query = "SELECT * FROM landlord WHERE id = ?";
$stmt = $db->prepare($query);
$stmt->execute(array($id));
$user = $stmt->fetch(PDO::FETCH_ASSOC);
?>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>修改資訊 - where is my love</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@300;400;500&family=Noto+Serif+TC:wght@400;600&display=swap" rel="stylesheet">
    <style>
        :root { --bg-color: #FDFCF8; --text-main: #464646; --text-light: #888888; --accent-color: #7A8B8B; --card-bg: #FFFFFF; --border-color: #ECEBE6; --green-accent: #A8BFA6; --green-hover: #8FA38D; }
        
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Noto Sans TC', sans-serif; background-color: var(--bg-color); color: var(--text-main); line-height: 1.8; padding-top: 80px; display: flex; justify-content: center; min-height: 100vh; }
        .serif { font-family: 'Noto Serif TC', serif; font-weight: 600; }
        a { text-decoration: none; color: var(--text-main); transition: 0.3s; }

        header { position: fixed; top: 0; left: 0; width: 100%; z-index: 1000; background-color: rgba(253, 252, 248, 0.95); border-bottom: 1px solid var(--border-color); padding: 15px 10%; display: flex; justify-content: space-between; align-items: center; }
        .logo { font-size: 1.4rem; letter-spacing: 0.2em; }
        .back-link { font-size: 0.9rem; color: var(--text-light); }
        .back-link:hover { color: var(--accent-color); }

        .container { width: 100%; max-width: 600px; margin-top: 40px; padding: 0 20px; }
        .edit-card { background: var(--card-bg); padding: 40px; border-radius: 8px; box-shadow: 0 5px 20px rgba(0,0,0,0.03); border: 1px solid var(--border-color); }
        .page-title { font-size: 1.5rem; margin-bottom: 30px; text-align: center; color: var(--text-main); }
        
        .form-group { margin-bottom: 25px; }
        .form-label { display: block; font-size: 0.9rem; color: var(--text-light); margin-bottom: 8px; }
        .form-input { width: 100%; padding: 12px 15px; border: 1px solid var(--border-color); border-radius: 4px; background-color: #FAFAFA; color: var(--text-main); font-size: 1rem; outline: none; transition: 0.3s; }
        .form-input:focus { border-color: var(--green-accent); background-color: #fff; }
        .form-input:disabled { background-color: #eee; cursor: not-allowed; color: #aaa; }

        .hint { font-size: 0.8rem; color: var(--accent-color); margin-top: 5px; }
        .section-divider { border-top: 1px dashed var(--border-color); margin: 30px 0; position: relative; }
        .section-label { position: absolute; top: -12px; left: 0; background: var(--card-bg); padding-right: 10px; font-size: 0.85rem; color: var(--text-light); font-weight: 500; }

        .btn-group { display: flex; gap: 15px; margin-top: 40px; }
        .btn { flex: 1; padding: 12px; border-radius: 4px; text-align: center; cursor: pointer; font-size: 1rem; font-family: 'Noto Serif TC'; letter-spacing: 0.1em; border: none; transition: 0.3s; }
        .btn-save { background-color: var(--green-accent); color: white; }
        .btn-save:hover { background-color: var(--green-hover); transform: translateY(-2px); }
        .btn-cancel { background-color: transparent; border: 1px solid var(--border-color); color: var(--text-light); }
        .btn-cancel:hover { border-color: var(--text-main); color: var(--text-main); }
    </style>
</head>
<body>

    <header>
        <div class="logo serif"><a href="index.php">where is my love</a></div>
        <a href="index.php" class="back-link">← 回首頁</a>
    </header>

    <div class="container">
        <div class="edit-card">
            <h2 class="page-title serif">修改個人資訊</h2>
            
            <form action="landlord_update.php" method="POST">
                
                <div class="form-group">
                    <label class="form-label">登入帳號</label>
                    <input type="text" class="form-input" value="<?php echo htmlspecialchars($user['account']); ?>" disabled>
                </div>

                <div class="form-group">
                    <label class="form-label">房東姓名</label>
                    <input type="text" name="name" class="form-input" value="<?php echo htmlspecialchars($user['name']); ?>" required>
                </div>

                <div class="form-group">
                    <label class="form-label">聯絡電話</label>
                    <input type="test" name="phone" class="form-input" value="<?php echo htmlspecialchars($user['phone']); ?>" required>
                </div>

                <div class="form-group">
                    <label class="form-label">Line ID</label>
                    <input type="text" name="line" class="form-input" value="<?php echo htmlspecialchars($user['line']); ?>">
                </div>

                <!-- 分隔線 -->
                <div class="section-divider">
                    <span class="section-label">變更密碼</span>
                </div>

                <!-- 舊密碼欄位 -->
                <div class="form-group">
                    <label class="form-label">舊密碼 <span style="font-size:0.8em; color:#aaa;">(若不修改密碼請留空)</span></label>
                    <input type="password" name="old_password" class="form-input" placeholder="請輸入目前的密碼">
                </div>

                <!-- 新密碼欄位 -->
                <div class="form-group">
                    <label class="form-label">新密碼</label>
                    <input type="password" name="new_password" class="form-input" placeholder="請輸入想設定的新密碼">
                </div>

                <div class="btn-group">
                    <a href="index.php" class="btn btn-cancel">取消</a>
                    <button type="submit" class="btn btn-save">儲存變更</button>
                </div>

            </form>
        </div>
    </div>
</body>
</html>
