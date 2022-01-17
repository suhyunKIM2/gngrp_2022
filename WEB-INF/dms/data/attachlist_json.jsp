<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="nek3.domain.dms.*" %>
<%@ page import="nek3.common.*" %>
<%@ page import="org.apache.commons.lang.StringUtils"%>
<%@ page import="net.sf.json.*"%>
<%@ page import="java.text.SimpleDateFormat" %>
<%
	long DAY_TIME = 86400000;

	SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMdd");
	SimpleDateFormat dspformatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	java.util.Date NOW = new java.util.Date();
	String today = formatter.format(NOW);
	long lToday = NOW.getTime();	// 86400000	 : 하루의 milisecond

	ListPage listPage = (ListPage)request.getAttribute("listPage");
	
    JSONObject jsonData =new JSONObject();    
    jsonData.put("total", listPage.getPageCnt());
    jsonData.put("page", listPage.getPage());
    jsonData.put("records", listPage.getTotalCnt());
    
    JSONArray cellArray=new JSONArray();
    JSONArray cell = new JSONArray();     
    JSONObject cellObj=new JSONObject();    
    
	java.util.List<DmsFile> items = listPage.getItems();
	String category, subject, createDate, writer, chkFlag, fileName;
	long fileSize;
	int idx = items.size();
	for(int i=0; i<idx; i++){
		DmsFile item = items.get(i);
		Dms dms = item.getParentDms();
		
		StringBuilder sb = new StringBuilder();
		//선택 -----------------------------------------------------------------------------------------------
		sb.append("<input type='checkbox' name='chkdocid' value='" + item.getId().getDocId() + "／" + item.getId().getFileNo() ) ;
		sb.append("／" + dms.getSubject() );
		sb.append("／" + item.getFileName() );
		sb.append("／" + item.getFileSaveName() );
		sb.append("／" + item.getFileSize() );
		sb.append("'>");
		chkFlag = sb.toString();
		sb.setLength(0);
		//제목 -----------------------------------------------------------------------------------------------
		sb.append("<a href='javascript:goSubmit(\"view\", \"false\", \"").append(item.getId().getDocId()).append("\");'>");
		sb.append(dms.getSubject());
		sb.append("</a>");
		subject = sb.toString();
		sb.setLength(0);
		//파일-----------------------------------------------------------------------------------------------
		fileName = item.getFileName();
		sb.setLength(0);
		//파일크기-----------------------------------------------------------------------------------------------
		fileSize = item.getFileSize();
		sb.setLength(0);
		//날짜 -----------------------------------------------------------------------------------------------
		createDate = dspformatter.format(dms.getCreateDate());
		sb.setLength(0);
		//작성자 -----------------------------------------------------------------------------------------------
		sb.append("<a href='javascript:ShowUserInfo(\"").append(dms.getOuUser().getUserId()).append("\");'>")
				.append("<img src='../common/images/man_info.gif' border='0' align='absmiddle'>")
				.append(dms.getOuUser().getnName()).append("</a>");
		writer = sb.toString();
		sb.setLength(0);
		//---------------------------------------------------------------------------------------------------------
		
		cell.add(chkFlag);
        cell.add(subject);
        cell.add(fileName);
        cell.add(fileSize);
        cell.add(createDate);
//         cell.add(writer);
        
        cellObj.put("docid", item.getId().getDocId()+ "／" + item.getId().getFileNo() );
        cellObj.put("cell",cell);    
        cell.clear();    
        cellArray.add(cellObj);    
	}
    jsonData.put("rows",cellArray);
    out.println(jsonData);
%>
