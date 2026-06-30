
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Graphics as Gfx;
using Toybox.Math as Math;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Calendar;
using Toybox.Application as App;
using Toybox.ActivityMonitor as Act;
using Toybox.SensorHistory;
using Toybox.Sensor;


enum {
    BackGroundColor, //0
    PresentColor,//1
    PastFutureColor,//2
    HourColor,//3
    MinutesColor,//4
    is24h,//5
    Field1,//6
    Field1Color,//7
    Field2,
    Field2Color,//9
    Field3,
    Field3Color,//11
    Field4,
    Field4Color,//13
    sourceBG,
    code,
    NSurl,
    NStoken,
    lastParametre
}
enum { //liste parametres fields
Nothing,
Battery,
Steps,
Distance,
Notifs,
Altitude,
Pressure,
Floor,
Temper,
TempExt,
Calories,
CurrentHeartRate,
TimeToRecovery,
BodyBattery,
ActiveMinutesDay,
ActiveMinutesWeek,
BG,
sunset,
sunrise,
spo2,
Seconds,
Digital_Time,
MoisJour,
JourMois,
JourSem,
JourSemJour,
JourSemMoisJour,
Week_number,
	}

var ParametresChanges = false; //pour les modifications avec le telephone
var haveToSaveParams = false; //pour les modifications avec la montre
var params ;
//var oldParams;
//var paramNamesTab;
    var couleurFond,couleurChiffresH,couleurChiffresM;

    var isAwake = true;
    var watchView;

    var bgBg =0;
    var tabData = new[0];
    var bgSecondes = Time.now().value()- 99*60; 
    var bgDelta = 0;
    var unitBG = 0; //0 mg/dl, 1 mmol/l

	var decalageY_OLED = 0;  // pour changement de place en mode low power sur les AMOLED
	var decalageX_OLED = 0;  // pour changement de place en mode low power sur les AMOLED
    var fenetre_heures;
    var fontPresentPastFuture;
   // var fieldsIcon;
    var iconsFieldsFont;
    var myLogo;
    var locked = false;
    var codeOK = false;
    var timeInstallation = 0;

	var lastD,lastLng,locLueString; //pour le sunset
    var hLever = 0.0;
    var hCoucher = 0.0;



class ProjectsWatchApp extends App.AppBase {

    function initialize() {
        AppBase.initialize();
   }
    function listParamNames() {
        var tab = [];
tab.add(WatchUi.loadResource(Rez.Strings.BackGroundColor));
tab.add(WatchUi.loadResource(Rez.Strings.PresentColor));
tab.add(WatchUi.loadResource(Rez.Strings.PastFutureColor));
tab.add(WatchUi.loadResource(Rez.Strings.HourColor));
tab.add(WatchUi.loadResource(Rez.Strings.MinutesColor));
tab.add(WatchUi.loadResource(Rez.Strings.is24h));
tab.add(WatchUi.loadResource(Rez.Strings.Field1));
tab.add(WatchUi.loadResource(Rez.Strings.Field1Color));
tab.add(WatchUi.loadResource(Rez.Strings.Field2));
tab.add(WatchUi.loadResource(Rez.Strings.Field2Color));
tab.add(WatchUi.loadResource(Rez.Strings.Field3));
tab.add(WatchUi.loadResource(Rez.Strings.Field3Color));
tab.add(WatchUi.loadResource(Rez.Strings.Field4));
tab.add(WatchUi.loadResource(Rez.Strings.Field4Color));
tab.add(WatchUi.loadResource(Rez.Strings.sourceBG));
tab.add(WatchUi.loadResource(Rez.Strings.code));
tab.add(WatchUi.loadResource(Rez.Strings.Nsurl));
tab.add(WatchUi.loadResource(Rez.Strings.Nstoken));
        return tab;
    }


    function getInitialView() as [Views] or [Views, InputDelegates] {
        watchView = new ProjectsWatchView();
        watchView.loadParams(true);
        Background.deleteTemporalEvent();
        readLastData();
        Sys.println("Initialize sync with offsetMillis="+bgSecondes);
        resync();
        return [watchView, new AnalogDelegate()];
    }


