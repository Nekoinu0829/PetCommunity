<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet" %>
<%@ page import="util.DBManager" %>
<%@ page import="model.BoardDAO, model.BoardDTO, model.UserDTO, model.ReplyDAO, model.ReplyDTO" %>
<%@ include file="../header.jsp" %>
<%!
    private String safe(String s) { return s == null ? "" : s; }

    private String findUserPic(String key, boolean byId) {
        if (key == null || key.trim().isEmpty()) return "";
        Connection conn = null; PreparedStatement pstmt = null; ResultSet rs = null;
        try {
            conn = DBManager.getConnection();
            if (conn == null) return "";
            String sql = byId
                ? "SELECT PIC FROM MEMBER WHERE ID = ?"
                : "SELECT PIC FROM MEMBER WHERE NICKNAME = ? AND ROWNUM = 1";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, key.trim());
            rs = pstmt.executeQuery();
            if (rs.next()) { String p = rs.getString(1); return p == null ? "" : p.trim(); }
        } catch (Exception e) {}
        finally {
            try { if (rs    != null) rs.close();    } catch (Exception e) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn  != null) conn.close();  } catch (Exception e) {}
        }
        return "";
    }

    private String normalizePic(String pic, String ctx) {
        if (pic == null || pic.trim().isEmpty()) return ctx + "/image/no_img.jpg";
        pic = pic.trim();
        if (pic.startsWith("http://") || pic.startsWith("https://") || pic.startsWith("data:") || pic.startsWith("/")) return pic;
        if (pic.startsWith("upload/") || pic.startsWith("uploads/") || pic.startsWith("image/") || pic.startsWith("images/")) return ctx + "/" + pic;
        return ctx + "/upload/" + pic;
    }

    private String escHtml(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    UserDTO sessUser = (UserDTO) session.getAttribute("user");
    int no = Integer.parseInt(request.getParameter("no"));
    BoardDAO dao = new BoardDAO();

    
    String cmd = request.getParameter("cmd");

    /* 댓글 등록 처리 / コメント投稿処理 */
    if ("reply_add".equals(cmd) && sessUser != null) {
        String content = request.getParameter("content");
        if (content != null && !content.trim().isEmpty()) {
            ReplyDTO newReply = new ReplyDTO();
            newReply.setB_no(no);
            newReply.setWriter(sessUser.getId());
            newReply.setContent(content.trim());
            new ReplyDAO().addReply(newReply);
        }
        out.println("<script>alert('コメントを投稿しました！'); location.href='detail.jsp?no=" + no + "';</script>");
        return;
    }

    /* 댓글 삭제 처리 / コメント削除処理 */
    if ("reply_del".equals(cmd) && sessUser != null) {
        int r_no = Integer.parseInt(request.getParameter("r_no"));
        new ReplyDAO().deleteReply(r_no);
        String from = request.getParameter("from");
        out.println("<script>alert('コメントを削除しました。'); location.href='detail.jsp?no=" + no + "';</script>");
        return;
    }

    /* 글 삭제 처리 / 投稿削除処理 */
    if ("del".equals(cmd) && sessUser != null) {
        dao.deleteBoard(no);
        String from = request.getParameter("from");
        String redirectUrl = "mypage".equals(from) ? "mypage.jsp" : "community.jsp";
        out.println("<script>alert('削除しました。'); location.href='" + redirectUrl + "';</script>");
        return;
    }

    dao.updateViews(no);
    BoardDTO dto = dao.getBoard(no);
    String ctx = request.getContextPath();
    String writerId   = safe(dto.getWriter()).trim();
    String writerNick = safe(dto.getNickname()).trim();
    String authorPic  = normalizePic(findUserPic(writerId, true), ctx);
    
    if ("admin".equals(writerId)) {
        authorPic = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjIwMCIgdmlld0JveD0iMCAwIDIwMCAyMDAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CiAgPCEtLSDrsLDqsr0gLS0+CiAgPGNpcmNsZSBjeD0iMTAwIiBjeT0iMTAwIiByPSIxMDAiIGZpbGw9IiMxYTFhMmUiLz4KICA8Y2lyY2xlIGN4PSIxMDAiIGN5PSIxMDAiIHI9Ijk1IiBmaWxsPSJub25lIiBzdHJva2U9IiNmZGQ4MzUiIHN0cm9rZS13aWR0aD0iMyIvPgogIAogIDwhLS0g7JmV6rSAIOuquOyytCAtLT4KICA8cGF0aCBkPSJNNDAsMTMwIEw0MCw4NSBMNjUsMTA1IEwxMDAsNTUgTDEzNSwxMDUgTDE2MCw4NSBMMTYwLDEzMCBaIgogICAgICAgIGZpbGw9IiNmZGQ4MzUiIHN0cm9rZT0iI2Y5YTgyNSIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWpvaW49InJvdW5kIi8+CiAgCiAgPCEtLSDsmZXqtIAg7ZWY64uoIOudoCAtLT4KICA8cmVjdCB4PSIzOCIgeT0iMTI1IiB3aWR0aD0iMTI0IiBoZWlnaHQ9IjE4IiByeD0iNCIgZmlsbD0iI2Y5YTgyNSIvPgogIAogIDwhLS0g67O07ISdICjsg4Hri6ggM+qwnCkgLS0+CiAgPGNpcmNsZSBjeD0iMTAwIiBjeT0iNTgiIHI9IjkiIGZpbGw9IiNlNTM5MzUiLz4KICA8Y2lyY2xlIGN4PSIxMDAiIGN5PSI1OCIgcj0iNSIgZmlsbD0iI2ZmNTI1MiIvPgogIDxjaXJjbGUgY3g9IjEwMCIgY3k9IjU2IiByPSIyIiBmaWxsPSIjZmZmIiBvcGFjaXR5PSIwLjciLz4KICAKICA8Y2lyY2xlIGN4PSI0NyIgY3k9Ijk0IiByPSI3IiBmaWxsPSIjMTU2NWMwIi8+CiAgPGNpcmNsZSBjeD0iNDciIGN5PSI5NCIgcj0iNCIgZmlsbD0iIzFlODhlNSIvPgogIDxjaXJjbGUgY3g9IjQ3IiBjeT0iOTIiIHI9IjEuNSIgZmlsbD0iI2ZmZiIgb3BhY2l0eT0iMC43Ii8+CiAgCiAgPGNpcmNsZSBjeD0iMTUzIiBjeT0iOTQiIHI9IjciIGZpbGw9IiMyZTdkMzIiLz4KICA8Y2lyY2xlIGN4PSIxNTMiIGN5PSI5NCIgcj0iNCIgZmlsbD0iIzQzYTA0NyIvPgogIDxjaXJjbGUgY3g9IjE1MyIgY3k9IjkyIiByPSIxLjUiIGZpbGw9IiNmZmYiIG9wYWNpdHk9IjAuNyIvPgogIAogIDwhLS0g7JmV6rSAIOudoCDrs7TshJ0gLS0+CiAgPGNpcmNsZSBjeD0iNjgiIGN5PSIxMzQiIHI9IjUiIGZpbGw9IiNmZGQ4MzUiIHN0cm9rZT0iI2Y5YTgyNSIgc3Ryb2tlLXdpZHRoPSIxIi8+CiAgPGNpcmNsZSBjeD0iMTAwIiBjeT0iMTM0IiByPSI1IiBmaWxsPSIjZmRkODM1IiBzdHJva2U9IiNmOWE4MjUiIHN0cm9rZS13aWR0aD0iMSIvPgogIDxjaXJjbGUgY3g9IjEzMiIgY3k9IjEzNCIgcj0iNSIgZmlsbD0iI2ZkZDgzNSIgc3Ryb2tlPSIjZjlhODI1IiBzdHJva2Utd2lkdGg9IjEiLz4KPC9zdmc+Cg==";
    }

    boolean alreadyLiked = false;
    if (sessUser != null) alreadyLiked = dao.isLike(sessUser.getId(), no);

    ReplyDAO rDao = new ReplyDAO();
    ArrayList<ReplyDTO> replyList = rDao.getReplyList(no);
%>

<style>
    body { background-color: #fdfaf4 !important; font-family: 'OshidashiGothic', sans-serif !important; }

    
    .detail-outer {
        max-width: 1100px;
        margin: 50px auto 100px;
        padding: 0 20px;
        display: grid;
        grid-template-columns: 1fr 320px;
        gap: 30px;
        align-items: start;
    }

    
    .article-card {
        background: #fff;
        border-radius: 20px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.04);
        overflow: hidden;
    }

    
    .article-head {
        padding: 44px 52px 32px;
        border-bottom: 1px solid #f0f0f0;
    }

    .article-tag {
        display: inline-block;
        background: #fff9dc; color: #f57f17;
        font-size: 13px; font-weight: 700;
        padding: 5px 14px; border-radius: 20px;
        margin-bottom: 18px;
    }

    .article-title {
        font-size: 28px; font-weight: 900; color: #1a1a1a;
        line-height: 1.4; margin: 0 0 24px;
    }

    .article-meta {
        display: flex; justify-content: space-between; align-items: center;
    }

    .writer-info {
        display: flex; align-items: center; gap: 12px;
    }
    .writer-pic {
        width: 44px; height: 44px; border-radius: 50%;
        object-fit: cover; border: 2px solid #f0f0f0;
    }
    .writer-name { font-size: 15px; font-weight: 800; color: #333; }
    .writer-date { font-size: 13px; color: #aaa; margin-top: 2px; }

    .meta-right { display: flex; align-items: center; gap: 14px; }
    .view-count { font-size: 14px; color: #bbb; font-weight: 600; }

    
    .btn-like {
        display: flex; align-items: center; gap: 7px;
        background: #fff; color: #ff4757;
        border: 2px solid #ff4757; border-radius: 30px;
        padding: 9px 20px; font-size: 15px; font-weight: 800;
        cursor: pointer; transition: 0.2s;
        white-space: nowrap;
    }
    .btn-like:hover, .btn-like.active {
        background: #ff4757; color: #fff;
    }

    
    .article-body {
        padding: 40px 52px 44px;
        font-size: 17px; line-height: 1.9; color: #444;
        word-break: break-word;
        
        overflow: hidden;
    }

    
    .article-body img {
        display: block !important;
        width: 100% !important;       
        max-width: 100% !important;
        height: 350px !important;     
        margin: 24px auto !important;
        border-radius: 12px !important;
        object-fit: cover !important; 
    }

    
    .article-body iframe,
    .article-body video {
        max-width: 100% !important;
        height: auto !important;
    }

    
    .article-foot {
        display: flex; justify-content: flex-end; gap: 10px;
        padding: 20px 52px 30px;
        border-top: 1px solid #f5f5f5;
    }

    .btn-action {
        padding: 11px 24px; border-radius: 10px;
        font-size: 14px; font-weight: 800;
        cursor: pointer; border: none; transition: 0.2s;
    }
    .btn-list { background: #f5f5f5; color: #666; }
    .btn-list:hover { background: #e8e8e8; }
    .btn-edit { background: #fdd835; color: #333; }
    .btn-edit:hover { background: #fbc02d; }
    .btn-del  { background: #ffebee; color: #d32f2f; }
    .btn-del:hover  { background: #ffcdd2; }

    
    .comment-section {
        background: #fff; border-radius: 20px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.04);
        padding: 36px 52px;
        margin-top: 24px;
    }

    .comment-title {
        font-size: 18px; font-weight: 800; color: #222;
        margin: 0 0 24px; display: flex; align-items: center; gap: 8px;
    }
    .comment-count {
        background: #333; color: #fff;
        font-size: 12px; font-weight: 700;
        padding: 2px 9px; border-radius: 20px;
    }

    .comment-list { list-style: none; padding: 0; margin: 0 0 28px; }
    .comment-item {
        padding: 16px 0;
        border-bottom: 1px solid #f5f5f5;
        display: flex; gap: 12px;
    }
    .comment-item:last-child { border-bottom: none; }
    .comment-avatar {
        width: 36px; height: 36px; border-radius: 50%;
        background: #f0f0f0; display: flex; align-items: center; justify-content: center;
        flex-shrink: 0; font-size: 16px;
    }
    .comment-body { flex: 1; min-width: 0; }
    .comment-writer { font-size: 14px; font-weight: 800; color: #333; margin-bottom: 4px; }
    .comment-text { font-size: 15px; color: #555; line-height: 1.6; margin: 0; }
    .comment-date { font-size: 12px; color: #bbb; margin-top: 6px; }
    .comment-del-btn {
        background: none; border: none; color: #ddd;
        font-size: 13px; cursor: pointer; padding: 0; flex-shrink: 0;
        transition: 0.2s; align-self: flex-start; margin-top: 4px;
    }
    .comment-del-btn:hover { color: #ff4757; }

    .comment-empty { text-align: center; padding: 30px 0; color: #bbb; font-size: 15px; }

    
    .comment-form { display: flex; gap: 10px; }
    .comment-input {
        flex: 1; border: 1.5px solid #e8e8e8; border-radius: 12px;
        padding: 13px 18px; font-size: 15px; resize: none;
        font-family: 'OshidashiGothic', sans-serif;
        background: #fafafa; transition: 0.2s;
    }
    .comment-input:focus { border-color: #fdd835; background: #fff; outline: none; }
    .comment-submit {
        background: #333; color: #fff; border: none;
        border-radius: 12px; padding: 0 24px;
        font-size: 15px; font-weight: 800; cursor: pointer; transition: 0.2s;
        white-space: nowrap;
    }
    .comment-submit:hover { background: #fdd835; color: #111; }

    
    .aside-sticky {
        display: flex; flex-direction: column; gap: 20px;
        position: sticky;
        top: 80px; 
        align-self: flex-start; 
        max-height: calc(100vh - 100px);
        overflow-y: auto;
        scrollbar-width: none; 
    }
    .aside-sticky::-webkit-scrollbar { display: none; } 

    .side-card {
        background: #fff; border-radius: 16px;
        box-shadow: 0 6px 20px rgba(0,0,0,0.04);
        padding: 24px;
    }
    .side-title {
        font-size: 15px; font-weight: 800; color: #222;
        margin: 0 0 16px; display: flex; align-items: center; gap: 7px;
    }
    .side-title i { color: #fdd835; }

    .side-list { list-style: none; padding: 0; margin: 0; }
    .side-item {
        padding: 11px 0; border-bottom: 1px solid #f5f5f5;
        cursor: pointer; transition: 0.15s;
        display: flex; align-items: center; gap: 10px;
    }
    .side-item:last-child { border-bottom: none; }
    .side-item:hover .side-item-title { color: #f57f17; }
    .side-item-thumb {
        width: 52px; height: 52px; border-radius: 8px;
        object-fit: cover; flex-shrink: 0; background: #f5f5f5;
    }
    .side-item-info { flex: 1; min-width: 0; }
    .side-item-tag { font-size: 11px; color: #f57f17; font-weight: 700; margin-bottom: 3px; }
    .side-item-title {
        font-size: 13px; font-weight: 700; color: #333;
        overflow: hidden; text-overflow: ellipsis;
        display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical;
        transition: 0.15s;
    }
</style>

<div class="detail-outer">

    
    <div>
        <div class="article-card">
            
            <div class="article-head">
                <%
    String artTag = dto.getTag() != null ? dto.getTag() : "";
    String artTagRaw = artTag.startsWith("콘텐츠_") ? artTag.substring(4) : artTag;
    java.util.Map<String,String> tagMap = new java.util.HashMap<>();
    tagMap.put("강아지","犬"); tagMap.put("고양이","猫"); tagMap.put("건강","健康");
    tagMap.put("행동","しつけ"); tagMap.put("음식","食事"); tagMap.put("훈련","トレーニング");
    tagMap.put("견종백과","犬種図鑑"); tagMap.put("묘종백과","猫種図鑑"); tagMap.put("용품리뷰","用品レビュー");
    tagMap.put("입양정보","里親情報"); tagMap.put("미용케어","グルーミング"); tagMap.put("산책운동","散歩・運動");
    tagMap.put("콘텐츠","一般"); tagMap.put("일상","日常"); tagMap.put("기타","その他");
    String artTagDisplay = tagMap.containsKey(artTagRaw) ? tagMap.get(artTagRaw) : artTagRaw;
%>
                <span class="article-tag"># <%= artTagDisplay %></span>
                <h1 class="article-title"><%= escHtml(dto.getTitle()) %></h1>
                <div class="article-meta">
                    <div class="writer-info">
                        <img src="<%= authorPic %>" class="writer-pic"
                             onerror="this.src='<%=ctx%>/image/no_img.jpg'">
                        <div>
                            <div class="writer-name"><%= escHtml(writerNick) %></div>
                            <div class="writer-date"><%= dto.getDate() %></div>
                        </div>
                    </div>
                    <div class="meta-right">
                        <span class="view-count"><i class="far fa-eye"></i> <%= dto.getViews() %></span>
                        <button id="likeBtn"
                                class="btn-like <%= alreadyLiked ? "active" : "" %>"
                                onclick="likePost(<%= no %>)">
                            <i class="<%= alreadyLiked ? "fas" : "far" %> fa-heart"></i>
                            お気に入り <b id="likeCount"><%= dto.getLikes() %></b>
                        </button>
                    </div>
                </div>
            </div>

            
            <div class="article-body">
                <%= dto.getContent() != null ? dto.getContent().replace("\n", "<br>") : "" %>
            </div>

            
            <div class="article-foot">
                <button class="btn-action btn-list" onclick="location.href='community.jsp'">一覧へ</button>
                <% if (sessUser != null && sessUser.getId().equals(dto.getWriter())) { %>
                    <button class="btn-action btn-edit" onclick="location.href='update.jsp?no=<%= no %>'">編集</button>
                    <button class="btn-action btn-del"
                            onclick="if(confirm('本当に削除しますか？')) location.href='detail.jsp?no=<%= no %>&cmd=del'">削除</button>
                <% } %>
            </div>
        </div>

        
        <div class="comment-section">
            <h3 class="comment-title">
                <i class="fas fa-comment-dots" style="color:#fdd835;"></i>
                コメント
                <span class="comment-count"><%= replyList != null ? replyList.size() : 0 %></span>
            </h3>

            <ul class="comment-list">
                <%
                if (replyList == null || replyList.isEmpty()) {
                %>
                    <li class="comment-empty">まだコメントがありません。最初のコメントを残しましょう！🐾</li>
                <%
                } else {
                    for (ReplyDTO r : replyList) {
                %>
                    <li class="comment-item">
                        <div class="comment-avatar">🐾</div>
                        <div class="comment-body">
                            <div class="comment-writer"><%= escHtml(r.getWriter()) %></div>
                            <p class="comment-text"><%= escHtml(r.getContent()) %></p>
                            <div class="comment-date"><%= r.getDate() != null ? r.getDate().toString().substring(0,10) : "" %></div>
                        </div>
                        <% if (sessUser != null && (sessUser.getNickname().equals(r.getWriter()) || sessUser.getRole() == 1)) { %>
                            <button class="comment-del-btn"
                                     onclick="if(confirm('コメントを削除しますか？')) location.href='detail.jsp?no=<%= no %>&cmd=reply_del&r_no=<%= r.getR_no() %>'">
                                <i class="fas fa-times"></i>
                            </button>
                        <% } %>
                    </li>
                <%
                    }
                }
                %>
            </ul>

            
            <form action="detail.jsp?no=<%= no %>" method="post" class="comment-form">
                <input type="hidden" name="cmd"   value="reply_add">
                <input type="hidden" name="b_no"  value="<%= no %>">
                <input type="hidden" name="writer" value="<%= sessUser != null ? escHtml(sessUser.getId()) : "" %>">
                <textarea class="comment-input" name="content" rows="1"
                          placeholder="<%= sessUser != null ? "コメントを入力してください 🐾" : "ログイン後にコメントできます" %>"
                          <%= sessUser == null ? "disabled" : "" %>></textarea>
                <button type="submit" class="comment-submit"
                        <%= sessUser == null ? "disabled" : "" %>>投稿</button>
            </form>
        </div>
    </div>

    
    <aside class="aside-sticky">
        <%
        
        model.BoardDAO sideDao = new model.BoardDAO();
        ArrayList<BoardDTO> recentList = sideDao.getRecentList();
        if (recentList != null && !recentList.isEmpty()) {
        %>
        <div class="side-card">
            <h4 class="side-title"><i class="fas fa-clock"></i> 最新の投稿</h4>
            <ul class="side-list">
                <%
                int sideCount = 0;
                for (BoardDTO sb : recentList) {
                    if (sb.getNo() == no) continue;
                    if (sideCount++ >= 5) break;
                    String sPic = normalizePic(sb.getPic(), ctx);
                %>
                <li class="side-item" onclick="location.href='detail.jsp?no=<%= sb.getNo() %>'">
                    <img class="side-item-thumb" src="<%= sPic %>"
                         onerror="this.src='<%=ctx%>/image/no_img.jpg'">
                    <div class="side-item-info">
                        <%
    String sideTag = sb.getTag() != null ? sb.getTag() : "";
                    String sideTagRaw = sideTag.startsWith("콘텐츠_") ? sideTag.substring(4) : sideTag;
                    String sideTagDisplay = tagMap.containsKey(sideTagRaw) ? tagMap.get(sideTagRaw) : sideTagRaw;
%>
                        <div class="side-item-tag"># <%= sideTagDisplay %></div>
                        <div class="side-item-title"><%= escHtml(sb.getTitle()) %></div>
                    </div>
                </li>
                <% } %>
            </ul>
        </div>
        <% } %>
    </aside>

</div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script>
function likePost(boardNo) {
    <% if (sessUser == null) { %>
        alert("ログインが必要です。");
        return;
    <% } %>
    var $btn = $("#likeBtn");
    if ($btn.prop("disabled")) return;
    $btn.prop("disabled", true);

    $.ajax({
        url: "<%=ctx%>/blog/like_pro.jsp",
        type: "GET",
        data: { no: boardNo },
        success: function(res) {
            var result = res.trim();
            if (result === "fail" || isNaN(result)) {
                alert("エラー：" + result);
            } else {
                $("#likeCount").text(result);
                var $icon = $btn.find("i");
                if ($btn.hasClass("active")) {
                    $btn.removeClass("active");
                    $icon.removeClass("fas").addClass("far");
                } else {
                    $btn.addClass("active");
                    $icon.removeClass("far").addClass("fas");
                }
            }
        },
        error: function(xhr) { alert("サーバーエラー [" + xhr.status + "]"); },
        complete: function() { $btn.prop("disabled", false); }
    });
}
</script>

<%@ include file="../footer.jsp" %>
