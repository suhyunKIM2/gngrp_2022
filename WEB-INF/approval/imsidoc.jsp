<%@page import="org.apache.commons.lang.StringUtils"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="nek3.domain.approval.*" %>
<%@ page import="nek3.domain.*" %>
<%@ page import="nek3.web.form.approval.*" %>
<%@page import="nek.common.util.HtmlEncoder"%>
<%@page import="nek.common.util.Convert"%>
<%@ page import="java.text.*" %>

<%!
	String sCssPath = "/common/css";
	String imgCssPath = "/common/css/blue/blue.css";
	String imagePath = "/common/images/blue";
	String sJsScriptPath = "/common/scripts";
	
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

%>
<%
	org.springframework.context.support.MessageSourceAccessor ma = (org.springframework.context.support.MessageSourceAccessor)request.getAttribute("messageAccessor");

	//OS 버전 확인
	String userAgent = request.getHeader("User-Agent");
	boolean isIE = userAgent.indexOf("ie") > -1 || userAgent.indexOf("IE") > -1;
	isIE = false;	//20121207 웹에디터 쓰지 않음
	UserL user = (UserL)request.getAttribute("user");
	String locale = (String)request.getAttribute("locale");
	String sUid = user.getUserId();
   
     // 보존기한을 가져 온다.
    int iLast = 0 ;  

    // 기안자의 정보를 가져온다.
    String sName = user.getnName();//성명
    String sDpname = user.getDepartment().getDpName();//부서명
    String sDpid = user.getUserPosition().getUpName();//직책코드
    String sUName = "" ;
    String gianDpName = "";
    String sCmpny = "";	// 회사명(html Content에 본인 회사명매칭{F_CMPNY}.	2017.02.20)
    
    int sLevel = user.getDepartment().getDpLevel();	// 부서레벨
	
    /* 현재 자기부서의 level이 1이면 회사명=부서명
              현재 자기부서의 level이 1이 아니면(2이면) 회사명=부서의 상위부서 
    */
    if(sLevel == 1){
    	sCmpny = sDpname;
    }else {
    	sCmpny = user.getDepartment().getParentDept().getDpName();
    }
    
    String approvalType = ApprDocCode.APPR_NUM_1;

    String regEdit = "";
    String sOldApprId = "" ;
    String sOldFileNM = "" ;
	String sFormName="";
	//현페이지의 성격을 나타낸다. ( 신규, 수정, 임시저장, 삭제)
	ApprWebForm apprWebForm = (ApprWebForm)request.getAttribute("apprWebForm");
	ApprSearch search = apprWebForm.getSearch();
	String cmd = Convert.nullCheck(search.getCmd());

    String sReturnUrl = "./imsilist.htm" ;
    if(!cmd.equals("EDIT")){
    	sReturnUrl= "./gianlist.htm" ; 
    }
    
    String sReceiveMenuId = search.getMenu();
    if(sReceiveMenuId ==null) sReceiveMenuId= "";
    if (sReceiveMenuId.equals(ApprMenuId.ID_130_NUM)) sReturnUrl = "./finlist.jsp" ; 
    String sMenuId = ApprMenuId.ID_110_NUM ; 
    int iMenuId = ApprMenuId.ID_110_NUM_INT ;

    String sPop = search.getPop(); //popup창 여부

    //임시저장후 수정 data를 가져온다.
    // 임시로 결재문서번호만 한개 가져옴(DB와 연동부분 처리해라.
    String sApprId = search.getApprId();

	//폼양식 로드
    ApprForm apprformInfo = (ApprForm)request.getAttribute("apprformInfo");
    String sFormID = apprformInfo.getApprFormNo();
    
    if(apprformInfo.getReqFlag().equals("Y")) approvalType = ApprDocCode.APPR_NUM_5;
   
    //결재 문서 정보
    ApprovalDocReadInfo apprreadInfo = (ApprovalDocReadInfo)request.getAttribute("apprreadInfo");
    String apprformContent = (String)request.getAttribute("apprformContent");

  	//상위 사업장 + 표시
    gianDpName = user.getDepartment().getDpName();
  	
//------------------------------------------------------------------------------------------------------------------
    //최종결재난 문서에서 새로 기안문작성한다. 이때 문서번호와 첨부파일을 보여주지 마라.
    String sReNewEdit = Convert.nullCheck(search.getRenewedit()) ;
    if (!sReNewEdit.equals(""))
    {
        ////문서번호와 파일을 보여주지 마라.
        cmd = ApprDocCode.APPR_NEW ;
        sOldApprId = sApprId ;
        
        sApprId = "" ;
        sMenuId = ApprMenuId.ID_110_NUM ;
        iMenuId = ApprMenuId.ID_110_NUM_INT ;
        
    }
//------------------------------------------------------------------------------------------------------------------
// 첨부 파일 경로 가져오기       
    String sFileSendUrl =  apprreadInfo.getHomePathUrl() ;
    if (!sFileSendUrl.endsWith("/")) sFileSendUrl += "/";
    sFileSendUrl += "approval/imsicontrol.htm";
    
//------------------------------------------------------------------------------------------------------------------
// 보존년한과 비밀등급 가져오기
    ArrayList arrSecurityID = null ;
    ArrayList arrPeriod = null ; 

    arrPeriod = apprreadInfo.getArrPreserve() ; 
    if (arrPeriod == null) arrPeriod = new ArrayList() ; 
    arrSecurityID = apprreadInfo.getArrSecurity() ; 
    if (arrSecurityID == null) arrSecurityID = new ArrayList() ; 

//------------------------------------------------------------------------------------------------------------------
    //수신인의 타이틀값 한글값을 UTF-8로 변환해서 보내야 한다.
    String sReceiveParam = "caption="+java.net.URLEncoder.encode("", "UTF-8")+"&title="+java.net.URLEncoder.encode(ma.getMessage("appr.distribute.line", "수신처 지정"), "UTF-8") ; 
//Form Name
	sFormName=apprreadInfo.getFormTitle();
%>


<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<HTML>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<HEAD>
<TITLE><spring:message code="t.approval" text="결재문서작성"/></TITLE>
<!-- css -->

<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.jquery.form.jsp"%>
<%@ include file="../common/include.common.jsp"%>

<!-- <script src="/common/jquery/plugins/hotkeys/jquery.hotkeys.js"></script> -->

<link rel="STYLESHEET" type="text/css" href="/common/active-x/tagfree/tagfree_approval.css">

<!-- 
<link rel=STYLESHEET type="text/css" href="<%=sCssPath%>/apprread.css">
<link rel="STYLESHEET" type="text/css" href="<%=imgCssPath%>">
 -->
<!-- script -->
<%@ include file="/common/scripts/appr_imsi.js.jsp"%>
<%-- <script src="<%=sJsScriptPath%>/appr_imsi.js"></script> --%>


<!-- <script src="/common/libs/rangy-1.2.3/rangy-core.js"></script> -->
<!-- <script src="/common/libs/rangy-1.2.3/rangy-cssclassapplier.js"></script> -->
<!-- <script src="/common/libs/rangy-1.2.3/rangy-selectionsavestore.js"></script> -->
<!-- <script src="/common/libs/rangy-1.2.3/rangy-serializer.js"></script> -->

<SCRIPT LANGUAGE="JavaScript">
<!--
var FORM_TITLE = "<%=apprformInfo.getSubject(locale) %>" ;	//양식명
var APPR_SIZE = <%= apprformInfo.getApprCnt() %>;	//기안자 제외 -1
var HELP_SIZE = <%= apprformInfo.getHelpCnt()  %>;

var MOVE_URL_IMSI = "<%=ApprMenuId.ID_120_URL%>" ;
var MOVE_NUM_IMSI = "<%=ApprMenuId.ID_120_NUM%>" ;
var MOVE_URL_APPR = "<%=ApprMenuId.ID_130_URL%>" ;
var MOVE_NUM_APPR = "<%=ApprMenuId.ID_130_NUM%>" ;

var RECEIVE_USER = "<%=ApprDocCode.RECEIVE_PERSON%>" ;
var RECEIVE_DEPT = "<%=ApprDocCode.RECEIVE_DEPT%>" ;
var VAL_T = "<%=ApprDocCode.APPR_SETTING_T%>" ;
var VAL_F = "<%=ApprDocCode.APPR_SETTING_F%>" ;

var TYPE_APPR = "<%=ApprDocCode.APPR_DOC_CODE_APPR%>" ;
var TYPE_HAN = "<%=ApprDocCode.APPR_DOC_CODE_HAN%>" ;
<%if (cmd.equals(ApprDocCode.APPR_EDIT) ){%>
var FORMID = "<%=apprreadInfo.getApprFormid()%>";
<%}else{%>
var FORMID = "<%=sFormID%>";
<%}%>
var gianDpName = "<%=gianDpName %>";
//회사명(html에 본인 회사명매칭.	2017.02.20)
var gianCmpnyName = "<%= sCmpny %>";

var FORM_CODE = "<%= apprreadInfo.getApprFormid() %>";
var REQ_SIZE = <%= apprformInfo.getReqCnt() %>;

var RECEIVE_URL_PARAM = "<%=sReceiveParam%>" ;
var console = { log: function() {} };	//결재문서 작성시 ie8에서 발생하는 오류를 막기위해 생성함(2016-01-18 / 삭제대상)

function winClose(){
	if(confirm("<spring:message code='c.unsaveClose' text='현재 문서를 닫으시겠습니까?\n\n문서 편집중에 닫는 경우 저장이 안됩니다.' />")){

		if ( window.opener ) {
			window.close();
		} else {
			try {
		 		var ifrm = $(window.frameElement).parent();
		 		var mdiv = ifrm.parent();
		 		mdiv.remove();
			} catch(e) {
				//alert( ifrm );
			}
		}
		
		//window.close();
		//return;
	}
}

function goPrintView(apprId){
		var url = "./preview.htm?apprId=" + apprId +"&cmd=EDIT&menu=240";
		OpenWindow( url, "", "810" , "610" );
	}

function htmlGenerator() {
	//editor에 결재정보 설정.
	//var ids = "ApTitle^ApInfo^ApReceipt^ApProject^ApSubject".split("^");
	var apHeader = document.getElementById("ApHeader");
	var editor = document.getElementById("twe");
	
	var tag = "<CENTER><DIV id=APPROVAL_DOC>";
	
	if (editor == null || editor == "undefined"){
// 		setEditorForm(); // 에디터의 데이터를 폼에 삽입 
		webEdit = document.getElementById("txtContent1");
		if(webEdit){
// 			Editor.modify({
// 				"content": tag + apHeader.outerHTML + editor.BodyValue + "</SPAN></CENTER>" /* 내용 문자열, 주어진 필드(textarea) 엘리먼트 */
// 			});
			seteditordata(1, tag + apHeader.outerHTML + editor.BodyValue + "</DIV></CENTER>");
		}
	} else {
		editor.BodyValue = tag + apHeader.outerHTML + editor.BodyValue + "</DIV></CENTER>";
	}
	
	/*
	for( var i=0; i < ids.length; i++) {
		var obj = document.getElementById(ids[i]);
		//editor.BodyValue = editor.BodyValue + obj.outerHTML ;
		//alert( editor.BodyValue );
		tag += obj.outerHTML;
	}
	editor.BodyValue = tag + editor.BodyValue + "</SPAN></CENTER>";
	*/
}

