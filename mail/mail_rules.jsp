<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="nek.mail.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="nek.common.util.*" %>
<%@ page import="nek.common.dbpool.*" %>
<%@ page import="com.oreilly.servlet.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ include file="../common/usersession.jsp" %>
<%!
	private MailRepository repository = MailRepository.getInstance();//new MailRepository();
	private RuleManager ruleManager = new RuleManager();
%>
<%
	// 에(이/가) -> :
	String[] FIELDS =  { "<font color='blue'>"+msglang.getString("mail.subject") /* 제목 */ +"</font> " + msglang.getString("mail.filter.is") + " ", 
							  "<font color='blue'>"+msglang.getString("mail.sender") /* 보낸사람 */ +" ("+msglang.getString("mail.filter.name.addr") /* 이름+주소 */ +")</font> " + msglang.getString("mail.filter.is") + " ", 
							  "<font color='blue'>"+msglang.getString("mail.sender") /* 보낸사람 */ +" "+msglang.getString("addr.address") /* 주소 */ +"</font> " + msglang.getString("mail.filter.is") + " ",
							  "<font color='blue'>"+msglang.getString("mail.sender") /* 보낸사람 */ +" "+msglang.getString("t.name") /* 이름 */ +"</font> " + msglang.getString("mail.filter.is") + " ", 
							  "<font color='blue'>"+msglang.getString("mail.recipient") /* 수신사람 */ +" ("+msglang.getString("mail.filter.name.addr") /* 이름+주소 */ +")</font> " + msglang.getString("mail.filter.is") + " ", 
							  "<font color='blue'>"+msglang.getString("mail.recipient") /* 수신사람 */ +" "+msglang.getString("addr.address") /* 주소 */ +"</font> " + msglang.getString("mail.filter.is") + " ", 
							  "<font color='blue'>"+msglang.getString("mail.recipient") /* 수신사람 */ +" "+msglang.getString("t.name") /* 이름 */ +"</font> " + msglang.getString("mail.filter.is") + " " };
	//협력업체 권한 체크
// 	if (loginuser.securityId < 1){
// 		String notPeermission = msglang.getString("sch.have.not.peermission"); /* 사용권한이 없습니다. */
// 		out.print("<script language='javascript'>alert('"+notPeermission+"');history.back();</script>");
// 		//out.close();
// 		return;
// 	}
	request.setCharacterEncoding("utf-8");

	//메일서버 DBconnect
	DBHandler db = new DBHandler();
	Connection con = null;
    //도메인명
    String domainName = application.getInitParameter("nek.mail.domain");
    if(!uservariable.userDomain.equals("")) domainName = uservariable.userDomain;

	String cmd = request.getParameter("cmd");
	if (cmd != null) {
		if (cmd.equals("delete")) {
			String[] ruleIds = request.getParameterValues("ruleid");
			if (ruleIds != null) {
				int[] ids = new int[ruleIds.length];
				for (int i = 0; i < ruleIds.length; i++) {
					ids[i] = Integer.parseInt(ruleIds[i]);
				}

				try {
					con = db.getDbConnection();
					ruleManager.delete(con, loginuser.emailId, ids, domainName);
				} finally {
					if (con != null) { db.freeDbConnection(); }
				}
			}

		} else if ( (cmd.equals("new")) || (cmd.equals("edit")) )  {
			int priority = Integer.parseInt(request.getParameter("priority"));
			int field = Integer.parseInt(request.getParameter("field"));
				
			/* 0: 포함, 1: 일치 */
			String paramExact = request.getParameter("match");
			boolean match = (paramExact != null && paramExact.equals("1"));

			/* 0: 삭제, 아니면 해당 메일함으로 이동 */
			String paramAction = request.getParameter("action");
			int action = Rule.ACTION_MOVE;
			int target = Mailbox.TRASH;
			if (paramAction != null) {
				//휴지통으로 이동: default:
				if (paramAction.startsWith("0")) {
					action = Rule.ACTION_DELETE;
				} else {
					target = Integer.parseInt(paramAction);
				}
					 
				
				/*else if (paramAction.startsWith("0_")) {
					int index = paramAction.indexOf('_');
					if (index > 0) {
						target = Integer.parseInt(paramAction.substring(index + 1));
					}
				}
				*/
			} 

			String keywords = request.getParameter("keywords");
			if (keywords != null) {
				Rule rule = new Rule(-1, priority, field, keywords, match, action, target);
				try {
					con = db.getDbConnection();

                    if (cmd.equals("edit")) { //수정이라면 삭제 후 저장
                        String[] ruleIds = request.getParameterValues("ruleid");
                        if (ruleIds != null) {
                            int[] ids = new int[ruleIds.length];
                            for (int i = 0; i < ruleIds.length; i++) {
                                ids[i] = Integer.parseInt(ruleIds[i]);
                            }
                        
                            ruleManager.delete(con, loginuser.emailId, ids, domainName); //삭제 
                        }
                    }

					ruleManager.create(con, loginuser.emailId, rule, domainName);
				} finally {
					if (con != null) { db.freeDbConnection(); }
				}
			}
		}

		response.sendRedirect("mail_rules.jsp");
		return;
	}

	
	Collection rules = null;
	Mailboxes mailboxes = null;

	try {
		con = db.getDbConnection();
		rules = ruleManager.getRules(con, loginuser.emailId, false, domainName);
		mailboxes = repository.getCustomMailboxes(con, loginuser.emailId, 1, domainName);	//받은편지함
	} finally {
		if (con != null) { db.freeDbConnection(); }
	}

