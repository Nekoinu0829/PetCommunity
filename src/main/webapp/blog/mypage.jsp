<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>
<%@ page import="model.BoardDAO, model.BoardDTO, model.ReplyDAO, model.ReplyDTO, model.UserDTO, model.UserDAO, model.PetDAO, model.PetDTO" %>
<%@ page import="java.util.ArrayList" %>
<%@ include file="../header.jsp" %>

<%
    UserDTO sessUser = (UserDTO) session.getAttribute("user");
    if (sessUser == null) {
        out.println("<script>alert('ログインが必要なサービスです。'); location.href='" + request.getContextPath() + "/index.jsp';</script>");
        return;
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        request.setCharacterEncoding("UTF-8");
        String nickname = request.getParameter("nickname");
        String picData  = request.getParameter("pic");

        if (nickname == null || nickname.trim().isEmpty()) nickname = sessUser.getNickname();
        else nickname = nickname.trim();

        if (picData != null) { picData = picData.trim().replace(" ", "+"); }

        UserDTO updateDto = new UserDTO();
        updateDto.setId(sessUser.getId());
        updateDto.setNickname(nickname);

        if (picData == null || picData.isEmpty() || !picData.startsWith("data:image")) {
            updateDto.setPic(sessUser.getPic());
        } else {
            if (picData.length() > 220000) {
                out.println("<script>alert('画像サイズが大きすぎます。'); history.back();</script>"); return;
            }
            updateDto.setPic(picData);
        }

        int result = new UserDAO().updateMember(updateDto);
        if (result > 0) {
            sessUser.setNickname(updateDto.getNickname());
            sessUser.setPic(updateDto.getPic());
            session.setAttribute("user", sessUser);
            out.println("<script>alert('プロフィールを更新しました。'); location.href='mypage.jsp';</script>"); return;
        } else {
            out.println("<script>alert('更新に失敗しました。サーバーログをご確認ください。'); history.back();</script>"); return;
        }
    }

    BoardDAO bDao = new BoardDAO();
    ReplyDAO rDao = new ReplyDAO();
    ArrayList<BoardDTO>  myPosts   = null;
    ArrayList<ReplyDTO>  myReplies = null;
    try { myPosts   = bDao.getMyPosts(sessUser.getId());   } catch (Exception e) { myPosts   = new ArrayList<>(); }
    try { myReplies = rDao.getMyReplies(sessUser.getId()); } catch (Exception e) { myReplies = new ArrayList<>(); }

    String userPic = sessUser.getPic();
    String profileSrc;
    if (userPic == null || userPic.isEmpty()) {
        profileSrc = request.getContextPath() + "/images/no_img.png";
    } else if (userPic.startsWith("data:image") || userPic.startsWith("http")) {
        profileSrc = userPic;
    } else {
        profileSrc = request.getContextPath() + "/upload/" + userPic;
    }

    String nick    = sessUser.getNickname();
    String initial = (nick != null && nick.length() > 0) ? String.valueOf(nick.charAt(0)) : "?";
    boolean hasPic = (userPic != null && !userPic.isEmpty());
    int postCnt    = (myPosts   != null) ? myPosts.size()   : 0;
    int replyCnt   = (myReplies != null) ? myReplies.size() : 0;

    
    PetDAO petDao = new PetDAO();
    java.util.ArrayList<PetDTO> petList = petDao.getPetList(sessUser.getId());
%>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700;900&display=swap" rel="stylesheet">

