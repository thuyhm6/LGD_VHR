<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY00011.jsp
    프로젝트명 : 베트남 근태 급여 시스템 구축

   Copyright(c) 2017 LG CNS,  All rights reserved..

    설 명 : 명세서 오픈일 관리
    작성자 : bakderia
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<script type="text/javascript">
var LGVPAY00011 = function() {
	var myForm = this;
    var _this = this;
	var result;
	// Form Util 선언
	var srchForm = '.searchBlock form';
	var srchFormUtil = new FormUtil( myForm, srchForm );
	var gridContent = new FormUtil(myForm,'.gridContent form');
	
	// 코드 데이터 조회
    var code = new CommonCode("lgcom");
    code.add("payRunTypeList", {codeTypeCode:'LGVHR_PAY_RUN_TYPE'});
    code.execute();
    
    //콤보 초기화
	srchFormUtil.initCombo("payrollTypeCode", code.get("payRunTypeList"), {selectAll:false});
  
	//검색조건 기본값 셋팅
	srchFormUtil.setValue({ payrollCalcPeriodValue : DateUtil.today("MM/YYYY") });
	
 	//필수항목 체크
   	var validator = new Validator( myForm, srchForm );
	
   	validator.setRule( {
    	option: {placement: 'right'},
	    rules: {
	    	payrollCalcPeriodValue : { required : true, monthYear : true },
	    	payrollTypeCode        : { required : true }
	    },
	    messages: {
	    	payrollCalcPeriodValue : { required : '<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.payMonth'/>" />'},
	    	payrollCalcPeriodValue : { monthYear : '<lgcom:message code="error.incorrectFormat" />'},
	    	payrollTypeCode        : { required : '<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.payType'/>" />'}
	    }
    });
  
   	myForm.setLayout( [ 
   	        		{ name : "searchBlock", left : 0, right : 0, top : 0 },
   	        		{ name : "gridControls", left : 0, right : 0, top : "searchBlock" },
   	        	    { name : "gridContent", left : 0, right : 0, top : "gridControls", bottom : 0 }
   	        	]);
	
 	// 그리드 선언
	var grid = buildGrid('.paySlipOpenDataMngGrid');
	
	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	
	// 팝업 데이터 정의 searchMode:single(단수),multi(복수)
	myForm.popupInfo = {
		calculationPopup   : {popupKind:'', confirmKind:'', calculationSetId:'', calculationSetName:'', calculationData:[]}
    };

	/***  이벤트 핸들러  ***/
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ) {
		case 'search':
			grid.getGridBase().cancel();
			var param = srchFormUtil.getValue();
			if(validator.isValid()) {
				grid.loadData('lgvhr','lgvpay/LGVPAY00011/retrievePaySlipOpenDateMngList', param, function(data){
					if( grid.getRowCount() == 0 ) {
						Message.alert('<lgcom:message code="note.nodata"/>');
					}
				} );
			}
			
			break;
		case 'save':
			var grid1 = grid.getGridBase();
			var param = {};
			
			try {
				grid.getGridBase().commit();
			} catch(e) {
				Message.alert(e.message);
				return;
			}
			if( grid.getRowCount() == 0 ) {
				Message.alert('<lgcom:message code="note.nodata"/>');
				return;
			};
			if(!grid.isChanged()) {
				Message.alert('<lgcom:message code="error.noChangedData"/>');
				return;
			}
				
			Message.confirm('<lgcom:message code="question.save"/>', function() {
				grid.useProgress(true);
				grid.saveChanges('lgvhr','lgvpay/LGVPAY00011/savePaySlipOpenDateMng', function(data, gridData ) {
					Message.alert('<lgcom:message code="note.saved"/>');
					myForm.select(".searchBlock button[data-action='search']").trigger('click');
				});
			});
		break;	
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
            	}
            });
            popupData.calculationData = [];
            break;
		}
		event.stopPropagation();
	});
	
	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});

	/***  내부 함수  ***/
	//그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		//필드 설정
		grid.setFields([
		   	{ fieldName: 'payrollCalculationExecId' , dataType:'text'},
		    { fieldName: 'payMonths'  				, dataType:'text'},
		    { fieldName: 'payTypeName'         		, dataType:'text'},
		    { fieldName: 'totalCount'         		, dataType:'number'},
		    { fieldName: 'totalNetSalary'    		, dataType:'number'},
		    { fieldName: 'paySlipOpenDate'         	, dataType:'text'},
		    { fieldName: 'hour'         			, dataType:'text'},
		    { fieldName: 'minutes'         			, dataType:'text'}
		]);
		// Lookup 설정
		grid.setLookupsMultiLvl({
			payTypeList:{data:code.get("payRunTypeList"), keyField:["code"]}
		});
		//컬럼 설정
		grid.setColumns([
  				{
					name:'payrollCalculationExecId',
					fieldName:'payrollCalculationExecId',
					width:0,
					header: {text:''},
					styles: {textAlignment:'center'},
					editable: false
				},
 				{
					name:'payMonths',
					fieldName:'payMonths',
					width:100,
					header: {text:'<lgcom:message code="label.pay.payMonthShort" />'},
					styles: {textAlignment:'center'},
					editable: false
				},
				{
					name:'payTypeName',
					fieldName:'payTypeName',
					width:300,
					header: {text:'<lgcom:message code="label.pay.payType" />'},
					styles: {textAlignment:'near'},
					editable: false	
				},
				{
					name:'totalCount',
					fieldName:'totalCount',
					width:200,
					header: {text:'<lgcom:message code="label.pay.totalCount"/>'},
					styles: {textAlignment:'far', numberFormat: '#,##0'},
					editable : false
				},	
				{
					name:'totalNetSalary',
					fieldName:'totalNetSalary',
					width:200,
					header: {text:'<lgcom:message code="label.pay.totalNetSalary" />'},
					styles: {textAlignment:'far', numberFormat: '#,##0'},
					editable : false
				},	
				{
					name:'paySlipOpenDate',
					fieldName:'paySlipOpenDate',
					width:120,
					header: {text:'<lgcom:message code="label.pay.paySlipOpenDate" />'},
					styles: {textAlignment:'center'},
					editor: {type:'date',textReadOnly : true, datetimeFormat:'dd/MM/yyyy'}
				},	
				{
					name:'hour',
					fieldName:'hour',
					width:80,
					type: 'data',
					header: {text:'<lgcom:message code="label.pay.hour" />'},
					lookupDisplay: true,
					sortable: false,
					values: ["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24"],
					
					editor: {type:'dropDown', textReadOnly : true,editable: true},
					styles: {textAlignment:'center'}
				},	
				{
					name:'minutes',
					fieldName:'minutes',
					width:80,
					type: 'data',
					header: {text:'<lgcom:message code="label.pay.minutes" />'},
					lookupDisplay: true,
					sortable: false,
					values: ["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20",
					         "21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40",
					         "31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50",
					         "51","52","53","54","55","56","57","58","59"],
					editor: {type:'dropDown', textReadOnly : true,editable: true},
					styles: {textAlignment:'center'}
				}
		]);
		//그리드 필수값 체크 
		grid.setValidations([
			{criteria: "value['payTypeName'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.payType'/>"/>',mode:'always',level:'error'},
			{criteria: "value['paySlipOpenDate'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.paySlipOpenDate'/>"/>',mode:'always',level:'error'},
			{criteria: "value['hour'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.hour'/>"/>',mode:'always',level:'error'},
			{criteria: "value['minutes'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.minutes'/>"/>',mode:'always',level:'error'}
		]);
		//옵션 설정
		grid.setOptions({
			grid: {
				hideDeletedRows: false,
				indicator: {visible:false},
				panel: {visible:false},
				checkBar: {visible:false},
				footer: {visible:false},
				paste: {enabled:false}, /*paste 기능막기 */
				sorting  : {enabled:false}, /*Sorting 기능을 막는다.*/
                sortMode : "explicit",
				edit: {
					insertable: true,
					appendable: true,
					updatable: true,
					deletable: true
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
}

LGVPAY00011.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGVPAY00011();
		form.init();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2></h2> 
		</div>
		<div class="searchBlock">
			<form class="form search-wrap">
				<table class="table">
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
		                	<th><label><lgcom:message code="label.pay.calculationSet" /></label></th>
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
		                </tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
			</form>
		</div>
		<%-- 그리드 버튼 영역 --%>
		<div class="gridControls module-group text-right">
			<div class="btn-toolbar">	
				<div class="btn-group">	
					<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save" data-access="LGVPAY00011/savePaySlipOpenDateMng"><lgcom:message code="save"/></button>				
				</div>
			</div>			
		</div>
	<div class="gridContent grid-wrap">
		<div class="grid paySlipOpenDataMngGrid"></div>
	</div>
	</section>
</div>
</body>
</html>
