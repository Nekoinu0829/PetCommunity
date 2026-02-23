<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.*, java.util.*, java.net.URLEncoder" %>
<%@ include file="../header.jsp" %>

<%
    BoardDAO dao = new BoardDAO();
    String pageStr = request.getParameter("page");
    int currentPage = (pageStr == null || pageStr.isEmpty()) ? 1 : Integer.parseInt(pageStr);
    String tag = request.getParameter("tag");
    if(tag == null || tag.isEmpty()) tag = "전체";
    ArrayList<BoardDTO> list = dao.getBoardList(currentPage, tag);
    int totalCount = dao.getBoardCount(tag);
    int totalPage = (int)Math.ceil((double)totalCount / 15.0);
    String encodedTag = URLEncoder.encode(tag, "UTF-8");
%>

<style>
    body { background-color: #fdfaf4 !important; font-family: 'OshidashiGothic', sans-serif !important; }

    .community-wrapper {
        max-width: 1100px; margin: 50px auto 100px;
        background: #fff; padding: 40px 50px;
        border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.03);
    }

    
    .com-header {
        display: flex; justify-content: space-between; align-items: center;
        margin-bottom: 20px;
    }
    .com-header h2 { font-size: 26px; font-weight: 800; color: #333; margin: 0; }
    .btn-write {
        background: #fdd835; color: #333 !important; padding: 12px 25px;
        border-radius: 30px; text-decoration: none !important; font-weight: bold;
        box-shadow: 0 4px 10px rgba(253,216,53,0.3); transition: 0.2s;
        display: inline-flex; align-items: center; gap: 8px;
    }
    .btn-write:hover { background: #fbc02d; transform: translateY(-2px); color: #333; }

    
    .filter-box {
        display: flex; gap: 10px; margin-bottom: 30px;
        padding-bottom: 20px; border-bottom: 2px solid #f0f0f0;
    }
    .filter-btn {
        padding: 8px 20px; border-radius: 20px; text-decoration: none !important;
        font-weight: bold; font-size: 15px; color: #666;
        background: #f5f5f5; transition: 0.2s; border: 1px solid #eee;
    }
    .filter-btn:hover { background: #e0e0e0; color: #666; }
    .filter-btn.active { background: #333; color: #fff !important; border-color: #333; }

    
    .card-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 25px;
    }

    .card-item {
        background: #fff; border: 1px solid #f0f0f0; border-radius: 15px;
        overflow: hidden; cursor: pointer; transition: all 0.3s ease;
        display: flex; flex-direction: column; height: 100%;
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

    
    .card-thumb {
        width: 100%; height: 220px;
        background: #f9f9f9; position: relative; overflow: hidden;
    }
    .card-thumb img {
        width: 100%; height: 100%; object-fit: cover; display: block;
        transition: transform 0.4s ease;
    }
    .card-item:hover .card-thumb img { transform: scale(1.06); }

    .card-badge {
        position: absolute; top: 12px; left: 12px;
        padding: 4px 12px; border-radius: 20px;
        font-size: 12px; font-weight: bold;
        box-shadow: 0 2px 5px rgba(0,0,0,0.1); z-index: 1;
    }
    .tag-dog { background: #e3f2fd; color: #1976d2; }
    .tag-cat { background: #fce4ec; color: #c2185b; }
    .tag-default { background: #fff; color: #555; }

    
    .card-body { padding: 20px; display: flex; flex-direction: column; flex-grow: 1; }
    .card-title {
        font-size: 18px; font-weight: bold; color: #222;
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
    .card-stats { font-size: 13px; color: #999; display: flex; gap: 10px; }
    .card-likes { color: #ff4757; font-weight: bold; }

    
    .pagination { margin-top: 50px; display: flex; justify-content: center; gap: 8px; }
    .page-btn {
        width: 38px; height: 38px; display: flex; align-items: center; justify-content: center;
        border-radius: 50%; background: #fff; border: 1px solid #ddd;
        color: #555; font-weight: bold; text-decoration: none !important; transition: 0.2s;
    }
    .page-btn:hover { background: #f0f0f0; }
    .page-btn.active { background: #333; color: #fff !important; border-color: #333; cursor: default; }

    
    .empty-box { text-align: center; padding: 100px 0; color: #999; }
    .empty-box i { font-size: 50px; color: #e8e0d5; margin-bottom: 15px; display: block; }
</style>

<div class="community-wrapper">
    <div class="com-header">
        <h2><i class="fas fa-paw" style="color:#fdd835;"></i> コミュニティストーリー</h2>
        <a href="write.jsp" class="btn-write"><i class="fas fa-pen"></i> 投稿する</a>
    </div>

    <div class="filter-box">
        <a href="community.jsp?tag=전체"  class="filter-btn <%= tag.equals("전체")  ? "active" : "" %>">すべて</a>
        <a href="community.jsp?tag=강아지" class="filter-btn <%= tag.equals("강아지") ? "active" : "" %>">🐶 犬</a>
        <a href="community.jsp?tag=고양이" class="filter-btn <%= tag.equals("고양이") ? "active" : "" %>">🐱 猫</a>
    </div>

    <% if(list == null || list.isEmpty()) { %>
        <div class="empty-box">
            <i class="far fa-sad-tear"></i>
            まだ投稿がありません。最初のストーリーを聞かせてください！
        </div>
    <% } else { %>
        <div class="card-grid">
            <%
            int ci = 0;
                for(BoardDTO b : list) {
                
                if(b.getTag() != null && b.getTag().startsWith("콘텐츠")) { ci++; continue; }
                String tagClass = "tag-default";
                if("강아지".equals(b.getTag())) tagClass = "tag-dog";
                else if("고양이".equals(b.getTag())) tagClass = "tag-cat";

                String pic = b.getPic();
                if(pic == null || pic.trim().isEmpty() || pic.equals("no_img.png") || pic.equals("img_board.png")) {
                    pic = request.getContextPath() + "/images/no_img.png"; 
                } else if(!pic.startsWith("data:image") && !pic.startsWith("http")) {
                    pic = request.getContextPath() + "/upload/" + pic; 
                }
            %>
            <div class="card-item" style="animation-delay:<%=String.format("%.2f", ci * 0.07)%>s" onclick="location.href='detail.jsp?no=<%= b.getNo() %>'">
                <div class="card-thumb">
                    <% if(b.getTag() != null && !b.getTag().isEmpty()) {
                        String displayBadge = "강아지".equals(b.getTag()) ? "犬" : "고양이".equals(b.getTag()) ? "猫" : b.getTag();
                    %>
                        <span class="card-badge <%= tagClass %>"><%= displayBadge %></span>
                    <% } %>
                    <img src="<%= pic %>" alt="投稿画像">
                </div>
                <div class="card-body">
                    <div class="card-title"><%= b.getTitle() != null ? b.getTitle() : "タイトルなし" %></div>
                    <div class="card-footer">
                        <span class="card-writer">
                            <i class="fas fa-user-circle" style="color:#ccc; font-size:16px;"></i>
                            <%= b.getNickname() != null ? b.getNickname() : "匿名" %>
                        </span>
                        <div class="card-stats">
                            <span><i class="far fa-eye"></i> <%= b.getViews() %></span>
                            <span class="card-likes"><i class="fas fa-heart"></i> <%= b.getLikes() %></span>
                        </div>
                    </div>
                </div>
            </div>
            <% ci++; } %>
        </div>

        <div class="pagination">
            <% if(totalPage > 0) {
                int startPage = ((currentPage - 1) / 5) * 5 + 1;
                int endPage = Math.min(startPage + 4, totalPage);
                if(startPage > 1) { %>
                    <a href="community.jsp?page=<%= startPage-1 %>&tag=<%= encodedTag %>" class="page-btn"><i class="fas fa-chevron-left"></i></a>
            <%  }
                for(int i = startPage; i <= endPage; i++) {
                    if(i == currentPage) { %>
                        <span class="page-btn active"><%= i %></span>
            <%      } else { %>
                        <a href="community.jsp?page=<%= i %>&tag=<%= encodedTag %>" class="page-btn"><%= i %></a>
            <%      }
                }
                if(endPage < totalPage) { %>
                    <a href="community.jsp?page=<%= endPage+1 %>&tag=<%= encodedTag %>" class="page-btn"><i class="fas fa-chevron-right"></i></a>
            <%  } } %>
        </div>
    <% } %>
</div>

<%@ include file="../footer.jsp" %>
