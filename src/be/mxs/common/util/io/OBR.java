package be.mxs.common.util.io;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.Base64;
import java.util.Vector;

import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonReader;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

import be.mxs.common.util.system.HTMLEntities;
import be.openclinic.finance.Debet;
import be.openclinic.finance.PatientInvoice;
import be.openclinic.finance.WicketCredit;
import be.openclinic.system.SH;
import net.admin.AdminPrivateContact;

public class OBR {
	public static String getProxyToken() throws ClientProtocolException, IOException {
		HttpClient client = HttpClients.createDefault();
		HttpPost req = new HttpPost("http://10.0.0.1/openclinic/api/obr/getToken.jsp");
		String aut = Base64.getEncoder().encodeToString((SH.cs("OBR_proxyuser","4")+":"+SH.cs("OBR_proxypassword","overmeire")).getBytes("utf-8"));
		req.setHeader("Authorization", "Basic "+aut);
		HttpResponse resp = client.execute(req);
		HttpEntity entity = resp.getEntity();
		String s = EntityUtils.toString(entity);
		JsonReader jr = Json.createReader(new java.io.StringReader(s));
		return jr.readObject().getString("token");
	}
	
	public static String getToken() throws ClientProtocolException, IOException {
		HttpClient client = HttpClients.createDefault();
		HttpPost req = new HttpPost(SH.cs("OBR_logincommand","http://41.79.226.28:8345/ebms_api/login/"));
	    req.setHeader("Content-Type", "application/json");
	    String aut = "{'username':'"+SH.cs("OBR_username","")+"','password':'"+SH.cs("OBR_password","")+"'}";
	    StringEntity reqEntity = new StringEntity(aut.replaceAll("'","\""));
	    req.setEntity(reqEntity);
	    
	    HttpResponse resp = client.execute(req);
	    HttpEntity entity = resp.getEntity();
	    JsonReader jr = Json.createReader(new java.io.StringReader(EntityUtils.toString(entity)));
	    JsonObject jo = jr.readObject();
	    return jo.getJsonObject("result").getString("token");
	}
	
	public static boolean addPatientInvoice(String uid, boolean useproxy) {
		boolean bSuccess=false;
		try {
			HttpClient client = HttpClients.createDefault();
			HttpPost req = new HttpPost(SH.cs("OBR_addinvoicecommand", "http://41.79.226.28:8345/ebms_api/addInvoice/"));
		   	req.setHeader("Content-Type", "application/json");
		   	req.setHeader("Authorization", "Bearer "+(useproxy?getProxyToken():getToken()));
		   	PatientInvoice invoice = PatientInvoice.get(uid);
		   	if(invoice!=null && invoice.getStatus().equalsIgnoreCase("closed")){
			    String inv = "{";
				inv+="'invoice_number':'"+invoice.getUid()+"',";
				inv+="'invoice_date':'"+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(invoice.getDate())+"',";
				inv+="'tp_type':'2',";
				inv+="'tp_name':'"+be.openclinic.system.SH.cs("OBR_taxpayer","CISA2 Team")+"',";
				inv+="'tp_TIN':'"+be.openclinic.system.SH.cs("OBR_TIN","4000235731")+"',";
				inv+="'tp_trade_number':'"+be.openclinic.system.SH.cs("OBR_tradenumber","3333")+"',";
				inv+="'tp_postal_number':'"+be.openclinic.system.SH.cs("OBR_postalcode","1234")+"',";
				inv+="'tp_phone_number':'"+be.openclinic.system.SH.cs("OBR_phonenumber","68350265")+"',";
				inv+="'tp_address_commune':'"+be.openclinic.system.SH.cs("OBR_town","BUJUMBURA")+"',";
				inv+="'tp_address_quartier':'"+be.openclinic.system.SH.cs("OBR_quarter","ROHERO")+"',";
				inv+="'tp_address_avenue':'"+be.openclinic.system.SH.cs("OBR_street","Av. de université")+"',"; //Pas d'accents!!!
				inv+="'tp_address_number':'"+be.openclinic.system.SH.cs("OBR_streetnumber","4")+"',";
				inv+="'vat_taxpayer':'"+be.openclinic.system.SH.cs("OBR_vattaxpayer","0")+"',";
				inv+="'ct_taxpayer':'0',";
				inv+="'tl_taxpayer':'0',";
				inv+="'tp_fiscal_center':'"+be.openclinic.system.SH.cs("OBR_fiscalcenter","DGF")+"',";
				inv+="'tp_activity_sector':'"+be.openclinic.system.SH.cs("OBR_activitysector","Services de soins")+"',";
				inv+="'tp_legal_form':'"+be.openclinic.system.SH.cs("OBR_legalform","hospitals")+"',";
		   		String paymenttype="1";
		   		Vector<WicketCredit> credits = WicketCredit.getByInvoiceUid(invoice.getUid());
		   		if(credits.size()>0){
		   			WicketCredit credit = credits.elementAt(0);
		   			if(credit.getWicket()!=null && be.openclinic.system.SH.c(credit.getWicket().getType()).length()>0 && !credit.getWicket().getType().equalsIgnoreCase("cash")){
		   				paymenttype="2";
		   			}
		   		}
				inv+="'payment_type':'"+paymenttype+"',";  
				inv+="'customer_name':'"+invoice.getPatient().getFullName()+"',";
				inv+="'customer_TIN':'',";
				inv+="'customer_address':'"+(invoice.getPatient().privateContacts.size()>0?((AdminPrivateContact)(invoice.getPatient().privateContacts.elementAt(0))).address:"")+"',";
				inv+="'vat_customer_payer':'0',";
				inv+="'invoice_type':'FN',";
				inv+="'cancelled_invoice_ref':'',";
				inv+="'invoice_signature':'"+be.openclinic.system.SH.cs("OBR_TIN","4000235731")+"/"+be.openclinic.system.SH.cs("OBR_username","ws400023573100150")+"/"+new java.text.SimpleDateFormat("yyyyMMddHHmmss").format(invoice.getDate())+"/"+invoice.getUid()+"',"; //Identifiant du système?
				inv+="'invoice_signature_date':'"+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(invoice.getDate())+"',";
				inv+="'invoice_items':[";
				boolean bHasDebets=false;
				for(int n=0;n<invoice.getDebets().size();n++){
					Debet debet = (Debet)invoice.getDebets().elementAt(n);
					if(debet.getQuantity()>0){
						if(bHasDebets){
							inv+= ",";
						}
						else{
							bHasDebets=true;
						}
						inv+=	"{";
						inv+=		"'item_designation':'"+debet.getPrestation().getDescription()+"',"; //pas d'accents
						inv+=		"'item_quantity':'"+debet.getQuantity()+"',";
						inv+=		"'item_price':'"+(debet.getAmount()/debet.getQuantity())+"',";
						inv+=		"'item_ct':'0',";
						inv+=		"'item_tl':'0',";
						inv+=		"'item_price_nvat':'"+(debet.getAmount()/debet.getQuantity())+"',";
						inv+=		"'vat':'0',";
						inv+=		"'item_price_wvat':'"+(debet.getAmount()/debet.getQuantity())+"',";
						inv+=		"'item_total_amount':'"+(debet.getAmount()/debet.getQuantity())+"'";
						inv+=	"}";
					}
				}
				inv+="]";
				inv+="}";
			    StringEntity reqEntity = new StringEntity(HTMLEntities.htmlentities(inv.replaceAll("'","\"")));
			    req.setEntity(reqEntity);
		   	}
		    
		   	HttpResponse resp = client.execute(req);
		    HttpEntity entity = resp.getEntity();
		    String s = EntityUtils.toString(entity);
		    JsonReader jr = Json.createReader(new java.io.StringReader(s));
		    JsonObject jo = jr.readObject();
		    bSuccess=jo.getBoolean("success");
		}
		catch(Exception e) {
			return false;
		}
	    return bSuccess;
	}
	
