<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
	파일명 : LGSYSC00300.jsp
	프로젝트명 : LGD WCFW

	Copyright(c) 2017 LG CNS,  All rights reserved.

	설 명 :  요청서를 표시하는 화면입니다.
	작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Request Form</title>
<style type="text/css">
.formContainer .guideContent div.contents {min-height:200px;overflow:auto;}
.formContainer .guideContent ul._fileList {padding:0px;margin:0px;list-style:none;}
.formContainer .guideContent ul._fileList li._fileItem {float:left;width:100%;margin-left:5px;display:inline-block;padding:3px 5px;}
.formContainer ._labelSpan {width:100%;max-width:200px;display:inline-block;overflow:hidden;text-overflow:ellipsis;padding:4px 0px 0px 0px;}
.formContainer .customContent {margin:4px 0px;}
.formContainer ._requestControls button {margin-left:4px}
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var <c:out value="${param.bizFormId}"/> = function() {
	var myForm = this;
	/* FormUtil 선언 */
	var requestorForm = new FormUtil(myForm,'.requestorBlock form._requestorForm');
	var approverForm  = new FormUtil(myForm,'.approverBlock form._approverForm');
	var referrerForm  = new FormUtil(myForm,'.referrerBlock form._referrerForm');
	/* 팝업용 변수 선언 */
	myForm.popupInfo = {
		userPopup: {},		// 결재자
		userMultiPopup: {}	// 참조자
	};
	// 결재 구분 코드
	var _code = new CommonCode('lgcom');
	_code.add('approvalTypeCode',{queryId:'retrieveFilteredCommonCodeList',codeTypeCode:'LGCOM_APPROVAL_ACTION_CODE',filterColumn:'code_data3_value',filterVallue:'APPROVAL'});
	_code.add('approvalStatusCode',{codeTypeCode:'LGCOM_APPROVAL_REQ_STATUS_CODE'});
	_code.execute();
	var __apprType = _code.get('approvalTypeCode');
	/* 요청서에 필요한 변수를 받는다. */
	var contentMenuId = '<c:out value="${urlAddr.contentMenuId}"/>';
	var contentBizFormId = uuid();
	var requestMasterId = '<c:out value="${urlAddr.requestMasterId}"/>';
	var requestCode = '<c:out value="${urlAddr.requestCode}"/>';
	requestMasterId = '193';
	requestCode = '51004';
	var request;
	/***  요청서 초기 설정 ***/
	myForm.initForm = function() {
		requestorForm.setValue({
			requestMasterId: requestMasterId,
			requestCode: requestCode
		});
		myForm.showProgress();
		// 메뉴 ID로 메뉴정보 조회
		fncRetrieveMenuData();
		/**
		 * TODO 현재 Program 기준으로 메뉴얼 설정이 되어 있어 요청서 가이드로 사용하기에는 불가능함.
		 */
		//fncLoadRequestInfo();
		// 요청자 정보 조회
		fncRetrieveRequestorData({
			requestMasterId: $.trim(requestorForm.getValue('requestMasterId')),
			requestCode: $.trim(requestorForm.getValue('requestCode'))
		});
		// 결재자 조회
		fncRetrieveApproverList();
		// 참조자 조회
		fncRetrieveReferrerList();
		// 요청내용 조회
		fncLoadRequestContent();
		// 진행상태가 10이 아니면 ReadOnly 모드
		setTimeout(function() {
			if($.trim(requestorForm.getValue('statusCode')) == '10') {
				//fncSetReadOnlyMode(false);
				fncSetReadOnlyMode(true);
			} else {
				fncSetReadOnlyMode(true);
			}
		},500);
		myForm.select(".tabHeader>ul>li>a[data-action='tab2']").click();
		myForm.hideProgress();
	};
	/***  이벤트 핸들러  ***/
	// 버튼제어
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch(action) {
			// 결재자 Reset
			case 'apprReset':
				myForm.select('.approverBlock>form._approverForm>table>tbody>tr').each(function() {
					if($.trim($(this).find('input[name="settlementDeleteFlag"]').val()) != 'Y') {
						$(this).remove();
						fncResetApprovalSeq();
					}
				});
				break;
			// 결재자 첫행 추가
			case 'apprAddFirst':
				fncSearchApprover('P');
				break;
			// 참조자 Reset
			case 'refrReset':
				myForm.select('.referrerBlock>form._referrerForm>table>tbody>tr').each(function() {
					$(this).remove();
				});
				break;
			// 참조자 첫행 추가
			case 'refrAddFirst':
				fncSearchReferrer('P',-1);
				break;
			// 임시저장
			case 'save':
			// 요청
			case 'request':
			// 요청취소
			case 'reqcancel':
				if(request) {
					try {
						request.callback.call(this, action, fncGetRequestInfo());
					} catch(e) {}
				}
				break;
			// 전달자 추가
			case 'forward':
				// 전달자는 결재 완료시에 처리함
				if($.trim(requestorForm.getValue('requestMasterId')) == '') {
					Message.alert('<lgcom:message code="error.CheckRequestNo."/>');
					return;
				}
				if($.trim(requestorForm.getValue('statusCode')) != '40') {
					Message.alert('Check approval status.');
					return;
				}
				// 팝업에 사용될 Argument 객체 선언
				var _popup = myForm.popupInfo.userMultiPopup;
				// 기존 선택된 사용자 ID를 넘긴다.
				_popup['commentFlag'] = 'Y';
				_popup['keyType'] = 'applicationUserId';		// applicationUserId 또는 userName(사번)
				_popup['keyValue'] = '';
				// 팝업 호출
				var popup = new Popup(myForm,'lgcom','M_LGSYSC_1152','<lgcom:message code="Referrers"/>');
				popup.setSize(1000,528);
				popup.open(function() {
					if(_popup['userList']) {
						var param = {
							requestMasterId: $.trim(requestorForm.getValue('requestMasterId')),
							requestCode: $.trim(requestorForm.getValue('requestCode')),
							requestorId: $.trim(requestorForm.getValue('requestorId')),
							requestorEmpNo: $.trim(requestorForm.getValue('requestorEmpNo')),
							organizationId: $.trim(requestorForm.getValue('organizationId')),
							forwarderList: [],
							inpctComment: ''
						};
						// 선택된 전달자 정보를 받는다.
						for(var i=0; i < _popup['userList'].length; i++) {
							var userItem = _popup['userList'][i];
							var forward = {
								userId: $.trim(userItem['userId']),
								employeeNo: $.trim(userItem['employeeNo']),
								employeeName: $.trim(userItem['employeeName'])
							};
							param.forwarderList.push(forward);
						}
						param['inpctComment'] = $.trim(_popup['comment']);
						// 전달처리
						<%-- 전달하시겠습니까? --%>
						Message.confirm('<lgcom:message code="question.transfer"/>',function() {
							myForm.showProgress();
							// 전달자를 전달한다.
							transaction_sync(CONTEXT_PATH,'common/requestForm/retrieveMenuData',param,function(data) {
								myForm.hideProgress();
								Message.notify('<lgcom:message code="note.completed"/>');
							});
						});
						if(request) {
							try {
								request.callback.call(this, action, param);
							} catch(e) {}
						}
						myForm.popupInfo.userMultiPopup = null;
						myForm.popupInfo.userMultiPopup = {};
					}
				});
				break;
			// 재작성
			case 'rewrite':
				// 요청자 정보 정리
				requestorForm.setValue({
					requestMasterId: '',
					requestCode: '',
					requestNo: '',
					organizationId: $.trim(SESSION_USER.defaultOrgId),
					requestorId: $.trim(SESSION_USER.applicationUserId),
					requestorEmpNo: $.trim(SESSION_USER.userName),
					departmentCode: $.trim(SESSION_USER.departmentCode),
					statusCode: '10'
				});
				// 요청번호
				myForm.select(".requestorBlock span[data-name='requestNo']").text('');
				// 요청자
				var requestorInfo = '<c:out value="${sessionScope.USER_SESSION.fullNameLocal}"/>/<c:out value="${sessionScope.USER_SESSION.titleName}"/>/<c:out value="${sessionScope.USER_SESSION.organizationName}"/>'/
				myForm.select(".requestorBlock span[data-name='requestorInfo']").text(requestorInfo);
				// 상태
				myForm.select(".requestorBlock span[data-name='approvalStatus']").text(fncGetApprovalStatusName('10'));
				// 요청일자
				myForm.select(".requestorBlock span[data-name='requestDate']").text(DateUtil.today('YYYY-MM-DD'));
				// 기존 전달자 제거
				myForm.select(".referrerBlock table tbody").empty();
				fncSetReadOnlyMode(false);
				if(request) {
					try {
						request.callback.call(this, action, param);
					} catch(e) {}
				}
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
				if(request) {
					try {
						request.callback.call(this, action, param);
					} catch(e) {}
				}
				break;
			default:
				if(request) {
					try {
						request.callback.call(this, action, fncGetRequestInfo());
					} catch(e) {}
				}
				break;
		}
	});
	/**
	 * 내용을 담은 페이지의 메뉴 ID로 메뉴 정보 조회
	 */
	function fncRetrieveMenuData() {
		transaction_sync(CONTEXT_PATH,'common/requestForm/retrieveMenuData',{menuId:contentMenuId},function(data) {
			if(data.result) {
				myForm.select('.customContent').data('custom',data.result);
			}
		});
	}
	/**
	 *
	 */
	function fncInitRequestForm() {
		var contentForm = LayoutManager.getForm(contentBizFormId);
		if(contentForm) {
			request = contentForm.getRequestInfo();
			if(request) {
				// 초기함수가 있을 경우 수행한다.
				try {
					request.init.call( this , {} );
				} catch(e){}
				// 버튼 영역 그리기
				myForm.select("#_${param.bizFormId}_tab2>.controls").empty();
				$(request.buttons).each(function() {
					var button = $('<button type="button"></button>');
					if(['SAVE','REQUEST','CANCEL'].indexOf(this['type']) != -1) {
						button.addClass('btn').addClass('btn-save').addClass('btn-sm');
					}
					else if( ['FORWARD','REWRITE','PRINT'].indexOf(this['type']) != -1) {
						button.addClass('btn').addClass('btn-gray').addClass('btn-sm');
					}
					else {
						button.addClass('btn').addClass('btn-default').addClass('btn-sm');
					}
					button.attr('data-action',$.trim(this['action']));
					button.attr('data-type',$.trim(this['type']));
					button.text($.trim(this['text']));
					if($.trim(this['visible']) == 'false' || $.trim(this['visible']) == 'N') {
						button.hide();
					}
					myForm.select("#_${param.bizFormId}_tab2>.controls").append(button);
				});
				// 모든 수행이 완료될 경우 callback 이 있으면 호출
				try {
					request.loadCompleted.call(this);
				} catch(e){}
			}
		}
	}
	/**
	 * 요청서 안내탭 정보 조회
	 */
	function fncLoadRequestInfo() {
		var menuItem = LayoutManager.getMenuItem(myForm.getBizFormId());
		transaction_sync(CONTEXT_PATH,'common/requestForm/retrieveRequestFormInfomationTab',{programId:$.trim(menuItem['programId'])},function(data) {
			if(data.result) {
				/*
				headerData = data['result'];
				row1.find('td').html(info.manualContent);
				*/
			}
		});
	}
	/**
	 * 요청자 정보 조회
	 */
	function fncRetrieveRequestorData(param) {
		transaction_sync(CONTEXT_PATH,'common/requestForm/retrieveRequestHeadInfo', param, function(data) {
			if(data.result) {
				requestorForm.setValue({
					requestMasterId: $.trim(data.result['requestMasterId']),
					requestCode: $.trim(data.result['requestCode']),
					requestNo: $.trim(data.result['requestNo']),
					organizationId: $.trim(data.result['organizationId']),
					requestorId: $.trim(data.result['requestorId']),
					requestorEmpNo: $.trim(data.result['requestorEmpNo']),
					departmentCode: $.trim(data.result['departmentCode']),
					statusCode: $.trim(data.result['statusCode'])
				});
				// 요청번호
				myForm.select(".requestorBlock span[data-name='requestNo']").text($.trim(data.result['requestNo']));
				// 요청자
				myForm.select(".requestorBlock span[data-name='requestorInfo']").text($.trim(data.result['requestorInfo']));
				// 상태
				myForm.select(".requestorBlock span[data-name='approvalStatus']").text($.trim(data.result['statusName']));
				// 요청일자
				myForm.select(".requestorBlock span[data-name='requestDate']").text($.trim(data.result['requestDate']));
				// 요청제목
				myForm.select(".requestorBlock input[name='requestTitle']").val($.trim(data.result['requestTitle']));
			}
		});
	}
	/**
	 * 결재자 조회
	 */
	function fncRetrieveApproverList() {
		// 결재자 목록을 조회한다.
		transaction_sync(CONTEXT_PATH,'common/requestForm/retrieveApprovalLineList', requestorForm.getValue(), function(data) {
			if(data.result) {
				$(data.result).each(function() {
					fncAddApprover('A',-1,this);
				});
			}
		});
		// 결재진행상태에 따라서 컬럼을 숨긴다.
		if($.trim(requestorForm.getValue('statusCode')) == '10') {
			myForm.select(".approverBlock table thead tr th").each(function(inx) {
				if(inx == 4 || inx == 5 || inx == 6) {
					$(this).hide();
				}
			});
			myForm.select(".approverBlock table tbody tr").each(function() {
				$(this).find('td').each(function(inx) {
					if(inx == 4 || inx == 5 || inx == 6) {
						$(this).hide();
					}
				});
			});
			myForm.select('.approverBlock').prev().find('input,button,select').prop('disabled',false);
			myForm.select('.approverBlock').find('input,button,select').prop('disabled',false);
		} else {
			myForm.select(".approverBlock table thead tr th").each(function(inx) {
				if(inx == 7) {
					$(this).hide();
				} else {
					$(this).show();
				}
			});
			myForm.select(".approverBlock table tbody tr").each(function() {
				$(this).find('td').each(function(inx) {
					if(inx == 7) {
						$(this).hide();
					} else {
						$(this).show();
					}
				});
			});
			myForm.select('.approverBlock').prev().find('input,button,select').prop('disabled',true);
			myForm.select('.approverBlock').find('input,button,select').prop('disabled',true);
		}
	}
	/**
	 * 참조자 조회
	 */
	function fncRetrieveReferrerList() {
		transaction_sync(CONTEXT_PATH,'common/requestForm/retrieveCarbonCopyList', requestorForm.getValue(), function(data) {
			if(data.result) {
				$(data.result).each(function() {
					fncAddReferrer(this);
				});
			}
		});
		// 결재진행상태에 따라서 컬럼을 숨긴다.
		if($.trim(requestorForm.getValue('statusCode')) == '10') {
			myForm.select(".referrerBlock table thead tr th").each(function(inx) {
				if(inx == 2) {
					$(this).hide();
				}
			});
			myForm.select(".referrerBlock table tbody tr").each(function() {
				$(this).find('td').each(function(inx) {
					if(inx == 2) {
						$(this).hide();
					}
				});
			});
			myForm.select('.referrerBlock').prev().find('input,button,select').prop('disabled',false);
			myForm.select('.referrerBlock').find('input,button,select').prop('disabled',false);
		} else {
			myForm.select(".referrerBlock table thead tr th").each(function(inx) {
				if(inx == 3) {
					$(this).hide();
				} else {
					$(this).show();
				}
			});
			myForm.select(".referrerBlock table tbody tr").each(function() {
				$(this).find('td').each(function(inx) {
					if(inx == 3) {
						$(this).hide();
					} else {
						$(this).show();
					}
				});
			});
			myForm.select('.referrerBlock').prev().find('input,button,select').prop('disabled',true);
			myForm.select('.referrerBlock').find('input,button,select').prop('disabled',true);
		}
	}
	/**
	 * 요청서 내용 화면 로딩
	 */
	function fncLoadRequestContent() {
		var custom = myForm.select('.customContent');
		var menu = custom.data('custom');
		var pageUrl = SERVER_URL + '/' + $.trim(menu['programSystemCode']).toLowerCase() + '/service/' + $.trim(menu['menuId']);
		$( custom ).data("URL", pageUrl );
		var param = {
			bizFormId: contentBizFormId,
			source: 'main',
			requestMasterId: requestMasterId,
			requestCode: requestCode
		};
		myForm.showProgress();
		custom.load(pageUrl, param, function(responseText, statusText, xhr) {
			//LayoutManager.addForm( contentBizFormId, null );
			$(custom).find("._loader").remove();
			$(this).data("URL", pageUrl );
			myForm.hideProgress();
			// 요청 버튼 처리
			fncInitRequestForm();
		});
	}
	/**
	 * 결재자 추가
	 * type - P, A
	 *        P : 테이블의 첫 행에 결재자를 추가한다.
	 *        A : 선택된 Row 의 아래에 결재자를 추가한다.
	 * ridx - 테이블 tr Index
	 * data - 결재자 정보
	 */
	function fncAddApprover(type,ridx,data) {
		var _tableBody = myForm.select('.approverBlock>form._approverForm>table>tbody');
		var tr = $('<tr></tr>');
		var td1 = $('<td></td>');	// Seq
		td1.addClass('text-center');
		var spn = $('<span></span>');
		spn.attr('name','seq');
		var inp0 = $('<input type="hidden" name="approvalSeqs"/>');
		td1.append(spn).append(inp0);
		var td2 = $('<td></td>');	// Approval Type
		td2.addClass('text-center');
		var cmb = $('<select></select>');
		cmb.addClass('form-control').addClass('input-sm').addClass('size_120');
		cmb.attr('name','approvalActionCode');
		$(__apprType).each(function() {
			cmb.append('<option value=' + $.trim(this['code']) + '>' + $.trim(this['name']) + '</option>');
		});
		if($.trim(data['approvalActionCode']) == '') {
			cmb.val('APPROVAL'); // Default APPROVAL
		} else {
			cmb.val($.trim(data['approvalActionCode']));
		}
		td2.append(cmb);
		var td3 = $('<td></td>');	// Approver
		var apprInfo = $.trim(data['employeeName']);
		if(apprInfo != '') {
			// 직위
			if($.trim(data['positionName']) != '') {
				apprInfo += ' / ' + $.trim(data['positionName']);
			} else {
				apprInfo += ' / ' + $.trim(data['titleName']);
			}
			// 부서
			apprInfo += ' / ' + $.trim(data['departmentName']);
		}
		td3.html(apprInfo);
		var inp3 = $('<input type="hidden" name="applicationUserId"/>');
		inp3.val($.trim(data['applicationUserId']));
		td3.append(inp3);
		var inp4 = $('<input type="hidden" name="employeeNo"/>');
		inp4.val($.trim(data['employeeNo']));
		td3.append(inp4);
		var inp5 = $('<input type="hidden" name="settlementDeleteFlag"/>');
		inp5.val(data['settlementDeleteFlag']);
		td3.append(inp5);
		var inp6 = $('<input type="hidden" name="approvalLineId"/>');
		inp6.val($.trim(data['approvalLineId']));
		td3.append(inp6);
		var td4 = $('<td></td>');	// Mandator
		var mndInfo = $.trim(data['mandatorEmployeeName']);
		if(mndInfo != '') {
			// 직위
			if($.trim(data['mandatorPositionName']) != '') {
				mndInfo += ' / ' + $.trim(data['mandatorPositionName']);
			} else {
				mndInfo += ' / ' + $.trim(data['mandatorTitleName']);
			}
			// 부서
			mndInfo += ' / ' + $.trim(data['mandatorDepartmentName']);
		}
		td4.html(mndInfo);
		var mnp1 = $('<input type="hidden" name="mandatorUserId"/>');
		mnp1.val($.trim(data['mandatorUserId']));
		td4.append(mnp1);
		var mnp2 = $('<input type="hidden" name="mandatorEmployeeNo"/>');
		mnp2.val($.trim(data['mandatorEmployeeNo']));
		td4.append(mnp2);
		var td5 = $('<td></td>');	// Status
		td5.addClass('text-center');
		td5.html($.trim(data['approvalStatusName']));
		var td6 = $('<td></td>');	// Date
		td6.addClass('text-center');
		td6.html($.trim(data['approvalDate']));
		var td7 = $('<td></td>');	// Comment
		td7.html($.trim(data['approvalComment']));
		var td8 = $('<td></td>');	// Button
		var btn1 = $('<button type="button" class="icon-plus" role="button"></button>');
		btn1.click(function() {
			fncSearchApprover('A',$(this).closest('tr').data('idx'));
		});
		td8.append(btn1);
		if($.trim(data['settlementDeleteFlag']) != 'Y') {
			var btn2 = $('<button type="button" class="icon-trash" role="button"></button>');
			btn2.click(function() {
				$(this).closest('tr').remove();
				fncResetApprovalSeq();
			});
			td8.append(btn2);
		}
		tr.append(td1).append(td2).append(td3).append(td4).append(td5).append(td6).append(td7).append(td8);
		if(type == 'P') {
			_tableBody.prepend(tr);
		} else if(type == 'A') {
			if(ridx == -1) {
				_tableBody.append(tr);
			} else {
				tr.insertAfter(_tableBody.find("tr[data-idx='"+ridx+"']"));
			}
		}
		$(_tableBody).find('tr').each(function(idx) {
			$(this).attr('data-idx',idx);
		});
		fncResetApprovalSeq();
	}
	// 결재차수 세팅
	function fncResetApprovalSeq() {
		var _tableBody = myForm.select('.approverBlock>form._approverForm>table>tbody');
		var approw = _tableBody.find('tr');
		//화면에서의 Seq 값 세팅
		var prevAction = '';
		var currSeq = 0;
		$(approw).each(function(inx) {
			$(this).attr('data-row-index',inx);
			var approveAction = $(this).find("td:nth-child(2) select>option:selected").val();
			if($.trim(approveAction) == '') {
				approveAction = $(this).find("input[name='approvalActionCode']").val();
			}
			if(approveAction == 'APPROVAL' || approveAction == 'AGREEMENT') {
				// 결재유형이 승인 또는 합의이면
				$(this).find("td:nth-child(1)>span[name='seq']").text(currSeq+1);
				$(this).find("td:nth-child(1)>input[name='approvalSeqs']").val(currSeq+1);
				prevAction = approveAction;
				currSeq++;
			} else if(approveAction != prevAction) {
				// 직전과 결재유형이 다르면
				$(this).find("td:nth-child(1)>span[name='seq']").text(currSeq+1);
				$(this).find("td:nth-child(1)>input[name='approvalSeqs']").val(currSeq+1);
				prevAction = approveAction;
				currSeq++;
			} else {
				$(this).find("td:nth-child(1)>span[name='seq']").text(currSeq);
				$(this).find("td:nth-child(1)>input[name='approvalSeqs']").val(currSeq);
			}
		});
	}
	// 결재자 검색 팝업
	function fncSearchApprover(mode,ridx) {
		if(ridx == undefined) ridx = -1;
		myForm.popupInfo.userPopup = null;
		myForm.popupInfo.userPopup = {};
		myForm.popupInfo.userPopup['searchMode'] = 'single';
		var popup = new Popup(myForm,'lgcom','M_LGUTLC_1142',Message.APPROVER_POPUP);
		popup.setSize(800,494);	// searchMode 'Single'
		popup.open(function() {
			var result = myForm.popupInfo.userPopup.userData;
			if(result && result.length == 1) {
				var item = {
					applicationUserId: $.trim(result[0]['userId']),
					departmentName: $.trim(result[0]['departmentName']),
					positionName: $.trim(result[0]['positionName']),
					titleName: $.trim(result[0]['titleName']),
					employeeNo: $.trim(result[0]['employeeNo']),
					employeeName: $.trim(result[0]['employeeName']),
					settlementDeleteFlag: 'N'
				};
				// 위임 정보 조회
				transaction_sync(CONTEXT_PATH,'common/requestForm/retrievePortalMandatorInfo',item,function(data) {
					if(data.result) {
						var _result = data.result;
						item = {
							applicationUserId: $.trim(_result['applicationUserId']),
							departmentName: $.trim(_result['departmentName']),
							positionName: $.trim(_result['positionName']),
							titleName: $.trim(_result['titleName']),
							employeeNo: $.trim(_result['employeeNo']),
							employeeName: $.trim(_result['employeeName']),
							settlementDeleteFlag: 'N',
							approvalLineId: $.trim(_result['approvalLineId']),
							mandatorUserId: $.trim(_result['mandatorUserId']),
							mandatorEmployeeNo: $.trim(_result['mandatorEmployeeNo']),
							mandatorEmployeeName: $.trim(_result['mandatorEmployeeName']),
							mandatorDepartmentName: $.trim(_result['mandatorDepartmentName']),
							mandatorPositionName: $.trim(_result['mandatorPositionName']),
							mandatorTitleName:$.trim(_result['mandatorTitleName'])
						};
						fncAddApprover(mode,ridx,item);
					}
				});
			}
		});
	}
	// 참조자 추가
	function fncAddReferrer(item) {
		var _tableBody = myForm.select('.referrerBlock>form._referrerForm>table>tbody');
		//이미 이 안에 추가된 경우에는 추가하지 않고 끝
		if(_tableBody.find("input[name='applicationUserId'][value='" + item["applicationUserId"] + "']").exists()) {
			Message.alert($.trim(item['employeeName']) + ' is already a selected ' + Message.CARBONCOPY_POPUP + '.');
			return;
		}
		var tr = $('<tr></tr>');
		var td1 = $('<td></td>');		// Seq
		td1.addClass('text-center');
		var spn = $('<span name="seq"></span>');
		td1.append(spn);
		var td2 = $('<td></td>');		// Name
		var ipt1 = $('<input type="hidden" name="applicationUserId"/>');
		ipt1.val($.trim(item['applicationUserId']));
		var ipt2 = $('<input type="hidden" name="employeeNo"/>');
		ipt2.val($.trim(item['employeeNo']));
		var refrInfo = $.trim(item['employeeName']);
		if(refrInfo != '') {
			// 직위
			if($.trim(item['positionName']) != '') {
				refrInfo += ' / ' + $.trim(item['positionName']);
			} else {
				refrInfo += ' / ' + $.trim(item['titleName']);
			}
			// 부서
			refrInfo += ' / ' + $.trim(item['departmentName']);
		}
		td2.html(refrInfo);
		td2.append(ipt1).append(ipt2);
		var td3 = $('<td></td>');		// Check Date
		td3.addClass('text-center');
		td3.html($.trim(item['approvalDate']));
		var td4 = $('<td></td>');		// Button
		var btn1 = $('<button type="button" class="icon-plus" role="button"></button>');
		btn1.click(function() {
			fncSearchReferrer('A',$(this).closest('tr').data('idx'));
		});
		var btn2 = $('<button type="button" class="icon-trash" role="button"></button>');
		btn2.click(function() {
			$(this).closest('tr').remove();
			fncResetCarbonCopySeq();
		});
		td4.append(btn1).append(btn2);
		tr.append(td1).append(td2).append(td3).append(td4);
		_tableBody.append(tr);
		$(_tableBody).find('tr').each(function(idx) {
			$(this).attr('data-idx',idx);
		});
		fncResetReferrerSeq();
	}
	// 결재차수 세팅
	function fncResetReferrerSeq() {
		var approw = myForm.select('.referrerBlock>form._referrerForm>table>tbody>tr');
		$(approw).each(function(inx) {
			$(this).find("td:nth-child(1)>span[name='seq']").text((inx+1));
		});
	}
	// 참조자 검색 팝업
	function fncSearchReferrer(type,ridx) {
		myForm.popupInfo.userMultiPopup = null;
		myForm.popupInfo.userMultiPopup = {};
		myForm.popupInfo.userMultiPopup['keyType']  = 'applicationUserId';	// applicationUserId 또는 userName(사번)
		myForm.popupInfo.userMultiPopup['keyValue'] = '';
		var popup = new Popup(myForm,'lgcom','M_LGSYSC_1150','<lgcom:message code="Referrers"/>');
		popup.setSize(1000,528);
		popup.open(function() {
			var _list = myForm.popupInfo.userMultiPopup['userList'];
			if(_list) {
				$(_list).each(function(idx) {
					var item = {
						applicationUserId: $.trim(this['userId']),
						employeeNo: $.trim(this['employeeNo']),
						employeeName: $.trim(this['employeeName']),
						positionName: $.trim(this['positionName']),
						titleName: $.trim(this['titleName']),
						departmentName: $.trim(this['departmentName'])
					};
					fncAddCarbonCopy(item);
				});
			}
		});
	}
	// 요청서 정보를 취합한다.
	function fncGetRequestInfo() {
		var param = {};
		// 요청기본정보(요청자 정보 포함)
		param['requestorInfo'] = requestorForm.getValue();
		// 결재자 정보
		var apprTemp = approverForm.getValue();
		var apprData = [];
		$(apprTemp.applicationUserId).each(function(inx) {
			var approver = {
				approvalActionCode: $.trim(apprTemp.approvalActionCode[inx]),
				approvalSeqs: $.trim(apprTemp.approvalSeqs[inx]),
				applicationUserId: $.trim(apprTemp.applicationUserId[inx]),
				employeeNo: $.trim(apprTemp.employeeNo[inx]),
				mandatorUserId: $.trim(apprTemp.mandatorUserId[inx]),
				mandatorEmployeeNo: $.trim(apprTemp.mandatorEmployeeNo[inx]),
				approvalLineId: $.trim(apprTemp.approvalLineId[inx]),
				settlementDeleteFlag: $.trim(apprTemp.settlementDeleteFlag[inx]),
			};
			apprData.push(approver);
		});
		param['approverInfo'] = apprData;
		// 전달자 정보
		var refrTemp = referrerForm.getValue();
		var refrData = [];
		$(refrTemp.applicationUserId).each(function(inx) {
			var referrer = {
				applicationUserId: $.trim(refrTemp.applicationUserId[inx]),
				employeeNo: $.trim(refrTemp.employeeNo[inx])
			};
			refrData.push(referrer);
		});

		param['referrerInfo'] = refrData;
		return param;
	}
	// 요청서 화면 ReadOnly 모드 처리
	function fncSetReadOnlyMode(flag) {
		if(flag) {
			// 요청자 정보
			myForm.select('.requestorBlock').find('input,select').prop('disabled',true);
			myForm.select('.requestorBlock').find('button').hide();
			// 요청내용
			myForm.select('.customContent').find('input,select').prop('disabled',true);
			myForm.select('.customContent').find('button').hide();
			// 결재자
			myForm.select('.approverBlock').prev().find('button').hide();
			myForm.select('.approverBlock').find('input,select').prop('disabled',true);
			myForm.select('.approverBlock').find('button').hide();
			myForm.select(".approverBlock table thead tr th").each(function(inx) {
				if(inx == 7) {
					$(this).hide();
				} else {
					$(this).show();
				}
			});
			myForm.select(".approverBlock table tbody tr").each(function() {
				$(this).find('td').each(function(inx) {
					if(inx == 7) {
						$(this).hide();
					} else {
						$(this).show();
					}
				});
			});
			// 참조자
			myForm.select('.referrerBlock').prev().find('button').hide();
			myForm.select('.referrerBlock').find('input,select').prop('disabled',true);
			myForm.select('.referrerBlock').find('button').hide();
			myForm.select(".referrerBlock table thead tr th").each(function(inx) {
				if(inx == 3) {
					$(this).hide();
				} else {
					$(this).show();
				}
			});
			myForm.select(".referrerBlock table tbody tr").each(function() {
				$(this).find('td').each(function(inx) {
					if(inx == 3) {
						$(this).hide();
					} else {
						$(this).show();
					}
				});
			});
		} else {
			// 요청자 정보
			myForm.select('.requestorBlock').find('input,select').prop('disabled',false);
			myForm.select('.requestorBlock').find('button').show();
			// 요청내용
			myForm.select('.customContent').find('input,select').prop('disabled',false);
			myForm.select('.customContent').find('button').show();
			// 결재자
			myForm.select('.approverBlock').prev().find('button').show();
			myForm.select('.approverBlock').find('input,select').prop('disabled',false);
			myForm.select('.approverBlock').find('button').show();
			myForm.select(".approverBlock table thead tr th").each(function(inx) {
				if(inx == 4 || inx == 5 || inx == 6) {
					$(this).hide();
				} else {
					$(this).show();
				}
			});
			myForm.select(".approverBlock table tbody tr").each(function() {
				$(this).find('td').each(function(inx) {
					if(inx == 4 || inx == 5 || inx == 6) {
						$(this).hide();
					} else {
						$(this).show();
					}
				});
			});
			// 참조자
			myForm.select('.referrerBlock').prev().find('button').show();
			myForm.select('.referrerBlock').find('input,select').prop('disabled',false);
			myForm.select('.referrerBlock').find('button').show();
			myForm.select(".referrerBlock table thead tr th").each(function(inx) {
				if(inx == 2) {
					$(this).hide();
				} else {
					$(this).show();
				}
			});
			myForm.select(".referrerBlock table tbody tr").each(function() {
				$(this).find('td').each(function(inx) {
					if(inx == 2) {
						$(this).hide();
					} else {
						$(this).show();
					}
				});
			});
		}
	}
	// 결재진행상태명 조회
	function fncGetApprovalStatusName(approvalStatusCode) {
		var approvalStatusName = '';
		$(_code.get('approvalStatusCode')).each(function() {
			if($.trim(this['code']) == $.trim(approvalStatusCode)) {
				approvalStatusName = $.trim(this['name']);
				return false;
			}
		});
		return approvalStatusName;
	}
}

