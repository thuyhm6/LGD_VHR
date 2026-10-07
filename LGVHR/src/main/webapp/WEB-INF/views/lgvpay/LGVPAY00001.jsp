<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY00001.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 임직원 또는 급여담당자가 급여명세서를 조회하는 화면입니다.
    작성자 : 임수진	
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title><lgcom:message code="label.pay.paySlip.paySlip"/></title>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<style type="text/css">
.incomeDeductionTable > thead > tr > th.spaceTD {/*income, deduction 구분하기 위한 스타일 */
	background-color:#ffffff;
    width:10px;/*해당 픽셀만큼 넓이 주기 위해 내용에 html 주석 구문 넣음 */
    padding:0px;
    border-bottom:0px none;/*헤더와 내용 영역 구분선 안보이기 위한 설정 */
	font-size:0px;
}
.incomeDeductionTable > tbody > tr > td.spaceTD {/*income, deduction 구분하기 위한 스타일 */
	background-color:#ffffff;
    width:10px;
    padding:0px;
    border-top:0px none;/*헤더와 내용 영역 구분선 안보이기 위한 설정 */
    border-bottom:0px none;/*헤더와 내용 영역 구분선 안보이기 위한 설정 */
	font-size:0px;
}
.incomeDeductionTable > tbody > tr > td[data-tooltip-visible="Y"] {
	cursor:pointer;/* 레이어 팝업 보여주는 경우만 커서 변경 */
}
.adjustmentPopupWindow .adjustmentWindow,
.contributionPitPopupWindow .contributionPitWindow,
.salaryChangeInfoPopupWindow .salaryChangeInfoWindow {
	width : 350px;
	height : 220px;
	position : fixed;/*팝업윈도우 위치변경하기 위해 반드시 fixed 속성부여해야함 */
	top : 100px;
	left : calc( 50% - 150px);
	overflow : auto;
	display:none;
	z-index:1100;
}
.calculationDetailPopupWindow .calculationDetailWindow {
	width : 600px;
	height : 300px;
	position : fixed;/*팝업윈도우 위치변경하기 위해 반드시 fixed 속성부여해야함 */
	top : 100px;
	left : calc( 50% - 150px);
	overflow : auto;
	display:none;
	z-index:1100;
}
.retroactivePayrollDetailPopupWindow .retroactivePayrollDetailWindow {
	width : 600px;
	height : 300px;
	position : fixed;/*팝업윈도우 위치변경하기 위해 반드시 fixed 속성부여해야함 */
	top : 100px;
	left : calc( 50% - 150px);
	overflow : auto;
	display:none;
	z-index:1100;
}
.adjustmentPopupWindow .adjustmentWindow .modal-header,
.calculationDetailPopupWindow .calculationDetailWindow .modal-header,
.contributionPitPopupWindow .contributionPitWindow .modal-header,
.salaryChangeInfoPopupWindow .salaryChangeInfoWindow .modal-header,
.retroactivePayrollDetailPopupWindow .retroactivePayrollDetailWindow .modal-header  {
	cursor : move;
}
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<%-- 급여 담당자 권한이 있는지 여부 체크 --%>
<c:set var="payAuthTypeCode" value=""/>
<c:if test="${ not empty urlAddr.authGroup and urlAddr.authGroup eq 'MASTER' }"><%--권한그룹이 MASTER인 경우 마스터 권한이 있는지 체크한다. --%>
<c:forEach var="roles" items="${sessionScope.USER_SESSION.roleList}">
    <c:if test="${roles.systemCode=='LGVHR' and roles.moduleCode=='LGVPAY' and (fn:indexOf(roles.roleCode,'VN_PAY_MASTER_USER')>-1 or fn:indexOf(roles.roleCode,'VN_PAY_SYSTEM_MASTER_USER')>-1) }">
        <c:set var="payAuthTypeCode" value="MASTER"/>
    </c:if>
</c:forEach>
</c:if>

