<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%@ page errorPage="/error.jsp" %>
<%@ include file="/common/usersession.jsp" %>
<%
java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("yyyy-MM-dd"); 
String today = formatter.format(new java.util.Date());			// 오늘 날짜
java.util.Calendar cal = java.util.Calendar.getInstance();
cal.add(cal.DATE, -7);
String weekDate = formatter.format(cal.getTime());				// 일주일전 날짜
%>
<!DOCTYPE html>
<html>
<head>
<title>Newest</title>
<%@ include file="/WEB-INF/common/include.mata.jsp" %>
<%@ include file="/WEB-INF/common/include.jquery.jsp" %>
<%@ include file="/WEB-INF/common/include.common.jsp" %>
<%@ include file="/WEB-INF/common/include.jqgrid.jsp" %>
<script type="text/javascript">
	
	$(document).ready(function() {
		
		$.jgrid.defaults = $.extend($.jgrid.defaults,{loadui:"enable",hidegrid:false});
		var grid = $("#dataGrid");
		var emptyMsgDiv = $("<div style='width:100%;height:100%;position:relative;'><div style='position:absolute;top:50%;margin-top:-5em;width:100%;text-align:center;'><spring:message code='t.not.registered' text='등록된 자료가 없습니다.' /></div></div>");
		$("#dataGrid").jqGrid({        
		   	url: "/bbs/newest_json.htm",
		   	ajaxGridOptions: {cache: false},
			datatype: "json",
			width: '100%',
			height:'100%',
		   	colNames:[
		   	          'No',
		   	          '<spring:message code="t.bbsName" text="게시판명"/>',
		   	          '<spring:message code="t.subject" text="제목"/>',
		   	          '<spring:message code="t.posting.period" text="게시기간" />',
		   	          '<spring:message code="t.createDate" text="작성일" />',
		   	          '<spring:message code="t.writer" text="작성자" />',
		   	          '<spring:message code="t.attached" text="첨부" />',
		   	          '<spring:message code="t.readCnt" text="조회" />'
		    ],
		   	colModel:[
		   		{name:'docSeq',index:'docSeq', width:'30', align:"center", hidden:true},	
		   		{name:'title',index:'title', width:'70', align:"left", sortable:false}, 
		   		{name:'subject',index:'subject', width:'300', align:"left"},
		   		{name:'period',index:'period', width:'120', align:"center", sortable:false},
		   		{name:'createDate',index:'createDate', width:'100', align:"center"},
		   		{name:'writer',index:'writer', width:'60', align:"center"},	
		   		{name:'fileCnt',index:'fileCnt', width:'30', align:"center"}, 
		   		{name:'readCnt',index:'readCnt', width:'30', align:"center"}
			],
			rowNum:${userConfig.listPPage},
		   	mtype: "GET",
		   	width: "100%",
		   	height: "100%",
			prmNames: {search: null, nd: null, rows: "rowsNum", page: "pageNo", sort: "sortColumn", order: "sortType"},  
		   	pager: '#dataGridPager',
		    viewrecords: true,
		    sortname: 'createDate',
		    sortorder: 'desc',
		    gridview: true,				/* 처리속도를 빠르게 해줌, 시간측정시 절반가량 로딩시간 감소. 사용불가 모듈 = treeGrid, subGrid, afterInsertRow(event) */
		    scroll:false,
			loadError:function(xhr,st,err) {
		    	$("#errorDisplayer").html("Type: "+st+"; Response: "+ xhr.status +" "+xhr.statusText);
		    },
		    loadComplete:function(data){
	
		    	/* jqGrid PageNumbering Trick */
		    	var i, myPageRefresh = function(e) {
		            var newPage = $(e.target).text();
		            grid.trigger("reloadGrid",[{page:newPage}]);
		            e.preventDefault();
		        };
		        
		    	/* MAX_PAGERS is Numbering Count. Public Variable : ex) 5 */
		        jqGridNumbering($("#dataGrid"), this, i, myPageRefresh );
				
	            var ids = grid.jqGrid('getDataIDs');
	            if (ids.length == 0) {
	            	grid.hide(); emptyMsgDiv.show();
	            } else {
	            	grid.show(); emptyMsgDiv.hide();
	            }
	            
	            listShowAttach();//파일
	            
	            ShowUserInfoSet();//작성자
		    }
		});
		
		emptyMsgDiv.insertAfter(grid.parent());
		$("#dataGrid").jqGrid('navGrid',"#dataGridPager",{search:false,edit:false,add:false,del:false});
		$("#dataGrid").setGridWidth($(window).width()-0);
		$("#dataGrid").setGridHeight($(window).height()-134);
		
		$(window).bind('resize', function() {
			$("#dataGrid").setGridWidth($(window).width()+0);
			$("#dataGrid").setGridHeight($(window).height()-134);
		}).trigger('resize');	

		$("#goList").hide();
		$("img").attr("align", "absmiddle");
		
		
        
	});
	function openBbsWidget(cmd, isNewWin, type, bbsId, docId){
		var url = "";
		if(type == "board"){
			url ="/bbs/read.htm?bbsId=" + bbsId + "&docId=" + docId;
		}else{
			url = "/bbswork/read.htm?docId=" + docId;
		}
		
		if(isNewWin == "true"){
			url += "&useNewWin=true&useLayerPopup=false";
			var winName = "popup_" + popupWinCnt++;
			OpenWindow(url, winName, "760", "610");
			
		} else {	//self
			url += "&useNewWin=false&useLayerPopup=true";
	        if (typeof dhtmlwindow == "undefined") {
	        	OpenWindow(url, '<spring:message code="main.Board" text="게시판" />', "780", "500");
// 	    		var a = ModalDialog({'t':'<spring:message code="main.Board" text="게시판" />', 'modal':false, 'w':800, 'h':500, 'm':'iframe', 'u':url});
	        } else {
	        	OpenWindow(url, '<spring:message code="main.Board" text="게시판" />', "780", "500");
// 	 			parent.dhtmlwindow.open(
// 					url, "iframe", url, "<spring:message code='main.Board' text='게시판' />", 
// 					"width=800px,height=500px,resize=1,scrolling=1,center=1", "recal"
// 				);
	        }
		}
	}
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
		
		//var reqUrl = "<c:url value="/bbs/list_data.htm?bbsId=${search.bbsId}" />" + "&searchKey=" + searchKey + "&searchValue=" + searchValue;
		var reqUrl = "<c:url value="/bbs/newest_json.htm?" />" + $("#search").serialize();
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
		$("#resetSearch").css('display', '');
		return true;
	}

	function reloadBbses(){
		var reqUrl = "/bbs/newest_json.htm?" + $("#search").serialize();
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
		return true;
	}
	
	function resetBbsSearch(){
		$("#search").each(function(){
			this.reset();
		});
		
		var reqUrl = "/bbs/newest_json.htm?" + $("#search").serialize();
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
		$("#resetSearch").hide();
	}
	
	function listShowAttach() {
	     // Make sure to only match links to wikipedia with a rel tag
	    var strUrl = "/bbs/download_attach_info.htm?";
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
	
	function attach_down(docId, fileNo, bbsId) {
		location.href =  "<c:url value="/bbs/download.htm?" />" + "bbsId="+bbsId+"&docId=" + docId + "&fileNo=" + fileNo;   
	}
	
	function goSubmit(cmd, isNewWin ,docId){
		var frm = document.getElementById("search");
		frm.method = "GET";
		switch(cmd){
			case "view":
				frm.action = "/bbs/read.htm";
				frm.docId.value = docId;
				break;
			case "new":
				frm.docId.value = "";
				frm.action = "/bbs/form.htm";
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
			
			if (isNewWin == "dhtmlwindow" && cmd == "manage") {
				OpenWindow(url, "<c:out value="${bbsMaster.title}" />", "800", "500");
			} else if ($("#workType").val()=="2"&&cmd=="manage"){
				OpenWindow(url, "<c:out value="${bbsMaster.title}" />", "400", "500");
			}else{
				//OpenWindow(url, "<c:out value="${bbsMaster.title}" />", winWidth, winHeight );
				OpenWindow(url, "", winWidth, winHeight );
	 			//var objWin = OpenLayer(url, "<c:out value="${bbsMaster.title}" />", winWidth, winHeight,isWindowOpen);	//opt는 top, current
				return;
			}
			return;
		}
		frm.submit();
	} 
</script>
<style>
.ui-jqgrid .ui-jqgrid-htable th div{padding-right:24.5px;}
font{color:#266fb5  !important;}
</style>
</head>
<body style="overflow:hidden; background:#f2f2f2;">
<form:form commandName="search" onsubmit="return false;">
	<form:hidden path="docId" />
	<form:hidden path="bbsId" />
	<form:hidden path="workType" />
	<form:hidden path="moduleId" />

<!-- List Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
<tr>
	<td width="60%" style="padding-left:5px; padding-top:5px; ">
		<span class="ltitle">
			<img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" />
			<spring:message code="bbs.board.newest" text="최근글목록" />
		</span>
	</td>
	</td>
	<td width="40%" align="right"><!-- n 개의 읽지않은 문서가 있습니다. --></td>
</tr>
</table>

<!-- List Button -->
<table width=100% border="0" cellspacing=0 cellpadding=0 style="height:35px;">
	<tr>
		<td width="*" style="padding-left:3px;">
				<%-- 
				<span onclick="goSubmit('new','','')" class="button gray medium">
				<img src="../common/images/bb01.gif" border="0"> <spring:message code="t.newDoc" text="새문서"/> </span> 
				--%>
		</td>
		<td width="*" class="DocuNo" align="right" style="padding-right:5px; ">
			<form:select path="searchKey" id="searchKey" style="width:80px;">
				<form:option value="subject"><spring:message code="t.subject" text="제목" /></form:option>
				<form:option value="writerName"><spring:message code="t.writer" text="작성자" /></form:option>
			</form:select>
			
			<form:input style="width:80px" path="searchValue" />
			
			<span onclick="findBbses()" class="button white medium">
			<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.search" text="검색" /> </span>
			
			<span id="resetSearch" onclick="resetBbsSearch()" class="button white medium" style="display:none;">
			<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.search.del" text="검색제거" /> </span>
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
