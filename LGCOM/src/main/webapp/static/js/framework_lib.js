if( window.console == undefined ) { console = {log : function(){} }; }

var SINGLE_LINE = { top1 : 38, top2 : 64 };
var DOUBLE_LINE = { top1 : 64, top2 : 91 };

/* Javascript Object modifications */
String.prototype.capitalize = function() {
	return this.charAt(0).toUpperCase() + this.slice(1);
}

String.prototype.replaceAll = function(target, replacement) {
	return this.split(target).join(replacement);
};

String.prototype.startsWith = function(str) {
	return this.indexOf(str) == 0;
};

String.prototype.contains = function(str) {
	return this.indexOf(str) > 0;
};

String.prototype.endsWith = function(suffix) {
	return this.indexOf(suffix, this.length - suffix.length) !== -1;
};

String.prototype.lpad = function(padString, length) {
	var str = this;
	while (str.length < length)
		str = padString + str;
	return str;
};

String.prototype.rpad = function(padString, length) {
	var str = this;
	while (str.length < length)
		str = str + padString;
	return str;
}

/********************************************
 * 숫자 필드의 계산과 포매팅을 위한 지원 클래스
 * 일단 사칙연산만 지원한다.
 *******************************************/
var Calc = function(){ }

Calc.real = function( val ){
	val = Number( (val + "").replaceAll("," , "" ) );
	return Number( val );
}

//tz trailing zero로 소수점 이후 0을 제거하려면 rtz, 유지하려면 ktz로 넘기면 됨
Calc.format = function( val, precision, tz) {
	var tzOption = tz||"ktz";
	
	if(tzOption ==="ktz"){
		//숫자에서 콤마를 제거한다.
		val = Number( (val + "").replaceAll("," , "" ) );

		if( precision != undefined ) {
			val = Number(val).toFixed(precision);
			return Number(val).toLocaleString("kr", { minimumFractionDigits: precision });
		} else {
			return Number(val).toLocaleString("kr");
		}
	} else {
		//숫자에서 콤마를 제거한다.
		val = Number( (val + "").replaceAll("," , "" ) );

		if( precision != undefined ) {
			val = parseFloat(Number(val).toFixed(precision)).toString();
			return Number(val).toLocaleString("kr", { maximumFractionDigits: precision });
		} else {
			return Number(val).toLocaleString("kr");
		}
	}
}

Calc.toNum = function( val, precision ) {
	val = Number( (val + "").replaceAll("," , "" ) );
	if( precision == undefined ) {
		precision = 0;
	}
	return prettyFloat( Number( val ), precision, true);
}

Calc.multiple = function( a, b, precision ){
	a = Calc.real(a);
	b = Calc.real(b);
	var value = a * b;
	if( precision != undefined ) {
		return Calc.format( value, precision);
	} else {
		return value;
	}
}

Calc.divide = function( a, b, precision ){
	a = Calc.real(a);
	b = Calc.real(b);

	if( precision == undefined ) {
		precision = 0;
	}

	var value = 0;
	try{
		value = a / b;
	}catch( e ) {}

	if( precision != undefined ) {
		return Calc.format( value, precision);
	} else {
		return value;
	}
}

/***************************************************
  moment.js 에 의존하여, Date 관련 처리를 수행한다.
  http://momentjs.com/docs/#/parsing/string-format/
***************************************************/
DateUtil = function() {};

DateUtil.setProperty = function(property) {
	this.property = property;
}

DateUtil.today = function(format) {
	var current = SystemDateSupport.getTime();
	if (format) {
		return moment(current).format(format);
	}
	return moment(current);
}

DateUtil.addDays = function(date, days, format) {
	if (typeof date == "string") {
		date = moment(date);
	}
	date = date.add(days, "days");
	if (format) {
		return date.format(format);
	}
	return date;
}

DateUtil.parse = function(dateString, format) {
	if (format) {
		return moment(dateString, format);
	} else {
		return moment(dateString);
	}
}

DateUtil.format = function( date, format ) {
	if (typeof date == "string") {
		date = moment(date);
	}
	if (format) {
		return date.format(format);
	} else {
		return date.format("YYYY-MM-DD");
	}
}

//해당 년 월의 가장 마지막 날짜를 리턴한다. year (number) : 2016 , month (number) : 1 ~ 12
DateUtil.getLastDay = function(year, month) {
	return moment(year + "-" + month + "-" + "01").endOf('month').date();
}

// 날짜를 받아 날짜 사이의 일수를 계산한다.
DateUtil.getDayTerm = function(date1, date2, format) {
	if($.trim(date1) == '') return 0;
	if($.trim(date2) == '') return 0;
	var dt1, dt2;
	if(typeof(format) == 'undefined') {
		dt1 = moment(date1);
		dt2 = moment(date2);
	} else {
		dt1 = moment(date1,format);
		dt2 = moment(date2,format);
	}
	var diff = dt1.diff(dt2,'days');
	if(isNaN(diff)) {
		return 0;
	} else {
		return Math.abs(dt1.diff(dt2,'days')) + 1;
	}
}

/****************************************************
 * 메세지 컴포넌트
 * bootbox.js -> http://bootboxjs.com/documentation.html#bb-alert-dialog-options
 ***************************************************/
var Message = function() {
}

Message.error = function(message, callback) {
	if (callback) {
		bootbox.alert({
			title : Message.ERROR,
			closeButton : false,
			message : message,
			animate : false,
			className : "_messageError",
			callback : callback,
			buttons: {
				'ok': {
					className: 'btn-primary btn-darkgray btn-sm'
				}
			}
		});
	} else {
		bootbox.alert({
			title : Message.ERROR,
			closeButton : false,
			message : message,
			animate : false,
			className : "_messageError",
			buttons: {
				'ok': {
					className: 'btn-primary btn-darkgray btn-sm'
				}
			}
		});
	}
}

Message.alert = function(message, callback ) {
	try {
		if(LayoutManager.getPopups() && LayoutManager.getPopups().size() == 0) {
			LayoutManager.toggleIframeOnActiveTab(false);
		}
	} catch( e ){}

    bootbox.alert({
        size: 'small',
        buttons: {
            'ok': {
            	label : Message.OK,
                className: 'btn-primary btn-darkgray btn-sm'
            }
        },
        title: Message.INFORMATION ,
        message: message,
        callback: callback
    })
}

Message.confirm = function(message, callback ) {
	try {
		if(LayoutManager.getPopups() && LayoutManager.getPopups().size() == 0) {
			LayoutManager.toggleIframeOnActiveTab(true);
		}
	} catch( e ){}
	
	
    bootbox.confirm({
        buttons: {
            'confirm': {
            	label : Message.CONFIRM,
                className: 'btn-primary btn-darkgray btn-sm'
            },
            'cancel': {
            	label : Message.CANCEL,
                className: 'btn-gray btn-sm'
            }
        },
        title: Message.CONFIRM ,
        message: message,
        callback: function( result ) {
        	if( result ) {
        		try { 
        			callback.call(this);
        		}catch(e){}
        	}
        }
    });
}

Message.notify = function(message, arg1, arg2) {
	var ok;
	var parameter;

	if (typeof (arg1) == "function") {
		ok = arg1;
	} else {
		parameter = arg1;
		ok = arg2;
	}

	if (parameter != undefined) {
		$.each(parameter, function(key, value) {
			var str = "{" + key + "}";
			message = message.replaceAll(str, value);
		});
	}

	var item = $("._globalStatusBar ._message").text(message);

	$(item).stop().fadeIn(function() {
		setTimeout(function() {
			item.stop().fadeOut();
		}, 10000);
	});
}

Message.instantMessage = function( message ){
	$.growl.notice({ title : "", message : message, location : "br", size : "large" });
}

/****************************************************
 * 화면의 이동과 관련하여 다음과 같은 기능을 지원한다.
 * 1. 메인 화면의 탭에서 호출하여 또다른 탭을 불러오기
 * 2.
 * bootbox.js -> http://bootboxjs.com/documentation.html#bb-alert-dialog-options
 ***************************************************/
var Navigate = function(arg1, arg2, arg3) {
	var parentForm;
	var context;
	var url;

	if (typeof arg1 == "string") {
		var context = arg1;
		var url = arg2;
	} else {
		parentForm = arg1;
		context = arg2;
		url = arg3;

		this.form = parentForm;
	}

	this.param = new Map();

	if ((url + "").startsWith("http")) {
		this.url = url;
	} else {
		this.menuId = url;
		this.url = SERVER_URL + "/" + context + "/service/" + url;
	}
}

Navigate.prototype.constructor = Navigate();

Navigate.prototype = {
	goPost : function() {
		$("#frm_redirection").remove();
		var formStr = "<form id='frm_redirection' action='" + this.url + "' method='post'></form>";
		$("body").append(formStr);
		var keyArr = this.param.keys();
		for (var inx = 0; keyArr != undefined && inx < keyArr.length; inx++) {
			$("#frm_redirection").append( "<input type='hidden' name='" + keyArr[inx] + "' value='" + this.param.get(keyArr[inx]) + "' />");
		}
		$("#frm_redirection").submit();
	},

	goGet : function() {
		var targetUrl = this.url;
		var keyArr = this.param.keys();
		for (var inx = 0; keyArr != undefined && inx < keyArr.length; inx++) {
			if (targetUrl.indexOf("?") < 0 && inx == 0) {
				targetUrl += "?";
			}
			targetUrl += keyArr[inx] + "=" + this.param.get(keyArr[inx]);
			if (inx < keyArr.length - 1) {
				targetUrl += "&";
			}
		}
		if( targetUrl.indexOf("/login") > -1 ) {
			top.location.href = targetUrl;
		} else {
			window.location.href = targetUrl;
		}
	},

	/* 브라우저 탭을 이용한 새 창 열기에 사용한다. */
	goPageInNewBrowerTab : function() {
		var targetUrl = this.url;
		var keyArr = this.param.keys();
		for (var inx = 0; keyArr != undefined && inx < keyArr.length; inx++) {
			if (inx == 0) {
				targetUrl += "?";
			}
			targetUrl += keyArr[inx] + "=" + this.param.get(keyArr[inx]);
			if (inx < keyArr.length - 1) {
				targetUrl += "&";
			}
		}

		var anchor = "<a id='_navigation_anchor' href='" + targetUrl + "' target='_blank' style='display:none;'>새 창으로 가시오</a>";

		if ($("#_navigation_anchor").length == 0) {
			$("body").append($(anchor));
		} else {
			$("#_navigation_anchor").attr("href", targetUrl);
		}
		$("#_navigation_anchor")[0].click();
	},

	goPageInNewTab : function() {
		//열고자 하는 메뉴로 이미 동일한 화면이 있다면, 닫는다.
		var targetBizFormId = $("._contents > ._contentWrapper > ._content[data-menuid='"+ this.menuId +"']").attr("id");
		if( targetBizFormId != undefined ) {
			LayoutManager.closeTab( targetBizFormId );
		}
		LayoutManager.addTabByMenuId( this.menuId, this.param.toJson() );
	},

	addParam : function(key, value) {
		this.param.put(key, value);
	},

	reload : function() {
		window.location.reload();
	},

	goPageInDiv : function(targetDiv, callback) {
		var targetUrl = this.url;
		var parameter = JSON.parse(JSON.stringify(this.param));
		var id = uuid();
		targetDiv.attr("id", uuid());
		parameter["bizFormId"] = id;
		targetDiv.load(this.url, parameter, function() {
			try {
				callback.call(this, responseText, statusText, xhr);
			} catch (e) {}
		});
	},

	/* goPageInCurrentDiv 에 의해서 화면간 이동이 발생할 때, 이 화면에서 */
	addNavigationCallback : function( callback ) {
		// 현재 화면에 로딩된 form의 id
		var bizFormId = this.form.getBizFormId();
		var wrapper = $("div._content#" + bizFormId).closest("._contentWrapper");
		var callbacks = wrapper.data("callbacks");
		var menuId = LayoutManager.getMenuItem(bizFormId).menuId;

		if( callbacks == undefined ) {
			callbacks = new Map();
			wrapper.data("callbacks", callbacks );
		}
		callbacks.put( menuId, callback );
	},

	/* option
	 *   reload : true / false -> goPageInCurrentDiv 로 여는 화면을 리로드 없이 그대로 보여주도록 한다.
	 */
	goPageInCurrentDiv : function( option ) {
		if( option == undefined ) {
			option = { reload : true };
		}

		if( option['reload'] == undefined ) {
			option['reload'] = true;
		}

		// 현재 화면에 로딩된 form의 id
		var bizFormId = this.form.getBizFormId();
		var wrapper = $("div._content#" + bizFormId).closest("._contentWrapper");
		var stack = wrapper.data("stack");
		var menuId = LayoutManager.getMenuItem(bizFormId).menuId;

		// 현재 화면이 포함된 wrapper 의 고유값 ( 메뉴에 의해서 초기에 로딩된 form 의 BizForm Id
		var wrapperFormId = wrapper.data("id");

		var content;
		var id;		// 이것은 화면에 보이게 될 Target 폼의 BizFormId

		// 이 wrapper 에 새로 로딩하려는 menuId 가 이미 있을때
		if (stack.containsKey(this.menuId)) {
			id = stack.get(this.menuId)["id"];
			content = wrapper.children("._content#" + id);
			//이 경우, 이미 페이지가 로딩 된 적이 있다. options.reload == flase 인 경우는 그냥 div 만 보여주고 callback 호출 하면 끝난다.
			option["_new"] = false;
		} else { // 새로 로딩하려는 menuId 를 추가할 때
			id = uuid();
			content = $("<div class='_content' id='" + id + "' data-menuId='" + this.menuId + "'><div class='spinner _loader'><span>Loading...</span></div></div>");
			wrapper.append(content);

			//Main 의 Tab 이 더블클릭에의해 전체 화면이 되는 기능이 추가 됨에 따라
			//전체 화면 모드에서 화면 전환 중 폼이 만들어 지는 상황에 대한 처리가 필요하다.
			//2017.07.14. forain 추가
			//기존 Open된 화면이 아닐 경우 SCREEN_MODE 값이 undefined 임으로 제외.
			if($("main").data("SCREEN_MODE") == undefined) {
				content.css({ top : "0px"});
			} else if( $("main").data("SCREEN_MODE") == "NORMAL" ) {
				content.css({ top : "0px"});
			} else {
				content.css({ top : "25px"});
			}

			// wrapper가 가지고 있던 가장 첫 bizFormId 로 해당 menuId 의 정보를 인출해 와 사용한다.
			var menuItem = LayoutManager.getMenuItem(bizFormId);
			LayoutManager.getMenuItems().put(id, { systemCode : menuItem["systemCode"], name : menuItem["menuName"], programId : "", menuId : this.menuId, urlAddr : "" });

			stack.put(this.menuId, { id : id , name : menuItem["menuName"] } );

			//이 경우, 이미 페이지가 로딩 된 적이 있다. 이 경우는 무조건 화면을 loading 해서 보여주어야 한다.
			option["_new"] = false;
		}

		// 새로 만들어 지거나, 이미 만들어져 찾아진 content 를 활성화 하여 전면으로 보낸다.
		content.show().siblings("._content").hide();

		// 리로드가 false 이고, 이 화면이 이미 만들어 져 있는 경우에 한하여, 다음 동작을 수행하고 여기서 멈춘다.
		if( option.reload == false && option._new == false ) {
			var callbacks = wrapper.data("callbacks");
			try {
				//새 화면의 menuId -> this.menuId
				//지금 호출하고있는 화면의 menuId -> menuId
				callbacks.get( this.menuId ).call( this, menuId );
			} catch(e) {
				trace( e );
			}
			$( "main ._header ._contentName[data-id='" + wrapperFormId + "'] ._text").html( stack.get(this.menuId)["name"] );
			$(content).closest("._contentWrapper").find("._handle ._text").html( stack.get(this.menuId)["name"] );

			//DOM에 생성된 달력이 있으면 삭제 한다.
			$("#"+ bizFormId).find("._datePicker").each( function(){
				var datePicker = $(this).data('dateRangePicker');
				if( typeof datePicker == "object" ) {
					$(this).data('dateRangePicker').destroy();
				}
			});
			// 이 화면을 리프레시 한다. ( 그리드 등이 보이지 않을 수 있으므로 )
			LayoutManager.getForm( id ).refreshGrid();
			// 2017.04.05. forain 추가. 현재 로딩된 폼을 currentBizForm 으로 등록 한다.
			LayoutManager.setCurrentBizFormId( id );
			return;
		}

		var parameter = {
			bizFormId : id
		};
		var _this = this;
		$.each(this.param.keys(), function() {
			parameter[this] = _this.param.get(this); // this에 주의 할것!
		});

		content.html("").removeData();
		LayoutManager.removeForm( id );

		content.load( this.url, parameter, function(responseText, statusText, xhr) {
			//요청한 메뉴가 등록돼 있지 않거나, Cache 에 없는 경우로서, 화면에는 에러 페이지가 보였을 상황이므로, load() 의 후처리는 필요 없으므로 중단한다.
			if( $.trim(xhr.getResponseHeader("menuName")) == "" ) {
				return;
			}

			var menuItem = {
				systemCode : xhr.getResponseHeader("systemCode") ,
				name : Base64.decode( $.trim(xhr.getResponseHeader("menuName")) ),
				programId : xhr.getResponseHeader("programId"),
				menuId : xhr.getResponseHeader("menuId")
			};

			LayoutManager.getMenuItems().put( id, menuItem );
			var menuName = menuItem["name"];

			stack.put( _this.menuId, { id : id , name : menuName } );

			if (id != wrapperFormId) {
				menuName = "<i class='fa fa-chevron-right' aria-hidden='true' style='margin-right:5px;'></i>" + menuName;
			}

			$( "main ._header ._contentName[data-id='" + wrapperFormId + "'] ._text").html( menuName );
			$(content).closest("._contentWrapper").find("._handle ._text").html( menuName );

			// 현재 로딩된 폼을 currentBizForm 으로 등록 한다.
			LayoutManager.setCurrentBizFormId(id);

			try {
				option.callback.call(this, responseText, statusText, xhr);
			} catch (e) {
			}
		});
	},

	//특정한 fullurl 을 별도로 마련한 iFrame 안에서 띄우는 함수
	goFullUrlWithInternalFrame : function( fullUrl ) {
		var holder = $("<div id='_internal_frame_window_' style='position:absolute; background:#FFFFFF; z-index : 1000; top: 30px; bottom:20px; left:20px; right : 20px; border : 1px solid #B3B3B3;'><div><span class='_name' style='position:absolute;top:0px;left:0px;right:0px;height:20px;'></span></div><iframe style='position:absolute;top:20px;left:0px;right:0px;bottom:0px;'></iframe></div>");
		if( !$("#_internal_frame_window_").exists() ) {
			$("body").append( holder );
		}

		$("#_internal_frame_window_").show();
		$("#_internal_frame_window_ iframe").attr("src", fullUrl );
	}
};



