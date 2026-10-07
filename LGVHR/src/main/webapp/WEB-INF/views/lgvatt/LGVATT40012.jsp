<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVATT40012.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2018 LG CNS,  All rights reserved.

    설 명 : 본 화면은 사무직 일근태 조회하는 화면 입니다. ( 팀장 하위 직원 모두 조회가능 )
    작성자 : 이형준
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title><lgcom:message code="label.att.dailyRegistration"/></title>
<script src="/lgvhr/static/js/lgvatt.js"></script>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVATT40012 = function() {
	var myForm = this;
	/* Form Util 선언 */ 
	var formUtil = new FormUtil(myForm,'.searchBlock form'); //요청기본정보

    // 화면 레이아웃 정의
	myForm.setLayout([
		{ name : "searchBlock",		left : 0, right : 0, top : 0  },              
		{ name : "buttonControls",	left : 0, right : 0, top : "searchBlock", bottom : "resultBlock" },
		{ name : "resultBlock",		left : 0, right : 0, top : "buttonControls", bottom : 0 }
	]);
	
	myForm.popupInfo = {
        userPopup   : {searchMode:'single', popupKind:'', confirmKind:'', employeeNo:'', employeeName:'', userData:[]},
        returnPopup : {returnComment:''}
    };
	
	//날짜 설정
    formUtil.setCalendar( { from : "fromDate", to : "toDate", language:SESSION_USER.languageCode, format: 'DD/MM/YYYY' } );
    
    formUtil.setValue( {
    	fromDate : DateUtil.format(DateUtil.today().add(-1, 'month'), 'DD/MM/YYYY'),
        toDate : DateUtil.format(DateUtil.today(), 'DD/MM/YYYY')
    });
	
    // 코드 데이터 조회(그리드 콤보 셋팅하기 위해 사용함.)
	// combo 목록 조회
    var code = new CommonCode("lgcom");
    code.add("approvalStatusList", {codeTypeCode:"LGVHR_ATT_APPROVAL_STATUS"});
    code.execute();

    //결재상태 콤보 셋팅
    formUtil.initCombo("approvaStatusCode", code.get("approvalStatusList"), {selectAll:true});
	
	//근태유형, 근태코드, 근태 상세코드 조회
	var valueset = new ValueSet("lgcom");
	valueset.add("attendanceCodeList", {valueSetId : "LGVATT_ATTEND_DETAIL", attendTypeName :"", subsidiaryCode :"${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}", languageCode:SESSION_USER.languageCode} );
	valueset.execute();
	
	myForm.transaction_sync("lgvhr", "lgvatt/LGVATT40012/retrieveSearchFormDataList", {}, function(data) { 
		if ( data.result ) {
			formUtil.initCombo('orgName', data.result["underOrgList"], { selectAll: false });
		}
	});
	
    // 그리드 초기화
    var resultGrid = buildGrid(".resultGrid");

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
			case 'search' :
				//기본정보 조회
				fncRetrieveAttendanceData();
				break;
			case 'goList' :
				var nav = new Navigate( myForm, "lgvhr", "M_LGVATT_1039" );
		        nav.addNavigationCallback( function( caller ){
		            myForm.select("button[data-action=search]").trigger('click');
		        });
		        nav.goPageInCurrentDiv(false);
				break;
				// 유저 검색 팝업
		    case "openPopupApprover" :
                console.log("openPopupApprover");
                var _popup = myForm.popupInfo.userPopup;
                _popup.searchMode   = "single";
                _popup.popupKind    = "underOrg";
                _popup.confirmKind  = "";
                _popup.employeeNo = formUtil.getValue("employeeNo");
                _popup.employeeName = formUtil.getValue("employeeName");

                var popup = new Popup( myForm,'lgvhr', 'M_LGVCOM_1010', '<lgcom:message code="UserSearch"/>' );
                popup.setSize(800,494);
                popup.open( function(){
                    formUtil.setValue({employeeNo  :_popup.userData[0].employeeNo});
                    formUtil.setValue({employeeName   :_popup.userData[0].employeeName});
                    formUtil.setValue({orgName   :_popup.userData[0].organizationId});
                });
                _popup.userData = [];
                break;
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
					fncSaveApproval();
				} else if( type == 'REJECT') {
					myForm.showProgress();
					fncSaveReject();
				}
				$(item).removeAttr("disabled");

				hideCommentWindow();
				$(".buttonControls button" ).removeAttr("disabled");
				break;
			case "cancel":
				hideCommentWindow();
				break;
			case "approval" :
				if( resultGrid.getRowCount() == 0 ) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};
				
				//선택된 행이 있는지 체크
				var checkeds = resultGrid.getGridBase().getCheckedItems();
				if ( !checkeds || checkeds.length == 0 ) {
					Message.alert("<lgcom:message code="note.noselected"/>");
					return ;
				}
				
				var action = $(event.target).data("action");
				myForm.select("._commentWindow").data("action", action);
				myForm.select("._commentWindow").data("type", action.toUpperCase());
				myForm.select("._commentWindow .actionName").text("Approval");
				myForm.select("._commentWindow ._comment").val("");
				
				showCommentWindow();
				break;
			case "reject" :
				if( resultGrid.getRowCount() == 0 ) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};
				
				//선택된 행이 있는지 체크
				var checkeds = resultGrid.getGridBase().getCheckedItems();
				if ( !checkeds || checkeds.length == 0 ) {
					Message.alert("<lgcom:message code="note.noselected"/>");
					return ;
				}
				
				var action = $(event.target).data("action");
				myForm.select("._commentWindow").data("action", action);
				myForm.select("._commentWindow").data("type", action.toUpperCase());
				myForm.select("._commentWindow .actionName").text("Reject");
				myForm.select("._commentWindow ._comment").val("");

				showCommentWindow();
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
								
				//마우스 오른쪽 클릭시 메뉴
				grid.setContextMenu();
				
				//필드 설정
				grid.setFields(
						[	
							{ fieldName:'organizationName'          , dataType:'text'  },
							{ fieldName:'employeeNo'        	    , dataType:'text'  },
							{ fieldName:'employeeName	'           , dataType:'text'  },
							{ fieldName:'timeAndAttendanceDate'     , dataType:'text'  },
							{ fieldName:'attendanceYyyymmddResult'  , dataType:'text'  },
							{ fieldName:'inTime'                    , dataType:'text'  },
							{ fieldName:'outTime'                   , dataType:'text'  },
							{ fieldName:'shiftTypeCode'             , dataType:'text'  },
							{ fieldName:'nightShiftName'            , dataType:'text'  },
							{ fieldName:'timeAndAttendanceTypeName' , dataType:'text'  },
				            { fieldName:'timeAndAttendanceCode'     , dataType:'text'  },
				            { fieldName:'timeAttendDetailName'      , dataType:'text'  },
							{ fieldName:'workStartTime'             , dataType:'text'  },
							{ fieldName:'tardyHours'                , dataType:'number'},
							{ fieldName:'earlyLeaveHours'           , dataType:'number'},
							{ fieldName:'goingOutHours'             , dataType:'number'},
							{ fieldName:'overtimeSumHours'          , dataType:'number'},
				            { fieldName:'timeAttendInputReasonDesc' , dataType:'text'  },
							{ fieldName:'approver1Name'             , dataType:'text'  },
							{ fieldName:'approver2Name'     		, dataType:'text'  },
				            { fieldName:'approvalStatus'          	, dataType:'text'  },
							{ fieldName:'requestMasterId'     		, dataType:'text'  },
				            { fieldName:'requestCode'          		, dataType:'text'  },
				            { fieldName:'approvalEnableFlag'        , dataType:'text'  },
				            { fieldName:'approvalStatCd'        	, dataType:'text'  },
				            
							{ fieldName:'eveningMealFlag'           , dataType:'text'  },
							{ fieldName:'normalNightOvertimeHours'  , dataType:'number'},
							{ fieldName:'weekdayOvertimeHours'      , dataType:'number'},
							{ fieldName:'holidayOvertimeHours'      , dataType:'number'},
							{ fieldName:'publicHolidayOvertimeHours', dataType:'number'},
							{ fieldName:'weekdayNightOvertimeHours' , dataType:'number'},
							{ fieldName:'weekdayOtAfNightWorkHours' , dataType:'number'},
							{ fieldName:'holidayNightOvertimeHours' , dataType:'number'},
							{ fieldName:'publicHolidayNightOtHours' , dataType:'number'},
				            { fieldName:'updateEnableFlag'          , dataType:'text'  },
				            { fieldName:'holidayFlag'          		, dataType:'text'  },
				            { fieldName:'inOutTimeRedFlag'          , dataType:'text'  }
						]
				);
				
				//옵션 설정 
				grid.setOptions({
					grid: {
						softDeleting: false,
						deleteCreated: false,
						hideDeletedRows: false,
						indicator: {visible:false},
						panel: {visible:false},
						checkBar: {visible:true, checkableExpression: "(values['approvalEnableFlag'] = 'Y') and (values['approvalStatCd'] = 'WA')"},
						stateBar: {visible:false},
						footer: {visible:false},
						select: 'block',
						paste    : { enabled: false }, /*paste 기능막기 */
						sorting  : { enabled: false }, /*Sorting 기능을 막는다.*/
		                sortMode : "explicit",
						edit: {
							insertable: false, /* INSERT 키 또는 방향키로 행삽입 불가능 */
							appendable: false, /* INSERT 키 또는 방향키로 행추가 불가능 */
							updatable: false,
							deletable: false
						},
						header: {height: 60, heightFill: 'fixed', showTooltip: true},
						fixed: { colCount: 3, resizable:true }
					},
					display: { fitStyle: 'none' }
				});
				
				//컬럼 콤보 셋팅
				grid.setLookupsMultiLvl({
					"attendanceCode":{data:valueset.get("attendanceCodeList"), keyField:['code']}
				});
				//컬럼 설정 
				grid.setColumns(
						[
							{	name:'organizationName',
								fieldName:'organizationName',
								width:220,
								header: {text:'<lgcom:message code="label.att.organization"/>'},
								styles: {textAlignment:'near' },
								editable: false
							},
							{	name:'employeeNo',
								fieldName:'employeeNo',
								width:70,
								header: {text:'<lgcom:message code="label.att.employeeNo"/>'},
								styles: {textAlignment:'center' },
								editable: false
							},
							{	name:'employeeName',
								fieldName:'employeeName',
								width:100,
								header: {text:'<lgcom:message code="label.att.employeeName"/>'},
								styles: {textAlignment:'near' },
								editable: false
							},
							{	name:'timeAndAttendanceDate',
								fieldName:'timeAndAttendanceDate',
								width:70,
								header: {text:'<lgcom:message code="label.att.date"/>'},
								styles: {textAlignment:'center' },
								editable: false
							},
							{	name:'inTime',
								fieldName:'inTime',
								width:40,
								header: {text:'<lgcom:message code="label.att.inTime"/>'},
								styles: {textAlignment:'center' },
								editable:false,
								dynamicStyles:[{criteria:"values['inOutTimeRedFlag']='Y'", styles:{foreground:"#f34d78"}}]
							},
							{	name:'outTime',
								fieldName:'outTime',
								width:40,
								header: {text:'<lgcom:message code="label.att.outTime"/>'},
								styles: {textAlignment:'center' },
								editable:false,
								dynamicStyles:[{criteria:"values['inOutTimeRedFlag']='Y'", styles:{foreground:"#f34d78"}}]
							},
							{	name:'shiftTypeCode',
								fieldName:'shiftTypeCode',
								width:40,
								header: {text:'<lgcom:message code="label.att.shiftType"/>'},
								styles: {textAlignment:'center' },
								editable: false
							},
							{	name:'nightShiftName',
								fieldName:'nightShiftName',
								width:40,
								header: {text:'<lgcom:message code="label.att.actualDayNight"/>'},
								styles: {textAlignment:'center' },
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
											{	name:'timeAndAttendanceTypeName',
												fieldName:'timeAndAttendanceTypeName',
												width:90,
												header: {text:'<lgcom:message code="label.att.actualAttendanceType"/>'},
												styles: {textAlignment:'near'},
											    renderer: {showTooltip: true},
												editor: {type:'dropDown',textReadOnly:true},
												editable : false
											},
											{	name:'timeAndAttendanceCode',
												fieldName:'timeAndAttendanceCode',
												width:110,
												header: {text:'<lgcom:message code="label.att.actualAttendanceDetail"/>'},
												styles: {textAlignment:'near'},
											    renderer: {showTooltip: true},
												lookupDisplay: true,
												lookupSourceId: 'attendanceCode',
												lookupKeyFields: ['timeAndAttendanceCode'],
												editor: {type:'dropDown',textReadOnly:true},
												editable : false
											},
											{	name:'timeAttendDetailName',
												fieldName:'timeAttendDetailName',
												width:120,
											    renderer: {showTooltip: true},
												header: {text:'<lgcom:message code="label.att.timeAttendDetailCode"/>'},
												styles: {textAlignment:'near'},
												renderer: {showTooltip:true},
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
								editor: {type:'dropDown',textReadOnly:true},
								editable: false
							},
							{	name:'eveningMealFlag',
								fieldName:'eveningMealFlag',
								width:50,
								header: {text:'<lgcom:message code="label.att.actualDinnerChk"/>'},
								styles: {textAlignment:'center'},
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
							{	name:'overtimeSumHours',
								fieldName:'overtimeSumHours',
								width:40,
								header: {text:'<lgcom:message code="label.att.totalOT"/>'},
								styles: {textAlignment:'far', numberFormat: '#0.0'},
								editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
								editable: false
							},
							{	name:'timeAttendInputReasonDesc',
								fieldName:'timeAttendInputReasonDesc',
								width:160,
								header: {text:'<lgcom:message code="label.att.timeAttendInputReasonDesc"/>'},
								styles: {textAlignment:'near'},
							    renderer: {showTooltip: true},
							    editor: {maxLength: 1000},
								editable: false
							},
							{	name:'approver1Name',
								fieldName:'approver1Name',
								width:120,
								header: {text:'<lgcom:message code="label.att.firstApprover"/>'},
								styles: {textAlignment:'near' },
								editable: false
							},
							{	name:'approver2Name',
								fieldName:'approver2Name',
								width:120,
								header: {text:'<lgcom:message code="Final"/>' + ' ' + '<lgcom:message code="label.att.approver"/>'},
								styles: {textAlignment:'near' },
								editable: false
							},
							{	name:'approvalStatus',
								fieldName:'approvalStatus',
								width:100,
								header: {text:'<lgcom:message code="label.att.approvalStatus"/>'},
								styles: {textAlignment:'center' },
								editable: false
							},
							{	type:'group',
								name:'night',
								fieldName:'night',
								width:45,
								header:{
							         text:'<lgcom:message code="label.att.night" />', fixedHeight:20
							    },
								orientation:'horizontal',
								columns: [
											{	name:'normalNightOvertimeHours',
												fieldName:'normalNightOvertimeHours',
												width:45,
												header: {text:'<lgcom:message code="label.att.nightNormal2"/>', tooltip:'<lgcom:message code="label.att.nightNormal"/>'},
												styles: {textAlignment:'far', numberFormat: '#0.0' },
												editable:false
											}
										]
							},
							{	type:'group',
								name:'actualOT',
								fieldName:'actualOT',
								width:150,
								header:{
							         text:'<lgcom:message code="label.att.actualOT" />', fixedHeight:20
							    },
								orientation:'horizontal',
								columns: [
											{	name:'weekdayOvertimeHours',
												fieldName:'weekdayOvertimeHours',
												width:50,
												header: {text:'<lgcom:message code="label.att.actualOTWeekDay2" />', tooltip:'<lgcom:message code="label.att.actualOTWeekDay"/>'},
												styles: {textAlignment:'far', numberFormat: '#0.0' },
												editable:false
											},
											{	name:'holidayOvertimeHours',
												fieldName:'holidayOvertimeHours',
												width:50,
												header: {text:'<lgcom:message code="label.att.actualOTWeekDayHoliday2" />', tooltip:'<lgcom:message code="label.att.actualOTWeekDayHoliday"/>'},
												styles: {textAlignment:'far', numberFormat: '#0.0' },
												editable:false
											},
											{	name:'publicHolidayOvertimeHours',
												fieldName:'publicHolidayOvertimeHours',
												width:50,
												header: {text:'<lgcom:message code="label.att.actualOTPublicHoliday2" />', tooltip:'<lgcom:message code="label.att.actualOTPublicHoliday"/>'},
												styles: {textAlignment:'far', numberFormat: '#0.0' },	
												editable:false
											}
										]
							},
							{	type:'group',
								name:'actualOTNight',
								fieldName:'actualOTNight',
								width:200,
								header:{
							         text:'<lgcom:message code="label.att.actualOTNight" />', fixedHeight:20
							    },
								orientation:'horizontal',
								columns: [
											{	name:'weekdayNightOvertimeHours',
												fieldName:'weekdayNightOvertimeHours',
												width:50,
												header: {text:'<lgcom:message code="label.att.actualOTNightWeekDay2" />', tooltip:'<lgcom:message code="label.att.actualOTNightWeekDay"/>'},
												styles: {textAlignment:'far', numberFormat: '#0.0' },	
												editable:false
											},
											{	name:'weekdayOtAfNightWorkHours',
												fieldName:'weekdayOtAfNightWorkHours',
												width:50,
												header: {text:'<lgcom:message code="label.att.actualOTNightWeekDayAfterOT2" />', tooltip:'<lgcom:message code="label.att.actualOTNightWeekDayAfterOT"/>'},
												styles: {textAlignment:'far', numberFormat: '#0.0' },
												editable:false
											},
											{	name:'holidayNightOvertimeHours',
												fieldName:'holidayNightOvertimeHours',
												width:50,
												header: {text:'<lgcom:message code="label.att.actualOTNightWeekDayHoliday2" />', tooltip:'<lgcom:message code="label.att.actualOTNightWeekDayHoliday"/>'},
												styles: {textAlignment:'far', numberFormat: '#0.0' },	
												editable:false
											},
											{	name:'publicHolidayNightOtHours',
												fieldName:'publicHolidayNightOtHours',
												width:50,
												header: {text:'<lgcom:message code="label.att.actualOTNightPublicHoliday2" />', tooltip:'<lgcom:message code="label.att.actualOTNightPublicHoliday"/>'},
												styles: {textAlignment:'far', numberFormat: '#0.0' },
												editable:false
											}
										]
							}
						]
				);
				break;
		}
		return grid;
	}
	
	//화면에 필요한 기본정보 조회
	function fncRetrieveAttendanceData() {
		resultGrid.loadData("lgvhr", "lgvatt/LGVATT40012/retrieveAttendanceData", formUtil.getValue(), function( data ) {
			myForm.hideProgress();
			if(data.result) {
				
			}
		});
	}
	
    //승인
    function fncSaveApproval( ) {
		/* 복수 레코드 정리 */
		var approvalList = [];
		var dataProvider = resultGrid.getDataProvider();
		try{
			var checkeds = resultGrid.getGridBase().getCheckedRows(false);//정렬된 순서로 index 가져오기
			for ( var i=0; i< checkeds.length; i++ ) {
				approvalList.push(dataProvider.getJsonRow(checkeds[i]));
			}
		} catch( e ) {
			trace( e );
		}
		
		if ( approvalList.length == 0 ) {
			Message.alert('<lgcom:message code="note.nodata"/>');
			return ;
		}
		
		//최종 저장소에 데이터 보내기
		var param = {};
		var infoData = {};
		infoData = $.extend(infoData, formUtil.getValue());
		infoData = $.extend(infoData, { comment : myForm.select("._commentWindow ._comment").val() });

		param["infoData"] = infoData;
		param["approvalList"] = approvalList;
		
		myForm.showProgress();
		myForm.transaction("lgvhr", "lgvatt/LGVATT40012/saveApproval", param, function(){
			myForm.hideProgress();
			Message.alert( "<lgcom:message code="note.com.successfullyApproved"/>" );
			resultGrid.getGridBase().setAllCheck(false);//헤더의 체크표시 비활성화 처리
			//클릭이벤트 호출
			myForm.select(".searchBlock button[data-action='search']").trigger('click');
		});
    }
    
    //반려
    function fncSaveReject() {
		/* 복수 레코드 정리 */
		var approvalList = [];
		var dataProvider = resultGrid.getDataProvider();
		try{
			var checkeds = resultGrid.getGridBase().getCheckedRows(false);//정렬된 순서로 index 가져오기
			for ( var i=0; i< checkeds.length; i++ ) {
				approvalList.push(dataProvider.getJsonRow(checkeds[i]));
			}
		} catch( e ) {
			trace( e );
		}
		
		if ( approvalList.length == 0 ) {
			Message.alert('<lgcom:message code="note.nodata"/>');
			return ;
		}

		//최종 저장소에 데이터 보내기
		var param = {};
		var infoData = {};
		infoData = $.extend(infoData, formUtil.getValue());
		infoData = $.extend(infoData, { comment : myForm.select("._commentWindow ._comment").val() });
		
		param["infoData"] = infoData;
		param["approvalList"] = approvalList;
		
		myForm.showProgress();
		myForm.transaction("lgvhr", "lgvatt/LGVATT40012/saveReject", param, function( data ){
			myForm.hideProgress();
			Message.alert( "<lgcom:message code="note.com.rejected"/>" );
			resultGrid.getGridBase().setAllCheck(false);//헤더의 체크표시 비활성화 처리
			//클릭이벤트 호출
			myForm.select(".searchBlock button[data-action='search']").trigger('click');
		});
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

LGVATT40012.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVATT40012();
		form.init();		
	});
});

