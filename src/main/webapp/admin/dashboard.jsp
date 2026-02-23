<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.UserDTO, java.util.ArrayList, java.sql.*, util.DBManager" %>
<%
    UserDTO adminUser = (UserDTO) session.getAttribute("user");
    
    if(adminUser == null || adminUser.getRole() != 1) {
%>
    <script>
        alert("管理者のみアクセス可能なページです。🚫");
        location.href = "../index.jsp";
    </script>
<%
        return;
    }

    
    String delAction = request.getParameter("action");
    String delId     = request.getParameter("delId");
    if ("deleteMember".equals(delAction) && delId != null && !delId.isEmpty()) {
        Connection dc = null; PreparedStatement dp = null;
        try {
            dc = DBManager.getConnection();
            dc.setAutoCommit(false);
            
            dp = dc.prepareStatement("DELETE FROM BOARD_LIKE WHERE ID = ?");
            dp.setString(1, delId); dp.executeUpdate(); dp.close();
            
            dp = dc.prepareStatement("DELETE FROM BOARD WHERE B_WRITER = ?");
            dp.setString(1, delId); dp.executeUpdate(); dp.close();
            
            dp = dc.prepareStatement("DELETE FROM MEMBER WHERE ID = ?");
            dp.setString(1, delId); dp.executeUpdate();
            dc.commit();
        } catch(Exception e) {
            try { if(dc != null) dc.rollback(); } catch(Exception ex) {}
            e.printStackTrace();
        } finally {
            try { if(dc != null) dc.setAutoCommit(true); } catch(Exception ex) {}
            DBManager.close(dc, dp, null);
        }
    }

    
    int totalMembers = 0;
    int totalBoards  = 0;
    int totalReplies = 0;

    Connection sc = null; PreparedStatement sp = null; ResultSet sr = null;
    try {
        sc = DBManager.getConnection();
        sp = sc.prepareStatement("SELECT COUNT(*) FROM MEMBER WHERE ROLE != 1");
        sr = sp.executeQuery(); if(sr.next()) totalMembers = sr.getInt(1); sr.close(); sp.close();

        sp = sc.prepareStatement("SELECT COUNT(*) FROM BOARD WHERE B_TAG != '콘텐츠'");
        sr = sp.executeQuery(); if(sr.next()) totalBoards = sr.getInt(1); sr.close(); sp.close();

        sp = sc.prepareStatement("SELECT COUNT(*) FROM REPLY");
        sr = sp.executeQuery(); if(sr.next()) totalReplies = sr.getInt(1);
    } catch(Exception e) { e.printStackTrace(); }
    finally { DBManager.close(sc, sp, sr); }

    
    ArrayList<UserDTO> recentMembers = new ArrayList<>();
    Connection mc = null; PreparedStatement mp = null; ResultSet mr = null;
    try {
        mc = DBManager.getConnection();
        mp = mc.prepareStatement(
            "SELECT * FROM (SELECT * FROM MEMBER WHERE ROLE != 1 ORDER BY JOIN_DATE DESC) WHERE ROWNUM <= 5"
        );
        mr = mp.executeQuery();
        while(mr.next()) {
            UserDTO u = new UserDTO();
            u.setId(mr.getString("ID"));
            u.setNickname(mr.getString("NICKNAME"));
            u.setJoinDate(mr.getDate("JOIN_DATE"));
            recentMembers.add(u);
        }
    } catch(Exception e) { e.printStackTrace(); }
    finally { DBManager.close(mc, mp, mr); }

    
    ArrayList<String[]> recentReplies = new ArrayList<>();
    Connection rc = null; PreparedStatement rp = null; ResultSet rr = null;
    try {
        rc = DBManager.getConnection();
        rp = rc.prepareStatement(
            "SELECT * FROM (SELECT r.R_NO, m.NICKNAME, r.R_CONTENT, r.R_DATE FROM REPLY r " +
            "JOIN MEMBER m ON r.R_WRITER = m.ID ORDER BY r.R_NO DESC) WHERE ROWNUM <= 5"
        );
        rr = rp.executeQuery();
        while(rr.next()) {
            recentReplies.add(new String[]{
                String.valueOf(rr.getInt("R_NO")),
                rr.getString("NICKNAME"),
                rr.getString("R_CONTENT"),
                rr.getDate("R_DATE") != null ? rr.getDate("R_DATE").toString().substring(5,10) : ""
            });
        }
    } catch(Exception e) { e.printStackTrace(); }
    finally { DBManager.close(rc, rp, rr); }
