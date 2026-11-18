<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY00033.jsp
    프로젝트명 : 베트남 근태 급여 시스템 구축

   Copyright(c) 2017 LG CNS,  All rights reserved..

    설 명 : Paid Leave Payment Rate Setup (PL_SW / PL_PLP)
            1) 지급률 : PL코드 + OW/LW + Tier(연속일수 a 구간) + 적용기간 별 구성요소 지급률(%)
                        Base amount type = MIN_WAGE 이면 Base salary 대신 최저임금(Global Value REGION_MINIMUM_WAGE) 사용
            2) 급여항목 매핑 : (PL코드, Tier, 구성요소) -> Payroll Item
                        (급여항목 Formula = lgvpay_paid_leave_pkg.calculation_pl_item)
    작성자 : HMT_20251201
    수정   : HMT_20261026 Rebuild
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVPAY00033 = function() {
	var myForm = this;
	// Form Util 선언
	var srchForm = '.searchBlock form';
	var srchFormUtil = new FormUtil( myForm, srchForm );

   	var code = new CommonCode("lgcom");
    code.add("paidLeaveCodeList", {codeTypeCode:'LGVHR_ATTENDANCE_PL_DETAIL_CODE'});
    code.execute();

    //급여항목 콤보
    var payrollItemList = [];
	transaction_sync("lgvhr", "lgvpay/LGVPAY00033/retrievePayrollItemList", {}, function(data) {
		if ( data.result ) {
			payrollItemList = data.result;
		}
	});

	var empCategoryList = [ {code:'LGD_OW', name:'OW'}, {code:'LGD_LW', name:'LW'}, {code:'ALL', name:'ALL'} ];
	var baseAmountList  = [ {code:'BASE_SALARY', name:'Base Salary'}, {code:'MIN_WAGE', name:'Minimum Wage'} ];
	var componentList   = [ {code:'BASE_SALARY'       , name:'Base salary'},
	                        {code:'POSITION_ALLW'     , name:'Position allowance'},
	                        {code:'JOB_ALLW'          , name:'Job allowance'},
	                        {code:'QUALIFICATION_ALLW', name:'Qualification allowance'},
	                        {code:'ADJ1_ALLW'         , name:'Adjustment 1 allowance'},
	                        {code:'ADJ2_ALLW'         , name:'Adjustment 2 allowance'},
	                        {code:'ADJ3_ALLW'         , name:'Adjustment 3 allowance'} ];
	var applyValueList  = [ {code:'PAY', name:'PAY (paid amount)'}, {code:'ADJ', name:'ADJ (pay - 100%)'} ];

	//콤보 초기화
	srchFormUtil.initCombo("paidLeaveDetailCode", code.get("paidLeaveCodeList"), {selectAll:true});
	srchFormUtil.setCalendar( { from : "effectiveDate", language:SESSION_USER.languageCode, format: 'DD/MM/YYYY' } );

   	myForm.setLayout( [
		{ name : "searchBlock",  left : 0, right : 0, top : 0 },
		{ name : "rateControls", left : 0, right : 0, top : "searchBlock" },
		{ name : "rateContent",  left : 0, right : 0, top : "rateControls", height : 300 },
		{ name : "mapControls",  left : 0, right : 0, top : "rateContent" },
		{ name : "mapContent",   left : 0, right : 0, top : "mapControls", bottom : 0 }
	]);

 	// 그리드 선언
	var rateGrid = buildRateGrid('.plRateGrid');
	var mapGrid  = buildMapGrid('.plItemMapGrid');

	// 조회조건 저장 처리
	myForm.searchConditionControl(true);

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

		case 'addRate':
			fncAddRow(rateGrid, {
				paidLeaveDetailCode : srchFormUtil.getValue("paidLeaveDetailCode"),
				empCategoryCode     : 'ALL',
				tierNo              : 1,
				fromDays            : 1,
				baseAmountType      : 'BASE_SALARY',
				baseSalaryRate      : 0, positionAllwRate : 0, jobAllwRate : 0, qualificationAllwRate : 0,
				adj1AllwRate        : 0, adj2AllwRate : 0, adj3AllwRate : 0,
				startDate           : DateUtil.today("DD/MM/YYYY"),
				endDate             : '31/12/4712'
			}, 'paidLeaveDetailCode');
			break;
		case 'copyRate':
			//선택 행 복사 : 새 적용기간 등록용
			var gv = rateGrid.getGridBase();
			var cur = gv.getCurrent();
			if(cur.itemIndex < 0) {
				Message.alert('<lgcom:message code="note.nodata"/>');
				return;
			}
			var src = gv.getValues(cur.itemIndex);
			delete src.plRateId;
			src.startDate = DateUtil.today("DD/MM/YYYY");
			src.endDate   = '31/12/4712';
			fncAddRow(rateGrid, src, 'startDate');
			break;
		case 'deleteRate':
			rateGrid.getGridBase().deleteSelection(true);
			break;
		case 'saveRate':
			if(!fncValidateRate()) return;
			fncSave(rateGrid, 'lgvpay/LGVPAY00033/savePlRate');
			break;

		case 'addMap':
			fncAddRow(mapGrid, {
				paidLeaveDetailCode : srchFormUtil.getValue("paidLeaveDetailCode"),
				tierNo              : 1,
				applyValueType      : 'PAY'
			}, 'paidLeaveDetailCode');
			break;
		case 'deleteMap':
			mapGrid.getGridBase().deleteSelection(true);
			break;
		case 'saveMap':
			if(!fncValidateMap()) return;
			fncSave(mapGrid, 'lgvpay/LGVPAY00033/savePlItemMap');
			break;
		}
	});

	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});

	//Search
	function search() {
		var param = srchFormUtil.getValue();
		rateGrid.getGridBase().cancel();
		mapGrid.getGridBase().cancel();
		rateGrid.loadData("lgvhr", "lgvpay/LGVPAY00033/retrievePlRateList", param);
		mapGrid.loadData("lgvhr", "lgvpay/LGVPAY00033/retrievePlItemMapList", param);
	}

	function fncAddRow(grid, values, focusColumn) {
		var gv = grid.getGridBase();
		try {
			gv.commit();
		} catch(e) {
			Message.alert(e.message);
			return;
		}
		gv.beginAppendRow();
		gv.commit();
		var idx = gv.getItemCount() - 1;
		for(var key in values) {
			if(values.hasOwnProperty(key) && values[key] !== undefined) {
				gv.setValue(idx, key, values[key]);
			}
		}
		gv.setCurrent({itemIndex:idx, column:focusColumn});
		gv.setFocus();
	}

	function fncSave(grid, url) {
		var gv = grid.getGridBase();
		try {
			gv.commit();
		} catch(e) {
			Message.alert(e.message);
			return;
		}
		if(!grid.isChanged()) {
			Message.alert('<lgcom:message code="error.noChangedData"/>');
			return;
		}
		Message.confirm('<lgcom:message code="question.save"/>', function() {
			grid.useProgress(true);
			grid.saveChanges('lgvhr', url, srchFormUtil.getValue(), function(data) {
				Message.alert('<lgcom:message code="note.saved"/>');
				search();
			});
		});
	}

	//DD/MM/YYYY -> YYYYMMDD
	function fncToYmd(value) {
		if(isNull(value)) return '';
		var arr = String(value).split('/');
		if(arr.length != 3) return '';
		return arr[2] + arr[1] + arr[0];
	}

	//변경 행만 반환
	function fncChangedRows(grid) {
		var gv = grid.getGridBase();
		var provider = grid.getDataProvider();
		var rows = [];
		for(var i = 0; i < gv.getItemCount(); i++) {
			var state = provider.getRowState(gv.getDataRow(i));
			if(state == 'created' || state == 'updated') {
				var row = gv.getValues(i);
				row.itemIndex = i;
				rows.push(row);
			}
		}
		return rows;
	}

	function fncValidateRate() {
		try { rateGrid.getGridBase().commit(); } catch(e) { Message.alert(e.message); return false; }
		var rows = fncChangedRows(rateGrid);
		for(var i = 0; i < rows.length; i++) {
			var r = rows[i], msg = '';
			if(isNull(r.paidLeaveDetailCode) || isNull(r.empCategoryCode) || isNull(r.tierNo) || isNull(r.fromDays) || isNull(r.startDate)) {
				msg = '<lgcom:message code="error.required" arguments="PL Type / Category / Tier / From Days / Start Date"/>';
			} else if(!isNull(r.toDays) && Number(r.toDays) < Number(r.fromDays)) {
				msg = 'From Days <= To Days';
			} else if(!isNull(r.endDate) && fncToYmd(r.startDate) > fncToYmd(r.endDate)) {
				msg = 'Start Date <= End Date';
			} else {
				var rates = [r.baseSalaryRate, r.positionAllwRate, r.jobAllwRate, r.qualificationAllwRate, r.adj1AllwRate, r.adj2AllwRate, r.adj3AllwRate];
				for(var k = 0; k < rates.length; k++) {
					if(!isNull(rates[k]) && (Number(rates[k]) < 0 || Number(rates[k]) > 100)) {
						msg = 'Rate : 0 ~ 100 (%)';
						break;
					}
				}
			}
			if(msg != '') {
				rateGrid.getGridBase().setCurrent({itemIndex:r.itemIndex});
				Message.alert(msg);
				return false;
			}
		}
		return true;
	}

	function fncValidateMap() {
		try { mapGrid.getGridBase().commit(); } catch(e) { Message.alert(e.message); return false; }
		var rows = fncChangedRows(mapGrid);
		for(var i = 0; i < rows.length; i++) {
			var r = rows[i];
			if(isNull(r.paidLeaveDetailCode) || isNull(r.tierNo) || isNull(r.componentCode) || isNull(r.payrollItemId)) {
				mapGrid.getGridBase().setCurrent({itemIndex:r.itemIndex});
				Message.alert('<lgcom:message code="error.required" arguments="PL Type / Tier / Component / Payroll Item"/>');
				return false;
			}
		}
		return true;
	}

	/***  내부 함수  ***/
	function comboCol(name, text, width, lookupId, required) {
		return { name:name, fieldName:name, width:width,
		         header:{text:text, required:!!required}, styles:{textAlignment:'center'},
		         lookupDisplay:true, lookupSourceId:lookupId, lookupKeyFields:[name],
		         editor:{type:'dropDown', textReadOnly:true} };
	}
	function numCol(name, text, width, required) {
		return { name:name, fieldName:name, width:width,
		         header:{text:text, required:!!required}, styles:{textAlignment:'far', numberFormat:'#,##0.##'},
		         editor:{type:'number', textAlignment:'far', editFormat:'#,##0.##'} };
	}
	function dateCol(name, text, required) {
		return { name:name, fieldName:name, width:100,
		         header:{text:text, required:!!required}, styles:{textAlignment:'center'},
		         editor:{type:'date', datetimeFormat:'dd/MM/yyyy', maxLength:10}, editButtonVisibility:'visible' };
	}
	//그리드 옵션 : setOptions 가 옵션 객체를 변경하므로 그리드마다 새 객체 생성
	function getGridOptions() {
		return {
		grid: {
			hideDeletedRows: false,
			indicator: {visible:false},
			panel: {visible:false},
			checkBar: {visible:false},
			footer: {visible:false},
			paste: {enabled:false},
			sorting  : {enabled:false},
            sortMode : "explicit",
			edit: { insertable: true, appendable: true, updatable: true, deletable: true },
			header: {height: 50}
		},
		dataProvider: { insertable: true, updatable: true, deletable: true, softDeleting: true, deleteCreated: true },
		display: { fitStyle: 'none' }
		};
	}

	function buildRateGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setFields([
		    { fieldName: 'plRateId'              , dataType:'text'},
		    { fieldName: 'paidLeaveDetailCode'   , dataType:'text'},
		    { fieldName: 'empCategoryCode'       , dataType:'text'},
		    { fieldName: 'tierNo'                , dataType:'number'},
		    { fieldName: 'fromDays'              , dataType:'number'},
		    { fieldName: 'toDays'                , dataType:'number'},
		    { fieldName: 'baseAmountType'        , dataType:'text'},
		    { fieldName: 'baseSalaryRate'        , dataType:'number'},
		    { fieldName: 'positionAllwRate'      , dataType:'number'},
		    { fieldName: 'jobAllwRate'           , dataType:'number'},
		    { fieldName: 'qualificationAllwRate' , dataType:'number'},
		    { fieldName: 'adj1AllwRate'          , dataType:'number'},
		    { fieldName: 'adj2AllwRate'          , dataType:'number'},
		    { fieldName: 'adj3AllwRate'          , dataType:'number'},
		    { fieldName: 'startDate'             , dataType:'text'},
		    { fieldName: 'endDate'               , dataType:'text'},
		    { fieldName: 'note'                  , dataType:'text'}
		]);
		grid.setLookups({
			plCode       : code.get("paidLeaveCodeList"),
			empCategory  : empCategoryList,
			baseAmount   : baseAmountList
		});
		grid.setColumns([
			comboCol('paidLeaveDetailCode', '<lgcom:message code="label.pay.plDetailCode"/>', 110, 'plCode', true),
			comboCol('empCategoryCode', '<lgcom:message code="label.pay.plEmpCategory"/>', 90, 'empCategory', true),
			numCol('tierNo'  , '<lgcom:message code="label.pay.plTierNo"/>'  , 70, true),
			numCol('fromDays', '<lgcom:message code="label.pay.plFromDays"/>', 80, true),
			numCol('toDays'  , '<lgcom:message code="label.pay.plToDays"/>'  , 80, false),
			comboCol('baseAmountType', '<lgcom:message code="label.pay.plBaseAmountType"/>', 120, 'baseAmount', true),
			{ type:'group', name:'rateGroup', width:700, orientation:'horizontal',
			  header:{text:'<lgcom:message code="label.pay.plRate"/>'},
			  columns:[ numCol('baseSalaryRate'       , '<lgcom:message code="label.pay.baseSalary"/>'            , 100),
			            numCol('positionAllwRate'     , '<lgcom:message code="label.pay.positionAllowance"/>'     , 100),
			            numCol('jobAllwRate'          , '<lgcom:message code="label.pay.jobAllowance"/>'          , 100),
			            numCol('qualificationAllwRate', '<lgcom:message code="label.pay.qualificationAllowance"/>', 100),
			            numCol('adj1AllwRate'         , '<lgcom:message code="label.pay.adjustmentAllowance1"/>'  , 100),
			            numCol('adj2AllwRate'         , '<lgcom:message code="label.pay.adjustmentAllowance2"/>'  , 100),
			            numCol('adj3AllwRate'         , '<lgcom:message code="label.pay.adjustmentAllowance3"/>'  , 100) ] },
			dateCol('startDate', '<lgcom:message code="StartDate"/>', true),
			dateCol('endDate'  , '<lgcom:message code="EndDate"/>'  , false),
			{ name:'note', fieldName:'note', width:250, header:{text:'<lgcom:message code="note"/>'}, editor:{maxLength:500} }
		]);
		grid.setOptions($.extend(true, getGridOptions(), {grid:{fixed:{colCount:3}}}));
		grid.setContextMenu();
		return grid;
	}

	function buildMapGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setFields([
		    { fieldName: 'plItemMapId'         , dataType:'text'},
		    { fieldName: 'paidLeaveDetailCode' , dataType:'text'},
		    { fieldName: 'tierNo'              , dataType:'number'},
		    { fieldName: 'componentCode'       , dataType:'text'},
		    { fieldName: 'payrollItemId'       , dataType:'text'},
		    { fieldName: 'applyValueType'      , dataType:'text'},
		    { fieldName: 'note'                , dataType:'text'}
		]);
		grid.setLookups({
			plCode      : code.get("paidLeaveCodeList"),
			component   : componentList,
			payrollItem : payrollItemList,
			applyValue  : applyValueList
		});
		grid.setColumns([
			comboCol('paidLeaveDetailCode', '<lgcom:message code="label.pay.plDetailCode"/>', 110, 'plCode', true),
			numCol('tierNo', '<lgcom:message code="label.pay.plTierNo"/>', 70, true),
			comboCol('componentCode', '<lgcom:message code="label.pay.plComponent"/>', 200, 'component', true),
			$.extend(comboCol('payrollItemId', 'Payroll Item', 280, 'payrollItem', true), {styles:{textAlignment:'near'}}),
			comboCol('applyValueType', '<lgcom:message code="label.pay.plApplyValueType"/>', 150, 'applyValue', true),
			{ name:'note', fieldName:'note', width:300, header:{text:'<lgcom:message code="note"/>'}, editor:{maxLength:500} }
		]);
		grid.setOptions(getGridOptions());
		grid.setContextMenu();
		return grid;
	}
}

