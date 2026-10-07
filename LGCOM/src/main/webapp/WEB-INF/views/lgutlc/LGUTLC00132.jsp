<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
	파일명 : LGUTLC00132.jsp
	프로젝트명 : LGD WCFW

	Copyright(c) 2017 LG CNS, All rights reserved.

	설 명 : 본 화면은 Mail Template Contents를 편집하는 화면입니다.
	작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGUTLC00132 = function() {
	var myForm = this;
	var _popupInfo;
	/* 팝업용 변수 선언 */
	myForm.popupInfo = {
		userPopup: { searchMode:'single', departmentName:'', mailAddr:'', employeeNo:'', employeeName:'', userData:[] }
	};
	/*
	myForm.setManagedLayout({
		displayBlock:{ left:10, top:0, right:10 },
		gridControls:{ left:10, top:SINGLE_LINE.top1, right:10 },
		gridContent :{ left:10, top:DOUBLE_LINE.top1, right:10, bottom:30 },
		controls    :{ left:10, right:10, bottom:0 }
	});
	*/
    /* Layout Setting */
	myForm.setLayout( [ 
		{ name  : "displayBlock",  left : 0, right : 0, top : 0 },		
		{ name  : "gridControls",  left : 0, right : 0, top : "displayBlock", bottom : "gridContent"},
		{ name  : "gridContent",   left : 0, right : 0, top : "gridControls", bottom : "controls"},
		{ name  : "controls",      left : 0, right : 0, bottom : 0 }	 	
	]);
	
	/* Grid Lookup 조회 */
	var code = new CommonCode('lgcom');
	code.add('recTypeCode',{codeTypeCode:'LGCOM_RECIPIENT_TYPE_CODE'});
	code.add('mailTypeCode',{codeTypeCode:'LGCOM_MAIL_TYPE_CODE'});
	code.execute();
	// 그리드 초기화
	var grid = buildGrid('.recipientGrid');
	/* 팝업화면 초기화 */
	myForm.initForm = function() {
		_popupInfo = myForm.getParent().popupInfo;
		myForm.select(".displayBlock input[name='mailId']").val($.trim(_popupInfo['mailId']));
		myForm.select(".displayBlock span[data-name='sendMailName']").text($.trim(_popupInfo['sendMailName']));
		fncRetrieveTextRecipients($.trim(myForm.select(".displayBlock input[name='mailId']").val()));
	};
	/***  이벤트 핸들러  ***/
	myForm.addEvent( "click", "button[data-action]" , function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch(action) {
			// 추가
			case 'insert':
				var cgrid = grid.getGridBase();
				cgrid.commit();
				var curr = cgrid.getCurrent();
				if(curr.itemIndex < 0) {
					cgrid.beginAppendRow();
				} else {
					cgrid.beginInsertRow(curr.itemIndex);
				}
				curr = cgrid.getCurrent();
				cgrid.setValue(curr.itemIndex,'mailId',$.trim(myForm.select(".displayBlock input[name='mailId']").val()));
				cgrid.setCurrent({column:'mailRecipientTypeCode'});
				cgrid.setFocus();
				break;
			// 삭제
			case 'delete':
				grid.getGridBase().deleteSelection(true);
				break;
			// 저장
			case 'save':
				try {
					grid.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				if(grid.getRowCount() == 0) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};
				// 수신자중 TO로 지정된 사용자가 0건이면
				var cgrid = grid.getGridBase();
				var tocnt = 0;
				var recpmap = new Map();
				var isDupFlag = false;
				var dupMailAddr;
				for(var i=0; i < cgrid.getItemCount(); i++) {
					// 삭제건은 제외
					if(cgrid.getDataProvider().getRowState(cgrid.getDataRow(i)) == 'deleted') continue;
					// 수신자 타입이 TO인 경우에만 카운트 한다.
					if(cgrid.getValue(i,'mailRecipientTypeCode') == 'TO') {
						tocnt++;
					}
					if(recpmap.containsKey(cgrid.getValue(i,'mailRecipientAddr'))) {
						dupMailAddr = cgrid.getValue(i,'mailRecipientAddr');
						isDupFlag = true;
						continue;
					}
					recpmap.put(cgrid.getValue(i,'mailRecipientAddr'),1);
				}
				if(tocnt == 0) {
					Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='Recipient'/>"/>');
					return;
				}
				if(isDupFlag) {
					Message.alert('<lgcom:message code="error.dupRecipient" arguments="'+dupMailAddr+'"/>');
					return;
				}
				// 중복건 체크
				Message.confirm('<lgcom:message code="question.save"/>', function() {
					grid.saveChanges('lgcom','lgutlc/LGUTLC00130/saveMailTemplateTextRecipientList', function(data) {
						Message.notify('<lgcom:message code="note.completed"/>');
						// 저장 완료후 목록 재조회
						fncRetrieveTextRecipients(myForm.select(".displayBlock input[name='mailId']").val());
					});
				});
				break;
			// 닫기
			case 'close':
				Popup.closePopup(myForm);
				break;
		}
	});
	grid.getGridBase().onCellButtonClicked = function(cgrid,itemIndex,column) {
		cgrid.commitEditor();
		var curr = cgrid.getCurrent();
		var _popup = myForm.popupInfo.userPopup;
		// 입력된 사용자명을 세팅한다.
		_popup['mailAddr'] = $.trim(cgrid.getValue(itemIndex,'mailRecipientAddr'));
		// 팝업을 호출한다.
		var popup = new Popup(myForm,'lgcom','M_LGUTLC_1142','<lgcom:message code="UserSearch"/>');
		popup.setSize(800,494);	// searchMode 'Single'
		cgrid.setValue(itemIndex,'mailRecipientAddr','');
		popup.open(function() {
			// Mail Addr
			cgrid.setValue(itemIndex,'mailRecipientAddr',$.trim(_popup.userData[0].mailAddr));
			_popup.userData = [];
		});
	};
	grid.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		var provider = cgrid.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';
		// 신규행이 아니면 System, Board ID 컬럼 편집 불가
		if(!editable) {
			cgrid.setColumnProperty('mailRecipientTypeCode','editable',false);
			cgrid.setColumnProperty('mailRecipientAddr','editable',false);
			cgrid.setColumnProperty('mailRecipientAddr','button','none');
		} else {
			cgrid.setColumnProperty('mailRecipientTypeCode','editable',true);
			cgrid.setColumnProperty('mailRecipientAddr','editable',true);
			cgrid.setColumnProperty('mailRecipientAddr','button','action');
		}
	};
	grid.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	};
	/***  내부 함수  ***/
	// 그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		// Grid Field Set
		grid.setFields([
			{ fieldName:'mailId'               , dataType:'number' },
			{ fieldName:'mailRecipientTypeCode', dataType:'text'   },
			{ fieldName:'mailRecipientAddr'    , dataType:'text'   },
			{ fieldName:'mailTypeCode'         , dataType:'text'   }
		]);
		grid.setLookupsMultiLvl({
			recTypeCode: code.get('recTypeCode'),
			mailTypeCode: code.get('mailTypeCode')
		});
		// Grid Column Set
		grid.setColumns([
			{
				name:'mailRecipientTypeCode',
				fieldName:'mailRecipientTypeCode',
				width:100,
				header: {text:'<lgcom:message code="RecipientType"/>', required:true},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'recTypeCode',
				lookupKeyFields: ['mailRecipientTypeCode'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			},
			{
				name:'mailRecipientAddr',
				fieldName:'mailRecipientAddr',
				width:250,
				header: {text:'<lgcom:message code="RecipientMail"/>', required:true},
				button: 'action'
			},
			{
				name:'mailTypeCode',
				fieldName:'mailTypeCode',
				width:100,
				header: {text:'<lgcom:message code="MailType"/>', required:true},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'mailTypeCode',
				lookupKeyFields: ['mailTypeCode'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			}
		]);
		grid.setOptions({
			grid: {
				hideDeletedRows:false,
				indicator: {visible:false},
				panel: {visible:false},
				checkBar: {visible:false},
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
		// Validation Set
		grid.setValidations([
			{criteria: "value['mailRecipientTypeCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='RecipientType'/>"/>',mode:'always',level:'error'},
			{criteria: "value['mailRecipientAddr'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='RecipientMail'/>"/>',mode:'always',level:'error'},
			{criteria: "value['mailTypeCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='MailType'/>"/>',mode:'always',level:'error'}
		]);
		return grid;
	}
	// TEXT Recipient 조회
	function fncRetrieveTextRecipients(recpMailId) {
		var param = {
			mailId: $.trim(recpMailId)
		};
		grid.loadData('lgcom','lgutlc/LGUTLC00130/retrieveMailTemplateTextRecipientList',param);
	}
}

LGUTLC00132.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGUTLC00132();
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
	<div class="displayBlock grid-wrap">
		<table class="table table-condensed">
			<colgroup>
				<col width="120"/>
				<col width="*"/>
			</colgroup>
			<tbody>
				<tr>
					<th scope="row"><label><lgcom:message code="Template"/></label></th>
					<td>
						<input type="hidden" name="mailId"/>
						<span data-name="sendMailName"></span>
					</td>
				</tr>
			</tbody>
		</table>
	</div>
	<div class="gridControls module-group text-right">
		<div class="btn-toolbar">	
			<div class="btn-group">	
				<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="insert"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="Add"/></button>
				<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete"><span class="fa fa-remove" aria-hidden="true"></span> <lgcom:message code="delete"/></button>
			</div>
		</div>		
	</div>
	<div class="gridContent grid-wrap">
		<div class="grid recipientGrid"></div>
	</div>
	<div class="controls modal-footer">
		<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save"><lgcom:message code="save"/></button>
		<button class="btn btn-gray btn-sm" type="button" role="button" data-action="close"><lgcom:message code="Close"/></button>
	</div>
	</section>
</div>
</body>
</html>
