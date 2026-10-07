<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGSETC00050.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본화면은 Code Value를 검색하기 위한 팝업 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Code Value Popup</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">

var LGSETC00050 = function(){
	var myForm = this;
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	
  	//팝업으로서의 이 화면은 여러 화면에서 사용하는 것으로, 팝업 윈도우의 크기를 아래와 같이 고정하였다.
	myForm.select(".searchBlock").parents("._div_popup_holder_").css({"width": "800px", "height":"500px"});
  	
    /* Layout Setting */
	myForm.setLayout( [ 
		{ name  : "searchBlock", left : 0, right : 0, top : 0 },		
		{ name  : "content",     left : 0, right : 0, top : "searchBlock", bottom : "controls"},
		{ name  : "controls",    left : 0, right : 0, bottom : 0 }	 	
	]);
    	
	var _popupInfo;

	var code = new CommonCode("lgcom");
	var systemCode = code.execute('systemCode',{codeTypeCode:'LGCOM_SYSTEM_CODE'});
	var moduleCode = code.execute('moduleCode',{codeTypeCode:'LGCOM_MODULE_CODE'});
	formUtil.initCombo('systemCode',systemCode,{selectAll:true});
	formUtil.initCombo('moduleCode',moduleCode,{selectAll:true});

	var grid = buildGrid("LGSETC00050_grid");

	myForm.initMyForm = function() {
		_popupInfo = myForm.getParent().popupInfo.parentCodePopup;
		if(_popupInfo) {
			if($.trim(_popupInfo['systemCode']) != '') {
				formUtil.setValue({systemCode: _popupInfo['systemCode']});
			}
			if($.trim(_popupInfo['moduleCode']) != '') {
				formUtil.setValue({moduleCode: _popupInfo['moduleCode']});
			}
			if(_popupInfo.findKey && _popupInfo.findKey != '') {
				formUtil.setValue({codeTypeCode: _popupInfo['findKey']});
			}
			if(_popupInfo.modYn=='Y'){
				formUtil.enable('codeTypeCode');
			} else if(_popupInfo.modYn=='N') {
				formUtil.disable('codeTypeCode');
			}
			myForm.select(".searchBlock button[data-action='search']").trigger('click');
		}
	};


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
				grid.loadData('lgcom','lgsetc/LGSETC00050/retrieveParentCodeList',param,function(data) {
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
					{ fieldName:'codeTypeCode'     	, dataType:'text'  },
					{ fieldName:'codeTypeCodeDesc'  , dataType:'text'  },
					{ fieldName:'commonCode'  		, dataType:'text'  },
					{ fieldName:'commonCodeName'  	, dataType:'text'  }
				]
		);
		//컬럼 설정
		grid.setColumns(
				[
					{
						name:'codeTypeCode',
						fieldName:'codeTypeCode',
						width:100,
						header: {text:'<lgcom:message code="CodeType"/>'},
			            editable: false
					},
					{
						name:'codeTypeCodeDesc',
						fieldName:'codeTypeCodeDesc',
						width:100,
						header: {text:'Code Type Name'},
			            editable: false
					},
					{
						name:'commonCode',
						fieldName:'commonCode',
						width:100,
						header: {text:'<lgcom:message code="CommonCode"/>'},
						editable: false
					},
					{
						name:'commonCodeName',
						fieldName:'commonCodeName',
						width:100,
						header: {text:'Code Name'},
						editable: false
					},
				]
		);

		return grid;
	}
	/*
	function init() {
		var param =  myForm.select(".searchBlock form").toJSON();
		grid.loadData('lgsetc/LGSETC00050/retrieveParentCodeList', param );
	}
	*/
};

LGSETC00050.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGSETC00050();
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
        <form class="form search-wrap">
                <table class="table" >
                    <colgroup>
                        <col width="90">
                        <col width="90">
                        <col width="90">
                        <col width="90">
                        <col width="120">
                        <col width="220">
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

                            <th><label><lgcom:message code="CodeType"/></th>
                            <td><input type="text" class="form-control input-sm" name="codeTypeCode"></td>
                        </tr>
                    </tbody>
                </table>
            <button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search" data-access="LGSYSC00140/retrieveProgramList" ><lgcom:message code="search" /></button>
        </form>
	</div>
	<div class="content grid-wrap" >
	   <div id="LGSETC00050_grid" class="grid"></div>
	</div>
	<div class="controls modal-footer">
		<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="ok"><lgcom:message code="ok"/></button>
		<button class="btn btn-gray btn-sm" type="button" role="button" data-action="cancel"><lgcom:message code="cancel"/></button>
    </div>
    </section>
</div>
</body>
</html>
