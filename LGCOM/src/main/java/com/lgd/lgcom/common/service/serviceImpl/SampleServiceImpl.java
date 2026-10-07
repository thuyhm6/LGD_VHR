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

import java.sql.SQLException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.service.SampleService;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import oracle.jdbc.OracleCallableStatement;
import oracle.jdbc.OracleConnection;
import oracle.jdbc.OracleTypes;
import oracle.sql.ARRAY;
import oracle.sql.ArrayDescriptor;
import oracle.sql.STRUCT;
import oracle.sql.StructDescriptor;


/**
 * <PRE>
 * com.lgd.lgcom.common.service.serviceImpl.SampleServiceImpl.java
 * </PRE>
 *
 * @Author    jhpark23
 * @Date	   2016. 8. 25. 오전 11:56:51
 * @Version   
 */
@Service("sampleService")
public class SampleServiceImpl implements SampleService {

    private static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(SampleServiceImpl.class);
    
    @Autowired
    private CommonDao commonDao;
    
    /** 
     * 
     * @param inParam
     * @throws SQLException
     * @see com.lgd.lgcom.common.service.SampleService#erpStdTest(java.lang.Object)
     */
    // Step1. sqlSession을 가져오기위해 Method name은 erpStd로 시작하도록 Method name 선언
    @Override
    public void erpStdTest(LGCOMData inParam) {

        // Step2. 프로시져를 수행할 callable statement 선언
        OracleCallableStatement procedure = null;
        
        try{
            // Step3. commonDao를 통해 Oracle Connection Get
            OracleConnection oraConn = commonDao.getOracleConnection();
            // Step4. 
            Object inTable[] = new Object[5];
            Object outTable[] = new Object[5];
            STRUCT structSampleIn;
           
            // Step5. type, table 객체 이름 선언 (대문자여야함)
            String struct = "lgcom_table_type_parameter".toUpperCase();
            String array = "lgcom_tab_param".toUpperCase();
            
            // Step6. type(struct), array(table) Descriptor 생성
            StructDescriptor sd = StructDescriptor.createDescriptor(struct, oraConn);
            ArrayDescriptor ad = ArrayDescriptor.createDescriptor(array , oraConn);
            LOGGER.debug("Struct Des :"+sd.descType());
            LOGGER.debug("Array Des :"+ad.descType());
            
            // Step7. 입력할 데이터 삽입
            for(int inx=0; inx < 5; inx++){
                Object[] params = new Object[4];
                params[0] = inx+"1";
                params[1] = 1+inx;
                params[2] = 2+inx;
                params[3] = 3+inx;
                
                structSampleIn = new STRUCT(sd, oraConn, params);
                inTable[inx] = structSampleIn;
            }
            
            // Step8. table 객체 생성
            ARRAY sampleIn = new ARRAY(ad, oraConn, inTable);
            
            // Step9. 프로시져 precall
            String procedureSql = "begin lgcom_test_pkg.insert_lgcom_test_01(?, ?); end;";
            procedure = (OracleCallableStatement) oraConn.prepareCall(procedureSql);

            // Step10. prepared statement parameter set
            procedure.setString(1, "01");
            procedure.setArray(2, sampleIn);
            // Step11. out parameter 등록
            procedure.registerOutParameter(2, OracleTypes.ARRAY, array);
            
            // Step12. 프로시져 excute
            procedure.execute();
            
            // Step13. out parameter에서 결과 get
            ARRAY sampleOut = (ARRAY) procedure.getArray(2);
            outTable = (Object[]) sampleOut.getOracleArray();
            
            LOGGER.debug("procedure execute!!!");
            LOGGER.debug("length : "+outTable.length);
            for(int inx=0; inx < outTable.length; inx++){
                STRUCT outStruct = (STRUCT) outTable[inx];
                Object outRecord[] = (Object[]) outStruct.getAttributes();
                for(int jnx=0; jnx < outRecord.length; jnx++){
                    LOGGER.debug(outRecord[jnx]);
                }
            }
            
        } catch(SQLException e) {
            throw new LGCOMException(e.getCause());
        } finally {
            // Step14. procedure close
            if (procedure != null){
                
                try {
                    procedure.close();
                } catch (Exception e) {
                    //none
                }               
            }
        }
    }
}
