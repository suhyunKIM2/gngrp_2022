<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="nek.mail.*" %>
<%@ page import="nek.notification.*" %>
<%@ page import="nek.common.util.*" %>
<%@ page import="nek.common.dbpool.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%!
	private MailRepository repository = MailRepository.getInstance();
 	private String imgPath = "../common/images/icons/";
	private String imgPath1 = "../common/images/";
%>
<%@ include file="../common/usersession.jsp"%>
<%
	boolean isPartner = loginuser.securityId == 0;
	boolean isPartnerTemp = loginuser.securityId == 8;
	long mailQuota = uservariable.mailBoxSize/(1024*1024);
	DBHandler db =  null;
	Connection pconn = null;
	Mailboxes mailboxes = null;
	MailboxSummaries summaries = null;
	NotificationSummaries noteSsummaries = null;
	ArrayList data = null;
	int mailUnRead = 0;
	try{
		String domainName = application.getInitParameter("nek.mail.domain");
		if(!uservariable.userDomain.equals("")) domainName = uservariable.userDomain;
		
		db = new DBHandler();
		pconn = db.getDbConnection();
		
		//받은편지함 읽지 않은 갯수
		MailRepositorySummary mailboxSummary  =  MailRepository.getInstance().getRepositorySize(pconn, loginuser.emailId, domainName);
		MailRepositorySummary mailboxUnreadSummary  =  MailRepository.getInstance().getUnreadRepositoryCount(pconn, loginuser.emailId, domainName);
		mailUnRead= MailRepository.getInstance().getMailUnReadCount(pconn, loginuser.emailId, domainName);
		
		double mailUsage = (double)mailboxSummary.getTotalSize();
		mailUsage = mailUsage/(1024.0*1024.0);
		int mailPercent = (int)(mailQuota == 0 ? 0 : (100* mailUsage)/mailQuota);
		if (mailPercent > 100) {
			mailPercent = 100;
		}
		//전자메일 - 서브폴더
// 		mailboxes = repository.getCustomMailboxes(pconn, loginuser.emailId, domainName);
// 		summaries = repository.getMailboxSummaries(pconn, loginuser.emailId, domainName);
		
		//사내통신 - 서브폴더
		Noteboxes notebox = new Noteboxes();
		data = notebox.noteBoxlist(pconn, loginuser.uid);
		noteSsummaries = notebox.getNoteboxSummaries(pconn, loginuser.uid);
		
		//임시저장함 갯수
		int iDraftMailCnt =  repository.getTotalMailCnt(pconn, loginuser.emailId, domainName, Mailbox.DRAFT);
		//예약함 갯수
		int iReservedMailCnt =  repository.getTotalMailCnt(pconn, loginuser.emailId, domainName, Mailbox.RESERVED);
		//스팸편지함 갯수
		int iSpamMailCnt =  repository.getTotalMailCnt(pconn, loginuser.emailId, domainName, Mailbox.SPAM);
		//휴지통 갯수
		int iTrashMailCnt = repository.getTrashMailCnt(pconn, loginuser.emailId, domainName);

// 		MailboxSummary summary = summaries.get(Mailbox.INBOX);	
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<fmt:setLocale value="<%=loginuser.locale %>"/>
<fmt:bundle basename="messages">
<body>
<style>
div#mail_left_layer a:link { color:black; text-decoration:none; }
div#mail_left_layer a:hover { color:black; text-decoration:none; }
div#mail_left_layer a:visited { color:black; text-decoration:none; font-weight:bold;}

div#mail_left_layer .num {padding-left:5px; font-size:9pt; font-family:tahoma; color:#205FCF;font-weight:bold;}
div#mail_left_layer .sub {padding-left:22px;}
div#mail_left_layer .tr_sub {height:23px; paddding-left:22px;}

div#mail_left_layer table {border-collapse:collapse;}
div#mail_left_layer tr { height:25px; }
/* div#mail_left_layer td {font-size:10pt;  white-space:nowrap; font-weights:bold; font-family:dotum, tahoma; sborder:1px solid #d8dee9;} */
/* div#mail_left_layer td {height:25px;} */
div#mail_left_layer td:hover {border:0px solid #A6C0E5; background:#B6D2F5; border-right:0px; border-left:0px; }
div#mail_left_layer td:visited {font-weight:bold; background:#ddd; border-right:0px; border-left:0px; }
div#mail_left_layer td:active {font-sweight:bold; background:#ddd; border-right:0px; border-left:0px; }
</style>

<form name="fmMailLeft" method="POST" action="mail_left.jsp" onsubmit="return false;">
	<input type="hidden" name="cmd" value="">
	<input type="hidden" name="url" value="">

			<table width=95% cellspacing=0 cellpadding=0 style="margin:0px 5px; float:center; border:0px solid #A1B5EF;">
				<tr>
					<td align=center style="height:15px; padding:0px; padding-top:4px; font-size:8pt; line-height:7px; ">
						<B><span style="color:#de0b0b; "><%=(mailUsage < 1) ? ""+(int)(mailUsage * 1024) + " KB": "" + (int)mailUsage +" MB"%></span></B> <fmt:message key="book.use"/><!-- 사용중 --> / <B><%=mailQuota%></B> MB&nbsp;<!-- (<%=mailPercent%>%) -->
					</td>
				</tr>
				<tr style="height:8px;">
					<td style="padding:0px; padding-right:1px; height:8px; line-height:8px; " valign=top>
						<table width=100% cellspacing=0 cellpadding=0 border=1 style="height:5px; ">
							<tr style="height:1px;">
								<td width="<%=(mailPercent==0) ? "1px" : mailPercent+"%" %>" align=center style="height:18px; padding:0px; padding-top:3px; background-color:#266fb5; line-height:18px;">
									<span style="font-size:8pt; font-weight:normal; color:red; line-height:5px;"><B></B> </span><span style="color:black;"></span>
								</td>
								<td width=* style="height:18px; line-height:18px; margin:0px; border:1px; " bgcolor=#ffffff>&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr style="height:8px; ">
					<td style="height:3px; padding:0px; padding-left:0px; padding-bottom:2px; ">
						<table width=100% cellspacing=0 cellpadding=0 border=0>
							<tr style="height:8px; ">
								<td width=33% align=left style="padding-left:0px; padding-top:0px; "><img src="<%=imgPath %>mail/0_per.gif"></td>
								<td width=34% align=center style="padding-left:0px; padding-top:0px; "><img src="<%=imgPath %>mail/50_per.gif"></td>
								<td width=* align=right style="padding-left:0px; padding-top:0px; "><img src="<%=imgPath %>mail/100_per.gif"></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
</div>

<div id="mail_left_layer" style="sborder:1px solid #A1B5FE;border-top:0px;position:relative; overflow:auto; padding-lefts:10px; left:0px;  width:100%; height:350px; background-color:#E6E8ED;">
<table class="mail_left_table" width=100%  cellspacing=0 cellpadding=0 border=0 id=m1 style="background:#fff; sborder-bottom:1px solid #ddd;">
	<tr>
		<td style="height:27px; padding-left:7px;"><img src="<%=imgPath1 %>icon-mail-pencil.png" align=absmiddle style="position:relative; top:-3px;">&nbsp;<a href="javascript:newDoc();" onclicks="m_click('write');"><b><fmt:message key="main.E-mail.Write"/><!-- 편지쓰기 --></b></a></td>
	</tr>
</table>

<table class="mail_left_table" width=100%  cellspacing=0 cellpadding=0 border=0 id=m2 style="background:#e6e8ed; border-top:1px solid #c4c4c4; border-bottom:1px solid #ddd;">
	<tr>
		<td style="padding-left:5px;"><img src="<%=imgPath1 %>icon-mail-receive.png" align=absmiddle style="position:relative; top:-1px;">&nbsp;<a href="/mail/mail_list.jsp?box=1&topbox=1" target="if_list" onclick="m_click('inbox');"><b><fmt:message key="mail.InBox"/><!-- 받은편지함  --></b></a>&nbsp;<span class="num" id="lCount1"><%=(mailUnRead == 0 ) ? "" : mailUnRead%></span></td>
	</tr>
	<tr class="tr_sub">
		<td class="sub"><img src="<%=imgPath %>email_icon_1.jpg" align=absmiddle>&nbsp;<a href="/mail/mail_list.jsp?unread=1&topbox=1" target="if_list" onclick="m_click('inbox');"><fmt:message key="mail.unread"/><!-- 읽지않은 메일 --></a>&nbsp;<span class="num" id="lCount0"><%=(mailboxUnreadSummary.getUnreadCount() == 0 ) ? "" : mailboxUnreadSummary.getUnreadCount()%></span></td>
	</tr>
	<tr class="tr_sub" style="display:none;">
		<td class="sub"><img src="<%=imgPath %>admin_icon_10.png" align=absmiddle>&nbsp;<a href="/mail/mail_pop3support.jsp" target="if_list" onclick="m_click('inbox');"><fmt:message key="mail.inquiry.mail"/><!-- 외부메일 조회 --></a>&nbsp;<span class="num"></span>	</td>
	</tr>
	<%--
	<%
		if (mailboxes.size() > 0) {
		    Iterator iter = mailboxes.iterator();
		    while (iter.hasNext()) {
			    Mailbox mailbox = (Mailbox)iter.next();
			    if(mailbox.getMainBoxId() !=1) continue;
			    summary = summaries.get(mailbox.getID());
				int iTotCnt = (summary == null) ? 0 : summary.getTotalCount();
				int iUnReadCnt = (summary == null) ? 0 : summary.getUnreadCount();
	%>			
		<tr class="mailboxpath tr_sub" style="sheight:20px; display: <% if (mailbox.getDepth() != 1) { out.print("nones"); } %>;" id="P<%=mailbox.getPath() %>">
			<td style="height:20px; padding-left: <%=( mailbox.getDepth()-1 == 0) ? "8" :(15 * (mailbox.getDepth() )) %>px;">
				<%	if (mailbox.isChildHas()) { 
						out.print("<img src=\"" + imgPath + "minus1.gif\" align=\"absmiddle\" style=\"margin-left: 3px;cursor: pointer;\" onclick=\"changeDisplay(this)\" class=\"plus_minus\" />");
					} else {
						if (mailbox.getDepth()-1 == 0) {
							out.print("<span style=\"margin-left:12px;\">&nbsp;</span>");
						} else {
							out.print("<span style=\"margin-left:17px;\"></span>");
						}
					}
				%>
				<img src="<%=imgPath %>folder.png" align="absmiddle" />
				<a href="/mail/mail_list.jsp?box=<%=mailbox.getID()%>&topbox=1" target="if_list" onclick="m_click('inbox');">
					<%=HtmlEncoder.encode(mailbox.getName())%>
				</a>
				<span class="num"  id="lCount<%=mailbox.getID()%>"><%=(iUnReadCnt == 0 ) ? "" : iUnReadCnt %></span>
			</td>
		</tr>
	<%
			}
		}
	%>
	--%>
</table>

<div id="inbox_tree_tr" style="overflow-y: hidden;overflow-x: auto;">
	<table width="100%" cellspacing="0" cellpadding="0" border="0" style="table-layout: fixed;">
		<tr>
			<td>
				<div id="inbox_tree_area" class="tree_area"></div>
			</td>
		</tr>
	</table>
</div>

<table class="mail_left_table" width=100%  cellspacing=0 cellpadding=0 border=0 id=m3 style="background:#e6e8ed; border-top:1px solid #efefef; border-bottom:1px solid #ddd;">
	<tr>
		<td style="padding-left:5px;"><img src="<%=imgPath1 %>icon-mail-send.png" align=absmiddle style="position:relative; top:-1px;">&nbsp;<a href="/mail/mail_list.jsp?box=2&topbox=2" target="if_list" onclick="m_click('inbox');"><b><fmt:message key="mail.OutBox"/><!-- 보낸편지함 --></b></a>&nbsp;
	</tr>
	<tr class="tr_sub">
		<td class="sub"><img src="<%=imgPath1 %>icon-mail-open.png" align=absmiddle style="position:relative; top:-2px;">&nbsp;<a href="/mail/mail_receiptlist.jsp?box=2&topbox=2" target="if_list" onclick="m_click('inbox');"><fmt:message key="mail.received.check"/><!-- 수신확인  --></a>&nbsp;</td>
	</tr>
	<%--
	<%
		if (mailboxes.size() > 0) {
		    Iterator iter = mailboxes.iterator();
		    while (iter.hasNext()) {
			    Mailbox mailbox = (Mailbox)iter.next();
			    if(mailbox.getMainBoxId() !=2) continue;
			    summary = summaries.get(mailbox.getID());
				int iTotCnt = (summary == null) ? 0 : summary.getTotalCount();
				int iUnReadCnt = (summary == null) ? 0 : summary.getUnreadCount();
	%>
		<tr style="display: <% if (mailbox.getDepth() != 1) { out.print("none"); } %>;" class="mailboxpath" id="P<%=mailbox.getPath() %>">
			<td style="height:20px; padding-left: <%=( mailbox.getDepth()-1 == 0) ? "8" :(15 * (mailbox.getDepth() )) %>px;">
				<%	if (mailbox.isChildHas()) { 
						out.print("<img src=\"" + imgPath + "plus1.gif\" align=\"absmiddle\" style=\"margin-left: 3px;cursor: pointer;\" onclick=\"changeDisplay(this)\" class=\"plus_minus\" />");
					} else {
						if (mailbox.getDepth()-1 == 0) {
							out.print("<span style=\"margin-left:12px;\">&nbsp;</span>");
						} else {
							out.print("<span style=\"margin-left:17px;\"></span>");
						}
						//out.print("<span style=\"width:20px;\"></span>");
					}
				%>
				<img src="<%=imgPath %>folderb.png" align="absmiddle" />
				<a href="/mail/mail_list.jsp?box=<%=mailbox.getID()%>&topbox=2" target="if_list" onclick="m_click('inbox');">
					<%=HtmlEncoder.encode(mailbox.getName())%>
				</a>
				<span class="num"><%=(iUnReadCnt == 0 ) ? "" : iUnReadCnt %></span>
			</td>
		</tr>
	<%
			}
		}
	%>
	--%>
</table>

<div id="outbox_tree_tr" style="overflow-y: hidden;overflow-x: auto;">
	<table width="100%" cellspacing="0" cellpadding="0" border="0" style="table-layout: fixed;">
		<tr>
			<td>
				<div id="outbox_tree_area" class="tree_area"></div>
			</td>
		</tr>
	</table>
</div>


<table class="mail_left_table" width=100%  cellspacing=0 cellpadding=0 border=0 id=m4 style="border-top:1px solid #efefef; border-bottom:1px solid #ddd; background:#D8DEE9;">
	<tr>
		<td style="padding-left:5px;"><img src="<%=imgPath1 %>icon-mail-sign.png" align=absmiddle style="position:relative; top:-2px;">&nbsp;<a href="/mail/mail_list.jsp?box=7" target="if_list" onclick="m_click('inbox');"><fmt:message key="mail.spamBox"/><!-- 스팸편지함  --></a>&nbsp;<span class="num" id="lCount7"><%=(iSpamMailCnt == 0 ) ? "" : iSpamMailCnt %></span></td>
	</tr>
	<tr>
		<td style="padding-left:5px;"><img src="<%=imgPath1 %>icon-mail-temp.png" align=absmiddle style="position:relative; top:-2px;">&nbsp;<a href="/mail/mail_list.jsp?box=3" target="if_list" onclick="m_click('inbox');"><fmt:message key="mail.TempBox"/><!-- 임시보관함  --></a>&nbsp;<span class="num"  id="lCount3"><%=(iDraftMailCnt == 0 ) ? "" : iDraftMailCnt %></span></td>
	</tr>
	<tr>
		<td style="padding-left:5px;"><img src="<%=imgPath1 %>icon-clock-arrow.png" align=absmiddle style="position:relative; top:-2px;">&nbsp;<a href="/mail/mail_list.jsp?box=6" target="if_list" onclick="m_click('inbox');"><fmt:message key="mail.ReservationBox"/><!-- 예약편지함  --></a>&nbsp;<span class="num" id="lCount6"><%=(iReservedMailCnt == 0 ) ? "" : iReservedMailCnt %></span></td>
	</tr>
	<tr>
		<td style="padding-left:5px;"><img src="<%=imgPath1 %>icon-mail-minus.png" align=absmiddle style="position:relative; top:-2px;">&nbsp;<a href="/mail/mail_list.jsp?box=4" target="if_list" onclick="m_click('inbox');"><fmt:message key="mail.DeletedBox"/><!-- 지운편지함  --></a>&nbsp;<span class="num" id="lCount4"><%=(iTrashMailCnt==0) ? "":iTrashMailCnt %></span>&nbsp<a style="float:right;" href="javascript:OnClickClearTrash();"><span style="font-size:8pt; font-weight:normal; color:red; margin-right:2px; ">[<fmt:message key="mail.empty"/><!-- 비우기 -->]</span></a></td>
	</tr>
	<tr>
		<td style="padding-left:5px;"><img src="<%=imgPath1 %>icon-chart.png" align=absmiddle style="position:relative; top:-2px;">&nbsp;<a href="/mail/mail_mailboxes.jsp?leftBlock=off" target="if_list" onclick="m_click('inbox');"><fmt:message key="mail.BoxManage"/><!-- 메일함관리  --></a></td>
	</tr>
	<tr>
		<td style="padding-left:5px;"><img src="<%=imgPath1 %>icon-config.png" align=absmiddle style="position:relative; top:-2px;">&nbsp;<a href="/mail/mail_portal.jsp" target="if_list" onclick="m_click('inbox');"><fmt:message key="main.option"/><!-- 환경설정  --></a><!-- &nbsp;&nbsp;&nbsp;&nbsp;<span style="font-size:8pt; font-weight:normal; color:#999999;">서명, 그룹메일 외</span> --></td>
	</tr>
	<%if(loginuser.securityId >= 9 && loginuser.uid.equals("00000000000000")){ %>
	<%-- 
	<tr>
		<td style="padding-left:5px;"><img src="<%=imgPath1 %>icon-config.png" align=absmiddle style="position:relative; top:-2px;">&nbsp;<a href="/mail/mail_archive_list.jsp" target="if_list" onclick="m_click('inbox');"><fmt:message key="mail.ArchiveBox"/><!-- 전체메일함:Archive  --></a></td>
	</tr>
	 --%>
	<%} %>
</table>

<%	if (!isPartner) if (!isPartnerTemp) { %>

<!--  쪽지 함 -->
<div style="width:100%; height:31px; sborder:1px solid #A1B5FE;sborder-bottom:0px;">

<table class="mail_left_table" width=100% cellspacing=0 cellpadding=0 style="">
	<tr style="height:31px;">
		<td align=center style="padding-left:0px; background-image:url('<%=imgPath %>mail/tbl_bg.jpg');"><B><fmt:message key="main.Message"/><!-- 쪽 지 함--></B></td>
	</tr>
</table>
</div>

<div style="borders:1px solid #A1B5FE; background-color:#D8DEE9; spadding-left:8px; border-top:0px;position:relative; left:0px; overflow:auto; overflow-y:auto;overflow-x:hidden;">
<table class="mail_left_table" width=100%  cellspacing=0 cellpadding=0 border=0>
	<tr>
		<td style="padding-left:5px;borders:1px solid white;">
			<img src="<%=imgPath %>approual_icon_4.jpg" align=absmiddle>
			<a href="/notification/list.htm?boxId=1" target="if_list" onclick="m_click('inbox');">
				<fmt:message key="mail.noti.received" /><!-- 받은쪽지함-->
			</a>
			<span class="num">(<%=nek.notification.Notifier.getInstance().getUnreadCount(pconn, loginuser.uid) %>)</span>
		</td>
	</tr>
	<tr class="tr_sub">
		<td style="padding-left:15px; borders:1px solid white;">
			<img src="<%=imgPath %>notification_icon_1.jpg" align=absmiddle>
			<a href="/notification/list.htm?boxId=1&noteType=1" target="if_list" onclick="m_click('inbox');">
				<fmt:message key="msg.list.Unread" /><!-- 읽지않은 쪽지-->
			</a>
			<span class="num">(<%=nek.notification.Notifier.getInstance().getUnreadCount(pconn, loginuser.uid) %>)</span>
		</td>
	</tr>
	<%--
	<tr class="tr_sub">
		<td style="padding-left:15px; borders:1px solid white;">
			<img src="<%=imgPath %>approual_icon_10.jpg" align=absmiddle>
			<a href="/notification/list.htm?boxId=1&noteType=2" target="if_list" onclick="m_click('inbox');">
				<fmt:message key="msg.list.noty" /><!-- 전자결재 알림-->
			</a>
			<span class="num">(<%=nek.notification.Notifier.getInstance().getApprUnReadCount(pconn, loginuser.uid) %>)</span>
		</td>
	</tr>
	--%>
	<%
		NotificationSummary noteSummary = null;//noteSsummaries.get(NoteBox.RECEIVEDS);
		if (!data.isEmpty()){
			Iterator iter = data.iterator();
			HashMap datas = null;
			while (iter.hasNext()){
				datas = (HashMap)iter.next();
				noteSummary = noteSsummaries.get(Integer.parseInt(datas.get("boxid").toString()));
				int iTotCnt = (noteSummary == null) ? 0 : noteSummary.getTotalCount();
				int iUnReadCnt = (noteSummary == null) ? 0 : noteSummary.getUnreadCount();
	%>			
			<tr class="tr_sub">
				<td style="padding-left:20px; borders:1px solid white;">
					<img src="<%=imgPath %>configuration_icon_5.jpg" align=absmiddle>
					<a href="/notification/list.htm?boxId=<%=datas.get("boxid") %>" target="if_list" onclick="m_click('inbox');">
						<%=datas.get("name") %>
					</a>
					<span class="num">(<%=iUnReadCnt %>)</span>
				</td>
			</tr>
	<%
			}
		}
	%>
</table>

<table class="mail_left_table" width=100%  cellspacing=0 cellpadding=0 border=0>
	<tr>
		<td style="padding-left:5px;"><img src="<%=imgPath %>approual_icon_2.jpg" align=absmiddle>&nbsp;<a href="/notification/list.htm?boxId=2" target="if_list" onclick="m_click('inbox');"><fmt:message key="mail.noti.send"/><!-- 보낸쪽지함--></a><span class="num"></span></td>
	</tr>
	<tr class="tr_sub">
		<td style="padding-left:5px;" class="sub">
			<img src="<%=imgPath %>admin_icon_9.jpg" align=absmiddle>
			<a href="/notification/receiptlist.htm?boxId=2" target="if_list" onclick="m_click('inbox');">
				<fmt:message key="mail.received.check"/><!-- 수신확인-->
			</a>
			<span class="num"></span>
		</td>
	</tr>
</table>

</div>
<%	} %>
</div>

<div style="line-height:1px; ">&nbsp;</div>

</form>
</body>
</fmt:bundle>

</html>
<%
	}catch(Exception e){
		System.out.println("mail_left.jsp : " + e);
	}finally{
		if (db != null) db.freeDbConnection();
	}
%>