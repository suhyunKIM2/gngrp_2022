<%@ page contentType="text/html;charset=utf-8" %>
<%
//request.setCharacterEncoding("UTF-8");
//String sApprType = "",  sDname= "", sUname= "", sNnmae= "", sApprUid= "" ;
String sApprType = "",  sNnmae= "", sApprUid= "" ;

//ArrayList arrPer = apprreadInfo.getArrApprPepole() ;
ArrayList arrTemp = apprreadInfo.getArrApprPepole() ;

int iPerSize = (arrTemp == null ) ? 0 : arrTemp.size() ;

ApprPersonInfo apprpersonInfo = null ;
ArrayList arrPer = new ArrayList(); 
ArrayList arrHelpPer = new ArrayList() ;	//협조 결재자
String isrenew=nek.common.util.Convert.TextNullCheck(request.getParameter("renewedit"));
ArrayList arrList = new ArrayList() ; 
int iTemp = 0 ;
int iTempHelp = 0 ;	//협조
int iSizeHelp = 0;	//협조
boolean helpChk = false;	//협조 결재 테이블 visible
//조회조건의 order by 가 apprno desc
%>
<SCRIPT LANGUAGE="JavaScript">
<!--
<%
if(apprreadInfo.getApprovalType().equals(ApprDocCode.APPR_NUM_5)){
	iPerSize = iPerSize - (apprreadInfo.getApprReqCnt()+1);
}
    for ( int i = 0 ; i < iPerSize ; i++ )
    {
        apprpersonInfo = (ApprPersonInfo)arrTemp.get(i) ;

        sApprType = apprpersonInfo.getType() ;
         if ( sApprType.equals(ApprDocCode.APPR_DOC_CODE_GIAN) )
         {
             continue ; //기안자를 보여줄 필요가 없다.
         }

         //협조 / 일반 결재 분리
         if(sApprType.equals(ApprDocCode.APPR_DOC_CODE_HAN)){
         	iTempHelp++;
         	arrHelpPer.add(apprpersonInfo);
         	helpChk = true;
         }else{
         	iTemp++ ;
         	arrPer.add(apprpersonInfo); 
         }

%>
    var objApprPerson<%= i %> = new Object() ;
    objApprPerson<%= i %>.type = "<%= 0 %>" ;
    objApprPerson<%= i %>.name = "<%= apprpersonInfo.getNName() %>" ;
    objApprPerson<%= i %>.id = "<%= apprpersonInfo.getApprUid() %>" ;
    objApprPerson<%= i %>.position = "<%= apprpersonInfo.getUpName() %>" ;
    objApprPerson<%= i %>.department = "<%= apprpersonInfo.getDpName() %>" ;
    objApprPerson<%= i %>.apprtype = "<%= sApprType %>" ;
    objApprPerson<%= i %>.apprname = "<%= ApprUtil.getApprTypeHan(sApprType) %>" ;
    arrPeople.push(objApprPerson<%= i %>) ;
<%
    }
%>
//-->
</SCRIPT>
<%  
    iPerSize = iTemp ;
	iSizeHelp = iTempHelp;	//협조
    int iFirstTr = 5 ;
    int iNextTr = 8 ;
    int j = 0 ;
%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="table2">
	<tr height=135>
		<td width="250" height="92" valign="top">
            <table border="0" cellspacing="0" width="100%" height="100%" class="Appborder">
                <tr>
                    <td class="Appborder" bgcolor="#EDF2F5" style="BORDER-BOTTOM: 0px;BORDER-right: 0px; padding:2 0 0 4; line-height:10px;height:25px;">
                        <p align="center" >기안부서</p>
                    </td>
                    <td valign="middle" class="Appborder" style="BORDER-BOTTOM: 0px;BORDER-right: 0px; padding:2 2 0 4; line-height:10px;">
                    &nbsp;<%=gianDpName %>
                    </td>
                </tr>
                <tr>
                    <td class="Appborder" bgcolor="#EDF2F5" style="BORDER-BOTTOM: 0px;BORDER-right: 0px; padding:2 0 0 4; line-height:10px;height:25px;">
                        <p align="center" >기 안 일</p>
                    </td>
                    <%  
    String sCreateDate = apprreadInfo.getCreateDate() ;
    if (sCreateDate.equals("")) sCreateDate =  ApprUtil.getDateTime(ApprUtil.getNowDateTime().toString()).substring(0,10) ;
    else sCreateDate = sCreateDate.substring(0,10) ;
