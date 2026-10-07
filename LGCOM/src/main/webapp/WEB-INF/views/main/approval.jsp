<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%---------------------------------------------------------
    파일명 : loginForm.jsp
    프로젝트명 : LGD WCFW 프로젝트

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 통합결재 승인 화면
    작성자 : WCFW
-------------------------------------------------------------%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta http-equiv="x-ua-compatible" content="IE=edge">
<title>Approval</title>
<%@ include file="/WEB-INF/views/framework/header.jsp" %>
<script src="<%=request.getContextPath()%>/static/ext/jquery-multidownload.js"></script>
<script>
if(SYSTEM_ENV == 'local' && Param.debug != 'Y') {
	window.onerror = function( errorMsg, url, lineNumber ){
		Message.alert("<lgcom:message code="error.systemError"/>" + "<br> Error : " + errorMsg );
		return true;
	};
}

$(window).on("unload", function(){
	$(document).off(".approval");
});

</script>

<script>
<%@ include file="/WEB-INF/views/framework/profile.jsp" %>
</script>

<style>	
._approvalMain > .attachment ,
._approvalMain > .reviewInformation,
._approvalMain > .forward ,
._approvalMain > .reviewer {
	display : none;
}

._approvalMain {
	position : absolute;
	top : 0px;
	left : 0px;
	right :0px;
	width : auto;
	bottom : 0px;
	overflow : auto;
	padding : 20px 10px 0px 10px;
}

._approvalMain .table td {
	padding : 4px !important;
}

._approvalMain  > div {
	float : left;
	width : 100%;
}

._approvalMain .sub-header h4 {
	font-size : 14px;
}

._approvalMain ._pageTitle {
	margin : 5px 0px;
	padding-bottom : 5px;
	border-bottom : 2px solid #C8C8C8;
}

._approvalMain ._contents {
	position: relative !important;
	top : auto !important;
	left : auto !important;
	bottom : 0px;
	right : auto !important;
	height : 400px;
	width : 100%;
	min-height : auto;
	overflow : auto;
	border-top : 0px;
	z-index : initial;
}   

._approvalControls  button {
    margin-left: 5px !important;
}  

._approvalControls button:first-child {
    margin-left: 0px !important;
}  

._approvalMain .btn-file .btn {
	width : 130px;
}

._approvalMain ._contentWrapper {
	top : 0px;
	bottom : 0px;
	left : 0px;
	right : 0px;
	z-index : initial;
}

._approvalControls._top {
	position:absolute;
	top: 5px;
	right: 10px;
	margin : 0px;
	z-index : 100;
}

._approvalControls._bottom {
	margin-top : 10px;
	margin-bottom : 10px;
}

._approvalMain .multi-attatch .file-list li .checkbox-wrap {
	padding : 0px 5px;
}

._approvalMain ._commentWindowBack {
	background-color : black;
	opacity : 0.3;
	position : fixed;
	top:0px;
	bottom : 0px;
	rifht : 0px;
	left : 0px;
	z-index : 500;
	display :none;
}

._approvalMain  ._commentWindow  {
	width : 493px;
	height : 156px;
	position : fixed;
	top : 100px;
	left : calc( 50% - 246px);
	overflow : hidden;
	box-shadow: 2px 2px 4px rgba(0,0,0,.5);
	z-index : 510;
	border: 0px solid transparent;
	display:none;
}

._approvalMain  ._commentWindow .panel-heading {
	padding : 5px 10px;
	cursor : move;
	background-color : #474751;
	color : #FFFFFF;
}

._approvalMain  ._commentWindow .panel-footer {
	padding : 5px 10px;
	background-color : #FFFFFF;
}

._approvalMain  ._commentWindow .panel-footer .btn {
	width : 50px;
}

._approvalMain  ._commentWindow .panel-heading h3 {
	font-size : 12px;
	font-weight : bold;
}

._approvalMain  ._commentWindow .panel-body {
	padding : 5px 5px 1px 5px;
}

._approvalMain  ._commentWindow  ._comment {
	width : 480px;
	height : 84px;
	resize: none;
}

.configButton {
	display : none;
}

._requestInformation pre {
	border : 0px;
	background-color : #FFFFFF;
	padding : 0px;
	font-size : 12px;
	color : #333;
	margin : 0px;
	font-family : '맑은 고딕', 'Malgun Gothic', dotum, '돋움', Arial;
}

._globalStatusBar {
	display: none;
}

._remark , ._requestComment {
	display: none;
}

.attachmentList ._fileName {
	cursor : poointer;
}
</style>
</head>

