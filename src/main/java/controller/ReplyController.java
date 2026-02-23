package controller;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.ReplyDAO;
import model.ReplyDTO;

@WebServlet("/Reply")
public class ReplyController extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        String cmd = request.getParameter("cmd");
        ReplyDAO dao = new ReplyDAO();

        if ("add".equals(cmd)) {
            int b_no = Integer.parseInt(request.getParameter("b_no"));
            String writer = request.getParameter("writer");
            String content = request.getParameter("content");

            if (writer == null || writer.isEmpty()) writer = "ゲスト";

            ReplyDTO dto = new ReplyDTO();
            dto.setB_no(b_no);
            dto.setWriter(writer);
            dto.setContent(content);

            dao.addReply(dto);

            PrintWriter out = response.getWriter();
            out.println("<script>");
            out.println("alert('コメントを投稿しました！');");
            out.println("location.href='" + request.getContextPath() + "/blog/detail.jsp?no=" + b_no + "';");
            out.println("</script>");
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html; charset=UTF-8");

        String cmd = request.getParameter("cmd");
        if ("delete".equals(cmd)) {
            int r_no = Integer.parseInt(request.getParameter("r_no"));
            int b_no = Integer.parseInt(request.getParameter("b_no"));

            new ReplyDAO().deleteReply(r_no);

            PrintWriter out = response.getWriter();
            out.println("<script>");
            out.println("alert('コメントを削除しました。');");
            out.println("location.href='" + request.getContextPath() + "/blog/detail.jsp?no=" + b_no + "';");
            out.println("</script>");
        }
    }
}
