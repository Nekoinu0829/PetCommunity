<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
    
    String action = request.getParameter("action");
    if ("logout".equals(action)) {
        session.invalidate(); 
%>
<script>
        alert("ログアウトしました。またね！🐾");
        location.href = "<%=request.getContextPath()%>/index.jsp";
    </script>
<%
        return; 
    }

    
    model.UserDTO user = (model.UserDTO) session.getAttribute("user");
    
    
    
    boolean isAdmin = false;
    if (user != null && user.getRole() == 1) {
        isAdmin = true;
    }
%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ペットメイト</title>

<link rel="icon"
	href="${pageContext.request.contextPath}/images/Favicon.png"
	type="image/png">

<link rel="stylesheet"
	href="${pageContext.request.contextPath}/css/style.css">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
.container, .header-content {
	max-width: 1100px !important;
	margin-left: auto !important;
	margin-right: auto !important;
	padding-left: 20px !important;
	padding-right: 20px !important;
}

.site-header {
	height: 70px !important;
}

.header-content {
	display: flex !important;
	align-items: center !important;
	justify-content: space-between !important;
	height: 70px !important;
}

.logo img {
	height: 45px !important;
	width: auto !important;
}

.header-right {
	display: flex;
	align-items: center;
	gap: 6px;
}
</style>
<script>
function openTab(evt, tabName) {
    var contents = document.querySelectorAll('.tab-content');
    var links = document.querySelectorAll('.tab-link');
    contents.forEach(function(c) { c.style.display = 'none'; });
    links.forEach(function(l) { l.classList.remove('active'); });
    document.getElementById(tabName).style.display = 'block';
    evt.currentTarget.classList.add('active');
}
</script>
</head>
<body>
	<header class="site-header">
		<div class="container header-content">
			<a href="${pageContext.request.contextPath}/index.jsp" class="logo">
				<img src="${pageContext.request.contextPath}/images/logo.png"
				alt="ペットメイト">
			</a>



			<div class="header-right">
				<nav class="main-nav">
					<ul>
						<li><a
							href="${pageContext.request.contextPath}/MoveBoard?cmd=contents"
							class="btn-outline">マガジン</a></li>
						<li><a
							href="${pageContext.request.contextPath}/MoveBoard?cmd=list"
							class="btn-outline">コミュニティ</a></li>
						<li><a
							href="${pageContext.request.contextPath}/MoveBoard?cmd=write"
							class="btn-outline">投稿する</a></li>
					</ul>
				</nav>

				<div class="auth-buttons">
					<%
				if (user == null) {
				%>
					<div class="dropdown">
						<button class="btn-point dropbtn">ログイン/会員登録</button>

						<div class="dropdown-content">
							<div class="auth-box">
								<div class="modal-tabs">
									<button class="tab-link active"
										onclick="openTab(event, 'loginTab')">ログイン</button>
									<button class="tab-link" onclick="openTab(event, 'signupTab')">会員登録</button>
								</div>

								<img src="${pageContext.request.contextPath}/images/logo.png"
									alt="ペットメイト" class="dropdown-logo">

								<div id="loginTab" class="tab-content" style="display: block;">
									<form action="${pageContext.request.contextPath}/User"
										method="post">
										<input type="hidden" name="action" value="login"> <input
											type="text" name="id" placeholder="メールアドレス"
											class="input-field" required> <input type="password"
											name="pw" placeholder="パスワード" class="input-field" required>
										<button type="submit" class="submit-btn btn-dark">ログイン</button>
									</form>
								</div>

								<div id="signupTab" class="tab-content" style="display: none;">
									<form action="${pageContext.request.contextPath}/User"
										method="post">
										<input type="hidden" name="action" value="join"> <input
											type="text" name="id" placeholder="メールアドレス"
											class="input-field" required> <input type="text"
											name="nickname" placeholder="ニックネーム" class="input-field"
											required> <input type="password" name="pw"
											placeholder="パスワード" class="input-field" required> <input
											type="password" name="pwConfirm" placeholder="確認"
											class="input-field">
										<button type="submit" class="submit-btn btn-yellow">登録する</button>
									</form>
								</div>
							</div>
						</div>
					</div>

					<%
				} else {
				%>
					<div class="dropdown">
						<button class="btn-point dropbtn">
							<%= isAdmin ? "管理者様 👑" : user.getNickname() + "様" %>
						</button>
						<div class="dropdown-content">
							<div class="user-menu-box">
								<% if(isAdmin) { %>
								<a href="${pageContext.request.contextPath}/admin/dashboard.jsp"
									style="color: #d32f2f; font-weight: bold;">管理者ページ</a>
								<% } else { %>
								<a href="${pageContext.request.contextPath}/blog/mypage.jsp">マイページ</a>
								<a href="${pageContext.request.contextPath}/blog/like_list.jsp"
									style="">お気に入り</a>
								<% } %>

								<a href="?action=logout"
									onclick="return confirm('本当にログアウトしますか？🐾');">ログアウト</a>
							</div>
						</div>
					</div>
					<%
				}
				%>
				</div>
			</div>
		</div>
	</header>