<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY00009.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 급여담당자가 특정일자의 임직원들의 급여관련 정보를 조회하고 다운로드 받는 화면입니다.
    작성자 : 임수진	
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title><lgcom:message code="label.pay.paymentMaster"/></title>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVPAY00009 = function() {
	var myForm = this;
	// Form Util 선언
	var srchFormUtil = new FormUtil( myForm, ".searchBlock form" );
	
    // 화면 레이아웃 정의
	myForm.setLayout( [
		{ name : "searchBlock",        left : 0, right : 0, top : 0 },
		{ name : "buttonControlBlock", left : 0, right : 0, top : "searchBlock"       , bottom : "gridBlock" },
	    { name : "gridBlock",          left : 0, right : 0, top : "buttonControlBlock", bottom : 0 }
	]);

    // 그리드선언
	var listGrid = buildGrid(".listGrid");

    // 개인화조건
    
    // 조회조건 저장 처리
    myForm.searchConditionControl( true );
    
    // 팝업 데이터 정의 searchMode:single(단수),multi(복수)
	myForm.popupInfo = {
		userPopup          : {searchMode:'single', popupKind:'', confirmKind:'', employeeNo:'', employeeName:'', attDate:'', flsaYn:'N', fseYn:'N', userData:[]}
	};

    // 그리드형 테이블 TR

    // 코드 데이터 조회
	
	// 콤보 초기화
    
    // 날짜 팝업창
    srchFormUtil.setCalendar( { from : "effectiveDate", language:SESSION_USER.languageCode, format: 'DD/MM/YYYY' } );
    
    // 초기값 셋팅
    srchFormUtil.setValue( { effectiveDate : DateUtil.today("DD/MM/YYYY") } );
    
    // 필수항목 체크
   	var validator = new Validator( myForm, ".searchBlock form" );

    validator.setRule( {
    	option: {placement: 'right'},
	    rules: {
	        effectiveDate:{required:true}
	    },
	    messages: {
	    	effectiveDate : {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.effectiveDate'/>" />'}
	    }
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
					//조회권한이 있는지 여부
					//데이터 조회
					fncRetrievePaymentMasterList();
				}
				break;
				
			// 유저 검색 팝업
		    case "openPopupEmployee" :
		    	fncPopupEmployeeSearch();
                break;
                
		    case "excelDownload" : 
				if(validator.isValid()) {
					Message.confirm('<lgcom:message code="question.excelDownload"/>',function() {
						var downloader = new Downloader( myForm );
						var param = {employeeNo : srchFormUtil.getValue("employeeNo")
								   , effectiveDate : srchFormUtil.getValue("effectiveDate")
								   , subsidiaryCode : "<c:out value="${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}"/>"
								   , languageCode : SESSION_USER.languageCode
								   };
						downloader.csvDirectDownload("lgvhr", "LGVPAY00009.createCSVDownloadData", param);
					});
				}
		    	break;
		}
		event.stopPropagation();
	});
	/* Form Submit 방지 */
	myForm.addEvent('submit', '.searchBlock form', function(event) {
		event.preventDefault();
	});
    //사번 또는 성명 클릭 시 값 초기화
    myForm.addEvent ( "click", ".searchBlock form input[name]", function(event) {
		var item = $(event.target);
		if ( $.trim(item.attr("name")) == "employeeNo" || $.trim(item.attr("name")) == "employeeName" ) {
    		//fncSearchEmpInfoInit();
		}
		event.stopPropagation();
    });
	myForm.addEvent ( "change", ".searchBlock form input[name]", function(event) {
		var item = $(event.target);
		switch ( $.trim(item.attr("name")) ) {
			case "employeeNo" :
				//사번이 변경된 경우 성명 초기화 처리
				if ( srchFormUtil.getPreviousValue("employeeNo") != srchFormUtil.getValue("employeeNo") || isNull(srchFormUtil.getValue("employeeNo")) ) {
					srchFormUtil.setValue({employeeName:""});
				}
				//fncPopupEmployeeSearch();//사번 또는 성명 값 변경되는 경우 임직원 검색
				break;
			case "employeeName" :
				//성명이 변경된 경우 사번 초기화 처리
				if ( srchFormUtil.getPreviousValue("employeeName") != srchFormUtil.getValue("employeeName") || isNull(srchFormUtil.getValue("employeeName")) ) {
					srchFormUtil.setValue({employeeNo:""});
				} 
				//fncPopupEmployeeSearch();//사번 또는 성명 값 변경되는 경우 임직원 검색
				break;
			case "effectiveDate" :
				fncSearchData();
				break;
		}			
		event.stopPropagation();
	});
	myForm.addEvent ( "keyup", ".searchBlock form input[name]", function(event) {
		var item = $(event.target);
		if ( event.keyCode == 13 ) {//enter key
			switch ( $.trim(item.attr("name")) ) {
				case "employeeNo":
					if ( srchFormUtil.getPreviousValue("employeeNo") != srchFormUtil.getValue("employeeNo") ) {
						srchFormUtil.setValue("employeeName", "");
					}
					break;
				case "employeeName":
					if ( srchFormUtil.getPreviousValue("employeeName") != srchFormUtil.getValue("employeeName") ) {
						srchFormUtil.setValue("employeeNo", "");
					}
					break;
			}
			fncPopupEmployeeSearch();
		}
		event.stopPropagation();
	});
	
	/*** 내부 함수  ***/	
	//사원검색 팝업 호출 및 값 셋팅
	function fncPopupEmployeeSearch() { 
    	var popupData = myForm.popupInfo.userPopup;
    	popupData.employeeNo = srchFormUtil.getValue("employeeNo");
    	popupData.employeeName = srchFormUtil.getValue("employeeName");
    	popupData.fseYn = "N";
    	popupData.flsaYn = "N";
    	fncSearchEmpInfoInit();

        var popup = new Popup( myForm,'lgvhr', 'M_LGVCOM_1010', '<lgcom:message code="UserSearch"/>' );
        popup.setSize(800,494);
        popup.open( function() {
        	if ( popupData.userData != null && popupData.userData.length > 0 ) {
        		srchFormUtil.setValue({employeeNo   : popupData.userData[0].employeeNo
        			                 , employeeName : popupData.userData[0].employeeName});
        		//검색조건 값이 있는 경우 데이터 조회
        		fncSearchData();
        	}
        });
        popupData.userData = [];
	}
	//사번, 성명값 초기화
	function fncSearchEmpInfoInit() { 
		srchFormUtil.setValue({employeeNo : '', employeeName : ''});		
	}
	function fncSearchData() {
		if ( !isNull(srchFormUtil.getValue("effectiveDate")) ) { 
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
			{ fieldName:'employeeNo'            , dataType:'text'  },
			{ fieldName:'employeeName'          , dataType:'text'  },
			{ fieldName:'empCategoryName'       , dataType:'text'  },
			{ fieldName:'jobTitleName'          , dataType:'text'  },
			{ fieldName:'hireDate'	            , dataType:'text'  },
			{ fieldName:'resignationDate'       , dataType:'text'  },
			{ fieldName:'organizationName'      , dataType:'text'  },
			{ fieldName:'probationStartDate'    , dataType:'text'  },
			{ fieldName:'probationEndDate'      , dataType:'text'  },
			{ fieldName:'probationBaseSalary'   , dataType:'number'},
			{ fieldName:'baseSalary'            , dataType:'number'},
			{ fieldName:'positionAllowance'     , dataType:'number'},
			{ fieldName:'jobAllowance'          , dataType:'number'},
			{ fieldName:'qualificationAllowance', dataType:'number'},
			{ fieldName:'adjustment1Allowance'  , dataType:'number'},
			{ fieldName:'adjustment2Allowance'  , dataType:'number'},
			{ fieldName:'adjustment3Allowance'  , dataType:'number'},
			{ fieldName:'total'                 , dataType:'number'}
		]);
		// Grid Column Set
		grid.setColumns([
			{
				name:'employeeNo',
				fieldName:'employeeNo',
				width:90,
				header: {text:'<lgcom:message code="label.pay.employeeNo"/>'},
				styles: {textAlignment:'center', fontUnderline: true, foreground:'#37a0ac'},
				cursor:'pointer', 
				editable: false
			},
			{
				name:'employeeName',
				fieldName:'employeeName',
				width:120,
				header: {text:'<lgcom:message code="label.pay.employeeName"/>'},
				editable: false
			},
			{
				name:'empCategoryName',
				fieldName:'empCategoryName',
				width:80,
				header: {text:'<lgcom:message code="label.pay.empCategory"/>'},
				editable: false
			},
			{
				name:'jobTitleName',
				fieldName:'jobTitleName',
				width:80,
				header: {text:'<lgcom:message code="label.pay.jobTitle"/>'},
			    renderer: {showTooltip: true},
				editable: false
			},
			{
				name:'hireDate',
				fieldName:'hireDate',
				width:80,
				header: {text:'<lgcom:message code="label.pay.hireDate"/>'},
				styles: {textAlignment:'center'},
				editable: false
			},
			{
				name:'resignationDate',
				fieldName:'resignationDate',
				width:80,
				header: {text:'<lgcom:message code="label.pay.resignationDate"/>'},
				styles: {textAlignment:'center'},
				editable: false
			},
			{
				name:'organizationName',
				fieldName:'organizationName',
				width:120,
				header: {text:'<lgcom:message code="label.pay.organization"/>'},
			    renderer: {showTooltip: true},
				editable: false
			},
			{
				name:'probationStartDate',
				fieldName:'probationStartDate',
				width:80,
				header: {text:'<lgcom:message code="label.pay.probationStartDate"/>'},
				styles: {textAlignment:'center'},
				editable: false
			},
			{
				name:'probationEndDate',
				fieldName:'probationEndDate',
				width:80,
				header: {text:'<lgcom:message code="label.pay.probationEndDate"/>'},
				styles: {textAlignment:'center'},
				editable: false
			},
			{
				name:'probationBaseSalary',
				fieldName:'probationBaseSalary',
				width:90,
				header: {text:'<lgcom:message code="label.pay.probationBaseSalary"/>'},
				styles: {textAlignment:'far', numberFormat: '#,##0'},
				editable: false
			},
			{
				name:'baseSalary',
				fieldName:'baseSalary',
				width:90,
				header: {text:'<lgcom:message code="label.pay.baseSalary"/>'},
				styles: {textAlignment:'far', numberFormat: '#,##0'},
				editable: false
			},
			{
				name:'positionAllowance',
				fieldName:'positionAllowance',
				width:90,
				header: {text:'<lgcom:message code="label.pay.positionAllowance"/>'},
				styles: {textAlignment:'far', numberFormat: '#,##0'},
				editable: false
			},
			{
				name:'jobAllowance',
				fieldName:'jobAllowance',
				width:90,
				header: {text:'<lgcom:message code="label.pay.jobAllowance"/>'},
				styles: {textAlignment:'far', numberFormat: '#,##0'},
				editable: false
			},
			{
				name:'qualificationAllowance',
				fieldName:'qualificationAllowance',
				width:90,
				header: {text:'<lgcom:message code="label.pay.qualificationAllowance"/>'},
				styles: {textAlignment:'far', numberFormat: '#,##0'},
				editable: false
			},
			{
				name:'adjustment1Allowance',
				fieldName:'adjustment1Allowance',
				width:90,
				header: {text:'<lgcom:message code="label.pay.adjustment1Allowance"/>'},
				styles: {textAlignment:'far', numberFormat: '#,##0'},
				editable: false
			},
			{
				name:'adjustment2Allowance',
				fieldName:'adjustment2Allowance',
				width:90,
				header: {text:'<lgcom:message code="label.pay.adjustment2Allowance"/>'},
				styles: {textAlignment:'far', numberFormat: '#,##0'},
				editable: false
			},
			{
				name:'adjustment3Allowance',
				fieldName:'adjustment3Allowance',
				width:90,
				header: {text:'<lgcom:message code="label.pay.adjustment3Allowance"/>'},
				styles: {textAlignment:'far', numberFormat: '#,##0'},
				editable: false
			},
			{
				name:'total',
				fieldName:'total',
				width:100,
				header: {text:'<lgcom:message code="label.pay.total"/>'},
				styles: {textAlignment:'far', numberFormat: '#,##0'},
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
				checkBar: {visible:false},
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
				},
				fixed: { colCount: 9, resizable:true }
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
		return grid;
	}
    listGrid.getGridBase().onDataCellClicked = function (cgrid, index) {
        if ( index.column == 'employeeNo' ) {

    		var nav = new Navigate( "lgvhr", "M_LGVPAY_1011" );
    		nav.addParam("employeeNo", cgrid.getValue(index.itemIndex, "employeeNo"));
    		nav.addParam("effectiveDate", srchFormUtil.getValue("effectiveDate").replaceAll("/", "_"));// '/'는 화면 전달시 encoding되므로 치환하여 전달함. 
    		//nav.addParam("authGroup", 'MASTER');
    		
    		nav.goPageInNewTab();
        }
    }
	//데이터 조회
	function fncRetrievePaymentMasterList() {
		listGrid.getGridBase().cancel();
		listGrid.loadData("lgvhr", "lgvpay/LGVPAY00009/retrievePaymentMasterList", srchFormUtil.getValue(), function (data) {
			
		});
	}
}

