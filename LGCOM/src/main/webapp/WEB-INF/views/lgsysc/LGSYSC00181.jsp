<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGSYSC00180.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : Program Search Popup
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Program Search</title>
<style type="text/css">

</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">

var LGSYSC00181 = function(){
	var myForm = this;

	myForm.popupInfo = { programPopup : {} };

	//팝업으로서의 이 화면은 여러 화면에서 사용하는 것으로, 팝업 윈도우의 크기를 아래와 같이 고정하였다.
	myForm.select(".searchBlock").parents("._div_popup_holder_").css({"width": "700px", "height":"500px"});

	/*
    myForm.setManagedLayout(
    		{  searchBlock : { line : 1,   left : 0, right :  0 },
			       content : { line : 3,   left : 0, right :  0, bottom : 48 },
                  controls : {             left : 0, right :  0, height : 38, bottom : 0 }
			}, 
    		{  searchBlock : { line : 1,   left : 0,  right :  0 },
			       content : { line : 2,   left : 0,  right :  0, bottom : 40 },
                  controls : { left : 0 , right : 0, height : 30, bottom : 0 }
			}
    );
	*/
	myForm.setLayout([ 
	                  { name : "searchBlock" , left : 0, right : 0, top : 0 },
	                  { name : "content" , left : 0, right : 0, top : "searchBlock", bottom : "controls" },
	                  { name : "controls",left : 0, right : 0, bottom : 0 }
	]);

	var grid = buildGrid('.programList');
	var formUtil = new FormUtil( myForm, ".searchBlock form");
	var programPopup = myForm.getParent().popupInfo.programPopup;

	// 조회조건 Combo 초기화
	var code = new CommonCode("lgcom");
	code.add(  "LGCOM_SYSTEM_CODE" , { codeTypeCode : "LGCOM_SYSTEM_CODE" } );
	code.add(  "LGCOM_MODULE_CODE" , { codeTypeCode : "LGCOM_MODULE_CODE" } );
	code.execute()
	// System code
	formUtil.initCombo( "systemCode", code.get("LGCOM_SYSTEM_CODE") , {selectAll : true} );
	if($.trim(programPopup["systemCode"]) != '') {
		formUtil.setValue('systemCode',$.trim(programPopup["systemCode"]));
	}
	// Module Code
	formUtil.initCombo( "moduleCode", code.get("LGCOM_MODULE_CODE") , {selectAll : true , filter : "systemCode"});
	if($.trim(programPopup["moduleCode"]) != '') {
		formUtil.setValue('moduleCode',$.trim(programPopup["moduleCode"]));
	}
	if($.trim(programPopup["programName"]) != '') {
		formUtil.setValue('programName',$.trim(programPopup["programName"]));
	}

	// 검색어가 주어지면 값을 세팅하고 조회한다.
	var isSearch = false;
	if( formUtil.getValue("programName") != "" ) {
		isSearch = true;
	}
	
	//무엇보다도 초기 Search 를 방지하는 코드를 넣으면, 이로써 조회가 발생하지 않도록 한다. 
	if( programPopup['search'] ) {
		isSearch = true;
	} else {
		isSearch = false;
	}
	
	if( isSearch ) {
 		var parameter = formUtil.getValue();
     	grid.loadData("lgcom", "lgsysc/LGSYSC00180/retrieveProgramList" , parameter , function( data ){
 		    var list = data["result"];
 		    if( list.length == 1 ) {
 		    	programPopup["programId"]   = list[0].programId;
 		    	programPopup["programName"] = list[0].programName;
 		    	Popup.closePopup( myForm, true );
 		    }
     	});
 	}

	/*** 이벤트 핸들러  ***/
	grid.getGridBase().onDataCellDblClicked =  function ( mgrid, index) {
		var rowData = mgrid.getValues( index.itemIndex );
		programPopup["programId"]   = rowData.programId;
		programPopup["programName"] = rowData.programName;
	    programPopup["systemCode"]  = rowData.systemCode;
	    programPopup["moduleCode"]  = rowData.moduleCode;	
		trace( programPopup );
	    Popup.closePopup( myForm, true );
    };

	myForm.addEvent( "click", "button[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ){
		    case "search" :
		    	var parameter = formUtil.getValue();
		    	grid.loadData( "lgcom", "lgsysc/LGSYSC00180/retrieveProgramList" , parameter , function(){
				    var list = data["result"];
				    if( list.length == 1 ) {
				    	programPopup["programId"]   = list[0].programId;
				    	programPopup["programName"] = list[0].programName;
				    	programPopup["systemCode"]  = list[0].systemCode;
					    programPopup["moduleCode"]  = list[0].moduleCode;
				    	Popup.closePopup( myForm, true );
				    }
		    	});
		      	break;
		    case "ok" :
			    var current = grid.getGridBase().getCurrent();

			    if (current == undefined ) { return; }

			    var rowData = grid.getDataProvider().getJsonRow( current.dataRow );

			    programPopup["programId"]   = rowData.programId;
			    programPopup["programName"] = rowData.programName;
			    programPopup["systemCode"]  = rowData.systemCode;
			    programPopup["moduleCode"]  = rowData.moduleCode;

		    	Popup.closePopup( myForm, true );

		    	break;
		    case "cancel" :
		    	Popup.closePopup(myForm);
		    	break;

		    case "test" :

		    	var popup = new Popup( myForm, "lgcom", "M_LGSYSC_1135", "<lgcom:message code="ProgramSearch"/>" );
		    	popup.setSize( 500, 500 );
		    	popup.open( function(){
		    		var menuInfo = menuTree.getMenuInfo( menuForm.getValue("menuId")  );

		    		if( menuInfo["status"] != "C" && ( menuInfo["programId"] != programPopup["programId"] ) ) {
		    			menuInfo["status"] = "U";
		    		}

		    		menuForm.setValue( "programId", programPopup["programId"] );
                    menuForm.setValue( "programName",programPopup["programName"] ).focus();

                    menuInfo["programId"] =  programPopup["programId"];
		    	    menuInfo["programName"] = programPopup["programName"];

                    menuTree.refresh();
		    	});

		    	break;
		}
	});

	/*** 내부 함수 ***/
	function buildGrid( gridId) {
		var grid = new RealGrid( myForm, gridId);
		grid.setPagingMode(true);

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
		//grid.setContextMenu();

		// Grid Field Set
		grid.setFields([
			{ fieldName:'systemCode'    , dataType:'text'},
			{ fieldName:'moduleCode'    , dataType:'text'},
			{ fieldName:'programId'     , dataType:'text'},
			{ fieldName:'programName'   , dataType:'text'}
		]);
		// Grid Column Set
		grid.setColumns([
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
								name:'programId',
								fieldName:'programId',
								width:70,
								header: {text:'<lgcom:message code="ProgramId" />'},
								styles: {textAlignment:'center'},
								editable: false
							},
							{
								name:'programName',
								fieldName:'programName',
								width:110,
								header: {text:'<lgcom:message code="ProgramName" />'},
								styles: {textAlignment:'near'},
								editable: false
							}
						]);
		// Grid Option Set
		grid.setOptions({
			grid: {
				hideDeletedRows: true,
				indicator: {visible:false},
				panel: {visible:false},
				stateBar: {visible:false},
				footer: {visible:false},
				checkBar: { visible: false }
			},
			display: { fitStyle: 'evenFill' }
		});
		return grid;
	}


}


