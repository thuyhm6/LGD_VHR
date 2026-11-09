<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY00032.jsp
    프로젝트명 : 베트남 근태 급여 시스템 구축

   Copyright(c) 2017 LG CNS,  All rights reserved..

    설 명 : Paid Leave Payment Calculation (PL_SW / PL_PLP)
            - Calculate : 근태실적(PL + 상세코드) 기준으로 일별 연속일수(a) / Tier / 지급률 산정 후
                          월 결과(사번/PL코드/Tier) 생성 -> 급여항목 (lgvpay_paid_leave_pkg.calculation_pl_item) 에서 사용
            - 금액 = 월 금액 / Perfect work hours * PL hours * 지급률
    작성자 : HMT_20251201
    수정   : HMT_20261026 Rebuild
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVPAY00032 = function() {
	var myForm = this;
    var _this = this;
	// Form Util 선언
	var srchForm = '.searchBlock form';
	var srchFormUtil = new FormUtil( myForm, srchForm );

 	//필수항목 체크
   	var validator = new Validator( myForm, srchForm );

   	var code = new CommonCode("lgcom");
    code.add("paidLeaveCodeList", {codeTypeCode:'LGVHR_ATTENDANCE_PL_DETAIL_CODE'});
    code.execute();

	//콤보 초기화 (전체 = 모든 PL 코드)
	srchFormUtil.initCombo("paidLeaveDetailCode", code.get("paidLeaveCodeList"), {selectAll:true});

   	myForm.setLayout( [
		{ name : "searchBlock",    left : 0, right : 0, top : 0 },
		{ name : "gridControls",   left : 0, right : 0, top : "searchBlock" },
		{ name : "gridContent",    left : 0, right : 0, top : "gridControls", height : 330 },
		{ name : "dailyControls",  left : 0, right : 0, top : "gridContent" },
		{ name : "dailyContent",   left : 0, right : 0, top : "dailyControls", bottom : 0 }
	]);

   	transaction_sync( "lgvhr","lgvatt/LGVATT50030/retrieveAttendanceYyyymm", {}, function(data) {
    	if ( data.result ) {
    		srchFormUtil.initCombo("payMonth", data.result.yyyymmList, {selectAll:false});
    		srchFormUtil.setValue({payMonth: data.result.currentYyyymmData.attendanceYyyymm});
    	}
    });

    validator.setRule( {
    	option: {placement: 'right'},
	    rules: {
	    	payMonth : {required:true}
	    },
	    messages: {
	    	payMonth : {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.month'/>" />'}
	    }
    });

 	// 그리드 선언
	var grid      = buildGrid('.paidLeaveResultGrid');
	var dailyGrid = buildDailyGrid('.paidLeaveDailyGrid');

	// 조회조건 저장 처리
	myForm.searchConditionControl(true);

	// 팝업 데이터 정의
	myForm.popupInfo = {
		userPopup : {searchMode:'single', popupKind:'', confirmKind:'', employeeNo:'', employeeName:'', userData:[]}
    };

	/***  이벤트 핸들러  ***/
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ) {
		case 'search':
			search();
			break;

		case 'calculate':
			if(!validator.isValid()) return;
			Message.confirm('<lgcom:message code="question.pay.calculate"/>', function() {
				myForm.showProgress();
				myForm.transaction("lgvhr", "lgvpay/LGVPAY00032/saveCalculatePaidLeave", srchFormUtil.getValue(), function (data) {
					myForm.hideProgress();
					Message.alert('<lgcom:message code="note.completed"/>');
					search();
				}, function (data) { myForm.hideProgress(); });
			});
			break;

		case 'excelDownload':
			if(validator.isValid()) {
				Message.confirm('<lgcom:message code="question.excelDownload"/>',function() {
					var downloader = new Downloader( myForm );
					downloader.excel( "lgvhr", "lgvpay/LGVPAY00032/createExcelExportData", srchFormUtil.getValue() );
				});
			}
			break;

     	// 유저 검색 팝업
	    case "openPopupApprover" :
            var _popup = _this.popupInfo.userPopup;
            _popup.searchMode   = "single";
            _popup.employeeNo   = srchFormUtil.getValue("employeeNo");
            _popup.employeeName = srchFormUtil.getValue("employeeName");
            _popup.fseYn = "N";
            _popup.flsaYn = "N";
            _popup.userData = [];
        	fncSearchEmpInfoInit();

            var popup = new Popup( _this,'lgvhr', 'M_LGVCOM_1010', '<lgcom:message code="UserSearch"/>' );
            popup.setSize(800,494);
            popup.open( function(){
            	if(_popup.userData.length == 0) return;
            	srchFormUtil.setValue({employeeNo   : _popup.userData[0].employeeNo});
            	srchFormUtil.setValue({employeeName : _popup.userData[0].employeeName});
            });
            break;
		}
	});

	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});
    myForm.addEvent ( "click", ".searchBlock form input[name='employeeNo'], input[name='employeeName']", function(event) {
    	fncSearchEmpInfoInit();
    });
    myForm.addEvent ( "keydown", ".searchBlock form input[name='employeeNo']", function(event) {
		if(event.keyCode == 13) {
			myForm.select(".searchBlock button[data-action='openPopupApprover']").trigger('click');
		}
	});
	function fncSearchEmpInfoInit() {
		srchFormUtil.setValue({employeeNo : '', employeeName : ''});
	}

	//결과 행 선택 시 일별 상세 조회
	grid.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		if(newRow < 0) {
			dailyGrid.getDataProvider().clearRows();
			return;
		}
		var row = cgrid.getDataProvider().getJsonRow(newRow);
		dailyGrid.loadData("lgvhr", "lgvpay/LGVPAY00032/retrievePaidLeaveDaily", {
			payMonth            : row.paymentYyyymm,
			employeeNo          : row.employeeNo,
			paidLeaveDetailCode : row.paidLeaveDetailCode
		});
	};

	//Search
	function search() {
		if(!validator.isValid()) return;
		dailyGrid.getDataProvider().clearRows();
		grid.loadData("lgvhr", "lgvpay/LGVPAY00032/retrievePaidLeaveHours", srchFormUtil.getValue(), function(data) {
			if( grid.getRowCount() == 0 ) {
				Message.alert('<lgcom:message code="note.nodata"/>');
			}
		});
	}

	/***  내부 함수  ***/
	function numCol(name, text, width, summary) {
		var col = { name:name, fieldName:name, width:(width || 100), editable:false,
		            header:{text:text}, styles:{textAlignment:'far', numberFormat:'#,##0.##'} };
		if(summary) {
			col.header.summary = {styles:{textAlignment:'far', numberFormat:'#,##0'}, expression:'sum'};
		}
		return col;
	}
	//급여 구성요소별 그룹 컬럼 : Monthly / 100% / Pay / Adj
	function componentGroup(prefix, text) {
		return { type:'group', name:prefix + 'Group', width:400, orientation:'horizontal',
		         header:{text:text},
		         columns:[ numCol(prefix + 'Base', '<lgcom:message code="label.pay.plMonthlyBase"/>', 100, false),
		                   numCol(prefix + 'Full', '<lgcom:message code="label.pay.plFullAmount"/>' , 100, true),
		                   numCol(prefix + 'Pay' , '<lgcom:message code="label.pay.plPayAmount"/>'  , 100, true),
		                   numCol(prefix + 'Adj' , '<lgcom:message code="label.pay.plAdjAmount"/>'  , 100, true) ] };
	}
	var components = ['baseSalary', 'positionAllw', 'jobAllw', 'qualificationAllw', 'adj1Allw', 'adj2Allw', 'adj3Allw'];

	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);

		var fields = [
		    { fieldName: 'paymentYyyymm'       , dataType:'text'},
		    { fieldName: 'employeeNo'          , dataType:'text'},
		    { fieldName: 'employeeName'        , dataType:'text'},
		    { fieldName: 'organizationName'    , dataType:'text'},
		    { fieldName: 'empCategoryName'     , dataType:'text'},
		    { fieldName: 'paidLeaveDetailCode' , dataType:'text'},
		    { fieldName: 'tierNo'              , dataType:'number'},
		    { fieldName: 'plDays'              , dataType:'number'},
		    { fieldName: 'plHours'             , dataType:'number'},
		    { fieldName: 'perfectWorkDays'     , dataType:'number'},
		    { fieldName: 'perfectWorkHours'    , dataType:'number'},
		    { fieldName: 'minWage'             , dataType:'number'},
		    { fieldName: 'totalPay'            , dataType:'number'},
		    { fieldName: 'calcDate'            , dataType:'text'}
		];
		$.each(components, function(i, p) {
			fields.push({fieldName:p + 'Base', dataType:'number'});
			fields.push({fieldName:p + 'Full', dataType:'number'});
			fields.push({fieldName:p + 'Pay' , dataType:'number'});
			fields.push({fieldName:p + 'Adj' , dataType:'number'});
		});
		grid.setFields(fields);

		grid.setColumns([
			{ name:'employeeNo', fieldName:'employeeNo', width:90, editable:false,
			  header:{text:'<lgcom:message code="label.pay.employeeNo"/>'}, styles:{textAlignment:'center'} },
			{ name:'employeeName', fieldName:'employeeName', width:180, editable:false,
			  header:{text:'<lgcom:message code="EmployeeEngName"/>'}, renderer:{showTooltip:true} },
			{ name:'empCategoryName', fieldName:'empCategoryName', width:60, editable:false,
			  header:{text:'OW/LW'}, styles:{textAlignment:'center'} },
			{ name:'paidLeaveDetailCode', fieldName:'paidLeaveDetailCode', width:80, editable:false,
			  header:{text:'<lgcom:message code="label.pay.plDetailCode"/>'}, styles:{textAlignment:'center'} },
			{ name:'tierNo', fieldName:'tierNo', width:60, editable:false,
			  header:{text:'<lgcom:message code="label.pay.plTierNo"/>'}, styles:{textAlignment:'center'} },
			numCol('plDays'          , '<lgcom:message code="label.pay.plDays"/>'           , 70, true),
			numCol('plHours'         , '<lgcom:message code="label.pay.plHours"/>'          , 80, true),
			numCol('perfectWorkDays' , '<lgcom:message code="label.pay.perfectWorkDays"/>'  , 90, false),
			numCol('perfectWorkHours', '<lgcom:message code="label.pay.perfectWorkHours"/>' , 90, false),
			numCol('totalPay'        , '<lgcom:message code="label.pay.plTotalPay"/>'       , 110, true),
			componentGroup('baseSalary'       , '<lgcom:message code="label.pay.baseSalary"/>'),
			componentGroup('positionAllw'     , '<lgcom:message code="label.pay.positionAllowance"/>'),
			componentGroup('jobAllw'          , '<lgcom:message code="label.pay.jobAllowance"/>'),
			componentGroup('qualificationAllw', '<lgcom:message code="label.pay.qualificationAllowance"/>'),
			componentGroup('adj1Allw'         , '<lgcom:message code="label.pay.adjustmentAllowance1"/>'),
			componentGroup('adj2Allw'         , '<lgcom:message code="label.pay.adjustmentAllowance2"/>'),
			componentGroup('adj3Allw'         , '<lgcom:message code="label.pay.adjustmentAllowance3"/>'),
			numCol('minWage', '<lgcom:message code="label.pay.plMinWage"/>', 100, false),
			{ name:'organizationName', fieldName:'organizationName', width:250, editable:false,
			  header:{text:'<lgcom:message code="label.pay.organizationName"/>'} },
			{ name:'calcDate', fieldName:'calcDate', width:120, editable:false,
			  header:{text:'Calc Date'}, styles:{textAlignment:'center'} }
		]);
		grid.setOptions({
			grid: {
				indicator: {visible:false},
				panel: {visible:false},
				checkBar: {visible:false},
				stateBar: {visible:false},
				footer: {visible:false},
				header: {height: 50,
				         summary: {visible: true, styles: {background: "#e9e9e9", fontBold: "false", paddingRight: 5}}},
				paste: {enabled:false},
				sorting  : {enabled:false},
                sortMode : "explicit",
				edit: { insertable: false, appendable: false, updatable: false, deletable: false },
				fixed: { colCount: 5 }
			},
			display: { fitStyle: 'none' }
		});
		grid.setContextMenu();
		return grid;
	}

	function buildDailyGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setFields([
		    { fieldName: 'employeeNo'            , dataType:'text'},
		    { fieldName: 'attDate'               , dataType:'text'},
		    { fieldName: 'dayOfWeek'             , dataType:'text'},
		    { fieldName: 'paidLeaveDetailCode'   , dataType:'text'},
		    { fieldName: 'empCategoryName'       , dataType:'text'},
		    { fieldName: 'shiftTypeCode'         , dataType:'text'},
		    { fieldName: 'chainStartDate'        , dataType:'text'},
		    { fieldName: 'continuousDays'        , dataType:'number'},
		    { fieldName: 'tierNo'                , dataType:'number'},
		    { fieldName: 'plHours'               , dataType:'number'},
		    { fieldName: 'baseAmountType'        , dataType:'text'},
		    { fieldName: 'baseSalaryRate'        , dataType:'number'},
		    { fieldName: 'positionAllwRate'      , dataType:'number'},
		    { fieldName: 'jobAllwRate'           , dataType:'number'},
		    { fieldName: 'qualificationAllwRate' , dataType:'number'},
		    { fieldName: 'adj1AllwRate'          , dataType:'number'},
		    { fieldName: 'adj2AllwRate'          , dataType:'number'},
		    { fieldName: 'adj3AllwRate'          , dataType:'number'}
		]);
		grid.setColumns([
			{ name:'attDate', fieldName:'attDate', width:100, editable:false, header:{text:'<lgcom:message code="label.att.date"/>'}, styles:{textAlignment:'center'} },
			{ name:'dayOfWeek', fieldName:'dayOfWeek', width:50, editable:false, header:{text:'Day'}, styles:{textAlignment:'center'} },
			{ name:'paidLeaveDetailCode', fieldName:'paidLeaveDetailCode', width:80, editable:false, header:{text:'<lgcom:message code="label.pay.plDetailCode"/>'}, styles:{textAlignment:'center'} },
			{ name:'empCategoryName', fieldName:'empCategoryName', width:60, editable:false, header:{text:'OW/LW'}, styles:{textAlignment:'center'} },
			{ name:'shiftTypeCode', fieldName:'shiftTypeCode', width:80, editable:false, header:{text:'Shift'}, styles:{textAlignment:'center'} },
			{ name:'chainStartDate', fieldName:'chainStartDate', width:110, editable:false, header:{text:'<lgcom:message code="label.pay.plChainStartDate"/>'}, styles:{textAlignment:'center'} },
			numCol('continuousDays', '<lgcom:message code="label.pay.plContinuousDays"/>', 110, false),
			{ name:'tierNo', fieldName:'tierNo', width:60, editable:false, header:{text:'<lgcom:message code="label.pay.plTierNo"/>'}, styles:{textAlignment:'center'} },
			numCol('plHours', '<lgcom:message code="label.pay.plHours"/>', 80, false),
			{ name:'baseAmountType', fieldName:'baseAmountType', width:110, editable:false, header:{text:'<lgcom:message code="label.pay.plBaseAmountType"/>'}, styles:{textAlignment:'center'} },
			{ type:'group', name:'rateGroup', width:700, orientation:'horizontal',
			  header:{text:'<lgcom:message code="label.pay.plRate"/>'},
			  columns:[ numCol('baseSalaryRate'       , '<lgcom:message code="label.pay.baseSalary"/>'            , 100, false),
			            numCol('positionAllwRate'     , '<lgcom:message code="label.pay.positionAllowance"/>'     , 100, false),
			            numCol('jobAllwRate'          , '<lgcom:message code="label.pay.jobAllowance"/>'          , 100, false),
			            numCol('qualificationAllwRate', '<lgcom:message code="label.pay.qualificationAllowance"/>', 100, false),
			            numCol('adj1AllwRate'         , '<lgcom:message code="label.pay.adjustmentAllowance1"/>'  , 100, false),
			            numCol('adj2AllwRate'         , '<lgcom:message code="label.pay.adjustmentAllowance2"/>'  , 100, false),
			            numCol('adj3AllwRate'         , '<lgcom:message code="label.pay.adjustmentAllowance3"/>'  , 100, false) ] }
		]);
		grid.setOptions({
			grid: {
				indicator: {visible:false},
				panel: {visible:false},
				checkBar: {visible:false},
				stateBar: {visible:false},
				footer: {visible:false},
				header: {height: 50},
				paste: {enabled:false},
				sorting  : {enabled:false},
				edit: { insertable: false, appendable: false, updatable: false, deletable: false }
			},
			display: { fitStyle: 'none' }
		});
		return grid;
	}
}

