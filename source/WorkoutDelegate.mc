import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class WorkoutDelegate extends WatchUi.BehaviorDelegate {
    private var _view as WorkoutView;

    function initialize(view as WorkoutView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    function onSelect() as Boolean {
        if (_view.isDone()) {
            System.exit();
            return true;
        }
        _view.togglePause();
        return true;
    }

    function onNextPage() as Boolean {
        _view.skipPhase();
        return true;
    }
}