//발주품의서
function setConfirm(){
	var obj = event.srcElement;
	var selVal = obj.value;
	var txtVal = document.getElementsByName("confirm");
	var obj = document.getElementsByName("conf");
	
	for(var i=0;i<obj.length;i++){
		if(i==selVal){
			txtVal[selVal].value = "Y";
		}else{
			obj[i].checked = false;
			txtVal[i].value = "N";
		}
	}
}

//휴가신청서 담당자 조회 (window.showModalDialog Version)
function goVacationUserModal() {
	var frm = document.getElementById("apprWebForm");
    var sUrl = "../common/department_selector.htm?"+
			    "caption=<%=java.net.URLEncoder.encode("<spring:message code='sch.vacation' text='휴가'/>(<spring:message code='appr.out.early' text='조퇴'/>,<spring:message code='appr.out.outing' text='외출'/>) <spring:message code='appr.applicant' text='신청자'/>","utf-8")%>"+
				"&title=<%=java.net.URLEncoder.encode("<spring:message code='appr.applicant.selected' text='신청자를 선택하세요'/>","utf-8")%>"+
				"&openmode=1&onlyuser=1";
    var returnval = window.showModalDialog(sUrl, apprTrip, "dialogHeight: 480px; dialogWidth: 300px; edge: Raised; center: Yes; help: No; resizable: No; status: No; Scroll: no");
    if (returnval != null) {
		var tmp = returnval.split(":");
		frm.vcuserid.value = tmp[1];
		frm.vcusernm.value = tmp[0];
	}
}

//휴가신청서 담당자 조회 (dhtmlmodal Version)
function goVacationUser() {
    var url = "../common/department_selector.htm?"+
			    "caption=<%=java.net.URLEncoder.encode("<spring:message code='sch.vacation' text='휴가'/>(<spring:message code='appr.out.early' text='조퇴'/>,<spring:message code='appr.out.outing' text='외출'/>) <spring:message code='appr.applicant' text='신청자'/>","utf-8")%>"+
				"&title=<%=java.net.URLEncoder.encode("<spring:message code='appr.applicant.selected' text='신청자를 선택하세요'/>","utf-8")%>"+
	"&openmode=1&onlyuser=1";
    
	window.modalwindow = window.dhtmlmodal.open(
		"_CHILDWINDOW_COMM1004", "iframe", url, "<spring:message code='main.Approval' text='전자결재' />", 
		"width=300px,height=480px,resize=0,scrolling=1,center=1", "recal"
	);
}

function setDeptSelector(returnval) {
	var frm = document.getElementById("apprWebForm");
    if (returnval != null) {
		var tmp = returnval.split(":");
		frm.vcuserid.value = tmp[1];
		frm.vcusernm.value = tmp[0];
	}
}

//!휴가(외출/조퇴) 신청서 --------------------------
function vwCat() {
	var radio = event.srcElement;
	var vac = document.getElementById("vac");
	var out = document.getElementById("out");
	var time = document.getElementById("dsptime");
	
	if ( radio.value == 1 ) {
		if(vac){
			vac.style.display = "";
		}
		if(out){
			out.style.display = "none";
		}
		if(time){
			time.style.display = "none";
		}
	} else {
		if(vac){
			vac.style.display = "none";
		}
		if(out){
			out.style.display = "";
		}
		if(time){
			time.style.display = "";
		}
	}
}

function fldDate() {
	$('input[id=startdate], input[id=enddate], input[id=regDt], input[id=revDt], input[id=reqDt], input[id=compDt], input[id=gateoutSdt], input[id=gateoutEdt]').datepicker({
		showAnim: "slide",
		showOptions: {
			origin: ["top", "left"] 
		},
		monthNamesShort: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
		dayNamesMin: ['일', '월', '화', '수', '목', '금', '토'],
		dateFormat: 'yy-mm-dd',
		//buttonText: 'Calendar',
		prevText: '이전달',
		nextText: '다음달',
		//showOn: 'both',
		altField: "#alternate",
		altFormat: "DD, d MM, yy",
		changeMonth: true,
		changeYear: true,
		showOtherMonths: true,
		selectOtherMonths: true,
		beforeShow: function() {
	        setTimeout(function(){
	            $('.ui-datepicker').css('z-index', 99999999999999);
	        }, 0);
		}
	});
}

function checkVal(){
	//E:69/P:80/O:79/x:88/I:73
	// 숫자 필드에서 숫자[0~9]키, BackSpace, '-' 등 예외키만을 허용함.
	if ( !( event.keyCode == 69 || event.keyCode == 73 || event.keyCode == 79 || event.keyCode == 80 || event.keyCode == 88 ||
			event.keyCode == 101 || event.keyCode == 105 || event.keyCode == 111 || event.keyCode == 112 || event.keyCode == 120 ||
			event.keyCode == 8 || event.keyCode ==13  || event.keyCode == 45 || (event.keyCode >= 48 && event.keyCode <= 57) ) ) {
			return false;
	}
}
//-->
</script>

<!-- script //출장신청서--교육신청서  start-->
<script src="<%=sJsScriptPath%>/appr_trip.js"></script>
<script type="text/javascript">

function tripsUrl()
{
	var sUrl = "../common/recipient_selector.htm?"+
	"caption=<%=java.net.URLEncoder.encode("NEK <spring:message code='addr.addressbook' text='주소록' />","utf-8")%>"+
	"&title=<%=java.net.URLEncoder.encode("<spring:message code='appr.participant.selected' text='출장자를 선택하세요' />","utf-8")%>"+
	"&openmode=1&onlyuser=1";
	return sUrl;
}