%>
                    <td valign="middle" class="Appborder" style="BORDER-BOTTOM: 0px;BORDER-right: 0px; padding:2 2 0 4; line-height:10px;">
                    &nbsp;<%=sCreateDate %>
                    </td>
                </tr>
                <tr>
                    <td width="80" class="Appborder" bgcolor="#EDF2F5" style="BORDER-BOTTOM: 0px;padding:2 2 0 4;height:25px;">
                    <input type="hidden" name="formtitle" value= "<%= apprreadInfo.getFormTitle() %>" ><% //결재양식 명 %>
		            <span id="apprform" style="display:none"><%= apprreadInfo.getFormTitle() %></span>
                        <p align="center">기 안 자</p>
                    </td>
                    <td width="*" valign="middle" class="Appborder" style="BORDER-BOTTOM: 0px;padding:2 2 0 4;">
                       <a href="javascript:ShowUserInfo('<%= sUid %>');"><%= sName %></a>
                    </td>
                </tr>
                <tr>
                    <td class="Appborder" bgcolor="#EDF2F5" style="BORDER-BOTTOM: 0px;BORDER-right: 0px; padding:2 0 0 4; line-height:10px;height:25px;">
                        <p align="center" >문서번호</p>
                    </td>
                    <td valign="middle" class="Appborder" style="BORDER-BOTTOM: 0px;BORDER-right: 0px; padding:2 2 0 4; line-height:10px;">
                    &nbsp;<%=(isrenew.equals("S"))? "" : apprreadInfo.getDocNum() %>
                    </td>
                </tr>
                <input type="hidden" name="securityid" value="1">
                <!-- 
                <tr>
                    <td class="Appborder" bgcolor="#EDF2F5" style="BORDER-BOTTOM: 0px;padding:2 2 0 4;height:25px;">
                        <p align="center">비밀등급</p>
                    </td>
                    <td class="Appborder">
			            <SELECT NAME="securityid" class="SELECT">
			<%   
			    int iSecurityIDSize = (arrSecurityID == null ) ? 0 : arrSecurityID.size() ;
			    if (iSecurityIDSize > 0 )
			    {
			        SecurityItem securityItem = null ;
			        String sOption = "";
			        String sSecurityID = "";
			        for(int k = 0 ; k < iSecurityIDSize ; k++)
			        {
			            securityItem = (SecurityItem)arrSecurityID.get(k);
			            sSecurityID = new Integer(securityItem.securityId).toString() ;
			            sOption = "<option value='"+sSecurityID+"' ";
			            if ( (apprreadInfo.getSecurityID()).equals(sSecurityID)){
			            	sOption += "selected" ;
			            }
						
			            /*
			            if ( !(apprreadInfo.getSecurityID()).equals(sSecurityID)&&k==1){
			            	sOption += "selected" ;
			            }
			            */

			            sOption += " >"+ securityItem.title+" </option>\n";
			
			            out.write(sOption);
			        }
			    }
			%>
			            </SELECT>&nbsp;
			
					 </td>
                </tr>
                 -->
                <tr>
                	<td class="Appborder" bgcolor="#EDF2F5" style="BORDER-BOTTOM: 0px;padding:2 2 0 4;height:25px;">
                        <p align="center">보존년한</p>
                    </td>
                	<td class="Appborder">
			            <select name="preserveitems" class="SELECT">
			<%
			    PreservePeriodItem preservePeriodItem = null ;
			
			    iLast = arrPeriod.size() ;
			    String spreserveId = apprreadInfo.getPreserveItems() ;
			    if(cmd.equals(ApprDocCode.APPR_NEW)) spreserveId = apprformInfo.getPreserveId();
			    if ( (spreserveId == null ) || ( "".equals(spreserveId)) ) spreserveId = "3" ;
			    for (int i = 0 ; i < iLast ; i++)
			    {
			        preservePeriodItem = (PreservePeriodItem) arrPeriod.get(i) ;
			        // 수정시 데이타 값에 의한 선택이 안되어 있다.
			%>
							<option value="<%= preservePeriodItem.preserveId %>" <% if( (spreserveId).equals(new Integer(preservePeriodItem.preserveId).toString()) ) out.write("selected"); %>><%= preservePeriodItem.title %></option>
			<%
			    }
			%>
						</select>
			        </td>
                </tr>
                <!-- 
                <tr>
                	<td class="Appborder" bgcolor="#EDF2F5">결재방식</td>
			        <td class="Appborder">&nbsp;
			            <input type="radio" name="approvaltype" value="<%= ApprDocCode.APPR_NUM_1 %>" onClick="javascript:reqChange();" <%= (apprreadInfo.getApprReqCnt()>0) ? "" : "checked" %>>일반결재
			            <input type="radio" name="approvaltype" value="<%= ApprDocCode.APPR_NUM_5 %>" onClick="javascript:reqChange();" <%= (apprreadInfo.getApprReqCnt()>0) ? "checked" : "" %>>신청결재					
					</td> 
                </tr>
                <tr id="reqLine" style="width:100;display:none">
                	<td class="Appborder" colspan=2 style="text-align:right">
                		<select name="reqLineitems" style=width:150px;" >
							<option value="">---------- 선택 ----------</option>
			            <%
			            ApprReqLineHDInfo appReqlineHDInfo = null;
			            int iCnt = arrReqLine.size() ;
			            for (int i = 0 ; i < iCnt ; i++)
			            {
			            	appReqlineHDInfo = (ApprReqLineHDInfo) arrReqLine.get(i) ;
			            %>
			            	<option value="<%= appReqlineHDInfo.getDPID()%>" <%= (appReqlineHDInfo.getDPID().equals(apprreadInfo.getApprReqDpid()) ? "selected" : "") %>><%= appReqlineHDInfo.getApprLineNm() %></option>
			            <%
			            }
			            %>
			            </select>
                	</td>
                </tr>
                 -->
                 <input type="hidden" name="approvaltype" value="<%= ApprDocCode.APPR_NUM_1 %>">
           </table>
        </td>
        <script>
        function m_over( args ) {
        	args.style.border = "1px solid #e95a05";
        	args.style.cursor = "hand";
        }
        function m_out( args ) {
           	args.style.border = "0px solid #90b9cb";
        	args.style.cursor = "normal";
        }
        function m_click( args ) {
	       	if ( args.tagName == "TABLE" ) {
   	    		if( event.srcElement.tagName == "A" ) {
   	    			return;
   	    		}
   	    		goApprPer();
   	    	}
        }
        </script>
        <td width="*" height="92" valign="top">
            <p>&nbsp;</p>
        </td>
  		<td width="445" height="92" valign="top">
		<table border="0" cellspacing="0" width="100%" title="클릭하시면 결재자를 선택 및 변경할 수 있습니다. " onclick="m_click(this);" onmouseover="m_over(this);" onmouseout="m_out(this);" class="Appborder" style="BORDER-BOTTOM: 0px;padding:2 2 0 4;">
		<colgroup>
		<col width="5%">
		<col width="16%" span="7">
		</colgroup>
			<tr>
        		<td width="*" height="102" rowspan="3" class="Appborder" bgcolor="#EDF2F5">
                    <p align="center">내</p>
                    <p align="center">부</p>
                    <p align="center">결</p>
					<p align="center">재</p>
				</td>
		<td class="Appborder"><%=loginuser.upName %>&nbsp;</td>
