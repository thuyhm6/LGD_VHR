<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang=“ko" lang="ko">
<head>
<title>Namo CrossEditor</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<meta http-equiv="X-UA-Compatible" content="IE=edge"/>
<meta name="robots" content="noindex, nofollow" />
<script type="text/javascript" src="./js/namo_scripteditor.js"></script>
</head>

<body style="width:100%;height:100%;margin:0px;padding:0px;">
<textarea id="namoEditor_${param.pgmId}" name="namoEditor_${param.pgmId}" style="width:100%;height:450px;"></textarea>
<script type="text/javascript">
	var crossEditor_${param.pgmId} = new NamoSE('namoEditor_${param.pgmId}');
	crossEditor_${param.pgmId}.params.Width = '100%';
	crossEditor_${param.pgmId}.params.Height = ${param.paramHeight};
	<c:choose>
		<c:when test="${param.lang eq 'en'}">
	crossEditor_${param.pgmId}.params.UserLang = 'enu';
		</c:when>
		<c:when test="${param.lang eq 'ko'}">
	crossEditor_${param.pgmId}.params.UserLang = 'kor';
		</c:when>
	</c:choose>
	crossEditor_${param.pgmId}.params.FullScreen = false;
	crossEditor_${param.pgmId}.params.UploadFileExecutePath = '/lgcom/upload/crosseditor?frameId=namoEditor_${param.pgmId}';
	crossEditor_${param.pgmId}.EditorStart();
	function OnInitCompleted(e) {
		//e.editorTarget.SetValue(document.getElementById('namoEditor_${param.pgmId}').value);
		crossEditor_${param.pgmId}.SetValue(document.getElementById('namoEditor_${param.pgmId}').value);
		if('${param.pgmId}' == 'LGUTLC00040' || '${param.pgmId}' == 'LGUTLC00050' || '${param.pgmId}' == 'LGUTLC00060') {
			document.getElementById('NamoSE_Ifr__namoEditor_${param.pgmId}').style.height = '${param.paramHeight}px';
			document.getElementById('NamoSE_Ifr__namoEditor_${param.pgmId}').contentWindow.document.getElementById('pe_aqJ_namoEditor_${param.pgmId}').style.height = '324px';
		}
	}
</script>
</body>
</html>