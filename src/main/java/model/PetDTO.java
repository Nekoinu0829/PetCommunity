package model;

import java.sql.Date;

public class PetDTO {
    private int    petNo;
    private String memberId;
    private String petName;
    private String petPic;   // CLOB: base64 data URL
    private Date   regDate;

    public int    getPetNo()   { return petNo; }
    public void   setPetNo(int petNo) { this.petNo = petNo; }

    public String getMemberId()  { return memberId; }
    public void   setMemberId(String memberId) { this.memberId = memberId; }

    public String getPetName()  { return petName; }
    public void   setPetName(String petName) { this.petName = petName; }

    public String getPetPic()   { return petPic; }
    public void   setPetPic(String petPic) { this.petPic = petPic; }

    public Date   getRegDate()  { return regDate; }
    public void   setRegDate(Date regDate) { this.regDate = regDate; }
}