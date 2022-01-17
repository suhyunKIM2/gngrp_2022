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
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<HTML>
<HEAD>
<TITLE>문서관리목록-관리자</TITLE>

<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.jqgrid.jsp"%>

<link rel=STYLESHEET type="text/css" href="<%= cssPath %>/list_new.css">
<link rel="STYLESHEET" type="text/css" href="<%= imgCssPath %>">
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

		return true;
	}

	function deleteValidation()
	{
		var bChecked = IsCheckedItemExist();
		if (!bChecked)
		{
			alert("<spring:message code='mail.c.notDoc.selected' text='선택된 문서가 없습니다' />");
			return false;
		}
		return confirm("<spring:message code='c.delete' text='삭제 하시겠습니까?' />");
	}

	function deleteAllValidation()
	{
		return confirm("<spring:message code='i.retention.period.delete' text='보존년한이 경과된 모든 문서를 삭제합니다' />\n\n<spring:message code='c.delete' text='삭제 하시겠습니까?' />");
	}

	function postValidation()
	{
		var bChecked = IsCheckedItemExist();
		if (!bChecked)
		{
			alert("<spring:message code='mail.c.notDoc.selected' text='선택된 문서가 없습니다'/>");
			return false;
		}
		return confirm("<spring:message code='c.reset.period' text='선택된 문서의 보존년한을 재조정 하시겠습니까?'/>");
	}
	function goSubmit(cmd, isNewWin ,docId)
	{
		var fm = document.getElementById("search");
		var url = "";
		var ids = "";
			
		switch(cmd)
		{
			case "search":					//검색
				if(!searchValidation()) return;
				fm.pg.value = "1";
				fm.action = "./dms_manager_list.jsp";
				break;
			case "view":					//문서보기
				fm.viewdocid.value = docId;
				fm.action = "./dms_manager_read.jsp";
				url = "./dms_manager_read.jsp?viewdocid=" + docId + "&menuid=";
				break;
			case "all":						//검색종료
				fm.action = "./dms_manager_list.jsp";
				fm.pg.value = "1";
				fm.searchtype.value = "0";
				fm.searchtext.value = "";
				break;
			case "pstate":					//보존기한 경과여부
				fm.action = "./dms_manager_list.jsp";
				fm.pg.value = "1";
				break;
			case "deleteall":				//모두 삭제
				if (!deleteAllValidation()) return;
				fm.action = "./dms_manager_write.jsp";
				fm.method = "POST";
				break;
			case "delete":					//선택삭제
				sids = $("#dataGrid").jqGrid('getGridParam','selarrrow');
				splitData = (sids.toString()).split(","); 
				if(splitData[0] == ''){
					alert("<spring:message code='mail.c.notDoc.selected' text='선택된 문서가 없습니다' />");
					return;
				}

				for(var i=0;i<splitData.length;i++){
					sVal = splitData[i];
					ids += sVal+":";
				}
				if (!deleteValidation()) return;
				fm.action = "./dmsInfoUpdate.htm";
				fm.cmd.value = "delete";
				fm.method = "POST";
				fm.docId.value = ids;
				break;
			case "listpost":					//보존년한 변경
				sids = $("#dataGrid").jqGrid('getGridParam','selarrrow');
				splitData = (sids.toString()).split(","); 
				if(splitData[0] == ''){
					alert("<spring:message code='mail.c.notDoc.selected' text='선택된 문서가 없습니다' />");
					return;
				}

				for(var i=0;i<splitData.length;i++){
					sVal = splitData[i];
					ids += sVal + "," +$("#" + sVal + " select")[0].value+":";
				}
				
				if (!postValidation()) return;
				fm.action = "./dmsInfoUpdate.htm";
				fm.cmd.value = "update";
				fm.method = "POST";
				fm.docId.value = ids;
				break;
		}
		if (isNewWin == "true"){
			
			fm.useNewWin.value = true;
			if ( cmd == "view") {
				//var url = "http://localhost/bbs/read.htm?searchKey=&searchValue=&docId=2011092219134762&bbsId=bbs00000000000000&useNewWin=true&useAjaxCall=false";
				var fms = $("#search").serialize();
				var url = fm.action + "?" + fms ;
				var a = parent.ModalDialog({'t':'<c:out value="${dms.title}" />', 'w':800, 'h':600, 'm':'iframe', 'u':url});
				return;
			}
		}else{
			fm.useNewWin.value = false;
			fm.target = "_self";
		}
		fm.submit();
	}

	function OnClickToggleAllSelect() {
		var items = document.getElementsByName("chkidx");
		if (items != null && items.length > 0) {
			var checked = !items[0].checked;
			for (var i = 0; i < items.length; i++) {
				items[i].checked = checked;
			}
		}
	}

	function IsCheckedItemExist()
	{
		var bChecked = false;
		var items = document.getElementsByName("chkidx");
		if (items != null && items.length > 0) {
			for (var i = 0; i < items.length; i++) 
			{
				if (items[i].checked)
				{
					bChecked = true;
					break;
				}
			}
		}
		return bChecked;
	}

	function OnChanePerserveId(idx)
	{
		var items = document.getElementsByName("chkidx");
		if (items !=null && items[idx] != null) items[idx].checked = true;
	}

	function OnChangePreserveState()
	{
		var fm = document.dmsWebFrom;
		fm.action = "./dms_manager_list.jsp";
		fm.method = "GET";
		fm.submit();
	}
	
	function div_resizes() {
		var objDiv = document.getElementById("viewList");
		var objTbl = document.getElementById("viewTable");
		var objPg = document.getElementById("viewPage");
	
	   	objDiv.style.height = document.body.clientHeight - 110 ;
	}
