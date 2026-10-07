<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGUTLC00100.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 Service Logging을 조회하는 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Service Logging</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGUTLC00100 = function() {
	var myForm = this;
	// 조회조건 Combo 초기화
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	/* 팝업용 변수 선언 */
	myForm.popupInfo = { detailPopup: {}, menuPopup: {}, programPopup: {} };

	
    /* Layout Setting */
	myForm.setLayout( [ 
		{ name : "searchBlock",  left : 0, right : 0, top : 0 },		
		{ name : "gridContent",  left : 0, right : 0, top : "searchBlock", bottom : 0 }		
    ]);	
    
	// 조회조건 Combo 초기화
	var code = new CommonCode('lgcom');
	code.add('systemCode',{codeTypeCode:'LGCOM_SYSTEM_CODE'});
	code.add('moduleCode',{codeTypeCode:'LGCOM_MODULE_CODE'});
	code.execute();
	formUtil.initCombo('systemCode',code.get('systemCode'),{selectAll:true});
	formUtil.initCombo('moduleCode',code.get('moduleCode'),{selectAll:true, filter:'systemCode'});
	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	// 실행년월 - 당월 세팅
	formUtil.setValue({executionYyyymm:DateUtil.today("YYYY-MM")});
	// 그리드 선언
	var grid = buildGrid(".checkerGrid");
	/*** 이벤트 핸들러  ***/
	myForm.addEvent( "click", "button[data-action]" , function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		// 조회
		if(action == 'search') {
			grid.getGridBase().cancel();
			var param = formUtil.getValue();
			grid.loadData('lgcom','lgutlc/LGUTLC00100/retrieveServiceLogSummaryList', param);
		}
	});
	// Popup 이벤트
	myForm.addEvent('click',".searchBlock button[data-action='popup']",function(event) {
		var type = $(event.target).data('type');
		if(!type) {
			type = $(event.target).closest('button[data-action]').data('type');
		}
		switch(type) {
			case 'menu':
				// 팝업에 사용될 Argument 객체 선언
				var _popup = myForm.popupInfo.menuPopup;
				_popup['systemCode'] = $.trim(formUtil.getValue('systemCode'));
				_popup['moduleCode'] = $.trim(formUtil.getValue('moduleCode'));
				_popup['menuName'] = $.trim(formUtil.getValue('menuName'));
				// 팝업을 호출한다.
				var popup = new Popup(myForm,'lgcom','M_LGSYSC_1151','<lgcom:message code="MenuSearch"/>');
				popup.setSize(470,450);
				// 기존 입력값 초기화
				formUtil.setValue({menuId:'',menuName:''});
				popup.open(function() {
					if(_popup['selectedData']) {
						formUtil.setValue({
							menuId: $.trim(_popup.selectedData['menuId']),
							menuName: $.trim(_popup.selectedData['menuName'])
						});
					}
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
					myForm.popupInfo.programPopup = {};
				});
				break;
		}
		event.stopPropagation();
	});
	// Popup 검색값 삭제처리
	myForm.addEvent('change',".searchBlock input[data-action='change']",function(event) {
		var type = $(this).data('type');
		switch(type) {
			case 'menu':
				// 팝업에 사용될 Argument 객체 선언
				var _popup = myForm.popupInfo.menuPopup;
				_popup['systemCode'] = $.trim(formUtil.getValue('systemCode'));
				_popup['moduleCode'] = $.trim(formUtil.getValue('moduleCode'));
				_popup['menuName'] = $.trim(formUtil.getValue('menuName'));
				// 팝업을 호출한다.
				var popup = new Popup(myForm,'lgcom','M_LGSYSC_1151','<lgcom:message code="MenuSearch"/>');
				popup.setSize(470,450);
				// 기존 입력값 초기화
				formUtil.setValue({menuId:'',menuName:''});
				popup.open(function() {
					if(_popup['selectedData']) {
						formUtil.setValue({
							menuId: $.trim(_popup.selectedData['menuId']),
							menuName: $.trim(_popup.selectedData['menuName'])
						});
					}
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
					myForm.popupInfo.programPopup = {};
				});
				break;
		}
	});
	// Grid 더블클릭시 상세 조회 Popup
	grid.getGridBase().onDataCellDblClicked = function(cgrid,index) {
		// 팝업에 사용될 Argument 객체 선언
		var _popup = myForm.popupInfo.detailPopup;
		_popup['executionYyyymm'] = $.trim(cgrid.getValue(index.itemIndex,'executionYyyymm'));
		_popup['menuId'] = $.trim(cgrid.getValue(index.itemIndex,'menuId'));
		_popup['menuName'] = $.trim(cgrid.getValue(index.itemIndex,'menuName'));
		_popup['programId'] = $.trim(cgrid.getValue(index.itemIndex,'programId'));
		_popup['programName'] = $.trim(cgrid.getValue(index.itemIndex,'programName'));
		_popup['systemServiceDesc'] = $.trim(cgrid.getValue(index.itemIndex,'systemServiceDesc'));
		_popup['serviceName'] = $.trim(cgrid.getValue(index.itemIndex,'serviceName'));
		// 팝업을 호출한다.
		var popup = new Popup(myForm,'lgcom','M_LGUTLC_1176','<lgcom:message code="ServiceLoggingDetail"/>');
		popup.setSize(1000,450);
		popup.open();
	};
	/*** 내부 함수  ***/
	//그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		//컬럼 설정
		grid.setFields([
			{ fieldName: 'executionYyyymm'      , dataType: 'text'   },
			{ fieldName: 'systemCode'           , dataType: 'text'   },
			{ fieldName: 'moduleCode'           , dataType: 'text'   },
			{ fieldName: 'menuId'               , dataType: 'text'   },
			{ fieldName: 'menuName'             , dataType: 'text'   },
			{ fieldName: 'programId '           , dataType: 'text'   },
			{ fieldName: 'programName'          , dataType: 'text'   },
			{ fieldName: 'systemServiceDesc'    , dataType: 'text'   },
			{ fieldName: 'serviceName'          , dataType: 'text'   },
			{ fieldName: 'averageProcessingTime', dataType: 'number' }
		]);
		grid.setLookupsMultiLvl({
			system: code.get('systemCode'),
			module: {data:code.get('moduleCode'), keyField:['pCode','code']}
		});
		// Grid Column 세팅
		grid.setColumns([
			{
				name:'executionYyyymm',
				fieldName:'executionYyyymm',
				width:70,
				header: {text:'<lgcom:message code="ExecutionYyyymm"/>'},
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
				name:'menuName',
				fieldName:'menuName',
				width:150,
				header: {text:'<lgcom:message code="MenuName"/>'},
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
				name:'serviceName',
				fieldName:'serviceName',
				width:200,
				header: {text:'<lgcom:message code="SystemServiceDesc"/>'},
				renderer: {showTooltip:true},
				editable: false
			},
			{
				name:'averageProcessingTime',
				fieldName:'averageProcessingTime',
				width:56,
				header: {text:'<lgcom:message code="ExecuteTime"/>'},
				styles: {textAlignment:'far',paddingRight:5,numberFormat:'#,##0.0000'},
				editable: false
			}
		]);
		//옵션 설정
		grid.setOptions({
			grid: {
				softDeleting: true,
				deleteCreated: true,
				hideDeletedRows:false,
				indicator: {visible:false},
				panel: {visible:false},
				checkBar: {visible:false},
				stateBar: {visible:false},
				footer: {visible:false},
				edit: {
					insertable: true,
					appendable: true,
					updatable: true,
					deletable: true
				},
				header: {
					height: 34
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

LGUTLC00100.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGUTLC00100();
		form.init();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Service Logging</h2>
	</div>
	<div class="searchBlock">
		<form class="form search-wrap">
				<table class="table">
					<colgroup>
						<col width="110"/>
						<col width="150"/>
						<col width="80" />
						<col width="100"/>
						<col width="80" />
						<col width="100"/>
						<col width="110"/>
						<col width="150"/>
						<col width="*"  />
					</colgroup>
					<tbody>
						<tr>
							<th scope="col"><label class="required"><i class="asterisk">*</i><lgcom:message code="ExecutionYyyymm"/></label></th>
							<td><input type="text" name="executionYyyymm" class="form-control input-sm input-require text-center" monthpicker/></td>
							<th><label><lgcom:message code="System"/></label></th>
							<td><select class="form-control input-sm" name="systemCode"></select></td>
							<th><label><lgcom:message code="Module"/></label></th>
							<td><select class="form-control input-sm" name="moduleCode"></select></td>
							<th></th>
							<td></td>
							<td></td>
						</tr>
						<tr>
							<th scope="col"><label><lgcom:message code="ProgramName"/></label></th>
							<td>
								<div class="input-group input-group-sm input-search">
									<input type="text" name="programName" class="form-control" data-action="change" data-type="program" placeholder=""/>
									<span class="input-group-btn">
										<button class="btn btn-default ico-lgd find" type="button" data-action="popup" data-type="program">
											<span class="fa fa-search" aria-hidden="true"></span>
										</button>
									</span>
								</div>
								<input type="hidden" name="programId"/>
							</td>
							<th scope="col"><label><lgcom:message code="SystemServiceDesc"/></label></th>
							<td colspan="3"><input type="text" name="serviceDesc" class="form-control input-sm "/></td>
							<th scope="col"></th>
							<td></td>
						</tr>
					</tbody>
				</table>
                <button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search" ><lgcom:message code="search" /></button>
		</form>
	</div>
	<div class="gridContent grid-wrapper">
		<div class="grid checkerGrid"></div>
	</div>
	</section>
</div>
</body>
</html>
