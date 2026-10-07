<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
	파일명 : LGSYSC00130.jsp
	프로젝트명 : LGD WCFW

	Copyright(c) 2012 LG CNS, All rights reserved.

	설 명 : 본 화면은 Role List 목록을 조회하는 팝업 화면입니다.
	작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Role List popup</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGSYSC00130 = function() {
	var myForm = this;
	var _popupInfo;
	var searchMode = 'multi';
	var _code;
	/* Form Util 선언 */
	var formUtil = new FormUtil(myForm,'.searchBlock form');

	//팝업으로서의 이 화면은 여러 화면에서 사용하는 것으로, 팝업 윈도우의 크기를 아래와 같이 고정하였다.
	myForm.select(".searchBlock").parents("._div_popup_holder_").css({"width": "800px", "height":"500px"});
	
    /* Layout Setting */
	myForm.setLayout( [ 
		{ name  : "searchBlock", left : 0, right : 0, top : 0 },		
		{ name  : "content", left : 0, right : 0, top : "searchBlock", bottom : "controls"},
		{ name  : "controls", left : 0, right : 0, bottom : 0 }	 	
	]);
    
	/* 조회조건 Combo 초기화 */
	_code = new CommonCode('lgcom');
	var systemCode = _code.execute('systemCode',{codeTypeCode:'LGCOM_SYSTEM_CODE'});
	var moduleCode = _code.execute('moduleCode',{codeTypeCode:'LGCOM_MODULE_CODE'});
	formUtil.initCombo('systemCode',systemCode,{selectAll:true});
	formUtil.initCombo('moduleCode',moduleCode,{selectAll:true, filter:'systemCode'});
	var grid = buildGrid('.rolePopupGrid');
	

	
	/*** OnLoad 이벤트 **/
	myForm.initMyForm = function() {
		_popupInfo = myForm.getParent().popupInfo.rolePopup;
		searchMode = _popupInfo['searchMode'];
		if(_popupInfo) {
			// 검색모드가 Single일 경우
			if(searchMode == 'single') {
				// 체크박스 숨기기
				grid.getGridBase().setCheckBar({visible:false});
			}
			if(_popupInfo['extraType']) {
				formUtil.setValue({extraType:_popupInfo['extraType']});
			}
			if(_popupInfo['extraOwn']) {
				formUtil.setValue({extraOwn:'Y'});
			} else {
				formUtil.setValue({extraOwn:'N'});
			}
			if(_popupInfo['ownUserId'] != '') {
				formUtil.setValue({ownUserId:_popupInfo['ownUserId']});
			}
			if(_popupInfo['ownPgmId'] != '') {
				formUtil.setValue({ownPgmId:_popupInfo['ownPgmId']});
			}
			if(_popupInfo['ownSvcId'] != '') {
				formUtil.setValue({ownSvcId:_popupInfo['ownSvcId']});
			}
			if(_popupInfo['findKey'] != '') {
				formUtil.setValue({roleName: _popupInfo['findKey']});
				myForm.select(".searchBlock button[data-action='search']").trigger('click');
			}
		}
	};
	/***  이벤트 핸들러  ***/
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch(action) {
			case 'search':
				var param = myForm.select('.searchBlock form').toJSON();
				grid.loadData('lgcom','lgsysc/LGSYSC00130/retrieveRolePopupList',param,function(data) {
					// 결과목록이 1건일 경우 선택후 창을 닫는다.
					if(data.result.length == 1) {
						_popupInfo.roleData.push(grid.getDataProvider().getJsonRow(0));
						Popup.closePopup(myForm,true);
					}
				});
				break;
			case 'ok':
				selectedRows();
				Popup.closePopup(myForm,true);
				break;
			case 'cancel':
				Popup.closePopup(myForm);
				break;
		}
	});
	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});
	grid.getGridBase().onShowTooltip = function (grid, index, value) {
		var column = index.column;
		if(column == 'roleName' || column == 'roleDesc') {
			return value;
		}
	};
	/* Single Mode 일 경우 Cell Double Click 하면 자동 선택 */
	grid.getGridBase().onDataCellDblClicked = function(grid, index) {
		// 검색모드가 Single일 경우
		if(searchMode == 'single') {
			selectedRows();
			Popup.closePopup(myForm,true);
		}
	};
	/*** 내부 함수 ***/
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		grid.setFields([
			{ fieldName:'applicationId'   , dataType:'number'},
			{ fieldName:'responsibilityId', dataType:'number'},
			{ fieldName:'systemCode'       },
			{ fieldName:'moduleCode'       },
			{ fieldName:'roleCode'         },
			{ fieldName:'roleName'         },
			{ fieldName:'roleDesc'         },
			{ fieldName:'applyStartDate'   },
			{ fieldName:'applyEndDate'     }
		]);
		/* Grid Lookup 세팅 */
		if(!_code) {
			_code = new CommonCode('lgcom');
		}
		_code.add('system',{codeTypeCode:'LGCOM_SYSTEM_CODE'});
		_code.add('module',{codeTypeCode:'LGCOM_MODULE_CODE'});
		_code.execute();
		grid.setLookups({
			'system': _code.get('system'),
			'module': _code.get('module')
		});
		/* Grid 컬럼 생성 */
		grid.setColumns([
			{
				name:'systemCode',
				fieldName:'systemCode',
				width:80,
				header: {text:'<lgcom:message code="System"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'system',
				lookupKeyFields: ['systemCode'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'},
				editable: false
			},
			{
				name:'moduleCode',
				fieldName:'moduleCode',
				width:80,
				header: {text:'<lgcom:message code="Module"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'module',
				lookupKeyFields: ['moduleCode'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'},
				editable: false
			},
			{
				name:'roleCode',
				fieldName:'roleCode',
				width:120,
				header: {text:'<lgcom:message code="RoleCode"/>'},
				editable: false
			},
			{
				name:'roleName',
				fieldName:'roleName',
				width:150,
				header: {text:'<lgcom:message code="RoleName"/>'},
				editable: false
			},
			{
				name:'roleDesc',
				fieldName:'roleDesc',
				width:150,
				type: 'data',
				header: {text:'<lgcom:message code="Description"/>'},
				editable: false
			}
		]);
		/* Grid Option 설정 */
		grid.setOptions({
			grid: {
				hideDeletedRows: true,
				indicator: {visible:false},
				panel: {visible:false},
				stateBar: {visible:false},
				footer: {visible:false},
				edit: {
					insertable: true,
					appendable: true,
					updatable: true,
					deletable: true
				},
				header: {
					height: 30
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
		// Context Menu Set
		grid.setContextMenu();
		return grid;
	}
	function selectedRows() {
		var bgrid = grid.getGridBase();
		if(searchMode == 'single') {
			var current = bgrid.getCurrent();
			if (current == undefined ) { return; }
			_popupInfo.roleData[0] = bgrid.getValues(current.itemIndex);
		} else {
			var checkeds = bgrid.getCheckedItems();
			if(bgrid.getItemCount() == 0) {
				Message.alert('<lgcom:message code="note.nodata"/>');
				return;
			}
			if(!checkeds || checkeds.length == 0) {
				Message.alert('<lgcom:message code="note.noselected"/>');
				return;
			}
			for(var i=0; i < checkeds.length; i++) {
				_popupInfo.roleData.push(bgrid.getValues(checkeds[i]));
			}
		}
	}
};

LGSYSC00130.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGSYSC00130();
		form.init();
		form.initMyForm();
	});
});
</script>
</head>

<body>
<div class="mdi-container popup">
  <section class="page-content">
	<div class="pageHeader">
	    <h2>Role Popup</h2>
	</div>  
	<%-- 조회영역 --%>
	<div class="searchBlock">
		<form class="form search-wrap">
			<input type="hidden" name="extraType"/>
			<input type="hidden" name="extraOwn" value="N"/>
			<input type="hidden" name="ownUserId" value=""/>
			<input type="hidden" name="ownPgmId" value=""/>
			<input type="hidden" name="ownSvcId" value=""/>
				<table class="table">
					<colgroup>
						<col width="50"/>
						<col width="120"/>
						<col width="50"/>
						<col width="120"/>
						<col width="50"/>
						<col width="150"/>
					</colgroup>
					<tbody>
						<tr>
							<th scope="col"><label><lgcom:message code="System"/></label>
							<td><select name="systemCode" class="form-control input-sm"></select>
							<th scope="col"><label><lgcom:message code="Module"/></label>
							<td><select name="moduleCode" class="form-control input-sm"></select>
							<th scope="col"><label><lgcom:message code="RoleName"/></label>
							<td><input type="text" name="roleName" class="form-control input-sm" placeholder=""/>
						</tr>
					</tbody>
				</table>
				<button type="button" class="btn btn-lgd btn-sm btn-search" data-action="search"><lgcom:message code="search"/></button>
		</form>
	</div>
	<%-- RealGrid 영역 --%>
	<div class="content grid-wrap">
		<div class="grid rolePopupGrid"></div>
	</div>
	<%-- 서버 버튼 영역 --%>
	<div class="controls text-right">
		<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="ok"><lgcom:message code="ok"/></button>
		<button class="btn btn-gray btn-sm" type="button" role="button" data-action="cancel"><lgcom:message code="cancel"/></button>
	</div>
	</section>
</div>
</body>
</html>
