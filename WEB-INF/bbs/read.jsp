<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="nek3.domain.bbs.*" %>
<%@ page import="java.util.*" %>
<%@ page import="nek3.common.*" %>
<%@ page import="nek.common.util.Convert"%>
<%
	String cssPath = "../common/css";
	String imgCssPath = "/common/css/blue";
	String imagePath = "../common/images/blue";
	String scriptPath = "../common/script";
%>

<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=Edge" />
<title><c:if test="${workType == '1' }"><c:out value="${bbsMaster.title }" />&nbsp;</c:if> <c:out value="${bbsWebForm.bbs.subject }" /></title>

<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.common.jsp"%>
<%@ include file="../common/include.script.map.jsp" %>

<!-- <style> -->
<!-- @page a4sheet { size: 21.0cm 29.7cm } -->
<!-- .a4{ page: a4sheet; page-break-after: always } -->
<!-- </style> -->

<script type="text/javascript">
	var popupWinCnt = 0;	
	function goSubmit(cmd, isNewWin ,docId)
	{
		var frm = document.getElementById("search");
		frm.method = "GET";
		switch(cmd){
			case "view":
				frm.docId.value = docId;
				frm.action = "read.htm";
				break;
			case "edit":
				frm.action = "form.htm";
				frm.pDocId.value = "";
				break;
			case "delete":
				if(!confirm("<spring:message code='c.delete' text='삭제 하시겠습니까?' />")) return;
				frm.action = "delete.htm";
				break;
			<c:if test="${bbsMaster.reply}">
			case "response":
				frm.action = "form.htm";
				frm.pDocId.value = frm.docId.value;
				frm.docId.value = "";
				break;
			</c:if>
			default:
				return;
				break;
		}
		<c:choose>
			<c:when test="${search.useLayerPopup}">
				frm.useNewWin.value = false;
				frm.useLayerPopup.value = true;
			</c:when>
			<c:otherwise>
				if(window.opener != null) frm.useNewWin.value = true;
				else frm.useNewWin.value = false;
			</c:otherwise>
		</c:choose>
		frm.submit();
	}

	var popupHistory,x,y;
	function ViewHistory(historyType ) {
		var url = "";
		x = 17;
		y = 80;
		switch(historyType)
		{
			case "edit":
				url = "./edit_history.htm?bbsId=<c:out value="${bbsMaster.bbsId}" />&docId=<c:out value="${bbs.docId}" />";
				break;
			case "read":
				x = 90;
				url = "./read_history.htm?bbsId=<c:out value="${bbsMaster.bbsId}" />&docId=<c:out value="${bbs.docId}" />";
				break;
			case "down":
				x = 163;
				url = "./down_history.htm?bbsId=<c:out value="${bbsMaster.bbsId}" />&docId=<c:out value="${bbs.docId}" />";
				break;
			default :
				return;
				break;
		}
		ajaxRequest("GET", "", url, viewHistoryCompleted);
	}

	function hideHistory(){
		if (window.createPopup){
			popupHistory.hide()
		} else popupHistory.close();
	}

	function viewHistoryCompleted(data, textStatus, jqXHR) {
		wid = 500 ;
		hei = 194;
		
		ModalDialog({'t':'History', 'w':480, 'h':250, 'm':'html', 'c':data, 'modal':false, 'd':true, 'r':true });
		/*
		if(window.createPopup){
			popupHistory = window.createPopup();
			popupHistory.document.body.innerHTML = data ;
			popupHistory.show(x, y, wid, hei , document.body);
		} else {
			var features = "height=" + hei + ",width=" + wid + ",left=" + x + ",top=" + y + 
				",titlebar=no,menubar=no,scrollbars=no,status=no,location=no"
			popupHistory = window.open("about:blank", "popupHistory", features);
			popupHistory.document.body.innerHTML = data;
		}
		*/
	}
	

	function ShowUserInfoSetss() {
	     // Make sure to only match links to wikipedia with a rel tag
	     var strUrl = "/common/userinfo.htm?userId=" ;

	   	$('.maninfo').each(function()
	    {
	   		// We make use of the .each() loop to gain access to each element via the "this" keyword...
	   		$(this).qtip(
	   		{
	   			content: {
	   				// Set the text to an image HTML string with the correct src URL to the loading image you want to use
	   				//text: '<img class="throbber" src="/projects/qtip/images/throbber.gif" alt="Loading..." />',
	   				text: 'loading...',
	   				ajax: {
	   					//url: $(this).attr('rel') // Use the rel attribute of each element for the url to load
	   					//url: strUrl // Use the rel attribute of each element for the url to load
	   					url: strUrl + $(this).attr('rel') // Use the rel attribute of each element for the url to load
	   				},
	   				title: {
	   					text: 'Man Information - ' + $(this).text(), // Give the tooltip a title using each elements text
	   					//text: 'Man Infomation', // Give the tooltip a title using each elements text
	   					button: true
	   				}
	   			},
	   			position: {
	   				at: 'left center', // Position the tooltip above the link
	   				my: 'right center',
	   				viewport: $(window), // Keep the tooltip on-screen at all times
	   				effect: false // Disable positioning animation
	   			},
	   			show: { 
	   				event: 'click',
	   				solo: true // Only show one tooltip at a time
	   			},
	   			hide: 'unfocus',
	   			style: {
	   				//classes: 'qtip-wiki qtip-light qtip-shadow'
	   				classes: 'ui-tooltip-bootstrap ui-tooltip-shadow ui-tooltip-rounded',
					width:350
	   			}
	   		})
	   	})
    
	   	// Make sure it doesn't follow the link when we click it
		.click(function(event) { event.preventDefault(); });
	}
