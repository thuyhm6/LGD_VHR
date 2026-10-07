<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
	파일명 : LGUTLC00131.jsp
	프로젝트명 : LGD WCFW

	Copyright(c) 2017 LG CNS, All rights reserved.

	설 명 : 본 화면은 Mail Template Contents를 편집하는 화면입니다.
	작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<style type="text/css">

</style>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGUTLC00131 = function() {
	var myForm = this;
	var _popupInfo;
	// Form Util 선언
	var formUtil = new FormUtil(myForm,'.dataBlock form');
	
	// 팝업으로서의 이 화면은 여러 화면에서 사용하는 것으로, 팝업 윈도우의 크기를 아래와 같이 고정하였다.
	myForm.select(".searchBlock").parents("._div_popup_holder_").css({"width": "900px", "height":"700px"});

	/* 화면 레이아웃 정의 */
	/*
	myForm.setManagedLayout({
		displayBlock:{ left:10, top:0, right:10 },
		dataBlock   :{ left:10, top:SINGLE_LINE.top1, right:10, bottom:30 },
		controls    :{ left:10, bottom:0, right:10 }
	});
	*/

    /* Layout Setting */
	myForm.setLayout( [ 
		{ name  : "displayBlock", left : 0, right : 0, top : 0 },		
		{ name  : "dataBlock", left : 0, right : 0, top : "displayBlock", bottom : "templateContents"},
		{ name  : "templateContents", left : 0, right : 0,  top : "dataBlock", bottom : "controls" },	
		{ name  : "controls", left : 0, right : 0,  bottom : 0 }
	]);	
	

	// 조회조건 Combo 초기화
	var code = new CommonCode('lgcom');
	code.execute('languageCode',{codeTypeCode:'LGCOM_LANGUAGE_CODE'});
	formUtil.initCombo('languageCode',code.get('languageCode'));
	// CKEditor 생성
	var editor = new Editor(myForm,'.editor',{
		language: SESSION_USER.languageCode
	});
	/* 사용자 세션 언어코드 세팅 */
	formUtil.setValue('languageCode',SESSION_USER.languageCode);
	/* 팝업화면 초기화 */
	myForm.initForm = function() {
		_popupInfo = myForm.getParent().popupInfo;
		formUtil.setValue('mailId',$.trim(_popupInfo['mailId']));
		myForm.select(".displayBlock span[data-name='sendMailName']").text($.trim(_popupInfo['sendMailName']));
		fncRetrieveContents($.trim(formUtil.getValue('mailId')),$.trim(formUtil.getValue('languageCode')));
	};
	/** 이벤트 핸들러 **/
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = event.target;
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).parent();
		}
		var action = $(item).data("action");
		switch(action) {
			// 저장
			case 'save':
				// 메일 ID
				if($.trim(formUtil.getValue('mailId')) == '') {
					Message.alert('Key is not exists.');
					Popup.closePopup(myForm);
					return;
				}
				// Subject
				if($.trim(formUtil.getValue('subjectText')) == '') {
					Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='Subject'/>"/>');
					myForm.select(".dataBlock form input[name='subjectText']").focus();
					return;
				}
				// Language
				if($.trim(formUtil.getValue('languageCode')) == '') {
					Message.alert('Key is not exists.');
					myForm.select(".dataBlock form select[name='languageCode']").focus();
					return;
				}
				// Template Content
				var content = $.trim(editor.getData());
				var contentBody = content.replace(/<[^>]*>|\s/g,'').replace(/[\&nbsp;]/g,'');
				if(contentBody == '') {
					Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='Content'/>"/>');
					return;
				}
				Message.confirm('<lgcom:message code="question.save"/>',function() {
					var param = formUtil.getValue();
					// 에디터에 입력된 내용이 있다면
					if(contentBody != '') {
						param["mailDetailContent"] = Base64.encode(content);
					}
					transaction_sync('lgcom','lgutlc/LGUTLC00130/saveMailTemplateContentsData',param,function(data) {
						Message.notify('<lgcom:message code="note.saved"/>');
						fncRetrieveContents($.trim(param.mailId),$.trim(param.languageCode));
					});
				});
				break;
			// 삭제
			case 'delete':
				var param = formUtil.getValue();
				Message.confirm('<lgcom:message code="question.delete"/>',function() {
					transaction_sync('lgcom','lgutlc/LGUTLC00130/deleteMailTemplateContentsData',param,function(data) {
						Message.notify('<lgcom:message code="note.deleted"/>');
						fncRetrieveContents($.trim(param.mailId),$.trim(param.languageCode));
					});
				});
				break;
			// 파일 첨부
			case 'attach':
				var fileManager = new FileManager({
					reqNumber: formUtil.getValue('etcAttachFileId'),
					moduleCode: "LGCOM",
					fileCount: 1,
					editable : true,
					success: function( reqNumber, fileData ) {
						if(reqNumber != null) {
							formUtil.setValue('etcAttachFileId',reqNumber);
							myForm.select(".dataBlock form td[data-name='attachFile']").empty();
							var anchor = $('<a></a>');
							anchor.attr('href','#').addClass('download').attr('data-file-id',$.trim(fileData[0].fileId)).css('margin-right','10px').text($.trim(fileData[0].fileName));
							var button = $('<span></span>');
							button.addClass('ico').addClass('ico-reply-del').attr('role','button').attr('aria-hidden','true').attr('data-id',$.trim(fileData[0].fileId));
							myForm.select(".dataBlock form td[data-name='attachFile']").append(anchor).append(button);
						}
					},
					error : function() {
						alert("error");
					}
				});
				fileManager.open();
				break;
			// 취소
			case 'cancel':
				Popup.closePopup(myForm);
				break;
		}
	});
	/* 첨부파일 다운로드 */
	myForm.addEvent('click',".dataBlock td[data-name='attachFile'] a.download",function(event) {
		var fileId = $(event.target).data('fileId');
		var downloader = new Downloader();
		downloader.attachment(fileId, function(){
			Message.notify('<lgcom:message code="note.fileDownloadCompleted"/>');
		});
	});
	/* 첨부파일 삭제 */
	myForm.addEvent('click',".dataBlock td[data-name='attachFile'] span.ico-reply-del",function(event) {
		var fileId = $.trim($(event.target).data('id'));
		var fileName = $.trim($(event.target).prev().html());
		var param = formUtil.getValue();
		param["fileId"] = fileId;
		Message.confirm('<lgcom:message code="question.removeAttach"/><br/><br/>Name : <strong>'+ fileName +'</strong>', function() {
			transaction('lgcom','lgutlc/LGUTLC00130/deleteMailTemplateContentsAttachFile',param,function(data) {
				Message.notify('<lgcom:message code="note.deleted"/>');
				fncRetrieveContents($.trim(param.mailId),$.trim(param.languageCode));
			});
		});
	});
	/* 언어 변경시 재조회 */
	myForm.addEvent('change',".dataBlock select[name='languageCode']",function(event) {
		fncRetrieveContents($.trim(formUtil.getValue('mailId')),$.trim($(event.target).find('>option:selected').val()));
	});
	/* 메일 Content 조회 */
	function fncRetrieveContents(templateMailId,templateLanguageCode) {
		var param = {
			mailId: $.trim(templateMailId),
			languageCode: $.trim(templateLanguageCode)
		};
		transaction('lgcom','lgutlc/LGUTLC00130/retrieveMailTemplateContentsData',param,function(data) {
			if(data.result) {
				var detail = data.result;
				// Subject, Language
				formUtil.setValue({
					mailId: $.trim(detail.mailId),
					subjectText: $.trim(detail.subjectText),
					languageCode: $.trim(detail.languageCode),
					etcAttachFileId: $.trim(detail.etcAttachFileId)
				});
				// 첨부파일
				myForm.select(".dataBlock form td[data-name='attachFile']").empty();
				if($.trim(detail.etcAttachFileId) == '') {
					myForm.select(".dataBlock form td[data-name='attachFile']").append('<button class="btn btn-default btn-sm" type="button" role="button" data-action="attach"><lgcom:message code="Attachment"/></button>');
				} else {
					var anchor = $('<a></a>');
					anchor.attr('href','#').addClass('download').attr('data-file-id',$.trim(detail.fileId)).css('margin-right','10px').text($.trim(detail.fileName));
					var button = $('<span></span>');
					button.addClass('ico').addClass('ico-reply-del').attr('role','button').attr('aria-hidden','true').attr('data-id',$.trim(detail.fileId));
					myForm.select(".dataBlock form td[data-name='attachFile']").append(anchor).append(button);
				}
				// 편집화면
				setTimeout(function() {
					editor.setData($.trim(detail.mailDetailContent));
				},300);
			} else {
				// Subject, Language
				formUtil.setValue({
					mailId: $.trim(templateMailId),
					subjectText: '',
					languageCode: $.trim(templateLanguageCode),
					etcAttachFileId: ''
				});
				// 첨부파일 초기화
				myForm.select(".dataBlock form td[data-name='attachFile']").empty();
				myForm.select(".dataBlock form td[data-name='attachFile']").append('<button class="btn btn-default btn-sm" type="button" role="button" data-action="attach"><lgcom:message code="Attachment"/></button>');
				// 편집화면
				editor.setData('');
			}
		});
	}
}