%>

<html>
<fmt:setLocale value="<%=loginuser.locale %>"/>
<fmt:bundle basename="messages">
<head>
<title><fmt:message key="mail.autoClassification"/>&nbsp;<%-- 자동분류 --%></title>
<meta http-equiv="Content-type" content="text/html; charset=utf-8">

<%@ include file="/WEB-INF/common/include.jquery.jsp" %>
<%@ include file="/WEB-INF/common/include.common.jsp" %>

<script language="javascript">
function OnClickToggleAllSelect() {
	var rules = document.getElementsByName("ruleid");
	if (rules.length > 0) {
		var checked = !rules[0].checked;

		for (var i = 0; i < rules.length; i++) {
			rules[i].checked = checked;
		}
	}
}

function OnClickDelete() {
	var rules = document.getElementsByName("ruleid");
	if (rules.length < 1) {
		return;
	}

	var count = 0;
	for (var i = 0; i < rules.length; i++) {
		if (rules[i].checked) {
			count++;
		}
	}

	if (count < 1) {
		alert("<fmt:message key='mail.filter.rules.delete'/>");//삭제할 규칙을 선택하세요!
		return;
	}

	if (confirm("<fmt:message key='c.delete.really'/>")) {//정말 삭제 하시겠습니까?
        document.fmMailRules.cmd.value ="delete" ; 
		document.fmMailRules.submit();
	}
}

function OnClickCreate() {
	var keywords = document.fmMailRules.keywords.value;
	keywords = TrimAll(keywords);
	if (keywords == "") {
		alert("<fmt:message key='mail.filter.words'/>");//필터링 할 단어를 입력하세요!
		document.fmMailRules.keywords.focus();
		return;
	}
	document.fmMailRules.keywords.value = keywords;
    if (document.fmMailRules.cmd.value == "edit" ) 
    {
        var idx = document.fmMailRules.editnum.value ;  
        var names = document.getElementsByName("ruleid");  
        names[idx].checked = true;

    } else {
	    document.fmMailRules.cmd.value = "new";
    }
	document.fmMailRules.submit();
}

