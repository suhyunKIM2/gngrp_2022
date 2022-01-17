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
    
	java.util.List<Dms> items = listPage.getItems();
	String category, subject, createDate, writer, fileCnt, readCnt, hotFlag;
	int idx = items.size();
	for(int i=0; i<idx; i++){
		Dms item = items.get(i);
		cellObj.put("id", item.getDocId());
		StringBuilder sb = new StringBuilder();
		/*
		if(StringUtils.equals(item.getBbsId(), "bbs00000000000000")){
			if(item.getImportFlag() == 1){
				sb.append("<img src='/common/images/hot.gif' align=absmiddle title='중요공지'>");
			}
		}
		*/
// 		category = item.getDmsCategory().getCatName();
		category = item.getDmsCategory().getCatFullName();
		
		if(item.isHotFlag()){	//중요
			sb.append("<img title='중요' src='/common/images/vwicn181.gif' align='absmiddle' border='0'>");
		}else{
			sb.append("");
		}
		hotFlag = sb.toString();
		sb.setLength(0);
		
		createDate = (item.getCreateDate()).toString();
		
		//sb.append("<a href='javascript:goSubmit(\"view\", \"true\", \"").append(item.getDocId()).append("\");'>")
		sb.append("<img src='../common/images/btn_listdot.gif' border='0'></a>");
	
		if (item.getReadCnt() > 30 ) {
			sb.append("<img src='/common/images/b_ks.gif' align=absmiddle>");
		}
		//sb.append("<img src='../common/images/reicon.gif' border='0' align='absmiddle'>");
		sb.append("<a href='javascript:goSubmit(\"view\", \"true\", \"").append(item.getDocId()).append("\");'>");
// 		sb.append("<a href='javascript:onClickOpen(\"").append(item.getDocId()).append("\");'>");
		
		if (lToday - item.getCreateDate().getTime() < DAY_TIME) {
			sb.append("<b>").append(item.getSubject()).append("</b>");
		} else {
			sb.append(item.getSubject());
		}
		subject = sb.toString();
		sb.setLength(0);
		
		
		sb.append("<a href='javascript:ShowUserInfo(\"").append(item.getOuUser().getUserId()).append("\");'>")
				.append("<img src='../common/images/man_info.gif' border='0' align='absmiddle'>")
				.append(item.getOuUser().getnName()).append("</a>");
		writer = sb.toString();
		sb.setLength(0);
		
		if (item.getFileCnt() > 0){
			sb.append("<img src='../common/images/icons/ico_file.gif'")
				.append(" onclick='javascript:ShowAttach(\"")
				.append(item.getDocId()).append("\");'")
				.append(" style='cursor:hand;' />");
			fileCnt = sb.toString();
			sb.setLength(0);
	 	} else {
	 		fileCnt = "";
	 	}
		
		readCnt = Integer.toString(item.getReadCnt());
		
		cell.add(category);
		cell.add(hotFlag);
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
