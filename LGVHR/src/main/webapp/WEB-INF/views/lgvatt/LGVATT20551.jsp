<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld"%>
<%---------------------------------------------------------
    File name : LGVATT20551.jsp
    Project name : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    Explanation : Request for swap weekly holiday - Swap holiday New&Detail
    Writer : HMS - HMS_20210703
-------------------------------------------------------------%>

<c:set var="flg_vn_line_worker_pic_user" value="N"/>
<c:set var="flg_lgd_ow" value="N"/>
<c:set var="flg_vn_att_master" value="N"/>
<c:forEach var="roles" items="${sessionScope.USER_SESSION.roleList}">
    <c:if test="${roles.systemCode=='LGVHR' && roles.moduleCode=='LGVATT' && fn:indexOf(roles.roleCode,'VN_LINE_WORK_PIC_USER')>=0 }">
        <c:set var="flg_vn_line_worker_pic_user" value="Y"/>
    </c:if>  
    <c:if test="${roles.systemCode=='LGVHR' && roles.moduleCode=='LGVATT' && fn:indexOf(roles.roleCode,'VN_ATT_MASTER_USER')>=0 }">
        <c:set var="flg_vn_att_master" value="Y"/>
    </c:if>   
</c:forEach>

<html lang="ko">
<head>
<title><lgcom:message code="label.att.requestAttendanceModification"/></title>
<script src="/lgvhr/static/js/lgvatt.js"></script>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>

