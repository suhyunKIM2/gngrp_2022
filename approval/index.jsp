<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import = "nek.approval.*" %>
<%@ page import = "nek.common.*" %>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>

<%@ include file="../common/usersession.jsp"%>
<% request.setCharacterEncoding("UTF-8"); %>
<%
    String sIndex = ApprUtil.setnullvalue(request.getParameter("index"), "2");     
%>
<html>

<head>
<title>전자결재</title>
</head>
<frameset cols="184,*,0" border="0">
    <frame src="./appr_left.jsp?index=<%= sIndex %>" name="left" noresize scrolling="no" marginwidth="0" marginheight="0">    
    <frame src="" name="main" scrolling="auto" marginwidth="0" marginheight="0">
    <frame src="" name="hidd" >
    <noframes>
        <body bgcolor="white" text="black" link="blue" vlink="purple" alink="red">
            <p>이 페이지를 보려면, 프레임을 볼 수 있는 브라우저가 필요합니다.</p>
        </body>
    </noframes>
</frameset>

</html>
