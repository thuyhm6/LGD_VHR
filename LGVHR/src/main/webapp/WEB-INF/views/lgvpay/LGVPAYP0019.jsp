<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAYP0019.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2018 LG CNS,  All rights reserved.

    설 명 : 본 화면은 Retroactive Payroll Run(실행)하는 팝업 화면입니다.
    작성자 : 이형준	
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title><lgcom:message code="label.pay.executionList"/></title>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVPAYP0019 = function() {
	var myForm = this;
	// Form Util 선언
	var formUtil = new FormUtil( myForm, ".dataBlock form" );
	var popupParam = myForm.getParent().popupInfo.retroPayrollRunPopup;
	
	//팝업으로서의 이 화면은 여러 화면에서 사용하는 것으로, 팝업 윈도우의 크기를 아래와 같이 고정하였다.
	myForm.select(".dataBlock").parents("._div_popup_holder_").css({"width": "500px", "height":"250px"});
	
    // 화면 레이아웃 정의
	//값 셋팅
	formUtil.clear();
	formUtil.setValue(popupParam);

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
	    	retroactiveStartMonth : { monthYear : true, required : true },
	    	retroactiveEndMonth : { monthYear : true, required : true }
	    },
	    messages: {
	    	retroactiveStartMonth : { required : '<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.retroactiveStartMonth'/>" />'},
	    	retroactiveStartMonth : { monthYear : '<lgcom:message code="error.incorrectFormat" />' },
	    	retroactiveEndMonth : { required : '<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.retroactiveEndMonth'/>" />'},
	    	retroactiveEndMonth : { monthYear : '<lgcom:message code="error.incorrectFormat" />' }
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
		    	// 소급 급여실행
		    	if ( validator.isValid()) {
		    		fncRetroactivePayrollRun();
		    	}
		    	break;
		}
		event.stopPropagation();
	});
	/* Form Submit 방지 */
	myForm.addEvent('submit','.dataBlock form',function(event) {
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
		
		if( DateUtil.parse(formUtil.getValue("retroactiveStartMonth"), "MM/YYYY") >= DateUtil.parse(popupParam["payrollCalcPeriodValue"], "MM/YYYY") ) {
			Message.alert('<lgcom:message code="error.pay.RetroactivePeriodValid" arguments="<lgcom:message code='label.pay.retroactiveStartMonth'/>, <lgcom:message code='label.pay.retroactiveEndMonth'/>, <lgcom:message code='label.pay.payMonthShort'/>"/>');
			return false;
		}
		
		if( DateUtil.parse(formUtil.getValue("retroactiveEndMonth"), "MM/YYYY") >= DateUtil.parse(popupParam["payrollCalcPeriodValue"], "MM/YYYY") ) {
			Message.alert('<lgcom:message code="error.pay.RetroactivePeriodValid" arguments="<lgcom:message code='label.pay.retroactiveStartMonth'/>, <lgcom:message code='label.pay.retroactiveEndMonth'/>, <lgcom:message code='label.pay.payMonthShort'/>"/>');
			return false;
		}
		
		if( DateUtil.parse(formUtil.getValue("retroactiveStartMonth"), "MM/YYYY") > DateUtil.parse(formUtil.getValue("retroactiveEndMonth"), "MM/YYYY") ) {
			Message.alert('<lgcom:message code="error.pay.RetroactivePeriodValid" arguments="<lgcom:message code='label.pay.retroactiveStartMonth'/>, <lgcom:message code='label.pay.retroactiveEndMonth'/>, <lgcom:message code='label.pay.payMonthShort'/>"/>');
			return false;
		}
		
		return true;
	}
	
	//급여실행
	function fncRetroactivePayrollRun() {
    	
		Message.confirm( "<lgcom:message code="question.pay.requestRun"/>", function() {
			var param = { payrollCalcPeriodValue   : popupParam["payrollCalcPeriodValue"]
			            , payrollTypeCode          : popupParam["payrollTypeCode"]
			            , calculationSetId         : popupParam["calculationSetId"]
            			, retroactiveStartMonth    : formUtil.getValue("retroactiveStartMonth")
            			, retroactiveEndMonth      : formUtil.getValue("retroactiveEndMonth")
					    };
			myForm.transaction("lgvhr", "lgvpay/LGVPAYP0019/insertRetroactivePayrollCalculationExec", param, function (data) {
				<%-- 급여실행 순서
			     - payrollCalculationExecId seq 조회
			     - tb_pay_calc_exec_n 테이블 insert
			     - payroll run 그룹 개수, 그룹당 인원수 조회
			     - payroll run 그룹 개수별 사번구간 조회
			     - payroll run 그룹 개수별 사번구간 loop 
			       - 건별 소급 급여실행 배치 call(LGVPAYC0014)
			     - payroll run 그룹 개수별 사번구간 end loop 
				--%>
				if ( data.result ) {
					$(data.result["payrollRunSectionList"]).each(function(inx) {
						param = {};
						param = { data : { programId                : "LGVPAYC0014"/*급여 Run : LGVPAYC0013 , 소급 급여 Run LGVPAYC0014*/
						                ,  empNo                    : '' /* 특정 사람에 대한 수행일때 */
						                ,  assignmentSetId          : popupParam["calculationSetId"]
						                ,  periodId                 : this.payrollCalculationPeriodId
						                ,  runTypeName              : popupParam["payrollTypeCode"]
						                ,  startEmployeeNo          : this.startEmployeeNo
						                ,  endEmployeeNo            : this.endEmployeeNo
						                ,  payrollCalculationExecId : this.payrollCalculationExecId
				            			, retroactiveStartMonth    : formUtil.getValue("retroactiveStartMonth")
				            			, retroactiveEndMonth      : formUtil.getValue("retroactiveEndMonth")
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

LGVPAYP0019.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVPAYP0019();
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
							<th scope="col"><lgcom:message code="label.pay.retroactiveStartMonth"/></th>
							<td><input type="text" class="form-control input-sm size_80" name="retroactiveStartMonth" maxlength="7" placeholder="<lgcom:message code="placeholder.pay.mmyyyy"/>" /></td>
						</tr>
						<tr>
							<th scope="col"><lgcom:message code="label.pay.retroactiveEndMonth"/></th>
							<td><input type="text" class="form-control input-sm size_80" name="retroactiveEndMonth" maxlength="7" placeholder="<lgcom:message code="placeholder.pay.mmyyyy"/>" /></td>
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
