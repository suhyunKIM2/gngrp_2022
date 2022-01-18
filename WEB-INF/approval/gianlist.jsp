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
    String cssPath = "/common/css";
	String imgCssPath = "/common/css/blue";
	String imagePath = "/common/images/blue";
	String scriptPath = "/common/scripts";
%>
<!DOCTYPE html>
<html>
<head>
<TITLE><spring:message code="t.app.select.from" text="결재문서 양식선택"/>
</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.jqgrid.jsp"%>

<%@ include file="../common/include.common.jsp"%>
<%@ include file="../common/include.script.map.jsp" %>

<!-- dhtmlwindow 2012-11-15 -->
<link rel="stylesheet" href="/common/libs/dhtmlwindow/1.1/dhtmlwindow.css" type="text/css" />
<script type="text/javascript" src="/common/libs/dhtmlwindow/1.1/dhtmlwindow.js"></script>

<!-- dhtmlmodal 2013-03-11 -->
<link rel="stylesheet" href="/common/libs/dhtmlmodal/1.1/modal.css" type="text/css" />
<script type="text/javascript" src="/common/libs/dhtmlmodal/1.1/modal.js"></script>

<!-- 
<link rel=stylesheet href="<%= cssPath %>/list.css" type="text/css">
<link rel="STYLESHEET" type="text/css" href="<%= imgCssPath %>">
<script src="<%= scriptPath %>/common.js"></script>
<script src="<%= scriptPath %>/list.js"></script>
 -->
 
<script src="./appr_doc.js"></script>
<!-- 
<script src="<%= scriptPath %>/xmlhttp.vbs" type="text/vbscript"></script>
 -->

<SCRIPT LANGUAGE="JavaScript">
<!--
    //도움말
   //SetHelpIndex("appr_formgian") ;

function goGianForm(appformID)
{
	/*
	document.mainForm.formid.value =  appformID ;
	document.mainForm.menu.value =  110 ;
	document.mainForm.action = "./appr_imsidoc.jsp?menu=110";
	document.mainForm.method = "get" ; 
	document.mainForm.submit() ;
	*/
	
	var url = "/approval/imsidoc.htm?menu=110&formId="+appformID;
	
	OpenWindow( url, "", winWidth, 610 );
	//var objWin = OpenLayer(url, "전자결재", winWidth, winHeight,isWindowOpen);	//opt는 top, current
}

//-->
</SCRIPT>

</head>
<!-- 
<style>
body {margin:5px; margin-left:10px; margin-top:2px; overflow-y:hidden; }
a, td, input, select {font-size:10pt; font-family:돋움,Tahoma; }
input {cursor:hand; }

