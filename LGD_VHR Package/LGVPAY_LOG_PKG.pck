CREATE OR REPLACE PACKAGE VHR_MGR.LGVPAY_LOG_PKG IS
PROCEDURE set_log_msg_payroll_result( p_payroll_calculation_exec_id    IN NUMBER,
                                      p_employee_no                    IN VARCHAR2,
                                      p_err_msg                        in VARCHAR2);

end LGVPAY_LOG_PKG;
/
CREATE OR REPLACE PACKAGE BODY VHR_MGR.LGVPAY_LOG_PKG is
PROCEDURE set_log_msg_payroll_result( p_payroll_calculation_exec_id    IN NUMBER,
                                      p_employee_no                    IN VARCHAR2,
                                      p_err_msg                        in VARCHAR2) IS
BEGIN
    INSERT INTO tb_pay_calc_emp_error_n
    (
	      error_log_id
        , payroll_calculation_exec_id	
        , employee_no
        , error_message_content
        , creation_user_id
        , creation_date            
    )
    SELECT sq_tb_pay_calc_emp_error_n.nextval
         , p_payroll_calculation_exec_id
         , p_employee_no
         , p_err_msg
         , '999'
         , SYSDATE
    FROM   dual 
    ;
    
    COMMIT;
END;                                          
end LGVPAY_LOG_PKG;
/