</script>

<script type="text/javascript">
	function TextCount(obj){
		var strsubject = obj.value;
		strlength = 0;
		document.getElementById("tmptext").innerHTML = strsubject.length;
		for (cntchar = 0; cntchar < strsubject.length; cntchar++) {
			if (strsubject.charCodeAt(cntchar) > 255){
				strlength += 2;
			}else{
				strlength++;
			}
			if (strlength >= 1000){
				alert("<spring:message code='c.msg.maximum' text='입력 문자는 최대 1000byte이므로 더이상 입력 할 수 없습니다.' />");
				obj.value = obj.value.substring(0, cntchar);
				break;
			}
		}
	}

	function goCommentSubmit(cmd, comNo){
		var frm = document.getElementById("bbsCommentWebForm");
		frm.elements["search.useAjaxCall"].value = true;
		switch(cmd){
			<c:if test="${bbsMaster.reply}">
			case "edit" :
			    $.ajax({
			        type: 'post'
				    ,dataType: 'text'
			        ,async: true
			        ,url: './save_comment.htm'
			        ,data: $("#bbsCommentWebForm").serialize()
			        ,beforeSend: function() {
			        	$('#ajaxIndicator').show(); 
			        } 
			        ,complete: function(){ 
			        	$('#ajaxIndicator').hide();
			        }
			        ,success: function(data, status, xhr) {
			        	goCommentSubmit("list_comment","");
			        }
			        ,error: function(xhr, status, error) {
				        $("#commentArea").html(status + ":" + error);
			        }
			    });
				break;
			case "save" :
				frm.elements["bbsComment.id.comNo"].value = "-1";
			    $.ajax({
			        type: 'post'
				    ,dataType: 'text'
			        ,async: true
			        ,url: './save_comment.htm'
			        ,data: $("#bbsCommentWebForm").serialize()
			        ,beforeSend: function() {
			        	$('#ajaxIndicator').show(); 
			        } 
			        ,complete: function(){ 
			        	$('#ajaxIndicator').hide();
			        }
			        ,success: function(data, status, xhr) {
			        	goCommentSubmit("list_comment","");
			        }
			        ,error: function(xhr, status, error) {
				        $("#commentArea").html(status + ":" + error);
			        }
			    });
				break;
			</c:if>
			case "delete":
				if(TrimAll(comNo) == "") return;
				frm.elements["bbsComment.id.comNo"].value = comNo;
				if (!confirm("<spring:message code='c.comments.delete' text='의견을 삭제 하시겠습니까?' />")) return;
			    $.ajax({
			        type: 'post'
			        ,async: true
			        ,url: './delete_comment.htm'
			        ,data: $("#bbsCommentWebForm").serialize()
			        ,beforeSend: function() {
			        	$('#ajaxIndicator').show().fadeIn('fast'); 
			        } 
			        ,complete: function() { 
			        	$('#ajaxIndicator').fadeOut();
			        }
			        ,success: function(data) {
			        	goCommentSubmit("list_comment","");
			        }
			        ,error: function(data, status, err) {
				        $("#commentArea").html(status + ":" + err);
			        }
			    });
			  	break;
			case "list_comment":
			    $.ajax({
			        type: 'post'
				    ,dataType: 'text'
			        ,async: true
			        ,url: './list_comment.htm'
			        ,data: $("#bbsCommentWebForm").serialize()
			        ,beforeSend: function() {
			        	$('#ajaxIndicator').show(); 
			        } 
			        ,complete: function(){ 
			        	$('#ajaxIndicator').hide();
			        }
			        ,success: function(data, status, xhr) {
			        	$("#commentArea").html(data);
			        }
			        ,error: function(xhr, status, error) {
				        $("#commentArea").html(status + ":" + error);
			        }
			    });
				break;
			default:
				return;
				break;
		}
	}
	
	function getCommentText(comNo){
		var frm = document.getElementById("bbsCommentWebForm");
		var id="#" + frm.elements["bbsComment.id.docId"].value + "_" + comNo;
		var comment = $(id).html();
		frm.elements["bbsComment.comments"].value = comment;
		frm.elements["bbsComment.id.comNo"].value = comNo;
		//$("#editButton").show();
		
		var saveObj = $("#commentSave");
		var editObj = $("#commentEdit");
		
		if ( saveObj ) saveObj.attr("style", "display:none");
		if ( editObj ) editObj.attr("style", "");
		
	}
	
	// 인쇄 시 수행버튼 숨김 처리 - 김정국 - chrome, ff에서 오류
	/*
	function window.onbeforeprint()
	{
		var btntbl = document.getElementsByName("btntbl");
		for( var i=0; i < btntbl.length; i++) {
			btntbl[i].style.display = "none";
		}
	}

	function window.onafterprint() {
		var btntbl = document.getElementsByName("btntbl");
		for( var i=0; i < btntbl.length; i++) {
			btntbl[i].style.display = "";
		}
	}
	*/
