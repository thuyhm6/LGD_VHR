<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAYP0010.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 Payroll Run(실행)하는 팝업 화면입니다.
    작성자 : 임수진	
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title><lgcom:message code="label.pay.executionList"/></title>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVPAYP0010 = function() {
	var myForm = this;
	// Form Util 선언
	var formUtil = new FormUtil( myForm, ".dataBlock form" );
	var popupParam = myForm.getParent().popupInfo.payrollRunPopup;
	
	//팝업으로서의 이 화면은 여러 화면에서 사용하는 것으로, 팝업 윈도우의 크기를 아래와 같이 고정하였다.
	myForm.select(".dataBlock").parents("._div_popup_holder_").css({"width": "500px", "height":"250px"});
	
    // 화면 레이아웃 정의
	//값 셋팅
	formUtil.clear();
	formUtil.setValue(popupParam);
	formUtil.setValue({addingUpTaxationFlag:"N"});

    // 그리드선언

    // 개인화조건
    
    // 조회조건 저장 처리
    
    // 팝업 데이터 정의 searchMode:single(단수),multi(복수)

    // 그리드형 테이블 TR
    
    // 코드 데이터 조회
	
	// 콤보 초기화
	
    // 날짜 팝업창
    
    // 필수항목 체크
   	var validator = new Validator( myForm, ".dataBlock form" );

    validator.setRule( {
    	option: {placement: 'right'},
	    rules: {
	    	addupTaxationStartYyyymm : { monthYear : true }
	    },
	    messages: {
	    	addupTaxationStartYyyymm : { monthYear : '<lgcom:message code="error.incorrectFormat" />'}
	    }
    });

    // 일반함수	
    
    // Event 처리
	/*** 이벤트 핸들러  ***/
	myForm.addEvent( "click", "button[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}                                                                                                                                                                                                                                             
		var action = $.trim(item.data('action'));
		switch( action ){
		    case "run" :
		    	if ( !fncValidatePayrollRunParam() ) return ;
		    	//급여실행
		    	if ( validator.isValid()) {
		    		//PIT가 Y인 경우 날짜필수 입력체크
		    		if ( nvl(formUtil.getValue("addingUpTaxationFlag")) == "Y" && isNull(formUtil.getValue("addupTaxationStartYyyymm")) ) {
		    			Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.addingUpPITStartMonth'/>" />');
		    			return ;
		    		}
		    		fncPayrollRun();
		    	}
		    	break;
		}
		event.stopPropagation();
	});
	/* Form Submit 방지 */
	myForm.addEvent('submit','.dataBlock form',function(event) {
		event.preventDefault();
	});
	myForm.addEvent('change','.dataBlock form select[name="addingUpTaxationFlag"]',function(event) {
		var item = $(event.target);
		
		if ( $.trim(item.val()) == "Y" ) {//Y인 경우 년월입력 활성화
			myForm.select("input[name='addupTaxationStartYyyymm']").removeAttr("disabled");			
		} else {

			myForm.select("input[name='addupTaxationStartYyyymm']").attr("disabled", "disabled");
		}
		
		event.preventDefault();
	});
	/*** 내부 함수  ***/
	//급여실행 전 파라메터 값 체크
	function fncValidatePayrollRunParam() {
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
		
		return true;
	}
	//급여실행
	function fncPayrollRun() {
    	
		Message.confirm( "<lgcom:message code="question.pay.requestRun"/>", function() {
			var param = { payrollCalcPeriodValue   : popupParam["payrollCalcPeriodValue"]
			            , payrollTypeCode          : popupParam["payrollTypeCode"]
			            , calculationSetId         : popupParam["calculationSetId"]
			            , addingUpTaxationFlag     : formUtil.getValue("addingUpTaxationFlag")
			            , addupTaxationStartYyyymm : formUtil.getValue("addupTaxationStartYyyymm")
					    };
			myForm.transaction("lgvhr", "lgvpay/LGVPAYP0010/insertPayrollCalculationExec", param, function (data) {
				<%-- 급여실행 순서
			     - payrollCalculationExecId seq 조회
			     - tb_pay_calc_exec_n 테이블 insert
			     - payroll run 그룹 개수, 그룹당 인원수 조회
			     - payroll run 그룹 개수별 사번구간 조회
			     - payroll run 그룹 개수별 사번구간 loop 
			       - 건별 급여실행 배치 call(LGVPAYC0013)
			     - payroll run 그룹 개수별 사번구간 end loop 
				--%>
				if ( data.result ) {
					$(data.result["payrollRunSectionList"]).each(function(inx) {
						param = {};
						param = { data : { programId                : "LGVPAYC0013"/*로컬에서 확인할때는 LGVPAYC0014 사용. 실제 수행해야 하는 프로그램은 LGVPAYC0013*/
						                ,  empNo                    : '' /* 특정 사람에 대한 수행일때 */
						                ,  assignmentSetId          : popupParam["calculationSetId"]
						                ,  periodId                 : this.payrollCalculationPeriodId
						                ,  runTypeName              : popupParam["payrollTypeCode"]
						                ,  startEmployeeNo          : this.startEmployeeNo
						                ,  endEmployeeNo            : this.endEmployeeNo
						                ,  payrollCalculationExecId : this.payrollCalculationExecId
						                ,  errBuf                   : null
						                 } 
						        };
						myForm.transaction( 'lgvhr', "lgvpay/LGVPAYC0000/sendExecuteRequest", param, function( data ){});
					});<%-- //each --%>
					Message.alert("<lgcom:message code="note.pay.requestRun"/>");
					//창닫기
					Popup.closePopup(myForm,true);
				}<%-- //if ( data.result ) { --%>
			}, function (data) {//실패인 경우
				Message.alert("<lgcom:message code="note.pay.failRequestRun"/>");
			});<%-- //myForm.transaction --%>
		});<%-- //Message.confirm --%>
	}

}

LGVPAYP0010.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVPAYP0010();
		form.init();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2><lgcom:message code="label.pay.payrollRun"/></h2>
		</div>

		<div class="dataBlock">
			<form class="form" method="post">
				<table class="table table-condensed">
					<colgroup>
						<col width="40%"/>
						<col width="60%"/>
					</colgroup>
					<tbody>
						<tr>
							<th scope="col"><lgcom:message code="label.pay.payMonthShort"/></th>
							<td><span name="payrollCalcPeriodValue"></span></td>
						</tr>
						<tr>
							<th scope="col"><lgcom:message code="label.pay.payType"/></th>
							<td><span name="payrollTypeName"></span></td>
						</tr>
						<tr>
							<th scope="col"><lgcom:message code="label.pay.calculationSet"/></th>
							<td><span name="calculationSetName"></span></td>
						</tr>
						<tr>
							<th scope="col"><lgcom:message code="label.pay.addingUpPITFlag"/></th>
							<td><select class="form-control input-sm size_60" name="addingUpTaxationFlag"  data-type="yes_no"></select></td>
						</tr>
						<tr>
							<th scope="col"><lgcom:message code="label.pay.addingUpPITStartMonth"/></th>
							<td><input type="text" class="form-control input-sm size_80" name="addupTaxationStartYyyymm" maxlength="7" placeholder="<lgcom:message code="placeholder.pay.mmyyyy"/>" disabled/></td>
						</tr>
					</tbody>
				</table>
			</form>
		</div>
		
		<div class="buttonBlock module-group text-right">
			<div class="btn-group">
				<button class="btn btn-darkgray btn-sm" type="button" data-action="run"><lgcom:message code="button.pay.run"/></button>
			</div>
		</div>
		
	</section>
</div>
</body>
</html>
