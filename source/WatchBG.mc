
using Toybox.Background;
using Toybox.Communications;
using Toybox.System as Sys;
using Toybox.Time.Gregorian as Calendar;
using Toybox.Lang;


(:background)
class WatchBG extends Toybox.System.ServiceDelegate {
    var receiveCtr = 0;
    //var bgdata = {};
    var reqNum = 0;
    //var propReq = {};

    function initialize() {
        Sys.ServiceDelegate.initialize();
    }

    function onTemporalEvent() {
        Sys.println("in onTemporalEvent");
        receiveCtr = 0;
        reqNum = 0;
        var isThereBg = Application.Properties.getValue("param"+Field1) == BG || Application.Properties.getValue("param"+Field2) == BG || Application.Properties.getValue("param"+Field3) == BG || Application.Properties.getValue("param"+Field4) == BG;
        if (isThereBg) {
            System.println("onTemporalEvent call myWebRequest");
            myWebRequest(true, 0, false);
        }
        else {
            System.println("onTemporalEvent no BG field, return ");
            //Background.exit([0,0,0]);
        }

    }

	function removeWhitespace(url) {
		while(!url.equals("") && url.substring(0,1).equals(" ")) {
		    url = url.substring(1,url.length());
        }
		while(!url.equals("") && url.substring(url.length()-1,url.length()).equals(" ")) {
		    url = url.substring(0,url.length()-1);
        }
        while(url.substring(url.length()-1,url.length()).equals("/")) {
		    url = url.substring(0,url.length()-1);
        }
        if (url.substring(url.length()-9,url.length()).equals("/sgv.json")) {
		    url = url.substring(0,url.length()-9);
        }
		return url;
	}


    function makeNSURL(fetchMode, loop) {
        
        var url =  Application.Properties.getValue("param"+NSurl);
        var utilisateurNS =  Application.Properties.getValue("param"+NStoken);
		var token = "";
		if ((utilisateurNS != null) && (! utilisateurNS.equals(""))) {token = "&token="+utilisateurNS;}
		
		//url = url+token;
		if (url == null) { url = ""; }

		url = removeWhitespace(url);

        if (!url.equals("")) {
        	//var options = "";
	        if (url.find("://") == null) {
    	        url = "https://" + url;
        	}
//  https://mon_site.com
//  /api/v1/entries/sgv.json?count=3
//  &token=myToken
//  url = https://mon_site.com/api/v1/entries/sgv.json?count=3&token=myToken
 
			url = url + "/api/v1/entries/sgv.json?count=3"+token;
			//url = url + options;
	   	}
		System.println("makeNSURL "+url);
        return url;
	}


    function myWebRequest(ns, fetchMode, loop) {
		var url;
        var source = Application.Properties.getValue("param"+sourceBG);
		if (source == 0) {
			url = makeNSURL(fetchMode, loop);//Nightscout
		} else if (source == 1) {
			url = "http://127.0.0.1:28891/sgv.json?count=3&brief_mode=true"; //AAPS
		} else if (source == 2) {
			url = "http://127.0.0.1:17580/sgv.json?count=3" ; //xdrip
		}
		//traiteDebugSent(sourceBG);
		receiveCtr++;
		reqNum++;
		Sys.println("request url: " + url);
		Communications.makeWebRequest(url, {}, { :method => Communications.HTTP_REQUEST_METHOD_GET,
														:headers => {                                           // set headers
																"Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED},
														:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
													}, method(:onReceiveSGV));
		return true;
    } 

    function onReceiveSGV(responseCode, data) {//si coderesponse 404=pas de réseau
        Sys.println("in OnReceiveSGV  responseCode="+ responseCode + "  "+data);
		var timeSecondes=0;
		var sgv=0;
        //var sgvPrevious=0;
		var delta=0;
        if ((responseCode == 200) &&
            (data != null) &&
        	(data instanceof Array) &&
            (data.size() > 1) &&
            (data[0] != null) &&
            (data[1] != null) &&
            !data[0].isEmpty() &&
            !data[1].isEmpty()
            ) {
            //bgdata["sgv"] = data;
            if (data[0].hasKey("sgv") &&
                data[0].hasKey("date") &&
                data[1].hasKey("sgv")
                ) {
                    var millis = data[0]["date"].toLong();
                    var bg = data[0]["sgv"].toNumber();
                    var previousbg = data[1]["sgv"].toNumber();
                    System.println("Reçu : millis="+millis+"  bg="+bg+"  previousbg="+previousbg);
                    if (millis != null && bg != null && previousbg != null) {
                        timeSecondes = millis/1000 as Lang.Long;
                        sgv = bg;
                        delta = bg-previousbg;
                        System.println("Transmis : [ sgv , delta , timeSecondes ] = [ "+sgv+" , "  + delta + " , " + timeSecondes+" ]");
                    }
            }
        }
		receiveCtr--;
        Background.exit([sgv,delta,timeSecondes]);
        
    }
}
