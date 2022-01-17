<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page errorPage="../error.jsp"%>
<!DOCTYPE html>
<html>
<head>
<title></title>
<%@ include file="../common/include.jquery.jsp"%>
<%@ include file="../common/include.jquery.form.jsp"%>
<%@ include file="../common/include.common.jsp"%>
<script src="/common/scripts/organization_selector.js"></script>
<script type="text/javascript">
	function goSubmit(cmd) {
		var frm = document.getElementById("dmsWebForm");
		switch (cmd) {
		case "new":
			self.location.href = "./categoryForm.htm?catId="
					+ "&cateType=${dmsWebForm.search.cateType }"
					+ "&pCategoryId=${dmsWebForm.search.catId }"
					+ "&pCatFullName=";
			return;
			break;
		case "list":
			self.location.href = "./categoryList.htm?cmd=<c:out value="${dmsWebForm.search.cmd}"/>"
					+ "&pCategoryId=<c:out value="${dmsWebForm.search.pCategoryId}"/>"
					+ "&cateType=<c:out value="${dmsWebForm.search.cateType}"/>";
			return;
			break;
		case "delete":
			if (!confirm("<spring:message code='c.delete' text='삭제 하시겠습니까?' />")) return;
			frm.command.value = "deletepost";
			frm.method = "POST";
			frm.action = "./categoryDelete.htm";
			break;
		case "post":
			if (!inputValidation()) return;
			if (!confirm("<spring:message code='c.save' text='저장 하시겠습니까?' />")) return;
			selectAll(frm.sharelist);
			frm.method = "POST";
			frm.action = "./categorySave.htm";
			break;
		}
		frm.submit();
	}

	// SELECT > OPTION 전체 선택
	function selectAll(selObj) {
		if (selObj.type == "select-multiple") {
			for (var i = 0; i < selObj.length; i++) {
				selObj.options[i].selected = true;
			}
		}
	}

	// 상위분류 검색 (window.showModalDialog Version)
	function findCategoryInfoModal() {
		var winwidth = "300";
		var winheight = "450";
		var cateType = document.getElementById("search.cateType").value;
		var url = "./categoryTree.htm?openmode=1&winname=opener&conname=document.submitForm&isadmin=1&cateType=" + cateType;
		rValue = window.showModalDialog(url, "", "status:no;scroll:no;center:yes;help:no;dialogWidth:" + winwidth + "px;dialogHeight:" + winheight + "px");
		if (rValue != null) {
			var frm = document.getElementById("dmsWebForm");
			frm.newpcatid.value = rValue[1];
			if (rValue[0] == "" || rValue[0] == null)
				frm.newpcatfullname.value = "[<spring:message code='t.category.top' text='최상위분류' />]";
			else
				frm.newpcatfullname.value = rValue[0];
		}
	}

	// 상위분류 검색 (dhtmlmodal Version)
	function findCategoryInfo() {
// 		var cateType = document.getElementById("search.cateType").value;
		var url = "./categoryTree.htm?openmode=1&winname=opener&conname=document.submitForm&isadmin=1"
				+ "&cateType=${dmsWebForm.search.cateType }"
				+ "&cateGubun=${dmsWebForm.search.cateGubun }";
		
		window.modalwindow = window.dhtmlmodal.open("_CHILDWINDOW_DMS1001", "iframe", url,
				"<spring:message code='t.doc.management' text='문서관리' />",
				"width=300px,height=450px,resize=0,scrolling=1,center=1", "recal");
	}

	// 상위분류 검색 결과값 적용
	function setCategoryInfo(rValue) {
		if (rValue != null) {
			var frm = document.getElementById("dmsWebForm");
			frm.newpcatid.value = rValue[1];
			if (rValue[0] == "" || rValue[0] == null)
				frm.newpcatfullname.value = "[<spring:message code='t.category.top' text='최상위분류' />]";
			else
				frm.newpcatfullname.value = rValue[0];
		}
	}

	// 양식 유효성 검사
	function inputValidation() {
		var frm = document.getElementById("dmsWebForm");
		
		if (TrimAll(frm.newpcatid.value) == "") {
			alert("<spring:message code='dms.choose.topcate' text='상위분류를 선택해 주세요' />");
			return false;
		}
		if (TrimAll(document.getElementsByName("dmsCategory.catName")[0].value) == "") {
			alert("<spring:message code='appr.c.category' text='분류명을 입력해 주세요' />");
			document.getElementById("dmsCategory.catName").focus();
			return false;
		}
		if (document.getElementById("sharelist").options.length < 1 
				&& !$("input:checkbox[name='openFlag']").is(":checked")) {
			alert("<spring:message code='dms.allshare.or.target' text='전체공유 또는 공유대상을 지정해 주세요.' />");
			return false;
		}
		return true;
	}

	$(document).ready(function() {
		
		if ('${dmsWebForm.search.cateType}' == 'P') {
			Organizations.setViewDivStyle(function(div) {
				div.css({
					"display" : "none"
				});
			});
		}
		
		if ('${dmsWebForm.search.cateType}' == 'S') {
			Organizations.Item = [ "type", "userid", "username", "dpid", "dpname", "includeSub", "upname", "udname" ];
			Organizations.formatAddressList(["sharelist", "userlist"]);
			
			$('#sharelist').bind('dblclick', function() {
				var title = '<spring:message code="t.organization.chart" text="조직도" />';
				var caption = '<spring:message code="t.select.sharer" text="공유자 선택" />';
				Organizations.open('sharelist', title, caption, 0, 0, 1);
			});
	
			$('#userlist').bind('dblclick', function() {
				var title = '<spring:message code="t.organization.chart" text="조직도" />';
				var caption = '<spring:message code="t.select.sharer" text="담당자 선택" />';
				Organizations.open('userlist', title, caption, 1, 0, 1);
			});
		}
		
		// 최상위 분류시 동작
		var catId = '${dmsWebForm.search.catId }';
		if (catId == '00000000000000') {
			$("#btnCateSave").hide(); // 저장 안됨
			$("#btnParentCateSearch").hide(); // 상위분류 검색 안됨
			$("input[name='newpcatfullname']").addClass("ui-state-disabled").attr("readonly", "readonly"); // 상위분류 변경 안됨
			$("input[name='dmsCategory.catName']").attr("readonly", "readonly"); // 분류명 변경 안됨
			$("input[name='dmsCategory.orders']").addClass("ui-state-disabled").attr("readonly", "readonly"); // 순서 변경 안됨
			$('#userlist_view').addClass("ui-state-disabled").css({"cursor":"default"}).unbind('click'); // 담당자 권한 없음
			$('#sharelist_view').addClass("ui-state-disabled").css({"cursor":"default"}).unbind('click'); // 공유대상 권한 없음
		}
		
		// 최상위 분류 직속 하위 분류시 동작
		var pcatId = '${dmsWebForm.dmsCategory.pCatId }';
		var isDamD = ${dmsWebForm.dmsCategory.pCatId != '00000000000000' || dmsWebForm.search.cateGubun == 'C' }; // 담당자 여부
		if (pcatId == '00000000000000' && isDamD) {
			$("#btnCateSave").hide(); // 저장 안됨
			$("#btnParentCateSearch").hide(); // 상위분류 검색 안됨
			$("input[name='newpcatfullname']").addClass("ui-state-disabled").attr("readonly", "readonly"); // 상위분류 변경 안됨
			$("input[name='dmsCategory.orders']").addClass("ui-state-disabled").attr("readonly", "readonly"); // 순서 변경 안됨
		}
		
		// 트리에서 호출되지 않았다면 선택된 항목의 상위를 다시 불러옴
		// 상위분류가 변경이 된 경우라면 2군대에서 다시 불러와야 함 (미작업)
		if ($.urlParam("isSelect") == "true") {
			
		} else {
			try {
				var tree = window.parent.frames[2];
				var target = tree.t_node.parent;
				if (target.data.datas == undefined) target = tree.t_node;
				target.reloadChildren();
			} catch(ex) {
				console.log(ex);
			}
		}

		// 왼쪽 메뉴를 다시 호출
		switch('${dmsWebForm.search.cateType}') {
			case 'P': top.reTreeMenu("code_MENU0305"); break;
			case 'S': 
				if ('${dmsWebForm.search.cateGubun }' == 'C') {
					top.reTreeMenu("code_MENU0305"); 
				} else {
					top.reTreeMenu("code_MENU0304"); 
				}
				break;
		}
	});

	$.urlParam = function(name){
	    var results = new RegExp('[\\?&amp;]' + name + '=([^&amp;#]*)').exec(window.location.href);
	    return (results)? results[1]: 0;
	}
