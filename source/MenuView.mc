
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;
import Toybox.Lang;


class MenuView extends Ui.View {
var titre;
var tabLignesMenu;
var tailleFont;
var item;
var justif;
var sautDeLigne;

//var tabModif;
var nbreTotalElements;
var nbreCar;
var x;
var item0;

var hFont;
var hLigne;
var nbreAff,nbreLignesDispoAffichage;
var L;
var itemString;

    function initialize(_titre as String,_tabLignesMenu as Array,_tailleFont as Integer,_item as Integer,_left as Boolean,_sautDeLigne  as Boolean) {
		View.initialize();
    	tabLignesMenu = _tabLignesMenu;
		titre = _titre;					// tab of strings  = lines of the menu
    	tailleFont = _tailleFont;  //size of the font
    	justif = _left ? Gfx.TEXT_JUSTIFY_LEFT : Gfx.TEXT_JUSTIFY_CENTER;				// true s'il faut aligner   gauche, sinon au centre
    	item = _item;

		sautDeLigne = _sautDeLigne;
    	nbreTotalElements = tabLignesMenu.size();		// number of items in the menu
		if (item>nbreTotalElements) {item = nbreTotalElements;}				// 1er affich 
		//L = System.getDeviceSettings().screenWidth ;
		nbreAff = 0;
		L = System.getDeviceSettings().screenWidth ;
		itemString = tabLignesMenu[item];
		
    }



    function onLayout(dc) {
		nbreCar = L/dc.getTextWidthInPixels("mjlnMili",tailleFont) * 10;
		//tabModif = prepareTab(tab);
		prepareTab();
		if (sautDeLigne) {titre = ajoutSautDeLigne(supprimeSautDeLigne(titre),nbreCar/2-3,false);}
		prepareHauteurs();
		calculeItem0(0);
		if (justif == Gfx.TEXT_JUSTIFY_LEFT) {
			x = L/10;
			}
		else {
			x = L/2;
		}
		if (Toybox.Graphics has :BufferedBitmap) {dc.clearClip();}
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    }

	function prepareHauteurs() {
		hFont = Gfx.getFontHeight(tailleFont);
		hLigne = 0.9*hFont;
		var hTitre = hFont+5;
		if (isRC(titre)) {hTitre = hTitre + hFont;}
		var hDispo = L
		-hTitre;
		nbreLignesDispoAffichage = hDispo/hFont;
		item0 = 0;

	}
	function prepareTab() {
		if (sautDeLigne ) {
			for (var i=0;i<tabLignesMenu.size();i++) {
				var st = supprimeSautDeLigne(tabLignesMenu[i]);
				st = ajoutSautDeLigne(st,nbreCar,true);
				tabLignesMenu[i] = st;
			}
		}
	}

	function ajoutSautDeLigne(mySt,nbreCarSaut,diminueNbre) {
		//System.print("ajoutsautdeligne nbre= "+nbre+"  "+mySt);
		if (mySt.length() > nbreCarSaut)  {
			var numero = mySt.substring(nbreCarSaut, mySt.length()).find(" ");
			if (numero != null)  {
				mySt = mySt.substring(0, nbreCarSaut+numero) + "\n" + mySt.substring(nbreCarSaut+numero+1,mySt.length());
			} else  {
				var newnbre = (nbreCarSaut*0.5).toNumber();
				numero = mySt.substring(newnbre, mySt.length()).find(" ");
				if (numero != null) {
					mySt = mySt.substring(0, newnbre+numero) + "\n" + mySt.substring(newnbre+numero+1,mySt.length());
				}
			}
		} 
		return mySt;
	}

	function supprimeSautDeLigne(st) {
        var sautDejaMis = st.find("\n");
		if (sautDejaMis != null) {
			st = st.substring(0, sautDejaMis) + " "+ st.substring(sautDejaMis+1,st.length());
		}
		return st;
	}


	function isRC(st) {
		return st.find("\n");
	}

	function modifie(texte) {
        var sautDejaMis = texte.find("\n");
		return[texte.substring(0, sautDejaMis),texte.substring(sautDejaMis+1,texte.length())];
	}

	function testeRCAndDrawLabel(dc,x, y, font, texte , justif) {
		y = y -(hFont-hLigne)*0.8;
		if (isRC(texte) ) {
			var texteb = modifie(texte);
			dc.drawText(x,y,font,texteb[0],justif);
			dc.drawText(x,y+hLigne,font,texteb[1],justif);
			return true;		
		} else {
			dc.drawText(x,y,font,texte,justif);
			return false;
		}

	}

