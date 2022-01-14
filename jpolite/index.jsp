<%@ page contentType="text/html;charset=utf-8" %>
<%@ page import="nek.common.*" %>
<%@ page import="java.util.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ include file="/common/usersession.jsp"%>
<%
	String userDomain = uservariable.userDomain;
	String logoTxt = " ";
	String logoImg = "";
%>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<fmt:setLocale value="<%=loginuser.locale %>"/>
<fmt:bundle basename="messages">
<head>
<%
Long nowTimeL = new Date().getTime();

int port = request.getServerPort();
String baseURL = request.getScheme() + "://" + request.getServerName() + (port != 80 ? ":" + Integer.toString(port) : "") + request.getContextPath();

%>
<meta http-equiv="X-UA-Compatible" content="IE=Edge" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>

<title><%=logoTxt %>GroupWare System</title><%--=uservariable.campaignTitle --%>

<%-- <link rel="shortcut icon" href="<%=baseURL %>/common/images/starion_fav.png" /> --%>

<!--  jquery cdn -->
<link rel="stylesheet" href="/common/jquery/ui/1.10.3/themes/smoothness/jquery-ui.css" />
<!-- <link rel="stylesheet" href="/common/jquery/ui/1.8.16/themes/smoothness/jquery-ui.css" /> -->
<!-- <link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/css/base/jquery.ui.all.css" />jquery-ui-1.8.16 base CSS -->

<!-- <script src="/common/jquery/js/jquery-1.9.1.js"></script> -->
<!-- <script src="/common/jquery/js/jquery-1.10.1.min.js"></script> -->

<!-- <script type="text/javascript" src="/common/jquery/js/jquery-1.6.4.min.js"></script>  -->
<script src="/common/jquery/js/jquery-1.7.1.js" type="text/javascript"></script>

<!-- <script src="/common/jquery/ui/1.8.16/jquery-ui.min.js" type="text/javascript"></script> -->
<script src="/common/jquery/ui/1.10.3/jquery-ui.js"></script>

<!-- <link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/ui/1.8.16/jquery-ui.garam.css" /> -->

<!-- jpolite -->
<link rel="stylesheet" href="css/screen.css" type="text/css" media="screen"/>

<!-- jpolite silver mode -->
<link rel="stylesheet" title="silver" href="css/style.css" type="text/css" media="screen"/>

<!-- RSS Plug-in -->
<!-- <link rel="stylesheet" type="text/css" href="/common/jquery/plugins/FeedEk/FeedEk.css"/> -->
<!-- <script type="text/javascript" src="/common/jquery/plugins/FeedEk/FeedEk.js"></script> -->

<!-- dhtmlwindow 2012-11-15 -->
<link rel="stylesheet" href="/common/libs/dhtmlwindow/1.1/dhtmlwindow.css" type="text/css" />
<script type="text/javascript" src="/common/libs/dhtmlwindow/1.1/dhtmlwindow.js"></script>

<!-- dhtmlmodal 2013-03-11 -->
<link rel="stylesheet" href="/common/libs/dhtmlmodal/1.1/modal.css" type="text/css" />
<script type="text/javascript" src="/common/libs/dhtmlmodal/1.1/modal.js"></script>

<!-- modaldialog Plug-in -->
<script src="/common/jquery/plugins/modaldialogs.js"></script>

<!-- chosen -->
<!-- <link rel="stylesheet" type="text/css" media="screen" href="/common/jquery/plugins/chosen-master/chosen/chosen.css" /> -->
<!-- <script src="/common/jquery/plugins/chosen-master/chosen/chosen.jquery.min.js" type="text/javascript"></script> -->

<!-- weather -->
<script src="/common/jquery/plugins/zweatherfeed-121/jquery.zweatherfeed.min.js" type="text/javascript"></script>
<!-- Example page styling (not required) -->
<link href="/common/jquery/plugins/zweatherfeed-121/example.css" rel="stylesheet" type="text/css" />

</head>

<body classs='normal' style="min-width:1194px; heights:950px; margin:10px; wsidth:1194px;" onloads="switchTheme('silver');">

<style>
#top {}
#top html,body,div,span,applet,object,iframe,h1,h2,h3,h4,h5,h6,p,blockquote,
pre,a,abbr,acronym,address,big,cite,code,del,dfn,em,font,img,ins,kbd,q,s,samp,small,strike,
strong,sub,sup,tt,var,b,u,i,center,dl,dt,dd,ol,ul,li,fieldset,form,label,legend,table,caption,
tbody,tfoot,thead,tr,th,td{font-family:Verdana, Gulim; margin:0;padding:0;border:0;outline:0;font-size:9pt;vertical-align:baseline_a;background:null}
/*
body{line-height:1}blockquote,
q{quotes:none}blockquote:before,blockquote:after,q:before,q:after{content:'';content:none}:
focus{outline:0}ins{text-decoration:none}del{text-decoration:line-through}table{border-collapse:collapse;border-spacing:0} */
#top table { }
#top a { font-size:9pt; text-decoration:none; height:100%; }
#top th, td {padding:0xp; margin:0px; }
#top hr, p, ul, ol, dl, pre, blockquote, address, table, form {  }
#top .msub {color:#FFFFFF;text-decoration:none; font-weight:bold; letter-spacing:-1px;}
#top .msub a:link {color:#FFFFFF;text-decoration:none; font-weight:bold; letter-spacing:-1px;}
#top .msub a:visited {color:#FFFFFF;text-decoration:none; font-weight:bold; letter-spacing:-1px;}
#top .msub a:active {color:#FFFFFF;text-decoration:none; font-weight:bold; letter-spacing:-1px;}
#top .msub a:hover {color:#FFFFFF;text-decoration:underline; font-weight:bold; letter-spacing:-1px;}

#ui-tabs-1 {padding:0px;}
#ui-tabs-2 {padding:0px;}

/* h1 { */
/* 	font: 4em normal Arial, Helvetica, sans-serif; */
/* 	padding: 20px;	margin: 0; */
/* 	text-align:center; */
/* } */

/* h1 small{ */
/* 	font: 0.2em normal  Arial, Helvetica, sans-serif; */
/* 	text-transform:uppercase; letter-spacing: 0.2em; line-height: 5em; */
/* 	display: block; */
/* } */

/* h2 { */
/*     font-weight:700; */
/*     color:#bbb; */
/*     font-size:20px; */
/* } */

/* h2, p { */
/* 	margin-bottom:10px; */
/* } */

/* @font-face { */
/*     font-family: 'BebasNeueRegular'; */
/*     src: url('BebasNeue-webfont.eot'); */
/*     src: url('BebasNeue-webfont.eot?#iefix') format('embedded-opentype'), */
/*          url('BebasNeue-webfont.woff') format('woff'), */
/*          url('BebasNeue-webfont.ttf') format('truetype'), */
/*          url('BebasNeue-webfont.svg#BebasNeueRegular') format('svg'); */
/*     font-weight: normal; */
/*     font-style: normal; */

/* } */

/* .container {width: 75px; margin: 0 auto; overflow: hidden;} */

