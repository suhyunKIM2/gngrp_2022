<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>  
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>  
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>  
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>  
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>  
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>  
  
<%@ page import="java.util.*" %>  
<%@ page import="nek.common.*" %>  
<%@ page import="nek.common.util.Convert" %>  
<%@ page import="nek3.domain.*" %>  
<%@ page import="nek3.domain.approval.*" %>  
<%@page import="java.text.SimpleDateFormat"%>  
  
<%!  
    String sImagePath =  ApprDocCode.APPR_IMAGE_PATH  ; 
    String sJsScriptPath =  ApprDocCode.APPR_JAVASCRIPT_PATH ;  
    String sCssPath =  ApprDocCode.APPR_CSS_PATH ;  
    String imgCssPath = "/common/css/blue/blue.css";  
	String imagePath = "/common/images/blue";  
	  
	private static SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");  
      
    private String setSelectedOption(String str1, String str2)  
    {  
    	String selectStr = "";  
    	if (str1.equals(str2)) selectStr = "selected";  
    	return selectStr;  
    }  
  
    private String setCheckedOption(String str1, String str2)  
    {  
    	String selectStr = "";  
    	if (str1.equals(str2)) selectStr = "checked";  
    	return selectStr;  
    }  
      
    //겸직 사용자 체크 함수  
    private boolean checkApprUser(UserL user, String userId){  
    	if(user.getSubUsers() != null){  
    		for(UserL u : user.getSubUsers()){  
    			if(userId.equals(u.getUserId())) return true;  
    		}  
    	}  
    	if(userId.equals(user.getUserId())) return true;  
    	  
    	return false;  
    }  
  
%>  
<%  
	UserL user = (UserL)request.getAttribute("user");  
	String locale = (String)request.getAttribute("locale");  
	String sUid = user.getUserId();  
	  
	org.springframework.context.support.MessageSourceAccessor ma = (org.springframework.context.support.MessageSourceAccessor)request.getAttribute("messageAccessor");  
	  
	//하나로 apprid  
	String mainApprId  = "";  
	  
	// 기안자의 정보를 가져온다.  
	String sLoginName = user.getnName();//성명  
	String sLoginDpname = user.getDepartment().getDpName();//부서명  
	String sLoginDpid = user.getUserPosition().getUpName();//직책코드  
	String sLoginUName = "" ;  
	String oldApprid = "";  
	String gianDpName = "";	//기안부서(사업장포함)  
	String sReNewEdit = "";  
  
    String sChkDelete = ApprDocCode.APPR_SETTING_T ; //상신 후 결재자의 결재가 없다면 삭제 가능하게 하라.  
  
    //현페이지의 성격을 나타낸다. ( 신규, 수정, 임시저장, 삭제)  
    String cmd = ApprUtil.setnullvalue(request.getParameter("cmd"),  ApprDocCode.APPR_NEW );   
	String sMenuId = request.getParameter("menu") ;//메뉴번호  
    int iMenuId = Integer.parseInt(sMenuId) ;   
  
    String sApprId = ApprUtil.nullCheck(request.getParameter("apprId")) ;  
  
    String sResultPass = ApprUtil.setnullvalue(request.getParameter("resultpass"),  ApprDocCode.APPR_SETTING_T) ; // 결재 패스워드 일치여부  
             
    String sPop = ApprUtil.nullCheck(request.getParameter("pop")) ;  
    String sMobile = (String)request.getAttribute("sMobile") ;	//모바일버전 조회확인  
    String sReceiveHistory = ApprUtil.nullCheck(request.getParameter("receivehistory")) ; //수신이력을 보여준다.수신함일 경우만..   
    String circul = ApprUtil.nullCheck(request.getParameter("circul")) ;   
      
  	//합의 문서의 원결재문서 정보   
    ApprovalDocReadInfo apprOldInfo = (ApprovalDocReadInfo)request.getAttribute("apprOldInfo"); //Old DOC INFO  
    //결재 문서 정보  
    ApprovalDocReadInfo apprreadInfo = (ApprovalDocReadInfo)request.getAttribute("apprreadInfo");  
    mainApprId = apprreadInfo.getApprDoc().getApprId();  
  
    String sChkReceive = "" ;   
    boolean sChkHelp = false;  
      
    int apprMaxNo = (Integer)request.getAttribute("apprMaxNo");	//최종결재자 순번  
      
 	//상위 사업장 + 표시  
    gianDpName = (String)request.getAttribute("gianDpName");  
 	  
 	//정형양식 에디터 본문내용  
 	String regEdit = apprreadInfo.getRegBody();  
          
    //최초 협조 결재자 일때 내부 결재자 선택이 가능 유무  
//     if(apprreadInfo.getApprovalType().equals(ApprDocCode.APPR_NUM_6)&&apprreadInfo.getApprIngNo()==0){  
	if(apprreadInfo.getApprovalType().equals(ApprDocCode.APPR_NUM_6)){  
    	sChkHelp = true;  
    	regEdit = apprOldInfo.getRegBody();  
    	mainApprId = apprOldInfo.getApprDoc().getApprId();  
    }  
          
    if(apprreadInfo.getApprFormid().length()==4){  
    	oldApprid =  (String)request.getAttribute("oldApprid");  
    	//oldApprid = apprObj.ApprTopAppridSelect();  
    }  
      
	//폼양식 로드  
    String sFormID = ApprUtil.nullCheck(request.getParameter("formId")) ;  
    ApprForm apprformInfo = (ApprForm)request.getAttribute("apprformInfo");  
    int apprSize = (apprformInfo==null) ? apprreadInfo.getApprCnt() : apprformInfo.getApprCnt();  
    int helpSize = (apprformInfo==null) ? apprreadInfo.getHelpCnt() : apprformInfo.getHelpCnt();  
    int reqSize = (apprformInfo==null) ? apprreadInfo.getApprReqCnt() : apprformInfo.getReqCnt();  
//------------------------------------------------------------------------------------------------------------------  
    // 첨부 파일 경로 가져오기     
    String baseURL = apprreadInfo.getHomePathUrl() ;  
    if (!baseURL.endsWith("/")) baseURL += "/";  
    if(apprreadInfo.getApprovalType().equals(ApprDocCode.APPR_NUM_6)){  
    	baseURL += "approval/appr_download.jsp?apprid=" + apprreadInfo.getTopApprID() + "&fileno=";      
    }else{  
    	baseURL += "approval/appr_download.jsp?apprid=" + sApprId + "&fileno=";      
    }  
//------------------------------------------------------------------------------------------------------------------  
// 보존년한과 비밀등급 가져오기  
    ArrayList arrSecurityID = new ArrayList() ;  
    ArrayList arrPeriod = new ArrayList() ;  
  
    arrPeriod = apprreadInfo.getArrPreserve() ;   
    arrSecurityID = apprreadInfo.getArrSecurity() ;   
  
//------------------------------------------------------------------------------------------------------------------  
    //수신인의 타이틀값 한글값을 UTF-8로 변환해서 보내야 한다.  
    String sReceiveParam = "caption="+java.net.URLEncoder.encode("NEK 주소록", "UTF-8")+"&title="+java.net.URLEncoder.encode("수신인을 선택하세요", "UTF-8") ;   
%>  
  
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">  
<HTML>  
<HEAD>  
<TITLE>결재 - <%= apprreadInfo.getFormTitle() %></TITLE>  
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">  
<meta http-equiv="X-UA-Compatible" content="IE=Edge" />  
<!-- css -->  
<!--   
<link rel="STYLESHEET" type="text/css" href="<%= imgCssPath %>">  
<link rel=STYLESHEET type="text/css" href="<%= sCssPath %>/apprread.css">  
 -->  
  
