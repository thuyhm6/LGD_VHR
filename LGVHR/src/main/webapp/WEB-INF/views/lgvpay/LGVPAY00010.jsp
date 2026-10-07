<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY00010.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 급여담당자가 특정 인원의 급여관련 상세 정보를 조회하는 화면입니다.
    작성자 : 임수진	
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title><lgcom:message code="label.pay.paymentMasterByEmployee"/></title>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<style type="text/css">
.table > tbody > tr > th .btn-link {
    padding: 0;
}
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVPAY00010 = function() {
	var myForm = this;
	// Form Util 선언
	var srchFormUtil = new FormUtil( myForm, ".searchBlock form" );
	var basicFormUtil        = new FormUtil( myForm, ".basicInfoBlock");
	var paymentBasicFormUtil = new FormUtil( myForm, ".paymentBasicInfoBlock form");
	var paymentFormUtil      = new FormUtil( myForm, ".paymentInfoBlock");
	
	// combo 목록 조회
	var code = new CommonCode("lgcom");
	code.add( "LGCOM_PIT_FLAG", { codeTypeCode:'LGCOM_PIT_FLAG' });
	code.execute();
	
	paymentBasicFormUtil.initCombo( "pitManualFlag", code.get("LGCOM_PIT_FLAG"), {selectAll : true } );
	
	//전달된 파라메터가 있는 경우 해당 값을 검색조건에 셋팅한다.
	var reqParam = { employeeNo : "<c:out value="${urlAddr.employeeNo}"/>"
			       , effectiveDate : "<c:out value="${urlAddr.effectiveDate}"/>".replaceAll("_", "/") };
	
    // 화면 레이아웃 정의

    // 그리드선언

    // 개인화조건
    
    // 조회조건 저장 처리
    myForm.searchConditionControl( true );
    
    // 팝업 데이터 정의 searchMode:single(단수),multi(복수)
	myForm.popupInfo = {
		userPopup          : {searchMode:'single', popupKind:'', confirmKind:'', employeeNo:'', employeeName:'', attDate:'', flsaYn:'N', fseYn:'N', userData:[]}
	  , bandPopup          : { employeeNo : '', searchFlag : 'Y' }
	  , dependantPopup     : { employeeNo : '', searchFlag : 'Y' }
	  , contractPopup      : { employeeNo : '', searchFlag : 'Y' }
	  , qualificationPopup : { employeeNo : '', searchFlag : 'Y' }
	  , assignmentPopup    : { employeeNo : '', searchFlag : 'Y' }
	};

    // 그리드형 테이블 TR

    // 코드 데이터 조회
	
	// 콤보 초기화
    
    // 날짜 팝업창
    srchFormUtil.setCalendar( { from : "effectiveDate", language:SESSION_USER.languageCode, format: 'DD/MM/YYYY' } );
    
    // 초기값 셋팅
    srchFormUtil.setValue( { employeeNo : nvl(reqParam.employeeNo)
    	                   , effectiveDate : nvl(reqParam.effectiveDate, DateUtil.today("DD/MM/YYYY")) 
    	                   } );
    paymentBasicFormUtil.setValue( { pitManualFlag : "N" } );
    
    // 필수항목 체크
   	var validator = new Validator( myForm, ".searchBlock form" );

    validator.setRule( {
    	option: {placement: 'right'},
	    rules: {
	        employeeNo:{required:true}
          , effectiveDate:{required:true}
	    },
	    messages: {
	    	employeeNo : {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.employeeNo'/>" />'}
    	  , effectiveDate : {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.effectiveDate'/>" />'}
	    }
    });
    //저장 시 체크할 validator
   	var saveValidator = new Validator( myForm, ".paymentBasicInfoBlock form" );

   	saveValidator.setRule( {
    	option: {placement: 'right'},
	    rules: {
	    	insStartMonth : { monthYear : true }
          , pitManualFlag : { required : true }
	    },
	    messages: {
	    	insStartMonth : { monthYear :'<lgcom:message code="incorrectFormat" />' }
    	  , pitManualFlag : { required :'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.pitManualFlag'/>" />' }
	    }
    });	

    // 일반함수	
    
    // Event 처리
	/*** 이벤트 핸들러  ***/
	myForm.addEvent( "click", "button[data-action]", function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}                                                                                                                                                                                                                                             
		var action = $.trim(item.data('action'));
		switch( action ){
			case "search" :
				if ( validator.isValid() ) {
					//조회권한이 있는지 여부
					//데이터 조회
					fncRetrievePaymentMasterData();
				}
				break;
				
			// 유저 검색 팝업
		    case "openPopupEmployee" :
		    	fncPopupEmployeeSearch();
                break;
				
   			// Assignment History 팝업
   		    case "assignmentHistory" :
   		    	fncPopupAssignment();
                break;
				
			case "save" :
				if ( saveValidator.isValid() ) {

					if ( !fncValidateEmployeeNo() ) return ;
					//데이터 저장
					fncUpdatePaymentBasicData();
				}
				break;
				
   			// Band 팝업
   		    case "band" :
   		    	fncPopupBand();
                break;
			
   			// Dependant 팝업
   		    case "dependant" :
   		    	fncPopupDependant();
                break;
    			
   			// Contract Type 팝업
   		    case "contract" :
   		    	fncPopupContract();
                break;
    			
   			// Qualification 팝업
   		    case "qualification" :
   		    	fncPopupQualification();
                break;
		}
		event.stopPropagation();
	});
	/* Form Submit 방지 */
	myForm.addEvent('submit', '.searchBlock form', function(event) {
		event.preventDefault();
	});
    //사번 또는 성명 클릭 시 값 초기화
    myForm.addEvent ( "click", ".searchBlock form input[name]", function(event) {
		var item = $(event.target);
		if ( $.trim(item.attr("name")) == "employeeNo" || $.trim(item.attr("name")) == "employeeName" ) {
    		//fncSearchEmpInfoInit();
		}
		event.stopPropagation();
    });
	myForm.addEvent ( "change", ".searchBlock form input[name]", function(event) {
		var item = $(event.target);
		switch ( $.trim(item.attr("name")) ) {
			case "employeeNo" : 
				//사번이 변경된 경우 성명 초기화 처리
				if ( srchFormUtil.getPreviousValue("employeeNo") != srchFormUtil.getValue("employeeNo") || isNull(srchFormUtil.getValue("employeeNo")) ) {
					srchFormUtil.setValue({employeeName:""});
				}
				//fncPopupEmployeeSearch();//사번 또는 성명 값 변경되는 경우 임직원 검색
				break;
			case "employeeName" : 
				//성명이 변경된 경우 사번 초기화 처리
				if ( srchFormUtil.getPreviousValue("employeeName") != srchFormUtil.getValue("employeeName") || isNull(srchFormUtil.getValue("employeeName")) ) {
					srchFormUtil.setValue({employeeNo:""});
				}
				//fncPopupEmployeeSearch();//사번 또는 성명 값 변경되는 경우 임직원 검색
				break;
			case "effectiveDate" :
				fncSearchData();
				break;
		}			
		event.stopPropagation();
	});
	myForm.addEvent ( "keyup", ".searchBlock form input[name]", function(event) {
		var item = $(event.target);
		if ( event.keyCode == 13 ) {//enter key
			switch ( $.trim($(event.target).attr("name")) ) {
				case "employeeNo":
					if ( srchFormUtil.getPreviousValue("employeeNo") != srchFormUtil.getValue("employeeNo") ) {
						srchFormUtil.setValue("employeeName", "");
					}
					break;
				case "employeeName":
					if ( srchFormUtil.getPreviousValue("employeeName") != srchFormUtil.getValue("employeeName") ) {
						srchFormUtil.setValue("employeeNo", "");
					}
					break;
			}
			fncPopupEmployeeSearch();
		}
		event.stopPropagation();
	});
	
	/*** 내부 함수  ***/	
	//사원검색 팝업 호출 및 값 셋팅
	function fncPopupEmployeeSearch() { 
    	var popupData = myForm.popupInfo.userPopup;
    	popupData.employeeNo = srchFormUtil.getValue("employeeNo");
    	popupData.employeeName = srchFormUtil.getValue("employeeName");
    	popupData.fseYn = "N";
    	popupData.flsaYn = "N";
    	fncSearchEmpInfoInit();

        var popup = new Popup( myForm,'lgvhr', 'M_LGVCOM_1010', '<lgcom:message code="UserSearch"/>' );
        popup.setSize(800,494);
        popup.open( function() {
        	if ( popupData.userData != null && popupData.userData.length > 0 ) {
        		srchFormUtil.setValue({employeeNo   : popupData.userData[0].employeeNo
        			                 , employeeName : popupData.userData[0].employeeName});
        		//검색조건 값이 있는 경우 데이터 조회
        		fncSearchData();
        	}
        });
        popupData.userData = [];
	}
	//사번, 성명값 초기화
	function fncSearchEmpInfoInit() { 
		srchFormUtil.setValue({employeeNo : '', employeeName : ''});		
	}
	function fncSearchData() {
		if ( !isNull(srchFormUtil.getValue("effectiveDate")) && !isNull(srchFormUtil.getValue("employeeNo")) ) { 
			myForm.select(".searchBlock button[data-action='search']").trigger("click");
		}
	}
	function fncValidateEmployeeNo() {
		if ( isNull(srchFormUtil.getValue("employeeNo")) ) {
			Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.employeeNo'/>" />');
			return false;
		}
		return true;
	}
	//band 팝업 호출
	function fncPopupBand() { 
		if ( !fncValidateEmployeeNo() ) return ;
    	var popupData = myForm.popupInfo.bandPopup;
    	popupData.employeeNo = srchFormUtil.getValue("employeeNo");
    	popupData.searchFlag = "Y";
    	
    	var popup = new Popup( myForm,'lgvhr', 'M_LGVPAY_1025', '<lgcom:message code="label.pay.bandHistory"/>' );
        popup.setSize(800,494);
        popup.open( function() {});
	}
	//dependant 팝업 호출
	function fncPopupDependant() { 
		if ( !fncValidateEmployeeNo() ) return ;
    	var popupData = myForm.popupInfo.dependantPopup;
    	popupData.employeeNo = srchFormUtil.getValue("employeeNo");
    	popupData.searchFlag = "Y";
    	
    	var popup = new Popup( myForm,'lgvhr', 'M_LGVPAY_1026', '<lgcom:message code="label.pay.dependantInfo"/>' );
        popup.setSize(800,494);
        popup.open( function() {});
	}
	//contract 팝업 호출
	function fncPopupContract() { 
		if ( !fncValidateEmployeeNo() ) return ;
    	var popupData = myForm.popupInfo.contractPopup;
    	popupData.employeeNo = srchFormUtil.getValue("employeeNo");
    	popupData.searchFlag = "Y";
    	
    	var popup = new Popup( myForm,'lgvhr', 'M_LGVPAY_1027', '<lgcom:message code="label.pay.contractInfo"/>' );
        popup.setSize(800,494);
        popup.open( function() {});
	}
	//qualification 팝업 호출
	function fncPopupQualification() { 
		if ( !fncValidateEmployeeNo() ) return ;
    	var popupData = myForm.popupInfo.qualificationPopup;
    	popupData.employeeNo = srchFormUtil.getValue("employeeNo");
    	popupData.searchFlag = "Y";
    	
    	var popup = new Popup( myForm,'lgvhr', 'M_LGVPAY_1028', '<lgcom:message code="label.pay.qualificationInfo"/>' );
        popup.setSize(800,494);
        popup.open( function() {});
	}
	//assignment history 팝업 호출
	function fncPopupAssignment() { 
		if ( !fncValidateEmployeeNo() ) return ;
    	var popupData = myForm.popupInfo.assignmentPopup;
    	popupData.employeeNo = srchFormUtil.getValue("employeeNo");
    	popupData.searchFlag = "Y";
    	
    	var popup = new Popup( myForm,'lgvhr', 'M_LGVPAY_1029', '<lgcom:message code="label.pay.assignmentHistory"/>' );
        popup.setSize(1000,494);
        popup.open( function() {});
	}
	//span 값 초기화
	function fncClearSpan( sClassName ){
		//헤더 제외한 데이터 영역만 초기화
		myForm.select("."+sClassName).find("span[name]").each(function(inx) {
			$(this).text("");
		});
	}
	//컨텐츠 영역 값 초기화.
	function fncContentInit() {
		fncClearSpan("basicInfoBlock");
		fncClearSpan("paymentBasicInfoBlock");
		fncClearSpan("paymentInfoBlock");
		paymentBasicFormUtil.clear();
	}
	//payment master 조회
	function fncRetrievePaymentMasterData() {
		fncContentInit();
		myForm.showProgress();
		myForm.transaction("lgvhr", "lgvpay/LGVPAY00010/retrievePaymentMasterData", srchFormUtil.getValue(), function (data) {
			myForm.hideProgress();
			if ( data.result ) {
				basicFormUtil.setValue(data.result);
				paymentBasicFormUtil.setValue(data.result);
				paymentFormUtil.setValue(data.result);
				
				myForm.select("button[data-action='assignmentHistory']").removeAttr("disabled");
				myForm.select("button[data-action='save']").removeAttr("disabled");
			}
		}, function () {
			myForm.hideProgress();
		});
	}
	//payment basic info 저장
	function fncUpdatePaymentBasicData() {
		Message.confirm( "<lgcom:message code="question.save"/>", function() {
			myForm.showProgress();
			var param = { employeeNo    : srchFormUtil.getValue("employeeNo")
					    , insStartMonth : nvl(paymentBasicFormUtil.getValue("insStartMonth"))
					    , pitManualFlag : nvl(paymentBasicFormUtil.getValue("pitManualFlag"))
			            };
			myForm.transaction("lgvhr", "lgvpay/LGVPAY00010/updatePaymentBasicData", param, function (data) { 
				myForm.hideProgress();
				Message.alert("<lgcom:message code="note.saved"/>");
			}, function () {
				myForm.hideProgress();
			});
		});<%-- //Message.confirm --%>
	}
	
	//전달된 파라메터가 있는 경우 화면 조회
	if ( !isNull(reqParam.employeeNo) && !isNull(reqParam.effectiveDate) ) {
		fncSearchData();
	}
}

