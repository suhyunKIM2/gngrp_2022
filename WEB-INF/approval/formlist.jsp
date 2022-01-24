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
<!-- 페이지 보기 권한 -->
<%
String sMenu = (String)request.getAttribute("menu");
int iMenuId = Integer.parseInt(sMenu);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<TITLE>결재문서양식목록</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel=stylesheet href="<%= cssPath %>/list.css" type="text/css">
<link rel="STYLESHEET" type="text/css" href="<%= imgCssPath %>">
<script src="<%= scriptPath %>/appr_doc.js"></script>

<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.jqgrid.jsp"%>

<%@ include file="../common/include.common.jsp"%>
<%@ include file="../common/include.script.map.jsp"%>

<!-- dhtmlwindow 2012-11-15 -->
<link rel="stylesheet" href="/common/libs/dhtmlwindow/1.1/dhtmlwindow.css" type="text/css" />
<script type="text/javascript" src="/common/libs/dhtmlwindow/1.1/dhtmlwindow.js"></script>

<!-- dhtmlmodal 2013-03-11 -->
<link rel="stylesheet" href="/common/libs/dhtmlmodal/1.1/modal.css" type="text/css" />
<script type="text/javascript" src="/common/libs/dhtmlmodal/1.1/modal.js"></script>

<SCRIPT LANGUAGE="JavaScript">
<!--
     //도움말
    SetHelpIndex("appr_form") ;

    function newForm()
    {
    	var frm = document.getElementById("search");
    	$("#apprId").val("");
    	$("#cmd").val("");
    	
        frm.action = "formdoc.htm" ;
		var url = "./formdoc.htm?menu=<%=sMenu %>";
		OpenWindow( url, "<spring:message code='main.Approval' text='전자결재' />", winWidth , winHeight );
		//OpenWindow( url, "", "755" , "610" );
		/*
        frm.pop.value = "" ; 
        frm.target = "_self";      
        frm.submit() ;
        */
    }

    function editForm(appformID, sType)
    {
    	var frm = document.getElementById("search");
    	$("#apprId").val("");
    	$("#cmd").val("");
        frm.apprformid.value =  appformID ;
        frm.cmd.value = "<%= ApprDocCode.APPR_EDIT %>" ;
        frm.action = "formdoc.htm" ;
        
        var url = "/approval/formdoc.htm?apprformid="+ appformID + "&cmd=<%= ApprDocCode.APPR_EDIT %>&menu=<%=sMenu %>";
        OpenWindow( url, "<spring:message code='main.Approval' text='전자결재' />", winWidth , winHeight );
        
//         var objWin = OpenLayer(url, "전자결재", winWidth, winHeight,isWindowOpen);	//opt는 top, current
		return;
        
        //OpenWindow( url, "", "900" , "750" );
		//OpenWindow( url, "", "755" , "610" );
        /*
        <% //새창과 현화면에서 처리여부 결정 %>
        if ( sType == "<%= ApprDocCode.POP_CHECK %>" )
        {
            frm.pop.value ="<%= ApprDocCode.POP_CHECK %>" ; 
            ShowFormOpen( );  <% // pop open%>            
        }else {
            frm.pop.value = ""; 
            frm.target = "_self";             
        }
        frm.method = "get" ; 
        frm.submit() ;
        */
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
    	
    	var reqUrl = "<c:url value="/approval/formlist_json.htm?" />" + $("#search").serialize();
    	$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
    	$("#resetSearch").show();
    	return true;
    }

    function resetSearch(){
    	$("#search").each(function(){
    		this.reset();
    	});
    	
    	var reqUrl = "<c:url value="/approval/formlist_json.htm?menu=${search.menu}" />";
    	$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
    	$("#resetSearch").hide();
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
	   	url:"<c:url value="/approval/formlist_json.htm" />?menu=<c:out value="${search.menu}" />",
		datatype: "json",
		//height: '100%',
		width: '100%',
	   	colNames:['<spring:message code='t.subject' text='제목' />','<spring:message code='t.createDate' text='기안일자' />','<spring:message code='t.writer' text='기안자' />'],
	   	colModel:[
	   		{name:'subject',index:'subject', width:300},
	   		{name:'createDate',index:'createDate', width:150},
	   		{name:'writer',index:'writer', width:120},
		],	
	   	rowNum:${userConfig.listPPage},
	   	mtype: "GET",
		prmNames: {search:null, nd: null, rows: null, page: "pageNo", sort: "sortColumn", order: "sortType"},  
	   	pager: '#dataGridPager',
	    viewrecords: true,
	   	//sortname: 'createDate',
	    //sortorder: "asc",
	    sortname: null,
	    scroll:false,
	    //toolbar:[true,"top"],
		//caption: "Scrolling data",	
		loadError:function(xhr,st,err) {
	    	$("#errorDisplayer").html("Type: "+st+"; Response: "+ xhr.status + " "+xhr.statusText);
	    },
	    loadComplete:function(data) {
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
	$("#dataGrid").setGridWidth($(window).width()-0);
	$("#dataGrid").setGridHeight($(window).height()-130);

	$(window).bind('resize', function() {
		$("#dataGrid").setGridWidth($(window).width()+0);
		$("#dataGrid").setGridHeight($(window).height()-130);
	}).trigger('resize');	
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

<style>
body {overflow:hidden; margin:5px; margin-left:10px; margin-top:2px; }
a, td, input, select {font-size:10pt; font-family:돋움,Tahoma; }
input {cursor:hand; }

a:link { color:black; text-decoration:none;  }
a:hover {text-decoration:underline; color:#316ac5}
a:visited { color:#616161; text-decoration:none;  }


.mail_list_t {border:1px solid #A1B5FE; background-image:url('../common/images/top_bg.jpg'); height:28px; }


.mail_list{border-collapse:collapse; border:1px solid #E8E8E8; border-width:1px 1px 0px 1px;}
.mail_list tr {height:25px; }
.mail_list td {font-size:10pt; font-family:돋움,Tahoma; border:1px solid #E8E8E8; border-width:0px 0px 1px 0px; padding:0px; padding-top:2px; }

.col   {background-image:url('../common/images/column_bg.jpg'); color:gray; text-align:center; padding:0px; border:0px; font-weight:bold;}
.col_p {background-image:url('../common/images/column_bg.jpg'); color:#E8E8E8; padding:0px; border:0px;  }

.space {line-height:3px;}

/* 추가분 */
.PageNo { font-family: "돋움"; font-size: 10pt; height:27px; text-decoration: none; letter-spacing:3px; padding-bottom:3px; }

.PageNo a{font-weight:bold; font-family:Tahoma; font-size:10pt; border:1px solid #EBF0F8; 
background-color:#EBF0F8; text-decoration:none; color:#528BA0; height:20px; width:20px; padding-left:0px;}
.PageNo a:visited{font-weight:bold; font-family:Tahoma; font-size:10pt; border:1px solid #EBF0F8; 
background-color:#EBF0F8; text-decoration:none; color:#528BA0; height:20px; width:20px; padding-left:0px; }
.PageNo a:hover {font-weight:bold; font-family:Tahoma; font-size:10pt; border:1px solid #90B3D2; font-weight:bold; 
background-color:#c6E2FD; color:#528BA0; text-decoration:none; height:20px; width:20px; padding-left:0px; }



.PageNo span{width:2px; height:15px; color:#528BA0;}
.div-view {width:100%; height:expression(document.body.clientHeight-108); overflow:auto; overflow-x:hidden;}

/* 리스트 문서수 */
.doc_num{text-decoration:underline; font-size:8pt; cursor:hand;}

/* 미리보기 */
.p { width:15px; border:1px solid #A1B5FE; border-collapse:collapse; background-color:#FFFFFF;}
.p td { line-height:15px; border:1px solid #A1B5FE; cursor:hand; }

.p_sel { width:15px; border:2px solid #A1B5FE; border-collapse:collapse; background-color:#D7E4F5;}
.p_sel td {line-height:15px; border:2px solid #A1B5FE; cursor:hand; }
</style>

<body style="overflow:hidden; padding: 0;margin: 0;">

<form:form commandName="search" onsubmit="return false;">
<form:hidden path="cmd"/>
<form:hidden path="menu"/>
<input type="hidden" name="apprformid" value="">
<input type="hidden" name="pop">

	<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
	<tr>
	<td width="60%" style="padding-left:5px; padding-top:5px; ">
		<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> <spring:message code="main.Approval" text="전자결재"/> &nbsp;&gt;&nbsp; <spring:message code="appr.menu.formbox" text="양식함"/> </span>
	</td>
	<td width="40%" align="right">
<!-- 	n 개의 읽지않은 문서가 있습니다. -->
	</td>
	</tr>
	</table>
<!-- List Title -->	

<table width=100% border="0" cellspacing=0 cellpadding=0 class=mail_list_t>
	<tr style="height:25px;" >
		<td width="110" style="padding-left:3px;"> 
			<a onclick="javascript:newForm();" class="button white medium">
				<img src="../common/images/bb01.gif" border="0">&nbsp;<spring:message code="main.Approval.form.New" text="결재양식장성"/>
			</a>
		</td>

		<td>&nbsp;</td>
		<td width="270" class="DocuNo" align="right" style="padding-right:5px; ">
			<table border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td width="*">
						<%
						//<form:option> 내부에 <spring:message> 를 사용할 수 없으므로 부득이 여기서 변수를 선언한다. 2011.08.17 김화중
						String searchKey = ((nek3.web.form.SearchBase)request.getAttribute("search")).getSearchKey();
						%>
							<form:select path="searchKey">
<!-- 								<option value="ALL">전체검색</option> -->
								<option value="SUBJECT" <%= setSelectedOption("SUBJECT",searchKey) %>><spring:message code="t.subject" /></option>
								<option value="GIANJA" <%= setSelectedOption("GIANJA",searchKey) %>><spring:message code="t.writer" /></option>
								<option value="DOCNUM" <%= setSelectedOption("DOCNUM",searchKey) %>><spring:message code="t.docNo" /></option>
								<option value="CONTENT" <%= setSelectedOption("CONTENT",searchKey) %>><spring:message code="t.content" /></option>
							</form:select>
							<form:input path="searchValue" />
					</td>
					<td width="150" align=center style="padding-top:0.5px; cursor:hand;">
<%-- 						<img src="<%=sImagePath %>/red_search.gif" align="absmiddle" onclick="javascript:findDocument();" alt="검색" /> --%>
						<a onclick="javascript:findDocument();" class="button white medium">
							<img src="../common/images/bb01.gif" border="0">&nbsp;<spring:message code="t.search" text="검색"/>
						</a>
						<a onclick="javascript:resetSearch();" class="button gray medium" id="resetSearch">
							<img src="../common/images/bb02.gif" border="0">&nbsp;<spring:message code="t.search.del" text="검색제거"/>
						</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table width=100% cellspacing=0 cellpadding=0 border=0>
	<tr>
		<td>
	<!-- 본문 DATA 시작 -->
	<table id="dataGrid"></table>
	<div id="dataGridPager"></div>
<!-- 	<div id="dataGridPagerNumber" style="text-align:center;">Page Numbering</div> -->
	<span id="errorDisplayer" style="color:red"></span>
	<!-- 본문 DATA 끝 -->
		</td>
	</tr>
</table>

</form:form>
</body>
</html>


<script>
//previewCancel();	/* preview cancellation */

function ShowAttach( bbsid, docid, fileno ) {
	winx = window.event.x-265;
	winy = window.event.y-40;
	//var url = "/notification/bbs_download_attach_info.jsp?noteid=" + uid;
	var url = "/bbs/bbs_download_attach_info.jsp?bbsid=" + bbsid + "&docid=" + docid + "&fileno=" + fileno;
	xmlhttpRequest( "GET", url , "afterShowAttach" ) ;
}
</script>