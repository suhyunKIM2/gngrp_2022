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
	String scriptPath = "../common/scripts";
	String[] viewType = {"0"};

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title></title>

<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.jqgrid.jsp"%>

<%@ include file="../common/include.common.jsp"%>

<script src="<%=scriptPath %>/common.js"></script>
<script src="<%=scriptPath %>/list.js"></script>
<script src="<%=scriptPath %>/xmlhttp.vbs" language="vbscript"></script>
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
	function goSubmit(cmd, isNewWin ,docId, hisNo)
	{
		var frm = document.getElementById("search");
		var url = "";
		switch(cmd)
		{
			case "search":
				if(!searchValidation()) return;
				frm.pg.value = "1";
				frm.action = "./list.htm";
				break;
			case "view":
				frm.docId.value = docId;
				frm.hisNo.value = hisNo;
				frm.action = "./history_read.htm";
				break;
			case "all":
				frm.action = "./list.htm";
				frm.pg.value = "1";
				frm.searchtype.value = "0";
				frm.searchtext.value = "";
				break;
			case "new":
				frm.docId.value = docId;
				frm.action = "form.htm?listMode=<c:out value='${search.listMode}'/>";
				break;
			<c:if test="${_isManager}">
			case "manage":
				frm.action = "./bbs_manager_view.jsp";
				url = "./bbs_manager_view.jsp?bbsId=<c:out value='${bbsMaster.bbsId}' />";
				break;
			</c:if>

		}
		if(isNewWin == "true"){
			frm.useNewWin.value = true;
			var winName = "popup_" + popupWinCnt++;
			OpenWindow("about:blank", winName, "790", "610");
			frm.target = winName;
		} else {	//self
			var frms = $("#search").serialize();
			var url = frm.action + "?" + frms ;
			parent.ModalDialog({'t':'<spring:message code="t.doc.management" text="문서관리"/>', 'w':800, 'h':400, 'm':'iframe', 'u':url, 'modal':false, 'd':true, 'r':false });
			return;
		}

		frm.submit();
	}
	
	function resetSearch(){
		$("#search").each(function(){
			this.reset();
		});
		
		var reqUrl = "<c:url value="/dms/history_list_data.htm" />";
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
		$("#resetSearch").hide();
	}
	function removeDocument(){
		var docid = ""; 	//docId
		var hisno = "";	//hisNo
		var selRow = $("#dataGrid").jqGrid('getGridParam','selarrrow') + "";
		var selectRow = selRow.split(",");	//선택한 ID값
		
		if (selectRow.length < 0) {
			alert("<spring:message code='mail.c.notDoc.selected' text='선택된 문서가 없습니다'/>");
			return; 
		}
		
		if (!confirm(selectRow.length + "<spring:message code='sch.c.select.delete2' text='개의 문서를 삭제 하시겠습니까?'/>")) return;
		
		for(var i=0 ; i<selectRow.length ; i++){
			docid += docid != "" ? "," : "";
			docid += $("#dataGrid").jqGrid("getCell", selectRow[i], 'docId');
			hisno += hisno != "" ? "," : "";
			hisno += $("#dataGrid").jqGrid("getCell", selectRow[i], 'hisNo');
		}
		
		$.ajax({ 
	        url: '/dms/removeHistory.htm',
	        type: 'post' ,dataType: 'json' ,async: true,
	    	data: { 
	    			"docids": docid,
	    			"hisnos":hisno
	    		   },
	        beforeSend: function() { waitMsg(); },
	        complete: function(){ $.unblockUI(); },
	        success: function(data, status, xhr) {
	        	$("#dataGrid").trigger("reloadGrid"); 
	        	alert(data.removeCnt+"<spring:message code='i.delete.success' text='건이 삭제 되었습니다.'/>");
	        },
	        error: function(xhr, status, error) { $.unblockUI(); }
	    });
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
		
		var reqUrl = "<c:url value="/dms/history_list_data.htm" />" + "?searchKey=" + searchKey + "&searchValue=" + searchValue;
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1});
		$("#dataGrid").trigger("reloadGrid");
		$("#resetSearch").show();
		return;
	}
</script>

