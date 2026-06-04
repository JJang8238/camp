<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<% String ctx = request.getContextPath(); %>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Camp Mate | Join Us</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Noto+Serif+KR:wght@400;700&family=Noto+Sans+KR:wght@400;500;700&display=swap" rel="stylesheet">

<style>
:root {
    --forest: #1E3A1A;
    --forest-mid: #2D5A27;
    --forest-light: #4A7C42;
    --moss: #8BAF7C;
    --cream: #F7F4EE;
    --cream-dark: #EDE8DE;
    --sand: #C8B89A;
    --text-main: #1A1A1A;
    --text-muted: #6B6560;
    --border: #D5CFC5;
    --white: #FFFFFF;
    --error: #C0392B;
    --success: #2D7A3E;
}

* { box-sizing: border-box; }

body {
    margin: 0;
    font-family: 'Noto Sans KR', sans-serif;
    background:
        linear-gradient(160deg, rgba(15,25,12,0.72) 0%, rgba(30,58,26,0.55) 100%),
        url('<%=ctx%>/assets/img/camp1.jpg') center/cover no-repeat fixed;
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 40px 16px;
}

/* ── 메인 카드 ── */
.register-container {
    width: 100%;
    max-width: 500px;
    background: var(--white);
    border-radius: 4px;
    overflow: hidden;
    box-shadow: 0 32px 80px rgba(0,0,0,0.35);
}

/* ── 헤더 밴드 ── */
.reg-header {
    background: var(--forest);
    padding: 32px 36px 28px;
    position: relative;
}

.reg-header::after {
    content: '';
    position: absolute;
    bottom: -1px; left: 0; right: 0;
    height: 3px;
    background: linear-gradient(90deg, var(--moss), var(--forest-light), var(--sand));
}

.reg-logo {
    font-family: 'Noto Serif KR', serif;
    font-size: 11px;
    letter-spacing: 0.35em;
    text-transform: uppercase;
    color: var(--moss);
    margin-bottom: 6px;
}

.reg-title {
    font-family: 'Noto Serif KR', serif;
    font-size: 26px;
    font-weight: 700;
    color: var(--white);
    margin: 0;
    line-height: 1.2;
}

.reg-subtitle {
    font-size: 13px;
    color: rgba(255,255,255,0.5);
    margin-top: 6px;
}

/* ── 폼 본문 ── */
.reg-body {
    padding: 32px 36px 36px;
    background: var(--white);
}

/* ── 회원 유형 선택 ── */
.role-select-wrap {
    margin-bottom: 28px;
}

.role-select-title {
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 0.12em;
    text-transform: uppercase;
    color: var(--text-muted);
    margin-bottom: 10px;
}

.role-options {
    display: flex;
    gap: 10px;
}

.role-card {
    flex: 1;
    border: 1.5px solid var(--border);
    border-radius: 3px;
    padding: 14px 12px;
    text-align: left;
    cursor: pointer;
    background: var(--white);
    transition: border-color 0.18s, background 0.18s;
    user-select: none;
    position: relative;
}

.role-card input { display: none; }

.role-card::before {
    content: '';
    position: absolute;
    top: 10px; right: 10px;
    width: 16px; height: 16px;
    border-radius: 50%;
    border: 1.5px solid var(--border);
    transition: 0.18s;
}

.role-card.active {
    border-color: var(--forest-mid);
    background: #F2F6F1;
}

.role-card.active::before {
    background: var(--forest-mid);
    border-color: var(--forest-mid);
    box-shadow: inset 0 0 0 3px #F2F6F1;
}

.role-icon {
    font-size: 20px;
    margin-bottom: 8px;
}

.role-name {
    font-size: 14px;
    font-weight: 700;
    color: var(--text-main);
    margin-bottom: 3px;
}

.role-desc {
    font-size: 11px;
    color: var(--text-muted);
    line-height: 1.5;
}

/* ── STEP 박스 ── */
.step-box {
    margin-bottom: 20px;
    border: 1px solid var(--border);
    border-radius: 3px;
    overflow: hidden;
    transition: opacity 0.25s;
}

.step-header {
    background: var(--cream);
    padding: 12px 18px;
    display: flex;
    align-items: center;
    gap: 10px;
    border-bottom: 1px solid var(--border);
}

.step-badge {
    width: 22px; height: 22px;
    border-radius: 50%;
    background: var(--forest);
    color: var(--white);
    font-size: 11px;
    font-weight: 700;
    display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
}

.step-title {
    font-size: 13px;
    font-weight: 700;
    color: var(--forest);
    letter-spacing: 0.03em;
    margin: 0;
}

.step-inner {
    padding: 20px 18px;
}

/* ── 폼 그룹 ── */
.form-group {
    margin-bottom: 16px;
}