	public static JsonObject addPatientInvoiceGetJSONObject(String uid, boolean useproxy) {
		JsonObject joResult=null;
		try {
			HttpClient client = HttpClients.createDefault();
			HttpPost req = new HttpPost(SH.cs("OBR_addinvoicecommand", "http://41.79.226.28:8345/ebms_api/addInvoice/"));
		   	req.setHeader("Content-Type", "application/json");
		   	req.setHeader("Authorization", "Bearer "+(useproxy?getProxyToken():getToken()));
		   	PatientInvoice invoice = PatientInvoice.get(uid);
		   	if(invoice!=null && invoice.getStatus().equalsIgnoreCase("closed")){
			    String inv = "{";
				inv+="'invoice_number':'frank."+invoice.getUid()+"',";
				inv+="'invoice_date':'"+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(invoice.getDate())+"',";
				inv+="'tp_type':'2',";
				inv+="'tp_name':'"+be.openclinic.system.SH.cs("OBR_taxpayer","CISA2 Team")+"',";
				inv+="'tp_TIN':'"+be.openclinic.system.SH.cs("OBR_TIN","4000235731")+"',";
				inv+="'tp_trade_number':'"+be.openclinic.system.SH.cs("OBR_tradenumber","3333")+"',";
				inv+="'tp_postal_number':'"+be.openclinic.system.SH.cs("OBR_postalcode","1234")+"',";
				inv+="'tp_phone_number':'"+be.openclinic.system.SH.cs("OBR_phonenumber","68350265")+"',";
				inv+="'tp_address_commune':'"+be.openclinic.system.SH.cs("OBR_town","BUJUMBURA")+"',";
				inv+="'tp_address_quartier':'"+be.openclinic.system.SH.cs("OBR_quarter","ROHERO")+"',";
				inv+="'tp_address_avenue':'"+be.openclinic.system.SH.cs("OBR_street","Av. de université")+"',"; //Pas d'accents!!!
				inv+="'tp_address_number':'"+be.openclinic.system.SH.cs("OBR_streetnumber","4")+"',";
				inv+="'vat_taxpayer':'"+be.openclinic.system.SH.cs("OBR_vattaxpayer","0")+"',";
				inv+="'ct_taxpayer':'0',";
				inv+="'tl_taxpayer':'0',";
				inv+="'tp_fiscal_center':'"+be.openclinic.system.SH.cs("OBR_fiscalcenter","DGF")+"',";
				inv+="'tp_activity_sector':'"+be.openclinic.system.SH.cs("OBR_activitysector","Services de soins")+"',";
				inv+="'tp_legal_form':'"+be.openclinic.system.SH.cs("OBR_legalform","hospitals")+"',";
		   		String paymenttype="1";
		   		Vector<WicketCredit> credits = WicketCredit.getByInvoiceUid(invoice.getUid());
		   		if(credits.size()>0){
		   			WicketCredit credit = credits.elementAt(0);
		   			if(credit.getWicket()!=null && be.openclinic.system.SH.c(credit.getWicket().getType()).length()>0 && !credit.getWicket().getType().equalsIgnoreCase("cash")){
		   				paymenttype="2";
		   			}
		   		}
				inv+="'payment_type':'"+paymenttype+"',";  
				inv+="'customer_name':'"+invoice.getPatient().getFullName()+"',";
				inv+="'customer_TIN':'',";
				inv+="'customer_address':'"+(invoice.getPatient().privateContacts.size()>0?((AdminPrivateContact)(invoice.getPatient().privateContacts.elementAt(0))).address:"")+"',";
				inv+="'vat_customer_payer':'0',";
				inv+="'invoice_type':'FN',";
				inv+="'cancelled_invoice_ref':'',";
				inv+="'invoice_signature':'"+be.openclinic.system.SH.cs("OBR_TIN","4000235731")+"/"+be.openclinic.system.SH.cs("OBR_username","ws400023573100150")+"/"+new java.text.SimpleDateFormat("yyyyMMddHHmmss").format(invoice.getDate())+"/frank."+invoice.getUid()+"',"; //Identifiant du système?
				inv+="'invoice_signature_date':'"+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(invoice.getDate())+"',";
				inv+="'invoice_items':[";
				boolean bHasDebets=false;
				for(int n=0;n<invoice.getDebets().size();n++){
					Debet debet = (Debet)invoice.getDebets().elementAt(n);
					if(debet.getQuantity()>0){
						if(bHasDebets){
							inv+= ",";
						}
						else{
							bHasDebets=true;
						}
						inv+=	"{";
						inv+=		"'item_designation':'"+debet.getPrestation().getDescription()+"',"; //pas d'accents
						inv+=		"'item_quantity':'"+debet.getQuantity()+"',";
						inv+=		"'item_price':'"+(debet.getAmount()/debet.getQuantity())+"',";
						inv+=		"'item_ct':'0',";
						inv+=		"'item_tl':'0',";
						inv+=		"'item_price_nvat':'"+(debet.getAmount()/debet.getQuantity())+"',";
						inv+=		"'vat':'0',";
						inv+=		"'item_price_wvat':'"+(debet.getAmount()/debet.getQuantity())+"',";
						inv+=		"'item_total_amount':'"+(debet.getAmount()/debet.getQuantity())+"'";
						inv+=	"}";
					}
				}
				inv+="]";
				inv+="}";
			    StringEntity reqEntity = new StringEntity(HTMLEntities.htmlentities(inv.replaceAll("'","\"")));
			    req.setEntity(reqEntity);
		   	}
		    
		   	HttpResponse resp = client.execute(req);
		    HttpEntity entity = resp.getEntity();
		    String s = EntityUtils.toString(entity);
		    JsonReader jr = Json.createReader(new java.io.StringReader(s));
		    JsonObject jo = jr.readObject();
		    joResult=jo;
		}
		catch(Exception e) {
			return null;
		}
	    return joResult;
	}
	
