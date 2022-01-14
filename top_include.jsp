<%@ page contentType="text/html;charset=utf-8" %>
<%@ page import = "nek.common.login.*" %>
<%
String passwd = "";
boolean isAdmin = loginuser.securityId >= 9;
boolean isPartner = loginuser.securityId == 0;
boolean isPartnerTemp = loginuser.securityId == 8;
String loginId = loginuser.loginId;
/* LoginUser li = loginuser;
String login_id=""; */
%>
<style type="text/css">
.ui-dialog { position: absolute; border: 2px solid #446f92; padding:1px; }
/* .ui-widget-header { */
/* 	border: 0px solid #4297D7; */
/* 	background: #5C9CCC url(/common/images/f1_bg.png) 50% 50% repeat-x; */
/* 	color: white; */
/* 	font-weight: bold; */
/* } */

.ui-dialog .ui-dialog-titlebar {
padding: 7px 0px 7px 10px;
position: relative;
}

.ui-dialog .ui-dialog-content {
padding: .5em 0.5em;
overflow: hidden;
}

#megamenu1 ul li {cursor:pointer;}
#megamenu1 ul li a {font-size: 12px; font-weight: bold;}


ul.ui-menu {
	list-style-type: none;
	margin:5px;
	white-space:pre;
}

li.ui-menu-item {
	vertical-align:top;
	padding:3px;
	//width:400px;
	height:72px;
	float:left;
}

li.ui-menu-item a {
	text-decoration:none;
	padding:3px;
	padding-top:0px;
	line-height:16px;
	cursor:pointer;
	width:219px;
}

.ui-autocomplete-loading { background: white url('/common/images/ui-anim_basic_16x16.gif') right center no-repeat; }
	.ui-autocomplete {
		max-height: 300px;
		overflow-y: auto;
		/* prevent horizontal scrollbar */
		overflow-x: hidden;
		/* add padding to account for vertical scrollbar */
		padding-right: 0px;
		width:320px;
		z-index: 200;
	}
	/* IE 6 doesn't support max-height
	 * we use height instead, but this forces the menu to always be this tall
	 */
	* html .ui-autocomplete {
		height: 300px;
		width: 320px;
		text-align:left;
	}
ul.ui-autocomplete ul.ui-menu ul.ui-widget ul.ui-widget-content ul.ui-corner-all {
width:320px; 
height:300px; 
overflow-y: auto;
}

/*20210714 출퇴근 UI신규 추가 관련 style*/
.user_info_right .work{display:none;}
table tr td.work{color:#fff;font-family:sans-serif;text-align:left;padding-left: 5px;float:left;height:45px;line-height: 49px;}
table tr td.work .btn_work_div{background:#ededed;position:relative;height:25px;line-height: 25px;margin-top:10px;padding:0 12px 0 28px;border-radius:12px;font-weight:600;letter-spacing: -1px;font-size:9pt;}
table tr td.work_off .btn_work_div{background:#ed4b5f; color:#fff;}
table tr td.work span{font-family:malgun gothic;font-size:9pt;vertical-align: middle;}
table tr td.work img{vertical-align: middle;position:absolute;left:3px;top:2px;height:20px;}
div#menu{background:#7795bb !important;}
div#menu li.back {width:0 !important;height:0 !important;}  
.work_finish{display:none;}
.working{display:none;}

/*20220114*/
.left_centent_box{    position: relative;
    top: 20px;
    margin-top: 0;
    z-index: 3;}
</style>
<script src="/common/scripts/WebTree.js"></script>
<script src="/common/scripts/common.js"></script>
<!-- <script src="/common/scripts/index.js"></script> -->
<!-- `.js`사용하지 않고 처리 -->

<link rel='stylesheet' type='text/css' href='/common/jquery/plugins/dynatree/skin-vista/ui.dynatree.css'>
<script src='/common/jquery/plugins/dynatree/jquery.dynatree.js' type="text/javascript"></script> 
<script src='/common/jquery/plugins/dynatree/config.dynatree.js' type="text/javascript"></script> 

<link rel='stylesheet' type='text/css' href='/common/css/common.css'><!----2021리뉴얼추가---->

<script>
var popupWinCnt = 0;
//main page open doc

var message_community = "<fmt:message key='bbs.community' />"; // 커뮤니티 
var message_approval = "<fmt:message key='main.Approval' />"; // 전자결재 
var message_document = "<fmt:message key='main.Document.Management' />"; // 문서관리 
var message_mailread = "<fmt:message key='mail.read' />"; // 메일읽기 
var message_message = "<fmt:message key='main.Message' />"; // 쪽지 

function openBbs(cmd, isNewWin ,bbsId, docId){
	var url = "/bbs/read.htm?bbsId=" + bbsId + "&docId=" + docId;
	//url += "&useNewWin=true&useLayerPopup=false";
//	var winName = "popup_" + popupWinCnt++;
//	OpenWindow(url, winName, "800", "610");
//	return;
	
	if(isNewWin == "true"){
		url += "&useNewWin=true&useLayerPopup=false";
		var winName = "popup_" + popupWinCnt++;
		OpenWindow(url, winName, "760", "610");
		
		//var a = ModalDialog({'t':'document title', 'modal':false, 'w':800, 'h':500, 'm':'iframe', 'u':url});
	} else {	//self
		url += "&useNewWin=false&useLayerPopup=true";
		//alert(url);
     if (typeof dhtmlwindow == "undefined") {
//  		var a = ModalDialog({'t':message_community, 'modal':false, 'w':800, 'h':500, 'm':'iframe', 'u':url});
    	 OpenWindow(url, message_community, "800", "500");
     } else {
    	 OpenWindow(url, message_community, "800", "500");
// 			parent.dhtmlwindow.open(
// 				url, "iframe", url, message_community, 
// 				"width=800px,height=500px,resize=1,scrolling=1,center=1", "recal"
// 			);
     }
	}
}

function openBbsWidget(cmd, isNewWin, type, bbsId, docId){
	var url = "";
	if(type == "board"){
		url ="/bbs/read.htm?bbsId=" + bbsId + "&docId=" + docId;
	}else{
		url = "/bbswork/read.htm?docId=" + docId;
	}
	
	if(isNewWin == "true"){
		url += "&useNewWin=true&useLayerPopup=false";
		var winName = "popup_" + popupWinCnt++;
		OpenWindow(url, winName, "760", "610");
		
		//var a = ModalDialog({'t':'document title', 'modal':false, 'w':800, 'h':500, 'm':'iframe', 'u':url});
	} else {	//self
		url += "&useNewWin=false&useLayerPopup=true";
		//alert(url);
        if (typeof dhtmlwindow == "undefined") {
    		var a = ModalDialog({'t':'community', 'modal':false, 'w':800, 'h':500, 'm':'iframe', 'u':url});
        } else {
 			parent.dhtmlwindow.open(
				url, "iframe", url, "community", 
				"width=800px,height=500px,resize=1,scrolling=1,center=1", "recal"
			);
        }
	}
}

function openBbsWork(cmd, isNewWin, docId){
	var url = "/bbswork/read.htm?docId=" + docId;
	//url += "&useNewWin=true&useLayerPopup=false";
//	var winName = "popup_" + popupWinCnt++;
//	OpenWindow(url, winName, "800", "610");
//	return;
	
	if(isNewWin == "true"){
		url += "&useNewWin=true&useLayerPopup=false";
		var winName = "popup_" + popupWinCnt++;
		OpenWindow(url, winName, "760", "610");
		
		//var a = ModalDialog({'t':'document title', 'modal':false, 'w':800, 'h':500, 'm':'iframe', 'u':url});
	} else {	//self
		url += "&useNewWin=false&useLayerPopup=true";
		//alert(url);
     if (typeof dhtmlwindow == "undefined") {
		OpenWindow(url, message_community, "800", "500");
//  		var a = ModalDialog({'t':message_community, 'modal':false, 'w':800, 'h':500, 'm':'iframe', 'u':url});
     } else {
		OpenWindow(url, message_community, "800", "500");
// 			parent.dhtmlwindow.open(
// 				url, "iframe", url, message_community, 
// 				"width=800px,height=500px,resize=1,scrolling=1,center=1", "recal"
// 			);
     }
	}
}

function goApprIng(apprtype, isNewWin, apprid, popcheck)
{
	var UrlStr = "";
 if( apprtype == "3" ){
 	UrlStr = "/approval/apprdoc.htm?menu=340&apprId="+apprid+"&pop=" + popcheck ;
 }else{
 	UrlStr = "/approval/apprdoc.htm?menu=240&apprId="+apprid+"&pop=" + popcheck ;
 }
 
 if(isNewWin == "true"){
 	UrlStr += "&useNewWin=true&useLayerPopup=false";
		var winName = "popup_" + popupWinCnt++;
		OpenWindow(UrlStr, winName, "800", "550");
	} else {	//self
		UrlStr += "&useNewWin=false&useLayerPopup=true";
		//alert(url);
     if (typeof dhtmlwindow == "undefined") {
    	 OpenWindow(UrlStr, message_approval, "800", "550");
//  		var a = ModalDialog({'t':message_approval, 'modal':false, 'w':800, 'h':550, 'm':'iframe', 'u':UrlStr});
     } else {
    	 OpenWindow(UrlStr, message_approval, "820", "550");
// 			parent.dhtmlwindow.open(
// 				UrlStr, "iframe", UrlStr, message_approval, 
// 				"width=820px,height=550px,resize=1,scrolling=1,center=1", "recal"
// 			);
     }
	}
}

function openDms(cmd, isNewWin, docId)
{
	var url = "/dms/read.htm?docId=" + docId;
	
	if(isNewWin == "true"){
		url += "&useNewWin=true&useLayerPopup=false";
		var winName = "popup_" + popupWinCnt++;
		OpenWindow(url, winName, "760", "610");
		
		//var a = ModalDialog({'t':'document title', 'modal':false, 'w':800, 'h':500, 'm':'iframe', 'u':url});
	} else {	//self
		url += "&useNewWin=false&useLayerPopup=true";
     if (typeof dhtmlwindow == "undefined") {
 		var a = ModalDialog({'t':message_document, 'modal':false, 'w':800, 'h':500, 'm':'iframe', 'u':url});
     } else {
			parent.dhtmlwindow.open(
				url, "iframe", url, message_document, 
				"width=800px,height=500px,resize=1,scrolling=1,center=1", "recal"
			);
     }
	}
}

//front mail open
function OnClickOpenMail(messageName)
{
	 var WinWidth = 1000 ;
	 var WinHeight = 500 ;
	 var winleft = (screen.width - WinWidth) / 2;
	 var wintop = (screen.height - WinHeight) / 2;
	 var UrlStr = "/mail/mail_read.jsp?front=&message_name=" + messageName ;
	 if (typeof dhtmlwindow == "undefined") {
		 OpenWindow(UrlStr, "", WinWidth, WinHeight);
//	      var win = window.open(UrlStr , "" , "scrollbars=yes,width="+ WinWidth +", height="+ WinHeight +", top="+ wintop +", left=" + winleft  );
	 } else {
		 OpenWindow(UrlStr, "", WinWidth, WinHeight);
//	 			parent.dhtmlwindow.open(
//	 				UrlStr, "iframe", UrlStr, message_mailread, 
//	 			"width="+WinWidth+"px,height="+WinHeight+"px,resize=1,scrolling=1,center=1", "recal"
//	 		);
	 }
}

//front noty open
function OnClickOpenNote(boxID, noteID) {
	var WinWidth = 850 ; 
	var WinHeight = 500 ; 
	var winleft = (screen.width - WinWidth) / 2;
	var wintop = (screen.height - WinHeight) / 2;
	var UrlStr = "/notification/read.htm?newwin=&noteId=" + noteID + "&boxId=" +boxID+"&indexMain=Y" ;
 if (typeof dhtmlwindow == "undefined") {
	 OpenWindow(UrlStr, "", WinWidth, WinHeight);
//  	var win = window.open(UrlStr , "" , "scrollbars=yes,width="+ WinWidth +", height="+ WinHeight +", top="+ wintop +", left=" + winleft  );
 } else {
	 OpenWindow(UrlStr, "", WinWidth, WinHeight);
// 			parent.dhtmlwindow.open(
// 				UrlStr, "iframe", UrlStr, message_message, 
// 			"width="+WinWidth+"px,height="+WinHeight+"px,resize=1,scrolling=1,center=1", "recal"
// 		);
 }
}
</script>

<script src="/common/jquery/plugins/jquery.cookie.js"></script>
<script src="/common/jquery/plugins/noty-master/js/noty/jquery.noty.js"></script>
<script src="/common/jquery/plugins/noty-master/js/noty/promise.js"></script>
<script src="/common/jquery/plugins/noty-master/js/noty/themes/default.js"></script>
<script src="/common/jquery/plugins/noty-master/js/noty/layouts/topRight.js"></script>
<script src="/common/jquery/plugins/noty-master/js/noty/layouts/bottomRight.js"></script>
<script src="/common/jquery/plugins/noty-master/js/noty/layouts/bottom.js"></script>
<script src="/common/jquery/plugins/noty-master/js/noty/layouts/bottomCenter.js"></script>
<script type="text/javascript">

var nIntervId;

var isiPad = (navigator.userAgent.toLowerCase().indexOf("ipad") > -1);

$(document).ready(function() {
	
	
	$('input[name=loginId]').bind('keydown',function(e){
		if (e.keyCode == $.ui.keyCode.ENTER) {
			var val = $(this).val();
			$(this).val("");
			$.post('/polymorph.htm',{loginId: val},function(data){
				$('#nNameTxt').text($(data).find("#userName").text());
				$('#upNameTxt').text($(data).find("#upName").text());
				$('#dpNameTxt').text($(data).find("#dpName").text());
			});
		}
	});

	if (nIntervId == null) mailCheckDate();							// 최초 신규 메일 체크. 
	nIntervId = setInterval(mailCheckDate, (3 * 60 * 1000));		// 2분마다 신규 메일 체크 (반복).

	// 세션유지시간을 제한하기 위하여 주석처리됨 2015-03-06
	setInterval(sessionCheck, (30 * 1000));	//30초마다 세션유지한다
	
	var get_status = "";
	var get_worktime_s = "";
	var get_worktime_e = "";
	var get_message = "";
	var dd = "";
	var getUrl = "/getAPI.do";
	var getLatitude='';
	var getLongitude='';
	
	// Geolocation API에 액세스할 수 있는지를 확인
    if (navigator.geolocation) {
        //위치 정보를 얻기
        navigator.geolocation.getCurrentPosition (function(pos) {
        	getLatitude=pos.coords.latitude;     // 위도
        	getLongitude=pos.coords.longitude; // 경도
        });
    } else {
        alert("이 브라우저에서는 Geolocation이 지원되지 않습니다.");
    }
	
	// pad 등 , 모바일 타블릿에서 메뉴 클릭 시 없어지도록 하기 위해 : 2013-08-27 김정국
	$('.ul_sub_menu').find('li').click( function() {
		//$(this).parent().toggle();
		$(this).parent().css("display", "none");
		
	});
	
	$('.ul_sub_menu').parent().click( function() {
		$(this).find('ul_sub_menu').css("display", "visible");
	});
	$(".btn_work_div").click(function(){
		var gubun=0;
		
		var ids="";
		ids=$(this).attr("id");
		
		if(ids=="work_start_btn") gubun=1;
		else if(ids=="work_continue_btn") gubun=2;
		else gubun=3;
		
		$.ajax({
			type:'post',
			url	:"/sendAPI.do",
			data:{"wgb":gubun,"latitude":getLatitude,"longitude":getLongitude},
			dataType: 'json',
			success:function(data){
				var state=data.status;
				var worktime_s=data.worktime_s;
				var worktime_e=data.worktime_e;
				var message=data.message;
				
				if(state=='01'){
					if(gubun==1){
						alert("업무시작 처리 하였습니다.");
						get_worktime_s=worktime_s.substring(8,10)+":"+worktime_s.substring(10,12);
						get_worktime_e=worktime_e.substring(8,10)+":"+worktime_e.substring(10,12);
						$('#worktime_s').html("출근 "+get_worktime_s);
						$('#worktime_e').html("");
						$(".work_finish").css("display","none");
						$(".working").css("display","block");
						$(".work_2").css("display","block");
					}else if(gubun==2){
						alert("근무체크 처리 하였습니다.");
						get_worktime_s=worktime_s.substring(8,10)+":"+worktime_s.substring(10,12);
						get_worktime_e=worktime_e.substring(8,10)+":"+worktime_e.substring(10,12);
						$('#worktime_s').html("출근 "+get_worktime_s);
						$('#worktime_e').html("");
						$(".work_finish").css("display","none");
						$(".working").css("display","block");
						$(".work_2").css("display","block");
					}else{
						alert("업무종료 처리 하였습니다.");
						$('#worktime_s').html("출근 "+get_worktime_s);
						$('#worktime_e').html(" / 퇴근 "+get_worktime_e);
						$(".work_finish").css("display","block");
						$(".working").css("display","block");
						$(".work_2").css("display","none");
					}
				}else if(state=='99'){
					alert("인증키 오류입니다.");
				}else if(state=='9999'){
					alert("출근 정보 로드 오류입니다. : "+message);
				}else{
					alert("처리중 오류가 발생했습니다. : "+message);
				}
			},
			error:function(jqXHR,status,err){
				alert("처리중 오류가 발생했습니다.");
			}
		});
	});
	
	$.ajax({
		type:'post',
		url	: getUrl,
		data:{"latitude":getLatitude,"longitude":getLongitude},
		dataType: 'json',
		success:function(data){
			var rs=data;
			get_status=rs.status;
			get_message=rs.message;
			if(get_status=="01"){
				if(rs.worktime_s) get_worktime_s=rs.worktime_s.substring(8,10)+":"+rs.worktime_s.substring(10,12);
				if(rs.worktime_e) get_worktime_e=rs.worktime_e.substring(8,10)+":"+rs.worktime_e.substring(10,12);
			}
			
			if(get_worktime_s){
				if(get_worktime_e){
					$('#worktime_s').html("출근 "+get_worktime_s);
					$('#worktime_e').html(" / 퇴근 "+get_worktime_e);
					$(".work_finish").css("display","none");
					$(".working").css("display","block");
					$(".work_2").css("display","none");
				}else{
					$('#worktime_s').html("출근 "+get_worktime_s);
					$('#worktime_e').html("");
					$(".work_finish").css("display","none");
					$(".working").css("display","block");
					$(".work_2").css("display","block");
				}
			}else{
				$(".work_finish").css("display","block");
				$(".working").css("display","none");
				$(".work_2").css("display","none");
			}
		},
		error:function(jqXHR,status,err){
			alert("처리중 오류가 발생했습니다.");
		}
	});
});

function sessionCheck(){
	$.ajax({
		url: '/test.jsp',
		cache: false,
		success: function(str) {
		}
	});
}

// 메일 체크. 
function mailCheckDate() {
	
	$.ajax({
		url: '/mail/data/mail_check_date_last.jsp',
		cache: false,
		success: function(str) {
			var data = eval("("+$.trim(str)+")");
			var newDate = data.date;
			var oldDate = $.cookie('nekMail_Date');

			if (oldDate == null) {										// 최초 데이터 이면, 
				$.cookie('nekMail_Date', newDate, { path: '/' });		// 쿠키에 일시를 저장.  
			} else if (newDate > oldDate) {								// 이전 데이터 일시와 비교하여 새로운 일시 이면, 
				$.cookie('nekMail_Date', newDate, { path: '/' });		// 쿠키에 일시를 저장하고,  
				getMessagePopup(data);									// 메시지 팝업을 호출한다. 
			}
		}
	});
	
}

// 메시지 팝업을 실행. 
function getMessagePopup(data) {
	var msg = data.subject+' - '+data.sender+' ['+data.created+']';
	var noty = generate('bottom', 'success', newMailMessageFormatter(msg, data.message_name));
	setTimeout(function() { $.noty.close(noty.options.id); }, 10000);	// 10초 뒤에 사라지도록 설정 
}

// 메시지 팝업에 사용할 메일알림 형식. 
function newMailMessageFormatter(value, id) {
	return '<a href="#" style="font-family:맑은 고딕; font-size:10pt; font-weight:bold;" onclick="newMailOpen(\''+id+'\')"> '
		 + '	<img style="position:relative; top:-1px;" src="/common/images/icon-mail-temp.png" align="absmiddle"> '
		 + '	새로운 메시지 수신 알림 - ' + value
		 + '</a> ';
}

// 메일 팝업 조회. 
function newMailOpen(id) {
	OpenWindow("/mail/mail_read.jsp?message_name="+id, "", "900" , "620");
}

// 신규 메일 작성
function newMailWrite(id) {
	OpenWindow("/mail/mail_form.jsp", "", "850" , "620");
}


//하단 신규 메일 확인 창 - 5분 간격 기준 확인 ( 데모서버는 2분 ) 
<%--
function getMessagePopup() {
	$.ajax({
	    url: '/bbs/notice_popup.htm',
	    type: 'POST',
	    dataType: 'html',
	    success: function(data, text, request) {
//	    	var tmp = data.split("</a>");
	    	var tmp = '<a href="#" style="font-family:맑은 고딕; font-size:10pt; font-weight:bold;" onclick="openBbs(\'view\', \'false\', \'bbs00000000000000\',\'2013032118095821\');">';
	    	tmp += '<img style="position:relative; top:-1px;" src="/common/images/icon-mail-temp.png" align="absmiddle">';
	    	tmp += ' 새로운 메세지 수신 알림 - [한국소프트웨어산업협회] SW가치이음터 사업 수요조사 - 김정국 [2013-03-22]</a>';
	    	
	    	var bNoty = generate('bottom', 'success', tmp);
	    	setTimeout(function() {
	    		$.noty.close(bNoty.options.id);
	    	}, 10000 );
	    }
	});
}
--%>

function generate(layout, ntype, nText) {
  	var n = noty({
  		text: nText,
  		type: ntype,
      dismissQueue: true,
  		layout: layout,
  		theme: 'defaultTheme'
  	});
  	//console.log('html: '+n.options.id);
  	return n;
  }

  function generateAll() {
    generate('topRight', 'information');
    generate('bottomRight', 'success');
  }

function qmenu(args) {
	isWindowOpen = function() { return true };
	if ( args == 1 ) {
		var url = "/mail/mail_form.jsp";
		OpenWindow( url, "", "800" , "650" );
		//isWindowOpen = "true";
		
		//var objWin = OpenLayer(url, "E-Mail", winWidth, winHeight,isWindowOpen);	//opt는 top, current
		return;
		
// 		dhtmlwindow.open(
// 				url, "iframe", url, "E-Mail", 
// 				"width=800px,height=500px,resize=1,scrolling=1,center=1", "recal"
// 			);
	} else if ( args == 2 ) {
		var url = "/schedule/form.htm"; // "/sche/form.jsp" 
		//OpenWindow( url, "", "800" , "400" );
		//isWindowOpen = "true";
// 		var objWin = OpenLayer(url, "Schedule", winWidth, winHeight,isWindowOpen);	//opt는 top, current
		OpenWindow(url, "Schedule", winWidth, winHeight);
		return;
		
// 		dhtmlwindow.open(
// 				url, "iframe", url, "Schedule", 
// 				"width=800px,height=400px,resize=1,scrolling=1,center=1", "recal"
// 			);
	} else if ( args == 3 ) {
		openTreeMenu('02','MENU020101');
// 		var url = "/mail/mail_form.jsp";
// 		dhtmlwindow.open(
// 				url, "iframe", url, "Approval", 
// 				"width=800px,height=500px,resize=1,scrolling=1,center=1", "recal"
// 			);
	} else if ( args == 4 ) {
		var url = "/sms/sms_form.jsp";
		
		var objWin = OpenLayer(url, "SMS", winWidth, winHeight,isWindowOpen);	//opt는 top, current
		return;
		
		//OpenWindow( url, "", "800" , "500" );
// 		dhtmlwindow.open(
// 				url, "iframe", url, "SMS", 
// 				"width=800px,height=500px,resize=1,scrolling=1,center=1", "recal"
// 			);

	} else if ( args == 5 ) {
		var url = "/notification/form.htm?indexMain=Y";
		//boxid?
		OpenWindow(url, "<fmt:message key='notification.message.write' />", winWidth, winHeight);
// 		OpenLayer( url, "<fmt:message key='notification.message.write' />", winWidth , winHeight, isWindowOpen );
		return;
	}
}

function searchTel() {
	<%--
	$( "#searchtel" ).autocomplete({
		source: function(request, response ){
			$.ajax({
				type: "GET",
				url: "/support/search_tel.jsp", //보낼 페이지
				data: {
					searchtext : document.getElementById("searchtel").value,
					searchtype : 1,
					opentype : 1,
					pg : 1,
					maxRows: 12
				},
	
				dataType:"json",
				error: function(request, status, error) {
					alert("code : " + request.status + " \r\nMessage : " + request.responseText);
				},
				success :function(data){
						response( $.map( data.items, function( item ) {
							return item;
							/*
							return {
								item
								//id: item.id,
								//value: item.value
							}
							*/
						}));
					}
		  	});
		},
		minLength: 1,
		autoFocus: false,
		width:	'320px',
		height: '300px',
		
		open: function(event, ui) {
			$( ".ui-menu-item a" ).css("white-space", "pre");
			$( ".ui-menu-item a" ).css("float","left");
			$( ".ui-menu-item a" ).css("padding-left","5px");
		},
		close: function(event, ui) {
		},
		focus: function(event, ui){
			$(".ui-menu-item a").removeClass("ui-state-hover");				
		},
		select: function(event, ui) {
			url = "/common/user_read.htm?userId=" + ui.item.id;
			dhtmlwindow.open(
					url, "iframe", url, "Man Info.", 
					"width=800px,height=500px,resize=1,scrolling=1,center=1", "recal"
				);
			return false;
			/*
			log( ui.item ?
				"Selected: " + ui.item.label :
				"Nothing selected, input was " + this.value);
			*/
		}
	}).data("ui-autocomplete")._renderItem = function (ul, item) {
	    var temp = item.label;
	    return $("<li></li>")
			//.data("item.autocomplete", item)
			.data("ui-autocomplete-item", item)
			.append("<img style='float:left;' align='sabsmiddle' src='/userdata/photos/" + item.id + "' width=70 height=70 onerror=\"this.src= '/common/images/photo_user_default.gif'\">")
			.append("<a>" + item.label + "</a>")
			.appendTo(ul);
	};
	--%>
}

function searchTelKeyPress() {
	if ( event.keyCode == 13 ) {
		$( "#searchtel" ).autocomplete("close");
		getTelInfoHtml();
	} 
}

function getTelInfoHtml() {
	/*
	if( document.getElementById("searchtel").value == "" ) {
		document.getElementById("searchtel").focus();
		alert( '검색할 이름을 입력하십시오     ');
		return;
	}
	$.ajax({
		type: "POST",
		url: "/support/search_tel_html.jsp", //보낼 페이지
		data: {
			searchtext : document.getElementById("searchtel").value,
			searchtype : 1,
			opentype : 1,
			pg : 1,
			maxRows: 500
		},

		dataType:"html",
		error: function(request, status, error) {
			alert("code : " + request.status + " \r\nMessage : " + request.responseText);
		},

		success :function(data){
			// test
			dhtmlwindow.open(
					"dhtml_tel", "inline", data, "전화번호 검색", 
					"width=700px,height=320px,resize=1,scrolling=1,center=1", "recal"
				);
		}
  	});
	*/
	var url = "/common/tel_explorer.htm";
	var title = "<fmt:message key="t.search.phone"/>"; /* 전화번호 검색 */
	var opt = "width=940px,height=400px,resize=1,scrolling=1,center=1";
//	dhtmlwindow.open(url, "iframe", url, title, opt, "recal");
	OpenWindow(url, title, "940", "400");
}
	
	function getNewXMLHttpRequest() {
		var xmlHttpRequest = null;
		try {
			xmlHttpRequest = new XMLHttpRequest();
		} catch(e) {
			try {
				xmlHttpRequest = new ActiveXObject("Msxml2.XMLHTTP");
			} catch(e) {
				try {
					xmlHttpRequest = new ActiveXObject("Microsoft.XMLHTTP");
				} catch(e) {
					return null;
				}
			}
		}
		return xmlHttpRequest;
	}
	
	function fnlogout(){
		if(confirm("<%=msglang.getString("c.logout") /* 로그아웃 하시겠습니까? */ %>")){
			top.location = "/logout.jsp";
			//if (helpWin !=null) helpWin.close();
		}
	}
	
	function fnpasswordchange() {
		/*
		var url = "/support/password.html";
		var a = ModalDialog({'t':'Password Change', 'modal':true, 'w':300, 'h':210, 'm':'iframe', 'u':url});
		
		return;
		*/
		returnvalue=null;
		winwidth = "300";
		winheight = "210";
		winleft = (screen.width - winwidth) / 2;
		wintop = (screen.height - winheight) / 2;

		returnvalue = self.showModalDialog("/support/passwordconfirm_form.jsp" , window,
    		             "status:yes;scroll=no;dialogLeft:" + winleft + ";dialogTop:" + wintop + ";help:no;dialogWidth:" + winwidth + "px;dialogHeight:" + winheight + "px");

	}
	
	function service() {
		alert("<fmt:message key='main.comming' />");	/*서비스 예정*/
		return;
	}
	//화면 잠금 기능 수행.
	function lockSystem() {
		/*
		var url = "/support/password.html";
		var a = ModalDialog({'t':'Password Change', 'modal':true, 'w':300, 'h':210, 'm':'iframe', 'u':url});
		
		return;
		*/
		var option = 'dialogHeight:202px;dialogWidth:429px;center:yes;help:no;resizable:no;scroll:no;status:no;dialogTop:'+(screen.height-(screen.availHeight/2)-125)+'px; dialogLeft:'+(screen.width-(screen.availWidth/2)-250)+'px';
		top.window.moveTo (0,window.screen.availHeight);
		var rValue=false;
		rValue = window.showModalDialog("/locksystem.jsp","",option);
		if (rValue == undefined) rValue = window.returnValue;
		if (rValue == false || typeof(rValue) == 'undefined')
			lockSystem();
		else if(rValue == "NOACCESS")
			top.location = '/jpolite/index.jsp';
		else{
			top.window.moveTo(0,0);
			window.screen.availHeight;
			window.screen.availWidght;
		}
	}

	//즐겨찾기
	function fnFavoriate() {
		alert("<fmt:message key='main.comming' />");	/*서비스 예정*/
	}
	
	function listInit() {
		// 리스트 페이 지 호출 부분.  pCode, sCode는 전역
		var if_list = document.getElementById("if_list");
		var url = "";
		
		switch(sCode) {
		case "MENU010202" :		//메일 받은편지함
			url = "/mail/mail_list.jsp?box=1&topbox=1";
			break;
		case "MENU010302" :		//메일 받은쪽지함
			url = "/notification/list.htm?boxId=1";
			break;
		case "MENU020201" :		//전자결재-결재할문서
			url = "/approval/inglist.htm?menu=240";
			break;
		case "MENU041001" :		//일정관리
			//url = "/sche/calendar.jsp";
			url = "/schedule/corpschedule_calendar.htm";
			break;
		case "MENU0501" :		//게시판-공지사항
			url = "/bbs/list.htm?bbsId=bbs00000000000000";
			break;
		case "MENU0512" :		//게시판-최근글목록
			url = "/bbs/newest.htm?bbsId=bbs00000000000000";
			break;
		case "MENU0601" :		//커뮤니티
			url = "/bbs/list.htm?bbsId=bbs00000000000000";
			break;
		case "MENU120401" :		//프로젝트
			url = "/project/list.jsp";
			break;
		
		case "MENU0901" :		//관리자
			url = "/configuration/environment.htm";
			break;
			
		
		case "MENU0101" :		//편지작성 시
			url = "/mail/mail_list.jsp?box=2";
			break;
		case "MENU001401" :		//보낸편지함
			url = "/mail/mail_list.jsp?box=2";
			break;
		case "MENU010401" :		//임시보관함
			url = "/mail/mail_list.jsp?box=3";
			break;
		case "MENU0105" :		//휴지통
			url = "/mail/mail_list.jsp?box=4";
			break;
		case "MENU010801" :		//전자메일 환경설정
			url = "/mail/mail_portal.jsp";
			break;
			
		case "MENU020101" :		//결재문서 작성
			url = "/approval/gianlist.htm?menuid=MENU020101&codekey=";
			break;
		case "MENU020102" :		//임시보관함
			url = "/approval/imsilist.htm?menu=120&menuid=MENU020102&codekey=";
			break;
		case "MENU020103" :		//기안함
			url = "/approval/finlist.htm?menu=130&menuid=MENU020103&codekey=";
			break;
		case "MENU020202" :		//결재한문서
			url ="/approval/finlist.htm?menu=340&menuid=MENU020202&codekey=";
			break;
		case "MENU020301" :		//완료
			url ="/approval/finlist.htm?menu=520&menuid=MENU020301&codekey=";
			break;
		case "MENU020401" :		//수신
			url = "/approval/receivelist.htm?menu=640&menuid=MENU020401&codekey=";
			break;
		case "MENU020801" :		//보낸회람
			url = "/approval/circulationlist.htm?menu=650&menuid=MENU020801&codekey=";
			break;
		case "MENU020802" :		//받은회람
			url = "/approval/circulationlist.htm?menu=660&menuid=MENU020802&codekey=";
			break;	
			
		case "MENU021101" :		//빅밴드 결재완료함
			url = "/approval/bigbandlist.htm?menu=1110&menuid=MENU021101&codekey=";
			break;	
			
		case "MENU020203" :		//반려
			url = "/approval/finlist.htm?menu=530&menuid=MENU020203&codekey=";
			break;
		case "MENU020601" :		//환경
			url = "/approval/appr_signature.jsp?menuid=MENU020601&codekey=";
			break;
		case "MENU040502" :	//회사일정
			url = "/schedule/calendar.htm";
			break;
		case "MENU0409" : //통합일정표
			url = "/schedule/calendarall.htm";
			break;
		case "MENU040602" :		//출장
			url = "/trip/calendar.jsp";
			break;
		case "MENU040702" :		//연차
			url = "/vacation/calendar.jsp";
			break;
		case "MENU0705" :		//임직원정보
// 			url = "/support/user_list.jsp?menuid=MENU0705&codekey=";
			url = "/common/user_list.htm";
			break;
		case "MENU070101" :		//주소록관리
			url = "/addressbook/list.htm";
			break;
		case "MENU071101" : 		// 급상여실적
			url = "/pay/list.htm";
			break;
		case "MENU071202" : 		// 방문자예약
			url = "/schedule/visit_list.htm";
			break;
		case "MENU0704" :		//문서고관리
			url = "/doclib/list.jsp?menuid=MENU0704&codekey=";
			break;
		case "MENU070203" :		//대여관리
			url = "/fixtures/list.jsp?menuid=MENU070203&codekey=";
			break;
		case "MENU0301" :		//문서관리
			url = "/dms/list.htm?listMode=alllist";
// 			url = "/dms/list.htm?menuid=&cateType=S&codekey=";
			break;
		case "MENU030601" :		//문서관리 개인문서함
// 			url = "/dms/list.htm?menuid=MENU070606&catId=&cateType=P";
			url = "/dms/list.htm?cateType=P";
			break;
		case "MENU030301" :		//문서관리 공용문서함
// 			url = "/dms/list.htm?menuid=MENU070603&catId=&cateType=S";
			url = "/dms/list.htm?cateType=S";
			break;
		case "MENU0305" :		//문서관리 환경설정
			url = "/dms/categoryMgr.htm?cateType=P";
			break;
		case "MENU0707" :		//근태
			url = "/attendance/list.htm"; //?menuid=MENU0707&codekey=
			break;	
		case "MENU070301" :		//설문조사
			url = "/poll/poll_m_user_list.jsp?menuid=MENU070301&codekey=";
			break;
		
		//case "MENU0501" :		//공지사항
		//	url = "/bbs/list.htm?bbsId=bbs00000000000000";
		//	break;
		case "MENU0511" :		//업무게시판
			url = "/bbswork/list.htm";
			break;
		case "MENU0505" :		//자유게시판
			url = "/bbs/list.htm?bbsId=bbs00000000000004";
			break;
		case "MENU0506" :		//사내경조사
			url = "/bbs/list.htm?bbsId=bbs20110922153448";
			break;
		case "MENU0507" :		//구 게시판 - 사내공지
			//url = "/bbs/list.htm?bbsId=001001&menuid=001001&codekey=";
			url = "/bbs/list.htm?bbsId=001005&menuid=001005&codekey=";
			break;

		case "MENU1207" :		//금일일정목록
			url = "/project/work_list.jsp";
			break;
		case "MENU1205" :		//공수등록
			url = "/project/work_form.jsp";
			break;
			
		case "MENU" :		//
			url = "";
			break;
			
		case "MENU1401" :		//SMS
			url = "/sms/sms_form.jsp";
			break;
			
		case "MENU1501" :		//프로젝트 목록 
			url = "/project/list.htm";
			break;

		case "MENU1601" :		//프로젝트 목록 
			url = "/project/read.htm?moduleId=" + moduleId;
			break;
		case "MENU160201" :		//프로젝트 계획 >> 계획수립 
			url = "/project/task.htm?moduleId=" + moduleId;
			break;
			
			//환경설정
		case "MENU0801" :		//개인정보
			url = "/configuration/self_edit.htm";
			break;
		case "MENU080201" :		//전자메일 - 서명관리
			url = "/mail/mail_signature.jsp";
			break;
		case "MENU080202" :		//전자메일 - 자동분류
			url = "/mail/mail_rules.jsp";
			break;
		case "MENU080203" :		//전자메일 - 편지함관리
			url = "/mail/mail_mailboxes.jsp";
			break;
		case "MENU080204" :		//전자메일 - 그룹관리
			url = "/mail/mail_grouplist.jsp";
			break;
		case "MENU080205" :		//전자메일 - POP3가져오기
			url = "/mail/mail_pop3support.jsp";
			break;
		case "MENU080206" :		//전자메일 - 아웃룩 주소록가져오기
			url = "/addressbook/addressbook_excel_form.jsp";
			break;
		case "MENU080301" :		//전자결재 - 결재서명
			url = "/approval/appr_signature.jsp";
			break;
		case "MENU080302" :		//전자결재  - 결재비밀번호
			url = "/approval/appr_apprpassword.jsp";
			break;
		case "MENU080303" :		//전자결재 - 결재선
			url = "/approval/appr_line.jsp";
			break;
		case "MENU080304" :		//전자결재 - 부재중설정
			url = "/approval/appr_bujaeja.jsp";
			break;
			
		case "MENU090401" :		//조직관리
// 			url = "/configuration/department_list.htm?pDpId=00000000000000&pDpName=NEK%20%EC%A3%BC%EC%8B%9D%ED%9A%8C%EC%82%AC";
			url = "/configuration/organization_tree.jsp";
			//url = "/configuration/department_list.htm";
			break;
		case "MENU090501" :		//전자결재
			url = "/approval/inghamlist.htm?menu=540";
			break;
		case "MENU0911" :		//접속로그
			url = "/configuration/loginhistory_list.htm";
			break;
		case "MENU0912" :		//로그인 세션 정보
			url = "/configuration/loginsession_list.htm";
			break;
		case "MENU091301" :		//메뉴관리
			url = "/configuration/menucode_list.htm?menuid=MENU091301&codekey=";
			break;
		case "MENU091501" :		//게시판관리
			url = "/bbs/admin_list.htm?menuid=MENU091501&codekey=";
			break;
		case "MENU1325" :		//월간공정회의
			url = "http://www.bizboiler.co.kr/conf/mConfView.jsp?selYear=2012&selMonth=2";
			break;
		// IMS _160704 IMS 메뉴추가
		case "MENU1001" :		//마스터
			url = "/ims/mst/mber/selectImsMber.do";
			break;
		case "MENU100101" :		//공통코드관리
			url = "/fsmt/code/ftcode/selectFTCodeList.do";
			break;
		case "MENU100102" :		//가맹점관리
			url = "/ims/mst/mrhst/selectMrhstList.do";
			break;
		case "MENU100103" :		//거래처관리
			url = "/ims/mst/cust/selectCustList.do";
			break;
		case "MENU100104" :		//거래처제품관리
			url = "/ims/mst/custPrduct/selectCustPrduct.do";
			break;
		case "MENU100105" :		//제품소속분류관리
			url = "/ims/mst/classCd/selectClassCd.do";
			break;
		case "MENU100106" :		//원부자재관리
			url = "/ims/mst/rwmatr/selectRwmatr.do";
			break;
		case "MENU100107" :		//제품관리
			url = "/ims/mst/prduct/selectPrduct.do";
			break;
		case "MENU100108" :		//레시피관리
			url = "/ims/mst/recipe/selectRecipe.do";
			break;
		case "MENU100109" :		//원부자재매칭
			url = "/ims/mst/prductMap/selectPrductMap.do";
			break;
		case "MENU100110" :		//레시피매칭
			url = "/ims/mst/prductMap/selectRecipeMap.do";
			break;
		case "MENU100111" :		//회원정보
			url = "/ims/mst/mber/selectImsMber.do";
			break;
		case "MENU1002" :		//매출관리
			url = "/fsmt/gnmall/gnmExcelList.do";
			break;
		case "MENU100201" :		//굽네몰원자료업로드
			url = "/fsmt/gnmall/gnmExcelList.do";
			break;
		case "MENU100202" :		//굽네몰더존업로드
			url = "/fsmt/mngr/ftSelngList.do?brand_cd=10";
			break;
		case "MENU100203" :		//디브런치원자료업로드
			url = "/fsmt/ksnet/ksnetFileList.do?brand_cd=71";
			break;
		case "MENU100204" :		//디브런치더존업로드
			url = "/fsmt/mngr/ftSelngList.do?brand_cd=71";
			break;
		case "MENU1003" :		//개인경비
			url = "/ims/inv/spend/selectSpend.do";
			break;
		case "MENU100301" :		//개인경비
			url = "/ims/inv/spend/selectSpend.do";
			break;
		case "MENU100302" :		//카드등록&조회
			url = "/ims/mst/cardInfo/selectCardInfoList.do";
			break;
		}
		/*
		var isClosed = myLayout.state.west.isClosed;
		if ( sCode=="MENU1006") {
			if( !isClosed ) myLayout.hide('west');
		} else {
			if( isClosed ) myLayout.open('west');
		}
		*/
		if_list.src = url;
	}
	
	var LEFT_DIV = "";
// 	function menuCheck() {
// 		var menu_area = document.getElementById("menu_area");
// 		if ( !menu_area ) {
// 			$(".ui-layout-west").html(LEFT_DIV);
// 		}
// 	}

function resetLeftCount(mailboxID, selectCount, readCount, cmd, moveboxID, unReadCheck){
	
	var listCount = $("#lCount"+mailboxID).text();
	var noReadCount = $("#lCount0").text();
	var toCount = $("#lCount1").text();
	var dListCount = $("#lCount4").text();
// 	console.log("cmd="+cmd+", unRead='"+unReadCheck+"', id='"+mailboxID+"', read= '"+readCount+"'");
	
	switch(cmd){
		case 'reading' :
			if(mailboxID != 3 && mailboxID != 4 && mailboxID != 6 && mailboxID != 7){
				$("#lCount0").html((Number(noReadCount))-(Number(readCount)));
				$("#lCount"+mailboxID).html((Number(listCount))-(Number(readCount)));
			}
			break;
		
		case 'deleteList' :	//삭제(지운편지함으로 이동)
			if(unReadCheck != 1){
				if(mailboxID == 2 || mailboxID == 3 || mailboxID == 6 || mailboxID == 7){
					$("#lCount"+mailboxID).html((Number(listCount))-(Number(selectCount)));
					$("#lCount4").html((Number(dListCount))+Number((selectCount)));
				}else if(mailboxID == 4){
					$("#lCount4").html((Number(dListCount))-Number((selectCount)));
				}else{
					$("#lCount"+mailboxID).html((Number(listCount))-(Number(readCount)));
					$("#lCount0").html((Number(noReadCount))-(Number(readCount)));
					$("#lCount4").html((Number(dListCount))+Number((selectCount)));
				}
			}else{
				$("#lCount0").html((Number(noReadCount))-(Number(readCount)));
				$("#lCount4").html((Number(dListCount))+Number((selectCount)));
			}
			break;
			
		case 'deleteAll' :	
			if(mailboxID == 2 || mailboxID == 3 || mailboxID == 6 || mailboxID == 7){
				$("#lCount"+mailboxID).html((Number(listCount))-(Number(selectCount)));
			}else{
				$("#lCount0").html((Number(noReadCount))-(Number(readCount)));
				$("#lCount"+mailboxID).html((Number(listCount))-(Number(readCount)));
			}
			break;					
						
		case 'moveList' :	//편지함 이동
			var beforeCount =  $("#lCount"+moveboxID).text();
			if(mailboxID == 4){	//지운편지함인 경우
				$("#lCount4").html(Number(dListCount) - Number(selectCount));
				if(moveboxID !=2 ){
					$("#lCount0").html(Number(noReadCount) + Number(readCount));
					$("#lCount"+moveboxID).html(Number(beforeCount) + Number(readCount));
				}
			} else{						//지운편지함 아닌경우 
				if(moveboxID == 4){
					//읽지않은 편지함에서 이동및 삭제했을때 카운트 하지 않음
					if(unReadCheck != 1){
						$("#lCount"+mailboxID).html((Number(listCount))-(Number(readCount)));
					}
					if(mailboxID != 2){
						$("#lCount0").html((Number(noReadCount))-(Number(readCount)));
						$("#lCount4").html((Number(dListCount))+Number((selectCount)));
					}else{
						$("#lCount4").html((Number(dListCount))+Number((selectCount)));
					}
				}else{
					if(unReadCheck != 1){
						$("#lCount"+mailboxID).html(Number(listCount) - Number(readCount));
					}
					$("#lCount"+moveboxID).html((Number(beforeCount))+(Number(readCount)));
				}
			}
			break;
			
		case 'clearTrash' :
			$("#lCount4").html("");
			break;
			
		case 'readDelete' : //read.jsp 삭제
			if(mailboxID == 4){
				$("#lCount4").html((Number(dListCount))-(Number(selectCount)));
			}else{
				$("#lCount4").html((Number(dListCount))+(Number(selectCount)));
			}
			break;
			
		case 'readMove' :	//read.jsp 이동
			var beforeCount =  $("#lCount"+moveboxID).text();
			if(moveboxID == 4){
				$("#lCount4").html((Number(beforeCount))+(Number(selectCount)));
			}else{
				$("#lCount"+moveboxID).html((Number(beforeCount))+(Number(readCount)));
			}
			if(mailboxID == 4){
				$("#lCount4").html(Number(listCount) - Number(selectCount));
			}else{
				$("#lCount"+mailboxID).html(Number(listCount) - Number(readCount));
			}
			break;
			
		case 'read' :	//읽음
			if(unReadCheck != 1){
				$("#lCount"+mailboxID).html(Number(listCount) - Number(readCount));
				$("#lCount0").html(Number(noReadCount) - Number(readCount));
			}else{
				$("#lCount0").html(Number(noReadCount) - Number(readCount));
			}
			break;
			
		case 'unread' :	//안읽음
			if(mailboxID != 2 && mailboxID != 3 && mailboxID != 4 && mailboxID != 6 && mailboxID !=7){
				if(unReadCheck != 1){
					$("#lCount"+mailboxID).html(Number(listCount) + Number(readCount));
					$("#lCount0").html(Number(noReadCount) + Number(readCount));
				}else{
					$("#lCount0").html(Number(noReadCount) + Number(readCount));
				}
			}
			break;
			
		case 'draft' :
			$("#lCount"+mailboxID).html(Number(listCount) + Number(selectCount));
			break;
			
		case 'spamDelete' : 
			$("#lCount7").html(Number(listCount) - Number(selectCount));
			$("#lCount0").html(Number(noReadCount) + Number(readCount));
			$("#lCount1").html(Number(toCount) + Number(readCount));
			break;
			
		case 'spam' :
			var afterCount = $("#lCount7").text();
			if(mailboxID != 7){
				if(unReadCheck == 1){
					$("#lCount0").html(Number(noReadCount) - Number(readCount));
				}else{
					$("#lCount0").html(Number(noReadCount) - Number(readCount));
					$("#lCount"+mailboxID).html(Number(listCount) - Number(readCount));
				}
				$("#lCount7").html(Number(afterCount) + Number(selectCount));
			}
			break;
		
	}
	
	$(".num").each(function(i){
		if($(this).text() == 0 || $(this).text() < 0){
			$(this).html("");
		}	
	});
	
}
function showMailMenu() {
	var leftMailUrl = "/mail/mail_left.jsp";
	$.ajax({
	    url: leftMailUrl,
	    async: false,
	    //url: 'calendar_list_data.htm?start=2011110120&end=2011123020&_=1321270106013',
	    type: 'GET',
	    dataType: 'html',
	    success: function(data, text, request) {
			$("#menu_area").html("");
			try {
	    		document.getElementById("menu_area").innerHTML = data;
	    	} catch(e) {
	    		$("#menu_area").html(data);	/* IE에서 AJAX-HTML 호출 시 인식 못하는 경우 발생해 순서 바꿈 */
	    	}
			$("#menuTitle").html('<fmt:message key="mail.email"/>');
			$("#menu_area").css( "padding", "0px");
			$("#menu_area").css("width", "190px");
			$("#menu_area").css("overflow", "hidden");
			
	 		var hasXScrollBar = $('body').width() < 970;
			$("#menu_area").css("height", $(window).height() - ((isiPad)?179:((hasXScrollBar)?196:179)));	//180
			$("#mail_left_layer").css("height", $(window).height() - ((isiPad)?224:((hasXScrollBar)?241:224)));
			//console.log( "mail...");
			
			$.post("/mail/mailbox_json.jsp?boxid=1&dbpath=mail&opentype=TOP", function(data) {
				if (data && data.length > 0) {
					$("#inbox_tree_area").dynatree({
						children: data,
						generateIds: true,
						idPrefix: "P",
						onClick: function(node, e) {
							var targetType = node.getEventTargetType(e);
							if (targetType) {
								document.getElementById("if_list").src = "/mail/mail_list.jsp?box="+node.data.key+"&topbox=1";
							} else return false;
						},
					 	onLazyRead: function(node) {
							node.appendAjax({
								url: "/mail/mailbox_json.jsp",
								data: { boxid: node.data.key, dbpath: node.data.dbpath, opentype: node.data.opentype },
								success: function(node) {
// 									console.log(node);
									node.visit(function(n) {
										n.expand(true);
									})
								}
							});
						},
						onCustomRender: function(dtnode) {
							returnHtmls = "<a href='#' class='dynatree-title'> "
										+ dtnode.data.name 
										+ "<span class='num' id='lCount"+dtnode.data.key+"'>";
							
							if (dtnode.data.count > 0) {
								returnHtmls += dtnode.data.count;
							}
							
							returnHtmls +="</span></a>";
							
							return returnHtmls;
						}
					});

					for(var i = 0, len = data.length; i < len; i++) {
						$("#inbox_tree_area").dynatree("getTree").getNodeByKey(data[i].key).toggleExpand();
					}
					
				} else {
					$("#inbox_tree_tr").hide();
				}
			}, "json");

			$.post("/mail/mailbox_json.jsp?boxid=2&dbpath=mail&opentype=TOP", function(data) {
				if (data && data.length > 0) {
					$("#outbox_tree_area").dynatree({
						children: data,
						generateIds: true,
						idPrefix: "P",
						onClick: function(node, e) {
							var targetType = node.getEventTargetType(e);
							if (targetType) {
								document.getElementById("if_list").src = "/mail/mail_list.jsp?box="+node.data.key+"&topbox=2";
							} else return false;
						},
					 	onLazyRead: function(node) {
							node.appendAjax({
								url: "/mail/mailbox_json.jsp",
								data: { boxid: node.data.key, dbpath: node.data.dbpath, opentype: node.data.opentype },
								success: function(node) {
									node.visit(function(n) {
										n.expand(true);
									})
								}
							});
						}
					});

					for(var i = 0, len = data.length; i < len; i++) {
						$("#outbox_tree_area").dynatree("getTree").getNodeByKey(data[i].key).toggleExpand();
					}
				} else {
					$("#outbox_tree_tr").hide();
				}
			}, "json");
	    }
	});
}

	var menu = new WebTree();
	var menus = new Array(menu);

	
	function reTreeMenu(code) {
		$("#menu_area").html("");
		loadRootMenus();
		if (code) loadAfterExpand(code); // "code_MENU0201"
	}
	
	var pCode;
	var sCode;
	function openTreeMenu( code1, code2 ){
		//지앤푸드 결재함 좌측 카운트 표시
		if(code1=="02"){
			setApprCnt(1);
			setApprCnt(6);
			setApprCnt(5);
		}
		
		pCode = code1;
		sCode = code2;
		window.pCode = pCode; // resize 에서 사용하기 위해 setting 
		
		sel_menu = pCode;
		
		var if_list = document.getElementById("if_list");
		
		if( !if_list ) {
			var url = "/main_sub.jsp?pCode=" + pCode + "&sCode=" + sCode;
			self.location = url;
			return;
		}
		
		// project 인 경우, 우측위치를 새로 고침.
		if (pCode == 16) {
			if_list.src = "/project/task.htm?" + sCode;
			//return;
		} else {
			listInit();		/* Right List Load */
		}
		
		var menu_area = document.getElementById("menu_area");
	 	
		//메일 인 경우 임.
		if( pCode == 01 ) {
			// Mail Left Menu - Ajax Call
			showMailMenu();

			if ( sCode == "MENU0101" ) {
				window.open("/mail/mail_form.jsp", "", "width=800,height=600,scrollbars=yes,resizable=yes");
			}

			return;
		}
				
		$("#menu_area").html("");
		$("#menu_area").css( "padding", "5px 5px");
		$("#menu_area").css("width", "180px");
		$("#menu_area").css("height", $(window).height() - ((isiPad)?189:(($('body').width() < 970)?206:189)));
		$("#menu_area").css("overflow", "auto");
		
		//1. 이미지 변경, 메뉴 텍스트 변경, 트리 적용, 종료
		menu.rootContainer = document.getElementById("menu_area");
		
		if( !menu.rootContainer ) {
			alert( "DEV - Check : Err Position - top");
		}
		var menuImage = document.getElementById("menuImage");
		var menuTitle = document.getElementById("menuTitle");

		try {
			var clickObj = $(event.fromElement);
		} catch(e) {
			var clickObj = null;
		}
		
		try {
			if ( pCode == "07" || pCode == "08" || pCode == "09" || pCode == "10" || pCode == "11" || pCode == "12" || pCode == "13" ) {
				var imgNo = "01" ;
			} else {
				var imgNo = pCode ;
			}
			menuImage.src = "../common/images/left_vis" + imgNo + ".jpg";
			//$(menuTitle).text( clickObj.text );
		} catch(e) {
			//$(menuTitle).text( "Menu Name" );
		}
		
		//오류 발생 포지션으로 추정.
		menu.rootContainer.setAttribute("menucode", "MENU" + pCode );
		menu.setExpandImg("../common/images/icons/minus1.gif");
		menu.setCollapseImg("../common/images/icons/plus1.gif");
		//menu.setItmImg("../common/images/icons/page1.gif");
		menu.setItmImg("/common/images/icons/admin_icon_10.png");
		
		
		menu.setFdCloseImg("../common/images/icons/folder.png");
		menu.setFdOpenImg("../common/images/icons/folder-open.png");
		
		//menu.setBlankImg("../common/images/tree/blank.gif");
		//menu.setBlankImg("../common/images/tree/blank1.png");
		
		menu.setInfoImg("../common/images/tree/noitem.gif");
		menu.onloadChildNode = function(folder){loadChildNode(folder, this)};
		menu.onclickFolder = function(folder){return OnOK(folder, this);}
		menu.onclickItem = function(item){return OnOK(item, this);}
		menu.ondblclickFolder = function(folder){return OnOK(folder, this);}
		menu.ondblclickItem = function(item){return OnOK(item, this);}

		loadRootMenus();
		
		///approval/inglist.htm?menu=240&menuid=MENU020201&codekey=undefined
				
		//action 이후 처리부
		
		list = document.getElementById("if_list");
		switch(pCode) {
		case "01" :
			$(menuTitle).text('<fmt:message key="mail.email"/>');
			break;
		case "02" :
			$(menuTitle).text('<fmt:message key="main.Approval"/>');
			break;
		case "03" :
			$(menuTitle).text('<fmt:message key="main.Document.Management"/>');
			break;
		case "04" :
			$(menuTitle).text('<fmt:message key="sch.Datebook"/>');
			break;
		case "05" :
			$(menuTitle).text('<fmt:message key="main.Board"/>');
			break;
		case "06" :
			$(menuTitle).text('<fmt:message key="main.Board"/>');
			break;
		case "07" :
			$(menuTitle).text('<fmt:message key="main.Business.Support"/>');
			break;
		case "08" :
			$(menuTitle).text('<fmt:message key="main.option"/>');
			break;
		case "09" :
			$(menuTitle).text('<fmt:message key="main.System.Management"/>');
			break;
		case "10" :
			$(menuTitle).text('<fmt:message key="main.IMS"/>');
			break;
		case "12" :
			$(menuTitle).text('<fmt:message key="main.Project.Management"/>');	/*프로젝트 관리*/
			break;
		case "13" :
			$(menuTitle).text('<fmt:message key="main.intranet"/>');	/*인트라넷*/
			break;
		case "14" :
			$(menuTitle).text("SMS");
			break;
		case "15" :
			$(menuTitle).text('<fmt:message key="t.project"/>');	/*프로젝트*/
			break;
		case "16" :
			$(menuTitle).text('<fmt:message key="t.project"/>');
			break;
		}
		
		//결재일 경우 기안함, 결재함은 항상 펼쳐지도록 : 2012-01-12 김정국 수정.
		// 상기 건으로 인해 loadRootMenu의 Ajax를 async를 false로 처리 하였음. 문제시 true로 변경 필요.
		var expMenu = sCode.substring(0,8);
		if( expMenu.indexOf("MENU02") > -1 ) {	//Approval Expand
			loadAfterExpand("code_MENU0201");
			loadAfterExpand("code_MENU0202");
		} else if (expMenu.indexOf("MENU03") > -1 ){	// EDMS Expand
			loadAfterExpand("code_MENU0303");
		} else if (expMenu.indexOf("workType") > -1 ){	// Project Expand
			loadAfterExpand("code_MENU1602");
			loadAfterExpand("code_MENU1603");
		}
	}
	
	function loadAfterExpand( argCode ) {
		try {
			var openTreeNode = argCode;
			var oDiv = document.getElementById( openTreeNode );
			if (oDiv) {
				var img = oDiv.childNodes[0];
				if ( img.src.indexOf("plus") > -1 ) {
					$(img).trigger("click");
				}
			}
		} catch(e) {
			alert( 'expand error');
		}
	}
	function loadRootMenus(){
		for(var i=0; i<menus.length; i++){
			var menu = menus[i];
			var container = menu.rootContainer;
			var menucode = container.getAttribute("menucode");
			if(menucode == null || menucode =="" || menucode == "undefined") continue;
			
			var xmlHttpRequest = getNewXMLHttpRequest();
			// project id 추가로 인해 sCode 부분 추가.
			var requestURL = "/common/menu_xml.htm?pCode=" + menucode + "&" + sCode;

			try {
				//xmlHttpRequest.onreadystatechange = function(){OnGetMenuCompleted(this, menu, container);};
				//xmlHttpRequest.open("POST", requestURL, false);
				//xmlHttpRequest.send();
				$.ajax({
				    url: requestURL,
				    async: false,
				    //url: 'calendar_list_data.htm?start=2011110120&end=2011123020&_=1321270106013',
				    type: 'POST',
				    dataType: 'xml',
				    success: function(data, text, request) {
				    	//$("#announce").html( data );
						//OnGetMenuCompleted(this, menu, container);
						OnGetMenuCompleted(request, menu, container);
				    }
				});
				
			} catch (e) {
				alert(e);
			}
		}
	}

	function loadCategoryMenus(menuTree, container, url){
		//var xmlHttpRequest = getNewXMLHttpRequest();
		try {
			//xmlHttpRequest.onreadystatechange = function(){OnGetMenuCompleted(this, menuTree, container);};
			//xmlHttpRequest.open("POST", url, true);
			//xmlHttpRequest.send();
			$.ajax({
			    url: url,
			    //url: 'calendar_list_data.htm?start=2011110120&end=2011123020&_=1321270106013',
			    type: 'POST',
			    dataType: 'xml',
			    success: function(data, text, request) {
			    	//$("#announce").html( data );
					
					//OnGetMenuCompleted(this, menu, container);
					OnGetMenuCompleted(request, menuTree, container);
			    }
			});
		} catch(e) {
			alert(e);
		}	
	}


	function loadChildNode(folder, menu){
		//var xmlHttpRequest = getNewXMLHttpRequest();
		var nodeData = folder.getAttribute(menu._NK_DATA);
		var datas = nodeData.split('|');
		//alert( datas );
		var subCateId = (datas[7]==null) ? "" : datas[7];			
		var subMenuUrl = (datas[9]==null) ? "" : datas[9];
// 		var moduleId = (datas[10]==null) ? "" : datas[10];
		
		var requestURL = "/common/menu_xml.htm?pCode=" + datas[1] + "&subcateid=" + subCateId + "&";
		if(datas[1].indexOf("MENU16")>-1){	//프로젝트 선택시 
			//requestURL += "&workType=2&moduleId="+ moduleId;
			requestURL += sCode; 
		}
		if(subMenuUrl != "") requestURL = subMenuUrl;
		try {
			$.ajax({
			    url: requestURL,
			    //url: 'calendar_list_data.htm?start=2011110120&end=2011123020&_=1321270106013',
			    type: 'POST',
			    dataType: 'xml',
			    success: function(data, text, request) {
			    	//$("#announce").html( data );
					
					//OnGetMenuCompleted(this, menu, container);
					OnGetMenuCompleted(request, menu, folder);
			    }
			});
		} catch (e) {
			alert(e);
		}
	}

	function setApprCnt(apprType){
		try {
			$.ajax({
			    url: '/approval/apprWidgetCount.htm?apprType=' + apprType,
			    type: 'POST',
			    dataType: 'text',
			    success: function(data, text, request) {
			    	if(apprType==1){
			    		$("#apprCnt1").text(data);
			    	}else if(apprType==6){
			    		$("#apprCnt2").text(data);
			    	}else if(apprType==5){
			    		$("#apprCnt3").text(data);
			    	}
			    }
			});
		} catch (e) {
			alert(e);
		}
	}
	
	var workBBS = [];
	
	function OnGetMenuCompleted(xhr, menuTree, container){
		
				
				var contentType = xhr.getResponseHeader("Content-Type");
				if (contentType.length < 8 || contentType.substring(0, 8) != "text/xml") {
					menuTree.makeInfoNode(container,"unsupported content type: " + contentType);
				} else {
					var categoryMenus = new Array();
					try{
						if ( xhr.responseXML ) {
							
						var objCollect = xhr.responseXML.getElementsByTagName("menucode");
						if (objCollect.length == 0) {
							menuTree.makeInfoNode(container, "<%=msglang.getString("t.not.exist.menu") /* 메뉴가 존재하지 않습니다. */ %>");
						} else {
							/*
							<menucode mCode="MENU11"
								 codeName="DOC. Library"
								 tpCode="MENU11"
								 pCode="TOP"
								 codeLevel="1"
								 orders="0"
								 url=""
								 subMenuUrl=""
								 openFlag="false"
								 childExist="true"
								 iconFile="approual_icon_4.jpg"
								*/ 
								var topCode = "";
							for (var i = 0; i < objCollect.length; i++) {
								topCode = objCollect[i].getAttribute("tpCode");		//2
								
								var code	= objCollect[i].getAttribute("mCode");	//0
								var catName = objCollect[i].getAttribute("codeName");	//1
								//지앤푸드 결재함 좌측 카운트 표시
								if(code=="MENU020201"||code=="MENU020202"||code=="MENU020203"){
									if(code=="MENU020201"){
										catName += "<span class='num'>" + $("#apprCnt1").text() + "</span>";
									}else if(code=="MENU020202"){
										catName += "<span class='num'>" + $("#apprCnt2").text() + "</span>";
									}else if(code=="MENU020203"){
										catName += "<span class='num'>" + $("#apprCnt3").text() + "</span>";
									}
								}
								
								var url = objCollect[i].getAttribute("url");		//2
								if(catName == "category"){
									categoryMenus.push(url);
									continue;
								}
								var isChildExist = objCollect[i].getAttribute("childExist");	//3
								var popup = objCollect[i].getAttribute("openFlag");	//4
								var codeLevel = objCollect[i].getAttribute("codeLevel");	//5
								var urlFlag = objCollect[i].getAttribute("urlflag");	//6
								var subCateID = objCollect[i].getAttribute("subcateid");	//7
								
								//var iconFile = objCollect[i].getAttribute("iconFile");	//8
								//var iconFile = "approual_icon_3.jpg";	//8
								var iconFile = "folder.png";	//8
								
								var subMenuUrl = objCollect[i].getAttribute("subMenuUrl"); //9
								subMenuUrl = (subMenuUrl == null) ? "" : subMenuUrl;
								var moduleId = objCollect[i].getAttribute("moduleId"); //10
								
								if(isChildExist=="true"){
									var menu = menuTree.makeFolderWithId(container, "code_" + code, catName, catName + "|" + code + "|" + isChildExist + "|" + url+ "|" + popup + "|" + codeLevel + "|" + urlFlag + "|" + subCateID + "|" + iconFile + "|" + subMenuUrl + "|" + moduleId);
									menu.setAttribute("usr_strType", code);
									menu.setAttribute("usr_selectedNode", i);
									menu.setAttribute("usr_expandChild", true);
									//var iconFile = "folder-open.png";	//8
									if(iconFile != "") menuTree.setCustomImg(menu, imgPath + iconFile);
									
								}else{
									//iconFile = "admin_icon_10.jpg";	//8
									iconFile = "admin_icon_10.png";	//8

	 								if (code == "MENU0511") {
	 									workBBS[0] = "code_" + code;
	 									workBBS[1] = catName;
	 									workBBS[2] = catName + "|" + code + "|" + isChildExist + "|" + url + "|" + popup + "|" + codeLevel + "|" + urlFlag + "|" + iconFile + "|" + subMenuUrl + "|" + moduleId;
	 									workBBS[3] = code;
 										workBBS[4] = imgPath + iconFile;
	 								} else if (code == "bbs00000000000000") {
										var subMenu = menuTree.makeItemWithId(container, "code_" + code, catName, catName + "|" + code + "|" + isChildExist + "|" + url + "|" + popup + "|" + codeLevel + "|" + urlFlag + "|" + iconFile + "|" + subMenuUrl + "|" + moduleId);
										subMenu.setAttribute("usr_strType", code);
										if (iconFile != "") menuTree.setCustomImg(subMenu, imgPath + iconFile);
	 								} else {
										var subMenu = menuTree.makeItemWithId(container, "code_" + code, catName, catName + "|" + code + "|" + isChildExist + "|" + url + "|" + popup + "|" + codeLevel + "|" + urlFlag + "|" + iconFile + "|" + subMenuUrl + "|" + moduleId);
										subMenu.setAttribute("usr_strType", code);
										if(iconFile != "") menuTree.setCustomImg(subMenu, imgPath + iconFile);
	 								}

									if (workBBS.length > 0) {
										var subMenuWorkBBS = menuTree.makeItemWithId(container, workBBS[0], workBBS[1], workBBS[2]);
										subMenuWorkBBS.setAttribute("usr_strType", workBBS[3]);
										if(iconFile != "") menuTree.setCustomImg(subMenuWorkBBS, workBBS[4]);
										workBBS = [];
									}
								}
							}
						}
						}
					}catch(e){
						alert(e);
					}
					var len = categoryMenus.length;
					for(var i=0; i<len; i++){
						loadCategoryMenus(menuTree, container, categoryMenus[i]);
					}
				}
						
						try {
						var expMenu = sCode.substring(0,8);
						var openTreeNode = "code_" + expMenu;
						
						var oDiv = document.getElementById( openTreeNode );
						var img = oDiv.childNodes[0];
						if ( img.src.indexOf("plus") > -1 ) {
								$(img).trigger("click");
						}
						} catch(e) {
							//window.status = "Tree Expand Error ... main_sub.jsp";
						}
						
			container.setAttribute("isLoaded", true);			
	}
	
function OnGetMenuCompleted_BK(xhr, menuTree, container){
		
		if(xhr.readyState == 4) {
			if(xhr.status == 200) {
				var contentType = xhr.getResponseHeader("Content-Type");
				if (contentType.length < 8 || contentType.substring(0, 8) != "text/xml") {
					menuTree.makeInfoNode(container,"unsupported content type: " + contentType);
				} else {
					var categoryMenus = new Array();
					try{
						var objCollect = xhr.responseXML.getElementsByTagName("menucode");
						if (objCollect.length == 0) {
							menuTree.makeInfoNode(container, "<%=msglang.getString("t.not.exist.menu") /* 메뉴가 존재하지 않습니다. */ %>");
						} else {
							/*
							<menucode mCode="MENU11"
								 codeName="DOC. Library"
								 tpCode="MENU11"
								 pCode="TOP"
								 codeLevel="1"
								 orders="0"
								 url=""
								 subMenuUrl=""
								 openFlag="false"
								 childExist="true"
								 iconFile="approual_icon_4.jpg"
								*/ 
							for (var i = 0; i < objCollect.length; i++) {
								var code	= objCollect[i].getAttribute("mCode");	//0
								var catName = objCollect[i].getAttribute("codeName");	//1
								var url = objCollect[i].getAttribute("url");		//2
								if(catName == "category"){
									categoryMenus.push(url);
									continue;
								}
								var isChildExist = objCollect[i].getAttribute("childExist");	//3
								var popup = objCollect[i].getAttribute("openFlag");	//4
								var codeLevel = objCollect[i].getAttribute("codeLevel");	//5
								var urlFlag = objCollect[i].getAttribute("urlflag");	//6
								var subCateID = objCollect[i].getAttribute("subcateid");	//7
								var iconFile = objCollect[i].getAttribute("iconFile");	//8
								var subMenuUrl = objCollect[i].getAttribute("subMenuUrl"); //9
								var moduleId = objCollect[i].getAttribute("moduleId"); //10
								subMenuUrl = (subMenuUrl == null) ? "" : subMenuUrl;
								
								if(isChildExist=="true"){
									var menu = menuTree.makeFolderWithId(container, "code_" + code, catName, catName + "|" + code + "|" + isChildExist + "|" + url+ "|" + popup + "|" + codeLevel + "|" + urlFlag + "|" + subCateID + "|" + iconFile + "|" + subMenuUrl + "|" + moduleId);
									menu.setAttribute("usr_strType", code);
									menu.setAttribute("usr_selectedNode", i);
									menu.setAttribute("usr_expandChild", true);
									if(iconFile != "") menuTree.setCustomImg(menu, imgPath + iconFile);
								}else{
									var subMenu = menuTree.makeItemWithId(container, "code_" + code, catName, catName + "|" + code + "|" + isChildExist + "|" + url + "|" + popup + "|" + codeLevel + "|" + urlFlag + "|" + iconFile + "|" + subMenuUrl + "|" + moduleId);
									subMenu.setAttribute("usr_strType", code);
									if(iconFile != "") menuTree.setCustomImg(subMenu, imgPath + iconFile);									
								}
							}
						}
					}catch(e){
						alert(e);
					}
					var len = categoryMenus.length;
					for(var i=0; i<len; i++){
						loadCategoryMenus(menuTree, container, categoryMenus[i]);
					}
				}
						
						try {
						var expMenu = sCode.substring(0,8);
						var openTreeNode = "code_" + expMenu;
						
						var oDiv = document.getElementById( openTreeNode );
						var img = oDiv.childNodes[0];
						if ( img.src.indexOf("plus") > -1 ) {
							
								img.click();	
						}
						} catch(e) {
							//window.status = "Tree Expand Error ... main_sub.jsp";	
						}
						
			} else {
				menuTree.makeInfoNode(container, "request status error : " + xhr.status);
			}
			container.setAttribute("isLoaded", true);			
		}
	}	

	function expandm(a, b) {
		var m = document.getElementById('code_MENU0405');
		var img = m.childNodes[0];
		
		if ( img.src.indexOf("plus") > -1 ) {
			img.click();
		}
		
	}

	function goSub( args ) {
		if ( args == 0 ) {
			//self.location = "main_sub.jsp";
		} else if ( args == 10 ) {
			document.getElementById("if_list").src = "/proposal/proposal_form.jsp?bbsid=bbs00000000000000&categoryid=";
		} else if ( args == 11 ) {
			document.getElementById("if_list").src = "/doclib/proposal_form.jsp?bbsid=bbs00000000000000&categoryid=";
		} else if ( args == 12 ) {
			document.getElementById("if_list").src = "/schedule/calendar.htm?bbsid=bbs00000000000000&categoryid=";
		} else {
			//self.location = "main_new.jsp";
		}
	}

	function OnOK(node, menu) {
		if ( node.childNodes[1].className != "wtree-itm" ) {
			if ( node.parentElement.id == "menu_area") {
				// oracle 변환 후 상단-폴더 트리 클릭 시 화면 틀어지는 현상으로 적용 : 2012-12-08
				return;
			}
		}
		
//		if(menu.getSelectedNode()  !=null){
			var contextRoot = "<c:url value="/" />";
			//var nek_datas = menu.getSelectedData().split(":");
			/*
			var tmp = menu.getData(node).toUpperCase();
			if ( tmp.indexOf("http://") > -1 ) {
				var tmp = menu.getData(node).replace(/http\:\/\//gi,"：");
				alert( tmp );
			}
			return;
			*/
			
			var nek_datas = menu.getData(node).split("|");
			var listURL =  "/common/menuleft.jsp?menucode=MENU04001"; //+ nek_datas[1];
			
			if(nek_datas[3] == "" || nek_datas[3] ==null){
				if(nek_datas[2]==0) alert('<fmt:message key="main.no.route"/>');	/*지정된 경로가 없습니다.*/
				return false;
			}
			
			listURL = nek_datas[3];
			listURL = listURL.replace(/＆/g, "&");
			//@today를 오늘일자로 변경(일정용)
			//listURL = listURL.replace( /@today/gi, dToday );
			
			if(contextRoot != "/") listURL += contextRoot;

			if(nek_datas[4].charAt(0) == "1"){
				if(nek_datas[1]=="MENU0101")
				{//메일작성
					winleft = (screen.width - 800) / 2;
					wintop = (screen.height - 650) / 2;
					window.open(listURL , "" , "scrollbars=no,width=800, height=650, top="+ wintop +", left=" + winleft);
				}else{
					winleft = (screen.width - 755) / 2;
					wintop = (screen.height - 610) / 2;
					window.open(listURL , "" , "scrollbars=yes,width=755, height=610, top="+ wintop +", left=" + winleft);
				}
			}else{
				/* 제안관리 메인인 경우 좌측 숨김 */
// 				var isClosed = myLayout.state.west.isClosed;
// 				if ( nek_datas[1]=="MENU1006") {
// 					if ( !isClosed ) myLayout.hide('west');
// 				} else {
// 					if( isClosed ) myLayout.open('west')
// 				}
				
				if(listURL.indexOf("?")>-1){
					document.getElementById("if_list").src = listURL + "&menuid=" + nek_datas[1] + "&codekey=" + (nek_datas.length==10 ? nek_datas[9] : nek_datas[8]);
				}else{
					document.getElementById("if_list").src = listURL + "?menuid=" + nek_datas[1] + "&codekey=" + (nek_datas.length==10 ? nek_datas[9] : nek_datas[8]);
				}
			}
			return true;
//		}
	}	
	
	function test() {
		if ( event.keyCode == 13 ) {
			alert( 'test');
		}
	}
	
	function m_over(mo)
	{
		mo.style.textDecoration='underline';
		mo.style.cursor = 'pointer';
	}

	function m_out(mt)
	{
		mt.style.textDecoration='none';	
	}
	
	function goNotes() {
		if ( $.browser.msie ) {
			window.open("http://old.starion.co.kr", "", "")
		} else {
			var msg = "old.starion.co.kr 사이트는 IE 전용 입니다. \nInternet Explorer를 이용해 접속하시기 바랍니다."; 
			msg += "\n\nold.starion.co.kr site in IE only.\nPlease use Internet Explorer to access.";
			alert( msg );
		}
	}
	
	function rateSso() {
		var url = "/common/confirm_password.htm";
		window.modalwindow = window.dhtmlmodal.open(
				"_CHILDWINDOW_COMM100P", "iframe", url, "<fmt:message key='appr.passre'/>",	/*비밀번호 확인*/ 
				"width=220px,height=170px,resize=0,scrolling=1,center=1", "recal"
		);
	}

	function payReadData(pwd) {
		$.ajax({
			url: "/common/rate_sso.htm?password=" + pwd,
			dataType: "json",
			data: { cmd: 'test' },
			success: function(data) {	
		    	if (data.result > 2) {
					alert("<fmt:message key='main.id.present.two'/>");	/*동일한 ID의 사용자가 2명 이상 존재합니다.*/
				} else {
					switch(data.result) {
						case 1:
							var newwin = window.open("about:blank");
							newwin.location.href = data.url;
							break;
						case -9: alert("<fmt:message key='v.no.ad'/>"); break;		/*AD계정이 없습니다.*/
						case -8: alert("<fmt:message key='v.check.ad'/>"); rateSso(); break;		/*AD계정의 ID 또는 비밀번호를 확인해 주십시요.*/
						case -7: alert("<fmt:message key='v.no.ad.groupware'/>"); break;		/*AD계정은 있으나 그룹웨어에 등록되어 있지 않습니다.*/
						default: alert("<fmt:message key='v.confirm.password'/>"); rateSso(); break;		/*비밀번호를 확인해 주십시오*/
					}
				}
			}
		});
	}
/*S: 2021리뉴얼 신규추가*/    
if(!String.prototype.padStart) {
	String.prototype.padStart = function padStart(targetLength, padString) {
		if(this.length >= targetLength) {
			return String(this);
		} else {
			if(padString == null || padString == " ") {
				padString = " ";
			} else if(padString.length > 1) {
				padString = padString.substring(0,1);
			}
			targetLength = targetLength - this.length;
			var prefix = "";
			for(var i = 0; i < targetLength; i++) {
				prefix += padString;
			}
			return prefix + String(this);
		}
	};
}
  $(function(){
  $('.nth-child_01').click(function(){
    var date = new Date();
    var date2 = new Date();
    var today = new Date();
	var dd = String(today.getDate()).padStart(2, '0');
	var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
	var yyyy = today.getFullYear();
    var hours = ('0' + today.getHours()).slice(-2); 
    var minutes = ('0' + today.getMinutes()).slice(-2);

	date =  yyyy+ '년' + mm + '월' + dd  + '일' ;
    date2 = hours + ':' +  minutes ;
    $('#newdate_span').text(date);
     $('#newdate_span_2').text(date2);
  });
  
  $('.nth-child_03').click(function(){
    var date = new Date();
    var date2 = new Date();
    var today = new Date();
	var dd = String(today.getDate()).padStart(2, '0');
	var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
	var yyyy = today.getFullYear();
    var hours = ('0' + today.getHours()).slice(-2); 
    var minutes = ('0' + today.getMinutes()).slice(-2);

	date =  yyyy+ '년' + mm + '월' + dd  + '일' ;
    date2 = hours + ':' +  minutes ;
    $('#newdate_span_3').text(date);
     $('#newdate_span_4').text(date2);
  });

  $('.save_btn').click(function(){
  var newdate_span = $('#newdate_span_2').text();
    $('.layer_bg , .start_layer').css('display','none');
    $('.start_time').text(newdate_span);
    $('.nth-child_01').css('pointer-events','none');
  });
  $('.close_save_btn').click(function(){
  var newdate_span_end = $('#newdate_span_4').text();
    $('.layer_bg , .end_layer').css('display','none');
    $('.end_time').text(newdate_span_end);
     $('.nth-child_03').css('pointer-events','none');
  });
  
   $('.nth-child_02').click(function(){
       alert('근무체크 처리 하였습니다.');
   });
});



/*E: 2021리뉴얼 신규추가*/    
</script>
<!----S: 2021리뉴얼추가 파일------->
<script src="/jpolite/js/layer_popup.js"></script>
<link rel="stylesheet" href="/jpolite/css/main_renew_2021.css"/>
<!----E: 2021리뉴얼추가 파일------->

<!--S: 출퇴근레이어팝업-->
<div class="layer_bg" style="display: block;"></div>
<div class="layer_wrap start_layer" layer="1">
    <div class="close_div_box"><a href="javascript:;" class="btn_close">X</a></div>
    <img src="/common/images/icon/img_01.png" border="0" >
    <div class="user_name_div"><b><%=loginuser.dpName %><%=loginuser.nName %><fmt:message key="main.by.who"/></b></div> 
    <ul class="today_ul">
        <li><div id="newdate_span"></div></li>
        <li><div id="newdate_span_2"></div></li>
    </ul>
    <div class="layer_text">업무를 시작하시겠습니까?</div>
    <div class="save_btn">확인</div>
</div>
<div class="layer_wrap end_layer" layer="2">
    <div class="close_div_box"><a href="javascript:;" class="btn_close">X</a></div>
    <img src="/common/images/icon/img_01.png" border="0" >
    <div class="user_name_div"><b><%=loginuser.dpName %><%=loginuser.nName %><fmt:message key="main.by.who"/></b></div> 
    <ul class="today_ul">
        <li><div id="newdate_span_3"></div></li>
        <li><div id="newdate_span_4"></div></li>
    </ul>
    <div class="layer_text">업무를 종료하시겠습니까?</div>
    <div class="close_save_btn">확인</div>
</div>


<!--E: 출퇴근레이어팝업-->

<!-- top -->
<div class="top_top_blank">
    <a href="javascript:fnlogout();" style="color: #000 !important;padding:2px 18px;background:#4392df;height:13px;border-radius: 15px;margin-right: 2px;">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 23.04 26.01" style="width:14px;height:14px;vertical-align: text-top;"><defs><style>.cls-1{fill:#fffec2;}</style></defs><g id="2" data-name="2"><g id="Layer_1" data-name="Layer 1"><path class="cls-1" d="M18.33,5.19a1.68,1.68,0,0,0-2,2.71,8.18,8.18,0,1,1-9.65,0,1.68,1.68,0,0,0-2-2.71A11.52,11.52,0,1,0,23,14.49,11.59,11.59,0,0,0,18.33,5.19Z"/><path class="cls-1" d="M11.52,12.36a1.72,1.72,0,0,0,1.73-1.73V1.73a1.73,1.73,0,0,0-3.46,0v8.9A1.73,1.73,0,0,0,11.52,12.36Z" /></g></g></svg>
        <font class="black" style="color:#fff;">로그아웃</font>
    </a> 
</div>
<div class="left_box_logo">
   <% if (isPartnerTemp) {%>
    <a href="<%= ( (!isPartnerTemp) ? "/jpolite/index.jsp" : "#" ) %>">
         <img src="/common/images/icon/logo.png" height="29" border="0" >
    </a>
    <% }else {%>
    <a href="<%= ( (!isPartner) ? "/jpolite/index.jsp" : "#" ) %>">
        <img src="/common/images/icon/logo.png" height="29" border="0" >
    </a>
    <%} %>
    <div class="user_info_div">
        <!--<ul class="user_info_left">
            <img src="/common/images/icon/img_01.png" border="0" >
        </ul>-->
        <ul class="user_info_right">
            <li style="margin-bottom: 6px;"><!-- topMenu 로그인유저 추가 -->
                <div><b><%=loginuser.dpName %><%=loginuser.nName %><fmt:message key="main.by.who"/></b> 반갑습니다.</div> 
            </li>
        </ul>
        <%if(loginuser.loginId.equals("admin") || loginuser.loginId.equals("cameo305") || loginuser.loginId.equals("stonebox") || loginuser.loginId.equals("goshwang")
             	 || loginuser.loginId.equals("chan048") || loginuser.loginId.equals("dbkim424") || loginuser.loginId.equals("suhyunzzang9")){ %>
            <style>
            .left_centent_box{top:127px;z-index:1;}
            </style>
            <ul class="user_info_right">     
            <li class="inline_block_li nth-child_01 btn_layer" onClick="javascript:;" layer="1">업무시작</li>
            <li class="inline_block_li nth-child_02" >근무체크</li>
            <li class="inline_block_li nth-child_03 btn_layer" onClick="javascript:;" layer="2">업무종료</li>
     
        <!---20210713 출퇴근 신규 등록---->
             <!-------업무시작전 노출---------
            <li class="work work_on work_finish">
                <ul>
                    <li class="work_on_btn">
                        <a href="">
                            <div class="btn_work_div" id="work_start_btn"  href=""  type="button">
                                출근
                            </div>
                        </a>
                    </li>
                    
                </ul>
            </li>
            <!-------//---------
            <!-------업무시작후 노출---------
            <li class="work working">
                <span id="worktime_s"></span><span id="worktime_e"></span>
            </li>
            <li class="work work_check working left_btn">
                <!-- <a href="#"> --
                    <div class="btn_work_div work_2" id="work_continue_btn"  href="" type="button">
                        체크
                    </div>
                <!-- </a> --
            </li>
            <li class="work work_off working work_2 right_btn">
                <a href="">
                    <div class="btn_work_div" id="work_end_btn"  href=""  type="button">
                        퇴근
                    </div>
                </a>
            </li>
         <!--------//---------------------->
        </ul>
        
        <div class="work_info_div">
            <ul>
                <li><b>출근</b> <span class="start_time">-</span></li>
                <li><b>퇴근</b> <span class="end_time">-</span></li>
            </ul>
        </div>
        <%} %>
        
        
    </div>
</div>
<div class="right_box_menu">
    <ul class="top_menu_list">
        <li>
            <input class="burger-check" type="checkbox" id="burger-check"  checked/><label class="burger-icon" for="burger-check"><span class="burger-sticks"></span></label>
            <span class="nav_menu_text">ALL Menu</span>
            <div class="menu">
              <div class="nav_centent">
                  <ul>
                  <% 	if (loginId.equals("taxinv") || loginId.equals("abcde"))  { %>
                  <li><a href="javascript:openTreeMenu('02', 'MENU020802');" class="parent"><span class="shadowText"><fmt:message key="main.Approval"/>&nbsp;<!-- 전자결재 --></span></a>
                      <div class="arrow-up"></div>
                      <ul class="ul_sub_menu">
                          <li><a href="javascript:openTreeMenu('02','MENU020802');"><span><fmt:message key="appr.menu.circulating"/>&nbsp;<!-- 회람함 --></span></a></li>
                      </ul>	
                  </li>
                  <% }else if (loginId.equals("bigband") || loginId.equals("big_cam11") || loginId.equals("big_cam12") || loginId.equals("big_cam13")
               		   || loginId.equals("big_cam21") || loginId.equals("big_cam22") || loginId.equals("big_cam23") || loginId.equals("big_cont1")
            		   || loginId.equals("big_cont2") || loginId.equals("big_cs1") || loginId.equals("big_cs2") || loginId.equals("big_stra1")
            		   || loginId.equals("big_stra2") || loginId.equals("big_sup1") || loginId.equals("big_sup2"))  {%> 
					 <li><a href="javascript:openTreeMenu('02', 'MENU021101');" class="parent"><span class="shadowText"><fmt:message key="main.Approval"/>&nbsp;<!-- 전자결재 --></span></a>
                            <div class="arrow-up"></div>
                            <ul class="ul_sub_menu">
                                <li><a href="javascript:openTreeMenu('02','MENU021101');"><span><fmt:message key="appr.menu.bigband"/>&nbsp;<!-- 빅밴드 --></span></a></li>
                            </ul>	
                        </li>
					<%}else{ %>
                  
                      <% 	if (isPartner)  { %>
                        <%--  <li class="last"><a href="javascript:openTreeMenu('01', 'MENU010202');"><span class="shadowText"><b>HOME<!-- <fmt:message key="main.Main"/>&nbsp;--><!-- 메인화면 --></b></span></a>--%>
                        <li class="last"><a href="javascript:openTreeMenu('01', 'MENU010202');"><span class="shadowText"><b>HOME&nbsp;<!-- 전자메일 --></b></span></a>        

                        <%	} %>
                        <% 	if (isPartnerTemp)  { %>
                        <%--  <li class="last"><a href="javascript:openTreeMenu('01', 'MENU010202');"><span class="shadowText"><b>HOME<!-- <fmt:message key="main.Main"/>&nbsp;--><!-- 메인화면 --></b></span></a>--%>
                        <li class="last"><a href="javascript:openTreeMenu('01', 'MENU010202');"><span class="shadowText"><b><fmt:message key="mail.email"/>&nbsp;<!-- 전자메일 --></b></span></a>        
                        <!--  2016.07.25 김현식  // 협력업체 전자결재 탭 추가.  -->
                        <li class="last"><a href="javascript:openTreeMenu('02', 'MENU020201');"><span class="shadowText"><fmt:message key="main.Approval"/>&nbsp;<!-- 전자결재 --></span></a>

                        <%	} %>
                        <% if ( !isPartner) if( !isPartnerTemp) { %>
                        <li><a href="/jpolite/index.jsp"><span class="shadowText"><b>HOME<!-- <fmt:message key="main.Main"/>&nbsp;--><!-- 메인화면 --></b></span></a>
                        <li><a href="javascript:openTreeMenu('01', 'MENU010202');" class="parent"><span class="shadowText"><b><fmt:message key="mail.email"/>&nbsp;<!-- 전자메일 --></b></span></a>
                            <div class="arrow-up"></div>
                            <ul class="ul_sub_menu">
                                <li><a href="javascript:newMailWrite();"><span style="color:black;"><fmt:message key="main.E-mail.Write"/>&nbsp;<!-- 편지쓰기--></span></a></li>
                                <li><a href="javascript:openTreeMenu('01','MENU010202');"><span><fmt:message key="mail.InBox"/>&nbsp;<!-- 받은편지함 --></span></a></li>
                                <li><a href="javascript:openTreeMenu('01','MENU001401');"><span><fmt:message key="mail.OutBox"/>&nbsp;<!-- 보낸편지함 --></span></a></li>
                                <li><a href="javascript:openTreeMenu('01','MENU010401');"><span><fmt:message key="mail.TempBox"/>&nbsp;<!-- 임시보관함 --></span></a></li>
                                <li><a href="javascript:openTreeMenu('01','MENU0105');"><span><fmt:message key="mail.DeletedBox"/>&nbsp;<!-- 지운편지함 --></span></a></li>
                                <li><a href="javascript:openTreeMenu('01','MENU010302');"><span><fmt:message key="main.Message"/>&nbsp;<!-- 쪽지 --></span></a></li>                
                                <li><a href="javascript:openTreeMenu('01','MENU010801');"><span><fmt:message key="main.option"/>&nbsp;<!-- 환경설정 --></span></a></li>
                            </ul>
                        </li>
                        <li><a href="javascript:openTreeMenu('02', 'MENU020201');" class="parent"><span class="shadowText"><fmt:message key="main.Approval"/>&nbsp;<!-- 전자결재 --></span></a>
                            <div class="arrow-up"></div>
                            <ul class="ul_sub_menu">
                                <li><a href="javascript:openTreeMenu('02','MENU020101');"><span><fmt:message key="appr.menu.new"/>&nbsp;<!-- 기안서작성 --></span></a></li>
                                <li><a href="javascript:openTreeMenu('02','MENU020201');"><span><fmt:message key="appr.menu.approvalbox"/>&nbsp;<!-- 결재함 --></span></a></li>
                                <li><a href="javascript:openTreeMenu('02','MENU020301');"><span><fmt:message key="appr.menu.complete"/>&nbsp;<!-- 결재완료함 --></span></a></li>
                                <li><a href="javascript:openTreeMenu('02','MENU020401');"><span><fmt:message key="appr.menu.receipient"/>&nbsp;<!-- 수신함 --></span></a></li>
                                <li><a href="javascript:openTreeMenu('02','MENU020802');"><span><fmt:message key="appr.menu.circulating"/>&nbsp;<!-- 회람함 --></span></a></li>
                                <li><a href="javascript:openTreeMenu('02','MENU020601');"><span><fmt:message key="main.option"/>&nbsp;<!-- 환경설정 --></span></a></li>
                            </ul>
                        </li>
                        <li><a href="javascript:openTreeMenu('04', 'MENU041001');" class="parent"><span class="shadowText"><fmt:message key="sch.Datebook"/>&nbsp;<!-- 일정관리 --></span></a>
                            <div class="arrow-up"></div>
                            <ul class="ul_sub_menu">
                                <li><a href="javascript:openTreeMenu('04','MENU0409');"><span><fmt:message key="sch.Integrated.schedule"/>&nbsp;<!-- 통합일정표 --></span></a></li>
                                <li><a href="javascript:openTreeMenu('04','MENU040502');"><span><fmt:message key="sch.Individuals.a.shared.calendar"/>&nbsp;<!-- 개인-공유일정 --></span></a></li>
                                <li><a href="javascript:openTreeMenu('04','MENU041001');"><span><fmt:message key="sch.Company.schedules"/>&nbsp;<!-- 회사일정 --></span></a></li>
                            </ul>
                        </li>
                        <li><a href="javascript:openTreeMenu('03', 'MENU0301');" class="parent"><span class="shadowText"><fmt:message key="main.Document.Management"/>&nbsp;<!-- 문서관리 --></span></a>
                            <div class="arrow-up"></div>
                            <ul class="ul_sub_menu">
                                <li><a href="javascript:openTreeMenu('03','MENU0301');"><span><fmt:message key="main.Document.Management"/>&nbsp;<!-- 문서관리 --></span></a></li>
                                <li><a href="javascript:openTreeMenu('03','MENU0305');"><span><fmt:message key="main.option"/>&nbsp;<!-- 환경설정 --></span></a></li>
                            </ul>
                        </li>
                        <li><a href="javascript:openTreeMenu('07', 'MENU0705');" class="parent"><span class="shadowText"><fmt:message key="main.Business.Support"/>&nbsp;<!-- 업무지원 --></span></a>
                            <div class="arrow-up"></div>
                            <ul class="ul_sub_menu">
                                <li><a href="javascript:openTreeMenu('07','MENU0705');"><span><fmt:message key="main.Employee.Info"/>&nbsp;<!-- 임직원정보 --></span></a></li>
                                <li><a href="javascript:openTreeMenu('07', 'MENU070101');"><span><fmt:message key="main.Business.Card"/>&nbsp;<!-- 주소록관리 --></span></a></li>                
                                <li><a href="javascript:openTreeMenu('07','MENU070203');"><span><fmt:message key="main.Rent.Management"/>&nbsp;<!-- 자원관리 --></span></a></li>
                                <li><a href="javascript:openTreeMenu('07','MENU070301');"><span><fmt:message key="main.Servey"/>&nbsp;<!-- 설문조사 --></span></a></li>
                            </ul>
                        </li>
                        <li><a href="javascript:openTreeMenu('05', 'MENU0501');" class="parent"><span class="shadowText"><fmt:message key="main.Board"/>&nbsp;<!-- 게시판 --></span></a>
                            <div class="arrow-up"></div>
                            <ul class="ul_sub_menu">
                                <li><a href="javascript:openTreeMenu('05','MENU0501');"><span><fmt:message key="main.notice"/>&nbsp;<!-- 공지사항 --></span></a></li>
                                <li><a href="javascript:openTreeMenu('05','MENU0511');"><span><fmt:message key="main.Work.Board"/>&nbsp; <!-- 업무게시판 --> </span></a></li>
                                <li><a href="javascript:openTreeMenu('05','MENU0505');"><span><fmt:message key="main.Free.Board"/>&nbsp;<!-- 자유게시판 --></span></a></li>
                            </ul>
                        </li>
                        <li><a href="javascript:openTreeMenu('10', 'MENU1003');" class="parent"><span class="shadowText"><fmt:message key="main.IMS"/>&nbsp;<!-- IMS --></span></a>
                            <div class="arrow-up"></div>
                            <ul class="ul_sub_menu">
                                <!-- <li><a href="javascript:openTreeMenu('10','MENU1001');"><span>마스터&nbsp;<!-- 마스터 </span></a></li> -->
                                <!-- <li><a href="javascript:openTreeMenu('10','MENU1002');"><span>매출관리&nbsp;<!-- 매출관리 </span></a></li>-->
                                <li><a href="javascript:openTreeMenu('10','MENU1003');"><span>개인경비&nbsp;<!-- 개인경비 --></span></a></li>
                            </ul>
                        </li>
                        <li><a href="javascript:openTreeMenu('08', 'MENU0801');" class="parent"><span class="shadowText"><fmt:message key="main.option"/>&nbsp;<!-- 환경설정 --></span></a>
                            <div class="arrow-up"></div>
                            <ul class="ul_sub_menu">
                                <li><a href="javascript:openTreeMenu('08','MENU0801');"><span><fmt:message key="main.Personal.Info"/>&nbsp;<!-- 개인정보 --></span></a></li>
                                <li><a href="javascript:openTreeMenu('08','MENU080201');"><span><fmt:message key="main.E-mail"/>&nbsp;<!-- 전자메일 --></span></a></li>
                                <li><a href="javascript:openTreeMenu('08','MENU080301');"><span><fmt:message key="main.Approval"/>&nbsp;<!-- 전자결재 --></span></a></li>
                            </ul>
                        </li>

                        <%if(isAdmin){ %>
                        <li><a href="javascript:openTreeMenu('09', 'MENU0901');" class="parent"><span class="shadowText"><fmt:message key="main.System.Management"/>&nbsp;<!-- 시스템관리 --></span></a>
                            <div class="arrow-up"></div>
                            <ul class="ul_sub_menu">
                                <li><a href="javascript:openTreeMenu('09','MENU0901');"><span><fmt:message key="ope.operating.environment"/>&nbsp;<!-- 운영환경 --></span></a></li>
                                <li><a href="javascript:openTreeMenu('09','MENU090401');"><span><fmt:message key="main.Organizational"/>&nbsp;<!-- 조직관리 --></span></a></li>
                                <!--  <li><a href="javascript:openTreeMenu('09','MENU090501');"><span><fmt:message key="main.Approval"/>&nbsp;</span></a></li> // 전자결재관리-->
                                <li><a href="javascript:openTreeMenu('09','MENU091501');"><span><fmt:message key="main.Board.Management"/>&nbsp;<!-- 게시판관리 --></span></a></li>
                                <li><a href="javascript:openTreeMenu('09','MENU091301');"><span><fmt:message key="main.Menu.Management"/>&nbsp;<!-- 메뉴관리 --></span></a></li>
                                <li><a href="javascript:openTreeMenu('09','MENU0911');"><span><fmt:message key="main.Connection.Log"/>&nbsp;<!-- 접속로그 --></span></a></li>
                                <li><a href="javascript:openTreeMenu('09','MENU0912');"><span><fmt:message key="main.Login.Info"/>&nbsp;<!-- 로그인정보 --></span></a></li>
                            </ul>
                        </li>
                    <%} %>
                        <li><a href="javascript:openTreeMenu('07', 'MENU0705');" class="last"><span class="shadowText"><fmt:message key="main.Employee.Info"/>&nbsp;<!-- 환경설정 --></span></a>
                            <div class="arrow-up"></div>
                            <ul class="ul_sub_menu">
                                <li><a href="javascript:openTreeMenu('07','MENU0705');"><span><fmt:message key="main.Employee.Info"/>&nbsp;<!-- 임직원정보 --></span></a></li>
                            </ul>
                        </li>
                    <%} %>
                    
                    <li><a href="http://www.gngrp.com" target="_blank" ><span class="shadowText">종합정보사이트</span></a></li>
                    <%} %>
                  </ul>
              </div>
             
            </div>
        </li>
        <!--<li>
           <a href="http://www.gngrp.com" target="_blank" >
               종합정보사이트 <font class="black">바로가기 ></font>
            </a> 
        </li>-->
    </ul>
</div>
<!-- //top -->



<!-- menu area -->
<link type="text/css" href="/common/jquery/menu/menu.css" rel="stylesheet" />
<script type="text/javascript" src="/common/jquery/menu/menu.js"></script>

<style type="text/css">
* { margin:0;
    padding:0;
}
/* div #menu_area {overflow-x:auto; overflow-y:auto; } */
div#menu_area div {line-height:20px;}
div#menu_area div span {font-weight:bold; color:#3d3d3d; no_letter-spacing:1px;}
/* div#menu_area div div {padding-left:26px;} */

/* div#menu_area div div {padding-left:15px;} */
div#menu_area div div span {font-weight:normal; color:#000;}

div#menu_area div span, div#menu_area div div span {
	border-left--:1px dotted #f9f9f9; margin-left:1px;
} 

div#menu_area .num {padding-left:5px; font-size:9pt; font-family:tahoma; color:#205FCF;font-weight:bold;}

div#menu_area .mail_left_table div span:hover, div#menu_area .mail_left_table div div span:hover {
	border:1px solid #a6c0e5;
	background:#ddecf7;
}

div#menu_area .mail_left_table div span:active, div#menu_area .mail_left_table div div span:active {
	border:1px solid #a6c0e5;
	background:#ddecf7;
}

div#menu_area .tree_area ul {
 	background-color: #e6e8ed;
}

