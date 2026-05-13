<%--
    include/reportModal.jsp
    사용법: <jsp:include page="/include/reportModal.jsp" />
    신고 버튼:
        <button onclick="openReportModal('review', 42, location.href)">신고</button>
        <button onclick="openReportModal('product', 7, location.href)">신고</button>
        <button onclick="openReportModal('post', 15, location.href)">신고</button>
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String _ctx = request.getContextPath();
    // URL 파라미터로 신고 결과 토스트 제어
    String _reportResult = request.getParameter("reportResult");
%>

<%-- 신고 모달 --%>
<div class="modal-overlay" id="reportModal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.45); z-index:2000; align-items:center; justify-content:center;">
    <div style="background:white; border-radius:16px; padding:32px 28px; width:100%; max-width:420px; box-shadow:0 12px 40px rgba(0,0,0,0.18);">
        <div style="font-size:17px; font-weight:700; margin-bottom:18px; color:#1a1a1a;">🚨 신고하기</div>

        <form method="post" action="<%=_ctx%>/report" id="reportForm">
            <input type="hidden" name="targetType" id="reportTargetType">
            <input type="hidden" name="targetId"   id="reportTargetId">
            <input type="hidden" name="redirectUrl" id="reportRedirectUrl">

            <div style="font-size:13px; font-weight:600; color:#555; margin-bottom:8px;">신고 사유를 선택해주세요</div>

            <div style="display:flex; flex-direction:column; gap:8px; margin-bottom:14px;">
                <% String[] reasons = {"스팸/도배", "욕설/혐오 표현", "허위 정보", "음란물/성적 콘텐츠", "개인정보 노출", "기타"}; %>
                <% for (String rn : reasons) { %>
                <label style="display:flex; align-items:center; gap:8px; font-size:14px; cursor:pointer; padding:8px 12px; border:1.5px solid #e9ecef; border-radius:8px; transition:border-color .2s;"
                       onmouseover="this.style.borderColor='#2d5a27'" onmouseout="this.style.borderColor='#e9ecef'">
                    <input type="radio" name="reason" value="<%=rn%>" required style="accent-color:#2d5a27;">
                    <%=rn%>
                </label>
                <% } %>
            </div>

            <div id="etcWrap" style="display:none; margin-bottom:14px;">
                <textarea name="etcReason" id="etcReason"
                          placeholder="구체적인 사유를 입력해 주세요. (선택)"
                          style="width:100%; height:80px; border:1.5px solid #dee2e6; border-radius:8px; padding:10px 14px; font-size:13px; resize:vertical; box-sizing:border-box; outline:none;"
                          onfocus="this.style.borderColor='#2d5a27'" onblur="this.style.borderColor='#dee2e6'"></textarea>
            </div>

            <div style="display:flex; gap:10px; margin-top:4px;">
                <button type="button"
                        style="flex:1; padding:10px; border:1.5px solid #dee2e6; border-radius:8px; background:white; font-size:14px; font-weight:600; cursor:pointer; color:#555;"
                        onclick="closeReportModal()">취소</button>
                <button type="submit"
                        style="flex:2; padding:10px; border:none; border-radius:8px; background:#e74c3c; color:white; font-size:14px; font-weight:600; cursor:pointer;"
                        onmouseover="this.style.background='#c0392b'" onmouseout="this.style.background='#e74c3c'">
                    신고 접수
                </button>
            </div>
        </form>
    </div>
</div>

<%-- 결과 토스트 --%>
<% if ("ok".equals(_reportResult)) { %>
<div id="reportToast" style="position:fixed; bottom:30px; left:50%; transform:translateX(-50%); background:#2d5a27; color:white; padding:12px 24px; border-radius:24px; font-size:14px; font-weight:600; z-index:3000; box-shadow:0 4px 16px rgba(0,0,0,0.2);">
    ✅ 신고가 접수되었습니다.
</div>
<% } else if ("duplicate".equals(_reportResult)) { %>
<div id="reportToast" style="position:fixed; bottom:30px; left:50%; transform:translateX(-50%); background:#e67e22; color:white; padding:12px 24px; border-radius:24px; font-size:14px; font-weight:600; z-index:3000; box-shadow:0 4px 16px rgba(0,0,0,0.2);">
    ⚠️ 이미 신고한 항목입니다.
</div>
<% } %>

<script>
    function openReportModal(type, id, redirectUrl) {
        document.getElementById('reportTargetType').value  = type;
        document.getElementById('reportTargetId').value    = id;
        document.getElementById('reportRedirectUrl').value = redirectUrl;
        // 초기화
        document.querySelectorAll('#reportForm input[name=reason]').forEach(r => r.checked = false);
        document.getElementById('etcWrap').style.display = 'none';
        const modal = document.getElementById('reportModal');
        modal.style.display = 'flex';
    }

    function closeReportModal() {
        document.getElementById('reportModal').style.display = 'none';
    }

    // '기타' 선택 시 직접입력 textarea 표시
    document.querySelectorAll('#reportForm input[name=reason]').forEach(radio => {
        radio.addEventListener('change', () => {
            const etcWrap = document.getElementById('etcWrap');
            etcWrap.style.display = radio.value === '기타' ? 'block' : 'none';
        });
    });

    // 폼 제출 전: 기타 사유를 reason에 병합
    document.getElementById('reportForm').addEventListener('submit', function(e) {
        const selected = document.querySelector('#reportForm input[name=reason]:checked');
        if (!selected) { e.preventDefault(); alert('신고 사유를 선택해주세요.'); return; }
        if (selected.value === '기타') {
            const etc = document.getElementById('etcReason').value.trim();
            if (etc) selected.value = '기타: ' + etc;
        }
    });

    // 모달 외부 클릭 닫기
    document.getElementById('reportModal').addEventListener('click', function(e) {
        if (e.target === this) closeReportModal();
    });

    // 토스트 자동 소멸
    const toast = document.getElementById('reportToast');
    if (toast) setTimeout(() => toast.style.opacity = '0', 2500);
</script>
