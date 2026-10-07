<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAYP0020.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2018 LG CNS,  All rights reserved.

    설 명 : 본 화면은 Transfer ERP 전에 급여 확정 요청(통합결재 승인)하는 팝업 화면입니다.
    작성자 : 이형준	
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Request Payroll Confirm</title>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<style type="text/css">
.appendedTD {
	padding: 8px;
	line-height: 1.42857143;
	vertical-align: top;
	border-top: 1px solid #ddd;
}
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVPAYP0020 = function() {
	var myForm = this;
	// Form Util 선언
	var formUtil = new FormUtil( myForm, ".dataBlock form" );
	var popupParam = {};
	
	if( isNull($.trim('<c:out value="${urlAddr.jobKeyId}"/>')) ) {
		popupParam = myForm.getParent().popupInfo.payrollSummaryPopup;
	}
	
	//팝업으로서의 이 화면은 여러 화면에서 사용하는 것으로, 팝업 윈도우의 크기를 아래와 같이 고정하였다.
	myForm.select(".dataBlock").parents("._div_popup_holder_").css({"width": "1100px", "height":"494px"});
	
    // 화면 레이아웃 정의a
	//값 셋팅
	formUtil.clear();

    // 그리드선언

    // 개인화조건
    
    // 조회조건 저장 처리
    
    // 팝업 데이터 정의 searchMode:single(단수),multi(복수)

    // 그리드형 테이블 TR
    
    // 코드 데이터 조회
	
	// 콤보 초기화
	
    // 날짜 팝업창
    
	/* 통합결재 연동 관련 코드 */
	var approvalInfo = {
		init : function(param) {
			// 요청서 조회
			myForm.select(".dataBlock input[name='requestMasterId']").val($.trim('<c:out value="${urlAddr.jobKeyId}"/>'));
			myForm.select(".dataBlock input[name='requestCode']").val($.trim('<c:out value="${urlAddr.jobRequestCode}"/>'));
			fncRetrieveRequestContent();
		},
		buttons : [
			{text:'<lgcom:message code="RequestCancel"/>'        , action:'selfReject', type:'SELF_REJECT', visible:false},
			{text:'<lgcom:message code="Approval"/>'             , action:'approval'  , type:'APPROVAL'   },
			{text:'<lgcom:message code="Reject"/>'               , action:'reject'    , type:'REJECT'     },
			{text:'<lgcom:message code="Forward"/>'              , action:'forward'   , type:'FORWARD'    , visible:false},
			{text:'<lgcom:message code="ProcEVF"/>'              , action:'openevf'   , type:'EVFPROC'    , visible:false},
			{text:'<lgcom:message code="ListEVF"/>'              , action:'evflist'   , type:'EVFLIST'    , visible:false},
			{text:'<lgcom:message code="Print"/>'                , action:'print'     , type:'PRINT'      , visible:false}
		],
		callback : function(action, param) {
			switch(action) {
				// 승인
				case 'approval':
					// 승인시 Comment 담기
					myForm.select(".dataBlock input[name='approvalComment']").val($.trim(param.comment));
					var returnValue = fnApprovalOrRejectRequest('APPROVAL');
					_approvalCallback(action, returnValue);  //승인 또는 반려 처리에 대한 결과 Callback 처리
					break;
				// 반려
				case 'reject':
					// 반려시 Comment 담기
					myForm.select(".dataBlock input[name='approvalComment']").val($.trim(param.comment));
					var returnValue = fnApprovalOrRejectRequest('REJECT');
					_approvalCallback(action, returnValue);  //승인 또는 반려 처리에 대한 결과 Callback 처리
					break;
			}
		}
	};
	myForm.setApprovalInfo( approvalInfo );
    
    // Event 처리
	/*** 이벤트 핸들러  ***/
	myForm.addEvent( "click", "button[data-action]" , function(event){
		var item = $(event.target);
		
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		
		var action = $.trim(item.data('action'));
		switch( action ){
		    case "request" :
		    	if ( !fncValidatePayrollConfirmParam() ) return ;
		    	
		    	var param = {
		    		payrollCalcPeriodValue	: popupParam["payrollCalcPeriodValue"],
		    		payrollTypeCode			: popupParam["payrollTypeCode"],
		    		calculationSetId		: popupParam["calculationSetId"],
	    			calculationExecId		: popupParam["calculationExecId"]
		    	};
		    	
		    	Message.confirm('<lgcom:message code="question.ApprovalRequest"/>', function() {
					myForm.showProgress();
					myForm.transaction_sync("lgvhr", "lgvpay/LGVPAYP0020/insertRequestPayrollConfirm", param, function( data ){
						myForm.hideProgress();
						Message.alert( '<lgcom:message code="note.completed" />' );
						Popup.closePopup(myForm, true);
					});
				});
		    	
		    	break;
		}
		
		event.stopPropagation();
	});
	/* Form Submit 방지 */
	myForm.addEvent('submit','.dataBlock form',function(event) {
		event.preventDefault();
	});
	
	/*** 내부 함수  ***/
    function fncRetrieveRequestContent() {
		myForm.select(".buttonBlock").hide();
		
		var param = {
			requestMasterId : myForm.select(".dataBlock input[name='requestMasterId']").val(),
			requestCode : myForm.select(".dataBlock input[name='requestCode']").val()
		};
		
		myForm.showProgress();
		myForm.transaction_sync("lgvhr", "lgvpay/LGVPAYP0020/retrieveRequestContent", param, function( data ){
			myForm.hideProgress();
			var list = data["result"];
			var tbody = $('.dataBlock form table tbody');
			tbody.empty();
			$(list).each(function(){
				$(tbody).append('<tr>');
				$(tbody).append('<td class="appendedTD text-center"><span>' + nvl(this["category"]) + '</span></td>');
				$(tbody).append('<td class="appendedTD text-right"><span>' + nvl(this["numOfPeople"]) + '</span></td>');
				$(tbody).append('<td class="appendedTD text-right"><span>' + nvl(this["salary"]) + '</span></td>');
				$(tbody).append('<td class="appendedTD text-right"><span>' + nvl(this["ot"]) + '</span></td>');
				$(tbody).append('<td class="appendedTD text-right"><span>' + nvl(this["insurance"]) + '</span></td>');
				$(tbody).append('<td class="appendedTD text-right"><span>' + nvl(this["tradeUnion"]) + '</span></td>');
				$(tbody).append('<td class="appendedTD text-right"><span>' + nvl(this["salaryBefTax"]) + '</span></td>');
				$(tbody).append('<td class="appendedTD text-right"><span>' + nvl(this["pitFull"]) + '</span></td>');
				$(tbody).append('<td class="appendedTD text-right"><span>' + nvl(this["pitAdjustmentFull"]) + '</span></td>');
				$(tbody).append('<td class="appendedTD text-right"><span>' + nvl(this["netPay"]) + '</span></td>');
				$(tbody).append('</tr>');
			});

			_resizeDetailArea(myForm.select('.dataBlock table').outerHeight(true) + 10);
		});
    }
	
	// 결재 처리 Callback Function
	function fnApprovalOrRejectRequest(actionCode) {
		myForm.showProgress();
		var returnValue = false;
		var param = {
			requestMasterId: $.trim(myForm.select(".dataBlock input[name='requestMasterId']").val()),
			requestCode: $.trim(myForm.select(".dataBlock input[name='requestCode']").val()),
			approvalCommand: $.trim(actionCode),
			comment: $.trim(myForm.select(".dataBlock input[name='approvalComment']").val())
		}
		transaction_sync("lgvhr",'lgvpay/LGVPAYP0020/insertApproveOrReject', param, function(data) {
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
	
	// 급여지급확정요청 전 파라미터체크
	function fncValidatePayrollConfirmParam() {
		if ( isNull(popupParam["payrollCalcPeriodValue"]) ) {
			Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.payMonthShort'/>" />');
			return false;
		}
		
		if ( isNull(popupParam["payrollTypeCode"]) ) {
			Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.payType'/>" />');
			return false;
		}
		
		if ( isNull(popupParam["calculationSetId"]) ) {
			Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.calculationSet'/>" />');
			return false;
		}
		
		if ( isNull(popupParam["calculationExecId"]) ) {
			Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.executionId'/>" />');
			return false;
		}
		
		return true;
	}
	
	function fncRetrievePayrollSummary() {
		
		if( !isNull($.trim('<c:out value="${urlAddr.jobKeyId}"/>')) || !fncValidatePayrollConfirmParam()) return;
		
		myForm.showProgress();
		myForm.transaction_sync("lgvhr", "lgvpay/LGVPAYP0020/retrievePayrollSummary", popupParam, function( data ){
			myForm.hideProgress();
			var list = data["result"];
			var tbody = $('.dataBlock form table tbody');
			tbody.empty();
			$(list).each(function(){
				$(tbody).append('<tr>');
				$(tbody).append('<td class="appendedTD text-center"><span>' + nvl(this["category"]) + '</span></td>');
				$(tbody).append('<td class="appendedTD text-right"><span>' + nvl(this["numOfPeople"]) + '</span></td>');
				$(tbody).append('<td class="appendedTD text-right"><span>' + nvl(this["salary"]) + '</span></td>');
				$(tbody).append('<td class="appendedTD text-right"><span>' + nvl(this["ot"]) + '</span></td>');
				$(tbody).append('<td class="appendedTD text-right"><span>' + nvl(this["insurance"]) + '</span></td>');
				$(tbody).append('<td class="appendedTD text-right"><span>' + nvl(this["tradeUnion"]) + '</span></td>');
				$(tbody).append('<td class="appendedTD text-right"><span>' + nvl(this["salaryBefTax"]) + '</span></td>');
				$(tbody).append('<td class="appendedTD text-right"><span>' + nvl(this["pitFull"]) + '</span></td>');
				$(tbody).append('<td class="appendedTD text-right"><span>' + nvl(this["pitAdjustmentFull"]) + '</span></td>');
				$(tbody).append('<td class="appendedTD text-right"><span>' + nvl(this["netPay"]) + '</span></td>');
				$(tbody).append('</tr>');
			});
		});
		
	}

	fncRetrievePayrollSummary();
}