<!-- script -->  
<script src="<%= sJsScriptPath %>/appr_help.js"></script>  
<script src="<%= sJsScriptPath %>/appr_doc.js"></script>  
  
<%@ include file="../common/include.jquery.jsp"%>  
<%@ include file="../common/include.common.jsp"%>  
  
<link rel="STYLESHEET" type="text/css" href="/common/active-x/tagfree/tagfree_approval.css">  
<link rel="stylesheet" type="text/css" href="/common/libs/daumeditor/7.5.11/css/content_view.css">  
<link rel="stylesheet" type="text/css" href="/common/libs/daumeditor/7.5.11/css/content_wysiwyg.css">  
<style>  
@page a4sheet { size: 21.0cm 29.7cm }  
.a4{ page: a4sheet; page-break-after: always }  
  
#APPROVAL_DOC .bg {background-color:#e4e4e4; text-align:middle; }  
#APPROVAL_DOC .td {border:1px solid #aaa; font-size:9pt; }  
#F_APLINE a {border-width: 0px;}  
#F_APLINE_H a {border-width: 0px;}  
  
</style>  
  
<SCRIPT LANGUAGE="JavaScript">  
<!--  
  
//도움말  
var APPR_SIZE = <%= apprSize %>;  
var HELP_SIZE = <%= helpSize  %>;  
var REQ_SIZE = <%= reqSize %>;  
  
<%  
    String sHelpID = "appr_appringdoc" ;   
    if ((iMenuId > ApprMenuId.ID_300_NUM_INT && iMenuId < ApprMenuId.ID_2000_NUM_INT) || (iMenuId == ApprMenuId.ID_130_NUM_INT))  
        sHelpID = "appr_apprfinishdoc" ;   
    else if (iMenuId > ApprMenuId.ID_2000_NUM_INT)   
        sHelpID = "appr_apprhamdoc" ;   
  
%>  
  
var S_EDIT = "<%= ApprDocCode.APPR_EDIT %>" ;  
var S_DEL = "<%= ApprDocCode.APPR_DELETE %>" ;  
var S_CANCEL = "<%= ApprDocCode.APPR_CANCEL %>";  
var S_URGENT = "<%= ApprDocCode.APPR_URGENT %>" ;  
  
var MOVE_MENU_ID = "<%= ApprMenuId.ID_110_NUM %>" ;  
var FORMID = "<%= sApprId%>" ;  
var MUNU = "<%= sMenuId%>" ;  
  
var RECEIVE_USER = "<%= ApprDocCode.RECEIVE_PERSON %>" ;  
var RECEIVE_DEPT = "<%= ApprDocCode.RECEIVE_DEPT %>" ;  
var VAL_T = "<%= ApprDocCode.APPR_SETTING_T %>" ;  
var VAL_F = "<%= ApprDocCode.APPR_SETTING_F %>" ;  
var RECEIVE_URL_PARAM = "<%= sReceiveParam %>" ;  
var gianUID = "";  
  
var FormCode = "<%= apprreadInfo.getApprFormid() %>";  
  
function goReflash(){  
	<%if(iMenuId==ApprMenuId.ID_240_NUM_INT){%>  
	//opener.parent.left.location.reload();  
	<%}%>  
	var frm = document.getElementById("apprWebForm");  
	  
	var flagType = document.getElementsByName("apprDoc.flagType");  
	var flagText = document.getElementById("flagText");  
	if(flagType[0].value=="3"){  
		flagText.innerHTML = "<FONT color='red'><B>중요</B></font>"  
	}  
}  
  
function goPrintView(){  
	var url = "./appr_printview_doc.jsp?cmd=<%=cmd%>&menu=<%=sMenuId%>&apprid=<%=sApprId %>";  
	OpenWindow( url, "", "755" , "610" );  
}  
  
//결재 진행중인 문서 회수   
function OnApEdit(sApprid){  
	var frm = document.getElementById("apprWebForm");  
	if( ! confirm("<spring:message code='appr.c.edit.content' text='현 결재문서를 수정하시겠습니까?'/>") ) return ;  
	frm.calltype.value="APEDIT";  
	frm.action="./apprdoc_edit.htm";  
	frm.submit();  
	  
}  
  
//결재 참조 문서 팝업  
function goRefDocViewer(docId, docType){  
// 	if(docType=="1"){	//결재문서  
// 		var url= "/approval/apprdoc.htm?apprId=" + docId + "&menu=130&cmd=EDIT";		  
// 	}else{		//문서관리  
// 		var url= "/dms/read.htm?docId=" + docId;  
// 	}  
  
	url= "/approval/apprdoc_view.htm?apprId=" + docId + "&menu=520&cmd=EDIT";  
	  
	OpenWindow( url, "", "800" , "610" );  
}  
  
function goDocViewer(apprId){  
	var url= "/approval/apprdoc.htm?apprId=" + apprId + "&menu=130&cmd=EDIT";  
	//url= "/approval/appr_apprdoc.jsp?apprid=" + docs + "&menu=640&cmd=EDIT&receivehistory=RECEIVE";//수신문서  
	  
	OpenWindow( url, "", "800" , "610" );  
}  
  
function goRevisionPop(apprId){  
	var url= "/approval/appr_revision_pop.htm?apprId=" + apprId;  
	  
	ModalDialog({'t':'Revision History', 'tp':winx, 'lp':winy, 'w':430, 'h':210, 'm':'iframe', 'u':url, 'modal':false, 'd':false, 'r':false });  
	//OpenWindow( url, "", "400" , "300" );  
}  
  
