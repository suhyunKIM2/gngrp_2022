<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="nek3.domain.bbs.Bbs" %>
<%@ page import="nek3.domain.bbs.BbsPopup" %>
<%@ page import="nek3.domain.bbs.BbsFile" %>
<%@ page import="nek3.web.form.bbs.BbsWebForm" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
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

	String cssPath = "../common/css";
	String imgCssPath = "/common/css/blue";
	String imagePath = "../common/images/blue";
	String scriptPath = "../common/scripts";
	
	String bbsWriter = (String)request.getAttribute("bbsWriter");

	String userAgent = request.getHeader("User-Agent");
	boolean isIE = nek.common.util.Convert.isIE(request);
	

	String homePath = "/bbs/save.htm";
	String attachURL = "../common/attachup_control.jsp?"
		+ "actionurl=" + java.net.URLEncoder.encode(homePath, "utf-8");
	
	Bbs bbs = ((BbsWebForm)request.getAttribute("bbsWebForm")).getBbs();

	boolean isModify = !StringUtils.isEmpty(bbs.getDocId());	// 문서번호가 존재한다면 수정
	// 수정이 아니고 부모문서번호가 존재한다면 or 수정이고 자신문서번호와 부모문서번호가 같다면 응답글
	boolean isReply = (!isModify && !StringUtils.isEmpty(bbs.getpDocId())) || (isModify && !StringUtils.equals(bbs.getDocId(), bbs.getpDocId()));	
	String categoryTr = "";
	if (isReply) categoryTr = " style='display:none;'";

