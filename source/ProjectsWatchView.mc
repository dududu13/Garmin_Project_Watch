//using Toybox.Time.Gregorian as Calendar;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;


class ProjectsWatchView extends WatchUi.WatchFace {
    const TIME_BEFORE_LOCKING = 4; //un peu plus d'une heure
    
	var decalageY_OLED = 0;  // pour changement de place en mode low power sur les AMOLED
	var decalageX_OLED = 0;  // pour changement de place en mode low power sur les AMOLED
    var fenetre_heures;
   // var fieldsIcon;
    var iconsFieldsFont;
    var myLogo;
    var locked = false;
    var codeOK = false;
    var timeInstallation = 0;

    function initialize() {
        WatchFace.initialize();
        iconsFieldsFont = WatchUi.loadResource(Rez.Fonts.AllIcons);
    
    }
    function onShow() {
        fenetre_heures = WatchUi.loadResource(Rez.Drawables.fenetre_heures);
    }


    function onUpdate(dc as Dc) as Void {
        if (ParametresChanges) {
            loadParams();
        }
        View.onUpdate(dc);
        if (! codeOK) {testTimeInstallation();}
        else {locked = false;}
        dessineTout(dc,fenetre_heures,iconsFieldsFont,false);
    }

    function loadParams() {
        //params = [4, 33, 14, 3, 1, true, 0, 1, 0, 1, 0, 1, 0, 1 ];
        
        params = [42, 33, 14, 1, 1, true, 0, 1, 0, 1, 0, 1, 0, 1];
        for (var i = 0 ; i < params.size() ; i++) {
            var value = Application.Storage.getValue("Params"+i);
            if (value != null) {params[i] = value;}
        }
        couleurFond = Colors.colorValuesTab()[params[BackGroundColor]];
        couleurChiffresH = Colors.colorValuesTab()[params[HourColor]];
        couleurChiffresM = Colors.colorValuesTab()[params[MinutesColor]];
        testeCode();
        ParametresChanges = false;
        //System.println("loadparams = "+params);
    }

    
	static function testeCode() {
        myLogo = WatchUi.loadResource(Rez.Drawables.myLogo);
        var code_a_tester = Application.Properties.getValue("code");
		if (code_a_tester == null) {
            Application.Properties.setValue("code","");
            code_a_tester = "";
        }
        if (code_a_tester.length() >= 1) {
            if (code_a_tester.substring(code_a_tester.length()-1,code_a_tester.length()).equals(" ")) {
                code_a_tester = code_a_tester.substring(0,code_a_tester.length()-1);
            }
        }

		code_a_tester = code_a_tester.toUpper();
        var goodCode = WatchUi.loadResource(Rez.Strings.codeApp);

        if (code_a_tester.equals(goodCode)) {
            System.println("  code entré OK = "+code_a_tester);
            codeOK = true;
            locked = false;
        } else {
            System.println("  code entré pas OK = "+code_a_tester);
            codeOK = false;
            locked = true;
        }
    }

    function testTimeInstallation() {
        var installationTime = Application.Storage.getValue("installationTime");
        if (installationTime == null) {
            installationTime = Time.now().value();
            Application.Storage.setValue("installationTime",installationTime);
        }
        var timeNow = Time.now().value();
        var elapsedTime = timeNow - installationTime;
        
        if (elapsedTime<TIME_BEFORE_LOCKING) {
            //System.println("timeNow="+timeNow+"  installationTime="+installationTime+"  elapsedTime="+elapsedTime+"   not elapsed, pas de logo");
            locked = false;
        } 
        else {
            //System.println("timeNow="+timeNow+"  installationTime="+installationTime+"  elapsedTime="+elapsedTime+"  elapsed, --> logo");
            locked = true;
        }       
	}


    function dessineTout(dc,fenetre_heures,thisIconFont,isInSetting) {
        var larg = dc.getHeight();
        var clockTime = System.getClockTime();
        dc.setColor(couleurFond,couleurFond);
        dc.clear();
        ProjectsWatchView.dessineHour(dc,clockTime,larg);
        ProjectsWatchView.dessineMinutes(dc,clockTime,larg);
        ProjectsWatchView.dessineFond(dc,larg,fenetre_heures);
        ProjectsWatchView.dessineChamps(dc,clockTime,larg,thisIconFont);
        if (! isInSetting) { dessineLockSiBesoin(dc,larg);}
		if ((! isAwake) && (larg>280)){ProjectsWatchView.quadrille(dc,larg);}
    }

