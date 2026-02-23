document.addEventListener('DOMContentLoaded', () => {
    // 검색창 기능 (기존 유지)
    const searchBtn = document.querySelector('.search-bar button');
    if(searchBtn) {
        searchBtn.addEventListener('click', () => {
            const searchInput = document.querySelector('.search-bar input').value;
            if (searchInput.trim() !== "") {
                alert(`"${searchInput}" 검색 기능은 준비 중입니다.`);
            }
        });
    }
});

// === 탭 전환 함수 (드롭다운 내부에서 사용) ===
function openTab(evt, tabName) {
    // 1. 이벤트 전파 방지 (탭 눌렀다고 드롭다운 닫히지 않게)
    // evt.stopPropagation(); // 필요 시 주석 해제

    // 2. 탭 내용 숨기기
    const tabContents = document.getElementsByClassName("tab-content");
    for (let i = 0; i < tabContents.length; i++) {
        tabContents[i].style.display = "none";
    }

    // 3. 탭 버튼 스타일 초기화
    const tabLinks = document.getElementsByClassName("tab-link");
    for (let i = 0; i < tabLinks.length; i++) {
        tabLinks[i].className = tabLinks[i].className.replace(" active", "");
    }

    // 4. 선택된 탭 보이기
    document.getElementById(tabName).style.display = "block";
    evt.currentTarget.className += " active";
}
/* 모달창 열기 */
function openModal() {
    document.getElementById('editModal').style.display = 'flex';
}

/* 모달창 닫기 */
function closeModal() {
    document.getElementById('editModal').style.display = 'none';
}

/* 모달창 바깥(검은 배경) 클릭 시 닫기 */
window.onclick = function(event) {
    var modal = document.getElementById('editModal');
    if (event.target == modal) {
        closeModal();
    }
}

/* 파일 선택 시 처리 (이미지 미리보기 + 파일명 표시) */
function handleFileSelect(input) {
    var fileNameContainer = document.getElementById('modalFileName');
    var previewImage = document.getElementById('preview');

    // 파일이 선택되었는지 확인
    if (input.files && input.files[0]) {
        // 1. 파일명 텍스트 변경
        fileNameContainer.innerText = input.files[0].name;

        // 2. 이미지 미리보기 변경
        var reader = new FileReader();
        reader.onload = function(e) {
            previewImage.src = e.target.result;
        };
        reader.readAsDataURL(input.files[0]);
    } else {
        // 취소했을 경우
        fileNameContainer.innerText = "선택된 파일 없음";
    }
	
}