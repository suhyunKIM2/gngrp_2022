<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page contentType="text/html;charset=utf-8" %>
<%@ page import="nek.common.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>	
<%@ include file="/common/usersession.jsp"%>
<%
	int port = request.getServerPort();
	String baseURL = request.getScheme() + "://" + request.getServerName()
			+ (port != 80 ? ":" + Integer.toString(port) : "") + request.getContextPath();
	String workType = request.getParameter("workType");
	String moduleId = request.getParameter("moduleId");

	String userDomain = uservariable.userDomain;
	String logoTxt = " ";
	String logoImg = "";
%>
<!DOCTYPE html>
<html>
<fmt:setLocale value="<%=loginuser.locale %>"/>
<fmt:bundle basename="messages">
<head>
<%-- <link rel="shortcut icon" href="<%=baseURL %>/common/images/starion_fav.png" /> --%>
<title><%=logoTxt %>GroupWare System</title><%--=uservariable.campaignTitle --%>
<%@ include file="/WEB-INF/common/include.mata.jsp" %>
<%@ include file="/WEB-INF/common/include.jquery.jsp" %>
<%@ include file="/WEB-INF/common/include.common.jsp" %>
<link rel="stylesheet" type="text/css" href="/common/jquery/css/layout-default.css" />
<script src="/common/jquery/js/jquery.layout.min-1.2.0.js"></script>
<script src="/common/jquery/plugins/modaldialogs.js"></script>
	<style type="text/css">

	/**

	 *	Basic Layout Theme

	 */

	.ui-layout-pane { /* all 'panes' */ 
 		border: 1px solid #aaa;
/* 		border-right:2px solid #aaa;  */
	} 

	.ui-layout-pane-center { /* IFRAME pane */ 
		padding: 0;
		margin:  0;
	} 

	.ui-layout-pane-north { /* west pane */ 
		border: 0px solid #fff;
	}
	
	.ui-layout-pane-west { /* west pane */ 
		padding: 0 5px; 
		/* background-color: #EEE !important; */
/* 		background-color: #FFF !important; */
/* 		overflow: auto; */
	} 

	.ui-layout-resizer { /* all 'resizer-bars' */ 
		background: #DDD;
		 background: #fff;
		} 
		.ui-layout-resizer-open:hover { /* mouse-over */
			background: #9D9;
			background: #85b5d9;
			
		}

	.ui-layout-toggler { /* all 'toggler-buttons' */ 
		background: #AAA;
 		background: #AAA url(/common/images/layout_button_left.gif) no-repeat ;
 		height:30px;
 		}
		
		.ui-layout-toggler-closed { /* closed toggler-button */ 
			background: #CCC; 
			background: #85b5d9;
			border-bottom: 1px solid #BBB;
			background: #000;
		} 

		.ui-layout-toggler-open { /* closed toggler-button */ 
			top:500px;
		} 

		.ui-layout-toggler .content { /* toggler-text */ 
			font: 9pt bold Verdana, Verdana, Arial, Helvetica, sans-serif;
			height:140px;
			padding-left:7px;
/* 			padding-top:20px;  */
			vertical-align:top;
			color:#000;
			font-weight:bold;
			background-color:#fff;
		}

		.ui-layout-toggler:hover { /* mouse-over */ 
		background: #DCA; 
			} 
		.ui-layout-toggler:hover .content { /* mouse-over */ 
			color: #009; 
		}

	/* class to make the 'iframe mask' visible */
	.ui-layout-mask {
		opacity: 0.2 !important;
		filter:	 alpha(opacity=20) !important;
		background-color: #666 !important;
	}

/*       body{margin:0px; font-family:Arial, Sans-Serif; font-size:13px;} */
     
</style>

