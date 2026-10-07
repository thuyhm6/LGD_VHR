/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVCOM00020ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER       DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *    1.0   2017. 11. 13.      LHJ      최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvcom.lgvcom00020.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvcom.lgvcom00020.service.LGVCOM00020Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvcom.lgvcom00020.service.serviceImpl.LGVCOM00020ServiceImpl.java
 * </PRE>
 *
 * @Author    LHJ
 * @Date      2017. 11. 13. 오전 09:32:58
 * @Version
 */
@Service("LGVCOM00020Service")
public class LGVCOM00020ServiceImpl implements LGVCOM00020Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVCOM00020ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
     * Desc : 나의 결재 승인 목록을 조회한다.
     * @Method Name : retrieveApprovalList
     * @param  param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveApprovalList(LGCOMData param){        
        String pStatus = param.getString("status");        
        String listName = "LGVCOM00020.retrieveApprovalPList";
        
        if( pStatus != null && !"".equals(pStatus) ){            
                
            if("P".equals(pStatus)){
                    
                listName = "LGVCOM00020.retrieveApprovalPList";
                    
            }else{
                
                listName = "LGVCOM00020.retrieveApprovalCList";
                    
            }           
            
        } else {
            
            listName = "LGVCOM00020.retrieveApprovalPList";
            
        }
        
        return this.commonDao.selectList(listName, param);
    }
    
}