%>

<%@ include file="../header.jsp" %>

<style>

.dash-wrap {
    display: flex;
    min-height: calc(100vh - 70px);
    background: #fdfaf4;  
    font-family: 'OshidashiGothic', sans-serif;
}

.dash-sidebar {
    width: 220px;
    flex-shrink: 0;
    background: #fff;
    border-right: 1px solid #f0ece2;
    padding: 28px 16px;
    display: flex;
    flex-direction: column;
    gap: 2px;
    position: sticky;
    top: 70px;
    height: calc(100vh - 70px);
    overflow-y: auto;
}

.dash-sidebar-title {
    display: flex; align-items: center; gap: 8px;
    font-size: 13px; font-weight: 800; color: #333;
    padding: 0 8px 20px;
    border-bottom: 2px solid #fdd835;
    margin-bottom: 12px;
    letter-spacing: -0.3px;
}
.dash-sidebar-title i { color: #fdd835; font-size: 15px; }

.dash-nav-label {
    font-size: 10px; font-weight: 700;
    color: #bbb; letter-spacing: 1.5px;
    text-transform: uppercase;
    padding: 14px 8px 5px;
}

.dash-nav-item {
    display: flex; align-items: center; gap: 9px;
    padding: 11px 12px;
    border-radius: 10px;
    color: #777;
    font-size: 13.5px; font-weight: 600;
    text-decoration: none;
    transition: all 0.18s;
}
.dash-nav-item i { width: 16px; text-align: center; font-size: 13px; color: #bbb; }
.dash-nav-item:hover { background: #fffde7; color: #333; }
.dash-nav-item:hover i { color: #f9a825; }
.dash-nav-item.active {
    background: #fdd835;
    color: #333;
    font-weight: 800;
    box-shadow: 0 3px 10px rgba(253,216,53,0.3);
}
.dash-nav-item.active i { color: #333; }

.dash-nav-badge {
    margin-left: auto;
    background: #ff5252; color: #fff;
    font-size: 10px; font-weight: 800;
    padding: 2px 6px; border-radius: 20px;
}

.dash-sidebar-footer {
    margin-top: auto;
    padding-top: 16px;
    border-top: 1px solid #f0ece2;
}
.dash-sidebar-footer a {
    display: flex; align-items: center; gap: 8px;
    color: #bbb; font-size: 12.5px;
    text-decoration: none; padding: 9px 10px;
    border-radius: 8px; transition: all 0.18s;
}
.dash-sidebar-footer a:hover { background: #fffde7; color: #666; }

.dash-main {
    flex: 1;
    padding: 36px 40px;
    overflow-y: auto;
}

.dash-page-header {
    display: flex; align-items: flex-end; justify-content: space-between;
    margin-bottom: 28px;
}
.dash-page-title {
    font-size: 22px; font-weight: 900; color: #222; letter-spacing: -0.5px;
    line-height: 1;
}
.dash-page-title small {
    display: block;
    font-size: 13px; color: #bbb; font-weight: 500; margin-bottom: 6px;
    letter-spacing: 0;
}
.dash-date-badge {
    background: #fff; border: 1px solid #f0ece2;
    border-radius: 20px; padding: 7px 16px;
    font-size: 12.5px; color: #999; font-weight: 600;
    display: flex; align-items: center; gap: 6px;
    box-shadow: 0 1px 4px rgba(0,0,0,0.04);
}
.dash-date-badge i { color: #fdd835; }

.stats-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 18px;
    margin-bottom: 28px;
}
.stat-card {
    background: #fff;
    border-radius: 16px; padding: 24px 22px;
    display: flex; align-items: center; justify-content: space-between;
    border: 1px solid #f0ece2;
    box-shadow: 0 2px 8px rgba(0,0,0,0.04);
    transition: transform 0.2s, box-shadow 0.2s;
}
.stat-card:hover { transform: translateY(-3px); box-shadow: 0 6px 20px rgba(0,0,0,0.08); border-color: #fdd835; }

.stat-info .stat-label {
    font-size: 11px; font-weight: 700; color: #bbb;
    text-transform: uppercase; letter-spacing: 0.8px; margin-bottom: 8px;
}
.stat-info .stat-num {
    font-size: 32px; font-weight: 900; color: #222; line-height: 1; margin-bottom: 8px;
    letter-spacing: -1px;
}
.stat-info .stat-num em { font-size: 15px; font-weight: 600; color: #aaa; font-style: normal; margin-left: 2px; }
.stat-trend {
    display: inline-flex; align-items: center; gap: 4px;
    font-size: 11px; font-weight: 700; padding: 3px 8px; border-radius: 20px;
}
.trend-up   { background: #fff9c4; color: #f57f17; }
.trend-new  { background: #fce4ec; color: #c62828; }
.trend-info { background: #f3f3f3; color: #888; }

.stat-icon {
    width: 50px; height: 50px; border-radius: 14px;
    display: flex; align-items: center; justify-content: center;
    font-size: 20px; flex-shrink: 0;
}
.si-1 { background: #fff9c4; color: #f9a825; }
.si-2 { background: #fce4ec; color: #e91e63; }
.si-3 { background: #e8f5e9; color: #43a047; }

.dash-grid-2 { display: grid; grid-template-columns: 1fr 300px; gap: 20px; }

.dash-section {
    background: #fff;
    border-radius: 16px; padding: 24px;
    border: 1px solid #f0ece2;
    box-shadow: 0 2px 8px rgba(0,0,0,0.04);
    margin-bottom: 20px;
}
.dash-section:last-child { margin-bottom: 0; }

.dsec-header {
    display: flex; justify-content: space-between; align-items: center;
    margin-bottom: 18px; padding-bottom: 14px;
    border-bottom: 1px solid #f5f0e8;
}
.dsec-title {
    font-size: 14px; font-weight: 800; color: #333;
    display: flex; align-items: center; gap: 7px; margin: 0;
}
.dsec-title .dtag {
    width: 6px; height: 18px; border-radius: 3px;
    background: #fdd835; display: inline-block;
}
.btn-dsec-more {
    font-size: 11.5px; font-weight: 700; color: #bbb;
    background: #f8f5ee; border: none; border-radius: 7px;
    padding: 5px 12px; cursor: pointer; transition: all 0.18s;
}
.btn-dsec-more:hover { background: #fdd835; color: #333; }

.dash-table { width: 100%; border-collapse: collapse; }
.dash-table th {
    text-align: left; padding: 0 10px 10px;
    font-size: 10.5px; font-weight: 700; color: #ccc;
    text-transform: uppercase; letter-spacing: 0.8px;
    border-bottom: 1px solid #f5f0e8;
}
.dash-table td {
    padding: 12px 10px; font-size: 13px; color: #555;
    border-bottom: 1px solid #f8f5ee; vertical-align: middle;
}
.dash-table tr:last-child td { border-bottom: none; }
.dash-table tr:hover td { background: #fffde7; }

.user-cell { display: flex; align-items: center; gap: 10px; }
.u-avatar {
    width: 34px; height: 34px; border-radius: 50%;
    background: linear-gradient(135deg, #fdd835, #fbc02d);
    display: flex; align-items: center; justify-content: center;
    font-size: 13px; font-weight: 800; color: #333; flex-shrink: 0;
    border: 2px solid #fff; box-shadow: 0 1px 4px rgba(253,216,53,0.3);
}
.u-name  { font-weight: 700; font-size: 13px; color: #222; }
.u-email { font-size: 11px; color: #ccc; margin-top: 1px; }

.d-badge {
    display: inline-block; background: #f8f5ee;
    padding: 3px 9px; border-radius: 6px;
    font-size: 11.5px; color: #999; font-weight: 600;
}
.btn-mini {
    padding: 4px 11px; border-radius: 6px;
    font-size: 11px; font-weight: 700; border: none; cursor: pointer; transition: 0.18s;
    margin-left: 3px;
}
.btn-stop { background: #fff9c4; color: #f57f17; }
.btn-stop:hover { background: #fff176; }
.btn-del  { background: #fce4ec; color: #c62828; }
.btn-del:hover  { background: #f8bbd0; }

.report-pill {
    display: inline-flex; align-items: center; gap: 4px;
    background: #fce4ec; color: #c62828;
    font-size: 10px; font-weight: 800; padding: 2px 7px; border-radius: 20px;
    margin-bottom: 4px;
}
.r-txt { font-size: 12.5px; color: #555; }
.r-txt.bad { color: #c62828; font-weight: 600; }

.quick-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
.quick-btn {
    display: flex; flex-direction: column; align-items: center; gap: 8px;
    background: #fdfaf4; border: 1px solid #f0ece2;
    border-radius: 12px; padding: 16px 10px;
    text-decoration: none; color: #555;
    font-size: 12px; font-weight: 700;
    transition: all 0.18s; cursor: pointer;
}
.quick-btn:hover { background: #fdd835; border-color: #fdd835; color: #333; transform: translateY(-2px); box-shadow: 0 4px 12px rgba(253,216,53,0.3); }
.quick-btn i { font-size: 18px; color: #f9a825; transition: color 0.18s; }
.quick-btn:hover i { color: #333; }

.notif-list { display: flex; flex-direction: column; }
.notif-item {
    display: flex; gap: 10px; padding: 12px 0;
    border-bottom: 1px solid #f5f0e8; align-items: flex-start;
}
.notif-item:last-child { border-bottom: none; }
.notif-emoji { font-size: 16px; flex-shrink: 0; margin-top: 1px; }
.notif-body { flex: 1; }
.notif-txt  { font-size: 12.5px; color: #555; line-height: 1.5; }
.notif-txt strong { color: #222; font-weight: 700; }
.notif-time { font-size: 11px; color: #ccc; margin-top: 2px; }
</style>

<div class="dash-wrap">

    <!-- ── 사이드바 ── -->
    <aside class="dash-sidebar">
        <div class="dash-sidebar-title">
            <i class="fas fa-crown"></i> 管理者センター
        </div>

        <div class="dash-nav-label">メイン</div>
        <a href="#" class="dash-nav-item active">
            <i class="fas fa-chart-pie"></i> ダッシュボード
        </a>

        <div class="dash-nav-label">管理</div>
        <a href="#" class="dash-nav-item">
            <i class="fas fa-users"></i> 会員管理
        </a>
        <a href="#" class="dash-nav-item">
            <i class="fas fa-file-alt"></i> 投稿管理
        </a>
        <a href="#" class="dash-nav-item">
            <i class="fas fa-flag"></i> 通報管理
            <span class="dash-nav-badge">3</span>
        </a>
        <a href="#" class="dash-nav-item">
            <i class="fas fa-comment-dots"></i> コメント管理
        </a>

        <div class="dash-nav-label">設定</div>
        <a href="#" class="dash-nav-item">
            <i class="fas fa-cog"></i> サイト設定
        </a>

        <div class="dash-sidebar-footer">
            <a href="../index.jsp">
                <i class="fas fa-arrow-left"></i> サイトに戻る
            </a>
        </div>
    </aside>

    <!-- ── 메인 콘텐츠 ── -->
    <main class="dash-main">

        <!-- 페이지 헤더 -->
        <div class="dash-page-header">
            <div class="dash-page-title">
                <small>管理者ホーム</small>
                ダッシュボード 🐾
            </div>
            <div class="dash-date-badge">
                <i class="far fa-calendar-alt"></i> 2026年2月19日（木）
            </div>
        </div>

        <!-- 통계 카드 -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-info">
                    <div class="stat-label">総会員数</div>
                    <div class="stat-num"><%= totalMembers %><em>名</em></div>
                    <span class="stat-trend trend-info">一般会員基準</span>
                </div>
                <div class="stat-icon si-1"><i class="fas fa-users"></i></div>
            </div>
            <div class="stat-card">
                <div class="stat-info">
                    <div class="stat-label">総投稿数</div>
                    <div class="stat-num"><%= totalBoards %><em>件</em></div>
                    <span class="stat-trend trend-info">コミュニティ投稿基準</span>
                </div>
                <div class="stat-icon si-2"><i class="fas fa-file-alt"></i></div>
            </div>
            <div class="stat-card">
                <div class="stat-info">
                    <div class="stat-label">総コメント数</div>
                    <div class="stat-num"><%= totalReplies %><em>件</em></div>
                    <span class="stat-trend trend-info">累計コメント数</span>
                </div>
                <div class="stat-icon si-3"><i class="fas fa-comment-dots"></i></div>
            </div>
        </div>

        <!-- 하단 2단 -->
        <div class="dash-grid-2">
            <div>
                <!-- 최근 가입 회원 (실DB) -->
                <div class="dash-section">
                    <div class="dsec-header">
                        <h3 class="dsec-title"><span class="dtag"></span> 最近登録した会員</h3>
                    </div>
                    <table class="dash-table">
                        <thead>
                            <tr>
                                <th>会員</th>
                                <th>ID</th>
                                <th>登録日</th>
                                <th style="text-align:right;">管理</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% if(recentMembers.isEmpty()) { %>
                            <tr><td colspan="4" style="text-align:center; color:#ccc; padding:24px;">登録会員がいません</td></tr>
                        <% } else { for(UserDTO u : recentMembers) {
                            String firstChar = (u.getNickname() != null && !u.getNickname().isEmpty())
                                ? u.getNickname().substring(0,1) : "?";
                        %>
                            <tr>
                                <td>
                                    <div class="user-cell">
                                        <div class="u-avatar"><%= firstChar %></div>
                                        <div>
                                            <div class="u-name"><%= u.getNickname() %></div>
                                        </div>
                                    </div>
                                </td>
                                <td><span class="u-email" style="font-size:12px; color:#999;"><%= u.getId() %></span></td>
                                <td><span class="d-badge"><%= u.getJoinDate() != null ? u.getJoinDate().toString() : "-" %></span></td>
                                <td style="text-align:right;">
                                    <button class="btn-mini btn-del"
                                        onclick="confirmDelete('<%= u.getId() %>', '<%= u.getNickname() %>')">退会</button>
                                </td>
                            </tr>
                        <% } } %>
                        </tbody>
                    </table>
                </div>

                <!-- 최근 댓글 (실DB) -->
                <div class="dash-section">
                    <div class="dsec-header">
                        <h3 class="dsec-title"><span class="dtag" style="background:#ff7043;"></span> 最新コメント</h3>
                    </div>
                    <table class="dash-table">
                        <thead>
                            <tr>
                                <th>投稿者</th>
                                <th>内容</th>
                                <th>日付</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% if(recentReplies.isEmpty()) { %>
                            <tr><td colspan="3" style="text-align:center; color:#ccc; padding:24px;">コメントがありません</td></tr>
                        <% } else { for(String[] r : recentReplies) {
                            String content = r[2] != null && r[2].length() > 30 ? r[2].substring(0,30)+"…" : r[2];
                        %>
                            <tr>
                                <td><strong><%= r[1] %></strong></td>
                                <td><div class="r-txt"><%= content %></div></td>
                                <td><span class="d-badge"><%= r[3] %></span></td>
                            </tr>
                        <% } } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- 오른쪽 -->
            <div>
                <!-- 빠른 메뉴 -->
                <div class="dash-section">
                    <div class="dsec-header">
                        <h3 class="dsec-title"><span class="dtag"></span> クイックメニュー</h3>
                    </div>
                    <div class="quick-grid">
                        <a href="#" class="quick-btn">
                            <i class="fas fa-pen"></i> 記事を書く
                        </a>
                        <a href="#" class="quick-btn">
                            <i class="fas fa-users"></i> 会員検索
                        </a>
                        <a href="#" class="quick-btn">
                            <i class="fas fa-trash-alt"></i> 通報処理
                        </a>
                        <a href="#" class="quick-btn">
                            <i class="fas fa-chart-bar"></i> 統計
                        </a>
                    </div>
                </div>

                <!-- 알림 -->
                <div class="dash-section">
                    <div class="dsec-header">
                        <h3 class="dsec-title"><span class="dtag"></span> 最新通知</h3>
                        <button class="btn-dsec-more">すべて</button>
                    </div>
                    <div class="notif-list">
                        <div class="notif-item">
                            <div class="notif-emoji">🚨</div>
                            <div class="notif-body">
                                <div class="notif-txt"><strong>通報受付</strong> — コメント1件が通報されました。</div>
                                <div class="notif-time">5分前</div>
                            </div>
                        </div>
                        <div class="notif-item">
                            <div class="notif-emoji">🐾</div>
                            <div class="notif-body">
                                <div class="notif-txt"><strong>新規会員</strong> — ワンワンパパ様が登録しました。</div>
                                <div class="notif-time">1時間前</div>
                            </div>
                        </div>
                        <div class="notif-item">
                            <div class="notif-emoji">📝</div>
                            <div class="notif-body">
                                <div class="notif-txt"><strong>投稿</strong> — 新しいマガジンが登録されました。</div>
                                <div class="notif-time">2時間前</div>
                            </div>
                        </div>
                        <div class="notif-item">
                            <div class="notif-emoji">🎉</div>
                            <div class="notif-body">
                                <div class="notif-txt"><strong>訪問者</strong> — 本日100名を突破しました！</div>
                                <div class="notif-time">3時間前</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<script>
function confirmDelete(id, nickname) {
    if(confirm('「' + nickname + '」会員を退会処理しますか？\n該当会員の投稿といいねデータも一緒に削除されます。')) {
        location.href = "dashboard.jsp?action=deleteMember&delId=" + encodeURIComponent(id);
    }
}
</script>

<%@ include file="../footer.jsp" %>