</script>

<script type="text/javascript">
$(document).ready(function(){
	if (navigator.userAgent.match(/iPad/) == null && navigator.userAgent.match(/Mobile|Windows CE|Windows Phone|Opera Mini|POLARIS/) != null){
		var head = document.getElementsByTagName("head")[0];
		var s = document.createElement("meta");
		s.name = "viewport";
		s.content = "width=device-width, minimum-scale=0.4, maximum-scale=1, initial-scale=0.4, user-scalable=yes";
		head.appendChild(s);
		s = null;
/*
		s = document.createElement("link");
		s.rel = "stylesheet";
		s.href = "/common/jquery/mobile/1.0/jquery.mobile-1.0.min.css";
		head.appendChild(s);
		s = null;

		s = document.createElement("script");
		s.type = "text/javascript";
		s.src = "/common/jquery/mobile/1.0/jquery.mobile-1.0.min.js";
		head.appendChild(s);
		s = null;
*/
	}
	
	ShowUserInfoSet();
	ViewHistorySet();
	
	pageScroll();	// page Scroll을 위해 사용. 2013-08-31
	
	setTimeout( "popupAutoResize2();", "500");		//팝업창 resize
});

</script>
</head>

<body style="margin:1px;">
<div id="pageScroll" class="wrapper">
<form:form commandName="search">
	<form:hidden path="searchKey" />
	<form:hidden path="searchValue" />
	
	<form:hidden path="pageNo" />
	<form:hidden path="bbsId"/>
	<form:hidden path="docId" />
	<form:hidden path="pDocId" />
	
	<form:hidden path="useNewWin" />
	<form:hidden path="useAjaxCall" />
	<form:hidden path="useLayerPopup" />
	
	<form:hidden path="workType" />
	<form:hidden path="moduleId" />
</form:form>

<table class="doc-width" cellspacing=0 cellpadding=0 border=0>
<tr>
<td>

