<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : excelUploader.jsp
    프로젝트명 : LGD WCFW 프로젝트

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : Excel Upload Popup
    작성자 : WCFW
-------------------------------------------------------------%>
<style>
#_excel_uploader_error_view_ {
    position : absolute;
    top: 20px;
    left: 100px;
    right: 100px;
    bottom: 20px;
    background-color : #FFFFFF;
    z-index : 1205;
    display : none;
}

#_excel_uploader_error_view_ .table {
    width : auto;
    max-width : none;
    white-space: nowrap;
}

#_excel_uploader_error_view_ .panel-body {
    height : calc( 100% - 70px);
}

#_excel_uploader_error_view_ .tableWrapper {
    width : 100%;
    height : 100%;
    overflow : auto;
}

#_excel_uploader_error_view_ .gridControls {
    margin-top : 10px;
}

#_excel_uploader_error_view_ .gridControls .btn {
    font-size : 12px;
    padding : 4px 10px;
}

</style>

<div id="_excel_uploader_" class="modal fade" tabindex="-1" role="dialog" data-backdrop="static" data-keyboard="false">
	<div class="modal-dialog" role="document">
		<div class="modal-content">
			<div class="modal-header" style="position:relative;">
				<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
				<h4 class="modal-title"><lgcom:message code="ExcelUploader" /></h4>
			</div>
			<div class="modal-body">
				<div class="grid-wrap uploadComponent" style="padding: 10px 0px; position : relative">
					<button type="button" class="btn btn-default btn-sm ico-lgd _button_upload_"><i class="fa fa-upload" aria-hidden="true"></i> <lgcom:message code="FileSelect"/></button>
					<span class="_button_upload_text_"></span>
					<input class="fileList" type="file"  name='files[]' multiple style="display:none"/>
					<input class="_fileupload_" type="file"  style="display:none" />

					<div style="position : absolute; top: 10px; right : 0px;">
						<div class="loader"></div>
						<button type="button" class="btn btn-default btn-sm ico-lgd uploadComponent"  data-action="upload" style="width: 65px;" disabled ><lgcom:message code="Upload"/></button>
					</div>
					<div class="_progress">
						<div class="bar" style="width: 0%;"></div>
					</div>
					<!--
					<div class="progress">
						<div class="progress-bar" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style="width: 60%;">60%</div>
					</div>
					-->
				</div>

				<div>
					<table class="table table-condensed">
						<colgroup>
							<col width="150px"/>
							<col width="90px" />
							<col width="*"    />
						</colgroup>
						<thead>
							<tr>
								<th></th>
								<th>Status</th>
								<th>Message</th>
							</tr>
						</thead>
						<tbody>
							<tr>
								<td style="font-weight : bold;"><lgcom:message code="Step1" /></td>
								<td class="_upload_status_"><lgcom:message code="Ready" /></td>
								<td class="_upload_status_message_"></td>
							</tr>
							<tr>
								<td style="font-weight : bold;"><lgcom:message code="Step2" /></td>
								<td class="_post_process_status_"><lgcom:message code="Ready" /></td>
								<td class="_post_process_status_message_"></td>
							</tr>
						</tbody>
					</table>
				</div>

				<ul class="list-unstyled" style="margin-top: 5px;">
					<li class="text-rubric"><i class="fa fa-exclamation-circle"></i><lgcom:message code="note.excelUploadNotice" /></li>
				</ul>

				<div class="grid-wrap" style="height: 30px; position : relative">
					<div style="position : absolute; top: 0px; right : 0px;">
						<button type="button" class="btn btn-default btn-sm ico-lgd" data-action="errors"  style="width: 65px;" ><lgcom:message code="Errors" /></button>
						<!--  <button type="button" class="btn btn-default btn-sm ico-lgd" data-action="launchPostProcess" data-action="upload" disabled style="width: 65px;"><lgcom:message code="Confirm"/></button>  -->
					</div>
				</div>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-gray btn-sm modalClose"  data-action="close"><lgcom:message code="Close" /></button>
			</div>
		</div><!-- /.modal-content -->
	</div><!-- /.modal-dialog -->
</div>

<div id="_excel_uploader_error_view_" class="panel panel-default">
	<div class="panel-heading"><span style="font-weight : bold;"><lgcom:message code="ExcelUploadError" /></span><span class="programId" ></span> <button type="button" class="close" data-action="previewClose"><span aria-hidden="true">&times;</span></button></div>
	<div class="panel-body">
		<div class="tableWrapper"></div>
		<div class="gridControls">
			<button type="button" class="btn btn-default btn-sm" data-action="excelDownload"><span class="ico ico-excel-down"></span>  <lgcom:message code="excelDown" /></button>
			<button type="button" class="btn btn-gray" data-action="errorWindowClose"><lgcom:message code="Close" /></button>
		</div>
	</div>