a:link { color:black; text-decoration:none;  }
a:hover {text-decoration:underline; color:#316ac5}
a:visited { color:#616161; text-decoration:none;  }


.mail_list_t {border:1px solid #A1B5FE; background-image:url('/common/images/top_bg.jpg'); height:28px; }


.mail_list{border-collapse:collapse; border:1px solid #E8E8E8; border-width:1px 1px 0px 1px;}
.mail_list tr {height:25px; }
.mail_list td {font-size:10pt; font-family:돋움,Tahoma; border:1px solid #E8E8E8; border-width:0px 0px 1px 0px; padding:0px; padding-top:2px; }

.col   {background-image:url('/common/images/column_bg.jpg'); color:gray; text-align:center; padding:0px; border:0px; font-weight:bold;}
.col_p {background-image:url('/common/images/column_bg.jpg'); color:#E8E8E8; padding:0px; border:0px;  }

.space {line-height:3px;}

/* 추가분 */
.PageNo { font-family: "돋움"; font-size: 10pt;  text-decoration: none; letter-spacing:3px; padding-bottom:3px; }

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
 -->
 
<script type="text/javascript">
$(document).ready(function(){
	// 전체 그리드에 대해 적용되는 default
	$.jgrid.defaults = $.extend($.jgrid.defaults,{loadui:"enable",hidegrid:false,gridview:false});

	$("#dataGrid").jqGrid({        
	    //scroll: true,
	   	url:"<c:url value="/approval/gianlist_json.htm" />",
		datatype: "json",
		height: '100%',
		width: '100%',
	   	colNames:['<spring:message code='t.subject' />','<spring:message code='t.descript' text='설명' />'],
	   	//,'<spring:message code='t.writer' />'
	   	colModel:[
	   		{name:'subject',index:'subject', width:200},
	   		{name:'descript',index:'descript', width:400},
	   		//{name:'writer_.nName',index:'owner_.nName', width:120},
	   		//{name:'fileCnt',index:'fileCnt', width:80},
	   		//{name:'readCnt',index:'readCnt', width:200},
		],	
	   	rowNum:${userConfig.listPPage},
	   	mtype: "GET",
		prmNames: {search:null, nd: null, rows: null, page: "pageNo", sort: "sortColumn", order: "sortType"},  
	   	pager: '#dataGridPager',
	    viewrecords: true,
	   	//sortname: 'createDate',
	    //sortorder: "asc",
	    //sortname: null,
	    scroll:false,
	    
//	    pginput: true,	/* page number set */
	    //gridview:true,	/* page number set */
	    
	    pginput: true,
	    gridview:true,
	    shrinkToFit: true,
	    
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

function search(){
	var searchKey = $("#searchKey").val();
	var searchValue = $("#searchValue").val();
	var reqUrl = "<c:url value="/approval/gianlist_xml.htm?" />" + "searchKey=" + searchKey + "&searchValue=" + searchValue;
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

<body style="overflow:hidden;">

<form name="mainForm" method="get">
<input type="hidden" name="cmd" value="">
<input type="hidden" name="formid" value="">
<input type="hidden" name="searchformid">
<input type="hidden" name="searchformnm">
<input type="hidden" name="menu">
<input type="hidden" name="pop">

<!-- List Title -->
<!-- <table border="0" cellpadding="0" cellspacing="0" width="100%" style="height:30px;"> -->
<!-- <tr> -->
<!-- <td width="60%"><img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
<%-- 	<span class="ltitle"> <%=ApprMenuId.ID_100_HNM + "&nbsp;&gt;&nbsp;" %> 결재문서 작성 --%>
<%-- 		<span class="doc_num" onclick="self.location.reload();" title="<spring:message code='t.reload' text='새로고침' />"></span> --%>
<%-- 		<spring:message code='lp.totalCount' arguments='X' text='{0}개의 문서가 있습니다' /> --%>
<!-- 	</span> -->
<!-- </td> -->
<!-- <td width="40%" align="right"> -->
<!-- </td> -->
<!-- </tr> -->
<!-- </table> -->

<!-- List Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
<tr>
<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
	<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> <spring:message code="appr.menu.drafting" text="기안함"/> &nbsp;&gt;&nbsp; <spring:message code="t.newapproval" text="결재문서 작성"/></span>
</td>
<td width="40%" align="right">
<!-- n 개의 읽지않은 문서가 있습니다. -->
</td>
</tr>
</table>

<!-- List Title -->

<!-- List Button -->
<table width=100% border="0" cellspacing=0 cellpadding=0 style="height:35px;">
	<tr>
		<td width="*" style="padding-left:3px;"><spring:message code="appr.write.comment" text="※ 작성하고자 하는 결재서식을 선택 하십시오."/></td>
	</tr>
</table>
<!-- List Button -->

<!-- 타이틀 시작 -->
<!-- 
<table cellspacing=0 cellpadding=0 border=0 width="100%">
	<colgroup>
		<col width=5>
		<col width=*>
		<col width=650>
		<col width=5>
	</colgroup>

	<tr height=30>
		<td><img src="/common/images/col_bg_left.gif"></td>
		<td background="/common/images/col_bg_center.jpg">
		&nbsp;<img align=absmiddle src="/common/images/icons/viewlink.gif" border=0>
		기안함&nbsp;&gt;&nbsp;<b>결재문서 작성</b>
		<span style="text-decoration:underline; font-size:8pt;"></span>
		</td>
		<td background="/common/images/col_bg_center.jpg" align=right>
		</td>
		<td align=right><img src="/common/images/col_bg_right.gif"></td>
	</tr>
</table>

<table width=100% border="0" cellspacing=0 cellpadding=0 class=mail_list_t>
	<tr style="height:25px;" >
		<td>&nbsp;결재 양식을 선택하십시오</td>
		<td>&nbsp;</td>
		<td width="*" class="DocuNo" align="right">
		</td>
	</tr>
</table>
-->
	<!-- 본문 DATA 시작 -->
	<table id="dataGrid"></table>
	<div id="dataGridPager"></div>
	<!-- <div id="dataGridPagerNumber" style="text-align:center;">Page Numbering</div> -->
	<span id="errorDisplayer" style="color:red"></span>
	<!-- 본문 DATA 끝 -->

</form>

</body>
</html>
