<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%---------------------------------------------------------
    파일명 : container.jsp
    프로젝트명 : LGD WCFW 프로젝트

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 타 시스템에서 Open하는 화면, Window 형태 popup, /lgcom/container?menuId=M_XXXXX
    작성자 : WCFW
-------------------------------------------------------------%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta http-equiv="x-ua-compatible" content="IE=edge">
<title>WCFW</title>
<%@ include file="/WEB-INF/views/framework/header.jsp" %>

<script>
<%@ include file="/WEB-INF/views/framework/profile.jsp" %>
</script>

<script>
if( Param.debug != "Y") {
	window.onerror = function( errorMsg, url, lineNumber, column, error ){
		// CKEditor이면 Skip
		if(error.name != 'TypeError') {
			Message.alert("<lgcom:message code="error.systemError"/>" + "<br> Error : " + errorMsg );
		}
		return true;
	};
}
</script>
<style>
html , body {
	position : static;
}

._container {
    position: absolute;
    top: 0px;
    left: 0px;
    bottom: 0px;
    right: 0px;
}

main {
    position: absolute;
    top: 35px;
    left: 10px;
    right: 10px;
    bottom: 10px;
}

main ._wrapper {
    height : 100%;
    width : 100%;
}

main ._contents {
    height : 100%;
    width : 100%;
}

main ._contentWrapper {
	bottom: 0px;
	overflow: auto;
	left:0px;
	right:0px;
}

main ._content {
	min-width : auto;
}

._container  main > ._wrapper > ._contents > ._contentWrapper > ._managed_layout_ > .mdi-container {
    left: 0px;
    top: 0px;
    right: 0px;
    bottom: 0px;
}

._pageTitleWrapper  {
	background-color : #474751;
	width : 100%;
	height : 25px;
	position: absolute;
}

._pageTitleWrapper > ._pageTitle {
	margin : 0px !important;
	position: absolute;
	top :  4px;
	left : 10px;
	color : #ffffff;
	font-size : 14px;
}
</style>
</head>

<body class="main _container <%= request.getAttribute("USE_SMALL_LAYOUT") %>">
<div class="_pageTitleWrapper">
	<h2 class="_pageTitle"></h2>
</div>
<main>
	<div class="_wrapper" >
		<div class="_contents">
			<div class="_contentWrapper">
				<div class="_content"></div>
			</div>
		</div>
		<div class="_globalStatusBar"><span class="_message"></span></div>
	</div>
</main>

<%@ include file="/WEB-INF/views/main/fileManager.jsp"%>

<%@ include file="/WEB-INF/views/main/excelUploader.jsp"%>
<script>
/* Event handler triggered just after page ready. */
$(document).ready(function() {
	//백스페이스를 눌렀을 때에, 이전 페이지로 이동되는 것을 막기 위한 코드
	$(document).on("keydown", function(event){
		if( event.target.nodeName != "INPUT" && event.target.nodeName != "TEXTAREA" ){
			if( event.keyCode === 8 ){
				return false;
			}
		}
	});

	// IE에서만 beforeunload 이벤트 핸들러가 작동한다.
	if((navigator.appName == 'Netscape' && navigator.userAgent.search('Trident') != -1) || (navigator.userAgent.toLowerCase().indexOf("msie") != -1)) {
		$(window).on('beforeunload', function(evt) {
			destroyContainer();
		});
	} else {
		$(window).unload( function(){
			destroyContainer();
		});
	}

	function destroyContainer() {
		
		$("main iframe").attr("src", "about:blank");
		
		var id = $("main div._contentWrapper").data("id");
		trace("[SYSTEM] iframe content unload : " + id );
		LayoutManager.closeTab( id );
	}

	//브라우저 뒤로가기를 막기 위한 코드
	window.history.forward(0);

	var layout = new LayoutManager();
});

