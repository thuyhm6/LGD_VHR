<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
	파일명 : LGSYSC00040.jsp
	프로젝트명 : LGD WCFW

	Copyright(c) 2017 LG CNS, All rights reserved.

	설 명 : 본 화면은 User 목록을 조회하는 팝업 화면입니다.
	작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGSYSC00040 = function() {
	var myForm = this;
	var searchMode = 'multi';
	var _popupInfo;
	// Form util 선언
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	
	//팝업으로서의 이 화면은 여러 화면에서 사용하는 것으로, 팝업 윈도우의 크기를 아래와 같이 고정하였다.
	myForm.select(".searchBlock").parents("._div_popup_holder_").css({"width": "812px", "height":"494px"});
	
    /* Layout Setting */
	myForm.setLayout( [ 
		{ name  : "searchBlock", left : 0, right : 0, top : 0 },		
		{ name  : "content", left : 0, right : 0, top : "searchBlock", bottom : "controls"},
		{ name  : "controls", left : 0, right : 0, bottom : 0 }	 	
	]);
	// 그리드 초기화
	var grid = buildGrid('.userPopupGrid');

	// 화면 Open시
	myForm.initMyForm = function() {
		// 검색 모드가 single 일 경우
		_popupInfo = myForm.getParent().popupInfo.userPopup;
		if(_popupInfo['userData']) {
			delete _popupInfo['userData'];
		}
		searchMode = $.trim(_popupInfo['searchMode']);
		if(searchMode == 'single') {
			// 체크박스 숨기기
			grid.getGridBase().setCheckBar({visible:false});
		}
		// 검색어가 주어지면 값을 세팅하고 조회한다.
		var isSearch = false;
		if($.trim(_popupInfo['departmentName']) != '') {
			formUtil.setValue({departmentName:_popupInfo['departmentName']});
			isSearch = true;
		}
		if($.trim(_popupInfo['mailAddr']) != '') {
			formUtil.setValue({mailAddr:_popupInfo['mailAddr']});
			isSearch = true;
		}
		if($.trim(_popupInfo['employeeName']) != '') {
			formUtil.setValue({employeeName:_popupInfo['employeeName']});
			isSearch = true;
		}
		
		formUtil.setValue({programId:_popupInfo['programId']});
		
		//무엇보다도 초기 Search 를 방지하는 코드를 넣으면, 이로써 조회가 발생하지 않도록 한다. 
		if( _popupInfo['search'] ) {
			isSearch = true;
		} else {
			isSearch = false;
		}

		if(isSearch) {
			myForm.select(".searchBlock button[data-action='search']").trigger('click');
		}
	}
	/* 버튼 제어 */
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch(action) {
			case 'search':
				var param = formUtil.getValue();
				grid.loadData('lgcom','lgsysc/LGSYSC00040/retrieveUserPopupList',param,function(data) {
					// 결과가 1건이면 자동선택후 종료한다.
					if(data.result.length == 1) {
						addUserList(grid.getDataProvider().getJsonRow(0));
						Popup.closePopup(myForm,true);
					}
				});
				break;
			case 'ok':
				var bgrid = grid.getGridBase();
				if(searchMode == 'single') {
					var current = bgrid.getCurrent();
					if (current == undefined ) { return; }
					addUserList(bgrid.getValues(current.itemIndex));
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
						addUserList(bgrid.getValues(checkeds[i]));
					}
				}
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
	/* Single Mode 일 경우 Cell Double Click 하면 자동 선택 */
	grid.getGridBase().onDataCellDblClicked = function(cgrid, index) {
		// 검색모드가 Single일 경우
		if(searchMode == 'single') {
			var current = cgrid.getCurrent();
			if (current == undefined ) { return; }
			addUserList(cgrid.getValues(current.itemIndex));
			Popup.closePopup(myForm,true);
		}
	};
	/*** 내부 함수 ***/
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		// Grid Field Set
		grid.setFields([
			{ fieldName:'userId'           , dataType:'number'},
			{ fieldName:'employeeNo'       , dataType:'text'  },
			{ fieldName:'employeeName'     , dataType:'text'  },
			{ fieldName:'englishFullName'  , dataType:'text'  },
			{ fieldName:'positionName'     , dataType:'text'  },
			{ fieldName:'titleName'        , dataType:'text'  },
			{ fieldName:'departmentCode'   , dataType:'text'  },
			{ fieldName:'departmentName'   , dataType:'text'  },
			{ fieldName:'officePhoneNumber', dataType:'text'  },
			{ fieldName:'mobilePhoneNumber', dataType:'text'  },
			{ fieldName:'mailAddr'         , dataType:'text'  },
			{ fieldName:'employeeDesc'     , dataType:'text'  },
			{ fieldName:'teamName'         , dataType:'text'  }
		]);
		// Grid Column Set
		grid.setColumns([
			{
				name:'employeeName',
				fieldName:'employeeName',
				width:150,
				header: {text:'<lgcom:message code="EmployeeName"/>'},
				editable: false
			},
			{
				name:'englishFullName',
				fieldName:'englishFullName',
				width:150,
				header: {text:'<lgcom:message code="EnglishFullName"/>'},
				editable: false
			},
			{
				name:'departmentName',
				fieldName:'departmentName',
				width:150,
				header: {text:'<lgcom:message code="Department"/>'},
				editable: false
			},
			{
				name:'officePhoneNumber',
				fieldName:'officePhoneNumber',
				width:100,
				header: {text:'<lgcom:message code="OfficePhoneNumber"/>'},
				style: {textAlignment:'center'},
				editable: false
			},
			{
				name:'mailAddr',
				fieldName:'mailAddr',
				width:150,
				header: {text:'<lgcom:message code="E-Mail"/>'},
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
			display: { fitStyle: 'none' }
		});
		// Context Menu Set
		grid.setContextMenu();
		return grid;
	}
	// 모화면에 Data Bind
	function addUserList(jsonData) {
		if(!_popupInfo.userData) {
			_popupInfo.userData = [];
		}
		_popupInfo.userData.push(jsonData);
	}
};