<!-- 결재자 정보 시작  -->
<% 
    for( j = 0 ; j < iFirstTr ; j++)
    {
        sApprUid = "";
        //sApprType = "";
        if ( j < iPerSize) {
            apprpersonInfo = (ApprPersonInfo)arrPer.get(j) ;

            sApprType = apprpersonInfo.getType() ;
            sApprUid = apprpersonInfo.getApprUid() ;

        }
		//결재자를 제외한 나머지 결재자 처리
		//결재형태
%>
		<td class="Appborder"><span id="apprup<%=j %>"></span></td>
		<input type="hidden" name="tbapprperuid" value="<%= sApprUid %>" >
        <input type="hidden" name="tbapprpertype" value="<%= sApprType %>">
<%  }  %>
   
	</tr>
    <!-- 결재 사인과 성명 결재 유형 -->
	<tr >
		<td class="Appborder">&nbsp;<span style="HEIGHT:85px;"><br><br><br><a href="javascript:ShowUserInfo('<%=sUid %>');"><%=sName %></a></span></td>
<%
    String sShowUID = "" ;
    for( j = 0 ; j < iFirstTr ; j++)
    {
        //sNnmae  = ""; sApprUid = ""; sShowUID = "" ;
        if ( j < iPerSize) {
            apprpersonInfo = (ApprPersonInfo)arrPer.get(j) ;
            sNnmae = apprpersonInfo.getNName() ;
            sApprUid = apprpersonInfo.getApprUid() ;
            sShowUID = "<a href=\"javascript:ShowUserInfo('"+sApprUid+"');\">"+sNnmae+"</a>" ;
        }
        //결재자(최종결재자 제외)
        
		if( j < (iPerSize-1)){
%>
		<td class="Appborder" id="per<%=j%>">&nbsp;<span id="appruid<%=j %>" style="HEIGHT:85px;"><br><br><br><%= sShowUID %></span></td>
		<!--  최종결재자 -->
<%		}else if(j == (iFirstTr-1)) { %>
		<td class="Appborder" id="per<%=j%>">&nbsp;<span id="appruid<%=j %>" style="HEIGHT:85px"><br><br><br><%= sShowUID %></span></td>
<%		}else{ %>
		<!-- 빈 공란 처리 -->
		<td class="Appborder" id="per<%=j%>">&nbsp;<span id="appruid<%=j %>" style="HEIGHT:85px"></span></td>
<% 		}%>
<%
    }
