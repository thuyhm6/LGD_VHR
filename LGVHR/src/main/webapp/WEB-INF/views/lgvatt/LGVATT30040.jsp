<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="devonframe.util.DateUtil" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%---------------------------------------------------------
    파일명 : LGVATT30040.jsp
    프로젝트명 : VHR LGD

    설 명 : Employee Monthly OT Level Report
    작성자 : HMT
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Employee Monthly OT Level Report</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<style type="text/css">
</style>
<script type="text/javascript">

var LGVATT30040 = function(){
    var grid;
    var _this = this;
    var myForm = this;
    var srchForm = '.searchBlock form';
    var formUtil = new FormUtil(myForm,'.searchBlock form');
    var validator = new Validator( myForm, srchForm );
    
    /* Layout Setting 하측 고정, 상측 Flexible*/
	myForm.setLayout( [ 
		{ name  : "searchBlock", left : 0, right : 0, top : 0 },		
		{ name  : "gridControls", left : 0, right : 0, top : "searchBlock"},
		{ name  : "content1", left : 0, right : 0, top : "gridControls", bottom : 0 }
	]);

  	//검색조건에 값을 입력하고 조회하면 방금 입력한 값을 저장하여 화면에 고정값으로 셋팅 
    myForm.searchConditionControl( true );
    transaction_sync( "lgvhr","lgvatt/LGVATT50030/retrieveAttendanceYyyymm", {}, function(data) {
    	if ( data.result ) {
    		yyyymmList = data.result.yyyymmList;
    		
    		formUtil.initCombo("attendanceYm", data.result.yyyymmList,   {selectAll:false});
    		formUtil.setValue({attendanceYm: data.result.currentYyyymmData.attendanceYyyymm});
    	}
    });
    
	// grid & serachBlock combo
	var code = new CommonCode('lgcom');
	code.add('shiftCode', {codeTypeCode:'LGVHR_SHIFT_TYPE_CODE'});
	code.add('gradeTitle', {codeTypeCode:'IF_VIETNAM_GRADE_TITLE'});
	code.add('categoryTitle', {codeTypeCode:'IF_EMP_CAT'});
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
	formUtil.initCombo('categoryTitle', code.get('categoryTitle'), { selectAll: true });
	
   	grid = buildGrid("LGVATT30040_grid");
	
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
				
				myForm.showProgress();
				grid.loadData('lgvhr','lgvatt/LGVATT30040/retrieveOtOverYearLimitList', param, function(data){
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
            
            // excel download monthly report HMT_20221108 Add Download Excel Function 
		    case "excelDown" :
		    	/* grid.getGridBase().exportGrid({
	    			target: "local",
	    			lookupDisplay: true,
		    		showProgress: true,
		    		done: function() {
		    			Message.alert("Excel exporting completed!!");
		    		}
		    	}); */
		    	
		    	if(validator.isValid()) {
					Message.confirm('<lgcom:message code="question.excelDownload"/>',function() {
						var param = formUtil.getValue();
						var downloader = new Downloader( myForm );
						downloader.excel( "lgvhr", "lgvatt/LGVATT30040/createExcelExportData", param );
					});
				}
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
	
	
	/*** 내부 함수  ***/
	
    /*** 그리드 초기 셋업  ***/
	function buildGrid(gridId) {
		var grid;
		switch(gridId){
			case 'LGVATT30040_grid':
				grid = new RealGrid(myForm, gridId, true);
				grid.setPagingMode(true, {rowSize:3000});
				var overColor = '#e9e9e9';
				
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
					    }
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
							{ fieldName:'attendanceYmEnd'     			, dataType:'text'  },
						 
							{ fieldName:'employee'     					, dataType:'text'  },
							{ fieldName:'employeeOrg'	        		, dataType:'text'  },
							{ fieldName:'employeeNo'	        		, dataType:'text'  },
							{ fieldName:'employeeName' 	        		, dataType:'text'  },
							{ fieldName:'employeeGrade' 	        	, dataType:'text'  },
							{ fieldName:'employeeCategory' 	        	, dataType:'text'  },
							{ fieldName:'dateHireSubsidiary'         	, dataType:'text'  },
							
							{ fieldName:'actualShiftCode'         		, dataType:'text'  },
							{ fieldName:'yearOt'	        			, dataType:'number'},
							{ fieldName:'monthTotalOt'	        		, dataType:'number'},
							
							{ fieldName:'weekdayDay' 	    			, dataType:'number'},
							{ fieldName:'holidayDay'					, dataType:'number'},
							{ fieldName:'publicHolidayDay'    			, dataType:'number'},
							
							{ fieldName:'weekdayNight'	       			, dataType:'number'},
							{ fieldName:'weekdayAfNight' 				, dataType:'number'},
							{ fieldName:'holidayNight'   				, dataType:'number'},
							{ fieldName:'publicHolidayNight'    		, dataType:'number'},
							
							{ fieldName:'weekdayDayOverM' 	    		, dataType:'number'},
							{ fieldName:'holidayDayOverM'				, dataType:'number'},
							{ fieldName:'publicHolidayDayOverM'    		, dataType:'number'},
							
							{ fieldName:'weekdayNightOverM'	       		, dataType:'number'},
							{ fieldName:'weekdayAfNightOverM' 			, dataType:'number'},
							{ fieldName:'holidayNightOverM'   			, dataType:'number'},
							{ fieldName:'publicHolidayNightOverM'    	, dataType:'number'},
							
							{ fieldName:'weekdayDayOverY' 	    		, dataType:'number'},
							{ fieldName:'holidayDayOverY'				, dataType:'number'},
							{ fieldName:'publicHolidayDayOverY'    		, dataType:'number'},
							
							{ fieldName:'weekdayNightOverY'	       		, dataType:'number'},
							{ fieldName:'weekdayAfNightOverY' 			, dataType:'number'},
							{ fieldName:'holidayNightOverY'   			, dataType:'number'},
							{ fieldName:'publicHolidayNightOverY'    	, dataType:'number'}
						]
				);

				grid.setLookupsMultiLvl({
					 			'employeeGrade': code.get("gradeTitle"),
					 			'employeeCategory': code.get("categoryTitle"),
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
								width:120,
								header:{
							         text:'<lgcom:message code="label.att.month" />',
							         fixedHeight: 20
							    },
								orientation:'horizontal',
								columns: [
											{	name:'attendanceYmEnd',
												fieldName:'attendanceYmEnd',
												width:60,
												header: {text:'<lgcom:message code="End"/>'},
												styles: {textAlignment:'near'},
												editable: false
											}
										]
							},
							{
								type:'group',
								name:'employee',
								fieldName:'employee',
								width:700,
								header:{
							         text:'<lgcom:message code="label.att.employee" />',
							         fixedHeight: 20
							    },
								orientation:'horizontal',
								columns: [
											{	name:'employeeOrg',
												fieldName:'employeeOrg',
												width:200,
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
								            	width:150, 
								            	header: {text:'<lgcom:message code="label.att.employeeName" />'},	 
								            	editable: false, 
								            	styles: {textAlignment:'near'}
								            },
								            {	name:'employeeGrade', 
								            	fieldName:'employeeGrade', 
								            	width:80,  
								            	lookupDisplay: true,
												lookupSourceId: 'employeeGrade',
												lookupKeyFields: ['employeeGrade'], 
												header: {text:'<lgcom:message code="label.att.jobTitle" />'},
												editable: false,
												styles: {textAlignment:'near'}
											},
											{	name:'employeeCategory', 
								            	fieldName:'employeeCategory', 
								            	width:100,  
								            	lookupDisplay: true,
												lookupSourceId: 'employeeCategory',
												lookupKeyFields: ['employeeCategory'], 
												header: {text:'<lgcom:message code="label.att.employmentCategory" />'},
												editable: false,
												styles: {textAlignment:'near'}
											},
											{
												name:'dateHireSubsidiary',
												fieldName:'dateHireSubsidiary',
												width:100,
												type: 'data',
												header: {text:'<lgcom:message code="label.pay.hireDate" />'},
												styles: {textAlignment:'center'},
												editable : false
											}
								         ]
							},
							{	name:'actualShiftCode',
								fieldName:'actualShiftCode',
								width:50,
								header: {text:'<lgcom:message code="label.att.actualShiftCode" />'},
								editable: false,
								styles: {textAlignment:'near' }
							},
							{	name:'yearOt', 
								fieldName:'yearOt', 
								width:60, 
								header: {text:'<lgcom:message code="label.att.yearTotalOT" />'},
								editable: false, 
								styles: {textAlignment:'center' }
							},
							{	name:'monthTotalOt', 
								fieldName:'monthTotalOt',
								width:50,
								header: {text:'<lgcom:message code="label.att.monthTotalOT" />'}, 
								editable: false,
								styles: {textAlignment:'far', numberFormat: '#0.0'},
								editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'}
							},
							{
								type:'group',
								name:'headerOT',
								fieldName:'headerOT',
								width:150,
								header:{
							         text:'<lgcom:message code="label.att.actualOT" />',
							         fixedHeight: 20
							    },
								orientation:'horizontal',
								columns: [
								            {	name:'weekdayDay',        
								            	fieldName:'weekdayDay',        
								            	width:50, header: {text:'<lgcom:message code="label.att.actualOTWeekDay2" />', showTooltip: true},
								            	editable: false,
								            	styles: {textAlignment:'far', numberFormat: '#0.0' }
								            },
								            {	name:'holidayDay', 
								            	fieldName:'holidayDay',  
								            	width:50, 
								            	header: {text:'<lgcom:message code="label.att.actualOTWeekDayHoliday2" />', showTooltip: true},
								            	editable: false, 
								            	styles: {textAlignment:'far', numberFormat: '#0.0' }
								            },
								            {	name:'publicHolidayDay',  
								            	fieldName:'publicHolidayDay', 
								            	width:50, 
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
								width:200,
								header:{
							         text:'<lgcom:message code="label.att.actualOTNight" />',
							         fixedHeight: 20
							    },
								orientation:'horizontal',
								columns: [
								            {	name:'weekdayNight',     
								            	fieldName:'weekdayNight',   
								            	width:50, 
								            	header: {text:'<lgcom:message code="label.att.actualOTNightWeekDay2" />', showTooltip: true},
								            	editable: false,
								            	styles: {textAlignment:'far', numberFormat: '#0.0' }
								            },
								            {	name:'weekdayAfNight', 
								            	fieldName:'weekdayAfNight',  
								            	width:50, 
								            	header: {text:'<lgcom:message code="label.att.actualOTNightWeekDayAfterOT2" />', showTooltip: true},
								            	editable: false, 
								            	styles: {textAlignment:'far', numberFormat: '#0.0' }
								            },
								            {	name:'holidayNight', 
								            	fieldName:'holidayNight', 
								            	width:50,  
								            	header: {text:'<lgcom:message code="label.att.actualOTNightWeekDayHoliday2" />', showTooltip: true}, 
								            	editable: false, 
								            	styles: {textAlignment:'far', numberFormat: '#0.0' }
								            },
								            {	name:'publicHolidayNight',  
								            	fieldName:'publicHolidayNight',  
								            	width:50, 
								            	header: {text:'<lgcom:message code="label.att.actualOTNightPublicHoliday2" />', showTooltip: true},
								            	editable: false, 
								            	styles: {textAlignment:'far', numberFormat: '#0.0' }
								            }
								         ]
							},
							{
								type:'group',
								name:'headerOT',
								fieldName:'headerOT',
								width:160,
								header:{
							         text:'<lgcom:message code="label.att.actualOTOverYearLimit" />',
							         fixedHeight: 20
							    },
								orientation:'horizontal',
								columns: [
								            {	name:'weekdayDayOverY',        
								            	fieldName:'weekdayDayOverY',        
								            	width:50, header: {text:'<lgcom:message code="label.att.actualOTWeekDay2" />', showTooltip: true},
								            	editable: false,
								            	styles: {textAlignment:'far', background: overColor, numberFormat: '#0.0' }
								            },
								            {	name:'holidayDayOverY', 
								            	fieldName:'holidayDayOverY',  
								            	width:50, 
								            	header: {text:'<lgcom:message code="label.att.actualOTWeekDayHoliday2" />', showTooltip: true},
								            	editable: false, 
								            	styles: {textAlignment:'far', background: overColor, numberFormat: '#0.0' }
								            },
								            {	name:'publicHolidayDayOverY',  
								            	fieldName:'publicHolidayDayOverY', 
								            	width:50, 
								            	header: {text:'<lgcom:message code="label.att.actualOTPublicHoliday2" />', showTooltip: true},
								            	editable: false, 
								            	styles: {textAlignment:'far', background: overColor, numberFormat: '#0.0' }
								            }
								         ]
							},
							{
								type:'group',
								name:'atNight',
								fieldName:'atNight',
								width:200,
								header:{
							         text:'<lgcom:message code="label.att.actualOTNightOverYearLimit" />',
							         fixedHeight: 20
							    },
								orientation:'horizontal',
								columns: [
								            {	name:'weekdayNightOverY',     
								            	fieldName:'weekdayNightOverY',   
								            	width:50, 
								            	header: {text:'<lgcom:message code="label.att.actualOTNightWeekDay2" />', showTooltip: true},
								            	editable: false,
								            	styles: {textAlignment:'far', background: overColor, numberFormat: '#0.0' }
								            },
								            {	name:'weekdayAfNightOverY', 
								            	fieldName:'weekdayAfNightOverY',  
								            	width:50, 
								            	header: {text:'<lgcom:message code="label.att.actualOTNightWeekDayAfterOT2" />', showTooltip: true},
								            	editable: false, 
								            	styles: {textAlignment:'far', background: overColor, numberFormat: '#0.0' }
								            },
								            {	name:'holidayNightOverY', 
								            	fieldName:'holidayNightOverY', 
								            	width:50,  
								            	header: {text:'<lgcom:message code="label.att.actualOTNightWeekDayHoliday2" />', showTooltip: true}, 
								            	editable: false, 
								            	styles: {textAlignment:'far', background: overColor, numberFormat: '#0.0' }
								            },
								            {	name:'publicHolidayNightOverY',  
								            	fieldName:'publicHolidayNightOverY',  
								            	width:50, 
								            	header: {text:'<lgcom:message code="label.att.actualOTNightPublicHoliday2" />', showTooltip: true},
								            	editable: false, 
								            	styles: {textAlignment:'far', background: overColor, numberFormat: '#0.0' }
								            }
								         ]
							},
							{
								type:'group',
								name:'headerOT',
								fieldName:'headerOT',
								width:160,
								header:{
							         text:'<lgcom:message code="label.att.actualOTOverMonthLimit" />',
							         fixedHeight: 20
							    },
								orientation:'horizontal',
								columns: [
								            {	name:'weekdayDayOverM',        
								            	fieldName:'weekdayDayOverM',        
								            	width:50, header: {text:'<lgcom:message code="label.att.actualOTWeekDay2" />', showTooltip: true},
								            	editable: false,
								            	styles: {textAlignment:'far', background: overColor, numberFormat: '#0.0' }
								            },
								            {	name:'holidayDayOverM', 
								            	fieldName:'holidayDayOverM',  
								            	width:50, 
								            	header: {text:'<lgcom:message code="label.att.actualOTWeekDayHoliday2" />', showTooltip: true},
								            	editable: false, 
								            	styles: {textAlignment:'far', background: overColor, numberFormat: '#0.0' }
								            },
								            {	name:'publicHolidayDayOverM',  
								            	fieldName:'publicHolidayDayOverM', 
								            	width:50, 
								            	header: {text:'<lgcom:message code="label.att.actualOTPublicHoliday2" />', showTooltip: true},
								            	editable: false, 
								            	styles: {textAlignment:'far', background: overColor, numberFormat: '#0.0' }
								            }
								         ]
							},
							{
								type:'group',
								name:'atNight',
								fieldName:'atNight',
								width:200,
								header:{
							         text:'<lgcom:message code="label.att.actualOTNightOverMonthLimit" />',
							         fixedHeight: 20
							    },
								orientation:'horizontal',
								columns: [
								            {	name:'weekdayNightOverM',     
								            	fieldName:'weekdayNightOverM',   
								            	width:50, 
								            	header: {text:'<lgcom:message code="label.att.actualOTNightWeekDay2" />', showTooltip: true},
								            	editable: false,
								            	styles: {textAlignment:'far', background: overColor, numberFormat: '#0.0' }
								            },
								            {	name:'weekdayAfNightOverM', 
								            	fieldName:'weekdayAfNightOverM',  
								            	width:50, 
								            	header: {text:'<lgcom:message code="label.att.actualOTNightWeekDayAfterOT2" />', showTooltip: true},
								            	editable: false, 
								            	styles: {textAlignment:'far', background: overColor, numberFormat: '#0.0' }
								            },
								            {	name:'holidayNightOverM', 
								            	fieldName:'holidayNightOverM', 
								            	width:50,  
								            	header: {text:'<lgcom:message code="label.att.actualOTNightWeekDayHoliday2" />', showTooltip: true}, 
								            	editable: false, 
								            	styles: {textAlignment:'far', background: overColor, numberFormat: '#0.0' }
								            },
								            {	name:'publicHolidayNightOverM',  
								            	fieldName:'publicHolidayNightOverM',  
								            	width:50, 
								            	header: {text:'<lgcom:message code="label.att.actualOTNightPublicHoliday2" />', showTooltip: true},
								            	editable: false, 
								            	styles: {textAlignment:'far', background: overColor, numberFormat: '#0.0' }
								            }
								         ]
							}
							
						]
				);
				break;
		}
		return grid;
	}
}

