<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGSETC00035.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved..

    설 명 : 본 화면은 Code Value Set 정보를 관리하는 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Code Value Set</title>
<style type="text/css">

</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">

var LGSETC00035 = function(){
    var grid;
    var myForm = this;

	// Form Util 선언
	var formUtil = new FormUtil(myForm,'.searchBlock form');
    var menuForm = new FormUtil(myForm, '.valueSetItem.form');
	// 조회조건 Combo 초기화
	var code = new CommonCode("lgcom");
    code.add(  "LGCOM_SYSTEM_CODE" , { codeTypeCode : "LGCOM_SYSTEM_CODE" } );
    code.add(  "LGCOM_MODULE_CODE" , { codeTypeCode : "LGCOM_MODULE_CODE" } );
    code.execute();
    
    var searchForm = new FormUtil( myForm, ".searchBlock .form" );
    searchForm.initCombo( "systemCode", code.get("LGCOM_SYSTEM_CODE") , {selectAll : true} );
    searchForm.initCombo( "moduleCode", code.get("LGCOM_MODULE_CODE") , {selectAll : true , filter : "systemCode"});
    
    searchForm.setValue({systemCode:SESSION_USER.systemCode});
    
	/* 화면 레이아웃 정의 */
	myForm.setLayout( [ 
	           		{ name  : "searchBlock", left : 0, right : 0, top : 0 },		
	           		{ name  : "gridControls", left : 0, right : 0, top : "searchBlock"},
	           		{ name  : "gridContent", left : 0, width : 400, top : "gridControls", bottom : 0 },	 	
	           		{ name  : "dataBlock", left : "gridContent", right : 0, top : "gridControls", bottom : 0 },
	           	]); 
	
	
	// 그리드 선언
    grid = buildGrid("LGSETC00035_grid");
	
   	// Selection Mode 변경
    grid.setSelectMode(RealGrid.SELECTION_BLOCKLINE);
    
    var validator = new Validator( myForm, ".valueSetItem", {
    	rules  : {
    		valueSetId : { required : true },
    		systemCode : { required : true },
    		moduleCode : { required : true },
    		sqlText : { sqlAntiKeyword : true },
    		fromSqlText : { sqlAntiKeyword : true },
    		whereSqlText : { sqlAntiKeyword : true },
    		ruleSqlText : { sqlAntiKeyword : true },
    		dynamicSqlText : { sqlAntiKeyword : true },
    		applyStartDate : { date : true},
    		applyEndDate : { date : true}
    	},
    	
    	messages : {
    		valueSetId : { required : "<lgcom:message code="error.requiredTooltip" />" },
    		systemCode : { required : "<lgcom:message code="error.requiredTooltip" />" },
    		moduleCode : { required : "<lgcom:message code="error.requiredTooltip" />" },
    		sqlText : { sqlAntiKeyword : "Check Keyword ! : SELECT is not allowed." },
    		fromSqlText : { sqlAntiKeyword : "Check Keyword ! : FROM is not allowed." },
    		whereSqlText : { sqlAntiKeyword : "Check Keyword ! : WHERE is not allowed." },
    		ruleSqlText : { sqlAntiKeyword : "Check Keyword ! : GroupBy is not allowed." },
    		dynamicSqlText : { sqlAntiKeyword : "Check Keyword ! : OrderBy is not allowed." },
	    	dateFrom : { date : "<lgcom:message code="error.incorrectFormat" />" },
	    	dateTo : { date : "<lgcom:message code="error.incorrectFormat" />" }
    	}
    } );
	
    //해당 Input에 특정 문구가 들어가면 벨리데이션 체크함!
    validator.addMethod( "sqlAntiKeyword", function( value, element ){
    	var result = true;

    	var keywordArr = ( $(element).data("antikeyword") + "" ).split(",");
    	$( keywordArr ).each( function(){
    		value = (value + "").toUpperCase();
    		var keyword  =  this.trim();
    		
    		if( value.indexOf( keyword ) > -1 ) { //걸렸다!
    			result = false;
    		    return false;  // break
    		}
    	});

    	return result;
    	
    });
	
    /* 그리드 이벤트 처리 */
	grid.getGridBase().onCurrentChanged = function(cgrid, index) {
		var currentRow = cgrid.getCurrent().itemIndex;
		var provider = cgrid.getDataProvider();
		menuForm.setValue( provider.getJsonRow(grid.getGridBase().getDataRow(currentRow)));	
	};

	menuForm.addChangeEvent( function( currentData, originalData, isChanged  ){
		var cgrid = grid.getGridBase();
		var provider = cgrid.getDataProvider();
		var currentRow = cgrid.getCurrent().itemIndex;
		
 		cgrid.setValue( currentRow,"systemCode"			,currentData["systemCode"]);
 		cgrid.setValue( currentRow,"moduleCode"			,currentData["moduleCode"]);
 		cgrid.setValue( currentRow,"valueSetId"			,currentData["valueSetId"]);
 		cgrid.setValue( currentRow,"valueSetName"		,currentData["valueSetName"]);
 		cgrid.setValue( currentRow,"applyStartDate"		,currentData["applyStartDate"]);
 		cgrid.setValue( currentRow,"applyEndDate"		,currentData["applyEndDate"]);
 		cgrid.setValue( currentRow,"sourceColumnName"	,currentData["sourceColumnName"]);
 		cgrid.setValue( currentRow,"meaningColumnName"	,currentData["meaningColumnName"]);
 		cgrid.setValue( currentRow,"sqlText"			,currentData["sqlText"]);
 		cgrid.setValue( currentRow,"fromSqlText"		,currentData["fromSqlText"]);
 		cgrid.setValue( currentRow,"whereSqlText"		,currentData["whereSqlText"]);
 		cgrid.setValue( currentRow,"ruleSqlText"		,currentData["ruleSqlText"]);
 		cgrid.setValue( currentRow,"dynamicSqlText"		,currentData["dynamicSqlText"]);

  		if( provider.getRowState(currentRow) != "created") {
  			if( !isChanged ) {
  				provider.setRowState( currentRow ,"none" , true);
  			}
  			
			provider.setOptions({
			       restoreMode: "auto"
			    });
  		} else {
  			cgrid.commit( true );
  		}
  		

	});
	
	/*** 이벤트 핸들러  ***/
	myForm.addEvent( "click", "button[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		var cgrid = grid.getGridBase();
		var currentRow = cgrid.getCurrent().itemIndex;
		var provider = cgrid.getDataProvider();
		
		switch( action ){
	    	case "search" :
	    		cgrid.cancel();
	    		validator.resetForm();

				var param = searchForm.getValue();
				grid.loadData('lgcom', 'lgsetc/LGSETC00035/retrieveCodeValSetList', param , function( data ){

					if(grid.getDataProvider().getRowCount() > 0){
			    		var index = {itemIndex: 0};				
						grid.getGridBase().setCurrent(index);
						
						//메뉴폼은 filter 적용으로 onload시 문제발생! 조회시 셋팅하면 문제 없음!.
					    menuForm.initCombo( "systemCode", code.get("LGCOM_SYSTEM_CODE"));
					    menuForm.initCombo( "moduleCode", code.get("LGCOM_MODULE_CODE"));
			    	}else{
				    	menuForm.setValue("systemCode", "");
				    	menuForm.setValue("moduleCode", "");
			    	}
					
				    menuForm.clear();
					menuForm.setValue(provider.getJsonRow(cgrid.getDataRow(0)) );
					cgrid.setCurrent({itemIndex : 0});
					
					provider.setOptions({
					       restoreMode: "auto"
					    });
				});

				break;
			case 'insert':
			    menuForm.initCombo( "systemCode", code.get("LGCOM_SYSTEM_CODE"));
			    menuForm.initCombo( "moduleCode", code.get("LGCOM_MODULE_CODE") , {filter : "systemCode"});
 				
				if(currentRow < 0) {
			    
				    menuForm.setValue( "valueSetId", " ");						    
				    
			        var rows = [
			                    ["","",""]
			                  ];					
		    
					provider.insertRows(0, rows, 0, 1, true);
					//cgrid.beginAppendRow();
				} else {
	 				// 벨리데이션 체크
	 				if( !validator.isValid() ) {
	 					return;
	 				}
	 				
					cgrid.beginInsertRow(currentRow);
				}

				menuForm.clear();
				cgrid.commit( true );
				
				break;
			case 'delete':
				cgrid.deleteSelection(true);
				validator.resetForm();
			    
			    if( grid.getRowCount() > 0 ) {
				    menuForm.initCombo( "systemCode", code.get("LGCOM_SYSTEM_CODE"));
				    menuForm.initCombo( "moduleCode", code.get("LGCOM_MODULE_CODE"));
				    
					menuForm.setValue(provider.getJsonRow(cgrid.getDataRow(currentRow)) );

					cgrid.setCurrent({itemIndex : currentRow});
			    				    	
			    } else{
			    	menuForm.setValue("systemCode", "");
			    	menuForm.setValue("moduleCode", "");
			    	menuForm.clear();
			    }

				break;				
		    case "save" :
		    	cgrid.commit();		    	
				if( grid.getRowCount() == 0 ) {
					Message.notify('<lgcom:message code="note.nodata" />');
					return;
				};
				
				// 변경건이 있는지 체크
				if(!grid.isChanged()) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				}
				
 				// 벨리데이션 체크
 				if( !validator.isValid() ) {
 					return;
 				}

				Message.confirm( "<lgcom:message code="question.save" />" , function(){
					grid.useProgress(true);
					grid.saveChanges('lgcom', 'lgsetc/LGSETC00035/saveCodeValSetList',function(data) {
						Message.notify('<lgcom:message code="note.completed" />');
						// 저장 완료후 목록 재조회
						myForm.select("button[data-action='search']").trigger('click');
					});
				});
				break;			
		}
	});
	
	//검색조건에 값을 입력하고 조회하면 방금 입력한 값을 저장하여 화면에 고정값으로 셋팅 
    myForm.searchConditionControl( true );
    
	//날짜 설정
	var $dateFrom = myForm.select(".valueSetItem input[name='applyStartDate']"),
		$dateTo   = myForm.select(".valueSetItem input[name='applyEndDate']");
	
	//멀티 달력
	myForm.select('._datePicker').dateRangePicker({
		    autoClose: true,
		    language : SESSION_USER.languageCode,
			setValue: function(s, s1, s2) {
				var dgrid = grid.getGridBase();
				var dcurrentRow = dgrid.getCurrent().itemIndex;
			
				dgrid.setValue( dcurrentRow,"applyStartDate"	,s1);
				dgrid.setValue( dcurrentRow,"applyEndDate"		,s2);
				
				$dateFrom.val(s1);
				$dateTo.val(s2);
		}
	});
	
	//싱글 달력 From
	$dateFrom.dateRangePicker({
			singleDate : true,
			showShortcuts: false,
	    	autoClose: true,
	    	language : SESSION_USER.languageCode,
			setValue: function(s, s1, s2) {

				var dgrid = grid.getGridBase();
				var dcurrentRow = dgrid.getCurrent().itemIndex;
			
				dgrid.setValue( dcurrentRow,"applyStartDate"	,s1);
			
				$dateFrom.val(s1);
		}
	});
	
	//싱글 달력 To
	$dateTo.dateRangePicker({
			singleDate : true,
			showShortcuts: false,
	    	autoClose: true,
	    	language : SESSION_USER.languageCode,
			setValue: function(s, s1, s2) {
				
				var dgrid = grid.getGridBase();
				var dcurrentRow = dgrid.getCurrent().itemIndex;
				2
				dgrid.setValue( dcurrentRow,"applyEndDate"		,s1);	
				
				$dateTo.val(s1);
		}
	});
	
