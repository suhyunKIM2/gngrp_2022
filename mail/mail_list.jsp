<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page errorPage="../error.jsp" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="nek.mail.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="nek.common.util.*" %>
<%@ page import="nek.common.dbpool.*" %>
<%@ page import="com.oreilly.servlet.*" %>
<%@ page import="javax.mail.*" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="javax.mail.internet.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>		

<%!
	private MailRepository repository = MailRepository.getInstance(); //new MailRepository();
	
	private static int SEARCH_LIKE = 2;
	
	private static SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

	private static HashMap SEARCH_FIELDS = new HashMap();
	static {
		SEARCH_FIELDS.put("subject", new String[] { "subject" });
		SEARCH_FIELDS.put("from", new String[] { "fromname", "sender" });
// 		SEARCH_FIELDS.put("all", new String[] { "subject", "fromname", "sender" });
		SEARCH_FIELDS.put("all", new String[] { "subject", "fromname", "sender", "displayto", "textdescription" });
		SEARCH_FIELDS.put("recieve", new String[] { "displayto" });
		SEARCH_FIELDS.put("all-rec", new String[] { "subject", "displayto" });
	}
/*
	private static String[] builtInMailboxes  = {
		"",
		"받은 편지함",
		"보낸 편지함",
		"임시 보관함",
		"지운편지함",
		"Pending",
		"예약함" //,	"HOT"	//Added By Kim Do Young for 디토소프트
	};
*/
/* 
	private static String[] builtInMailboxes  = {
		"",
		"받은편지함",
		"보낸편지함",
		"임시보관함",
		"지운편지함",
		"Pending",
		"예약편지함", //,	"HOT"	//Added By Kim Do Young for 디토소프트
		"스팸편지함"
	};
*/
%>
<%@ include file="../common/usersession.jsp" %>

<fmt:setLocale value="<%=loginuser.locale %>"/>
<fmt:bundle basename="messages">				
<%
	String[] builtInMailboxes  = {
			"",
			msglang.getString("mail.InBox"),				/* 받은편지함 */
			msglang.getString("mail.OutBox"),				/* 보낸편지함 */
			msglang.getString("mail.TempBox"),				/* 임시보관함 */
			msglang.getString("mail.DeletedBox"),			/* 지운편지함 */
			"Pending",
			msglang.getString("mail.ReservationBox"),		/* 예약편지함 */
			msglang.getString("mail.spamBox")				/* 스팸편지함 */
	};

	//협력업체 권한 체크
// 	if (loginuser.securityId < 1){
// 		String msg = msglang.getString("sch.have.not.peermission"); /* 사용권한이 없습니다. */
// 		out.print("<script language='javascript'>alert('"+msg+"');history.back();</script>");
// 		out.close();
// 		return;
// 	}
	request.setCharacterEncoding("utf-8");
	
	String mainBoxID = request.getParameter("codekey");
	mainBoxID = request.getParameter("topbox");
	if(mainBoxID==null) mainBoxID = "";
	String unReadChk = request.getParameter("unread");
	if(unReadChk==null) unReadChk = "";

	//parameters -------------------------------------------------------
	ParameterParser pp = new ParameterParser(request);
	String cmd			= pp.getStringParameter("cmd", "list");
	int mailboxID		= pp.getIntParameter("box", Mailbox.INBOX);
	String searchText	= pp.getStringParameter("searchtext", "");
	String searchType	= pp.getStringParameter("searchtype", "");
	int pageNo			= pp.getIntParameter("pg", 1);

	//검색인 경우 검색 조건 설정 -------------------------------------------
	SearchConstraint constraint = null;
	if (searchText != "" && searchType != "") {
		String[] searchFields = (String[])SEARCH_FIELDS.get(searchType);
		if (searchFields != null) {
			constraint = new SearchConstraint();
			constraint.setSearchText(searchText);
			constraint.setSearchFields(searchFields);
			constraint.setWhereType(SEARCH_LIKE);
		}
	}

	//DB 작업 --------------------------------------------------------------------
	ListPage listPage = null;
	Mailboxes mailboxes_rec = null;
	Mailboxes mailboxes_send = null;
	int iUnReadCnt = 0;

	DBHandler db = new DBHandler();
	Connection con = null;
	
    String[] sortLists = null;
    
	try {
		con = db.getDbConnection();
		
		String domainName = application.getInitParameter("nek.mail.domain");
		if(!uservariable.userDomain.equals("")) domainName = uservariable.userDomain;
		//개인편지함 가져오기--------------------------------------------------------
		mailboxes_rec = repository.getCustomMailboxes(con, loginuser.emailId, 1, domainName);	//받은편지함
		mailboxes_send = repository.getCustomMailboxes(con, loginuser.emailId, 2, domainName);	//보낸편지함
		//목록 가져오기--------------------------------------------------------------
		if(unReadChk.equals("1")){ // 안않은 메일은 안읽은 메일수를 가져오지 않는다.
			//listPage = repository.unReadlist(con, loginuser.emailId, mailboxID, pageNo, uservariable.listPPage, constraint, domainName);
// 			MailRepositorySummary mailboxSummary  = MailRepository.getInstance().getUnreadRepositoryCount(con, loginuser.emailId, domainName, String.valueOf(mailboxID), constraint);
			//안읽은 갯수
// 			iUnReadCnt = mailboxSummary.getUnreadCount();
		} else if (mailboxID == 1 || "1".equals(mainBoxID)) { // 보낸편지함 또는 보낸편지함 하위 폴더만 안읽은 메일수를 가져온다.
			//listPage = repository.list(con, loginuser.emailId, mailboxID, pageNo, uservariable.listPPage, constraint, domainName, sortLists);
			MailRepositorySummary mailboxSummary  = MailRepository.getInstance().getRepositoryCount(con, loginuser.emailId, domainName, String.valueOf(mailboxID), constraint);
			//안읽은 갯수
			iUnReadCnt = mailboxSummary.getUnreadCount();
		}

	} finally {
		if (con != null) {
			db.freeDbConnection();
		}
	} //END DB 작업

	

	//현재 메일함의 이름 구하기 ----------------------------------------------
	String mailboxName = "" ;
    String NavMailBoxName = msglang.getString("mail.InBox");				/* 받은편지함 */ 
    String NavCenterName = msglang.getString("mail.read");					/* 메일읽기 */
	if (Mailbox.isCustomMailbox(mailboxID)) {
		Mailbox box1 = mailboxes_rec.get(mailboxID);
		Mailbox box2 = mailboxes_send.get(mailboxID);
		if (box1 != null) {
			NavMailBoxName = box1.getName();
            mailboxName = builtInMailboxes[1];
		}else if (box2 != null) {
			NavMailBoxName = box2.getName();
            mailboxName = builtInMailboxes[1];
		}
	} else {
		mailboxName = builtInMailboxes[mailboxID];
        if (mailboxID != 1 ) {                    
            NavCenterName = msglang.getString("mail.mailbox"); 			/* 편지함 */ 
            NavMailBoxName = mailboxName ; 
        }
	}
	if(unReadChk.equals("1")){
		NavMailBoxName = msglang.getString("mail.unread");					/* 읽지않은 메일 */
	}
%>
<%
	// 폴더 이동시 선택 OPTION 문자열 ---------------------------------------------
	StringBuffer selBoxBuf = new StringBuffer();
	int selectBox = 0; // 선택된 메일 MainBoxId(1:받은편지함/2:보낸편지함)
	
	Iterator mailbox_temp1 = mailboxes_rec.iterator();
	Iterator mailbox_temp2 = mailboxes_send.iterator();
	switch(mailboxID) {
		case 1 : selectBox = 1; break;
		case 2 : selectBox = 2; break;
	}
	while (mailbox_temp1.hasNext()) {
		Mailbox mailbox = (Mailbox)mailbox_temp1.next(); 
		if (mailboxID==mailbox.getID()) selectBox = mailbox.getMainBoxId();
	}
	while (mailbox_temp2.hasNext()) {
		Mailbox mailbox = (Mailbox)mailbox_temp2.next();
		if (mailboxID == mailbox.getID()) selectBox = mailbox.getMainBoxId();
	}

	if (mailboxID != Mailbox.INBOX && selectBox == Mailbox.INBOX) {
		selBoxBuf.append("<option value='" + Mailbox.INBOX + "'>"+builtInMailboxes[1]+"</option>");
	}
	
	if (mailboxID != Mailbox.OUTBOX && mainBoxID.equals("2")) {
		selBoxBuf.append("<option value='" + Mailbox.OUTBOX + "'>"+builtInMailboxes[2]+"</option>");
	}
	
	if(mailboxID == 4){
		selBoxBuf.append("<option value='1'>"+builtInMailboxes[1]+"</option>");
		selBoxBuf.append("<option value='2'>"+builtInMailboxes[2]+"</option>");
	}
	//if (mailboxID != Mailbox.HOT) {
	//	selBoxBuf.append("<option value='" + Mailbox.HOT + "'>HOT</option>");
	//}
	//if (mailboxID != Mailbox.DRAFT && mailboxID != Mailbox.INBOX) {
	//	selBoxBuf.append("<option value='" + Mailbox.DRAFT + "'>임시보관함</option>");
	//}
	if (mailboxID != Mailbox.TRASH) {
		selBoxBuf.append("<option value='" + Mailbox.TRASH + "'>"+builtInMailboxes[4]+"</option>");
	}	
