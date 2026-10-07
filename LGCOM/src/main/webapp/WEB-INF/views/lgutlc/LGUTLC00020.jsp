<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGUTLC00020.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 디버깅 정보를 관리하는 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Debugging Setup</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGUTLC00020 = function(){
    var grid;
    var myForm = this;
    
 	// 조회조건 Combo 초기화
	var searchForm = new FormUtil(myForm,'.searchBlock form');
	var code = new CommonCode("lgcom");
	
	var combo1 = code.execute('retrieveCommonCodeList',{codeTypeCode:'LGCOM_TARGET_RESOURCE_NAME'});
	searchForm.initCombo('debugTypeCode',combo1,{selectAll:false});

	var combo2 = code.execute('retrieveCommonCodeList',{codeTypeCode:'LGCOM_YN_FLAG'});
	searchForm.initCombo('useFlag',combo2,{selectAll:true});

    /* Layout Setting */
	myForm.setLayout( [ 
		{ name : "searchBlock",  left : 0, right : 0, top : 0 },		
		{ name : "gridControls", left : 0, right : 0, top : "searchBlock", bottom : "gridContent"},
		{ name : "gridContent",  left : 0, right : 0, top : "gridControls", bottom : 0 }		
    ]);		

	// 그리드 선언
   	grid = buildGrid("LGUTLC00020_grid");
	
	$('#debugTypeCode').click(function(){
		if(searchForm.getValue("debugTypeCode") == 'USER'){
			document.getElementById('debugScopeName').placeholder= "<lgcom:message code="placeholder.employeeName" />";
		}else{
			document.getElementById('debugScopeName').placeholder= "<lgcom:message code="placeholder.programName" />";		
		}
	});

    // event handling
    grid.getGridBase().onCellButtonClicked = function (cgrid, itemIndex, column) {
		cgrid.commitEditor();
    	if(cgrid.getValue(itemIndex,'debugTypeCode') == 'USER'){
			// 팝업을 호출한다.
			//cgrid.commit();

			var _popup = myForm.popupInfo.userPopup;
			
			_popup["employeeName"] = cgrid.getValue(itemIndex,column.name);

	    	var popup = new Popup( myForm,'lgcom', 'M_LGUTLC_1142', '<lgcom:message code="UserSearch"/>' );
	    	popup.setSize(800,494);
	    	popup.open( function(){
	    		cgrid.setValue(itemIndex, 'debugScopeName',_popup.userData[0].employeeName);
	    		cgrid.setValue(itemIndex, 'debugScopeId',_popup.userData[0].userId);
		    	//cgrid.commit();
	    	});

	    	_popup.userData = [];

    	}else{
			// 팝업에 사용될 Argument 객체 선언
			//cgrid.commit();
			var _popup = myForm.popupInfo.programPopup;
			
			_popup["programName"] = cgrid.getValue(itemIndex,column.name);
			
			var popup = new Popup(myForm,'lgcom','M_LGSYSC_1135','<lgcom:message code="ProgramSearch"/>');
			popup.setSize(500,450);
			popup.open(function() {
			//debug Scope Id

			cgrid.setValue( itemIndex, "debugScopeId", _popup["programId"] );
			cgrid.setValue( itemIndex, "debugScopeName",_popup["programName"] );
			
			});
			//_popup = {};
    	}

    };   

	/*** 이벤트 핸들러  ***/
	myForm.addEvent( "click", "button[data-action], .form .find" , function(event){
		var action = $(event.target).data("action");
		var programPopup = myForm.popupInfo.programPopup;
		var userPopup = myForm.popupInfo.userPopup;
		var cgrid = grid.getGridBase();
		switch( action ){
    		case "search" :
    			grid.getGridBase().cancel();
				var param = myForm.select(".searchBlock form").toJSON();
				grid.loadData('lgcom','lgutlc/LGUTLC00020/retrieveDebuggingList', param );
				if(grid.getDataProvider().getRowCount() > 0){
		    		var index = {itemIndex: 0};				
					grid.getGridBase().setCurrent(index);
		    	}
				break;
			case 'insert':
				// 조회된 정보가 없다면 종료한다.
				//if(grid.getGridBase().getItemCount() < 1) return;
				cgrid.commit();				
				if(cgrid.getCurrent().itemIndex < 0) {
					cgrid.beginAppendRow();
					cgrid.setValue(cgrid.getCurrent().itemIndex,'debugTypeCode', searchForm.getValue("debugTypeCode"));

				} else {
					cgrid.beginInsertRow(cgrid.getCurrent().itemIndex);
					cgrid.setValue(cgrid.getCurrent().itemIndex,'debugTypeCode', cgrid.getValue(cgrid.getCurrent().itemIndex+1,'debugTypeCode'));

				}				
				//cgrid.showEditor();
				cgrid.setCurrent({column:'debugScopeName'});
				cgrid.setFocus();
				break;
			case 'delete':
				grid.getGridBase().deleteSelection(true);
				break;				
		    case "save" :
				try {
					grid.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}	
				
				if( grid.getRowCount() == 0 ) {
					Message.notify('<lgcom:message code="note.nodata" />');
					return;
				};
				// 변경건이 있는지 체크
				if(!grid.isChanged()) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				}
				
				var debugTypeCode = cgrid.getValue(cgrid.getCurrent().itemIndex,"debugTypeCode");
				var debugScopeId = cgrid.getValue(cgrid.getCurrent().itemIndex,"debugScopeId");
				
				var param = {debugTypeCode : debugTypeCode, debugScopeId : debugScopeId};	        			    
						Message.confirm( "<lgcom:message code="question.save" />" , function(){
							grid.useProgress(true);
							grid.saveChanges('lgcom','lgutlc/LGUTLC00020/saveDebuggingList',function(data) {
								Message.notify('<lgcom:message code="note.completed" />');
								// 저장 완료후 목록 재조회
								myForm.select("button[data-action='search']").trigger('click');
							}, function( data , serverMessage ){
								var message = data["_server_message_"];
								Message.error(serverMessage.text);
							} );
				});
				break;
		    case "openPopup" :

				if(searchForm.getValue("debugTypeCode") == 'USER'){
					// 팝업에 사용될 Argument 객체 선언
					var _popup = myForm.popupInfo.userPopup;
					// 입력된 사용자명을 세팅한다.
					_popup.employeeName = searchForm.getValue("debugScopeName");
					// 팝업을 호출한다.
					var popup = new Popup(myForm,'lgcom','M_LGUTLC_1142','<lgcom:message code="UserSearch"/>');
			    	popup.setSize(800,494);
			    	popup.open( function(){
			    		searchForm.setValue({debugScopeName:_popup.userData[0].employeeName});
			    		searchForm.setValue({debugScopeId:_popup.userData[0].userId});
			    	});	
			    	_popup.userData = [];
				}else{
			    	programPopup["programName"] = searchForm.getValue("debugScopeName");
			    	
			    	var popup = new Popup( myForm,'lgcom', 'M_LGSYSC_1135', '<lgcom:message code="ProgramSearch"/>' );
			    	popup.open( function(){
			    		searchForm.setValue( "debugScopeName",programPopup["programName"] );
			    		searchForm.setValue( "debugScopeId", programPopup["programId"] );
			    	});
					//_popup = {};
				}
		    	break;
				
		}
	});
	
	this.addEvent( "change", ".searchBlock .form input[name=debugScopeName]" , function(event){	
		var programPopup = myForm.popupInfo.programPopup;
		var userPopup = myForm.popupInfo.userPopup;		
		if(searchForm.getValue("debugTypeCode") == 'USER'){
			// 팝업에 사용될 Argument 객체 선언
			var _popup = myForm.popupInfo.userPopup;
			// 입력된 사용자명을 세팅한다.
			_popup.employeeName = searchForm.getValue("debugScopeName");
			// 팝업을 호출한다.
			var popup = new Popup(myForm,'lgcom','M_LGUTLC_1142','<lgcom:message code="UserSearch"/>');
	    	popup.setSize(800,494);
	    	popup.open( function(){
	    		searchForm.setValue({debugScopeName:_popup.userData[0].employeeName});
	    		searchForm.setValue({debugScopeId:_popup.userData[0].userId});
	    	});	
	    	_popup.userData = [];
		}else{
	    	programPopup["programName"] = searchForm.getValue("debugScopeName");
	    	
	    	var popup = new Popup( myForm,'lgcom', 'M_LGSYSC_1135', '<lgcom:message code="ProgramSearch"/>' );
	    	popup.open( function(){
	    		searchForm.setValue( "debugScopeName",programPopup["programName"] );
	    		searchForm.setValue( "debugScopeId", programPopup["programId"] );
	    	});
			//_popup = {};
		}
	});	
	
	/* 그리드 이벤트 처리 */
	/*onCurrentRowChanged은 dataRow의 위치가 변경된 후 호출되는 callback 이다.*/
	grid.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		var provider = cgrid.getDataProvider();
		//var columns = grid1.getColumnNames();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';

		// add버튼 클릭시 신규행에 필수입력값으로 들어가야할 row 위치에 backgroud 변환.	
		cgrid.addCellStyle("required",{background: "#ffffffaa"}, true);
				
		// 신규행이 아니면 Program ID 컬럼 편집 불가
		if(!editable) {
			cgrid.setColumnProperty('debugScopeName','editable',false);
			cgrid.setColumnProperty('debugScopeName','button','none');
			
			cgrid.setColumnProperty('debugTypeCode','editable',false);
			cgrid.setColumnProperty('debugScopeName','editable',false);
			cgrid.setColumnProperty('debugScopeId','editable',false);
			
			// 삭제버튼 활성화
			myForm.select(".gridControls button[data-action='delete']").attr('disabled','disabled');
		} else {
			cgrid.setColumnProperty('debugScopeName','editable',true);
			cgrid.setColumnProperty('debugScopeName','button','action');
			
			cgrid.setColumnProperty('debugTypeCode','editable',true);
			cgrid.setColumnProperty('debugScopeName','editable',true);
			cgrid.setColumnProperty('debugScopeId','editable',false);
			
			// 삭제버튼 비활성화
			myForm.select(".gridControls button[data-action='delete']").removeAttr('disabled');
			
			// add버튼 클릭시 신규행에 필수입력값으로 들어가야할 row 위치에 backgroud 변환.
			cgrid.setCellStyles(newRow,'debugTypeCode',"required");
			cgrid.setCellStyles(newRow,'debugScopeName',"required");
			cgrid.setCellStyles(newRow,'debugScopeId',"required");
			cgrid.setCellStyles(newRow,'useFlag',"required");
		}
	};

	/* 그리드 이벤트 처리 && 중복 데이터 체크 */
	grid.getGridBase().onCurrentChanging = function(cgrid, oldIndex, newIndex) {
		var editRow = oldIndex.dataRow;
		var editable = editRow < 0 || cgrid.getDataProvider().getRowState(editRow) === 'created';

		if(editable){

			if(oldIndex.column == "debugScopeName"){
				
				var debugTypeCode = cgrid.getValue(cgrid.getCurrent().itemIndex,"debugTypeCode");
				var debugScopeId = cgrid.getValue(cgrid.getCurrent().itemIndex,"debugScopeId");
				var param = {debugTypeCode : debugTypeCode, debugScopeId : debugScopeId};

				transaction_sync( 'lgcom','lgutlc/LGUTLC00020/retrieveDebugScopeNameChk', param, function(data){
			    	var result = data["result"][0];	

			    	if(result["cnt"] == 0){
			    	}else{
						Message.alert('<lgcom:message code="error.duplicateValue"/>');
						//cgrid.setValue(oldIndex.itemIndex,"debugScopeName", "");
						//cgrid.setValue(oldIndex.itemIndex,"debugScopeId", "");
			    	}
				});
			}			
		}
	};
	
	myForm.popupInfo = { programPopup : {}, userPopup : {searchMode:'single', departmentName:'', mailAddr:'', employeeNo:'', employeeName:'', userData:[]} };

	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});
	
	grid.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	};
	/*** 내부 함수  ***/
    //그리드 초기화 
	function buildGrid(gridId, lookupList) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode( true );
		
		//옵션 설정 
		grid.setOptions({
			grid: {
				softDeleting: true,
				deleteCreated: true,
				hideDeletedRows:true,
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
				}
			},
			dataProvider: {
				insertable: true,
				updatable: true,
				deletable: true,
				softDeleting: true,
				deleteCreated: true
			},	
			display: { fitStyle: 'none' },
			
		});
		
		// 화면 초기 세팅
		searchForm.setValue({debugTypeCode:'USER'});
		
		//룩업코드 설정 //
	    var code = new CommonCode("lgcom");
	    code.add(  "debugTypeCode" , { codeTypeCode : "LGCOM_TARGET_RESOURCE_NAME" } );
	    code.add(  "useFlag" , { codeTypeCode : "LGCOM_YN_FLAG" } );
	    code.execute();
	        
		grid.setLookups({
			'debugTypeCode':code.get('debugTypeCode'),
			'useFlag':code.get('useFlag')
		});

	 	//마우스 오른쪽 클릭시 메뉴
		grid.setContextMenu();
	 	
		// Validation Set
		grid.setValidations([
			{criteria: "value['debugTypeCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='DebugTypeCode'/>"/>',mode:'always',level:'error'},
			{criteria: "value['debugScopeName'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='DebugScopeName'/>"/>',mode:'always',level:'error'},
			{criteria: "value['debugScopeId'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='DebugScopeID'/>"/>',mode:'always',level:'error'},
			{criteria: "value['useFlag'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='UseFlag'/>"/>',mode:'always',level:'error'}
		]);
	 	
		//컬럼 설정
		grid.setFields(
				[
					{ fieldName: 'debugTypeCode'            , dataType:'text'},
					{ fieldName: 'debugScopeName'           , dataType:'text'},					
					{ fieldName: 'debugScopeId'             , dataType:'text'},
					{ fieldName: 'useFlag'             		, dataType:'text'},
					{ fieldName: 'debugLogSetupId'          , dataType:'text'}
				]	
		);
		
		grid.setColumns(
				[
					{
						name:'debugTypeCode',
						fieldName:'debugTypeCode',
						width:100,
						header: {text:'<lgcom:message code="DebugType" />', required: true},
						styles: {textAlignment:'center'},
						lookupDisplay: true,
						lookupSourceId: 'debugTypeCode',
						lookupKeyFields: ['debugTypeCode'],
						editor: {type:'dropDown', textReadOnly : true}
					},
					{
						name:'debugScopeName',
						fieldName:'debugScopeName',
						width:250,
						button: 'action',
						header: {text:'<lgcom:message code="DebugScopeName" />', required: true},
						styles: {textAlignment:'center'}				
					},					
					{
						name:'debugScopeId',
						fieldName:'debugScopeId',
						width:250,
						type: 'data',
						header: {text:'<lgcom:message code="DebugScopeID" />', required: true},
						styles: {textAlignment:'center'}
					},				
					{
						name:'useFlag',
						fieldName:'useFlag',
						width:150,
						header: {text:'<lgcom:message code="UseFlag" />', required: true},
						styles: {textAlignment:'center'},
						lookupDisplay: true,
						lookupSourceId: 'useFlag',
						lookupKeyFields: ['useFlag'],
						editor: {type:'dropDown', textReadOnly : true}
					 }
				]	
			);
			return grid;
	}

};

LGUTLC00020.prototype = new BizForm("${param.bizFormId}");

//$(document).ready( function() {
	launch( function(){
		var form = new LGUTLC00020();
		form.init();
	});
//});
</script>
</head>
<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Debugging Setup</h2>
	</div>
	
	<div class="searchBlock">
		<form class="form search-wrap">
		        <table class="table" >
		            <colgroup>
		                <col width="90">
		                <col width="90">
		                <col width="90">
		                <col width="150">
		                <col width="90">
		                <col width="90">
		            </colgroup>
		            <tbody>
		                <tr>
		                    <th><label class="required"><i class="asterisk">*</i><lgcom:message code="DebugType" /></label></th>
		                    <td>
		                        <select class="form-control input-sm input-require" name="debugTypeCode"></select>
		                    </td>
		                    
		                    <th><label class="required"><i class="asterisk">*</i><lgcom:message code="DebugScopeName" /></label></th>
		                    <td>
                                 <div class="input-group input-group-sm input-search input-require">
		                            <input type="text" class="form-control input-sm" name="debugScopeName"  />
		                            <span class="input-group-btn">
		                                <button class="btn btn-default ico-lgd find" type="button" data-action="openPopup" data-type="sPopup" >
		                                    <span class="fa fa-search" aria-hidden="true"></span>
		                                </button>
		                            </span>
		                        </div>		    		                    
		                    </td>		                    
		                    
		                    <th><label ><lgcom:message code="UseFlag" /></label></th>
		                    <td>
		                        <select class="form-control input-sm" name="useFlag"></select>
		                    </td>
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
		        <button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete"><span class="fa fa-remove" aria-hidden="true"></span> <lgcom:message code="Delete"/></button>	
			</div>
			<div class="btn-group">
		        <button class="btn btn-gray btn-sm" type="submit" data-action="save" ><lgcom:message code="Save" /></button>
		    </div>
		</div>        
    </div>
    
	<div class="gridContent grid-wrap" >
	    <div id="LGUTLC00020_grid" class="grid"></div>
	</div>
	
	<div class="controls" >
    </div>
    </section>		    
</div>
</body>
</html>