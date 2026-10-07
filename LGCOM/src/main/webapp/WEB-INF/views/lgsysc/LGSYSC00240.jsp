<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGSYSC00240.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 결재시에 검토자를 지정하는 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<style type="text/css">
.LGSYSC00240 .reviewerListGrid {min-height:100px;}
.LGSYSC00240 .commentBox {width:100%;height:50px;}
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGSYSC00240 = function() {
	var myForm = this;
	/* 모화면에서 받은 변수 */
	var _popupInfo;
	/* 팝업용 변수 선언 */
	myForm.popupInfo = { userPopup: {} };
	// Form util 선언
	var formUtil = new FormUtil(myForm,'.dataBlock form.commentForm');

	//팝업으로서의 이 화면은 여러 화면에서 사용하는 것으로, 팝업 윈도우의 크기를 아래와 같이 고정하였다.
	myForm.select(".LGSYSC00240").parents("._div_popup_holder_").css({"width": "700px", "height":"420px"});
	
	/* 화면 레이아웃 정의 */
	/*
	myForm.setManagedLayout({
		gridControls: { left:10, top:0, right:10 },
		gridContent : { left:10, top:28, right:10, bottom:88 },
		dataBlock   : { left:10, right:10, bottom:28 },
		controls    : { left:10, right:10, bottom:0 }
	});
	*/
    /* Layout Setting */
	myForm.setLayout( [ 
		{ name  : "gridControls", left : 0, right : 0, top : 0 },		
		{ name  : "gridContent", left : 0, right : 0, top : "gridControls", bottom : "dataBlocks"},
		{ name  : "dataBlock", left : 0, right : 0, top : "gridContent", bottom : "controls"},
		{ name  : "controls", left : 0, right : 0, bottom : 0 }	 	
	]);
	
	
	// 조회조건 Combo 초기화
	var code = new CommonCode('lgcom');
	code.execute('useFlag',{codeTypeCode:'LGCOM_YN_FLAG'});
	// Comment 입력 유효성 체크
	var validator = new Validator(myForm,".commentForm",{
		rules : {commentBox: {required:true, maxlength:2000}},
		messages : {commentBox: {maxlength:'<lgcom:message code="error.maxlength" arguments="1000,3000"/>'}},
		tooltip_options:{placement:'top'}
	});
	// 그리드 선언
	var grid = buildGrid('.reviewerListGrid');
	// 화면 Open시
	myForm.initForm = function() {
		// Popup 정보 받기
		_popupInfo = myForm.getParent().popupInfo.reviewerPopup;
		formUtil.setValue({
			requestId: $.trim(_popupInfo['requestId']),
			orgId: $.trim(_popupInfo['orgId']),
			requestCode: $.trim(_popupInfo['requestCode'])
		});
	}
	/***  이벤트 핸들러  ***/
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ) {
			// 검토자 추가
			case 'add':
				var cgrid = grid.getGridBase();
				// 팝업에 사용될 Argument 객체 선언
				var _popup = myForm.popupInfo.userPopup;
				// 팝업 조회용
				_popup['searchMode'] = 'single';
				_popup['departmentName'] = '';
				_popup['mailAddr'] = '';
				_popup['employeeNo'] = '';
				_popup['employeeName'] = '';
				_popup['employeeName'] = '';
				// 팝업을 호출한다.
				var popup = new Popup(myForm,'lgcom','M_LGUTLC_1142','<lgcom:message code="UserSearch"/>');
				popup.setSize(800,494);	// searchMode 'Single'
				popup.open(function() {
					if(_popup.userData) {
						$(_popup.userData).each(function() {
							// 사용자 상세정보 조합
							var userInfo = '';
							// 부서
							userInfo += $.trim(this['departmentName']);
							// 직위
							if($.trim(this['positionName']) != '') {
								userInfo += ' / ';
								userInfo += $.trim(this['positionName']);
							} else {
								userInfo += ' / ';
								userInfo += $.trim(this['titleName']);
							}
							// 사무실 전화번호
							userInfo += ' / ';
							userInfo += $.trim(this['officePhoneNumber']);
							// 휴대폰번호
							userInfo += ' / ';
							userInfo += $.trim(this['mobilePhoneNumber']);
							if(cgrid.getCurrent().itemIndex < 0) {
								cgrid.beginAppendRow();
							} else {
								cgrid.beginInsertRow(cgrid.getCurrent().itemIndex);
							}
							cgrid.setValue(cgrid.getCurrent().itemIndex,'requestMasterId',$.trim(formUtil.getValue('requestId')));
							cgrid.setValue(cgrid.getCurrent().itemIndex,'requestCode',$.trim(formUtil.getValue('requestCode')));
							cgrid.setValue(cgrid.getCurrent().itemIndex,'orgId',$.trim(formUtil.getValue('orgId')));
							cgrid.setValue(cgrid.getCurrent().itemIndex,'applicationUserId',$.trim(this['userId']));
							cgrid.setValue(cgrid.getCurrent().itemIndex,'employeeNo',$.trim(this['employeeNo']));
							cgrid.setValue(cgrid.getCurrent().itemIndex,'employeeName',$.trim(this['employeeName']));
							cgrid.setValue(cgrid.getCurrent().itemIndex,'employeeInfo',userInfo);
							cgrid.setValue(cgrid.getCurrent().itemIndex,'useFlag','N');
						});
					}
					try {
						cgrid.commit();
					} catch(e) {
						Message.alert(e.message);
						return;
					}
					myForm.popupInfo.userPopup = {};
				});
				break;
			// 검토자 삭제
			case 'del':
				grid.removeCheckedRows();
				break;
			// 검토자 지정 완료
			case 'save':
				if(grid.getGridBase().getItemCount() == 0) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				}
				if(!validator.isValid()) return;
				try {
					grid.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
				}
				Message.confirm('<lgcom:message code="question.designReviewer"/>', function() {
					var param = {
						dataRow: grid.getChangedRows(),
						comment: $.trim(formUtil.getValue('previewComment'))
					};
					transaction('lgcom','lgsysc/LGSYSC00240/insertRequestReviewers',param,function(data) {
						Message.notify('<lgcom:message code="note.completed"/>');
						Popup.closePopup(myForm,true);
					});
				});
				break;
			// 검토자 지정 취소
			case 'cancel':
				Popup.closePopup(myForm);
				break;
		}
	});
	/***  내부 함수  ***/
	// 그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId, {
			gridType: 'normal',
			statusBar: 'N',
			gridControl: false,
			fitToRowCount: false
		});
		grid.setPagingMode(true);
		// Grid Field Set
		grid.setFields([
			{fieldName:'requestMasterId'  , dataType:'number'},
			{fieldName:'orgId'            , dataType:'text'  },
			{fieldName:'requestCode'      , dataType:'text'  },
			{fieldName:'applicationUserId', dataType:'text'  },
			{fieldName:'employeeNo'       , dataType:'text'  },
			{fieldName:'employeeName'     , dataType:'text'  },
			{fieldName:'employeeInfo'     , dataType:'text'  },
			{fieldName:'useFlag'          , dataType:'text'  }
		]);
		grid.setLookups('useflag',code.get('useFlag'));
		// Grid Column Set
		grid.setColumns([
			{
				name:'employeeName',
				fieldName:'employeeName',
				width:150,
				header: {text:'<lgcom:message code="Name01"/>'},
				editable: false
			},
			{
				name:'employeeInfo',
				fieldName:'employeeInfo',
				width:350,
				header: {text:'<lgcom:message code="Detail02"/>'},
				editable: false
			},
			{
				name:'useFlag',
				fieldName:'useFlag',
				width:80,
				header: {text:'<lgcom:message code="OpenFlag01"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'useflag',
				lookupKeyFields: ['useFlag'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			}
		]);
		grid.setOptions({
			grid: {
				hideDeletedRows: true,
				indicator: {visible:false},
				panel: {visible:false},
				stateBar: {visible:false},
				checkBar: {visible:true},
				footer: {visible:false},
				edit: {
					insertable: true,
					appendable: true,
					updatable: true,
					deletable: true
				}
			},
			dataProvider: {
				insertable: true,
				updatable: true,
				deletable: true,
				deleteCreated: true
			},
			display: { fitStyle: 'evenFill' }
		});
		// Context Menu Set
		grid.setContextMenu();
		return grid;
	}
};

