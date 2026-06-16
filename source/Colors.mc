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

return [ "Aqua","Black","Blue",
"Blue_Dark",//3
"Blue_Ice",
"Blue_Light",
"Blue_Ocean",//6
"Blue_Pale",
"Blue_Sky",
"Brown",//9
"Coral",
"Gold",
"Gray_25",//12
"Gray_40",
"Gray_50",
"Gray_80",//15
"Gray_Blue",
"Green",
"Green_Bright",//18
"Green_Dark",
"Green_Light",
"Green_Olive",//21
"Green_Sea",
"Indigo",
"Ivory",//24
"Lavender",
"Lime",
"Orange",//27
"Orange_Light",
"Periwinkle",
"Pink",//30
"Plum",
"Purple_Dark",
"Red",//33
"Red_Dark",
"Rose",
"Tan",//36
"Teal",
"Teal_Dark",
"Turquoise",//39
"Turquoise_Light",
"Violet",
"White",//42
"Yellow",
"Yellow_Dark",
"Yellow_Light",
"Transparent"

];

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