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

<% 
	/**
	* 전자결재 기안첨부 목록 2016-05-11
	*/    
%>
<!DOCTYPE html>
<html>
<head>
<TITLE>기안첨부목록</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.jqgrid.jsp"%>
<%@ include file="../common/include.common.jsp"%>
<%@ include file="../common/include.script.map.jsp"%>

<script src="/common/scripts/appr_doc.js"></script>

<SCRIPT LANGUAGE="JavaScript">
var objDocList = new Array();

	//기안문서 선택
	function fnOk(){
		$("input[name=cellId]:checked").each(function(){
			var tmpStr = $(this).val().split("／");
			
			var docInfo = new Object();
			docInfo.docId = tmpStr[0];
			docInfo.subject = tmpStr[1];
			docInfo.docType = 1;
			objDocList.push(docInfo);
		});
		
		parent.setRelation(objDocList);
		parent.closeDhtmlModalWindow();	
// 		var cellId = $("input[name=cellId]:checked").val()
// 		if(cellId != null && cellId != ""){
// 			parent.setRelation(cellId);
// 			parent.closeDhtmlModalWindow();	
// 		}
	}
	
	//창 닫음
	function fnClose(){
		parent.closeDhtmlModalWindow();
		return;
	}
	
	//검색
    function findDocument(type){
    	var searchKey = $("#searchKey").val();
    	var searchValue = $("#searchValue").val();
    	
    	if($.trim(searchValue) == "" && type != "S"){	//
    		alert("<spring:message code='v.query.required' text='검색어를 입력하여 주십시요!' />");
    		$("#searchValue").focus();
    		return false;
    	}

    	var reqUrl = "<c:url value="/approval/appr_relate_json.htm?" />" + $("#search").serialize();
    	$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
    	$("#resetSearch").css("display", "");
    	return true;
    }
	
	//검색제거
    function resetSearch(){
    	$("#search").each(function(){
    		this.reset();
    	});
    	
    	var reqUrl = "<c:url value="/approval/appr_relate_json.htm"/>";
    	$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
    	$("#resetSearch").css("display", "none");
    }
    
</SCRIPT>

<script type="text/javascript">
var cnt=0;
$(document).ready(function(){
	
	$("#search").submit(function(){
		return findDocument();
	});
	
	// 전체 그리드에 대해 적용되는 default
	$.jgrid.defaults = $.extend($.jgrid.defaults,{loadui:"enable",hidegrid:false,gridview:false});
	var grid = $("#dataGrid");
	
	$("#dataGrid").jqGrid({        
	    scroll: true,
	   	url: "<c:url value="/approval/appr_relate_json.htm?" />" + $("#search").serialize(),
		datatype: "json",
		width: '90%',
	   	colNames:[
	   	          '',
	   	          '<spring:message code="t.subject" text="제목" />',
	   	          '<spring:message code="t.writer" text="기안자" />',
		   	      '<spring:message code="t.form.name" text="양식명" />',
	   	          '<spring:message code="t.createDate" text="기안일" />',
	   	          '<spring:message code="t.finishDate" text="완료일" />'
	   	],
	   	colModel:[
		   		{name:'cellId',index:'cellId', width:20, sortable:false},
		   		{name:'subject',index:'subject', width:250},
		   		{name:'nName',index:'nName', width:60, align:'center'},
				{name:'formTitle',index:'formTitle', width:100},
		   		{name:'gianDate',index:'gianDate', width:90},
		   		{name:'endDate',index:'endDate', width:90}
		],	
	   	rowNum:"10",
	   	mtype: "GET",
		prmNames: {search:null, nd: null, rows: null, page: "pageNo", sort: "sortColumn", order: "sortType"},  
	   	pager: '#dataGridPager',
	    viewrecords: true,
	    sortname: 'endDate',
	    sortorder: 'desc',
	    scroll:false,
	    pginput: true,	
	    gridview:true,
	    loadError:function(xhr,st,err) { $("#errorDisplayer").html("Type: "+st+"; Response: "+ xhr.status + " "+xhr.statusText); },
	    loadComplete:function(data) {
	    	/* jqGrid PageNumbering Trick */
	    	var i, myPageRefresh = function(e) {
	            var newPage = $(e.target).text();
	            $("#dataGrid").trigger("reloadGrid",[{page:newPage}]);
	            e.preventDefault();
	        };
	        
	    	/* MAX_PAGERS is Numbering Count. Public Variable : ex) 5 */
	        jqGridNumbering( $("#dataGrid"), this, i, myPageRefresh );
	
			if(cnt==0){
				var height=$(".ui-jqgrid-bdiv").css("height").replace("px","");
		    	$(".ui-jqgrid-bdiv").css("height",height-20+"px");
		    	cnt++;
			}
	    }

	});
	$("#dataGrid").jqGrid('navGrid',"#dataGridPager",{search:false,edit:false,add:false,del:false});
	
	/* listResize */
	gridResize("dataGrid", 125, false);	
	
	$("input[name='searchValue']").keydown(function(event) {
		if (event.which == 13) {
			event.preventDefault();
			findDocument();
		}
	});
	
});

