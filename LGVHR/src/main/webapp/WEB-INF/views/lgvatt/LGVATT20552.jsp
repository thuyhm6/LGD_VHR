<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVATT20552.jsp
    프로젝트명 : 베트남 근태 급여 시스템 구축

   Copyright(c) 2017 LG CNS,  All rights reserved..

    설 명 : Swap weekly holiday master
    작성자 : HMS - HMS_20210703
-------------------------------------------------------------%>
<c:set var="ui_bizform_id" value="${param.bizFormId}" />
<html lang="ko">
<head>
<title>Swap Weekly Holiday Master</title>
<script src="/lgvhr/static/js/lgvatt.js"></script>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVATT20552 = function() {
	var _this = this;	
	var grid;
	var searchForm = new FormUtil(_this, '.search-wrap');
	
	/* 팝업용 변수 선언 */
	_this.popupInfo = {
        userPopup   : {searchMode:'single', popupKind:'', confirmKind:'', employeeNo:'', employeeName:'', userData:[]},
        returnPopup : {returnComment:''}
    };
	
	_this.popupInfoOrg = {
	        orgPopup   : {searchMode:'single', popupKind:'', confirmKind:'', orgName:'', orgData:[]},
	        returnPopup : {returnComment:''}
	};

	// 화면 레이아웃 정의(결재선 셋팅 후 화면 레이아웃 확정되기 때문에 마지막에 셋팅한다.)
	_this.setLayout([
		{ name : "searchBlock", left : 0, right : 0, top : 0 },
		{ name : "gridControls", left : 0, right : 0, top : "searchBlock" },
	    { name : "gridContent", left : 0, right : 0, top : "gridControls", bottom : 0 }
	]);
	
    // 코드 데이터 조회(그리드 콤보 셋팅하기 위해 사용함.)
	// combo 목록 조회
	var code = new CommonCode("lgcom");
	code.add("approvalStatusList", {codeTypeCode:"LGCOM_APPROVAL_REQ_STATUS_CODE"});
	code.execute();
	
	// 전체 조직 리스트를 ValueSet으로 사용하기위한 조회
	var allOrgList = {};
	_this.transaction_sync("lgvhr", "lgvatt/LGVATTCOMM/retrieveAllOrgList", {}, function(data) { 
		if ( data.result.length > 0 ) {
			allOrgList = data.result;
		}
	});
	
	var confirmFlagList = [ {code: 'Y', name: 'Confirmed'}, {code: 'N', name: 'Not Yet'}, {code: 'R', name: 'Rejected'} ];
	
    searchForm.initCombo( "confirmFlag", confirmFlagList, { selectAll: true });
    searchForm.initCombo("approvaStatusCode", code.get("approvalStatusList"), {selectAll:true});
	
    var dateFrom = DateUtil.format(DateUtil.today().add(-1,'month').set('date',1), 'DD/MM/YYYY');

    searchForm.setValue( {
    	requestStartDate : dateFrom,
        requestEndDate : DateUtil.today("DD/MM/YYYY"),
        confirmFlag : 'N'
    });

    searchForm.setCalendar( { from : "requestStartDate", to : "requestEndDate", language:SESSION_USER.languageCode, format: 'DD/MM/YYYY' } );
	
	// 그리드 초기화
    grid = buildGrid(".swapHolidayMasterGrid");
    var gridView = grid.getGridBase();
    var provider = grid.getDataProvider();
	  
    // 화면에 필요한 초기데이터 조회

    // 개인화조건
    
    // 조회조건 저장 처리
    _this.searchConditionControl( true );    
    
    _this.addEvent('submit', searchForm, function(event) {
        event.preventDefault();
    });
    
    // 날짜 팝업창
    
    // 필수항목 체크
    
    // 일반함수	
    
	/*** 이벤트 핸들러  ***/
	// 버튼제어
	_this.addEvent('click','button[data-action]',function(event) {
		var action = $(this).data("action");	
		var itemIndex = gridView.getCurrent().itemIndex;	
		
		switch(action) {
			case 'search' :
				fncSearchRequestSwapHoliday();
				break;
			case 'reject' :
				fncUpdateSwapHolidayByHR('R');
				break;
			case 'confirm' :
				fncUpdateSwapHolidayByHR('Y');
				break;
			case 'excelDown' :
				grid.getGridBase().exportGrid({
	    			target: "local",
	    			lookupDisplay: true,
		    		showProgress: true,
		    		done: function() {
		    			Message.alert("Excel exporting completed!!");
		    		}
		    	});
				break;
				// 유저 검색 팝업
		    case "openPopupUser" :
                var _popup = _this.popupInfo.userPopup;
                _popup.searchMode   = "single";
                _popup.popupKind    = "";
                _popup.confirmKind  = "";
                _popup.employeeNo = searchForm.getValue("empNo");
                _popup.employeeName = searchForm.getValue("empName");

                var popup = new Popup( _this,'lgvhr', 'M_LGVCOM_1010', '<lgcom:message code="UserSearch"/>' );
                popup.setSize(800,494);
                popup.open( function(){
                	searchForm.setValue({empNo   :_popup.userData[0].employeeNo});
                	searchForm.setValue({empName :_popup.userData[0].employeeName});
                	searchForm.setValue({orgId   :_popup.userData[0].organizationId});
                	searchForm.setValue({orgName :_popup.userData[0].organizationName});
                });
                _popup.userData = [];
                break;
            // 조직 검색 팝업
		    case "openPopupOrg" :
                var _popup = _this.popupInfoOrg.orgPopup;
                _popup.searchMode   = "single";
                _popup.popupKind    = "";
                _popup.confirmKind  = "";
                _popup.orgName = searchForm.getValue("orgName");
                
                var popup = new Popup( _this,'lgvhr', 'M_LGVCOM_1014', 'Org Search' );
                popup.setSize(800,494);
                popup.open( function(){
                	searchForm.setValue({orgId   :_popup.orgData[0].organizationId});
                	searchForm.setValue({orgName :_popup.orgData[0].organizationName});
                });
                _popup.orgData = [];
                break;
		}
	}); 
   
    gridView.onEditChange = function (cgrid, index, value) {
	    
	};
	
    gridView.onEditCommit = function(cgrid, index, oldValue, newValue) {
    	
    };
    
    gridView.onCellEdited = function(cgrid, itemIndex, dataRow, field) {
    	cgrid.commit();
    	cgrid.checkItem(itemIndex, true, false);
    	var fieldName = provider.getOrgFieldName(field);
    	if(fieldName === 'weeklyHoliday'){
    		for(var i=0; i<cgrid.getDataProvider().getRowCount(); i++) {
    			if((cgrid.getValue(itemIndex, fieldName) == cgrid.getValue(i, fieldName) && i != itemIndex) && 
    					(cgrid.getValue(itemIndex, 'employeeNo') == cgrid.getValue(i, 'employeeNo') && i != itemIndex)) {
    				Message.alert("<lgcom:message code='note.att.dupUser'/>");
    				cgrid.setValue(itemIndex, fieldName, null);
    				return;
    			}
    		}
    		fncWeeklyHolidayChage(cgrid, itemIndex, fieldName);
    	}else if(fieldName === 'workingDay'){
    		for(var i=0; i<cgrid.getDataProvider().getRowCount(); i++) {
    			if((cgrid.getValue(itemIndex, fieldName) == cgrid.getValue(i, fieldName) && i != itemIndex) && 
    					(cgrid.getValue(itemIndex, 'employeeNo') == cgrid.getValue(i, 'employeeNo') && i != itemIndex)) {
    				Message.alert("<lgcom:message code='note.att.dupUser'/>");
    				cgrid.setValue(itemIndex, fieldName, null);
    				return;
    			}
    		}
    		fncWeeklyHolidayChage(cgrid, itemIndex, fieldName);
    	}
    };  
    
	grid.getGridBase().onDataCellClicked =  function (cgrid, index) {
		
	};
	var controlColumns = {
        editColumn : ["weeklyHoliday","workingDay","timeAttendInputReasonDesc"]
    };
	grid.getGridBase().addCellStyles([
                 {
                      id: "unableEdit",
                      background: '#e9e9e9',
                      editable: false
                      },
                 {
                 id: "enableEdit",
                  background: 'none',
                 editable: true
                }
             ]);
	// 그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(_this, gridId, true);
		var gridReadOnyBgColor = "#e9e9e9";
		grid.setPagingMode(true);
		
		//필드 설정
		grid.setFields(
				[
					{ fieldName:'requestSeqNo'         		, dataType:'text'},
					{ fieldName:'requestNo'         		, dataType:'text'},
					{ fieldName:'employeeOrg'            	, dataType:'text'},
					{ fieldName:'employeeNo'	     	    , dataType:'text'},
					{ fieldName:'employeeName'			    , dataType:'text'},
					{ fieldName:'shiftTypeCode'             , dataType:'text'},
					{ fieldName:'weeklyHoliday'             , dataType:'text'},
					{ fieldName:'weeklyHolidayShiftTypeCode', dataType:'text'},
					{ fieldName:'resultWhShiftTypeCode'     , dataType:'text'},
				    { fieldName:'workingDay'                , dataType:'text'},
				    { fieldName:'workingDayShiftTypeCode'   , dataType:'text'},
				    { fieldName:'resultNwShiftTypeCode'     , dataType:'text'},
					{ fieldName:'requestSeqNo'              , dataType:'text'},
					{ fieldName:'requestMasterId'  		    , dataType:'text'},
					{ fieldName:'requestCode'            	, dataType:'text'},
					{ fieldName:'approvalStatus'  		    , dataType:'text'},
					{ fieldName:'confirmFlag'            	, dataType:'text'},
					{ fieldName:'approvalStatusCode'        , dataType:'text'},
					{ fieldName:'timeAttendInputReasonDesc' , dataType:'text'},
					{ fieldName:'progressStatusCode'        , dataType:'text'},
					{ fieldName:'creationDate'          	, dataType:'text'},
				    { fieldName:'creationUserId'          	, dataType:'text'}
				]
		);
		//컬럼 콤보 셋팅
		grid.setLookupsMultiLvl({
	                             "orgList": { data: allOrgList },
	                             "confirmFlagList": { data: confirmFlagList }
			                   });
		//컬럼 설정 
		grid.setColumns(
				[
					{	name:'requestSeqNo',
						fieldName:'requestSeqNo',
						width:0,
						header: {text:'<lgcom:message code="label.att.requestNo"/>'},
						styles: {textAlignment:'center', background:gridReadOnyBgColor},
						editable: false
					},
					{	name:'progressStatusCode',
						fieldName:'progressStatusCode',
						width:0,
						header: {text:'<lgcom:message code="label.att.requestNo"/>'},
						styles: {textAlignment:'center', background:gridReadOnyBgColor},
						editable: false
					},
					{	name:'requestNo',
						fieldName:'requestNo',
						width:150,
						header: {text:'<lgcom:message code="label.att.requestNo"/>'},
						styles: {textAlignment:'center', background:gridReadOnyBgColor},
						editable: false
					},
					{	name:'employeeOrg',
						fieldName:'employeeOrg',
						width:220,
						header: {text:'<lgcom:message code="label.att.organization"/>'},
						styles: {textAlignment:'near', background:gridReadOnyBgColor},
						lookupDisplay: true,
						lookupSourceId: 'orgList',
						lookupKeyFields: ["employeeOrg"],
						editable:false
					},					
					{	name:'employeeNo',
						fieldName:'employeeNo',
						width:70,
						header: {text:'<lgcom:message code="label.att.id"/>'},
						styles: {textAlignment:'center', background:gridReadOnyBgColor},
						editable:false
					},
					{	name:'employeeName',
						fieldName:'employeeName',
						width:180,
						header: {text:'<lgcom:message code="label.att.employeeName"/>'},
						styles: {textAlignment:'near', background:gridReadOnyBgColor },	
						editable: false,						
					},
					{	name:'shiftTypeCode',
						fieldName:'shiftTypeCode',
						width:0,
						header: {text:'<lgcom:message code="label.att.shiftType"/>'},
						styles: {textAlignment:'near', background:gridReadOnyBgColor},
						editable: false
					},
					{
						type:'group',
						name:'weeklyHoliday',
						fieldName:'weeklyHoliday',
						width:230,
						header:{
					         text:'<lgcom:message code="label.att.weeklyHoliday" />',
					         fixedHeight: 25
					    },
						orientation:'horizontal',
						columns: [
									{	name:'weeklyHoliday',
										fieldName:'weeklyHoliday',
										width:120,
										header: {text:'<lgcom:message code="label.att.date"/>'},
										styles: {textAlignment:'center'},						
										editor: {type:'date',datetimeFormat:'dd/MM/yyyy'},
										editable: true
									},
									{	name:'weeklyHolidayShiftTypeCode',
										fieldName:'weeklyHolidayShiftTypeCode',
										width:100,
										header: {text:'<lgcom:message code="label.att.swapShiftType"/>'},
										styles: {textAlignment:'center', background:gridReadOnyBgColor},
										editable: false
									},
									{	name:'resultWhShiftTypeCode',
										fieldName:'resultWhShiftTypeCode',
										width:100,
										header: {text:'<lgcom:message code="label.att.currentShiftType"/>'},
										styles: {textAlignment:'center', background:gridReadOnyBgColor},
										editable: false
									}
						         ]
					},
					{
						type:'group',
						name:'workingDay',
						fieldName:'workingDay',
						width:230,
						header:{
					         text:'<lgcom:message code="label.att.workingDay" />',
					         fixedHeight: 25
					    },
						orientation:'horizontal',
						columns: [
									{	name:'workingDay',
										fieldName:'workingDay',
										width:120,
										header: {text:'<lgcom:message code="label.att.date"/>'},
										styles: {textAlignment:'center'},						
										editor: {type:'date',datetimeFormat:'dd/MM/yyyy'},
										editable: true
									},
									{	name:'workingDayShiftTypeCode',
										fieldName:'workingDayShiftTypeCode',
										width:100,
										header: {text:'<lgcom:message code="label.att.swapShiftType"/>'},
										styles: {textAlignment:'center', background:gridReadOnyBgColor},
										editable: false
									},
									{	name:'resultNwShiftTypeCode',
										fieldName:'resultNwShiftTypeCode',
										width:100,
										header: {text:'<lgcom:message code="label.att.currentShiftType"/>'},
										styles: {textAlignment:'center', background:gridReadOnyBgColor},
										editable: false
									}
						         ]
					},
					{	name:'timeAttendInputReasonDesc',
						fieldName:'timeAttendInputReasonDesc',
						width:200,
					    renderer: {showTooltip: true},
						header: {text:'<lgcom:message code="label.att.timeAttendInputReasonDesc"/>'},
						styles: {textAlignment:'near'},
						editable: true
					},
					{	name:'approvalStatus',
						fieldName:'approvalStatus',
						width:100,
						header: {text:'<lgcom:message code="label.att.approvalStatus"/>'},
						styles: {textAlignment:'near', background:gridReadOnyBgColor},
						editable: false
					},
					{	name:'confirmFlag',
						fieldName:'confirmFlag',
						width:100,
						header: {text:'<lgcom:message code="label.att.confirmFlag"/>'},
						styles: {textAlignment:'center', background:gridReadOnyBgColor},
						lookupDisplay: true,
						lookupSourceId: 'confirmFlagList',
						lookupKeyFields: ['confirmFlag'],
						editable: false
					},
					{
						name:'lastUpdateDate',
						fieldName:'lastUpdateDate',
						width:120,
						header: {text:'<lgcom:message code="LastUpdatedDate" />'},
						styles: {textAlignment:'center'},
						editable : false
					},
					{
						name:'lastUpdateUserId',
						fieldName:'lastUpdateUserId',
						width:100,
						header: {text:'<lgcom:message code="LastUpdatedBy" />'},
						styles: {textAlignment:'near'},
						editable : false
					}
				]
		);
		//옵션 설정 
		grid.setOptions({
			grid: {
				softDeleting: true,
				deleteCreated: true,
				hideDeletedRows:true,
				indicator: {visible: false},
				panel: {visible:false},
				checkBar: {
					visible:true, 
					checkableExpression: "((values['progressStatusCode'] = '20') or (values['progressStatusCode'] = '30')) "
				},
				stateBar: {visible:false},
				footer: {visible: false},
				paste: {enabled: false},
				select: 'block',
				edit: {
					insertable: false,
					appendable: false,
					updatable: true,
					deletable: true
				},
				header: {height: 50, heightFill: 'fixed', showTooltip: true},
				fixed: { colCount: 4, resizable:true }
			},
			display: { fitStyle: 'none' }
		});
		
		grid.getGridBase().setSortingOptions({
			enabled: false
		});
		
		// Context Menu Set
		grid.setContextMenu();
		//그리드 필수값 체크
		return grid;
	}
	