.clock {float:left; width:70px; height:19px; margin:2px 1px 0px 5px; padding:2px 1px 0px 4px; border:1px solid #dfdfdf; background-color:#efefef;   }
#Date { font-family:'BebasNeueRegular', Arial, Helvetica, sans-serif; font-size:36px; text-align:center; text-shadow:0 0 5px #00c6ff; }

.clock ul { swidth:75px; margin:0 auto; padding:0px; list-style:none; text-align:center; }
.clock ul li { line-height: 150%; display:inline; font-size:0.9em; font-weight:bold; text-align:center; font-family:'tahoma', Arial, Helvetica, sans-serif; colors:#3072b3; text-shadow:1px 1px 0 #bbb; /*text-shadows:-1px -1px 0 rgba(0,0,0,0.3);*/ margin:0px; float:left;}

#point { padding:0px 1px; position:relative; top: -2px; -moz-animation:mymove 1s ease infinite; -webkit-animation:mymove 1s ease infinite;  }
.left_centent_box{margin-top:0 !important;top:0px !important;}
 body{background:#fff !important;overflow:auto !important;}
 .user_info_right{width:100% !important;float:none !important;text-align: center !important;}
 .main_centent_box{background:#f7f7f7 !important;}
 .left_centent_box,.right_centent_box{height:100% !important;overflow:hidden !important;}
@-webkit-keyframes mymove 
{
0% {opacity:1.0; text-shadow:0 0 20px #00c6ff;}
50% {opacity:0; text-shadow:none; }
100% {opacity:1.0; text-shadow:0 0 20px #00c6ff; }	
}

@-moz-keyframes mymove 
{
0% {opacity:1.0; text-shadow:0 0 20px #00c6ff;}
50% {opacity:0; text-shadow:none; }
100% {opacity:1.0; text-shadow:0 0 20px #00c6ff; }	
}

</style>

<center>

<div class="all_centent_box" style="height:auto;overflow:hidden;">
    <div class="top_centent_box">
        <!-- TOP MENU INCLUDE -->
        <%@ include file="/top_include.jsp"%>
        <!-- TOP MENU INCLUDE -->
    </div>
    <!-- 전체 크기 _메인 -->
    <div class="main_centent_box">
        <!-- 좌측 메뉴 시작-->
        <div class="left_centent_box">
            <div class="main_auto">
            
            <% if(!loginId.equals("taxinv") && !loginId.equals("abcde") && !loginId.equals("bigband")
											&& !loginId.equals("big_cam11") && !loginId.equals("big_cam12") && !loginId.equals("big_cam13")
											&& !loginId.equals("big_cam21") && !loginId.equals("big_cam22") && !loginId.equals("big_cam23")
											&& !loginId.equals("big_cont1") && !loginId.equals("big_cont2") && !loginId.equals("big_cs1")
											&& !loginId.equals("big_cs2") && !loginId.equals("big_stra1") && !loginId.equals("big_stra2")
											&& !loginId.equals("big_sup1") && !loginId.equals("big_sup2")){%> 
                
                <!---- Quick Menu----->
                <div class="left_box Quick_box" style="padding-top: 0;">
                    <h3>Quick Menu</h3>
                    <ul class="Quick_ul">
                        <li onClick="javascript:qmenu(1);"><img src="/common/images/icon_2/img_02.png"><div>편지쓰기</div></li>
                        <li onClick="javascript:qmenu(3);"><img src="/common/images/icon_2/img_03.png"><div>결재작성</div></li>
                        <li onClick="javascript:qmenu(5);"><img src="/common/images/icon/img_04.png"><div>쪽지작성</div></li>
                        <li onClick="javascript:qmenu(2);"><img src="/common/images/icon/img_05.png"><div>일정작성</div></li>
                        <li onClick="javascript:openTreeMenu('07', 'MENU070101');"><img src="/common/images/icon/img_06.png"><div>주소록</div></li>
                    </ul>
                </div>
                <%} %>
            
                <!-- calendar area -->
                <div id="cal" style="border:1px solid #ddd; float:left;padding:0;margin-top:12%;" class="left_box">
                    <div id="datepicker" style="float:left;width:50%; "></div>
                    <div id="sche" style="float:right; width:48%;border-left: 1px solid #eee; height:156px;overflow: auto; overflow-x:hidden;">
                    </div>
                </div>
                
                <!---- 금주생일자----->
                <div class="left_box">
                    <h3>금주생일자</h3>
                    <div id="birthDiv" class="birthDiv" style="border:1px solid #eee;margin:5% 0;">
	                 <table width=100% border="1" cellspacing="0" cellpadding="0"  class="birthDiv" style="overflow: auto;">
                        <tr height="100%">
                            <td align="center" valign="top" id="birthday">
                                <table width="100%" border="0">
                                    <tr height="95" >
                                        <td align="center">
                                            <fmt:message key="t.no.birth"/> <!-- 생일자가 없습니다. -->
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        </table>
                    </div>
                </div>
                
                <!---- 날씨-------->
                <div class="left_box ">
                    <h3>날씨정보</h3>
                    <div style="margin: 2% auto 0;">
                        <iframe width="100%" height="200" src="https://forecast.io/embed/#lat=37.5662&lon=126.9785&name=서울&color=&font=arial&units=si" frameborder="0"></iframe>
                    </div>
                </div>
                
                
                
             </div>
        </div>
        <!-- 좌측 메뉴 끝-->
        
        
        <!-- 우측 메뉴 시작-->
        <div class="right_centent_box">
           <!--- 왼쪽 아이콘 메뉴---->
               <div class="left_box_menu">
                    <% 	if (loginId.equals("taxinv") || loginId.equals("abcde"))  { %>
                    <ul>
						<li onClick="openTreeMenu('02','MENU020201');">
                            <div class="count"><div class="speech-bubble"><span id="appr_idx1">0</span></div></div>
                            <img src="/common/images/icon_2/img_08.png">
                            <div class="text_btn">전자결재</div>
                        </li>
                    </ul>
                    <%	}else if (loginId.equals("bigband") || loginId.equals("big_cam11") || loginId.equals("big_cam12") || loginId.equals("big_cam13")
		   		   || loginId.equals("big_cam21") || loginId.equals("big_cam22") || loginId.equals("big_cam23") || loginId.equals("big_cont1")
		   		   || loginId.equals("big_cont2") || loginId.equals("big_cs1") || loginId.equals("big_cs2") || loginId.equals("big_stra1")
		   		   || loginId.equals("big_stra2") || loginId.equals("big_sup1") || loginId.equals("big_sup2"))  { %>
					<ul>
						<li onClick="openTreeMenu('02','MENU021101');">
                            <div class="count"><div class="speech-bubble"><span id="appr_idx1">0</span></div></div>
                            <img src="/common/images/icon_2/img_08.png">
                            <div class="text_btn">전자결재</div>
                        </li>
                    </ul>
					<%}else{ %>
					<ul>
                        <li onclick="openTreeMenu('01','MENU010202');">
                            <div class="count"><div class="speech-bubble"><span id="appr_idx5">0</span></div></div>
                            <img src="/common/images/icon_2/img_07.png">
                            <div class="text_btn">메일</div>
                        </li>
                        <li onClick="openTreeMenu('02','MENU020201');">
                            <div class="count"><div class="speech-bubble"><span id="appr_idx1">0</span></div></div>
                            <img src="/common/images/icon_2/img_08.png">
                            <div class="text_btn">전자결재</div>
                        </li>
                        <li onClick="openTreeMenu('01','MENU010302');">
                            <div class="count"><div class="speech-bubble"><span id="appr_idx6">0</span></div></div>
                            <img src="/common/images/icon_2/img_09.png">
                            <div class="text_btn">쪽지</div>
                        </li>
                        <li onClick="javascript:openTreeMenu('04', 'MENU041001');">
                            <img src="/common/images/icon_2/img_10.png">
                            <div class="text_btn">일정관리</div>
                        </li>
                        <li onClick="javascript:openTreeMenu('03', 'MENU0301');">
                            <img src="/common/images/icon_2/img_11.png">
                            <div class="text_btn">문서관리</div>
                        </li>
                        <li onClick="javascript:openTreeMenu('07', 'MENU0705');">
                            <img src="/common/images/icon_2/img_12.png">
                            <div class="text_btn">업무지원</div>
                        </li>
                        <li onClick="javascript:openTreeMenu('05', 'MENU0501');">
                            <img src="/common/images/icon_2/img_13.png">
                            <div class="text_btn">게시판</div>
                        </li>
                        <li onClick="javascript:openTreeMenu('10', 'MENU1003');">
                            <img src="/common/images/icon_2/img_14.png">
                            <div class="text_btn">IMS</div>
                        </li>
                        <li onClick="javascript:openTreeMenu('07','MENU0705');">
                            <img src="/common/images/icon_2/img_15.png">
                            <div class="text_btn">임직원정보</div>
                        </li>
                        <li onClick="javascript:openTreeMenu('08', 'MENU0801');">
                            <img src="/common/images/icon_2/img_16.png">
                            <div class="text_btn">환경설정</div>
                        </li>
                    </ul>
                    <%	} %>
                </div>
             <div class="right_float">
           <!---- 환율정보----->
                <div class="left_box left_footer_right">
                    <div class="iframe_position">
                       <iframe src="https://sbiz.wooribank.com/biz/Dream?withyou=FXCNT0007&rc=0&divType=1&lang=KOR" frameBorder=0 width=100% scrolling=no height=100 topmargin="0" name=irate marginWidth=0 marginHeight=0 title="무료환율표A형"></iframe>		
                    </div>                           
                </div>
                
                <!----공지사항-------->
                <div class="right_box right_01">
                    <h3><span class="h3_left"><img src="/common/images/icon/img_19.png">공지사항</span>
                    <% if(!loginId.equals("taxinv") && !loginId.equals("abcde") && !loginId.equals("bigband")
							&& !loginId.equals("big_cam11") && !loginId.equals("big_cam12") && !loginId.equals("big_cam13")
							&& !loginId.equals("big_cam21") && !loginId.equals("big_cam22") && !loginId.equals("big_cam23")
							&& !loginId.equals("big_cont1") && !loginId.equals("big_cont2") && !loginId.equals("big_cs1")
							&& !loginId.equals("big_cs2") && !loginId.equals("big_stra1") && !loginId.equals("big_stra2")
							&& !loginId.equals("big_sup1") && !loginId.equals("big_sup2")){%> 
                    <span class="h3_right" onClick="javascript:openTreeMenu('05','MENU0501');"><img src="/common/images/icon/+.png"></span>
                    <%} %>
                    </h3>
                    <!-- 공지사항 -->
                    <div class="cont_list_box">
                        <div class="moduleFrame nobg">
                            <div id="announce" class="moduleContent" ></div>
                        </div> 
                    </div>
                </div>
                
             </div> 
             
             <!------받은메일함------>
            <div class="cont_right_main">
                <ul class="cont_left">
                    <li>
                        <h3 class="h3_01"><span class="h3_left"><img src="/common/images/icon/img_17.png"></span>
                        <% if(!loginId.equals("taxinv") && !loginId.equals("abcde") && !loginId.equals("bigband")
							&& !loginId.equals("big_cam11") && !loginId.equals("big_cam12") && !loginId.equals("big_cam13")
							&& !loginId.equals("big_cam21") && !loginId.equals("big_cam22") && !loginId.equals("big_cam23")
							&& !loginId.equals("big_cont1") && !loginId.equals("big_cont2") && !loginId.equals("big_cs1")
							&& !loginId.equals("big_cs2") && !loginId.equals("big_stra1") && !loginId.equals("big_stra2")
							&& !loginId.equals("big_sup1") && !loginId.equals("big_sup2")){%> 
                        <span class="h3_right" onClick="openTreeMenu('01','MENU010202');"><img src="/common/images/icon/+.png"></span>
                        <%} %>
                        </h3>
                        <div class="cont_list_box">
                        <h2>받은메일함</h2>
                        <div class="moduleFrame nobg">
                        <div id="tabs-mail" class="tabs moduleContent" style="padding-top:0 !important;padding-bottom:0 !important;">
                            <ul class="tabsul">
                                <li style="font-size:9pt;"><a href="/mail/mail_front.jsp?listCount=6" data-pcode="01" data-scode="MENU010202"></a></li>
                            </ul>
                <!-- 			<div id="tabs-mail-1" style="padding:0px; "></div> -->
                <!-- 			<div id="tabs-mail-2" style="padding:0px; "></div> -->
                        </div>
                    </div>
                    </div>
                    </li>
                    <li>
                        <h3 class="h3_03"><span class="h3_left"><img src="/common/images/icon/img_20.png"></span>
                        <% if(!loginId.equals("taxinv") && !loginId.equals("abcde") && !loginId.equals("bigband")
							&& !loginId.equals("big_cam11") && !loginId.equals("big_cam12") && !loginId.equals("big_cam13")
							&& !loginId.equals("big_cam21") && !loginId.equals("big_cam22") && !loginId.equals("big_cam23")
							&& !loginId.equals("big_cont1") && !loginId.equals("big_cont2") && !loginId.equals("big_cs1")
							&& !loginId.equals("big_cs2") && !loginId.equals("big_stra1") && !loginId.equals("big_stra2")
							&& !loginId.equals("big_sup1") && !loginId.equals("big_sup2")){%> 
                        <span class="h3_right" onClick="javascript:openTreeMenu('02', 'MENU020201');"><img src="/common/images/icon/+.png"></span>
                        <%} %>
                        </h3>
                        <div class="cont_list_box">
                            <!-- approval -->
                            <div class="moduleFrame nobg">
                                
                                <div id="tabs-approval" class="tabs moduleContent" style="height:170px; border:0px;">
                                    <ul class="tabsul" style="border:0px solid #ddd; border-bottom:1px solid #ddd; padding-left:10px; background-color: #fff;">
                                        <li><a href="/approval/widget.htm?listCount=5&ctype=1" data-pcode="02" data-scode="MENU020201"><img src="../common/images/icon-document.png" align="absmiddle" />&nbsp;<fmt:message key='main.approval.tab'/><!--  <span style="color:red; font-weight:bold;">(1건)</span> --> </a></li>
                                        <li><a href="/approval/widget.htm?listCount=6&ctype=2" data-pcode="02" data-scode="MENU020202"><img src="../common/images/icon-document-arrow.png" align="absmiddle" />&nbsp;<fmt:message key='appr.menu.ing.appr'/><!--  3 건 --></a></li>
                                        <li><a href="/approval/widget.htm?listCount=6&ctype=3" data-pcode="02" data-scode="MENU020301"><img src="../common/images/icon-document-epub.png" align="absmiddle" />&nbsp;<fmt:message key='main.completed'/><!--  5 건 --></a></li>
                                    </ul>
                        <!-- 			<div id="tabs-approval-1" style="padding:0px; "></div> -->
                        <!-- 			<div id="tabs-approval-2" style="padding:0px; "></div> -->
                        <!-- 			<div id="tabs-approval-3" style="padding:0px; "></div> -->
                                </div>
                            </div>
                        </div>
                    </li>
                </ul>
                <ul class="cont_right">
                    <li>
                        <h3 class="h3_02"><span class="h3_left"><img src="/common/images/icon/img_18.png"></span>
                        <% if(!loginId.equals("taxinv") && !loginId.equals("abcde") && !loginId.equals("bigband")
							&& !loginId.equals("big_cam11") && !loginId.equals("big_cam12") && !loginId.equals("big_cam13")
							&& !loginId.equals("big_cam21") && !loginId.equals("big_cam22") && !loginId.equals("big_cam23")
							&& !loginId.equals("big_cont1") && !loginId.equals("big_cont2") && !loginId.equals("big_cs1")
							&& !loginId.equals("big_cs2") && !loginId.equals("big_stra1") && !loginId.equals("big_stra2")
							&& !loginId.equals("big_sup1") && !loginId.equals("big_sup2")){%> 
                        <span class="h3_right" onClick="javascript:openTreeMenu('05','MENU0511');"><img src="/common/images/icon/+.png"></span>
                        <%} %>
                        </h3>
                        <div class="cont_list_box">
                            <!-- board -->
                            <div class="moduleFrame nobg">
                        <!-- 		<div id="board" class="moduleContent" style="margin:3px 3px; height: 170px;"></div> -->
                                <div id="tabs-community" class="tabs moduleContent" style="    height: auto !important;">
                                    <ul class="tabsul">
                                        <li><a href="/bbswork/widget.htm?listCount=5" data-pcode="05" data-scode="MENU0511"><img src="../common/images/icon-document.png" align="absmiddle" />&nbsp;<fmt:message key='main.Work.Board'/><!-- 업무게시판 --></a></li>
                        <%-- 				<li><a href="/bbs/widget_board.htm?endNum=6" data-pcode="05" data-scode="MENU0512"><img src='../common/images/NN.gif' align="absmiddle" />&nbsp;<fmt:message key='bbs.board.newest'/><!-- 최근글 목록 --></a></li> --%>
                        <!-- 				<li><a href="/bbs/widget_team.htm?listCount=6&topCode=2014101010370156" data-pcode="05" data-scode="MENU0511"><img src="../common/images/icon-document-arrow.png" align="absmiddle" />&nbsp;갤러리</a></li> -->
                                        <li><a href="/bbs/widget.htm?listCount=5&bbsId=bbs00000000000004" data-pcode="05" data-scode="MENU0505"><img src="../common/images/icon-document-arrow.png" align="absmiddle" />&nbsp;<fmt:message key='main.Free.Board'/><!-- 자유게시판 --></a></li>
                                    </ul>
                        <!-- 			<div id="tabs-approval-1" style="padding:0px; "></div> -->
                        <!-- 			<div id="tabs-approval-2" style="padding:0px; "></div> -->
                        <!-- 			<div id="tabs-approval-3" style="padding:0px; "></div> -->
                                </div>
                            </div>
                        </div>
                    </li>
                    <li>
                        <h3 class="h3_04"><span class="h3_left"><img src="/common/images/icon/img_21.png"></span>
                        <% if(!loginId.equals("taxinv") && !loginId.equals("abcde") && !loginId.equals("bigband")
							&& !loginId.equals("big_cam11") && !loginId.equals("big_cam12") && !loginId.equals("big_cam13")
							&& !loginId.equals("big_cam21") && !loginId.equals("big_cam22") && !loginId.equals("big_cam23")
							&& !loginId.equals("big_cont1") && !loginId.equals("big_cont2") && !loginId.equals("big_cs1")
							&& !loginId.equals("big_cs2") && !loginId.equals("big_stra1") && !loginId.equals("big_stra2")
							&& !loginId.equals("big_sup1") && !loginId.equals("big_sup2")){%> 
                        <span class="h3_right" onClick="javascript:openTreeMenu('01','MENU010302');"><img src="/common/images/icon/+.png"></span>
                        <%} %>
                        </h3>
                        <div class="cont_list_box">
                            <h2>쪽지함</h2>
                            <div class="cont_list_box_div"><c:import url="/notification/widget.htm?boxId=1" charEncoding="utf-8" /></div>
                        </div>
                    </li>
                </ul>
            </div>
                
        </div>
        <!-- 우측 메뉴 끝-->
    </div>
</div>

	
<div id="header" style="display:none; width: 925px; background-color:#fff; float: left; margin-top:5px; border:1px solid #e4e4e4; border-width:0px 0px 1px 0px; height:20px;">
	<!-- <div id="logo"></div>
	<div id="title">A Lightweight Portal Framework based on jQuery</div>
	 -->
	<ul id="main_nav">
		<li id="t1" style="width:65x; height:20px; line-height:20px; "><b class="hover" style=" font-size:9pt;"><fmt:message key='main.common.screen'/><!-- 공통화면 --></b><fmt:message key='main.common.screen'/><!-- 공통화면 --></li>
<!-- 		<li id="t2"><b class="hover">TAB 1</b>TAB 1</li> -->
	</ul>
	 
<!-- 	<div id="info_bar" style="line-height:2px; height:2px; border:0px solid red; background-color:#fff;"> -->
<!-- 		<b id="loading"></b><b id="menu_btn"></b><i class="left hint">Module menu</i> -->
<!-- 		<i class="right"> -->
<!-- 			<b id="maxAll" title="Expand All Modules"></b> -->
<!-- 			<b id="minAll" title="Collapse All Modules"></b> -->
<!-- 		</i> -->
<!-- 		<i class="hint right">Adjust module appearance</i> -->
<!-- 	</div> -->
</div>

	<!--  portlet width handle : screen.css 에 설정됨. modules.js를 통해 width 등 클래스 핸들링 -->
	<div id="module_menu" class="jqmWindow" style="background-color:#fff;"></div>

	<div id="c2" class="cc" style="display:none;"></div>
	<div id="c1" class="cc" style="display:none;"></div>
	<div id="c3" class="cc" style="display:none;"></div>
	<!-- <hr style="line-height:0px; height:0px; border:0px;"> -->
	<!-- 1 records -->
	
<!-- 	<div id="c4" class="cc"></div> -->
	<div id="c5" class="cc" style="display:none;"></div>
	<div id="c6" class="cc" style="display:none;"></div>
	<!-- <hr style="line-height:0px; height:0px; border:0px;"> -->
	<!-- 2 records -->
 
 	<!-- 
	<div id="c7" class="cc" style="margin-left:3px; margin-top:10px; float:left; width:920px; display:none;">
		<div class="module nobg" id="m104:t1" style="border:0px">
			<div class="moduleFrame">
				<div class='moduleHeader ui-corner-all' style="border: 1px solid #d2d2d2; sdisplay:none;">
					<div class='moduleTitle' style="margin:4px 3px;">휴가자 및 출장 정보</div>
					<div class='moduleActions' style="display:none;">
						<b title="Collapse" class="actionMin"></b>
						<b title="Expand" class="actionMax"></b>
						<b title="Close" class="actionClose"></b>
					</div>
				</div>
				<div class='moduleContent' style="height:152px; margin: 0px 0px; "> 
					<div class="span-8" style="width:28%; margin-left:4px; spadding-top:3px; border:0px solid #e7566d; heightㄴ:180px;">
						<fieldset id="fieldset1" style="margin-lefts:10px; margins:3px; paddings:3px; border:1px solid #bbb; height:145px;">
						<legend style="margin:1px 10px; padding:0px 3px; border:1px; cursor:pointer;">
						<span class="mtitle"><img src="../common/images/icon-offline.png" align="absmiddle" />
							<fmt:message key="main.state.vavation"/>&nbsp; 휴가자 현황 </span> - <span id="appr_idx11">0</span><fmt:message key="main.people.vacation"/>&nbsp; 명 휴가중 
						</legend>
						<div id="vacation" style="width:100%;"></div>
						</fieldset>
					</div>
					
					<div class="span-8" style="spadding-top:3px; margin-left:10px; border:0px solid #579ae9; heightㄴ:180px; width:33%;">
						<fieldset style="margins:3px; paddings:3px; border:1px solid #bbb; height:145px;">
							<legend style="margin:1px 10px; padding:0px 3px; border:1px; cursor:pointer;">
							<span class="mtitle"><img src="../common/images/icon-away.png" border="0" align="absmiddle" />
								<fmt:message key="main.state.trip"/>&nbsp; 출장자 현황</span> - <span id="appr_idx12">0</span><fmt:message key="main.people.trip"/>&nbsp;명 출장중
							</legend>
							<div id="trip" style="width:100%; spadding-left:10px;"></div>
						</fieldset>
					</div>
					
					<div class="span-8" style="spadding-top:3px; margin-left:10px; border:0px solid #579ae9; heightㄴ:180px; width:325px;">
						<fieldset style="margins:3px; paddings:3px; border:1px solid #bbb; height:145px;">
							<legend style="margin:1px 10px; padding:0px 3px; border:1px; cursor:pointer;">
							<span class="mtitle"><img src="../common/images/icon-block-share.png" align="absmiddle" />
								자료실&nbsp;자료실</span>
							</legend>
							<div id="pds" style="width:100%; spadding-left:10px;"></div>
						</fieldset>
					</div>
					
					<div class="span-11" style="margin-left:1px; margin-top:5px; spadding-top:3px; padding-bottom:5px; border:0px solid #e7566d; float:left; width:375px; height:166px;">
						<div><img style="position:relative; top:-2px;" src="/common/images/icon-feed.png" align="absmiddle"/>&nbsp;<b>영어/한글 번역기</b></div>
						<iframe width=100% height=155 frameborder=1 scrolling="no" style="float:right; overflow: hidden; border: 1px solid #DDD; width: 100%; height: 145px; overflow:hidden; " src="/jpolite/modules/translate.html"></iframe>
					</div>

					<div class="span-11" style="margin-left:1px; margin-top:5px; spadding-top:3px; padding-bottom:5px; border:0px solid #e7566d; float:left; width:253px; height:168px; padding-right:12px;">
						<div><img style="position:relative; top:-2px;" src="/common/images/icon-feed.png" align="absmiddle" />&nbsp;<b>Daum News</b></div>
						<div id="divRss"></div>
					</div>
					
					<div class="span-11 last" style="margin-left:1px; margin-top:5px; spadding-top:3px; padding-bottom:5px; border:0px solid #e7566d; float:left; width:253px; height:168px; padding-right:12px;">
						<div><img style="position:relative; top:-2px;" src="/common/images/icon-feed.png" align="absmiddle"/>&nbsp;<b>Google News</b></div>
						<div id="divRssNaver"></div>
					</div>
				</div>
			</div>
		</div>
	</div>
	-->
	
</div><!--  End Content -->

</div>

</div>

</center>

<script type="text/javascript">

	function goSystem( args ) {
		if ( args == 1 ) {
			window.open("http://www.starion.co.kr:87/ePro/", "_blank"); 
		} else if (args == 2 ) {
			window.open("http://www.starion.co.kr:87/SnS/", "_blank");
		} else if (args == 3 ) {
			window.open("http://www.starion.co.kr:87/Isots/login.aspx" ,"_blank");
		} else if (args == 4 ) {
			window.open("http://www.starion.co.kr:87/eis/default.aspx", "_blank");
		}
		
	}

	// 상단 알림창 - 레이어
	function getNoticePopup() {
		$.ajax({
		    url: '/bbs/notice_popup.htm',
		    type: 'POST',
		    dataType: 'html',
		    success: function(data, text, request) {
		    	var tmp = data.split("</a>");
		    	for( var i=0; i < tmp.length-1; i++) {
			    	var topNoty = generate('topRight', 'alert', tmp[i] + "</a>");
			    	setTimeout(function() {
			    		$.noty.close(topNoty.options.id);
			    	}, 10000 );
		    	}
		    }
		});
	}
	
	function noticeTickerRead(docId) {
		var url = "/noticeticker/noticeticker_read.jsp?docid=" + docId;
		dhtmlwindow.open(
				url, "iframe", url, "noticeTickerRead", 
				"width=800px,height=500px,resize=1,scrolling=1,center=1", "recal"
			);
	}

	$.cookie('jpolite2layout',null);
	function getAnnounceData() {
		$.ajax({
		    url: '/bbs/widget.htm?listCount=7&bbsId=bbs00000000000000',
		    //url: '/jpolite/modules/weather.html',
		    //url: 'calendar_list_data.htm?start=2011110120&end=2011123020&_=1321270106013',
		    type: 'POST',
		    dataType: 'html',
		    success: function(data, text, request) {
		    	$("#announce").html( data );
		    }
		});
	}
	
	function getNewestData() {
		$.ajax({
		    url: '/bbs/widget_board.htm?endNum=6',
		    type: 'POST',
		    dataType: 'html',
		    success: function(data, text, request) {
		    	$("#newest").html( data );
		    }
		});
	}
	
	/* 메인화면 자유게시판 초기호출 */
	function getBbsData() {
		//return;
		$.ajax({
		    url: '/bbs/widget.htm?listCount=7&bbsId=bbs00000000000004',
		    //url: '/jpolite/modules/weather.html',
		    type: 'POST',
		    dataType: 'html',
		    success: function(data, text, request) {
		    	$("#board").html( data );
		    }
		});
	}
	
	function getApprovalIngData() {
		$.ajax({
		    url: '/approval/widget.htm?listCount=10&ctype=1',
		    //url: 'calendar_list_data.htm?start=2011110120&end=2011123020&_=1321270106013',
		    type: 'POST',
		    dataType: 'html',
		    success: function(data, text, request) {
		    	$("#tabs-1").html( data );
		    }
		});
	}
	
	function getVacationIngData() {
		$.ajax({
		    url: '/vacation/widget.jsp?listcount=6&ctype=1',
		    type: 'POST',
		    dataType: 'html',
		    success: function(data, text, request) {
		    	$("#vacation").html( data );
		    }
		});
	}

	// 생일자 가져오기
	function getBirthdayData() {
		$.ajax({
// 		    url: '/sche/birthdaywidget.jsp?listcount=6&ctype=1',
			url: '/sche/widget_birthday.jsp',
		    type: 'POST',
		    dataType: 'html',
		    success: function(data, text, request) {
		    	$("#birthday").html( data );
		    }
		});
	}
	
	function getPollData() {
		$.ajax({
			url: '/poll/widget.jsp',
		    type: 'POST',
		    dataType: 'html',
		    success: function(data, text, request) {
		    	$("#poll").html( data );
		    }
		});
	}
	
	function getTripIngData() {
		$.ajax({
		    url: '/trip/widget.jsp?listcount=6&ctype=1',
		    type: 'POST',
		    dataType: 'html',
		    success: function(data, text, request) {
		    	$("#trip").html( data );
		    }
		});
	}
	
	/* 메인화면 자료실 초기호출 */
	function getPdsData() {
		$.ajax({
		    url: '/bbs/widget.htm?listCount=5&bbsId=bbs00000000000002',
		    type: 'POST',
		    dataType: 'html',
		    success: function(data, text, request) {
		    	$("#pds").html( data );
		    }
		});
	}

	// 메인화면 최근 접속일시 가져오기
	function getlastLoginTime() {
		$.ajax({
		    url: '/common/getLastLoginTime.htm',
		    type: 'POST',
		    dataType: 'html',
		    success: function(data, text, request) {
		    	$("#lastLoginTime").html( data );
		    }
		});
	}
				
/* 	function setWidgetCount(apprType) {
		$.ajax({
		    url: '/approval/apprWidgetCount.htm?apprType=' + apprType,
		    type: 'POST',
		    dataType: 'text',
		    success: function(data, text, request) {
		    	var objSpan = document.getElementById("appr_idx" + apprType);
		    	objSpan.innerText = data + " 건";
		    }
		});
	} */ // 02/21 김광일
	
	function setWidgetCount(apprType) {
		var u_Str = "";
		
		switch(apprType)
		{
		case 5:	//전자메일 읽지 않은 수
			url_Str = '/mail/WidgetCount.jsp';
			break;
		case 6:	//사내쪽지 읽지 않은수
			url_Str = '/notification/WidgetCount.htm';
			break;
//		case 10:	//대여
//			url_Str = '/fixtures/data/fixturesWidgetCount.jsp';
			break;
		case 7:		// 제안문서
		case 8:		// 심사문서
			url_Str = '/proposal/data/proposalWidgetCount.jsp?menu=' + apprType;
			break;
		case 11: 	// 휴가자 수
			url_Str = '/vacation/data/widgetCount.jsp';
			break;
		case 12:	// 출장자 수
			url_Str = '/trip/data/widgetCount.jsp';
			break;
		default :	//전자결재 관련 카운터
			url_Str = '/approval/apprWidgetCount.htm?apprType='+ apprType;
			break;
		}
		
		$.ajax({
		    url: url_Str,
		    type: 'POST',
		    dataType: 'text',
		    success: function(data, text, request) {
		    	var objSpan = document.getElementById("appr_idx" + apprType);
		    	var cnt = parseInt($.trim(data));
		    	if (isNaN(cnt)) cnt = 0;
		    	objSpan.innerHTML = cnt;
		    }
		});
	}
	
	function getScheIngData(date) {
		$.ajax({
// 		    url: '/sche/widget.jsp?listcount=999&ctype=1&date=' + date,
		    url: '/schedule/widget.htm?listcount=999&ctype=1&date=' + date,
		    type: 'POST',
		    dataType: 'html',
		    success: function(data, text, request) {
		    	var dateHeight = $("#datepicker").height();	//메인화면 달력의 세로길이
		    	/**
		    		해당월이 총 몇주인가에 따라 달력의 세로 길이가 변한다.
		    		변하는 세로길이에 맞춰 생일자 항목의 세로 길이를 조정한다.
		    	*/
		    	if(dateHeight >= 180){	//6주
		    		$(".birthDiv").css("height", "97");
		    	}else if(dateHeight >= 159){	//5주
		    		$(".birthDiv").css("height", "115");
		    	}else if(dateHeight <= 138){	//4주
		    		$(".birthDiv").css("height", "138");
		    	}
		    	$("#sche").html( data );
		    }
		});
	}

function setTab_not_use() {
	//getAnnounceData();	사용않음
	
	$( "#tabs" ).tabs({
		ajaxOptions: {
			error: function( xhr, status, index, anchor ) {
				
				$( anchor.hash ).html(
					"Couldn't load this tab. We'll try to fix this as soon as possible. " +
					"If this wouldn't be a demo." );
				
				//alert( status );
			}
		}
	});
	
	//getBbsData();
	getVacationIngData();
	getBirthdayData();
	getPollData();		// 설문조사
	getTripIngData();
	getPdsData();	//업무자료실
	//getScheIngData("");
}
</script>
	
<script>
$(document).ready(function() {
	
	$( "#tabs" ).tabs();

	// calendar draw
 	$( "#datepicker" ).datepicker({		
 		dateFormat: 'yy-mm-dd',
 		onSelect: function(dateText, inst) { getScheIngData(dateText); },
 		onChangeMonthYear: function(year, month, inst){ getScheIngData(""); }//달력 월선택 변경시
 	});
 	
 	/*
	$("#go-system").chosen({
		default_text: "시스템 바로가기",
		disable_search_threshold: 6
 		//allow_single_deselect: true
	});

	$("#go-homepage").chosen({
		//no_results_text: "홈페이지 바로가기",
		disable_search_threshold: 7
 		//allow_single_deselect: true
	});
*/ 	

	getNoticePopup();	// 공지사항 팝업

	// Portal Counter	
	//1. 전자결재
	setWidgetCount(1);	//결재할 문서 수
// 	setWidgetCount(2);
// 	setWidgetCount(3);
// 	setWidgetCount(4);
 	
 	setWidgetCount(5);	//전자메일 수

 	setWidgetCount(6);	//사내쪽지
//  setWidgetCount(7);	//제안문서
//  setWidgetCount(8);	//제안심사
 	
// 	setWidgetCount(11);	//휴가자수
// 	setWidgetCount(12); //출장자수

	getScheIngData("");	//오늘의 일정 가져오기
	
//  getVacationIngData();	//휴가자 가져오기
 	getBirthdayData();		//생일자 가져오기
//  getPollData();			//진행설문 가져오기
// 	getTripIngData();		//출장자 가져오기
// 	getPdsData();		//자료실 가져오기
	getlastLoginTime();	//최근 접속일시 가져오기
	
	
	searchTel();
	
	//menu map crate
	jkmegamenu.render($);
	 	
	/*
 	$( "#tabs" ).tabs({
		ajaxOptions: {
			error: function( xhr, status, index, anchor ) {
				$( anchor.hash ).html( "weather Loading Error !" );
				//alert( 'err');
			}
		}
	});
 	*/
 	
 	$( "#tabs-approval" ).tabs({
		ajaxOptions: {
			error: function( xhr, status, index, anchor ) {
				$( anchor.hash ).html( "weather Loading Error !" );
				//alert( 'err');
			}
		}
	});
 	
 	$( "#tabs-community" ).tabs({
		ajaxOptions: {
			error: function( xhr, status, index, anchor ) {
				$( anchor.hash ).html( "weather Loading Error !" );
				//alert( 'err');
			}
		}
	});

 	$( "#tabs-mail" ).tabs({
		ajaxOptions: {
			error: function( xhr, status, index, anchor ) {
				$( anchor.hash ).html( "weather Loading Error !" );
				//alert( 'err');
			}
		}
	});

//  	 $( "#tabs-mail" ).tabs({
//  		beforeLoad: function( event, ui ) {
//  		ui.jqXHR.error(function() {
// 	 		ui.panel.html(
// 	 		"Couldn't load this tab. We'll try to fix this as soon as possible. " +
// 	 		"If this wouldn't be a demo." );
// 	 		});
//  		}
//  	});
 	 
 	getAnnounceData();
 	getNewestData();
 	getBbsData();
 	
	// 공지사항 tabs boarder 제거
 	$('#tabs > ul').removeClass('ui-widget-header');
 	$('ul').removeClass('ui-corner-all');

 // run the currently selected effect
 	function runEffect() {
 		 
	 	// get effect type from
	 	//var selectedEffect = $( "#effectTypes" ).val();
	 	var selectedEffect = "slide";
	 	// most effect types need no options passed by default
	 	var options = {};
	 	// some effects have required parameters
	 	if ( selectedEffect === "scale" ) {
	 	options = { percent: 0 };
	 	} else if ( selectedEffect === "size" ) {
	 	options = { to: { width: 200, height: 60 } };
 		}
 		// run the effect
 		$( "#effect" ).toggle( selectedEffect, options, 500 );
 		$( "#effect1" ).toggle( selectedEffect, options, 500 );
 	};
 	
 	 //callback function to bring a hidden box back
 	function callback() {
 		//$( "#effect1:none" ).removeAttr( "style" ).fadeOut();
 		$( "#effect1" ).toggle( selectedEffect, options, 500 );
 	};
 	
 	// set effect from select menu value
 	$( "#buttons" ).click(function() {
 		runEffect();
 		return false;
 	});
 	
 	$( "#wreload" ).click(function() {
 		weatherReload();
 		return false;
 	});

 	var ServerTimeL = <%=nowTimeL %>;
	var ServerTimeZ = 540 * 60000;
 	var ClientTimeL = new Date().getTime();
	var ClientTimeZ = new Date().getTimezoneOffset() * 60000;
 	var SyncTimeL = ClientTimeL - ServerTimeL;

 	function wTime(hoffset) {
 		var wDate = new Date();
 		var offset = hoffset * 3600000;
 		var tz = wDate.getTime() - SyncTimeL + offset + ServerTimeZ + ClientTimeZ;
 		wDate.setTime(tz);
 		var sDate = leftZero(wDate.getMonth()+1) + "-" + leftZero(wDate.getDate()) + " " + leftZero(wDate.getHours()) + ":" + leftZero(wDate.getMinutes());
 		return sDate;
 	}
 	
 	function ywTime(hoffset) {
 		var wDate = new Date();
 		var offset = hoffset * 3600000;
 		var tz = wDate.getTime() - SyncTimeL + offset + ServerTimeZ + ClientTimeZ;
 		wDate.setTime(tz);
 		var sDate = wDate.getFullYear() + "-" + leftZero(wDate.getMonth()+1) + "-" + leftZero(wDate.getDate()) + " " + leftZero(wDate.getHours()) + ":" + leftZero(wDate.getMinutes());
 		return sDate;
 	}
 	
 	function leftZero(num) { return ((num < 10)? "0": "") + num; }
 	
 	setInterval( function() {
 		// Create a newDate() object and extract the minutes of the current time on the visitor's
 		// var minutes = new Date().getMinutes();
 		// Add a leading zero to the minutes value
 		// for( var i=1; i < 11; i++ ) {
 		//	$("#min"+(i)).html(( minutes < 10 ? "0" : "" ) + minutes);
 		// }
 		
 		// HongKong
 		$(".hongkong").html(wTime(-1));
 		 
 		// Macau
  		$(".macau").html(wTime(-1));
 		
  		// Guangzhou
 		$(".guangzhou").html(wTime(-1));
  	
 		// LA
 		$(".la").html(wTime(-16));
 	
 		// Peicheng
 		$(".peicheng").html(wTime(-1));
 	
 		// Sydney
 		$(".sydney").html(wTime(+1));
 		
 		$("#localhours").html(ywTime(0));
	},1000);
 		
//  	setInterval( function() {
 		// Create a newDate() object and extract the hours of the current time on the visitor's
 		// var hours = new Date().getHours();
 		// Add a leading zero to the hours value
 		// $("#hours").html(( hours < 10 ? "0" : "" ) + hours);
 		// $("#hours1").html(( hours < 10 ? "0" : "" ) + hours);
 		// for( var i=1; i < 11; i++ ) {
 		// 	$("#hours"+(i)).html(( hours < 10 ? "0" : "" ) + hours);
 		// }
// 	}, 1000);
 	
 	// 국가 검색 사이트는 아래에서 참조
 	// http://www.zazar.net/developers/jquery/zweatherfeed/
 	// http://www.zazar.net/developers/jquery/zweatherfeed/example_location.html
 	
	function weatherReload() {
		$('#global1').html("");
		$('#global2').html("");
		$('#local').html("");
		
		//HongKong Macau Guangzhou 
		$('#global1').weatherfeed(['2165352','1887901','2161838'],{
			unit: 'c',
			image: true,
			country: true,
			highlow: true,
			wind: false,
			humidity: false,
			visibility: false,
			sunrise: false,
			sunset: false,
			forecast: false,
			link: false,
			woeid: true
		});
		// LA Peicheng Sydney 
		$('#global2').weatherfeed(['2442047','2137120','1105779'],{
			unit: 'c',
			image: true,
			country: true,
			highlow: true,
			wind: false,
			humidity: false,
			visibility: false,
			sunrise: false,
			sunset: false,
			forecast: false,
			link: false,
			woeid: true
		});
		
		// Seoul Busan Jeju
		$('#local').weatherfeed(['1132599','1132447','1132454'],{
			unit: 'c',
			image: true,
			country: false,
			highlow: true,
			wind: false,
			humidity: false,
			visibility: false,
			sunrise: false,
			sunset: false,
			forecast: false,
			link: false,
			woeid: true
		});
		
		setTimeout( function() {
			$('.weatherItem').css( 'background-image', function() {
				if ( this.style.backgroundImage.indexOf('20d.png') > -1 ) {
					this.style.backgroundImage = this.style.backgroundImage.replace(/20d\.png/gi,"28s.png");
				} else if ( this.style.backgroundImage.indexOf('20n.png') > -1 ) {
					this.style.backgroundImage = this.style.backgroundImage.replace(/20n\.png/gi,"28s.png");
				} else {
					this.style.backgroundImage = this.style.backgroundImage.replace(/d\.png/gi,"s.png");
					this.style.backgroundImage = this.style.backgroundImage.replace(/n\.png/gi,"s.png");
				}
			});
		}, 1000 );
	}
	
	function weatherResize() {
		//console.log("weatherResize");
		// 기본 d.png , n.png 를 s.png로 변경
		$('.weatherItem').css( 'background-image', function() {
			if ( this.style.backgroundImage.indexOf('20d.png') > -1 ) {
				this.style.backgroundImage = this.style.backgroundImage.replace(/20d\.png/gi,"28s.png");
			} else if ( this.style.backgroundImage.indexOf('20n.png') > -1 ) {
				this.style.backgroundImage = this.style.backgroundImage.replace(/20n\.png/gi,"28s.png");
			} else {
			this.style.backgroundImage = this.style.backgroundImage.replace(/d\.png/gi,"s.png");
			this.style.backgroundImage = this.style.backgroundImage.replace(/n\.png/gi,"s.png");
			}
		});
	}
	
	weatherReload();
	
	/* 국내 날씨 */
	/*
	setInterval( function() {
 		// Create a newDate() object and extract the minutes of the current time on the visitor's
 		var minutes = new Date().getMinutes();
 		// Add a leading zero to the minutes value
 		$("#localmin").html(( minutes < 10 ? "0" : "" ) + minutes);
	},1000);
 		
 	setInterval( function() {
 		// Create a newDate() object and extract the hours of the current time on the visitor's
 		var hours = new Date().getHours();
 		// Add a leading zero to the hours value
 		$("#localhours").html(( hours < 10 ? "0" : "" ) + hours);
	}, 1000);
 	*/	
	
 	
 	//$('.ui-datepicker').css( 'border', '1px solid #fff'); 	
 	//$(".moduleFrame").addClass("ui-corner-all");

 	/* 	
	$('#divRss').FeedEk({
// 		FeedUrl : 'http://media.daum.net/rss/part/primary/digital/rss2.xml',
		FeedUrl : 'http://www.daum.net/rss.xml',
		MaxCount : 10,
		ShowDesc : false,
		ShowPubDate:true
	});
	
	$('#divRssNaver').FeedEk({
// 		FeedUrl : 'http://media.daum.net/rss/part/primary/digital/rss2.xml',
// 		FeedUrl : 'http://www.zdnet.co.kr/services/rss/all/EUC/ZDNetKorea_News.asp',
		FeedUrl : 'http://news.google.co.kr/news?pz=1&ned=kr&hl=ko&topic=po&output=rss',
		MaxCount : 10,
		ShowDesc : false,
		ShowPubDate:true
	});
	*/
 	
 	$(".actionRefresh").bind("click", function() {
 		var moduleFrame = $(this).parents(".moduleFrame").eq(0);
 		if (moduleFrame.find(".moduleContent.ui-tabs").length > 0) {
 	 		var moduleContent = moduleFrame.find(".moduleContent.ui-tabs").eq(0);
 	 		var active = moduleContent.tabs("option", "active");
 	 		moduleContent.tabs("load", active);
 		} else {
 			// No Tabs
 		}
 	});

 	$(".actionMore").bind("click", function() {
 		var moduleFrame = $(this).parents(".moduleFrame").eq(0);
 		if (moduleFrame.find(".moduleContent.ui-tabs").length > 0) {
	 		var moduleContent = moduleFrame.find(".moduleContent.ui-tabs").eq(0);
	 		var active = moduleContent.tabs("option", "active");
	 		var a = moduleContent.find("ul>li a").eq(active);
	 		openTreeMenu(a.attr('data-pcode'), a.attr('data-scode'));
 		} else {
 			// No Tabs
 		}
 	});
});


</script>

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

ul.ui-menu {
	list-style-type: none;
	margin:5px;
	white-space:pre;
}

li.ui-menu-item {
	vertical-align:top;
	padding:3px;
	//width:400px;
	height:75px;
	float: left;
}

li.ui-menu-item a {
	text-decoration:none;
	padding:3px;
	padding-top:0px;
	line-height:16px;
	cursor:pointer;
}
/* .ui-dialog-titlebar {height:25px;} */


#ui-datepicker-div {
	display:none;
}

#aps {font-size:9pt; }
#aps table { border:1px solid blue; table-layout:fixed;}
#aps tr {height:24px;}
#aps tr:hover { background-color:#eee; }
#aps td {white-space:nowrap; text-overflow:ellipsis; overflow:hidden; line-height:12px; font-size:9pt; padding-left:0px; padding-right:2px; padding-bottom:2px; }

/* #aps a, font {color:#000; font-weight:normal; text-decoration:none; } */
#aps a:hover, font:hover {color:#09F; font-weight:bold; text-decoration:none;}
#aps .clip {white-space:nowrap; text-overflow:clip; overflow:hidden;}


#approval_front {}
#approval_front td	{text-overflow:ellipsis; overflow:hidden; white-space:nowrap;}
/* td	{text-overflow:ellipsis; overflow:hidden; white-space:nowrap;} */


.ui-datepicker{
	width : 100%;
	height: inherit;
	font-size:10px;
	border:1px soldi #fff; 
}
/* .ui-datepicker td {padding:0px;} */
.ui-datepicker td span, .ui-datepicker td a {
padding:0.2em;
/* padding-bottom: 0px; */
}
.ui-datepicker-today {
font-weight:bold;
}
.ui-datepicker th {
padding: .3em .3em;
}

.ui-tabs .ui-tabs-nav li a {
padding: .3em 1em;
}

.tabsul {
//background: #EFEFEF;
background: #fff;
border-bottom:1px solid #ddd;
}

table.ui-datepicker-calendar a.ui-state-default {font-weight:bold;}
.ui-datepicker-today {color:blue;}
/* table.ui-datepicker-calendar a.ui-state-highlight { background:#b6d3f5; color:blue; border:1px solid blue;} */
table.ui-datepicker-calendar a.ui-state-active { background:#b6d3f5; color:blue; border:1px solid blue;}
/* ui-state-highlight ui-state-active */

table.ui-datepicker-calendar {font-family:arial}

.ui-tabs .ui-tabs-panel {padding: 0px;}
.ui-tabs .ui-tabs-nav {padding: 0em .2em;}
.moduleContent {margin: 0px; padding: 2px;}

.ui-tabs .ui-tabs-nav li.ui-tabs-selected {padding-bottom: 0px;}

div#menu ul ul li {text-align: left;}

.ui-tabs .ui-tabs-nav li.ui-tabs-active a, .ui-tabs .ui-tabs-nav li.ui-state-disabled a, .ui-tabs .ui-tabs-nav li.ui-tabs-loading a {
font-weight: bold;
}

</style>
</body>
</fmt:bundle>
</html>