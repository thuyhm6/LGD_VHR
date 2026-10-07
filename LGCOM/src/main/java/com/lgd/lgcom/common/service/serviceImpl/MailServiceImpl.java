/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : SampleServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2016. 8. 25.  	jhpark23  	최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.common.service.serviceImpl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.service.MailService;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;

import devonframe.mail.MailSender;
import devonframe.mail.MailSenderFactory;

/**
 * <PRE>
 * com.lgd.lgcom.common.service.serviceImpl.ApprovalServiceImpl.java
 * </PRE>
 *
 * @Author jhpark23
 * @Date 2016. 8. 25. 오전 11:56:51
 * @Version
 */
@Service("mailService")
public class MailServiceImpl implements MailService {
	private static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(MailServiceImpl.class);

	@Autowired
	private CommonDao commonDao;
	
	@Autowired 
	private MailSenderFactory mailSenderFactory;

	@Override
	public LGCOMData sendMailTest(LGCOMData param) {
		
		MailSender mailSender = mailSenderFactory.createMailSender();
		mailSender.setFromMailAddress("chachan@lgdpartner.com", "이종훈");
		mailSender.setToMailAddress("chachan@lgdpartner.com");
		mailSender.setSubject("테스트 메일을 보냅니다.");
		mailSender.setText("내용이 잘 갔나요? 궁금합니다.");
		mailSender.send();
		
		return null;
	}

}