// 	System.out.println("isModify: " + isModify);
// 	System.out.println("isReply: " + isReply);
// 	System.out.println("categoryTr: " + categoryTr);
// 	System.out.println("bbs.getpDocId(): " + bbs.getpDocId());
	
	//http://127.0.0.1
	String baseURL = "http://" + request.getServerName() + "/bbs/download.htm?bbsId=" + bbs.getBbsId() + "&docId=" + bbs.getDocId() + "&fileNo=";
	if(request.getServerName().indexOf("localhost") != -1){//로컬인지 서버인지 확인
		baseURL = request.getScheme() + "://" + request.getServerName()+":"+request.getServerPort() + "/bbs/download.htm?bbsId=" + bbs.getBbsId() + "&docId=" + bbs.getDocId() + "&fileNo=";
	}else{
		baseURL = request.getScheme() + "://" + request.getServerName() + "/bbs/download.htm?bbsId=" + bbs.getBbsId() + "&docId=" + bbs.getDocId() + "&fileNo=";
	}
	StringBuffer fileAttachInfo = new StringBuffer();
	List<BbsFile> files = bbs.getFiles();
	if(files != null) {
		for(int i=0; i< files.size(); i++){
			BbsFile file = files.get(i);
			//URL|파일명|크기|...
			fileAttachInfo.append(file.getId().getFileNo() + "|");
			fileAttachInfo.append(file.getFileName() + "|");
			fileAttachInfo.append(file.getFileSize() + "|");
		}
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="Cache-Control" content="no-cache">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="0">
<title><c:out value="${bbsMaster.title }" />&nbsp;<spring:message code="t.newDoc" text="새문서"/></title>

<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.jquery.form.jsp"%>

<!-- uniform -->
<script src="/common/jquery/plugins/uniform/jquery.uniform.min.js" type="text/javascript"></script>
<link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/plugins/uniform/themes/default/css/uniform.default.css" />

<script src="/common/jquery/plugins/jquery.bgiframe.js" type="text/javascript"></script>

<%@ include file="../common/include.common.jsp"%>

<script type="text/javascript">
	function validCheck(){
    	<c:if test="${bbsMaster.bbsId == 'bbs00000000000000' }">
    	var frm = document.getElementById("bbsWebForm");
		$("#sDate").rules("remove");
		$("#eDate").rules("remove");
		if(frm.elements["usePopup"].checked){
			$("#sDate").rules("add",{
				 required: true,
				 messages: {
				 	required: "<spring:message code='v.period.required' text='기간을 선택해 주십시요' />",
				 	date: "<spring:message code='v.date.invalid' text='날짜 형식이 틀립니다' />"
				 }				
			});
			$("#eDate").rules("add",{
				 required: true,
				 datetimePeriod:true,
				 messages: {
				 	required: "<spring:message code='v.period.required' text='기간을 선택해 주십시요' />",
				 	date: "<spring:message code='v.date.invalid' text='날짜 형식이 틀립니다' />"
				 }				
			});
		}
    	</c:if>
    	var isValid = validator.form();
    	if(!isValid) validator.focusInvalid();
		return isValid;
	}
	
	function docSubmit(){
		var form = document.getElementById("bbsWebForm");
		// setEditorForm(); // 에디터의 데이터를 폼에 삽입
		
        if (!validCheck()) return false;
		
		if (!confirm("<spring:message code='c.save' text='저장하시겠습니까?' />")) return false;

		$("#closeDate").removeAttr("disabled");
		form.elements["bbs.content"].value = geteditordata();
		
		waitMsg();	/* Processing message */
		
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

	function togglePopupPeriod(show){
		if(show) $("#popupPeriod").show();
		else $("#popupPeriod").hide();
	}

	function goSubmit(cmd,docId){ 
		var frm = document.getElementById("bbsWebForm");
		switch(cmd) {
			case "post":				 
				//if (!docSubmit()) return;
				docSubmit();
				//frm.submit();
				break;
			case "close":
				if(confirm("<spring:message code='c.unsaveClose' text='현재 문서를 닫으시겠습니까?\\n\\n문서 편집중에 닫는 경우 저장이 되지 않습니다.' />")){
					window.close();
				}
				return;
				break;
			default:
				return;
				break;
		}
	}

	function objHide(){
		var twe = document.getElementById("twe");
		if ( twe ) {
			twe.style.width = '0px';
			twe.style.height = '0px';
		}
	}
	function objView() {
		var twe = document.getElementById("twe");
		if ( twe ) {
			twe.style.width = '760px';
			twe.style.height = '320px';
		}
	}
	//datePicker가 ActiveX 에디터에 가려지는 현상을 iFrame 추가해서 가려지지 않도록 구현함.
	function actView(id, type){
		setTimeout(function() {		
	        $("#"+id).before("<iframe id='hideFrame' frameborder='0' scrolling='no' style='filter:alpha(opacity=0); position:absolute; "
                + "left: " + $("#ui-datepicker-div").css("left") + ";"
                + "top: " + $("#ui-datepicker-div").css("top") + ";"
                + "width: " + $("#ui-datepicker-div").outerWidth(true) + "px;"
                + "height: " + $("#ui-datepicker-div").outerHeight(true) + "px;'></iframe>");
	        if(type == "change")  actHide(); 
	    }, 50);
	}
	//iFrame 숨김
	function actHide(){
		$("#hideFrame").remove();
	}
	//시작-종료일 비활성화
	function blarDate(id){
		 if (id == "sDate"){
		 	$('#eDate').datepicker( "option", "minDate", $("#sDate").val() );
		 }else if (id == "eDate"){
		  	$('#sDate').datepicker( "option", "maxDate", $("#eDate").val() );
		 }
	}
</script>
<script type="text/javascript">
var validator = null;
$(document).ready(function(){
	$("input[type=text], input[type=checkbox], input[type=radio], textarea").uniform();
	//$("select").uniform({selectAutoWidth : true});
	
	$("#sDate, #eDate").datepicker({ 
		dateFormat: 'yy-mm-dd' ,
		monthNamesShort: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
		prevText: '이전달',
		nextText: '다음달',
	 	yearRange: 'c-10:c+10', 		
		showOtherMonths: true,
		selectOtherMonths: true,
		changeMonth: true,
		changeYear: true,
		onChangeMonthYear: function (year, month, inst) {  
	 		actView(inst.id, "change");
        },
		beforeShow: function(input, inst) {
			objHide();
			actView(inst.id, "before");
		},
		onClose: function(dateText, inst) {
			objView(); 
			actHide();
			blarDate(inst.id);
		},
		onSelect: function (dateText, inst) {  
			actHide();
        }
	});
	$("#openDate, #closeDate").datepicker({
		dateFormat: 'yy-mm-dd' ,
		monthNamesShort: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
		prevText: '이전달',
		nextText: '다음달',
	 	yearRange: 'c-10:c+10', 		
		showOtherMonths: true,
		selectOtherMonths: true,
		changeMonth: true,
		changeYear: true,
		minDate: $("#openDate").val(),
		onChangeMonthYear: function (year, month, inst) {  
	 		actView(inst.id, "change");
        },
		beforeShow: function(input, inst) {
			objHide();
			actView(inst.id, "before");
		},
		onClose: function(dateText, inst) {
			objView(); 
			actHide();
		},
		onSelect: function (dateText, inst) {  
			actHide();
        }
	});
	
	<c:if test="${bbsWebForm.usePopup }">
	$("#popupPeriod").show();
	</c:if>
/*
	var content = document.getElementById("bbs.content").value;
	var editor = document.getElementById("twe");	// tagFree
	if (editor == null || editor == undefined){
		//var txtContent = document.getElementById("txtContent");
		//txtContent.value = content;
		// 에디터에 데이터 삽입 
		Editor.modify({
			"content": content / 내용 문자열, 주어진 필드(textarea) 엘리먼트 /
		});
	}
	*/
	validator = $("#bbsWebForm").validate({
		rules:{
			"bbs.subject":{ required:true },
			"bbs.closeDate":{ required:true }
		},
		messages:{
			"bbs.subject":{ required:"<spring:message code='v.subject.required' text='제목을  입력하십시요' />" },
			"bbs.closeDate":{ required:"<spring:message code='none' text='게시기간 종료일을 선택하십시요' />" }
		},
		focusInvalid:true
	});
	
	// 영구보존 관련 추가
	var cdate = "";
	 $('#never').click(function() {
       var ischecked = $('#never').attr('checked');
       if(ischecked){
           // 이전 값 보존 후, 영구설정.
           cdate = $("#closeDate").val();
           $("#closeDate").val( "2025-12-30" );
           $("#startDate").attr("disabled", "true" );
           $("#closeDate").attr("disabled", "true" );
       }else{
           // 이전 값 보존.
    	   $("#closeDate").val( cdate );
    	   $("#startDate").attr("disabled", "false");
           $("#closeDate").removeAttr("disabled");
       }
    });
	/*
	$( "button" ).click(
		function() {
			alert('test');
			return false; 
			alert('end');
		}
	);
	*/
	
	pageScroll();	// page Scroll을 위해 사용. 2013-08-31
	
	setTimeout( "popupAutoResize2();", "500");		//팝업창 resize
});

jQuery.validator.addMethod("datetimePeriod", function(value, element) {
	var sDateTime = $("#sDate").datepicker("getDate");
	var eDateTime = $("#eDate").datepicker("getDate");
	var isSTimePM = $("#sTimeAMPM").val() == "PM";
	var isETimePM = $("#eTimeAMPM").val() == "PM";
	var sTimeHour = parseInt($("#sTimeHour").val());
	var eTimeHour = parseInt($("#eTimeHour").val());
	var sTimeMinute = parseInt($("#sTimeMinute").val());
	var eTimeMinute = parseInt($("#eTimeMinute").val());
	if(isSTimePM) sTimeHour += 12;
	if(isETimePM) eTimeHour += 12;
	sDateTime.setHours(sTimeHour, sTimeMinute);
	eDateTime.setHours(eTimeHour, eTimeMinute);
    return eDateTime > sDateTime;
}, "<spring:message code='v.dateperiod.notvalid' text='기간선택이 올바르지 않습니다' />");

</script>
</head>

 <%--
<script language="JScript" FOR="twe" EVENT="OnControlInit()">
	var content = document.getElementById("bbs.content").value;
	var editor = document.getElementById("twe");	// tagFree
	if (editor == null || editor == "undefined"){
		var txtContent = document.getElementById("txtContent");
		txtContent.value = content;
	} else {
		//editor.InitDocument();
		this.BodyValue =  content;
	}
</script>
 --%>
<!-- 태그프리에디터 로딩 이후 함수 수행 -->

<body style="margin:1px;">
<div id="pageScroll" class="wrapper">
<form:form enctype="multipart/form-data" commandName="bbsWebForm" action="/upload">
	<c:if test="${bbsWebForm.search != null }">
		<form:hidden path="search.searchKey" />
		<form:hidden path="search.searchValue" />
		<form:hidden path="search.pageNo" />
		<form:hidden path="search.bbsId" />
		<form:hidden path="search.docId" />
		<form:hidden path="search.useLayerPopup" />
		<form:hidden path="search.useNewWin" />
	</c:if>
<%-- 	<form:input path="bbs.bbsId"/> --%>
	<form:hidden path="bbs.docId" />
	<form:hidden path="bbs.content" />
	<form:hidden path="bbs.pDocId" />
	<form:hidden path="bbs.tpDocId" />

<table class="doc-width" cellspacing=0 cellpadding=0 border=0>
<tr>
<td>

<!--  Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/title_doc.gif); height:33px; border: 1px solid #CCC;;">
<tr height="26">
<td width="*" align=left style="padding-left:10px; ">
	<img src="/common/images/icons/icon_inquiry.jpg" border="0" align="absmiddle">
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
	<img src="../common/images/pp.gif" border="0" align="absmiddle">
	<a href="javascript:ShowUserInfo('<c:out value="${user.userId}" />');" class="maninfo">
	<c:set var="now" value="<%= new Date() %>" />
	<c:out value="${user.nName }"/> / <c:out value="${user.department.dpName}"/></a> ( <fmt:formatDate value="${now}" pattern="yyyy-MM-dd HH:mm:ss"/> )
</td>
</tr>
</table>

<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr height="5">
<td></td>
</tr>
</table>

<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
	<td width="*" align="right" class="fileupload-buttonbar">
		<a onclick="javascript:goSubmit('post','');" class="button gray medium">
		<img src="../common/images/bb02.gif" border="0"> <spring:message code='t.save' text='저장' /> </a>
<%-- 		<c:if test="${bbsWebForm.search != null && !bbsWebForm.search.useLayerPopup }"> --%>
		<a onclick="javascript:closeDoc();" class="button white medium">
		<img src="/common/images/bb02.gif" border="0"> <spring:message code="t.close" text="닫기"/> </a>
<%-- 		</c:if> --%>
	</td>
</tr>
</table>

<table><tr><td class=tblspace09></td></tr></table>

<div class="space"></div>
<div class="hr_line">&nbsp;</div>

<table width="100%" cellspacing=0 cellpadding=0 border="0">
	<thead>
		<th width="13%" />
		<th width="37%" />
		<th width="13%" />
		<th width="*" />
	</thead>
	<tr>
		<td class="td_le1"><spring:message code='t.writer' text='게시자' /></td>
		<td class="td_le2">
			<form:input class="w100p" path="bbs.writerName" value="<%=bbsWriter %>"/>
		</td>
		<td class="td_le1">
		<c:if test="${isManager}">
			<spring:message code='t.importance/notice' text='중요/공지설정' />
		</c:if>
		</td>
		<td class="td_le2">
		<c:if test="${isManager}">
			<form:checkbox path="bbs.important"  /><spring:message code='t.importance' text='중요설정' />
			<c:if test="${!isReply }">
				<form:checkbox path="bbs.notice"  /><spring:message code='t.notice' text='공지설정' />
			</c:if>
		</c:if>
		</td>
	</tr>
	
	<c:if test="${bbsMaster.bbsId == 'bbs00000000000000' }">
	<tr>
		<td class="td_le1"><spring:message code='t.usePopup' text='팝업설정' /></td>
		<td class="td_le2" colspan=3>
			<c:if test="${bbsWebForm.bbs.popup != null }"></c:if>
		
			<table width="100%" cellspacing=0 cellpadding=0 border="0">
				<tr>
					<td width="80">
						<form:checkbox path="usePopup" onclick="javascript:togglePopupPeriod(this.checked);"/><spring:message code='t.bbs.setting' text='기간설정' />
					</td>
					<td>
						<div id="popupPeriod" style="position:relative;top:1px;display:none;">
							<form:input path="sDate" id="sDate" readonly="true" class="dateInput" style="width:70px;" />
							<form:select path="sTimeHour" style="width:60px;">
									<form:option value="00">00</form:option>
									<form:option value="01">01</form:option>
									<form:option value="02">02</form:option>
									<form:option value="03">03</form:option>
									<form:option value="04">04</form:option>
									<form:option value="05">05</form:option>
									<form:option value="06">06</form:option>
									<form:option value="07">07</form:option>
									<form:option value="08">08</form:option>
									<form:option value="09">09</form:option>
									<form:option value="10">10</form:option>
									<form:option value="11">11</form:option>
							</form:select>
							<form:select path="sTimeMinute">
									<form:option value="00">00</form:option>
									<form:option value="05">05</form:option>
									<form:option value="10">10</form:option>
									<form:option value="15">15</form:option>
									<form:option value="20">20</form:option>
									<form:option value="25">25</form:option>
									<form:option value="30">30</form:option>
									<form:option value="35">35</form:option>
									<form:option value="40">40</form:option>
									<form:option value="45">45</form:option>
									<form:option value="50">50</form:option>
									<form:option value="55">55</form:option>
							</form:select>
							<form:select path="sTimeAMPM">
								<form:option value="AM">AM</form:option>
								<form:option value="PM">PM</form:option>
							</form:select>
							~
							<form:input path="eDate" id="eDate" readonly="true" class="dateInput" style="width:70px;" />
							<form:select path="eTimeHour">
									<form:option value="00">00</form:option>
									<form:option value="01">01</form:option>
									<form:option value="02">02</form:option>
									<form:option value="03">03</form:option>
									<form:option value="04">04</form:option>
									<form:option value="05">05</form:option>
									<form:option value="06">06</form:option>
									<form:option value="07">07</form:option>
									<form:option value="08">08</form:option>
									<form:option value="09">09</form:option>
									<form:option value="10">10</form:option>
									<form:option value="11">11</form:option>
							</form:select>
							<form:select path="eTimeMinute">
									<form:option value="00">00</form:option>
									<form:option value="05">05</form:option>
									<form:option value="10">10</form:option>
									<form:option value="15">15</form:option>
									<form:option value="20">20</form:option>
									<form:option value="25">25</form:option>
									<form:option value="30">30</form:option>
									<form:option value="35">35</form:option>
									<form:option value="40">40</form:option>
									<form:option value="45">45</form:option>
									<form:option value="50">50</form:option>
									<form:option value="55">55</form:option>
							</form:select>
							<form:select path="eTimeAMPM">
								<form:option value="AM">AM</form:option>
								<form:option value="PM">PM</form:option>
							</form:select>
						</div>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</c:if>
	<c:if test="${!isReply }">
	<tr>
		<td class="td_le1"><spring:message code='t.posting.period' text='게시기간' /> <span class="readme"><b>*</b></span></td>
		<td class="td_le2" colspan=3>
			<form:input path="bbs.openDate" id="openDate" readonly="true" class="dateInput" style="width:65px;color:#919191;" />
			~
			<form:input path="bbs.closeDate" id="closeDate" readonly="true" class="dateInput" style="width:65px;" />
			
			&nbsp;<input type="checkbox" id="never" name="never"><spring:message code='t.permanent.post' text='영구게시' />
		</td>
	</tr>
	</c:if>
<%-- 	<tr<%=categoryTr %>> --%>
	<tr style="display:none;">
		<td class="td_le1"><spring:message code='t.category' text='게시판분류' /> <span class="readme"><b>*</b></span></td>
		<td class="td_le2" colspan=3>
			<form:select path="bbs.bbsId">
				<c:choose>
					<c:when test="${locale == 'ko' }">
						<form:options items="${bbsMasters }" itemValue="bbsId" itemLabel="titleKo" />
					</c:when>
					<c:when test="${locale == 'en' }">
						<form:options items="${bbsMasters }" itemValue="bbsId" itemLabel="titleEn" />
					</c:when>
					<c:when test="${locale == 'ja' }">
						<form:options items="${bbsMasters }" itemValue="bbsId" itemLabel="titleJa" />
					</c:when>
					<c:when test="${locale == 'zh' }">
						<form:options items="${bbsMasters }" itemValue="bbsId" itemLabel="titleZh" />
					</c:when>
					<c:otherwise>
						<form:options items="${bbsMasters }" itemValue="bbsId" itemLabel="title" />
					</c:otherwise>
				</c:choose>	
			</form:select>
		</td>
	</tr>
	<tr>
		<td class="td_le1"><spring:message code='t.subject' text='제 목' /> <span class="readme"><b>*</b></span></td>
		<td class="td_le2" colspan=3>
			<form:input path="bbs.subject" class="w100p" onkeydown="CheckTextCount(this, 120);" />
		</td>
	</tr>
	<tr style="display:none;">
		<td class="td_le1"><spring:message code='t.preservPeriod' text='보존년한' /></td>
		<td class="td_le2" colspan=3>
			<form:select path="bbs.preservePeriod.preserveId" cssClass="fld_100">
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
</table>

<div class="space"></div>
<!-- 웹에디터 삽입-->
<div>
	<jsp:include page="../common/daum_editor_control.jsp" flush="true" />
</div>

<div class="space"></div>
<!--  파일 첨부 컨트롤 삽입 -->
<c:if test ="${bbsMaster.attach}">
<%-- 	<%	if (isIE) { %> --%>
<%-- 	<jsp:include page="<%=attachURL%>" flush="true"> --%>
<%-- 		<jsp:param name="attachfiles" value="<%=fileAttachInfo.toString()%>"/> --%>
<%-- 		<jsp:param name="maxfilesize" value="${userConfig.uploadSize}"/> --%>
<%-- 		<jsp:param name="maxfilecount" value=""/> --%>
<%-- 	</jsp:include> --%>
<%-- 	<%	} else { %> --%>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<thead>
		<tr><th width="13%"></th>
		<th width="*">
	</th></tr>
	</thead>
	<tbody>
	<tr>
		<td class="td_le1" style="text-align:center; background:#ddecf7;"><spring:message code="t.attachfile" text="파일첨부" /><!-- 첨부 --></td>
		<td class="td_le2" align="center">
	<jsp:include page="../common/file_upload_control.jsp" flush="true">
		<jsp:param name="attachfiles" value="<%=fileAttachInfo.toString()%>"/>
		<jsp:param name="actionURL" value="./save.htm"/>
		<jsp:param name="baseURL" value="<%=baseURL%>"/>
		<jsp:param name="filepath" value="bbs"/>
	</jsp:include>
	</td>
	</tr>
	</tbody>
</table>
<%-- 	<%	} %> --%>
</c:if>

</td>
</tr>
</table>

</form:form>
</div>
</body>
</html>

