<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%---------------------------------------------------------
	파일명 : LGSMPC10011.jsp
	프로젝트명 : LGD WCFW
	Copyright(c) 2017 LG CNS, All rights reserved.
	설 명 : 본 화면은 요청서 샘플 Contents 화면입니다.
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
var LGSMPC10011 = function() {
	var myForm = this;
	/* 요청서 관련 코드 */
	var requestInfo = {
		init : function(param) {
			// 요청서 조회
			//myForm.select(".requestBlock input[name='requestMasterId']").val($.trim('<c:out value="${urlAddr.jobKeyId}"/>'));
			//myForm.select(".requestBlock input[name='requestCode']").val($.trim('<c:out value="${urlAddr.jobRequestCode}"/>'));
			fncRetrieveRequestContent();
		},
		loadCompleted: function() {
			trace('==========> loadCompleted');
		},
		buttons : [
			{text:'<lgcom:message code="RequestCancel"/>'        , action:'selfReject', type:'SELF_REJECT'},
			{text:'<lgcom:message code="Approval"/>'             , action:'approval'  , type:'APPROVAL'   },
			{text:'<lgcom:message code="Reject"/>'               , action:'reject'    , type:'REJECT'     },
			{text:'<lgcom:message code="Forward"/>'              , action:'forward'   , type:'FORWARD'    },
			{text:'<lgcom:message code="Print"/>'                , action:'print'     , type:'PRINT'      }			
		],
		callback : function(action, param) {
			trace(action);
			switch(action) {
				// 임시저장
				case 'save':
					trace(param);
					break;
				// 요청
				case 'request':
					break;
				// 요청취소
				case 'reqcancel':
					break;
				// 전달
				case 'forward':
					trace(param);
					break;
				// 재작성
				case 'rewrite':
					break;
				// 인쇄
				case 'print':
					break;
				// 목록
				case 'list':
					break;
			}
		}
	};
	myForm.setApprovalInfo(requestInfo);

	var requestMasterId = '<c:out value="${param.jobKeyId}"/>';
	var requestCode = '<c:out value="${param.jobRequestCode}"/>';
	trace('requestMasterId = ' + requestMasterId);
	trace('requestCode = ' + requestCode);

	function fncRetrieveRequestContent() {
		trace('===> load contents');
	}
	
	/* 이 화면이 승인 페이지에서 노출 되는 영역의 크기를 지정하는 부분이다  try{} catch(){} 구문을 반드시 적어야 한다.*/
	try {
		_resizeDetailArea( 186 );
	} catch( e ) {
		
	}
};

LGSMPC10011.prototype = new BizForm("<c:out value="${param.bizFormId}"/>");

$(document).ready( function() {
	launch(function() {
		var form = new LGSMPC10011();
		form.init();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Request Approval Content</h2>
	</div>
<%-- Sub 내용 제목 --%>
<div class="module-group clearfix">
	<div class="sub-header pull-left">
		<h3>Request Contents1</h3>
	</div>
</div>
<%-- 요청내용 --%>
<div class="dataBlock contentBlock">
	<form class="form contentForm">
		<table class="table table-condensed" summary="Requestor Infomation">
			<caption class="sr-only-lgd">Request Contents1</caption>
			<colgroup>
				<col width="100"/>
				<col width="*"  />
				<col width="100" />
				<col width="100"/>
			</colgroup>
			<thead>
				<tr>
					<th scope="col"><label>Seq</label></th>
					<th scope="col"><label>Subject</label></th>
					<th scope="col"><label>Date</label></th>
					<th scope="col"><label>Writer</label></th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td class="text-center">1</td>
					<td class="text-center">Approval Request Sample</td>
					<td class="text-center">2017-10-11</td>
					<td class="text-center">Test</td>
				</tr>
			</tbody>
		</table>
	</form>
</div>
<%-- Sub 내용 제목 --%>
<div class="module-group clearfix">
	<div class="sub-header pull-left">
		<h3>Request Contents2</h3>
	</div>
</div>
<%-- 요청내용 --%>
<div class="dataBlock contentBlock">
	<form class="form contentForm">
		<table class="table table-condensed" summary="Requestor Infomation">
			<caption class="sr-only-lgd">Request Contents2</caption>
			<colgroup>
				<col width="100"/>
				<col width="*"  />
				<col width="100" />
				<col width="100"/>
			</colgroup>
			<thead>
				<tr>
					<th scope="col"><label>Seq</label></th>
					<th scope="col"><label>Subject</label></th>
					<th scope="col"><label>Date</label></th>
					<th scope="col"><label>Writer</label></th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td class="text-center">1</td>
					<td></td>
					<td></td>
					<td></td>
				</tr>
			</tbody>
		</table>
	</form>
	</div>
	</section>
</div>
</body>
</html>