%>
	</tr>
    <!-- 결재일자 -->
	<tr>
		<td class="Appborder">&nbsp;<FONT  COLOR="#000000"><B><span><%= ApprUtil.getApprTypeHan("G") %></span></B></FONT>&nbsp;</td>
<%    for( j = 0 ; j < iFirstTr ; j++)   { 
		String sFonColor = "" ;
		//결재는 진하게 합의는 파란색에 진하게 색 변경
	    if (sApprType.equals(ApprDocCode.APPR_DOC_CODE_APPR) ) {
	        sFonColor = "#000000" ; //
	    } else {
	        sFonColor = "#0033CC" ; //
	    }
		if ( j < (iPerSize-1) ){%>
		<td class="Appborder">&nbsp;<FONT  COLOR="<%= sFonColor %>"><B><span id="apprtype<%=j %>"><%= ApprUtil.getApprTypeHan(sApprType) %></span></B></FONT>&nbsp;</td>
<%		}else if(j == (iFirstTr) ){%>
		<td class="Appborder">&nbsp;<FONT  COLOR="<%= sFonColor %>"><B><span id="apprtype<%=j %>"><%= ApprUtil.getApprTypeHan(sApprType) %></span></B></FONT>&nbsp;</td>
<% 		}else{ %>
		<td class="Appborder">&nbsp;<FONT  COLOR="<%= sFonColor %>"><B><span id="apprtype<%=j %>">&nbsp;</td>
<%		} %>
<%    } %>
		</tr>
		</table>
		</td>
	</tr>