</div>

<script>
/**
 * 엑셀 Content 업로드
 * options.uploadType : options 값이 없거나 uploadType이 없을 경우 erp를 기본으로 사용한다.
 *              erp - ERP에 있는 XXLGE_IMPORT_INFO 테이블을 Temp 테이블로 사용한다.(기본값)
 *              lgcom - LGCOM 전용의 LGCOM_IMPORT_INFO_T, LGCOM_IMPORT_N 테이블을 사용한다.
 */
var ExcelUploader = function( context, programId, options ) {
	if( programId == undefined ) {
		alert("Program Id is mendatory.");
		return;
	}
	if( options == undefined ) {
		options = { uploadType: 'lgcom' };  
	}

	var defaultOption = {
		uploadType: 'lgcom'
	};

	options = $.extend(defaultOption, options);
	if($.trim(options['uploadType']) == '') {
		options['uploadType'] = 'lgcom';
	}

	var url = "/"+context+"/attachment/upload/excel/" + programId + "/" + options['uploadType'];
	var sessionId = 0, rowCount = 0, columnCount = 0 ;
	var callback, closeCallback;
	this.open = function( _callback, _closeCallback ) {
		callback = _callback;
		closeCallback = _closeCallback;

		init();
		$('#_excel_uploader_').modal('show');
	}

	function init() {
		sessionId = 0;
		uploadType = '';
		rowCount = 0;
		columnCount = 0 ;

		$("#_excel_uploader_ .uploadComponent button[data-action='upload']").prop("disabled", true);

		$('#_excel_uploader_ ._progress .bar').css( 'width', "0%" );

		if( $('#_excel_uploader_ ._fileupload_').data("fileupload") != undefined ) {
			$('#_excel_uploader_ ._fileupload_').fileupload('destroy');
		}

		$('#_excel_uploader_ .fileList, #_excel_uploader_ ._fileupload_').each( function(){
			$(this).replaceWith( $(this).clone(true) );
		});

		$("#_excel_uploader_ ._button_upload_text_").text( "" );
		$("#_excel_uploader_ ._upload_status_").text( "Ready" );
		$("#_excel_uploader_ ._upload_status_message_").text( "" );
		$("#_excel_uploader_ ._post_process_status_").text( "Ready" );
		$("#_excel_uploader_ ._post_process_status_message_").text( "" );

		$("#_excel_uploader_ .loader").hide();
		$("#_excel_uploader_ [data-action='launchPostProcess']").prop("disabled", true );
		$("#_excel_uploader_ [data-action='errors']").hide();

		var option =  {
			url : url,
			dataType: 'json',
			done: function (e, data) {
				init();
				var serverMessage = data.jqXHR.responseJSON._server_message_;
				if( serverMessage.type == "SYSTEM_ERROR" ) {
					var errorMessage = "";
					if( data.files ) {
						$.each(data.files, function (index, file) {
							errorMessage = serverMessage.text + "<br><strong> "+ file.name +" </strong> size : " + file.size + " bytes.";
						});
						Message.alert( errorMessage );
					} else {
						Message.alert( serverMessage.text );
					}
				} else {
					var result = data.jqXHR.responseJSON;
					rowCount = Number( result["recordCount"] + "").toLocaleString("kr");
					sessionId = result["sessionId"];
					uploadType = (($.trim(result["uploadType"]) == '') ? 'erp':$.trim(result["uploadType"]));
					columnCount = result["columnCount"];
					$("#_excel_uploader_ ._upload_status_").text( "<lgcom:message code="Completed" />" );
					$("#_excel_uploader_ ._upload_status_message_").text( rowCount + " Rows imported with Session Id : " + sessionId );


					$("#_excel_uploader_ [data-action='launchPostProcess']").removeAttr("disabled");
					$("#_excel_uploader_ [data-action='preview']").removeAttr("disabled");

					try{
						$("#_excel_uploader_ ._post_process_status_").text( "<lgcom:message code="Processing" />" );
						$("#_excel_uploader_ ._post_process_status_message_").text( "" );
						callback.call( this, sessionId, uploadType );
					} catch( e ){
						$("#_excel_uploader_ ._post_process_status_").text( "<lgcom:message code="Error" />" );
						$("#_excel_uploader_ ._post_process_status_message_").text( "Post processor is undefined. Operation canceled." );
					} finally{
						retrieveExcelUploadErrorCount(  sessionId, uploadType );
					}
				}
			},
			progressall: function (e, data) {
				var progress = parseInt(data.loaded / data.total * 100, 10);
				$("#_excel_uploader_ ._progress .bar").css( 'width', progress + '%' );
			},
			fail : function (e, data) {
				trace( "upload fail ");
				trace( data );
			}
		};

		var uploader = $("#_excel_uploader_ ._fileupload_").fileupload( option );
		uploader.error(function( jqXHR, textStatus, errorThrown ) {
			trace( jqXHR );
		});

		$("#_excel_uploader_ ._fileupload_").data("fileupload", uploader );
	}

	function showErrors() {
		var param = { 'sessionId' : sessionId , 'uploadType' : uploadType, 'columnCount' : columnCount };

		var plate = $("#_excel_uploader_error_view_ .tableWrapper");
		plate.empty();

		var table = $("<table class='table table-condensed'><thead></thead><tbody></tbody></table>");
		plate.append( table );

		transaction("lgcom", "lgsysc/LGSYSC00210/retrieveExcelUploadErrorList", param, function( data ){
			var list = data["result"];
			$(list).each( function( row ){
				var item = this;
				if( item["rowType"] == "H" ) {
					var tr = $("<tr></tr>");
					tr.append("<th>Row Num</th>");
					tr.append("<th>Error Message</th>");
					for( var inx = 1 ; inx <= param.columnCount ; inx ++ ) {
						tr.append("<th row='"+ ( row + 1 )+"' col='"+ inx +"'>"+ nvl( item["attribute" + inx ] )+"</th>");
					}
					table.find("thead").append( tr );
					$("#_excel_uploader_error_view_ .programId").text( "( Program : "+item["programId"] + " Session ID : " + item["sessionId"] + " )" );
				} else {
					var tr = $("<tr></tr>");
					tr.append("<td align='center'>"+ item["seqNo"] +"</td>");
					tr.append("<td width='150px'>"+ nvl( item["errorMessage"] ) +"</td>");
					for( var inx = 1 ; inx <= param.columnCount ; inx ++ ) {
						tr.append("<td>"+ nvl( item["attribute" + inx ] )+"</td>");
					}
					table.find("tbody").append( tr );
				}
			});

			// 이 조회의 결과를 엑셀 다운로드 하기 위해, 버튼에 정보를 부여한다.
			$("button[data-action='excelDownload']").data("sessionId", param.sessionId );
			$("button[data-action='excelDownload']").data("uploadType", param.uploadType );
			$("button[data-action='excelDownload']").data("columnCount", param.columnCount );

			// TH 에 대한 Cell Merging을 위해 데이터 정비작업 수행
			/*
			$(table.find("thead > tr") ).each( function( inx ) {
				var former = "";
				$( $(this).find("th[col]")).each( function( jnx ){
					if( jnx < 2 ) {
						former = "";
						return true;
					}
					var cell = $(this);
					if( cell.text() == "" ) {
						cell.text( former );
					} else {
						former = cell.text();
					}
				});
			});

			for( var inx = 1 ; inx <= param.columnCount ; inx++ ) {
				var former = "";
				$( table.find("thead").find("th[col='"+ inx +"']") ).each( function(){
					var cell = $(this);
					if( cell.text() == "" ) {
						cell.text( former );
					} else {
						former = cell.text();
					}
					trace( former );
				});
				//table.rowspan( inx - 1 );
			}
			// table.colspan( 0 );
			//table.colspan( 1 );
			// table.colspan( 2 );
			//table.colspan( 3 );
			*/
			plate = null;
		});
		$("#_excel_uploader_error_view_").show();
	}

	function hideErrors() {
		$("#_excel_uploader_error_view_ .tableWrapper").html("");
		$("#_excel_uploader_error_view_").hide();
	}

	function retrieveExcelUploadErrorCount( sessionId, uploadType ) {
		var param = {'sessionId' : sessionId, 'uploadType' : uploadType };
		transaction("lgcom", "lgsysc/LGSYSC00210/retrieveExcelUploadErrorCount", param, function( data ){
			var errorCount = Number( data["result"][0]["errorCount"] );
			if( errorCount == 0 ){
				$("#_excel_uploader_ ._post_process_status_").text( "<lgcom:message code="Completed" />" );
				$("#_excel_uploader_ ._post_process_status_message_").text( "" );
				$("#_excel_uploader_ [data-action='errors']").hide();
			} else {
				$("#_excel_uploader_ ._post_process_status_").text( "<lgcom:message code="Error" />" );
				$("#_excel_uploader_ ._post_process_status_message_").text( "<lgcom:message code="note.excelUploadErrorReport" /> " + errorCount + " <lgcom:message code="note.excelUploadErrorReportPost" />");
				$("#_excel_uploader_ [data-action='errors']").show();
			}
		});
	}

	ExcelUploader.init = function(){
		init();
	}

	//버튼들의 통합 이벤트 핸들러
	$(document).on( "click.excel_uploader", "#_excel_uploader_ [data-action], #_excel_uploader_error_view_ [data-action]", function( event ){
		var action = $(this).data("action");
		switch( action ) {
			case "upload" :
				if( $("#_excel_uploader_ .fileList").val() == "" ) {
					return;
				}
				$("#_excel_uploader_ .uploadComponent button[data-action='upload']").prop("disabled", true);

				var filesList = $('#_excel_uploader_ .fileList').prop('files');
				$('#_excel_uploader_ ._fileupload_').fileupload('send',  {files: filesList }   );
				$("#_excel_uploader_ .loader").show();
				$("#_excel_uploader_ ._upload_status_").text("<lgcom:message code="Processing" />");
				$("#_excel_uploader_ ._upload_status_message_").text("");
				break;
			case "close" :
				init();
				try{
					closeCallback.call( this, sessionId, uploadType );
				}catch( e ) {}
				$('#_excel_uploader_').modal('hide');
				break;
			case "launchPostProcess" :
				if( callback ) {
					Message.confirm( "Do you want to launch post process ?", function(){
						try{
							callback.call( this, sessionId );
						}catch( e ) {}
					});
				} else {
					Message.alert("Post process is undefined !");
				}
				break;
			case "errors" :
				showErrors();
				break;
			case "previewClose" :
				hideErrors();
				break;
			case "errorWindowClose" :
				hideErrors();
				break;
			case "excelDownload" :
				var param = { sessionId : $(event.target).data("sessionId"), uploadType : $(event.target).data("uploadType"), columnCount : $(event.target).data("columnCount") };
				Message.confirm( "<lgcom:message code="question.excelDownload" />", function(){
					var downloader = new Downloader();
					downloader.excel( "lgcom", "lgsysc/LGSYSC00210/createExcelExportData", param );
				});
				break;
		}
	});
}