// 	selBoxBuf.append("<option value='division'>-----개인편지함-----</option>");
	
	
	Iterator mailbox_iter1 = mailboxes_rec.iterator();
	Iterator mailbox_iter2 = mailboxes_send.iterator();
	int iter1 = 0;
	while (mailbox_iter1.hasNext()) {
		Mailbox mailbox = (Mailbox)mailbox_iter1.next();
		//받은편지함에서 보낸편지함으로 이동은 안된다!!!
// 		if(mailbox.getID()==mailboxID){
// 			selectBox = mailbox.getMainBoxId();
// 		}else if(mailboxID==1){
// 			selectBox = 1;
// 		}else if(mailboxID==2){
// 			selectBox = 2;
// 		}
		
		if (mailboxID != mailbox.getID()) {
			if(selectBox==1){	//받은편지함이면 보낸편지함으로 이동은 막는
				if(mailbox.getMainBoxId()==2) continue;
			} else if (selectBox==2){ 
				if(mailbox.getMainBoxId()==1) continue;
			}
			if (iter1 == 0) {
// 				selBoxBuf.append("<optgroup label='받은 개인편지함'>");
				String mailInboxPersonal = msglang.getString("mail.InBox.personal"); /* 받은 개인편지함 */
				selBoxBuf.append("<option value='division'>-----"+mailInboxPersonal+"-----</option>");
			}
			selBoxBuf.append("<option value='" + mailbox.getID() + "'>"
				+ mailbox.getName()+ "</option>");
			iter1++;
		}
	}
// 	if (iter1 != 0) selBoxBuf.append("</optgroup>");
	//selBoxBuf.append("<option value='division'>-----보낸편지함-----");
	int iter2 = 0;
	while (mailbox_iter2.hasNext()) {
		Mailbox mailbox = (Mailbox)mailbox_iter2.next();
		//받은편지함에서 보낸편지함으로 이동은 안된다!!!
// 		if(mailbox.getID()==mailboxID){
// 			selectBox = mailbox.getMainBoxId();
// 		}else if(mailboxID==1){
// 			selectBox = 1;
// 		}else if(mailboxID==2){
// 			selectBox = 2;
// 		}
		if (mailboxID != mailbox.getID()) {
			if(selectBox==1){	//받은편지함이면 보낸편지함으로 이동은 막는
				if(mailbox.getMainBoxId()==2) continue;
			} else if (selectBox==2){ 
				if(mailbox.getMainBoxId()==1) continue;
			}
			if (iter2 == 0) {
// 				selBoxBuf.append("<optgroup label='보낸 개인편지함'>");
				String mailOutboxPersonal = msglang.getString("mail.OutBox.personal"); /* 보낸 개인편지함 */
				selBoxBuf.append("<option value='division'>-----"+mailOutboxPersonal+"-----</option>");
			}
			selBoxBuf.append("<option value='" + mailbox.getID() + "'>"
				+ mailbox.getName()+ "</option>");
			iter2++;
		}
	}
// 	if (iter2 != 0) selBoxBuf.append("</optgroup>");
	String selBoxes = selBoxBuf.toString();
%>
<!DOCTYPE html>
<html>

<head>
<title><fmt:message key="mail.list"/>&nbsp;<!-- 메일목록 --></title>
<%@ include file="/WEB-INF/common/include.mata.jsp" %>
<%@ include file="/WEB-INF/common/include.jquery.jsp" %>
<%@ include file="/WEB-INF/common/include.jqgrid.jsp" %>
<%@ include file="/WEB-INF/common/include.common.jsp" %>

<link type="text/css" href="/common/css/styledButton.css" rel="stylesheet" />

<script src="/common/jquery/plugins/jquery.validate.js"  type="text/javascript"></script>
<script src="/common/jquery/plugins/modaldialogs.js"  type="text/javascript"></script>

<style type="text/css"> 

select, option {max-width:200px;}

/* Add some nice box-shadow-ness to the modal tooltip */
.ui-tooltip, .qtip{
		max-width: 800px;
		min-width: 230px;
}
#qtip-modal{
	width: 550px;
 
	-moz-box-shadow: 0 0 10px 1px rgba(0,0,0,.5);
	-webkit-box-shadow: 0 0 10px 1px rgba(0,0,0,.5);
	box-shadow: 0 0 10px 1px rgba(0,0,0,.5);
}
 
#qtip-modal .qtip-content{
	padding: 10px;
}
.qtip {max-width:850px;}
.ui-jqgrid .ui-jqgrid-btable, .ui-jqgrid .ui-pg-table{table-layout: auto;}
</style>

<script language="javascript">
var objWin;
var winx = 0;
var winy = 0;

