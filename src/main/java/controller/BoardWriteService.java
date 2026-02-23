package controller;

import java.io.File;
import java.io.IOException;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import model.BoardDAO;
import model.BoardDTO;
import model.UserDTO;

public class BoardWriteService extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        
        
        String uploadPath = request.getServletContext().getRealPath("/upload");
        System.out.println("========== [디버깅 시작] ==========");
        System.out.println("1. 서버 저장 경로: " + uploadPath); 

        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
            System.out.println("2. 폴더가 없어서 새로 생성함");
        } else {
            System.out.println("2. 폴더가 이미 존재함");
        }

        
        String tag = request.getParameter("tag");
        String title = request.getParameter("title");
        String content = request.getParameter("content");

        
        String saveFileName = "no_img.png"; 
        Part filePart = null;
        try {
            filePart = request.getPart("pic");
        } catch (Exception e) { e.printStackTrace(); }

        if (filePart != null && filePart.getSize() > 0) {
            String originName = getFileName(filePart);
            System.out.println("3. 업로드된 파일명: " + originName);
            System.out.println("4. 파일 크기: " + filePart.getSize() + " bytes");

            if (originName != null && !originName.isEmpty()) {
                saveFileName = UUID.randomUUID().toString() + "_" + originName;
                filePart.write(uploadPath + File.separator + saveFileName);
                System.out.println("5. 최종 저장된 파일명: " + saveFileName);
                System.out.println("6. 저장 성공! 위치 확인 요망.");
            }
        } else {
            System.out.println("3. 파일이 업로드되지 않음 (기본 이미지 사용)");
        }
        System.out.println("================================");

        
        HttpSession session = request.getSession();
        UserDTO loginUser = (UserDTO) session.getAttribute("user");
        
        BoardDTO dto = new BoardDTO();
        dto.setTag(tag);
        dto.setTitle(title);
        dto.setContent(content);
        dto.setPic(saveFileName);
        dto.setWriter(loginUser != null ? loginUser.getId() : "guest");
        dto.setNickname(loginUser != null ? loginUser.getNickname() : "ゲスト");

        BoardDAO dao = new BoardDAO();
        int result = dao.insertBoard(dto);

        if (result > 0) {
            response.sendRedirect(request.getContextPath() + "/MoveBoard?cmd=list");
        } else {
            response.sendRedirect(request.getContextPath() + "/MoveBoard?cmd=write");
        }
    }

    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1).replace("\"", "");
            }
        }
        return null;
    }
}