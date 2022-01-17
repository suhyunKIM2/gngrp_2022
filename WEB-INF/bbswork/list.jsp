<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
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

// 	String cssPath = "../common/css";
// 	String imgCssPath = "/common/css/blue";
// 	String imagePath = "../common/images/blue";
// 	String scriptPath = "../common/script";
// 	String[] viewType = {"0"};

%>

<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title><c:out value="${bbsMaster.title}" /></title>

<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.jqgrid.jsp"%>

<%@ include file="../common/include.common.jsp"%>
<%@ include file="../common/include.script.map.jsp" %>

<!-- gtip2 -->
<link rel="stylesheet" type="text/css" media="screen" href="/common/libs/jquery-qtip2/2.0.0/jquery.qtip.min.css" />
<script src="/common/libs/jquery-qtip2/2.0.0/jquery.qtip.min.js" type="text/javascript"></script>

<!-- dhtmlwindow 2012-11-15 -->
<link rel="stylesheet" href="/common/libs/dhtmlwindow/1.1/dhtmlwindow.css" type="text/css" />
<script type="text/javascript" src="/common/libs/dhtmlwindow/1.1/dhtmlwindow.js"></script>

<!-- dhtmlmodal 2013-03-11 -->
<link rel="stylesheet" href="/common/libs/dhtmlmodal/1.1/modal.css" type="text/css" />
<script type="text/javascript" src="/common/libs/dhtmlmodal/1.1/modal.js"></script>

<script type="text/javascript">

	function findBbses(){
		var searchKey = $("#searchKey").val();
		var searchValue = $("#searchValue").val();
		if($.trim(searchValue) == ""){
			//alert("<spring:message code='v.query.required' text='검색어를 입력하여 주십시요!' />");
			$("#searchValue").focus();
			return false;
		}

		if ($.trim(searchKey) == "") {
			document.getElementById("searchKey").selectedIndex = 1;
		}
		
		//var reqUrl = "<c:url value="/bbswork/list_data.htm?bbsId=${search.bbsId}" />" + "&searchKey=" + searchKey + "&searchValue=" + searchValue;
		var reqUrl = "<c:url value="/bbswork/list_data.htm?" />" + $("#search").serialize();
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
		$("#resetSearch").show();
		return true;
	}

	function reloadBbses(){
		var reqUrl = "/bbswork/list_data.htm?" + $("#search").serialize();
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
		return true;
	}
	
	function resetBbsSearch(){
		$("#search").each(function(){
			this.reset();
		});
		
		var reqUrl = "/bbswork/list_data.htm?" + $("#search").serialize();
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
		$("#resetSearch").hide();
	}

	var popupWinCnt = 0;
	function goSubmit(cmd, isNewWin ,docId){
		var frm = document.getElementById("search");
		frm.method = "GET";
		switch(cmd){
			case "view":
				frm.action = "/bbswork/read.htm";
				frm.docId.value = docId;
				break;
			case "new":
				frm.docId.value = "";
				frm.action = "/bbswork/form.htm";
				break;
			<c:if test="${isManager or isAdmin}">
			case "manage":
				if($("#workType").val()=="2"){
					frm.action = "/project/admin_form.htm";
				}else{
					frm.action = "/bbswork/admin_form.htm";
				}
				break;
			</c:if>
			default:
				return;
				break;
		}

		if(isNewWin == "true"){
			var winName = "popup_" + popupWinCnt++;
			if($("#workType").val()=="2"&&cmd=="manage"){
				OpenWindow("about:blank", winName, "400", "500");
			}else{
				OpenWindow("about:blank", winName, "820", "610");
			}
			frm.useNewWin.value = true;
			frm.useLayerPopup.value = false;
			frm.target = winName;
		} else {	//self
// 			frm.useNewWin.value = false;
// 			frm.useLayerPopup.value = true;
			var formData = $("#search").serialize();
			var url = frm.action + "?" + formData;
			
			if($("#workType").val()=="2"&&cmd=="manage"){
				OpenWindow(url, "<c:out value="${bbsMaster.title}" />", "400", "500");
			}else{
				
// 	 			dhtmlwindow.open(
// 					url, "iframe", url, "<c:out value="${bbsMaster.title}" />", 
// 					"width=" + winWidth + "px,height=" + winHeight + "px,resize=" + winResize + ",scrolling=" + winScroll + ",center=" + winCenter, "recal"
// 				);
				OpenWindow(url, "<c:out value="${bbsMaster.title}" />", winWidth, winHeight);
// 	 			var objWin = OpenLayer(url, "<c:out value="${bbsMaster.title}" />", winWidth, winHeight,isWindowOpen);	//opt는 top, current

				return;
				//OpenWindow(url, "<c:out value="${bbsMaster.title}" />", "800", "500");
			}
			 
// 			parent.dhtmlwindow.open(
// 					url, "iframe", url, "<c:out value="${bbsMaster.title}" />", 
// 					"width=800px,height=500px,resize=1,scrolling=1,center=1", "recal"
// 			);
			//parent.ModalDialog({'t':'<c:out value="${bbsMaster.title}" />', 'w':800, 'h':600, 'm':'iframe', 'u':url, 'modal':false, 'd':true, 'r':false });
			return;
		}
		frm.submit();
	}
