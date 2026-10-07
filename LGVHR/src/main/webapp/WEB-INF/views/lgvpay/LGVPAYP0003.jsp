<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
	파일명 : LGVPAYP0003.jsp
	프로젝트명 : LGDisplay LGVHR Project

	Copyright(c) 2017 LG CNS, All rights reserved.

	설 명 : 본 화면은 Payroll Item 목록을 조회하는 팝업 화면입니다.
	작성자 : bakderia
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVPAYP0003 = function() {
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
	var grid = buildGrid('.payrollItemPopupGrid');

	// 화면 Open시
	myForm.initMyForm = function() {
		_popupInfo = myForm.getParent().popupInfo.payrollItemPopup;
		if(_popupInfo['payrollItemData']) {
			delete _popupInfo['payrollItemData'];
		}

		// 검색어가 주어지면 값을 세팅하고 조회한다.
		var isSearch = false;
		if($.trim(_popupInfo['payrollCalcPeriodValue']) != '') {
			var splitVal = _popupInfo['payrollCalcPeriodValue'].split("/");
			formUtil.setValue({payrollCalcPeriodValue:splitVal[1]+splitVal[0]});
			//isSearch = true;
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
				grid.loadData('lgvhr','lgvpay/LGVPAYP0003/retrievePayrollItemList',param,function(data) {

				});
				break;
			case 'ok':
				var bgrid = grid.getGridBase();
				var current = bgrid.getCurrent();
				if (current == undefined ) { return; }
				addValueList(bgrid.getValues(current.itemIndex));
				
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
	/* Cell Double Click 하면 자동 선택 */
	grid.getGridBase().onDataCellDblClicked = function(cgrid, index) {
	var current = cgrid.getCurrent();
	if (current == undefined ) { return; }
	addValueList(cgrid.getValues(current.itemIndex));
	Popup.closePopup(myForm,true);
	};
	/*** 내부 함수 ***/
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		// Grid Field Set
		grid.setFields([
		    { fieldName:'payrollItemId'    	, dataType:'text'  },
			{ fieldName:'inquiryName'  		, dataType:'text'  },
			{ fieldName:'payrollApplyFlag'  , dataType:'text'  },
			{ fieldName:'commonCodeName'   	, dataType:'text'  }
		]);
		// Grid Column Set
		grid.setColumns([
			{
				name:'payrollItemId',
				fieldName:'payrollItemId',
				width:0,
				header: {text:''},
				styles: {textAlignment:'near'},
				editable: false
			},
			{
				name:'inquiryName',
				fieldName:'inquiryName',
				width:300,
				header: {text:'<lgcom:message code="label.pay.payrollItem"/>'},
				styles: {textAlignment:'near'},
				editable: false
			},
			{
				name:'commonCodeName',
				fieldName:'commonCodeName',
				width:300,
				header: {text:'<lgcom:message code="label.pay.payrollClassType"/>'},
				styles: {textAlignment:'near'},
				editable: false
			},
			{
				name:'payrollApplyFlag',
				fieldName:'payrollApplyFlag',
				width:100,
				header: {text:'<lgcom:message code="label.pay.recurringYn"/>'},
				styles: {textAlignment:'center'},
				editable: false
			}
		]);
		// Grid Option Set
		grid.setOptions({
				grid: {
					softDeleting: false,
					deleteCreated: false,
					hideDeletedRows: false,
					indicator: {visible: false},
					panel: {visible: false},
					checkBar: {visible: false},
					stateBar: {visible: false},
					footer: {visible: false},
					sortMode: "explicit",
					edit: {
						insertable: false,
						appendable: false,
						updatable: false,
						deletable: false
					}
				},
				dataProvider: {
					insertable: false,
					updatable: false,
					deletable: false,
					softDeleting: false,
					deleteCreated: false
				},
				display: { fitStyle: 'none' }
			});
		// Context Menu Set
		grid.setContextMenu();
		return grid;
	}
	// 모화면에 Data Bind
	function addValueList(jsonData) {
		if(!_popupInfo.payrollItemData) {
			_popupInfo.payrollItemData = [];
		}
		_popupInfo.payrollItemData.push(jsonData);
	}
};

LGVPAYP0003.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGVPAYP0003();
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
			<input type="hidden" name="payrollCalcPeriodValue"/>
				<table class="table">
					<colgroup>
						<col width="100"/>
						<col width="200"/>
						<col width="120"/>
					</colgroup>
					<tbody>
						<tr>
							<th scope="col"><label><lgcom:message code="label.pay.payrollItem"/></label></th>
							<td><input type="text" name="inquiryName" class="form-control input-sm" placeholder=""/></td>
						</tr>
					</tbody>
				</table>
				<button type="button" class="btn btn-lgd btn-sm btn-search" data-action="search"><lgcom:message code="search"/></button>
		</form>
	</div>
	<%-- RealGrid 영역 --%>
	<div class="content grid-wrap">
		<div class="grid payrollItemPopupGrid"></div>
	</div>
	<div class="controls modal-footer">
		<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="ok"><lgcom:message code="ok"/></button>
		<button class="btn btn-gray btn-sm" type="button" role="button" data-action="cancel"><lgcom:message code="cancel"/></button>
	</div>
	</section>
</div>
</body>
</html>
