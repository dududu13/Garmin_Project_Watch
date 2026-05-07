using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;


class SettingsAnalogView extends Ui.View {

	var numParametre;
	var element_promptTab;
	var titre;
	var numEnCours;
	var item;
	var clock;
    var largEcran;
	var largIndicateur;
	var fenetre_heures;
	var itemString;


    function initialize(_numParametre,_element_promptTab,_titre) {
    	numEnCours = params[_numParametre];
		numParametre = _numParametre; //numero parametre en cours de modif
		element_promptTab = _element_promptTab; //liste des choix possibles en texte
		titre = _titre;
		//if (numParametre == BackGroundColor) {_nbre = _nbre-1;} // pas de transparence pour la couleur background
		couleurFond = params[BackGroundColor];
		//item = convertiParamEnValeur(_numParametre);  // numero en cours 
		item = 10 + numEnCours;
		fenetre_heures = WatchUi.loadResource(Rez.Drawables.fenetre_heures);
		itemString = "";
		var divis = 180;
		if (element_promptTab.size()>15) {divis = 360;}
		largIndicateur = divis.toFloat()/(element_promptTab.size());
		View.initialize();
	}

    function onUpdate(dc) {
		clock = Sys.getClockTime();
        largEcran = dc.getHeight();
		ProjectsWatchView.dessineTout(dc,fenetre_heures);
		dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
		System.println("element_promptTab "+element_promptTab+"  numEnCours "+numEnCours);
		dc.drawText(largEcran/2,largEcran/2*.35,Gfx.FONT_SMALL,element_promptTab[numEnCours],Gfx.TEXT_JUSTIFY_CENTER);
		dc.drawText(largEcran/2,largEcran/2*.15,Gfx.FONT_SMALL,titre,Gfx.TEXT_JUSTIFY_CENTER);
		dessineIndicateurAnalogique(dc);
	}

	

	function dessineIndicateurAnalogique(dc) {
		var degreeStart = numEnCours*largIndicateur+90;
		var degreeEnd = (numEnCours+1)*largIndicateur+90;
		var couleurArc = (couleurFond != Graphics.COLOR_GREEN) ? Graphics.COLOR_GREEN : Graphics.COLOR_RED; // couleur de l'arc ---> verte, sauf si le fond est en vert ---> rouge
		couleurArc = Graphics.COLOR_GREEN; // couleur de l'arc ---> verte, sauf si le fond est en vert ---> rouge
		dc.setColor(couleurArc, Gfx.COLOR_TRANSPARENT);
		dc.setPenWidth(10);
		dc.drawArc(largEcran/2, largEcran/2, largEcran/2-5, 0, degreeStart , degreeEnd);
		dc.setPenWidth(1);
	}

	function prev() {
		numEnCours = (numEnCours+element_promptTab.size()-1) % (element_promptTab.size());
		item = 10 + numEnCours;
		Ui.requestUpdate();
	}

    function next() {
		numEnCours = (numEnCours+element_promptTab.size()+1) % (element_promptTab.size());
		item = 10 + numEnCours;
		Ui.requestUpdate();
	}


}