<style>
:root {
    --yellow:     #fdd835;
    --yellow-lt:  #fff9c4;
    --yellow-md:  #fff176;
    --peach:      #ffe0b2;
    --peach-lt:   #fff3e0;
    --mint:       #e0f7ee;
    --lavender:   #ede7f6;
    --pink-lt:    #fce4ec;
    --bg:         #fdfaf4;
    --card:       #ffffff;
    --text:       #3d2c1e;
    --text-mid:   #6b5244;
    --text-muted: #b0968a;
    --line:       #f0e6dd;
    --r-sm:  14px;
    --r-md:  22px;
    --r-lg:  30px;
    --r-xl:  38px;
    --shadow-sm: 0 4px 14px rgba(0,0,0,0.04);
    --shadow-md: 0 10px 30px rgba(0,0,0,0.05);
}
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
body { background: #fdfaf4 !important; font-family: 'OshidashiGothic', sans-serif !important; color: var(--text); -webkit-font-smoothing: antialiased; }

.mp-layout { max-width: 1100px; margin: 50px auto 100px; padding: 0 20px; display: grid; grid-template-columns: 290px 1fr; gap: 24px; align-items: start; }
.mp-sidebar { position: sticky; top: 20px; display: flex; flex-direction: column; gap: 14px; }

.mp-profile-card { background: var(--card); border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.03); padding: 30px 24px 24px; display: flex; flex-direction: column; align-items: center; text-align: center; position: relative; overflow: hidden; }
.mp-profile-card::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 80px; background: linear-gradient(135deg, var(--yellow-lt) 0%, var(--yellow-md) 55%, var(--yellow-lt) 100%); border-radius: 20px 20px 60% 60% / 20px 20px 40px 40px; z-index: 0; }