<style>
.img {text-align:right;}
.menu	{color:#000000; padding-left:5px; padding-top:3px; line-height:24px;}
.sub	{color:#000000; padding-left:5px; padding-top:3px; line-height:18px;}
 
a.1depth:link		{color:#000000; text-decoration:none;}
a.1depth:visited	{color:#000000; text-decoration:none;}
a.1depth:hover 	{color:#3A81AB; text-decoration:none;}
 
 
a.2depth:link		{color:#000000; text-decoration:none; font-style:normal;}
a.2depth:visited 	{color:#000000; text-decoration:none; font-style:normal;}
a.2depth:hover   	{color:#ff0000; text-decoration:none; font-style:normal;}
 


.png24 {
   tmp:expression(setPng24(this));
}

</style>

<!-- Mail Left Script -->
<script language="javascript">
var selObj;
var workType ="<%=workType %>";
var moduleId ="<%=moduleId %>";

function t_on() {
	this.style.border = "1px solid #A6C0E5";
	this.style.backgroundColor = "#B6D2F5";
	//this.style.fontWeight = "bold";
}
function t_off() {
	this.style.border = "1px solid #d8dee9";
	//this.style.backgroundColor = "#ffffff";
	this.style.backgroundColor = "#d8dee9";
	if ( selObj ) {
		if ( selObj.innerText != this.innerText ) {
			this.style.fontWeight = "normal";
		}
	} else {
		this.style.fontWeight = "normal";
	}
}

function m_click() {
	t_handle();
	// menu jump
	
	//우측 Frame 초기화
	var fs_list = parent.document.getElementById("fs_list");
	if (fs_list) {
		fs_list.rows = "100%,0";
		fs_list.cols = "100%,0%";
	}
}

function t_handle() {
	// UI Handle
	var curObj = window.event.srcElement;	// A Tag
	if ( selObj ) {
		if ( selObj.innerText == curObj.innerText ) {
		} else {
			selObj.style.fontWeight = "normal";
			selObj = curObj
			selObj.style.fontWeight = "bold";
		}
	} else {
		selObj = window.event.srcElement;
		selObj.style.fontWeight = "bold";
	}

}

function t_set() {
	return;
	for ( var n = 1; n < 7; n++ ) {
		var str = "m" + n;
		var tbl = document.getElementById( str );

		var tr = tbl.rows;
		for( var i=0; i< tr.length; i++ ) {
			for( var j=0; j < tr[i].cells.length; j++ ) {
				var td = tr[i].cells[j];
				td.onmouseover = t_on;
				td.onmouseout = t_off;
				
				//td.onclick = m_click;
			}
		}
	}
}

//var objWin ;
// 새메일
function newDoc(){
	var if_list = window.frames[0];
	
	try {
		if ( if_list ) {
			if ( if_list.objWin ) {
				//var msg = "현재 편지를 작성 중 에 있습니다.\n\n[확인]을 누르시면 작성중인 내용이 사라집니다.\n\n저장하려면 [취소] 후  [저장] 버튼을 누르세요.\n";
				//if ( !confirm (msg) ) return;
				//if_list.objWin.close();

				$(if_list.objWin).remove(); 
			}
			var url = "/mail/mail_form.jsp";
			try {
				// if_list.objWin = if_list.OpenLayer(url, "Mail", winWidth, winHeight,isWindowOpen);	//opt는 top, current
				OpenWindow(url, "", "800", "650");
			} catch(e) {
				if_list.src = url;
			}
		} else {
			if_list.src = url;
		}

		//if_list.goSubmit('NEW');
	} catch(e) {
		alert( 'Layer Open에 따른 오류 \n\niframe - list page : objWin 설정필요 !\n\n 관리자에게 문의하십시오     ');
	}
	
	return;
	
	var url = "/mail/mail_form.jsp";
	if_list.objWin = if_list.OpenLayer(url, "Mail", winWidth, winHeight,isWindowOpen);	//opt는 top, current
	
/*
	winleft = (screen.width - 800) / 2;
	wintop = (screen.height - 650) / 2;
	window.open(listURL , "" , "scrollbars=no,width=800, height=650, top="+ wintop +", left=" + winleft);
*/
}

function newNoteDoc(){
	var listURL = "/notification/form.htm";
	winleft = (screen.width - 800) / 2;
	wintop = (screen.height - 650) / 2;
	window.open(listURL , "" , "scrollbars=yes,width=800, height=650, top="+ wintop +", left=" + winleft);
}

function OnClickClearTrash() {
	if (confirm("<fmt:message key='mail.c.delete.all.trash'/>")) { //휴지통 내의 모든 문서를 삭제합니다. 계속하시겠습니까?
// 		fmMailLeft.action = "mail_cleartrash.jsp";
// 		fmMailLeft.method = "post";
// 		fmMailLeft.url.value = "mail_left";
// 		fmMailLeft.submit();

		$.ajax({
		    url: "/mail/mail_cleartrash.jsp", async: false, type: 'POST',
		    success: function(data, text, request) {
				var if_list = $("#if_list").contents();
				if (if_list.find("input[name=box]").val() == '4') {
					if_list.find('.ui-icon-refresh').click();
					if_list.find('.dhtmlwindow').remove();
				}
// 		    	showMailMenu();
		    	top.resetLeftCount(4, 0, null, 'clearTrash');
		    }
		});
	}

}



function changeDisplay(img) { 
	var id = $(img.parentNode.parentNode).attr("id");
	var lv = id.split("/").length +1;
	var flag = (img.getAttribute("src").indexOf("plus") > -1);
	var boxs = $(".mailboxpath");
	
	for(var i = 0; i < boxs.length; i++) {
		var box = $(boxs[i]);
		var box_id = box.attr("id");
		var box_lv = box_id.split("/").length;
		var img_fc = box.find('img:eq(0)');

		if (box_id == id) {
			changeImage(img);
		} else if (box_id.indexOf(id) == 0)
			if (flag) { if (box_lv == lv) box.show();
			} else { changeImage(img_fc); box.hide(); }
	}
	
	function changeImage(img) {
		var img = $(img);
		var imgPath = "../common/images/icons/";
		if(img.attr("src")) {
			if (img.attr("src").indexOf("minus") > -1) {
				img.attr("src", imgPath + "plus1.gif");
			} else if (img.attr("src").indexOf("plus") > -1) {
				img.attr("src", imgPath + "minus1.gif");
			}
		}
	}
}
</script>

<script>
function Request(valuename)
{
 var rtnval;
 var nowAddress = unescape(location.href);
 var parameters = new Array();
 parameters = (nowAddress.slice(nowAddress.indexOf("?")+1,nowAddress.length)).split("&");
 for(var i=0; i<parameters.length; i++)
 {
  if(parameters[i].indexOf(valuename) != -1)
  {
   rtnval = parameters[i].split("=")[1];
   if(rtnval == undefined || rtnval == null)
   {
    rtnval = "";
   }
   return rtnval;
  }
 }
}
</script>

<script type="text/javascript">
var imgPath = "<c:url value="/common/images/icons/" />";
//var menucode = "MENU05";
//var submenucode = "MENU0501";

var myLayout; // a var is required because this page utilizes: myLayout.allowOverflow() method

$(document).ready(function () {
	//지앤푸드 결재함 좌측 카운트 표시
	setApprCnt(1);
	setApprCnt(6);
	setApprCnt(5);
	
	//$('#switcher').themeswitcher();

	if ( self.location.href.indexOf("main_sub.jsp") > -1 ) {
		$("#qmenu").show();
	}

	myLayout = $('body').layout({
			north__slidable:		false	// OVERRIDE the pane-default of 'slidable=true'
		,	north__togglerLength_closed: '100%'	// toggle-button is full-width of resizer-bar
		,	north__spacing_closed:	20		// big resizer-bar when open (zero height)
		,	north__resizable:		false
		,	north__size:		92
		,	north__initClosed:	false
		,	north__initHidden:	false
		,	north__spacing_open:	0		// no resizer-bar when open (zero height)
		,	north__spacing_closed:	0
	
		,	west__size:					205 
		,	west__resizable:					false
 		,	west__spacing_open:		0
		,	west__spacing_closed:		30
 		,	west__togglerLength_closed:	140
		,	west__togglerAlign_closed:	"top"
		,	west__togglerContent_closed:"좌측 메뉴<br/><br/>열기<br/>&nbsp;<br/><img src='/common/images/layout_button_right.gif' />"
		,	west__togglerTip_closed:	"좌측 메뉴 열기 및 고정"
 		,	west__sliderTip:			"좌측 메뉴 미리보기"
// 		,	west__slideTrigger_open:	"mouseover"

//  		,	south__size:		45
 		,	south__initClosed:	false
 		,	south__initHidden:	false
 		,	south__resizable:			false	// OVERRIDE the pane-default of 'resizable=true'
		,	south__spacing_open:		0		// no resizer-bar when open (zero height)
		,	south__spacing_closed:		20	
	});

// 	$("body").css("margin", "10px");
	
	myLayout.allowOverflow('north');

	searchTel();

	var pCode = Request("pCode");
	var sCode = Request("sCode");
	openTreeMenu( pCode, sCode );

	var isiPad = navigator.userAgent.toLowerCase().indexOf("ipad") > -1;
	
	// tree resize 

 	$(window).bind('resize', function() { setTimeout(function() {
 		var hasXScrollBar = $('body').width() < 970;
		if (window.pCode == 01) {
			$("#menu_area").css("height", $(window).height() - ((isiPad)?178:(hasXScrollBar)?196:179));	//-180
 			$("#mail_left_layer").css("height", $(window).height() - ((isiPad)?224:(hasXScrollBar)?241:224));	//-190			
		} else {
			$("#menu_area").css("height", $(window).height()- ((isiPad)?189:(hasXScrollBar)?206:189));	//-190
		}
		$("#if_list").height($(window).height() - ((isiPad)?130:(hasXScrollBar)?147:130)); //((isiPad)?127:((hasXScrollBar)?144:127))
		$("#if_list").width($(window).width() -226);
	}, 0);}).trigger('resize');


// 	var i = 0;
// 	$(window).bind('resize', function() {
// 		consolelog($("#if_list").height() + " " + $("#if_list").css("height"));
// 		consolelog($(".ui-layout-center").height() + " " + $(".ui-layout-center").css("height"));
		
// 		consolelog(i++ + ". body: " + $('body').width() + " x " + $('body').height());
// 		consolelog(i++ + ". main: " + $(window).width() + " x " + $(window).height());
// 	});
	
	// menu map create
	jkmegamenu.render($);
	
// 	if( isiPad > -1 ) {
// 		$('.ui-layout-south').toggle();
// 	}

	if (!isiPad) {
		$("html").css({"overflow-x":"auto","overflow-y":"hidden"});
		$("body").css({"overflow-x":"auto","overflow-y":"hidden"});
	} else {
		$("html").css({"-webkit-overflow-scrolling":"touch","overflow":"auto"});
		$("body").css({"-webkit-overflow-scrolling":"touch","overflow":"auto"});
	}
	$("html").css({height:"100%"});
	$("body").css({position:"relative",height:"100%","margin":"0px 10px 0px 10px",padding:0,border:"none"});
});
</script>
<link rel='stylesheet' type='text/css' href='/common/css/main_sub.css'><!----2021리뉴얼추가---->
</head>
<body style="overflow: auto;">

	<!-- <body style="border: 1px solid #505050; margin:3px; background:#fff; min-width:1004px;">  -->
	<!--  style="border: 1px solid #505050; background:#fff; min-width:970px;" -->

	<div class="ui-layout-north"><!-- inherit -->
		<div id="log" ></div>
		<!-- 
		<script type="text/javascript" src="http://jqueryui.com/themeroller/themeswitchertool/"></script>
		<div id="switcher"></div>
		 -->
		<%@ include file="/top_include.jsp"%>
	</div>
	
<!-- 	<style> -->
<!-- 	.ui-layout-west {overflow-y:hidden; height:100%;} -->
<!-- 	</style> -->

<!-----2021리뉴얼---------->
 <div class="main_centent_box">
     <!-- 좌측 메뉴 시작-->
        <div class="left_centent_box">
            <div class="main_auto">
                 <div id="menu_area"  class="ui-corner-all">
                </div>
            </div>
        </div>
        <!-- 좌측 메뉴 끝-->    
         
        <!-- 우측 메뉴 시작-->
        <div class="right_centent_box">
            <div class="ui-layout-center">
            <iframe id="if_list" name="if_list" width="100%" height="100%" frameborder="0" scrolling="1" src="about:blank">
            </iframe>
            </div>
            <div class="ui-layout-south" style="border-color:#eee;">
            <table width="100%" height="26" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td  height="26" align="center"  class="copyright shadowText1">
                        <%=uservariable.campaignText %>
                        <!-- 2006 <b>G</b>aram<b> S</b>ystem <b>C</b>ompany All right reserved -->
                    </td>
                </tr>
            </table>
	    </div>
     </div>



	<div class="ui-layout-west" style="display:none; border-width: 0px 0px 0px 0px; padding:0px; background-color: inherit;">
		<!-- left -->	
		<table id="table_left" width="100%" heights=100% border="0" cellpadding="0" radius="0" border="#e0e0e0" bgcolors="#efefef">
		<tr>
		<td valign="top" style="border:1px solid #aaa; background-color:#dfdfdf;">
			
		<table border="0" height=37 width="100%" cellpadding="0" cellspacing="0" style="background-image:url(../common/images/bg_teamtitleOn.gif); position:relative; lefts:-1px; smargin-top:1px; height:37px; z-index:100;">
		<tr>
		<td align="center" colspan="3"><span id="menuTitle" style="font-size:11pt; letter-spacing:0.2em; font-weight:bold;">Load...</span></td>
		</tr>
		</table>
 
		<div id="menu_area" style="border:1px solid #aaa; width:180px; height:200px; overflow:auto; position:relative; 
		 margin:5px 5px ; padding:5px 5px; background-color:#f2f2f2; background-image:url('/common/images/left_bg.jpg'); background-repeat: no-repeat; background-position: bottom center;" class="ui-corner-all">
		</div>

		</td>
		</tr>
		</table>
		<!-- left -->
	</div>
	
	<div class="ui-layout-center" style="overflow: hidden;/*min-width:797px;633px*/min-width:765px; display:none; border-width: 0px 0px 0px 0px; padding:0px; background-color: white;">
		<iframe id="if_list" name="if_list" width="100%" height="100%" frameborder="0" scrolling="1" src="about:blank" style=" background-color: white;overflow: auto;min-width:763px;border-left:0px solid #aaa; border-bottom:1px solid #aaa; border-top:1px solid #aaa; border-right:1px solid #aaa;">
		</iframe>
	</div>
	
	<!-- <iframe id="if_list" name="if_list" class="ui-layout-center" width="100%" height="100%" frameborder="1" scrolling="auto" src="about:blank" 
			style="/*min-width:797px;633px*/ min-width:763px; overflow:hidden; margin-right:10px; border-left:1px solid #ccc; border-bottom:0px solid #fff; left:204px; background-color: blue;">
	</iframe> -->

	<div class="ui-layout-south" style="min-width:970px; display:none; overflow:hidden; bottom:38px; border:0px solid #fff;padding-bottom: 10px;background-color: inherit;">
		<table width="100%" height="26" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td background="/common/images/blue/bottom_line_bg.jpg" height="26" align="center" class="copyright shadowText1">
					<%=uservariable.campaignText %>
					<!-- 2006 <b>G</b>aram<b> S</b>ystem <b>C</b>ompany All right reserved -->
				</td>
			</tr>
		</table>
	</div>
	
<script type="text/javascript" src="/common/scripts/jkmegamenu.js">
/***********************************************
* jQuery Mega Menu- by JavaScript Kit (www.javascriptkit.com)
* jkmegamenu.js의 jkmegamenu.render($); 를 주석처리. index.jsp, main_sub.jsp의 document.ready 에서 호출하도록 수정.
***********************************************/
</script>

<script type="text/javascript">
//jkmegamenu.definemenu("anchorid", "menuid", "mouseover|click")
jkmegamenu.definemenu("megaanchor", "megamenu1", "click")
</script>

<style>
span.group-item-icon,
span.file-item-icon {
  display: inline-block;
  height: 16px;
  width: 16px;
  margin-left: -16px;
}
span.group-item-icon {
  background: url("/common/images/icons/admin_icon_7.jpg") no-repeat left 4px;
}

.ui-layout-south {
margin-top: 2px;
}

/* left menu scroll - hidden */
.ui-layout-west ui-layout-pane {
overflow: hidden;
}

</style>

</body>
</fmt:bundle>
</html>