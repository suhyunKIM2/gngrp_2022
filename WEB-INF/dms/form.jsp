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
<%@ page import="nek.common.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%@ page import="nek3.domain.*" %>
<%@ page import="nek3.domain.dms.*" %>
<%@ page import="nek3.web.form.dms.DmsSearch" %>
<%@ page import="nek3.web.form.dms.DmsWebForm" %>
<%@ page import="nek.common.util.HtmlEncoder" %>

<%
	response.setHeader("Cache-Control","no-store");   
	response.setHeader("Pragma","no-cache");   
	response.setDateHeader("Expires",0);   
%>
<%!
	private final static long DAY_TIME = 86400000;

	private String setSelectedOption(int i1, int i2)
	{
		String selectStr = "";
		if (i1 == i2) selectStr = "selected";
		return selectStr;
	}

	private String setSelectedOption(String str1, String str2)
	{
		String selectStr = "";
		if (str1.equals(str2)) selectStr = "selected";
		return selectStr;
	}
%>
<%
	//OS 버전 확인
	String userAgent = request.getHeader("User-Agent");
	boolean selEditor = false;
	if (userAgent == null || 
		userAgent.indexOf("Windows 95") > 0 ||
		userAgent.indexOf("Windows 98") > 0)
	{
		selEditor = true;
	}

	boolean isIE = nek.common.util.Convert.isIE(request);
	String cateType = (String)request.getAttribute("cateType");
%>
<%
	//오늘 날짜 선언부분 시작
	java.util.Date today = new java.util.Date();
	java.text.SimpleDateFormat format_today = new java.text.SimpleDateFormat("yyyy-MM-dd");
	java.text.SimpleDateFormat format_fullToday = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	java.text.SimpleDateFormat format_m = new java.text.SimpleDateFormat("m");
	int cMinute = Integer.parseInt(format_m.format(today));	//현재 분
	java.text.SimpleDateFormat format_h = new java.text.SimpleDateFormat("H");
	int cHour = Integer.parseInt(format_h.format(today));		//현재 시
	String cAmpm = "";		//오전/오후
	String cAmpm2 = "";
	
	if(cMinute > 30){
		cHour = cHour + 1;	//30~60분 사이이면 시간 + 1
		cMinute = 0;
	
		if(cHour+1 >= 12)
		{
			cAmpm2 = "PM";
		}else{
			cAmpm2 = "AM";
		}
	}else{
		if(cHour+1 >= 12)
		{
			cAmpm2 = "PM";
		}else{
			cAmpm2 = "AM";
		}
		cMinute = 30;
	}
	
	if(cHour >= 12)
	{
		cHour = cHour - 12;	
		cAmpm = "PM";
	}else{
		cAmpm = "AM";
	}
	
	String strdate = null;
	if(request.getParameter("caldate") == null){	//파라미터 날짜가 없을 경우 오늘 날짜를 날짜필드에 setting
		strdate = format_today.format(today);
	}else{
		strdate = request.getParameter("caldate");	//보기에서 날짜 선택시 날짜 파라미터 값이 따라옴.
	}
	
	String cssPath = "../common/css";
	String imgCssPath = "/common/css/blue";
	String imagePath = "../common/images/blue";
	String scriptPath = "../common/scripts";
%>
<!DOCTYPE html>
<HTML>
<HEAD>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<TITLE><spring:message code="t.newDoc" /></TITLE>

<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.jquery.form.jsp"%>
	
<script src="/common/scripts/organization_selector.js"></script>

<%@ include file="../common/include.common.jsp"%>