div#menu_area .tree_area ul.dynatree-container a {
  	border-color: #e6e8ed;
}

div#menu_area .tree_area ul span.dynatree-active a,
div#menu_area .tree_area ul span.dynatree-active a:hover
{
	border: 1px solid #99DEFD;
	background-color: #D8F0FA !important;
}


div#menu { margin:5px auto; margin-top:1px; }
div#copyright {
    font:11px 'Trebuchet MS';
    color:#fff;
    text-indent:30px;
/* 	width:0px; height:0px; */
}
div#copyright a { color:#00bfff; }
div#copyright a:hover { color:#fff; }

div#menu {
background: url(/common/images/top_blue_bg.png);
height:33px;
margin-top: 0px;
}
div#menu span {
margin-top: 1px;
}
div#menu a {color:#fff; height:33px; }
.shadowText {text-shadow: -1px -1px 0 rgba(0,0,0,0.3);}
.shadowText1 {text-shadow: -1px -1px 0 rgba(0,0,0,0.1);}
div#menu li.back {
height: 33px;
}
/* div#menu li { */
/* background: none; */
/* } */

div#menu li.back .left {
/* background: url(images/lava.png) no-repeat top left !important; */
/* background-image: url(images/lava.gif); */
height: 33px;
/* margin-right: 8px; */
}

div#menu ul ul {
top: 32px;
border-radius: 4px;
width: 175px;
}

div#menu li {
background: url(/common/images/top_line_bg1.png) 94% 8px no-repeat;
}
</style>



<!-- ***** jQuery megamenu Menu Map ***** 
1. index.jsp의 마지막에 jkmegamenu.js 링크하고, jkmegamenu.definemenu() 호출함.
2. main_sub.jsp에 jkmegamenu.js 링크하고, jkmegamenu.definemenu() 호출함.
     ***** jQuery megamenu Menu Map ***** -->

<link rel="stylesheet" type="text/css" href="/common/scripts/jkmegamenu.css" />



<div style="display:none;" id="copyright"><a href="http://apycom.com/"></a></div>
<div style="display:none;" id="apprCnt1"></div>
<div style="display:none;" id="apprCnt2"></div>
<div style="display:none;" id="apprCnt3"></div>

<!-- <div style="sdisplay:none;" id="copyright"><a href="http://apycom.com/"></a></div> -->

<!-- top End -->>>>>>>>>>>>>