using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;


class SettingsAnalogView extends Ui.View {

	var numParametre;
	var element_promptTab;
	var titre;
	var numEnCours;
	var item;
	//var clock;
    var largEcran;
	var largIndicateur;
	var fenetre_heures;
	//var oldParams;




    function initialize(_numParametre,_element_promptTab,_titre) {
		oldParams = [];
		for (var i=0;i<params.size();i++) {
			oldParams.add(params[i]);
		}
    	numEnCours = params[_numParametre];
		numParametre = _numParametre; //numero parametre en cours de modif
		element_promptTab = _element_promptTab; //liste des choix possibles en texte
		titre = _titre;
		couleurFond = Colors.colorValuesTab()[params[0]];
		item = 10 + numEnCours;
		fenetre_heures = WatchUi.loadResource(Rez.Drawables.fenetre_heures);
		var divis = 180;
		if (element_promptTab.size()>15) {divis = 360;}
		largIndicateur = divis.toFloat()/(element_promptTab.size());
		View.initialize();
	}

    function onUpdate(dc) {
		couleurFond = Colors.colorValuesTab()[params[0]];
        largEcran = dc.getHeight();
		ProjectsWatchView.dessineTout(dc,fenetre_heures);
		var couleur = (couleurFond == Graphics.COLOR_GREEN) ? Graphics.COLOR_RED : Graphics.COLOR_GREEN; // couleur de l'arc ---> verte, sauf si le fond est en vert ---> rouge
		dc.setColor(couleur, Gfx.COLOR_TRANSPARENT);
		//System.println("element_promptTab "+element_promptTab+"  numEnCours "+numEnCours);
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
		item = 10 + numEnCours;
		params[numParametre] = numEnCours;
		Ui.requestUpdate();
	}

    function next() {
		numEnCours = (numEnCours+element_promptTab.size()+1) % (element_promptTab.size());
		item = 10 + numEnCours;
		params[numParametre] = numEnCours;
		Ui.requestUpdate();
	}


}