LGVPAY00009.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVPAY00009();
		form.init();		
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2><lgcom:message code="label.pay.paymentMaster"/></h2>
		</div>
		<div class="searchBlock">
			<form class="form search-wrap" method="post">
				<table class="table" >
					<colgroup>
						<col width="120"></col>
						<col width="110"></col>
						<col width="160"></col>
						<col width="200"></col>
						<col width="150"></col>
						<col width="100"></col>
						<col width="*"></col>
					</colgroup>
					<tbody>
						<tr>
		                	<th><label><lgcom:message code="label.pay.employeeNo" /></label></th>
							<td>
		                		<div class="input-group input-group-sm input-search">
	                                <input class="form-control input-sm" name="employeeNo" type="text" />
	                                <span class="input-group-btn">
	                                    <button class="btn btn-default ico-lgd" type="button" data-action="openPopupEmployee">
	                                        <span class="fa fa-search" aria-hidden="true"></span>
	                                    </button>
	                                </span>
	                            </div>
		                	</td>
							<th><label><lgcom:message code="label.pay.employeeName" /></label></th>
							<td>
		                		<div class="input-group input-group-sm input-search">
		                			<input type="text" class="form-control input-sm" name="employeeName" />
	                                <span class="input-group-btn">
	                                    <button class="btn btn-default ico-lgd" type="button" data-action="openPopupEmployee">
	                                        <span class="fa fa-search" aria-hidden="true"></span>
	                                    </button>
	                                </span>
	                            </div>
	                        </td>
							<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.pay.effectiveDate" /></label></th>
							<td>
								<span class="form-inline">
								    <input type="text" class="form-control input-sm input-require size_80" name="effectiveDate" placeholder="dd/mm/yyyy" readonly />
								    <button type="button" class="btn btn-ico" aria-label="calendar">
								        <span class="ico ico-calendar" aria-hidden="true"></span>
								    </button>
								</span>
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
				<button type="button" class="btn btn-default btn-sm" data-action="excelDownload"><span class="ico ico-excel-down"  aria-hidden="true"></span> <lgcom:message code="Download"/></button>
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