//조회 : 문서 조회 시 결재선 표시에 사용하는 함수  
function setApLineEditorByRead() {  
// 	alert("START - setApLineEditorByRead");  
	try {  
		var twe = document.getElementById("twe");  
		var d = (twe)? twe.GetDOM(): document;  
  
// 		if ( !twe ) {  
// 			alert();  
// 			imsibody, F_HEADER  
// 			var imsibody = document.getElementById("imsibody");  
// 			var F_HEADER = document.getElementById("F_HEADER");  
// 			F_HEADER.innerHTML = imsibody.innerText;  
// 		}  
  
/*  
		//문서번호  
	 	var docno = document.getElementById("DOC_NO");	//ap table  
	 	var f_docno = document.getElementById("F_DOCNO");	//ap table  
	 	f_docno.innerText = docno.innerText;  
	  
	 	//보안수준   
	 	var preserveId = document.getElementById("bbs.preservePeriod.preserveId");  
	 	var f_security = document.getElementById("F_SECURITY");  
	 	f_security.innerText = $(preserveId).find("option:selected").text();  
*/  
	  
	 	//결재설정 F_APLINE  
		var appobj = document.getElementById("appobj");	//ap table  
		var F_TABLE = d.getElementById("F_APLINE").childNodes[0];  
		F_TABLE = $(d.getElementById("F_APLINE")).find("table").get(0);   
		for ( var i=0; i < appobj.rows.length-1; i++ ) {  
			for ( var j=0; j < appobj.rows[i].cells.length; j++) {  
				if ( i==0 ) {  
					//F_TABLE.rows[i].cells[j+1].innerText = $.trim(appobj.rows[i].cells[j].innerText.replace("<br>",""));  
					$(F_TABLE.rows[i].cells[j+1]).html( $(appobj.rows[i].cells[j]).html().replace("<br>",""));  
				} else if ( i==2 ) {  
					//F_TABLE.rows[i].cells[j].innerText = $.trim(appobj.rows[i+1].cells[j].innerText.replace("<br>",""));  
					$(F_TABLE.rows[i].cells[j]).html( $(appobj.rows[i+1].cells[j]).html().replace("<br>",""));  
					// 직급 + 이름으로 되어 있는것을 이름만 표기  
				} else {  
					//F_TABLE.rows[i].cells[j].innerText = appobj.rows[i].cells[j].innerText;  
					  
					//F_TABLE.rows[i].cells[j].innerHTML = appobj.rows[i].cells[j].innerHTML;  
					//F_TABLE.rows[i].cells[j].innerHTML += appobj.rows[i+1].cells[j].innerHTML;  
					  
					$(F_TABLE.rows[i].cells[j]).html( $(appobj.rows[i].cells[j]).html() );  
					$(F_TABLE.rows[i].cells[j]).append( $(appobj.rows[i+1].cells[j]).html() );  
					//$(F_TABLE.rows[i].cells[j]).css("font-size","8pt");  
					$(F_TABLE.rows[i].cells[j]).css("padding-top","2px");  
					$(F_TABLE.rows[i].cells[j]).css("line-height","12px");  
					//$(F_TABLE.rows[i].cells[j]).css("font-family","tahoma");  
				}  
			}  
		}  
		//합의설정 F_APLINE_H  
		var appobj = document.getElementById("helpobj");	//ap table  
		var F_TABLE = d.getElementById("F_APLINE_H").childNodes[0];  
		F_TABLE = $(d.getElementById("F_APLINE_H")).find("table").get(0);  
		for ( var i=0; i < appobj.rows.length-1; i++ ) {  
			for ( var j=0; j < appobj.rows[i].cells.length; j++) {  
				if ( i==0 ) {  
					//F_TABLE.rows[i].cells[j+1].innerText = $.trim(appobj.rows[i].cells[j].innerText.replace("<br>",""));  
					$(F_TABLE.rows[i].cells[j+1]).html( $(appobj.rows[i].cells[j]).html().replace("<br>",""));  
				} else if ( i==2 ) {  
					//F_TABLE.rows[i].cells[j].innerText = $.trim(appobj.rows[i+1].cells[j].innerText.replace("<br>",""));  
					$(F_TABLE.rows[i].cells[j]).html( $(appobj.rows[i+1].cells[j]).html().replace("<br>",""));  
					// 직급 + 이름으로 되어 있는것을 이름만 표기  
				} else {  
					//F_TABLE.rows[i].cells[j].innerText = appobj.rows[i].cells[j].innerText;  
					  
					//F_TABLE.rows[i].cells[j].innerHTML = appobj.rows[i].cells[j].innerHTML;  
					//F_TABLE.rows[i].cells[j].innerHTML += appobj.rows[i+1].cells[j].innerHTML;  
					  
					$(F_TABLE.rows[i].cells[j]).html( $(appobj.rows[i].cells[j]).html() );  
					$(F_TABLE.rows[i].cells[j]).append( $(appobj.rows[i+1].cells[j]).html() );  
					//$(F_TABLE.rows[i].cells[j]).css("font-size","8pt");  
					$(F_TABLE.rows[i].cells[j]).css("padding-top","2px");  
					$(F_TABLE.rows[i].cells[j]).css("line-height","12px");  
					//$(F_TABLE.rows[i].cells[j]).css("font-family","tahoma");  
				}  
			}  
		}  
		  
		//신청결재설정 F_APLINE_R  
		var appobj = document.getElementById("ApReceipt");	//ap table  
		if(d.getElementById("F_APLINE_R")){  
		var F_TABLE = d.getElementById("F_APLINE_R").childNodes[0];  
		F_TABLE = $(d.getElementById("F_APLINE_R")).find("table").get(0);  
			for ( var i=0; i < appobj.rows.length-1; i++ ) {  
				for ( var j=0; j < appobj.rows[i].cells.length; j++) {  
					if ( i==0 ) {  
						//F_TABLE.rows[i].cells[j+1].innerText = $.trim(appobj.rows[i].cells[j].innerText.replace("<br>",""));  
						$(F_TABLE.rows[i].cells[j+1]).html( $(appobj.rows[i].cells[j]).html().replace("<br>",""));  
					} else if ( i==2 ) {  
						//F_TABLE.rows[i].cells[j].innerText = $.trim(appobj.rows[i+1].cells[j].innerText.replace("<br>",""));  
						$(F_TABLE.rows[i].cells[j]).html( $(appobj.rows[i+1].cells[j]).html().replace("<br>",""));  
						// 직급 + 이름으로 되어 있는것을 이름만 표기  
					} else {  
						//F_TABLE.rows[i].cells[j].innerText = appobj.rows[i].cells[j].innerText;  
						  
						//F_TABLE.rows[i].cells[j].innerHTML = appobj.rows[i].cells[j].innerHTML;  
						//F_TABLE.rows[i].cells[j].innerHTML += appobj.rows[i+1].cells[j].innerHTML;  
						  
						$(F_TABLE.rows[i].cells[j]).html( $(appobj.rows[i].cells[j]).html() );  
						$(F_TABLE.rows[i].cells[j]).append( $(appobj.rows[i+1].cells[j]).html() );  
						//$(F_TABLE.rows[i].cells[j]).css("font-size","8pt");  
						$(F_TABLE.rows[i].cells[j]).css("padding-top","2px");  
						$(F_TABLE.rows[i].cells[j]).css("line-height","12px");  
						//$(F_TABLE.rows[i].cells[j]).css("font-family","tahoma");  
					}  
				}  
			}  
		}  
		  
		// 합의문서 일 경우 F_APLINE_H, R 을 모두 제거 함.  
		<% if(apprreadInfo.getApprovalType().equals(ApprDocCode.APPR_NUM_6)){	%>  
			var F_TABLE = d.getElementById("F_APLINE_H");  
			var F_TopNode = F_TABLE.parentNode;  
// 			F_TopNode.parentNode.removeChild(F_TopNode);  
			F_TopNode.removeChild(F_TABLE);  
			var R_TABLE = d.getElementById("F_APLINE_R");  
			if(R_TABLE){  
				var R_TopNode = R_TABLE.parentNode;  
				R_TopNode.removeChild(R_TABLE);  
			}  
			  
			//합의 타이틀 변경  
			$(d.getElementById("F_APLINE").childNodes[1].rows[0].cells[0]).html("합<br><br>의");  
		<%} %>  
		  
	} catch(e) {  
		//alert( "err");  
	}  
	ApLineRotate();  
}  
  
