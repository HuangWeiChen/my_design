<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>房東專區 - where is my love </title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@300;400;500&family=Noto+Serif+TC:wght@400;600&display=swap" rel="stylesheet">
    <style>
        /* 保持原有風格設定 */
        :root { --bg-color: #FDFCF8; --text-main: #464646; --text-light: #888888; --accent-color: #7A8B8B; --card-bg: #FFFFFF; --border-color: #ECEBE6; --green-accent: #A8BFA6; --green-hover: #8FA38D; }
        
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Noto Sans TC', sans-serif; background-color: var(--bg-color); color: var(--text-main); line-height: 1.8; display: flex; justify-content: center; align-items: center; min-height: 100vh; padding: 20px; }
        .serif { font-family: 'Noto Serif TC', serif; font-weight: 600; }
        a { text-decoration: none; color: var(--text-main); transition: 0.3s; }

        .back-home { position: absolute; top: 30px; left: 40px; font-size: 0.9rem; color: var(--text-light); }
        .auth-container { background: var(--card-bg); width: 100%; max-width: 450px; padding: 40px; border-radius: 8px; box-shadow: 0 10px 30px rgba(0,0,0,0.03); border: 1px solid var(--border-color); }
        
        .auth-header { text-align: center; margin-bottom: 30px; }
        .logo { font-size: 1.4rem; letter-spacing: 0.2em; margin-bottom: 5px; display: block; }
        .subtitle { font-size: 0.9rem; color: var(--text-light); font-family: 'Noto Serif TC'; }

        .toggle-box { display: flex; border-bottom: 1px solid var(--border-color); margin-bottom: 25px; }
        .toggle-btn { flex: 1; text-align: center; padding: 15px; cursor: pointer; color: var(--text-light); font-family: 'Noto Serif TC'; position: relative; }
        .toggle-btn.active { color: var(--text-main); font-weight: 600; }
        .toggle-btn.active::after { content: ''; position: absolute; bottom: -1px; left: 0; width: 100%; height: 2px; background-color: var(--green-accent); }

        .form-group { margin-bottom: 15px; }
        .form-label { display: block; font-size: 0.85rem; color: var(--text-light); margin-bottom: 5px; }
        .form-input { width: 100%; padding: 10px 12px; border: 1px solid var(--border-color); border-radius: 4px; background-color: #FAFAFA; color: var(--text-main); outline: none; }
        .form-input:focus { border-color: var(--green-accent); background-color: #fff; }
        
        .submit-btn { width: 100%; padding: 12px; background-color: var(--green-accent); color: white; border: none; border-radius: 4px; font-size: 1rem; font-family: 'Noto Serif TC'; letter-spacing: 0.1em; cursor: pointer; margin-top: 10px; }
        .submit-btn:hover { background-color: var(--green-hover); }

        .form-section { display: none; }
        .form-section.active { display: block; animation: fadeIn 0.5s ease; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(5px); } to { opacity: 1; transform: translateY(0); } }
    </style>
</head>
<body>

    <a href="index.php" class="back-home">← 回到where is my love</a>

    <div class="auth-container">
        <div class="auth-header">
            <span class="logo serif">where is my love</span>
            <div class="subtitle">房東專屬通道</div>
        </div>

        <div class="toggle-box">
            <div class="toggle-btn active" onclick="switchTab('login')">登入</div>
            <div class="toggle-btn" onclick="switchTab('register')">註冊</div>
        </div>

        <!-- 登入表單 -->
        <form id="login-form" class="form-section active" action="landlord_action.php" method="POST">
            <input type="hidden" name="action" value="login">
            <div class="form-group">
                <label class="form-label">帳號 (Account)</label>
                <input type="text" name="account" class="form-input" required>
            </div>
            <div class="form-group">
                <label class="form-label">密碼 (Password)</label>
                <input type="password" name="password" class="form-input" required>
            </div>
            <button type="submit" class="submit-btn">登入</button>
        </form>

        <!-- 註冊表單 -->
        <form id="register-form" class="form-section" action="landlord_action.php" method="POST">
            <input type="hidden" name="action" value="register">
            
            <div class="form-group">
                <label class="form-label">設定帳號</label>
                <input type="text" name="account" class="form-input" required placeholder="登入用帳號">
            </div>
            
            <div class="form-group">
                <label class="form-label">設定密碼</label>
                <input type="password" name="password" class="form-input" required>
            </div>

            <div class="form-group">
                <label class="form-label">房東姓名</label>
                <input type="text" name="name" class="form-input" required placeholder="例如：陳先生">
            </div>

            <div class="form-group">
                <label class="form-label">ID</label>
                <input type="number" name="id" class="form-input" required placeholder="例如：8">
            </div>

            <div class="form-group">
                <label class="form-label">聯絡電話</label>
                <!-- type="number" 確保輸入數字，以符合資料庫 INT 格式 -->
                <input type="number" name="phone" class="form-input" required placeholder="0912345678">
            </div>

            <div class="form-group">
                <label class="form-label">Line ID</label>
                <input type="text" name="line" class="form-input" placeholder="方便租客聯繫 (選填)">
            </div>

            <button type="submit" class="submit-btn">註冊房東</button>
        </form>
    </div>

    <script>
        function switchTab(tab) {
            const loginForm = document.getElementById('login-form');
            const registerForm = document.getElementById('register-form');
            const btns = document.querySelectorAll('.toggle-btn');

            if (tab === 'login') {
                loginForm.classList.add('active');
                registerForm.classList.remove('active');
                btns[0].classList.add('active');
                btns[1].classList.remove('active');
            } else {
                loginForm.classList.remove('active');
                registerForm.classList.add('active');
                btns[0].classList.remove('active');
                btns[1].classList.add('active');
            }
        }
    </script>
</body>
</html>
