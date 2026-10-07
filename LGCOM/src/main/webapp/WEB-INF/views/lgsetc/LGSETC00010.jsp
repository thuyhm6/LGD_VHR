<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGSETC00010.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 Code Type 정보를 관리하는 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Code Type</title>
<style type="text/css">
</style>
<script type="text/javascript">

var LGSETC00010 = function(){
    var grid1, grid2;
    var myForm = this;

    var formUtil = new FormUtil(myForm,'.searchBlock form');

    /* 팝업용 변수 선언 */
	myForm.popupInfo = { 'rolePopup': {searchMode:'single',row:-1,col:'',extraOwn:true,ownUserId:'',findKey:'', roleData:[]} };

    /* Layout Setting 하측 고정, 상측 Flexible*/
	myForm.setLayout( [ 
		{ name  : "searchBlock", left : 0, right : 0, top : 0 },		
		{ name  : "gridControls1", left : 0, right : 0, top : "searchBlock"},
		{ name  : "content1", left : 0, right : 0, top : "gridControls1", bottom : "gridControls2" },	 	
		{ name  : "gridControls2", left : 0, right : 0, bottom : "content2"},
	 	{ name  : "content2", left : 0, right : 0, height : 140, bottom : 0  }		
	]);    
    
    // combo 목록 조회
	var code = new CommonCode("lgcom");
	code.add( "LGCOM_YN_FLAG", { codeTypeCode:'LGCOM_YN_FLAG' });
	code.add( "LGCOM_SYSTEM_CODE", { codeTypeCode:'LGCOM_SYSTEM_CODE' });
	code.add( "LGCOM_MODULE_CODE", { codeTypeCode:'LGCOM_MODULE_CODE' });
	code.add( "LGCOM_ACCESS_LEVEL_CODE", { codeTypeCode:'LGCOM_ACCESS_LEVEL_CODE' });
	code.add( "LGCOM_CONTROL_LEVEL_CODE", { codeTypeCode:'LGCOM_CONTROL_LEVEL_CODE' });
	code.execute();

	formUtil.initCombo( "systemCode", code.get("LGCOM_SYSTEM_CODE"), {selectAll : true } );
	formUtil.initCombo( "moduleCode", code.get("LGCOM_MODULE_CODE"), {selectAll : true, filter : "systemCode" } );
	formUtil.initCombo( "useFlag", code.get("LGCOM_YN_FLAG"), {selectAll : true } );

   	grid1 = buildGrid("LGSETC00010_grid1");
   	grid2 = buildGrid("LGSETC00010_grid2");
	
   
    // 조회조건 저장 처리
	myForm.searchConditionControl(true);
    
   	myForm.loadCompleted = function() {
		formUtil.setValue({systemCode:SESSION_USER.systemCode,useFlag:'Y'});
	};

    // 그리드 이벤트 처리
  	//상단그리드의 code type 입력시 중복체크
	grid1.getGridBase().onCurrentChanging =  function (grid, oldIndex, newIndex) {
		var editRow = oldIndex.dataRow;
		var editable = editRow < 0 || grid.getDataProvider().getRowState(editRow) === 'created';
		if( editable && ( oldIndex.fieldIndex == grid.getDataProvider().getFieldIndex('codeTypeCode') ) ){

			var value = grid.getValue(oldIndex.itemIndex, oldIndex.fieldIndex);
			var param = {codeTypeCode : value};
			var result;
			transaction_sync( 'lgcom',"lgsetc/LGSETC00010/retrieveCodeTypeCode", param, function(data){
				result = data.result;
			});
			//데이터가 있다 -> 중복이 있다의 의미
			if( result ){
            	Message.error('<lgcom:message code="error.duplicateValue"/>');
				//return false;
        	}
		}
		//return true;
	};

	//하단그리드의 role code 입력시 중복체크
	grid2.getGridBase().onCurrentChanging =  function (grid, oldIndex, newIndex) {
		var editRow = oldIndex.dataRow;
		var editable = editRow < 0 || grid.getDataProvider().getRowState(editRow) === 'created';
		if( editable && ( oldIndex.fieldIndex == grid.getDataProvider().getFieldIndex('roleName') ) ){

			var codeTypeCodeValue = grid.getValue(oldIndex.itemIndex, grid.getDataProvider().getFieldIndex('codeTypeCode'));
			var roleCodeValue = grid.getValue(oldIndex.itemIndex, grid.getDataProvider().getFieldIndex('roleCode'));
			var param = {codeTypeCode : codeTypeCodeValue, roleCode : roleCodeValue};
			var result;
			transaction_sync( 'lgcom',"lgsetc/LGSETC00010/retrieveRoleByCodeTypeCode", param, function(data){
				result = data.result;
			});
			//데이터가 있다 -> 중복이 있다의 의미
			if( result ){
            	Message.error('<lgcom:message code="error.duplicateValue"/>');
				//return false;
        	}
		}
		//return true;
	};

	grid1.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		if(newRow > -1) {
			grid2.getGridBase().cancel();
			var rowData = grid1.getDataProvider().getJsonRow(newRow);
			if(rowData.accessLevelCode == 'U'){
				grid2.getGridBase().setEditOptions({readOnly: false})
				grid2.loadData('lgcom','lgsetc/LGSETC00010/retrieveCodeTypeRoleList',{codeType: rowData.codeTypeCode});
			}else{
				//grid2를 비활성화 시킨다
				grid2.getGridBase().setEditOptions({readOnly: true})
				grid2.getDataProvider().clearRows()
			}
		}
        var provider = cgrid.getDataProvider();
        var editable = newRow < 0 || provider.getRowState(newRow) === 'created';
        var rstyle   = cgrid.addCellStyle('required',{background:'#ffffffaa'}, true);
        // 신규행이 아니면 Program ID 컬럼 편집 불가
        if(!editable) {
            cgrid.setColumnProperty('codeTypeCode','editable',false);
            // 삭제버튼 활성화
            myForm.select(".gridControls button[data-action='delete1']").attr('disabled','disabled');
        } else {
            cgrid.setColumnProperty('codeTypeCode','editable',true);
            // 삭제버튼 비활성화
            myForm.select(".gridControls button[data-action='delete1']").removeAttr('disabled');
            cgrid.setCellStyles(newRow,'codeTypeCode','required');
            cgrid.setCellStyles(newRow,'codeTypeCodeDesc','required');
            cgrid.setCellStyles(newRow,'controlLevelCode','required');
            cgrid.setCellStyles(newRow,'accessLevelCode','required');
            cgrid.setCellStyles(newRow,'useFlag','required');
        }
	};

	grid2.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		var provider = cgrid.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';
		var rstyle   = cgrid.addCellStyle('required',{background:'#ffffffaa'}, true);
		// 신규행이 아니면 Program ID 컬럼 편집 불가
		if(!editable) {
			cgrid.setColumnProperty('codeTypeCode','editable',false);
			cgrid.setColumnProperty('roleName','editable',false);
			cgrid.setColumnProperty('roleName','button','none');
			// 삭제버튼 활성화
			//myForm.select(".gridControls button[data-action='delete1']").attr('disabled','disabled');
		} else {
			cgrid.setColumnProperty('codeTypeCode','editable',true);
			cgrid.setColumnProperty('roleName','editable',true);
			cgrid.setColumnProperty('roleName','button','action');
			// 삭제버튼 비활성화
			//myForm.select(".gridControls button[data-action='delete1']").removeAttr('disabled');
			cgrid.setCellStyles(newRow,'codeTypeCode','required');
			cgrid.setCellStyles(newRow,'roleCode','required');
			cgrid.setCellStyles(newRow,'roleName','required');
			cgrid.setCellStyles(newRow,'updateEnableFlag','required');
		}
	};

	grid1.getGridBase().onEditCommit = function(cgrid, index, oldValue, newValue) {
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

	//하단 그리드 팝업버튼 클릭시 이벤트
	grid2.getGridBase().onCellButtonClicked = function (cgrid, itemIndex, column) {
		//role 검색 팝업을 열고 결과값(role code, role name)을 하단 그리드의 해당 셀에 세팅한다
		cgrid.commitEditor();
		var currRow = cgrid.getCurrent();
		var gridRow = cgrid.getValues(currRow.itemIndex);
		processRolePopup(itemIndex, column.name,gridRow.userId,cgrid.getValue(itemIndex,column.name));
    };

    grid1.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	};

	grid2.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	};
	/*** 이벤트 핸들러  ***/
	this.addEvent( "click", "button[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ){
		    case "search" :
		    	grid1.getGridBase().cancel();
		    	grid2.getGridBase().cancel();
		    	grid2.getDataProvider().clearRows();
				var param =  myForm.select(".searchBlock form").toJSON();
				grid1.loadData('lgcom','lgsetc/LGSETC00010/retrieveCodeTypeList', param, function( ){
	                //키워드를 저장하는 함수를 호출하였다
	                if(grid1.getDataProvider().getRowCount() > 0){
	                    myForm.sendKeyword( "commonCodeType", "codeType", param );
	                }
				} );
				grid2.getDataProvider().clearRows();
				if(grid1.getDataProvider().getRowCount() > 0){
		    		var index = {itemIndex: 0};
					grid1.getGridBase().setCurrent(index);
		    	}
				
				break;

		    case "save1" :

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
					grid1.useProgress(true);
					grid1.saveChanges('lgcom','lgsetc/LGSETC00010/saveCodeTypeList', function(data, gridData ) {
                        //키워드를 저장하는 함수를 호출하였다
                        myForm.sendKeyword( "commonCodeType", "codeTypeCode", gridData );
						
						Message.notify('<lgcom:message code="note.completed"/>');
						// 저장 완료후 목록 재조회
						myForm.select(".searchBlock button[data-action='search']").trigger('click');
					});
				});
		    	break;

		    case "save2" :
		    	/*
		    	var createdRowIdxs = grid1.getDataProvider().getStateRows('created');
				var updatedRowIdxs = grid1.getDataProvider().getStateRows('updated');
				if(createdRowIdxs.length != 0 || updatedRowIdxs.length != 0){
		    		Message.alert('<lgcom:message code="error.modifyCodeType"/>');
		    		return;
		    	}
				*/
				if(grid1.isChanged()) {
					Message.alert('<lgcom:message code="error.modifyCodeType"/>');
					return;
				}else{
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
					Message.confirm( '<lgcom:message code="question.save"/>' , function() {
						grid2.useProgress(true);
						grid2.saveChanges('lgcom','lgsetc/LGSETC00010/saveCodeTypeRoleList', function(data) {

							Message.notify('<lgcom:message code="note.completed"/>');
							// 저장 완료후 목록 재조회
							myForm.select(".searchBlock button[data-action='search']").trigger('click');
						});
					});
		    	}
		    	break;

		    case "add1" :
		    	//if(grid1.getGridBase().getItemCount() < 1) return;
		    	//그리드에 조회된 행이 있으면 현지점에 row추가 / 없다면 맨 밑에 행추가

				if(grid1.getGridBase().getCurrent().itemIndex < 0) {
					grid1.getGridBase().beginAppendRow();
				} else {
					grid1.getGridBase().beginInsertRow(grid1.getGridBase().getCurrent().itemIndex);
				}
				grid1.getGridBase().commit();
				var currCell = grid1.getGridBase().getCurrent();
				var index = {
					itemIndex: currCell.itemIndex,
					column: 'codeTypeCode',
					dataRow: currCell.dataRow,
					fieldName: currCell.fieldName
				};
				grid1.getGridBase().setCurrent(index);
		    	//grid1.getGridBase().showEditor();
		    	grid1.getGridBase().setFocus();
		    	break;

		    case "delete1" :
		    	//var base = grid1.getGridBase();
				//var data = grid1.getDataProvider();
				//if(data.getRowState(base.getCurrent().dataRow) == 'created') {
				grid1.getGridBase().deleteSelection(true);
				//}
		    	break;
		    case "add2" :
		    	/*
		    	var createdRowIdxs = grid1.getDataProvider().getStateRows('created');
				var updatedRowIdxs = grid1.getDataProvider().getStateRows('updated');
				if(createdRowIdxs.length != 0 || updatedRowIdxs.length != 0){
		    		Message.alert('<lgcom:message code="error.modifyCodeType"/>');
		    		return;
		    	}
				*/
				if(grid1.isChanged()) {
					Message.alert('<lgcom:message code="error.modifyCodeType"/>');
					return;
				}else{
		    		//첫번쨰 그리드의 조회정보가 없다면 행추가를 하지 않는다.
			    	if(grid1.getGridBase().getItemCount() < 1) return;
			    	//두번째 그리드에 조회된 행이 있으면 현지점에 row추가 / 없다면 맨 밑에 행추가
			    	//grid2.getGridBase().beginAppendRow();
			    	var grid1Curr = grid1.getGridBase().getCurrent();
			    	if(grid1.getGridBase().getValue(grid1Curr.itemIndex,'accessLevelCode') != 'U'){
			    		Message.alert('Access Level이 [User]가 아닙니다');
			    		return;
			    	}
			    	grid2.getGridBase().commit();
					if(grid2.getGridBase().getCurrent().itemIndex < 0) {
						grid2.getGridBase().beginAppendRow();
					} else {
						grid2.getGridBase().beginInsertRow(grid2.getGridBase().getCurrent().itemIndex);
					}
					//grid2.getGridBase().commit();
			    	/* 첫번째 그리드의 정보를 세팅할 필요가 있는 경우 사용..*/
					grid2.getGridBase().setValue(grid2.getGridBase().getCurrent().itemIndex,'codeTypeCode',grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex,'codeTypeCode'));

					//grid2.getGridBase().commit();
					var currCell = grid2.getGridBase().getCurrent();
					var index = {
						itemIndex: currCell.itemIndex,
						column: 'roleName',
						dataRow: currCell.dataRow,
						fieldName: currCell.fieldName
					};
					grid2.getGridBase().setCurrent(index);
			    	//grid2.getGridBase().showEditor();
			    	grid2.getGridBase().setFocus();
		    	}

		    	break;

		    case "delete2" :
		    	/*
		    	var createdRowIdxs = grid1.getDataProvider().getStateRows('created');
				var updatedRowIdxs = grid1.getDataProvider().getStateRows('updated');
				if(createdRowIdxs.length != 0 || updatedRowIdxs.length != 0){
		    		Message.alert('<lgcom:message code="error.modifyCodeType"/>');
		    		return;
		    	}
				*/
				if(grid1.isChanged()) {
					Message.alert('<lgcom:message code="error.modifyCodeType"/>');
					return;
				}else{
		    		var currCell = grid2.getGridBase().getCurrent();
		    		if(currCell.dataRow == -1){
		    			grid2.getGridBase().deleteSelection(true);
		    		}else{
		    			if(grid2.getGridBase().getCheckedRows() == "" || grid2.getGridBase().getCheckedRows() == null) {
							Message.notify('<lgcom:message code="note.nocheck" />');
							return;
						}
						grid2.getGridBase().commit();
						grid2.getDataProvider().removeRows(grid2.getGridBase().getCheckedRows(true,false),false);
		    		}

		    	}
		    	break;
		}
	});
	/*** 내부 함수  ***/
    //그리드 초기화
	function buildGrid(gridId) {
		var grid;
		switch(gridId){
			case 'LGSETC00010_grid1':
				grid = new RealGrid(myForm, gridId);
				grid.setPagingMode(true);
				//옵션 설정
				grid.setOptions({
					grid: {
						//softDeleting: true,
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
					display: { fitStyle: 'evenFill' }
				});

				grid.setValidations([
				 					{criteria: "value['codeTypeCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='CodeType'/>"/>',mode:'always',level:'error'},
				 					{criteria: "value['codeTypeCodeDesc'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='CodeTypeDesc'/>"/>',mode:'always',level:'error'},
				 					{criteria: "value['controlLevelCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='ControlLevel'/>"/>',mode:'always',level:'error'},
				 					{criteria: "value['accessLevelCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='AccessLevel'/>"/>',mode:'always',level:'error'},
				 					{criteria: "value['useFlag'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='UseFlag'/>"/>',mode:'always',level:'error'}
				 				]);

				//마우스 오른쪽 클릭시 메뉴
				grid.setContextMenu();

				//필드 설정
				grid.setFields(
						[
							{ fieldName:'systemCode'     	, dataType:'text'  },
							{ fieldName:'moduleCode'     	, dataType:'text'  },
							{ fieldName:'codeTypeCode'      , dataType:'text'  },
							{ fieldName:'codeTypeCodeDesc'  , dataType:'text'  },
							{ fieldName:'controlLevelCode'  , dataType:'text'  },
							{ fieldName:'accessLevelCode'	, dataType:'text'  },
							{ fieldName:'applyStartDate' 	, dataType:'text'  },
							{ fieldName:'applyEndDate'   	, dataType:'text'  },
							{ fieldName:'useFlag'        	, dataType:'text'  }
						]
				);
				grid.setLookupsMultiLvl({
								 'systemCode':code.get("LGCOM_SYSTEM_CODE"),
					 			 'moduleCode':{data:code.get("LGCOM_MODULE_CODE"), keyField:['pCode','code']},
					 			 'accessLevelCode':code.get("LGCOM_ACCESS_LEVEL_CODE"),
					 			 'controlLevelCode':code.get("LGCOM_CONTROL_LEVEL_CODE"),
					 			 'useFlag':code.get("LGCOM_YN_FLAG"),
					 			 });

				//컬럼 설정
				grid.setColumns(
						[
							{
								name:'systemCode',
								fieldName:'systemCode',
								width:100,
								header: {text:'<lgcom:message code="System"/>'},
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
								name:'codeTypeCode',
								fieldName:'codeTypeCode',
								width:150,
								header: {text:'<lgcom:message code="CodeType"/>', required: true},
							},
							{
								name:'codeTypeCodeDesc',
								fieldName:'codeTypeCodeDesc',
								width:150,
								header: {text:'<lgcom:message code="CodeTypeDesc"/>', required: true},
							},
							{
								name:'controlLevelCode',
								fieldName:'controlLevelCode',
								width:100,
								header: {text:'<lgcom:message code="ControlLevel"/>', required: true},
								styles: {textAlignment:'center'},
								lookupDisplay: true,
								lookupSourceId: 'controlLevelCode',
								lookupKeyFields: ['controlLevelCode'],
								editor: {type:'dropDown',textReadOnly:true}
							},
							{
								name:'accessLevelCode',
								fieldName:'accessLevelCode',
								width:100,
								header: {text:'<lgcom:message code="AccessLevel"/>', required: true},
								styles: {textAlignment:'center'},
								lookupDisplay: true,
								lookupSourceId: 'accessLevelCode',
								lookupKeyFields: ['accessLevelCode'],
								editor: {type:'dropDown',textReadOnly:true}
							},
							{
								type:'group',
								orientation:'horizontal',
								width:200,
								height : 60,
								header : { text : '<lgcom:message code="ApplyDate"/>' , styles : { fontBold: "true"}  },
								columns: [
									{
										name:'applyStartDate',
										fieldName:'applyStartDate',
										width:100,
										type: 'data',
										header: {text:'<lgcom:message code="StartDate"/>'},
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
								name:'useFlag',
								fieldName:'useFlag',
								width:150,
								header: {text:'<lgcom:message code="UseFlag"/>', required: true},
								styles: {textAlignment:'center'},
								lookupDisplay: true,
								lookupSourceId: 'useFlag',
								lookupKeyFields: ['useFlag'],
								editor: {type:'dropDown',textReadOnly:true}
							}
						]
				);
				break;

			case 'LGSETC00010_grid2':
				grid = new RealGrid(myForm, gridId);
				grid.setPagingMode(true);
				//옵션 설정
				grid.setOptions({
					grid: {
						softDeleting: true,
						deleteCreated: true,
						hideDeletedRows:false,
						indicator: {visible:false},
						panel: {visible:false},
						checkBar: {visible:true},
						stateBar: {visible:true},
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
					display: { fitStyle: 'evenFill' }
				});

				//마우스 오른쪽 클릭시 메뉴
				grid.setContextMenu();

				grid.setValidations([
					 					{criteria: "value['codeTypeCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='CodeType'/>"/>',mode:'always',level:'error'},
					 					{criteria: "value['roleCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='RoleCode'/>"/>',mode:'always',level:'error'},
					 					{criteria: "value['roleName'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='RoleName'/>"/>',mode:'always',level:'error'},
					 					{criteria: "value['updateEnableFlag'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='Writable'/>"/>',mode:'always',level:'error'}
					 				]);

				//필드 설정
				grid.setFields(
						[
							{ fieldName:'codeTypeCode'	, dataType:'text'  },
							{ fieldName:'roleCode'      , dataType:'text'  },
							{ fieldName:'roleName'      , dataType:'text'  },
							{ fieldName:'updateEnableFlag'      , dataType:'text'  }
						]
				);
				grid.setLookups({'updateEnableFlag':code.get("LGCOM_YN_FLAG")});
				//컬럼 설정
				grid.setColumns(
						[
							{
								name:'codeTypeCode',
								fieldName:'codeTypeCode',
								width:100,
								header: {text:'<lgcom:message code="CodeType"/>'},
								styles: {textAlignment:'center'},
								editable: false
							},
							{
								name:'roleName',
								fieldName:'roleName',
								width:150,
								button: 'action',
								header: {text:'<lgcom:message code="RoleName"/>'},
								styles: {textAlignment:'center'},
								editable: false
							},
							{
								name:'roleCode',
								fieldName:'roleCode',
								width:150,
								header: {text:'<lgcom:message code="RoleCode"/>'},
								styles: {textAlignment:'center'},
								editable: false
							},
							{
								name:'updateEnableFlag',
								fieldName:'updateEnableFlag',
								width:100,
								header: {text:'<lgcom:message code="Writable"/>'},
								styles: {textAlignment:'center'},
								lookupDisplay: true,
								lookupSourceId: 'updateEnableFlag',
								lookupKeyFields: ['updateEnableFlag'],
								editor: {type:'dropDown',textReadOnly:true}
							},
						]
				);
				break;
		}
		return grid;
	}
	//그리드에 값 세팅하는 함수
	function setValue(grid, field, val) {
	    var row = 0;
	    var current = grid.getGridBase().getCurrent();
	    if (current) {
	        row = Math.max(0, current.dataRow);
	    }
	    grid.getDataProvider().setValue(row,field,val);
	}
	function processRolePopup(rowIdx, colName, applicationUserId, keyword) {
		if(typeof(applicationUserId) == 'undefined') applicationUserId = '';
		if(typeof(keyword) == 'undefined') keyword = '';

		myForm.popupInfo.rolePopup['row'] = rowIdx;
		myForm.popupInfo.rolePopup['col'] = colName;
		myForm.popupInfo.rolePopup['ownUserId'] = applicationUserId;
		myForm.popupInfo.rolePopup['findKey'] = keyword;

		/* 적용대상 Grid 지정 */
		var egrid = grid1.getGridBase();
		var cgrid = grid2.getGridBase();
		var rolepop = new Popup(myForm, "lgcom", 'M_LGUTLC_1141','<lgcom:message code="RoleSearch"/>');
		rolepop.setSize(740,412);
		rolepop.open(function() {
			var array = myForm.popupInfo.rolePopup.roleData;
			if(array.length == 0) return;
			if(array.length == 1) {
				cgrid.setValue(myForm.popupInfo.rolePopup.row,'roleCode',array[0].roleCode);
				cgrid.setValue(myForm.popupInfo.rolePopup.row,'roleName',array[0].roleName);
				cgrid.commit();
			}
			myForm.popupInfo.rolePopup.roleData = [];
		});
	}
}

LGSETC00010.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGSETC00010();
		form.init();
		form.loadCompleted();
	});
});

</script>
<style>
</style>
</head>

<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
	    <h2>Code Type</h2>
	</div>

	<div class="searchBlock">
	    <form class="form search-wrap">
				<table class="table">
					<colgroup>
						<col width="90" />
						<col width="100"/>
						<col width="90" />
						<col width="100"/>
						<col width="90" />
						<col width="300"/>
						<col width="90" />
						<col width="60"/>
					</colgroup>
					<tbody>
						<tr>
							<th scope="col"><label for="systemCode"><lgcom:message code="System"/></label></th>
							<td><select id="systemCode" name="systemCode" class="form-control input-sm"></select></td>
							<th scope="col"><label for="moduleCode"><lgcom:message code="Module"/></label></th>
							<td><select id="moduleCode" name="moduleCode" class="form-control input-sm"></select></td>
							<th scope="col"><label for="CodeType"><lgcom:message code="CodeType" /></label></th>
							<td><input type="text" name="codeType" class="form-control input-sm" /></td>
							<th scope="col"><label for="useFlag"><lgcom:message code="UseFlag"/></label></th>
							<td><select id="useFlag" name="useFlag" class="form-control input-sm"></select></td>							
						</tr>						
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search" ><lgcom:message code="search" /></button>
	    </form>
	</div>

	<div class="gridControls gridControls1 module-group text-right">
		<div class="btn-toolbar">	
			<div class="btn-group">	
		        <button class="btn btn-default btn-sm ico-lgd" type="submit" data-action="add1"><span class="fa fa-plus" aria-hidden="true"></span><lgcom:message code="add"/></button>
		        <button class="btn btn-default btn-sm ico-lgd" type="submit" data-action="delete1"><span class="fa fa-minus" aria-hidden="true"></span><lgcom:message code="delete"/></button>
        	</div>
        	<div class="btn-group">
        		<button class="btn btn-gray btn-sm" type="submit" data-action="save1" ><lgcom:message code="save"/></button>
        	</div>
        </div>	
    </div>

	<div class="content content1 grid-wrap" >
	    <div id="LGSETC00010_grid1" class="grid"></div>
	</div>

	<div class="gridControls gridControls2 module-group text-right" >
		<div class="btn-toolbar">	
			<div class="btn-group">	
		        <button class="btn btn-default btn-sm ico-lgd" type="submit" data-action="add2"><span class="fa fa-plus" aria-hidden="true"></span><lgcom:message code="add"/></button>
		        <button class="btn btn-default btn-sm ico-lgd" type="submit" data-action="delete2"><span class="fa fa-minus" aria-hidden="true"></span><lgcom:message code="delete"/></button>
			</div>
			<div class="btn-group">					
        		<button class="btn btn-gray btn-sm" type="submit" data-action="save2" ><lgcom:message code="save"/></button>
        	</div>
        </div>	
    </div>

	<div class="content content2 grid-wrap" >
	    <div id="LGSETC00010_grid2" class="grid"></div>
	</div>
  </section>
</div>
</body>
</html>
