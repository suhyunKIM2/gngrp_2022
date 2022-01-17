<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>

<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.oreilly.servlet.*" %>
<%@ page import="com.oreilly.servlet.multipart.*" %>
<%@ page import="nek.approval.*" %>
<%@ page import="javax.activation.*" %>

<%@  include file="../common/usersession.jsp"%>
<%!
    //현재 사용자의 임시 업로드 저장폴더 확인 후 없으면 생성
    String sFileSeparator = java.io.File.separator ;

	//나모웹에디터 이미지 저장 폴더삭제
	private void deleteImgFiles(String docId, String imgDir)
	{
		String fileSaveName = "";
		File imgFile[] = null;
		fileSaveName = imgDir;
		File dir = new File(fileSaveName);
		if (!dir.exists()) return;
		imgFile = new File(fileSaveName).listFiles();
		for(int i=0;i<imgFile.length;i++){
			imgFile[i].delete();
		}
		File imgDiretory = new File(fileSaveName);
		imgDiretory.delete();
	}
%>
<%    
    request.setCharacterEncoding("UTF-8"); 

    String sFilePath = application.getInitParameter("datadir") ; 
    if (!sFilePath.endsWith(sFileSeparator)) sFilePath += sFileSeparator;
    String apprPath = sFilePath + "approval" + sFileSeparator ;
    File apprDir = new File(apprPath);
    if (!apprDir.exists() || !apprDir.isDirectory()) {
        apprDir.mkdir();
    }

    String sUid = loginuser.uid;
    int iUploadSize = new Long(uservariable.uploadSize).intValue()  ;
    if ( iUploadSize == 0 ) iUploadSize = 10*1024*1024 ;

