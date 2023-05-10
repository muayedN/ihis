<%@page import="java.util.*,be.openclinic.finance.*,be.mxs.common.util.system.HTMLEntities"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<ul id="autocompletion">
<%
	String sPrestation = SH.p(request,"prestation");
	String sEncounterType = SH.p(request,"encountertype");
	Insurance insurance = Insurance.getDefaultInsuranceForPatient(activePatient.personid);
	List lResults = null;
	if(sPrestation.length()>0){
		int iMaxRows = MedwanQuery.getInstance().getConfigInt("MaxSearchFieldsRows",20);
		if(sPrestation.indexOf("--")>-1){
			sPrestation=sPrestation.substring(sPrestation.indexOf("--")+2);
		}
		sPrestation=sPrestation.split("--")[0].trim();
		lResults = Prestation.searchPrestations("", sPrestation, "", "");
        if(lResults.size() > 0){
            Iterator<Prestation> it = lResults.iterator();
            Prestation prestation;
            int lines=0;
            while(it.hasNext() && lines++<iMaxRows){
                prestation = it.next();
                out.write("<li>");
               	out.write(HTMLEntities.htmlentities("<b>"+prestation.getCode()+"<b> -- "+prestation.getDescription().toUpperCase().replace(sPrestation.toUpperCase(),"<font style='font-weight: bold;background-color: yellow'>"+sPrestation.toUpperCase()+"</font>"))+" -- "+SH.getPriceFormat(prestation.getPatientPrice(insurance,insurance.getInsuranceCategoryLetter(),sEncounterType))+" "+SH.cs("currency","EUR"));
                String servicename="";
                if(SH.c(prestation.getServiceUid()).length()>0){
	                Service service = Service.getService(prestation.getServiceUid());
	                if(service!=null){
	                	servicename=service.getLabel(sWebLanguage);
	                }
                }
               	out.write("<span style='display:none'>"+prestation.getUid()+";"+(insurance.getExtraInsurarUid().length()>0 && SH.p(request,"defaultExtraInsurar").equals("1")?"0":SH.getPriceFormat(prestation.getPatientPrice(insurance,insurance.getInsuranceCategoryLetter(),sEncounterType)))+"-idcache</span>");
                out.write("</li>");
            }
        }

	    boolean hasMoreResults = (lResults!=null && lResults.size() >= iMaxRows);
	    if(hasMoreResults){
	        out.write("<ul id='autocompletion'><li>...</li></ul>");
	    }
	}
%>