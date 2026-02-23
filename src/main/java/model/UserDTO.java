package model;

import java.sql.Date;

public class UserDTO {
    // 1. 변수 선언
    private String id;
    private String pw;
    private String nickname;
    private Date joinDate;
    private String pic; 
    public int getRole() {
		return role;
	}
	public void setRole(int role) {
		this.role = role;
	}
	private int role;

    // 2. Getter / Setter 메서드 (이게 있어야 DAO가 부를 수 있음!)
    
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    
    public String getPw() { return pw; }
    public void setPw(String pw) { this.pw = pw; }
    
    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }
    
    public Date getJoinDate() { return joinDate; }
    public void setJoinDate(Date joinDate) { this.joinDate = joinDate; }
    
    // ▼▼▼ DAO가 찾고 있는 게 바로 이 녀석들입니다! ▼▼▼
    public String getPic() { return pic; }
    public void setPic(String pic) { this.pic = pic; }
}