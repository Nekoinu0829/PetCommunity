package controller;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/MoveBoard")
public class BoardController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        
        String cmd = request.getParameter("cmd");
        String contextPath = request.getContextPath();
        HttpSession session = request.getSession();

        
        if (cmd == null || cmd.equals("list")) {
            response.sendRedirect(contextPath + "/blog/community.jsp");
        } 
        
        
        else if (cmd.equals("contents")) {
            response.sendRedirect(contextPath + "/blog/contents.jsp");
        }

        
        else if (cmd.equals("write")) {
            if(session.getAttribute("user") == null) {
                PrintWriter out = response.getWriter();
                out.println("<script>");
                out.println("alert('ログインが必要なサービスです！ 🐾');");
                out.println("location.href='" + contextPath + "/index.jsp';"); 
                out.println("</script>");
                out.flush();
            } else {
                response.sendRedirect(contextPath + "/blog/write.jsp");
            }
        } 
        
        
        else {
            response.sendRedirect(contextPath + "/index.jsp");
        }
    }
}