function goEdit(cnt,  priority, field,keyword, match,action,actionmailbox) 
{

    document.fmMailRules.cmd.value ="edit" ; 
    document.fmMailRules.editnum.value = cnt ; 
    document.fmMailRules.priority.selectedIndex = priority -1  ;
    document.fmMailRules.field.selectedIndex = field ;
    document.fmMailRules.keywords.value = keyword ;

    var iMatchVal = 0 ; 
    if (match) iMatchVal = 1 ; 
    document.fmMailRules.match.selectedIndex = iMatchVal ;
    
    if (action != 0)  {
        document.fmMailRules.action.value = 0 ;
    }else {
        var iLen = document.fmMailRules.action.options.length ; 
        for(var i = 0 ; i< iLen ;i++){            
            if (document.fmMailRules.action.options[i].value == actionmailbox ) {                
                document.fmMailRules.action.selectedIndex = i ; 
                break ; 
            }
        }  
    }

}

</script>
</head>

<style>
body {margin:0px; overflow-y:auto; }
</style>

<body>
<form name="fmMailRules" method="POST" action="mail_rules.jsp" onsubmit="return false;">
<!-- hidden field -->
<input type="hidden" name="cmd" value="delete">
<input type="hidden" name="editnum" value="">

<!-- List Title -->
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
<tr>
<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
	<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> <fmt:message key="mail.option"/>&nbsp;&gt;&nbsp;<fmt:message key="mail.autoClassification"/></span>
</td>
<td width="40%" align="right">
<!-- n 개의 읽지않은 문서가 있습니다. -->
</td>
</tr>
</table>
<!-- List Title -->

<table border="0" cellpadding="0" cellspacing="0" width="100%"><tr height="8"><td></td></tr></table>
	
<!-- 버튼 시작 -->
<a onclick="OnClickDelete();" class="button white medium"> 
<img src="../common/images/bb01.gif" border="0"> <fmt:message key="t.delete"/><%-- 삭제 --%> </a>
<!-- 버튼 끝 -->
	
