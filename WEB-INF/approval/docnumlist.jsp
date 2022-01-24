<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="nek3.common.*" %>
<%@ page import="nek3.domain.approval.*" %>
<%! 
    //각 경로 패스
    String sImagePath =  ApprDocCode.APPR_IMAGE_PATH  ;
    String sJsScriptPath =  ApprDocCode.APPR_JAVASCRIPT_PATH ;
    String sCssPath =  ApprDocCode.APPR_CSS_PATH ;
    String cssPath = "/common/css";
	String imgCssPath = "/common/css/blue";
	String imagePath = "/common/images/blue";
	String scriptPath = "/common/scripts";
	String[] viewType = {"0"};
	
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

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<TITLE>내결재완료목록</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.jqgrid.jsp"%>

<%@ include file="../common/include.common.jsp"%>
<%@ include file="../common/include.script.map.jsp"%>
<!-- 
<link rel=stylesheet href="<%= cssPath %>/list.css" type="text/css">
<link rel="STYLESHEET" type="text/css" href="<%= imgCssPath %>">
 -->
<script src="<%= scriptPath %>/appr_doc.js"></script>

<SCRIPT LANGUAGE="JavaScript">
<!--
    function newDoc()
    {
//     	var frm = document.getElementById("search");
//     	$('#apprId').val("");
//     	$('#cmd').val("");
//         frm.action = "docnumform.htm" ;
//         frm.method = "get" ; 
//         frm.submit() ;
        
        var frm = document.getElementById("search");
    	$("#cmd").val("");
    	
		var url = "docnumform.htm";
		OpenWindow( url, "", "450" , "200" );
    }

    function goChangeMenu()
    {
    	var frm = document.getElementById("search");
        frm.menu.value = frm.menuselected[frm.menuselected.selectedIndex].value
        frm.target = "_self";  
        frm.action = "finlist.htm" ;
        frm.method = "get" ; 
        frm.submit() ;
    }
    
    function findDocument(){
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
    	
    	var reqUrl = "<c:url value="/approval/docnumlist_json.htm?" />" + $("#search").serialize();
    	$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
    	$("#resetSearch").show();
    	return true;
    }

    function resetSearch(){
    	$("#search").each(function(){
    		this.reset();
    	});
    	
    	var reqUrl = "<c:url value="/approval/docnumlist_json.htm?menu=${search.menu}" />" + "&formId=<c:out value="${search.formId}" />";
    	$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
    	$("#resetSearch").hide();
    }

    // 외부 문서 삭제하기
    function docnum_delete(docNumId){
        var rowData = $("#dataGrid").jqGrid('getRowData', docNumId);
    	var msg = '<spring:message code="t.docNo" text="문서번호" />: ' + rowData.docNumNo + '\n'
    			+ '<spring:message code="appr.document.subject" text="문서제목" />: ' + rowData.subject + '\n\n'
    			+ '<spring:message code="appr.out.document.delete" text="외부 문서를 삭제 하시겠습니까?" />' + '\n\n'
    			+ '<spring:message code="appr.out.document.after" text="삭제 후에는 외부 문서를 복구 할 수 없습니다." />';
		if (!confirm(msg)) return false;
    	$.ajax({
    		async: false,
    		cache: false,
    		url: '/approval/docnum_delete.htm',
    		type: 'POST',
    		data: { docNumId : docNumId },
    		dataType: 'text',
    		success: function (data) {
    			$("#dataGrid").trigger("reloadGrid");
    		}
    	});
    }
//-->
</SCRIPT>

<script type="text/javascript">
	$.jgrid.no_legacy_api = true;
	$.jgrid.useJSON = true;
</script>