<script type="text/javascript">
var LGVATT20551 = function() {
	var _this = this;
	var requestInfoForm = new FormUtil(_this, ".requestInfo");
	var requestorForm = new FormUtil(_this, "._requestHeadForm_");
	var approverForm = new FormUtil(_this, "._approverForm_");	
	
	var viewType = '${param.viewType}';
	var returnPage = '${param.returnPage}';
	var requestNo = '${param.requestNo}';
	var applicationUserId = "${param.applicationUserId}";
	var status = "${param.status}";
	var mode = isNull(viewType)?"VIEW" : viewType;
	
	var approvalCallFlag = nvl("<c:out value="${urlAddr.approval}"/>", "N");
	var isAttContract = '<c:out value="${flg_vn_line_worker_pic_user}"/>';  // 근태 담당자 여부 pic
	var isLgdOw = ('${sessionScope.LGVHR_PROJECT_SESSION.employmentCategoryCode}' === 'LGD_OW') ? 'Y':'N';
	/* 팝업용 변수 선언 */
	_this.popupInfo = {
		userPopup: {},		// 결재자
		userMultiPopup: {}	// 참조자
	};
	
	var orgList = [];
	var userList = [];
	var yyyymmList = [];
	
	var isApprovalComplete = false;
	var isHrMng = ('<c:out value="${flg_vn_att_master}"/>' == 'Y')?true:false;
	
	var isCheckOrg = function(arr, id){
		return arr.some(function(d){
			if(d.code == id){
				return true;
			}
			return false;
		})
	}
	
	var isCheckUser = function(arr, id){
		return arr.some(function(d){
			if(d.name == id){
				return true;
			}
			return false;
		})
	}
	if(status == "20"){
		$(".controls [data-type='SELFREJECT']").show();
	}else{
		$(".controls [data-type='SELFREJECT']").hide();
	}
	if(isAttContract === 'Y'){
		//기능직 근태 담당자
		_this.transaction_sync("lgvhr", "lgvatt/LGVATT20551/retrieveAttContractOrg", {employeeNo : '${sessionScope.LGVHR_PROJECT_SESSION.employeeNo}'}, function(data) {
			//trace('retrieveAttContractOrg ', data );
			if ( data.result ) {
				orgList = data.result;
				
				if(isLgdOw === 'Y'){
					if(!isCheckOrg(orgList, '${sessionScope.LGVHR_PROJECT_SESSION.organizationId}')){
						orgList.push({code:'${sessionScope.LGVHR_PROJECT_SESSION.organizationId}', name:'${sessionScope.USER_SESSION.organizationName}'});					
					}
				}
			}
		});			
		
	}else{
		orgList.push({code:'${sessionScope.LGVHR_PROJECT_SESSION.organizationId}', name:'${sessionScope.USER_SESSION.organizationName}'});		
		userList.push({name:'${sessionScope.LGVHR_PROJECT_SESSION.userName}', code:'${sessionScope.USER_SESSION.userName}', organizationId:'${sessionScope.LGVHR_PROJECT_SESSION.organizationId}'})
	} 

	var requestMasterId = isNull('<c:out value="${urlAddr.requestMasterId}"/>')?(isNull('${param.approvalRequestId}')?'':'${param.approvalRequestId}'):'<c:out value="${urlAddr.requestMasterId}"/>';
	var requestCode = isNull('<c:out value="${urlAddr.requestCode}"/>')? (isNull('${param.requestCode}')?'':'${param.requestCode}') : '<c:out value="${urlAddr.requestCode}"/>';
	

	requestorForm.setValue({'requestMasterId':requestMasterId,'requestCode':requestCode});
	
	// 화면 레이아웃 정의(결재선 셋팅 후 화면 레이아웃 확정되기 때문에 마지막에 셋팅한다.)
	_this.setLayout([		   
		{ name : "controls",      left : 0, right : 0, top : '0'  },
		{ name : "requestorInfo", left : 0, right : 0, top : "controls", height : 100 },
		{ name : "gridContent",   left : 0, right : 0, top : "requestorInfo", height : 400 },
		{ name : "approvalArea",  left : 0, right : 0, top : "gridContent", bottom : 0 }
	]);
	
    // 코드 데이터 조회(그리드 콤보 셋팅하기 위해 사용함.)
	// combo 목록 조회
	var code = new CommonCode("lgcom");
	code.add( "LGVHR_DAY_NIGHT_FLAG", {codeTypeCode:'LGVHR_DAY_NIGHT_FLAG'} );
	code.add( "LGCOM_YN_FLAG",        {codeTypeCode:'LGCOM_YN_FLAG'} );
	code.add( "workStartTm",          {codeTypeCode:'LGVHR_ATT_WORK_START_TIME'});	
	code.execute();
	

    // 그리드 초기화
    var grid = buildGrid(".modifyGrid");
    var gridView = grid.getGridBase();
    var provider = grid.getDataProvider();
    
    <%-- 결재화면 호출로직 추가 start --%>
	/* 통합결재 연동 관련 코드 */
	var approvalInfo = {
		init : function(param) {

			// 요청서 조회
			requestorForm.setValue({ requestMasterId:$.trim('<c:out value="${urlAddr.jobKeyId}"/>')
				                   , requestCode    :$.trim('<c:out value="${urlAddr.jobRequestCode}"/>')
				                   });
			fncRetrieveRequestContent();
		},
		buttons : [
			{text:'<lgcom:message code="RequestCancel"/>'        , action:'selfReject', type:'SELF_REJECT'},
			{text:'<lgcom:message code="Approval"/>'             , action:'approval'  , type:'APPROVAL'   },
			{text:'<lgcom:message code="Reject"/>'               , action:'reject'    , type:'REJECT'     },
			{text:'<lgcom:message code="Forward"/>'              , action:'forward'   , type:'FORWARD'    , visible:false},
			{text:'<lgcom:message code="Print"/>'                , action:'print'     , type:'PRINT'      , visible:false}
		],
		callback : function(action, param) {
			switch(action) {
				// 요청취소
				case 'selfReject':
					Message.confirm('<lgcom:message code="question.Cancelrequest"/>',function() {
						if(fnSelfRejectRequest('REQUESTCANCEL')) _approvalCallback( action, true);  //승인 또는 반려 처리에 대한 결과 Callback 처리
						successMessage();
					});
					break;	
				// 승인
				case 'approval':
					// 승인시 Comment 담기
					requestorForm.setValue({ approvalComment:$.trim(param.comment) });
					var returnValue = fnApprovalOrRejectRequest('approval');
					_approvalCallback(action, returnValue);  //승인 또는 반려 처리에 대한 결과 Callback 처리
					fnApprovalRequest(returnValue);
					break;
				// 반려
				case 'reject':
					// 반려시 Comment 담기
					requestorForm.setValue({ approvalComment:$.trim(param.comment) });
					var returnValue = fnApprovalOrRejectRequest('reject');
					_approvalCallback(action, returnValue);  //승인 또는 반려 처리에 대한 결과 Callback 처리
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
	_this.setApprovalInfo( approvalInfo );
    <%-- 결재화면 호출로직 추가 end --%>
    
    // 화면에 필요한 초기데이터 조회

    // 개인화조건
    
    // 조회조건 저장 처리
    _this.searchConditionControl( true );
    
    // 팝업 데이터 정의 searchMode:single(단수),multi(복수)

    // 그리드형 테이블 TR

    // 날짜 팝업창
    
    // 필수항목 체크
    
    // 일반함수	
    
	/*** 이벤트 핸들러  ***/
	// 버튼제어
	_this.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if( item.is("span") ) {
			item = $(item).closest("button");
		}
		var action = $(this).data("action");   
		
		var itemIndex = gridView.getCurrent().itemIndex;	
		
		switch(action) {			
			case 'add':
				try {
					gridView.commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				/*
				grid 한개의 로우를 추가 한다.
				*/
		        var row = [];
		        provider.insertRow(0,row);
				
				//현재 행 위치를 지정해 주어야 rowChange event 에서 readonly 행에 대한 배경색 처리가 됨.
				gridView.setCurrent({itemIndex: 0, column:'employeeName'});
				gridView.setCurrent({itemIndex: 0, column:'shiftTypeCode'});
				
				
				// 근태 담당자가 아니면 자신 셋팅 나중에 처리 하자 (현재는 인사담당자가 처리 함)
				if(isAttContract !== 'Y'){
					// 사무직이 아닐경우
					var employeeValue = {
							employeeNo   : '${sessionScope.USER_SESSION.userName}',
							employeeName : '${sessionScope.USER_SESSION.fullNameLocal}',
							organizationId   : '${sessionScope.LGVHR_PROJECT_SESSION.organizationId}',
							organizationName : '${sessionScope.USER_SESSION.organizationName}'
					}
					gridView.setValues(0, employeeValue, true);					
					fncRetrieveARMInfo(requestInfoForm.getValue("armNo"))
					
				}else{				
					
					if(provider.getRowCount() != 1){
						//2번째 행부터 생성되는 
						var cnt = grid.getDataProvider().getRowCount();
						
						for(var i=0; i < cnt-1; i++){
							gridView.setCellStyle(i, "organizationName", "unableEdit", true);
							gridView.setValue(i, "organizationName", gridView.getValue(cnt-1, "organizationName"));
						}	
					}else{
						
						gridView.setCellStyle(0, "organizationName", "editableStyle", true);
					}
					
				}
				
				var editableStyle = "editableStyle";	
				for(var i=0; i < controlColumns.editColumn.length; i++){
					gridView.setCellStyle(0, controlColumns.editColumn[i], editableStyle, true);
				}
				gridView.setFocus();
				gridView.commit( true );
				
				break;
			case 'delete':
				try {
					gridView.commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				if(provider.getRowCount() == 0){
					Message.alert('row is count 0');
					return false;
				}			
								
				provider.setOptions({softDeleting:false});//softDeleting:true인 경우 행삭제되지 않고, 행구분만 삭제로 변경되므로, 화면에서 행 삭제하기 위해 false로 변경함	
				
				if(grid.getGridBase().getCurrent().itemIndex != grid.getDataProvider().getRowCount()-1) {
					gridView.deleteSelection(true);	
				}
				
				break;
			case 'request':
				// 결재요청
				if(fncValidateSaveRequestInfo()) {
					fncSaveSwapHolidayRequest('request');
				}
				break;
			case 'goList' :
				var nav = new Navigate( _this, "lgvhr", "${param.returnPage}" );
		        nav.addNavigationCallback( function( caller ){
		            myForm.select("button[data-action=search]").trigger('click');
		        });
		        nav.goPageInCurrentDiv(false);
		        break;
			case 'selfReject':
				Message.confirm('<lgcom:message code="question.Cancelrequest"/>',function() {
					if(fnSelfRejectRequest('REQUESTCANCEL')) successMessage();
				 });	
			break;
			case 'save':
				fncSaveSwapHolidayRequest('save');
				break;
			case 'resetRows':
				var target = $(item).data("target");
				if( target == "approvalInfoTable" ) {
					_this.select( "." + target + " tbody tr.ARM_N" ).remove();
				}
				fncManageButton();
				break;
				
		    case 'insertRowTop':
				if( $(item).data( "target" ) == "approvalInfoTable" ) {
					_this.popupInfo.userPopup = { searchMode : "single"};
					var popup = new Popup( _this, "lgcom", "M_LGUTLC_1142", "Approver" );
					popup.setSize( 1000, 528 );
					popup.open( function(){
						var result = _this.popupInfo.userPopup.userData;
						if( result != undefined ) {
							if(  _this.select( "." + $(item).data( "target" ) + " tbody tr" ).length == 0  ) {
								fncAppendTableRow( $(item).data( "target" ), result[0] );
							} else {
								fncAppendTableRow( $(item).data( "target" ), result[0], _this.select( "." + $(item).data( "target" ) + " tbody tr:first-child"), -1 );
							}
						}
					});
				}
				break;
			
		    case 'addApprover' : 
		    	_this.popupInfo.userPopup = { searchMode : "single"};
				var popup = new Popup( _this, "lgcom", "M_LGUTLC_1142", "Approver" );
				popup.setSize( 1000, 528 );
				popup.open( function(){
					var result = _this.popupInfo.userPopup.userData;
					if( result != undefined ) {
						fncAppendTableRow( $(item).data( "target" ), result[0], $(item).closest("tr") );
					}
				});
				break;

			case 'deleteApprover' :
				$(item).closest("tr").remove();
				fncManageButton();
				break;
		}
	});
	/*** 내부 함수  ***/
	
	var controlColumns = {	                      
	                    	 editColumn : ["employeeNo","weeklyHoliday","workingDay","timeAttendInputReasonDesc"], /* 사용자가 입력 가능한 after 컬럼명 */
	                    	 hrmanagerColumn: [ "weeklyHoliday", "workingDay","timeAttendInputReasonDesc"]
               	            
	                    
	                     };
    // 그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(_this, gridId, {statusBar : "N"});
		var gridReadOnyBgColor = "#e9e9e9";
		grid.setPagingMode(true);

		//옵션 설정 
		grid.setOptions({
			grid: {
				softDeleting: true,
				deleteCreated: true,
				hideDeletedRows:true,
				indicator: {visible:false},
				panel: {visible:false},
				checkBar: {visible:false},
				stateBar: {visible:false},
				footer: {visible:false},
				select: 'block',
				edit: {
					insertable: true,
					appendable: true,
					updatable: true,
					deletable: true
				},
				header: {height: 25, heightFill: 'fixed', showTooltip: true},
				fixed: { colCount: 4, resizable:true }
			},
			display: { fitStyle: 'none' }
		});
		
		grid.getGridBase().setSortingOptions({
			enabled: false
		});
		
		//필드 설정
		grid.setFields(
				[
					
					{ fieldName:'organizationName'           , dataType:'text'  },
					{ fieldName:'organizationId'             , dataType:'text'  },
					{ fieldName:'employeeNo'                 , dataType:'text'  },
					{ fieldName:'employeeName'               , dataType:'text'  },
					{ fieldName:'shiftTypeCode'              , dataType:'text'  },
					{ fieldName:'weeklyHoliday'              , dataType:'text'  },
					{ fieldName:'weeklyHolidayShiftTypeCode' , dataType:'text'  },
					{ fieldName:'resultWhShiftTypeCode'      , dataType:'text'  },
					{ fieldName:'workingDay'                 , dataType:'text'  },
					{ fieldName:'workingDayShiftTypeCode'    , dataType:'text'  },
					{ fieldName:'resultNwShiftTypeCode'      , dataType:'text'  },
					{ fieldName:'timeAttendInputReasonDesc'  , dataType:'text'  },
					{ fieldName:'holidayFlag'                , dataType:'text'  }
					
				]
		);
		//컬럼 콤보 셋팅
		grid.setLookupsMultiLvl({
	                             "organizationList":{data:orgList,keyField:["code"]},
	                             "weeklyHoliday":{data:yyyymmList,keyField:["code"]},
	                             "workingDay":{data:yyyymmList,keyField:["code"]},
	                             "userList":{data:userList, keyField:["organizationId", "code"]},
// 	                             "timeAttendDetailCode":{data:valueset.get("attendanceDetailCodeList"), keyField:["attendanceCode", "code"]}
			                   });
		//컬럼 설정 
		grid.setColumns(
				[
					{	name:'organizationName',
						fieldName:'organizationName',
						width:250,
						header: {text:'<lgcom:message code="label.att.organization"/>'},
						styles: {textAlignment:'near', background:gridReadOnyBgColor},
						lookupDisplay: true,
						lookupSourceId: 'organizationList',
						lookupKeyFields: ["organizationName"],
						editor: {type:'dropDown',textReadOnly:true},						
						editable:false
					},					
					{	name:'employeeNo',
						fieldName:'employeeNo',
						width:120,
						header: {text:'<lgcom:message code="label.att.id"/>'},						
						styles: {textAlignment:'center', background:gridReadOnyBgColor},						
						editor: {type:'dropDown',textReadOnly:true},
						lookupDisplay: true,
						lookupSourceId: 'userList',
						lookupKeyFields: ["organizationName","employeeNo"],
						editable:false
					},
					{	name:'employeeName',
						fieldName:'employeeName',
						width:200,
						header: {text:'<lgcom:message code="label.att.employeeName"/>'},
						styles: {
							textAlignment:'near', 
							background:gridReadOnyBgColor,							
							},
						editable: false,						
					},
					{	name:'shiftTypeCode',
						fieldName:'shiftTypeCode',
						width:100,
						header: {text:'<lgcom:message code="label.att.shiftType"/>'},
						styles: {textAlignment:'near', background:gridReadOnyBgColor},
						editable: false
					},
					{	name:'workingDay',
						fieldName:'workingDay',
						width:120,
						header: {text:'<lgcom:message code="label.att.workingDay"/>'},
						styles: {textAlignment:'center', background:gridReadOnyBgColor},						
						editor: {type:'date',datetimeFormat:'dd/MM/yyyy'},
						editable: false,
					},
					{	name:'workingDayShiftTypeCode',
						fieldName:'workingDayShiftTypeCode',
						width:150,
						header: {text:'<lgcom:message code="label.att.workingDayShiftType"/>'},
						styles: {textAlignment:'center', background:gridReadOnyBgColor},
						editable: false
					},
					{	name:'resultNwShiftTypeCode',
						fieldName:'resultNwShiftTypeCode',
						width:0,
						header: {text:'<lgcom:message code="label.att.weeklyHolidayShiftType"/>'},
						styles: {textAlignment:'center', background:gridReadOnyBgColor},
						editable: false
					},
					{	name:'weeklyHoliday',
						fieldName:'weeklyHoliday',
						width:120,
						header: {text:'<lgcom:message code="label.att.weeklyHoliday"/>'},
						styles: {textAlignment:'center', background:gridReadOnyBgColor},						
						editor: {type:'date',datetimeFormat:'dd/MM/yyyy'},
						editable: false,
					},
					{	name:'weeklyHolidayShiftTypeCode',
						fieldName:'weeklyHolidayShiftTypeCode',
						width:180,
						header: {text:'<lgcom:message code="label.att.weeklyHolidayShiftType"/>'},
						styles: {textAlignment:'center', background:gridReadOnyBgColor},
						editable: false
					},
					{	name:'resultWhShiftTypeCode',
						fieldName:'resultWhShiftTypeCode',
						width:0,
						header: {text:'<lgcom:message code="label.att.weeklyHolidayShiftType"/>'},
						styles: {textAlignment:'center', background:gridReadOnyBgColor},
						editable: false
					},
					{	name:'timeAttendInputReasonDesc',
						fieldName:'timeAttendInputReasonDesc',
						width:350,
					    renderer: {showTooltip: true},
						header: {text:'<lgcom:message code="label.att.timeAttendInputReasonDesc"/>'},
						styles: {textAlignment:'near', background:gridReadOnyBgColor},
						editable: false,
					},
				]
		);
		
		// Context Menu Set
		grid.setContextMenu();
		//그리드 필수값 체크
		return grid;
	}
	grid.getGridBase().addCellStyle("readOnlyStyle", {editable:false, background:"#e9e9e9"}, true);/* 수정불가능한 경우 배경색을 구분해서 보여줘야 함 */
	grid.getGridBase().addCellStyle("editableStyle", {editable:true, background:"#FFFFFF"}, true);/* 사용자가 입력하는 경우 사용할 스타일. 수정 가능해야하고, 배경색도 수정 가능한 상태로 보여줘야 함 */
	grid.getGridBase().addCellStyle("apprEditableStyle", {editable:false, background:"#FFFFFF"}, true);/* 결재자 화면인 경우 사용할 스타일. 수정은 불가능해야하지만 배경색은 수정 가능한 상태로 보여줘야 함 */
	grid.getGridBase().addCellStyle("unableEdit", {
		background: '#e9e9e9',
		editor: {type: 'text'},
		editable: false
	});
	
	gridView.setEditOptions({commitLevel:"info"});
	
	grid.getGridBase().onCurrentRowChanged = function (grid, oldRow, newRow) {
		var columns = grid.getColumnNames();
	};
	
	//날짜 셀 클릭 시 수정 가능여부를 판단한다.
	grid.getGridBase().onDataCellClicked =  function (cgrid, index) {
		var itemIndex = cgrid.getCurrent().itemIndex;
		var clickedFieldName = index.column;
	};
   
    gridView.onEditChange = function (grid, index, value) {
    	var itemIndex = index.itemIndex
	    if(index.fieldName == "employeeNo"){
	    	try {
	        	grid.commit();
	        } catch(e) {
	            trace(e.message);
	        }
	    	//trace('emp :', gridView.getValue(itemIndex, 'employeeNo'));
	    	
	    }else if(index.fieldName == 'organizationName'){
	    	try {
	        	grid.commit();
	        } catch(e) {
	            trace(e.message);
	        }
	    }

	};
	
    gridView.onEditCommit = function(grid, index, oldValue, newValue){
    	
    }
    
    gridView.onCellEdited = function(grid, itemIndex, dataRow, field){
    	grid.commit();
    	
    	var fieldName = provider.getOrgFieldName(field);
    	if(fieldName === 'weeklyHoliday'){
    		for(var i=0; i<grid.getDataProvider().getRowCount(); i++) {
    			if((grid.getValue(itemIndex, fieldName) == grid.getValue(i, fieldName) && i != itemIndex) && 
    					(grid.getValue(itemIndex, 'employeeNo') == grid.getValue(i, 'employeeNo') && i != itemIndex)) {
    				Message.alert("<lgcom:message code='note.att.dupUser'/>");
    				grid.setValue(itemIndex, fieldName, null);
    				return;
    			}
    		}
    		fncWeeklyHolidayChage(grid, itemIndex, fieldName);
    	}else if(fieldName === 'workingDay'){
    		for(var i=0; i<grid.getDataProvider().getRowCount(); i++) {
    			if((grid.getValue(itemIndex, fieldName) == grid.getValue(i, fieldName) && i != itemIndex) && 
    					(grid.getValue(itemIndex, 'employeeNo') == grid.getValue(i, 'employeeNo') && i != itemIndex)) {
    				Message.alert("<lgcom:message code='note.att.dupUser'/>");
    				grid.setValue(itemIndex, fieldName, null);
    				return;
    			}
    		}
    		fncWeeklyHolidayChage(grid, itemIndex, fieldName);
    	}else if(fieldName === 'employeeNo'){
    		fncRetrieveEmployeeName(itemIndex);
    	}else if(fieldName === 'organizationName'){    		
    		fncRetrieveEmployeeNo(itemIndex);
    	} 
    	
    }
    
    var fncRetrieveEmployeeNo = function(itemIndex){
    	gridView.setValue(itemIndex, 'employeeNo','');
    	gridView.setValue(itemIndex, 'employeeName','');

    	for(var i=0; i<grid.getDataProvider().getRowCount()-1; i++) {
    		gridView.setValue(i, "organizationName", gridView.getValue(itemIndex, "organizationName"));
    		gridView.setValue(i, 'employeeNo','');
        	gridView.setValue(i, 'employeeName','');
    	}
    	_this.showProgress()
    	_this.transaction("lgvhr", "lgvatt/LGVATT20551/retrieveEmployeeNo", {orgId: gridView.getValue(itemIndex, 'organizationName')}, function(data){
//     		trace('retrieveEmployeeNo ', data);
    		if(data.result.length > 0){
    			var lookups = data.result.map(function(d){
    				return [d.organizationId, d.code, d.code ];
    			});
    			
    			gridView.fillLookupData("userList", {
                    rows: lookups
                });
    			
    			fncRetrieveARMInfo(requestInfoForm.getValue("armNo"), data.result[0].orgGetArmInfo);
    		}
    		_this.hideProgress();
    	});
    }
    
    var fncRetrieveEmployeeName = function(itemIndex){
    	_this.transaction("lgvhr", "lgvatt/LGVATT20551/retrieveEmployeeName", {employeeNo: gridView.getValue(itemIndex, 'employeeNo')}, function(data){
//     		trace('retrieveEmployeeName ', data);
    		if(data.result){
    			gridView.setValue(itemIndex, 'employeeName', data.result.employeeName);
    			gridView.setValue(itemIndex, 'shiftTypeCode', data.result.shiftTypeCode);
    		}
    	});
    }    
	
	function fncWeeklyHolidayChage(grid, itemIndex, fieldName){
		
		var weeklyHoliday = gridView.getValue(itemIndex,'weeklyHoliday');		
		var employeeNo = gridView.getValue(itemIndex, 'employeeNo');
		var workingDay = gridView.getValue(itemIndex, 'workingDay');
		
		if (isNull(employeeNo) ) {
			gridView.setValue(itemIndex, 'workingDay', null);
			gridView.setValue(itemIndex, 'weeklyHoliday', null);
			Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.id'/>"/>');
			return false;
		}
		if (!isNull(workingDay) && !isNull(weeklyHoliday)) {
			if (workingDay.substring(10,3) != weeklyHoliday.substring(10,3)) {
				gridView.setValue(itemIndex, 'workingDay', null);
				gridView.setValue(itemIndex, 'weeklyHoliday', null);
				
				Message.alert("<lgcom:message code='label.att.mustChooseSameMonth'/>");
			} else {
			
			var dateArr = [];
			var startDate = '';
			var endDatte = '';
			var paramDate = {
					subsidiaryCode : '${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}',
					weeklyHoliday : weeklyHoliday, 
					workingDay : workingDay,
					employeeNo : employeeNo
				};
			transaction_sync("lgvhr", "lgvatt/LGVATT20552/checkLockDate", paramDate, function(data) {
				if (data.result.length > 0) {
					gridView.setValue(itemIndex, 'workingDay', null);
					gridView.setValue(itemIndex, 'weeklyHoliday', null);
					Message.alert("<lgcom:message code="note.att.attendanceDateLocked"/>" + " or " + "<lgcom:message code="note.att.existRequest"/>");
					return;
				}
			}); 
			_this.showProgress();
			transaction_sync("lgvhr", "lgvatt/LGVATT20551/checkWorkingTime", paramDate, function(data) {
				startDate = data.result.startDate;
				endDatte = data.result.endDate;
				gridView.setValue(itemIndex, 'workingDayShiftTypeCode', data.result.workingDayShiftTypeCode);
				gridView.setValue(itemIndex, 'weeklyHolidayShiftTypeCode', data.result.weeklyHolidayShiftTypeCode);
				_this.hideProgress();
			}); 
			
			for(var i=0; i<grid.getDataProvider().getRowCount(); i++) {
    			if(!isNull(grid.getValue(i, 'workingDay')) && i != itemIndex && grid.getValue(itemIndex, 'employeeNo') == grid.getValue(i, 'employeeNo')) {
    				var nwDay =  grid.getValue(i, 'workingDay');
    				var formatNW = nwDay.substring(10,6) + nwDay.substring(5,3) + nwDay.substring(2,0);
    				var whDay =  grid.getValue(i, 'weeklyHoliday');
    				var formatWH = whDay.substring(10,6) + whDay.substring(5,3) + whDay.substring(2,0);
    				//Check all the swap requests which in the grid view to find the first WH day-consider it as the end date of that period
    				if (formatWH == startDate) {
    					transaction_sync("lgvhr", "lgvatt/LGVATT20551/retrieveSwapdate", {subsidiaryCode : '${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}',weeklyHoliday: startDate,employeeNo : employeeNo, type: 'START_DATE'}, function(data) {
    						startDate = data.result.swapDate;
    						_this.hideProgress();
    					}); 
    				}
    				//Check all the swap requests which in the grid view to find the last WH day-consider it as the end date of that period
    				if (formatWH == endDatte) {
    					transaction_sync("lgvhr", "lgvatt/LGVATT20551/retrieveSwapdate", {subsidiaryCode : '${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}',weeklyHoliday: endDatte,employeeNo : employeeNo, type: 'END_DATE' }, function(data) {
    						endDatte = data.result.swapDate;
    						_this.hideProgress();
    					}); 
    				}
    				if (formatNW >= startDate && formatNW <= endDatte) {
    					dateArr.push(formatNW);
    				}
    			}
    		}
			
			dateArr.push(startDate);
			dateArr.push(endDatte);
			
			var workingDayfm = workingDay.substring(10,6) + workingDay.substring(5,3) + workingDay.substring(2,0);
			if (workingDayfm < Math.max.apply(null, dateArr)) {
				dateArr.push(workingDayfm)
			}
			//Sắp xếp theo thứ tự từ nhỏ đến lớn
			dateArr.sort();
			//Duyệt chuỗi ngày WH để tính khoảng cách giữa các ngày WH với nhau
			for (var i = 0; i < dateArr.length - 1; i++) {
			    var pattern = /(\d{4})(\d{2})(\d{2})/;
			    var fromD = new Date(dateArr[i].replace(pattern,'$1-$2-$3'));
			    var toD = new Date(dateArr[i+1].replace(pattern,'$1-$2-$3'));
			    if((toD.getTime() - fromD.getTime()) / 86400000 > 7) {
				gridView.setValue(itemIndex, 'workingDay', null);
				gridView.setValue(itemIndex, 'weeklyHoliday', null);
				Message.alert("<lgcom:message code="label.att.workingTimeNotMoreThan7Days"/>" + "! "+fromD.toLocaleDateString("vi-VN")+" ~ "+ toD.toLocaleDateString("vi-VN"));
			}
			}
			
			}
		}
		var workCode = '';
		if (fieldName == 'weeklyHoliday') {
			workCode = 'WH';
			attendanceDate = weeklyHoliday;
		} else {
			workCode = 'NW';
			attendanceDate = workingDay;
		}
		var param = {
			subsidiaryCode : '${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}',
			attendanceDate : attendanceDate, 
			employeeNo : employeeNo,
			workCode : workCode
		};
		
		_this.showProgress();
		transaction_sync("lgvhr", "lgvatt/LGVATT20551/checkAttendanceDate", param, function(data) {
			if(data.result.count <= 0) {
				gridView.setValue(itemIndex, 'workingDay', null);
				gridView.setValue(itemIndex, 'weeklyHoliday', null);
				if (fieldName == 'weeklyHoliday') {
					Message.alert("<lgcom:message code='label.att.mustChooseWeeklyHoliday'/>");
				} else {
					Message.alert("<lgcom:message code='label.att.mustChooseWorkingDay'/>");
				}
			}
			_this.hideProgress();
		}); 
		
	}
	
	/* 그리드 특정 행의 값을 모두 지우는 함수 */
	function fncClearGridRow( itemIndex, provider ) {
		var fieldNames = provider.getOrgFieldNames();
		if ( itemIndex > -1 && itemIndex < provider.getRowCount() ) {
			for ( var i=0; i<fieldNames.length; i++ ) {
				// Old, New 구분 컬럼을 제외하고 공백으로 초기화 
				if ( controlColumns["oldNewTypeColumn"].indexOf(fieldNames[i]) == -1 ) {
					if ( fieldNames[i] == "eveningMealFlag" ) {//석식여부는 기본값을 N으로 한다.
						provider.setValue(itemIndex, fieldNames[i], "N");
					} else {
						provider.setValue(itemIndex, fieldNames[i], null);
					}
				}
			}//end-for
		}//end-if
	}
	//값 초기화
	
	//공통의 결재자 정보 조회 기능 사용
	function fncRetrieveApprovalLineList() {
		_this.showProgress();
		transaction_sync("lgvhr",'common/requestForm/retrieveApprovalLineList', {requestMasterId:approvalRequestId, requestCode:requestCode}, function(data) {
			if(data.result) {
				var list = data["result"];			
				_this.select(".approvalInfoTable tbody").empty();
				$(list).each( function(){
					this["settlementDeleteFlag"] = "Y";
					fncAppendTableRow( "approvalInfoTable", this );
				});
			}
			_this.hideProgress();
		});
	}
	//재량권 조회
	function fncRetrieveARMInfo( armNo, orgGetArmInfo ) {
		/* 재랑권 정보 조회. parameter[armNo:재량권번호]  */
		
		var param = {};
		var itemIndex = gridView.getCurrent().itemIndex;
		fncRetrieveEmployeeName(itemIndex);
		
		if(orgGetArmInfo != null) {
			param.employeeNo = orgGetArmInfo;
		} else {
			if(provider.getRowCount() > 0){
				param.employeeNo = gridView.getValue(itemIndex, 'employeeNo');
			}else{
				param.employeeNo = '${sessionScope.LGVHR_PROJECT_SESSION.employeeNo}';
			}
		}
		param.createBy = '${sessionScope.LGVHR_PROJECT_SESSION.employeeNo}';
		param.armNo = armNo;
		
		_this.transaction("lgvhr", "lgvatt/LGVATT20551/retrieveARMInfoWithHRPartLD", param , function( data ){
			var list = data["result"];			
			_this.select(".approvalInfoTable tbody").empty();
			$(list).each( function(){
				this["settlementDeleteFlag"] = "Y";
				fncAppendTableRow( "approvalInfoTable", this );
			});
		});
	}
	//행추가
	function fncAppendTableRow( target, item, appendTarget, direction ) {
		if( direction == undefined ) {
			direction = 1;
		}

		var disabled = "";
		if(  mode == "VIEW" ) {
			disabled = "disabled";
		}

		var userName = item["employeeName"] + " / " + nvl(item["titleName"]) + " / " +item["departmentName"] ;
		var mendator = nvl( item["mendatorEmployeeName"] ) + " / " + nvl( nvl(item["mendatorTitleName"]) ) + " / " + nvl( item["mendatorDepartmentName"] ) ;

		if( mendator.trim() == "/  /" ) {
			mendator = "";
		}

		if( item["settlementDeleteFlag"] == undefined ) {
			item["settlementDeleteFlag"] = "N";
		}

		if( target == "approvalInfoTable" ) {
			var body = _this.select(".approvalInfoTable tbody");
			//이미 이 안에 추가된 경우에는 추가하지 않고 끝
			if( body.find("input[name='applicationUserId'][value='" + item["userId"] + "']").exists() ) {
				Message.alert( item["employeeName"] + "<lgcom:message code="note.accountAlreadyExists"/>" );
				return;
			}
			
			var selectText = "<lgcom:message code="label.att.approval"/>";
			selectText    += "<input type='hidden' name='approvalActionCode' value='APPROVAL' />";

			var str = "<tr class='ARM_"+ item["settlementDeleteFlag"] +"'>"+
			          "<td class='text-center'>" + ( $(body).find("tr").length + 1 ) + "</td>"+
			          "<td class='text-center'>"+ selectText +"</td>"+
			          "<td>"+ userName +
			          "<input type='hidden' name='applicationUserId' value='"+ item["employeeId"] +"' />"+
			          "<input type='hidden' name='positionName' value='"+ nvl(item["positionName"]) +"' />"+
			          "<input type='hidden' name='lineType' value='APPROVER' />"+
			          "<input type='hidden' name='employeeNo' value='"+ item["employeeNo"] +"' />"+
			          "<input type='hidden' name='settlementDeleteFlag' value='"+ item["settlementDeleteFlag"] +"' />"+
			          "</td>"+
			          "<td>"+ mendator + " <input type='hidden' name='menDatorApplicationUserId' value='"+ nvl(item["mandatorUserId"]) +"' /><input type='hidden' name='menDatorAemployeeNo' value='"+ nvl(item["mandatorEmployeeNo"]) +"' /></td>"+
			          "<td>"+
			          "<button class='icon-plus pointer' data-action='addApprover' data-target='approvalInfoTable'></button>";
			
				if(item["settlementDeleteFlag"] == 'N') {
					str += "<button class='icon-trash pointer' data-action='deleteApprover' data-target='approvalInfoTable'></button>"+
							"</td>"+
							"</tr>";
				} else {
					str += "</td>"+
							"</tr>";
				}


			if( appendTarget == undefined ) {
				body.append( str );
			} else {
				if( direction < 0 ) {
					$(str).insertBefore( appendTarget );
				} else {
					$(str).insertAfter( appendTarget );
				}
			}
		} 
		fncManageButton();
	}
	/* Delete 버튼 류는 필요한 시점이 아니면,  Disabled 돼야 하는 상황이라, table 에 기반한 이 버튼의 움직임을 */
	function fncManageButton() {
		_this.select(".approvalInfoTable tbody tr:first-child .delete").hide();

		if( _this.select(".approvalInfoTable tbody tr").length > 1 ) {
			_this.select(".approvalInfoTable .delete").show();
		}
	}
	//요청전 입력값 체크
	function fncValidateSaveRequestInfo() {
		var dataProvider = grid.getDataProvider();
		var cgrid = grid.getGridBase();					
		
		//행추가로 강제 생성된 행이기 때문에 행 상태는 created
		var rowIdxs = dataProvider.getStateRows("created");
		if ( rowIdxs ) {
			for ( var i=0; i<rowIdxs.length; i++ ) {
				var rowData = dataProvider.getJsonRow(rowIdxs[i]);
				//사원 선택 없는 경우 오류
				if ( isNull(rowData["employeeName"]) ) {
					Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.id'/>"/>');
					cgrid.setCurrent({itemIndex: rowIdxs[i], column:'employeeNo'});
					cgrid.setFocus();
					return false;
				}
				
				//date 선택 없는 경우 오류
				if ( isNull(rowData["weeklyHoliday"]) ) {
					Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.date'/>"/>');
					cgrid.setCurrent({itemIndex: rowIdxs[i], column:'weeklyHoliday'});
					cgrid.setFocus();
					return false;
				} 
				if ( isNull(rowData["workingDay"]) ) {
					Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.date'/>"/>');
					cgrid.setCurrent({itemIndex: rowIdxs[i], column:'workingDay'});
					cgrid.setFocus();
					return false;
				} 
			}
		}
		return true;
	}
	
	// 요청처리
	/*
		그리드 데이터 체크 
		요청 정보 같이 파라미터로 보낸다.
	*/
	function fncSaveSwapHolidayRequest(requestType){
		try {
			grid.getGridBase().commit();
		} catch(e) {
			Message.alert(e.message);
			return;
		}
		
		// 데이터 유무 체크		
		// 변경건이 있는지 체크
		if( !grid.isChanged() ) {
			Message.alert('<lgcom:message code="error.noChangedData"/>');
			return;
		}else{
			if( grid.getRowCount() == 0 ) {
				Message.alert('<lgcom:message code="note.nodata"/>');
				return;
			}
		}
		
		//결재자 체크
		if(requestType == 'request'){
			if( _this.select(".approvalInfoTable tr.ARM_Y").length == 0 ) {
				Message.alert("<lgcom:message code="note.checkApprovalInformation"/>");
				return;
			}	
		}
		
		var param = {
				requestorData : requestorForm.getValue(),
				approvalData : fncArrangeMultiLine( approverForm.getValue(), "applicationUserId")
		};	
		
		var callUrl = '';
		var cMsg = ''
		if(requestType == 'request'){
			callUrl = 'lgvatt/LGVATT20551/saveApprovalRequest';
			cMsg = "<lgcom:message code="question.ApprovalRequest" />";
		}else{
// 			callUrl = 'lgvatt/LGVATT20551/saveSwapHolidayRequest';
			cMsg = "<lgcom:message code="question.att.requestSave" />"
		}
		
		Message.confirm(cMsg, function(){
			_this.showProgress();
			grid.saveChanges("lgvhr", callUrl, param, function(data){					
				Message.alert("<lgcom:message code="note.saved" />", function(){
					
					if(requestType == 'request'){
						requestorForm.clear();
						grid.clear();
						//Approval 영역의 초기상태를 두고, 모두 지운다.
						_this.select(".approvalInfoTable tbody tr").remove();
						approverForm.clear();
						
						//신규화면으로 재 셋팅
						fncRetrieveInitData();
					}else{
						grid.clear();
						//Approval 영역의 초기상태를 두고, 모두 지운다.
						_this.select(".approvalInfoTable tbody tr").remove();
						approverForm.clear();
						// 조회된 화면으로 재 셋팅
						fncRetrieveDetailInitData(); // 헤더 정보 가져온다.
						searchSwapHolidayRequest();  // 파라미터에 맞게끔 조회 한다.
					}
					
					_this.hideProgress();
				});
			});
		}, function(){
			// 취소
			_this.hideProgress();
		});
		
	}
	
	<%-- 공통 결재에서 호출되는 경우 사용함 --%>
	//결재에서 호출된경우 요청서 데이터 조회
	
	function fncRetrieveRequestContent() {
		//요청서 버튼, 요청자정보, 결재자 정보 숨김
		_this.select(".controls").hide();
		_this.select(".requestorInfo").hide();
		_this.select(".clearfix").hide();
		_this.select(".approvalArea").hide();
		
		
		_this.setLayout( [
			{ name  : "gridContent", left : 0, right : 0, top : 0, bottom : 0 },
		]);
// 		trace('requestorForm.getValue() ', requestorForm.getValue());
		_this.showProgress();
		grid.loadData("lgvhr", "lgvatt/LGVATT20551/retrieveSwapHolidayRequest", requestorForm.getValue(), function (data) {
			var editableStyle = "editableStyle";			
			if(data.result){				
				if(!isNull(viewType) && nvl(viewType) === 'NEW'){
					data.result.forEach(function(d, index){
						for(var i=0; i < controlColumns.editColumn.length; i++){
							grid.setCellStyle(index, controlColumns.editColumn[i], editableStyle, true);
						}	
					});
				}else if(isNull(viewType)){
					data.result.forEach(function(d, index){
						for(var i=0; i < controlColumns.editColumn.length; i++){
							grid.setCellStyle(index, controlColumns.editColumn[i], editableStyle, true);
						}	
					})
				}
				
				
			}
		});
		grid.getGridBase().setEditOptions({readOnly:true});//비활성화
		// 결재영역 높이 재지정
		_resizeDetailArea(_this.select('.gridContent').outerHeight(true));
		grid.getGridBase().resetSize();
		fncDetailBtnControl();
		_this.hideProgress();
	}
	
	// 결재 처리 Callback Function
	function fnApprovalOrRejectRequest(actionCode) {
		if(actionCode == 'approval'){
			var cgrid = grid.getGridBase();
			for(var i=0; i < cgrid.getItemCount(); i++) {
				if (cgrid.getValue(i,'workingDayShiftTypeCode') != cgrid.getValue(i,'resultNwShiftTypeCode')
					|| cgrid.getValue(i,'weeklyHolidayShiftTypeCode') != cgrid.getValue(i,'resultWhShiftTypeCode')) {
					Message.alert('<lgcom:message code="note.att.workScheduleChange"/> ' + cgrid.getValue(i,'employeeNo'));
					return;
				}
			}
		}
		_this.showProgress();
		var returnValue = false;
		var param = {requestMasterId : requestorForm.getValue("requestMasterId")
				   , requestCode     : requestorForm.getValue("requestCode")
				   , approvalCommand : actionCode.toUpperCase()
				   , comment         : requestorForm.getValue("approvalComment")
		             };
			
		transaction_sync("lgvhr", "lgvatt/LGVATT20551/saveRequestApprovalOrReject", param, function(data) {
			if(data.result) {
				// 정상처리
				if($.trim(data.result['errorCode']) == 'S') {
					returnValue = true;
				} else {
					returnValue = false;
				}
				_this.hideProgress();
				if(!returnValue) {
					Message.alert(data.result['errorMsg']);
				}
				return returnValue;
			}
			_this.hideProgress();
		},function(error) {
			trace(error);
			_this.hideProgress();
		});
	}
	
	// Approval Request Function
	function fnApprovalRequest(returnValue) {
		_this.showProgress();
		var param = {requestMasterId : requestorForm.getValue("requestMasterId")
				   , requestCode     : requestorForm.getValue("requestCode")
				   , approvalCommand : 'APPROVAL'
				   , comment         : requestorForm.getValue("approvalComment")
		             };
		transaction_sync("lgvhr", "lgvatt/LGVATT20551/saveRequestApproval", param, function(data) {
			_this.hideProgress();
		},function(error) {
			trace(error);
			_this.hideProgress();
		});
	}
	//Self Reject callback Function
	function fnSelfRejectRequest(actionCode) {
		_this.showProgress();
		var returnValue = false;
		var applicationUserId = "";
		
		applicationUserId = $("#applicationUserId").val();
		
		var param = {
				requestMasterId: requestorForm.getValue("requestMasterId"),
				requestCode: requestorForm.getValue("requestCode"),
				applicationUserId: applicationUserId,
				approvalCommand: $.trim(actionCode)
		};
		alert(requestorForm.getValue("requestMasterId"));
		alert(requestorForm.getValue("requestCode"));
		alert(applicationUserId);
		alert($.trim(actionCode));
		 transaction_sync("lgvhr",'lgvatt/LGVATT20551/saveSelfReject',param,function(data) {
			 
			if(data.result) {
				// 정상처리
				if($.trim(data.result['errorCode']) == 'S') {
					returnValue = true;
				} else {
					returnValue = false;
				}
				_this.hideProgress();
				if(!returnValue) {
					Message.alert(data.result['errorMsg']);
				}
				$(".controls [data-type='SELFREJECT']").hide();
			}
		},function(error) {
			trace(error);
			_this.hideProgress();
		}); 
		 return returnValue;
	}
	// Custom Button 제어 로직
	function fncControllButton() {
	}
	
	function searchSwapHolidayRequest(){
		// 상세 보기 일경우	
		var param = {
				requestNo : requestNo,
				requestMasterId : requestMasterId
		};			
		grid.loadData("lgvhr", "lgvatt/LGVATT20551/retrieveSwapHolidayRequest",param, function(data){			
			var editableStyle = "editableStyle";			
			if(data.result){				
				if(!isNull(viewType) && nvl(viewType) === 'NEW'){
					data.result.forEach(function(d, index){
						for(var i=0; i < controlColumns.editColumn.length; i++){
							grid.setCellStyle(index, controlColumns.editColumn[i], editableStyle, true);
						}	
					});
				}else if(isNull(viewType)){
					data.result.forEach(function(d, index){
						for(var i=0; i < controlColumns.editColumn.length; i++){
							grid.setCellStyle(index, controlColumns.editColumn[i], editableStyle, true);
						}	
					})
				}
				
				
			}
			
		});
	}
	
	<%-- //공통 결재에서 호출되는 경우가 아닐때 사용함 --%>
	//화면 초기데이터 조회
	function fncRetrieveInitData() {
		// 요청자및 요청상태 정보 셋팅		
		_this.showProgress();
		_this.transaction_sync("lgvhr",'common/requestForm/retrieveRequestHeadInfo',requestorForm.getValue(), function(data) {
			if(data.result) {				
				requestorForm.setValue(data.result);			
			}
			//조회 초기 셋팅, 요청서 셋팅
			_this.transaction("lgvhr", "lgvatt/LGVATT20551/retrieveInitData", requestInfoForm.getValue(), function(data) {
				if(data.result){
					var reqDocBaseInfo = data.result.reqDocBaseInfo;
					var approvalMasterData = data.result.approvalMasterData;
					
					requestInfoForm.setValue({ armNo:reqDocBaseInfo["armNo"] });
					requestorForm.setValue({ requestCode:reqDocBaseInfo["requestCode"],
											 requestTitle:approvalMasterData["requestTitle"]});
					
					// 재량권 or 결재선 셋팅
					// 요청서 ID가 없으면 재량권 조회 , 
					_this.select(".approvalInfoTable").show();
					_this.select(".approvalInfoTableView").hide();
					isNull(requestInfoForm.getValue("requestMasterId"))?fncRetrieveARMInfo(requestInfoForm.getValue("armNo")):fncRetrieveApprovalLineList();
					_this.hideProgress();
				}
			});		
		});
	}
	
	function fncDetailBtnControl(){

		_this.select('button[data-action="add"]').hide();
		_this.select('button[data-action="delete"]').hide();
		_this.select('button[data-action="request"]').hide();
		
		if(isHrMng && isApprovalComplete){			
			_this.select('button[data-action="save"]').show();
			var editableStyle = "editableStyle";
			var gCnt = provider.getRowCount();
			for(var i=0; i < gCnt; i++){
				controlColumns.hrmanagerColumn.forEach(function(d){
					gridView.setCellStyle(i, d, editableStyle, true);
				})				
			}
			
		}else{			
			_this.select('button[data-action="save"]').hide();
		}
		// 체크박스도 없앤다.
		gridView.setCheckBar({
			  visible: false  
		});
	}
	
	function fncRetrieveDetailInitData(){
		// 요청자및 요청상태 정보 셋팅		
		_this.showProgress();
		_this.transaction_sync("lgvhr",'common/requestForm/retrieveRequestHeadInfo',requestorForm.getValue(), function(data) {
			if(data.result) {				
				requestorForm.setValue(data.result);			
			}
			//조회 초기 셋팅, 요청서 셋팅
			_this.transaction("lgvhr", "lgvatt/LGVATT20551/retrieveInitData", requestInfoForm.getValue(), function(data) {
				if(data.result){
					var reqDocBaseInfo = data.result.reqDocBaseInfo;
					var approvalMasterData = data.result.approvalMasterData;
					
					requestInfoForm.setValue({ armNo:reqDocBaseInfo["armNo"] });
					requestorForm.setValue({ requestCode:reqDocBaseInfo["requestCode"],
						 					 requestTitle:approvalMasterData["requestTitle"]});
				
					
					// 재량권 or 결재선 셋팅
					// 요청서 ID가 없으면 재량권 조회 , 
					_this.select(".approvalInfoTable").show();
					_this.select(".approvalInfoTableView").hide();
					isNull(requestInfoForm.getValue("requestMasterId"))?fncRetrieveARMInfo(requestInfoForm.getValue("armNo")):fncRetrieveApprovalLineList();
					
					_this.transaction("lgvhr", "lgvatt/LGVATT20551/retrieveApprovalStatus", requestorForm.getValue(), function(data) {
// 						trace('retrieveApprovalStatus : ', data);
						isApprovalComplete = (data.result.approvedFlag === 'N')?false:true;
						fncDetailBtnControl();
					})
				}
			});
			
				
		});
	}
	
	// 화면 로드 후 실행 시작
	_this.myFormInit = function(){
		// 통합결재에서 호출될 경우가 아닐때만 초기 데이터 조회
		if(approvalCallFlag !== 'Y'){
			if(!isNull(viewType) && nvl(viewType) === 'NEW'){
				//신규 요청
				fncRetrieveInitData();
				_this.select('button[data-action="save"]').hide();
			}else if(!isNull(viewType) && nvl(viewType) === 'DETAIL_VIEW'){
				// 상세보기
				fncRetrieveDetailInitData(); // 헤더 정보 가져온다.
				searchSwapHolidayRequest();  // 파라미터에 맞게끔 조회 한다.
				
				
			}
		}else{
			_this.select('button[data-action="save"]').hide();
		}
		
		
		
		// 화면 레이아웃 정의(결재선 셋팅 후 화면 레이아웃 확정되기 때문에 마지막에 셋팅한다.)
		_this.setLayout([
			{ name : "searchBlock",   left : 0, right : 0, top : 0  },             
			{ name : "controls",      left : 0, right : 0, top : 'searchBlock'  },
			{ name : "requestorInfo", left : 0, right : 0, top : "controls", bottom : "gridContent" },
			{ name : "gridContent",   left : 0, right : 0, top : "requestorInfo", bottom : "approvalArea" },
			{ name : "approvalArea",  left : 0, right : 0, top : "gridContent", bottom : 0 }
		]);	
	}	
	
}

