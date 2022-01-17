<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
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
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="nek3.service.impl.HibernateUtils" %>
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

	String cssPath = "../common/css";
	String imgCssPath = "/common/css/blue";
	String imagePath = "../common/images/blue";
	String scriptPath = "../common/script";
	String[] viewType = {"0"};

%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title></title>

<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.jqgrid.jsp"%>

<%@ include file="../common/include.common.jsp"%>

<!-- 
<link rel=STYLESHEET type="text/css" href="<%= cssPath %>/list_new.css">
<link rel="STYLESHEET" type="text/css" href="<%= imgCssPath %>">
<script src="<%=scriptPath %>/common.js"></script>
<script src="<%=scriptPath %>/list.js"></script>
<script src="<%=scriptPath %>/xmlhttp.vbs" language="vbscript"></script>

 -->
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
				frm.action = "/dms/list.jsp";
				break;
			case "view":
				frm.docId.value = docId;
				frm.action = "/dms/read.htm";
				break;
			case "all":
				frm.action = "/dms/bbs_list.jsp";
				frm.pg.value = "1";
				frm.searchtype.value = "0";
				frm.searchtext.value = "";
				break;
			case "new":
				frm.docId.value = docId;
				frm.action = "/dms/form.htm";
				break;
			<c:if test="${_isManager}">
			case "manage":
				frm.action = "/dms/bbs_manager_view.jsp";
				url = "./bbs_manager_view.jsp?bbsId=<c:out value='${bbsMaster.bbsId}' />";
				break;
			</c:if>

		}
		if(isNewWin == "true"){
			frm.useNewWin.value = true;
			var winName = "popup_" + popupWinCnt++;
			OpenWindow("about:blank", winName, "760", "610");
			frm.target = winName;
		} else {	//self
			var frms = $("#search").serialize();
			var url = frm.action + "?" + frms ;
			//var a = parent.ModalDialog({'t':'<spring:message code='t.doc.management' text='문서관리' />', 'w':800, 'h':500, 'm':'iframe', 'u':url, 'modal':false, 'd':true, 'r':false});
			
			parent.dhtmlwindow.open(
					url, "iframe", url, '<spring:message code="t.doc.management" text="문서관리"/>', 
					"width=800px,height=410px,resize=1,scrolling=1,center=1", "recal"
			);
			return;
		}

		frm.submit();
	}
	
	function onClickOpen(docId){
		//location.href="http://localhost/DHIERP2Mobile/dms/read.htm";
		location.href= request.getScheme() + "://localhost/DHIERP2Mobile/dms/read.htm";//개발, 운영 시 적용 (https 적용)
		/* var frm = document.forms[0];
		frm.docId.value = docId;
		frm.action = "<c:url value="/dms/read.htm" />";
		frm.submit(); */
	}
	
	function findDmses(){
		var searchKey = $("#searchKey").val();
		var searchValue = $("#searchValue").val();
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
		
		var reqUrl = "<c:url value="/dms/myList_data.htm" />" + "?searchKey=" + searchKey + "&searchValue=" + searchValue;
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
		$("#resetSearch").show();
		return true;
	}
</script>


