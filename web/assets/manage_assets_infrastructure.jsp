<%@page import="be.openclinic.assets.Asset,
               java.text.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../assets/includes/commonFunctions.jsp"%>
<%
	String sAction = checkString(request.getParameter("action"));
	String sEditAssetUID = checkString(request.getParameter("EditAssetUID"));
	String sEditServiceUid = checkString(request.getParameter("serviceuid"));
	boolean bNewAsset = false;
	boolean bLocked=false;
	Asset asset = null;
	if(sAction.equalsIgnoreCase("new")){
		asset = new Asset();
		asset.setUid("-1");
		if(MedwanQuery.getInstance().getConfigInt("GMAOLocalServerId",-1)>0){
			asset.setLockedBy(MedwanQuery.getInstance().getConfigInt("GMAOLocalServerId",-1));
			asset.setLockeddate(new java.util.Date());
		}
		else{
			asset.setLockedBy(-1);
		}
		asset.store(activeUser.userid);
		bNewAsset=true;
	}
	else if(sAction.equalsIgnoreCase("edit")){
		asset=Asset.get(sEditAssetUID);
		sEditServiceUid=asset.getServiceuid();
	}
	else if(sAction.equalsIgnoreCase("history")){
		asset=Asset.getHistory(sEditAssetUID,SH.parseDate(SH.p(request,"timestamp"), "yyyyMMddHHmmssSSS"));
		sEditServiceUid=asset.getServiceuid();
	}
	if(asset!=null){
		bLocked = asset.getObjectId()>-1 && ((asset.getLockedBy()>-1 && asset.getLockedBy()!=MedwanQuery.getInstance().getConfigInt("GMAOLocalServerId",-1)) || (asset.getLockedBy()==-1 && MedwanQuery.getInstance().getConfigInt("GMAOLocalServerId",-1)!=0));
	}
