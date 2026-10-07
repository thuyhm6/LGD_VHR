<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGSMPC00200.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : Batch Test
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Summary</title>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">

var LGSMPC00200 = function(){
    var myForm = this;
    
    myForm.addEvent("click", "button", function( event ){
    	var action = $(event.target).data("action");
        switch( action ) {
        case "mailBatch":
        	var param = { "data" : { programId : "LGBATC00020" } };
        	myForm.transaction( 'lgcom', "lgsmpc/LGSMPC00200/sendExecuteRequest", param , function( data ){
        		trace( data );
        	});
        	break;        
        case "toSystem":
        	var param = { "data" : { programId : "LGBATC00010" } };
        	myForm.transaction( 'lgcom', "lgsmpc/LGSMPC00200/sendExecuteRequest", param , function( data ){
        		trace( data );
        	});
        	break;
        	
        case "mailTest":
        	myForm.transaction( 'lgcom', "lgsmpc/LGSMPC00200/sendMailTest", {} , function( data ){
        		trace( data );
        	});
        	break;
        case "discretionaryTest" :
        	var param = { pgmSeq : "2410", orgId : "89", requestorEmpNo : "T966018", rangeCode : "AMOUNT", uomCode : "KRW" , rangeValue : "0" };
        	myForm.transaction( 'lgcom', "common/webServiceSubscribe/getDiscretionaryList", param , function( data ){
        		trace( data );
        	});
        	break;
        case "dqTest" : 
        	var param = { data : { programId : "LGUTLC00083", 
        		                   queryMode:"RUN",
        		                   accessGroup:"LGCOM",
        		                   queryId:"1002",
        		                   executeAs:"Y",
        		                   sqlArg:{ "Employee No":"x030807" } } };
        	myForm.transaction( 'lgcom', "lgsmpc/LGSMPC00200/sendExecuteRequest", param , function( data ){
        		trace( data );
        	});
        	break;
        }
    	
    });

};

LGSMPC00200.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch( function(){
		var form = new LGSMPC00200();
		form.init();		
	});
});
</script>
</head>
<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Profile</h2>
	</div>
	<div class="searchBlock">
		<button data-action="mailBatch">Batch MailBatch</button>
		<button data-action="toSystem">Batch Common API ( to System )</button>  
		<button data-action="mailTest">Mail Test</button>
		<button data-action="discretionaryTest">재량권 Test</button>
		<button data-action="dqTest">DQ Test</button>
		<select name="select02-sm" class="form-control input-sm" multiselect >
			<option selected>전체</option>
			<option>1</option>
			<option>2</option>
			<option>3</option>
			<option>4</option>
			<option>5</option>
		</select>
	</div>
    <div class="approvalArea">
				<table class="approvalInfoTable table table-condensed">
					<colgroup>
						<col width="50">
						<col width="150">
						<col width="300">
						<col width="300">
						<col width="*">
					</colgroup>
					<thead>
						<tr>
							<th>Seq.</th>
							<th>Approval Type</th>
							<th>Approver</th>
							<th>Mandator</th>
							<th></th>
						</tr>
					</thead>
					<tbody>
					<tr data-row-index="0">
					<td class="text-center"><span name="seq">1</span><input name="approvalSeqs" type="hidden" value="1"></td>
					<td class="text-center"><select name="approvalActionCode" class="form-control input-sm size_120">
					<option value="APPROVAL">Approval</option><option value="AGREEMENT">Agreement</option><option value="PARAGREE_ALL">Parallel Agree All</option>
					<option value="PARAGREE_OR">Parallel Agree Anyone</option></select></td>
					<td>송성근 /  / 경영관리 PI 팀<input name="requestMasterId" type="hidden" value="">
					<input name="requestCode" type="hidden" value="51002"><input name="applicationUserId" type="hidden" value="">
					<input name="employeeNo" type="hidden" value="T966018"><input name="settlementDeleteFlag" type="hidden" value="Y">
					<input name="approvalLineId" type="hidden" value=""></td><td><input name="mandatorUserId" type="hidden" value="">
					<input name="mandatorEmployeeNo" type="hidden" value=""></td>
					<td><button class="icon-plus" role="button" data-action="vadd" data-target="approvalInfoTable"></button>
					<button class="icon-trash" role="button" data-action="vdel" data-target="approvalInfoTable"></button></td>
					</tr>
					</tbody>
				</table>
			</div>	
	</section>
</div>
</body>
</html>