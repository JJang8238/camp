<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.ReservationDAO, dto.ReservationDTO, java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    Integer adminId = (Integer) session.getAttribute("userId");
    String  role    = (String)  session.getAttribute("role");

    if (adminId == null || !"admin".equals(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String idStr = request.getParameter("id");
    if (idStr == null) {
        response.sendRedirect(ctx + "/admin/reservations.jsp");
        return;
    }

    int reservationId;
    try { reservationId = Integer.parseInt(idStr); }
    catch (NumberFormatException e) {
        response.sendRedirect(ctx + "/admin/reservations.jsp");
        return;
    }

    ReservationDTO r = ReservationDAO.getReservationById(reservationId);
    if (r == null) {
        response.sendRedirect(ctx + "/admin/reservations.jsp");
        return;
    }

    // 고객 이메일 조회
    String guestEmail = ReservationDAO.getGuestEmail(reservationId);
    if (guestEmail == null) guestEmail = "";

    // 처리 결과 메시지
    String result = request.getParameter("result");

    // 상태 라벨 / 배지
    String st = r.getStatus() != null ? r.getStatus() : "";
    String statusLabel = "reserved".equals(st) || "pending".equals(st) ? "승인 대기"
                       : "approved".equals(st)  ? "예약 확정"
                       : "rejected".equals(st)  ? "거절됨"
                       : "cancelled".equals(st) ? "취소됨"
                       : "completed".equals(st) ? "이용 완료"
                       : st;
    String statusColor = "reserved".equals(st) || "pending".equals(st) ? "#f57f17"
                       : "approved".equals(st)  ? "#2d5a27"
                       : "rejected".equals(st)  ? "#c0392b"
                       : "cancelled".equals(st) ? "#c0392b"
                       : "completed".equals(st) ? "#1565c0"
                       : "#555";
    String statusBg   = "reserved".equals(st) || "pending".equals(st) ? "#fff8e1"
                       : "approved".equals(st)  ? "#e8f5e9"
                       : "rejected".equals(st)  ? "#fdecea"
                       : "cancelled".equals(st) ? "#fdecea"
                       : "completed".equals(st) ? "#e3f2fd"
                       : "#f1f3f5";

    boolean canApprove  = "reserved".equals(st) || "pending".equals(st);
    boolean canReject   = "reserved".equals(st) || "pending".equals(st);
    boolean canCancel   = !"cancelled".equals(st) && !"completed".equals(st) && !"rejected".equals(st);
    boolean canComplete = "approved".equals(st);

    // 박수 계산
    int nights = 0;
    if (r.getCheckIn() != null && r.getCheckOut() != null
            && !r.getCheckIn().isEmpty() && !r.getCheckOut().isEmpty()) {
        try {
            java.time.LocalDate dateIn  = java.time.LocalDate.parse(r.getCheckIn());
            java.time.LocalDate dateOut = java.time.LocalDate.parse(r.getCheckOut());
            nights = (int) java.time.temporal.ChronoUnit.DAYS.between(dateIn, dateOut);
        } catch (Exception ignored) {}
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <title>예약 상세 | 캠프 메이트 관리자</title>
    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/admin.css">
    <style>
        .detail-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 24px;
        }
        @media (max-width: 768px) { .detail-grid { grid-template-columns: 1fr; } }

        .detail-card {
            background: #fff;
            border: 1.5px solid #e9ecef;
            border-radius: 14px;
            padding: 24px;
        }
        .detail-card h3 {
            font-size: 14px;
            font-weight: 700;
            color: #888;
            letter-spacing: 0.5px;
            text-transform: uppercase;
            margin: 0 0 16px;
            padding-bottom: 10px;
            border-bottom: 1px solid #f0f0f0;
        }
        .detail-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 8px 0;
            border-bottom: 1px solid #f8f9fa;
            font-size: 14px;
        }
        .detail-row:last-child { border-bottom: none; }
        .detail-label { color: #888; font-weight: 500; }
        .detail-value { color: #1a1a1a; font-weight: 600; text-align: right; }

        .status-badge-large {
            display: inline-block;
            padding: 6px 18px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 700;
        }

        .action-bar {
            background: #fff;
            border: 1.5px solid #e9ecef;
            border-radius: 14px;
            padding: 20px 24px;
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            margin-bottom: 24px;
        }
        .action-bar-title {
            font-size: 14px;
            font-weight: 700;
            color: #333;
            margin-right: auto;
        }

        .btn-action {
            padding: 10px 20px;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 700;
            border: none;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: opacity 0.2s, transform 0.1s;
        }
        .btn-action:hover { opacity: 0.85; transform: translateY(-1px); }
        .btn-approve  { background: #2d5a27; color: #fff; }
        .btn-reject   { background: #e67e22; color: #fff; }
        .btn-cancel   { background: #e74c3c; color: #fff; }
        .btn-complete { background: #1565c0; color: #fff; }
        .btn-email    { background: #f8f9fa; color: #333; border: 1.5px solid #dee2e6; }

        .contact-card {
            background: #f0f8f2;
            border: 1.5px solid #c8e6c9;
            border-radius: 14px;
            padding: 20px 24px;
            margin-bottom: 24px;
        }
        .contact-card h3 {
            font-size: 15px;
            font-weight: 700;
            color: #2d5a27;
            margin: 0 0 14px;
        }
        .email-row {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }
        .email-val {
            font-size: 15px;
            font-weight: 600;
            color: #1a1a1a;
            flex: 1;
        }
        .btn-copy {
            padding: 7px 16px;
            background: #2d5a27;
            color: #fff;
            border: none;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.2s;
        }
        .btn-copy:hover { background: #1e3d1b; }
        .btn-mailto {
            padding: 7px 16px;
            background: #fff;
            color: #2d5a27;
            border: 1.5px solid #2d5a27;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 600;
            text-decoration: none;
            transition: background 0.2s;
        }
        .btn-mailto:hover { background: #f0f8f2; }

        .email-template {
            margin-top: 14px;
            background: #fff;
            border-radius: 10px;
            padding: 14px 16px;
            font-size: 13px;
            color: #555;
            line-height: 1.7;
            border: 1px solid #c8e6c9;
        }
        .email-template select {
            width: 100%;
            padding: 8px 10px;
            border-radius: 8px;
            border: 1px solid #ddd;
            font-size: 13px;
            margin-bottom: 10px;
            background: #f8f9fa;
        }
        .email-template textarea {
            width: 100%;
            min-height: 100px;
            border-radius: 8px;
            border: 1px solid #ddd;
            font-size: 13px;
            padding: 10px;
            resize: vertical;
            box-sizing: border-box;
            font-family: inherit;
        }

        .alert-box {
            padding: 12px 18px;
            border-radius: 10px;
            margin-bottom: 18px;
            font-size: 14px;
            font-weight: 500;
        }
        .alert-success { background: #d1fae5; color: #065f46; border: 1px solid #6ee7b7; }
        .alert-error   { background: #fee2e2; color: #991b1b; border: 1px solid #fca5a5; }

        .amount-highlight {
            font-size: 22px;
            font-weight: 800;
            color: #2d5a27;
        }
        .nights-badge {
            display: inline-block;
            background: #e8f5e9;
            color: #2d5a27;
            font-size: 12px;
            font-weight: 700;
            padding: 3px 10px;
            border-radius: 20px;
            margin-left: 8px;
        }
    </style>
</head>
<body class="admin-body">

<jsp:include page="/admin/include/adminHeader.jsp" />

<div class="admin-layout">
    <jsp:include page="/admin/include/adminSidebar.jsp" />

    <main class="admin-content">

        <!-- 헤더 -->
        <div class="admin-page-head">
            <div>
                <h1 class="admin-page-title">예약 상세 <span style="font-size:16px; color:#aaa;">#<%= reservationId %></span></h1>
                <p class="admin-page-desc">예약 정보를 확인하고 승인/거절/취소 처리를 합니다.</p>
            </div>
            <a href="<%=ctx%>/admin/reservations.jsp" class="admin-btn admin-btn-outline">← 목록으로</a>
        </div>

        <!-- 처리 결과 알림 -->
        <% if ("approve".equals(result)) { %>
            <div class="alert-box alert-success">✅ 예약이 승인되었습니다.</div>
        <% } else if ("reject".equals(result)) { %>
            <div class="alert-box alert-success">🚫 예약이 거절되었습니다.</div>
        <% } else if ("cancel".equals(result)) { %>
            <div class="alert-box alert-success">❌ 예약이 취소 처리되었습니다.</div>
        <% } else if ("complete".equals(result)) { %>
            <div class="alert-box alert-success">🎉 이용 완료 처리되었습니다.</div>
        <% } else if ("error".equals(result)) { %>
            <div class="alert-box alert-error">⚠️ 처리 중 오류가 발생했습니다.</div>
        <% } %>

        <!-- 액션 버튼 바 -->
        <div class="action-bar">
            <span class="action-bar-title">예약 처리</span>

            <% if (canApprove) { %>
            <a href="<%=ctx%>/admin/reservationAction.jsp?id=<%=reservationId%>&action=approve&referer=detail"
               class="btn-action btn-approve"
               onclick="return confirm('이 예약을 승인하시겠습니까?')">✅ 승인</a>
            <% } %>

            <% if (canReject) { %>
            <a href="<%=ctx%>/admin/reservationAction.jsp?id=<%=reservationId%>&action=reject&referer=detail"
               class="btn-action btn-reject"
               onclick="return confirm('이 예약을 거절하시겠습니까?')">🚫 거절</a>
            <% } %>

            <% if (canComplete) { %>
            <a href="<%=ctx%>/admin/reservationAction.jsp?id=<%=reservationId%>&action=complete&referer=detail"
               class="btn-action btn-complete"
               onclick="return confirm('이용 완료 처리하시겠습니까?')">🎉 이용 완료</a>
            <% } %>

            <% if (canCancel) { %>
            <a href="<%=ctx%>/admin/reservationAction.jsp?id=<%=reservationId%>&action=cancel&referer=detail"
               class="btn-action btn-cancel"
               onclick="return confirm('이 예약을 취소하시겠습니까?\n취소 후 되돌릴 수 없습니다.')">❌ 취소</a>
            <% } %>
        </div>

        <!-- 상세 정보 그리드 -->
        <div class="detail-grid">

            <!-- 예약 정보 -->
            <div class="detail-card">
                <h3>📋 예약 정보</h3>
                <div class="detail-row">
                    <span class="detail-label">예약 번호</span>
                    <span class="detail-value">#<%= r.getId() %></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">캠핑장</span>
                    <span class="detail-value"><%= r.getCampName() != null ? r.getCampName() : "-" %></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">체크인</span>
                    <span class="detail-value"><%= r.getCheckIn() != null && !r.getCheckIn().isEmpty() ? r.getCheckIn() : (r.getReserveDate() != null ? r.getReserveDate() : "-") %></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">체크아웃</span>
                    <span class="detail-value"><%= r.getCheckOut() != null && !r.getCheckOut().isEmpty() ? r.getCheckOut() : "-" %></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">숙박</span>
                    <span class="detail-value"><%= nights > 0 ? nights + "박" : "-" %></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">인원</span>
                    <span class="detail-value"><%= r.getPeopleCount() %>명</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">상태</span>
                    <span class="detail-value">
                        <span class="status-badge-large"
                              style="background:<%=statusBg%>; color:<%=statusColor%>;">
                            <%= statusLabel %>
                        </span>
                    </span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">예약 등록일</span>
                    <span class="detail-value">
                        <%= r.getCreatedAt() != null ? r.getCreatedAt().toString().substring(0, 16) : "-" %>
                    </span>
                </div>
            </div>

            <!-- 결제 정보 -->
            <div class="detail-card">
                <h3>💳 결제 정보</h3>
                <div class="detail-row">
                    <span class="detail-label">결제 금액</span>
                    <span class="detail-value">
                        <span class="amount-highlight">
                            <%= r.getAmount() > 0 ? String.format("%,d", r.getAmount()) + "원" : "미결제" %>
                        </span>
                        <% if (nights > 0) { %>
                        <span class="nights-badge"><%= nights %>박</span>
                        <% } %>
                    </span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">주문 번호</span>
                    <span class="detail-value" style="font-size:12px; color:#888;">
                        <%= r.getOrderId() != null && !r.getOrderId().isEmpty() ? r.getOrderId() : "-" %>
                    </span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">결제 키</span>
                    <span class="detail-value" style="font-size:11px; color:#aaa; word-break:break-all; max-width:220px;">
                        <%= r.getPaymentKey() != null && !r.getPaymentKey().isEmpty() ? r.getPaymentKey() : "-" %>
                    </span>
                </div>

                <h3 style="margin-top:20px;">👤 예약자 정보</h3>
                <div class="detail-row">
                    <span class="detail-label">이름</span>
                    <span class="detail-value"><%= r.getGuestName() != null ? r.getGuestName() : "-" %></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">아이디</span>
                    <span class="detail-value" style="color:#888;">
                        <!-- username은 getOrderId 임시 활용 대신 별도 필드 권장 -->
                        user_id: <%= r.getUserId() %>
                    </span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">이메일</span>
                    <span class="detail-value" style="font-size:13px;">
                        <%= !guestEmail.isEmpty() ? guestEmail : "정보 없음" %>
                    </span>
                </div>
            </div>
        </div>

        <!-- 고객 연락 -->
        <% if (!guestEmail.isEmpty()) { %>
        <div class="contact-card">
            <h3>📧 고객 연락</h3>
            <div class="email-row">
                <span class="email-val"><%= guestEmail %></span>
                <button class="btn-copy" onclick="copyEmail('<%=guestEmail%>')">이메일 복사</button>
                <a href="mailto:<%=guestEmail%>?subject=[캠프메이트] 예약 #<%=reservationId%> 안내"
                   class="btn-mailto">메일 보내기</a>
            </div>

            <!-- 이메일 템플릿 -->
            <div class="email-template">
                <select id="templateSelect" onchange="applyTemplate()">
                    <option value="">-- 이메일 템플릿 선택 --</option>
                    <option value="approve">✅ 예약 승인 안내</option>
                    <option value="reject">🚫 예약 거절 안내</option>
                    <option value="remind">📅 체크인 일정 안내</option>
                    <option value="cancel">❌ 예약 취소 안내</option>
                </select>
                <textarea id="emailBody" placeholder="이메일 내용을 작성하거나 템플릿을 선택하세요."></textarea>
                <div style="margin-top:8px; display:flex; gap:8px; justify-content:flex-end;">
                    <button class="btn-copy" onclick="copyEmailBody()">내용 복사</button>
                    <a id="mailtoBtn"
                       href="mailto:<%=guestEmail%>?subject=[캠프메이트] 예약 안내"
                       class="btn-mailto" style="padding:7px 16px;">
                       메일 앱으로 열기
                    </a>
                </div>
            </div>
        </div>
        <% } %>

    </main>
</div>

<script>
const campName    = "<%= r.getCampName() != null ? r.getCampName().replace("\"","\\\"") : "" %>";
const checkIn     = "<%= r.getCheckIn()  != null ? r.getCheckIn()  : "" %>";
const checkOut    = "<%= r.getCheckOut() != null ? r.getCheckOut() : "" %>";
const guestName   = "<%= r.getGuestName() != null ? r.getGuestName().replace("\"","\\\"") : "고객" %>";
const reservId    = "<%= reservationId %>";
const guestEmail  = "<%= guestEmail %>";

const templates = {
    approve: `안녕하세요, ${guestName}님.\n\n[캠프메이트] ${campName} 예약이 확정되었습니다.\n\n▶ 체크인: ${checkIn}\n▶ 체크아웃: ${checkOut}\n\n예약 번호: #${reservId}\n\n즐거운 캠핑 되세요! 🏕️\n\n감사합니다.\n캠프메이트 운영팀`,
    reject:  `안녕하세요, ${guestName}님.\n\n죄송합니다. ${campName} 예약(#${reservId})이 아래 사유로 수락이 어렵게 되었습니다.\n\n▶ 체크인: ${checkIn}\n▶ 체크아웃: ${checkOut}\n\n사유: (직접 입력해주세요)\n\n더 좋은 캠핑장을 찾아드릴 수 있도록 노력하겠습니다.\n\n감사합니다.\n캠프메이트 운영팀`,
    remind:  `안녕하세요, ${guestName}님.\n\n곧 체크인 날짜가 다가왔습니다! 🏕️\n\n▶ 캠핑장: ${campName}\n▶ 체크인: ${checkIn}\n▶ 체크아웃: ${checkOut}\n\n즐거운 캠핑 되세요!\n\n감사합니다.\n캠프메이트 운영팀`,
    cancel:  `안녕하세요, ${guestName}님.\n\n${campName} 예약(#${reservId})이 취소 처리되었습니다.\n\n▶ 체크인: ${checkIn}\n▶ 체크아웃: ${checkOut}\n\n결제 금액은 영업일 기준 3~5일 이내 환불됩니다.\n\n불편을 드려 죄송합니다.\n\n감사합니다.\n캠프메이트 운영팀`
};

function applyTemplate() {
    const key = document.getElementById("templateSelect").value;
    if (!key) return;
    const body = document.getElementById("emailBody");
    body.value = templates[key];

    const subjects = {
        approve: "[캠프메이트] 예약이 확정되었습니다 - " + campName,
        reject:  "[캠프메이트] 예약 거절 안내 - " + campName,
        remind:  "[캠프메이트] 체크인 일정 안내 - " + campName,
        cancel:  "[캠프메이트] 예약 취소 안내 - " + campName
    };
    const mailtoBtn = document.getElementById("mailtoBtn");
    mailtoBtn.href = "mailto:" + guestEmail
                  + "?subject=" + encodeURIComponent(subjects[key])
                  + "&body="    + encodeURIComponent(body.value);
}

function copyEmail(email) {
    navigator.clipboard.writeText(email)
        .then(() => alert("이메일 주소가 복사되었습니다!\n" + email))
        .catch(() => {
            const ta = document.createElement("textarea");
            ta.value = email;
            document.body.appendChild(ta);
            ta.select();
            document.execCommand("copy");
            document.body.removeChild(ta);
            alert("이메일 주소가 복사되었습니다!\n" + email);
        });
}

function copyEmailBody() {
    const body = document.getElementById("emailBody").value;
    if (!body.trim()) { alert("내용을 입력하거나 템플릿을 선택해주세요."); return; }
    navigator.clipboard.writeText(body)
        .then(() => alert("내용이 복사되었습니다!"))
        .catch(() => {
            const ta = document.createElement("textarea");
            ta.value = body;
            document.body.appendChild(ta);
            ta.select();
            document.execCommand("copy");
            document.body.removeChild(ta);
            alert("내용이 복사되었습니다!");
        });
}
</script>

</body>
</html>