function tripTitle(overSeas)  //타이틀 변경
{
	var titleNm = "";
	if(overSeas=="0"){
		titleNm = "(<spring:message code='appr.domestic' text='국내'/>)";
	}else if(overSeas=="1"){
		titleNm = "(<spring:message code='appr.overseas' text='국외'/>)";
	}
	var dspFormName = document.getElementById("dspFormName");
	var formtitle = "<%=Convert.nullCheck(apprformInfo.getSubject())%>" ;
	<%if(sFormID.equals("")){%>
		formtitle = "<spring:message code='appr.generalForm' text='일반양식'/>";
	<%}%>
	dspFormName.innerText = formtitle + titleNm ;
}
</script>
<!-- script //출장신청서--교육신청서 End-->
<script type="text/javascript">
//개발중
function setPaperType(pageType) {
	// 세로(P) : 900 , 750 , 가로(L) : 1024 * 500 ?
	var paperWidth = document.getElementById("paperWidth");
	var pWidth = 758; // 다음에디터는 +40px 확장필요 : 신규 작성시에만
	if ( pageType == "L" ) {
		pWidth = 1026 + 30;
		wWidth = pWidth + 72;
		wHeight = 550;
	} else {
		pWidth = 758 + 30;
		wWidth = pWidth + 72;
		wHeight = 550;
	}
	window.resizeTo( wWidth, wHeight);
	paperWidth.style.width = pWidth + "px";
}

	$(document).ready(function(){
		
		if(gianCmpnyName != null){
			//회사명 (지출결의서 신규)
			$("#cmpny").text(gianCmpnyName);
			$("#cmpny").parent().find('input[name=cmpny]').val(gianCmpnyName);	
		}
		
		// 신규 작성 시 양식명 설정.
		$(".SubTitle").text( $(".SubTitle").text() + " - " + FORM_TITLE ) ;

		<%	if (cmd.equals(ApprDocCode.APPR_NEW)) { %>
		//근태신청서 현시간 기준으로 자동 셋팅 (신규)
		try {
		} catch(e) {}
		<%	} %>
		
		//전결인 경우, 기본으로 결재선 숨김처리 하도록 함.
		try {		
			if (isXen) {
				btnToggle();	//전결인 경우 숨겨야 할 사항 : 결재헤더, 버튼, 중요도, 첨부 등 외...				
			}
		} catch(e) {}
		
		fldDate();	//DatePicker 사용하는 모든 필드에 공통사용.
		
		//setPaperType("${apprWebForm.apprDoc.pageType}");
		var editor = document.getElementById("twe");	// tagFree
		
		if (editor == null || editor == "undefined"){
			var sBody = document.getElementById("imsibody");
// 			var sBodyText = sBody.innerText ;
			var sBodyText = sBody.innerHTML ;
			sBody.innerHTML = sBodyText; 
			if(document.getElementById("tx_canvas_wysiwyg1") != null){
// 				Editor.modify({
// 					"content": sBody.innerHTML /* 내용 문자열, 주어진 필드(textarea) 엘리먼트 */
// 				});
			/*	setTimeout(function(){
					seteditordata(1, sBody.innerHTML);
				}, 0);
				
				//신규 작성 시 다음 에디터 내부에서 로딩되는 시간 때문에 설정되지 못하는 경우 발생함.
				setTimeout( "setApHeaderByNoEditor()", 1000 );
				*/
			}

			
		} else {
		}
		 
		//localeSet();
		
		//layer.setSize( $(window).width(), ($(window).height()-(addHeight) ));
		//ApLineRotate();
		
		ActionButtonCopy();
		
		pageScroll();
		setTimeout( "apEditorControl();", "1000");
	});

	var selObj;
	function apEditorControl() {
		var twe = document.getElementById("twe");
		if ( twe ) {
				var d = twe.GetDOM();
		} else {
			var ifrm = document.getElementById("tx_canvas_wysiwyg1");
			if(ifrm == null){
				var d = document;
			}else{
				var y=(ifrm.contentWindow || ifrm.contentDocument);
				var d = y.document;
			}
		}
		/*대외공문인경우 담당부서 설정
		  1. 대외공문(지앤푸드)
		  2. 대외공문(참아람)
		  3. 대외공문(분식이)
		  4. 대외공문(지앤몰)
		*/
		if(FORMID=="2016061610572435" || FORMID=="2017022110384946" || FORMID=="2017030917403502" || FORMID=="2017030917420323"){
			$(d).find("#GIAN_DEPT").text(gianDpName);
		}
/*
		var tds = $(d.body).find("td");
		for(var i = 0; i < tds.length; i++) {
			var td = $(tds[i]);
			td.html($.trim(td.html()));
		}
		
		// 필수ID 값
		try {
			$(d.body).find("#F_TITLE").attr("contenteditable", "false");	// F_TITLE (양식제목)
			$(d.body).find("#F_APLINE").attr("contenteditable", "false");	// F_APLINE (결재자)
			$(d.body).find("#F_APLINE_H").attr("contenteditable", "false");	// F_APLINE_H (합의자)
			$(d.body).find("#F_DEPT").attr("contenteditable", "false");		// F_DEPT (기안부서)
			$(d.body).find("#F_NAME").attr("contenteditable", "false");		// F_NAME (기안자)
			$(d.body).find("#F_DATE").attr("contenteditable", "false");		// F_DATE (기안일자)
			$(d.body).find("#F_STORAGE").attr("contenteditable", "false");	// F_STORAGE (보존년한)
			$(d.body).find("#F_DOCNO").attr("contenteditable", "false");	// F_DOCNO (문서번호)
			$(d.body).find("#F_SECURITY").attr("contenteditable", "false");	// F_SECURITY (보안수준)
			$(d.body).find("#F_RECEIPT").attr("contenteditable", "false");	// F_RECEIPT (수신처)
			$(d.body).find("#F_SUBJECT").attr("contenteditable", "false");	// F_SUBJECT (제목)
		} catch (e) {
			try { console.log("필수 ID 값을 찾을수 없습니다."); } catch(e) {}
		}

		$(d.body).bind("mousedown focus", function(e) {
			var id = e.target.getAttribute('id') || e.target.tagName;
			var ids = '^F_TITLE^F_DEPT^F_NAME^F_DATE^F_STORAGE^F_DOCNO^F_SECURITY^F_RECEIPT^F_SUBJECT^';

			if (id.toLowerCase() == "td") {
				var childrenItem = $(e.target).children();
				for(var i = 0; i < childrenItem.length; i++) {
					if (childrenItem.attr("contenteditable") == "false") {
						this.blur();
						return false;
					}
				}
			}
			
			if (ids.indexOf('^'+id+'^') > -1) {
				this.blur();	//입력 부분 외 개체 선택 시 포커스를 없앰.
				return false;
			} else if (id.indexOf('F_APLINE') > -1 || id.indexOf('F_APLINE_H') > -1) {
				this.blur();
				return false;
			} else {
				return true;
			}
		});
		
		*/

		// editor default cursor set
		//$(d.body).css("cursor", 'url(/common/images/prohibition.png), auto' );
		//$(d).find("td[tweedittype=true]").css("border", "1px solid rgb(114, 157, 215)");
		//$(d).find("td[tweedittype=true]").css("border", "2px solid #666");
		
		$(d.body).css("cursor", "not-allowed" );
		$(d).find("td[tweedittype=true]").css("background-color", "#f2f2f2");
		
		// editor table resize default = hidden
		$(".tx-table-row-resize-dragger").css("width", "0px");
		$(".tx-table-row-resize-dragger").css("height", "0px");

		$(".tx-table-col-resize-dragger").css("width", "0px");
		$(".tx-table-col-resize-dragger").css("height", "0px");
		
		
		// editor cursor handle
		$(d).find("td[tweedittype=true]").hover(
			function(e) {	// over
				$(this).css("cursor", "text");

				// 단순 입력 시에는 resize 없도록 하고, 내용안에 테이블이 있는 경우만 resize 활성화 기킴
				if( $(this).find("td").size() > 0 ) {
					// editor table resize enable
					$(".tx-table-row-resize-dragger").css("width", "100%");
					$(".tx-table-row-resize-dragger").css("height", "2px");

					$(".tx-table-col-resize-dragger").css("width", "2px");
					$(".tx-table-col-resize-dragger").css("height", "100%");
				}
			},
			function() {	// out
				//$(d.body).css("cursor", 'url(/http://127.0.0.1/common/images/prohibition.png), auto' );
				$(d.body).css("cursor", "not-allowed" );
				
				// editor table resize disable
				$(".tx-table-row-resize-dragger").css("width", "1px");
				$(".tx-table-row-resize-dragger").css("height", "1px");

				$(".tx-table-col-resize-dragger").css("width", "1px");
				$(".tx-table-col-resize-dragger").css("height", "1px");
				
				//$(d.body).disableSelection();
			}
		);
		
		
		// mouse down event handle : 2013-11-07 김정국 수정 건.
		// 양식함에서 서식 등록 시 tweedittype = "true" 옵션을 주어서 처리해야 함 ( tagfree와 호환 )
		// : 상기 부분은 서식 등록시 별도 예약변수를 두던가 해서 처리하도록 해야 함.
		// 1. 현재 마우스 이용해서 테이블 리사이즈 기능 막지못했음. - 완료
		// 2. 커서 이용해서 이동하는 경우에 막지 못했음.
		// 3. delete 키 이용해서 삭제할 경우 막지 못했음.
		$(d.body).bind("click mousepress mousedown", function(e) {
			var id = e.target.getAttribute('tweedittype');
			//console.log( "mouse down 선택 값 : " + e.target.nodeName );

			if ( id ) {
				//console.log( "현재 개체 : " + e.target.nodeName + " / " +  e.target.getAttribute() );
			} else {
				if( $(e.target).parents("td[tweedittype=true]").size() > 0 ) {
					//console.log( "상위에 개체 있음 : return true");
				} else {
					$(window).focus();
					return false;
				}
			}
		})
		
		// ctrl + a handle, key handle
		$(d.body).bind("keydown", function(e) {
			
			var code = e.which;
			if ( e.ctrlKey && (code == 65) ) {
				alert( "<spring:message code='appr.ctrl.a.no' text='서식보호를 위해 ctrl + a 는 사용을 금지합니다.'/>");
				return false;
			}
		
		    var node,selection;
		    if (!$.support.leadingWhitespace) {	//ie 7,8
		    	 if (!node && document.selection) {
				        selection = document.selection
				        var range = selection.getRangeAt ? selection.getRangeAt(0) : selection.createRange();
				        node = range.commonAncestorContainer ? range.commonAncestorContainer :
				               range.parentElement ? range.parentElement() : range.item(0);
				 }
			} else {
				tmp = d.getSelection();
				node = tmp.focusNode;
			}
		    			    
		    if (node) {
		        var tnode = (node.nodeName == "#text" ? node.parentNode : node);
		        
		        var sObj = tnode;			
				if ( sObj.parentNode.nodeName == "BODY" ) {
					return false;
				}
				
				var id = sObj.getAttribute('tweedittype');
				if( !id ) {
					if ( $(sObj).parents("td[tweedittype=true]").size() < 0 ) {
						$(window).focus();
						return false;
					}
				}
		    } else {
		    	// error
		    	console.log( "error- node is nothing");
		    }			
			return true;
		});
		
		// ipad 일 경우, pagescroll 선언하는 부분 진행할  - 김정국 테스트 중.
		if (isiPad()) {
			var tmp = $(d.body).html();
			var cssStyle = "position:absolute; z-index:2; top:0; left:0; bottom:0; height:" + iflist_height(1) + "px; width:" + iflist_width(1) + "px; overflow-x:scroll; overflow-y:scroll;";
			var editorBodyHtml = "<div id='EditorPageScroll' style='" + cssStyle + "'>" + tmp + "</div>";
			$(d.body).html( editorBodyHtml );
		}
	}
	
	function ActionButtonCopy() {
		var btnHtml = "<div id='ActionButtonBottom'>" + $("#ActionButton").html() + "</div>";
		var apcmt = $("#paperWidth").append( btnHtml );
	}
	
	// 전결 시 결재 헤더 숨김 여부 건.
	function hiddenApp() {
		if( $("input:checkbox[name='xenflag']").is(":checked") == true ) {
			$("input:checkbox[name='xenflag']").attr("checked", true);
		} else {
			$("input:checkbox[name='xenflag']").attr("checked", false);
		}
		
		btnToggle();
	}

	//전결 클릭 시 결재선, 수신처 등 숨김항목 처리
	function btnToggle() {
		$("#F_HEADER").toggle();	//정형 일 때 결재 헤더
		
		$(".ap_btn").toggle();	//결재자 선택
		$(".re_btn").toggle();	//수신처 선택
		$(".im_btn").toggle();	//임시저장
		
		var tmp = $(".ar_btn").html();
		if ( tmp.indexOf("결재요청") > -1 ) {
			$(".ar_btn").html( tmp.replace(/결재요청/g,"저장")) ;	//전결인 경우, 결재요청 버튼명을 저장으로 변경.
		} else {
			$(".ar_btn").html( tmp.replace(/저장/g, "결재요청") );	//전결인 경우, 결재요청 버튼명을 저장으로 변경.
		}
		
		$("#ApprovalPriority").toggle();	//중요도
		$("#DocAttach").toggle();			//기안 첨부
		$("#upload").toggle();				//파일 첨부
	}
		
	//필수 값 언어변환. 서식 타이틀은 초기에 설정되도록 함.
	function localeSet() {
		var lang = "<%=locale %>";
		if( lang == "") return;
		
		var flds = "F_NAME^F_DEPT^F_DATE^F_DOCNO^F_SECURITY^F_STORAGE^F_RECEIPT^F_SUBJECT".split("^");
		var txt = "기안자^기안부서^기안일자^문서번호^보안수준^보존년한^수신부서^제목".split("^");;

		if ( lang == "zh" ) {
			txt = "Drafter^Draft Dept^Created^Doc. No^Security^Storage^Receipts^Subject".split("^");;
		} else if ( lang == "en" ) {
			txt = "Drafter^Draft Dept^Created^Doc. No^Security^Storage^Receipts^Subject".split("^");;
		}

		var twe = document.getElementById("twe");
		if ( twe ) {
				var d = twe.GetDOM();
		} else {
			var ifrm = document.getElementById("tx_canvas_wysiwyg1");
			if(ifrm == null){
				var d = document;
			}else{
				var y=(ifrm.contentWindow || ifrm.contentDocument);
				var d = y.document;
			}
		}
		
		//var d = document;
		for ( var i=0; i < flds.length; i++) {
			var obj = $(d).find("div.#"+flds[i])[0];
			
			if ( !obj ) {
				console.log(flds[i] + "<spring:message code='t.no.search' text='못찾음'/>");
			}

			var ctd = $(obj).parent();
			var td = $(ctd).prev();

			$(td).text( txt[i] );
			$(td).css("text-align", "center");
			$(td).css("font-family", "verdana");
		}
		
		setEditorForm1();	//변환된 내용을 에디터에 다시 설정.
	}
	
	function SetEditorData1( Editor ) {
	    
		var sBody = document.getElementById("imsibody");
		var contents = '';
		contents = $('#imsibody').val();
		contents = initApLine(contents);	//결재선을 초기화 하는 함수 : 재기안 시 ?
				
		if ( !Editor.id ) {
			Editor.switchEditor(1);
			Editor.modify({
		        content: contents
			});
			
		} else {	//twe
			Editor.HtmlValue = contents;
		}
		
		editorFieldSet();	// 예약변수 값 설정	- 신규 일때
		
		if ( document.domain == 'gw.dycms.co.kr' ) {
			dycms_add();	// musso using
		}
		
		localeSet();		// 각 예약변수 타이틀 부분에 다국어-스크립트 적용 - 신규 일때
		
		headerReset();		//정형결재의 경우, 에디터에 있는 헤더 값을 F_HEADER에 설정함
		
		//ApLineRotate();		// 재기안의 경우 결재선 공백을 위해 호출해야 함.
		
		
		<%
// 		if (cmd.equals(ApprDocCode.APPR_EDIT) || (!sReNewEdit.equals(""))) {//수정이면 본문에 값 넣기
// 		    out.write("setBody();") ;
		
// 			if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_1)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_1))
// 					||sFormID.equals(ApprDocCode.APPR_FIX_NUM_4)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_4))
// 					||sFormID.equals(ApprDocCode.APPR_FIX_NUM_6)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_6))){
// 				out.write("setRegBody();") ;	//정형양식 본문
// 			}
// 		}
		%>
	}
	