LGSYSC00040.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGSYSC00040();
		form.init();
		form.initMyForm();
	});
});
</script>
</head>

<body>
<div class="mdi-container popup">
  <section class="page-content">
	<%-- 조회영역 --%>
	<div class="searchBlock">
		<form class="form search-wrap" method="post">
			<input type="hidden" name="programId"/>
				<table class="table">
					<colgroup>
						<col width="70"/>
						<col width="130"/>
						<col width="50"/>
						<col width="130"/>
						<col width="100"/>
						<col width="120"/>
					</colgroup>
					<tbody>
						<tr>
							<th scope="col"><label><lgcom:message code="Department"/></label></th>
							<td><input type="text" name="departmentName" class="form-control input-sm" placeholder=""/></td>
							<th scope="col"><label><lgcom:message code="E-Mail"/></label></th>
							<td><input type="text" name="mailAddr" class="form-control input-sm" placeholder=""/></td>
							<th scope="col"><label><lgcom:message code="EmployeeName"/></label></th>
							<td><input type="text" name="employeeName" class="form-control input-sm" placeholder=""/></td>
						</tr>
					</tbody>
				</table>
				<button type="button" class="btn btn-lgd btn-sm btn-search" data-action="search"><lgcom:message code="search"/></button>
		</form>
	</div>
	<%-- RealGrid 영역 --%>
	<div class="content grid-wrap">
		<div class="grid userPopupGrid"></div>
	</div>
	<div class="controls modal-footer">
		<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="ok"><lgcom:message code="ok"/></button>
		<button class="btn btn-gray btn-sm" type="button" role="button" data-action="cancel"><lgcom:message code="cancel"/></button>
	</div>
	</section>
</div>
</body>
</html>