LGSYSC00240.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGSYSC00240();
		form.init();
		form.initForm();
	});
});
</script>
</head>
<body>
<div class="mdi-container popup LGSYSC00240">
  <section class="page-content">
	<div class="pageHeader">
		<h2>${urlAddr.titleName}</h2>
	</div>
	<div class="gridControls module-group text-right">
		<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="add"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="Add"/></button>
		<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="del"><span class="fa fa-remove" aria-hidden="true"></span> <lgcom:message code="Delete"/></button>
	</div>
	<div class="gridContent grid-wrap">
		<div class="grid reviewerListGrid"></div>
	</div>
	<div class="dataBlock">
		<form class="form commentForm" onsubmit="return(false);">
			<input type="hidden" name="requestId"/>
			<input type="hidden" name="orgId"/>
			<input type="hidden" name="requestCode"/>
			<table class="table table-condensed" summary="">
				<caption class="sr-only-lgd"></caption>
				<colgroup>
					<col width="100"/>
					<col width="*"  />
				</colgroup>
				<tbody>
					<tr>
						<th scope="col"><label class="required"><lgcom:message code="Comment"/></label></th>
						<td><textarea name="previewComment" class="commentBox required"></textarea></td>
					</tr>
				</tbody>
			</table>
		</form>
	</div>
	<div class="controls modal-footer">
		<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save"><lgcom:message code="Save"/></button>
		<button class="btn btn-gray btn-sm" type="button" role="button" data-action="cancel"><lgcom:message code="Cancel"/></button>
	</div>
	</section>
</div>
</body>
</html>
