
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
        var display12 = "Display 12h";
        var display24 = "Display 24h";
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
        var item = menuView.item;
        //System.println("item "+item);
        var display12 = "Display 12h";
        var display24 = "Display 24h";
        if ((item >=0) && (item <= MinutesColor)){
            var colorsNames = Colors.colorsNames();
            if (item == BackGroundColor) {colorsNames.remove("Transparent");} //pas de transparence pour le background
            setttingAnalogView = new SettingsAnalogView(item,colorsNames,menuPrincipalTab()[item]);
            Ui.pushView(setttingAnalogView, new MenusDelegate(setttingAnalogView), Ui.SLIDE_RIGHT);
        } else if (item == MinutesColor+1)   {
            params[is24h] = ! params[is24h];
            saveParam(is24h, params[is24h]);
            menuView.itemString = params[is24h] ? display12 : display24;
            menuView.tabLignesMenu[menuView.item] = params[is24h] ? display12 : display24;
 		} else if (item >=10) { // dans ce cas la couleur est confirmée
            var colorNum = item-10;
            System.println("save  numParam "+menuView.numParametre+"  color "+params[menuView.numParametre]+"--->"+colorNum);
            params[menuView.numParametre] = colorNum;
            saveParam(menuView.numParametre, colorNum);
            couleurFond = Colors.colorValuesTab()[params[0]];
            Ui.popView(Ui.SLIDE_RIGHT);
        }
        
        Ui.requestUpdate();
    }

    function saveParam(num,value) {
        App.Storage.setValue("Params"+num, value);
    }


    function onBack()    {
        if (oldParams != null) {
            System.println("onBack   oldParams = "+oldParams);
            params = oldParams;
        }
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

