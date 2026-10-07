<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<div id="_file_manager_" class="modal fileManagerPopup" role="dialog" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header dark">
                <button type="button" class="btn btn-ico close" data-dismiss="modal" aria-label="Close">
                    <span class="ico ico-popup-close" aria-hidden="true"></span>
                </button>
                <h1 class="modal-title">File Manager</h1>
            </div>
            <!-- /modal-header -->
            <div class="modal-body" >
                <div class="controls">
	                <form action="" class="search-wrap well text-right">
	                    <span class="_button_upload_text_ pull-left"></span>
	                    <input class="fileList" type="file"  name='files[]' multiple style="display:none"/>
	                    <input class="_fileupload_" type="file"  style="display:none" />          
	                    <button class="btn btn-darkgray btn-sm _button_upload_"  data-action="fileSelect" type="button"><lgcom:message code="FileSelect"/></button>
	                    <button type="button" class="btn btn-default btn-sm ico-lgd"  data-action="upload" disabled ><lgcom:message code="Upload" /></button>
	                    <!-- /partFoldingBtn -->
	                </form>
                </div>
                <!-- /search-wrap -->
                <div>
	                <table class="table table-bordered table-condensed _editable  _fileList">
	                    <colgroup>
	                        <col width="5%">
	                        <col width="40%">
	                        <col width="*">
	                        <col width="15%">
	                    </colgroup>
	                    <thead>
	                        <tr>
	                            <th></th>
	                            <th><lgcom:message code="AttachFileName"/></th>
	                            <th><lgcom:message code="FileDesc"/></th>
	                            <th></th>
	                        </tr>
	                    </thead>
	                    <tbody></tbody>
	                </table>
	                
	                <table class="table table-bordered table-condensed _readonly _fileList">
	                    <colgroup>
	                        <col width="45%">
	                        <col width="*">
	                        <col width="15%">
	                    </colgroup>
	                    <thead>
	                        <tr>
	                            <th><lgcom:message code="AttachFileName"/></th>
	                            <th><lgcom:message code="FileDesc"/></th>
	                            <th></th>
	                        </tr>
	                    </thead>
	                    <tbody></tbody>
	                </table>
                </div>  
	            <div class="_progress controls" style="width:0%; height: 10px; background:#E63C6B;"></div>
	            <div style="display:none;">
	                <span class="text-rubric controls" ><i class="fa fa-exclamation-circle"></i><span class="fileCount"></span> <lgcom:message code="note.fileManagerFileCount"/></span>
	            </div>
            </div>
            <!-- /modal-body -->
            <div class="modal-footer">
                <span class="_fileupload_server_message_ pull-left"></span>
                <button type="button" class="btn btn-darkgray btn-sm controls" data-action="saveAttachFileDescription" ><lgcom:message code="save"/></button>
                <button type="button" class="btn btn-gray btn-sm" data-action="confirm" ><lgcom:message code="Close"/></button>
            </div>
            <!-- /modal-footer -->
        </div>
        <!-- /modal-content -->
    </div>
    <!-- /modal-dialog -->
</div>