LGVATT30040.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVATT30040();
		form.init();
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
			                	<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.att.month"/></label></th>
			                    <td>
			                        <div class="form-inline ">
		                                <select class="form-control input-sm input-require" name="attendanceYm" id="attendanceYm"></select>
	                            	</div>
			                    </td>
								
								<th><label><lgcom:message code="label.att.shiftCode" /></label></th>
								<td><select class="form-control input-sm" name="shiftCode"></select></td>
								
								<th><label><lgcom:message code="label.att.employmentCategory" /></label></th>
								<td><select class="form-control input-sm size_150" name="categoryTitle"></select></td>
								
								<th><label><lgcom:message code="label.att.monthTotalOT" /></label></th>
								<td><input type="number" class="form-control input-sm" name="monthTotalOtFrom" size="10"></td>
								<th><label> ~ </label></th>
								<td><input type="number" class="form-control input-sm" name="monthTotalOtTo" size="10"></td>
								
								<th><label><lgcom:message code="label.att.yearTotalOT" /></label></th>
								<td><input type="number" class="form-control input-sm" name="yearTotalOtFrom" size="10"></td>
								<th><label> ~ </label></th>
								<td><input type="number" class="form-control input-sm" name="yearTotalOtTo" size="10"></td>
								
			                </tr>
			                <tr>
								<th><label class="required"><lgcom:message code="label.att.organization" /></label></th>
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
								<td><input type="text" class="form-control input-sm" name="empName" ></td>
								
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
		    <div id="LGVATT30040_grid" class="grid"></div>
		</div>
	</section>
</div>
</body>
</html>
