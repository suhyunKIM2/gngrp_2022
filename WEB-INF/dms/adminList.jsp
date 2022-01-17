<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%--@ page errorPage="../error.jsp" --%>
<%@ page import="java.util.*"%>
<%@ page import="nek.common.*"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="nek3.service.impl.HibernateUtils"%>
<%!private final static long DAY_TIME = 86400000;

	private String setSelectedOption(int i1, int i2) {
		String selectStr = "";
		if (i1 == i2)
			selectStr = "selected";
		return selectStr;
	}

	private String setSelectedOption(String str1, String str2) {
		String selectStr = "";
		if (str1.equals(str2))
			selectStr = "selected";
		return selectStr;
	}

	String cssPath = "../common/css";
	String imgCssPath = "/common/css/blue";
	String imagePath = "../common/images/blue";
	String scriptPath = "../common/scripts";
	String[] viewType = {"0"};%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title></title>

<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.jqgrid.jsp"%>

<%@ include file="../common/include.common.jsp"%>

<!-- gtip2 -->
<link rel="stylesheet" type="text/css" media="screen"
	href="/common/libs/jquery-qtip2/2.0.0/jquery.qtip.min.css" />
<script src="/common/libs/jquery-qtip2/2.0.0/jquery.qtip.min.js"
	type="text/javascript"></script>

<!-- dhtmlwindow 2012-11-15 -->
<link rel="stylesheet"
	href="/common/libs/dhtmlwindow/1.1/dhtmlwindow.css" type="text/css" />
<script type="text/javascript"
	src="/common/libs/dhtmlwindow/1.1/dhtmlwindow.js"></script>

<!-- dhtmlmodal 2013-03-11 -->
<link rel="stylesheet" href="/common/libs/dhtmlmodal/1.1/modal.css"
	type="text/css" />
<script type="text/javascript"
	src="/common/libs/dhtmlmodal/1.1/modal.js"></script>