function SetEditorData2( Editor ) {
//	alert( 'call SetEditorData2');
		var contents = '';
		contents = document.getElementById("apprDoc.regBody").value;
		//contents = $('#apprDoc.regBody').val();

		if ( !Editor.id ) {
			//Editor.switchEditor(2);
			Editor.modify({
		        content: contents
			});
		} else {	//twe
			Editor.HtmlValue = contents;
		}
	}
// 사용 않음 - 추후 삭제
function SetEditorData3( Editor ) {
	alert( 'call SetEditorData3');
	return;
	var sBody = document.getElementById("imsibody");
	var contents = '';
	contents = $('#imsibody').val();

	if ( !Editor.id ) {
		Editor.switchEditor(1);
		Editor.modify({
	        content: contents
		});
	} else {	//twe
		Editor.HtmlValue = contents;
	}
}


</script>

</HEAD>
<body onload="//setApHeaderByNoEditor();" style="padding:0px; margin:0px; margin-top:5px; margin-left:5px; display:none;">

<div id="pageScroll" class="wrapper">

<%-- <form name="mainForm" method="get" action="./appr_imsicontrol.jsp" ENCTYPE="multipart/form-data" > --%>
<form:form enctype="multipart/form-data" commandName="apprWebForm" onsubmit="return false;">

<!-- <div id="imsibody" style="display:none;"> -->
<textarea id="imsibody" style="display:none;">
<%=Convert.nullCheck( (apprformContent.equals(""))?apprformInfo.getContent():apprformContent ) %></textarea>
<!-- <input type="hidden" name="editbody" > -->
<form:hidden path="apprDoc.content" />
<form:hidden path="apprDoc.pageType" />
<form:hidden path="apprDoc.formType" />
<form:hidden path="apprDoc.apprCnt" />
<form:hidden path="apprDoc.helpCnt" />
<form:hidden path="apprDoc.regBody" />
<form:hidden path="apprId"/>
<form:hidden path="cmd" value="<%=cmd %>" />
<form:hidden path="browser" />
<form:hidden path="filepath"/>
<form:hidden path="fileExist"/>
<input type="hidden" name="gianopinion"  value="">
<input type="hidden" name="regulardetail" value="">
<input type="hidden" name="apprpepole" >
<input type="hidden" name="reNewEdit" value="<%=sReNewEdit %>">
<input type="hidden" name="formtitle" value="<%= apprreadInfo.getFormTitle().replace("\r\n","\\n") %>" ><% //결재양식 명 %>
<input type="hidden" name="menu" value="<%=sReceiveMenuId%>">
<input type="hidden" name="reqUserId" value="<%=apprreadInfo.getApprReqUserId() %>">	<!-- 신청결재자 접수담당자ID -->
<input type="hidden" name="reqDpId" value="<%=apprreadInfo.getApprReqDpid() %>">	<!-- 신청결재자 접수담당자부서ID -->
<input type="hidden" name="reqCnt" value="<%=apprformInfo.getReqCnt() %>">	<!-- 신청결재 라인수 -->
<%
	//신규작성(new), 수정(edit), 삭제(del)
%>
<input type="hidden" name="calltype" >
<%
	//임시저장, 결재 상신, 결재양식 호출
%>
<input type="hidden" id="apprformid" name="apprformid" value="<%=apprreadInfo.getApprFormid()%>">

<!-- 소유권이전 -->
<input type="hidden" name="receiveownid" >
<input type="hidden" name="ownid" value="<%=user.getUserId()%>">

<%
	//최종결재 완료후 재기안을 했을때 값을 가지고 있자.
%>
<input type="hidden" name="oldapprid" value="<%=sOldApprId%>" >

<script>
function OnClickPreview() {
	
	//editor 없는 경우...
	var url = "/support/PrintPreview.jsp";
	OpenWindow(url, "", 800, 600);
	return;
	
	//에디터가 있다면 에디터 이용하고, 없으면, 새창으로 띄워서 넣어주도록 한다.
	
	var editor = document.getElementById("twe");	// tagFree
	if ( editor ) {
	var ApHeader = document.getElementById("ApHeader");	//
	editor.BodyValue = "<DIV id='APPROVAL_DOC'>" + ApHeader.innerHTML + "<br/></DIV>" + editor.BodyValue;
	
	var twe_dom = editor.GetDOM();

	var span = twe_dom.getElementsByTagName("SPAN");
	for( var i=span.length-1; i >= 0; i-- ) {
		if ( span[i].style ) {
			if ( span[i].style.height ) {
				if ( span[i].style.height == "58px" || span[i].style.height == "100%" || span[i].style.height == "85px" ) {
					//alert( 'aaa');
					span[i].style.height = "10px";
				}
			}
		}
	}
	
	var input = twe_dom.getElementsByTagName("INPUT");
	for( var i=input.length-1; i >= 0; i-- ) {
		var tmp = input[i].parentNode;
		if (input[i].type == "text" ) {
			var tmp1 = input[i].value;			
			tmp.removeChild(input[i]);
			tmp.innerText = tmp1;
			tmp.style.verticalAlign = "middle";
		} else {
		tmp.removeChild(input[i]);
		}
	}
	
	var receivehtml = twe_dom.getElementById("receivehtml");	//
	var obj=twe_dom.createElement("P");
	obj.innerText = receivehtml.innerText;
	var tmp = receivehtml.parentNode;
	tmp.removeChild(receivehtml);
	tmp.appendChild(obj);
	
	/*
	var obj = twe_dom.getElementsByTagName("OBJECT");
	for( var i=obj.length-1; i >= 0; i-- ) {
		var tmp = obj[i].parentNode;
		tmp.removeChild(obj[i]);
	}
	*/
	
	editor.PrintPreview(); 
	
	setTimeout( function() {
		var editor = document.getElementById("twe");	// tagFree
		var twe_dom = editor.GetDOM();
		var apdoc = twe_dom.getElementById("APPROVAL_DOC");
		twe_dom.body.removeChild( apdoc );
	}, 300)
	} else {
		//editor 없는 경우...
		var url = "/support/PrintPreview.jsp";
		OpenWindow(url, "", 830, 600);
	}
	return;
}
</script>

<table id="paperWidth" style="width:756px; float:left; padding-left:5px; " border=0 cellspacing=0 cellpadding=0 align=center>
<tr>
<td style="padding:0px;">

<div style="line-height:5px;">&nbsp;</div>

<!-- 타이틀 시작 -->
<table width="100%" border="0" cellspacing="0" cellpadding="0" height="34" name="btntbl" id=btntbl>
	<tr> 
		<td height="27"> 
			<table width="100%" border="0" cellspacing="0" cellpadding="0" height="27">
				<tr> 
					<td width="35"><img src="<%=imagePath %>/sub_img/sub_title_approval.jpg" width="27" height="27"></td>
					<td width="400" class="SubTitle" style="font-size:11pt; font-weight:bold;"><spring:message code="appr.form" text="전자결재 양식"/></td>
					
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

<div style="line-height:5px;">&nbsp;</div>

<div id="ActionButton">
<table width="100%" border="0" cellspacing="0" cellpadding="0" height="17">
	<tr> 
		<td valign="top" class="SubLocation" align="right">

			<%	if ("GN023".equals(apprformInfo.getFormCode()) || "GN024".equals(apprformInfo.getFormCode())) { %>		
			<a onclick="javascript:OpenWindow('/approval/apprpop_gn001.html', '', 735, 400);" class="button white medium" style="float: left;">
			<img src="../common/images/bb02.gif" border="0"> 출장 여비정액표 </a>
			<%	} %>
			