    function dessineLockSiBesoin(dc,larg) {
        //System.println("dessineLockSiBesoin   locked = "+locked);
        if (locked) {
            dc.drawBitmap(0, .75*larg, myLogo);
            dc.drawText(0.5*larg,.4*larg,Graphics.FONT_TINY,"Read watchFace\ndescription please\nto remove Dudu logo",Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

	function quadrille(dc,larg) {
		var epaisseurNoir = 1;
		decalageY_OLED = (decalageY_OLED + 1) % (epaisseurNoir+1);
		decalageX_OLED = (decalageX_OLED + 1) % (epaisseurNoir+1);
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
		dc.setPenWidth(epaisseurNoir);
		for (var i = - decalageY_OLED - epaisseurNoir ; i <= larg + epaisseurNoir ; i=i+epaisseurNoir+1)	{
			dc.drawLine(0, i, larg, i);//horizontal
			//dc.drawLine(i, 0, i, larg);//vertical	
		}

	}


    function onEnterSleep() {
        isAwake = false;
        couleurFond = Graphics.COLOR_BLACK;
        couleurChiffresH = Graphics.COLOR_WHITE;
        couleurChiffresM = Graphics.COLOR_WHITE;
        System.println("ENTER sleep, couleur fond = "+couleurFond+"   param = "+params[BackGroundColor]);
    }

    function onExitSleep() {
        isAwake = true;
		couleurFond = Colors.colorValuesTab()[params[BackGroundColor]]; //sortie de veille pour OLED, il faut remettre la couleur
        couleurChiffresH = Colors.colorValuesTab()[params[HourColor]];
        couleurChiffresM = Colors.colorValuesTab()[params[MinutesColor]];
        System.println("EXIT sleep, couleur fond = "+couleurFond+"   param = "+params[BackGroundColor]);
        //WatchUi.requestUpdate();
    }


    function getParam(i) {
        var result;
        //System.println("lecture param num "+i);
        if ((i<=MinutesColor) || (i == Field1Color) || (i == Field2Color)|| (i == Field3Color)|| (i == Field4Color)){
            result = Colors.colorValuesTab()[params[i]];
        } else {
            result = params[i];
        }
        //System.println("param num "+i+" = "+result);
        return result;
    }


    function dessineFond(dc,larg,fenetre_heure) {
        var height = (130.0*larg/454).toNumber();
        //if (fenetre_heures != null) {dc.drawScaledBitmap(0,0, larg, height , fenetre_heures);}
        if (fenetre_heures != null) {dc.drawBitmap(0,0, fenetre_heures);}
        dc.setColor(couleurFond,couleurFond);
        dc.fillPolygon([[.767*larg,.134*larg],[.639*larg,.267*larg],[.705*larg,.551*larg],[larg,.57*larg]]);
        dc.fillPolygon([[.233*larg,.134*larg],[.361*larg,.267*larg],[.295*larg,.449*larg],[0,.57*larg]]);

        dc.setColor(ProjectsWatchView.getParam(PresentColor),Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawLine(larg*.5-1,larg*.05,larg*.5-1,larg*.55);

        var font = WatchUi.loadResource(Rez.Fonts.PresentPastFuture);
        if (font != null) {
            dc.drawText(0.48*larg,0.57*larg,font,"0",Graphics.TEXT_JUSTIFY_LEFT);//present
            dc.setColor(ProjectsWatchView.getParam(PastFutureColor),Graphics.COLOR_TRANSPARENT);
            dc.drawText(0.21*larg,0.218*larg,font,"1",Graphics.TEXT_JUSTIFY_LEFT);//past
            dc.drawText(0.6*larg,0.176*larg,font,"2",Graphics.TEXT_JUSTIFY_LEFT);//future
        }
    }

    function dessineHour(dc,clockTime,larg) {
        var fontList = [
            "RobotoRegular",
            "RobotoCondensedBold",
            "RobotoCondensedBold",
            "RobotoCondensedBold"
        ];
        var rayon = larg*.27 ;
        var siz = (70.0/454*larg).toNumber();
        //System.println("size h="+siz);
        var vectorFont = Graphics.getVectorFont({:face=>fontList, :size=>siz}); 
        //var vectorFont = Graphics.getVectorFont({:face=>fontList, :size=>siz ,:font=>Graphics.FONT_SMALL}); 
        //vectorFont = Graphics.getVectorFont({:face=>fontList, :size=>siz,:font=>Graphics.FONT_SMALL, :scale=>0.5});  
        var h =  clockTime.hour;
        var hMax = 24;
        if (! ProjectsWatchView.getParam(is24h)) {
            h = h % 12;
            hMax = 12;       
        }
        var hm1 = h-1;
        if (hm1<=0) {hm1 = hMax;}
        var hp1 = h+1;
        if (hp1 >hMax) {hp1 = 1;}
        var hp2 = hp1+1;
        if (hp2 >hMax) {hp2 = 1;}
        var hS = h.toString();
        //if (h<10) {hS = " "+h+" ";}
        var hm1S = hm1.toString();
        //if (hm1<10) {hm1S = " "+hm1+" ";}
        var hp1S = hp1.toString();
        //if (hp1<10) {hp1S = " "+hp1+" ";}
        var hp2S = hp2.toString();
        //if (hp2<10) {hp2S = " "+hp2+" ";}
        var esp = "  ";
        var text = hm1S+esp+hS+esp+hp1S+esp+hp2S;
        var hm1L = dc.getTextWidthInPixels(hm1S,vectorFont);
        var hL = dc.getTextWidthInPixels(hS,vectorFont);
        var hp1L = dc.getTextWidthInPixels(hp1S,vectorFont);
        var hp2L = dc.getTextWidthInPixels(hp2S,vectorFont);
        var espL = dc.getTextWidthInPixels(esp,vectorFont);
        var minutePourcent = clockTime.min/60.0;

        var arcDeCerclePixels = (hL/2 + espL + hp1L/2 ) * minutePourcent;
        var arcDeCercleTotalPixels = hm1L + espL + hL/2 + arcDeCerclePixels;
        
        var angleDeg = 90 + arcDeCercleTotalPixels / (2 * Math.PI * rayon) * 360;
        dc.setColor(couleurChiffresH,Graphics.COLOR_TRANSPARENT);
        dc.drawRadialText(larg/2, larg*.41, vectorFont, text, Graphics.TEXT_JUSTIFY_LEFT, angleDeg, rayon, Graphics.RADIAL_TEXT_DIRECTION_CLOCKWISE);  
    }

 
    function dessineMinutes(dc,clockTime,larg) {
        var fontList = [
            "RobotoRegular",
            "RobotoCondensedBold",
            "RobotoCondensedBold",
            "RobotoCondensedBold"
        ];
        var rayon = larg*.212 ;
        var siz = (30.0/454*larg).toNumber();
        //System.println("size m="+siz);
        var vectorFont = Graphics.getVectorFont({:face=>fontList, :size=>siz});  
        var minutes =  clockTime.min;
        var minuteMod = minutes % 5;
        var m = minutes - minuteMod;    
        var mm1 = m-5;
        if (mm1<0) {mm1 = 55;}
        var mp1 = m+5;
        if (mp1 >55) {mp1 = 0;}
        var mp2 = mp1+5;
        if (mp2 >55) {mp2 = 0;}
        var mS = m.toString();
        //if (m<10) {mS = " "+m+" ";}
        var mm1S = mm1.toString();
        //if (mm1<10) {mm1S = " "+mm1+" ";}
        var mp1S = mp1.toString();
        //if (mp1<10) {mp1S = " "+mp1+" ";}
        var mp2S = mp2.toString();
        //if (mp2<10) {mp2S = " "+mp2+" ";}
        var esp = "  ";
        var text = mm1S+esp+mS+esp+mp1S+esp+mp2S;
        var mm1L = dc.getTextWidthInPixels(mm1S,vectorFont);
        var mL = dc.getTextWidthInPixels(mS,vectorFont);
        var mp1L = dc.getTextWidthInPixels(mp1S,vectorFont);        
        var espL = dc.getTextWidthInPixels(esp,vectorFont);
        var secondesPourcent = minuteMod/5.0;

        var arcDeCerclePixels = (mL/2 + espL + mp1L/2 ) *secondesPourcent;
        var arcDeCercleTotalPixels = mm1L + espL + mL/2 + arcDeCerclePixels;

        var angleDeg = 90 + arcDeCercleTotalPixels / (2 * Math.PI * rayon) * 360;
        dc.setColor(couleurChiffresM,Graphics.COLOR_TRANSPARENT);
        dc.drawRadialText(larg/2, larg*.41, vectorFont, text, Graphics.TEXT_JUSTIFY_LEFT, angleDeg, rayon, Graphics.RADIAL_TEXT_DIRECTION_CLOCKWISE);  
        //dc.drawText(larg/2, larg*.6, Graphics.FONT_NUMBER_MILD, clockTime.hour+":"+clockTime.min+":"+clockTime.sec, Graphics.TEXT_JUSTIFY_CENTER);  
    }

    function dessineChamps(dc,clockTime,larg,thisIconFont) {
        var positions = [[.154,.4],[.28,.65],[.72,.65],[.757,.4]];
        var largeurHauteurIcon = 50*larg/454;
        for (var numParam = Field1 ; numParam<=Field4 ; numParam = numParam +2) {
            if (params[numParam] != 0) {
                var pos = (numParam-Field1) /2;
                var x = positions[pos][0]*larg;
                var y = positions[pos][1]*larg;
                dc.setColor(ProjectsWatchView.getParam(numParam+1),Graphics.COLOR_TRANSPARENT);
                if (params[numParam] < Seconds) { // dans ce cas il y a un icone a dessiner
                    var symbol = (params[numParam]+48).toChar().toString();
                    dc.drawText(x,y  ,thisIconFont,symbol,Graphics.TEXT_JUSTIFY_CENTER);    
                } else {
                    y = y - .05*larg;
                }
                var text = ProjectsWatchView.getFieldText(params[numParam],clockTime).toString();
                var f  = Graphics.FONT_SMALL;
                var longText = dc.getTextWidthInPixels(text, f);
                if (longText > larg * .25) {
                    f = Graphics.FONT_XTINY;
                }
                System.println("dessine champs "+pos+"   xy = "+x+ " "+y+"   --> "+text);
                dc.drawText(x,y + largeurHauteurIcon ,f,text,Graphics.TEXT_JUSTIFY_CENTER);   
            } 
        }
    }   

	function getFieldText(fieldType,clockTime) {
        var result = "N/A";
        if (fieldType == Nothing) {
            return "";
        }
		if (fieldType == Notifs)  {
            result = System.getDeviceSettings().notificationCount.format("%01d");
		}
		else if (fieldType==Battery) {
			result = System.getSystemStats().battery.format("%01d")+"%";
		}
		else if (fieldType==Steps)  {
			result =  ActivityMonitor.getInfo().steps.format("%01d");
		}
		else if (fieldType==Distance) {
			result =  (ActivityMonitor.getInfo().distance/100).format("%01d");
		}
		else if (fieldType==CurrentHeartRate) {
			var r = Activity.getActivityInfo().currentHeartRate;
			if ((r == null) && (Toybox has :SensorHistory) && (Toybox.SensorHistory has :getHeartRateHistory)) {
				r = Toybox.SensorHistory.getHeartRateHistory({:period=>1});
				if (r != null) { r = r.next().data;}
			}
			if (r != null) {
				result = r.toString();
			}
		}
		else if (fieldType==Altitude) {
			var r = Activity.getActivityInfo().altitude;
		//			if (r!=null){System.println("not history alt");}
			if ((r == null) && (Toybox has :SensorHistory) && (Toybox.SensorHistory has :getElevationHistory)) {
				r = Toybox.SensorHistory.getElevationHistory({:period=>1});
				if (r != null) { r = r.next().data;}
			}
			if (r != null) {
				var unit = 1;
				var unitstr = "m";
				if (System.getDeviceSettings().heightUnits != 0) {
					unit = 3.28084;
					unitstr = "ft";
				}
				result = (r*unit).format("%01d") +unitstr;
			}
		}
		else if (fieldType==Pressure) {
			var r;
			if (Activity.Info has :rawAmbientPressure) {
				r = Activity.getActivityInfo().rawAmbientPressure;
			}
			if ((r == null) && (Toybox has :SensorHistory) && (Toybox.SensorHistory has :getPressureHistory)) {
				r = Toybox.SensorHistory.getPressureHistory({:period=>1});
				if (r != null) { r = r.next().data;}
				}
			if (r != null) {
				result = (r/100).format("%1.2f") ;
			}
		}
		else if (fieldType==Floor) {
			if  (ActivityMonitor.Info has :floorsClimbed) {
				result =  ActivityMonitor.getInfo().floorsClimbed;}
		}
		else if (fieldType==Calories) {
			if  (ActivityMonitor.Info has :calories) {
				result =  ActivityMonitor.getInfo().calories;}
		}
		else if (fieldType==Temper) {
			if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getTemperatureHistory)) {
				var temp = Toybox.SensorHistory.getTemperatureHistory({:period=>1}).next().data;
				if (temp != null) {
					if (System.getDeviceSettings().temperatureUnits == System.UNIT_METRIC) {
						result = temp.format("%01d")+" C";
					} else {
						result = (temp*1.8+32).format("%01d")+" F";
					}
				}
			}
		}
		else if (fieldType==TimeToRecovery) {
			if  (ActivityMonitor.getInfo() has :timeToRecovery) {
				result =  ActivityMonitor.getInfo().timeToRecovery+" h";
			}
		}
		else if (fieldType==BodyBattery) {
			var r;
			if  (Toybox.SensorHistory has :getBodyBatteryHistory) {
				r =  Toybox.SensorHistory.getBodyBatteryHistory({:period=>1}).next();
				if (r != null) {result = r.data.toNumber();}
			}
		}
		else if (fieldType==ActiveMinutesDay) {
			if  (ActivityMonitor.getInfo() has :activeMinutesDay) {
				result =  ActivityMonitor.getInfo().activeMinutesDay.total + " min" ;
			}
		}
		else if (fieldType==ActiveMinutesWeek) {
			if  (ActivityMonitor.getInfo() has :activeMinutesWeek) {
				result =  ActivityMonitor.getInfo().activeMinutesWeek.total + " min";
			}
		}
		else if (fieldType==TempExt) {
			if  (Toybox has :Weather) {
				var CC = Weather.getCurrentConditions();
				if (CC != null) {
					var temper = CC.temperature;
					if ((temper != null) && (System.getDeviceSettings().temperatureUnits == System.UNIT_METRIC)) {
						result = temper.format("%01d")+" C";
					} else if  (temper != null) {
						result = (temper*1.8+32.0).format("%01d")+" F";
					}
				}
			}
		}

		else if (fieldType==Seconds)  {
			result =  clockTime.sec;
		}			
		else if (fieldType == Digital_Time) {
            var form = "%02d";
            var h = clockTime.hour;
            if (! params[is24h]) {
                h = h % 12;
                form = "%01d";
            }
            result = h.format(form)+":"+clockTime.min.format("%02d");
		}
		else if (fieldType==MoisJour)  {
            var today = Toybox.Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
			result = MOIS[today.month] + " "+today.day;
		}			
		else if (fieldType==JourMois)  {
            var today = Toybox.Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
			result = today.day + " "+MOIS[today.month];
		}			
		else if (fieldType==JourSem)  {
            var today = Toybox.Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
			result = DAYOFWEEK[today.day_of_week];
		}			
		else if (fieldType==JourSemJour)  {
            var today = Toybox.Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
			result = DAYOFWEEK[today.day_of_week]+ " "+today.day;
		}			
		else if (fieldType==JourSemMoisJour)  {
            var today = Toybox.Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
			result = DAYOFWEEK[today.day_of_week];
			if (result.equals("Dim")) { // si langue française on inverse mois et jour
				    result = result+"\n" + today.day.format("%02d") + "/"+ today.month.format("%02d");
				}		
                else {
                    result = result+"\n" + today.month.format("%02d")+"/"+today.day; 
                }				
		}			
		else if (fieldType==Week_number)  {
            var today = Toybox.Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
			result = ProjectsWatchView.iso_week_number(today.year, today.month, today.day);
		}			
        //System.println("get field text FieldType = "+fieldType+"   valeur = "+result);
		return result;
	}	



    function iso_week_number(year, month, day)	{
	    var first_day_of_year = ProjectsWatchView.julian_day(year, 1, 1);
	    var given_day_of_year = ProjectsWatchView.julian_day(year, month, day);

	    var day_of_week = (first_day_of_year + 3) % 7; // days past thursday
	    var week_of_year = (given_day_of_year - first_day_of_year + day_of_week + 4) / 7;
    	// week is at end of this year or the beginning of next year
        System.println("first_day_of_year "+first_day_of_year);
        System.println("given_day_of_year "+given_day_of_year);
        System.println("day_of_week "+day_of_week);
        System.println("week_of_year "+week_of_year);
	    if (week_of_year == 53) {
	        if (day_of_week == 6) {
	            return week_of_year;
	        }
	        else if (day_of_week == 5 && ProjectsWatchView.is_leap_year(year)) {
	            return week_of_year;
 	       }
 	       else {
 	           return 1;
	        }
	    }
    	// week is in previous year, try again under that year
	    else if (week_of_year == 0) {
	        first_day_of_year = ProjectsWatchView.julian_day(year - 1, 1, 1);
	        day_of_week = (first_day_of_year + 3) % 7;
	        return (given_day_of_year - first_day_of_year + day_of_week + 4) / 7;
	    }

    	// any old week of the year
	    else {
	        return week_of_year;
 	   }
    }

    function is_leap_year(year) {
	    if (year % 4 != 0)  {
	        return false;
	    }
	    else if (year % 100 != 0) {
	        return true;
	    }
	    else if (year % 400 == 0) {
	        return true;
	    }
	    return false;
	}

    function julian_day(year, month, day) {
    	var a = (14 - month) / 12;
	    var y = (year + 4800 - a);
	    var m = (month + 12 * a - 3);
	    return day + ((153 * m + 2) / 5) + (365 * y) + (y / 4) - (y / 100) + (y / 400) - 32045;
	}




}
