<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="nek.common.*" %>
<%@ page import="nek.approval.*" %>

<% request.setCharacterEncoding("UTF-8"); %>
<%@ include file="../common/usersession.jsp"%>
<%!
    //각 경로 패스
    String sImagePath =  ApprDocCode.APPR_IMAGE_PATH  ;
    String sJsScriptPath =  ApprDocCode.APPR_JAVASCRIPT_PATH ;
    String sCssPath =  ApprDocCode.APPR_CSS_PATH ;
%>
<%
    String sUid = loginuser.uid ;

    String sApprID = ApprUtil.nullCheck(request.getParameter("apprid")) ;

    ArrayList arrList = new ArrayList() ;
    Approval ApprObj = null ;
    try
    {
        if (!sApprID.equals(""))
        {
            ApprObj = new Approval() ;
            arrList = ApprObj.ApprovalPersonProcess( sUid, sApprID) ;
        }
// System.out.println(arrList);
    }catch(Exception e){
        Debug.println (e) ;
    } finally {
        ApprObj.freeConnecDB() ;
    }

%>
<!DOCTYPE html>
<html>
<head>
<title></title>
<%@ include file="/WEB-INF/common/include.mata.jsp" %>
<style>
td {font-size:9pt;}
.ActBtn {cursor:hand; height:22px;}

.ActBtn_Left {
	width:23px;
	background-image:url('<%=imagePath %>/btn1_left.jpg');
	background-repeat :no-repeat
}

.ActBtn_Left_On {
	width:23px;
	background-image:url('<%=imagePath %>/btn2_left.jpg');
	background-repeat :no-repeat
}

/* 버튼왼쪽(mouse over시 바뀌는..) */
.ActBtn_Text {
	background-image:url('<%=imagePath %>/btn1_bg.jpg');
	padding-left:3px;
	font-size:9pt;
}
/* 버튼오른쪽-마지막 부분 */
.ActBtn_Right {
	padding:0px;
	width:3px;
	background-image:url('<%=imagePath %>/btn1_right.jpg');
	background-repeat :no-repeat
}

/* body {margin:0px; padding:3px; border:1px solid white; overflow:auto;} */
/* a, td, input, select {font-size:10pt; font-family:돋움,Tahoma; } */
input {cursor:hand; }

