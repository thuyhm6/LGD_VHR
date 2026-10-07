<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%---------------------------------------------------------
    파일명 : approvalReqeust.jsp
    프로젝트명 : LGD WCFW 프로젝트

    Copyright(c) 2012 LG CNS,  All rights reserved.

    설 명 : 결재 요청 
    작성자 : wcfw
-------------------------------------------------------------%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta http-equiv="x-ua-compatible" content="IE=edge">
<title>Approval Request</title>
<%@ include file="/WEB-INF/views/framework/header.jsp" %>
<script language="JavaScript">
if( DEBUG_MODE != "Y") {
	window.onerror = function( errorMsg, url, lineNumber ){
		Message.alert("<lgcom:message code="error.systemError"/>" + "<br> Error : " + errorMsg );
		return true;
	};
}

var pageParameter = {};

<%
	StringBuffer sb = new StringBuffer();
	java.util.Enumeration<String> keys = request.getParameterNames();
	while( keys.hasMoreElements() ){
		String key = keys.nextElement();
		out.println( " pageParameter['"+ key +"'] = '" + request.getParameter( key ) + "';" );
	}
%>

</script>
<style>
html , body {
    position : static;
}

main {
    width : auto;
    top : 0px;
    left : 10px;
    right : 10px;
    bottom : 0px;
}

main ._contents {
    border-top : 0px;
    top : 0px;
    bottom : 24px;
    min-height : 200px;
}

main ._pageTitle {
    margin : 0px !important;
    position: absolute;
    top :  5px;
    left : 10px;
}

</style>

</head>

<body>

<main>
    <div class="_wrapper" >
        <div class="_contents">
            <div class=_content></div>
        </div>
        <div class="_globalStatusBar"><span class="_message"></span></div>
    </div>
</main>

<%@ include file="/WEB-INF/views/main/fileManager.jsp"%>

<%@ include file="/WEB-INF/views/main/excelUploader.jsp"%>

<script>
//<![CDATA[
/* Event handler triggered just after page ready. */
$(document).ready( function(){

	//백스페이스를 눌렀을 때에, 이전 페이지로 이동되는 것을 막기 위한 코드
	$(document).on("keydown", function(event){
		if( event.target.nodeName != "INPUT" && event.target.nodeName != "TEXTAREA" ){
            if( event.keyCode === 8 ){
                return false;
            }
        }
	});

	//브라우저 뒤로가기를 막기 위한 코드
	window.history.forward(0);

	var layout = new LayoutManager();
});


LayoutManager = function( mode ) {
    var _this = this;
	var animationDuration = 250;
	var notitle = '<c:out value="${param.notitle}"/>';

	if( notitle == "Y" ) {
		$("._pageTitle").hide();
		$("main ._contents").css("top", "0px");
		$("main").css({ top : "0px", bottom : "0px", left : "0px", right : "0px"});
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


	loadPage();

    /*메뉴에 사용할 데이터를 모두 인출해 온다.*/
    function loadPage() {

    	var bizFormId = uuid();
		var menuItem = { systemCode : "LGPRO" , name : "Request Approval",  programId : "LGPCOMAPORV", menuId : "M_LGPCOM_1014"  };
		menuItems.put( bizFormId, menuItem );

		$("._pageTitle").text( menuItem.name );

		//contents 아래 ._content 에  id 를 부여한다.
		$(contents).find("._content").attr( "id", bizFormId );

		var pageUrl = SERVER_URL + "/" + menuItem.systemCode.toLowerCase() + "/service/"+ menuItem["menuId"] +"?time=" + ( new Date() ).getTime() ;

		//현재 탭이 보이든 안보이든 간에, 내용물은 먼저 가지고 와서 초기화 해야 한다.
		$(contents).find("#"+ bizFormId ).data("URL", pageUrl );

		pageParameter["bizFormId"] = bizFormId;
		$(contents).find("#"+ bizFormId ).load(pageUrl , pageParameter , function(responseText, statusText, xhr) {
			if( xhr.status != "200" ) {
				// 정상적으로 로딩이 되지 않더라도, 화면에 탭이 추가 되기 때문에, addForm 은 해 주어야 한다.
				LayoutManager.addForm( bizFormId, null );
				//$(contents).find("#"+ bizFormId ).append("<div class='_contentNotFound'><i class='fonti um-exclamation-circle'></i><div style='font-size : 20px;text-align:center;' >Page not found <br> 페이지가 없습니다.</div></div>");
				$(contents).find("#"+ bizFormId ).append("<div class='_contentNotFound'><i class='fa fa-exclamation-triangle errorMark' aria-hidden='true'></i><div style='height:56px;font-size:20px;text-align:center;line-height:28px;'>Page not found<br/>페이지가 없습니다.</div></div>");
			}
			$(contents).find("._content#" + bizFormId).show().siblings().hide();
			$(contents).find("._content#" + bizFormId).find("._contentLoader").remove();

			currentBizFormId = bizFormId;
			trace("URL Loaded : " + pageUrl );
			$(this).data("URL", pageUrl );
		});
	}

	LayoutManager.addForm = function( formId, formObject ) {
		forms.put(formId , formObject );
		trace("[SYSTEM] New Form " + formId + " added.  count : " + forms.size() );
	}

	LayoutManager.removeForm = function( formId ) {
		forms.remove( formId );
		//폼이 없어지는 순간에, 해당 폼에서 추가한 이벤트 핸들러를 모두 제거처리한다. BizForm 에서 추가해두었던 namespace 기준으로 처리함
		$(document).off("." + formId );
		trace("[SYSTEM] Form " + formId + " removed.  count : " + forms.size() );
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

    //Session time out 시간을 update 하는 부분
  	setInterval( function(){
    	$("._globalStatusBar ._sessionTimeRemain").text( humanReadable( SESSION_INTERVAL ) );
    	SESSION_INTERVAL--;
   	}, 1000);

    LayoutManager.initSessionTimeout = function(){
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

//]]>
</script>
</body>
</html>
