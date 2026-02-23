package model;

import java.sql.Date;

public class ReplyDTO {
    private int r_no;       // 댓글 번호
    private int b_no;       // 게시글 번호
    private String writer;  // 작성자
    private String content; // 내용
    private Date date;      // 작성일

    // 기본 생성자
    public ReplyDTO() {}

    // Getter & Setter
    public int getR_no() { return r_no; }
    public void setR_no(int r_no) { this.r_no = r_no; }
    public int getB_no() { return b_no; }
    public void setB_no(int b_no) { this.b_no = b_no; }
    public String getWriter() { return writer; }
    public void setWriter(String writer) { this.writer = writer; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public Date getDate() { return date; }
    public void setDate(Date date) { this.date = date; }
}