<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.*, java.util.*" %>
<%@ include file="../header.jsp" %>

<%
    BoardDAO dao = new BoardDAO();
    ArrayList<BoardDTO> contentList = dao.getContentList();

    
    String filterTag = request.getParameter("tag");
    if (filterTag == null) filterTag = "전체";
%>

<style>
    body { background-color: #fdfaf4 !important; font-family: 'OshidashiGothic', sans-serif !important; }

    .content-wrapper {
        max-width: 1100px; margin: 50px auto 100px;
        background: #fff; padding: 40px 50px;
        border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.03);
    }

    
    .com-header {
        display: flex; justify-content: space-between; align-items: center;
        margin-bottom: 24px; padding-bottom: 20px; border-bottom: 2px solid #f0f0f0;
    }
    .com-header h2 { font-size: 26px; font-weight: 800; color: #333; margin: 0; }
    .com-header p { font-size: 14px; color: #999; margin: 6px 0 0; }

    
    .tag-filter-bar {
        display: flex; gap: 8px; flex-wrap: wrap;
        margin-bottom: 28px; padding-bottom: 20px;
        border-bottom: 1px solid #f5f0e8;
    }
    .tf-chip {
        padding: 7px 18px; border-radius: 20px;
        background: #f8f5ee; color: #888; font-weight: 700; font-size: 13px;
        border: 1.5px solid transparent; cursor: pointer;
        text-decoration: none; transition: all 0.18s;
        display: flex; align-items: center; gap: 5px;
    }
    .tf-chip:hover { background: #fffde7; color: #555; border-color: #fdd835; }
    .tf-chip.active {
        background: #fdd835; color: #333; border-color: #fdd835;
        box-shadow: 0 3px 10px rgba(253,216,53,0.3);
    }

    
    .card-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 25px;
    }

    .card-item {
        background: #fff; border: 1px solid #f0f0f0; border-radius: 15px;
        overflow: hidden; cursor: pointer; transition: all 0.3s ease;
        display: flex; flex-direction: column; height: 100%;
        position: relative;
        opacity: 0; transform: translateY(28px);
        animation: fadeUpCard 0.45s ease forwards;
    }
    @keyframes fadeUpCard {
        to { opacity: 1; transform: translateY(0); }
    }
    .card-item:hover {
        transform: translateY(-8px);
        box-shadow: 0 15px 25px rgba(0,0,0,0.08);
        border-color: #fdd835;
    }

    
    .badge-official {
        position: absolute; top: 12px; right: 12px; z-index: 2;
        background: #333; color: #fdd835;
        padding: 4px 10px; border-radius: 20px;
        font-size: 11px; font-weight: 800;
        box-shadow: 0 2px 8px rgba(0,0,0,0.2);
    }

    
    .card-thumb {
        width: 100%; height: 220px;
        background: #f9f9f9; position: relative; overflow: hidden;
    }
    .card-thumb img {
        width: 100%; height: 100%; object-fit: cover; display: block;
        transition: transform 0.4s ease;
    }
    .card-item:hover .card-thumb img { transform: scale(1.06); }

    
    .card-tag-badge {
        position: absolute; top: 12px; left: 12px;
        background: #fff9dc; color: #f57f17;
        padding: 4px 12px; border-radius: 20px;
        font-size: 12px; font-weight: bold;
        box-shadow: 0 2px 5px rgba(0,0,0,0.08); z-index: 1;
    }

    
    .card-body { padding: 20px; display: flex; flex-direction: column; flex-grow: 1; }
    .card-title {
        font-size: 18px; font-weight: 800; color: #222;
        margin-bottom: 12px; line-height: 1.4; height: 50px;
        display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical;
        overflow: hidden; text-overflow: ellipsis;
    }
    .card-footer {
        margin-top: auto;
        display: flex; justify-content: space-between; align-items: center;
        border-top: 1px solid #f5f5f5; padding-top: 12px;
    }
    .card-writer { font-size: 14px; font-weight: 500; color: #555; display: flex; align-items: center; gap: 6px; }
    .card-writer i { color: #fdd835; }
    .card-stats { font-size: 13px; color: #999; display: flex; gap: 10px; }
    .card-likes { color: #ff4757; font-weight: bold; }

    
    .empty-box { text-align: center; padding: 100px 0; color: #999; }
    .empty-box i { font-size: 50px; color: #e8e0d5; margin-bottom: 15px; display: block; }

    
    .no-result {
        text-align: center; padding: 60px 0; color: #bbb;
        grid-column: 1 / -1;
    }
    .no-result i { font-size: 36px; margin-bottom: 12px; display: block; color: #e8e0d5; }
</style>

<div class="content-wrapper">
    <div class="com-header">
        <div>
            <h2><i class="fas fa-paw" style="color:#fdd835;"></i> ペットメイト マガジン</h2>
            <p>ペットと一緒に過ごす幸せな日常、公式コンテンツをお楽しみください。</p>
        </div>
    </div>

    <!-- 태그 필터 바 -->
    <div class="tag-filter-bar">
        <a href="contents.jsp" class="tf-chip <%= "전체".equals(filterTag) ? "active" : "" %>">すべて</a>
        <a href="contents.jsp?tag=건강"    class="tf-chip <%= "건강".equals(filterTag)    ? "active" : "" %>">🏥 健康</a>
        <a href="contents.jsp?tag=행동"    class="tf-chip <%= "행동".equals(filterTag)    ? "active" : "" %>">🐾 しつけ</a>
        <a href="contents.jsp?tag=음식"    class="tf-chip <%= "음식".equals(filterTag)    ? "active" : "" %>">🍖 食事</a>
        <a href="contents.jsp?tag=훈련"    class="tf-chip <%= "훈련".equals(filterTag)    ? "active" : "" %>">🎯 トレーニング</a>
        <a href="contents.jsp?tag=견종백과" class="tf-chip <%= "견종백과".equals(filterTag) ? "active" : "" %>">📖 犬種図鑑</a>
        <a href="contents.jsp?tag=묘종백과" class="tf-chip <%= "묘종백과".equals(filterTag) ? "active" : "" %>">📖 猫種図鑑</a>
    </div>

    <% if(contentList == null || contentList.isEmpty()) { %>
        <div class="empty-box">
            <i class="far fa-sad-tear"></i>
            まだコンテンツがありません。
        </div>
    <% } else { %>
        <div class="card-grid">
            <%
            int ci = 0;
            boolean anyShown = false;
            for(BoardDTO b : contentList) {
                
                String bTag = b.getTag() != null ? b.getTag() : "";
                
                String rawTag = bTag.startsWith("콘텐츠_") ? bTag.substring("콘텐츠_".length()) : bTag;
                java.util.Map<String,String> tagJpMap = new java.util.LinkedHashMap<>();
                tagJpMap.put("건강","健康"); tagJpMap.put("행동","しつけ"); tagJpMap.put("음식","食事");
                tagJpMap.put("트레이닝","トレーニング"); tagJpMap.put("강아지품종","犬種図鑑"); tagJpMap.put("고양이품종","猫種図鑑");
                tagJpMap.put("용품","用品レビュー"); tagJpMap.put("입양","里親情報"); tagJpMap.put("미용","グルーミング"); tagJpMap.put("운동","散歩・運動");
                String displayTag = tagJpMap.containsKey(rawTag) ? tagJpMap.get(rawTag) : rawTag;
                if (!"전체".equals(filterTag) && !filterTag.equals(rawTag)) continue;
                anyShown = true;

                String pData = b.getPic();
                if(pData == null || pData.isEmpty() || pData.equals("no_img.png")) {
                    pData = request.getContextPath() + "/images/no_img.png";
                } else if(!pData.startsWith("data:image") && !pData.startsWith("http")) {
                    pData = request.getContextPath() + "/upload/" + pData;
                }

                
            %>
            <div class="card-item" style="animation-delay:<%=String.format("%.2f", ci * 0.07)%>s"
                 onclick="location.href='detail.jsp?no=<%= b.getNo() %>'">
                <span class="badge-official">公式</span>
                <div class="card-thumb">
                    <span class="card-tag-badge"># <%= displayTag %></span>
                    <img src="<%= pData %>" alt="コンテンツ画像">
                </div>
                <div class="card-body">
                    <div class="card-title"><%= b.getTitle() %></div>
                    <div class="card-footer">
                        <span class="card-writer">
                            <i class="fas fa-check-circle"></i> ペットメイト編集部
                        </span>
                        <div class="card-stats">
                            <span><i class="far fa-eye"></i> <%= b.getViews() %></span>
                            <span class="card-likes"><i class="fas fa-heart"></i> <%= b.getLikes() %></span>
                        </div>
                    </div>
                </div>
            </div>
            <% ci++; }

            if (!anyShown) { %>
                <div class="no-result">
                    <i class="fas fa-search"></i>
                    '<%= filterTag %>' タグのコンテンツはまだありません。
                </div>
            <% } %>
        </div>
    <% } %>
</div>

<%@ include file="../footer.jsp" %>