function fncWeeklyHolidayChage(cgrid, itemIndex, fieldName){
		
		var weeklyHoliday = gridView.getValue(itemIndex,'weeklyHoliday');
		var workingDay = gridView.getValue(itemIndex, 'workingDay');
		var employeeNo = gridView.getValue(itemIndex, 'employeeNo');
		
		if (isNull(employeeNo) ) {
			gridView.setValue(itemIndex, 'workingDay', null);
			gridView.setValue(itemIndex, 'weeklyHoliday', null);
			Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.id'/>"/>');
			return false;
		}
		if (!isNull(workingDay) && !isNull(weeklyHoliday)) {
			if (workingDay.substring(10,3) != weeklyHoliday.substring(10,3)) {
				gridView.setValue(itemIndex, 'workingDay', null);
				gridView.setValue(itemIndex, 'weeklyHoliday', null);
				Message.alert("<lgcom:message code='label.att.mustChooseSameMonth'/>");
			} else {
			var paramDate = {
					subsidiaryCode : '${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}',
					weeklyHoliday : weeklyHoliday, 
					workingDay : workingDay,
					employeeNo : employeeNo
				};
			_this.showProgress();
			transaction_sync("lgvhr", "lgvatt/LGVATT20552/checkLockDate", paramDate, function(data) {
				if (data.result.length > 0) {
					gridView.setValue(itemIndex, 'workingDay', null);
					gridView.setValue(itemIndex, 'weeklyHoliday', null);
					Message.alert("<lgcom:message code="note.att.attendanceDateLocked"/>" + " or " + "<lgcom:message code="note.att.existRequest"/>");
					return;
				}
			}); 
			_this.showProgress();
			transaction_sync("lgvhr", "lgvatt/LGVATT20551/checkWorkingTime", paramDate, function(data) {
				gridView.setValue(itemIndex, 'workingDayShiftTypeCode', data.result.workingDayShiftTypeCode);
				gridView.setValue(itemIndex, 'weeklyHolidayShiftTypeCode', data.result.weeklyHolidayShiftTypeCode);
				_this.hideProgress();
			}); 
			}
		}
		var workCode = '';
		if (fieldName == 'weeklyHoliday') {
			workCode = 'WH';
			attendanceDate = weeklyHoliday;
		} else {
			workCode = 'NW';
			attendanceDate = workingDay;
		}
		var param = {
			subsidiaryCode : '${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}',
			attendanceDate : attendanceDate, 
			employeeNo : employeeNo,
			workCode : workCode
		};
		
		_this.showProgress();
		transaction_sync("lgvhr", "lgvatt/LGVATT20551/checkAttendanceDate", param, function(data) {
			if(data.result.count <= 0) {
				gridView.setValue(itemIndex, 'workingDay', null);
				gridView.setValue(itemIndex, 'weeklyHoliday', null);
				if (fieldName == 'weeklyHoliday') {
					Message.alert("<lgcom:message code='label.att.mustChooseWeeklyHoliday'/>");
				} else {
					Message.alert("<lgcom:message code='label.att.mustChooseWorkingDay'/>");
				}
			}
			_this.hideProgress();
		}); 
		
	}
	
	function fncUpdateSwapHolidayByHR(actionType) {
		var cMsg = '<lgcom:message code="question.save"/>';
		
		if(actionType == "R") {
			cMsg = '<lgcom:message code="question.att.reject"/>';
		} else if(actionType == "Y") {
			cMsg = '<lgcom:message code="question.confirm"/>';
		} else {
			cMsg = '<lgcom:message code="question.save"/>';
		}
		
		try {
			grid.getGridBase().commit();
		} catch(e) {
			Message.alert(e.message);
			return;
		}
			
		var checkedRows = grid.getGridBase().getCheckedRows(true);
		
		if( checkedRows.length > 0 ) {
			
			var param = {};
			var arr = [];
			
			for(var i=0; i<checkedRows.length; i++) {
				arr.push(grid.getDataProvider().getJsonRow(checkedRows[i]));
				if(actionType == "R") {
					if (grid.getDataProvider().getJsonRow(checkedRows[i]).confirmFlag != "Y") {
						Message.alert('<lgcom:message code="note.att.canNotReject"/>');
						return;
					}
				} if(actionType == "Y") {
					if (grid.getDataProvider().getJsonRow(checkedRows[i]).confirmFlag == "Y") {
						Message.alert('<lgcom:message code="note.att.canNotConfirm"/>');
						return;
					}
					
					if (grid.getDataProvider().getJsonRow(checkedRows[i]).workingDayShiftTypeCode != grid.getDataProvider().getJsonRow(checkedRows[i]).resultNwShiftTypeCode
					   || grid.getDataProvider().getJsonRow(checkedRows[i]).weeklyHolidayShiftTypeCode != grid.getDataProvider().getJsonRow(checkedRows[i]).resultWhShiftTypeCode) {
						Message.alert('<lgcom:message code="note.att.workScheduleChange"/> ' + grid.getDataProvider().getJsonRow(checkedRows[i]).employeeNo);
						return;
					}
				}
			}
			
			param["modifyList"] = arr;
			param["actionType"] = actionType;
			
		} else {
			Message.alert('<lgcom:message code="error.noChangedData"/>');
			return;
		}
		
		Message.confirm(cMsg, function() {
			_this.showProgress();
			_this.transaction("lgvhr", "lgvatt/LGVATT20552/saveSwapMasterManage", param, function( data ){

				Message.alert( '<lgcom:message code="note.completed" />' );
				_this.select(".search-wrap button[data-action='search']").trigger('click');
				_this.hideProgress();
			});
		});	
	}
    
	function fncSearchRequestSwapHoliday(){
		
		var param = searchForm.getValue();
		var dateFrom = param.requestStartDate;
		var dateTo = param.requestEndDate;	
		
		if( isNull(dateFrom) ) {
			Message.alert("<lgcom:message code="note.att.emptyRequestDate"/>.");
			return;
		}else{
			if(!isValidDate(dateFrom)) {
				Message.alert("<lgcom:message code="note.att.emptyRequestDate"/>.");
				return;
			}
		}
		
		if( isNull(dateTo) ) {
			Message.alert("<lgcom:message code="note.att.emptyRequestDate"/>.");
			return;
		}else{
			if(!isValidDate(dateTo)) {
				Message.alert("<lgcom:message code="note.att.emptyRequestDate"/>.");
				return;
			}
		}
		
		if(!isValidDateBetween(dateFrom, dateTo)) {
			Message.alert("<lgcom:message code="note.att.emptyRequestDate"/>.");
			return;
		}
		grid.loadData("lgvhr", "lgvatt/LGVATT20552/retrieveSwapMaster", param, function (data) {
			if(data.result){
				for(var i=0; i<data.result.length; i++) {
					if(data.result[i].progressStatusCode == "40" || data.result[i].progressStatusCode == "50" || data.result[i].progressStatusCode == "60" || 
					   data.result[i].progressStatusCode == "70" || data.result[i].confirmFlag == "Y") {
						grid.getGridBase().setCellStyles(i, controlColumns.editColumn, "unableEdit");
					} else {
						grid.getGridBase().setCellStyles(i, controlColumns.editColumn, "enableEdit");
					}
					
				}
			}	
		});
	}	
	
	// 화면 로드 후 실행 시작
	_this.myFormInit = function(){
		// searchForm 초기 셋팅
		
	};
}

