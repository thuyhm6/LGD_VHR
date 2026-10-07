<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
	파일명 : LGUTLC00133.jsp
	프로젝트명 : LGD WCFW

	Copyright(c) 2012 LG CNS, All rights reserved.

	설 명 : 본 화면은 Mail Template Contents를 편집하는 화면입니다.
	작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGUTLC00133 = function() {
	var myForm = this;
	var _popupInfo;
	// Form Util 선언
	var formUtil = new FormUtil(myForm,'.dataBlock form');
	
	/* 화면 레이아웃 정의 */
	/*
	myForm.setManagedLayout({
		displayBlock   :{ left:10, top:0, right:10 },
		gridContent    :{ left:10, top:SINGLE_LINE.top1, width:300, bottom:30 },
		rightControls  :{ left:315, top:SINGLE_LINE.top1, right:10 },
		dataBlock      :{ left:315, top:DOUBLE_LINE.top1, right:10, bottom:30 },
		bottomControls :{ left:10, right:10, bottom:0 }
	});
	
    /* Layout Setting */
	myForm.setLayout( [ 
		{ name  : "displayBlock",      left : 0, right : 0, top : 0 },		
		{ name  : "rightControls",     left : 0, right : 0, top : "displayBlock", bottom : "dataBlock"},
		{ name  : "gridContent",       left : 0, right : 0, top : "rightControls", width : 300, bottom : "bottomControls" },		
		{ name  : "dataBlock",         left : "gridContent", right : 0, top : "rightControls", bottom : "bottomControls"},
		{ name  : "bottomControls",    left : 0, right : 0, bottom : 0 },	 	
	]);
    
    
	//우측 메뉴 정보 폼의 입력 검증을 위한 validator 정의
	var validator = new Validator( myForm, ".templateItem", {
		rules  : {
			mailId: { required : true },
			mailRecipientTypeCode : { required : true },
			mailTypeCode : { required : true },
			sqlText : { required : true },
			fromSqlText : { required : true }
		},
		messages : {
			mailId: { required : "Required" },
			mailRecipientTypeCode : { required : "Required" },
			mailTypeCode : { required : "Required" },
			sqlText : { required : "Required" },
			fromSqlText : { required : "Required" }
		}
	});
	/* Grid Lookup 조회 */
	var code = new CommonCode('lgcom');
	code.add('recTypeCode',{codeTypeCode:'LGCOM_RECIPIENT_TYPE_CODE'});
	code.add('mailTypeCode',{codeTypeCode:'LGCOM_MAIL_TYPE_CODE'});
	code.execute();
	// 조회조건
	formUtil.initCombo('mailRecipientTypeCode',code.get('recTypeCode'),{selectEmpty:true});
	formUtil.initCombo('mailTypeCode',code.get('mailTypeCode'),{selectEmpty:true});
	// 그리드 초기화
	var grid = buildGrid('.sqlRecipientGrid');
	/* 팝업화면 초기화 */
	myForm.initForm = function() {
		_popupInfo = myForm.getParent().popupInfo;
		myForm.select(".displayBlock input[data-name='mailId']").val($.trim(_popupInfo['mailId']));
		myForm.select(".displayBlock span[data-name='sendMailName']").text($.trim(_popupInfo['sendMailName']));
		fncRetrieveSqlRecipients($.trim(myForm.select(".displayBlock input[data-name='mailId']").val()));
	};
	/***  이벤트 핸들러  ***/
	myForm.addEvent('click','[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch(action) {
			// Preview
			case 'preview':
				Message.alert(formUtil.getValue('generatedQuery'));
				break;
			// 추가
			case 'insert':
				formUtil.clear();
				formUtil.setValue('mailId',myForm.select(".displayBlock input[data-name='mailId']").val());
				break;
			// 추가
			case 'save':
				if(!formUtil.isChanged()) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				};
				if($.trim(formUtil.getValue('mailId')) == '') {
					formUtil.setValue('mailId',myForm.select(".displayBlock input[data-name='mailId']").val());
				}
				if(!validator.isValid()) return;
				Message.confirm('<lgcom:message code="question.save"/>', function() {
					myForm.showProgress();
					transaction('lgcom','lgutlc/LGUTLC00130/saveMailTemplateSqlRecipientData',formUtil.getValue(),function(data) {
						myForm.hideProgress();
						Message.notify('<lgcom:message code="note.completed"/>');
						// 입력화면 초기화
						myForm.select("button[data-action='insert']").trigger('click');
						// 목록 재조회
						fncRetrieveSqlRecipients($.trim(myForm.select(".displayBlock input[data-name='mailId']").val()));
					});
				});
				break;
			// 추가
			case 'delete':
				var param = formUtil.getValue();
				// 선택된 항목이 없다면 중단
				if($.trim(param['mailSeqNo']) == '') return;
				Message.confirm('<lgcom:message code="question.delete"/>',function() {
					myForm.showProgress();
					transaction('lgcom','lgutlc/LGUTLC00130/deleteMailTemplateSqlRecipientData',param,function(data) {
						myForm.hideProgress();
						Message.notify('<lgcom:message code="note.deleted"/>');
						// 입력화면 초기화
						myForm.select("button[data-action='insert']").trigger('click');
						// 목록 재조회
						fncRetrieveSqlRecipients($.trim(myForm.select(".displayBlock input[data-name='mailId']").val()));
					});
				});
				break;
			// 닫기
			case 'close':
				Popup.closePopup(myForm);
				break;
		}
	});
	grid.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		var provider = cgrid.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';
		// 신규행이 아니면 System, Board ID 컬럼 편집 불가
		if(!editable) {
			formUtil.setValue({
				mailId: $.trim(cgrid.getValue(newRow,'mailId')),
				mailSeqNo: $.trim(cgrid.getValue(newRow,'mailSeqNo')),
				mailRecipientTypeCode: $.trim(cgrid.getValue(newRow,'mailRecipientTypeCode')),
				mailTypeCode: $.trim(cgrid.getValue(newRow,'mailTypeCode')),
				sqlText: $.trim(cgrid.getValue(newRow,'sqlText')),
				fromSqlText: $.trim(cgrid.getValue(newRow,'fromSqlText')),
				whereSqlText: $.trim(cgrid.getValue(newRow,'whereSqlText')),
				ruleSqlText: $.trim(cgrid.getValue(newRow,'ruleSqlText')),
				generatedQuery: $.trim(cgrid.getValue(newRow,'genQuery'))
			});
		} else {
			formUtil.clear();
		}
	};
	/***  내부 함수  ***/
	// 그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		// Grid Field Set
		grid.setFields([
			{ fieldName:'mailId'               , dataType:'number' },
			{ fieldName:'mailSeqNo'            , dataType:'number' },
			{ fieldName:'mailRecipientTypeCode', dataType:'text'   },
			{ fieldName:'mailTypeCode'         , dataType:'text'   },
			{ fieldName:'sqlText'              , dataType:'text'   },
			{ fieldName:'fromSqlText'          , dataType:'text'   },
			{ fieldName:'whereSqlText'         , dataType:'text'   },
			{ fieldName:'ruleSqlText'          , dataType:'text'   },
			{ fieldName:'genQuery'             , dataType:'text'   }
		]);
		grid.setLookupsMultiLvl({
			recTypeCode: code.get('recTypeCode'),
			mailTypeCode: code.get('mailTypeCode')
		});
		// Grid Column Set
		grid.setColumns([
			{
				name:'mailSeqNo',
				fieldName:'mailSeqNo',
				width:60,
				header: {text:'<lgcom:message code="No."/>'},
				styles: {textAlignment:'far'},
				editable: false
			},
			{
				name:'mailRecipientTypeCode',
				fieldName:'mailRecipientTypeCode',
				width:80,
				header: {text:'<lgcom:message code="Type"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'recTypeCode',
				lookupKeyFields: ['mailRecipientTypeCode'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'},
				editable: false
			},
			{
				name:'mailTypeCode',
				fieldName:'mailTypeCode',
				width:80,
				header: {text:'<lgcom:message code="MailType"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'mailTypeCode',
				lookupKeyFields: ['mailTypeCode'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'},
				editable: false
			}
		]);
		grid.setOptions({
			grid: {
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
		return grid;
	}
	// SQL Recipient 조회
	function fncRetrieveSqlRecipients(recpMailId) {
		var param = {
			mailId: $.trim(recpMailId)
		};
		grid.loadData('lgcom','lgutlc/LGUTLC00130/retrieveMailTemplateSqlRecipientList',param);
	}
}

LGUTLC00133.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGUTLC00133();
		form.init();
		form.initForm();
	});
});
</script>
</head>

<body>
<div class="mdi-container popup">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Mail Template Recipients</h2>
	</div>
	<div class="displayBlock">
		<input type="hidden" data-name="mailId"/>
		<table class="table">
			<colgroup>
				<col width="120"/>
				<col width="*"/>
			</colgroup>
			<tbody>
				<tr>
					<th scope="row"><label><lgcom:message code="Template"/></label></th>
					<td><span data-name="sendMailName"></span></td>
				</tr>
			</tbody>
		</table>
	</div>
	
	<div class="gridContent grid-wrap">
		<div class="grid sqlRecipientGrid"></div>
	</div>
	
	<div class="controls rightControls module-group text-right">
		<div class="btn-toolbar">	
			<div class="btn-group">	
				<button class="btn btn btn-default btn-sm" type="button" role="button" data-action="preview"><lgcom:message code="Preview"/></button>
			</div>	
			<div class="btn-group">
				<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="insert"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="Add"/></button>
			</div>
			<div class="btn-group">	
				<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save"><lgcom:message code="save"/></button>
				<button class="btn btn-default btn-sm" type="button" role="button" data-action="delete"><lgcom:message code="delete"/></button>
			</div>
		</div>		
	</div>
	
	<div class="dataBlock">
		<form class="templateItem form">
			<input type="hidden" name="mailId"/>
			<input type="hidden" name="mailSeqNo"/>
			<input type="hidden" name="generatedQuery"/>
			<table class="table table-condensed">
				<colgroup>
					<col width="80"/>
					<col width="*"/>
				</colgroup>
				<tr>
					<th scope="row"><label class="required"><i class="asterisk">*</i><lgcom:message code="RecipientType"/></label></th>
					<td><select name="mailRecipientTypeCode" class="form-control input-sm input-require"></select></td>
				</tr>
				<tr>
					<th scope="row"><label class="required"><i class="asterisk">*</i><lgcom:message code="MailType"/></label></th>
					<td><select name="mailTypeCode" class="form-control input-sm input-require"></select></td>
				</tr>
				<tr>
					<th scope="row"><label class="required"><i class="asterisk">*</i><lgcom:message code="Select"/></label></th>
					<td><input type="text" name="sqlText" class="form-control input-sm input-require"/></td>
				</tr>
				<tr>
					<th scope="row"><label class="required"><i class="asterisk">*</i><lgcom:message code="From"/></label></th>
					<td><textarea name="fromSqlText" class="form-control input-sm input-require" style="margin-top:4px;" rows="8" placeholder="FROM table_name alias"></textarea></td>
				</tr>
				<tr>
					<th scope="row"><label><lgcom:message code="where"/></label></th>
					<td><textarea name="whereSqlText" class="form-control input-sm" style="margin-top:4px;" rows="8" placeholder="WHERE condition = [Variable]"></textarea></td>
				</tr>
				<tr>
					<th scope="row"><label><lgcom:message code="GroupOrderby"/></label></th>
					<td><input type="text" name="ruleSqlText" class="form-control input-sm" placeholder="GROUP BY or ORDER BY clause"/></td>
				</tr>
			</table>
		</form>
	</div>
	
	<div class="controls bottomControls modal-footer">
		<button class="btn btn-gray btn-sm" type="button" role="button" data-action="close"><lgcom:message code="Close"/></button>
	</div>
	
	</section>
</div>
</body>
</html>
