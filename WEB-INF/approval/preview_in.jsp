<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
//결재자 정보를 보여주자
// 외부 변수  sGianUID, sGianGa  include시키는 쪽에 두개의 변수가 선언되어 있어야 한다.

//ArrayList arrPer = apprreadInfo.getArrApprPepole() ;
ArrayList arrTemp = apprreadInfo.getArrApprPepole() ;
int iPerSize = (arrTemp == null ) ? 0 : arrTemp.size() ;

String  sApprNo= "", sApprBujaeUID = "", sUpName = "" ; //sApprType_pop = "",//결재시 팦업창에 결재 형태를 넘기기 위한 변수
String sType = "", sImage = "", sDpname = "", sUpname = "", sApprUid = ""  ;
String sNname = "", sApprDate = "", sNote = "", sFlag = "", sFlagHan = "";
String sBujaeHan = "", sXengal = "",  sInApprId  = "" , sOuid = ""  ;
String sShowNote = "" , sShowUser = "" ;
String sNowApprNo = "" ; 

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
        continue ;
    }

	if(sChkHelp&&z!=iPerSize-2){	//협조 결재자 선택하기 위해 결재자 정보 셋팅 / 첫번째 결재자 패스
		
%>
<SCRIPT LANGUAGE="JavaScript">
<!--
	var objApprPerson<%= z %> = new Object() ;
	objApprPerson<%= z %>.type = "<%= 0 %>" ;
	objApprPerson<%= z %>.name = "<%= apprpersonInfo.getNName() %>" ;
	objApprPerson<%= z %>.id = "<%= apprpersonInfo.getApprUid() %>" ;
	objApprPerson<%= z %>.position = "<%= apprpersonInfo.getUpName() %>" ;
	objApprPerson<%= z %>.department = "<%= apprpersonInfo.getDpName() %>" ;
	objApprPerson<%= z %>.apprtype = "<%= sType %>" ;
	objApprPerson<%= z %>.apprname = "<%= ApprUtil.getApprTypeHan(sType) %>" ;
	arrPeople.push(objApprPerson<%= z %>) ;
//-->
</SCRIPT>
<%
	}
    
	//재기안 / 업무연락  버튼 생성시
	if(sFlag.equals(ApprDocCode.APPR_DOC_CODE_HANDLE_RETURN)){	//반려
		returnChk = true;
	}else if(sFlag.equals(ApprDocCode.APPR_DOC_CODE_HANDLE_GIGAC)){	//기각
		rejectChk = true;
	}
	
    //현 결재자의 결재 순번을 찿아라. (대리자로 설정되어서 2곳이상에 나타날 수 있슴, 병렬이나 동시결재도 마찬가지)    
    if ( (sUid.equals(sApprUid)) && 
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
boolean busiChk = false;
//현재결재자인지 확인을 함.
	nek.approval.ApprAuthority au = new nek.approval.ApprAuthority();
	nek.common.dbpool.DBHandler db = new nek.common.dbpool.DBHandler();
	java.sql.Connection con = null;
	boolean isAppUser =false;
	try{
		con = db.getDbConnection();
		isAppUser = au.isApprovalPerson(con,sApprId,sUid);
		
		//보기 사용자가 수신처 개인일경우
		busiChk = au.isApprovalReceive(con,sApprId,sUid);
	}finally{ if( db != null ) db.freeDbConnection(); }
//------------------------------------------------------------------------------------------------------------------------
//수행버튼 보여주기
%>

<table><tr><td class="tblspace09"></td></tr></table>
<br>
<!--  전자결재 양식명 -->
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="table2">
	<tr>
		<td align=center>
			<FONT face=굴림  style="font-size:28pt;"><STRONG><U><%= apprreadInfo.getFormTitle() %></U></STRONG></FONT>
		</td>
	</tr>
</table>
<!-- 수행버튼 끝 -->
<br>
<%
iSize = iTemp ; 
iSizeHelp = iTempHelp ; 

int iTDfirst = 6 ; 
int iTD = 8 ;
int j = 0 ;
int ifor = 0 ;
iTemp = iSize - iTDfirst   ; 
int iLoop = (int)(Math.ceil((double)iTemp/(double)iTD)) ;
iLoop = iLoop + 1 ; //총 loop 건수

%>
<table class="tblspace03"><tr><td ></td></tr></table>
<%

for (int k = 0 ; k < iLoop ; k++ )
{

//------------------------------------------------------------------------------------------------------------------------
//첯번째 결재자 줄 보여주기    
if ( k == 0 )
{
    j = 0 ; //시작 부분
    ifor = j + iTDfirst ; //for 문 도는 갯수

//------------------------------------------------------------------------------------------------------------------------
//결재형식, 보존년한 설정
%>
<table class="tblspace03"><tr><td></td></tr></table>
<table width="100%" border="0"  cellspacing="0" cellpadding="0" class="table2">

<% 
/*
	if (apprreadInfo.getApprovalType().equals(ApprDocCode.APPR_NUM_1)||apprreadInfo.getApprovalType().equals(ApprDocCode.APPR_NUM_5)) { out.write("순차결재") ; 
	} else if (apprreadInfo.getApprovalType().equals(ApprDocCode.APPR_NUM_2)) { out.write("동시결재") ;  
	} else if (apprreadInfo.getApprovalType().equals(ApprDocCode.APPR_NUM_3)) {  out.write("병렬결재") ; 
	} else if (apprreadInfo.getApprovalType().equals(ApprDocCode.APPR_NUM_4)) {  out.write("병렬+순차") ;  } 
*/
//------------------------------------------------------------------------------------------------------------------------
//기안자, 문서번호 설정
    String sCreateDate = "";
	//if(apprreadInfo != null) new java.text.SimpleDateFormat("yyyy-MM-dd").format(apprreadInfo.getCreateDate());
    if (!sCreateDate.equals("")) sCreateDate = sCreateDate ; 
%>       
	<tr height=135>
		<td width="250" height="92" valign="top">
            <table border="0" cellspacing="0" width="100%" height="100%" class="Appborder">
            	<tr>
                    <td class="Appborder" bgcolor="#EDF2F5" style="BORDER-BOTTOM: 0px;padding:2 2 0 4;height:25px;">
                        <p align="center" >기안부서</p>
                    </td>
                    <td valign="middle" class="Appborder" style="BORDER-BOTTOM: 0px;BORDER-right: 0px; padding:2 0 0 4; line-height:10px;"><%= gianDpName %>
                    </td>
                </tr>
                <tr>
                    <td class="Appborder" bgcolor="#EDF2F5" style="BORDER-BOTTOM: 0px;padding:2 2 0 4;height:25px;">
                        <p align="center" >기 안 일</p>
                    </td>
                    <td valign="middle" class="Appborder" style="BORDER-BOTTOM: 0px;BORDER-right: 0px; padding:2 0 0 4; line-height:10px;"><%= sCreateDate %>
                    </td>
                </tr>
                <tr>
                    <td width="80" class="Appborder" bgcolor="#EDF2F5" style="BORDER-BOTTOM: 0px;padding:2 2 0 4;height:25px;">
                        <p align="center">기 안 자</p>
                    </td>
                    <td width="*" valign="middle" class="Appborder" style="BORDER-BOTTOM: 0px;padding:2 2 0 4;">
                       <a href="javascript:ShowApprUserInfo('<%= sApprId %>','<%= apprreadInfo.getGianUID() %>','0');"><%= apprreadInfo.getGianNname() %></a>
                    </td>
                </tr>
                <tr>
                    <td class="Appborder" bgcolor="#EDF2F5" style="BORDER-BOTTOM: 0px;padding:2 2 0 4;height:25px;">
                        <p align="center" >문서번호</p>
                    </td>
                    <td valign="middle" class="Appborder" style="BORDER-BOTTOM: 0px;BORDER-right: 0px; padding:2 0 0 4; line-height:10px;"><%= apprreadInfo.getDocNum() %>
                    </td>
                </tr>
                <tr>
                    <td class="Appborder" bgcolor="#EDF2F5" style="BORDER-BOTTOM: 0px;padding:2 2 0 4;;height:25px;">
                        <p align="center">보존년한</p>
                    </td>
                    <td class="Appborder">
						<c:out value="${apprreadInfo.getPreserveItemName() }"/>
                    </td>
                </tr>
            </table>
        </td>
        <td width="*" height="92" valign="top">
            <p>&nbsp;</p>
        </td>
  		<td width="445" height="92" valign="top">
		<table border="0" cellspacing="0" width="100%" class="Appborder" style="padding:2 2 0 4">
			<colgroup">
			<col width="5%">
			<col width="15%" span="6">
			</colgroup>
        	<tr>
        		<td width="*" height="82" rowspan="4" class="Appborder" bgcolor="#EDF2F5">
                    <p align="center">내</p>
                    <p align="center">부</p>
                    <p align="center">결</p>
					<p align="center">재</p>
				</td>
<% 
//------------------------------------------------------------------------------------------------------------------------
//결재 형태, 수신처 설정
    //결재 형태와 수신처
    //결재 형태
    if(apprreadInfo.getApprovalType().equals(ApprDocCode.APPR_NUM_5)){
    	iSize = iSize - apprreadInfo.getApprReqCnt();
    }
    for( i = j ; i < ifor ; i++)
    {
        sType = "";  sApprUid = ""  ;// sApprNo= "";  sApprBujaeUID = "" ;
        String sFonColor = "#000000" ;
        //String sFonColor = "" ;
        if ( i < iSize ) {
            apprpersonInfo = (ApprPersonInfo)arrPer.get(i) ;

            sType =  apprpersonInfo.getType() ; //결재 형태
            sApprUid = apprpersonInfo.getApprUid();
            sApprNo = apprpersonInfo.getApprNo() ;// 결재 ID
            sUpName = apprpersonInfo.getUpName();//결재자 직위

			//협조결재는 보여줄 필요가 없다.
            if ( sType.equals(ApprDocCode.APPR_DOC_CODE_HAN) ) continue ;

            //결재는 진하게 합의는 파란색에 진하게 색 변경
            if (sType.equals(ApprDocCode.APPR_DOC_CODE_APPR) ) {
                sFonColor = "#000000" ; //
            } else {
                sFonColor = "#0033CC" ; //
            }

            // 현재 결재 순서이면 글 색깔 변경(결재 순번으로 결정)            
            if ( (((iMenuId > ApprMenuId.ID_200_NUM_INT ) && (iMenuId < ApprMenuId.ID_300_NUM_INT ) ) ) 
                || (iMenuId == ApprMenuId.ID_130_NUM_INT ) )
            {

                if (sNowApprNo.equals(sApprNo))  sFonColor = "#FF0000" ; //결재 중
                //else { //sFonColor = "#000000" ;  }
            }

        }
        
        if(sChkHelp){	//협조 문서일경우
            String sTypeHan =  ApprUtil.getApprTypeHan(sType)  ;
        	if ( i < (iSize) ){%>
			<td class="Appborder">&nbsp;<FONT  COLOR="<%= sFonColor %>"><B><span id="apprtype<%=i %>"><%= sUpName %></span></B></FONT>&nbsp;</td>
    <%		}else{ %>
    		<td class="Appborder">&nbsp;<FONT  COLOR="<%= sFonColor %>"><B><span id="apprtype<%=i %>">&nbsp;</span></B></FONT>&nbsp;</td>
    <%		} 
        }else{
			//결재자를 제외한 나머지 결재자 처리
        	if ( i < (iSize-1) ){%>
			<td class="Appborder">&nbsp;<FONT  COLOR="<%= sFonColor %>"><B><span id="apprtype<%=i %>"><%= sUpName %></span></B></FONT>&nbsp;</td>
	<%		}else if(i == (ifor-1) ){ %>
			<td class="Appborder">&nbsp;<FONT  COLOR="<%= sFonColor %>"><B><span id="apprtype<%=i %>"><%= sUpName %></span></B></FONT>&nbsp;</td>
	<% 		}else{ %>
			<td class="Appborder">&nbsp;<FONT  COLOR="<%= sFonColor %>"><B><span id="apprtype<%=i %>">&nbsp;</span></B></FONT>&nbsp;</td>
	<%		} %>
	<%	} %>
		<input type="hidden" name="tbapprperuid" value="<%= sApprUid %>" >
        <input type="hidden" name="tbapprpertype" value="<%= sType %>">
<%   }    %>
		
	</tr>
	<tr>
<%
//------------------------------------------------------------------------------------------------------------------------
//결재유형과 결재사인이미지
    for( i = j ; i < ifor ; i++)
    {
		//sType= "";  sApprUid = ""  ; sInApprId = ""; sApprNo  = "" ; sNname = "" ; sApprBujaeUID = "" ; 
    	//sOuid = ""; sImage = "" ; sApprDate ="" ; sShowUser="" ; sBujaeHan= "" ;
	    if ( i < iSize ) {
        	apprpersonInfo = (ApprPersonInfo)arrPer.get(i);

            //sType =  apprpersonInfo.getType() ; //결재 형태
            sApprUid =  apprpersonInfo.getApprUid() ; //결재자 UID
            sInApprId  =  apprpersonInfo.getApprId() ; //결재 문서번호
            sApprNo = apprpersonInfo.getApprNo() ;// 결재 ID
            sNname =  apprpersonInfo.getNName() ; //성명            
            sApprBujaeUID =  apprpersonInfo.getBujaeUID() ; //부재자 UID
            sOuid = apprpersonInfo.getOuid() ; //소유자 UID
            sImage =  apprpersonInfo.getApprImage() ; //결재 사인 이미지
            sApprDate =  apprpersonInfo.getApprDate() ; //결재 일자

            //기안자를 보여줄 필요가 없다.
            //if ( sType.equals(ApprDocCode.APPR_DOC_CODE_GIAN) ) continue ;

            //결재자가 없다면 자바스크립트의 내용을 보여주지 않기 위해서 사용함.
            if (!sApprUid.equals("")){
                sShowUser = "<a href=\"javascript:ShowApprUserInfo(\'"+ sInApprId  +"\', \'"+ sApprUid +"\', \'"+ sApprNo +"\');\">"+ sNname +"</a>" ;
            }
			//Debug.println(sApprUid +"/"+sApprBujaeUID);
            //부재자 표시
            if(!sOuid.equals(sApprBujaeUID)){
                sBujaeHan = ApprDocCode.APPR_DOC_CODE_B_HAN ;
            }else{
            	sBujaeHan = "";
            }
	    }
	    
	    if(sChkHelp){	//협조 문서일경우
	    	if ( i < (iSize) ){%>
				<td class="Appborder2" id="per<%=i%>" style="BORDER-BOTTOM: 0px;padding:4 2 0 4;height:60px;">
				<span id="appruid<%=i %>">
				<font color="#CC33FF" ><%=  sBujaeHan %></font>&nbsp;<%= sShowUser %><br>
	<%      	if (!sApprDate.equals("")) {  // 결재 이미지가 있고 결재 날짜가 있는 경우에는 이미지를 보여주어라.  %>
	            <img src="../userdata/signs/<%= sImage %>"  WIDTH="57" HEIGHT="42" onerror="this.src = '<%= sImagePath %>/app_sign.gif';"  Border="0">
	<%     		 } %></span>
	        </td>
	        <!--  최종결재자 결재자 결재판 결재자 처리 -->
	<%     }else{	%>
				<!-- 결재자가 없는 없는 빈 공란 결재판 처리(사선) -->
				<td class="Appborder2" id="per<%=i%>" background="/common/images/slash2.gif" rowspan=2" style="BORDER-BOTTOM: 0px;padding:2 2 0 4;height:60px;">
				<span id="appruid<%=i %>" style="HEIGHT:100%;">
				<font color="#CC33FF" ></font><br>
	<%      }%>
		        </span></td>
    <%  }else{
			//최종결재자를 제외한 나머지 결재자들까지 결재판처리를 한다.
		    if ( i < (iSize-1) ){%>
				<td class="Appborder2" id="per<%=i%>" style="BORDER-BOTTOM: 0px;padding:4 2 0 4;height:60px;">
				<span id="appruid<%=i %>">
				<font color="#CC33FF" ><%=  sBujaeHan %></font>&nbsp;<%= sShowUser %><br>
	<%      	if (!sApprDate.equals("")) {  // 결재 이미지가 있고 결재 날짜가 있는 경우에는 이미지를 보여주어라.  %>
	            <img src="../userdata/signs/<%= sImage %>"  WIDTH="57" HEIGHT="42" onerror="this.src = '<%= sImagePath %>/app_sign.gif';"  Border="0">
	<%     		 } %></span>
	        </td>
	        <!--  최종결재자 결재자 결재판 결재자 처리 -->
	<%     }else if(i == (ifor-1) ){%>
				<td class="Appborder2" id="per<%=i%>" style="BORDER-BOTTOM: 0px;padding:4 2 0 4;height:60px;">
				<span id="appruid<%=i %>">
				<%=  sBujaeHan %>&nbsp;<%= sShowUser %><br>
				<%if (!sApprDate.equals("")) {  // 결재 이미지가 있고 결재 날짜가 있는 경우에는 이미지를 보여주어라.  %>
	            <img src="../userdata/signs/<%= sImage %>"  WIDTH="57" HEIGHT="42" onerror="this.src = '<%= sImagePath %>/app_sign.gif';"  Border="0">
	<%     		 } %> 
				</span></td>
	<%     }else{
	%>
				<!-- 결재자가 없는 없는 빈 공란 결재판 처리(사선) -->
				<td class="Appborder2" id="per<%=i%>" background="/common/images/slash2.gif" rowspan=2" style="BORDER-BOTTOM: 0px;padding:2 2 0 4;height:60px;">
				<span id="appruid<%=i %>" style="HEIGHT:100%;">
				<font color="#CC33FF" ></font><br>
	<%	   } %>
	        </span></td>
        <%
	    }
  }    %>
	</tr>
	<tr>
<%
//------------------------------------------------------------------------------------------------------------------------
//결재유형과 결재사인이미지

    for( i = j ; i < ifor ; i++) //지정되지 않은 결재선의 사선처리를 위해 아래로 변경
    {
        //sApprDate= "";  sType = ""  ;
        if ( i < iSize ) {
            apprpersonInfo = (ApprPersonInfo)arrPer.get(i) ;

            //sType =  apprpersonInfo.getType() ; //결재 형태
            sApprDate =  apprpersonInfo.getApprDate() ; //결재 일자
            
            //기안자를 보여줄 필요가 없다.
            //if ( sType.equals(ApprDocCode.APPR_DOC_CODE_GIAN) ) continue ;
        }
        if(i <(iSize-1) ){
%>
		<td class="Appborder2" style="BORDER-TOP: 0px;padding:0 2 2 4;height:15px;"><%=(sApprDate)%></td>
<%  	}else if(i == (ifor-1)){%>	
		<td class="Appborder2" style="BORDER-TOP: 0px;padding:0 2 2 4;height:15px;"><%=(sApprDate)%></td>
<%
		}
	} %>
    </tr>
	<tr>
<%
//------------------------------------------------------------------------------------------------------------------------
//결재 형태, 비밀등급설정
String sApprRead = "";
String sBoryuName = "";
    for( i = j ; i < ifor ; i++)
    {
        //sFlagHan ="" ; sXengal = ""; sFlag = "" ;
        
        if ( i < iSize ) //{
        {
        	sApprRead = "";
        	sBoryuName = "";
            apprpersonInfo = (ApprPersonInfo)arrPer.get(i) ;

            //sType =  apprpersonInfo.getType() ; //결재 형태

            sXengal = apprpersonInfo.getXenGal() ;// 전결
            sApprDate =  apprpersonInfo.getApprDate() ; //결재 일자

            sUpName = apprpersonInfo.getUpName();//결재자 직위
			//sApprDate =  (String)arrApprDate.get(i) ; //결재 일자
           //기안자를 보여줄 필요가 없다.
           //if ( sType.equals(ApprDocCode.APPR_DOC_CODE_GIAN) ) continue ;


            //결재 형태 표시

            //결재를 하지 않았다면 어떤 결재 유형인지 모른다 그러므로 보여주지 마라.
            if (!sApprDate.equals("")){
               sFlag = apprpersonInfo.getFlag() ; //결재유형 한글명 ;
               sFlagHan =  ApprUtil.getApprFlagHan(sFlag)  ;
            }
            if (sXengal.equals(ApprDocCode.APPR_DOC_XEN_APPR)) {
                sFlagHan = ApprDocCode.APPR_DOC_CODE_X_HAN ;
            }
            
            //결재 조회했는가
            /*
            String sApprReadDate = apprpersonInfo.getReadDate();
			if(sApprDate.equals("")&&!sApprReadDate.equals("")) sApprRead ="읽음";
			*/
			if(apprpersonInfo.getBoryu()!=null){
				if(apprpersonInfo.getBoryu().equals("T")){
					sBoryuName = "보류";
				}
			}
        }
        
///결재 형태(결재, 반려, 전결) 와 대결 여부
		if(sChkHelp){	//협조 문서일경우
			if( i < (iSize) ){
				%>
				<td class="Appborder">&nbsp;
		    		<font color="#0000FF" ><span id="apprup<%=i %>"><%=sApprRead %><%= ("".equals(sApprDate))? "":sFlagHan  %>&nbsp;<%//= sApprDate %></span></font>
		        </td>
	<%		}else{%>
				<td class="Appborder"><span id="apprup<%=i %>">&nbsp;
		            <font color="#0000FF" ></font></span>
		        </td>
	<%		} 
		}else{
	        if( i < (iSize-1) ){
	%>
				<td class="Appborder">&nbsp;
		    		<font color="#0000FF" ><span id="apprup<%=i %>"><%=sApprRead %><%= ("".equals(sApprDate))? sBoryuName:sFlagHan  %>&nbsp;<%//= sApprDate %></span></font>
		        </td>
	<%		}else if(i == (ifor-1) ){%>
	
				<td class="Appborder">&nbsp;
	    			<font color="#0000FF" ><span id="apprup<%=i %>"><%=sApprRead %><%= ("".equals(sApprDate))? sBoryuName:sFlagHan  %>&nbsp;<%//= sApprDate %></span></font>
		        </td>
	<%		}else{%>
				<td class="Appborder"><span id="apprup<%=i %>">&nbsp;
		            <font color="#0000FF" ></font></span>
		        </td>
	<%		} %>
	<%	} %>
<%   }    %>
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
			<col width=5%>
			<col width="15%" span="6">
			</colgroup>
        	<tr>
        		<td width="*" height="82" rowspan="4" class="Appborder" bgcolor="#EDF2F5">
                    <p align="center">합</p>
                    <p align="center">의</p>
                    <p align="center">부</p>
					<p align="center">서</p>
				</td>
<% 
//------------------------------------------------------------------------------------------------------------------------
//결재 형태, 수신처 설정
    //결재 형태와 수신처
    //결재 형태
	ApprPersonInfo apprpersonInfo_help = null;
	String sDpName = "";
    for( i = 0 ; i < ifor ; i++)
    {
        String sFonColor = "", sHelpApprid = "";
        sType = ""; sApprNo = ""; sUpName = ""; sApprUid= "";
        if ( i < iSizeHelp ) {
        	apprpersonInfo_help = (ApprPersonInfo)arrHelpPer.get(i) ;

            sType =  apprpersonInfo_help.getType() ; //결재 형태
            sApprNo = apprpersonInfo_help.getApprNo() ;// 결재 ID
            sUpName = apprpersonInfo_help.getUpName();//결재자 직위
            sApprUid = apprpersonInfo_help.getApprUid() ;
            sDpName = apprpersonInfo_help.getDpName();//결재자 부서
            sHelpApprid = apprpersonInfo_help.getHelpApprId();//협조 결재문서번호

            //결재는 진하게 합의는 파란색에 진하게 색 변경
            if (sType.equals(ApprDocCode.APPR_DOC_CODE_APPR) ) {
                sFonColor = "#000000" ; //
            } else {
                sFonColor = "#0033CC" ; //
            }

            // 현재 결재 순서이면 글 색깔 변경(결재 순번으로 결정)            
            if ( (((iMenuId > ApprMenuId.ID_200_NUM_INT ) && (iMenuId < ApprMenuId.ID_300_NUM_INT ) ) ) 
                || (iMenuId == ApprMenuId.ID_130_NUM_INT ) )
            {

                if (sNowApprNo.equals(sApprNo))  sFonColor = "#FF0000" ; //결재 중
                //else { //sFonColor = "#000000" ;  }
            }
        }
        //결재자를 제외한 나머지 결재자 처리
        if ( i < (iSizeHelp) ){%>
		<td class="Appborder">&nbsp;<a href="javascript:goHelpApproval('<%=sHelpApprid %>');"><FONT  COLOR="<%= sFonColor %>"><B><span id="apprtype_help<%=i %>"><%= sDpName %></span></B></FONT></a>&nbsp;</td>		
<%		}else{ %>
		<td class="Appborder">&nbsp;<FONT  COLOR="<%= sFonColor %>"><B><span id="apprtype_help<%=i %>">&nbsp;</span></B></FONT>&nbsp;</td>
<%		} %>
		<input type="hidden" name="tbapprperuid_help" value="<%= sApprUid %>" >
        <input type="hidden" name="tbapprpertype_help" value="<%= sType %>">
<%   }    %>
		
	</tr>
	<tr>
<%
//------------------------------------------------------------------------------------------------------------------------
//결재유형과 결재사인이미지
    for( i = j ; i < ifor ; i++)
    {
		sType= "";  sApprUid = ""  ; sInApprId = ""; sApprNo  = "" ; sNname = "" ; sApprBujaeUID = "" ; 
    	sOuid = ""; sImage = "" ; sApprDate ="" ; sShowUser="" ; sBujaeHan= "" ;
	    if ( i < iSizeHelp ) {
	    	apprpersonInfo_help = (ApprPersonInfo)arrHelpPer.get(i);
	    	
            //sType =  apprpersonInfo.getType() ; //결재 형태
            sApprUid =  apprpersonInfo_help.getApprUid() ; //결재자 UID
            sInApprId  =  apprpersonInfo_help.getApprId() ; //결재 문서번호
            sApprNo = apprpersonInfo_help.getApprNo() ;// 결재 ID
            sNname =  apprpersonInfo_help.getNName() ; //성명            
            sApprBujaeUID =  apprpersonInfo_help.getBujaeUID() ; //부재자 UID
            sOuid = apprpersonInfo_help.getOuid() ; //소유자 UID
            sImage =  apprpersonInfo_help.getApprImage() ; //결재 사인 이미지
            sApprDate =  apprpersonInfo_help.getApprDate() ; //결재 일자

            //기안자를 보여줄 필요가 없다.
            //if ( sType.equals(ApprDocCode.APPR_DOC_CODE_GIAN) ) continue ;

            //결재자가 없다면 자바스크립트의 내용을 보여주지 않기 위해서 사용함.
            if (!sApprUid.equals("")){
                sShowUser = "<a href=\"javascript:ShowApprUserInfo(\'"+ sInApprId  +"\', \'"+ sApprUid +"\', \'"+ sApprNo +"\');\">"+ sNname +"</a>" ;
            }
			//Debug.println(sApprUid +"/"+sApprBujaeUID);
            //부재자 표시
            if(!sOuid.equals(sApprBujaeUID)){
                sBujaeHan = ApprDocCode.APPR_DOC_CODE_B_HAN ;
            }else{
            	sBujaeHan = "";
            }
	    }
		//최종결재자를 제외한 나머지 결재자들까지 결재판처리를 한다.
	    if ( i < (iSizeHelp) ){%>
			<td class="Appborder2" id="per_help<%=i%>" style="BORDER-BOTTOM: 0px;padding:4 2 0 4;height:60px;">
			<span id="appruid_help<%=i %>">
			<font color="#CC33FF" ><%=  sBujaeHan %></font>&nbsp;<%= sShowUser %><br>
<%      	if (!sApprDate.equals("")) {  // 결재 이미지가 있고 결재 날짜가 있는 경우에는 이미지를 보여주어라.  %>
            <img src="../userdata/signs/<%= sImage %>"  WIDTH="57" HEIGHT="42" onerror="this.src = '<%= sImagePath %>/app_sign.gif';"  Border="0">
<%     		 } %></span>
        </td>
<%     }else{
%>
			<!-- 결재자가 없는 없는 빈 공란 결재판 처리(사선) -->
			<td class="Appborder2" id="per_help<%=i%>" background="/common/images/slash2.gif" rowspan=2" style="BORDER-BOTTOM: 0px;padding:2 2 0 4;height:60px;">
			<span id="appruid_help<%=i %>" style="HEIGHT:100%;">
			<font color="#CC33FF" ></font><br>
<%
        }%>
	        </span></td>
        <%
  }    %>
	</tr>
	<tr>
<%
//------------------------------------------------------------------------------------------------------------------------
//결재유형과 결재사인이미지

    for( i = j ; i < ifor ; i++) //지정되지 않은 결재선의 사선처리를 위해 아래로 변경
    {
        sApprDate= "";  sType = ""  ;
        if ( i < iSizeHelp ) {
        	apprpersonInfo_help = (ApprPersonInfo)arrHelpPer.get(i) ;

            //sType =  apprpersonInfo_help.getType() ; //결재 형태
            sApprDate =  apprpersonInfo_help.getApprDate() ; //결재 일자

            //기안자를 보여줄 필요가 없다.
            //if ( sType.equals(ApprDocCode.APPR_DOC_CODE_GIAN) ) continue ;
        }
        if(i <(iSizeHelp) ){
%>
		<td class="Appborder2" style="BORDER-TOP: 0px;padding:0 2 2 4;height:15px;"><%=(sApprDate)%></td>
<%  	}
	} %>
    </tr>
	<tr>
<%
//------------------------------------------------------------------------------------------------------------------------
//결재 형태, 비밀등급설정
    for( i = j ; i < ifor ; i++)
    {
        sFlagHan ="" ; sXengal = ""; sFlag = "" ;
        if ( i < iSizeHelp ) //{
        {
        	apprpersonInfo_help = (ApprPersonInfo)arrHelpPer.get(i) ;

            //sType =  apprpersonInfo_help.getType() ; //결재 형태

            sXengal = apprpersonInfo_help.getXenGal() ;// 전결
            sApprDate =  apprpersonInfo_help.getApprDate() ; //결재 일자

			//sApprDate =  (String)arrApprDate.get(i) ; //결재 일자
           //기안자를 보여줄 필요가 없다.
           //if ( sType.equals(ApprDocCode.APPR_DOC_CODE_GIAN) ) continue ;


            //결재 형태 표시

            //결재를 하지 않았다면 어떤 결재 유형인지 모른다 그러므로 보여주지 마라.
            if (!sApprDate.equals("")){
               sFlag = apprpersonInfo_help.getFlag() ; //결재유형 한글명 ;
               sFlagHan =  ApprUtil.getApprFlagHan(sFlag)  ;
            }
            if (sXengal.equals(ApprDocCode.APPR_DOC_XEN_APPR)) {
                sFlagHan = ApprDocCode.APPR_DOC_CODE_X_HAN ;
            }
        }
///결재 형태(결재, 반려, 전결) 와 대결 여부
        if( i < (iSizeHelp) ){
%>
			<td class="Appborder">&nbsp;
	    		<font color="#0000FF" ><span id="apprup_help<%=i %>"><%= ("".equals(sApprDate))? "":sFlagHan  %>&nbsp;<%//= sApprDate %></span></font>
	        </td>
<%		}else{%>
			<td class="Appborder"><span id="apprup_help<%=i %>">&nbsp;
	            <font color="#0000FF" ></font></span>
	        </td>
<%		} %>
<%   }    %>
		</tr>
		</table>
		</td>
	</tr>
</table>
<!-- 협조 결재자 정보 끝 -->
<table class="tblspace03"><tr><td></td></tr></table>
<!-- 신청 결재자 정보 시작 -->
<% 
	if (apprreadInfo.getApprovalType().equals(ApprDocCode.APPR_NUM_5)){
%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
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
                    <p align="center">담</p>
                    <p align="center">당</p>
                    <p align="center">부</p>
					<p align="center">서</p>
				</td>
<% 
//------------------------------------------------------------------------------------------------------------------------
//결재 형태, 수신처 설정
    //결재 형태와 수신처
    //결재 형태
   	j = iSize;
	iSize = arrTemp.size()-1;
   	ifor = iTDfirst + j ;
    for( i = j ; i < ifor ; i++)
    {
        //sType = "";  sApprUid = ""  ;// sApprNo= "";  sApprBujaeUID = "" ;
        //String sFonColor = "#000000" ;
        String sFonColor = "" ;
        if ( i < iSize ) {
            apprpersonInfo = (ApprPersonInfo)arrPer.get(i) ;

            sType =  apprpersonInfo.getType() ; //결재 형태            
            sApprNo = apprpersonInfo.getApprNo() ;// 결재 ID
            sUpName = apprpersonInfo.getUpName();//결재자 직위

            //기안자를 보여줄 필요가 없다.
            //if ( sType.equals(ApprDocCode.APPR_DOC_CODE_GIAN) ) continue ;

            //결재는 진하게 합의는 파란색에 진하게 색 변경
            if (sType.equals(ApprDocCode.APPR_DOC_CODE_APPR) ) {
                sFonColor = "#000000" ; //
            } else {
                sFonColor = "#0033CC" ; //
            }

            // 현재 결재 순서이면 글 색깔 변경(결재 순번으로 결정)            
            if ( (((iMenuId > ApprMenuId.ID_200_NUM_INT ) && (iMenuId < ApprMenuId.ID_300_NUM_INT ) ) ) 
                || (iMenuId == ApprMenuId.ID_130_NUM_INT ) )
            {

                if (sNowApprNo.equals(sApprNo))  sFonColor = "#FF0000" ; //결재 중
                //else { //sFonColor = "#000000" ;  }
            }

        }
        //결재자를 제외한 나머지 결재자 처리
		if ( i < (iSize-1) ){%>
		<td class="Appborder">&nbsp;<FONT  COLOR="<%= sFonColor %>"><B><%= sUpName %></B></FONT>&nbsp;</td>		
<%		}else if(i == (ifor-1) ){ %>
		<td class="Appborder">&nbsp;<FONT  COLOR="<%= sFonColor %>"><B><%= sUpName %></B></FONT>&nbsp;</td>		
<% 		}else{ %>
		<td class="Appborder">&nbsp;</td>		
<%		} %>
<%   }    %>
		
	</tr>
	<tr>
<%
//------------------------------------------------------------------------------------------------------------------------
//결재유형과 결재사인이미지

    for( i = j ; i < ifor ; i++)
    {
		//sType= "";  sApprUid = ""  ; sInApprId = ""; sApprNo  = "" ; sNname = "" ; sApprBujaeUID = "" ; 
    	//sOuid = ""; sImage = "" ; sApprDate ="" ; sShowUser="" ; sBujaeHan= "" ;
	    if ( i < iSize ) {
        	apprpersonInfo = (ApprPersonInfo)arrPer.get(i);

            //sType =  apprpersonInfo.getType() ; //결재 형태
            sApprUid =  apprpersonInfo.getApprUid() ; //결재자 UID
            sInApprId  =  apprpersonInfo.getApprId() ; //결재 문서번호
            sApprNo = apprpersonInfo.getApprNo() ;// 결재 ID
            sNname =  apprpersonInfo.getNName() ; //성명            
            sApprBujaeUID =  apprpersonInfo.getBujaeUID() ; //부재자 UID
            sOuid = apprpersonInfo.getOuid() ; //소유자 UID
            sImage =  apprpersonInfo.getApprImage() ; //결재 사인 이미지
            sApprDate =  apprpersonInfo.getApprDate() ; //결재 일자

            //기안자를 보여줄 필요가 없다.
            //if ( sType.equals(ApprDocCode.APPR_DOC_CODE_GIAN) ) continue ;

            //결재자가 없다면 자바스크립트의 내용을 보여주지 않기 위해서 사용함.
            if (!sApprUid.equals("")){
                sShowUser = "<a href=\"javascript:ShowApprUserInfo(\'"+ sInApprId  +"\', \'"+ sApprUid +"\', \'"+ sApprNo +"\');\">"+ sNname +"</a>" ;
            }
			//Debug.println(sApprUid +"/"+sApprBujaeUID);
            //부재자 표시
            if(!sOuid.equals(sApprBujaeUID)){
                sBujaeHan = ApprDocCode.APPR_DOC_CODE_B_HAN ;
            }
	    }
		//최종결재자를 제외한 나머지 결재자들까지 결재판처리를 한다.
	    if ( i < (iSize-1) ){%>
			<td class="Appborder2" style="BORDER-BOTTOM: 0px;padding:2 2 0 4;height:75px;"><font color="#CC33FF" ><%=  sBujaeHan %></font>&nbsp;<%= sShowUser %><br>
<%      	if (!sApprDate.equals("")) {  // 결재 이미지가 있고 결재 날짜가 있는 경우에는 이미지를 보여주어라.  %>
            <img src="../userdata/signs/<%= sImage %>"  WIDTH="57" HEIGHT="42" onerror="this.src = '<%= sImagePath %>/app_sign.gif';"  Border="0">
<%     		 } %>        
        </td>
		<!--  최종결재자 결재자 결재판 결재자 처리 -->
<%     }else if(i == (ifor-1) ){%>
			<td class="Appborder2" style="BORDER-BOTTOM: 0px;padding:2 2 0 4;height:75px;"><%=  sBujaeHan %></font>&nbsp;<%= sShowUser %><br>
			<%if (!sApprDate.equals("")) {  // 결재 이미지가 있고 결재 날짜가 있는 경우에는 이미지를 보여주어라.  %>
            <img src="../userdata/signs/<%= sImage %>"  WIDTH="70" HEIGHT="50" onerror="this.src = '<%= sImagePath %>/app_sign.gif';"  Border="0">
<%     		 } %> 
<%
        }else{
%>
			<!-- 결재자가 없는 없는 빈 공란 결재판 처리(사선) -->
			<td class="Appborder2" background="/common/images/slash2.gif" rowspan=2" style="BORDER-BOTTOM: 0px;padding:2 2 0 4;height:105px;"><font color="#CC33FF" ></font><br>
<%
        }
  }    %>
	</tr>
	<tr>
<%
//------------------------------------------------------------------------------------------------------------------------
//결재유형과 결재사인이미지

    for( i = j ; i < ifor ; i++) //지정되지 않은 결재선의 사선처리를 위해 아래로 변경
    {
        //sApprDate= "";  sType = ""  ;
        if ( i < iSize ) {
            apprpersonInfo = (ApprPersonInfo)arrPer.get(i) ;

            //sType =  apprpersonInfo.getType() ; //결재 형태
            sApprDate =  apprpersonInfo.getApprDate() ; //결재 일자

            //기안자를 보여줄 필요가 없다.
            //if ( sType.equals(ApprDocCode.APPR_DOC_CODE_GIAN) ) continue ;
        }
        if(i <(iSize-1) ){
%>
		<td class="Appborder2" style="BORDER-TOP: 0px;padding:0 2 2 4;height:15px;"><%=(sApprDate)%></td>
<%  	}else if(i == (ifor-1)){%>	
		<td class="Appborder2" style="BORDER-TOP: 0px;padding:0 2 2 4;height:15px;"><%=(sApprDate)%></td>
<%
		}
	} %>
	</tr>
	<tr>
<%
//------------------------------------------------------------------------------------------------------------------------
//결재 형태, 비밀등급설정
    for( i = j ; i < ifor ; i++)
    {
        //sFlagHan ="" ; sXengal = ""; sFlag = "" ;
        if ( i < iSize ) //{
        {
            apprpersonInfo = (ApprPersonInfo)arrPer.get(i) ;

            //sType =  apprpersonInfo.getType() ; //결재 형태

            sXengal = apprpersonInfo.getXenGal() ;// 전결
            sApprDate =  apprpersonInfo.getApprDate() ; //결재 일자

			//sApprDate =  (String)arrApprDate.get(i) ; //결재 일자
           //기안자를 보여줄 필요가 없다.
           //if ( sType.equals(ApprDocCode.APPR_DOC_CODE_GIAN) ) continue ;

            //결재 형태 표시

            //결재를 하지 않았다면 어떤 결재 유형인지 모른다 그러므로 보여주지 마라.
            if (!sApprDate.equals("")){
               sFlag = apprpersonInfo.getFlag() ; //결재유형 한글명 ;
               sFlagHan =  ApprUtil.getApprFlagHan(sFlag)  ;
            }
            if (sXengal.equals(ApprDocCode.APPR_DOC_XEN_APPR)) {
                sFlagHan = ApprDocCode.APPR_DOC_CODE_X_HAN ;
            }
        }
///결재 형태(결재, 반려, 전결) 와 대결 여부
		if( i < (iSize-1) ){
%>
		<td class="Appborder">&nbsp;
            <font color="#0000FF" ><%= ("".equals(sApprDate))? "":sFlagHan  %>&nbsp;<%//= sApprDate %></font>
        </td>
<%		}else if(i == (ifor-1) ){%>
		<td class="Appborder">&nbsp;
            <font color="#0000FF" ><%= ("".equals(sApprDate))? "":sFlagHan  %>&nbsp;<%//= sApprDate %></font>
        </td>
<%		}else{%>
		<td class="Appborder">&nbsp;
            <font color="#0000FF" ></font>
        </td>
<%		} %>
<%   }    %>
		</tr>
		</table>
		</td>
    </tr>
<% }%>
<!-- 신청결재자 끝 -->
</table>
<%
///**************************************************************************************************
///**************************************************************************************************
///**************************************************************************************************
///**************************************************************************************************
	}

} //for (int k = 0 ; k < iLoop ; k++ )
%>
<!-- 결재자 정보 끝 -->

<table class="tblspace05"><tr><td></td></tr></table>
<!-- 수신처 정보 시작 -->
<table width="100%" cellspacing="0" height="100%" class="Appborder" style="BORDER-BOTTOM: 0px;padding:2 2 0 4;">
	<tr>
		<td width="15%" class="Appborder" bgcolor="#EDF2F5">수신처</td>
		<!-- 수신처 처리 -->
		<td width="*" class="Appborder" bgcolor="#ffffff" style="text-align:left;text-valign:bottom">
		    <div id="receivehtml" style="height:20px;width:100%;overflow:no;border:0px;">
            <font color="#000000">
<%
    //수신처 정보 출력
    ArrayList arrReceive = apprreadInfo.getReceive() ;
    int iReceiveSize = 0 ;
    if (arrReceive != null ) iReceiveSize = arrReceive.size() ; 
        
    ApprReceiveInfo receiveInfo = null ; 
    if ( arrReceive != null )
    {

	    String sReceiveType = "", sReceiveName = "", sRceiveText = "", sCommonCheck = ""    ;
	    String sReceiveDpName = "" , sReceiveID= "" ;
		String sReceiveUpName = ""  ; 
	    boolean bCommon = true ; 
	
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

<table class="tblspace05"><tr><td></td></tr></table>

<!-- 참조자 정보 시작 -->
<table width="100%" cellspacing="0" height="100%" class="Appborder" style="BORDER-BOTTOM: 0px;padding:2 2 0 4;">
	<tr>
		<td width="15%" class="Appborder" bgcolor="#EDF2F5">참조자</td>
		<!-- 참조자 처리 -->
		<td width="*" class="Appborder" bgcolor="#ffffff" style="text-align:left;text-valign:bottom">
		    <div id="receivehtml2" style="height:20px;width:100%;overflow:no;border:0px;">
            <font color="#000000">
<%
    //참조 정보 출력
    ArrayList arrReference = null;
    //합의 문서는 원결재문서의 참조를 보여준다. 2011-07-21
   	arrReference = apprreadInfo.getReference() ;
    
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
                <%= sRceiveText %>
                <input type="hidden" name="receivetype2" value="<%= sReceiveType %>">
                <input type="hidden" name="receiveid2" value="<%= sReceiveID %>">
                <input type="hidden" name="commoncheck2" value="<%= sCommonCheck %>">

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
<!-- 참조자 끝 -->

<!-- 결재의견은 popup -->
<%// 마지막 번호 %>
<input type="hidden" name="apprpersoncnt" value="<%= iSize %>">
<%//협조 결재자 시작번호 %>
<input type="hidden" name="apprhelpcnt">
<%// 새로 생성된 결재자 테이블의 수 %>
<input type="hidden" name="apprpersontablecnt" value="0">
