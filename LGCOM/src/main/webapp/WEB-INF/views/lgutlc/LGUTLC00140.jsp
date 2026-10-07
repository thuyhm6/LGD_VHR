<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGUTLC00140.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 Batch Log Viewer를 조회하는 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Concurrent Viewer</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGUTLC00140 = function() {
	var myForm = this;
	
	var $dateFrom = myForm.select(".searchBlock input[name='dateFrom']");
	// 조회조건 Combo 초기화
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	formUtil.setCalendar( { from : "dateFrom", to : "dateTo" , language:SESSION_USER.languageCode } );
	
	/* 팝업용 변수 선언 */
	myForm.popupInfo = {
		userPopup: { searchMode:'single', departmentName:'', mailAddr:'', employeeNo:'', employeeName:'', userData:[] },
		programPopup: {}
	};
	/* 화면 레이아웃 정의 */
	/*
	myForm.setManagedLayout({
		searchBlock :{ left:0, top:0, right:0 },
		gridControls:{ left:0, top:DOUBLE_LINE.top1, right:0 },
		gridContent :{ left:0, top:DOUBLE_LINE.top2, right:0, bottom:0 }
	});
	*/
    /* Layout Setting */
	myForm.setLayout( [ 
		{ name : "searchBlock",  left : 0, right : 0, top : 0 },		
		{ name : "gridContent",  left : 0, right : 0, top : "searchBlock", bottom : 0 }		
    ]);	
	var isAdmin = false;
	// 조회조건 Combo 초기화
	var code = new CommonCode('lgcom');
	code.add('systemCode',{codeTypeCode:'LGCOM_SYSTEM_CODE'});
	code.add('moduleCode',{codeTypeCode:'LGCOM_MODULE_CODE'});
	code.add('alarmFlag',{codeTypeCode:'LGCOM_YN_FLAG'});
	code.add('checkFlag',{codeTypeCode:'LGCOM_YN_FLAG'});
	code.add('scheduleFlag',{codeTypeCode:'LGCOM_YN_FLAG'});
	code.add('errorFlag',{codeTypeCode:'LGCOM_YN_FLAG'});
	
	code.execute();
	
	formUtil.initCombo('systemCode',code.get('systemCode'),{selectAll:true});
	formUtil.initCombo('moduleCode',code.get('moduleCode'),{selectAll:true, filter:'systemCode'});
	formUtil.initCombo('alarmFlag',code.get('alarmFlag'),{selectAll:true});
	formUtil.initCombo('scheduleFlag',code.get('scheduleFlag'),{selectAll:true}); 
	formUtil.initCombo('userCheckFlag',code.get('checkFlag'),{selectAll:true});
	//formUtil.initCombo('errorFlag',code.get('errorFlag'),{selectAll:true});
	
	formUtil.setValue( { "scheduleFlag" :  "N", "dateFrom" : DateUtil.today("YYYY-MM-DD"),  "dateTo" : DateUtil.today("YYYY-MM-DD") } );
	
	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	// 그리드 선언
	var grid = buildGrid(".viewerGrid");
	/*** 화면 초기 처리 ***/
	myForm.initForm = function() {
		$.each(USER_ROLE_LIST,function(idx) {
			if(this.systemCode == 'LGCOM' && this.moduleCode == 'LGSYSC' && this.roleCode == 'BIZWEB_SYSTEM_ADMINISTRATOR') {
				isAdmin = true;
				return false;
			}
		});
		// 사용자 정보 세팅
		formUtil.setValue({
			requestUserId: $.trim(SESSION_USER.applicationUserId),
			employeeName: $.trim(SESSION_USER.fullNameLocal)
		});
		// 사용자 고정
		if(!isAdmin) {
			myForm.select(".searchBlock form input[name='employeeName']").prop('disabled',true);
			myForm.select(".searchBlock form button.btn[data-action='popup']").prop('disabled',true);
		}

		if( '<c:out value="${param.requestId}"/>' != "null" ) {
			formUtil.setValue({ requestId : '<c:out value="${param.requestId}"/>'  });
			search();
		}
	};

	this.search = function( requestId ) {
		if( requestId != undefined ) {
			formUtil.setValue({ requestId : requestId  });
			myForm.select(".searchBlock button[data-action='search']").click();
		}
	}

	function search() {
		grid.getGridBase().cancel();
		var param = formUtil.getValue();
		param['adminFlag'] = ((isAdmin) ? 'Y':'N');
		grid.loadData('lgcom','lgutlc/LGUTLC00140/retrieveConcurrentViewerList', param);
	}


	/*** 이벤트 핸들러  ***/
	myForm.addEvent( "click", "button[data-action]" , function(event) {
		var action = $.trim($(this).data('action'));
		// 조회
		if(action == 'search') {
			search();
		}
		// View Log
		else if(action == 'showlog') {
			var cgrid = grid.getGridBase();
			var checkedItems = cgrid.getCheckedItems();
			if(checkedItems == null || checkedItems.length == 0) {
				Message.alert('<lgcom:message code="note.nocheckdata"/>');
				return;
			}
			if($.trim(cgrid.getValue(checkedItems[0],'logfileExist')) != 'Y') {
				Message.alert('<lgcom:message code="error.noExistLogFile"/>');
				return;
			}
			// Concurrent Log Viewer
			var popup = new Popup(myForm,'lgcom','M_LGUTLC_1199','<lgcom:message code="ConcurrentLogViewer"/>');
			popup.setSize(900,680);
			popup.addParam("requestId",$.trim(cgrid.getValue(checkedItems[0],'concurrentRequestId')));
			popup.addParam("viewMode",'log');
			popup.addParam("screenTitle",'<lgcom:message code="ConcurrentLogViewer"/>');
			popup.openWindow();
		}
		// View Output
		else if(action == 'showout') {
			var cgrid = grid.getGridBase();
			var checkedItems = cgrid.getCheckedItems();
			if(checkedItems == null || checkedItems.length == 0) {
				Message.alert('<lgcom:message code="note.nocheckdata"/>');
				return;
			}
			if($.trim(cgrid.getValue(checkedItems[0],'outfileExist')) != 'Y') {
				Message.alert('<lgcom:message code="error.noExistLogFile"/>');
				return;
			}
			// Out File Type에 따라 처리
			//TEXT,XML,HTML
			if($.trim(cgrid.getValue(checkedItems[0],'outputFileType')) == 'TEXT' || $.trim(cgrid.getValue(checkedItems[0],'outputFileType')) == 'XML' || $.trim(cgrid.getValue(checkedItems[0],'outputFileType')) == 'HTML') {
				// Concurrent Log Viewer
				var popup = new Popup(myForm,'lgcom','M_LGUTLC_1199','<lgcom:message code="ConcurrentOutputViewer"/>');
				popup.setSize(900,680);
				popup.addParam("requestId",$.trim(cgrid.getValue(checkedItems[0],'concurrentRequestId')));
				popup.addParam("viewMode",'out');
				popup.addParam("screenTitle",'<lgcom:message code="ConcurrentOutputViewer"/>');
				popup.openWindow();
			}
			//XLSX,PDF
			else if($.trim(cgrid.getValue(checkedItems[0],'outputFileType')) == 'XLSX' || $.trim(cgrid.getValue(checkedItems[0],'outputFileType')) == 'PDF') {
				var downloader = new Downloader( myForm );
				downloader.concurrentOutput('lgcom',$.trim(cgrid.getValue(checkedItems[0],'outputFileType')).toLowerCase(),$.trim(cgrid.getValue(checkedItems[0],'concurrentRequestId')));
			}
			else {
				Message.alert('지원되지 않는 Output 타입입니다.');
			}
		}
	});
	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});
	// 검색 버튼 이벤트
	myForm.addEvent('click',".searchBlock button[data-action='popup']",function(event) {
		var type = $(this).data('type');
		switch(type) {
			case 'user':
				// 팝업에 사용될 Argument 객체 선언
				var _popup = myForm.popupInfo.userPopup;
				// 입력된 사용자명을 세팅한다.
				_popup.employeeName = formUtil.getValue('employeeName');
				// 팝업을 호출한다.
				var popup = new Popup(myForm,'lgcom','M_LGUTLC_1142','<lgcom:message code="UserSearch"/>');
				//popup.setSize(800,528);	// searchMode 'Multi'
				popup.setSize(800,494);	// searchMode 'Single'
				formUtil.setValue({requestUserId:'',employeeName:''});
				popup.open(function() {
					// Employee Name
					formUtil.setValue({employeeName:_popup.userData[0].employeeName,requestUserId:_popup.userData[0].userId});
					_popup.userData = [];
				});
				break;
			case 'program':
				// 팝업에 사용될 Argument 객체 선언
				var _popup = myForm.popupInfo.programPopup;
				_popup['systemCode'] = $.trim(formUtil.getValue('systemCode'));
				_popup['moduleCode'] = $.trim(formUtil.getValue('moduleCode'));
				_popup['programName'] = $.trim(formUtil.getValue('programName'));
				var popup = new Popup(myForm,'lgcom','M_LGSYSC_1135','<lgcom:message code="ProgramSearch"/>');
				popup.setSize(500,450);
				formUtil.setValue({programId:'',programName:''});
				popup.open(function() {
					// Program Id, Name
					formUtil.setValue({programId:_popup.programId, programName:_popup.programName});
					myForm.popupInfo.programPopup = {};
				});
				break;
		}
		event.stopPropagation();
	});
	// On Change 이벤트
	myForm.addEvent('change',".searchBlock input[data-action='change']",function(event) {
		var type = $(this).data('type');
		switch(type) {
			case 'user':
				// 팝업에 사용될 Argument 객체 선언
				var _popup = myForm.popupInfo.userPopup;
				// 입력된 사용자명을 세팅한다.
				_popup.employeeName = formUtil.getValue('employeeName');
				// 팝업을 호출한다.
				var popup = new Popup(myForm,'lgcom','M_LGUTLC_1142','<lgcom:message code="UserSearch"/>');
				//popup.setSize(800,528);	// searchMode 'Multi'
				popup.setSize(800,494);	// searchMode 'Single'
				formUtil.setValue({requestUserId:'',employeeName:''});
				popup.open(function() {
					// Employee Name
					formUtil.setValue({employeeName:_popup.userData[0].employeeName,requestUserId:_popup.userData[0].userId});
					_popup.userData = [];
				});
				break;
			case 'program':
				// 팝업에 사용될 Argument 객체 선언
				var _popup = myForm.popupInfo.programPopup;
				_popup['systemCode'] = '';
				_popup['programName'] = $.trim(formUtil.getValue('programName'));
				var popup = new Popup(myForm,'lgcom','M_LGSYSC_1135','<lgcom:message code="ProgramSearch"/>');
				popup.setSize(500,450);
				formUtil.setValue({programId:'',programName:''});
				popup.open(function() {
					// Program Name
					formUtil.setValue({programId:_popup.programId, programName:_popup.programName});
					_popup = {};
				});
				break;
		}
		event.stopPropagation();
	});
	/*** 내부 함수  ***/
	//그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		//컬럼 설정
		grid.setFields([
			{ fieldName: 'requestId'                , dataType: 'number' },
			{ fieldName: 'requestUserId'            , dataType: 'number' }, 
			{ fieldName: 'employeeName'             , dataType: 'text'   },
			{ fieldName: 'systemCode'               , dataType: 'text'   },
			{ fieldName: 'moduleCode'               , dataType: 'text'   },
			{ fieldName: 'programId'                , dataType: 'text'   },
			{ fieldName: 'programName'              , dataType: 'text'   },
			{ fieldName: 'batchId'                  , dataType: 'text'   },
			{ fieldName: 'batchName'                , dataType: 'text'   },
			{ fieldName: 'popUpAlarmFlag'           , dataType: 'text'   },
			{ fieldName: 'userCheckFlag'            , dataType: 'text'   },
			{ fieldName: 'actualStartDate'          , dataType: 'text'   },
			{ fieldName: 'actualEndDate'            , dataType: 'text'   },
			{ fieldName: 'trxSec'                   , dataType: 'number' },
			{ fieldName: 'trxHhmiss'                , dataType: 'text'   },
			{ fieldName: 'argumentText'             , dataType: 'text'   },
			{ fieldName: 'statusCode'               , dataType: 'text'   },
			{ fieldName: 'statusCodeName'           , dataType: 'text'   },
			{ fieldName: 'errorFlag'                , dataType: 'text'   },
			{ fieldName: 'errorContent'             , dataType: 'text'   },
			{ fieldName: 'fileId'                   , dataType: 'text'   }
		]);
		// Lookup 세팅
		grid.setLookupsMultiLvl({
			system: code.get('systemCode'),
			module: {data:code.get('moduleCode'), keyField:['pCode','code']},
			alarmFlag:code.get('alarmFlag'),
			checkFlag:code.get('checkFlag'),
			errorFlag:code.get('errorFlag')
		});
		// Grid Column 세팅
		grid.setColumns([
			{
				name:'requestId',
				fieldName:'requestId',
				width:80,
				header: {text:'<lgcom:message code="RequestId"/>'},
				styles: {textAlignment:'center'},
				editable: false
			},
			{
				name:'systemCode',
				fieldName:'systemCode',
				width:60,
				header: {text:'<lgcom:message code="System"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'system',
				lookupKeyFields: ['systemCode'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'},
				editable: false
			},	
			{
				name:'moduleCode',
				fieldName:'moduleCode',
				width:70,
				header: {text:'<lgcom:message code="Module"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'module',
				lookupKeyFields: ['systemCode','moduleCode'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'},
				editable: false
			},
			{
				name:'programId',
				fieldName:'programId',
				width:90,
				header: {text:'<lgcom:message code="ProgramId"/>'},
				renderer: {showTooltip:true},
				editable: false
			},
			{
				name:'programName',
				fieldName:'programName',
				width:150,
				header: {text:'<lgcom:message code="ProgramName"/>'},
				renderer: {showTooltip:true},
				editable: false
			},
			{
				name:'argumentText',
				fieldName:'argumentText',
				width:120,
				header: {text:'<lgcom:message code="argumentText"/>'},
				renderer: {showTooltip:true},
				editable: false
			},
			{
				name:'actualStartDate',
				fieldName:'actualStartDate',
				width:130,
				header: {text:'<lgcom:message code="StartDate"/>'},
				styles: {textAlignment:'center'},
				editable: false
			},
			{
				name:'actualEndDate',
				fieldName:'actualEndDate',
				width:130,
				header: {text:'<lgcom:message code="EndDate"/>'},
				styles: {textAlignment:'center'},
				editable: false
			},
			{
				name:'trxHhmiss',
				fieldName:'trxHhmiss',
				width:70,
				header: {text:'<lgcom:message code="Runtime"/>'},
				styles: {textAlignment:'far'},
				editable: false
			},
			{
				name:'statusCodeName',
				fieldName:'statusCodeName',
				width:80,
				header: {text:'<lgcom:message code="Status"/>'},
				styles: {textAlignment:'center'},
				editable: false
			},
			{
				name:'employeeName',
				fieldName:'employeeName',
				width:80,
				header: {text:'<lgcom:message code="EmployeeName"/>'},
				editable: false
			},
			{
				name:'popUpAlarmFlag',
				fieldName:'popUpAlarmFlag',
				width:60,
				header: {text:'<lgcom:message code="AlarmFlag"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'alarmFlag',
				lookupKeyFields: ['popUpAlarmFlag'],
				editor: {type:'dropDown', textReadOnly : true},
				editable: false
			},
			{
				name:'userCheckFlag',
				fieldName:'userCheckFlag',
				width:60,
				header: {text:'<lgcom:message code="UserCheck"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'checkFlag',
				lookupKeyFields: ['userCheckFlag'],
				editor: {type:'dropDown', textReadOnly : true},
				editable: false
			},
			{
				name:'errorFlag',
				fieldName:'errorFlag',
				width:60,
				header: {text:'<lgcom:message code="errorFlag"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'errorFlag',
				lookupKeyFields: ['errorFlag'],
				editor: {type:'dropDown', textReadOnly : true},
				editable: false
			},
			{
				name:'errorContent',
				fieldName:'errorContent',
				width:150,
				header: {text:'<lgcom:message code="errorContent"/>'},
				styles: {textAlignment:'left'},
				editable: false
			}
		]);
		//옵션 설정
		grid.setOptions({
			grid: {
				softDeleting: true,
				deleteCreated: true,
				hideDeletedRows:false,
				header: {height:36},
				indicator: {visible:false},
				panel: {visible:false},
				checkBar: {visible:false,showAll:false,visibleOnly:false,exclusive:false},
				stateBar: {visible:false},
				footer: {visible:false},
				edit: {
					insertable: true,
					appendable: true,
					updatable: true,
					deletable: true
				}
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
		//마우스 오른쪽 클릭시 메뉴
		grid.setContextMenu();
		return grid;
	}
};

LGUTLC00140.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGUTLC00140();
		form.init();
		form.initForm();
	});
});
</script>
</head>
<body>
<div class="mdi-container">
<section class="page-content">
	<div class="pageHeader">
		<h2>Batch Viewer</h2>
	</div>
	<div class="searchBlock">
		<form class="form search-wrap">
				<table class="table">
					<colgroup>
						<col width="100"/>
						<col width="80"/>
						<col width="90"/>
						<col width="80"/>
						<col width="100"/>
						<col width="140"/>
						<col width="100"/>
						<col width="*"/>
					</colgroup>
					<tbody>
						<tr>
							<th><label><lgcom:message code="System"/></label></th>
							<td><select class="form-control input-sm" name="systemCode"></select></td>
							<th><label><lgcom:message code="Module"/></label></th>
							<td><select class="form-control input-sm" name="moduleCode"></select></td>
							<th scope="col"><label><lgcom:message code="ProgramName"/></label></th>
							<td>
								<div class="input-group input-group-sm input-search">
									<input type="hidden" name="programId"/>
									<input type="text" name="programName" class="form-control" data-action="change" data-type="program" placeholder=""/>
									<span class="input-group-btn">
										<button class="btn btn-default ico-lgd find" type="button" data-action="popup" data-type="program">
											<span class="fa fa-search" aria-hidden="true"></span>
										</button>
									</span>
								</div>
							</td>
							<th scope="col"><label><i class="asterisk">*</i><lgcom:message code="EmployeeName"/></label></th>
							<td>
								<div class="input-group input-group-sm input-search input-require">
									<input type="hidden" name="requestUserId"/>
									<input type="text" name="employeeName" class="form-control" data-action="change" data-type="user" placeholder=""/>
									<span class="input-group-btn">
										<button class="btn btn-default ico-lgd find" type="button" data-action="popup" data-type="user">
											<span class="fa fa-search" aria-hidden="true"></span>
										</button>
									</span>
								</div>
							</td>
							<td></td>
						</tr>
						<tr>
							<th scope="row"><label><lgcom:message code="RequestId"/></label></th>
							<td><input type="text" name="requestId" class="form-control input-sm"/></td>
							<th scope="col"><label><lgcom:message code="AlarmFlag"/></label></th>
							<td><select name="alarmFlag" class="form-control input-sm"></select></td>
							<th><label><lgcom:message code="UserCheck"/></label></th>
							<td><select name="userCheckFlag" class="form-control input-sm"></select></td>
							<th scope="col"><label><lgcom:message code="ScheduleFlag"/></label></th>
							<td><select name="scheduleFlag" class="form-control input-sm"></select></td>
							<td></td>
						</tr>
		                <tr>
		                    <th><lgcom:message code="ExecuteHour" /></label></th>
		                    <td>
								<div class="form-inline">
									<div class="form-group">
										<input type="text" class="form-control input-sm" name="dateFrom" placeholder="yyyy-mm-dd" style="width: 90px;" placeholder="yyyy-mm-dd" >
									</div> ~
									<div class="form-group">
										<input type="text" class="form-control input-sm" name="dateTo" placeholder="yyyy-mm-dd" style="width: 90px;" placeholder="yyyy-mm-dd">
									</div>
									<button type="button" class="btn btn-ico _datePicker" aria-label="calendar">
										<span class="ico ico-calendar" aria-hidden="true"></span>
									</button>
								</div>     
		                    </td>
		                    <th></th>
		                    <td></td>
		                    <th></th>
		                    <td></td>
		                    <th></th>
		                    <td></td>
		                </tr>
					</tbody>
				</table>
				<button type="button" class="btn btn-lgd btn-sm btn-search" data-action="search"><lgcom:message code="Search"/></button>
		</form>
	</div>
	<!-- 
	<div class="gridControls">
		<button class="btn btn-default btn-sm" type="button" role="button" data-action="showlog">View Log</button>
		<button class="btn btn-default btn-sm" type="button" role="button" data-action="showout">View Output</button>
	</div>
	-->
	<div class="gridContent grid-wrap">
		<div class="grid viewerGrid"></div>
	</div>
</section>
</div>
</body>
</html>
