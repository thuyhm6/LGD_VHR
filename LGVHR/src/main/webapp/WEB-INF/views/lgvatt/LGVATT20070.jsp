<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld"%>
<%---------------------------------------------------------
    파일명 : LGVATT20070.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 사무직 / 기능직 직원이 특별연장근무실적을 입력하고 신청하는 화면이다.
    		사무직 직원은 직접 입력 , 기능직 직원은 근태 담당자가 입력 한다.
            결재 시 본화면의 내용을 동일하게 사용한다.
            1. 사무직인지 / 기능직인지 판단 접속 사용자
            2. 근태담당자인지 판단 , 근태 담당자이면 조직아이디에 물린 liner_worker(기능직) 리스트 업(id/name)
    작성자 : KIKIMANS
    HMT_20210410             Add month ot total, month ot limit and 
-------------------------------------------------------------%>

<c:set var="flg_vn_line_worker_pic_user" value="N"/>
<c:set var="flg_lgd_ow" value="N"/>
<c:set var="flg_vn_att_master" value="N"/>
<c:forEach var="roles" items="${sessionScope.USER_SESSION.roleList}">
    <c:if test="${roles.systemCode=='LGVHR' && roles.moduleCode=='LGVATT' && fn:indexOf(roles.roleCode,'VN_LINE_WORK_PIC_USER')>=0 }">
        <c:set var="flg_vn_line_worker_pic_user" value="Y"/>
    </c:if>  
    <c:if test="${roles.systemCode=='LGVHR' && roles.moduleCode=='LGVATT' && fn:indexOf(roles.roleCode,'VN_ATT_MASTER_USER')>=0 }">
        <c:set var="flg_vn_att_master" value="Y"/>
    </c:if>   
</c:forEach>

<html lang="ko">
<head>
<title><lgcom:message code="label.att.requestAttendanceModification"/></title>
<script src="/lgvhr/static/js/lgvatt.js"></script>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>

