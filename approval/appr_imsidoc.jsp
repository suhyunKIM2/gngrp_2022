<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>

<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="nek.approval.*" %>
<%@ page import="java.text.*" %>

<% request.setCharacterEncoding("UTF-8"); %>
<%@ include file="../common/usersession.jsp"%>
<%!
    String sImagePath =  ApprDocCode.APPR_IMAGE_PATH ;
    String sJsScriptPath =  ApprDocCode.APPR_JAVASCRIPT_PATH ;
    String sCssPath =  ApprDocCode.APPR_CSS_PATH ;
    private static SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
%>
<%
	//OS 버전 확인
	String userAgent = request.getHeader("User-Agent");
	boolean selEditor = false;
	if (userAgent == null || 
		userAgent.indexOf("Windows 95") > 0 ||
		userAgent.indexOf("Windows 98") > 0)
	{
		selEditor = true;
	}
	
    //각 경로 패스
    String sUid = loginuser.uid;
    
     // 보존기한을 가져 온다.
    int iLast = 0 ;

    // 기안자의 정보를 가져온다.
    String sName = loginuser.nName;//성명
    String sDpname = loginuser.dpName;//부서명
    String sDpid = loginuser.dpId;//직책코드
    String sUName = "" ;
    String gianDpName = "";

    String sOldApprId = "" ;
    String sOldFileNM = "" ;
	String sFormName="";
    //현페이지의 성격을 나타낸다. ( 신규, 수정, 임시저장, 삭제)
	String cmd = ApprUtil.setnullvalue(request.getParameter("cmd"),  ApprDocCode.APPR_NEW );

    String sReturnUrl = "./appr_imsilist.jsp" ;
    if(!cmd.equals("EDIT")){
    	sReturnUrl= "./appr_apprgian.jsp" ; 
    }
    String sReceiveMenuId = ApprUtil.nullCheck(request.getParameter("menu")) ;
    if (sReceiveMenuId.equals(ApprMenuId.ID_130_NUM)) sReturnUrl = "./appr_finlist.jsp" ; 
//Debug.println(sReceiveMenuId+"/"+ApprMenuId.ID_130_NUM+"/"+sReturnUrl) ; 
    String sMenuId = ApprMenuId.ID_110_NUM ; 
    int iMenuId = ApprMenuId.ID_110_NUM_INT ;

    String sPop = ApprUtil.nullCheck(request.getParameter("pop")); //popup창 여부

    //임시저장후 수정 data를 가져온다.
    // 임시로 결재문서번호만 한개 가져옴(DB와 연동부분 처리해라.
    String sApprId = ApprUtil.nullCheck(request.getParameter("apprid")) ;



    ArrayList arrForm = new ArrayList() ;
    String sChkReceive = "" ; 
    ApprovalDocReadInfo apprreadInfo = new ApprovalDocReadInfo() ; //info
    ApprovalDocRead apprObj = null ;
    
	//폼양식 로드
    String sFormID = ApprUtil.nullCheck(request.getParameter("formid")) ;
    ApprForm formObj = new ApprForm() ;
    ApprFormInfo apprformInfo = null  ;
    try
    {            
        apprformInfo = formObj.ApprFormSel(sFormID) ;

    } finally {
        formObj.freeConnecDB() ;
    }
    
    //신청결재
    //ApprReqLineHDInfo appReqlineHDInfo = new ApprReqLineHDInfo() ;
	ApprReqLine lineObj = null ;
	ArrayList arrReqLine = new ArrayList();
    try
    {
    	//신청결재
    	lineObj = new ApprReqLine() ;
    	arrReqLine = lineObj.ApprReqLineHDList(); //hd의 정보를 가져와라
        //arrList = lineObj.ApprReqLineDTListSelect(sDpid, sLineId) ;
        
        apprObj = new ApprovalDocRead(loginuser, sApprId, iMenuId,  application.getInitParameter("CONF.HOME_PATH")) ;
        
        // 양식폼
        ApprForm apprformobj = new ApprForm(apprObj.getDBConn()) ;
        arrForm = apprformobj.ApprFormTitleSel() ;
//Debug.println(iMenuId); 

		//상위 사업장 + 표시
		gianDpName = apprObj.getTopDepatment(loginuser.uid);

		if (cmd.equals(ApprDocCode.APPR_EDIT) )
        {
%>
<%@ include file="./appr_authory.jsp"%>
<%
            //임시저장된 문서를 불러와라.
            apprreadInfo = apprObj.ApprovalSelect() ;

			try
			{            
			    apprformInfo = formObj.ApprFormSel(apprreadInfo.getApprFormid()) ;
			
			} finally {
			    formObj.freeConnecDB() ;
			}
        } 
        else //기본결재라인의 값을 불러서 결재자에 뿌려라.
        {
        	if(sFormID.equals("")){
        		apprreadInfo = apprObj.ApprovalDefaultLinePersonSelect() ;
        	}else{
        		//만호요청 2009-08-26 기본결재로만 사용
        		apprreadInfo = apprObj.ApprovalDefaultLinePersonSelect() ;
       			//apprreadInfo = apprObj.ApprovalFormLinePersonSelect(sFormID);
         	}
        }

        apprformobj = null ;
       
    } finally {        
    	if(apprObj != null) apprObj = null;
        if(lineObj !=null) lineObj.freeConnecDB() ;	//신청결재
    }