<script type="text/javascript">
$(document).ready(function(){
	// 전체 그리드에 대해 적용되는 default
//	$.jgrid.defaults = $.extend($.jgrid.defaults,{loadui:"enable",hidegrid:false,gridview:false});
	$.jgrid.defaults = $.extend($.jgrid.defaults,{loadui:"enable",hidegrid:false});
	var grid = $("#dataGrid");
	var emptyMsgDiv = $("<div style='width:100%;height:100%;position:relative;'><div style='position:absolute;top:50%;margin-top:-5em;width:100%;text-align:center;'><spring:message code='t.not.registered' text='등록된 자료가 없습니다.' /></div></div>");

	$("#dataGrid").jqGrid({        
	   	url:"<c:url value="/dms/history_list_data.htm" />?catId=<c:out value="${search.catId}" />",
		datatype: "json",
		//height: auto,
		width: '100%',
		height:'100%',
		
	   	colNames:[
				  'docId',
				  'hisNo',
	   	          '<spring:message code='t.flagType' text='구분' />',
	   	          '<spring:message code='t.category' />',
				  '<spring:message code='sch.Importance.2' text='중요' />',
	   	          '<spring:message code='t.subject' />',
	   	      	  '<spring:message code='t.type' text='유형' />',
	   	          '<spring:message code='dms.historydate' text='수정일시' />',
	   	          '<spring:message code='dms.historyuser' text='수정자' />',
	   	          '<spring:message code='t.attached' />',
	   	          '<spring:message code='t.readCnt' />'
	   	          ],
	   	colModel:[
	   		{name:'docId',index:'docId', hidden:true},
	   		{name:'hisNo',index:'hisNo', hidden:true},
			{name:'cateType',index:'cateType', width:50},
	   		{name:'dmsCategory_.catFullName',index:'dmsCategory_.catFullName', width:120, sortable:false},
	   		{name:'hotFlag',index:'hotFlag', width:30},
	   		{name:'subject',index:'subject', width:400},
	   		{name:'hisType',index:'hisType', width:50},
	   		{name:'createDate',index:'createDate', width:120, align:'center'},
	   		{name:'uUser_.nName',index:'uUser_.nName', width:80, align:'center'},
	   		{name:'fileCnt',index:'fileCnt', width:30, align:'center'},
	   		{name:'readCnt',index:'readCnt', width:30, align:'center'},
		],	
	    
	    rowNum: ${userConfig.listPPage},
	   	mtype: "GET",	
		prmNames: {search:null, nd: null, rows: null, page: "pageNo", sort: "sortColumn", order: "sortType"},  
		pager: '#dataGridPager',
	    viewrecords: true,
	    sortname: 'createDate',
	    sortorder: 'desc',
	    scroll:false,
	    multiselect: true,
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
         	var ids = grid.jqGrid('getDataIDs');
            if (ids.length == 0) {
            	grid.hide(); emptyMsgDiv.show();
            } else {
            	grid.show(); emptyMsgDiv.hide();
            }
	    }
	});
	
	$("#dataGrid").jqGrid('navGrid',"#dataGridPager",{search:false,edit:false,add:false,del:false});
	$("#dataGrid").setGridWidth($(window).width()-0);
	$("#dataGrid").setGridHeight($(window).height()-130);
	
	$(window).bind('resize', function() {
		$("#dataGrid").setGridWidth($(window).width()+0);
		$("#dataGrid").setGridHeight($(window).height()-130);
	}).trigger('resize');	
});

</script>

</head>
<body style="overflow:hidden;">
<!-- List Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
<tr>
<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
	<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> <spring:message code="main.Document.Management" text="문서관리"/> &gt; <spring:message code="dms.history" text="문서이력"/></span>
</td>
<td width="40%" align="right">
<!-- n 개의 읽지않은 문서가 있습니다. -->
</td>
</tr>
</table>

<table width=100% border="0" cellspacing=0 cellpadding=0 class=mail_list_t style="height:35px;">
	<tr>
		<td width="*" style="padding-left:3px;">
			<a onclick="javascript:removeDocument();" class="button gray medium">
			<img src="../common/images/bb01.gif" border="0"> <spring:message code="t.delete" text="삭제"/> </a>
		<td> 
		
		<td width="400" class="DocuNo" align="right" style="padding-right:5px; ">

			<%
			//<form:option> 내부에 <spring:message> 를 사용할 수 없으므로 부득이 여기서 변수를 선언한다. 2011.08.17 김화중
			String searchKey = ((nek3.web.form.SearchBase)request.getAttribute("search")).getSearchKey();
			%>
			<form:form commandName="search">
				<form:select path="searchKey"  id="searchKey">
					<option value="subject" <%= setSelectedOption("subject",searchKey) %>><spring:message code="t.subject" /></option>
					<option value="writer_.nName" <%= setSelectedOption("writer_.nName",searchKey) %>><spring:message code="t.writer" /></option>
					<option value="dmsCategory_.catName" <%= setSelectedOption("dmsCategory_.catName",searchKey) %>><spring:message code="t.category" text="분류"/></option>
<%-- 					<option value="subject" <%= setSelectedOption("subject",searchKey) %>><spring:message code="t.subject" /></option> --%>
<%-- 					<option value="writer_.nName" <%= setSelectedOption("writer_.nName",searchKey) %>><spring:message code="t.writer" /></option> --%>
				</form:select>
				<form:input style="width:100px;" path="searchValue"  id="searchValue"/>
				<form:hidden path="docId" /><form:hidden path="useNewWin" /><form:hidden path="useAjaxCall" />
				<form:hidden path="hisNo" />

			<a onclick="javascript:findDmses();" class="button gray medium">
			<img src="../common/images/bb02.gif" border="0"> <fmt:message key="t.search"/>&nbsp;<!-- 검색 --> </a>
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
		<!-- <div id="dataGridPagerNumber" style="text-align:center;">Page Numbering</div> -->
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

