<%@ page contentType="text/html;charset=utf-8" %>
<%@ page errorPage="../error.jsp" %>

<%@ page import="java.sql.*" %>

<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="com.oreilly.servlet.*" %>
<%@ page import="com.oreilly.servlet.multipart.*" %>
<%@ page import="nek.approval.*" %>
<%@ page import="javax.activation.*" %>
<%@ page import="nek.common.*" %>

<%@ include file="../common/usersession.jsp"%>
<% request.setCharacterEncoding("UTF-8"); %>
<%!
    //각 경로 패스
    String sImagePath =  ApprDocCode.APPR_IMAGE_PATH  ;
    String sJsScriptPath =  ApprDocCode.APPR_JAVASCRIPT_PATH ;
    String sCssPath =  ApprDocCode.APPR_CSS_PATH ;
%>
<%
	java.util.UUID uuid = java.util.UUID.randomUUID();

    //각 경로 패스
    String sUid = loginuser.uid;
    int iUploadSize = new Long(uservariable.uploadSize).intValue()  ;
    if ( iUploadSize == 0 ) iUploadSize = 1024*1024 ;
    
    //파일의 경로 가져오기
    String apprPath  = request.getRealPath("/")+ File.separator + "userdata" + File.separator + "signs" +File.separator  ;// File.separator   
    int iMenuId = ApprMenuId.ID_410_NUM_INT ; 

    String sSignFileNm  = "" ; 
    String cmd = "" ; 
    boolean bFile = false ;
    MultipartRequest mrReq = null;
    ApprSign signObj = null ; 
    try
    {
        
        signObj = new ApprSign() ;        

        if ("POST".equals(request.getMethod()))	
        {
            mrReq = new MultipartRequest(request, apprPath, iUploadSize, "UTF-8");

            cmd = ApprUtil.setnullvalue(mrReq.getParameter("cmd"), ApprDocCode.APPR_NEW) ;   //신규-> null, 수정 -> edit, 

            if(cmd.equals(ApprDocCode.APPR_EDIT) )
            {
                
                String sConfPassd = mrReq.getParameter("confpassd"); //
                sConfPassd =  ApprUtil.nullCheck( sConfPassd )  ; 
    
                //서버에 파일저장
                File fds = null ; 
                String sName ="", sFsName = "" , sPath= "" ;
                Enumeration enumNames = mrReq.getFileNames();  // 폼의 이름 반환
                while(enumNames.hasMoreElements()) {
                    sName = (String)enumNames.nextElement();
                    sFsName = mrReq.getFilesystemName(sName);                
                    if (sFsName != null) 
                    {			
                        sPath = apprPath + sFsName;                    
                        fds = new File(sPath);
                    }
                }

                ApprSignInfo apprsignInfo = new ApprSignInfo(); 
    
                apprsignInfo.setUID(sUid) ; 
                apprsignInfo.setApprSign(sFsName) ; 
                apprsignInfo.setSignFilePath(apprPath) ; 
                apprsignInfo.setNewApprPass(sConfPassd) ; 
    
                bFile = signObj.ApprSignConf(apprsignInfo) ;
            }
        }

        sSignFileNm = signObj.ApprSignSelect( sUid) ;  //  
        if (sSignFileNm == null ) sSignFileNm = ""; 
    }catch(Exception e){
        Debug.println (e) ;
    } finally {
        signObj.freeConnecDB() ;
    }


%>

<html>
<head>
<title>결재사인등록</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel=stylesheet href="<%= cssPath %>/list.css" type="text/css">
<link rel="STYLESHEET" type="text/css" href="<%= imgCssPath %>">
<link rel="stylesheet" href="/common/css/style.css">
<script src="<%= scriptPath %>/common.js"></script>
<SCRIPT LANGUAGE="JavaScript">
<!--
     //도움말
    SetHelpIndex("appr_sign") ;

    function doSubmit()
    {
        if(isEmpty( "signfile" )) {
            alert("<%=msglang.getString("appr.select.sing.file") /* 서명 파일을 선택하시기 바랍니다. */ %>") ; 
            return ; 
        }  

//         if(isEmpty( "confpassd" )) {
//             alert("비밀번호를 입력하시기 바랍니다.") ; 
//             return ; 
//         }  

        if( !confirm("<%=msglang.getString("appr.insert.sing") /* 서명을 등록하시겠습니까? */ %>") ) return ; 

        document.mainForm.cmd.value = "<%= ApprDocCode.APPR_EDIT %>" ; 
        document.mainForm.method = "post" ; 
        mainForm.submit() ; 

    }

	function setUserPhoto(fileObj)
	{
		if (fileObj.value != "") document.all.userphoto.src = fileObj.value;
		else document.all.userphoto.src = "<%= sImagePath %>/Photo_User_Default.gif";
	}
//-->
</SCRIPT>
<link type="text/css" href="/common/css/appr.css" rel="stylesheet" /><!---리뉴얼 추가 파일---->
</head>
<body style="margin: 0 0 0 0; padding-top: 0px;">

