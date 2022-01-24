<%@ page contentType="text/html;charset=utf-8" %>
<%@ page import="java.util.*" %>
<%@ page import="nek.approval.*" %>

<%@ include file="../common/usersession.jsp" %>

<%
request.setCharacterEncoding("utf-8");

//문서 ID, 없으면 목록으로 리다이렉트
String sApprId = request.getParameter("apprid");
String menuId = request.getParameter("menuid");
int iMenuId = Integer.parseInt(menuId);
if (sApprId == null) {
	response.sendRedirect("appr_list.jsp?" );
	return;
}

//문서 읽기
ApprovalDocRead apprObj = null ; 
ApprovalDocReadInfo apprreadInfo = new ApprovalDocReadInfo() ; //info
StringBuffer fileAttachInfo = new StringBuffer();
try{
	apprObj = new ApprovalDocRead(loginuser, sApprId, iMenuId,  application.getInitParameter("CONF.HOME_PATH")) ;

	apprreadInfo = apprObj.ApprovalSelect() ;

}finally
{
	if(apprObj != null) apprObj.freeConnecDB();
}

%>
	
<style>
.v_attach {}
.v_attach td {font-size:9pt; padding:3px; vertical-align:top; }
.v_attach tr {height:20px; }
a {color:black;}
</style>
<div style="width:100%; border:0px solid #A1B5FE; ">
<table width=100% height=100% cellspacing=0 cellpadding=0 border=0 style="border-collapse:collapse; border:0px solid white;table-layout:fixed;" oncontextmenu="return false" ondragstart="return false"  >
<%
	String baseURL = apprreadInfo.getHomePathUrl() ;
	if (!baseURL.endsWith("/")) baseURL += "/";
	baseURL += "approval/appr_download.jsp?apprid=" + apprreadInfo.getTopApprID() + "&fileno=";    
	String sFileName = apprreadInfo.getFileName();
	StringTokenizer st = new StringTokenizer(sFileName, "|");
	String totFile = "";
	if ( !sFileName.equals("") )
	{
		int count = 1;
		while(st.hasMoreTokens()){
			String arrTmp = st.nextToken();
			if(count>1&&count%3==1) totFile += ",";
			if(count%3==1){
				totFile += arrTmp;
			}else{
				totFile += "／"+ arrTmp;
			}
			count++;
		}
		String[] tmpStr = totFile.split(",");
		for(int i=0;i<tmpStr.length;i++){
			String[] strVal = tmpStr[i].split("／");
%>
	<tr style="height:20px;">
		<td width=* style="font-size:9pt; padding:3px; padding-right:5px; vertical-align:top; text-overflow:ellipsis; overflow:hidden; white-space:nowrap;">
			<img src='../common/images/icons/icon_attach.gif'>&nbsp;
			<a href="<%=baseURL + strVal[0] %>" style="text-decoration:none;"><%out.print( strVal[1] );%></a>
		</td>
	</tr>
<%
		}
	}
%>
</table>
</div>