<!--  Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/title_doc.gif); height:33px; border: 1px solid #CCC;;">
<tr height="26">
<td width="300" align=left style="padding-left:5px; ">
	<img src="/common/images/icons/doc-img-white.png" border="0" align="absmiddle">
	<span class="ltitle">
		<c:choose>
			<c:when test="${locale == 'ko' }">
				<c:out value="${bbsMaster.titleKo}" />
			</c:when>
			<c:when test="${locale == 'en' }">
				<c:out value="${bbsMaster.titleEn}" />
			</c:when>
			<c:when test="${locale == 'ja' }">
				<c:out value="${bbsMaster.titleJa}" />
			</c:when>
			<c:when test="${locale == 'zh' }">
				<c:out value="${bbsMaster.titleZh}" />
			</c:when>
			<c:otherwise>
				<c:out value="${bbsMaster.title}" />
			</c:otherwise>
		</c:choose>
	</span>
</td>
<td width="*" align="right" style="padding-right:10px;">
<!-- 	<img src="../common/images/pp.gif" border="0" align="absmiddle"> -->
<%-- 	<a href="javascript:ShowUserInfo('<c:out value="${bbs.writer.userId }"/>');" class="maninfo"> --%>
<%-- 	<c:out value="${bbs.writer.nName }"/> / <c:out value="${bbs.writer.department.dpName }"/></a> ( <fmt:formatDate value="${bbs.createDate}" pattern="yyyy-MM-dd HH:mm:ss" /> ) --%>
	<img src="../common/images/pp.gif" border="0" align="absmiddle">
	<a href="#" rel='<c:out value="${bbs.writer.userId }"/>' class="maninfo">
	<c:out value="${bbs.writer.nName }"/> / <c:out value="${bbs.writer.department.dpName }"/></a> ( <fmt:formatDate value="${bbs.createDate}" pattern="yyyy-MM-dd HH:mm:ss" /> )
</td>
</tr>
</table>

<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr height="5">
<td></td>
</tr>
</table>

<!--  수행버튼  -->	
<table border="0" cellpadding="0" cellspacing="0" width="100%" name="btntbl" id=btntbl>
	<tr>

	<td width="350" align="left" style="padding:0px;">
		<!-- 문서 편집 이력 -->
		<c:if test="${bbsMaster.logHistory}" >
			<a href="#" rel="edit^${search.docId}^${bbsMaster.bbsId}" class="history"><img src="../common/images/icons/icon_modify.jpg" border=0 align="absmiddle">&nbsp;<spring:message code="t.editHistory" text="수정이력"/></a>&nbsp;
		</c:if>
		
		<!-- 문서 읽음 이력 -->
		<c:if test="${bbsMaster.logRead}" >
			<a href="#" rel="read^${search.docId}^${bbsMaster.bbsId}" class="history"><img src="../common/images/icons/icon_inquiry.jpg" border=0 align="absmiddle">&nbsp;<spring:message code="t.readHistory" text="조회이력"/></a>&nbsp;
		</c:if>

		<!-- 첨부다운 이력 -->
		<c:if test="${bbsMaster.logDown}" >
			<a href="#" rel="down^${search.docId}^${bbsMaster.bbsId}" class="history"><img src="../common/images/icons/icon_down.jpg" border=0 align="absmiddle">&nbsp;<spring:message code="t.fileDownHistory" text="파일다운이력"/></a>
		</c:if>
	</td>

	<td width="*" align="right" style="padding:0px;">
		<c:if test="${canModify || isBbsAdmin}" >
		<a onclick="javascript:goSubmit('edit','','${search.docId}');" class="button white medium">
		<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.modify" text="편집"/> </a>
		<a onclick="javascript:goSubmit('delete','','${search.docId}');" class="button white medium">
		<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.delete" text="삭제"/> </a>
		</c:if>

		<c:if test="${bbsMaster.reply and canCreate}">
		<a onclick="javascript:goSubmit('response','','');" class="button white medium">
		<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.reply" text="응답"/> </a>
		</c:if>
					
		<a onclick="javascript:docPrint('document');" class="button white medium">
		<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.print" text="인쇄"/> </a>

		<a onclick="javascript:closeDoc();" class="button white medium">
		<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.close" text="닫기"/> </a>
	</td>
	</tr>
</table>
<!--  수행버튼  -->

<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr height="4">
<td></td>
</tr>
</table>

<div class="space"></div>
<div class="hr_line">&nbsp;</div>
<table width="100%" cellspacing=0 cellpadding=0 border=0>
	<thead>
		<th width="13%" />