//결재선 공백 제거함수  
function ApLineRotate() {  
  
	var tbl;  
	var td;  
	var strTbl = "F_APLINE,F_APLINE_H".split(",");  
	//var strTbl = "F_APLINE".split(",");  
	var d = null;  
	var ifrm = document.getElementById("tx_canvas_wysiwyg1");  
	if (ifrm == null) {  
		d = document;  
	} else {  
		var y = (ifrm.contentWindow || ifrm.contentDocument);  
		d = y.document;  
	}  
	  
	for ( var n=0; n < strTbl.length; n++ ) {  
		div = d.getElementById( strTbl[n] );  
 		tbl = $(div).find("table").get(0);  
 		if (tbl === undefined) continue;  
		tr_last = tbl.rows[tbl.rows.length-1];	//이름이 있고 없고를 기준으로 이동함.  
		for( var a = tr_last.cells.length-1; a >= 0; a--) {  
			td_chk = tr_last.cells[a];	//tr의 마지막 셀(이름)  
			  
			// old Code: $.trim(td_chk.innerText) == "" // `innerText`는 `FF`에서 지원않하는 문제  
			if ( $.trim($(td_chk).text()) == "" ) {	//이동할 위치가 비어있으면   
				//console.log("삭제 : " + a + "/" + td_chk.innerText + "/");  
			  
				td_chk.style.display = "none";  
				tbl.rows[1].cells[a].style.display = "none";				  
				tbl.rows[0].cells[a+1].style.display = "none";  
			} else {  
				//console.log("유지 : " + a + "/" + td_chk.innerText + "/");  
				  
				td_chk.style.display = "";  
				tbl.rows[1].cells[a].style.display = "";  
				tbl.rows[0].cells[a+1].style.display = "";  
				  
				tbl.parentElement.style.display = "";	//결재선 변경으로 추가. 2013.08.19 김정국  
			}  
		}  
	}  
}  
//-->  
</SCRIPT>  
  
<script type="text/javascript">  
  
$(document).ready(function () {  
	//김정국 추가 - 모바일 인 경우 viewport 및 jquery mobile 관련 js, css 로드. 제일 하단에 ui-body-c css 있음.  
	if (navigator.userAgent.match(/iPad/) == null && navigator.userAgent.match(/Mobile|Windows CE|Windows Phone|Opera Mini|POLARIS/) != null){  
		var head = document.getElementsByTagName("head")[0];  
		var s = document.createElement("meta");  
		s.name = "viewport";  
		s.content = "width=device-width, minimum-scale=0.4, maximum-scale=1, initial-scale=0.4, user-scalable=yes";  
		head.appendChild(s);  
		s = null;  
		  
/*  
		s = document.createElement("link");  
		s.rel = "stylesheet";  
		s.href = "/common/jquery/mobile/1.0/jquery.mobile-1.0.min.css";  
		head.appendChild(s);  
		s = null;  
  
		s = document.createElement("script");  
		s.type = "text/javascript";  
		s.src = "/common/jquery/mobile/1.0/jquery.mobile-1.0.min.js";  
		head.appendChild(s);  
		s = null;  
*/  
	}  
	//$("#content").css("height","500px;;");  
//	ApLineRotate();  
	  
	if("${apprWebForm.apprDoc.apprLastState}" == "F"){  
		setApLineEditorByRead();  
	}  
	  
	moveComment();	//결재의견 위치 이동 ( 의견 이동 후 스크롤 사이즈 조정 )  
	  
	try {  
		if (isXen ) $("#dispRegContent").toggle();  
	} catch(e) {  
		  
	}  
	  
	// 복사된 버튼바 폭의 길이로 인해 인쇄시 공백이 많이 생기는 현상으로 인해 주석처리함 2014-01-19  
	//ActionButtonCopy();  
	  
//	addHeight = $("#ApComment").css("height");  
//	layer.setSize( $(window).width(), ($(window).height()-(addHeight) ));  
  
  
	//localeSet();  
	  
	//New Window 일 경우만 아래 수행  
	//setPaperType("${apprWebForm.apprDoc.pageType}");  
  
	  
	pageScroll();	// page Scroll을 위해 사용. 2013-08-31  
	ApLineRotate();	//결재선 공백제거  
	  
//	$('#pageScroll').css("height", 500 ) ;  
//	$('#pageScroll').css("border","1px solid red");  
});  
  
  
function ActionButtonCopy() {  
	var btnHtml = "<div id='ActionButtonBottom' style='margin-top:3px;'>" + $("#ActionButton").html() + "</div>";  
	var apcmt = $("#paperWidth").append( btnHtml );  
}  
  
// 결재의견 위치 이동  
function moveComment() {  
	var cmt = document.getElementById("ApComment");  
	var subj = document.getElementById("F_STORAGE");  
	var cmtWid = (FormCode.length == 4) ? "100%" : "742px" ;  
	  
	//subject의 아래로 이동 : div > td > tr > > tbody > table >  
	//var cmthtml = "<div id='ApComment' style='width:749px; margin-top:3px; margin-right:5px;'>" + $(cmt).html() + "</div>";  
	var cmthtml = "<div id='ApComment' style='width:" + cmtWid + "; margin-top:3px; margin-right:5px;'>" + $(cmt).html() + "</div>";  
	var tbl = $(subj).parent().parent().parent().parent();  
	//$(tbl).next().remove();	//p tag remove  
	$(cmt).remove();  
	var apcmt = $(tbl).after( cmthtml );  
// 	$(apcmt).css("margin-top", "3px");  
// 	$(apcmt).css("margin-right", "5px");   
}  
  
//필수 값 언어변환  
function localeSet() {  
	  
	var lang = "<%=locale %>";  
	if( lang == "") return;  
	  
	var flds = "F_NAME^F_DEPT^F_DATE^F_DOCNO^F_SECURITY^F_STORAGE^F_RECEIPT^F_SUBJECT".split("^");  
	var txt = "Drafter^Draft Dept^Created^Doc. No^Security^Storage^Receipts^Subject".split("^");;  
  
	if ( lang == "cn" ) {  
		txt = "Drafter^Draft Dept^Created^Doc. No^Security^Storage^Receipts^Subject".split("^");;  
	}  
	  
	var d = document;  
	for ( var i=0; i < flds.length; i++) {  
		var obj = $(d).find("div.#"+flds[i])[0];  
		  
		if ( !obj ) {  
			console.log(flds[i] + "<spring:message code='t.no.search' text='못찾음' />");  
		}  
  
		var ctd = $(obj).parent();  
		var td = $(ctd).prev();  
  
		$(td).text( txt[i] );  
		$(td).css("text-align", "center");  
		$(td).css("font-family", "verdana");  
	}  
}  
  
/*   
function window.onbeforeprint()  
{  
	var btntbl = document.getElementsByName("btntbl");  
	for( var i=0; i < btntbl.length; i++) {  
		btntbl[i].style.display = "none";  
	}  
}  
  
function window.onafterprint() {  
	var btntbl = document.getElementsByName("btntbl");  
	for( var i=0; i < btntbl.length; i++) {  
		btntbl[i].style.display = "";  
	}  
}  
 */  
</script>  
  
<script type="text/javascript">  
  
//양식에 따른 페이지 크기 조절  
function setPaperType(pageType) {  
	// 세로 : 900 , 750 , 가로 : 1024 * 500 ?  
	var paperWidth = document.getElementById("paperWidth");  
	var pWidth = 758;  
	  
	if ( pageType == "L" ) {  
		pWidth = 1026;  
		wWidth = pWidth + 200;  
		wHeight = 750;  
	} else {  
		pWidth = 758;  
		wWidth = pWidth + 200;  
		wHeight = 750;  
	}  
	var dispContent = document.getElementById("dispContent");  
	  
	if("${apprWebForm.search.pop}"=="POP") return;  
	  
	if(dispContent){  
		dispContent.style.width = pWidth + "px";  
		paperWidth.style.width = pWidth + "px";  
		window.resizeTo( wWidth, wHeight);  
	}  
}  
  