<%-- 급여 담당자 권한이 있는지 여부 체크 --%>
<script type="text/javascript">
var LGVPAY00001 = function() {
	var myForm = this;
	// Form Util 선언
	var srchFormUtil         = new FormUtil( myForm, ".searchBlock form" );

	//toolip drag
	$(".adjustmentWindow").draggable({
		handle : ".modal-header", /* 레이어팝업의 헤더 영역클릭한 경우만 drag 가능 */
		containment : "document",
		stop : function(){
			var sideBarObj = $("aside.sidebar");
			var contentLeft = ( sideBarObj.hasClass("closed") )?0:sideBarObj.width();/* left menu close 된 경우 0px, 아닌 경우 left menu width */
			
			if( $(this).offset().top <= 0 ) {/* 레이어팝업의 top position이 0보다 작은 경우 20px위치로 고정 */
				$(this).css({ top: '30px' });
			
			}
			if( $(this).offset().left <= contentLeft ) {/* 레이어팝업의 left position이 left menu 위치보다 작은 경우 left menu width + 20px 위치로 고정 */
				$(this).css({ left: (contentLeft+30)+'px' });
			}
		}});
	//etc - adjustment 팝업 숨김
	fncHideToolTipWindow('adjustment');
	
	<%-- 급여담당자인 경우 보여주는 툴팁에 대한 처리 --%>
	<c:if test="${ payAuthTypeCode eq 'MASTER'}">
	//toolip drag
	$(".calculationDetailWindow").draggable({
		handle : ".modal-header", /* 레이어팝업의 헤더 영역클릭한 경우만 drag 가능 */
		containment : "document",
		stop : function(){
			var sideBarObj = $("aside.sidebar");
			var contentLeft = ( sideBarObj.hasClass("closed") )?0:sideBarObj.width();/* left menu close 된 경우 0px, 아닌 경우 left menu width */

			if( $(this).offset().top <= 0 ) {/* 레이어팝업의 top position이 0보다 작은 경우 20px위치로 고정 */
				$(this).css({ top: '30px' });
			}
			if( $(this).offset().left <= contentLeft ) {/* 레이어팝업의 left position이 left menu 위치보다 작은 경우 left menu width + 20px 위치로 고정 */
				$(this).css({ left: (contentLeft+30)+'px' });
			}
		}});
	$(".contributionPitWindow").draggable({
		handle : ".modal-header", /* 레이어팝업의 헤더 영역클릭한 경우만 drag 가능 */
		containment : "document",
		stop : function(){
			var sideBarObj = $("aside.sidebar");
			var contentLeft = ( sideBarObj.hasClass("closed") )?0:sideBarObj.width();/* left menu close 된 경우 0px, 아닌 경우 left menu width */
			
			if( $(this).offset().top <= 0 ) {/* 레이어팝업의 top position이 0보다 작은 경우 20px위치로 고정 */
				$(this).css({ top: '30px' });
			}
			if( $(this).offset().left <= contentLeft ) {/* 레이어팝업의 left position이 left menu 위치보다 작은 경우 left menu width + 20px 위치로 고정 */ 
				$(this).css({ left: (contentLeft+30)+'px' });
			}
		}});
	$(".salaryChangeInfoWindow").draggable({
		handle : ".modal-header", /* 레이어팝업의 헤더 영역클릭한 경우만 drag 가능 */
		containment : "document",
		stop : function(){
			var sideBarObj = $("aside.sidebar");
			var contentLeft = ( sideBarObj.hasClass("closed") )?0:sideBarObj.width();/* left menu close 된 경우 0px, 아닌 경우 left menu width */

			if( $(this).offset().top <= 0 ) {/* 레이어팝업의 top position이 0보다 작은 경우 20px위치로 고정 */
				$(this).css({ top: '30px' });
			}
			if( $(this).offset().left <= contentLeft ) {/* 레이어팝업의 left position이 left menu 위치보다 작은 경우 left menu width + 20px 위치로 고정 */
				$(this).css({ left: (contentLeft+30)+'px' });
			}
		}});
	$(".retroactivePayrollDetailWindow").draggable({
		handle : ".modal-header", /* 레이어팝업의 헤더 영역클릭한 경우만 drag 가능 */
		containment : "document",
		stop : function(){
			var sideBarObj = $("aside.sidebar");
			var contentLeft = ( sideBarObj.hasClass("closed") )?0:sideBarObj.width();/* left menu close 된 경우 0px, 아닌 경우 left menu width */

			if( $(this).offset().top <= 0 ) {/* 레이어팝업의 top position이 0보다 작은 경우 20px위치로 고정 */
				$(this).css({ top: '30px' });
			}
			if( $(this).offset().left <= contentLeft ) {/* 레이어팝업의 left position이 left menu 위치보다 작은 경우 left menu width + 20px 위치로 고정 */
				$(this).css({ left: (contentLeft+30)+'px' });
			}
		}});
	//Calculation Detail 팝업 숨김
	fncHideToolTipWindow('calculationDetail');
	fncHideToolTipWindow('contributionPit');
	fncHideToolTipWindow('salaryChangeInfo');
	fncHideToolTipWindow('retroactivePayrollDetail');
	</c:if>
	<%-- 급여담당자인 경우 보여주는 툴팁에 대한 처리 --%>
	
	// 테이블 헤더 개행 처리
	myForm.select(".deductionBlock>table>tbody>tr>th").each(function(){
		$(this).find(">label").html($(this).find(">label").html().replace(/(\\n)/gi,'<br/>'));
	});
	// deduction 영역 개행된 높이 만큼 payment 영역 높이 조정
	myForm.select(".paymentBlock>table>tbody>tr>th:last-child").css({height:myForm.select(".deductionBlock>table>tbody>tr>th:last-child").outerHeight()});
	
    // 화면 레이아웃 정의(달력 그린 후 레이아웃 지정하기 위해 마지막에 수행함.)
	myForm.setLayout( [ 
		{ name : "searchBlock",             left : 0, right : 0, top : 0 },
		{ name : "employeeInfoBlock",       left : 0, right : 0, top : "searchBlock",             bottom : "contractSalaryInfoBlock" },
	    { name : "contractSalaryInfoBlock", left : 0, right : 0, top : "employeeInfoBlock",       bottom : "salaryDetailBlock" },
	    { name : "salaryDetailBlock",       left : 0, right : 0, top : "contractSalaryInfoBlock", bottom : "buttonControlBlock" },
		{ name : "buttonControlBlock",      left : 0, right : 0, top : "salaryDetailBlock",       bottom : "incomeDeductionBlock"},
	    { name : "incomeDeductionBlock",    left : 0, right : 0, top : "buttonControlBlock",      bottom : "bankNSalaryBlock" },
	    { name : "bankNSalaryBlock",        left : 0, right : 0, top : "incomeDeductionBlock",    bottom : "policyBlock" },
	    { name : "policyBlock",             left : 0, right : 0, bottom : 0 }
	]);

    // 그리드선언

    // 개인화조건
    
    // 조회조건 저장 처리
    myForm.searchConditionControl( true );
    
    // 팝업 데이터 정의 searchMode:single(단수),multi(복수)
	myForm.popupInfo = {
		executionListPopup : {searchMode:'single', payMonthName :'', payTypeCode:'', searchFlag:'', executionData:[]},
		userPopup          : {searchMode:'single', popupKind:'', confirmKind:'', employeeNo:'', employeeName:'', attDate:'', flsaYn:'N', fseYn:'N', attDate:'', userData:[]}
	};

    // 그리드형 테이블 TR

    // 코드 데이터 조회
    <c:if test="${empty payAuthTypeCode}"><%-- 일반 임직원 권한인 경우만 조회함 --%>
    var valueset = new ValueSet("lgcom");
	valueset.add("payTypeList", {valueSetId : "LGVPAY_PAYSLIP_PAY_TYPE_LIST", employeeNo:"${sessionScope.LGVHR_PROJECT_SESSION.employeeNo}", languageCode:SESSION_USER.languageCode});
	valueset.execute();
	
	//콤보 초기화
	srchFormUtil.initCombo("payrollCalculationExecId", valueset.get("payTypeList"), {selectAll:false});
    </c:if>
    
    // 날짜 팝업창
    
    // 필수항목 체크
   	var validator = new Validator( myForm, ".searchBlock form" );
    

    validator.setRule( {
    	/*tooltip_options: {placement: 'right'},*/
	    rules: {
	    	payrollCalculationExecId:{required:true}
    		<c:if test="${payAuthTypeCode eq 'MASTER'}">
	       ,employeeNo:{required:true}
    		</c:if>
	    },
	    messages: {
	        <c:choose>
			<c:when test="${payAuthTypeCode eq 'MASTER'}">
	    	payrollCalculationExecId: {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.executionId'/>" />'}
	       ,employeeNo: {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.employeeNo'/>" />'}
	 		</c:when>
	 		<c:otherwise>
	    	payrollCalculationExecId: {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.paySlip.payType'/>" />'}
	 		</c:otherwise>
	 		</c:choose>
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
					var param = {payrollCalculationExecId : srchFormUtil.getValue("payrollCalculationExecId")
							   , employeeNo               : srchFormUtil.getValue("employeeNo")
							   , authGroup                : "<c:out value="${urlAddr.authGroup}"/>"
							    };
					var actionName = "lgvpay/LGVPAY00001/retrieveValidatePayrollCalcExecId";
					<c:if test="${ payAuthTypeCode eq 'MASTER' }"><%-- 급여담당자인 경우 --%>
					actionName = "lgvpay/LGVPAY00001/retrieveValidateMasterPayrollCalcExecId";
					</c:if>
					myForm.transaction("lgvhr", actionName, param, function(data) {
						if ( data.result ) {
							//데이터 조회
							fncRetrievePaySlipData();
						} else {
							Message.alert("<lgcom:message code="note.NoPermission"/>");
							return ;
						}
					});
				}
				break;
				
			// Execution List 팝업
		    case "openPopupExecutionList" :
		    	var popupData = myForm.popupInfo.executionListPopup;
		    	popupData.payMonthName = srchFormUtil.getValue("payMonth");
		    	popupData.searchFlag = "Y";

                var popup = new Popup( myForm,'lgvhr', 'M_LGVPAY_1019', '<lgcom:message code="label.pay.executionList"/>' );
                popup.setSize(800,494);
                popup.open( function() {
                	if ( popupData.executionData != null && popupData.executionData.length > 0 ) {
                		var selectData = popupData.executionData[0];
                		
                		srchFormUtil.setValue({ payrollCalculationExecId : selectData.payrollCalculationExecId
                			                  , payMonth                 : selectData.payMonthName
                			                  , payType                  : selectData.payTypeName });
                		//검색조건 값이 있는 경우 데이터 조회
                		fncSearchData();
                	}
                });
                popupData.executionData = [];
                break;
			
			// 유저 검색 팝업
		    case "openPopupEmployee" :
		    	fncPopupEmployeeSearch();
                break;
               
            // calucatiion detail layer popup
		    case "calculationDetail":
		    	var tdPosition = {top       : Math.round($(this).offset().top)
		    			        , left      : Math.round($(this).offset().left)
		    			        , height    : Math.round($(this).outerHeight())
		    			        , width     : Math.round($(this).outerWidth())
		    			        , titleName : $.trim(item.text())
		    			        , popupName : $.trim(item.data('target'))};
		    	//상세내용 팝업 보여줌
		    	fncShowToolTipWindow(tdPosition);
		    	break;
	               
            // contribution/PIT layer popup
		    case "enterprize":
		    	var oTD = item.parent("th");
		    	var tdPosition = {top       : Math.round($.trim(oTD.offset().top))
		    			        , left      : Math.round($.trim(oTD.offset().left))
		    			        , height    : Math.round($.trim(oTD.outerHeight()))
		    			        , width     : Math.round($.trim(oTD.outerWidth()))
		    			        , titleName : $.trim(oTD.find(">span").text()) /* button객체가 있는 th의 값 */
		    			        , popupName : $.trim(item.data('target'))};
		    	//상세내용 팝업 보여줌
		    	fncShowToolTipWindow(tdPosition);
		    	break;
	               
            // salary change info layer popup
		    case "salaryChangeInfo":
		    	var tdPosition = {top       : Math.round($(this).offset().top)
		    			        , left      : Math.round($(this).offset().left)
		    			        , height    : Math.round($(this).outerHeight())
		    			        , width     : Math.round($(this).outerWidth())
		    			        , titleName : $.trim(item.text())
		    			        , popupName : $.trim(item.data('target'))};
		    	//상세내용 팝업 보여줌
		    	fncShowToolTipWindow(tdPosition);
		    	break;
		    	
		    // retroactive payroll detail layer popup
		    case "retroactivePayrollDetail":
		    	var tdPosition = {top       : Math.round($(this).offset().top)
		    			        , left      : Math.round($(this).offset().left)
		    			        , height    : Math.round($(this).outerHeight())
		    			        , width     : Math.round($(this).outerWidth())
		    			        , titleName : $.trim(item.text())
		    			        , popupName : $.trim(item.data('target'))};
		    	//상세내용 팝업 보여줌
		    	fncShowToolTipWindow(tdPosition);
		    	break;
		}
		event.stopPropagation();
	});
	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});
    //사번 또는 성명 클릭 시 값 초기화
    myForm.addEvent ( "click", ".searchBlock form input[name='employeeNo'], input[name='employeeName']", function(event) {
    	//fncSearchEmpInfoInit();
		event.stopPropagation();
    });
	myForm.addEvent ( "change",".searchBlock form",function(event) {
		var item = $(event.target);
		switch ( $.trim(item.attr("name")) ) {
			case "employeeNo" :
				//사번이 변경된 경우 성명 초기화 처리
				if ( srchFormUtil.getPreviousValue("employeeNo") != srchFormUtil.getValue("employeeNo") || isNull(srchFormUtil.getValue("employeeNo")) ) {
					srchFormUtil.setValue({employeeName:""});
				}
			
				//검색조건 사번이 있는 경우 임직원 검색 팝업 호출
				if ( !isNull(srchFormUtil.getValue("employeeNo")) ) {
					//fncPopupEmployeeSearch();//사번 또는 성명 값 변경되는 경우 임직원 검색
				}
				break;
			case "employeeName" :
				//성명이 변경된 경우 사번 초기화 처리
				if ( srchFormUtil.getPreviousValue("employeeName") != srchFormUtil.getValue("employeeName") || isNull(srchFormUtil.getValue("employeeName")) ) {
					srchFormUtil.setValue({employeeNo:""});
				}
			
				//검색조건 성명이 있는 경우 임직원 검색 팝업 호출
				if ( !isNull(srchFormUtil.getValue("employeeName")) ) {
					//fncPopupEmployeeSearch();//사번 또는 성명 값 변경되는 경우 임직원 검색
				}
				break;
			case "payrollCalculationExecId" :
				fncSearchData();//데이터 조회
				break;
		}
		event.stopPropagation();
	});
	myForm.addEvent ( "keyup",".searchBlock form input[name='employeeNo'], input[name='employeeName']",function(event) {
		//var val = $.trim($(this).val());
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
    //Etc - Adjustment 클릭 이벤트 처리
    myForm.addEvent( "click", ".incomeDeductionTable td[data-tooltip-visible='Y']", function(event) {
    	var tdPosition = {top       : Math.round($(this).offset().top)
    			        , left      : Math.round($(this).offset().left)
    			        , height    : Math.round($(this).outerHeight())
    			        , width     : Math.round($(this).outerWidth())
    			        , titleName : $(this).text()
    			        , popupName : "adjustment"};
    	//상세내용 팝업 보여줌
    	fncShowToolTipWindow(tdPosition);
		event.stopPropagation();
    });
    //Etc - Adjustment 팝업 닫기 클릭 이벤트 처리
    myForm.addEvent( "click", "._close", function(event) {
    	var item = $(event.target);
    	fncHideToolTipWindow($.trim(item.data("target")));
		event.stopPropagation();
    });
	/*** 내부 함수  ***/	
	//salary detail 리스트 그리기
	function fncDrawSalaryDetailList() {
		<%-- Income / Deduction Display Logic
		     - Income 2개 영역과 Deduction 1개영역 총 3개로 구성되어 있고, 3개의 행수를 일치시키기 위해 각 영역별로 데이터를 조회한다.
		       - Income 시간 없는 항목 리스트 조회
		       - Income 시간 있는 항목 리스트 조회
		       - Deduction 항목 리스트 조회
		     - 3개 영역 리스트 중 가장 큰 행 수 loop
		       - 1차항목이 마지막 행인 경우 전체 행수만큼 병합.
		       - 금액이 0인 경우 2차항목, 시간/일, 금액 표기하지 않음. 단, Income 시간있는 항목인 경우 OT 이므로 2차항목 보여줌.
		       - Deduction항목인 경우 시간/일자를 구분하지 않는 행인 경우 셀병합.
		       -               "                  구분하는 경우 시간 또는 일자와 단위를 표기함.
		     - 3개 영역 리스트 중 가장 큰 행 수 end loop
		     - 3개 영역 sub-total 표기
		--%>
		var listDiv = myForm.select(".incomeDeductionBlock");
		var listTbody = listDiv.find(">table>tbody");
		var rowCount = Math.max(Math.max(incomeTimeNList.length, incomeTimeYList.length), deductionList.length);//화면에 출력해야할 row 최대 개수

		//tr 삭제
		fncDeleteTableRow(listTbody);

		var tr = "", deductionTimeUnit = "";
		var incomeTimeNRowSpan = 1, incomeTimeYRowSpan = 1, deductionRowSpan = 1;
		var deductionColSpan = 1;
		var incomeTimeNData = {};
		var incomeTimeYData = {};
		var deductionData = {};

		for ( var i=0; i<rowCount; i++ ) {
			incomeTimeNData = (incomeTimeNList.length>i)?incomeTimeNList[i]:{};
			incomeTimeYData = (incomeTimeYList.length>i)?incomeTimeYList[i]:{};
			deductionData   = (deductionList.length>i)?deductionList[i]:{};	

			tr = "<tr>";
			//Income(TIME_N)
			if ( incomeTimeNList.length == 0 ) {//데이터가 없는 경우 전체 행수만큼 병합하여 보여준다.
				tr += "<th class='text-center' rowspan='"+rowCount+"'></th>";
				
			} else if ( nvl(incomeTimeNData["rank1"]) == "1" ) {//처음 한번만 병합시킴. 단, 마지막 병합행이 rowCount보다 작은 경우 rowCount 까지 병합 처리함.
				incomeTimeNRowSpan = Number(nvl(incomeTimeNData["rowspanCnt1"], "1"));
				if ( incomeTimeNList.length == (i+Number(nvl(incomeTimeNData["rowspanCnt1"]))) ) {//row index + 병합행 수 = 데이터 건수인 경우가 마지막 병합으로 봄
					incomeTimeNRowSpan += (rowCount - incomeTimeNList.length);
				}
				tr += "<th class='text-center' rowspan='"+incomeTimeNRowSpan+"'>"+nvl(incomeTimeNData["codeName1"])+"</th>";
			}
			//Etc - Adjustment인 경우 세부항목 팝업 링크
			tr += "<td class='text-center' data-tooltip-visible='"+(nvl(incomeTimeNData["code2"])=="ADJ_INCOME"?"Y":"N")+"'>"+(nvl(incomeTimeNData["itemAmount"], "0") !="0"?nvl(incomeTimeNData["codeName2"]):"") +"</td>";//금액이 0이 아닌 경우만 표시
			tr += "<td class='text-right'>" +(nvl(incomeTimeNData["itemAmount"], "0") !="0"?nvl(incomeTimeNData["itemAmount"]):"")+"</td>";//금액이 0이 아닌 경우만 표시

			//Income(TIME_Y)
			if ( incomeTimeYList.length == 0 ) {//데이터가 없는 경우 전체 행수만큼 병합하여 보여준다.
				tr += "<th class='text-center' rowspan='"+rowCount+"'></th>";
				
			} else if ( nvl(incomeTimeYData["rank1"]) == "1" ) {//처음 한번만 병합시킴. 단, 마지막 병합행이 rowCount보다 작은 경우 rowCount 까지 병합 처리함.
				incomeTimeYRowSpan = Number(nvl(incomeTimeYData["rowspanCnt1"], "1"));
				if ( incomeTimeYList.length == (i+Number(nvl(incomeTimeYData["rowspanCnt1"]))) ) {//row index + 병합행 수 = 데이터 건수인 경우가 마지막 병합으로 봄
					incomeTimeYRowSpan += (rowCount - incomeTimeYList.length);
				}
				tr += "<th class='text-center' rowspan='"+incomeTimeYRowSpan+"'>"+nvl(incomeTimeYData["codeName1"])+"</th>";
			}
			tr += "<td class='text-center'>"+nvl(incomeTimeYData["codeName2"]) +"</td>";//overtime 관련 항목은 2차항목 모두 보여줌
			tr += "<td class='text-right'>" +(nvl(incomeTimeYData["itemAmount"], "0") !="0"?nvl(incomeTimeYData["itemHours"]):"") +"</td>";//금액이 0이 아닌 경우만 표시
			tr += "<td class='text-right'>" +(nvl(incomeTimeYData["itemAmount"], "0") !="0"?nvl(incomeTimeYData["itemAmount"]):"")+"</td>";//금액이 0이 아닌 경우만 표시

			//income 과 deduction 구분하기 위한 경계 
			tr += "<td  class='spaceTD' ><!-- --></td>";

			//Deduction
			if ( deductionList.length == 0 ) {//데이터가 없는 경우 전체 행수만큼 병합하여 보여준다.
				tr += "<th class='text-center' rowspan='"+rowCount+"'></th>";
				
			} else if ( nvl(deductionData["rank1"]) == "1" ) {//처음 한번만 병합시킴. 단, 마지막 병합행이 rowCount보다 작은 경우 rowCount 까지 병합 처리함.
				deductionRowSpan = Number(nvl(deductionData["rowspanCnt1"], "1"));
				if ( deductionList.length == (i+Number(nvl(deductionData["rowspanCnt1"]))) ) {//row index + 병합행 수 = 데이터 건수인 경우가 마지막 병합으로 봄
					deductionRowSpan += (rowCount - deductionList.length);
				}
				tr += "<th class='text-center' rowspan='"+deductionRowSpan+"'><span class='listCodeName1'>"+nvl(deductionData["codeName1"]) + "</span>";
				if ( nvl(deductionData["code1"]) == "CONT_PIT" && "<c:out value="${payAuthTypeCode}"/>" == "MASTER" ) {<%-- 1차분류코드가 Contribution/PIT이고, 급여담당자인 경우만 버튼 추가함 --%>
					tr += "<br/><button class=\"btn btn-darkgray btn-sm\" type=\"button\" data-action=\"enterprize\" data-target=\"contributionPit\"><lgcom:message code="button.pay.paySlip.enterprize"/></button>";
				}
				tr += "</th>";
			}
			if ( nvl(deductionData["timeDisplayCode"]) == "TIME_Y" ) {//시간 또는 일자를 보여주는 경우
				deductionColSpan = 1;
				deductionTimeUnit = "";
				if ( nvl(deductionData["dayHourCode"]) == "D" ) {//일자인 경우
					deductionTimeUnit = " <lgcom:message code='label.pay.paySlip.unitDay'/>";
				} else if ( nvl(deductionData["dayHourCode"]) == "H" ) {//시간인 경우
					deductionTimeUnit = " <lgcom:message code='label.pay.paySlip.unitHour'/>";
				}
			} else {//시간 또는 일자를 보여주지 않는 경우 셀병합
				deductionColSpan = 2;
				deductionTimeUnit = "";
			}
			tr += "<td class='text-center' colspan='"+deductionColSpan+"'>"+(nvl(deductionData["itemAmount"], "0") !="0"?nvl(deductionData["codeName2"]):"")+"</td>";//금액이 0이 아닌 경우만 표시
			if ( nvl(deductionData["timeDisplayCode"]) == "TIME_Y" ) {//시간 또는 일자를 보여주는 경우만 처리
			tr += "<td class='text-right'>"+(nvl(deductionData["itemAmount"], "0") !="0"?(nvl(deductionData["itemHours"])+deductionTimeUnit):"")+"</td>";//금액이 0이 아닌 경우만 표시
			}
			tr += "<td class='text-right'>"+(nvl(deductionData["itemAmount"], "0") !="0"?nvl(deductionData["itemAmount"]):"")+"</td>";//금액이 0이 아닌 경우만 표시
			tr += "</tr>";
			listTbody.append(tr);
		}<%-- //for ( var i=0; i<rowCount; i++ ) { --%>
		
		
		var sIncomeTimeNAmount = "", sIncomeTimeYAmount = "", sDeductionAmount = "";
		if ( salaryDetailData != undefined ) {//데이터가 있는 경우만 처리
			sIncomeTimeNAmount = nvl(salaryDetailData["incomeTimeNAmount"]);
			sIncomeTimeYAmount = nvl(salaryDetailData["incomeTimeYAmount"]);
			sDeductionAmount = nvl(salaryDetailData["deductionAmount"]);
		}
		<%-- sub total 영역 그리기 --%>
		var tFoot = "<tr>"+
		            "<th scope='row' colspan='2'><label class='text-lgd'><lgcom:message code="label.pay.paySlip.subTotal"/></label> ①</th>"+
		            "<td class='text-right text-lgd'>" + sIncomeTimeNAmount + "</td>"+
		            "<th scope='row' colspan='3'><label class='text-lgd'><lgcom:message code="label.pay.paySlip.subTotal"/></label> ②</th>"+
		            "<td class='text-right text-lgd'>" + sIncomeTimeYAmount + "</td>"+
					"<td class='spaceTD'><!-- --></td>"+
					"<th scope='row' colspan='3'><label class='text-lgd'><lgcom:message code="label.pay.paySlip.total"/></label> ③</th>"+
					"<td class='text-right text-lgd'>" + sDeductionAmount + "</td>"+
					"</tr>";
		listTbody.append(tFoot);
		
		//bank 영역 위치 조정
		fncChangePosition();
	}
		
	//salary detail 리스트 그리기
	function fncDrawOtherIncomeInputList() {
		
		var listDiv = myForm.select(".otherIncomeInputBlock");
		var listTbody = listDiv.find(">table>tbody");
		fncDeleteTableRow(listTbody);
		
		var rowCount = otherIncomeInputList.length;//화면에 출력해야할 row 최대 개수
		if (rowCount > 0) {
			//tr 삭제
			

			var tr = "";
			var otherIncomeInputData = {};
			var otherIncomeInputTotal = 0;

			for ( var i=0; i<rowCount; i++ ) {
				otherIncomeInputData   = (otherIncomeInputList.length>i)?otherIncomeInputList[i]:{};	
				
				tr = "<tr>";
				
				//Deduction
				tr += "<td class='text-center'>"+nvl(otherIncomeInputData["remark"])+"</td>";
				tr += "<td class='text-right'>"+nvl(otherIncomeInputData["payment"])+"</td>";
				tr += "<td class='text-center'>"+nvl(otherIncomeInputData["apNumber"])+"</td>";
				tr += "<td class='text-center'>"+nvl(otherIncomeInputData["picId"])+"</td>";
				tr += "<td class='text-center'>"+nvl(otherIncomeInputData["picName"])+"</td>";
				tr += "</tr>";
				listTbody.append(tr);
				otherIncomeInputTotal += nvl(parseFloat((otherIncomeInputData["payment"]).replace(/,/g, "").replace(/[^\d.]/g, "")));
			}
			otherIncomeInputTotal = new Intl.NumberFormat('en-US').format(otherIncomeInputTotal);
			tr = "<tr><th scope='row'><label class='text-lgd'><lgcom:message code="label.pay.paySlip.subTotal"/></label></th>";
			tr += "<td class='text-right'>"+nvl(otherIncomeInputTotal)+"</td>";
			tr += "<td class='text-center'></td>";
			tr += "<td class='text-center'></td>";
			tr += "<td class='text-center'></td>";
			tr += "</tr>";
			listTbody.append(tr);
			
			fncChangePosition();
		}
		
	}
	
	//payMonth 기준 paySlipText3/4 노출 여부 결정 (202607 이상이면 paySlipText4, 그 외에는 paySlipText3)
	function fncSetOtPolicyText(payMonth) {
		var otPolicy = myForm.select(".otPolicy");
		var payMonthNo = 0;
		if ( !isNull(payMonth) ) {
			var payMonthArr = $.trim(payMonth).split("/");//[0]:month, [1]:year
			payMonthNo = Number(payMonthArr[1]) * 100 + Number(payMonthArr[0]);//YYYYMM 형태로 변환
		}
		if ( payMonthNo >= 202607 ) {
			otPolicy.find(".paySlipText3").hide();
			otPolicy.find(".paySlipText4").show();
		} else {
			otPolicy.find(".paySlipText3").show();
			otPolicy.find(".paySlipText4").hide();
		}
	}
	
	//bank, salary total 영역 높이 조정
	function fncChangePosition() {
		var incomeDeductionBlock = myForm.select(".incomeDeductionBlock");
		var bankNSalaryBlock = myForm.select(".bankNSalaryBlock");
		var otherIncomeInputBlock = myForm.select(".otherIncomeInputBlock");
		var bankBlock = myForm.select(".bankBlock");
		var salaryBlock = myForm.select(".salaryBlock");
		var otPolicy = myForm.select(".otPolicy");
		var policyBlock = myForm.select(".policyBlock");

		//bankBlock, salaryBlock 중 더 큰 높이 + otPolicy(paySlipText3) 높이 = 우측 컬럼 전체 높이
		var rightColumnHeigh = (Number(bankBlock.height()) > Number(salaryBlock.height()) ? Number(bankBlock.height()) : Number(salaryBlock.height())) + Number(otPolicy.outerHeight(true));
		var bankNSalaryBlockHeigh =  (otherIncomeInputBlock.find(">table").height() > rightColumnHeigh) ? otherIncomeInputBlock.find(">table").height() : rightColumnHeigh;

		//income, deduction 테이블 높이 + 20 위치로 이동
		bankNSalaryBlock.css({ top : ((Number(incomeDeductionBlock.position().top) + Number(incomeDeductionBlock.find(">table").height()) + 20)) + "px" });
		policyBlock.css({ top : ((Number(bankNSalaryBlock.position().top) + Number(bankNSalaryBlockHeigh) + 20)) + "px" });
  }
	//etc-adjustment 툴팁에서 보여줄 내용 셋팅
	function fncDrawToolTipAdjustment() {
		var tBody = myForm.select(".adjustmentTable>tbody");
		//tr 삭제
		fncDeleteTableRow(tBody);
		
		if ( adjustmentList != null && adjustmentList.length > 0 ) {
			$(adjustmentList).each(function() {
				var tr = "<tr>"+
						 "	<td>"+nvl(this["elementName"])+"</td>"+
						 "	<td class=\"text-right\">"+nvl(this["elementAmount"])+"</td>"+
						 "</tr>";
				tBody.append(tr);
			});
		}
	}
	//calculation detail 툴팁에서 보여줄 내용 셋팅
	function fncDrawToolTipCalculationDetail() {
		var tBody = myForm.select(".calculationDetailTable>tbody");
		//tr 삭제
		fncDeleteTableRow(tBody);
		
		if ( calculationDetailList != null && calculationDetailList.length > 0 ) {
			$(calculationDetailList).each(function() {
				var tr = "<tr>"+
						 "	<td>"+nvl(this["inquiryName"])+"</td>"+
						 "	<td class=\"text-center\">"+ nvl(this["baseStartDate"])     +"</td>"+
						 "	<td class=\"text-center\">"+ nvl(this["baseEndDate"])       +"</td>"+
						 "	<td class=\"text-right\">" + nvl(this["paymentBaseAmount"]) +"</td>"+
						 "	<td class=\"text-right\">" + nvl(this["workingDays"])       +"</td>"+
						 "</tr>";
				tBody.append(tr);
			});
		}
	}
	//contribution/PIT 툴팁에서 보여줄 내용 셋팅
	function fncDrawToolTipContributionPit() {
		var tBody = myForm.select(".contributionPitTable>tbody");
		//tr 삭제
		fncDeleteTableRow(tBody);
		
		if ( contributionPitList != null && contributionPitList.length > 0 ) {
			$(contributionPitList).each(function() {
				var tr = "<tr>"+
						 "	<td>"+nvl(this["elementName"])+"</td>"+
						 "	<td class=\"text-right\">"+nvl(this["elementAmount"])+"</td>"+
						 "</tr>";
				tBody.append(tr);
			});
		}
	}
	//salary Change info 툴팁에서 보여줄 내용 셋팅
	function fncDrawToolTipSalaryChangeInfo() {
		var tBody = myForm.select(".salaryChangeInfoTable>tbody");
		//tr 삭제
		fncDeleteTableRow(tBody);
		
		if ( salaryChangeInfoList != null && salaryChangeInfoList.length > 0 ) {
			$(salaryChangeInfoList).each(function() {
				var tr = "<tr>"+
						 "	<td class=\"text-center\">"+nvl(this["startDate"])+"</td>"+
						 "	<td class=\"text-right\">"+nvl(this["baseAmount"])+"</td>"+
						 "</tr>";
				tBody.append(tr);
			});
		}
	}
	//retroactive payroll detail 레이어 팝업에서 보여줄 내용 셋팅
	function fncDrawToolTipRetroPayDetail() {
		var tBody = myForm.select(".retroactivePayrollDetailTable>tbody");
		//tr 삭제
		fncDeleteTableRow(tBody);
		
		if ( retroPayDetailList != null && retroPayDetailList.length > 0 ) {
			$(retroPayDetailList).each(function() {
				var tr = "<tr>"+
						 "	<td class=\"text-center\">"+nvl(this["retroactiveTargetMonth"])+"</td>"+
						 "	<td class=\"text-left\">"+nvl(this["payItemDescription"])+"</td>"+
						 "	<td class=\"text-right\">"+nvl(this["differentAmt"])+"</td>"+
						 "</tr>";
				tBody.append(tr);
			});
		}
	}
	//레이어 팝업 보여주기
	function fncShowToolTipWindow(tdPosition) {
		var popup = myForm.select("."+tdPosition.popupName+"PopupWindow ."+tdPosition.popupName+"Window");
		var popupTop = (tdPosition.top+tdPosition.height);
		var popupLeft = tdPosition.left;
		var contentBottom = $("._globalStatusBar").offset().top;//화면하단 시간 보여주는 영역
		
		//화면 크기보다 팝업bottom 이 아래인 경우 팝업을 TD 위로 보여준다.
		if ( contentBottom < (popup.outerHeight()+tdPosition.top) ) {//화면 하단 bar 영역제외하고 높이 계산하기 위해 -25
			popupTop = (tdPosition.top-popup.outerHeight());
		} else {
			popupTop = (tdPosition.top+tdPosition.height);
		}
		
		var screenWidth = $("div#${param.bizFormId}").outerWidth();//$(document).outerWidth() : document width 가 bizform div 영역보다 크게 계산되어 width 기준을 bizform 으로 변경함.
		//화면 크기보다 팝업right가 큰 경우 팝업 left 위치 조정
		if ( screenWidth < (popup.outerWidth()+tdPosition.left) ) {
			popupLeft = (tdPosition.left + tdPosition.width - popup.outerWidth());
		} else {
			popupLeft = tdPosition.left;
		}

		popup.css({top:popupTop+"px", left:popupLeft+"px"});
		
		popup.find("[name='titleName']").text(tdPosition.titleName);//팝업 타이틀에 항목명 셋팅
		popup.show();
	}
	//레이어 팝업 숨김
	function fncHideToolTipWindow(sToolTipWindowName) {
		var popup = myForm.select("."+sToolTipWindowName+"PopupWindow ."+sToolTipWindowName+"Window");
		popup.hide();
	}
	//사원검색 팝업 호출 및 값 셋팅
	function fncPopupEmployeeSearch() { 

    	var popupData = myForm.popupInfo.userPopup;
    	popupData.employeeNo = srchFormUtil.getValue("employeeNo");
    	popupData.employeeName = srchFormUtil.getValue("employeeName");
    	popupData.fseYn = "N";
    	popupData.flsaYn = "N";
    	// 오늘 날짜 넘김
    	popupData.attDate = DateUtil.today("DD/MM/YYYY");
    	//사번, 성명 inputbox 초기화
    	//fncSearchEmpInfoInit();
		//컨텐츠 영역 초기화
		fncContentInit();

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
	//조회
	function fncSearchData() {
		var isSearchFlag = false;
		
		<%-- 급여답당자인 경우 payrollCalculationExecId와 사번이 있는 경우 조회 가능 --%>
		if ( "<c:out value="${payAuthTypeCode}"/>" == "MASTER" && !isNull(srchFormUtil.getValue("payrollCalculationExecId")) && !isNull(srchFormUtil.getValue("employeeNo")) ) {
			isSearchFlag = true;
		<%-- 급여담당자 아닌 경우 payrollCalculationExecId 있는 경우 조회가능 --%>
		} else if ( "<c:out value="${payAuthTypeCode}"/>" != "MASTER" && !isNull(srchFormUtil.getValue("payrollCalculationExecId")) ) {
			isSearchFlag = true;
		}
		
		if ( isSearchFlag ) { 
			myForm.select(".searchBlock button[data-action='search']").trigger("click");
		}
	}
	//조회권한이 있는지 조회
	function fncRetrieveValidatePayrollCalcExecId() {
		var validateFlag = false;
		var param = {payrollCalculationExecId : srchFormUtil.getValue("payrollCalculationExecId")
				   , employeeNo               : srchFormUtil.getValue("employeeNo")
				   , authGroup                : "<c:out value="${urlAddr.authGroup}"/>"
				    };
		var actionName = "lgvpay/LGVPAY00001/retrieveValidatePayrollCalcExecId";
		<c:if test="${ payAuthTypeCode eq 'MASTER' }"><%-- 급여담당자인 경우 --%>
		actionName = "lgvpay/LGVPAY00001/retrieveValidateMasterPayrollCalcExecId";
		</c:if>
		myForm.transaction_sync("lgvhr", actionName, param, function(data) {
			validateFlag = data.result;
		});
		return validateFlag;
	}
	//컨텐츠 영역 값 초기화.
	function fncContentInit() {
		
		incomeTimeNList       = [];
		incomeTimeYList       = [];
		deductionList         = [];
		salaryDetailData      = {};
		adjustmentList        = [];
		calculationDetailList = [];
		contributionPitList   = [];
		salaryChangeInfoList  = [];
		retroPayDetailList	  = [];
		otherIncomeInputList  = [];
		
		fncClearSpan("employeeInfoBlock");
		fncClearSpan("contractSalaryInfoBlock");
		fncClearSpan("salaryDetailBlock");
		fncClearSpan("bankNSalaryBlock");
		
		//salary detail 항목별 금액리스트 구성
		fncDrawSalaryDetailList();
		
		fncDrawOtherIncomeInputList();
		
		//adjustment 툴팁 리스트 구성
		fncDrawToolTipAdjustment();
		//툴팁 숨김
		fncHideToolTipWindow('adjustment');
		
		<c:if test="${ payAuthTypeCode eq 'MASTER' }"><%-- 급여담당자인 경우 calucation detail popup, contribution/pit popup, retro pay detail popup 구성함 --%>
		//calculation detail 툴팁 리스트 구성
		fncDrawToolTipCalculationDetail();
		//contribution/pit 툴팁 리스트 구성
		fncDrawToolTipContributionPit();
		//salary change info 툴팁 리스트 구성
		fncDrawToolTipSalaryChangeInfo();
		//retroactive payroll detail 레이어팝업 리스트 구성
		fncDrawToolTipRetroPayDetail();
		//툴팀 숨김
		fncHideToolTipWindow('calculationDetail');
		fncHideToolTipWindow('contributionPit');
		fncHideToolTipWindow('salaryChangeInfo');
		fncHideToolTipWindow('retroactivePayrollDetail');
		</c:if>
		
		//bank 영역 위치 조정
		fncChangePosition();
	}
	//테이블 tr 객체 삭제
	function fncDeleteTableRow(tBody) {
		//tr 삭제
		tBody.empty();
	}
	//span 값 초기화
	function fncClearSpan( sClassName ){ 
		myForm.select("."+sClassName).find("span").each(function(inx) {
			$(this).text("");
		});
	}
	
	var incomeTimeNList       = [];
	var incomeTimeYList       = [];
	var deductionList         = [];
	var salaryDetailData      = {};
	var adjustmentList        = [];
	var calculationDetailList = [];
	var contributionPitList   = [];
	var salaryChangeInfoList  = [];
	var retroPayDetailList	  = [];
	var otherIncomeInputList  = [];
	//데이터 조회
	function fncRetrievePaySlipData(actionType) {
		myForm.showProgress();
		//컨텐츠 영역 초기화
		fncContentInit();
		
		var param = { payrollCalculationExecId : srchFormUtil.getValue("payrollCalculationExecId")
				    , employeeNo               : srchFormUtil.getValue("employeeNo")
				    , authGroup                : "<c:out value="${urlAddr.authGroup}"/>"
				    };
		
		var actionName = "lgvpay/LGVPAY00001/retrievePaySlipData";
		<c:if test="${ payAuthTypeCode eq 'MASTER' }"><%-- 급여담당자인 경우 --%>
		actionName = "lgvpay/LGVPAY00001/retrieveMasterPaySlipData";
		</c:if>
		
		myForm.transaction("lgvhr", actionName, param, function(data) {
			myForm.hideProgress();
			var searchData = data.result["searchData"];
			salaryDetailData = data.result["salaryDetailData"];
			incomeTimeNList = data.result["incomeTimeNList"];
			incomeTimeYList = data.result["incomeTimeYList"];
			deductionList = data.result["deductionList"];
			otherIncomeInputList = data.result["otherIncomeInputList"];
			adjustmentList = data.result["adjustmentList"];
			<c:if test="${ payAuthTypeCode eq 'MASTER' }">
			calculationDetailList = data.result["calculationDetailList"];
			contributionPitList = data.result["contributionPitList"];
			salaryChangeInfoList = data.result["salaryChangeInfoList"];
			retroPayDetailList = data.result["retroPayDetailList"];
			</c:if>

			//화면 로딩 시 최초 조회인 경우만 값 셋팅함. 검색조건에 따른 조회시는 셋팅 필요 없음.
			if ( actionType == "init" ) {
				srchFormUtil.setValue({ payrollCalculationExecId : $.trim(searchData["payrollCalculationExecId"])
					                  , payMonth                 : $.trim(searchData["payMonth"])
					                  , payType                  : $.trim(searchData["payType"]) 
					                  });
			} else {
				//타 화면에서 호출되는 경우 payrollCalculationExecId만 있으므로, 조회한 값을 셋텡해주는 처리가 필요함.
				if ( isNull(srchFormUtil.getValue("payMonth")) && !isNull($.trim(searchData["payMonth"])) ) {
					srchFormUtil.setValue({ payMonth : $.trim(searchData["payMonth"]) });
				}
				if ( isNull(srchFormUtil.getValue("payType")) && !isNull($.trim(searchData["payType"])) ) {
					srchFormUtil.setValue({ payType : $.trim(searchData["payType"]) });
				}
			}

			var employeeFormUtil     = new FormUtil( myForm, ".employeeInfoBlock");
			var contractFormUtil     = new FormUtil( myForm, ".contractSalaryInfoBlock");
			var salaryDetailFormUtil = new FormUtil( myForm, ".salaryDetailBlock");
			var bankNSalaryFormUtil  = new FormUtil( myForm, ".bankNSalaryBlock");
			
			employeeFormUtil.setValue(data.result["employeeData"]);
			contractFormUtil.setValue(data.result["contractSalaryData"]);
			salaryDetailFormUtil.setValue(salaryDetailData);
			bankNSalaryFormUtil.setValue(salaryDetailData);
			
			//paySlipText3/4 : payMonth가 202607 이상이면 paySlipText4, 그 외에는 paySlipText3 노출
			fncSetOtPolicyText($.trim(searchData["payMonth"]));
			
			//salary detail 항목별 금액리스트 구성
			fncDrawSalaryDetailList();
			
			fncDrawOtherIncomeInputList();
			
			//adjustment 툴팁 리스트 구성
			fncDrawToolTipAdjustment();
			
			<c:if test="${ payAuthTypeCode eq 'MASTER' }"><%-- 급여담당자인 경우 calucation detail popup, contribution/pit popup, retro pay detail popup 구성함 --%>
			//calculation detail 툴팁 리스트 구성
			fncDrawToolTipCalculationDetail();
			//contribution/pit 툴팁 리스트 구성
			fncDrawToolTipContributionPit();
			//salary change info 툴팁 리스트 구성
			fncDrawToolTipSalaryChangeInfo();
			//retroactive payroll detail 레이어팝업 리스트 구성
			fncDrawToolTipRetroPayDetail();
			</c:if>
		}, function () { myForm.hideProgress(); });
		
	}
	
	//전달된 파라메터가 있는 경우 해당 값을 검색조건에 셋팅한다.
	var reqParam = {payrollCalculationExecId : "<c:out value="${urlAddr.payrollCalculationExecId}"/>"
			      , employeeNo               : "<c:out value="${urlAddr.employeeNo}"/>"
			       };
	if ( !isNull(reqParam.payrollCalculationExecId) || !isNull(reqParam.employeeNo) ) {
		srchFormUtil.setValue(reqParam);
		fncRetrievePaySlipData();
		
	} else {
		<c:if test="${empty payAuthTypeCode}"><%-- 일반 임직원 권한인 경우만 조회함 --%>
	    //데이터 조회
		fncRetrievePaySlipData('init');
	    </c:if>
	}
	
}
	
function closePopup(popup) {
	if(popup == "1") {
		$(".retroactivePayrollDetailPopupWindow").hide();	
	} else if(popup == "2"){
		$(".salaryChangeInfoPopupWindow").hide();	
	} else {
		$(".calculationDetailPopupWindow").hide();	
	}
}

function openPopup(popup) {
	if(popup == "1") {
		$(".retroactivePayrollDetailPopupWindow").show();	
	} else if(popup == "2"){
		$(".salaryChangeInfoPopupWindow").show();	
	} else {
		$(".calculationDetailPopupWindow").show();	
	}
}
	


LGVPAY00001.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVPAY00001();
		form.init();		
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2><lgcom:message code="label.pay.paySlip.paySlip"/></h2>
		</div>
		<div class="searchBlock">
			<form class="form search-wrap" method="post">
				<table class="table" >
					<colgroup>
						<c:if test="${ empty payAuthTypeCode }"><%-- 일반 임직원인 경우 --%>
						<col width="110"></col>
						<col width="250"></col>
						</c:if>
						<c:if test="${ payAuthTypeCode eq 'MASTER' }"><%-- 급여담당자인 경우 --%>
						<col width="130"></col>
						<col width="110"></col>
						<col width="160"></col>
						<col width="200"></col>
						<col width="100"></col>
						<col width="200"></col>
						</c:if>
					</colgroup>
					<tbody>
						<c:if test="${ empty payAuthTypeCode }"><%-- 일반 임직원인 경우 --%>
						<tr>
							<th scope="col"><label class="required"><i class="asterisk">*</i><lgcom:message code="label.pay.paySlip.payType"/></label></th>
							<td><select class="form-control input-sm input-require" name="payrollCalculationExecId" ></select></td>
						</tr>
						</c:if>
						<c:if test="${ payAuthTypeCode eq 'MASTER' }"><%-- 급여담당자인 경우 --%>
						<tr>
		                	<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.pay.executionId" /></label></th>
							<td>
		                		<div class="input-group input-group-sm input-search">
	                                <input class="form-control input-sm" name="payrollCalculationExecId" type="text" readonly>
	                                <span class="input-group-btn">
	                                    <button class="btn btn-default ico-lgd" type="button" data-action="openPopupExecutionList">
	                                        <span class="fa fa-search" aria-hidden="true"></span>
	                                    </button>
	                                </span>
	                            </div>
		                	</td>
		                	<th><label><lgcom:message code="label.pay.payMonth" /></label></th>
		                	<td><input type="text" class="form-control input-sm size_70" name="payMonth" data-action="change" readonly /></td>
		                	<th><label><lgcom:message code="label.pay.payType" /></label></th>
		                	<td><input type="text" class="form-control input-sm" name="payType" data-action="change" readonly /></td>
		                </tr>
						<tr>
		                	<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.pay.employeeNo" /></label></th>
							<td>
		                		<div class="input-group input-group-sm input-search">
	                                <input class="form-control input-sm" name="employeeNo" type="text" data-action="emptyAndPopup">
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
		                			<input type="text" class="form-control input-sm" name="employeeName">
	                                <span class="input-group-btn">
	                                    <button class="btn btn-default ico-lgd" type="button" data-action="openPopupEmployee">
	                                        <span class="fa fa-search" aria-hidden="true"></span>
	                                    </button>
	                                </span>
	                            </div>
	                        </td>
							<th scope="col"><label></label></th>
							<td></td>
						</tr>
						</c:if>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
			</form>
		</div>
		<%-- //searchBlock --%>
		
		<div class="row employeeInfoBlock">
			<div class="sub-header"><h4><lgcom:message code="label.pay.paySlip.personalInformation"/></h4></div>
	    	<table class="table table-condensed table-bordered" summary="Personal Information">
	        	<caption class="sr-only-lgd">Personal Information</caption>
				<colgroup>
					<col width="07%"></col><!-- employeeNo -->
					<col width="15%"></col><!-- employeeName -->
					<col width="05%"></col><!-- grade -->
					<col width="11%"></col><!-- jobTitle -->
					<col width="*"></col><!-- organization -->
					<col width="09%"></col><!-- empCategory -->
					<col width="11%"></col><!-- workType -->
					<col width="07%"></col><!-- hireDate -->
					<col width="11%"></col><!-- contractType -->
				</colgroup>
				<thead>
					<tr>
						<th scope="row"><label><lgcom:message code="label.pay.paySlip.employeeNo"/></label></th>
						<th scope="row"><label><lgcom:message code="label.pay.paySlip.employeeName"/></label></th>
						<th scope="row"><label><lgcom:message code="label.pay.paySlip.grade"/></label></th>
						<th scope="row"><label><lgcom:message code="label.pay.paySlip.jobTitle"/></label></th>
						<th scope="row"><label><lgcom:message code="label.pay.paySlip.organization"/></label></th>
						<th scope="row"><label><lgcom:message code="label.pay.paySlip.empCategory"/></label></th>
						<th scope="row"><label><lgcom:message code="label.pay.paySlip.workType"/></label></th>
						<th scope="row"><label><lgcom:message code="label.pay.paySlip.hireDate"/></label></th>
						<th scope="row"><label><lgcom:message code="label.pay.paySlip.contractType"/></label></th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<td class="text-center"><span name="employeeNo"></span></td>
						<td class="text-center"><span name="employeeName"></span></td>
						<td class="text-center"><span name="gradeTitleCode"></span></td>
						<td class="text-center"><span name="gradeTitleName"></span></td>
						<td ><span name="organizationName"></span></td>
						<td class="text-center"><span name="empCategoryName"></span></td>
						<td class="text-center"><span name="workTypeName"></span></td>
						<td class="text-center"><span name="hireDate"></span></td>
						<td class="text-center"><span name="contractTypeName"></span></td>
					</tr>
				</tbody>
			</table>
		</div>
		<%-- //employeeInfoBlock --%>
		
		<div class="row contractSalaryInfoBlock">
			<div class="col-xs-4">
				<div class="sub-header"><h4><lgcom:message code="label.pay.paySlip.contractSalaryInformation"/></h4></div>
				<div class="contractSalaryBlock">
					<table class="table table-condensed table-bordered" summary="Contract Salary Information">
			        	<caption class="sr-only-lgd">Contract Salary Information</caption>
						<colgroup>
							<col width="25%"></col>
							<col width="25%"></col>
						</colgroup>
						<thead>
							<tr>
								<th scope="row"><label><lgcom:message code="label.pay.paySlip.probSalOldSal"/></label></th>
								<th scope="row"><label><lgcom:message code="label.pay.paySlip.norSalNewSal"/></label></th>
							</tr>
						</thead>
						<tbody>
							<tr>
								<td class="text-right"><span name="probationPeriodOdwgAmount"></span></td>
								<td class="text-right"><span name="ordinaryWagesAmount"></span></td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
			<!-- //contractSalaryBlock -->
						
			<div class="col-xs-3">
				<div class="sub-header"><h4><lgcom:message code="label.pay.paySlip.annualLeave"/></h4></div>
				<div class="annualLeaveBlock">
					<table class="table table-condensed table-bordered" summary="Annual Leave Information">
			        	<caption class="sr-only-lgd">Annual Leave Information</caption>
						<colgroup>
							<col width="25%"></col>
							<col width="25%"></col>
						</colgroup>
						<thead>
							<tr>
								<th scope="row"><label><lgcom:message code="label.pay.paySlip.useAnnualLeaveDays"/></label></th>
								<th scope="row"><label><lgcom:message code="label.pay.paySlip.remainAnnualLeaveDays"/></label></th>
							</tr>
						</thead>
						<tbody>
							<tr>
								<td class="text-right"><span name="useAlDays"></span> <lgcom:message code="label.pay.paySlip.unitDay"/></td>
								<td class="text-right"><span name="remainAlDays"></span> <lgcom:message code="label.pay.paySlip.unitDay"/></td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
			<!-- //dependantBlock -->
			<div class="col-xs-2">
				<div class="sub-header"><h4><lgcom:message code="label.pay.taxInfo"/></h4></div>
				<div class="dependantBlock">
					<table class="table table-condensed table-bordered" summary="Dependant Information">
			        	<caption class="sr-only-lgd">Dependant Information</caption>
						<colgroup>
							<col width="50%"></col>
						</colgroup>
						<thead>
							<tr>
								<th scope="row"><label><lgcom:message code="label.pay.dependantCount"/></label></th>
							</tr>
						</thead>
						<tbody>
							<tr>
								<td class="text-center"><span name="dependantCountPay"></span></td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
			<!-- //annualLeaveBlock -->
		</div>
		<%-- //contractSalaryInfoBlock --%>
		
		<div class="row salaryDetailBlock">
			<div class="sub-header"><h4><lgcom:message code="label.pay.paySlip.salaryDetail"/></h4></div>
			<div class="col-xs-4 paymentBlock">
				<table class="table table-condensed table-bordered" summary="Payment Info">
					<caption class="sr-only-lgd">Payment</caption>
					<colgroup>
						<col width="15%"></col>
						<col width="20%"></col>
						<col width="20%"></col>
						<col width="25%"></col>
					</colgroup>
					<tbody>
						<tr>
							<th scope="row" rowspan="2" class="text-center"><label><lgcom:message code="label.pay.paySlip.payment"/></label></th>
							<th scope="row" class="text-center"><label><lgcom:message code="label.pay.paySlip.nightAllowance"/></label></th>
							<th scope="row" class="text-center"><label><lgcom:message code="label.pay.paySlip.overtime"/></label></th>
							<th scope="row" class="text-center"><label><lgcom:message code="label.pay.paySlip.overtimeAtNight"/></label></th>
						</tr>
						<tr>
							<td class="text-right"><span name="nightHours"></span> <lgcom:message code="label.pay.paySlip.unitHour"/></td>
							<td class="text-right"><span name="otHours"></span> <lgcom:message code="label.pay.paySlip.unitHour"/></td>
							<td class="text-right"><span name="otntHours"></span> <lgcom:message code="label.pay.paySlip.unitHour"/></td>
						</tr>
					</tbody>
				</table>
			</div>
			<%-- //paymentBlock --%>
			<div class="col-xs-8 deductionBlock">
				<table class="table table-condensed table-bordered" summary="Deduction Info">
					<caption class="sr-only-lgd">Deduction</caption>
					<colgroup>
						<col width="10%"></col>
						<col width="12%"></col>
						<col width="12%"></col>
						<col width="12%"></col>
						<col width="18%"></col>
						<col width="18%"></col>
						<col width="18%"></col>
					</colgroup>
					<tbody>
						<tr>
							<th scope="row" rowspan="2" class="text-center"><label><lgcom:message code="label.pay.paySlip.deduction"/></label></th>
							<th scope="row" class="text-center"><label><lgcom:message code="label.pay.paySlip.lateness"/></label></th>
							<th scope="row" class="text-center"><label><lgcom:message code="label.pay.paySlip.goingOut"/></label></th>
							<th scope="row" class="text-center"><label><lgcom:message code="label.pay.paySlip.leavingEarly"/></label></th>
							<th scope="row" class="text-center"><label><lgcom:message code="label.pay.paySlip.absenceNonWorking"/></label></th>
							<th scope="row" class="text-center"><label><lgcom:message code="label.pay.paySlip.unpaidLeaveNonWorking"/></label></th>
							<th scope="row" class="text-center"><label><lgcom:message code="label.pay.paySlip.suspensionNonWorking"/></label></th>
						</tr>
						<tr>
							<td class="text-right"><span name="latenessHours"></span> <lgcom:message code="label.pay.paySlip.unitHour"/></td>
							<td class="text-right"><span name="gooutHours"></span> <lgcom:message code="label.pay.paySlip.unitHour"/></td>
							<td class="text-right"><span name="leavingEarlyHours"></span> <lgcom:message code="label.pay.paySlip.unitHour"/></td>
							<td class="text-right"><span name="absenceLeaveDays"></span> <lgcom:message code="label.pay.paySlip.unitDay"/></td>
							<td class="text-right"><span name="unpaidLeaveDays"></span> <lgcom:message code="label.pay.paySlip.unitDay"/></td>
							<td class="text-right"><span name="suspensionLeaveDays"></span> <lgcom:message code="label.pay.paySlip.unitDay"/></td>
						</tr>
					</tbody>
				</table>
			</div>
			<%-- //deductionBlock --%>
		</div>
		<%-- //salaryDetailBlock --%>
		
		<div class="buttonControlBlock module-group text-right">
		<c:if test="${ payAuthTypeCode eq 'MASTER' }"><%-- 담당자 권한인 경우 Calculation Detail 버튼을 보여준다. --%>
			<div class="btn-group">
				<button class="btn btn-darkgray btn-sm" type="button" data-action="retroactivePayrollDetail" data-target="retroactivePayrollDetail" onclick="openPopup(1)"><lgcom:message code="button.pay.retroactivePayrollDetail"/></button>
				<button class="btn btn-darkgray btn-sm" type="button" data-action="salaryChangeInfo" data-target="salaryChangeInfo" onclick="openPopup(2)"><lgcom:message code="button.pay.paySlip.salaryChangeInfo"/></button>
				<button class="btn btn-darkgray btn-sm" type="button" data-action="calculationDetail" data-target="calculationDetail" onclick="openPopup(3)"><lgcom:message code="button.pay.paySlip.calculationDetail"/></button>
			</div>
		</c:if>
		</div>
		<%-- //buttonControlBlock --%>
		
		<div class="row incomeDeductionBlock">
			<table class="table table-condensed table-bordered incomeDeductionTable" summary="Income Deduction Info">
				<caption class="sr-only-lgd">Income Deduction Info</caption>
				<colgroup>
					<col width="10%"></col><!-- income > category (1차) -->
					<col width="*"  ></col><!-- income > category (2차) -->
					<col width=" 8%"></col><!-- income > amount -->
					<col width="11%"></col><!-- income > category (1차) -->
					<col width=" 7%"></col><!-- income > category (2차) -->
					<col width=" 5%"></col><!-- income > hr(시간) -->
					<col width=" 8%"></col><!-- income > amount -->
					<col width="1px"></col><!-- 경계선 -->
					<col width="11%"></col><!-- deduction > category (1차) -->
					<col width="11%"></col><!-- deduction > category (2차) -->
					<col width=" 5%"></col><!-- deduction > category (시간) -->
					<col width=" 8%"></col><!-- deduction > amount -->
				</colgroup>
				<thead>
					<tr>
						<th scope="row" colspan="7"><label><lgcom:message code="label.pay.paySlip.income"/></label></th>
						<th class="spaceTD" rowspan="2"><!-- --></th>
						<th scope="row" colspan="4"><label><lgcom:message code="label.pay.paySlip.deduction"/></label></th>
					</tr>
					<tr>
						<th scope="row" colspan="2"><label><lgcom:message code="label.pay.paySlip.category"/></label></th>
						<th scope="row"><label><lgcom:message code="label.pay.paySlip.amount"/></label></th>
						<th scope="row" colspan="2"><label><lgcom:message code="label.pay.paySlip.category"/></label></th>
						<th scope="row"><label><lgcom:message code="label.pay.paySlip.hr"/></label></th>
						<th scope="row"><label><lgcom:message code="label.pay.paySlip.amount"/></label></th>
						<%-- //income --%>
						<th scope="row" colspan="3"><label><lgcom:message code="label.pay.paySlip.category"/></label></th>
						<th scope="row"><label><lgcom:message code="label.pay.paySlip.amount"/></label></th>
						<%-- //deduction --%>
					</tr>
				</thead>
				<tbody>
				</tbody>
			</table>
		</div>
		<%-- //incomeDeductionBlock --%>
		
		<div class="row bankNSalaryBlock">
			<!-- HMT_20251101 Add Other Income data Start -->
			<div class="col-xs-6 otherIncomeInputBlock">
				<table class="table table-condensed table-bordered incomeDeductionTable" summary="Income Other Info">
					<caption class="sr-only-lgd">Income Other Info</caption>
					<colgroup>
						<col width="20%"></col><!-- income > category (1차) -->
						<col width=" 6%"></col><!-- income > amount -->
						<col width="10%"></col><!-- income > category (1차) -->
						<col width="6%"></col><!-- income > category (2차) -->
						<col width="10%"></col><!-- income > hr(시간) -->
					</colgroup>
					<thead>
						<tr>
							<th scope="row" colspan="5"><label><lgcom:message code="label.pay.otherIncome"/></label></th>
						</tr>
						<tr>
							<th scope="row"><label><lgcom:message code="label.pay.otherIncomeName"/></label></th>
							<th scope="row"><label><lgcom:message code="label.pay.paySlip.amount"/></label></th>
							<th scope="row"><label><lgcom:message code="label.pay.apNumber"/></label></th>
							<th scope="row"><label><lgcom:message code="label.pay.picId"/></label></th>
							<th scope="row"><label><lgcom:message code="label.pay.picName"/></label></th>
						</tr>
					</thead>
					<tbody>
					</tbody>
				</table>
			</div>
			<!-- HMT_20251101 Add Other Income data End -->
			<div class="col-xs-6">
				<div class="row">
					<div class="col-xs-6 bankBlock">
						<table class="table table-condensed deductionTable" summary="Bank Account">
							<caption class="sr-only-lgd">Bank Account</caption>
							<colgroup>
								<col width="40%"></col>
								<col width="60%"></col>
							</colgroup>
							<tbody>
								<tr>
									<th scope="row"><label><lgcom:message code="label.pay.paySlip.bankName"/></label></th>
									<td class="text-right"><span name="bankName"></span></td>
								</tr>
								<tr>
									<th scope="row"><label><lgcom:message code="label.pay.paySlip.accountNumber"/></label></th>
									<td class="text-right"><span name="bankAccountNo"></span></td>
								</tr>
							</tbody>
						</table>
					</div>
					<%-- //bankBlock --%>
					
					<div class="col-xs-6 salaryBlock">
						<table class="table table-condensed deductionTable" summary="Salary">
							<caption class="sr-only-lgd">Salary</caption>
							<colgroup>
								<col width="30%"></col>
								<col width="20%"></col>
								<col width="50%"></col>
							</colgroup>
							<tbody>
								<tr>
									<th scope="row"><label class="text-lgd"><lgcom:message code="label.pay.paySlip.grossSalary"/></label></th>
									<th scope="row" class="text-left">ⓐ=①+②</th>
									<td class="text-right"><span name="salaryTotalAmount"></span></td>
								</tr>
								<tr>
									<th scope="row"><label class="text-lgd"><lgcom:message code="label.pay.paySlip.deduction"/></label></th>
									<th scope="row" class="text-left">ⓑ=③</th>
									<td class="text-right"><span name="deductionTotalAmount"></span></td>
								</tr>
								<tr>
									<th scope="row"><label class="text-lgd"><lgcom:message code="label.pay.paySlip.netSalary"/></label></th>
									<th scope="row" class="text-left">ⓒ=ⓐ-ⓑ</th>
									<td class="text-right"><span name="bankTransferAmount"></span></td>
								</tr>
							</tbody>
						</table>
					</div>
					<%-- //salaryBlock --%>
					<div class="col-xs-12 otPolicy">
						<div class="alert alert-nomral" role="alert">
							<p class="paySlipText3" style="display:none;"><lgcom:message code="note.pay.paySlip.paySlipText3"/></p>
							<p class="paySlipText4"><lgcom:message code="note.pay.paySlip.paySlipText4"/></p>
						</div>
					</div>
				</div>
				
			</div>
			
		</div>
		<div class="row policyBlock">
			<div class="alert alert-nomral" role="alert">
				<p><lgcom:message code="note.pay.paySlip.paySlipText1"/></p>
				<p><lgcom:message code="note.pay.paySlip.paySlipText2"/></p>
			</div>
		</div>
		<%-- //bankNSalaryBlock --%>
		
		<!-- ------------ layer popup ------------ -->
		<%-- Etc - Adjustment Popup --%>
		<div class="modal-dialog adjustmentPopupWindow" role="dialog">
			<div class="modal-content adjustmentWindow">
	       		<div class="modal-header biz-header">
					<button type="button" class="btn btn-ico close _close" data-dismiss="modal" aria-label="Close" data-target="adjustment">
						<span class="ico ico-popup-close" aria-hidden="true"></span>
					</button>
	                <h1 class="modal-title"><span name="titleName"></span></h1>
	            </div>
				<div class="modal-body">
					<table class="table table-condensed table-bordered adjustmentTable" summary="Adjustment Info">
						<caption class="sr-only-lgd">Adjustment</caption>
						<colgroup>
							<col width="60%"></col>
							<col width="40%"></col>
						</colgroup>
						<thead>
							<tr>
								<th scope="row"><label><lgcom:message code="label.pay.paySlip.element"/></label></th>
								<th scope="row"><label><lgcom:message code="label.pay.paySlip.amount"/></label></th>
							</tr>
						</thead>
						<tbody>
						</tbody>
					</table>
				</div>
			</div>
		</div>
		<%-- //adjustmentPopupWindow --%>
		
		<c:if test="${ payAuthTypeCode eq 'MASTER' }"><%-- 담당자 권한인 경우 Calculation Detail Popup과 Contribution/PIT Pop을 보여준다. --%>
		<div class="modal-dialog calculationDetailPopupWindow" role="dialog">
			<div class="modal-content calculationDetailWindow">
	       		<div class="modal-header biz-header">
					<button type="button" class="btn btn-ico close _close" data-dismiss="modal" aria-label="Close" data-target="calculationDetail"
					onclick="closePopup(3)">
						<span class="ico ico-popup-close" aria-hidden="true"></span>
					</button>
	                <h1 class="modal-title"><span name="titleName"></span></h1>
	            </div>
				<div class="modal-body">
					<table class="table table-condensed table-bordered calculationDetailTable" summary="Calculation Detail Info">
						<caption class="sr-only-lgd">Calculation Detail Info</caption>
						<colgroup>
							<col width="40%"></col>
							<col width="20%"></col>
							<col width="20%"></col>
							<col width="20%"></col>
						</colgroup>
						<thead>
							<tr>
								<th scope="row"><label><lgcom:message code="label.pay.paySlip.category"/></label></th>
								<th scope="row" colspan="2"><label><lgcom:message code="label.pay.paySlip.calculatonPeriod"/></label></th>
								<th scope="row"><label><lgcom:message code="label.pay.paySlip.amount"/></label></th>
								<th scope="row"><label><lgcom:message code="label.pay.paySlip.workingDays"/></label></th>
							</tr>
						</thead>
						<tbody>
						</tbody>
					</table>
				</div>
			</div>
		</div>
		<%-- //calculationDetailPopupWindow --%>
		
		<div class="modal-dialog contributionPitPopupWindow" role="dialog">
			<div class="modal-content contributionPitWindow">
	       		<div class="modal-header biz-header">
					<button type="button" class="btn btn-ico close _close" data-dismiss="modal" aria-label="Close" data-target="contributionPit">
						<span class="ico ico-popup-close" aria-hidden="true"></span>
					</button>
	                <h1 class="modal-title"><span name="titleName"></span></h1>
	            </div>
				<div class="modal-body">
					<table class="table table-condensed table-bordered contributionPitTable" summary="Contribution/PIT Info">
						<caption class="sr-only-lgd">Contribution/PIT Info</caption>
						<colgroup>
							<col width="60%"></col>
							<col width="40%"></col>
						</colgroup>
						<thead>
							<tr>
								<th scope="row"><label><lgcom:message code="label.pay.paySlip.element"/></label></th>
								<th scope="row"><label><lgcom:message code="label.pay.paySlip.amount"/></label></th>
							</tr>
						</thead>
						<tbody>
						</tbody>
					</table>
				</div>
			</div>
		</div>
		<%-- //contributionPitPopupWindow --%>
		
		<div class="modal-dialog salaryChangeInfoPopupWindow" role="dialog">
			<div class="modal-content salaryChangeInfoWindow">
	       		<div class="modal-header biz-header">
					<button type="button" class="btn btn-ico close _close" data-dismiss="modal" aria-label="Close" data-target="salaryChangeInfo"
					onclick="closePopup(2)">
						<span class="ico ico-popup-close" aria-hidden="true"></span>
					</button>
	                <h1 class="modal-title"><span name="titleName"></span></h1>
	            </div>
				<div class="modal-body">
					<table class="table table-condensed table-bordered salaryChangeInfoTable" summary="Salary Change Info">
						<caption class="sr-only-lgd">Salary Change Info</caption>
						<colgroup>
							<col width="40%"></col>
							<col width="60%"></col>
						</colgroup>
						<thead>
							<tr>
								<th scope="row"><label><lgcom:message code="StartDate"/></label></th>
								<th scope="row"><label><lgcom:message code="label.pay.baseAmount"/></label></th>
							</tr>
						</thead>
						<tbody>
						</tbody>
					</table>
				</div>
			</div>
		</div>
		<%-- //salaryChangeInfoPopupWindow --%>
		
		<div class="modal-dialog retroactivePayrollDetailPopupWindow" role="dialog">
			<div class="modal-content retroactivePayrollDetailWindow">
	       		<div class="modal-header biz-header">
					<button type="button" class="btn btn-ico close _close" data-dismiss="modal" aria-label="Close" data-target="retroactivePayrollDetail"
					onclick="closePopup(1)">
						<span class="ico ico-popup-close" aria-hidden="true"></span>
					</button>
	                <h1 class="modal-title"><span name="titleName"></span></h1>
	            </div>
				<div class="modal-body">
					<table class="table table-condensed table-bordered retroactivePayrollDetailTable" summary="Retroactive Payroll Detail">
						<caption class="sr-only-lgd">Retroactive Payroll Detail</caption>
						<colgroup>
							<col width="30%"></col>
							<col width="40%"></col>
							<col width="30%"></col>
						</colgroup>
						<thead>
							<tr>
								<th scope="row"><label><lgcom:message code="label.pay.retropayTargetMonth"/></label></th>
								<th scope="row"><label><lgcom:message code="label.pay.payrollItemDesc"/></label></th>
								<th scope="row"><label><lgcom:message code="label.pay.differentAmt"/></label></th>
							</tr>
						</thead>
						<tbody>
						</tbody>
					</table>
				</div>
			</div>
		</div>
		<%-- //salaryChangeInfoPopupWindow --%>
		<!-- ------------ layer popup ------------ -->
		</c:if>
		
	</section>
</div>
</body>
</html>
