<%@ page language="java" pageEncoding="UTF-8"
	contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%---------------------------------------------------------
    파일명 : loginForm.jsp
    프로젝트명 : XXXX 프로젝트

    Copyright(c) 2012 LG CNS,  All rights reserved.

    설 명 : 본 화면은 로그인 정보를 입력받는 화면입니다.
    작성자 : XXX팀 OOO
-------------------------------------------------------------%>
<!DOCTYPE html>
<html lang="${sessionScope.USER_SESSION.languageCode}">
<head>
<meta http-equiv="x-ua-compatible" content="IE=edge">
<title>Web Common Framework</title>
<%@ include file="/WEB-INF/views/framework/header.jsp"%>
<script>
<%@ include file="/WEB-INF/views/framework/profile.jsp" %>
</script>
<script
	src="<%=request.getContextPath()%>/static/js/main.js?version=${version}"></script>
</head>

<body
	class="layout-tl main  <%= request.getAttribute("USE_SMALL_LAYOUT") %>">
	<div class="_introWrapper"></div>

	<div class="wrap">
		<header class="navbar navbar-fixed-top navbar-default navbar-inverse">
			<div class="container">
				<div class="navbar-header _logo">
					<h1>
						<a class="navbar-brand site" href="#"> <small></small></a>
					</h1>
				</div>
				<!-- /navbar-header -->
				<div class="scroll-wrap">
					<nav class="gnb" data-pos="1">
						<ul class="nav navbar-nav _menu _level1"></ul>
					</nav>
					<!-- /gnb -->
				</div>
				<!-- /scroll-wrap -->
				<div class="gnb-control">
					<button type="button" class="btn btn-link grd-prev"
						aria-label="왼쪽으로 이동">
						<span class="fa fa-caret-left" aria-hidden="true"></span>
					</button>
					<button type="button" class="btn btn-link grd-next"
						aria-label="오른쪽으로 이동">
						<span class="fa fa-caret-right" aria-hidden="true"></span>
					</button>
				</div>
				<!-- /gnb-control -->
				<div class="navbar-form navbar-right _profileBox">
					<!-- 
                    <div class="navbar-search">
                        <div class="input-group">
                            <input type="text" name="" class="form-control" placeholder="통합검색">
                            <span class="input-group-btn">
                                <button type="button" class="btn btn-link">
                                    <span class="fa fa-search" aria-hidden="true"></span>
                                </button>
                            </span>
                        </div> 
                    </div>
                     -->
					<p class="user-name _name text-right"></p>
					<!-- /dropdown -->
					<div class="dropdown config _profileBox">
						<button type="button"
							class="btn btn-ico btn-config dropdown-toggle"
							data-toggle="dropdown" aria-expanded="false" aria-label="환경설정">
							<span class="fa fa-th-large" aria-hidden="true"></span>
						</button>
						<div class="dropdown-menu" role="menu">
							<p class="user-name _name"></p>
							<p class="_title"></p>
							<hr>
							<ul>
								<li><a href="#" data-action="userProfile">My Page</a></li>
								<li><a href="#" data-action="userMenu">My Menu</a></li>
								<li><a href="#" data-action="shortcutMenu">Short Cut
										Menu</a></li>
								<li><a href="#" data-action="contactPoint">Contact
										Point</a></li>
								<li><a href="#" id="changeSize">사이즈변경</a></li>
							</ul>
						</div>
					</div>
					<!-- /dropdown -->
					<button type="button" class="btn btn-ico btn-signout"
						aria-label="Sign Out" data-action="logout">
						<span class="ico ico-sign-out" aria-hidden="true"></span>
					</button>
					<!-- /btn -->
				</div>
				<!-- /navbar-form -->
			</div>
			<!-- /container -->
		</header>
		<!-- /navbar -->

		<div class="container">
			<div class="row _wrapper">
				<aside class="sidebar left ui-widget-content _left" id="resizable">
					<header class="sidebar-header _menuHeader">
						<h2 class="_menuTitle"></h2>
						<div class="btn-group">
							<button type="button"
								class="btn btn-ico btn-favorite _favoriteButton"
								aria-label="Favorite Menu" data-status="CLOSED">
								<span class="ico ico-menu-favorite" aria-hidden="true"></span>
							</button>
							<button type="button"
								class="_closeButton btn btn-side-toggle left"
								aria-label="Panel control">
								<span class="fa fa-angle-left" aria-hidden="true"></span>
							</button>
						</div>
					</header>
					<!-- /sidebar-header -->

					<nav class="lnb _menuContent _menuBody">
						<ul class="nav nav-sidebar"></ul>
					</nav>
					<!-- /lnb -->

					<div class="favorite sr-only _menuContent _favoriteBody">
						<ul class="nav nav-tabs inner-tabs _favoriteHeader">
							<li class="active">
							    <a href="#lnbFavorit" data-toggle="tab" data-target="_selected">User</a>
							</li>
							<li>
							    <a href="#lnbRecent" data-toggle="tab" data-target="_all">Recent</a>
							</li>
						</ul>
						<!-- /inner-tabs -->
						<div class="tab-content inner-content">
							<div id="lnbFavorit" class="tab-pane active">
								<nav class="lnb bookmark">
									<ul class="nav _selected"></ul>
								</nav>
							</div>
							<div id="lnbRecent" class="tab-pane">
								<nav class="lnb recent">
									<ul class="nav _all"></ul>
								</nav>
							</div>
						</div>
					</div>
					<!-- /favorite -->
				</aside>
				<!-- /sidebar left -->

				<section class="page-content mdi-content">
					<div class="page-header mdi-tabs">
						<div class="scroll-wrap _header">
							<ul class="nav nav-tabs"></ul>
						</div>
						<!-- /scroll-wrap -->
						<div class="_toolBox mdi-util">
							<div class="mdi-control _moover">
								<button type="button" class="btn btn-ico prev _button _left" aria-label="왼쪽으로 이동">
									<span class="ico ico-mdi-prev" aria-hidden="true"></span>
								</button>
								<button type="button" class="btn btn-ico next _button _right" aria-label="오른쪽으로 이동">
									<span class="ico ico-mdi-next" aria-hidden="true"></span>
								</button>
							</div>
							<!-- /mdi-control -->
							<div class="mdi-btns _borderLess">
								<div class="btn-group" id="mdiList">
									<button type="button" class="btn btn-ico dropdown-toggle" data-toggle="dropdown" aria-expanded="false" data-label="List">
										<span class="ico ico-mdi-list" aria-hidden="true"></span>
									</button>
									<ul class="dropdown-menu _tabHolder"></ul>
								</div>
								<!-- /btn-group -->
								<button type="button" class="btn btn-ico" id="closeAllMid" data-label="전체닫기" data-action="closeAll">
									<span class="ico ico-mdi-close-all"></span>
								</button>
							</div>
							<!-- /mdi-btns -->
							<div class="mdi-page-control">
								<div class="btn-group">
									<button type="button" id="fullFoldingBtn"
										class="btn btn-ico btn-link" aria-label="Full Toggle"
										title="검색영역 토글" data-action="toggleSearch">
										<span class="ico ico-search-close" aria-hidden="true"></span>
									</button>
									<button type="button" class="btn btn-ico" aria-label="Help"
										title="도움말" data-action="showManual" disabled>
										<span class="ico ico-help" aria-hidden="true"></span>
									</button>
									<button type="button" class="btn btn-ico" aria-label="Favorite"
										title="즐겨찾기" data-action="markFavorite">
										<span class="ico ico-favorite-off" aria-hidden="true"></span>
									</button>
									<button type="button" class="btn btn-ico btn-conditaion"
										aria-label="Search Condition" title="조회 조건"
										data-action="showSearchCondition">
										<span class="ico ico-search-condition" aria-hidden="true"></span>
									</button>
								</div>
								<!-- /btn-group -->
								<div class="btn-group search-condition-group">
									<button type="button" class="btn btn-ico ico-lgd"
										data-toggle="tooltip" data-placement="left"
										aria-label="Full Toggle" title="조회 조건 저장"
										data-action="saveSearchCondition">
										<i class="fa fa-floppy-o" aria-hidden="true"></i>
									</button>
									<button type="button" class="btn btn-ico ico-lgd"
										data-toggle="tooltip" data-placement="top" aria-label="Help"
										title="조회 조건 삭제" data-action="deleteSearchCondition">
										<i class="fa fa-trash" aria-hidden="true"></i>
									</button>
									<button type="button"
										class="btn btn-ico ico-lgd btn-shift-right"
										aria-label="Favorite" title="돌아가기"
										data-action="hidewSearchCondition">
										<i class="fa fa-angle-right" aria-hidden="true"></i>
									</button>
								</div>
							</div>
						</div>
						<!-- /btn-util -->
					</div>
					<div class="mdi-contents _contents"></div>
					<!-- /tabs -->
					<footer>
						<div class="_globalStatusBar _messagingOn">
							<div class="pull-left">
								<p class="_message">Message</p>
							</div>
							<div class="pull-right">
								<p class="_appInfo"></p>
								<p class="_sessionTimeRemain">00:00:00</p>
								<p class="_currentTime">2017-09-05 00:00:00 (GMT +9)</p>
								<div class="_instantMessage">
									<i class="fa fa-circle _status" aria-hidden="true"></i>
									<div class="btn-group dropup">
										<button type="button" class="btn btn-default dropdown-toggle"
											data-toggle="dropdown" aria-haspopup="true"
											aria-expanded="false">
											<span class="_messageText">Not Connected</span><span
												class="caret"></span>
										</button>
										<ul
											class="dropdown-menu dropdown-menu-right _messageContainer">
											<li class="_messageItem _noMesage"><a href="#">No
													Messages</a></li>
											<li role="separator" class="divider"></li>
											<li><a href="#" class="deleteAllNotifications">Delete
													All Notifications</a></li>
											<li><a href="#" class="goConcurrentViewer">Concurrent
													Viewer</a></li>
										</ul>
									</div>
								</div>
							</div>
						</div>
					</footer>
				</section>
				<!-- /page-content -->
			</div>
			<!-- /row -->
		</div>
		<!-- /container -->
	</div>
	<!-- /wrap -->

	<div class="_upperSideAppPlate modal" role="dialog" tabindex="-1">
		<div class="modal-dialog">
			<div class="modal-content" style="height: 600px;">
				<div class="modal-header dark">
					<button type="button" class="btn btn-ico close _close"
						data-dismiss="modal" aria-label="Close">
						<span class="ico ico-popup-close" aria-hidden="true"></span>
					</button>
					<h1 class="modal-title">
						<lgcom:message code="MyMenu" />
					</h1>
				</div>
				<!-- /modal-header -->
				<div class="modal-body _popupBody">
					<div class="_contentWrapper">
						<div class="_content"></div>
					</div>
				</div>
			</div>
			<!-- /modal-content -->
		</div>
		<!-- /modal-dialog -->
	</div>
	<!-- /modal -->

	<div class="mdi-context _tabContextMenu">
		<ul>
			<li><a href="#" class="close-this" data-action="closeThis">Close
					This Tab</a></li>
			<li><a href="#" class="close-other" data-action="closeOthers">Close
					Other Tabs</a></li>
			<li><a href="#" class="close-all" data-action="closeAll"">Close
					All Tabs</a></li>
		</ul>
	</div>
	<!-- mdi-context -->

	<div class="_shortCutMenu">
		<button type="button"
			class="btn btn-side-toggle right _shortCutCloseButton">
			<span class="fa fa-angle-right" aria-hidden="true"></span>
		</button>

		<%-- <div class="searchBlock">
			<form class="form search-wrap" autocomplete="off"
				onkeypress="return event.keyCode != 13;">
				<table class="table table-condensed">
					<colgroup>
						<col width="90" />
						<col width="*" />
					</colgroup>
					<tbody>
						<tr>
							<td><select name="systemCode"
								class="control form-control input-sm"></select></td>
							<td><input type="text" name="menuName"
								class="form-control input-sm" placeholder="Input menu name..." /></td>
						</tr>
					</tbody>
				</table>
			</form>
		</div> --%>
		
		<div class="searchBlock">
			<form class="form search-wrap" autocomplete="off" onkeypress="return event.keyCode != 13;">
	            <div class="form-inline">
	                <select name="systemCode" class="control form-control input-sm"></select>
	                <input type="text" name="menuName" class="form-control input-sm" placeholder="Input menu name..." />
	            </div>
	        </form>
        </div>
		<div class="uxpTree"></div>
	</div>

	<div class="_system_notice_popup">
		<div class="noticeHeader">
			<h2>
				<lgcom:message code="SystemNotice" />
			</h2>
			<div class="checkbox checkbox-uxp checkbox-inline"
				style="position: absolute; top: 2px; right: 30px; font-size: 11.25px;">
				<input type="checkbox" class="userCheckFlag" value="Y"> <label
					for="inlineCheckbox1"><lgcom:message
						code="note.markPostAsReaden" /></label>
			</div>
			<button type="button" class="_close close" aria-label="Close">
				<span aria-hidden="true">×</span>
			</button>
		</div>
		<div class="noticeList">
			<ul class="list-group"></ul>
		</div>
		<div class="noticeContent"></div>
	</div>

	<%@ include file="/WEB-INF/views/main/fileManager.jsp"%>

	<%@ include file="/WEB-INF/views/main/excelUploader.jsp"%>

	<!-- 페이지 스크립트 -->
	<script>
    /*
        var app = uxp;
        app.loading(); //페이지 로딩

        $(function() {
            // UI init
            app.pageInit({
                sidebar: {
                    resizable: true,
                    targetID: '#resizable',
                },
                mdiInit: '#tabs',
            });
        });
        */
    </script>


	<script>