<script>

	function sssvalidCheck() {
		var form = document.getElementById("dmsWebForm");
		//공유 점검.
		if ( $('#private').is(':checked') ) {
			a = document.getElementById("sharelist");
			if ( a.options.length < 1 ) {
			alert( "<spring:message code='t.not.sharing' text='공유대상이 지정되지 않았습니다.' />" );
				return false;
			}
		}
		
		if(form.elements["dms.catId"].value==""){
			alert( "<spring:message code='t.not.category' text='분류가 지정되지 않았습니다.' />" );
			return false;
		}
		
		if(form.elements["dms.subject"].value==""){
			alert( "<spring:message code='sch.enter.title' text='제목을 입력해 주세요' />" );
			form.elements["dms.subject"].focus();
			return false;
		}	
		return true;
	}

	function docSubmit(){
		var form = document.getElementById("dmsWebForm");
		if(!validCheck()) return false;
		
		//form.elements["dms.content"].value = geteditordata() ;
		
		if (!confirm("<spring:message code='c.save' text='저장하시겠습니까?' />")) return false;
				
		if ($('#private').is(':checked'))
		{
			selectAll(form.sharelist);
		}

		form.elements["dms.subContent"].value = geteditordata();
		
		waitMsg();
		
		if ($('.template-upload') && $('.template-upload').length > 0) {
			//$('#fileuploadstartconfirm').val(1);
			$('.fileupload-buttonbar').find('.start').click();
//			$('button[type=submit]').click();
			//return false;
		} else {
			form.method = "POST";
			form.action ="./save.htm";
			controlSubmit(form);
		}
	}

	function selectAll(selObj)
	{
		if (selObj.type == "select-multiple")
		{
			for (var i=0;i < selObj.length; i++)
			{
				selObj.options[i].selected = true;
			}
		}
	}

	function goSubmit(cmd)
	{
		//var fm = document.dmsWebForm;
		var form = document.getElementById("dmsWebForm");
		switch(cmd)
		{
			case "list":
				fm.method = "GET";
				fm.action = "./dms_list.jsp";
				break;
			case "post":
				docSubmit();
				break;
			case "close":
				if(confirm("<spring:message code='c.unsaveClose' text='현재 문서를 닫으시겠습니까?\\n\\n문서 편집중에 닫는 경우 저장이 되지 않습니다.?' />")){
					closeDoc();
				}
				return;
				break;
		}
		
		//fm.submit();
	}

	// (window.showModalDialog Version)
	function findCategoryInfoModal() {
		var winwidth = "320";
		var winheight = "450";
		var cType = $(":input:radio[name='dms.cateType']:checked").val();
		var url = "./categoryTree.htm?openmode=1&winname=parent.list_frame&conname=dmsWebForm&cateType=" + cType;
		returnValue = window.showModalDialog( url , "" ,
						 "status:no;scroll:no;center:yes;help:no;dialogWidth:" + winwidth + "px;dialogHeight:" + winheight + "px");
		if (returnValue != null) {
			var frm = document.getElementById("dmsWebForm");
			var arrayVal = returnValue;
			frm.elements["catFullName"].value = arrayVal[0];
			frm.elements["dms.catId"].value = arrayVal[1];
		}
	}

	// (dhtmlmodal Version)
	function findCategoryInfo() {
		var cType = $(":input:radio[name='dms.cateType']:checked").val();
		var url = "./categoryTree.htm?openmode=1&winname=parent.list_frame&conname=dmsWebForm&cateType=" + cType;
		window.modalwindow = window.dhtmlmodal.open(
			"_CHILDWINDOW_DMS1001", "iframe", url, "<spring:message code='t.doc.management' text='문서관리' />", 
			"width=320px,height=450px,resize=0,scrolling=1,center=1", "recal"
		);
	}
	
	function setCategoryInfo(returnValue) {
		if (returnValue != null) {
			var frm = document.getElementById("dmsWebForm");
			var arrayVal = returnValue;
			frm.elements["catFullName"].value = arrayVal[0];
			frm.elements["dms.catId"].value = arrayVal[1];
		}
	}

	function seteditordatass() {
		if (document.getElementById("dspcontent") !=null)
		{
			var encodeBody = document.all.dspcontent.innerText;
			document.all.dspcontent.innerHTML = encodeBody;
		}
		
	}
	
	//Editor 공통함수 : 본문 Html값 에디터에 설정하는 부분
	function SetEditorData(objEditor, contentId) {
		var contents = "";
		if (!contentId) {
			contents = document.getElementById("dms.subContent").value;
		} else {
			contents = document.getElementById(contentId).value;
		}
		if ( contents == "" ) return;
		if ( !objEditor ) {
			alert( "SetEditorData() Error - Editor Object Not Found");
			return;
		}
		if( getEditorName() == "twe" ) {
			objEditor.HtmlValue = contents;
		} else if( getEditorName() == "xfree" ) {
			objEditor.setHtmlValue( contents );	
		} else {
			objEditor.modify({ content: contents });
		}
	}
