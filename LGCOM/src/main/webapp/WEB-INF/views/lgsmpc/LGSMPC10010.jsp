<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%---------------------------------------------------------
	파일명 : LGSMPC10010.jsp
	프로젝트명 : LGD WCFW
	Copyright(c) 2012 LG CNS, All rights reserved.
	설 명 : 본 화면은 요청서 샘플 화면입니다.
	작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<style type="text/css">
.editor {min-height:200px;}
</style>
<script type="text/javascript">
var LGSMPC10010 = function() {
	var myForm = this;
	/* 팝업용 변수 선언 */
	myForm.popupInfo = {
		userPopup: {},		// 결재자
		userMultiPopup: {}	// 참조자
	};

	var requestMasterId = '<c:out value="${urlAddr.requestMasterId}"/>';
	var requestCode = '<c:out value="${urlAddr.requestCode}"/>';

	var reqForm = new RequestForm(myForm,{'requestMasterId':requestMasterId,'requestCode':requestCode});
	// 안내탭 그리기
	reqForm.drawInfomationTab('.tabContents #_${param.bizFormId}_tab1');
	// 요청 정보 그리기
	reqForm.drawRequestHeaderBox('.tabContents #_${param.bizFormId}_tab2 .requestorInfo');
	// 결재선 테이블 그리기
	reqForm.drawApprovalBox('.tabContents #_${param.bizFormId}_tab2 .approvalArea', { mode:'W' });
	// 참조 테이블 그리기
	reqForm.drawCarbonCopyBox('.tabContents #_${param.bizFormId}_tab2 .carbonCopyArea');
	// 전달
	reqForm.drawForwarderBox('.tabContents #_${param.bizFormId}_tab2 .forwardArea', { requestId:requestMasterId, requestCode:requestCode });
	// 사전검토
	reqForm.drawPreviewBox('.tabContents #_${param.bizFormId}_tab2 .previewArea', { requestId:requestMasterId, requestCode:requestCode });
	// 신청서 탭 선택
	myForm.select('.tabHeader ul.nav-tabs li:nth-child(2) a').click();
	/***  이벤트 핸들러  ***/
	// 버튼제어
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch(action) {
			// 임시저장
			case 'save':
				// 요청 Header 정보
				trace(reqForm.getRequestHeaderData());
				// 요청 결재선 정보
				trace(reqForm.getRequestApprovalLine());
				// 참조자 목록
				trace(reqForm.getRequestCarbonCopyList());
				// 전달자 목록
				trace(reqForm.getRequestForwardList());
				break;				
			// Reset
			case 'reset':
				Message.confirm('<lgcom:message code="question.reset"/>',function() {
					reqForm.reset();
				});
				break;
		}
	});
	
	//fileMamagerOption["editable"] = false;
    var formUtil = new FormUtil( myForm, ".attachmentSample");
    
	var fileManager = new FileManager( myForm, { moduleCode : "LGCOM", 
		                                         fileCount : 3 , 
		                                         container : ".fileAttachments" } );
	fileManager.inline( { callback : function( fileGroupId ){
		formUtil.setValue( "fileGroupId" , fileGroupId );
	}});
	
	fileManager.setFileGroupId( "1010" , true );
	
	formUtil.addChangeEvent( function( original, data, isChanged ){
		trace( data );
	});
	
};

LGSMPC10010.prototype = new BizForm("<c:out value="${param.bizFormId}"/>");

$(document).ready( function() {
	launch(function() {
		var form = new LGSMPC10010();
		form.init();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Request Approval Sample</h2>
	</div>
	<!-- 탭 영역 -->
	<div class="tabHeader">
		<ul class="nav nav-tabs">
			<li><a href="#_${param.bizFormId}_tab1" data-toggle="tab" data-action="tab1">&nbsp;<lgcom:message code="Guidance"/>&nbsp;</a></li>
			<li><a href="#_${param.bizFormId}_tab2" data-toggle="tab" data-action="tab2">&nbsp;<lgcom:message code="ReqForm"/>&nbsp;</a></li>
		</ul>
	</div>
	<!-- 각탭 영역 -->
	<div class="tabContents tab-content">
			<!-- 안내 -->
			<div class="tab-pane fade" id="_${param.bizFormId}_tab1"></div>
			<!-- 신청서 -->
			<div class="tab-pane fade" id="_${param.bizFormId}_tab2">
			    <div class="controls module-group text-right">	
					<div class="btn-toolbar">	
						<div class="btn-group">				
							<button class="btn btn-default btn-sm ico-lgd" type="button" name="save" data-action="save"><lgcom:message code="SaveasDraft"/></button>
							<button class="btn btn-default btn-sm ico-lgd type="button" name="request" data-action="request"><lgcom:message code="RequestApproval"/></button>
							<button class="btn btn-default btn-sm ico-lgd" type="button" name="reset" data-action="reset"><lgcom:message code="Reset1"/></button>
							<button class="btn btn-default btn-sm ico-lgd" type="button" name="list" data-action="list"><lgcom:message code="list"/></button>
						</div>
					</div>		
				</div>
				<!-- 요청자 정보 -->
				<div class="requestorInfo"></div>
				<!-- 요청내용 -->
				<div class="requestInfo">
					<div class="editor"></div>
				</div>
				<!-- 결재선 -->
				<div class="approvalArea"></div>
				<!-- 참조 -->
				<div class="carbonCopyArea"></div>
				<!-- 전달 -->
				<div class="forwardArea"></div>
				<!-- 검토 -->
				<div class="previewArea"></div>
				
				<div>
				    <form class= "form attachmentSample">
						<table class="table table-condensed" summary="입력 테이블">
							<caption class="sr-only-lgd">입력 테이블</caption>
							<colgroup>
								<col width="17%">
								<col width="*">
							</colgroup>
							<tbody>
								<tr>
									<th scope="row">
										<label >fileGroupId</label>
									</th>
									<td>
										<input type="text" name="fileGroupId" class="form-control input-sm" placeholder="">
									</td>
								</tr>
								
							</tbody>
						</table>
				    </form>
				</div>
				
				<div class="fileAttachments"></div>
					
		    </div>
	</div>
	</section>
</div>
</body>
</html>