LGVPAYP0020.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVPAYP0020();
		form.init();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2>Request Payroll Confirm</h2>
		</div>
		
		<div class="buttonBlock module-group text-right">
			<div class="btn-group">
				<button class="btn btn-darkgray btn-sm" type="button" data-action="request"><lgcom:message code="button.pay.request"/></button>
			</div>
		</div>

		<div class="dataBlock">
			<form class="form" method="post">
				<table class="table table-bordered table-condensed">
					<colgroup>
						<col width="08%"/>
						<col width="10%"/>
						<col width="10%"/>
						<col width="9%"/>
						<col width="10%"/>
						<col width="10%"/>
						<col width="12%"/>
						<col width="9%"/>
						<col width="11%"/>
						<col width="11%"/>
					</colgroup>
					<thead>
						<tr>
							<th scope="col"><lgcom:message code="label.pay.category"/></th>
							<th scope="col"><lgcom:message code="label.pay.numOfPeople"/></th>
							<th scope="col"><lgcom:message code="label.pay.salary"/></th>
							<th scope="col"><lgcom:message code="label.pay.ot"/></th>
							<th scope="col"><lgcom:message code="label.pay.insurance"/></th>
							<th scope="col"><lgcom:message code="label.pay.tradeUnion"/></th>
							<th scope="col"><lgcom:message code="label.pay.salaryBefTax"/></th>
							<th scope="col"><lgcom:message code="label.pay.pitFull"/></th>
							<th scope="col"><lgcom:message code="label.pay.pitAdjustmentFull"/></th>
							<th scope="col"><lgcom:message code="label.pay.netPay"/></th>
						</tr>
					</thead>
					<tbody>
					</tbody>
				</table>
				
				<input type="hidden" name="requestMasterId"/>
				<input type="hidden" name="requestCode"/>
				<input type="hidden" name="approvalComment"/>
			</form>
		</div>
	</section>
</div>
</body>
</html>
