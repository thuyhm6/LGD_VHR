<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGUTLC00402.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : Cache Monitor
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Cache Monitor</title>
<style type="text/css">
.inputCacheData {
	position: absolute; 
	top: 50%; 
	right: 0px; 
	width: 500px; 
	height: 300px; 
	text-align:right; 
	z-index:1;
}

.inputCacheData textarea {  
   font-size: 15px;
   width: 500px;   
}

</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGUTLC00402 = function() {
	var myForm = this;
	myForm.select(".inputCacheData textarea").text("/command \n/**\n * The cache names are need to be typed in lowerCamelCase.\n * The format you need to meet is represented blow.\n */\n {\n    \"cacheName1\" : [\n    { \n        \"key\": \"\",\n        \"value\": { \"key\" : \"value\" }\n    } ],\n    \"cacheName2\": [\n    { \n        \"key\": \"\",\n        \"value\": {  }\n    } ]\n}");

    myForm.setManagedLayout({
    	searchBlock  : { left:0, top:0 , right:0 },
        cacheItems : { left:0, top:SINGLE_LINE.top1, right:0 , bottom : 0},
    });
	
    var timer = setInterval( function(){
    	myForm.select(".loading").text("Loading .... ");
    	getCacheItemsList("batchScheduleInfoCache");
    }, 10000 );
    
    this.destroy = function(){
    	clearInterval( timer );
    }
    
    
    myForm.addEvent("click", ".searchBlock button", function(event) {
    	var action = $(event.target).data("action");
    	
    	switch( action ) {
    	case "search" :
    		getCacheItemsList();
    		break;
    		
    	case "input" :
    		$('.inputCacheData').css({opacity: 0, visibility: "visible"}).animate({opacity: 1.0}, 0);
    		break;
    	}
    });
    
    myForm.addEvent("click", ".inputCacheData button", function(event) {
    	var action = $(event.target).data("action");

    	switch( action ) {
			case "submit" :
				var contents = myForm.select('.inputCacheData textarea').val();
				var commandStart = contents.indexOf("/command");
				var commandEnd = contents.indexOf(";");
				var command = $.trim(contents.substring(commandStart+8, commandEnd));
				var commentStart = contents.indexOf("/*");
				var commentEnd = contents.indexOf("*/", commentStart);
				var jsonContents = JSON.parse( $.trim(contents.substring(commentEnd+3)) );
			     
				Message.confirm('<lgcom:message code="question.WouldyouliketoConfirm"/>', function() {
					$('.inputCacheData').css({opacity: 1, visibility: "hidden"}).animate({opacity: 0}, 0);
					setCacheItemsList( jsonContents );
					$('.inputCacheData textarea').empty(); 
					Message.alert('<lgcom:message code="Completed"/>');
				}); 
				break;
    	}
    });
    $( ".inputCacheData" ).draggable();
    getCacheItemsList();

    function getCacheItemsList( target ) {
		var param = {};
		if( target == undefined ) {
			param["target"] = target;
		}
		
		myForm.transaction( "lgcom", "lgutlc/LGUTLC00402/retrieveCacheItems", param, function(data){
			myForm.select(".dataTableBody").empty(); 
			var cacheItems = data["result"];
			
			//trace(cacheItems)
            $.each( cacheItems, function(key, value){
            	var list = value;
            	
            	switch( key )  {
            	case "menuCache" :
            		var target = myForm.select(".menu_cache");
            		
            		$(list).each( function( inx ){
            			target.append("<tr>" + 
            					         "<td>"+ this["menuId"]+"</td>"+
            					         "<td>"+ this["menuName"]+"</td>"+
            					         "<td>"+ this["systemCode"]+"</td>"+
            					         "<td>"+ this["moduleCode"]+"</td>"+
            					         "<td>"+ this["programId"]+"</td>"+
            					         "<td>"+ this["displayFlag"]+"</td>"+
            					         "<td>"+ this["serviceCount"]+"</td>"+
            					      "</tr>");
            		});
            		
            		break;
            		
            	case "commonCodeCache" :
            		var target = myForm.select(".commonCode_cache");
            		
            		$(list).each( function( inx ){
            			target.append("<tr>" + 
            					         "<td>"+ this["key"]+"</td>"+
            					         "<td>"+ this["value"]+"</td>"+
            					      "</tr>");
            		});
            		
            		break;            		
            		
            	case "profileCacheSite" :
            		var target = myForm.select(".profile_site");
            		
            		$(list).each( function( inx ){
            			target.append("<tr>" + 
            					         "<td>"+ this["key"]+"</td>"+
            					         "<td>"+ this["value"]+"</td>"+
            					      "</tr>");
            		});
            		break;
            		
            	case "profileCacheSystem" :
            		var target = myForm.select(".profile_system");
            		
            		$(list).each( function( inx ){
            			target.append("<tr>" + 
            					         "<td>"+ this["key"]+"</td>"+
            					         "<td>"+ this["value"]+"</td>"+
            					      "</tr>");
            		});
			
            		break;
            		
            	case "profileCacheUser" :
					var target = myForm.select(".profile_user");
					
					$(list).each( function( inx ){
            			target.append("<tr>" + 
            					         "<td>"+ this["key"]+"</td>"+
            					         "<td>"+ this["value"]+"</td>"+
            					      "</tr>");
            		});
			
            		break;
            		
            	case "batchSecheduleInfoCache" : 
					var target = myForm.select(".batchSchedule");
					//trace("batchScheduleInfoCache");
					$(list).each( function( inx ){
            			target.append("<tr>" + 
            					         "<td><pre>"+ JSON.stringify(this, null, 2 )+"</pre></td>"+
            					      "</tr>");
            		});
			
					myForm.select(".loading").text("");
            		break;

            	case "batchRunningInfoCache" : 
					var target = myForm.select(".batchRunning");
					//trace("batchRunningInfoCache");
					$(list).each( function( inx ){
            			target.append("<tr>" + 
            					         "<td><pre>"+ JSON.stringify(this, null, 2 )+"</pre></td>"+
            					      "</tr>");
            		});
			
					myForm.select(".loading").text("");
            		break;
            		
            	case "debugCache" :
            		var target = myForm.select(".debug_cache");
            		
            		$(list).each( function( inx ){
            			target.append("<tr>" + 
            					         "<td>"+ this["key"]+"</td>"+
            					         "<td>"+ this["value"]+"</td>"+
            					      "</tr>");
            		});
            		break;
            		
            	case "serviceCache" :
					var target = myForm.select(".service_cache");
					
					$(list).each( function( inx ){
            			target.append("<tr>" + 
            					         "<td>"+ this["key"]+"</td>"+
            					         "<td>"+ this["value"]+"</td>"+
            					      "</tr>");
            		});
            		break;
            	}
            });			
		});
	} 
    
	function setCacheItemsList( jsonContents ) {
		param["rawJsonData"] = jsonContents;
		transaction( "lgcom", "lgutlc/LGUTLC00402/saveCacheItems", param, function(data){
			myForm.select(".searchBlock form button[data-action='search']").trigger("click");
		}); 
	}
};