/*
	function ShowAttach(bbsId, docId ) {
		var img = $(event.srcElement);
		winx = img.position().top + 20;
		winy = img.position().left - 352;
		
		//winx = window.event.x-265;
		//winy = window.event.y-40;
		var url = "<c:url value="/bbswork/download_attach_info.htm?bbsId=" />" + bbsId + "&docId=" + docId;
		ajaxRequest("GET", "", url, showAttachCompleted);
	}

	function showAttachCompleted(data, textStatus, jqXHR) {
		wid = 250 ;
		hei = 105;

		//var p = $("p:first");
		//p.text("left : " + p.position().left + " | top : " + p.position().top);
		//여기서 결과는 20 20

		//var p = $("p:first");
		//p.text("left : " + p.offset().left + " | top : " + p.offset().top);
		//여기서 결과는 35 20
		
		
		ModalDialog({'t':'<spring:message code='t.download' text='다운로드' />', 'lp':winy, 'tp':winx, 'w':350, 'h':170, 'm':'html', 'c':data, 'modal':false, 'd':false, 'r':false });
		
		//oPopup is declared in common.js
// 		if(window.createPopup){
// 			oPopup = window.createPopup();
// 			var oPopupBody = oPopup.document.body;
// 			oPopupBody.innerHTML = data ;
// 			oPopup.show(winx, winy, wid, hei , document.body);
// 		} else {
// 			var features = "height=" + hei + ",width=" + wid + ",left=" + winx + ",top=" + winy + 
// 				",titlebar=no,menubar=no,scrollbars=no,status=no,location=no"
// 			oPopup = window.open("about:blank", "oPopup", features);
// 			oPopup.document.body.innerHTML = data;
// 		}
		
	}
*/
	function attach_down(docId, fileNo) {
		location.href =  "<c:url value="/bbswork/download.htm?" />" + "bbsId=bbswork&docId=" + docId + "&fileNo=" + fileNo;   
	}
	
	function listShowAttach() {
	     // Make sure to only match links to wikipedia with a rel tag
	    var strUrl = "/bbswork/download_attach_info.htm?";
    	$('[name=listAttach]').each(function()
    	{
    		// We make use of the .each() loop to gain access to each element via the "this" keyword...
    		$(this).qtip(
    		{
    			content: {
    				// Set the text to an image HTML string with the correct src URL to the loading image you want to use
    				//text: '<img class="throbber" src="/projects/qtip/images/throbber.gif" alt="Loading..." />',
    				text: 'loading...',
    				ajax: {
    					url: strUrl + $(this).attr('rel') // Use the rel attribute of each element for the url to load
    				},
    				title: {
    					//text: 'Download Files - ' + $(this).text(), // Give the tooltip a title using each elements text
    					text: 'Download Files', // Give the tooltip a title using each elements text
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
					width:250
    			}
    		})
    	})
     
    	// Make sure it doesn't follow the link when we click it
    	.click(function(event) { event.preventDefault(); });
	}
	
	function ShowUserInfoSet() {
	     // Make sure to only match links to wikipedia with a rel tag
	     var strUrl = "../common/userinfo.htm?userId=" ;

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

$(document).ready(function(){
	<c:choose>
	<c:when test="${search.onSearch}">
		$("#resetSearch").show();
	</c:when>
	<c:otherwise>
		resetBbsSearch();
	</c:otherwise>
	</c:choose>
	
	$("#search").submit(function(){
		return findBbses();
	});
	
	
	// 전체 그리드에 대해 적용되는 default
	$.jgrid.defaults = $.extend($.jgrid.defaults,{loadui:"enable",hidegrid:false,gridview:false});

	//var tmp = $(userConfig.listPPage);
	grid = $("#dataGrid");
	//MAX_PAGERS = 20;
// 	,MAX_PAGERS = ${userConfig.listPPage};
	//,MAX_PAGERS = 5;
	
	grid.jqGrid({        
	   	url:"/bbswork/list_data.htm?" + $("#search").serialize(),
		datatype: "json",
		width: '100%',
		height:'100%',
	   	colNames:['No',
	   	          '<spring:message code='t.subject' />',
	   	          '<spring:message code='t.posting.period' />',
	   	          '<spring:message code='t.createDate' />',
	   	          '<spring:message code='t.writer' />',
	   	          '<spring:message code='t.attached' />',
	   	          '<spring:message code='t.readCnt' />'],
	   	colModel:[
  	   		{name:'docSeq',index:'docSeq', width:30, align:"center"},
	   		{name:'subject',index:'subject', width:400},
	   		{name:'postingPeriod',index:'postingPeriod', width:180, align:"center", sortable:false},
	   		{name:'createDate',index:'createDate', width:120, align:"center"},
	   		{name:'writerName',index:'writerName', width:80, align:"center"},
	   		{name:'fileCnt',index:'fileCnt', width:30, align:"center"},
	   		{name:'readCnt',index:'readCnt', width:30, align:"center"},
		],
 	   rowNum:${userConfig.listPPage},
	   	mtype: "GET",
		prmNames: {search:null, nd: null, rows: null, page: "pageNo", sort: "sortColumn", order: "sortType"},  
	   	pager: '#dataGridPager',
	    viewrecords: true,
// 	    sortname: 'createDate',
// 	    sortorder: 'desc',
	    scroll: false,
	    pginput: true,
	    gridview:true,
	    shrinkToFit: true,
	    /*
	    onSelectRow: function(id){
	    	goSubmit('view', 'true', id);
	    },
	    */
	    
		loadError:function(xhr,st,err) {
	    	$("#errorDisplayer").html("Type: "+st+"; Response: "+ xhr.status + " "+xhr.statusText);
	    },

	    loadComplete: function(data) {
	    	/* jqGrid PageNumbering Trick */
	    	var i, myPageRefresh = function(e) {
	            var newPage = $(e.target).text();
	            grid.trigger("reloadGrid",[{page:newPage}]);
	            e.preventDefault();
	        };
	        //jqGrid('getGridParam','url'))
	        	
	    	/* MAX_PAGERS is Numbering Count. Public Variable : ex) 5 */
	        jqGridNumbering( grid, this, i, myPageRefresh );
	
	        listShowAttach();
	        
	        ShowUserInfoSet();
	    }
	});
	
	$("#dataGrid").jqGrid('navGrid',"#dataGridPager",{search:false,edit:false,add:false,del:false});

	/* listResize */
	gridResize("dataGrid");

	$('#searchValue').keydown(function(event) {
		if (event.which == 13) {
			event.preventDefault();
			findBbses();
		}
	});
});
</script>
<style>
.ui-jqgrid tr.jqgrow td{padding-left:0 !important;}
</style>
</head>

<body style="overflow:hidden; background:#f2f2f2;">
<form:form commandName="search" onsubmit="return false;">
	<form:hidden path="docId" />
	<form:hidden path="bbsId" />
	<form:hidden path="workType" />
	<form:hidden path="moduleId" />
<%-- 	<form:hidden path="useNewWin" /> --%>
<%-- 	<form:hidden path="useAjaxCall" /> --%>
<%-- 	<form:hidden path="useLayerPopup" /> --%>

<!-- List Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
<tr>
	<td width="60%" style="padding-left:5px; padding-top:5px; ">
		<!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
		<span class="ltitle">
			<img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" />
			<spring:message code="bbs.community" text="커뮤니티"/> &gt;
			<spring:message code="main.Work.Board" text="업무게시판"/>
		</span>
	</td>
	<td width="40%" align="right"><!-- n 개의 읽지않은 문서가 있습니다. --></td>
</tr>
</table>

<!-- List Button -->
<table width=100% border="0" cellspacing=0 cellpadding=0 style="height:35px;">
	<tr>
		<td width="*" style="padding-left:3px;">
			<span onclick="goSubmit('new','','')" class="button gray medium">
			<img src="../common/images/bb01.gif" border="0"> <spring:message code="t.newDoc" text="새문서"/> </span>
			
			<form:select path="searchRange" onchange="reloadBbses()">
				<form:option value="0"><spring:message code="t.all" text="전체"/></form:option>
				<form:option value="1"><spring:message code="t.posting" text="게시중"/></form:option>
				<form:option value="2"><spring:message code="t.posting.complete" text="게시완료"/></form:option>
			</form:select>
		</td>
		<td width="400" class="DocuNo" align="right" style="padding-right:5px; ">
			<form:select path="searchKey" id="searchKey" style="width:80px;">
				<form:option value="subject"><spring:message code="t.subject" text="제목" /></form:option>
				<form:option value="writer_.nName"><spring:message code="t.writer" text="작성자" /></form:option>
				<form:option value="content"><spring:message code="t.content" text="내용" /></form:option>
			</form:select>
			
			<form:input style="width:100px" path="searchValue" />
			
			<span onclick="findBbses()" class="button white medium">
			<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.search" text="검색" /> </span>
			
			<span id="resetSearch" onclick="resetBbsSearch()" class="button white medium">
			<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.search.del" text="검색제거" /> </span>
			</span>
		</td>
	</tr>
</table>
<!-- List Button -->

<table id="dataGrid"></table>
<div id="dataGridPager"></div>
<span id="errorDisplayer" style="color:red"></span>

</form:form>

</body>
</html>
