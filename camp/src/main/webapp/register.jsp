<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<% String ctx = request.getContextPath(); %>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Camp Mate | Join Us</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
:root {
    --primary-green: #2D5A27;
    --light-green: #f4f8f3;
    --border-color: #dfe5de;
}

body {
    margin: 0;
    font-family: 'Pretendard', sans-serif;
    background:
        linear-gradient(rgba(0,0,0,0.5), rgba(0,0,0,0.5)),
        url('<%=ctx%>/assets/img/camp1.jpg') center/cover no-repeat;
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 100vh;
    padding: 30px 15px;
}

.register-container {
    background: rgba(255,255,255,0.96);
    border-radius: 25px;
    padding: 40px;
    width: 100%;
    max-width: 520px;
    box-shadow: 0 20px 40px rgba(0,0,0,0.15);
}

h2 {
    text-align: center;
    font-weight: 800;
    color: var(--primary-green);
    margin-bottom: 25px;
}

/* 회원 유형 */
.role-select-wrap {
    margin-bottom: 20px;
}

.role-select-title {
    font-size: 14px;
    font-weight: 700;
    color: var(--primary-green);
    margin-bottom: 10px;
}

.role-options {
    display: flex;
    gap: 12px;
}

.role-card {
    flex: 1;
    border: 1px solid var(--border-color);
    border-radius: 16px;
    padding: 16px 12px;
    text-align: center;
    cursor: pointer;
    background: #fff;
    transition: 0.2s ease;
    user-select: none;
}

.role-card input {
    display: none;
}

.role-card.active {
    border: 2px solid var(--primary-green);
    background: var(--light-green);
}

.role-name {
    font-size: 15px;
    font-weight: 700;
    color: #222;
}

.role-desc {
    font-size: 12px;
    color: #666;
    margin-top: 4px;
}

/* STEP */
.step-box {
    background: #f9faf9;
    border-radius: 18px;
    padding: 20px;
    margin-bottom: 20px;
}

.step-title {
    font-size: 14px;
    font-weight: 700;
    color: var(--primary-green);
    margin-bottom: 15px;
}

/* 공통 */
.form-group {
    margin-bottom: 15px;
}

.form-group label {
    font-size: 13px;
    font-weight: 600;
    margin-bottom: 6px;
    display: block;
}

.input-flex {
    display: flex;
    gap: 10px;
}

.input-flex input {
    flex: 1;
    height: 48px;
    border-radius: 12px;
    border: 1px solid #ddd;
    padding: 0 15px;
    outline: none;
}

.input-single {
    width: 100%;
    height: 48px;
    border-radius: 12px;
    border: 1px solid #ddd;
    padding: 0 15px;
    outline: none;
}

textarea.input-single {
    height: 90px;
    padding: 12px 15px;
    resize: none;
}

.input-flex button {
    width: 110px;
    height: 48px;
    border-radius: 12px;
    background: var(--primary-green);
    color: white;
    border: none;
    font-weight: 600;
}

input:disabled,
textarea:disabled {
    background: #f1f3f2;
}

.status {
    font-size: 12px;
    margin-top: 5px;
}

.owner-fields {
    display: none;
}

.owner-fields.show {
    display: block;
}

/* 가입 버튼 */
#btnRegister {
    width: 100%;
    height: 50px;
    border-radius: 12px;
    border: none;
    background: #ccc;
    font-weight: 700;
    transition: 0.2s ease;
}

#btnRegister:not(:disabled) {
    background: var(--primary-green);
    color: white;
}
</style>
</head>

<body>

<div class="register-container">
    <h2>Join Camp Mate</h2>

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
                    <div class="role-name">일반 사용자</div>
                    <div class="role-desc">캠핑장 예약 / 커뮤니티 / 중고거래</div>
                </label>

                <label class="role-card" id="roleOwnerCard" onclick="selectRole('owner')">
                    <input type="radio" name="roleSelect" value="owner">
                    <div class="role-name">캠핑장 사장님</div>
                    <div class="role-desc">캠핑장 등록 / 관리 / 운영</div>
                </label>
            </div>
        </div>

        <!-- STEP1 -->
        <div class="step-box">
            <div class="step-title">STEP 1. 본인 인증</div>

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

        <!-- STEP2 -->
        <div class="step-box" id="step2" style="opacity:0.5; pointer-events:none;">
            <div class="step-title">STEP 2. 정보 입력</div>

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
                <input type="password" id="password" name="password" class="input-single" disabled oninput="checkPasswordMatch()" placeholder="비밀번호 입력">
            </div>

            <div class="form-group">
                <label>비밀번호 확인</label>
                <input type="password" id="passwordConfirm" class="input-single" disabled oninput="checkPasswordMatch()" placeholder="비밀번호 확인">
                <div id="pwHelp" class="status"></div>
            </div>

            <!-- 사장님 전용 -->
            <div id="ownerFields" class="owner-fields">
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

    </form>
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