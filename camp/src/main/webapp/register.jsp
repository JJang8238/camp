<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<% String ctx = request.getContextPath(); %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Join Camp Mate</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        :root {
            --main-green: #1b4d3e;
            --light-gray: #f8f9fa;
            --error-red: #dc3545;
            --success-green: #28a745;
        }

        body { background-color: var(--light-gray); font-family: 'Noto Sans KR', sans-serif; }
        .signup-container { max-width: 700px; margin: 60px auto; padding: 0 20px; }
        .form-card { background: white; padding: 35px; border-radius: 20px; box-shadow: 0 10px 30px rgba(27, 77, 62, 0.05); margin-bottom: 25px; }
        .form-control { height: 50px; border-radius: 12px; border: 1px solid #e1e1e1; }
        
        /* 🔥 비밀번호 조건부 실시간 색상 */
        .pw-rules { list-style: none; padding: 0; margin-top: 8px; display: flex; gap: 15px; }
        .pw-rules li { font-size: 12px; font-weight: 600; color: #6c757d; transition: 0.3s; }
        .rule-invalid { color: var(--error-red) !important; }
        .rule-valid { color: var(--success-green) !important; }

        .btn-main-solid { background: var(--main-green); color: white; border: none; height: 50px; border-radius: 12px; font-weight: 600; }
        .btn-main-solid:disabled { background: #ccc; }
        .eye-btn { background: transparent; border: 1px solid #e1e1e1; border-left: none; border-top-right-radius: 12px !important; border-bottom-right-radius: 12px !important; color: #777; }
    </style>
</head>
<body>

<div class="signup-container">
    <div class="form-card">
        <h5 class="mb-4">📧 이메일 본인인증</h5>
        <div class="mb-3">
            <label class="form-label">이메일 주소</label>
            <div class="input-group">
                <input type="email" id="email" class="form-control" placeholder="example@mail.com">
                <button class="btn btn-outline-success" type="button" id="btnSendCode" onclick="sendEmailCode()">인증코드 발송</button>
            </div>
        </div>
        <div>
            <label class="form-label">인증코드 입력</label>
            <div class="input-group">
                <input type="text" id="emailCode" class="form-control" maxlength="6" placeholder="코드 6자리">
                <button class="btn btn-main-solid px-4" type="button" onclick="verifyEmailCode()">확인</button>
            </div>
        </div>
    </div>

    <div class="form-card">
        <h5 class="mb-4">✍️ 회원정보 입력</h5>
        <form action="register_process.jsp" method="post" onsubmit="return validateBeforeSubmit();">
            <input type="hidden" id="emailVerified" name="emailVerified" value="0">
            <input type="hidden" id="emailHidden" name="email">

			<div class="mb-4">
                <label class="form-label">이름</label>
                <input type="text" class="form-control" id="name" name="name" disabled placeholder="닉네임을 입력하세요">
            </div>
            <div class="mb-4">
                <label class="form-label">아이디</label>
                <div class="input-group">
                    <input type="text" class="form-control" id="username" name="username" disabled 
                           placeholder="영문/숫자 4~12자" oninput="resetIdCheck()">
                    <button class="btn btn-outline-success" id="btnCheckDup" type="button" disabled onclick="checkIdDup()">중복확인</button>
                </div>
                <div id="idHelp" style="font-size: 12px; margin-top: 5px;"></div>
            </div>

            <div class="mb-4">
                <label class="form-label">비밀번호</label>
                <div class="input-group">
                    <input type="password" class="form-control" id="password" name="password" 
                           disabled placeholder="비밀번호를 입력하세요" oninput="checkPasswordRules()">
                    <button class="btn eye-btn" type="button" onclick="toggleEye('password')">👁</button>
                </div>
                <ul class="pw-rules">
                    <li id="ruleLen">● 8~20자</li>
                    <li id="ruleKinds">● 영문/숫자/특수문자 중 2종 이상</li>
                </ul>
            </div>

            <div class="mb-4">
                <label class="form-label">비밀번호 확인</label>
                <div class="input-group">
                    <input type="password" class="form-control" id="passwordConfirm" 
                           disabled placeholder="한 번 더 입력하세요" oninput="checkPasswordMatch()">
                    <button class="btn eye-btn" type="button" onclick="toggleEye('passwordConfirm')">👁</button>
                </div>
                <div id="pwHelp" style="font-size: 12px; margin-top: 5px;"></div>
            </div>


            <button type="submit" id="btnRegister" class="btn btn-main-solid w-100" disabled>가입 완료하기</button>
        </form>
    </div>
</div>

<script>
    let isIdChecked = false;

    // 아이디 새로 입력 시 상태 초기화 (중복확인 다시 하게끔)
    function resetIdCheck() {
        isIdChecked = false;
        document.getElementById('idHelp').innerText = "";
        toggleRegisterBtn();
    }

    async function sendEmailCode() {
        const email = document.getElementById('email').value.trim();
        if(!email) { alert('이메일을 입력하세요.'); return; }
        try {
            await fetch('<%=ctx%>/email/send', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: new URLSearchParams({ email })
            });
            alert('인증코드가 발송되었습니다.');
        } catch (e) { alert('발송 실패'); }
    }

    async function verifyEmailCode() {
        const email = document.getElementById('email').value;
        const code = document.getElementById('emailCode').value;
        try {
            const res = await fetch('<%=ctx%>/email/verify', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: new URLSearchParams({ email, code })
            });
            const result = await res.json();
            if (result.ok === true) {
                alert('인증에 성공했습니다!');
                document.getElementById('emailVerified').value = "1";
                document.getElementById('emailHidden').value = email;
                ['username', 'btnCheckDup', 'password', 'passwordConfirm', 'name'].forEach(id => {
                    document.getElementById(id).disabled = false;
                });
            } else {
                // 🔥 "코드 불일치" JSON 대신 한글 메시지 출력
                alert('인증번호가 틀립니다. 다시 확인해주세요.');
            }
        } catch (e) { alert('인증 오류'); }
    }

    async function checkIdDup() {
        const username = document.getElementById('username').value.trim();
        const help = document.getElementById('idHelp');
        if(username.length < 4) { alert('4자 이상 입력하세요.'); return; }

        try {
            const res = await fetch('<%=ctx%>/user/checkId?username=' + username);
            const result = (await res.text()).trim();

            // 🔥 서블릿 결과값과 일치하도록 수정
            if(result === 'available') {
                help.innerText = '사용 가능한 아이디입니다.';
                help.style.color = 'var(--success-green)';
                isIdChecked = true;
            } else {
                help.innerText = '이미 사용 중인 아이디입니다.';
                help.style.color = 'var(--error-red)';
                isIdChecked = false;
            }
            toggleRegisterBtn();
        } catch (e) { alert('중복 확인 오류'); }
    }

    function checkPasswordRules() {
        const pw = document.getElementById('password').value;
        const ruleLen = document.getElementById('ruleLen');
        const ruleKinds = document.getElementById('ruleKinds');

        // 🔥 조건 만족 시 초록색, 부족 시 빨간색
        if(pw.length >= 8 && pw.length <= 20) {
            ruleLen.className = 'rule-valid';
        } else {
            ruleLen.className = pw.length > 0 ? 'rule-invalid' : '';
        }

        let kinds = 0;
        if(/[a-zA-Z]/.test(pw)) kinds++;
        if(/[0-9]/.test(pw)) kinds++;
        if(/[^a-zA-Z0-9]/.test(pw)) kinds++;

        if(kinds >= 2) {
            ruleKinds.className = 'rule-valid';
        } else {
            ruleKinds.className = pw.length > 0 ? 'rule-invalid' : '';
        }
        checkPasswordMatch();
        toggleRegisterBtn();
    }

    function checkPasswordMatch() {
        const pw = document.getElementById('password').value;
        const confirm = document.getElementById('passwordConfirm').value;
        const help = document.getElementById('pwHelp');
        if(!confirm) { help.innerText = ''; return; }
        if(pw === confirm) {
            help.innerText = '비밀번호가 일치합니다.';
            help.style.color = 'var(--success-green)';
        } else {
            help.innerText = '비밀번호가 일치하지 않습니다.';
            help.style.color = 'var(--error-red)';
        }
        toggleRegisterBtn();
    }

    function toggleRegisterBtn() {
        const isPwOk = document.getElementById('ruleLen').classList.contains('rule-valid') && 
                       document.getElementById('ruleKinds').classList.contains('rule-valid');
        const isMatch = document.getElementById('password').value === document.getElementById('passwordConfirm').value;
        const isEmailOk = document.getElementById('emailVerified').value === "1";
        
        document.getElementById('btnRegister').disabled = !(isIdChecked && isPwOk && isMatch && isEmailOk);
    }

    function toggleEye(id) {
        const el = document.getElementById(id);
        el.type = el.type === 'password' ? 'text' : 'password';
    }

    function validateBeforeSubmit() {
        if(!isIdChecked) { alert('아이디 중복 확인을 해주세요.'); return false; }
        return true;
    }
</script>
</body>
</html>