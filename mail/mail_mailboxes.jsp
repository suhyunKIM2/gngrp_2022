<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="nek.common.util.*" %>
<%@ page import="nek.common.dbpool.*" %>
<%@ page import="com.oreilly.servlet.*" %>
<%@ page import="nek.mail.*" %>
<%@ page import="nek.notification.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ include file="../common/usersession.jsp" %>
<%!
	private MailRepository repository = MailRepository.getInstance();

	private NumberFormat formatter = new DecimalFormat("##,###,###");

	private String toSizeString(long bytesize) {
		if (bytesize == 0) {
			return "0KB";
		} else if (bytesize < 1024) {
			return "1KB";
		} else {
			long kbsize = bytesize/1024;
			return formatter.format(kbsize) + "KB";
		}
	}
%>
<%
	//협력업체 권한 체크
// 	if (loginuser.securityId < 1){
// 		out.print("<script language='javascript'>alert('사용권한이 없습니다.');history.back();</script>");
// 		out.close();
// 		return;
// 	}
	request.setCharacterEncoding("utf-8");

	DBHandler db = null;
	Connection con = null;
	Noteboxes notebox = new Noteboxes();
	nek.mail.RuleManager ruleManager = new nek.mail.RuleManager();
    String domainName = application.getInitParameter("nek.mail.domain");
    String menuid = request.getParameter("menuid");
    String leftBlock = request.getParameter("leftBlock");
    if(!uservariable.userDomain.equals("")) domainName = uservariable.userDomain;
	
	boolean refreshMenu = false;

	String cmd = request.getParameter("cmd");
	if (cmd != null) {

		if (cmd.equals("delete")) {
			String paramBoxID = request.getParameter("box");
			String dbPath = request.getParameter("dbpath");
			if (paramBoxID != null) {
				int boxID = Integer.parseInt(paramBoxID);
				int num = 0;
				try {
					db = new DBHandler();
					con = db.getDbConnection();
					if (dbPath.equals("mail")) {
						num = repository.deleteMailbox(con, loginuser.emailId, boxID, domainName);
						if (num > 0) ruleManager.delete(con, boxID, loginuser.emailId, domainName);
					} else if (dbPath.equals("note")) {
						num = notebox.deleteNotebox(con, loginuser.uid, boxID);
					}
				} finally {
					if (db != null && con != null) db.freeDbConnection();
				}
				if (num == 0) {
					String str = msglang.getString("mail.sub.exists");	/*하위 편지함이 존재합니다.*/
					out.print("<script langauge='javascript'>alert('"+str+"');history.back();</script>");
					out.close();
					return;
				}
			}

			refreshMenu = true;

		} else if (cmd.equals("clear")) {
			String paramBoxID = request.getParameter("box");
			String dbPath = request.getParameter("dbpath");
			if (paramBoxID != null) {
				int boxID = Integer.parseInt(paramBoxID);

				try {
					db = new DBHandler();
					con = db.getDbConnection();
					repository.clearMailbox(con, loginuser.emailId, boxID, domainName);
				} finally {
					if (db != null && con != null) {
						db.freeDbConnection();
					}
				}

			}
		} else if (cmd.equals("new")) {
			String name = request.getParameter("boxname");
			name = name.trim();	//앞뒤 공백제거 
// 			name = name.replaceAll("\\p{Space}", "");		//스페이스 제거
			String mainBoxId = request.getParameter("mainboxid");
			String topBoxId = request.getParameter("topboxid");
			String dbPath = request.getParameter("dbpath");
			if (name != null && name.length() > 0) {
				try {
					db = new DBHandler();
					con = db.getDbConnection();
					
					if(dbPath.equals("mail")){
						repository.createMailbox(con, loginuser.emailId, name, topBoxId, mainBoxId, domainName);
					}else if(dbPath.equals("note")){
						notebox.createNotebox(con, loginuser.uid, name, topBoxId, mainBoxId);
					}
				} finally {
					if (db != null && con != null) {
						db.freeDbConnection();
					}
				}
			}
			refreshMenu = true;
		} else if (cmd.equals("rename")) {
			String newName = request.getParameter("newname");
			String paramBoxID = request.getParameter("box");
			String dbPath = request.getParameter("dbpath");
			if (newName != null && paramBoxID != null) {
				int boxID = Integer.parseInt(paramBoxID);
				try {
					db = new DBHandler();
					con = db.getDbConnection();
					
					if(dbPath.equals("mail")){
						repository.renameMailbox(con, loginuser.emailId, boxID, newName, domainName);
					}else if(dbPath.equals("note")){
						notebox.renameNotebox(con, loginuser.uid, boxID, newName);
					}
					
				} finally {
					if (db != null && con != null) {
						db.freeDbConnection();
					}
				}
			}
			refreshMenu = true;
		} else if (cmd.equals("orders")) {
			String orders = request.getParameter("orders");
			String paramBoxID = request.getParameter("box");
			String dbPath = request.getParameter("dbpath");
			if (orders != null && paramBoxID != null) {
				int boxID = Integer.parseInt(paramBoxID);
				try {
					db = new DBHandler();
					con = db.getDbConnection();
					
					int orderNo = Integer.parseInt(orders);
					if(dbPath.equals("mail")){
						repository.orderMailbox(con, loginuser.emailId, boxID, orderNo, domainName);
					}else if(dbPath.equals("note")){
						notebox.orderNotebox(con, loginuser.uid, boxID, orderNo);
					}
					
				} finally {
					if (db != null && con != null) {
						db.freeDbConnection();
					}
				}
			}
			refreshMenu = true;
		}
		String url = "mail_mailboxes.jsp?_=";
		if (refreshMenu) {
			url += "&nomain=&refresh=";
		}
		if (menuid != null) 
			url += "&menuid=" + menuid;
		
		response.sendRedirect(url);
		return;

	}

	//메일
	Mailboxes mailboxes = null;
	MailboxSummaries summaries = null;
	try {
		db = new DBHandler();
		con = db.getDbConnection();
		
		mailboxes = repository.getCustomMailboxes(con, loginuser.emailId, domainName);
		summaries = repository.getMailboxSummaries(con, loginuser.emailId, domainName);
	} finally {
		if (db != null && con != null) {
			db.freeDbConnection();
		}
	}
	//사내통신
	ArrayList data = null;
	NotificationSummaries noteSsummaries = null;
	try {
		db = new DBHandler();
		con = db.getDbConnection();
		data = notebox.noteBoxlist(con, loginuser.uid);
		noteSsummaries = notebox.getNoteboxSummaries(con, loginuser.uid);
		//total = notebox.getCount(con, loginuser.uid);

	}finally {
		if (db != null && con != null) {
			db.freeDbConnection();
		}
	}
