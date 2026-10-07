<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGUTLC00090.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2016 LG CNS,  All rights reserved.

    설 명 : 본 화면은 Dynamic Query 목록을 조회하는 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Dynamic Query</title>
<style type="text/css">
.detailContent {
	overflow-y:auto;
	background-color:#fff !important;
	/*border:1px solid #898989;*/
	display:none;
}
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
/**
 * TODO DQ 프로그램 복제시 해당 Context 명을 변경함으로써 적용가능하다.
 */
var DQ_CONTEXT_PATH = 'lgcom';

var LGUTLC00090 = function() {
	var grid;
	var myForm = this;
	/* 팝업용 변수 선언 */
	myForm.popupInfo = {};
	// Form Util 선언
	var listForm = new FormUtil(myForm,'.searchBlock form');
	var editForm = new FormUtil(myForm,'.detailContent form');
	
	/* 화면 레이아웃 정의 */
    /*	
	myForm.setManagedLayout({
		searchBlock  :{ left:0, top:0 , right:0 },
		gridControls :{ left:0, top:SINGLE_LINE.top1, right:0 },
		contentGrid  :{ left:0, top:SINGLE_LINE.top2, right:0, bottom:0 },
		detailContent:{ left:0, top:0 , right:0, bottom:0 }
	});
	*/
	
    /* Layout Setting */
    
	myForm.setLayout( [ 
		{ name : "searchBlock",  left : 0, right : 0, top : 0 },		
		{ name : "gridControls", left : 0, right : 0, top : "searchBlock", bottom : "contentGrid"},
		{ name : "contentGrid",  left : 0, right : 0, top : "gridControls", bottom : 0 },
		{ name : "detailContent",  left : 0, right : 0, top : 0, bottom : 0 }
    ]);
	
	
	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	// Combo 생성
	var _code = new CommonCode(DQ_CONTEXT_PATH);
	_code.add('group',{queryId:'retrieveDynamicAccessGroupList', accessGroup:'${urlAddr.accessGroup}'});
	_code.add('glevel',{queryId:'retrieveCommonCodeList',codeTypeCode:'LGCOM_DYNAMIC_ACCESSL_LEVEL'});
	_code.add('elevel',{queryId:'retrieveCommonCodeList',codeTypeCode:'LGCOM_DYNAMIC_ACCESSL_LEVEL'});
	_code.execute();
	listForm.initCombo('accessGroup',_code.get('group'),{selectAll:false});
	editForm.initCombo('accessGroup',_code.get('group'),{selectAll:false});
	editForm.initCombo('accessLevel',_code.get('elevel'),{selectAll:false});
	// Access Group 초기값
	listForm.setValue({accessGroup:'${urlAddr.accessGroup}'});
	// Access Group 값이 주어지면
	if($.trim('${urlAddr.accessGroup}') != '') {
		// Access Group 비활성화
		myForm.select(".searchBlock form select[name='accessGroup']").prop('disabled',true);
	}
	// 그리드 초기화
	var grid1 = buildGrid('.dynamicQueryListGrid');
	var grid2 = buildGrid('.dynamicColumnListGrid');
	/***  이벤트 핸들러  ***/
	myForm.addEvent( "click", "button[data-action]" , function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch(action) {
			case 'search':
				// Access Group 선택 여부
				if($.trim(listForm.getValue('accessGroup')) == '') {
					Message.alert('<lgcom:message code="error.mustSelected" arguments="<lgcom:message code='AccessGroup'/>"/>');
					myForm.select(".searchBlock form select[name='accessGroup']").focus();
					return;
				}
				// 편집창 닫기
				clearEditForm();
				toggleEditForm(false);
				grid1.getGridBase().cancel();
				var param = listForm.getValue();
				grid1.loadData(DQ_CONTEXT_PATH,'lgutlc/LGUTLC00090/retrieveDynamicQueryList', param);
				break;
			// New
			case 'register':
				// 입력폼 초기화
				clearEditForm();
				// 편집창 보이기
				toggleEditForm(true,'');
				editForm.setValue({accessLevel:'C'});
				myForm.select(".detailContent form select[name='accessLevel']").trigger('change');
				break;
			// Modify
			case 'modify':
				var cgrid = grid1.getGridBase();
				cgrid.cancel();
				var curr = cgrid.getCurrent();
				if(curr.itemIndex > -1) {
					clearEditForm();
					retrieveEditForm($.trim(cgrid.getValue(curr.itemIndex,'queryId')));
				}
				break;
			// Setup Param
			case 'setparam':
				// Setup Parameter 팝업
				myForm.popupInfo['queryId'] = $.trim(editForm.getValue('queryId'));
				var setpop = new Popup(myForm,DQ_CONTEXT_PATH,'M_LGUTLC_1152','<lgcom:message code="SetupParam"/>');
				setpop.setSize(800,700);
				setpop.open(function() {
					myForm.popupInfo = null;
					myForm.popupInfo = {};
				},function() {
					myForm.popupInfo = null;
					myForm.popupInfo = {};
				});
				break;
			// Param Value
			case 'paramval':
				// Setup Parameter Value 팝업
				myForm.popupInfo['queryId'] = $.trim(editForm.getValue('queryId'));
				var valpop = new Popup(myForm,DQ_CONTEXT_PATH,'M_LGUTLC_1153','<lgcom:message code="SetupParamVal"/>');
				valpop.setSize(650,384);
				valpop.open(function() {
					myForm.popupInfo = null;
					myForm.popupInfo = {};
				},function() {
					myForm.popupInfo = null;
					myForm.popupInfo = {};
				});
				break;
			// See SQL
			case 'viewsql':
				myForm.popupInfo['queryId'] = $.trim(editForm.getValue('queryId'));
				// Input Parameter Popup Open
				var iapop = new Popup(myForm,DQ_CONTEXT_PATH,'M_LGUTLC_1155','<lgcom:message code="inputParam"/>');
				iapop.setSize(450,600);
				iapop.open(function() {
					// Preview SQL Popup Open
					var pvpop = new Popup(myForm,DQ_CONTEXT_PATH,'M_LGUTLC_1154','<lgcom:message code="PreviewSQL"/>');
					pvpop.setSize(800,600);
					pvpop.open(function() {
						myForm.popupInfo = null;
						myForm.popupInfo = {};
					},function() {
						myForm.popupInfo = null;
						myForm.popupInfo = {};
					});
				},function() {
					myForm.popupInfo = null;
					myForm.popupInfo = {};
				});
				break;
			// Test Value
			case 'testsql':
				myForm.popupInfo['queryId'] = $.trim(editForm.getValue('queryId'));
				// Input Parameter Popup Open
				var iapop = new Popup(myForm,DQ_CONTEXT_PATH,'M_LGUTLC_1155','<lgcom:message code="inputParam"/>');
				iapop.setSize(450,384);
				iapop.open(function() {
					var args = {
						queryMode: 'TEST',
						queryId: $.trim(myForm.popupInfo['queryId']),
						sqlArg: {}
					};
					if(myForm.popupInfo.selData) {
						for(key in myForm.popupInfo.selData) {
							args['sqlArg'][key] = $.trim(myForm.popupInfo.selData[key]);
						}
					}
					// Dynamic Query Preview를 조회한다.
					transaction_sync(DQ_CONTEXT_PATH,'lgutlc/LGUTLC00090/retrieveDynamicQueryTest',args,function(data) {
						if(data.result) {
							if(data.result.cnt == 0) {
								Message.alert('<lgcom:message code="note.nodata"/>');
							} else {
								Message.alert('<lgcom:message code="note.selectedRow" arguments="'+data.result.cnt+'"/>');
							}
						}
					},function(msg) {
						Message.alert(msg);
					});
				},function() {
					myForm.popupInfo = null;
					myForm.popupInfo = {};
				});
				break;
			// Save
			case 'save':
				try {
					grid2.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				if(!validateEditForm()) return;
				Message.confirm('<lgcom:message code="question.save"/>', function() {
					// 저장을 위한 Param Data 조합
					var param = editForm.getValue();
					// 컬럼 목록
					param['columns'] = grid2.getChangedRows();
					// 저장
					transaction_sync(DQ_CONTEXT_PATH,'lgutlc/LGUTLC00090/saveDynamicQueryInfo',param,function(data) {
						// 완료 메세지
						Message.notify('<lgcom:message code="note.completed"/>');
						// Access Group 갱신
						refreshAccessGroupCombo(data.result.accessGroup);
						// 편집창 갱신
						clearEditForm();
						retrieveEditForm($.trim(data.result.queryId));
					});
				});
				break;
			// List
			case 'list':
				// 입력폼 초기화
				clearEditForm();
				toggleEditForm(false);
				break;
			// Column Add
			case 'add':
				var cgrid = grid2.getGridBase();
				cgrid.commit();
				if(cgrid.getItemCount() >= 70) {
					Message.alert('<lgcom:message code="error.tenrows" arguments="70"/>');
					return;
				}
				cgrid.beginAppendRow();
				// Query Id
				cgrid.setValue(cgrid.getCurrent().itemIndex,'queryId',$.trim(myForm.select(".detailContent form input[name='queryId']").val()))
				// Column Seq
				if(cgrid.getItemCount() == 1) {
					cgrid.setValue(cgrid.getCurrent().itemIndex,'columnSeq',1);
				} else {
					cgrid.setValue(cgrid.getCurrent().itemIndex,'columnSeq',cgrid.getValue(cgrid.getCurrent().itemIndex-1,'columnSeq')+1);
				}
				// Data Type
				cgrid.setValue(cgrid.getCurrent().itemIndex,'dataType','C');		// Character
				cgrid.setCurrent({column:'columnPrompt'});
				cgrid.setFocus();
				break;
			// Column Delete
			case 'del':
				grid2.getGridBase().deleteSelection(true);
				break;
		}
	});
	myForm.addEvent('change',".detailContent form select[name='accessLevel']",function(event) {
		var val = $.trim($(event.target).find('>option:selected').val());
		if(val == 'G') {
			myForm.select(".detailContent form input[name='accessGroup']").addClass('input-require');
			myForm.select(".detailContent form input[name='accessGroup']").prop('disabled',false);
		} else {
			myForm.select(".detailContent form input[name='accessGroup']").val('');
			myForm.select(".detailContent form input[name='accessGroup']").removeClass('input-require');
			myForm.select(".detailContent form input[name='accessGroup']").prop('disabled',true);
		}
	});
	grid1.getGridBase().onDataCellDblClicked = function(cgrid, index) {
		if(index.itemIndex > -1) {
			clearEditForm();
			retrieveEditForm($.trim(cgrid.getValue(index.itemIndex,'queryId')));
		}
	};
	grid2.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		var provider = cgrid.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';
		// 신규행이 아니면 편집 불가
		if(!editable) {
		} else {
			cgrid.setCellStyles(newRow,'columnSeq','addStyle');
			cgrid.setCellStyles(newRow,'columnPrompt','addStyle');
			cgrid.setCellStyles(newRow,'columnField','addStyle');
			cgrid.setCellStyles(newRow,'dataType','addStyle');
		}
	};
	grid2.getGridBase().onEditCommit = function(cgrid,index,oldValue,newValue) {
		if(index.column == 'dataType') {
			if($.trim(cgrid.getValue(index.itemIndex,index.column)) == 'N') {
			} else {
			}
		}
	};
	/***  내부 함수  ***/
	// 그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId, {statusBar : "N"});
		switch(gridId) {
			case '.dynamicQueryListGrid':
				grid.setPagingMode(true);
				// Grid Field Set
				grid.setFields([
					{ fieldName:'queryId'        , dataType:'number' },
					{ fieldName:'queryName'       },
					{ fieldName:'queryDesc'       },
					{ fieldName:'accessLevel'     },
					{ fieldName:'accessLevelName' },
					{ fieldName:'accessGroup'     }
				]);
				// Lookup 조회, key 속성에 lookup에 매핑될 lookupSourceId 값을 사용한다.
				grid.setLookups({
					'accessLevelCode':_code.get('glevel')
				});
				// Grid Column Set
				grid.setColumns([
					{
						name:'queryName',
						fieldName:'queryName',
						width:300,
						header: {text:'<lgcom:message code="QueryName"/>'},
						editable: false
					},
					{
						name:'queryDesc',
						fieldName:'queryDesc',
						width:250,
						header: {text:'<lgcom:message code="Description"/>'},
						editable: false
					},
					{
						name:'accessLevel',
						fieldName:'accessLevel',
						width:80,
						header: {text:'<lgcom:message code="AccessLevel"/>'},
						styles: {textAlignment:'center'},
						lookupDisplay: true,
						lookupSourceId: 'accessLevelCode',
						lookupKeyFields: ['accessLevel'],
						editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'},
						editable: false
					},
					{
						name:'accessGroup',
						fieldName:'accessGroup',
						width:80,
						header: {text:'<lgcom:message code="AccessGroup"/>'},
						styles: {textAlignment:'center'},
						editable: false
					}
				]);
				grid.setOptions({
					grid: {
						hideDeletedRows:false,
						indicator: {visible:false},
						panel: {visible:false},
						checkBar: {visible:false},
						stateBar: {visible:false},
						footer: {visible:false},
						statusBar : {visible:false},
						edit: {
							insertable: false,
							appendable: false,
							updatable: false,
							deletable: false
						}
					},
					dataProvider: {
						insertable: false,
						updatable: false,
						deletable: false,
						softDeleting: true,
						deleteCreated: true
					},
					display: { fitStyle: 'none' }
				});
				break;
			case '.dynamicColumnListGrid':
				grid.setPagingMode(false);
				// Grid Field Set
				grid.setFields([
					{ fieldName:'queryId'     , dataType:'number' },
					{ fieldName:'columnSeq'   , dataType:'number' },
					{ fieldName:'columnPrompt' },
					{ fieldName:'columnField'  },
					{ fieldName:'dataType'     },
					{ fieldName:'columnLength', dataType:'number' },
					{ fieldName:'columnWidth' , dataType:'number' },
					{ fieldName:'formatMask'   }
				]);
				// Grid Column Set
				grid.setColumns([
					{
						name:'columnSeq',
						fieldName:'columnSeq',
						width:60,
						header: {text:'<lgcom:message code="columnSeq"/>', required: true},
						editor: {
							type: 'number',
							positiveOnly: true,
							integerOnly: true
						},
						styles: {textAlignment:'far'}
					},
					{
						name:'columnPrompt',
						fieldName:'columnPrompt',
						width:200,
						header: {text:'<lgcom:message code="Prompt"/>', required: true},
					},
					{
						name:'columnField',
						fieldName:'columnField',
						width:200,
						header: {text:'<lgcom:message code="FieldDefinition"/>', required: true},
					},
					{
						name:'dataType',
						fieldName:'dataType',
						width:100,
						header: {text:'<lgcom:message code="DataType"/>', required: true},
						styles: {textAlignment:'center'},
						lookupDisplay: true,
						values: ['C','N','D','T'],
						labels: ['Character','Number','Date','DateTime'],
						editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
					},
					{
						name:'columnLength',
						fieldName:'columnLength',
						width:70,
						header: {text:'<lgcom:message code="Length"/>'},
						editor: {
							type: 'number',
							positiveOnly: true,
							integerOnly: true
						},
						styles: {textAlignment:'far'}
					},
					{
						name:'formatMask',
						fieldName:'formatMask',
						width:120,
						header: {text:'<lgcom:message code="FormatMask"/>'}
					},
					{
						name:'columnWidth',
						fieldName:'columnWidth',
						width:70,
						header: {text:'<lgcom:message code="Width"/>'},
						editor: {
							type: 'number',
							positiveOnly: true
						},
						styles: {textAlignment:'far'}
					}
				]);
				grid.setOptions({
					grid: {
						hideDeletedRows:false,
						indicator: {visible:false},
						panel: {visible:false},
						checkBar: {visible:false},
						footer: {visible:false},
						statusBar : {visible:false},
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
				// Validation Set
				grid.setValidations([
					{criteria: "value['columnSeq'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='columnSeq'/>"/>',mode:'always',level:'error'},
					{criteria: "value['columnPrompt'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='Prompt'/>"/>',mode:'always',level:'error'},
					{criteria: "value['columnField'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='FieldDefinition'/>"/>',mode:'always',level:'error'},
					{criteria: "value['dataType'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='DataType'/>"/>',mode:'always',level:'error'}
				]);
				break;
		}
		// Context Menu Set
		grid.setContextMenu();
		return grid;
	}
	// 입력폼 초기화
	function clearEditForm() {
		grid2.getGridBase().cancel();
		grid2.getDataProvider().clearRows();
		myForm.select(".detailContent input[name='queryId']").val('');
		myForm.select(".detailContent span[data-action='queryId']").empty();
		editForm.clear();
		myForm.select(".detailContent form select[name='accessLevel']").val('');
	}
	// 입력폼 보이기/숨기기
	function toggleEditForm(flag,queryId) {
		queryId = $.trim(queryId);
		if(flag) {
			if(queryId == '') {
				// Setup Param 숨기기
				myForm.select(".detailContent button[data-action='setparam']").hide();
				// Param Value 숨기기
				myForm.select(".detailContent button[data-action='paramval']").hide();
				// See SQL 숨기기
				myForm.select(".detailContent button[data-action='viewsql']").hide();
				// Test SQL 숨기기
				myForm.select(".detailContent button[data-action='testsql']").hide();				
			} else {
				// Setup Param 보이기
				myForm.select(".detailContent button[data-action='setparam']").show();
				// Param Value 보이기
				myForm.select(".detailContent button[data-action='paramval']").show();
				// See SQL 보이기
				myForm.select(".detailContent button[data-action='viewsql']").show();
				// Test SQL 보이기
				myForm.select(".detailContent button[data-action='testsql']").show();
				
			}
			$('.container .contentGrid').hide();
			$('.container .detailContent').show();
			grid2.getGridBase().resetSize();
		} else {
			$('.container .contentGrid').show();
			$('.container .detailContent').hide();
			grid1.getGridBase().resetSize();
		}
	}
	// 입력폼 조회
	function retrieveEditForm(queryId) {
		var param = {'queryId':$.trim(queryId)};
		transaction_sync(DQ_CONTEXT_PATH,'lgutlc/LGUTLC00090/retrieveDynamicQueryDetail',param,function(data) {
			// 쿼리 상세내역 세팅
			if(data.result) {
				myForm.select(".detailContent input[name='queryId']").val($.trim(data.result.queryId));
				myForm.select(".detailContent span[data-action='queryId']").html($.trim(data.result.queryId));
				editForm.setValue({
					queryName: $.trim(data.result.queryName),
					queryDesc: $.trim(data.result.queryDesc),
					accessLevel: $.trim(data.result.accessLevel),
					accessGroup: $.trim(data.result.accessGroup),
					hintClause: $.trim(data.result.hintClause),
					fromClause: $.trim(data.result.fromClause),
					whereClause: $.trim(data.result.whereClause),
					orderByClause: $.trim(data.result.orderByClause)
				});
				myForm.select(".detailContent form select[name='accessLevel']").trigger('change');
				// Distinct Flag
				if($.trim(data.result.distinctFlag) == 'Y') {
					myForm.select(".detailContent .dataBlock input[type='checkbox'][name='distinctFlag']").prop('checked',true);
				} else {
					myForm.select(".detailContent .dataBlock input[type='checkbox'][name='distinctFlag']").prop('checked',false);
				}
				// 컬럼 목록을 조회한다.
				grid2.loadData(DQ_CONTEXT_PATH,'lgutlc/LGUTLC00090/retrieveDynamicQueryColumnList',param,function() {
					// 편집창 보이기
					toggleEditForm(true,$.trim(queryId));
				});
			}
		});
	}
	// 입력폼 유효성 체크
	function validateEditForm() {
		// 유효성 체크
		// 1. 쿼리명
		if($.trim(editForm.getValue('queryName')) == '') {
			Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='QueryName'/>"/>');
			myForm.select(".detailContent form input[name='queryName']").focus();
			return false;
		}
		// 2. Access Level
		if($.trim(editForm.getValue('accessLevel')) == '') {
			Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='AccessLevel'/>"/>');
			myForm.select(".detailContent form select[name='accessLevel']").focus();
			return false;
		}
		// 3. Access Level이 Group일 경우 Access Group
		if($.trim(editForm.getValue('accessLevel')) == 'G') {
			if($.trim(editForm.getValue('accessGroup')) == '') {
				Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='AccessGroup'/>"/>');
				myForm.select(".detailContent form select[name='accessGroup']").focus();
				return false;
			}
		}
		// 4. 등록된 Column 개수
		if(grid2.getGridBase().getItemCount() == 0) {
			Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='Column'/>"/>');
			return false;
		}
		// 5. FROM절 입력 여부
		if($.trim(editForm.getValue('fromClause')) == '') {
			Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='From'/>"/>');
			myForm.select(".detailContent form select[name='fromClause']").focus();
			return false;
		}
		// 6. WHERE절 입력 여부
		if($.trim(editForm.getValue('whereClause')) == '') {
			Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='where'/>"/>');
			myForm.select(".detailContent form select[name='whereClause']").focus();
			return false;
		}
		// 7. ORDERBY절 입력 여부
		if($.trim(editForm.getValue('orderByClause')) == '') {
			Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='OrderBy'/>"/>');
			myForm.select(".detailContent form select[name='orderByClause']").focus();
			return false;
		}
		return true;
	}
	// Access Group 목록 갱신
	function refreshAccessGroupCombo(initVal) {
		_code.add('group',{queryId:'retrieveDynamicAccessGroupList', accessGroup:'${urlAddr.accessGroup}'});
		_code.execute();
		listForm.initCombo('accessGroup',_code.get('group'),{selectAll:false});
		listForm.setValue({accessGroup:initVal});
	}
};

LGUTLC00090.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch( function(){
		var form = new LGUTLC00090();
		form.init();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Dynamic Query</h2>
	</div>
	<div class="searchBlock">
		<form class="search-wrap form" method="post" action="">
				<table class="table">
					<colgroup>
						<col width="90" />
						<col width="110" />
						<col width="90" />
						<col width="280" />
						<col width="*" />
					</colgroup>
					<tbody>
						<tr>
							<th scope="col"><label class="required"><i class="asterisk">*</i><lgcom:message code="AccessGroup"/></label></th>
							<td><select name="accessGroup" class="form-control input-sm input-require"></select></td>
							<th scope="col"><label><lgcom:message code="QueryName"/></label></th>
							<td><input type="text" name="queryName" class="form-control input-sm"></td>
						</tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
		</form>
	</div>
	<div class="gridControls module-group text-right">
		<div class="btn-toolbar">	
			<div class="btn-group">	
				<button class="btn btn-default btn-sm" type="button" data-action="register"><lgcom:message code="New"/></button>
				<button class="btn btn-default btn-sm" type="button" data-action="modify"><lgcom:message code="Modify"/></button>
			</div>
		</div>		
	</div>	
	<div class="contentGrid grid-wrap">
		<div class="grid dynamicQueryListGrid"></div>
	</div>
	<div class="detailContent">
		<div class="module-group clearfix">
			<div class="pull-left sub-header">
				<h3><lgcom:message code="SetupDynamicQuery"/></h3>
			</div>
			<div class="pull-right">
				<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save"><lgcom:message code="save"/></button>
				<button class="btn btn-default btn-sm" type="button" role="button" data-action="list"><lgcom:message code="list"/></button>
			</div>
		</div>
		<form class="form" method="post" action="">
			<input type="hidden" name="queryId"/>
			<div class="dataBlock">
				<table class="table">
					<colgroup>
						<col width="15%"/>
						<col width="35%"/>
						<col width="15%"/>
						<col width="35%"/>
					</colgroup>
					<tbody>
						<tr>
							<th scope="col"><label><lgcom:message code="QueryId"/></label></th>
							<td><span data-action="queryId"></span></td>
							<th scope="col"><label class="required"><lgcom:message code="QueryName"/></label></th>
							<td><input type="text" name="queryName" class="form-control input-sm input-require" placeholder="" /></td>
						</tr>
						<tr>
							<th scope="col"><label><lgcom:message code="Description"/></label></th>
							<td colspan="3"><input type="text" name="queryDesc" class="form-control input-sm" placeholder="" /></td>
						</tr>
						<tr>
							<th scope="col"><label class="required"><lgcom:message code="AccessLevel"/></label></th>
							<td><select name="accessLevel" class="form-control input-sm input-require size_100"></select></td>
							<th scope="col"><label class="required"><lgcom:message code="AccessGroup"/></label></th>
							<td><select name="accessGroup" class="form-control input-sm input-require size_130"></select></td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="btn-wrap module-group text-right" style="margin-top:10px">
				<div class="text-right">
					<button class="btn btn btn-default btn-sm" type="button" role="button" data-action="setparam"><lgcom:message code="setupParam"/></button>
					<button class="btn btn btn-default btn-sm" type="button" role="button" data-action="paramval"><lgcom:message code="paramValue"/></button>
					<button class="btn btn btn-default btn-sm" type="button" role="button" data-action="viewsql"><lgcom:message code="seeSQL"/></button>
					<button class="btn btn btn-default btn-sm" type="button" role="button" data-action="testsql"><lgcom:message code="testSQL"/></button>
				</div>
			</div>
			<div class="dataBlock">
				<table class="table table-condensed">
					<colgroup>
						<col width="15%"/>
						<col width="15%"/>
						<col width="15%"/>
						<col width="55%"/>
					</colgroup>
					<tbody>
						<tr>
							<th scope="col"><label><lgcom:message code="select"/></label></th>
							<td>
								<div class="checkbox checkbox-uxp checkbox-inline">
									<input type="checkbox" id="${param.bizFormId}_distinct" name="distinctFlag" value="N"/>
									<label for="${param.bizFormId}_distinct"><lgcom:message code="distinct"/></label>
								</div>
							</td>
							<th scope="col"><label><lgcom:message code="hint"/></label></th>
							<td><input type="text" name="hintClause" class="form-control input-sm"/></td>
						</tr>
						<tr>
							<th scope="col"><label><lgcom:message code="Column"/></label></th>
							<td colspan="3">
							  <div class="dynamicColumnList" style="height:320px;margin-bottom:5px;overflow:hidden">
								<div class="btn-wrap text-right" style="margin:5px">
									<button type="button" class="btn btn-default btn-xs ico-lgd" data-action="add"><span class="fa fa-plus"></span> <lgcom:message code="Add"/></button>
									<button type="button" class="btn btn-default btn-xs ico-lgd" data-action="del"><span class="fa fa-minus"></span> <lgcom:message code="Delete"/></button>
								</div>
								<div class="grid dynamicColumnListGrid grid-wrap" ></div>
							</td>
						</tr>
						<tr>
							<th scope="col"><label><lgcom:message code="From"/></label></th>
							<td colspan="3"><textarea name="fromClause" class="form-control input-sm input-require" style="margin-top:5px;" rows="6" placeholder="FROM&#10;    table_name alias,"></textarea></td>
						</tr>
						<tr>
							<th scope="col"><label><lgcom:message code="where"/></label></th>
							<td colspan="3"><textarea name="whereClause" class="form-control input-sm input-require" style="margin-top:5px;" rows="6" placeholder="WHERE rownum < [Variable]&#10;&#10;group by&#10;&#10;having"></textarea></td>
						</tr>
						<tr>
							<th scope="col"><label><lgcom:message code="OrderByClause"/></label></th>
							<td colspan="3"><input type="text" name="orderByClause" class="form-control input-sm input-require" placeholder="ORDER BY 1,2,3" /></td>
						</tr>
					</tbody>
				</table>
			</div>
		</form>
	</div>
	</section>
</div>
</body>
</html>
