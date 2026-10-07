
<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGSYSC00090.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 role 정보를 관리하는 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Role List</title>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGSYSC00090 = function() {
	var myForm = this;
	var formUtil = new FormUtil(myForm,'.searchBlock form');

    /* Layout Setting */
	myForm.setLayout( [ 
		{ name : "searchBlock",  left : 0, right : 0, top : 0 },		
		{ name : "gridControls", left : 0, right : 0, top : "searchBlock", bottom : "contentGrid"},
		{ name : "contentGrid",  left : 0, right : 0, top : "gridControls", bottom : 0 }		
    ]);	

	// combo 목록 조회
	var code = new CommonCode("lgcom");
	code.add( "LGCOM_SYSTEM_CODE", { codeTypeCode:'LGCOM_SYSTEM_CODE' });
	code.add( "LGCOM_MODULE_CODE", { codeTypeCode:'LGCOM_MODULE_CODE' });
	code.execute();

	formUtil.initCombo( "systemCode", code.get("LGCOM_SYSTEM_CODE"), {selectAll : true } );
	formUtil.initCombo( "moduleCode", code.get("LGCOM_MODULE_CODE"), {selectAll : true, filter : "systemCode" } );

	var grid = buildGrid(".LGSYSC00090_grid");


	/*** 이벤트 핸들러  ***/
	this.addEvent( "click", "button[data-action], button[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ){
			case "search" :
				grid.getGridBase().cancel();
				var param =  myForm.select(".searchBlock form").toJSON();
				grid.loadData('lgcom', 'lgsysc/LGSYSC00090/retrieveRoleList', param );
				if(grid.getDataProvider().getRowCount() > 0){
					var index = {itemIndex: 0};
					grid.getGridBase().setCurrent(index);
				}

				break;

			case "save" :
				try {
					grid.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				//grid.getGridBase().commit();
				if( grid.getRowCount() == 0 ) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};

				// 변경건이 있는지 체크
				if(!grid.isChanged()) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				}
				Message.confirm( '<lgcom:message code="question.save"/>' , function() {
					grid.useProgress(true);
					grid.saveChanges( "lgcom", 'lgsysc/LGSYSC00090/saveRoleList', function(data) {
						Message.notify('<lgcom:message code="note.completed"/>');
						// 저장 완료후 목록 재조회
						myForm.select(".searchBlock button[data-action='search']").trigger('click');
					});
				});

				break;

			case "add" :
				var cgrid = grid.getGridBase();
				cgrid.commit();

				if(cgrid.getCurrent().itemIndex < 0) {
					cgrid.beginAppendRow();
					var sel = {startItem: 0, endItem: 0, style: "none"};
					cgrid.setSelection(sel);
				} else {
					startItem = cgrid.getSelection().startItem;
					var sel = {startItem: startItem, endItem: 0, style: "none"};
					cgrid.setSelection(sel);
					cgrid.beginInsertRow(cgrid.getCurrent().itemIndex);

				}
				var currCell = cgrid.getCurrent();
				cgrid.setValue(currCell.itemIndex,'systemCode','');
				cgrid.setValue(currCell.itemIndex,'moduleCode','');
				cgrid.setValue(currCell.itemIndex,'roleCode','');
				cgrid.setValue(currCell.itemIndex,'roleName','');
				cgrid.setValue(currCell.itemIndex,'roleDesc','');
				grid.getGridBase().setFocus();
				break;

			case "delete" :
				grid.getGridBase().deleteSelection(true);
				grid.getGridBase().setSelectOptions( {style : "rows"});
				break;

			case 'purge':
				var cgrid = grid.getGridBase();
				cgrid.cancel();
				if(cgrid.getItemCount() < 1) return;
				if(cgrid.getCurrent().itemIndex < 0) return;
				Message.confirm('<lgcom:message code="question.reallyDelete"/>', function() {
					var param = cgrid.getValues(cgrid.getCurrent().itemIndex);
					transaction('lgcom','lgsysc/LGSYSC00090/deleteRoleCodePhysical',param,function(data) {
						Message.notify('<lgcom:message code="note.completed"/>');
						// 저장 완료후 목록 재조회
						myForm.select(".searchBlock button[data-action='search']").trigger('click');
					});
				});
				break;
		}
		event.stopPropagation();
	});

	/* 그리드 이벤트 처리 */
	grid.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		var provider = grid.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';
		var rstyle   = cgrid.addCellStyle('required',{background:'#ffffffaa'}, true);
		// 신규행이 아니면 Role Code 컬럼 편집 불가
		if(!editable) {
			cgrid.setColumnProperty('roleCode','editable',false);
			myForm.select(".gridControls button[data-action='delete']").attr('disabled','disabled');
		} else {
			cgrid.setColumnProperty('roleCode','editable',true);
			myForm.select(".gridControls button[data-action='delete']").removeAttr('disabled');
			cgrid.setCellStyles(newRow,'systemCode','required');
			cgrid.setCellStyles(newRow,'moduleCode','required');
			cgrid.setCellStyles(newRow,'roleCode','required');
			cgrid.setCellStyles(newRow,'roleName','required');
			cgrid.setCellStyles(newRow,'applyStartDate','required');
		}
	};

	//role code 입력시 중복체크
	grid.getGridBase().onCurrentChanging =  function (grid, oldIndex, newIndex) {
		var editRow = oldIndex.dataRow;
		var editable = editRow < 0 || grid.getDataProvider().getRowState(editRow) === 'created';
		if( editable && ( oldIndex.fieldIndex == grid.getDataProvider().getFieldIndex('roleCode') ) ){
			var value = grid.getValue(oldIndex.itemIndex, oldIndex.fieldIndex);
			var param = {roleCode : value};
			var result;
			transaction_sync( "lgcom", "lgsysc/LGSYSC00090/retrieveRoleCode", param, function(data){
				result = data.result;
			});
			//데이터가 있다 -> 중복이 있다의 의미
			if( result ){
				Message.error('<lgcom:message code="error.duplicateValue"/>');
			}
		 }
	};

	grid.getGridBase().onEditCommit = function(cgrid, index, oldValue, newValue) {
		if(index.column == 'systemCode') {
			var exists = cgrid.existsLookupData('moduleCode',[newValue,cgrid.getValue(index.itemIndex,'moduleCode')]);
			if(!exists) {
				var moduleLookup = code.get('LGCOM_MODULE_CODE');
				var moduleCode = '';
				for(var i=0; i < moduleLookup.length; i++) {
					if($.trim(moduleLookup[i]['pCode']) == newValue) {
						moduleCode = $.trim(moduleLookup[i]['code']);
						break;
					}
				}
				cgrid.setValue(index.itemIndex,'moduleCode',moduleCode);
			}
		}
	};

	/*** 중복체크 함수  ***/
	function checkDuplicateProgramId(param) {
		var rslt = false;
		transaction_sync( "lgcom", "lgsysc/LGSYSC00090/retrieveRoleCode",param,function(data) {
			rslt = data.result;
		});
		return rslt;
	}

	grid.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	};

	/*** 내부 함수  ***/
	//그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		//옵션 설정
		grid.setOptions({
			grid: {
				softDeleting: true,
				deleteCreated: true,
				hideDeletedRows:false,
				indicator: {visible:false},
				panel: {visible:false},
				checkBar: {visible:false},
				stateBar: {visible:true},
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

		//필드 설정
		grid.setFields([
			{ fieldName:'systemCode'     , dataType:'text'  },
			{ fieldName:'moduleCode'     , dataType:'text'  },
			{ fieldName:'roleCode'       , dataType:'text'  },
			{ fieldName:'roleName'       , dataType:'text'  },
			{ fieldName:'roleDesc'       , dataType:'text'  },
			{ fieldName:'applyStartDate' , dataType:'text'  },
			{ fieldName:'applyEndDate'   , dataType:'text'  },
			{ fieldName:'menuFlag'       , dataType:'text'  },
			{ fieldName:'orgFlag'        , dataType:'text'  }
		]);
		//마우스 오른쪽 클릭시 메뉴
		grid.setContextMenu();

		grid.setLookupsMultiLvl({
			'systemCode': code.get('LGCOM_SYSTEM_CODE'), 'moduleCode': {data:code.get('LGCOM_MODULE_CODE'), keyField:['pCode','code']},
		});

		//컬럼 설정
		grid.setColumns([
			{
				name:'systemCode',
				fieldName:'systemCode',
				width:100,
				header: {text:'<lgcom:message code="System" />', required: true},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'systemCode',
				lookupKeyFields: ['systemCode'],
				editor: {type:'dropDown',textReadOnly:true}
			},
			{
				name:'moduleCode',
				fieldName:'moduleCode',
				width:100,
				header: {text:'<lgcom:message code="Module"/>', required: true},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'moduleCode',
				lookupKeyFields: ['systemCode','moduleCode'],
				editor: {type:'dropDown',textReadOnly:true}
			},
			{
				name:'roleCode',
				fieldName:'roleCode',
				width:150,
				header: {text:'<lgcom:message code="RoleCode"/>', required: true},
			},
			{
				name:'roleName',
				fieldName:'roleName',
				width:150,
				header: {text:'<lgcom:message code="RoleName"/>', required: true},
			},
			{
				name:'roleDesc',
				fieldName:'roleDesc',
				width:150,
				header: {text:'<lgcom:message code="RoleDesc"/>'}
			},
			{
				type:'group',
				orientation:'horizontal',
				height:60,
				width:200,
				header : { text : '<lgcom:message code="ApplyDate"/>' , styles : { fontBold: "true"}  },
				columns: [
					{
						name:'applyStartDate',
						fieldName:'applyStartDate',
						width:100,
						type: 'data',
						header: {text:'<lgcom:message code="StartDate"/>', required: true},
						styles: {textAlignment:'center'},
						editor: {type:'date',datetimeFormat:'yyyy-MM-dd'}
					},
					{
						name:'applyEndDate',
						fieldName:'applyEndDate',
						width:100,
						type: 'data',
						header: {text:'<lgcom:message code="EndDate"/>'},
						styles: {textAlignment:'center'},
						editor: {type:'date',datetimeFormat:'yyyy-MM-dd'}
					}
				]
			},
			{
				name:'menuFlag',
				fieldName:'menuFlag',
				width:150,
				header: {text:'<lgcom:message code="MenuExistFlag"/>'},
				styles: {textAlignment:'center'},
				editable: false
			},
			{
				name:'orgFlag',
				fieldName:'orgFlag',
				width:150,
				header: {text:'<lgcom:message code="OrgExistFlag"/>'},
				styles: {textAlignment:'center'},
				editable: false
			},
		]);

		grid.setValidations([
			{criteria: "value['systemCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='System'/>"/>',mode:'always',level:'error'},
			{criteria: "value['moduleCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='Module'/>"/>',mode:'always',level:'error'},
			{criteria: "value['roleCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='RoleCode'/>"/>',mode:'always',level:'error'},
			{criteria: "value['roleName'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='RoleName'/>"/>',mode:'always',level:'error'},
			{criteria: "value['applyStartDate'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='StartDate'/>"/>',mode:'always',level:'error'}
		]);
		return grid;
	}
}

LGSYSC00090.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGSYSC00090();
		form.init();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
		<h2><lgcom:message code="RoleList"/></h2>
	</div>
	<div class="searchBlock">
		<form class="form search-wrap">
				<table class="table" >
					<colgroup>
						<col width="90">
						<col width="90">
						<col width="90">
						<col width="90">
						<col width="120">
						<col width="180">
						<col width="120">
						<col width="220">
					</colgroup>
					<tbody>
						<tr>
							<th><label class="required"><lgcom:message code="System" /></label></th>
							<td><select class="form-control input-sm" name="systemCode"></select></td>
							<th><label><lgcom:message code="Module" /></label></th>
							<td><select class="form-control input-sm" name="moduleCode"></select></td>
							<th><label><lgcom:message code="RoleCode" /></label></th>
							<td><input type="text" class="form-control input-sm uppercase" name="roleCode"></td>
							<th><label><lgcom:message code="RoleName" /></label></th>
							<td><input type="text" class="form-control input-sm" name="roleName"></td>
						</tr>
					</tbody>
				</table>
			<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
		</form>
	</div>
	<div class="gridControls module-group text-right" >
			<div class="btn-toolbar">
			    <div class="btn-group">	
					<button class="btn btn-default btn-sm ico-lgd" type="submit" data-action="add"><span class="fa fa-plus"  aria-hidden="true"></span><lgcom:message code="add"/></button>
					<button class="btn btn-default btn-sm ico-lgd" type="submit" data-action="delete"><span class="fa fa-minus"  aria-hidden="true"></span><lgcom:message code="delete"/></button>
				</div>
			    <div class="btn-group">				
					<button class="btn btn-darkgray btn-sm" type="submit" data-action="purge" data-access="LGSYSC00090/deleteRoleCodePhysical"><lgcom:message code="ForceDelete"/></button>
					<button class="btn btn-gray btn-sm" type="submit" data-action="save"><lgcom:message code="save"/></button>
				</div>
			</div>		
	</div>
	<div class="contentGrid grid-wrap">
		<div class="grid LGSYSC00090_grid"></div>
	</div>
	</section>
</div>
</body>
</html>
