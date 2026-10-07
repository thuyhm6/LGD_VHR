<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.io.*, java.util.Arrays"%>
<%@ page import="java.lang.reflect.Array"%>
<!DOCTYPE html>
<html> 
<head> 
<%
    String hostNm = java.net.InetAddress.getLocalHost().getHostName();

    String s_sel_loc        = request.getParameter("sel_loc") == null ? "" : request.getParameter("sel_loc");
    String s_sel_file       = request.getParameter("sel_file") == null ? "" : request.getParameter("sel_file");
    String s_sel_line       = request.getParameter("sel_line") == null ? "" : request.getParameter("sel_line");
    String s_currentTime    = "";
    
    String context = (String)request.getContextPath();
    
    String s_Options = "-";
    String vMsg = "";

    StringBuilder sb = new StringBuilder(); 

    //out.println("위치 : " + s_sel_loc + " <br/>");
    //out.println("파일 : " + s_sel_file + " <br/>");
    //out.println("라인 : " + s_sel_line + " <br/>");    

    if(s_sel_loc != null && !"".equals(s_sel_loc)) {
        
        File FileCollection = new File(s_sel_loc);      
        String[] FileNameList = FileCollection.list();      // 파일리스트
        
        if ( FileNameList == null ) {
            
            vMsg =  "파일이 없습니다.";
               
        } else {
            
            
            Arrays.sort(FileNameList);
            
            s_Options += "<option value=''>선택</option>";
            
            for(int i = 0; i < FileNameList.length; i ++){  
            
                if(!FileNameList[i].endsWith(".log")) {
                    continue;
                }
                            
                s_Options += "<option value='" + FileNameList[i] + "'>" + FileNameList[i] + "</option>";
            }
            
            if(s_sel_file != null && !"".equals(s_sel_file)){
                
                vMsg = s_sel_loc+"/"+s_sel_file;                

                String t_fileName = s_sel_loc + "/" + s_sel_file;
                File t_File = new File(t_fileName);
                
                if(t_File == null) {

                    out.print("선택하신 파일이 없습니다" + "<br/>");
                    
                } else {                  
                    try {
                        if("".equals(s_sel_line)) {
                            s_sel_line = "100";
                        }
                        
                        String s_Cmd = "tail -" + Integer.parseInt(s_sel_line) + " " + t_fileName;  
                        
                        Process p = Runtime.getRuntime().exec(s_Cmd);
                        BufferedReader input = new BufferedReader(new InputStreamReader(p.getInputStream()));
                        String line = null;
                        while((line = input.readLine())!=null){
                            sb.append(line + '\n');
                        }

                    } catch(IOException e) {
                        e.printStackTrace();
                    }                       
                }               
            }       
        }
    }
    
%>
<title>로그뷰어</title>
<script>
    function fn_sel_loc_change(){       
        fn_ok();
    }

    function fn_ok(){       
        form1.submit();     
    }

    function fn_sel_loc_click(){
        document.getElementById('sel_file').value = "";
    }
</script>

<style type="text/css">
    body {
        font-family:'맑은 고딕','Malgun Gothic','돋움',Dotum,sans-serif;
        font-size:12px;
        // font-weight:700; 
        background-color:#4ebfec;
        border:2px solid white;
        border-radius: 3px;
        
        //text-shadow:1px 1px 1px #0e1c30; 
    }
    .Select {
        width:97.5%;height:24px;
        margin-right:12px;
        text-align:left;
        font-size:12px;
        text-indent:1px;
        border:2px solid #c3edfa;
        border-radius: 3px;
        background-color:#9ad9f0;
        outline:none;
    }
    .btnEtc {
        width:130px;height:25px;
        font-size:12px;
        text-align:center;
        border:1px solid #3f5771;
        border-radius:3px;
        background-color:#808080;
        text-shadow:1px 1px 1px #0e1c30;
        cursor:pointer;
        color:#fff;
    }

/***** { FORM ELEMENTS-INIT } *****/
textarea {
	font:inherit;
}

</style>
</head>

<body>

<table class="table" border=0>

<tr height=20>
    <td>&nbsp;</td>
    <td><font  size=3> <b>  [ HOST : <%= hostNm %> ] </b> </font></td>
</tr>
</table>
    <form name="form1" method="post" action="logViewer.jsp">
        <table style="width:100%;height:98%;vertical-align:top; border:0px ">
          <tr> 
            <td style="vertical-align:top"> 
              <table border="3" style="width:100%;height:99%;vertical-align:top">              
                <tr>
                    <td width=120> 로그파일 위치선택 </td>
                    <td width=368>
                        <select class="Select" name="sel_loc" id="sel_loc" onclick="fn_sel_loc_click();" onchange="fn_sel_loc_change();"  >  >
                            <option value="" selected> - 선택 - </option>     
                            <option value="/logs001/juscom01/spring/logs">■ 온라인 LOG [ /LGCOM/workspace/LGCOM/logs ]</option>
                            <option value="/logs001/juscom01/spring/logs/debugging">■ 디버그 LOG [ /LGCOM/workspace/LGCOM/logs/debugging ]</option>
                            <option value="/logs001/juscom01/spring/logs">■ 스프링 LOG [ /logs001/juscom01/spring/logs ]</option>
                       </select>
                    </td>
                    <td width='10%'> 표시라인 선택 </td>
                    <td>
                        <select class="Select"  name="sel_line" id="sel_line"  style="width:80px" >
                            <option value="" selected>선택</option>                           
                            <option value="100">100</option>
                            <option value="1000">1000</option>
                            <option value="10000">10000</option>    
                            <option value="30000">30000</option>    
                            <option value="50000">50000</option>                        
                        </select>
                        
                        <button name="btnSearch" class="btnEtc" onclick="fn_ok();" >로그보기</button>
                    </td>
                </tr>
                <tr>
                </tr>
                <tr>
                    <td> 파일 선택</td>
                    <td colspan='3'>
                        <select class="Select"  name="sel_file" id="sel_file" style="width:360px">
                            <%= s_Options %>
                        </select>
                        

                        <font size=2><%=vMsg%></font>
                    </td>
                </tr>
                <tr> 
                    <td valign="top" colspan='4'>
                        <textarea name="txt_log" style="width:100%;height:750px" rows="44" cols="135"><%=sb.toString()%></textarea>                          
                    </td>
                </tr>
            </table>                
            </td>
          </tr>
        </table>
        <script>
            document.getElementById('sel_loc').value ="<%=s_sel_loc%>";
            document.getElementById('sel_file').value ="<%=s_sel_file%>";
            document.getElementById('sel_line').value ="<%=s_sel_line%>";        
        </script>
    </form>
</body>
</html>