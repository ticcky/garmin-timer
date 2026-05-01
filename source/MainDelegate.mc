import Toybox.Lang;
import Toybox.WatchUi;

class MainDelegate extends WatchUi.BehaviorDelegate {
    private var _view as MainView;

    function initialize(view as MainView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onSelect() as Boolean {
        var view = new WorkoutView();
        WatchUi.pushView(view, new WorkoutDelegate(view), WatchUi.SLIDE_LEFT);
        return true;
    }

    function onMenu() as Boolean {
        showConfigMenu(_view);
        return true;
    }
}