/* 
	function geteditordata() {
		var editor = document.getElementById("twe");	// tagFree
		//var editor = document.getElementById("Wec");	// namo
		if (editor != null && editor != "undefined"){
			if (editor.MimeValue) {
				return editor.MimeValue();
				//return editor.MIMEValue; //namo
			}
		} else {
			var txtContent = '';
			if (document.getElementById("txtContent")) txtContent = document.getElementById("txtContent").value;
			return txtContent;
		}
	}
 */
<%--
	var ORGUNIT_TYPE_USER = 0;
	var ORGUNIT_TYPE_DEPARTMENT = 1;
	var objRecipients = new Array();

	function OnClickAddressBook() {
		var url = "../common/recipient_selector.htm?caption=" + encodeURI("NEK주소록") + "&title=" + encodeURI("공유자를 선택하세요");
		var ret = window.showModalDialog(url, objRecipients,"dialogHeight: 400px; dialogWidth: 550px; edge: Raised; center: Yes; help: No; resizable: No; status: No; Scroll: no");
		
		if (ret != null) {
			objRecipients = new Array();
			for (var i = 0; i < ret.length; i++) {
				objRecipients.push(ret[i]);
			}
			RefreshRecipientsList();
		}
	}

	function RefreshRecipientsList() {
		var frm = document.getElementById("dmsWebForm");
		var objList = frm.sharelist;
		while (objList.options.length > 0) {
			objList.options.remove(0);
		}

		for (var i = 0; i < objRecipients.length; i++) {
			var objRecipient = objRecipients[i];			
			var objOption = document.createElement("OPTION");
			objOption.text = AddressToDisplayString(objRecipient);
			objOption.value = AddressToString(objRecipient);
			objList.options.add(objOption);
		}
	}

	function AddressToString(objAddress) {
		if (objAddress.type == ORGUNIT_TYPE_USER) {
			return "P:" + objAddress.name + ":" + objAddress.id + ":" + objAddress.position
				+ ":" + objAddress.department;
		} else if (objAddress.type == ORGUNIT_TYPE_DEPARTMENT) {
			return "D:" + objAddress.name + ":" + objAddress.id + ":" 			
				+ (objAddress.includeSub ? "+" : "-");
		}
		return "";
	}

	function AddressToDisplayString(objAddress) {
		var strDisplay = "";

		if (objAddress.type == ORGUNIT_TYPE_USER) {
			strDisplay += objAddress.name;
			strDisplay += "/";
			strDisplay += objAddress.position;
			strDisplay += "/";
			strDisplay += objAddress.department;
		} else if (objAddress.type == ORGUNIT_TYPE_DEPARTMENT) {
			strDisplay += objAddress.name;
			if (objAddress.includeSub) {
				strDisplay += "[+]";
			} else {
				strDisplay += "[-]";
			}
		}
		return strDisplay;
	}

	function ParseAddress(strData) {
		if (strData == "") {
			return null;
		}

		if (strData.charAt(0) == 'P') {
			//user, P:이름:UID:직급
			var segments = strData.split(':');
			if (segments.length < 5) {
				return null;
			}
			var objAddress = new Object();
			objAddress.type		= ORGUNIT_TYPE_USER;
			objAddress.name		= segments[1];
			objAddress.id		= segments[2];
			objAddress.position	= segments[3];
			objAddress.department = segments[4];
			return objAddress;
		} else if (strData.charAt(0) == 'D') {
			//department, D:부서이름:부서ID:(+|-)
			var segments = strData.split(':');
			if (segments.length < 4) {
				return null;
			}

			var objAddress = new Object();
			objAddress.type = ORGUNIT_TYPE_DEPARTMENT;
			objAddress.name = segments[1];
			objAddress.id	= segments[2];
			objAddress.includeSub = (segments[3] == "+");
			return objAddress;
		}

		return null;
	}
	
	function OnClickRemoveRecipients() {
		var objList = document.getElementById("sharelist");
		var bRefresh = false;
		for (var i = objList.options.length - 1; i >= 0; i--) {
			if (objList.options[i].selected) {
				RemoveRecipient(objList.options[i].value);
				bRefresh = true;
			}
		}

		if (bRefresh) {
			RefreshRecipientsList();
		}
	}
	
	function RemoveRecipient(strAddress) {
		var objNewRecipients = new Array();
		var nIndex = -1;
		var objAddress = ParseAddress(strAddress);
		if (objAddress != null) {
			for (var i = 0; i < objRecipients.length; i++) {
				if (objAddress.type != objRecipients[i].type ||
					objAddress.id != objRecipients[i].id) {
					objNewRecipients.push(objRecipients[i]);
				}
			}
			objRecipients = objNewRecipients;
		}
	}