<!-- 		<th width="37%" /> -->
<!-- 		<th width="13%" /> -->
		<th width="*" />
	</thead>
	
	<tr>
		<td class="td_le1" NOWRAP><spring:message code="t.subject" text="제목"/></td>
		<td class="td_le2"  colspan=3  style="word-break:break-all;"><c:out value="${bbs.subject}" /><%--= nek.common.util.HtmlEncoder.encode(itemData.subject) --%> </td>
	</tr>
	<tr>
		<td class="td_le1" NOWRAP><spring:message code="t.posting.period" text="게시기간"/></td>
		<td class="td_le2"  colspan=3  style="word-break:break-all;">
			<c:out value="${bbs.openDate}" /> ~ <c:out value="${bbs.closeDate}" /> 
		</td>
	</tr>
	<tr style="display:none;">
<!--		<td class="td_le1" NOWRAP>분 류</td>-->
<!--		<td class="td_le2"><c:if test="${bbs.category != null}"><c:out value="${bbs.category.categoryName }"/></c:if></td>-->
<!--		<td class="td_le1" NOWRAP>보안등급</td>-->
<!--		<td class="td_le2"><c:out value="${bbs.securityLevel.title }"/></td>-->
		<td class="td_le1" NOWRAP><spring:message code="t.preservePeriod" text="보존년한"/></td>
		<td class="td_le2" colspan="3">
			<c:choose>
				<c:when test="${locale == 'ko' }">
					<c:out value="${bbs.preservePeriod.titleKo }"/>
				</c:when>
				<c:when test="${locale == 'en' }">
					<c:out value="${bbs.preservePeriod.titleEn }"/>
				</c:when>
				<c:when test="${locale == 'ja' }">
					<c:out value="${bbs.preservePeriod.titleJa }"/>
				</c:when>
				<c:when test="${locale == 'zh' }">
					<c:out value="${bbs.preservePeriod.titleZh }"/>
				</c:when>
				<c:otherwise>
					<c:out value="${bbs.preservePeriod.title }"/>
				</c:otherwise>
			</c:choose>
		</td>
	</tr>
</table>

<!--본문 시작 -->
<div class="space"></div>
<table width="100%" height="180" border=0>
	<tr>
		<td class=content>
		${bbs.content}
		</td>
	</tr>
</table>
<!-- 본문 끝 -->

