<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVATT30080.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2018 LG CNS,  All rights reserved.

    설 명 : 본 화면은 사무직 / 기능직 직원의 특별연장근무실적 중 최종 승인된 리스트를 HR근태담당자가 Confirm 하는 화면
    		
    작성자 : 이형준
    HMT_20210410     Add month ot total, month ot limit and attendance name
-------------------------------------------------------------%>
<c:set var="ui_bizform_id" value="${param.bizFormId}" />
<html lang="ko">
<head>
<title>Confirm Special OT</title>
<script src="/lgvhr/static/js/lgvatt.js"></script>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVATT30080 = function() {
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
	code.add( "workTm", {codeTypeCode:'LGVHR_ATT_WORK_START_TIME'} );
	code.add( "nightFlag", {codeTypeCode:'LGVHR_DAY_NIGHT_FLAG'} );
	code.add("approvalStatusList", {codeTypeCode:"LGVHR_ATT_APPROVAL_STATUS"});
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
	
	//searchForm.initCombo("approvalStatusCode", code.get("approvalStatusList"), {selectAll:true});
    var dateFrom = DateUtil.format(DateUtil.today().add(-1,'month').set('date',1), 'DD/MM/YYYY');

    searchForm.setValue( {
    	requestStartDate : dateFrom,
        requestEndDate : DateUtil.today("DD/MM/YYYY"),
        confirmFlag : 'N'
    });

    searchForm.setCalendar( { from : "requestStartDate", to : "requestEndDate", language:SESSION_USER.languageCode, format: 'DD/MM/YYYY' } );
	
	// 그리드 초기화
    grid = buildGrid(".specialOvertimeGrid");
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
				fncSearchRequestSpectialOt();
				break;
			case 'save' :
				fncUpdateSpecialOTByHR('N');
				break;
			case 'reject' :
				fncUpdateSpecialOTByHR('R');
				break;
			case 'confirm' :
				fncUpdateSpecialOTByHR('Y');
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
    };  
    
	grid.getGridBase().onDataCellClicked =  function (cgrid, index) {
		
	};

	// 그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(_this, gridId, true);
		var gridReadOnyBgColor = "#e9e9e9";
		grid.setPagingMode(true);
		
		//필드 설정
		grid.setFields(
				[
					{ fieldName:'requestNo'         		, dataType:'text'  },
					{ fieldName:'employeeOrg'            	, dataType:'text'  },
					{ fieldName:'employeeNo'	     	    , dataType:'text'  },
					{ fieldName:'employeeName'			    , dataType:'text'  },
					{ fieldName:'timeAndAttendanceDate'	    , dataType:'text'  },
					{ fieldName:'shiftTypeCode'             , dataType:'text'  },
					{ fieldName:'nightShiftFlag'            , dataType:'text'  },
					{ fieldName:'time'             			, dataType:'text'  },
					{ fieldName:'workStartTime'             , dataType:'text'  },
					{ fieldName:'workEndTime'             	, dataType:'text'  },
					{ fieldName:'timeAttendInputReasonDesc' , dataType:'text'  },
					{ fieldName:'overtimeSumHours'          , dataType:'number'},
					{ fieldName:'attendanceName'            , dataType:'text'},//HMT_20210410
					{ fieldName:'monthTotalOvertime'        , dataType:'number'},//HMT_20210410
					{ fieldName:'overtimeLimit'             , dataType:'number'},//HMT_20210410
					{ fieldName:'actualOT'          		, dataType:'text'  },
					{ fieldName:'weekdayOvertimeHours'      , dataType:'number'},
					{ fieldName:'holidayOvertimeHours'      , dataType:'number'},
					{ fieldName:'publicHolidayOvertimeHours', dataType:'number'},
					{ fieldName:'actualOTNight'				, dataType:'text'  },
					{ fieldName:'weekdayNightOvertimeHours' , dataType:'number'},
					{ fieldName:'weekdayOtAfNightWorkHours' , dataType:'number'},
					{ fieldName:'holidayNightOvertimeHours' , dataType:'number'},
					{ fieldName:'publicHolidayNightOtHours' , dataType:'number'},
					{ fieldName:'requestMasterId'  		    , dataType:'text'  },
					{ fieldName:'requestCode'            	, dataType:'text'  },
					{ fieldName:'approvalStatus'  		    , dataType:'text'  },
					{ fieldName:'confirmFlag'            	, dataType:'text'  },
					{ fieldName:'approvalStatusCode'        , dataType:'text'  }
				]
		);
		//컬럼 콤보 셋팅
		grid.setLookupsMultiLvl({
	                             "nightFlag": code.get("nightFlag"),
	                             "orgList": { data: allOrgList },
	                             "confirmFlagList": { data: confirmFlagList },
	                             "workTime": { data: code.get("workTm"), keyField:["code"] }
			                   });
		//컬럼 설정 
		grid.setColumns(
				[
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
						width:120,
						header: {text:'<lgcom:message code="label.att.employeeName"/>'},
						styles: {textAlignment:'near', background:gridReadOnyBgColor },	
						editable: false,						
					},
					{	name:'timeAndAttendanceDate',
						fieldName:'timeAndAttendanceDate',
						width:80,
						header: {text:'<lgcom:message code="label.att.date"/>'},
						styles: {textAlignment:'center', background:gridReadOnyBgColor},
						editable: false
					},
					{	name:'attendanceName',
						fieldName:'attendanceName',
						width:100,
						header: {text:'<lgcom:message code="label.att.actualAttendanceDetail"/>'},
						styles: {textAlignment:'near', background:gridReadOnyBgColor},						
						editable: false
					},
					{	name:'shiftTypeCode',
						fieldName:'shiftTypeCode',
						width:50,
						header: {text:'<lgcom:message code="label.att.shiftType"/>'},
						styles: {textAlignment:'near', background:gridReadOnyBgColor},
						editable: false
					},					
					{	name:'nightShiftFlag',
						fieldName:'nightShiftFlag',
						width:40,
						header: {text:'<lgcom:message code="label.att.actualDayNight"/>'},
						styles: {textAlignment:'near', background:gridReadOnyBgColor},						
						lookupDisplay: true,
						lookupSourceId: 'nightFlag',
						lookupKeyFields: ['nightShiftFlag'],
						editable : false						
					},
					{	type:'group',
						name:'time',
						fieldName:'time',
						width:150,
						header:{
					         text:'<lgcom:message code="Time" />', fixedHeight:20
					    },
						orientation:'horizontal',
						columns: [
									{	name:'workStartTime',
										fieldName:'workStartTime',
										width:50,
										header: {text:'<lgcom:message code="StartTime"/>'},
										styles: {textAlignment:'center', background:gridReadOnyBgColor},
										lookupDisplay: true,
										lookupSourceId: 'workTime',
										lookupKeyFields: ['workStartTime'],
										editor: {type:'dropDown',textReadOnly:true},
										editable: false
									},
									{	name:'workEndTime',
										fieldName:'workEndTime',
										width:50,
										header: {text:'<lgcom:message code="EndTime"/>'},
										styles: {textAlignment:'center', background:gridReadOnyBgColor},
										lookupDisplay: true,
										lookupSourceId: 'workTime',
										lookupKeyFields: ['workEndTime'],
										editor: {type:'dropDown',textReadOnly:true},
										editable: false
									},
									{	name:'overtimeSumHours',
										fieldName:'overtimeSumHours',
										width:50,
										header: {text:'<lgcom:message code="label.att.totalOT"/>'},
										styles: {textAlignment:'far', numberFormat: '#0.0' },
										editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
										editable: true
									},
								]
					},
					//HMT_20210410 Start
					{	name:'monthTotalOvertime',
						fieldName:'monthTotalOvertime',
						width:40,
						header: {text:'<lgcom:message code="label.att.monthTotalOT"/>'},
						styles: {textAlignment:'far', background: gridReadOnyBgColor, numberFormat: '#0.0'},
						editable: false
					},
					{	name:'overtimeLimit',
						fieldName:'overtimeLimit',
						width:40,
						header: {text:'<lgcom:message code="label.att.monthOtLimit"/>'},
						styles: {textAlignment:'far', background: gridReadOnyBgColor, numberFormat: '#0.0'},
						editable: false
					},
					//HMT_20210410 End
					{	name:'timeAttendInputReasonDesc',
						fieldName:'timeAttendInputReasonDesc',
						width:200,
					    renderer: {showTooltip: true},
						header: {text:'<lgcom:message code="label.att.timeAttendInputReasonDesc"/>'},
						styles: {textAlignment:'near'},
						editable: true
					},
					{	type:'group',
						name:'actualOT',
						fieldName:'actualOT',
						width:150,
						header:{
					         text:'<lgcom:message code="label.att.actualOT" />', fixedHeight:30
					    },
						orientation:'horizontal',
						columns: [
									{	name:'weekdayOvertimeHours',
										fieldName:'weekdayOvertimeHours',
										width:50,
										header: {text:'<lgcom:message code="label.att.actualOTWeekDay2" />', tooltip:'<lgcom:message code="label.att.actualOTWeekDay"/>'},
										styles: {textAlignment:'far', numberFormat: '#0.0'},
										editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
										editable: true
									},
									{	name:'holidayOvertimeHours',
										fieldName:'holidayOvertimeHours',
										width:50,
										header: {text:'<lgcom:message code="label.att.actualOTWeekDayHoliday2" />', tooltip:'<lgcom:message code="label.att.actualOTWeekDayHoliday"/>'},
										styles: {textAlignment:'far', numberFormat: '#0.0'},
										editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
										editable: true
									},
									{	name:'publicHolidayOvertimeHours',
										fieldName:'publicHolidayOvertimeHours',
										width:50,
										header: {text:'<lgcom:message code="label.att.actualOTPublicHoliday2" />', tooltip:'<lgcom:message code="label.att.actualOTPublicHoliday"/>'},
										styles: {textAlignment:'far', numberFormat: '#0.0'},
										editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
										editable: true
									}
								]
					},
					{	type:'group',
						name:'actualOTNight',
						fieldName:'actualOTNight',
						width:200,
						header:{
					         text:'<lgcom:message code="label.att.actualOTNight" />', fixedHeight:30
					    },
						orientation:'horizontal',
						columns: [
									{	name:'weekdayNightOvertimeHours',
										fieldName:'weekdayNightOvertimeHours',
										width:50,
										header: {text:'<lgcom:message code="label.att.actualOTNightWeekDay2" />', tooltip:'<lgcom:message code="label.att.actualOTNightWeekDay"/>'},
										styles: {textAlignment:'far', numberFormat: '#0.0'},
										editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
										editable: true
									},
									{	name:'weekdayOtAfNightWorkHours',
										fieldName:'weekdayOtAfNightWorkHours',
										width:50,
										header: {text:'<lgcom:message code="label.att.actualOTNightWeekDayAfterOT2" />', tooltip:'<lgcom:message code="label.att.actualOTNightWeekDayAfterOT"/>'},
										styles: {textAlignment:'far', numberFormat: '#0.0'},
										editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
										editable: true
									},
									{	name:'holidayNightOvertimeHours',
										fieldName:'holidayNightOvertimeHours',
										width:50,
										header: {text:'<lgcom:message code="label.att.actualOTNightWeekDayHoliday2" />', tooltip:'<lgcom:message code="label.att.actualOTNightWeekDayHoliday"/>'},
										styles: {textAlignment:'far', numberFormat: '#0.0'},
										editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
										editable: true
									},
									{	name:'publicHolidayNightOtHours',
										fieldName:'publicHolidayNightOtHours',
										width:50,
										header: {text:'<lgcom:message code="label.att.actualOTNightPublicHoliday2" />', tooltip:'<lgcom:message code="label.att.actualOTNightPublicHoliday"/>'},
										styles: {textAlignment:'far', numberFormat: '#0.0'},
										editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
										editable: true
									}
								]
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
						width:70,
						header: {text:'<lgcom:message code="label.att.confirmFlag"/>'},
						styles: {textAlignment:'center', background:gridReadOnyBgColor},
						lookupDisplay: true,
						lookupSourceId: 'confirmFlagList',
						lookupKeyFields: ['confirmFlag'],
						editable: false
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
					checkableExpression: "(values['confirmFlag'] = 'N') and (values['approvalStatusCode'] = 'FA')"
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
	
	function fncUpdateSpecialOTByHR(actionType) {
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
			}
			
			param["modifyList"] = arr;
			param["actionType"] = actionType;
			
		} else {
			Message.alert('<lgcom:message code="error.noChangedData"/>');
			return;
		}
		
		Message.confirm(cMsg, function() {
			_this.showProgress();
			_this.transaction("lgvhr", "lgvatt/LGVATT30080/updateSpecialOTByHR", param, function( data ){

				Message.alert( '<lgcom:message code="note.completed" />' );
				_this.select(".search-wrap button[data-action='search']").trigger('click');
				_this.hideProgress();
			});
		});	
	}
    
	function fncSearchRequestSpectialOt(){
		
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
		
		grid.loadData("lgvhr", "lgvatt/LGVATT30080/retrieveSpecialOtRequestList", param);
	}	
	
	// 화면 로드 후 실행 시작
	_this.myFormInit = function(){
		// searchForm 초기 셋팅
		
	};
}

LGVATT30080.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVATT30080();
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
                    <button class="btn btn-gray btn-sm" type="submit" data-action="save"><lgcom:message code="save"/></button>
                    <button class="btn btn-gray btn-sm" type="submit" data-action="reject"><lgcom:message code="Reject"/></button>
                    <button class="btn btn-gray btn-sm" type="submit" data-action="confirm"><lgcom:message code="button.att.confirm"/></button>
                </div>
            </div>
        </div>
		<div class="gridContent grid-wrap">
			<div class="grid specialOvertimeGrid"></div>
		</div>
		
	</section>
</div>
</body>
</html>
