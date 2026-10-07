<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGUTLC00091.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2016 LG CNS,  All rights reserved.

    설 명 : 본 화면은 Dynamic Query Setup Parameter를 조회/수정하는 화면입니다.
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

var LGUTLC00091 = function() {
	var myForm = this;
	var _popupInfo;
	/* Form Util 선언 */
	var formUtil = new FormUtil(myForm,'.dataBlock form');


	/* 화면 레이아웃 정의 */
	/*
	myForm.setManagedLayout({
		commentBlock: { left:10, top:0  , right:10 },
		gridControls: { left:10, top:98 , right:10 },
		contentGrid : { left:10, top:128, right:10, height:150 },
		dataBlock   : { left:10, top:285, right:10 },
		viewControls: { left:10, top:464, right:10 }
	});
	*/
	myForm.setLayout( [ 
	           		{ name : "commentBlock",  left : 0, right : 0, top : 0 },		
	           		{ name : "gridControls", left : 0, right : 0, top : "commentBlock"},
	           		{ name : "contentGrid",  left : 0, right : 0, top : "gridControls", height : 150 },
	           		{ name : "dataBlock",  left : 0, right : 0, top : "contentGrid", bottom : "viewControls"},
	           		{ name : "viewControls",  left : 0, right : 0, top : "dataBlock", bottom :0},
	               ]);	
	/* RealGrid 그리기 */
	var grid = buildGrid('.setupParameterGrid');
	/*** OnLoad 이벤트 **/
	myForm.initMyForm = function() {
		_popupInfo = myForm.getParent().popupInfo;
		formUtil.setValue({queryId:$.trim(_popupInfo['queryId'])});
		retrieveQueryParamerers();
	};
	/*** addChangeEvent 이벤트 **/
	formUtil.addChangeEvent(function(formChangedValue, formOriginalValue, changFlag) {
		var cgrid = grid.getGridBase();
		cgrid.setValue(cgrid.getCurrent().itemIndex,'fromClause'   ,formChangedValue["fromClause"]);
		cgrid.setValue(cgrid.getCurrent().itemIndex,'whereClause'  ,formChangedValue["whereClause"]);
		cgrid.setValue(cgrid.getCurrent().itemIndex,'orderByClause',formChangedValue["orderByClause"]);     
	
	});	
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
				cgrid.beginAppendRow();
				// Query Id
				trace('query id = ' + $.trim(formUtil.getValue('queryId')));
				cgrid.setValue(cgrid.getCurrent().itemIndex,'queryId',$.trim(formUtil.getValue('queryId')));
				// Type
				cgrid.setValue(cgrid.getCurrent().itemIndex,'paraType','C');		// Default Character
				// Distinct Flag
				cgrid.setValue(cgrid.getCurrent().itemIndex,'distinctFlag','N');		// Default N
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
					grid.saveChanges(DQ_CONTEXT_PATH,'lgutlc/LGUTLC00090/saveDynamicQueryParamData',param,function(data) {
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
	myForm.addEvent('submit','.dataBlock form',function(event) {
		event.preventDefault();
	});
	grid.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		var provider = cgrid.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';
		trace('oldRow = ' + oldRow + ', newRow = ' + newRow);
		// 신규행이 아니면 편집 불가
		if(!editable) {
			// 이전행이 존재하면 이전행에서 입력된 Data가 변경된 경우 Bind
			if(oldRow > -1) {
				cgrid.setValue(oldRow,'fromClause',$.trim(formUtil.getValue('fromClause')));
				cgrid.setValue(oldRow,'whereClause',$.trim(formUtil.getValue('whereClause')));
				cgrid.setValue(oldRow,'orderByClause',$.trim(formUtil.getValue('orderByClause')));
				cgrid.commit();
			}
			// 현재행의 Where 절, Order By 절 내용을 쓴다.
			formUtil.setValue({
				fromClause:$.trim(cgrid.getValue(newRow,'fromClause')),
				whereClause:$.trim(cgrid.getValue(newRow,'whereClause')),
				orderByClause:$.trim(cgrid.getValue(newRow,'orderByClause'))
			});
		} else {
			cgrid.setCellStyles(newRow,'paraName','addStyle');
			cgrid.setCellStyles(newRow,'paraType','addStyle');
			cgrid.setCellStyles(newRow,'codeCol','addStyle');
			// 현재행의 Where 절, Order By 절 내용을 쓴다.
			formUtil.setValue({fromClause:'',whereClause:'',orderByClause:''});
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
			{ fieldName: 'paraType'      },
			{ fieldName: 'distinctFlag'  },
			{ fieldName: 'codeCol'       },
			{ fieldName: 'descCol'       },
			{ fieldName: 'formatMask'    },
			{ fieldName: 'fromClause'    },
			{ fieldName: 'whereClause'   },
			{ fieldName: 'orderByClause' }
		]);
		// Lookup 조회, key 속성에 lookup에 매핑될 lookupSourceId 값을 사용한다.
		var _code = new CommonCode(DQ_CONTEXT_PATH);
		grid.setLookups({
			'distinctYn':_code.execute('distinctYn',{codeTypeCode:'LGCOM_YN_FLAG'})
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
				name:'paraType',
				fieldName:'paraType',
				width:100,
				header: {text:'<lgcom:message code="Type"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				values: ['C','N','D','T'],
				labels: ['Character','Number','Date','DateTime'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			},
			{
				name:'distinctFlag',
				fieldName:'distinctFlag',
				width:60,
				header: {text:'<lgcom:message code="distinct"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'distinctYn',
				lookupKeyFields: ['distinctFlag'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			},
			{
				name:'codeCol',
				fieldName:'codeCol',
				width:150,
				header: {text:'<lgcom:message code="CodeColumn"/>'}
			},
			{
				name:'descCol',
				fieldName:'descCol',
				width:150,
				type: 'data',
				header: {text:'<lgcom:message code="DescriptionColumn"/>'}
			},
			{
				name:'formatMask',
				fieldName:'formatMask',
				width:100,
				type: 'data',
				header: {text:'<lgcom:message code="FormatMask"/>'}
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
			{criteria: "value['paraName'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='ParameterName'/>"/>',mode:'always',level:'error'},
			{criteria: "value['paraType'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='Type'/>"/>',mode:'always',level:'error'},
			{criteria: "value['codeCol'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='CodeColumn'/>"/>',mode:'always',level:'error'}
		]);
		return grid;
	}
	// 목록 조회
	function retrieveQueryParamerers() {
		var param = {queryId:$.trim(formUtil.getValue('queryId'))};
		// 컬럼 목록을 조회한다.
		grid.loadData(DQ_CONTEXT_PATH,'lgutlc/LGUTLC00090/retrieveDynamicQueryParamList',param);
	}
	// 저장시 유효성 체크
	function validateEditForm() {
		// 유효성 체크
		// 1. 등록된 Column 개수
		if(grid.getGridBase().getItemCount() == 0) {
			Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='Item'/>"/>');
			return false;
		}
		// 변경건이 있는지 체크
		if(!grid.isChanged()) {
			Message.alert('<lgcom:message code="error.noChangedData"/>');
			return false;
		}
		return true;
	}
};

LGUTLC00091.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch( function(){
		var form = new LGUTLC00091();
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
		<h2>Setup Dynamic Query Parameter</h2>
	</div>
	<div class="commentBlock alert alert-normal" role="alert">
		<p><lgcom:message code="note.dq_comment_1"/></p>
		<p><lgcom:message code="note.dq_comment_2"/></p>
	</div>
	<div class="gridControls module-group text-right">
		<div class="btn-toolbar">	
			<div class="btn-group">	
				<button type="button" class="btn btn-default btn-xs ico-lgd" data-action="add"><span class="fa fa-plus"></span> <lgcom:message code="Add"/></button>
				<button type="button" class="btn btn-default btn-xs ico-lgd" data-action="del"><span class="fa fa-minus"></span> <lgcom:message code="Delete"/></button>
			</div>
		</div>		
	</div>
	<div class="contentGrid grid-wrap">
		<div class="grid setupParameterGrid"></div>
	</div>
	<div class="dataBlock">
		<form class="form" method="post" action="">
			<input type="hidden" name="queryId" value=""/>
			<table class="table table-condensed">
				<colgroup>
					<col width="80"/>
					<col width="*"/>
				</colgroup>
				<tbody>
					<tr>
						<th scope="col"><label><lgcom:message code="From"/></label></th>
						<td><textarea name="fromClause" class="form-control input-sm" rows="3"></textarea></td>
					</tr>
					<tr>
						<th scope="col"><label><lgcom:message code="where"/></label></th>
						<td><textarea name="whereClause" class="form-control input-sm" rows="4"></textarea></td>
					</tr>
					<tr>
						<th scope="col"><label><lgcom:message code="OrderByClause"/></label></th>
						<td><input type="text" name="orderByClause" class="form-control input-sm" /></td>
					</tr>
				</tbody>
			</table>
		</form>
	</div>
	<%-- 서버 버튼 영역 --%>
	<div class="modal-footer viewControls controls">
		<button class="btn btn-dark-gray btn-sm" type="button" role="button" data-action="save"><lgcom:message code="save"/></button>
		<button class="btn btn-gray btn-sm" type="button" role="button" data-action="cancel"><lgcom:message code="cancel"/></button>
	</div>
	</section>
</div>
</body>
</html>
