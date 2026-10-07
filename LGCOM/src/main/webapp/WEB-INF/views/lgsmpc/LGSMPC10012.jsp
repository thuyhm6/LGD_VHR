<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%---------------------------------------------------------
	파일명 : approvalSample.jsp
	프로젝트명 : LGD WCFW

	Copyright(c) 2017 LG CNS,  All rights reserved.

	설 명 : 결재 Sample 화면입니다.
	작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<style type="text/css">
.LGSMPC10012 ._reqContent {margin:4px 0px;}
.LGSMPC10012 ._reqContent ._stayTerm {display:block;}
.LGSMPC10012 ._reqContent ._stayTerm:not(:last-child) {margin-bottom:4px;}
.LGSMPC10012 ._reqContent ._stayTerm .seperator {margin:0px 4px;}
</style>
<script type="text/javascript">
var LGSMPC10012 = function() {
	var myForm = this;
	// 팝업 변수
	myForm.popupInfo = { userMultiPopup: {} };
	/* 통합결재 연동 관련 코드 */
	var approvalInfo = {
		init : function(param) {
			// 요청서 조회
			myForm.select(".requestBlock input[name='requestMasterId']").val($.trim('<c:out value="${urlAddr.jobKeyId}"/>'));
			myForm.select(".requestBlock input[name='requestCode']").val($.trim('<c:out value="${urlAddr.jobRequestCode}"/>'));
			fncRetrieveRequestContent();
		},
		buttons : [
			{text:'<lgcom:message code="RequestCancel"/>'        , action:'selfReject', type:'SELF_REJECT'},
			{text:'<lgcom:message code="Approval"/>'             , action:'approval'  , type:'APPROVAL'   },
			{text:'<lgcom:message code="Reject"/>'               , action:'reject'    , type:'REJECT'     },
			{text:'<lgcom:message code="Forward"/>'              , action:'forward'   , type:'FORWARD'    , visible:false},
			{text:'<lgcom:message code="ProcEVF"/>'              , action:'openevf'   , type:'EVFPROC'    , visible:false},
			{text:'<lgcom:message code="ListEVF"/>'              , action:'evflist'   , type:'EVFLIST'    , visible:false},
			{text:'<lgcom:message code="Print"/>'                , action:'print'     , type:'PRINT'      }
		],
		callback : function(action, param) {
			switch(action) {
				// 요청취소
				case 'selfReject':
					<%-- 신청취소하시겠습니까? --%>
					Message.confirm('<lgcom:message code="question.Cancelrequest"/>',function() {
						myForm.showProgress();
						var param = {
							requestMasterId:$.trim(myForm.select(".requestBlock input[name='requestMasterId']").val()),
							requestCode:$.trim(myForm.select(".requestBlock input[name='requestCode']").val())
						};
						transaction("lgcom",'lgcom/LGSMPC10012/updateCancelApprovalRequest',param,function(data) {
							myForm.hideProgress();
							Message.notify('<lgcom:message code="note.Successfullydeleted"/>');	// 성공적으로 삭제하였습니다.
							_approvalCallback( action, true);  //승인 또는 반려 처리에 대한 결과 Callback 처리
						});
					});
					break;
				// 승인
				case 'approval':
					// 승인시 Comment 담기
					myForm.select(".requestBlock input[name='approvalComment']").val($.trim(param.comment));
					var returnValue = fnApprovalOrRejectRequest('approval');
					_approvalCallback(action, returnValue);  //승인 또는 반려 처리에 대한 결과 Callback 처리
					break;
				// 반려
				case 'reject':
					// 반려시 Comment 담기
					myForm.select(".requestBlock input[name='approvalComment']").val($.trim(param.comment));
					var returnValue = fnApprovalOrRejectRequest('reject');
					_approvalCallback(action, returnValue);  //승인 또는 반려 처리에 대한 결과 Callback 처리
					break;
				// 전달
				case 'forward':
					// 팝업에 사용될 Argument 객체 선언
					var _popup = myForm.popupInfo.userMultiPopup;
					// 기존 선택된 사용자 ID를 넘긴다.
					_popup['commentFlag'] = 'Y';
					_popup['keyType'] = 'applicationUserId';		// applicationUserId 또는 userName(사번)
					_popup['keyValue'] = '';
					// 팝업 호출
					var popup = new Popup(myForm,'lgcom','M_LGSYSC_1152','<lgcom:message code="Forwarder"/>');
					popup.setSize(1000,528);
					popup.open(function() {
						if(_popup['userList']) {
							var param = {
								requestMasterId: $.trim(myForm.select(".requestBlock input[name='requestMasterId']").val()),
								requestCode: $.trim(myForm.select(".requestBlock input[name='requestCode']").val()),
								requestorId: $.trim(myForm.select(".requestBlock input[name='requestorId']").val()),
								organizationId: $.trim(myForm.select(".requestBlock input[name='organizationId']").val()),
								transfererNo: [],
								inpctComment: ''
							};
							// 선택된 전달자 정보를 받는다.
							for(var i=0; i < _popup['userList'].length; i++) {
								var userItem = _popup['userList'][i];
								var transf = {
									userId: $.trim(userItem['userId']),
									employeeNo: $.trim(userItem['employeeNo']),
									employeeName: $.trim(userItem['employeeName'])
								};
								param.transfererNo.push(transf);
							}
							param['inpctComment'] = $.trim(_popup['comment']);
							// 전달처리
							<%-- 전달하시겠습니까? --%>
							Message.confirm('<lgcom:message code="question.transfer"/>',function() {
								myForm.showProgress();
								// 전달자를 전달한다.
								myForm.transaction_sync("lgcom",'lgcom/LGSMPC10012/updateRequestTransferer',param,function(data) {
									myForm.hideProgress();
									Message.notify('<lgcom:message code="note.completed"/>');
									// 결재화면 재조회
									_refreshApprovalInfo();
								});
							});
							myForm.popupInfo.userMultiPopup = null;
							myForm.popupInfo.userMultiPopup = {};
						}
					});
					break;
				// 인쇄
				case 'print':
					var browser = navigator.userAgent.toLowerCase();
					if(browser.indexOf('chrome') != -1) {
						window.print();
					} else if (browser.indexOf('trident') != -1) {
						try {
							//웹 브라우저 컨트롤 생성
							var webBrowser = '<object id="previewWeb" width="0" height="0" classid="CLSID:8856F961-340A-11D0-A96B-00C04FD705A2"></object>';
							//웹 페이지에 객체 삽입
							document.body.insertAdjacentHTML('beforeEnd', webBrowser);
							//ExexWB 메쏘드 실행 (7 : 미리보기 , 8 : 페이지 설정 , 6 : 인쇄하기(대화상자))
							document.previewWeb.ExecWB(7,1);
							//객체 해제
							$('#previewWeb').remove();
						} catch(e) {
							Message.alert('<lgcom:message code="note.errorPrint"/>');
						}
					}
					break;
			}
		}
	};
	myForm.setApprovalInfo( approvalInfo );
	/*** 이벤트 핸들러  ***/
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch(action) {
		}
	});
	/***  내부 함수  ***/
	/* 요청내용 조회 */
	function fncRetrieveRequestContent() {
		var param = {
			requestMasterId:$.trim(myForm.select(".requestBlock input[name='requestMasterId']").val()),
			requestCode:$.trim(myForm.select(".requestBlock input[name='requestCode']").val())
		};
		myForm.showProgress();
		myForm.transaction_sync("lgcom",'lgcom/LGSMPC10012/retrieveApprovalContent',param,function(data) {
			if(data.result) {
				var requestorData = data.result['requestorData'];
				var baseContent = data.result['baseContent'];
				var travelerData = data.result['travelerData'];
				var stayTermList = data.result['stayTermList'];
				var approvalFlagData = data.result['approvalFlagData'];
				// 결재진행상태
				if(requestorData) {
					myForm.select(".requestBlock input[name='requestMasterId']").val($.trim(requestorData['requestMasterId']));
					myForm.select(".requestBlock input[name='requestCode']").val($.trim(requestorData['requestCode']));
					myForm.select(".requestBlock input[name='requestNo']").val($.trim(requestorData['requestNo']));
					myForm.select(".requestBlock input[name='requestorId']").val($.trim(requestorData['requestorId']));
					myForm.select(".requestBlock input[name='organizationId']").val($.trim(requestorData['organizationId']));
					myForm.select(".requestBlock input[name='approvalStatusCode']").val($.trim(requestorData['statusCode']));
				}
				// 기본정보
				if(baseContent) {
					// 법인
					myForm.select(".requestBlock ._baseContent input[name='countryCode'").val($.trim(baseContent['countryCode']));
					myForm.select(".requestBlock ._baseContent input[name='subsidiaryCode'").val($.trim(baseContent['subsidiaryCode']));
					myForm.select(".requestBlock ._baseContent span[data-name='subsidiaryName'").text($.trim(baseContent['subsidiaryName']));
					// Visa Type
					myForm.select(".requestBlock ._baseContent input[name='visaTypeCode'").val($.trim(baseContent['visaTypeCode']));
					myForm.select(".requestBlock ._baseContent span[data-name='visaTypeName'").text($.trim(baseContent['visaTypeName']));
				}
				// 출장자
				if(travelerData) {
					// 출장자명
					myForm.select(".requestBlock ._reqContent input[name='travelerId']").val($.trim(travelerData['travelerId']));
					var travelerName = $.trim(travelerData['travelerName']);
					if($.trim(travelerData['travelerTitleName']) != '') {
						travelerName += '/' + $.trim(travelerData['travelerTitleName']);
					}
					myForm.select(".requestBlock ._reqContent span[data-name='travelerName']").text(travelerName);
					// 부서
					myForm.select(".requestBlock ._reqContent input[name='travelerDepartmentCode']").val($.trim(travelerData['travelerDepartmentCode']));
					myForm.select(".requestBlock ._reqContent span[data-name='travelerDepartmentName']").text($.trim(travelerData['travelerDepartmentName']));
					// 전화번호
					myForm.select(".requestBlock ._reqContent span[data-name='travelerOfficeNumber']").text($.trim(travelerData['travelerOfficeNumber']));
					// 여권번호
					myForm.select(".requestBlock ._reqContent span[data-name='travelerPassportNumber']").text($.trim(travelerData['passportNo']));
					// 영문명
					myForm.select(".requestBlock ._reqContent span[data-name='travelerEnglishName']").text($.trim(travelerData['englishName']));
					// 성별
					myForm.select(".requestBlock ._reqContent input[name='genderCode']").val($.trim(travelerData['genderCode']));
					myForm.select(".requestBlock ._reqContent span[data-name='genderName']").text($.trim(travelerData['genderName']));
					// 여권발행일
					myForm.select(".requestBlock ._reqContent span[data-name='issueDate']").text($.trim(travelerData['passportStartDate']));
					// 여권만료일
					myForm.select(".requestBlock ._reqContent span[data-name='expiryDate']").text($.trim(travelerData['passportEndDate']));
					// 생일
					myForm.select(".requestBlock ._reqContent span[data-name='birthDay']").text($.trim(travelerData['birthDate']));
				}
				// 체류기간
				if(stayTermList) {
					$(stayTermList).each(function(inx) {
						var div = $('<div></div>');
						div.addClass('form-inline').addClass('_stayTerm');
						var span1= $('<span></span>');
						span1.text($.trim(this['fromDate']));
						var span2= $('<span>~</span>');
						span2.addClass('seperator');
						var span3= $('<span></span>');
						span3.text($.trim(this['toDate']));
						div.append(span1).append(span2).append(span3);
						myForm.select(".requestBlock ._reqContent td[data-name='stayTerm']").append(div);
					});
				}
				// 요청자, 결재자, 참조자 여부
				if(approvalFlagData) {
					myForm.select(".requestBlock input[name='requestorFlag']").val($.trim(approvalFlagData['requestorFlag']));
					myForm.select(".requestBlock input[name='approverFlag']").val($.trim(approvalFlagData['approverFlag']));
					myForm.select(".requestBlock input[name='referrerFlag']").val($.trim(approvalFlagData['referrerFlag']));
				}
			}
			// 결재영역 높이 재지정
			_resizeDetailArea(myForm.select('.LGBTF00031 .requestBlock').outerHeight(true) + 10);
			fncControllButton();
			myForm.hideProgress();
		});
	}
	// 결재 처리 Callback Function
	function fnApprovalOrRejectRequest(actionCode) {
		myForm.showProgress();
		var returnValue = false;
		myForm.select(".requestBlock input[name='approvalActionCode']").val(actionCode);
		var param = {
			requestMasterId: $.trim(myForm.select(".requestBlock input[name='requestMasterId']").val()),
			requestCode: $.trim(myForm.select(".requestBlock input[name='requestCode']").val()),
			requestNo: $.trim(myForm.select(".requestBlock input[name='requestNo']").val()),
			approvalActionCode: $.trim(myForm.select(".requestBlock input[name='approvalActionCode']").val()),
			approvalComment: $.trim(myForm.select(".requestBlock input[name='approvalComment']").val())
		}
		transaction_sync("lgcom",'lgcom/LGSMPC10012/saveRequestApprovalOrReject',param,function(data) {
			if(data.result) {
				// 정상처리
				if($.trim(data.result['errorCode']) == 'S') {
					returnValue = true;
				} else {
					returnValue = false;
				}
				myForm.hideProgress();
				if(!returnValue) {
					Message.alert(data.result['errorMsg']);
				}
				return returnValue;
			}
			myForm.hideProgress();
		},function(error) {
			trace(error);
			myForm.hideProgress();
		});
	}
	// Custom Button 제어 로직
	function fncControllButton() {
		// 처리상태가 승인완료이면서 요청자, 결재자, 참조자, 전달자의 경우에만 EVF처리,EVF처리현황 버튼을 숨긴다.
		var status = $.trim(myForm.select(".requestBlock input[name='approvalStatusCode'").val());
		var flag1 = $.trim(myForm.select(".requestBlock input[name='requestorFlag']").val());
		var flag2 = $.trim(myForm.select(".requestBlock input[name='approverFlag']").val());
		var flag3 = $.trim(myForm.select(".requestBlock input[name='referrerFlag']").val());
		var flag = (flag1 == 'Y' || flag2 == 'Y' || flag3 == 'Y');
		if(status == '40' && flag) {
			_approvalButtonControl('FORWARD',true);
		} else {
			_approvalButtonControl('FORWARD',false);
		}
	}
};