</table>
<!-- 협조 결재자 정보 시작 -->
<table id="helpobj" width="100%" border="0" cellspacing="0" cellpadding="0" style="display:<%=(helpChk) ? "" : "none" %>;">
	<tr height=3><td></td></tr>
	<tr height=160>
	 	<td width="250" height="92" valign="top">&nbsp;</td>
	 	<td width="*" height="92" valign="top">&nbsp;</td>
        <td width="445" height="92" valign="top">
		<table border="0" cellspacing="0" width="100%" class="Appborder" style="BORDER-BOTTOM: 0px;padding:2 2 0 4;">
			<colgroup span="7">
			<col width="5%">
			<col width="16%" span="6">
			</colgroup>
        	<tr>
        		<td width="*" height="102" rowspan="4" class="Appborder" bgcolor="#EDF2F5">
                    <p align="center">합</p>
                    <p align="center">의</p>
                    <p align="center">부</p>
					<p align="center">서</p>
				</td>
	<% 
	iFirstTr = 6 ;
	ApprPersonInfo apprpersonInfo_help = null;
	for( j = 0 ; j < iFirstTr ; j++)
	{
	    sApprUid = "";
	    String sFonColor = "" ;
	    sApprType ="";
	    String sDpName = "";
	    if ( j < iSizeHelp) {
	    	apprpersonInfo_help = (ApprPersonInfo)arrHelpPer.get(j) ;
	
	        sApprType = apprpersonInfo_help.getType() ;
	        sApprUid = apprpersonInfo_help.getApprUid() ;
	        sDpName = apprpersonInfo_help.getDpName();//결재자 부서
	
	        //결재는 진하게 합의는 파란색에 진하게 색 변경
	        if (sApprType.equals(ApprDocCode.APPR_DOC_CODE_APPR) ) {
	            sFonColor = "#000000" ; //
	        } else {
	            sFonColor = "#0033CC" ; //
	        }
	    }
		//결재자를 제외한 나머지 결재자 처리
		//결재형태
		if ( j < iSizeHelp ){%>
		<td class="Appborder">&nbsp;<FONT  COLOR="<%= sFonColor %>"><B><span id="apprtype_help<%=j %>"><%= sDpName %></span></B></FONT>&nbsp;</td>
	<%		}else{ %>
		<td class="Appborder">&nbsp;<FONT  COLOR="<%= sFonColor %>"><B><span id="apprtype_help<%=j %>">&nbsp;</td>
	<%		} %>
		<input type="hidden" name="tbapprperuid_help" value="<%= sApprUid %>" >
	    <input type="hidden" name="tbapprpertype_help" value="<%= sApprType %>">
	<%  }  %>
	
	</tr>
	<!-- 결재 사인과 성명 결재 유형 -->
	<tr >
	<%
	sShowUID = "" ;
	for( j = 0 ; j < iFirstTr ; j++)
	{
	    sNnmae  = ""; sApprUid = ""; sShowUID = "" ;
	    if ( j < iSizeHelp) {
	    	apprpersonInfo_help = (ApprPersonInfo)arrHelpPer.get(j) ;
	        sNnmae = apprpersonInfo_help.getNName() ;
	        sApprUid = apprpersonInfo_help.getApprUid() ;
	        sShowUID = "<a href=\"javascript:ShowUserInfo('"+sApprUid+"');\">"+sNnmae+"</a>" ;
	    }
	    //결재자(최종결재자 제외)
	    if( j < iSizeHelp){
	%>
		<td class="Appborder" id="per<%=j%>">&nbsp;<span id="appruid_help<%=j %>" style="HEIGHT:85px;"><br><br><br><%= sShowUID %></span></td>
	<%		}else{ %>
		<!-- 빈 공란 처리 -->
		<td class="Appborder" id="per<%=j%>">&nbsp;<span id="appruid_help<%=j %>" style="HEIGHT:85px"></span></td>
	<% 		}%>
	<%
	}
	%>
	</tr>
	<!-- 결재일자 -->
	<tr>
	<%    for( j = 0 ; j < iFirstTr ; j++)   { %>
		<td class="Appborder"><span id="apprup_help<%=j %>"></span></td>
	<%    } %>
		</tr>
		</table>
		</td>
	</tr>