	public static String validateTIN(String tin) throws ClientProtocolException, IOException {
		String taxpayer ="Unknown";
		//1. Construire un client HTTP
		HttpClient client = HttpClients.createDefault();
		
		//2. Construire une requête POST et l'exécuter sur le client HTTP
		HttpPost req = new HttpPost(SH.cs("OBR_checkTINcommand","http://41.79.226.28:8345/ebms_api/checkTIN/"));
	    req.setHeader("Content-Type", "application/json");
	   	req.setHeader("Authorization", "Bearer "+getProxyToken());
		String body = "{'tp_TIN':'"+tin+"'}";
	    StringEntity reqEntity = new StringEntity(HTMLEntities.htmlentities(body.replaceAll("'","\"")));
	    req.setEntity(reqEntity);
	    HttpResponse resp = client.execute(req);
	    
		//3. Récupérer la réponse HTTP
	    HttpEntity entity = resp.getEntity();
	    String s = EntityUtils.toString(entity);
		
		//4. Mettre le body de la réponse dans un objet JSON
	    JsonReader jr = Json.createReader(new java.io.StringReader(s));
	    JsonObject jo = jr.readObject();
		
		//5. Extraire le nom du contribuable de l'objet JSON
	    if(jo.getBoolean("success")) {
	    	taxpayer = jo.getJsonObject("result").getJsonArray("taxpayer").getJsonObject(0).getString("tp_name");
	    }
	    
		return taxpayer;
	}
}
