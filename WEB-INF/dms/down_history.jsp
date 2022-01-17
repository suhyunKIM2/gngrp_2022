<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="nek3.domain.dms.*" %>
<%@ page import="java.util.*" %>
<%@ page import="nek3.common.*" %>
<%@ page import="nek.common.util.Convert"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>문서관리&nbsp;<c:out value="${dms.subject }" />-파일다운이력</title>
<%-- <%@ include file="../common/include.common.jsp"%> --%>
<%-- <%@ include file="../common/include.script.map.jsp" %> --%>
</head>
<body BODY TEXT="000000" BGCOLOR="FFFFFF">
<DIV STYLE="position:relative; background:#ffffff; border:1px solid #6699cc; width:100%; height:100%; font-family:굴림; font-size:9pt; border:1px solid #A1B5FE;borders-top-width:0px;; z-index:3 ;">
	<!-- 타이틀 바 사이즈 -->
	<DIV  STYLE="position:relative; width:100%; background:#ffffff; font-weight:bold; font-size:9pt; ; filter:progid:DXImageTransform.Microsoft.Gradient(endColorstr='#00ffffff', startColorstr='#FF99CCFF', gradientType='1'); ">
		<table width=100% cellspacing=0 cellpadding=0 border=0 style="border-bottom:1px solid #A1B5FE;">
			<tr height=26>
				<td width=* background="../common/images/etc_infor_ti_bg.gif">
					<font color="#000000" style="font-size:9pt">&nbsp;&nbsp;<B>FileDown History</B></font>
				</td>
				<td width=20 align=center background="../common/images/etc_infor_ti_bg.gif">
				<!-- <a href="#" onclick="javascript:if(opener) opener.hideHistory();else parent.hideHistory();">
				<img src="../common/images/close.gif" border=0></A>
				 -->
				</td>
			</tr>
		</table>
	</DIV>
	<div style="width:100%;height:100%; overflow:auto;">
		<TABLE BORDER=0 STYLE="font-size:9pt; width:100%;" cellspacing=0 cellpadding=0>
			<colgroup><col width="100%" align="left" style="line-height:18px;"></colgroup>
			<c:forEach var="history" items="${histories}">
			<TR>
				<td style="border-bottoms:1px solid #6699cc; ">
				&nbsp;[<fmt:formatDate value="${history.id.downDate}" pattern="yyyy-MM-dd HH:mm:ss" />] - <c:out value="${history.user.nName}" />/<c:out value="${history.user.department.dpName}" />]
				<br>&nbsp;<b><c:out value="${history.dmsFile.fileName}" /></b>
				</td>
			</TR>
<!-- 			<TR> -->
<!-- 				<TD background="../common/images/doc_dotline.gif" height=1></TD> -->
<!-- 			</TR> -->
			</c:forEach>
		</TABLE>
	</div>
</DIV>
</body>
</html>