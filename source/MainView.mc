import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class MainView extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;

        dc.drawText(cx, h * 0.12, Graphics.FONT_SMALL,
            WatchUi.loadResource(Rez.Strings.AppName) as String,
            Graphics.TEXT_JUSTIFY_CENTER);

        var ex = getExerciseSec();
        var rest = getRestSec();
        var reps = getReps();

        var line = ex + "s / " + rest + "s x " + reps;
        dc.drawText(cx, h * 0.40, Graphics.FONT_LARGE, line,
            Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(cx, h * 0.65, Graphics.FONT_XTINY,
            WatchUi.loadResource(Rez.Strings.ReadyPrompt) as String,
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(cx, h * 0.75, Graphics.FONT_XTINY,
            WatchUi.loadResource(Rez.Strings.ConfigPrompt) as String,
            Graphics.TEXT_JUSTIFY_CENTER);
    }
}