<script type="text/javascript">
var LGVATT20070 = function() {
	var _this = this;
	var requestInfoForm = new FormUtil(_this, ".requestInfo");
	var requestorForm = new FormUtil(_this, "._requestHeadForm_");
	var approverForm = new FormUtil(_this, "._approverForm_");	
	
	var viewType = '${param.viewType}';
	var returnPage = '${param.returnPage}';
	var requestNo = '${param.requestNo}';	
	
	var mode = isNull(viewType)?"VIEW" : viewType;
	
	var approvalCallFlag = nvl("<c:out value="${urlAddr.approval}"/>", "N");
	var isAttContract = '<c:out value="${flg_vn_line_worker_pic_user}"/>';  // 근태 담당자 여부 pic
	var isLgdOw = ('${sessionScope.LGVHR_PROJECT_SESSION.employmentCategoryCode}' === 'LGD_OW') ? 'Y':'N';
	/* 팝업용 변수 선언 */
	_this.popupInfo = {
		userPopup: {},		// 결재자
		userMultiPopup: {}	// 참조자
	};
	
	var orgList = [];
	var userList = [];
	
	var isApprovalComplete = false;
	var isHrMng = ('<c:out value="${flg_vn_att_master}"/>' == 'Y')?true:false;
	
	var isCheckOrg = function(arr, id){
		return arr.some(function(d){
			if(d.code == id){
				return true;
			}
			return false;
		})
	}
	
	var isCheckUser = function(arr, id){
		return arr.some(function(d){
			if(d.name == id){
				return true;
			}
			return false;
		})
	}
	
	if(isAttContract === 'Y'){
		//기능직 근태 담당자
		_this.transaction_sync("lgvhr", "lgvatt/LGVATT20070/retrieveAttContractOrg", {employeeNo : '${sessionScope.LGVHR_PROJECT_SESSION.employeeNo}'}, function(data) {
			//trace('retrieveAttContractOrg ', data );
			if ( data.result ) {
				orgList = data.result;
				
				if(isLgdOw === 'Y'){
					if(!isCheckOrg(orgList, '${sessionScope.LGVHR_PROJECT_SESSION.organizationId}')){
						orgList.push({code:'${sessionScope.LGVHR_PROJECT_SESSION.organizationId}', name:'${sessionScope.USER_SESSION.organizationName}'});					
					}
				}
			}
		});			
		
	}else{
		orgList.push({code:'${sessionScope.LGVHR_PROJECT_SESSION.organizationId}', name:'${sessionScope.USER_SESSION.organizationName}'});		
		userList.push({name:'${sessionScope.LGVHR_PROJECT_SESSION.userName}', code:'${sessionScope.USER_SESSION.userName}', organizationId:'${sessionScope.LGVHR_PROJECT_SESSION.organizationId}'})
	} 

	var requestMasterId = isNull('<c:out value="${urlAddr.requestMasterId}"/>')?(isNull('${param.approvalRequestId}')?'':'${param.approvalRequestId}'):'<c:out value="${urlAddr.requestMasterId}"/>';
	var requestCode = isNull('<c:out value="${urlAddr.requestCode}"/>')? (isNull('${param.requestCode}')?'':'${param.requestCode}') : '<c:out value="${urlAddr.requestCode}"/>';
	

	requestorForm.setValue({'requestMasterId':requestMasterId,'requestCode':requestCode});

	// 화면 레이아웃 정의(결재선 셋팅 후 화면 레이아웃 확정되기 때문에 마지막에 셋팅한다.)
	_this.setLayout([		   
		{ name : "controls",      left : 0, right : 0, top : '0'  },
		{ name : "requestorInfo", left : 0, right : 0, top : "controls", height : 100 },
		{ name : "gridContent",   left : 0, right : 0, top : "requestorInfo", height : 400 },
		{ name : "approvalArea",  left : 0, right : 0, top : "gridContent", bottom : 0 }
	]);
	
    // 코드 데이터 조회(그리드 콤보 셋팅하기 위해 사용함.)
	// combo 목록 조회
	var code = new CommonCode("lgcom");
	code.add( "LGVHR_DAY_NIGHT_FLAG", {codeTypeCode:'LGVHR_DAY_NIGHT_FLAG'} );
	code.add( "LGCOM_YN_FLAG",        {codeTypeCode:'LGCOM_YN_FLAG'} );
	code.add( "workStartTm",          {codeTypeCode:'LGVHR_ATT_WORK_START_TIME'});	
	code.execute();
	

    // 그리드 초기화
    var grid = buildGrid(".modifyGrid");
    var gridView = grid.getGridBase();
    var provider = grid.getDataProvider();
    
    <%-- 결재화면 호출로직 추가 start --%>
	/* 통합결재 연동 관련 코드 */
	var approvalInfo = {
		init : function(param) {

// 			trace("approval=-==>" + $.trim('<c:out value="${urlAddr.approval}"/>'));
// 			trace("requestMasterId=-==>" + $.trim('<c:out value="${urlAddr.jobKeyId}"/>'));
// 			trace("requestCode=-==>" + $.trim('<c:out value="${urlAddr.jobRequestCode}"/>'));
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
	_this.setApprovalInfo( approvalInfo );
    <%-- 결재화면 호출로직 추가 end --%>
    
    // 화면에 필요한 초기데이터 조회

    // 개인화조건
    
    // 조회조건 저장 처리
    _this.searchConditionControl( true );
    
    // 팝업 데이터 정의 searchMode:single(단수),multi(복수)

    // 그리드형 테이블 TR

    // 날짜 팝업창
    
    // 필수항목 체크
    
    // 일반함수	
    
	/*** 이벤트 핸들러  ***/
	// 버튼제어
	_this.addEvent('click','button[data-action]',function(event) {
		var action = $(this).data("action");   
		
		var itemIndex = gridView.getCurrent().itemIndex;	
		
		switch(action) {			
			case 'add':
				try {
					gridView.commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				/*
				grid 한개의 로우를 추가 한다.
				*/
		        var row = [];
		        provider.insertRow(0,row);
				
				//현재 행 위치를 지정해 주어야 rowChange event 에서 readonly 행에 대한 배경색 처리가 됨.
				gridView.setCurrent({itemIndex: 0, column:'employeeName'});
				
				
				// 근태 담당자가 아니면 자신 셋팅 나중에 처리 하자 (현재는 인사담당자가 처리 함)
				if(isAttContract !== 'Y'){
					// 사무직이 아닐경우
					var employeeValue = {
							employeeNo   : '${sessionScope.USER_SESSION.userName}',
							employeeName : '${sessionScope.USER_SESSION.fullNameLocal}',
							organizationId   : '${sessionScope.LGVHR_PROJECT_SESSION.organizationId}',
							organizationName : '${sessionScope.USER_SESSION.organizationName}'
					}
					gridView.setValues(0, employeeValue, true);					
					fncRetrieveARMInfo(requestInfoForm.getValue("armNo"))
					
				}else{				
					
					if(provider.getRowCount() != 1){
						//2번째 행부터 생성되는 
						var cnt = grid.getDataProvider().getRowCount();
						
						for(var i=0; i < cnt-1; i++){
							gridView.setCellStyle(i, "organizationName", "unableEdit", true);
							gridView.setValue(i, "organizationName", gridView.getValue(cnt-1, "organizationName"));
						}	
					}else{
						
						gridView.setCellStyle(0, "organizationName", "editableStyle", true);
					}
					
				}
				
				var editableStyle = "editableStyle";	
				for(var i=0; i < controlColumns.editColumn.length; i++){
					gridView.setCellStyle(0, controlColumns.editColumn[i], editableStyle, true);
				}
				gridView.setFocus();
				gridView.commit( true );
				
				break;
			case 'delete':
				try {
					gridView.commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				if(provider.getRowCount() == 0){
					Message.alert('row is count 0');
					return false;
				}			
								
				provider.setOptions({softDeleting:false});//softDeleting:true인 경우 행삭제되지 않고, 행구분만 삭제로 변경되므로, 화면에서 행 삭제하기 위해 false로 변경함	
				
				if(grid.getGridBase().getCurrent().itemIndex != grid.getDataProvider().getRowCount()-1) {
					gridView.deleteSelection(true);	
				}
				
				//fncSaveSpecialOt('delete');
				break;
			case 'request':
				// 결재요청
				if(fncValidateSaveRequestInfo()) {
					fncSaveSpecialOt('request');
				}
				break;
			case 'goList' :
				var nav = new Navigate( _this, "lgvhr", "${param.returnPage}" );
		        nav.addNavigationCallback( function( caller ){
		            myForm.select("button[data-action=search]").trigger('click');
		        });
		        nav.goPageInCurrentDiv(false);
		        break;
			case 'save':
				fncSaveSpecialOt('save');
				break;
		}
	});
	/*** 내부 함수  ***/
	
	var controlColumns = {	                      
	                    	 editColumn : ["employeeNo","timeAndAttendanceDate","workStartTime", "workEndTime", "timeAttendInputReasonDesc","overtimeSumHours", 
	                    	               "weekdayOvertimeHours", "holidayOvertimeHours", "publicHolidayOvertimeHours", "weekdayNightOvertimeHours",
	                        	            "weekdayOtAfNightWorkHours", "holidayNightOvertimeHours", "publicHolidayNightOtHours" ], /* 사용자가 입력 가능한 after 컬럼명 */
	                    	 hrmanagerColumn: [ "weekdayOvertimeHours", "holidayOvertimeHours", "publicHolidayOvertimeHours", "weekdayNightOvertimeHours",
		                        	            "weekdayOtAfNightWorkHours", "holidayNightOvertimeHours", "publicHolidayNightOtHours" ]
               	            
	                    
	                     };
    // 그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(_this, gridId, {statusBar : "N"});
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
				edit: {
					insertable: true,
					appendable: true,
					updatable: true,
					deletable: true
				},
				header: {height: 50, heightFill: 'fixed', showTooltip: true},
				fixed: { colCount: 3, resizable:true }
			},
			display: { fitStyle: 'none' }
		});
		
		grid.getGridBase().setSortingOptions({
			enabled: false
		});
		
		//필드 설정
		grid.setFields(
				[
					
					{ fieldName:'organizationName'          , dataType:'text'  },
					{ fieldName:'organizationId'            , dataType:'text'  },
					{ fieldName:'employeeNo'	     	    , dataType:'text'  },
					{ fieldName:'employeeName'			    , dataType:'text'  },
					{ fieldName:'timeAndAttendanceDate'	    , dataType:'text'  },
					{ fieldName:'shiftTypeCode'             , dataType:'text'  },
					{ fieldName:'shiftTypeName'  		    , dataType:'text'  },
					{ fieldName:'nightShiftFlag'            , dataType:'text'  },					
					{ fieldName:'workStartTime'             , dataType:'text'  },
					{ fieldName:'workEndTime'             	, dataType:'text'  },
					{ fieldName:'timeAttendInputReasonDesc' , dataType:'text'  },
					{ fieldName:'overtimeSumHours'          , dataType:'number'},
					{ fieldName:'attendanceName'            , dataType:'text'  },//HMT_20210410
					{ fieldName:'monthTotalOvertime'        , dataType:'number'},//HMT_20210410
					{ fieldName:'overtimeLimit'             , dataType:'number'},//HMT_20210410
					{ fieldName:'weekdayOvertimeHours'      , dataType:'number'},
					{ fieldName:'holidayOvertimeHours'      , dataType:'number'},
					{ fieldName:'publicHolidayOvertimeHours', dataType:'number'},
					{ fieldName:'weekdayNightOvertimeHours' , dataType:'number'},
					{ fieldName:'weekdayOtAfNightWorkHours' , dataType:'number'},
					{ fieldName:'holidayNightOvertimeHours' , dataType:'number'},
					{ fieldName:'publicHolidayNightOtHours' , dataType:'number'},
					{ fieldName:'holidayFlag'               , dataType:'text'  }
					
				]
		);
		//컬럼 콤보 셋팅
		grid.setLookupsMultiLvl({
	                             
	                             "nightShiftFlag":code.get("LGVHR_DAY_NIGHT_FLAG"),
	                             "organizationList":{data:orgList,keyField:["code"]},	                             
	                             "workStartTime":{data:code.get("workStartTm"), keyField:["code"]},
	                             "userList":{data:userList, keyField:["organizationId", "code"]},
// 	                             "timeAttendDetailCode":{data:valueset.get("attendanceDetailCodeList"), keyField:["attendanceCode", "code"]}
			                   });
		//컬럼 설정 
		grid.setColumns(
				[
					{	name:'organizationName',
						fieldName:'organizationName',
						width:250,
						header: {text:'<lgcom:message code="label.att.organization"/>'},
						styles: {textAlignment:'near', background:gridReadOnyBgColor},
						lookupDisplay: true,
						lookupSourceId: 'organizationList',
						lookupKeyFields: ["organizationName"],
						editor: {type:'dropDown',textReadOnly:true},						
						editable:false
					},					
					{	name:'employeeNo',
						fieldName:'employeeNo',
						width:70,
						header: {text:'<lgcom:message code="label.att.id"/>'},						
						styles: {textAlignment:'center', background:gridReadOnyBgColor},						
						editor: {type:'dropDown',textReadOnly:true},
						lookupDisplay: true,
						lookupSourceId: 'userList',
						lookupKeyFields: ["organizationName","employeeNo"],
						editable:false
					},
					{	name:'employeeName',
						fieldName:'employeeName',
						width:120,
						header: {text:'<lgcom:message code="label.att.employeeName"/>'},
						styles: {
							textAlignment:'near', 
							background:gridReadOnyBgColor,							
							},
													
						editable: false,						
					},
					{	name:'timeAndAttendanceDate',
						fieldName:'timeAndAttendanceDate',
						width:80,
						header: {text:'<lgcom:message code="label.att.date"/>'},
						styles: {textAlignment:'center', background:gridReadOnyBgColor},						
						editor: {type:'date',datetimeFormat:'dd/MM/yyyy'},
						editable: false
					},
					{	name:'attendanceName',
						fieldName:'attendanceName',
						width:100,
						header: {text:'<lgcom:message code="label.att.actualAttendanceDetail"/>'},
						styles: {textAlignment:'near', background:gridReadOnyBgColor},						
						editable: false
					},
					{	name:'shiftTypeName',
						fieldName:'shiftTypeName',
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
						lookupSourceId: 'nightShiftFlag',
						lookupKeyFields: ['nightShiftFlag'],
						editor: {type:'dropDown',textReadOnly:true},
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
										lookupSourceId: 'workStartTime',
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
										lookupSourceId: 'workStartTime',
										lookupKeyFields: ['workEndTime'],
										editor: {type:'dropDown',textReadOnly:true},
										editable: false
									},
									{	name:'overtimeSumHours',
										fieldName:'overtimeSumHours',
										width:50,
										header: {text:'<lgcom:message code="label.att.totalOT"/>'},
										styles: {textAlignment:'far', numberFormat: '#0.0', background:gridReadOnyBgColor},
										editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
										editable: false
									},
								]
					},
					//HMT_20210410 Start
					{	name:'monthTotalOvertime',
						fieldName:'monthTotalOvertime',
						width:50,
						header: {text:'<lgcom:message code="label.att.monthTotalOT"/>'},
						styles: {textAlignment:'far', background: gridReadOnyBgColor, numberFormat: '#0.0'},
						editable: false
					},
					{	name:'overtimeLimit',
						fieldName:'overtimeLimit',
						width:50,
						header: {text:'<lgcom:message code="label.att.monthOtLimit"/>'},
						styles: {textAlignment:'far', background: gridReadOnyBgColor, numberFormat: '#0.0'},
						editable: false
					},
					//HMT_20210410 End
					{	name:'timeAttendInputReasonDesc',
						fieldName:'timeAttendInputReasonDesc',
						width:250,
					    renderer: {showTooltip: true},
						header: {text:'<lgcom:message code="label.att.timeAttendInputReasonDesc"/>'},
						styles: {textAlignment:'near', background:gridReadOnyBgColor},					    		
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
										editable: false
									},
									{	name:'holidayOvertimeHours',
										fieldName:'holidayOvertimeHours',
										width:50,
										header: {text:'<lgcom:message code="label.att.actualOTWeekDayHoliday2" />', tooltip:'<lgcom:message code="label.att.actualOTWeekDayHoliday"/>'},
										styles: {textAlignment:'far', numberFormat: '#0.0', background:gridReadOnyBgColor},
										editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
										editable: false
									},
									{	name:'publicHolidayOvertimeHours',
										fieldName:'publicHolidayOvertimeHours',
										width:50,
										header: {text:'<lgcom:message code="label.att.actualOTPublicHoliday2" />', tooltip:'<lgcom:message code="label.att.actualOTPublicHoliday"/>'},
										styles: {textAlignment:'far', numberFormat: '#0.0', background:gridReadOnyBgColor},
										editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
										editable: false
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
										editable: false
									},
									{	name:'weekdayOtAfNightWorkHours',
										fieldName:'weekdayOtAfNightWorkHours',
										width:50,
										header: {text:'<lgcom:message code="label.att.actualOTNightWeekDayAfterOT2" />', tooltip:'<lgcom:message code="label.att.actualOTNightWeekDayAfterOT"/>'},
										styles: {textAlignment:'far', numberFormat: '#0.0', background:gridReadOnyBgColor},
										editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
										editable: false
									},
									{	name:'holidayNightOvertimeHours',
										fieldName:'holidayNightOvertimeHours',
										width:50,
										header: {text:'<lgcom:message code="label.att.actualOTNightWeekDayHoliday2" />', tooltip:'<lgcom:message code="label.att.actualOTNightWeekDayHoliday"/>'},
										styles: {textAlignment:'far', numberFormat: '#0.0', background:gridReadOnyBgColor},
										editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
										editable: false
									},
									{	name:'publicHolidayNightOtHours',
										fieldName:'publicHolidayNightOtHours',
										width:50,
										header: {text:'<lgcom:message code="label.att.actualOTNightPublicHoliday2" />', tooltip:'<lgcom:message code="label.att.actualOTNightPublicHoliday"/>'},
										styles: {textAlignment:'far', numberFormat: '#0.0', background:gridReadOnyBgColor},
										editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'},
										editable: false
									}
								]
					    
					},				
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
	grid.getGridBase().addCellStyle("unableEdit", {
		background: '#e9e9e9',
		editor: {type: 'text'},
		editable: false
	});
	
	
	
  	gridView.onValidateColumn  = function(cgrid, column, inserting, value){	
		if(column.editor === 'number'){			
			if(value % 0.5 > 0){
				/* var error = {};
				error.level = "warning";					
				error.message = '<lgcom:message code="note.att.latenessInputFault" />';//Message.alert('<lgcom:message code="note.att.latenessInputFault" />');
				return error; */
				Message.alert('<lgcom:message code="note.att.latenessInputFault" />');
				grid.cancel();
			}	
		}	
	}
	
	gridView.setEditOptions({commitLevel:"info"});
	
	grid.getGridBase().onCurrentRowChanged = function (grid, oldRow, newRow) {
		var columns = grid.getColumnNames();
		
		
		

	};
	
	//날짜 셀 클릭 시 수정 가능여부를 판단한다.
	grid.getGridBase().onDataCellClicked =  function (cgrid, index) {
		var itemIndex = cgrid.getCurrent().itemIndex;
		var clickedFieldName = index.column;
		

	};
   
    gridView.onEditChange = function (grid, index, value) {
    	var itemIndex = index.itemIndex
	    if(index.fieldName == "timeAndAttendanceDate"){
	    	if(isNull(gridView.getValue(itemIndex, 'employeeNo')) || isNull(gridView.getValue(itemIndex, 'employeeName'))){
	    		
	    		Message.alert('<lgcom:message code="error.requiredOr" arguments="<lgcom:message code='label.att.employeeName'/>,<lgcom:message code='label.att.id'/>"/>', function(){	 
	    			grid.cancel();
	    		});
	    		
    			gridView.setCurrent({itemIndex : itemIndex, column : 'employeeName'});
    			gridView.setValue(itemIndex, index.fieldName, '');
    			gridView.setFocus();
	    		return;
	    	}else{
	    		try {
		        	grid.commit();
		        } catch(e) {
		            trace(e.message);
		        }
	    	}
        
	    }else if(index.fieldName == "employeeNo"){
	    	try {
	        	grid.commit();
	        } catch(e) {
	            trace(e.message);
	        }
	    	//trace('emp :', gridView.getValue(itemIndex, 'employeeNo'));
	    	
	    }else if(index.fieldName == 'organizationName'){
	    	try {
	        	grid.commit();
	        } catch(e) {
	            trace(e.message);
	        }
	    }

	};
	
    gridView.onEditCommit = function(grid, index, oldValue, newValue){
    	
    }
    
    gridView.onCellEdited = function(grid, itemIndex, dataRow, field){
    	grid.commit();
    	
    	var fieldName = provider.getOrgFieldName(field);
    	if(fieldName === 'timeAndAttendanceDate'){

    		for(var i=0; i<grid.getDataProvider().getRowCount(); i++) {
    			if((grid.getValue(itemIndex, fieldName) == grid.getValue(i, fieldName) && i != itemIndex) && 
    					(grid.getValue(itemIndex, 'employeeNo') == grid.getValue(i, 'employeeNo') && i != itemIndex)) {
    				Message.alert("<lgcom:message code='note.att.dupUser'/>");
    				grid.setValue(itemIndex, fieldName, null);
    				return;
    			}
    		}
    		
    		//날짜 선택시 shiftTypeName, shiftTypeCode 처리 및 nightFlag 처리 
    		fncTimeAndattendanceDateChage(grid, itemIndex, fieldName);
    	}else if(fieldName === 'employeeNo'){
    		
    		fncRetrieveEmployeeName(itemIndex);
    		/* if(isAttContract === 'Y'){
    			fncRetrieveARMInfo(requestInfoForm.getValue("armNo"))
    		} */
    	}else if(fieldName === 'organizationName'){    		
    		fncRetrieveEmployeeNo(itemIndex);
    	}
    	//Compare month ot total with month ot limit HMT_20210410 Start
	    else if(fieldName === 'overtimeSumHours'){    		
	    	var monthOtTotal     = grid.getValue(dataRow,  "monthTotalOvertime");
	    	var monthOtLimit     = grid.getValue(dataRow,  "overtimeLimit"); 
	    	var overtimeSumHours = grid.getValue(dataRow, fieldName);
    		if ( overtimeSumHours + monthOtTotal > monthOtLimit ) {
    			grid.setValue(dataRow, fieldName, 0);
				Message.alert("<lgcom:message code="note.att.OtExceedLevel"/>" + "! " + monthOtTotal + " + "+overtimeSumHours+" > " + monthOtLimit);
				_this.hideProgress();
				return ;
			}
		}
	  //HMT_20210410 End
    }
    
    var fncRetrieveEmployeeNo = function(itemIndex){
    	gridView.setValue(itemIndex, 'employeeNo','');
    	gridView.setValue(itemIndex, 'employeeName','');

    	for(var i=0; i<grid.getDataProvider().getRowCount()-1; i++) {
    		gridView.setValue(i, "organizationName", gridView.getValue(itemIndex, "organizationName"));
    		gridView.setValue(i, 'employeeNo','');
        	gridView.setValue(i, 'employeeName','');
    	}
    	_this.showProgress()
    	_this.transaction("lgvhr", "lgvatt/LGVATT20070/retrieveEmployeeNo", {orgId: gridView.getValue(itemIndex, 'organizationName')}, function(data){
//     		trace('retrieveEmployeeNo ', data);
    		if(data.result.length > 0){
    			var lookups = data.result.map(function(d){
    				return [d.organizationId, d.code, d.code ];
    			});
    			
    			gridView.fillLookupData("userList", {
                    rows: lookups
                });
    			
    			fncRetrieveARMInfo(requestInfoForm.getValue("armNo"), data.result[0].orgGetArmInfo);
    		}
    		_this.hideProgress();
    	});
    }
    
    var fncRetrieveEmployeeName = function(itemIndex){
    	_this.transaction("lgvhr", "lgvatt/LGVATT20070/retrieveEmployeeName", {employeeNo: gridView.getValue(itemIndex, 'employeeNo')}, function(data){
//     		trace('retrieveEmployeeName ', data);
    		if(data.result){
    			gridView.setValue(itemIndex, 'employeeName', data.result.employeeName);
    		}
    	});
    }    
	
	function fncTimeAndattendanceDateChage(grid, itemIndex, fieldName){
		
		var attendanceDate = gridView.getValue(itemIndex,fieldName);		
		var employeeNo = gridView.getValue(itemIndex, 'employeeNo');
		
		var param = {
			subsidiaryCode : '${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}',
			attendanceDate : attendanceDate, 
			employeeNo : employeeNo
		};
		
		_this.showProgress();
		transaction_sync("lgvhr", "lgvatt/LGVATT20070/retrieveDupData", param, function(data) {
			if(data.result.dupCount > 0) {
				gridView.setValue(itemIndex, fieldName, null);
				gridView.setValue(itemIndex, 'shiftTypeCode', null);
				gridView.setValue(itemIndex, 'shiftTypeName', null);
				gridView.setValue(itemIndex, 'attendanceName', null);
				gridView.setValue(itemIndex, 'nightShiftFlag', null);
				
				Message.alert("<lgcom:message code='note.att.specialOTdupChk'/>");
			} else {
				transaction("lgvhr", "lgvatt/LGVATT20070/retrieveShftTypeAndNightFlag", param, function(data){
					if(data.result){
						if(data.result.shiftData){
							gridView.setValue(itemIndex, 'shiftTypeCode', data.result.shiftData.shiftTypeCode);
							gridView.setValue(itemIndex, 'shiftTypeName', data.result.shiftData.shiftTypeName);
							gridView.setValue(itemIndex, 'attendanceName', data.result.shiftData.attendanceName);
							gridView.setValue(itemIndex, 'nightShiftFlag', data.result.shiftData.nightShiftFlag);
							gridView.setValue(itemIndex, 'monthTotalOvertime', data.result.shiftData.monthTotalOvertime); //HMT_20210410
							gridView.setValue(itemIndex, 'overtimeLimit', data.result.shiftData.overtimeLimit); //HMT_20210410
							//gridView.setValue(itemIndex, 'holidayFlag', data.result.shiftData.holidayFlag);
							
							var editableStyle = "editableStyle";					
							for(var i=0; i < controlColumns.editColumn.length; i++){
								grid.setCellStyle(itemIndex, controlColumns.editColumn[i], editableStyle, true);
							}
						}
					}
				});
			}
			_this.hideProgress();
		}); 
		
	}
	
	/* 그리드 특정 행의 값을 모두 지우는 함수 */
	function fncClearGridRow( itemIndex, provider ) {
		var fieldNames = provider.getOrgFieldNames();
		if ( itemIndex > -1 && itemIndex < provider.getRowCount() ) {
			for ( var i=0; i<fieldNames.length; i++ ) {
				// Old, New 구분 컬럼을 제외하고 공백으로 초기화 
				if ( controlColumns["oldNewTypeColumn"].indexOf(fieldNames[i]) == -1 ) {
					if ( fieldNames[i] == "eveningMealFlag" ) {//석식여부는 기본값을 N으로 한다.
						provider.setValue(itemIndex, fieldNames[i], "N");
					} else {
						provider.setValue(itemIndex, fieldNames[i], null);
					}
				}
			}//end-for
		}//end-if
	}
	//값 초기화
	
	//공통의 결재자 정보 조회 기능 사용
	function fncRetrieveApprovalLineList() {
		_this.showProgress();
		transaction_sync("lgvhr",'common/requestForm/retrieveApprovalLineList', {requestMasterId:approvalRequestId, requestCode:requestCode}, function(data) {
			if(data.result) {
				var list = data["result"];			
				_this.select(".approvalInfoTable tbody").empty();
				$(list).each( function(){
					this["settlementDeleteFlag"] = "Y";
					fncAppendTableRow( "approvalInfoTable", this );
				});
			}
			_this.hideProgress();
		});
	}
	//재량권 조회
	function fncRetrieveARMInfo( armNo, orgGetArmInfo ) {
		/* 재랑권 정보 조회. parameter[armNo:재량권번호]  */
		
		var param = {};
		var itemIndex = gridView.getCurrent().itemIndex;
		
		if(orgGetArmInfo != null) {
			param.employeeNo = orgGetArmInfo;
		} else {
			if(provider.getRowCount() > 0){
				param.employeeNo = gridView.getValue(itemIndex, 'employeeNo');
			}else{
				param.employeeNo = '${sessionScope.LGVHR_PROJECT_SESSION.employeeNo}';
			}
		}
		
		param.armNo = armNo;
		
		_this.transaction("lgvhr", "lgvatt/LGVATTCOMM/retrieveARMInfo", param , function( data ){
			var list = data["result"];			
			_this.select(".approvalInfoTable tbody").empty();
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

		var userName = item["employeeName"] + " / " + nvl(item["titleName"]) + " / " +item["departmentName"] ;
		var mendator = nvl( item["mendatorEmployeeName"] ) + " / " + nvl( nvl(item["mendatorTitleName"]) ) + " / " + nvl( item["mendatorDepartmentName"] ) ;

		if( mendator.trim() == "/  /" ) {
			mendator = "";
		}

		if( item["settlementDeleteFlag"] == undefined ) {
			item["settlementDeleteFlag"] = "N";
		}

		if( target == "approvalInfoTable" ) {
			var body = _this.select(".approvalInfoTable tbody");
			//이미 이 안에 추가된 경우에는 추가하지 않고 끝
			if( body.find("input[name='applicationUserId'][value='" + item["userId"] + "']").exists() ) {
				Message.alert( item["employeeName"] + "<lgcom:message code="note.accountAlreadyExists"/>" );
				return;
			}
			
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
		} 
		fncManageButton();
	}
	/* Delete 버튼 류는 필요한 시점이 아니면,  Disabled 돼야 하는 상황이라, table 에 기반한 이 버튼의 움직임을 */
	function fncManageButton() {
		_this.select(".approvalInfoTable tbody tr:first-child .delete").hide();

		if( _this.select(".approvalInfoTable tbody tr").length > 1 ) {
			_this.select(".approvalInfoTable .delete").show();
		}
	}
	//요청전 입력값 체크
	function fncValidateSaveRequestInfo() {
		var dataProvider = grid.getDataProvider();
		var cgrid = grid.getGridBase();					
		
		//행추가로 강제 생성된 행이기 때문에 행 상태는 created
		var rowIdxs = dataProvider.getStateRows("created");
		if ( rowIdxs ) {
			for ( var i=0; i<rowIdxs.length; i++ ) {
				var rowData = dataProvider.getJsonRow(rowIdxs[i]);
				
				//사원 선택 없는 경우 오류
				if ( isNull(rowData["employeeName"]) ) {
					Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.id'/>"/>');
					cgrid.setCurrent({itemIndex: rowIdxs[i], column:'employeeNo'});
					cgrid.setFocus();
					return false;
				}
				
				//date 선택 없는 경우 오류
				if ( isNull(rowData["timeAndAttendanceDate"]) ) {
					Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.date'/>"/>');
					cgrid.setCurrent({itemIndex: rowIdxs[i], column:'timeAndAttendanceDate'});
					cgrid.setFocus();
					return false;
				} 
				
				//workStartTime 선택 없는 경우 오류
				if ( isNull(rowData["workStartTime"]) ) {
					Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='StartTime'/>"/>');
					cgrid.setCurrent({itemIndex: rowIdxs[i], column:'workStartTime'});
					cgrid.setFocus();
					return false;
				} 
				
				//workEndTime 선택 없는 경우 오류
				if ( isNull(rowData["workEndTime"]) ) {
					Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='EndTime'/>"/>');
					cgrid.setCurrent({itemIndex: rowIdxs[i], column:'workEndTime'});
					cgrid.setFocus();
					return false;
				} 
				
				//total O/T 선택 없는 경우 오류
				if ( isNull(rowData["overtimeSumHours"]) ) {
					Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.totalOT'/>"/>');
					cgrid.setCurrent({itemIndex: rowIdxs[i], column:'overtimeSumHours'});
					cgrid.setFocus();
					return false;
				} 
				//Total O/T must be equal to total component HMT_20210410 Start
				var otPlan = rowData["overtimeSumHours"];
				var weekdayOvertimeHours = isNull(rowData["weekdayOvertimeHours"]) ? 0 : rowData["weekdayOvertimeHours"];
				var holidayOvertimeHours = isNull(rowData["holidayOvertimeHours"]) ? 0 : rowData["holidayOvertimeHours"];
				var publicHolidayOvertimeHours = isNull(rowData["publicHolidayOvertimeHours"]) ? 0 : rowData["publicHolidayOvertimeHours"];
				var weekdayNightOvertimeHours = isNull(rowData["weekdayNightOvertimeHours"]) ? 0 : rowData["weekdayNightOvertimeHours"] ;
				var weekdayOtAfNightWorkHours = isNull(rowData["weekdayOtAfNightWorkHours"]) ? 0 : rowData["weekdayOtAfNightWorkHours"] ;
				var holidayNightOvertimeHours = isNull(rowData["holidayNightOvertimeHours"]) ? 0 : rowData["holidayNightOvertimeHours"] ;
				var publicHolidayNightOtHours = isNull(rowData["publicHolidayNightOtHours"]) ? 0 : rowData["publicHolidayNightOtHours"];
				var otActual = weekdayOvertimeHours + holidayOvertimeHours + publicHolidayOvertimeHours + weekdayNightOvertimeHours 
							   + weekdayOtAfNightWorkHours + holidayNightOvertimeHours + publicHolidayNightOtHours;
				if ( otPlan != otActual ) {
					Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.totalOTMustEqualComponent'/>"/>');
					cgrid.setCurrent({itemIndex: rowIdxs[i], column:'overtimeSumHours'});
					cgrid.setFocus();
					return false;
				} 
				//HMT_20210410 End
			}
		}
		return true;
	}
	
	// 요청처리
	/*
		그리드 데이터 체크 
		요청 정보 같이 파라미터로 보낸다.
	*/
	function fncSaveSpecialOt(requestType){
		try {
			grid.getGridBase().commit();
		} catch(e) {
			Message.alert(e.message);
			return;
		}
		
		// 데이터 유무 체크		
		// 변경건이 있는지 체크
		if( !grid.isChanged() ) {
			Message.alert('<lgcom:message code="error.noChangedData"/>');
			return;
		}else{
			if( grid.getRowCount() == 0 ) {
				Message.alert('<lgcom:message code="note.nodata"/>');
				return;
			}
		}
		
		//결재자 체크
		if(requestType == 'request'){
			if( _this.select(".approvalInfoTable tr.ARM_Y").length == 0 ) {
				Message.alert("<lgcom:message code="note.checkApprovalInformation"/>");
				return;
			}	
		}
		
		var param = {
				requestorData : requestorForm.getValue(),
				approvalData : fncArrangeMultiLine( approverForm.getValue(), "applicationUserId")
		};	
		
		var callUrl = '';
		var cMsg = ''
		if(requestType == 'request'){
			callUrl = 'lgvatt/LGVATT20070/saveApprovalRequest';
			cMsg = "<lgcom:message code="question.ApprovalRequest" />";
		}else{
			callUrl = 'lgvatt/LGVATT20070/saveSpecialOt';
			cMsg = "<lgcom:message code="question.att.requestSave" />"
		}
		
		Message.confirm(cMsg, function(){
			_this.showProgress();
			grid.saveChanges("lgvhr", callUrl, param, function(data){					
				Message.alert("<lgcom:message code="note.saved" />", function(){
					
					if(requestType == 'request'){
						requestorForm.clear();
						grid.clear();
						//Approval 영역의 초기상태를 두고, 모두 지운다.
						_this.select(".approvalInfoTable tbody tr").remove();
						approverForm.clear();
						
						//신규화면으로 재 셋팅
						fncRetrieveInitData();
					}else{
						grid.clear();
						//Approval 영역의 초기상태를 두고, 모두 지운다.
						_this.select(".approvalInfoTable tbody tr").remove();
						approverForm.clear();
						// 조회된 화면으로 재 셋팅
						fncRetrieveDetailInitData(); // 헤더 정보 가져온다.
						searchSpecialOt();  // 파라미터에 맞게끔 조회 한다.
					}
					
					_this.hideProgress();
				});
			});
		}, function(){
			// 취소
			_this.hideProgress();
		});
		
	}
	
	<%-- 공통 결재에서 호출되는 경우 사용함 --%>
	//결재에서 호출된경우 요청서 데이터 조회
	
	function fncRetrieveRequestContent() {
		//요청서 버튼, 요청자정보, 결재자 정보 숨김
		_this.select(".controls").hide();
		_this.select(".requestorInfo").hide();
		_this.select(".clearfix").hide();
		_this.select(".approvalArea").hide();
		
		
		_this.setLayout( [
			{ name  : "gridContent", left : 0, right : 0, top : 0, bottom : 0 },
		]);
// 		trace('requestorForm.getValue() ', requestorForm.getValue());
		_this.showProgress();
		grid.loadData("lgvhr", "lgvatt/LGVATT20070/retrieveSpecialOt", requestorForm.getValue(), function (data) {
			var editableStyle = "editableStyle";			
			if(data.result){				
				if(!isNull(viewType) && nvl(viewType) === 'NEW'){
					data.result.forEach(function(d, index){
						for(var i=0; i < controlColumns.editColumn.length; i++){
							grid.setCellStyle(index, controlColumns.editColumn[i], editableStyle, true);
						}	
					});
				}else if(isNull(viewType)){
					data.result.forEach(function(d, index){
						for(var i=0; i < controlColumns.editColumn.length; i++){
							grid.setCellStyle(index, controlColumns.editColumn[i], editableStyle, true);
						}	
					})
				}
				
				
			}
		});
		grid.getGridBase().setEditOptions({readOnly:true});//비활성화
		// 결재영역 높이 재지정
		_resizeDetailArea(_this.select('.gridContent').outerHeight(true));
		grid.getGridBase().resetSize();
		fncDetailBtnControl();
		_this.hideProgress();
	}
	
	// 결재 처리 Callback Function
	function fnApprovalOrRejectRequest(actionCode) {
		_this.showProgress();
		var returnValue = false;
		var param = {requestMasterId : requestorForm.getValue("requestMasterId")
				   , requestCode     : requestorForm.getValue("requestCode")
				   , approvalCommand : actionCode.toUpperCase()
				   , comment         : requestorForm.getValue("approvalComment")
		             };
			
		transaction_sync("lgvhr", "lgvatt/LGVATT20070/saveRequestApprovalOrReject", param, function(data) {
			if(data.result) {
				// 정상처리
				if($.trim(data.result['errorCode']) == 'S') {
					returnValue = true;
				} else {
					returnValue = false;
				}
				_this.hideProgress();
				if(!returnValue) {
					Message.alert(data.result['errorMsg']);
				}
				return returnValue;
			}
			_this.hideProgress();
		},function(error) {
			trace(error);
			_this.hideProgress();
		});
	}
	// Custom Button 제어 로직
	function fncControllButton() {
	}
	
	function searchSpecialOt(){
		// 상세 보기 일경우	
		var param = {
				requestNo : requestNo,
				requestMasterId : requestMasterId
		};			
		
		grid.loadData("lgvhr", "lgvatt/LGVATT20070/retrieveSpecialOt",param, function(data){			
			var editableStyle = "editableStyle";			
			if(data.result){				
				if(!isNull(viewType) && nvl(viewType) === 'NEW'){
					data.result.forEach(function(d, index){
						for(var i=0; i < controlColumns.editColumn.length; i++){
							grid.setCellStyle(index, controlColumns.editColumn[i], editableStyle, true);
						}	
					});
				}else if(isNull(viewType)){
					data.result.forEach(function(d, index){
						for(var i=0; i < controlColumns.editColumn.length; i++){
							grid.setCellStyle(index, controlColumns.editColumn[i], editableStyle, true);
						}	
					})
				}
				
				
			}
			
		});
	}
	
	<%-- //공통 결재에서 호출되는 경우가 아닐때 사용함 --%>
	//화면 초기데이터 조회
	function fncRetrieveInitData() {
		// 요청자및 요청상태 정보 셋팅		
		_this.showProgress();
		_this.transaction_sync("lgvhr",'common/requestForm/retrieveRequestHeadInfo',requestorForm.getValue(), function(data) {
			if(data.result) {				
				requestorForm.setValue(data.result);			
			}
			//조회 초기 셋팅, 요청서 셋팅
			_this.transaction("lgvhr", "lgvatt/LGVATT20070/retrieveInitData", requestInfoForm.getValue(), function(data) {
				if(data.result){
					var reqDocBaseInfo = data.result.reqDocBaseInfo;
					var approvalMasterData = data.result.approvalMasterData;
					
					requestInfoForm.setValue({ armNo:reqDocBaseInfo["armNo"] });
					requestorForm.setValue({ requestCode:reqDocBaseInfo["requestCode"],
											 requestTitle:approvalMasterData["requestTitle"]});
					
					// 재량권 or 결재선 셋팅
					// 요청서 ID가 없으면 재량권 조회 , 
					_this.select(".approvalInfoTable").show();
					_this.select(".approvalInfoTableView").hide();
					isNull(requestInfoForm.getValue("requestMasterId"))?fncRetrieveARMInfo(requestInfoForm.getValue("armNo")):fncRetrieveApprovalLineList();
					_this.hideProgress();
				}
			});		
		});
	}
	
	function fncDetailBtnControl(){

		_this.select('button[data-action="add"]').hide();
		_this.select('button[data-action="delete"]').hide();
		_this.select('button[data-action="request"]').hide();
		
		if(isHrMng && isApprovalComplete){			
			_this.select('button[data-action="save"]').show();
			var editableStyle = "editableStyle";
			var gCnt = provider.getRowCount();
			for(var i=0; i < gCnt; i++){
				controlColumns.hrmanagerColumn.forEach(function(d){
					gridView.setCellStyle(i, d, editableStyle, true);
				})				
			}
			
		}else{			
			_this.select('button[data-action="save"]').hide();
		}
		// 체크박스도 없앤다.
		gridView.setCheckBar({
			  visible: false  
		});
	}
	
	function fncRetrieveDetailInitData(){
		// 요청자및 요청상태 정보 셋팅		
		_this.showProgress();
		_this.transaction_sync("lgvhr",'common/requestForm/retrieveRequestHeadInfo',requestorForm.getValue(), function(data) {
			if(data.result) {				
				requestorForm.setValue(data.result);			
			}
			//조회 초기 셋팅, 요청서 셋팅
			_this.transaction("lgvhr", "lgvatt/LGVATT20070/retrieveInitData", requestInfoForm.getValue(), function(data) {
				if(data.result){
					var reqDocBaseInfo = data.result.reqDocBaseInfo;
					var approvalMasterData = data.result.approvalMasterData;
					
					requestInfoForm.setValue({ armNo:reqDocBaseInfo["armNo"] });
					requestorForm.setValue({ requestCode:reqDocBaseInfo["requestCode"],
						 					 requestTitle:approvalMasterData["requestTitle"]});
				
					
					// 재량권 or 결재선 셋팅
					// 요청서 ID가 없으면 재량권 조회 , 
					_this.select(".approvalInfoTable").show();
					_this.select(".approvalInfoTableView").hide();
					isNull(requestInfoForm.getValue("requestMasterId"))?fncRetrieveARMInfo(requestInfoForm.getValue("armNo")):fncRetrieveApprovalLineList();
					
					_this.transaction("lgvhr", "lgvatt/LGVATT20070/retrieveApprovalStatus", requestorForm.getValue(), function(data) {
// 						trace('retrieveApprovalStatus : ', data);
						isApprovalComplete = (data.result.approvedFlag === 'N')?false:true;
						fncDetailBtnControl();
					})
				}
			});
			
				
		});
	}
	
	// 화면 로드 후 실행 시작
	_this.myFormInit = function(){
		// 통합결재에서 호출될 경우가 아닐때만 초기 데이터 조회
		if(approvalCallFlag !== 'Y'){
			if(!isNull(viewType) && nvl(viewType) === 'NEW'){
				//신규 요청
				fncRetrieveInitData();
				_this.select('button[data-action="save"]').hide();
			}else if(!isNull(viewType) && nvl(viewType) === 'DETAIL_VIEW'){
				// 상세보기
				fncRetrieveDetailInitData(); // 헤더 정보 가져온다.
				searchSpecialOt();  // 파라미터에 맞게끔 조회 한다.
				
				
			}
		}else{
			_this.select('button[data-action="save"]').hide();
		}
		
		
		
		// 화면 레이아웃 정의(결재선 셋팅 후 화면 레이아웃 확정되기 때문에 마지막에 셋팅한다.)
		_this.setLayout([
			{ name : "searchBlock",   left : 0, right : 0, top : 0  },             
			{ name : "controls",      left : 0, right : 0, top : 'searchBlock'  },
			{ name : "requestorInfo", left : 0, right : 0, top : "controls", bottom : "gridContent" },
			{ name : "gridContent",   left : 0, right : 0, top : "requestorInfo", bottom : "approvalArea" },
			{ name : "approvalArea",  left : 0, right : 0, top : "gridContent", bottom : 0 }
		]);	
	}	
	
}

LGVATT20070.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVATT20070();
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
			<h2><lgcom:message code="label.att.requestAttendanceModification"/></h2>
		</div>	
		<%-- 버튼 --%>
	    <div class="controls module-group text-right">	
			<div class="btn-toolbar">
				<div class="btn-group">
					<button class="btn btn-default btn-sm" type="submit" data-action="goList"><lgcom:message code="List"/></button>
				</div>	
				<div class="btn-group">					
					<button class="btn btn-darkgray btn-sm" type="button" name="request" data-action="request"><lgcom:message code="button.att.submitRequest"/></button>
					<button class="btn btn-darkgray btn-sm" type="button" name="save" data-action="save"><lgcom:message code="save"/></button>
					<!-- button class="btn btn-default btn-sm" type="button" name="list" data-action="list"><lgcom:message code="list"/></button -->
				</div>
			</div>		
		</div>
		<form class="form requestInfo">
			<input type="hidden" name="requestDocCode" value="ATT0005" />
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