</script>  
</HEAD>  
<body onload="goReflash();" style="padding:0px; margin:0px; margin-top:5px; margin-left:5px;">  
<form:form commandName="apprWebForm">  
<form:hidden path="apprDoc.flagType" />  
<input type="hidden" name="cmd" value="<%= cmd %>"> <% //신규작성(new), 수정(edit), 삭제(del)  %>  
<input type="hidden" name="menu" value="<%= sMenuId %>">   
<input type="hidden" name="apprId" value="<%= sApprId %>">  
<input type="hidden" name="topapprid" value="<%= apprreadInfo.getTopApprID() %>">  
<input type="hidden" name="renewedit" value="S">  
<input type="hidden" name="approvaltype" value="<%= apprreadInfo.getApprovalType() %>">   
<input type="hidden" name="formid" value="<%= apprreadInfo.getApprFormid() %>" >  
<input type="hidden" name="sformid" value="<%= apprreadInfo.getApprFormid() %>" >  
<input type="hidden" name="apprformid" value="<%=apprreadInfo.getApprFormid() %>">  
<input type="hidden" name="calltype" >  
<input type="hidden" name="chkhelp" value="<%=sChkHelp %>">  
<input type="hidden" name="pop" value="<%= sPop %>"/>  
<input type="hidden" name="dbody" value=""/><!-- 합의문서의 본문내용 다시 저장함. -->  
<input type="hidden" name="regbody" value=""/><!-- 정형문서의 본문내용 -->  
<input type="hidden" name="apprMaxNo" value="<%= apprMaxNo %>" >  
<input type="hidden" name="dmsCateId" >  
<!-- popup에서 받는 값 -->  
<input type="hidden" name="apprflagid" >   
<input type="hidden" name="apprxengeal" >   
<input type="hidden" name="apprnote" >   
<input type="hidden" name="apprpass" >   
  
<!-- 소유권이전 -->  
<input type="hidden" name="receiveownid" >  
<input type="hidden" name="ownid" value="<%= sUid %>">  
  
<!-- 모바일확인 -->  
<input type="hidden" name="apprmobile" value="<%= sMobile %>"/>  
  
<!-- 문서이관 -->  
<%  
    String sFileSeparator = java.io.File.separator ;  
    String sDownPath = application.getInitParameter("datadir") ;  
    if (!sDownPath.endsWith(sFileSeparator)) sDownPath += sFileSeparator;  
    String sDownFilePathName = sDownPath + "approval"+sFileSeparator ;  
//Debug.println(apprreadInfo.getFileName() ) ;   
%>  
   
<div id="pageScroll" class="wrapper">  
  
<table id="paperWidth" style="width:786px; float:left; table-layout:fixed; padding-left:5px; " border=0 cellspacing=0 cellpadding=0 align=center>  
<tr>  
<td style="padding:0px;">  
  
<!-- 타이틀 시작 -->  
<table width="100%" border="0" cellspacing="0" cellpadding="0" height="34" name="btntbl" id=btntbl>  
	<tr>   
		<td height="27">   
			<table width="100%" border="0" cellspacing="0" cellpadding="0" height="27">  
				<tr>  
					<td width="35"><img src="<%=imagePath %>/sub_img/sub_title_approval.jpg" width="27" height="27"></td>  
					<td width="400" class="SubTitle" style="font-size:11pt; font-wieght:bold;"><b><!--<spring:message code="appr.form" text="전자결재 양식"/> - --><%=(apprformInfo==null) ? "" : apprformInfo.getSubject(locale) %></b></td>  
					  
					  
					<td valign="bottom" width="*" align="right">   
						<table border="0" cellspacing="0" cellpadding="0" height="17">  
							<tr>   
								<td valign="top" class="SubLocation"><%= ApprUtil.getNavigation(iMenuId, ma)%></td>  
								<td align="right" width="15"><img src="<%=imagePath %>/sub_img/sub_title_location_icon.jpg" width="10" height="10"></td>  
							</tr>  
						</table>  
					</td>  
				</tr>  
			</table>  
		</td>  
	</tr>  
	<tr>   
		<td height="3"></td>  
	</tr>  
	<tr>   
		<td height="3">   
			<table width="100%" border="0" cellspacing="0" cellpadding="0" height="3">  
				<tr>   
					<td width="200" bgcolor="eaeaea"><img src="<%=imagePath %>/sub_img/sub_title_line.jpg" width="200" height="3"></td>  
					<td bgcolor="eaeaea"></td>  
				</tr>  
			</table>  
		</td>  
	</tr>  
</table>  
<!-- 타이틀 끝 -->  
  
<table id=blanktbl><tr><td class="tblspace03"></td></tr></table>  
<!-- --------------------------------------------------------------------------------------- -->  
<%  
//결재자 정보를 보여주자  
// 외부 변수  sGianUID, sGianGa  include시키는 쪽에 두개의 변수가 선언되어 있어야 한다.  
  
//ArrayList arrPer = apprreadInfo.getArrApprPepole() ;  
ArrayList arrTemp = apprreadInfo.getArrApprPepole() ;  
int iPerSize = (arrTemp == null ) ? 0 : arrTemp.size() ;  
  
String  sApprNo= "", sApprBujaeUID = "", sUpName = "" ; //sApprType_pop = "",//결재시 팦업창에 결재 형태를 넘기기 위한 변수  
String sType = "", sImage = "", sDpname = "", sApprUid = ""  ;  
String sNname = "", sApprDate = "", sNote = "", sFlag = "", sFlagHan = "";  
String sBujaeHan = "", sXengal = "",  sInApprId  = "" , sOuid = ""  ;  
String sShowNote = "" , sShowUser = "" ;  
String sNowApprNo = "" ;   
String sBtnNowApprNo = "";  
  
int i = 0 ;      
//    int iType = 0 ; //기안자의 정보를 얻기위한 변수 , 각각분리 되어 있어서 몇 번째에 기안자 정보가 담겨줘 있는지 확인하라.  
//int iSize = (arrPer == null ) ? 0 : arrPer.size() ;  
  
int iTemp = 0 ;  
int iSize = 0;  
int iTempHelp = 0 ;  
int iSizeHelp = 0;  
  
boolean helpChk = false;	//협조 결재 테이블 visible  
boolean returnChk = false;		//완료된 문서가  반려이면 true(업무연락 발송 금지)  
boolean rejectChk = false;		//완료된 문서가  기각이면 true(업무연락 작성 금지 / 재기안 작성 금지)  
  
ApprPersonInfo apprpersonInfo = null ;  
ArrayList arrPer = new ArrayList() ;   
ArrayList arrHelpPer = new ArrayList() ;   
  
