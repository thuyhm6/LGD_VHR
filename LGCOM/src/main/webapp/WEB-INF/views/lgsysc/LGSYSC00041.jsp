<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
	파일명 : LGSYSC00041.jsp
	프로젝트명 : LGD WCFW

	Copyright(c) 2017 LG CNS, All rights reserved.

	설 명 : 본 화면은 User 목록을 조회하는 팝업 화면입니다.
	작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<style>
.popup {
	padding:10px;
}
.shuttlebtn .btnwrapper {
	padding-top:100px;
	text-align:center;
}
.shuttlebtn .btnwrapper .wrapper {
	margin-bottom:10px;
}
.shuttlebtn .btnwrapper .stlbtn {
	width: 60px;
	height: 28px;
	border: 1px solid #d2d2d2;
	background-color: #fff;
	text-align: center;
	vertical-align: middle;
	box-shadow: none;
	padding-top:4px;
}
</style>
<script type="text/javascript">
var LGSYSC00041 = function() {
	var myForm = this;
	var _popupInfo;
	// Form util 선언
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	/* 화면 레이아웃 정의 */
	/*
	myForm.setManagedLayout({
		searchBlock: { line : 1, left:10 , right:10 },
		content1   : { line : 2, left:10 , width:520, bottom:28 },
		shuttlebtn : { line : 2, left:530, width:80 , bottom:28 },
		content2   : { line : 2, left:610, right:10, bottom:28 },
		controls   : { left:10 , right:10, bottom:0 }
	});
	*/
	//팝업으로서의 이 화면은 여러 화면에서 사용하는 것으로, 팝업 윈도우의 크기를 아래와 같이 고정하였다.
	myForm.select(".searchBlock").parents("._div_popup_holder_").css({"width": "1000px", "height":"494px"});

	/* Layout Setting */
	myForm.setLayout( [ 
		{ name  : "searchBlock",   left : 0, right : 0, top : 0 },		
		{ name  : "content1", left : 0, right : 0, top : "searchBlock", width : 520, bottom : "controls" },
		{ name  : "shuttlebtn", left : "content1", right : 0, top : "searchBlock", width : 80, bottom : "controls" },	 	
		{ name  : "content2",  left : "shuttlebtn", right : 0, top : "searchBlock", bottom : "controls"},
	 	{ name  : "controls",  left : 0, right : 0, bottom : 0  }	 //top 적으면 에러	
	]); 	
	// 그리드 초기화
	var grid1 = buildGrid('.userPopupGrid');
	var grid2 = buildGrid('.userSelectGrid');
	
	// 화면 Open시
	myForm.initMyForm = function() {
		// Popup 정보 받기
		_popupInfo = myForm.getParent().popupInfo.userMultiPopup;
		if($.trim(_popupInfo['keyValue'].replace(/[\,]/g,'')) != '') {
			// 기선택 조회를 수행한다.
			var param = {
				keyType: _popupInfo['keyType'],
				keyValue: _popupInfo['keyValue']
			};
			grid2.loadData('lgcom','lgsysc/LGSYSC00040/retrievePreSelectedUserPopupList',param);
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
				grid1.loadData('lgcom','lgsysc/LGSYSC00040/retrieveUserPopupList',param,function(data) {
					// 결과가 1건이면 자동선택후 종료한다.
					if(data.result.length == 1) {
						var lgrid = grid1.getGridBase();
						var rgrid = grid2.getGridBase();
						// 중복되지 않으면
						if(!checkRightDuplication(lgrid.getValue(0,'userId'))) {
							rgrid.getDataProvider().addRow(lgrid.getDataProvider().getJsonRow(0));
							lgrid.getDataProvider().removeRow(0);
							lgrid.getDataProvider().clearRowStates(true);
							rgrid.getDataProvider().clearRowStates(true);
							//myForm.select(".controls button[data-action='ok']").trigger('click');
						} else {
							lgrid.getDataProvider().removeRow(0);
							lgrid.getDataProvider().clearRowStates(true);
							rgrid.getDataProvider().clearRowStates(true);
						}
					}
				});
				break;
			case 'right':
				var lgrid = grid1.getGridBase();
				var lprov = grid1.getDataProvider();
				var rgrid = grid2.getGridBase();
				var rprov = grid2.getDataProvider();
				var checkedIndex = lgrid.getCheckedRows(true,true);
				if(lgrid.getItemCount() == 0) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				}
				if(checkedIndex.length == 0) {
					Message.alert('<lgcom:message code="note.nocheckdata"/>');
					return;
				}
				for(var i=0; i < checkedIndex.length; i++) {
					// 중복체크후 중복이 되면 추가하지 않는다.
					if(checkRightDuplication(lprov.getValue(checkedIndex[i],'userId'))) {
						lprov.removeRow(checkedIndex[i]);
						continue;
					}
					rprov.addRow(lprov.getJsonRow(checkedIndex[i]));
					lprov.removeRow(checkedIndex[i]);
				}
				lprov.clearRowStates(true);
				rprov.clearRowStates(true);
				break;
			case 'left':
				var lgrid = grid1.getGridBase();
				var lprov = grid1.getDataProvider();
				var rgrid = grid2.getGridBase();
				var rprov = grid2.getDataProvider();
				var checkedIndex = rgrid.getCheckedRows(true,true);
				if(rgrid.getItemCount() == 0) return;
				if(checkedIndex.length == 0) return;
				for(var i=0; i < checkedIndex.length; i++) {
					// 중복체크후 중복이 되면 추가하지 않는다.
					if(checkLeftDuplication(rprov.getValue(checkedIndex[i],'userId'))) {
						rprov.removeRow(checkedIndex[i]);
						continue;
					}
					lprov.insertRow(0,rprov.getJsonRow(checkedIndex[i]));
					rprov.removeRow(checkedIndex[i]);
				}
				lprov.clearRowStates(true);
				rprov.clearRowStates(true);
				break;
			case 'ok':
				var cgrid = grid2.getGridBase();
				if(cgrid.getItemCount() == 0) {
					Message.alert('<lgcom:message code="note.nocheckdata"/>');
					return;
				}
				_popupInfo['userList'] = [];
				for(var i=0; i < cgrid.getItemCount(); i++) {
					_popupInfo['userList'].push(cgrid.getValues(i));
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
	/*** 내부 함수 ***/
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		switch(gridId) {
			case '.userPopupGrid':
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
						renderer: {showTooltip:true},
						editable: false
					},
					{
						name:'departmentName',
						fieldName:'departmentName',
						width:150,
						header: {text:'<lgcom:message code="Department"/>'},
						renderer: {showTooltip:true},
						editable: false
					},
					{
						name:'mailAddr',
						fieldName:'mailAddr',
						width:150,
						header: {text:'<lgcom:message code="E-Mail"/>'},
						renderer: {showTooltip:true},
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
					display: { fitStyle: 'evenFill' }
				});
				break;
			case '.userSelectGrid':
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
						name:'departmentName',
						fieldName:'departmentName',
						width:150,
						header: {text:'<lgcom:message code="Department"/>'},
						editable: false
					},
					{
						name:'mailAddr',
						fieldName:'mailAddr',
						width:200,
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
					display: { fitStyle: 'evenFill' }
				});
				break;
		}
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
	// 중복체크
	function checkLeftDuplication(userId) {
		var grid = grid1.getGridBase();
		for(var i=0; i < grid.getItemCount(); i++) {
			// 동일한 사용자가 이미 존재하면
			if($.trim(userId) == $.trim(grid.getValue(i,'userId'))) {
				return true;
			}
		}
		return false;
	}
	// 중복체크
	function checkRightDuplication(userId) {
		var grid = grid2.getGridBase();
		for(var i=0; i < grid.getItemCount(); i++) {
			// 동일한 사용자가 이미 존재하면
			if($.trim(userId) == $.trim(grid.getValue(i,'userId'))) {
				return true;
			}
		}
		return false;
	}
};