/* 리스트 첨부 조회 */
function listShowAttach() {
    // Make sure to only match links to wikipedia with a rel tag
   //var strUrl = "/bbs/download_attach_info.htm?";
   var strUrl = "./get_attach_info.jsp?message_name=";
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
					url: strUrl + $(this).attr('rel') + "&box=<%=mailboxID %>"
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

/* 메일 팝업 액션 */ 
function OnClickAction(cmd) {
	var mailboxID = '<%=mailboxID%>';	
	var unReadCheck = '<%=unReadChk%>';
	var readCount = 0;
	var index ;
	
	var msgs = document.getElementsByName("mailid");
	for (var i = 0; i < msgs.length; i++) {
		if (msgs[i].value==fmMailList.message_name.value) {
			msgs[i].checked = true;
			index = i;
			break;
		}
	}
	var ret = $("#dataGrid").getRowData(index+1);   
   	var read = ret.readCheck;
    if(read == "false"){
    	readCount = readCount+1;
    }
	switch(cmd){
		case "read" : 
			OnClickOpenNewWin(fmMailList.message_name.value);
			break;
		case "reply" :
			var url = "./mail_form.jsp?message_name=" + fmMailList.message_name.value + "&cmd=" +cmd;
			OpenWindow( url, "", "850" , "620" );
			break;
		case "forward" :
			var url = "./mail_form.jsp?message_name=" + fmMailList.message_name.value + "&cmd=" +cmd;
			OpenWindow( url, "", "850" , "620" );
			break;
		case "search1" :
			fmMailList.searchtext.value = fmMailList.fromaddress.value;
			fmMailList.searchtype.value= "from";
			fmMailList.method = "post";
			fmMailList.pg.value = 1;
			fmMailList.action = "./mail_list.jsp";
			//fmMailList.submit();
			gridReload();
			break;
		case "search2" :
			fmMailList.searchtext.value = fmMailList.fromaddress.value;
			fmMailList.searchtype.value= "recieve";
			fmMailList.method = "post";
			fmMailList.pg.value = 1;
			fmMailList.action = "./mail_list.jsp";
			//fmMailList.submit();
			gridReload();
			break;
		case "addressbook_s" :
			//var url = "/addressbook/addressbook_s_form.jsp?acid=ALL&name=" + encodeURI(fmMailList.fromname.value) + "&email=" + fmMailList.fromaddress.value;
			var url = "/addressbook/form.htm?name=" + encodeURI(fmMailList.fromname.value) + "&email=" + encodeURI(fmMailList.fromaddress.value);
			OpenWindow( url, "", "755" , "610" );
			break;
		case "spam" :
// 			var url = "./mail_spam_pop.jsp?message_name=" + fmMailList.message_name.value + "&email=" + encodeURI(fmMailList.fromaddress.value);
			var url = "./mail_spam_pop.jsp?message_name=" + fmMailList.message_name.value + "&email=" + encodeURI(fmMailList.fromaddress.value)+"&mailboxID="+mailboxID+"&readCount="+readCount+"&unReadCheck="+unReadCheck;
			OpenWindow( url, "", "300" , "200" );
			break;
		case "markread" :
			
// 			fmMailList.ctype.value = "1";
// 			fmMailList.method = "post";
// 			fmMailList.action = "./mail_markread.jsp";
// 			fmMailList.submit();

			var uarl = "./mail_markread.jsp";
			$("input[name=isread]").val(1);
			$("input[name=ctype]").val("1");
			
			$.ajax({
				type: "POST",
				url: uarl,
				data: $("form[name=fmMailList]").serialize(),
				success : function(data){
					top.resetLeftCount(mailboxID, 1, readCount, 'read', null, unReadCheck);
					$("#dataGrid").trigger("reloadGrid");
				}
		  	});
			break;
			
		case "markunread" :
// 			fmMailList.ctype.value = "1";
// 			fmMailList.method = "post";
// 			fmMailList.action = "./mail_markunread.jsp";
// 			fmMailList.submit();
			
			var uarl = "./mail_markunread.jsp";
			$("input[name=isread]").val(1);
			$("input[name=ctype]").val("1");
			
			if(readCount == 1){
				readCount = 0;
			}else{
				readCount = 1;
			}
			
			$.ajax({
				type: "POST",
				url: uarl,
				data: $("form[name=fmMailList]").serialize(),
				success : function(data){
					top.resetLeftCount(mailboxID, 1, readCount, 'unread', null, unReadCheck);
					$("#dataGrid").trigger("reloadGrid");
				}
		  	});
			break;
			
		case "rule" :
			var url = "./mail_rule_popup.jsp?sendaddr=" + encodeURI(fmMailList.fromaddress.value);
			OpenWindow( url, "", "700" , "160" );
			break;
	}
}

function OnClickCheckReceipt(messageName) {
	window.showModalDialog("mail_receiptstatus.jsp?message_name=" + messageName,"","dialogHeight: 300px; dialogWidth: 400px; edge: Raised; center: Yes; help: No; resizable: No; status: No; Scroll: no");
}

function OnClickDelete() {
	var conf_delMsg = "<fmt:message key='c.delete'/>";					//삭제 하시겠습니까?
	var aler_notMsg = "<fmt:message key='mail.c.notDoc.delete'/>";	//삭제할 문서가 없습니다!
	var aler_selMsg = "<fmt:message key='c.del.select.required'/>";	//삭제할 문서를 선택하세요!

	var mailboxID = '<%=mailboxID%>';	
	var unReadCheck = '<%=unReadChk%>';

	var readCount = 0;
	var selRow = $("#dataGrid").getGridParam('selarrrow');
	var ids = $("#dataGrid").jqGrid('getDataIDs');
	var selectCount= selRow.length;
	var eachCount = ids.length;
	
	for(var i=0 ; i<eachCount ; i++){
		 var check = false;
         var chedata = $("#dataGrid").getRowData(ids[i]);
         
         $.each(selRow, function (index, value) {
             if (value == ids[i])
                 check = true;
         });
         
         if(check){
        	var read= chedata.readCheck;
   		    if(read == "false"){
   		    	readCount = readCount+1;
   		    }
         }
	}
	
	var selected = false;
	var msgs = document.getElementsByName("mailid");
	
	if (msgs.length == 0) { alert(aler_notMsg); return; }
	
	for (var i = 0; i < msgs.length; i++)
		if (msgs[i].checked) { selected = true; break; }

	if (!selected) { alert(aler_selMsg); return; }

	var box = getUrlVar("box");
	if (box == 4) 	
		conf_delMsg = "<fmt:message key='mail.note.delete'/>"; /*주의하십시오 ! \n지운편지함에서 삭제 시 메일이 완전히 삭제됩니다.\n삭제하시겠습니까 ?*/

	if (confirm(conf_delMsg)) {
		fmMailList.ctype.value = "1";
		$.ajax({
			type: "POST",
			url: "mail_delete.jsp",
			data: $("form[name=fmMailList]").serialize(),
// 			beforeSend: function() { waitMsg(); },
// 			complete: function() { $.unblockUI(); },
			error: function(request, status, error) { /* $.unblockUI(); */
				alert("code : " + request.status + " \r\nMessage : " + request.responseText);
			},
			success : function(response, status, request){
// 				top.showMailMenu();
				top.resetLeftCount(mailboxID, selectCount, readCount, 'deleteList', null, unReadCheck);
				$("#dataGrid").trigger("reloadGrid");
			}
	  	});
	}
}

//메일 읽음/ 안읽음 
function OnClickMarker(type){

	var uarl="";
	var cmd ="";
	
	if(type=="1"){	//읽음 표시
// 		fmMailList.action = "mail_markread.jsp";
		uarl = "mail_markread.jsp";
		cmd = "read";
	}else{	//안읽음표시
// 		fmMailList.action = "mail_markunread.jsp";
		uarl = "mail_markunread.jsp";
		cmd = "unread";
	}
	
	var readCount = 0;
	var selRow = $("#dataGrid").getGridParam('selarrrow');
	var ids = $("#dataGrid").jqGrid('getDataIDs');
	var selectCount= selRow.length;
    
	if (selectCount < 0) {
		alert("<fmt:message key='mail.c.select.mail'/>");//메일을 선택해 주십시오.
		return;
	}
	var eachCount = ids.length;
	
	for(var i=0 ; i<eachCount ; i++){
		 var check = false;
         var chedata = $("#dataGrid").getRowData(ids[i]);
         
         $.each(selRow, function (index, value) {
             if (value == ids[i])
                 check = true;
         });
         
         if(check){
        	 var read= chedata.readCheck;
        	 if(type == "1"){
     		    if(read == "false"){
     		    	readCount = readCount+1;
     		    }
     	    }else{
     	    	if(read == "true"){
     	    		readCount = readCount+1;
     	    	}
     	    }
         }
	}

	$("input[name=ctype]").val("1");
	
	var mailboxID = '<%=mailboxID%>';	
	var unReadCheck = '<%=unReadChk%>';
	
	$.ajax({
		type: "POST",
		url: uarl,
		data: $("form[name=fmMailList]").serialize(),
		success : function(data){
			top.resetLeftCount(mailboxID, 0, readCount, cmd, null, unReadCheck);
			$("#dataGrid").trigger("reloadGrid");
		}
  	});
	
// 	fmMailList.isread.value = readCount; 
// 	fmMailList.ctype.value = "1";
// 	fmMailList.method = "post";
// 	fmMailList.submit();
	
}

function getUrlVars() {
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++) {
        hash = hashes[i].split('=');
        vars.push(hash[0]);
        vars[hash[0]] = hash[1];
    }
    return vars;
}

function getUrlVar(name) {
	return getUrlVars()[name];
}

function OnSpamDelete() {

	var unReadCheck = '<%=unReadChk%>';
	
	var readCount = 0;
	var selRow = $("#dataGrid").getGridParam('selarrrow');
	var ids = $("#dataGrid").jqGrid('getDataIDs');
	var selectCount= selRow.length;
	
	if (selectCount < 0) {
		alert("<fmt:message key='mail.c.select.mail'/>");//메일을 선택해 주십시오.
		return;
	}
    var eachCount = ids.length;
    
	for(var i=0 ; i<eachCount ; i++){
		 var check = false;
         var chedata = $("#dataGrid").getRowData(ids[i]);
         
         $.each(selRow, function (index, value) {
             if (value == ids[i])
                 check = true;
         });
         
         if(check){
        	var read= chedata.readCheck;
   		    if(read == "false"){
   		    	readCount = readCount+1;
   		    }
         }
	}
	
	if (confirm("<fmt:message key='mail.c.select.unblock'/>")) {
// 		fmMailList.action = "mail_spam_delete.jsp";
		fmMailList.ctype.value = "1";
// 		fmMailList.method = "post";
// 		fmMailList.submit();
		$.ajax({
			type: "POST",
			url:  "mail_spam_delete.jsp",
			data: $("form[name=fmMailList]").serialize(),
			success : function(data){
				top.resetLeftCount(7, selectCount, readCount, 'spamDelete');
				$("#dataGrid").trigger("reloadGrid");
			}
	  	});
	}
}

function OnClickClearTrash() {
	if (confirm("<fmt:message key='mail.c.delete.all.trash'/>")) { //휴지통 내의 모든 문서를 삭제합니다. 계속하시겠습니까?
// 		fmMailList.action = "/mail/mail_cleartrash.jsp";
// 		fmMailList.method = "post";
// 		fmMailList.submit();
		var  unReadCnt = $("#unReadCnt").text();
		$.ajax({
			type: "POST",
			url:  "/mail/mail_cleartrash.jsp",
			data: $("form[name=fmMailList]").serialize(),
			success : function(data){
				top.resetLeftCount(4, 0, null, 'clearTrash');
				$("#dataGrid").trigger("reloadGrid");
			}
	  	});
	}
}

function reMailSend(){
	var msgs = document.getElementsByName("mailid");
	var selected = false;
	var totCnt = 0;
	var mailId = "";
	for (var i = 0; i < msgs.length; i++) {
		if (msgs[i].checked) {
			selected = true;
			mailId = msgs[i].value;
			totCnt = totCnt + 1;
		}
	}

	if (!selected) {
		alert("<fmt:message key='mail.c.select.redial'/>");//재발신 할 문서를 선택해주십시오.
		return;
	}
	if(totCnt >1){
		alert("<fmt:message key='mail.c.selectOne.redial'/>!");//재발신 할 문서는 1개만 선택하세요!
		return;
	}
	
	var url = "./mail_form.jsp?message_name=" + mailId + "&reSend=1" ;
	OpenWindow( url, "", "850" , "620" );
}
function OnClickPop3() {
	self.location = "/mail/mail_pop3support.jsp";
}