function nvl(str, alternative ) {
	if (str == undefined || str == null || str == "null" || str == "undefined" || str == "" ) {
		if( alternative ) {
			str = alternative;
		} else {
			str = "";
		}
	}
	
	return str;
}

function isNull(str) {
	return ( nvl(str) == "" );
}

var Base64={_keyStr:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",encode:function(e){var t="";var n,r,i,s,o,u,a;var f=0;e=Base64._utf8_encode(e);while(f<e.length){n=e.charCodeAt(f++);r=e.charCodeAt(f++);i=e.charCodeAt(f++);s=n>>2;o=(n&3)<<4|r>>4;u=(r&15)<<2|i>>6;a=i&63;if(isNaN(r)){u=a=64}else if(isNaN(i)){a=64}t=t+this._keyStr.charAt(s)+this._keyStr.charAt(o)+this._keyStr.charAt(u)+this._keyStr.charAt(a)}return t},decode:function(e){var t="";var n,r,i;var s,o,u,a;var f=0;e=e.replace(/[^A-Za-z0-9+/=]/g,"");while(f<e.length){s=this._keyStr.indexOf(e.charAt(f++));o=this._keyStr.indexOf(e.charAt(f++));u=this._keyStr.indexOf(e.charAt(f++));a=this._keyStr.indexOf(e.charAt(f++));n=s<<2|o>>4;r=(o&15)<<4|u>>2;i=(u&3)<<6|a;t=t+String.fromCharCode(n);if(u!=64){t=t+String.fromCharCode(r)}if(a!=64){t=t+String.fromCharCode(i)}}t=Base64._utf8_decode(t);return t},_utf8_encode:function(e){e=e.replace(/rn/g,"n");var t="";for(var n=0;n<e.length;n++){var r=e.charCodeAt(n);if(r<128){t+=String.fromCharCode(r)}else if(r>127&&r<2048){t+=String.fromCharCode(r>>6|192);t+=String.fromCharCode(r&63|128)}else{t+=String.fromCharCode(r>>12|224);t+=String.fromCharCode(r>>6&63|128);t+=String.fromCharCode(r&63|128)}}return t},_utf8_decode:function(e){var t="";var n=0;var r=c1=c2=0;while(n<e.length){r=e.charCodeAt(n);if(r<128){t+=String.fromCharCode(r);n++}else if(r>191&&r<224){c2=e.charCodeAt(n+1);t+=String.fromCharCode((r&31)<<6|c2&63);n+=2}else{c2=e.charCodeAt(n+1);c3=e.charCodeAt(n+2);t+=String.fromCharCode((r&15)<<12|(c2&63)<<6|c3&63);n+=3}}return t}}

Array.prototype.merge = function(array1) {
	if (array1 == undefined)
		return;
	for (var i = 0; i < array1.length; i++) {
		this.push(array1[i]);
	}
	return this;
}

Array.prototype.remove = function(from, to) {
	var rest = this.slice((to || from) + 1 || this.length);
	this.length = from < 0 ? this.length + from : from;
	return this.push.apply(this, rest);
};

Array.prototype.removeByValue = function() {
	var what, a = arguments, L = a.length, ax;
	while (L && this.length) {
		what = a[--L];
		while ((ax = this.indexOf(what)) !== -1) {
			this.splice(ax, 1);
		}
	}
	return this;
};

/* JQuery Object Extionsions */
/* JSON 객체에 적용하여 값이 null, 'null', undefined 로 돼 있는 항목들을 "" 로 만들어 주는 플러그인 */
$.fn.cleanJSON = function() {
	$(this).each(function() {
		$self = this;

		$.each($self, function(key, value) {
			$self[key] = nvl(value);
		});
	});
}

$.fn.toJSON = function() {
	var o = {};
	var a = this.serializeAll();
	$.each(a, function() {
		if (o[this.name] !== undefined) {
			if (!o[this.name].push) {
				o[this.name] = [ o[this.name] ];
			}
			o[this.name].push(this.value || '');
		} else {
			o[this.name] = this.value || '';
		}
	});
	return o;
};

$.fn.exists = function() {
	if ($(this).length > 0) {
		return true;
	} else {
		return false;
	}
}

$.fn.clearForm = function() {
	$(this).each(function() {
		if (this.tagName == "FORM") {
			this.reset();
		}
	});
}

$.fn.serializeAll = function() {
	var data = $(this).serializeArray();
	$(':disabled[name]', this).each(function() {
		data.push({
			name : this.name,
			value : $(this).val()
		});
	});
	return data;
}


/************************************************************
 * 폼 컴포넌트 중 pastabe attribute 가 붙은 아이템에 대해서, 다수행 붙여넣기 기능을 구현하기 위한 플러그인 설정
************************************************************/
$.fn.pastable = function() {
	$(this).each( function() {
		var id = uuid();
		
		if (this.tagName != "INPUT") {
			return true; // continue 와 같은 효과를 낸다.
		}

		var elementWrapper = "<div class='input-group input-group-sm input-search'>\
								<input type='hidden' name='" + $(this).attr("name") + "' pastable /></input>\
								<input type='text' class='form-control _pastable_origin_' pastableId='"+id+"' disabled />\
								<span class='input-group-btn'>\
									<button class='btn btn-default ico-lgd' type='button' data-action='popup' data-type='sPopup'>\
										<span class='fa fa-clipboard pastable' aria-hidden='true' data-action='popup'></span>\
									</button>\
								</span>\
							</div>"; 
			
		var wrapper = $(elementWrapper);
		
		if( $(this).hasClass("input-require") ) {
			wrapper.addClass("input-require");
		}
		
		$(this).replaceWith( wrapper );
		var element = wrapper.find("._pastable_origin_");
		var button =  wrapper.find(".btn");
		var elementHidden =  wrapper.find("input[type='hidden']");
		
		var plate = $("<textarea id='" + id + "' class='_pasteContent' ></textarea>");
		plate.css("width", wrapper.width());
		$("body").append(plate);

		$(button).on( "click", function(event) {
			if( $(this).hasClass("disabled") ) {
				return;
			}

			var item = $(event.target);
			if( item.is("span") ) {
				item = $(item).parent();
			}
			var width = $(wrapper).outerWidth();
			
			if( width < 200 ) {
				width = 200;
			}
			
			if (item.data("status") == undefined || item.data("status") == "CLOSED") {
				plate.css({ top : ( $(wrapper).offset().top + $(wrapper) .outerHeight() + 1 ) +"px", 
					        left : $(wrapper).offset().left +"px", 
					        width : width +"px" });
				plate.show().focus();
				// element.prop("disabled",
				// true);
				item.data("status", "OPEN");
			} else {
				// var text =
				// plate.text().trim().replace(/\n/g,
				// "|").replaceAll("
				// ","");//.replaceAll("|",",");
				pushData();
				plate.hide();
				// element.removeAttr("disabled");
				item.data("status", "CLOSED");
			}
		});

		$(element).on("click", function(event) {
			plate.hide();
		});

		$(element).on( "keyup", function(event) {
			if (nvl($(event.target).data("displayText")) != "" && $(event.target).data( "displayText") != $(event.target).val()) {
				$(event.target).val("");
				$(event.target).data( "displayText", "");
			}
			elementHidden.val($(event.target).val());
			if ($(event.target).val() == "") {
				plate.val("");
				elementHidden.val("");
			} else {
				plate.val($(event.target).val());
				elementHidden.val($(event.target).val());
			}
		});

		$(plate).on("keyup", function(event) {
			resizeTextArea();
		});

		$(plate).on("paste", function(event) {
			resizeTextArea();
		});

		$(plate).on("focusout", function(event) {
			pushData();
		});

		$(element).on("paste", function(event) {
			setTimeout( function() {
				var text = element.val();
				var textWithComma = text.replaceAll(" ", ",");

				plate.val(text.replaceAll(" ","\n"));
				elementHidden.text(textWithComma);
				element.val(textWithComma.split(",")[0] + " (" + textWithComma.split(",").length + ")");
			}, 100);

			plate.css({
				top : $(element).offset().top + $(element) .outerHeight() - 1,
				left : $(element).offset().left,
				width : $(element).outerWidth()
			});
			// plate.show();
		});

		$("*:not(._pasteContent, .pastable )").click( function() {
			// plate.hide();
		});

		function resizeTextArea() {
			plate.css("height", "1px");
			plate.css("height", (plate.prop("scrollHeight"))+ "px");
		}

		function pushData() {
			var arr = plate.val().trim().replaceAll(" ", "").replace(/\n/g, "|").split("|");
			var text = "";
			$(arr).each(function() {
				if (this.trim().length > 0) {
					text += this.trim() + ",";
				}
			});

			text = text.substr(0, text.length - 1);
			if (text != "") {
				elementHidden.val(text);
				var displayText = text.split(",")[0] + " ("+ text.split(",").length + ")";
				element.data("displayText", displayText).val( displayText );
			} else {
				elementHidden.val("");
				element.data("displayText", "").val("");
			}
		}

		$(document).bind("click",function(event) {
			var $clicked = $(event.target);
			if (!($clicked.hasClass("_pasteContent") || $clicked.hasClass("pastable"))) {
				pushData();
				plate.hide();
				// element.removeAttr("disabled");
				button.data("status", "CLOSED");
			}
		});
	});
}

/************************************************************
 * Map : Java의 HashMap 과 동일한 기능을 수행하는 Javascript Custom Class 이다.
************************************************************/
var Map = function() {
	this.map = new Object();
};

Map.prototype.constructor = Map;

Map.prototype = {
	put : function(key, value) {
		this.map[key] = value;
	},
	get : function(key) {
		return this.map[key];
	},
	containsKey : function(key) {
		return key in this.map;
	},
	containsValue : function(value) {
		for ( var prop in this.map) {
			if (this.map[prop] == value)
				return true;
		}
		return false;
	},
	isEmpty : function() {
		return (this.size() == 0);
	},
	clear : function() {
		/*
		for ( var prop in this.map) {
			delete this.map[prop];
		}*/
		this.map = null;
		this.map = new Object();
	},
	remove : function(key) {
		delete this.map[key];
	},
	keys : function() {
		var keys = new Array();
		for ( var prop in this.map) {
			keys.push(prop);
		}
		return keys;
	},
	values : function() {
		var values = new Array();
		for ( var prop in this.map) {
			values.push(this.map[prop]);
		}
		return values;
	},
	size : function() {
		var count = 0;
		for ( var prop in this.map) {
			count++;
		}
		return count;
	},
	toJson : function() {
		var json = {};
		for ( var prop in this.map) {
			json[prop] = this.map[prop];
		}
		return json;
	}
};

/************************************************************
 * Validator : Form 요소의 검증 도구( jquery validator 활용 )
 * 컴포넌트의 자세한 정보 : http://api.highcharts.com/highcharts
************************************************************/
//jQuery Validate Date Format

$.validator.addMethod( "date", function(value, element) {
	// yyyy-mm-dd
	var re = /^\d{4}-\d{1,2}-\d{1,2}$/;
	// valid if optional and empty OR if it passes the regex test
	return (this.optional(element) && value=="") || re.test(value);
});

var Validator = function(bizForm, selector, rule) {
	var target = bizForm.select(selector);
	var validator;
	if (rule) {
		setRule(rule);
	}

	this.addMethod = function(key, func) {
		$.validator.addMethod(key, func);
	}

	this.setRule = function(rule) {
		setRule(rule);
	}

	function setRule(rule) {
		var placement = "bottom";

		if( rule.tooltip_options ) {
			placement = rule.tooltip_options.placement;
			$.each( rule.rules, function(key, value){
				if( rule.tooltip_options[key] == undefined ) {
						rule.tooltip_options[key] = { placement : placement , container : false};
				}
			});
		} else {
			rule.tooltip_options = {};
			$.each( rule.rules, function(key, value){
				rule.tooltip_options[key] = { placement : placement, container : false};
			});
		}
		trace("!!!!!!!!!!!!!!!!!! rule");
		trace( JSON.stringify(rule, 4) );
		
		validator = target.validate(rule);
	}

	this.isValid = function() {
		if (validator == undefined) {
			validator = target.validate(rule);
		}

		if (target.valid()) {
			return true;
		} else {
			validator.focusInvalid();
			return false;
		}
	}

	this.resetForm = function() {
		// 남아있는 error tooltip 을 제거하는 부분
		target.find("._error_tooltip_target_").tooltip("destroy").removeClass("_error_tooltip_target_");
		// form 의 error 관련 요소를 해제하는 부분
		validator.resetForm();
	}

	this.valid = function( name ) {
		if( name == undefined ) {
			$.each( rule.rules, function(key, value){
				target.find("[name='"+ key +"']").valid();
			});
		} else {
			target.find("[name='"+ name +"']").valid();
		}
	}
};

/************************************************************
 * 화면의 Popup 관련 처리를 담당하는 클래스
 * open : div 기반. 파라미터는 본화면과 팝업간에 공유하는 메모리를 통해 양방향 교환
 * openWindow : javascript window.open 을 사용한 별도 창으로 열리는 팝업. 파라미터 전달은 단방향으로 Post 방식으로 전달
 * openFrame : div 기반이면서 내부적으로 iFrame 을 활용하여 완성 url 을 호출하는 용도로 사용
 ************************************************************/
var Popup = function(parent, context, action, name) {
	var caller = parent.getBizFormId();
	var callee = uuid();
	trace("caller : " + caller);
	trace("callee : " + callee);

	if (name == undefined) {
		name = "Popup name is not defined!";
	}

	//현재 이 팝업의 menuId ( action ) 에 해당하는 menuItem 이 main 에 없는 경우에는, 이것을 초기화 하여 정보를 생성한다.
	if( action.indexOf("M_") == 0 ) {
		var menuItem = LayoutManager.getMenuItem( callee );
		if( menuItem == undefined ) {
			transaction_sync("lgcom", "common/uiCommon/retriveMenuItemFromCache", { menuId : action }, function( data ){
				menuItem = data["result"][0];
				LayoutManager.getMenuItems().put( callee, menuItem );
			});
		}
	}

	parent.addPopup(callee, this);

	var size = {
		width : 400,
		height : 300
	};
	var back, holder;
	var callbackFunction;
	var cancelCallbackFunction;

	this.closePopup = function(flag) {
		// 201.07.11. forain. Popup에서 Popup이 open 된 경우 BIMATRIX 처리 안함.
		if(LayoutManager.getPopups() && LayoutManager.getPopups().size() < 2) {
			LayoutManager.toggleIframeOnActiveTab(true);
		}
		closePopup(flag);
	}

	function closePopup(flag, popupId) {

		if (popupId == undefined) {
			popupId = callee;
		}

		if (flag == undefined) {
			flag = false;
		}

		$("div._div_popup_background_[data-id=" + popupId + "]").velocity({
			opacity : 0
		}, {
			duration : 0,
			display : "none",
			complete : function() {
				$(this).html("");
				$(this).remove();
			}
		});

		$("div.modal[data-id=" + popupId + "]").velocity({
			opacity : 0
		}, {
			duration : 0,
			display : "none",
			complete : function() {
				$(this).html("");
				$(this).remove();

				if (flag) {
					try {
						callbackFunction.call();
					} catch (e) { }
				} else {
					try {
						cancelCallbackFunction.call();
					} catch (e) {}
				}

			}
		});
		// 2017.03.22 forain. Popup 에서 Grid onDataCellClicked 이벤트에서 그리드를 제거하는 코드가 들어있을때 발생하는것으로 파악됩니다
		setTimeout(function() {
			LayoutManager.removePopup(popupId);
			LayoutManager.removeForm(popupId);
			parent.removePopup(popupId);
		},150);
	}

	this.setSize = function(width, height) {
		size = {
			width : width,
			height : height
		};
	}


	/*
	 * parameter : 여는 순간에 전달할 오브젝트 (json ), callback : 닫히는 순간에 트리거되는 callback
	 *
	 * callback 은 다음과 같이 입력한다. { before : function(){ }, after : function() { } }
	 *
	 * 만일 json 이 아닐경우, after callback 으로 작동
	 *
	 * before 에서 false 를 리턴할 경우, 팝업은 닫히지 않음
	 *
	 */
	this.open = function(callback, cancelCallback) {
		// 201.07.11. forain. Popup에서 Popup이 open 된 경우 BIMATRIX 처리 안함.
		if(LayoutManager.getPopups() && LayoutManager.getPopups().size() == 0) {
			LayoutManager.toggleIframeOnActiveTab(false);
		}

		callbackFunction = callback;
		cancelCallbackFunction = cancelCallback;
		
		var smallFlag = $("body").hasClass("page-sm");
		var pageSm = "";
        if( smallFlag ) {
        	pageSm = "page-sm";
        }
		
		var offset = LayoutManager.getPopups().size() * 20;
		if (!$("div._div_popup_background_[data-id=" + callee + "]").exists()) {
			back = $(popupBackground);
			$("body").append(back);
			back.attr("data-id", callee );
			
			holder = $(divPopupTemplate);
			$("body").append(holder);
			holder.attr("data-id", callee );

			holder.find(".modal-content, .modal-dialog").css({ "top" : "0px",  "width" : size.width + "px", "height" : size.height + "px" }); 
			holder.find(".modal-content").addClass("_div_popup_holder_");
			holder.find("._popupHeader").addClass(pageSm);
			holder.find("._popupName").text(name);
			holder.find("._content").attr("id",callee );

			$(holder).find("._popupHeader ._close").click(function() {
				if(LayoutManager.getPopups() && LayoutManager.getPopups().size() < 2) {
					LayoutManager.toggleIframeOnActiveTab(true);
				}
				closePopup();
			});

			holder.find("._popupHeader").on("dblclick", function(){
				holder.find(".modal-dialog").toggleClass("maximized_absolute");
				holder.find(".modal-content").toggleClass("maximized_percent");

				var form = LayoutManager.getForm(callee);
				if( form != undefined ) {
					form.refreshGrid();
				}
			});
		}

		back.velocity({ opacity : 0.3 }, { duration : 0, display : "block" });
		holder.velocity({ opacity : 1 }, {
			duration : 0,
			display : "block",
			complete : function() {
				var popupCount = LayoutManager.addPopup(caller, callee);
				// 팝업의 z-index를 재조정하는 작업
				back.css("z-index", (1100 + popupCount + 10));
				holder.css("z-index", (1101 + popupCount + 10));

				holder.find(".modal-content").draggable({
				    scroll: false,
					handle : "._popupHeader",
					stop : function(){
						if( $(this).offset().top < 0 ) {
							$(this).css({ top: '20px' });
						}
					}
				});

				try {
					holder.find(".modal-content").resizable('destroy');
				} catch(e) {}

				holder.find(".modal-content").resizable({
					minHeight : size.height,
					minWidth : size.width,
					resize : function(event, ui) {
						//var form = LayoutManager.getForm($(ui.element).data("id"));
						var form = LayoutManager.getForm( callee );
						form.refreshGrid();
					}
				});

				holder.find("._content").empty().removeData();

				var pageUrl = SERVER_URL + "/" + context + "/service/" + action+ "?time=" + (new Date()).getTime();
				holder.find("._content").data("URL", pageUrl);
				holder.find("._content").load(pageUrl, { bizFormId : callee }, function(response, status, xhr) {
					// 만약 팝업 호출에서 페이지가 정상적으로 로딩 되지 않은경우에 한하여
					if (xhr.status != 200) {
						LayoutManager.removePopup(caller);
					}

					var menuItem = {
						systemCode : xhr.getResponseHeader("systemCode") ,
						name : Base64.decode( xhr.getResponseHeader("menuName") ),
						programId : xhr.getResponseHeader("programId"),
						menuId : xhr.getResponseHeader("menuId")
					};
					LayoutManager.getMenuItems().put( callee, menuItem );

					if( $("div#" + callee ).find(".searchBlock .btn-lgd").exists() ) {
						$("div#" + callee ).find(".searchBlock .btn-lgd").focus();
					} else {
						if( $("div#" + callee ).find(":input").filter(":not([type='hidden'])").exists() ){
							$( $("div#" + callee ).find(":input").filter(":not([type='hidden'])")[0] ).focus();
						}
					}
				});
				$(holder).data("position", { status : "default", 
					                         top : holder.find(".modal-content").offset().top , 
					                         left : holder.find(".modal-content").offset().left, 
					                         width : holder.find(".modal-content").width() , 
					                         height : holder.find(".modal-content").outerHeight() } );
			}
		});
	}

	this.param = new Map();

	this.addParam = function(key, value) {
		this.param.put(key, value);
	}

	this.openWindow = function(callback, cancelCallback) {
		var winName= uuid();
		var wtop = 50;
		var wleft = 50;

		var winURL= SERVER_URL + "/lgcom/container?menuId=" + action;

		if( action.indexOf("approval") >= 0 ) {
			winURL = SERVER_URL + "/" + context + "/" + action;
		}

		if( action.indexOf("http") > -1 ) {
			winURL = action;
		}
		wtop = (window.screen.height - size.height)/2;
		wleft = (window.screen.width - size.width)/2;
		var windowoption='resizable=yes,height='+ size.height +',width='+ size.width +',location=0,menubar=0,scrollbars=1, top='+wtop+', left='+wleft;

		var form = $("#_open_popup_temp_form_");

		if( !form.exists() ) {
			$("body").append("<form id='_open_popup_temp_form_' method='POST'></form>");
			form = $("#_open_popup_temp_form_");
		}
		$(form).empty();

		$(form).attr("action", winURL);
		$(form).attr("target",winName);

		var keyArr = this.param.keys();
		for (var inx = 0; keyArr != undefined && inx < keyArr.length; inx++) {
			$(form).append("<input type='hidden' name='"+ keyArr[inx] +"' value='"+ this.param.get(keyArr[inx]) +"' />");
		}

		window.open('', winName,windowoption);
		$(form).submit();
	}

	this.openFrame = function( callback, cancelCallback ) {

		callbackFunction = callback;
		cancelCallbackFunction = cancelCallback;

		var offset = LayoutManager.getPopups().size() * 20;

		if (!$("div._div_popup_background_[data-id=" + callee + "]").exists()) {

			back = $("<div data-id='" + callee + "' class='_div_popup_background_' ><div>")
			holder = $("<div data-id='" + callee + "' class='_div_popup_holder_' style='top : " + (50 + offset) + "px; left : calc( 50% - " + (size.width / 2) + "px + " + offset + "px ); width : " + size.width + "px; height : " + size.height + "px ;'><div>");

			holder.append("<div class='_popupHeader'><span class='_popupName'>" + name + "</span><button type='button' class='_close close' aria-label='Close'><span aria-hidden='true'>×</span></button></div>");
			holder.append("<div class='_popupBody' id='" + callee + "'><iframe width='100%' height='100%' frameBorder='0' ></iframe></div>");

			$("body").append(back);
			$("body").append(holder);

			holder.find("._popupBody").css({"padding-top": "0px", "padding-top" : "0px" } );

			$(holder).find("._popupHeader ._close").click(function() {
				closePopup();
			});

			holder.find("._popupHeader").on("dblclick", function(){
				var position = $(holder).data("position");
				if( position != undefined ) {
					if( position.status == "default" ) {
						$(holder).css( { top : "40px" , left : "10px", right : "10px" , bottom : "10px", width : "auto", height : "auto" } );
						position.status = "extended";
					} else {
						$(holder).css( { top : position.top + "px" , left : position.left + "px", right : "auto" , bottom : "auto", width : position.width + "px", height : position.height + "px" } );
						position.status = "default";
					}
				}
			});
		}

		back.velocity({ opacity : 0.3 }, { duration : 0, display : "block" });
		holder.velocity({ opacity : 1 }, {
			duration : 0,
			display : "block",
			complete : function() {
				var popupCount = LayoutManager.addPopup(caller, callee);

				// 팝업의 z-index를 재조정하는 작업
				back.css("z-index", (1100 + popupCount + 10));
				holder.css("z-index", (1101 + popupCount + 10));

				// Draggable 설정
				holder.draggable({
					handle : "._popupHeader",
					containment : "main",
					stop : function(){
						if( $(this).offset().top < 0 ) {
							$(this).css({ top: '20px' });
						}
					}
				});
				holder.resizable({
					minHeight : size.height,
					minWidth : size.width,
					resize : function(event, ui) {
						var form = LayoutManager.getForm($(ui.element).data("id"));
						//form.refreshGrid();
					}
				});

				var pageUrl = SERVER_URL + "/" + context + "/" + action;
				holder.find("._popupBody iframe").attr("src", pageUrl );

				$(holder).data("position", { status : "default", top : $(holder).offset().top , left : $(holder).offset().left, width : $(holder).width() , height : $(holder).height() } );
			}
		});
	}

	Popup.closePopup = function(form, flag) {
		if (typeof form != "object") {
			alert("[DEV Error] : Popup.closePopup 인자는 BizForm 이어야 합니다. 코드를 수정해주세요.");
			return;
		}

		var formId = form.getBizFormId();
		var parentFormId = LayoutManager.getPopups().get(formId);

		var parentForm = LayoutManager.getForm(parentFormId);
		var popupObject = parentForm.getPopup(formId);
		popupObject.closePopup(flag, formId);
	}
	
	var popupBackground  = '<div class="_div_popup_background_" ><div>';
	
	var divPopupTemplate = '<div class="modal" role="dialog" tabindex="-1">\
								<div class="modal-dialog">\
								    <div class="modal-content">\
								        <div class="modal-header dark _popupHeader">\
								            <button type="button" class="btn btn-ico close _close" data-dismiss="modal" aria-label="Close">\
								                <span class="ico ico-popup-close" aria-hidden="true"></span>\
								            </button>\
								            <h1 class="modal-title _popupName"></h1>\
								        </div>\
								        <div class="modal-body _popupBody">\
		                                    <div class="_contentWrapper"><div class="_content"></div></div>\
								        <div class="modal-footer" style="display:none;">\
								            <button type="button" class="btn btn-darkgray btn-sm">저장</button>\
								            <button type="button" class="btn btn-gray btn-sm">취소</button>\
								        </div>\
								    </div>\
								</div>\
							</div>';
	
};

var Downloader = function( form, options ) {
	var _this = this;
	var _options = {};
	var _form = form;

	if( options != undefined ) {
		_options = options;
	}

	this.param = new Map();

	/* Downloader by Post */
	// <a
	// href="http://bizweb-local.lgdisplay.com:8080/lgcom/excel/export/lgsysc/LGSYSC00220/exportExcel"
	// target="_blank">aaaaaaaaaaaaaaaaaaaaaaaa</a>
	// param -> json object
	// main의 _global_spinner_filedownloader_ DOM 부재로 수정.2017.12.20 lgdvhrd 
	this.excelDynamicQuery = function(context, action, param, headers) {
		//$("#_global_spinner_filedownloader_ , #_global_spinner_filedownloader_spinner_").show();
		_form.showProgress();
		var url = SERVER_URL + "/" + context + "/export/excel/" + action;
		var data = { _param_ : JSON.stringify(param) };

		if (headers) {
			var arr = [];
			$(headers).each(function() {
				arr.push(JSON.stringify(this));
			});

			data["_headers_"] = "[" + arr.toString() + "]";
		}

		$.fileDownload( url, {
			data : data ,
			httpMethod: "POST",
			successCallback: function (url) {
				//$("#_global_spinner_filedownloader_ , #_global_spinner_filedownloader_spinner_").hide();
				_form.hideProgress();
			},
			failCallback: function (responseHtml, url) {
				//$("#_global_spinner_filedownloader_ , #_global_spinner_filedownloader_spinner_").hide();
				_form.hideProgress();
			}
		});
	}

	this.csvDynamicQuery = function(context, action, param, headers) {
		//$("#_global_spinner_filedownloader_ , #_global_spinner_filedownloader_spinner_").show();
		_form.showProgress();
		var url = SERVER_URL + "/" + context + "/export/csv/" + action;
		var data = { _param_ : JSON.stringify(param) };

		if (headers) {
			var arr = [];
			$(headers).each(function() {
				arr.push(JSON.stringify(this));
			});
			data["_headers_"] = "[" + arr.toString() + "]";
		}

		$.fileDownload( url, {
			data : data ,
			httpMethod: "POST",
			successCallback: function (url) {
				//$("#_global_spinner_filedownloader_ , #_global_spinner_filedownloader_spinner_").hide();
				_form.hideProgress();
			},
			failCallback: function (responseHtml, url) {
				//$("#_global_spinner_filedownloader_ , #_global_spinner_filedownloader_spinner_").hide();
				_form.hideProgress();
			}
		});
	}

	this.csvDirectDownload = function(context, queryId, param) {
		var formId = LayoutManager.getCurrentBizFormId();
		//$("#_global_spinner_filedownloader_ , #_global_spinner_filedownloader_spinner_").show();
		_form.showProgress();
		var url = SERVER_URL + "/" + context + "/directDownload/csv";

		if( param == undefined ) {
			param = { _queryId_ : queryId };
		} else {
			param["_queryId_"]= queryId;
		}

		param["_menuId_"] = LayoutManager.getMenuItem(formId)["menuId"];

		var data = { _param_ : JSON.stringify(param) };

		$.fileDownload( url, {
			data : data ,
			httpMethod: "POST",
			successCallback: function (url) {
				//$("#_global_spinner_filedownloader_ , #_global_spinner_filedownloader_spinner_").hide();
				_form.hideProgress();
			},
			failCallback: function (responseHtml, url) {
				//$("#_global_spinner_filedownloader_ , #_global_spinner_filedownloader_spinner_").hide();
				_form.hideProgress();
			}
		});
	}

	this.excel = function(context, action, param ) {
		var formId = LayoutManager.getCurrentBizFormId();
		//$("#_global_spinner_filedownloader_ , #_global_spinner_filedownloader_spinner_").show();
		_form.showProgress();

		transaction( context , action , param, function( data ){
			var result = data["result"];
			if( result["sessionId"] == undefined ) {
				$(data["result"]).each( function(){
					result = this;
				});
			}

			var url = SERVER_URL + "/" + context + "/export/csv";
			if( _options.multiSheet ) {
				var list = data["result"];
				$(list).each( function(){
					this["sheetName"] = Base64.encode( this["sheetName"] );
				});

				result = { downloadInfo : data["result"] };
				url = SERVER_URL + "/" + context + "/export/excel";
			}

			result["menuId"] = LayoutManager.getMenuItem(formId)["menuId"];
			result["columnCount"] = param["columnCount"];

			var data = "_param_=" + JSON.stringify(result);
			$.fileDownload( url, {
				data : data ,
				httpMethod: "POST",
				successCallback: function (url) {
					//$("#_global_spinner_filedownloader_ , #_global_spinner_filedownloader_spinner_").hide();
					_form.hideProgress();
				},
				failCallback: function (responseHtml, url) {
					//$("#_global_spinner_filedownloader_ , #_global_spinner_filedownloader_spinner_").hide();
					_form.hideProgress();
				}
			});
		});
	}

	this.csv = function(context, action, param, headers) {
		transaction( context , action , param, function( data ){
			var result = data["result"];
			var url = SERVER_URL + "/" + context + "/export/csv";
			var data = { _param_ : JSON.stringify(result) };
			$.AjaxDownloader( { url : url, data : data });
		});
	}

	this.csv2 = function(context, action, param, headers) {
		transaction( context , action , param, function( data ){
			var result = data["result"];
			var url = SERVER_URL + "/" + context + "/export/csv2";
			var data = { _param_ : JSON.stringify(result) };
			$.AjaxDownloader( { url : url, data : data });
		});
	}

	// EMRO
	this.attachment = function( fileId, success, fail, source ) {
		//이 다운로드는 LGCOM 에서만 수행되기 때문에, CONTEXT_PATH 를 따로 받지 않고, CONTEXT_PATH 를 사용하였다.
		var url = SERVER_URL + "/" + CONTEXT_PATH + "/download/common/"+ fileId + "/";
		if(typeof(source) == 'undefined') {
			source = 'LGCOM';
		}
		url = url + source;

		var nua = navigator.userAgent;
		if( nua.indexOf('Android ') > 0 ) {
			url = SERVER_URL + "/" + CONTEXT_PATH + "/download/common/mobile?fileId="+ fileId + "&moduleCode=" + source;
			if( !$("#_download_frame_").exists() ) {
				$("body").append("<iframe id='_download_frame_' width='0px' height='0px' ></iframe>");
			}
			$("#_download_frame_").attr("src", url );
		} else {
			setTimeout( function(){
				$.fileDownload( url, {
					data : {},
					httpMethod: "POST",
					successCallback : function() {
						try {
							success.call(this);
						} catch(e) {}
					} ,
					failCallback : function( responseHtml, url, error ){

						if( responseHtml.indexOf( "FILE_NOT_FOUND" ) > -1 ) {
							Message.alert(Message.NO_FILE_FOUND );
						}


						try {
							fail.call(this);
						} catch(e) {
						}
					}
				});
			}, 1000 );
		}
	}

	this.concurrentOutput = function(context,type,requestId) {
		var formId = LayoutManager.getCurrentBizFormId();
		$.fileDownload(SERVER_URL + "/" + context + "/download/concurrent/" + type + "/" + requestId,{
			data: {},
			httpMethod: 'POST'
		});
	}

	this.addParam = function(key, value) {
		var url = SERVER_URL + "/" + context + "/export/csv2/" + action;
		var data = { _param_ : JSON.stringify(param) };
		if (headers) {
			var arr = [];
			$(headers).each(function() {
				arr.push(JSON.stringify(this));
			});
			data["_headers_"] = "[" + arr.toString() + "]";
		}
		$.AjaxDownloader( { url : url, data : data });
	}
}

/************************************************************
 * 공통 코드셋을 가져와 화면에 사용할 수 있도록 하는 유틸리티 클래스
 * 서버에서 가지고 오는 컬럼(항목)
 * code : 코드값 ( ex. LGCOM )
 * name : 코드이름 ( ex. LGD Common )
 *
************************************************************/
var CommonCode = function(context) {
	var parameter = {
		queryId : []
	};
	var result = new Map();
	var queryId = "retrieveCommonCodeList";

	/* 공통 콤보의 기본 Query Id 를 사용하지 않는 특별한 경우에만 사용 */
	this.setQueryId = function(id) {
		queryId = id;
	}

	this.add = function(key, param) {
		if (param == undefined) {
			param = {
				key : key,
				queryId : "Common." + queryId
			}
		} else {
			if (param.queryId) {
				param.queryId = "Common." + param.queryId;
			} else {
				param.queryId = "Common." + queryId;
			}
			param.key = key;
		}
		parameter.queryId.push(param);
	}

	this.execute = function(key, parameter) {
		if (key == undefined) {
			_executeCommonCode();
		} else {
			this.add(key, parameter);
			_executeCommonCode();
			return result.get(key);
		}
	}

	function _executeCommonCode() {
		transaction_sync(context, "lgsysc/common/retrieveCommonCode",parameter, function(data) {
			var serverResult = data["result"];
			$.each(serverResult, function(key, value) {
				result.put(key, value);
			});
		});
	}

	this.get = function(key) {
		return result.get(key);
	}
}

var ValueSet = function(context) {
	var parameter = {
		valueSetId : []
	};

	var result = new Map();

	this.add = function(key, param) {
		if (typeof (key) == "string") {
			param.key = key;
		} else {
			param.key = param.valueSetId;
		}
		parameter.valueSetId.push(param);
	}

	this.execute = function(key, parameter) {
		if (key == undefined) {
			_executeCommonCode();
		} else {
			this.add(key, parameter);
			_executeCommonCode();
			return result.get(key);
		}
	}

	function _executeCommonCode() {
		transaction_sync(context, "lgsysc/common/retrieveValueSet", parameter, function(data) {
			var serverResult = data["result"];
			$.each(serverResult, function(key, value) {
				result.put(key, value);
			});
		});
	}

	this.get = function(key) {
		return result.get(key);
	}
}

/**
 * 요청서 처리
 * bizForm - 요청서 BizForm 객체
 * option  - 요청서 기본정보
 */
var RequestForm = function(bizForm, option) {
	var _this = this;
	var _form = bizForm;
	var requestKey = {
		requestMasterId:'',
		requestCode:''
	};
	if(typeof(option) == 'object') {
		requestKey = $.extend(requestKey,option);
	}
	// BizForm 에서 메뉴 정보를 얻는다.
	var menuItem = LayoutManager.getMenuItem(_form.getBizFormId());
	// 파일 다운로드를 위한 객체
	var down = new Downloader(_form);
	// 결재 구분 코드
	var _apprCode_ = new CommonCode(CONTEXT_PATH);
	_apprCode_.execute('approvalTypeCode',{queryId:'retrieveFilteredCommonCodeList',codeTypeCode:'LGCOM_APPROVAL_ACTION_CODE',filterColumn:'code_data3_value',filterVallue:'APPROVAL'});
	var __apprType = _apprCode_.get('approvalTypeCode');
	// 각 항목에 Form Util 설정
	var headerForm = null;		// 요청서 헤더정보
	var appLineForm = null;		// 요청서 결재선 정보
	var cbcForm = null;			// 요청서 참조자 정보
	var forwardForm = null;		// 요청서 전달자 정보
	// 각 영역 selector
	var headerSelector,approvalSelector,carbonSelector,forwardSelector;
	// 전달자 영역 Visible
	var forwarderAreaVisible = false;
	/**
	 * 요청서의 안내 탭의 내용을 조회해서 쓴다.
	 */
	this.drawInfomationTab = function(selector) {
		var _target_ = _form.select(selector);
		var programId;
		if(menuItem != null) {
			programId = $.trim(menuItem.programId);
		}
		var info = fncLoadRequestInfo({ 'programId':programId });
		if(info) {
			$(_target_).empty();
			var table = $('<table class="table table-condensed" summary=""></table>');
			table.append('<colgroup><col width="100"/><col width="*"/></colgroup>');
			var tbody = $('<tbody></tbody>');
			// 내용
			var row1 = $('<tr><td></td></tr>');
			row1.find('td').attr('colspan','2').addClass('text-left').css('padding','10px 5px');
			row1.find('td').html(info.manualContent);
			tbody.append(row1);
			// 첨부파일
			if($.trim(info.attachFileId) != '') {
				if(info.attachFile.length > 0) {
					var row2 = $('<tr><th></th><td class="text-left"></td></tr>');
					row2.find('th').html('<label>Attachment</label>');
					var ul = $('<ul class="_fileList_"></ul>');
					ul.css('padding','0px').css('margin','0px').css('list-style','none');
					$(info.attachFile).each(function() {
						var item = $('<li></li>');
						item.css('float','left').css('margin-left','5px').css('display','inline-block').css('padding','3px 5px');
						var anchor = $('<a href="#"></a>');
						anchor.attr('data-req-number',this['attachFileId']);
						anchor.attr('data-file-id',this['fileId']);
						anchor.attr('data-module-code',this['moduleCode']);
						anchor.click(function() {
							down.attachment($(this).data('fileId'),function(){},function(){},$(this).data('moduleCode'));
						});
						var fileName = $.trim(this['fileName']);
						if($.trim(this['docDesc']) != '') {
							fileName += ' ( ' + $.trim(this['docDesc']) + ' )';
						}
						anchor.text(fileName);
						item.append(anchor);
						ul.append(item);
					});
					row2.find('td').append(ul);
					tbody.append(row2);
				}
			}
			table.append(tbody);
			$(_target_).append(table);
		}
	};
	/**
	 * 요청자 정보를 그린다.
	 * 초기 주어진 요청 마스터 ID와 요청코드값을 가진 요청서의 진행상태에 따라 읽기전용, 편집용으로 자동 설정한다.
	 * 옵션에 요청 마스터 ID와 요청코드값이 주어지지 않을 경우 기본적으로 편집용으로 그린다.
	 * option: 선택
	 *        requestId : 요청 마스터 ID
	 *        requestCode : 요청코드
	 */
	this.drawRequestHeaderBox = function(selector, option) {
		if(typeof(option) == 'object') {
			requestKey = $.extend(requestKey,option);
		}
		var reqheader = { readonly: false };
		reqheader = $.extend(reqheader,requestKey);
		var header = fncLoadRequestHeader(reqheader);
		if(header) {
			// 요청서 그릴 때 요청ID와 요청코드가 주어지고
			if($.trim(reqheader['requestMasterId']) != '' && $.trim(reqheader['requestCode']) != '') {
				// 진행상태가 요청상태 이상이면 읽기 모드
				if($.trim(header['statusCode'] )!= '10') {
					reqheader['readonly'] = true;
				}
			}
			reqheader = $.extend(reqheader,header);
		}
		headerSelector = _form.select(selector);
		var header = $('<div></div>');
		header.addClass('sub-header');
		header.append('<h3>'+Message.REQUESTOR_TITLE+'</h3>');
		headerSelector.append(header);
		var detail = $('<div></div>');
		headerSelector.append(detail);
		var dtForm = $('<form></form>');
		dtForm.addClass('form').addClass('_requestHeadForm_');
		detail.append(dtForm);
		var dtlTable = $('<table></table>');
		dtlTable.addClass('table').addClass('table-condensed');
		dtlTable.attr('summary','Request Header');
		dtForm.append(dtlTable);
		dtlTable.append('<colgroup><col width="80"/><col width="200"/><col width="80"/><col width="200"/><col width="80"/><col width="250"/><col width="80"/><col width="*"/></colgroup>');
		var dtlBody = $('<tbody></tbody>');
		dtlTable.append(dtlBody);
		var row, th, td;
		// 1행 쓰기
		row = $('<tr></tr>');
		// 요청번호
		th = $('<th scope="row"></th>');
		th.append('<label>'+Message.REQUEST_NO+'</label>');
		td = $('<td></td>');
		td.append('<span name="_spnRequestNo">'+$.trim(reqheader['requestNo'])+'</span>');
		td.append('<input type="hidden" name="requestNo" value="'+$.trim(reqheader['requestNo'])+'"/>');
		row.append(th).append(td);
		// 요청자
		th = $('<th scope="row"></th>');
		th.append('<label>'+Message.REQUESTOR_INFO+'</label>');
		td = $('<td></td>');
		td.append('<span name="_spnRequestorInfo">'+$.trim(reqheader['requestorInfo'])+'</span>');
		// 요청자 ID
		td.append('<input type="hidden" name="requestorId"/>');
		td.find('input[name="requestorId"]').val($.trim(reqheader['requestorId']));
		// 요청마스터 ID
		td.append('<input type="hidden" name="requestMasterId"/>');
		td.find('input[name="requestMasterId"]').val($.trim(reqheader['requestMasterId']));
		// 요청코드
		td.append('<input type="hidden" name="requestCode"/>');
		td.find('input[name="requestCode"]').val($.trim(reqheader['requestCode']));
		// Org ID
		td.append('<input type="hidden" name="organizationId"/>');
		td.find('input[name="organizationId"]').val($.trim(reqheader['organizationId']));
		// Request No
		td.append('<input type="hidden" name="requestNo"/>');
		td.find('input[name="requestNo"]').val($.trim(reqheader['requestNo']));
		row.append(th).append(td);
		// 진행상태
		th = $('<th scope="row"></th>');
		th.append('<label>'+Message.REQUEST_STATUS+'</label>');
		td = $('<td></td>');
		td.append('<span name="_spnRequestStatus">'+$.trim(reqheader['statusName'])+'</span>');
		td.append('<input type="hidden" name="statusCode"/>');
		td.find('input[name="statusCode"]').val($.trim(reqheader['statusCode']));
		row.append(th).append(td);
		// 요청일시
		th = $('<th scope="row"></th>');
		th.append('<label>'+Message.REQUEST_DATE+'</label>');
		td = $('<td></td>');
		td.append('<span name="_spnRequestDate">'+$.trim(reqheader['requestDate'])+'</span>');
		row.append(th).append(td);
		dtlBody.append(row);
		// 2행 쓰기
		row = $('<tr></tr>');
		// 제목 쓰기
		th = $('<th scope="row"></th>');
		if(reqheader['readonly']) {
			th.append('<label>'+Message.REQUEST_TITLE+'</label>');
		} else {
			th.append('<label class="required">'+Message.REQUEST_TITLE+'</label>');
		}
		td = $('<td colspan="7"></td>');
		if(reqheader['readonly']) {
			td.append('<span name="_spnRequestTitle">'+$.trim(reqheader['requestTitle'])+'</span>');
		} else {
			td.append('<input type="text" name="requestTitle" class="form-control input-sm input-require"/>');
			td.find('input[name="requestTitle"]').val($.trim(reqheader['requestTitle']));
		}
		row.append(th).append(td);
		dtlBody.append(row);
		// 3행 쓰기
		if($.trim(reqheader['requestComment']) != '') {
			// 요청자 Comment
			row = $('<tr></tr>');
			th = $('<th scope="row"></th>');
			th.append('<label>'+Message.REQUEST_COMMENT+'</label>');
			td = $('<td colspan="7"></td>');
			td.append('<pre name="_preRequestComment">'+$.trim(reqheader['requestComment'])+'</pre>');
			row.append(th).append(td);
			dtlBody.append(row);
		}
		// 4행 쓰기
		if($.trim(reqheader['requestRemark']) != '') {
			// 요청 Remark
			row = $('<tr></tr>');
			th = $('<th scope="row"></th>');
			th.append('<label>'+Message.REQUEST_REMARK+'</label>');
			td = $('<td colspan="7"></td>');
			td.append('<pre name="_preRequestRemark">'+$.trim(reqheader['requestRemark'])+'</pre>');
			row.append(th).append(td);
			dtlBody.append(row);
		}
		headerForm = new FormUtil(_form, selector + ' form._requestHeadForm_');
	};
	/**
	 * 기존 정보를 제거하고 신규 정보를 재조회한다.
	 */
	this.resetRequestHeaderBox = function(requestId,requestCode) {
		if(typeof(requestId) == 'undefined') {
			requestId = '';
		}
		if(typeof(requestCode) == 'undefined') {
			requestCode = '';
		}
		if(headerForm) {
			headerForm.clear();
			// 요청번호
			headerSelector.find("span[name='_spnRequestNo']").empty();
			// 요청자
			headerSelector.find("span[name='_spnRequestorInfo']").empty();
			// 상태
			headerSelector.find("span[name='_spnRequestStatus']").empty();
			// 요청일
			headerSelector.find("span[name='_spnRequestDate']").empty();
			if($.trim(requestId) != '' && $.trim(requestCode) != '') {
				requestKey['requestMasterId'] = requestId;
				requestKey['requestCode'] = requestCode;
			}
			var header = fncLoadRequestHeader(requestKey);
			if(header) {
				headerForm.setValue(header);
				// 요청번호
				headerSelector.find("span[name='_spnRequestNo']").text($.trim(header['requestNo']));
				// 요청자
				headerSelector.find("span[name='_spnRequestorInfo']").text($.trim(header['requestorInfo']));
				// 상태
				headerSelector.find("span[name='_spnRequestStatus']").text($.trim(header['statusName']));
				// 요청일
				headerSelector.find("span[name='_spnRequestDate']").text($.trim(header['requestDate']));
			}
		}
	};
	/**
	 * 결재자 입력란을 그린다.
	 * 초기 주어진 요청 마스터 ID와 요청코드값을 가진 요청서의 진행상태에 따라 읽기전용, 편집용으로 자동 설정한다.
	 * 옵션에 요청 마스터 ID와 요청코드값이 주어지지 않을 경우 기본적으로 편집용으로 그린다.
	 * option:
	 *        requestId : 요청 마스터 ID
	 *        requestCode : 요청코드
	 *        mode: 'W', 'R'
	 *              - W : 편집모드로 순번, Approval Type, 승인자, 위임자, 추가/삭제 버튼 으로 타이틀이 구성된다.
	 *              - R : 읽기모드로 순번, 종류, 승인자, 위임자, 상태, 일자, 의견으로 타이틀이 구성된다.
	 * 화면에 팝업용 변수가 반드시 선언되어야 한다.
	 * myForm.popupInfo = { userPopup: {} };
	 */
	this.drawApprovalBox = function(selector, option) {
		if(typeof(option) == 'object') {
			requestKey = $.extend(requestKey,option);
		}
		if($.trim(requestKey['mode']) == '') {
			requestKey['mode'] = 'R';
		}
		approvalSelector = _form.select(selector);
		var _appr_status = '10';	// 초기진행상태는 임시저장
		/**
		 * 옵션에서 요청ID와 요청코드가 주어지면 요청서의 진행상태를 조회한다.
		 */
		if($.trim(requestKey['requestMasterId']) != '' && $.trim(requestKey['requestCode']) != '') {
			transaction_sync(CONTEXT_PATH,'common/requestForm/retrieveRequestStatusData', requestKey, function(data) {
				if(data.result) {
					_appr_status = $.trim(data.result['statusCode']);
					// 결재진행상태가 임시저장일 경우에만 편집가능
					if($.trim(_appr_status) == '' || $.trim(_appr_status) == '10') {
						requestKey['readonly'] = false;
					} else {
						requestKey['readonly'] = true;
					}
				}
			});
		}
		// 결재자 선택 입력 헤더 영역
		var header = $('<div></div>');
		header.addClass('module-group').addClass('clearfix');
		if($.trim(requestKey['mode']) == 'W' && !requestKey['readonly']) {
			// 제목 영역
			var leftdiv = $('<div></div>');
			leftdiv.addClass('pull-left').addClass('sub-header');
			leftdiv.append('<h3>' + Message.APPROVAL_TITLE + '</h3>');
			// 버튼 영역
			var divright = $('<div></div>');
			divright.addClass('pull-right');
			// Reset 버튼
			var btnReset = $('<button></button>');
			btnReset.addClass('btn').addClass('btn-default').addClass('btn-sm');
			btnReset.css('margin-right','5px');
			btnReset.html(Message.BUTTON_RESET);
			btnReset.click(function() {
				var outerDiv = $(this).parent().parent().next();
				outerDiv.find('>form>table>tbody>tr').each(function() {
					if($.trim($(this).find('input[name="settlementDeleteFlag"]').val()) != 'Y') {
						$(this).remove();
						fncResetApprovalSeq(approvalSelector);
					}
				});
			});
			// Add Row First 버튼
			var btnAddFirst = $('<button></button>');
			btnAddFirst.addClass('btn').addClass('btn-default').addClass('btn-sm');
			btnAddFirst.append('<span class="glyphicon glyphicon-plus"></span>').append(' ').append(Message.BUTTON_ADD_FIRST);
			btnAddFirst.click(function() {
				fncSearchApprover(approvalSelector,'P');
			});
			divright.append(btnReset).append(btnAddFirst);
			header.append(leftdiv).append(divright);
		} else {
			// 제목 영역
			var leftdiv = $('<div></div>');
			leftdiv.addClass('sub-header');
			leftdiv.append('<h3>' + Message.APPROVAL_TITLE + '</h3>');
			header.append(leftdiv);
		}
		approvalSelector.append(header);
		// 결재선 표시 영역
		var detail = $('<div></div>');
		detail.addClass('_approval_area_');
		var apprform = $('<form></form>');
		apprform.addClass('form').addClass('_approverForm_');
		detail.append(apprform);
		var table = $('<table></table>');
		table.addClass('table').addClass('table-condensed').addClass('table-bordered');
		if($.trim(requestKey['mode']) == 'W' && !requestKey['readonly']) {
			table.append('<colgroup><col width="50"/><col width="150"/><col width="300"/><col width="300"/><col width="*"/></colgroup>');
			table.append('<thead><tr><th>'+Message.APPROVAL_SEQ+'</th><th>'+Message.APPROVAL_TYPE+'</th><th>'+Message.APPROVAL_APPROVER+'</th><th>'+Message.APPROVAL_MANDATOR+'</th><th></th>');
		} else {
			table.append('<colgroup><col width="50"/><col width="110"/><col width="280"/><col width="280"/><col width="100"/><col width="100"/><col width="*"/></colgroup>');
			table.append('<thead><tr><th>'+Message.APPROVAL_SEQ+'</th><th>'+Message.APPROVAL_TYPE+'</th><th>'+Message.APPROVAL_APPROVER+'</th><th>'+Message.APPROVAL_MANDATOR+'</th><th>'+Message.APPROVAL_STATUS+'</th><th>'+Message.APPROVAL_DATE+'</th><th>'+Message.APPROVAL_COMMENT+'</th>');
		}
		table.append('<tbody></tbody>');
		apprform.append(table);
		approvalSelector.append(detail);
		/**
		 * 옵션에서 요청ID와 요청코드가 주어지면 기저장된 결재선 목록을 조회한다.
		 * 요청서의 진행상태가 10이 아니면 readonly 모드가 false 이다.
		 */
		if($.trim(requestKey['requestMasterId']) != '' && $.trim(requestKey['requestCode']) != '') {
			var approvalLine = fncLoadApprovalLineList(requestKey);
			if(approvalLine) {
				$(approvalLine).each(function() {
					fncAddApprover(approvalSelector,'A',-1,this);
				});
			}
		}
		appLineForm = new FormUtil(_form, selector + ' form._approverForm_');
	};
	/**
	 * 결재자 창을 초기화한다.
	 */
	this.resetApprovalBox = function(force) {
		var approvalRow = approvalSelector.find('>._approval_area_>form._approverForm_>table>tbody>tr');
		$(approvalRow).each(function(inx) {
			if(force) {
				$(this).remove();
			} else {
				if($.trim($(this).find('input[name="settlementDeleteFlag"]').val()) != 'Y') {
					$(this).remove();
				}
			}
		});
		fncResetApprovalSeq(approvalSelector);
	};
	/**
	 * 결재자 창을 재조회한다.
	 * requestId   - 요청 마스터 ID
	 * requestCode - 요청코드
	 * statusCode  - 결재상태코드
	 */
	this.reloadApprovalBox = function(requestId,requestCode,statusCode) {
		if(typeof(statusCode) == 'undefined') statusCode = '10';
		this.resetApprovalBox(true);
		requestKey['requestMasterId'] = requestId;
		requestKey['requestCode'] = requestCode;
		if(statusCode == '10') {
			requestKey['readonly'] = false;
		} else {
			requestKey['readonly'] = true;
		}
		var approvalLine = fncLoadApprovalLineList(requestKey);
		if(approvalLine) {
			$(approvalLine).each(function() {
				fncAddApprover(approvalSelector,'A',-1,this);
			});
		}
	};
	/**
	 * 결재자 창을 재조회한다.
	 * data - 추가할 결재자 정보
	 *    {
	 *    }
	 */
	this.addApprover = function(data) {
		fncAddApprover(approvalSelector,'A',-1,data);
	}
	/**
	 * 참조자 입력란을 그린다.
	 * 초기 주어진 요청 마스터 ID와 요청코드값을 가진 요청서의 진행상태에 따라 읽기전용, 편집용으로 자동 설정한다.
	 * 옵션에 요청 마스터 ID와 요청코드값이 주어지지 않을 경우 기본적으로 편집용으로 그린다.
	 * option:
	 *        requestId : 요청 마스터 ID
	 *        requestCode : 요청코드
	 * 화면에 팝업용 변수가 반드시 선언되어야 한다.
	 * myForm.popupInfo = { userMultiPopup: {} };
	 */
	this.drawCarbonCopyBox = function(selector,option) {
		if(typeof(option) == 'object') {
			requestKey = $.extend(requestKey,option);
		}
		carbonSelector = _form.select(selector);
		var _tableBody;
		var _appr_status = '10';	// 초기진행상태는 임시저장
		/**
		 * 옵션에서 요청ID와 요청코드가 주어지면 요청서의 진행상태를 조회한다.
		 */
		if($.trim(requestKey['requestMasterId']) != '' && $.trim(requestKey['requestCode']) != '') {
			transaction_sync(CONTEXT_PATH,'common/requestForm/retrieveRequestStatusData', requestKey, function(data) {
				if(data.result) {
					_appr_status = $.trim(data.result['statusCode']);
					// 결재진행상태가 임시저장일 경우에만 편집가능
					if($.trim(_appr_status) == '' || $.trim(_appr_status) == '10') {
						requestKey['readonly'] = false;
					} else {
						requestKey['readonly'] = true;
					}
				}
			});
		}
		// 참조자 선택 입력 헤더 영역
		var header = $('<div></div>');
		header.addClass('module-group').addClass('clearfix');
		if(requestKey['readonly']) {
			// 제목 영역
			var leftdiv = $('<div></div>');
			leftdiv.addClass('sub-header');
			leftdiv.append('<h3>' + Message.CARBONCOPY_TITLE + '</h3>');
			header.append(leftdiv);
		} else {
			// 제목 영역
			var leftdiv = $('<div></div>');
			leftdiv.addClass('pull-left').addClass('sub-header');
			leftdiv.append('<h3>' + Message.CARBONCOPY_TITLE + '</h3>');
			// 버튼 영역
			var divright = $('<div></div>');
			divright.addClass('pull-right');
			// Reset 버튼
			var btnReset = $('<button></button>');
			btnReset.addClass('btn').addClass('btn-default').addClass('btn-sm');
			btnReset.css('margin-right','5px');
			btnReset.html(Message.BUTTON_RESET);
			btnReset.click(function() {
				var outerDiv = $(this).parent().parent().next();
				outerDiv.find('>form>table>tbody>tr').each(function() {
					$(this).remove();
				});
			});
			// Add Row First 버튼
			var btnAddFirst = $('<button></button>');
			btnAddFirst.addClass('btn').addClass('btn-default').addClass('btn-sm');
			btnAddFirst.append('<span class="glyphicon glyphicon-plus"></span>').append(' ').append(Message.BUTTON_ADD_FIRST);
			btnAddFirst.click(function() {
				fncSearchCarbonCopier('P',-1);
			});
			divright.append(btnReset).append(btnAddFirst);
			header.append(leftdiv).append(divright);
		}
		carbonSelector.append(header);
		// 참조자 표시 영역
		var detail = $('<div></div>');
		detail.addClass('_carboncopy_area_');
		var apprform = $('<form></form>');
		apprform.addClass('form').addClass('_carboncopyForm_');
		detail.append(apprform);
		var table = $('<table></table>');
		table.addClass('table').addClass('table-condensed').addClass('table-bordered');
		table.attr('summary','Carbon Copy To');
		table.append('<colgroup><col width="100"/><col width="360"/><col width="*"/></colgroup>');
		if(requestKey['readonly']) {
			table.append('<thead><tr><th>'+Message.CARBONCOPY_SEQ+'</th><th>'+Message.CARBONCOPY_NAME+'</th><th>'+Message.CARBONCOPY_DATE+'</th></thead>');
		} else {
			table.append('<thead><tr><th>'+Message.CARBONCOPY_SEQ+'</th><th>'+Message.CARBONCOPY_NAME+'</th><th></th></thead>');
		}
		table.append('<tbody></tbody>');
		apprform.append(table);
		carbonSelector.append(detail);
		_tableBody = carbonSelector.find('._carboncopy_area_>form._carboncopyForm_>table>tbody');
		/**
		 * 옵션에 요청 마스터 ID와 요청코드가 있다면 기등록 참조자 목록을 조회한다.
		 * 요청서의 진행상태가 10이 아니면 readonly 모드가 false 이다.
		 */
		if($.trim(requestKey['requestMasterId']) != '' && $.trim(requestKey['requestCode']) != '') {
			var carbonCopyList = fncLoadCarbonCopierList(requestKey);
			if(carbonCopyList) {
				$(carbonCopyList).each(function(inx) {
					fncAddCarbonCopy(this);
				});
			}
		};
		cbcForm = new FormUtil(_form, selector + ' form._carboncopyForm_');
	};
	/**
	 * 참조자 창을 초기화한다.
	 */
	this.resetCarbonCopyBox = function() {
		if(carbonSelector) {
			var targetRows = carbonSelector.find('._carboncopy_area_>form._carboncopyForm_>table>tbody>tr');
			$(targetRows).each(function() {
				$(this).remove();
			});
		}
	}
	/**
	 * 참조자 창을 재조회한다.
	 */
	this.reloadCarbonCopyBox = function(requestId,requestCode,statusCode) {
		if(typeof(statusCode) == 'undefined') statusCode = '10';
		this.resetCarbonCopyBox();
		requestKey['requestMasterId'] = requestId;
		requestKey['requestCode'] = requestCode;
		var carbonCopyList = fncLoadCarbonCopierList(requestKey);
		if(carbonCopyList) {
			$(carbonCopyList).each(function(inx) {
				fncAddCarbonCopy(this);
			});
		}
	};
	/**
	 * 전달자 조회란을 그린다.
	 * 초기 주어진 요청 마스터 ID와 요청코드값이 주어질 경우에만 테이블을 그린다.
	 * option:
	 *        requestId : 요청 마스터 ID
	 *        requestCode : 요청코드
	 */
	this.drawForwarderBox = function(selector,option) {
		forwardSelector = _form.select(selector);
		if(typeof(option) == 'object') {
			requestKey = $.extend(requestKey,option);
		}
		// 참조자 선택 입력 헤더 영역
		var header = $('<div></div>');
		header.addClass('module-group').addClass('clearfix');
		// 제목 영역
		var leftdiv = $('<div></div>');
		leftdiv.addClass('sub-header');
		leftdiv.append('<h3>' + Message.FORWARDER_TITLE + '</h3>');
		header.append(leftdiv);
		forwardSelector.append(header);
		// 전달자 표시 영역
		var detail = $('<div></div>');
		detail.addClass('_forwarder_area_');
		var apprform = $('<form></form>');
		apprform.addClass('form').addClass('_forwardForm_');
		detail.append(apprform);
		var table = $('<table></table>');
		table.addClass('table').addClass('table-condensed').addClass('table-bordered');
		table.attr('summary','Forward To');
		table.append('<colgroup><col width="100"/><col width="360"/><col width="*"/></colgroup>');
		table.append('<thead><tr><th>'+Message.FORWARDER_SEQ+'</th><th>'+Message.FORWARDER_NAME+'</th><th>'+Message.FORWARDER_DATE+'</th>');
		table.append('<tbody></tbody>');
		apprform.append(table);
		forwardSelector.append(detail);
		/* 전달자 영역이 화면에 그려질 경우에만 조회를 수행한다. */
		if(!forwarderAreaVisible) {
			/* 옵션에서 요청ID와 요청코드가 주어질 경우에만 조회 및 전달 목록을 그린다. */
			if($.trim(requestKey['requestMasterId']) != '' && $.trim(requestKey['requestCode']) != '') {
				var forwardList = fncLoadForwarderList(requestKey);
				var ridx = 1;
				if(forwardList != null && forwardList.length > 0) {
					// 조회된 전달자 목록을 쓴다.
					$(forwardList).each(function() {
						fncAddForwarder(ridx,this);
						ridx++;
					});
				}
			}
		}
		forwardForm = new FormUtil(_form, selector + ' ._forwarder_area_ form');
		if(!forwarderAreaVisible) {
			$(forwardSelector).hide();
		}
	};
	/**
	 * 전달자 창을 초기화한다..
	 */
	this.resetForwarderBox = function() {
		if(forwardSelector) {
			var targetRows = forwardSelector.find('._forwarder_area_>form._forwardForm_>table>tbody>tr');
			$(targetRows).each(function() {
				$(this).remove();
			});
		}
	};
	/**
	 * 전달자 창을 재조회한다.
	 */
	this.reloadForwarderBox = function(requestId,requestCode,statusCode) {
		if(typeof(statusCode) == 'undefined') statusCode = '10';
		if(forwarderAreaVisible) {
			this.resetForwarderBox();
			requestKey['requestMasterId'] = requestId;
			requestKey['requestCode'] = requestCode;
			var forwarderList = fncLoadForwarderList(requestKey);
			var ridx = 1;
			if(forwarderList) {
				$(forwarderList).each(function(inx) {
					fncAddForwarder(ridx,this);
					ridx++;
				});
			}
		}
	};
	/**
	 * 전달자 영역의 Visible을 관리한다.
	 */
	this.setForwarderBoxVisible = function(visible) {
		forwarderAreaVisible = visible;
		if(forwardSelector) {
			if(forwarderAreaVisible) {
				$(forwardSelector).show();
			} else {
				$(forwardSelector).hide();
			}
		}
	};
	/**
	 * 검토자 입력란을 그린다.
	 * 초기 주어진 요청 마스터 ID와 요청코드값을 가진 요청서의 검토자가 있을 경우에만 그린다.
	 * option:
	 *        requestId : 요청 마스터 ID
	 *        requestCode : 요청코드
	 */
	this.drawPreviewBox = function(selector,option) {
		var _target = _form.select(selector);
		var _tableBody;
		var defOpt = {
			requestId: '',
			requestCode: ''
		};
		if(option == undefined) option = defOpt;
		option = $.extend(defOpt,option);
		// 조회를 위한 Arguments
		var param = {
			requestMasterId: $.trim(option['requestId']),
			requestCode: $.trim(option['requestCode'])
		};
		/* 옵션에서 요청ID와 요청코드가 주어질 경우에만 검토자 목록을 그린다. */
		if($.trim(option['requestId']) != '' && $.trim(option['requestCode']) != '') {
			transaction_sync(CONTEXT_PATH,'common/requestForm/retrieveReviewerList', param, function(data) {
				if(data.result) {
					var reviewList = data.result;
					if(reviewList != null && reviewList.length > 0) {
						// 검토자 선택 입력 헤더 영역
						var header = $('<div></div>');
						header.addClass('module-group').addClass('clearfix');
						// 제목 영역
						var leftdiv = $('<div></div>');
						leftdiv.addClass('sub-header');
						leftdiv.append('<h3>' + Message.REVIEWER_TITLE + '</h3>');
						header.append(leftdiv);
						_target.append(header);
						// 전달자 표시 영역
						var detail = $('<div></div>');
						detail.addClass('_reviewer_area_');
						var apprform = $('<form></form>');
						apprform.addClass('form').addClass('_reviewForm_');
						detail.append(apprform);
						var table = $('<table></table>');
						table.addClass('table').addClass('table-condensed').addClass('table-bordered');
						table.attr('summary','Forward To');
						table.append('<colgroup><col width="50%"/><col width="50%"/></colgroup>');
						table.append('<thead><tr><th>'+Message.REVIEWER_REQ+'</th><th>'+Message.REVIEWER_RES+'</th>');
						table.append('<tbody></tbody>');
						apprform.append(table);
						_target.append(detail);
						_tableBody = _target.find('._reviewer_area_>form._reviewForm_>table>tbody');
						// 조회된 검토내용을 쓴다.
						$(reviewList).each(function() {
							fncAddReviewer(this);
						});
					}
				}
			});
		}
		// 전달자 목록을 그린다.
		function fncAddReviewer(item) {
			if(_tableBody) {
				var list = item['attachFileList'];
				var attachment = "";
				if(list != undefined) {
					$(list).each(function(inx) {
						attachment += "<div><a href='/lgcom/download/common/mobile?fileId=" + this["fileId"] + "&moduleCode="+ this["moduleCode"] +"' style='text-decoration: underline;'>"+ this["fileName"] +"</a></div>";
					});
				}
				var row = $('<tr></tr>');
				var td1 = $('<td></td>');
				td1.addClass('text-left').css('vertical-align','top');
				td1.html($.trim(item['requestEmpName'])+'<br/>'+$.trim(item['requestComment'])+'<br/>'+$.trim(item['requestDate']));
				var td2 = $('<td></td>');
				td2.addClass('text-left').css('vertical-align','top');
				td2.html('<div>'+$.trim(item['reviewEmpName'])+'<br/>'+$.trim(item['reviewComment'])+'<br/>'+$.trim(item['reviewDate'])+'</div>'+attachment);
				row.append(td1).append(td2);
				_tableBody.append(row);
			}
		}
	};
	/**
	 * 요청서 헤더정보를 받는다.
	 */
	this.getRequestHeaderData = function() {
		if(headerForm != null) {
			return headerForm.getValue();
		}
	};
	/**
	 * 결재선 입력 건수 반환
	 */
	this.getRequestApproverCount = function() {
		return approvalSelector.find('>._approval_area_>._approverForm_>table>tbody>tr').length;
	};
	/**
	 * 요청서 결재선 정보를 받는다.
	 */
	this.getRequestApprovalLine = function() {
		var approvalLine = [];
		if(appLineForm != null) {
			var lineData = appLineForm.getValue();
			if(!Array.isArray(lineData['approvalActionCode'])) {
				approvalLine.push(lineData);
			} else {
				for(var i=0; i < lineData['approvalActionCode'].length; i++) {
					var lineItem = {};
					for(var key in lineData) {
						lineItem[key] = $.trim(lineData[key][i]);
					}
					approvalLine.push(lineItem);
				}
			}
		}
		return approvalLine;
	};
	/**
	 * 요청서 참조자 정보를 받는다.
	 */
	this.getRequestCarbonCopyList = function() {
		var carbonCopyList = [];
		if(cbcForm != null) {
			var ccData = cbcForm.getValue();
			if(!Array.isArray(ccData['applicationUserId'])) {
				carbonCopyList.push(ccData);
			} else {
				if(Array.isArray(ccData['applicationUserId']) && ccData['applicationUserId'].length > 0) {
					for(var i=0; i < ccData['applicationUserId'].length; i++) {
						var ccItem = {};
						for(var key in ccData) {
							ccItem[key] = $.trim(ccData[key][i]);
						}
						carbonCopyList.push(ccItem);
					}
				}
			}
		}
		return carbonCopyList;
	};
	/**
	 * 요청서 전달자 정보를 받는다.
	 */
	this.getRequestForwardList = function() {
		var forwarderList = [];
		if(forwardForm != null) {
			var forwardData = forwardForm.getValue();
			if(Array.isArray(forwardData['approvalSeqs']) && forwardData['approvalSeqs'].length > 0) {
				for(var i=0; i < forwardData['approvalSeqs'].length; i++) {
					var forwarderData = {};
					for(var key in forwardData) {
						forwarderData[key] = $.trim(forwardData[key][i]);
					}
					forwarderList.push(forwarderData);
				}
			}
		}
		return forwarderList;
	};
	/**
	 * Option 속성을 임의로 변경한다.
	 */
	this.setOption = function(option) {
		if(typeof(option) == 'object') {
			requestKey = $.extend(requestKey,option);
		}
	}
	/**
	 * 요청서 내용을 초기화한다.
	 */
	this.reset = function() {
		this.resetRequestHeaderBox();
		this.resetApprovalBox(true);
		this.resetCarbonCopyBox();
		this.resetForwarderBox();
	};

	/**************************************************
	 * 내부 사용 함수
	 **************************************************/
	/**
	 * 요청서 안내탭 정보 조회
	 */
	function fncLoadRequestInfo(param) {
		var headerData = {};
		_form.showProgress();
		transaction_sync(CONTEXT_PATH,'common/requestForm/retrieveRequestFormInfomationTab', param, function(data) {
			if(data.result) {
				headerData = data['result'];
			}
			_form.hideProgress();
		});
		return headerData;
	}
	/**
	 * 요청서 헤더 정보를 조회한다.
	 */
	function fncLoadRequestHeader(param) {
		var reqHeader = {};
		_form.showProgress();
		transaction_sync(CONTEXT_PATH,'common/requestForm/retrieveRequestHeadInfo', param, function(data) {
			if(data.result) {
				reqHeader = data.result;
			}
			_form.hideProgress();
		});
		return reqHeader;
	}
	/**
	 * 요청서 결재선 목록을 조회한다.
	 */
	function fncLoadApprovalLineList(param) {
		var approvalLine = [];
		_form.showProgress();
		transaction_sync(CONTEXT_PATH,'common/requestForm/retrieveApprovalLineList', param, function(data) {
			if(data.result) {
				approvalLine = data.result;
			}
			_form.hideProgress();
		});
		return approvalLine;
	}
	/**
	 * 결재자 추가
	 * type - P, A
	 *        P : 테이블의 첫 행에 결재자를 추가한다.
	 *        A : 선택된 Row 의 아래에 결재자를 추가한다.
	 * ridx - 테이블 tr Index
	 * data - 결재자 정보
	 */
	function fncAddApprover(selector,type,ridx,data) {
		var _tableBody = selector.find('div._approval_area_>form._approverForm_>table>tbody');
		var tr = $('<tr></tr>');
		var td1 = $('<td></td>');	// Seq
		td1.addClass('text-center');
		var spn = $('<span></span>');
		spn.attr('name','seq');
		var inp0 = $('<input type="hidden" name="approvalSeqs"/>');
		td1.append(spn).append(inp0);
		var td2 = $('<td></td>');	// Approval Type
		td2.addClass('text-center');
		if(requestKey['readonly']) {
			// 결재유형명
			td2.html($.trim(data['approvalActionName']));
			var inp0 = $('<input type="hidden" name="approvalActionCode"/>');
			inp0.val(data['approvalActionCode']);
			td2.append(inp0);
		} else {
			var cmb = $('<select></select>');
			cmb.addClass('form-control').addClass('input-sm').addClass('size_120');
			cmb.attr('name','approvalActionCode');
			$(__apprType).each(function() {
				cmb.append('<option value=' + $.trim(this['code']) + '>' + $.trim(this['name']) + '</option>');
			});
			if($.trim(data['approvalActionCode']) == '') {
				cmb.val('APPROVAL'); // Default APPROVAL
			} else {
				cmb.val($.trim(data['approvalActionCode']));
			}
			td2.append(cmb);
		}
		var td3 = $('<td></td>');	// Approver
		var apprInfo = $.trim(data['employeeName']);
		if(apprInfo != '') {
			// 직위
			if($.trim(data['positionName']) != '') {
				apprInfo += ' / ' + $.trim(data['positionName']);
			} else {
				apprInfo += ' / ' + $.trim(data['titleName']);
			}
			// 부서
			apprInfo += ' / ' + $.trim(data['departmentName']);
		}
		td3.html(apprInfo);
		var inp3 = $('<input type="hidden" name="applicationUserId"/>');
		inp3.val($.trim(data['applicationUserId']));
		td3.append(inp3);
		var inp4 = $('<input type="hidden" name="employeeNo"/>');
		inp4.val($.trim(data['employeeNo']));
		td3.append(inp4);
		var inp5 = $('<input type="hidden" name="settlementDeleteFlag"/>');
		inp5.val(data['settlementDeleteFlag']);
		td3.append(inp5);
		var inp6 = $('<input type="hidden" name="approvalLineId"/>');
		inp6.val($.trim(data['approvalLineId']));
		td3.append(inp6);
		var td4 = $('<td></td>');	// Mandator
		var mndInfo = $.trim(data['mandatorEmployeeName']);
		if(mndInfo != '') {
			// 직위
			if($.trim(data['mandatorPositionName']) != '') {
				mndInfo += ' / ' + $.trim(data['mandatorPositionName']);
			} else {
				mndInfo += ' / ' + $.trim(data['mandatorTitleName']);
			}
			// 부서
			mndInfo += ' / ' + $.trim(data['mandatorDepartmentName']);
		}
		td4.html(mndInfo);
		var mnp1 = $('<input type="hidden" name="mandatorUserId"/>');
		mnp1.val($.trim(data['mandatorUserId']));
		td4.append(mnp1);
		var mnp2 = $('<input type="hidden" name="mandatorEmployeeNo"/>');
		mnp2.val($.trim(data['mandatorEmployeeNo']));
		td4.append(mnp2);
		var td5 = $('<td></td>');	// Button
		if($.trim(requestKey['mode']) == 'W') {
			var btn1 = $('<button type="button" class="icon-plus" role="button"></button>');
			btn1.click(function() {
				fncSearchApprover(selector,'A',$(this).closest('tr').data('idx'));
			});
			td5.append(btn1);
			if($.trim(data['settlementDeleteFlag']) != 'Y') {
				var btn2 = $('<button type="button" class="icon-trash" role="button"></button>');
				btn2.click(function() {
					$(this).closest('tr').remove();
					fncResetApprovalSeq(selector);
				});
				td5.append(btn2);
			}
		} else {
			// 상태
			td5.addClass('text-center');
			td5.html($.trim(data['approvalStatusName']));
		}
		tr.append(td1).append(td2).append(td3).append(td4).append(td5);
		if($.trim(requestKey['mode']) == 'R') {
			var td6 = $('<td></td>');	// 일자
			td6.addClass('text-center');
			td6.html($.trim(data['approvalDate']));
			var td7 = $('<td></td>');	// 의견
			td7.html($.trim(data['approvalComment']));
			tr.append(td6).append(td7);
		}
		if(type == 'P') {
			_tableBody.prepend(tr);
		} else if(type == 'A') {
			if(ridx == -1) {
				_tableBody.append(tr);
			} else {
				tr.insertAfter(_tableBody.find("tr[data-idx='"+ridx+"']"));
			}
		}
		$(_tableBody).find('tr').each(function(idx) {
			$(this).attr('data-idx',idx);
		});
		fncResetApprovalSeq(selector);
	}
	// 결재차수 세팅
	function fncResetApprovalSeq(selector) {
		var _tableBody = selector.find('div._approval_area_>form._approverForm_>table>tbody');
		var approw = _tableBody.find('tr');
		//화면에서의 Seq 값 세팅
		var prevAction = '';
		var currSeq = 0;
		$(approw).each(function(inx) {
			$(this).attr('data-row-index',inx);
			var approveAction = $(this).find("td:nth-child(2) select>option:selected").val();
			if($.trim(approveAction) == '') {
				approveAction = $(this).find("input[name='approvalActionCode']").val();
			}
			if(approveAction == 'APPROVAL' || approveAction == 'AGREEMENT') {
				// 결재유형이 승인 또는 합의이면
				$(this).find("td:nth-child(1)>span[name='seq']").text(currSeq+1);
				$(this).find("td:nth-child(1)>input[name='approvalSeqs']").val(currSeq+1);
				prevAction = approveAction;
				currSeq++;
			} else if(approveAction != prevAction) {
				// 직전과 결재유형이 다르면
				$(this).find("td:nth-child(1)>span[name='seq']").text(currSeq+1);
				$(this).find("td:nth-child(1)>input[name='approvalSeqs']").val(currSeq+1);
				prevAction = approveAction;
				currSeq++;
			} else {
				$(this).find("td:nth-child(1)>span[name='seq']").text(currSeq);
				$(this).find("td:nth-child(1)>input[name='approvalSeqs']").val(currSeq);
			}
		});
	}
	// 결재자 검색 팝업
	function fncSearchApprover(_selector,mode,ridx) {
		if(ridx == undefined) ridx = -1;
		_form.popupInfo.userPopup = null;
		_form.popupInfo.userPopup = {};
		_form.popupInfo.userPopup['searchMode'] = 'single';
		var popup = new Popup(_form,'lgcom','M_LGUTLC_1142',Message.APPROVER_POPUP);
		popup.setSize(800,494);	// searchMode 'Single'
		popup.open(function() {
			var result = _form.popupInfo.userPopup.userData;
			if(result && result.length == 1) {
				var item = {
					applicationUserId: $.trim(result[0]['userId']),
					departmentName: $.trim(result[0]['departmentName']),
					positionName: $.trim(result[0]['positionName']),
					titleName: $.trim(result[0]['titleName']),
					employeeNo: $.trim(result[0]['employeeNo']),
					employeeName: $.trim(result[0]['employeeName']),
					settlementDeleteFlag: 'N'
				};
				// 위임 정보 조회
				transaction_sync(CONTEXT_PATH,'common/requestForm/retrievePortalMandatorInfo',item,function(data) {
					if(data.result) {
						var _result = data.result;
						item = {
							applicationUserId: $.trim(_result['applicationUserId']),
							departmentName: $.trim(_result['departmentName']),
							positionName: $.trim(_result['positionName']),
							titleName: $.trim(_result['titleName']),
							employeeNo: $.trim(_result['employeeNo']),
							employeeName: $.trim(_result['employeeName']),
							settlementDeleteFlag: 'N',
							approvalLineId: $.trim(_result['approvalLineId']),
							mandatorUserId: $.trim(_result['mandatorUserId']),
							mandatorEmployeeNo: $.trim(_result['mandatorEmployeeNo']),
							mandatorEmployeeName: $.trim(_result['mandatorEmployeeName']),
							mandatorDepartmentName: $.trim(_result['mandatorDepartmentName']),
							mandatorPositionName: $.trim(_result['mandatorPositionName']),
							mandatorTitleName:$.trim(_result['mandatorTitleName'])
						};
						fncAddApprover(_selector,mode,ridx,item);
					}
				});
			}
		});
	}
	// 참조자 목록 조회
	function fncLoadCarbonCopierList(param) {
		var carbonCopierList = [];
		_form.showProgress();
		transaction_sync(CONTEXT_PATH,'common/requestForm/retrieveCarbonCopyList', param, function(data) {
			if(data.result) {
				carbonCopierList = data.result;
			}
			_form.hideProgress();
		});
		return carbonCopierList;
	}
	// 참조자 추가
	function fncAddCarbonCopy(item) {
		var _tableBody = carbonSelector.find('._carboncopy_area_>form._carboncopyForm_>table>tbody');
		//이미 이 안에 추가된 경우에는 추가하지 않고 끝
		if(_tableBody.find("input[name='applicationUserId'][value='" + item["applicationUserId"] + "']").exists()) {
			Message.alert($.trim(item['employeeName']) + ' is already a selected ' + Message.CARBONCOPY_POPUP + '.');
			return;
		}
		var tr = $('<tr></tr>');
		var td1 = $('<td></td>');
		td1.addClass('text-center');
		var spn = $('<span name="seq"></span>');
		td1.append(spn);
		var td2 = $('<td></td>');
		var ipt1 = $('<input type="hidden" name="applicationUserId"/>');
		ipt1.val($.trim(item['applicationUserId']));
		var ipt2 = $('<input type="hidden" name="employeeNo"/>');
		ipt2.val($.trim(item['employeeNo']));
		var refrInfo = $.trim(item['employeeName']);
		if(refrInfo != '') {
			// 직위
			if($.trim(item['positionName']) != '') {
				refrInfo += ' / ' + $.trim(item['positionName']);
			} else {
				refrInfo += ' / ' + $.trim(item['titleName']);
			}
			// 부서
			refrInfo += ' / ' + $.trim(item['departmentName']);
		}
		td2.html(refrInfo);
		td2.append(ipt1).append(ipt2);
		var td3 = $('<td></td>');
		if(requestKey['readonly']) {
			td3.html($.trim(item['approvalDate']));
		} else {
			var btn1 = $('<button type="button" class="icon-plus" role="button"></button>');
			btn1.click(function() {
				fncSearchCarbonCopier('A',$(this).closest('tr').data('idx'));
			});
			var btn2 = $('<button type="button" class="icon-trash" role="button"></button>');
			btn2.click(function() {
				$(this).closest('tr').remove();
				fncResetCarbonCopySeq();
			});
			td3.append(btn1).append(btn2);
		}
		tr.append(td1).append(td2).append(td3);
		_tableBody.append(tr);
		$(_tableBody).find('tr').each(function(idx) {
			$(this).attr('data-idx',idx);
		});
		fncResetCarbonCopySeq();
	}
	// 결재차수 세팅
	function fncResetCarbonCopySeq() {
		var _tableBody = carbonSelector.find('._carboncopy_area_>form._carboncopyForm_>table>tbody');
		var approw = _tableBody.find('tr');
		$(approw).each(function(inx) {
			$(this).find("td:nth-child(1)>span[name='seq']").text((inx+1));
		});
	}
	// 참조자 검색 팝업
	function fncSearchCarbonCopier(type,ridx) {
		_form.popupInfo.userMultiPopup = null;
		_form.popupInfo.userMultiPopup = {};
		_form.popupInfo.userMultiPopup['keyType']  = 'applicationUserId';	// applicationUserId 또는 userName(사번)
		_form.popupInfo.userMultiPopup['keyValue'] = '';
		var popup = new Popup(_form,'lgcom','M_LGSYSC_1150',Message.CARBONCOPY_POPUP);
		popup.setSize(1000,528);
		popup.open(function() {
			var _list = _form.popupInfo.userMultiPopup['userList'];
			if(_list) {
				$(_list).each(function(idx) {
					var item = {
						applicationUserId: $.trim(this['userId']),
						employeeNo: $.trim(this['employeeNo']),
						employeeName: $.trim(this['employeeName']),
						positionName: $.trim(this['positionName']),
						titleName: $.trim(this['titleName']),
						departmentName: $.trim(this['departmentName'])
					};
					fncAddCarbonCopy(item);
				});
			}
		});
	}
	// 전달자 목록 조회
	function fncLoadForwarderList(param) {
		var forwardList = [];
		_form.showProgress();
		transaction_sync(CONTEXT_PATH,'common/requestForm/retrieveForwarderList', param, function(data) {
			if(data.result) {
				forwardList = data.result;
			}
			_form.hideProgress();
		});
		return forwardList;
	}
	// 전달자 목록을 그린다.
	function fncAddForwarder(inx,item) {
		_tableBody = forwardSelector.find('._forwarder_area_>form._forwardForm_>table>tbody');
		var row = $('<tr></tr>');
		var td1 = $('<td></td>');
		td1.addClass('text-center');
		td1.html(inx);
		td1.append('<input type="hidden" name="approvalSeqs" value="'+$.trim(item['approvalSeqs'])+'"/>');
		td1.append('<input type="hidden" name="employeeNo" value="'+$.trim(item['userNo'])+'"/>');
		var td2 = $('<td></td>');
		td2.html($.trim(item['referEmpName']));
		var td3 = $('<td></td>');
		td3.html($.trim(item['approvalDate']));
		row.append(td1).append(td2).append(td3);
		_tableBody.append(row);
	}
};

var BiMatrix = function( bizForm, selector, option ){
	var bizFormId = bizForm.getBizFormId();
	var _uuid = uuid();
	var container = bizForm.select(selector);
	var ready = false;

	$(container).css( {"overflow": "hidden"} ).closest("._contentWrapper").css( {"overflow": "hidden"} );

	if( option == undefined ){
		option = {};
	}

	this.init = function( param ){

		addGlobalContol();

		var form = $("<form style='display: none;' method='post' action='" + SERVER_URL + "/lgbmx/extention/portal/jsp/sso/sso_login.jsp' target='" + _uuid + "_biMatrixFrame'></form>");

		form.append("<input type='hidden' name='id' value='"+ option["id"]+"' />");
		form.append("<input type='hidden' name='uid' value='matrix' />");
		form.append("<input type='hidden' name='ssoId' value='"+ SESSION_USER.ssoId +"' />");
		form.append("<input type='hidden' name='containerId' value='"+ _uuid +"' />");

		$.each( param, function(key, value){
			form.append("<input type='hidden' name='"+key+"' value='"+value+"' />");
		});

		var iframe = $("<iframe id='frm" + _uuid + "_biMatrixFrame' class='externalFrame' name='" + _uuid + "_biMatrixFrame' width='100%' height='100%' frameBorder='0'></iframe>");
		var wrapper = $("<div style='position:absolute;top:0px;left:0px;right:0px;bottom:-7px;'></div>")

		wrapper.append(iframe);

		container.append( wrapper );
		container.append( form );

		container.append( "<iframe id='layer_"+ _uuid +"' style='position:absolute;bottom:20px;right:0px;width:0px;height:0px;z-index:100;display:none;'></iframe>" );

		$(form).submit();

		$( "#_dropdown_" + _uuid ).on('show.bs.dropdown', function () {
			$("#layer_" + _uuid ).show();
		});

		$( "#_dropdown_" + _uuid ).on('hide.bs.dropdown', function () {
			$("#layer_" + _uuid ).hide();
		});

		setTimeout( function(){
			form.remove();
		}, 500);
	}

	this.refresh = function(){
		getMatrix().fnMatrixViewer().Refresh();
	}

	this.execute = function( macroName, param ){
		if( !ready ) {
			alert("Please waite. Report is getting ready.");
			return;
		}

		$.each( param, function( key, value ){
			getMatrix().fnSetRangeValue( key, value );
		});

		if( macroName == "SEARCH" ){
			getMatrix().fnRefresh();
		} else {
			getMatrix().fnMacroCall( macroName );
		}
	}

	this.onComplete = function(){
		ready = true;
	}


	function addGlobalContol(){

		var control = $("<div class='bimatrixGlobalButtons'><div class='options' data-action='options'></div></div>");
		var pannel =  $('<ul class="dropdown-menu dropdown-menu-right _biMatrixExtend" >'+
							'<li style="display: list-item;"><a href="#" data-action="download" >엑셀 다운로드</a></li>'+
							'<li style="display: list-item;"><a href="#" data-action="header" data-status="OFF" >헤더 보기</a></li>'+
							'<li style="display: list-item;"><a href="#" data-action="tab" data-status="OFF" >시트탭 보기</a></li>'+
							'<li style="display: list-item;"><a href="#" data-action="formula" data-status="OFF" >수식입력줄 보기</a></li>'+
							'<li style="display: list-item;"><a href="#" data-action="fixed" data-status="OFF" >틀 고정</a></li>'+
							'<li style="display: list-item;"><a href="#" data-action="satus" data-status="OFF" >상태 바 보기</a></li>'+
						'</ul>');
		var backpanel =  $('<iframe class="_biMatrixExtendBack" frameBorder="0" src="about:blank" ></iframe>');

		//버튼을 container 의 바깥에 위치시키기 위한 연산을 수행한다.
		var content = $(container).closest("._content");

		$(content).append(control).append( pannel ).append( backpanel );;
		$(control).css({"top": ( $( container ).position().top - 22 ) + "px","left": $( container ).position().left + "px"});
		$(pannel).css({"top": ( $( container ).position().top - 2 ) + "px","left": $( container ).position().left + "px"});
		$(backpanel).css({"top": ( $( container ).position().top - 2 ) + "px","left": $( container ).position().left + "px"});

		$(pannel).data("STATUS", "CLOSED");

		bizForm.addEvent( "click", ".bimatrixGlobalButtons [data-action], ._biMatrixExtend [data-action]", function( event ){
			var item = $(event.target);
			var action = $(item).data("action");

			switch( action ) {
				case "options" :
					if( $(pannel).data("STATUS") == "OPEN" ) {
						$(backpanel).hide();
						$(pannel).hide();
						$(pannel).data("STATUS", "CLOSED");
					} else {
						$(backpanel).show();
						$(pannel).show();
						$(pannel).data("STATUS", "OPEN");
					}
					break;
				case "download" :
					getMatrix().fnExport();
					break;
				case "header" :
					getMatrix().fnDisplayHeadings();
					break;
				case "tab" :
					getMatrix().fnSheetVisible();
					break;
				case "formula" :
					getMatrix().fnDisplayFormulas();
					break;
				case "fixed" :
					getMatrix().fnFreezePanes();
					break;
				case "satus" :
					getMatrix().fnDisplayStatusBar();
					break;
			}  //

			if( action != "options" ){
				$(backpanel).hide();
				$(pannel).hide();
				$(pannel).data("STATUS", "CLOSED");
			}
		});
	}

	function getMatrix() {
		return bizForm.select( "#frm"+ _uuid + "_biMatrixFrame" )[0].contentWindow.FRAME_MATRIX.FRAME_MATRIX;
	}

	if( $(document).data("BIMATRIX") == undefined ) {
		$(document).data("BIMATRIX", {} );
	}

	var info = $(document).data("BIMATRIX");
	info[ option["id"] ] = this;
}

function biMtrixCallback( reportId ) {
	var matrix = $(document).data("BIMATRIX")[reportId];
	matrix.onComplete();
}

/* General Utility Functions */ 
function trace(str, item) {
	if ( Param.debug == "Y" || SYSTEM_ENV != "prod") {
		if (console && console['log'] ) {
			if (arguments.length > 1 && typeof str === 'string') {
				console.log(str + ": ", item);
			} else {
				console.log(str);
			}
		}
	}
}

/*
var trace = function(){
	if( !window.console || !console.log ) {
		return;
	}
	
	return Function.prototype.bind.call( console.log, console);
}();
*/
function launch(func) {
	if( Param.debug == "Y") {
		func.call(this);
	} else {
		try {
			func.call(this);
		} catch (e) {
			Message.error(Message.APPLICATION_ERROR + " : <br>" + e.message);
			trace(e.name + " - " + e.message);
		}
	}
}

function uuid() {
	function s4() {
		return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
	}
	return "ui_" + s4() + s4() + s4() + s4() + s4() + s4() + s4() + s4() + "_";
}

function random(length) {
	if (length == undefined) {
		length = 10;
	}
	return Math.round(Math.random() * Math.pow(10, length));
}

function setCookie(c_name, value, exdays) {
	var exdate = new Date();
	exdate.setDate(exdate.getDate() + exdays);
	var c_value = escape(value) + ((exdays == null) ? "" : "; expires=" + exdate.toUTCString());
	document.cookie = c_name + "=" + c_value;
}

function getCookie(c_name) {
	var i, x, y, ARRcookies = document.cookie.split(";");
	for (i = 0; i < ARRcookies.length; i++) {
		x = ARRcookies[i].substr(0, ARRcookies[i].indexOf("="));
		y = ARRcookies[i].substr(ARRcookies[i].indexOf("=") + 1);
		x = x.replace(/^\s+|\s+$/g, "");
		if (x == c_name) {
			return unescape(y);
		}
	}
}

function transaction_sync(context, action, data, callback, errorCallback) {
	_transaction(false, context, action, data, callback, errorCallback);
}

function transaction(context, action, data, callback, errorCallback) {
	_transaction(true, context, action, data, callback, errorCallback);
}

/* Ajax를활용한 서버 트랜잭션 코드 */
function _transaction(async, context, action, data, callback, errorCallback) {
	// 이 트랜잭션과 연관된 menuId, programdId 를 추적하기 위한 추적정보를 header에 뭍혀 서버로 보내기 위한 코드 (
	// 프로그램 고유의 정보가 취득되지 않으면, 모두 main 으로 값이 들어간다. )
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

	$.ajax({
		dataType : "JSON",
		contentType : "application/json; charset=UTF-8",
		type : "POST",
		async : async,
		data : JSON.stringify(data),
		headers : {
			headerInfo : JSON.stringify(headerInfo)
		},
		url : url,
		success : function(data) {
			if (callback) {
				var serverMessage = data["_server_message_"];

				if (serverMessage.type == "SUCCESS") {
					callback(data, serverMessage);
				} else {
					try {
						errorCallback.call(this, serverMessage);
					} catch (e) {

					} finally {
						 Message.error(serverMessage.text);
					}

					// 전 화면에 걸쳐서 모든 spinner를 숨긴다.
					$(".spinnerBack, .spinner").hide();

					// 해당 화면의 Grid 의 spinner 를 숨긴다.
					try {
						BizForm.offGridProgress();
					} catch( e ) {}

				}
			}

			try{
				LayoutManager.initSessionTimeout();
			}catch( e ){ }
		},
		error : function(jqXHR, textStatus, errorThrown) {
			trace(textStatus + " : " + errorThrown);
		},
		statusCode : {
			404 : function() {
				alert("[ERROR] page not found : " + url);
			},
			401 : function(jqXHR) { // 로그인이 필요한 상황 -> 로그인 페이지로 보낸다.
				var data = JSON.parse(jqXHR.responseText);
				var serverMessage = data["_server_message_"];
				Message.error(serverMessage.text, function() {
					var nav = new Navigate("lgcom", "login");
					nav.goGet();
				});
			},
			405 : function(jqXHR) { // 해당 요청에 권한이 없는 상황 -> 메세지만 표출하고 만다.
				var data = JSON.parse(jqXHR.responseText);
				var serverMessage = data["_server_message_"];
				Message.error(serverMessage.text);

				BizForm.offGridProgress();
			},
			504 : function(jqXHR) { // Request Timeout
				Message.error("504 : Request Timeout");
				BizForm.offGridProgress();
			}
		}
	});
}

function showProgress() {
	var container = $("body");
	if ( !container.find(" .spinnerBack").exists()) {
		var contentLoader = $("<div class='spinnerBack'></div><div class='spinner'><span>Loading...</span></div>");
		$(container).append(contentLoader);
		$(contentLoader).find(".spinnerBack").css("z-index", "2000");
		$(contentLoader).find(".spinner").css("z-index", "2001");
	}
	$(container).find(".spinnerBack, .spinner").show();
}

function hideProgress() {
	$(".spinnerBack , .spinner").hide();
}

/**
 * IFrame Dom 을 받아서 src 속성이 있는지 체크하고
 * src 속성이 없다면 IFrame의 window location 을 읽어서 경로를 반환한다.
 */
function parseIframeSource(iframeDom) {
	var src = $.trim($(iframeDom).attr('src'));
	if(src == '') {
		if($(iframeDom).get(0).contentWindow && $(iframeDom).get(0).contentWindow.location.href) {
			src = $.trim($(iframeDom).get(0).contentWindow.location.href);
		}
	}
	return src;
}

/**
 * IFrame Dom 을 받아서 src 속성이 있는지 체크하고
 * src 속성이 있다면 src 속성을 about:blank 값으로 변경
 * src 속성이 없다면 IFrame의 window location 을 읽어서 경로를 about:blank로 변경한다.
 */
function clearIframeSource(iframeDom) {
	var src = $.trim($(iframeDom).attr('src'));
	if(src == '' || src == 'about:blank') {
		var windowObj = $(iframeDom).get(0).contentWindow;
		if(windowObj) {
			windowObj.location.href = 'about:blank';
		}
	} else {
		$(iframeDom).attr('src','about:blank');
	}
}

function isSmallLayout() {
	return $("body").hasClass("page-sm");
}