$(function() {
	$("#dataFinder").accordion({
		collapsible: true,
		change:function(event, ui){
			//alert("changed");
		}
	});
});

function goMove(){
	$(location).attr("href",  "/approval/appr_relate_dms.htm");
}

</script>
</head>

<body style="overflow:hidden;" >
<form:form commandName="search" onsubmit="return false;">
<form:hidden path="apprId"/>

<!-- List Button -->
<table width=100% border="0" cellspacing=0 cellpadding=0 style="height:35px;">
	<tr>
		<td width="130">
			<span id="category" class="ui-buttonset">
				<label for="cat0" aria-pressed="false" class="ui-state-active ui-button ui-widget ui-state-default ui-button-text-only ui-corner-left" role="button" aria-disabled="false"><span class="ui-button-text">결재함</span></label>
				<label for="cat2" aria-pressed="false" class="ui-button ui-widget ui-state-default ui-button-text-only eeeeeeeeeeeeeee" role="button" aria-disabled="false"><span class="ui-button-text" onclick="goMove();">문서함</span></label>
			</span>
		</td>
		<td width="*" style="padding-left:3px;text-align:leftt;">
			<form:select path="gubun" onchange="findDocument('S')">
				<option value="0"><spring:message code="t.all" text="전체"/></option>
				<option value="1"><spring:message code="appr.menu.approvalbox" text="결재함"/></option>
				<option value="2"><spring:message code="appr.menu.receipient"  text="수신함"/></option>
				<option value="3"><spring:message code="appr.menu.circulatinge"  text="회람함"/></option>
			</form:select>
		</td>
		<td width="400" class="DocuNo" align="right" style="">
			<form:select path="searchKey">
				<option value="subject"><spring:message code="t.subject" text="제목"/></option>
				<option value="nName"><spring:message code="t.writer" text="작성자"/></option>
				<option value="formTitle"><spring:message code="t.form.name"  text="양식명"/></option>
			</form:select>
			<form:input path="searchValue" />

			<a onclick="javascript:findDocument();" class="button gray medium">
			<img src="../common/images/bb01.gif" border="0"> <spring:message code="t.search" text="검색"/> </a>
			
			<span id="resetSearch" style="display:none;">
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
<span id="errorDisplayer" style="color:red"></span>
<table width=100% border="0" cellspacing=0 cellpadding=0 style="height:auto;">
	<tr>
		<td width="*" style="padding-left:3px;" align="center">
		
		<a onclick="javascript:fnOk();" class="button white medium">
			<img src="../common/images/bb01.gif" border="0">
			<spring:message code="t.ok" text="확인" />
		</a>

		<a onclick="javascript:fnClose();" class="button white medium">
			<img src="/common/images/bb02.gif" border="0">
			<spring:message code="t.close" text="닫기" />
		</a>
		</td>
	</tr>
	</table>
<!-- 본문 DATA 끝 -->
<style>
.ui-jqgrid .ui-jqgrid-view{height:100%;}
.ui-jqgrid .ui-jqgrid-bdiv{height:350px !important;}
</style>
</form:form>

</body>
</html>