--%>
	function setDispShareListTR()
	{
		var gb1 = $('#public');
		var gb2 = $('#private');
		var shareListLayer = document.getElementById("divShareList");
		$('input:checkbox[name=dms.openFlag]').click(function() {
			//alert(gb1.val() + " : " + gb2.val() + " : " + $(this).val());
		    if(gb1.val()== $(this).val()){
		    	if(gb1.is(':checked')){
		    		gb2.attr('checked', false);
		    	}
	    		shareListLayer.style.display = "none";
		    }
		    if(gb2.val()== $(this).val()){
		    	if(gb2.is(':checked')){
		    		gb1.attr('checked', false);
		    		shareListLayer.style.display = "";
		    	}else{
		    		shareListLayer.style.display = "none";
		    	}
		    }
		});
	}
	
</script>


<script>
	function validCheck(){
		var validator = $("#dmsWebForm").validate({
			rules:{
				"catFullName":{
					required:true
				},
				"dms.subject":{
					required:true
				}
			},
			messages:{
				"catFullName":{
					required: '<spring:message code='c.choice.category' text='분류항목을 선택하십시요' />'
				},
				"dms.subject":{
					required: '<spring:message code='c.input.subject' text='제목을 입력하십시요' />'
				}
			},
			focusInvalid:true
		});
		return $("#dmsWebForm").validate().form();
	}
	
	$(document).ready(function(){
		
		ShowUserInfoSet();
		
//		$("select, input[type=text], /*input[type=checkbox],*/ input[type=radio], textarea").uniform();
		
		var fm = document.getElementById("dmsWebForm");
		var recipients = document.getElementById("sharelist");
		
		$('input:checkbox[name=dms.openFlag]').click(function() {
			var gb1 = $('#public');
			var gb2 = $('#private');
			var shareListLayer = document.getElementById("divShareList");
			
			//alert(gb1.val() + " : " + gb2.val() + " : " + $(this).val());
			var chkValue = $(this).val();
			if ( chkValue == '1' ) {	//전체
				if(gb1.is(':checked')){
					gb2.attr("checked", false);
				}
				shareListLayer.style.display = "none";
			} else {
				if(gb2.is(':checked')){
					gb1.attr("checked", false);
					shareListLayer.style.display = "";
				} else {
		    		shareListLayer.style.display = "none";
		    	}
			}
		});
		
		if(recipients.length > 0){
			var shareListLayer = document.getElementById("divShareList");
			if($('#private').is(':checked')){
				shareListLayer.style.display = "";
			}
		}
		
		/*
		for (var i = 0; i < recipients.length; i++) {
			var objAddress = ParseAddress(recipients[i].value);
			if (objAddress != null) {
				objRecipients.push(objAddress);
			}
		}
		*/

// 		var content = document.getElementById("dms.subContent").value;
// 		var editor = document.getElementById("twe");	// tagFree
// 		if (editor == null || editor == undefined){
// 			Editor.modify({
// 				"content": content /* 내용 문자열, 주어진 필드(textarea) 엘리먼트 */
// 			});
// 		}
		
		Organizations.Item = [
     			"type",
   				"userid",
   				"username",
   				"dpid",
   				"dpname",
   				"includeSub",
   				"upname",
   	   			"udname"
   		];
		
		Organizations.formatAddress("sharelist");

		$('#sharelist').bind('dblclick', function() {
			var title = '<spring:message code="t.organization.chart" text="조직도" />';
			var caption = '<spring:message code="t.select.sharer" text="공유자 선택" />';
			Organizations.open('sharelist',title , caption, 0, 0, 1);
		});
		
		pageScroll();
		
		// form 포커스 관련 테스트 중. 2013-12-05
		//$('form :input:text:visible:not(input[class*=filter]):first').focus();
		$('body').focus();
		
		setTimeout( "popupAutoResize2();", "500");		//팝업창 resize
	});
	
	function chkCategory(cType){
		var authObj = document.getElementById("authObj");
		if(cType!="S"){
			authObj.style.display = "none";
		}else{
			authObj.style.display = "";
		}
		
		document.getElementById("catFullName").value = "";
		document.getElementById("dms.catId").value = "";
	}
