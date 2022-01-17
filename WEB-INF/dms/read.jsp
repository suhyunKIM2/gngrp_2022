<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%--@ page errorPage="../error.jsp" --%>
<%@ page import="java.util.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="nek3.domain.dms.*" %>
<%@ page import="nek3.domain.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
	String cssPath = "../common/css";
	String imgCssPath = "/common/css/blue";
	String imagePath = "../common/images/blue";
	String scriptPath = "../common/script";
	String[] viewType = {"0"};
	Dms dms = (Dms)request.getAttribute("dms");
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=Edge" />
<title><spring:message code="t.doc.management" text="문서관리"/></title>

<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.common.jsp"%>
<%@ include file="../common/include.script.map.jsp" %>

<link rel="STYLESHEET" type="text/css" href="/common/active-x/tagfree/tagfree_approval.css">

<script language=javascript>
	var targetWin;
	function goSubmit(cmd, docId, hisNo)
	{
		var frm = document.getElementById("search");
		switch(cmd)
		{
			case "edit":
				frm.method = "GET";
				frm.action = "./form.htm";
				break;
			case "delete":
				if(!confirm("<spring:message code='c.delete' text='삭제 하시겠습니까?' />")) return;
			    frm.method = "POST";
				frm.command.value = "deletepost";
				frm.action = "./delete.htm";
				break;
			case "transfer":
				var url = "../common/department_selector.jsp?title=" + encodeURI("<spring:message code='t.doc.management' text='문서관리'/> <spring:message code='t.doc.handed.over' text='문서인계'/>")
							+ "&openmode=1&isadmin=0&onlyuser=1";
				var rValue = window.showModalDialog(url,"", "dialogHeight: 420px; dialogWidth: 360px; edge: Raised; center: Yes; help: No; resizable: No; status: No; Scroll: no");	
				if (rValue !=null)
				{
					var receiver = rValue.split(":");
					var transferMsg = receiver[0] + "/" + receiver[2] + "/" + receiver[3] + " <spring:message code='c.ownership.document' text='에게 문서 소유권을 이전 하시겠습니까?'/>";
					if (!confirm(transferMsg)) return;
					frm.receiverid.value = receiver[1];
					frm.method = "POST";
					frm.command.value = "transpost";
					frm.action = "./dms_transfer.jsp";
				}
				else return;
				break;
			case "view":
				var url  = "./history_read.htm?docId=" + docId + "&hisNo=" + hisNo;
				OpenWindow(url, "<spring:message code='t.doc.management' text='문서관리'/>", "800", "410");
				
// 				parent.dhtmlwindow.open(
// 					url, "iframe", url, "문서관리", 
// 					"width=800px,height=410px,resize=1,scrolling=1,center=1", "recal"
// 				);
				return;
				break;
			case "close":
			/*
				if(confirm("현재 문서를 닫으시겠습니까?\n\n문서 편집중에 닫는 경우 저장이 안됩니다.")){
					window.close();
				}
			*/
				window.close();
				return;
				break;

		}
		frm.submit();
	}

	var popupHistory;
	var x,y;
	function ViewHistory(historyType ) {
		var url = "";
		x = 17;
		y = 80;
		switch(historyType)
		{
			case "read":
				x = 90;
				url = "./read_history.htm?docId=<c:out value="${dms.docId}" />";
				break;
			case "down":
				x = 163;
				url = "./down_history.htm?docId=<c:out value="${dms.docId}" />";
				break;
			default :
				return;
				break;
		}

		ajaxRequest("GET", "", url, viewHistoryCompleted);
	}

	function hideHistory()
	{
		if (popupHistory.isOpen) popupHistory.hide()
	}

	function viewHistoryCompleted(data, textStatus, jqXHR) {
		wid = 500 ;
		hei = 194;

		ModalDialog({'t':'History', 'w':480, 'h':250, 'm':'html', 'c':data, 'modal':false, 'd':true, 'r':true });
	}
</script>

<script type="text/javascript">
//var validator = null;
$(document).ready(function(){
// 	$( "#header-1" ).click( function(){
// 		$("#header-info").toggle();
// 	});

// 	setTimeout( '$("#header-info").hide()', 3000 );
	ShowUserInfoSet();
	
	ViewHistorySet();
	
	pageScroll();
	
	setTimeout( "popupAutoResize2();", "500");		//팝업창 resize
});
</script>