<script src="<%=scriptPath%>/common.js"></script>
<script src="<%=scriptPath%>/list.js"></script>
<script src="<%=scriptPath%>/xmlhttp.vbs" language="vbscript"></script>
<script language=javascript>
	var targetWin;

	function searchValidation()
	{
		if(TrimAll(document.all.searchtext.value) == ""){
			alert("<spring:message code='v.query.required' text='검색어를 입력하여 주십시요!' />");
			document.all.searchtext.focus();
			return false;
		}

		var option = document.all.searchtype.options;
		if (document.all.searchtype.value < 1) {
			alert("<spring:message code='v.queryType.requried' text='검색 분류를  선택하여 주십시요!' />");
			option.focus() ;
			return false;
		}
		return true;
	}
	var popupWinCnt = 0;	
	function goSubmit(cmd, isNewWin ,docId)
	{
		var frm = document.getElementById("search");
		var url = "";
		switch(cmd)
		{
			case "search":
				if(!searchValidation()) return;
				frm.pg.value = "1";
				frm.action = "/dms/list.htm";
				break;
			case "view":
				frm.docId.value = docId;
				frm.action = "/dms/read.htm";
				break;
			case "all":
				frm.action = "/dms/list.htm";
				frm.pg.value = "1";
				frm.searchtype.value = "0";
				frm.searchtext.value = "";
				break;
			case "new":
				frm.docId.value = docId;
				frm.action = "/dms/form.htm?listMode=<c:out value='${search.listMode}'/>&catId=<c:out value='${search.catId}'/>";
				break;
			<c:if test="${_isManager}">
			case "manage":
				frm.action = "./bbs_manager_view.jsp";
				url = "./bbs_manager_view.jsp?bbsId=<c:out value='${bbsMaster.bbsId}' />";
				break;
			</c:if>

		}
		var vtitle = '<spring:message code="t.doc.management" text="문서관리"/>';
		if(isNewWin == "true"){
			frm.useNewWin.value = true;
			var winName = "popup_" + popupWinCnt++;
			OpenWindow("about:blank", winName, "790", "610");

// 			parent.dhtmlwindow.open(
// 					url, "iframe", url, '<spring:message code="t.doc.management" text="문서관리"/>', 
// 					"width=800px,height=500px,resize=1,scrolling=1,center=1", "recal"
// 			);
			frm.target = winName;
		} else {	//self
			var frms = $("#search").serialize();
			var isChk = (frm.action.indexOf("?") > -1);
			var url = frm.action + (isChk ? "&" : "?" ) + frms ;
			
			OpenWindow(url, winName, "790", "610");
// 			var objWin = OpenLayer(url, vtitle, winWidth, winHeight);
			/*
			parent.dhtmlwindow.open(
					url, "iframe", url, '<spring:message code="t.doc.management" text="문서관리"/>', 
					"width=800px,height=410px,resize=1,scrolling=1,center=1", "recal"
			);
			
			//parent.ModalDialog({'t':'<spring:message code="t.doc.management" text="문서관리"/>', 'w':800, 'h':400, 'm':'iframe', 'u':url, 'modal':false, 'd':true, 'r':false });
			//var a = parent.ModalDialog({'t':'문서관리', 'w':800, 'h':600, 'm':'iframe', 'u':url, 'modal':false});
			*/
			return;
		}

		frm.submit();
	}
	
	function onClickOpen(docId){
		//location.href="http://localhost:81/dms/read.htm";
		location.href=request.getScheme()+"://localhost:81/dms/read.htm"; //개발, 운영 시 적용 (https 적용)
		/* var frm = document.forms[0];
		frm.docId.value = docId;
		frm.action = "<c:url value="/dms/read.htm" />";
		frm.submit(); */
	}
	function goNewDoc(){
		//location.href="http://localhost:81/dms/form.htm";
		location.href=request.getScheme()+"://localhost:81/dms/form.htm"; //개발, 운영 시 적용 (https 적용)
	}
	
	function resetSearch(){
		$("#search").each(function(){
			this.reset();
		});
		var cateType = $("#search.cateType").val();
		var reqUrl = "<c:url value="/dms/adminList_data.htm" />" + "?cateType=" + cateType + "&catId=<c:out value="${search.catId}" />";
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
		$("#resetSearch").hide();
	}
	
	function findDmses(){
		var searchKey = $("#searchKey").val();
		var searchValue = $("#searchValue").val();
		var cateType = $("#search.cateType").val();
		if($.trim(searchValue) == ""){
			alert("<spring:message code='v.query.required' text='검색어를 입력하여 주십시요!' />");
			$("#searchValue").focus();
			return false;
		}
		if ($.trim(searchKey) == "") {
			alert("<spring:message code='v.queryType.requried' text='검색 분류를  선택하여 주십시요!' />");
			$("#searchKey").focus();
			return false;
		}
		
		var reqUrl = "<c:url value="/dms/adminList_data.htm" />" + "?searchKey=" + searchKey + "&searchValue=" + encodeURIComponent(searchValue) + "&cateType=" + cateType;
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
		$("#resetSearch").show();
		return true;
	}

	function listShowAttach() {
	     // Make sure to only match links to wikipedia with a rel tag
	    //var strUrl = "/bbs/download_attach_info.htm?";

	    var strUrl = "/dms/dms_download_attach_info.jsp?";
	    
   	$('[name=listAttach]').each(function()
   	{
   		// We make use of the .each() loop to gain access to each element via the "this" keyword...
   		$(this).qtip({
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
	
	//문서 다중삭제 (관리자 전용)
	function goDelete(){
		var selRow = $("#dataGrid").jqGrid('getGridParam','selarrrow');
		if(selRow == ""){
			alert("<spring:message code='c.del.select.required' text='삭제할 문서를 선택 하세요.'/>");
			return;
		}
		
		if (!confirm("<spring:message code='t.perfect.delete.alert' text='삭제 후에는 문서를 복구 할 수 없습니다.'/>\n\n<spring:message code='c.delete' text='정말 삭제 하시겠습니까?' />")) return false;
		
		$.ajax({
			url : '/dms/multiDelete.htm',
			type : 'post',
			datatype:"json",
			data : {
				"docId" : selRow.toString()
			},
 			beforeSend: function() { waitMsg(); },
 			complete: function() { $.unblockUI(); },
			success : function(data) {
				if(data.result == "O"){	//Success
					alert("<spring:message code='i.delete.success' text='삭제 완료 되었습니다.'/>");
					$("#dataGrid").trigger("reloadGrid",[{page:1}]);
				}
			}
		});

	}
</script>

<script type="text/javascript">
$(document).ready(function(){
	cAdmin = new Boolean(false);	//관리자 확인	(삭제버튼 공개여부)
	cAdmin = "${isAdmin}" == "true" ? true : false;
	
	// 전체 그리드에 대해 적용되는 default
	$.jgrid.defaults = $.extend($.jgrid.defaults,{loadui:"enable",hidegrid:false,gridview:false});
	$("#dataGrid").jqGrid({
	    scroll: true,
	   	url:"<c:url value="/dms/adminList_data.htm" />?catId=<c:out value="${search.catId}" />&cateType=<c:out value="${search.cateType}" />",
		datatype: "json",
		//height: auto,
		width: '100%',
		height:'100%',
		
	   	colNames:[
	   	          //'<spring:message code='t.category' />',
				  '<spring:message code='t.hotFlag' text='' />',
				  '<spring:message code='t.openFlag' text='' />',
	   	          '<spring:message code='t.subject' />',
	   	          '<spring:message code='t.createDate' />',
	   	          '<spring:message code='t.writer' />',
	   	          '<spring:message code='t.attached' />',
	   	          '<spring:message code='t.readCnt' />'],
	   	colModel:[
// 	   		{name:'dmsCategory_.catFullName',index:'dmsCategory_.catFullName', width:200},
	   		{name:'hotFlag',index:'hotFlag', width:45, align:'center'},
	   		{name:'openFlag',index:'openFlag', width:30, align:'center'},
	   		{name:'subject',index:'subject', width:550},
	   		{name:'createDate',index:'createDate', width:120, align:'center'},
	   		{name:'uUser_.nName',index:'uUser_.nName', width:80, align:'center'},
	   		{name:'fileCnt',index:'fileCnt', width:30, align:'center'},
	   		{name:'readCnt',index:'readCnt', width:30, align:'center'},
		],	
	   	rowNum: '${userConfig.listPPage}',
	   	mtype: "GET",	
		prmNames: {search:null, nd: null, rows: null, page: "pageNo", sort: "sortColumn", order: "sortType"},  
		pager: '#dataGridPager',
	    viewrecords: true,
	    scroll:false,
	    multiselect: cAdmin,
		loadError:function(xhr,st,err) {
	    	$("#errorDisplayer").html("Type: "+st+"; Response: "+ xhr.status + " "+xhr.statusText);
	    },
	    loadComplete: function(data) {
	    	/* jqGrid PageNumbering Trick */
	    	var i, myPageRefresh = function(e) {
	            var newPage = $(e.target).text();
	            $("#dataGrid").trigger("reloadGrid",[{page:newPage}]);
	            e.preventDefault();
	        };
	        
	    	/* MAX_PAGERS is Numbering Count. Public Variable : ex) 5 */
	        jqGridNumbering( $("#dataGrid"), this, i, myPageRefresh );
	
			// 첨부파일 
// 	        listShowAttach();
			$('[name=listAttach]').css({"cursor":"default"});
	        
	        ShowUserInfoSet();

	    }
	});
	
	$("#dataGrid").jqGrid('navGrid',"#dataGridPager",{search:false,edit:false,add:false,del:false});

	/* listResize */
	gridResize("dataGrid");

	$('input[name=searchValue]').bind("keypress", function(event) {
		switch(event.keyCode) {
			case jQuery.ui.keyCode.ENTER: 
				findDmses();
				event.preventDefault();
				break;
		}
	});
});

function search(){
	var searchKey = $("#searchKey").val();
	var searchValue = $("#searchValue").val();
	var cateType = $("#search.cateType").val();
	
	var reqUrl = "<c:url value="/dms/adminList_data.htm?" />" + "searchKey=" + searchKey + "&searchValue=" + searchValue + "&cateType=" + cateType;
	$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
}

$(function() {
	$("#dataFinder").accordion({
		collapsible: true,
		change:function(event, ui){
			//alert("changed");
		}
	});
});

</script>

</head>
<body style="overflow: hidden;">
	<!-- List Title -->
	<table border="0" cellpadding="0" cellspacing="0" width="100%"
		style="background-image: url(../common/images/bg_teamtitleOn.gif); position: relative; lefts: -1px; height: 37px; z-index: 100;">
		<tr>
			<td width="60%" style="padding-left: 5px; padding-top: 5px;">
				<!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
				<span class="ltitle"><img align="absmiddle"
					src="/common/images/icons/title-list-blue-folder2.png" /> <spring:message code="t.doc.management" text="문서관리" /> &gt; <spring:message code="dms.document.list" text="문서목록"/> 
					</span>
			</td>
			<td width="40%" align="right">
				<!-- n 개의 읽지않은 문서가 있습니다. -->
			</td>
		</tr>
	</table>

	<table width=100% border="0" cellspacing=0 cellpadding=0
		class=mail_list_t style="height: 35px;">
		<tr>
			<td width="*" style="padding-left: 3px;">
				<a onclick="javascript:goSubmit('new','','');" class="button gray medium"> 
					<img src="../common/images/bb01.gif" border="0"><spring:message code="t.newDoc" text="새문서" />
				</a> 
				<c:if test="${isManager}">
					<a onclick="javascript:goSubmit('manage','true','');" class="button white medium"> 
						<img src="../common/images/bb02.gif" border="0"><spring:message code="t.management" text="관리" />
					</a>
				</c:if> <c:if test="${isAdmin }">
					<a onclick="javascript:goDelete();" class="button white medium">
						<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.delete" text="삭제" />
					</a>
				</c:if>
			<td>
			<td width="400" class="DocuNo" align="right"
				style="padding-rightㄴ: 5px;">
				<%
					//<form:option> 내부에 <spring:message> 를 사용할 수 없으므로 부득이 여기서 변수를 선언한다. 2011.08.17 김화중
					String searchKey = ((nek3.web.form.SearchBase) request.getAttribute("search")).getSearchKey();
				%> <form:form commandName="search">
					<form:select path="searchKey">
						<%-- <option value=""><spring:message code="t.choice" text="선택"/></option> --%>
						<option value="subject" <%=setSelectedOption("subject", searchKey)%>>
							<spring:message code="t.subject" />
						</option>
						<option value="writer_.nName" <%=setSelectedOption("writer_.nName", searchKey)%>>
							<spring:message code="t.writer" />
						</option>
						<option value="dmsCategory_.catName" <%=setSelectedOption("dmsCategory_.catName",searchKey)%>>
							<spring:message code="t.category" text="분류"/> </option>
						<option value="keyword" <%=setSelectedOption("keyword", searchKey)%>>
							<spring:message code="t.searchValue" />
						</option>
					</form:select>
					<form:input style="width:100px;" path="searchValue" />
					<form:hidden path="docId" />
					<form:hidden path="useNewWin" />
					<form:hidden path="useAjaxCall" />
					<form:hidden path="cateType" />

					<a onclick="javascript:findDmses();" class="button gray medium">
						<img src="../common/images/bb01.gif" border="0"> <spring:message code="t.search" text="검색" />
					</a>
					<span id="resetSearch" style="display: none;">
						<a onclick="javascript:resetSearch();" class="button white medium">
							<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.search.del" text="검색제거"/>&nbsp;
						</a>
					</span>
				</form:form>
			</td>
		</tr>
	</table>


	<table id="dataGrid"></table>
	<div id="dataGridPager"></div>
	<span id="errorDisplayer" style="color: red"></span>

</body>
</html>

