<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY00023.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 급여담당자가 퇴직자의 연차를 조정하는 화면입니다.
    작성자 : 임수진	
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Annual Leave Adj. for Retiree</title>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVPAY00023 = function() {
	var myForm = this;
	// Form Util 선언
	var srchFormUtil = new FormUtil( myForm, ".searchBlock form" );
	
    // 화면 레이아웃 정의
	myForm.setLayout( [
		{ name : "searchBlock",        left : 0, right : 0, top : 0 },
		{ name : "buttonControlBlock", left : 0, right : 0, top : "searchBlock"       , bottom : "retireeGridBlock" },
		{ name : "retireeGridBlock",   left : 0, right : 0, top : "buttonControlBlock", bottom : 0 }
	]);

    // 그리드선언
	var retireeGrid = buildGrid(".retireeGrid");

    // 개인화조건
    
    // 조회조건 저장 처리
    myForm.searchConditionControl( true );
    
    // 팝업 데이터 정의 searchMode:single(단수),multi(복수)
	myForm.popupInfo = {
		calculationPopup : { popupKind:'', confirmKind:'', calculationSetId:'', calculationSetName:'', calculationData:[] }
    };

    // 그리드형 테이블 TR
    
    // 코드 데이터 조회
    var code = new CommonCode("lgcom");
    code.add("payRunTypeList", {codeTypeCode:'LGVHR_PAY_RUN_TYPE'});
    code.execute();
    
    // MTH인 payTypeName 셋팅
    var payRunTypeData = code.get("payRunTypeList").find(function ( item ) { return item.code == 'MTH'; });
    if (payRunTypeData != undefined && typeof(payRunTypeData) == "object") {
		srchFormUtil.setValue({payrollTypeCode: payRunTypeData.code, payrollTypeName : nvl(payRunTypeData.name)});    	
    }
	
	//콤보 초기화
	
    // 날짜 팝업창
    
    // 필수항목 체크
   	var validator = new Validator( myForm, ".searchBlock form" );

    validator.setRule( {
    	option: {placement: 'right'},
	    rules: {
	    	payrollCalcPeriodValue : { required : true, monthYear : true },
	    	calculationSetName     : { emptyCalculationSet : true }
	    },
	    messages: {
	    	payrollCalcPeriodValue : { required            : '<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.payMonth'/>" />'},
	    	payrollCalcPeriodValue : { monthYear           : '<lgcom:message code="error.incorrectFormat" />'},
	    	calculationSetName     : { emptyCalculationSet : '<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.calculationSet'/>" />'}
	    }
    });
    
    //calculation set 입력값에 대한 validation 추가
    validator.addMethod( "emptyCalculationSet", function ( value, element ) {
    	var result = true;
    	if ( isNull(value) || isNull(srchFormUtil.getValue("calculationSetId")) ) {
    		result = false;
    	}
    	return result;
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
			case "search" :
				if ( validator.isValid() ) {
					fncRetrieveRetireeAnnualLeaveList();
				}
				break;
	            
			case "excelDownload":
				if(validator.isValid()) {
					Message.confirm('<lgcom:message code="question.excelDownload"/>',function() {
						var downloader = new Downloader( myForm );
						var param = {};
						param = $.extend(param, srchFormUtil.getValue());
						param = $.extend(param, {subsidiaryCode : "<c:out value="${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}"/>"
						                       , languageCode : SESSION_USER.languageCode});
						downloader.csvDirectDownload("lgvhr", "LGVPAY00023.createCSVDownloadData", param);
					});
				}
				break;
				
			// 급여대상자 SET 조회 팝업
		    case "openPopupCalSet" :
	            var popupData = myForm.popupInfo.calculationPopup;
	            popupData.popupKind    = "";
	            popupData.confirmKind  = "";
	            popupData.calculationSetName = srchFormUtil.getValue("payrollCalcPeriodValue");
	            srchFormUtil.setValue({calculationSetId : '', calculationSetName : ''});

	            var popup = new Popup( myForm,'lgvhr', 'M_LGVPAY_1018', '<lgcom:message code="label.pay.calculationSet"/>' );
	            popup.setSize(800,494);
	            popup.open( function(){
	            	if ( popupData.calculationData != undefined && popupData.calculationData.length > 0 ) {
	            		var selectData = popupData.calculationData[0];
		            	srchFormUtil.setValue({calculationSetId   : selectData.calculationSetId, 
		            		                   calculationSetName : selectData.calculationSetName});
		            	//검색조건 값이 있는 경우 데이터 조회
		        		fncSearchData();
	            	}
	            });
	            popupData.calculationData = [];
	            break;
	            
		    case "calculate" :
		    	//연차 계산 및 보정
		    	fncCalculateAnnualLeave();
		    	break;
	            
		    case "save" :
		    	//payDays 수정
		    	fncSave();
		    	break;
		}
		event.stopPropagation();
	});
	function fncSearchData() {
		if ( !isNull(srchFormUtil.getValue("payrollCalcPeriodValue")) && !isNull(srchFormUtil.getValue("payrollTypeCode")) && !isNull(srchFormUtil.getValue("calculationSetId")) ) { 
			myForm.select(".searchBlock button[data-action='search']").trigger("click");
		}
	}
	/*** 내부 함수  ***/
	function buildGrid(gridId) {
		var grid;
		switch ( gridId ) {
			case ".retireeGrid" :
				grid = new RealGrid(myForm, gridId);
				grid.setPagingMode(true);
				// Context Menu Set
				grid.setContextMenu();
				// Grid Field Set
				grid.setFields([
					{ fieldName:'employeeNo'             , dataType:'text'  },
					{ fieldName:'employeeName'           , dataType:'text'  },
					{ fieldName:'startDate'              , dataType:'text'  },
					{ fieldName:'calcStartDate'          , dataType:'text'  },
					{ fieldName:'resignationDate'	     , dataType:'text'  },
					{ fieldName:'accumulationLastYear'   , dataType:'number'},
					{ fieldName:'creationThisYear'       , dataType:'number'},
					{ fieldName:'totalAlThisYear'        , dataType:'number', calculateExpression:"values['accumulationLastYear'] + values['creationThisYear']"},
					{ fieldName:'creationFifthYear'      , dataType:'number'},
					{ fieldName:'usedAlThisYear'         , dataType:'number'},
					{ fieldName:'fullDays'               , dataType:'number'},
					{ fieldName:'workingDays'            , dataType:'number'},
					{ fieldName:'unpaidDays'             , dataType:'number'},
					{ fieldName:'adjDays'                , dataType:'number'},
					{ fieldName:'payDays'                , dataType:'number'},
					{ fieldName:'remainDays'             , dataType:'number'},
					{ fieldName:'calcAdjDays'            , dataType:'number'},
					{ fieldName:'timeAndAttendanceYyyymm', dataType:'text'  },
					{ fieldName:'confirmExistsFlag'      , dataType:'text'  }
				]);
				// Grid Column Set
				grid.setColumns([
					{
						name:'employeeNo',
						fieldName:'employeeNo',
						width:100,
						header: {text:'<lgcom:message code="label.pay.employeeNo"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'employeeName',
						fieldName:'employeeName',
						width:150,
						header: {text:'<lgcom:message code="label.pay.employeeName"/>'},
						editable: false
					},
					{
						name:'startDate',
						fieldName:'startDate',
						width:90,
						header: {text:'<lgcom:message code="StartDate"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'calcStartDate',
						fieldName:'calcStartDate',
						width:90,
						header: {text:'<lgcom:message code="label.pay.calcStartDate"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'resignationDate',
						fieldName:'resignationDate',
						width:90,
						header: {text:'<lgcom:message code="label.pay.resignationDate"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'accumulationLastYear',
						fieldName:'accumulationLastYear',
						width:110,
						header: {text:'<lgcom:message code="label.pay.accmulationFromLastYear"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0.0'},
						editable: false
					},
					{
						name:'creationThisYear',
						fieldName:'creationThisYear',
						width:110,
						header: {text:'<lgcom:message code="label.pay.creationFromThisYear"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0.0'},
						editable: false
					},
					{
						name:'totalAlThisYear',
						fieldName:'totalAlThisYear',
						width:120,
						header: {text:'<lgcom:message code="label.pay.totalAnnualLeaveOfThisYear"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0.0'},
						editable: false
					},
					{
						name:'creationFifthYear',
						fieldName:'creationFifthYear',
						width:110,
						header: {text:'<lgcom:message code="label.pay.creationFrom5Year"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0.0'},
						editable: false
					},
					{
						name:'usedAlThisYear',
						fieldName:'usedAlThisYear',
						width:120,
						header: {text:'<lgcom:message code="label.pay.usedAnnualLeaveAtThisYear"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0.0'},
						editable: false
					},
					{
						name:'fullDays',
						fieldName:'fullDays',
						width:90,
						header: {text:'<lgcom:message code="label.pay.fullDays"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0'},
						editable: false
					},
					{
						name:'workingDays',
						fieldName:'workingDays',
						width:100,
						header: {text:'<lgcom:message code="label.pay.workingDaysThisYear"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0.0'},
						editable: false
					},
					{
						name:'unpaidDays',
						fieldName:'unpaidDays',
						width:100,
						header: {text:'<lgcom:message code="label.pay.unpaidDaysThisYear"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0.0'},
						editable: false
					},
					{
						name:'adjDays',
						fieldName:'adjDays',
						width:140,
						header: {text:'<lgcom:message code="label.pay.adjustDays"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0.0'},
						editable: false
					},
					{
						name:'payDays',
						fieldName:'payDays',
						width:100,
						header: {text:'<lgcom:message code="label.pay.payDays"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0.0'},
//						dynamicStyles:[{criteria:"values['confirmExistsFlag']='N'", styles:{background:"#ffffffaa"}}],
						editor: {type:'number'},
						editable: false
					},
					{
						name:'remainDays',
						fieldName:'remainDays',
						width:100,
						header: {text:'<lgcom:message code="label.pay.remainDays"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0.0'},
						editable: false
					}
				]);
				// Grid Option Set
				grid.setOptions({
					grid: {
						hideDeletedRows: true,
						indicator: {visible:false},
						panel: {visible:false},
						stateBar: {visible:false},
						checkBar: {visible:false},
						footer: {visible:false},
			            sortMode : "explicit",
						edit: {
							insertable: false, /* INSERT 키 또는 방향키로 행삽입 불가능 */
							appendable: false, /* INSERT 키 또는 방향키로 행추가 불가능 */
							updatable: true,
							deletable: true
						},
						header: {
							height: 60
						},
						fixed: { colCount: 5, resizable:true }
					},
					dataProvider: {
						insertable: true,
						updatable: true,
						deletable: true,
						softDeleting: true,
						deleteCreated: true
					},
					display: { fitStyle: 'none' }
				});
				break;
		}
		return grid;
	}
	//연차 계산 및 보정
	function fncCalculateAnnualLeave() {
		Message.confirm( "<lgcom:message code="question.pay.calculate"/>", function() {

			myForm.showProgress();
			myForm.transaction("lgvhr", "lgvpay/LGVPAY00023/saveCalculateAnnualLeave", srchFormUtil.getValue(), function (data) {
				myForm.hideProgress();
				if ( data.result ) {
					if ( nvl(data.result.retCode) == 0 ) {
						Message.alert("<lgcom:message code="note.pay.successfullyProcessed"/>");
						//화면 재조회
						myForm.select(".searchBlock button[data-action='search']").trigger("click");
					} else {
						Message.alert("<lgcom:message code="note.pay.failProcesse"/>");
					}
				}//if ( data.result ) 
			}, function (data) { myForm.hideProgress(); });//myForm.transaction
		});//Message.confirm
	}
	
    //저장
    function fncSave() {
		try {
			retireeGrid.getGridBase().commit();
		} catch(e) {
			Message.alert(e.message);
			return;
		}
		
		if( retireeGrid.getRowCount() == 0 ) {
			Message.alert('<lgcom:message code="note.nodata"/>');
			return;
		}
		
		if(!retireeGrid.isChanged()) {
			Message.alert('<lgcom:message code="error.noChangedData"/>');
			return;
		}

		Message.confirm( "<lgcom:message code="question.save"/>", function() {
       		retireeGrid.useProgress(true);
       		retireeGrid.saveChanges("lgvhr", "lgvpay/LGVPAY00023/updateAnnualLeave", param, function (data) {
        		myForm.hideProgress();
        		Message.alert("<lgcom:message code="note.saved"/>");
				//화면 재조회
				myForm.select(".searchBlock button[data-action='search']").trigger("click");
        	}, function (data) {
        		myForm.hideProgress();
        	});<%-- myForm.transaction --%>
       	});<%-- //Message.confirm --%>

    }
	//급여 대상자 중 퇴직자의 연차 정보 조회
	function fncRetrieveRetireeAnnualLeaveList() {
		retireeGrid.getGridBase().cancel();
		myForm.select("button[data-action='calculate']").attr("disabled", "disabled");
		myForm.select("button[data-action='save']").attr("disabled", "disabled");
		myForm.select("button[data-action='excelDownload']").attr("disabled", "disabled");
		
		//데이터조회
		retireeGrid.loadData("lgvhr", "lgvpay/LGVPAY00023/retrieveRetireeAnnualLeaveList", srchFormUtil.getValue(), function (data) { 
			if ( data.result && data.result.length > 0 ) {
				//조회결과 있는 경우만 엑셀 다운로드 버튼 활성화
				myForm.select("button[data-action='excelDownload']").removeAttr("disabled");
				
				//해당 payMonth, payType에 대해 확정된 건이 없는 경우만 calculate, save 가능함
				fncRetrieveConfirmExistsData();
			}
		});
	}
	//확정건 여부 조회후 버튼 및 컬럼 수정 여부 활성화 처리
	function fncRetrieveConfirmExistsData() {
		//확정건 없는 경우 연차계산, 저장 버튼 활성화. Pay Days 컬럼 수정가능여부 셋팅
		myForm.transaction("lgvhr", "lgvpay/LGVPAY00023/retrieveConfirmExistsData", srchFormUtil.getValue(), function (data) {
			//해당 payMonth, payType에 대해 확정된 건이 없는 경우만 calculate, save 가능함
			if ( data.result && nvl(data.result.confirmExistsFlag, "N") == "N" ) {
				//calculate, save 버튼 활성화
				myForm.select("button[data-action='calculate']").removeAttr("disabled");
				myForm.select("button[data-action='save']").removeAttr("disabled");

				//그리드 pay days 컬럼 배경색 변경, 수정 가능하도록 속성변경
				retireeGrid.getGridBase().setColumnProperty("payDays", "editable", true);
				retireeGrid.getGridBase().setColumnProperty("payDays", "styles", {background:"#ffffffaa"});
			} else {
				
				//그리드 pay days 컬럼 배경색 변경, 수정 가능하도록 속성변경
				retireeGrid.getGridBase().setColumnProperty("payDays", "editable", false);
				retireeGrid.getGridBase().setColumnProperty("payDays", "styles", {background:"#ffffff"});
				
			}
		});
	}
}

LGVPAY00023.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVPAY00023();
		form.init();		
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2>Annual Leave Adj. for Retiree</h2>
		</div>
		<div class="searchBlock">
			<form class="form search-wrap" method="post">
				<input type="hidden" name="payrollTypeCode" />
				<table class="table" >
					<colgroup>
						<col width="180"></col>
						<col width="070"></col>
						<col width="100"></col>
						<col width="180"></col>
						<col width="140"></col>
						<col width="250"></col>
						<col width="*"></col>
					</colgroup>
					<tbody>
						<tr>
		                	<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.pay.payMonth" /></label></th>
							<td><input type="text" class="form-control input-sm input-require" name="payrollCalcPeriodValue" maxlength="7" placeholder="<lgcom:message code="placeholder.pay.mmyyyy"/>" /></td>
		                	<th><label><lgcom:message code="label.pay.payType" /></label></th>
		                	<td><input type="text" class="form-control input-sm" name="payrollTypeName" readonly /></td>
		                	<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.pay.calculationSet" /></label></th>
							<td>
		                		<div class="input-group input-group-sm input-search">
		                			<input type="hidden" name="calculationSetId" />
	                                <input class="form-control input-sm input-require" name="calculationSetName" type="text" data-action="emptyAndPopup" readonly />
	                                <span class="input-group-btn">
	                                    <button class="btn btn-default ico-lgd find" type="button" data-action="openPopupCalSet">
	                                        <span class="fa fa-search" aria-hidden="true"></span>
	                                    </button>
	                                </span>
	                            </div>
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
			<div class="btn-toolbar">
				<div class="btn-group">
					<button class="btn btn-gray btn-sm" type="button" data-action="calculate" disabled><lgcom:message code="button.pay.calculate"/></button>
					<button class="btn btn-gray btn-sm" type="button" data-action="save" disabled><lgcom:message code="Save"/></button>
				</div>
				<div class="btn-group">
					<button type="button" class="btn btn-default btn-sm" data-action="excelDownload" disabled><span class="ico ico-excel-down"  aria-hidden="true"></span> <lgcom:message code="Download"/></button>
				</div>
			</div>
		</div>
		<%-- //buttonControlBlock --%>

		<div class="retireeGridBlock grid-wrap">
			<div class="grid retireeGrid"></div>
		</div>
		
	</section>
</div>
</body>
</html>