//Debug.println("444444444444") ; 
//결재자 정보가 없다면 정당한 결재자가 아닌사람으로 인정한다.
    if (apprreadInfo.getApprreadright())
    {
        out.close() ;
    }

//------------------------------------------------------------------------------------------------------------------
    //최종결재난 문서에서 새로 기안문작성한다. 이때 문서번호와 첨부파일을 보여주지 마라.
    String sReNewEdit = ApprUtil.nullCheck(request.getParameter("renewedit")) ;
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
    sFileSendUrl += "approval/appr_imsicontrol.jsp";
    
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
    String sReceiveParam = "caption="+java.net.URLEncoder.encode("NEK 주소록", "UTF-8")+"&title="+java.net.URLEncoder.encode("수신인을 선택하세요", "UTF-8") ; 
//Form Name
	sFormName=apprreadInfo.getFormTitle();
%>

<%@page import="nek.common.util.HtmlEncoder"%>
<%@page import="nek.common.util.Convert"%>
<HTML>
<HEAD>
<TITLE>결재문서 작성</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<!-- css -->
<link rel=STYLESHEET type="text/css" href="<%= sCssPath %>/apprread.css">
<link rel="STYLESHEET" type="text/css" href="<%= imgCssPath %>">
<!-- script -->
<script src="<%= sJsScriptPath %>/common.js"></script>
<script src="<%= sJsScriptPath %>/xmlhttp.vbs" type="text/vbscript"></script>
<script src="./appr_imsi.js"></script>
<!-- <script src="./appr_table.js"></script> -->
<SCRIPT LANGUAGE="JavaScript">
<!--

var MOVE_URL_IMSI = "<%= ApprMenuId.ID_120_URL %>" ;
var MOVE_NUM_IMSI = "<%= ApprMenuId.ID_120_NUM %>" ;
var MOVE_URL_APPR = "<%= ApprMenuId.ID_130_URL %>" ;
var MOVE_NUM_APPR = "<%= ApprMenuId.ID_130_NUM %>" ;

var RECEIVE_USER = "<%= ApprDocCode.RECEIVE_PERSON %>" ;
var RECEIVE_DEPT = "<%= ApprDocCode.RECEIVE_DEPT %>" ;
var VAL_T = "<%= ApprDocCode.APPR_SETTING_T %>" ;
var VAL_F = "<%= ApprDocCode.APPR_SETTING_F %>" ;

var TYPE_APPR = "<%= ApprDocCode.APPR_DOC_CODE_APPR %>" ;
var TYPE_HAN = "<%= ApprDocCode.APPR_DOC_CODE_HAN %>" ;
<% if (cmd.equals(ApprDocCode.APPR_EDIT) ){ %>
var FORMID = "<%=apprreadInfo.getApprFormid() %>";
<%}else{%>
var FORMID = "<%=sFormID%>";
<%}%>

var RECEIVE_URL_PARAM = "<%= sReceiveParam %>" ;

//신청결재 부서 선택
function reqChange(){
	if(document.all.approvaltype[1].checked){
		document.getElementById("reqLine").style.display = "";
	}else{
	
		document.getElementById("reqLine").style.display = 'none';
	}
}

function setReqLine(){
	<%if(apprreadInfo.getApprReqCnt()>0){ %>
		document.getElementById("reqLine").style.display = "";
	<%} %>
}

function winClose(){
	if(confirm("현재 문서를 닫으시겠습니까?\n\n문서 편집중에 닫는 경우 저장이 안됩니다.")){
		window.close();
		return;
	}
}