    function onUpdate(dc) {
    	var y;
		var coulFond = Gfx.COLOR_BLACK;
		var coulPP = Gfx.COLOR_WHITE;
	    dc.setColor(coulPP, coulFond );
		dc.clear();
		dc.setPenWidth(3);

		//Title
		if (isRC(titre)) {y = hFont * 2 +5;}
		else {y = hFont+5;}			
		dc.setColor( coulPP, Gfx.COLOR_TRANSPARENT );
		dc.fillRectangle(0, 0, L, y-2);
		dc.setColor( coulFond, Gfx.COLOR_TRANSPARENT );
		dc.drawText(L/2, y/2, tailleFont, titre, Gfx.TEXT_JUSTIFY_CENTER+Gfx.TEXT_JUSTIFY_VCENTER); 

		// lignes 
		dc.setColor( coulPP, Gfx.COLOR_TRANSPARENT );
		for (var i=item0;i<=item0+nbreAff-1;i++) {
			if (i==item) {
				dc.fillRectangle(0,y,L,hLigne);
				if (isRC(tabLignesMenu[i])) { dc.fillRectangle(0,y+hLigne,L,hLigne);}
				dc.setColor( coulFond,Gfx.COLOR_TRANSPARENT );
			}
			if (testeRCAndDrawLabel(dc,x, y, tailleFont, tabLignesMenu[i] , justif)) {y = y + hLigne;} // saut de ligne si ligne double
			dc.setColor( coulPP, Gfx.COLOR_TRANSPARENT );
			//if (isRC(tabModif[i])) {y = y + hLigne;}  // saut de ligne si ligne double
			y = y + hLigne;
			if (i!=item) {dc.drawLine(0,y,L,y);}
		}
		
		if (item0+nbreAff < nbreTotalElements) {
			if (testeRCAndDrawLabel(dc,x, y, tailleFont, tabLignesMenu[item0+nbreAff] , justif)) {y = y + hLigne;}
			//if (isRC(tabModif[item0+nbreAff])) {y = y + hLigne;}
			
		}
		if (item0+nbreAff+1 < nbreTotalElements) {
			dc.drawLine(0,y+ hFont,L,y+ hFont);
			y = y + hLigne;
			testeRCAndDrawLabel(dc,x, y, tailleFont, tabLignesMenu[item0+nbreAff+1] , justif);
		}
		
	}
//item0 = celui du haut
//item  = celui selectionné
	function calculeItem0(delta){
		nbreAff = nbreLignesDispoAffichage;
		//System.println("");
		//System.println("calculeItem0("+delta+")"+ "  nbreAff="+nbreAff+"   tab size="+nbreTotalElements);
		//System.print("    ITEM--->"+item);
		item = (item + delta + nbreTotalElements) % (nbreTotalElements);
		itemString = tabLignesMenu[item];
		//System.println("--->"+item);
		if (nbreAff>nbreTotalElements) {
			nbreAff = nbreTotalElements;
		}


		//System.print("ITEM0  --->"+item0);
		if (item0>item) {item0=item;}
		if (item>item0+nbreAff) {item0=item-nbreAff;}
		//System.println("--->"+item0);

		//System.print("nbreAff="+nbreAff);
		for (var i=item0;i<=item0+nbreAff-1;i++) {
			if (i>=nbreTotalElements) {break;}
			if (isRC(tabLignesMenu[i])) {
				nbreAff --;
				i++;
			}
		}
		//System.print("----un--->"+nbreAff);
		if ((item0+nbreAff>=nbreTotalElements) && (nbreAff>nbreTotalElements)){
			nbreAff = nbreTotalElements-item0-1;
			}
		//System.println("------->"+nbreAff);

		//System.print("ITEM0  --->"+item0);
		if (item>item0+nbreAff-1) {
			item0=item-nbreAff+1;
		}
		//System.print("----un--->"+item0);
		if (item<item0) {
			item0=item;
		}
		//System.print("----deux--->"+item0);
		if (item0+nbreAff>nbreTotalElements)  {
			item0=item0-1;
		}
		//System.println("----trois-->"+item0);
	}

	
	function prev() {
		calculeItem0(-1);
		Ui.requestUpdate();
	}

    function next() {
		calculeItem0(1);
		Ui.requestUpdate();
	}


}