LayoutManager = function( mode ) {
	var _this = this;
	var animationDuration = 250;
	var notitle = '<c:out value="${param.notitle}"/>';
	var nostatus = '<c:out value="${param.nostatus}"/>';
	var programTypeCode = '<c:out value="${programTypeCode}"/>';
    var linkUrlAddr = '<c:out value="${linkUrlAddr}"/>';

	if( notitle == "Y" ) {
		$("._pageTitle").hide();
		$("main ._contents").css("top", "0px");
		$("main").css({ top : "0px", bottom : "0px", left : "0px", right : "0px"});
	}

	if( nostatus == "Y" ) {
		// Contents 영역 사이즈 조절
		$("main ._contents").css({ top : "0px", bottom : "0px", left : "0px", right : "0px"});
		// 상태바 숨기기
		$("main ._globalStatusBar").hide();
	}

	//처음 페이지가 로딩 됐을때의 타이틀
	var initTitle = document.title + "(" + SYSTEM_ENV.toUpperCase() +")";
	document.title = initTitle;

	//User Access List 를 담을 data 를 형성한다.
	if( $(document).data("USER_ACCESS_LIST") == undefined ) {
		$(document).data("USER_ACCESS_LIST", new Map() );
		$(document).data("USER_ACCESS_LIST_COUNT", new Map() );
	}

	//각 폼에 있는 그리드를 담을 data 를 형성한다. : 그리드가 container 의 보이기 / 안보이기 속성에 따라서 때때로 드러나지 않는 문제를 해결하기 위한 workaround 이다.
	if( $(document).data("FORM_GRID_LIST") == undefined ) {
		$(document).data("FORM_GRID_LIST", new Map() );
	}

	/*현재 활성화 돼 있는 탭의 프로그램 ID */
	var currentBizFormId;

	var menuItems = new Map();

	//화면에 드러난 모든 폼의 오브젝트를 저장하는 객체 : 폼의 생성과 삭제따라 크기가 변하면서 반응한다.
	var forms = new Map();
	//화면에 드러난 모든 팝업을 저장하는 객체 { caller : "..", callee : ".." } 형태로 저장되어, 팝업이 자신의 parent 를 찾을 수 있도록 하고 있다.
	var popups  = new Map();
	//팝업은 여러개 뜰 수 있기 때문에, Popup.openPopup() 이 호출 된다면, 그때의 callee 를 차곡차곡 모아놓아야 한다.
	var popupStack = new Array();

	/*메소드 : 현재 탭으로 활성화된 programId 를 얻기위한 메소드  */
	this.getCurrentBizFormId = function(){
		return currentBizFormId;
	}

	var contents = $("main div._contents");
	var contentWrapper = $( "main div._contentWrapper");
	var content = $( "main div._contentWrapper > div._content");

	if( programTypeCode == "MATRIX" ) {
		loadExternalPage();
	} else {
		loadPage();
	}

	$(window).on("resize",function(){
		var form = forms.get( currentBizFormId );
		if( form != undefined ) {
			form.resizeComponent();
		}
	});

	/*메뉴에 사용할 데이터를 모두 인출해 온다.*/
	function loadPage() {
		var bizFormId = uuid();
		var menuItem = { systemCode : '<c:out value="${systemCode}"/>' , name : '<c:out value="${menuName}"/>',  programId : '<c:out value="${programId}"/>', menuId : '<c:out value="${menuId}"/>' };
		menuItems.put( bizFormId, menuItem );
		if($.trim('<c:out value="${param.screenTitle}"/>') != '') {
			$("._pageTitle").text( $.trim('<c:out value="${param.screenTitle}"/>') );
		} else {
			$("._pageTitle").text( menuItem.name );
		}

		//contents 아래 ._content 에  id 를 부여한다.
		$(contentWrapper).attr( "data-id", bizFormId );
		$(content).attr( "id", bizFormId );

		//contentWrapper 에 stack 을 추가해서 자식 폼이 추가 되는 여부를 관리한다.
		var stack = new Map();
		stack.put( menuItem["menuId"],  { id : bizFormId , name : menuItem["name"] } );
		contentWrapper.data("stack", stack );

		var pageUrl = SERVER_URL + "/" + menuItem.systemCode.toLowerCase() + "/service/<c:out value="${param.menuId}"/>?time=" + ( new Date() ).getTime() ;

		//현재 탭이 보이든 안보이든 간에, 내용물은 먼저 가지고 와서 초기화 해야 한다.
		$(contents).find("#"+ bizFormId ).data("URL", pageUrl );

		Param["bizFormId"] = bizFormId;
		Param["container"] = "Y";
		$(contents).find("#"+ bizFormId ).load(pageUrl , Param , function(responseText, statusText, xhr) {
			if( xhr.status != "200" ) {
				// 정상적으로 로딩이 되지 않더라도, 화면에 탭이 추가 되기 때문에, addForm 은 해 주어야 한다.
				LayoutManager.addForm( bizFormId, null );
				$(contents).find("#"+ bizFormId ).append("<div class='_contentNotFound'><i class='fonti um-exclamation-circle'></i><div style='font-size : 20px;text-align:center;' >Page not found <br> 페이지가 없습니다.</div></div>");
				//$(contents).find("#"+ bizFormId ).append("<div class='_contentNotFound'><i class='fa fa-exclamation-triangle errorMark' aria-hidden='true'></i><div style='height:56px;font-size:20px;text-align:center;line-height:28px;'>Page not found<br/>페이지가 없습니다.</div></div>");
			}

			$(contents).find("._content#" + bizFormId).show().siblings().hide();
			$(contents).find("._content#" + bizFormId).find("._contentLoader").remove();
			
			/*페이지가 로딩된 직후, 서버로 부터 전달 받은 헤더 정보가 있을 때, 이것을 페이지에 적용한다. */
			if( nvl( xhr.getResponseHeader('securityCode') ) != "" ) {
				LayoutManager.setSecurityCode( xhr.getResponseHeader('securityCode') );
			}

			currentBizFormId = bizFormId;
			trace("URL Loaded : " + pageUrl );
			$(this).data("URL", pageUrl );
		});
	}

	
	/*메뉴에 사용할 데이터를 모두 인출해 온다.*/
	function loadExternalPage() {
		
        $("main ._contentWrapper").css( {"overflow" :"hidden"} );
		$("._globalStatusBar").css( {"display" :"none"} );
		$("main ._contents ").css( {"bottom" :"5px"} );
		
		var bizFormId = uuid();
		var menuItem = { systemCode : '<c:out value="${systemCode}"/>' , name : '<c:out value="${menuName}"/>',  programId : '<c:out value="${programId}"/>', menuId : '<c:out value="${menuId}"/>' };
		menuItems.put( bizFormId, menuItem );
		if($.trim('<c:out value="${param.screenTitle}"/>') != '') {
			$("._pageTitle").text( $.trim('<c:out value="${param.screenTitle}"/>') );
		} else {
			$("._pageTitle").text( menuItem.name );
		}

		//contents 아래 ._content 에  id 를 부여한다.
		$(contentWrapper).attr( "data-id", bizFormId );
		$(content).attr( "id", bizFormId ).append("<iframe name='_externalFrame' class='externalFrame' style='width:100%;height:100%;' scrolling='auto' frameBorder='0' src='about:blank'></iframe>");
		
		Param["bizFormId"] = bizFormId;
		Param["container"] = "Y";
		
		var form = $('<form action="action" method="post" target="_externalFrame">');
		$.each(Param, function( key , value ){
			form.append( "<input name='" + key + "' type='hidden' value='" + value + "' />" );
		});
		
		if( SYSTEM_ENV != "prod") {
		    form.append( "<input name='ssoId' type='hidden' value='" + SESSION_USER.ssoId + "' />" );
		}
		
		$("body").append( form );
		
		transaction("lgcom", "common/uiCommon/checkValidBiMatrixMenuId", {menuId : '<c:out value="${menuId}"/>' }, function(data){
			menuItem = data["result"];
			
			form.append( "<input name='uid' value='matrix' />" );
			form.append( "<input name='id' value='" + menuItem["linkUrlAddr"] + "' />" );
			
			var pageUrl = SERVER_URL + "/lgbmx/extention/portal/jsp/sso/sso_login.jsp";
			form.attr("action", pageUrl );
            form.submit();
		}); 
	}	
	
	
	function closeTab( item ) {
		var id = $(item).data("id");
		//_contentWrapper 에 자식 form 이 있다면, 이것들도 form 을 삭제해야 한다.
		var stack = $("main div._contentWrapper").data("stack");
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
				trace( "[container] Stack size key : " + stack.get( this )["id"]  );
				LayoutManager.removeForm( stack.get( this )["id"] );
			});
			stack.clear();
			stack = null;
		}

		//현재 화면에 첨부된 모든 DataAPI 를 제거한다.
		$( "div[data-id='"+ id +"']._contentWrapper, div[data-id='"+ id +"']._contentWrapper *").removeData();

		//모든 탭 화면에 포함된 multiselect 를 제거한다.
		//$( "div#" + id + " select[multiselect]").multiselect("destroy");

		//현재 화면에 뜬 모든 툴팁을 해제한다.
		$("[data-toggle='tooltip']").tooltip('destroy');
		$(".tooltip").remove();

		//$("._contentWrapper[data-id='"+id+"']").find("iframe").attr("srcdoc", "<div></div>").empty().remove();
		$("._contentWrapper[data-id='"+id+"']").find("iframe").attr("src", "about:blank").empty().remove();
		$("._contentWrapper[data-id='"+id+"']").empty().remove();

		//현재 화면에 뜬 모든 pastable plate 를 지운다.
		$("._pasteContent").hide();

		//현재 화면의 모든 jsTree 를 제거한다.
		$("div[data-id='"+ id +"']._contentWrapper .jstree:jstree").jstree("destroy");
	}

	LayoutManager.closeTab = function( bizFormId ) {
		var item = $("div._contentWrapper[data-id='"+bizFormId+"']");
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
			forms.remove(formId );
			//폼이 없어지는 순간에, 해당 폼에서 추가한 이벤트 핸들러를 모두 제거처리한다. BizForm 에서 추가해두었던 namespace 기준으로 처리함
			$("#" + formId ).off("." + formId );
		}

		//DOM에 생성된 달력을 삭제 한다.
		$("#"+ formId).find("._datePicker").each( function() {
			var datePicker = $(this).data('dateRangePicker');
			if( typeof datePicker == "object" ) {
				$(this).data('dateRangePicker').destroy();
			}
		});

		// Window 에서 함수 객체 선언부 자체를 를 삭제하는 부분
		try {
			var menuItem = menuItems.get( formId );
			if( typeof window[ menuItem["programId"] ] == "function") {
				window[menuItem["programId"]].prototype = null;  //상속관계에 있는 무
				trace("program prototype removed : " + formId );
				window[ menuItem["programId"] ] = undefined;
				delete  window[ menuItem["programId"] ];
				trace("[SYSTEM] Form function deleted. [programId] : " + formId );
			} else {
				window[ formId ].prototype = null;
				trace("formId prototype removed : " + formId );

				window[ formId ] = undefined;
				delete  window[ formId ];
				trace("[SYSTEM] Form function deleted. [formId] : " + formId );
			}
		} catch( e ) {
			trace(e);
		}
	}


	LayoutManager.getForm = function( formId ) {
		return forms.get( formId );
	}

	LayoutManager.getPopups = function() {
		return  popups;
	}

	LayoutManager.addPopup = function( caller, callee ) {
		popups.put(callee , caller );
		popupStack.push( callee );
		trace("[SYSTEM] New Popup " + callee + " added.  count ( by popup form ): " + popups.size() + " Stack count : " + popupStack.length );
	}

	LayoutManager.removePopup = function( callee ) {
		popups.remove(callee );
		popupStack.removeByValue( callee );
		trace("[SYSTEM] Popup " + callee + " removed.  count ( by popup form ): " + popups.size() + " Stack count : " + popupStack.length );
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

	LayoutManager.toggleIframeOnActiveTab = function( flag ) {
		trace("toggleIframeOnActiveTab");
		if( flag ) {
			$("main div[id='"+ currentBizFormId +"']._content  iframe.externalFrame").show();
			$("#_div_global_background_").hide();
		} else {
			$("main div[id='"+ currentBizFormId +"']._content  iframe.externalFrame").hide();
		}
	}
		
	var securityCode = "<%=request.getAttribute("securityCode")%>";
	LayoutManager.setSecurityCode = function( code ){
		securityCode = code;
	}
	
	LayoutManager.getSecurityCode = function( code ){
		return securityCode;
	}

	
	//Session time out 시간을 update 하는 부분
	setInterval(function() {
		$("._globalStatusBar ._sessionTimeRemain").text( humanReadable( SESSION_INTERVAL ) );
		SESSION_INTERVAL--;
	}, 1000);

	LayoutManager.initSessionTimeout = function() {
		SESSION_INTERVAL = <%= session.getMaxInactiveInterval() %>;
	}

	function humanReadable(seconds) {
		var pad = function(x) { return (x < 10) ? "0"+x : x; }
		return pad(parseInt(seconds / (60*60))) + ":" +
		       pad(parseInt(seconds / 60 % 60)) + ":" +
		       pad(seconds % 60)
	}
}

SystemDateSupport = function(){
	this.current = moment( "<%=request.getAttribute("serverTime")%>", "YYYYMMDD HH:mm:ss" );
	var timer = setInterval( refreshTime, 1000);
	function refreshTime(){
		this.current = moment( this.current ).add(1, 'seconds');
	}
}

SystemDateSupport.getTime = function(){
	return this.current;
}

SystemDateSupport.setServerTime = function( serverTime ){
	this.current = moment( serverTime, "YYYYMMDD HH:mm:ss" );
}

<%@ include file="/WEB-INF/views/framework/commonMessage.jsp" %>
</script>
</body>
</html>
