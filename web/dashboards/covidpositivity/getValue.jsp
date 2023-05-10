<%@include file="/includes/validateUser.jsp"%>
<%
	String sTimeUnit = SH.p(request,"timeunit");
	String title = getTranNoLink("web","covid.positivity",sWebLanguage);
	String period="";

	String dates="",values="";
	Connection conn = SH.getOpenClinicConnection();
	if(sTimeUnit.equalsIgnoreCase("day")){
		for(int n=0;n<30;n++){
			String sSql = "select count(distinct patientid) total from requestedlabanalyses where analysiscode=? and resultdate >=? and resultdate <? and resultvalue='positif'";
			PreparedStatement ps = conn.prepareStatement(sSql);
			ps.setString(1,SH.cs("covidlabcode","cov"));
			ps.setDate(2,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*(n+1)));
			ps.setTimestamp(3,new java.sql.Timestamp(new java.util.Date().getTime()-SH.getTimeDay()*n));
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				String sSql2 = "select count(distinct patientid) total from requestedlabanalyses where analysiscode=? and resultdate >=? and resultdate <? and length(resultvalue)>0";
				PreparedStatement ps2 = conn.prepareStatement(sSql2);
				ps2.setString(1,SH.cs("covidlabcode","cov"));
				ps2.setDate(2,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*(n+1)));
				ps2.setTimestamp(3,new java.sql.Timestamp(new java.util.Date().getTime()-SH.getTimeDay()*n));
				ResultSet rs2 = ps2.executeQuery();
				if(rs2.next()){
					if(rs2.getInt("total")>0){
						String date = new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date(new java.util.Date().getTime()-SH.getTimeDay()*n));
						if(dates.length()>0){
							dates+=",";
							values+=",";
						}
						dates+= "'"+date+"'";
						values+= rs.getDouble("total")*100/rs2.getDouble("total")+"";
					}
				}
				rs2.close();
				ps2.close();
			}
			rs.close();
			ps.close();
		}
		period =" 30 "+getTranNoLink("web","days",sWebLanguage);
	}
	else if(sTimeUnit.equalsIgnoreCase("month")){
		java.util.Date activeDate=SH.getEndOfMonth(new java.util.Date());
		for(int n=0;n<12;n++){
			String sSql = "select count(distinct patientid) total from requestedlabanalyses where analysiscode=? and resultdate >=? and resultdate <? and resultvalue='positif'";
			PreparedStatement ps = conn.prepareStatement(sSql);
			ps.setString(1,SH.cs("covidlabcode","cov"));
			ps.setDate(2,new java.sql.Date(SH.getBeginOfMonth(activeDate).getTime()));
			ps.setTimestamp(3,new java.sql.Timestamp(activeDate.getTime()));
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				String sSql2 = "select count(distinct patientid) total from requestedlabanalyses where analysiscode=? and resultdate >=? and resultdate <? and length(resultvalue)>0";
				PreparedStatement ps2 = conn.prepareStatement(sSql2);
				ps2.setString(1,SH.cs("covidlabcode","cov"));
				ps2.setDate(2,new java.sql.Date(SH.getBeginOfMonth(activeDate).getTime()));
				ps2.setTimestamp(3,new java.sql.Timestamp(activeDate.getTime()));
				ResultSet rs2 = ps2.executeQuery();
				if(rs2.next()){
					if(rs2.getInt("total")>0){
						String date = new SimpleDateFormat("yyyy-MM-01").format(activeDate);
						if(dates.length()>0){
							dates+=",";
							values+=",";
						}
						dates+= "'"+date+"'";
						values+= rs.getDouble("total")*100/rs2.getDouble("total")+"";
					}
				}
			}
			rs.close();
			ps.close();
			activeDate = SH.getPreviousMonthEnd(activeDate);
		}
		period =" 12 "+getTranNoLink("web","months",sWebLanguage);
	}
	conn.close();
%>
{
	data: {
		labels: [<%=dates %>],
		datasets: [
		{
			data: [<%=values %>],
			borderColor: 'red',
			label: '<%=title+period %>',
			borderWidth: 1,
			pointRadius: 1
		}
		]
	}
}