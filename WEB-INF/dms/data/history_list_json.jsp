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
	String locale = (String)request.getAttribute("locale");
	
    JSONObject jsonData =new JSONObject();    
    jsonData.put("total", listPage.getPageCnt());
    jsonData.put("page", listPage.getPage());
    jsonData.put("records", listPage.getTotalCnt());
    
    JSONArray cellArray=new JSONArray();
    JSONArray cell = new JSONArray();     
    JSONObject cellObj=new JSONObject();    
    
	java.util.List<DmsHistory> items = listPage.getItems();
	String category, subject, createDate, writer, hisType, fileCnt, readCnt, hotFlag;
	int idx = items.size();
	for(int i=0; i<idx; i++){
		DmsHistory item = items.get(i);
// 		cellObj.put("id", item.getId().getDocId());
// 		cellObj.put("hisNo", item.getId().getHisNo());
		StringBuilder sb = new StringBuilder();
		try {
			category = item.getDmsCategory().getCatName(locale);
		} catch (Exception e) {
			category = "미분류";
		}
		
		if(item.isHotFlag()){	//중요
			sb.append("<img title='중요' src='/common/images/vwicn181.gif' align='absmiddle' border='0'>");
		}else{
			sb.append("");
		}
		hotFlag = sb.toString();
		sb.setLength(0);
		
		createDate = (dspformatter.format(item.getHisDate())).substring(0, 16).toString();
		
		//sb.append("<a href='javascript:goSubmit(\"view\", \"true\", \"").append(item.getDocId()).append("\");'>")
		sb.append("<img src='../common/images/btn_listdot.gif' border='0'></a>");
	
		if (item.getReadCnt() > 30 ) {
// 			sb.append("<img src='/common/images/b_ks.gif' align=absmiddle>");
		}
		//sb.append("<img src='../common/images/reicon.gif' border='0' align='absmiddle'>");
		sb.append("<a href='javascript:goSubmit(\"view\", \"true\", \"").append(item.getId().getDocId()).append("\", \"").append(item.getId().getHisNo()).append("\");'>");
// 		sb.append("<a href='javascript:onClickOpen(\"").append(item.getDocId()).append("\");'>");
		
		if (lToday - item.getCreateDate().getTime() < DAY_TIME) {
			sb.append("<b>").append(item.getSubject()).append("</b>");
		} else {
			sb.append(item.getSubject());
		}
		subject = sb.toString();
		sb.setLength(0);
		
		//
		String hisTypeNm = "";
		if(item.getHisType().equals("U")){
			hisTypeNm = "수정";
		}else if(item.getHisType().equals("D")){
			hisTypeNm = "삭제";
		}
		sb.append(hisTypeNm);
		hisType =sb.toString();
		sb.setLength(0);
		
		sb.append("<a href='javascript:ShowUserInfo(\"").append(item.getOwUser().getUserId()).append("\");'>")
				.append("<img src='../common/images/man_info.gif' border='0' align='absmiddle'>")
				.append(item.getOwUser().getnName()).append("</a>");
		writer = sb.toString();
		
		if ("20140409161336".equals(item.getCatId())) {
			writer = "익명";
		}
		
		sb.setLength(0);
		
		if (item.getFileCnt() > 0){
			sb.append("<img src='../common/images/icons/ico_file.gif'")
				.append(" onclick='javascript:ShowAttach(\"")
				.append(item.getId().getDocId()).append("\");'")
				.append(" style='cursor:hand;' />");
			fileCnt = sb.toString();
			sb.setLength(0);
	 	} else {
	 		fileCnt = "";
	 	}
		
		readCnt = Integer.toString(item.getReadCnt());
		
		String cateType = "";
		if(item.getCateType().equals("S")){
			cateType =  "공용";
		}else if(item.getCateType().equals("P")){
			cateType = "개인";
		}else if(item.getCateType().equals("D")){
			cateType = "부서";
		}
		
        cell.add(item.getId().getDocId());
        cell.add(item.getId().getHisNo());
		cell.add(cateType);
		cell.add(category);
		cell.add(hotFlag);
        cell.add(subject);
        cell.add(hisType);
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
