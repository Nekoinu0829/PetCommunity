<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.regex.Pattern, java.util.regex.Matcher" %>
<%@ page import="model.BoardDAO, model.BoardDTO, model.UserDTO" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();
%>
<%@ include file="../header.jsp" %>
<%
    UserDTO u = (UserDTO) session.getAttribute("user");
    if (u == null) {
%>
        <script>alert('ログインが必要です。'); location.href='<%=ctx%>/login.jsp';</script>
<%      return; }

    
    boolean writeIsAdmin = (u.getRole() == 1);

    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String category  = request.getParameter("category");
        String contentTag = request.getParameter("contentTag"); 
        String title     = request.getParameter("title");
        String content   = request.getParameter("content");
        String pic       = request.getParameter("pic");

        if (category == null) category = "강아지";
        if (title    == null) title    = "";
        if (content  == null) content  = "";
        if (pic      == null) pic      = "";

        
        if ("콘텐츠".equals(category) && !writeIsAdmin) {
%>
            <script>alert('権限がありません。'); history.back();</script>
<%          return; }

        if (title.trim().isEmpty()) {
%>
            <script>alert('タイトルを入力してください。'); history.back();</script>
<%          return; }

        
        if (pic.isEmpty()) {
            Matcher m = Pattern.compile("<img[^>]*src=[\"']([^\"']+)[\"'][^>]*>",
                        Pattern.CASE_INSENSITIVE).matcher(content);
            if (m.find()) pic = m.group(1);
        }

        
        
        String finalTag = category;
        if ("콘텐츠".equals(category)) {
            if (contentTag != null && !contentTag.trim().isEmpty()) {
                finalTag = "콘텐츠_" + contentTag.trim();
            } else {
                finalTag = "콘텐츠";
            }
        }

        BoardDTO dto = new BoardDTO();
        dto.setTag(finalTag);
        dto.setTitle(title);
        dto.setContent(content);
        dto.setPic(pic);
        dto.setWriter(u.getId());
        dto.setNickname(u.getNickname());

        int result = new BoardDAO().insertBoard(dto);
        if (result > 0) {
            String redirect = "콘텐츠".equals(category) ? "contents.jsp" : "community.jsp";
%>
            <script>alert('投稿が完了しました！🐾'); location.href='<%=redirect%>';</script>
<%      } else { %>
            <script>alert('登録に失敗しました。画像が多すぎるかDBの容量問題の可能性があります。'); history.back();</script>
<%      }
        return;
    }
%>

<link href="https://cdn.jsdelivr.net/npm/summernote@0.9.0/dist/summernote-lite.min.css" rel="stylesheet">