//------------------------------------------------------------------------------------------------------------------------  
//기안자, 현재 결재자 찿기, 삭제버튼 보여줄지 여부 파악  
boolean bFirstApprovalPerson = false ;   
boolean helpApprChk = false;	//현 결재자가 협조 이면 true  
boolean reqApprChk = false;	//현 결재자가 신청접수자 이면 true  
boolean reqLineApprChk = false; // 현 결재자가 신청접수라인에 포함되면 true  
int reqCount = 0;  
for( int z = 0 ; z < iPerSize ; z++)  
{  
   // apprpersonInfo = (ApprPersonInfo)arrPer.get(z) ;  
   apprpersonInfo = (ApprPersonInfo)arrTemp.get(z) ;     
  
    sType = apprpersonInfo.getType() ;  
    sApprUid = apprpersonInfo.getApprUid() ;  
    sFlag = apprpersonInfo.getFlag() ;   
    sApprBujaeUID = apprpersonInfo.getBujaeUID() ;   
    sApprNo = apprpersonInfo.getApprNo() ;   
    //기안자 처리  
    if ( sType.equals(ApprDocCode.APPR_DOC_CODE_GIAN) )  
    {  
%><script>gianUID = "<%=sApprUid %>";</script><%  
        continue ;  
    }  
  
	if(sChkHelp&&z!=iPerSize-2){	//협조 결재자 선택하기 위해 결재자 정보 셋팅 / 첫번째 결재자 패스  
%>  
<%  
	}  
      
	//재기안 / 업무연락  버튼 생성시  
	if(sFlag.equals(ApprDocCode.APPR_DOC_CODE_HANDLE_RETURN)){	//반려  
		returnChk = true;  
	}else if(sFlag.equals(ApprDocCode.APPR_DOC_CODE_HANDLE_GIGAC)){	//기각  
		rejectChk = true;  
	}  
	  
	//버튼에서 사용될 진행중 결재자 순번  
	if(( !(sType.equals(ApprDocCode.APPR_DOC_CODE_GIAN))) &&    
	         (sFlag.equals(ApprDocCode.APPR_DOC_CODE_HANDLE_DAEGI)) )  
	{  
		sBtnNowApprNo = sApprNo;  
	}  
	  
	if(apprreadInfo.getApprovalType().equals(ApprDocCode.APPR_NUM_5)&&sType.equals(ApprDocCode.APPR_DOC_CODE_APP)){  
    	reqCount++;  
    }  
	  
    //현 결재자의 결재 순번을 찿아라. (대리자로 설정되어서 2곳이상에 나타날 수 있슴, 병렬이나 동시결재도 마찬가지)  
    //sUid.equals(sApprUid)  
    if ( (checkApprUser(user, sApprUid)) &&   
         ( !(sType.equals(ApprDocCode.APPR_DOC_CODE_GIAN))) &&    
         (sFlag.equals(ApprDocCode.APPR_DOC_CODE_HANDLE_DAEGI))   
       )  
    {  
  
        if (bFirstApprovalPerson) continue ; //기안자 검사  
        sNowApprNo = sApprNo ; //현결재자 순번  
        bFirstApprovalPerson = true ;   
          
        if(sType.equals(ApprDocCode.APPR_DOC_CODE_HAN)){	//현 결재자가 협조이면 결재 버튼을 숨긴다.  
        	helpApprChk = true;  
        }  
        if(apprreadInfo.getApprovalType().equals(ApprDocCode.APPR_NUM_5)&&sType.equals(ApprDocCode.APPR_DOC_CODE_APP)&&reqCount==1){  
        	reqApprChk = true;  
        }  
        if(apprreadInfo.getApprovalType().equals(ApprDocCode.APPR_NUM_5)&&sType.equals(ApprDocCode.APPR_DOC_CODE_APP)&&reqCount>1){  
        	reqLineApprChk = true;  
        }  
%>  
            <input type="hidden" name="typepopup" value="<%= sType %>" >  
            <input type="hidden" name="apprno" value="<%= sApprNo %>" >  
            <input type="hidden" name="bujaeuid" value="<%= sApprBujaeUID %>" >  
<%  
    }  
      
    //삭제버튼보여주기 여부  
    if ( !"".equals(apprpersonInfo.getApprDate()) ) {   
        sChkDelete = ApprDocCode.APPR_SETTING_F ;  
    }  
      
    //협조 / 일반 결재 분리  
    if(sType.equals(ApprDocCode.APPR_DOC_CODE_HAN)){  
    	iTempHelp++;  
    	arrHelpPer.add(apprpersonInfo);  
    	helpChk = true;  
    }else{  
    	iTemp++ ;  
    	arrPer.add(apprpersonInfo);   
    }  
  
}   
boolean busiChk = (Boolean)request.getAttribute("busiChk");  
boolean isAppUser = (Boolean)request.getAttribute("isAppUser");  
boolean isApprCancel = (Boolean)request.getAttribute("isApprCancel");	//결재취소여부  
boolean isGianCancel = (Boolean)request.getAttribute("isGianCancel");	//현재 결재자 기안여부  
  
boolean isPoChk = (Boolean)request.getAttribute("isPoChk");	//발주번호 리비전시 사용가능여부  
boolean isChkIngHelp = (Boolean)request.getAttribute("isChkIngHelp");	//합의 이전  
  
//------------------------------------------------------------------------------------------------------------------------  
//수행버튼 보여주기  
%>  
  
<%for(int b=0;b<(apprSize+helpSize);b++){  
	String appUid = "", appType = ""; String apprFix ="";  
    if(b<arrTemp.size()-1){ //-(apprreadInfo.getApprReqCnt())  
    	  
    	apprpersonInfo = (ApprPersonInfo)arrTemp.get(b) ;  
      
    	if (apprpersonInfo.getType().equals(ApprDocCode.APPR_DOC_CODE_APP)) continue;  
  
    	appUid = apprpersonInfo.getApprUid();  
    	appType = apprpersonInfo.getType();  
    	  
    	if ( appType.equals(ApprDocCode.APPR_DOC_CODE_GIAN) )  
        {  
    	//기안자 제외  
            appUid = ""; appType = "";  
        }  
    	  
    	if(!apprpersonInfo.getFlag().equals("C")){  
    		apprFix = "1";  
    	}  
%>  
<SCRIPT LANGUAGE="JavaScript">  
<!--  
	var objApprPerson<%= i %> = new Object() ;  
	objApprPerson<%= i %>.type = "<%= 0 %>" ;  
	objApprPerson<%= i %>.name = "<%= apprpersonInfo.getNName() %>" ;  
	objApprPerson<%= i %>.id = "<%= apprpersonInfo.getApprUid() %>" ;  
	objApprPerson<%= i %>.position = "<%= apprpersonInfo.getUpName() %>" ;  
	objApprPerson<%= i %>.department = "<%= apprpersonInfo.getDpName() %>" ;  
	objApprPerson<%= i %>.apprtype = "<%= apprpersonInfo.getType() %>" ;  
	objApprPerson<%= i %>.apprname = "<%= ApprUtil.getApprTypeHan(apprpersonInfo.getType(), ma) %>" ;  
	objApprPerson<%= i %>.duty = "<%= apprpersonInfo.getUdName() %>" ;  
	<% if(!apprpersonInfo.getFlag().equals("C")){ %>  
	objApprPerson<%= i %>.fixed = "1";  
	<% } %>  
	  
	arrPeople.push(objApprPerson<%= i %>) ;  
//-->  
</SCRIPT>  
<%  
	}  
%>  
	<input type="hidden" name="tbapprperuid_tot" value="<%=appUid %>">  
	<input type="hidden" name="tbapprpertype_tot" value="<%=appType %>">  
	<input type="hidden" name="tbapprperfix_tot" value="<%=apprFix %>">  
<%  
}      
%>  
  
  
<%	int reqG = 0;  
	for(int b = 0; b < arrTemp.size(); b++) {  
		String appUid = "", appType = "", apprFix ="";  
    	apprpersonInfo = (ApprPersonInfo) arrTemp.get(b);  
    	  
    	if (apprpersonInfo.getType().equals(ApprDocCode.APPR_DOC_CODE_APP)) {  
    		reqG++;  
    		if (reqG == 1) continue; // 신청결재 접수자는 제외한다.  
	    	appUid = apprpersonInfo.getApprUid();  
	    	appType = apprpersonInfo.getType();  
	    	  
	    	if (!apprpersonInfo.getFlag().equals("C")) {  
	    		apprFix = "1";  
	    	}  
%>  
<SCRIPT LANGUAGE="JavaScript">  
<!--  
	var objApprPerson<%= i %> = new Object() ;  
	objApprPerson<%= i %>.type = "<%= 0 %>" ;  
	objApprPerson<%= i %>.name = "<%= apprpersonInfo.getNName() %>" ;  
	objApprPerson<%= i %>.id = "<%= apprpersonInfo.getApprUid() %>" ;  
	objApprPerson<%= i %>.position = "<%= apprpersonInfo.getUpName() %>" ;  
	objApprPerson<%= i %>.department = "<%= apprpersonInfo.getDpName() %>" ;  
	objApprPerson<%= i %>.apprtype = "<%= apprpersonInfo.getType() %>" ;  
	objApprPerson<%= i %>.apprname = "<%= ApprUtil.getApprTypeHan(apprpersonInfo.getType(), ma) %>" ;  
	objApprPerson<%= i %>.duty = "<%= apprpersonInfo.getUdName() %>" ;  
	<% if(!apprpersonInfo.getFlag().equals("C")){ %>  
	objApprPerson<%= i %>.fixed = "1";  
	<% } %>  
	  
	arrPeople_req.push(objApprPerson<%= i %>) ;  
//-->  
</SCRIPT>  
<%  
	}  
%>  
	<input type="hidden" name="tbapprperuid_tot" value="<%=appUid %>">  
	<input type="hidden" name="tbapprpertype_tot" value="<%=appType %>">  
	<input type="hidden" name="tbapprperfix_tot" value="<%=apprFix %>">  
<%  
}      
	ArrayList<?> a=apprreadInfo.getReceive();
	System.out.println(a.toString());