<div id="_file_manager_inline_" style="display:none;" >
	<div>
	    <!-- /search-wrap -->
	    <div>
	     <table class="table table-bordered table-condensed _editable  _fileList">
	         <colgroup>
	             <col width="5%">
	             <col width="40%">
	             <col width="*">
	             <col width="15%">
	         </colgroup>
	         <thead>
	             <tr>
	                 <th></th>
	                 <th><lgcom:message code="AttachFileName"/></th>
	                 <th><lgcom:message code="FileDesc"/></th>
	                 <th></th>
	             </tr>
	         </thead>
	         <tbody></tbody>
	     </table>
	     
	     <table class="table table-bordered table-condensed _readonly _fileList">
	         <colgroup>
	             <col width="45%">
	             <col width="*">
	             <col width="15%">
	         </colgroup>
	         <thead>
	             <tr>
	                 <th><lgcom:message code="AttachFileName"/></th>
	                 <th><lgcom:message code="FileDesc"/></th>
	                 <th></th>
	             </tr>
	         </thead>
	         <tbody></tbody>
	     </table>
	    </div>  
	 <div class="_progress controls" style="width:0%; height: 10px; background:#E63C6B;"></div>
	 <div style="margin-bottom:5px;display:none;">
	     <span class="text-rubric controls" ><i class="fa fa-exclamation-circle"></i><span class="fileCount"></span> <lgcom:message code="note.fileManagerFileCount"/></span>
     </div>	     
	</div>
	<!-- /modal-body -->
	<div class="button-toolbar controls pull-left">
	    <form>
	        <span class="_button_upload_text_ pull-left"></span>
	        <input class="fileList" type="file"  name='files[]' multiple style="display:none"/>
	        <input class="_fileupload_" type="file"  style="display:none" />          
	    </form>
        <button class="btn btn-darkgray btn-sm _button_upload_"  data-action="fileSelect" type="button"><lgcom:message code="FileSelect"/></button>
	    <button type="button" class="btn btn-default btn-sm ico-lgd"  data-action="upload" disabled ><lgcom:message code="Upload" /></button>	 
	    
	    <span class="_fileupload_server_message_"></span>   
	</div>
	<div class="button-toolbar controls pull-right">
	    <button type="button" class="btn btn-darkgray btn-sm " data-action="inlineConfirm" ><lgcom:message code="save"/></button>
	</div>
</div>

<!-- /modal -->

<script id="_fileNamager_row_template" type="text/template">
<tr>
    <td class="text-center align-middle">
        <div class="checkbox checkbox-uxp checkbox-inline">
            <input type="checkbox" id="inlineCheckbox2" value="option1">
            <label for="inlineCheckbox2"></label>
        </div>
    </td>
    <td class="align-middle"><span class=" _fileName" data-action="download"></span><span class="fileIndex" style="display:none;"></span></td>
    <td><input type="text" class="form-control input-sm _description"/></td>
    <td class="text-center align-middle">
        <button class="btn btn-sm btn-link" aria-label="삭제" data-action="delete" >
            <span class="ico ico-trace" aria-hidden="true"></span>
        </button>
        <button class="btn btn-sm btn-link" aria-label="다운로드" data-action="download" >
            <span class="ico ico-attach-down" aria-hidden="true"></span>
        </button>
    </td>
</tr>
</script>

<script id="_fileNamager_row_template_readonly" type="text/template">
<tr>
    <td class="align-middle"><span class=" _fileName"></span><span class="fileIndex" style="display:none;"></span></td>
    <td class="_description"></td>
    <td class="text-center align-middle">
        <button class="btn btn-sm btn-link" aria-label="다운로드" data-action="download" >
            <span class="ico ico-attach-down" aria-hidden="true"></span>
        </button>
    </td>
</tr>
</script>
	