LGVPAY00033.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGVPAY00033();
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
						<col width="120"/>
						<col width="180"/>
						<col width="120"/>
						<col width="180"/>
						<col width="*"/>
					</colgroup>
					<tbody>
						<tr>
		                    <th><label><lgcom:message code="label.pay.plDetailCode"/></label></th>
		                	<td><select class="form-control input-sm" name="paidLeaveDetailCode"></select></td>
		                	<th><label><lgcom:message code="label.pay.effectiveDate"/></label></th>
		                	<td>
		                		<span class="form-inline">
		                			<input type="text" class="form-control input-sm size_80" name="effectiveDate" placeholder="dd/mm/yyyy" readonly />
		                			<button type="button" class="btn btn-ico" aria-label="calendar">
		                				<span class="ico ico-calendar" aria-hidden="true"></span>
		                			</button>
		                		</span>
		                	</td>
		                	<td></td>
						</tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search"/></button>
			</form>
		</div>
		<%-- 지급률 --%>
		<div class="rateControls module-group clearfix">
			<h3 class="title pull-left"><lgcom:message code="label.pay.plRateSetup"/></h3>
			<div class="btn-toolbar pull-right">
				<div class="btn-group">
					<button class="btn btn-default btn-sm ico-lgd" type="button" data-action="addRate"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="Add"/></button>
					<button class="btn btn-default btn-sm" type="button" data-action="copyRate">Copy</button>
					<button class="btn btn-default btn-sm ico-lgd" type="button" data-action="deleteRate"><span class="fa fa-minus" aria-hidden="true"></span> <lgcom:message code="Delete"/></button>
				</div>
				<div class="btn-group">
					<button class="btn btn-darkgray btn-sm" type="button" data-action="saveRate" data-access="LGVPAY00033/savePlRate"><lgcom:message code="save"/></button>
				</div>
			</div>
		</div>
		<div class="rateContent grid-wrap">
			<div class="grid plRateGrid"></div>
		</div>
		<%-- 급여항목 매핑 --%>
		<div class="mapControls module-group clearfix">
			<h3 class="title pull-left"><lgcom:message code="label.pay.plItemMapping"/></h3>
			<div class="btn-toolbar pull-right">
				<div class="btn-group">
					<button class="btn btn-default btn-sm ico-lgd" type="button" data-action="addMap"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="Add"/></button>
					<button class="btn btn-default btn-sm ico-lgd" type="button" data-action="deleteMap"><span class="fa fa-minus" aria-hidden="true"></span> <lgcom:message code="Delete"/></button>
				</div>
				<div class="btn-group">
					<button class="btn btn-darkgray btn-sm" type="button" data-action="saveMap" data-access="LGVPAY00033/savePlItemMap"><lgcom:message code="save"/></button>
				</div>
			</div>
		</div>
		<div class="mapContent grid-wrap">
			<div class="grid plItemMapGrid"></div>
		</div>
	</section>
</div>
</body>
</html>
