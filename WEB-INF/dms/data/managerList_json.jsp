<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="nek3.domain.dms.*" %>
<%@ page import="nek3.common.*" %>
<%@ page import="nek3.domain.*" %>
<%@ page import="org.apache.commons.lang.StringUtils"%>
<%@ page import="net.sf.json.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
	long DAY_TIME = 86400000;

	SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMdd");
	SimpleDateFormat dspformatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	java.util.Date NOW = new java.util.Date();
	String today = formatter.format(NOW);
	long lToday = NOW.getTime();	// 86400000	 : 하루의 milisecond

	ListPage listPage = (ListPage)request.getAttribute("listPage");
	List preservePeriods = (List)request.getAttribute("preservePeriods");
	
    JSONObject jsonData =new JSONObject();    
    jsonData.put("total", listPage.getPageCnt());
    jsonData.put("page", listPage.getPage());
    jsonData.put("records", listPage.getTotalCnt());
    
    JSONArray cellArray=new JSONArray();
    JSONArray cell = new JSONArray();     
    JSONObject cellObj=new JSONObject();    
    
	java.util.List<DmsNativeSqlItem> items = listPage.getItems();
	
	Calendar c = Calendar.getInstance();
	SimpleDateFormat sd = new SimpleDateFormat("yyyy-MM-dd");
	
	String category, subject, writer, startDate, endDate, preserveId, keepDate;
	int idx = items.size();
	for(int i=0; i<idx; i++){
		DmsNativeSqlItem item = items.get(i);
		cellObj.put("id", item.getDocId());
		StringBuilder sb = new StringBuilder();
		/*
		if(StringUtils.equals(item.getBbsId(), "bbs00000000000000")){
			if(item.getImportFlag() == 1){
				sb.append("<img src='/common/images/hot.gif' align=absmiddle title='중요공지'>");
			}
		}
		*/
		/* category */
		sb.append("<a href='javascript:goSubmit(\"view\", \"true\", \"").append(item.getDocId()).append("\");'>")
			.append("<img src='../common/images/btn_listdot.gif' border='0'></a>"+item.getCatName());
		//category = item.getCatName();
		category = sb.toString();
		sb.setLength(0);

		/* subject */
		//sb.append("<a href='javascript:goSubmit(\"view\", \"true\", \"").append(item.getDocId()).append("\");'>")
		sb.append("<img src='../common/images/btn_listdot.gif' border='0'></a>");
	
		if (item.getReadCnt() > 30 ) {
			sb.append("<img src='/common/images/b_ks.gif' align=absmiddle>");
		}
		//sb.append("<img src='../common/images/reicon.gif' border='0' align='absmiddle'>");
		sb.append("<a href='javascript:onClickOpen(\"").append(item.getDocId()).append("\");'>");
		
		if (lToday - item.getCreateDate().getTime() < DAY_TIME) {
			sb.append("<b>").append(item.getSubject()).append("</b>");
		} else {
			sb.append(item.getSubject());
		}
		subject = sb.toString();
		sb.setLength(0);
		
		/* preserveDate */
		c.setTime(item.getCreateDate());
		int monthTmp = item.getPreserveId();
		
		
		startDate = item.getCreateDate().toString().substring(0,10);
		endDate = item.getPreserveDate().toString().substring(0,10);
		keepDate = startDate+" ~ "+endDate;
		
		
		String selectedVal = "";
		/* preserveId */
		
		sb.append("<select name='a'>");
		if(item.getPreserveId() == 1){
			sb.append("<option value='1' selected>1년</option>");
		}else{
			sb.append("<option value='1'>1년</option>");
		}
		
		if(item.getPreserveId() == 2){
			sb.append("<option value='2' selected>2년</option>");
		}else{
			sb.append("<option value='2'>2년</option>");
		}
		
		if(item.getPreserveId() == 3){
			sb.append("<option value='3' selected>3년</option>");
		}else{
			sb.append("<option value='3'>3년</option>");
		}
		
		if(item.getPreserveId() == 5){
			sb.append("<option value='5' selected>5년</option>");
		}else{
			sb.append("<option value='5'>5년</option>");
		}
		
		if(item.getPreserveId() == 10){
			sb.append("<option value='10' selected>10년</option>");
		}else{
			sb.append("<option value='10'>10년</option>");
		}
		
		if(item.getPreserveId() == 99){
			sb.append("<option value='99' selected>영구보존</option>");
		}else{
			sb.append("<option value='99'>영구보존</option>");
		}
		sb.append("/<select>");
		preserveId = sb.toString();
		sb.setLength(0);
		//preserveId = Integer.toString(item.getPreserveId());
		
		cell.add(category);
        cell.add(subject);            
        cell.add(keepDate);
        cell.add(preserveId);
        
        cellObj.put("cell",cell);    
        cell.clear();    
        cellArray.add(cellObj);    
	}
    jsonData.put("rows",cellArray);
    out.println(jsonData);
%>