function OnClickMove() {
	// 이동할 편지함을 선택하세요!
	var moveMsg = "<fmt:message key='mail.c.select.mailbox.move'/>";
	var targetMailbox = fmMailList.targetFolder.value;

	if (targetMailbox == "title" || targetMailbox == "division") {
		alert(moveMsg);
		return;
	}

	var msgs = document.getElementsByName("mailid");
	if (msgs.length == 0) {
		return;
	}

	var selected = false;
	for(var i = 0; i < msgs.length; i++) {
		if (msgs[i].checked) {
			selected = true;
			break;
		}
	}

	if (!selected) {
		alert(moveMsg);
		return;
	}
	
	var moveboxID = $("select[name=targetFolder]").val();	//이동할 boxId
	var mailboxID = '<%=mailboxID%>';	
	var unReadCheck = '<%=unReadChk%>';
	
	var readCount = 0;
	var selRow = $("#dataGrid").getGridParam('selarrrow');
	var ids = $("#dataGrid").jqGrid('getDataIDs');
	var selectCount= selRow.length;
	var eachCount = ids.length;
	
	for(var i=0 ; i<eachCount ; i++){
		 var check = false;
         var chedata = $("#dataGrid").getRowData(ids[i]);
         
         $.each(selRow, function (index, value) {
             if (value == ids[i])
                 check = true;
         });
         
         if(check){
        	var read= chedata.readCheck;
   		    if(read == "false"){
   		    	readCount = readCount+1;
   		    }
         }
	}
	
	fmMailList.ctype.value = "1";
	$.ajax({
		type: "POST",
		url: "mail_move.jsp",
		data: $("form[name=fmMailList]").serialize(),
// 		beforeSend: function() { waitMsg(); },
// 		complete: function() { $.unblockUI(); },
		error: function(request, status, error) { /* $.unblockUI(); */
			alert("code : " + request.status + " \r\nMessage : " + request.responseText);
		},
		success : function(response, status, request){
// 			top.showMailMenu();
			top.resetLeftCount(mailboxID, selectCount, readCount, 'moveList', moveboxID, unReadCheck);
			$("#dataGrid").trigger("reloadGrid");
		}
  	}); 
}

function OnClickToggleAllSelect() {
	var items = document.getElementsByName("mailid");
	if (items != null && items.length > 0) {
		var checked = !items[0].checked;
		for (var i = 0; i < items.length; i++) {
			items[i].checked = checked;
		}
	}
}

function OnClickSearch() {
	var searchtext = fmMailList.searchtext.value;

	if (searchtext == "") {
		alert("<fmt:message key='v.query.required'/>");//검색어를 입력하여 주십시요!
		fmMailList.searchtext.focus();
		return;
	}

	fmMailList.method = "post";
	fmMailList.pg.value = 1;
	fmMailList.action = "./mail_list.jsp";
	fmMailList.submit();
}

function OnClickEdit(message_name) {
	var url = "/mail/mail_form.jsp?message_name=" + message_name + "&box=<%=mailboxID %>";
	
	//OpenWindowNoScr( url, "", "755" , "610" );
	OpenWindow( url, "", "850" , "650" );
	//objWin = OpenLayer(url, "Mail", winWidth, winHeight,isWindowOpen);	//opt는 top, current
}


function OnClickOpen(message_name, importance) {
	var readChk = document.getElementById("mchk_"+message_name);	//안읽은 편지 읽음표시
	var boldObj = document.getElementById("bl_"+message_name);	//제목강조 제거
	var unReadCheck = '<%=unReadChk%>';
	var mailboxID = '<%=mailboxID %>'; 
	<%if(mailboxID != Mailbox.OUTBOX) {%>
		if(readChk.src.indexOf("icon-mail.png")>-1){
			readChk.src = "../common/images/icon-mail-open.png";
			//if (boldObj.innerText) boldObj.innerHTML = boldObj.innerText;
			$(boldObj).html( $(boldObj).text() );
		}
	<%}%>
	/*
	var fr_list = parent.document.getElementById("fr_list");
	var fr_right = parent.document.getElementById("fr_preview_right");
	var fr_bottom = parent.document.getElementById("fr_preview_bottom");

	var url = "/mail/mail_read.jsp?message_name=" + message_name + "&box="+mailboxID+"&importance=" + importance;
	var urlRB = "/mail/mail_view.jsp?message_name=" + message_name + "&box="+mailboxID+"&importance=" + importance;
	*/
	
	var url = "/mail/mail_read.jsp?message_name=" + message_name + "&box="+mailboxID+"&importance=" + importance+"&unread="+unReadCheck;

	//objWin = OpenLayer(url, "Mail", winWidth, winHeight, isWindowOpen);	//opt는 top, current
	OpenWindow( url, "", "900" , "650" );	//전자메일 무조건 새창 : htns에 한함. - 2013-12-20 김정국
	
}

function OnClickOpenNewWin(messageName) {
	
	var WinWidth = 900 ; 
	var WinHeight = 620 ; 
	var winleft = (screen.width - WinWidth) / 2;
	var wintop = (screen.height - WinHeight) / 2;
	var UrlStr = "./mail_read.jsp?front=&message_name=" + messageName ;
	var win = window.open(UrlStr , "" , "scrollbars=yes,width="+ WinWidth +", height="+ WinHeight +", top="+ wintop +", left=" + winleft  );
}

function OnClickSave(){
	var msgs = document.getElementsByName("mailid");
	if (msgs.length == 0) {
		alert("<fmt:message key='mail.c.notDoc.selected'/>");//선택된 문서가 없습니다!
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
		alert("<fmt:message key='mail.c.select.doc'/>");//문서를 선택하세요!
		return;
	}
	
	fmMailList.action = "mail_backup_select.jsp";
	fmMailList.method = "POST";
	fmMailList.submit();
}

function goSubmit(cmd){
	if(cmd=="NEW"){
		//document.location.href = "./mail_form.jsp";
		var url = "/mail/mail_form.jsp";
		
		//objWin = OpenLayer(url, "Mail", winWidth, winHeight, isWindowOpen);	//opt는 top, current
		OpenWindow( url, "", "850" , "650" );	//전자메일 무조건 새창 : htns에 한함. - 2013-12-20 김정국
		
		//objWin = OpenLayer(url, "Mail", "850", "600",isWindowOpen);	//opt는 top, current
		//OpenWindow( url, "", "850" , "650" );
		//targetWin = OpenWindowNoScr( url, "", "800" , "650" );
		
	}else if("list"){
		//document.location.href = "mail_list.jsp";
		fmMailList.searchtext.value= "";
		fmMailList.searchtype.value= "";
		fmMailList.action = "mail_list.jsp";
		fmMailList.method = "POST";
		fmMailList.submit();
	}
}

function goMail(url){
	OpenWindowNoScr( url, "", "800" , "620" );
}

function OnMailCancel(msgID, nekMsgId) {
	if (confirm("<fmt:message key='mai.c.sent.cancel'/>")) {//정말 발송된 메일을 취소하시겠습니까?=Are you sure you want to cancel the mail was really sent?

		fmMailList.action = "mail_cancel.jsp";
		fmMailList.ctype.value = "1";
		fmMailList.message_name.value = msgID;
		fmMailList.nekmsgid.value = nekMsgId;
		fmMailList.method = "post";
		fmMailList.submit();
	}
}

