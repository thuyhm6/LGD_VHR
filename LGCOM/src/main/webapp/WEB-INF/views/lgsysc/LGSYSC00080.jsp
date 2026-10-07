<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
	파일명 : LGSYSC00030.jsp
	프로젝트명 : LGD WCFW

	Copyright(c) 2017 LG CNS, All rights reserved.

	설 명 : 본 화면은 사용자별 Condition List를 조회하는 화면입니다.
	작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGSYSC00080 = function() {
	var myForm = this;
	/* Form util 선언 */
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	/* 팝업용 변수 선언 */
	myForm.popupInfo = {
		userPopup: { searchMode:'single', departmentName:'', mailAddr:'', employeeNo:'', employeeName:'', userData:[] },
		programPopup: {}
	};
	
    /* Layout Setting */
	myForm.setLayout( [ 
		{ name : "searchBlock",  left : 0, right : 0, top : 0 },		
		{ name : "gridControls", left : 0, right : 0, top : "searchBlock", bottom : "gridContent"},
		{ name : "gridContent",  left : 0, right : 0, top : "gridControls", bottom : 0 }		
    ]);	
	// Grid 초기화
	var grid = buildGrid('.condigionListGrid');
	// 필수항목 체크
	var validator = new Validator( myForm, ".searchBlock form", {
		rules: {
			userId:{required:true},
		},
		option: {placement:'right'}
	});
	$.validator.messages.required = '<lgcom:message code="error.requiredTooltip"/>',
	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	/***  이벤트 핸들러  ***/
	// 버튼 이벤트
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch(action) {
			case 'search':
				if(validator.isValid()) {
					grid.getGridBase().cancel();
					var param = formUtil.getValue();
					grid.loadData('lgcom','lgsysc/LGSYSC00080/retrieveConditionList',param);
				} else {
					myForm.select(".searchBlock form input[name='employeeName']").focus();
				}
				break;
			case 'delete':
				var cgrid = grid.getGridBase();
				if(cgrid.getItemCount() == 0) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};
				cgrid.deleteSelection(true);
				break;
			case 'save':
				if(grid.getRowCount() == 0) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};
				// 변경건이 있는지 체크
				if(!grid.isChanged()) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				}
				Message.confirm('<lgcom:message code="question.checkedDelete"/>',function() {
					grid.saveChanges('lgcom','lgsysc/LGSYSC00080/deleteConditionList', function(data) {
						Message.notify('<lgcom:message code="note.completed"/>');
						// 저장 완료후 목록 재조회
						myForm.select("button[data-action='search']").trigger('click');
					});
				});
				break;
		}
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
				formUtil.setValue({userId:'',employeeName:''});
				popup.open(function() {
					// Employee Name
					formUtil.setValue({employeeName:_popup.userData[0].employeeName,userId:_popup.userData[0].userId});
					_popup.userData = [];
				});
				break;
			case 'program':
				// 팝업에 사용될 Argument 객체 선언
				var _popup = myForm.popupInfo.programPopup;
				_popup['systemCode'] = '';
				_popup['programName'] = $.trim(formUtil.getValue('programName'));
				var popup = new Popup(myForm,'lgcom','M_LGSYSC_1135','<lgcom:message code="ProgramSearch"/>');
				popup.setSize(700,450);
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
	
	//onChange 이벤트 
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
				formUtil.setValue({userId:'',employeeName:''});
				popup.open(function() {
					// Employee Name
					formUtil.setValue({employeeName:_popup.userData[0].employeeName,userId:_popup.userData[0].userId});
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
					myForm.popupInfo.programPopup = {};
				});
				break;
		}
		event.stopPropagation();
	});	
	
	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});
	/*** 내부 함수 ***/
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		grid.setFields([
			{ fieldName:'userId'                   , dataType:'number'},
			{ fieldName:'employeeNo'               , dataType:'text'  },
			{ fieldName:'employeeName'             , dataType:'text'  },
			{ fieldName:'programId'                , dataType:'text'  },
			{ fieldName:'programName'              , dataType:'text'  },
			{ fieldName:'htmlInqConditionObjectId' , dataType:'text'  },
			{ fieldName:'htmlInqCondObjectTypeCode', datatype:'text'  },
			{ fieldName:'initialValue1Text'        , datatype:'text'  }
		]);

		// Grid Lookup 목록 조회
		var code = new CommonCode('lgcom');
		var lookups = code.execute("elementType",{codeTypeCode:'LGCOM_HTML_OBJECT_TYPE_CODE'} );
		grid.setLookups({'elementType':lookups});

		grid.setColumns([
			{
				name:'employeeNo',
				fieldName:'employeeNo',
				width:80,
				header: {text:'<lgcom:message code="EmployeeNo"/>'},
				styles: {textAlignment:'center'},
				editable: false
			},
			{
				name:'employeeName',
				fieldName:'employeeName',
				width:110,
				header: {text:'<lgcom:message code="EmployeeName"/>'},
				renderer: {showTooltip:true},
				editable: false
			},
			{
				name:'programId',
				fieldName:'programId',
				width:86,
				header: {text:'<lgcom:message code="ProgramId"/>'},
				styles: {textAlignment:'center'},
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
				name:'htmlInqConditionObjectId',
				fieldName:'htmlInqConditionObjectId',
				width:120,
				header: {text:'<lgcom:message code="ConditionObjectID"/>'},
				editable: false
			},
			{
				name:'htmlInqCondObjectTypeCode',
				fieldName:'htmlInqCondObjectTypeCode',
				width:140,
				header: {text:'<lgcom:message code="ConditionObjectType"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'elementType',
				lookupKeyFields: ['htmlInqCondObjectTypeCode'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'},
				editable: false
			},
			{
				name:'initialValue1Text',
				fieldName:'initialValue1Text',
				width:120,
				header: {text:'<lgcom:message code="InitialValue"/>'},
				editable: false
			}
		]);

		grid.setOptions({
			grid: {
				hideDeletedRows: false,
				indicator: {visible:false},
				panel: {visible:false},
				checkBar: {visible:false},
				footer: {visible:false},
				edit: {
					insertable: true,
					appendable: true,
					updatable: true,
					deletable: true
				},
				header: {
					resizable: true
				}
			},
			dataProvider: {
				insertable: true,
				updatable: true,
				deletable: true,
				softDeleting: true,
				deleteCreated: true
			},
			display: { fitStyle: 'even' }
		});
		// Context Menu Set
		grid.setContextMenu();
		return grid;
	}
};

