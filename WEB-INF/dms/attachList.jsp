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

	window.code = '_CHILDWINDOW_DMS1002';

	var targetWin;

	var arrDocs = new Array();
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
	function goSubmit(cmd) {
		var frm = document.getElementById("AttendanceWebForm");
		switch(cmd) {
			case "ok":
				var msgs = document.getElementsByName("chkdocid");
				if (msgs.length == 0) {
// 					alert("<fmt:message key='mail.c.select.mail'/>");//삭제할 문서가 없습니다!
					alert("<spring:message code='dms.choose.document' text='해당 문서를 선택해 주세요' />");
					return;
				}

				var selected = false;
				for (var i = 0; i < msgs.length; i++) {
					if (msgs[i].checked) {
						selected = true;
						break;
					}
				}

				if (!selected) {
 					alert("<spring:message code='dms.choose.document' text='해당 문서를 선택해 주세요' />");
					return;
				}
				
				arrDocs = new Array();
				
				var chk = document.getElementsByName("chkdocid");
				for( var i=0; i < chk.length; i++ ) {
					if(chk[i].checked){
						var data = chk[i].value.split('／');
						var dmsDoc = new Object();
						dmsDoc.docId = data[0];
						dmsDoc.fileNo = data[1];
						dmsDoc.subject	= data[2];
						dmsDoc.fileName = data[3];
						dmsDoc.fileSaveName = data[4];
						dmsDoc.fileSize = data[5];
						arrDocs.push(dmsDoc);
					}
				}
				
// 				window.returnValue = arrDocs;
// 				window.close();
				parent.setDmsAttachInfo(arrDocs);
				parent.closeDhtmlModalWindow();
				
				break;
			case "close": 
// 				closeDoc();
// 				window.close();
				parent.closeDhtmlModalWindow();
				return;
		}
	}
	
	function onClickOpen(docId){
		//location.href="http://localhost:81/dms/read.htm";
		location.href=request.getScheme()+"://localhost:81/dms/read.htm";
		/* var frm = document.forms[0];
		frm.docId.value = docId;
		frm.action = "<c:url value="/dms/read.htm" />";
		frm.submit(); */
	}
	
	function resetSearch(){
		$("#search").each(function(){
			this.reset();
		});
		var cateType = "${search.cateType}";
		var reqUrl = "<c:url value="/dms/attachlist_data.htm" />" + "?cateType=" + cateType;
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
		$("#resetSearch").hide();
	}
	
	function findDmses(){
		var searchKey = $("#searchKey").val();
		var searchValue = $("#searchValue").val();
		var cateType = "${search.cateType}";
		
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
		
		var reqUrl = "/dms/attachlist_data.htm?"+ $("#search").serialize()+"&cateType="+cateType;
		
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
		$("#resetSearch").show();
		return true;
	}
</script>

<script type="text/javascript">
//배열에 값이 있으면 넣지 않고 반환, 있으면 넣고 반환.001 LSH
Array.prototype.checkPush = function(args) {
	var check = true;
	for(var i in this) if (this[i] == args) { check = false; continue; }
	if (check) this.push(args);
	return this;
};

