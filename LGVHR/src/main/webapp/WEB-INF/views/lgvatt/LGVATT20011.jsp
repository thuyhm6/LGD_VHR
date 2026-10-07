<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVATT20011.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 임직원이 일근태 계획/실적 조회 및 결재요청하는 팝업 화면입니다.
    작성자 : 임수진
    HMT_20210410     Add month ot total with month ot limit
    HMT_20210717     Swap weekly holiday (Add employeeNo)
-------------------------------------------------------------%>

<c:set var="flg_vn_line_worker_pic_user" value="N"/>
<c:forEach var="roles" items="${sessionScope.USER_SESSION.roleList}">
    <c:if test="${roles.systemCode=='LGVHR' && roles.moduleCode=='LGVATT' && fn:indexOf(roles.roleCode,'VN_LINE_WORK_PIC_USER')>=0 }">
        <c:set var="flg_vn_line_worker_pic_user" value="Y"/>
    </c:if>
</c:forEach>

<html lang="ko">
<head>
<title><lgcom:message code="label.att.dailyRegistration"/></title>
<script src="/lgvhr/static/js/lgvatt.js"></script>
<style type="text/css">
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
var LGVATT20011 = function() {
	var grid;
	var myForm = this;
	/* Form Util 선언 */ 
	var requestInfoFormUtil = new FormUtil( myForm, "form.requestInfo");//요청기본정보
	var approvalInfoFormUtil = new FormUtil(myForm, "form.approvalInfo");//결재자정보
	var dailyAttendancePopup = myForm.getParent().popupInfo.dailyAttendancePopup;
	var mode = "VIEW";
	var gridEditFlag = false;
	
	var isPicUser = ('<c:out value="${flg_vn_line_worker_pic_user}"/>' == 'Y')?true:false;  // 근태 담당자 여부 pic

	//요청폼 값 셋팅
	requestInfoFormUtil.setValue({employeeNo:dailyAttendancePopup["employeeNo"], attendanceYyyymmdd:dailyAttendancePopup["attendanceYyyymmdd"]});
	//화면 최초 레이아웃 설정
	fncInitLayout();

    // 화면 레이아웃 정의
	myForm.setLayout([
		{ name : "controls",           left : 0, right : 0, top : 0  },
		{ name : "resultBlock",        left : 0, right : 0, top : "controls", height : 250 },
		{ name : "planBlock",          left : 0, right : 0, top : "resultBlock", height : 250 },
		{ name : "approvalArea",       left : 0, right : 0, top : "planBlock", height : 150 },
		{ name : "guideline_Viet",     left : 0, right : 0, top : "approvalArea", height : 800 },
		{ name : "guideline_Eng",      left : 0, right : 0, top : "guideline_Viet", bottom : 0 }
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
    var planGrid   = buildGrid(".planGrid");
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
    
    // 팝업 데이터 정의 searchMode:single(단수),multi(복수)
	myForm.popupInfo = {
		userPopup   : {searchMode:'single', popupKind:'', confirmKind:'', employeeNo:'', employeeName:'', attDate:'', userData:[]},
	};
    
	//기본정보 조회
	fncRetrieveInitData();

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
			case 'request':				
				//결재요청
				fncSaveRequestInfo();
				break;
				
			case 'cancel':
				//창닫기
				Popup.closePopup(myForm);
				break;

			case "resetRows":
				//결재자 reset
				var target = $(item).data("target");
				if( target == "approvalInfoTable" ) {
					myForm.select( "." + target + " tbody tr.ARM_N" ).remove();//재량권 외 추가한 행 삭제
					fncRetrieveARMInfo();
				} else {
					myForm.select( "." + target + " tbody" ).empty();
				}
				fncManageButton();
				break;

			case "insertRowTop":
				//결재자 추가
				if( $(item).data( "target" ) == "approvalInfoTable" ) {
					myForm.popupInfo.userPopup = { searchMode : "single"};
					var popup = new Popup( myForm, "lgcom", "M_LGUTLC_1142", "Approver" );
					popup.setSize( 1000, 528 );
					popup.open( function(){
						var result = myForm.popupInfo.userPopup.userData;
						if( result != undefined ) {
							if(  myForm.select( "." + $(item).data( "target" ) + " tbody tr" ).length == 0  ) {
								appendTableRow( $(item).data( "target" ), result[0] );
							} else {
								appendTableRow( $(item).data( "target" ), result[0], myForm.select( "." + $(item).data( "target" ) + " tbody tr:first-child"), -1 );
							}
						}
					});
				}
				break;
		}
	});

	/*** 내부 함수 ***/
    //그리드 초기화 
	function buildGrid(gridId) {
		var grid;
		var readOnyBgColor = "#e9e9e9";
		switch ( gridId ) {
			case ".planGrid" :	
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
						header: {height: 60}
					},
					display: { fitStyle: 'none' }
				});		
				
				//마우스 오른쪽 클릭시 메뉴
				grid.setContextMenu();
				
				//필드 설정
				grid.setFields(
						[
			              { fieldName:'attendanceYyyymm'         , dataType:'text'  },
			              { fieldName:'attendanceYyyymmdd'       , dataType:'text'  },
			              { fieldName:'attendanceYmd'            , dataType:'text'  },
			              { fieldName:'weekName'                 , dataType:'text'  },
			              { fieldName:'screenWeekName'           , dataType:'text'  },
			              { fieldName:'attendanceType'           , dataType:'text'  },
			              { fieldName:'attendanceTypeName'       , dataType:'text'  },
			              { fieldName:'attendanceCode'           , dataType:'text'  },
			              { fieldName:'attendanceName'           , dataType:'text'  },
			              { fieldName:'shiftTypeCode'            , dataType:'text'  },
			              { fieldName:'shiftTypeName'            , dataType:'text'  },
			              { fieldName:'timeAttendDetailCode'     , dataType:'text'  },
			              { fieldName:'timeAttendInputReasonDesc', dataType:'text'  },
			              { fieldName:'nightShiftFlag'           , dataType:'text'  },
			              { fieldName:'eveningMealFlag'          , dataType:'text'  },
			              { fieldName:'overtimeSumHours'         , dataType:'number'},
			              { fieldName:'planningId'               , dataType:'text'  },
			              { fieldName:'approvalRequestId'        , dataType:'text'  },
			              { fieldName:'progressStatusCode'       , dataType:'text'  },
			              { fieldName:'inputEnableFlag'          , dataType:'text'  },
			              { fieldName:'updateEnableFlag'         , dataType:'text'  },
				          { fieldName:'holidayFlag'              , dataType:'text'  }
						]
				);
				//컬럼 콤보 셋팅
				grid.setLookupsMultiLvl({"attendanceType":{data:valueset.get("attendanceTypeList"), keyField:['updateEnable', 'code']},
			                             "attendanceCode":{data:valueset.get("attendanceCodeList"), keyField:['updateEnable', 'attendTypeName', 'code']},
			                             "nightShiftFlag":code.get("LGVHR_DAY_NIGHT_FLAG"),
			                             "eveningMealFlag":code.get("LGCOM_YN_FLAG"),
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
								editable: false
							},
							{	type:'group',
								name:'planAttendance',
								fieldName:'planAttendance',
								width:330,
								header:{
							         text:'<lgcom:message code="label.att.planAttendance" />'
							    },
								orientation:'horizontal',
								columns: [
											{	name:'attendanceType',
												fieldName:'attendanceType',
												width:90,
												header: {text:'<lgcom:message code="label.att.planAttendanceType"/>'},
												styles: {textAlignment:'near'},
											    renderer: {showTooltip: true},
												lookupDisplay: true,
												lookupSourceId: 'attendanceType',
												lookupKeyFields: ['updateEnableFlag', 'attendanceType'],
												editor: {type:'dropDown',textReadOnly:true},
												editable : true
											},
											{	name:'attendanceCode',
												fieldName:'attendanceCode',
												width:110,
												header: {text:'<lgcom:message code="label.att.planAttendanceDetail"/>'},
												styles: {textAlignment:'near'},
											    renderer: {showTooltip: true},
												lookupDisplay: true,
												lookupSourceId: 'attendanceCode',
												lookupKeyFields: ['updateEnableFlag', 'attendanceType', 'attendanceCode'],
												editor: {type:'dropDown',textReadOnly:true},
												editable : true
											},
											{	name:'timeAttendDetailCode',
												fieldName:'timeAttendDetailCode',
												width:120,
												header: {text:'<lgcom:message code="label.att.timeAttendDetailCode"/>'},
												styles: {textAlignment:'near'},
											    renderer: {showTooltip: true},
												lookupDisplay: true,
												lookupSourceId: 'timeAttendDetailCode',
												lookupKeyFields: ['attendanceCode', 'timeAttendDetailCode'],
												editor: {type:'dropDown',textReadOnly:true},
												editable : true
											}
										]
							},
							{	name:'overtimeSumHours',
								fieldName:'overtimeSumHours',
								width:40,
								header: {text:'<lgcom:message code="label.att.totalOT"/>'},
								styles: {textAlignment:'far', numberFormat: '#0.0'},
								editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
								editable : true
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
							{
								name:'eveningMealFlag',
								fieldName:'eveningMealFlag',
								width:50,
								header: {text:'<lgcom:message code="label.att.actualDinnerChk"/>'},
								styles: {textAlignment:'center'},
								lookupDisplay: true,
								lookupSourceId: 'eveningMealFlag',
								lookupKeyFields: ['eveningMealFlag'],
								editor: {type:'dropDown',textReadOnly:true},
								editable: true
								
							}
						]
				);
				//그리드 필수값 체크
				grid.setValidations([
					{criteria: "value['attendanceCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.actualAttendanceDetail'/>"/>',mode:'always',level:'error'},
					{criteria: "value['eveningMealFlag'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.actualDinnerChk'/>"/>',mode:'always',level:'error'}
				]);
				break;
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
							{ fieldName:'attendanceYyyymm'          , dataType:'text'  },
							{ fieldName:'attendanceYyyymmdd'        , dataType:'text'  },
							{ fieldName:'attendanceYmd'             , dataType:'text'  },
							{ fieldName:'weekName'     	            , dataType:'text'  },
							{ fieldName:'screenWeekName'     	    , dataType:'text'  },
							{ fieldName:'attendanceType'            , dataType:'text'  },
				            { fieldName:'attendanceTypeName'        , dataType:'text'  },
							{ fieldName:'attendanceCode'            , dataType:'text'  },
							{ fieldName:'attendanceName'            , dataType:'text'  },
							{ fieldName:'shiftTypeCode'             , dataType:'text'  },
							{ fieldName:'shiftTypeName'             , dataType:'text'  },
				            { fieldName:'timeAttendDetailCode'      , dataType:'text'  },
				            { fieldName:'timeAttendInputReasonDesc' , dataType:'text'  },
							{ fieldName:'workStartTime'             , dataType:'text'  },
							{ fieldName:'workStartTimeOri'          , dataType:'text'  },
							{ fieldName:'inTime'                    , dataType:'text'  },
							{ fieldName:'outTime'                   , dataType:'text'  },
							{ fieldName:'nightShiftFlag'            , dataType:'text'  },
							{ fieldName:'eveningMealFlag'           , dataType:'text'  },
							{ fieldName:'actualOtHours'             , dataType:'number'},//HMT_20260831
							{ fieldName:'actualOtMinutes'           , dataType:'number'},//HMT_20260831
							{ fieldName:'overtimeSumHours'          , dataType:'number'},
							{ fieldName:'monthTotalOvertime'        , dataType:'number'},//HMT_20210410
							{ fieldName:'overtimeLimit'             , dataType:'number'},//HMT_20210410
							{ fieldName:'weekdayOvertimeHours'      , dataType:'number'},
							{ fieldName:'holidayOvertimeHours'      , dataType:'number'},
							{ fieldName:'publicHolidayOvertimeHours', dataType:'number'},
							{ fieldName:'weekdayNightOvertimeHours' , dataType:'number'},
							{ fieldName:'weekdayOtAfNightWorkHours' , dataType:'number'},
							{ fieldName:'holidayNightOvertimeHours' , dataType:'number'},
							{ fieldName:'publicHolidayNightOtHours' , dataType:'number'},
							{ fieldName:'normalNightOvertimeHours'  , dataType:'number'},
							{ fieldName:'tardyHours'                , dataType:'number'},
							{ fieldName:'earlyLeaveHours'           , dataType:'number'},
							{ fieldName:'goingOutHours'             , dataType:'number'},
							{ fieldName:'specialBonusHours'         , dataType:'number'},
							{ fieldName:'helpcallSupportHours'      , dataType:'number'},
							{ fieldName:'approvalRequestId'         , dataType:'text'  },
							{ fieldName:'progressStatusCode'        , dataType:'text'  },
							{ fieldName:'inputEnableFlag'           , dataType:'text'  },
				            { fieldName:'updateEnableFlag'          , dataType:'text'  },
				            { fieldName:'holidayFlag'               , dataType:'text'  },
				            { fieldName:'inTimeRedFlag'             , dataType:'text'  },
				            { fieldName:'outTimeRedFlag'            , dataType:'text'  }
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
								dynamicStyles:[{criteria:"values['inTimeRedFlag']='Y'", styles:{foreground:"#f34d78"}}]
							},
							{	name:'outTime',
								fieldName:'outTime',
								width:40,
								header: {text:'<lgcom:message code="label.att.outTime"/>'},
								styles: {textAlignment:'center', background:readOnyBgColor},
								editable:false,
								visible:true,
								dynamicStyles:[{criteria:"values['outTimeRedFlag']='Y'", styles:{foreground:"#f34d78"}}]
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
							{	//HMT_20260831 Start
								type:'group',
								name:'totalOT',
								fieldName:'totalOT',
								width:130,
								header:{
							         text:'<lgcom:message code="label.att.totalOT" />'
							    },
								orientation:'horizontal',
								columns: [
											{	name:'actualOtHours',
												fieldName:'actualOtHours',
												width:45,
												header: {text:'<lgcom:message code="label.pay.hour"/>'},
												styles: {textAlignment:'far', numberFormat: '#0.0'},
												editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
												editable: true
											},
											{	name:'actualOtMinutes',
												fieldName:'actualOtMinutes',
												width:45,
												header: {text:'<lgcom:message code="label.pay.minutes"/>'},
												styles: {textAlignment:'far', numberFormat: '#0.0'},
												editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
												editable: true
											},
											{	name:'overtimeSumHours',
												fieldName:'overtimeSumHours',
												width:40,
												header: {text:'<lgcom:message code="label.att.totalOT"/>'},
												styles: {textAlignment:'far', background: readOnyBgColor, numberFormat: '#0.0'},
												editable: false
											}
										]
							},
							//HMT_20260831 End
							//HMT_20210410 Start
							{	name:'monthTotalOvertime',
								fieldName:'monthTotalOvertime',
								width:50,
								header: {text:'<lgcom:message code="label.att.monthTotalOT"/>'},
								styles: {textAlignment:'far', background: readOnyBgColor, numberFormat: '#0.0'},
								editable: false
							},
							{	name:'overtimeLimit',
								fieldName:'overtimeLimit',
								width:50,
								header: {text:'<lgcom:message code="label.att.monthOtLimit"/>'},
								styles: {textAlignment:'far', background: readOnyBgColor, numberFormat: '#0.0'},
								editable: false
							},
							//HMT_20210410 End
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
	//계획근태유형 선택 시 선택 불가능한 값 체크
	planGrid.getGridBase().onEditRowChanged = function (cgrid, itemIndex, dataRow, field, oldValue, newValue) {
		<%--[PARAMETER]
	    	- cgrid : grid.getGridBase()
	    	- itemIndex : 변경된 행 row index
	        - dataRow   : 변경된 행 데이터 row index
	        - field : 편집된 필드 인덱스
	        - oldValue : 편집전 셀 데이터 값
	        - newValue : 편집후 셀 데이터 값
		--%>
		var provider = cgrid.getDataProvider();
		var fieldName = provider.getOrgFieldName(field);
		
		if ( fieldName == "attendanceType" ) {
			//계획근태에서 선택 불가능한 근태유형인지 체크
			if ( attendCodeAllList.findIndex(function(item) {return (item.attendTypeName == newValue && item.useFlag == "Y" && item.planTgFlag == "Y") }) == -1 ) {//사용불가능한 근태유형인 경우
				Message.alert("<lgcom:message code="note.att.changeAttendTypePlan"/>");<%-- 계획근태에서 선택할 수 없는 근태유형입니다. --%>
				cgrid.setValue(itemIndex, "attendanceType", oldValue);
				cgrid.commit();
			}
		}  
	};
    /* 그리드 이벤트 처리 */
    //계획 근태유형에 따른 근태코드 셋팅
	planGrid.getGridBase().onEditCommit = function(cgrid, index, oldValue, newValue) {
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
			//계획근태에서 선택 불가능한 근태유형인지 체크
			if ( attendCodeAllList.findIndex(function(item) {return (item.attendTypeName == newValue && item.useFlag == "Y" && item.planTgFlag == "Y") }) > -1 ) {//사용가능한 근태유형인 경우
				var exists = cgrid.existsLookupData('attendanceCode',[newValue,cgrid.getValue(index.itemIndex,'attendanceCode')]);
				if(!exists) {
					var attendCodeLookup = valueset.get('attendanceCodeList');
					var attendCode = '';
					for(var i=0; i < attendCodeLookup.length; i++) {
						if($.trim(attendCodeLookup[i]['attendTypeName']) == newValue) {
							attendCode = $.trim(attendCodeLookup[i]['code']);
							break;
						}
					}
					cgrid.setValue(index.itemIndex,'attendanceCode',attendCode);
					
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
							cgrid.setValue(index.itemIndex,'timeAttendDetailCode', detailReasonCode);
						}
					}
					
					//근태유형에 따른 근태코드 변경되므로, 값 초기화
			    	fncResetRowData(cgrid, index.itemIndex, "PLAN");
				}
			}
		} else if(index.column == 'attendanceCode') {
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
			
			fncResetRowData(cgrid, index.itemIndex, "PLAN");
		}
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
				fncCompareOtTotal(cgrid, index.itemIndex);//HMT_20210410
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
			fncCompareOtTotal(cgrid, index.itemIndex);//HMT_20210410
		}
	}
	//휴일/평일에 따른 OT입력 최대값 체크
	planGrid.getGridBase().onCellEdited = function (cgrid, itemIndex, dataRow, field) {
		<%--[PARAMETER]
	    	- cgrid : grid.getGridBase()
	    	- itemIndex : 편집중인 행 row index
	        - dataRow   : 편집중인 행 데이터 row index
	        - field : 편집된 필드 인덱스
		--%>
		cgrid.commit();
		var provider = cgrid.getDataProvider();
	    var fieldName = provider.getOrgFieldName(field);
	    
	    //근태코드 변경 시 석식여부, OT 초기화
	    if ( fieldName == "attendanceCode" ) {
	    	fncResetRowData(cgrid, itemIndex, "PLAN");
	    
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
	    	}
	    }<%-- // if ( fieldName == "attendanceCode" ) { --%>
	}
	//석식여부, OT시간 셀 수정시 이벤트
	resultGrid.getGridBase().onCellEdited = function (cgrid, itemIndex, dataRow, field) {
		<%--[PARAMETER]
	    	- cgrid : grid.getGridBase()
	    	- itemIndex : 편집중인 행 row index
	        - dataRow   : 편집중인 행 데이터 row index
	        - field : 편집된 필드 인덱스
		--%>
		cgrid.commit();
		var provider = cgrid.getDataProvider();
	    var fieldName = provider.getOrgFieldName(field);

		//근태코드 변경 시 석식여부, OT 초기화
	    if ( fieldName == "attendanceCode" ) {
			//OT계산
			fncCalculateOT(cgrid, itemIndex);
			fncCompareOtTotal(cgrid, itemIndex);//HMT_20210410
			
		//석식여부 변경시 OT시간이 있으면 재계산
	    } else if ( fieldName == "eveningMealFlag" ) {
			//OT계산
			fncCalculateOT(cgrid, itemIndex);
			fncCompareOtTotal(cgrid, itemIndex);//HMT_20210410
			
		//출근시간 변경 시 OT 재계산
		} else if ( fieldName == "workStartTime" ) {
			//OT계산
			fncCalculateOT(cgrid, itemIndex);
			fncCompareOtTotal(cgrid, itemIndex);//HMT_20210410
			
		// actualOtHours, actualOtMinutes 값 검증 후 overtimeSumHours 재계산 (HMT_20260831)
	    } else if ( fieldName == "actualOtHours" || fieldName == "actualOtMinutes" ) {
	    	if ( fieldName == "actualOtHours" ) {
	    		var otHoursVal = cgrid.getValue(itemIndex, "actualOtHours");
	    		if ( Number(otHoursVal) != 0 && ( isNaN(otHoursVal) || otHoursVal % 1 != 0 || otHoursVal < 1 || otHoursVal > 23 ) ) {
	    			Message.alert('<lgcom:message code="note.att.CheckOTHours"/>');
	    			cgrid.setValue(itemIndex, "actualOtHours", 0);
	    		}
	    	}

	    	if ( fieldName == "actualOtMinutes" ) {
	    		var attType = cgrid.getValue(itemIndex, "attendanceCode");
	    		var otMinutesVal = cgrid.getValue(itemIndex, "actualOtMinutes");

	    		if ( attType != 'WH' && attType != 'PH' ) {
	    			if ( Number(otMinutesVal) != 0 && Number(otMinutesVal) != 30 ) {
	    				Message.alert('<lgcom:message code="note.att.WHPHCheckMinuties"/>');
	    				cgrid.setValue(itemIndex, "actualOtMinutes", 0);
	    			}
	    		} else if ( Number(otMinutesVal) != 0 && ( isNaN(otMinutesVal) || otMinutesVal % 1 != 0 || otMinutesVal < 1 || otMinutesVal > 59 ) ) {
	    			Message.alert('<lgcom:message code="note.att.CheckOTMinuties"/>');
	    			cgrid.setValue(itemIndex, "actualOtMinutes", 0);
	    		}
	    	}

	    	//actualOtHours, actualOtMinutes 값으로 overtimeSumHours 재계산
	    	var otHours = Number(cgrid.getValue(itemIndex, "actualOtHours")) || 0;
	    	var otMinutes = Number(cgrid.getValue(itemIndex, "actualOtMinutes")) || 0;
	    	var otSumHours = Math.round((otHours + otMinutes / 60) * 10) / 10;

		    //휴일, 평일별 OT 시간 제약
	    	if ( cgrid.getValue(itemIndex, "holidayFlag") == "Y" ) {
	    		otSumHours = Math.min(otSumHours, 24);//휴일 최대 24시간
	    	} else {
	    		otSumHours = Math.min(otSumHours, 16);//평일 최대 16시간
	    	}
	    	cgrid.setValue(itemIndex, "overtimeSumHours", otSumHours);
			//OT계산
			fncCalculateOT(cgrid, itemIndex);
			fncCompareOtTotal(cgrid, itemIndex);//HMT_20210410
		
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
			fncCompareOtTotal(cgrid, itemIndex);//HMT_20210410

		//조퇴 입력 시 입력값 체크 및 야간근무이면 night 30%차감 로직 추가
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
			fncCompareOtTotal(cgrid, itemIndex);//HMT_20210410

		//외출 입력 시 입력값 체크 및 야간근무이면 night 30%차감 로직 추가
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
			fncCompareOtTotal(cgrid, itemIndex);//HMT_20210410
	    }
	}
	//입력값 validation
    planGrid.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	}
	//입력값 validation
    resultGrid.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	}
	//값 초기화
	function fncResetRowData(cgrid, itemIndex, planResultType) {
		if ( planResultType == "PLAN" ) {
	    	cgrid.setValue(itemIndex, "eveningMealFlag", "N");//석식여부는 기본값을 N으로 한다.
	    	cgrid.setValue(itemIndex, "overtimeSumHours", 0);
	    	
		} else if ( planResultType == "RESULT") {
	    	cgrid.setValue(itemIndex, "eveningMealFlag", "N");//석식여부는 기본값을 N으로 한다.
	    	cgrid.setValue(itemIndex, "workStartTime", cgrid.getValue(itemIndex, "workStartTimeOri"));
	    	cgrid.setValue(itemIndex, "actualOtHours", 0);//HMT_20260831
	    	cgrid.setValue(itemIndex, "actualOtMinutes", 0);//HMT_20260831
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
			cgrid.setValue(itemIndex, "timeAttendInputReasonDesc", null);
		}
	}
	//OT재계산
	function fncCalculateOT(cgrid, rowIndex) {
		
		var param = {subsidiaryCode    :"${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}",
			         employeeNo        :"${sessionScope.LGVHR_PROJECT_SESSION.employeeNo}", //HMT_20210717     
			         attendanceYyyymmdd:$.trim(cgrid.getValue(rowIndex, "attendanceYyyymmdd")),
			         attendanceCode    :$.trim(cgrid.getValue(rowIndex, "attendanceCode")),
			         shiftTypeCode     :$.trim(cgrid.getValue(rowIndex, "shiftTypeCode")),
			         dayNightFlag      :$.trim(cgrid.getValue(rowIndex, "nightShiftFlag")),
			         dinnerFlag        :$.trim(cgrid.getValue(rowIndex, "eveningMealFlag")),
			         workingStartTime  :$.trim(cgrid.getValue(rowIndex, "workStartTime")),
			         lateness          :Number($.trim(cgrid.getValue(rowIndex, "tardyHours"))).toString(),
			         leavingEarly      :Number($.trim(cgrid.getValue(rowIndex, "earlyLeaveHours"))).toString(),
			         goingOut          :Number($.trim(cgrid.getValue(rowIndex, "goingOutHours"))).toString(),
			         overtimeSumHours  :Number($.trim(cgrid.getValue(rowIndex, "overtimeSumHours"))).toString()
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
	//Compare month ot total with month ot limit HMT_20210410 Start
	function fncCompareOtTotal(cgrid, rowIndex) {
    	var monthOtTotal = cgrid.getValue(rowIndex, "monthTotalOvertime");
    	var monthOtLimit = cgrid.getValue(rowIndex, "overtimeLimit");
    	var overtimeSumHours = cgrid.getValue(rowIndex, "weekdayOvertimeHours") + cgrid.getValue(rowIndex, "holidayOvertimeHours") + cgrid.getValue(rowIndex, "publicHolidayOvertimeHours") + 
                               cgrid.getValue(rowIndex, "weekdayNightOvertimeHours") + cgrid.getValue(rowIndex, "weekdayOtAfNightWorkHours") + 
                               cgrid.getValue(rowIndex, "holidayNightOvertimeHours") + cgrid.getValue(rowIndex, "publicHolidayNightOtHours");
		if ( overtimeSumHours + monthOtTotal > monthOtLimit ) {
			cgrid.setValue(rowIndex, "actualOtHours", 0);//HMT_20260831
			cgrid.setValue(rowIndex, "actualOtMinutes", 0);//HMT_20260831
			cgrid.setValue(rowIndex, "overtimeSumHours", 0);
			cgrid.setValue(rowIndex, "weekdayOvertimeHours", 0);
			cgrid.setValue(rowIndex, "holidayOvertimeHours", 0);
			cgrid.setValue(rowIndex, "publicHolidayOvertimeHours", 0);
			cgrid.setValue(rowIndex, "weekdayNightOvertimeHours", 0);
			cgrid.setValue(rowIndex, "weekdayOtAfNightWorkHours", 0);
			cgrid.setValue(rowIndex, "holidayNightOvertimeHours", 0);
			cgrid.setValue(rowIndex, "publicHolidayNightOtHours", 0);
			cgrid.setValue(rowIndex, "normalNightOvertimeHours", 0);
			Message.alert("<lgcom:message code="note.att.OtExceedLevel"/>" + "! " + monthOtTotal + " + "+overtimeSumHours+" > " + monthOtLimit);
			myForm.hideProgress();
			return ;
		}
	}
	//HMT_20210410 End
	//재량권 조회
	function fncRetrieveARMInfo() {
		/* 재랑권 정보 조회. parameter[armNo:재량권번호]  */
		
		var empNo = '';
		if( (nvl(requestInfoFormUtil.getValue("employeeNo")) != "${sessionScope.LGVHR_PROJECT_SESSION.employeeNo}") && isPicUser ) {
			empNo = requestInfoFormUtil.getValue("employeeNo");
		}
		
		myForm.transaction("lgvhr", "lgvatt/LGVATTCOMM/retrieveARMInfo", {armNo:requestInfoFormUtil.getValue("armNo"), employeeNo:empNo} , function( data ){
			var list = data["result"];			
			myForm.select(".approvalInfoTable tbody").empty();
			$(list).each( function(){
				this["settlementDeleteFlag"] = "Y";
				fncAppendTableRow( "approvalInfoTable", this );
			});
		});
	}
	//행추가
	function fncAppendTableRow( target, item, appendTarget, direction ) {
		if( direction == undefined ) {
			direction = 1;
		}

		var disabled = "";
		if(  mode == "VIEW" ) {
			disabled = "disabled";
		}

		var userName = nvl( item["employeeName"] )         + " / " + nvl( item["titleName"] )         + " / " + nvl( item["departmentName"] ) ;
		var mendator = nvl( item["mendatorEmployeeName"] ) + " / " + nvl( item["mendatorTitleName"] ) + " / " + nvl( item["mendatorDepartmentName"] ) ;

		if( mendator.trim() == "/  /" ) {
			mendator = "";
		}

		if( item["settlementDeleteFlag"] == undefined ) {
			item["settlementDeleteFlag"] = "N";
		}
		
		if( target == "approvalInfoTable" ) {
			var body = myForm.select(".approvalInfoTable tbody");

			var selectText = "<lgcom:message code="label.att.approval"/>";
			selectText    += "<input type='hidden' name='approvalActionCode' value='APPROVAL' />";

			var str = "<tr class='ARM_"+ item["settlementDeleteFlag"] +"'>"+
			          "<td class='text-center'>" + ( $(body).find("tr").length + 1 ) + "</td>"+
			          "<td class='text-center'>"+ selectText +"</td>"+
			          "<td>"+ userName +
			          "<input type='hidden' name='applicationUserId' value='"+ item["employeeId"] +"' />"+
			          "<input type='hidden' name='positionName' value='"+ nvl(item["positionName"]) +"' />"+
			          "<input type='hidden' name='lineType' value='APPROVER' />"+
			          "<input type='hidden' name='employeeNo' value='"+ item["employeeNo"] +"' />"+
			          "<input type='hidden' name='settlementDeleteFlag' value='"+ item["settlementDeleteFlag"] +"' />"+
			          "</td>"+
			          "<td>"+ mendator + " <input type='hidden' name='menDatorApplicationUserId' value='"+ nvl(item["mandatorUserId"]) +"' /><input type='hidden' name='menDatorAemployeeNo' value='"+ nvl(item["mandatorEmployeeNo"]) +"' /></td>"+
			          "</tr>";

			if( appendTarget == undefined ) {
				body.append( str );
			} else {
				if( direction < 0 ) {
					$(str).insertBefore( appendTarget );
				} else {
					$(str).insertAfter( appendTarget );
				}
			}
		} else if( target == "approvalInfoTableView" ){
			var body = myForm.select(".approvalInfoTableView tbody");

			var str = "<tr>"+
			          "<td class='text-center'>" + item["approvalSeqs"] + "</td>"+
			          "<td class='text-center'>"+ item["approvalActionName"] +"</td>"+
			          "<td class='text-center'>"+ userName + "</td>"+
			          "<td class='text-center'>"+ mendator + "</td>"+
			          "<td class='text-center'>"+ item["approvalStatusCodeName"] +"</td>"+
			          "<td class='text-center'>"+ nvl( item["approvalDate"] ) +"</td>"+
			          "<td class='text-left'>"+ nvl( item["approvalComment"] ) +"</td>"+
			          "</tr>";

			if( appendTarget == undefined ) {
				body.append( str );
			} else {
				if( direction < 0 ) {
					$(str).insertBefore( appendTarget );
				} else {
					$(str).insertAfter( appendTarget );
				}
			}

		}
		fncManageButton();
	}

	/* Delete 버튼 류는 필요한 시점이 아니면,  Disabled 돼야 하는 상황이라, table 에 기반한 이 버튼의 움직임을 */
	function fncManageButton() {
		myForm.select(".approvalInfoTable tbody tr:first-child .delete").hide();

		if( myForm.select(".approvalInfoTable tbody tr").length > 1 ) {
			myForm.select(".approvalInfoTable .delete").show();
		}
	}
	//요청전 계획입력값 체크
	function fncValidatePlanSaveRequestInfo() {
		var dataProvider = planGrid.getDataProvider();
		var cgrid = planGrid.getGridBase();
		
		//행추가로 강제 생성된 행이기 때문에 행 상태는 created
		var rowIdxs = dataProvider.getRowCount();
		for ( var i=0; i<rowIdxs; i++ ) {
			var rowData = dataProvider.getJsonRow(i);
			//근태일자 없는 경우 오류
			if ( isNull(rowData["attendanceYyyymmdd"]) ) {
				Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.date'/>"/>');
				cgrid.setCurrent({itemIndex:cgrid.getItemIndex(i), column:'attendanceYyyymmdd'});
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
	//요청전 실적입력값 체크
	function fncValidateResultSaveRequestInfo() {
		var dataProvider = resultGrid.getDataProvider();
		var cgrid = resultGrid.getGridBase();
		
		//행추가로 강제 생성된 행이기 때문에 행 상태는 created
		var rowIdxs = dataProvider.getRowCount();
		for ( var i=0; i<rowIdxs; i++ ) {
			var rowData = dataProvider.getJsonRow(i);
			
			//근태일자 없는 경우 오류
			if ( isNull(rowData["attendanceYyyymmdd"]) ) {
				Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.date'/>"/>');
				cgrid.setCurrent({itemIndex:cgrid.getItemIndex(i), column:'attendanceYyyymmdd'});
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
	/* Save as Draft */
	function fncSaveRequestInfo(){
		try {
			planGrid.getGridBase().commit();
			resultGrid.getGridBase().commit();
		} catch(e) {
			Message.alert(e.message);
			return;
		}
		
		// 데이터 유무 체크
		if( planGrid.getRowCount() == 0 && resultGrid.getRowCount() == 0 ) {
			Message.alert('<lgcom:message code="note.nodata"/>');
			return;
		};
		
		//실적/계획 입력값 체크
		if ( !fncValidateResultSaveRequestInfo() || !fncValidatePlanSaveRequestInfo() ) {
			return ;
		}
		
		//결재자 체크
		if( myForm.select(".approvalInfoTable tr.ARM_Y").length == 0 ) {
			Message.alert("<lgcom:message code="note.checkApprovalInformation"/>");
			return;
		}
		
		//결재요청 가능시간인지 체크
		myForm.transaction_sync("lgvhr", "lgvatt/LGVATT20011/retrieveBaseInfo", {}, function(data) {
			if ( data.result ) {
				if ( nvl(data.result.inputEnableTimeFlag) != "Y" ) {//입력불가
					Message.alert("<lgcom:message code="note.att.dailyAttendanceInputTime" arguments='"+data.result["inputEndTime"]+"'/>");
					myForm.hideProgress();
					return ;
					
				} else {//입력가능
					Message.confirm( "<lgcom:message code="question.att.requestSubmit" />" , function() {
						/* 복수 레코드 정리 */
						try{
							var planArr = fncArrangeMultiLineGridAll(planGrid);//모든 계획근태 승인요청함.
							var resultArr = fncArrangeMultiLineGridAll(resultGrid);//모든 실적근태 승인요청함.
							var approvalArr = fncArrangeMultiLine( approvalInfoFormUtil.getValue(), "applicationUserId");
						} catch( e ) {
							trace( e );
						}
						
						if ( planArr.length == 0 && resultArr.length == 0 ) {
							Message.alert('<lgcom:message code="note.nodata"/>');
							return ;
						}

						if ( approvalArr.length == 0 ) {
							Message.alert("<lgcom:message code="note.checkApprovalInformation"/>");
							return ;
						}
						
						//최종 저장소에 데이터 보내기
						var param = {};
						var master = {};
						master = $.extend(master, requestInfoFormUtil.getValue());
						master = $.extend(master, { isPicUser : '<c:out value="${flg_vn_line_worker_pic_user}"/>' });
						//단일레코드의 항목들을 모두 master 로 모아서 저장한다.
						param["master"] = master;
						
						//멀티 레코드의 항목들을 각각 저장한다.
						param["planList"] = planArr;
						param["resultList"] = resultArr;
						param["approval"] = approvalArr;
						
						myForm.showProgress();
						myForm.transaction("lgvhr", "lgvatt/LGVATT20011/insertDailyAttendanceApprovalRequest", param, function( data ){
							Message.alert( "<lgcom:message code="note.completed" />" );
							requestInfoFormUtil.clear();
							
							//Approval 영역의 초기상태를 두고, 모두 지운다.
							myForm.select(".approvalInfoTable tbody tr").remove();
							approvalInfoFormUtil.clear();
							
							//창닫기
							Popup.closePopup(myForm,true);
						});<%-- //결재요청 정보 저장 --%>
					});<%-- //Message.confirm --%>
				}
			}
		});<%-- //결재요청 가능시간인지 체크 --%>
	}
	
	//화면에 필요한 기본정보 조회
	function fncRetrieveInitData() {
		myForm.transaction("lgvhr", "lgvatt/LGVATT20011/retrieveInitData", requestInfoFormUtil.getValue(), function( data ) {
			if ( data.result ) {
				myForm.hideProgress();
				var baseInfo = data.result.baseInfo;
				var reqDocBaseInfo = data.result.reqDocBaseInfo;
				var employeeData = data.result.employeeData;
				var planList = data.result.planList;
				var resultList = data.result.resultList;
				
				//화면 수정 불가능여부
				var planEditFlag   = (planList.findIndex(function ( item ) { return item.inputEnableFlag == 'N'} ) == -1)?true:false
				  , resultEditFlag = (resultList.findIndex(function ( item ) { return item.inputEnableFlag == 'N'} ) == -1)?true:false;
				<%-- 화면 수정 가능여부 셋팅
				     - 조건 : 입력 불가능한 계획일자가 없고, 입력 불가능한 실적일자가 없고, 일근태 입력 가능시간이고, 본인화면이고, 사무직이고, FSE 아니고, 단기파견자 아닌 경우만 수정 가능) 
				--%>
				gridEditFlag = (planEditFlag && resultEditFlag && (baseInfo.inputEnableTimeFlag == "Y") 
									&& ( (nvl(requestInfoFormUtil.getValue("employeeNo")) == "${sessionScope.LGVHR_PROJECT_SESSION.employeeNo}") || isPicUser )
									&& nvl(employeeData.employmentCategoryCode) == "LGD_OW"
									&& nvl(employeeData.fseYn) == "N"
									&& nvl(employeeData.flsaYn) == "N" );
				
				for(var i=0; i<resultList.length; i++) {
					if( gridEditFlag && resultList[i].inTimeRedFlag == "Y" && resultList[i].attendanceCode == "NW" ) {
						resultList[i].timeAttendDetailCode = "NW_LTN";
					}
				}

				//폼에 요청서코드 셋팅
				requestInfoFormUtil.setValue({ requestCode:reqDocBaseInfo.requestCode, armNo:reqDocBaseInfo.armNo });
				
				//계획근태 리스트 셋팅
				planGrid.setData(planList);
				//실적근태 리스트 셋팅
				resultGrid.setData(resultList);
				//휴일인 경우 출근시간 수정가능하도록 처리
				fncChnageCellStyle();

				for(var i=0; i<resultList.length; i++) {
					
					if( gridEditFlag && resultList[i].attendDays == 0 ) {
						resultGrid.getGridBase().setCellStyles(i, controlColumns.deductionColumn, "unableEdit");
					} else {
						resultGrid.getGridBase().setCellStyles(i, controlColumns.deductionColumn, "enableEdit");
					}
					
				}
				//trace("gridEditFlag("+gridEditFlag+"), planEditFlag("+planEditFlag+"), resultEditFlag("+resultEditFlag+"), baseInfo.inputEnableTimeFlag("+baseInfo.inputEnableTimeFlag+")");
				//화면 모드에 따라 처리
				fncChangeLayout(baseInfo);
			}
		});
	}
	//화면유형에 따라 레이아웃 조정
	function fncChangeLayout( baseInfo ) {
		//그리드 수정 가능한 상태인 경우 요청가능한 상태로 봄
		if ( gridEditFlag ) {
			//결재자영역 보여주는 경우 재량권에서 조회함.
			//재량권 조회
			fncRetrieveARMInfo();
			
			mode = "EDIT";

			//화면 버튼 처리
			myForm.select(".controls button[data-action='request']").show();
			
			//결재자영역 처리
			myForm.select(".approvalArea").show();
			
		} else {//그리드 수정 불가능한 상태인 경우 조회만 가능한 상태로 봄
			mode = "VIEW";

			//화면 버튼 처리
			myForm.select(".controls button[data-action='request']").hide();
			
			// 그리드 수정불가 모드로 전환
			planGrid.getGridBase().setEditOptions({readOnly: true});//비활성화 시킴
			resultGrid.getGridBase().setEditOptions({readOnly: true});//비활성화 시킴
			
			//결재자영역 처리
			myForm.select(".approvalArea").hide();
			
		    // 화면 레이아웃 정의(조회인 경우 결재요청 버튼영역과 결재자 영역이 보이지 않으므로, 계획, 실적 그리드 위치 이동)
			myForm.setLayout([
				{ name : "resultBlock",        left : 0, right : 0, top : 0, height : 270 },
				{ name : "planBlock",          left : 0, right : 0, top : "resultBlock", height : 270 }
			]);
			
			//결재자 영역을 숨기기 때문에 화면 높이를 조정한다.
			myForm.select(".controls").parents("._div_popup_holder_").css({"width": nvl(dailyAttendancePopup["popupWidth"], "1570")+"px", "height":"650px"});
		}
	}
	//수정가능여부에 따라 컬럼 수정 불가 설정
	function fncChnageCellStyle() {
		var pgrid     = planGrid.getGridBase();
		var pProvider = planGrid.getDataProvider();
		var rgrid     = resultGrid.getGridBase();
		var rProvider = resultGrid.getDataProvider();
		
		pgrid.addCellStyle("readOnlyStyle", {editable:false, background:"#e9e9e9"}, true);
		pgrid.addCellStyle("editableStyle", {editable:true, background:"#FFFFFF"}, true);
		for ( var i=0; i < pProvider.getRowCount(); i++ ) {
			pgrid.setCellStyle(i, "attendanceType", (pProvider.getValue(i, "updateEnableFlag") == "Y")?"editableStyle":"readOnlyStyle", true);
			pgrid.setCellStyle(i, "attendanceCode", (pProvider.getValue(i, "updateEnableFlag") == "Y")?"editableStyle":"readOnlyStyle", true);
		}

		//휴일인 경우 실적의 출근시간 수정 가능하도록 설정 변경
		rgrid.addCellStyle("readOnlyStyle", {editable:false, background:"#e9e9e9"}, true);
		rgrid.addCellStyle("editableStyle", {editable:true, background:"#FFFFFF"}, true);
		for ( var i=0; i < rProvider.getRowCount(); i++ ) {
			rgrid.setCellStyle(i, "attendanceType", (rProvider.getValue(i, "updateEnableFlag") == "Y")?"editableStyle":"readOnlyStyle", true);
			rgrid.setCellStyle(i, "attendanceCode", (rProvider.getValue(i, "updateEnableFlag") == "Y")?"editableStyle":"readOnlyStyle", true);
		}
	}
	//화면 로딩 시 레이아웃 설정
	function fncInitLayout() {
		//화면 버튼 처리
		myForm.select(".controls button[data-action='request']").hide();
		//결재자영역 처리
		myForm.select(".approvalArea").hide();
	}
}

LGVATT20011.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVATT20011();
		form.init();		
	});
});
</script>
</head>