    public function getSettingsView()  {
		var menuView = new MenuView("Settings",menuPrincipalTab(),2, 0,false,true);
		return [menuView, new MenusDelegate(menuView)];
    }
    function menuPrincipalTab() {
        var tab = [];
        tab.add(WatchUi.loadResource(Rez.Strings.BackGroundColor));
        tab.add(WatchUi.loadResource(Rez.Strings.PresentColor));
        tab.add(WatchUi.loadResource(Rez.Strings.PastFutureColor));
        tab.add(WatchUi.loadResource(Rez.Strings.HourColor));
        tab.add(WatchUi.loadResource(Rez.Strings.MinutesColor));
        tab.add(WatchUi.loadResource(params[is24h] ? Rez.Strings.is24h_2 : Rez.Strings.is24h));
        tab.add("Fields");
        tab.add("BG source");
        tab.add("Unlock code");
        return tab;
    }

    function onSettingsChanged() {
        System.println("-----------------------onSettingsChanged---------------------------");
		ParametresChanges = true;
        
		WatchUi.requestUpdate();
	}

    function resync() { // réglage prochain temporal event, 5 min au moins après le précédent, et juste après la prochaine lecture du capteur + tempo
        var isThereBG = (params[Field1] == BG) || (params[Field2] == BG) || (params[Field3] == BG) || (params[Field4] == BG);
        if (! isThereBG) {
            Sys.println("stop RESYNC, no BG field, return");
            return;
        }
        Sys.println("start RESYNC ---");
        Background.deleteTemporalEvent();
        var TEMPO_WEB = [15,10,15][params[sourceBG]];  //tempo pour que la nouvelle glycemie soit dispo sur Nightscout, Xdrip ou AAPS 
        var timeNowValue = Time.now().value();
        var last_capteur_seconds_time = bgSecondes;
        if ((last_capteur_seconds_time == null) || (last_capteur_seconds_time == 0)){
            last_capteur_seconds_time = timeNowValue - 600; //pour synchro des que possible
        }
        var getLastTemporalEventTime = Background.getLastTemporalEventTime();
        var lastTemporalEventTime = 0;
        if (getLastTemporalEventTime != null) {
            lastTemporalEventTime = getLastTemporalEventTime.value();
        }
        else {
            lastTemporalEventTime = timeNowValue - 600;
        }
        var nextCallEventTimeMini = lastTemporalEventTime + 300; //next call mini 5 min after last temporal event
        var nextCapteurTimeMini = last_capteur_seconds_time + 300 + TEMPO_WEB; //next call mini after last capteur + tempo
        var delaiMin = nextCallEventTimeMini - timeNowValue;
        var delaiCapteur = nextCapteurTimeMini - timeNowValue;
        //delaiMin = 60;
        //delaiCapteur = -200;
        var tempo = delaiMin;
        if (delaiMin > 0) {
            if (delaiCapteur < delaiMin - 10 && delaiCapteur > 5) {
               tempo = (delaiCapteur % 300)  + 300;
            }
            if (delaiCapteur > delaiMin && delaiCapteur - delaiMin < 10) {
                tempo = delaiCapteur;
            }
        }
        if (tempo<1) {tempo = 1;}
        if (tempo < delaiMin) {tempo = delaiMin;}

        Sys.println("RESYNC fin OK---tempo = " + tempo + " delaiMin = "+delaiMin+"  delaiCapteur = "+(delaiCapteur));

        Background.registerForTemporalEvent(Time.now().add(new Time.Duration(tempo))); 
    }

    function onBackgroundData(data) { //data=[sgv,delta,timeSecondes]
	    Sys.println("onBackgroundData "+data);
        if (data[0]>0) {
            enregistreDernierCapteur(data);
            var capteurSecondes = data[2];
            Sys.println("onBackgroundData secondes capteur= "+capteurSecondes);
            if (capteurSecondes > 0) {
                Sys.println("onBackgroundData call resync(capteurSecondes) "+capteurSecondes);
                resync(); 
                return;           
            } 
        }
        Sys.println("onBackgroundData invalid data pose 300 sec");
        Background.registerForTemporalEvent(new Time.Duration(300));

    }

const NBRE_MAXI_DATA = 5;