LGVATT20551.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVATT20551();
		form.init();
		form.myFormInit();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2><lgcom:message code="label.att.requestAttendanceModification"/></h2>
		</div>	
		<%-- 버튼 --%>
	    <div class="controls module-group text-right">	
			<div class="btn-toolbar">
				<div class="btn-group">
					<button class="btn btn-default btn-sm" type="submit" data-action="goList"><lgcom:message code="List"/></button>
				</div>	
				<div class="btn-group">					      
				<button class="btn btn-darkgray btn-sm" type="button" role="button" data-type='SELFREJECT' data-action="selfReject"><lgcom:message code="RequestCancel"/></button>
				</div>
				<div class="btn-group">					
					<button class="btn btn-darkgray btn-sm" type="button" name="request" data-action="request"><lgcom:message code="button.att.submitRequest"/></button>
					<%-- <button class="btn btn-darkgray btn-sm" type="button" name="save" data-action="save"><lgcom:message code="save"/></button> --%>
					<!-- button class="btn btn-default btn-sm" type="button" name="list" data-action="list"><lgcom:message code="list"/></button -->
				</div>
			</div>		
		</div>
		<form class="form requestInfo">
			<input type="hidden" name="requestDocCode" value="ATT0007" />
			<input type="hidden" name="armNo" value="" />
		</form>
		<!-- 요청자 정보 -->
		<div class="requestorInfo">
			<div class="sub-header">
				<h3><lgcom:message code="RequestInformation"/></h3>
			</div>
			<div>
				<form class="form _requestHeadForm_">
					<input type="hidden" name="requestMasterId" value="" />
					<input type="hidden" name="requestCode" value="" />
					<input type="hidden" name="statusCode" value="" />
					<input type="hidden" name="approvalComment"/>
					<table class="table table-condensed" summary="Request Header">
						<colgroup>
							<col width="80" />
							<col width="200" />
							<col width="80" />
							<col width="350" />
							<col width="80" />
							<col width="180" />
							<col width="80" />
							<col width="*" />
						</colgroup>
						<tbody>
							<tr>
								<th scope="row"><label><lgcom:message code="ApprovalRequestNo"/></label></th>
								<td><span name="requestNo"></span></td>
								<th scope="row"><label><lgcom:message code="ApprovalRequestor"/></label></th>
								<td><span name="requestorInfo"></span></td>
								<th scope="row"><label><lgcom:message code="ApprovalRequestStatus"/></label></th>
								<td><span name="statusName"></span></td>
								<th scope="row"><label><lgcom:message code="ApprovalRequestDate"/></label></th>
								<td><span name="requestDate"></span></td>
							</tr>
							<tr>
								<th scope="row"><label><lgcom:message code="ApprovalRequestTitle"/></label></th>
								<td colspan="7"><span name="requestTitle"></span></td>
							</tr>
						</tbody>
					</table>
				</form>
			</div>
		</div>
		<!-- 상세 정보 : 업무 화면이 위치하는 부분  -->
		<%-- 수정요청 --%>
		<div class="gridContent grid-wrap">
			<div class="module-group clearfix">
				<div class="pull-left sub-header">
					<h4><lgcom:message code="ApprovalDetailInformation" /></h4>
				</div>
				<div class="pull-right">
					<button class="btn btn-default btn-sm ico-lgd" data-action="add"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="Add"/></button>
					<button class="btn btn-default btn-sm ico-lgd" data-action="delete"><span class="fa fa-minus" aria-hidden="true"></span> <lgcom:message code="Delete" /></button>
				</div>
			</div>
			<div class="grid modifyGrid"></div>
		</div>
		<!-- 결재선 -->
		<div class="approvalArea">
			<div class="module-group clearfix">
				<div class="pull-left sub-header">
					<h3><lgcom:message code="ApprovalInformation"/></h3>
				</div>
				<div class="pull-right">
					<button type="button" class="btn btn-default btn-sm ico-lgd" data-action="resetRows" data-target="approvalInfoTable" ><lgcom:message code="Reset1"/></button>
					<button type="button" class="btn btn-default btn-sm ico-lgd" data-action="insertRowTop"  data-target="approvalInfoTable" ><span class="fa fa-plus"></span> <lgcom:message code="AddRowAtFirst1"/></button>
				</div>
			</div>
			<div class="_approval_area_">
				<form class="form _approverForm_">
					<table class="table table-condensed table-bordered approvalInfoTable" summary="Approver Infomation">
						<colgroup>
							<col width="50"/>
							<col width="150"/>
							<col width="400"/>
							<col width="*"/>
						</colgroup>
						<thead>
							<tr>
								<th><lgcom:message code="ApprovalSeq"/></th>
								<th><lgcom:message code="ApprovalType"/></th>
								<th><lgcom:message code="ApprovalApprover"/></th>
								<th><lgcom:message code="ApprovalMandator"/></th>
								<th></th>
							</tr>
						</thead>
						<tbody></tbody>
					</table>
					<table class="table table-condensed table-bordered approvalInfoTableView" summary="Approver Infomation">
						<colgroup>
							<col width="50"/>
							<col width="110"/>
							<col width="280"/>
							<col width="280"/>
							<col width="100"/>
							<col width="100"/>
							<col width="*"/>
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
		</div>
		<!-- //결재선 -->
	</section>
</div>
</body>
</html>
