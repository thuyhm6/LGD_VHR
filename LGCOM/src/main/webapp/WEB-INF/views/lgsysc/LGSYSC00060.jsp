<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
	파일명 : LGSYSC00060.jsp
	프로젝트명 : LGD WCFW

	Copyright(c) 2017 LG CNS, All rights reserved.

	설 명 : 본 화면은 User Role 정보를 관리하는 화면입니다.
	작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGSYSC00060 = function() {
	var myForm = this;
	/* Form util 선언 */
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	/* 팝업용 변수 선언 */
	myForm.popupInfo = { rolePopup: {} };
	/* 화면 레이아웃 정의 */
	/*
	myForm.setManagedLayout({
		searchBlock :{ left:0  , top:0 , right:0 },
		gridControls:{ left:0  , top:DOUBLE_LINE.top1, right:0 },
		contentGrid1:{ left:0  , top:DOUBLE_LINE.top2, width:350, bottom:0 },
		contentGrid2:{ left:360, top:DOUBLE_LINE.top2, right:0, bottom:0 }
	});
	*/
    /* Layout Setting */
	myForm.setLayout( [ 
		{ name  : "searchBlock",   left : 0, right : 0, top : 0 },		
		{ name  : "gridControls",  left : 0, right : 0, top : "searchBlock", bottom : "contentGrid1" }, 
		{ name  : "contentGrid1",  left : 0, right : 0, top : "gridControls", width : 400, bottom : 0}, 
	 	{ name  : "contentGrid2",  left : "contentGrid1", right : 0, top : "gridControls", bottom : 0  }		
	]); 	
	// 재직구분 세팅
	var code = new CommonCode('lgcom');
	var combo = code.execute('resignationList',{codeTypeCode:'LGCOM_SUSP_RESIGNATION_FLAG'});
	formUtil.initCombo('suspResignationFlag',combo,{selectAll:true});
	// 그리드 생성
	var grid1 = buildGrid('.userListGrid');
	var grid2 = buildGrid('.userRoleListGrid');
	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	// 화면 초기 세팅
	myForm.loadCompleted = function() {
		formUtil.setValue({suspResignationFlag:'C'});
	};
	/***  이벤트 핸들러  ***/
	myForm.addEvent('click', 'button[data-action]', function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch(action) {
			case 'search':
				grid2.getGridBase().cancel();
				var param = formUtil.getValue();
				grid1.loadData('lgcom','lgsysc/LGSYSC00060/retrieveUserList', param);
				break;
			case 'insert':
				var egrid = grid1.getGridBase();
				var cgrid = grid2.getGridBase();
				// 조회된 사원정보가 없다면 종료한다.
				if(grid1.getGridBase().getItemCount() < 1) return;
				if(cgrid.getCurrent().itemIndex < 0) {
					cgrid.beginAppendRow();
				} else {
					cgrid.beginInsertRow(cgrid.getCurrent().itemIndex);
				}
				cgrid.setValue(cgrid.getCurrent().itemIndex,'userId',egrid.getValue(egrid.getCurrent().itemIndex,'userId'));
				cgrid.setValue(cgrid.getCurrent().itemIndex,'employeeNo',egrid.getValue(egrid.getCurrent().itemIndex,'employeeNo'));
				cgrid.setValue(cgrid.getCurrent().itemIndex,'employeeName',egrid.getValue(egrid.getCurrent().itemIndex,'localEmployeeName'));
				var currCell = cgrid.getCurrent();
				var index = {
					itemIndex: (currCell.itemIndex < 0) ? 0:currCell.itemIndex,
					column: 'roleName',
					dataRow: (currCell.dataRow < 0) ? 0:currCell.dataRow,
					fieldName: currCell.fieldName
				};
				cgrid.setCurrent(index);
				cgrid.setFocus();
				break;
			case 'delete':
				grid2.getGridBase().deleteSelection(true);
				break;
			case 'save':
				try {
					grid2.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				if(grid2.getRowCount() == 0) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};
				// 변경건이 있는지 체크
				if(!grid2.isChanged()) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				}
				Message.confirm('<lgcom:message code="question.save"/>', function() {
					grid2.saveChanges('lgcom','lgsysc/LGSYSC00060/saveUserRoleList', function(data) {
						Message.notify('<lgcom:message code="note.completed"/>');
						// 저장 완료후 목록 재조회
						myForm.select("button[data-action='search']").trigger('click');
					});
				});
				break;
			case 'multiExport':
			    // 20181008 nomi : 리얼그리드 multi export
                var sheetInfo = [
                    {grid: grid1.getGridBase(), sheetName: 'grid1'},
                    {grid: grid2.getGridBase(), sheetName: 'grid2'}
                ]
                myForm.exportMultiGrid('test', sheetInfo);
			    break;
		}
	});
	/* 숫자키만 입력 */
	myForm.addEvent('keydown','.searchBlock form input.number',function(event) {
		var code = event.which ? event.which : event.keyCode;
		if(code >= 48 && code <= 57) {
		} else if(96 <= code && code <= 105) {
		} else if(code === 8 || code === 9 || code === 37 || code === 39 || code === 46 || code === 67 || code === 86) {
		} else {
			var val = $.trim($(this).val());
			if(isNaN(val)) {
				val = val.slice(0,-1);
			}
			$(this).val(val);
			event.returnValue = false;
			if(event.preventDefault) event.preventDefault();
		}
	});
	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});
	/* 그리드 이벤트 처리 */
	grid1.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		if(newRow > -1) {
			grid2.getGridBase().cancel();
			var rowData = cgrid.getValues(newRow);
			var param = {userId:''};
			if(rowData && rowData.userId) {
				param['userId'] = rowData.userId;
			}
			grid2.loadData('lgcom','lgsysc/LGSYSC00060/retrieveUserRoleList',param);
		}
	};
	grid2.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		var provider = cgrid.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';
		// 신규행이 아니면 Program ID 컬럼 편집 불가
		if(!editable) {
			cgrid.setColumnProperty('roleName','editable',false);
			cgrid.setColumnProperty('roleName','button','none');
			// 삭제버튼 활성화
			myForm.select(".gridControls button[data-action='delete']").attr('disabled','disabled');
		} else {
			cgrid.setColumnProperty('roleName','editable',true);
			cgrid.setColumnProperty('roleName','button','action');
			// 삭제버튼 비활성화
			myForm.select(".gridControls button[data-action='delete']").removeAttr('disabled');
			cgrid.setCellStyles(newRow,'systemCode','addStyle');
			cgrid.setCellStyles(newRow,'moduleCode','addStyle');
			cgrid.setCellStyles(newRow,'roleCode','addStyle');
			cgrid.setCellStyles(newRow,'roleName','addStyle');
		}
	};
	grid2.getGridBase().onCellButtonClicked = function(cgrid, itemIndex, column) {
		cgrid.commitEditor();
		var currRow = cgrid.getCurrent();
		var gridRow = cgrid.getValues(currRow.itemIndex);
		processRolePopup(itemIndex,column.name,gridRow.userId,gridRow.roleName);
	};
	grid2.getGridBase().onEditChange = function(cgrid,index,value) {
		if(index.column == 'roleName') {
			if($.trim(value) == '') {
				cgrid.setValue(index.itemIndex,'roleCode','');
			}
		}
	};
	grid2.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	};
	/***  내부 함수  ***/
	// 그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		switch(gridId) {
			case '.userListGrid':
				grid.setFields([
					{ fieldName:'userId'           , dataType:'number'},
					{ fieldName:'employeeNo'       , dataType:'text'  },
					{ fieldName:'localEmployeeName', dataType:'text'  },
					{ fieldName:'mailAddr'         , dataType:'text'  }
				]);
				grid.setColumns([
					{
						name:'employeeNo',
						fieldName:'employeeNo',
						width:90,
						header: {text:'<lgcom:message code="EmployeeNo"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'localEmployeeName',
						fieldName:'localEmployeeName',
						width:120,
						header: {text:'<lgcom:message code="EmployeeName"/>'},
						editable: false
					},
					{
						name:'mailAddr',
						fieldName:'mailAddr',
						width:150,
						header: {text:'<lgcom:message code="E-Mail"/>'},
						editable: false
					}
				]);
				grid.setOptions({
					grid: {
						hideDeletedRows: true,
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
							height: 40
						}
					},
					dataProvider: {
						insertable: true,
						updatable: true,
						deletable: true,
						softDeleting: true,
						deleteCreated: true
					},
					display: { fitStyle: 'evenFill' }
				});
				// Context Menu Set
				grid.setContextMenu();
				break;
			case '.userRoleListGrid':
				grid.setFields([
					{ fieldName:'userId'             , dataType:'number'},
					{ fieldName:'employeeNo'         , dataType:'text'  },
					{ fieldName:'employeeName'       , dataType:'text'  },
					{ fieldName:'systemCode'         , dataType:'text'  },
					{ fieldName:'moduleCode'         , dataType:'text'  },
					{ fieldName:'roleCode'           , dataType:'text'  },
					{ fieldName:'roleName'           , dataType:'text'  },
					{ fieldName:'applyStartDate'     , dataType:'text'  },
					{ fieldName:'applyEndDate'       , dataType:'text'  },
					{ fieldName:'approverOpinionDesc', dataType:'text'  }
				]);
				/* Grid Lookup 세팅 */
				code.add('system',{codeTypeCode:'LGCOM_SYSTEM_CODE'});
				code.add('module',{codeTypeCode:'LGCOM_MODULE_CODE'});
				code.execute();
				grid.setLookups({'system':code.get('system'),'module':code.get('module')});
				grid.setColumns([
					{
						name:'employeeNo',
						fieldName:'employeeNo',
						width:60,
						header: {text:'<lgcom:message code="EmployeeNo"/>'},
						styles: {textAlignment:'center'},
						mergeRule: {criteria:'value'},
						editable: false
					},
					{
						name:'employeeName',
						fieldName:'employeeName',
						width:100,
						header: {text:'<lgcom:message code="EmployeeName"/>'},
						mergeRule: {criteria:"values['employeeNo'] + value"},
						editable: false
					},
					{
						name:'systemCode',
						fieldName:'systemCode',
						width:60,
						header: {text:'<lgcom:message code="System"/>', required: true},
						styles: {textAlignment:'center'},
						mergeRule: {criteria:"values['employeeNo'] + values['employeeName'] + value"},
						lookupDisplay: true,
						lookupSourceId: 'system',
						lookupKeyFields: ['systemCode'],
						editable: false
					},
					{
						name:'moduleCode',
						fieldName:'moduleCode',
						width:60,
						header: {text:'<lgcom:message code="Module"/>', required: true},
						styles: {textAlignment:'center'},
						mergeRule: {criteria:"values['employeeNo'] + values['employeeName'] + values['systemCode'] + value"},
						lookupDisplay: true,
						lookupSourceId: 'module',
						lookupKeyFields: ['moduleCode'],
						editable: false
					},
					{
						name:'roleCode',
						fieldName:'roleCode',
						width:110,
						header: {text:'<lgcom:message code="RoleCode"/>', required : true},
						editable: false
					},
					{
						name:'roleName',
						fieldName:'roleName',
						width:120,
						header: {text:'<lgcom:message code="RoleName"/>', required : true},
						button: 'action',
						editable: false
					},
					{
						type:'group',
						orientation:'horizontal',
						width:160,
						header : { text: '<lgcom:message code="ApplyDate"/>', styles: {fontBold:true} },
						columns: [
							{
								name:'applyStartDate',
								fieldName:'applyStartDate',
								width:80,
								type: 'data',
								header: {text:'<lgcom:message code="StartDate"/>'},
								styles: {textAlignment:'center'},
								editor: {type:'date',datetimeFormat:'yyyy-MM-dd'}
							},
							{
								name:'applyEndDate',
								fieldName:'applyEndDate',
								width:80,
								type: 'data',
								header: {text:'<lgcom:message code="EndDate"/>'},
								styles: {textAlignment:'center'},
								editor: {type:'date',datetimeFormat:'yyyy-MM-dd'}
							}
						]
					},
					{
						name:'approverOpinionDesc',
						fieldName:'approverOpinionDesc',
						width:150,
						header: {text:'<lgcom:message code="Description"/>'}
					},
				]);
				grid.setOptions({
					grid: {
						hideDeletedRows: true,
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
							height: 40
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
				// Validation Set
				grid.setValidations([
					{criteria: "value['userId'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='EmployeeNo'/>"/>',mode:'always',level:'error'},
					{criteria: "value['roleCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='RoleCode'/>"/>',mode:'always',level:'error'},
					{criteria: "value['roleName'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='RoleName'/>"/>',mode:'always',level:'error'}
				]);
				break;
		}
		return grid;
	}
	// Role Popup 처리
	function processRolePopup(rowIdx, colName, applicationUserId, keyword) {
		if(typeof(applicationUserId) == 'undefined') applicationUserId = '';
		if(typeof(keyword) == 'undefined') keyword = '';
		myForm.popupInfo.rolePopup['searchMode'] = 'multi';
		myForm.popupInfo.rolePopup['row'] = rowIdx;
		myForm.popupInfo.rolePopup['col'] = colName;
		myForm.popupInfo.rolePopup['extraType'] = 'User';
		myForm.popupInfo.rolePopup['extraOwn'] = true;
		myForm.popupInfo.rolePopup['ownUserId'] = applicationUserId;
		myForm.popupInfo.rolePopup['findKey'] = keyword;
		myForm.popupInfo.rolePopup['roleData'] = [];
		/* 적용대상 Grid 지정 */
		var egrid = grid1.getGridBase();
		var cgrid = grid2.getGridBase();
		var rolepop = new Popup(myForm,'lgcom','M_LGUTLC_1141','<lgcom:message code="RoleSearch"/>');
		rolepop.setSize(800,500);
		rolepop.open(function() {
			var array = myForm.popupInfo.rolePopup.roleData;
			if(array.length == 0) return;
			if(array.length == 1) {
				cgrid.setValue(myForm.popupInfo.rolePopup.row,'systemCode',array[0].systemCode);
				cgrid.setValue(myForm.popupInfo.rolePopup.row,'moduleCode',array[0].moduleCode);
				cgrid.setValue(myForm.popupInfo.rolePopup.row,'roleCode',array[0].roleCode);
				cgrid.setValue(myForm.popupInfo.rolePopup.row,'roleName',array[0].roleName);
				cgrid.setValue(myForm.popupInfo.rolePopup.row,'applyStartDate',array[0].applyStartDate);
				cgrid.setValue(myForm.popupInfo.rolePopup.row,'applyEndDate',array[0].applyEndDate);
				cgrid.commit();
			} else {
				var egrid = grid1.getGridBase();
				for(var i=0; i < array.length; i++) {
					if(i > 0) {
						cgrid.beginInsertRow(myForm.popupInfo.rolePopup.row);
						cgrid.setValue(cgrid.getCurrent().itemIndex,'userId',egrid.getValue(egrid.getCurrent().itemIndex,'userId'));
						cgrid.setValue(cgrid.getCurrent().itemIndex,'employeeNo',egrid.getValue(egrid.getCurrent().itemIndex,'employeeNo'));
						cgrid.setValue(cgrid.getCurrent().itemIndex,'employeeName',egrid.getValue(egrid.getCurrent().itemIndex,'localEmployeeName'));
					}
					cgrid.setValue(myForm.popupInfo.rolePopup.row,'systemCode',array[i].systemCode);
					cgrid.setValue(myForm.popupInfo.rolePopup.row,'moduleCode',array[i].moduleCode);
					cgrid.setValue(myForm.popupInfo.rolePopup.row,'roleCode',array[i].roleCode);
					cgrid.setValue(myForm.popupInfo.rolePopup.row,'roleName',array[i].roleName);
					cgrid.setValue(myForm.popupInfo.rolePopup.row,'applyStartDate',array[i].applyStartDate);
					cgrid.setValue(myForm.popupInfo.rolePopup.row,'applyEndDate',array[i].applyEndDate);
					cgrid.commit();
				}
			}
			myForm.popupInfo.rolePopup.roleData = [];
		});
	}
};

LGSYSC00060.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGSYSC00060();
		form.init();
		form.loadCompleted();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
		<h2><lgcom:message code="UserRole"/></h2>
	</div>
	<%-- 조회영역 --%>
	<div class="searchBlock">
		<form class="form search-wrap">
			<table class="table">
				<colgroup>
					<col width="90"/>
					<col width="220"/>
					<col width="60"/>
					<col width="180"/>
					<col width="90"/>
					<col width="120"/>
				</colgroup>
				<tbody>
					<tr>
						<th scope="col"><label><lgcom:message code="Department"/></label></th>
						<td>
							<input type="text" name="deptName" class="form-control input-sm" placeholder=""/>
							<input type="hidden" name="deptCode"/>
						</td>
						<th scope="col"><label><lgcom:message code="UserID"/></label></th>
						<td><input type="text" name="userId" class="form-control input-sm number" maxlength="6" placeholder=""/></td>
						<th scope="col"><label><lgcom:message code="EmployeeNo"/></label></th>
						<td><input type="text" name="employeeNo" class="form-control input-sm" placeholder=""/></td>
					</tr>
					<tr>
						<th scope="col"><label><lgcom:message code="EmployeeName"/></label></th>
						<td><input type="text" name="employeeName" class="form-control input-sm" placeholder=""/></td>
						<th scope="col"><label><lgcom:message code="E-Mail"/></label></th>
						<td><input type="text" name="mailAddr" class="form-control input-sm" placeholder=""/></td>
						<th scope="col"><label><lgcom:message code="InOfficeType"/></label></th>
						<td><select name="suspResignationFlag" class="form-control input-sm"></select></td>
					</tr>
				</tbody>
			</table>
			<button type="button" class="btn btn-lgd btn-sm btn-search" data-action="search" data-access="LGSYSC00030/retrieveUserList"><lgcom:message code="search"/></button>
		</form>
	</div>
	<%-- 그리드 버튼 영역 --%>
	<div class="gridControls module-group text-right">
		<div class="btn-toolbar">
			<div class="btn-group">
				<button type="button" class="btn btn-default btn-sm" role="button" data-action="multiExport">
					<span class="ico ico-excel-down"></span> Download
				</button>
				<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="insert"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="Add"/></button>
				<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete"><span class="fa fa-remove" aria-hidden="true"></span> <lgcom:message code="delete"/></button>
			</div>
			<div class="btn-group">					      
				<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save" data-access="LGSYSC00060/saveUserRoleList"><lgcom:message code="save"/></button>
			</div>
		</div>
	</div>
	<%-- 사용자 그리드 --%>
	<div class="contentGrid1 grid-wrap">
		<div class="grid userListGrid"></div>
	</div>
	<%-- RealGrid 영역 --%>
	<div class="contentGrid2 grid-wrap">
		<div class="grid userRoleListGrid"></div>
	</div>
	</section>
</div>
</body>
</html>
