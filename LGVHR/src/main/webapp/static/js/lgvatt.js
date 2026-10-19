// https://tc39.github.io/ecma262/#sec-array.prototype.find
if (!Array.prototype.find) {
  Object.defineProperty(Array.prototype, 'find', {
    value: function(predicate) {
     // 1. Let O be ? ToObject(this value).
      if (this == null) {
        throw new TypeError('"this" is null or not defined');
      }

      var o = Object(this);

      // 2. Let len be ? ToLength(? Get(O, "length")).
      var len = o.length >>> 0;

      // 3. If IsCallable(predicate) is false, throw a TypeError exception.
      if (typeof predicate !== 'function') {
        throw new TypeError('predicate must be a function');
      }

      // 4. If thisArg was supplied, let T be thisArg; else let T be undefined.
      var thisArg = arguments[1];

      // 5. Let k be 0.
      var k = 0;

      // 6. Repeat, while k < len
      while (k < len) {
        // a. Let Pk be ! ToString(k).
        // b. Let kValue be ? Get(O, Pk).
        // c. Let testResult be ToBoolean(? Call(predicate, T, « kValue, k, O »)).
        // d. If testResult is true, return kValue.
        var kValue = o[k];
        if (predicate.call(thisArg, kValue, k, o)) {
          return kValue;
        }
        // e. Increase k by 1.
        k++;
      }

      // 7. Return undefined.
      return undefined;
    }
  });
}

//https://tc39.github.io/ecma262/#sec-array.prototype.findIndex
if (!Array.prototype.findIndex) {
  Object.defineProperty(Array.prototype, 'findIndex', {
    value: function(predicate) {
     // 1. Let O be ? ToObject(this value).
      if (this == null) {
        throw new TypeError('"this" is null or not defined');
      }

      var o = Object(this);

      // 2. Let len be ? ToLength(? Get(O, "length")).
      var len = o.length >>> 0;

      // 3. If IsCallable(predicate) is false, throw a TypeError exception.
      if (typeof predicate !== 'function') {
        throw new TypeError('predicate must be a function');
      }

      // 4. If thisArg was supplied, let T be thisArg; else let T be undefined.
      var thisArg = arguments[1];

      // 5. Let k be 0.
      var k = 0;

      // 6. Repeat, while k < len
      while (k < len) {
        // a. Let Pk be ! ToString(k).
        // b. Let kValue be ? Get(O, Pk).
        // c. Let testResult be ToBoolean(? Call(predicate, T, « kValue, k, O »)).
        // d. If testResult is true, return k.
        var kValue = o[k];
        if (predicate.call(thisArg, kValue, k, o)) {
          return k;
        }
        // e. Increase k by 1.
        k++;
      }

      // 7. Return -1.
      return -1;
    }
  });
}


/*특정한 키를 중심으로 포도송이를 레코드 형태로 바꿔주는 함수 */
function fncArrangeMultiLine( data, key ) {
	var arr = [];

	if( typeof data[key] == "string" ) {
		var result = {};
		$.each( data, function( key, value){
			result[key] = value;
		});
		arr.push( result );
	} else {
		$( data[key] ).each( function( inx ){
			var result = {};
			$.each( data, function( key, value){
				result[key] = value[inx];
			});
			arr.push( result );
		});
	}
	return arr;
}

/* 그리드에서 등록/수정된 행을 배열로 반환하는 함수 */
function fncArrangeMultiLineGrid( cgrid, rowStatus ) {
	var arr = [];
	var dataProvider = cgrid.getDataProvider();
	
	if ( isNull(rowStatus) ) {
		arr = fncArrangeMultiLineGridAll( cgrid );
	} else {
		//rowStatus : created, updated, delete
		$(rowStatus.split(',')).each(function() {
			var rowIdxs = dataProvider.getStateRows(this);
			if (rowIdxs) {
				for (var a = 0; a < rowIdxs.length; a++) {
					arr.push(dataProvider.getJsonRow(rowIdxs[a]));
				}
			}
		});
	}
	return arr;
}