<body class="main <%= request.getAttribute("USE_SMALL_LAYOUT") %>">
<main class="_approvalMain">
	<h2 class="_pageTitle" style="display:none;"><lgcom:message code="ApprovalRequest" /></h2>
	
	<div class="_approvalControls _top module-group text-right" >
		<div class="btn-toolbar">
		    <div class="btn-group general"></div>
		    <div class="btn-group approve"></div>
		</div>
	</div>

	<div class="_approvalPanel">
		<div class="sub-header">
			<h4><lgcom:message code="RequestInformation" /></h4>
		</div>

		<div>
			<form class="_requestInformation">
				<table class="table table-condensed" summary="Request Information">
					<colgroup>
						<col width="80" />
						<col width="200"/>
						<col width="80" />
						<col width="200"/>
						<col width="80" />
						<col width="250"/>
						<col width="80" />
						<col width="*"  />
					</colgroup>
					<tbody>
						<tr>
							<th scope="row"><label><lgcom:message code="ApprovalRequestTitle" /></label></th>
							<td colspan="7"><span name="requestTitle"></span></td>
						</tr>
						<tr>
							<th scope="row"><label><lgcom:message code="ApprovalRequestNo" /></label></th>
							<td><span name="requestNo"></span></td>
							<th scope="row"><label><lgcom:message code="ApprovalRequestor" /></label></th>
							<td><span name="requestor"></span></td>
							<th scope="row"><label><lgcom:message code="ApprovalRequestStatus" /></label></th>
							<td><span name="requestStatus"></span></td>
							<th scope="row"><label><lgcom:message code="ApprovalRequestDate" /></label></th>
							<td><span name="requestDate"></span></td>
						</tr>
						<tr class="_requestComment">
							<th scope="row"><label ><lgcom:message code="ApprovalRequestComment" /></label></th>
							<td colspan="7"><pre name="requestComment"></pre></td>
						</tr>
						<tr class="_remark">
							<th scope="row"><label><lgcom:message code="ApprovalRequestRemark" /></label></th>
							<td colspan="7"><pre name="requestRemark"></pre></td>
						</tr>
					</tbody>
				</table>
			</form>
			<!-- /table -->
		</div>
	</div>

	<!-- 상세 정보 : 업무 화면이 위치하는 부분  -->
	<div class="sub-header">
		<h4><lgcom:message code="ApprovalDetailInformation" /></h4>
	</div>
	<div class="_contents"></div>

	<!-- 첨부파일 : 요청의 첨부파일 목록이 위치하는 부분   -->
	<div class="sub-header attachment">
		<h4><lgcom:message code="ApprovalAttachment" /></h4>
	</div>
	<table class="table table-condensed multi-attatch attachment" summary="File Attachment">
		<colgroup>
			<col width="80" />
			<col width="*"  />
			<col width="150"/>
		</colgroup>
		<tbody>
			<tr>
				<th scope="row"><lgcom:message code="ApprovalAttachmentFile" /></th>
				<td style="vertical-align: top">
					<ul class="file-list _attachmentList"></ul>
				</td>
				<td style="vertical-align : top;">
					<p class="btn-file" ><button type="button" class="btn btn-default btn-sm" data-action="downloadChecked" ><lgcom:message code="ApprovalFileDownChecked" /></button></p>
					<p class="btn-file" style="margin-bottom:0px;"><button type="button" class="btn btn-default btn-sm" data-action="downloadAll" ><lgcom:message code="ApprovalFileDownAll" /></button></p>
				</td>
			</tr>
		</tbody>
	</table>

	<!-- 승인자 정보  -->
	<div class="sub-header">
		<h4><lgcom:message code="ApprovalInformation" /></h4>
	</div>
	<div class="grid-wrap">
		<table class="table table-condensed table-bordered" summary="Approval Information">
			<caption class="sr-only">Approval Information</caption>
			<colgroup>
				<col width="50" />
				<col width="150"/>
				<col width="180"/>
				<col width="180"/>
				<col width="120"/>
				<col width="130"/>
				<col width="*"  />
			</colgroup>
			<thead>
				<tr>
					<th scope="col"><lgcom:message code="ApprovalSeq" /></th>
					<th scope="col"><lgcom:message code="ApprovalType" /></th>
					<th scope="col"><lgcom:message code="ApprovalApprover" /></th>
					<th scope="col"><lgcom:message code="ApprovalMandator" /></th>
					<th scope="col"><lgcom:message code="ApprovalStatus" /></th>
					<th scope="col"><lgcom:message code="ApprovalDate" /></th>
					<th scope="col"><lgcom:message code="ApprovalComment" /></th>
				</tr>
			</thead>
			<tbody class="_approverBody"></tbody>
		</table>
		<!-- /table -->
	</div>

	<!-- 검토자 정보    -->
	<div class="sub-header reviewInformation">
		<h4><lgcom:message code="ReviewInformation" /></h4>
	</div>
	<div class="grid-wrap reviewInformation">
		<table class="table table-condensed table-bordered" summary="Review Information">
			<caption class="sr-only">Review Information</caption>
			<colgroup>
				<col width="100"/>
				<col width="120"/>
				<col width="*"  />
				<col width="120"/>
				<col width="*"  />
			</colgroup>
			<thead>
				<tr>
					<th scope="col">Type</th>
					<th scope="col">Approver</th>
					<th scope="col">Comment</th>
					<th scope="col">Reviewer</th>
					<th scope="col">Comment</th>
				</tr>
			</thead>
			<tbody class="_inspectionBody"></tbody>
		</table>
		<!-- /table -->
	</div>

	<!-- 참조자 정보  -->
	<div class="sub-header carbonCopy">
		<h4><lgcom:message code="Referrers" /></h4>
	</div>
	<div class="grid-wrap carbonCopy">
		<table class="table table-condensed table-bordered" summary="Carbon Copy To">
			<colgroup>
				<col width="100"/>
				<col width="360"/>
				<col width="*"  />
			</colgroup>
			<thead>
				<tr>
					<th scope="col">No.</th>
					<th scope="col">Name</th>
					<th scope="col">Date</th>
				</tr>
			</thead>
			<tbody class="_carbonCopyBody"></tbody>
		</table>
		<!-- /table -->
	</div>

	<!-- 전달 정보  -->
	<div class="sub-header forward">
		<h4><lgcom:message code="Forward" /></h4>
	</div>
	<div class="grid-wrap forward">
		<table class="table table-condensed table-bordered" summary="Carbon Copy To">
			<colgroup>
				<col width="100"/>
				<col width="360"/>
				<col width="*"  />
			</colgroup>
			<thead>
				<tr>
					<th scope="col">No.</th>
					<th scope="col">Name</th>
					<th scope="col">Date</th>
				</tr>
			</thead>
			<tbody class="_forwardBody"></tbody>
		</table>
		<!-- /table -->
	</div>

	<!-- 검토자 지정 정보 정보  -->
	<div class="sub-header reviewer">
		<h4><lgcom:message code="Reviewer" /></h4>
	</div>
	<div class="grid-wrap reviewer">
		<table class="table table-condensed table-bordered" summary="Carbon Copy To">
			<colgroup>
				<col width="50%"/>
				<col width="50%"/>
			</colgroup>
			<thead>
				<tr>
					<th scope="col"><lgcom:message code="ReviewRequestContent" /></th>
					<th scope="col"><lgcom:message code="PrereviewComment" /></th>
				</tr>
			</thead>
			<tbody class="_reviewerBody"></tbody>
		</table>
		<!-- /table -->
	</div>

	<div class="gridControls _approvalControls _bottom text-right"></div>
	<div style="height:1px;"></div>

	<!-- Comment 입력 부분 -->
	<div class="_commentWindowBack"></div>
	<div class="panel panel-default _commentWindow" role="dialog" >
		<div class="panel-heading">
			<h3 class="panel-title"><span class="actionName"></span> Comment</h3>
		</div>
		<div class="panel-body">
			<textarea class="_comment input-require form-control input-sm"></textarea>
		</div>
		<div class="panel-footer">
			<div class="gridControls" style="margin:0px;">
				<button class="btn btn-darkgray btn-xs" data-action="ok" >Ok</button>
				<button class="btn btn-gray btn-xs"  data-action="cancel">Cancel</button>
			</div>
		</div>
	</div>