<table border="0" cellpadding="0" cellspacing="0" width="100%"><tr height="6"><td></td></tr></table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" id="viewTable">
	<tr> 
		<td height="30" valign="top"> 
			<table width="100%" border="0" cellspacing="0" cellpadding="0" height="29">
				<tr> 
					<td width="5"></td>
					<td align="center">
						<table width="100%" border="0" cellspacing="0" cellpadding="0" style="position:relative;top:1px">
							<colgroup>
								<col width="20">
								<col width="60">
								<col width="1">
								<col width="*">
							</colgroup>
							<tr>
								<td align="center" class="SubTitleText">
									<img src="../common/images/btn_checkbox.gif" onClick="OnClickToggleAllSelect()" style="cursor: hand">
								</td>
								<td align="center" class="SubTitleText"><fmt:message key="t.priority"/>&nbsp;<!-- 우선순위 --></td>
								<td align="center"><img src="<%=imagePath %>/sub_img/titlebar_line.jpg" width="2" height="16"></td>
								<td align="center" class="SubTitleText"><fmt:message key="mail.contents"/>&nbsp;<!-- 내용 --></td>
							</tr>
						</table>
					</td>
					<td width="5" ></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr> 
		<td height="30" valign="top"> 
		<!-- 본문 DATA 시작 -->
		<%
			if (rules != null && rules.size() > 0) {
                   int iCnt = 0 ; 
				boolean alternating = false;
				Iterator iter = rules.iterator();
				while (iter.hasNext()) {
					Rule rule = (Rule)iter.next();

					alternating = !alternating;
		%>
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr> 
					<td width="5"></td>
					<td> 
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr> 
								<td height='25' <%=(alternating) ? "bgcolor='F5F5F5'" : "" %>>
									<table width="100%" border="0" cellspacing="0" cellpadding="0" style="position:relative;top:1px;">
										<colgroup>
											<col width="20">
											<col width="60">
											<col width="1">
											<col width="*">
										</colgroup>
										<tr> 
											<td align="center" class="SubText" nowrap>
									            <input type="checkbox" name="ruleid" value="<%=rule.getID()%>">
											</td>
											<td nowrap align="center" class="SubText">
												<%=rule.getPriority()%>
											</td>
											<td nowrap></td>
											<td class="SubText">
						                        <a href="javascript:goEdit(<%= iCnt++ %>, <%= rule.getPriority()%>,<%= rule.getField()%>, '<%= HtmlEncoder.encode(rule.getKeywords()) %>', <%= rule.isExactMatch() %>, <%= rule.getAction() %>, <%= rule.getTargetMailboxID() %>  ); "> 
												<%
													out.print(FIELDS[rule.getField()]);
													out.print("<font color='blue'>");
													out.print(HtmlEncoder.encode(rule.getKeywords()));
													out.print("</font>");
													//out.print(rule.isExactMatch() ? "와(과) 일치하면 " : "을(를) 포함하면 ");
													if(rule.isExactMatch()){%>
														<fmt:message key="mail.filter.match"/>&nbsp;<!-- 와(과) 일치하면 -->
												<%  }else{%>
														<fmt:message key="mail.filter.include"/>&nbsp;<!-- 을(를) 포함하면 -->
												<%}	if (rule.getAction() == Rule.ACTION_DELETE) {%>
														<font color='red'><fmt:message key="t.delete"/>&nbsp;<!-- 삭제 --></font>
												<%	} else {
														int target = rule.getTargetMailboxID();
														if (target == Mailbox.TRASH) {%>
															<font color='blue'><fmt:message key="mail.trash"/>&nbsp;<!-- 휴지통 --></font><fmt:message key="mail.filter.moving"/>&nbsp;<!-- (으)로 이동합니다. -->
														<%} else {
															Mailbox box = mailboxes.get(target);
															if (box != null) {%>
																	<font color='blue'>
																<%out.print(HtmlEncoder.encode(box.getName()));%>
																	</font><fmt:message key="mail.filter.moving"/>&nbsp;<!-- (으)로 이동합니다. -->
															<%}									
														}			
													}
												%>
						                        </a>
									        </td>
										</tr>
									</table>
								</td>
							</tr>
							<tr> 
								<td height="1" bgcolor="c3c3c3"></td>
							</tr>
						</table>
					</td>
					<td width="5"></td>
				</tr>
			</table>
			<%
				    }
			    }else{
			    	String NODoc_autodelete = msglang.getString("mail.no.drawn"); /*작성된 자동 분류가 없습니다!*/
			    	if(loginuser.locale.equals("en")){NODoc_autodelete = "Not created automatically classified!";}
			    	out.println("<table width='100%' style='height:expression(document.body.clientHeight-400);' border='0' cellspacing='0' cellpadding='0'><tr>"
							+ "<td width='5'></td><td>"+StringUtil.getNODocExistMsg(200, NODoc_autodelete)
							+ "</td><td width='5'></td></tr></table>");
			    }
			%>
			<!-- 본문 DATA 끝 -->
		</td>
	</tr>
	<tr>
		<td>
			<table width="100%" height="50" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td width=11><img src=../common/images/comment_le_top.gif></td>
					<td width=* height=10 background=../common/images/comment_top_bg.gif></td>
					<td width=11><img src=../common/images/comment_ri_top.gif></td>
				</tr>
				<tr>
					<td width=11 background=../common/images/comment_le_bg.gif></td>
					<td width="*">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="*">
									<table width="100%" cellspacing=0 cellpadding=0 border=0 class="tblfix">
										<tr>
											<td width="7%"><fmt:message key="t.priority"/>&nbsp;<!-- 우선순위 --></td>
											<td width="4%">
												<select name="priority" style="width:100%">
													<option value="1">1</option>
													<option value="2">2</option>
													<option value="3">3</option>
													<option value="4">4</option>
													<option value="5">5</option>
													<option value="6">6</option>
													<option value="7">7</option>
													<option value="8">8</option>
													<option value="9">9</option>
												</select>
											</td>
											<td width="3%">&nbsp;</td>
											<td width="12%">
												<select name="field" style="width:100%">
													<option value="0"><fmt:message key="mail.subject"/>&nbsp;<!-- 제목 --></option>
													<option value="1"><fmt:message key="mail.sender"/>&nbsp;<!-- 발신인 -->(<fmt:message key="mail.filter.name.addr"/>&nbsp;<!-- 이름+주소 -->)</option>
													<option value="2"><fmt:message key="mail.sender"/>&nbsp;<!-- 발신인 --> <fmt:message key="addr.address"/>&nbsp;<!-- 주소 --></option>
													<option value="3"><fmt:message key="mail.sender"/>&nbsp;<!-- 발신인 --> <fmt:message key="t.name"/>&nbsp;<!-- 이름 --></option>
													<option value="4"><fmt:message key="mail.recipient"/>&nbsp;<!-- 수신인 -->(<fmt:message key="mail.filter.name.addr"/>&nbsp;<!-- 이름+주소 -->)</option>
													<option value="5"><fmt:message key="mail.recipient"/>&nbsp;<!-- 수신인 --> <fmt:message key="addr.address"/>&nbsp;<!-- 주소 --></option>
													<option value="6"><fmt:message key="mail.recipient"/>&nbsp;<!-- 수신인 --> <fmt:message key="t.name"/>&nbsp;<!-- 이름 --></option>
												</select>
											</td>
											<td width="8%"><fmt:message key="mail.filter.is"/>&nbsp;<!-- 에(이/가) --> </td>
											<td width="12%">
												<input type="text" name="keywords" style="width:100%"> 
											</td>
											<td width="15%">
												<select name="match" style="width:100%">
													<option value="0"><fmt:message key="mail.filter.include"/>&nbsp;<!-- 을(를) 포함하면 --></option>
													<option value="1"><fmt:message key="mail.filter.match"/>&nbsp;<!-- 와(과) 일치하면 --></option>
												</select>
											</td>
											<td width="18%">
												<select name="action" style="width:100%">
													<option value="0"><fmt:message key="t.delete"/>&nbsp;<!-- 삭제 --></option>
													<option value="<%=Mailbox.TRASH%>"><fmt:message key="mail.delete.move.trash"/>&nbsp;<!-- 을(를) 휴지통으로 이동합니다. --></option>
													<%
														if (mailboxes != null) {
															Iterator iter = mailboxes.iterator();
															while (iter.hasNext()) {
																Mailbox box = (Mailbox)iter.next();
																out.println("<option value='" + box.getID() + "'>" + HtmlEncoder.encode(box.getName()) + " " + msglang.getString("mail.filter.moving") /* 이동 */ + "</option>");%>
<%-- 																																<option value="<%= box.getID()%>"><%=HtmlEncoder.encode(box.getName())%> &nbsp;<!-- (으)로 이동합니다. --></option> --%>
															<%}
														}
													%>
												</select>
											</td>
											<td width="8%"><fmt:message key="mail.do.that"/>&nbsp;<!-- 합니다 -->.</td>
										</tr>
									</table>									

								</td>
								<td width="78" align="center">
									<span onclick="OnClickCreate()" class="button white medium">
									<img src="../common/images/bb02.gif" border="0"> <%=msglang.getString("t.create") /* 작성 */ %> </span>
								</td>
							</tr>
						</table>
					</td>
					<td width=11 background=../common/images/comment_ri_bg.gif></td>
				</tr>
				<tr>
					<td><img src=../common/images/comment_le_down.gif></td>
					<td width="*" height="10" background="../common/images/comment_down_bg.gif"></td>
					<td><img src=../common/images/comment_ri_down.gif></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td>* <fmt:message key="mail.filter.separated.words"/>&nbsp;<!-- 필터링 할 단어가 여러개인 경우는 ','로 분리해서 입력하세요. ex)광고,성인 --></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr> 
		<td height="15"></td>
	</tr>
</table>
																
	</form>
	<script language="javascript">
		SetHelpIndex("mail_rule");
	</script>
</body>
</fmt:bundle>
</html>	