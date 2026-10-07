<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVATT40011.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2018 LG CNS,  All rights reserved.

    설 명 : 본 화면은 사무직 일근태 결재권자가 입력된 실적을 수정하는 팝업 화면입니다.
    작성자 : 이형준
    HMT_20210717     Swap weekly holiday (Add employeeNo)
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title><lgcom:message code="label.att.dailyRegistration"/></title>
<script src="/lgvhr/static/js/lgvatt.js"></script>
<style type="text/css">
._approvalPopupWindow ._commentWindowBack {
	background-color : black;
	opacity : 0.3;
	position : fixed;
	top:0px;
	bottom : 0px;
	rifht : 0px;
	left : 0px;
	z-index : 500;
	display :none;
}

._approvalPopupWindow  ._commentWindow  {
	width : 493px;
	height : 156px;
	position : fixed;
	top : 100px;
	left : calc( 50% - 246px);
	overflow : hidden;
	box-shadow: 2px 2px 4px rgba(0,0,0,.5);
	z-index : 510;
	border: 0px solid transparent;
	display:none;
}

._approvalPopupWindow  ._commentWindow .panel-heading {
	padding : 5px 10px;
	cursor : move;
	background-color : #474751;
	color : #FFFFFF;
}

._approvalPopupWindow  ._commentWindow .panel-footer {
	padding : 5px 10px;
	background-color : #FFFFFF;
}

._approvalPopupWindow  ._commentWindow .panel-footer .btn {
	width : 50px;
}

._approvalPopupWindow  ._commentWindow .panel-heading h3 {
	font-size : 12px;
	font-weight : bold;
}

._approvalPopupWindow  ._commentWindow .panel-body {
	padding : 5px 5px 1px 5px;
}

._approvalPopupWindow  ._commentWindow  ._comment {
	width : 480px;
	height : 84px;
	resize: none;
}
.table button.icon-plus {
    display : inline-block;
    height : 19px;
    width : 19px;
    margin-top: 3px;
    border : 0px;
    background :  url("/lgcom/static/img/realgrid/ico_plus_02.png");
}

