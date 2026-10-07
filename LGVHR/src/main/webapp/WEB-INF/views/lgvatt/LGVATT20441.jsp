<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"     uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVATT20441.jsp
    프로젝트명 : 베트남 근태 급여 시스템 구축

   Copyright(c) 2017 LG CNS,  All rights reserved..

    설 명 : Long Term Plan 상세조회
    작성자 : bakderia
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Mutiple plan Detail</title>

<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVATT20450 = function() {
	var grid;
	var myForm = this;
	var callType = "${param.callType}";
	var status = "${param.status}";
	var applicationUserId = "${param.applicationUserId}";
	var approvalRequestId = "${param.approvalRequestId}";
	var paramEmployeeNo = "${param.employeeNo}";
	var requestCode = "${param.requestCode}";
	
	// Form Util 선언
	var formUtil = new FormUtil(myForm,'form.detailInfo');
	
	/************************************************************
	 화면 각 구역에 할당돼 있는 Form 에 대해서 Form Util을 선언
	************************************************************/
	var generalInfo  = new FormUtil(myForm, "form.generalInfo");
	
	retrieveMutipleDetailInfo(status);
	retrieveApproverInfo();
	
	//결제처리 버튼제어는 결제화면에서만 컨트롤 가능하게 수정
	if(callType != "DETAIL") {
		fncControllButton();
		myForm.select("#detailSubHeader").hide();
	}
	
	//상세조회
	function retrieveMutipleDetailInfo(status) {
		//결제담당자가 상세화면에서 승인이전 상태일 경우 결제취소 가능하게 처리
		if(status == "20"){
			$(".gridControls [data-type='SELFREJECT']").show();
		}else{
			$(".gridControls [data-type='SELFREJECT']").hide();
		}
		
		var approvalRequestId = "";
		
		if(callType == "DETAIL") {
			approvalRequestId = "${param.approvalRequestId}";
			document.getElementById("ul").className="mdi-container";
		}else{
			approvalRequestId = "${param.jobKeyId}";
			myForm.select(".gridControls").hide();
		}
		
		var body = myForm.select(".table ._detailBody");
		var table = "table";
		
		myForm.transaction("lgvhr", "lgvatt/LGVATT20441/retrieveMutiplanDetail", {approvalRequestId:approvalRequestId} , function( data ){
			
		var requestDate = data["result"]["requestDate"];
		var subsidiaryCode = data["result"]["subsidiaryCode"];
		var employeeNo = data["result"]["employeeNo"];
		var planStartDate = data["result"]["planStartDate"];
		var planEndDate = data["result"]["planEndDate"];
		var attendanceType = data["result"]["attendanceType"];
		var attendanceTypeDetail = data["result"]["attendanceTypeDetail"];
		var requestReasonContent = data["result"]["requestReasonContent"];
		var detailReason = data["result"]["detailReason"];
		var planningId = data["result"]["planningId"];
		var requestor = data["result"]["requestor"];
		
		$("#employeeNo").val(employeeNo);
		
		if(detailReason == undefined) {
			detailReason = "";
		}
		
		$("#planningId").val(planningId);
		
		var str = "<tr>"+
					"<th>"+"<lgcom:message code='label.att.requestDate' />"+"</th>"+
					"<td colspan='5'>"+
					"<div class='form-inline'>"+
					nvl(requestDate) +
					"<div class='form-group'></div>"+
					"</div>"+
					"</td>"+
				  "</tr>"+
				  "<tr>"+
				  "<th>"+"<lgcom:message code='label.att.planDate' />"+"</th>"+
					"<td>"+
					"<div class='form-inline'>"+
					nvl(planStartDate) +" ~ "+ nvl(planEndDate) +
					"</div>"+
					"</td>"+
					"<th><lgcom:message code='EmployeeName' /></th>"+
					"<td colspan='3'>"+
					"<div class='form-inline'>"+
					nvl(requestor) +
					"</div>"+
					"</td>"+
				  "</tr>"+
				  "<tr>"+
					"<th><lgcom:message code='label.att.attendanceType' /></th>"+
					"<td>"+
					"<div class='form-inline'>"+
					nvl(attendanceType) +
					"</div>"+
					"</td>"+
					"<th rowspan='2'><lgcom:message code='label.att.timeAttendInputReasonDesc' /></th>"+
					"<td rowspan='2'>"+
					"<div class='form-inline'>"+
					nvl(requestReasonContent) +
					"</div>"+
					"</td>"+
					"<tr>"+
					"<th><lgcom:message code="label.att.attendanceCode" /></th>"+
					"<td>"+
					"<div class='form-inline'>"+
					nvl(attendanceTypeDetail) +
					"</div>"+
					"</td>"+
					"</tr>"+
					"<tr>"+
					"<th><lgcom:message code='label.att.attendanceDetailReason' /></th>"+
					"<td colspan='3'>"+
					"<div class='form-inline'>"+
					nvl(detailReason) +
					"</div>"+
					"</td>"+
				  "</tr>";
				  
		body.append(str);

		});
		// 결재영역 높이 재지정
		if(callType != "DETAIL") {
			//_resizeDetailArea(myForm.select('.content1').outerHeight(true));
			_resizeDetailArea(200);
		}
	}
	
	//결제정보 조회
	function retrieveApproverInfo() {
		if(callType == "DETAIL") {
			document.getElementById("ul").className="mdi-container";
		}else{
			approvalRequestId = "${param.jobKeyId}";
			myForm.select(".gridControls").hide();
			myForm.select("#approvalInfo").hide();
			myForm.select(".gridControls button").hide();
		}
		$("#requestMasterId").val(approvalRequestId);
		$("#requestCode").val(requestCode);
		$("#applicationUserId").val(applicationUserId);
		
		myForm.transaction("lgvhr", "lgvatt/LGVATTCOMM/retrieveApproverList", {requestMasterId:approvalRequestId, requestCode:requestCode} , function( data ){
			var list = data["result"];
			myForm.select(".approvalInfoTable tbody").empty();
			
			$(list).each( function(){
				appendTableRow(this);
			});
		});
	}
	//행추가
	function appendTableRow(item) {
		var body = myForm.select(".approvalInfoTable ._approverBody");
		
		var str = "<tr data-approvalseq="+item["approvalSeqs"]+">"+
						"<td class='text-center'>"+nvl(item["approvalSeqs"])+"</td>"+
						"<td class='text-center'>"+nvl(item["approvalActionName"])+"</td>"+
						"<td class='text-left'>"+nvl(item["approver"])+"</td>"+
						"<td class='text-center'>"+nvl(item["mandator"])+"</td>"+
						"<td class='text-left'>"+nvl(item["approvalStatusCodeName"])+"</td>"+
						"<td class='text-center'>"+nvl(item["approvalDate"])+"</td>"+
						"<td class='text-left'>"+nvl(item["approvalComment"])+"</td>"+
						//"<td></td>"+
					"</tr>";
					
		body.append( str );
	}
	
	myForm.addEvent( "click", "button[data-action]", function( event){
		
		var item = $(event.target);
		if( item.is("span") ) {
			item = $(item).closest("button");
		}
		var action = $(item).data("action");
		
		
		switch( action ) {
			case "goList" :
				var nav = new Navigate( myForm, "lgvhr", "M_LGVATT_1019" );
		        nav.addNavigationCallback( function( caller ){
		            myForm.select("button[data-action=search]").trigger('click');
		        });
		        nav.goPageInCurrentDiv(false);
			break;	
			case 'selfReject':
				Message.confirm('<lgcom:message code="question.Cancelrequest"/>',function() {
					if(fnSelfRejectRequest('REQUESTCANCEL')) successMessage();
				 });	
			break;
		}
	});
	
	/* 통합결재 연동 관련 코드 */
	var approvalInfo = {
		init : function(param) {
			// 요청서 조회
			myForm.select(".requestBlock input[name='requestMasterId']").val($.trim('<c:out value="${urlAddr.jobKeyId}"/>'));
			myForm.select(".requestBlock input[name='requestCode']").val($.trim('<c:out value="${urlAddr.jobRequestCode}"/>'));
			fncRetrieveRequestContent();
		},
		buttons : [
			{text:'<lgcom:message code="RequestCancel"/>'        , action:'selfReject', type:'SELF_REJECT'},
			{text:'<lgcom:message code="Approval"/>'             , action:'approval'  , type:'APPROVAL'   },
			{text:'<lgcom:message code="Reject"/>'               , action:'reject'    , type:'REJECT'     },
			{text:'<lgcom:message code="Forward"/>'              , action:'forward'   , type:'FORWARD'    , visible:false},
			{text:'<lgcom:message code="ProcEVF"/>'              , action:'openevf'   , type:'EVFPROC'    , visible:false},
			{text:'<lgcom:message code="ListEVF"/>'              , action:'evflist'   , type:'EVFLIST'    , visible:false},
			{text:'<lgcom:message code="Print"/>'                , action:'print'     , type:'PRINT'      }
		],
		callback : function(action, param) {
			switch(action) {
				// 요청취소
				case 'selfReject':
					Message.confirm('<lgcom:message code="question.Cancelrequest"/>',function() {
						if(fnSelfRejectRequest('REQUESTCANCEL')) _approvalCallback( action, true);  //승인 또는 반려 처리에 대한 결과 Callback 처리
						//if(fnSelfRejectRequest('REQUESTCANCEL')) successMessage();
						successMessage();
					});
					break;
				// 승인
				case 'approval':
					// 승인시 Comment 담기
					myForm.select(".requestBlock input[name='approvalComment']").val($.trim(param.comment));
					var returnValue = fnApprovalOrRejectRequest('APPROVAL');
					_approvalCallback(action, returnValue);  //승인 또는 반려 처리에 대한 결과 Callback 처리
					break;
				// 반려
				case 'reject':
					// 반려시 Comment 담기
					myForm.select(".requestBlock input[name='approvalComment']").val($.trim(param.comment));
					var returnValue = fnApprovalOrRejectRequest('REJECT');
					_approvalCallback(action, returnValue);  //승인 또는 반려 처리에 대한 결과 Callback 처리
					break;
				// 전달
				case 'forward':
					// 팝업에 사용될 Argument 객체 선언
					var _popup = myForm.popupInfo.userMultiPopup;
					// 기존 선택된 사용자 ID를 넘긴다.
					_popup['commentFlag'] = 'Y';
					_popup['keyType'] = 'applicationUserId';		// applicationUserId 또는 userName(사번)
					_popup['keyValue'] = '';
					// 팝업 호출
					var popup = new Popup(myForm,'lgcom','M_LGSYSC_1152','<lgcom:message code="Forwarder"/>');
					popup.setSize(1000,528);
					popup.open(function() {
						if(_popup['userList']) {
							var param = {
								requestMasterId: $.trim(myForm.select(".requestBlock input[name='requestMasterId']").val()),
								requestCode: $.trim(myForm.select(".requestBlock input[name='requestCode']").val()),
								requestorId: $.trim(myForm.select(".requestBlock input[name='requestorId']").val()),
								organizationId: $.trim(myForm.select(".requestBlock input[name='organizationId']").val()),
								transfererNo: [],
								inpctComment: ''
							};
							// 선택된 전달자 정보를 받는다.
							for(var i=0; i < _popup['userList'].length; i++) {
								var userItem = _popup['userList'][i];
								var transf = {
									userId: $.trim(userItem['userId']),
									employeeNo: $.trim(userItem['employeeNo']),
									employeeName: $.trim(userItem['employeeName'])
								};
								param.transfererNo.push(transf);
							}
							param['inpctComment'] = $.trim(_popup['comment']);
							// 전달처리
							<%-- 전달하시겠습니까? --%>
							Message.confirm('<lgcom:message code="question.transfer"/>',function() {
								myForm.showProgress();
								// 전달자를 전달한다.
								myForm.transaction_sync("lgcom",'lgcom/LGSMPC10012/updateRequestTransferer',param,function(data) {
									myForm.hideProgress();
									Message.notify('<lgcom:message code="note.completed"/>');
									// 결재화면 재조회
									_refreshApprovalInfo();
								});
							});
							myForm.popupInfo.userMultiPopup = null;
							myForm.popupInfo.userMultiPopup = {};
						}
					});
					break;
				// 인쇄
				case 'print':
					var browser = navigator.userAgent.toLowerCase();
					if(browser.indexOf('chrome') != -1) {
						window.print();
					} else if (browser.indexOf('trident') != -1) {
						try {
							//웹 브라우저 컨트롤 생성
							var webBrowser = '<object id="previewWeb" width="0" height="0" classid="CLSID:8856F961-340A-11D0-A96B-00C04FD705A2"></object>';
							//웹 페이지에 객체 삽입
							document.body.insertAdjacentHTML('beforeEnd', webBrowser);
							//ExexWB 메쏘드 실행 (7 : 미리보기 , 8 : 페이지 설정 , 6 : 인쇄하기(대화상자))
							document.previewWeb.ExecWB(7,1);
							//객체 해제
							$('#previewWeb').remove();
						} catch(e) {
							Message.alert('<lgcom:message code="note.errorPrint"/>');
						}
					}
					break;
			}
		}
	};
	myForm.setApprovalInfo( approvalInfo );
	
	// 결재 처리 Callback Function
	function fnApprovalOrRejectRequest(actionCode) {
		myForm.showProgress();
		var returnValue = false;
		var planningId = $("#planningId").val();
		var employeeNo = $("#employeeNo").val();
		var param = {
			requestMasterId: $.trim(myForm.select(".requestBlock input[name='requestMasterId']").val()),
			requestCode: $.trim(myForm.select(".requestBlock input[name='requestCode']").val()),
			approvalCommand: $.trim(actionCode),
			comment: $.trim(myForm.select(".requestBlock input[name='approvalComment']").val()),
			planningId: planningId,
			employeeNo: employeeNo
		}
		 transaction_sync("lgvhr",'lgvatt/LGVATT20441/saveRequestApprovalOrReject',param,function(data) {
			if(data.result) {
				// 정상처리
				if($.trim(data.result['errorCode']) == 'S') {
					returnValue = true;
				} else {
					returnValue = false;
				}
				myForm.hideProgress();
				if(!returnValue) {
					Message.alert(data.result['errorMsg']);
				}
				return returnValue;
			}
			myForm.hideProgress();
		},function(error) {
			trace(error);
			myForm.hideProgress();
		});  
	}
	//Self Reject callback Function
	function fnSelfRejectRequest(actionCode) {
		myForm.showProgress();
		var returnValue = false;
		var approvalRequestId = "";
		var requestCode = "";
		var applicationUserId = "";
		
		approvalRequestId = $("#requestMasterId").val();
		requestCode = $("#requestCode").val();
		applicationUserId = $("#applicationUserId").val();
		
		var param = {
				requestMasterId: approvalRequestId,
				requestCode: requestCode,
				applicationUserId: applicationUserId,
				approvalCommand: $.trim(actionCode)
		};
		 transaction_sync("lgvhr",'lgvatt/LGVATT20441/saveSelfReject',param,function(data) {
			 
			if(data.result) {
				// 정상처리
				if($.trim(data.result['errorCode']) == 'S') {
					returnValue = true;
				} else {
					returnValue = false;
				}
				myForm.hideProgress();
				if(!returnValue) {
					Message.alert(data.result['errorMsg']);
				}
				$(".gridControls [data-type='SELFREJECT']").hide();
			}
		},function(error) {
			trace(error);
			myForm.hideProgress();
		}); 
		 return returnValue;
	}

	function successMessage() {
		Message.alert( "<lgcom:message code="note.Successfullydeleted" />" );
	}
	
	// Custom Button 제어 로직
	function fncControllButton() {
		// 처리상태가 승인완료이면서 요청자, 결재자, 참조자, 전달자의 경우에만 EVF처리,EVF처리현황 버튼을 숨긴다.
		var status = $.trim(myForm.select(".requestBlock input[name='approvalStatusCode'").val());
		var flag1 = $.trim(myForm.select(".requestBlock input[name='requestorFlag']").val());
		var flag2 = $.trim(myForm.select(".requestBlock input[name='approverFlag']").val());
		var flag3 = $.trim(myForm.select(".requestBlock input[name='referrerFlag']").val());
		var flag = (flag1 == 'Y' || flag2 == 'Y' || flag3 == 'Y');
		if(status == '40' && flag) {
			_approvalButtonControl('FORWARD',true);
		} else {
			_approvalButtonControl('FORWARD',false);
		}
	}
}