</script>
</head>
<body style="margin-right: 10px; margin-left: 10px;">
<form:form commandName="dmsWebForm" onsubmit="return false;">
<input type="hidden" name="command" value="newpost">
<form:hidden path="search.catId" />
<form:hidden path="search.cateType" />
<form:hidden path="search.cmd" />
<form:hidden path="dmsCategory.includeSub" value="false" />
<form:hidden path="dmsCategory.enable" value="true" />
<input type="hidden" name="pCategoryId" value="<c:out value="${dmsWebForm.search.pCategoryId }"/>" />
<input type="hidden" name="pCatFullName" value="<c:out value="${dmsWebForm.search.pCatFullName }"/>" />
<input type="hidden" name="newpcatid" value="<c:out value="${pCatId }"/>">

<!-- 수행버튼 시작 -->
<table width="100%" cellspacing="0" cellpadding="0" border="0" id=btntbl>
	<tr>
		<td align="right">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" style="">
				<tr>
					<td width="*"><span><b>[<spring:message code='emp.basic.info' text='기본정보' />]</b></span></td> <%-- <c:out value="${dmsWebForm.search.pCatFullName }" /> --%>
					<td width="300" align="right">
					
						<c:if test="${fn:length(dmsWebForm.dmsCategory.id.catId) > 0 }">			
						<a onclick="goSubmit('new','');" class="button white medium">
						<img src="../common/images/bb02.gif" border="0"> <spring:message code='dms.crete.subcategory' text='하위 분류 생성' />  </a>
						</c:if>
						
						<a id="btnCateSave" onclick="goSubmit('post');" class="button white medium">
						<img src="../common/images/bb02.gif" border="0"> <spring:message code='t.save' text='저장' /> </a>
						
						<c:if test="${fn:length(dmsWebForm.dmsCategory.id.catId) > 0 && dmsWebForm.docCnt == 0 && fn:length(dmsWebForm.dmsCategory.childDmsCats) == 0 }">
						<a onclick="goSubmit('delete');" class="button white medium">
						<img src="../common/images/bb02.gif" border="0"> <spring:message code='t.delete' text='삭제' /> </a>
						</c:if>
						
						<a onclick="goSubmit('list');" class="button white medium" style="display:none;">
						<img src="../common/images/bb02.gif" border="0"> <spring:message code='t.list' text='목록' /> </a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<!-- 수행버튼 끝 -->

