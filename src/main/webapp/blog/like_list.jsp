<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="util.DBManager" %>
<%@ page import="model.BoardDAO, model.BoardDTO, model.UserDTO" %>
<%@ include file="../header.jsp" %>

<%!
    private String normalizePic2(String pic, String ctx) {
        if (pic == null || pic.trim().isEmpty()) return ctx + "/image/no_img.jpg";
        pic = pic.trim();
        if (pic.startsWith("http://") || pic.startsWith("https://") || pic.startsWith("data:") || pic.startsWith("/")) return pic;
        if (pic.startsWith("upload/") || pic.startsWith("uploads/") || pic.startsWith("image/") || pic.startsWith("images/")) return ctx + "/" + pic;
        return ctx + "/upload/" + pic;
    }
%>

<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();
    UserDTO u = (UserDTO)session.getAttribute("user");
    if (u == null) {
%>
    <script>alert('ログインが必要です。'); location.href='<%=ctx%>/login.jsp';</script>
<%
        return;
    }
    BoardDAO dao = new BoardDAO();
    ArrayList<BoardDTO> list = dao.getLikeList(u.getId());
%>

<style>
    body { background-color: #fdfaf4 !important; font-family: 'OshidashiGothic', sans-serif !important; }

    .lk-wrapper {
        max-width: 1100px;
        margin: 50px auto 100px;
        background: #fff;
        padding: 40px 50px;
        border-radius: 20px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.03);
    }

    
    .lk-top {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 30px;
        padding-bottom: 20px;
        border-bottom: 2px solid #f0f0f0;
    }
    .lk-top h2 {
        font-size: 26px; font-weight: 800; color: #333; margin: 0;
        display: flex; align-items: center; gap: 10px;
    }
    .lk-badge {
        background: #ff4757; color: #fff; font-size: 13px; font-weight: 700;
        padding: 2px 10px; border-radius: 30px;
    }
    .lk-btn {
        background: #fdd835; color: #333 !important; padding: 12px 25px;
        border-radius: 30px; text-decoration: none !important; font-weight: bold;
        box-shadow: 0 4px 10px rgba(253,216,53,0.3); transition: 0.2s;
        display: inline-flex; align-items: center; gap: 8px; font-size: 15px;
    }
    .lk-btn:hover { background: #fbc02d; transform: translateY(-2px); color: #333; }

    
    .lk-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 25px;
    }

    .lk-card {
        background: #fff;
        border: 1px solid #f0f0f0;
        border-radius: 15px;
        overflow: hidden;
        cursor: pointer;
        transition: all 0.3s ease;
        display: flex;
        flex-direction: column;
        height: 100%;
        opacity: 0;
        transform: translateY(15px);
        animation: lkFadeUp 0.4s ease forwards;
    }
    @keyframes lkFadeUp { to { opacity: 1; transform: translateY(0); } }

    .lk-card:hover {
        transform: translateY(-8px);
        box-shadow: 0 15px 25px rgba(0,0,0,0.08);
        border-color: #fdd835;
    }

    
    .lk-thumb {
        width: 100%;
        height: 220px;
        background: #f9f9f9;
        position: relative;
        overflow: hidden;
    }
    .lk-thumb img {
        width: 100%; height: 100%;
        object-fit: cover;
        display: block;
        transition: transform 0.4s ease;
    }
    .lk-card:hover .lk-thumb img { transform: scale(1.06); }

    .lk-thumb-badge {
        position: absolute; top: 12px; left: 12px;
        padding: 4px 12px; border-radius: 20px;
        font-size: 12px; font-weight: bold;
        box-shadow: 0 2px 5px rgba(0,0,0,0.1); z-index: 1;
    }
    .tag-dog { background: #e3f2fd; color: #1976d2; }
    .tag-cat { background: #fce4ec; color: #c2185b; }
    .tag-etc { background: #fff; color: #555; }

    
    .lk-body {
        padding: 20px;
        display: flex;
        flex-direction: column;
        flex-grow: 1;
    }
    .lk-title {
        font-size: 18px; font-weight: bold; color: #222;
        margin-bottom: 12px; line-height: 1.4; height: 50px;
        display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical;
        overflow: hidden; text-overflow: ellipsis;
    }
    .lk-footer {
        margin-top: auto;
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-top: 1px solid #f5f5f5;
        padding-top: 12px;
    }
    .lk-writer {
        font-size: 14px; font-weight: 500; color: #555;
        display: flex; align-items: center; gap: 6px;
    }
    .lk-stats {
        font-size: 13px; color: #999;
        display: flex; gap: 10px;
    }
    .lk-likes { color: #ff4757; font-weight: bold; }

    
    .lk-empty { text-align: center; padding: 100px 0 80px; }
    .lk-empty i { font-size: 52px; color: #e8e0d5; margin-bottom: 18px; display: block; }
    .lk-empty p { font-size: 16px; color: #999; line-height: 1.7; margin: 0 0 26px; }
    .lk-empty-btn {
        display: inline-block; background: #fdd835; color: #333;
        font-size: 15px; font-weight: 700; padding: 14px 32px;
        border-radius: 30px; text-decoration: none;
        box-shadow: 0 4px 10px rgba(253,216,53,0.3); transition: 0.2s;
    }
    .lk-empty-btn:hover { background: #fbc02d; transform: translateY(-2px); color: #333; text-decoration: none; }
</style>

<div class="lk-wrapper">

    <div class="lk-top">
        <h2>
            <i class="fas fa-heart" style="color:#ff4757;"></i>
            お気に入りの投稿
            <% if (list != null && !list.isEmpty()) { %>
                <span class="lk-badge"><%= list.size() %></span>
            <% } %>
        </h2>
       
    </div>

    <%
    if (list == null || list.isEmpty()) {
    %>
        <div class="lk-empty">
            <i class="far fa-heart"></i>
            <p>まだお気に入りの投稿がありません。<br>気に入った投稿にハートを押してみましょう！</p>
            <a href="community.jsp" class="lk-empty-btn"><i class="fas fa-paw"></i> コミュニティを見る</a>
        </div>
    <%
    } else {
    %>
    <div class="lk-grid">
        <%
        int idx = 0;
        for (BoardDTO b : list) {
            idx++;
            String thumb = normalizePic2(b.getPic(), ctx);
            String dateStr = (b.getDate() != null) ? b.getDate().toString().substring(0, 10) : "";
            double delay = idx * 0.06;
            String rawTag = b.getTag() != null ? b.getTag() : "";
            if (rawTag.startsWith("콘텐츠_")) rawTag = rawTag.substring("콘텐츠_".length());

            java.util.Map<String,String> tagJpMap = new java.util.LinkedHashMap<>();
            tagJpMap.put("강아지", "犬"); tagJpMap.put("고양이", "猫");
            tagJpMap.put("건강", "健康"); tagJpMap.put("행동", "しつけ"); tagJpMap.put("음식", "食事");
            tagJpMap.put("트레이닝", "トレーニング"); tagJpMap.put("강아지품종", "犬種図鑑"); tagJpMap.put("고양이품종", "猫種図鑑");
            tagJpMap.put("견종백과", "犬種図鑑"); tagJpMap.put("묘종백과", "猫種図鑑");
            tagJpMap.put("용품", "用品レビュー"); tagJpMap.put("입양", "里親情報"); tagJpMap.put("미용", "グルーミング"); tagJpMap.put("운동", "散歩・運動");

            String tagLabel = tagJpMap.containsKey(rawTag) ? tagJpMap.get(rawTag) : rawTag;
            String tagClass = "tag-etc";
            if ("강아지".equals(rawTag)) tagClass = "tag-dog";
            else if ("고양이".equals(rawTag)) tagClass = "tag-cat";
        %>
        <div class="lk-card"
             onclick="location.href='detail.jsp?no=<%=b.getNo()%>'"
             style="animation-delay:<%=String.format("%.2f", delay)%>s;">

            <div class="lk-thumb">
                <% if (b.getTag() != null && !b.getTag().isEmpty()) { %>
                    <span class="lk-thumb-badge <%= tagClass %>"># <%= tagLabel %></span>
                <% } %>
                <img src="<%= thumb %>" alt="サムネイル"
                     onerror="this.src='<%=ctx%>/image/no_img.jpg';">
            </div>

            <div class="lk-body">
                <div class="lk-title"><%= b.getTitle() %></div>
                <div class="lk-footer">
                    <span class="lk-writer">
                        <i class="fas fa-user-circle" style="color:#ccc; font-size:16px;"></i>
                        <%= b.getNickname() %>
                    </span>
                    <div class="lk-stats">
                        <span><i class="far fa-eye"></i> <%= b.getViews() %></span>
                        <span class="lk-likes"><i class="fas fa-heart"></i> <%= b.getLikes() %></span>
                    </div>
                </div>
            </div>
        </div>
        <%
        }
        %>
    </div>
    <% } %>

</div>

<%@ include file="../footer.jsp" %>