</script>

 <!-- 태그프리에디터 로딩 이후 함수 수행 -->
<script language="JScript" FOR="twe" EVENT="OnControlInit()">
	var content = document.getElementById("dms.content").value;
	this.BodyValue =  content;
</script>
<script type="text/javascript">
/* 
 function OnInit(){	 
	var editor = document.getElementById("twe");	// tagFree
	//var editor = document.getElementById("Wec");	// namo
	if (editor == null || editor == "undefined"){
		var txtContent = document.getElementById("txtContent");
		var content = document.getElementById("dms.content").value;
		//txtContent.value = content; 에디터
	} else {
		editor.InitDocument();						// tagFree
	}
}
// body onload="javascript:OnInit(); " ddonclick="parent.dhtmlwindow.setfocus(parent.mywin)"
 */
</script>
</HEAD>

<body>

<div id="pageScroll" class="wrapper">
<form:form commandName="dmsWebForm" enctype="multipart/form-data" onsubmit="return false;" action="/upload">
	<c:if test="${dmsWebForm.search != null }">
		<form:hidden path="search.listMode" />
		<form:hidden path="search.includeSub" />
		<form:hidden path="search.searchType" />
		<form:hidden path="search.searchText" />
<%-- 		<form:hidden path="search.moduleId" /> --%>
		<form:hidden path="search.docId" />
		<form:hidden path="dms.securityLevel.securityId" value="1" />
	</c:if>
	<form:hidden path="dms.catId" />
	<form:hidden path="dms.content" />

<center>
<table class="doc-width" cellspacing=0 cellpadding=0 border=0>
<tr>
<td align="center">

<!--  Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/title_doc.gif); height:33px; border: 1px solid #CCC;;">
<tr height="26">
<td width="300" align=left style="padding-left:10px; ">
	<img src="/common/images/icons/icon_inquiry.jpg" border="0" align="absmiddle">
	<span class="ltitle"><spring:message code="t.doc.management" text="문서관리"/> <spring:message code="t.insert" text="등록"/></span>