LGVATT20450.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch( function(){
		var form = new LGVATT20450();
		form.init();
		//form.loadCompleted();
	});
});

</script>
</head>

<body>

<div id="ul" class="_approvalPanel">
	<section class="page-content">
	<div class="pageHeader">
		<h2>Long Term Request</h2>
	</div>

	<div class="dataBlock requestBlock">
		<input type="hidden" name="requestMasterId" id="requestMasterId"/>
		<input type="hidden" name="requestCode" id="requestCode"/>
		<input type="hidden" name="applicationUserId" id="applicationUserId"/>		
		<input type="hidden" name="approvalComment"/>	
		<input type="hidden" id="successYn"/>	
		<input type="hidden" id="employeeNo"/>
	</div>
	<div class="gridControls module-group text-right">
		 <div class="btn-toolbar">
			<div class="btn-group">
				<button class="btn btn-default btn-sm" type="submit" data-action="goList"><lgcom:message code="List"/></button>
			</div>
			<div class="btn-group">					      
				<button class="btn btn-darkgray btn-sm" type="button" role="button" data-type='SELFREJECT' data-action="selfReject"><lgcom:message code="RequestCancel"/></button>
			</div>
		 </div>
	</div>
	<div class="sub-header" id="detailSubHeader">
		<h3><lgcom:message code="DetailInfo" /></h3>
	</div>	
	
	<div class="gridContent grid-wrap">
		<form class="form detailInfo">
			<input type="hidden" name="approvalMenuId" value="M_LGVATT_1030"/>
			<input type="hidden" name="planningId" id="planningId"/>
			<table class="table table-condensed" >
				<colgroup>
					<col width="130" /> <!-- th -->
					<col width="150" />
					<col width="130" /> <!-- th -->
					<col width="150" />
					<col width="130" /> <!-- th -->
					<col width="150" />
				</colgroup>
				<tbody class="_detailBody"></tbody>
			</table>
		</form>
		
	</div>
	<br>
	<div id="approvalInfo">
	<div class="sub-header">
		<h4><lgcom:message code="Approval Info" /></h4>
	</div>
	<div class="approvalArea _approvals">
		<form class="form approvalInfo" >
			<table class="approvalInfoTable table table-bordered table-condensed">
				<caption class="sr-only"><lgcom:message code="ApprovalInformation1" /></caption>
				<colgroup>
					<col width="50">
					<col width="100">
					<col width="400">
					<col width="400">
					<col width="150">
					<col width="130">
					<col width="*">
				</colgroup>
				<thead>
					<tr>
						<th scope="col"><lgcom:message code="label.att.seq" /></th>
						<th scope="col"><lgcom:message code="label.att.approvalType" /></th>
						<th scope="col"><lgcom:message code="label.att.approver" /></th>
						<th scope="col"><lgcom:message code="label.att.mandator" /></th>
						<th scope="col"><lgcom:message code="label.att.approvalStatus" /></th>
						<th scope="col"><lgcom:message code="ApprovalRequestDate" /></th>
						<th scope="col"><lgcom:message code="ApprovalComment" /></th>
					</tr>
				</thead>
				<tbody class="_approverBody">
				</tbody>
			</table>
		</form>
	</div>
	</div>
	</section>
</div>
</body>
</html>