<style>
    body { background-color: #fdfaf4 !important; font-family: 'OshidashiGothic', sans-serif !important; }

    .write-wrapper {
        max-width: 1100px; margin: 50px auto 100px;
        background: #fff; padding: 60px;
        border-radius: 25px; box-shadow: 0 10px 30px rgba(0,0,0,0.03);
    }

    .write-header {
        display: flex; align-items: center; gap: 18px;
        margin-bottom: 40px; padding-bottom: 25px; border-bottom: 2px solid #f0f0f0;
    }
    .paw-icon {
        font-size: 22px; color: #fdd835; background: #fff8e1;
        padding: 14px; border-radius: 50%;
        display: inline-flex; align-items: center; justify-content: center;
        box-shadow: 0 4px 12px rgba(253,216,53,0.25); flex-shrink: 0;
    }
    .write-title-box h1 { font-size: 30px; font-weight: 900; color: #222; margin: 0; }
    .write-title-box p  { font-size: 14px; color: #aaa; margin: 5px 0 0; }

    .form-group { margin-bottom: 36px; }
    .form-label {
        display: flex; align-items: center; gap: 8px;
        font-size: 16px; font-weight: 800; color: #333; margin-bottom: 14px;
    }
    .form-label i { color: #fdd835; font-size: 15px; }

    .chip-row { display: flex; gap: 10px; flex-wrap: wrap; }
    .cat-chip {
        padding: 10px 22px; border-radius: 30px;
        background: #f5f5f5; color: #777; font-weight: 700; font-size: 14px;
        border: 1.5px solid #eee; cursor: pointer; transition: 0.2s;
    }
    .cat-chip:hover { background: #efefef; }
    .cat-chip.active {
        background: #fdd835; color: #111; border-color: #fdd835;
        box-shadow: 0 4px 12px rgba(253,216,53,0.35);
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
        margin-top: 24px;
        padding: 22px 24px;
        background: #fdfaf4;
        border: 1.5px solid #f0ece2;
        border-radius: 14px;
        animation: fadeIn 0.25s ease;
    }
    .content-tag-section.show { display: block; }
    @keyframes fadeIn { from { opacity: 0; transform: translateY(-6px); } to { opacity: 1; transform: translateY(0); } }

    .tag-section-label {
        font-size: 13px; font-weight: 800; color: #888;
        text-transform: uppercase; letter-spacing: 0.8px;
        margin-bottom: 14px; display: flex; align-items: center; gap: 7px;
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
        width: 100%; height: 54px; border: 1.5px solid #e8e8e8; border-radius: 14px;
        font-size: 16px; padding: 0 20px; box-sizing: border-box;
        background: #fafafa; transition: 0.2s; font-family: 'OshidashiGothic', sans-serif;
    }
    .write-input:focus { border-color: #fdd835; background: #fff; outline: none; box-shadow: 0 0 0 3px rgba(253,216,53,0.15); }

    .note-editor.note-frame { border: 1.5px solid #e8e8e8 !important; border-radius: 14px; overflow: hidden; }
    .note-toolbar { display: none !important; }
    .note-editable { min-height: 480px !important; font-size: 16px; line-height: 1.8; padding: 28px !important; }
    .note-editable img { max-width: 700px !important; height: auto !important; }
    .note-statusbar { display: none !important; }

    .upload-box {
        display: flex; align-items: center; justify-content: space-between;
        margin-top: 14px; padding: 16px 22px;
        background: #fffcf0; border: 1.5px dashed #e6d18a; border-radius: 12px;
    }
    .upload-text { font-size: 14px; color: #b09430; display: flex; align-items: center; gap: 8px; }
    .file-btn {
        background: #fff; border: 1.5px solid #e6d18a; color: #ae8b1d;
        font-weight: 800; font-size: 13px; border-radius: 10px;
        padding: 9px 18px; cursor: pointer; transition: 0.2s; white-space: nowrap;
    }
    .file-btn:hover { background: #fdd835; color: #111; border-color: #fdd835; }

    .submit-wrap {
        display: flex; justify-content: center; gap: 12px;
        margin-top: 50px; padding-top: 30px; border-top: 1.5px solid #f0f0f0;
    }
    .btn-cancel {
        border: 2px solid #ddd; border-radius: 50px; background: #fff; color: #888;
        font-size: 16px; font-weight: 800; padding: 14px 40px; cursor: pointer; transition: 0.2s;
    }
    .btn-cancel:hover { border-color: #bbb; background: #f5f5f5; color: #555; }
    .btn-submit {
        border: 0; border-radius: 50px; background: #333; color: #fff;
        font-size: 17px; font-weight: 800; padding: 14px 60px; cursor: pointer; transition: 0.2s;
    }
    .btn-submit:hover { background: #fdd835; color: #111; transform: translateY(-2px); }
</style>

<div class="write-wrapper">
    <form method="post" action="write.jsp" onsubmit="return beforeSubmit();">
        <input type="hidden" id="pic"        name="pic">
        <input type="hidden" id="category"   name="category"   value="강아지">
        <input type="hidden" id="contentTag" name="contentTag" value="">

        <div class="write-header">
            <div class="paw-icon"><i class="fas fa-paw"></i></div>
            <div class="write-title-box">
                <h1>新しい投稿</h1>
                <p>ペットとの大切なストーリーを共有しましょう 🐾</p>
            </div>
        </div>

        <!-- 카테고리 -->
        <div class="form-group">
            <label class="form-label"><i class="fas fa-tag"></i> カテゴリー</label>
            <div class="chip-row" id="chipRow">
                <button type="button" class="cat-chip active" data-cat="강아지">🐶 犬</button>
                <button type="button" class="cat-chip"        data-cat="고양이">🐱 猫</button>
                <% if (writeIsAdmin) { %>
                <button type="button" class="cat-chip admin-chip" data-cat="콘텐츠">
                    📋 コンテンツ <span class="admin-chip-label">管理者</span>
                </button>
                <% } %>
            </div>

            <!-- 콘텐츠 태그 선택 (관리자 전용, 콘텐츠 선택 시 표시) -->
            <% if (writeIsAdmin) { %>
            <div class="content-tag-section" id="contentTagSection">
                <div class="tag-section-label">コンテンツタグを選択</div>
                <div class="tag-chip-row" id="tagChipRow">
                    <button type="button" class="tag-chip" data-tag="건강">🏥 健康</button>
                    <button type="button" class="tag-chip" data-tag="행동">🐾 しつけ</button>
                    <button type="button" class="tag-chip" data-tag="음식">🍖 食事</button>
                    <button type="button" class="tag-chip" data-tag="훈련">🎯 トレーニング</button>
                    <button type="button" class="tag-chip" data-tag="견종백과">📖 犬種図鑑</button>
                    <button type="button" class="tag-chip" data-tag="묘종백과">📖 猫種図鑑</button>
                    <button type="button" class="tag-chip" data-tag="용품리뷰">🛍️ 用品レビュー</button>
                    <button type="button" class="tag-chip" data-tag="입양정보">🏠 里親情報</button>
                    <button type="button" class="tag-chip" data-tag="미용케어">✂️ グルーミング</button>
                    <button type="button" class="tag-chip" data-tag="산책운동">🏃 散歩・運動</button>
                </div>
            </div>
            <% } %>
        </div>

        <!-- 제목 -->
        <div class="form-group">
            <label class="form-label"><i class="fas fa-heading"></i> タイトル</label>
            <input type="text" name="title" class="write-input" placeholder="タイトルを入力してください" required>
        </div>

        <!-- 내용 -->
        <div class="form-group">
            <label class="form-label"><i class="fas fa-align-left"></i> 内容</label>
            <textarea id="summernote" name="content"></textarea>
            <div class="upload-box">
                <span class="upload-text"><i class="fas fa-image"></i> <span id="fileText">写真を選ぶと本文に自動挿入されます</span></span>
                <label class="file-btn" for="imgFiles">写真を探す</label>
                <input type="file" id="imgFiles" accept="image/*" multiple style="display:none;">
            </div>
        </div>

        <!-- 버튼 -->
        <div class="submit-wrap">
            <button type="button" class="btn-cancel" onclick="if(confirm('作成をキャンセルして戻りますか？')) history.back()">キャンセル</button>
            <button type="submit" class="btn-submit">投稿完了</button>
        </div>
    </form>
</div>

<script src="https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/summernote@0.9.0/dist/summernote-lite.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/summernote@0.9.0/dist/lang/summernote-ko-KR.min.js"></script>
<script>
$(function () {
    $('#summernote').summernote({
        height: 480,
        lang: 'ko-KR',
        placeholder: 'ペットとのストーリーを教えてください！🐾',
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
        if (files.length > 0) processFiles(files);
    });

    function processFiles(files) {
        $('#fileText').text(files.length + '個処理中...');
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
                    $('#summernote').summernote('insertImage', canvas.toDataURL('image/jpeg', 0.7));
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
    const html  = $('#summernote').summernote('code');
    const temp  = $('<div>').html(html);
    const first = temp.find('img').first();
    if (first.length > 0) $('#pic').val(first.attr('src'));
    return true;
}
</script>

<%@ include file="../footer.jsp" %>
