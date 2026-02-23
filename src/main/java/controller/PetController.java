package controller;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import model.PetDAO;
import model.PetDTO;
import model.UserDTO;
import java.util.ArrayList;

@WebServlet("/PetController")
public class PetController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        res.setContentType("application/json; charset=UTF-8");
        PrintWriter out = res.getWriter();

        HttpSession session = req.getSession();
        UserDTO sessUser = (UserDTO) session.getAttribute("user");

        if (sessUser == null) {
            out.print("{\"result\":\"fail\",\"msg\":\"ログインが必要です。\"}");
            return;
        }

        String cmd = req.getParameter("cmd");
        PetDAO dao = new PetDAO();

        
        if ("insert".equals(cmd)) {
            String petName = req.getParameter("petName");
            String petPic  = req.getParameter("petPic");

            if (petName == null || petName.trim().isEmpty()) {
                out.print("{\"result\":\"fail\",\"msg\":\"名前を入力してください。\"}");
                return;
            }
            if (petPic != null) petPic = petPic.trim().replace(" ", "+");

            PetDTO dto = new PetDTO();
            dto.setMemberId(sessUser.getId());
            dto.setPetName(petName.trim());
            dto.setPetPic(petPic);

            int row = dao.insertPet(dto);
            if (row > 0) {
                out.print("{\"result\":\"ok\"}");
            } else {
                out.print("{\"result\":\"fail\",\"msg\":\"保存に失敗しました。\"}");
            }

        
        } else if ("update".equals(cmd)) {
            int petNo      = Integer.parseInt(req.getParameter("petNo"));
            String petName = req.getParameter("petName");
            String petPic  = req.getParameter("petPic");

            if (petPic != null) petPic = petPic.trim().replace(" ", "+");

            PetDTO dto = new PetDTO();
            dto.setPetNo(petNo);
            dto.setMemberId(sessUser.getId());
            dto.setPetName(petName != null ? petName.trim() : "");
            dto.setPetPic(petPic);

            int row = dao.updatePet(dto);
            out.print(row > 0 ? "{\"result\":\"ok\"}" : "{\"result\":\"fail\",\"msg\":\"更新に失敗しました。\"}");

        
        } else if ("delete".equals(cmd)) {
            int petNo = Integer.parseInt(req.getParameter("petNo"));
            int row   = dao.deletePet(petNo, sessUser.getId());
            out.print(row > 0 ? "{\"result\":\"ok\"}" : "{\"result\":\"fail\",\"msg\":\"削除に失敗しました。\"}");

        } else {
            out.print("{\"result\":\"fail\",\"msg\":\"不明なコマンドです。\"}");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        doPost(req, res);
    }
}