function getForm(){
	var formtitle = "<%= ApprUtil.nullCheck(apprformInfo.getSubject()) %>" ;
	<%if(sFormID.equals("")){%>
		formtitle = "일 반 양 식";
	<%}%>

    document.all.apprform.innerHTML = formtitle ;    
    document.mainForm.apprformid.value = "<%=apprformInfo.getFormID()%>" ;
    <% 
    if(!cmd.equals("EDIT")){
    %>
	    document.all.dspFormName.innerText = formtitle ;
    <%}else{%>
	    document.mainForm.apprformid.value = "<%=apprreadInfo.getApprFormid()%>"
	    document.all.apprform.innerHTML = "<%=sFormName%>" ;
    <%}%>
}

function goPrintView(){
		var url = "./appr_printview.jsp";
		OpenWindow( url, "", "755" , "610" );
	}

//-->
</SCRIPT>
<!-- 태그프리에디터 로딩 이후 함수 수행 -->
<script language="JScript" FOR="twe" EVENT="OnControlInit()">
	var formtitle = "<%= ApprUtil.nullCheck(apprformInfo.getSubject()) %>" ;
	<%if(sFormID.equals("")){%>
		formtitle = "일 반 양 식";
	<%}%>

    var sBody = document.all.imsibody.innerText ;
    document.all.imsibody.innerHTML = sBody; 
    document.all.twe.BodyValue = document.all.imsibody.innerHTML ;
    
    <%
    if (cmd.equals(ApprDocCode.APPR_EDIT) || (!sReNewEdit.equals(""))) {//수정이면 본문에 값 넣기
        out.write("setBody();") ;
    }
	%>
  
    document.all.apprform.innerHTML = formtitle ;    
    document.mainForm.apprformid.value = "<%=apprformInfo.getFormID()%>" ;
    <% 
    if(!cmd.equals("EDIT")){
    %>
	    document.all.dspFormName.innerText = formtitle ;
    <%}else{%>
	    document.mainForm.apprformid.value = "<%=apprreadInfo.getApprFormid()%>"
	    document.all.apprform.innerHTML = "<%=sFormName%>" ;
    <%}%>
</script>

</HEAD>

<body class="body" onLoad="getForm();">

<form name="mainForm" method="get" action="./appr_imsicontrol.jsp" ENCTYPE="multipart/form-data"  onsubmit="return false;">

<div id="imsibody" style="display:none;"><%= nek.common.util.HtmlEncoder.encode(ApprUtil.nullCheck( apprformInfo.getContend() )) %></div>
<input type="hidden" name="editbody" >
<input type="hidden" name="apprid" value="<%= sApprId %>">
<input type="hidden" name="apprpepole" >
<input type="hidden" name="menu" value="<%= sReceiveMenuId %>">
<input type="hidden" name="cmd" value="<%= cmd %>"> <% //신규작성(new), 수정(edit), 삭제(del)  %>
<input type="hidden" name="calltype" ><% //임시저장, 결재 상신, 결재양식 호출  %>
<input type="hidden" name="formtitle" value="<%= apprreadInfo.getFormTitle() %>" ><% //결재양식 명 %>
<input type="hidden" name="apprformid" value="<%=apprreadInfo.getApprFormid() %>">

<!-- 소유권이전 -->
<input type="hidden" name="receiveownid" >
<input type="hidden" name="ownid" value="<%= sUid %>">

<% //최종결재 완료후 재기안을 했을때 값을 가지고 있자.  %>
<input type="hidden" name="oldapprid" value="<%= sOldApprId %>" >

<!-- 타이틀 시작 -->
<table width="100%" border="0" cellspacing="0" cellpadding="0" height="34" id=btntbl>
	<tr> 
		<td height="27"> 
			<table width="100%" border="0" cellspacing="0" cellpadding="0" height="27">
				<tr> 
					<td width="35"><img src="<%=imagePath %>/sub_img/sub_title_approval.jpg" width="27" height="27"></td>
					<td class="SubTitle">전자결재 양식</td>
					<td valign="bottom" width="*" align="right"> 
						<table border="0" cellspacing="0" cellpadding="0" height="17">
							<tr> 
								<td valign="top" class="SubLocation">
