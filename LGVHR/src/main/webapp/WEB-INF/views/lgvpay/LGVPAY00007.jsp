<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY00007.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 급여담당자가 급여작업을 할 때 진행해야 하는 Activity들을 조회하고 완료처리 할 수 있는 화면입니다.
    작성자 : 임수진	
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title><lgcom:message code="label.pay.payrollActivityManagement"/></title>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVPAY00007 = function() {
	var myForm = this;
	// Form Util 선언
	var srchFormUtil = new FormUtil( myForm, ".searchBlock form" );
	
    // 화면 레이아웃 정의
	myForm.setLayout( [
		{ name : "searchBlock",        left : 0, right : 0, top : 0 },
		{ name : "buttonControlBlock", left : 0, right : 0, top : "searchBlock"       , bottom : "gridBlock" },
	    { name : "gridBlock",          left : 0, right : 0, top : "buttonControlBlock", bottom : 0 }
	]);


    // 개인화조건
    
    // 조회조건 저장 처리
    myForm.searchConditionControl( true );
    
    // 팝업 데이터 정의 searchMode:single(단수),multi(복수)
	myForm.popupInfo = {
		calculationPopup 	: { popupKind:'', confirmKind:'', calculationSetId:'', calculationSetName:'', calculationData:[] },
		payrollSummaryPopup : { popupKind:'', confirmKind:'', payrollCalcPeriodValue:'', calculationSetId:'', payrollTypeCode:'', calculationExecId:'', calculationData:[] }
	};

    // 그리드형 테이블 TR

    // 코드 데이터 조회
	// combo 목록 조회
	var code = new CommonCode("lgcom");
    code.add( "payRunTypeList", {codeTypeCode:'LGVHR_PAY_RUN_TYPE'});
	code.add( "LGCOM_YN_FLAG", {codeTypeCode:'LGCOM_YN_FLAG'} );
	code.execute();
	
    // 그리드선언
	var listGrid = buildGrid(".listGrid");
	
	// 콤보 초기화
	srchFormUtil.initCombo("payrollTypeCode", code.get("payRunTypeList"), {selectAll:false});
    
    // 날짜 팝업창
    
    // 필수항목 체크
   	var validator = new Validator( myForm, ".searchBlock form" );

    validator.setRule( {
    	option: {placement: 'right'},
	    rules: {
	    	payrollCalcPeriodValue : { required : true, monthYear : true },
	    	payrollTypeCode        : { required : true },
	    	calculationSetName     : { emptyCalculationSet : true }
	    },
	    messages: {
	    	payrollCalcPeriodValue : { required            : '<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.payMonth'/>" />'},
	    	payrollCalcPeriodValue : { monthYear           : '<lgcom:message code="error.incorrectFormat" />'},
	    	payrollTypeCode        : { required            : '<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.payType'/>" />'},
	    	calculationSetName     : { emptyCalculationSet : '<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.calculationSet'/>" />'}
	    }
    });
    
    //calculation set 입력값에 대한 validation 추가
    validator.addMethod( "emptyCalculationSet", function ( value, element ) {
    	var result = true;
    	if ( isNull(value) || isNull(srchFormUtil.getValue("calculationSetId")) ) {
    		result = false;
    	}
    	return result;
    });

    // 일반함수	
    
    // Event 처리
	/*** 이벤트 핸들러  ***/
	myForm.addEvent( "click", "button[data-action]", function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}                                                                                                                                                                                                                                             
		var action = $.trim(item.data('action'));
		switch( action ){
			case "search" :
				if ( validator.isValid() ) {
					//데이터 조회
					fncRetrievePayrollActivityList();
				}
				break;
				
			// 급여대상자 SET 조회 팝업
		    case "openPopupCalSet" :
	            var popupData = myForm.popupInfo.calculationPopup;
	            popupData.popupKind    = "";
	            popupData.confirmKind  = "";
	            popupData.calculationSetName = srchFormUtil.getValue("payrollCalcPeriodValue");
	            srchFormUtil.setValue({calculationSetId : '', calculationSetName : ''});

	            var popup = new Popup( myForm,'lgvhr', 'M_LGVPAY_1018', '<lgcom:message code="label.pay.calculationSet"/>' );
	            popup.setSize(800,494);
	            popup.open( function(){
	            	if ( popupData.calculationData != undefined && popupData.calculationData.length > 0 ) {
	            		var selectData = popupData.calculationData[0];
		            	srchFormUtil.setValue({calculationSetId   : selectData.calculationSetId, 
		            		                   calculationSetName : selectData.calculationSetName});
		            	//검색조건 값이 있는 경우 데이터 조회
		        		fncSearchData();
	            	}
	            });
	            popupData.calculationData = [];
	            break;
	            
			// 저장
		    case "save" :
				if ( validator.isValid() ) {
					try {
						listGrid.getGridBase().commit();
					} catch(e) {
						Message.alert(e.message);
						return;
					}
					
					if( listGrid.getRowCount() == 0 ) {
						Message.alert('<lgcom:message code="note.nodata"/>');
						return;
					};

					// 변경건이 있는지 체크
					if(!listGrid.isChanged()) {
						Message.alert('<lgcom:message code="error.noChangedData"/>');
						return;
					}
					
					Message.confirm( "<lgcom:message code="question.save" />", function () {
						try {
							var listArr = fncArrangeMultiLineGrid(listGrid.getGridBase(), "updated");
						} catch (e) {
							trace(e);
						}
						
						if ( listArr.length == 0 ) {
							Message.alert('<lgcom:message code="note.nodata"/>');
							return ;
						}
						var param  = {};
						param = $.extend(param, srchFormUtil.getValue());
						param["list"] = listArr;
						
						myForm.transaction("lgvhr", "lgvpay/LGVPAY00007/savePayrollActivity", param, function(data) {
							if ( data.result ) {
								if ( isNull(data.result.errCode) ) {//정상인 경우
									Message.alert("<lgcom:message code="note.saved"/>");
									//데이터 재조회
									fncSearchData();
								} else {//실패인 경우
									Message.alert("<lgcom:message code="note.pay.failProcess"/>");
								}
							}
						});<%-- //myForm.transaction --%>
						
					});<%-- //Message.confirm --%>
				}
		    	break;
		}
		event.stopPropagation();
	});
	/* Form Submit 방지 */
	myForm.addEvent('submit', '.searchBlock form', function(event) {
		event.preventDefault();
	});
	
	/*** 내부 함수  ***/
	function fncSearchData() {
		if ( !isNull(srchFormUtil.getValue("payrollCalcPeriodValue")) && !isNull(srchFormUtil.getValue("payrollTypeCode")) && !isNull(srchFormUtil.getValue("calculationSetId")) ) { 
			myForm.select(".searchBlock button[data-action='search']").trigger("click");
		}
	}
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		// Context Menu Set
		grid.setContextMenu();
		// Grid Field Set
		grid.setFields([
			{ fieldName:'processNo'               , dataType:'text'  },
			{ fieldName:'processGroupName'        , dataType:'text'  },
			{ fieldName:'processName'             , dataType:'text'  },
			{ fieldName:'processDesc'             , dataType:'text'  },
			{ fieldName:'completionFlag'	      , dataType:'text'  },
			{ fieldName:'completionDate'          , dataType:'text'  },
			{ fieldName:'paymentDate'             , dataType:'text'  },//HMT_20260801
			{ fieldName:'runBtnDisplayFlag'       , dataType:'text'  },
			{ fieldName:'runBtnName'              , dataType:'text'  },
			{ fieldName:'batchProgramFulLName'    , dataType:'text'  },
			{ fieldName:'retireFlag'              , dataType:'text'  },
			{ fieldName:'payrollCalculationExecId', dataType:'text'  },
			{ fieldName:'approvedFlag'			  , dataType:'text'  }
		]);
		//컬럼 콤보 셋팅
		grid.setLookupsMultiLvl({"completionFlag":code.get("LGCOM_YN_FLAG")
			                   });
		// Grid Column Set
		grid.setColumns([
			{
				name:'processName',
				fieldName:'processName',
				width:200,
				header: {text:'<lgcom:message code="label.pay.activityName"/>'}, 
				editable: false
			},
			{
				name:'processDesc',
				fieldName:'processDesc',
				width:550,
				header: {text:'<lgcom:message code="Description"/>'},
				styles : {textWrap : "explicit"},
				renderer: {showTooltip:true},
				editor: {type: "multiline"},
				editable: false
			},
			{
				name:'runBtnName',
				fieldName:'runBtnName',
				width:80,
				header: {text:'<lgcom:message code="label.pay.run"/>'},
				styles: {textAlignment:'center', fontBold:true},
				cursor: 'pointer',
				editable: false
			},
			{
				name:'completionFlag',
				fieldName:'completionFlag',
				width:120,
				header: {text:'<lgcom:message code="label.pay.completionFlag"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'completionFlag',
				lookupKeyFields: ['completionFlag'],
				editor: {type:'dropDown',textReadOnly:true},
			},
			{
				name:'completionDate',
				fieldName:'completionDate',
				width:200,
				header: {text:'<lgcom:message code="CompletionDate"/>'},
				styles: {textAlignment:'center'},
				editable: false
			},
			{
				name:'paymentDate',
				fieldName:'paymentDate',
				width:200,
				header: {text:'<lgcom:message code="label.pay.paymentDate"/>'},
				styles: {textAlignment:'center'},
				editor: {type:'date', datetimeFormat:'dd/MM/yyyy', maxLength:10},
				editable: true
			}
		]);
		// Grid Option Set
		grid.setOptions({
			grid: {
				hideDeletedRows: true,
				indicator: {visible:false},
				panel: {visible:false},
				stateBar: {visible:false},
				checkBar: {visible:false},
				footer: {visible:false},
				select: 'block',
				paste    : { enabled: false }, /*paste 기능막기 */
				sorting  : { enabled: false }, /*Sorting 기능을 막는다.*/
	            sortMode : "explicit",
				edit: {
					insertable: false, /* INSERT 키 또는 방향키로 행삽입 불가능 */
					appendable: false, /* INSERT 키 또는 방향키로 행추가 불가능 */
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
			display: { fitStyle: 'none', rowHeight: 50 }
		});
		return grid;
	}
    listGrid.getGridBase().onDataCellClicked = function (cgrid, index) {
        if ( index.column == 'runBtnName' && cgrid.getValue(index.itemIndex, "runBtnDisplayFlag") != "N" ) {
        	switch ( cgrid.getValue(index.itemIndex, "processGroupName") ) {
        		//급여대상자 생성
        		case "CREATE_EMPLOYEE" : 
        			fncCreateTargetEmployee(cgrid, index);
        			break;
        		//급여 전표 인터페이스 데이터 생성
        		case "TRANSFER_ERP" :
        			fncInsertPayInvoiceIF(cgrid, index);
        			break;
        		//급여 전표 인터페이스 생성 전 Confirm Request
        		case "REQUEST_PAYROLL_CONFIRM" :
        			if( index.column == 'runBtnName' && cgrid.getValue(index.itemIndex, "approvedFlag") == "Y" ) fncRequestPayrollConfirm(cgrid, index);
        			break;
        	}  
        }
    }
	//데이터 조회
	function fncRetrievePayrollActivityList() {
		listGrid.getGridBase().cancel();
		listGrid.loadData("lgvhr", "lgvpay/LGVPAY00007/retrievePayrollActivityList", srchFormUtil.getValue(), function (data) {
			//저장 버튼 활성화
			myForm.select("button[data-action='save']").removeAttr("disabled");
			if ( data.result ) {
				for (var i=0; i<data.result.length; i++) {
					//run 버튼 보여주는 경우만 버튼명 보여줌
					listGrid.getGridBase().setValue(i, "runBtnName", (nvl(data.result[i].runBtnDisplayFlag) == "Y")?"[<lgcom:message code="button.pay.run"/>]":
						(nvl(data.result[i].runBtnDisplayFlag) == "R" && nvl(data.result[i].approvedFlag) == 'Y')?"[<lgcom:message code="button.pay.request"/>]":"");
				}
			}
		});
	}
	//급여 대상자 생성
	function fncCreateTargetEmployee( cgrid, index ) {
		if ( validator.isValid() ) {
			try {
				listGrid.getGridBase().commit();
			} catch(e) {
				Message.alert(e.message);
				return;
			}
			Message.confirm( "<lgcom:message code="question.pay.requestRun"/>", function() {
				var provider = cgrid.getDataProvider();
				var param = provider.getJsonRow(index.dataRow);
				param = $.extend(param, srchFormUtil.getValue());

				myForm.showProgress();
				myForm.transaction("lgvhr", "lgvpay/LGVPAY00007/createPayrollTargetEmployee", param, function (data) {
					myForm.hideProgress();
					if ( data.result ) {
						if ( isNull(data.result.errcode) ) {//정상
							Message.alert("<lgcom:message code='note.pay.rowSuccessfullyCreated' arguments='"+nvl(data.result.createCnt)+"' />");
							//데이터 재조회
							fncSearchData();
						} else {//실패
							Message.alert("<lgcom:message code='note.pay.failCreate' />");
						}
					}
				}, function (data) {
					myForm.hideProgress();
				});<%-- //myForm.transaction --%>
			});<%-- //Message.confirm --%>
		}
	}
	//급여 전표 인터페이스 데이터 생성
	function fncInsertPayInvoiceIF( cgrid, index ) {
		if ( validator.isValid() ) {
			
			//확정된 execution_id 가 있는지 체크
			if ( isNull(cgrid.getValue(index.itemIndex, "payrollCalculationExecId")) ) {
				Message.alert("<lgcom:message code="note.pay.noConfirmExecId" />");
				return ;
			}
			
			try {
				listGrid.getGridBase().commit();
			} catch(e) {
				Message.alert(e.message);
				return;
			}
			Message.confirm( "<lgcom:message code="question.pay.requestRun"/>", function() {
				
				var provider = cgrid.getDataProvider();
				var param = provider.getJsonRow(index.dataRow);
				param = $.extend(param, srchFormUtil.getValue());

				myForm.showProgress();
				myForm.transaction("lgvhr", "lgvpay/LGVPAY00007/insertPayInvoiceIF", param, function (data) {
					myForm.hideProgress();
					if ( data.result ) {
						if ( data.result.errcode == "0" ) {//정상
							if ( !isNull(data.result.errbuf) ) {//메세지 있는 경우 출력
								Message.alert(data.result.errbuf);
							} else {//메세지 없는 경우 기본메세지로
								Message.alert("<lgcom:message code='note.pay.successfullyProcessed' />");
							}
							//데이터 재조회
							fncSearchData();
						} else {//실패
							if ( !isNull(data.result.errbuf) ) {//메세지 있는 경우 출력
								Message.alert(data.result.errbuf);
							} else {//메세지 없는 경우 기본메세지로
								Message.alert("<lgcom:message code='note.pay.failProcess' />");
							}
						}
					}
				}, function (data) {
					myForm.hideProgress();
				});<%-- //myForm.transaction --%>
			});<%-- //Message.confirm --%>
		}
	}
	//급여 전표 인터페이스 생성 전 Confirm Request
	function fncRequestPayrollConfirm( cgrid, index ) {
		if ( validator.isValid() ) {
			
			//확정된 execution_id 가 있는지 체크
			if ( isNull(cgrid.getValue(index.itemIndex, "payrollCalculationExecId")) ) {
				Message.alert("<lgcom:message code="note.pay.noConfirmExecId" />");
				return ;
			}
			
			try {
				listGrid.getGridBase().commit();
			} catch(e) {
				Message.alert(e.message);
				return;
			}
				
			var popupData = myForm.popupInfo.payrollSummaryPopup;
            popupData.popupKind    = "";
            popupData.confirmKind  = "";
            popupData.calculationSetId = srchFormUtil.getValue("calculationSetId");
            popupData.payrollTypeCode = srchFormUtil.getValue("payrollTypeCode");
            popupData.payrollCalcPeriodValue = srchFormUtil.getValue("payrollCalcPeriodValue");
            popupData.calculationExecId = cgrid.getValue(index.itemIndex, "payrollCalculationExecId");

            var popup = new Popup( myForm,'lgvhr', 'M_LGVPAY_1050', 'Request Payroll Confirm' );
            popup.setSize(1100, 494);
            popup.open( function(){
            	fncRetrievePayrollActivityList();
            });
            popupData.calculationData = [];
            
		}
	}
}

LGVPAY00007.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVPAY00007();
		form.init();		
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2><lgcom:message code="label.pay.payrollActivityManagement"/></h2>
		</div>
		<div class="searchBlock">
			<form class="form search-wrap" method="post">
				<table class="table" >
					<colgroup>
						<col width="180"></col>
						<col width="070"></col>
						<col width="100"></col>
						<col width="180"></col>
						<col width="140"></col>
						<col width="250"></col>
						<col width="*"></col>
					</colgroup>
					<tbody>
						<tr>
		                	<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.pay.payMonth" /></label></th>
							<td><input type="text" class="form-control input-sm input-require" name="payrollCalcPeriodValue" maxlength="7" placeholder="<lgcom:message code="placeholder.pay.mmyyyy"/>" /></td>
		                	<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.pay.payType" /></label></th>
		                	<td><select class="form-control input-sm input-require" name="payrollTypeCode" ></select></td>
		                	<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.pay.calculationSet" /></label></th>
							<td>
		                		<div class="input-group input-group-sm input-search">
		                			<input type="hidden" name="calculationSetId" />
	                                <input class="form-control input-sm input-require" name="calculationSetName" type="text" data-action="emptyAndPopup" readonly />
	                                <span class="input-group-btn">
	                                    <button class="btn btn-default ico-lgd find" type="button" data-action="openPopupCalSet">
	                                        <span class="fa fa-search" aria-hidden="true"></span>
	                                    </button>
	                                </span>
	                            </div>
		                	</td>
		                	<td></td>
		                </tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
			</form>
		</div>
		<%-- //searchBlock --%>
		
		<div class="buttonControlBlock module-group text-right">
			<div class="btn-group">
				<button class="btn btn-gray btn-sm" type="button" data-action="save" disabled><lgcom:message code="Save"/></button>
			</div>
		</div>
		<%-- //buttonControlBlock --%>
		
		<div class="gridBlock grid-wrap">
			<div class="grid listGrid"></div>
		</div>
				
	</section>
</div>
</body>
</html>
