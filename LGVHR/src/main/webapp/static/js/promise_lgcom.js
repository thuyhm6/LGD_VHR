/* promise 를 사용하는 transaction 처리  시작 add kikimans */
function transaction_p(context, action, data){
    return _promiseTransaction(context,action,data);
}

function _promiseTransaction(context,action,data ){
    trace('call _promiseTransaction ');
	var callerInfo = {
			programId : "main",
			menuId : "main"
	};

	if( data != undefined && data._programMeta != undefined ) {
		callerInfo["menuId"] = data._programMeta["menuId"];
		callerInfo["programId"] = data._programMeta["programId"];
	} else {
		try {
			var formId = LayoutManager.getCurrentBizFormId(); // BizForm.getFormId();
			var menuItem = LayoutManager.getMenuItem(formId);
			callerInfo["menuId"] = menuItem["menuId"];
			callerInfo["programId"] = menuItem["programId"];
		} catch (e) {

		}
	}

	if (data == undefined) {
		data = {};
	}

	var headerInfo = {
		action : context + "/action/" + action,
		menuId : callerInfo["menuId"],
		programId : callerInfo["programId"]
	};

	//로그인 예외 처리된 URL이 아닌 모든 URL 에 대해 Ajax 로 서버 요청을 하는 경우, securityCode 정보가 없으면 거부된다.
	try {
		headerInfo["securityCode"] = LayoutManager.getSecurityCode();
	}catch(e){}
     
	
	delete data["_programMeta"];

		
    var url = SERVER_URL + "/" + context + "/action/" + action;
    axios.defaults.headers.post['Content-Type'] = "application/json; charset=UTF-8";
    axios.defaults.headers.post['headerInfo'] = headerInfo;
    showProgress();  // spinner
    return axios({        
        method : "POST",        
        data : data,        
        url : url,
    }).then(function(response){
        //trace('axios ', response);
        var serverMessage = response.data._server_message_;
        //trace('serverMessage : ', serverMessage);
        hideProgress();
        if(serverMessage.type === "SUCCESS"){
            return response.data;
        }else{
            Message.error(serverMessage.text);
        }
        
    }).catch(onPromiseError);   
    
}

function onPromiseError(error){
    trace('error ', error);
    trace(error.status + " : " + error.message);
    $(".spinnerBack, .spinner").hide();

    // 해당 화면의 Grid 의 spinner 를 숨긴다.
    try {
        BizForm.offGridProgress();
    } catch( e ) {}
    
    switch(error.status){
    case "404" :
        alert("[ERROR] page not found : " + url);
        break;
    case "401" :
        var data = error.response;
        var serverMessage = data["_server_message_"];
        Message.error(serverMessage.text, function() {
            var nav = new Navigate("lgcom", "login");
            nav.goGet();
        });
        break;
    case "405":
        var data = error.response;
        var serverMessage = data["_server_message_"];
        Message.error(serverMessage.text);

        BizForm.offGridProgress();
        break;
    case "504":
        Message.error("504 : Request Timeout");
        BizForm.offGridProgress();
    
    }    
}


//kikimans by Array remove
Array.prototype.remove = function(num){
 delete this[num];
 return this.filter(function(v){
     if(typeof v !== 'undefined'){
         return v;
     }
 });
}