//<![CDATA[
$(document).ready( function() {

	if( Param.debug == "N") {
		window.onerror = function( errorMsg, url, lineNumber, colNumber, error ){
			// CKEditor이면 Skip
			if(error.name != 'TypeError') {
				Message.alert("<lgcom:message code="error.systemError"/>" + "<br> Error !!!: " + errorMsg + " <br> url : " + url + " <br> line : "+ lineNumber );
			}
			return true;
		};
	}
	
	if( Profile.SYSTEM_LOGO_TEXT ) {
	    $(".navbar-brand.site").text( Profile.SYSTEM_LOGO_TEXT );	
	    $("title").text( Profile.SYSTEM_LOGO_TEXT );	    
	} else {
	    $(".navbar-brand.site").text( "WCFW" );
	    $("title").text( "WCFW" );
	}

	// Default ORG 출력여부 결정 ( 현재는 값만 할당하는 것으로 정리 )
	if( SESSION_USER.ouUseFlag == "Y" ) {
		$(".navbar-brand > small").show().text( SESSION_USER.defaultOrgShortCode );
	}

	//백스페이스를 눌렀을 때에, 이전 페이지로 이동되는 것을 막기 위한 코드
	$(document).on("keydown", function(event) {
		if( event.target.nodeName != "INPUT" && event.target.nodeName != "TEXTAREA" ) {
			if( event.keyCode === 8 ) {
				return false;
			}
		}
	});

	//브라우저 뒤로가기를 막기 위한 코드
	window.history.forward(0);

	var layout = new LayoutManager();
	$(document).data( "LAYOUT_MANAGER",layout  );

	( new SystemDateSupport() ).setServerTime( "${serverTime}" );
	
	new DeveloperSupport();
});