</td>
<td width="*" align="right" style="padding-right:10px;">
	<c:if test="${dms.catId != '20140409161336'}">
	<img src="../common/images/pp.gif" border="0" align="absmiddle">
	<a href="#" rel='<c:out value="${user.userId}" />' class="maninfo">
	<c:set var="now" value="<%= new Date() %>" />
	<c:out value="${user.nName }"/> / <c:out value="${user.department.dpName}"/></a> ( <fmt:formatDate value="${now}" pattern="yyyy-MM-dd HH:mm:ss"/> )
	</c:if>
</td>
</tr>
</table>

<table><tr><td class=tblspace09></td></tr></table>

<!--  수행버튼  -->	
<table border="0" cellpadding="0" cellspacing="0" width="100%">
	<tr>
	<td width="*" align="right">
		<a onclick="javascript:goSubmit('post','');" class="button white medium">
		<img src="../common/images/bb02.gif" border="0"> <spring:message code='t.save' text='저장' /> </a>
		<a onclick="javascript:goSubmit('close','');" class="button white medium">
		<img src="/common/images/bb02.gif" border="0"> <spring:message code='t.close' text='닫기' /></a>
	</td>
	</tr>
</table>

<table><tr><td class=tblspace09></td></tr></table>

<!-- 전체 문서 넓이 : 100% -->
<div class="space"></div>
<div class="hr_line">&nbsp;</div>
<table width="100%" cellspacing=0 cellpadding=0 border="0">
	<colgroup>
		<col width="13%">
		<col width="37%">
		<col width="13%">
		<col width="*">
	</colgroup>
	<tr>
		<td class="td_le1"><spring:message code='addr.division' text='구분'/> <span class="readme"><b>*</b></span></td>
		<c:choose>
			<c:when test="${isModify }">
			<td class="td_le2">
			</c:when>
			<c:otherwise>
			<td class="td_le2">
			</c:otherwise>
		</c:choose>
			<form:radiobutton path="dms.cateType" value="S" onclick="chkCategory('S');"/><spring:message code='dms.share' text='공용문서함'/>
			<form:radiobutton path="dms.cateType" value="P" onclick="chkCategory('P');"/><spring:message code='dms.person' text='개인문서함'/>
<%-- 			<form:radiobutton path="dms.cateType" value="D" onclick="chkCategory('D');"/>부서 --%>
		</td>
		<c:choose>
			<c:when test="${isModify }">
				<c:choose>
					<c:when test="${isOwner || isAdmin }">
						<td class="td_le1">	Check Out</td>
						<td class="td_le2"><form:radiobutton path="dms.chkOut"  value="false"  />IN<form:radiobutton path="dms.chkOut"  value="true"  />OUT</td>
					</c:when>
					<c:otherwise>
						<td class="td_le1"></td>
						<td class="td_le2"><form:hidden path="dms.chkOut" /></td>
					</c:otherwise>
				</c:choose>
			</c:when>
			<c:otherwise>
				<td class="td_le1">	Check Out</td>
				<td class="td_le2"><form:radiobutton path="dms.chkOut"  value="false"  />IN<form:radiobutton path="dms.chkOut"  value="true"  />OUT</td>
			</c:otherwise>
		</c:choose>
	</tr>
	<tr>
		<td class="td_le1"><spring:message code='t.category' text='문서분류' /> <span class="readme"><b>*</b></span></td>
		<td class="td_le2">
			<input type="text" name="catFullName" id="catFullName" value="<c:out value='${catFullName }' />" readonly="true" onclick="javascript:findCategoryInfo();" style="width:180px; cursor:pointer;" />
