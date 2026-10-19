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
if ( typeof(fncArrangeMultiLine) == "undefined" ) {
	fncArrangeMultiLine = function( data, key ) {
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
}

/* 그리드에서 등록/수정된 행을 배열로 반환하는 함수 */
if ( typeof(fncArrangeMultiLineGrid) == "undefined" ) {
	fncArrangeMultiLineGrid = function( cgrid, rowStatus ) {
		var arr = [];
		var dataProvider = cgrid.getDataProvider();
		
		if ( isNull(rowStatus) ) {
			arr = fncArrangeMultiLineGridAll( cgrid );
		} else {
			//rowStatus : none,created,updated,deleted
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
}
/* 그리드 전체행을 배열로 반환하는 함수 */
if ( typeof(fncArrangeMultiLineGridAll) == "undefined" ) {
	fncArrangeMultiLineGridAll = function( cgrid ) {
		var arr = [];
		var dataProvider = cgrid.getDataProvider();
		for (var a = 0; a < dataProvider.getRowCount(); a++) {
			arr.push(dataProvider.getJsonRow(a));
		}
		return arr;
	}
}

/* 그리드에서 checkbox 선택된 행을 배열로 반환하는 함수 */
if ( typeof(fncArrangeMultiLineGridSelected) == "undefined" ) {
	fncArrangeMultiLineGridSelected = function( grid ) {
		var arr = [];
		var cgrid = grid.getGridBase();
		var provider = grid.getDataProvider();
		
		var checkeds = cgrid.getCheckedRows(false);//정렬된 순서로 index 가져오기
		for ( var i=0; i< checkeds.length; i++ ) {
			arr.push(provider.getJsonRow(checkeds[i]));
		}
		return arr;
	}
}

/* 그리드에서 checkbox 선택된 행의 특정 컬럼을 배열로 반환하는 함수 */
if ( typeof(fncArrangeFieldMultiLineGridSelected) == "undefined" ) {
	fncArrangeFieldMultiLineGridSelected = function( grid, fieldName ) {
		var arr = [];
		var cgrid = grid.getGridBase();
		var provider = grid.getDataProvider();
		
		if ( !isNull(fieldName) ) {
			var checkeds = cgrid.getCheckedRows(false);//정렬된 순서로 index 가져오기
			for ( var i=0; i< checkeds.length; i++ ) {
				arr.push(provider.getValue(checkeds[i], fieldName));
			}
		}
		return arr;
	}
}

/* mm/yyyy 포맷 체크 */
$.validator.addMethod( "monthYear", function(value, element) {
	// mm/yyyy
	var re = /(0[1-9]|10|11|12)\/2[0-9]{3}$/;
	// valid if optional and empty OR if it passes the regex test
	return (this.optional(element) && value=="") || re.test(value);
});

/* 날짜형식이 DD/MM/YYYY인지 체크 */
if ( typeof(fncValidateDateFormat) == "undefined" ) {
	fncValidateDateFormat = function(sDate) {
		var sRegExp = /^(0[0-9]|1[0-9]|2[0-9]|3[0-1])\/(0[0-9]|10|11|12)\/[1-4][0-9]{3}$/;
	
		//날짜 format 체크
		if ( !isNull(sDate) && !sRegExp.test(sDate) ) {
			return false;
		}
		return true;
	}
}
/* currency formatting */
if ( typeof(fncCurrencyFormat) == "undefined" ) {
	fncCurrencyFormat = function(val) {
		//숫자에서 콤마를 제거한다.
		val = Number( (val + "").replaceAll("," , "" ) );
		if ( isNaN(val) ) {
			return "";
		}
	    return val.toFixed(0).replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1,");
	}
}
/* decimal formatting */
if ( typeof(fncNumberFormat) == "undefined" ) {
	fncNumberFormat = function(val) {
		//숫자에서 콤마를 제거한다.
		val = Number( (val + "").replaceAll("," , "" ) );
		if ( isNaN(val) ) {
			return "";
		}
	    return val.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1,")
	}
}