/* 그리드 전체행을 배열로 반환하는 함수 */
function fncArrangeMultiLineGridAll( cgrid ) {
	var arr = [];
	var dataProvider = cgrid.getDataProvider();
	for (var a = 0; a < dataProvider.getRowCount(); a++) {
		arr.push(dataProvider.getJsonRow(a));
	}
	return arr;
}

function auto_date_format( e, oThis ){
    
    var num_arr = [ 
        97, 98, 99, 100, 101, 102, 103, 104, 105, 96,
        48, 49, 50, 51, 52, 53, 54, 55, 56, 57
    ]
    
    var key_code = ( e.which ) ? e.which : e.keyCode;
    if( num_arr.indexOf( Number( key_code ) ) != -1 ){
    
        var len = oThis.value.length;
        
        if( len == 2 ) {
        	oThis.value += "/";
        }else if( len == 5 ) {
        	oThis.value += "/";
        }
    }
}

$('#planStartDate').keypress(function (event) { 
	if (event.which && (event.which <= 47 || event.which >= 58) && event.which != 8) { 
		event.preventDefault(); 
	} 
});
$('#planEndDate').keypress(function (event) { 
	if (event.which && (event.which <= 47 || event.which >= 58) && event.which != 8) { 
		event.preventDefault(); 
	} 
});

/*
 * 윤년여부 검사
 */
function isLeaf(year) {
    var leaf = false;

    if(year % 4 == 0) {
        leaf = true;

        if(year % 100 == 0) {
            leaf = false;
        }
        if(year % 400 == 0) {
            leaf = true;
        }
    }
    return leaf;
}
/*
 * 날짜가 유효한지 검사
 */
function isValidDate(d) {
    // 포맷에 안맞으면 false리턴
    var month_day = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    var dateToken = d.split('/');
    var year = Number(dateToken[2]);
    var month = Number(dateToken[1]);
    var day = Number(dateToken[0]);
    
    // 날짜가 0이면 false
    if(day == 0) {
        return false;
    }

    var isValid = false;

    // 윤년일때
    if(isLeaf(year)) {
        if(month == 2) {
            if(day <= month_day[month-1] + 1) {
                isValid = true;
            }
        } else {
            if(day <= month_day[month-1]) {
                isValid = true;
            }
        }
    } else {
        if(day <= month_day[month-1]) {
        	isValid = true;
        }
    }
    
    if(month > 12) {
		isValid = false;
	}
	if(year < 1900) {
		isValid = false;
	}
	if(year > 3000) {
		isValid = false;
	}
	
	if(dateToken.length > 8) {
		isValid = false;
	}
	
    return isValid;
}
/*
 * 시작일자와 종료일자 비교
 */
function isValidDateBetween(dateFrom, dateTo) {

	var startDateArr = dateFrom.split('/');
	var endDateArr = dateTo.split('/');
	var isValid = false;
	
	var startDateCompare = new Date(startDateArr[2], parseInt(startDateArr[1])-1, startDateArr[0]);
	var endDateCompare = new Date(endDateArr[2], parseInt(endDateArr[1])-1, endDateArr[0]);
	
	if(startDateCompare <= endDateCompare) {
		isValid = true;
	}
	return isValid;
}
/*
 * 계획시작일자가 오늘이전인지 비교
 */
function checkInputDate(dateFrom, today) {
	var startDateArr = dateFrom.split('/');
	var toDayArr = today.split('/');
	var isValid = false;
	
	var startDateCompare = new Date(startDateArr[2], parseInt(startDateArr[1])-1, startDateArr[0]);
	var toDayCompare = new Date(toDayArr[2], parseInt(toDayArr[1])-1, toDayArr[0]);
	
	if(startDateCompare >= toDayCompare) {
		isValid = true;
	}
	return isValid;
}