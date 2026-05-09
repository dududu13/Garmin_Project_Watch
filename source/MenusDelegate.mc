
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;


class MenusDelegate extends Ui.InputDelegate {
    var setttingAnalogView;

    function menuPrincipalTab() {
        var tab = [
            "BackGround Color", //0
            "Present Color",//1
            "PastFuture Color",//2
            "Hour Color",//4
            "Minutes Color"//5
        ];
        var display12 = "Display -> 12h";
        var display24 = "Display -> 24h";
        if (params[is24h]) {tab.add(display12);}
        else {tab.add(display24);}
        return tab;
        
    }

    var menuView;


    function initialize(_menuView) {
    	InputDelegate.initialize();
    	menuView = _menuView;
        
    }


    function onSelect()    {
        var parametre = menuView.item;
        System.println("parametre "+parametre);
        if ((parametre >=0) && (parametre <= MinutesColor)){
            var colorsNames = Colors.colorsNames();
            if (parametre == BackGroundColor) {colorsNames.remove("Transparent");} //pas de transparence pour le background
            setttingAnalogView = new SettingsAnalogView(parametre,colorsNames,menuPrincipalTab()[parametre]);
            Ui.pushView(setttingAnalogView, new AnalogSettingsDelegate(setttingAnalogView,parametre), Ui.SLIDE_RIGHT);
        } else if (parametre == MinutesColor+1)   {
            params[is24h] = ! params[is24h];
            App.Storage.setValue("Params"+is24h, params[is24h]);
            var display12 = "Display -> 12h";
            var display24 = "Display -> 24h";
            menuView.itemString = params[is24h] ? display12 : display24;
            menuView.tabLignesMenu[parametre] = params[is24h] ? display12 : display24;
        }
        
        Ui.requestUpdate();
    }


    function onBack()    {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        Ui.requestUpdate();
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
    	menuView.next();
    }
    
    function onPreviousPage() 	{
    	menuView.prev();
	}    


}

class AnalogSettingsDelegate extends Ui.InputDelegate {
    var setttingAnalogView;
    var numParametre;


    function initialize(_setttingAnalogView,_numParametre) {
    	InputDelegate.initialize();
    	numParametre = _numParametre;
        setttingAnalogView = _setttingAnalogView;
        
    }


    function onSelect()    {
        var colorNum = setttingAnalogView.numEnCours;
        System.println("colorNum "+colorNum);
        System.println("save  numParam "+numParametre+"  color "+params[numParametre]+"--->"+colorNum);
        params[numParametre] = colorNum;
        App.Storage.setValue("Params"+numParametre, colorNum);
        couleurFond = Colors.colorValuesTab()[params[0]];
        Ui.popView(Ui.SLIDE_RIGHT);
        Ui.requestUpdate();
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