LGSYSC00041.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGSYSC00041();
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
				<table class="table">
					<colgroup>
						<col width="70"/>
						<col width="200"/>
						<col width="100"/>
						<col width="150"/>
					</colgroup>
					<tbody>
						<tr>
							<th scope="col"><label><lgcom:message code="Department"/></label></th>
							<td><input type="text" name="departmentName" class="form-control input-sm" placeholder=""/></td>
							<th scope="col"><label><lgcom:message code="EmployeeName"/></label></th>
							<td><input type="text" name="employeeName" class="form-control input-sm" placeholder=""/></td>
						</tr>
					</tbody>
				</table>
			<button type="button" class="btn btn-lgd btn-sm btn-search" data-action="search"><lgcom:message code="search"/></button>
		</form>
	</div>
	<%-- RealGrid 영역 --%>
	<div class="content1 grid-wrap">
		<div class="grid userPopupGrid"></div>
	</div>
	
	<div class="shuttlebtn">
		<div class="btnwrapper">
			<div class="wrapper">
				<button class="stlbtn" type="button" role="button" data-action="right"><span class="ico ico-shuttle-right"></span></button>
			</div>
			<div class="wrapper">
				<button class="stlbtn" type="button" role="button" data-action="left"><span class="ico ico-shuttle-left"></span></button>
			</div>
		</div>
	</div>
	
	<div class="content2 grid-wrap">
		<div class="grid userSelectGrid"></div>
	</div>
	
	<div class="controls modal-footer">
		<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="ok"><lgcom:message code="ok"/></button>
		<button class="btn btn-gray btn-sm" type="button" role="button" data-action="cancel"><lgcom:message code="cancel"/></button>
	</div>
	</section>
</div>
</body>
</html>