.table button.icon-trash {
    display : inline-block;
    height : 19px;
    width : 19px;
    margin-top: 3px;
    border : 0px;
    background :  url("/lgcom/static/img/realgrid/icon_trash.png");
}
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVATT40011 = function() {
	var myForm = this;
	/* Form Util 선언 */ 
	var requestInfoFormUtil = new FormUtil( myForm, "form.requestInfo");//요청기본정보
	var editAttendancePopup = myForm.getParent().popupInfo.editAttendancePopup;
	var mode = editAttendancePopup.gridType;

	//요청폼 값 셋팅
	requestInfoFormUtil.setValue({
		employeeNo			: editAttendancePopup.employeeNo,
		employeeName		: editAttendancePopup.employeeName,
		attendanceYyyymmdd	: editAttendancePopup.attendanceDate
	});
	//화면 최초 레이아웃 설정
	fncInitLayout(mode);

    // 화면 레이아웃 정의
	myForm.setLayout([
		{ name : "buttonControls",           left : 0, right : 0, top : 0  },
		{ name : "resultBlock",        left : 0, right : 0, top : "buttonControls", height : 270 }
	]);
    
    // 코드 데이터 조회(그리드 콤보 셋팅하기 위해 사용함.)
	// combo 목록 조회
	var code = new CommonCode("lgcom");
	code.add( "LGVHR_DAY_NIGHT_FLAG", {codeTypeCode:'LGVHR_DAY_NIGHT_FLAG'} );
	code.add( "LGCOM_YN_FLAG",        {codeTypeCode:'LGCOM_YN_FLAG'} );
	code.execute();
	
	//근태유형, 근태코드, 근태 상세코드 조회
	var valueset = new ValueSet("lgcom");
	valueset.add("attendanceTypeList",       {valueSetId : "LGVATT_ATTEND_TYPE_UPDATE_ENABLE", subsidiaryCode :"${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}", languageCode:SESSION_USER.languageCode});
	valueset.add("attendanceCodeList",       {valueSetId : "LGVATT_ATTEND_DETAIL", attendTypeName :"", subsidiaryCode :"${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}", languageCode:SESSION_USER.languageCode} );
	valueset.add("attendanceDetailCodeList", {valueSetId : "LGVATT_ATTEND_DETAIL_CODE", subsidiaryCode :"${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}", languageCode:SESSION_USER.languageCode} );//근태코드에 따른 근태상세코드
	valueset.add("attDays", 				 {valueSetId : "LGVATT_ATT_DAYS", subsidiaryCode :"${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}"} );
	valueset.execute();

	//계획근태유형 선택 가능한지 여부 조회하기 위한 근태코드 목록 조회
	var attendCodeAllList = {};
	myForm.transaction("lgvhr", "lgvatt/LGVATTCOMM/retrieveAttendanceCodeList", {}, function(data) { 
		if ( data.result ) {
			attendCodeAllList = data.result;
		}
	});
	
	//출근시간리스트 조회(평일인 경우 8시, 20시만 선택가능하고, 휴일인 경우 모든시간 선택가능하도록 하기 위해 휴일여부Y,N인 출근시간을 모두 조회한다.)
	var workStartTimeList = {};
	myForm.transaction_sync("lgvhr", "lgvatt/LGVATTCOMM/retrieveWorkStartTimeList", {}, function(data) { 
		if ( data.result ) {
			workStartTimeList = data.result;
		}
	});
	
    // 그리드 초기화
    var resultGrid = buildGrid(".resultGrid");
    
    var controlColumns = {         
    	deductionColumn : [ "tardyHours", "earlyLeaveHours", "goingOutHours" ]
    };
    
    resultGrid.getGridBase().addCellStyles([
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
    
	//기본정보 조회
	fncRetrieveInitData(mode);

    // 그리드형 테이블 TR

    // 날짜 팝업창
    
    // 필수항목 체크

    // 일반함수	

    // Event 처리
	/*** 이벤트 핸들러  ***/
	/* 버튼 제어 */
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch(action) {
			case "ok":
				//이 버튼 자체를 Disable 처리 한다.
				$(item).prop("disabled", true);

				//승인 버튼 구역의 모든 버튼을 잠금 처리한다.
				myForm.select(".buttonControls button" ).prop("disabled", true);

				var action = myForm.select("._commentWindow").data("action");
				var type = myForm.select("._commentWindow").data("type");
				var comment = myForm.select("._commentWindow ._comment").val();

				//comment 에 입력한 내용이 없을 때에는 자동으로 지정된 메세지를 추가한다.
				if( comment == "" ) {
					if( type == 'APPROVAL') {
						comment = "OK";
					} else if( type == 'REJECT') {
						comment = "Rejected";
					}
					myForm.select("._commentWindow ._comment").val( comment );
				}

				if( type == 'APPROVAL') {
					myForm.showProgress();
					fncSaveApproval(mode);
				} 
				
				$(item).removeAttr("disabled");

				hideCommentWindow();
				$(".buttonControls button" ).removeAttr("disabled");
				break;
				
			case "cancel":
				hideCommentWindow();
				break;
			
			case "approval" :
				resultGrid.getGridBase().commit();
				var action = $(event.target).data("action");
				myForm.select("._commentWindow").data("action", action);
				myForm.select("._commentWindow").data("type", action.toUpperCase());
				myForm.select("._commentWindow .actionName").text("Approval");
				myForm.select("._commentWindow ._comment").val("");
				
				showCommentWindow();
				break;
			
			case "save" :
				resultGrid.getGridBase().commit();
				fncSaveApproval(mode);
				break;
		}
	});

	/*** 내부 함수 ***/
    //그리드 초기화 
	function buildGrid(gridId) {
		var grid;
		var readOnyBgColor = "#e9e9e9";
		switch ( gridId ) {
			case ".resultGrid":
				grid = new RealGrid(myForm, gridId);
				grid.setPagingMode(true);
				//옵션 설정 
				grid.setOptions({
					grid: {
						softDeleting: true,
						deleteCreated: true,
						hideDeletedRows:true,
						indicator: {visible:false},
						panel: {visible:false},
						checkBar: {visible:false},
						stateBar: {visible:false},
						footer: {visible:false},
						select: 'block',
						paste    : { enabled: false }, /*paste 기능막기 */
						sorting  : { enabled: false }, /*Sorting 기능을 막는다.*/
		                sortMode : "explicit",
						edit: {
							insertable: false, /* INSERT 키 또는 방향키로 행삽입 불가능 */
							appendable: false, /* INSERT 키 또는 방향키로 행추가 불가능 */
							updatable: true,
							deletable: true
						},
						header: {height: 70, heightFill: 'fixed', showTooltip: true},
						fixed: { colCount: 11, resizable:true }
					},
					display: { fitStyle: 'none' }
				});		
				
				//마우스 오른쪽 클릭시 메뉴
				grid.setContextMenu();
				
				//필드 설정
				grid.setFields(
						[
							{ fieldName:'attendanceYmd'             , dataType:'text'  },
							{ fieldName:'attendanceYyyymmddResult'  , dataType:'text'  },
							{ fieldName:'screenWeekName'     	    , dataType:'text'  },
							{ fieldName:'inTime'                    , dataType:'text'  },
							{ fieldName:'outTime'                   , dataType:'text'  },
							{ fieldName:'shiftTypeName'             , dataType:'text'  },
							{ fieldName:'nightShiftFlag'            , dataType:'text'  },
							{ fieldName:'attendanceType'            , dataType:'text'  },
							{ fieldName:'attendanceCode'            , dataType:'text'  },
							{ fieldName:'originAttendanceCode'      , dataType:'text'  },
				            { fieldName:'timeAttendDetailCode'      , dataType:'text'  },
							{ fieldName:'workStartTime'             , dataType:'text'  },
							{ fieldName:'workStartTimeOri'          , dataType:'text'  },
							{ fieldName:'tardyHours'                , dataType:'number'},
							{ fieldName:'earlyLeaveHours'           , dataType:'number'},
							{ fieldName:'goingOutHours'             , dataType:'number'},
							{ fieldName:'overtimeSumHours'          , dataType:'number'},
				            { fieldName:'timeAttendInputReasonDesc' , dataType:'text'  },
							{ fieldName:'eveningMealFlag'           , dataType:'text'  },
							{ fieldName:'normalNightOvertimeHours'  , dataType:'number'},
							{ fieldName:'weekdayOvertimeHours'      , dataType:'number'},
							{ fieldName:'holidayOvertimeHours'      , dataType:'number'},
							{ fieldName:'publicHolidayOvertimeHours', dataType:'number'},
							{ fieldName:'weekdayNightOvertimeHours' , dataType:'number'},
							{ fieldName:'weekdayOtAfNightWorkHours' , dataType:'number'},
							{ fieldName:'holidayNightOvertimeHours' , dataType:'number'},
							{ fieldName:'publicHolidayNightOtHours' , dataType:'number'},
							{ fieldName:'specialBonusHours'         , dataType:'number'},
							{ fieldName:'helpcallSupportHours'      , dataType:'number'},
				            { fieldName:'updateEnableFlag'          , dataType:'text'  },
				            { fieldName:'holidayFlag'          		, dataType:'text'  },
				            { fieldName:'inOutTimeRedFlag'          , dataType:'text'  },
				            { fieldName:'requestMasterIdResult'     , dataType:'text'  },
							{ fieldName:'requestCodeResult'         , dataType:'text'  },
							{ fieldName:'waitFlagResult'            , dataType:'text'  }
						]
				);
				//컬럼 콤보 셋팅
				grid.setLookupsMultiLvl({"attendanceType":{data:valueset.get("attendanceTypeList"), keyField:['updateEnable', 'code']},
			                             "attendanceCode":{data:valueset.get("attendanceCodeList"), keyField:['updateEnable', 'attendTypeName', 'code']},
			                             "nightShiftFlag":code.get("LGVHR_DAY_NIGHT_FLAG"),
			                             "eveningMealFlag":code.get("LGCOM_YN_FLAG"),
			                             "workStartTime":{data:workStartTimeList, keyField:["holidayFlag", "code"]},
			                             "timeAttendDetailCode":{data:valueset.get("attendanceDetailCodeList"), keyField:["attendanceCode", "code"]}
					                   });
				//컬럼 설정 
				grid.setColumns(
						[
							{	type:'group',
								name:'date',
								fieldName:'date',
								width:140,
								header:{
							         text:'<lgcom:message code="label.att.date" />'
							    },
								orientation:'horizontal',
								hideChildHeaders: true,
								columns: [
											{	name:'attendanceYmd',
												fieldName:'attendanceYmd',
												width:70,
												header: {text:'<lgcom:message code="label.att.date"/>', visible:false},
												styles: {textAlignment:'center', background:readOnyBgColor},
												editable: false
											},
											{	name:'screenWeekName',
												fieldName:'screenWeekName',
												width:70,
												header: {text:'<lgcom:message code="label.att.dayOfWeek"/>', visible:false},
												styles: {textAlignment:'near', background:readOnyBgColor},
												editable: false
											}
										]
							},
							{	name:'inTime',
								fieldName:'inTime',
								width:40,
								header: {text:'<lgcom:message code="label.att.inTime"/>'},
								styles: {textAlignment:'center', background:readOnyBgColor},
								editable:false,
								visible:true,
								dynamicStyles:[{criteria:"values['inOutTimeRedFlag']='Y'", styles:{foreground:"#f34d78"}}]
							},
							{	name:'outTime',
								fieldName:'outTime',
								width:40,
								header: {text:'<lgcom:message code="label.att.outTime"/>'},
								styles: {textAlignment:'center', background:readOnyBgColor},
								editable:false,
								visible:true,
								dynamicStyles:[{criteria:"values['inOutTimeRedFlag']='Y'", styles:{foreground:"#f34d78"}}]
							},
							{	name:'shiftTypeName',
								fieldName:'shiftTypeName',
								width:40,
								header: {text:'<lgcom:message code="label.att.shiftType"/>'},
								styles: {textAlignment:'center', background:readOnyBgColor},
								editable: false
							},
							{	name:'nightShiftFlag',
								fieldName:'nightShiftFlag',
								width:40,
								header: {text:'<lgcom:message code="label.att.actualDayNight"/>'},
								styles: {textAlignment:'center', background:readOnyBgColor},
								lookupDisplay: true,
								lookupSourceId: 'nightShiftFlag',
								lookupKeyFields: ['nightShiftFlag'],
								editor: {type:'dropDown',textReadOnly:true},
								editable : false
							},
							{	type:'group',
								name:'actualAttendance',
								fieldName:'actualAttendance',
								width:320,
								header:{
							         text:'<lgcom:message code="label.att.actualAttendance" />', fixedHeight:30
							    },
								orientation:'horizontal',
								columns: [
											{	name:'attendanceType',
												fieldName:'attendanceType',
												width:90,
												header: {text:'<lgcom:message code="label.att.actualAttendanceType"/>'},
												styles: {textAlignment:'near'},
											    renderer: {showTooltip: true},
												lookupDisplay: true,
												lookupSourceId: 'attendanceType',
												lookupKeyFields: ['updateEnableFlag','attendanceType'],
												editor: {type:'dropDown',textReadOnly:true},
												editable : true
											},
											{	name:'attendanceCode',
												fieldName:'attendanceCode',
												width:110,
												header: {text:'<lgcom:message code="label.att.actualAttendanceDetail"/>'},
												styles: {textAlignment:'near'},
											    renderer: {showTooltip: true},
												lookupDisplay: true,
												lookupSourceId: 'attendanceCode',
												lookupKeyFields: ['updateEnableFlag','attendanceType','attendanceCode'],
												editor: {type:'dropDown',textReadOnly:true},
												editable : true
											},
											{	name:'timeAttendDetailCode',
												fieldName:'timeAttendDetailCode',
												width:120,
											    renderer: {showTooltip: true},
												header: {text:'<lgcom:message code="label.att.timeAttendDetailCode"/>'},
												styles: {textAlignment:'near'},
												renderer: {showTooltip:true},
												lookupDisplay: true,
												lookupSourceId: 'timeAttendDetailCode',
												lookupKeyFields: ['attendanceCode', 'timeAttendDetailCode'],
												editor: {type:'dropDown',textReadOnly:true},
												editable : true
											}
										]
							},
							{	name:'workStartTime',
								fieldName:'workStartTime',
								width:60,
								header: {text:'<lgcom:message code="label.att.actualStartTm"/>'},
								styles: {textAlignment:'center'},
								lookupDisplay: true,
								lookupSourceId: 'workStartTime',
								lookupKeyFields: ['holidayFlag', 'workStartTime'],
								editor: {type:'dropDown',textReadOnly:true},
								editable: true
							},
							{	type:'group',
								name:'deduction',
								fieldName:'deduction',
								width:175,
								header:{
							         text:'<lgcom:message code="label.att.deduction" />', fixedHeight:30
							    },
								orientation:'horizontal',
								columns: [
											{	name:'tardyHours',
												fieldName:'tardyHours',
												width:55,
												header: {text:'<lgcom:message code="label.att.deductionLateness"/>'},
												styles: {textAlignment:'far', numberFormat: '#0.0'},
												editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
												editable: true
											},
											{	name:'earlyLeaveHours',
												fieldName:'earlyLeaveHours',
												width:55,
												header: {text:'<lgcom:message code="label.att.deductionLeavingEarly"/>'},
												styles: {textAlignment:'far', numberFormat: '#0.0'},
												editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
												editable: true
											},
											{	name:'goingOutHours',
												fieldName:'goingOutHours',
												width:55,
												header: {text:'<lgcom:message code="label.att.deductionGoingOut"/>'},
												styles: {textAlignment:'far', numberFormat: '#0.0'},
												editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
												editable: true
											}
										]
							},
							{	name:'overtimeSumHours',
								fieldName:'overtimeSumHours',
								width:40,
								header: {text:'<lgcom:message code="label.att.totalOT"/>'},
								styles: {textAlignment:'far', numberFormat: '#0.0'},
								editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
								editable: true
							},
							{	name:'timeAttendInputReasonDesc',
								fieldName:'timeAttendInputReasonDesc',
								width:160,
								header: {text:'<lgcom:message code="label.att.timeAttendInputReasonDesc"/>'},
								styles: {textAlignment:'near'},
							    renderer: {showTooltip: true},
							    editor: {maxLength: 1000},
								editable: true
							},
							{	name:'eveningMealFlag',
								fieldName:'eveningMealFlag',
								width:50,
								header: {text:'<lgcom:message code="label.att.actualDinnerChk"/>'},
								styles: {textAlignment:'center'},
								lookupDisplay: true,
								lookupSourceId: 'eveningMealFlag',
								lookupKeyFields: ['eveningMealFlag'],
								editor: {type:'dropDown',textReadOnly:true},
								editable: true
							},
							{	type:'group',
								name:'night',
								fieldName:'night',
								width:45,
								header:{
							         text:'<lgcom:message code="label.att.night" />', fixedHeight:30
							    },
								orientation:'horizontal',
								columns: [
											{	name:'normalNightOvertimeHours',
												fieldName:'normalNightOvertimeHours',
												width:45,
												header: {text:'<lgcom:message code="label.att.nightNormal2"/>', tooltip:'<lgcom:message code="label.att.nightNormal"/>'},
												styles: {textAlignment:'far', numberFormat: '#0.0', background:readOnyBgColor},
												editable:false
											}
										]
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
												styles: {textAlignment:'far', numberFormat: '#0.0', background:readOnyBgColor},
												editable:false
											},
											{	name:'holidayOvertimeHours',
												fieldName:'holidayOvertimeHours',
												width:50,
												header: {text:'<lgcom:message code="label.att.actualOTWeekDayHoliday2" />', tooltip:'<lgcom:message code="label.att.actualOTWeekDayHoliday"/>'},
												styles: {textAlignment:'far', numberFormat: '#0.0', background:readOnyBgColor},
												editable:false
											},
											{	name:'publicHolidayOvertimeHours',
												fieldName:'publicHolidayOvertimeHours',
												width:50,
												header: {text:'<lgcom:message code="label.att.actualOTPublicHoliday2" />', tooltip:'<lgcom:message code="label.att.actualOTPublicHoliday"/>'},
												styles: {textAlignment:'far', numberFormat: '#0.0', background:readOnyBgColor},	
												editable:false
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
												styles: {textAlignment:'far', numberFormat: '#0.0', background:readOnyBgColor},	
												editable:false
											},
											{	name:'weekdayOtAfNightWorkHours',
												fieldName:'weekdayOtAfNightWorkHours',
												width:50,
												header: {text:'<lgcom:message code="label.att.actualOTNightWeekDayAfterOT2" />', tooltip:'<lgcom:message code="label.att.actualOTNightWeekDayAfterOT"/>'},
												styles: {textAlignment:'far', numberFormat: '#0.0', background:readOnyBgColor},
												editable:false
											},
											{	name:'holidayNightOvertimeHours',
												fieldName:'holidayNightOvertimeHours',
												width:50,
												header: {text:'<lgcom:message code="label.att.actualOTNightWeekDayHoliday2" />', tooltip:'<lgcom:message code="label.att.actualOTNightWeekDayHoliday"/>'},
												styles: {textAlignment:'far', numberFormat: '#0.0', background:readOnyBgColor},	
												editable:false
											},
											{	name:'publicHolidayNightOtHours',
												fieldName:'publicHolidayNightOtHours',
												width:50,
												header: {text:'<lgcom:message code="label.att.actualOTNightPublicHoliday2" />', tooltip:'<lgcom:message code="label.att.actualOTNightPublicHoliday"/>'},
												styles: {textAlignment:'far', numberFormat: '#0.0', background:readOnyBgColor},
												editable:false
											}
										]
							},
							{	name:'specialBonusHours',
								fieldName:'specialBonusHours',
								width:60,
								header: {text:'<lgcom:message code="label.att.specialBonus"/>'},
								styles: {textAlignment:'far', numberFormat: '#0.0'},
								editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
								editable: true,
								visible: false
							},
							{	name:'helpcallSupportHours',
								fieldName:'helpcallSupportHours',
								width:60,
								header: {text:'<lgcom:message code="label.att.helpCall"/>'},
								styles: {textAlignment:'far', numberFormat: '#0.0'},
								editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
								editable: true,
								visible: false
							}
						]
				);
				//그리드 필수값 체크
				grid.setValidations([
					{criteria: "value['attendanceCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.actualAttendanceDetail'/>"/>',mode:'always',level:'error'},
					{criteria: "value['eveningMealFlag'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.actualDinnerChk'/>"/>',mode:'always',level:'error'}
				]);
				break;
		}
		return grid;
	}
    //실적 근태유형에 따른 근태코드 셋팅
	resultGrid.getGridBase().onEditCommit = function(cgrid, index, oldValue, newValue) {
		<%--[PARAMETER]
	    	- cgrid : grid.getGridBase()
	    	- index : 클릭된 데이터 셀의 인덱스.
	                  - index.itemIndex : 그리드의 row index
	                  - index.dataRow : 조회한 데이터셋의 row index
	        - oldValue : 편집 전 셀의 데이터 값
	        - newValue : 편집 후 셀의 데이터 값
		--%>
		//근태유형선택 시 근태코드 자동 변경 처리
		if(index.column == 'attendanceType') {
			var exists = cgrid.existsLookupData('attendanceCode',[newValue,cgrid.getValue(index.itemIndex,'attendanceCode')]);
			if(!exists) {
				var attendCodeLookup = valueset.get('attendanceCodeList');
				var attDaysLookup = valueset.get('attDays');
				var attendCode = '';
				for(var i=0; i < attendCodeLookup.length; i++) {
					if($.trim(attendCodeLookup[i]['attendTypeName']) == newValue) {
						attendCode = $.trim(attendCodeLookup[i]['code']);
						break;
					}
				}<%-- //for(var i=0; i < attendCodeLookup.length; i++) { --%>
				for(var i=0; i < attDaysLookup.length; i++) {
					if($.trim(attDaysLookup[i]['timeAndAttendanceCode']) == attendCode) {
						if($.trim(attDaysLookup[i]['code']) == 0) {
							cgrid.setCellStyles(index.dataRow, controlColumns.deductionColumn, "unableEdit");
						} else {
							cgrid.setCellStyles(index.dataRow, controlColumns.deductionColumn, "enableEdit");
						}
						break;
					}
				}<%-- //for(var i=0; i < attDaysLookup.length; i++) { --%>
				
				cgrid.setValue(index.itemIndex, 'attendanceCode', attendCode);
				
				exists = cgrid.existsLookupData('timeAttendDetailCode',[cgrid.getValue(index.itemIndex,'attendanceCode'), cgrid.getValue(index.itemIndex,'timeAttendDetailCode')]);
				if(!exists) {
					var detailReasonLookup = valueset.get('attendanceDetailCodeList');
					var detailReasonCode = '';
					for(var i=0; i < detailReasonLookup.length; i++) {
						if($.trim(detailReasonLookup[i]['attendanceCode']) == cgrid.getValue(index.itemIndex,'attendanceCode')) {
							detailReasonCode = $.trim(detailReasonLookup[i]['code']);
							break;
						}
					}
					
					if( cgrid.getValue(index.itemIndex,'attendanceCode') == 'NW') {
						cgrid.setValue(index.itemIndex,'timeAttendDetailCode', 'NW_NRM');
					} else {
						cgrid.setValue(index.itemIndex,'timeAttendDetailCode',detailReasonCode);
					}
				}
				//근태유형에 따른 근태코드 변경되므로, 값 초기화
		    	fncResetRowData(cgrid, index.itemIndex, "RESULT");
				
				//OT계산
				fncCalculateOT(cgrid, index.itemIndex);
			}
		} else if(index.column == 'attendanceCode') {
			var attDaysLookup = valueset.get('attDays');
			for(var i=0; i < attDaysLookup.length; i++) {
				if($.trim(attDaysLookup[i]['timeAndAttendanceCode']) == newValue) {
					if($.trim(attDaysLookup[i]['code']) == 0) {
						cgrid.setCellStyles(index.dataRow, controlColumns.deductionColumn, "unableEdit");
					} else {
						cgrid.setCellStyles(index.dataRow, controlColumns.deductionColumn, "enableEdit");
					}
					break;
				}
			}<%-- //for(var i=0; i < attDaysLookup.length; i++) { --%>
			var exists = cgrid.existsLookupData('timeAttendDetailCode',[newValue,cgrid.getValue(index.itemIndex,'timeAttendDetailCode')]);
			if(!exists) {
				var attendCodeLookup = valueset.get('attendanceDetailCodeList');
				var attendCode = '';
				for(var i=0; i < attendCodeLookup.length; i++) {
					if($.trim(attendCodeLookup[i]['attendanceCode']) == newValue) {
						attendCode = $.trim(attendCodeLookup[i]['code']);
						break;
					}
				}

				if( newValue == 'NW') {
					cgrid.setValue(index.itemIndex,'timeAttendDetailCode', 'NW_NRM');
				} else {
					cgrid.setValue(index.itemIndex,'timeAttendDetailCode',attendCode);
				}
			}
			//근태유형에 따른 근태코드 변경되므로, 값 초기화
	    	fncResetRowData(cgrid, index.itemIndex, "RESULT");
			
			//OT계산
			fncCalculateOT(cgrid, index.itemIndex);
		}
	}
	//석식여부, OT시간 셀 수정시 이벤트
	resultGrid.getGridBase().onCellEdited = function (cgrid, itemIndex, dataRow, field) {
		cgrid.commit();
		var provider = cgrid.getDataProvider();
	    var fieldName = provider.getOrgFieldName(field);

		//근태코드 변경 시 석식여부, OT 초기화
	    if ( fieldName == "attendanceCode" ) {
			//OT계산
			fncCalculateOT(cgrid, itemIndex);
			
		//석식여부 변경시 OT시간이 있으면 재계산
	    } else if ( fieldName == "eveningMealFlag" ) {
			//OT계산
			fncCalculateOT(cgrid, itemIndex);
			
		//출근시간 변경 시 OT 재계산
		} else if ( fieldName == "workStartTime" ) {
			//OT계산
			fncCalculateOT(cgrid, itemIndex);
			
		// OT시간이 변경되면 재계산
	    } else if ( fieldName == "overtimeSumHours" ) {
	    	//ot가 0.5 단위로 입력되었는지 체크
	    	if ( $.isNumeric(cgrid.getValue(itemIndex, fieldName)) && (Number(cgrid.getValue(itemIndex, fieldName)) % 0.5) > 0 ) {
	    		Message.alert("<lgcom:message code="note.att.otInputFault"/>");
	    		cgrid.setValue(itemIndex, fieldName, 0);
	    		
		    //휴일, 평일별 OT 시간 제약
	    	} else if ( $.isNumeric(cgrid.getValue(itemIndex, fieldName)) && nvl(cgrid.getValue(itemIndex, fieldName).toString()) != "" ) {
	    		if ( cgrid.getValue(itemIndex, "holidayFlag") == "Y" ) {
	    			cgrid.setValue(itemIndex, fieldName, Math.min(cgrid.getValue(itemIndex, fieldName), 24));//휴일 최대 24시간
	    		} else {
	    			cgrid.setValue(itemIndex, fieldName, Math.min(cgrid.getValue(itemIndex, fieldName), 16));//평일 최대 16시간
	    		}
	    		
	    	} else if ( isNull(cgrid.getValue(itemIndex, fieldName)) ) {//공백인 경우 0으로 기본 셋팅
	    		cgrid.setValue(itemIndex, fieldName, 0);
	    	
	    	}
			//OT계산
			fncCalculateOT(cgrid, itemIndex);
		
		//지각 입력 시 입력값 체크 및 야간근무이면 night 30%차감 로직 추가
	    } else if ( fieldName == "tardyHours" ) {
	    	//지각이 0.5 단위로 입력되었는지 체크
	    	if ( $.isNumeric(cgrid.getValue(itemIndex, fieldName)) && (Number(cgrid.getValue(itemIndex, fieldName)) % 0.5) > 0 ) {
	    		Message.alert("<lgcom:message code="note.att.latenessInputFault"/>");
	    		cgrid.setValue(itemIndex, fieldName, 0);
	    		
	    	} else if ( isNull(cgrid.getValue(itemIndex, fieldName)) ) {//공백인 경우 0으로 기본 셋팅
	    		cgrid.setValue(itemIndex, fieldName, 0);
	    	
	    	}
			//OT재계산
			fncCalculateOT(cgrid, itemIndex);
	    } else if ( fieldName == "earlyLeaveHours" ) {
	    	//조퇴가 0.5 단위로 입력되었는지 체크
	    	if ( $.isNumeric(cgrid.getValue(itemIndex, fieldName)) && (Number(cgrid.getValue(itemIndex, fieldName)) % 0.5) > 0 ) {
	    		Message.alert("<lgcom:message code="note.att.leavingEarlyInputFault"/>");
	    		cgrid.setValue(itemIndex, fieldName, 0);
	    		
	    	} else if ( isNull(cgrid.getValue(itemIndex, fieldName)) ) {//공백인 경우 0으로 기본 셋팅
	    		cgrid.setValue(itemIndex, fieldName, 0);
	    	}
			//OT재계산
			fncCalculateOT(cgrid, itemIndex);
	    } else if ( fieldName == "goingOutHours" ) {
	    	//외출가 0.5 단위로 입력되었는지 체크
	    	if ( $.isNumeric(cgrid.getValue(itemIndex, fieldName)) && (Number(cgrid.getValue(itemIndex, fieldName)) % 0.5) > 0 ) {
	    		Message.alert("<lgcom:message code="note.att.goingOutInputFault"/>");
	    		cgrid.setValue(itemIndex, fieldName, 0);
	    		
	    	} else if ( isNull(cgrid.getValue(itemIndex, fieldName)) ) {//공백인 경우 0으로 기본 셋팅
	    		cgrid.setValue(itemIndex, fieldName, 0);
	    	}
			//OT재계산
			fncCalculateOT(cgrid, itemIndex);
	    }
	}
	//입력값 validation
    resultGrid.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	}
	//값 초기화
	function fncResetRowData(cgrid, itemIndex) {
    	cgrid.setValue(itemIndex, "eveningMealFlag", "N");//석식여부는 기본값을 N으로 한다.
    	cgrid.setValue(itemIndex, "workStartTime", cgrid.getValue(itemIndex, "workStartTimeOri"));
    	cgrid.setValue(itemIndex, "overtimeSumHours", 0);

		cgrid.setValue(itemIndex, "weekdayOvertimeHours", 0);
		cgrid.setValue(itemIndex, "holidayOvertimeHours", 0);
		cgrid.setValue(itemIndex, "publicHolidayOvertimeHours", 0);
		cgrid.setValue(itemIndex, "weekdayNightOvertimeHours", 0);
		cgrid.setValue(itemIndex, "weekdayOtAfNightWorkHours", 0);
		cgrid.setValue(itemIndex, "holidayNightOvertimeHours", 0);
		cgrid.setValue(itemIndex, "publicHolidayNightOtHours", 0);
		cgrid.setValue(itemIndex, "normalNightOvertimeHours", 0);

		cgrid.setValue(itemIndex, "tardyHours", 0);
		cgrid.setValue(itemIndex, "earlyLeaveHours", 0);
		cgrid.setValue(itemIndex, "goingOutHours", 0);
		cgrid.setValue(itemIndex, "specialBonusHours", 0);
		cgrid.setValue(itemIndex, "helpcallSupportHours", 0);
		cgrid.setValue(itemIndex, "timeAttendDetailCode", null);
		cgrid.setValue(itemIndex, "timeAttendInputReasonDesc", null);
	}
	//OT재계산
	function fncCalculateOT(cgrid, rowIndex) {
		
		var param = {subsidiaryCode    :"${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}",
			         employeeNo        :requestInfoFormUtil.getValue("employeeNo"), //HMT_20210717
			         attendanceYyyymmdd:$.trim(cgrid.getValue(rowIndex, "attendanceYyyymmddResult")),
			         attendanceCode    :$.trim(cgrid.getValue(rowIndex, "attendanceCode")),
			         shiftTypeCode     :$.trim(cgrid.getValue(rowIndex, "shiftTypeName")),
			         dayNightFlag      :$.trim(cgrid.getValue(rowIndex, "nightShiftFlag")),
			         dinnerFlag        :$.trim(cgrid.getValue(rowIndex, "eveningMealFlag")),
			         workingStartTime  :$.trim(cgrid.getValue(rowIndex, "workStartTime")),
			         lateness          :Number($.trim(cgrid.getValue(rowIndex, "tardyHours"))).toString(),
			         leavingEarly      :Number($.trim(cgrid.getValue(rowIndex, "earlyLeaveHours"))).toString(),
			         goingOut          :Number($.trim(cgrid.getValue(rowIndex, "goingOutHours"))).toString(),
			         overtimeSumHours  :Number($.trim(cgrid.getValue(rowIndex, "overtimeSumHours"))).toString(),
			        };

		//OT계산 전 초기화
		cgrid.setValue(rowIndex, "weekdayOvertimeHours", 0);
		cgrid.setValue(rowIndex, "holidayOvertimeHours", 0);
		cgrid.setValue(rowIndex, "publicHolidayOvertimeHours", 0);
		cgrid.setValue(rowIndex, "weekdayNightOvertimeHours", 0);
		cgrid.setValue(rowIndex, "weekdayOtAfNightWorkHours", 0);
		cgrid.setValue(rowIndex, "holidayNightOvertimeHours", 0);
		cgrid.setValue(rowIndex, "publicHolidayNightOtHours", 0);
		cgrid.setValue(rowIndex, "normalNightOvertimeHours", 0);
		
		//OT자동 계산
		myForm.transaction_sync("lgvhr", "lgvatt/LGVATTCOMM/processCalculateOT", param, function(data) {
			if ( data.result ) {
				//OT자동 계산값 셋팅
				cgrid.setValue(rowIndex, "weekdayOvertimeHours", data.result.ot150);
				cgrid.setValue(rowIndex, "holidayOvertimeHours", data.result.ot200);
				cgrid.setValue(rowIndex, "publicHolidayOvertimeHours", data.result.ot300);
				cgrid.setValue(rowIndex, "weekdayNightOvertimeHours", data.result.nt200);
				cgrid.setValue(rowIndex, "weekdayOtAfNightWorkHours", data.result.nt210);
				cgrid.setValue(rowIndex, "holidayNightOvertimeHours", data.result.nt270);
				cgrid.setValue(rowIndex, "publicHolidayNightOtHours", data.result.nt390);
				cgrid.setValue(rowIndex, "normalNightOvertimeHours", data.result.nt30);
			}
		});
	}
	
	//승인
    function fncSaveApproval(mode) {
		var approvalList = [];
		var dataProvider = resultGrid.getDataProvider();
		try{
			var gridData = dataProvider.getJsonRow(0);
			gridData = $.extend(gridData, { employeeNo : requestInfoFormUtil.getValue("employeeNo") });
			gridData = $.extend(gridData, { applicationUserId : '${sessionScope.USER_SESSION.applicationUserId}' });
			gridData = $.extend(gridData, { subsidiaryCode : '${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}' });
			approvalList.push(gridData);
		} catch( e ) {
			trace( e );
		}
		
		//최종 저장소에 데이터 보내기
		var param = {};
		var infoData = {};
		infoData = $.extend(infoData, { planYyyymmdd : requestInfoFormUtil.getValue("attendanceYyyymmdd") });
		infoData = $.extend(infoData, { comment : myForm.select("._commentWindow ._comment").val() });

		param["infoData"] = infoData;
		param["approvalList"] = approvalList;
		
		if(mode == "requested") {
			myForm.showProgress();
			myForm.transaction("lgvhr", "lgvatt/LGVATT40011/saveApproval", param, function( data ){
				myForm.hideProgress();
				Message.alert( "<lgcom:message code='note.com.successfullyApproved'/>" );

				//창닫기
				Popup.closePopup(myForm,true);
			});
		} else if(mode == "nonrequested") {
			myForm.showProgress();
			myForm.transaction("lgvhr", "lgvatt/LGVATT40011/updateAttendanceResult", param, function( data ){
				myForm.hideProgress();

				//창닫기
				Popup.closePopup(myForm,true);
			});
		}
    }
	
	//요청전 실적입력값 체크
	function fncValidateResultSaveRequestInfo() {
		var dataProvider = resultGrid.getDataProvider();
		var cgrid = resultGrid.getGridBase();
		
		//행추가로 강제 생성된 행이기 때문에 행 상태는 created
		var rowIdxs = dataProvider.getRowCount();
		for ( var i=0; i<rowIdxs; i++ ) {
			var rowData = dataProvider.getJsonRow(i);
			
			//근태일자 없는 경우 오류
			if ( isNull(rowData["attendanceYyyymmddResult"]) ) {
				Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.date'/>"/>');
				cgrid.setCurrent({itemIndex:cgrid.getItemIndex(i), column:'attendanceYyyymmddResult'});
				cgrid.setFocus();
				return false;
			}
			//근태코드 없는 경우 오류
			if ( isNull(rowData["attendanceCode"]) ) {
				Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.actualAttendanceDetail'/>"/>');
				cgrid.setCurrent({itemIndex:cgrid.getItemIndex(i), column:'attendanceType'});
				cgrid.setFocus();
				return false;
			//근태코드에 대한 상세코드가 있는 경우 상세코드 선택값 없으면 오류
			} else if ( isNull(rowData["timeAttendDetailCode"]) && valueset.get("attendanceDetailCodeList").findIndex(function ( item ) { return item.attendanceCode == rowData["attendanceCode"]}) > -1 ) {
				Message.alert('<lgcom:message code="note.att.emptyAttendanceDetailReason"/>');
				cgrid.setCurrent({itemIndex:cgrid.getItemIndex(i), column:'timeAttendDetailCode'});
				cgrid.setFocus();
				return false;
			}
			//석식여부 없는 경우 오류
			if ( isNull(rowData["eveningMealFlag"]) ) {
				Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.actualDinnerChk'/>"/>');
				cgrid.setCurrent({itemIndex:cgrid.getItemIndex(i), column:'eveningMealFlag'});
				cgrid.setFocus();
				return false;
			}
		}
		return true;
	}
	
	//화면에 필요한 기본정보 조회
	function fncRetrieveInitData(mode) {
		
		if(mode == "requested") {
			
			resultGrid.loadData("lgvhr", "lgvatt/LGVATT40011/retrieveInitData", requestInfoFormUtil.getValue(), function( data ) {
				myForm.hideProgress();
				if(data.result) {
					for(var i=0; i<data.result.length; i++) {
						
						if( data.result[i].attendDays == 0 ) {
							resultGrid.getGridBase().setCellStyles(i, controlColumns.deductionColumn, "unableEdit");
						} else {
							resultGrid.getGridBase().setCellStyles(i, controlColumns.deductionColumn, "enableEdit");
						}
						
					}
				}
			});
			
		} else if(mode == "nonrequested") {

			resultGrid.loadData("lgvhr", "lgvatt/LGVATT40011/retrieveNonRequestorData", requestInfoFormUtil.getValue(), function( data ) {
				myForm.hideProgress();
				if(data.result) {
					for(var i=0; i<data.result.length; i++) {
						
						if( data.result[i].attendDays == 0 ) {
							resultGrid.getGridBase().setCellStyles(i, controlColumns.deductionColumn, "unableEdit");
						} else {
							resultGrid.getGridBase().setCellStyles(i, controlColumns.deductionColumn, "enableEdit");
						}
						
					}
				}
			});
			
		}
	}
	
	//화면 로딩 시 레이아웃 설정
	function fncInitLayout(mode) {
		
		var empNameTitle = "<lgcom:message code='label.att.employeeName'/>";
		var empNotitle = "<lgcom:message code='label.att.id'/>";
		var nameSubTitle = empNameTitle + " : ";
		var idSubTitle = empNotitle + " : ";
		
		$(".resultSubTitle").append("<h3>" + 
									idSubTitle + requestInfoFormUtil.getValue("employeeNo") +
									" , " + 
									nameSubTitle + requestInfoFormUtil.getValue("employeeName") +
									"</h3>"
								   );
		
		//화면 버튼 처리
		if(mode == "requested") {
			myForm.select(".buttonControls button[data-action='approval']").show();
			myForm.select(".buttonControls button[data-action='save']").hide();
		} else if(mode == "nonrequested") {
			myForm.select(".buttonControls button[data-action='approval']").hide();
			myForm.select(".buttonControls button[data-action='save']").show();
		}
	}
	
	//결재의견 레이어 팝업 보여주기
    function showCommentWindow() {
    	myForm.select(".buttonControls button[data-action]" ).prop("disabled", true);
    	$("._approvalPopupWindow ._commentWindow button[action='ok']").removeAttr("disabled");
    	$("._approvalPopupWindow ._commentWindowBack").show();
    	$("._approvalPopupWindow ._commentWindow").show();
    }
	
	//결재의견 레이어 팝업 숨기기
    function hideCommentWindow() {
    	myForm.select(".buttonControls button[data-action]" ).prop("disabled", false);
    	$("._approvalPopupWindow ._commentWindow button[action='ok']").removeAttr("disabled");
    	$("._approvalPopupWindow ._commentWindowBack").hide();
    	$("._approvalPopupWindow ._commentWindow").hide();
    }
	
	//화면로딩 시 결재의견 레이어 팝업 숨김
    hideCommentWindow();
}

