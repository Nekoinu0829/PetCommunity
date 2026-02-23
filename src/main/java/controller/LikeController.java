package controller;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import model.BoardDAO;
import model.UserDTO;

@WebServlet("/LikeController")
public class LikeController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        UserDTO user = (session == null) ? null : (UserDTO) session.getAttribute("user");
        if (user == null) {
            response.setStatus(401);
            out.print("{\"status\":\"login\"}");
            return;
        }

        String bNoStr = request.getParameter("bNo");
        if (bNoStr == null || bNoStr.trim().isEmpty()) {
            bNoStr = request.getParameter("no"); 
        }

        int bNo = 0;
        try {
            bNo = Integer.parseInt(bNoStr);
        } catch (Exception e) {
            response.setStatus(400);
            out.print("{\"status\":\"bad\"}");
            return;
        }

        String userId = user.getId();

        BoardDAO dao = new BoardDAO();

        boolean wasLiked = dao.isLike(userId, bNo);
        int likes = dao.toggleLike(userId, bNo);

        if (likes < 0) {
            response.setStatus(500);
            out.print("{\"status\":\"fail\"}");
            return;
        }

        boolean liked = !wasLiked; 
        out.print("{\"status\":\"success\",\"likes\":" + likes + ",\"liked\":" + (liked ? "true" : "false") + "}");
    }
}