<body>
<div class="mdi-container">
	<section class="page-content">
		<%-- 버튼 --%>
		<div class="controls module-group text-right">
	        <div class="btn-toolbar">
	            <div class="btn-group">
					<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="request" ><lgcom:message code="button.att.submitRequest"/></button>
	            </div>
	        </div>
		</div>
		<form class="form requestInfo">
			<input type="hidden" name="saveMode" value="INSERT" />
			<input type="hidden" name="requestDocCode" value="" />
			<input type="hidden" name="requestCode" />
			<input type="hidden" name="armNo" />
			<input type="hidden" name="employeeNo" />
			<input type="hidden" name="attendanceYyyymmdd" />
		</form>
		<%-- 실적 그리드 --%>
		<div class="resultBlock grid-wrap">
			<div class="sub-header resultSubTitle">
				<h3><lgcom:message code="label.att.actual"/></h3>
			</div>
			<div class="grid resultGrid"></div>
		</div>
		<%-- 계획 그리드 --%>
		<div class="planBlock grid-wrap">
			<div class="sub-header planSubTitle">
				<h3><lgcom:message code="label.att.plan"/></h3>
			</div>
			<div class="grid planGrid"></div>
		</div>
		<div class="approvalArea">
			<%-- 결재자 Sub Title 및 버튼 --%>
			<div class="module-group clearfix" >
				<div class="pull-left sub-header">
					<h3><lgcom:message code="ApprovalInformation"/></h3>
				</div>
				<div class="pull-right" style="display:none;">
					<button type="button" class="btn btn-default btn-sm ico-lgd" data-action="resetRows" data-target="approvalInfoTable" ><lgcom:message code="Reset1"/></button>
					<button type="button" class="btn btn-default btn-sm ico-lgd" data-action="insertRowTop"  data-target="approvalInfoTable"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="AddRowAtFirst1"/></button>
				</div>
			</div>
			<%-- 결재자 --%>
			<div class=" _approval_area_" >
				<form class="form approvalInfo" >
					<table class="approvalInfoTable table table-bordered table-condensed">
						<colgroup>
							<col width="50" />
							<col width="150" />
							<col width="*" />
							<col width="400" />
							<%--col width="*" /--%>
						</colgroup>
						<thead>
							<tr>
								<th><lgcom:message code="ApprovalSeq"/></th>
								<th><lgcom:message code="label.att.approvalType"/></th>
								<th><lgcom:message code="label.att.approver"/></th>
								<th><lgcom:message code="label.att.mandator"/></th>
								<%--th></th--%>
							</tr>
						</thead>
						<tbody></tbody>
					</table>
				</form>
			</div>
		</div>
		<div class="guideline_Viet">
			<table class="table table-bordered table-condensed">
				<colgroup>
					<col width="200" />
					<col width="300" />
					<col width="*" />
				</colgroup>
				<thead>
					<tr>
						<th>TT.</th>
						<th>Loại hình</th>
						<th>Hướng dẫn T&A</th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<td rowspan="8">Hàng<br>tuần</td>
						<td>Thời gian bắt<br>đầu và kết thúc</td>
						<td>
							<div>
								<table class="table table-bordered table-condensed">
									<colgroup>
										<col width="100" />
										<col width="100" />
										<col width="100" />
										<col width="100" />
									</colgroup>
									<thead>
										<tr>
											<th rowspan="2">Phân loại</th>
											<th rowspan="2">1 ca</th>
											<th colspan="2">2 ca/</th>
										</tr>
										<tr>
											<th>Ca ngày</th>
											<th>Ca đêm</th>
										</tr>
									</thead>
									<tbody>
										<tr>
											<td>Bắt đầu</td>
											<td>08:00</td>
											<td>08:00</td>
											<td>20:00</td>
										</tr>
										<tr>
											<td>Kết thúc</td>
											<td>17:00</td>
											<td>20:00</td>
											<td>08:00<br>ngày hôm sau</td>
										</tr>
									</tbody>
								</table>
							</div>
						</td>
					</tr>
					<tr>
						<td>Làm thêm giờ</td>
						<td>
							Công ty có thể yêu cầu nhân viên làm thêm trong trường hợp cần thiết tuân thủ tích cực yêu cầu của công ty, Nhân viên được yêu cầu làm thêm giờ phải lập trước kế hoạch làm việc, xin phê duyệt của trưởng phòng, việc làm thêm giờ phải được sự đồng ý của nhân viên.<br>
							Việc làm thêm giờ được tiến hành theo đơn vị 30 phút.
						</td>
					</tr>
					<tr>
						<td>Ca đêm</td>
						<td>
							Được tính từ 22 giờ đến 06:00 ngày hôm sau.
						</td>
					</tr>
					<tr>
						<td>Vắng mặt</td>
						<td>
							Trường hợp nghỉ làm bởi một số lý do không thể tránh được như bị ốm hoặc các lý do khách quan khác, phải được trưởng bộ phận phê duyệt trước khi bắt đầu thời gian làm việc<br>
							Trường hợp không thể nhận phê duyệt trước của trưởng bộ phận, cần báo cáo trước qua điện thoại, sau đó phải nhanh chóng xin phê duyệt, nếu không sẽ được coi là nghỉ việc không có lý do chính đáng<br>
							Ảnh hưởng của việc nghỉ làm<br>
							- Không trả lương cho ngày đó<br>
							- Có thể ảnh hưởng đến phép năm và lương.<br>
							- Trường hợp nghỉ việc không có lý do chính đáng sẽ bị xử lý kỷ<br>
							  luật.
						</td>
					</tr>
					<tr>
						<td>Đi muộn</td>
						<td>
							Đi muộn là việc có mặt tại nơi làm việc trong vòng 5 phút trước khi bắt đầu thời gian làm việc đến 1 tiếng sau thời gian bắt đầu làm việc sẽ được coi là đi muộn.<br>
							- Có thể yêu cầu nhân viên đi muộn về nhà nếu việc đi muộn gây ảnh hưởng đến công việc.<br>
							- Trường hợp đi muộn quá 1 tiếng kể từ thời gian bắt đầu làm việc sẽ được yêu cầu quay về nhà, trường hợp bắt buộc phải <br>
							  làm việc sẽ được coi là đi muộn và cứ mỗi 30 phút sẽ bị giảm đi mức lương tương ứng<br>
							Trường hợp đi muộn nhiều lần, bị nhắc nhở nhưng không sửa chữa sẽ bị kỷ luật.
						</td>
					</tr>
					<tr>
						<td>Về sớm</td>
						<td>
							Có thể về sớm sau khi được trưởng bộ phận phê duyệt trong trường hợp có lý do bất khả kháng như bị ốm hoặc các lý do<br>
							khách quan khác<br>
							Tính từ thời gian về sớm đến thời gian kết thúc ngày làm việc, cứ mỗi 30 phút sẽ bị giảm đi mức lương tương ứng
						</td>
					</tr>
					<tr>
						<td>Ra ngoài việc riêng</td>
						<td>
							Có thể ra ngoài sau khi được trưởng bộ phận phê duyệt trong trường hợp có lý do bất khả kháng như bị ốm hoặc các lý do<br>
							khách quan khác<br>
							Ra ngoài do công việc<br>
							- Là trường hợp ra ngoài với mục đích thực hiện công việc của công ty<br>
							- Trường hợp không thể quay lại công ty bởi lý do bất khả kháng cần sự phê duyệt của trưởng bộ phận.<br>
							Ra ngoài do lý do cá nhân<br>
							- Là trường hợp ra ngoài với mục đích thực hiện công việc cá nhân<br>
							- Theo nguyên tắc là bắt buộc phải quay trở lại công ty<br>
							- Thời gian ra ngoài tối đa là 3 tiếng/1 ngày kể cả thời gian ăn trưa<br>
							- Cứ mỗi 30 phút ra ngoài sẽ bị giảm đi mức lương tương ưng không tính thời gian ăn trưa<br>  
							  → Ra ngoài việc riêng trong thời gian làm thêm thì không được phép.
						</td>
					</tr>
					<tr>
						<td>Nghỉ</td>
						<td>
							Việc xin nghỉ phải được lãnh đạo phê duyệt trước khi nghỉ.<br>
							- Trong trường hợp nghỉ mà chưa được phê duyệt trước vì các lý do hợp lý và lý do khẩn cấp của cá nhân thì cần phải phê<br>
							  duyệt lại của lãnh đạo sau đó.<br>
						</td>
					</tr>
				</tbody>
			</table>
		</div>
		<div class="guideline_Eng">
			<table class="table table-bordered table-condensed">
				<colgroup>
					<col width="200" />
					<col width="300" />
					<col width="*" />
				</colgroup>
				<thead>
					<tr>
						<th>Cate.</th>
						<th>Attendance Code</th>
						<th>T&A Guideline</th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<td rowspan="8">Weekday</td>
						<td>Opening & Closing Time</td>
						<td>
							<div>
								<table class="table table-bordered table-condensed">
									<colgroup>
										<col width="100" />
										<col width="100" />
										<col width="100" />
										<col width="100" />
									</colgroup>
									<thead>
										<tr>
											<th rowspan="2">Category</th>
											<th rowspan="2">1-shift Worker</th>
											<th colspan="2">2-shift Worker</th>
										</tr>
										<tr>
											<th>Day Shift</th>
											<th>Night Shift</th>
										</tr>
									</thead>
									<tbody>
										<tr>
											<td>Opening Time</td>
											<td>08:00</td>
											<td>08:00</td>
											<td>20:00</td>
										</tr>
										<tr>
											<td>Closing Time</td>
											<td>17:00</td>
											<td>20:00</td>
											<td>08:00<br>on the next day</td>
										</tr>
									</tbody>
								</table>
							</div>
						</td>
					</tr>
					<tr>
						<td>Overtime Work</td>
						<td>
							The company could order overtime work, if necessary, to meet requirements for business and employee shall follow orders positively, the employee having orders to work overtime shall work after making plan for work and getting approval from the leader in advance<br>
							- work overtime based on agreement with the employee<br>
							Overtime work shall be done by every 30-minute.
						</td>
					</tr>
					<tr>
						<td>Night Work</td>
						<td>
							Counted from 22:00 to 06:00 on the next day.
						</td>
					</tr>
					<tr>
						<td>Absence</td>
						<td>
							Getting approval from the leader in advance before opening time in case of absence caused by sickness or other reasonable and inevitable reasons<br>
							In case the employee couldn’t get approval in advance because of inevitable reasons, reporting in advance by phone and getting retroactive approval without delay. If not, considered as absence without permission<br>
							Influence of absence<br>
							- Without payment for the day of absence<br>
							- Possible to have an influence on annual leave, salary, etc.<br>
							- Possible to be submitted to disciplinary punishment in case of absence<br>
							  without permission.
						</td>
					</tr>
					<tr>
						<td>Lateness</td>
						<td>
							Regarded as lateness in case of coming to work between 5 minutes before and 1 hour after opening time<br>
							- Order to return home if anything in work intervenes because of lateness.<br>
							- Being a principle to order to return home in case of coming to work after 1 hour from opening time. If work inevitably,<br>
							regarded as lateness and deducting hourly salary cut off by every 30-minute from the actual hours  of lateness.<br>
							Possible to be submitted to disciplinary punishment in case of frequent<br>
							lateness or not being corrected after warning.
						</td>
					</tr>
					<tr>
						<td>Leaving-early</td>
						<td>
							Possible to leave the company early with approval from the leader in case of sickness or other reasonable and inevitable reasons.<br>
							Deducting hourly salary cut off by every 30-minute from the actual time  to leave early to closing time.
						</td>
					</tr>
					<tr>
						<td>Going-out</td>
						<td>
							Possible to go out the company with approval from the leader in case of sickness or other reasonable and inevitable reasons.<br>
							Going-out for business<br>
							- Means Going-out for the purpose of performing jobs of the company<br>
							- Getting approval from the leader in case of not coming back to the<br>         
							  company because of inevitable reasons<br>
							Going-out for personal reasons<br>
							- Going-out for the purpose of personal things to do<br>
							- Being a principle to come back to the company without fail<br>
							- Within 3 hours per day including mealtime<br>
							- Deducting hourly salary cut off by every 30-minute to the time for<br>  
							  going-out excluding mealtime.<br>
							  → Going-out for private issues in case of overtime work shall not be<br>  
							    accepted.
						</td>
					</tr>
					<tr>
						<td>Leave</td>
						<td>
							Take leave with approval from the leader in advance<br>
							- In case the employee takes leave without approval in advance because<br>
							  of reasonable and urgent personal reasons, getting retroactive approval<br>
							  from the leader.
						</td>
					</tr>
				</tbody>
			</table>
		</div>
	</section>
</div>
</body>
</html>