LGVATT20552.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVATT20552();
		form.init();
		form.myFormInit();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2>Confirm Special OT</h2>
		</div>
		<%-- 조회 화면 --%>
		<div class="searchBlock">
			<form class="form search-wrap">
				<input type="hidden" name="orgId"/>
				<table class="table">
					<colgroup>
						<col width="90"/>
						<col width="220"/>
						<col width="60"/>
						<col width="*"/>
					</colgroup>
					<tbody>
						<tr>
		                    <th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.att.requestDate"/></label></th>
		                    <td>
		                        <div class="form-inline">
                                <input type="text" class="form-control input-sm input-require" name="requestStartDate" id="<c:out value="${ui_bizform_id}"/>_requestStartDate" placeholder="dd/mm/yyyy" style="width: 85px;" maxlength="10" onkeyup="return auto_date_format(event, this)" onkeypress="auto_date_format(event, this)">
                                ~
                                <input type="text" class="form-control input-sm input-require" name="requestEndDate" id="<c:out value="${ui_bizform_id}"/>_requestEndDate" placeholder="dd/mm/yyyy" style="width: 85px;" maxlength="10" onkeyup="return auto_date_format(event, this)" onkeypress="auto_date_format(event, this)">
                                <button type="button" id="setSingleDateSample" class="btn btn-ico" aria-label="calendar">
							        <span class="ico ico-calendar" aria-hidden="true"></span>
							    </button>
                            	</div>
		                    </td>
		                    
		                    <th scope="col"><label><lgcom:message code="label.att.confirmFlag"/></label></th>
							<td><select class="form-control input-sm input-require" name="confirmFlag" ></select></td>
							
							<th scope="col"><label><lgcom:message code="label.att.approvalStatus"/></label></th>
							<td><select class="form-control input-sm input-require" name="approvaStatusCode" ></select></td>		
		                </tr>
		                <tr>
							<th><label><lgcom:message code="label.att.organization" /></label></th>
							<td>
		                		<div class="input-group input-group-sm input-search">
	                                <input class="form-control input-sm _find_origin_" name="orgName" type="text">
	                                <span class="input-group-btn">
	                                    <button class="btn btn-default ico-lgd find" type="button" data-action="openPopupOrg">
	                                        <span class="fa fa-search" aria-hidden="true"></span>
	                                    </button>
	                                </span>
	                            </div>
		                	</td>
		                
		                	<th><label><lgcom:message code="label.att.employeeNo2" /></label></th>
							<td>
		                		<div class="input-group input-group-sm input-search">
	                                <input class="form-control input-sm _find_origin_" name="empNo" type="text">
	                                <span class="input-group-btn">
	                                    <button class="btn btn-default ico-lgd find" type="button" data-action="openPopupUser">
	                                        <span class="fa fa-search" aria-hidden="true"></span>
	                                    </button>
	                                </span>
	                            </div>
		                	</td>
							
							<th><label><lgcom:message code="label.att.employeeName" /></label></th>
							<td><input type="text" class="form-control input-sm" name="empName" readonly></td>
		                </tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
			</form>
		</div>			
		
		<%-- 리스트 화면 --%>
		<div class="gridControls module-group text-right">
            <div class="btn-toolbar">
                <div class="btn-group">
                    <button class="btn btn-default btn-sm" type="button" data-action="excelDown"><span class="ico ico-excel-down"></span><lgcom:message code="Download"/></button>
                    <button class="btn btn-gray btn-sm" type="submit" data-action="reject"><lgcom:message code="Reject"/></button>
                    <button class="btn btn-gray btn-sm" type="submit" data-action="confirm"><lgcom:message code="button.att.confirm"/></button>
                </div>
            </div>
        </div>
		<div class="gridContent grid-wrap">
			<div class="grid swapHolidayMasterGrid"></div>
		</div>
		
	</section>
</div>
</body>
</html>
