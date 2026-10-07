<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY00028.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2024 LG CNS,  All rights reserved.

-------------------------------------------------------------%>
<html lang="ko">
<head>
<title><lgcom:message code="label.pay.paySlip.paySlip"/></title>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<style type="text/css">
.totalMoneyEachBankBlock{
top: 160px !important;
}
.payrollInforBlock
{
 top: 324px !important;
}
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>

<%-- 급여 담당자 권한이 있는지 여부 체크 --%>
<script type="text/javascript">
var LGVPAY00028 = function() {
	var myForm = this;
	var srchFormUtil         = new FormUtil( myForm, ".searchBlock form" );

	myForm.setLayout( [ 
		{ name : "searchBlock",             left : 0, right : 0, top : 0 },
	    { name : "totalSalaryBlock",    left : 0, right : 0, top : "searchBlock", bottom : "totalMoneyEachBankBlock"},
	    { name : "totalMoneyEachBankBlock",    left : 0, right : 0, top : "totalSalaryBlock", bottom : "payrollInforBlock"},
	    { name : "payrollInforBlock",    left : 0, right : 0, top : "totalMoneyEachBankBlock"}
	]);
    myForm.searchConditionControl( true );
    
	myForm.popupInfo = {
		executionListPopup : {searchMode:'single', payMonthName :'', payTypeCode:'', searchFlag:'', executionData:[]}
	};
    var valueset = new ValueSet("lgcom");
	valueset.add("payTypeList", {valueSetId : "LGVPAY_PAYSLIP_PAY_TYPE_LIST", employeeNo:"${sessionScope.LGVHR_PROJECT_SESSION.employeeNo}", languageCode:SESSION_USER.languageCode});
	valueset.execute();
	
	srchFormUtil.initCombo("payrollCalculationExecId", valueset.get("payTypeList"), {selectAll:false});
    
   	var validator = new Validator( myForm, ".searchBlock form" );
    
    validator.setRule( {
	    rules: {
	    	payrollCalculationExecId:{required:true}
	    },
	    messages: {
	    	payrollCalculationExecId: {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.executionId'/>" />'}
	    	,payrollCalculationExecId: {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.paySlip.payType'/>" />'}
	    }
    });

    
    // Event
	myForm.addEvent( "click", "button[data-action]", function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}                                                                                                                                                                                                                                             
		var action = $.trim(item.data('action'));
		switch( action ){
			case "search" :
				if ( validator.isValid() ) {
					var param = {payrollCalculationExecId : srchFormUtil.getValue("payrollCalculationExecId")
							    };
					var actionName = "lgvpay/LGVPAY00028/retrieveValidateMasterPayrollCalcExecId";
					myForm.transaction("lgvhr", actionName, param, function(data) {
						if ( data.result ) {
							fncRetrievePaySlipData();
						} else {
							Message.alert("<lgcom:message code="note.NoPermission"/>");
							return ;
						}
					});
				}
				break;
				
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
                		fncSearchData();
                	}
                });
                popupData.executionData = [];
                break;
		}
		event.stopPropagation();
	});

	//wrong payroll list
	function fncpayrollInforBlock() {
		var tBody = myForm.select(".incomeDeductionTable>tbody");
		fncDeleteTableRow(tBody);
		if ( payrollInforList != null && payrollInforList.length > 0 ) {
			$(payrollInforList).each(function() {
				var tr = "<tr>"+
						 "	<td class=\"text-center\">"+nvl(this["payrollCalculationExecId"])+"</td>"+
						 "	<td class=\"text-center\">"+ nvl(this["employeeNo"])     +"</td>"+
						 "	<td class=\"text-center\">"+ nvl(this["payrollTypeName"])       +"</td>"+
						 "	<td class=\"text-center\">" + nvl(this["organizationName"]) +"</td>"+
						 "	<td class=\"text-center\">" + nvl(this["basePayAmount"])       +"</td>"+
						 "	<td class=\"text-center\">"+nvl(this["taxAmount"])+"</td>"+
						 "	<td class=\"text-center\">"+ nvl(this["fixedPayTotalAmount"])     +"</td>"+
						 "	<td class=\"text-center\">"+ nvl(this["variableAllowance"])       +"</td>"+
						 "	<td class=\"text-center\">" + nvl(this["aggregateTaxationAmount"]) +"</td>"+
						 "	<td class=\"text-center\">" + nvl(this["taxFreeSumAmount"])       +"</td>"+
						 "	<td class=\"text-center\">"+nvl(this["assessmentAddAmount"])+"</td>"+
						 "	<td class=\"text-center\">"+ nvl(this["totalIncomeAmount"])     +"</td>"+
						 "	<td class=\"text-center\">"+ nvl(this["salaryTotalAmount"])       +"</td>"+
						 "	<td class=\"text-center\">" + nvl(this["deductionTotalAmount"]) +"</td>"+
						 "	<td class=\"text-center\">" + nvl(this["probationPeriodOdwgAmount"])       +"</td>"+
						 "	<td class=\"text-center\">"+nvl(this["ordinaryWagesAmount"])+"</td>"+
						 "	<td class=\"text-center\">"+ nvl(this["bankTransferAmount"])     +"</td>"+
						 "	<td class=\"text-center\">"+ nvl(this["bankName"])       +"</td>"+
						 "	<td class=\"text-center\">" + nvl(this["paymentBankAccountNo"]) +"</td>"+
						 "</tr>";
				tBody.append(tr);
			});
		}
	}
	
	//totalSalary
	function fnctotalSalaryBlock() {
		var tBody = myForm.select(".totalSalaryTable>tbody");
		fncDeleteTableRow(tBody);
		if ( totalSalaryInfor != null && totalSalaryInfor.length > 0 ) {
			$(totalSalaryInfor).each(function() {
				var tr = "<tr>"+
						 "	<td class=\"text-center\">"+nvl(this["totalEmp"])+"</td>"+
						 "	<td class=\"text-center\">"+ nvl(this["totalSalary"])+"</td>"+
						 "</tr>";
				tBody.append(tr);
			});
		}
	}
	
	//totalMoneyEachBank
	function fnctotalMoneyEachBankBlock() {
		var tBody = myForm.select(".totalMoneyEachBankTable>tbody");
		fncDeleteTableRow(tBody);
		if ( totalBankInforList != null && totalBankInforList.length > 0 ) {
			$(totalBankInforList).each(function() {
				var tr = "<tr>"+
						 "	<td class=\"text-center\">"+nvl(this["bankName"])+"</td>"+
						 "	<td class=\"text-center\">"+ nvl(this["totalMoney"])+"</td>"+
						 "</tr>";
				tBody.append(tr);
			});
		}
	}
	
	
	function fncSearchData() {
			myForm.select(".searchBlock button[data-action='search']").trigger("click");
	}

	function fncContentInit() {
		
		payrollInforList = [];
		totalSalaryInfor = [];
		totalBankInforList = [];
		
		fncpayrollInforBlock();
		fnctotalSalaryBlock();
		fnctotalMoneyEachBankBlock();
	}
	function fncDeleteTableRow(tBody) {
		tBody.empty();
	}
	function fncContentInit( sClassName ){ 
		myForm.select("."+sClassName).find("span").each(function(inx) {
			$(this).text("");
		});
	}
	
	var payrollInforList = [];
	var totalSalaryInfor = [];
	var totalBankInforList = [];
	function fncRetrievePaySlipData(actionType) {
		myForm.showProgress();
		fncContentInit();
		
		var param = { payrollCalculationExecId : srchFormUtil.getValue("payrollCalculationExecId")
				    };
		
		var actionName = "lgvpay/LGVPAY00028/retrievePaySlipData";
		
		myForm.transaction("lgvhr", actionName, param, function(data) {
			myForm.hideProgress();
			var searchData = data.result["searchData"];
			payrollInforList = data.result["payrollInforList"];
			totalSalaryInfor = data.result["totalSalaryInfor"];
			totalBankInforList = data.result["totalBankInforList"];

			if ( actionType == "init" ) {
				srchFormUtil.setValue({ payrollCalculationExecId : $.trim(searchData["payrollCalculationExecId"])
					                  , payMonth                 : $.trim(searchData["payMonth"])
					                  , payType                  : $.trim(searchData["payType"]) 
					                  });
			} else {
				if ( isNull(srchFormUtil.getValue("payMonth")) && !isNull($.trim(searchData["payMonth"])) ) {
					srchFormUtil.setValue({ payMonth : $.trim(searchData["payMonth"]) });
				}
				if ( isNull(srchFormUtil.getValue("payType")) && !isNull($.trim(searchData["payType"])) ) {
					srchFormUtil.setValue({ payType : $.trim(searchData["payType"]) });
				}
			}
			
			fncpayrollInforBlock();
			fnctotalSalaryBlock();
			fnctotalMoneyEachBankBlock();
		}, function () { myForm.hideProgress(); });
		
	}
	
}

