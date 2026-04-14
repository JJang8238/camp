<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="dao.UserDAO" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    String ctx = request.getContextPath();

    if (userId == null) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String userName = (String) session.getAttribute("userName");
    if (userName == null || userName.trim().isEmpty()) {
        UserDAO uDao = new UserDAO();
        userName = uDao.getNameByUserId(userId);
        if (userName != null) {
            session.setAttribute("userName", userName);
        }
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <title>캠프 메이트 | 고객센터</title>
    <link rel="stylesheet" href="<%=ctx%>/assets/css/cs.css">
    <style>
        /* 모달 스타일 커스텀 */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            background: rgba(0, 0, 0, 0.4);
            backdrop-filter: blur(4px);
            z-index: 9999;
            align-items: center;
            justify-content: center;
        }

        .modal-container {
            background: #fff;
            width: 100%;
            max-width: 440px;
            padding: 32px;
            border-radius: 20px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
            transform: translateY(-20px);
            transition: transform 0.3s ease;
        }

        .modal-overlay.active {
            display: flex;
        }

        .modal-overlay.active .modal-container {
            transform: translateY(0);
        }

        .modal-header { margin-bottom: 24px; }
        .modal-header h5 { font-size: 1.25rem; font-weight: 700; color: #1a1a1a; margin: 0; }

        .modal-body .custom-input {
            width: 100%;
            padding: 12px 16px;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            margin-bottom: 12px;
            font-size: 14px;
            transition: border-color 0.2s;
        }

        .modal-body .custom-input:focus {
            outline: none;
            border-color: #198754;
            box-shadow: 0 0 0 3px rgba(25, 135, 84, 0.1);
        }

        .modal-body textarea.custom-input { height: 160px; resize: none; }

        .modal-footer { display: flex; gap: 8px; justify-content: flex-end; margin-top: 24px; }

        .btn-modal { padding: 10px 24px; border-radius: 8px; font-weight: 600; font-size: 14px; border: none; cursor: pointer; }
        .btn-close-modal { background: #f1f3f5; color: #495057; }
        .btn-submit-modal { background: #198754; color: #fff; }
        .btn-submit-modal:hover { background: #146c43; }
    </style>
</head>
<body>

    <jsp:include page="/include/header.jsp" />

    <main class="cs-page">
        <div class="cs-wrap">
            <section class="cs-hero">
                <div class="cs-eyebrow">Camp Mate Support</div>
                <h1 class="cs-title">고객센터</h1>
                <p class="cs-desc">
                    자주 묻는 질문을 먼저 확인해 보세요. 예약, 후기 작성, 계정 관련 문의를 한눈에 확인할 수 있도록
                    깔끔하게 정리했습니다.
                </p>
            </section>

            <div class="cs-grid">
                <section class="cs-faq-card">
                    <div class="cs-card-head">
                        <h2 class="cs-card-title">자주 묻는 질문</h2>
                        <p class="cs-card-sub">이용 중 많이 찾는 문의를 모아두었습니다.</p>
                    </div>

                    <div class="cs-faq-body">
                        <div class="accordion cs-accordion" id="faqAccordion">
                            <div class="accordion-item">
                                <h2 class="accordion-header" id="faqHeading1">
                                    <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#faq1">
                                        Q. 예약 취소는 어떻게 하나요?
                                    </button>
                                </h2>
                                <div id="faq1" class="accordion-collapse collapse show" data-bs-parent="#faqAccordion">
                                    <div class="accordion-body">마이페이지에서 예약 내역을 확인한 뒤 취소 가능합니다.</div>
                                </div>
                            </div>

                            <div class="accordion-item">
                                <h2 class="accordion-header" id="faqHeading2">
                                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq2">
                                        Q. 캠핑장 후기는 언제 작성할 수 있나요?
                                    </button>
                                </h2>
                                <div id="faq2" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                                    <div class="accordion-body">예약 및 이용이 완료된 후 마이페이지의 '이용 내역'에서 작성하실 수 있습니다.</div>
                                </div>
                            </div>

                            <div class="accordion-item">
                                <h2 class="accordion-header" id="faqHeading3">
                                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq3">
                                        Q. 아이디나 비밀번호를 잊어버렸어요.
                                    </button>
                                </h2>
                                <div id="faq3" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                                    <div class="accordion-body">로그인 페이지 하단의 '아이디/비밀번호 찾기'를 통해 가입하신 이메일로 인증 후 찾으실 수 있습니다.</div>
                                </div>
                            </div>

                            <div class="accordion-item">
                                <h2 class="accordion-header" id="faqHeading4">
                                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq4">
                                        Q. 문의 답변은 얼마나 걸리나요?
                                    </button>
                                </h2>
                                <div id="faq4" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                                    <div class="accordion-body">평일 기준 24시간 이내 답변을 원칙으로 하고 있으나, 문의량이 많을 경우 순차적으로 답변드리고 있습니다.</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>

                <aside class="cs-contact-card">
                    <div class="cs-contact-top">
                        <h2 class="cs-contact-title">추가 문의</h2>
                        <p class="cs-contact-desc">원하는 답변을 찾지 못했다면 아래 안내를 확인한 뒤 메일로 문의할 수 있습니다.</p>
                    </div>

                    <div class="cs-contact-list">
                        <div class="cs-contact-item">
                            <div class="cs-contact-label">운영시간</div>
                            <div class="cs-contact-value"><strong>평일 09:00 - 18:00</strong><br>주말 및 공휴일 제외</div>
                        </div>
                        <div class="cs-contact-item">
                            <div class="cs-contact-label">문의방법</div>
                            <div class="cs-contact-value">support@campmate.com</div>
                        </div>
                    </div>

                    <button type="button" class="cs-contact-action" onclick="openModal()">
                        1:1 메일 문의하기
                    </button>
                    <p class="cs-notice">문의 전 FAQ를 먼저 확인하면 더 빠르게 해결할 수 있습니다.</p>
                </aside>
            </div>
        </div>
    </main>

    <div id="inquiryModal" class="modal-overlay" onclick="handleOverlayClick(event)">
        <div class="modal-container">
            <div class="modal-header">
                <h5>1:1 문의하기</h5>
            </div>
            <div class="modal-body">
                <input type="text" id="title" placeholder="제목을 입력해주세요" class="custom-input">
                <textarea id="content" placeholder="문의하실 내용을 상세히 적어주세요." class="custom-input"></textarea>
            </div>
            <div class="modal-footer">
                <button type="button" onclick="closeModal()" class="btn-modal btn-close-modal">취소</button>
                <button type="button" onclick="submitInquiry()" class="btn-modal btn-submit-modal">전송하기</button>
            </div>
        </div>
    </div>

    <jsp:include page="/include/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script>
    function openModal() {
        const modal = document.getElementById("inquiryModal");
        modal.classList.add("active");
        document.body.style.overflow = "hidden";
    }

    function closeModal() {
        const modal = document.getElementById("inquiryModal");
        modal.classList.remove("active");
        document.body.style.overflow = "auto";
    }

    function handleOverlayClick(e) {
        if (e.target === document.getElementById("inquiryModal")) {
            closeModal();
        }
    }

    async function submitInquiry() {
        const title = document.getElementById("title").value.trim();
        const content = document.getElementById("content").value.trim();

        if (!title || !content) {
            alert("제목과 내용을 모두 입력해주세요.");
            return;
        }

        try {
            const res = await fetch('<%=request.getContextPath()%>/inquiry', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: new URLSearchParams({ title, content })
            });
            const result = await res.json();
            if (result.success) {
                alert("문의가 접수되었습니다.");
                closeModal();
            } else {
                alert("전송 실패");
            }
        } catch (error) {
            alert("오류 발생");
        }
    }
    </script>
</body>
</html>