</head>

<body>
<div id="pageScroll" class="wrapper">
<form:form commandName="search">
<input type="hidden" name="command">
<form:hidden path="docId" />
<form:hidden path="cateType" />
</form:form>

<center>
<table class="doc-width" cellspacing=0 cellpadding=0 border=0>
<tr>
<td align="center">

<!--  Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/title_doc.gif); height:33px; border: 1px solid #CCC;;">
<tr height="26">
<td width="300" align=left style="padding-left:10px; ">
	<img src="../common/images/icons/doc-img-white.png" border="0" align="absmiddle"> 
	<span class="ltitle"><spring:message code="t.doc.management" text="문서관리"/> </span>
</td>
<td width="*" align="right" style="padding-right:10px;">
<c:if test="${dms.catId != '20140409161336'}">
<!-- 	<img src="../common/images/pp.gif" border="0" align="absmiddle"> -->
<%-- 	<a Href="javascript:ShowUserInfo('${dms.ouUser.userId }')" class="maninfo"> --%>
<%-- 	<c:out value="${dms.ouUser.nName }"/> / <c:out value="${dms.ouUser.department.dpName }"/></a> ( <fmt:formatDate pattern="yyyy-MM-dd hh:mm:ss" value="${dms.createDate}" /> )&nbsp; --%>
		<img src="../common/images/pp.gif" border="0" align="absmiddle">
		<a href="#" rel='<c:out value="${dms.ouUser.userId }"/>' class="maninfo">
		<c:out value="${dms.ouUser.nName }"/> / <c:out value="${dms.ouUser.department.dpName }"/></a> ( <fmt:formatDate pattern="yyyy-MM-dd hh:mm:ss" value="${dms.createDate}" /> )
</c:if>
</td>
</tr>
</table>

<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr height="5">
<td></td>
</tr>
</table>

<!--  수행버튼  -->	
<table border="0" cellpadding="0" cellspacing="0" width="100%" name="btntbl">
	<tr>
		<td width="300" align="left">
			<c:if test="${dms.catId != '20140409161336'}">
			<!-- 문서 읽음 이력 -->
<%-- 			${dms.docId} --%>
			
<%-- 			<a href="javascript:ViewHistory('read');"><img src="../common/images/icons/icon_inquiry.jpg" border=0 align="absmiddle">&nbsp;<spring:message code="t.readHistory" text="조회이력"/></a>&nbsp; --%>
			<a class="history" href="#" rel="read^${search.docId}"><img src="../common/images/icons/icon_inquiry.jpg" border=0 align="absmiddle">&nbsp;<spring:message code="t.readHistory" text="조회이력"/></a>&nbsp;
			<!-- 문서읽음이력 끝 -->
			<!-- 첨부다운 이력 -->
<%-- 			<a href="javascript:ViewHistory('down');"><img src="../common/images/icons/icon_down.jpg" border=0 align="absmiddle">&nbsp;<spring:message code="t.fileDownHistory" text="파일다운이력"/></a> --%>
			<a class="history" href="#" rel="down^${search.docId}"><img src="../common/images/icons/icon_down.jpg" border=0 align="absmiddle">&nbsp;<spring:message code="t.fileDownHistory" text="파일다운이력"/></a>
			<!-- 첨부다운이력 끝 -->
			</c:if>
		</td>
<%-- 		<c:if test="${dms.chkOut}"> --%>
<!-- 		<td width="170"><font color="#FF0000"><b></b></font></td> -->
<%-- 		</c:if>	 --%>
		<td width="*" align="right">
			<!-- 편집권한은 조회가능한 모든 사용자 -->
			<c:if test="${!dms.chkOut||isAdmin||isOwner}">
			<a onclick="javascript:goSubmit('edit','${search.docId}', '');" class="button white medium">
			<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.modify" text="편집"/> </a>
