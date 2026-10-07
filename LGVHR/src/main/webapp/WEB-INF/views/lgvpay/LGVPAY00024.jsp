<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY00024.jsp
    프로젝트명 : 베트남 소급 급여 시스템 구축

   Copyright(c) 2018 LG CNS,  All rights reserved..

    설 명 : 소급 급여실적 일괄다운로드
    작성자 : 이형준
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<script src="/lgvhr/static/js/lgvatt.js"></script>
<script type="text/javascript">
var LGVPAY00024 = function() {
	var myForm = this;
    var _this = this;
	var result;
	// Form Util 선언
	var srchForm = '.searchBlock form';
	var srchFormUtil = new FormUtil( myForm, srchForm );
	
	//var code = new CommonCode('lgcom');
	//code.add('payType', {codeTypeCode:'LGVHR_PAY_RUN_TYPE'});
	//code.execute();
	
	var valueset = new ValueSet("lgcom");
	valueset.add("payTypeList", {valueSetId : "LGVPAY_PAYSLIP_PAY_TYPE_LIST", employeeNo:"${sessionScope.LGVHR_PROJECT_SESSION.employeeNo}", languageCode:SESSION_USER.languageCode});
	valueset.execute();
	
	//combo setting
	//srchFormUtil.initCombo('payType',code.get('payType'),{selectAll:false,selectEmpty:true});
	srchFormUtil.initCombo("payrollCalculationExecId", valueset.get("payTypeList"), {selectAll:false});
	
 	//필수항목 체크
   	var validator = new Validator( myForm, srchForm );
	
   	validator.setRule( {
    	option: {placement: 'right'},
	    rules: {
	    	payrollCalculationExecId: {required:true}
	    },
	    messages: {
	    	payrollCalculationExecId: {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.executionId'/>" />'}
	    }
    });
   	
   	myForm.setLayout( [ 
   	        		{ name : "searchBlock", left : 0, right : 0, top : 0 },
   	        		{ name : "gridControls", left : 0, right : 0, top : "searchBlock" }
   	        	]);
   	
   	srchFormUtil.setValue( {
   		//payMonth : DateUtil.today("MM/YYYY")
    });
	
	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	
	// 팝업 데이터 정의 searchMode:single(단수),multi(복수)
	myForm.popupInfo = {
		userPopup   : {searchMode:'single', popupKind:'', confirmKind:'', employeeNo:'', employeeName:'', attDate:'', userData:[]},
		executionListPopup : {searchMode:'single', payMonthName :'', payTypeCode:'', searchFlag:'', executionData:[]},
        returnPopup : {returnComment:''}
    };
	$("input[name=employeeNo]").keydown(function (key) {
		if(key.keyCode == 13) {
			myForm.select(".searchBlock button[data-action='openPopupApprover']").trigger('click');
		}
	});

	/***  이벤트 핸들러  ***/
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ) {
		// Execution List 팝업
	    case "openPopupExecutionList" :
	    	var popupData = myForm.popupInfo.executionListPopup;
	    	popupData.payMonthName = srchFormUtil.getValue("payMonth");
	    	popupData.searchFlag = "Y";

            var popup = new Popup( myForm,'lgvhr', 'M_LGVPAY_1019', '<lgcom:message code="label.pay.executionList"/>' );
            popup.setSize(800,494);
            popup.open( function() {
            	if ( popupData.executionData != null && popupData.executionData.length > 0 ) {
            		var selectData = popupData.executionData[0];
            		
            		srchFormUtil.setValue({ payrollCalculationExecId : selectData.payrollCalculationExecId
						                  , payMonth                 : selectData.payMonthName
						                  , payType                  : selectData.payTypeName });
            	} 
            });
            popupData.executionData = [];
            break;
		case 'directCSV':
			if(validator.isValid()) {
				var payMonthSplit = srchFormUtil.getValue("payMonth").split("/");
				var payMonth = payMonthSplit[1]+payMonthSplit[0];
				srchFormUtil.setValue("searchPayMonth", payMonth);
				
				Message.confirm('<lgcom:message code="question.excelDownload"/>',function() {
					var downloader = new Downloader( myForm );
					var param = srchFormUtil.getValue();
					param = $.extend(param, {languageCode:SESSION_USER.languageCode});
					downloader.csvDirectDownload("lgvhr", "LGVPAY00024.createDirectCSVDownloadData", param);
				});
			}
		break;
     	// 유저 검색 팝업
	    case "openPopupApprover" :
            console.log("openPopupApprover");
            var _popup = _this.popupInfo.userPopup;
            _popup.searchMode   = "single";
            _popup.popupKind    = "";
            _popup.confirmKind  = "";
            _popup.employeeNo = srchFormUtil.getValue("employeeNo");
            _popup.employeeName = srchFormUtil.getValue("employeeName");
            _popup.fseYn = "N";
            _popup.flsaYn = "N";

            srchFormUtil.setValue({employeeNo : '', employeeName : ''});
            
            var popup = new Popup( _this,'lgvhr', 'M_LGVCOM_1010', '<lgcom:message code="UserSearch"/>' );
            popup.setSize(800,494);
            popup.open( function(){
            	srchFormUtil.setValue({employeeNo  :_popup.userData[0].employeeNo});
            	srchFormUtil.setValue({employeeName   :_popup.userData[0].employeeName});
            });
            _popup.userData = [];
            break;
			
		}
	});
	
	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});
}

