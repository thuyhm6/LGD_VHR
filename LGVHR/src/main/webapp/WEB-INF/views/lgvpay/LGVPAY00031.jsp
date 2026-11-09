<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY00031.jsp
    프로젝트명 : 베트남 근태 급여 시스템 구축

   Copyright(c) 2017 LG CNS,  All rights reserved..

    설 명 : Paid Leave Registration (PL_SW / PL_PLP)
            1) 등록 / 엑셀 업로드  2) Apply to T&A (근태 계획/실적을 PL + 상세코드로 변경)
            -> 금액 계산은 LGVPAY00032, 지급률 설정은 LGVPAY00033
    작성자 : HMT_20251201
    수정   : HMT_20261026 Rebuild
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVPAY00031 = function() {
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

	//콤보 초기화
	srchFormUtil.initCombo("paidLeaveDetailCode", code.get("paidLeaveCodeList"), {selectAll:false});

   	myForm.setLayout( [
		{ name : "searchBlock",  left : 0, right : 0, top : 0 },
		{ name : "gridControls", left : 0, right : 0, top : "searchBlock" },
		{ name : "gridContent",  left : 0, right : 0, top : "gridControls", bottom : 0 }
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
	    	payMonth            : {required:true},
	    	paidLeaveDetailCode : {required:true}
	    },
	    messages: {
	    	payMonth            : {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.month'/>" />'},
	    	paidLeaveDetailCode : {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.plDetailCode'/>" />'}
	    }
    });

 	// 그리드 선언
	var grid = buildGrid('.paidLeaveEmployeeGrid');
	var gridView = grid.getGridBase();

	// 조회조건 저장 처리
	myForm.searchConditionControl(true);

	// 팝업 데이터 정의 searchMode:single(단수),multi(복수)
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

		case 'insert':
			if(!validator.isValid()) return;
			try {
				gridView.commit();
			} catch(e) {
				Message.alert(e.message);
				return;
			}
			var curr = gridView.getCurrent();
			if(curr.itemIndex < 0) {
				gridView.beginAppendRow();
			} else {
				gridView.beginInsertRow(curr.itemIndex);
			}
			gridView.setCurrent({column:'employeeNo'});
			gridView.setFocus();
			break;

		case 'delete':
			gridView.deleteSelection(true);
			break;

		case 'save':
			try {
				gridView.commit();
			} catch(e) {
				Message.alert(e.message);
				return;
			}
			if(!grid.isChanged()) {
				Message.alert('<lgcom:message code="error.noChangedData"/>');
				return;
			}
			if(!fncValidateSave()) return;

			Message.confirm('<lgcom:message code="question.save"/>', function() {
				grid.useProgress(true);
				grid.saveChanges('lgvhr','lgvpay/LGVPAY00031/savePaidLeaveEmp', srchFormUtil.getValue(), function(data) {
					Message.alert('<lgcom:message code="note.saved"/>');
					search();
				});
			});
			break;

		case 'deleteAll':
			if(!validator.isValid()) return;
			Message.confirm('<lgcom:message code="note.pay.deleteAll"/>', function() {
				myForm.showProgress();
				myForm.transaction('lgvhr','lgvpay/LGVPAY00031/deleteAllPaidLeaveInMonth', srchFormUtil.getValue(), function(data) {
					myForm.hideProgress();
					Message.alert('<lgcom:message code="note.successfullyDelete"/>');
					search();
				}, function (data) { myForm.hideProgress(); });
			});
			break;

		case 'applyAtt':
			//등록 기간을 근태(계획/실적)에 반영
			if(!validator.isValid()) return;
			if(grid.isChanged()) {
				Message.alert('<lgcom:message code="question.save"/>');
				return;
			}
			Message.confirm('<lgcom:message code="label.pay.plApplyAtt"/> ?', function() {
				myForm.showProgress();
				myForm.transaction("lgvhr", "lgvpay/LGVPAY00031/saveCalculateAttendancePL", srchFormUtil.getValue(), function (data) {
					myForm.hideProgress();
					var r = data.result || {};
					Message.alert('<lgcom:message code="note.completed"/>' + ' (Plan : ' + (r.planCnt || 0) + ', Actual : ' + (r.actualCnt || 0) + ')');
					search();
				}, function (data) { myForm.hideProgress(); });
			});
			break;

		case 'excelDownload':
			if(validator.isValid()) {
				Message.confirm('<lgcom:message code="question.excelDownload"/>',function() {
					var downloader = new Downloader( myForm );
					downloader.excel( "lgvhr", "lgvpay/LGVPAY00031/createExcelExportData", srchFormUtil.getValue() );
				});
			}
			break;

		case 'excelUpload':
			//업로드 양식 : Employee No / Employee Name / Start Date / End Date (DD/MM/YYYY) / Note
			if(!validator.isValid()) return;
			var uploader = new ExcelUploader("lgvhr", "LGVPAY00031", {});
			uploader.open( processExcelUploadPostProcess );
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
	//사번 또는 성명 클릭 시 값 초기화
    myForm.addEvent ( "click", ".searchBlock form input[name='employeeNo'], input[name='employeeName']", function(event) {
    	fncSearchEmpInfoInit();
    });
    myForm.addEvent ( "keydown", ".searchBlock form input[name='employeeNo']", function(event) {
		if(event.keyCode == 13) {
			myForm.select(".searchBlock button[data-action='openPopupApprover']").trigger('click');
		}
	});
  	//사번, 성명값 초기화
	function fncSearchEmpInfoInit() {
		srchFormUtil.setValue({employeeNo : '', employeeName : ''});
	}

	//신규행만 사번 입력 가능
	gridView.onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		var editable = newRow < 0 || cgrid.getDataProvider().getRowState(newRow) === 'created';
		cgrid.setColumnProperty('employeeNo','editable',editable);
		cgrid.setColumnProperty('employeeNo','button',editable ? 'action' : 'none');
	};
	//employeeNo 클릭 시 user검색 팝업호출
	gridView.onCellButtonClicked = function(cgrid, itemIndex, column) {
		cgrid.commitEditor();
		emplyoeePopup(itemIndex);
	};
	gridView.onCellEdited = function(cgrid, itemIndex, dataRow, field){
		cgrid.commit();
	};

	//Search
	function search() {
		if(!validator.isValid()) return;
		gridView.cancel();
		grid.loadData("lgvhr", "lgvpay/LGVPAY00031/retrievePaidLeaveEmpList", srchFormUtil.getValue(), function(data) {
			if( grid.getRowCount() == 0 ) {
				Message.alert('<lgcom:message code="note.nodata"/>');
			}
		});
	}

	//DD/MM/YYYY -> YYYYMMDD
	function fncToYmd(value) {
		if(isNull(value)) return '';
		var arr = String(value).split('/');
		if(arr.length != 3) return '';
		return arr[2] + arr[1] + arr[0];
	}

	//저장 전 체크 : 필수, 시작일 <= 종료일
	function fncValidateSave() {
		var provider = gridView.getDataProvider();
		for(var i = 0; i < gridView.getItemCount(); i++) {
			var dataRow = gridView.getDataRow(i);
			var state = provider.getRowState(dataRow);
			if(state != 'created' && state != 'updated') continue;

			var row = gridView.getValues(i);
			if(isNull(row.employeeNo) || isNull(row.startDate) || isNull(row.endDate)) {
				gridView.setCurrent({itemIndex:i, column:'employeeNo'});
				Message.alert('<lgcom:message code="error.required" arguments="Employee No / Start Date / End Date"/>');
				return false;
			}
			var s = fncToYmd(row.startDate), e = fncToYmd(row.endDate);
			if(s.length != 8 || e.length != 8 || s > e) {
				gridView.setCurrent({itemIndex:i, column:'startDate'});
				Message.alert('[' + row.employeeNo + '] Start Date <= End Date (DD/MM/YYYY)');
				return false;
			}
		}
		return true;
	}

	//user 검색팝업
	function emplyoeePopup(rowIdx) {
		myForm.popupInfo.userPopup = { searchMode : "single", fseYn:"N", flsaYn:"N", userData:[] };
		var popup = new Popup( _this,'lgvhr', 'M_LGVCOM_1010', '<lgcom:message code="UserSearch"/>' );
		popup.setSize( 1000, 528 );
		popup.open( function(){
			var array = myForm.popupInfo.userPopup.userData;
			if(array.length == 0) return;
			transaction('lgvhr','lgvpay/LGVPAY00031/retrieveEmployeeInfo',{'employeeNo':array[0].employeeNo}, function(data) {
				var r = data.result;
				gridView.setValue(rowIdx,'employeeNo',r.employeeNo);
				gridView.setValue(rowIdx,'employeeName',r.employeeName);
				gridView.setValue(rowIdx,'organizationName',r.organizationName);
				gridView.setValue(rowIdx,'empCategoryName',r.empCategoryName);
				gridView.setValue(rowIdx,'shiftTypeName',r.shiftTypeName);
				gridView.setValue(rowIdx,'dateHireSubsidiary',r.dateHireSubsidiary);
				gridView.setValue(rowIdx,'dateRetire',r.dateRetire);
			});
		});
	}

	function processExcelUploadPostProcess( sessionId ) {
		var param = srchFormUtil.getValue();
		param.sessionId = sessionId;
		//반드시 transaction_sync 를 써야합니다 !!
		transaction_sync('lgvhr','lgvpay/LGVPAY00031/createPaidLeaveEmpUpload',param, function(data) {
			Message.notify('<lgcom:message code="note.completed"/>');
			search();
		});
	}

	/***  내부 함수  ***/
	//그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		grid.setFields([
		    { fieldName: 'paidLeaveId'          , dataType:'text'},
		    { fieldName: 'paymentYyyymm'        , dataType:'text'},
		    { fieldName: 'paidLeaveDetailCode'  , dataType:'text'},
		    { fieldName: 'employeeNo'           , dataType:'text'},
		    { fieldName: 'employeeName'         , dataType:'text'},
		    { fieldName: 'employeeNameLocal'    , dataType:'text'},
		    { fieldName: 'startDate'            , dataType:'text'},
		    { fieldName: 'endDate'              , dataType:'text'},
		    { fieldName: 'calendarDays'         , dataType:'number'},
		    { fieldName: 'attAppliedDays'       , dataType:'number'},
		    { fieldName: 'note'                 , dataType:'text'},
		    { fieldName: 'organizationName'     , dataType:'text'},
		    { fieldName: 'empCategoryName'      , dataType:'text'},
		    { fieldName: 'shiftTypeName'        , dataType:'text'},
		    { fieldName: 'dateHireSubsidiary'   , dataType:'text'},
		    { fieldName: 'dateRetire'           , dataType:'text'}
		]);
		grid.setColumns([
			{ name:'employeeNo', fieldName:'employeeNo', width:100,
			  header: {text:'<lgcom:message code="label.pay.employeeNo"/>', required:true},
			  styles: {textAlignment:'center'}, button:'action', editable:false },
			{ name:'employeeName', fieldName:'employeeName', width:200,
			  header: {text:'<lgcom:message code="EmployeeEngName"/>'}, renderer:{showTooltip:true}, editable:false },
			{ name:'startDate', fieldName:'startDate', width:110,
			  header: {text:'<lgcom:message code="label.att.startDate"/>', required:true}, styles:{textAlignment:'center'},
			  editor: {type:'date', datetimeFormat:'dd/MM/yyyy', maxLength:10}, editButtonVisibility:'visible' },
			{ name:'endDate', fieldName:'endDate', width:110,
			  header: {text:'<lgcom:message code="label.att.endDate"/>', required:true}, styles:{textAlignment:'center'},
			  editor: {type:'date', datetimeFormat:'dd/MM/yyyy', maxLength:10}, editButtonVisibility:'visible' },
			{ name:'calendarDays', fieldName:'calendarDays', width:80,
			  header: {text:'Days'}, styles:{textAlignment:'far', numberFormat:'#,##0'}, editable:false },
			{ name:'attAppliedDays', fieldName:'attAppliedDays', width:110,
			  header: {text:'T&A PL Days'}, styles:{textAlignment:'far', numberFormat:'#,##0'}, editable:false },
			{ name:'note', fieldName:'note', width:250,
			  header: {text:'<lgcom:message code="note"/>'}, editor:{maxLength:255} },
			{ name:'organizationName', fieldName:'organizationName', width:250,
			  header: {text:'<lgcom:message code="label.pay.organizationName"/>'}, editable:false },
			{ name:'empCategoryName', fieldName:'empCategoryName', width:80,
			  header: {text:'<lgcom:message code="label.pay.plEmpCategory"/>'}, styles:{textAlignment:'center'}, editable:false },
			{ name:'shiftTypeName', fieldName:'shiftTypeName', width:120,
			  header: {text:'<lgcom:message code="label.pay.workType"/>'}, editable:false },
			{ name:'dateHireSubsidiary', fieldName:'dateHireSubsidiary', width:100,
			  header: {text:'<lgcom:message code="label.pay.hireDate"/>'}, styles:{textAlignment:'center'}, editable:false },
			{ name:'dateRetire', fieldName:'dateRetire', width:100,
			  header: {text:'<lgcom:message code="label.pay.resignationDate"/>'}, styles:{textAlignment:'center'}, editable:false }
		]);
		grid.setOptions({
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
				header: {height: 30},
				fixed: { colCount: 2 }
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
		grid.setContextMenu();
		return grid;
	}
}

