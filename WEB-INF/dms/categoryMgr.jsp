<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<% 	request.setCharacterEncoding("utf-8"); %>
<%
	String cssPath = "../common/css";
	String imgCssPath = "/common/css/blue";
	String imagePath = "../common/images/blue";
	String scriptPath = "../common/script";
	String[] viewType = {"0"};
	
	String menuId = request.getParameter("menuid");
	String cateType = request.getParameter("cateType");	//P:개인 / D:부서 / S: 공용
	
	/*
	 * cateGubun 값이 "D" 인 경우 최상위 분류정보를 반환한다.
	 * cateGubun 값이 "C" 인 경우 사용자가 담당한 분류정보 목록을 반환한다.
	 */ 
	String cateGubun = request.getParameter("cateGubun");
	
	String cmd ="";
	if(cateType.equals("S")){
		cmd = "admin";
	}
	String url = "./categoryTree.htm";
%>
<FRAMESET ROWS="40,*"  border="0">
	<FRAME SRC="./categoryTitle.htm" name="tree_title"   noresize="yes" border="0" scrolling="no">
	<FRAMESET COLS="10,280,*" border="0">
		<frame src="" name="null_frame" scrolling="no">
		<frame src="<%=url %>?openmode=2&isadmin=1&winname=parent.list_frame&menuid=<%=menuId %>&cmd=<%=cmd %>&cateType=<%=cateType %>&cateGubun=<%=cateGubun %>" name="tree_frame" id="tree_frame" scrolling="no">
		<frame src="" name="list_frame" id="list_frame">
	</FRAMESET>
</FRAMESET>