LGVPAY00010.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVPAY00010();
		form.init();		
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2><lgcom:message code="label.pay.paymentMasterByEmployee"/></h2>
		</div>
		<div class="searchBlock">
			<form class="form search-wrap" method="post">
				<table class="table" >
					<colgroup>
						<col width="120"></col>
						<col width="110"></col>
						<col width="160"></col>
						<col width="200"></col>
						<col width="150"></col>
						<col width="100"></col>
						<col width="*"></col>
					</colgroup>
					<tbody>
						<tr>
		                	<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.pay.employeeNo" /></label></th>
							<td>
		                		<div class="input-group input-group-sm input-search">
	                                <input class="form-control input-sm" name="employeeNo" type="text" />
	                                <span class="input-group-btn">
	                                    <button class="btn btn-default ico-lgd" type="button" data-action="openPopupEmployee">
	                                        <span class="fa fa-search" aria-hidden="true"></span>
	                                    </button>
	                                </span>
	                            </div>
		                	</td>
							<th><label><lgcom:message code="label.pay.employeeName" /></label></th>
							<td>
		                		<div class="input-group input-group-sm input-search">
		                			<input type="text" class="form-control input-sm" name="employeeName" />
	                                <span class="input-group-btn">
	                                    <button class="btn btn-default ico-lgd" type="button" data-action="openPopupEmployee">
	                                        <span class="fa fa-search" aria-hidden="true"></span>
	                                    </button>
	                                </span>
	                            </div>
	                        </td>
							<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.pay.effectiveDate" /></label></th>
							<td>
								<span class="form-inline">
								    <input type="text" class="form-control input-sm input-require size_80" name="effectiveDate" placeholder="dd/mm/yyyy" readonly />
								    <button type="button" class="btn btn-ico" aria-label="calendar">
								        <span class="ico ico-calendar" aria-hidden="true"></span>
								    </button>
								</span>
							</td>
							<td></td>
						</tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
			</form>
		</div>
		<%-- //searchBlock --%>
		
		<div class="buttonControlBlock module-group text-right">
			<div class="btn-group">
				<button class="btn btn-default btn-sm" type="button" data-action="assignmentHistory" disabled><lgcom:message code="button.pay.assignmentHistory"/></button>
				<button class="btn btn-gray btn-sm" type="button" data-action="save" disabled><lgcom:message code="Save"/></button>
			</div>
		</div>
		<%-- //buttonControlBlock --%>
		
		<div class="row basicInfoBlock">
			<div class="sub-header"><h4><lgcom:message code="label.pay.basicInformation"/></h4></div>
	    	<table class="table table-condensed table-bordered" summary="Basic Information">
	        	<caption class="sr-only-lgd">Basic Information</caption>
				<colgroup>
					<col width="12%"></col>
					<col width="13%"></col>
					<col width="12%"></col>
					<col width="13%"></col>
					<col width="12%"></col>
					<col width="13%"></col>
					<col width="12%"></col>
					<col width="*"></col>
				</colgroup>
				<tbody>
					<tr>
						<th scope="col"><label><lgcom:message code="label.pay.employeeNo"/></label></th>
						<td><span name="employeeNo"></span></td>
						<th scope="col"><label><lgcom:message code="label.pay.employeeName"/></label></th>
						<td><span name="employeeName"></span></td>
						<th scope="col"><label><lgcom:message code="label.pay.organization"/></label></th>
						<td colspan="3"><span name="organizationName"></span></td>
					</tr>
					<tr>
						<th scope="col"><label><lgcom:message code="label.pay.empCategory"/></label></th>
						<td><span name="empCategoryName"></span></td>
						<th scope="col"><label><lgcom:message code="label.pay.grade"/></label></th>
						<td><span name="gradeCode"></span></td>
						<th scope="col"><label><lgcom:message code="label.pay.jobTitle"/></label></th>
						<td><span name="jobTitleName"></span></td>
						<th scope="col"><label><lgcom:message code="label.pay.jobGroup"/></label></th>
						<td><span name="jobGroup"></span></td>
					</tr>
					<tr>
						<th scope="col"><label><lgcom:message code="label.pay.shiftType"/></label></th>
						<td><span name="shiftType"></span></td>
						<th scope="col"><label><lgcom:message code="label.pay.hireDate"/></label></th>
						<td><span name="hireDate"></span></td>
						<th scope="col"><label><lgcom:message code="label.pay.resignationDate"/></label></th>
						<td><span name="resignationDate"></span></td>
						<th scope="col"><label><lgcom:message code="label.pay.probationEndDate"/></label></th>
						<td><span name="probationEndDate"></span></td>
					</tr>
				</tbody>
			</table>
		</div>
		<%-- //basicInfoBlock --%>
		
		<div class="row paymentBasicInfoBlock">
			<div class="sub-header"><h4><lgcom:message code="label.pay.paymentBasicInfo"/></h4></div>
			<form>
	    	<table class="table table-condensed table-bordered" summary="Payment Master Basic Information">
	        	<caption class="sr-only-lgd">Payment Master Basic Information</caption>
				<colgroup>
					<col width="12%"></col>
					<col width="13%"></col>
					<col width="12%"></col>
					<col width="13%"></col>
					<col width="12%"></col>
					<col width="13%"></col>
					<col width="12%"></col>
					<col width="*"></col>
				</colgroup>
				<tbody>
					<tr>
						<th>
							<label><lgcom:message code="label.pay.band"/></label>
                            <button class="btn btn-link ico-lgd" type="button" data-action="band">
                                <span class="fa fa-search" aria-hidden="true"></span>
                            </button>
						</th>
						<td><span name="band"></span></td>
						<th scope="col">
							<label><lgcom:message code="label.pay.dependant"/></label>
                            <button class="btn btn-link ico-lgd" type="button" data-action="dependant">
                                <span class="fa fa-search" aria-hidden="true"></span>
                            </button>
						</th>
						<td><span name="dependantCount"></span></td>
						<th scope="col">
							<label><lgcom:message code="label.pay.contractType"/></label>
                            <button class="btn btn-link ico-lgd" type="button" data-action="contract">
                                <span class="fa fa-search" aria-hidden="true"></span>
                            </button>
						</th>
						<td><span name="contractType"></span></td>
						<th scope="col">
							<label><lgcom:message code="label.pay.qualification"/></label>
                            <button class="btn btn-link ico-lgd" type="button" data-action="qualification">
                                <span class="fa fa-search" aria-hidden="true"></span>
                            </button>
						</th>
						<td><span name="qualification"></span></td>
					</tr>
					<tr>
						<th scope="col"><label><lgcom:message code="label.pay.insStartMonth"/></label></th>
						<td><input type="text" class="form-control input-sm size_70" name="insStartMonth" maxlength="7" placeholder="<lgcom:message code="placeholder.pay.mmyyyy"/>" /></td>
						<th scope="col"><label><lgcom:message code="label.pay.pitManualFlag"/></label></th>
						<td><select class="form-control input-sm size_80" id="pitManualFlag" name="pitManualFlag"></select></td>
						<th scope="col"><label><lgcom:message code="label.pay.bankName"/></label></th>
						<td><span name="bankName"></span></td>
						<th scope="col"><label><lgcom:message code="label.pay.accountNumber"/></label></th>
						<td><span name="accountNumber"></span></td>
					</tr>
				</tbody>
			</table>
			</form>
		</div>
		<%-- //paymentBasicInfoBlock --%>
		
		<div class="row paymentInfoBlock">
			<div class="sub-header"><h4><lgcom:message code="label.pay.paymentInformation"/></h4></div>
	    	<table class="table table-condensed table-bordered" summary="Payment Information">
	        	<caption class="sr-only-lgd">Payment Information</caption>
				<colgroup>
					<col width="20%"></col>
					<col width="20%"></col>
					<col width="20%"></col>
					<col width="20%"></col>
					<col width="*"></col>
				</colgroup>
				<tbody>
					<tr>
						<th scope="row"><label><lgcom:message code="label.pay.baseSalary"/></label></th>
						<th scope="row"><label><lgcom:message code="label.pay.baseSalary"/></label></th>
						<td class="text-right"><span name="baseSalary"></span></td>
						<th scope="row"><label><lgcom:message code="label.pay.probSalary"/></label></th>
						<td class="text-right"><span name="probationBaseSalary"></span></td>
					</tr>
					<tr>
						<th scope="row" rowspan="3"><label><lgcom:message code="label.pay.fixedAllowance"/></label></th>
						<th scope="row"><label><lgcom:message code="label.pay.jobAllowance"/></label></th>
						<td class="text-right"><span name="jobAllowance"></span></td>
						<th scope="row"><label><lgcom:message code="label.pay.adjustment1Allowance"/></label></th>
						<td class="text-right"><span name="adjustment1Allowance"></span></td>
					</tr>
					<tr>
						<th scope="row"><label><lgcom:message code="label.pay.positionAllowance"/></label></th>
						<td class="text-right"><span name="positionAllowance"></span></td>
						<th scope="row"><label><lgcom:message code="label.pay.adjustment2Allowance"/></label></th>
						<td class="text-right"><span name="adjustment2Allowance"></span></td>
					</tr>
					<tr>
						<th scope="row"><label><lgcom:message code="label.pay.qualificationAllowance"/></label></th>
						<td class="text-right"><span name="qualificationAllowance"></span></td>
						<th scope="row"><label><lgcom:message code="label.pay.adjustment3Allowance"/></label></th>
						<td class="text-right"><span name="adjustment3Allowance"></span></td>
					</tr>
				</tbody>
			</table>
		</div>
		<%-- //paymentInfoBlock --%>
				
	</section>
</div>
</body>
</html>
