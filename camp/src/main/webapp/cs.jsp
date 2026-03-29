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
            <button class="accordion-button" type="button"
                    data-bs-toggle="collapse"
                    data-bs-target="#faq1"
                    aria-expanded="false"
                    aria-controls="faq1">
                Q. 예약 취소는 어떻게 하나요?
            </button>
        </h2>
        <div id="faq1" class="accordion-collapse collapse"
             aria-labelledby="faqHeading1">
            <div class="accordion-body">
                마이페이지에서 예약 내역을 확인한 뒤 취소 버튼으로 진행할 수 있습니다.
                취소 가능 여부와 수수료 규정은 각 캠핑장 정책에 따라 달라질 수 있으니 상세 안내를 함께 확인해 주세요.
            </div>
        </div>
    </div>

    <div class="accordion-item">
        <h2 class="accordion-header" id="faqHeading2">
            <button class="accordion-button collapsed" type="button"
                    data-bs-toggle="collapse"
                    data-bs-target="#faq2"
                    aria-expanded="false"
                    aria-controls="faq2">
                Q. 캠핑장 후기는 언제 작성할 수 있나요?
            </button>
        </h2>
        <div id="faq2" class="accordion-collapse collapse"
             aria-labelledby="faqHeading2">
            <div class="accordion-body">
                예약 완료 후 실제 이용이 확인되면 후기 작성이 가능합니다.
                커뮤니티 내 후기 게시판에서 작성할 수 있도록 연결되게 구성하는 방식이 가장 자연스럽습니다.
            </div>
        </div>
    </div>

    <div class="accordion-item">
        <h2 class="accordion-header" id="faqHeading3">
            <button class="accordion-button collapsed" type="button"
                    data-bs-toggle="collapse"
                    data-bs-target="#faq3"
                    aria-expanded="false"
                    aria-controls="faq3">
                Q. 아이디나 비밀번호를 잊어버렸어요.
            </button>
        </h2>
        <div id="faq3" class="accordion-collapse collapse"
             aria-labelledby="faqHeading3">
            <div class="accordion-body">
                로그인 페이지의 아이디/비밀번호 찾기 메뉴에서 가입한 이메일을 통해 확인할 수 있게 연결하면 됩니다.
                아직 해당 기능이 없다면 추후 계정 찾기 페이지를 따로 만드는 것도 좋습니다.
            </div>
        </div>
    </div>

    <div class="accordion-item">
        <h2 class="accordion-header" id="faqHeading4">
            <button class="accordion-button collapsed" type="button"
                    data-bs-toggle="collapse"
                    data-bs-target="#faq4"
                    aria-expanded="false"
                    aria-controls="faq4">
                Q. 문의 답변은 얼마나 걸리나요?
            </button>
        </h2>
        <div id="faq4" class="accordion-collapse collapse"
             aria-labelledby="faqHeading4">
            <div class="accordion-body">
                평일 운영 시간 내 접수된 문의는 순차적으로 확인하는 형태가 무난합니다.
                현재 페이지에서는 운영 시간 안내와 메일 문의 버튼을 분리해 두어 정보가 한쪽으로 몰리지 않게 정리했습니다.
            </div>
        </div>
    </div>
</div>
                    </div>
                </section>

                <aside class="cs-contact-card">
                    <div class="cs-contact-top">
                        
                        <h2 class="cs-contact-title">추가 문의</h2>
                        <p class="cs-contact-desc">
                            원하는 답변을 찾지 못했다면 아래 안내를 확인한 뒤 메일로 문의할 수 있습니다.
                        </p>
                    </div>

                    <div class="cs-contact-list">
                        <div class="cs-contact-item">
                            <div class="cs-contact-label">운영시간</div>
                            <div class="cs-contact-value">
                                <strong>평일 09:00 - 18:00</strong><br>
                                주말 및 공휴일 제외
                            </div>
                        </div>

                        <div class="cs-contact-item">
                            <div class="cs-contact-label">문의방법</div>
                            <div class="cs-contact-value">support@campmate.com</div>
                        </div>

                        <div class="cs-contact-item">
                            <div class="cs-contact-label">안내</div>
                            <div class="cs-contact-value">
                                예약 정보와 계정 정보를 함께 적으면 더 빠르게 확인하기 좋습니다.
                            </div>
                        </div>
                    </div>

                    <button type="button" class="cs-contact-action"
                            onclick="location.href='mailto:support@campmate.com'">
                        1:1 메일 문의하기
                    </button>

                    <p class="cs-notice">문의 전 FAQ를 먼저 확인하면 더 빠르게 해결할 수 있습니다.</p>
                </aside>
            </div>
        </div>
    </main>

    <jsp:include page="/include/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>