LGVPAY00031.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGVPAY00031();
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
		                    <th><label class="required"><lgcom:message code="label.pay.plDetailCode"/></label></th>
		                	<td><select class="form-control input-sm input-require" name="paidLeaveDetailCode"></select></td>
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
					<button class="btn btn-gray btn-sm" type="button" data-action="applyAtt" data-access="LGVPAY00031/saveCalculateAttendancePL"><lgcom:message code="label.pay.plApplyAtt"/></button>
			    </div>
				<div class="btn-group">
			        <button type="button" class="btn btn-default btn-sm" data-action="excelDownload"><span class="ico ico-excel-down" aria-hidden="true"></span> <lgcom:message code="Download"/></button>
					<button type="button" class="btn btn-default btn-sm" data-action="excelUpload"><span class="ico ico-excel-up"></span> <lgcom:message code="Upload"/></button>
				</div>
				<div class="btn-group">
					<button class="btn btn-default btn-sm ico-lgd" type="button" data-action="insert"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="Add"/></button>
					<button class="btn btn-default btn-sm ico-lgd" type="button" data-action="delete"><span class="fa fa-minus" aria-hidden="true"></span> <lgcom:message code="Delete"/></button>
				</div>
				<div class="btn-group">
					<button class="btn btn-darkgray btn-sm" type="button" data-action="save" data-access="LGVPAY00031/savePaidLeaveEmp"><lgcom:message code="save"/></button>
				</div>
				<div class="btn-group">
					<button class="btn btn-default btn-sm ico-lgd" type="button" data-action="deleteAll" data-access="LGVPAY00031/deleteAllPaidLeaveInMonth"><span class="fa fa-minus" aria-hidden="true"></span> <lgcom:message code="Delete All"/></button>
				</div>
			</div>
		</div>
		<div class="gridContent grid-wrap">
			<div class="grid paidLeaveEmployeeGrid"></div>
		</div>
	</section>
</div>
</body>
</html>