<!-- 협조결재자 끝 -->
</table>
<!-- 결재자 정보 끝 -->
<table><tr><td class="tblspace03"></td></tr></table>
<!--  수신처 -->
<table width="100%" cellspacing="0" height="100%" class="Appborder">
	<tr>
		<td width="15%" class="Appborder" bgcolor="#EDF2F5">수신처</td>
		<!-- 수신처 처리 -->
		<td width="*" class="Appborder" bgcolor="#ffffff" style="text-align:left;text-valign:bottom">
		    <div id="receivehtml" style="height:20px;width:100%;overflow:no;border:0px;" title="클릭하시면 수신처를 지정할 수 있습니다." onclick="goReceive();" onmouseover="m_over(this);" onmouseout="m_out(this);">
<%  
    //수신처 정보 4
    ArrayList arrReceive = apprreadInfo.getReceive() ;
    if ( arrReceive != null )
    {
        int iReceiveSize = arrReceive.size() ;
//Debug.println("in : " + iReceiveSize) ; 
        String sReceiveType = "", sReceiveName = "", sCommonCheck= "", sRceiveText = ""   ;
        String sReceiveDpName = "" , sReceiveUpName = "" , sReceiveID= "" ;
        boolean bCommon = false ;
        ApprReceiveInfo receiveInfo = null ;

        for(int m = 1 ; m < iReceiveSize ; m++) //첫정보는 권한 이다. 그러므로 두번째 부터 읽어라
        {
            receiveInfo = (ApprReceiveInfo)arrReceive.get(m) ;

            sReceiveType = receiveInfo.getReceiveType() ;
            sReceiveName = receiveInfo.getReceiveName() ;
            sReceiveID = receiveInfo.getReceiveID() ;
            sCommonCheck = receiveInfo.getCommonCheck() ;

            sReceiveDpName = receiveInfo.getDpName() ;
            sReceiveUpName = receiveInfo.getUpName() ;

            if (sCommonCheck.equals(ApprDocCode.APPR_SETTING_T)) bCommon = true ;
            else bCommon = false ;

            if (sReceiveType.equals(ApprDocCode.RECEIVE_DEPT)) //부서
            {
                if (bCommon) {
                    sRceiveText = sReceiveName + "[+]" ;
                } else {
                    sRceiveText = sReceiveName + "[-]" ;
                }
            }
            else if (sReceiveType.equals(ApprDocCode.RECEIVE_PERSON)) //사람
            {
                sRceiveText = sReceiveName + "/" + sReceiveDpName ;
            }

%>
                <%= sRceiveText%>
                <input type="hidden" name="receivetype" value="<%= sReceiveType %>">
                <input type="hidden" name="receiveid" value="<%= sReceiveID %>">
                <input type="hidden" name="commoncheck" value="<%= sCommonCheck %>">

<SCRIPT LANGUAGE="JavaScript">
<%//수신처 팦업과 정보 주고 받기위한 자료 %>
<!--
var objreceive = new Object() ;
<% if (sReceiveType.equals(ApprDocCode.RECEIVE_DEPT)) { %>
objreceive.type = "<%= 1 %>" ;
objreceive.name = "<%= sReceiveName %>" ;
objreceive.id = "<%= sReceiveID %>" ;
objreceive.includeSub = "<%= bCommon %>" ;
<% } else if (sReceiveType.equals(ApprDocCode.RECEIVE_PERSON)) { %>
objreceive.type = "<%= 0 %>" ;
objreceive.name = "<%= sReceiveName %>" ;
objreceive.id = "<%= sReceiveID %>" ;
objreceive.position = "<%= sReceiveUpName %>" ;
objreceive.department = "<%= sReceiveDpName %>" ;
<% } %>
apprReceive.push(objreceive) ;
//-->
</SCRIPT>
<%
        }
    }
%>
            </div>
        </td>
	</tr>
</table>

<table><tr><td class="tblspace03"></td></tr>