var LayoutManager = function() {
	var _this = this;
	var animationDuration = 0;
	var reloadFlag;
	
	if( Param.reload ) {
		reloadFlag = Param.reload;
	}
	
	var messaging;
	try {
		messaging = new InstantMessaging( true );
	} catch( e ){}

	
	// 메인 화면의 유틸리티 팝업 화면들을 생성하고 표출하기 위한 기능을 담고있는 SideApp 클래스의 초기화 
	var sideApp = new SideApp();
	sideApp.onClose( function(){
		//User Menu 에서 수정사항이 발생했다면, main 을 갱신처리 한다.
		if( $(document).data("USER_NEMU_UPDATED" ) == "Y") {
			//전체 탭을 닫고, 메인 화면을 그대로 리프레시한다.
			var activeLevel1MenuId = $("header ._menu ._menuItem.active").data("id");
			var activeLevel2MenuId = $("aside ._menuBody a._level2._selected").data("id");
			var nav = new Navigate( "lgcom" , "main");
			nav.addParam("reload", "Y");
			nav.addParam("activeLevel1MenuId", activeLevel1MenuId );
			nav.addParam("activeLevel2MenuId", activeLevel2MenuId );
			nav.goPost();
		}
	});
	
	//처음 페이지가 로딩 됐을때의 타이틀
	var initTitle;

	if( SYSTEM_ENV != "prod") {
		initTitle = document.title + "(" + SYSTEM_ENV.toUpperCase() +")";
		document.title = initTitle;
	} else {
		$("._profileBox .btn-signout").hide();
		initTitle = document.title;
		document.title = initTitle;
	}
	
	//도메인이 wcfw 일 때만 설정의 size 변경 버튼을 활성화 한다. 
	if( document.location.hostname.indexOf("wcfw") < 0 ) {
		$("#changeSize").parent().hide();
	}

	//User Access List 를 담을 data 를 형성한다. ""
	if( $(document).data("USER_ACCESS_LIST") == undefined ) {
		$(document).data("USER_ACCESS_LIST", new Map() );
		$(document).data("USER_ACCESS_LIST_COUNT", new Map() );
	}

	//Profile Area 의 정보 설정
	var profileBox = $("header ._profileBox");
	profileBox.find("._name").text( SESSION_USER.fullNameLocal );
	profileBox.find("._title").text( SESSION_USER.organizationName + " | " + SESSION_USER.titleName );
	

	//데이터 로딩
	loadMenuData();
	loadFavoriteData();
	
	//메뉴 드래그 리사이즈 기능 활성화 
	menuReziseDragging();

	//화면에 드러난 모든 폼의 오브젝트를 저장하는 객체 : 폼의 생성과 삭제따라 크기가 변하면서 반응한다.
	var forms = new Map();
	//화면에 드러난 모든 팝업을 저장하는 객체 { caller : "..", callee : ".." } 형태로 저장되어, 팝업이 자신의 parent 를 찾을 수 있도록 하고 있다.
	var popups  = new Map();
	//팝업은 여러개 뜰 수 있기 때문에, Popup.openPopup() 이 호출 된다면, 그때의 callee 를 차곡차곡 모아놓아야 한다.
	var popupStack = new Array();

	//동적으로 구성된 formId 에 대한 메뉴 정보를 저장하는 객체 : 최초 메뉴가 만들어질 때 한번 만들어지고, 그 이후로 변화가 없이 유지된다.
	var menuItems = new Map();

	//즐겨찻기 버튼의 표시와 관리를 위해 관리하는 즐겨찾기 목록 ( menuId 기반으로 운영됨 )
	var favoriteList = new Map();

	var intro;

	if( reloadFlag != "Y" ) {
		new SystemNoticePopup();
	}

	var contents = $("section.page-content div._contents");
	var header = $("section.page-content div._header ul.nav-tabs");
	var tabHolder = $("._toolBox ._tabHolder");

	var headerHeight = $("section.page-content ._header").outerHeight();
	var tabHandleSortable = $("section.page-content ._header").sortable({
		axis: "x" ,
		delay: 300 ,
		containment : "parent",
		placeholder : "_contentNamePlaceHolder" ,
		hoverClass : "_itemOnDrag",
		stop : function( event, ui ) {
			$(ui.item).removeAttr("style");
		}
	});

	$("section.page-content ._header").droppable({
		drop : function( event, ui ) {
			$(ui.draggable).removeClass('_itemOnDrag');  //이거 trigger 가 안되는 버그
		},
		over: function(event, ui) {
			//   $(ui.draggable).addClass('_itemOnDrag');
		}
	});
	/*각 영역의 크기를 */
	var SIZE_ARGS = { left : {small : 32, large : 200 }  };

	/*현재 활성화 돼 있는 탭의 프로그램 ID */
	var currentBizFormId;

	var shortcut = new ShortcutMenuTree( "._shortCutMenu .uxpTree" );
	shortcut.loadData();

	$("section.page-content ._header").droppable({
		drop : function( event, ui ) {
			var item = $(ui.draggable);
			$(item).click();
			event.preventDefault();
		}
	});

	$(window).on("resize",function() { //unbinds itself every time it fires
		//윈도우 크기 조절에 따라, 컴포넌트 크기를 변경해 줘야 하는 항목을 크기 조절 해준다.
		resizeComponent();
	});


	//window 가 unload 될 때 단 한번만 수행하면 된다.
	$(window).one("beforeunload", function() {

		$("section.page-content iframe").attr("src", "about:blank");


		$("section.page-content ._contents").removeData();
		$("section.page-content ._contents").html("");
		$("aside").html("");
	});

	function loadIntro() {
		$("._introWrapper").data("loaded", true );

		var introUrl = SERVER_URL + "/" +SESSION_USER.systemCode.toLowerCase() + "/service/intro";
		$("._introWrapper").load( introUrl ,function(){
			try {
				intro = new IntroPage();
				$("._intro").show();

				if (typeof intro.init == "function") {
					intro.init();
				}

				if( reloadFlag == "Y" ) {
					$("._intro").hide();
				} else {
					intro.refresh();
				}
			} catch(e){ }
			//첫줄에서 적었지만, 재차 확인을 위해 callback 에 다시 적어둠
			$("._introWrapper").data("loaded", true );
		});
	}

	function gnbNavigateToggle() {
		if( $(".navbar ._profileBox").offset().left - $(".navbar .gnb").outerWidth() - 250  < 0 ) {
			$(".navbar .gnb-control").show( 200 );
		} else {
			$(".navbar .gnb-control").hide( 200 );
			$(".navbar .gnb").data("pos", 1 );
			$(".navbar .gnb").css({ left : "0px;" });
		}
	}
	
	function menuReziseDragging() {
		$(".sidebar").resizable({
			maxWidth: 400,
			minWidth: 200,
			resize : function( event, ui ) {
				$("section.mdi-content").css({"margin-left" : ui.size.width + "px"});
				resizeComponent(currentBizFormId);
			},
			stop : function( event, ui ) {
				$("section.mdi-content").css({"margin-left" : ui.size.width + "px"});
				resizeComponent(currentBizFormId);
			} 
		});
	}
	

	/*메소드 : 현재 탭으로 활성화된 programId 를 얻기위한 메소드  */
	this.getCurrentBizFormId = function() {
		return currentBizFormId;
	}

	/*메소드 : 모든 탭을 한번에 닫는 메소드 */
	this.closeAllTabs = function(){
		
		if( forms.size() == 0 ) {
			return;
		}
		
		Message.confirm( Message.CONFIRM_CLOSE_ALL_TABS, function() {
			//모든 탭 화면안에 포함된 dateRangePicker 를 제거한다.
			$( "div._contents ._datePicker, div._div_popup_holder_ ._datePicker").each( function(){
				if( $(this).data('dateRangePicker') != undefined ) {
					if($(this).data('dateRangePicker').destroy != undefined) {
						$(this).data('dateRangePicker').destroy();
					}
					$(this).removeData('dateRangePicker');
				}
			});

			//모든 탭 화면 안에 포함된 data  API 값들을 제거한다.
			$( "div._contents *").removeData();

			//모든 탭 화면에 포함된 multiselect 를 제거한다.
			/*
			$( "div._contents select[multiselect]").each( function(){
				$(this).multiselect("destroy");
			});
			*/

			//모든 탭 화면에 포함된 jsTree 를 제거한다.
			$('div._contents .jstree:jstree').jstree('destroy');
			$(document).off('.jstree');

			$(header).find("._contentName").parent().remove();
			$(contents).find("._contentWrapper").remove();
			$(tabHolder).find("._contentName").parent().remove();

			//탭을 모두 닫기 전에, 이벤트 핸들러를 네임스페이스 기반으로 제거 처리 해 주어야 한다. (팝업도 모두 forms 에 등록되기 때문에 이것만 처리 함 )
			$(forms.keys()).each( function(){
				$(document).off("." + this );

				//Object Reference 를 명시적으로 초기화 한다.
				forms.put( this, null );
			});

			//화면의 탭을 모두 없애는 상황에서는 반드시 현재 열린 form 과 popup 을 가지고 있는 맵을 모두 초기화 해주어야 한다.
			forms.clear();
			popups.clear();

			//현재의  formId 도 초기화 한다.
			currentBizFormId = null;

			//모든 탭이 닫히면, Favorite 마크도 정리되어야 한다
			markFavoriteIcon();

			//탭의 제목을 기본 값으로 돌려놓는다.
			document.title = initTitle;

			//탭 내부의 모든 그리드 정보를 모은 오브젝트 또한 초기화 한다.
			$(document).data("FORM_GRID_LIST", new Map() );

			LayoutManager.hideSearchCondition();

			//trace("[SYSTEM] All forms removed.  count : " + forms.size() );

			// 전체 탭을 닫고, 메인 화면을 그대로 리프레시한다.
			var activeLevel1MenuId = $("header ._menuItem.active").data("id");
			var activeLevel2MenuId = $("aside ._menuBody a._level2._selected").data("id");
			var nav = new Navigate( "lgcom" , "main");
			nav.addParam("reload", "Y");
			nav.addParam("activeLevel1MenuId", activeLevel1MenuId );
			nav.addParam("activeLevel2MenuId", activeLevel2MenuId );
			nav.goPost();
		});
	}

	/*메뉴에 사용할 데이터를 모두 인출해 온다.*/
	function loadMenuData() {
		transaction( CONTEXT_PATH, "lgsysc/LGSYSC00210/retrieveMenuList", {} , function(data) {
			var topMenuContainer = $("header ._menu._level1");
			var leftMenuContainer = $("aside > .lnb .nav");

			topMenuContainer.empty();
			leftMenuContainer.empty();

			var level1MenuId, level2MenuId, level3MenuId, level4MenuId;

			$(data["result"]).each( function(inx) {
				var item = this;

				//메뉴가 만들어질 때의 정보를 모아서, menuItems 에 정보를 저장한다.
				var bizFormId = uuid();
				menuItems.put( bizFormId, {
					systemCode : item["programSystemCode"],
					moduleCode : item["moduleCode"],
					//action : action,
					name : item["menuName"],
					programId : item["programId"],
					menuId : item["menuId"] ,
					urlAddr : item["urlAddr"],
					programTypeCode : item["programTypeCode"],
					userManualFlag : item["userManualFlag"],
					linkUrlAddr : item["linkUrlAddr"]
				});

				var _subMenu;
				//Level 1 메뉴는 최상단으로 보낸다.
				if( item["menuLevelNo"] == "1" ) {
					level1MenuId = item["menuId"];
					var firstMenu = $('<li class="_menuItem" data-id="'+ level1MenuId +'" ><a href="#">' + item["menuName"]+ '</a></li>');
					topMenuContainer.append( firstMenu );
					firstMenu.data("bizFormId", bizFormId  );
				} else {
					if( item["menuLevelNo"] == "2" ) {
						level2MenuId = item["menuId"];
                        var text = '<li class="_level2" data-level1="'+ level1MenuId +'" style="display:none;">' +
                                   '<a href="#" title="' + item["menuName"] + '" role="button" data-id="'+ level2MenuId +'" >'+ item["menuName"] +' <span class="fa fa-angle-down" aria-hidden="true"></span></a>' +
                                   '<ul style="display: none;" data-level2="'+ level2MenuId +'" ></ul>' +
                                   '</li>';
                        leftMenuContainer.append( text ); 
					} else if ( item["menuLevelNo"] == "3" ) {
						level3MenuId = item["menuId"];
						var subMenu = $("._menuBody ._level2 ul[data-level2=" + level2MenuId+ "]");
						var text = '<li class="_level3">'+
						           '<a href="" title="'+ item["menuName"] +'" data-id="'+ item["menuId"] +'">'+ item["menuName"] +' <span class="fa fa-angle-up" aria-hidden="true"></span></a>' +
						           '<ul style="display: none;" data-level3="'+ level3MenuId +'" ></ul>' +
						           '</li>';
						
						var lastMenu = $(text);
						lastMenu.data("bizFormId", bizFormId  ); //3 Depth 와 4 Depth 는 bizFormId 가 있어야 한다 
						subMenu.append( lastMenu );
					} else if ( item["menuLevelNo"] == "4" ) {
						level4MenuId = item["menuId"];
						var subMenu = $("._menuBody ._level2 ul[data-level3=" + level3MenuId+ "]");
						var text = '<li class="_level4">'+
						           '<a href="" title="'+ item["menuName"] +'" data-id="'+ item["menuId"] +'">'+ item["menuName"] +'</a>' +
						           '<ul style="display: none;" data-level4="'+ level4MenuId +'" ></ul>' +
						           '</li>';
						
						var lastMenu = $(text);
						lastMenu.data("bizFormId", bizFormId  ); //3 Depth 와 4 Depth 는 bizFormId 가 있어야 한다 
						subMenu.append( lastMenu );
					}
				}
			});

			$("._level3").each( function(){
				if( $(this).find("ul ._level4").length == 0) {
					$(this).find("a span").remove();
					$(this).find("ul").css("padding","0");
				}
			});
			
			
			$("._menuBody ._level2").hide();
			$("._menuBody ._subMenu").hide();

			//메뉴를 모두 추가하고, 가장 첫번째 레벨 1 메뉴를 활성화 한다.
			selectFirstTopMenu();

			$('._level3[data-toggle="tooltip"]').tooltip();
			//페이지가 리로드 될 때 화면의 상태를 파라미터로 받아 재 할당 해주는 코드
			afterReloadProcess();

			//메뉴가 로딩 됐을때, 최상단 메뉴의 크기에 따라서 스크롤 버튼을 보이기 / 숨기기 하는 토글 함수
			gnbNavigateToggle();
		});
	}

	/*
	 * 탭 전체 닫기 또는 사용자 메뉴 화면의 "저장" 수행 직후에는, 전체 화면을 리로드 하는 작업을 수행한다.
	 * 이때 '현재 활성화 된 메뉴들' 의 정보를 파라미터로 전달해 주는데, 이 정보를 받아서 메뉴를 활성화 된 것 으로 표현 해주기 위한 함수이다.
	 */
	function afterReloadProcess() {
		var activeLevel1MenuId, activeLevel2MenuId;
		if( Param.activeLevel1MenuId ) { activeLevel1MenuId = Param.activeLevel1MenuId };
		if( Param.activeLevel2MenuId ) { activeLevel2MenuId = Param.activeLevel2MenuId };
		
		if( activeLevel1MenuId != "" && activeLevel1MenuId != undefined ) { //리로드 돼 있을 때, 이미 선택된 메뉴들에 대한 처리
			$("header ._menu ._menuItem[data-id='"+ activeLevel1MenuId +"']").click();
			$("aside ._level2[data-id='"+ activeLevel2MenuId +"']").click();

			//17.04.04
			//전체 탭을 닫으면 nav.goPost()로 submit을 날려 introCase가 초기화 되는 문제로
			//인트로 페이지를 사용하지만 클릭해도 이동되지 않는 문제 때문에 추가
			if( Profile.USE_INTRO == "Y" ) {
				var introCase = 1;
				if( SESSION_USER.systemCode == "LGPRO" ) {
					if( introCase == 1 ) {
						$(USER_ROLE_LIST).each( function() {
							if( this["roleCode"] == "LGPRO_INIT_USER" ) {
								introCase = 2;
								return false;
							}
						});
					}
					if( introCase == 1 ) {
						$(USER_ROLE_LIST).each( function() {
							if( this["moduleCode"] == "LGPSBM" ) {
								introCase = 3;
								return false;
							}
						});
					}
					$(document).data("introCase", introCase );
				}
			}
		} else {
			if( Profile.USE_INTRO == "Y" ) {				
				/*
				 * LGPRO의 경우, 이 로그인 된 사용자의 roleCode 에 LGPSBM 이 하나라도 나와 있으면, menuId : M_LGPSBM_1003 을 활성화 한다.
				 * 적은 번호는 우선순위로 먼저 적용되면 끝
				 * 1. Role Code : LGPRO_INIT_USER
				 * ==> intro 를 보여준다.  ( introCase = 2 )
				 * 2. this["moduleCode"] == "LGPSBM" 인 경우
				 * ==> summary 를 보여준다  M_LGPSBM_1003  ( introCase = 3 )
				 * 3. 그 밖의 경우
				 * ==> 제 1 메뉴를 보여준다.  ( introCase = 1 )
				 */
				var introCase = 1;

				if( SESSION_USER.systemCode == "LGPRO" ) {
					if( introCase == 1 ) {
						$(USER_ROLE_LIST).each( function(){
							if( this["roleCode"] == "LGPRO_INIT_USER" ) {
								introCase = 2;
								return false;
							}
						});
					}

					if( introCase == 1 ) {
						$(USER_ROLE_LIST).each( function(){
							if( this["moduleCode"] == "LGPSBM" ) {
								introCase = 3;
								return false;
							}
						});
					}
					

					if( introCase == 1 ) {
						$("header ._menu ._menuItem:first-child").click();
						var id = $("header ._menu ._menuItem:first-child").data("id");

						$("aside ._level2:first-child").click();
						$("aside ._level2[data-level1='"+ id +"']:first ._level3:first-child").click();
					} else if( introCase == 2 ) {
						//프로파일의 USE_INTRO 값에 따라, intro page 를 표출 할 지 말지 결정한다.
						$("._intro").show();
						loadIntro();
					} else if( introCase == 3 ) {
						var _targetMenu = $("aside ._level3[data-id='M_LGPSBM_1003']");
						var _menuId_level1 = _targetMenu.closest("._subMenu").data("level1");
						var _menuId_level2 = _targetMenu.closest("._subMenu").data("level2");

						//메뉴 1레벨을 클릭하고, 이어서 레벨 2를 클릭한다.
						$("header ._menu ._menuItem[data-id='"+ _menuId_level1 +"']").click();
						$("aside ._level2[data-id='"+ _menuId_level2 +"']").click();
						//이어서 3레벨을 클릭해 화면을 불러온다.
						_targetMenu.click();
					}

					// introCase 연산을 끝낸 경우에만 이 데이터를 적재한다.
					$(document).data("introCase", introCase );
				} else {
									
					loadIntro();
				}
			} else {
				$("._introWrapper, ._intro").hide();
				//리로드가 아니라 처음 호출 된 것일 때, 프로파일의 USE_INTRO 사용이 N 이라면, 형성된 가장 첫번째 메뉴를 클릭한다.
				// Profile.USE_INTRO == "N"
				$("header ._menu ._menuItem:first-child").click();			
				var id = $("header ._menu ._menuItem:first-child").data("id");

				$("aside ._level2:first-child").click();
				$("aside ._level2[data-level1='"+ id +"']:first ._level3:first-child").click();

			}
		}
	}

	function refreshGrid( formId ) {
		if( formId != undefined ) { 
			var form = forms.get( formId );
			if( form != undefined ) {
				setTimeout( function(){
					form.refreshGrid();
				}, 100);
			}
		}
	}

	//현재의 모든 active form 에 대해
	function resizeComponent( formId ) {
		if( formId == undefined ) {
			formId = currentBizFormId;
		}

		var form = forms.get( formId );
		if( form != undefined ) {
			form.refreshGrid();
		}
		
		mdiTabMovmentControl();
	}

	function mdiTabMovmentControl() { 
		if( $('.scroll-wrap .nav-tabs').width() < $('.scroll-wrap').width()) {
		    $('.scroll-wrap').removeClass('movable');
		} else {
		    $('.scroll-wrap').addClass('movable');
		}
		
		//왼쪽 희미한 부분은 왼쪽으로 밀려난 부분이 있을 때만 활성화 된다. 
	    if( $('.scroll-wrap .nav-tabs').offset().left <  $(".scroll-wrap").offset().left  ) {
	    	$('.scroll-wrap').addClass('moved');
		} else {
			$('.scroll-wrap').removeClass('moved');
		}

	}
	
	function adjustActiveTabLocation(){
		/* 사이즈 조정으로 인한 "선택된 탭" 의 위치를 조정하는 부분  */	
		var wrap = $('.mdi-tabs .scroll-wrap');
		var target = wrap.children('ul');
		if( wrap.data("count") ==  undefined ) {
			wrap.data("count", 1 );
		}	
		
		var active = $(".mdi-tabs .nav-tabs .active");
		if( active.exists() ) {
			var offSideFlag = false;
			
			if( wrap.offset().left >= ( active.offset().left + active.width() ) ||  ( wrap.offset().left + wrap.width() ) <= active.offset().left ) {
				offSideFlag = true;
			}
			
			if( offSideFlag ) {
				_moveTaps( active.index() + 1 , wrap, target );
			}
		}
	}
	
	
	/*내부함수 : 특정 탭을 선택 된 것으로 만드는 함수  */
	function setTabActive( item ) {
		var target;
        
		if( $.type( item ) == "string" ) {
			target = header.find("._contentName[data-id='"+item+"']" );
			currentBizFormId = item;
			menuItem = menuItems.get(item);
		} else {
			target = $(item);
			currentBizFormId = target.data("id");
		}
		
		if( SYSTEM_ENV != "prod" ) {
			try{
				var menuItem = menuItems.get( currentBizFormId );
				$("._globalStatusBar  ._appInfo").text( menuItem["menuId"] + " " + menuItem["programId"] );
			}catch(e){
				var menuItem = menuItems.get( currentBizFormId );
				$("._globalStatusBar  ._appInfo").text("");
			}
		}

		markFavoriteIcon();
		toggleSearchConditionControl() ;

		if( !target.hasClass( "_contentName" ) ) {
			document.title = initTitle;
			return;
		}

		//탭 헤더에 대한 정리를 한다. 
		target.parent().addClass("active").siblings().removeClass("active");
		$(contents).find("._contentWrapper[data-id='"+ currentBizFormId +"']").show( 0, function(){
			refreshGrid( currentBizFormId );
		}).siblings().hide();

		//탭 헤더의 active 항목이 View 를 벗어나 있는 경우를 찾아서 보이도록 스크롤한다. 
		var wrap = $('.mdi-tabs .scroll-wrap');
        var target = wrap.children('ul');
        var offset = 0;
        if( wrap.data("offset")  != undefined ){
        	offset = wrap.data("offset");
        }
  
        var activeItem = target.find(".active");
        trace( "setActive :" + offset + "_" + activeItem.offset().left + "_" +  wrap.offset().left );
        
        wrap.data("offset", offset);
        
		
		//탭의 타이틀을 얻는다.
		var title = $(target).find("._text").text();
		document.title = initTitle  + "-" + title;
	}

	/* 내부함수 : 탭의 핸들과 컨텐츠를 하나씩 증가시키는 함수 */
	function addTab( bizFormId , parameter , callback ) {
		//현재 탭 갯수를 모두 더하고, 이를 Profile.MAX_TAB_COUNT 와 비교한다.
		var tabCount = header.find("._contentName").length + tabHolder.find("._contentName").length;
		if( Profile.MAX_TAB_COUNT > 0 && tabCount >= Profile.MAX_TAB_COUNT ) {
			Message.alert( Message.MAX_TAB_COUNT_1 + Profile.MAX_TAB_COUNT  + Message.MAX_TAB_COUNT_2 );
			return;
		}

		//화면 탭이 열릴 때 마다, searchCondition 컨트롤이 가려져야 한다. ( 페이지 로딩이 끝나고 나면 알아서 열어줄 것임 )
		LayoutManager.hideSearchCondition();
		var menuItem = menuItems.get( bizFormId );
		var name = menuItem.name;
		
		if( menuItem["programId"] == undefined ) return;

		var proceedFlag = true;
		//이미 화면이 열려 있는 상태에서는 이를 활성화 해주는 것으로 마무리 한다.
		//먼저 Contents 존재하는 지 확인
		if( $( "._contentWrapper[data-id='"+ bizFormId +"']").exists() ) {
			//해당 탭이 이미 열려 있으면 contentWrapper 를 찾고, 그 안에 stack 의 크기를 살핀다.
			var currentStack = $( "._contentWrapper[data-id='"+ bizFormId +"']").data("stack");
			if( currentStack.size() > 1  ) { //자신을 포함한 부속화면이 있다면
				var currentTabName = $("section.page-content ._header ._contentName[data-id='"+bizFormId+"'] ._text").text();
			
				Message.confirm( "Do you want to replace the tab of : " + currentTabName + " <br> with " + name + "?" , function(){
					if( menuItem["programTypeCode"] == "MATRIX" ) {
						_addTabComponentExternal( true );
					} else {
						_addTabComponent( true );
					}

				});
			}

			//ContentWrapper를
			if( $("section.page-content ._header ._contentName[data-id='"+bizFormId+"']").exists() ) {
				setTabActive( bizFormId );	//탭 핸들이 화면에 보이면, 그것을 그대로 활성화
			} else {
				$("section.page-content ._contentNameExtendPannel ._contentName[data-id='"+bizFormId+"']").click(); //햄버거에 들어 있으면 그 아이템을 클릭함
			}
		} else {
			if( menuItem["programTypeCode"] == "MATRIX" ) {
				_addTabComponentExternal( false );
			} else {
				_addTabComponent( false );
			}
		}

		mdiTabMovmentControl();
		
		/* BziWeb 의 일반 업무 화면을 Tab으로 표시하는 함수 : DIV 의  $.load() 를 사용하여 화면을 표시한다.  */
		function _addTabComponent( reload ) {
			//Tab Content ( tabName )
			var contentWrapper;
			var content;
			var contentName;

			if( reload ) {
				contentWrapper = $( "._contentWrapper[data-id='"+ bizFormId +"']");
				content = contentWrapper.find("._content#" + bizFormId );

				//첫번째 content 를 제외한 모든 항목을 다 지운다.
				content.siblings().remove();

				//content 의 내용도 비운다.
				content.empty().show();

				var stack = contentWrapper.data("stack");
				$( stack.keys() ).each( function(){
					LayoutManager.removeForm( stack.get( this )["id"] );
				});

				//contentWrapper 에 있는 data() 를 초기화 한다.
				contentWrapper.removeData();

				//다시 stack 을 초기화 하여 wrapper 에 할당한다.
				stack = new Map();
				stack.put( menuItem.menuId, { id : bizFormId , name : name } );
				contentWrapper.data("stack", stack );

				//기존의 탭 핸들에 탭 핸들의 원래 메뉴이름을 회복해준다.
				header.find("._contentName[data-id='"+bizFormId+"']").attr("title", name );
				header.find("._contentName[data-id='"+bizFormId+"'] ._text").text(name);
			} else {
				contentWrapper = $( "<div class='_contentWrapper' data-id='"+bizFormId+"' ><div class='_content' id='"+ bizFormId +"' data-menuId='"+ menuItem.menuId +"'><div class='_loader page-loading'><div class='loading'><p class=''>Loading...</p></div><div class='overlay'></div></div></div>" );
				content = contentWrapper.find("._content");

				//Tab Haeder
				contentName = $("<li><a class='_contentName' data-id='"+bizFormId+"' title='"+name+"'><span class='_text'>"+ name +"</span><span class='close _closeTab'>×</span></a></li>");

				header.append( contentName );
				contents.append( contentWrapper );
				tabHolder.append("<li><a href='#' data-title='"+ name +"' class='_contentName' data-id='"+bizFormId+"' >"+ name +"</a></li>");

				content.find("._loader").show();
				content.on("remove", function () {
					$(document).off("." +  $(this).attr("id") );
					$(this).removeData();
					$(this).html("");
				});

				//contentWrapper 에 stack 을 추가해서 자식 폼이 추가 되는 여부를 관리한다.
				var stack = new Map();
				stack.put( menuItem.menuId,  { id : bizFormId , name : name } );
				contentWrapper.data("stack", stack );
			}

			setTabActive( bizFormId );
			var systemCode = menuItem["systemCode"].toLowerCase();
			var pageUrl = SERVER_URL + "/" +systemCode + "/service/" + menuItem["menuId"];

			if( nvl( menuItem["urlAddr"] ) != "" ) {
				pageUrl += "?" + nvl( menuItem["urlAddr"] );
			}

			//파라미터 처리 부분
			var param = { bizFormId  : bizFormId };
			if( parameter != null ) {
				parameter.bizFormId = bizFormId;
				param = parameter;
			}

			param.source = "main";
			//현재 탭이 보이든 안보이든 간에, 내용물은 먼저 가지고 와서 초기화 해야 한다.
			$( content ).data("URL", pageUrl );

			$( content ).load(pageUrl , param , function(responseText, statusText, xhr) {
				if( responseText.indexOf( "error420.jsp" ) > -1 ) {
					$( content ).empty().append( "<div class='_contentNotFound'><i class='fa fa-exclamation-triangle errorMark' aria-hidden='true'></i><div style='font-size : 20px;text-align:center;' >You don't have permission for this menu.</div></div>");
					return;
				}

				if( responseText.indexOf( "error.jsp" ) > -1 ) {
					return;
				}
				
				if( xhr.status != "200" ) {
					// 정상적으로 로딩이 되지 않더라도, 화면에 탭이 추가 되기 때문에, addForm 은 해 주어야 한다.
					LayoutManager.addForm( bizFormId, null );
					$(contents).find("#"+ bizFormId ).append("<div class='_contentNotFound'><i class='fa fa-exclamation-triangle errorMark' aria-hidden='true'></i><div style='font-size : 20px;text-align:center;' >Page not found <br> 페이지가 없습니다.</div></div>");
				}

				$(content).find("._loader").remove();
				$(this).data("URL", pageUrl );

				hideFolatingPannel();
				LayoutManager.initSessionTimeout();

				try{
					callback.call( this, LayoutManager.getForm( bizFormId ) );
				}catch( e ){  }
				
				try {
					messaging.refresh();
				}catch( e ){ trace(e); }
				
				if( SYSTEM_ENV != "prod" ) {
					menuItem["programId"] = xhr.getResponseHeader("programId");
					$("._globalStatusBar  ._appInfo").text( menuItem["menuId"] + " " + menuItem["programId"] );
				}
			});
			$("._contents *").tooltip('destroy');
			markFavoriteIcon();
		}

		function _addTabComponentExternal( reload ) {
			transaction("lgcom", "common/uiCommon/checkValidBiMatrixMenuId", {menuId : menuItem.menuId }, function(data){

				if( data["result"].length == 0 ) {
					return;
				}

				//Tab Content ( tabName )
				var contentWrapper;
				var content;
				var frame;
				var contentName;

				if( reload ) {
					contentWrapper = $( "._contentWrapper[data-id='"+ bizFormId +"']");
					content = contentWrapper.find("._content#" + bizFormId );

					//첫번째 content 를 제외한 모든 항목을 다 지운다.
					content.siblings().remove();

					//content 의 내용도 비운다.
					content.empty().show();

					var stack = contentWrapper.data("stack");
					$( stack.keys() ).each( function(){
						LayoutManager.removeForm( stack.get( this )["id"] );
					});

					//contentWrapper 에 있는 data() 를 초기화 한다.
					contentWrapper.removeData();

					//다시 stack 을 초기화 하여 wrapper 에 할당한다.
					stack = new Map();
					stack.put( menuItem.menuId, { id : bizFormId , name : name } );
					contentWrapper.data("stack", stack );

					//기존의 탭 핸들에 탭 핸들의 원래 메뉴이름을 회복해준다.
					header.find("._contentName[data-id='"+bizFormId+"']").attr("title", name );
					header.find("._contentName[data-id='"+bizFormId+"'] ._text").text(name);
				} else {
					contentWrapper = $( "<div class='_contentWrapper' data-id='"+bizFormId+"' ><div class='_content' id='"+ bizFormId +"' data-menuId='"+ menuItem.menuId +"' style='overflow:hidden;'><div class='_loader page-loading'><div class='loading'><p class=''>Loading...</p></div><div class='overlay'></div></div><iframe class='externalFrame' style='width:100%;height:100%;' scrolling='auto' frameBorder='0' src='about:blank'></iframe></div></div>" );
					content = contentWrapper.find("._content");
					frame = content.find(".externalFrame");

					//Tab Haeder
					contentName = $("<li><a class='_contentName' data-id='"+bizFormId+"' title='"+name+"'><span class='_text'>"+ name +"</span><span class='close _closeTab'>×</span></a></li>");

					header.append( contentName );
					contents.append( contentWrapper );

					$(frame).on( "load", function(){
						content.find("._loader").remove();
					});

					content.find("._loader").show();
					content.on("remove", function () {
						$(document).off("." +  $(this).attr("id") );
						$(this).removeData();
						$(this).html("");
					});

					//contentWrapper 에 stack 을 추가해서 자식 폼이 추가 되는 여부를 관리한다.
					var stack = new Map();
					stack.put( menuItem.menuId,  { id : bizFormId , name : name } );
					contentWrapper.data("stack", stack );
				}

				setTabActive( bizFormId );
				var systemCode = menuItem["systemCode"].toLowerCase();

				if(  menuItem["moduleCode"] == "LGDEVC" ) {
					systemCode = menuItem["moduleCode"].substr(0, 5).toLowerCase();
				}

				//http://bizweb-dev.lgdisplay.com:9006/lgbmx/portal/sso/sso_login.jsp?uid=matrix&id=
				var pageUrl = SERVER_URL + "/lgbmx/extention/portal/jsp/sso/sso_login.jsp?uid=matrix&id=" + menuItem["linkUrlAddr"] + "&bizFormId=" + bizFormId;
				//var pageUrl = SERVER_URL + "/lgcom/container?menuId=M_LGUTLC_1183";

				if( nvl( menuItem["urlAddr"] ) != "" ) {
					pageUrl += "&" + nvl( menuItem["urlAddr"] );
				}

				if( SYSTEM_ENV != "prod") {
					pageUrl += "&ssoId=" + SESSION_USER.ssoId;
				}

				//파라미터 처리 부분
				var param = { bizFormId  : bizFormId };
				if( parameter != null ) {
					parameter.bizFormId = bizFormId;
					param = parameter;
				}

				param.source = "main";
				//현재 탭이 보이든 안보이든 간에, 내용물은 먼저 가지고 와서 초기화 해야 한다.
				$( content ).data("URL", pageUrl );
				$(frame).attr("src", pageUrl );

				$("._contents *").tooltip('destroy');
				markFavoriteIcon();

			});
		}
	}

	function closeTab( item ) {
		//만일 최대화 모드였다면, 이것을 원래대로 돌려놓고 닫도록 한다. 
		if( $("body").hasClass("maximized") ) {
			$("body").removeClass("maximized");
		}
		
		var id = $(item).data("id");

		//_contentWrapper 에 자식 form 이 있다면, 이것들도 form 을 삭제해야 한다.
		var stack = $(contents).find("._contentWrapper[data-id='"+id+"']").data("stack");
		var destroyable = true;

		try {
			$(stack.keys()).each( function(){
				var bizForm = forms.get( stack.get( this )["id"] );
				if( !bizForm.isDestroyable() ){
					destroyable = false;
					return false; // each 루프를 끝낸다.
				}
			});
		} catch( e ) {
			//위의 코드가 정상작동을 하지 않고 문제가 발생했을 때는, 기본적으로 탭은 문제 없이 닫혀야 한다.
			destroyable = true;
		}

		if( !destroyable ) {
			return;
		}

		if(stack) {
			$(stack.keys()).each( function(){
				trace( "Stack size key : " + stack.get( this )["id"]  );
				LayoutManager.removeForm( stack.get( this )["id"] );
			});
		}

		var selectedIndex = $(header).find("._contentName._selected").index();

		//현재 탭이 지워지고, 그자리에 tabHolder에 있던 다른 탭이 나와 대체되지 않는 상황이고
		//현재 인덱스가 last index 라면, 하나를 빼야 한다.
		if( $(tabHolder).find("._contentName" ).length == 0 ) {
			if( $(header).find("._contentName:last-child").index() == selectedIndex ) {
				selectedIndex = selectedIndex - 1;
			}
		}
		stack.clear();

		//현재 화면에 첨부된 모든 DataAPI 를 제거한다.
		$( "div[data-id='"+ id +"']._contentWrapper, div[data-id='"+ id +"']._contentWrapper *").removeData();

		//모든 탭 화면에 포함된 multiselect 를 제거한다.
		//$( "div#" + id + " select[multiselect]").multiselect("destroy");

		//현재 화면에 뜬 모든 툴팁을 해제한다.
		$("[data-toggle='tooltip']").tooltip('destroy');
		$(".tooltip").remove();

		header.find("a[data-id='"+id+"']").parent().empty().remove();
		contents.find("._contentWrapper[data-id='"+id+"']").empty().remove();
		tabHolder.find("._contentName[data-id='"+id+"']").parent().empty().remove();

		//현재 화면에 뜬 모든 pastable plate 를 지운다.
		$("._pasteContent").hide();

		//현재 화면의 모든 jsTree 를 제거한다.
		$("div[data-id='"+ id +"']._contentWrapper .jstree:jstree").jstree("destroy");

		setTabActive( $(header).find("._contentName:eq("+ selectedIndex +")") );
		stack = null;
	}

	/* 탭의 X 버튼을 눌러서 탭을 닫는 이벤트 핸들러 */
	$(document).on( "click._main", "section.page-content ._header ._closeTab", function(event) {
		closeTab( $(event.target).closest("._contentName")  );
		//탭의 닫기 버튼과 그를 둘러싼 _contentName 에 같은 종류의 이벤트가 걸려있기 때문에, 그 상위 객체로 이벤트가 전파되는 것을 막아야 한다.
		event.stopPropagation();
	});

	/* 상단 탭 핸들러를 클릭하는 이벤트에 대한 핸들러 */
	$(document).on( "click._main dblclick._main mousedown._main", "section.page-content ._header ._contentName", function(event) {
		var item = $(this);

		if (event.type == 'click') {
			setTabActive( item );
		} else if (event.type == 'dblclick') { //전체화면 토글(화면 확장 효과)
			toggleAppMaximize();
		} else if (event.type == 'mousedown' && event.which == 2) {
			$(this).children('._closeTab').trigger("click"); //휠 클릭하면 탭 닫힘
		}
	});

	$(document).on( "click", "._contentWrapper ._handle i", function(event){
		toggleAppMaximize();
		event.preventDefault();
	});


	/* 탭 홀더에 있는 아이템을 클릭하는 이벤트에 대한 핸들러 */
	$(document).on( "click._main", "._tabHolder ._contentName", function(event) {
		var item = $(event.target);
		if( !item.hasClass("_contentName") ) {
			item = $(item).parent();
		}
		
		//_moveTaps( item.parent().index() + 1 );
		
		//이 아이템을 Active 상태로 활성화 한다.
		setTabActive( item.data("id") );
		
		adjustActiveTabLocation();
	});

	/* 툴박스 안의 탭 이동 버튼 ( <,  > )에 대한 이벤트 핸들러 */
	$(document).on( "click._main", "._toolBox ._moover ._button", function(event) {
		if( header.children().length < 2 ) { return; }
		var item = $(event.target);
		
		if( item.is("span") ) {
			item = item.parent();
		}
		
		var wrap = $('.mdi-tabs .scroll-wrap');
		var target = wrap.children('ul');
		if( wrap.data("count") ==  undefined ) {
			wrap.data("count", 1 );
		}	
		
		if( item.hasClass("_right") ) {
			var count = wrap.data("count") + 1;
		} else {
			var count = wrap.data("count") - 1;
		}
		
		_moveTaps( count, wrap, target );
		
	});

	function _moveTaps( count, wrap, target ) {

 	    if( wrap == undefined ) {
	    	wrap = $('.mdi-tabs .scroll-wrap');
	    }
	    if( target == undefined ) {
	    	target = wrap.children('ul');
	    }    
		
	    //좌측이 끝에 도달했을때 멈추는 부분
		if( count <= 0 ) {
			return;
		}
		//우측이 좌측 끝에 도달했을때 멈추는 부분 
		if( count > target.find("li").length ) {
			return;
		}
	    
		var gap = target.find("li:nth-child("+ count +")").offset().left - wrap.offset().left ;
	    var targetPosition = Math.abs( target.position().left );
		var left = gap + targetPosition;
		
		var param = { left: "-" + left + "px"  };
		
		if( count == 1 ) {
	        param = { left: "0px" };
		} 
		
        target.stop().animate( param , {
        	complete : function(){
        		mdiTabMovmentControl();	
    	        wrap.data("count", count );
        	}
        });	
	}
	
	/* 왼쪽 메뉴 바를 숨기기 - 보이기 하기 위한 이벤트 핸들러 */
	$(document).on( "click._main", "._closeButton", function(event) {
		var obj = $("aside.sidebar"); 
		
        if (obj.hasClass('closed')) {
        	$('section.page-content').removeClass('extend-left');
            $('.page-header').removeClass('extended');
            obj.removeClass("closed");
        } else {
        	$('section.page-content').addClass('extend-left');
            $('.page-header').addClass('extended');
            obj.addClass("closed");
        }
		
        $(obj).find(".btn-side-toggle").children().toggleClass('fa-angle-left fa-angle-right');
	});

	/**********************************
	즐겨찾기
	***********************************/
	/* 즐겨찾기 목록을 보이고 보이지 않게하는 동작을 수행하는 이벤트 핸들러 */
	/*
	 $(document).on( "click._main", "aside ._favoriteButton", function(event) {
		var item = $(event.target);

		if( item.hasClass("selected") ) {
			$("aside ._favoriteBody").hide(0);
			$("aside ._menuBody").show();

			$(item).removeClass("selected");
		} else {
			$("aside ._menuBody").hide(0);
			$("aside ._favoriteBody").show();

			$(item).addClass("selected");
		}
	});
   */
	$(document).on('click._main', '._toolBox ._button, ._contentNameExtendPannel ._button', function (event) {
		var item = $(event.target);
		var action = $(item).data("action");

		if( action == "contentNameExtend" ) {
			if( $("main ._contentNameExtendPannel ._contentName").length > 0 ) {
				$("main ._contentNameExtendPannel").css("right", ( $("main ._bordered").width() + 39  )+ "px");
				$("main ._contentNameExtendPannel").show();
			}
		} else if ( action == "windowToolHide" ){
			$("main ._contentNameExtendPannel").hide();
		} else if ( action == "windowCloseAll" ) {
			_this.closeAllTabs();
		}
	});

	$(document).on('click._main', '._guide._button', function (event) {
		var menuItem = LayoutManager.getMenuItem( currentBizFormId );
		if( menuItem == undefined ) { return; }

		var size = { width : 1036, height : 600 };
		var winName= "_screen_manual_";
		var winURL= SERVER_URL + "/lgcom/container?menuId=M_LGUTLC_1183";
		var windowoption='resizable=yes,height='+ size.height +',width='+ size.width +',location=0,menubar=0,scrollbars=1, top=50, left=50';

		var form = $("#_open_popup_temp_form_");

		if( !form.exists() ) {
			$("body").append("<form id='_open_popup_temp_form_' method='POST'></form>");
			form = $("#_open_popup_temp_form_");
		}
		$(form).empty();

		$(form).attr("action", winURL);
		$(form).attr("target",winName);
		$(form).append("<input type='hidden' name='manualProgramId' value='"+ menuItem["programId"] +"' />");

		window.open('', winName,windowoption);
		$(form).submit();
	});

	/* 이벤트 핸들러 : 즐겨찾기 목록의 별표 아이콘을 클릭하면, 발생하는 이벤트 핸들러, 클릭하면 즐겨찾기가 삭제되고, 재조회 되어 데이터가 갱신된다.  */
	$(document).on( "click._main", "#lnbFavorit .bookmark", function(event) {
		var bizFormId = $(event.target).parent().data("id");
		var menuItem = menuItems.get( bizFormId );

		Message.confirm( "<lgcom:message code="question.favoriteRemove"/>" , function(){
			transaction( CONTEXT_PATH, "lgsysc/LGSYSC00070/deleteFavoriteItem", { menuId : menuItem.menuId } , function(data){
				Message.notify("Favorite removed !!");
				loadFavoriteData();
			});
		});
		
		event.stopPropagation();
	});

	/* 이벤트 핸들러 : 즐겨찾기 User, Recent를 선택시 발생한다 */
	$(document).on( "click._main", "aside ._favoriteHeader li", function(event) {
		var item = $(event.target);
		$(item).addClass("selected").siblings().removeClass("selected");

		var target = $(item).data("target");
	
		if(target=="_selected"){	
			$("#lnbFavorit").show();			
			$("#lnbRecent").hide();			
		}else if(target=="_all"){
			$("#lnbRecent").show();
			$("#lnbFavorit").hide();
		}
		event.stopPropagation(); 
	});

	/* 이벤트 핸들러 : 즐겨찾기 목록의 내역을 누르면 해당 메뉴가 열린다 */
	$(document).on( "click._main", "aside ._favoriteMenu", function(event) {
		var item = $(event.target);
		if( !( item.hasClass("_favoriteMenu") ) ) {
			return;
		}
		addTab( $(item).data("id") );
		event.stopPropagation();
	});

	/* 내부함수  : 앱 화면을 최대화 최소화 한다.  */
	function toggleAppMaximize(){
		//만일 최대화 모드였다면, 이것을 원래대로 돌려놓고 닫도록 한다. 
		if( $("body").hasClass("maximized") ) {
			$("body").removeClass("maximized");
		} else {
			$("body").addClass("maximized");
		}

		var currentWrapper = $("._contentWrapper:visible");
		/*
	    if( $("section.page-content").data("SCREEN_MODE") == undefined ) {
	    	$("section.page-content").data("SCREEN_MODE", "NORMAL");
	    }

	    var currentWrapper = $("main ._contentWrapper:visible");

	    if( $("section.page-content").data("SCREEN_MODE") == "NORMAL" ) {
			$("section.page-content").data("LEFT", $("main").css("left") );

			$("header, aside, ._closeButton").hide();
			$("section.page-content ._header , section.page-content ._toolBox").hide();
			$("section.page-content").css({ top : "0px", left : "0px" });
			$("section.page-content ._contents").css({ top : "0px" });
			$("section.page-content ._contentWrapper").css({ top : "0px" });

			$(currentWrapper).find("._content").css({ top : "25px"});
			$(currentWrapper).find("._handle").show();

			$("section.page-content").data("SCREEN_MODE", "MAX");
	    } else {
			$("header, aside, ._closeButton").show();
			$("section.page-content ._header , section.page-content ._toolBox").show();

			$(currentWrapper).find("._content").css({ top : "0px"});
			$(currentWrapper).find("._handle").hide();

			$("section.page-content ._contentWrapper").css({ top : "6px" });

			$("section.page-content").css({ top : "28px", left : $("section.page-content").data("LEFT") });
			$("section.page-content ._contents").css({ top : "24px" });

			$("section.page-content").data("SCREEN_MODE", "NORMAL");
	    }
	    */

    	var id = currentWrapper.data("id");
    	var form = LayoutManager.getForm(id);
	    form.refreshGrid();
	}

	function loadFavoriteData(){
		//정보 인출 부분 작성.
		transaction( 'lgcom', "lgsysc/LGSYSC00070/retrieveFavoriteList", {} , function(data) {
			favoriteList.clear();
			$("aside ._favoriteBody ._selected, aside ._favoriteBody ._all").empty();

			var seq = 1;

			$( data["result"] ).each( function(){
				var item = this;
				var bizFormId = uuid();
				menuItems.put( bizFormId, { systemCode : item["systemCode"], name : item["menuName"],  programId : item["programId"], menuId : item["menuId"] , urlAddr : item["urlAddr"] } );

				var obj;
				if( item["itemType"] == "SELECTED") {
					//특정 메뉴아이디가 Favorite 돼 있는지 확인하기 위한 Map 을 운영함 ( 사용자 정의 아이템만 여기에 포함시킨다.)
					favoriteList.put( item["menuId"], item );
					//
					obj = $('<li><button class="btn-link ico-lgd" data-id="'+bizFormId+'"><i class="fa fa-star" aria-hidden="true"></i></button><a href="#" class="_favoriteMenu" title="'+ item["menuName"] +'" data-id="'+ bizFormId +'">'+item["menuName"]+'</a><i aria-hidden="true" class="fa fa-bars _handle"></i></li>');
					$("#lnbFavorit ._selected").append( obj );
				} else {
					obj = $('<li><a href="#" class="_favoriteMenu" title="'+ item["menuName"] +'" data-id="'+ bizFormId +'" >'+item["sortOrderNo"]+". "+item["menuName"]+'</a></li>');
					$("#lnbRecent ._all").append( obj );
				}
			});
		});

		$("#lnbFavorit ._selected").sortable({
			axis: "y",
			containment: "parent",
			handle: "._handle",
			placeholder : "_favoriteItemPlaceHolder" ,
			hoverClass  : "_favoriteItemOnDrag",
			stop : function( event, ui ) {
				updateFavoriteOrder();
			}
		});

		$("aside ._favoriteBody ._selected").droppable({
			drop : function( event, ui ){
				$(ui.draggable).removeClass('_favoriteItemOnDrag');
			},
			over: function(event, ui) {
				$(ui.draggable).addClass('_favoriteItemOnDrag');
			}
		});
	}

	function updateFavoriteOrder() {
		var sortOrder = new Array();
		$("aside ._favoriteBody ._selected ._favoriteMenu").each( function(inx){
			var bizFormId = $(this).data("id");
			var menuItem = menuItems.get( bizFormId );
			sortOrder.push( { menuId : menuItem.menuId , sortOrderNo : (inx+1) });
		});

		transaction( CONTEXT_PATH, "lgsysc/LGSYSC00070/updateFavoriteSortOrder", { sortOrder : sortOrder } , function(data){
			Message.notify("Favorite reordered !!");
			loadFavoriteData();
		});
	}

	/* 현재의 열린 폼이 가진 메뉴아이디를 확인하여, 이것이 favoriteList 에 있는지 보고 있다면,  화면 오른쪽 상단의 즐겨찾기 버튼을 활성화 한다.*/
	function markFavoriteIcon() {
		if( currentBizFormId == undefined  ) {
			$("._toolBox button[data-action='markFavorite'] .ico").removeClass( "ico-favorite-on" ).addClass( "ico-favorite-off" );  //즐겨찾기 버튼의 아이콘 초기화
			$("._toolBox button._toggleSearch").removeClass( "_toggle" );  //조회영역 감추기 버튼의 아이콘 초기화
			return;
		}

		var menuId = menuItems.get( currentBizFormId )["menuId"];
		if( favoriteList.containsKey( menuId ) ) {
			$("._toolBox button[data-action='markFavorite'] .ico").addClass( "ico-favorite-on" ).removeClass( "ico-favorite-off" );
		} else {
			$("._toolBox button[data-action='markFavorite'] .ico").removeClass( "ico-favorite-on" ).addClass( "ico-favorite-off" );
		}

		var bizForm = forms.get( currentBizFormId );
	}
	
	function toggleSearchConditionControl() {
		if( currentBizFormId != undefined  ) {
			var menuItem = menuItems.get( currentBizFormId );
			trace(menuItem);
			if( menuItem["userManualFlag"] == "Y" ) {
				$(".mdi-page-control button[aria-label='Help']").removeAttr("disabled" );
			} else {
				$(".mdi-page-control button[aria-label='Help']").prop("disabled", true );
			}
		}
	}

	/*로고를 클릭했을때 인트로 화면이 보이도록 하는 이벤트  ( 보이기 이전에 refresh 를 호출해서 데이터 갱신을 수행한다. )*/
	$(document).on( "click._main", "._logo", function( event ) {
		var showIntro = true;

		try {
			if( Profile.USE_INTRO == "Y" ) {
				if( SESSION_USER.systemCode == "LGPRO" ) {
					if( $(document).data("introCase") == 2 ) {
						showIntro = true;
					} else {
						showIntro = false;
					}
				}
			} else {
				showIntro = false;
			}

			if( showIntro ) {
				// 17.04.04
				// 전체 탭 닫은 후 인트로 이동이 안되는 문제 때문에 추가
				if (reloadFlag == 'Y') {
					reloadFlag = 'N';
				}

				if( $("._introWrapper").data("loaded") == undefined ) {
					$(document).off(".intro");
					$("._intro").show();
					loadIntro();
				} else {
					//intro 가 이미 로드 돼 있는 경우라면, 단순히 show 한  다음 데이터 갱신만 지시한다.
					$("._intro").show();
					intro.refresh();
				}
			}

			//프로파일을 사용하도록 설정이 돼 있는데, intro 가 초기화 돼 있지 않은 경우
			if( Profile.USE_INTRO == "Y" && intro != undefined ) {
				$("header ._menu._level1 ._menuItem").removeClass("active");
			}
		} catch(e) {
			trace( e ); 
		}
	});

	/*탭 핸들에 대한 오른쪽 클릭을 지원하는 이벤트 */
	$(document).on(  "contextmenu.main", "._header ._contentName", function( event ){
		//만일 최대화 모드였다면 컨텍스트 메뉴는 없음
		if( $("body").hasClass("maximized") ) {
			return false;
		} 
		
		var item = $(event.target);
		if( !item.hasClass("_contentName") ) {
			item = $(event.target).parents("._contentName");
		}

		var id = $(item).data("id");
		setTabActive( id );

		$("._tabContextMenu").data("formId", id );
		$("._tabContextMenu").css( "top", event.pageY ).css( "left", event.pageX + 5 ).show();

		event.preventDefault();
		event.stopPropagation();
	});

	$(document).on(  "click.main", "._tabContextMenu [data-action]", function( event ){
		var action = $(event.target).data("action"); 
		if( action == "closeThis" ) {
			closeTab( $("section.page-content ._header ._contentName._selected") );
		} else if( action == "closeOthers" ) {
			var siblings = $("section.page-content ._header ._contentName._selected").siblings();
			$(siblings).each( function(){
				closeTab(this);
			});
		} else if( action == "closeAll" ) {
			_this.closeAllTabs();
		}

		$("._tabContextMenu").hide();

		action = null;
		event.preventDefault();
		event.stopPropagation();
	});

	/* 이벤트 핸들러 :  Top 메뉴의 항목을 마우스로 선택했을 때를 위한 이벤트 핸들러 */
	$(document).on( "click._main", "header ._menu ._menuItem", function( event ) {
		var item = $(event.target);
		if( !$(item).hasClass("_menuItem") ) {
			item = item.parent();
		}

		//플로팅 화면들을 모두 숨긴다.
		hideFolatingPannel();
		LayoutManager.hideIntro();

		//좌측 메뉴 부분 layer 정리를 수행한다 ( favorite 숨기고, 메뉴가 보이도록 )
		$("._favoriteBody").hide(0);
		$("._menuBody").show();
		$("._favoriteButton").children(".ico").removeClass("ico-menu-favorite-s").addClass("ico-menu-favorite");

		//가장 첫번째 Topmenu 를 활성화 한다.
		selectFirstTopMenu(item);

		//가장 첫번째 메뉴가 외부 링크인 경우에 대한 별도의 처리
		var menuItem = menuItems.get( item.data("bizFormId") );
		if( menuItem["programTypeCode"] != undefined && menuItem["programTypeCode"] == "LINK" ) {
			var nav = new Navigate("/", menuItem["linkUrlAddr"] );
			nav.goPageInNewBrowerTab();
		}
	});

	function selectFirstTopMenu( item ) {
		if( item == undefined ) {
			item =  $("header ._menu ._menuItem:first-child");
		}
		//선택된 항목의 ID 를 읽어온다.
		var id = $(item).data("id");

		$("header ._menu._level1 ._menuItem").removeClass("active");
		$("header ._menu._level1 ._menuItem[data-id="+id+"]").addClass("active");

		$("aside ._level2").hide();
		$("aside ._subMenu").hide();

		$("aside ._level2[data-level1="+ id +"]").show();

		//aside 의 모든 _subMenu 를 닫힌 상태로 정리해준다.
		$("aside ._level2._selected").removeClass("_selected");
		$("aside ._subMenu").data("status", "CLOSED");
		$("aside ._expander").removeClass("rotate180");

		//Top 메뉴의 타이틀을 좌측 메뉴 최상단에 부여한다.
		$("aside ._menuTitle").text( $(item).text() );
		//20160905 추가
		$("aside ._menuTitle").attr('title', $(item).text() );

		//좌측 메뉴의 Favorite 가 활성화 돼 있을때는, 메뉴 레이어로 돌려준다.
		if( $("aside ._favoriteButton").hasClass("selected") ) {
			$("aside ._menuContent").hide(0);
			$("aside ._menuBody").hide();

			$("aside ._favoriteButton").removeClass("selected");
		}
	}

	/* 이벤트 핸들러  :  왼쪽 메뉴 2레벨 메뉴를 클릭했을때의 이벤트 핸들러 */
	$(document).on( "click._main", "._menuBody ._level2, ._menuBody ._level2 span", function(event) {
		//대상이 되는 subMenu 는 level2 아이템의 바로 아래 것
		var item = $(event.target);
		if(  !item.hasClass("_level2") ) {
			item = item.parent();
		}
		
		$("._menuBody ._level2 ul").hide();
		$("._menuBody ._level2 a span").removeClass("fa-angle-up").addClass("fa-angle-down");

		$(item).find("ul").show();
		$(item).find("span").removeClass("fa-angle-down").addClass("fa-angle-up");

		event.stopPropagation();
	});

	/* 이벤트 핸들러  :  왼쪽 메뉴 3레벨 메뉴를 클릭했을때의 이벤트 핸들러 */
	$(document).on( "click._main", "._menuBody ._level3", function(event) {
		var target = $(event.target);
		if( !$(target).hasClass("_level3") ) {
			target = $(target).parent();
		}

		$("._menuBody ._level3.active, ._menuBody ._level4.active").removeClass("active");
		$(target).addClass("active");

		if( !target.hasClass("_level3") ) {
			target = $(event.target).parents("_level3");
		}
		
		event.preventDefault();
		event.stopPropagation();
		addTab( $(target).data("bizFormId")  );
	});

	/* 이벤트 핸들러  :  왼쪽 메뉴 3레벨 메뉴를 클릭했을때의 이벤트 핸들러 */
	$(document).on( "click._main", "._menuBody ._level4", function(event) {
		var target = $(event.target);
		if( !$(target).hasClass("_level4") ) {
			target = $(target).parent();
		}

		$("._menuBody ._level3.active, ._menuBody ._level4.active").removeClass("active");
		$(target).addClass("active");

		if( !target.hasClass("_level4") ) {
			target = $(event.target).parents("_level4");
		}
		
		event.preventDefault();
		event.stopPropagation();
		addTab( $(target).data("bizFormId")  );
	});
	
	/* 이벤트 핸들러  : ToobBox 의 아이콘들을 클릭했을때의 이벤트 핸들러 */
	$(document).on("click._main", "._toolBox  button[data-action]", function(event) {
		var item = $(event.target);
		var action = $(item).data("action");
		if( action == undefined ) {
			item = $(item).parent();
			action = $(item).data("action");
		}

		if ( action == "closeAll" ) {
			_this.closeAllTabs();
		} else if ( action == "toggleSearch" ) {
			var bizForm = forms.get( currentBizFormId );
			bizForm.toggleSearch();
		} else if ( action == "markFavorite" ) {
			if( currentBizFormId == undefined ) { return; }
			var menuId = LayoutManager.getMenuItem(currentBizFormId).menuId;
			
			if( item.find(".ico").hasClass( "ico-favorite-on" ) ) {
				Message.confirm( "<lgcom:message code="question.favoriteRemove"/>" , function(){
					transaction( CONTEXT_PATH, "lgsysc/LGSYSC00070/deleteFavoriteItem", { menuId : menuId } , function(data){
						Message.notify("Favorite removed !!");
						item.find(".ico").removeClass( "ico-favorite-on" ).addClass("ico-favorite-off");
						loadFavoriteData();
					});
				});
			} else {
				Message.confirm( "<lgcom:message code="question.favoriteAdd"/>" , function(){
					transaction( CONTEXT_PATH, "lgsysc/LGSYSC00070/insertFavoriteItem", { menuId : menuId } , function(data){
						Message.notify("Favorite added !!");
						item.find(".ico").removeClass( "ico-favorite-off" ).addClass("ico-favorite-on");
						loadFavoriteData();
					});
				});
			}
		} else if ( action == "searchCondition" ) {
			$("div#" + currentBizFormId ).find("._searchControlButton").toggle();
			$("section.page-content ._toolBox ._searchCondition").toggleClass("_open");
		} else if ( action == "showSearchCondition" ) {
			 $(item).closest('.mdi-page-control').addClass('shift-left');
		} else if ( action == "hidewSearchCondition" ) {
			$(item).closest('.mdi-page-control').removeClass('shift-left');
		} else if ( action == "saveSearchCondition" ) {
			var bizForm = forms.get( currentBizFormId );
	        bizForm.saveSearchCondition();
		} else if ( action == "deleteSearchCondition" ) {
			var bizForm = forms.get( currentBizFormId );
			bizForm.deleteSearchCondition();
		} else if ( action = "showManual" ) {
			var menuItem = LayoutManager.getMenuItem( currentBizFormId );
			if( menuItem == undefined ) { return; }

			var size = { width : 1036, height : 600 };
			var winName= "_screen_manual_";
			var winURL= SERVER_URL + "/lgcom/container?menuId=M_LGUTLC_1183";
			var windowoption='resizable=yes,height='+ size.height +',width='+ size.width +',location=0,menubar=0,scrollbars=1, top=50, left=50';

			var form = $("#_open_popup_temp_form_");

			if( !form.exists() ) {
				$("body").append("<form id='_open_popup_temp_form_' method='POST'></form>");
				form = $("#_open_popup_temp_form_");
			}
			$(form).empty();

			$(form).attr("action", winURL);
			$(form).attr("target",winName);
			$(form).append("<input type='hidden' name='manualProgramId' value='"+ menuItem["programId"] +"' />");

			window.open('', winName,windowoption);
			$(form).submit();
		}
	});

	/* 이벤트 핸들러  : ToobBox 의 아이콘들을 클릭했을때의 이벤트 핸들러 */
	$(document).on("click._main", "._profileBox [data-action]", function(event) {
		var item = $(event.target);
		var action = $(item).data("action");

		if( action == undefined ) {
			item = $(item).parent();
			action = $(item).data("action");
		}

		if( action == "userProfile") {
			if(LayoutManager.getPopups() && LayoutManager.getPopups().size() == 0) {
				LayoutManager.toggleIframeOnActiveTab( false );
			}

			var menuItem = { systemCode : "LGCOM", 
					         name : "My Page",  
					         programId : "LGSYSC00050",
					         menuId : "userProfile"  };
			
			var height = 439;
			if( isSmallLayout() ) {
				height = 350;
			}
		    sideApp.open( menuItem, { width : 650, height : height } );
			
		} else if( action == "userMenu") {
			if(LayoutManager.getPopups() && LayoutManager.getPopups().size() == 0) {
				LayoutManager.toggleIframeOnActiveTab( false );
			}

			var menuItem = { systemCode : "LGCOM", 
					         name : "User Menu",  
					         programId : "LGSYSC00220",
					         menuId : "userMenu"  };
			sideApp.open( menuItem );
		} else if( action == "logout") {
			var nav = new Navigate(CONTEXT_PATH, "logout");
			nav.goGet();
		} else if( action == "logWin") {
			if(typeof(debugWindow)=='undefined' || debugWindow.closed) {
				debugWindow = window.open('/lgcom/debugWin.jsp','','top=0,left=0,width=500,height=500,scrollbars=auto,resizable=yes');
			}
		} else if( action == "shortcutMenu") {
			var plate = $( "._shortCutMenu"  );

			if( plate.hasClass("_show") ) {
				plate.removeClass("_show");
				//$("#_div_global_background_").hide();
				// 201.07.11. forain. Popup에서 Popup이 open 된 경우 BIMATRIX 처리 안함.
				if(LayoutManager.getPopups() && LayoutManager.getPopups().size() == 0) {
					LayoutManager.toggleIframeOnActiveTab(false);
				}
			} else {
				hideFolatingPannel();
				//$("#_div_global_background_").show();
				// 201.07.11. forain. Popup에서 Popup이 open 된 경우 BIMATRIX 처리 안함.
				if(LayoutManager.getPopups() && LayoutManager.getPopups().size() == 0) {
					LayoutManager.toggleIframeOnActiveTab(false);
				}
				plate.addClass("_show");
				shortcut.refresh();
			}

		} else if( action == "refreshResource" ) {
			$.getJSON(  "/lgcom/refresh" , function(){
				Message.alert("Refresh complete !");
				// 전체 화면 Reload
				var nav = new Navigate('lgcom','main');
				nav.addParam('reload','Y');
				nav.goPost();
			});
		} else if( action == "contactPoint" ) {
			if(LayoutManager.getPopups() && LayoutManager.getPopups().size() == 0) {
				LayoutManager.toggleIframeOnActiveTab( false );
			}

			var menuItem = { systemCode : "LGCOM", 
					         name : "Contact Point",  
					         programId : "LGUTLC00407",
					         menuId : "M_LGUTLC_1172"  };
			
			var height = 400;
			if( isSmallLayout() ) {
				height = 350;
			}
		    sideApp.open( menuItem, { width : 600, height : height } );
		} else {
				$("section.page-content ._header, section.page-content ._toolBox").show();
				$("section.page-content").data("SCREEN_MODE","NORMAL");
		}
		// event.stopPropagation();
	});


	$(document).on("click", "section.page-content ._contentWrapper", function( event ){
		$("section.page-content ._contentWrapper").css("z-index", 100 );
		$(this).css("z-index", 101 );
	});


	$(document).on("dblclick", "section.page-content ._contentWrapper ._handle", function( event ){
		toggleAppMaximize();
		event.stopPropagation();
		return;


	    var wrapper = $(event.target).parent();
	    if( wrapper.data("STATUS") != "MAX" ) {

	    	var positionInfo = { top : $(wrapper).css("top"),
	    			             left :  $(wrapper).css("left") ,
	    			             width :  $(wrapper).width(),
	    			             height : $(wrapper).height(),
	    			             zoom : $(wrapper).find("._content").css("zoom"),
	    			             "main-left" : $("main").css("left")
	    			             };
	    	$(wrapper).data("POSITION_INFO", positionInfo );

	    	$("header, aside, ._closeButton").hide();
	    	$("main").css( {"top" : "0px", "left": "0px"} );

		    $(wrapper).css({"width" : "auto", "height" : "auto", "left" : "0px", "right" : "0px", "top" : "0px", "bottom" : "0px" });
		    $(wrapper).find("._content").css({"zoom" : 1, "top" : "20px" });
		    $(wrapper).data("STATUS", "MAX");
		    $(wrapper).removeClass("floating");
		    $(wrapper).draggable("disable");
		    $(wrapper).resizable("disable");
		    $(wrapper).find(".externalFrame").show();

		    $(wrapper).show();
		    $("section.page-content ._contentWrapper").not(wrapper).hide();

			$("section.page-content ._contentWrapper").css("z-index", 100 );
			$(wrapper).css("z-index", 101 );

	    	var id = wrapper.data("id");
	    	var form = LayoutManager.getForm(id);
		    form.refreshGrid();

	    } else {
	    	var positionInfo = $(wrapper).data("POSITION_INFO" );
	    	$(wrapper).css({"width" : positionInfo.width, "height" : positionInfo.height, "left" : positionInfo.left, "right" : "auto", "top" : positionInfo.top, "bottom" : "auto" });
	    	$(wrapper).find("._content").css({"zoom" : 1, "top" : "20px" });
	    	$(wrapper).addClass("floating");

	    	$(wrapper).draggable("enable");
	    	$(wrapper).resizable("enable");

	    	$(wrapper).find(".externalFrame").hide();
	    	$("section.page-content ._contentWrapper").show();

	    	$("header, aside, ._closeButton").show();
	    	$("main").css( {"top" : "28px", "left": positionInfo["main-left"] } );

	    	$(wrapper).data("STATUS", "NORMAL");

	    	var id = wrapper.data("id");
	    	var form = LayoutManager.getForm(id);
		    form.refreshGrid();
	    }

	});

	function hideFolatingPannel() {
		if( $( "._shortCutMenu" ).hasClass("_show") ) {
			$( "._shortCutMenu" ).removeClass("_show");
		}

		$("._profileBox .button").removeClass("_selected");
		if(LayoutManager.getPopups() && LayoutManager.getPopups().size() == 0) {
			LayoutManager.toggleIframeOnActiveTab( true );
		}
	}

	/* 이벤트 핸들러  : ToobBox 의 아이콘들을 클릭했을때의 이벤트 핸들러 */
	$(document).on("mouseenter._main", "header ._profileBox .button[data-action='shortcutMenu']", function(event) {

	});

	/* 이벤트 핸들러 : 탭홀더에 아이템이 추가되거나 삭제될 때의 이벤트 핸들러 */
	$(tabHolder).bind("DOMSubtreeModified propertychange",function() {
		if( $(this).find("._contentName").length > 0  ) {
			$("section.page-content ._toolBox ._contentNameExtend").addClass("_initem");
		} else {
			$("section.page-content ._toolBox ._contentNameExtend").removeClass("_initem");
			$("section.page-content ._contentNameExtendPannel").hide();
		}
	});

	/* Static 메소드 : 주로 Global 객체에 대한 핸들링을 담당한다. */
	LayoutManager.closeAllTabs = function() {
		_this.closeAllTabs();
	}

	LayoutManager.closeTab = function( bizFormId ) {
		var item = $("div._contentWrapper[data-id='"+bizFormId+"']")
		closeTab( item );
		item = null;
	}

	LayoutManager.addForm = function( formId, formObject ) {
		forms.put(formId , formObject );
		trace("[SYSTEM] New Form " + formId + " added.  count : " + forms.size() );
	}

	LayoutManager.removeForm = function( formId ) {
		var form = forms.get( formId );

		//form 객체를 초기화 한다.
		if( form != undefined ) {
			form.destroy();
			forms.remove( formId );
			//폼이 없어지는 순간에, 해당 폼에서 추가한 이벤트 핸들러를 모두 제거처리한다. BizForm 에서 추가해두었던 namespace 기준으로 처리함
			$("#" + formId ).off("." + formId );
		}

		//DOM에 생성된 달력을 삭제 한다.
		$("#"+ formId).find("._datePicker").each(function() {
			var datePicker = $(this).data('dateRangePicker');
			if( typeof datePicker == "object" ) {
				$(this).data('dateRangePicker').destroy();
			}
		});

		for (var k in form) {
			if( k.indexOf("GRID_") == 0  ||  k.indexOf("FORM_UTIL_") == 0) {
				form[k] = null;
				delete form[k];
			}
		}

		// Window 에서 함수 객체 선언부 자체를 를 삭제하는 부분
		try {
			var menuItem = menuItems.get( formId );
			if( typeof window[ menuItem["programId"] ] == "function") {
				window[menuItem["programId"]].prototype = null;  //상속관계에 있는 무
				window[ menuItem["programId"] ] = undefined;
				delete  window[ menuItem["programId"] ];
				//trace("[SYSTEM] Form function deleted. [programId] : " + formId );
			} else {
				if( window[ formId ] ) {
				    window[ formId ].prototype = null;
				    window[ formId ] = undefined;
				    delete  window[ formId ];
				}
				//trace("[SYSTEM] Form function deleted. [formId] : " + formId );
			}
			LayoutManager[ formId ] = null;
			delete LayoutManager[ formId ];
		} catch( e ) {
			trace(e);
		}
		//특정 폼안에 iframe 이 있는 경우에 자원을 해제 하기 위한 부분
		$("._content[id='"+ formId +"']").find("iframe").attr("src","about:blank").remove();
	}

	LayoutManager.getForm = function( formId ) {
		return forms.get( formId );
	}

	/*
	 * menuId 를 통해서 현재 화면에 열려 있는 Form 을 리턴하는 함수
	 * 동일한 menuId 의 화면이 여러개 열려 있는 경우, 그 중 가장 첫번 째 것만 나오게 되므로 유의
	 */
	LayoutManager.getFormByMenuId = function( menuId , options ) {
		if( options == undefined ) {
			options = { active : false, openTarget : false };
		} else {
			if( options.active == undefined ) {
				options.active = false;
			}
		}

		var formId = $("section.page-content ._content[data-menuid='"+ menuId +"']").attr("id");
		if( options.active ) {
			setTabActive( formId );
		}
		return forms.get( formId );
	}

	LayoutManager.getPopups = function() {
		return  popups;
	}

	LayoutManager.addPopup = function( caller, callee ) {
		popups.put(callee , caller );
		popupStack.push( callee );
		//trace("[SYSTEM] New Popup " + callee + " added.  count ( by popup form ): " + popups.size() + " Stack count : " + popupStack.length );
		return popupStack.length;
	}

	LayoutManager.removePopup = function( callee ) {
		popups.remove(callee );
		popupStack.removeByValue( callee );
		//trace("[SYSTEM] Popup " + callee + " removed.  count ( by popup form ): " + popups.size() + " Stack count : " + popupStack.length );
	}

	LayoutManager.getParent = function( callee ) {
		var caller = popups.get(callee );
		return LayoutManager.getForm(caller);
	}

	LayoutManager.getMenuItems = function() {
		return menuItems;
	}

	LayoutManager.getMenuItem = function( bizFormId ) {
		return menuItems.get( bizFormId );
	}

	LayoutManager.getCurrentBizFormId = function( callee ) {
		return currentBizFormId;
	}

	LayoutManager.setCurrentBizFormId = function( id ) {
		currentBizFormId = id;
	}
	
	/* 외부에서 단지 menuId 만 가지고 있는 상황에서 화면에 정식으로 tab 을 띄워야 하는 경우에 대한 Static 메소드 */
	LayoutManager.addTab = function( bizFormId , parameter ) {
		addTab( bizFormId, parameter );
	}

	/* 외부에서 단지 menuId 만 가지고 있는 상황에서 화면에 정식으로 tab 을 띄워야 하는 경우에 대한 Static 메소드 */
	LayoutManager.addTabByMenuId = function( menuId , parameter, callback ) {
		var _formId;
		$(menuItems.keys()).each( function(){
			var _item = menuItems.get( this );
			if( _item["menuId"] == menuId ) {
				_formId = this;
				return false;
			}
		});
		_formId = undefined;  // 삭제해야함

		//만약 메인 메뉴 리스트에 열고자 하는 메뉴가 없다면
		if( _formId == undefined ) {
			transaction_sync("lgcom", "common/uiCommon/retriveMenuItemFromCache", { menuId  : menuId }, function( data ){
				_formId = uuid();
				data["result"][0]["name"] = data["result"][0]["menuName"];
				menuItems.put( _formId, data["result"][0] );
			});
		}
		addTab( _formId, parameter, callback );
	}

	/* 외부에서 받은 menuId와 메뉴 정보를 받아서 화면에 정식으로 tab 을 띄워야 하는 경우에 대한 Static 메소드 */
	LayoutManager.addTabByMenuItem = function( bizFormId , menuItem, param ) {
		menuItems.put( bizFormId, menuItem );
		addTab( bizFormId , param );
	}

	LayoutManager.applyUserTheme = function() {
		applyUserTheme();
	}

	LayoutManager.hideIntro = function( callback ) {
		try {
			callback.call( this );
		} catch( e ) {}

		$("._intro").hide( 0, function(){
			$(document).off(".intro");
			$("._introWrapper").removeData().empty();
			delete window["IntroPage"];
		});
	}

	LayoutManager.hideSearchCondition = function() {
		$("button[data-action='hidewSearchCondition']").closest('.mdi-page-control').removeClass('shift-left');
	}

	LayoutManager.toggleIframeOnActiveTab = function( flag ) {
		if( flag ) {
			$("section.page-content div[id='"+ currentBizFormId +"']._content  iframe.externalFrame").show();
			$("#_div_global_background_").hide();
		} else {
			$("section.page-content div[id='"+ currentBizFormId +"']._content  iframe.externalFrame").hide();
		}
	}

	//body 에서 띄운 팝업들이 다른 곳을 눌렀을 때 없어져야 하는 이벤트
	$(document).bind( "click", function( event ) {
		var $clicked = $(event.target);
		if ( !$clicked.hasClass("_tabContextMenu") ) {
			$("._tabContextMenu").hide();
		}
	});

	/*
    $('header.navbar .navbar-form .navbar-search').on('mouseenter', function (e) {
        $(this).closest('.container').addClass('extended');
        $(window).resize();
    });

    $('header.navbar').on('mouseleave', function (e) {
        $(this).find('.container').removeClass('extended');
        $(window).resize();
    });	
	*/
	
	//Session time out 시간을 update 하는 부분
	setInterval( function() {
		$("._globalStatusBar ._sessionTimeRemain").text( humanReadable( SESSION_INTERVAL ) );
		SESSION_INTERVAL--;
	}, 1000);

	LayoutManager.initSessionTimeout = function() {
		SESSION_INTERVAL = <%= session.getMaxInactiveInterval() %>
		;
			}

			function humanReadable(seconds) {
				var pad = function(x) {
					return (x < 10) ? "0" + x : x;
				}
				return pad(parseInt(seconds / (60 * 60))) + ":"
						+ pad(parseInt(seconds / 60 % 60)) + ":"
						+ pad(seconds % 60)
			}
		}
