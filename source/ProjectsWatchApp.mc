
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

enum {
    BackGroundColor, //0
    PresentColor,//1
    PastFutureColor,//2
    HourColor,//4
    MinutesColor,//5
    SecondsColor,
    Field1Color,//6
    Field2Color,//7
    Field3Color,//8
    Field4Color,//9
    Field5Color,
    Field6Color,
    Field1,
    Field2,
    Field3,
    Field4,
    Field5,
    Field6,
    is24h,
    lastParametre
}

var couleurFond;


class ProjectsWatchApp extends App.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        var view = new ProjectsWatchView();
        //return [ new ProjectsWatchView() ];
        return [view, new AnalogDelegate()];
    }
    public function getSettingsView()  {
		var menuView = new MenuView("Settings",MenusDelegate.menuPrincipalTab(),2, 0,false,true);
		return [menuView, new MenusDelegate(menuView)];
    }

    function onSettingsChanged() {
		ParametresChanges = true;
		requestUpdate();
	}




}

//function getApp() as ProjectsWatchApp {
//    return Application.getApp() as ProjectsWatchApp;
//}


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