$('#_excel_uploader_').on('hidden.bs.modal', function (e) {
	ExcelUploader.init();
	$('#_excel_uploader_').removeData();
	$(document).off( ".excel_uploader");
	document.location.href = "#";
});

$('#_excel_uploader_').on('shown.bs.modal', function (e) {
	ExcelUploader.init();
	document.location.href = "#_excel_uploader_";
});

$("#_excel_uploader_ ._button_upload_").click( function(){
	$("#_excel_uploader_ .fileList").click();
});

$("#_excel_uploader_ .fileList").change( function(){
	$("#_excel_uploader_ ._button_upload_text_").text(  $(this).val()  );
	if( $(this).val() == "" ) {
		$("#_excel_uploader_ .uploadComponent button[data-action='upload']").prop("disabled", true);
	} else {
		$("#_excel_uploader_ .uploadComponent button[data-action='upload']").removeAttr("disabled");
	}
});

/*
 *
 * 같은 값이 있는 열을 병합함
 *
 * 사용법 : $('#테이블 ID').rowspan(0);
 *
 */
$.fn.rowspan = function(colIdx, isStats) {
	return this.each(function() {
		var that;
		$('tr', this).each(function(row) {
			$('th:eq('+colIdx+')', this).filter(':visible').each(function(col) {
				if ($(this).html() == $(that).html() && (!isStats || isStats && $(this).prev().html() == $(that).prev().html() ) ) {
					rowspan = $(that).attr("rowspan") || 1;
					rowspan = Number(rowspan)+1;
					$(that).attr("rowspan",rowspan);

					// do your action for the colspan cell here
					$(this).hide();

					//$(this).remove();
					// do your action for the old cell here
				} else {
					that = this;
				}
				// set the that if not already set
				that = (that == null) ? this : that;
			});
		});
	});
};

/*
 *
 * 같은 값이 있는 행을 병합함
 *
 * 사용법 : $('#테이블 ID').colspan (0);
 *
 */
$.fn.colspan = function(rowIdx) {
	return this.each(function() {
		var that;
		$('tr', this).filter(":eq("+rowIdx+")").each(function(row) {
			$(this).find('th').filter(':visible').each(function(col) {
				if ($(this).html() == $(that).html()) {
					colspan = $(that).attr("colSpan") || 1;
					colspan = Number(colspan)+1;

					$(that).attr("colSpan",colspan);
					$(this).hide(); // .remove();
				} else {
					that = this;
				}
				// set the that if not already set
				that = (that == null) ? this : that;
			});
		});
	});
}
</script>