<!-- 					<a onclick="javascript:printdoc();" class="button white medium"> -->
<%-- 					<img src="../common/images/bb02.gif" border="0"> <spring:message code="appr.print.preview" text="인쇄 미리보기"/></a> --%>
			<c:if test="${apprformInfo.reqFlag == 'Y' }">
			<a onclick="goApprReqPer();" class="button white medium im_btn">
			<img src="../common/images/bb02.gif" border="0"> 신청부서선택 </a>
			<div style="display:none;">
				<select id="reqList" name="reqList">
					<%	//재기안 시 신청결재자 설정하기
						ArrayList reqTemp = apprreadInfo.getArrApprPepole();
						for (int i = 0; i < reqTemp.size(); i++) {
							ApprPersonInfo apprpersonInfo = (ApprPersonInfo) reqTemp.get(i);
							if (ApprDocCode.APPR_DOC_CODE_APP.equals(apprpersonInfo.getType()) && StringUtils.isNotBlank(apprpersonInfo.getApprUid())) {
								String value = "P:"+apprpersonInfo.getApprUid()+":"+apprpersonInfo.getNName()+"::"+apprpersonInfo.getDpName()+":undefined:"+apprpersonInfo.getUpName()+":"+apprpersonInfo.getDpName();
								out.print("<option value=\""+value+"\">"+apprpersonInfo.getNName()+"/"+apprpersonInfo.getUpName()+"/"+apprpersonInfo.getDpName()+"</option>");
							}
						}
					%>
				</select>
			</div>
			</c:if>
			<%if (cmd.equals(ApprDocCode.APPR_EDIT) ){ %>
				<!-- <a onclick="javascript:goPrintView('<%=sApprId %>');" class="button white medium im_btn">
				<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.preview" text="미리보기"/> </a> -->
<%-- 			<a onclick="javascript:goPrintVIEW('<%=SAPPRID %>');" CLASS="BUTTON WHITE MEDIUM IM_BTN"> --%>
<%-- 			<IMG SRC="../COMMON/IMAGES/BB02.gif" border="0"> <spring:message code="t.preview" text="미리보기"/> </a> --%>
			<%} %>
			<a onclick="javascript:OnClickSend('<%=ApprDocCode.APPR_APPR%>', 'AP');" class="button white medium ar_btn">
			<img src="../common/images/bb02.gif" border="0"> <spring:message code="appr.request" text="결재요청"/></a>
			<!-- 
			<td width="83"> 
				<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:OnClickSend('<%=ApprDocCode.APPR_APPR%>', 'AP');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma01','','<%=imagePath%>/btn2_left.jpg',1)">
					<tr>
						<td width="23"><img id="btnIma01" src="<%=imagePath%>/btn1_left.jpg" width="23" height="22"></td>
						<td background="<%=imagePath%>/btn1_bg.jpg"><span class="btntext">&nbsp;결재요청</span></td>
						<td width="3"><img src="<%=imagePath%>/btn1_right.jpg" width="3" height="22"></td>
					</tr>
				</table>
			</td>
			 -->
			<a onclick="javascript:OnClickSend('<%=ApprDocCode.APPR_IMSI%>', 'IM');" class="button white medium im_btn">
			<img src="../common/images/bb02.gif" border="0"> <spring:message code="appr.tmp.save" text="임시저장"/> </a>
			<!-- 
			<td width="83"> 
				<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:OnClickSend('<%=ApprDocCode.APPR_IMSI%>', 'IM');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma02','','<%=imagePath%>/btn2_left.jpg',1)">
					<tr>
						<td width="23"><img id="btnIma02" src="<%=imagePath%>/btn1_left.jpg" width="23" height="22"></td>
						<td background="<%=imagePath%>/btn1_bg.jpg"><span class="btntext">&nbsp;임시저장</span></td>
						<td width="3"><img src="<%=imagePath%>/btn1_right.jpg" width="3" height="22"></td>
					</tr>
				</table>
			</td>
			 -->
			<%
				if (cmd.equals(ApprDocCode.APPR_EDIT) ) { //신규작성일 경우에는 삭제 버튼을 보이지 말자.
			%>
			<a onclick="javascript:OnDelete('<%=sApprId %>', '<%=ApprDocCode.APPR_DELETE%>');" class="button white medium">
			<img src="../common/images/bb02.gif" border="0"> <spring:message code='t.delete' text='삭제'/> </a>
			<!-- 
			<td width="60"> 
				<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:OnDelete('<%=sApprId %>', '<%=ApprDocCode.APPR_DELETE%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma03','','<%=imagePath%>/btn2_left.jpg',1)">
					<tr>
						<td width="23"><img id="btnIma03" src="<%=imagePath%>/btn1_left.jpg" width="23" height="22"></td>
						<td background="<%=imagePath%>/btn1_bg.jpg"><span class="btntext">&nbsp;삭제</span></td>
						<td width="3">	<img src="<%=imagePath%>/btn1_right.jpg" width="3" height="22"></td>
					</tr>
				</table>
			</td>
			 -->
			<%
				}
			%>
			<a onclick="javascript:goApprPer();" class="button white medium ap_btn">
			<img src="../common/images/bb02.gif" border="0"> <spring:message code="appr.add.appr.line" text="결재선 지정"/> </a>
			<!-- 
			<td width="98"> 
				<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:goApprPer();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma04','','<%=imagePath%>/btn2_left.jpg',1)">
					<tr>
						<td width="23"><img id="btnIma04" src="<%=imagePath%>/btn1_left.jpg" width="23" height="22"></td>
						<td background="<%=imagePath%>/btn1_bg.jpg"><span class="btntext">&nbsp;결재선 지정</span></td>
						<td width="3"><img src="<%=imagePath%>/btn1_right.jpg" width="3" height="22"></td>
					</tr>
				</table>
			</td>
			 -->
			<a onclick="javascript:goReceive();" class="button white medium re_btn">
			<img src="../common/images/bb02.gif" border="0"> <spring:message code="appr.distribute.line" text="수신처 지정"/> </a>
			
			<a onclick="searchRelation();" class="button white medium re_btn">
			<img src="../common/images/bb02.gif" border="0"> 결재문서첨부</a>
			<!-- 
			<td width="98"> 
				<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:goReceive();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma05','','<%=imagePath%>/btn2_left.jpg',1)">
					<tr>
						<td width="23"><img id="btnIma05" src="<%=imagePath%>/btn1_left.jpg" width="23" height="22"></td>
						<td background="<%=imagePath%>/btn1_bg.jpg"><span class="btntext">&nbsp;수신처 지정</span></td>
						<td width="3"><img src="<%=imagePath%>/btn1_right.jpg" width="3" height="22"></td>
					</tr>
				</table>
			</td>
			 -->
			<%
				if (iMenuId == ApprMenuId.ID_120_NUM_INT ) { //소유권 이전
			%>
			<a onclick="javascript:getReceiveOwnID();" class="button white medium">
			<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.changeOver" text="인수인계"/> </a>
			<!-- 
			<td width="83"> 
				<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:getReceiveOwnID();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma06','','<%=imagePath%>/btn2_left.jpg',1)">
					<tr>
						<td width="23"><img id="btnIma06" src="<%=imagePath%>/btn1_left.jpg" width="23" height="22"></td>
						<td background="<%=imagePath%>/btn1_bg.jpg"><span class="btntext">&nbsp;인수인계</span></td>
						<td width="3"><img src="<%=imagePath%>/btn1_right.jpg" width="3" height="22"></td>
					</tr>
				</table>
			</td>
			 -->
			<%
				}
			%>
			<a onclick="javascript:winClose();" class="button white medium">
			<img src="../common/images/bb02.gif" border="0"> <spring:message code="t.close" text="닫기"/> </a>
			<!-- 
			<td width="60"> 
				<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:winClose();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma08','','<%=imagePath%>/btn2_left.jpg',1)">
					<tr>
						<td width="23"><img id="btnIma08" src="<%=imagePath%>/btn1_left.jpg" width="23" height="22"></td>
						<td background="<%=imagePath%>/btn1_bg.jpg"><span class="btntext">&nbsp;닫기</span></td>
						<td width="3"><img src="<%=imagePath%>/btn1_right.jpg" width="3" height="22"></td>
					</tr>
				</table>
			</td>
			 -->
		 </td>
	</tr>
</table>
</div>

<div style="line-height:5px;">&nbsp;</div>

<!--  전자결재 양식명 -->
<!-- 
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="table2">
	<tr>
		<td align=center>
			<FONT face=돋움 style="font-size:28pt;"><STRONG><U><span id="dspFormName"><%=sFormName%></span></U></STRONG></FONT>
		</td>
	</tr>
</table>
 -->

<style>
#APPROVAL_DOC .bg {background-color:#e4e4e4; text-align:middle; }
#APPROVAL_DOC .td {border:1px solid #aaa; font-size:9pt; }
/* #APPROVAL_DOC table {border-collapse:collapse;} */
	.ui-autocomplete {
		max-height: 100px;
		overflow-y: auto;
		/* prevent horizontal scrollbar */
		overflow-x: hidden;
		/* add padding to account for vertical scrollbar */
		padding-right: 0px;
		
	}
	/* IE 6 doesn't support max-height
	 * we use height instead, but this forces the menu to always be this tall
	 */
	* html .ui-autocomplete {
		height: 100px;
		width: 205px;
		text-align:left;
	}

	</style>
<div id="ApprovalPriority">
<span style="width:100%; text-align:right; height:20px; ">
<span onclick="getFavoriteApLine();" style="float:right; padding:2px; padding-top:0px; borders:0px solid #E8E8E8; 
font-size:9pt; color:#666666; z-index:10; cursor:pointer;" title="<spring:message code="appr.apprline.load" text="저장된 결재선을 불러옵니다."/>">
<img src="/common/images/icons/icon_modify.jpg" align="middle"> <B><spring:message code="appr.often.apploval.line" text="자주 사용하는 결재선"/></B></span>
</span>

<span style="width:100%; text-align:left;">
<%-- <form:checkbox path="apprDoc.smsType" value="Y" /><b><font color="red">&nbsp;긴급결재 요청</font></b> ( ※ 긴급일 경우 SMS(문자메시지) 또는 휴대폰 알림 지원 예정 입니다. )<br/> --%>
<!-- <form:checkbox path="apprDoc.receiveYn" id="receiveYn" value="N" onclick="setReceiveType();" /><b><font color="red">&nbsp;배포금지</font></b>&nbsp;-->
&nbsp;&nbsp;<font color=blue><b><spring:message code="appr.imp" text="문서중요도"/> :</b></font>
<form:radiobuttons path="apprDoc.flagType" items="${apprFlagList }" /> 

&nbsp;<form:checkbox path="apprDoc.circulYn" value="N" /><b><font color="red">&nbsp;<spring:message code="appr.circulate.no" text="회람금지"/></font></b>

<%	
	//전결 체크 
	if(sFormID.equals("2016061610562932")||(apprreadInfo.getApprFormid().equals("2016061610562932"))
			||sFormID.equals("2016061610564077")||(apprreadInfo.getApprFormid().equals("2016061610564077"))
			||sFormID.equals("2016022909241005")||(apprreadInfo.getApprFormid().equals("2016022909241005"))
			||sFormID.equals("2016051718201364")||(apprreadInfo.getApprFormid().equals("2016051718201364"))
			||sFormID.equals("2016022615050916")||(apprreadInfo.getApprFormid().equals("2016022615050916"))// 기안(폼의)서 분식이 대표이사 자리가 공석이라 전결기능 임시생성.
	   ){	// (회람, 메모, 법인카드 분실 및 재발급신청, 업무협조문)인경우 전결기능 추가
%>
&nbsp;<input type="checkbox" name="xenflag" onclick="chkXenFlag();" value="T"><spring:message code="appr.out.directapproval" text="전결"/>
<%} %>

<%	
	//전결 체크 
	System.out.println("sFormID="+sFormID);
	System.out.println("apprreadInfo.getApprFormid()="+apprreadInfo.getApprFormid());
	if(sFormID.equals("A023")||(apprreadInfo.getApprFormid().equals("A023"))// 기안(폼의)서 분식이 대표이사 자리가 공석이라 전결기능 임시생성.
	   ){	// (회람, 메모, 법인카드 분실 및 재발급신청, 업무협조문)인경우 전결기능 추가
%>
&nbsp;<input type="checkbox" name="xenflag" onclick="chkXenFlag2();" value="T"><spring:message code="appr.out.directapproval" text="전결"/>
<%} %>

</span>
</div>

<DIV id="APPROVAL_DOC" style="width:788px;">

<!-- 결재자 정보 시작 -->
<%@ include file="./imsidoc_in.jsp"%>
<!-- 결재자 정보 끝 -->