    function enregistreDernierCapteur(capteur) {//capteur=[sgv,delta,timeSecondes]
        System.println("enregistre Dernier Capteur "+capteur);
        
        tabData.add(capteur);// ajoute a la fin
        if (tabData.size()>NBRE_MAXI_DATA) {
            tabData.remove(tabData[0]); // enleve le 1er
        }
        storeAllBGData(tabData);
        bgBg = capteur[0];
        bgDelta = capteur[1];
        bgSecondes = capteur[2];
    }

    function readLastData() {
        readAllData();
        if (tabData.size() > 0) {
            var lastCapteur = tabData[tabData.size() - 1];
            bgBg = lastCapteur[0];
            bgDelta = lastCapteur[1];
            bgSecondes = lastCapteur[2];
            System.println("readLastData bgBg="+bgBg+" bgDelta="+bgDelta+" bgSecondes="+bgSecondes);
        }
    }
    
    function readAllData() {
        //System.println("start readAllData ");
        var st = Application.Storage.getValue("BGdata");
       
        tabData=new[0];
        if ((st == null) || (st.length() < 3)) {
            return tabData;
        }
        var	n1 = st.find(";");
        while (n1 != null) {
            var st2 = st.substring(0,n1);
            st = st.substring(n1+1,st.length());
            n1 = st.find(";");

            var tab2 = new[0];
            var	n2 = st2.find(",");
            tab2.add(st2.substring(0,n2).toNumber()); //BG
            st2 = st2.substring(n2+1,st2.length());

            n2 = st2.find(",");
            tab2.add(st2.substring(0,n2).toNumber()); //BG,delta
            st2 = st2.substring(n2+1,st2.length());

            tab2.add(st2.toNumber()); //BG,delta,secondes

            tabData.add(tab2); //[BG,delta,secondes]
        }
        //System.println("fin readAllData  ="+tab);
        //return tab;
    }

    function stringToArray(st,Tab) {
        var result = new[0];
        var num1,num2;
        num1 = st.find("[");
        System.println("");
        var nbrecrochets = 0; 
        var crochetsfermes = ""; 
        if (num1 == null) {
            System.println("NEW "+st+"  num1="+num1+"  ajoute et retourne");
            Tab.add(st);
            return Tab;
        }  
        while (num1 != null) {
            System.println("NEW "+st+"  num1="+num1+"  OK continue boucle");
            nbrecrochets++;
            crochetsfermes = crochetsfermes+"]";
            var newTab = new[0];
            if (num1 == 0) {
                num2 = st.find(crochetsfermes);
                //var newst = st.substring(1,num2-1+nbrecrochets);
                var newst = st.substring(1,num2);
                System.println("crochetsfermes="+crochetsfermes+ " recherche dans st="+st+" -->"+newst);
                st = st.substring(num2+3,null);
                var arr = ProjectsWatchApp.stringToArray(newst,newTab);
                Tab.add(arr);
                System.println("dimension="+nbrecrochets+ "   prochain st="+st);
            }
            num1 = st.find("[");
            crochetsfermes = "";   
        }
        //result.add(newTab);
        //System.println("----->result="+result.toString());
        return Tab;
        
    }
            

    function storeAllBGData(myTab) {
        System.println("debut storeAllBGData "+myTab);
        var st = "";
        for (var i = 0;i<myTab.size();i++) {
            if ((myTab[i] !=null) && (myTab[i][0] !=null) && (myTab[i][1] !=null) && (myTab[i][2] !=null)) {
            st=st+myTab[i][0].toString()+","+myTab[i][1].toString()+","+myTab[i][2].toString()+";";
            }
        }
        Application.Storage.setValue("BGdata",st);
        System.println("fin storeAllBGData st = "+st);
     }



    function getServiceDelegate(){
		Sys.println("getServiceDelegate");
        return [new WatchBG()];
    }




}


class AnalogDelegate extends WatchUi.WatchFaceDelegate {

    function initialize() {
        WatchFaceDelegate.initialize();
   }

    function onPowerBudgetExceeded(powerInfo) {
        System.println( "Moy temps: " + powerInfo.executionTimeAverage );
        System.println( "Temps Max: " + powerInfo.executionTimeLimit );
		ParametresChanges = true;
		WatchUi.requestUpdate();
    }

}
