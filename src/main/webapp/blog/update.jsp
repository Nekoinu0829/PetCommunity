<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.regex.Pattern, java.util.regex.Matcher" %>
<%@ page import="model.BoardDAO, model.BoardDTO, model.UserDTO" %>
<%!
    private String h(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;");
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");
    String ctx = request.getContextPath();

    UserDTO u = (UserDTO) session.getAttribute("user");
    if (u == null) {
%>
        <script>alert('ログインが必要です。'); location.href='<%=ctx%>/login.jsp';</script>
<%      return; }

    BoardDAO dao = new BoardDAO();
    int no = 0;
    try {
        no = Integer.parseInt(request.getParameter("no"));
    } catch (Exception e) {
%>
        <script>alert('不正なアクセスです。'); location.href='community.jsp';</script>
<%      return; }

    BoardDTO origin = dao.getBoard(no);
    if (origin == null) {
%>
        <script>alert('投稿が見つかりません。'); location.href='community.jsp';</script>
<%      return; }

    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String category   = request.getParameter("category");
        String contentTag = request.getParameter("contentTag");
        String title      = request.getParameter("title");
        String content    = request.getParameter("content");
        String pic        = request.getParameter("pic");

        if (category == null) category = "강아지";
        if (title    == null) title    = "";
        if (content  == null) content  = "";
        if (pic      == null) pic      = "";

        category = category.trim(); title = title.trim();
        content  = content.trim();  pic   = pic.trim();

        
        boolean valid = false;
        for (String a : new String[]{"강아지","고양이","기타","커뮤니티","콘텐츠"})
            if (a.equals(category)) { valid = true; break; }
        if (!valid) category = "강아지";

        if (title.isEmpty()) {
%>
            <script>alert('タイトルを入力してください。'); history.back();</script>
<%          return; }

        
        String plain = content.replaceAll("<[^>]*>","").replace("&nbsp;"," ").trim();
        if (plain.length() < 1 && content.indexOf("<img") < 0) {
%>
            <script>alert('内容を入力するか画像を追加してください。'); history.back();</script>
<%          return; }

        
        if (pic.isEmpty()) {
            Matcher m = Pattern.compile("<img[^>]*src=[\"']([^\"']+)[\"'][^>]*>",
                        Pattern.CASE_INSENSITIVE).matcher(content);
            if (m.find()) pic = m.group(1);
        }

        
        String finalTag;
        if ("콘텐츠".equals(category)) {
            if (contentTag != null && !contentTag.trim().isEmpty()) {
                finalTag = "콘텐츠_" + contentTag.trim();
            } else {
                finalTag = "콘텐츠";
            }
        } else if ("기타".equals(category)) {
            finalTag = "커뮤니티";
        } else {
            finalTag = category;
        }

        String writer   = (origin.getWriter()   != null && !origin.getWriter().trim().isEmpty())   ? origin.getWriter()   : u.getId();
        String nickname = (u.getNickname()       != null && !u.getNickname().trim().isEmpty())      ? u.getNickname()      : origin.getNickname();

        BoardDTO dto = new BoardDTO();
        dto.setNo(no); dto.setTag(finalTag); dto.setTitle(title);
        dto.setContent(content); dto.setPic(pic);
        dto.setWriter(writer); dto.setNickname(nickname);

        int result = dao.updateBoard(dto);
        if (result <= 0 && pic.startsWith("data:image/")) {
            dto.setPic(origin.getPic() == null ? "" : origin.getPic());
            result = dao.updateBoard(dto);
        }

        if (result > 0) {
%>
            <script>alert('投稿を更新しました！🐾'); location.href='detail.jsp?no=<%=no%>';</script>
<%      } else { %>
            <script>alert('更新に失敗しました。管理者にお問い合わせください。'); history.back();</script>
<%      }
        return;
    }

    
    boolean updateIsAdmin = (u.getRole() == 1);
    String uiCategory = origin.getTag();
    if (uiCategory == null || uiCategory.trim().isEmpty()) uiCategory = "강아지";

    
    String[] contentTags = {"건강","행동","음식","훈련","견종백과","묘종백과","용품리뷰","입양정보","미용케어","산책운동"};
    boolean isContentTag = false;
    String currentContentTag = "";
    
    if (uiCategory.startsWith("콘텐츠_")) {
        isContentTag = true;
        currentContentTag = uiCategory.substring("콘텐츠_".length());
    } else if (uiCategory.equals("콘텐츠")) {
        isContentTag = true;
        currentContentTag = "";
    } else {
        
        for (String ct : contentTags) {
            if (ct.equals(uiCategory)) { isContentTag = true; currentContentTag = uiCategory; break; }
        }
    }
    
    if (isContentTag) uiCategory = "콘텐츠";
    else if ("커뮤니티".equals(uiCategory)) uiCategory = "기타";