function div_resize() {
	var objDiv = document.getElementById("viewList");
	var objTbl = document.getElementById("viewTable");
	var objPg = document.getElementById("viewPage");

	//objDiv.style.width = document.body.clientWidth - 30;
   	objDiv.style.height = document.body.clientHeight - 110 ;
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

function goSpam(){
	var url = "/mail/mail_spamlist.jsp";
	OpenWindow( url, "", "350" , "450" );
}

function showDetailSearch(){
	var deSearch = document.getElementById("detail_search");
	if(deSearch.style.display==""){
		deSearch.style.display = "none";
	}else{
		deSearch.style.display = "";
	}
}

function onClickcr(){
	var frm = document.fmMailList;
	
	document.getElementsByName("sel_period")[0].selectedIndex = 6;
}

function validCheck(){
	var frm = document.fmMailList;
	
	var startDate = document.getElementsByName("startDate")[0];
	var endDate = document.getElementsByName("endDate")[0];
	var sel_period = document.getElementsByName("sel_period")[0];

	var sType = sel_period.options[sel_period.selectedIndex].value;
	
	//var sType = frm.sel_period.options[frm.sel_period.selectedIndex].value;
	if(sType!=0){	//전체가 아니면 날짜 체크함.
		if(startDate.value==""){
			alert("<fmt:message key='appr.c.startdate'/>");	/*시작일을 입력 해주세요.*/
			startDate.focus();
			return false;
		}
		if(endDate.value==""){
			alert("<fmt:message key='appr.c.enddate'/>");	/*시작일을 입력 해주세요.*/
			endDate.focus();
			return false;
		}
		if(startDate.value>endDate.value){
			alert("<fmt:message key='sch.end.early.start'/>");	/*종료일이 시작일보다 작을 수 없습니다.*/
			return false;
		}
	}
	return true;
}

//상세검색 기간 콤보
function setDatePeriod(){
	var frm = document.fmMailList;
	var newDt = new Date();
	var befDate = "";
	var nowDate = converDateString(newDt);
	
	var sel_period = document.getElementsByName("sel_period")[0];
	
	var sType = sel_period.options[sel_period.selectedIndex].value;
	if(sType==1){	//1주일
		newDt.setDate( newDt.getDate() - 7 );
		befDate = converDateString(newDt);
	}else if(sType==2){	//1개월
		newDt.setMonth( newDt.getMonth() - 1 );
		befDate = converDateString(newDt);
	}else if(sType==3){	//3개월
		newDt.setMonth( newDt.getMonth() - 3 );
		befDate = converDateString(newDt);
	}else if(sType==4){	//6개월
		newDt.setMonth( newDt.getMonth() - 6 );
		befDate = converDateString(newDt);
	}else if(sType==5){	//1년
		newDt.setFullYear( newDt.getFullYear() - 1 );
		befDate = converDateString(newDt);
	}else if(sType==0){	//전체
		berDate = "";
		nowDate = "";
	}
	
	if(sType!=99){
		document.getElementsByName("startDate")[0].value= befDate;
		document.getElementsByName("endDate")[0].value= nowDate;
	}
}

function converDateString(dt){
	return dt.getFullYear() + "-" + addZero(eval(dt.getMonth()+1)) + "-" + addZero(dt.getDate());
}

function addZero(i){
	var rtn = i + 100;
	return rtn.toString().substring(1,3);
}


//상세검색 메일함 - 전체인 경우만  필터 제공(휴지통/스팸함)
function setChangeMailbox(){
	var frm = document.fmMailList;
	var sel_mailbox = document.getElementsByName("sel_mailbox")[0];
	var mailBoxId = sel_mailbox.options[sel_mailbox.selectedIndex].value;
	if(mailBoxId==0){
		jQuery("input[name='rdo_srch']").each(function(i) {
			jQuery(this).attr('disabled', false);
		});
	}else{
		jQuery("input[name='rdo_srch']").each(function(i) {
			jQuery(this).attr('disabled', true);
		});
	}
}
</script>

<!-- jqgrid 추가 -->
<script type="text/javascript">
	var mailboxID = "<%=mailboxID %>";
	var unread = "<%=unReadChk%>";
	var codekey = "<%=mainBoxID %>";
	
	// 배열에 값이 있으면 넣지 않고 반환, 있으면 넣고 반환.001 LSH
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
		
		//상세검색 엔터키 적용
		$("input[name=ipt_receiver],  input[name=ipt_content]").keydown(function(evt){
			if (evt.keyCode==13)
				goSearch();
		});
		
		$('input[id=startDate], input[id=endDate]').datepicker({
			showAnim: "slide",
			showOptions: {
				origin: ["top", "left"] 
			},
			dateFormat: 'yy-mm-dd',
			buttonText: 'Calendar',
			altField: "#alternate",
			altFormat: "DD, d MM, yy",
			changeMonth: true,
			changeYear: true,
			showOtherMonths: true,
			selectOtherMonths: true,
			onClose : function(selectedDate) {
			 if (jQuery(this).attr('name') == 'startDate') {
					jQuery('input[name=endDate]').datepicker("option", "minDate", selectedDate );
				} else if (jQuery(this).attr('name') == 'endDate') {
					jQuery('input[name=startDate]').datepicker("option", "maxDate", selectedDate);
				}
			},
			
			beforeShow: function() {
			}
		});
		
		$.jgrid.defaults = $.extend($.jgrid.defaults,{loadui:"enable",hidegrid:false,gridview:false});
		var grid = $("#dataGrid");
		$("#dataGrid").jqGrid({
			ajaxGridOptions: {cache: false},
		    scroll: false,
		   	url:"./data/mail_list_json.jsp?box=" + mailboxID + "&unread=" + unread + "&codekey=" + codekey + "&searchtype=" + $("input[name=searchtype]").val() + "&searchtext=" + encodeURI($("input[name=searchtext]").val(), "UTF-8"),
			datatype: "json",
			width: '100%',
			height:'100%',
		   	colNames:['<img src="../common/images/btn_checkbox.gif" onClick="OnClickToggleAllSelect()" style="cursor:hand;" align=absmiddle hidefocus=true>',
		   			<%
		   				if (mailboxID == Mailbox.OUTBOX || 
		   					mailboxID == Mailbox.DRAFT ||
		   					mailboxID == Mailbox.RESERVED || mainBoxID.equals("2")) {
		   					out.print("'"+msglang.getString("mail.recipient")+"'"); //수신인
		   				} else {
		   					out.print("'"+msglang.getString("mail.sender")+"'"); //발신인
		   				}
		   			%>,
		   				'<img src="../common/images/icon-flag.png" style="cursor:hand;" align=absmiddle hidefocus=true>',
		   				'<img src="../common/images/icons/icon_attach.gif" style="cursor:hand;" align=absmiddle hidefocus=true>',
		   				'<img src="../common/images/icon-mail.png" style="cursor:hand;" align=absmiddle hidefocus=true>',
		   				'<img src="/common/images/icon-mail-send-receive.png" style="cursor:hand;" align=absmiddle hidefocus=true>',	/*회신*/
		   				'<fmt:message key="mail.subject"/>', /* 제목 */
		   				'<%=(mailboxID == Mailbox.RESERVED) ? msglang.getString("book.date") /* 예약일시 */ : msglang.getString("t.dateTime") /* 일시 */ %>',
		   				'<fmt:message key="mail.size"/>', /* 크기 */ 
		   				'readCheck' /*읽음체크*/
		   	], 
		   	colModel:[
		  	   	{name:'checkbox',index:'checkbox', width:10, align:"center", sortable: false},
		<%	if (mailboxID == Mailbox.OUTBOX || mailboxID == Mailbox.DRAFT || mailboxID == Mailbox.RESERVED || mainBoxID.equals("2")) {	%>
			  	   	{name:'displayto',index:'displayto', width:70, align:"left"},
  	   	<%	}else{	%>
		   		{name:'fromname',index:'fromname', width:70, align:"left"},
   		<%	}	%>
		   		{name:'importance',index:'importance', width:15, align:"center", padding:"0px;"},
				{name:'hasattachment',index:'hasattachment', width:15, align:"center"},
		   		{name:'isread',index:'isread', width:15, align:"center"},
		   		{name:'isreply',index:'isreply', width:15, align:"center"},
		   		{name:'subject',index:'subject', width:280, align:"left"},
		   		{name:<%=(mailboxID == Mailbox.RESERVED) ? "'reserved'" : "'created'" %>,
		   				index:<%=(mailboxID == Mailbox.RESERVED) ? "'reserved'" : "'created'" %>, width:75, align:"center"},
		   		{name:'mailsize',index:'mailsize', width:40, align:"right"},
		   		{name:'readCheck',index:'readCheck', hidden:true}
			],	
			rowNum:${userConfig.listPPage},
<%-- 		   	rowList: [10,20,30].checkPush(<%=uservariable.listPPage %>).sort(), --%>
		   	mtype: "GET",
			prmNames: {search:null, nd: null, rows: "rowsNum", page: "pageNo", sort: "sortColumn", order: "sortType"},  
		   	pager: '#dataGridPager',
		    viewrecords: true,
		    sortname: 'created',
		    sortorder: 'desc',
		    //pginput: false,
		    //gridview: true, 
		    //rownumbers: true,
		    
			multiselect:true, //10.05 일 김정국 수정.
		    onSelectRow: function(id){	//1~...
		    	var chk = document.getElementsByName("mailid");
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
		    	$('#searchBlock').unblock();
		        <%if (!(mailboxID==3||mailboxID==6)) {%>
		        $('tr', this).each(function(key, item) {
			      	$($('td:eq(2)',item)).qtip({
							content: document.getElementById("val").innerHTML,
							style: {width:200,padding:0,background:'#fff',color:'#FFF','font-size':'11px',
							textAlign: 'left',
							border: {width:1,radius:1,color:'#72a9d3'},
							//tip: 'botttomLeft',
							
							name: 'dark' // Inherit the rest of the attributes from the preset dark style
						},

						position: {
							//target: 'mouse',
							my: 'left center', // ...at the center of the viewport
							at: 'right center',
						
							corner: {target:'topMiddle', tooltip:'bottomLeft'},
							adjust: {
								screen: true
							}
						},
						hide: {when:'mouseout', fixed:true, delay:100},
						show: {
							when: { target: false, event: 'mouseover' },
							delay: 100,
							solo: false,
							ready: false
						},
						events: {
							show: function(event, api) {
								var mails = document.getElementsByName("mailinfo");
						      	if($($('td:eq(2)',item))){
						      		if(mails[key-1]){
						      			var tmp = mails[key-1].value.split('／');;
						      			document.fmMailList.message_name.value = tmp[0];
						      			document.fmMailList.fromname.value = tmp[1];
						      			document.fmMailList.fromaddress.value = tmp[2];
						      		}
						      	}
							}
						}
					})
		        });
		        <%}%>
		        
		    	/* jqGrid PageNumbering Trick */
		    	var i, myPageRefresh = function(e) {
		            var newPage = $(e.target).text();
		            $("#dataGrid").trigger("reloadGrid",[{page:newPage}]);
		            e.preventDefault();
		        };
		        
		    	/* MAX_PAGERS is Numbering Count. Public Variable : ex) 5 */
		        jqGridNumbering( $("#dataGrid"), this, i, myPageRefresh );
		
		        listShowAttach();
		        
		    	$('#totalCnt').html($('#dataGrid').jqGrid('getGridParam','records')); 

//		    	var unReadCnt = $('#dataGrid').jqGrid('getGridParam', 'userData');
//		    	if (unReadCnt != null && unReadCnt != '')
//		    		$('#unReadCnt').html(unReadCnt); 
		    }
		}); 
	
		/* 받은 편지함에서 회신확인 보여줌*/
		if (mailboxID == 1) {
			$('#dataGrid').showCol('isreply');
		} else {
			$('#dataGrid').hideCol('isreply');
		}
	
		$("#dataGrid").jqGrid('navGrid',"#dataGridPager",{search:false,edit:false,add:false,del:false});
		$("#dataGrid").jqGrid('hideCol','checkbox');	//10.05 일 김정국 수정.
		
		/* listResize */
		//gridResize("dataGrid");
		$(top.window).bind('resize', function() { setTimeout(function() {
			var line2 = $("#mainListButton").height() > 50;
			$("#dataGrid").setGridWidth(iflist_width(true)-0);
			$("#dataGrid").setGridHeight(iflist_height(true)-134-((line2)?20:0));
		}, 0);}).trigger('resize').trigger('resize');
		
		$("#cb_dataGrid").click( function() {
			var chk = document.getElementsByName("mailid");
			for( var i=0; i < chk.length; i++ ) {
    			chk[i].checked = $("#jqg_dataGrid_" + (i+1) ).attr('checked');
			}
		} );
		
		if ($("input[name=searchtext]").val() == "") $("#resetSearch").hide(); else $("#resetSearch").show();
		
		//$('select[name=searchtype] > option[value="<%=searchType %>"]').attr("selected","true");
		
		//상세검색 적용
		$('#btn_detail_search').qtip(
		{
			id: 'modal', // Since we're only creating one modal, give it an ID so we can style it
			content: {
				text: $('#detail_search'),
				title: {
					text: 'Mail Search',
					button: true
				}
			},
			position: {
				my: 'top right', // ...at the center of the viewport
				at: 'bottom right'
				//target: $(window)
				
			},
			show: {
				target: $('#btn_detail_search'),
				event: 'click', // Show it on click...
				solo: false // ...and hide all other tooltips...
				//modal: true // ...and make it modal
			},
			hide: true,
			style: 'qtip-light qtip-rounded',
			classes: 'ui-tooltip-bootstrap'
		});
		
		$("input[name='searchtext']").keydown(function(event) {
			if (event.which == 13) {
				event.preventDefault();
				gridReload();
			}
		});
	});
	
	function gridReload(){
		var searchtype = $("select[name=searchtype]").val();
		var searchtext = encodeURI($("input[name=searchtext]").val(), "UTF-8");
		if(searchtext == "" || searchtext == null){
			$("input[name=searchtext]").focus()
			return false;
		}
		var tag;	
			tag  = '<h3 style="position: initial; top: -2px; font-weights:normal;">';
			tag = '<div style="background-color:#fff; position:relative; dtop:-49px; margin:2px 3px; ';
			tag += 'height:21px; font-size:12px; padding:2px 0px 0px; z-index:1000;">';
			tag += '<div style="font-size:12px; background: #fff; spadding: 8px; left:116px;">';
			tag += '<img style="position: initial; top: 5px;" src="/common/jquery/css/validate/loading.gif" /><span style="position:relative; top:-5px;">검색중입니다.</span></div>';
			tag += '</div>';
			tag += '</h3>';
		$('#searchBlock').block({ 
				message: tag, 
				centerX: false,
				css: {
					fontFamily: 'calibri', fontSize: '7pt', fontStyle:'italic', height:'27px', width:'212px', left:'104px'
				}
		}); 
		var reqUrl = "./data/mail_list_json.jsp?box=" + mailboxID + "&unread=" + unread + "&codekey=" + codekey 
				   + "&searchtype=" + searchtype + "&searchtext=" + searchtext;
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
		if (searchtext != "") $("#resetSearch").show(); else $("#resetSearch").hide();
	}
	
	function gridReset(){
		$("input[name=searchtype]").val("all");
		$("input[name=searchtext]").val("");
		var searchtype = $("input[name=searchtype]").val();
		var searchtext = encodeURI($("input[name=searchtext]").val(), "UTF-8");
		var reqUrl = "./data/mail_list_json.jsp?box=" + mailboxID + "&unread=" + unread + "&codekey=" + codekey 
				   + "&searchtype=" + searchtype + "&searchtext=" + searchtext;
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
		if (searchtext != "") $("#resetSearch").show(); else $("#resetSearch").hide();
	}
	
	function goSearch(){
		
		if(!validCheck()) return;
		
		//수발신 검색
		var sel_receiver = $("select[name=sel_receiver]").val();
		var ipt_receiver = encodeURI($("input[name=ipt_receiver]").val(), "UTF-8");
		//본문검색
		var sel_content = $("select[name=sel_content]").val();
		var ipt_content = encodeURI($("input[name=ipt_content]").val(), "UTF-8");
		//메일함 검색
		var sel_mailbox = $("select[name=sel_mailbox]").val();
		var rdo_srch = $("input[@name=rdo_srch]:checked").val();
		if(sel_mailbox!=0) rdo_srch = "";
		//검색기간
		var sel_period = $("select[name=sel_period]").val();
		var startdate = $("input[name=startDate]").val();
		var enddate = $("input[name=endDate]").val();
		
		var reqUrl = "./data/mail_list_json.jsp?box=" + mailboxID + "&unread=" + unread + "&codekey=" + codekey 
				   + "&sel_receiver=" + sel_receiver + "&ipt_receiver=" + ipt_receiver
				   + "&sel_content=" + sel_content + "&ipt_content=" + ipt_content
				   + "&sel_mailbox=" + sel_mailbox + "&rdo_srch=" + rdo_srch
				   + "&sel_period=" + sel_period + "&startdate=" + startdate
				   + "&enddate=" + enddate;
		
		$("#dataGrid").jqGrid('setGridParam',{url:reqUrl,page:1}).trigger("reloadGrid");
// 		if (searchtext != "") $("#resetSearch").show(); else $("#resetSearch").hide();
	}