%>  
  
<div id="ActionButton">  
<!-- 수행버튼 시작 -->  
<jsp:include page="./apprdocbutton_in.jsp" flush="true">  
    <jsp:param name="menu" value="<%= sMenuId %>"/>  
    <jsp:param name="pop" value="<%= sPop %>"/>      
    <jsp:param name="finalproc" value="<%= apprreadInfo.getApprFinalProc() %>"/>  
    <jsp:param name="place" value="TOP"/>  
    <jsp:param name="gianouid" value="<%= apprreadInfo.getGianUID() %>"/>   
    <jsp:param name="receivehistory" value="<%= sReceiveHistory %>"/>  
    <jsp:param name="apprid" value="<%= sApprId %>"/>      
    <jsp:param name="receiveown" value="<%= sChkReceive %>"/>  
    <jsp:param name="deletedoc" value="<%= sChkDelete %>"/>      
	<jsp:param name="nowapprno" value="<%= sNowApprNo %>"/>  
	<jsp:param name="appringno" value="<%= apprreadInfo.getApprIngNo() %>"/>  
	<jsp:param name="isappruser" value="<%= isAppUser %>"/>  
	<jsp:param name="chkhelp" value="<%=sChkHelp %>"/>  
	<jsp:param name="helpapprchk" value="<%=helpApprChk %>"/>  
	<jsp:param name="reqApprChk" value="<%=reqApprChk %>"/>  
	<jsp:param name="reqLineApprChk" value="<%=reqLineApprChk %>"/>  
	<jsp:param name="approvaltype" value="<%=apprreadInfo.getApprovalType() %>"/>  
	<jsp:param name="returnchk" value="<%=returnChk %>"/>  
	<jsp:param name="rejectchk" value="<%=rejectChk %>"/>  
	<jsp:param name="busichk" value="<%=busiChk %>"/>  
	<jsp:param name="isPoChk" value="<%=isPoChk %>"/>  
	<jsp:param name="isApprCancel" value="<%=isApprCancel %>"/>  
	<jsp:param name="btnnowapprno" value="<%= sBtnNowApprNo %>"/>  
	<jsp:param name="receivecnt" value="<%= apprreadInfo.getReceive().size() %>"/>  
	<jsp:param name="circulYn" value="<%= apprreadInfo.getCirculYn() %>"/>  
	<jsp:param name="suid" value="<%= sUid %>"/>  
	<jsp:param name="sMobile" value="<%= sMobile %>"/>  
	<jsp:param name="formid" value="<%= apprreadInfo.getApprFormid() %>"/>  
	<jsp:param name="isChkIngHelp" value="<%=isChkIngHelp %>" />  
	<jsp:param name="securityId" value="<%=user.getSecurityLevel().getSecurityId() %>" />  
	<jsp:param name="sabun" value="<%=user.getSabun() %>" />  
	<jsp:param name="isGianChk" value="<%=checkApprUser(user, apprreadInfo.getGianUID()) %>" />  
	<jsp:param name="mainapprid" value="<%=mainApprId %>" />  
</jsp:include>  
</div>  
  
<table><tr><td class="tblspace09"></td></tr></table>  
  
<!-- --------------------------------------------------------------------------------------- -->  
<!--   
<div id="bodyObj" style="padding-right:6px;width:100%;overflow:auto;">  
 -->  
  
<div id=APPROVAL_DOC>  
  
<%-- //결재자들을 보여주어라. --%>  
<!--  제목을 appr_apprdoc_in.jsp 안에 삽입 -->  
<%@ include file="./apprdoc_in.jsp"%>  
  
<!-- 정형 본문 시작 -->  
<%  
if(apprformInfo!=null&&apprformInfo.getFormType().equals("T")){  
%>  
  
	<table width="100%" border="0" cellspacing="1" cellpadding="0">  
		<tr>  
			<td>  
				<div id="dispRegContent">  
	            <%= apprreadInfo.getBody() %>  
	            </div>  
	        </td>  
		</tr>  
	</table>  
  
	<%if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_1)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_1))){//근태신청서%>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A001.jsp" flush="true">  
		    <jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_2)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_2))){//공문 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A002.jsp" flush="true">  
		    <jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_3)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_3))){//회의록 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A003.jsp" flush="true">  
		    <jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_4)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_4))){//특근신청서 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A004.jsp" flush="true">  
		    <jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_5)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_5))){//휴가신청서 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A005.jsp" flush="true">  
		    <jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_6)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_6))){//인원충원신청서 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A006.jsp" flush="true">  
		    <jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_7)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_7))){//교육결과보고서 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A007.jsp" flush="true">  
		    <jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_8)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_8))){//지출결의서 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A008.jsp" flush="true">  
		    <jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_9)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_9))){//자금계획 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A009.jsp" flush="true">  
		    <jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_10)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_10))){//자금일보 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A010.jsp" flush="true">  
		    <jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_11)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_11))){//일일입출금내역서 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A011.jsp" flush="true">  
		    <jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_12)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_12))){//일일자금집행계획 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A012.jsp" flush="true">  
		    <jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_13)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_13))){//자금주보 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A013.jsp" flush="true">  
		    <jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_14)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_14))){//양도양수-신청서%>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A014.jsp" flush="true">  
		    <jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_15)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_15))){//계약종료-기안 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A015.jsp" flush="true">  
	    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>			  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_16)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_16))){//매장이전-기안 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A016.jsp" flush="true">  
	    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_17)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_17))){//내용증명-요청서 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A017.jsp" flush="true">  
	    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>	  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_18)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_18))){//계약변경-기안 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A018.jsp" flush="true">  
	    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_19)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_19))){//휴점-기안 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A019.jsp" flush="true">  
	    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_20)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_20))){//연구개발비 지출명세서 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A020.jsp" flush="true">  
	    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_21)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_21))){//시장조사 지출명세서 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A021.jsp" flush="true">  
	    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_22)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_22))){//가맹점 경조금 지급신청서 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A022.jsp" flush="true">  
	    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_23)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_23))){//경조금 지급신청서 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A023.jsp" flush="true">  
	    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_24)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_24))){//지앤 기념일 선물 지급 신청서 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A024.jsp" flush="true">  
	    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_25)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_25))){//제품교환권(협찬) 신청서 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A025.jsp" flush="true">  
	    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_26)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_26))){//제품교환권(구매) 신청서 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A026.jsp" flush="true">  
	    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_27)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_27))){//퇴직자 물품 반납 확인서 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A027.jsp" flush="true">  
	    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_28)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_28))){//매출기안 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A028.jsp" flush="true">  
	    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_29)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_29))){//지급기안(매입) %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A029.jsp" flush="true">  
	    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_30)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_30))){//신규 개설 사전 승인 기안 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A030.jsp" flush="true">  
	    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_31)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_31))){//신규양수 사전 승인 기안 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A031.jsp" flush="true">  
	    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_32)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_32))){//계약변경 승인 기안 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A032.jsp" flush="true">  
	    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_33)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_33))){//가맹계약 종료 / 해지 기안 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A033.jsp" flush="true">  
	    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_34)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_34))){//가맹점 휴점 기안 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A034.jsp" flush="true">  
	    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_35)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_35))){//대여금 신청서 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A035.jsp" flush="true">  
	    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_36)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_36))){//수주기안 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A036.jsp" flush="true">  
	    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_37)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_37))){//매출기안 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A037.jsp" flush="true">  
	    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_38)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_38))){//지급기안 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A038.jsp" flush="true">  
	    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_39)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_39))){//연장근로신청서 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A039.jsp" flush="true">  
	    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  	    	  		
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_41)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_41))){//계약 확정 기안 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A041.jsp" flush="true">  
	    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  	    	  		
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_42)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_42))){//지급기안 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A042.jsp" flush="true">  
	    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>  	    	  		
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_43)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_43))){//연장근로신청서 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A043.jsp" flush="true">  
    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
	</jsp:include>  	    	  		
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_44)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_44))){//연장근로확인서 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A044.jsp" flush="true">  
    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
	</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_45)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_45))){//신규양수 사전 승인 기안 %>  
		<jsp:include page="/WEB-INF/approval/appr_regular_A045.jsp" flush="true">  
	    	<jsp:param name="iMenuId" value="<%=iMenuId %>"/>  
		</jsp:include>    	    	  		
	<%} %>  
