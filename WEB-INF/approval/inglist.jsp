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
    //--------------------------------------------------------------------------------------------------
    //조회 값
    String sMenu = ApprUtil.setnullvalue((String)request.getAttribute("menu"), ApprMenuId.ID_240_NUM);
	int iMenuId = Integer.parseInt(sMenu);
	String formName = (String)request.getAttribute("formName");
    String sMenuId = ApprUtil.setnullvalue(request.getParameter("menu"), ApprMenuId.ID_240_NUM) ;
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<TITLE>내결재진행문서목록</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.jqgrid.jsp"%>

<%@ include file="../common/include.common.jsp"%>
<%@ include file="../common/include.script.map.jsp"%>

<!-- gtip2 -->
<link rel="stylesheet" type="text/css" media="screen" href="/common/libs/jquery-qtip2/2.0.0/jquery.qtip.min.css" />
<script src="/common/libs/jquery-qtip2/2.0.0/jquery.qtip.min.js" type="text/javascript"></script>

<!-- dhtmlwindow 2012-11-15 -->
<link rel="stylesheet" href="/common/libs/dhtmlwindow/1.1/dhtmlwindow.css" type="text/css" />
<script type="text/javascript" src="/common/libs/dhtmlwindow/1.1/dhtmlwindow.js"></script>

<!-- dhtmlmodal 2013-03-11 -->
<link rel="stylesheet" href="/common/libs/dhtmlmodal/1.1/modal.css" type="text/css" />
<script type="text/javascript" src="/common/libs/dhtmlmodal/1.1/modal.js"></script>

<script src="<%= scriptPath %>/appr_doc.js"></script>

<SCRIPT LANGUAGE="JavaScript">
<!--
    function watchDoc(appID, sType, sApprType)
    {
    	var frm = document.getElementById("search");
    	$("#apprId").val(appID);
    	$("#cmd").val("<%= ApprDocCode.APPR_EDIT %>");
        //frm.action = "appr_ingappr.jsp" ;
        frm.action = "appr_apprdoc.jsp" ;

        if(sApprType=="7"){
			var url = "/approval/busi_apprdoc.htm?apprId="+ appID + "&menu=<%=sMenuId%>&cmd=<%= ApprDocCode.APPR_EDIT %>";
			var url_p = "/approval/busi_apprdoc_preview.htm?apprId="+ appID + "&menu=<%=sMenuId%>&cmd=<%= ApprDocCode.APPR_EDIT %>";
		}else{
			var url = "/approval/apprdoc.htm?apprId="+ appID + "&menu=<%=sMenuId%>&cmd=<%= ApprDocCode.APPR_EDIT %>";
			var url_p = "/approval/apprdoc_preview.htm?apprId="+ appID + "&menu=<%=sMenuId%>&cmd=<%= ApprDocCode.APPR_EDIT %>";
		}
		
		var fr_list = parent.document.getElementById("fr_list");
		var fr_right = parent.document.getElementById("fr_preview_right");
		var fr_bottom = parent.document.getElementById("fr_preview_bottom");
		
		/*
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
		*/
		
		OpenWindow( url, "", winWidth , 610 );
		//var objWin = OpenLayer(url, "전자결재", winWidth, winHeight,isWindowOpen);	//opt는 top, current
		return;
		
		
		//OpenWindow( url, "", "780" , "970" );
		
		/*
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

    function goChangeMenu()
    {
    	var frm = document.getElementById("search");
        frm.menu.value = frm.menuselected[frm.menuselected.selectedIndex].value;
        frm.target = "_self";  
        frm.action = "appr_inglist.jsp" ;
        frm.method = "post" ; 
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
    	
    	var reqUrl = "<c:url value="/approval/inglist_json.htm?" />" + $("#search").serialize();
    	$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
    	$("#resetSearch").show();
    	return true;
    }

    function resetSearch(){
    	$("#search").each(function(){
    		this.reset();
    	});
    	
    	var reqUrl = "<c:url value="/approval/inglist_json.htm?menu=${search.menu}" />";
    	$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
    	$("#resetSearch").hide();
    }
    
    function chkBg() {
    	var chkbox = window.event.srcElement;
    	var tr = chkbox.parentElement.parentElement;
    	if ( chkbox.checked ) {
    		tr.style.backgroundColor = "#D5E2F5";
    	} else {
    		tr.style.backgroundColor = "#EEEEF4";
    	}
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
	var grid = $("#dataGrid");
	$("#dataGrid").jqGrid({        
	    scroll: true,
	   	url:"<c:url value="/approval/inglist_json.htm" />?menu=<c:out value="${search.menu}" />",
		datatype: "json",
		//height: '100%',
		width: '100%',
	   	colNames:['<spring:message code='t.apprFlag1' text='&nbsp;' />',
// 	   			'<spring:message code='t.mFlag1' text='형태' />',
	   			'<spring:message code='t.flagType' text='FlagType' />',
	   			'<spring:message code='t.form.name' text='양식명' />',
// 	   			'<spring:message code='t.apprFlag' text='결재상태' />',
	   			'<spring:message code='t.subject' text='제목' />',
	   			'<spring:message code='t.writer' text='기안자' />',
	   			'<spring:message code='t.createDate' text='기안일자' />',
	   			'<spring:message code='t.attached' text='첨부' />'],
	   	colModel:[
			{name:'chkFlag',index:'chkFlag', width:3, align:'center'},
// 			{name:'mFlag',index:'mFlag', width:6, align:'center'},
			{name:'flagType',index:'flagType', width:5, align:'center'},
			{name:'formTitle',index:'formTitle', width:14/* formatter: formTitleFormatter*/},