//	$dateFrom.addClass("_datePicker");
//	$dateTo.addClass("_datePicker");
		

	//PK 중복값 체크
	var $valueSetId = myForm.select(".valueSetItem input[name='valueSetId']");
	
	$valueSetId.blur(function(){
		transaction_sync( 'lgcom','lgsetc/LGSETC00035/retrieveValueSetIdChk', $valueSetId, function(data){
	    	var result = data["result"][0];	

	    	if(result["cnt"] == 0){
	    	}else{
				Message.alert('<lgcom:message code="error.duplicateValue"/>');
	    	}
		});
	});
	
	

	/* 그리드 이벤트 처리 */
	/*onCurrentChanging은 dataRow의 위치가 변경되기 전에 호출되는 callback 이다.*/	
	grid.getGridBase().onCurrentChanging = function(){
		return validator.isValid();
	}
	
	/* 그리드 이벤트 처리 */
	/*onCurrentRowChanged은 dataRow의 위치가 변경된 후 호출되는 callback 이다.*/
	grid.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		var provider = cgrid.getDataProvider();

		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';
		
		// 신규행이 아니면 Program ID 컬럼 편집 불가
		if(!editable) {
			cgrid.setColumnProperty('debugScopeName','editable',false);
			cgrid.setColumnProperty('debugScopeName','button','none');
			
			//메뉴폼 disable
			menuForm.disable("systemCode");
			menuForm.disable("moduleCode");
			menuForm.disable("valueSetId");
			
			// 삭제버튼 활성화
			myForm.select(".gridControls button[data-action='delete']").attr('disabled','disabled');
		} else {
			cgrid.setColumnProperty('debugScopeName','editable',true);
			cgrid.setColumnProperty('debugScopeName','button','action');

			//메뉴폼 enable
			menuForm.enable("systemCode");
			menuForm.enable("moduleCode");
			menuForm.enable("valueSetId");
			
			// 삭제버튼 비활성화
			myForm.select(".gridControls button[data-action='delete']").removeAttr('disabled');			
		}
	};
	
	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});
	
	/*** 내부 함수  ***/
    //그리드 초기화 
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		
		grid.setPagingMode( true );
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
				sortMode: "explicit",
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

		//룩업코드 설정 //
	    var code = new CommonCode("lgcom");
	    code.add(  "systemCode" , { codeTypeCode : "LGCOM_SYSTEM_CODE" } );
	    code.add(  "moduleCode" , { codeTypeCode : "LGCOM_MODULE_CODE" } );
	    code.execute();
		
		grid.setLookups({
			'systemCode':code.get('systemCode'),
			'moduleCode':code.get('moduleCode')
			});
	   
	 	//마우스 오른쪽 클릭시 메뉴
		grid.setContextMenu();
		
		//컬럼 설정
		grid.setFields(
				[
					{ fieldName: 'systemCode'               , dataType:'text'},
					{ fieldName: 'moduleCode'               , dataType:'text'},
					{ fieldName: 'valueSetId'               , dataType:'text'},
					{ fieldName: 'valueSetName'             , dataType:'text'},
					{ fieldName: 'applyStartDate'           , dataType:'text'},
					{ fieldName: 'applyEndDate'             , dataType:'text'},
					{ fieldName: 'sourceColumnName'         , dataType:'text'},
					{ fieldName: 'meaningColumnName'        , dataType:'text'},
					{ fieldName: 'sqlText'             		, dataType:'text'},
					{ fieldName: 'fromSqlText'              , dataType:'text'},
					{ fieldName: 'whereSqlText'             , dataType:'text'},
					{ fieldName: 'ruleSqlText'              , dataType:'text'},
					{ fieldName: 'dynamicSqlText'           , dataType:'text'}
				]	
		);
		
		grid.setColumns(
				[
					{
						name:'systemCode',
						fieldName:'systemCode',
						width:50,
						header: {text:'<lgcom:message code="System" />'},
						styles: {textAlignment:'center'},
						editable : false,
						lookupDisplay: true,
						lookupSourceId: "systemCode",
						lookupKeyFields: ['systemCode'],
						editor: {type:'dropDown', textReadOnly : true}
					},
					{
						name:'moduleCode',
						fieldName:'moduleCode',
						width:50,
						type: 'data',
						header: {text:'<lgcom:message code="Module" />'},
						styles: {textAlignment:'center'},
						editable : false,
						lookupDisplay: true,
						lookupSourceId: "moduleCode",
						lookupKeyFields: ['moduleCode'],
						editor: {type:'dropDown', textReadOnly : true}
					},				
					{
						name:'valueSetId',
						fieldName:'valueSetId',
						width:200,
						header: {text:'<lgcom:message code="ValueSetID" />'},
						styles: {textAlignment:'near'},
						editable : false
					}
				]	
		);
		
		return grid;
	}
};
	
