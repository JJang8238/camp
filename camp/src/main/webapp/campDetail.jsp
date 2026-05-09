<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*, dao.CampDAO, dao.MatchDAO, dao.PlaceReviewDAO, dao.WishlistDAO, dto.Camp, dto.Match" %>

<%
String ctx = request.getContextPath();

String idStr = request.getParameter("id");

if (idStr == null || idStr.trim().isEmpty()) {
    out.println("id 없음");
    return;
}

int id = 0;
try {
    id = Integer.parseInt(idStr);
} catch (NumberFormatException e) {
    out.println("id 형식 오류");
    return;
}

CampDAO campDao = new CampDAO();
Camp camp = campDao.getCampById(id);

if (camp == null) {
    out.println("캠핑장 없음");
    return;
}

String name = (camp.getName() != null) ? camp.getName() : "";
String description = (camp.getDescription() != null) ? camp.getDescription() : "";

MatchDAO matchDao = new MatchDAO();
List<Match> matches = matchDao.getTodayMatchesByPlace(name);
if (matches == null) matches = new ArrayList<>();

PlaceReviewDAO reviewDao = new PlaceReviewDAO();
List<Map<String, Object>> reviews = reviewDao.listByPlace(name, "latest");
if (reviews == null) reviews = new ArrayList<>();

Integer userId = (Integer) session.getAttribute("userId");
String userName = (String) session.getAttribute("userName");
if (userName == null) userName = "";

boolean isWished = (userId != null) && WishlistDAO.isWished(userId, id);

// 이미지 경로 처리
String rawImg = camp.getImage();
String imgPath;
if (rawImg != null && !rawImg.trim().isEmpty()) {
    rawImg = rawImg.trim();
    if (rawImg.startsWith("http://") || rawImg.startsWith("https://")) {
        imgPath = rawImg;
    } else if (rawImg.startsWith("/")) {
        imgPath = ctx + rawImg;
    } else {
        imgPath = ctx + "/assets/img/" + rawImg;
    }
} else {
    imgPath = ctx + "/assets/img/default.jpg";
}