LGUTLC00402.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGUTLC00402();
		form.init();
	});
});
</script>
</head>
<body> 
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Cache Monitor</h2>
	</div>
	<div class="searchBlock">

		<form class="form search-wrap">
		        <table class="table table-condensed" >
		            <tbody>
		                <tr>
		                    <td></td>
		                    <td><button class="btn btn-lgd btn-sm" type="button" data-action="input"><lgcom:message code="input" /></button></td>
		                </tr>
		            </tbody>
		        </table>
		        <button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
		</form>
	</div>
	<div class="cacheItems">
		<ul class="nav nav-tabs">
		    <li class="active"><a href="#_cache_monitor_menu" data-toggle="tab"><lgcom:message code="MenuCache"/></a></li>
		    <li><a href="#_cache_monitor_profile" data-toggle="tab"><lgcom:message code="Profile"/></a></li>
		    <li><a href="#_cache_monitor_batchSchedule" data-toggle="tab"><lgcom:message code="BatchSchedule"/></a></li>
		    <li><a href="#_cache_monitor_batchRunning" data-toggle="tab"><lgcom:message code="BatchRunning"/></a></li>
		    <li><a href="#_cache_monitor_logger" data-toggle="tab"><lgcom:message code="Logger"/></a></li>
		</ul>
		<!-- /nav-tabs -->
		<div class="tab-content">
				<div class="tab-pane fade active in" id="_cache_monitor_menu">
				    <table class="table table-condensed">
				       <thead>
				           <tr>
				               <th><lgcom:message code="MenuId"/></th>
				               <th><lgcom:message code="MenuName"/></th>
				               <th><lgcom:message code="System"/></th>
				               <th><lgcom:message code="Module"/></th>
				               <th><lgcom:message code="ProgramId"/></th>
				               <th><lgcom:message code="DisplayFlag"/></th>
				               <th><lgcom:message code="ServiceCount"/></th>
				           </tr>
				       </thead>
				       <tbody class="dataTableBody menu_cache"></tbody>
				    </table>		
				</div>
				
				<div class="tab-pane fade" id="_cache_monitor_profile">
					<ul class="nav nav-tabs inner-tabs">
						<li class="active"><a href="#_cache_monitor_profile_site" data-toggle="tab"><lgcom:message code="Site"/></a></li>
						<li><a href="#_cache_monitor_profile_system" data-toggle="tab"><lgcom:message code="System"/></a></li>
						<li><a href="#_cache_monitor_profile_user" data-toggle="tab"><lgcom:message code="User"/></a></li>
					</ul>
					<!-- /inner-tabs -->
					<div class="tab-content inner-content">
						<div class="tab-pane fade active in" id="_cache_monitor_profile_site">
							<table class="table table-condensed">
								<thead>
									<tr>
										<th><lgcom:message code="key"/></th>
				               			<th><lgcom:message code="value"/></th>
									</tr>
								</thead>
								<tbody class="dataTableBody profile_site"></tbody>
							</table>
						</div>

						<!-- /tab-pane -->
						<div class="tab-pane fade" id="_cache_monitor_profile_system">

							<table class="table table-condensed">
								<thead>
									<tr>
										<th><lgcom:message code="key"/></th>
				               			<th><lgcom:message code="value"/></th>
				               			
									</tr>
								</thead>
								<tbody class="dataTableBody profile_system"></tbody>
							</table>

						</div>

						<!-- /tab-pane -->
						<div class="tab-pane fade" id="_cache_monitor_profile_user">
							<table class="table table-condensed">
								<thead>
									<tr>
										<th><lgcom:message code="key"/></th>
				               			<th><lgcom:message code="value"/></th>
				               		
									</tr>
								</thead>
								<tbody class="dataTableBody profile_user"></tbody>
							</table>
						</div>
						<!-- /tab-pane -->
					</div>
					<!-- /tab-content -->
				</div>

				<div class="tab-pane fade" id="_cache_monitor_batchSchedule">
				    <table class="table table-condensed">
				       <thead>
				           <tr>
				               <th>Value <span class="loading"></span></th>
				           </tr>
				       </thead>
				       <tbody class="dataTableBody batchSchedule""></tbody>
				    </table>		
				</div>
				<div class="tab-pane fade" id="_cache_monitor_batchRunning">
				    <table class="table table-condensed">
				       <thead>
				           <tr>
				               <th>Value <span class="loading"></span></th>
				           </tr>
				       </thead>
				       <tbody class="dataTableBody batchRunning""></tbody>
				    </table>		
				</div>				

	            <div class="tab-pane fade" id="_cache_monitor_logger">
	                <ul class="nav nav-tabs inner-tabs">
	                    <li class="active"><a href="#_cache_monitor_logger_debug" data-toggle="tab"><lgcom:message code="Debug"/></a></li>
	                    <li><a href="#_cache_monitor_logger_service" data-toggle="tab"><lgcom:message code="Service"/></a></li>
	                </ul>
	                <!-- /inner-tabs -->
	                <div class="tab-content inner-content">
	                    <div class="tab-pane fade active in" id="_cache_monitor_logger_debug">
	                       <table class="table table-condensed">
									<thead>
										<tr>
											<th><lgcom:message code="key"/></th>
					               			<th><lgcom:message code="value"/></th>
										</tr>
									</thead>
									<tbody class="dataTableBody debug_cache"></tbody>
							</table>
	                    </div>
	                    <!-- /tab-pane -->
	                    <div class="tab-pane fade" id="_cache_monitor_logger_service">
	                        <table class="table table-condensed">
									<thead>
										<tr>
											<th><lgcom:message code="key"/></th>
					               			<th><lgcom:message code="value"/></th>
										</tr>
									</thead>
									<tbody class="dataTableBody service_cache"></tbody>
							</table>
	                    </div>
	                    <!-- /tab-pane -->
	                </div>
	                <!-- /tab-content -->             
	            </div>
		
		</div>
		<!-- /tab-content -->	
	</div>
	
	<!-- /input-area -->
	<div class="inputCacheData" id="inputCacheData"  style="visibility: hidden">
		<form class="cachae-data form eventForm">
			<table class="table table-condensed">
				<tr>
				     <td><textarea rows="20" cols="50"></textarea></td>
				</tr>
				<tr>
				   <td></td>					
				</tr>
			</table>
			<button class="btn btn-darkgray btn-xs" data-action="submit">Submit</button>
		</form>
	</div>
	</section>
</div>
</body>
</html>