<table width="100%" border="0" cellspacing="0" cellpadding="0" style="position:relative;top:1px">
				<tr> 
					<td width="*">&nbsp;</td>
					<td width="83"> 
						<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:OnClickSend('<%= ApprDocCode.APPR_APPR %>', 'AP');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma01','','<%=imagePath %>/btn2_left.jpg',1)">
							<tr>
								<td width="23"><img id="btnIma01" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
								<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;결재요청</span></td>
								<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
							</tr>
						</table>
					</td>
					<td width="83"> 
						<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:OnClickSend('<%= ApprDocCode.APPR_IMSI %>', 'IM');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma02','','<%=imagePath %>/btn2_left.jpg',1)">
							<tr>
								<td width="23"><img id="btnIma02" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
								<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;임시저장</span></td>
								<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
							</tr>
						</table>
					</td>
					<%if (cmd.equals(ApprDocCode.APPR_EDIT) ) { //신규작성일 경우에는 삭제 버튼을 보이지 말자.%>
					<td width="60"> 
						<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:OnDelete('<%= sApprId %>', '<%= ApprDocCode.APPR_DELETE %>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma03','','<%=imagePath %>/btn2_left.jpg',1)">
							<tr>
								<td width="23"><img id="btnIma03" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
								<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;삭제</span></td>
								<td width="3">	<img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
							</tr>
						</table>
					</td>
					<%} %>
					<!--
					<td width="82"> 
						<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:goPrintView();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma07','','<%=imagePath %>/btn2_left.jpg',1)">
							<tr>
								<td width="23"><img id="btnIma07" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
								<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;미리보기</span></td>
								<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
							</tr>
						</table>
					</td>
					-->
					<td width="98"> 
						<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:goApprPer();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma04','','<%=imagePath %>/btn2_left.jpg',1)">
							<tr>
								<td width="23"><img id="btnIma04" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
								<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;결재자 지정</span></td>
								<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
							</tr>
						</table>
					</td>
					<td width="98"> 
						<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:goReceive();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma05','','<%=imagePath %>/btn2_left.jpg',1)">
							<tr>
								<td width="23"><img id="btnIma05" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
								<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;수신처 지정</span></td>
								<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
							</tr>
						</table>
					</td>
					<%if (iMenuId == ApprMenuId.ID_120_NUM_INT ) { //소유권 이전 %>
					<td width="83"> 
						<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:getReceiveOwnID();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma06','','<%=imagePath %>/btn2_left.jpg',1)">
							<tr>
								<td width="23"><img id="btnIma06" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
								<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;인수인계</span></td>
								<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
							</tr>
						</table>
					</td>
					<%} %>
					<%if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_3)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_3))){%>
					<!-- 업무일보 -->
					<%} %>
					<td width="60"> 
						<table border="0" cellspacing="0" cellpadding="0" class="ActBtn" onclick="javascript:winClose();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('btnIma08','','<%=imagePath %>/btn2_left.jpg',1)">
							<tr>
								<td width="23"><img id="btnIma08" src="<%=imagePath %>/btn1_left.jpg" width="23" height="22"></td>
								<td background="<%=imagePath %>/btn1_bg.jpg"><span class="btntext">&nbsp;닫기</span></td>
								<td width="3"><img src="<%=imagePath %>/btn1_right.jpg" width="3" height="22"></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
								</td>
								<td align="right" width="15"></td>
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

<table><tr><td class="tblspace03"></td></tr>

<!---수행버튼 --->
<table width="100%" cellspacing="0" cellpadding="0" border="0" id=btntbl>
	<tr>
		<td align="right"> 
			
		</td>
	</tr>
</table>
<!-- 수행버튼 끝 -->

<table><tr><td class="tblspace09"></td></tr></table>

<div style="width:100%;height:expression(document.body.clientHeight-88);overflow:auto;">
<!--  전자결재 양식명 -->
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="table2">
	<tr>
		<td align=center>
			<FONT face=돋움 style="font-size:28pt;"><STRONG><U><span id="dspFormName"><%= sFormName %></span></U></STRONG></FONT>
		</td>
	</tr>
</table>
<span style="width:100%; text-align:right; height:20px; ">
<span onclick="getFavoriteApLine();" style="padding:2px; padding-top:5px; borders:1px solid #E8E8E8; 
font-size:9pt; color:#666666; z-index:10; cursor:hand;" title="저장된 결재선을 불러옵니다.">
<img src="/common/images/icons/icon_modify.jpg" align=absmiddle> <B>자주 사용하는 결재선</B></span>
</span>
<!-- 결재자 정보 시작 -->
<%@ include file="./appr_imsidoc_in.jsp"%>

<!-- 결재자 정보 끝 -->

<table width="100%" cellspacing="0" cellpadding="0" border="0" class="table1">
	<tr>
		<td width="15%" class="td_ce1" NOWRAP>제 목<span class="readme"><b>*</b></span></td>
		<td width="*" class="td_le2" NOWRAP>
            <input type="text" name="subject" style="width:100%;" value="<%= apprreadInfo.getSubject() %>" maxlength="255">
        </td>
	</tr>
