import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.WatchUi;

const KEY_EXERCISE = "exercise_sec";
const KEY_REST = "rest_sec";
const KEY_REPS = "reps";
const KEY_PRESETS = "presets";
const KEY_SOUNDS = "sounds_enabled";
const KEY_RECORD = "record_activity";
const KEY_LOADED_PRESET = "loaded_preset";

const DEFAULT_EXERCISE = 30;
const DEFAULT_REST = 10;
const DEFAULT_REPS = 5;

const EXERCISE_MIN = 1;
const EXERCISE_MAX = 99;
const REST_MIN = 1;
const REST_MAX = 99;
const REPS_MIN = 1;
const REPS_MAX = 99;

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

function getSoundsEnabled() as Boolean {
    var v = Storage.getValue(KEY_SOUNDS);
    return (v == null) ? true : v as Boolean;
}

function setSoundsEnabled(enabled as Boolean) as Void {
    Storage.setValue(KEY_SOUNDS, enabled);
}

function getRecordEnabled() as Boolean {
    var v = Storage.getValue(KEY_RECORD);
    return (v == null) ? true : v as Boolean;
}

function setRecordEnabled(enabled as Boolean) as Void {
    Storage.setValue(KEY_RECORD, enabled);
}

function getLoadedPresetName() as String? {
    return Storage.getValue(KEY_LOADED_PRESET) as String?;
}

function setLoadedPresetName(name as String?) as Void {
    if (name == null) {
        Storage.deleteValue(KEY_LOADED_PRESET);
    } else {
        Storage.setValue(KEY_LOADED_PRESET, name);
    }
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
            setLoadedPresetName(name);
            return;
        }
    }
    list.add(preset);
    Storage.setValue(KEY_PRESETS, list);
    setLoadedPresetName(name);
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
    var loaded = getLoadedPresetName();
    if (loaded != null && loaded.equals(name)) {
        setLoadedPresetName(null);
    }
}

function renamePreset(oldName as String, newName as String) as Void {
    if (newName.length() == 0 || oldName.equals(newName)) {
        return;
    }
    var list = getPresets();
    for (var i = 0; i < list.size(); i++) {
        if ((list[i]["name"] as String).equals(oldName)) {
            list[i]["name"] = newName;
            Storage.setValue(KEY_PRESETS, list);
            var loaded = getLoadedPresetName();
            if (loaded != null && loaded.equals(oldName)) {
                setLoadedPresetName(newName);
            }
            return;
        }
    }
}

function loadPreset(name as String) as Void {
    var list = getPresets();
    for (var i = 0; i < list.size(); i++) {
        if ((list[i]["name"] as String).equals(name)) {
            Storage.setValue(KEY_EXERCISE, list[i]["ex"]);
            Storage.setValue(KEY_REST, list[i]["rest"]);
            Storage.setValue(KEY_REPS, list[i]["reps"]);
            setLoadedPresetName(name);
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