</script>
<!-- jqgrid 추가 -->

</head>
<body style="overflow:hidden; ">

<form name="fmMailList" method="POST" action="mail_list.jsp" onsubmit="return false;">
	<!-- hidden field -->
	<input type="hidden" name="box" value="<%=mailboxID%>">
	<input type="hidden" name="pg" value="<%=pageNo%>">
	<input type="hidden" name="message_name" value="">
	<input type="hidden" name="ctype" value="">
	<input type="hidden" name="nekmsgid" value="">
	<input type="hidden" name="codekey" value="<%=mainBoxID %>">
	<input type="hidden" name="unread" value="<%=unReadChk %>">
	<input type="hidden" name="topbox" value="<%=mainBoxID %>">
	<input type="hidden" name="fromname" value="">
	<input type="hidden" name="fromaddress" value="">
	<input type="hidden" name="boxname" value="<%=NavMailBoxName %>">
	<input type="hidden" name="isread" value="">

<!-- List Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="position:relative; lefts:-1px; height:37px; z-index:100;table-layout: fixed;">
<tr>
<td width="*" style="padding-left:5px; padding-top:5px;float:left; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
	<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-mail.png" />
	<%=NavMailBoxName%></span>&nbsp;-&nbsp;
</td>
<td width="*" style="padding-top:9px;float:left;">
	<span>
		<fmt:message key="mail.total"/>
		<!-- 전체 --><span id="totalCnt"></span>
		<%	if(!unReadChk.equals("1") && (mailboxID == 1 || "1".equals(mainBoxID))) { %>
		<fmt:message key="mail.unreaded"/>
		<!-- 개 중 안읽은메일 --><span id="unReadCnt"><%=iUnReadCnt %></span>
		<%	} %>
		<fmt:message key="mail.unread.have"/>&nbsp;<!-- 개가 있습니다 -->
	</span>
</td>
<td width="430" align="right" style="padding-right:5px;">
<!-- 	<input type="hidden" name="searchtype" value="all"> -->
	<div id="searchBlock">
		<select class="read" name="searchtype" align="absmiddle">
<%-- 			<option value='all_rec'><fmt:message key="mail.search.entire"/>전체검색</option> --%>
			<option value='subject'><fmt:message key="mail.subject" /><%-- 제목--%></option>
			<%if( mailboxID != 2){ //보낸편지함 %>
			<option value='from'><fmt:message key="mail.sender"/>&nbsp;<%-- 발신인 --%></option>
			<% } %>
			<option value='recieve'><fmt:message key="mail.recipient"/><%-- 수신인 --%></option>
			<option value='ref'><fmt:message key="mail.TO" /><%-- 수신 --%>+<fmt:message key="mail.CC" /><%-- 참조 --%></option>
			<option value='body'><fmt:message key="t.content" /><%--본문 --%></option>
		</select>
		<input name="searchtext" class="fld_other ui-corner-all" style="padding:4px; border:1px solid #aaa;" value="<%=searchText%>" />
		
		<a href="javascript:void(0)" class="btn btn-icon" onclick="gridReload();">
			<span><span class="icon-search"></span><fmt:message key='mail.seach'/>
		</span></a>&nbsp;
		<a href="javascript:void(0)" id="resetSearch" onclick="gridReset();" class="btn-red btn-icon" style="display:none;">
			<span><span class="icon-search"></span><fmt:message key="t.search.del"/><!-- 검색제거 -->&nbsp;
		</span></a>
	<!-- 	<a id="btn_detail_search" href="#" onclicks="showDetailSearch();" class="btn btn-icon"> -->
	<!-- 		<span><span class="icon-search"></span>상세검색&nbsp;검색제거 -->
	<!-- 	</span></a> --> 
		<a id="btn_detail_search" href="javascript:void(0)" onclicks="showDetailSearch();" class="btn-blue btn-icon">
			<span><span class="icon-search"></span><fmt:message key="mail.powersearch"/><!-- 상세검색-->&nbsp;<!-- 검색제거 -->
		</span></a>
	</div>