<!-- 			<a href="javascript:findCategoryInfo()"><img src="../common/images/i_search.gif" border="0" align="absmiddle"></a> -->
			<a onclick="javascript:findCategoryInfo();" class="button gray medium">
			<img src="/common/images/bb02.gif" border="0"> <spring:message code='t.search' text='search' /></a>
		</td>
		<td class="td_le1"><spring:message code='t.importance' text='중요구분' /> <span class="readme"><b>*</b></span></td>
		<td class="td_le2">
			<form:checkbox path="dms.hotFlag"  value="1" /><spring:message code='t.importance' text='중요설정' />
		</td>
	</tr>
	<tr style="sdisplay:none;">
		<td class="td_le1"><fmt:message key="addr.share.div"/>&nbsp;<!-- 공유구분 --></td>
		<td class="td_le2">
			<c:if test="${search.cateType == 'P' || search.cateType == 'D' }">
				<c:set var="authDisplay" value="style=display:none"/>
			</c:if>
			<div id="authObj" <c:out value="${ authDisplay }"></c:out> >
			<form:checkbox path="dms.openFlag" id="public" value="1" onclicks="setDispShareListTR();" /><fmt:message key="addr.share.entire"/>&nbsp;<!-- 전체공유 -->
			<form:checkbox path="dms.openFlag" id="private" value="0" onclicks="setDispShareListTR();" /><fmt:message key="addr.share.specify"/>&nbsp;<!-- 지정공유 -->
			</div>
		</td>
		<td class="td_le1"><spring:message code="t.preservePeriod" text="보존년한 "/></td>
		<td class="td_le2">
			<form:select path="dms.preservePeriod.preserveId" cssClass="fld_100">
			<c:choose>
				<c:when test="${locale == 'ko' }">
					<form:options items="${preservePeriods }" itemValue="preserveId" itemLabel="titleKo" />
				</c:when>
				<c:when test="${locale == 'en' }">
					<form:options items="${preservePeriods }" itemValue="preserveId" itemLabel="titleEn" />
				</c:when>
				<c:when test="${locale == 'ja' }">
					<form:options items="${preservePeriods }" itemValue="preserveId" itemLabel="titleJa" />
				</c:when>
				<c:when test="${locale == 'zh' }">
					<form:options items="${preservePeriods }" itemValue="preserveId" itemLabel="titleZh" />
				</c:when>
				<c:otherwise>
					<form:options items="${preservePeriods }" itemValue="preserveId" itemLabel="title" />
				</c:otherwise>
			</c:choose>
			</form:select>
		</td>
	</tr>
	<tr id="divShareList" style="display:none;">
		<td class="td_le1"><fmt:message key="sch.share.person"/>&nbsp;<!-- 지정공유 --></td>
		<td class="td_le2" colspan=3>
			<select id="sharelist" name="sharelist" style="width:80%;height:80px;display:none;" multiple="multiple">
			<c:forEach var="shareItem" items="${dmsShareList }">
				<c:choose>
					<c:when test="${fn:contains(shareItem.shareType, 'D') }">
						<c:choose>
							<c:when test="${shareItem.childDept}">
								<c:set var="shareText" value="${shareItem.shareName}${'[+]' }"/>
							</c:when>
							<c:otherwise>
								<c:set var="shareText" value="${shareItem.shareName}${'[-]' }"/>
							</c:otherwise>
						</c:choose>
					</c:when>
					<c:otherwise>
						<c:set var="shareText" value="${shareItem.shareName }"/>
					</c:otherwise>
				</c:choose>
				<option value="<c:out value="${shareItem.shareValue}"/>"><c:out value="${shareText }" /></option>
			</c:forEach>
			
			</select>
			<!-- 
			<a onclick="javascript:OnClickAddressBook()" class="button white medium">
			<img src="../common/images/bb02.gif" border="0"> <spring:message code='t.addressbook' text='주소록' /> </a>
			-->
		</td>
	</tr>
	<tr>
		<td class="td_le1"><spring:message code="t.subject" text="제목 "/><span class="readme"><b>*</b></span></td>
		<td class="td_le2" colspan=3>
			<form:input path="dms.subject" class="w100p" onkeydown="CheckTextCount(this, 120);" />
		</td>
	</tr>
	<tr>
		<td class="td_le1"><spring:message code="t.searchValue" text="검색어 "/></td>
		<td class="td_le2" colspan=3>
			<form:input path="dms.keywords" class="w100p" onkeydown="CheckTextCount(this, 120);" />
		</td>
	</tr>
	<tr>
		<td class="td_le2" colspan=4>
			<form:hidden path="dms.subContent" />
			<!-- 웹에디터 삽입-->
			<jsp:include page="../common/daum_editor_control.jsp" flush="true" />
			<%-- <form:textarea path="dms.subContent" class="w100p" cssStyle="height:60px;" onkeydown="CheckTextCount(this, 1200);" /> --%>
		</td>
	</tr>