</script>

<style>
body {overflow:hidden; margin:5px; margin-left:10px; margin-top:2px; }
a, td, input, select {font-size:10pt; font-family:돋움,Tahoma; }
input {cursor:hand; }

a:link { color:black; text-decoration:none;  }
a:hover {text-decoration:underline; color:#316ac5}
a:visited { color:#616161; text-decoration:none;  }


.mail_list_t {border:1px solid #A1B5FE; background-image:url('../common/images/top_bg.jpg');}
.mail_list_td {border:1px solid white; border-width:0px 0px 1px 1px; }

.mail_list{border-collapse:collapse; border:1px solid #E8E8E8; border-width:1px 1px 0px 1px;}
.mail_list tr {height:25px; }
.mail_list td {font-size:10pt; font-family:돋움,Tahoma; border:1px solid #E8E8E8; 
				border-width:0px 0px 1px 0px; padding:2px; padding-top:2px; cursor:default;}

.col   {background-image:url('../common/images/column_bg.gif'); color:gray; text-align:center; padding:0px; font-weight:bold; padding:0px; padding-left:2px;  }
.col_p {background-image:url('../common/images/column_bg.gif'); color:#E8E8E8; padding:0px; }

.space {line-height:3px;}

/* 추가분 */
.PageNo { font-family: "돋움"; font-size: 10pt;  text-decoration: none; letter-spacing:3px; padding-bottom:3px; }

.PageNo a{font-weight:bold; font-family:Tahoma; font-size:10pt; border:1px solid #EBF0F8; background-color:#EBF0F8; text-decoration:none; color:#528BA0; height:20px; width:20px; padding-left:0px;}
.PageNo a:visited{font-weight:bold; font-family:Tahoma; font-size:10pt; border:1px solid #EBF0F8; background-color:#EBF0F8; text-decoration:none; color:#528BA0; height:20px; width:20px; padding-left:0px; }
.PageNo a:hover {font-weight:bold; font-family:Tahoma; font-size:10pt; border:1px solid #90B3D2; font-weight:bold; background-color:#c6E2FD; color:#528BA0; text-decoration:none; height:20px; width:20px; padding-left:0px; }

/* 추가분 */
.PageNo1 {}
.PageNo1 a{ font-weight:bold; font-family:돋움,Tahoma; font-size:11pt; border:1px solid #EBF0F8; 
			background-color:#FFFFFF; text-decoration:none; color:#528BA0;
			padding:2px 3px 3px 3px;}
.PageNo1 a:visited{ font-weight:bold; font-family:돋움,Tahoma; font-size:11pt; 
border:1px solid #EBF0F8; font-weight:bold; background-color:#FFFFFF; 
text-decoration:none; color:#528BA0; padding:2px 3px 3px 3px;}
.PageNo1 a:hover { font-weight:bold; font-family:돋움,Tahoma; font-size:11pt; 
border:1px solid #90B3D2; font-weight:bold; background-color:#c6E2FD; 
color:#528BA0; text-decoration:none; padding:2px 3px 3px 3px;}
.PageNo1 a:active { font-weight:bold; font-family:돋움,Tahoma; font-size:11pt; 
border:1px solid #90B3D2; font-weight:bold; background-color:#c6E2FD; 
color:#528BA0; text-decoration:none; padding:2px 3px 3px 3px;}

.PageNo span{width:2px; height:15px; color:#528BA0;}
.div-view {width:100%; height:expression(document.body.clientHeight-115); overflow:auto; overflow-x:hidden;}

/* 리스트 문서수 */
.doc_num{text-decoration:underline; font-size:8pt; cursor:hand;}

/* 미리보기 */
.p { width:15px; border:1px solid #A1B5FE; border-collapse:collapse; background-color:#FFFFFF;}
.p td { line-height:15px; border:1px solid #A1B5FE; cursor:hand; }

.p_sel { width:15px; border:2px solid #A1B5FE; border-collapse:collapse; background-color:#D7E4F5;}
.p_sel td {line-height:15px; border:2px solid #A1B5FE; cursor:hand; }
</style>

<script type="text/javascript">
$(document).ready(function(){
	// 전체 그리드에 대해 적용되는 default
	$.jgrid.defaults = $.extend($.jgrid.defaults,{loadui:"enable",hidegrid:false,gridview:false});

	$("#dataGrid").jqGrid({        
	    scroll: true,
	   	url:"<c:url value="/dms/managerList_data.htm" />",
		datatype: "json",
		//height: auto,
		width: '100%',
		height:'100%',
		
	   	colNames:['<spring:message code='t.category' />',
	   	          '<spring:message code='t.subject' />',
	   	          '<spring:message code='t.preservePeriod' />',
	   	          '<spring:message code='t.preserveYear' />'],
	   	colModel:[
	   		{name:'category',index:'category', width:200},
	   		{name:'subject',index:'subject', width:200},
	   		{name:'preservePeriod',index:'preservePeriod', width:200},
	   		{name:'createDate',index:'createDate', width:200},
		],	
	   	rowNum:${userConfig.listPPage},
	   	mtype: "GET",	
		prmNames: {search:null, nd: null, rows: null, page: "pageNo", sort: "sortColumn", order: "sortType"},  
		pager: '#dataGridPager',
	    viewrecords: true,
	    sortname: 'createDate',
	    multiselect: true,
	    scroll:false,
		loadError:function(xhr,st,err) {
	    	$("#errorDisplayer").html("Type: "+st+"; Response: "+ xhr.status + " "+xhr.statusText);
	    },
	    loadComplete:function(data){
		    //
	    }
	});
	
	$("#dataGrid").jqGrid('navGrid',"#dataGridPager",{search:false,edit:false,add:false,del:false});
	$("#dataGrid").setGridWidth($(window).width()-20);
	$("#dataGrid").setGridHeight($(window).height()-160);
	
	//$("#dataGrid").setGridWidth($(this).width() * .90);
	
	//$("#dataGrid").jqGrid('gridResize', { minWidth: 400, minHeight: 500 });
	
	$(window).bind('resize', function() {
		$("#dataGrid").setGridWidth($(window).width()-20);
		$("#dataGrid").setGridHeight($(window).height()-160);
		//$("#dataGrid").setGridWidth($(this).width() * .90);
		
		//$("#dataGrid").setGridWidth($(window).width()-30);
		//$("#dataGrid").setGridWidth($(window).width()-30);
	}).trigger('resize');	
});

function search(){
	var searchKey = $("#searchKey").val();
	var searchValue = $("#searchValue").val();
	var reqUrl = "<c:url value="/dms/list_xml.htm?" />" + "searchKey=" + searchKey + "&searchValue=" + searchValue;
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

<script language="javascript">

	function OnToggleSelect(checked){
		var s = $("#dataGrid").jqGrid('getGridParam','selarrrow');
	}

	function IsCheckedItemExist(){
		var s = $("#dataGrid").jqGrid('getGridParam','selarrrow');
		return s != "";
	}
	

</script>

</HEAD>
<body>
<!-- 타이틀 시작 -->
<table width="100%" height=100% border="0" cellspacing="0" cellpadding="0" style="border:1px solid A1B5FE;">
	<tr> 
		<td valign=top style="border:1px solid A1B5FE; padding:5px;">

<table cellspacing=0 cellpadding=0 border=0 width=100%>
	<colgroup>
		<col width=5>
		<col width=*>
		<col width=260>
		<col width=5>
	</colgroup>

	<tr height=30>
		<td><img src="/common/images/col_bg_left.gif"></td>
		<td background="/common/images/col_bg_center.jpg">
		&nbsp;<img align=absmiddle src="../common/images/icons/viewlink.gif" border=0>&nbsp;<B><spring:message code='t.doc.management' text='문서관리' /></B> &gt; 
		<B><spring:message code='t.administrator' text='관리자' /></B> &gt; <B><spring:message code='dms.document.list' text='문서목록' /></B>-&nbsp;
		-&nbsp;<span class="doc_num" onclick="self.location.reload();" title="새로고침">
		<spring:message code='mail.g.list.total' text='개의 문서가 있습니다.' /></span>
		</td>
		<td width="*" align=right background="/common/images/col_bg_center.jpg">
		</td>
		<td align=right><img src="/common/images/col_bg_right.gif"></td>
	</tr>
</table>

<table width=100% border="0" cellspacing=0 cellpadding=0 class=mail_list_t>
	<tr style="height:25px;" >
		<td width="58" style="padding-left:3px; ">
			<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:goSubmit('listpost','','');">
				<tr>
					<td width="23"><img id="btnIma01" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
					<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;<spring:message code='t.save' text='저장' /></span></td>
					<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
				</tr>
			</table>
		</td>
		<td width="60"> 
			<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:goSubmit('delete','','');">
				<tr>
					<td width="23"><img id="btnIma02" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
					<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;<spring:message code='t.delete' text='삭제' /></span></td>
					<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
				</tr>
			</table>
		</td>
		<td width="83"> 
			<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:goSubmit('deleteall','','');">
				<tr>
					<td width="23"><img id="btnIma03" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
					<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;<spring:message code='t.batch.deletion' text='일괄삭제' /></span></td>
					<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
				</tr>
			</table>
		</td>

		<td>&nbsp;</td>
		<td width="370" class="DocuNo" align="right" style="padding-right:5px; ">
			<!-- 검색 -->
			<table border="0" width=100% cellspacing="0" cellpadding="0" style="table-layout:fixed;">
				<tr>
					<!-- 검색 시작 -->
					<td width="*" align="right"> 
					<form:form commandName="search">
						<table border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="105">
									<%
									String searchKey = ((nek3.web.form.SearchBase)request.getAttribute("search")).getSearchKey();
									%>
							    	<form:select path="searchKey">
										<option value=""></option>
										<option value="subject" <%= setSelectedOption("subject",searchKey) %>><spring:message code="t.subject" /></option>
										<option value="writer_.nName" <%= setSelectedOption("writer_.nName",searchKey) %>><spring:message code="t.writer" /></option>
									</form:select>
									<form:input path="searchValue" />
									<form:hidden path="cmd" />
									<form:hidden path="docId" />
									<form:hidden path="docIds" />
									<form:hidden path="useNewWin" />
									<form:hidden path="useAjaxCall" />
								</td>
								<td width="52" align=center style="padding-top:0.5px; cursor:hand;">
									<img src="/common/images/red_search.gif" align=absmiddle onclick="javascript:goSubmit('search','','');">
								</td>
							</tr>
						</table>
						</form:form>
					</td>
					<td width="83" align="right">
						<table border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="83">
									<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:goSubmit('all','','');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma05','','<%=imagePath %>/btn2_left.jpg',1)">
										<tr>
											<td width="23"><img id="btnIma05" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
											<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;<spring:message code='t.search.del' text='검색제거' /></span></td>
											<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			<!-- 검색 끝 -->
		</td>
	</tr>
</table>

<table id="dataGrid"></table>
<div id="dataGridPager"></div>
<div id="dataGridPagerNumber" style="text-align:center;">Page Numbering</div>
<span id="errorDisplayer" style="color:red"></span>

<!-- table 간 공백 -->
<div class=space>&nbsp;</div>

</td>
</tr>
</table>
</BODY>
</HTML>