</td>
</tr>
</table>

<div id="detail_search" style="display:none;"> <%-- border-bottom:1px solid #00FFFF; --%>
	<table>
		<colgroup>
			<col width="*">
			<col width="*">
			<col width="*">
		</colgroup>
		<tr height="32">
			<td align="right"><label for="ipt_query"><fmt:message key="t.search.people" /><%-- 사람검색 --%> : </label></td>
			<td>
				<select class="read" name="sel_receiver" align="absmiddle">
					<%if( mailboxID != 2){ //보낸편지함 %>
					<option value='from'><fmt:message key="mail.sender"/>&nbsp;<!-- 발신인 --></option>
					<% } %>
					<option value='recieve'><fmt:message key="mail.recipient"/><!-- 수신인 --></option>
				</select>
				<input type="text" name="ipt_receiver" maxlength="100" style="ime-mode:active;heightd:15px;padding:4px;border:1px solid #abadb3;line-height:15px">
			</td>
			<td rowspan="5" valign="top">
				<a href="javascript:void(0)" class="btn btn-icon" onclick="goSearch();">
					<span>
						<span class="icon-search"></span>
						<span><fmt:message key='mail.seach'/></span>
					</span>
				</a>
			</td>
		</tr>
		<tr height="32">
			<td align="right"><label for="ipt_query"><fmt:message key="t.search.contents" /><%-- 내용검색 --%> : </label></td>
			<td> 
				<select name="sel_content" align="absmiddle">
					<option value="all_body" selected="selected"><fmt:message key="t.subject" />+<fmt:message key="t.content" /></option>
					<option value="subject"><fmt:message key="t.subject" /><%-- 제목 --%></option>
					<option value="body"><fmt:message key="t.content" /></option><%--본문 --%>
					<!-- <option value="4">첨부파일</option> -->
					<!-- <option value="5">전체</option> -->
				</select>
				<input type="text" name="ipt_content" maxlength="100" style="ime-mode:active;heightd:15px;padding:4px;border:1px solid #abadb3;line-height:15px">
				<!-- <span class="ment">(첨부파일/첨부본문 포함)</span> -->
			</td>
		</tr>
		<tr height="32">
			<td align="right"><label for="ipt_query"><fmt:message key="t.select.folder" /><%-- 폴더선택 --%> : </label></td>
			<td>
				<select name="sel_mailbox" onchange="setChangeMailbox()" align="absmiddle">
					<option value="0"><fmt:message key="mail.mailbox.all" /><%-- 전체편지함 --%></option>
					<option value="1" <%=(mailboxID==1 ? "selected" : "") %>><fmt:message key="mail.InBox" /><%-- 받은편지함 --%></option>
					<%
					Iterator recMailboxs = mailboxes_rec.iterator();
					//Iterator mailbox_iter2 = mailboxes_send.iterator();
					while (recMailboxs.hasNext()) {
						Mailbox mailbox = (Mailbox)recMailboxs.next();
						boolean isSelected = false;
						if(mailbox.getID()==mailboxID){
							isSelected = true;
						}
						out.println("<option value='" + mailbox.getID() + "' " + (isSelected ? "selected" : "") +">" 
								+ mailbox.getName()+ "</option>");
					}
					%>
					<option value="2" <%=(mailboxID==2 ? "selected" : "") %>><fmt:message key="mail.OutBox" /><%-- 보낸편지함 --%></option>
					<option value="7" <%=(mailboxID==7 ? "selected" : "") %>><fmt:message key="mail.spamBox" /><%-- 스팸편지함 --%></option>
					<option value="3" <%=(mailboxID==3 ? "selected" : "") %>><fmt:message key="mail.TempBox" /><%-- 임시보관함 --%></option>
					<option value="6" <%=(mailboxID==6 ? "selected" : "") %>><fmt:message key="mail.ReservationBox" /><%-- 예약편지함 --%></option>
					<option value="4" <%=(mailboxID==4 ? "selected" : "") %>><fmt:message key="mail.DeletedBox" /><%-- 지운편지함 --%></option>
				</select>
			</td>
		</tr>
		<tr height="32">
			<td></td>
			<td style="position: relative; top: -3px;">
				<label><fmt:message key="mail.DeletedBox" /><%-- 지운편지함 --%>/<fmt:message key="mail.spamBox" /><%-- 스팸편지함 --%> : </label>
				<input type="radio" name="rdo_srch" value="exceptTrash" disabled="true" checked><label><fmt:message key="t.exclusion" /><%-- 제외 --%></label>
				<input type="radio" name="rdo_srch" value="includeTrash" disabled="true"><label ><fmt:message key="t.inclusion" /><%-- 포함 --%></label>
			</td>
		</tr>
		<tr height="32">
			<td align="right"><label><fmt:message key="t.search.period" /><%-- 기간검색 --%> : </label></td>
			<td>
				<select name="sel_period" onchange="setDatePeriod()">
				<option value="0" selected><fmt:message key="t.all" /><%-- 전체 --%></option>
				<option value="1">1 <fmt:message key="t.week" /><%-- 주 --%></option>
				<option value="2">1 <fmt:message key="t.month" /><%-- 월 --%></option>
				<option value="3">3 <fmt:message key="t.month" /><%-- 월 --%></option>
				<option value="4">6 <fmt:message key="t.month" /><%-- 월 --%></option>
				<option value="5">1 <fmt:message key="t.year" /><%-- 년 --%></option>
				<option value="99"><fmt:message key="t.input.direct" /><%-- 직접입력 --%></option>
				</select>
				<input id="startDate" name="startDate" type="text" title="<fmt:message key="sch.Strat.Date" /><%-- 시작일 --%>" Style="width:75px;border:1px solid #abadb3;" maxlength="30" onclick="onClickcr();" readonly>
				 - 
				<input id="endDate" name="endDate" type="text" title="<fmt:message key="sch.End.Date" /><%-- 종료일 --%>" Style="width:75px;border:1px solid #abadb3;" maxlength="30" onclick="onClickcr();" readonly>
			</td>
		</tr>
	</table>
