using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;


class SettingsAnalogView extends Ui.View {

	var numParametre;
	var element_promptTab;
	var titre;
	var numEnCours;
    var largEcran;
	var largIndicateur;

    function initialize(_numParametre,_element_promptTab,_titre) {
    	numEnCours = params[_numParametre];
		numParametre = _numParametre; //numero parametre en cours de modif
		element_promptTab = _element_promptTab; //liste des choix possibles en texte
		titre = _titre;
		ProjectsWatchView.loadParams(false);
		var divis = 180;
		if (element_promptTab.size()>15) {divis = 360;}
		largIndicateur = divis.toFloat()/(element_promptTab.size());
		View.initialize();
	}

    function onUpdate(dc) {
		couleurFond = Colors.colorValuesTab()[params[0]];
        couleurChiffresH = Colors.colorValuesTab()[params[HourColor]];
        couleurChiffresM = Colors.colorValuesTab()[params[MinutesColor]];
        largEcran = dc.getHeight();
		ProjectsWatchView.dessineTout(dc,true);
		dessineIndicateur(dc);
	}

	function dessineIndicateur(dc) {
		var couleurIndicateur = (couleurFond == Graphics.COLOR_GREEN) ? Graphics.COLOR_RED : Graphics.COLOR_GREEN; // couleur de l'arc ---> verte, sauf si le fond est en vert ---> rouge
		dc.setColor(couleurIndicateur, Gfx.COLOR_TRANSPARENT);
		dc.drawText(largEcran/2,largEcran *.35,Gfx.FONT_SMALL,titre,Gfx.TEXT_JUSTIFY_CENTER);
		dc.drawText(largEcran/2,largEcran *.45,Gfx.FONT_SMALL,element_promptTab[numEnCours],Gfx.TEXT_JUSTIFY_CENTER);
		var degreeStart = numEnCours*largIndicateur+90;
		var degreeEnd = (numEnCours+1)*largIndicateur+90;
		dc.setPenWidth(10);
		dc.drawArc(largEcran/2, largEcran/2, largEcran/2-5, 0, degreeStart , degreeEnd);
		dc.setPenWidth(1);
	}

	function prev() {
		numEnCours = (numEnCours+element_promptTab.size()-1) % (element_promptTab.size());
		params[numParametre] = numEnCours;
		Ui.requestUpdate();
	}

    function next() {
		numEnCours = (numEnCours+element_promptTab.size()+1) % (element_promptTab.size());
		params[numParametre] = numEnCours;
		Ui.requestUpdate();
	}


}


class AnalogSettingsDelegate extends Ui.InputDelegate {
    var setttingAnalogView;
    var numParametre;
	var oldParams;


    function initialize(_setttingAnalogView,_numParametre) {
    	InputDelegate.initialize();
    	numParametre = _numParametre;
        setttingAnalogView = _setttingAnalogView;
		oldParams = [];
		for (var i=0;i<params.size();i++) {
			oldParams.add(params[i]);
		}
        
    }


    function onSelect()    {
        var valeurChoisie = setttingAnalogView.numEnCours;
        System.println("valeurChoisie "+valeurChoisie);
        params[numParametre] = valeurChoisie;
        //App.Properties.setValue("param"+numParametre, params[numParametre]);
        Ui.popView(Ui.SLIDE_RIGHT);
        //Ui.requestUpdate();
    }


    function onBack()    {
        if (oldParams != null) {
            System.println("onBack   oldParams = "+oldParams);
            params = oldParams;
            oldParams = null;
        }
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        //Ui.requestUpdate();
        return true;
    }

 

	function onTap(clickEvent) {
        return onSelect();
    }

    function onSwipe(evt) {
		var direction = evt.getDirection();
		if (direction == Ui.SWIPE_DOWN) {
			return onPreviousPage();
		}
		if (direction == Ui.SWIPE_UP) {
			return onNextPage();
		}
		if (direction == Ui.SWIPE_RIGHT) {
			return onBack();
		}
        return true;
    }
	function onKey(keyEvent) {
         if (keyEvent.getKey() == keyEvent.KEY_ENTER || keyEvent.getKey() == keyEvent.KEY_START) {
            return onSelect();
        }
        else if (keyEvent.getKey() == keyEvent.KEY_UP) {
            return onPreviousPage();
        }
        else if (keyEvent.getKey() == keyEvent.KEY_DOWN) {
            return onNextPage();
        }
        else if (keyEvent.getKey() == keyEvent.KEY_ESC) {
            return onBack();
        }
       return true;
    }
    
    function onNextPage()    {
    	setttingAnalogView.next();
    }
    
    function onPreviousPage() 	{
    	setttingAnalogView.prev();
	}    


}