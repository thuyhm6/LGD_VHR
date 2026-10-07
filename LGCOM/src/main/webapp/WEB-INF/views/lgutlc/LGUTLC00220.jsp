<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGUTLC00220.jsp
    프로젝트명 : LGD WCFW Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : Batch Schedule 관리화면.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Batch Schedule</title>
<style type="text/css">

</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">

var LGUTLC00220 = function(){
	var myForm = this;
	myForm.popupInfo = { programPopup : {} , userPopup : {} };

    /* Layout Setting */
	myForm.setLayout( [ 
		{ name : "searchBlock",  left : 0, right : 0, top : 0 },		
		{ name : "gridControls", left : 0, right : 0, top : "searchBlock", bottom : "gridContent"},
		{ name : "gridContent",  left : 0, right : 0, top : "gridControls", bottom : 0 }		
    ]);
	
    //공통코드 정보를 인출
    var code = new CommonCode("lgcom");
    code.add( "systemCode" , { codeTypeCode : "LGCOM_SYSTEM_CODE" } );
    code.add( "moduleCode" , { codeTypeCode : "LGCOM_MODULE_CODE" } );
    code.add( "intervalUnitCode" , { codeTypeCode : "LGCOM_BATCH_INTERVAL_UNIT_CODE" } );
    code.add( "intervalTypeCode", {codeTypeCode:'LGCOM_BATCH_INTERVAL_TYPE_CODE'});
    code.add( "holdFlag",{codeTypeCode:'LGCOM_YN_FLAG'});
    code.add( "useFlag",{codeTypeCode:'LGCOM_YN_FLAG'});
    code.execute();
	
	var grid = buildGrid(".scheduleGrid");
	var formUtil = new FormUtil( myForm, ".searchBlock form");
	
	formUtil.initCombo( "systemCode", code.get("systemCode") );
	formUtil.initCombo( "moduleCode", code.get("moduleCode"), { filter : "systemCode", selectAll : true } );
	formUtil.initCombo( "holdFlag", code.get("holdFlag") );
	formUtil.setValue({ holdFlag : "N"  });
	
	/*** 이벤트 핸들러  ***/
	grid.addEvent("onValidationFail", function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	});
	
	grid.addEvent( "onCellButtonClicked", function( grid, itemIndex, column){
		switch( column.fieldName ){
		case "programName" :
			var programPopup = myForm.popupInfo.programPopup;
			var programName =  grid.getValue(itemIndex,"programName");
			programPopup["programName"] = programName; 
	    	programPopup["systemCode"]  = grid.getValue(itemIndex,"systemCode"); 

	    	//조회용 초기 값들은 모두 주면서, 조회만 수행하지 않도록 방지 
	    	programPopup["search"] = false;
			
	    	var popup = new Popup( myForm, "lgcom", "M_LGSYSC_1135", "<lgcom:message code="ProgramSearch"/>" );
	    	popup.setSize( 600, 500 );
	    	popup.open( function(){
	    		grid.setValue(itemIndex, 'programId', programPopup.programId );
	    		grid.setValue(itemIndex, 'programName', programPopup.programName);
	    		grid.setValue(itemIndex, 'systemCode', programPopup.systemCode);
	    		grid.setValue(itemIndex, 'moduleCode', programPopup.moduleCode);
	    	});
	    	
	    	break;  
	    	
		case "requesterFullName" :
			var userPopup = myForm.popupInfo.userPopup;
			userPopup["employeeName"] = grid.getValue(itemIndex,"requesterName"); 
            userPopup["search"] = false;
            userPopup['searchMode'] = 'single';
            var popup = new Popup( myForm,'lgcom', 'M_LGUTLC_1142', '<lgcom:message code="UserSearch"/>' );
	    	popup.setSize(800,494);
	    	popup.open( function(){
	    		var user = userPopup.userData[0];
	    		var fullName = user.employeeName + "/" + user.titleName + "/" + user.departmentName  ;
	    		grid.setValue(itemIndex, 'requesterName', user.employeeName);
	    		grid.setValue(itemIndex, 'requesterFullName', fullName);
	    		grid.setValue(itemIndex, 'requesterId', user.userId);
		    	//cgrid.commit();
	    	});
			
			break;
		}
	});
	
	myForm.addEvent( "click", "button.find" , function(event){
		// 팝업에 사용될 Argument 객체 선언
		var _popup = myForm.popupInfo.userPopup;
		// 입력된 사용자명을 세팅한다.
		_popup.employeeName = formUtil.getValue("employeeName");
		// 팝업을 호출한다.
		var popup = new Popup(myForm,'lgcom','M_LGUTLC_1142','<lgcom:message code="UserSearch"/>');
		popup.setSize(800,494);
		popup.open( function(){
			formUtil.setValue( { employeeName:_popup.userData[0].employeeName,
				                 employeeId:_popup.userData[0].userId } );
		});	
		_popup.userData = [];
	});
	
	
	myForm.addEvent( "click", "button[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ){
		    case "search" :		
				var cgrid = grid.getGridBase();
				cgrid.commit();
				
		    	var parameter = formUtil.getValue();
		    	grid.loadData( "lgcom", "lgutlc/LGUTLC00220/retrieveBatchScheduleList" , parameter , function(){
				    var list = data["result"];
		    	});
		      	break;
			case "add" :
				var cgrid = grid.getGridBase();
				cgrid.commit();
				var curr = cgrid.getCurrent();
				var curIndex = 0;
				
				if(curr.itemIndex < 0) {
					cgrid.beginAppendRow();
				} else {
					cgrid.beginInsertRow(curr.itemIndex);
					curIndex = curr.itemIndex;
				}
				
				cgrid.setValue(curIndex,'systemCode','');
				cgrid.setValue(curIndex,'moduleCode','');
				cgrid.setValue(curIndex,'programId','');
				cgrid.setValue(curIndex,'programName','');
				cgrid.setValue(curIndex,'requestStartDate', DateUtil.today("YYYY-MM-DD HH:mm:ss") ); 
				cgrid.setValue(curIndex,'requestEndDate', "" );
				cgrid.setValue(curIndex,'runAloneFlag', "N" );
				cgrid.setValue(curIndex,'holdFlag', "N" );
				cgrid.setValue(curIndex,'useFlag', "Y" );
				cgrid.setValue(curIndex,'argumentText', "{}" );
				cgrid.setValue(curIndex,'submitInterval', "1" ); 
				cgrid.setValue(curIndex,'submitIntervalTypeCode', "START" ); 
				cgrid.setValue(curIndex,'submitIntervalUnitCode', "MINUTE" ); 
				cgrid.setCurrent({column:'programName'});
				cgrid.setFocus();
				break;

			case "delete" :
				grid.getGridBase().deleteSelection(true);
				grid.getGridBase().setSelectOptions( {style : "rows"});
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
					grid.saveChanges( "lgcom", 'lgutlc/LGUTLC00220/saveBatchScheduleList', function(data) {
						Message.notify('<lgcom:message code="note.completed"/>');
						// 저장 완료후 목록 재조회
						myForm.select(".searchBlock button[data-action='search']").trigger('click');
					});
				});

				break;	
		}
	});    
	
	/*** 내부 함수 ***/
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		
	 	//마우스 오른쪽 클릭시 메뉴
		//grid.setContextMenu();
	 	
		// Grid Field Set
		grid.setFields([
		    { fieldName:'batchId'    	         , dataType:'text'},	                
			{ fieldName:'requestStartDate'       , dataType:'text'},
			{ fieldName:'requestEndDate'         , dataType:'text'}, //dataType: "datetime", datetimeFormat: "yyyy-MM-dd HH:mm:ss"},
			{ fieldName:'systemCode'    	     , dataType:'text'},
			{ fieldName:'moduleCode'    	     , dataType:'text'},
			{ fieldName:'requesterId'    	     , dataType:'text'},
			{ fieldName:'batchName'      	     , dataType:'text'},
			{ fieldName:'requesterName'    	     , dataType:'text'},
			{ fieldName:'requesterFullName'    	 , dataType:'text'},
			{ fieldName:'submitInterval'    	 , dataType:'text'},
			{ fieldName:'programId'    	         , dataType:'text'},
			{ fieldName:'programName'    	     , dataType:'text'},
			{ fieldName:'submitIntervalUnitCode' , dataType:'text'},
			{ fieldName:'submitIntervalTypeCode' , dataType:'text'},
			{ fieldName:'runAloneFlag'    	     , dataType:'text'},	
			{ fieldName:'useFlag'    	         , dataType:'text'},
			{ fieldName:'holdFlag'    	         , dataType:'text'},
			{ fieldName:'argumentText'    	     , dataType:'text'}
		]);
		
		grid.setValidations([
		    {criteria: "value['programName'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='programName'/>"/>',mode:'always',level:'error'},
			{criteria: "value['requesterName'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='requesterName'/>"/>',mode:'always',level:'error'},
			{criteria: "value['submitInterval'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='submitInterval'/>"/>',mode:'always',level:'error'},
			{criteria: "value['requestStartDate'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='requestStartDate'/>"/>',mode:'always',level:'error'}
		]);
		
		grid.setLookups({
			intervalUnitCode:code.get("intervalUnitCode"),
			intervalTypeCode:code.get("intervalTypeCode"),
			useFlag : code.get("useFlag"),
			holdFlag : code.get("holdFlag")
		});
		
		// Grid Column Set
		grid.setColumns([
							{
								name:'programId',
								fieldName:'programId',
								width:90,
								header: {text:'<lgcom:message code='ProgramId'/>'},
								styles: {textAlignment:'center'},
								editable : false
							},
							{
								name:'programName',
								fieldName:'programName',
								width:150,
								type: 'data',
								button : "action",
								header: {text:'<lgcom:message code='programName'/>'}, 
								styles: {textAlignment:'center'},
								editable : false
							},
							{
								name:'requesterFullName',
								fieldName:'requesterFullName',
								width:200,
								type: 'data',
								button : "action",
								header: {text:'<lgcom:message code='requesterName'/>'},
								styles: {textAlignment:'center'},
								editable : false
							},
							{
								name:'batchName',
								fieldName:'batchName',
								width:200,
								type: 'data',
								header: {text:'<lgcom:message code='batchName'/>'},
								editable : true
							},
							{
								name:'submitInterval',
								fieldName:'submitInterval',
								width:50,
								type: 'data',
								header: {text:'<lgcom:message code="submitInterval"/>'},
								styles: {textAlignment:'center'},
								editable : true
							},
							{
								name:'submitIntervalUnitCode',
								fieldName:'submitIntervalUnitCode',
								width:60,
								type: 'data',
								lookupDisplay: true,
								lookupSourceId: 'intervalUnitCode',
								lookupKeyFields: ['submitIntervalUnitCode'],
								header: {text:'<lgcom:message code="submitIntervalUnitCode"/>'},
								styles: {textAlignment:'center'},
								editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
							},
							{
								name:'submitIntervalTypeCode',
								fieldName:'submitIntervalTypeCode',
								width:90,
								type: 'data',
								lookupDisplay: true,
								lookupSourceId: 'intervalTypeCode',
								lookupKeyFields: ['submitIntervalTypeCode'],
								header: {text:'<lgcom:message code="submitIntervalTypeCode"/>'},
								styles: {textAlignment:'center'},
								editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
							},		
							{
								name:'argumentText',
								fieldName:'argumentText',
								width:150,
								type: 'data',
								header: {text:'<lgcom:message code="argumentText"/>'},
								editable : true
							},
							{
								name:'holdFlag',
								fieldName:'holdFlag',
								width:80,
								header: {text:'<lgcom:message code="HoldFlag"/>'},
								styles: {textAlignment:'center'},
								lookupDisplay: true,
								lookupSourceId: 'holdFlag',
								lookupKeyFields: ['holdFlag'],
								editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
							},
							{
								name:'runAloneFlag',
								fieldName:'runAloneFlag',
								width:80,
								header: {text:'<lgcom:message code="RunAloneFlag"/>'},
								styles: {textAlignment:'center'},
								lookupDisplay: true,
								lookupSourceId: 'useFlag',
								lookupKeyFields: ['useFlag'],
								editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
							},	
							{
								name:'requestStartDate',
								fieldName:'requestStartDate',
								width:130,
								type: 'data',
								header: {text:'<lgcom:message code="RequestStartDate"/>'},
								styles: {textAlignment:'center', datetimeFormat: "yyyy-MM-dd HH:mm:ss" },
								editor : { 
									datetimeFormat: "yyyy-MM-dd HH:mm:ss"
								},
								editable : true
							},
							{
								name:'requestEndDate',
								fieldName:'requestEndDate',
								width:130,
								type: 'data',
								header: {text:'<lgcom:message code="RequestEndDate"/>'},
								styles: {textAlignment:'center', datetimeFormat: "yyyy-MM-dd HH:mm:ss"},
								editor : { 
									datetimeFormat: "yyyy-MM-dd HH:mm:ss"
								},
								editable : true
							}
						]);
		
		// Grid Option Set
		grid.setOptions({  
			grid: {
				softDeleting: true,
				deleteCreated: true,
				hideDeletedRows:false,
				indicator: {visible:true},
				panel: {visible:false},
				stateBar: {visible:true},
				footer: {visible:false},
				checkBar: { visible: false },
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
			}
		});

		return grid;
	}	
}


LGUTLC00220.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch( function(){
		var form = new LGUTLC00220();
		form.init();
	});		
});