<form name="mainForm"  action="./appr_signature.jsp" method="post" enctype="multipart/form-data"  onsubmit="return false;" >
<!-- List Title -->
	<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; height:37px; z-index:100;">
	<tr>
	<td width="60%" style="padding-left:5px; padding-top:5px; "><!-- <img src="../common/images/h3_ctbg.gif" border="0" align="absmiddle"> -->
	<span class="ltitle"><img align="absmiddle" src="/common/images/icons/title-list-blue-folder2.png" /> <b>
		<%//=ApprUtil.getNavigation(iMenuId)%>
		<%=msglang.getString("main.Approval") /* 전자결재 */ %> &gt;
		<%=msglang.getString("appr.menu.config") /* 환경설정 */ %> &gt;
		<%=msglang.getString("appr.menu.sing.set") /* 결재서명등록 */ %>
	</b> </span>
	</td>
	<td width="40%" align="right">
	<!-- 					n 개의 읽지않은 문서가 있습니다. -->
	</td>
	</tr>
	</table>
	<!-- List Title -->
<input type="hidden" name="cmd" > 

	<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%" >
		<tr> 
			<td valign="top"> 
				<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
					<tr> 
						<td bgcolor="#FFFFFF" valign="top">
						
							<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
								<tr> 
									<td width="4">&nbsp; </td>
									<td valign="top"> 
										<table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
											<tr> 
												<td valign="top"> 
													<table width="100%" border="0" cellspacing="0" cellpadding="0">
														<tr> 
															<td height="10"></td>
														</tr>
														<tr> 
															<td> 
																<div id="viewList" class="div-view" onpropertychange="div_resize();">
																<table width="100%" border="0" cellspacing="0" cellpadding="0" id="viewTable">
																	<tr> 
																		<td height="30" valign="top"> 
																		<!-- 본문 DATA 시작 -->
																			<table width="100%" cellspacing="0" cellpadding="0" style="border-collapse:collapse">
																				<tr height="100">
																					<td class="td_ce1" style="width:50px;"><%=msglang.getString("appr.signreg") %><!-- 결재사인등록-->&nbsp;<font color="red">*</font><br>(75 x 60)</td><!-- width="110" -->
																					<td class="td_le2" width="315">
																			           <!--<input type="file" name="signfile" value="" onchange="javascript:setUserPhoto(this);" style="width:256px;">
                                                                                       <img id="userphoto" onerror="this.src = '<%= sImagePath %>/app_sign.gif';" src="../userdata/signs/<%= sSignFileNm %>?_=<%=uuid %>" WIDTH="80" HEIGHT="60" Border="0" >-->
                                                                                      <img id="userphoto" onerror="this.src = '<%= sImagePath %>/app_sign.gif';" src="../userdata/signs/<%= sSignFileNm %>?_=<%=uuid %>" WIDTH="80" HEIGHT="60" Border="0" >
                                                                                       <div class="file_input">
                                                                                            <label>
                                                                                                파일 업로드
                                                                                                <input type="file"   name="signfile" value="" onchange="javascript:document.getElementById('file_route').value=this.value;javascript:setUserPhoto(this);">
                                                                                            </label>
                                                                                            <input type="text" readonly="readonly" title="File Route" id="file_route">
                                                                                            
                                                                                        </div>
                                                                                        
                                                                                    </td>
																					<!--<td class="td_le2" width="87" rowspan="2"  valign="middle" align="center">
																						<span onclick="doSubmit()" class="button white medium">
																						<img src="../common/images/bb02.gif" border="0"> <%=msglang.getString("t.save") /* 저장 */ %> </span>
																			        </td> -->
																				</tr>
<!-- 																				<tr> -->
<%-- 																					<td class="td_ce1" style="width:150px;"  ><%=msglang.getString("appr.signinput") %><!-- 결재패스워드-->&nbsp;<font color="red">*</font></td> --%>
<!-- 																					<td class="td_le2" width="258" > width="308" -->
<!-- 																			            <input type="password" name="confpassd" value="" style="width:267px;" maxlength="255"> -->
<!-- 																			        </td> -->
<!-- 																				</tr> -->
																			
																			</table>
                                                                            <div class="btn_save" onclick="doSubmit()">
																               <%=msglang.getString("t.save") /* 저장 */ %>
                                                                            </div>
																			<!-- 본문 DATA 끝 -->
																		</td>
																	</tr>
																	<tr> 
																		<td height="15"></td>
																	</tr>
																</table>
																</div>
															</td>
															<td width="11">&nbsp;</td>
														</tr>
													</table>
												</td>
											</tr>											
										</table>
									</td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>

</form>

</body>
</html>

<script>
previewCancel();	/* preview cancellation */
</script>

<%  if (bFile) { %>
<SCRIPT LANGUAGE="JavaScript">
<!--
    alert("<%=msglang.getString("appr.not.equals.password") /* 결재 비밀번호가 다릅니다. */ %>"); 
//-->
</SCRIPT>
<%  
    } 
    if ((cmd.equals(ApprDocCode.APPR_EDIT) ) &&  ( !bFile))
    {
%>
<SCRIPT LANGUAGE="JavaScript">
<!--
    alert("<%=msglang.getString("t.save.ok") /* 저장되었습니다. */ %>") ; 
//-->
</SCRIPT>
<%
    }    
%>