//System.out.println("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&") ; 
    //데이타를 가져온다.
    MultipartRequest mrReq =      //  new MultipartRequest(request, apprPath)  ;
        new MultipartRequest(request, apprPath, iUploadSize,
                              "UTF-8", new DefaultFileRenamePolicy());

	String sCallType = ApprUtil.nullCheck(mrReq.getParameter("calltype")) ;
	String sMoveUrl ="";
    if (sCallType.equals(ApprDocCode.APPR_TEMP) ) //결재 양식의 본문내용을 가져오시오.
    {
        String sFormID = ApprUtil.nullCheck(mrReq.getParameter("apprformid")) ;

        ApprForm formObj = new ApprForm() ;
        ApprFormInfo apprformInfo = null  ;
        try
        {
            apprformInfo = formObj.ApprFormSel(sFormID) ;
        } finally {
            formObj.freeConnecDB() ;
        }
        //원하는 곳(제목과 본문)에 값을 보내라.

///저장시 본문의 내용을 담아 둘수 있는 방법을 찿지 못하여서 하난의 HTML의 span 안에 값을 넣고
// 그값을 다시 옮겨주는 방법을 사용하였다.
%>
<HTML>
<HEAD>
<TITLE>결재 양식 호출</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
</HEAD>

<BODY >

<div id="imsibody"><%= nek.common.util.HtmlEncoder.encode(ApprUtil.nullCheck( apprformInfo.getContend() )) %></div>

</BODY>
</HTML>
<SCRIPT LANGUAGE="JavaScript">
<!--
    var formtitle = "<%= ApprUtil.nullCheck(apprformInfo.getSubject()) %>" ;

    var sBody = document.all.imsibody.innerText ;
    document.all.imsibody.innerHTML = sBody; 
    parent.main.document.all.WebEditor.DOM.body.innerHTML = document.all.imsibody.innerHTML ;
    

    parent.main.document.all.apprform.innerHTML = formtitle ;    
    parent.main.document.mainForm.apprformid.value = <%=apprformInfo.getFormID()%> ;
    parent.main.document.mainForm.formtitle.value = formtitle ;
    //결재양식 보존년한 셋팅
    var prNum = 1;
    switch(<%=apprformInfo.getPreserveId() %>){
    	case 1: prNum = 0;	break;
    	case 2: prNum = 1;	break;
    	case 3: prNum = 2;	break;
    	case 4: prNum = 3;	break;
    	case 5: prNum = 4;	break;
    	case 10: prNum = 5;	break;
    	case 99: prNum = 6;	break;
    }
    parent.main.document.mainForm.preserveitems.selectedIndex = prNum ;

//-->
</SCRIPT>
<%

//-----------------------------------------------------------------------------------------------------------
    }else if (sCallType.equals(ApprDocCode.APPR_DELETE) ) {  // 삭제 

        String sApprID = ApprUtil.nullCheck(mrReq.getParameter("apprid")) ;  //결재문서번호

        ApprovalDocDelete ApprObj = null ; 
        try
        {  
        	String uploadPath = request.getRealPath("/") + File.separator + "common" + File.separator + "namo" + File.separator;;
        	uploadPath += "approval" + File.separator +sApprID + File.separator;
        	
            ApprObj = new ApprovalDocDelete(sApprID, apprPath ) ;
            deleteImgFiles(sApprID, uploadPath);

boolean iLoop = false ; 
int iAuthApprNo = 0 ; 
String sAuthApprID = sApprID ; 
String[] allApprNo = null ; 
String[] allApprID = null ; 
%>
<%@ include file="./appr_authory_edit.jsp" %>
<%
            ApprObj.ApprImsiDocDelete(sUid) ; 

        } finally {
            ApprObj.freeConnecDB() ; 
        }
        out.println("<script language='javascript'>if(opener.parent.main!=undefined){"
        		  + "opener.parent.main.location.href = './appr_imsilist.jsp?menu=120';"
        		  + "}else{"
        		  + "opener.parent.main.location.reload();"
        		  + "} window.close();"
        		  +	"</script>");
		return;
        //response.sendRedirect("./appr_imsilist.jsp?menu=120" ) ;

//-----------------------------------------------------------------------------------------------------------
    } else { //결재 상신, 임시 저장, 처리
		//신청부서 등록 조회
    	/*
    	ArrayList arrList = new ArrayList() ;
       	ApprReqLine lineObj = null ;
       	int reqCnt = 0;
       	String sDpid = mrReq.getParameter("reqLineitems");	//신청결재 부서ID
       	if(sDpid.equals("")||sDpid==null){
       	}else{
			try
			{
				lineObj = new ApprReqLine() ;
				arrList = lineObj.ApprReqLineDTListUser(sDpid);
				reqCnt = arrList.size();
			}catch(Exception e){
				Debug.println (e) ;
			} finally {
				lineObj.freeConnecDB() ;
			}
       	}
       	*/

        // getParameterValues
        // 각종 정보
        String sDelFileList = "" ;
        String sFormId = ApprUtil.nullCheck(mrReq.getParameter("apprformid"));	//결재양식문서 ID
        if(sFormId==null) sFormId = "";
        String smrCmd = ApprUtil.nullCheck(mrReq.getParameter("cmd")) ;  // value = new, edit, del, imsi
        String sMenuId = ApprUtil.nullCheck(mrReq.getParameter("menu")) ;  // 
        String sApprID = ApprUtil.nullCheck(mrReq.getParameter("apprid")) ;  //결재문서번호        
        String sPreserveItems = ApprUtil.nullCheck(mrReq.getParameter("preserveitems")) ; // 보존년한

        //String sApprPeople = ApprUtil.nullCheck(mrReq.getParameter("apprpepole")) ;// 결재자정보
        String sSubject = ApprUtil.nullCheck(mrReq.getParameter("subject")) ; // 제목
        String sBody = ApprUtil.nullCheck(mrReq.getParameter("editbody")) ; //webedit의 내용
        String sFormTitle = ApprUtil.nullCheck(mrReq.getParameter("formtitle")) ; //
        String[] sDelFile = mrReq.getParameterValues("DROP") ;//파일 삭제는 "DROP"으로 값을 받아라.
        
        String[] arrApprPeople = mrReq.getParameterValues("tbapprperuid") ;// 결재자 ID 
        String[] attType = mrReq.getParameterValues("tbapprpertype") ;// 결재자 결재 형태
        String[] arrApprPeople_help = mrReq.getParameterValues("tbapprperuid_help") ;// 협조 결재자 ID 
	    String[] attType_help = mrReq.getParameterValues("tbapprpertype_help") ;// 협조 결재자 결재 형태
	    int apprhelpcnt = Integer.parseInt(ApprUtil.setnullvalue(mrReq.getParameter("apprhelpcnt"),"0"));	//협조 결재자 순서
	    
	    String[] arrApprPeople_busi = mrReq.getParameterValues("tbapprperuid_busi") ;// 업무연락  결재자 ID 
	    String[] attType_busi = mrReq.getParameterValues("tbapprpertype_busi") ;// 업무연락 결재자 결재 형태

        String sOldApprID = ApprUtil.nullCheck(mrReq.getParameter("oldapprid")) ;  //재 기안 전의 원본 결재 ID        

        //수신처
        String[] arrReceiveID = mrReq.getParameterValues("receiveid") ;//  수진자ID
        String[] attReceiveType = mrReq.getParameterValues("receivetype") ;// 수신자type
        String[] attCommonCheck = mrReq.getParameterValues("commoncheck") ;// 하위부서 공유유무
        //참조
        String[] arrReferenceID = mrReq.getParameterValues("referenceid") ;//  참조자ID
        String[] attReferenceType = mrReq.getParameterValues("referencetype") ;// 참조자type
        String[] attRCommonCheck = mrReq.getParameterValues("rcommoncheck") ;// 하위부서 공유유무2
        
        String sSecurityid = ApprUtil.setnullvalue(mrReq.getParameter("securityid"),"0") ;  //보안등급      
        String sApprovalType = ApprUtil.setnullvalue(mrReq.getParameter("approvaltype"), "1") ; // 결재형식
        String openFlag = ApprUtil.setnullvalue(mrReq.getParameter("openflag"), "1");	//공개여부
        
        String relateValue = ApprUtil.nullCheck(mrReq.getParameter("relateValue"));	//관련문서 S
        String relateText = ApprUtil.nullCheck(mrReq.getParameter("relateText"));	//관련문서 Text
//Debug.println("cmd==>"+smrCmd+"/menu==>"+sMenuId) ; 
//Debug.println("apprid==>"+sApprID+"/preserveitems==>"+sPreserveItems) ; 
//Debug.println("subject==>"+sSubject+"/formtitle==>"+sFormTitle) ; 
//Debug.println("sBody==>"+sBody) ; 

        int iLen = -1 ; 
        //------------------------------------------------------------------------------------
        //수신자처리
        iLen = (arrReceiveID == null ) ? 0 : arrReceiveID.length ;

        ArrayList arrReceive = new ArrayList() ; 
        ApprReceiveInfo receiveInfo = null ; 

        for(int i = 0 ; i< iLen ; i++)
        {
            receiveInfo = new ApprReceiveInfo() ; 
//Debug.println(attReceiveType[i]) ; 
//Debug.println(arrReceiveID[i]) ; 
//Debug.println(attCommonCheck[i]) ; 
            receiveInfo.setReceiveType(attReceiveType[i]) ; 
            receiveInfo.setReceiveID(arrReceiveID[i]) ; 
            receiveInfo.setCommonCheck(attCommonCheck[i]) ; 
            //receiveInfo.setCommonCheck("F") ; 

            arrReceive.add(receiveInfo) ; 
        }

        //------------------------------------------------------------------------------------
        //------------------------------------------------------------------------------------
        //참조 처리
        int iLen2 = (arrReferenceID == null ) ? 0 : arrReferenceID.length ;

        ArrayList arrReference = new ArrayList() ; 
        ApprReferenceInfo referenceInfo = null ; 

        for(int i = 0 ; i< iLen2 ; i++)
        {
        	referenceInfo = new ApprReferenceInfo() ;
//Debug.println(attReceiveType[i]) ; 
//Debug.println(arrReceiveID[i]) ; 
//Debug.println(attCommonCheck[i]) ; 
            referenceInfo.setReferenceType(attReferenceType[i]) ; 
            referenceInfo.setReferenceID(arrReferenceID[i]) ; 
            referenceInfo.setCommonCheck(attRCommonCheck[i]) ; 
            //receiveInfo.setCommonCheck("F") ;

            arrReference.add(referenceInfo) ; 
        }
        

        //------------------------------------------------------------------------------------
        //결재자
        //임시저장에서는 결재자가 없을 수도 있다.        
        iLen = (arrApprPeople == null ) ? 0 : arrApprPeople.length ;
        int iLenHelp = (arrApprPeople_help == null ) ? 0 : arrApprPeople_help.length ;
        int iLenBusi = (arrApprPeople_busi == null ) ? 0 : arrApprPeople_busi.length ;

        String sApprPeople = ""; 
        ArrayList arrPerson = new ArrayList() ; 

        ApprPersonInfo apprpersonInfo = new ApprPersonInfo() ;
        //기안자 넣기(업무연락이 아니면)
		if(!sApprovalType.equals(ApprDocCode.APPR_NUM_7)){
	        apprpersonInfo.setApprUid(loginuser.uid ) ; 
	        apprpersonInfo.setType(ApprDocCode.APPR_DOC_CODE_GIAN) ; 
	        arrPerson.add(apprpersonInfo) ; 
        }
        
		//신청결재자 넣기
		/*
		if(sApprovalType.equals(ApprDocCode.APPR_NUM_5)){
			ApprReqLineDTInfo arrlinedtInfo = null ;
	        for(int i=0;i<arrList.size();i++){ 
	        	arrlinedtInfo = (ApprReqLineDTInfo)arrList.get(i);
	        	apprpersonInfo = new ApprPersonInfo() ;
	            apprpersonInfo.setApprUid(arrlinedtInfo.getApprPersonUID()) ; 
	            apprpersonInfo.setType("A") ; 
	            arrPerson.add(apprpersonInfo) ; 
	        }
		}
		*/

		if(sApprovalType.equals(ApprDocCode.APPR_NUM_7)){	//업무연락이면 결재자를 다시 설정한다.
			//결재자 넣기
			if(iLenBusi>0){
				apprpersonInfo = new ApprPersonInfo() ; 
	        	apprpersonInfo.setApprUid(loginuser.uid) ; 
	        	apprpersonInfo.setType(ApprDocCode.APPR_DOC_CODE_GIAN) ; //최초 결재자
	        	arrPerson.add(apprpersonInfo) ; 
	        }
	        for(int i = iLenBusi-1 ; i >= 1 ; i--)
	        {
	            if (arrApprPeople_busi[i] == null || arrApprPeople_busi[i].equals("") ) continue ; //정보가 없다면 skip
	            apprpersonInfo = new ApprPersonInfo() ; 
	            apprpersonInfo.setApprUid(arrApprPeople_busi[i]) ; 
	            apprpersonInfo.setType(attType_busi[i]) ; 
	            arrPerson.add(apprpersonInfo) ; 
	        }
		}else{
	        //결재자 넣기
	        for(int i = iLen-1 ; i >= 0 ; i--)
	        {
	            if (arrApprPeople[i] == null || arrApprPeople[i].equals("") ) continue ; //정보가 없다면 skip
	            //sApprPeople = sApprPeople + ApprDocCode.APPR_GUBUN + arrApprPeople[i] +"|"+attType[i] ;
	            apprpersonInfo = new ApprPersonInfo() ; 
	            apprpersonInfo.setApprUid(arrApprPeople[i]) ; 
	            apprpersonInfo.setType(attType[i]) ; 
	            arrPerson.add(apprpersonInfo) ; 
	            
				//협조 결재자 추가
		        if(apprhelpcnt==i){
		        	for(int j = iLenHelp-1 ; j >= 0 ; j--){
		        		if (arrApprPeople_help[j] == null || arrApprPeople_help[j].equals("") ) continue ;
		        		apprpersonInfo = new ApprPersonInfo() ; 
		    	        apprpersonInfo.setApprUid(arrApprPeople_help[j]) ; 
		    	        apprpersonInfo.setType(attType_help[j]) ; 
		    	        arrPerson.add(apprpersonInfo) ; 
		        	}
		        }
	        }
		}

        //결재자 정보에 기안자의 정보를 추가 한다.
        //sApprPeople = loginuser.uid +"|" + ApprDocCode.APPR_DOC_CODE_GIAN + sApprPeople ; 

        //-----------------------------------------------------------------------------------------
        //첨부                                           
        String sName, sFsName, sPath, sHabFileName = ""  ;        
        File fds = null ;
        Enumeration enumNames = mrReq.getFileNames();  // 폼의 이름 반환
        //실제 파일 이름으로 서버에 저장한다. 그후 파일의 이름을 변경하자.(class에서 처리한다.)
        ArrayList arrFileName = new ArrayList() ; 
        while(enumNames.hasMoreElements()) 
        {
            sName = (String)enumNames.nextElement();
            sFsName = mrReq.getFilesystemName(sName);

            //sHabFileName = sHabFileName + ApprDocCode.APPR_GUBUN +sFsName ; //구분코드 "<>" 저장할 파일 이름을 넣어라.
            arrFileName.add(sFsName) ; 

            if (sFsName != null) {
                sPath = apprPath + "\\" + sFsName;

                fds = new File(sPath);
            }
        }

        //삭제 파일을 목록을 작성해서 넘려라.
        ArrayList arrDelFileList = new ArrayList() ; 
        if (sDelFile != null ) 
        {
            for(int i = 0 ; i < sDelFile.length ; i++)
            {
                arrDelFileList.add(sDelFile[i]) ; 

                //sDelFileList = sDelFileList + ApprDocCode.APPR_GUBUN  + sDelFile[i] ;
            }
        }

        //-----------------------------------------------------------------------------------------
        //파일 구분자의 크기
        int iGubunLen = (ApprDocCode.APPR_GUBUN).length() ;
        //info 파일을 만들어라.
        ApprovalEditInfo appreditInfo = new ApprovalEditInfo() ;

        appreditInfo.setCmd(smrCmd) ;
        appreditInfo.setApprID(sApprID) ;
        appreditInfo.setPreserveItems(sPreserveItems) ;
        //appreditInfo.setApprPepole(sApprPeople) ;
        appreditInfo.setArrApprPepole(arrPerson) ;
        
        appreditInfo.setApprFormid(sFormId);	//결재양식 문서번호
        
        appreditInfo.setSubject(sSubject) ;
        appreditInfo.setBody(sBody) ;
        appreditInfo.setFormTitle(sFormTitle) ;
        appreditInfo.setFilePath(apprPath) ;  
        appreditInfo.setUID(sUid) ; //기안자 
        appreditInfo.setCallType(sCallType) ; 
        appreditInfo.setRootFilePath(sFilePath) ;  //file copy에 사용

        appreditInfo.setOldApprId(sOldApprID) ; //old        

        appreditInfo.setReceive(arrReceive) ; //수신
        appreditInfo.setReference(arrReference) ; //참조
        appreditInfo.setSecurityID(sSecurityid) ; //보안등급
        
        //appreditInfo.setOpenFlag(openFlag);		//공개여부
        appreditInfo.setRelateText(relateText);	//관련문서 Text
        appreditInfo.setRelateValue(relateValue);	//관련문서 Value
        
        
        //신청결재 추가 2007.06.20
        /*
        if(sApprovalType.equals(ApprDocCode.APPR_NUM_5)){
        	appreditInfo.setApprReqDpid(sDpid);
        	appreditInfo.setApprReqCnt(reqCnt);
        }
        */

        //처음부터 구분자가 있다. 이 부분은 넘어가지 않도록 처리하자.
        //자바 스크립트에서는 이부분을 활용
        if (!sHabFileName.equals(""))
        {
            appreditInfo.setarrFileName(arrFileName) ;
        }
        if (!sDelFileList.equals(""))
        {
            appreditInfo.setarrDeleteFile(arrDelFileList) ;
        }

        appreditInfo.setarrFileName(arrFileName) ;

        appreditInfo.setarrDeleteFile(arrDelFileList) ;
		//-----------------------------------------------------------------------------------------
		ApprRegularFormInfo regformInfo = null;			//신청계
		ApprRegularBusiInfo regBusiInfo = null;			//출장신청 및 명령서
		ApprRegularReportInfo regReportInfo = null;		//업무일보
		ApprRegularChitInfo regChitInfo = null;			//분개전표
		ApprRegularBusiReportInfo regBuReInfo = null;	//출장보고서
		if(sFormId.equals(ApprDocCode.APPR_FIX_NUM_1)){	//신청 계
			//계 본문내용 입력
	        String fType = ApprUtil.nullCheck(mrReq.getParameter("ftype")) ;// 유형
			String deptId = ApprUtil.nullCheck(mrReq.getParameter("deptid")) ;// 부서 ID
			String deptName = ApprUtil.nullCheck(mrReq.getParameter("deptname")) ;// 부서명
			String ouid = ApprUtil.nullCheck(mrReq.getParameter("ouid")) ;// UID
			String ouName = ApprUtil.nullCheck(mrReq.getParameter("ouname")) ;// 성명
			String content = ApprUtil.nullCheck(mrReq.getParameter("content")) ;// 사유
	        String startDate = ApprUtil.nullCheck(mrReq.getParameter("startdate")) ;// 시작일자
	        String endDate = ApprUtil.nullCheck(mrReq.getParameter("enddate")) ;// 종료일자
	        
	        regformInfo =new ApprRegularFormInfo();
	        regformInfo.setFType(fType);
	        regformInfo.setDeptId(deptId);
	        regformInfo.setDeptName(deptName);
	        regformInfo.setOuName(ouName);
	        regformInfo.setOuid(ouid);
	        regformInfo.setContent(content);
	        regformInfo.setStartDate(startDate);
	        regformInfo.setEndDate(endDate);
	        
		}else if(sFormId.equals(ApprDocCode.APPR_FIX_NUM_2)){	//출장신청 및 명령서
			//출장신청 및 명령서  본문내용 입력
			String ouid = ApprUtil.nullCheck(mrReq.getParameter("ouid")) ;// UID
			String ouName = ApprUtil.nullCheck(mrReq.getParameter("ouname")) ;// 성명
			String fuid = ApprUtil.nullCheck(mrReq.getParameter("fuid")) ;// 동행자 iD
			String fuName = ApprUtil.nullCheck(mrReq.getParameter("funame")) ;// 동행자명
			String purpose = ApprUtil.nullCheck(mrReq.getParameter("purpose")) ;// 출장목적
			String local = ApprUtil.nullCheck(mrReq.getParameter("local")) ;// 출장지
			String localEtc = ApprUtil.nullCheck(mrReq.getParameter("localetc")) ;// 출장지 기타
	        String startDate = ApprUtil.nullCheck(mrReq.getParameter("startdate")) ;// 시작일자
	        String endDate = ApprUtil.nullCheck(mrReq.getParameter("enddate")) ;// 종료일자
	        String bak = ApprUtil.nullCheck(mrReq.getParameter("bak")) ;// X박
			String dday = ApprUtil.nullCheck(mrReq.getParameter("dday")) ;// X일
			String startTime = ApprUtil.nullCheck(mrReq.getParameter("starttime")) ;// 시작일자
	        String endTime = ApprUtil.nullCheck(mrReq.getParameter("endtime")) ;// 종료일자
	        String content = ApprUtil.nullCheck(mrReq.getParameter("content")) ;// 사유

	        regBusiInfo = new ApprRegularBusiInfo();
	        regBusiInfo.setOuid(ouid);
	        regBusiInfo.setOuName(ouName);
	        regBusiInfo.setFuid(fuid);
	        regBusiInfo.setFuName(fuName);
	        regBusiInfo.setPurpose(purpose);
			regBusiInfo.setLocal(local);
			regBusiInfo.setLocalEtc(localEtc);
			regBusiInfo.setStartDate(startDate);
			regBusiInfo.setEndDate(endDate);
			regBusiInfo.setBak(bak);
			regBusiInfo.setDday(dday);
			regBusiInfo.setStartTime(startTime);
			regBusiInfo.setEndTime(endTime);
			regBusiInfo.setContent(content);
		} else if(sFormId.equals(ApprDocCode.APPR_FIX_NUM_3)){	//업무일보
			//출장신청 및 명령서  본문내용 입력
			int dtype = Integer.parseInt(ApprUtil.setnullvalue(mrReq.getParameter("dtype"), "0")) ;// 유형
			int pgtype = Integer.parseInt(ApprUtil.setnullvalue(mrReq.getParameter("select_pg"),"0")) ;// 페이지 넘버
			String pg1_vistor1 = ApprUtil.nullCheck(mrReq.getParameter("pg1_vistor1")) ;// 방문처1
			String pg1_vistor2 = ApprUtil.nullCheck(mrReq.getParameter("pg1_vistor2")) ;// 업무내용1
			String pg2_vistor1 = ApprUtil.nullCheck(mrReq.getParameter("pg2_vistor1")) ;// 방문처2
			String pg2_vistor2 = ApprUtil.nullCheck(mrReq.getParameter("pg2_vistor2")) ;// 업무내용2
			String pg3_vistor1 = ApprUtil.nullCheck(mrReq.getParameter("pg3_vistor1")) ;// 방문처3
	        String pg3_vistor2 = ApprUtil.nullCheck(mrReq.getParameter("pg3_vistor2")) ;// 업무내용3
	        String company = ApprUtil.nullCheck(mrReq.getParameter("company")) ;// 업체
	        String standard = ApprUtil.nullCheck(mrReq.getParameter("standard")) ;// 규격
			String model = ApprUtil.nullCheck(mrReq.getParameter("model")) ;// 강종
			String used = ApprUtil.nullCheck(mrReq.getParameter("used")) ;// 용도
	        String details = ApprUtil.nullCheck(mrReq.getParameter("details")) ;// 불만사항

	        regReportInfo = new ApprRegularReportInfo();
	        regReportInfo.setDtype(dtype);
	        regReportInfo.setPgType(pgtype);
	        regReportInfo.setPg1_vistor1(pg1_vistor1);
	        regReportInfo.setPg1_vistor2(pg1_vistor2);
	        regReportInfo.setPg2_vistor1(pg2_vistor1);
	        regReportInfo.setPg2_vistor2(pg2_vistor2);
	        regReportInfo.setPg3_vistor1(pg3_vistor1);
	        regReportInfo.setPg3_vistor2(pg3_vistor2);
	        regReportInfo.setCompany(company);
	        regReportInfo.setStandard(standard);
	        regReportInfo.setModel(model);
	        regReportInfo.setUsed(used);
	        regReportInfo.setDetails(details);
		} else if(sFormId.equals(ApprDocCode.APPR_FIX_NUM_4)){	//분개전표
			//분개전표 본문내용 입력
			String cha_tot = ApprUtil.nullCheck(mrReq.getParameter("cha_tot")) ;// 차변 합계
	        String dae_tot = ApprUtil.nullCheck(mrReq.getParameter("dae_tot")) ;// 대변 합계
	         
	        regChitInfo = new ApprRegularChitInfo();
	        regChitInfo.setNo_1(ApprUtil.nullCheck(mrReq.getParameter("no_1")));
	        regChitInfo.setNo_2(ApprUtil.nullCheck(mrReq.getParameter("no_2")));
	        regChitInfo.setNo_3(ApprUtil.nullCheck(mrReq.getParameter("no_3")));
	        regChitInfo.setNo_4(ApprUtil.nullCheck(mrReq.getParameter("no_4")));
	        regChitInfo.setNo_5(ApprUtil.nullCheck(mrReq.getParameter("no_5")));
	        regChitInfo.setNo_6(ApprUtil.nullCheck(mrReq.getParameter("no_6")));
	        regChitInfo.setNo_7(ApprUtil.nullCheck(mrReq.getParameter("no_7")));
	        regChitInfo.setNo_8(ApprUtil.nullCheck(mrReq.getParameter("no_8")));
	        regChitInfo.setKwa_1(ApprUtil.nullCheck(mrReq.getParameter("kwa_1")));
	        regChitInfo.setKwa_2(ApprUtil.nullCheck(mrReq.getParameter("kwa_2")));
	        regChitInfo.setKwa_3(ApprUtil.nullCheck(mrReq.getParameter("kwa_3")));
	        regChitInfo.setKwa_4(ApprUtil.nullCheck(mrReq.getParameter("kwa_4")));
	        regChitInfo.setKwa_5(ApprUtil.nullCheck(mrReq.getParameter("kwa_5")));
	        regChitInfo.setKwa_6(ApprUtil.nullCheck(mrReq.getParameter("kwa_6")));
	        regChitInfo.setKwa_7(ApprUtil.nullCheck(mrReq.getParameter("kwa_7")));
	        regChitInfo.setKwa_8(ApprUtil.nullCheck(mrReq.getParameter("kwa_8")));
	        regChitInfo.setJuk_1(ApprUtil.nullCheck(mrReq.getParameter("juk_1")));
	        regChitInfo.setJuk_2(ApprUtil.nullCheck(mrReq.getParameter("juk_2")));
	        regChitInfo.setJuk_3(ApprUtil.nullCheck(mrReq.getParameter("juk_3")));
	        regChitInfo.setJuk_4(ApprUtil.nullCheck(mrReq.getParameter("juk_4")));
	        regChitInfo.setJuk_5(ApprUtil.nullCheck(mrReq.getParameter("juk_5")));
	        regChitInfo.setJuk_6(ApprUtil.nullCheck(mrReq.getParameter("juk_6")));
	        regChitInfo.setJuk_7(ApprUtil.nullCheck(mrReq.getParameter("juk_7")));
	        regChitInfo.setJuk_8(ApprUtil.nullCheck(mrReq.getParameter("juk_8")));
			regChitInfo.setCha_1(ApprUtil.nullCheck(mrReq.getParameter("cha_1")));
			regChitInfo.setCha_2(ApprUtil.nullCheck(mrReq.getParameter("cha_2")));
			regChitInfo.setCha_3(ApprUtil.nullCheck(mrReq.getParameter("cha_3")));
			regChitInfo.setCha_4(ApprUtil.nullCheck(mrReq.getParameter("cha_4")));
			regChitInfo.setCha_5(ApprUtil.nullCheck(mrReq.getParameter("cha_5")));
			regChitInfo.setCha_6(ApprUtil.nullCheck(mrReq.getParameter("cha_6")));
			regChitInfo.setCha_7(ApprUtil.nullCheck(mrReq.getParameter("cha_7")));
			regChitInfo.setCha_8(ApprUtil.nullCheck(mrReq.getParameter("cha_8")));
	        regChitInfo.setDae_1(ApprUtil.nullCheck(mrReq.getParameter("dae_1")));
	        regChitInfo.setDae_2(ApprUtil.nullCheck(mrReq.getParameter("dae_2")));
	        regChitInfo.setDae_3(ApprUtil.nullCheck(mrReq.getParameter("dae_3")));
	        regChitInfo.setDae_4(ApprUtil.nullCheck(mrReq.getParameter("dae_4")));
	        regChitInfo.setDae_5(ApprUtil.nullCheck(mrReq.getParameter("dae_5")));
	        regChitInfo.setDae_6(ApprUtil.nullCheck(mrReq.getParameter("dae_6")));
	        regChitInfo.setDae_7(ApprUtil.nullCheck(mrReq.getParameter("dae_7")));
	        regChitInfo.setDae_8(ApprUtil.nullCheck(mrReq.getParameter("dae_8")));
	        regChitInfo.setCha_tot(cha_tot);
	        regChitInfo.setDae_tot(dae_tot);
		}
        //-----------------------------------------------------------------------------------------
        
        //DB에 넣어라.        
        ApprovalEdit ApprObj = null ; 
        try
        {
        	if(sFormId.equals(ApprDocCode.APPR_FIX_NUM_1)){	//신청계
        		ApprObj = new ApprovalEdit(appreditInfo, regformInfo) ;
	        }else if(sFormId.equals(ApprDocCode.APPR_FIX_NUM_2)){	//출장신청 및 명령서
	        	ApprObj = new ApprovalEdit(appreditInfo, regBusiInfo) ;
	        }else if(sFormId.equals(ApprDocCode.APPR_FIX_NUM_3)){	//업무일보
	        	ApprObj = new ApprovalEdit(appreditInfo, regReportInfo) ;
	        }else if(sFormId.equals(ApprDocCode.APPR_FIX_NUM_4)){	//분개전표
	        	ApprObj = new ApprovalEdit(appreditInfo, regChitInfo) ;
	        }else{
	        	ApprObj = new ApprovalEdit(appreditInfo) ;
	        }
if (smrCmd.equals(ApprDocCode.APPR_EDIT)&&!sApprovalType.equals(ApprDocCode.APPR_NUM_7)) {
//수정 권한 검사
boolean iLoop = false ; 
int iAuthApprNo = 0 ; 
String sAuthApprID = sApprID ; 
String[] allApprNo = null ; 
String[] allApprID = null ; 
%>
<%@ include file="./appr_authory_edit.jsp" %>
<%
}
			String uploadPath = request.getRealPath("/");
			ApprObj.ApprovalSendDoc(sApprovalType, uploadPath) ; 
        } finally {
            ApprObj.freeConnecDB() ; 
        }

        //-----------------------------------------------------------------------------------------    
        //휴가원일 경우에는 휴가원으로 보내주어라.
        //그리고 휴가원 테이블에 값을 저장 하도록 하자.
        if (sFormTitle.equals("vacationdoc") ) { //휴가원인 경우 
           new HttpServletRequestWrapper(request).getRequestDispatcher("../vacation/vaca_writeControl.jsp").forward(request, response) ; 
        }
        //-----------------------------------------------------------------------------------------
        //이동해라.
        sMoveUrl = ApprMenuId.ID_130_URL ;  // 결재 상신
        if (sCallType.equals(ApprDocCode.APPR_IMSI) ) { //임시저장
            sMoveUrl = ApprMenuId.ID_120_URL ;
        } 
        
        //response.sendRedirect(sMoveUrl ) ; //기안으로 보내기

    }//else if
    
%>
<script language="javascript">
try{
	opener.parent.main.location.href ="<%=sMoveUrl%>";
}catch(ex){
	//alert("현재 페이지를 벗어났습니다.");
	window.close();
}finally{
	window.close();
}
</script>