
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
Seconds,
Digital_Time,
MoisJour,
JourMois,
JourSem,
JourSemJour,
JourSemMoisJour,
Week_number
	}

const MOIS = ["",  //les mois vont de 1 a 12, donc pas de zero
		WatchUi.loadResource( Rez.Strings.M1),
		WatchUi.loadResource( Rez.Strings.M2),
		WatchUi.loadResource( Rez.Strings.M3),
		WatchUi.loadResource( Rez.Strings.M4),
		WatchUi.loadResource( Rez.Strings.M5),
		WatchUi.loadResource( Rez.Strings.M6),
		WatchUi.loadResource( Rez.Strings.M7),
		WatchUi.loadResource( Rez.Strings.M8),
		WatchUi.loadResource( Rez.Strings.M9),
		WatchUi.loadResource( Rez.Strings.M10),
		WatchUi.loadResource( Rez.Strings.M11),
		WatchUi.loadResource( Rez.Strings.M12)
	];

const DAYOFWEEK = ["",//les jours de semaine vont de 1 a 7, donc pas de zero
		WatchUi.loadResource( Rez.Strings.Day1), // dimanche
		WatchUi.loadResource( Rez.Strings.Day2),
		WatchUi.loadResource( Rez.Strings.Day3),
		WatchUi.loadResource( Rez.Strings.Day4),
		WatchUi.loadResource( Rez.Strings.Day5),
		WatchUi.loadResource( Rez.Strings.Day6),
		WatchUi.loadResource( Rez.Strings.Day7) // samedi
	];

var couleurFond,couleurChiffresH,couleurChiffresM;

var isAwake = true;
var watchView;


class ProjectsWatchApp extends App.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        watchView = new ProjectsWatchView();
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
