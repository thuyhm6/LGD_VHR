<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY00007.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 급여다당자가 급여를 실행하는 화면입니다.
    작성자 : 손수양
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Summary</title>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">

var LGVPAY00007 = function(){
    var myForm = this;
    
    var runForm = new FormUtil( myForm, ".payrollRun");
    
    
    myForm.addEvent("click", "button", function( event ){
    	var action = $(event.target).data("action");
        switch( action ) {
        case "run1" :
        	alert(runForm.getValue("assignmentSetId") );
        	var assignmentSetId = runForm.getValue("assignmentSetId") ;
        	var periodId        = runForm.getValue("periodId") ;
        	
        	var runTypeName     = runForm.getValue("runTypeName");
        	var payrollCalculationExecId = runForm.getValue("payrollCalculationExecId") ;
        	
        	alert(payrollCalculationExecId);
        	var startEmployeeNo = runForm.getValue("startEmployeeNo1") ;
        	var endEmployeeNo = runForm.getValue("endEmployeeNo1") ;
        	
        	
           
           var param = { data : { programId : "LGVPAYC0013", 
        	            empNo : "", 
        	            assignmentSetId : assignmentSetId,
        	            periodId : periodId,
        	            runTypeName :runTypeName,
        	            startEmployeeNo : startEmployeeNo,
        	            endEmployeeNo : endEmployeeNo,
        	            payrollCalculationExecId :payrollCalculationExecId,errBuf :null} };
           
           
           myForm.transaction( 'lgvhr', "lgvpay/LGVPAYC0000/sendExecuteRequest", param , function( data ){
        		trace( data );
        	});
            
            //var param = { "data" : { programId : "LGVPAYC0014" } };
        	//myForm.transaction( 'lgcom', "lgsmpc/LGSMPC00200/sendExecuteRequest", param , function( data ){
        //		trace( data );
        	//});
        	
        	break;
        }
    	
    });

};

LGVPAY00007.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch( function(){
		var form = new LGVPAY00007();
		form.init();		
	});
});
</script>
</head>
<body>
<div class="mdi-container">
<section class="page-content">
  <div>
    <form class="payrollRun">
    assignmentSetId  <input name="assignmentSetId" type="text" value="1"> 
    periodId         <input name="periodId" type="text" value="33"> 
    runTypeName      <input name="runTypeName" type="text" value="MTH">
    payrollCalculationExecId  <input name="payrollCalculationExecId" type="text" value="335">
    <button data-action="run1">Run1</button> 
    <input name="startEmployeeNo1" type="text" value="VH000001">
    <input name="endEmployeeNo1" type="text" value="VH000304">
    </form>
  </div>    
</section>
</div>
</body>
</html>