<%-- <ACRONYM id="dspbody" style="display:none"><%= HtmlEncoder.encode(apprreadInfo.getBody()) %></ACRONYM> --%>
<ACRONYM id="regbody" style="display:none"><%= HtmlEncoder.encode(apprreadInfo.getRegBody()) %></ACRONYM>
<!-- 정형결재 양식폼  -->
<%
if(apprformInfo.getFormType().equals("T")){
%>
<!-- imsibody 의 내용을 표기한다.-->
<div id="F_HEADER" style=""></div>

<!-- 20130619 정형결재의 결재헤더 처리를 위해 에디터 히든으로 처리함. -->
	
	<div id="hiddEditor" style="display:none;">
	<%if(isIE){ %>
	<!-- IE ActiveX -->
	<jsp:include page="../common/editor_control_approval.jsp"></jsp:include><!-- 태그프리 에디터 적용 -->
	<%}else{ %>
	<div>
	<!-- No ActiveX -->
<%-- 	<jsp:include page="../common/daum_editor_control.jsp" flush="true" /> --%>
	<jsp:include page="/WEB-INF/common/daum_editor_i_multi_control.jsp" flush="true">
		<jsp:param name="i" value="1" />
		<jsp:param name="cnts" value="" />
	</jsp:include>
	</div>
	<%} %>
	</div>

	<%if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_1)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_1))){//근태신청서%>
		<jsp:include page="/WEB-INF/approval/appr_regular_A001.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_2)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_2))){//공문 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A002.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_i_multi_control.jsp" flush="true">
			<jsp:param name="i" value="2" />
			<jsp:param name="cnts" value="" />
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="2" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_3)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_3))){//회의록 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A003.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_4)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_4))){//특근신청서 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A004.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_5)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_5))){//휴가신청서 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A005.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_6)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_6))){//인원충원신청서 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A006.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_7)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_7))){//교육결과보고서 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A007.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_8)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_8))){//지출결의서 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A008.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_9)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_9))){//자금계획 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A009.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_10)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_10))){//자금일보 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A010.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_11)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_11))){//일일입출금내역서 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A011.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_12)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_12))){//일일자금집행계획 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A012.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_13)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_13))){//자금주보 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A013.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_14)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_14))){//양도양수-신청서 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A014.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_15)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_15))){//계약종료-기안 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A015.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>		
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_16)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_16))){//매장이전-기안 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A016.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_17)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_17))){//내용증명-요청서 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A017.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>		
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_18)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_18))){//계약변경-기안 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A018.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_19)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_19))){//휴점-기안 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A019.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>	
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_20)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_20))){//연구개발비 지출명세서 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A020.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_21)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_21))){//시장조사 지출명세서 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A021.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_22)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_22))){//가맹점 경조금 지급신청서 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A022.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_23)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_23))){//경조금 지급신청서 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A023.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_24)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_24))){//지앤 기념일 선물 지급 신청서 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A024.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_25)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_25))){//제품교환권(협찬) 신청서 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A025.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_26)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_26))){//제품교환권(구매) 신청서 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A026.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_27)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_27))){//퇴직자 물품 반납 확인서 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A027.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_28)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_28))){//매출기안 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A028.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_29)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_29))){//지급기안(매입) %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A029.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_30)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_30))){//신규 개설 사전 승인 기안 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A030.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_31)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_31))){//신규양수 사전 승인 기안 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A031.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_32)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_32))){//계약변경 승인 기안 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A032.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_33)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_33))){//가맹계약 종료 / 해지 기안 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A033.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_34)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_34))){//가맹점 휴점 기안 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A034.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_35)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_35))){//대여금 신청서 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A035.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_36)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_36))){//수주기안 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A036.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>	
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_37)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_37))){//수주기안 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A037.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>		
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_38)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_38))){//지급 기안(매입) %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A038.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>	
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_39)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_39))){//연장근로신청서 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A039.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>			
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_41)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_41))){//계약 확정 기안 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A041.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>			
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_42)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_42))){//지급기안 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A042.jsp" flush="true">
		<jsp:param name="iMenuId" value="110"/>
	</jsp:include>
	<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
		<jsp:param name="total" value="1" />
		<jsp:param name="height" value="250" />
	</jsp:include>			
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_43)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_43))){//연장근로신청서 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A043.jsp" flush="true">
		<jsp:param name="iMenuId" value="110"/>
	</jsp:include>
	<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
		<jsp:param name="total" value="1" />
		<jsp:param name="height" value="250" />
	</jsp:include>			
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_44)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_44))){//연장근로확인서 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A044.jsp" flush="true">
		<jsp:param name="iMenuId" value="110"/>
	</jsp:include>
	<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
		<jsp:param name="total" value="1" />
		<jsp:param name="height" value="250" />
	</jsp:include>			
	<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_45)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_45))){//신규양수 사전 승인 기안 %>
		<jsp:include page="/WEB-INF/approval/appr_regular_A045.jsp" flush="true">
			<jsp:param name="iMenuId" value="110"/>
		</jsp:include>
		<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
			<jsp:param name="total" value="1" />
			<jsp:param name="height" value="250" />
		</jsp:include>
	<%} %>

<%}else{ %><!-- 비정형 -->

	<%if(isIE){ %>
	<!-- IE ActiveX -->
	<jsp:include page="../common/editor_control_approval.jsp"></jsp:include><!-- 태그프리 에디터 적용 -->
	<%}else{ %>
	<div>
	<!-- No ActiveX -->
<%-- 	<jsp:include page="../common/daum_editor_control.jsp" flush="true" /> --%>
	<jsp:include page="/WEB-INF/common/daum_editor_i_multi_control.jsp" flush="true">
		<jsp:param name="i" value="1" />
		<jsp:param name="cnts" value="" />
	</jsp:include>
	<jsp:include page="/WEB-INF/common/daum_editor_multi_control.jsp" flush="true">
		<jsp:param name="total" value="1" />
		<jsp:param name="height" value="250" />
	</jsp:include>
	</div>
	<%} %>
<%} %>

<script>
function editorResize( Editor ) {	//override용
	var url = self.location.href.toUpperCase();
	var d_hei = "150px";
	
	 if( FORMID == 'A001' ) {
		d_hei = "200px";
		Editor.setCanvasSize({height:d_hei});
		var obj = document.getElementById("tx_trex_container2");
		obj.parentElement.style.minHeight = null;
	} 
	 
};
</script>

<table class="apsize" style="margin:1px 0px;">
	<tr>
		<td width="120" align=center class="bg" height="60"><spring:message code="t.approval.attach" text="결재문서 첨부" /><!-- <input type="button" value="전체삭제" onclick="searchDelete()" style="width:60px;"> --></td>
		<td width="*" valign="top">
			<table id="DocAttach" class="apsize" style="margin:1px 0px;">
				<colgroup>
					<col width="*" >
					<col width="200">
					<col width="30">
				</colgroup>
				<tr height=30>
					<td align=center class="bg" >제 목</td>
					<td align=center class="bg" >비고</td>
					<td align=center class="bg" ></td>
				</tr>
				<%
				if(apprreadInfo.getLinkList()!=null&&apprreadInfo.getLinkList().size()>0){
					for(ApprovalLink linkInfo : apprreadInfo.getLinkList()){
				%>
				<tr height=30>
					<td><%=linkInfo.getSubject() %></td>
					<td><input type="hidden" name="docId" value="<%=linkInfo.getDocId() %>">
						  <input type="hidden" name="docSubject" value="<%=linkInfo.getSubject() %>">
						  <input type="hidden" name="docType" value="<%=linkInfo.getDocType() %>">
						  <input type="text" name="docDescript" style="width:95%;" value="<%=Convert.nullCheck(linkInfo.getDescript()) %>">
					</td>
					<td align=center><input type="button" name="btnRemove" value="삭제" onClick="onDocDelete(this);"></td>
				</tr>
				<%
					}
				} 
				%>
			</table>
		</td>
	</tr>
</table>


<%if(isIE){ %>
<table class="apsize" style="border:0px; " id="attachControl">
<tr>
<td style="border:0px;">
<% 
        String attachURL = "../common/attachup_control.jsp?"
			+ "attachfiles=" + java.net.URLEncoder.encode(apprreadInfo.getFileName(),"utf-8")
			+ "&actionurl=" + java.net.URLEncoder.encode(sFileSendUrl,"utf-8")
			+ "&maxfilecount=" + "-1"
			+ "&maxfilesize=<c:out value='${userConfig.getUploadSize() }' />";
%>
<jsp:include page="<%=attachURL%>" flush="true" />

</td>
</tr>
</table>
<%}else{ %>
<%
String baseURL = "http://" + request.getServerName();
if(request.getServerName().indexOf("localhost") != -1){//로컬인지 서버인지 확인
	baseURL = request.getScheme() + "://" + request.getServerName()+":"+request.getServerPort(); //로컬 시 적용  (https 적용)
}else{
	baseURL = request.getScheme() + "://" + request.getServerName(); //개발, 운영 시 적용 (https 적용)
}
 if (!baseURL.endsWith("/")){ 
 	baseURL += "/";
 } 
 baseURL += "approval/appr_download.jsp?apprid=" + sApprId + "&fileno=";
 String actionURL = "/approval/imsicontrol.htm";
%>
<jsp:include page="../common/file_upload_control.jsp" flush="true">
	<jsp:param name="attachfiles" value="<%=apprreadInfo.getFileName()%>"/>
	<jsp:param name="baseURL" value="<%=baseURL%>"/>
	<jsp:param name="actionURL" value="<%=actionURL%>"/>
</jsp:include>
<%} %>

 
</td>
</tr>
</table>

<!-- 기안자 결재의견 입력 관련 추가 : 2013.08.12 김정국 -->
<div id="dialog-message" title="<spring:message code='appr.comment.drafter.input' text='기안자 결재의견 입력' />" style="display:none;">
<textarea id="cmt2" style="width:98%; height:100px; border:1px solid #aaa;"></textarea>
</div>

</form:form>

</DIV> <!--  APPROVAL_DOC END -->
<br/>

<script>
document.body.style.display = "";
</script>

</div>
</body>
</html>

<script language="javascript">
//fld_over_handle();

