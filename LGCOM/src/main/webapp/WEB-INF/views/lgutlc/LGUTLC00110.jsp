<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGUTLC00110.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2016 LG CNS,  All rights reserved.

    설 명 : 본 화면은 Keyword Logging을 조회하는 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Keyword Logging</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGUTLC00110 = function() {
	var myForm = this;
	// 조회조건 Combo 초기화
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	/* 팝업용 변수 선언 */
	myForm.popupInfo = { userMultiPopup: {} };

    /* Layout Setting */
	myForm.setLayout( [ 
		{ name : "searchBlock",  left : 0, right : 0, top : 0 },		
		{ name : "gridContent",  left : 0, right : 0, top : "searchBlock", bottom : 0 }		
    ]);	
    
	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	// 그리드 선언
	var grid = buildGrid('.checkerGrid');
	/*** 화면 초기 처리 ***/
	myForm.initForm = function() {
		var isAdmin = false;
		$.each(USER_ROLE_LIST,function(idx) {
			if(this.systemCode == 'LGCOM' && this.moduleCode == 'LGSYSC' && this.roleCode == 'BIZWEB_SYSTEM_ADMINISTRATOR') {
				isAdmin = true;
				return false;
			}
		});
		// 사용자 정보 세팅
		formUtil.setValue({
			userId: $.trim(SESSION_USER.applicationUserId),
			employeeName: $.trim(SESSION_USER.fullNameLocal)
		});
		// 사용자 고정
		if(!isAdmin) {
			myForm.select(".searchBlock form input[name='employeeName']").prop('disabled',true);
			myForm.select(".searchBlock form button.btn[data-action='popup']").prop('disabled',true);
		}
	};
	/*** 이벤트 핸들러  ***/
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		// 조회
		if(action == 'search') {
			grid.getGridBase().cancel();
			var param = formUtil.getValue();
			grid.loadData('lgcom','lgutlc/LGUTLC00110/retrieveKeywordLogList', param);
		}
	});
	// 검색 버튼 이벤트
	myForm.addEvent('click',".searchBlock button[data-action='popup']",function(event) {
		var type = $(event.target).data('type');
		if(!type) {
			type = $(event.target).closest('button[data-action]').data('type');
		}
		switch(type) {
			case 'user':
				// 팝업에 사용될 Argument 객체 선언
				var _popup = myForm.popupInfo.userMultiPopup;
				// 기존 선택된 사용자 ID를 넘긴다.
				_popup['keyType'] = 'applicationUserId';		// applicationUserId 또는 userName(사번)
				_popup['keyValue'] = $.trim(formUtil.getValue('userId'));
				// 팝업을 호출한다.
				var popup = new Popup(myForm,'lgcom','M_LGSYSC_1150','<lgcom:message code="UserMultiSearch"/>');
				popup.setSize(1000,528);
				// 기존 입력값 초기화
				//formUtil.setValue({userId:'',employeeName:''});
				popup.open(function() {
					if(_popup['userList']) {
						if(_popup['userList'].length == 1) {
							formUtil.setValue({employeeName:$.trim(_popup['userList'][0]['employeeName']),userId:$.trim(_popup['userList'][0]['userId'])});
						}
						else if(_popup['userList'].length > 1) {
							var dispName;
							var empName = [];
							var uId = [];
							for(var i=0; i < _popup['userList'].length; i++) {
								empName.push(_popup['userList'][i]['employeeName']);
								uId.push(_popup['userList'][i]['userId']);
							}
							dispName = _popup['userList'].length + ' rows selected.';
							//formUtil.setValue({employeeName:$.trim(empName.join(',')),userId:$.trim(uId.join(','))});
							formUtil.setValue({employeeName:dispName,userId:$.trim(uId.join(','))});
						}
					}
				});
				break;
		}
		event.stopPropagation();
	});
	// 사용자명 지워지면 사용자 ID 제거
	myForm.addEvent('change',".searchBlock input[name='employeeName']",function(event) {
		// 팝업에 사용될 Argument 객체 선언
		var _popup = myForm.popupInfo.userMultiPopup;
		// 기존 선택된 사용자 ID를 넘긴다.
		_popup['keyType'] = 'applicationUserId';		// applicationUserId 또는 userName(사번)
		_popup['keyValue'] = $.trim(formUtil.getValue('userId'));
		// 팝업을 호출한다.
		var popup = new Popup(myForm,'lgcom','M_LGSYSC_1150','<lgcom:message code="UserMultiSearch"/>');
		popup.setSize(1000,528);
		// 기존 입력값 초기화
		//formUtil.setValue({userId:'',employeeName:''});
		popup.open(function() {
			if(_popup['userList']) {
				if(_popup['userList'].length == 1) {
					formUtil.setValue({employeeName:$.trim(_popup['userList'][0]['employeeName']),userId:$.trim(_popup['userList'][0]['userId'])});
				}
				else if(_popup['userList'].length > 1) {
					var dispName;
					var empName = [];
					var uId = [];
					for(var i=0; i < _popup['userList'].length; i++) {
						empName.push(_popup['userList'][i]['employeeName']);
						uId.push(_popup['userList'][i]['userId']);
					}
					dispName = _popup['userList'].length + ' rows selected.';
					//formUtil.setValue({employeeName:$.trim(empName.join(',')),userId:$.trim(uId.join(','))});
					formUtil.setValue({employeeName:dispName,userId:$.trim(uId.join(','))});
				}
			}
		});
	});
	/*** 내부 함수  ***/
	//그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		//컬럼 설정
		grid.setFields([
			{ fieldName: 'applicationUserId'    , dataType: 'number' },
			{ fieldName: 'employeeName'         , dataType: 'text'   },
			{ fieldName: 'logSeqNo'             , dataType: 'number' },
			{ fieldName: 'inquiryConditionValue', dataType: 'text'   },
			{ fieldName: 'columnContent'        , dataType: 'text'   },
			{ fieldName: 'effectiveToDate'      , dataType: 'text'   }
		]);
		// Grid Column 세팅
		grid.setColumns([
			{
				name:'employeeName',
				fieldName:'employeeName',
				width:100,
				header: {text:'<lgcom:message code="EmployeeName"/>'},
				renderer: {showTooltip:true},
				editable: false
			},
			{
				name:'inquiryConditionValue',
				fieldName:'inquiryConditionValue',
				width:200,
				header: {text:'<lgcom:message code="keyword"/>'},
				renderer: {showTooltip:true},
				editable: false
			},
			{
				name:'columnContent',
				fieldName:'columnContent',
				width:350,
				header: {text:'<lgcom:message code="Value"/>'},
				renderer: {showTooltip:true},
				editable: false
			},
			{
				name:'effectiveToDate',
				fieldName:'effectiveToDate',
				width:100,
				header: {text:'<lgcom:message code="EffectEndDate"/>'},
				styles: {textAlignment:'center'},
				editable: false
			}
		]);
		//옵션 설정
		grid.setOptions({
			grid: {
				softDeleting: true,
				deleteCreated: true,
				hideDeletedRows:false,
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
				},
				header: {height:34}
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
		//마우스 오른쪽 클릭시 메뉴
		grid.setContextMenu();
		return grid;
	}
};

