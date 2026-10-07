<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGUTLC00407.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : Contact Point
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Contact Point</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGUTLC00407 = function() {
	var myForm = this;
	var formUtil = new FormUtil(myForm,'.searchBlock form');
    /*
	myForm.setManagedLayout({
		searchBlock :{ left:0, top:0 , right:0 },
		contentGrid :{ left:0, top:SINGLE_LINE.top1, right:0, bottom:0 }
	});
    */
    /* Layout Setting */
	myForm.setLayout( [ 
		{ name : "searchBlock",  left : 0, right : 0, top : 0 },		
		{ name : "contentGrid",  left : 0, right : 0, top : "searchBlock", bottom : 0 }		
    ]);	    
 
	// combo 목록 조회
	var code = new CommonCode("lgcom");
	code.add( "LGCOM_SYSTEM_CODE", { codeTypeCode:'LGCOM_SYSTEM_CODE' });
	code.add( "LGCOM_MODULE_CODE", { codeTypeCode:'LGCOM_MODULE_CODE' });
	code.execute();

	formUtil.initCombo( "systemCode", code.get("LGCOM_SYSTEM_CODE"), {selectAll : true } );
	formUtil.initCombo( "moduleCode", code.get("LGCOM_MODULE_CODE"), {selectAll : true, filter : "systemCode" } );

	var grid = buildGrid(".LGUTLC00407_grid");
	
	
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
				var param =  formUtil.getValue();
				grid.loadData('lgcom', 'lgutlc/LGUTLC00407/retrieveSystemContactUserList', param, function(){
					if(grid.getDataProvider().getRowCount() > 0){
						var index = {itemIndex: 0};
						grid.getGridBase().setCurrent(index);
					}
				});
				
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
					grid.saveChanges( "lgcom", 'lgutlc/LGUTLC00407/saveSystemContactUserList', function(data) {
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
			cgrid.setColumnProperty('systemCode','editable',false);
			cgrid.setColumnProperty('moduleCode','editable',false);
			myForm.select(".gridControls button[data-action='delete']").attr('disabled','disabled');
		} else {
			cgrid.setColumnProperty('systemCode','editable',true);
			cgrid.setColumnProperty('moduleCode','editable',true);
			myForm.select(".gridControls button[data-action='delete']").removeAttr('disabled');
			cgrid.setCellStyles(newRow,'systemCode','required');
			cgrid.setCellStyles(newRow,'moduleCode','required');
		}
	};
	/* 
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
	}; */

	
	/*** 중복체크 함수  ***/
	/* function checkDuplicateProgramId(param) {
		var rslt = false;
		transaction_sync( "lgcom", "lgutlc/LGUTLC00407/retrieveSystemContactUserList",param,function(data) {
			rslt = data.result;
		});
		return rslt;
	} */

	grid.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	};

	/*** 내부 함수  ***/
	//그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId, {statusBar : "N"});
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
					insertable: false,  
					appendable: false,
					updatable: false,
					deletable: false
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
			{ fieldName:'systemCode'     		, dataType:'text'  },
			{ fieldName:'moduleCode'     		, dataType:'text'  },
			{ fieldName:'smEmployeeNumber'  	, dataType:'text'  },
			{ fieldName:'smName'         		, dataType:'text'  },
			{ fieldName:'smOrganizationNameEng'	, dataType:'text'  },
			{ fieldName:'piEmployeeNumber'  	, dataType:'text'  },
			{ fieldName:'piName'         		, dataType:'text'  },
			{ fieldName:'piOrganizationNameEng' , dataType:'text'  },
			{ fieldName:'piOfficePhoneNumber'   , dataType:'text'  }
		]);
		//마우스 오른쪽 클릭시 메뉴
		grid.setContextMenu();

		grid.setLookupsMultiLvl({
			'systemCode': code.get('LGCOM_SYSTEM_CODE'), 
			'moduleCode': {data:code.get('LGCOM_MODULE_CODE'), keyField:['pCode','code']},
		});  

		//컬럼 설정
		grid.setColumns([
			{
				name:'systemCode',
				fieldName:'systemCode',
				width:100,
				header: {text:'<lgcom:message code="System" />'},
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
				header: {text:'<lgcom:message code="Module"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'moduleCode',
				lookupKeyFields: ['systemCode','moduleCode'],
				editor: {type:'dropDown',textReadOnly:true}
			},
			{
				name:'smName',
				fieldName:'smName',
				width:150,
				header: {text:'<lgcom:message code="SmName"/>'},
				styles: {textAlignment:'center'}
			},
			{
				name:'smOrganizationNameEng',
				fieldName:'smOrganizationNameEng',
				width:150,
				header: {text:'<lgcom:message code="SmOrgName"/>'},
				styles: {textAlignment:'center'}
			},
			{
				name:'piName',
				fieldName:'piName',
				width:150,
				header: {text:'<lgcom:message code="PiName"/>'},
				styles: {textAlignment:'center'},
				//editable: false
			},
			{
				name:'piOrganizationNameEng',
				fieldName:'piOrganizationNameEng',
				width:150,
				header: {text:'<lgcom:message code="PiOrgName"/>'},
				styles: {textAlignment:'center'},
				//editable: false
			},
			{
				name:'piOfficePhoneNumber',
				fieldName:'piOfficePhoneNumber',
				width:150,
				header: {text:'<lgcom:message code="PiPhoneNum"/>'},
				styles: {textAlignment:'center'},
				//editable: false
			}
		]);

		grid.setValidations([
			{criteria: "value['systemCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='System'/>"/>',mode:'always',level:'error'},
			{criteria: "value['moduleCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='Module'/>"/>',mode:'always',level:'error'}
		]);
		
		return grid;
	}
}

LGUTLC00407.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGUTLC00407();
		form.init();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Contact Point</h2>
	</div>
	<div class="searchBlock">
		<form class="form search-wrap">
				<table class="table" >
					<colgroup>
						<col width="90">
						<col width="90">
						<col width="90">
						<col width="90">
					</colgroup>
					<tbody>
						<tr>
							<th><label class=""><lgcom:message code="System" /></label></th>
							<td><select class="form-control input-sm" name="systemCode"></select></td>
							<th><label class="required"><lgcom:message code="Module" /></label></th>
							<td><select class="form-control input-sm" name="moduleCode"></select></td>
						</tr>
					</tbody>
				</table>
			<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
		</form>
	</div>
	
	<div class="contentGrid grid-wrap">
		<div class="grid LGUTLC00407_grid"></div>
	</div>
	</section>
</div>
</body>
</html>
