<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="devonframe.util.DateUtil" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%---------------------------------------------------------
    파일명 : LGVATT30060.jsp
    프로젝트명 : LGD BizWeb

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : T&A Monthly Report
    작성자 : 이형준S
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>T&A Monthly Report</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<style type="text/css">
</style>
<script type="text/javascript">

var LGVATT30060 = function(){
    var grid;
    var _this = this;
    var myForm = this;
    var formUtil = new FormUtil(myForm,'.searchBlock form');
    
    /* Layout Setting 하측 고정, 상측 Flexible*/
	myForm.setLayout( [ 
		{ name  : "searchBlock", left : 0, right : 0, top : 0 },		
		{ name  : "gridControls", left : 0, right : 0, top : "searchBlock"},
		{ name  : "content1", left : 0, right : 0, top : "gridControls", bottom : 0 }
	]);

  	//검색조건에 값을 입력하고 조회하면 방금 입력한 값을 저장하여 화면에 고정값으로 셋팅 
    myForm.searchConditionControl( true );
  	
  	//날짜 설정
    formUtil.setCalendar( { from : "fromDate", to : "toDate", language:SESSION_USER.languageCode, format: 'DD/MM/YYYY' } );
    
    formUtil.setValue( {
    	fromDate : DateUtil.format(DateUtil.today().set('date', 1), 'DD/MM/YYYY'),
        toDate : DateUtil.format(DateUtil.today().add(+1, 'month').set('date', 1), 'DD/MM/YYYY')
    });
    
	// grid & serachBlock combo
	var code = new CommonCode('lgcom');
	code.add('ynFlag',{codeTypeCode:'LGCOM_YN_FLAG'});
	code.add('dayNightFlag',{codeTypeCode:'LGVHR_DAY_NIGHT_FLAG'});
	code.add('shiftCode', {codeTypeCode:'LGVHR_SHIFT_TYPE_CODE'});
	code.add('gradeTitle', {codeTypeCode:'IF_VIETNAM_GRADE_TITLE'});
	code.execute();
	
	var valueSet = new ValueSet("lgcom");
	valueSet.add('attCode', {valueSetId : 'LGVATT_ATTEND_DETAIL'});
	valueSet.add('attTypeName', {valueSetId : 'LGVATT_ATTEND_TYPE_UPDATE_ENABLE'});
	valueSet.add("attendanceDetailCodeList", {valueSetId : "LGVATT_ATTEND_DETAIL_CODE", subsidiaryCode :"${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}"} );
	valueSet.execute();
	
	// 전체 조직 리스트를 ValueSet으로 사용하기위한 조회
	var allOrgList = {};
	myForm.transaction_sync("lgvhr", "lgvatt/LGVATTCOMM/retrieveAllOrgList", {}, function(data) { 
		if ( data.result.length > 0 ) {
			allOrgList = data.result;
		}
	});
	
	formUtil.initCombo('shiftCode', code.get('shiftCode'), { selectAll: true });
	formUtil.initCombo('baseAttend', code.get('ynFlag'), { selectAll: true });
	
   	grid = buildGrid("LGVATT30060_grid");
	
	myForm.popupInfo = {
        userPopup   : {searchMode:'single', popupKind:'', confirmKind:'', employeeNo:'', employeeName:'', attDate:'', userData:[]},
        returnPopup : {returnComment:''}
    };
	
	myForm.popupInfoOrg = {
	        orgPopup   : {searchMode:'single', popupKind:'', confirmKind:'', orgName:'', orgData:[]},
	        returnPopup : {returnComment:''}
	};
	
	/*** 이벤트 핸들러  ***/
	
	this.addEvent( "click", "button[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ){
		    case "search" :
		    	grid.getGridBase().cancel();
				var param =  myForm.select(".searchBlock form").toJSON();
				
				if( isNull(formUtil.getValue("orgId")) ) {
					Message.alert('<lgcom:message code="note.att.essentialOrg"/>');
					return;
				}
				
				myForm.showProgress();
				grid.loadData('lgvhr','lgvatt/LGVATT30060/retrieveMonthlyAttList', param, function(data){
					if( data.result.length > 0 ) {
						var index = {itemIndex: 0};
						grid.getGridBase().setCurrent(index);
					} else {
						Message.alert('<lgcom:message code="note.nodata"/>');
					}
					myForm.hideProgress();
				} );
				
				break;
			// 유저 검색 팝업
		    case "openPopupUser" :
                var _popup = _this.popupInfo.userPopup;
                _popup.searchMode   = "single";
                _popup.popupKind    = "";
                _popup.confirmKind  = "";
                _popup.employeeNo = formUtil.getValue("empNo");
                _popup.employeeName = formUtil.getValue("empName");

                var popup = new Popup( _this,'lgvhr', 'M_LGVCOM_1010', '<lgcom:message code="UserSearch"/>' );
                popup.setSize(800,494);
                popup.open( function(){
                    formUtil.setValue({empNo   :_popup.userData[0].employeeNo});
                    formUtil.setValue({empName :_popup.userData[0].employeeName});
                    formUtil.setValue({orgId   :_popup.userData[0].organizationId});
                    formUtil.setValue({orgName :_popup.userData[0].organizationName});
                });
                _popup.userData = [];
                break;
            // 조직 검색 팝업
		    case "openPopupOrg" :
                var _popup = _this.popupInfoOrg.orgPopup;
                _popup.searchMode   = "single";
                _popup.popupKind    = "";
                _popup.confirmKind  = "";
                _popup.orgName = formUtil.getValue("orgName");
                
                var popup = new Popup( _this,'lgvhr', 'M_LGVCOM_1014', 'Org Search' );
                popup.setSize(800,494);
                popup.open( function(){
                    formUtil.setValue({orgId   :_popup.orgData[0].organizationId});
                    formUtil.setValue({orgName :_popup.orgData[0].organizationName});
                });
                _popup.orgData = [];
                break;
            
            // excel download monthly report
		    case "excelDown" :
		    	grid.getGridBase().exportGrid({
	    			target: "local",
	    			lookupDisplay: true,
		    		showProgress: true,
		    		done: function() {
		    			Message.alert("Excel exporting completed!!");
		    		}
		    	});
		    	break;
		}
	});
	myForm.addEvent ( "change", ".searchBlock form input[name]", function(event) {
		var item = $(event.target);
		switch ( $.trim(item.attr("name")) ) {
			case "empNo" :
				//사번이 변경된 경우 성명 삭제
				if ( nvl(formUtil.getValue("empNo")) != nvl(formUtil.getPreviousValue("empNo")) ) {
					formUtil.setValue("empName", "");
				}
				break;
		}			
		event.stopPropagation();
	});
	
	grid.getGridBase().onShowHeaderTooltip = function ( grid, column, value ) {
		if(column.fieldName == "weekday") {
			return '<lgcom:message code="label.att.actualOTWeekDay" />';
		} else if(column.fieldName == "weekdayHoliday") {
			return '<lgcom:message code="label.att.actualOTWeekDayHoliday" />';
		} else if(column.fieldName == "publicHoliday") {
			return '<lgcom:message code="label.att.actualOTPublicHoliday" />';
		} else if(column.fieldName == "atNightWeekday") {
			return '<lgcom:message code="label.att.actualOTNightWeekDay" />';
		} else if(column.fieldName == "atNightWeekdayAfterOT") {
			return '<lgcom:message code="label.att.actualOTNightWeekDayAfterOT" />';
		} else if(column.fieldName == "atNightWeekdayHoliday") {
			return '<lgcom:message code="label.att.actualOTNightWeekDayHoliday" />';
		} else if(column.fieldName == "atNightPublicHoliday") {
			return '<lgcom:message code="label.att.actualOTNightPublicHoliday" />';
		} else if(column.fieldName == "nightNormal") {
			return '<lgcom:message code="label.att.nightNormal" />';
		} else {
			return null;
		}
	};

	
	/*** 내부 함수  ***/
	
    /*** 그리드 초기 셋업  ***/
	function buildGrid(gridId) {
		var grid;
		switch(gridId){
			case 'LGVATT30060_grid':
				grid = new RealGrid(myForm, gridId, true);
				grid.setPagingMode(true, {rowSize:3000});
				//grid.setPagingMode(false);
				
				//옵션 설정
				grid.setOptions({
					grid: {
						softDeleting: false,
						deleteCreated: false,
						hideDeletedRows: false,
						indicator: {visible: false},
						panel: {visible: false},
						checkBar: {visible: false},
						stateBar: {visible: false},
						footer: {visible: false},
						paste: { enabled: false},
						sortMode: "explicit",
						edit: {
							insertable: false,
							appendable: false,
							updatable: false,
							deletable: false
						},
						header:{
					         height: 60,
					         heightFill: 'fixed',
					         showTooltip: true
					    },
					    fixed: { colCount: 2 }
					},
					dataProvider: {
						insertable: false,
						updatable: false,
						deletable: false,
						softDeleting: false,
						deleteCreated: false
					}
				});

				//마우스 오른쪽 클릭시 메뉴
				grid.setContextMenu();

				//필드 설정
				grid.setFields(
						[
							{ fieldName:'date'     						, dataType:'text'  },
							{ fieldName:'attendanceYmd'     			, dataType:'text'  },
							{ fieldName:'screenWeekName'	        	, dataType:'text'  },
						 
							{ fieldName:'employee'     					, dataType:'text'  },
							{ fieldName:'employeeOrg'	        		, dataType:'text'  },
							{ fieldName:'employeeNo'	        		, dataType:'text'  },
							{ fieldName:'employeeName' 	        		, dataType:'text'  },
							{ fieldName:'employeeGrade' 	        	, dataType:'text'  },
							
							{ fieldName:'actualAttendance'      		, dataType:'text'  },
							{ fieldName:'actualAttendanceType' 			, dataType:'text'  },
							{ fieldName:'actualAttendanceDetail'		, dataType:'text'  },
							{ fieldName:'actualAttendDetailReason'		, dataType:'text'  },
							
							{ fieldName:'actualShiftCode'         		, dataType:'text'  },
							{ fieldName:'actualDayNight'         		, dataType:'text'  },
							{ fieldName:'actualDinnerChk'         		, dataType:'text'  },
							{ fieldName:'actualStartTm'         		, dataType:'text'  },
							{ fieldName:'actualOT'	        			, dataType:'number'},
							
							{ fieldName:'headerOT'	        			, dataType:'text'},
							{ fieldName:'weekday' 	    				, dataType:'number'},
							{ fieldName:'weekdayHoliday'				, dataType:'number'},
							{ fieldName:'publicHoliday'    				, dataType:'number'},
							
							{ fieldName:'atNight'     					, dataType:'text'  },
							{ fieldName:'atNightWeekday'	       		, dataType:'number'},
							{ fieldName:'atNightWeekdayAfterOT' 		, dataType:'number'},
							{ fieldName:'atNightWeekdayHoliday'   		, dataType:'number'},
							{ fieldName:'atNightPublicHoliday'    		, dataType:'number'},
							
							{ fieldName:'night'     					, dataType:'text'  },
							{ fieldName:'nightNormal'	        		, dataType:'number'},
							
							{ fieldName:'deduction' 	    			, dataType:'text'  },
							{ fieldName:'deductionLateness'        		, dataType:'number'},
							{ fieldName:'deductionLeavingEarly'    		, dataType:'number'},
							{ fieldName:'deductionGoingOut'     		, dataType:'number'},
							{ fieldName:'deductionSubTotal'     		, dataType:'number'},
							
							{ fieldName:'specialOT'     				, dataType:'number'},
							{ fieldName:'baseAttFlag'     				, dataType:'text'}
						]
				);

				grid.setLookupsMultiLvl({
					 			'employeeGrade': code.get("gradeTitle"),
					 			'actualDayNight': code.get("dayNightFlag"),
					 			'ynFlag': code.get("ynFlag"),
					 			'attendanceDetail': valueSet.get("attCode"),
					 			'attendanceDetailReason': valueSet.get("attendanceDetailCodeList"),
					 			'attendanceType': valueSet.get("attTypeName"),
					 			'orgList': {data: allOrgList}
					 		}); 
				
				//컬럼 설정
				grid.setColumns(
						[
							{	
								type:'group',
								name:'date',
								fieldName:'date',
								width:160,
								header:{
							         text:'<lgcom:message code="label.att.date" />',
							         fixedHeight: 20
							    },
								orientation:'horizontal',
								columns: [
											{	name:'attendanceYmd',
												fieldName:'attendanceYmd',
												width:100,
												header: {text:'<lgcom:message code="label.att.date"/>'},
												styles: {textAlignment:'center'},
												editable: false
											},
											{	name:'screenWeekName',
												fieldName:'screenWeekName',
												width:60,
												header: {text:'<lgcom:message code="label.att.dayOfWeek"/>'},
												styles: {textAlignment:'near'},
												editable: false
											}
										]
							},
							{
								type:'group',
								name:'employee',
								fieldName:'employee',
								width:480,
								header:{
							         text:'<lgcom:message code="label.att.employee" />',
							         fixedHeight: 20
							    },
								orientation:'horizontal',
								columns: [
											{	name:'employeeOrg',
												fieldName:'employeeOrg',
												width:250,
												header: {text:'<lgcom:message code="label.att.organization"/>'},
												lookupDisplay: true,
												lookupSourceId: 'orgList',
												lookupKeyFields: ['employeeOrg'], 
												editable:false,
												styles: {textAlignment:'near'},
											},
								            {	name:'employeeNo',    
								            	fieldName:'employeeNo',    
								            	width:70,  
								            	header: {text:'<lgcom:message code="label.att.id" />'},	 
								            	editable: false, 
								            	styles: {textAlignment:'near'}
								            },
								            {	name:'employeeName',  
								            	fieldName:'employeeName',  
								            	width:100, 
								            	header: {text:'<lgcom:message code="label.att.employeeName" />'},	 
								            	editable: false, 
								            	styles: {textAlignment:'near'}
								            },
								            {	name:'employeeGrade', 
								            	fieldName:'employeeGrade', 
								            	width:60,  
								            	lookupDisplay: true,
												lookupSourceId: 'employeeGrade',
												lookupKeyFields: ['employeeGrade'], 
												header: {text:'<lgcom:message code="label.att.jobTitle" />'},
												editable: false,
												styles: {textAlignment:'near'}
											}
								         ]
							},
							{
								type:'group',
								name:'actualAttendance',
								fieldName:'actualAttendance',
								width:220,
								header:{
							         text:'<lgcom:message code="label.att.actualAttendance" />',
							         fixedHeight: 20
							    },
								orientation:'horizontal',
								columns: [
								            {	name:'actualAttendanceType',
								            	fieldName:'actualAttendanceType',
								            	width:60,
								            	header: {text:'<lgcom:message code="label.att.actualAttendanceType" />'},
								            	lookupDisplay: true,
												lookupSourceId: 'attendanceType',
												lookupKeyFields: ['actualAttendanceType'], 
												editable: false, 
												styles: {textAlignment:'near' }
											},
								            {	name:'actualAttendanceDetail',      
												fieldName:'actualAttendanceDetail',       
												width:80,  
												header: {text:'<lgcom:message code="label.att.actualAttendanceDetail" />'},
												lookupDisplay: true,
												lookupSourceId: 'attendanceDetail',
												lookupKeyFields: ['actualAttendanceDetail'], 
												editable: false, 
												styles: {textAlignment:'near' }
											},
											{	name:'actualAttendDetailReason',      
												fieldName:'actualAttendDetailReason',       
												width:80,  
												header: {text:'<lgcom:message code="label.att.timeAttendDetailCode" />'},
												lookupDisplay: true,
												lookupSourceId: 'attendanceDetailReason',
												lookupKeyFields: ['actualAttendDetailReason'], 
												editable: false,
												styles: {textAlignment:'near' }
											}
								         ]
							},
							{	name:'actualShiftCode',
								fieldName:'actualShiftCode',
								width:40,
								header: {text:'<lgcom:message code="label.att.actualShiftCode" />'},
								editable: false,
								styles: {textAlignment:'near' }
							},
							{	name:'actualDayNight',
								fieldName:'actualDayNight', 
								width:40,  
								header: {text:'<lgcom:message code="label.att.actualDayNight" />'}, 
								lookupDisplay: true,
								lookupSourceId: 'actualDayNight',
								lookupKeyFields: ['actualDayNight'],
								editable: false,
								styles: {textAlignment:'near' }
							},
							{	name:'actualDinnerChk',
								fieldName:'actualDinnerChk',
								width:50, 
								header: {text:'<lgcom:message code="label.att.actualDinnerChk" />'}, 
								lookupDisplay: true,
								lookupSourceId: 'ynFlag',
								lookupKeyFields: ['actualDinnerChk'],
								editable: false,
								styles: {textAlignment:'near' }
							},
							{	name:'actualStartTm', 
								fieldName:'actualStartTm', 
								width:60, 
								header: {text:'<lgcom:message code="label.att.actualStartTm" />'},
								editable: false, 
								styles: {textAlignment:'center' }
							},
							{	name:'actualOT', 
								fieldName:'actualOT',
								width:40,
								header: {text:'<lgcom:message code="label.att.totalOT" />'}, 
								editable: false,
								styles: {textAlignment:'far', numberFormat: '#0.0'},
								editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'}
							},
							{
								type:'group',
								name:'headerOT',
								fieldName:'headerOT',
								width:120,
								header:{
							         text:'<lgcom:message code="label.att.actualOT" />',
							         fixedHeight: 20
							    },
								orientation:'horizontal',
								columns: [
								            {	name:'weekday',        
								            	fieldName:'weekday',        
								            	width:40, header: {text:'<lgcom:message code="label.att.actualOTWeekDay2" />', showTooltip: true},
								            	editable: false,
								            	styles: {textAlignment:'far', numberFormat: '#0.0' }
								            },
								            {	name:'weekdayHoliday', 
								            	fieldName:'weekdayHoliday',  
								            	width:40, 
								            	header: {text:'<lgcom:message code="label.att.actualOTWeekDayHoliday2" />', showTooltip: true},
								            	editable: false, 
								            	styles: {textAlignment:'far', numberFormat: '#0.0' }
								            },
								            {	name:'publicHoliday',  
								            	fieldName:'publicHoliday', 
								            	width:40, 
								            	header: {text:'<lgcom:message code="label.att.actualOTPublicHoliday2" />', showTooltip: true},
								            	editable: false, 
								            	styles: {textAlignment:'far', numberFormat: '#0.0' }
								            }
								         ]
							},
							{
								type:'group',
								name:'atNight',
								fieldName:'atNight',
								width:160,
								header:{
							         text:'<lgcom:message code="label.att.actualOTNight" />',
							         fixedHeight: 20
							    },
								orientation:'horizontal',
								columns: [
								            {	name:'atNightWeekday',     
								            	fieldName:'atNightWeekday',   
								            	width:40, 
								            	header: {text:'<lgcom:message code="label.att.actualOTNightWeekDay2" />', showTooltip: true},
								            	editable: false,
								            	styles: {textAlignment:'far', numberFormat: '#0.0' }
								            },
								            {	name:'atNightWeekdayAfterOT', 
								            	fieldName:'atNightWeekdayAfterOT',  
								            	width:40, 
								            	header: {text:'<lgcom:message code="label.att.actualOTNightWeekDayAfterOT2" />', showTooltip: true},
								            	editable: false, 
								            	styles: {textAlignment:'far', numberFormat: '#0.0' }
								            },
								            {	name:'atNightWeekdayHoliday', 
								            	fieldName:'atNightWeekdayHoliday', 
								            	width:40,  
								            	header: {text:'<lgcom:message code="label.att.actualOTNightWeekDayHoliday2" />', showTooltip: true}, 
								            	editable: false, 
								            	styles: {textAlignment:'far', numberFormat: '#0.0' }
								            },
								            {	name:'atNightPublicHoliday',  
								            	fieldName:'atNightPublicHoliday',  
								            	width:40, 
								            	header: {text:'<lgcom:message code="label.att.actualOTNightPublicHoliday2" />', showTooltip: true},
								            	editable: false, 
								            	styles: {textAlignment:'far', numberFormat: '#0.0' }
								            }
								         ]
							},
							{
								type:'group',
								name:'night',
								fieldName:'night',
								width:40,
								header:{
							         text:'<lgcom:message code="label.att.night" />',
							         fixedHeight: 20
							    },
								orientation:'horizontal',
								columns: [
								            {	name:'nightNormal', 
								            	fieldName:'nightNormal', 
								            	width:40,
								            	header: {text:'<lgcom:message code="label.att.nightNormal2" />', showTooltip: true },
								            	editable: false, 
								            	styles: {textAlignment:'far', numberFormat: '#0.0' }
								            }
								         ]
							},
							{
								type:'group',
								name:'deduction',
								fieldName:'deduction',
								width:210,
								header:{
							         text:'<lgcom:message code="label.att.deduction" />',
							         fixedHeight: 20
							    },
								orientation:'horizontal',
								columns: [
								            {	name:'deductionLateness',   
								            	fieldName:'deductionLateness',  
								            	width:60,
								            	header: {text:'<lgcom:message code="label.att.deductionLateness" />'}, 	
								            	editable: false, 
								            	styles: {textAlignment:'far', numberFormat: '#0.0' }
								            },
								            {	name:'deductionLeavingEarly',
								            	fieldName:'deductionLeavingEarly',
								            	width:50,  
								            	header: {text:'<lgcom:message code="label.att.deductionLeavingEarly" />'}, 
								            	editable: false,
								            	styles: {textAlignment:'far', numberFormat: '#0.0' }
								            },
								            {	name:'deductionGoingOut', 	
								            	fieldName:'deductionGoingOut',  	
								            	width:50,  
								            	header: {text:'<lgcom:message code="label.att.deductionGoingOut" />'}, 
								            	editable: false,
								            	styles: {textAlignment:'far', numberFormat: '#0.0' }
								            },
								            {	name:'deductionSubTotal', 	
								            	fieldName:'deductionSubTotal',  	
								            	width:50,  
								            	header: {text:'<lgcom:message code="label.att.deductionSubTotal" />'}, 
								            	editable: false,
								            	styles: {textAlignment:'far', numberFormat: '#0.0' }
								            }
								         ]
							},
							{	name:'specialOT', 
								fieldName:'specialOT',
								width:40,
								header: {text:'<lgcom:message code="label.att.specialOT" />'}, 
								editable: false,
								styles: {textAlignment:'far', numberFormat: '#0.0'},
								editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'}
							},
							{	name:'baseAttFlag',
								fieldName:'baseAttFlag',
								width:40, 
								header: {text:'<lgcom:message code="label.att.baseAttFlag" />'}, 
								lookupDisplay: true,
								lookupSourceId: 'ynFlag',
								lookupKeyFields: ['baseAttFlag'],
								editable: false,
								styles: {textAlignment:'near' }
							}
						]
				);
				break;
		}
		return grid;
	}
}