.form-group:last-child { margin-bottom: 0; }

.form-group label {
    display: block;
    font-size: 12px;
    font-weight: 700;
    color: var(--text-muted);
    letter-spacing: 0.08em;
    text-transform: uppercase;
    margin-bottom: 7px;
}

.input-flex {
    display: flex;
    gap: 8px;
}

.input-flex input {
    flex: 1;
    height: 44px;
    border: 1.5px solid var(--border);
    border-radius: 3px;
    padding: 0 14px;
    font-size: 14px;
    font-family: 'Noto Sans KR', sans-serif;
    color: var(--text-main);
    background: var(--white);
    outline: none;
    transition: border-color 0.15s;
}

.input-flex input:focus {
    border-color: var(--forest-mid);
}

.input-single {
    width: 100%;
    height: 44px;
    border: 1.5px solid var(--border);
    border-radius: 3px;
    padding: 0 14px;
    font-size: 14px;
    font-family: 'Noto Sans KR', sans-serif;
    color: var(--text-main);
    background: var(--white);
    outline: none;
    transition: border-color 0.15s;
}

.input-single:focus {
    border-color: var(--forest-mid);
}

textarea.input-single {
    height: 90px;
    padding: 12px 14px;
    resize: none;
}

.input-flex button {
    height: 44px;
    padding: 0 16px;
    border-radius: 3px;
    background: var(--forest);
    color: var(--white);
    border: none;
    font-size: 13px;
    font-weight: 700;
    font-family: 'Noto Sans KR', sans-serif;
    cursor: pointer;
    white-space: nowrap;
    transition: background 0.15s;
    letter-spacing: 0.02em;
}

.input-flex button:hover {
    background: var(--forest-light);
}

.input-flex button:disabled {
    background: var(--border);
    cursor: not-allowed;
    color: var(--text-muted);
}

input:disabled,
textarea:disabled {
    background: var(--cream);
    color: var(--text-muted);
    border-color: var(--cream-dark);
    cursor: not-allowed;
}

.status {
    font-size: 12px;
    margin-top: 5px;
}

/* ── 사장님 전용 필드 ── */
.owner-fields { display: none; }
.owner-fields.show { display: block; }

.owner-divider {
    border: none;
    border-top: 1px dashed var(--border);
    margin: 18px 0;
}

.owner-badge {
    display: inline-block;
    font-size: 10px;
    font-weight: 700;
    letter-spacing: 0.1em;
    text-transform: uppercase;
    background: var(--forest);
    color: var(--white);
    padding: 3px 10px;
    border-radius: 2px;
    margin-bottom: 14px;
}

/* ── 가입 완료 버튼 ── */
#btnRegister {
    width: 100%;
    height: 50px;
    border-radius: 3px;
    border: none;
    background: var(--cream-dark);
    color: var(--text-muted);
    font-size: 15px;
    font-weight: 700;
    font-family: 'Noto Sans KR', sans-serif;
    letter-spacing: 0.05em;
    cursor: not-allowed;
    transition: background 0.2s, color 0.2s;
    margin-top: 4px;
}

#btnRegister:not(:disabled) {
    background: var(--forest);
    color: var(--white);
    cursor: pointer;
}

#btnRegister:not(:disabled):hover {
    background: var(--forest-light);
}

/* ── 하단 로그인 링크 ── */
.reg-footer {
    text-align: center;
    padding: 0 36px 28px;
    font-size: 13px;
    color: var(--text-muted);
}

.reg-footer a {
    color: var(--forest-mid);
    font-weight: 700;
    text-decoration: none;
}

.reg-footer a:hover { text-decoration: underline; }
</style>
</head>

<body>

