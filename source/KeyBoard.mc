using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;

class KeyboardView extends Ui.View {
var prompt,codeString,codeIsOK;


    function initialize(codeOK) {
        codeString = params[code];
        codeIsOK = codeOK;
        View.initialize();
    }

    function onUpdate(dc) {
        if (codeIsOK != null) {
            if (codeIsOK) {
                prompt = "Your code is OK";
            } else {
                prompt = "Your code is\ninvalid !";
            }
        } else {
            prompt = "Your actual code is\n"+codeString+"\nPress Enter to change it";
        }
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_SMALL, prompt, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);    
    }
    public function setText(text) as Void {
        codeString = text;
    }

}


class KeyboardDelegate extends Ui.InputDelegate {

    private var _lastText = "";
    private var _view as KeyboardView;

    public function initialize(view as KeyboardView) {
        WatchUi.InputDelegate.initialize();
        _view = view;
        _lastText = params[code];
    }
    public function onKey(key) {
        if (key.getKey() == WatchUi.KEY_ENTER) { 
            Ui.pushView(new Ui.TextPicker(_lastText), new KeyboardListener(_view, self), WatchUi.SLIDE_DOWN);
        } else {
            Ui.popView(Ui.SLIDE_IMMEDIATE);
        }
        return true;
    }
    public function onTap(evt) {
        WatchUi.pushView(new Ui.TextPicker(_lastText), new KeyboardListener(_view, self), WatchUi.SLIDE_DOWN);
        return true;
    }
    public function setLastText(text) as Void {
        _lastText = text;
    }

}


class KeyboardListener extends Ui.TextPickerDelegate {

    private var _delegate as KeyboardDelegate;
    private var _view as KeyboardView;

    public function initialize(view as KeyboardView, delegate as KeyboardDelegate) {
        Ui.TextPickerDelegate.initialize();
        _delegate = delegate;
        _view = view;
    }
    public function onTextEntered(text, changed ) {
        Application.Properties.setValue("param"+code,text);
        var myTimer = new Timer.Timer();
        _view.codeIsOK = codeIsOK(text);
        myTimer.start(method(:timerCallback), 3000, false);
        Ui.requestUpdate();
    }
    public function onCancel() {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        return true;
    }

    function timerCallback() {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
    }
    function codeIsOK(codeString) {
		if ((codeString == null) || codeString.length() == 0){
            return false;
        }
        if (codeString.substring(codeString.length()-1,codeString.length()).equals(" ")) {
            codeString = codeString.substring(0,codeString.length()-1);
        }
		codeString = codeString.toUpper();
        var goodCode = WatchUi.loadResource(Rez.Strings.codeApp);
        if (codeString.equals(goodCode)) {
            return true;
        } else {
            return false;
        }
    }
}

