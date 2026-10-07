<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVATT20020.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 임직원이 사무직 일근태 실적에 대해 수정요청하는 화면입니다.
            결재 시 본화면의 내용을 동일하게 사용한다.
    작성자 : 임수진
    HMT_20210410     Add month ot total with month ot limit
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title><lgcom:message code="label.att.requestAttendanceModification"/></title>
<script src="/lgvhr/static/js/lgvatt.js"></script>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVATT20020 = function() {
	var myForm = this;
	var requestInfoForm = new FormUtil(myForm, ".requestInfo");
	var requestorForm = new FormUtil(myForm, "._requestHeadForm_");
	var approverForm = new FormUtil(myForm, "._approverForm_");
	var mode = "VIEW";
	var approvalCallFlag = nvl("<c:out value="${urlAddr.approval}"/>", "N");
	/* 팝업용 변수 선언 */
	myForm.popupInfo = {
		userPopup: {},		// 결재자
		userMultiPopup: {}	// 참조자
	};

	var requestMasterId = '<c:out value="${urlAddr.requestMasterId}"/>';
	var requestCode = '<c:out value="${urlAddr.requestCode}"/>';

	requestorForm.setValue({'requestMasterId':requestMasterId,'requestCode':requestCode});

	// 화면 레이아웃 정의(결재선 셋팅 후 화면 레이아웃 확정되기 때문에 마지막에 셋팅한다.)
	myForm.setLayout([
		{ name : "controls",      left : 0, right : 0, top : 0  },
		{ name : "requestorInfo", left : 0, right : 0, top : "controls", height : 100 },
		{ name : "gridContent",   left : 0, right : 0, top : "requestorInfo", height : 420 },
		{ name : "approvalArea",  left : 0, right : 0, top : "gridContent", bottom : 0 }
	]);
	
    // 코드 데이터 조회(그리드 콤보 셋팅하기 위해 사용함.)
	// combo 목록 조회
	var code = new CommonCode("lgcom");
	code.add( "LGVHR_DAY_NIGHT_FLAG", {codeTypeCode:'LGVHR_DAY_NIGHT_FLAG'} );
	code.add( "LGCOM_YN_FLAG",        {codeTypeCode:'LGCOM_YN_FLAG'} );
	code.execute();
	
	//근태유형, 근태코드 조회
	var valueset = new ValueSet("lgcom");
	valueset.add( "attendanceTypeList", {valueSetId:'LGVATT_ATTEND_TYPE_UPDATE_ENABLE', subsidiaryCode :"${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}", languageCode:SESSION_USER.languageCode} );
	valueset.add( "attendanceCodeList", {valueSetId : "LGVATT_ATTEND_DETAIL", attendTypeName :"", subsidiaryCode :"${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}", languageCode:SESSION_USER.languageCode} );
	valueset.add( "attendanceDetailCodeList", {valueSetId : "LGVATT_ATTEND_DETAIL_CODE", subsidiaryCode :"${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}", languageCode:SESSION_USER.languageCode} );//근태코드에 따른 근태상세코드
	valueset.add( "attDays", 				  {valueSetId : "LGVATT_ATT_DAYS", subsidiaryCode :"${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}"} );
	valueset.execute();
	
	//출근시간리스트 조회(평일인 경우 8시, 20시만 선택가능하고, 휴일인 경우 모든시간 선택가능하도록 하기 위해 휴일여부Y,N인 출근시간을 모두 조회한다.)
	var workStartTimeList = {};
	myForm.transaction_sync("lgvhr", "lgvatt/LGVATTCOMM/retrieveWorkStartTimeList", {}, function(data) { 
		if ( data.result ) {
			workStartTimeList = data.result;
		}
	});

    // 그리드 초기화
    var grid = buildGrid(".modifyGrid");
    
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
    
    <%-- 결재화면 호출로직 추가 start --%>
	/* 통합결재 연동 관련 코드 */
	var approvalInfo = {
		init : function(param) {

			// 요청서 조회
			requestorForm.setValue({ requestMasterId:$.trim('<c:out value="${urlAddr.jobKeyId}"/>')
				                   , requestCode    :$.trim('<c:out value="${urlAddr.jobRequestCode}"/>')
				                   });
			fncRetrieveRequestContent();
		},
		buttons : [
			{text:'<lgcom:message code="RequestCancel"/>'        , action:'selfReject', type:'SELF_REJECT', visible:false},
			{text:'<lgcom:message code="Approval"/>'             , action:'approval'  , type:'APPROVAL'   },
			{text:'<lgcom:message code="Reject"/>'               , action:'reject'    , type:'REJECT'     },
			{text:'<lgcom:message code="Forward"/>'              , action:'forward'   , type:'FORWARD'    , visible:false},
			{text:'<lgcom:message code="Print"/>'                , action:'print'     , type:'PRINT'      , visible:false}
		],
		callback : function(action, param) {
			switch(action) {
				// 승인
				case 'approval':
					// 승인시 Comment 담기
					requestorForm.setValue({ approvalComment:$.trim(param.comment) });
					var returnValue = fnApprovalOrRejectRequest('approval');
					_approvalCallback(action, returnValue);  //승인 또는 반려 처리에 대한 결과 Callback 처리
					break;
				// 반려
				case 'reject':
					// 반려시 Comment 담기
					requestorForm.setValue({ approvalComment:$.trim(param.comment) });
					var returnValue = fnApprovalOrRejectRequest('reject');
					_approvalCallback(action, returnValue);  //승인 또는 반려 처리에 대한 결과 Callback 처리
					break;
				// 인쇄
				case 'print':
					var browser = navigator.userAgent.toLowerCase();
					if(browser.indexOf('chrome') != -1) {
						window.print();
					} else if (browser.indexOf('trident') != -1) {
						try {
							//웹 브라우저 컨트롤 생성
							var webBrowser = '<object id="previewWeb" width="0" height="0" classid="CLSID:8856F961-340A-11D0-A96B-00C04FD705A2"></object>';
							//웹 페이지에 객체 삽입
							document.body.insertAdjacentHTML('beforeEnd', webBrowser);
							//ExexWB 메쏘드 실행 (7 : 미리보기 , 8 : 페이지 설정 , 6 : 인쇄하기(대화상자))
							document.previewWeb.ExecWB(7,1);
							//객체 해제
							$('#previewWeb').remove();
						} catch(e) {
							Message.alert('<lgcom:message code="note.errorPrint"/>');
						}
					}
					break;
			}
		}
	};
	myForm.setApprovalInfo( approvalInfo );
    <%-- 결재화면 호출로직 추가 end --%>
    
    // 화면에 필요한 초기데이터 조회

    // 개인화조건
    
    // 조회조건 저장 처리
    myForm.searchConditionControl( true );
    
    // 팝업 데이터 정의 searchMode:single(단수),multi(복수)

    // 그리드형 테이블 TR

    // 날짜 팝업창
    
    // 필수항목 체크
    
    // 일반함수	
    
	/*** 이벤트 핸들러  ***/
	// 버튼제어
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		var cgrid = grid.getGridBase();
		var currentRow = cgrid.getCurrent().itemIndex;
		var provider = cgrid.getDataProvider();
		switch(action) {
			case 'add':
				try {
					cgrid.commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				//2줄씩 생성되므로, 무조건 첫번재 행부터 2줄씩 생기도록 고정함.
				//2줄 생성하기 위한 배열 값
				//attendanceYyyymmdd, weekName, screenWeekName, dataOldNewTypeCode, dataOldNewTypeName, 
				//attendanceType, attendanceCode, attendanceName, shiftTypeCode, shiftTypeName,
				//workStartTime, workStartTimeOri, inTime, outTime, nightShiftFlag, 
				//eveningMealFlag
		        var rows = [
		                    ["", "", "", "OLD", "Old"]
		                  , ["", "", "", "NEW", "New",   
		                     "", "", "", "", "",   
		                     "", "", "", "", "",  
		                     "" 
		                    ]
		                   ];
	    
				provider.insertRows(0, rows, 0, -1, true);
				//현재 행 위치를 지정해 주어야 rowChange event 에서 readonly 행에 대한 배경색 처리가 됨.
				cgrid.setCurrent({itemIndex: 0, column:'attendanceYyyymmdd'});
				cgrid.setFocus();
				cgrid.commit( true );
				
				break;
			case 'delete':
				try {
					cgrid.commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				//2줄씩 생성되므로, 삭제시 2줄 모두 지워야 함.
				var deleteRow = [];
				deleteRow.push(currentRow);
				if ( currentRow % 2 == 0 ) {//짝수 행인 경우 다음 행까지 삭제
					deleteRow.push(currentRow+1);
				} else {//홀수 행인 경우 이전 행까지 삭제
					deleteRow.push(currentRow-1);
				}
				
				provider.setOptions({softDeleting:false});//softDeleting:true인 경우 행삭제되지 않고, 행구분만 삭제로 변경되므로, 화면에서 행 삭제하기 위해 false로 변경함
				provider.removeRows(deleteRow, false);
				break;
			case 'request':
				// 결재요청
				fncSaveRequestInfo( true );
				break;
		}
	});
	/*** 내부 함수  ***/
	
	var controlColumns = {copyColumn  : ["attendanceYyyymmdd", "weekName", "screenWeekName", "shiftTypeCode", "shiftTypeName"
	                                  , "attendanceType", "attendanceCode", "timeAttendDetailCode", "eveningMealFlag", "monthTotalOvertime","overtimeLimit" //HMT_20210410
	                                  , "overtimeSumHours", "tardyHours", "earlyLeaveHours", "goingOutHours"
	                                  , "weekdayOvertimeHours", "holidayOvertimeHours", "publicHolidayOvertimeHours", "weekdayNightOvertimeHours"
	                                  , "weekdayOtAfNightWorkHours", "holidayNightOvertimeHours", "publicHolidayNightOtHours", "normalNightOvertimeHours"
	                                  , "workStartTime", "workStartTimeOri", "inTime", "outTime", "nightShiftFlag"
	                                  , "updateEnableFlag", "holidayFlag", "inTimeRedFlag", "attendDays"] /* 실적근태 조회 시 Old 값을 셋팅해야할 New 컬럼명 */
	                    , editColumn : ["attendanceType", "attendanceCode", "timeAttendDetailCode", "timeAttendInputReasonDesc", "eveningMealFlag"
	                                  , "workStartTime", "actualOtHours", "actualOtMinutes", "tardyHours", "earlyLeaveHours", "goingOutHours" //HMT_20260831
	                                  , "specialBonusHours", "helpcallSupportHours", "updateRequestReasonDesc"] /* 사용자가 입력 가능한 after 컬럼명 */
	                    , oldNewTypeColumn : ["dataOldNewTypeCode", "dataOldNewTypeName"] /* 신규,수정 구분 컬럼명 */
	                    , deductionColumn : [ "tardyHours", "earlyLeaveHours", "goingOutHours" ] /* 공제항목 컬럼 */
	                     };
    // 그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		var gridReadOnyBgColor = "#e9e9e9";
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
				fixed: { colCount: 12, resizable:true }
			},
			display: { fitStyle: 'none' }
		});
		
		//필드 설정
		grid.setFields(
				[
					{ fieldName:'attendanceYyyymmdd'        , dataType:'text'  },
					{ fieldName:'weekName'     	            , dataType:'text'  },
					{ fieldName:'screenWeekName'     	    , dataType:'text'  },
					{ fieldName:'dataOldNewTypeCode'  	    , dataType:'text'  },
					{ fieldName:'dataOldNewTypeName'  	    , dataType:'text'  },
					{ fieldName:'attendanceType'            , dataType:'text'  },
					{ fieldName:'attendanceCode'            , dataType:'text'  },
					{ fieldName:'attendanceName'            , dataType:'text'  },
					{ fieldName:'shiftTypeCode'             , dataType:'text'  },
					{ fieldName:'shiftTypeName'             , dataType:'text'  },
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
		            { fieldName:'timeAttendDetailCode'      , dataType:'text'  },
		            { fieldName:'timeAttendInputReasonDesc' , dataType:'text'  },
					{ fieldName:'updateRequestReasonDesc'   , dataType:'text'  },
					{ fieldName:'approvalRequestId'         , dataType:'text'  },
					{ fieldName:'progressStatusCode'        , dataType:'text'  },
					{ fieldName:'inputEnableFlag'           , dataType:'text'  },
		            { fieldName:'updateEnableFlag'          , dataType:'text'  },
		            { fieldName:'holidayFlag'               , dataType:'text'  },
		            { fieldName:'inTimeRedFlag'             , dataType:'text'  },
		            { fieldName:'outTimeRedFlag'            , dataType:'text'  },
		            { fieldName:'attendDays'            	, dataType:'number'}
				]
		);
		//컬럼 콤보 셋팅
		grid.setLookupsMultiLvl({"attendanceType":{data:valueset.get("attendanceTypeList"), keyField:['updateEnable', 'code']},
	                             "attendanceCode":{data:valueset.get("attendanceCodeList"), keyField:['updateEnable', 'attendTypeName','code']},
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
						width:130,
						header:{
					         text:'<lgcom:message code="label.att.date" />'
					    },
						orientation:'horizontal',
						hideChildHeaders: true,
						columns: [
									{	name:'attendanceYyyymmdd',
										fieldName:'attendanceYyyymmdd',
										width:70,
										type: 'data',
										header: {text:'<lgcom:message code="label.att.date"/>', visible:false},
										styles: {textAlignment:'center'},
										mergeRule: {criteria: "row div 2"},
										editor: {type:'date',datetimeFormat:'dd/MM/yyyy'}
									},
									{	name:'screenWeekName',
										fieldName:'screenWeekName',
										width:70,
										header: {text:'<lgcom:message code="label.att.dayOfWeek"/>', visible:false},
										styles: {textAlignment:'near'},
										mergeRule: {criteria: "row div 2"},
										editable: false
									}
								]
					},
					{	name:'inTime',
						fieldName:'inTime',
						width:40,
						header: {text:'<lgcom:message code="label.att.inTime"/>'},
						styles: {textAlignment:'center', background:gridReadOnyBgColor},
						mergeRule: {criteria: "row div 2"},
						editable:false,
						dynamicStyles:[{criteria:"values['inTimeRedFlag']='Y'", styles:{foreground:"#f34d78"}}]
					},
					{	name:'inTimeRedFlag',
						fieldName:'inTimeRedFlag',
						width:40,
						header: {text:'<lgcom:message code="label.att.inTime"/>'},
						styles: {textAlignment:'center', background:gridReadOnyBgColor},
						mergeRule: {criteria: "row div 2"},
						editable:false,
						visible: false
					},
					{	name:'outTime',
						fieldName:'outTime',
						width:40,
						header: {text:'<lgcom:message code="label.att.outTime"/>'},
						styles: {textAlignment:'center', background:gridReadOnyBgColor},
						mergeRule: {criteria: "row div 2"},
						editable:false,
						dynamicStyles:[{criteria:"values['outTimeRedFlag']='Y'", styles:{foreground:"#f34d78"}}]
					},
					{	name:'shiftTypeName',
						fieldName:'shiftTypeName',
						width:40,
						header: {text:'<lgcom:message code="label.att.shiftType"/>'},
						styles: {textAlignment:'center', background:gridReadOnyBgColor},
						mergeRule: {criteria: "row div 2"},
						editable: false
					},
					{	name:'nightShiftFlag',
						fieldName:'nightShiftFlag',
						width:40,
						header: {text:'<lgcom:message code="label.att.actualDayNight"/>'},
						styles: {textAlignment:'center', background:gridReadOnyBgColor},
						mergeRule: {criteria: "row div 2"},
						lookupDisplay: true,
						lookupSourceId: 'nightShiftFlag',
						lookupKeyFields: ['nightShiftFlag'],
						editor: {type:'dropDown',textReadOnly:true},
						editable : false,
						visible: false
					},
					{	name:'dataOldNewTypeName',
						fieldName:'dataOldNewTypeName',
						width:40,
						header: {text:'<lgcom:message code="label.att.oldNewTypeName"/>'},
						styles: {textAlignment:'center', background:gridReadOnyBgColor},
						editable: false
					},
					{	type:'group',
						name:'actualAttendance',
						fieldName:'actualAttendance',
						width:300,
						header:{
					         text:'<lgcom:message code="label.att.actualAttendance" />', fixedHeight:30
					    },
						orientation:'horizontal',
						columns: [
									{	name:'attendanceType',
										fieldName:'attendanceType',
										width:70,
										header: {text:'<lgcom:message code="label.att.actualAttendanceType"/>'},
										styles: {textAlignment:'near'},
									    renderer: {showTooltip: true},
										lookupDisplay: true,
										lookupSourceId: 'attendanceType',
										lookupKeyFields: ['updateEnableFlag','attendanceType'],
										editor: {type:'dropDown',textReadOnly:true},
										editable : false
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
										editable : false
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
										editable : false
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
						editable: false
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
										editable: false
									},
									{	name:'earlyLeaveHours',
										fieldName:'earlyLeaveHours',
										width:55,
										header: {text:'<lgcom:message code="label.att.deductionLeavingEarly"/>'},
										styles: {textAlignment:'far', numberFormat: '#0.0'},
										editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
										editable: false
									},
									{	name:'goingOutHours',
										fieldName:'goingOutHours',
										width:55,
										header: {text:'<lgcom:message code="label.att.deductionGoingOut"/>'},
										styles: {textAlignment:'far', numberFormat: '#0.0'},
										editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
										editable: false
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
										editable: false
									},
									{	name:'actualOtMinutes',
										fieldName:'actualOtMinutes',
										width:45,
										header: {text:'<lgcom:message code="label.pay.minutes"/>'},
										styles: {textAlignment:'far', numberFormat: '#0.0'},
										editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
										editable: false
									},
									{	name:'overtimeSumHours',
										fieldName:'overtimeSumHours',
										width:40,
										header: {text:'<lgcom:message code="label.att.totalOT"/>'},
										styles: {textAlignment:'far', background: gridReadOnyBgColor, numberFormat: '#0.0'},
										editable: false
									}
								]
					},
					//HMT_20260831 End
					{	name:'timeAttendInputReasonDesc',
						fieldName:'timeAttendInputReasonDesc',
						width:120,
						header: {text:'<lgcom:message code="label.att.timeAttendInputReasonDesc"/>'},
						styles: {textAlignment:'near'},
					    renderer: {showTooltip: true},
						editable: false
					},
					//HMT_20210410 Start
					{	name:'monthTotalOvertime',
						fieldName:'monthTotalOvertime',
						width:40,
						header: {text:'<lgcom:message code="label.att.monthTotalOT"/>'},
						styles: {textAlignment:'far', numberFormat: '#0.0'},
						editable: false
					},
					{	name:'overtimeLimit',
						fieldName:'overtimeLimit',
						width:40,
						header: {text:'<lgcom:message code="label.att.monthOtLimit"/>'},
						styles: {textAlignment:'far', numberFormat: '#0.0'},
						editable: false
					},
					//HMT_20210410 End
					{	name:'eveningMealFlag',
						fieldName:'eveningMealFlag',
						width:50,
						header: {text:'<lgcom:message code="label.att.actualDinnerChk"/>'},
						styles: {textAlignment:'center'},
						lookupDisplay: true,
						lookupSourceId: 'eveningMealFlag',
						lookupKeyFields: ['eveningMealFlag'],
						editor: {type:'dropDown',textReadOnly:true},
						editable: false
					},
					{	name:'updateRequestReasonDesc',
						fieldName:'updateRequestReasonDesc',
						width:160,
						header: {text:'<lgcom:message code="label.att.modificationReason"/>'},
						styles: {textAlignment:'near'},
					    renderer: {showTooltip: true},
					    editor: {maxLength: 1000},
						editable: false
					},
					{	type:'group',
						name:'night',
						fieldName:'night',
						width:50,
						header:{
					         text:'<lgcom:message code="label.att.night" />', fixedHeight:30
					    },
						orientation:'horizontal',
						columns: [
									{	name:'normalNightOvertimeHours',
										fieldName:'normalNightOvertimeHours',
										width:50,
										header: {text:'<lgcom:message code="label.att.nightNormal2"/>', tooltip:'<lgcom:message code="label.att.nightNormal"/>'},
										styles: {textAlignment:'far', numberFormat: '#0.0', background:gridReadOnyBgColor},
										editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
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
										styles: {textAlignment:'far', numberFormat: '#0.0', background:gridReadOnyBgColor},
										editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
										editable:false
									},
									{	name:'holidayOvertimeHours',
										fieldName:'holidayOvertimeHours',
										width:50,
										header: {text:'<lgcom:message code="label.att.actualOTWeekDayHoliday2" />', tooltip:'<lgcom:message code="label.att.actualOTWeekDayHoliday"/>'},
										styles: {textAlignment:'far', numberFormat: '#0.0', background:gridReadOnyBgColor},
										editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
										editable:false
									},
									{	name:'publicHolidayOvertimeHours',
										fieldName:'publicHolidayOvertimeHours',
										width:50,
										header: {text:'<lgcom:message code="label.att.actualOTPublicHoliday2" />', tooltip:'<lgcom:message code="label.att.actualOTPublicHoliday"/>'},
										styles: {textAlignment:'far', numberFormat: '#0.0', background:gridReadOnyBgColor},
										editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
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
										styles: {textAlignment:'far', numberFormat: '#0.0', background:gridReadOnyBgColor},
										editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
										editable:false
									},
									{	name:'weekdayOtAfNightWorkHours',
										fieldName:'weekdayOtAfNightWorkHours',
										width:50,
										header: {text:'<lgcom:message code="label.att.actualOTNightWeekDayAfterOT2" />', tooltip:'<lgcom:message code="label.att.actualOTNightWeekDayAfterOT"/>'},
										styles: {textAlignment:'far', numberFormat: '#0.0', background:gridReadOnyBgColor},
										editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
										editable:false
									},
									{	name:'holidayNightOvertimeHours',
										fieldName:'holidayNightOvertimeHours',
										width:50,
										header: {text:'<lgcom:message code="label.att.actualOTNightWeekDayHoliday2" />', tooltip:'<lgcom:message code="label.att.actualOTNightWeekDayHoliday"/>'},
										styles: {textAlignment:'far', numberFormat: '#0.0', background:gridReadOnyBgColor},
										editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
										editable:false
									},
									{	name:'publicHolidayNightOtHours',
										fieldName:'publicHolidayNightOtHours',
										width:50,
										header: {text:'<lgcom:message code="label.att.actualOTNightPublicHoliday2" />', tooltip:'<lgcom:message code="label.att.actualOTNightPublicHoliday"/>'},
										styles: {textAlignment:'far', numberFormat: '#0.0', background:gridReadOnyBgColor},
										editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
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
						editable: false,
						visible: false
					},
					{	name:'helpcallSupportHours',
						fieldName:'helpcallSupportHours',
						width:60,
						header: {text:'<lgcom:message code="label.att.helpCall"/>'},
						styles: {textAlignment:'far', numberFormat: '#0.0'},
						editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
						editable: false,
						visible: false
					},
					{	name:'attendDays', 
						fieldName:'attendDays', 
						width:40,  
						header: {text:'<lgcom:message code="attendDays" />', styles: {background: '#c8c8c8'}},
						editable: false, 
						visible: false,
						styles: {textAlignment:'near' }
					}
				]
		);
		// Context Menu Set
		grid.setContextMenu();
		//그리드 필수값 체크
		return grid;
	}
	grid.getGridBase().addCellStyle("readOnlyStyle", {editable:false, background:"#e9e9e9"}, true);/* 수정불가능한 경우 배경색을 구분해서 보여줘야 함 */
	grid.getGridBase().addCellStyle("editableStyle", {editable:true, background:"#FFFFFF"}, true);/* 사용자가 입력하는 경우 사용할 스타일. 수정 가능해야하고, 배경색도 수정 가능한 상태로 보여줘야 함 */
	grid.getGridBase().addCellStyle("apprEditableStyle", {editable:false, background:"#FFFFFF"}, true);/* 결재자 화면인 경우 사용할 스타일. 수정은 불가능해야하지만 배경색은 수정 가능한 상태로 보여줘야 함 */
    //Old, New 별 셀 수정가능여부 셋팅
	grid.getGridBase().onCurrentRowChanged = function (cgrid, oldRow, newRow) {
		<%--[PARAMETER]
		    - cgrid : grid.getGridBase()
		    - oldRow : 변경 전 데이터행의 dataRow
		    - newRow : 변경 후 데이터행의 dataRow
		    
		    *dataRow : 최초 조회한 데이터셋의 row index
		--%>
		var provider = cgrid.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';
		var fieldNames = provider.getOrgFieldNames();
		var dataRow = newRow;

		if ( editable && dataRow > -1 && dataRow < provider.getRowCount() ) {
			//행별 수정가능 컬럼 여부 판별
			fncSetEditableControl(cgrid, provider, dataRow, "Y");
		}
	};
	//날짜 셀 클릭 시 수정 가능여부를 판단한다.
	grid.getGridBase().onDataCellClicked =  function (cgrid, index) {
		<%--[PARAMETER]
		    - cgrid : grid.getGridBase()
		    - index : 클릭된 데이터 셀의 인덱스.
		              - index.itemIndex : 그리드의 row index
		              - index.dataRow : 조회한 데이터셋의 row index
		--%>
		var currentRow = index.dataRow;
		if ( index.fieldName == "attendanceYyyymmdd" ) {//근태일자 셀인 경우 짝수행이면 수정가능, 홀수행이면 수정불가능
			<%-- 스타일 변경시 dataRow 사용해야함 --%>
			cgrid.setCellStyle(currentRow, index.fieldName, (currentRow%2==0)?"editableStyle":"readOnlyStyle", true);
		}
	};
	//날짜 선택 cell 이동하지 않아도 변경 값 적용되도록 강제 commit 처리 함.
	grid.getGridBase().onEditChange =  function (cgrid, index, value) {
		<%--[PARAMETER]
	    	- cgrid : grid.getGridBase()
	    	- index : 클릭된 데이터 셀의 인덱스.
	                  - index.itemIndex : 그리드의 row index
	                  - index.dataRow : 조회한 데이터셋의 row index
	        - value : 편집 중인 셀의 데이터 값
		--%>
	    if(index.fieldName == "attendanceYyyymmdd"){
	        try {
	        	cgrid.commit()
	        } catch(e) {
	            trace(e.message);
	        }
	    }
	};
    //근태유형에 따른 근태코드 셋팅
	grid.getGridBase().onEditCommit = function(cgrid, index, oldValue, newValue) {
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
							cgrid.setValue(index.itemIndex, 'attendDays', $.trim(attDaysLookup[i]['code']));
						} else {
							cgrid.setCellStyles(index.dataRow, controlColumns.deductionColumn, "enableEdit");
							cgrid.setValue(index.itemIndex, 'attendDays', $.trim(attDaysLookup[i]['code']));
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
				//Compare month ot total with month ot limit HMT_20210410
				//fncCompareOtTotal(cgrid, itemIndex);
			}
		} else if(index.column == 'attendanceCode') {
			var attDaysLookup = valueset.get('attDays');
			for(var i=0; i < attDaysLookup.length; i++) {
				if($.trim(attDaysLookup[i]['timeAndAttendanceCode']) == newValue) {
					if($.trim(attDaysLookup[i]['code']) == 0) {
						cgrid.setCellStyles(index.dataRow, controlColumns.deductionColumn, "unableEdit");
						cgrid.setValue(index.itemIndex, 'attendDays', $.trim(attDaysLookup[i]['code']));
					} else {
						cgrid.setCellStyles(index.dataRow, controlColumns.deductionColumn, "enableEdit");
						cgrid.setValue(index.itemIndex, 'attendDays', $.trim(attDaysLookup[i]['code']));
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
			//Compare month ot total with month ot limit HMT_20210410
			//fncCompareOtTotal(cgrid, itemIndex);
		}
	}
    //셀 수정시 후처리
    grid.getGridBase().onCellEdited = function (cgrid, itemIndex, dataRow, field) {
		<%--[PARAMETER]
	    	- cgrid : grid.getGridBase()
	    	- itemIndex : 편집중인 행 row index
	        - dataRow   : 편집중인 행 데이터 row index
	        - field : 편집된 필드 인덱스
		--%>
		cgrid.commit();
		var provider = cgrid.getDataProvider();
	    var fieldName = provider.getOrgFieldName(field);

	    //근태년월 선택된 경우 실적근태 조회
	    if ( fieldName == "attendanceYyyymmdd" ) {
	    	fncRetrieveResultData( cgrid, itemIndex, dataRow, fieldName );
	    	
	    //근태코드 변경 시 석식여부, OT 초기화
	    } else if ( fieldName == "attendanceCode" ) {
		  	fncResetRowData(cgrid, itemIndex);
			//OT계산
			fncCalculateOT(cgrid, itemIndex);
			//Compare month ot total with month ot limit HMT_20210410
			fncCompareOtTotal(cgrid, itemIndex);
		  	
	    //석식여부 변경시 OT시간이 있으면 재계산
	    } else if ( fieldName == "eveningMealFlag" ) {
			//OT계산
			fncCalculateOT(cgrid, itemIndex);
			//Compare month ot total with month ot limit HMT_20210410
			fncCompareOtTotal(cgrid, itemIndex);
			
		//출근시간 변경 시 OT 재계산
		} else if ( fieldName == "workStartTime" ) {
			//OT계산
			fncCalculateOT(cgrid, itemIndex);
			//Compare month ot total with month ot limit HMT_20210410
			fncCompareOtTotal(cgrid, itemIndex);
			
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
			//Compare month ot total with month ot limit HMT_20210410
			fncCompareOtTotal(cgrid, itemIndex);

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
			//Compare month ot total with month ot limit HMT_20210410
			fncCompareOtTotal(cgrid, itemIndex);

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
			//Compare month ot total with month ot limit HMT_20210410
			fncCompareOtTotal(cgrid, itemIndex);

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
			//Compare month ot total with month ot limit HMT_20210410
			fncCompareOtTotal(cgrid, itemIndex);
	    }
	}
	grid.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	}
	//특정행의 cell 별 수정가능여부 셋팅
	function fncSetEditableControl(cgrid, provider, rowData, editFlag) {
		<%-- [PARAMETER]
		     - cgrid : grid.getGridBase()
		     - provider : grid.getGridBase().getDataProvider()
		     - itemIndex : 데이터셋 row index(dataRow)
		     - editFlag
		       - Y : 수정 가능. 수정요청서 작성 시 수정 가능하도록 설정하기 위한 구분값
		       - N : 수정 불가능. 수정요청서 결재 시 수정가능 행이지만, 수정은 불가능하도록 설정하기 위한 구분값
		--%>
		var fieldNames = provider.getOrgFieldNames();
		var editableStyle = (nvl(editFlag, "N") == "Y")?"editableStyle":"apprEditableStyle";
		
		if ( rowData > -1 && rowData < provider.getRowCount() ) {
			for ( var i=0; i<fieldNames.length; i++ ) {
				<%-- Old 행인 경우 근태일자를 제외하고 모두 readOnly=true --%>
				if ( provider.getValue(rowData, "dataOldNewTypeCode") == "OLD" ) {
					cgrid.setCellStyle(rowData, fieldNames[i], (fieldNames[i] == "attendanceYyyymmdd")?editableStyle:"readOnlyStyle", true);
					
				<%-- After 행인 경우 근태일자를 제외하고 모두 editable --%>
				} else if ( provider.getValue(rowData, "dataOldNewTypeCode") == "NEW" ) {
					//근태코드 수정불가능 행인 경우 처리
					if ( nvl(provider.getValue(rowData, "updateEnableFlag"), "N") == "N" 
							&& (fieldNames[i] == "attendanceType" || fieldNames[i] == "attendanceCode") ) {
						cgrid.setCellStyle(rowData, fieldNames[i], "readOnlyStyle", true);
						
					// attendance_days = 0 인경우 readOnly
					} else if ( provider.getValue(rowData, "attendDays") == 0 &&
							(fieldNames[i] == "tardyHours" || fieldNames[i] == "earlyLeaveHours" || fieldNames[i] == "goingOutHours") ) {
						cgrid.setCellStyle(rowData, fieldNames[i], "readOnlyStyle");

					//그외 편집 가능한 컬림 여부에 따라 활성화 처리
					} else {
						if ( controlColumns.editColumn.indexOf( fieldNames[i] ) > -1 ) {
							cgrid.setCellStyle(rowData, fieldNames[i], editableStyle, true);
						} else {
							cgrid.setCellStyle(rowData, fieldNames[i], "readOnlyStyle", true);
						}
					}
				}
			}
		}
	}
	//근태일자의 실적근태 조회후 값 셋팅
	function fncRetrieveResultData( cgrid, itemIndex, dataRow, fieldName ) {
		<%-- [PARAMETER]
		     - cgrid : grid.getGridBase()
		     - itemIndex : 화면에 보이는 row index. (grid.getGridBase()에서 사용)
		     - dataRow : 최초 조회한 데이터셋의 row index(grid.getDataProvider()에서 사용)
		     - fieldName : 컬럼명
		--%>
		myForm.showProgress();
		var provider = cgrid.getDataProvider();
		var attendanceYyyymmdd = cgrid.getValue(itemIndex, fieldName);
        var rows = [];
		
		//근태일자 선택 시 Old/New 셋팅
		if ( !isNull($.trim(attendanceYyyymmdd)) ) {//입력한 근태일자가 있는 경우만 조회

			//같은 근태일자가 있는지 체크(OLD행 기준으로 체크)
			for ( var i=0; i<provider.getRowCount(); i++ ) {
				//선택된 날짜와 동일한 날짜를 선택하는 경우 오류
				if ( i != dataRow && provider.getValue(i, "dataOldNewTypeCode") == "OLD" && !isNull(provider.getValue(i, "attendanceYyyymmdd")) && attendanceYyyymmdd == provider.getValue(i, "attendanceYyyymmdd") ) {
    				//날짜 선택 시 Old, New 행 모두 초기화
    				fncClearGridRow(dataRow, provider);
    				fncClearGridRow(dataRow+1, provider);
					Message.alert("<lgcom:message code="note.att.alreadySelectModifyDate"/>");
					myForm.hideProgress();
					return ;
				}
			}
			
			//수정가능한 근태일인지 체크
			//수정가능한 근태일인 경우 기존근태를 OLD 로 조회
	    	myForm.transaction("lgvhr", "lgvatt/LGVATT20020/retrieveAttendanceResultData", { attendanceYyyymmdd: attendanceYyyymmdd }, function (data) {
	    		if ( data.result ) {
	    			var checkData = data.result.checkData;
	    			var resultData = data.result.resultData;
	    			if ( $.trim(checkData.modifyEnableFlag) != "Y" ) {//수정가능한 근태일이 아닌 경우 메세지 출력
	    				//날짜 선택 시 Old, New 행 모두 초기화
	    				fncClearGridRow(dataRow, provider);
	    				fncClearGridRow(dataRow+1, provider);
	    				Message.alert("<lgcom:message code='note.att.modifyDate' />");
	    				return ;
	    			} else if ( $.trim(resultData) ) {//수정가능한 근태일인 경우 변경전 근태에 조회한 데이터 출력
	    				rows.push(resultData);
	    				provider.updateRows(dataRow, rows, 0, -1);
	    				fncClearGridRow(dataRow+1, provider);//날짜 변경전 선택값 지워주기
	    				
	    				//조회결과 중 날짜, 요일, 교대 정보는 new 행에 셋팅해준다.
	    				for (var i=0; i<controlColumns.copyColumn.length; i++) {
	    					var columnName = controlColumns.copyColumn[i];
	    					//old행값 복사 컬럼인 경우 old행 값, 컬럼명에 Hours가 들어가는 경우 숫자 컬럼으로 보고 초기값 0, 그외 초기값 null 
	    					//provider.setValue(dataRow+1, columnName, nvl(resultData[columnName], (fncIsNumberColumn(columnName)?0:null)));
	    					provider.setValue(dataRow+1, columnName, resultData[columnName]);
	    				}
	    				
	    				//근태코드 수정 불가능한 행인 경우 근태유형, 근태코드 셋팅
	    				if ( nvl(resultData.updateEnableFlag, "N") == "N" ) {
	    					provider.setValue(dataRow+1, "attendanceType", resultData.attendanceType);
	    					provider.setValue(dataRow+1, "attendanceCode", resultData.attendanceCode);
	    				}
	    				
	    				//행별 수정가능 컬럼 여부 판별
	    				fncSetEditableControl(cgrid, provider, dataRow, "N");
	    				fncSetEditableControl(cgrid, provider, dataRow+1, "Y");
	    			}
	    		}
	    	});
		}<%-- end - if ( !isNull($.trim(attendanceYyyymmdd)) ) { --%>
		else {//날짜가 없는 경우 
			//날짜 선택 시 Old, New 행 모두 초기화
			fncClearGridRow(dataRow, provider);
			fncClearGridRow(dataRow+1, provider);
		}
		myForm.hideProgress();
	}
	/* 그리드 특정 행의 값을 모두 지우는 함수 */
	function fncClearGridRow( itemIndex, provider ) {
		var fieldNames = provider.getOrgFieldNames();
		if ( itemIndex > -1 && itemIndex < provider.getRowCount() ) {
			for ( var i=0; i<fieldNames.length; i++ ) {
				<%-- Old, New 구분 컬럼을 제외하고 공백으로 초기화 --%>
				if ( controlColumns["oldNewTypeColumn"].indexOf(fieldNames[i]) == -1 ) {
					if ( fieldNames[i] == "eveningMealFlag" ) {//석식여부는 기본값을 N으로 한다.
						provider.setValue(itemIndex, fieldNames[i], "N");
					
					} else if ( fncIsNumberColumn(fieldNames[i]) ) {//숫자컬럼이면 기본값을 0으로 한다.
						provider.setValue(itemIndex, fieldNames[i], 0);
					
					} else {
						provider.setValue(itemIndex, fieldNames[i], null);
					}
				}
			}//end-for
		}//end-if
	}
	//숫자컬럼인지 여부
	function fncIsNumberColumn(columnName) {
		if ( !isNull(columnName) && columnName.indexOf("Hours") > -1 ) {
			return true;		
		}
		return false;
	}
	//값 초기화
	function fncResetRowData(cgrid, itemIndex) {
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
		cgrid.setValue(itemIndex, "updateRequestReasonDesc", null);
	}
	//OT재계산
	function fncCalculateOT(cgrid, rowIndex) {
		var param = {subsidiaryCode    :"${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}",
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
			         
			        ,employeeNo            :"${sessionScope.LGVHR_PROJECT_SESSION.employeeNo}",
			         attDate               :$.trim(cgrid.getValue(rowIndex, "attendanceYyyymmdd")),
					 actualShiftCode	   :"${sessionScope.LGVHR_PROJECT_SESSION.shiftTypeCode}",
					 actualAttendanceDetail:$.trim(cgrid.getValue(rowIndex, "attendanceCode")),
					 actualDayNight		   :$.trim(cgrid.getValue(rowIndex, "nightShiftFlag")),
					 actualStartTm		   :$.trim(cgrid.getValue(rowIndex, "workStartTime")),
					 actualDinnerChk	   :$.trim(cgrid.getValue(rowIndex, "eveningMealFlag"))
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
		var provider = cgrid.getDataProvider();
    	var monthOtTotal = cgrid.getValue(rowIndex, "monthTotalOvertime");
    	var monthOtLimit = cgrid.getValue(rowIndex, "overtimeLimit");
    	var overtimeSumHours = 0;
    	for ( var i=1; i<provider.getRowCount(); i=i+2 ) {
    		overtimeSumHours = overtimeSumHours + provider.getValue(i, "weekdayOvertimeHours") + provider.getValue(i, "holidayOvertimeHours") + 
    		provider.getValue(i, "publicHolidayOvertimeHours") + provider.getValue(i, "weekdayNightOvertimeHours") + 
			provider.getValue(i, "weekdayOtAfNightWorkHours") +  provider.getValue(i, "holidayNightOvertimeHours") + provider.getValue(i, "publicHolidayNightOtHours");
		}
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
	//공통의 요청자 정보 조회 기능 사용
	function fncRetrieveRequestorData() {
		myForm.showProgress();
		myForm.transaction_sync("lgvhr",'common/requestForm/retrieveRequestHeadInfo', {'requestMasterId':requestMasterId,'requestCode':requestCode}, function(data) {
			if(data.result) {
				requestorForm.setValue(data.result);
			}
			myForm.hideProgress();
		});
	}
	//공통의 결재자 정보 조회 기능 사용
	function fncRetrieveApprovalLineList() {
		myForm.showProgress();
		transaction_sync("lgvhr",'common/requestForm/retrieveApprovalLineList', requestorForm.getValue(), function(data) {
			if(data.result) {
				approvalLine = data.result;
			}
			myForm.hideProgress();
		});
	}
	//재량권 조회
	function fncRetrieveARMInfo( armNo ) {
		/* 재랑권 정보 조회. parameter[armNo:재량권번호]  */
		myForm.transaction("lgvhr", "lgvatt/LGVATTCOMM/retrieveARMInfo", {armNo:armNo} , function( data ){
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

		} else {
			var body = myForm.select(".carbonCopyTable tbody");
			//이미 이 안에 추가된 경우에는 추가하지 않고 끝
			if( body.find("input[name='applicationUserId'][value='" + item["userId"] + "']").exists() ) {
				Message.alert( item["employeeName"] + " is already added in the list. ");
				return;
			}

			var str = "<tr>"+
			          "<td class='text-center'>" + ( $(body).find("tr").length + 1 ) + "</td>"+
			          "<td>"+ userName +
			          " <input type='hidden' name='positionName' value='"+ nvl(item["positionName"]) +"' />"+
			          "<input type='hidden' name='lineType' value='CARBON' />"+
			          "<input type='hidden' name='applicationUserId' value='"+ item["userId"] +"' />"+
			          "<input type='hidden' name='employeeNo' value='"+ item["employeeNo"] +"' />"+
			          "</td>"+
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
	//요청전 입력값 체크
	function fncValidateSaveRequestInfo() {
		var dataProvider = grid.getDataProvider();
		var cgrid = grid.getGridBase();
		
		//행추가로 강제 생성된 행이기 때문에 행 상태는 created
		var rowIdxs = dataProvider.getStateRows("created");//dataRow배열값
		if ( rowIdxs ) {
			for ( var i=0; i<rowIdxs.length; i++ ) {
				var rowData = dataProvider.getJsonRow(rowIdxs[i]);
				//근태일자 없는 경우 오류
				if ( isNull(rowData["attendanceYyyymmdd"]) ) {
					Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.date'/>"/>');
					cgrid.setCurrent({itemIndex: cgrid.getItemIndex(rowIdxs[i]), column:'attendanceYyyymmdd'});
					cgrid.setFocus();
					return false;
				}
				//근태코드 없는 경우 오류
				if ( rowData["dataOldNewTypeCode"] == "NEW" && isNull(rowData["attendanceCode"]) ) {
					Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.actualAttendanceDetail'/>"/>');
					cgrid.setCurrent({itemIndex: cgrid.getItemIndex(rowIdxs[i]), column:'attendanceType'});
					cgrid.setFocus();
					return false;
				//근태코드에 대한 상세코드가 있는 경우 상세코드 선택값 없으면 오류
				} else if ( rowData["dataOldNewTypeCode"] == "NEW" && isNull(rowData["timeAttendDetailCode"]) && valueset.get("attendanceDetailCodeList").findIndex(function ( item ) { return item.attendanceCode == rowData["attendanceCode"]}) > -1 ) {
					Message.alert('<lgcom:message code="note.att.emptyAttendanceDetailReason"/>');
					cgrid.setCurrent({itemIndex: cgrid.getItemIndex(rowIdxs[i]), column:'timeAttendDetailCode'});
					cgrid.setFocus();
					return false;
				}
				//석식여부 없는 경우 오류
				if ( rowData["dataOldNewTypeCode"] == "NEW" && isNull(rowData["eveningMealFlag"]) ) {
					Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.actualDinnerChk'/>"/>');
					cgrid.setCurrent({itemIndex: cgrid.getItemIndex(rowIdxs[i]), column:'eveningMealFlag'});
					cgrid.setFocus();
					return false;
				}
				//수정사유 필수입력 체크
				if ( rowData["dataOldNewTypeCode"] == "NEW" && isNull(rowData["updateRequestReasonDesc"]) ) {
					Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.modificationReason'/>"/>');
					cgrid.setCurrent({itemIndex: cgrid.getItemIndex(rowIdxs[i]), column:'updateRequestReasonDesc'});
					cgrid.setFocus();
					return false;
				}
			}
		}
		return true;
	}
	/* Save as Draft */
	function fncSaveRequestInfo( requestFlag ){
		try {
			grid.getGridBase().commit();
		} catch(e) {
			Message.alert(e.message);
			return;
		}
		
		// 데이터 유무 체크
		if( grid.getRowCount() == 0 ) {
			Message.alert('<lgcom:message code="note.nodata"/>');
			return;
		}
		
		// 변경건이 있는지 체크
		if( !grid.isChanged() ) {
			Message.alert('<lgcom:message code="error.noChangedData"/>');
			return;
		}

		//입력값 체크
		if ( !fncValidateSaveRequestInfo() ) {
			return ;
		}
		
		//결재자 체크
		if( myForm.select(".approvalInfoTable tr.ARM_Y").length == 0 ) {
			Message.alert("<lgcom:message code="note.checkApprovalInformation"/>");
			return;
		}

		var startMessage = "<lgcom:message code="question.att.requestSave" />";
		if( requestFlag ){
			startMessage = "<lgcom:message code="question.att.requestSubmit" />";
		}

		Message.confirm( startMessage , function(){
			/* 복수 레코드 정리 */
			try{
				var modifyArr = fncArrangeMultiLineGrid( grid, "created,updated" );//계획 변경 건만 승인요청 함.
				var approvalArr =  fncArrangeMultiLine( approverForm.getValue(), "applicationUserId");
			} catch( e ) {
				trace( e );
			}
			
			if ( modifyArr.length == 0 ) {
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
			master = $.extend(master, requestorForm.getValue());
			//단일레코드의 항목들을 모두 master 로 모아서 저장한다.
			param["master"] = master;

			//멀티 레코드의 항목들을 각각 저장한다.
			param["modifyList"] = modifyArr;
			param["approval"] = approvalArr;

			if( requestFlag ) {
				param["requestFlag"] = "Y";
			}

			myForm.showProgress();
			myForm.transaction("lgvhr", "lgvatt/LGVATT20020/insertModifyAttendanceApprovalRequest", param, function( data ){
				myForm.hideProgress();
				if( requestFlag ) {
					Message.alert( "<lgcom:message code="note.completed" />" );
				} else {
					Message.alert( "<lgcom:message code="note.saved" />" );
				}

				requestorForm.clear();
				grid.clear();
				//Approval 영역의 초기상태를 두고, 모두 지운다.
				myForm.select(".approvalInfoTable tbody tr").remove();
				approverForm.clear();
				
				//신규화면으로 재 셋팅
				fncRetrieveInitData();
			});
		});
	}
	<%-- 공통 결재에서 호출되는 경우 사용함 --%>
	//결재에서 호출된경우 요청서 데이터 조회
	function fncRetrieveRequestContent() {
		//요청서 버튼, 요청자정보, 결재자 정보 숨김
		myForm.select(".controls").hide();
		myForm.select(".requestorInfo").hide();
		myForm.select(".clearfix").hide();
		myForm.select(".approvalArea").hide();
		
		/* Grid Layout 재조정 */
		myForm.setLayout( [
			{ name  : "gridContent", left : 0, right : 0, top : 0, bottom : 0 },
		]);
		
		myForm.showProgress();
		grid.loadData("lgvhr", "lgvatt/LGVATT20020/retrieveResultUpdateReqList", requestorForm.getValue(), function (data) {
			//readonly 행에 대한 배경색 처리
			for( var i=0; i<data.result.length; i++ ) {
				fncSetEditableControl(grid.getGridBase(), grid.getGridBase().getDataProvider(), i, "N");
			}
		});
		grid.getGridBase().setEditOptions({readOnly:true});//비활성화
		// 결재영역 높이 재지정
		_resizeDetailArea(myForm.select('.gridContent').outerHeight(true));
		grid.getGridBase().resetSize();
		fncControllButton();
		myForm.hideProgress();
	}
	// 결재 처리 Callback Function
	function fnApprovalOrRejectRequest(actionCode) {
		myForm.showProgress();
		var returnValue = false;
		var param = {requestMasterId : requestorForm.getValue("requestMasterId")
				   , requestCode     : requestorForm.getValue("requestCode")
				   , approvalCommand : actionCode.toUpperCase()
				   , comment         : requestorForm.getValue("approvalComment")
		             };
			
		transaction_sync("lgvhr", "lgvatt/LGVATT20020/saveRequestApprovalOrReject", param, function(data) {
			if(data.result) {
				// 정상처리
				if($.trim(data.result['errorCode']) == 'S') {
					returnValue = true;
				} else {
					returnValue = false;
				}
				myForm.hideProgress();
				if(!returnValue) {
					Message.alert(data.result['errorMsg']);
				}
				return returnValue;
			}
			myForm.hideProgress();
		},function(error) {
			trace(error);
			myForm.hideProgress();
		});
	}
	// Custom Button 제어 로직
	function fncControllButton() {
	}
	<%-- //공통 결재에서 호출되는 경우 사용함 --%>
	//화면 초기데이터 조회
	function fncRetrieveInitData() {
		//요청 정보 조회
		fncRetrieveRequestorData();
		
		myForm.transaction("lgvhr", "lgvatt/LGVATT20020/retrieveInitData", requestInfoForm.getValue(), function(data) {
			if ( data.result ) {
				var reqDocBaseInfo = data.result.reqDocBaseInfo;
				var approvalMasterData = data.result.approvalMasterData;
				
				//재량권번호 셋팅
				requestInfoForm.setValue({ armNo:reqDocBaseInfo["armNo"] });
				//요청코드, 요청서제목 셋팅
				requestorForm.setValue({ requestCode:reqDocBaseInfo["requestCode"]
				                       , requestTitle:approvalMasterData["requestTitle"]});
				
				if ( isNull(requestInfoForm.getValue("requestMasterId")) ) {//요청서아이디가 없으면 재량권 조회
					myForm.select(".approvalInfoTable").show();
					myForm.select(".approvalInfoTableView").hide();
					fncRetrieveARMInfo(requestInfoForm.getValue("armNo"));
				} else {//요청서아이디가 있으면 결재선조회
					myForm.select(".approvalInfoTable").hide();
					myForm.select(".approvalInfoTableView").show();
					fncRetrieveApprovalLineList();
				}
			}
		});
	}
	
	//결재에서 호출된 경우가 아닐때만 초기 데이터 조회한다.
	if ( approvalCallFlag != "Y" ) {
		fncRetrieveInitData();
		
		// 화면 레이아웃 정의(결재선 셋팅 후 화면 레이아웃 확정되기 때문에 마지막에 셋팅한다.)
		myForm.setLayout([
			{ name : "controls",      left : 0, right : 0, top : 0  },
			{ name : "requestorInfo", left : 0, right : 0, top : "controls", bottom : "gridContent" },
			{ name : "gridContent",   left : 0, right : 0, top : "requestorInfo", bottom : "approvalArea" },
			{ name : "approvalArea",  left : 0, right : 0, top : "gridContent", bottom : 0 }
		]);
	}
}

LGVATT20020.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVATT20020();
		form.init();		
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2><lgcom:message code="label.att.requestAttendanceModification"/></h2>
		</div>
		<%-- 버튼 --%>
	    <div class="controls module-group text-right">	
			<div class="btn-toolbar">	
				<div class="btn-group">				
					<button class="btn btn-darkgray btn-sm" type="button" name="request" data-action="request"><lgcom:message code="button.att.submitRequest"/></button>
				</div>
			</div>		
		</div>
		<form class="form requestInfo">
			<input type="hidden" name="requestDocCode" value="" />
			<input type="hidden" name="armNo" value="" />
		</form>
		<!-- 요청자 정보 -->
		<div class="requestorInfo">
			<div class="sub-header">
				<h3><lgcom:message code="RequestInformation"/></h3>
			</div>
			<div>
				<form class="form _requestHeadForm_">
					<input type="hidden" name="requestMasterId" value="" />
					<input type="hidden" name="requestCode" value="" />
					<input type="hidden" name="statusCode" value="" />
					<input type="hidden" name="approvalComment"/>
					<table class="table table-condensed" summary="Request Header">
						<colgroup>
							<col width="80" />
							<col width="200" />
							<col width="80" />
							<col width="350" />
							<col width="80" />
							<col width="180" />
							<col width="80" />
							<col width="*" />
						</colgroup>
						<tbody>
							<tr>
								<th scope="row"><label><lgcom:message code="ApprovalRequestNo"/></label></th>
								<td><span name="requestNo"></span></td>
								<th scope="row"><label><lgcom:message code="ApprovalRequestor"/></label></th>
								<td><span name="requestorInfo"></span></td>
								<th scope="row"><label><lgcom:message code="ApprovalRequestStatus"/></label></th>
								<td><span name="statusName"></span></td>
								<th scope="row"><label><lgcom:message code="ApprovalRequestDate"/></label></th>
								<td><span name="requestDate"></span></td>
							</tr>
							<tr>
								<th scope="row"><label><lgcom:message code="ApprovalRequestTitle"/></label></th>
								<td colspan="7"><span name="requestTitle"></span></td>
							</tr>
						</tbody>
					</table>
				</form>
			</div>
		</div>
		<!-- 상세 정보 : 업무 화면이 위치하는 부분  -->
		<%-- 수정요청 --%>
		<div class="gridContent grid-wrap">
			<div class="module-group clearfix">
				<div class="pull-left sub-header">
					<h4><lgcom:message code="ApprovalDetailInformation" /></h4>
				</div>
				<div class="pull-right">
					<button class="btn btn-default btn-sm ico-lgd" data-action="add"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="Add"/></button>
					<button class="btn btn-default btn-sm ico-lgd" data-action="delete"><span class="fa fa-minus" aria-hidden="true"></span> <lgcom:message code="Delete" /></button>
				</div>
			</div>
			<div class="grid modifyGrid"></div>
		</div>
		<!-- 결재선 -->
		<div class="approvalArea">
			<div class="module-group clearfix">
				<div class="pull-left sub-header">
					<h3><lgcom:message code="ApprovalInformation"/></h3>
				</div>
				<div class="pull-right">
					<button class="btn btn-default btn-sm" data-action="apprReset" style="display:none;"><lgcom:message code="Reset1"/></button>
					<button class="btn btn-default btn-sm" data-action="apprAddFirst" style="display:none;"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="AddRowAtFirst1"/></button>
				</div>
			</div>
			<div class="_approval_area_">
				<form class="form _approverForm_">
					<table class="table table-condensed table-bordered approvalInfoTable" summary="Approver Infomation">
						<colgroup>
							<col width="50"/>
							<col width="150"/>
							<col width="*"/>
							<col width="400"/>
						</colgroup>
						<thead>
							<tr>
								<th><lgcom:message code="ApprovalSeq"/></th>
								<th><lgcom:message code="ApprovalType"/></th>
								<th><lgcom:message code="ApprovalApprover"/></th>
								<th><lgcom:message code="ApprovalMandator"/></th>
								<th></th>
							</tr>
						</thead>
						<tbody></tbody>
					</table>
					<table class="table table-condensed table-bordered approvalInfoTableView" summary="Approver Infomation">
						<colgroup>
							<col width="50"/>
							<col width="110"/>
							<col width="280"/>
							<col width="280"/>
							<col width="100"/>
							<col width="100"/>
							<col width="*"/>
						</colgroup>
						<thead>
							<tr>
								<th><lgcom:message code="ApprovalSeq"/></th>
								<th><lgcom:message code="ApprovalType"/></th>
								<th><lgcom:message code="ApprovalApprover"/></th>
								<th><lgcom:message code="ApprovalMandator"/></th>
								<th><lgcom:message code="ApprovalStatus"/></th>
								<th><lgcom:message code="ApprovalDate"/></th>
								<th><lgcom:message code="ApprovalComment"/></th>
								<th></th>
							</tr>
						</thead>
						<tbody></tbody>
					</table>
				</form>
			</div>
		</div>
		<!-- //결재선 -->
	</section>
</div>
</body>
</html>