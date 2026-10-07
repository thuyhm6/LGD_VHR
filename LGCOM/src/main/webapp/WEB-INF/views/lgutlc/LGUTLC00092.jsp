<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGUTLC00092.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 Dynamic Query Parameter를 입력하는 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Dynamic Query</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
/**
 * TODO DQ 프로그램 복제시 해당 Context 명을 변경함으로써 적용가능하다.
 */
var DQ_CONTEXT_PATH = 'lgcom';

var LGUTLC00092 = function() {
	var myForm = this;
	var _popupInfo;
	/* Form Util 선언 */
	var formUtil = new FormUtil(myForm,'.form');
	/* 화면 레이아웃 정의 */
	/*
	myForm.setManagedLayout({
		gridControls: { left:10, top:0  , right:10 },
		contentGrid : { left:10, top:30 , right:10, bottom:30 },
		viewControls: { left:10, right:10, bottom:0, height:28 }
	});
	*/
	myForm.setLayout( [ 
	           		{ name : "gridControls",  left : 0, right : 0, top : 0 },		
	           		{ name : "contentGrid",   left : 0, right : 0, top : "gridControls", bottom : "viewControls"},
	           		{ name : "viewControls",  left : 0, right : 0, bottom : 0 }		
	               ]);	
	/* RealGrid 그리기 */
	var grid = buildGrid('.setupParamValueGrid');
	/*** OnLoad 이벤트 **/
	myForm.initMyForm = function() {
		_popupInfo = myForm.getParent().popupInfo;
		formUtil.setValue({queryId:$.trim(_popupInfo['queryId'])});
		retrieveQueryParamValues(_popupInfo['queryId']);
	};
	/***  이벤트 핸들러  ***/
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch(action) {
			case 'add':
				var cgrid = grid.getGridBase();
				cgrid.commit();
				if(cgrid.getItemCount() >= 10) {
					Message.alert('<lgcom:message code="error.tenrows" arguments="10"/>');
					return;
				}
				cgrid.beginAppendRow();
				// Query Id
				cgrid.setValue(cgrid.getCurrent().itemIndex,'queryId',formUtil.getValue('queryId'));
				// Required
				cgrid.setValue(cgrid.getCurrent().itemIndex,'requiredFlag','N');		// Default N
				break;
			case 'del':
				grid.getGridBase().deleteSelection(true);
				break;
			case 'save':
				try {
					grid.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				if(!validateEditForm()) return;
				Message.confirm('<lgcom:message code="question.save"/>', function() {
					// 저장을 위한 Param Data 조합
					var param = formUtil.getValue();
					//param['queryId'] = formUtil.getValue('queryId');
					// 컬럼 목록
					param['columns'] = grid.getChangedRows();
					// 저장
					transaction(DQ_CONTEXT_PATH,'lgutlc/LGUTLC00090/saveDynamicQueryParamValueData',param,function(data) {
						// 완료 메세지
						Message.alert('<lgcom:message code="note.completed"/>',function() {
							Popup.closePopup(myForm,true);
						});
					});
				});
				break;
			case 'cancel':
				Popup.closePopup(myForm);
				break;
		}
	});
	/* Form Submit 방지 */
	myForm.addEvent('submit','.form',function(event) {
		event.preventDefault();
	});
	grid.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		var provider = cgrid.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';
		// 신규행이 아니면 편집 불가
		if(!editable) {
		} else {
			cgrid.setCellStyles(newRow,'paraName','addStyle');
			cgrid.setCellStyles(newRow,'paraType','addStyle');
			cgrid.setCellStyles(newRow,'codeCol','addStyle');
		}
	};
	/*** 내부 함수 ***/
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		grid.setFields([
			{ fieldName: 'queryId'       },
			{ fieldName: 'paraName'      },
			{ fieldName: 'orgParaName'   },
			{ fieldName: 'defaultValue'  },
			{ fieldName: 'requiredFlag'  }
		]);
		// Lookup 조회, key 속성에 lookup에 매핑될 lookupSourceId 값을 사용한다.
		var _code = new CommonCode(DQ_CONTEXT_PATH);
		grid.setLookups({
			'requiredFlag':_code.execute('requiredFlag',{codeTypeCode:'LGCOM_YN_FLAG'})
		});
		/* Grid 컬럼 생성 */
		grid.setColumns([
			{
				name:'paraName',
				fieldName:'paraName',
				width:120,
				header: {text:'<lgcom:message code="ParameterName"/>'}
			},
			{
				name:'requiredFlag',
				fieldName:'requiredFlag',
				width:50,
				header: {text:'<lgcom:message code="Required"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'requiredFlag',
				lookupKeyFields: ['requiredFlag'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			},
			{
				name:'defaultValue',
				fieldName:'defaultValue',
				width:250,
				header: {text:'<lgcom:message code="DefaultValue"/>'}
			}
		]);
		/* Grid Option 설정 */
		grid.setOptions({
			grid: {
				hideDeletedRows: true,
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
			dataProvider: {
				insertable: true,
				updatable: true,
				deletable: true,
				softDeleting: true,
				deleteCreated: true
			},
			display: { fitStyle: 'evenFill' }
		});
		// Validation Set
		grid.setValidations([
			{criteria: "value['paraName'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='ParameterName'/>"/>',mode:'always',level:'error'}
		]);
		return grid;
	}
	// 목록 조회
	function retrieveQueryParamValues(queryId) {
		var param = {'queryId':$.trim(queryId)};
		// 컬럼 목록을 조회한다.
		grid.loadData(DQ_CONTEXT_PATH,'lgutlc/LGUTLC00090/retrieveDynamicQueryParamValueList',param,function(data) {
			formUtil.setValue('queryId',$.trim(queryId));
		});
	}
	// 저장시 유효성 체크
	function validateEditForm() {
		// 유효성 체크
		// 1. 등록된 Column 개수
		if(grid.getGridBase().getItemCount() == 0) {
			Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='Item'/>"/>');
			return false;
		}
		return true;
	}
};

LGUTLC00092.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch( function(){
		var form = new LGUTLC00092();
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
		<h2>Setup Dynamic Query Parameter Value</h2>
	</div>
	<div class="gridControls module-group text-right">
		<button type="button" class="btn btn-default btn-xs ico-lgd" data-action="add"><span class="fa fa-plus"></span> <lgcom:message code="Add"/></button>
		<button type="button" class="btn btn-default btn-xs ico-lgd" data-action="del"><span class="fa fa-minus"></span> <lgcom:message code="Delete"/></button>
	</div>
	<div class="contentGrid grid-wrap">
		<div class="grid setupParamValueGrid"></div>
	</div>
	<%-- 서버 버튼 영역 --%>
	<div class="viewControls controls modal-footer">
		<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save"><lgcom:message code="save"/></button>
		<button class="btn btn-gray btn-sm" type="button" role="button" data-action="cancel"><lgcom:message code="cancel"/></button>
	</div>
	<%-- Form 영역 --%>
	<form class="form" method="post" action="">
		<input type="hidden" name="queryId" value=""/>
	</form>
	</section>
</div>
</body>
</html>