</div>
<!-- </div> -->

	<!-- List Button -->
	<table id="mainListButton" width=100% border="0" cellspacing=0 cellpadding=0 class=mail_list_t style="height:35px;">
		<tr>
			<td width="*" style="padding:3px;">
				<a href="javascript:void(0)" class="btn btn-icon" onclick="goSubmit('NEW');">
					<span><span class="icon-mail-pencil"></span><fmt:message key="mail.new"/>&nbsp;<!-- 새메일 -->
				</span></a>
				
				<a href="javascript:void(0)" class="btn btn-icon" onclick="OnClickDelete();">
					<span><span class="icon-delete"></span><fmt:message key="mail.delete"/>&nbsp;<!-- 삭제 -->
				</span></a>
				
				<%	if (mainBoxID.equals("1")) { %>
				<a href="javascript:void(0)" class="btn btn-icon" onclick="OnClickMarker(1);">
					<span><span class="icon"></span><fmt:message key="mail.list.read"/><!-- 읽음표시-->&nbsp;
				</span></a>&nbsp;
				<a href="javascript:void(0)" class="btn btn-icon" onclick="OnClickMarker(2);">
					<span><span class="icon"></span><fmt:message key="mail.list.unread"/><!-- 안읽음표시-->&nbsp;
				</span></a>
				<% } %>

				<%	if (mailboxID == Mailbox.SPAM) { %>
				<a href="javascript:void(0)" class="btn btn-icon" onclick="OnSpamDelete();">
					<span><span class="icon"></span><fmt:message key="mail.unblock"/>&nbsp;<!-- 차단해제 -->
				</span></a>
				<% } %>
				
				
				<%	if (mailboxID == Mailbox.TRASH) { %>
				<a href="javascript:void(0)" class="btn btn-icon" onclick="OnClickClearTrash();">
					<span><span class="icon"></span><fmt:message key="mail.empty.trash"/>&nbsp;<!-- 휴지통비우기 -->
				</span></a>
				<% } %>
				
				<%	if (!(mailboxID==Mailbox.SPAM||mailboxID == Mailbox.DRAFT||mailboxID == Mailbox.RESERVED)) { %>
				<select name="targetFolder" style="max-width:180px;"><option value="title">-----<fmt:message key="mail.select.mailbox"/>&nbsp;<!-- 편지함 선택 -->-----</option>
					<%=selBoxes %>
				</select>
				<a href="javascript:void(0)" class="btn btn-icon" onclick="OnClickMove();">
					<span><span class="icon-mail-move"></span><fmt:message key="mail.move.folder"/>&nbsp;<!-- 폴더 이동 -->
				</span></a>
				<% } %>
				<%-- 
				<a href="#" class="btn btn-icon" onclick="OnClickPop3();">
					<span><span class="icon-mail-receive"></span><fmt:message key="mail.import.pop3"/>&nbsp;<!-- 외부메일(POP3)가져오기 -->
				</span></a>
				 --%>
				<a href="javascript:void(0)" class="btn btn-icon" onclick="OnClickSave();">
					<span><span class="icon-mail-download"></span><fmt:message key="mail.storage.pc"/>&nbsp;<!-- PC 보관 -->
				</span></a>
				
				<%	if (mailboxID == Mailbox.OUTBOX) { %>
				<a href="javascript:void(0)" class="btn btn-icon" onclick="reMailSend();">
					<span><span class="icon-mail-send"></span><fmt:message key="mail.redials"/>&nbsp;<!-- 재발신 -->
				</span></a>
				<% } %>
				
				<%	if (mailboxID == Mailbox.SPAM) { %>
				<a href="javascript:void(0)" class="btn btn-icon" onclick="goSpam();">
					<span><span class="icon-config"></span><fmt:message key="mail.spamSetting"/>&nbsp;<!-- 스팸설정 -->
				</span></a>
				<% } %>
			</td>
			<td width="*">&nbsp;</td>
		</tr>
	</table>
	<!-- List Button -->

	<!-- List -->
	<table id="dataGrid"></table>
	<div id="dataGridPager"></div>
	<span id="errorDisplayer" style="color:red"></span>
	<!-- List -->
	
	<%
		String toolsHt ="";
		if (mainBoxID.equals("1")) {
			toolsHt ="190px";
		}else if (mainBoxID.equals("2")) {
			toolsHt ="80px";
		}else{
			toolsHt ="190px";
		}
	%>
	<div id=val style="display:none;">
		<div id=test style="width:100%; height:<%=toolsHt %>; borders:2px solid #A1B5FE; overflow:auto;">
			<table width=100% height=100% cellspacing=0 cellpadding=0 border=0 style="border-collapse:collapse; borders:1px solid white;table-layout:fixed;" oncontextmenu="return false" ondragstart="return false"  >
				<tr height=20>
					<td width=* style="font-size:9pt; color:black; padding-left:3px; padding-top:3px; text-overflow:ellipsis; overflow:hidden; white-space:nowrap; cursor:hand; " onmouseovers="this.style.backgroundColor='#A1B5FE';" onmouseouts="this.style.backgroundColor='white';">
						<img src='/common/images/icons/configuration_icon_10.jpg' align=absmiddle>
						<a href="javascript:OnClickAction('read');" style="color:black; text-decoration:none; "><fmt:message key="mail.read"/>&nbsp;<!-- 메일읽기 --></a>
					</td>
				</tr>
				<tr height=20>
					<td width=* style="font-size:9pt; color:black; padding-left:3px; padding-top:3px; text-overflow:ellipsis; overflow:hidden; white-space:nowrap; cursor:hand; " onmouseovesr="this.style.backgroundColor='#A1B5FE';" onmouseouts="this.style.backgroundColor='white';">
						<img src='/common/images/icons/configuration_icon_10.jpg' align=absmiddle>
						<a href="javascript:OnClickAction('reply');" style="color:black; text-decoration:none; "><fmt:message key="mail.reply.sender"/>&nbsp;<!-- 발신인에게 회신 --></a>
					</td>
				</tr>
				<tr height=20>
					<td width=* style="font-size:9pt; color:black; padding-left:3px; padding-top:3px; text-overflow:ellipsis; overflow:hidden; white-space:nowrap; cursor:hand; " onmouseovers="this.style.backgroundColor='#A1B5FE';" onmouseouts="this.style.backgroundColor='white';">
						<img src='/common/images/icons/configuration_icon_10.jpg' align=absmiddle>
						<a href="javascript:OnClickAction('forward');" style="color:black; text-decoration:none; "><fmt:message key="mail.forwarding"/>&nbsp;<!-- 메일전달 --></a>
					</td>
				</tr>
				<%	if (mainBoxID.equals("1")) { %>
				<tr height=20>
					<td width=* style="font-size:9pt; color:black; padding-left:3px; padding-top:3px; text-overflow:ellipsis; overflow:hidden; white-space:nowrap; cursor:hand; " onmouseovers="this.style.backgroundColor='#A1B5FE';" onmouseouts="this.style.backgroundColor='white';">
						<img src='/common/images/icons/configuration_icon_10.jpg' align=absmiddle>
						<a href="javascript:OnClickAction('markread');" style="color:black; text-decoration:none; "><fmt:message key="mail.list.read"/><!-- 읽음표시-->&nbsp;</a>
					</td>
				</tr>
				<tr height=20>
					<td width=* style="font-size:9pt; color:black; padding-left:3px; padding-top:3px; text-overflow:ellipsis; overflow:hidden; white-space:nowrap; cursor:hand; " onmouseovers="this.style.backgroundColor='#A1B5FE';" onmouseouts="this.style.backgroundColor='white';">
						<img src='/common/images/icons/configuration_icon_10.jpg' align=absmiddle>
						<a href="javascript:OnClickAction('markunread');" style="color:black; text-decoration:none; "><fmt:message key="mail.list.unread"/><!-- 안읽음표시-->&nbsp;</a>
					</td>
				</tr>
				<% } %>
				<%	if (mainBoxID.equals("2")) { %><!-- 보낸편지함 -->
				<tr height=20>
					<td width=* style="font-size:9pt; color:black; padding-left:3px; padding-top:5px; text-overflow:ellipsis; overflow:hidden; white-space:nowrap; cursor:hand; " onmouseovers="this.style.backgroundColor='#A1B5FE';" onmouseouts="this.style.backgroundColor='white';">
						<img src='/common/images/vwicn008.gif' align=absmiddle>
						<a href="javascript:OnClickAction('search2');" style="color:black; text-decoration:none; padding-left:2px;"><fmt:message key="mail.recipient.search"/><!-- 수신인의 메일검색 --></a>
					</td>
				</tr>
				<%} %>
				<%	if (!mainBoxID.equals("2")) { %><!-- 받은편지함 -->
				<tr height=20>
					<td width=* style="font-size:9pt; color:black; padding-left:3px; padding-top:5px; text-overflow:ellipsis; overflow:hidden; white-space:nowrap; cursor:hand; " onmouseovers="this.style.backgroundColor='#A1B5FE';" onmouseouts="this.style.backgroundColor='white';">
						<img src='/common/images/vwicn008.gif' align=absmiddle>
						<a href="javascript:OnClickAction('search1');" style="color:black; text-decoration:none; padding-left:2px;"><fmt:message key="mail.search.sender"/>&nbsp;<!-- 발신인의 메일 검색 --></a>
					</td>
				</tr>
				<tr height=20>
					<td width=* style="font-size:9pt; color:black; padding-left:3px; padding-top:5px; text-overflow:ellipsis; overflow:hidden; white-space:nowrap; cursor:hand; " onmouseovers="this.style.backgroundColor='#A1B5FE';" onmouseouts="this.style.backgroundColor='white';">
						<img src='/common/images/icons/admin_icon_7.jpg' align=absmiddle>
						<a href="javascript:OnClickAction('addressbook_s');" style="color:black; text-decoration:none; "><fmt:message key="mail.add.sender"/>&nbsp;<!-- 발신인을 주소록에 추가 --></a>
					</td>
				</tr>
				<%if(mailboxID!=Mailbox.SPAM){ %>
				<tr height=20>
					<td width=* style="font-size:9pt; color:black; padding-left:3px; padding-top:5px; text-overflow:ellipsis; overflow:hidden; white-space:nowrap; cursor:hand; " onmouseovers="this.style.backgroundColor='#A1B5FE';" onmouseouts="this.style.backgroundColor='white';">
						<img src='/common/images/icons/email_icon_1.jpg' align=absmiddle>
						<a href="javascript:OnClickAction('spam');" style="color:black; text-decoration:none; "><fmt:message key="mail.spam.sender"/>&nbsp;<!-- 발신인을 스팸으로 등록 --></a>
					</td>
				</tr>
				<%} %>
				<tr height=20>
					<td width=* style="font-size:9pt; color:black; padding:3px; padding-top:6px; padding-right:5px; vertical-align:top; text-overflow:ellipsis; overflow:hidden; white-space:nowrap; cursor:hand; " onmouseovers="this.style.backgroundColor='#A1B5FE';" onmouseouts="this.style.backgroundColor='white';">
						<img src='/common/images/icons/configuration_icon_4.jpg' align=absmiddle>
						<a href="javascript:OnClickAction('rule');" style="color:black; text-decoration:none;"><fmt:message key="mail.auto.classification"/>&nbsp;<!-- 자동분류 설정 --></a>
					</td>
				</tr>
				<%} %>
			</table>
		</div>
	</div>
</form>
</fmt:bundle>
</body>
</html>	