<%-- 			</c:if> --%>
<%-- 			<c:if test="${canModify}"> --%>
			<c:if test="${isOwner||isAdmin }">
			<a onclick="javascript:goSubmit('delete','${search.docId}', '');" class="button white medium">
			<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.delete" text="삭제"/> </a>
			</c:if>
			<!-- 
			<a onclick="javascript:goSubmit('trnasfer','${search.docId}', '');" class="button white medium">
			<img src="../common/images/bb02.gif" border="0"> 인수인계 </a>
			 -->
			</c:if>
			
			
			<a onclick="javascript:docPrint('document');" class="button white medium">
			<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.print" text="인쇄"/> </a>
			<a onclick="javascript:closeDoc();" class="button white medium">
			<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.close" text="닫기"/> </a>
	
		</td>
	</tr>
</table>

<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr height="4">
<td></td>
</tr>
</table>
<!-- 수행버튼 끝 -->

<div id="header-1" style="text-align:left; cursor:pointer;" >
<img src="../common/images/information-italic.png" align="absmiddle" style="position:relative; top:-1px;"/>
<span style="font-weight:bold; font-size:12px;">Document Info</span> 

<c:if test="${dms.chkOut}">
<!-- 	<span style="margin-top:3px; float:left; "> -->
	- <img src="/common/images/lock.png" align="absmiddle" style="position:relative; top:-2px;"/>
	<span style="color:#FF0000; font-weight:bold;">Check Out</span>
<!-- 	</span> -->
</c:if>	
			
</div>
<div id="header-info" style="margin:0px; display:block;">

<div class="space"></div>
<div class="hr_line">&nbsp;</div>
<table width="100%" cellspacing=0 cellpadding=0 border=0>
	<colgroup>
		<col width="13%">
		<col width="37%">
		<col width="13%">
		<col width="*">
	</colgroup>
	<tr>
		<td class="td_le1"><spring:message code='addr.division' text='구분'/></td>
		<td class="td_le2">
			<c:choose>
				<c:when test="${dms.cateType == 'S' }">
				<spring:message code='dms.share' text='공용문서함'/>
				</c:when>
				<c:when test="${dms.cateType == 'P' }">
				<spring:message code='dms.person' text='개인문서함'/>
				</c:when>
				<c:when test="${dms.cateType == 'D' }">
				부서
				</c:when>
			</c:choose>
		</td>
		<td class="td_le1" NOWRAP><spring:message code='t.category' text='문서분류' /></td>
		<td class="td_le2"><c:out value="${catFullName }"/></td>
	</tr>

<!-- 	<tr> -->
<!-- 		<td class="td_le1" NOWRAP>보안등급</td> -->
<%-- 		<td class="td_le2"><c:out value="${dms.getSecurityLevel().getTitle() }"/></td> --%>
<!-- 	</tr> -->
<c:if test="${dms.cateType == 'S' }">
	<tr>
		<td class="td_le1" NOWRAP><fmt:message key="addr.share.div"/>&nbsp;<!-- 공유구분 --></td>
		<td class="td_le2">
			<c:choose>
				<c:when test="${dms.openFlag == '0' }">
				<fmt:message key="addr.share.specify"/><!-- 비공개-->
				</c:when>
				<c:when test="${dms.openFlag == '1' }">
				<fmt:message key="addr.share.entire"/><!-- 전체공개 -->
				</c:when>
			</c:choose>
		</td>
		<td class="td_le1" NOWRAP><spring:message code="t.preservePeriod" text="보존년한 "/></td>
		<td class="td_le2" colspan="3">
			<c:choose>
				<c:when test="${locale == 'ko' }">
					<c:out value="${dms.preservePeriod.titleKo }"/>
				</c:when>
				<c:when test="${locale == 'en' }">
					<c:out value="${dms.preservePeriod.titleEn }"/>
				</c:when>
				<c:when test="${locale == 'ja' }">
					<c:out value="${dms.preservePeriod.titleJa }"/>
				</c:when>
				<c:when test="${locale == 'zh' }">
					<c:out value="${dms.preservePeriod.titleZh }"/>
				</c:when>
				<c:otherwise>
					<c:out value="${dms.preservePeriod.title }"/>
				</c:otherwise>
			</c:choose>
		</td>
	</tr>
	<c:if test="${dms.openFlag != '1' }">
	<tr>
		<td class="td_le1" NOWRAP><fmt:message key="addr.share.specify"/>&nbsp;<!-- 공유자 --></td>
		<td class="td_le2" colspan="3">
		
		<c:if test="${dmsShareList != null }">
			<div style="width:100%;overflow:auto;;border:0px;">
			<c:forEach var="shareItem" items="${dmsShareList }" varStatus="status">
				<c:if test="${status.count > 1 }">,</c:if>
				<c:out value="${shareItem.shareName }" />
				<c:if test="${fn:contains(shareItem.shareType, 'D') }">
					<c:choose>
						<c:when test="${shareItem.childDept}">
							<c:out value="[+]" />
						</c:when>
						<c:otherwise>
							<c:out value="[-]" />
						</c:otherwise>
					</c:choose>
				</c:if>
			</c:forEach>
			</div>
		</c:if>
		</td>
	</tr>
	</c:if>
