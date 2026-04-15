<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.InquiryDAO" %>
<%@ page import="java.util.*" %>

<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    Integer adminUserId = (Integer) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");

    if (adminUserId == null || role == null || !"admin".equals(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    InquiryDAO dao = new InquiryDAO();
    List<Map<String,String>> list = dao.getAllInquiry();
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <title>캠프 메이트 관리자 | 문의 관리</title>
    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/admin.css">
    <style>
        /* 모달 세부 UX 디자인 */
        .modal-overlay {
            display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.4); backdrop-filter: blur(4px); z-index: 9999;
            align-items: center; justify-content: center;
        }
        .modal-overlay.active { display: flex; }
        
        .modal-container {
            background: #fff; width: 520px; padding: 35px; border-radius: 20px;
            box-shadow: 0 15px 40px rgba(0,0,0,0.15); transform: translateY(-20px); transition: 0.3s;
        }
        .modal-overlay.active .modal-container { transform: translateY(0); }

        .modal-header h3 { font-size: 22px; font-weight: 700; color: #1a372a; margin-bottom: 25px; border-bottom: 1px solid #eee; padding-bottom: 15px; }
        
        .info-label { font-size: 13px; color: #666; margin-bottom: 8px; display: block; font-weight: 600; }
        .inquiry-box { 
            background: #f8f9fa; padding: 20px; border-radius: 12px; 
            font-size: 14px; line-height: 1.6; color: #333; margin-bottom: 25px;
            border: 1px solid #eee; max-height: 150px; overflow-y: auto;
        }

        .reply-textarea { 
            width: 100%; padding: 15px; border: 2px solid #eef0f2; border-radius: 12px;
            font-size: 14px; height: 130px; resize: none; transition: 0.2s; background: #fff;
        }
        .reply-textarea:focus { outline: none; border-color: #1a372a; box-shadow: 0 0 0 4px rgba(26, 55, 42, 0.05); }

        .modal-footer { display: flex; gap: 12px; margin-top: 30px; }
        .m-btn { flex: 1; padding: 14px; border-radius: 10px; font-weight: 600; font-size: 14px; cursor: pointer; border: none; }
        .btn-cancel { background: #f1f3f5; color: #495057; }
        .btn-submit { background: #1a372a; color: #fff; }
        .btn-submit:hover { background: #142b21; }

        /* 테이블 정렬 및 디자인 보정 */
        .admin-table th, .admin-table td { vertical-align: middle; }
        .text-left { text-align: left !important; padding-left: 20px !important; }
    </style>
</head>

<body class="admin-body">

<jsp:include page="/admin/include/adminHeader.jsp" />

<div class="admin-layout">
    <jsp:include page="/admin/include/adminSidebar.jsp" />

    <main class="admin-content">
        <div class="admin-page-head">
            <div>
                <h1 class="admin-page-title">문의 관리</h1>
                <p class="admin-page-desc">고객센터를 통해 접수된 1:1 문의를 관리합니다.</p>
            </div>
        </div>

        <section class="admin-table-wrap">
            <div class="admin-table-top">
                <div class="admin-table-title">문의 내역</div>
                <div class="admin-table-count">총 <strong><%= list.size() %></strong>건</div>
            </div>

            <div class="admin-table-scroll">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th style="width: 80px;">번호</th>
                            <th style="width: 120px;">작성자</th>
                            <th>문의 제목</th>
                            <th style="width: 150px;">상태</th>
                            <th style="width: 180px;">작성일</th>
                            <th style="width: 120px;">관리</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% if (list == null || list.isEmpty()) { %>
                        <tr>
                            <td colspan="6"><div class="admin-empty-inline">접수된 문의 내역이 없습니다.</div></td>
                        </tr>
                    <% } else {
                        for (Map<String,String> i : list) {
                    %>
                        <tr>
                            <td><%= i.get("id") %></td>
                            <td><strong><%= i.get("username") %></strong></td>
                            <td class="text-left"><%= i.get("title") %></td>
                            <td>
                                <span class="admin-badge <%= "완료".equals(i.get("status")) ? "admin-badge-active" : "admin-badge-warn" %>">
                                    <%= i.get("status") %>
                                </span>
                            </td>
                            <td><%= i.get("created_at") != null ? i.get("created_at") : "-" %></td>
                            <td>
                                <button class="admin-btn" onclick="openInquiry('<%=i.get("id")%>')">상세보기</button>
                            </td>
                        </tr>
                    <% } } %>
                    </tbody>
                </table>
            </div>
        </section>
    </main>
</div>

<div id="modal" class="modal-overlay" onclick="handleOverlayClick(event)">
    <div class="modal-container">
        <div class="modal-header">
            <h3>문의 상세 및 답변</h3>
        </div>

        <div class="modal-body">
            <span class="info-label">문의 제목</span>
            <div id="mTitle" style="font-weight: 700; margin-bottom: 15px; color: #333;"></div>
            
            <span class="info-label">고객 문의 내용</span>
            <div id="mContent" class="inquiry-box"></div>

            <span class="info-label">관리자 답변 작성</span>
            <textarea id="reply" class="reply-textarea" placeholder="답변 내용을 상세히 입력해주세요."></textarea>
        </div>

        <div class="modal-footer">
            <button type="button" class="m-btn btn-cancel" onclick="closeModal()">취소</button>
            <button type="button" class="m-btn btn-submit" onclick="sendReply()">답변 등록</button>
        </div>
    </div>
</div>

<script>
let currentId = null;

// 모달 열기 및 데이터 Fetch
async function openInquiry(id) {
    currentId = id;
    try {
        const res = await fetch('<%=ctx%>/admin/inquiryDetail?id=' + id);
        const data = await res.json();

        document.getElementById("mTitle").innerText = data.title;
        document.getElementById("mContent").innerText = data.content;
        document.getElementById("reply").value = ""; // 입력창 초기화

        document.getElementById("modal").classList.add("active");
        document.body.style.overflow = 'hidden';
    } catch (e) {
        alert("데이터를 가져오는 중 오류가 발생했습니다.");
    }
}

// 모달 닫기
function closeModal() {
    document.getElementById("modal").classList.remove("active");
    document.body.style.overflow = 'auto';
}

// 바깥 영역 클릭 시 닫기
function handleOverlayClick(e) {
    if(e.target.id === 'modal') closeModal();
}

// 답변 등록 처리
async function sendReply() {
    const replyValue = document.getElementById("reply").value;
    
    if(!replyValue.trim()) {
        alert("답변 내용을 입력해주세요.");
        return;
    }

    try {
        const res = await fetch('<%=ctx%>/admin/inquiryReply', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: new URLSearchParams({
                id: currentId,
                reply: replyValue
            })
        });

        const result = await res.json();

        if(result.success) {
            alert("답변이 성공적으로 등록되었습니다.");
            location.reload();
        } else {
            alert("답변 등록에 실패했습니다. 다시 시도해주세요.");
        }
    } catch (e) {
        alert("서버 통신 중 오류가 발생했습니다.");
    }
}
</script>

</body>
</html>