<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGSETC00030.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2012 LG CNS,  All rights reserved.

    설 명 : 본 화면은 Code Value 정보를 관리하는 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Code Value</title>
<style type="text/css">

</style>
<script type="text/javascript">

var LGSETC00030 = function(){
    var grid1, grid2;
    var myForm = this;

    var formUtil = new FormUtil(myForm,'.searchBlock form');
    formUtil.disable('controlLevelCodeName');
    formUtil.disable('accessLevelCodeName');
    /* 팝업용 변수 선언 */
	myForm.popupInfo = { 'codePopup': {findKey:'',codeData:[]} ,
    		            'parentCodePopup':{row:-1, col:'', modYn:'Y', findKey:'', codeData:[]} ,
    		            'invOrgIdPopup':{row:-1, col:'', compId:'', findKeyComp:'',findKeyInv:'' , codeData:[]}
    		          };
    
    /* Layout Setting */
	myForm.setLayout( [ 
		{ name  : "searchBlock", left : 0, right : 0, top : 0 },		
		{ name  : "gridControls1", left : 0, right : 0, top : "searchBlock"},
		{ name  : "content1", left : 0, right : 0, top : "gridControls1", bottom : "gridControls2" },	 	
		{ name  : "gridControls2", left : 0, right : 0, bottom : "content2"},
	 	{ name  : "content2", left : 0, right : 0, height : 140, bottom : 0  }		
	]);        
    
 	// 필수항목 체크
   	var validator = new Validator( myForm, ".searchBlock .form" );
    validator.setRule({
    	option: {placement: 'bottom'},
	    rules: {
	    	codeTypeCodeShow: {required:true}
	    },
	    messages: {
	    	codeTypeCodeShow: {required:'<lgcom:message code="error.requiredTooltip"/>'}
	    }
    });

	// combo 목록 조회
	var code = new CommonCode("lgcom");
	code.add( "LGCOM_LANGUAGE_CODE", { codeTypeCode:'LGCOM_LANGUAGE_CODE' });
	code.execute();

   	grid1 = buildGrid("LGSETC00030_grid1");
   	grid2 = buildGrid("LGSETC00030_grid2");
   
    // 조회조건 저장 처리
	myForm.searchConditionControl(true);
   	
    /* 그리드 이벤트 처리 */
	grid1.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
   		/* 신규 row가 아닐 경우에만 이벤트 발생 */
   		var provider = cgrid.getDataProvider();
   		if(newRow > -1) {
       		grid2.getGridBase().cancel();
   			var rowData = provider.getJsonRow(newRow);
   			var compVal = rowData.companyId;
   			if( typeof(compVal) == 'undefined' || compVal == '' || compVal == null){
   				compVal = '0';
   			}
   			var invVal = rowData.inventoryOrganizationId;
   			if( typeof(invVal) == 'undefined' || invVal == '' || invVal == null){
   				invVal = '0';
   			}
   			grid2.loadData('lgcom','lgsetc/LGSETC00030/retrieveCodeLangList',{codeTypeCode: rowData.codeTypeCode,
   																	  commonCode : rowData.commonCode,
   																	  companyId : compVal,
   																	  inventoryOrganizationId : invVal,
   																	 });
   		}
   		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';
   		var rstyle   = cgrid.addCellStyle('required',{background:'#ffffffaa'}, true);
   		// 신규행이 아니면 Program ID 컬럼 편집 불가
   		if(!editable) {
   			cgrid.setColumnProperty('companyId','editable',false);
   			cgrid.setColumnProperty('commonCode','editable',false);
   			cgrid.setColumnProperty('inventoryOrganizationIdName','editable',false);
   			// 삭제버튼 활성화
   			myForm.select(".gridControls button[data-action='delete1']").attr('disabled','disabled');
   			//inventory organization 버튼 비활성화
   		} else {
   			cgrid.setColumnProperty('companyId','editable',true);
   			cgrid.setColumnProperty('commonCode','editable',true);
   			cgrid.setColumnProperty('inventoryOrganizationIdName','editable',true);
   			// 삭제버튼 비활성화
   			var changedVal = myForm.select('.searchBlock .form input[name=controlLevelCode]').val();
   			myForm.select(".gridControls button[data-action='delete1']").removeAttr('disabled');
   			var current = cgrid.getCurrent();
   			if('SITE' == changedVal){
   				cgrid.setCellStyles(newRow,'commonCode','required');
   				cgrid.setCellStyles(newRow,'useFlag','required');
   				cgrid.setCellStyles(newRow,'applyStartDate','required');
   				cgrid.setCellStyles(newRow,'sortOrderNo','required');
   				grid1.getGridBase().setValue(current.itemIndex,'inventoryOrganizationId','0');
   			}else if('COMPANY' == changedVal){
   				cgrid.setCellStyles(newRow,'commonCode','required');
   				cgrid.setCellStyles(newRow,'companyId','required');
   				cgrid.setCellStyles(newRow,'commonCode','required');
   				cgrid.setCellStyles(newRow,'useFlag','required');
   				cgrid.setCellStyles(newRow,'applyStartDate','required');
   				cgrid.setCellStyles(newRow,'sortOrderNo','required');
   				grid1.getGridBase().setValue(current.itemIndex,'inventoryOrganizationId','0');
   			}else if('INVENTORY_ORG' ==  changedVal){
   				cgrid.setCellStyles(newRow,'commonCode','required');
   				cgrid.setCellStyles(newRow,'companyId','required');
   				cgrid.setCellStyles(newRow,'inventoryOrganizationIdName','required');
   				cgrid.setCellStyles(newRow,'useFlag','required');
   				cgrid.setCellStyles(newRow,'applyStartDate','required');
   				cgrid.setCellStyles(newRow,'sortOrderNo','required');
   			}
    	}
	};

	grid2.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		var provider = cgrid.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';
		var rstyle   = cgrid.addCellStyle('required',{background:'#ffffffaa'}, true);
		// 신규행이 아니면 Program ID 컬럼 편집 불가
		if(!editable) {
			cgrid.setColumnProperty('languageCode','editable',false);
			// 삭제버튼 활성화
			//myForm.select(".gridControls button[data-action='delete1']").attr('disabled','disabled');
		} else {
			cgrid.setColumnProperty('languageCode','editable',true);
			// 삭제버튼 비활성화
			//myForm.select(".gridControls button[data-action='delete1']").removeAttr('disabled');
			cgrid.setCellStyles(newRow,'languageCode','required');
			cgrid.setCellStyles(newRow,'commonCodeName','required');
		}
	};

	//상단 그리드 팝업버튼 클릭시 이벤트
	grid1.getGridBase().onCellButtonClicked = function (cgrid, itemIndex, column) {
		//role 검색 팝업을 열고 결과값(role code, role name)을 하단 그리드의 해당 셀에 세팅한다.
		cgrid.commitEditor();
		if(column.name == 'inventoryOrganizationIdName'){
			var editable = grid1.getGridBase().getDataRow(itemIndex) < 0 || cgrid.getDataProvider().getRowState(grid1.getGridBase().getDataRow(itemIndex)) === 'created';
			if(editable){
				if(typeof(cgrid.getValue(itemIndex,'companyId'))=='undefined' || cgrid.getValue(itemIndex,'companyId')==''){
					Message.alert('<lgcom:message code="note.selectCompany"/>');
					return;
				}
				processInvOrgIdPopup(itemIndex, column.name, cgrid.getValue(itemIndex,'companyId'),cgrid.getValue(itemIndex,column.name));
			}
		}else{
			processParentCodePopup(itemIndex, column.name, cgrid.getValue(itemIndex,column.name));
		}
    };

  	//상단그리드의 code type 입력시 중복체크
	grid1.getGridBase().onCurrentChanging =  function (grid, oldIndex, newIndex) {
		var editRow = oldIndex.dataRow;
		var editable = editRow < 0 || grid.getDataProvider().getRowState(editRow) === 'created';
		if( editable && ( oldIndex.fieldIndex == grid.getDataProvider().getFieldIndex('companyId') ||
				          oldIndex.fieldIndex == grid.getDataProvider().getFieldIndex('inventoryOrganizationIdName') ||
				          oldIndex.fieldIndex == grid.getDataProvider().getFieldIndex('commonCode'))){
			var changedVal = myForm.select('.searchBlock .form input[name=controlLevelCode]').val();
			var typeValue = grid.getValue(oldIndex.itemIndex, grid.getDataProvider().getFieldIndex('codeTypeCode'));
			var comValue = grid.getValue(oldIndex.itemIndex, grid.getDataProvider().getFieldIndex('companyId'));
			var invValue = grid.getValue(oldIndex.itemIndex, grid.getDataProvider().getFieldIndex('inventoryOrganizationId'));
			var codeValue = grid.getValue(oldIndex.itemIndex, grid.getDataProvider().getFieldIndex('commonCode'));
			if('SITE' == changedVal){
				if(nvl(codeValue)!=""){
					//중복체크
					var param = {codeTypeCode : typeValue, commonCode : codeValue, companyId : '0', inventoryOrganizationId : '0'};
					var result;
					transaction_sync( 'lgcom',"lgsetc/LGSETC00030/retrieveCodeValDupChk", param, function(data){
						result = data.result;
					});
					//데이터가 있다 -> 중복이 있다의 의미
					if( result ){
		            	Message.error('<lgcom:message code="error.duplicateValue"/>');
						//return false;
		        	}
				}
			}else if('COMPANY' == changedVal){
				if( nvl(codeValue)!="" && nvl(comValue)!="" ){
					//중복체크
					var param = {codeTypeCode : typeValue, commonCode : codeValue, companyId : comValue, inventoryOrganizationId : '0'};
					var result;
					transaction_sync( 'lgcom',"lgsetc/LGSETC00030/retrieveCodeValDupChk", param, function(data){
						result = data.result;
					});
					//데이터가 있다 -> 중복이 있다의 의미
					if( result ){
		            	Message.error('<lgcom:message code="error.duplicateValue"/>');
						//return false;
		        	}
				}
			}else if('INVENTORY_ORG' ==  changedVal){
				if( nvl(codeValue)!="" && nvl(comValue)!="" && nvl(invValue)!="" ){
					//중복체크
					var param = {codeTypeCode : typeValue, commonCode : codeValue, companyId : comValue, inventoryOrganizationId : invValue};
					var result;
					transaction_sync( 'lgcom',"lgsetc/LGSETC00030/retrieveCodeValDupChk", param, function(data){
						result = data.result;
					});
					//데이터가 있다 -> 중복이 있다의 의미
					if( result ){
		            	Message.error('<lgcom:message code="error.duplicateValue"/>');
						//return false;
		        	}
				}
			}
		}
		//return true;
	};

	//하단그리드의 code type 입력시 중복체크
	grid2.getGridBase().onCurrentChanging =  function (grid, oldIndex, newIndex) {
		var editRow = oldIndex.dataRow;
		var editable = editRow < 0 || grid.getDataProvider().getRowState(editRow) === 'created';
		if( editable && ( oldIndex.fieldIndex == grid.getDataProvider().getFieldIndex('languageCode') ) ){

			var langValue = grid.getValue(oldIndex.itemIndex, oldIndex.fieldIndex);
			var typeValue = grid.getValue(oldIndex.itemIndex, grid.getDataProvider().getFieldIndex('codeTypeCode'));
			var comValue = grid.getValue(oldIndex.itemIndex, grid.getDataProvider().getFieldIndex('companyId'));
			var invValue = grid.getValue(oldIndex.itemIndex, grid.getDataProvider().getFieldIndex('inventoryOrganizationId'));
			var codeValue = grid.getValue(oldIndex.itemIndex, grid.getDataProvider().getFieldIndex('commonCode'));

			var param = {languageCode : langValue ,
						 codeTypeCode : typeValue ,
					     commonCode : codeValue ,
						 companyId : comValue ,
						 inventoryOrganizationId : invValue};
			var result;
			transaction_sync( 'lgcom',"lgsetc/LGSETC00030/retrieveLangCodeDupChk", param, function(data){
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

	grid1.getGridBase().onEditCommit = function(cgrid, index, oldValue, newValue) {
		if(index.fieldIndex == cgrid.getDataProvider().getFieldIndex('parentCodeTypeCode')){
			var current = grid1.getGridBase().getCurrent();
			var pCodeType = grid1.getGridBase().getValue(current.itemIndex,'parentCodeTypeCode');
			var pComonCode = grid1.getGridBase().getValue(current.itemIndex,'parentCommonCode');
			if( (newValue=='' || typeof(newValue)=='undefined') && (pComonCode !='') ){
				grid1.getGridBase().setValue(current.itemIndex,'parentCommonCode','');
			}
		}
	};

	grid1.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	};

	grid2.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	};

	/*** 이벤트 핸들러  ***/
	myForm.addEvent( "click", ".find" , function(event){

		var item = myForm.select('.searchBlock .form input[name=codeTypeCodeShow]');
		var findKey = item.val();

		if( $(item).data("popup_open") != "open") {
			$(item).data("popup_open", "open");
			grid1.getGridBase().cancel();
			grid2.getGridBase().cancel();
			processCodePopup(findKey);
		}
	});

	myForm.addEvent( "change", ".searchBlock .form input[name=codeTypeCodeShow]" , function(event){
		var item = myForm.select('.searchBlock .form input[name=codeTypeCodeShow]');
		var findKey = item.val();

		if( $(item).data("popup_open") != "open") {
			$(item).data("popup_open", "open");
			grid1.getGridBase().cancel();
			grid2.getGridBase().cancel();
			processCodePopup(findKey);
		}
	});




	myForm.addEvent( "click", "button[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ){
		    case "search" :
		    	grid1.getGridBase().cancel();
		    	grid2.getGridBase().cancel();
		    	var cVal = myForm.select('.searchBlock .form input[name=codeTypeCode]').val();
		    	var showVal = myForm.select('.searchBlock .form input[name=codeTypeCodeShow]').val();
		    	if(validator.isValid()) {
					grid1.getGridBase().cancel();
					var param = formUtil.getValue();
					grid1.loadData('lgcom','lgsetc/LGSETC00030/retrieveCodeValueList',param);
					grid2.getDataProvider().clearRows();
				} else {
					myForm.select(".searchBlock form input[name='codeTypeCodeShow']").focus();
				}

		    	if( (cVal == '' || typeof(cVal) == 'undefined') && (showVal != '') ){
		    		Message.alert('<lgcom:message code="error.useSearchPopup"/>');
		    		//myForm.select(".searchBlock form input[name='codeTypeCodeShow']").focus();
		    	}

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
				/*
				if(formUtil.getValue('controlLevelCode') != 'SITE'){
					for(var i = 0; i < createdRowIdxs.length; i++){
						var rowData = grid1.getDataProvider().getJsonRow(createdRowIdxs[i]);
						if(typeof(rowData.companyId)=='undefined' || rowData.companyId==''){
							Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='Company'/>"/>');
							return;
						}
					}
				}
				*/
				Message.confirm( '<lgcom:message code="question.save"/>' , function() {
					grid1.useProgress(true);
					grid1.saveChanges('lgcom','lgsetc/LGSETC00030/saveCodeValueList', function(data) {
						Message.notify('<lgcom:message code="note.completed"/>');
						// 저장 완료후 목록 재조회
						//$("div#LGSETC00030 button[data-action='search']").trigger('click');
						myForm.select(".searchBlock button[data-action='search']").trigger('click');
					});
				});
		    	break;

		    case "save2" :
		    	// 변경건이 있는지 체크
				if(grid1.isChanged()) {
					Message.alert('<lgcom:message code="error.codeValModify"/>');
					return;
				}
		    	/*
		    	var createdRowIdxs = grid1.getDataProvider().getStateRows('created');
				var updatedRowIdxs = grid1.getDataProvider().getStateRows('updated');
				if(createdRowIdxs.length != 0 || updatedRowIdxs.length != 0){
		    		Message.alert('<lgcom:message code="error.codeValModify"/>');
		    		return;
		    	}
				*/
				else{
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
						grid2.saveChanges('lgcom','lgsetc/LGSETC00030/saveCodeLangList', function(data) {
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
		    	if(nvl(formUtil.getValue('codeTypeCode'))==''){
		    		return;
		    	}
		    	grid1.getGridBase().commit();
				if(grid1.getGridBase().getCurrent().itemIndex < 0) {
					grid1.getGridBase().beginAppendRow();
				} else {
					grid1.getGridBase().beginInsertRow(grid1.getGridBase().getCurrent().itemIndex);
				}

				var cVal = myForm.select('.searchBlock .form input[name=codeTypeCode]').val();
			    var contVal = formUtil.getValue('controlLevelCode');
			    var currCell = grid1.getGridBase().getCurrent();
			    grid1.getGridBase().setValue(currCell.itemIndex,'codeTypeCode',cVal);
			    var index;
			    if(contVal=='SITE'){
			    	grid1.getGridBase().setValue(currCell.itemIndex,'companyId','0');
			    	grid1.getGridBase().setValue(currCell.itemIndex,'inventoryOrganizationId','0');
			    	index = {
							itemIndex: currCell.itemIndex,
							column: 'commonCode',
							dataRow: currCell.dataRow,
							fieldName: currCell.fieldName
					};
			    }else{
			    	if(contVal=='COMPANY'){
				    	grid1.getGridBase().setValue(currCell.itemIndex,'inventoryOrganizationId','0');
			    	}
			    	index = {
							itemIndex: currCell.itemIndex,
							column: 'companyId',
							dataRow: currCell.dataRow,
							fieldName: currCell.fieldName
					};
			    }

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
		    		Message.alert('<lgcom:message code="error.codeValModify"/>');
		    		return;
		    	}*/
		    	if(grid1.isChanged()) {
					Message.alert('<lgcom:message code="error.codeValModify"/>');
					return;
				}else{
		    		//첫번쨰 그리드의 조회정보가 없다면 행추가를 하지 않는다.
			    	if(grid1.getGridBase().getItemCount() < 1) return;
			    	//두번째 그리드에 조회된 행이 있으면 현지점에 row추가 / 없다면 맨 밑에 행추가

					if(grid2.getGridBase().getCurrent().itemIndex < 0) {
						grid2.getGridBase().beginAppendRow();
					} else {
						grid2.getGridBase().beginInsertRow(grid2.getGridBase().getCurrent().itemIndex);
					}
					grid2.getGridBase().commit();

					var current1 = grid1.getGridBase().getCurrent();
					var current2 = grid2.getGridBase().getCurrent();
					var cRow = 0;
				    if (current1) {
				    	cRow = Math.max(0, current1.dataRow);
				    }
				    grid2.getGridBase().setValue(current2.itemIndex,'codeTypeCode',grid1.getGridBase().getValue(current1.itemIndex,'codeTypeCode'));
				    grid2.getGridBase().setValue(current2.itemIndex,'commonCode',grid1.getGridBase().getValue(current1.itemIndex,'commonCode'));

				    var compVal = grid1.getGridBase().getValue(current1.itemIndex,'companyId');
				    if( nvl(compVal)=="" ){
				    	grid2.getGridBase().setValue(current2.itemIndex,'companyId','0');
				    }else{
				    	grid2.getGridBase().setValue(current2.itemIndex,'companyId', compVal);
				    }

				    var invVal = grid1.getGridBase().getValue(current1.itemIndex,'inventoryOrganizationId');
				    if( nvl(invVal)=="" ){
				    	grid2.getGridBase().setValue(current2.itemIndex,'inventoryOrganizationId', '0');
				    }else{
				    	grid2.getGridBase().setValue(current2.itemIndex,'inventoryOrganizationId', invVal);
				    }

					var index = {
						itemIndex: current2.itemIndex,
						column: 'languageCode',
						dataRow: current2.dataRow,
						fieldName: current2.fieldName
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
		    		Message.alert('<lgcom:message code="error.codeValModify"/>');
		    		return;
		    	}
				*/
				if(grid1.isChanged()) {
					Message.alert('<lgcom:message code="error.codeValModify"/>');
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

//	myForm.addEvent( 'click', "button[data-action], .find",function(event) {
//		var findKey = myForm.select('.searchBlock .form input[name=codeTypeCode]').val();
//		processCodePopup(findKey);
//	});

	/*** 내부 함수  ***/
    //그리드 초기화
	function buildGrid(gridId) {
		var grid;
		switch(gridId){
			case 'LGSETC00030_grid1':
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
					}
				});

				//필드 설정
				grid.setFields(
						[
							{ fieldName:'companyId'     			, dataType:'text'  },
							{ fieldName:'codeTypeCode'     			, dataType:'text'  },
							{ fieldName:'inventoryOrganizationId'   , dataType:'text'  },
							{ fieldName:'inventoryOrganizationIdName', dataType:'text' },
							{ fieldName:'commonCode'      			, dataType:'text'  },
							{ fieldName:'commonCodeDesc'  			, dataType:'text'  },
							{ fieldName:'sortOrderNo'  				, dataType:'number'  },
							{ fieldName:'useFlag'					, dataType:'text'  },
							{ fieldName:'applyStartDate' 			, dataType:'text'  },
							{ fieldName:'applyEndDate'   			, dataType:'text'  },
							{ fieldName:'parentCodeTypeCode'      	, dataType:'text'  },
							{ fieldName:'parentCommonCode'        	, dataType:'text'  },
							{ fieldName:'codeData1Value'        	, dataType:'text'  },
							{ fieldName:'codeData2Value'        	, dataType:'text'  },
							{ fieldName:'codeData3Value'        	, dataType:'text'  },
							{ fieldName:'codeData4Value'        	, dataType:'text'  },
							{ fieldName:'codeData5Value'        	, dataType:'text'  }
						]
				);

				var parameter = {codeTypeCode : 'LGCOM_YN_FLAG'};
				transaction_sync( 'lgcom',"lgsetc/LGSETC00030/retrieveGridComboList", parameter, function(data){
					var serverResult1 = data["result"][0];
					var serverResult2 = data["result"][1];
					//var serverResult3 = data["result"][2];
					//grid.setLookups( {"companyId": serverResult1, "inventoryOrganizationId": serverResult2, "useFlag": serverResult3} );
					grid.setLookups( {"companyId": serverResult1, "useFlag": serverResult2} );
				});

				//마우스 오른쪽 클릭시 메뉴
				grid.setContextMenu();

				grid.setValidations([
					 					{criteria: "value['commonCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='CommonCode'/>"/>',mode:'always',level:'error'},
					 					{criteria: "value['companyId'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='Company'/>"/>',mode:'always',level:'error'},
					 					{criteria: "value['inventoryOrganizationId'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='InventoryOrganization'/>"/>',mode:'always',level:'error'},
					 					{criteria: "value['useFlag'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='UseFlag'/>"/>',mode:'always',level:'error'},
					 					{criteria: "value['sortOrderNo'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='OrderBy'/>"/>',mode:'always',level:'error'},
					 					{criteria: "value['applyStartDate'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='StartDate'/>"/>',mode:'always',level:'error'}
					 				]);
				grid.setColumns(
						[
							{
								name:'companyId',
								fieldName:'companyId',
								width:150,
								header: {text:'<lgcom:message code="Company"/>'},
								styles: {textAlignment:'center'},
					            lookupDisplay: true,
								lookupSourceId: 'companyId',
								lookupKeyFields: ['companyId'],
								editor: {type:'dropDown',textReadOnly:true}
							},
							{
								name:'inventoryOrganizationIdName',
								fieldName:'inventoryOrganizationIdName',
								width:100,
								header: {text:'<lgcom:message code="InventoryOrganization"/>'},
								styles: {textAlignment:'center'},
								button: 'action'
							},
							{
								name:'commonCode',
								fieldName:'commonCode',
								width:120,
								header: {text:'<lgcom:message code="CommonCode"/>'},
								styles: {textAlignment:'center'}
							},
							{
								name:'commonCodeDesc',
								fieldName:'commonCodeDesc',
								width:250,
								header: {text:'<lgcom:message code="CommonCodeDesc"/>'}
							},
							{
								name:'sortOrderNo',
								fieldName:'sortOrderNo',
								width:70,
								header: {text:'<lgcom:message code="OrderBy"/>'},
								styles: {textAlignment:'right'}
							},
							{
								name:'useFlag',
								fieldName:'useFlag',
								width:70,
								header: {text:'<lgcom:message code="UseFlag"/>'},
								styles: {textAlignment:'center'},
								lookupDisplay: true,
								lookupSourceId: 'useFlag',
								lookupKeyFields: ['useFlag'],
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
								name:'parentCodeTypeCode',
								fieldName:'parentCodeTypeCode',
								width:150,
								header: {text:'<lgcom:message code="ParentType"/>'},
								styles: {textAlignment:'center'},
								button: 'action'
							},
							{
								name:'parentCommonCode',
								fieldName:'parentCommonCode',
								width:150,
								header: {text:'<lgcom:message code="ParentCode"/>'},
								styles: {textAlignment:'center'},
								editable: false
							},
							{
								name:'codeData1Value',
								fieldName:'codeData1Value',
								width:100,
								header: {text:'<lgcom:message code="Value1"/>'},
								styles: {textAlignment:'center'}
							},
							{
								name:'codeData2Value',
								fieldName:'codeData2Value',
								width:100,
								header: {text:'<lgcom:message code="Value2"/>'},
								styles: {textAlignment:'center'}
							},
							{
								name:'codeData3Value',
								fieldName:'codeData3Value',
								width:100,
								header: {text:'<lgcom:message code="Value3"/>'},
								styles: {textAlignment:'center'}
							},
							{
								name:'codeData4Value',
								fieldName:'codeData4Value',
								width:100,
								header: {text:'<lgcom:message code="Value4"/>'},
								styles: {textAlignment:'center'}
							},
							{
								name:'codeData5Value',
								fieldName:'codeData5Value',
								width:100,
								header: {text:'<lgcom:message code="Value5"/>'},
								styles: {textAlignment:'center'}
							},
						]
				);
				break;

			case 'LGSETC00030_grid2':
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
					 					{criteria: "value['languageCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='language'/>"/>',mode:'always',level:'error'},
					 					{criteria: "value['commonCodeName'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='CommonCodeName'/>"/>',mode:'always',level:'error'}
					 				]);

				//필드 설정
				grid.setFields(
						[
							{ fieldName:'languageCode'		, dataType:'text'  },
							{ fieldName:'commonCodeName'  	, dataType:'text'  },
							{ fieldName:'codeTypeCode'  	, dataType:'text'  },
							{ fieldName:'commonCode'  		, dataType:'text'  },
							{ fieldName:'companyId'  		, dataType:'text'  },
							{ fieldName:'inventoryOrganizationId', dataType:'text'  }
						]
				);
				grid.setLookups({'languageCode':code.get("LGCOM_LANGUAGE_CODE")});
				//컬럼 설정
				grid.setColumns(
						[
							{
								name:'languageCode',
								fieldName:'languageCode',
								width:100,
								header: {text:'<lgcom:message code="Language"/>'},
								styles: {textAlignment:'center'},
								lookupDisplay: true,
								lookupSourceId: 'languageCode',
								lookupKeyFields: ['languageCode'],
								editor: {type:'dropDown',textReadOnly:true}
							},
							{
								name:'commonCodeName',
								fieldName:'commonCodeName',
								width:250,
								header: {text:'<lgcom:message code="CommonCodeName"/>'},
								styles: {textAlignment:'center'}
							},
						]
				);
				break;
		}
		return grid;
	}

	function processCodePopup(keyword) {
		if(typeof(keyword) == 'undefined') keyword = '';
		myForm.popupInfo.codePopup['findKey'] = keyword;
		myForm.select('.searchBlock .form input[name=codeTypeCode]').val('');
		var codepop = new Popup(myForm, "lgcom", "M_LGSETC_1126", '<lgcom:message code="CodeTypePopupTitle"/>' );
		codepop.setSize(900,500);
		codepop.open(function() {
			grid1.getDataProvider().clearRows();
			grid2.getDataProvider().clearRows();
			var array = myForm.popupInfo.codePopup.codeData;
			if(array.length == 0) return;
			if(array.length == 1) {
				myForm.select('.searchBlock .form input[name=codeTypeCode]').val(array[0].codeTypeCode);
				myForm.select('.searchBlock .form input[name=codeTypeCodeShow]').val(array[0].codeTypeCode);
				myForm.select('.searchBlock .form input[name=codeTypeCodeDesc]').val(array[0].codeTypeCodeDesc);
				myForm.select('.searchBlock .form input[name=controlLevelCode]').val(array[0].controlLevelCode);
				myForm.select('.searchBlock .form input[name=controlLevelCodeName]').val(array[0].controlLevelCodeName);
				myForm.select('.searchBlock .form input[name=accessLevelCode]').val(array[0].accessLevelCode);
				myForm.select('.searchBlock .form input[name=accessLevelCodeName]').val(array[0].accessLevelCodeName);
				var  changedVal = myForm.select('.searchBlock .form input[name=controlLevelCode]').val();
				if(changedVal == 'SITE'){
					//둘다 비활성화
					var column1 = grid1.getGridBase().columnByName("companyId");
					var column2 = grid1.getGridBase().columnByName("inventoryOrganizationIdName");
					grid1.getGridBase().setColumnProperty(column1, "visible", false);
					grid1.getGridBase().setColumnProperty(column2, "visible", false);
				}else if(changedVal == 'COMPANY'){
					//inv 비활성화
					var column1 = grid1.getGridBase().columnByName("companyId");
					var column2 = grid1.getGridBase().columnByName("inventoryOrganizationIdName");
					grid1.getGridBase().setColumnProperty(column1, "visible", false);
					grid1.getGridBase().setColumnProperty(column2, "visible", false);
					grid1.getGridBase().setColumnProperty(column1, "visible", true);
				}else if(changedVal == 'INVENTORY_ORG'){
					//둘다 활성화
					var column1 = grid1.getGridBase().columnByName("companyId");
					var column2 = grid1.getGridBase().columnByName("inventoryOrganizationIdName");
					grid1.getGridBase().setColumnProperty(column1, "visible", false);
					grid1.getGridBase().setColumnProperty(column2, "visible", false);
					grid1.getGridBase().setColumnProperty(column2, "visible", true);
					grid1.getGridBase().setColumnProperty(column1, "visible", true);
				}
				//grid1.getGridBase().commit();
			}
			myForm.popupInfo.codePopup.codeData = [];


			var item = myForm.select('.searchBlock .form input[name=codeTypeCodeShow]');
			$(item).data("popup_open", "closed");

		},

		function(){
			var item = myForm.select('.searchBlock .form input[name=codeTypeCodeShow]');
			$(item).data("popup_open", "closed");
		});
	}

	function processParentCodePopup(rowId, colNm, keyword) {
		if(typeof(keyword) == 'undefined') {
			keyword = '';
		}
		myForm.popupInfo.parentCodePopup['row'] = rowId;
		myForm.popupInfo.parentCodePopup['col'] = colNm;
		myForm.popupInfo.parentCodePopup['findKey'] = keyword;
		/* 적용대상 Grid 지정 */
		var egrid = grid1.getGridBase();
		var ppopup = new Popup( myForm, "lgcom", "M_LGSETC_1127", '<lgcom:message code="CodeValuePopupTitle"/>' );
		ppopup.setSize( 1100, 500 );
		ppopup.open(function() {
			var array = myForm.popupInfo.parentCodePopup.codeData;
			if(array.length == 0) return;
			if(array.length == 1) {
				egrid.setValue(myForm.popupInfo.parentCodePopup.row,'parentCodeTypeCode',array[0].codeTypeCode);
				egrid.setValue(myForm.popupInfo.parentCodePopup.row,'parentCommonCode',array[0].commonCode);
				//egrid.commit();
			}
			myForm.popupInfo.parentCodePopup.codeData = [];
		});
	}

	function processInvOrgIdPopup(rowId, colNm, compKeyword, invKeyword) {
		if(typeof(compKeyword) == 'undefined') {
			compKeyword = '';
		}
		if(typeof(invKeyword) == 'undefined') {
			invKeyword = '';
		}
		myForm.popupInfo.invOrgIdPopup['row'] = rowId;
		myForm.popupInfo.invOrgIdPopup['col'] = colNm;
		myForm.popupInfo.invOrgIdPopup['findKeyComp'] = compKeyword;
		myForm.popupInfo.invOrgIdPopup['findKeyInv'] = invKeyword;
		/* 적용대상 Grid 지정 */
		var egrid = grid1.getGridBase();
		var ppopup = new Popup( myForm, "lgcom", "M_LGSETC_1129", '<lgcom:message code="invOrgPopupTitle"/>' );
		ppopup.setSize( 900, 500 );
		ppopup.open(function() {
			var array = myForm.popupInfo.invOrgIdPopup.codeData;
			if(array.length == 0) return;
			if(array.length == 1) {
				egrid.setValue(myForm.popupInfo.invOrgIdPopup.row,'inventoryOrganizationId',array[0].invOrgId);
				egrid.setValue(myForm.popupInfo.invOrgIdPopup.row,'inventoryOrganizationIdName',array[0].invOrgIdCode);
				//egrid.commit();
			}
			myForm.popupInfo.invOrgIdPopup.codeData = [];
			var test = myForm.popupInfo.invOrgIdPopup.codeData;
		});
	}
}

LGSETC00030.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGSETC00030();
		form.init();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
<section class="page-content">
	<div class="pageHeader">
	    <h2>Code Value</h2>
	</div>

	<div class="searchBlock">
        <form class="form search-wrap">
            <input type="hidden" name="codeTypeCode"/>
            <input type="hidden" name="codeTypeCodeDesc"/>
            <input type="hidden" name="controlLevelCode"/>
            <input type="hidden" name="accessLevelCode"/>
		        <table class="table" >
		            <colgroup>
		                <col width="90">
		                <col width="330">
		                <col width="100">
		                <col width="90">
		                <col width="100">
		                <col width="90">
		            </colgroup>
		            <tbody>
		                <tr>
		                    <th><label class="required"><i class="asterisk">*</i><lgcom:message code="CodeType" /></label></th>
		                    <td>
                                <div class="input-group input-group-sm input-search input-require">
		                            <input type="text" class="form-control required size_310 key-recommendation" name="codeTypeCodeShow" keyword="commonCodeType"/>
		                            <span class="input-group-btn">
		                                <button class="btn btn-default ico-lgd find" type="button" data-action="popup" data-type="sPopup" >
		                                    <span class="fa fa-search" aria-hidden="true"></span>
		                                </button>
		                            </span>
		                        </div>
		                    </td>

		                    <th><label><lgcom:message code="ControlLevel" /></label></th>
		                    <td><input type="text" class="form-control input-sm" name="controlLevelCodeName" data-action="change" disabled /></td>


		                    <th><label><lgcom:message code="AccessLevel" /></label></th>
		                    <td><input type="text" class="form-control input-sm" name="accessLevelCodeName" disabled /></td>
		                </tr>
		            </tbody>
		        </table>
		        <button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search" ><lgcom:message code="search" /></button>
	    </form>
	</div>
	<div class="gridControls gridControls1 module-group text-right" >
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
	    <div id="LGSETC00030_grid1" class="grid"></div>
	</div>

	<div class="gridControls gridControls2 module-group text-right" >
		<div class="btn-toolbar">	
			<div class="btn-group">	
		        <button class="btn btn-default btn-sm ico-lgd" type="button" data-action="add2"><span class="fa fa-plus" aria-hidden="true"></span><lgcom:message code="add"/></button>
		        <button class="btn btn-default btn-sm ico-lgd" type="button" data-action="delete2"><span class="fa fa-minus" aria-hidden="true"></span><lgcom:message code="delete"/></button>
		    </div>
			<div class="btn-group">
		        <button class="btn btn-gray btn-sm" type="button" data-action="save2" ><lgcom:message code="save"/></button>
		    </div>
		</div>
    </div>

	<div class="content content2 grid-wrap" >
	    <div id="LGSETC00030_grid2" class="grid"></div>
	</div>
  </section>
</div>
</body>
</html>