LGVPAY00028.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVPAY00028();
		form.init();		
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2><lgcom:message code="label.pay.paySlip.paySlip"/></h2>
		</div>
		<div class="searchBlock">
			<form class="form search-wrap" method="post">
				<table class="table" >
					<colgroup>
						<col width="100"></col>
						<col width="250"></col>
						<col width="130"></col>
					</colgroup>
					<tbody>
						<tr>
		                	<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.pay.executionId" /></label></th>
							<td>
		                		<div class="input-group input-group-sm input-search">
	                                <input class="form-control input-sm" name="payrollCalculationExecId" type="text" readonly>
	                                <span class="input-group-btn">
	                                    <button class="btn btn-default ico-lgd" type="button" data-action="openPopupExecutionList">
	                                        <span class="fa fa-search" aria-hidden="true"></span>
	                                    </button>
	                                </span>
	                            </div>
		                	</td>
		                	<th><label><lgcom:message code="label.pay.payMonth" /></label></th>
		                	<td><input type="text" class="form-control input-sm size_70" name="payMonth" data-action="change" readonly /></td>
		                	<th><label><lgcom:message code="label.pay.payType" /></label></th>
		                	<td><input type="text" class="form-control input-sm" name="payType" data-action="change" readonly /></td>
		                </tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
			</form>
		</div>
		<%-- //searchBlock --%>

		<div class="row totalSalaryBlock">
			<div class="sub-header"><h4><lgcom:message code="label.pay.paySlip.totalSalaryInformation"/></h4></div>
			<table class="table table-condensed table-bordered totalSalaryTable" summary="Total Sanary Info">
				<caption class="sr-only-lgd">Total Employee & Salary Info</caption>
				<colgroup>
					<col width="5%"></col><!-- income > category (1차) -->
					<col width="5%"  ></col><!-- income > category (2차) -->
				</colgroup>
				<thead>
					<tr>
					<th scope="row"><label><lgcom:message code="label.pay.totalEmp"/></label></th>
					<th scope="row"><label><lgcom:message code="label.pay.paySlip.totalSalary"/></label></th>
					</tr>
				</thead>
				<tbody>
				</tbody>
			</table>
		</div>
		<%-- //totalSalaryBlock --%>
		<div class="row totalMoneyEachBankBlock">
			<div class="sub-header"><h4><lgcom:message code="label.pay.paySlip.totalMoneyBankInformation"/></h4></div>
			<table class="table table-condensed table-bordered totalMoneyEachBankTable" summary="Total Bank Money Info">
				<caption class="sr-only-lgd">Total Money Each Banks</caption>
				<colgroup>
					<col width="5%"></col><!-- income > category (1차) -->
					<col width="5%"  ></col><!-- income > category (2차) -->
				</colgroup>
				<thead>
					<tr>
					<th scope="row"><label><lgcom:message code="label.pay.paySlip.bankName"/></label></th>
					<th scope="row"><label><lgcom:message code="label.pay.paySlip.totalSalary"/></label></th>
					</tr>
				</thead>
				<tbody>
				</tbody>
			</table>
		</div>
		<%-- //totalSalaryBlock --%>
		<div class="row payrollInforBlock">
			<div class="sub-header"><h4><lgcom:message code="label.pay.paySlip.wrongPayrollList"/></h4></div>
			<table class="table table-condensed table-bordered incomeDeductionTable" summary="Income Deduction Info">
				<caption class="sr-only-lgd">Payroll problems Info</caption>
				<colgroup>
					<col width="5%"></col><!-- income > category (1차) -->
					<col width="5%"  ></col><!-- income > category (2차) -->
					<col width="5%"></col><!-- income > amount -->
					<col width="5%"></col><!-- income > category (1차) -->
					<col width="5%"></col><!-- income > category (2차) -->
					<col width="5%"></col><!-- income > hr(시간) -->
					<col width="5%"></col><!-- income > amount -->
					<col width="5%"></col><!-- income > category (1차) -->
					<col width="5%"  ></col><!-- income > category (2차) -->
					<col width="5%"></col><!-- income > amount -->
					<col width="5%"></col><!-- income > category (1차) -->
					<col width="5%"></col><!-- income > category (2차) -->
					<col width="5%"></col><!-- income > hr(시간) -->
					<col width="5%"></col><!-- income > amount -->
					<col width="5%"></col><!-- income > category (1차) -->
					<col width="5%"  ></col><!-- income > category (2차) -->
					<col width="5%"></col><!-- income > amount -->
					<col width="5%"></col><!-- income > category (1차) -->
					<col width="5%"></col><!-- income > category (2차) -->
				</colgroup>
				<thead>
					<tr>
					<th scope="row"><label><lgcom:message code="label.pay.executionId"/></label></th>
					<th scope="row"><label><lgcom:message code="label.pay.paySlip.employeeNo"/></label></th>
					<th scope="row"><label><lgcom:message code="label.pay.payType"/></label></th>
					<th scope="row"><label><lgcom:message code="label.pay.paySlip.organization"/></label></th>
					<th scope="row"><label><lgcom:message code="label.pay.baseAmount"/></label></th>
					<th scope="row"><label><lgcom:message code="label.pay.taxAmount"/></label></th>
					<th scope="row"><label><lgcom:message code="label.pay.fixedPayTotalAmount"/></label></th>
					<th scope="row"><label><lgcom:message code="label.pay.variableAllowance"/></label></th>
					<th scope="row"><label><lgcom:message code="label.pay.aggregateTaxationAmount"/></label></th>
					<th scope="row"><label><lgcom:message code="label.pay.taxFreeSumAmount"/></label></th>
					<th scope="row"><label><lgcom:message code="label.pay.assessmentAddAmount"/></label></th>
					<th scope="row"><label><lgcom:message code="label.pay.paySlip.income"/></label></th>
					<th scope="row"><label><lgcom:message code="label.pay.paySlip.total"/></label></th>
					<th scope="row"><label><lgcom:message code="label.pay.paySlip.deduction"/></label></th>
					<th scope="row"><label><lgcom:message code="label.pay.paySlip.probSalOldSal"/></label></th>
					<th scope="row"><label><lgcom:message code="label.pay.paySlip.norSalNewSal"/></label></th>
					<th scope="row"><label><lgcom:message code="label.pay.paySlip.netSalary"/></label></th>
					<th scope="row"><label><lgcom:message code="label.pay.paySlip.bankName"/></label></th>
					<th scope="row"><label><lgcom:message code="label.pay.paySlip.accountNumber"/></label></th>
					</tr>
				</thead>
				<tbody>
				</tbody>
			</table>
		</div>
		<%-- //payrollInforBlock --%>
	</section>
</div>
</body>
</html>