%>
<!DOCTYPE html>
<html>
<fmt:setLocale value="<%=loginuser.locale %>"/>
<fmt:bundle basename="messages">
<head>
<title><fmt:message key="mail.mailbox.mng"/>&nbsp;<%-- 편지함 관리 --%></title>
<%@ include file="/WEB-INF/common/include.mata.jsp" %>
<%@ include file="/WEB-INF/common/include.jquery.jsp" %>
<%-- <%@ include file="/WEB-INF/common/include.jqgrid.jsp" %> --%>
<%@ include file="/WEB-INF/common/include.common.jsp" %>
 
<link type="text/css" href="/common/css/styledButton.css" rel="stylesheet" />

<link rel="stylesheet" type="text/css" href="<%=cssPath %>/list.css">
<link rel="stylesheet" type="text/css" href="<%=imgCssPath %>">
<style type="text/css">
.br_tit_v {font-size:9pt; color:#cc6600;}
a.br_tit_v:link {font-size:9pt; color:#cc6600; text-decoration:none;}
a.br_tit_v:visited {font-size:9pt; color:#cc6600; text-decoration:none;}
a.br_tit_v:hover {font-size:9pt; color:#cc6600; text-decoration:underline;}
.div-view {width:100%; height:expression(document.body.clientHeight-115); overflow:auto; overflow-x:hidden;}
</style>
<script language="javascript">
<!--

//window.showModalDialog Version
function OnClickRenameModal(mailboxID, dbPath, mailboxName, topBoxId) {
	document.fmMailbox.box.value = mailboxID;
	document.fmMailbox.dbpath.value = dbPath;
	
	var url = "mail_editboxname.jsp";
	var opt = "dialogHeight: 260px; dialogWidth: 300px; dialogTop: px; edge: Raised; center: Yes; help: No; resizable: No; status: No; scroll: no;";
	var newname = window.showModalDialog(url ,mailboxName, opt);
	setRename(newname, topBoxId);
}

//dhtmlmodal Version
function OnClickRename(mailboxID, dbPath, mailboxName, topBoxId) {
	document.fmMailbox.box.value = mailboxID;
	document.fmMailbox.dbpath.value = dbPath;
	
	var url = "mail_editboxname.jsp?topBoxId=" + topBoxId + "&mailboxName=" + encodeURIComponent(mailboxName);
	window.modalwindow = window.dhtmlmodal.open(
		"_CHILDWINDOW_MAIL1002", "iframe", url, "<%=msglang.getString("mail.email") /* 전자메일 */ %>", 
		"width=300px,height=260px,resize=0,scrolling=1,center=1", "recal"
	);
}

function setRename(newname, topBoxId) {
	if (newname != null && newname.length > 0) {
		for (var i = 0; i < regacyBoxNames.length; i++) {
			var tmp = regacyBoxNames[i].split("｜");
			var mailboxName = tmp[0];
			var mailTopBoxId = tmp[1];
			if(mailTopBoxId!=topBoxId) continue;
			if (mailboxName == newname) {
				alert("<fmt:message key='mail.c.name.duplicate'/>");//같은 이름의 편지함이 이미 있습니다. 다른 이름을 입력하세요!
				document.fmMailbox.boxname.select();
				return;
			}
		}
		if(confirm("'" + newname + "'<fmt:message key='mail.c.name.rename'/>")) {//(으)로 편지함 이름을 수정합니다. 계속하시겠습니까?
			document.fmMailbox.cmd.value = "rename";
			document.fmMailbox.newname.value = newname;
			document.fmMailbox.submit();
		}
	}
}

function OnClickClear(mailboxID) {
	if (confirm("<fmt:message key='mail.c.mail.remove'/>")) {//편지함 내의 모든 문서가 삭제되며 복구할 수 없습니다. 계속하시겠습니까?
		document.fmMailbox.cmd.value = "clear";
		document.fmMailbox.box.value = mailboxID;
		document.fmMailbox.submit();
	}
}

function OnClickDelete(mailboxID, dbPath) {
	if (confirm("<fmt:message key='mail.c.mailbox.remove'/>")) {//편지함을 삭제하시면 편지함 내의 모든 문서와 편지함과 연결된 자동분류도 함께 삭제되면 복구할 수 없습니다. 계속하시겠습니까?
		document.fmMailbox.dbpath.value=dbPath;
		document.fmMailbox.cmd.value = "delete";
		document.fmMailbox.box.value = mailboxID;
		document.fmMailbox.submit();
	}
}

//window.showModalDialog Version
function OnClickOrderModal(mailboxID, orders, dbPath) {
	document.fmMailbox.dbpath.value = dbPath;
	document.fmMailbox.box.value = mailboxID;
	
	var url = "mail_editorders.jsp?orders="+orders;
	var opt = "dialogHeight: 200px; dialogWidth: 250px; dialogTop: px; edge: Raised; center: Yes; help: No; resizable: No; status: No; scroll: no;";
	var newname = window.showModalDialog(url ,"" , opt);
	setOrder(newname);
}

//dhtmlmodal Version
function OnClickOrder(mailboxID, orders, dbPath) {
	document.fmMailbox.dbpath.value = dbPath;
	document.fmMailbox.box.value = mailboxID;
	
	var url = "mail_editorders.jsp?orders="+orders;
	window.modalwindow = window.dhtmlmodal.open(
		"_CHILDWINDOW_MAIL1003", "iframe", url, "<%=msglang.getString("mail.email") /* 전자메일 */ %>", 
		"width=250px,height=200px,resize=0,scrolling=1,center=1", "recal"
	);
}

function setOrder(newname) {
	if (newname != null && newname.length > 0) {
		document.fmMailbox.cmd.value = "orders";
		document.fmMailbox.orders.value = newname;
		document.fmMailbox.submit();
	}
}


function OnClickCreate() {
	var topname = document.fmMailbox.topboxname.value;
	var name = document.fmMailbox.boxname.value;
	
	var topBoxId = document.fmMailbox.mainboxid.value;
	/*
	var topBox = document.fmMailbox.topboxname.value;
	if (topBox == "") {
		alert("상위 편지함을 선택해주십시오!");
		return;
	}
	*/
	var frm = document.fmMailbox;
	//var selBox = frm.selbox;
	//var tmpStr = selBox.options[selBox.selectedIndex].value;
	//var arrTxt = tmpStr.split("|");
	//frm.topboxid.value = arrTxt[0];
	//frm.mainboxid.value = arrTxt[0];
	//frm.dbpath.value = arrTxt[1];
	
	topname = TrimAll(topname);
	if (topname == "") {
		alert("<fmt:message key='mail.c.select.parent.mailbox'/>");//상위 편지함을 선택하세요
		getTopCode();
		return;
	}
	
	name = TrimAll(name);
	if (name == "") {
		alert("<fmt:message key='mail.c.mailbox.newname'/>");//새 편지함 이름을 입력하세요!
		document.fmMailbox.boxname.focus();
		return;
	}

	if (name.length > 20) {
		alert("<fmt:message key='mail.mailbox.name.limit.20'/>");//(편지함 이름은 20자 이내로 입력하세요)
		document.fmMailbox.boxname.select();
		return;
	}

	for (var i = 0; i < regacyBoxNames.length; i++) {
		var tmp = regacyBoxNames[i].split("｜");
		var mailboxName = tmp[0];
		var mailTopBoxId = tmp[1];
		if(mailTopBoxId!=topBoxId) continue;
		if (mailboxName == name) {
			alert("<fmt:message key='mail.c.name.duplicate'/>");//같은 이름의 편지함이 이미 있습니다. 다른 이름을 입력하세요!
			document.fmMailbox.boxname.select();
			return;
		}
	}

	if(confirm("'" + name + "'<fmt:message key='mail.c.mailbox.new'/>")) {//(으)로 편지함을 생성합니다. 계속하시겠습니까?
		document.fmMailbox.cmd.value = "new";
		document.fmMailbox.submit();
	}
}

var regacyBoxNames = new Array();
regacyBoxNames.push("<fmt:message key="mail.InBox"/>｜1"); //받은편지함
//2005-06-09, Added By Kim Do Hyoung for 디토소프트
//regacyBoxNames.push("HOT");
regacyBoxNames.push("<fmt:message key="mail.OutBox"/>｜2");	//보낸편지함
regacyBoxNames.push("<fmt:message key="mail.TempBox"/>｜4"); 	//&nbsp;<!-- 임시보관함 -->
regacyBoxNames.push("<fmt:message key="mail.DeletedBox"/>｜4");	//&nbsp;<!-- 지운편지함 -->
regacyBoxNames.push("<fmt:message key="mail.ReservationBox"/>｜6");	//&nbsp;<!-- 예약편지함 -->

<%
	Iterator iter = mailboxes.iterator();
	while (iter.hasNext()) {
		Mailbox box = (Mailbox)iter.next();
		out.println("regacyBoxNames.push(\"" + box.getName() + "｜" + box.getTopBoxId() + "\");");
	}
%>

function OnBoxNameKeyDown(e) {
	if(/\W/.test(String.fromCharCode(event.keyCode)) && event.keyCode != 46){
		event.returnValue = false;
	}

	if (event.keyCode == 13) {
		OnClickCreate();
	}
}

	//window.showModalDialog Version
	function getTopCodeModal() {
		var frm = document.fmMailbox;
		var winwidth = "300";
		var winheight = "450";
		var url = "./mailbox_tree.jsp?boxid=0";
		var opt = "status:no;scroll:no;center:yes;help:no;dialogWidth:" + winwidth + "px;dialogHeight:" + winheight + "px";
		returnvalue = window.showModalDialog(url, "", opt);
		setTopCode(returnvalue);
	}

	// dhtmlmodal Version
	function getTopCode(nType) {
		var url = "./mailbox_tree.jsp?boxid=0";
		window.modalwindow = window.dhtmlmodal.open(
			"_CHILDWINDOW_MAIL1004", "iframe", url, "<%=msglang.getString("mail.email") /* 전자메일 */ %>", 
			"width=300px,height=450px,resize=0,scrolling=1,center=1", "recal"
		);
	}
	
	function setTopCode(returnvalue, f_name) {
		var frm = document.fmMailbox;
		if (returnvalue != null  && returnvalue != "") {
			//alert(returnvalue);
			var menuInfo = returnvalue.split(":");
			if(menuInfo[1]==0) return;
			frm.topboxname.value = menuInfo[0];
			frm.topboxid.value = menuInfo[1];
			frm.mainboxid.value = menuInfo[3];
			frm.dbpath.value = menuInfo[4];
			
			frm.boxname.value = f_name;
		}
	}
	
	//Div 목록 사이즈 재조정
	function div_resize() {
		var objDiv = document.getElementById("viewList");
		var objTbl = document.getElementById("viewTable");
		var objPg = document.getElementById("viewPage");
	   	objDiv.style.height = document.body.clientHeight - 115 ;
	}

	//메일함 백업
	function OnBackup(box, boxname) {
		if (confirm(boxname + "<fmt:message key='mail.c.mailbox.bak'/>")) {//를 백업하시겠습니까?
			location.href = "mail_backup.jsp?box=" + box + "&boxname=" + encodeURI(boxname);
		}
	}
	//-->
	</script>
	</head>
	
<style>
body {margin:0px; }
.table_mail_padding td{padding:15px 0;}

</style>
	
<body>
<form name="fmMailbox" method="POST" action="mail_mailboxes.jsp" onsubmit="return false;">
<!-- hidden field -->
<input type="hidden" name="menuid" value="<%=menuid %>">
<input type="hidden" name="cmd" value="delete">
<input type="hidden" name="box" value="">
<input type="hidden" name="newname" value="">
<input type="hidden" name="orders" value="">

<!-- List Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
<tr>
<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
	<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> <fmt:message key="mail.option"/>&nbsp;&gt;&nbsp;<fmt:message key="mail.mailbox.mng"/></span>
</td>
<td width="40%" align="right">
<!-- n 개의 읽지않은 문서가 있습니다. -->
</td>
</tr>
</table>
<!-- List Title -->

<table border="0" cellpadding="0" cellspacing="0" width="100%"><tr height="8"><td></td></tr></table>

<!-- 버튼 시작 -->
<input type="hidden" name="topboxid">
<input type="hidden" name="mainboxid">
<input type="hidden" name="dbpath">
<input type="hidden" name="topboxname">
<input type="hidden" name="boxname">
<span onclick="getTopCode()" class="button white medium">
<img src="../common/images/bb02.gif" border="0"> <fmt:message key='mail.mailbox.new'/> <%-- 새 편지함 --%></span>
<!-- 버튼 끝 -->

<table border="0" cellpadding="0" cellspacing="0" width="100%"><tr height="6"><td></td></tr></table>

<div id="viewList" class="div-view" onpropertychange="div_resize();">
<table width="100%" border="0" cellspacing="0" cellpadding="0" id="viewTable">
	<tr> 
		<td height="30" valign="top"> 
			<table width="100%" border="0" cellspacing="0" cellpadding="0" height="29">
				<tr> 
					<td width="5" ></td>
					<td align="center">
						<table width="100%" border="0" cellspacing="0" cellpadding="0" style="position:relative;top:1px">
							<colgroup>
								<col width="17%">
								<col width="1">
								<col width="11%">
								<col width="1">
								<col width="11%">
								<col width="1">
								<col width="12%">
								<col width="1">
								<col width="10%">
								<col width="1">
								<col width="10%">
								<col width="1">
								<col width="10%">
								<col width="1">
								<col width="10%">
								<col width="1">
								<col width="10%">
							</colgroup>
							<tr>
								<td align="center" class="SubTitleText"><fmt:message key="mail.mailbox.name"/>&nbsp;<!-- 편지함 이름 --></td>
								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
								<td align="center" class="SubTitleText" nowrap><fmt:message key="mail.storage.letter"/>&nbsp;<!-- 보관중인 편지 --></td>
								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
								<td align="center" class="SubTitleText"><fmt:message key="mail.unread"/>&nbsp;<!-- 읽지않은 메일 --></td>
								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
								<td align="center" class="SubTitleText"><fmt:message key="mail.size"/>&nbsp;<!-- 크기 --></td>
								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
								<td align="center" class="SubTitleText"><fmt:message key="mail.backup"/>&nbsp;<!-- 백업 --></td>
								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
								<td align="center" class="SubTitleText"><fmt:message key="mail.empty"/>&nbsp;<!-- 비우기 --></td>
								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
								<td align="center" class="SubTitleText"><fmt:message key="mail.rename"/>&nbsp;<!-- 이름 바꾸기 --></td>
								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
								<td align="center" class="SubTitleText"><fmt:message key="t.delete"/>&nbsp;<!-- 삭제 --></td>
								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
								<td align="center" class="SubTitleText"><fmt:message key="mail.mailbox.order"/>&nbsp;<!-- 순서 --></td>
							</tr>
						</table>
					</td>
					<td width="5"></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr> 
		<td> 
			<!-- 본문 DATA 목록 -->
			<table width="100%" border="0" cellspacing="0" cellpadding="0" style="table-layout: auto;" class="table_mail_padding">
				<colgroup>
					<col width="17%" style="word-break:break-all">
					<col width="1">
					<col width="11%">
					<col width="1">
					<col width="11%">
					<col width="1">
					<col width="12%">
					<col width="1">
					<col width="10%">
					<col width="1">
					<col width="10%">
					<col width="1">
					<col width="10%">
					<col width="1">
					<col width="10%">
					<col width="1">
					<col width="10%">
				</colgroup>
				<tr>
					<%
						MailboxSummary summary = summaries.get(Mailbox.INBOX);
						boolean alternating = true;
					%>
					<td nowrap class="td_le" style="padding-left:20px;"><!-- <a href="mail_list.jsp?box=1"> --><b><fmt:message key="mail.InBox"/>&nbsp;<!-- 받은편지함 --></b><!-- </a> --></td>
					<td nowrap></td>
					<td nowrap class="td_ce"><%=(summary == null) ? 0 : summary.getTotalCount()%></td>
					<td nowrap></td>
					<td nowrap class="td_ce"><%=(summary == null) ? 0 : summary.getUnreadCount()%></td>
					<td nowrap></td>
					<td nowrap class="td_ri"><%=(summary == null) ? "0KB" : toSizeString(summary.getTotalSize())%></td>
					<td nowrap></td>
					<td nowrap class="td_ce">
					<%
						if (summary != null && summary.getTotalCount() > 0) {
							%>
							<a href="javascript:OnBackup(1, '<fmt:message key='mail.InBox'/>')" class="br_tit_v">[<fmt:message key="mail.backup"/>&nbsp;<!-- 백업 -->]</a>
							<%
							//out.print("<a href='mail_backup.jsp?box=1&boxname=받은편지함' class='br_tit_v'>[백업]</a>");
						} else {
							out.print("-");
						}
					%>
					</td>
					<td nowrap></td>
					<td nowrap class="td_ce">
					<%
						if (summary != null && summary.getTotalSize() > 0) {
					%>
						<a href="javascript:OnClickClear(<%=Mailbox.INBOX%>)" class="br_tit_v">[<fmt:message key="mail.empty"/>&nbsp;<!-- 비우기 -->]</a></td>
					<%
						} else {
							out.print("-");
						}
					%>
					<td nowrap></td>
					<td nowrap class="td_ce">-</td>
					<td nowrap></td>
					<td nowrap class="td_ce">-</td>
					<td nowrap></td>
					<td nowrap class="td_ce">-</td>
				</tr>
				<tr>
					<td height='1' bgcolor='c3c3c3' colspan=17 style="padding:0;"></td>
				</tr>
				<%
					//받은편지함 서브 트리
					iter = mailboxes.iterator();
					while (iter.hasNext()) {
						Mailbox box = (Mailbox)iter.next();
						if(box.getMainBoxId() !=1) continue;
						summary = summaries.get(box.getID());
				%>
				<tr <%=(alternating) ? "bgcolor='#f9f9f9'" : "" %>>
					<td nowrap class="td_le" style="padding-left: <%=(10 * box.getDepth()) %>px;" title="<%=box.getName()%>">&nbsp;&nbsp;<img src="../common/images/reicon.gif" border=0 align=absmiddle><%-- <a href="mail_list.jsp?box=<%=box.getID()%>"> --%><%=box.getName()%><!-- </a> --></td>
					<td nowrap></td>
					<td nowrap class="td_ce"><%=(summary == null) ? 0 : summary.getTotalCount()%></td>
					<td nowrap></td>
					<td nowrap class="td_ce"><%=(summary == null) ? 0 : summary.getUnreadCount()%></td>
					<td nowrap></td>
					<td nowrap class="td_ri"><%=(summary == null) ? "0KB" : toSizeString(summary.getTotalSize())%></td>
					<td nowrap></td>
					<td nowrap class="td_ce">
					<%
						alternating = !alternating;
						if (summary != null && summary.getTotalCount() > 0) {
							%>
							<a href="javascript:OnBackup(<%=box.getID() %>, '<%=box.getName() %>')" class="br_tit_v">[<fmt:message key="mail.backup"/>&nbsp;<!-- 백업 -->]</a>
							<%
							//out.print("<a href='mail_backup.jsp?box=" + box.getID() + "&boxname="+box.getName()+"' class='br_tit_v'>[백업]</a>");
						} else {
							out.print("-");
						}
					%>
					</td>
					<td nowrap></td>
					<td nowrap class="td_ce">
					<%
						if (summary != null && summary.getTotalSize() > 0) {
					%>
						<a href="javascript:OnClickClear(<%=box.getID()%>)" class="br_tit_v">[<fmt:message key="mail.empty"/>&nbsp;<!-- 비우기 -->]</a>
					<%
						} else {
							out.print("-");
						}
					%>
					</td>
					<td nowrap></td>
					<td nowrap class="td_ce"><a href="javascript:OnClickRename('<%=box.getID()%>','mail','<%=box.getName()%>','<%=box.getTopBoxId() %>')" class="br_tit_v">[<fmt:message key="t.modify"/>&nbsp;<!-- 수정 -->]</a></td>
					<td nowrap></td>
					<td class="td_ce" nowrap><a href="javascript:OnClickDelete('<%=box.getID()%>','mail')" class="br_tit_v">[<fmt:message key="mail.delete"/>&nbsp;<!-- 삭제 -->]</a></td>
					<td nowrap></td>
					<td class="td_ce" nowrap><a href="javascript:OnClickOrder('<%=box.getID()%>','<%=box.getOrders() %>','mail')" class="br_tit_v">[<%=box.getOrders() %>]</a></td>
				</tr>
				<tr>
					<td height='1' bgcolor='c3c3c3' colspan=17 style="padding:0;"></td>
				</tr>
				<%} %>
				<!-- 보낸 편지함 -->
					<tr <%=(alternating) ? "bgcolor='#f9f9f9'" : "" %>>
					<%
						summary = summaries.get(Mailbox.OUTBOX);
					%>
					<td nowrap class="td_le" style="padding-left:20px;"><!-- <a href="mail_list.jsp?box=2"> --><b><fmt:message key="mail.OutBox"/>&nbsp;<!-- 보낸편지함 --></b><!-- </a> --></td>
					<td nowrap></td>
					<td nowrap class="td_ce"><%=(summary == null) ? 0 : summary.getTotalCount()%></td>
					<td nowrap></td>
					<td nowrap class="td_ce"><%=(summary == null) ? 0 : summary.getUnreadCount()%></td>
					<td nowrap></td>
					<td nowrap class="td_ri"><%=(summary == null) ? "0KB" : toSizeString(summary.getTotalSize())%></td>
					<td nowrap></td>
					<td nowrap class="td_ce">
					<%
						if (summary != null && summary.getTotalCount() > 0) {
							%>
							<a href="javascript:OnBackup(2, '<fmt:message key='mail.OutBox'/>')" class="br_tit_v">[<fmt:message key="mail.backup"/>&nbsp;<!-- 백업 -->]</a>
							<%
							//out.print("<a href='mail_backup.jsp?box=2&boxname=보낸편지함' class='br_tit_v'>[백업]</a>");
						} else {
							out.print("-");
						}
					%>					
					</td>
					<td nowrap></td>
					<td nowrap class="td_ce">
					<%
						if (summary != null && summary.getTotalSize() > 0) {
					%>
						<a href="javascript:OnClickClear(<%=Mailbox.OUTBOX%>)" class="br_tit_v">[<fmt:message key="mail.empty"/>&nbsp;<!-- 비우기 -->]</a></td>
					<%
						} else {
							out.print("-");
						}
					%>
					<td nowrap></td>
					<td nowrap class="td_ce">-</td>
					<td nowrap></td>
					<td nowrap class="td_ce">-</td>
					<td nowrap></td>
					<td nowrap class="td_ce">-</td>
				</tr>
				<tr><td height='1' bgcolor='c3c3c3' colspan=17 style="padding:0;"></td></tr>
				<%
					//보낸편지함 서브 트리
					iter = mailboxes.iterator();
					while (iter.hasNext()) {
						Mailbox box = (Mailbox)iter.next();
						if(box.getMainBoxId() !=2) continue;
						summary = summaries.get(box.getID());
						alternating = !alternating;
				%>
				<tr <%=(alternating) ? "bgcolor='#f9f9f9'" : ""%>>
					<td nowrap class="td_le" style="padding-left: <%=(10 * box.getDepth()) %>px;" title="<%=box.getName()%>">&nbsp;&nbsp;<img src="../common/images/reicon.gif" border=0 align=absmiddle><%-- <a href="mail_list.jsp?box=<%=box.getID()%>"> --%><%=box.getName()%><!-- </a> --></td>
					<td nowrap></td>
					<td nowrap class="td_ce"><%=(summary == null) ? 0 : summary.getTotalCount()%></td>
					<td nowrap></td>
					<td nowrap class="td_ce"><%=(summary == null) ? 0 : summary.getUnreadCount()%></td>
					<td nowrap></td>
					<td nowrap class="td_ri"><%=(summary == null) ? "0KB" : toSizeString(summary.getTotalSize())%></td>
					<td nowrap></td>
					<td nowrap class="td_ce">
					<%
						if (summary != null && summary.getTotalCount() > 0) {
							%>
							<a href="javascript:OnBackup(<%=box.getID() %>, '<%=box.getName() %>')" class="br_tit_v">[<fmt:message key="mail.backup"/>&nbsp;<!-- 백업 -->]</a>
							<%
							//out.print("<a href='mail_backup.jsp?box=" + box.getID() + "&boxname="+ box.getName()+"' class='br_tit_v'>[백업]</a>");
						} else {
							out.print("-");
						}
					%>					
					</td>
					<td nowrap></td>
					<td nowrap class="td_ce">
					<%
						if (summary != null && summary.getTotalSize() > 0) {
					%>
						<a href="javascript:OnClickClear(<%=box.getID()%>)" class="br_tit_v">[<fmt:message key="mail.empty"/>&nbsp;<!-- 비우기 -->]</a>
					<%
						} else {
							out.print("-");
						}
					%>
					</td>
					<td nowrap></td>
					<td nowrap class="td_ce"><a href="javascript:OnClickRename('<%=box.getID()%>','mail','<%=box.getName()%>','<%=box.getTopBoxId() %>')" class="br_tit_v">[<fmt:message key="t.modify"/>&nbsp;<!-- 수정 -->]</a></td>
					<td nowrap></td>
					<td class="td_ce" nowrap><a href="javascript:OnClickDelete('<%=box.getID()%>','mail')" class="br_tit_v">[<fmt:message key="t.delete"/>&nbsp;<!-- 삭제 -->]</a></td>
					<td nowrap></td>
					<td class="td_ce" nowrap><a href="javascript:OnClickOrder('<%=box.getID()%>','<%=box.getOrders() %>','mail')" class="br_tit_v">[<%=box.getOrders() %>]</a></td>
				</tr>
				<tr><td height='1' bgcolor='c3c3c3' colspan=17 style="padding:0;"></td></tr>
				<%
					}
					alternating = !alternating;
				%>
				<tr <%=(alternating) ? "bgcolor='#f9f9f9'" : "" %>>
					<%
						summary = summaries.get(Mailbox.DRAFT);
						alternating = !alternating;
					%>
					<td nowrap class="td_le" style="padding-left:20px;"><!-- <a href="mail_list.jsp?box=3"> --><b><fmt:message key="mail.TempBox"/>&nbsp;<!-- 임시보관함 --></b><!-- </a> --></td>
					<td nowrap></td>
					<td nowrap class="td_ce"><%=(summary == null) ? 0 : summary.getTotalCount()%></td>
					<td nowrap></td>
					<td nowrap class="td_ce"><%=(summary == null) ? 0 : summary.getUnreadCount()%></td>
					<td nowrap></td>
					<td nowrap class="td_ri"><%=(summary == null) ? "0KB" : toSizeString(summary.getTotalSize())%></td>
					<td nowrap></td>
					<td nowrap class="td_ce">
					<%
						if (summary != null && summary.getTotalCount() > 0) {
							%>
							<a href="javascript:OnBackup(3, '<fmt:message key='mail.TempBox'/>')" class="br_tit_v">[<fmt:message key="mail.backup"/>&nbsp;<!-- 백업 -->]</a>
							<%
							//out.print("<a href='mail_backup.jsp?box=3&boxname=임시저장함' class='br_tit_v'>[백업]</a>");
						} else {
							out.print("-");
						}
					%>					
					</td>
					<td nowrap></td>
					<td nowrap class="td_ce">
					<%
						if (summary != null && summary.getTotalSize() > 0) {
					%>
						<a href="javascript:OnClickClear(<%=Mailbox.DRAFT%>)" class="br_tit_v">[<fmt:message key="mail.empty"/>&nbsp;<!-- 비우기 -->]</a></td>
					<%
						} else {
							out.print("-");
						}
					%>
					<!-- <a href="javascript:OnClickClear(3)" class="br_tit_v">[비우기]</a> --> 
					<td nowrap></td>
					<td nowrap class="td_ce">-</td>
					<td nowrap></td>
					<td nowrap class="td_ce">-</td>
					<td nowrap></td>
					<td nowrap class="td_ce">-</td>
				</tr>
				<tr><td height='1' bgcolor='c3c3c3' colspan=17 style="padding:0;"></td></tr>
				<!-- 임시보관함 -->
				<tr <%=(alternating) ? "bgcolor='#f9f9f9'" : "" %>>
					<%
						summary = summaries.get(Mailbox.RESERVED);
						alternating = !alternating;
					%>
					<td nowrap class="td_le" style="padding-left:20px;"><!-- <a href="mail_list.jsp?box=6"> --><b><fmt:message key="mail.ReservationBox"/>&nbsp;<!-- 예약편지함 --></b><!-- </a> --></td>
					<td nowrap></td>
					<td nowrap class="td_ce"><%=(summary == null) ? 0 : summary.getTotalCount()%></td>
					<td nowrap></td>
					<td nowrap class="td_ce"><%=(summary == null) ? 0 : summary.getUnreadCount()%></td>
					<td nowrap></td>
					<td nowrap class="td_ri"><%=(summary == null) ? "0KB" : toSizeString(summary.getTotalSize())%></td>
					<td nowrap></td>
					<td nowrap class="td_ce">-</td>
					<td nowrap></td>
					<td nowrap class="td_ce">
					<%
						if (summary != null && summary.getTotalSize() > 0) {
					%>
						<a href="javascript:OnClickClear(<%=Mailbox.RESERVED%>)" class="br_tit_v">[<fmt:message key="mail.empty"/>&nbsp;<!-- 비우기 -->]</a></td>
					<%
						} else {
							out.print("-</td>");
						}
					%>
					<!-- <a href="javascript:OnClickClear(3)" class="br_tit_v">[비우기]</a> -->
					
					<td nowrap></td>
					<td nowrap class="td_ce">-</td>
					<td nowrap></td>
					<td nowrap class="td_ce">-</td>
					<td nowrap></td>
					<td nowrap class="td_ce">-</td>
				</tr>
				<tr><td height='1' bgcolor='c3c3c3' colspan=17 style="padding:0;"></td></tr>
				<tr <%=(alternating) ? "bgcolor='#f9f9f9'" : "" %>>
					<%
						summary = summaries.get(Mailbox.TRASH);
						alternating = !alternating;
					%>
					<td nowrap class="td_le" style="padding-left:20px;"><!-- <a href="mail_list.jsp?box=4"> --><b><fmt:message key="mail.DeletedBox"/>&nbsp;<!-- 지운편지함 --></b><!-- </a> --></td>
					<td nowrap></td>
					<td nowrap class="td_ce"><%=(summary == null) ? 0 : summary.getTotalCount()%></td>
					<td nowrap></td>
					<td nowrap class="td_ce"><%=(summary == null) ? 0 : summary.getUnreadCount()%></td>
					<td nowrap></td>
					<td nowrap class="td_ri"><%=(summary == null) ? "0KB" : toSizeString(summary.getTotalSize())%></td>
					<td nowrap></td>
					<td nowrap class="td_ce">
					<%
						if (summary != null && summary.getTotalCount() > 0) {
							%>
							<a href="javascript:OnBackup(4, '<fmt:message key='mail.DeletedBox'/>')" class="br_tit_v">[<fmt:message key="mail.backup"/>&nbsp;<!-- 백업 -->]</a>
							<%
							//out.print("<a href='mail_backup.jsp?box=4&boxname=휴지통' class='br_tit_v'>[백업]</a>");
						} else {
							out.print("-");
						}
					%>					
					</td>
					<td nowrap></td>
					<td nowrap class="td_ce">
					<%
						if (summary != null && summary.getTotalSize() > 0) {
					%>
						<a href="javascript:OnClickClear(<%=Mailbox.TRASH%>)" class="br_tit_v">[<fmt:message key="mail.empty"/>&nbsp;<!-- 비우기 -->]</a></td>
					<%
						} else {
							out.print("-</td>");
						}
				%>
					<td nowrap></td>
					<td nowrap class="td_ce">-</td>
					<td nowrap></td>
					<td nowrap class="td_ce">-</td>
					<td nowrap></td>
					<td nowrap class="td_ce">-</td>
				</tr>
				<tr><td height='1' bgcolor='c3c3c3' colspan=17 style="padding:0;"></td></tr>
				<%
					//사내문서수신함 
					NotificationSummary noteSummary = noteSsummaries.get(NoteBox.RECEIVEDS);
				%>
				<tr <%=(alternating) ? "bgcolor='#f9f9f9'" : "" %>>
					<td nowrap class="td_le" style="padding-left:20px;"><%-- <a href="/notification/list.htm?boxId=<%=NoteBox.RECEIVEDS%>"> --%><b><fmt:message key="mail.noti.received"/>&nbsp;<!-- 받은쪽지함 --></b><!-- </a> --></td>
					<td nowrap></td>
					<td nowrap class="td_ce"><%=(noteSummary == null) ? 0 : noteSummary.getTotalCount()%></td>
					<td nowrap></td>
					<td nowrap class="td_ce"><%=(noteSummary == null) ? 0 : noteSummary.getUnreadCount()%></td>
					<td nowrap></td>
					<td nowrap class="td_ri">0KB</td>
					<td nowrap></td>
					<td nowrap class="td_ce">-</td>
					<td nowrap></td>
					<td nowrap class="td_ce">-</td>
					<td nowrap></td>
					<td nowrap class="td_ce">-</td>
					<td nowrap></td>
					<td nowrap class="td_ce">-</td>
					<td nowrap></td>
					<td nowrap class="td_ce">-</td>
				</tr>
				<tr><td height='1' bgcolor='c3c3c3' colspan=17 style="padding:0;"></td></tr>
				<%
					alternating = !alternating;
					//사내통신함 서브 트리
					if (data.isEmpty()){
					}else{
						iter = data.iterator();
						HashMap datas = null;
						while (iter.hasNext()){
							datas = (HashMap)iter.next();
							noteSummary = noteSsummaries.get(Integer.parseInt(datas.get("boxid").toString()));
				%>
				<tr <%=(alternating) ? "bgcolor='#f9f9f9'" : "" %>>
					<td nowrap class="td_le" style="padding-left:20px;">&nbsp;&nbsp;<img src="../common/images/reicon.gif" border=0 align=absmiddle><%-- <a href="/notification/list.htm?boxId=<%=datas.get("boxid")%>"> --%><%=datas.get("name")%><!-- </a> --></td>
					<td nowrap></td>
					<td nowrap class="td_ce"><%=(noteSummary == null) ? 0 : noteSummary.getTotalCount()%></td>
					<td nowrap></td>
					<td nowrap class="td_ce"><%=(noteSummary == null) ? 0 : noteSummary.getUnreadCount()%></td>
					<td nowrap></td>
					<td nowrap class="td_ri">0KB</td>
					<td nowrap></td>
					<td nowrap class="td_ce">-</td>
					<td nowrap></td>
					<td nowrap class="td_ce">-</td>
					<td nowrap></td>
					<td nowrap class="td_ce"><a href="javascript:OnClickRename('<%=datas.get("boxid")%>','note','<%=datas.get("name")%>','')" class="br_tit_v">[<fmt:message key="t.modify"/><!-- 편집-->]</a></td>
					<td nowrap></td>
					<td class="td_ce" nowrap><a href="javascript:OnClickDelete('<%=datas.get("boxid")%>','note')" class="br_tit_v">[<fmt:message key="t.delete"/><!-- 삭제-->]</a></td>
					<td nowrap></td>
					<td class="td_ce" nowrap><a href="javascript:OnClickOrder('<%=datas.get("boxid") %>','<%=datas.get("orders")%>','note')" class="br_tit_v">[<%=datas.get("orders") %>]</a></td>
				</tr>
				<tr><td height='1' bgcolor='c3c3c3' colspan=17 style="padding:0;"></td></tr>
				<%
						alternating = !alternating;
						}
					}
				%>
				<%
					//사내문서발신함 
					noteSummary = noteSsummaries.get(NoteBox.SENTS);
				%>
				<tr <%=(alternating) ? "bgcolor='#f9f9f9'" : "" %>>
					<td nowrap class="td_le" style="padding-left:20px;"><%-- <a href="/notification/list.htm?boxId=<%=NoteBox.SENTS %>"> --%><b><fmt:message key="mail.noti.send"/>&nbsp;<!-- 보낸쪽지함 --></b><!-- </a> --></td>
					<td nowrap></td>
					<td nowrap class="td_ce"><%=(noteSummary == null) ? 0 : noteSummary.getTotalCount()%></td>
					<td nowrap></td>
					<td nowrap class="td_ce">-<!--%=(noteSummary == null) ? 0 : noteSummary.getUnreadCount()%--></td>
					<td nowrap></td>
					<td nowrap class="td_ri">0KB</td>
					<td nowrap></td>
					<td nowrap class="td_ce">-</td>
					<td nowrap></td>
					<td nowrap class="td_ce">-</td>
					<td nowrap></td>
					<td nowrap class="td_ce">-</td>
					<td nowrap></td>
					<td nowrap class="td_ce">-</td>
					<td nowrap></td>
					<td nowrap class="td_ce">-</td>
				</tr>
				<tr><td height='1' bgcolor='c3c3c3' colspan=17 style="padding:0;"></td></tr>
			</table>
			<!-- 본문 DATA 끝-->
		</td>
	</tr>
	<tr> 
		<td height="15"></td>
	</tr>
</table>
</div>


<%	
	if (request.getParameter("refresh") != null) {
%>	
	<!-- menu refresh -->
	<script language="javascript">
			//parent.left.location.href = "../common/menuleft.jsp?menucode=MENU01&submenucode=MENU0108";
// 			parent.left.location.href = "/mail/mail_left.jsp";
	</script>
<%
	}
%>
	</form>
	<script language="javascript">
		<%	if (!"MENU080203".equals(menuid) && leftBlock == null) { %>
		top.showMailMenu();
		SetHelpIndex("mail_mailboxes");
		<%	} %>
	</script>
	</body>
</fmt:bundle>
</html>	