var SystemDateSupport = function() {
	var timer = setInterval(refreshTime, 1000);
	var _this = this;
	var current;

	function refreshTime() {
		current = moment( current ).add(1, 'seconds');
		var gmtText = Number( SESSION_USER.serverTimeDifferenceSeqs );
		if( gmtText > 0 ) {
			gmtText = "+" + Math.abs( gmtText );
		} else {
			gmtText = "-" + Math.abs( gmtText );
		}
		$("footer ._globalStatusBar ._currentTime").text( moment( current ).format("YYYY-MM-DD HH:mm:ss") + " (GMT "+ gmtText +")" );
	}

	this.setServerTime = function( serverTimeText ) {
		current = moment( serverTimeText, "YYYYMMDD HH:mm:ss");
	}

	this.getTime = function() {
		return current;
	}

	SystemDateSupport.getTime = function() {
		return current;
	}

	SystemDateSupport.setServerTime = function(serverTimeText) {
		this.setServerTime( serverTimeText ) ;
	}

	$("footer ._globalStatusBar ._currentTime").click( function(){
		trace(  moment( _this.getTime() ).format("YYYY-MM-DD HH:mm:ss") );
	});
}		
	<%@ include file="/WEB-INF/views/framework/commonMessage.jsp" %>
		//]]>
	</script>

</body>
</html>