<table class="tblspace05"><tr><td></td></tr></table>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<colgroup>
		<col width="140">
		<col width="*">
	</colgroup>
	<tr>
		<td class="td_le1"><spring:message code='t.pcategory' text='상위분류' /> <span class="readme"><b>*</b></span></td>
		<td class="td_le2">
			<input type="text" name="newpcatfullname" value="<c:out value="${pCatFullName }"/>" readonly style="width: 300px;">
			<a id="btnParentCateSearch" onclick="findCategoryInfo()" class="button white medium">
			<img src="../common/images/bb02.gif" border="0"> <spring:message code='t.search' text='search' /> </a>
		</td>
	</tr>
	<tr>
		<td class="td_le1"><spring:message code='t.category' text='분류명' /> <span class="readme"><b>*</b></span></td>
		<td class="td_le2">
			<form:input path="dmsCategory.catName" onKeyUp="CheckTextCount(this, 80);" style="width:200px;" maxlength="50" />
		</td>
	</tr>
	<tr>
		<td class="td_le1"><spring:message code='t.order' text='정렬순서' /></td>
		<td class="td_le2"><form:input path="dmsCategory.orders" /></td>
	</tr>
</table>

<c:choose>
	<c:when test="${dmsWebForm.search.cateType =='P' }">
		<div style="display:none;">
			<select id="sharelist" name="sharelist" style="width: 0px; height: 0px;" multiple>
				<option value="P:<c:out value="${user.userId}"/>:<c:out value="${user.nName}"/>:<c:out value="${user.userPosition.upName}"/>:<c:out value="${user.department.dpName}"/>"></option>
			</select>
		</div>
	</c:when>
	<c:otherwise>
		<br>
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<caption style="text-align:left;line-height:180%;font-weight:bold;">
				[<spring:message code='t.permission' text='권한' />]
			</caption>
			<colgroup>
				<col width="140">
				<col width="*">
			</colgroup>
			
			<c:if test="${dmsWebForm.dmsCategory.pCatId != '00000000000000' || dmsWebForm.search.cateGubun == 'C' }">
				<c:set var="userDisplay" value="style=display:none" />
			</c:if>
			<tr <c:out value="${ userDisplay }"/>>
				<td class="td_le1"><spring:message code='v.contact' text='담당자' /></td>
				<td class="td_le2">
					<select id="userlist" name="userlist" style="width:80%;height:80px;display:none;" multiple="multiple">
					<c:forEach var="userItem" items="${dmsWebForm.dmsCategory.cateUsersList }">
						<option value="P:${userItem.user.userId }:${userItem.user.nName }:${userItem.user.department.dpId }:${userItem.user.department.dpName }::${userItem.user.userPosition.upName }">
							<c:out value="${userItem.user.nName }" />
						</option>
					</c:forEach>
					</select>
				</td>
			</tr>
			
			<c:if test="${fn:length(dmsWebForm.dmsCategory.id.catId)> 0 }">
				<c:set var="authDisplay" value="style=display:none" />
			</c:if>
			<tr <c:out value="${ authDisplay }"/>>
				<td class="td_le1"><spring:message code='addr.share.div' text='공유구분' /></td>
				<td class="td_le2">
					<form:checkbox path="openFlag" value="1" />
					<spring:message code='addr.share.entire' text='전체공유' />
				</td>
			</tr>
			<tr id="divShareList">
				<td class="td_le1">
					<spring:message code='t.share.target' text='공유대상' />
					<span class="readme"><b>*</b></span>
				</td>
				<td class="td_le2">
					<select id="sharelist" name="sharelist" style="width:80%;height:80px;display:none;" multiple="multiple">
						<c:forEach var="shareItem" items="${dmsShareList }">
							<c:out value="${shareItem.shareValue}" />
							<option value="<c:out value="${shareItem.shareValue}"/>">
								<c:out value="${shareText }" />
							</option>
						</c:forEach>
					</select>
				</td>
			</tr>
		</table>
	</c:otherwise>
</c:choose>

<c:if test="${dmsWebForm.dmsCategory.id.catId != null }">
<br>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<caption style="text-align:left;line-height:180%;">
		<span class="readme"><b>*</b></span>
		<spring:message code='dms.zero.delete' text='분류의 보유문서와 하위분류가 0건인 경우에만 삭제할 수 있습니다.' />
	</caption>
	<colgroup>
		<col width="140">
		<col width="*">
	</colgroup>
	<tr>
		<td class="td_le1"><spring:message code='dms.hold.document' text='보유 문서' /></td>
		<td class="td_le2">${dmsWebForm.docCnt } <spring:message code='main.ea' text='건' /></td>
	</tr>
	<tr>
		<td class="td_le1"><spring:message code='dms.sub.division' text='하위 분류' /></td>
		<td class="td_le2">${fn:length(dmsWebForm.dmsCategory.childDmsCats) } <spring:message code='main.ea' text='건' /></td>
	</tr>
</table>
</c:if>

</form:form>
</body>
</html>