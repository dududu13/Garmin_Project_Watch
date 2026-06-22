
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

var ParametresChanges = true;
var params ;
var oldParams;

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
Seconds,
Digital_Time,
MoisJour,
JourMois,
JourSem,
JourSemJour,
JourSemMoisJour,
Week_number,

UnitBG
	}

    var couleurFond,couleurChiffresH,couleurChiffresM;

    var isAwake = true;
    var watchView;

    var bgBg =0;
    var tabData = new[0];
    var bgSecondes = Time.now().value()- 99*60; 
    var bgDelta = 0;
    var unitBG = 0; //0 mg/dl, 1 mmol/l


class ProjectsWatchApp extends App.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        watchView = new ProjectsWatchView();

        Background.deleteTemporalEvent();
        //var thisApp = Application.getApp();
        var lastBGmillis = watchView.bgSecondes;
        Sys.println("Initialize sync with offsetMillis="+lastBGmillis);
        var next = ProjectsWatchView.prochainBackground(); //return [delaiRestant,prochainTime];
        System.println("Delai restant="+next[0]);
        resync(lastBGmillis);
        return [watchView, new AnalogDelegate()];
    }


    public function getSettingsView()  {
		var menuView = new MenuView("Settings",MenusDelegate.menuPrincipalTab(),2, 0,false,true);
		return [menuView, new MenusDelegate(menuView)];
    }

    function onSettingsChanged() {
		ParametresChanges = true;
		WatchUi.requestUpdate();
	}

    function DelaiTemporalEventSecondRestant() {
        
        var delaiMin = 1;

        var lastBackgroundMoment = Background.getLastTemporalEventTime();// as Time.Moment or Time.Duration or Null
        var delaiRestantSecondes=0;
        if (lastBackgroundMoment != null) {
          Sys.println("DelaiTemporalEventSecondRestant temporal depuis = "+(Time.now().value() - lastBackgroundMoment.value()) +" sec");
          delaiRestantSecondes = 300 -Time.now().value() + lastBackgroundMoment.value();
        } else {
          Sys.println("DelaiTemporalEventSecondRestant temporal null, delai = 0");

        }
        var delaiCalcule = delaiRestantSecondes;
        if (delaiCalcule<delaiMin) {delaiRestantSecondes = delaiMin;}
        //s.println("DelaiTemporalEventSecondRestant = "+delaiRestantSecondes);
        return delaiRestantSecondes;
    }

    function resync(last_capteur_seconds) { // réglage prochain temporal event, 5 min au moins après le précédent, et juste après la prochaine lecture du capteur + tempo
        Sys.println("start RESYNC : last_capteur_seconds = "+last_capteur_seconds);
        var TEMPO_WEB = [15,10,15];  //tempo pour que la nouvelle glycemie soit dispo sur Nightscout, Xdrip ou AAPS 
        var timeNowValue = Time.now().value();
        var tempoWeb = Application.Storage.getValue("tempoWeb");
        if (tempoWeb == null) {
            tempoWeb = timeNowValue - 600;
            Application.Storage.setValue("tempoWeb", tempoWeb);
        }
        
        var delaiCapteurRestantMini = 0;
        //var last_capteur_seconde;
        if ((last_capteur_seconds == null) || (last_capteur_seconds == 0)){
            last_capteur_seconds = timeNowValue - 600 - tempoWeb -60; //pour synchro des que possible
        }

        var capteurElapsed = timeNowValue - last_capteur_seconds;
        delaiCapteurRestantMini = 300 - capteurElapsed + tempoWeb; //
        var delaicapteurCorrige = delaiCapteurRestantMini;
        if ((delaiCapteurRestantMini >-300 ) && (delaiCapteurRestantMini <295)){
            delaicapteurCorrige = delaiCapteurRestantMini % 300 +300; // de 300 à 599
        }
        var temporalMinRestant = ProjectsWatchApp.DelaiTemporalEventSecondRestant();
        var timeTempo = temporalMinRestant;

        if ((delaicapteurCorrige < 595) && (temporalMinRestant<delaicapteurCorrige)) {
            timeTempo = delaicapteurCorrige; //correction en rallongeant
        }

        Sys.println("RESYNC 0 timeNowValue            = " +timeNowValue);
        Sys.println("RESYNC 1 capteurElapsed          = " +capteurElapsed);
        Sys.println("RESYNC 2 delaiCapteurRestantMini = " +delaiCapteurRestantMini);
        Sys.println("RESYNC 3 delaicapteurCorrige     = " +delaicapteurCorrige);
        Sys.println("RESYNC 4 temporalMinRestant      = " +temporalMinRestant);
        Sys.println("RESYNC 5 tempofinal              = " +timeTempo);
        Background.registerForTemporalEvent(Time.now().add(new Time.Duration(timeTempo))); 
        Sys.println("RESYNC fin OK---Tempo final posee = " + timeTempo);
    }


    function onBackgroundData(data) { //data=[sgv,delta,timeSecondes]
	    Sys.println("onBackground "+data);
        
        enregistreDernierCapteur(data);
        var capteurSecondes = data[2];
	    Sys.println("onBackground "+capteurSecondes);
        if (capteurSecondes > 0) {
            Sys.println("onBackgroundData call resync(capteurSecondes) "+capteurSecondes);
            resync(capteurSecondes);            
        } else {
            Sys.println("onBackgroundData invalid data: "+capteurSecondes + "pose 300 sec");
            Background.registerForTemporalEvent(new Time.Duration(300));
            resync(0);
        }
    

        //App.getApp().setProperty("offsetSeconds", offsetSeconds);

    }

