/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : DeleteExpiredAttachmentsJob.java
 * @Desc    : LGPRO 의 요청에 의해 작업하는 첨부파일 관리 작업자 
 *            
 *            1. 개인 정보를 담고있는 업무 정보의 삭제
 *            2. 관련된 첨부 파일의 삭제 대상을 별도의 테이블에 기록
 *            3. 이 기록을 바탕으로 1일 1회 (자정) 의 스케줄을 통해 첨부파일을 찾아서 삭제 처리
 *            4. 첨부파일 데이터도 모두 삭제 
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 12. 21. JHLEE         최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.common.scheduler;

import java.io.File;
import java.util.List;

import org.quartz.JobExecutionContext;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.common.scheduler.SampleJob.java
 * </PRE>
 *
 * @Author    SWA
 * @Date	   2016. 7. 1.
 * @Version   
 */
public class DeleteExpiredAttachmentsJob extends AbstractJob {

    private static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(DeleteExpiredAttachmentsJob.class);

    /** 
     * 
     * @param context
     * @see com.lgd.lgcom.common.scheduler.AbstractJob#exeucteJob(org.quartz.JobExecutionContext)
     */
    @Override
    protected void exeucteJob(JobExecutionContext context){
        LOGGER.debug("execute Job : DeleteExpiredAttachmentsJob Start");
        commonDao = (CommonDao)getBean("commonDao");
        String attachmentDir = LGCOMUtils.getValueFromProjectProperties("common_directory_" + System.getProperty("env") );
        LOGGER.debug("- Target Directiry : " + attachmentDir );
        
        List<LGCOMData> list = commonDao.selectList("concurrent.selectExpiredAttachments", new LGCOMData() );
        
        for( LGCOMData item : LGCOMUtils.emptyIfNull( list ) ) {
        	File target = new File( attachmentDir + item.getString("moduleCode") + "/" + item.getString("fileId") );
        	
        	if( target.delete() ) {
        		LOGGER.debug("- File " + target.getAbsolutePath() + " deleted successfully.");
        		commonDao.update("concurrent.deleteExpiredAttachments", item );
        	} else {
        		LOGGER.debug("- File " + target.getAbsolutePath() + " deletion fail.");
        	}
        }
        LOGGER.debug("execute Job : DeleteExpiredAttachmentsJob End");
    }
}