LGVATT30060.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVATT30060();
		form.init();
		//form.loadCompleted();
	});
});

</script>
<style>
</style>
</head>

<body>
<div class="mdi-container">
	<section class="page-content">
		<div class="pageHeader">
		    <h2>Inquiry Monthly Attendance</h2>
		</div>
	
		<div class="searchBlock">
		    <form class="form search-wrap">
		    	<input type="hidden" name="orgId"/>
				<fieldset>
					<table class="table">
						<colgroup>
							<col width="90"/>
							<col width="220"/>
							<col width="90" />
							<col width="100"/>
							<col width="90" />
							<col width="200" />
							<col width="*"  />
						</colgroup>
						<tbody>
			                <tr>
			                	<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.att.date"/></label></th>
			                    <td>
			                        <div class="form-inline ">
		                                <input type="text" class="form-control input-sm input-require" name="fromDate" placeholder="dd/mm/yyyy" readonly>
		                                ~
		                                <input type="text" class="form-control input-sm input-require" name="toDate" placeholder="dd/mm/yyyy" readonly>
		                                <button type="button" id="setSingleDateSample" class="btn btn-ico" aria-label="calendar">
									        <span class="ico ico-calendar" aria-hidden="true"></span>
									    </button>
	                            	</div>
			                    </td>
								
								<th><label><lgcom:message code="label.att.shiftCode" /></label></th>
								<td><select class="form-control input-sm" name="shiftCode"></select></td>
								
								<th><label><lgcom:message code="label.att.baseAttend" /></label></th>
								<td><select class="form-control input-sm size_80" name="baseAttend"></select></td>
								
			                </tr>
			                <tr>
								<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.att.organization" /></label></th>
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
				</fieldset>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search" ><lgcom:message code="search" /></button>
		    </form>
		</div>
		
		<%-- 그리드 버튼 영역 --%>
		<div class="gridControls gridControls1 module-group text-right">
			<div class="btn-toolbar">	
				<div class="btn-group">
					<button class="btn btn-default btn-sm" type="button" data-action="excelDown"><span class="ico ico-excel-down"></span> <lgcom:message code="Download"/></button>
		 		</div>
	        </div>	
	    </div>
		
		<div class="content content1 grid-wrap" >
		    <div id="LGVATT30060_grid" class="grid"></div>
		</div>
	</section>
</div>
</body>
</html>