<!--  참조자 시작  -->
<table width="100%" cellspacing="0" height="100%" class="Appborder">
	<tr>
		<td width="15%" class="Appborder" bgcolor="#EDF2F5">참조자</td>
		<td width="*" class="Appborder" bgcolor="#ffffff" style="text-align:left;text-valign:bottom">
		    <div id="referencehtml" style="height:20px;width:100%;overflow:no;border:0px;" title="클릭하시면 수신처를 지정할 수 있습니다." onclick="goReference();" onmouseover="m_over(this);" onmouseout="m_out(this);">
<%  
    //참조자 정보
    ArrayList arrReference = apprreadInfo.getReference () ;
    if ( arrReference != null )
    {
        int iReferenceSize = arrReference.size() ;
//Debug.println("in : " + iReceiveSize) ; 
        String sReceiveType = "", sReceiveName = "", sCommonCheck= "", sRceiveText = ""   ;
        String sReceiveDpName = "" , sReceiveUpName = "" , sReceiveID= "" ;
        boolean bCommon = false ;
        ApprReferenceInfo referenceInfo = null ;

        for(int m = 1 ; m < iReferenceSize ; m++) //첫정보는 권한 이다. 그러므로 두번째 부터 읽어라
        {
        	referenceInfo = (ApprReferenceInfo)arrReference.get(m) ;

            sReceiveType = referenceInfo.getReferenceType() ;
            sReceiveName = referenceInfo.getReferenceName() ;
            sReceiveID = referenceInfo.getReferenceID() ;
            sCommonCheck = referenceInfo.getCommonCheck() ;

            sReceiveDpName = referenceInfo.getDpName() ;
            sReceiveUpName = referenceInfo.getUpName() ;

            if (sCommonCheck.equals(ApprDocCode.APPR_SETTING_T)) bCommon = true ;
            else bCommon = false ;

            if (sReceiveType.equals(ApprDocCode.RECEIVE_DEPT)) //부서
            {
                if (bCommon) {
                    sRceiveText = sReceiveName + "[+]" ;
                } else {
                    sRceiveText = sReceiveName + "[-]" ;
                }
            }
            else if (sReceiveType.equals(ApprDocCode.RECEIVE_PERSON)) //사람
            {
                sRceiveText = sReceiveName + "/" + sReceiveDpName ;
            }

%>
                <%= sRceiveText%>
                <input type="hidden" name="referencetype" value="<%= sReceiveType %>">
                <input type="hidden" name="referenceid" value="<%= sReceiveID %>">
                <input type="hidden" name="rcommoncheck" value="<%= sCommonCheck %>">

<SCRIPT LANGUAGE="JavaScript">
<%//참조 팦업과 정보 주고 받기위한 자료 %>
<!--
var objreference = new Object() ;
<% if (sReceiveType.equals(ApprDocCode.RECEIVE_DEPT)) { %>
objreference.type = "<%= 1 %>" ;
objreference.name = "<%= sReceiveName %>" ;
objreference.id = "<%= sReceiveID %>" ;
objreference.includeSub = "<%= bCommon %>" ;
<% } else if (sReceiveType.equals(ApprDocCode.RECEIVE_PERSON)) { %>
objreference.type = "<%= 0 %>" ;
objreference.name = "<%= sReceiveName %>" ;
objreference.id = "<%= sReceiveID %>" ;
objreference.position = "<%= sReceiveUpName %>" ;
objreference.department = "<%= sReceiveDpName %>" ;
<% } %>
apprReference.push(objreference) ;
//-->
</SCRIPT>
<%
        }
    }
%>
            </div>
        </td>
	</tr>
</table>
<!-- 결재자 추가 -->
<div id='apprtableadd5' style="display:none"></div>

<%// 마지막 번호 %>
<input type="hidden" name="apprpersoncnt" value="<%= iPerSize %>">
<%//협조 결재자 시작번호 %>
<input type="hidden" name="apprhelpcnt">
<%// 새로 생성된 결재자 테이블의 수 %>
<input type="hidden" name="apprpersontablecnt" value="0">
<table><tr><td class="tblspace03"></td></tr></table>
