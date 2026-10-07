<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGUTLC00203.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2016 LG CNS,  All rights reserved.

    설 명 : Currency Sample
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Currency Sample</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">

var LGUTLC00203 = function(){
    var grid;
    var myForm = this;

 	// 조회조건 Combo 초기화
	var searchForm = new FormUtil(myForm,'.searchBlock form');
	var dataForm = new FormUtil(myForm,'.dataArea form');
	dataForm.setCurrencyInfo( { currency : "currencyCode",
	    	                    defaultCurrency : "USD",
		                        target : { "unitPrice" : { precisionType : "EXT" },
	    	                    	       "amount"    : { precisionType : "EXT" } } } );


	var multiForm = new FormUtil( myForm, ".multiRowTest");

	dataForm.addChangeEvent(function(newval, oldval, changed) {
		trace('===============> number changed');
	});

 	myForm.addEvent("click", "[data-action]", function( event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
 		switch( action ) {
	 		case "search" :
	 		    var data = JSON.parse( searchForm.getValue("result") );
	 		    dataForm.setValue( data );
	 			break;

            case "save" :

            	trace( dataForm.getValue() );

                break;
	 		case "excelDown" :

				Message.confirm( "<lgcom:message code="question.excelDownload" />", function(){

					var downloader = new Downloader( myForm );
				    downloader.excel2( "lgcom", "lgutlc/LGUTLC00203/createTempTable", JSON.parse(  searchForm.getValue("result")  ) );

				});

				break;
			case "csvDown" :

				Message.confirm( "<lgcom:message code="question.excelDownload" />", function(){

					var downloader = new Downloader( myForm );
					downloader.csv( "lgcom", "lgutlc/LGUTLC00203/createTempTable", JSON.parse(  searchForm.getValue("result")  ) );
				});

				break;

			case "sendMessage" :
				$('<input type="text" id="input01" name="quantity" class="form-control input-sm size_120" data-numeral="PREC:5" value="123456"/>').insertAfter( myForm.select(".dataForm [name='quantity']") );
				myForm.applyFormatManually(".dataArea");
				break;

			case "getData" :
				myForm.select(".multiRowTestResult").text( JSON.stringify( multiForm.getValue() ) );
				break;
 		}

 	});


};