$(document).ready(function(){
	if(navigator.userAgent.indexOf('Firefox') >= 0){			//파이어폭스 window.event 사용
		(function(){
			var events = ["mousedown", "mouseover", "mouseout", "mousemove", "mousedrag", "click", "dblclick"];
			for (var i = 0; i < events.length; i++){
				window.addEventListener(events[i], function(e){
					window.event = e;
				}, true);
			}
		}());
	};
	
	$.jgrid.defaults = $.extend($.jgrid.defaults,{loadui:"enable",hidegrid:false,gridview:false});
	var grid = $("#dataGrid");
	$("#dataGrid").jqGrid({
	    scroll: true,
	    url:"<c:url value="/dms/attachlist_data.htm" />?catId=<c:out value="${search.catId}" />&cateType=<c:out value="${search.cateType}" />",
		datatype: "json",
		width: '100%',
		height:'100%',
		colNames:[ '<img src="../common/images/btn_checkbox.gif" onClick="OnClickToggleAllSelect()" style="cursor:hand;" align=absmiddle hidefocus=true>',
		   	          '<spring:message code='t.subject' />',
		   	          '<spring:message code='t.file.name' text='파일명' />',
		   	          '<spring:message code='t.file.size' text='파일크기' />',
//	 	   	       	  '<spring:message code='t.subject' />',
//	 	   	       	  '<spring:message code='t.subject' />',
		   	          '<spring:message code='t.createDate' />'
// 		   	          '<spring:message code='t.writer' />'
		   	          ],
		   	colModel:[
		   		{name:'checkbox',index:'checkbox', width:30, align:'center', sortable: false},
		   		{name:'subject',index:'subject', width:300},
		   		{name:'fileName',index:'fileName', width:120},
		   		{name:'fileSize',index:'fileSize', width:50},
		   		{name:'createDate',index:'createDate', width:100, align:'center'}
// 		   		{name:'uUser_.nName',index:'uUser_.nName', width:80, align:'center'}
			],	
		rowNum: '${userConfig.listPPage}',
// 	   	rowList: [10,20,30].checkPush('${userConfig.blockPPage}').sort(),
	   	mtype: "GET",
		prmNames: {search:null, nd: null, rows: "rowsNum", page: "pageNo", sort: "sortColumn", order: "sortType"},  
	   	pager: '#dataGridPager',
	    viewrecords: true,
	    sortname: 'created',
	    sortorder: 'desc',
	    scroll:false,
	    
	    pginput: false,	/* page number set */
	    gridview:false,	/* page number set */
	    
		multiselect:true, //10.05 일 김정국 수정.
	    onSelectRow: function(id){	//1~...
	    	var chk = document.getElementsByName("chkdocid");
	    	var isChecked = $("#jqg_dataGrid_" + id).attr('checked');
    		chk[id-1].checked = isChecked;
    		
    		// link click ... checkbox check pass //10.05 일 김정국 수정.
    		if ( event.srcElement.tagName == "B" || event.srcElement.tagName == "FONT" ) {
    			if ( $("#jqg_dataGrid_" + id).attr('checked') ) {
	    			$("#jqg_dataGrid_" + id).attr('checked',false);
	    			chk[id-1].checked = false;
    			} else {
    				$("#jqg_dataGrid_" + id).attr('checked',true);
	    			chk[id-1].checked = true;
    			}
    		}
	    },
		loadError:function(xhr,st,err) { $("#errorDisplayer").html("Type: "+st+"; Response: "+ xhr.status + " "+xhr.statusText); },
	    loadComplete: function() {
	    	
	    	/* jqGrid PageNumbering Trick */
// 	    	var i, myPageRefresh = function(e) {
// 	            var newPage = $(e.target).text();
// 	            grid.trigger("reloadGrid",[{page:newPage}]);
// 	            e.preventDefault();
// 	        };
	        
	    	/* MAX_PAGERS is Numbering Count. Public Variable : ex) 5 */
// 	        jqGridNumbering( grid, this, i, myPageRefresh );
	    	var chk = document.getElementsByName("chkdocid");
// 	    	var arrDms = dialogArguments.window.arrDocs;
			var arrDms = parent.getDmsAttachInfo();
			
	    	if(arrDms.length>0){
		    	for(var i=0;i<chk.length;i++){
		    		var tmp = chk[i].value.split("／");
		    		var a = tmp[0] + "／" + tmp[1];	//docid + fileno 
		    		for(var k=0;k<arrDms.length;k++){
		    			var dmsInfo = arrDms[k];
		    			var b = dmsInfo.docId + "／" + dmsInfo.fileNo;
		    			if(a==b){
		    				chk[i].checked = true;
		    				$("#jqg_dataGrid_" + (i+1)).attr('checked',true);
		    			}
		    		}
		    	}
	    	}
	        
	    	$('#totalCnt').html($('#dataGrid').jqGrid('getGridParam','records')); 
	    }
	});
	
	$("#dataGrid").jqGrid('hideCol','checkbox');	//10.05 일 김정국 수정.
	$("#dataGrid").jqGrid('navGrid',"#dataGridPager",{search:true,edit:false,add:false,del:false});
	
	/* listResize */
	gridResize("dataGrid", 160, false);
			
	$("#cb_dataGrid").click( function() {
		var chk = document.getElementsByName("chkdocid");
		for( var i=0; i < chk.length; i++ ) {
			chk[i].checked = $("#jqg_dataGrid_" + (i+1) ).attr('checked');
		}
	} );
	
	$("#resetSearch").hide();
});

