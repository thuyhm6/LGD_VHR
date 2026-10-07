<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAYP0018.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 급여담당자가 급여실적이 정상적으로 생성된 인원에 대해 급여명세서를 출력하는 팝업 화면입니다.
    작성자 : 임수진	
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Print by Employee</title>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVPAYP0018 = function() {
	var myForm = this;
	// Form Util 선언
	var srchFormUtil = new FormUtil( myForm, ".searchBlock form" );
	var printByEmployeePopupData = myForm.getParent().popupInfo.printByEmployeePopup;
	
	//팝업으로서의 이 화면은 여러 화면에서 사용하는 것으로, 팝업 윈도우의 크기를 아래와 같이 고정하였다.
	//myForm.select(".searchBlock").parents("._div_popup_holder_").css({"width": "712px", "height":"512px"});
	
    // 화면 레이아웃 정의(달력 그린 후 레이아웃 지정하기 위해 마지막에 수행함.)
	myForm.setLayout( [
		{ name : "searchBlock",  left : 0, right : 0, top : 0 },
		{ name : "contentBlock", left : 0, right : 0, top : "searchBlock",  bottom : "controlBlock" },
	    { name : "controlBlock", left : 0, right : 0, bottom : 0 }
	]);

    // 그리드선언
	var grid = buildGrid(".listGrid");

    // 개인화조건
    
    // 조회조건 저장 처리
    myForm.searchConditionControl( true );
    
    // 팝업 데이터 정의 searchMode:single(단수),multi(복수)	
	myForm.popupInfoOrg = {
        orgPopup   : {searchMode:'single', popupKind:'', confirmKind:'', orgName:'', orgData:[]},
        returnPopup : {returnComment:''}
	};

    // 그리드형 테이블 TR
    
    // 코드 데이터 조회
    
	//콤보 초기화
	
    // 날짜 팝업창
    
    // 필수항목 체크
    
    // 일반함수	
    
    // Event 처리
	/*** 이벤트 핸들러  ***/
	myForm.addEvent( "click", "button[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}                                                                                                                                                                                                                                             
		var action = $.trim(item.data('action'));
		switch( action ){
			case "search" :
				if ( fncValidateSearch() ) {
					fncRetrievePayrollRunEmpList();
				}
				break;
				
            // 조직 검색 팝업
		    case "openPopupOrg" :
                fncPopupOrgSearch();
                break;
            // 인쇄
			case 'print':
				fncPrintByEmployee();
				break;
		}
		event.stopPropagation();
	});
	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});
	//enter key 입력 시 조직 검색 팝업 호출
	myForm.addEvent ( "keyup", ".searchBlock form input[name]", function(event) {
		var item = $(event.target);
		if ( event.keyCode == 13 ) {//enter key
			switch ( $.trim(item.attr("name")) ) {
				case "organizationName":
					if ( srchFormUtil.getPreviousValue("organizationName") != srchFormUtil.getValue("organizationName") ) {
						srchFormUtil.setValue("organizationId", "");
					}
					fncPopupOrgSearch();
					break;
			}
		}
		event.stopPropagation();
	});
	/*** 내부 함수  ***/
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		// Grid Field Set
		grid.setFields([
			{ fieldName:'employeeNo'               , dataType:'text'  },
			{ fieldName:'employeeName'             , dataType:'text'  },
			{ fieldName:'organizationName'         , dataType:'text'  },
			{ fieldName:'hireDate'                 , dataType:'text'  },
			{ fieldName:'resignationDate'          , dataType:'text'  }
		]);
		// Grid Column Set
		grid.setColumns([
			{
				name:'employeeNo',
				fieldName:'employeeNo',
				width:100,
				header: {text:'<lgcom:message code="label.pay.employeeNo"/>'},
				styles: {textAlignment:'center'},
				editable: false
			},
			{
				name:'employeeName',
				fieldName:'employeeName',
				width:200,
				header: {text:'<lgcom:message code="label.pay.employeeName"/>'},
				editable: false
			},
			{
				name:'organizationName',
				fieldName:'organizationName',
				width:280,
				header: {text:'<lgcom:message code="label.pay.organizationName"/>'},
				editable: false
			},
			{
				name:'hireDate',
				fieldName:'hireDate',
				width:100,
				header: {text:'<lgcom:message code="label.pay.hireDate"/>'},
				styles: {textAlignment:'center'},
				editable: false
			},
			{
				name:'resignationDate',
				fieldName:'resignationDate',
				width:120,
				header: {text:'<lgcom:message code="label.pay.resignationDate"/>'},
				styles: {textAlignment:'center'},
				editable: false
			}
		]);
		// Grid Option Set
		grid.setOptions({
			grid: {
				hideDeletedRows: true,
				indicator: {visible:false},
				panel: {visible:false},
				stateBar: {visible:false},
				footer: {visible:false},
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
			display: { fitStyle: 'none' }
		});
		// Context Menu Set
		grid.setContextMenu();
		return grid;
	}
	//조직검색 팝업
	function fncPopupOrgSearch() {
        var popupData = myForm.popupInfoOrg.orgPopup;
        
        popupData.searchMode  = "single";
        popupData.popupKind   = "";
        popupData.confirmKind = "";
        popupData.orgName     = srchFormUtil.getValue("organizationName");
        popupData.orgData     = [];
        
        var popup = new Popup( myForm,'lgvhr', 'M_LGVCOM_1014', 'Org Search' );
        popup.setSize(800,494);
        popup.open( function(){
        	if ( popupData.orgData != undefined && popupData.orgData.length > 0 ) {
        		var selectData = popupData.orgData[0];
                srchFormUtil.setValue({organizationId   : selectData.organizationId
                	                 , organizationName : selectData.organizationName});
        	}
        });
	}
	//조회 전 체크
	function fncValidateSearch() {
		if ( isNull(srchFormUtil.getValue("organizationId")) && isNull(srchFormUtil.getValue("employeeNo")) ) {
			Message.alert("<lgcom:message code="note.pay.oneMoreSelectCondition"/>");
			return false;
		}
		return true;
	}
	//데이터 조회
	function fncRetrievePayrollRunEmpList() {
		grid.getGridBase().cancel();
		var param = {};
		param = $.extend(param, srchFormUtil.getValue());
		param["payrollCalculationExecIdList"] = printByEmployeePopupData.payrollCalculationExecIdList;
		myForm.select("button[data-action='print']").attr("disabled", "disabled");
		
		grid.loadData("lgvhr", "lgvpay/LGVPAYP0018/retrievePayrollRunEmpList", param, function(data) {
			if ( data.result ) {
				myForm.select("button[data-action='print']").removeAttr("disabled");
			}
		});
	}
	//인쇄
	function fncPrintByEmployee() {
		var list = fncArrangeMultiLineGridSelected(grid);
		
		//선택된 행이 있는지 체크
		if ( !list || list.length == 0 ) {
			Message.alert("<lgcom:message code="note.noselected"/>");
			return ;
		}
        	    
	    var winUrl = SERVER_URL+'/aireport/report/PaySlipReport.jsp';
	    var windowoption='resizable=yes,height='+ 800 +',width='+ 1280 +',location=0,menubar=0,scrollbars=1, top=50, left=50';
	    var form = $("#printEmployeeReportForm");

	    if( !form.exists() ) {
	        $("body").append("<form id='printEmployeeReportForm' method='POST'></form>");
	        form = $("#printEmployeeReportForm");
	    }
	    
	    $(form).empty();
	    $(form).attr("action", winUrl);
	    $(form).attr("target",'aiReportPrintEmployee');
	    
	    //파라미터 셋팅
	    $(form).append("<input type='hidden' name='payrollCalcPeriodValue' value='"+printByEmployeePopupData.payrollCalcPeriodValue+"' />");
	    $(form).append("<input type='hidden' name='AIReportLangScCd' value='"+SESSION_USER.languageCode+"' />");
	    $(form).append("<input type='hidden' name='reportParams' value='useReportFile:true,reportFileSave:true' />");
	    
	    //선택된 payrollCalculationExecId 가 있는 경우 배열을 <> 구분자로 변환하여 변수 값으로 셋팅
	    if ( printByEmployeePopupData.payrollCalculationExecIdList != null && printByEmployeePopupData.payrollCalculationExecIdList.length > 0 ){
	    	$(form).append("<input type='hidden' name='payrollCalculationExecIdList' value='"+printByEmployeePopupData.payrollCalculationExecIdList.join("<>")+"' />");
	    }
	    
	    //선택된 사번이 있는 경우 배열을 <> 구분자로 변환하여 변수 값으로 셋팅 
	    var employeeNoList = fncArrangeFieldMultiLineGridSelected(grid, "employeeNo");
	    if ( employeeNoList != null && employeeNoList.length > 0 ){
	    	$(form).append("<input type='hidden' name='employeeNoList' value='"+employeeNoList.join("<>")+"' />");
	    }
	    
	    window.open('', 'aiReportPrintEmployee', windowoption);
	    $(form).submit();
	}
}

