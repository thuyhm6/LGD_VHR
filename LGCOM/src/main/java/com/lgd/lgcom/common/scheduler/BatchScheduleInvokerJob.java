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

import java.util.List;

import org.quartz.JobExecutionContext;
import org.springframework.cache.ehcache.EhCacheCacheManager;

import com.lgd.lgcom.common.service.BatchService;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;

import net.sf.ehcache.Ehcache;
import net.sf.ehcache.Element;

/**
 * <PRE>
 * com.lgd.lgcom.common.scheduler.SampleJob.java
 * </PRE>
 *
 * @Author    SWA
 * @Date	   2016. 7. 1.
 * @Version   
 */
public class BatchScheduleInvokerJob extends AbstractJob {
    private static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(BatchScheduleInvokerJob.class);

    /** 
     * 
     * @param context
     * @see com.lgd.lgcom.common.scheduler.AbstractJob#exeucteJob(org.quartz.JobExecutionContext)
     */
    @Override
    protected void exeucteJob(JobExecutionContext context){
		EhCacheCacheManager cacheManager = (EhCacheCacheManager)getBean("cacheManager");
		Ehcache cache = cacheManager.getCacheManager().getInstance().getCache(LGCOMConstants.BATCH_SCHEDULE_CACHE);
		List<String> keys = (List<String>)cache.getKeys();
		for( String key : LGCOMUtils.emptyIfNull( keys ) ) {
			LGCOMData schedule = (LGCOMData)cache.get(key).getObjectValue();
			
			if( schedule.getString("argumentText") == null ) {
				schedule.set("argumentText", "{}"); 
			}
			
			if( "Y".equals( schedule.getString("holdFlag") ) ) {
				continue;
			}
	        
			/**Batch 스케줄에 대한 분석 및 실행 여부 결정을 위한 코드 
			 * (용어)
			 * 주기적으로 배치 스케줄을 검토하는 자 : 트리거 ( Interval : 30 초 )
			 * 트리거에서 수행되는 자 : 작업
			 * 작업의 수행 계획 : 스케줄
			 * 스케줄에 지정된 실행계획( 1회/30분, 1회/1시간 등 )을 트리거 Interval 로 계산놓은 카운트 : 목표 카운트 
			 *    ex)  1회/1분 -> 목표카운트 2,  1회/1시간  -> 목표카운트 120 
			 * 트리거가 스케줄을 확인해서 작업 수행 시점이 됐는지 판단하기 위한 표지 : 실행카운트
			 * 
			 * 1. 트리거가 주기에 따라 스케줄을 확인하고, 이때마다 실행카운트를 +1 한다. 
			 * 2. 실행카운트와 목표카운트가 같으면 작업을 수행한다. 
			 * 3. 작업 수행이 시작되면 스케줄 캐시에 작업 수행 중 플래그( jobWorkingFlag )를 Y 로 설정한다.
			 * 4. runAloneFlag 이 'Y'이고 jobWorkingFlag 이  'Y' 이면 작업을 수행하지 않고 스킵한다. 
			 * 5. submitIntervalTypeCode 에 따른 작업 수행 방식
			 *    START : 작업이 수행될 때 수행 카운트를 0 으로 맞춘다. 
			 *    END : 작업이 수행될 때 수행카운트를 -999999999 로 맞추고, 완료될 때 0 으로 맞춘다. 
			 * **/
			boolean runnableFlag = false;
			
			// 규칙 1 : 트리거가 주기(30초)에 따라 스케줄을 확인하고, 이때마다 실행카운트를 +1 한다. 
			schedule.set( "runningCount", schedule.getLong("runningCount") + 1 );
			
			// 규칙 2 : 실행카운트와 목표카운트가 같으면 작업을 수행한다. 
			if( schedule.getLong("targetCount") <= schedule.getLong("runningCount") ) {
				runnableFlag = true;
				schedule.set( "runningCount", 0 );
			}
			
			// 규칙 3 : 작업 수행이 시작되면 스케줄 캐시에 작업 수행 중 플래그( jobWorkingFlag )를 Y 로 설정한다.
			// ==> BatchScheculeRunner Thread 에서 원격지 Batch 작업의 수행을 마치고, 정상수행 되면 변경하고 있다. 
			
			// 규칙 4 : runAloneFlag 이 'Y'이고 jobWorkingFlag 이  'Y' 이면 작업을 수행하지 않고 스킵한다. 
			if( "Y".equals( schedule.getString("jobWorkingFlag") ) && "Y".equals( schedule.getString("runAloneFlag") ) ) {
				runnableFlag = false;
			}
			
			// 규칙 5 : submitIntervalTypeCode 작업수행방식
			// ==> BatchScheculeRunner Thread 에서 원격지 Batch 작업의 수행을 마치고, 정상수행 되면 변경하고 있다. 
			
			if( runnableFlag ) {
	            Thread t = new Thread( new BatchScheculeRunner( schedule ));
	            t.start();
			}
			LOGGER.debug( schedule );
		}
    }
    
    class BatchScheculeRunner implements Runnable{
    	LGCOMData schedule;
    	
    	public BatchScheculeRunner( LGCOMData schedule ) {
    		this.schedule = schedule;
    	}

		public void run() {
			BatchService service = (BatchService) getBean("batchService");
			LGCOMData param = new LGCOMData();
			
			LGCOMData data = LGCOMData.parse(schedule.getString("argumentText"));
			data.set("requestUserId", schedule.getString("requestUserId"));
			data.set("programId", schedule.getString("programId"));
			data.set("batchId", schedule.getString("batchId"));
			data.set("scheduleFlag", "Y");
			data.set("submitIntervalTypeCode", schedule.getString("submitIntervalTypeCode") );
			param.set("data", data);
			LGCOMData result = service.executeBatch(param);
			
			if( result != null && "SUCCESS".equals( result.getString("status") ) ) {
				//원격 배치 수행 명령이 정상적으로 접수되면, Cache의 jobWorkingFlag 을 Y 로 변경한다.
				schedule.set("jobWorkingFlag","Y");
				if( "END".equals( schedule.getString("submitIntervalTypeCode") ) ) {
					schedule.set( "runningCount", -999999999 );
				} 
			}
		}
    }
}