<script>
var FileManager = function( myForm, options ) {
	var _this = this;
	var id = uuid();
    var table, template;
    var container;	
    
	if( options == undefined ){
		options = { editable : true,  moduleCode : "LGCOM" };
	} else {
		if( options.editable == undefined ) { options.editable = false; }
		if( options.moduleCode == undefined ) { options.moduleCode = "LGCOM"; }
	}
	
    var url = "/lgcom/attachment/upload/"+ options.moduleCode +"?fileGroupId=";
    var option =  {
            dataType: 'json',
            done: onUploadFinished,
            progressall: function (e, data) {
                var progress = parseInt(data.loaded / data.total * 100, 10);
                $(container).find("._progress").css( 'width', progress + '%' );
            },
            fail : function (e, data) {
            	$(container).find("._progress").css( 'width', "0%" );
                trace( "upload fail ");
                trace( data );
                if(options.inline) {
                    document.location.href = "#";
                }
            }
        };

	/* 메소드 구현 부분 */
	this.open = function( _options ) {  //fileGroupId, editable. callback )
	    options["inline"] = false;
	    
	    if( container == undefined ) {
			container = $("#_file_manager_").clone();
		    container.attr("id", id );
		    $("body").append( container );
		    
		    addEvent();
		    resetFileComponent();
	    }

		if( options["fileCount"] != undefined ){
			container.find(".fileCount").text( options.fileCount );	
			container.find(".fileCount").closest("div").show();
		}
	    
	    options["fileGroupId"] = _options["fileGroupId"];
       	options["editable"] = nvl( _options["editable"], false );
       	options["callback"] = _options["callback"];
       	
        options["uploadUrl"] = url + options["fileGroupId"];
       	loadData();
        
        //테이블 구성을 읽기전용 / 입력가능으로 구분하여 지정한다
        if( options["editable"] ) {
        	table = container.find("._fileList._editable");
        	template = $( $("#_fileNamager_row_template").text() );
        	container.find(".controls").show();
        } else {
        	table = container.find("._fileList._readonly");
        	template = $( $("#_fileNamager_row_template_readonly").text() );
        	container.find(".controls").hide();
        }
        
        table.show().siblings().hide();
        loadData();
        
        container.find("._fileupload_server_message_").text( "" );
        container.modal("show");
	}
	
	this.setFileGroupId = function( fileGroupId, loadDataFlag ) {
		options["fileGroupId"] = fileGroupId;
		
		if( loadDataFlag ) {
			loadData();
		}
	}
	
	this.inline = function( _options ){
		options["inline"] = true; 
		
		if( _options["fileGroupId"] != undefined  ) {
			options["fileGroupId"] = _options["fileGroupId"];	
		}
       	
       	options["editable"] = nvl( _options["editable"], true );
       	options["callback"] = _options["callback"];
       	
       	if( container == undefined ) {
    		container = $("#_file_manager_inline_").clone();
    		container.attr("id", id ).removeAttr("style");  
            myForm.select( options["container"]).append( container );
            
            //테이블 구성을 읽기전용 / 입력가능으로 구분하여 지정한다
            if( options["editable"] ) {
            	table = container.find("._fileList._editable");
            	template = $( $("#_fileNamager_row_template").text() );
            	container.find(".controls").show();
            } else {
            	table = container.find("._fileList._readonly");
            	template = $( $("#_fileNamager_row_template_readonly").text() );
            	container.find(".controls").hide();
            }        
            
    		if( options["fileCount"] != undefined ){
    			container.find(".fileCount").text( options.fileCount );	
    			container.find(".fileCount").parent().show();
    		}	            
            
            table.show().siblings().hide();
    	    addEvent();
    	    resetFileComponent();     
       	}
	}
	
	this.destroy = function(){		
		if( container == undefined )  return;
		
		container.off("." + id );
		container.remove();
		
		try{
			$(container).find("._fileupload_").fileupload('destroy');
		} catch(e){}
				
		
		trace( "[System] FileManager destroyed");
	}
	
	/* 일반 함수 구현부분  */
    function onUploadFinished(e, data) {
    	$(container).find("._progress").css( 'width', "0%" );
    	
        if(options.inline) {
            document.location.href = "#";
        }

        var serverMessage = data.jqXHR.responseJSON._server_message_;

        //파라미터로 이 값이 전달 됐다면 -> 서버에서오는 값이 동일하다.
        //파라미터로 이 값이 전달 되지 않았다면 -> 서버에서 신규 생성해서 값을 보내준다.
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
            //서버에서 보내준 fileGroupId 를 다시 담는다.
            options["fileGroupId"] = nvl( data.jqXHR.responseJSON.fileGroupId );
            options["uploadUrl"] = url + options["fileGroupId"];
            showManagerMessage ("<lgcom:message code="note.attachmentUploadSuccess"/>"); 
            loadData();
        }

        //파일 업로드 컴포넌트 관련 초기화를 진행한다. 
        resetFileComponent();
        $(container).find("._button_upload_text_").text( "" );
        
        try {
            options.callback.call( this, options["fileGroupId"] );
        } catch(e) {}
    }
	
	function resetFileComponent() {
        //파일 업로드 컴포넌트 관련 초기화를 진행한다. 
        $(container).find(".fileList, ._fileupload_").each( function(){
             $(this).replaceWith( $(this).clone(true) );
         });
        
        uploader = $(container).find("._fileupload_").fileupload( option );
	}
	
	function confirm(){
		container.modal('hide');
					
        try {
            if( table.find(".fileIndex").length > 0 ) {
                options.callback.call( this, options["fileGroupId"], options["	"] );
            } else {
                options.callback.call( this, null, null );
            }
        } catch( e ) {}
	}	
	
    function loadData(){
        myForm.transaction( "lgcom", "lgsysc/LGSYSC00210/selectAttachmentListByFileGroupId", { fileGroupId : options["fileGroupId"], moduleCode :  options["moduleCode"] }, function(data){
            var list = data["result"];
            var body = table.find("tbody");
            options["fileData"] = [];
            
            if( options.editable ) {
                body.empty();

                $(list).each( function( inx ) {
                    var row = template.clone();
                    row.find("._fileName").text( this["fileName"] ).data("id", this["fileId"] );
                    row.find("._description").val( this["fileDesc"] ).data("id", this["fileId"] );
                    
                    row.find("[data-action='download']").data( "module", this["moduleCode"]  );
                    row.find("[data-action='delete'], [data-action='download']").data( "id", this["fileId"] );
                    row.data("fileInfo", this );
                    body.append(row);

                    // 서버에서 보내준 파일 정보를 담는다.
                    options["fileData"].push({
                        fileGroupId: nvl( this["fileGroupId"] ),
                        fileId: nvl( this["fileId"] ),
                        fileName: nvl( this["fileName"] ),
                        moduleCode: nvl( this["moduleCode"] ),
                        downloadUrl: nvl( this["downloadUrl"] ),
                    });
                });
                
                if( list == undefined || list.length == 0 ) {
                    body.append("<tr><td colspan='4' class='noFiles'>No files</td></tr>");
                }
                
                // 수정모드일때만 파일 카운트를 세고, 화면에 업로드 가능/불가능 여부를 표시한다.
                if( options.fileCount != undefined ) {
                    if( $(body).find(".fileIndex").length < options.fileCount  ) {
                        $(container).find("._button_upload_, [data-action='upload']" ).removeAttr("disabled");
                    } else {
                        $(container).find("._button_upload_, [data-action='upload']" ).prop("disabled", true);
                        $(container).find("._fileupload_server_message_").text( "" );
                    }
                } else {
                    $(container).find("._button_upload_, [data-action='upload']" ).removeAttr("disabled");
                }
                
            }  else {
                body.empty();
                $(list).each( function( inx ){
                	var row = template.clone();
                    row.find("._fileName").text( this["fileName"] );
                    row.find("._description").text( this["fileDesc"] );
                    row.data("fileInfo", this );
                    body.append(row);
                });
                
                if( list == undefined || list.length == 0 ) {
                    body.append("<tr><td colspan='3' class='noFiles'>No files</td></tr>");
                }
            }
        });
    }	
    
	function addEvent() {
		container.on( "click." + id , "[data-action]", function( event ){
		    var item = $(event.target);
		    var action = item.data("action");
		    
		    if( action == undefined ) {
		    	item = item.parent();
		    	action = item.data("action");
		    }
		    
		    switch( action ) {
		        case "fileSelect" :
	                document.location.href = "#_file_manager_";
		            $(container).find(".fileList").click();

		            setTimeout( function(){
	                    document.location.href = "#";
		            }, 1000 );
		            
		        	break;
		        case "upload" :
		            $(container).find(".uploadComponent button[data-action='upload']").prop("disabled", true);
		            var filesList = $(container).find(".fileList").prop('files');
		            
		            options["uploadUrl"] = url + nvl( options["fileGroupId"] );
		            uploader.fileupload('send', {files: filesList, url : options["uploadUrl"] });		
		            break;
		        case "saveAttachFileDescription" :
		            var data = [];
		            table.find("._description").each( function(){
		                data.push( { fileId : $(this).data("id"), fileDesc : $(this).val() } );
		            });

		            myForm.transaction( "lgcom", "lgsysc/LGSYSC00210/updateAttachFileInfo", { data : data }, function(){
		            	 showManagerMessage ("<lgcom:message code="note.saved" />" );
		            });     	
		        	
			    	break;
			    case "confirm" :
			    	confirm();	 
			    	break;
				case "download" :
					var fileInfo =  $(event.target).closest("tr").data("fileInfo");
					downloadFile( fileInfo );
					break;
				case "delete" :
					var fileInfo =  $(event.target).closest("tr").data("fileInfo");
				    deleteFile( fileInfo , $(event.target).closest("tr") );
					break;		
				case "inlineConfirm" :
		            var data = [];
		            table.find("._description").each( function(){
		                data.push( { fileId : $(this).data("id"), fileDesc : $(this).val() } );
		            });

		            myForm.transaction( "lgcom", "lgsysc/LGSYSC00210/updateAttachFileInfo", { data : data }, function(){
		            	 showManagerMessage ("<lgcom:message code="note.saved" />" );
		            }); 
		            
		            confirm();	 
					break;		
		    }
		});
		
		container.on( "change." + id, ".fileList", function(){
			container.find("._button_upload_text_").text(  $(this).val()  );
		
		    if( $(this).val() == "" ) {
		    	container.find(".uploadComponent button[data-action='upload']").prop("disabled", true);
		    } else {
		    	container.find(".uploadComponent button[data-action='upload']").prop("disabled", false);
		    }
		});	
		
		container.on( "click." + id, "._fileList ._fileName", function( event ) {
			var fileInfo =  $(event.target).closest("tr").data("fileInfo");
			downloadFile( fileInfo );
		});		
	}
	
	
	function downloadFile( fileInfo ) {
		container.find("._fileupload_server_message_").text( "<lgcom:message code="note.fileDownloadloading" />" );
		var downloader = new Downloader( {} , { } );
		downloader.attachment( fileInfo["fileId"] , function() {
			container.find("._fileupload_server_message_").text( "<lgcom:message code="note.fileDownloadCompleted" />" );
		}, function() {
			container.find("._fileupload_server_message_").text( "<lgcom:message code="note.fileDownloadFailed" />" );
		}, fileInfo["moduleCode"] );
	}	
	
    function deleteFile( fileInfo, row ) {
		var fileName = fileInfo["fileName"];
		var fileId =  fileInfo["fileId"];

		Message.confirm( "Do you wnat to delete file in below ? : <br> Name : <strong>"+ fileName +"</strong>", function() {
			var param = { fileId : fileId ,  moduleCode :  options["moduleCode"]  };
			myForm.transaction( "lgcom", "lgsysc/LGSYSC00210/deleteAttachFileInfo", param, function(data){
				showManagerMessage( "<lgcom:message code="note.fileDeleted" />" ); 

				$(row).remove();
				var body = table.find("tbody");
				
				if( $(body).find(".fileIndex").length == 0 ) {
					if(options.editable) {
						body.append("<tr><td colspan='4'>No files</td></tr>");
					} else {
						body.append("<tr><td colspan='3'>No files</td></tr>");
					}
				}

				if( options.fileCount != undefined ) {
					if( body.find(".fileIndex").length < options.fileCount  ) {
						container.find("._button_upload_, [data-action='upload']" ).removeAttr("disabled");
					} else {
						container.find("._button_upload_, [data-action='upload']" ).prop("disabled", true);
					}
				} else {
					container.find("._button_upload_, [data-action='upload']" ).removeAttr("disabled");
				}
			});
		});    	
    }	
	

    function showManagerMessage( message ) {
        $(container).find("._fileupload_server_message_").text( message );
        var timeout = setTimeout( function(){
            $(container).find("._fileupload_server_message_").text( "" );
            clearTimeout( timeout )
        }, 5000 );
    }    
    
	myForm.addComponent( "FileManager", this);
}	
</script>