LGVPAYP0018.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVPAYP0018();
		form.init();		
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2>Print by Employee</h2>
		</div>
		<div class="searchBlock">
			<form class="form search-wrap" method="post">
				<table class="table" >
					<colgroup>
						<col width="100"></col>
						<col width="180"></col>
						<col width="100"></col>
						<col width="80"></col>
						<col width="*"></col>
					</colgroup>
					<tbody>
						<tr>
		                	<th><label><lgcom:message code="label.pay.organization" /></label></th>
							<td>
		                		<div class="input-group input-group-sm input-search">
		                			<input type="hidden" name="organizationId" />
	                                <input class="form-control input-sm" type="text" name="organizationName" />
	                                <span class="input-group-btn">
	                                    <button class="btn btn-default ico-lgd" type="button" data-action="openPopupOrg">
	                                        <span class="fa fa-search" aria-hidden="true"></span>
	                                    </button>
	                                </span>
	                            </div>
							</td>
		                	<th><label><lgcom:message code="label.pay.employeeNo" /></label></th>
							<td><input type="text" class="form-control input-sm" name="employeeNo" /></td>
		                	<td></td>
		                </tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
			</form>
		</div>
		<%-- //searchBlock --%>

		<div class="contentBlock grid-wrap">
			<div class="grid listGrid"></div>
		</div>

		<div class="controlBlock modal-footer">
			<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="print" disabled><lgcom:message code="Print"/></button>
		</div>
		
	</section>
</div>
</body>
</html>