LGVPAY00024.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGVPAY00024();
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
						<col width="120"></col>
						<col width="110"></col>
						<col width="160"></col>
						<col width="200"></col>
						<col width="100"></col>
						<col width="200"></col>
					</colgroup>
					<tbody>
						<tr>
		                    <th><i class="asterisk">*</i><label class="required" keyword><lgcom:message code="label.pay.executionId"/></label></th>
		                    <td>
		                		<div class="input-group input-group-sm input-search">
	                                <input class="form-control input-sm _find_origin_" name="payrollCalculationExecId" type="text" data-action="emptyAndPopup" readonly>
	                                <span class="input-group-btn">
	                                    <button class="btn btn-default ico-lgd find" type="button" data-action="openPopupExecutionList">
	                                        <span class="fa fa-search" aria-hidden="true"></span>
	                                    </button>
	                                </span>
	                            </div>
		                	</td>
		                	<th><label><lgcom:message code="label.pay.payMonth" /></label></th>
		                		<input type="hidden" name="searchPayMonth"> 
								<td><input type="text" class="form-control input-sm" name="payMonth" disabled></td>
							<th><label><lgcom:message code="label.pay.payType"/></label></th>
		                    <td>
		                        <div class="form-inline ">
                                	 <input type="text" class="form-control input-sm" name="payType" data-action="change" disabled /> 
                                	<!--<select class="form-control input-sm input-require" name="payType" id="payType"></select>-->
                            	</div>
		                    </td>
		                </tr>
						<tr>
		                	<th><label><lgcom:message code="label.pay.employeeNo" /></label></th>
								<td>
			                		<div class="input-group input-group-sm input-search">
		                                <input class="form-control input-sm _find_origin_" name="employeeNo" type="text" data-action="emptyAndPopup">
		                                <span class="input-group-btn">
		                                    <button class="btn btn-default ico-lgd find" type="button" data-action="openPopupApprover">
		                                        <span class="fa fa-search" aria-hidden="true"></span>
		                                    </button>
		                                </span>
		                            </div>
			                	</td>
							<th><label><lgcom:message code="label.pay.employeeName" /></label></th>
								<td><input type="text" class="form-control input-sm" name="employeeName"></td>
		                </tr>
					</tbody>
				</table>
				<%-- <button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button> --%>
			</form>
		</div>
		<%-- 그리드 버튼 영역 --%>
		<div class="gridControls module-group text-right">
			<div class="btn-toolbar">	
				<div class="btn-group">	
			        <button type="button" class="btn btn-default btn-sm" data-action="directCSV"><span class="ico ico-excel-down"  aria-hidden="true"></span> DirectCSV</button>
			     </div>
			</div>			
		</div>
	</section>
</div>
</body>
</html>
