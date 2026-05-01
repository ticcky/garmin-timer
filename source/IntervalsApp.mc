import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.WatchUi;

const KEY_EXERCISE = "exercise_sec";
const KEY_REST = "rest_sec";
const KEY_REPS = "reps";
const KEY_PRESETS = "presets";

const DEFAULT_EXERCISE = 30;
const DEFAULT_REST = 10;
const DEFAULT_REPS = 5;

const EXERCISE_MIN = 10;
const EXERCISE_MAX = 60;
const REST_MIN = 2;
const REST_MAX = 15;
const REPS_MIN = 1;
const REPS_MAX = 10;

function getExerciseSec() as Number {
    var v = Storage.getValue(KEY_EXERCISE);
    return (v == null) ? DEFAULT_EXERCISE : v as Number;
}

function getRestSec() as Number {
    var v = Storage.getValue(KEY_REST);
    return (v == null) ? DEFAULT_REST : v as Number;
}

function getReps() as Number {
    var v = Storage.getValue(KEY_REPS);
    return (v == null) ? DEFAULT_REPS : v as Number;
}

function getPresets() as Array<Dictionary> {
    var v = Storage.getValue(KEY_PRESETS);
    if (v == null) { return [] as Array<Dictionary>; }
    return v as Array<Dictionary>;
}

function savePreset(name as String) as Void {
    var list = getPresets();
    var preset = {
        "name" => name,
        "ex" => getExerciseSec(),
        "rest" => getRestSec(),
        "reps" => getReps()
    };
    for (var i = 0; i < list.size(); i++) {
        if ((list[i]["name"] as String).equals(name)) {
            list[i] = preset;
            Storage.setValue(KEY_PRESETS, list);
            return;
        }
    }
    list.add(preset);
    Storage.setValue(KEY_PRESETS, list);
}

function deletePreset(name as String) as Void {
    var list = getPresets();
    var newList = [] as Array<Dictionary>;
    for (var i = 0; i < list.size(); i++) {
        if (!(list[i]["name"] as String).equals(name)) {
            newList.add(list[i]);
        }
    }
    Storage.setValue(KEY_PRESETS, newList);
}

function loadPreset(name as String) as Void {
    var list = getPresets();
    for (var i = 0; i < list.size(); i++) {
        if ((list[i]["name"] as String).equals(name)) {
            Storage.setValue(KEY_EXERCISE, list[i]["ex"]);
            Storage.setValue(KEY_REST, list[i]["rest"]);
            Storage.setValue(KEY_REPS, list[i]["reps"]);
            return;
        }
    }
}

class IntervalsApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {}
    function onStop(state as Dictionary?) as Void {}

    function getInitialView() as [Views] or [Views, InputDelegates] {
        var view = new MainView();
        var delegate = new MainDelegate(view);
        return [view, delegate];
    }
}
