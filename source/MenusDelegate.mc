
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;


class MenusDelegate extends Ui.InputDelegate {

    function menuPrincipalTab() {
        var tab = [
            "BackGround Color", //0
            "Present Color",//1
            "PastFuture Color",//2
            "Hour Color",//4
            "Minutes Color",
       ];
        var display12 = "Display -> 12h";
        var display24 = "Display -> 24h";
        if (params[is24h]) {tab.add(display12);}
        else {tab.add(display24);}
        tab.add("Fields");
        tab.add("BG source");
        tab.add("Unlock code");
        return tab;
    }

    function menuFieldsTab() {
        var tab = [
            "Left up field data",//1
            "Left up field color", //0
            "Left down field data",//1
            "Left down field color", //0
            "Right down field data",//1
            "Right down field color", //0
            "Right up field data",//1
            "Right up field color", //0
        ];
        return tab;

    }
    function menuBGTab() {
        var tab = [
            "Nigthscout", 
            "AAPS",
            "Xdrip" 
        ];
        return tab;

    }

    var setttingAnalogView;
    var menuView;
    var item_menu_fields;


    function initialize(_menuView) {
    	InputDelegate.initialize();
    	menuView = _menuView;
    }


    function onSelect()    {
        var item = menuView.item;
        System.println("parametre "+item);
        if (item <= MinutesColor) {
            var colorsNames = Colors.colorsNames();
            if (item == BackGroundColor) {colorsNames.remove("Transparent");} //pas de transparence pour le background
            setttingAnalogView = new SettingsAnalogView(item,colorsNames,menuPrincipalTab()[item]);
            Ui.pushView(setttingAnalogView, new AnalogSettingsDelegate(setttingAnalogView,item), Ui.SLIDE_RIGHT);
        } else if (item == is24h)   { //is24h
            params[is24h] = ! params[is24h];
            App.Storage.setValue("Params"+is24h, params[is24h]);
            var display12 = "Display -> 12h";
            var display24 = "Display -> 24h";
            menuView.itemString = params[is24h] ? display12 : display24;
            menuView.tabLignesMenu[item] = params[is24h] ? display12 : display24;
        } else  if (item == Field1) { //fields
            var menuView = new MenuView("Fields",MenusDelegate.menuFieldsTab(),2, 0,true,true);
            Ui.pushView(menuView, new MenusFieldsDelegate(menuView,item), Ui.SLIDE_RIGHT);
        } else  if (item == Field1+1) { //source BG
            var menuView = new MenuView("BG source",MenusDelegate.menuBGTab(),3, params[sourceBG],true,true);
            Ui.pushView(menuView, new MenusBGDelegate(menuView,item), Ui.SLIDE_RIGHT);
        } else  if (item == Field1+2+1) { //Code
            var code_a_modifier = Application.Properties.getValue("code");
            var view = new KeyboardView(code_a_modifier,null);
            Ui.pushView(view, new KeyboardDelegate(view,code_a_modifier), Ui.SLIDE_RIGHT);
       }
        
        Ui.requestUpdate();
    }


    function onBack()    {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        Ui.requestUpdate();
        ParametresChanges = true;
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

class MenusFieldsDelegate extends Ui.InputDelegate {
    function fieldTypeList() {
        var tab = [];
            tab.add(WatchUi.loadResource(Rez.Strings.Nothing));
            tab.add(WatchUi.loadResource(Rez.Strings.Battery));
            tab.add(WatchUi.loadResource(Rez.Strings.Steps));
            tab.add(WatchUi.loadResource(Rez.Strings.Distance));
            tab.add(WatchUi.loadResource(Rez.Strings.Notifs));
            tab.add(WatchUi.loadResource(Rez.Strings.Altitude));
            tab.add(WatchUi.loadResource(Rez.Strings.Pressure));
            tab.add(WatchUi.loadResource(Rez.Strings.Floor));
            tab.add(WatchUi.loadResource(Rez.Strings.Temper));
            tab.add(WatchUi.loadResource(Rez.Strings.TempExt));
            tab.add(WatchUi.loadResource(Rez.Strings.Calories));
            tab.add(WatchUi.loadResource(Rez.Strings.CurrentHeartRate));
            tab.add(WatchUi.loadResource(Rez.Strings.TimeToRecovery));
            tab.add(WatchUi.loadResource(Rez.Strings.BodyBattery));
            tab.add(WatchUi.loadResource(Rez.Strings.ActiveMinutesDay));
            tab.add(WatchUi.loadResource(Rez.Strings.ActiveMinutesWeek));
            tab.add(WatchUi.loadResource(Rez.Strings.BloodGlucose));
            tab.add(WatchUi.loadResource(Rez.Strings.Seconds));
            tab.add(WatchUi.loadResource(Rez.Strings.Digital_Time));
            tab.add(WatchUi.loadResource(Rez.Strings.MoisJour));
            tab.add(WatchUi.loadResource(Rez.Strings.JourMois));
            tab.add(WatchUi.loadResource(Rez.Strings.JourSem));
            tab.add(WatchUi.loadResource(Rez.Strings.JourSemJour));
            tab.add(WatchUi.loadResource(Rez.Strings.JourSemMoisJour));
            tab.add(WatchUi.loadResource(Rez.Strings.Week_number));
            return tab;
        }

    var setttingAnalogView;
    var menuView;
    var numParam;


    function initialize(_menuView,_numParam) {
    	InputDelegate.initialize();
    	menuView = _menuView;
        numParam = _numParam;
        
    }


    function onSelect()    {
        var item = menuView.item;
        numParam = item + Field1;
        var numfield = item / 2;
        var isColor = ((item % 2) == 1);
        System.println("item = "+item+"   num param = "+numParam+"   numfield = "+numfield+"  iscolor ? " + isColor);
        if (isColor) { //field color
            var colorsNames = Colors.colorsNames();
            colorsNames.remove("Transparent"); //pas de transparence pour les champs
            setttingAnalogView = new SettingsAnalogView(numParam,colorsNames,"Field color");
            Ui.pushView(setttingAnalogView, new AnalogSettingsDelegate(setttingAnalogView,numParam), Ui.SLIDE_RIGHT);
        } else   { //field type
            setttingAnalogView = new SettingsAnalogView(numParam,fieldTypeList(),"Field data");
            Ui.pushView(setttingAnalogView, new AnalogSettingsDelegate(setttingAnalogView,numParam), Ui.SLIDE_RIGHT);
        }
        Ui.requestUpdate();
    }


    function onBack()    {
        //menuView.item_menu_fields = 
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



class MenusBGDelegate extends Ui.InputDelegate {

    var setttingAnalogView;
    var menuView;
    var numParam;


    function initialize(_menuView,_numParam) {
    	InputDelegate.initialize();
    	menuView = _menuView;
        numParam = _numParam;
        
    }

    function onSelect()    {
        var item = menuView.item;
        params[sourceBG] = item;
        Application.Storage.setValue("Params"+sourceBG,item);
        Ui.popView(Ui.SLIDE_IMMEDIATE);
    }


    function onBack()    {
        //menuView.item_menu_fields = 
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
        var valeurChoisie = setttingAnalogView.numEnCours;
        System.println("valeurChoisie "+valeurChoisie);
        System.println("save  numParam "+numParametre+"  valeur "+params[numParametre]+"--->"+valeurChoisie);
        params[numParametre] = valeurChoisie;
        App.Storage.setValue("Params"+numParametre, valeurChoisie);
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