//자주 사용하는 결재선 선택 (window.showModalDialog Version)
function getFavoriteApLineModal() {
//	alert( event.srcElement.offsetLeft );
// 	winx = window.event.x-265;
// 	winy = window.event.y-40;
	
// 	oPopup = window.createPopup();
// 	var oPopupBody = oPopup.document.body;
// 	oPopupBody.innerHTML = "<div style='width:100%; height:100%; border:3px solid #A1B5FE;'></div>" ;

// 	wid = 250;
// 	hei = 105;
	//oPopup.show(winx, winy, wid, hei , document.body);


	var sUrl = "./appr_line_select.jsp?no="  ;
	var sUrl = "./appr_line_new.jsp?no="  ;
    var returnval = OpenModal( sUrl , self , 600 , 400 ) ;
    //var returnval = window.showModalDialog(sUrl, document,
	//"dialogHeight: 400px; dialogWidth: 400px; edge: Raised; center: Yes; help: No; resizable: No; status: No; scroll: no;");
//alert( returnval );
    if (returnval == undefined) returnval = window.returnValue;
    if ((returnval != null) && (returnval != "") )
        goApprPersonLine(returnval) ;
}

//자주 사용하는 결재선 선택 (dhtmlmodal Version)
function getFavoriteApLine() {
	try{
		if($("input:checkbox[name='xenflag']:checked").val()=="T"){
			alert("기안자 전결 선택시 결재자를 지정할수 없습니다.");
			return;
		}
		
	}catch(e){}
	
	var url = "./appr_line_new.jsp?no=";
	window.modalwindow = window.dhtmlmodal.open(
			"_CHILDWINDOW_APPR1001", "iframe", url, "<spring:message code='main.Approval' text='전자결재' />", 
			"width=500px,height=380px,resize=0,scrolling=1,center=1", "recal"
		);
}

//자주 사용하는 결재선 셋팅
function goApprPersonLine(sTemp)
{
    var sArr ;
    var sList = sTemp.split("<%= ApprDocCode.APPR_GUBUN %>");
    var objAdd = new Array() ;
    var iApprCnt = 0;
    var iHelpCnt = 0;

    for (var i = 1 ; i < sList.length ; i++ )  // 1부터 시작하는 이유 처음은 값이 없다.
    {
        sArr = sList[i].split("|");

        var objAddress = new Object();

        objAddress.type = ORGUNIT_TYPE_USER;
        objAddress.apprname = sArr[0] ;
        objAddress.department = sArr[1];

        if (sArr[2] == null || sArr[2] == "") {
            sArr[2] = SNOPOSITION_HAN ;
        }
        objAddress.position = sArr[2];
        objAddress.name = sArr[3];
        objAddress.id	= sArr[4];
        objAddress.apprtype = sArr[5]  ;
        objAddress.duty = sArr[6];
        
        if(objAddress.apprtype=="A"){
        	iApprCnt++;
        }else if(objAddress.apprtype=="H"){
        	iHelpCnt++;
        }

        objAdd.push(objAddress) ;
    }
    
    //결재선 결재자/합의자 수가  양식의 지정된 수를 넘어선다면 막는다.
    if(iApprCnt > APPR_SIZE){
    	alert("<spring:message code='appr.select.approval.over' text='선택된 결재자수가 지정된 결재양식의 결재자수를 초과합니다.'/>");
    	return;
    }else if(iHelpCnt > HELP_SIZE){
    	alert("<spring:message code='appr.select.a​greement.over' text='선택된 합의자수가 지정된 결재양식의 합의자수를 초과합니다.'/>");
    	return;
    }

	arrPeople = objAdd;
	setApprPersonLine(objAdd);

	// 에디터 내부 결재선 설정
	var twe = document.getElementById("twe");
	if ( twe ) {
		setApLineEditor();
	} else {
		var ifrm = document.getElementById("tx_canvas_wysiwyg1");
		if(ifrm == null){
			setApLineEditor();
		}else{
			setApLineEditorCross();
			
			ApLineRotate();	// 결재선 지정 후 공백있는 칸 제거 함수 : 2013-08-14 jkkim 추가
			
			var F_HEADER = document.getElementById("F_HEADER");
			
			if( F_HEADER ) {
				F_HEADER.innerHTML = geteditordata(1);
			}
		}
	}
}

	function CheckKeyCode() {
	    // 숫자 필드에서 숫자[0~9]키, BackSpace등 예외키만을 허용함.
	    //alert( event.keyCode );
	    if ( !( /* dot */ event.keyCode == 46 || event.keyCode == 8 || event.keyCode ==13 || (event.keyCode >= 48 && event.keyCode <= 57) ) ) {
			return false;
	    }
	}
	
	function CheckKeyCode1(e) {
		// 숫자 필드에서 숫자[0~9]키, BackSpace등 예외키만을 허용함.
		if(window.event){
			if ( !( event.keyCode == 46 || event.keyCode == 8 || event.keyCode ==13 || (event.keyCode >= 48 && event.keyCode <= 57) ) ) {
				return false;
			}
		}else{ // 윈도우, 사파리, 크롬
			if ( !( e.which == 46 || e.which == 8 || e.which ==13 || (e.which >= 48 && e.which <= 57) ) ) {
				return false;
			}
		}
	}

	function strMoneyFormat( strMoney ) {
		var tmp = "";
		var tmpminus = "" ; 
		var str = new Array();
		
		var dotValue = strMoney.split(".");
		if ( dotValue.length > 1 ) {
			tmp = dotValue[0];
		} else {
			tmp = strMoney;
		}
	  	
	       if (tmp.substring(0,1) == "-") {
	           tmpminus  = "-" ;
	           tmp = tmp.substring(1) ; 
	       }
		       
		var v = tmp.replace(/,/gi,''); //콤마를 빈문자열로 대체
		for(var i=0;i<=v.length;i++){ //문자열만큼 루프를 돈다.
			str[str.length]=v.charAt(v.length-i); //스트링에 거꾸로 담음
			if(i%3==0&&i!=0&&i!=v.length){ //첫부분이나, 끝부분에는 콤마가 안들어감
				str[str.length]='.'; //세자리마다 점을 찍음 - 배열을 핸들링할때 쉼표가 들어가면 헛갈리므로
			}
		}

		str = str.reverse().join('').replace(/\./gi,','); //배열을 거꾸로된 스트링으로 바꾼후에, 점을 콤마로 치환
		
		if ( dotValue.length > 1 ) {
		str += "." + dotValue[1].substring(0,2);
		}
		
		return tmpminus + str;
	}
	
	function getMoneyFormat(){
		if( arguments.length == 0 ) {
			var objFld = window.event.srcElement;
		}
		objFld.value = strMoneyFormat( objFld.value );
	}

	function moneyFormat(){
		if( arguments.length == 0 ) {
			var objFld = window.event.srcElement;
		}
		objFld.value = strMoneyFormat( objFld.value );
		sum_x( objFld );
		sum_y( objFld );
	}

	function sum_x( objFld ) {
		//현재 입력한 필드 명을 통해 처리할 부분을 찾도록 한다.
		//	var tmp = objFld.value;
		//	var price = tmp.replace(/,/gi,'');
		var returnStr = "";
		var bgtAmt = document.getElementsByName("BgtAmt");	//실행예산
		var rltAmt1 = document.getElementsByName("RltAmt");	//기발주실적금액
		var curRltAmt = document.getElementsByName("CurRltAmt");	//현재발주금액
		var remBgtAmt = document.getElementsByName("RemBgtAmt");	//잔여예산
		for ( var i=0; i < bgtAmt.length;i++ ) {
			
			if ( rltAmt1[i].value == "" && curRltAmt[i].value != "" ) {
				remBgtAmt[i].value = curRltAmt[i].value;
			} else if ( !(rltAmt1[i].value == "" || curRltAmt[i].value == "") ) {
				var intBgtAmt = eval(bgtAmt[i].value.replace(/,/gi,'')) ;
				var intRltAmt1 = eval(rltAmt1[i].value.replace(/,/gi,'')) ;
				var intCurRltAmt = eval(curRltAmt[i].value.replace(/,/gi,'')) ;
				var T=Number('1e'+6);
				returnStr = intBgtAmt - (intRltAmt1 + intCurRltAmt) + ""; /* string type */
				
				//잔여예산이 마이너스이면 Flagtype를 예산초과로 고정 아니면 전체 허용 
				var flagType = document.getElementsByName("apprDoc.flagType");
				if((intBgtAmt - (intRltAmt1 + intCurRltAmt))<0){
					flagType[0].disabled=false;
					flagType[1].disabled=true;
					flagType[2].disabled=true;
					flagType[0].checked=true;
				}else{
					flagType[0].disabled=false;
					flagType[1].disabled=false;
					flagType[2].disabled=false;
					flagType[2].checked=true;
				}
				remBgtAmt[i].value = strMoneyFormat( returnStr );
			} else {
				remBgtAmt[i].value = "";
			}
		}
	}
	
	function sum_y( objFld ) {
		//현재 입력한 필드 명을 통해 처리할 부분을 찾도록 한다.
		//	var tmp = objFld.value;
		//	var price = tmp.replace(/,/gi,'');
		var returnStr = "";
		var curRltAmt = document.getElementsByName("CurRltAmt");
		var totRltAmt = document.getElementById("totRltAmt");
		var totAccount = 0;
		for ( var i=0; i < curRltAmt.length;i++ ) {
			var intCurRltAmt = eval(curRltAmt[i].value.replace(/,/gi,'')) ;
			totAccount = totAccount + intCurRltAmt; /* string type */
			returnStr = totAccount + ""; 
		}
		totRltAmt.innerText = strMoneyFormat( returnStr );
	}

	//관련문서 검색 (dhtmlmodal Version)
	function searchRelation(){
// 		var url = "./appr_relate_search_m.jsp";
		var url = "./appr_relate.htm";
		window.modalwindow = window.dhtmlmodal.open(
			"_CHILDWINDOW_APPR1004", "iframe", url, "결재문서 첨부", 
			"width=700px,height=530px,resize=0,scrolling=1,center=1", "recal"
		);
		/* var d=$(window.modalwindow).find(".drag-contentarea").eq(0);
		$(d).css("height","430px");
		console.log($(window.modalwindow));
		console.log($(window.modalwindow).find("#drag-contentarea"));
		alert("dfsfdsf");
		alert(d);  */
		
		
		//document.getElementById("drag-contentarea").style.height="430px";
	}
	
	function setRelation(ret) {
		if (ret != null) {
			var frm = document.getElementById("apprWebForm");
			var docList = ret;
			
			for(var i=0;i<docList.length;i++){
				var isExist = false;	//중복문서 방지
				var docInfo =  docList[i];
				
				$("#DocAttach").find("input[name=docId]").each(function(){
					if($(this).val()==docInfo.docId) {
						isExist = true;
					}
				});
				
				if(isExist) continue;
				
				var docId = docInfo.docId;
				var subject = docInfo.subject;
				var docType = docInfo.docType;
				
				var hidTxt = "<input type='hidden' name='docId' value='" + docId + "'>"
								+"<input type='hidden' name='docSubject' value='"+subject+"'>"
								+"<input type='hidden' name='docType' value='"+docType+"'>"
								+"<input type='text' name='docDescript' value='' style='width:95%'>";
				
				$('#DocAttach > tbody:last').append('<tr><td>' + subject + '</td><td>' + hidTxt + '</td><td></td></tr>');
				
				// 버튼에 클릭 이벤트 추가
	            $.btnDelete = $(document.createElement("input"));
	            $.btnDelete.attr({
	                name : "btnRemove",
	                type : "button" ,
	                value : "삭제"
	            });
	         	
	            $.btnDelete.click(function(){
	                $(this).parent().parent().remove();
	            });
	            
	            $("#DocAttach tr:last td:last").append($.btnDelete);
			}
				
		}
			
	}
	
	function onDocDelete(doc){
// 		$(doc).remove();
		$(doc).parent().parent().remove();
	}
	
	//관련문서 검색 삭제
	function searchDelete(){
		$("#DocAttach").find("tr").each(function(){
			if($(this).index()>0){
				$(this).remove();
			}
		});
	}
