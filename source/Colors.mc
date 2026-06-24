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



class Colors {

function colorName(i) {
    var list = Colors.colorsNames();
    return list[i] ;
}
function colorsNames() {
var tab = [];
tab.add(WatchUi.loadResource(Rez.Strings.Aqua));
tab.add(WatchUi.loadResource(Rez.Strings.Black));
tab.add(WatchUi.loadResource(Rez.Strings.Blue));
tab.add(WatchUi.loadResource(Rez.Strings.Blue_Dark));
tab.add(WatchUi.loadResource(Rez.Strings.Blue_Ice));
tab.add(WatchUi.loadResource(Rez.Strings.Blue_Light));
tab.add(WatchUi.loadResource(Rez.Strings.Blue_Ocean));
tab.add(WatchUi.loadResource(Rez.Strings.Blue_Pale));
tab.add(WatchUi.loadResource(Rez.Strings.Blue_Sky));
tab.add(WatchUi.loadResource(Rez.Strings.Brown));
tab.add(WatchUi.loadResource(Rez.Strings.Coral));
tab.add(WatchUi.loadResource(Rez.Strings.Gold));
tab.add(WatchUi.loadResource(Rez.Strings.Gray_25));
tab.add(WatchUi.loadResource(Rez.Strings.Gray_40));
tab.add(WatchUi.loadResource(Rez.Strings.Gray_50));
tab.add(WatchUi.loadResource(Rez.Strings.Gray_80));
tab.add(WatchUi.loadResource(Rez.Strings.Gray_Blue));
tab.add(WatchUi.loadResource(Rez.Strings.Green));
tab.add(WatchUi.loadResource(Rez.Strings.Green_Bright));
tab.add(WatchUi.loadResource(Rez.Strings.Green_Dark));
tab.add(WatchUi.loadResource(Rez.Strings.Green_Light));
tab.add(WatchUi.loadResource(Rez.Strings.Green_Olive));
tab.add(WatchUi.loadResource(Rez.Strings.Green_Sea));
tab.add(WatchUi.loadResource(Rez.Strings.Indigo));
tab.add(WatchUi.loadResource(Rez.Strings.Ivory));
tab.add(WatchUi.loadResource(Rez.Strings.Lavender));
tab.add(WatchUi.loadResource(Rez.Strings.Lime));
tab.add(WatchUi.loadResource(Rez.Strings.Orange));
tab.add(WatchUi.loadResource(Rez.Strings.Orange_Light));
tab.add(WatchUi.loadResource(Rez.Strings.Periwinkle));
tab.add(WatchUi.loadResource(Rez.Strings.Pink));
tab.add(WatchUi.loadResource(Rez.Strings.Plum));
tab.add(WatchUi.loadResource(Rez.Strings.Purple_Dark));
tab.add(WatchUi.loadResource(Rez.Strings.Red));
tab.add(WatchUi.loadResource(Rez.Strings.Red_Dark));
tab.add(WatchUi.loadResource(Rez.Strings.Rose));
tab.add(WatchUi.loadResource(Rez.Strings.Tan));
tab.add(WatchUi.loadResource(Rez.Strings.Teal));
tab.add(WatchUi.loadResource(Rez.Strings.Teal_Dark));
tab.add(WatchUi.loadResource(Rez.Strings.Turquoise));
tab.add(WatchUi.loadResource(Rez.Strings.Turquoise_Light));
tab.add(WatchUi.loadResource(Rez.Strings.Violet));
tab.add(WatchUi.loadResource(Rez.Strings.White));
tab.add(WatchUi.loadResource(Rez.Strings.Yellow));
tab.add(WatchUi.loadResource(Rez.Strings.Yellow_Dark));
tab.add(WatchUi.loadResource(Rez.Strings.Yellow_Light));
return tab;
}

function colorValuesTab() {
    return [
    0x33CCCC,
0x000000,
0x0000FF,
0x000080,
0xCCCCFF,
0x3366FF,
0x0066CC,
0x99CCFF,
0x00CCFF,
0x993300,
0xFF8080,
0xFFCC00,
0xC0C0C0,
0x969696,
0x808080,
0x333333,
0x666699,
0x008000,
0x00FF00,
0x003300,
0xCCFFCC,
0x333300,
0x339966,
0x333399,
0xFFFFCC,
0xCC99FF,
0x99CC00,
0xFF6600,
0xFF9900,
0x9999FF,
0xFF00FF,
0x993366,
0x660066,
0xFF0000,
0x800000,
0xFF99CC,
0xFFCC99,
0x008080,
0x003366,
0x00FFFF,
0xCCFFFF,
0x800080,
0xFFFFFF,
0xFFFF00,
0x808000,
0xFFFF99,
Graphics.COLOR_TRANSPARENT
    ];
}

function getColor(thisName) {
    var list = Colors.colorsNames();
    for (var i = 0;i<list.size();i++) {
        if (thisName.equals(list[i])) {
            return Colors.colorValuesTab()[i];
            }
        }
    return Colors.colorValuesTab()[0];
    }
}