LGSYSC00080.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGSYSC00080();
		form.init();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2>Condition List</h2>
		</div>
		<%-- 조회영역 --%>
		<div class="searchBlock">
			<form class="form search-wrap">
				<table class="table">
					<colgroup>
						<col width="100"/>
						<col width="150"/>
						<col width="100"/>
						<col width="240"/>
					</colgroup>
					<tbody>
						<tr>
							<th scope="col"><label class="required"><i class="asterisk">*</i><lgcom:message code="EmployeeName"/></label></th>
							<td>
								<div class="input-group input-group-sm input-search input-require">
									<input type="text" name="employeeName" class="form-control required" data-action="change" data-type="user" placeholder=""/>
									<span class="input-group-btn">
										<button class="btn btn-default ico-lgd find" type="button" data-action="popup" data-type="user">
											<span class="fa fa-search" aria-hidden="true"></span>
										</button>
									</span>
								</div>
								<input type="hidden" name="userId"/>
							</td>
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
						</tr>
					</tbody>
				</table>
				<button type="button" class="btn btn-lgd btn-sm btn-search" data-action="search" data-access="LGSYSC00080/retrieveConditionList"><lgcom:message code="search"/></button>
			</form>
		</div>
		<%-- 그리드 버튼 영역 --%>
		<div class="gridControls module-group text-right">
			<div class="btn-toolbar">
			    <div class="btn-group">
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete"><span class="fa fa-remove"  aria-hidden="true"></span> <lgcom:message code="Delete"/></button>
				</div>
				<div class="btn-group">	
					<button class="btn btn-gray btn-sm" type="button" role="button" data-action="save" data-access="LGSYSC00080/deleteConditionList"><lgcom:message code="save"/></button>
		        </div>
		    </div>
		</div>
		
		
		<%-- RealGrid 영역 --%>
		<div class="gridContent grid-wrap">
			<div class="grid condigionListGrid"></div>
		</div>
	</section>
</div>
</body>
</html>
