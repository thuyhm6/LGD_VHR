<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGSETC00032.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본화면은 Inventory Organization Id 검색을 위한 팝업 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>LGCOM - Inventory Organization Popup</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">

var LGSETC00032 = function(){
	var myForm = this;	 
	var _popupInfo;
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	formUtil.disable('compId');
	formUtil.disable('compName');
	
	myForm.initMyForm = function(){
		_popupInfo = myForm.getParent().popupInfo.invOrgIdPopup;
		if(_popupInfo) {			
			if(_popupInfo.findKeyComp && _popupInfo.findKeyComp != '') {
				var param = {companyId : _popupInfo.findKeyComp};	     
				transaction_sync( 'lgcom',"lgsetc/LGSETC00032/retrieveCompanyName", param, function(data){
					var check = data.result;
					formUtil.setValue({compName: check.companyName});				
				});			
				formUtil.setValue({compId: _popupInfo['findKeyComp']});
				formUtil.setValue({invOrgId: _popupInfo['findKeyInv']});
				if(_popupInfo.findKeyInv && _popupInfo.findKeyInv != ''){
					myForm.select(".searchBlock button[data-action='search']").trigger('click');
				}			
			}
		}
	}
			
    var grid = buildGrid("LGSETC00032_grid");
    
	
    //팝업으로서의 이 화면은 여러 화면에서 사용하는 것으로, 팝업 윈도우의 크기를 아래와 같이 고정하였다. 
  	myForm.select(".searchBlock").parents("._div_popup_holder_").css({"width": "900px", "height":"500px"});
    
    /* Layout Setting */
	myForm.setLayout( [ 
		{ name  : "searchBlock", left : 0, right : 0, top : 0 },		
		{ name  : "content", left : 0, right : 0, top : "searchBlock", bottom : "controls"},
		{ name  : "controls", left : 0, right : 0, bottom : 0 }	 	
	]);   
  
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
				grid.loadData('lgcom','lgsetc/LGSETC00032/retrieveInvOrgIdList',param,function(data) {
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
	});   
	
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
					{ fieldName:'compId'     	, dataType:'text'  },
					{ fieldName:'invOrgId'  	, dataType:'text'  },
					{ fieldName:'invOrgIdCode'  , dataType:'text'  },
					{ fieldName:'invOrgIdName'  , dataType:'text'  }
				]
		);
		//컬럼 설정 
		grid.setColumns(
				[
					{
						name:'invOrgIdCode',
						fieldName:'invOrgIdCode',
						width:60,
						header: {text:'<lgcom:message code="InventoryOrganizationCode"/>'},
						styles: {textAlignment:'center'},
			            editable: false		        
					},
					{
						name:'invOrgIdName',
						fieldName:'invOrgIdName',
						width:100,
						header: {text:'<lgcom:message code="InventoryOrganizationCodeName"/>'},
						editable: false
					}					
				]
		);
	
		return grid;
	}
	
	function init() {
		var param =  myForm.select(".searchBlock form").toJSON();			
		grid.loadData('lgcom','lgsetc/LGSETC00032/retrieveInvOrgIdList', param );
	}
}

LGSETC00032.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {	
	launch(function(){
		var form = new LGSETC00032();
		form.init();
		form.initMyForm();
	});
});

</script>

</head>

<body> 
<div class="mdi-container popup">
<section class="page-content">

	<div class="searchBlock">
	    <form class="form">
	     <table class="table" >   
    		<colgroup>
                <col width="300">
                <col width="100">                
                <col width="360">
                <col width="100">
            </colgroup>
            <tbody>
	            <tr>      
		          <th><label><lgcom:message code="Company"/></label></th>
			      <td><input type="text" name="compName" class="form-control input-sm"/>
			            <input type="hidden" name="compId"/>	            	  
	              </td>
	              <th><label><lgcom:message code="InventoryOrganization"/></label></th>
			      <td><input type="text" name="invOrgId" class="form-control input-sm"/></td>            	  
	            </tr>	
	        </tbody>
	      </table>	    
          <button type="button" class="btn btn-lgd btn-sm btn-search" data-action="search"><lgcom:message code="search"/></button>
	    </form>
	</div>	
	<div class="content grid-wrap" >
	   <div id="LGSETC00032_grid" class="grid"></div>
	</div>	
	<div class="controls modal-footer">
		<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="ok"><lgcom:message code="ok"/></button>
		<button class="btn btn-gray btn-sm" type="button" role="button" data-action="cancel"><lgcom:message code="cancel"/></button>
    </div>	
  </section>
</div>
</body>
</html>
