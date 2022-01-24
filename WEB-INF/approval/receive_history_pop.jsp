<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="nek.common.util.Convert" %>
<%@ page import="nek3.domain.*" %>
<%@ page import="nek3.domain.approval.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%!
    //각 경로 패스
    String sImagePath =  ApprDocCode.APPR_IMAGE_PATH  ;
    String sJsScriptPath =  ApprDocCode.APPR_JAVASCRIPT_PATH ;
    String sCssPath =  ApprDocCode.APPR_CSS_PATH ;

    SimpleDateFormat dspformatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
%>
<%
    ArrayList arrlist = (ArrayList)request.getAttribute("arrlist");
    String finishdate = "";
%>
<!DOCTYPE html>
<html>
<head>
<title>수신문서 열람 이력</title>
<%@ include file="../common/include.mata.jsp" %>
<link rel="stylesheet" type="text/css" href="<%= sCssPath %>/popup.css">
<%@ include file="../common/include.common.jsp" %>
</head>

<body>
<table width="100%" cellspacing="0" cellpadding="0" border="0">
	<tr height="40">
		<td background="<%=sImagePath %>/popup_bg.gif" width="30"><img src="<%= sImagePath %>/popup_title.gif"></td>
		<td background="<%=sImagePath %>/popup_bg.gif" width="*" class="title" style="padding-left: 10px;">
			<spring:message code="t.receiveHistory" text="수신이력" />
		</td>
	</tr>
	<tr><td height="7" colSpan="2"></td></tr>
</table>

<div style="height:350px;width:100%;overflow-y:scroll;border:0px;">
<table width="100%" border="0" cellspacing="0" cellpadding="0" style="border-collapse:collapse;table-layout:fixed;">
	<tr>
        <td class="td1" width="20%"><spring:message code="t.dpName" text="부서" /></td>
        <td class="td1" width="15%"><spring:message code="t.upName" text="직급" /></td>
        <td class="td1" width="15%"><spring:message code="mail.recipient" text="수신인" /></td>
        <td class="td1" width="25%"><spring:message code="t.date.view.first" text="최초조회일자" /></td>
        <td class="td1" width="25%"><spring:message code="t.date.view.last" text="마지막조회일자" /></td>
	</tr>
</table>

<table  width="100%" border="0" cellspacing="0" cellpadding="0" style="border-collapse:collapse;table-layout:fixed;">
<%
	int iSize = arrlist.size(); 
	if (iSize > 0) {
		ApprReceiveHistory historyInfo = null;
    	for(int i = 0; i < iSize; i++) {
	        historyInfo = (ApprReceiveHistory)arrlist.get(i);
	        String readDate = "";
	        String lastDate = "";
	        if (!dspformatter.format(historyInfo.getReceiveReadingDate()).equals(dspformatter.format(Convert.getDefaultDateTime()))) {
	        	readDate = dspformatter.format(historyInfo.getReceiveReadingDate());
	        }
	        if (!dspformatter.format(historyInfo.getReceiveLastDate()).equals(dspformatter.format(Convert.getDefaultDateTime()))) {
	        	lastDate = dspformatter.format(historyInfo.getReceiveLastDate());
	        }
%>
	<tr>
        <td class="td2" width="20%" nowrap><%=historyInfo.getReceiveDeptNm() %></td>
        <td class="td2" width="15%" nowrap><%=historyInfo.getReceivePositionNm() %></td>
        <td class="td2" width="15%" nowrap><%=historyInfo.getReceiveName() %></td>
        <td class="td2" width="25%" nowrap><%=readDate %></td>
        <td class="td2" width="25%" nowrap><%=lastDate %></td>
	</tr>
<%
    	}
	}
%>
</table>
</div>
<!---수행버튼 --->
<table width="100%" cellspacing="0" cellpadding="0" border="0">
	<tr height="7" ><td></td></tr>
	<tr height="25" bgcolor="#E7E7E7" align="center">
		<td>          
          <a href="javascript:close();"><img src="<%= sImagePath %>/btn_close.gif" border="0" align="absmiddle" ></a>
        </td>
	</tr>
</table>
<!-- 보기 수행버튼 끝 -->
</body>
</html>
