package controller;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.UserDAO;
import model.UserDTO;

@WebServlet("/User")
public class UserController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        
        String action = request.getParameter("action");
        
        UserDAO dao = new UserDAO();
        PrintWriter out = response.getWriter();
        HttpSession session = request.getSession();

        if ("join".equals(action)) {
            String id = request.getParameter("id");
            String pw = request.getParameter("pw");
            String nickname = request.getParameter("nickname");
            
            UserDTO dto = new UserDTO();
            dto.setId(id);
            dto.setPw(pw);
            dto.setNickname(nickname);
            
            int result = dao.join(dto);
            
            if (result > 0) {
                out.println("<script>alert('会員登録が完了しました！ログインしてください。'); location.href='index.jsp';</script>");
            } else {
                out.println("<script>alert('会員登録に失敗しました。もう一度お試しください。'); history.back();</script>");
            }

        } else if ("login".equals(action)) {
            String id = request.getParameter("id");
            String pw = request.getParameter("pw");
            
            UserDTO user = dao.login(id, pw); 
            
            if (user != null) {
                session.setAttribute("user", user);
                out.println("<script>alert('" + user.getNickname() + "様、ようこそ！'); location.href='index.jsp';</script>");
            } else {
                out.println("<script>alert('メールアドレスまたはパスワードを確認してください。'); history.back();</script>");
            }

        } else if ("logout".equals(action)) {
            session.invalidate();
            out.println("<script>alert('ログアウトしました。'); location.href='index.jsp';</script>");
        }
    }
}