%>

<%@ include file="../header.jsp" %>

<link href="https://cdn.jsdelivr.net/npm/summernote@0.9.0/dist/summernote-lite.min.css" rel="stylesheet">

<style>
    body { background-color: #fdfaf4 !important; font-family: 'OshidashiGothic', sans-serif !important; }

    .write-wrapper {
        max-width: 1100px; margin: 50px auto;
        background: #ffffff; padding: 60px;
        border-radius: 25px; box-shadow: 0 10px 30px rgba(0,0,0,0.03);
    }

    .write-header {
        margin-bottom: 40px; padding-bottom: 25px; border-bottom: 2px solid #f9f9f9;
        display: flex; align-items: center; gap: 18px;
    }
    .paw-icon {
        font-size: 26px; color: #fdd835;
        background: #fff8e1; padding: 12px; border-radius: 50%;
        display: inline-flex; align-items: center; justify-content: center;
        box-shadow: 0 4px 12px rgba(253,216,53,0.2);
    }
    .write-title { font-size: 32px; font-weight: 900; color: #333; margin: 0; }

    .form-group { margin-bottom: 35px; }
    .form-label {
        display: block; font-size: 18px; font-weight: 800; color: #333; margin-bottom: 15px;
    }

    .chip-row { display: flex; gap: 12px; }
    .cat-chip {
        padding: 10px 24px; border-radius: 30px;
        background: #f9f9f9; color: #777; font-weight: 700; font-size: 15px;
        border: 1px solid #eee; cursor: pointer; transition: 0.2s;
    }
    .cat-chip.active {
        background: #fdd835; color: #111; border-color: #fdd835;
        box-shadow: 0 4px 12px rgba(253,216,53,0.3);
    }
    .cat-chip.admin-chip.active {
        background: #333; color: #fdd835; border-color: #333;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    }
    .admin-chip-label {
        font-size: 10px; font-weight: 800; background: #ff4757;
        color: #fff; padding: 2px 6px; border-radius: 6px; margin-left: 4px;
    }

    
    .content-tag-section {
        display: none;
        margin-top: 20px; padding: 20px 22px;
        background: #fdfaf4; border: 1.5px solid #f0ece2;
        border-radius: 14px; animation: fadeIn 0.25s ease;
    }
    .content-tag-section.show { display: block; }
    @keyframes fadeIn { from { opacity: 0; transform: translateY(-6px); } to { opacity: 1; transform: translateY(0); } }
    .tag-section-label {
        font-size: 13px; font-weight: 800; color: #888;
        letter-spacing: 0.8px; margin-bottom: 12px;
        display: flex; align-items: center; gap: 7px;
    }
    .tag-section-label::before {
        content: ''; display: block; width: 3px; height: 14px;
        background: #fdd835; border-radius: 2px;
    }
    .tag-chip-row { display: flex; gap: 8px; flex-wrap: wrap; }
    .tag-chip {
        padding: 7px 16px; border-radius: 20px;
        background: #fff; color: #888; font-weight: 700; font-size: 13px;
        border: 1.5px solid #e8e8e8; cursor: pointer; transition: 0.18s;
        display: flex; align-items: center; gap: 5px;
    }
    .tag-chip:hover { border-color: #fdd835; color: #555; background: #fffde7; }
    .tag-chip.active {
        background: #fdd835; color: #333; border-color: #fdd835;
        box-shadow: 0 3px 10px rgba(253,216,53,0.3);
    }

    .write-input {
        width: 100%; height: 55px; border: 1px solid #ddd; border-radius: 15px;
        font-size: 17px; padding: 0 20px; box-sizing: border-box; transition: 0.2s;
    }
    .write-input:focus { border-color: #fdd835; outline: none; }

    .note-editor.note-frame { border: 1px solid #ddd !important; border-radius: 15px; overflow: hidden; }
    .note-editable { min-height: 500px !important; font-size: 16px; line-height: 1.7; padding: 30px !important; }
    .note-toolbar { display: none !important; }
    .note-editable img { max-width: 700px !important; height: auto !important; }

    .upload-box {
        margin-top: 20px; padding: 18px 24px;
        border-radius: 15px; background: #fffcf0; border: 1px dashed #e6d18a;
        display: flex; align-items: center; justify-content: space-between;
    }
    .file-btn {
        background: #fff; border: 1px solid #e6d18a; color: #ae8b1d;
        font-weight: 800; border-radius: 10px; padding: 10px 20px; cursor: pointer;
    }
    .file-btn:hover { background: #fdd835; color: #111; border-color: #fdd835; }

    .btn-wrap { display: flex; justify-content: center; gap: 14px; margin-top: 50px; padding-top: 30px; border-top: 1px solid #f9f9f9; }
    .btn-cancel {
        border: 2px solid #ddd; border-radius: 50px; background: #fff; color: #666;
        font-size: 17px; font-weight: 800; padding: 15px 45px; cursor: pointer; transition: 0.2s;
    }
    .btn-cancel:hover { border-color: #bbb; background: #f5f5f5; }
    .btn-submit {
        border: 0; border-radius: 50px; background: #333; color: #fff;
        font-size: 18px; font-weight: 800; padding: 15px 60px; cursor: pointer; transition: 0.2s;
    }
    .btn-submit:hover { background: #fdd835; color: #111; transform: translateY(-3px); }
</style>

<div class="write-wrapper">
    <form method="post" action="update.jsp" accept-charset="UTF-8" onsubmit="return beforeSubmit();">
        <input type="hidden" name="no"         value="<%=no%>">
        <input type="hidden" id="pic"          name="pic"        value="<%= h(origin.getPic()) %>">
        <input type="hidden" id="category"     name="category"   value="<%= h(uiCategory) %>">
        <input type="hidden" id="contentTag"   name="contentTag" value="<%= h(currentContentTag) %>">

        <div class="write-header">
            <div class="paw-icon"><i class="fas fa-pen"></i></div>
            <h1 class="write-title">投稿を編集</h1>
        </div>

        <!-- 카테고리 -->
        <div class="form-group">
            <label class="form-label">カテゴリー</label>
            <div class="chip-row" id="chipRow">
                <button type="button" class="cat-chip <%= "강아지".equals(uiCategory) ? "active" : "" %>" data-cat="강아지">🐶 犬</button>
                <button type="button" class="cat-chip <%= "고양이".equals(uiCategory) ? "active" : "" %>" data-cat="고양이">🐱 猫</button>
                <button type="button" class="cat-chip <%= "기타".equals(uiCategory)   ? "active" : "" %>" data-cat="기타">💬 その他</button>
                <% if (updateIsAdmin) { %>
                <button type="button" class="cat-chip admin-chip <%= "콘텐츠".equals(uiCategory) ? "active" : "" %>" data-cat="콘텐츠">
                    📋 コンテンツ <span class="admin-chip-label">管理者</span>
                </button>
                <% } %>
            </div>

            <!-- 콘텐츠 태그 선택 (관리자 전용) -->
            <% if (updateIsAdmin) { %>
            <div class="content-tag-section <%= "콘텐츠".equals(uiCategory) ? "show" : "" %>" id="contentTagSection">
                <div class="tag-section-label">コンテンツタグを選択</div>
                <div class="tag-chip-row" id="tagChipRow">
                    <% String[] updateTags = {"건강","행동","음식","훈련","견종백과","묘종백과","용품리뷰","입양정보","미용케어","산책운동"};
                       String[] updateLabels = {"🏥 健康","🐾 しつけ","🍖 食事","🎯 トレーニング","📖 犬種図鑑","📖 猫種図鑑","🛍️ 用品レビュー","🏠 里親情報","✂️ グルーミング","🏃 散歩・運動"};
                       String[] updateEmojis = {"🏥","🐾","🍖","🎯","📖","📖","🛍️","🏠","✂️","🏃"};
                       for (int ti = 0; ti < updateTags.length; ti++) { %>
                    <button type="button" class="tag-chip <%= updateTags[ti].equals(currentContentTag) ? "active" : "" %>"
                            data-tag="<%= updateTags[ti] %>"><%= updateEmojis[ti] %> <%= updateLabels[ti] %></button>
                    <% } %>
                </div>
            </div>
            <% } %>
        </div>

        <!-- 제목 -->
        <div class="form-group">
            <label class="form-label">タイトル</label>
            <input type="text" name="title" class="write-input"
                   value="<%= h(origin.getTitle()) %>" placeholder="タイトルを入力してください" required>
        </div>

        <!-- 내용 -->
        <div class="form-group">
            <label class="form-label">内容</label>
            <textarea id="summernote" name="content"><%= origin.getContent() == null ? "" : origin.getContent() %></textarea>
            <div class="upload-box">
                <span id="fileText">写真を選ぶと本文に挿入されます。</span>
                <label class="file-btn" for="imgFiles">写真を探す</label>
                <input type="file" id="imgFiles" accept="image/*" multiple style="display:none;">
            </div>
        </div>

        <!-- 버튼 -->
        <div class="btn-wrap">
            <button type="button" class="btn-cancel"
                    onclick="if(confirm('編集をキャンセルして戻りますか？')) location.href='detail.jsp?no=<%=no%>'">
                キャンセル
            </button>
            <button type="submit" class="btn-submit">保存完了</button>
        </div>
    </form>
</div>

<script src="https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/summernote@0.9.0/dist/summernote-lite.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/summernote@0.9.0/dist/lang/summernote-ko-KR.min.js"></script>

<script>
$(function () {
    
    $('#summernote').summernote({
        height: 500,
        lang: 'ko-KR',
        placeholder: '内容を編集してください 🐾',
        toolbar: [
            ['font',   ['bold', 'underline', 'clear']],
            ['color',  ['color']],
            ['para',   ['ul', 'ol']],
            ['insert', ['link', 'picture']],
            ['view',   ['fullscreen']]
        ],
        callbacks: {
            onImageUpload: function(files) { processFiles(files); }
        }
    });

    
    $('.cat-chip').click(function() {
        $('.cat-chip').removeClass('active');
        $(this).addClass('active');
        const cat = $(this).data('cat');
        $('#category').val(cat);
        if (cat === '콘텐츠') {
            $('#contentTagSection').addClass('show');
        } else {
            $('#contentTagSection').removeClass('show');
            $('.tag-chip').removeClass('active');
            $('#contentTag').val('');
        }
    });

    
    $(document).on('click', '.tag-chip', function() {
        const wasActive = $(this).hasClass('active');
        $('.tag-chip').removeClass('active');
        if (!wasActive) {
            $(this).addClass('active');
            $('#contentTag').val($(this).data('tag'));
        } else {
            $('#contentTag').val('');
        }
    });

    
    $('#imgFiles').change(function() {
        const files = Array.from(this.files);
        if (!files.length) return;
        processFiles(files);
    });

    function processFiles(files) {
        $('#fileText').text(files.length + '個のファイル処理中...');
        Array.from(files).forEach(file => {
            if (!file.type.match('image.*')) return;
            const reader = new FileReader();
            reader.onload = e => {
                const img = new Image();
                img.onload = function() {
                    const canvas = document.createElement('canvas');
                    let w = img.width, h = img.height;
                    const MAX_W = 700;
                    if (w > MAX_W) { h *= MAX_W / w; w = MAX_W; }
                    canvas.width = w; canvas.height = h;
                    canvas.getContext('2d').drawImage(img, 0, 0, w, h);
                    const dataUrl = canvas.toDataURL('image/jpeg', 0.7);
                    $('#summernote').summernote('insertImage', dataUrl);
                };
                img.src = e.target.result;
            };
            reader.readAsDataURL(file);
        });
        $('#fileText').text('写真の挿入完了 🐾');
        $('#imgFiles').val('');
    }
});

function beforeSubmit() {
    if ($('#category').val() === '콘텐츠' && !$('#contentTag').val()) {
        alert('コンテンツタグを選択してください！（🏥 健康、🐾 しつけ、🍖 食事など）');
        return false;
    }
    const html = $('#summernote').summernote('code');
    const temp = $('<div>').html(html);
    const firstImg = temp.find('img').first();
    if (firstImg.length > 0) $('#pic').val(firstImg.attr('src'));
    return true;
}
</script>

<%@ include file="../footer.jsp" %>
