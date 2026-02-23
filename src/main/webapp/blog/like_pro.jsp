<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.BoardDAO, model.UserDTO" %>
<%
    
    UserDTO user = (UserDTO) session.getAttribute("user");
    String noStr = request.getParameter("no");

    if (user == null || noStr == null) {
        out.print("fail");
        return;
    }

    try {
        int bNo = Integer.parseInt(noStr);
        BoardDAO dao = new BoardDAO();
        
        
        
        int newCount = dao.toggleLike(user.getId(), bNo);

        if (newCount >= 0) {
            out.print(newCount); 
        } else {
            out.print("fail");
        }
    } catch (Exception e) {
        out.print("fail");
    }
%>