LGVPAY00032.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGVPAY00032();
		form.init();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2></h2>
		</div>
		<div class="searchBlock">
			<form class="form search-wrap">
				<table class="table">
					<colgroup>
						<col width="80"/>
						<col width="120"/>
						<col width="120"/>
						<col width="160"/>
						<col width="100"/>
						<col width="160"/>
						<col width="100"/>
						<col width="160"/>
					</colgroup>
					<tbody>
						<tr>
							<th><label class="required"><lgcom:message code="label.att.month"/></label></th>
		                    <td><select class="form-control input-sm input-require" name="payMonth"></select></td>
		                    <th><label><lgcom:message code="label.pay.plDetailCode"/></label></th>
		                	<td><select class="form-control input-sm" name="paidLeaveDetailCode"></select></td>
		                	<th><label><lgcom:message code="label.pay.employeeNo"/></label></th>
							<td>
		                		<div class="input-group input-group-sm input-search">
	                                <input class="form-control input-sm _find_origin_" name="employeeNo" type="text">
	                                <span class="input-group-btn">
	                                    <button class="btn btn-default ico-lgd find" type="button" data-action="openPopupApprover">
	                                        <span class="fa fa-search" aria-hidden="true"></span>
	                                    </button>
	                                </span>
	                            </div>
		                	</td>
							<th><label><lgcom:message code="label.pay.employeeName"/></label></th>
							<td><input type="text" class="form-control input-sm" name="employeeName"></td>
						</tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search"/></button>
			</form>
		</div>
		<%-- 그리드 버튼 영역 --%>
		<div class="gridControls module-group text-right">
			<div class="btn-toolbar">
				<div class="btn-group">
					<button class="btn btn-gray btn-sm" type="button" data-action="calculate" data-access="LGVPAY00032/saveCalculatePaidLeave"><lgcom:message code="button.pay.calculate"/></button>
				</div>
				<div class="btn-group">
			        <button type="button" class="btn btn-default btn-sm" data-action="excelDownload"><span class="ico ico-excel-down" aria-hidden="true"></span> <lgcom:message code="Download"/></button>
			    </div>
			</div>
		</div>
		<div class="gridContent grid-wrap">
			<div class="grid paidLeaveResultGrid"></div>
		</div>
		<div class="dailyControls module-group">
			<h3 class="title"><lgcom:message code="label.pay.plDailyDetail"/></h3>
		</div>
		<div class="dailyContent grid-wrap">
			<div class="grid paidLeaveDailyGrid"></div>
		</div>
	</section>
</div>
</body>
</html>
