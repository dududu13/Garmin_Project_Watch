import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class ProjectsWatchView extends WatchUi.WatchFace {
    
	var decalageY_OLED = 0;  // pour changement de place en mode low power sur les AMOLED
	var decalageX_OLED = 0;  // pour changement de place en mode low power sur les AMOLED
    var fenetre_heures;

    function initialize() {
        WatchFace.initialize();
        if (ParametresChanges) {
            loadParams();
        }
    
    }
    function onShow() {
        fenetre_heures = WatchUi.loadResource(Rez.Drawables.fenetre_heures);
    }


    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);
        dessineTout(dc,fenetre_heures);
    }

    function loadParams() {
        params = [4, 33, 14, 3, 1, 19, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 0, 0, true];
        for (var i = 0 ; i < params.size() ; i++) {
            var value = Application.Storage.getValue("Params"+i);
            if (value != null) {params[i] = value;}
        }
        couleurFond = Colors.colorValuesTab()[params[BackGroundColor]];
        couleurChiffresH = Colors.colorValuesTab()[params[HourColor]];
        couleurChiffresM = Colors.colorValuesTab()[params[MinutesColor]];
        ParametresChanges = false;
    }

    function dessineTout(dc,fenetre_heures) {
        var larg = dc.getHeight();
        var clockTime = System.getClockTime();
        dc.setColor(couleurFond,couleurFond);
        dc.clear();
        ProjectsWatchView.dessineHour(dc,clockTime,larg);
        ProjectsWatchView.dessineMinutes(dc,clockTime,larg);
        ProjectsWatchView.dessineFond(dc,larg,fenetre_heures);
		if ((! isAwake) && (larg>280)){
            ProjectsWatchView.quadrille(dc,larg);
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
        if (i<Field1) {
            return Colors.colorValuesTab()[params[i]];
        } else {
            return params[i];
        }
    }


    function dessineFond(dc,larg,fenetre_heure) {
        var height = (130.0*larg/454).toNumber();
        if (fenetre_heures != null) {dc.drawScaledBitmap(0,0, larg, height , fenetre_heures);}
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

    function dessineChamps(dc,clockTime,larg) {
        var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
        var x = .2;
        var y = .4;
        dc.setColor(ProjectsWatchView.getParam(Field1Color),Graphics.COLOR_TRANSPARENT);
        for (var i=0;i<2;i++) {
            var xx = x * larg;
            for (var j=0;j<3;j++) {
                var yy = y * larg;
                var text = "ij="+i+" "+j;
                dc.drawText(xx,yy,Graphics.FONT_SMALL,text,Graphics.TEXT_JUSTIFY_CENTER);
                y = y+0.2;
                if (x ==.2) {xx = xx+.05*larg;}
                else {xx = xx-.05*larg;}
            }
            x = .8;
            y = .4;
            //System.println("xx="+xx);
        }
    }


}