</script>
</head>

<body>
<div class="mdi-container">
	<section class="page-content">
		
		<div class="searchBlock">
		    <form class="form search-wrap">
				<fieldset>
					<table class="table">
						<colgroup>
							<col width="90" />
							<col width="90"/>
							<col width="100" />
							<col width="200"/>
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
										
								<th scope="col"><label><lgcom:message code="label.att.approvalStatus"/></label></th>
								<td><select class="form-control input-sm input-require" name="approvaStatusCode" ></select></td>
								
			                </tr>
			                <tr>
			                
			                	<th><label><i class="asterisk">*</i><lgcom:message code="label.att.organization" /></label></th>
								<td><select class="form-control input-sm input-require" name="orgName"></select></td>
			                	
			                	<th><label><lgcom:message code="label.att.employeeNo2" /></label></th>
								<td>
			                		<div class="input-group input-group-sm input-search">
		                                <input class="form-control input-sm _find_origin_" name="employeeNo" type="text" data-action="emptyAndPopup">
		                                <span class="input-group-btn">
		                                    <button class="btn btn-default ico-lgd find" type="button" data-action="openPopupApprover">
		                                        <span class="fa fa-search" aria-hidden="true"></span>
		                                    </button>
		                                </span>
		                            </div>
			                	</td>
								
								<th><label><lgcom:message code="label.att.employeeName" /></label></th>
								<td><input type="text" class="form-control input-sm" name="employeeName"></td>
								
			                </tr>
						</tbody>
					</table>
				</fieldset>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search" ><lgcom:message code="search" /></button>
		    </form>
		</div>
	
		<%-- 버튼 --%>
		<div class="buttonControls module-group text-right">
	        <div class="btn-toolbar">
	            <div class="btn-group">
					<button class="btn btn-default btn-sm" type="submit" data-action="goList"><lgcom:message code="GoBack"/></button>
					<button class="btn btn-darkgray btn-sm" type="button" data-action="approval" disabled><lgcom:message code="Approval"/></button>
					<button class="btn btn-darkgray btn-sm" type="button" data-action="reject" disabled><lgcom:message code="Reject"/></button>
	            </div>
	        </div>
		</div>
		
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