LGUTLC00110.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGUTLC00110();
		form.init();
		form.initForm();
	});
});
</script>
</head>
<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Keyword Logging</h2>
	</div>
	<div class="searchBlock">
		<form class="form search-wrap">
				<table class="table">
					<colgroup>
						<col width="100" />
						<col width="100" />
						<col width="80"  />
						<col width="100" />
						<col width="80"  />
						<col width="100" />
					</colgroup>
					<tbody>
						<tr>
							<th scope="col"><label><i class="asterisk">*</i><lgcom:message code="EmployeeName"/></label></th>
							<td>
								<div class="input-group input-group-sm input-search input-require"">
									<input type="text" name="employeeName" class="form-control required" data-action="change" data-type="user" placeholder=""/>
									<span class="input-group-btn">
										<button class="btn btn-default ico-lgd find" type="button" data-action="popup" data-type="user">
											<span class="fa fa-search" aria-hidden="true"></span>
										</button>
									</span>
								</div>
								<input type="hidden" name="userId"/>
							</td>
							<th scope="col"><label><lgcom:message code="keyword"/></label></th>
							<td><input type="text" name="keyword" class="form-control input-sm"/></td>
							<th scope="col"><label><lgcom:message code="Value"/></label></th>
							<td><input type="text" name="keyvalue" class="form-control input-sm"/></td>
						</tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search" ><lgcom:message code="search" /></button>
		</form>
	</div>
	<div class="gridContent grid-wrap">
		<div class="grid checkerGrid"></div>
	</div>
	</section>
</div>
</body>
</html>
