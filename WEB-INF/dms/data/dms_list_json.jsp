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
    
	java.util.List<DmsNativeSqlItem> items = listPage.getItems();
	String category, subject, createDate, writer, fileCnt, readCnt, hotFlag, openFlag;
	int idx = items.size();
	for(int i=0; i<idx; i++){
		DmsNativeSqlItem item = items.get(i);
		cellObj.put("id", item.getDocId());
		StringBuilder sb = new StringBuilder();
		sb.append("<img src='../common/images/btn_listdot.gif' border='0'></a>");
		if(item.getCatFullName() != null && !item.getCatFullName().equals("") && !item.getCatFullName().equals("null")){
			sb.append(item.getCatFullName());
		}else{
			sb.append(item.getCatName());
		}
		category = sb.toString();
		sb.setLength(0);
		
		if(item.isHotFlag()){	//중요
			sb.append("<span class='ui-corner-all grid-btn-blue'>중요</span>");
		}else{
			sb.append("");
		}
		hotFlag = sb.toString();
		sb.setLength(0);
		
		//공유구분 - 1: 전체공유, 0:지정공유
		if(item.getOpenFlag().equals("1")){
 			sb.append("<img title='전체공개' src='/common/images/document-share.png' align='absmiddle' border='0'>");
		}
		openFlag = sb.toString();
		sb.setLength(0);
	
		sb.append("<a href='javascript:goSubmit(\"view\", \"false\", \"").append(item.getDocId()).append("\");'>");
		
		if (lToday - item.getCreateDate().getTime() < DAY_TIME) {
			sb.append("<b>").append(item.getSubject()).append("</b>");
		} else {
			if( item.isHotFlag()) {
				sb.append("<font color='red'><b>" + item.getSubject() + "</b></font>");
			} else {
				sb.append(item.getSubject());
			}
		}
		String revisionStr = "";
		if(	item.getRevisionNo() > 0){
			revisionStr = " <font color='blue'>(Rev." + item.getRevisionNo() + ")</font>";
		}
		subject = sb.toString() + revisionStr;
		sb.setLength(0);
		
		createDate = dspformatter.format(item.getCreateDate()).substring(0, 16);
		
		sb.append("<a class='maninfo' rel='").append(item.getOuId()).append("' href='#'>")
		.append("<img src='../common/images/man_info.gif' border='0' align='absmiddle'>")
		.append(item.getnName()).append("</a>");
		
		writer = sb.toString();
		
		if ("20140409161336".equals(item.getCatId())) {
			writer = "익명";
		}
		
		sb.setLength(0);
		
		if (item.getFileCnt() > 0){
			sb.append("<a name='listAttach' rel='docid=" + item.getDocId() + "&fileno=" + "" + "' href='#'><img src='../common/images/icons/ico_file.gif'")
			.append(" style='cursor:hand;' />");
			
			fileCnt = sb.toString();
			sb.setLength(0);
	 	} else {
	 		fileCnt = "";
	 	}
		
		readCnt = Integer.toString(item.getReadCnt());
		
		cell.add(category);
		cell.add(hotFlag);
		cell.add(openFlag);
        cell.add(subject);
        cell.add(createDate);
        cell.add(writer);
        cell.add(fileCnt);
        cell.add(readCnt);
        
        cellObj.put("cell",cell);    
        cell.clear();    
        cellArray.add(cellObj);    
	}
    jsonData.put("rows",cellArray);
    out.println(jsonData);
%>