<%}else{ %>  
<!-- 비정형 본문시작 -->  
<table width="100%" heights="560" border="0" cellspacing="1" cellpadding="0" bgcolor="90B9CB">  
	<tr>  
		<td classs=content bgcolor=ffffff valign=top style="border:1px solid #dfdfdf; word-break:break-all;">  
           <div id="dispContent" style="display:nones;">   
                <%= apprreadInfo.getBody() %>  
           </div>  
        </td>  
	</tr>  
</table>  
<!-- 본문 끝 -->  
<%} %>  
  
<%  
if(apprreadInfo.getApprovalType().equals(ApprDocCode.APPR_NUM_6)){  
%>  
<!-- 합의 원결재문서 -->  
<table class=apsize style="margin:1px 0px;" id="ApReceipt">  
<tr height=30>  
<td width=110 align=center bgcolor="#EDF2F5">  
	<spring:message code="appr.documents.original" text="원결재문서" />  
</td>  
<td style="word-break:break-all;" align=left>  
	&nbsp;<a href="#" onClick="goOriAppovalDoc('<%=cmd %>','<%=apprreadInfo.getTopApprID() %>');" >  
	<B><%=apprOldInfo.getSubject() %></B>  
	</a>  
</td>  
</tr>  
</table>  
<!-- 합의 원결재문서 끝 -->  
<%} %>  
  
<%if(apprreadInfo.getLinkList()!=null&&apprreadInfo.getLinkList().size()>0){ %>  
<!-- 관련문서 시작 -->  
<table class="apsize" style="margin:1px 0px;">  
	<tr>  
		<td width="120" align=center class="bg" height="60"><spring:message code="t.approval.attach" text="결재문서 첨부" /></td>  
		<td width="*" valign="top">  
			<table id="DocAttach" class="apsize" style="margin:1px 0px;">  
				<colgroup>  
					<col width="*" >  
					<col width="200">  
				</colgroup>  
				<tr height=30>  
					<td align=center class="bg" >제 목</td>  
					<td align=center class="bg" >비고</td>  
				</tr>  
				<%  
					for(ApprovalLink linkInfo : apprreadInfo.getLinkList()){  
				%>  
				<tr height=30>  
					<td><a href="javascript:goRefDocViewer('<%=linkInfo.getDocId() %>', '<%=linkInfo.getDocType() %>');"><%=linkInfo.getSubject() %></a></td>  
					<td><%=linkInfo.getDescript() %></td>  
				</tr>  
				<%  
					}  
				%>  
			</table>  
		</td>  
	</tr>  
</table>  
  
<!-- 관련문서 끝 -->  
<%} %>  
  
<!-- 재기안 원본결재문서 링크 -->  
<%  
if(apprreadInfo.getOldApprId() !=null&&!"".equals(apprreadInfo.getOldApprId())){  
%>  
<table class=apsize style="top:-1px;" id="ApReceipt">  
<tr height=30>  
<td width=110 align=center bgcolor="#EDF2F5">  
	<spring:message code="appr.documents.original" text="원결재문서" />  
</td>  
<td style="word-break:break-all;" align=left>  
	&nbsp;<a href ="javascript:goDocViewer('<%= apprreadInfo.getOldApprId() %>');">  
		<spring:message code="appr.documents" text="결재문서" />  
	</a>  
</td>  
</tr>  
</table>  
<%} %>  
  
<!-- 결재의견 삽입 -->  
<jsp:include page="/approval/appropinion_pop.htm" flush="true">  
    <jsp:param name="isinline" value="yes"/>  
    <jsp:param name="apprid" value="<%=mainApprId %>"/>  
    <jsp:param name="suid" value="<%= sUid %>"/>  
</jsp:include>  
<!-- 결재의견 삽입 끝-->  
  
<!-- 첨부파일시작 -->  
<%  
	String sFileName = "";  
	if(apprreadInfo.getApprovalType().equals(ApprDocCode.APPR_NUM_6)){  
		sFileName = apprOldInfo.getFileName();  
	}else{  
		sFileName = apprreadInfo.getFileName();  
	}  
    if ( !sFileName.equals("") )  
    {  
  
        String attachURL = "../common/attachdown_control.jsp?"  
			+ "attachfiles=" + java.net.URLEncoder.encode(sFileName,"utf-8")  
			+ "&baseurl=" + java.net.URLEncoder.encode(baseURL,"utf-8");  
%>  
<jsp:include page="<%=attachURL%>" flush="true" />  
<table class="tblspace05"><tr><td></td></tr></table>  
<%  
	}  
%>  
  
</div>  
   
</td>  
</tr>  
</table>  
  
</div>  
  
<SCRIPT LANGUAGE="JavaScript">  
	//dispBody("dispContent") ;  
</SCRIPT>  
  
<% //결재 승인시 비밀번호가 다를경우에 메세지를 보여주자  
    if (sResultPass.equals(ApprDocCode.APPR_SETTING_F))   
    {  
%>  
		<SCRIPT LANGUAGE="JavaScript">  
		//<!--  
		    alert("<spring:message code='appr.not.equals.password' text='결재 비밀번호가 다릅니다.'/>");   
		//-->  
		</SCRIPT>  
<%  
    }      
%>  
  
  
</form:form>  
  
<style>  
.ui-body-c {background:#fff;}  
</style>  
  
</BODY>  
</HTML>  
  