LGSMPC110012.prototype = new BizForm("${param.bizFormId}");

$(document).ready(function() {
	launch(function() {
		var form = new LGSMPC110012();
		form.init();
	});
});
</script>
</head>

<body>
<div class="mdi-container LGSMPC110012">
<section class="page-content">
	<div class="pageHeader">
		<h2>초청장 요청서</h2>
	</div>
	<%-- 신청 정보 --%>
	<div class="dataBlock requestBlock">
		<input type="hidden" name="requestMasterId"/>
		<input type="hidden" name="requestCode"/>
		<input type="hidden" name="requestNo"/>
		<input type="hidden" name="requestorId"/>
		<input type="hidden" name="organizationId"/>
		<input type="hidden" name="approvalActionCode"/>
		<input type="hidden" name="approvalComment"/>
		<input type="hidden" name="approvalStatusCode"/>

		<input type="hidden" name="requestorFlag" value="N"/>
		<input type="hidden" name="approverFlag" value="N"/>
		<input type="hidden" name="referrerFlag" value="N"/>
		<table class="table table-condensed _baseContent" summary="">
			<caption class="sr-only-lgd"><lgcom:message code="ApprovalRequestor"/></caption>
			<colgroup>
				<col width="110"/>
				<col width="200"/>
				<col width="110"/>
				<col width="*"  />
			</colgroup>
			<tbody>
				<tr>
					<th><label><lgcom:message code="btf.Subdiary"/></label></th>
					<td><span data-name="subsidiaryName"></span><input type="hidden" name="countryCode"/><input type="hidden" name="subsidiaryCode"/></td>
					<th><label><lgcom:message code="btf.VisaType"/></label></th>
					<td><span data-name="visaTypeName"></span><input type="hidden" name="visaTypeCode"/></td>
				</tr>
			</tbody>
		</table>
		<%-- 신청 내역 --%>
		<table class="table table-condensed _reqContent" summary="">
			<caption class="sr-only-lgd">초청장 요청서</caption>
			<colgroup>
				<col width="110"/>
				<col width="200"/>
				<col width="110"/>
				<col width="300"/>
				<col width="110"/>
				<col width="*"  />
			</colgroup>
			<tbody>
				<tr>
					<th scope="col"><label><lgcom:message code="Traveler"/></label></th>
					<td><span data-name="travelerName"></span><input type="hidden" name="travelerId"/></td>
					<th scope="col"><label><lgcom:message code="Department"/></label></th>
					<td><span data-name="travelerDepartmentName"></span><input type="hidden" name="travelerDepartmentCode"/></td>
					<th scope="col"><label><lgcom:message code="PhoneNo"/></label></th>
					<td><span data-name="travelerOfficeNumber"></span></td>
				</tr>
				<tr>
					<th scope="col"><label><lgcom:message code="btf.PassportNo"/></label></th>
					<td><span data-name="travelerPassportNumber"></span></td>
					<th scope="col"><label><lgcom:message code="btf.EnglishName"/></label></th>
					<td><span data-name="travelerEnglishName"></span></td>
					<th scope="col"><label><lgcom:message code="Gender"/></label></th>
					<td><span data-name="genderName"></span><input type="hidden" name="genderCode"/></td>
				</tr>
				<tr>
					<th scope="col"><label><lgcom:message code="btf.PassportIssueDate"/></label></th>
					<td><span data-name="issueDate"></span></td>
					<th scope="col"><label><lgcom:message code="btf.PassportExpiryDate"/></label></th>
					<td><span data-name="expiryDate"></span></td>
					<th scope="col"><label><lgcom:message code="btf.BirthDay"/></label></th>
					<td><span data-name="birthDay"></span></td>
				</tr>
				<tr>
					<th><label><lgcom:message code="btf.StayTerm"/></label></th>
					<td colspan="7" data-name="stayTerm"></td>
				</tr>
			</tbody>
		</table>
	</div>
	</section>
</div>
</body>
</html>