LGSETC00035.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch( function(){
		var form = new LGSETC00035();
		form.init();		
	});
});

</script>
</head>
<body>
<div class="mdi-container">
<section class="page-content">
	<div class="pageHeader">
		<h2>Code Value Set</h2>
	</div>
	
	<div class="searchBlock">
		<form class="form search-wrap">
		        <table class="table" >
		            <colgroup>
		                <col width="90">
		                <col width="90">
		                <col width="90">
		                <col width="90">
		                <col width="90">
		                <col width="180">
		                <col width="90">
		                <col width="220">		                
		            </colgroup>
		            <tbody>
		                <tr>
		                    <th><label class="required"><lgcom:message code="System" /></label></th>
		                    <td>
		                        <select class="form-control input-sm" name="systemCode"  ></select>
		                    </td>
		                    
		                    <th><label ><lgcom:message code="Module" /></label></th>
		                    <td>
		                        <select class="form-control input-sm" name="moduleCode"  ></select>
		                    </td>
		                    
		                    <th><label><lgcom:message code="ValueSetID" /></label></th>
		                    <td><input type="text" class="form-control input-sm" name="valueSetId" pastable/></td>
		                    
		                    <th><label><lgcom:message code="ValueSetName" /></label></th>
		                    <td><input type="text" class="form-control input-sm" name="valueSetName"></td>		                    
		                    
		                    
		                </tr>
		            </tbody>
		        </table>
		        <button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
		</form>	
	</div>
	
	<div class="gridControls module-group text-right" >
		<div class="btn-toolbar">	
			<div class="btn-group">	
		        <button class="btn btn-default btn-sm ico-lgd" type="submit" data-action="insert"><span class="fa fa-plus" aria-hidden="true"></span><lgcom:message code="Add" /></button>
		        <button class="btn btn-default btn-sm ico-lgd" type="submit" data-action="delete"><span class="fa fa-remove" aria-hidden="true"></span><lgcom:message code="Delete" /></button>
		    </div>
			<div class="btn-group">		               
        		<button class="btn btn-darkgray btn-sm" type="submit" data-action="save" ><lgcom:message code="Save" /></button>
        	</div>
        </div>        
    </div>
    
	<div class="gridContent grid-wrap" >
	    <div id="LGSETC00035_grid" class="grid"></div>
	</div>

    <div class="LGSETC00035  dataBlock grid-warp">
	    <form class="valueSetItem form">
			<table class="table table-condensed">
				<colgroup>
					<col width="180">
					<col width="210">
					<col width="120">
					<col width="210">
				</colgroup>
				<tbody>
					<tr>
						<th scope="row">
							<label><lgcom:message code="System" /></label>
						</th>
						<td>
							<select name="systemCode" class="form-control input-sm"  ></select>
						</td>
						<th scope="row">
							<label><lgcom:message code="Module" /></label>
						</th>
						<td>
							<select class="form-control input-sm size_210" name="moduleCode"  ></select>
						</td>
					</tr>
					<tr>
						<th scope="row">
							<label class="required"><lgcom:message code="ValueSetID" /></label>
						</th>
						<td>
							<input type="text" name="valueSetId" class="form-control input-sm" placeholder="" />
						</td>
						<th scope="row">
							<label><lgcom:message code="ValueSetName" /></label>
						</th>
						<td>
							<input type="text" name="valueSetName" class="form-control input-sm" placeholder="" />
						</td>
					</tr>					
					<tr>
						<th scope="row">
							<label><lgcom:message code="ApplyDate" /></label>
						</th>
						<td colspan="3">
						    <div class="form-inline">
							    <input type="text" name="applyStartDate" class="form-control input-sm size_80" placeholder="" />
							    ~
							    <input type="text" name="applyEndDate" class="form-control input-sm size_80" placeholder="" />
								<button type="button" id="setDate"  class="btn btn-ico _datePicker" aria-label="calendar">
									<span class="ico ico-calendar" aria-hidden="true"></span>
								</button>					
							</div>
						</td>
					</tr>
					<tr>
						<th scope="row">
							<label>Code / Name</label>
						</th>
						<td colspan="3">
						    <div class="form-inline">
							    <input type="text" name="sourceColumnName" class="form-control input-sm size_210" placeholder="" />
							    <input type="text" name="meaningColumnName" class="form-control input-sm size_210" placeholder="" />
							</div>
						</td>
					</tr>						
					<tr>
						<th scope="row">
							<label><lgcom:message code="Select" /></label>
						</th>
						<td colspan="3">
                            <input type="text" name="sqlText" class="form-control input-sm" placeholder="<lgcom:message code="placeholder.select"/>" data-antikeyword="SELECT" />
						</td>
					</tr>
					<tr>
						<th scope="row">
							<label><lgcom:message code="From" /></label>
						</th>
						<td colspan="3">
                            <input type="text" name="fromSqlText" class="form-control input-sm" placeholder="<lgcom:message code="placeholder.from"/>" data-antikeyword="FROM" />
						</td>
					</tr>
					<tr>
						<th scope="row">
							<label><lgcom:message code="Where" /></label>
						</th>
						<td colspan="3">
                            <textarea name="whereSqlText" class="form-control input-sm" style="height: 200px"placeholder="<lgcom:message code="placeholder.where"/>"  data-antikeyword="WHERE"  ></textarea>
						</td>
					</tr>	
					<tr>
						<th scope="row">
							<label><lgcom:message code="GroupOrderby" /></label>
						</th>
						<td colspan="3">
						    <div class="form-inline">
				        	    <input type="text" name="ruleSqlText" class="form-control input-sm size_210" placeholder="<lgcom:message code="placeholder.groupBy"/>" data-antikeyword="GROUP BY"/>
				        	    <input type="text" name="dynamicSqlText" class="form-control input-sm size_210" placeholder="<lgcom:message code="placeholder.orderBy"/>" data-antikeyword="ORDER BY"/>
				            </div>								
						</td>
					</tr>										
				</tbody>				
			</table>
		</form>	    
	</div>	        		    
  </div>
  </section>
</body>
</html>