<script type="text/javascript">
$(document).ready(function(){
	// 전체 그리드에 대해 적용되는 default
	$.jgrid.defaults = $.extend($.jgrid.defaults,{loadui:"enable",hidegrid:false,gridview:false});

	$("#dataGrid").jqGrid({        
	    scroll: true,
	   	url:"<c:url value="/dms/myList_data.htm" />",
		datatype: "json",
		//height: auto,
		width: '100%',
		height:'100%',
	   	colNames:['<spring:message code='t.category' />',
	   	  		  '<spring:message code='t.hotFlag' text='중요' />',
	   	          '<spring:message code='t.subject' />',
	   	          '<spring:message code='t.createDate' />',
	   	          '<spring:message code='t.writer' />',
	   	          '<spring:message code='t.attached' />',
	   	          '<spring:message code='t.readCnt' />'],
	   	colModel:[
			{name:'dmsCategory_.catFullName',index:'dmsCategory_.catFullName', width:100},
			{name:'hotFlag',index:'hotFlag', width:30},
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
// 	    sortname: 'createDate',
	    scroll:false,
		loadError:function(xhr,st,err) {
	    	$("#errorDisplayer").html("Type: "+st+"; Response: "+ xhr.status + " "+xhr.statusText);
	    },
	    loadComplete:function(data){
	    	/* jqGrid PageNumbering Trick */
	    	var i, myPageRefresh = function(e) {
	            var newPage = $(e.target).text();
	            grid.trigger("reloadGrid",[{page:newPage}]);
	            e.preventDefault();
	        };
	        
	    	/* MAX_PAGERS is Numbering Count. Public Variable : ex) 5 */
	        jqGridNumbering( $("#dataGrid"), this, i, myPageRefresh );
	
	    	if (data.rows.length == 0) {
            	ModalDialog({
            		't': '<spring:message code="alerts" text="알림"/>',
            		'c': '<p><spring:message code="t.not.registered" text="등록된 자료가 없습니다."/></p>',
            		'modal': false, 
            		'esc': true,
            		'b': { '<spring:message code="ok" text="확인"/>': function() { $(this).dialog('close'); } }
            	});
            }
	    }
	});
	
	$("#dataGrid").jqGrid('navGrid',"#dataGridPager",{search:false,edit:false,add:false,del:false});

	/* listResize */
	gridResize("dataGrid");
});

function search(){
	var searchKey = $("#searchKey").val();
	var searchValue = $("#searchValue").val();
	var reqUrl = "<c:url value="/dms/myList_data.htm?" />" + "searchKey=" + searchKey + "&searchValue=" + searchValue;
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

function resetSearch(){
	$("#search").each(function(){
		this.reset();
	});
	
	var reqUrl = "<c:url value="/dms/myList_data.htm" />";
	$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
	$("#resetSearch").hide();
}

</script>

</head>
<body style="overflow:hidden;">

<!-- List Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
<tr>
<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
	<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> <spring:message code="t.worksupport" text="업무지원"/> > <spring:message code="t.doc.management" text="문서관리"/> > <spring:message code="t.myDoc" text="내 문서"/></span>
</td>
<td width="40%" align="right">
<!-- n 개의 읽지않은 문서가 있습니다. -->
</td>
</tr>
</table>

<table width=100% border="0" cellspacing=0 cellpadding=0 class=mail_list_t style="height:35px;">
	<tr>
		<td width="*" style="padding-left:3px;">
		<a onclick="javascript:goSubmit('new','','');" class="button gray medium">
		<img src="../common/images/bb01.gif" border="0"> <spring:message code="t.newDoc" text="새문서"/> </a>

		<c:if test="${isManager}">
		<a onclick="javascript:goSubmit('manage','true','');" class="button white medium">
		<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.management" text="관리"/> </a>
		</c:if>				
		<td> 
		
		<td width="400" class="DocuNo" align="right" style="padding-rightㄴ:5px; ">

			<%
			//<form:option> 내부에 <spring:message> 를 사용할 수 없으므로 부득이 여기서 변수를 선언한다. 2011.08.17 김화중
			String searchKey = ((nek3.web.form.SearchBase)request.getAttribute("search")).getSearchKey();
			%>
			<form:form commandName="search">
				<form:select path="searchKey">
					<option value=""><spring:message code="t.choice" text="선택"/></option>
					<option value="subject" <%= setSelectedOption("subject",searchKey) %>><spring:message code="t.subject" /></option>
					<option value="writer_.nName" <%= setSelectedOption("writer_.nName",searchKey) %>><spring:message code="t.writer" /></option>
					<option value="dmsCategory_.catName" <%= setSelectedOption("dmsCategory_.catName",searchKey) %>><spring:message code="t.category" text="분류"/></option>
				</form:select>
				<form:input style="width:100px;" path="searchValue" />
				<form:hidden path="docId" /><form:hidden path="useNewWin" /><form:hidden path="useAjaxCall" />

			<img src="/common/images/btn_search.gif" align="absmiddle" onclick="javascript:findDmses();" alt="검색" />
			
			<span id="resetSearch" style="display:none;">
			<a onclick="javascript:resetSearch();" class="button white medium">
			<img src="../common/images/bb02.gif" border="0"> <fmt:message key="t.search.del"/>&nbsp;<!-- 검색제거 --> </a>
			</span>
			</form:form>						
		</td>
	</tr>
</table>

<table id="dataGrid"></table>
<div id="dataGridPager"></div>
<div id="dataGridPagerNumber" style="text-align:center;">Page Numbering</div>
<span id="errorDisplayer" style="color:red"></span>

</body>
</html>
<script>

function ShowAttach( docid, fileno ) {
	winx = window.event.x-265;
	winy = window.event.y-40;
	//var url = "/notification/bbs_download_attach_info.jsp?noteid=" + uid;
	var url = "/dms/dms_download_attach_info.jsp?docid=" + docid + "&fileno=" + fileno;
	xmlhttpRequest( "GET", url , "afterShowAttach" ) ;
}
</script>