<c:out value="${param.bizFormId}"/>.prototype = new BizForm('<c:out value="${param.bizFormId}"/>');

$(document).ready( function() {
	launch(function() {
		var form = new <c:out value="${param.bizFormId}"/>();
		form.init();
		form.initForm();
	});
});
</script>
</head>

<body>
<div class="mdi-container formContainer">
  <section class="page-content">
	<div class="pageHeader">
		<h2><lgcom:message code="Request"/></h2>
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
		<div class="tab-pane fade" id="_${param.bizFormId}_tab1">
			<table class="table table-condensed guideContent" summary="">
				<colgroup>
					<col width="100"/>
					<col width="*"/>
				</colgroup>
				<tbody>
					<tr>
						<td colspan="2"><div class="contents"></div></td>
					</tr>
					<tr>
						<th><label><lgcom:message code="Attach"/></label></th>
						<td class="text-left">
							<ul class="_fileList">
								<li class="_fileItem"><a href="#">첨부파일1</a></li>
								<li class="_fileItem"><a href="#">첨부파일2</a></li>
							</ul>
						</td>
					</tr>
				</tbody>
			</table>
		</div>
		<!-- 신청서 -->
		<div class="tab-pane fade" id="_${param.bizFormId}_tab2">
			<div class="controls _requestControls"></div>
			<%-- 요청자 --%>
			<div class="module-group clearfix">
				<div class="sub-header pull-left">
					<h3><lgcom:message code="RequestInformation"/></h3>
				</div>
			</div>
			<div class="dataBlock requestorBlock">
				<form class="form _requestorForm">
					<input type="hidden" name="requestMasterId"/>
					<input type="hidden" name="requestCode"/>
					<input type="hidden" name="requestNo"/>
					<input type="hidden" name="organizationId"/>
					<input type="hidden" name="requestorId"/>
					<input type="hidden" name="requestorEmpNo"/>
					<input type="hidden" name="departmentCode"/>
					<input type="hidden" name="statusCode"/>
					<table class="table table-condensed" summary="Requestor Infomation">
						<caption class="sr-only-lgd"><lgcom:message code="RequestInformation"/></caption>
						<colgroup>
							<col width="80" />
							<col width="200"/>
							<col width="80" />
							<col width="200"/>
							<col width="80" />
							<col width="250"/>
							<col width="80" />
							<col width="*"  />
						</colgroup>
						<tbody>
							<tr>
								<th scope="row"><label><lgcom:message code="ApprovalRequestNo"/></label></th>
								<td><span data-name="requestNo" class="_labelSpan"></span></td>
								<th scope="row"><label><lgcom:message code="ApprovalRequestor"/></label></th>
								<td><span data-name="requestorInfo" class="_labelSpan"></span></td>
								<th scope="row"><label><lgcom:message code="ApprovalRequestStatus"/></label></th>
								<td><span data-name="approvalStatus" class="_labelSpan"></span></td>
								<th scope="row"><label><lgcom:message code="ApprovalRequestDate"/></label></th>
								<td><span data-name="requestDate" class="_labelSpan"></span></td>
							</tr>
							<tr>
								<th scope="row"><label class="required"><lgcom:message code="ApprovalRequestTitle"/></label></th>
								<td colspan="7"><input type="text" name="requestTitle" class="form-control input-sm" maxlength=""/></td>
							</tr>
						</tbody>
					</table>
				</form>
			</div>
			<%-- 요청내용 --%>
			<div class="customContent"></div>
			<%-- 결재자 --%>
			<div class="module-group clearfix">
				<div class="sub-header pull-left">
					<h3><lgcom:message code="ApprovalInformation"/></h3>
				</div>
				<div class="pull-right">
					<button class="btn btn-default btn-sm" data-action="apprReset"><lgcom:message code="Reset1"/></button>
					<button class="btn btn-default btn-sm ico-lgd" data-action="apprAddFirst"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="AddRowAtFirst1"/></button>
				</div>
			</div>
			<div class="dataBlock approverBlock">
				<form class="form _approverForm">
					<table class="table table-condensed table-bordered" summary="Approver Infomation">
						<caption class="sr-only-lgd"><lgcom:message code="ApprovalInformation"/></caption>
						<colgroup>
							<col width="50" />
							<col width="110"/>
							<col width="280"/>
							<col width="280"/>
							<col width="100"/>
							<col width="100"/>
							<col width="*"  />
						</colgroup>
						<thead>
							<tr>
								<th><lgcom:message code="ApprovalSeq"/></th>
								<th><lgcom:message code="ApprovalType"/></th>
								<th><lgcom:message code="ApprovalApprover"/></th>
								<th><lgcom:message code="ApprovalMandator"/></th>
								<th><lgcom:message code="ApprovalStatus"/></th>
								<th><lgcom:message code="ApprovalDate"/></th>
								<th><lgcom:message code="ApprovalComment"/></th>
								<th></th>
							</tr>
						</thead>
						<tbody></tbody>
					</table>
				</form>
			</div>
			<%-- 참조자 --%>
			<div class="module-group clearfix">
				<div class="sub-header pull-left">
					<h3><lgcom:message code="Referrers"/></h3>
				</div>
				<div class="pull-right">
					<button class="btn btn-default btn-sm" data-action="refrReset"><lgcom:message code="Reset1"/></button>
					<button class="btn btn-default btn-sm" data-action="refrAddFirst"><span class="glyphicon glyphicon-plus"></span> <lgcom:message code="AddRowAtFirst1"/></button>
				</div>
			</div>
			<div class="dataBlock referrerBlock">
				<form class="form _referrerForm">
					<table class="table table-condensed table-bordered" summary="Referrer Infomation">
						<caption class="sr-only-lgd"><lgcom:message code="Referrers"/></caption>
						<colgroup>
							<col width="100"/>
							<col width="360"/>
							<col width="150"/>
							<col width="*"  />
						</colgroup>
						<thead>
							<tr>
								<th><lgcom:message code="Seq"/></th>
								<th><lgcom:message code="Name01"/></th>
								<th><lgcom:message code="CheckDate"/></th>
								<th></th>
							</tr>
						</thead>
						<tbody></tbody>
					</table>
				</form>
			</div>
		</div>
	</div>
	</section>
</div>
</body>
</html>