a:link { color:black; text-decoration:none;  }
a:hover {text-decoration:underline; color:#316ac5}
a:visited { color:#616161; text-decoration:none;  }


.mail_list_t {border:1px solid #A1B5FE; background-image:url('../common/images/top_bg.jpg'); height:28px; }

.mail_list{border-collapse:collapse; border:1px solid #E8E8E8; border-width:1px 1px 0px 1px;}
.mail_list tr {height:25px; }
.mail_list td { border:1px solid #E8E8E8; border-width:0px 0px 1px 0px; padding:0px; padding-top:2px; }

.col   {background-image:url('../common/images/column_bg.jpg'); color:gray; text-align:center; padding:0px; border:0px;}
.col_p {background-image:url('../common/images/column_bg.jpg'); color:#E8E8E8; padding:0px; border:0px;  }

.space {line-height:3px;}

/* 추가분 */
.PageNo {   text-decoration: none; letter-spacing:3px; padding-bottom:3px; }

.PageNo a{font-weight:bold; font-family:Tahoma; font-size:10pt; border:1px solid #EBF0F8; 
background-color:#EBF0F8; text-decoration:none; color:#528BA0; height:20px; width:20px; padding-left:0px;}
.PageNo a:visited{font-weight:bold; font-family:Tahoma; font-size:10pt; border:1px solid #EBF0F8; 
background-color:#EBF0F8; text-decoration:none; color:#528BA0; height:20px; width:20px; padding-left:0px; }
.PageNo a:hover {font-weight:bold; font-family:Tahoma; font-size:10pt; border:1px solid #90B3D2; font-weight:bold; 
background-color:#c6E2FD; color:#528BA0; text-decoration:none; height:20px; width:20px; padding-left:0px; }

.PageNo span{width:2px; height:15px; color:#528BA0;}
.div-view {width:100%; height:expression(document.body.clientHeight-115); overflow:auto; overflow-x:hidden;}

/* 리스트 문서수 */
.doc_num{text-decoration:underline; font-size:8pt; cursor:hand;}

/* 미리보기 */
.p { width:15px; border:1px solid #A1B5FE; border-collapse:collapse; background-color:#FFFFFF;}
.p td { line-height:15px; border:1px solid #A1B5FE; cursor:hand; }

.p_sel { width:15px; border:2px solid #A1B5FE; border-collapse:collapse; background-color:#D7E4F5;}
.p_sel td {line-height:15px; border:2px solid #A1B5FE; cursor:hand; }

.td1 { border:1px solid #90B9CB;  font-weight:bold; text-align:center; background-color:#EDF2F5; line-height:25px; font-size:9pt;}
.td2 { border:1px solid #90B9CB;  text-align:center; line-height:25px; background-color: white; font-size:9pt;}
</style>

</HEAD>

<body styles="border-right:2px solid #959385; border-top:1px solid #959385;">


<table cellspacing=0 cellpadding=0 border=0 style="width:100%;">
	<colgroup>
		<col width=5>
		<col width=*>
		<col width=5>
		<col width=5>
	</colgroup>

	<tr height=30>
		<td><img src="/common/images/col_bg_left.gif"></td>
		<td style="font-size:9pt;" background="/common/images/col_bg_center.jpg">
		&nbsp;<img align=absmiddle src="../common/images/vwicn011.gif" border=0>
		<B><%=msglang.getString("appr.status.processing.doc") /* 결재문서 진행 상태 */ %></B>
		</td>
		<td background="/common/images/col_bg_center.jpg" align=right style="padding-top:3px;">
		&nbsp;
		</td>
		<td align=right><img src="/common/images/col_bg_right.gif"></td>
	</tr>
</table>
<!-- 
<table width="775" cellspacing="0" cellpadding="0" border="0">
	<tr>
		<td width="30"><img src="<%= sImagePath %>/popup_title.gif"></td>
		<td width="765" height="40" class=title background="<%= sImagePath %>/popup_bg.gif">결재진행</td>
	</tr>
	<tr><td height="7" colSpan="2"></td></tr>
</table>
-->

<!-- <div style="height:185px;width:100%;overflow-y:scroll;border:0px; border:1px solid white;">-->
<table  width="100%" border="0" cellspacing="0" cellpadding="0" style="border-collapse:collapse;table-layout:fixed;">
<colgroup>
<col width=25>
<col width=*>
<col width=85>
<col width=120>
<col width=120>
</colgroup>
<thead>
	<tr>
        <td class="td1">&nbsp;</td>
        <td class="td1" style="padding:0px; text-align:center;"><%=msglang.getString("appr.approver") /* 결재자 */ %></td>
        <td class="td1"><%=msglang.getString("appr.type") /* 결재유형 */ %></td>
        <td class="td1"><%=msglang.getString("appr.date.read") /* 결재읽은일자 */ %></td><!-- 읽은날짜 -->
        <td class="td1"><%=msglang.getString("appr.date") /* 결재일자 */ %></td>
	</tr>
</thead>	
<!-- 기안자 표시 -->
<%
	String  sApprType = "", sApprFlag= "", sXenGal = "" , sBujaeUID =""  ;
	String sXenGalHan = "", sBujaeHan = "", sHanXenBu = "", sApprFlagHan = "" ;
	String txt1 = "", imgArrow = "";
	int iPerSize =  arrList.size() ;
	ApprPersonInfo apprpersonInfo = null ;
	
	/** 기안자는 진행순번이 틀리므로 별도로 처리 **/
    for(int i = 0; i < iPerSize ; i++)
    {
        sXenGalHan = ""; sBujaeHan = ""; sHanXenBu = "" ; txt1 = "";

        apprpersonInfo = (ApprPersonInfo)arrList.get(i) ;
        sApprType  = apprpersonInfo.getType() ;
        
        //기안자가 아니면 진행금지
        if ( !sApprType.equals(ApprDocCode.APPR_DOC_CODE_GIAN) )
           continue ;
        
        sApprFlagHan = ApprDocCode.APPR_DOC_CODE_G_HAN;
        
        if ("기안".equals(sApprFlagHan)) {
    		sApprFlagHan = msglang.getString("appr.gian");
    	}

       	imgArrow = "<img align=absmiddle src='/common/images/icons/down_arrow_b.gif'>";
%>
	<tr>
        <td class="td2" nowrap style="text-align:center; padding:0px;"><%=imgArrow %></td>
        <td class="td2" nowrap align=left bgcolor="" style="text-align:left;">&nbsp;[<%= apprpersonInfo.getDpName() %>] <%= apprpersonInfo.getNName() %> <%=apprpersonInfo.getUpName()%></td>
        <td class="td2" nowrap><B><%= sApprFlagHan %></B></td>
        <td class="td2" style="font-family:arial;" nowrap>&nbsp;<%= apprpersonInfo.getReadDate() %></td>
        <td class="td2" style="font-family:arial;" nowrap>&nbsp;<%= apprpersonInfo.getApprDate() %></td>
	</tr>
<%
    }
%>	
<!-- 기안자 표시 끝 -->	

<!-- 결재자 표시(기안자 제외) -->
<%
	/** 기안자를 제외한 나머지 결재자 진행현황 표시  **/
    for(int i = 0; i < iPerSize ; i++)
    {
        sXenGalHan = ""; sBujaeHan = ""; sHanXenBu = "" ; txt1 = ""; sApprFlag=""; sApprFlagHan = "";

        apprpersonInfo = (ApprPersonInfo)arrList.get(i) ;
        sApprType  = apprpersonInfo.getType() ;					//결재형태
        String apprFinishDate = apprpersonInfo.getApprDate();	//결재 완료일자
        String apprReadDate = apprpersonInfo.getReadDate();		//결재 읽은날짜
        sApprFlag = apprpersonInfo.getFlag();					//결재진행FLAG
        
        
        //기안자이면 더이상 진행 금지.
        if ( sApprType.equals(ApprDocCode.APPR_DOC_CODE_GIAN) )
           continue ;
        
		//현재 결재자의 대결 여부
        sBujaeUID = apprpersonInfo.getBujaeUID() ;
        if( !sBujaeUID.equals(apprpersonInfo.getApprUid()) ) {
            sBujaeHan = ApprDocCode.APPR_DOC_CODE_B_HAN ;
            sBujaeHan = msglang.getString("appr.bujae");
        }
        
        //현재 결재자의 전결 여부
        sXenGal = apprpersonInfo.getXenGal() ;
        if ( sXenGal.equals(ApprDocCode.APPR_DOC_XEN_APPR) ){
        	sApprFlagHan = ApprDocCode.APPR_DOC_CODE_X_HAN ;
        	sApprFlagHan = msglang.getString("appr.xen");
			if(!sBujaeHan.equals("")){	//전결이면서 대결일 경우
				sApprFlagHan = sBujaeHan + " " + sApprFlagHan;
        	}
        }else{
        	sApprFlagHan = ApprUtil.getApprFlagHan(sApprFlag) ;
        	
        	if ("완료".equals(sApprFlagHan)) {
        		sApprFlagHan = msglang.getString("appr.finish");
        	} else if ("반려".equals(sApprFlagHan)) {
        		sApprFlagHan = msglang.getString("appr.return");
        	} else if ("진행".equals(sApprFlagHan)) {
        		sApprFlagHan = msglang.getString("appr.ing");
        	} else if ("진행중".equals(sApprFlagHan)) {
        		sApprFlagHan = msglang.getString("appr.ingproc");
        	} else if ("결재".equals(sApprFlagHan)) {
        		sApprFlagHan = msglang.getString("appr.approval");
        	}
        	
        	
			if(!sBujaeHan.equals("")){	//일반 결재에 대결일 경우
				sApprFlagHan = sBujaeHan + " " + sApprFlagHan;
        	}
        }
        
        //합의이면 결재 뒤에 합의 표시
        if ( ApprUtil.getApprTypeHan(sApprType) == "합의" ) {
    		txt1 = "(" + msglang.getString("appr.agreed") + ")";
    	}

        //진행표시 화살표
        if( sApprFlag.equals(ApprDocCode.APPR_DOC_CODE_HANDLE_DAEGI) ) {	// 결재 진행중
        	sApprFlagHan = "<font color=red>"
        				 + msglang.getString("t.reviewing") /* 검토중 */
        				 + "</font>";
        	imgArrow = "<img align=absmiddle src='/common/images/red_arrow.gif'>";
        	out.println( "<tr style='background-color:#A1B5FE;'>");
        } else if( sApprFlag.equals("C") ) {		//다음 결재자 대기
        	imgArrow = "<img align=absmiddle src='/common/images/icons/down_arrow_b.gif'>";
        	sApprFlagHan = msglang.getString("t.wait"); // 대기
        	out.println( "<tr>" );
        } else {	//결재 완료 / 기안
        	imgArrow = "<img align=absmiddle src='/common/images/icons/down_arrow_b.gif'>";
        	out.println( "<tr>" );
        }
        
//Debug.println(apprpersonInfo.getReadDate()) ; 
%>
        <td class="td2" nowrap style="text-align:center; padding:0px;"><%=imgArrow %></td>
        <td class="td2" nowrap align=left bgcolor="" style="text-align:left;">&nbsp;[<%= apprpersonInfo.getDpName() %>] <%= apprpersonInfo.getNName() %> <%=apprpersonInfo.getUpName()%></td>
        <td class="td2" nowrap><B><%= sApprFlagHan %></B><%=txt1%></td>
        <td class="td2" style="font-family:arial;" nowrap>&nbsp;<%= apprReadDate %></td>
        <td class="td2" style="font-family:arial;" nowrap>&nbsp;<%= apprFinishDate %></td>
	</tr>
<%
    }
%>
<!-- 결재자 표시(기안자 제외) 끝 -->
</table>

<!---수행버튼 --->
<!-- <table width="100%" cellspacing="0" cellpadding="0" border="0" style="position:absolute; top:expression(document.body.clientHeight-27);"> -->
<!-- 	<tr height="25" bgcolor="#E7E7E7" align="center"> -->
<!-- 		<td style="padding:0px; "> -->
<%--           <a href="javascript:close();"><img src="<%= sImagePath %>/btn_close.gif" border="0" align="absmiddle" ></a> --%>
<!--         </td> -->
<!-- 	</tr> -->
<!-- </table> -->
<!-- 보기 수행버튼 끝 -->

</BODY>
</HTML>