<div class="register-container">

    <!-- 헤더 -->
    <div class="reg-header">
        <div class="reg-logo">Camp Mate</div>
        <h2 class="reg-title">회원가입</h2>
        <div class="reg-subtitle">자연과 함께하는 캠핑 커뮤니티에 오신 것을 환영합니다</div>
    </div>

    <div class="reg-body">
        <form action="<%=ctx%>/register_process.jsp" method="post" onsubmit="return validateBeforeSubmit()">

            <!-- 숨김값 -->
            <input type="hidden" id="emailVerified" name="emailVerified" value="0">
            <input type="hidden" id="emailHidden" name="email">
            <input type="hidden" id="role" name="role" value="user">

            <!-- 회원 유형 선택 -->
            <div class="role-select-wrap">
                <div class="role-select-title">회원 유형 선택</div>
                <div class="role-options">
                    <label class="role-card active" id="roleUserCard" onclick="selectRole('user')">
                        <input type="radio" name="roleSelect" value="user" checked>
                        <div class="role-icon">🏕️</div>
                        <div class="role-name">일반 사용자</div>
                        <div class="role-desc">캠핑장 예약<br>커뮤니티 / 중고거래</div>
                    </label>

                    <label class="role-card" id="roleOwnerCard" onclick="selectRole('owner')">
                        <input type="radio" name="roleSelect" value="owner">
                        <div class="role-icon">🌲</div>
                        <div class="role-name">캠핑장 사장님</div>
                        <div class="role-desc">캠핑장 등록<br>관리 / 운영</div>
                    </label>
                </div>
            </div>

            <!-- STEP1 -->
            <div class="step-box">
                <div class="step-header">
                    <div class="step-badge">1</div>
                    <div class="step-title">본인 인증</div>
                </div>
                <div class="step-inner">
                    <div class="form-group">
                        <label>이메일 주소</label>
                        <div class="input-flex">
                            <input type="email" id="email" placeholder="example@mail.com">
                            <button type="button" onclick="sendEmailCode()">코드 발송</button>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>인증번호</label>
                        <div class="input-flex">
                            <input type="text" id="emailCode" placeholder="6자리 숫자 입력">
                            <button type="button" onclick="verifyEmailCode()">인증 확인</button>
                        </div>
                    </div>

                    <div id="emailMsg" class="status"></div>
                </div>
            </div>

            <!-- STEP2 -->
            <div class="step-box" id="step2" style="opacity:0.5; pointer-events:none;">
                <div class="step-header">
                    <div class="step-badge">2</div>
                    <div class="step-title">정보 입력</div>
                </div>
                <div class="step-inner">
                    <div class="form-group">
                        <label>이름</label>
                        <input type="text" id="name" name="name" class="input-single" disabled placeholder="이름 입력">
                    </div>

                    <div class="form-group">
                        <label>아이디</label>
                        <div class="input-flex">
                            <input type="text" id="username" name="username" disabled oninput="resetIdCheck()" placeholder="아이디 입력">
                            <button type="button" id="btnCheckDup" disabled onclick="checkIdDup()">중복 확인</button>
                        </div>
                        <div id="idHelp" class="status"></div>
                    </div>

                    <div class="form-group">
                        <label>비밀번호</label>
                        <input type="password" id="password" name="password" class="input-single" disabled oninput="checkPasswordMatch()" placeholder="8자 이상 입력">
                    </div>

                    <div class="form-group">
                        <label>비밀번호 확인</label>
                        <input type="password" id="passwordConfirm" class="input-single" disabled oninput="checkPasswordMatch()" placeholder="비밀번호 재입력">
                        <div id="pwHelp" class="status"></div>
                    </div>

                    <!-- 사장님 전용 -->
                    <div id="ownerFields" class="owner-fields">
                        <hr class="owner-divider">
                        <div class="owner-badge">사업자 정보</div>

                        <div class="form-group">
                            <label>캠핑장명</label>
                            <input type="text" id="campName" name="campName" class="input-single" disabled placeholder="운영 중인 캠핑장명 입력">
                        </div>

                        <div class="form-group">
                            <label>사업자명</label>
                            <input type="text" id="businessName" name="businessName" class="input-single" disabled placeholder="사업자명 입력">
                        </div>

                        <div class="form-group">
                            <label>사업자등록번호</label>
                            <input type="text" id="businessNumber" name="businessNumber" class="input-single" disabled placeholder="숫자만 입력">
                        </div>
                    </div>

                    <button type="submit" id="btnRegister" disabled>가입 완료</button>
                </div>
            </div>

        </form>
    </div>

    <div class="reg-footer">
        이미 계정이 있으신가요? <a href="<%=ctx%>/login.jsp">로그인</a>
    </div>
</div>

<script>
let isIdChecked = false;
let currentRole = "user";

const emailVerified = document.getElementById("emailVerified");
const emailHidden = document.getElementById("emailHidden");
const step2 = document.getElementById("step2");
const idHelp = document.getElementById("idHelp");
const pwHelp = document.getElementById("pwHelp");
const btnRegister = document.getElementById("btnRegister");

const password = document.getElementById("password");
const passwordConfirm = document.getElementById("passwordConfirm");

function selectRole(roleValue) {
    currentRole = roleValue;
    document.getElementById("role").value = roleValue;

    const userCard = document.getElementById("roleUserCard");
    const ownerCard = document.getElementById("roleOwnerCard");
    const ownerFields = document.getElementById("ownerFields");

    userCard.classList.remove("active");
    ownerCard.classList.remove("active");

    if (roleValue === "user") {
        userCard.classList.add("active");
        ownerFields.classList.remove("show");
    } else {
        ownerCard.classList.add("active");
        ownerFields.classList.add("show");
    }

    updateOwnerFieldState();
    toggleRegisterBtn();
}

