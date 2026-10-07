<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
	파일명 : LGVPAYP0001.jsp
	프로젝트명 : LGDisplay LGVHR Project

	Copyright(c) 2017 LG CNS, All rights reserved.

	설 명 : 본 화면은 급여대상자 SET 목록을 조회하는 팝업 화면입니다.
	작성자 : bakderia
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVPAYP0001 = function() {
	var myForm = this;
	var searchMode = 'multi';
	var srchForm = '.searchBlock form';
	var _popupInfo;
	
	// Form util 선언
	var formUtil = new FormUtil(myForm, srchForm);

	//필수항목 체크
   	var validator = new Validator( myForm, srchForm);
	
   	validator.setRule( {
    	option: {placement: 'right'},
	    rules: {
	    	calculationSetName: {required:true}
	    },
	    messages: {
	    	calculationSetName: {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='calculationSetName'/>" />'}
	    }
    });
   	
	var code = new CommonCode('lgcom');
	code.add('payrollType', {codeTypeCode:'LGVHR_PAY_RUN_TYPE'});
	code.add('resignationFlag', {codeTypeCode:'LGDVHR_PAY_RESIGNATION_FLAG'});
	code.execute();
	
	//combo setting
	formUtil.initCombo('payrollType',code.get('payrollType'),{selectAll: true});
	formUtil.initCombo('resignationFlag',code.get('resignationFlag'),{selectAll: true});
	
	//팝업으로서의 이 화면은 여러 화면에서 사용하는 것으로, 팝업 윈도우의 크기를 아래와 같이 고정하였다.
	myForm.select(".searchBlock").parents("._div_popup_holder_").css({"width": "812px", "height":"494px"});
	
    /* Layout Setting */
	myForm.setLayout( [ 
		{ name  : "searchBlock", left : 0, right : 0, top : 0 },		
		{ name  : "content", left : 0, right : 0, top : "searchBlock", bottom : "controls"},
		{ name  : "controls", left : 0, right : 0, bottom : 0 }	 	
	]);
	// 그리드 초기화
	var grid = buildGrid('.calculationPopupGrid');

	// 화면 Open시
	myForm.initMyForm = function() {
		_popupInfo = myForm.getParent().popupInfo.calculationPopup;
		if(_popupInfo['calculationData']) {
			delete _popupInfo['calculationData'];
		}

		// 검색어가 주어지면 값을 세팅하고 조회한다.
		var isSearch = false;
		if($.trim(_popupInfo['calculationSetName']) != '') {
			formUtil.setValue({calculationSetName:_popupInfo['calculationSetName']});
			isSearch = true;
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
				if(validator.isValid()) {
					grid.loadData("lgvhr", "lgvpay/LGVPAYP0001/retrieveCalculationSetList", param, function(data) {
						if( grid.getRowCount() == 0 ) {
							Message.alert('<lgcom:message code="note.nodata"/>');
							return;
						};
					});
				}else{
					myForm.select(".searchBlock form input[name='calculationSetName']").focus();
				}

				break;
			case 'ok':
				var bgrid = grid.getGridBase();
				var current = bgrid.getCurrent();
				if (current == undefined ) { return; }
				addUserList(bgrid.getValues(current.itemIndex));
				
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
	addUserList(cgrid.getValues(current.itemIndex));
	Popup.closePopup(myForm,true);
	};
	/*** 내부 함수 ***/
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		// Grid Field Set
		grid.setFields([
		    { fieldName:'calculationSetId'    , dataType:'text'  },
			{ fieldName:'calculationSetName'    , dataType:'text'  },
			{ fieldName:'payrollType'      		, dataType:'text'  },
			{ fieldName:'resignationFlag'	    , dataType:'text'  },
			{ fieldName:'employeeCount'    		, dataType:'text'  }
		]);
		// Grid Column Set
		grid.setColumns([
			{
				name:'calculationSetId',
				fieldName:'calculationSetId',
				width:0,
				header: {text:'<lgcom:message code="label.pay.calculationSetId"/>'},
				styles: {textAlignment:'near'},
				editable: false
			},
			{
				name:'calculationSetName',
				fieldName:'calculationSetName',
				width:250,
				header: {text:'<lgcom:message code="label.pay.calculationSetName"/>'},
				styles: {textAlignment:'near'},
				editable: false
			},
			{
				name:'payrollType',
				fieldName:'payrollType',
				width:150,
				header: {text:'<lgcom:message code="label.pay.payType"/>'},
				styles: {textAlignment:'near'},
				editable: false
			},
			{
				name:'resignationFlag',
				fieldName:'resignationFlag',
				width:150,
				header: {text:'<lgcom:message code="label.pay.resignationFlag"/>'},
				styles: {textAlignment:'center'},
				editable: false
			},
			{
				name:'employeeCount',
				fieldName:'employeeCount',
				width:200,
				header: {text:'<lgcom:message code="label.pay.employeeCount"/>'},
				styles: {textAlignment:'far'},
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
	function addUserList(jsonData) {
		if(!_popupInfo.calculationData) {
			_popupInfo.calculationData = [];
		}
		_popupInfo.calculationData.push(jsonData);
	}
};

LGVPAYP0001.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGVPAYP0001();
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
			<input type="hidden" name="attDate"/>
			<input type="hidden" name="orgId"/>
				<table class="table">
					<colgroup>
						<col width="190"/>
						<col width="150"/>
						<col width="140"/>
						<col width="100"/>
					</colgroup>
					<tbody>
						<tr>
							<th><i class="asterisk">*</i><label class="required" keyword><lgcom:message code="label.pay.calculationSetName"/></label></th>
							<td><input type="text" name="calculationSetName" class="form-control input-sm" placeholder=""/></td>
							<th><label class="required"><lgcom:message code="label.pay.resignationFlag"/></label></th>
		                    <td>
		                        <div class="form-inline ">
                                <select class="form-control input-sm input-require" name="resignationFlag" id="resignationFlag"></select>
                            	</div>
		                    </td>
						</tr>
						<tr>
							<th><label class="required"><lgcom:message code="label.pay.payType"/></label></th>
		                    <td>
		                        <div class="form-inline ">
                                <select class="form-control input-sm input-require" name="payrollType" id="payrollType"></select>
                            	</div>
		                    </td><td></td>
						</tr>
					</tbody>
				</table>
				<button type="button" class="btn btn-lgd btn-sm btn-search" data-action="search"><lgcom:message code="search"/></button>
		</form>
	</div>
	<%-- RealGrid 영역 --%>
	<div class="content grid-wrap">
		<div class="grid calculationPopupGrid"></div>
	</div>
	<div class="controls modal-footer">
		<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="ok"><lgcom:message code="ok"/></button>
		<button class="btn btn-gray btn-sm" type="button" role="button" data-action="cancel"><lgcom:message code="cancel"/></button>
	</div>
	</section>
</div>
</body>
</html>