// 별점 평균
double avgRating = 0;
if (!reviews.isEmpty()) {
    int sum = 0;
    for (Map<String, Object> r : reviews) {
        try { sum += Integer.parseInt(String.valueOf(r.get("rating"))); } catch (Exception ignored) {}
    }
    avgRating = (double) sum / reviews.size();
}
String avgStr = reviews.isEmpty() ? "-" : String.format("%.1f", avgRating);
int roundedAvg = (int) Math.round(avgRating);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <title><%=name%> | Camp Mate</title>

    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/camp.css">
    <script src="https://js.tosspayments.com/v1"></script>

    <style>
        body { background: #f5f4f0; }

        .detail-container {
            max-width: 1100px;
            margin: 40px auto 80px;
            padding: 0 24px;
        }

        /* ── 메인 상단: 이미지 + 정보 ── */
        .detail-main {
            display: flex;
            gap: 28px;
            align-items: flex-start;
            margin-bottom: 24px;
        }

        .detail-img-box {
            flex: 0 0 520px;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 4px 20px rgba(0,0,0,0.10);
        }
        .detail-img-box img {
            width: 100%;
            height: 340px;
            object-fit: cover;
            display: block;
        }

        /* 우측 카드 */
        .detail-right-card {
            flex: 1;
            background: white;
            border-radius: 16px;
            padding: 28px 28px 24px;
            box-shadow: 0 2px 16px rgba(0,0,0,0.07);
            display: flex;
            flex-direction: column;
            gap: 0;
        }

        .detail-name {
            font-size: 22px;
            font-weight: 800;
            color: #1a1a1a;
            margin: 0 0 8px;
            line-height: 1.35;
        }

        .detail-address {
            font-size: 13px;
            color: #888;
            margin-bottom: 12px;
        }

        .detail-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
            margin-bottom: 14px;
        }
        .detail-tag {
            background: #f0f7ee;
            color: #2d5a27;
            font-size: 11px;
            font-weight: 600;
            padding: 3px 10px;
            border-radius: 20px;
        }

        .detail-rating {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 13px;
            color: #555;
            margin-bottom: 20px;
        }
        .stars-row { color: #f5a623; font-size: 15px; letter-spacing: 1px; }
        .rating-count { color: #bbb; font-size: 12px; }

        .divider { border: none; border-top: 1px solid #f1f3f5; margin: 0 0 18px; }

        .price-label { font-size: 11px; color: #bbb; margin-bottom: 2px; }
        .price-value {
            font-size: 26px;
            font-weight: 800;
            color: #e8401c;
            margin-bottom: 18px;
        }

        .btn-book {
            width: 100%;
            padding: 13px;
            background: #2d5a27;
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 15px;
            font-weight: 700;
            cursor: pointer;
            transition: background 0.2s;
            margin-bottom: 10px;
        }
        .btn-book:hover { background: #1e3d1b; }

        .btn-wish-detail {
            width: 100%;
            padding: 11px;
            background: white;
            border: 1.5px solid #e0e0e0;
            border-radius: 10px;
            font-size: 13px;
            font-weight: 600;
            color: #666;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 5px;
            transition: border-color 0.2s, color 0.2s, background 0.2s;
        }
        .btn-wish-detail:hover { border-color: #e74c3c; color: #e74c3c; }
        .btn-wish-detail.wished { border-color: #e74c3c; color: #e74c3c; background: #fff5f5; }

        /* ── 주소 클릭 버튼 ── */
        .detail-address {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-size: 13px;
            color: #888;
            margin-bottom: 12px;
            cursor: pointer;
            border-bottom: 1px dashed #ccc;
            padding-bottom: 1px;
            transition: color 0.2s;
        }
        .detail-address:hover { color: #2d5a27; border-bottom-color: #2d5a27; }
        .detail-address .map-hint {
            font-size: 11px;
            color: #bbb;
            margin-left: 4px;
        }

        /* ── 카카오맵 팝업 모달 ── */
        .map-modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.5);
            z-index: 2000;
            align-items: center;
            justify-content: center;
        }
        .map-modal-overlay.active { display: flex; }

        .map-modal-box {
            background: white;
            border-radius: 16px;
            width: 90%;
            max-width: 680px;
            box-shadow: 0 16px 48px rgba(0,0,0,0.2);
            overflow: hidden;
        }

        .map-modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 16px 20px;
            border-bottom: 1px solid #f1f3f5;
        }
        .map-modal-title {
            font-size: 15px;
            font-weight: 700;
            color: #1a1a1a;
        }
        .map-modal-close {
            background: none;
            border: none;
            font-size: 20px;
            color: #aaa;
            cursor: pointer;
            line-height: 1;
        }
        .map-modal-close:hover { color: #333; }

        #kakaoMapContainer {
            width: 100%;
            height: 380px;
        }

        .map-modal-footer {
            padding: 12px 20px;
            background: #f8f9fa;
            font-size: 13px;
            color: #555;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 8px;
        }
        .map-distance-info { font-weight: 600; color: #2d5a27; }
        .map-address-text { color: #888; font-size: 12px; }

        /* ── 하단 섹션 ── */
        .detail-section {
            background: white;
            border-radius: 14px;
            padding: 26px 30px;
            margin-bottom: 18px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        .detail-section h3 {
            font-size: 16px;
            font-weight: 700;
            color: #1a1a1a;
            margin: 0 0 16px;
            padding-bottom: 12px;
            border-bottom: 1px solid #f1f3f5;
        }
        .detail-desc { font-size: 13px; color: #555; line-height: 1.9; }
        .empty-msg { color: #bbb; font-size: 13px; }

        /* 후기 */
        .review-item {
            padding: 16px 0;
            border-bottom: 1px solid #f7f7f7;
        }
        .review-item:last-of-type { border-bottom: none; }
        .review-top-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 5px;
        }
        .review-user { font-size: 13px; font-weight: 700; color: #333; }
        .review-stars-sm { color: #f5a623; font-size: 12px; }
        .review-date { font-size: 11px; color: #bbb; }
        .review-text { font-size: 13px; color: #666; line-height: 1.7; margin: 0; }

        /* 후기 작성 */
        .review-form-wrap {
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid #f1f3f5;
        }
        .review-form-wrap h4 { font-size: 14px; font-weight: 700; margin-bottom: 12px; color: #1a1a1a; }
        .review-textarea {
            width: 100%; height: 90px;
            border: 1.5px solid #dee2e6; border-radius: 8px;
            padding: 10px 12px; font-size: 13px;
            resize: none; box-sizing: border-box;
            outline: none; transition: border-color 0.2s;
        }
        .review-textarea:focus { border-color: #2d5a27; }
        .review-form-bottom {
            display: flex; justify-content: space-between;
            align-items: center; margin-top: 8px; gap: 10px;
        }
        .review-select {
            padding: 7px 10px; border: 1.5px solid #dee2e6;
            border-radius: 7px; font-size: 13px; outline: none; cursor: pointer;
        }
        .btn-review-submit {
            padding: 8px 20px; background: #2d5a27; color: white;
            border: none; border-radius: 7px; font-size: 13px;
            font-weight: 600; cursor: pointer; transition: background 0.2s;
        }
        .btn-review-submit:hover { background: #1e3d1b; }

        @media (max-width: 750px) {
            .detail-main { flex-direction: column; }
            .detail-img-box { flex: none; width: 100%; }
            .detail-img-box img { height: 220px; }
            .detail-right-card { width: 100%; box-sizing: border-box; }
        }
    </style>
</head>

<body>

<jsp:include page="/include/header.jsp" />

<div class="detail-container">

    <div class="detail-main">

        <!-- 이미지 -->
        <div class="detail-img-box">
            <img src="<%=imgPath%>"
                 alt="<%=name%>"
                 onerror="this.src='<%=ctx%>/assets/img/default.jpg'">
        </div>

        <!-- 우측 정보 카드 -->
        <div class="detail-right-card">
            <h1 class="detail-name"><%=name%></h1>
            <p class="detail-address" onclick="openMapModal()" title="클릭하면 지도에서 위치를 확인할 수 있어요">
                📍 <%=camp.getAddress()%>
                <span class="map-hint">🗺 지도 보기</span>
            </p>

            <div class="detail-tags">
                <% if (camp.getType() != null && !camp.getType().trim().isEmpty()) { %>
                <span class="detail-tag"><%=camp.getType()%></span>
                <% } %>
                <% if (camp.getTags() != null && !camp.getTags().trim().isEmpty()) {
                    for (String tg : camp.getTags().split("[,\\s]+")) {
                        if (!tg.trim().isEmpty()) { %>
                <span class="detail-tag">#<%=tg.trim().replace("#","")%></span>
                <%      }
                    }
                } %>
            </div>

            <% if (!reviews.isEmpty()) { %>
            <div class="detail-rating">
                <span class="stars-row">
                    <% for (int i=1; i<=5; i++) out.print(i <= roundedAvg ? "★" : "☆"); %>
                </span>
                <strong><%=avgStr%></strong>
                <span class="rating-count">(후기 <%=reviews.size()%>개)</span>
            </div>
            <% } %>

            <hr class="divider">

            <div class="price-label">1박 기준 시작가</div>
            <div class="price-value">₩ <%=String.format("%,d", camp.getPrice())%></div>

            <button class="btn-book" id="pay-btn">예약하기</button>

            <button type="button"
                    class="btn-wish-detail <%=isWished ? "wished" : ""%>"
                    id="wishBtn"
                    data-camp-id="<%=id%>"
                    data-wished="<%=isWished%>"
                    onclick="toggleWishDetail(this)">
                <span id="wishIcon"><%=isWished ? "❤️" : "🤍"%></span>
                <span id="wishText"><%=isWished ? "찜 해제" : "찜하기"%></span>
            </button>
        </div>
    </div>

    <!-- 소개 -->
    <div class="detail-section">
        <h3>캠핑장 소개</h3>
        <% if (!description.trim().isEmpty()) { %>
            <p class="detail-desc"><%=description.replace("\n", "<br>")%></p>
        <% } else { %>
            <p class="empty-msg">등록된 상세 설명이 없습니다.</p>
        <% } %>
    </div>

    <!-- 후기 -->
    <div class="detail-section">
        <h3>후기<%=reviews.isEmpty() ? "" : " (" + reviews.size() + ")"%></h3>

        <% if (!reviews.isEmpty()) {
            for (Map<String, Object> r : reviews) {
                int rv = 5;
                try { rv = Integer.parseInt(String.valueOf(r.get("rating"))); } catch (Exception ignored) {}
                String rStars = "★★★★★☆☆☆☆☆".substring(5 - rv, 10 - rv);
                String rDate = r.get("created_at") != null ? r.get("created_at").toString().substring(0, 10) : "";
        %>
        <div class="review-item">
            <div class="review-top-row">
                <span class="review-user">🏕️ <%=r.get("user")%> 캠퍼님</span>
                <span class="review-date"><%=rDate%></span>
            </div>
            <div class="review-stars-sm"><%=rStars%></div>
            <p class="review-text"><%=r.get("content")%></p>
        </div>
        <% } } else { %>
            <p class="empty-msg">아직 후기가 없습니다.</p>
        <% } %>

        <div class="review-form-wrap">
            <h4>✍️ 후기 작성</h4>
            <form action="<%=ctx%>/review" method="post">
                <input type="hidden" name="place" value="<%=name%>">
                <textarea name="content" class="review-textarea" placeholder="캠핑 후기를 솔직하게 남겨주세요."></textarea>
                <div class="review-form-bottom">
                    <select name="rating" class="review-select">
                        <option value="5">⭐⭐⭐⭐⭐ 5점</option>
                        <option value="4">⭐⭐⭐⭐ 4점</option>
                        <option value="3">⭐⭐⭐ 3점</option>
                        <option value="2">⭐⭐ 2점</option>
                        <option value="1">⭐ 1점</option>
                    </select>
                    <button type="submit" class="btn-review-submit">작성 완료</button>
                </div>
            </form>
        </div>
    </div>

</div>

<jsp:include page="/include/footer.jsp" />

<%-- ── 카카오맵 팝업 모달 ── --%>
<div class="map-modal-overlay" id="mapModal">
    <div class="map-modal-box">
        <div class="map-modal-header">
            <span class="map-modal-title">🗺️ <%=name%> 위치</span>
            <button class="map-modal-close" onclick="closeMapModal()">✕</button>
        </div>
        <div id="kakaoMapContainer"></div>
        <div class="map-modal-footer">
            <span class="map-address-text">📍 <%=camp.getAddress()%></span>
            <span class="map-distance-info" id="distanceInfo">현재 위치를 불러오는 중...</span>
        </div>
    </div>
</div>

<script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=631343aadfb0ebd9e064328c2767b936&libraries=services"></script>
<script>
// 토스페이먼츠 (기존 그대로)
const clientKey = "test_ck_6bJXmgo28e4dxgEbwWKArLAnGKWx";
const tossPayments = TossPayments(clientKey);

document.getElementById("pay-btn").addEventListener("click", function () {
    <% if (userId == null) { %>
        alert("로그인 후 이용해주세요.");
        location.href = "<%=ctx%>/login.jsp";
        return;
    <% } %>

    const orderId = "ORDER-<%=id%>-" + Date.now();

    tossPayments.requestPayment("카드", {
        amount: <%=camp.getPrice()%>,
        orderId: orderId,
        orderName: "<%=name%>",
        successUrl: window.location.origin + "<%=ctx%>/payment/success.jsp",
        failUrl:    window.location.origin + "<%=ctx%>/payment/fail.jsp",
        customerName: "<%=userName%>"
    });
});

// 찜 AJAX
function toggleWishDetail(btn) {
    <% if (userId == null) { %>
        alert("로그인 후 이용해주세요.");
        location.href = "<%=ctx%>/login.jsp";
        return;
    <% } %>

    const campId = btn.dataset.campId;
    const wished = btn.dataset.wished === 'true';
    btn.disabled = true;

    fetch('<%=ctx%>/wishToggle', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'campId=' + campId + '&action=' + (wished ? 'remove' : 'add')
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            const nowWished = !wished;
            btn.dataset.wished = nowWished;
            btn.classList.toggle('wished', nowWished);
            document.getElementById('wishIcon').textContent = nowWished ? '❤️' : '🤍';
            document.getElementById('wishText').textContent = nowWished ? '찜 해제' : '찜하기';
        }
    })
    .catch(err => console.error('찜 오류:', err))
    .finally(() => { btn.disabled = false; });
}

// ── 카카오맵 팝업 ──
const campAddress = "<%=camp.getAddress().replace("\"", "\\\"")%>";
let kakaoMap = null;
let mapInitialized = false;

function openMapModal() {
    document.getElementById('mapModal').classList.add('active');
    if (!mapInitialized) {
        setTimeout(initKakaoMap, 100); // 모달 렌더 후 초기화
        mapInitialized = true;
    }
}

function closeMapModal() {
    document.getElementById('mapModal').classList.remove('active');
}

function initKakaoMap() {
    const container = document.getElementById('kakaoMapContainer');
    const options = {
        center: new kakao.maps.LatLng(37.5665, 126.9780),
        level: 7
    };
    kakaoMap = new kakao.maps.Map(container, options);

    const geocoder = new kakao.maps.services.Geocoder();
    geocoder.addressSearch(campAddress, function(result, status) {
        if (status === kakao.maps.services.Status.OK) {
            const campCoord = new kakao.maps.LatLng(result[0].y, result[0].x);

            // 캠핑장 마커 + 인포윈도우
            const campMarker = new kakao.maps.Marker({ map: kakaoMap, position: campCoord });
            const infowindow = new kakao.maps.InfoWindow({
                content: '<div style="padding:8px 12px;font-size:13px;font-weight:700;color:#2d5a27;white-space:nowrap;">🏕️ <%=name.replace("\"","\\\"")%></div>'
            });
            infowindow.open(kakaoMap, campMarker);
            kakaoMap.setCenter(campCoord);

            // 현재 위치
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(function(pos) {
                    const userLat = pos.coords.latitude;
                    const userLng = pos.coords.longitude;
                    const userCoord = new kakao.maps.LatLng(userLat, userLng);

                    // 내 위치 마커 (별 모양)
                    new kakao.maps.Marker({
                        map: kakaoMap,
                        position: userCoord,
                        title: "내 위치",
                        image: new kakao.maps.MarkerImage(
                            'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/markerStar.png',
                            new kakao.maps.Size(24, 35)
                        )
                    });

                    // 직선 거리 계산 (Haversine)
                    const R = 6371;
                    const dLat = (parseFloat(result[0].y) - userLat) * Math.PI / 180;
                    const dLon = (parseFloat(result[0].x) - userLng) * Math.PI / 180;
                    const a = Math.sin(dLat/2)**2
                            + Math.cos(userLat*Math.PI/180) * Math.cos(parseFloat(result[0].y)*Math.PI/180)
                            * Math.sin(dLon/2)**2;
                    const dist = R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));

                    const distText = dist < 1 ? Math.round(dist*1000)+"m" : dist.toFixed(1)+"km";
                    const timeMin = Math.round(dist / 60 * 60);
                    const timeText = timeMin < 60 ? timeMin+"분" : Math.floor(timeMin/60)+"시간 "+(timeMin%60)+"분";

                    document.getElementById('distanceInfo').innerHTML =
                        '📍 현재 위치에서 약 <strong>' + distText + '</strong> · 차량 약 <strong>' + timeText + '</strong> 소요';

                    // 두 마커 모두 보이게 범위 조정
                    const bounds = new kakao.maps.LatLngBounds();
                    bounds.extend(userCoord);
                    bounds.extend(campCoord);
                    kakaoMap.setBounds(bounds);

                }, function() {
                    document.getElementById('distanceInfo').textContent = '위치 권한이 없어 거리를 계산할 수 없습니다.';
                });
            } else {
                document.getElementById('distanceInfo').textContent = '이 브라우저는 위치 정보를 지원하지 않습니다.';
            }
        } else {
            document.getElementById('distanceInfo').textContent = '주소를 지도에서 찾을 수 없습니다.';
        }
    });
}

// 모달 외부 클릭 시 닫기
document.getElementById('mapModal').addEventListener('click', function(e) {
    if (e.target === this) closeMapModal();
});
</script>

</body>
</html>
