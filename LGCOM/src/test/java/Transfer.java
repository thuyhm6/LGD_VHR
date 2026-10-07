import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Types;

public class Transfer {
	public static void main(String[] args) {
		Connection conn1 = null, conn2 = null;
		PreparedStatement pstmt1 = null, pstmt2 = null;
		
		String table = "SELECT a.business_group_id,a.subsidiary_name,a.person_id,a.employee_no,a.local_full_name,a.en_full_name,a.cn_full_name, "+
       " a.birth_yyyymmdd,a.solar_lunar_flag,a.martial_status_type_name,a.wedding_anniversary_date,a.email_addr, "+
       " a.retire_flag,a.organization_code,a.organization_name,a.organization_name_en,a.organization_level_code, "+
       " a.organization_level_name,a.job_title_code,a.job_title_name,a.position_code,a.position_name,a.location_name, "+
       " a.lg_hire_yyyymmdd,a.hire_yyyymmdd,a.absense_yyyymmdd,a.resignation_yyyymmdd,a.reinstatement_yyyymmdd, "+
       " a.office_phone_no,a.mobile_no,a.fax_no,a.grade_type_name,a.work_type_name,a.status_desc,a.last_update_date, "+
       " a.parent_organization_code,a.parent_organization_name,a.user_id,a.job_series_name,a.part_leader_flag, "+
       " a.person_location_name,a.org_location_name,a.super_employee_no,a.executive_flag,a.recent_org_update_yyyymmdd, "+
       " a.job_title_flag,a.real_part_leader_flag,a.detail_job1_desc,a.fse_flag,a.scheduled_resignation_yyyymmdd,a.job_start_yyyymmdd, "+
       " a.dangan_flag,a.dangan_location_code,a.dangan_start_date,a.hokou_code,a.email_use_flag,a.job_title_name_en,a.organization_id, "+
       " a.person_location_id,a.grade_id,a.kor_full_name,a.detail_job2_desc,a.job_family_name,a.job_name,a.job_id, "+
       " a.kor_fse_flag,a.work_type_code,a.create_date,a.grade_seniority,a.ko_language_use_flag,a.super1_person_id,a.super2_person_id, "+
       " a.person_type_name,a.ou_id "+
" FROM xxgifh.xxgifh_emp_info_m_p_if a where 1 = 1 and a.business_group_id = 83 and a.retire_flag <> 'T' ";
		
		String condition = "";
		//condition = "where rownum < 50 order by creation_date desc";
		
		try {
			Class.forName("oracle.jdbc.driver.OracleDriver");
		    conn1 = DriverManager.getConnection("jdbc:oracle:thin:@172.19.69.85:1571:DEV5", "apps", "anwkddo");
			conn2 = DriverManager.getConnection("jdbc:oracle:thin:@172.19.79.162:2521:LGDWCFD1", "lgcom", "mgr_wcf");
			conn2.setAutoCommit(false);

			String query1 = table ;
			pstmt1 = conn1.prepareCall(query1);

			ResultSet rs1 = pstmt1.executeQuery();
			ResultSetMetaData meta1 = rs1.getMetaData();

			String cols = "";
			String values = "";
			int count = meta1.getColumnCount();

			for (int inx = 1; inx <= count; inx++) {
				cols = cols + meta1.getColumnName(inx);
				values = values + " ?";

				if (inx < count) {
					cols = cols + ",";
					values = values + ",";
				}
			}

			String query2 = "INSERT INTO lgcom_ehr_r_employee ( " + cols + " ) values ( " + values + " )";

			System.out.println(query2);

			pstmt2 = conn2.prepareCall(query2);

			while (rs1.next()) {
				for (int inx = 1; inx <= count; inx++) {
					
					//System.out.println( inx + " : " + meta1.getColumnType(inx) );
					
					switch (meta1.getColumnType(inx)) {
					case Types.DATE:
						pstmt2.setDate(inx, rs1.getDate(inx));
						break;
					case Types.TIMESTAMP:
						pstmt2.setTimestamp( inx, rs1.getTimestamp(inx));
						break;
					case Types.NUMERIC :
						pstmt2.setLong(inx, rs1.getLong(inx));
						break;
					case Types.VARCHAR :
						pstmt2.setString(inx, rs1.getString(inx));
						break;
					default:
						pstmt2.setString(inx, rs1.getString(inx));
					}
				}

				pstmt2.addBatch();
			}
			pstmt2.executeBatch();

			conn2.commit();
		} catch (Exception e) {
			e.printStackTrace();
			if( conn2 != null )
				try { conn2.rollback(); } catch (SQLException e1) { e1.printStackTrace(); }
		} finally {
			try { pstmt1.close(); } catch (SQLException e1) { e1.printStackTrace(); }
			try { pstmt2.close(); } catch (SQLException e1) { e1.printStackTrace(); }
			try { conn1.close(); } catch (SQLException e1) { e1.printStackTrace(); }
			try { conn2.close(); } catch (SQLException e1) { e1.printStackTrace(); }
		}
	}
}
