<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.BoardDAO, model.BoardDTO" %>
<%@ page import="java.util.ArrayList" %>
<%@ include file="header.jsp" %>

<%
    BoardDAO dao = new BoardDAO();
    ArrayList<BoardDTO> contentList = dao.getContentList();
    ArrayList<BoardDTO> recentList  = dao.getRecentList();
%>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;900&family=Noto+Sans+KR:wght@400;500;700;900&display=swap" rel="stylesheet">

<style>
body { background-color: #fdfaf4 !important; font-family: 'OshidashiGothic', 'OshidashiGothic', sans-serif !important; }

.hero-section {
    width: 100%; height: 400px;
    background: url('https://images.unsplash.com/photo-1450778869180-41d0601e046e?q=80&w=1600') no-repeat center center / cover;
    position: relative; overflow: hidden;
}
.hero-section::before {
    content: ''; position: absolute; inset: 0;
    background: linear-gradient(135deg, rgba(0,0,0,0.58) 0%, rgba(0,0,0,0.22) 55%, rgba(253,216,53,0.12) 100%);
}
.hero-inner {
    position: relative; z-index: 1;
    max-width: 1100px; margin: 0 auto; padding: 0 20px;
    height: 100%; display: flex; flex-direction: column; justify-content: center;
}
.hero-badge {
    display: inline-flex; align-items: center; gap: 7px;
    background: rgba(253,216,53,0.95); color: #333;
    font-size: 12px; font-weight: 800; letter-spacing: 0.5px;
    padding: 6px 18px; border-radius: 30px;
    width: fit-content; margin-bottom: 22px;
    box-shadow: 0 4px 14px rgba(253,216,53,0.4);
}
.hero-title {
    font-size: 48px; font-weight: 900; color: #fff;
    line-height: 1.2; letter-spacing: -1.5px;
    text-shadow: 0 2px 16px rgba(0,0,0,0.35); margin-bottom: 16px;
}
.hero-title em { color: #fdd835; font-style: normal; }
.hero-desc {
    font-size: 17px; color: rgba(255,255,255,0.85);
    margin-bottom: 34px; line-height: 1.65;
}
.hero-btns { display: flex; gap: 12px; }
.btn-hero-primary {
    padding: 14px 32px; background: #fdd835; color: #333;
    font-weight: 800; font-size: 15px; border-radius: 30px;
    text-decoration: none; transition: all 0.22s;
    box-shadow: 0 4px 18px rgba(253,216,53,0.45);
    display: inline-flex; align-items: center; gap: 8px;
}
.btn-hero-primary:hover { background: #fff; transform: translateY(-3px); }
.btn-hero-secondary {
    padding: 14px 32px; background: rgba(255,255,255,0.15);
    color: #fff; border: 2px solid rgba(255,255,255,0.7);
    font-weight: 700; font-size: 15px; border-radius: 30px;
    text-decoration: none; backdrop-filter: blur(6px);
    transition: all 0.22s; display: inline-flex; align-items: center; gap: 8px;
}
.btn-hero-secondary:hover { background: #fff; color: #333; transform: translateY(-3px); }

.main-content {
    max-width: 1100px;
    margin: 0 auto 100px;
    padding: 0 20px;
}

.section-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-end;
    padding: 60px 0 20px;
    border-bottom: 2px solid #1a1a1a;
    margin-bottom: 20px;
}
.section-header-left { display: flex; flex-direction: column; gap: 6px; }
.section-eyebrow { font-size: 11px; font-weight: 800; letter-spacing: 3px; text-transform: uppercase; color: #f57f17; }
.section-title { font-size: 28px; font-weight: 900; color: #1a1a1a; line-height: 1; }
.section-more {
    font-size: 13px; font-weight: 700; color: #888;
    text-decoration: none; display: flex; align-items: center; gap: 6px;
    padding-bottom: 4px; border-bottom: 1px solid transparent; transition: all 0.2s;
}
.section-more:hover { color: #f57f17; border-bottom-color: #f57f17; }

.tag-filter-row {
    display: flex; gap: 8px; flex-wrap: wrap;
    margin-bottom: 22px;
}
.tf-btn {
    padding: 7px 18px; border-radius: 30px;
    background: #f5f0e8; color: #888;
    font-size: 12px; font-weight: 800;
    border: 1.5px solid transparent;
    cursor: pointer; transition: all 0.18s;
    display: flex; align-items: center; gap: 5px;
}
.tf-btn:hover { background: #fffde7; border-color: #fdd835; color: #555; }
.tf-btn.active { background: #fdd835; color: #333; border-color: #fdd835; box-shadow: 0 3px 10px rgba(253,216,53,0.3); }

.panel-wrap { position: relative; margin-bottom: 60px; }

.mag-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 24px;
    min-height: 380px;
}

.mag-featured {
    position: relative;
    border-radius: 20px;
    overflow: hidden;
    background: #e0e0e0;
    min-height: 380px;
    cursor: pointer;
}
.feat-slide {
    position: absolute; inset: 0;
    opacity: 0;
    pointer-events: none;
    
}
.feat-slide.active {
    opacity: 1;
    pointer-events: auto;
    animation: slideFromRight 0.5s cubic-bezier(0.4, 0, 0.2, 1) both;
}
.feat-slide.active.from-left {
    animation: slideFromLeft  0.5s cubic-bezier(0.4, 0, 0.2, 1) both;
}
@keyframes slideFromRight {
    from { opacity: 0; transform: translateX(60px);  }
    to   { opacity: 1; transform: translateX(0);      }
}
@keyframes slideFromLeft {
    from { opacity: 0; transform: translateX(-60px); }
    to   { opacity: 1; transform: translateX(0);      }
}
.feat-slide img { width: 100%; height: 100%; object-fit: cover; display: block; }
.feat-slide-overlay {
    position: absolute; inset: 0;
    background: linear-gradient(to top, rgba(0,0,0,0.82) 0%, rgba(0,0,0,0.08) 55%, transparent 100%);
}
.feat-slide-body {
    position: absolute; bottom: 0; left: 0; right: 0;
    padding: 28px 26px;
}
.feat-chip {
    display: inline-block;
    background: #fdd835; color: #1a1a1a;
    font-size: 10px; font-weight: 900; letter-spacing: 1.5px;
    text-transform: uppercase; padding: 4px 12px; border-radius: 30px; margin-bottom: 10px;
}
.feat-title {
    font-size: 20px; font-weight: 900; color: #fff;
    line-height: 1.35; margin-bottom: 12px;
}
.feat-meta { display: flex; gap: 14px; font-size: 12px; color: rgba(255,255,255,0.6); }
.feat-meta span { display: flex; align-items: center; gap: 4px; }

.feat-nav {
    position: absolute; top: 50%; transform: translateY(-50%);
    width: 36px; height: 36px; border-radius: 50%;
    background: rgba(255,255,255,0.9); border: none;
    color: #333; font-size: 13px; cursor: pointer;
    display: flex; align-items: center; justify-content: center;
    z-index: 5; transition: all 0.2s;
    box-shadow: 0 2px 8px rgba(0,0,0,0.15);
}
.feat-nav:hover { background: #fdd835; }
.feat-nav.left { left: 12px; }
.feat-nav.right { right: 12px; }

.feat-dots {
    position: absolute; bottom: 14px; right: 18px;
    display: flex; gap: 5px; z-index: 5;
}
.feat-dot {
    width: 6px; height: 6px; border-radius: 50%;
    background: rgba(255,255,255,0.45); cursor: pointer; transition: all 0.25s;
}
.feat-dot.active { background: #fdd835; width: 18px; border-radius: 3px; }

.mag-side-list { display: flex; flex-direction: column; }
.mag-side-item {
    display: grid; grid-template-columns: 110px 1fr; gap: 16px;
    align-items: center; padding: 18px 14px;
    border-bottom: 1px solid #f0f0f0; cursor: pointer;
    transition: background 0.15s; border-radius: 12px;
}
.mag-side-item:last-child { border-bottom: none; }
.mag-side-item:hover { background: #fffde7; }
.mag-side-thumb {
    width: 110px; height: 86px;
    border-radius: 12px; overflow: hidden; background: #f5f5f5;
}
.mag-side-thumb img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.4s; }
.mag-side-item:hover .mag-side-thumb img { transform: scale(1.06); }
.mag-side-info { display: flex; flex-direction: column; gap: 6px; }
.mag-side-chip {
    font-size: 10px; font-weight: 800; letter-spacing: 1px;
    text-transform: uppercase; color: #f57f17;
    display: flex; align-items: center; gap: 5px;
}
.mag-side-chip::before { content: ''; display: block; width: 10px; height: 2px; background: #fdd835; }
.mag-side-title {
    font-size: 15px; font-weight: 800; color: #1a1a1a; line-height: 1.4;
    display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
}
.mag-side-item:hover .mag-side-title { color: #f57f17; }
.mag-side-meta { font-size: 11px; color: #bbb; display: flex; gap: 8px; }

.empty-msg { padding: 80px 20px; color: #ccc; text-align: center; }
</style>

<!-- ══ 히어로 ══ -->
<div class="hero-section">
    <div class="hero-inner">
        <div class="hero-badge">🐾 Welcome to Petmate</div>
        <h1 class="hero-title">小さな友だちと<br><em>紡ぐストーリー</em></h1>
        <p class="hero-desc">専門家の飼育情報から日常のひとこままで、一緒に楽しみましょう。</p>
        <div class="hero-btns">
            <a href="${pageContext.request.contextPath}/blog/community.jsp" class="btn-hero-primary">
                <i class="fas fa-paw"></i> コミュニティに参加する
            </a>
            <a href="${pageContext.request.contextPath}/blog/contents.jsp" class="btn-hero-secondary">
                <i class="fas fa-book-open"></i> マガジンを見る
            </a>
        </div>
    </div>
</div>

<!-- ══ 메인 콘텐츠 ══ -->
<div class="main-content">

<%

String ctx2 = request.getContextPath();

StringBuilder magJson = new StringBuilder("[");
if (contentList != null) {
    int mi = 0;
    for (BoardDTO b : contentList) {
        String pic = b.getPic();
        if (pic == null || pic.trim().isEmpty() || pic.equals("no_img.png"))
            pic = "https://images.unsplash.com/photo-1450778869180-41d0601e046e?q=80&w=800";
        else if (!pic.startsWith("data:image") && !pic.startsWith("http"))
            pic = ctx2 + "/upload/" + pic;
        String tag = b.getTag() != null ? b.getTag() : "";
        String rawTagLabel = tag.startsWith("콘텐츠_") ? tag.substring("콘텐츠_".length())
                        : tag.equals("콘텐츠") ? "" : tag;
        java.util.Map<String,String> magTagMap = new java.util.LinkedHashMap<>();
        magTagMap.put("건강","健康"); magTagMap.put("행동","しつけ"); magTagMap.put("음식","食事");
        magTagMap.put("트레이닝","トレーニング"); magTagMap.put("강아지품종","犬種図鑑"); magTagMap.put("고양이품종","猫種図鑑");
        magTagMap.put("강아지","犬"); magTagMap.put("고양이","猫");
        String tagLabel = magTagMap.containsKey(rawTagLabel) ? magTagMap.get(rawTagLabel) : rawTagLabel.isEmpty() ? "マガジン" : rawTagLabel;
        String title = b.getTitle() != null ? b.getTitle().replace("\"","&quot;").replace("'","&#39;") : "";
        String nick  = b.getNickname() != null ? b.getNickname().replace("\"","&quot;") : "ゲスト";
        if (mi > 0) magJson.append(",");
        magJson.append("{\"no\":").append(b.getNo())
               .append(",\"tag\":\"").append(tagLabel).append("\"")
               .append(",\"pic\":\"").append(pic).append("\"")
               .append(",\"title\":\"").append(title).append("\"")
               .append(",\"nick\":\"").append(nick).append("\"")
               .append(",\"views\":").append(b.getViews())
               .append(",\"likes\":").append(b.getLikes()).append("}");
        mi++;
    }
}
magJson.append("]");

StringBuilder commJson = new StringBuilder("[");
if (recentList != null) {
    int ci = 0;
    for (BoardDTO b : recentList) {
        if (b.getTag() != null && b.getTag().startsWith("콘텐츠")) continue;
        String pic = b.getPic();
        if (pic == null || pic.trim().isEmpty() || pic.equals("no_img.png"))
            pic = ctx2 + "/images/no_img.png";
        else if (!pic.startsWith("data:image") && !pic.startsWith("http"))
            pic = ctx2 + "/upload/" + pic;
        String tag   = b.getTag() != null ? b.getTag().trim() : "";
        java.util.Map<String,String> commTagMap = new java.util.LinkedHashMap<>();
        commTagMap.put("강아지","犬"); commTagMap.put("고양이","猫");
        String tagJp = commTagMap.containsKey(tag) ? commTagMap.get(tag) : tag;
        String title = b.getTitle() != null ? b.getTitle().replace("\"","&quot;").replace("'","&#39;") : "";
        String nick  = b.getNickname() != null ? b.getNickname().replace("\"","&quot;") : "ゲスト";
        if (ci > 0) commJson.append(",");
        commJson.append("{\"no\":").append(b.getNo())
                .append(",\"tag\":\"").append(tagJp).append("\"")
                .append(",\"pic\":\"").append(pic).append("\"")
                .append(",\"title\":\"").append(title).append("\"")
                .append(",\"nick\":\"").append(nick).append("\"")
                .append(",\"views\":").append(b.getViews())
                .append(",\"likes\":").append(b.getLikes()).append("}");
        ci++;
    }
}
commJson.append("]");
%>

<script>
var MAG_DATA  = <%=magJson%>;
var COMM_DATA = <%=commJson%>;
var CTX = '<%=ctx2%>';
</script>

    <!-- ── 매거진 섹션 ── -->
    <div class="section-header">
        <div class="section-header-left">
            <span class="section-eyebrow">Magazine</span>
            <h2 class="section-title">ペットメイト マガジン</h2>
        </div>
        <a href="${pageContext.request.contextPath}/blog/contents.jsp" class="section-more">
            すべて見る <i class="fas fa-arrow-right"></i>
        </a>
    </div>

    <!-- 매거진 태그 필터 -->
    <div class="tag-filter-row" id="magFilters"></div>

    <div class="panel-wrap">
        <div class="mag-grid">
            <div class="mag-featured" id="magFeatured"></div>
            <div class="mag-side-list" id="magSide"></div>
        </div>
    </div>

    <!-- ── 커뮤니티 섹션 ── -->
    <div class="section-header">
        <div class="section-header-left">
            <span class="section-eyebrow">Community</span>
            <h2 class="section-title">コミュニティストーリー</h2>
        </div>
        <a href="${pageContext.request.contextPath}/blog/community.jsp" class="section-more">
            すべて見る <i class="fas fa-arrow-right"></i>
        </a>
    </div>

    <!-- 커뮤니티 태그 필터 -->
    <div class="tag-filter-row" id="commFilters"></div>

    <div class="panel-wrap">
        <div class="mag-grid">
            <div class="mag-featured" id="commFeatured"></div>
            <div class="mag-side-list" id="commSide"></div>
        </div>
    </div>

</div><!-- /.main-content -->

<script>

function createPanel(cfg) {
    var data     = cfg.data;
    var curTag   = 'すべて';
    var featIdx  = 0;
    var filtered = [];
    var slideDir = 1;           
    var autoTimer = null;
    var AUTO_INTERVAL = 5000;

    
    var tagSet = ( cfg.fixedTags || ['すべて']).slice();

    
    var filterRow = document.getElementById(cfg.filterRowId);
    tagSet.forEach(function(t) {
        var btn = document.createElement('button');
        btn.className = 'tf-btn' + (t === cfg.fixedTags[0] ? ' active' : '');
        btn.textContent = (cfg.tagLabelMap && cfg.tagLabelMap[t]) ? cfg.tagLabelMap[t] : t;
        btn.onclick = function() {
            document.querySelectorAll('#' + cfg.filterRowId + ' .tf-btn')
                    .forEach(function(b) { b.classList.remove('active'); });
            btn.classList.add('active');
            curTag  = t;
            featIdx = 0;
            stopAuto();
            render();
            startAuto();
        };
        filterRow.appendChild(btn);
    });

    function getFiltered() {
        if (curTag === cfg.fixedTags[0]) return data;
        return data.filter(function(d) {
            return d.tag && d.tag.trim() === curTag.trim();
        });
    }

    
    function startAuto() {
        stopAuto();
        if (filtered.length <= 1) return;
        autoTimer = setInterval(function() {
            slideDir = 1;
            featIdx = (featIdx + 1) % filtered.length;
            render();
        }, AUTO_INTERVAL);
    }
    function stopAuto() { clearInterval(autoTimer); autoTimer = null; }

    function renderFeatured(list) {
        var el = document.getElementById(cfg.featuredId);
        if (!list.length) {
            el.innerHTML = '<p class="empty-msg">記事がありません</p>';
            return;
        }
        var html = '';
        list.forEach(function(d, i) {
            var chipExtra = cfg.chipStyle ? cfg.chipStyle(d.tag) : '';
            var dirClass  = (i === featIdx) ? (slideDir < 0 ? ' from-left' : '') : '';
            html += '<div class="feat-slide' + (i === featIdx ? ' active' + dirClass : '') + '"'
                  + ' onclick="location.href=\'' + CTX + '/blog/detail.jsp?no=' + d.no + '\'">'
                  + '<img src="' + d.pic + '" alt="">'
                  + '<div class="feat-slide-overlay"></div>'
                  + '<div class="feat-slide-body">'
                  + '<span class="feat-chip" ' + chipExtra + '>' + d.tag + '</span>'
                  + '<div class="feat-title">' + d.title + '</div>'
                  + '<div class="feat-meta">'
                  + '<span><i class="fas fa-user-circle"></i> ' + d.nick + '</span>'
                  + '<span><i class="far fa-eye"></i> ' + d.views + '</span>'
                  + '</div></div></div>';
        });

        
        if (list.length > 2) {
            html += '<button class="feat-nav left" onclick="event.stopPropagation();'
                  + cfg.movePrefix + 'Move(-1)"><i class="fas fa-chevron-left"></i></button>';
            html += '<button class="feat-nav right" onclick="event.stopPropagation();'
                  + cfg.movePrefix + 'Move(1)"><i class="fas fa-chevron-right"></i></button>';
            html += '<div class="feat-dots">';
            list.forEach(function(_, i) {
                html += '<div class="feat-dot' + (i === featIdx ? ' active' : '') + '"'
                      + ' onclick="event.stopPropagation();' + cfg.movePrefix + 'Go(' + i + ')"></div>';
            });
            html += '</div>';
        }
        el.innerHTML = html;

        
        el.onmouseenter = stopAuto;
        el.onmouseleave = startAuto;
    }

    function renderSide(list) {
        var el = document.getElementById(cfg.sideId);
        
        if (list.length <= 1) { el.innerHTML = ''; return; }

        
        var sideCount = Math.min(list.length - 1, 3);
        var html = '';
        for (var i = 1; i <= sideCount; i++) {
            var d = list[(featIdx + i) % list.length];
            html += '<div class="mag-side-item" onclick="location.href=\'' + CTX + '/blog/detail.jsp?no=' + d.no + '\'">'
                  + '<div class="mag-side-thumb"><img src="' + d.pic + '" alt=""></div>'
                  + '<div class="mag-side-info">'
                  + '<span class="mag-side-chip">' + d.tag + '</span>'
                  + '<div class="mag-side-title">' + d.title + '</div>'
                  + '<div class="mag-side-meta">'
                  + '<span><i class="far fa-eye"></i> ' + d.views + '</span>'
                  + '<span><i class="fas fa-heart" style="color:#ff9999;"></i> ' + d.likes + '</span>'
                  + '</div></div></div>';
        }
        el.innerHTML = html;
    }

    function render() {
        filtered = getFiltered();
        if (featIdx >= filtered.length) featIdx = 0;
        renderFeatured(filtered);
        renderSide(filtered);
    }

    window[cfg.movePrefix + 'Move'] = function(dir) {
        stopAuto();
        slideDir = dir;
        filtered = getFiltered();
        featIdx  = (featIdx + dir + filtered.length) % filtered.length;
        render();
        startAuto();
    };
    window[cfg.movePrefix + 'Go'] = function(i) {
        stopAuto();
        slideDir = (i > featIdx) ? 1 : -1;
        featIdx = i;
        render();
        startAuto();
    };

    render();
    startAuto();
}

createPanel({
    data        : MAG_DATA,
    filterRowId : 'magFilters',
    featuredId  : 'magFeatured',
    sideId      : 'magSide',
    fixedTags   : ['すべて', '健康', 'しつけ', '食事', 'トレーニング', '犬種図鑑', '猫種図鑑'],
    tagLabelMap : { 'すべて':'すべて', '健康':'🏥 健康', 'しつけ':'🐾 しつけ', '食事':'🍖 食事', 'トレーニング':'🎯 トレーニング', '犬種図鑑':'📖 犬種図鑑', '猫種図鑑':'📖 猫種図鑑' },
    chipStyle   : null,
    movePrefix  : 'mag'
});

createPanel({
    data        : COMM_DATA,
    filterRowId : 'commFilters',
    featuredId  : 'commFeatured',
    sideId      : 'commSide',
    fixedTags   : ['すべて', '犬', '猫'],
    tagLabelMap : { 'すべて':'すべて', '犬':'🐶 犬', '猫':'🐱 猫' },
    chipStyle   : function(tag) {
        var t = tag ? tag.trim() : '';
        var color = t === '犬' ? '#1565c0' : t === '猫' ? '#ad1457' : '#555';
        return 'style="background:#fff;color:' + color + ';"';
    },
    movePrefix  : 'comm'
});
</script>

<%@ include file="footer.jsp" %>