</main>
<div class="_globalStatusBar"><span class="_message"></span></div>
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

	$(document).data( "LAYOUT_MANAGER",layout  );

	( new SystemDateSupport() ).setServerTime( "<%=request.getAttribute("serverTime")%>" );

	var approval = new Approval();
	approval.getApprovalData();

	$(document).data( "APPROVAL",approval  );
});

function _approvalButtonControl( type, showFlag ) {
	$("._approvalControls button[data-type='"+type+"']" ).hide();
	if( showFlag ) {
		$("._approvalControls button[data-type='"+type+"']" ).show();
	}
}

function _refreshApprovalInfo() {
	var approval = $(document).data( "APPROVAL");
	approval.getApprovalData();
}

function _approvalCallback( action, status, message ) {
	//승인 버튼 구역의 모든 버튼을 다시 활성화 한다
	$("._approvalControls button" ).removeAttr("disabled");

	var type = $(document).data("approvalType");
	var approval = $(document).data( "APPROVAL");

	switch( type ) {
		case "APPROVAL" :
			if( status ) { // 승인 정상 처리
				Message.notify("Approved successfully.");
				$("._approvalControls [data-type='APPROVAL'], ._approvalControls [data-type='REJECT']").hide();
			} else { // 승인 오류 처리
				Message.notify("[Error] Errors in approval processing.");
			}

			//$("._commentWindow").modal("hide");
			hideCommentWindow();

			if( approval != undefined ) {
				approval.getApprovalData();
			}
			break;
		case "REJECT" :
			if( status ) { // 반려 정상 처리
				Message.notify("Rejected.");
				$("._approvalControls [data-type='APPROVAL'], ._approvalControls [data-type='REJECT']").hide();
			} else { // 승인 오류 처리
				Message.notify("[Error] Errors in rejection processing.");
			}

			//$("._commentWindow").modal("hide");
			hideCommentWindow();

			if( approval != undefined ) {
				approval.getApprovalData();
			}
			break;
	}

	switch( action ) {
		case "selfReject" :
			if( status ) {
				Message.notify("Completed.");
				$("._approvalControls button").hide();
				window.close();
			}
			break;
	}
}