// 			{name:'apprFlag',index:'apprFlag', width:8, align:'center'},
	   		{name:'subject',index:'subject', width:30},
	   		{name:'writer',index:'writer', width:8, align:'center'},
	   		{name:'createDate',index:'createDate', width:12, align:'center'},
	   		{name:'attached',index:'attached', width:3, align:'center'}
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
	    //multiselect: true,
	    //toolbar:[true,"top"],
		//caption: "Scrolling data",	
		loadError:function(xhr,st,err) {
	    	$("#errorDisplayer").html("Type: "+st+"; Response: "+ xhr.status + " "+xhr.statusText);
	    },
	    loadComplete:function(data) {
	    	/* jqGrid PageNumbering Trick */
	    	var i, myPageRefresh = function(e) {
	            var newPage = $(e.target).text();
	            grid.trigger("reloadGrid",[{page:newPage}]);
	            e.preventDefault();
	        };
	        
	    	/* MAX_PAGERS is Numbering Count. Public Variable : ex) 5 */
	        jqGridNumbering( $("#dataGrid"), this, i, myPageRefresh );
	
	        ShowUserInfoSet();
	
	        var ids = $("#dataGrid").jqGrid('getDataIDs');
	        for (var i=0;i<ids.length;i++) {
				var id=ids[i];
			
				 // MAKE SURE YOUR SELECTOR MATCHES SOMETHING IN YOUR HTML!!!
		        //$('.te').each(function() {
		            $('#' + id).qtip({
		               content: {
		                   text: 'Loading...',
		                   ajax: {
		                       //url: 'http://qtip2.com/demos/data/snowyowl',
		                       url: '/approval/appr_apprperprocess_pop.jsp?apprid=' + id,
		                       loading: false
		                   }
		               },
		               position: {
		                   viewport: $(window),
		                   my: 'bottom center',
		                   at: 'top center'
		               },
		               style: {
						   classes:	'ui-tooltip-bootstrap'
					   },
		               show: {
		                   delay: 600
		               },
		               hide: {
		                   delay: 0
		               }
		            });
		       // });
	        } 
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
	
	$("#dataGrid").jqGrid('hideCol','chkFlag');	//스타리온 요청사항
	$("#dataGrid").jqGrid('navGrid',"#dataGridPager",{search:false,edit:false,add:false,del:false});
	
	function formTitleFormatter(cellvalue, options, rowObject) {
		return '<a class="te" id="' + options.rowId + '" href="javascript:goApprperProcess(\'' + options.rowId +'\');">'+cellvalue+'</a>';
	}
	/* listResize */
	gridResize("dataGrid");
	/*
	$("#dataGrid").setGridWidth($(window).width()-0);
	$("#dataGrid").setGridHeight($(window).height()-130);
	
	$(window).bind('resize', function() {
		$("#dataGrid").setGridWidth($(window).width()+0);
		$("#dataGrid").setGridHeight($(window).height()-130);
	}).trigger('resize');
	*/

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
</head>

<body style="overflow: hidden;">
<form:form commandName="search" onsubmit="return false;">
<form:hidden path="apprId" />
<form:hidden path="useNewWin" />
<form:hidden path="useAjaxCall" />
<form:hidden path="menu" />
<form:hidden path="cmd" />
<input type="hidden" name="chkList" value="<%= ApprDocCode.APPR_SETTING_T %>">

<!-- popup에서 받는 값 -->
<input type="hidden" name="apprflagid" > 
<input type="hidden" name="apprxengeal" > 
<input type="hidden" name="apprnote" > 
<input type="hidden" name="apprpass" > 
<input type="hidden" name="calltype" >
<input type="hidden" name="pop">

<!-- List Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
<tr>
<td width="*" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
	<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> <spring:message code="appr.menu.approvalbox" text="결재함"/> &nbsp;&gt;&nbsp; <spring:message code="appr.menu.to.appr" text="결재할문서"/> </span>
</td>
<td width="*" align="right">
<!-- n 개의 읽지않은 문서가 있습니다. -->
</td>
</tr>
</table>

<!-- List Title -->

<!-- List Button -->
<table width=100% border="0" cellspacing=0 cellpadding=0 style="height:35px;">
	<tr>
		<td width="*" style="padding-left:3px;">
		<span style="position:absolute; z-index:100; top:77px; left:20px; cursor:pointer; display:none;">
			<img src="../common/images/btn_checkbox.gif" onClick="OnClickCheckBox()" style="cursor: hand" align="absmiddle">
            <input type="checkbox" name="chkval" value="false" style="width:0;">
		<!-- <input type="checkbox" name="chkno" value="" hidefocus='true' onclick="chk_select();"> -->
		</span>
		<%if ( ! ((iMenuId<=ApprMenuId.ID_340_NUM_INT)&&(iMenuId >= ApprMenuId.ID_300_NUM_INT)) ) { %>
<!-- 			<a onclick="javascript:allApproval();" class="button gray medium"> -->
<!-- 			<img src="../common/images/bb01.gif" border="0"> 일괄결재 </a> -->
		<%} %>
		
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
<!-- <div id="dataGridPagerNumber" style="text-align:center;">Page Numbering</div> -->
<span id="errorDisplayer" style="color:red"></span>
<!-- 본문 DATA 끝 -->

</form:form>

<style>

.qtip {
	max-width: 585px;
	min-height: 200px;
	height: 230px;
	max-height: 600px
}
body {margin:0px; padding:0px;}
.ui-jqgrid tr.jqgrow td:nth-last-child(4),.ui-jqgrid tr.jqgrow td:nth-last-child(3){text-align: center;}
.ui-jqgrid .ui-jqgrid-htable th#dataGrid_formTitle{text-align: left;}
.ui-jqgrid .ui-jqgrid-htable th#dataGrid_formTitle div{padding-left:13px;}
.ui-jqgrid-btable td:nth-last-child(4){text-align: left !important;}
</style>

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