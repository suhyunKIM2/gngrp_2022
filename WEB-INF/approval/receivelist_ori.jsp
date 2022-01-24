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
<%
String sMenu = (String)request.getAttribute("menu");
int iMenuId = Integer.parseInt(sMenu);

String titleName = (String) request.getAttribute("titleName");
String sSumDeptID = "";
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>수신목록</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

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

<!-- 
<link rel=stylesheet href="<%= cssPath %>/list.css" type="text/css">
<link rel="STYLESHEET" type="text/css" href="<%= imgCssPath %>">
<script src="<%= scriptPath %>/common.js"></script>
<script src="<%= scriptPath %>/list.js"></script>
<script src="<%= scriptPath %>/xmlhttp.vbs" type="text/vbscript"></script>
 -->
 
<script src="./appr_doc.js"></script>


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
	var grid = $("#dataGrid");
	$("#dataGrid").jqGrid({
	    scroll: true,
	   	url:"<c:url value="/approval/receivelist_json.htm" />?menu=<c:out value="${search.menu}" />",
		datatype: "json",
		//height: 400,
		width: '100%',
	   	colNames:['<spring:message code='t.flagType' text='구분' />',
	   	          '<spring:message code='t.apprLastUser' text='승인자' />',
	   	       		'<spring:message code='t.form.name' text='양식명' />',
	   	          '<spring:message code='t.subject' text='제목' />',
	   	          '<spring:message code='t.writer' text='기안자' />',
	   	          '<spring:message code='t.createDate' text='기안일' />',
	   	          '<spring:message code='t.finishDate' text='결재완료일' />',
	   	          '<spring:message code='t.preservePeriodAp' text='보존년한' />',
	   	          '<spring:message code='t.attached' text='첨부' />'],
	   	colModel:[
			{name:'flagType',index:'flagType', width:50, align:'center'},
			{name:'apprLastUser',index:'apprLastUser', width:80, align:'center'},
			{name:'formTitle',index:'formTitle', width:100},
	   		{name:'subject',index:'subject', width:300},
	   		{name:'writer',index:'writer', width:80, align:'center'},
	   		{name:'createDate',index:'createDate', width:100, align:'center'},
	   		{name:'finishDate',index:'finishDate', width:100, align:'center'},
	   		{name:'preserveId',index:'preserveId', width:60, align:'center'},
	   		{name:'attached',index:'attached', width:30, align:'center'}
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
	        
	        listShowAttach();
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
	var reqUrl = "<c:url value="/approval/receivelist_xml.htm?" />" + "searchKey=" + searchKey + "&searchValue=" + searchValue;
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

/* 리스트 첨부 조회 */
function listShowAttach() {
    // Make sure to only match links to wikipedia with a rel tag
   //var strUrl = "/bbs/download_attach_info.htm?";
   var strUrl = "/approval/appr_download_attach_info.jsp?apprid=";
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
					//url: strUrl + $(this).attr('rel') // Use the rel attribute of each element for the url to load
					url: strUrl + $(this).attr('rel') + "&menuid=<%=sMenu %>"
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
				width:300
			}
		})
	})

	// Make sure it doesn't follow the link when we click it
	.click(function(event) { event.preventDefault(); });
}
</script>

<SCRIPT LANGUAGE="JavaScript">
<!--
     //도움말
    SetHelpIndex("appr_receive") ;

    function watchDoc(appID, sType)
    {
    	var frm = document.getElementById("search");
        //frm.apprid.value =  appID ;
        frm.receivehistory.value =  "<%= ApprDocCode.RECEIVE_LIST_CHECK %>" ; ;
        //frm.cmd.value = "<%= ApprDocCode.APPR_EDIT %>" ;
        frm.action = "appr_apprdoc.jsp" ;
        
		var url = "/approval/apprdoc.htm?apprId="+ appID + "&menu=<%=sMenu%>&cmd=<%= ApprDocCode.APPR_EDIT %>&receivehistory=<%=ApprDocCode.RECEIVE_LIST_CHECK%>";
		var url_p = "/approval/preview.htm?apprId="+ appID + "&menu=<%=sMenu%>&cmd=<%= ApprDocCode.APPR_EDIT %>&receivehistory=<%=ApprDocCode.RECEIVE_LIST_CHECK%>";

		/*
		var fr_list = parent.document.getElementById("fr_list");
		var fr_right = parent.document.getElementById("fr_preview_right");
		var fr_bottom = parent.document.getElementById("fr_preview_bottom");
		
		if ( v_type == 1 ) {
			if ( fr_bottom.src == url_p ) {
				OpenWindow( url, "", "820" , "550" );
			} else {
			//fr_bottom.src = url_p;
			//fr_right.src = "about:blank";
			}
		} else if ( v_type == 2 ) {
			if ( fr_right.src == url_p ) {
				OpenWindow( url, "", "820" , "550" );
			} else {
			//fr_right.src = url_p;
			//fr_bottom.src = "about:blank";
			}
		} else {
			//fr_right.src = "about:blank";
			//fr_bottom.src = "about:blank";
			OpenWindow( url, "", "820" , "550" );
		}
		return;
*/

		OpenWindow( url, "", winWidth , 610 );
		//var objWin = OpenLayer(url, "전자결재", winWidth, winHeight,isWindowOpen);	//opt는 top, current
		return;

        
		OpenWindow( url, "", "780" , "970" );
        /*
        <% //새창과 현화면에서 처리여부 결정 %>
        if ( sType == "<%= ApprDocCode.POP_CHECK %>" )
        {
            mainForm.pop.value = "<%= ApprDocCode.POP_CHECK %>" ;
            ShowFormOpen();
        }else {
            mainForm.pop.value = "" ;
            mainForm.target = "_self";
        }
        frm.method = "post" ; 
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
    	
    	var reqUrl = "<c:url value="/approval/receivelist_json.htm?" />" + $("#search").serialize();
    	$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
    	$("#resetSearch").show();
    	return true;
    }

    function resetSearch(){
    	$("#search").each(function(){
    		this.reset();
    	});
    	
    	var reqUrl = "<c:url value="/approval/receivelist_json.htm?menu=${search.menu}" />" + "&formId=<c:out value="${search.formId}" />";
    	$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
    	$("#resetSearch").hide();
    }
//-->
</SCRIPT>
</head>

<body style="overflow:hidden;">
<form:form commandName="search" onSubmit="return false;">
<form:hidden path="apprId"/>
<form:hidden path="cmd"/>
<form:hidden path="menu"/>
<input type="hidden" name="sumdeptid" value="<%= sSumDeptID %>">
<input type="hidden" name="receivehistory">
<input type="hidden" name="pop">

	<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
	<tr>
	<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
		<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> <%= titleName %> </span>
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
								<option value="CONTENT" <%= setSelectedOption("CONTENT",searchKey) %>><spring:message code="t.content" /></option>
							</form:select>
							<form:input path="searchValue" />

<!-- 			<img src="/common/images/btn_search.gif" align="absmiddle" onclick="javascript:findDocument();" alt="검색" /> -->
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
<span id="errorDisplayer" style="color:red"></span>
<!-- 본문 DATA 끝 -->

</form:form>
</BODY>
</HTML>

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