</c:if>
</table>
</div>

<div class="space"></div>
<div class="hr_line">&nbsp;</div>
<table width="100%" cellspacing=0 cellpadding=0 border=0>
	<colgroup>
		<col width="13%">
		<col width="*">
	</colgroup>
	<tr>
		<td class="td_le1" NOWRAP>
			<spring:message code="t.subject" text="제목"/>
		<td class="td_le2">
			<c:if test="${dms.hotFlag }">
				<span class='ui-corner-all grid-btn-blue'><spring:message code="appr.imp.a" text="중요"/></span>
			</c:if>
			${dms.subject }
			<c:if test="${dms.revisionNo > 0 }">
				<font color="blue"><B>(Rev.<c:out value="${dms.revisionNo }"/>)</B></font>
			</c:if>
		</td>
	</tr>
	<tr>
		<td class="td_le1" NOWRAP><spring:message code="t.searchValue" text="검색어 "/></td>
		<td class="td_le2">${dms.keywords }</td>
	</tr>
	<tr>
		<td class="td_le2" valign="top" style="min-height: 85px;" colspan="2"> 
		<div style="padding: 6px 0px; margin: 0; overflow: auto;">${dms.subContent }</div>
<%-- <pre style="line-height: 17px; padding: 0; margin: 0; word-wrap: break-word; white-space: pre-wrap; white-space: -moz-pre-wrap; white-space: -pre-wrap; white-space: -o-pre-wrap; word-break: break-all;">${dms.subContent }</pre> --%>
		</td>
	</tr>
</table>
<table class=tblspace09><tr><td></td></tr></table>
<c:if test="${dms.moduleId == 'APPR'}">
	<!--본문 시작 -->
	<table width="100%" height="80" border="0" cellspacing="1" cellpadding="0" bgcolor="90B9CB">
		<tr>
			<td class=content bgcolor=ffffff valign=top style="height:80px;">${dms.content }</td>
		</tr>
	</table>
<!-- 본문 끝 -->
</c:if>

<table id=btntbl><tr><td class=tblspace09></td></tr></table>
<%
	StringBuffer fileAttachInfo = new StringBuffer();
	StringBuffer fileAttachURL = new StringBuffer();
	String baseURL = "http://" + request.getServerName() + "/dms/download.htm?docId=" + dms.getDocId() + "&fileNo=";
	if(request.getServerName().indexOf("localhost") != -1){//로컬인지 서버인지 확인
		baseURL = request.getScheme() + "://" + request.getServerName()+":"+request.getServerPort() + "/dms/download.htm?docId=" + dms.getDocId() + "&fileNo="; //로컬 시 적용  (https 적용)
	}else{
		baseURL = request.getScheme() + "://" + request.getServerName() + "/dms/download.htm?docId=" + dms.getDocId() + "&fileNo="; //개발, 운영 시 적용 (https 적용)
	}
	
