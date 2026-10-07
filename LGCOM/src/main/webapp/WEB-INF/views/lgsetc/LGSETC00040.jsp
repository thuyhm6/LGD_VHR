<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGSETC00040.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2012 LG CNS,  All rights reserved.

    설 명 : 본화면은 Code Type을 검색하기 위한 팝업 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>LGCOM - Code Type Popup</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">

var LGSETC00040 = function(){
	var myForm = this;	 
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	
    //팝업으로서의 이 화면은 여러 화면에서 사용하는 것으로, 팝업 윈도우의 크기를 아래와 같이 고정하였다. 
    myForm.select(".searchBlock").parents("._div_popup_holder_").css({"width": "900px", "height":"500px"});
	
    /* Layout Setting */
	myForm.setLayout( [ 
		{ name  : "searchBlock", left : 0, right : 0, top : 0 },		
		{ name  : "content", left : 0, right : 0, top : "searchBlock", bottom : "controls"},
		{ name  : "controls", left : 0, right : 0, bottom : 0 }	 	
	]);
    
	var _popupInfo;
	
	myForm.initMyForm = function(){
		_popupInfo = myForm.getParent().popupInfo.codePopup;
		if(_popupInfo) {			
			if(_popupInfo.findKey && _popupInfo.findKey != '') {
				formUtil.setValue({codeTypeCode: _popupInfo['findKey']});
				myForm.select(".searchBlock button[data-action='search']").trigger('click');
			}
		}
	}
		    
	var code = new CommonCode("lgcom");
	code.add( "LGCOM_YN_FLAG", { codeTypeCode:'LGCOM_YN_FLAG' });
	code.add( "LGCOM_SYSTEM_CODE", { codeTypeCode:'LGCOM_SYSTEM_CODE' });
	code.add( "LGCOM_MODULE_CODE", { codeTypeCode:'LGCOM_MODULE_CODE' });	
	code.execute();
		
	formUtil.initCombo( "systemCode", code.get("LGCOM_SYSTEM_CODE"), {selectAll : true } );
	formUtil.initCombo( "moduleCode", code.get("LGCOM_MODULE_CODE"), {selectAll : true, filter : "systemCode" } );
	formUtil.initCombo( "useFlag", code.get("LGCOM_YN_FLAG") );
    
    myForm.loadCompleted = function() {
		formUtil.setValue({useFlag:'Y'});
	};
	
   
    var grid = buildGrid("LGSETC00040_grid");  
    
   	// Selection Mode 변경
    grid.setSelectMode(RealGrid.SELECTION_BLOCKLINE);
    

	/*** 이벤트 핸들러  ***/
	myForm.addEvent( "click", "button[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ){
		    case "search" :
		    	var param =  myForm.select(".searchBlock form").toJSON();										
				grid.loadData('lgcom','lgsetc/LGSETC00040/retrieveCodeTypePopupList',param,function(data) {

					// 결과목록이 1건일 경우 선택후 창을 닫는다.
					if(data.result.length == 1) {
						_popupInfo.codeData.push(grid.getGridBase().getValues(0));
						Popup.closePopup( myForm, true );
					}
				});
				break;		    	
		    case "ok" :
		    	var current = grid.getGridBase().getCurrent();
				var cRow = 0; 				
			    if (current) {
			    	cRow = Math.max(0, current.dataRow);
			    }	
		    	_popupInfo.codeData.push(grid.getGridBase().getValues(cRow));
		    	Popup.closePopup( myForm, true );   	
		    break;
		    case "cancel" :
		    	Popup.closePopup(myForm); 	
		    break;	
		}
		
		event.stopPropagation();
	});   
	
	grid.getGridBase().onDataCellDblClicked = function(cgrid, index) {
		var current = grid.getGridBase().getCurrent();
		var cRow = 0; 				
	    if (current) {
	    	cRow = Math.max(0, current.dataRow);
	    }	
    	_popupInfo.codeData.push(grid.getGridBase().getValues(cRow));
    	Popup.closePopup( myForm, true ); 
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
				hideDeletedRows:true,
				indicator: {visible:false},
				panel: {visible:false},
				checkBar: {visible:false},
				stateBar: {visible:false},
				footer: {visible:false},
				edit: {
					insertable: true,
					appendable: true,
					updatable: true,
					deletable: true
				}
			},
			display: { fitStyle: 'evenFill' }
		});		
		
		//마우스 오른쪽 클릭시 메뉴
		grid.setContextMenu();
		
		//필드 설정
		grid.setFields(
				[
					{ fieldName:'systemCode'		, dataType:'text'  },
					{ fieldName:'moduleCode'  		, dataType:'text'  },
					{ fieldName:'codeTypeCode'     	, dataType:'text'  },
					{ fieldName:'codeTypeCodeDesc'  , dataType:'text'  },
					{ fieldName:'controlLevelCode'  , dataType:'text'  },
					{ fieldName:'controlLevelCodeName'  , dataType:'text'  },
					{ fieldName:'accessLevelCode'   , dataType:'text'  },
					{ fieldName:'accessLevelCodeName'   , dataType:'text'  }					
				]
		);
		//컬럼 설정 
		grid.setColumns(
				[
					{
						name:'systemCode',
						fieldName:'systemCode',
						width:70,
						header: {text:'<lgcom:message code="System"/>'},
						styles: {textAlignment:'center'},
			            editable: false		        
					},
					{
						name:'moduleCode',
						fieldName:'moduleCode',
						width:70,
						header: {text:'<lgcom:message code="Module"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'codeTypeCode',
						fieldName:'codeTypeCode',
						width:150,
						header: {text:'<lgcom:message code="CodeType"/>'},
						editable: false
					},	
					{
						name:'codeTypeCodeDesc',
						fieldName:'codeTypeCodeDesc',
						width:130,
						header: {text:'<lgcom:message code="CodeTypeDesc"/>'},
			            editable: false		        
					},
					{
						name:'controlLevelCodeName',
						fieldName:'controlLevelCodeName',
						width:80,
						header: {text:'<lgcom:message code="ControlLevel"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'accessLevelCodeName',
						fieldName:'accessLevelCodeName',
						width:80,
						header: {text:'<lgcom:message code="AccessLevel"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
				]
		);
	
		return grid;
	}
}


LGSETC00040.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {	
	launch(function(){
		var form = new LGSETC00040();
		form.init();
		form.initMyForm();
		form.loadCompleted();
	});
});

</script>

</head>

<body> 
<div class="mdi-container popup">
  <section class="page-content">
	<div class="searchBlock"> 
		<div class="pageHeader">
			<h2><lgcom:message code="UserList"/></h2>
		</div>	
		<form class="form search-wrap">
		        <table class="table" >
		            <colgroup>
		                <col width="80">
		                <col width="80">
		                <col width="80">
		                <col width="80">
		                <col width="80">
		                <col width="150">
		                <col width="*">		                
		            </colgroup>
		            <tbody>
		                <tr>
		                    <th><label ><lgcom:message code="System" /></label></th>
		                    <td>
		                        <select class="form-control input-sm input-require" name="systemCode"></select>
		                    </td>
		                    
		                    <th><label ><lgcom:message code="Module" /></label></th>
		                    <td>
		                        <select class="form-control input-sm" name="moduleCode"></select>
		                    </td>
		                    
		                    <th><label><lgcom:message code="CodeType" /></label></th>
		                    <td><input type="text" class="form-control input-sm size_150" name="codeTypeCode"></td>                 

		                    <th><label ><lgcom:message code="UseFlag" /></label></th>
		                    <td>
		                        <select class="form-control input-sm" name="useFlag"></select>
		                    </td>		                    
		                </tr>		                		                		                
		            </tbody>
		        </table>
			    <button class="btn btn-lgd btn-sm btn-search"" type="button" data-action="search" ><lgcom:message code="search" /></button>
	    </form>		
   </div>   
	<div class="content grid-wrap" >
	   <div id="LGSETC00040_grid" class="grid"></div>
	</div>
	<div class="controls modal-footer" >
		<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="ok"><lgcom:message code="ok"/></button>
		<button class="btn btn-gray btn-sm" type="button" role="button" data-action="cancel"><lgcom:message code="cancel"/></button>
    </div>
  </section>    
</div>
</body>
</html>
