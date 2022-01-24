<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ page import="nek3.domain.approval.*" %>
<%!
    //각 경로 패스
    String sImagePath =  ApprDocCode.APPR_IMAGE_PATH  ; 
    String sJsScriptPath =  ApprDocCode.APPR_JAVASCRIPT_PATH ;  
    String sCssPath =  ApprDocCode.APPR_CSS_PATH ; 
%>
<%
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<TITLE>외부문서 등록</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="<%= sCssPath %>/popup.css" type="text/css">
<link rel="stylesheet" href="<%= sCssPath %>/style.css" type="text/css">
<script src="<%= sJsScriptPath %>/common.js"></script>

<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.script.map.jsp"%>
<SCRIPT LANGUAGE="JavaScript">
<!--
window.name = "MPOP";

function goOK(){
	var f = document.getElementById("apprWebForm");
	f.action = "./docnumform_save.htm";
	f.method = "post";
	f.submit();
}
function goX() 
{
	window.close();
}

function goFocus() {
	if(event.keyCode == 13) { 
		var f = document.getElementById("apprWebForm");
		f.apprnote.focus();
		return false;
	};
}
//-->
</SCRIPT>

<script>
$(document).ready(function () {
//김정국 추가 - 모바일 인 경우 viewport 및 jquery mobile 관련 js, css 로드. 제일 하단에 ui-body-c css 있음.
if (navigator.userAgent.match(/iPad/) == null && navigator.userAgent.match(/Mobile|Windows CE|Windows Phone|Opera Mini|POLARIS/) != null){
	var head = document.getElementsByTagName("head")[0];
	
	var s = document.createElement("meta");
	s.name = "viewport";
	s.content = "width=device-width, user-scalable=no";
	head.appendChild(s);
	s = null;
}
});
</script>
</head>
<body style="margin:0px; padding:0px; ">
<form:form enctype="multipart/form-data" commandName="apprWebForm">
<form:hidden path="search.cmd" value="save" />
<form:hidden path="search.menu" />
<input type="hidden" name="revalue" value="">
<table width="100%" cellspacing="0" cellpadding="0" border="0">
	<tr>
		<td width="30"><img src="<%= sImagePath %>/popup_title.gif"></td>
		<td width="*" height="40" class=title background="../common/images/popup_bg.gif">&nbsp;<font style="font-size:10pt;" color="white">
				<spring:message code='appr.approval.edocno' text='외부문서 등록' />
			</font></td>
	</tr>
	<tr><td colSpan=2></td></tr>
</table>
<table><tr><td class="tblspace03"></td></tr></table>
<table width="100%" cellspacing="0" cellpadding="0" border="0">	
	<tr>
		<td width="5">&nbsp;</td>
		<td width="*" valign="top">
			<table width="100%" cellspacing="0" cellpadding="0" border="0" style="border-collapse:collapse">
				<tr>
					<td class="td_le1"><spring:message code='t.subject' text='제목' /></td>
					<td class="td_le2">
                      <input type="text" name="subject" value="" style=width:95%; onKeyPress="goFocus();">
                    </td>
				</tr>
				<tr name="att">
					<td class="td_le1" rowspan=3><spring:message code='t.attach.external.documents' text='외부문서첨부' /></td>
					<td class="td_le2">
                        <input type="file" name="apprfile" value="">
                    </td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<table><tr><td class="tblspace05"></td></tr></table>
<!---수행버튼 --->
<div style="width:100%; height:40px; background-color:#e7e7e7; position:absolute; top:expression(document.body.clientHeight-30); left:0px;">
<table width="100%" cellspacing="0" cellpadding="0" border="0">
	<tr height=40>
		<td align=center>
		<span id="AP">
			<a onclick="javascript:goOK();" class="button white medium">
			<img src="../common/images/bb02.gif" border="0"> <spring:message code='t.insert' text='등록' /> </a>&nbsp;
		</span>
			<a onclick="javascript:self.close();" class="button white medium">
			<img src="../common/images/bb02.gif" border="0"> <spring:message code='t.cancel' text='취소' /> </a>
        </td>
	</tr>
</table>
</div>
<script>
//window.resizeTo(500, 200 );
</script>
<!-- 보기 수행버튼 끝 -->
</form:form>
</body>
</html>