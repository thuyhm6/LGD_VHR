<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
	파일명 : LGSYSC00150.jsp
	프로젝트명 : LGD WCFW

	Copyright(c) 2012 LG CNS, All rights reserved.

	설 명 : 본 화면은 Program Access를 관리하는 화면입니다.
	작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGSYSC00150 = function() {
	var myForm = this;
	// Form Util 선언
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	/* 팝업용 변수 선언 */
	myForm.popupInfo = { programPopup: {}, rolePopup: {} };

    /* Layout Setting */
	myForm.setLayout( [ 
		{ name  : "searchBlock",   left : 0, right : 0, top : 0 },		
		{ name  : "gridControls1", left : 0, right : 0, top : "searchBlock", width : 650, bottom : "contentGrid1" },
		{ name  : "gridControls2", left : "gridControls1", right : 0, top : "searchBlock", bottom : "contentGrid2" },	 	
		{ name  : "contentGrid1",  left : 0, right : 0, top : "gridControls1", width : 650, bottom : 0},
	 	{ name  : "contentGrid2",  left : "contentGrid1", right : 0, top : "gridControls2", bottom : 0  }		
	]);   
	// 조회조건 Combo 초기화
	var code = new CommonCode('lgcom');
	formUtil.initCombo('useFlag',code.execute('userFlag',{codeTypeCode:'LGCOM_YN_FLAG'}),{selectAll:true});
	// 사용여부 초기값
	formUtil.setValue({useFlag:'Y'});
	// 그리드 생성
	var grid1 = buildGrid('.programServiceGrid');
	var grid2 = buildGrid('.programAccessGrid');
	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	/***  이벤트 핸들러  ***/
	myForm.addEvent('click', 'button[data-action]', function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch(action) {
			case 'search':
				// Grid1 조회
				grid1.getGridBase().cancel();
				var param = formUtil.getValue();
				grid1.loadData('lgcom','lgsysc/LGSYSC00150/retrieveProgramServiceList',param);
				// Grid2 초기화
				grid2.getDataProvider().clearRows();
				break;
			case 'insert1':
				var cgrid = grid1.getGridBase();
				try {
					grid1.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				if(cgrid.getCurrent().itemIndex < 0) {
					cgrid.beginAppendRow();
				} else {
					cgrid.beginInsertRow(cgrid.getCurrent().itemIndex);
				}
				cgrid.setValue(cgrid.getCurrent().itemIndex,'programId',formUtil.getValue('programId'));
				cgrid.setValue(cgrid.getCurrent().itemIndex,'programName',formUtil.getValue('programName'));
				cgrid.setValue(cgrid.getCurrent().itemIndex,'useFlag','Y');
				cgrid.setFocus();
				break;
			case 'delete1':
				grid1.getGridBase().deleteSelection(true);
				break;
			case 'save1':
				try {
					grid1.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				if( grid1.getRowCount() == 0 ) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};
				// 변경건이 있는지 체크
				if(!grid1.isChanged()) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				}
				Message.confirm('<lgcom:message code="question.save"/>', function() {
					grid1.saveChanges('lgcom','lgsysc/LGSYSC00150/saveProgramServiceList', function(data) {
						Message.notify('<lgcom:message code="note.completed"/>');
						// 저장 완료후 목록 재조회
						myForm.select("button[data-action='search']").trigger('click');
					});
				});
				break;
			case 'insert2':
				var cgrid = grid2.getGridBase();
				var egrid = grid1.getGridBase();
				if(cgrid.getCurrent().itemIndex < 0) {
					cgrid.beginAppendRow();
				} else {
					cgrid.beginInsertRow(cgrid.getCurrent().itemIndex);
				}
				cgrid.setValue(cgrid.getCurrent().itemIndex,'programId',egrid.getValue(egrid.getCurrent().itemIndex,'programId'));
				cgrid.setValue(cgrid.getCurrent().itemIndex,'systemServiceId',egrid.getValue(egrid.getCurrent().itemIndex,'systemServiceId'));
				var currCell = cgrid.getCurrent();
				var index = {
					itemIndex: currCell.itemIndex,
					column: 'roleName',
					dataRow: currCell.dataRow,
					fieldName: currCell.fieldName
				};
				cgrid.setCurrent(index);
				cgrid.setFocus();
				break;
			case 'delete2':
				grid2.getGridBase().deleteSelection(true);
				break;
			case 'save2':
				try {
					grid2.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				if( grid2.getRowCount() == 0 ) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};
				// 변경건이 있는지 체크
				if(!grid2.isChanged()) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				}
				Message.confirm('<lgcom:message code="question.save"/>', function() {
					grid2.useProgress(true);
					grid2.saveChanges('lgcom','lgsysc/LGSYSC00150/saveProgramServiceRoleList', function(data) {
						Message.notify('<lgcom:message code="note.completed"/>');
						// 저장 완료후 목록 재조회
						var egrid = grid1.getGridBase();
						var programId = egrid.getValue(egrid.getCurrent().itemIndex,'programId');
						var systemServiceId = egrid.getValue(egrid.getCurrent().itemIndex,'systemServiceId');
						retrieveProgramServiceRoleList(grid2,programId,systemServiceId);
					});
				});
				break;
		}
	});
	// 검색 버튼 이벤트
	myForm.addEvent('click',".searchBlock button[data-action='popup']",function(event) {
		// 팝업에 사용될 Argument 객체 선언
		var _popup = myForm.popupInfo.programPopup;
		_popup['systemCode'] = '';
		_popup['programName'] = $.trim(formUtil.getValue('programName'));
		var popup = new Popup(myForm,'lgcom','M_LGSYSC_1135','<lgcom:message code="ProgramSearch"/>');
		popup.setSize(500,450);
		popup.open(function() {
			// Program Name
			formUtil.setValue({programId:_popup.programId, programName:_popup.programName});
		});
		event.stopPropagation();
	});
	
	// 팝업 컬럼 change 이벤트
	myForm.addEvent( "change", ".searchBlock .form input[name=programName]" , function(event){
		// 팝업에 사용될 Argument 객체 선언
		var _popup = myForm.popupInfo.programPopup;
		_popup['systemCode'] = '';
		_popup['programName'] = $.trim(formUtil.getValue('programName'));
		var popup = new Popup(myForm,'lgcom','M_LGSYSC_1135','<lgcom:message code="ProgramSearch"/>');
		popup.setSize(500,450);
		popup.open(function() {
			// Program Name
			formUtil.setValue({programId:_popup.programId, programName:_popup.programName});
		});
		event.stopPropagation();
	});	
	
	// 검색 버튼 이벤트
	myForm.addEvent('keyup',".searchBlock form input[name='programName']",function(event) {
		var val = $.trim($(this).val());
		if(val == '') formUtil.setValue({programId:'',programName:''});
	});
	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});
	/* 그리드 이벤트 처리 */
	grid1.getGridBase().onCurrentRowChanged = function(cgrid,oldRow,newRow) {
		if(grid2 && grid2.getGridBase()) grid2.getGridBase().cancel();
		var provider = cgrid.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';
		// 신규행이 아니면 Service URL 컬럼 편집 불가
		if(!editable) {
			// Program Name 편집 불가능
			cgrid.setColumnProperty('programName','editable',false);
			cgrid.setColumnProperty('programName','button','none');
			// System Service ID 편집 불가능
			cgrid.setColumnProperty('systemServiceId','editable',false);
			// 삭제버튼 비활성화
			myForm.select(".gridControls1 button[data-action='delete1']").attr('disabled','disabled');
		} else {
			// Program Name 편집 가능
			cgrid.setColumnProperty('programName','editable',true);
			cgrid.setColumnProperty('programName','button','action');
			// System Service ID 편집 가능
			cgrid.setColumnProperty('systemServiceId','editable',true);
			/* 필수입력표시 */
			cgrid.setCellStyles(newRow,'systemServiceId','addStyle');
			// 삭제버튼 활성화
			myForm.select(".gridControls1 button[data-action='delete1']").removeAttr('disabled');
		}
		// Service Role 목록 조회
		if(cgrid.getCurrent().itemIndex > -1) {
			var rowData = cgrid.getValues(cgrid.getCurrent().itemIndex);
			retrieveProgramServiceRoleList(grid2,rowData.programId,rowData.systemServiceId);
		}
	};
	grid1.getGridBase().onCellButtonClicked = function(cgrid, itemIndex, column) {
		cgrid.commitEditor();
		var currRow = cgrid.getCurrent();
		var gridRow = cgrid.getValues(currRow.itemIndex);
		// 팝업에 사용될 Argument 객체 선언
		var _popup = myForm.popupInfo.programPopup;
		_popup['systemCode'] = '';
		_popup['programName'] = $.trim(gridRow.programName);
		var popup = new Popup(myForm,'lgcom','M_LGSYSC_1135','<lgcom:message code="ProgramSearch"/>');
		popup.setSize(500,450);
		popup.open(function() {
			cgrid.setValue(itemIndex,'programId',_popup.programId);
			cgrid.setValue(itemIndex,'programName',_popup.programName);
			cgrid.commit();
		});
	};
	grid1.getGridBase().onEditCommit = function(cgrid, index, oldValue, newValue) {
		if(index.column == 'systemServiceId') {
			var editable = index.dataRow < 0 || cgrid.getDataProvider().getRowState(editRow) === 'created';
			if(editable) {
				var rst = checkDuplicateProgramServiceId(cgrid.getValue(index.itemIndex,'programId'), newValue);
				trace('rst = ' + rst);
				if(rst) {
					Message.alert('<lgcom:message code="error.duplicateValue"/>');
					cgrid.setCurrent({column:'systemServiceId'});
					cgrid.setFocus();
					return false;
				}
			}
		}
	};
	grid1.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	};
	grid2.getGridBase().onCurrentRowChanged = function(cgrid,oldRow,newRow) {
		var provider = cgrid.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';
		// 신규행이 아니면 Service URL 컬럼 편집 불가
		if(!editable) {
			cgrid.setColumnProperty('roleName','editable',false);
			cgrid.setColumnProperty('roleName','button','none');
		} else {
			cgrid.setColumnProperty('roleName','editable',true);
			cgrid.setColumnProperty('roleName','button','action');
			/* 필수입력표시 */
			cgrid.setCellStyles(newRow,'roleCode','addStyle');
			cgrid.setCellStyles(newRow,'roleName','addStyle');
		}
	};
	grid2.getGridBase().onCellButtonClicked = function(cgrid, itemIndex, column) {
		cgrid.commitEditor();
		processRolePopup(itemIndex,column.name,cgrid.getValue(itemIndex,column.name));
	};
	grid2.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	};
	/***  내부 함수  ***/
	// Service ID 중복 체크
	function checkDuplicateProgramServiceId(pgmId,serviceId) {
		var rslt = false;
		transaction_sync('lgcom','lgsysc/LGSYSC00150/retrieveCheckDuplicateProgramServiceId',{programId:pgmId,systemServiceId:serviceId},function(data) {
			rslt = data.result;
		});
		return rslt;
	}
	// 프로그램 Service Role 목록 조회
	function retrieveProgramServiceRoleList(grid,programId,serviceId) {
		var param = {
			programId: $.trim(programId),
			systemServiceId: $.trim(serviceId)
		};
		grid.loadData('lgcom','lgsysc/LGSYSC00150/retrieveProgramServiceRoleList', param);
	}
	// Role Popup 처리
	function processRolePopup(rowIdx, colName, keyword) {
		if(typeof(applicationUserId) == 'undefined') applicationUserId = '';
		if(typeof(keyword) == 'undefined') keyword = '';
		/* 적용대상 Grid 지정 */
		var egrid = grid1.getGridBase();
		var cgrid = grid2.getGridBase();
		myForm.popupInfo.rolePopup['searchMode'] = 'multi';
		myForm.popupInfo.rolePopup['row'] = rowIdx;
		myForm.popupInfo.rolePopup['col'] = colName;
		myForm.popupInfo.rolePopup['extraType'] = 'Program';
		myForm.popupInfo.rolePopup['extraOwn'] = true;
		myForm.popupInfo.rolePopup['ownUserId'] = '';
		myForm.popupInfo.rolePopup['ownPgmId'] = cgrid.getValue(rowIdx,'programId');
		myForm.popupInfo.rolePopup['ownSvcId'] = cgrid.getValue(rowIdx,'systemServiceId');
		myForm.popupInfo.rolePopup['findKey'] = keyword;
		myForm.popupInfo.rolePopup['roleData'] = [];
		var rolepop = new Popup(myForm,'lgcom','M_LGUTLC_1141','<lgcom:message code="RoleSearch"/>');
		rolepop.setSize(740,412);
		rolepop.open(function() {
			var array = myForm.popupInfo.rolePopup.roleData;
			if(array.length == 0) return;
			if(array.length == 1) {
				cgrid.setValue(myForm.popupInfo.rolePopup.row,'roleCode',array[0].roleCode);
				cgrid.setValue(myForm.popupInfo.rolePopup.row,'roleName',array[0].roleName);
				cgrid.commit();
			} else {
				var egrid = grid1.getGridBase();
				for(var i=0; i < array.length; i++) {
					if(i > 0) {
						cgrid.beginInsertRow(myForm.popupInfo.rolePopup.row);
						cgrid.setValue(cgrid.getCurrent().itemIndex,'programId',egrid.getValue(egrid.getCurrent().itemIndex,'programId'));
						cgrid.setValue(cgrid.getCurrent().itemIndex,'systemServiceId',egrid.getValue(egrid.getCurrent().itemIndex,'systemServiceId'));
					}
					cgrid.setValue(myForm.popupInfo.rolePopup.row,'roleCode',array[i].roleCode);
					cgrid.setValue(myForm.popupInfo.rolePopup.row,'roleName',array[i].roleName);
					cgrid.commit();
				}
			}
			myForm.popupInfo.rolePopup.roleData = [];
		});
	}
	// 그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		switch(gridId) {
			case '.programServiceGrid':
				// Grid Field Set
				grid.setFields([
					{ fieldName:'programId'        },
					{ fieldName:'programName'      },
					{ fieldName:'systemServiceId'  },
					{ fieldName:'systemServiceDesc'},
					{ fieldName:'useFlag'          }
				]);
				// Lookup 조회, key 속성에 lookup에 매핑될 lookupSourceId 값을 사용한다.
				grid.setLookups('useFlag',code.execute('useFlag',{codeTypeCode:'LGCOM_YN_FLAG'}));
				// Grid Column Set
				grid.setColumns([
					{
						name:'programId',
						fieldName:'programId',
						width:100,
						header: {text:'<lgcom:message code="ProgramId"/>'},
						styles: {textAlignment:'center'},
						visible: false,
						editable: false
					},
					{
						name:'programName',
						fieldName:'programName',
						width:120,
						header: {text:'<lgcom:message code="ProgramName"/>'},
						button:'action',
						editable: false
					},
					{
						name:'systemServiceId',
						fieldName:'systemServiceId',
						width:150,
						header: {text:'<lgcom:message code="ServiceURL"/>'}
					},
					{
						name:'systemServiceDesc',
						fieldName:'systemServiceDesc',
						width:150,
						header: {text:'<lgcom:message code="ServiceDescription"/>'}
					},
					{
						name:'useFlag',
						fieldName:'useFlag',
						width:80,
						header: {text:'<lgcom:message code="UseFlag"/>'},
						styles: {textAlignment:'center'},
						lookupDisplay: true,
						lookupSourceId: 'useFlag',
						lookupKeyFields: ['useFlag'],
						editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
					}
				]);
				// Grid Option Set
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
							height: 20
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
				// Validation Set
				grid.setValidations([
					{criteria: "value['programId'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='ProgramId'/>"/>',mode:'always',level:'error'},
					{criteria: "value['programName'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='ProgramName'/>"/>',mode:'always',level:'error'},
					{criteria: "value['systemServiceId'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='ServiceURL'/>"/>',mode:'always',level:'error'}
				]);
				break;
			case '.programAccessGrid':
				grid.setFields([
					{ fieldName:'programId'      },
					{ fieldName:'systemServiceId'},
					{ fieldName:'roleCode'       },
					{ fieldName:'roleName'       }
				]);
				grid.setColumns([
					{
						name:'systemServiceId',
						fieldName:'systemServiceId',
						width:100,
						header: {text:'<lgcom:message code="ServiceURL"/>'},
						styles: {textAlignment:'center'},
						visible: false,
						editable: false
					},
					{
						name:'roleName',
						fieldName:'roleName',
						width:250,
						header: {text:'<lgcom:message code="RoleName"/>', required: true},
						button: 'action',
						editable: false
					},
					{
						name:'roleCode',
						fieldName:'roleCode',
						width:220,
						header: {text:'<lgcom:message code="RoleCode"/>', required: true},
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
							height: 20
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
				// Context Menu Set
				grid.setContextMenu();
				// Validation Set
				grid.setValidations([
					{criteria: "value['roleName'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='roleName'/>"/>',mode:'always',level:'error'},
					{criteria: "value['roleCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='RoleCode'/>"/>',mode:'always',level:'error'}
				]);
				break;
		}
		return grid;
	}
};

LGSYSC00150.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGSYSC00150();
		form.init();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Program Access</h2>
	</div>
	<%-- 조회영역 --%>
	<div class="searchBlock">
		<form class="form search-wrap">
				<table class="table">
					<colgroup>
						<col width="90"/>
						<col width="320"/>
						<col width="90"/>
						<col width="60"/>
					</colgroup>
					<tbody>
						<tr>
							<th scope="col"><label><lgcom:message code="ProgramName"/></label></th>
							<td>
								<div class="input-group input-group-sm input-search">
									<input type="text" name="programName" class="form-control" placeholder=""/>
									<span class="input-group-btn">
										<button class="btn btn-default ico-lgd find" type="button" data-action="popup">
											<span class="fa fa-search" aria-hidden="true"></span>
										</button>
									</span>
								</div>
								<input type="hidden" name="programId"/>
							</td>
							<th scope="col"><label><lgcom:message code="UseFlag"/></label></th>
							<td><select name="useFlag" class="form-control input-sm"></select></td>
						</tr>
					</tbody>
				</table>
			<button type="button" class="btn btn-lgd btn-sm btn-search" data-action="search" data-access="LGSYSC00150/retrieveProgramServiceList"><lgcom:message code="search"/></button>
		</form>
	</div>
	<%-- 그리드 버튼 영역 --%>
	<div class="gridControls1 module-group text-right">
		<div class="btn-toolbar">	
			<div class="btn-group">	
				<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="insert1"><span class="fa fa-plus"></span> <lgcom:message code="Add"/></button>
				<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete1"><span class="fa fa-remove"></span> <lgcom:message code="Delete"/></button>
			</div>
			<div class="btn-group">
				<button class="btn btn-gray btn-sm" type="button" role="button" data-action="save1" data-access="LGSYSC00150/saveProgramServiceList"><lgcom:message code="save"/></button>
			</div>
		</div>		
	</div>
	<%-- 그리드 버튼 영역 --%>
	<div class="gridControls2 module-group text-right">
		<div class="btn-toolbar">	
			<div class="btn-group">		
				<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="insert2"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="Add"/></button>
				<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete2"><span class="fa fa-remove" aria-hidden="true"></span> <lgcom:message code="Delete"/></button>
			</div>
			<div class="btn-group">
				<button class="btn btn-gray btn-sm" type="button" role="button" data-action="save2" data-access="LGSYSC00150/saveProgramServiceRoleList"><lgcom:message code="save"/></button>
			</div>
		</div>		
	</div>
	<%-- RealGrid 영역 --%>
	<div class="contentGrid1 grid-wrap">
		<div class="grid programServiceGrid"></div>
	</div>
	<%-- RealGrid 영역 --%>
	<div class="contentGrid2 grid-wrap">
		<div class="grid programAccessGrid"></div>
	</div>
	</section>
</div>
</body>
</html>