/* 
function search(){
	var searchKey = $("#searchKey").val();
	var searchValue = $("#searchValue").val();
	var cateType = $("#search.cateType").val();
	
	var reqUrl = "<c:url value="/dms/attachlist_data.htm?" />" + "searchKey=" + searchKey + "&searchValue=" + searchValue + "&cateType=" + cateType;
	$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
}
 */
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
<body style="overflow:hidden;">
<!-- List Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
<tr>
<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
	<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> <spring:message code="t.doc.management" text="문서관리"/><c:out value="${ fullName }" /></span>
</td>
<td width="40%" align="right">
<!-- n 개의 읽지않은 문서가 있습니다. -->
</td>
</tr>
</table>

<table width=100% border="0" cellspacing=0 cellpadding=0 class=mail_list_t style="height:35px;">
	<tr>
		<td width="400" class="DocuNo" align="right" style="padding-rightㄴ:5px; ">

			<%
			//<form:option> 내부에 <spring:message> 를 사용할 수 없으므로 부득이 여기서 변수를 선언한다. 2011.08.17 김화중
			String searchKey = ((nek3.web.form.SearchBase)request.getAttribute("search")).getSearchKey();
			%>
			<form:form commandName="search" onsubmit="return false;">
				<form:select path="searchKey">
					<option value=""><spring:message code="t.choice" text="선택"/></option>
					<option value="subject" <%= setSelectedOption("subject",searchKey) %>><spring:message code="t.subject" /></option>
					<option value="writer_.nName" <%= setSelectedOption("writer_.nName",searchKey) %>><spring:message code="t.writer" /></option>
					<option value="dmsCategory_.catName" <%= setSelectedOption("dmsCategory_.catName",searchKey) %>><spring:message code="t.category" text="분류"/></option>
					<option value="keyword" <%= setSelectedOption("keyword",searchKey) %>><spring:message code="t.searchValue" /></option>
<%-- 					<option value="subject" <%= setSelectedOption("subject",searchKey) %>><spring:message code="t.subject" /></option> --%>
<%-- 					<option value="writer_.nName" <%= setSelectedOption("writer_.nName",searchKey) %>><spring:message code="t.writer" /></option> --%>
				</form:select>
				<form:input style="width:100px;" path="searchValue" />
				<form:hidden path="docId" /><form:hidden path="useNewWin" /><form:hidden path="useAjaxCall" />
				<form:hidden path="cateType" />

			<span>
				<a onclick="javascript:findDmses();" class="button gray medium">
				<img src="../common/images/bb02.gif" border="0"> <fmt:message key="t.search"/>&nbsp;<!-- 검색 --> </a>
			</span>
			
			
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
		
	<table width=100% border="0" cellspacing=0 cellpadding=0 class=mail_list_t style="height:35px;">
	<tr>
		<td width="*" style="padding-left:3px;" align="center">
		
		<a onclick="goSubmit('ok')" class="button gray medium">
			<img src="../common/images/bb02.gif" border="0">
			<spring:message code="t.ok" text="확인" />
		</a>

		<a onclick="goSubmit('close')" class="button white medium">
			<img src="/common/images/bb02.gif" border="0">
			<spring:message code="t.close" text="닫기" />
		</a>
		</td>
	</tr>
	</table>				
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