LGUTLC00131.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGUTLC00131();
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
		<h2>Mail Template Contents</h2>
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
					<td><span data-name="sendMailName"></span></td>
				</tr>
			</tbody>
		</table>
	</div>
	<div class="dataBlock grid-wrap">
		<form class="form">
			<input type="hidden" name="mailId"/>
			<input type="hidden" name="etcAttachFileId"/>
			<table class="table table-condensed">
				<colgroup>
					<col width="120"/>
					<col width="*"/>
					<col width="120"/>
					<col width="90"/>
				</colgroup>
				<tbody>
					<tr>
						<th scope="row"><label class="required" aria-required="true"><lgcom:message code="Title"/></label></th>
						<td><input type="text" name="subjectText" class="form-control input-sm"/></td>
						<th scope="row"><label class="required" aria-required="true"><lgcom:message code="Language"/></label></th>
						<td><select class="form-control input-sm size_90" name="languageCode"></select></td>
					</tr>
					<tr>
						<th scope="row"><label><lgcom:message code="Attachment"/></label></th>
						<td colspan="3" data-name="attachFile"></td>
					</tr>
				</tbody>
			</table>
		</form>
	</div>
	<div class="templateContents">
		<div class="editor"></div>
	</div>	
	<div class="controls modal-footer" >
		<div class="btn-toolbar">	
			<div class="btn-group">							
				<button class="btn btn-default btn-sm" type="button" role="button" data-action="cancel"><lgcom:message code="cancel"/></button>				
			</div>
			<div class="btn-group">
				<button class="btn btn-gray btn-sm" type="button" role="button" data-action="delete"><lgcom:message code="Delete"/></button>
			</div>	
			<div class="btn-group">	
				<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save"><lgcom:message code="save"/></button>
			</div>	
		</div>		
	</div>
	</section>
</div>
</body>
</html>
