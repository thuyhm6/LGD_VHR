/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVCOMMAILServiceImpl.java
 * @Desc    : LGVHR 메일 발송 공통
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 11. 08.    limsjin    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvcom.lgvcommail.service.serviceImpl;

import javax.annotation.Resource;

import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvcom.lgvcommail.service.LGVCOMMAILService;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvcom.lgvcommail.service.LGVCOMMAILServiceImpl.java
 * </PRE>
 *
 * @Author    limsjin
 * @Date	  2017. 11. 08. 오후 10:47:00
 * @Version
 */
@Service("LGVCOMMAILService")
public class LGVCOMMAILServiceImpl implements LGVCOMMAILService {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVCOMMAILServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
    @Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;
    
    /**
     * Desc : 메일 템플릿으로 메일 발송하도록 LGCOM_MAIL_INFO 테이블에 적재하는 처리를 한다.
     * @param param
     * @return
     */
    public LGCOMData insertSendMail(LGCOMData param) {
		LGCOMData result = new LGCOMData();
    	/*
    	 * 메일발송 시 필요한 파라메터
    	 * [IN PARAMETER]
		 * - sessionAppUserId : 생성자, 최종수정자 컬럼에 입력될 로그인 사용자의 lgcom_user_m.application_user_id
		 * - subsidiaryCode : 법인코드.
		 * - mailCode : 메일 템플릿 코드. code_type_code='LGVHR_MAIL_TEMPLATE_LIST'
		 * - receiptInfo : 수신자메일 : 사원번호 가능(1명만),  이메일 여러명 가능(콤마 구분)
		 * - languageCode : 언어코드. 디폴트 en
		 * - mailMappData : 템플릿에 등록된 메일 내용 및 제목을 치환할 JSON 데이터셋. 생략: 매핑데이타
		 * - senderInfo : 생략: 송신자메일: 생락시 디폴트(hrsys@lgdisplay.com), 사원번호 가능(1명만),  이메일 여러명 가능(콤마 구분)
		 * - ccInfo : 생략: 참조자메일
		 * [OUT PARAMETER]
		 * - retCode : 필수: 양수이면 성공(메일생성 Seq 리턴됨), 음수이면 에러
		 * - errorMessage : 필수: 양수이면 '', 음수이면 에러메시지
		 * [VALIDATION]
		 * - 데이터셋이 없는 경우 오류
		 * - 메일아이디가 없는 경우 오류
		 * - 수신자사번이 없는 경우 오류
		 * [PROCESS]
		 * - lgcom_mail_info 등록
    	 */
    	if ( NullUtil.isNull(param) ) {
			result.set( "errorCode", -1);
			result.set( "errorMessage", "param is null");
    	} else if ( NullUtil.isNone( param.getString("subsidiaryCode")) ) {
			result.set( "errorCode", "E");
			result.set( "errorMessage", "subsidiaryCode is null");
    	} else if ( NullUtil.isNone( param.getString("mailCode")) ) {
			result.set( "errorCode", "E");
			result.set( "errorMessage", "mailCode is null");
    	} else if ( NullUtil.isNone( param.getString("receiptInfo")) ) {
			result.set( "errorCode", "E");
			result.set( "receiptInfo", "receiptInfo is null");
    	} else {
    		LOGGER.debug("insertSendMailTemplate().param===>" + param);
    		//메일발송 테이블에 등록한 결과 조회
    		this.commonDao.select("LGVCOMMAIL.retrieveInsertSendMail", param);
    		if ( param.getInt("retCode") > -1 ) {
    			result.set ("errorCode", "S");
    		}
    		
    	}
    	return param;
    }
}