const NBRE_MAXI_DATA = 5;//6h

    function enregistreDernierCapteur(capteur) {//capteur=[sgv,delta,timeSecondes]
        //if (capteur[0] ==0) { return;}
        System.println("enregistreDernierCapteur "+capteur);
        var allData = readAlldData();
        allData.add(capteur);// ajoute a la fin
        if (allData.size()>NBRE_MAXI_DATA) {
            allData.remove(allData[0]); // enleve le 1er
        }
        storeAllData(allData);
        Application.Storage.setValue("CapteurChanged",true);
        System.println("enregistreDernierCapteur FIN, secondes = "+capteur[2]);

    }
    
    function readAlldData() {
        //System.println("start readAlldData ");
        var st = Application.Storage.getValue("data");
       
        var tab=new[0];
        if ((st == null) || (st.length() < 3)) {
            return tab;
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

            tab.add(tab2); //[BG,delta,secondes]
        }
        //System.println("fin readAlldData  ="+tab);
        return tab;
    }

    function readAlldData2() {
        var st="[[153, -5, 1772098150], [[148, -5, 1772098451], [146, -2, 1772098750], [217, -1, 1772438800]]]";
        st = st.substring(1,st.length()-1); //enlève les doubles crochets de départ
        var array = ProjectsWatchApp.stringToArray(st,new[0]);
        System.println("Result final="+array.toString());
        //[0, 0, 0], [160, 0, 1772097550], [153, -5, 1772098150], [148, -5, 1772098451], [146, -2, 1772098750], [217, -1, 1772438800]
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
            

    function storeAllData(myTab) {
      System.println("debut storeAllData "+myTab);
      var st = "";
      for (var i = 0;i<myTab.size();i++) {
        if ((myTab[i] !=null) && (myTab[i][0] !=null) && (myTab[i][1] !=null) && (myTab[i][2] !=null)) {
        st=st+myTab[i][0].toString()+","+myTab[i][1].toString()+","+myTab[i][2].toString()+";";
        }
      }
      Application.Storage.setValue("data",st);
      System.println("fin storeAllData st = "+st);
     }

    function storeAllData2(myTab) {
      //System.println("debut storeAllData2 "+myTab);
      var st = myTab.toString();
      //for (var i = 0;i<myTab.size();i++) {
      //  if ((myTab[i] !=null) && (myTab[i][0] !=null) && (myTab[i][1] !=null) && (myTab[i][2] !=null)) {
      //  st=st+myTab[i][0].toString()+","+myTab[i][1].toString()+","+myTab[i][2].toString()+";";
      //  }
      //}
      //Application.Storage.setValue("data",st);
      System.println("fin storeAllData2 "+st);
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