<script type="text/javascript">
$(document).ready(function(){
	<c:choose>
	<c:when test="${search.onSearch}">
		$("#resetSearch").show();
	</c:when>
	<c:otherwise>
		resetSearch();
	</c:otherwise>
	</c:choose>
	
	$("#search").submit(function(){
		return findDocument();
	});
	
	// 전체 그리드에 대해 적용되는 default
	$.jgrid.defaults = $.extend($.jgrid.defaults,{loadui:"enable",hidegrid:false,gridview:false});

	$("#dataGrid").jqGrid({        
	    scroll: true,
	   	url:"<c:url value="/approval/docnumlist_json.htm" />?menu=<c:out value="${search.menu}" />&formId=<c:out value="${search.formId}" />",
		datatype: "json",
		//height: '100%',
		width: '100%',
	   	colNames:['',
	   	          '<spring:message code='t.docNo' text='문서번호' />',
	   	          '<spring:message code='t.subject' text='제목' />',
	   	          '<spring:message code='t.writer' text='기안자' />',
	   	          '<spring:message code='t.createDate' text='작성일' />',
	   	          '<spring:message code='t.attached' text='첨부' />'],
	   	colModel:[
  	   		{name:'delete',index:'delete', width:30, align:'center', sortable:false},
			{name:'docNumNo',index:'docNumNo', width:120, align:'center'},
	   		{name:'subject',index:'subject', width:300},
	   		{name:'writer',index:'writer', width:80, align:'center'},
	   		{name:'createDate',index:'createDate', width:100, align:'center'},
	   		{name:'fileCnt',index:'filecnt', width:40, align:'center'}
		],	
	   	rowNum:${userConfig.listPPage},
	   	mtype: "GET",
		prmNames: {search:null, nd: null, rows: null, page: "pageNo", sort: "sortColumn", order: "sortType"},  
	   	pager: '#dataGridPager',
	    viewrecords: true,
	   	sortname: 'createDate',
	    sortorder: 'desc',
	    scroll:false,
	    
	    pginput: true,	/* page number set */
	    gridview:true,	/* page number set */
	    
	    //toolbar:[true,"top"],
		//caption: "Scrolling data",	
		loadError:function(xhr,st,err) {
	    	$("#errorDisplayer").html("Type: "+st+"; Response: "+ xhr.status + " "+xhr.statusText);
	    },
	    loadComplete:function(data) {
	    	/* jqGrid PageNumbering Trick */
	    	var i, myPageRefresh = function(e) {
	            var newPage = $(e.target).text();
	            $("#dataGrid").trigger("reloadGrid",[{page:newPage}]);
	            e.preventDefault();
	        };
	        
	    	/* MAX_PAGERS is Numbering Count. Public Variable : ex) 5 */
	        jqGridNumbering( $("#dataGrid"), this, i, myPageRefresh );
	
	        ShowUserInfoSet();
	    },
	    onSelectRow:function(rowid){
	        //alert(rowid);
	        //$("#dialogContainer").load("<c:url value="/bbs/view.htm" />" + rowid);
	        /*
	        $("#viewDialog").dialog("open");
	        $("#viewDialog").dialog("option","title",rowid);
	        */
	    }/*,
	    ondblClickRow:function(rowid){
	        //alert(rowid);
	        $("#dialogContainer").load("<c:url value="/sample/view.htm" />");
	        $("#viewDialog").dialog("open");
	    },
	    onCellSelect:function(rowid, iCol,cellcontent){
	        alert(rowid);
	        alert(iCol);
	        alert(cellcontent);
	    }*/

	});
	$("#dataGrid").jqGrid('navGrid',"#dataGridPager",{search:false,edit:false,add:false,del:false});
	
	/* listResize */
	gridResize("dataGrid");	
});

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

<body>
<form:form commandName="search" onsubmit="return false;">
<form:hidden path="apprId"/>
<form:hidden path="cmd"/>
<form:hidden path="menu"/>
<form:hidden path="formId"/>
<form:hidden path="useNewWin" />
<form:hidden path="useAjaxCall" />
<input type="hidden" name="pop">

<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
<tr>
	<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
		<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> <spring:message code="appr.approval.edoclist" text="외부문서 대장"/></span>
	</td>
	<td width="40%" align="right">
<!-- 	n 개의 읽지않은 문서가 있습니다. -->
	</td>
	</tr>
	</table>

<!-- List Title -->

<!-- List Button -->
<table width=100% border="0" cellspacing=0 cellpadding=0 style="height:35px;">
	<tr>
		<td width="*" style="padding-left:3px;">

		<a onclick="javascript:newDoc();" class="button gray medium">
		<img src="../common/images/bb01.gif" border="0"> <spring:message code="appr.approval.edocno" text="외부문서 등록"/> </a>
		
		</td>
		<td width="400" class="DocuNo" align="right" style="">
			<%
						//<form:option> 내부에 <spring:message> 를 사용할 수 없으므로 부득이 여기서 변수를 선언한다. 2011.08.17 김화중
						String searchKey = ((nek3.web.form.SearchBase)request.getAttribute("search")).getSearchKey();
						%>
							<form:select path="searchKey">
<!-- 								<option value="ALL">전체검색</option> -->
								<option value="SUBJECT" <%= setSelectedOption("SUBJECT",searchKey) %>><spring:message code="t.subject" /></option>
								<option value="GIANJA" <%= setSelectedOption("GIANJA",searchKey) %>><spring:message code="t.writer" /></option>
								<option value="DOCNUM" <%= setSelectedOption("DOCNUM",searchKey) %>><spring:message code="t.docNo" /></option>
							</form:select>
							<form:input path="searchValue" />

			<a onclick="javascript:findDocument();" class="button gray medium">
			<img src="../common/images/bb01.gif" border="0"> <spring:message code="t.search" text="검색"/> </a>
			
			<span id="resetSearch">
			<a onclick="javascript:resetSearch();" class="button white medium">
			<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.search.del" text="검색제거" /> </a>
			</span>
		</td>
	</tr>
</table>
<!-- List Button -->

<!-- 본문 DATA 시작 -->
<table id="dataGrid"></table>
<div id="dataGridPager"></div>
<!-- <div id="dataGridPagerNumber" style="text-align:center;">Page Numbering</div> -->
<span id="errorDisplayer" style="color:red"></span>
<!-- 본문 DATA 끝 -->
<style>
.ui-jqgrid tr.jqgrow td{padding-left:21px !important;}
</style>
</form:form>
</body>
</html>

<script>
//t_set();

//setVeiwPage("<%=viewType[0]%>");

function ShowAttach( apprid,  menuid ) {
	winx = window.event.x-265;
	winy = window.event.y-40;
	var url = "/approval/appr_download_attach_info.jsp?apprid=" + apprid +"&menuid=" + menuid;
	xmlhttpRequest( "GET", url , "afterShowAttach" ) ;
}

</script>