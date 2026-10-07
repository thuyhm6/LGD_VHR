<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGSYSC00231.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 :  Responsibility별 사용자 목록을 조회하는 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<%
	request.setAttribute("env", ((System.getProperty("env") == null) ? "local":System.getProperty("env")) );
%>
<html lang="ko">
<head>
<title>Role User</title>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGSYSC00231 = function() {
	var myForm = this;
	var _popupInfo;
	/* Form Util 선언 */
	var formUtil = new FormUtil(myForm,'.container form');
	
	/* 화면 레이아웃 정의 */
	/*
	myForm.setManagedLayout({
		gridContent :{ left:10, top:0 , right:10, bottom:44 },
		gridControls:{ left:10, right:10, bottom:0 }
	});
	*/
    /* Layout Setting */
	myForm.setLayout( [ 
		{ name : "gridContent",  left : 0, right : 0, top : 0, bottom :"gridControls"  },		
		{ name : "gridControls",  left : 0, right : 0, bottom : 0 }		
    ]);		
	
	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	// 그리드 선언
	var grid = buildGrid('.superUserRoleListGrid');
	/*** OnLoad 이벤트 **/
	myForm.initMyForm = function() {
		_popupInfo = myForm.getParent().popupInfo.roleUserPopup;
		if(_popupInfo) {
			formUtil.setValue({
				responsibilityId:$.trim(_popupInfo['responsibilityId']),
				responsibilityKey:$.trim(_popupInfo['responsibilityKey']),
				responsibilityName:$.trim(_popupInfo['responsibilityName']),
				section:$.trim(_popupInfo['section'])
			});
			var param = {responsibilityKey:formUtil.getValue('responsibilityKey')};
			// 컬럼 목록을 조회한다.
			grid.loadData('lgcom','lgsysc/LGSYSC00230/retrieveResponsibilitySuperUserDetailList',param,function(data) {
				if(data.result) {
					// 조회건수가 없으면 메일 전송 못함.
					if(data.result.length == 0) {
						myForm.select("button[data-action='send']").hide();
					}
				}
			});
		}
	};
	/***  이벤트 핸들러  ***/
	// 버튼 이벤트
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch(action) {
			// E-Mail Send
			case 'send':
				Message.confirm('<lgcom:message code="question.sendMail"/>', function() {
					// 진행바 보이기
					myForm.showProgress(".superUserRoleListGrid");
					// 테스트용일 경우 testMode에 true, testMailAddr에 수신받을 메일주소를 적는다.
					var param;
					if('${env}' == 'prod') {
						param = formUtil.getValue();
						param['testMode'] = false;
						param['testMailAddr'] = '';
						param['mailSendFlag'] = 'Y';
					} else {
						param = formUtil.getValue();
						param['testMode'] = true;
						param['testMailAddr'] = 'sskeun@lgdpartner.com';
						param['mailSendFlag'] = 'Y';
					}
					transaction('lgcom','lgsysc/LGSYSC00230/saveResponsibilitySuperUserSendMailList', param, function(data) {
						Message.notify('<lgcom:message code="note.completeSentMail"/>');
						// 진행바 숨기기
						myForm.hideProgress();
						Popup.closePopup(myForm,true);
					}, function(error) {
						// 진행바 숨기기
						myForm.hideProgress();
					});
				});
				break;
			// 닫기
			case 'close':
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
		grid.setFields([
			{ fieldName: 'repKey'       },
			{ fieldName: 'repName'      },
			{ fieldName: 'userStart'    },
			{ fieldName: 'userEnd'      },
			{ fieldName: 'userName'     },
			{ fieldName: 'description'  },
			{ fieldName: 'emailAddress' }
		]);
		//컬럼 설정
		grid.setColumns([
			{
				name:'repName',
				fieldName:'repName',
				width:180,
				header: {text:'<lgcom:message code="RoleName"/>'},
				renderer: {showTooltip:true},
				editable: false
			},
			{
				name:'userStart',
				fieldName:'userStart',
				width:80,
				header: {text:'<lgcom:message code="UserStart"/>'},
				styles: {textAlignment:'center'},
				renderer: {showTooltip:true},
				editable: false
			},
			{
				name:'userEnd',
				fieldName:'userEnd',
				width:80,
				header: {text:'<lgcom:message code="UserEnd"/>'},
				styles: {textAlignment:'center'},
				renderer: {showTooltip:true},
				editable: false
			},
			{
				name:'userName',
				fieldName:'userName',
				width:100,
				header: {text:'<lgcom:message code="EmployeeNo"/>'},
				styles: {textAlignment:'center'},
				renderer: {showTooltip:true},
				editable: false
			},
			{
				name:'description',
				fieldName:'description',
				width:200,
				header: {text:'<lgcom:message code="Description"/>'},
				renderer: {showTooltip:true},
				editable: false
			},
			{
				name:'emailAddress',
				fieldName:'emailAddress',
				width:150,
				header: {text:'<lgcom:message code="E-Mail"/>'},
				renderer: {showTooltip:true},
				editable: false
			},
		]);
		//옵션 설정
		grid.setOptions({
			grid: {
				softDeleting: true,
				deleteCreated: true,
				hideDeletedRows:true,
				indicator: {visible:false},
				panel: {visible:false},
				checkBar: {visible:false},
				footer: {visible:false},
				edit: {
					insertable: false,
					appendable: false,
					updatable: false,
					deletable: false
				},
				header: {
					height: 40
				}
			},
			dataProvider: {
				insertable: false,
				updatable: false,
				deletable: false,
				softDeleting: false,
				deleteCreated: false
			},
			display: { fitStyle: 'evenFill' }
		});
		// Context Menu Set
		grid.setContextMenu();
		return grid;
	}
}

LGSYSC00231.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGSYSC00231();
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
		<h2>Responsibility User List</h2>
	</div>
	<div class="gridContent grid-wrap">
		<div class="grid superUserRoleListGrid"></div>
	</div>
	<div class="gridControls modal-footer">
		<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="send"><lgcom:message code="SendMail"/></button>
		<button class="btn btn-gray btn-sm" type="button" role="button" data-action="close"><lgcom:message code="Close"/></button>
	</div>
	<form method="post" action="">
		<input type="hidden" name="responsibilityId" value=""/>
		<input type="hidden" name="responsibilityKey" value=""/>
		<input type="hidden" name="responsibilityName" value=""/>
		<input type="hidden" name="section" value=""/>
	</form>
	</section>
</div>
</body>
</html>