function updateOwnerFieldState() {
    const isEnabled = emailVerified.value === "1" && currentRole === "owner";

    document.getElementById("campName").disabled = !isEnabled;
    document.getElementById("businessName").disabled = !isEnabled;
    document.getElementById("businessNumber").disabled = !isEnabled;
}

function resetIdCheck() {
    isIdChecked = false;
    idHelp.innerText = "";
    toggleRegisterBtn();
}

async function sendEmailCode() {
    const email = document.getElementById('email').value.trim();

    if (!email) {
        alert('이메일을 입력해주세요.');
        return;
    }

    try {
        const res = await fetch('<%=ctx%>/email/send', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: new URLSearchParams({ email })
        });

        if (res.ok) {
            alert('인증코드를 발송했습니다.');
        } else {
            alert('인증코드 발송에 실패했습니다.');
        }
    } catch (e) {
        alert('오류가 발생했습니다.');
    }
}

async function verifyEmailCode() {
    const email = document.getElementById('email').value.trim();
    const code = document.getElementById('emailCode').value.trim();

    if (!email || !code) {
        alert('이메일과 인증번호를 입력해주세요.');
        return;
    }

    try {
        const res = await fetch('<%=ctx%>/email/verify', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: new URLSearchParams({ email, code })
        });

        const result = await res.json();

        if (result.ok) {
            alert('이메일 인증이 완료되었습니다.');

            emailVerified.value = "1";
            emailHidden.value = email;

            ['username', 'btnCheckDup', 'password', 'passwordConfirm', 'name']
                .forEach(id => document.getElementById(id).disabled = false);

            step2.style.opacity = "1";
            step2.style.pointerEvents = "auto";

            updateOwnerFieldState();
            toggleRegisterBtn();

        } else {
            alert('인증번호가 올바르지 않습니다.');
        }

    } catch (e) {
        alert('오류가 발생했습니다.');
    }
}

async function checkIdDup() {
    const username = document.getElementById('username').value.trim();

    if (!username) {
        alert('아이디를 입력해주세요.');
        return;
    }

    try {
        const res = await fetch('<%=ctx%>/user/checkId?username=' + encodeURIComponent(username));
        const result = (await res.text()).trim();

        if (result === 'available') {
            idHelp.innerText = '사용 가능한 아이디입니다.';
            idHelp.style.color = 'green';
            isIdChecked = true;
        } else {
            idHelp.innerText = '이미 사용 중인 아이디입니다.';
            idHelp.style.color = 'red';
            isIdChecked = false;
        }

        toggleRegisterBtn();

    } catch (e) {
        alert('오류가 발생했습니다.');
    }
}

function checkPasswordMatch() {
    const pw = password.value;
    const pwc = passwordConfirm.value;

    if (pw.length === 0 && pwc.length === 0) {
        pwHelp.innerText = '';
        toggleRegisterBtn();
        return;
    }

    if (pw === pwc && pw.length >= 8) {
        pwHelp.innerText = '비밀번호가 일치합니다.';
        pwHelp.style.color = 'green';
    } else {
        pwHelp.innerText = '비밀번호가 일치하지 않거나 8자 미만입니다.';
        pwHelp.style.color = 'red';
    }

    toggleRegisterBtn();
}

function isOwnerFieldsValid() {
    if (currentRole !== "owner") return true;

    const campName = document.getElementById("campName").value.trim();
    const businessName = document.getElementById("businessName").value.trim();
    const businessNumber = document.getElementById("businessNumber").value.trim();

    return campName !== "" && businessName !== "" && businessNumber !== "";
}

function toggleRegisterBtn() {
    const isMatch = password.value === passwordConfirm.value && password.value.length >= 8;
    const isEmailOk = emailVerified.value === "1";
    const isOwnerOk = isOwnerFieldsValid();

    btnRegister.disabled = !(isIdChecked && isMatch && isEmailOk && isOwnerOk);
}

function validateBeforeSubmit() {
    if (emailVerified.value !== "1") {
        alert("이메일 인증이 필요합니다.");
        return false;
    }

    if (!isIdChecked) {
        alert("아이디 중복 확인이 필요합니다.");
        return false;
    }

    if (!(password.value === passwordConfirm.value && password.value.length >= 8)) {
        alert("비밀번호를 다시 확인해주세요.");
        return false;
    }

    if (currentRole === "owner") {
        const campName = document.getElementById("campName").value.trim();
        const businessName = document.getElementById("businessName").value.trim();
        const businessNumber = document.getElementById("businessNumber").value.trim();

        if (!campName || !businessName || !businessNumber) {
            alert("사장님 회원은 캠핑장 정보와 사업자 정보를 모두 입력해야 합니다.");
            return false;
        }
    }

    return true;
}
</script>

</body>
</html>
