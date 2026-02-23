package model;

import java.sql.Date;

public class BoardDTO {
    // 멤버 변수 (DB 컬럼과 일치)
    private int no;         // B_NO
    private String tag;     // B_TAG
    private String title;   // B_TITLE
    private String content; // B_CONTENT
    private String pic;     // B_PIC (게시글 사진)
    private String writer;  // B_WRITER (작성자 ID)
    private String nickname;// B_NICKNAME
    private Date date;      // B_DATE
    private int views;      // B_VIEWS
    private int likes;      // B_LIKES

    // 기본 생성자
    public BoardDTO() {
    }

    // Getter & Setter 메서드
    public int getNo() {
        return no;
    }
    public void setNo(int no) {
        this.no = no;
    }

    public String getTag() {
        return tag;
    }
    public void setTag(String tag) {
        this.tag = tag;
    }

    public String getTitle() {
        return title;
    }
    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return content;
    }
    public void setContent(String content) {
        this.content = content;
    }

    public String getPic() {
        return pic;
    }
    public void setPic(String pic) {
        this.pic = pic;
    }

    public String getWriter() {
        return writer;
    }
    public void setWriter(String writer) {
        this.writer = writer;
    }

    public String getNickname() {
        return nickname;
    }
    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public Date getDate() {
        return date;
    }
    public void setDate(Date date) {
        this.date = date;
    }

    public int getViews() {
        return views;
    }
    public void setViews(int views) {
        this.views = views;
    }

    public int getLikes() {
        return likes;
    }
    public void setLikes(int likes) {
        this.likes = likes;
    }
}