LGVATT40011.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVATT40011();
		form.init();		
	});
});
</script>
</head>

<body>
<div class="mdi-container">
	<section class="page-content">
		<%-- 버튼 --%>
		<div class="buttonControls module-group text-right">
	        <div class="btn-toolbar">
	            <div class="btn-group">
					<button class="btn btn-darkgray btn-sm" type="button" data-action="approval" disabled><lgcom:message code="Approval"/></button>
					<button class="btn btn-darkgray btn-sm" type="button" data-action="save" disabled><lgcom:message code="Save"/></button>
	            </div>
	        </div>
		</div>
		<form class="form requestInfo">
			<input type="hidden" name="employeeNo" />
			<input type="hidden" name="employeeName" />
			<input type="hidden" name="attendanceYyyymmdd" />
		</form>
		<%-- 실적 그리드 --%>
		<div class="resultBlock grid-wrap">
			<div class="sub-header resultSubTitle"></div>
			<div class="grid resultGrid"></div>
		</div>
		
		<%-- Comment 입력 부분(approval.jsp 참고하여 작성함) --%>
		<div class="_approvalPopupWindow">
			<div class="_commentWindowBack"></div>
			<div class="panel panel-default _commentWindow" role="dialog" >
				<div class="panel-heading">
					<h3 class="panel-title"><span class="actionName"></span> <lgcom:message code="Comment" /></h3>
				</div>
				<div class="panel-body">
					<textarea class="_comment input-require form-control input-sm"></textarea>
				</div>
				<div class="panel-footer">
					<div class="gridControls" style="margin:0px;">
						<button class="btn btn-darkgray btn-xs" data-action="ok" ><lgcom:message code="Ok"/></button>
						<button class="btn btn-gray btn-xs"  data-action="cancel"><lgcom:message code="Cancel"/></button>
					</div>
				</div>
			</div>
		</div>
	</section>
</div>
</body>
</html>