</script>

</head>

<body> 
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Batch Schedule</h2>
	</div>
	<div class="searchBlock">
		<form class="form search-wrap">
				<table class="table">
					<colgroup>
						<col width="70">
						<col width="80">
						<col width="70">
						<col width="80">
						<col width="70">
						<col width="90">
						<col width="90">
						<col width="110">
						<col width="90">
					</colgroup>
					<tbody>
						<tr>
							<th><label><lgcom:message code="System"/></label></th>
							<td><select class="form-control input-sm" name="systemCode"></select></td>
							
							<th><label><lgcom:message code="Module"/></label></th>
							<td><select class="form-control input-sm" name="moduleCode"></select></td>
							
							<th scope="col"><label><lgcom:message code="batchName"/></label></th>
							<td><input type="text" name="batchName" class="form-control input-sm" placeholder=""/></td>
							
							<th scope="col"><label><lgcom:message code="EmployeeName"/></label></th>
							<td>
		                        <div class="input-group input-group-sm input-search">
		                            <input type="hidden" name="employeeId" />
		                            <input type="text" class="form-control size_150" name="employeeName"  />
		                            <span class="input-group-btn">
		                                <button class="btn btn-default ico-lgd find" type="button">
		                                    <span class="fa fa-search" aria-hidden="true"></span>
		                                </button>
		                            </span>
		                        </div>
							</td>
							
							<th scope="col"><lgcom:message code="HoldFlag"/></th>
							<td><select name="holdFlag" class="form-control input-sm"></select></td>
						</tr>
					</tbody>
				</table>
			<button type="button" class="btn btn-lgd btn-sm btn-search" data-action="search" data-access="LGSYSC00030/retrieveUserList"><lgcom:message code="search"/></button>
		</form>
	</div>


	<div class="gridControls module-group text-right">
		<div class="btn-toolbar">	
			<div class="btn-group">	
				<button class="btn btn-default btn-sm ico-lgd" type="submit" data-action="add"><span class="fa fa-plus" aria-hidden="true"></span><lgcom:message code="add"/></button>
				<button class="btn btn-default btn-sm ico-lgd" type="submit" data-action="delete"><span class="fa fa-minus" aria-hidden="true"></span><lgcom:message code="delete"/></button>
				<!--<button class="btn btn-default btn-sm" type="submit" data-action="cachedInfo">Cached Info</button>-->
			</div>
			<div class="btn-group">		
				<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save" data-access="LGSYSC00030/saveUserList"><lgcom:message code="save"/></button>
			</div>
		</div>		
	</div>
	<div class="gridContent grid-wrap">
		<div class="grid scheduleGrid"></div>
	</div>
</section>
</div>
</body>
</html>
