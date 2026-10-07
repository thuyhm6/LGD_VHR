<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGSYSC00241.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 검토자로 지정된 인원이 검토의견을 입력하는 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Preview Comment</title>
<style type="text/css">
.LGSYSC00241 .dataBlock {overflow:auto;}
.LGSYSC00241 .commentBox {width:100%;min-height:50px;height:100%;}
.LGSYSC00241 .requestComment {min-height:50px;}
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGSYSC00241 = function() {
	var myForm = this;
	/* 모화면에서 받은 변수 */
	var _popupInfo;
	// Form util 선언
	var formUtil = new FormUtil(myForm,'.dataBlock form.commentForm');

	//팝업으로서의 이 화면은 여러 화면에서 사용하는 것으로, 팝업 윈도우의 크기를 아래와 같이 고정하였다.
	myForm.select(".LGSYSC00241").parents("._div_popup_holder_").css({"width": "700px", "height":"420px"});

	
	/* 화면 레이아웃 정의 */
	/*
	myForm.setManagedLayout({
		dataBlock   : { left:10, top:0, right:10, bottom:28 },
		controls    : { left:10, right:10, bottom:0 }
	});
	*/
	
    /* Layout Setting */
	myForm.setLayout( [ 
		{ name  : "dataBlock", left : 0, right : 0, top : 0, bottom : "controls"},
		{ name  : "controls", left : 0, right : 0, bottom : 0 }	 	
	]);
    
	// Comment 입력 유효성 체크
	var validator = new Validator(myForm,".commentForm",{
		rules : {commentBox: {maxlength:2000}},
		messages : {commentBox: {maxlength:'<lgcom:message code="error.maxlength" arguments="1000,3000"/>'}},
		tooltip_options:{placement:'top'}
	});
	// 첨부파일 영역선언
	var fileManager;
	// 화면 Open시
	myForm.initForm = function() {
		// Popup 정보 받기
		_popupInfo = myForm.getParent().popupInfo.commentPopup;
		formUtil.setValue({
			requestId: $.trim(_popupInfo['requestId']),
			orgId: $.trim(_popupInfo['orgId']),
			requestCode: $.trim(_popupInfo['requestCode'])
		});
		fncRetrieveReviewContent();
	}
	/***  이벤트 핸들러  ***/
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ) {
			// 검토 의견 입력
			case 'save':
				// 검토의견입력여부 체크
				if($.trim(formUtil.getValue('previewComment')) == '') {
					Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='PrereviewComment'/>"/>');
					myForm.select(".dataBlock textarea[name='previewComment']").focus();
					return;
				}
				Message.confirm('<lgcom:message code="question.save"/>', function() {
					transaction('lgcom','lgsysc/LGSYSC00240/updateRequestReviewData',formUtil.getValue(),function(data) {
						Message.notify('<lgcom:message code="note.completed"/>');
						Popup.closePopup(myForm,true);
					});
				});
				break;
			// 검토 의견 입력 취소
			case 'cancel':
				Popup.closePopup(myForm);
				break;
		}
	});
	/***  내부 함수  ***/
	// 검토요청 조회
	function fncRetrieveReviewContent() {
		transaction_sync('lgcom','lgsysc/LGSYSC00240/retrieveReviewRequestData',formUtil.getValue(),function(data) {
			if(data.result) {
				var comment = data.result;
				trace(comment);
				formUtil.setValue({
					approvalSeqs: $.trim(comment['approvalSeqs']),
					attachFileId: $.trim(comment['attachFileId']),
					previewComment: $.trim(comment['approvalComment'])
				});
				// 검토요청내역
				myForm.select(".dataBlock .commentForm div[data-name='requestComment']").html($.trim(comment['inspectionComment']));
				// 검토의견
				myForm.select(".dataBlock .commentForm div[data-name='requestComment']").html($.trim(comment['inspectionComment']));
				// 첨부파일 처리
				fileManager = new FileManager({
					reqNumber: $.trim(comment['attachFileId']),
					moduleCode: 'LGCOM',
					fileCount: 10,
					inline: true,
					editable: true,
					success: function(reqNumber) {
						myForm.select(".dataBlock form.commentForm input[name='attachFileId']").val(reqNumber);
					},
					container : myForm.select('.dataBlock form.commentForm .attachField')
				});
				fileManager.inline();
			}
		});
	}
};

LGSYSC00241.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGSYSC00241();
		form.init();
		form.initForm();
	});
});
</script>
</head>
<body>
<div class="mdi-container popup LGSYSC00241">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Preview Comment</h2>
	</div>
	<div class="dataBlock">
		<form class="form commentForm" onsubmit="return(false);">
			<input type="hidden" name="requestId"/>
			<input type="hidden" name="orgId"/>
			<input type="hidden" name="requestCode"/>
			<input type="hidden" name="approvalSeqs"/>
			<input type="hidden" name="attachFileId"/>
			<table class="table table-condensed" summary="">
				<caption class="sr-only-lgd"></caption>
				<colgroup>
					<col width="50%"/>
					<col width="50%"/>
				</colgroup>
				<thead>
					<tr>
						<th scope="col"><label><lgcom:message code="ReviewRequestContent"/></label></th>
						<th scope="col"><label><lgcom:message code="PrereviewComment"/></label></th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<td><div data-name="requestComment" class="requestComment"></div></td>
						<td><textarea name="previewComment" class="commentBox"></textarea></td>
					</tr>
					<tr>
						<td colspan="2">
							<div class="attachField"></div>
						</td>
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