function _resizeDetailArea( height ) {
	$("._contents").css( { height : height, "overflow-y" : "hidden" } );
	$("._contents ._contentWrapper").css( { "overflow-y" : "hidden" } );
}

LayoutManager = function( mode ) {
	var _this = this;
	var animationDuration = 250;

	//외부 파라미터
	var jobKeyId = '<c:out value="${param.jobKeyId}"/>';

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

	this.loadApprovalPage = function( menuItem ) {
		loadPage( menuItem );
	}

	/*메뉴에 사용할 데이터를 모두 인출해 온다.*/
	function loadPage( menuItem ) {
		var contents = $("main div._contents");
		var bizFormId = uuid();
		menuItems.put( bizFormId, menuItem );

		//$(contents).find('._contentWrapper').hide();
		// 기존에 로딩된 내역이 존재하면 삭제한다. 2017.03.10 forain 추가
		$(contents).find('._contentWrapper').remove();

		//$("._pageTitle").text( menuItem.name );
		var contentWrapper = $( "<div class='_contentWrapper' data-id='"+bizFormId+"' ><div class='_content' id='"+ bizFormId +"' data-menuId='"+ menuItem.menuId +"'><div class='spinner _loader'><span>Loading...</span></div></div></div>" );
		$(contents).append( contentWrapper );

		var content = contentWrapper.find("._content#" + bizFormId );

		//contentWrapper 에 stack 을 추가해서 자식 폼이 추가 되는 여부를 관리한다.
		var stack = new Map();
		stack.put( menuItem.menuId, bizFormId );
		contentWrapper.data("stack", stack );
		content.find("._loader").show();

		var pageUrl = SERVER_URL + "/" + menuItem.systemCode.toLowerCase() + "/service/M_LGUTLC_1162?approvalForward="+ menuItem.menuId;

		Param["bizFormId"] = bizFormId;
		Param["jobKeyId"] = jobKeyId;
		Param["approval"] = "Y";

		//현재 탭이 보이든 안보이든 간에, 내용물은 먼저 가지고 와서 초기화 해야 한다.
		$( content ).load(pageUrl , Param , function(responseText, statusText, xhr) {
			$(content).find("._loader").remove();
			if( xhr.status != "200" ) {
				// 정상적으로 로딩이 되지 않더라도, 화면에 탭이 추가 되기 때문에, addForm 은 해 주어야 한다.
				LayoutManager.addForm( bizFormId, null );
				$( content ).append("<div class='_contentNotFound'><i class='fa fa-exclamation-triangle errorMark' aria-hidden='true'></i><div style='height:56px;font-size:20px;text-align:center;line-height:28px;'>Page not found<br/>페이지가 없습니다.</div></div>");
			} else {
				currentBizFormId = bizFormId;
				trace("URL Loaded : " + pageUrl );
				$(this).data("URL", pageUrl );
				
				/*페이지가 로딩된 직후, 서버로 부터 전달 받은 헤더 정보가 있을 때, 이것을 페이지에 적용한다. */
				if( nvl( xhr.getResponseHeader('securityCode') ) != "" ) {
					LayoutManager.setSecurityCode( xhr.getResponseHeader('securityCode') );
				}
				
				buildApprovalPannel();
			}
		});
	}

	var approval;

	$(document).on("click.approval", "._approvalControls button[data-action]", function(event){
		//이 버튼에 개발자가 적은
		var action = $(event.target).data("action");
		var type = $(event.target).data("type");

		switch(type){
			case "APPROVAL":
				$("._commentWindow").data("action", action);
				$("._commentWindow").data("type", type);
				$("._commentWindow .actionName").text("Approval");
				$("._commentWindow ._comment").val("");
				//$("._commentWindow").modal("show");
				showCommentWindow();
				break;
			case "REJECT":
				$("._commentWindow").data("action", action);
				$("._commentWindow").data("type", type);
				$("._commentWindow .actionName").text("Reject");
				$("._commentWindow ._comment").val("");
				//$("._commentWindow").modal("show");
				showCommentWindow();
				break;
			default :
				var inspectionInfo = $(document).data("APPROVER_LIST");
				try {
					approval.callback.call( this, action, inspectionInfo );
				} catch(e){
					trace( e );
				}
				break;
		}
	});

	$(document).on( "click.approval", "._commentWindow [data-action]", function( event ){
		trace("( ._commentWindow button[data-action] ) clicked !!! ");
		var item = $(event.target);

		switch( $(item).data("action") ){
			case "ok":
				//이 버튼 자체를 Disable 처리 한다.
				$(item).prop("disabled", true);

				//승인 버튼 구역의 모든 버튼을 잠금 처리한다.
				$("._approvalControls button" ).prop("disabled", true);

				var action = $("._commentWindow").data("action");
				var type = $("._commentWindow").data("type");
				var comment = $("._commentWindow ._comment").val();

				//승인 타입을 글로벌에 저장한다.
				$(document).data("approvalType", type );

				//comment 에 입력한 내용이 없을 때에는 자동으로 지정된 메세지를 추가한다.
				if( comment == "" ) {
					if( type == 'APPROVAL') {
						comment = "OK";
					} else if( type == 'REJECT') {
						comment = "Rejected";
					}
					$("._commentWindow ._comment").val( comment );
				}

				invokeCallback( action, type , comment );
				$(item).removeAttr("disabled");

				hideCommentWindow();
				$("._approvalControls button" ).removeAttr("disabled");
				break;
			case "cancel":
				//$("._commentWindow").modal("hide");
				hideCommentWindow();
				break;
		}
	});

	$("._commentWindow").on('show.bs.modal', function (e) {
		setTimeout( function(){
			$("._approvalMain  ._commentWindow  ._comment").focus();
		}, 500 );
	});

	$('#myModal').on('show.bs.modal', function (e) {
		$('body').on('scroll touchmove mousewheel', function(e) {
			e.preventDefault();
			e.stopPropagation();
			return false;
		});
	});

	$('#myModal').on('hidden.bs.modal', function (e) {
		$('body').off('scroll touchmove mousewheel');
	});

	function buildApprovalPannel() {
		$("main ._approvalControls").find(".btn-group").empty();

		var form = forms.get(currentBizFormId);
		if( form == undefined ) {
			return;
		}

		approval = form.getApprovalInfo();

		try {
			approval.init.call( this , {} );
		} catch(e){}

		if( approval == undefined ) {
			return;
		}
		//Approval 패널을 화면에 표출하고, ._contents 패널의 높이를 재조정한다.
		$("main ._contents").css("top", "65px");
		$("main ._approvalPanel").show();

		//미리 저장된 승인자 목록을 꺼내서, 버튼의 visiblity 를 결정한다.
		var approverList = $(document).data("APPROVER_LIST");
		var approvalInfo =  $(document).data("APPROVAL_INFO");
		//approval 정보를 가공하여, 화면에 버튼을 표현한다.
		$(approval.buttons).each( function(){
			var button = this;

			//(개선) 승인 / 기각 버튼이 아니면 
			if( ["APPROVAL", "REJECT", "APPROVAL_DETAIL", "SELF_REJECT" ].indexOf( button["type"] ) < 0 ) {
				var buttonObj = $('<button type="button" class="btn btn-default btn-sm" data-action="'+ button["action"]+'" data-type="'+ button["type"] +'" >'+ button["text"]+'</button>\n');
				if($.trim(button['visible']) == 'false' || $.trim(button['visible']) == 'N') {
					$(buttonObj).hide();
				}
				$("main ._approvalControls").find(".btn-group.general").append( buttonObj );
			} else {
				switch( button["type"] ) {
					case "SELF_REJECT" :
						//요청자가 이 화면을 열었을때
						if( SESSION_USER.applicationUserId == approvalInfo["requestorId"] && approvalInfo["requestStatusCode"] == "20" ) {
							trace("self reject show");
							var buttonObj = $('<button type="button" class="btn btn-gray btn-sm" data-action="'+ button["action"]+'" data-type="'+ button["type"] +'" >'+ button["text"]+'</button>\n');
							if($.trim(button['visible']) == 'false' || $.trim(button['visible']) == 'N') {
								$(buttonObj).hide();
							}
							$("main ._approvalControls").find(".btn-group.approve").prepend( buttonObj);
						}
						break;
					default :
						//(개선) 승인 / 기각 버튼 인 경우에는, 승인자와 위임자 모두가 관련 있다.
						var approverData = [];
						$(approverList).each( function() {
							var userNo = this["userNo"];

							if( SESSION_USER.userName == userNo && this["approvalStatusCode"] == "2" ) {
								/**
								 * 2017.06.29. forain, 수정
								 * 결재선에 동일인이 설정되었을 경우 버튼이 1회이상씩 표시되는 문제를 수정
								 * 결재선에서 Seq 가 먼저인 버튼이 보여진다면 종료한다.
								 */
								if(approverData.indexOf(userNo) != -1) {
									return true;
								}
								var buttonObj = $('<button type="button" class="btn btn-darkgray btn-sm" data-action="'+ button["action"]+'" data-type="'+ button["type"] +'" >'+ button["text"]+'</button>\n');
								if($.trim(button['visible']) == 'false' || $.trim(button['visible']) == 'N') {
									$(buttonObj).hide();
								}
								$("main ._approvalControls").find(".btn-group.approve").append( buttonObj );
								approverData.push(userNo);
							}
						});
						break;
				}
			}
		});

		try {
			approval.loadCompleted.call(this);
		} catch(e){}
	}

	function invokeCallback( action, type , comment ) {
		try{
			switch(type){
				case "APPROVAL":
					approval.callback.call( this, action, { comment  : comment });
					break;
				case "REJECT":
					approval.callback.call( this, action, { comment  : comment } );
					break;
			}
		} catch( e ) { }
	}

	LayoutManager.addForm = function( formId, formObject ) {
		forms.put(formId , formObject );
		trace("[SYSTEM] New Form " + formId + " added.  count : " + forms.size() );
	}

	LayoutManager.removeForm = function( formId ) {
		//form 객체를 초기화 한다.
		if( forms.get( formId ) != undefined ) {
			forms.get( formId ).destroy();
			forms.remove(formId );

			//폼이 없어지는 순간에, 해당 폼에서 추가한 이벤트 핸들러를 모두 제거처리한다. BizForm 에서 추가해두었던 namespace 기준으로 처리함
			$(document).off("." + formId );
		}
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
		return popupStack.length;
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

SystemDateSupport = function() {
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

		$("main ._globalStatusBar ._currentTime").text( moment( current ).format("YYYY-MM-DD HH:mm:ss") + " (GMT "+ gmtText +")" );
	}

	this.setServerTime = function( serverTimeText ) {
		current = moment( serverTimeText, "YYYYMMDD HH:mm:ss");
	}

	this.getTime = function(){
		return current;
	}

	SystemDateSupport.getTime = function() {
		return current;
	}

	SystemDateSupport.setServerTime = function(serverTimeText) {
		this.setServerTime(  serverTimeText ) ;
	}

	$("aside ._menu ._currentTime").click( function(){
		trace(  moment( _this.getTime() ).format("YYYY-MM-DD HH:mm:ss")   );
	});
}

Approval = function() {
	var layout = $(document).data( "LAYOUT_MANAGER" );
	//외부 파라미터
	var jobKeyId = '<c:out value="${param.jobKeyId}"/>';
	var jobRequestCode = '<c:out value="${param.jobRequestCode}"/>';

	var attacmentDownloadSource = "LGCOM";

	$("._commentWindow").draggable();

	this.getApprovalData = function() {
		getRequestInfoList();
	}

	function getRequestInfoList() {
		$(document).data("APPROVAL_INFO", null);
		$(document).data("APPROVER_LIST", null);

		var param = { requestMasterId : jobKeyId , requestCode : jobRequestCode };

		$("._requestInformation [name]").text( "" );
		$("._approverBody, ._attachmentList, ._inspectionBody, ._carbonCopyBody, ._forwardBody, ._reviewerBody").empty();

		transaction("lgcom", "common/approval/retrieveRequestInfoList", param, function(data){
			var result = data["result"];
			if( result == undefined || result.requestInfo == undefined ) {
				Message.alert("<lgcom:message code="error.unrequestedApproval" />");
				return;
			}

			// 단일 레코드 여러 항
			$( result.requestInfo ).each( function( inx ){
				var item = this;
				// 비용사전 품의서의 경우, 이전 데이터가 Conversion 이 된 것이면, 첨부파일 다운로드 소스가 변경되어야 한다.
				if( item["requestCode"] == "51002" &&  nvl( item["requestCreationCode"] ) == "CONVERSION" ) {
					attacmentDownloadSource = "HRM";
				}

				// 업무적으로 레코드가 한 줄 밖에 나오지 않는다.
				$.each( item, function( key, value ){
					$("._requestInformation [name='"+ key +"']").text( nvl(value) );

					// 비고 항목이 있고 그 값이 있는 경우에 한하여 ._remark 를 보이도록 조치한다.
					if( key == "requestRemark" && nvl(value) != "" ) {
						$("._remark").show();
					}

					if( key == "requestComment" && nvl(value) != "" ) {
						$("._requestComment").show();
					}
				});

				var menuItem = { systemCode : nvl(item["systemCode"]) , name : nvl(item["menuName"]), programId : nvl(item["programId"]) , menuId : nvl(item["menuId"])  };
				layout.loadApprovalPage( menuItem );

				$(document).data("APPROVAL_INFO", item );
			});

			if( result.attachmentList != undefined && result.attachmentList.length > 0 ) {
				var nua = navigator.userAgent;
				if( nua.indexOf('Android') > 0 ) {
					$( result.attachmentList ).each( function( inx ){
						$("._attachmentList").append("<li><div class='checkbox-wrap' style='padding-top:4px;'>"+
													 "<a href='/lgcom/download/common/mobile?fileId=" + this["fileId"] + "&moduleCode="+attacmentDownloadSource+"' style='text-decoration: underline;'>"+ this["fileName"] +"</a>"+
													 "</div></li>");
					});
					$("table.attachment").find(".btn-file").hide();
				} else {
					$( result.attachmentList ).each( function( inx ){
						$("._attachmentList").append("<li><div class='checkbox-wrap'>"+
						                             "<div class='checkbox checkbox-uxp checkbox-inline'>"+
						                             "<input type='checkbox' id='_file_" + inx +"' data-id='"+ this["fileId"]+"' value='1'/>"+
						                             "<label for='_file_" + inx +"' class='_fileName' data-id='"+ this["fileId"]+"' >"+ this["fileName"] +"</label>"+
						                             "</div></div></li>");
					});
				}
				$(".attachment").show();
			}

			$(document).data("APPROVER_LIST", result.approverList );

			$( result.approverList ).each( function( inx ){
				$("._approverBody").append("<tr data-approvalseq='"+ this["approvalSeqs"] +"'>"+
				                           "<td class='text-center'>"+ (inx+1) +" </td>"+
				                           "<td class='text-center'>"+ nvl(this["approvalActionName"]) +"</td>"+
				                           "<td class='text-center'>"+ nvl(this["approver"])+"</td>"+
				                           "<td class='text-center'>"+ nvl(this["mandator"])+"</td>"+
				                           "<td  class='text-center'>"+ nvl(this["approvalStatusCodeName"]) +"</td>"+
				                           "<td class='text-center'>"+ nvl(this["approvalDate"]) +"</td>"+
				                           "<td><pre>"+ nvl(this["approvalComment"]) +"</pre></td>"+
				                           "</tr>");
			});

			$( result.inspectionList ).each( function(){
				//여러 레코드
				$("._inspectionBody").append("<tr>"+
				                             "<td>"+ nvl(this["type"]) +"</td>"+
				                             "<td class='text-center'>"+ nvl(this["approver"]) +"</td>"+
				                             "<td>"+ nvl(this["approverComment"]) +"</td>"+
				                             "<td class='text-center'>"+ nvl(this["inspector"])+"</td>"+
				                             "<td>"+ nvl(this["inspectionComment"]) +"</td>"+
				                             "</tr>");
			});

			$( result.carbonCopyList ).each( function( inx ){
				//여러 레코드
				$("._carbonCopyBody").append("<tr>"+
				                             "<td class='text-center'>"+ ( inx + 1 ) +"</td>"+
				                             "<td class='text-center'>"+ nvl(this["referEmpName"]) +"</td>"+
				                             "<td class='text-center'>"+ nvl(this["approvalDate"]) +"</td>"+
				                             "</tr>");

				$(".carbonCopy").show();
			});

			$( result.forwardList ).each( function( inx ){
				//여러 레코드
				$("._forwardBody").append("<tr>"+
				                          "<td class='text-center'>"+ ( inx + 1 ) +"</td>"+
				                          "<td class='text-center'>"+ nvl(this["referEmpName"]) +"</td>"+
				                          "<td class='text-center'>"+ nvl(this["approvalDate"]) +"</td>"+
				                          "</tr>");

				$(".forward").show();
			});

			/*
			  approval_seqs
			, approval_action_name
			, TYPE
			, open_flag
			, request_emp_name
			, request_comment
			, request_date
			, review_emp_name
			, review_comment
			, review_date
			, attachment_req_number
			*/
			$( result.reviewerList ).each( function( inx ){
				var list = this["attachFileList"];
				var attachment = "";

				if( list != undefined ) {
					$(list).each( function(  inx ){
						attachment += "<div><a href='/lgcom/download/common/mobile?fileId=" + this["fileId"] + "&moduleCode="+ this["moduleCode"] +"' style='text-decoration: underline;'>"+ this["fileName"] +"</a></div>";
					});
				}

				$("._reviewerBody").append("<tr>"+
				                           "<td class='text-left' style='vertical-align: top;' >"+ this["requestEmpName"] + "<br>" +  nvl(this["requestComment"]) + "<br>" + nvl(this["requestDate"]) + "</td>"+
				                           "<td class='text-left' style='vertical-align: top;' ><div>"+ this["reviewEmpName"] + "<br>" +  nvl(this["reviewComment"]) + "<br>" + nvl(this["reviewDate"]) + "</div>"+ attachment +"</td>"+
				                           "</tr>");

				$(".reviewer").show();
			});
		});
	}

	$(document).on( "click.approval", ".multi-attatch [data-action]", function(event){
		var action = $(event.target).data("action");
		switch( action ) {
			case "downloadChecked" :
				Message.confirm( "<lgcom:message code="question.downloadAttachSelected" />", function() {
					$("._attachmentList input[data-id]:checked").each( function(){
						$("._multipleDownloadArea").empty();
						$("._attachmentList input[data-id]").each( function(){
							var id = $(this).data("id");
							var url = SERVER_URL + "/lgcom/download/common/"+ id + "/" + attacmentDownloadSource;
							$("._multipleDownloadArea").append("<a href='" + url + "'></a>");
						});
						$('._multipleDownloadArea a').multiDownload( {delay : 500 } );
					});
				});
				break;
			case "downloadAll" :
				Message.confirm( "<lgcom:message code="question.downloadAttachAll" />", function() {
					$("._multipleDownloadArea").empty();
					$("._attachmentList input[data-id]").each( function(){
						var id = $(this).data("id");
						var url = SERVER_URL + "/lgcom/download/common/"+ id + "/" + attacmentDownloadSource;
						$("._multipleDownloadArea").append("<a href='" + url + "'></a>");
					});
					$('._multipleDownloadArea a').multiDownload( {delay : 500 } );
				});
				break;
		}
	});

	$(document).on( "click.approval", "._attachmentList ._fileName", function( event ){
		var id = $(event.target).data("id");
		downloadFile( id , attacmentDownloadSource );
	});

	function downloadFile( id, moduleCode ) {
		var downloader = new Downloader( {} , { } );
		downloader.attachment( id , function(){
		}, function(){
			Message.alert( "<lgcom:message code="note.fileDownloadCompleted" />" );
		}, moduleCode );
	}
}

function showCommentWindow() {
	$("._approvalMain ._commentWindow button[action='ok']").removeAttr("disabled");
	$("._approvalMain ._commentWindowBack").show();
	$("._approvalMain ._commentWindow").show();
}

function hideCommentWindow() {
	$("._approvalMain ._commentWindow button[action='ok']").removeAttr("disabled");
	$("._approvalMain ._commentWindowBack").hide();
	$("._approvalMain ._commentWindow").hide();
}
<%@ include file="/WEB-INF/views/framework/commonMessage.jsp" %>
//]]>
</script>
<%@ include file="/WEB-INF/views/main/fileManager.jsp"%>
<%@ include file="/WEB-INF/views/main/excelUploader.jsp"%>
<div class="_multipleDownloadArea" style="display:none;"></div>
</body>
</html>