%>
<form name="EditForm" id="EditForm" method="POST">
	<input type='hidden' name='searchCode' id='searchCode' value=''/>
	<input type='hidden' name='action' id='action' value=''/>
	<input type='hidden' name='lockedby' id='lockedby' value='<%=asset.getLockedBy()%>'/>
    <input type="hidden" id="EditAssetUID" name="EditAssetUID" value="<%=asset.getUid()%>">
    <%=writeTableHeaderButton(getTran(request,"web","assets.infrastructure",sWebLanguage),!asset.hasHistory()?"":"<img title='"+getTranNoLink("web","history",sWebLanguage)+"' src='"+sCONTEXTPATH+"/_img/icons/icon_history2.gif' onclick='showHistory();'/>&nbsp;")%>
    
    <input type='hidden' id='comment2'/>
    <input type='hidden' id='comment3'/>
    <input type='hidden' id='comment4'/>
    <input type='hidden' id='comment5'/>
    <input type='hidden' id='comment10'/>
    <input type='hidden' id='comment16'/>
    <input type='hidden' id='assetType'/>
    <input type='hidden' id='quantity'/>
    <input type='hidden' id='serialnumber'/>
                
    <table class="list" border="0" width="100%" cellspacing="1">    
        <%-- CODE (*) --%>
        <tr>
            <td class="admin" width='15%')><%=getTran(request,"Web","service",sWebLanguage)%> *</td>
            <td class='admin2' colspan="3">
            	<table cellspacing="0">
            		<tr>
            			<td><b>
	                <%
	                	if(sEditServiceUid.length()>0){
	                		Service service = Service.getService(sEditServiceUid);
	                		if(service!=null){
		                		String[] names=service.getFullyQualifiedName(sWebLanguage,";").split(";");
		                		for(int n=0;n<names.length-1;n++){
		                			if(n>0){
		                				out.println(" - ");
		                			}
		                			out.println(names[n]);
		                		}
	                		}
	                	}
	                %>
	                	</b></td>
	                </tr>
	                <tr>
	                	<td nowrap>
			                <input type="hidden" name="serviceuid" id="serviceuid" value="<%=sEditServiceUid%>">
	                		<input onblur="if(document.getElementById('serviceuid').value.length==0){this.value='';}" class="text" type="text" name="servicename" id="servicename" size="50" value="<%=getTranNoLink("service",sEditServiceUid,sWebLanguage) %>" >
			                <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTran(null,"Web","select",sWebLanguage)%>" onclick="searchService('serviceuid','servicename');">
				            <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTran(null,"Web","delete",sWebLanguage)%>" onclick="document.getElementById('serviceuid').value='';document.getElementById('servicename').value='';document.getElementById('servicename').focus();">
							<div id="autocomplete_service" class="autocomple"></div>
						</td>
					</tr>			              
				</table>
            </td>
            <td class="admin" ><%=getTran(request,"web.assets","code",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="code" name="code" size="20" maxLength="20" value="<%=checkString(asset.getCode())%>">
            </td>
        </tr>
        <tr>
	        <%-- GMDNCODE --%>
            <td class="admin" ><%=getTran(request,"web","nomenclature",sWebLanguage)%> *</td>
            <td class="admin2" colspan="3">
          		<input onfocus='this.blur()' class="greytext" type="text" readonly size="15" name="FindNomenclatureCode" id="FindNomenclatureCode" value="<%=checkString(asset.getNomenclature())%>" onchange="checkDefaultMaintenancePlans();validateLabels()">&nbsp;
                <input onblur="if(document.getElementById('FindNomenclatureCode').value.length==0){this.value='';}" type="text" class="text" id="nomenclature" name="nomenclature" size="50" maxLength="80" value="<%=getTranNoLink("admin.nomenclature.asset",checkString(asset.getNomenclature()),sWebLanguage)%>">
                <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchNomenclature('FindNomenclatureCode','nomenclature');">
                <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="EditForm.FindNomenclatureCode.value='';EditForm.nomenclature.value='';">
				<div id="autocomplete_nomenclature" class="autocomple"></div>
            </td>
            <td class="admin" ><%=getTran(request,"web.assets","UID",sWebLanguage)%></td>
            <td class="admin2">
                <b><%=checkString(asset.getUid())%></b>
            </td>
		</tr>
		
        <%-- DESCRIPTION (*) --%>                    
        <tr>
            <td class="admin"><%=getTran(request,"web","description",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2" colspan="3">
                <textarea class="text" name="description" id="description" cols="60" rows="2" onKeyup="resizeTextarea(this,8);limitChars(this,245);"><%=checkString(asset.getDescription())%></textarea>
            </td>
            <td class="admin" ><%=getTran(request,"web.assets","surface",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" id="comment17" name="comment17" size="10" maxLength="30" value="<%=checkString(asset.getComment17())%>">
                <select name='comment19' id='comment19' class='text'>
                	<%=SH.writeSelect(request, "gmao.surfaceunit", SH.c(asset.getComment19(),SH.cs("gmaodefaultsurfaceunit","m2")), sWebLanguage) %>
                </select>&nbsp;
            </td>
        </tr>
        <tr>
	        <%-- ASSET STATUS (*) --%>
            <td class="admin">	        
            	<%=getTran(request,"web.assets","infrastructure.status",sWebLanguage)%>&nbsp;*&nbsp;
            </td>
            <td class="admin2" colspan='3'>
                <select class="text" id="comment9" name="comment9">
                    <option/>
                    <%=ScreenHelper.writeSelect(request,"assets.status",checkString(asset.getComment9()),sWebLanguage)%>
                </select>
                <input type='hidden' name='comment7' id='comment7'/>
            </td>
            <td class="admin"><%=getTran(request,"web","details",sWebLanguage)%></td>
            <td class="admin2">
                <textarea class="text" name="comment8" id="comment8" cols="30" rows="2" onKeyup="resizeTextarea(this,8);limitChars(this,245);"><%=checkString(asset.getComment8())%></textarea>
            </td>
        </tr>    
        
        <%-- CHARACTERISTICS --%>                
        <tr>
            <td class="admin"><%=getTran(request,"web.assets","characteristics",sWebLanguage)%>&nbsp;</td>
            <td class="admin2" colspan="3">
                <textarea class="text" name="characteristics" id="characteristics" cols="60" rows="2" onKeyup="resizeTextarea(this,8);"><%=checkString(asset.getCharacteristics().replaceAll("<br>", "\n"))%></textarea>
            </td>
            <td class="admin" id="serialnumber_label"><%=getTran(request,"gmao","cadasternumber",sWebLanguage)%>&nbsp;</td>
            <td class="admin2" colspan="2">
                <input type="text" class="text" id="serialnumber" name="serialnumber" size="20" maxLength="30" value="<%=checkString(asset.getSerialnumber())%>">
            </td>
        </tr>     
        <%-- COMPONENTS --%>
        <tr>
        	<td class='admin'>
        		<%=getTran(request,"web.assets","components",sWebLanguage) %>
				<%if(!bLocked && activeUser.getAccessRight("assets.edit")){ %>
	            	<img src='<%=sCONTEXTPATH %>/_img/icons/icon_add.gif' onclick="searchComponents('componentField')"/>
				<%} %>
        	</td> 
        	<td class='admin' colspan='5'>
        		<a href='javascript:showComponents(1)'><%=getTran(request,"web","show",sWebLanguage) %></a>&nbsp;
        		<a href='javascript:showComponents(0)'><%=getTran(request,"web","hide",sWebLanguage) %></a>
        	</td>
        </tr>
        <script>
        	function showComponents(value){
        		if(value==1){
        			document.getElementById("componentSection").style.display="";
        		}
        		else if(value==0){
        			document.getElementById("componentSection").style.display="none";
        		}
        	}
        	
        </script>
        <tr id='componentSection' style='display: none'>
        	<td colspan='6'>
        		<table width='100%'  style='border:1px solid black;'>
			        <tr>
			            <td class="admin">
			            </td>
			            <td class="admin2" nowrap colspan="5">
			            	<input type='hidden' name='componentField' id='componentField' value='' onchange='addComponent(this.value)'/>
			            	<script>
			            		function addComponent(value){
			            		    document.getElementById("componentsDiv").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Loading..";
			            		    
			            		    var url = "<c:url value='/assets/addComponent.jsp'/>?ts="+new Date().getTime();
			            		    new Ajax.Request(url,{
			            		      	method: "POST",
			            		      	parameters: "componentuid=<%=asset.getUid()%>."+value,
			            		      	onSuccess: function(resp){
				            		  		loadComponents('<%=asset.getUid()%>');
			            		    	},
				            		    onFailure: function(resp){
				            		        $("divMessage").innerHTML = "Error in 'assets/addComponent.jsp' : "+resp.responseText.trim();
				            		    }
			            		    });
			            		}
			            	</script>
			            	<input type='hidden' name='comment15' id='comment15' value='<%=asset.getComment15() %>'/>
			            	<div id='componentsDiv'></div>
			            </td>
			        </tr>   
			    </table>
			</td>
		</tr>     
        <%-- SUPPLIER --%>
        <tr>
            <td class="admin" id="supplier_label"><%=getTran(request,"web.assets","company",sWebLanguage)%>&nbsp;</td>
            <td class="admin2" nowrap>
                <input type="text" class="text" id="supplierUID" name="supplierUID" size="30" maxLength="50" value="<%=checkString(asset.getSupplierUid())%>">
            </td>
	        <%-- PURCHASE DATE --%>
            <td class="admin"><%=getTran(request,"web.assets","workstartdate",sWebLanguage)%>&nbsp;</td>
            <td class="admin2" nowrap>
                <%=writeDateField("purchaseDate","EditForm",ScreenHelper.formatDate(asset.getPurchaseDate()),sWebLanguage)%>        
            </td>                        
	        <%-- PURCHASE PRICE (+currency) --%>
            <td class="admin"><%=getTran(request,"web.assets","receiptBy",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="receiptBy" name="receiptBy" size="30" maxLength="50" value="<%=checkString(asset.getReceiptBy())%>">
            </td>
        </tr>        
        
        <tr>
            <td class="admin"><%=getTran(request,"web.assets","infrastructure.productiodate",sWebLanguage)%>&nbsp;</td>
            <td class="admin2" nowrap>
                <%=writeDateField("comment11","EditForm",checkString(asset.getComment11()),sWebLanguage)%>        
            </td>                        
            <td class="admin"><%=getTran(request,"web.assets","infrastructure.deliverydate",sWebLanguage)%>&nbsp;*</td>
            <td class="admin2" nowrap>
                <%=writeDateField("comment12","EditForm",checkString(asset.getComment12()),sWebLanguage)%>        
            </td>                        
            <td class="admin"><%=getTran(request,"web.assets","firstusagedate",sWebLanguage)%>&nbsp;</td>
            <td class="admin2" nowrap>
                <%=writeDateField("comment13","EditForm",checkString(asset.getComment13()),sWebLanguage)%>        
            </td>                        
        </tr>        
        
        <%-- RECEIPT BY --%>
        <tr>
            <td class="admin"><%=getTran(request,"web.assets","workcost",sWebLanguage)%>&nbsp;*</td>
            <td class="admin2">
                <input type="text" class="text" id="purchasePrice" name="purchasePrice" size="15" maxLength="15" value="<%=asset.getPurchasePrice() %>" onKeyUp="isNumber(this);" onBlur="if(isNumber(this))setDecimalLength(this,2,true);">
                <select name='comment18' id='comment18' class='text'>
                	<%=SH.writeSelect(request, "gmao.currency", SH.c(asset.getComment18(),SH.cs("gmaodefaultcurrency","�bif")), sWebLanguage) %>
                </select>&nbsp;
            </td>
            <td class="admin"><%=getTran(request,"web.assets","fundingsource",sWebLanguage)%>&nbsp;*</td>
            <td class="admin2">
                <input type="text" class="text" id="comment6" name="comment6" size="20" maxLength="255" value="<%=asset.getComment6() %>" />
            </td>
            <td class="admin"><%=getTran(request,"web.assets","endofwarantydate",sWebLanguage)%>&nbsp;</td>
            <td class="admin2" nowrap>
                <%=writeDateField("comment14","EditForm",checkString(asset.getComment14()),sWebLanguage)%>        
            </td>                        
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web.assets","outofservicedate",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <%=writeDateField("saleDate","EditForm",SH.formatDate(asset.getSaleDate()),sWebLanguage)%>
            </td>
            <td class="admin"><%=getTran(request,"web.assets","lastworkstype",sWebLanguage)%>&nbsp;</td>
            <td class="admin2" colspan='3'>
            	<select class='text' name='comment1' id='comment1'>
            		<option/>
            		<%=SH.writeSelect(request, "asset.workstype", asset.getComment1(), sWebLanguage) %>
            	</select>
            </td>
        </tr>
        <input type='hidden' name='saleValue' id='saleValue'/>
        <input type='hidden' name='saleClient' id='saleClient'/>
      
        <tr>
	        <%-- DOCUMENTS (multi-add) --%>   
            <td class="admin" nowrap>
            	<%=getTran(request,"web.assets","documents",sWebLanguage)%>&nbsp;
				<%if(!bLocked && activeUser.getAccessRight("assets.edit")){ %>
	            	<img src='<%=sCONTEXTPATH %>/_img/icons/icon_add.gif' onclick="addDocument('<%=asset.getUid()%>')"/>
	            <%} %>
            </td>
        	<td class='admin' colspan='5'>
        		<a href='javascript:showDocuments(1)'><%=getTran(request,"web","show",sWebLanguage) %></a>&nbsp;
        		<a href='javascript:showDocuments(0)'><%=getTran(request,"web","hide",sWebLanguage) %></a>
        	</td>
        </tr>        
        <script>
        	function showDocuments(value){
        		if(value==1){
        			document.getElementById("documentSection").style.display="";
        		}
        		else if(value==0){
        			document.getElementById("documentSection").style.display="none";
        		}
        	}
        </script>
        <tr id='documentSection' style='display: <%=SH.ci("enableAssetOpenDocuments",0)==1?"":"none"%>'>
        	<td colspan='6'>
        		<table width='100%'  style='border:1px solid black;'>
			        <tr>
			            <td class="admin">
			            	<div id='documentsLoaderDiv'></div><div id='documentsDiv'></div>
			            </td>
			        </tr>   
			    </table>
			</td>
		</tr>     	        
        
        <tr>
        	<td class='admin'>
        		<%=getTran(request,"web","accounting",sWebLanguage) %>
        	</td> 
        	<td class='admin' colspan='5'>
        		<a href='javascript:showFinance(1)'><%=getTran(request,"web","show",sWebLanguage) %></a>&nbsp;
        		<a href='javascript:showFinance(0)'><%=getTran(request,"web","hide",sWebLanguage) %></a>
        	</td>
        </tr>
        <script>
        	function showFinance(value){
        		if(value==1){
        			document.getElementById("financialSection").style.display="";
        		}
        		else if(value==0){
        			document.getElementById("financialSection").style.display="none";
        		}
        	}
        	
        </script>
        <tr id='financialSection' style='display: none'>
        	<td colspan='6'>
        		<table width='100%'  style='border:2px solid black;'>
			        <%-- WRITE OFF METHOD --%>
			        <tr>
			            <td class="admin"  width='15%'><%=getTran(request,"web.assets","writeOffMethod",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <select class="text" id="writeOffMethod" name="writeOffMethod">
			                    <option/>
			                    <%=ScreenHelper.writeSelect(request,"assets.writeOffMethod",checkString(asset.getWriteOffMethod()),sWebLanguage)%>
			                </select>
			            </td>
				        <%-- WRITE OFF PERIOD --%>
			            <td class="admin"><%=getTran(request,"web.assets","writeOffPeriod",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <input type="text" class="text" id="writeOffPeriod" name="writeOffPeriod" size="2" maxLength="2" value="<%=asset.getWriteOffPeriod() %>" onKeyUp="isNumber(this);">&nbsp;<%=getTran(request,"web","years",sWebLanguage).toLowerCase()%>&nbsp;
			            </td>
				        <%-- ANNUITIY --%>
			            <td class="admin"><%=getTran(request,"web.assets","annuity",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <select class="text" id="annuity" name="annuity">
			                    <option/>
			                    <%=ScreenHelper.writeSelect(request,"assets.annuity",checkString(asset.getAnnuity()),sWebLanguage)%>
			                </select>
			            </td>
			        </tr>        
			        
			        <%-- GAINS (multi-add: date, value (+currency)) --%>
			        <tr>
			            <td class="admin" nowrap><%=getTran(request,"web.assets","gains",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" style="padding:5px;" colspan="5">
			                <input type="hidden" id="gains" name="gains" value="">
			                                     
			                <table width="100%" class="sortable" id="tblGA" cellspacing="1" headerRowCount="2"> 
			                    <%-- header --%>                        
			                    <tr class="admin">
			                        <%-- 0 - empty --%>
			                        <td  nowrap/>
			                        <%-- 1 - date --%>
			                        <td  nowrap style="padding-left:0px;">
			                            <%=getTran(request,"web.assets","date",sWebLanguage)%>&nbsp;*&nbsp;
			                        </td>    
			                        <%-- 2 - value --%>
			                        <td  nowrap style="padding-left:0px;">
			                            <%=getTran(request,"web.assets","value",sWebLanguage)%>&nbsp;*&nbsp;
			                        </td>    
			                        <%-- 3 - empty --%>
			                        <td nowrap>&nbsp;</td>      
			                    </tr>
			        
			                    <%-- content by ajax and javascript --%>
			                    
			                    <%-- add-row --%>                          
			                    <tr>
			                        <%-- 0 - empty --%>
			                        <td class="admin"/>
			                        <%-- 1 - gaDate --%>
			                        <td class="admin" nowrap> 
			                            <%=writeDateField("gaDate","EditForm","",sWebLanguage)%>&nbsp; 
			                        </td>
			                        <%-- 2 - gaValue --%>
			                        <td class="admin"> 
			                            <input type="text" class="text" id="gaValue" name="gaValue" size="8" maxLength="8" onKeyUp="isNumber(this);" onBlur="if(isNumber(this))setDecimalLength(this,2,true);" value="">&nbsp;<%=MedwanQuery.getInstance().getConfigParam("currency","�")%>&nbsp;
			                        </td>
			                        <%-- 3 - buttons --%>
			                        <td class="admin" nowrap>
			                            <input type="button" class="button" name="ButtonAddGA" id="ButtonAddGA" value="<%=getTranNoLink("web","add",sWebLanguage)%>" onclick="addGA();">
			                            <input type="button" class="button" name="ButtonUpdateGA" id="ButtonUpdateGA" value="<%=getTranNoLink("web","edit",sWebLanguage)%>" onclick="updateGA();" disabled>&nbsp;
			                        </td>    
			                    </tr>
			                </table>                    
			            </td>
			        </tr>
			        <tr>
				        <%-- LOSSES (multi-add: date, value (+currency)) --%>  
			            <td class="admin" nowrap><%=getTran(request,"web.assets","losses",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" style="padding:5px;" colspan="5">
			                <input type="hidden" id="losses" name="losses" value="">
			                                     
			                <table width="100%" class="sortable" id="tblLO" cellspacing="1" headerRowCount="2"> 
			                    <%-- header --%>                        
			                    <tr class="admin">
			                        <%-- 0 - empty --%>
			                        <td nowrap/>
			                        <%-- 1 - date --%>
			                        <td nowrap style="padding-left:0px;">
			                            <%=getTran(request,"web.assets","date",sWebLanguage)%>&nbsp;*&nbsp;
			                        </td>    
			                        <%-- 2 - value --%>
			                        <td nowrap style="padding-left:0px;">
			                            <%=getTran(request,"web.assets","value",sWebLanguage)%>&nbsp;*&nbsp;
			                        </td>    
			                        <%-- 3 - empty --%>
			                        <td  nowrap>&nbsp;</td>      
			                    </tr>
			        
			                    <%-- content by ajax and javascript --%>
			                    
			                    <%-- add-row --%>                          
			                    <tr>
			                        <%-- 0 - empty --%>
			                        <td class="admin"/>
			                        <%-- 1 - loDate --%>
			                        <td class="admin" nowrap> 
			                            <%=writeDateField("loDate","EditForm","",sWebLanguage)%>&nbsp; 
			                        </td>   
			                        <%-- 2 - loValue --%>
			                        <td class="admin"> 
			                            <input type="text" class="text" id="loValue" name="loValue" size="8" maxLength="8" onKeyUp="isNumber(this)" onBlur="if(isNumber(this))setDecimalLength(this,2,true);" value="">&nbsp;<%=MedwanQuery.getInstance().getConfigParam("currency","�")%>&nbsp;
			                        </td>
			                        <%-- 3 - buttons --%>
			                        <td class="admin" nowrap>
			                            <input type="button" class="button" name="ButtonAddLO" id="ButtonAddLO" value="<%=getTranNoLink("web","add",sWebLanguage)%>" onclick="addLO();">
			                            <input type="button" class="button" name="ButtonUpdateLO" id="ButtonUpdateLO" value="<%=getTranNoLink("web","edit",sWebLanguage)%>" onclick="updateLO();" disabled>&nbsp;
			                        </td>    
			                    </tr>
			                </table>                    
			            </td>
			        </tr>        
			
			        <%-- RESIDUAL VALUE HISTORY (calculated) --%>
			        <tr id="residualValueHistoryDiv" style="visibility:visible;">
			            <td class="admin" nowrap><%=getTran(request,"web.assets","residualValueHistory",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" colspan="5">
			                <div id="residualValueHistory" class="admin">
			                    <%-- javascript --%>
			                </div>
			            </td>
			        </tr>     
			                    
			        <%-- LOAN (own table) -------------------------------------------------------------------%>
			        
			        <tr>
			            <td class="admin" nowrap><%=getTran(request,"web.assets","loan",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" style="padding:5px;" colspan="5">
			                <table class="list" cellspacing="1" cellpadding="0" width="100%">
			                
			            <%-- subtitle : loan --%>
			            <tr class="admin">
			                <td colspan="2"><%=getTran(request,"web.assets","loan",sWebLanguage)%></td>        
			            </tr>
			        
			            <%-- LOAN DATE --%>
			            <tr>
			                <td class="admin" nowrap><%=getTran(request,"web.assets","loanDate",sWebLanguage)%>&nbsp;</td>
			                <td class="admin2">
			                    <%=writeDateField("loanDate","EditForm",ScreenHelper.formatDate(asset.getLoanDate()),sWebLanguage)%>            
			                </td>                        
			            </tr>
			            
			            <%-- LOAN AMOUNT --%>
			            <tr>
			                <td class="admin" nowrap><%=getTran(request,"web.assets","loanAmount",sWebLanguage)%>&nbsp;</td>
			                <td class="admin2">
			                    <input type="text" class="text" id="loanAmount" name="loanAmount" size="8" maxLength="8" value="<%=asset.getLoanAmount() %>" onKeyUp="isNumber(this);">&nbsp;<%=MedwanQuery.getInstance().getConfigParam("currency","�")%>&nbsp;
			                </td>
			            </tr>
			                
			            <%-- LOAN INTEREST RATE (text!) --%>
			            <tr>
			                <td class="admin" nowrap><%=getTran(request,"web.assets","loadInterestRate",sWebLanguage)%>&nbsp;</td>
			                <td class="admin2">
			                    <input type="text" class="text" id="loanInterestRate" name="loanInterestRate" size="30" maxLength="30" value="<%=checkString(asset.getLoanInterestRate())%>">
			                </td>
			            </tr>     
			            
			            <%-- LOAN REIMBURSEMENT PLAN (multi-add: date, capital, interest, total (calculated)) --%>  
			            <tr>
			                <td class="admin" nowrap><%=getTran(request,"web.assets","loadReimbursementPlan",sWebLanguage)%>&nbsp;</td>
			                <td class="admin2" style="padding:5px;">
			                    <input type="hidden" id="loanReimbursementPlan" name="loanReimbursementPlan" value="">
			                                         
			                    <table width="100%" class="sortable" id="tblRP" cellspacing="1" headerRowCount="2" bottomRowCount="1"> 
			                        <%-- header --%>                        
			                        <tr class="admin">
			                            <%-- 0 - empty --%>
			                            <td nowrap/>
			                            <%-- 1 - date --%>
			                            <td nowrap style="padding-left:0px;">
			                                <%=getTran(request,"web.assets","date",sWebLanguage)%>&nbsp;*&nbsp;
			                            </td>
			                            <%-- 2 - capital (+currency) --%>
			                            <td nowrap style="padding-left:0px;">
			                                <%=getTran(request,"web.assets","capital",sWebLanguage)%>&nbsp;*&nbsp;
			                            </td>
			                            <%-- 3 - interest (+currency) --%>
			                            <td nowrap style="padding-left:0px;">
			                                <%=getTran(request,"web.assets","interest",sWebLanguage)%>&nbsp;*&nbsp;
			                            </td>    
			                            <%-- 4 - total --%>
			                            <td nowrap style="padding-left:0px;">
			                                <%=getTran(request,"web.assets","total",sWebLanguage)%>&nbsp;
			                            </td>   
			                            <%-- 5 - empty --%>
			                            <td nowrap>&nbsp;</td>      
			                        </tr>
			            
			                        <%-- content by ajax and javascript --%>
			                        
			                        <%-- add-row --%>                          
			                        <tr>
			                            <%-- 0 - empty --%>
			                            <td class="admin"/>
			                            <%-- 1 - rpDate --%>
			                            <td class="admin" nowrap> 
			                                <%=writeDateField("rpDate","EditForm","",sWebLanguage)%>&nbsp; 
			                            </td>
			                            <%-- 2 - rpCapital --%>
			                            <td class="admin">
			                                <input type="text" class="text" id="rpCapital" name="rpCapital" size="8" maxLength="8" onKeyUp="calculateRPTotal(this,false);" onBlur="calculateRPTotal(this,true);" value="">&nbsp;<%=MedwanQuery.getInstance().getConfigParam("currency","�")%>&nbsp;
			                            </td>    
			                            <%-- 3 - rpInterest --%>
			                            <td class="admin">  
			                                <input type="text" class="text" id="rpInterest" name="rpInterest" size="8" maxLength="8" onKeyUp="calculateRPTotal(this,false);" onBlur="calculateRPTotal(this,true);" value="">&nbsp;<%=MedwanQuery.getInstance().getConfigParam("currency","�")%>&nbsp;
			                            </td>  
			                            <%-- 4 - rpTotal (calculated) --%>
			                            <td style="background-color:#ccc;font-weight:bold;color:#505050;">
			                                <span id="rpTotal" style="searchResults" style="color:#505050;padding:3px;width:50px;height:18px;border:1px solid #ccc;background:#f0f0f0;"><%-- javascript --%></span>&nbsp;<span style="vertical-align:3px"><%=MedwanQuery.getInstance().getConfigParam("currency","�")%></span>&nbsp;
			                            </td>   
			                            <%-- 5 - buttons --%>
			                            <td class="admin" nowrap>
			                                <input type="button" class="button" name="ButtonAddRP" id="ButtonAddRP" value="<%=getTranNoLink("web","add",sWebLanguage)%>" onclick="addRP();">
			                                <input type="button" class="button" name="ButtonUpdateRP" id="ButtonUpdateRP" value="<%=getTranNoLink("web","edit",sWebLanguage)%>" onclick="updateRP();" disabled>&nbsp;
			                            </td>    
			                        </tr>
			                    </table>                    
			                </td>
			            </tr>        
			                        
			            <%-- LOAN COMMENT --%>                
			            <tr>
			                <td class="admin" nowrap><%=getTran(request,"web.assets","comment",sWebLanguage)%>&nbsp;</td>
			                <td class="admin2">
			                    <textarea class="text" name="loanComment" id="loanComment" cols="40" rows="2" onKeyup="resizeTextarea(this,8);"><%=checkString(asset.getLoanComment()) %></textarea>
			                </td>
			            </tr>
			            
			            <%-- LOAN DOCUMENTS (multi-add) --%>
			            <tr>
			                <td class="admin" nowrap><%=getTran(request,"web.assets","loanDocuments",sWebLanguage)%>&nbsp;</td>
			                <td class="admin2" style="padding:5px;padding-bottom:0;">
			                    <input type="hidden" id="loanDocuments" name="loanDocuments" value="">
			                              
			                    <span id="ldScroller" style="overflow:none;width:270px;height:50px;border:none;">           
			                        <table width="100%" class="sortable" id="tblLD" cellspacing="1" headerRowCount="2"> 
			                            <%-- header --%>                        
			                            <tr class="admin">
			                                <%-- 0 - empty --%>
			                                <td nowrap/>
			                                <%-- 1 - documentId --%>
			                                <td  nowrap style="padding-left:0px;">
			                                    <%=getTran(request,"web.assets","documentId",sWebLanguage)%>&nbsp;*&nbsp;
			                                </td>    
			                                <%-- 2 - empty --%>
			                                <td nowrap>&nbsp;</td>      
			                            </tr>
			                            
			                            <%-- add-row --%>                          
			                            <tr>
			                                <%-- 0 - empty --%>
			                                <td class="admin"/>
			                                <%-- 1 - documentId --%>
			                                <td class="admin"> 
			                                    <input type="text" class="text" id="ldID" name="ldID" size="15" maxLength="12" value="" onKeyDown="if(enterEvent(event,13)){if(isValidDocumentId(document.getElementById('ldID')))addLD();}">&nbsp;
			                                </td>
			                                <%-- 2 - buttons --%>
			                                <td class="admin" nowrap>
			                                    <input type="button" class="button" name="ButtonAddLD" id="ButtonAddLD" value="<%=getTranNoLink("web","add",sWebLanguage)%>" onclick="if(isValidDocumentId(document.getElementById('ldID')))addLD();">
			                                    <input type="button" class="button" name="ButtonUpdateLD" id="ButtonUpdateLD" value="<%=getTranNoLink("web","edit",sWebLanguage)%>" onclick="updateLD();" disabled>&nbsp;
			                                </td>    
			                            </tr>
			                
			                            <%-- content by ajax and javascript --%>
			                        </table>
			                    
			                        <div id="loanDocumentMsgDiv" style="padding-top:10px;"></div>      
			                    </span>              
			                </td>
			            </tr>        
			        
			                </table>
			            </td>
			        </tr>
			    </table>
			</td>
		</tr>
        <tr>
            <td class="admin" nowrap>
            	<%=getTran(request,"web","lastmodificationby",sWebLanguage)%>&nbsp;
            </td>
            <td class="admin2" colspan="5">
            	<b><%=User.getFullUserName(asset.getUpdateUser()) %> (<%=ScreenHelper.formatDate(asset.getUpdateDateTime(), ScreenHelper.fullDateFormat) %>)</b>
				<%if(bLocked && asset.getLockedBy()>0){ %>
				&nbsp;[<%=getTran(request,"web","lockedby",sWebLanguage) %>: <%=asset.getLockedBy()%>]
				<%} %>
            </td>
        </tr>        
                            
        <%-- BUTTONS --%>
        <tr>     
            <td class="admin"/>
            <td class="admin2" colspan="7">
            	<%if(!sAction.equalsIgnoreCase("history") && !SH.p(request,"readonly").equalsIgnoreCase("true")){ %>
				<%if(!bLocked && activeUser.getAccessRight("assets.edit")){ %>
                <input class="button" type="button" name="buttonSave" id="buttonSave" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="saveAsset();">&nbsp;
				<%} %>
				<%if(!bLocked && activeUser.getAccessRight("assets.delete")){ %>
                <input class="button" type="button" name="buttonDelete" id="buttonDelete" value="<%=getTranNoLink("web","delete",sWebLanguage)%>" onclick="deleteAsset();" >&nbsp;
				<%} %>
                <input class="button" type="button" name="buttonList" id="buttonList" value="<%=getTranNoLink("web","list",sWebLanguage)%>" onclick="listAssets('infrastructure');">&nbsp;
                <input class="button" type="button" name="buttonMaintenance" id="buttonMaintenance" value="<%=getTranNoLink("web","maintenanceplans",sWebLanguage)%>" onclick="listMaintenancePlans();">&nbsp;
                <input class="button" type="button" name="buttonOperations" id="buttonOperations" value="<%=getTranNoLink("web","operations",sWebLanguage)%>" onclick="listMaintenanceOperations();">&nbsp;
                <input class="button" type="button" name="buttonDocuments" id="buttonDocuments" value="<%=getTranNoLink("web","documents",sWebLanguage)%>" onclick="printWordDocuments();">&nbsp;
				<%
					if(activeUser.getAccessRight("assets.defaultassets.add")){
				%>
                <input class="button" type="button" name="buttonAddDefault" id="buttonAddDefault" value="<%=getTranNoLink("web","adddefaultinfrastructure",sWebLanguage)%>" onclick="addDefault();">&nbsp;
				<%
					}
					if(activeUser.getAccessRight("assets.defaultassets.select")){
				%>
                <input class="button" type="button" name="buttonViewDefault" id="buttonViewDefault" value="<%=getTranNoLink("web","loaddefaultinfrastructure",sWebLanguage)%>" onclick="viewDefault();">&nbsp;
				<%
					}
            	}
				%>
            </td>
        </tr>
    </table>
    <i><%=getTran(request,"web","colored_fields_are_obligate",sWebLanguage)%></i>
    
    <%if(sAction.equalsIgnoreCase("history")|| SH.p(request,"readonly").equalsIgnoreCase("true")){%>
    	<center><input class="button" type="button" name="buttonClose" id="buttonClose" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onclick="window.close();"></center>
	<%}%>
    
    <div id="divMessage" style="padding-top:10px;"></div>
</form>
<script>
new Ajax.Autocompleter('nomenclature','autocomplete_nomenclature','assets/findNomenclature.jsp',{
	  minChars:1,
	  method:'post',
	  afterUpdateElement: afterAutoCompleteNomenclature,
	  callback: composeCallbackURLNomenclature
	});

	function afterAutoCompleteNomenclature(field,item){
	  var regex = new RegExp('[-0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.]*-idcache','i');
	  var nomimage = regex.exec(item.innerHTML);
	  var id = nomimage[0].replace('-idcache','');
	  document.getElementById("FindNomenclatureCode").value = id;
	  document.getElementById("nomenclature").value=item.innerHTML.split("$")[1];
	}
	
	function composeCallbackURLNomenclature(field,item){
	  document.getElementById('FindNomenclatureCode').value='';
	  var url = "";
	  if(field.id=="nomenclature"){
		url = "code=<%=SH.c(request.getParameter("assetType")).equalsIgnoreCase("infrastructure")?"I":SH.c(request.getParameter("assetType")).equalsIgnoreCase("equipment")?"E":""%>&text="+field.value;
	  }
	  return url;
	}

	new Ajax.Autocompleter('servicename','autocomplete_service','assets/findService.jsp',{
	  minChars:1,
	  method:'post',
	  afterUpdateElement: afterAutoCompleteService,
	  callback: composeCallbackURLService
	});

	function afterAutoCompleteService(field,item){
	  var regex = new RegExp('[-0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.]*-idcache','i');
	  var nomimage = regex.exec(item.innerHTML);
	  var id = nomimage[0].replace('-idcache','');
	  document.getElementById("serviceuid").value = id;
	  document.getElementById("servicename").value=item.innerHTML.split("$")[1];
	}
	
	function composeCallbackURLService(field,item){
	  document.getElementById('serviceuid').value
	  var url = "";
	  if(field.id=="servicename"){
		url = "text="+field.value;
	  }
	  return url;
	}
</script>