// 	String baseURL = "/dms/download.htm?docId=" + dms.getDocId() + "&fileNo=";
	List<DmsFile> files = dms.getDmsFile();
	for(int i=0; i< files.size(); i++){
		DmsFile file = files.get(i);
		//URL|파일명|크기|...
		fileAttachInfo.append(file.getId().getFileNo() + "|");
		fileAttachInfo.append(file.getFileName() + "|");
		fileAttachInfo.append(file.getFileSize() + "|");
		
	} 
	fileAttachURL.append("/common/attachdown_control.jsp?")
	.append("attachfiles=").append(java.net.URLEncoder.encode(fileAttachInfo.toString(),"utf-8"))
	.append("&baseurl=").append(java.net.URLEncoder.encode(baseURL,"utf-8"));
%>
<input type="hidden" name="attachobj" value="<%=fileAttachInfo.toString() %>">
<!-- 조회시 파일 첨부 컨트롤 삽입 -->
<%
	if (files.size() > 0)
	{
%>

<table width="100%" cellspacing=0 cellpadding=0 border="0">
	<colgroup>
		<col width="13%">
		<col width="*">
	</colgroup>
	<tr>
		<td class="td_le1"><spring:message code="t.attached"/><!-- 첨부--></td>
		<td class="td_le2">	
			<jsp:include page="<%=fileAttachURL.toString()%>" flush="true" />
		</td>
	</tr>
</table>
<table><tr><td class="tblspace03"></td></tr></table>
<%
	}
%>

<!-- 문서 이력관리 -->
<c:if test="${fn:length(histories)>0 }">
<table border="0" cellpadding="0" cellspacing="0" width="100%"><tr height="4"><td></td></tr></table>

<table border="0" cellpadding="0" cellspacing="0" width="100%">
	<tr>
	<td align="left"><img src="../common/images/bul_ch3.gif" border="0" align="absmiddle"> <b>Document History</b></td>
	</tr>
</table>
<table id=btntbl><tr><td class="tblspace05"></td></tr></table>

	<table width=100% cellspacing=0 cellpadding=0 border=0 style="border-bottom:1px solid #A1B5FE;table-layout:fixed;">
<%-- 		<colgroup> --%>
<%-- 			<col width="10%" style="width:20px"> --%>
<%-- 			<col width="15%" style="width:50px"> --%>
<%-- 			<col width="*"> --%>
<%-- 			<col width="20%"> --%>
<%-- 			<col width="20%"> --%>
<%-- 		</colgroup> --%>
		<tr height=26>
			<td class="td_le1" style="width:40px;"><b><spring:message code="mail.mailbox.order" text="순번"/></b></td>
			<td class="td_le1" style="width:65px;"><b><spring:message code="t.category" text="구분"/></b></td>
			<td class="td_le1" style="width:265px;"><b><spring:message code="t.subject" text="제목"/></b></td>
			<td class="td_le1" style="width:120px;"><b><spring:message code="dms.historydate" text="수정일시"/></b></td>
			<td class="td_le1" style="width:90px;"><b><spring:message code="dms.historyuser" text="수정자"/></b></td>
		</tr>
		<c:forEach var="history" items="${histories}">
		<TR>
			<td class="td_le2" style="text-align:center"><b><c:out value="${history.id.hisNo -1}" /></b></td>
			<td class="td_le2" style="text-align:center">
				<a onclick="goSubmit('view','${search.docId}', '${history.id.hisNo }');" class="button white medium">
				<c:choose>
					<c:when test="${history.hisType == 'U' }"><spring:message code="dms.historyedit" text="수정이력"/></c:when>
					<c:otherwise><spring:message code="dms.historydelete" text="삭제이력"/></c:otherwise>
				</c:choose>
				</a>
			</td>
			<td class="td_le2">
				<a onclick="goSubmit('view','${search.docId}', '${history.id.hisNo }');" style="cursor:pointer; font-weight:bold;">
					<c:out value="${history.subject}" />
				</a>
			</td>
			<td class="td_le2" style="text-align:center"><fmt:formatDate value="${history.hisDate}" pattern="yyyy-MM-dd HH:mm:ss" /></td>
			<td class="td_le2" style="text-align:center">
				<c:if test="${dms.catId != '20140409161336'}">
				<c:out value="${history.owUser.nName}" />/<c:out value="${history.owUser.department.dpName}" />
				</c:if>
			</td>
		</TR>
		</c:forEach>
	</table>
</c:if>

</td>
</tr>
</table>
</center>
</div>
</body>
</html>