</table>
<!-- ??? -->
<%
%>
<!-- 파일 다운로드 컨트롤 -->

<table><tr><td class=tblspace09></td></tr></table>
<%
%>
<!-- 웹에디터 삽입-->

<!--  파일 첨부 컨트롤  -->
<%
	int port = request.getServerPort();
	String homePath= "/dms/save.htm";
	String attachURL = "../common/attachup_control.jsp?" + "actionurl=" + java.net.URLEncoder.encode(homePath, "utf-8");
	
	Dms dms = ((DmsWebForm)request.getAttribute("dmsWebForm")).getDms();
	String baseURL = "http://" + request.getServerName() + "/dms/download.htm?docId=" + dms.getDocId() + "&fileNo=";
	if(request.getServerName().indexOf("localhost") != -1){//로컬인지 서버인지 확인
		baseURL = request.getScheme() + "://" + request.getServerName()+":"+request.getServerPort() + "/dms/download.htm?docId=" + dms.getDocId() + "&fileNo="; //로컬 시 적용  (https 적용)
	}else{
		baseURL = request.getScheme() + "://" + request.getServerName() + "/dms/download.htm?docId=" + dms.getDocId() + "&fileNo="; //개발, 운영 시 적용 (https 적용)
	}
	
	StringBuffer fileAttachInfo = new StringBuffer();
	List<DmsFile> files = dms.getDmsFile();
	if(files != null){
		for(int i=0; i<files.size(); i++){
			DmsFile file = files.get(i);
			//URL|파일명|크기|...
			fileAttachInfo.append(file.getId().getFileNo() + "|");
			fileAttachInfo.append(file.getFileName() + "|");
			fileAttachInfo.append(file.getFileSize() + "|");
		}
			
	}
		
%>
<%-- <%	if (isIE) { %> --%>
<%-- <jsp:include page="<%=attachURL%>" flush="true"> --%>
<%-- 	<jsp:param name="attachfiles" value="<%=fileAttachInfo.toString()%>"/> --%>
<%-- 	<jsp:param name="maxfilesize" value="${userConfig.uploadSize}"/> --%>
<%-- 	<jsp:param name="maxfilecount" value=""/> --%>
<%-- </jsp:include> --%>
<%-- <%	} else { %> --%>
<table width="100%" cellspacing=0 cellpadding=0 border="0">
	<colgroup>
		<col width="13%">
		<col width="*">
	</colgroup>
	<tr>
		<td class="td_le1"><spring:message code="t.attachfile"/><!-- 첨부--></td>
		<td class="td_le2">		
			<jsp:include page="../common/file_upload_control.jsp" flush="true">
				<jsp:param name="attachfiles" value="<%=fileAttachInfo.toString()%>"/>
				<jsp:param name="actionURL" value="./save.htm"/>
				<jsp:param name="baseURL" value="<%=baseURL%>"/>
				<jsp:param name="filepath" value="dms"/>
			</jsp:include>
		</td>
	</tr>
</table>
<%-- <%	} %> --%>

</td>
</tr>
</table>
</center>

</form:form>
</div>
<body>
</html>