<%

	/*
	if(apprformInfo!=null){
		if(apprformInfo.getPageType().equals("R")){
%>
	//window.resizeTo(1000, 710);
<%	
		}
	}
*/
%>	
	//문서이관 보관 분류ID 검색 (window.showModalDialog Version)
	function findCategoryInfoModal() {
		var winwidth = "300";
		var winheight = "450";
		var url = "/dms/categoryTree.htm?openmode=1&winname=opener&conname=document.submitForm&isadmin=1&cateType=S";
		var opt = "status:no;scroll:no;center:yes;help:no;dialogWidth:" + winwidth + "px;dialogHeight:" + winheight + "px";
		var rValue = window.showModalDialog(url, "", opt);
		setCategoryInfo(rValue);
	}

	//문서이관 보관 분류ID 검색 (dhtmlmodal Version)
	function findCategoryInfo() {
		var url = "/dms/categoryTree.htm?openmode=1&winname=opener&conname=document.submitForm&isadmin=1&cateType=S";
		window.modalwindow = window.dhtmlmodal.open(
			"_CHILDWINDOW_DMS1001", "iframe", url, "<spring:message code='main.Approval' text='전자결재' />", 
			"width=300px,height=450px,resize=0,scrolling=1,center=1", "recal"
		);
	}
	
	function setCategoryInfo(rValue) {
		if (rValue != null) {
			var catId = document.getElementById("apprDoc.dmsCatId");
			var catName = document.getElementById("apprDoc.dmsCategory.catName");
			catId.value = rValue[1];
			if (rValue[2] == "" || rValue[2] == null) catName.value = "[<spring:message code='t.category.top' text='최상위분류' />]";
			else catName.value = rValue[2];
		}
	}
	//전결 체크
	function chkXenFlag(){
		if($("input[name=xenflag]:checked").val() == "T"){
			if(confirm("기안자 전결을 하시겠습니까?")){
			
				//기안자 결재선 셋팅 및 기존 결재자 제거
				arrPeople = new Array();
				setApprPersonInit_tot();
				setApprPersonInit();		//결재자 초기화
				for (var i = 1 ; i < APPR_SIZE ; i++ )
				{
					setApprLineInit(i);
				}
				setApprHelpPersonInit(); //합의자 초기화
				for (var i = 0 ; i < HELP_SIZE ; i++ )
				{
					setApprHelpLineInit(i);
				}
				setApLineEditorCross();
				
				//기안자 정보 설정
				setGianApLineEditor();
				ApLineRotate();
			}
		}else{
			if(confirm("기안자 전결을 취소하시겠습니까?")){
				$("input:checkbox[name='xenflag']").attr("checked", false);
			}else{
				$("input:checkbox[name='xenflag']").attr("checked", true);
			}
		}
	}
	
	//전결 체크(경조금 지급신청서)
	function chkXenFlag2(){
		if($("input[name=xenflag]:checked").val() == "T"){
			if(confirm("기안자 전결을 하시겠습니까?")){
			
				//기안자 결재선 셋팅 및 기존 결재자 제거
				arrPeople = new Array();
				setApprPersonInit_tot();
				setApprPersonInit();		//결재자 초기화
				for (var i = 1 ; i < APPR_SIZE ; i++ )
				{
					setApprLineInit(i);
				}
				setApprHelpPersonInit(); //합의자 초기화
				for (var i = 0 ; i < HELP_SIZE ; i++ )
				{
					setApprHelpLineInit(i);
				}
				
				//결재선 초기화
				var appobj = document.getElementById("appobj");	//ap table
				for ( var i=0; i < appobj.rows.length; i++ ) {
					for ( var j=1; j < appobj.rows[i].cells.length; j++) {
						if(i==0){
							if(j!=appobj.rows[i].cells.length-1){
								appobj.rows[i].cells[j+1].innerText="";
							}
						}
						else{
							appobj.rows[i].cells[j].innerText="";
						}
					}
				}
				var appobj = document.getElementById("helpobj");	//ap table
				for ( var i=0; i < appobj.rows.length; i++ ) {
					for ( var j=1; j < appobj.rows[i].cells.length; j++) {
						if(i==0){
							if(j!=appobj.rows[i].cells.length-1){
								appobj.rows[i].cells[j+1].innerText="";
							}
						}
						else{
							appobj.rows[i].cells[j].innerText="";
						}
					}
				}
				
				setApLineEditorCross2();
				
				//기안자 정보 설정
				setGianApLineEditor();
				ApLineRotate2();
			}
		}else{
			if(confirm("기안자 전결을 취소하시겠습니까?")){
				$("input:checkbox[name='xenflag']").attr("checked", false);
			}else{
				$("input:checkbox[name='xenflag']").attr("checked", true);
			}
		}
	}
	
	//정형문서 전결용 텍스트 삽입
	function setApLineEditorCross2() {
		//alert("START- no active");
	 	try {
			var d = null;
			var ifrm = document.getElementById("tx_canvas_wysiwyg1");
			if (ifrm == null) {
				d = document;
			} else {
				var y = (ifrm.contentWindow || ifrm.contentDocument);
				d = y.document;
			}

			var appobj = document.getElementById("appobj");	//ap table
			//F_APLINE,F_APLINE_H
			var F_TABLE = d.getElementById("F_APLINE").childNodes[1];
			F_TABLE = $("#F_APLINE").find("table").get(0);
			for ( var i=0; i < appobj.rows.length; i++ ) {
				for ( var j=0; j < appobj.rows[i].cells.length; j++) {
					if ( i==0 ) {
						$("#F_APLINE_TITLE_"+j).html("<SPAN id=APPRTITLE" + j+">"+TrimAll(appobj.rows[i].cells[j].innerText)+"</SPAN>");
					} else if ( i==2 ) {
						$("#F_APLINE_NAME_"+j).html(TrimAll(appobj.rows[i].cells[j].innerText));
						// 직급 + 이름으로 되어 있는것을 이름만 표기
					} else {
						//결재사인을위해 정보 임의 ID 부여
						$("#F_APLINE_SIGN_"+j).html(appobj.rows[i].cells[j].innerHTML + "<SPAN id=APPRSIGN" + j+"></SPAN>");
					}
				}
			}
			//합의설정
			var appobj = document.getElementById("helpobj");	//ap table
			//F_APLINE,F_APLINE_H
			var F_TABLE = d.getElementById("F_APLINE_H").childNodes[1];
//	 		if (F_TABLE.nodeType == 3) F_TABLE = d.getElementById("F_APLINE_H").childNodes[2];
			F_TABLE = $(d.getElementById("F_APLINE_H")).find("table").get(0);
			for ( var i=0; i < appobj.rows.length; i++ ) {
				for ( var j=0; j < appobj.rows[i].cells.length; j++) {
					if ( i==0 ) {
						$("#F_APLINE_H_TITLE_"+j).html( "<SPAN id=HELPTITLE" + j+">"+TrimAll(appobj.rows[i].cells[j].innerText)+"</SPAN>");
					} else if ( i==2 ) {
						$("#F_APLINE_H_NAME_"+j).html(TrimAll(appobj.rows[i].cells[j].innerText));
						// 직급 + 이름으로 되어 있는것을 이름만 표기
					} else {
						//결재사인을위해 정보 임의 ID 부여
						$("#F_APLINE_H_SIGN_"+j).html(appobj.rows[i].cells[j].innerHTML + "<SPAN id=HELPSIGN" + j+"></SPAN>");
					}
				}
			}
	  	} catch(e) {
	  		alert( 'err:' + e);
	  	
	  	}
	}
	
	function setApprLineInit(index)
	{
		var titleObj = $("#apprtitle"+index) ;
		var typeObj = $("#apprtype"+index) ;
		var uidObj = $("#appruid"+index) ;

		titleObj.html("");
		typeObj.html("");
		uidObj.html(""); 
	}
	
	function setApprHelpLineInit(index)
	{
		var titleObj = $("#apprtitle_help"+index) ;
		var typeObj = $("#apprtype_help"+index) ;
		var uidObj = $("#appruid_help"+index) ;

		titleObj.html("");
		typeObj.html("");
		uidObj.html(""); 
	}
	
	function setGianApLineEditor() {
		try {
			var d = null;
			var ifrm = document.getElementById("tx_canvas_wysiwyg1");
			if (ifrm == null) {
				d = document;
			} else {
				var y = (ifrm.contentWindow || ifrm.contentDocument);
				d = y.document;
			}
			
			var F_TABLE = d.getElementById("F_APLINE").childNodes[0];
			F_TABLE = $(d.getElementById("F_APLINE")).find("table").get(0);
			//직급
			F_TABLE.rows[0].cells[1].innerHTML = "<span id='APPRTITLE0'><b><%=sDpid%></b></span>";
			//결재사인
			F_TABLE.rows[1].cells[0].innerHTML = "<span id='apprtype0'>기안</span><SPAN id='APPRSIGN0'></SPAN>";
			//이름
			F_TABLE.rows[2].cells[0].innerText = "<%=sName %>";
		}catch(e){
			alert(e);
		}
	}
</script>
<script>
var frm = document.getElementById("apprWebForm");
var formtitle = "<%=Convert.nullCheck(apprformInfo.getSubject())%>" ;
<%if(sFormID.equals("")){%>
	formtitle = "<spring:message code='appr.generalForm' text='일반양식'/>";
<%}%>

var dspFormName = document.getElementById("dspFormName");
dspFormName.innerText = formtitle ;
frm.apprformid.value = "<%=apprformInfo.getApprFormNo() %>" ;
<%if(!cmd.equals("EDIT")){%>
	var dspFormName = document.getElementById("dspFormName");
    dspFormName.innerText = formtitle ;
<%}else{%>
    frm.apprformid.value = "<%=apprreadInfo.getApprFormid()%>"
   	dspFormName.innerText = "<%=sFormName.replace("\r\n","\\n")%>" ;
<%}%>

</script>