LGSYSC00181.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	//launch( function(){
		var form = new LGSYSC00181();
		form.init();
	//});
});

</script>
</head>

<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="searchBlock">
		<form class="form search-wrap">
		        <table class="table" >
		            <colgroup>
		                <col width="120">
		                <col width="100">
		                <col width="120">
		                <col width="100">
		            </colgroup>
		            <tbody>
		                <tr>
		                    <th><label ><lgcom:message code="System" /></label></th>
		                    <td>
		                        <select class="form-control input-sm" name="systemCode"></select>
		                    </td>

		                    <th><label ><lgcom:message code="Module" /></label></th>
		                    <td>
		                        <select class="form-control input-sm" name="moduleCode"></select>
		                    </td>
		                </tr>

		                <tr>
		                    <th><label ><lgcom:message code="ProgramName" /></label></th>
		                    <td>
		                        <input type="text" class="form-control input-sm" name="programName" />
		                    </td>

		                    <th><label ><lgcom:message code="ProgramId" /></label></th>
		                    <td>
		                        <input type="text" class="form-control input-sm" name="programId" />
		                    </td>
		                </tr>
		            </tbody>
		        </table>
		    <button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
		</form>

	</div>

	<div class="content grid-wrap">
		<div class="grid programList"></div>
	</div>

	<div class="controls text-right" >
        <button class="btn btn-darkgray btn-sm" type="submit" data-action="ok" ><lgcom:message code="ok" /></button>
        <button class="btn btn-gray btn-sm" href="#" role="button" data-action="cancel"><lgcom:message code="cancel" /></button>
    </div>
</section>
</div>
</body>
</html>
