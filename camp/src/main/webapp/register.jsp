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
}

body {
    margin:0;
    font-family:'Pretendard',sans-serif;
    background: linear-gradient(rgba(0,0,0,0.5),rgba(0,0,0,0.5)),
                url('assets/img/camp1.jpg') center/cover no-repeat;
    display:flex;
    justify-content:center;
    align-items:center;
    min-height:100vh;
}

.register-container {
    background: rgba(255,255,255,0.95);
    border-radius:25px;
    padding:40px;
    width:100%;
    max-width:480px;
}

h2 {
    text-align:center;
    font-weight:800;
    color:var(--primary-green);
    margin-bottom:25px;
}

/* STEP */
.step-box {
    background:#f9faf9;
    border-radius:18px;
    padding:20px;
    margin-bottom:20px;
}

.step-title {
    font-size:14px;
    font-weight:700;
    color:var(--primary-green);
    margin-bottom:15px;
}

/* 공통 */
.form-group {
    margin-bottom:15px;
}

.form-group label {
    font-size:13px;
    font-weight:600;
    margin-bottom:6px;
    display:block;
}

/* 🔥 핵심 통일 */
.input-flex {
    display:flex;
    gap:10px;
}

.input-flex input {
    flex:1;
    height:48px;
    border-radius:12px;
    border:1px solid #ddd;
    padding:0 15px;
}

.input-single {
    width:100%;
    height:48px;
    border-radius:12px;
    border:1px solid #ddd;
    padding:0 15px;
}

/* 버튼 */
.input-flex button {
    width:110px;
    height:48px;
    border-radius:12px;
    background:var(--primary-green);
    color:white;
    border:none;
    font-weight:600;
}

input:disabled {
    background:#f1f3f2;
}

.status {
    font-size:12px;
    margin-top:5px;
}

/* 가입 버튼 */
#btnRegister {
    width:100%;
    height:50px;
    border-radius:12px;
    border:none;
    background:#ccc;
    font-weight:700;
}

#btnRegister:not(:disabled) {
    background:var(--primary-green);
    color:white;
}
</style>
</head>

<body>

<div class="register-container">
<h2>Join Camp Mate</h2>

<form action="register_process.jsp" method="post" onsubmit="return validateBeforeSubmit()">

<input type="hidden" id="emailVerified" name="emailVerified" value="0">
<input type="hidden" id="emailHidden" name="email">

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
<input type="text" id="name" name="name" class="input-single" disabled placeholder="실명 입력">
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

<button type="submit" id="btnRegister" disabled>가입 완료</button>
</div>

</form>
</div>

<script>
let isIdChecked = false;

function resetIdCheck() {
    isIdChecked = false;
    idHelp.innerText = "";
    toggleRegisterBtn();
}

async function sendEmailCode() {
    const email = document.getElementById('email').value.trim();
    if(!email){ alert('이메일 입력'); return; }

    try {
        await fetch('<%=ctx%>/email/send', {
            method:'POST',
            headers:{'Content-Type':'application/x-www-form-urlencoded'},
            body:new URLSearchParams({ email })
        });
        alert('인증코드 발송');
    } catch(e){ alert('오류'); }
}

async function verifyEmailCode() {
    const email = document.getElementById('email').value;
    const code = document.getElementById('emailCode').value;

    try {
        const res = await fetch('<%=ctx%>/email/verify', {
            method:'POST',
            headers:{'Content-Type':'application/x-www-form-urlencoded'},
            body:new URLSearchParams({ email, code })
        });

        const result = await res.json();

        if(result.ok){
            alert('인증 성공');

            emailVerified.value="1";
            emailHidden.value=email;

            ['username','btnCheckDup','password','passwordConfirm','name']
                .forEach(id => document.getElementById(id).disabled=false);

            step2.style.opacity="1";
            step2.style.pointerEvents="auto";

        } else {
            alert('인증 실패');
        }

    } catch(e){ alert('오류'); }
}

async function checkIdDup() {
    const username = document.getElementById('username').value;

    try {
        const res = await fetch('<%=ctx%>/user/checkId?username='+username);
        const result = (await res.text()).trim();

        if(result === 'available'){
            idHelp.innerText='사용 가능';
            idHelp.style.color='green';
            isIdChecked=true;
        }else{
            idHelp.innerText='이미 사용중';
            idHelp.style.color='red';
            isIdChecked=false;
        }

        toggleRegisterBtn();

    } catch(e){ alert('오류'); }
}

function checkPasswordMatch() {
    if(password.value === passwordConfirm.value && password.value.length>=8){
        pwHelp.innerText='일치';
        pwHelp.style.color='green';
    }else{
        pwHelp.innerText='불일치';
        pwHelp.style.color='red';
    }
    toggleRegisterBtn();
}

function toggleRegisterBtn() {
    const isMatch = password.value === passwordConfirm.value;
    const isEmailOk = emailVerified.value === "1";
    btnRegister.disabled = !(isIdChecked && isMatch && isEmailOk);
}

function validateBeforeSubmit(){
    if(!isIdChecked){
        alert('아이디 확인 필요');
        return false;
    }
    return true;
}
</script>

</body>
</html>