.mp-avatar-wrap { position: relative; z-index: 2; margin-bottom: 14px; }
.mp-avatar-ring { width: 100px; height: 100px; border-radius: 50%; background: linear-gradient(145deg, var(--yellow), #ffca28, var(--peach)); padding: 4px; box-shadow: 0 4px 20px rgba(253,216,53,0.35), 0 0 0 6px rgba(253,216,53,0.12); display: flex; align-items: center; justify-content: center; }
.mp-avatar-inner { width: 100%; height: 100%; border-radius: 50%; background: #fff; overflow: hidden; display: flex; align-items: center; justify-content: center; }
.mp-avatar-img  { width: 100%; height: 100%; object-fit: cover; border-radius: 50%; }
.mp-avatar-initial { font-size: 38px; font-weight: 900; color: var(--yellow); font-family: 'OshidashiGothic', sans-serif; line-height: 1; }
.mp-edit-btn { position: absolute; bottom: 2px; right: 2px; width: 28px; height: 28px; border-radius: 50%; background: var(--yellow); color: #5d4037; border: 2.5px solid #fff; display: flex; align-items: center; justify-content: center; cursor: pointer; font-size: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.13); transition: transform 0.2s, box-shadow 0.2s; }
.mp-edit-btn:hover { transform: scale(1.2) rotate(-15deg); box-shadow: 0 4px 14px rgba(253,216,53,0.4); }

.mp-nickname { font-size: 21px; font-weight: 900; color: var(--text); letter-spacing: -0.3px; margin-bottom: 4px; z-index: 2; position: relative; }
.mp-email    { font-size: 13px; color: var(--text-muted); margin-bottom: 20px; z-index: 2; position: relative; }

.mp-stats { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; width: 100%; margin-bottom: 16px; }
.mp-stat { background: var(--bg); border-radius: var(--r-md); padding: 12px 8px; text-align: center; border: 1.5px solid var(--line); cursor: default; }
.mp-stat:first-child { background: var(--yellow-lt); border-color: var(--yellow-md); }
.mp-stat:last-child  { background: var(--peach-lt);  border-color: var(--peach); }
.mp-stat-num   { display: block; font-size: 28px; font-weight: 900; color: var(--text); font-family: 'OshidashiGothic', sans-serif; line-height: 1.1; }
.mp-stat-label { font-size: 12px; color: var(--text-muted); font-weight: 700; }

.mp-modify-btn { width: 100%; padding: 12px; border-radius: var(--r-md); background: var(--yellow); color: #5d4037; font-size: 15px; font-weight: 800; border: none; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 7px; box-shadow: 0 4px 14px rgba(253,216,53,0.35); transition: all 0.2s; font-family: 'OshidashiGothic', sans-serif; }
.mp-modify-btn:hover { transform: translateY(-2px); box-shadow: 0 8px 22px rgba(253,216,53,0.45); }

.mp-like-box { background: var(--card); border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.03); padding: 16px; display: flex; align-items: center; gap: 14px; text-decoration: none; border: 1px solid #f0f0f0; transition: all 0.2s; }
.mp-like-box:hover { transform: translateY(-3px); box-shadow: 0 15px 25px rgba(233,30,99,0.08); border-color: #f48fb1; }
.mp-like-icon-wrap { width: 46px; height: 46px; border-radius: 50%; background: var(--pink-lt); display: flex; align-items: center; justify-content: center; font-size: 22px; flex-shrink: 0; animation: hbeat 2.2s ease-in-out infinite; }
@keyframes hbeat { 0%,60%,100% { transform: scale(1); } 30% { transform: scale(1.15); } 45% { transform: scale(1.05); } }
.mp-like-text-wrap { flex: 1; }
.mp-like-title { font-size: 15px; font-weight: 800; color: var(--text); margin-bottom: 1px; }
.mp-like-sub   { font-size: 12px; color: var(--text-muted); }
.mp-like-arrow { font-size: 16px; color: var(--text-muted); }

.mp-pets-card { background: var(--card); border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.03); padding: 20px; border: 1px solid #f0f0f0; }
.mp-pets-head { display: flex; align-items: center; margin-bottom: 14px; }
.mp-pets-head h3 { font-size: 14px; font-weight: 800; color: var(--text-mid); text-transform: uppercase; letter-spacing: 0.8px; display: flex; align-items: center; gap: 6px; }
.mp-pets-head h3 i { color: #66bb6a; font-size: 13px; }

.pet-slots { display: flex; flex-wrap: wrap; gap: 10px; align-items: center; }
.pet-slot  { display: flex; flex-direction: column; align-items: center; gap: 5px; cursor: pointer; }
.pet-circle {
    width: 52px; height: 52px; border-radius: 50%;
    object-fit: cover; border: 2.5px solid var(--line);
    transition: all 0.22s; box-shadow: 0 2px 8px rgba(0,0,0,0.07);
    background: #f5f5f5; display: block;
}
.pet-circle:hover { border-color: var(--yellow); transform: scale(1.1) translateY(-2px); box-shadow: 0 6px 18px rgba(253,216,53,0.3); }
.pet-name { font-size: 12px; font-weight: 700; color: var(--text-muted); max-width: 52px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; text-align: center; }
.pet-add-btn { width: 52px; height: 52px; border-radius: 50%; border: 2px dashed #ddd; background: var(--bg); display: flex; align-items: center; justify-content: center; cursor: pointer; transition: all 0.2s; }
.pet-add-btn:hover { border-color: var(--yellow); background: var(--yellow-lt); }
.pet-add-btn i { font-size: 16px; color: #ccc; transition: color 0.2s; }
.pet-add-btn:hover i { color: #f9a825; }

.mp-content { display: flex; flex-direction: column; gap: 0; }

.tab-bar { display: flex; gap: 6px; background: var(--card); border-radius: 20px 20px 0 0; padding: 8px 8px 0; box-shadow: 0 10px 30px rgba(0,0,0,0.03); }
.tab-btn { flex: 1; padding: 13px 10px; border-radius: var(--r-md) var(--r-md) 0 0; border: none; background: none; font-size: 15px; font-weight: 700; color: var(--text-muted); cursor: pointer; transition: all 0.22s; display: flex; align-items: center; justify-content: center; gap: 7px; font-family: 'OshidashiGothic', sans-serif; position: relative; bottom: -1px; }
.tab-btn:hover:not(.active) { background: var(--bg); color: var(--text-mid); }
.tab-btn.active { background: var(--bg); color: var(--text); border: 1.5px solid var(--line); border-bottom: 2px solid var(--bg); font-weight: 900; }
.tab-count { font-size: 12px; font-weight: 800; padding: 2px 8px; border-radius: 20px; background: var(--line); color: var(--text-muted); }
.tab-btn.active .tab-count { background: var(--yellow-lt); color: #8B6914; }

.tab-panels-wrap { background: var(--bg); border: 1px solid #f0f0f0; border-top: none; border-radius: 0 0 20px 20px; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.03); }
.tab-panel { display: none; }
.tab-panel.active { display: block; animation: panelIn 0.22s ease both; }
@keyframes panelIn { from { opacity: 0; transform: translateY(6px); } to { opacity: 1; transform: translateY(0); } }

.list-card { background: var(--card); }
.list-item { display: flex; align-items: center; gap: 14px; padding: 15px 22px; border-bottom: 1px solid var(--line); transition: background 0.15s; position: relative; }
.list-item:last-child { border-bottom: none; }
.list-item:hover { background: var(--yellow-lt); }
.list-num   { font-size: 13px; font-weight: 900; color: #e0d0c8; width: 22px; text-align: center; flex-shrink: 0; }
.list-title { flex: 1; font-size: 16px; font-weight: 600; color: var(--text-mid); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; cursor: pointer; transition: color 0.15s; }
.list-item:hover .list-title { color: var(--text); }
.list-date  { font-size: 13px; color: var(--text-muted); flex-shrink: 0; }
.list-actions { display: flex; gap: 5px; flex-shrink: 0; opacity: 0; transition: opacity 0.2s; }
.list-item:hover .list-actions { opacity: 1; }
.btn-act { padding: 5px 12px; border-radius: 10px; font-size: 13px; font-weight: 700; cursor: pointer; border: none; transition: all 0.18s; font-family: 'OshidashiGothic', sans-serif; }
.btn-act.edit { background: var(--yellow-lt); color: #8B6914; }
.btn-act.edit:hover { background: var(--yellow); transform: translateY(-1px); }
.btn-act.del  { background: var(--pink-lt); color: #c62828; }
.btn-act.del:hover  { background: #ffcdd2; transform: translateY(-1px); }
.empty-panel { padding: 64px 20px; text-align: center; }
.empty-panel .empty-icon { font-size: 42px; display: block; margin-bottom: 12px; }
.empty-panel p { font-size: 16px; color: var(--text-muted); font-weight: 500; }

.modal-overlay, .pet-modal-overlay { display: none; position: fixed; inset: 0; z-index: 9999; background: rgba(80,50,30,0.35); align-items: center; justify-content: center; backdrop-filter: blur(6px); }
.modal-box, .pet-modal-box { background: var(--card); border-radius: 20px; padding: 44px 38px; width: 100%; max-width: 400px; position: relative; box-shadow: 0 10px 30px rgba(0,0,0,0.08); animation: popIn 0.28s cubic-bezier(.34,1.56,.64,1); }
.pet-modal-box { max-width: 360px; }
@keyframes popIn { from { opacity:0; transform:scale(0.88) translateY(20px); } to { opacity:1; transform:scale(1) translateY(0); } }
.modal-close, .pet-modal-close { position: absolute; top: 16px; right: 18px; background: var(--bg); border: none; border-radius: 50%; width: 32px; height: 32px; font-size: 18px; color: var(--text-muted); cursor: pointer; display: flex; align-items: center; justify-content: center; transition: all 0.2s; }
.modal-close:hover, .pet-modal-close:hover { background: var(--yellow); color: var(--text); transform: rotate(90deg); }
.modal-title, .pet-modal-title { font-size: 22px; font-weight: 900; color: var(--text); margin: 0 0 26px; text-align: center; font-family: 'OshidashiGothic', sans-serif; }
.modal-avatar-wrap, .pet-preview-wrap { display: flex; justify-content: center; margin-bottom: 22px; }
.modal-avatar { width: 88px; height: 88px; border-radius: 50%; object-fit: cover; box-shadow: 0 0 0 4px #fff, 0 0 0 7px var(--yellow), 0 8px 24px rgba(253,216,53,0.25); }
.modal-label { display: block; font-size: 13px; font-weight: 700; color: var(--text-muted); margin-bottom: 7px; text-transform: uppercase; letter-spacing: 0.7px; }
.file-row { display: flex; align-items: center; gap: 10px; margin-bottom: 18px; }
.file-select-btn { background: var(--yellow-lt); border: 1.5px solid var(--yellow-md); color: #8B6914; font-size: 14px; font-weight: 700; padding: 9px 16px; border-radius: var(--r-sm); cursor: pointer; transition: all 0.2s; white-space: nowrap; font-family: 'OshidashiGothic', sans-serif; }
.file-select-btn:hover { background: var(--yellow); border-color: var(--yellow); }
.file-name-text { font-size: 13px; color: var(--text-muted); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.modal-input { width: 100%; height: 48px; border: 1px solid #e8e8e8; border-radius: 15px; font-size: 16px; padding: 0 16px; background: var(--bg); transition: all 0.2s; margin-bottom: 18px; font-family: 'OshidashiGothic', sans-serif; color: var(--text); }
.modal-input:focus { border-color: var(--yellow); background: #fff; outline: none; box-shadow: 0 0 0 4px rgba(253,216,53,0.18); }
.btn-save { width: 100%; height: 50px; border: none; border-radius: 30px; background: var(--yellow); color: #5d4037; font-size: 17px; font-weight: 800; cursor: pointer; transition: all 0.2s; box-shadow: 0 4px 10px rgba(253,216,53,0.3); font-family: 'OshidashiGothic', sans-serif; }
.btn-save:hover { background: #fbc02d; transform: translateY(-2px); box-shadow: 0 8px 22px rgba(253,216,53,0.45); }

.pet-btn-row { display: flex; gap: 10px; }
.pet-btn-row .btn-save { flex: 1; }
.btn-pet-del { flex: 1; height: 50px; border: none; border-radius: 30px; background: #ffebee; color: #c62828; font-size: 17px; font-weight: 800; cursor: pointer; transition: all 0.2s; font-family: 'OshidashiGothic', sans-serif; }
.btn-pet-del:hover { background: #c62828; color: #fff; transform: translateY(-2px); }

.pet-preview { width: 84px; height: 84px; border-radius: 50%; background: var(--bg); border: 3px solid var(--line); display: flex; align-items: center; justify-content: center; overflow: hidden; }
.pet-preview-img { width: 84px; height: 84px; border-radius: 50%; object-fit: cover; display: none; }
.pet-preview-placeholder { font-size: 32px; }

@media (max-width: 720px) {
    .mp-layout { grid-template-columns: 1fr; }
    .mp-sidebar { position: static; }
    .tab-bar { border-radius: 20px; }
    .tab-btn.active { border-bottom: none; }
    .tab-panels-wrap { border-radius: 20px; border-top: 1px solid #f0f0f0; margin-top: 8px; }
}
</style>

<div class="mp-layout">
    <aside class="mp-sidebar">

        
        <div class="mp-profile-card">
            <div class="mp-avatar-wrap">
                <div class="mp-avatar-ring">
                    <div class="mp-avatar-inner">
                        <% if (hasPic) { %>
                            <img src="<%= profileSrc %>" class="mp-avatar-img" id="sideAvatar"
                                 onerror="this.style.display='none';document.getElementById('sideInitial').style.display='flex';">
                            <div class="mp-avatar-initial" id="sideInitial" style="display:none;"><%= initial %></div>
                        <% } else { %>
                            <div class="mp-avatar-initial" id="sideInitial"><%= initial %></div>
                        <% } %>
                    </div>
                </div>
                <button class="mp-edit-btn" onclick="openModal()" title="プロフィール編集">
                    <i class="fas fa-pen"></i>
                </button>
            </div>
            <p class="mp-nickname"><%= nick %></p>
            <p class="mp-email"><%= sessUser.getId() %></p>
            <div class="mp-stats">
                <div class="mp-stat">
                    <span class="mp-stat-num"><%= postCnt %></span>
                    <span class="mp-stat-label">📝 投稿</span>
                </div>
                <div class="mp-stat">
                    <span class="mp-stat-num"><%= replyCnt %></span>
                    <span class="mp-stat-label">💬 コメント</span>
                </div>
            </div>
            <button class="mp-modify-btn" onclick="openModal()">
                <i class="fas fa-pen"></i> 情報を編集
            </button>
        </div>

        
        <a class="mp-like-box" href="${pageContext.request.contextPath}/blog/like_list.jsp">
            <div class="mp-like-icon-wrap">❤️</div>
            <div class="mp-like-text-wrap">
                <div class="mp-like-title">お気に入りを見る</div>
                <div class="mp-like-sub">保存した投稿</div>
            </div>
            <span class="mp-like-arrow"><i class="fas fa-chevron-right"></i></span>
        </a>

        
        <div class="mp-pets-card">
            <div class="mp-pets-head">
                <h3><i class="fas fa-paw"></i> 私のペット</h3>
            </div>
            <div class="pet-slots" id="petSlots">
                
                <% for (PetDTO pet : petList) {
                    String petPicSrc = (pet.getPetPic() != null && !pet.getPetPic().isEmpty()) ? pet.getPetPic() : "";
                    String safeName  = pet.getPetName().replace("'", "\\'");
                %>
                <div class="pet-slot">
                    <% if (!petPicSrc.isEmpty()) { %>
                        <img class="pet-circle" src="<%= petPicSrc %>" alt="<%= pet.getPetName() %>"
                             onclick="editPet(<%= pet.getPetNo() %>, '<%= safeName %>', this.src)">
                    <% } else { %>
                        <div class="pet-circle" style="display:flex;align-items:center;justify-content:center;font-size:22px;cursor:pointer;"
                             onclick="editPet(<%= pet.getPetNo() %>, '<%= safeName %>', '')">🐾</div>
                    <% } %>
                    <span class="pet-name"><%= pet.getPetName() %></span>
                </div>
                <% } %>
                
                <% if (petList.size() < 6) { %>
                <div class="pet-slot">
                    <div class="pet-add-btn" onclick="openPetModal(-1, '', '')"><i class="fas fa-plus"></i></div>
                    <span class="pet-name" style="color:#ccc;">追加</span>
                </div>
                <% } %>
            </div>
        </div>

    </aside>

    
    <main class="mp-content">
        <div class="tab-bar">
            <button class="tab-btn active" onclick="switchTab('posts', this)">
                <i class="fas fa-pen-nib"></i> 私の投稿
                <span class="tab-count"><%= postCnt %></span>
            </button>
            <button class="tab-btn" onclick="switchTab('replies', this)">
                <i class="fas fa-comment-dots"></i> 私のコメント
                <span class="tab-count"><%= replyCnt %></span>
            </button>
        </div>
        <div class="tab-panels-wrap">
            <div id="panel-posts" class="tab-panel active">
                <div class="list-card">
                    <% if (myPosts == null || myPosts.isEmpty()) { %>
                        <div class="empty-panel"><span class="empty-icon">📭</span><p>まだ投稿がありません</p></div>
                    <% } else { int pi = 1; for (BoardDTO b : myPosts) { %>
                        <div class="list-item">
                            <span class="list-num"><%= pi++ %></span>
                            <span class="list-title" onclick="location.href='detail.jsp?no=<%= b.getNo() %>&from=mypage'"><%= b.getTitle() %></span>
                            <span class="list-date"><%= (b.getDate() != null) ? b.getDate().toString().substring(0,10) : "" %></span>
                            <div class="list-actions">
                                <button class="btn-act edit" onclick="event.stopPropagation();location.href='update.jsp?no=<%= b.getNo() %>'">編集</button>
                                <button class="btn-act del"  onclick="event.stopPropagation();if(confirm('本当に削除しますか？'))location.href='detail.jsp?no=<%= b.getNo() %>&cmd=del&from=mypage'">削除</button>
                            </div>
                        </div>
                    <% } } %>
                </div>
            </div>
            <div id="panel-replies" class="tab-panel">
                <div class="list-card">
                    <% if (myReplies == null || myReplies.isEmpty()) { %>
                        <div class="empty-panel"><span class="empty-icon">💬</span><p>まだコメントがありません</p></div>
                    <% } else { int ri = 1; for (ReplyDTO r : myReplies) { %>
                        <div class="list-item">
                            <span class="list-num"><%= ri++ %></span>
                            <span class="list-title" onclick="location.href='detail.jsp?no=<%= r.getB_no() %>'"><%= r.getContent() %></span>
                            <span class="list-date"><%= (r.getDate() != null) ? r.getDate().toString().substring(0,10) : "" %></span>
                        </div>
                    <% } } %>
                </div>
            </div>
        </div>
    </main>
</div>


<div id="editModal" class="modal-overlay">
    <div class="modal-box">
        <button class="modal-close" onclick="closeModal()">&times;</button>
        <h2 class="modal-title">✏️ 情報を編集</h2>
        <form action="mypage.jsp" method="post">
            <input type="hidden" name="pic" id="hiddenPicData">
            <div class="modal-avatar-wrap">
                <% if (hasPic) { %>
                    <img src="<%= profileSrc %>" id="preview" class="modal-avatar"
                         onerror="this.style.display='none';document.getElementById('modalInitial').style.display='flex';">
                    <div id="modalInitial" class="modal-avatar" style="display:none;background:linear-gradient(135deg,#fdd835,#ffb300);align-items:center;justify-content:center;font-size:28px;font-weight:900;color:#fff;"><%= initial %></div>
                <% } else { %>
                    <img src="" id="preview" class="modal-avatar" style="display:none;">
                    <div id="modalInitial" class="modal-avatar" style="display:flex;background:linear-gradient(135deg,#fdd835,#ffb300);align-items:center;justify-content:center;font-size:28px;font-weight:900;color:#fff;"><%= initial %></div>
                <% } %>
            </div>
            <label class="modal-label">プロフィール写真</label>
            <div class="file-row">
                <label for="modalPic" class="file-select-btn">📷 ファイルを選択</label>
                <span id="modalFileName" class="file-name-text">ファイルが選択されていません</span>
                <input type="file" id="modalPic" accept="image/*" style="display:none;">
            </div>
            <label class="modal-label">ニックネーム</label>
            <input type="text" name="nickname" class="modal-input" value="<%= sessUser.getNickname() %>">
            <button type="submit" class="btn-save">保存完了</button>
        </form>
    </div>
</div>


<div id="petModal" class="pet-modal-overlay">
    <div class="pet-modal-box">
        <button class="pet-modal-close" onclick="closePetModal()">&times;</button>
        <h2 class="pet-modal-title" id="petModalTitle">🐾 ペット追加</h2>
        <div class="pet-preview-wrap">
            <div class="pet-preview">
                <img id="petPreviewImg" class="pet-preview-img">
                <span id="petPreviewIcon" class="pet-preview-placeholder">🐾</span>
            </div>
        </div>
        <div class="file-row" style="justify-content:center; margin-bottom:18px;">
            <label for="petPicInput" class="file-select-btn">📷 写真を選択</label>
            <span id="petFileName" class="file-name-text">ファイルが選択されていません</span>
            <input type="file" id="petPicInput" accept="image/*" style="display:none;">
        </div>
        <label class="modal-label">名前</label>
        <input type="text" id="petNameInput" class="modal-input" placeholder="ペットの名前を入力してください" maxlength="10">
        <div id="petBtnAdd">
            <button class="btn-save" onclick="savePet()">追加完了</button>
        </div>
        <div id="petBtnEdit" class="pet-btn-row" style="display:none;">
            <button class="btn-save" onclick="savePet()">保存完了</button>
            <button class="btn-pet-del" onclick="deletePetFromModal()">🗑 削除</button>
        </div>
    </div>
</div>

<script>
function switchTab(name, btn) {
    document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
    document.getElementById('panel-' + name).classList.add('active');
    btn.classList.add('active');
}

function openModal()  { document.getElementById('editModal').style.display = 'flex'; }
function closeModal() { document.getElementById('editModal').style.display = 'none'; }
window.addEventListener('click', function(e) {
    if (e.target === document.getElementById('editModal'))  closeModal();
    if (e.target === document.getElementById('petModal'))   closePetModal();
});

(function () {
    const fileInput = document.getElementById('modalPic');
    const hiddenPic = document.getElementById('hiddenPicData');
    const preview   = document.getElementById('preview');
    const fileName  = document.getElementById('modalFileName');
    if (!fileInput) return;
    fileInput.addEventListener('change', function (e) {
        const file = e.target.files && e.target.files[0];
        if (!file) return;
        if (fileName) fileName.textContent = file.name;
        const reader = new FileReader();
        reader.onload = function (ev) {
            const img = new Image();
            img.onload = function () {
                const MAX = 320; let w = img.width, h = img.height;
                if (w > h && w > MAX) { h = Math.round(h * MAX / w); w = MAX; }
                else if (h >= w && h > MAX) { w = Math.round(w * MAX / h); h = MAX; }
                const canvas = document.createElement('canvas');
                canvas.width = w; canvas.height = h;
                canvas.getContext('2d').drawImage(img, 0, 0, w, h);
                let quality = 0.75, dataUrl = canvas.toDataURL('image/jpeg', quality);
                const TARGET = 120 * 1024;
                while (Math.floor(dataUrl.length * 3 / 4) > TARGET && quality > 0.2) {
                    quality -= 0.08; dataUrl = canvas.toDataURL('image/jpeg', quality);
                }
                hiddenPic.value = dataUrl;
                if (preview) { preview.src = dataUrl; preview.style.display = ''; }
                const mi = document.getElementById('modalInitial'); if (mi) mi.style.display = 'none';
                const sa = document.getElementById('sideAvatar');
                const si = document.getElementById('sideInitial');
                if (sa) { sa.src = dataUrl; sa.style.display = ''; }
                if (si) si.style.display = 'none';
            };
            img.src = ev.target.result;
        };
        reader.readAsDataURL(file);
    });
})();

let petPicData = '';
let editPetNo  = -1;

function openPetModal(petNo, petName, petPic) {
    editPetNo  = (petNo > 0) ? petNo : -1;
    petPicData = petPic || '';

    document.getElementById('petNameInput').value = petName || '';
    const previewImg  = document.getElementById('petPreviewImg');
    const previewIcon = document.getElementById('petPreviewIcon');

    if (petPicData) {
        previewImg.src = petPicData;
        previewImg.style.display = 'block';
        previewIcon.style.display = 'none';
    } else {
        previewImg.style.display = 'none';
        previewIcon.style.display = '';
    }
    document.getElementById('petFileName').textContent = 'ファイルが選択されていません';

    const isEdit = (editPetNo > 0);
    document.getElementById('petModalTitle').textContent = isEdit ? '🐾 ペット編集' : '🐾 ペット追加';
    document.getElementById('petBtnAdd').style.display  = isEdit ? 'none'  : 'block';
    document.getElementById('petBtnEdit').style.display = isEdit ? 'flex'  : 'none';

    document.getElementById('petModal').style.display = 'flex';
}

function editPet(petNo, petName, petPic) { openPetModal(petNo, petName, petPic); }
function closePetModal() { document.getElementById('petModal').style.display = 'none'; }

function savePet() {
    const name = document.getElementById('petNameInput').value.trim();
    if (!name) { alert('名前を入力してください！'); return; }
    const cmd = (editPetNo > 0) ? 'update' : 'insert';
    const params = new URLSearchParams();
    params.append('cmd', cmd);
    params.append('petName', name);
    params.append('petPic',  petPicData);
    if (editPetNo > 0) params.append('petNo', editPetNo);
    fetch('${pageContext.request.contextPath}/PetController', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params.toString()
    })
    .then(r => r.json())
    .then(data => {
        if (data.result === 'ok') {
            const msg = (cmd === 'insert') ? '登録しました！' : '更新しました！';
            alert(msg);
            closePetModal();
            location.reload();
        } else alert(data.msg || '保存失敗');
    })
    .catch(() => alert('サーバーエラー。PetControllerが登録されているか確認してください。'));
}

function deletePetFromModal() {
    const name = document.getElementById('petNameInput').value || 'このペット';
    if (!confirm(name + 'を削除しますか？')) return;
    const params = new URLSearchParams();
    params.append('cmd',   'delete');
    params.append('petNo', editPetNo);
    fetch('${pageContext.request.contextPath}/PetController', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params.toString()
    })
    .then(r => r.json())
    .then(data => {
        if (data.result === 'ok') {
            alert('削除しました。');
            closePetModal();
            location.reload();
        } else alert(data.msg || '削除失敗');
    });
}

document.getElementById('petPicInput').addEventListener('change', function(e) {
    const file = e.target.files[0];
    if (!file) return;
    document.getElementById('petFileName').textContent = file.name;
    const reader = new FileReader();
    reader.onload = function(ev) {
        const img = new Image();
        img.onload = function() {
            const MAX = 200; let w = img.width, h = img.height;
            if (w > h && w > MAX) { h = Math.round(h * MAX / w); w = MAX; }
            else if (h >= w && h > MAX) { w = Math.round(w * MAX / h); h = MAX; }
            const canvas = document.createElement('canvas');
            canvas.width = w; canvas.height = h;
            canvas.getContext('2d').drawImage(img, 0, 0, w, h);
            petPicData = canvas.toDataURL('image/jpeg', 0.8);
            document.getElementById('petPreviewImg').src = petPicData;
            document.getElementById('petPreviewImg').style.display = 'block';
            document.getElementById('petPreviewIcon').style.display = 'none';
        };
        img.src = ev.target.result;
    };
    reader.readAsDataURL(file);
});
</script>

<%@ include file="../footer.jsp" %>