</table>
<table><tr><td class="tblspace05"></td></tr></table>

<ACRONYM id="dspbody" style="display:none"><%= HtmlEncoder.encode(apprreadInfo.getBody()) %></ACRONYM>
<!-- 정형결재 양식폼  -->
<%if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_1)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_1))){%>
	<%@ include file="./appr_regularform.jsp"%>
<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_2)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_2))){%>
	<%@ include file="./appr_regularbusi.jsp"%>
<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_3)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_3))){%>
	<%@ include file="./appr_regularreport.jsp"%>
<%}else if(sFormID.equals(ApprDocCode.APPR_FIX_NUM_4)||(apprreadInfo.getApprFormid().equals(ApprDocCode.APPR_FIX_NUM_4))){%>
	<%@ include file="./appr_regularchit.jsp"%>
<%}else{ %>
<!-- 태그프리 삽입 -->
<script language="jscript" src="../common/scripts/tweditor.js"></script>
<%} %>
<table><tr><td class="tblspace09"></td></tr></table>

<table width="100%" cellspacing="0" cellpadding="0" border="0" class="table1">
	<tr>
		<td width="15%" class="td_ce1" NOWRAP>관련문서</td>
		<td width="*" class="td_le2" NOWRAP>
            <input type="text" name="relateText" style="width:500px;" value="<%= ApprUtil.nullCheck(apprreadInfo.getRelateText()) %>" maxlength="255" readonly>
            <input type="hidden" name="relateValue" value="<%= ApprUtil.nullCheck(apprreadInfo.getRelateValue()) %>">
            <input type="button" value="검색" onclick="searchRelation();">&nbsp;
            <input type="button" value="삭제" onclick="searchDelete()">
        </td>
	</tr>
</table>

<table><tr><td class="tblspace09"></td></tr></table>

<% 
        String attachURL = "../common/attachup_control.jsp?"
			+ "attachfiles=" + java.net.URLEncoder.encode(apprreadInfo.getFileName(),"utf-8")
			+ "&actionurl=" + java.net.URLEncoder.encode(sFileSendUrl,"utf-8")
			+ "&maxfilecount=" + "-1"
			+ "&maxfilesize=" + Long.toString(uservariable.uploadSize) ;
%>
<jsp:include page="<%=attachURL%>" flush="true" />
</div>

</form>
<form name="subForm" action="./appr_imsicontrol.jsp" method="post" target="hidd" ENCTYPE="multipart/form-data" >
    <input type="hidden" name="calltype">
    <input type="hidden" name="apprformid">
</form>

</BODY>
</HTML>

<script>
fld_over_handle();

//자주 사용하는 결재선 선택
function getFavoriteApLine() {
//	alert( event.srcElement.offsetLeft );
	winx = window.event.x-265;
	winy = window.event.y-40;
	
	oPopup = window.createPopup();
	var oPopupBody = oPopup.document.body;
	oPopupBody.innerHTML = "<div style='width:100%; height:100%; border:3px solid #A1B5FE;'></div>" ;

	wid = 250;
	hei = 105;
	//oPopup.show(winx, winy, wid, hei , document.body);


	var sUrl = "./appr_line_select.jsp?no="  ;
    var returnval = OpenModal( sUrl , null , 510 , 400 ) ;

    if ((returnval != null) && (returnval != "") )
        goApprPersonLine(returnval) ;

}

//자주 사용하는 결재선 셋팅
function goApprPersonLine(sTemp)
{
    var sArr ;
    var sList = sTemp.split("<%= ApprDocCode.APPR_GUBUN %>");
    var objAdd = new Array() ;

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

        objAdd.push(objAddress) ;
    }
	arrPeople = objAdd;
	setApprPersonLine(objAdd);
}
	//관련문서 검색
	function searchRelation(){
		var ret = window.showModalDialog("./appr_relate_search_m.jsp", document,
			"dialogHeight: 400px; dialogWidth: 400px; edge: Raised; center: Yes; help: No; resizable: No; status: No; scroll: no;");
			
		if (ret == undefined) ret = window.returnValue;
		if (ret != null) {
			var frm = document.mainForm;
			tmpStr = ret.split("／");
			var reText = "";
			var url = tmpStr[1] +":" + tmpStr[0];
			reText = "[결재문서] " + tmpStr[1];
			frm.relateValue.value = url;
			frm.relateText.value = reText;
		}

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
	//관련문서 검색 삭제
	function searchDelete(){
		var frm = document.mainForm;
		frm.relateValue.value = "";
		frm.relateText.value = "";
	}

</script>