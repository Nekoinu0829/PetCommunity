<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<footer class="site-footer">
	<div class="container">
		<p>&copy; 2026 ペットメイト. All rights reserved.</p>
		<ul class="footer-links">
			<li><a href="#">利用規約</a></li>
			<li><a href="#">プライバシーポリシー</a></li>
			<li><a href="#">カスタマーサポート</a></li>
		</ul>
	</div>
</footer>

<!-- 최상단으로 버튼 -->
<button id="scrollTopBtn"
	onclick="window.scrollTo({top:0, behavior:'smooth'})" title="トップへ">
	<i class="fas fa-chevron-up"></i>
</button>

<style>
#scrollTopBtn {
	position: fixed;
	bottom: 36px;
	right: 36px;
	width: 48px;
	height: 48px;
	border-radius: 50%;
	background: #fdd835;
	color: #333;
	border: none;
	font-size: 18px;
	cursor: pointer;
	box-shadow: 0 4px 14px rgba(0, 0, 0, 0.15);
	display: flex;
	align-items: center;
	justify-content: center;
	opacity: 0;
	transform: translateY(20px);
	transition: opacity 0.3s ease, transform 0.3s ease, background 0.2s;
	pointer-events: none;
	z-index: 9999;
}

#scrollTopBtn.visible {
	opacity: 1;
	transform: translateY(0);
	pointer-events: auto;
}

#scrollTopBtn:hover {
	background: #fbc02d;
	transform: translateY(-3px);
	box-shadow: 0 6px 18px rgba(253, 216, 53, 0.5);
}
</style>

<script>
	(function() {
		var btn = document.getElementById('scrollTopBtn');
		window.addEventListener('scroll', function() {
			if (window.scrollY > 300) {
				btn.classList.add('visible');
			} else {
				btn.classList.remove('visible');
			}
		});
	})();
</script>

</body>
</html>