<table id=btntbl><tr><td class=tblspace09></td></tr></table>
<%
	Bbs bbs = (Bbs)request.getAttribute("bbs");
	BbsMaster bbsMaster = (BbsMaster)request.getAttribute("bbsMaster");

	StringBuffer fileAttachInfo = new StringBuffer();
	StringBuffer fileAttachURL = new StringBuffer();
	String baseURL = "http://" + request.getServerName() +  "/bbs/download.htm?bbsId=" + bbs.getBbsId() + "&docId=" + bbs.getDocId() + "&fileNo=";
	if(request.getServerName().indexOf("localhost") != -1){//로컬인지 서버인지 확인
		baseURL = request.getScheme() + "://" + request.getServerName()+":"+request.getServerPort() +  "/bbs/download.htm?bbsId=" + bbs.getBbsId() + "&docId=" + bbs.getDocId() + "&fileNo="; //로컬 시 적용  (https 적용)
	}else{
		baseURL = request.getScheme() + "://" + request.getServerName() +  "/bbs/download.htm?bbsId=" + bbs.getBbsId() + "&docId=" + bbs.getDocId() + "&fileNo="; //개발, 운영 시 적용 (https 적용)
	}
	
	List<BbsFile> files = bbs.getFiles();
	for(int i=0; i< files.size(); i++){
		BbsFile file = files.get(i);
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
	if (files.size() > 0 && bbsMaster.isAttach())
	{
%>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<thead>
		<tr><th width="13%"></th>
		<th width="*">
	</th></tr>
	</thead>
	<tbody>
	<tr>
		<td class="td_le1" style="text-align:center; background:#ddecf7;"><spring:message code="t.attached.file" text="첨부파일"/></td>
		<td class="td_le2" align="center" style="padding-bottom:10px;">
		<jsp:include page="<%=fileAttachURL.toString()%>" flush="true" />
		</td>
	</tr>
	</tbody>
</table>

<table><tr><td class="tblspace03"></td></tr></table>
<%
	}
%>
<div id="ajaxIndicator" style="display:none"><span>Loading</span></div>

<div id="commentArea">

<!-- 의견 쓰기 -->
<c:if test="${bbsMaster.comment and canCreate}">
<form:form commandName="bbsCommentWebForm">
	<form:hidden path="search.searchKey" />
	<form:hidden path="search.searchValue" />
	<form:hidden path="search.pageNo" />
	<form:hidden path="search.bbsId"/>
	<form:hidden path="search.docId" />
	<form:hidden path="search.pDocId" />
	<form:hidden path="search.useNewWin" />
	<form:hidden path="search.useAjaxCall" />
	<form:hidden path="bbsComment.id.docId" />
	<form:hidden path="bbsComment.id.comNo" />

<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
<td align="left"><img src="../common/images/bul_ch3.gif" border="0" align="absmiddle">
 <b><spring:message code="t.comments" text="댓글"/></b>
 <c:if test="${fn:length(bbsComments) > 0}">
  - <span id="cmtnum" style="color:#FF6600;"><c:out value="${fn:length(bbsComments)}"/></span> <spring:message code='bbs.cnt.opinion' text='개의 의견이 있습니다.' />
 </c:if>
 </td>
</tr>
</table>

	<table id="table_re2" width="100%" heights="100%" border="0" cellpadding="0" radius="3" rborder="#e0e0e0" rbgcolor="#f2f2f2">
	<tr>
	<td width=* bgcolor="#FFFFFF">	
		<textarea style="width:95%; height:45px; line-height:120%;" id="bbsComment.comments" name="bbsComment.comments" onkeyup="javascript:TextCount(this);"></textarea><br/>
		<a id="editButton" style="display:none;" href="javascript:goCommentSubmit('edit','')"><spring:message code='t.modify' text='편집' /></a>		
		<font color="#656565"><spring:message code="t.cmt.now" text="현재"/> <span id="tmptext">0</span><spring:message code="t.cmt.maximum" text="/최대 1000byte(한글 500자, 영문 1000자)"/></font>
	</td>
	<td width="95" align="absmiddle" valign=top align=center>
		<div id="commentSave"><a href="javascript:goCommentSubmit('save','')">
		<img src="../common/images/btn_comment_w.gif" border="0" align="absmiddle"></a></div>
		<div id="commentEdit" style="display:none;"><a href="javascript:goCommentSubmit('edit','')">
		<img src="../common/images/btn_comment_w.gif" border="0" align="absmiddle"></a></div>
	</td>
	</tr>
	</table>
	<script>//roundTable("table_re2");</script> 
</form:form>
<table class="tblspace05" id=btntbl><tr><td></td></tr></table>
</c:if>

<!-- 간단한 의견 목록 -->
<table id="table_op" width="100%" heights="100%" border="0" cellpadding="6" radius="4" rborder="#e0e0e0" rbgcolor="#ffffff">
<tr>
<td bgcolor="#FFFFFF">
	
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr height="2">
<td></td>
</tr>
<tr height="1">
<td width="100%" background="../common/images/lbg.gif"></td>
</tr>
<tr height="2">
<td></td>
</tr>
</table>

<!-- 간단한 의견 타이틀 시작 -->
	<c:if test="${fn:length(bbsComments) > 0}">
	<table border="0" cellpadding="0" cellspacing="0" width="100%" id=btntbl>
	<tr>
	<td align="left"><img src="../common/images/bul_ch3.gif" border="0" align="absmiddle"> <b><spring:message code="t.opinion" text="의견"/></b> - <span id="cmtnum" style="color:#FF6600;"><c:out value="${fn:length(bbsComments)}"/></span> <spring:message code='bbs.cnt.opinion' text='개의 의견이 있습니다.' /></td>
	</tr>
	</table>
	<!-- 간단한 의견 타이틀 끝 --> 
	<table id=btntbl><tr><td class="tblspace05"></td></tr></table>
	</c:if>

<c:forEach var="comment" items="${bbsComments }">
	<table border="0" cellpadding="0" cellspacing="0" width="100%">
	<tr height="30">
	<td align=left width="100%" bgcolor="#F2F2F2" style="padding-left:8px;">
		<img src="../common/images/pp.gif" border="0" align="absmiddle"> <b>
		<a href="javascript:ShowUserInfo('<c:out value="${comment.user.userId }" />')">
		<c:out value="${comment.user.nName}" />
		</a></b>&nbsp;<fmt:formatDate value="${comment.createDate}" pattern="yyyy-MM-dd HH:mm:ss"/>
		<!-- 
		<a href="javascript:void();"><img src="../common/images/btn_creply.gif" border="0" align="absmiddle"></a>
		 --> 
		<c:if test="${comment.user.userId eq user.userId}">
			<a href="javascript:getCommentText('${comment.id.comNo }');">
			<img src="../common/images/btn_cedit.gif" border="0" salign="absmiddle"></a>
			<a href="javascript:goCommentSubmit('delete','<c:out value="${comment.id.comNo }" />');">
			<img src="../common/images/btn_cdel.gif" border="0" salign="absmiddle"></a>
		</c:if>
	</td>
	</tr>
	<tr>
	<td align=left>
		<c:choose>
		<c:when test="${comment.user.userId eq user.userId }">
			<span id="${comment.id.docId }_${comment.id.comNo }" style="white-space:pre-wrap;line-height:130%;"><c:out value="${comment.comments}" /></span>
		</c:when>
		<c:otherwise>
			<span style="white-space:pre-wrap;line-height:130%;"><c:out value="${comment.comments}" /></span>
		</c:otherwise>
		</c:choose>
		<br/>		
			
		<table border="0" cellpadding="0" cellspacing="0" width="100%">
		<tr height="2">
		<td></td>
		</tr>
		<tr height="1">
		<td width="100%" background="../common/images/lbg.gif"></td>
		</tr>
		<tr height="2">
		<td></td>
		</tr>
		</table>
</td>
</tr>
</table>
</c:forEach>
</td>
</tr>
</table>

<!-- 간단한 의견 목록 끝 -->
</div>


<c:if test="${bbsMaster.reply and fn:length(relatedBbses) > 1}">
<!-- 관련문서 타이틀 시작 -->
<table width="100%" border="0" cellspacing="0" cellpadding="0" style="table-layout:fixed;">
	<tr>
		<td width="154"><img src="../common/images/doc_top_left.jpg"></td>
		<td width="*" height="36" background="../common/images/doc_top_bg.jpg"></td>
		<td width="10"><img src="../common/images/doc_top_right.jpg"></td>
	</tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="11" background="../common/images/doc_left_bg.gif"></td>
		<td width="*">
			<table width="100%" cellspacing="0" cellpadding="0" border="0"  STYLE="table-layout:fixed;">
			<c:forEach var="item" items="${relatedBbses}">
				<tr height=23>
					<c:choose>
						<c:when test="${item.docId eq bbs.docId}">
							<td width="25" class="td_docmapbb">
								<img src='../common/images/btn_docmap.gif' align=absmiddle>
							</td>
						</c:when>
						<c:otherwise>
							<td width="25" class="td_docmapba">&nbsp;</td>
						</c:otherwise>
					</c:choose>
					<td class="" nowrap>
					<c:if test="${item.docLevel > 1}">
						<c:forEach var="i" begin="0" end="${item.docLevel - 1}" step="1">&nbsp;</c:forEach>
						<img src="../common/images/btn_re.gif" border=0 align=absmiddle>
					</c:if>
					<c:choose>
						<c:when test="${item.docId eq bbs.docId}">
							<c:out value="${item.subject}" />
						</c:when>
						<c:otherwise>
							<a href="javascript:goSubmit('view','','<c:out value="${item.docId }" />');" class="td_docmapab" onFocus="blur();">
								<c:out value="${item.subject }" />
							</a>
						</c:otherwise>
					</c:choose>
					</td>
					<td width=80 class=""><c:out value="${item.writer.nName}" /></td>
					<td width=160 class=""><fmt:formatDate value="${item.createDate}" pattern="yyyy-MM-dd HH:mm:ss" /></td>
				</tr>
				<tr height="1"><td colspan="4" background="../common/images/doc_titleline.gif"></td></tr>
			</c:forEach>
			</table>
		</td>
		<td width=11 background="../common/images/doc_right_bg.gif"></td>
	</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" style="table-layout:fixed;">
	<tr>
		<td width="11"><img src="../common/images/doc_down_left.jpg"></td>
		<td width="*" height="12" background="../common/images/doc_down_bg.jpg"></td>
		<td width="11"><img src="../common/images/doc_down_right.jpg"></td>
	</tr>
</table>
</c:if>

</td>
</tr>
</table>
</div>
</body>
</html>