LGUTLC00203.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch( function(){
		var form = new LGUTLC00203();
		form.init();
	});
});
</script>
</head>
<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Currency Sample</h2>
	</div>

	<div class="searchBlock">
		<form class="form search-wrap">
				<table class="table" >
					<colgroup>
						<col width="550"/>
						<col width="*"/>
					</colgroup>
					<tbody>
						<tr>
							<td><input type="text"  name="result" class="form-control input-sm input-require" value='{ "currencyCode" : "USD", "unitPrice" : 2023121.4121212, "quantity" : 1024 , "amount" : 12111.15787845, "myRadio" : 2 , "myCheck" : 3}'></td>
						</tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm" type="button" data-action="search"><lgcom:message code="search" /></button>
		</form>
	</div>

	<%-- 그리드 버튼 영역 --%>
	<div class="gridControls module-group text-right">
		<button class="btn btn-default btn-sm" type="button" role="button" data-action="getData" >getDataTest</button>
		<button class="btn btn-default btn-sm" type="button" role="button" data-action="sendMessage" >Apply Format Manually</button>
		<button class="btn btn-gray btn-sm" type="button" role="button" data-action="save" ><lgcom:message code="save"/></button>
	</div>

	<div class="dataArea">
		<form class="dataForm" >
			<table class="table table-condensed" summary="입력 테이블">
				<caption class="sr-only-lgd">입력 테이블</caption>
				<colgroup>
					<col width="17%"/>
					<col width="*"/>
				</colgroup>
				<tbody>
					<tr>
						<th scope="row">
							<label for="input01"><i class="asterisk">*</i>Currency</label>
						</th>
						<td>
							<select class="form-control input-sm size_100" name="currencyCode"></select>
						</td>
					</tr>
					<tr>
						<th scope="row">
							<label>Unit Price</label>
						</th>
						<td colspan="3">
							<input type="text" id="input01" name="unitPrice" class="form-control input-sm size_120" data-numeral="PREC:1"/>
						</td>
					</tr>

					<tr>
						<th scope="row">
							<label>Quantiy</label>
						</th>
						<td colspan="3">
							<input type="text" id="input01" name="quantity" class="form-control input-sm size_120" data-numeral="PREC:5" />
						</td>
					</tr>

					<tr>
						<th scope="row">
							<label >Amount</label>
						</th>
						<td colspan="3" height="30px" style="vertical-align:middle;">
							<span class="text-rubric" name="amount" data-numeral="PREC:3" ></span>
						</td>
					</tr>

                    <tr>
                        <th scope="row">
                            <label >Radio</label>
                        </th>
                        <td colspan="3" height="30px" style="vertical-align:middle;">
                            <div class="radio radio-uxp radio-inline">
							    <input type="radio" id="inlineRadio1" name="myRadio" value="1" >
							    <label for="inlineRadio1">1</label>
							</div>
							<div class="radio radio-uxp radio-inline">
							    <input type="radio" id="inlineRadio2" name="myRadio" value="2">
							    <label for="inlineRadio2">2</label>
							</div>
							<div class="radio radio-uxp radio-inline">
							    <input type="radio" id="inlineRadio3" name="myRadio" value="3">
							    <label for="inlineRadio3">3</label>
							</div>
                        </td>
                    </tr>

                    <tr>
                        <th scope="row">
                            <label >ChechBox</label>
                        </th>
                        <td colspan="3" height="30px" style="vertical-align:middle;">
							<div class="checkbox checkbox-uxp checkbox-inline">
							    <input type="checkbox" id="inlineCheckbox1" name="myCheck" value="1">
							    <label for="inlineCheckbox1">1</label>
							</div>
							<div class="checkbox checkbox-uxp checkbox-inline">
							    <input type="checkbox" id="inlineCheckbox2" name="myCheck" value="2">
							    <label for="inlineCheckbox2">2</label>
							</div>
							<div class="checkbox checkbox-uxp checkbox-inline">
							    <input type="checkbox" id="inlineCheckbox3" name="myCheck" value="3">
							    <label for="inlineCheckbox3">3</label>
							</div>
                        </td>
                    </tr>


				</tbody>
			</table>
		</form>
	</div>

	<div class="panel panel-default ">
	    <pre><code class="javascript" >
var dataForm = new FormUtil(myForm,'.dataArea form');
dataForm.setCurrencyInfo( { currency : "currencyCode",
                            defaultCurrency : "USD",
	                        target : { "unitPrice" : { precisionType : "EXT" },
                                       "amount"    : { precisionType : "EXT" } } } );
	    </code></pre>
	</div>

	<div>
	    <form class="multiRowTest">
	        <table class="table">
	            <tbody>
	                <tr> <td><input name="data10" value="878456312" data-numeral="PREC:3" /> name : data10 </td> <td><input name="data20" value="986413213" data-numeral="PREC:3" /> name : data20 </td> </tr>
		            <tr> <td><input name="data1" value="15486843213" data-numeral="PREC:3" /> name : data1 </td> <td><input name="data2" value="545678765678" data-numeral="PREC:3" /> name : data2 </td> </tr>
	                <tr> <td><input name="data1" value="123123124" data-numeral="PREC:3"  /> name : data1 </td> <td><input name="data2" value="58465135468133" data-numeral="PREC:3" /> name : data2 </td> </tr>
	                <tr> <td><input name="data1" value="23523445234" data-numeral="PREC:3"  /> name : data1 </td> <td><input name="data2" value="87463541321" data-numeral="PREC:3" /> name : data2 </td> </tr>
                </tbody>
	        </table>
	    </form>

        <div class="panel panel-default multiRowTestResult" style="width:100%; height:200px;">
	    </div>
	</div>
</section>
</div>
</body>
</html>