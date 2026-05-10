import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.WatchUi;

function showConfigMenu(parent as MainView) as Void {
    var menu = new WatchUi.Menu2({:title => "Settings"});
    menu.addItem(buildItem(Rez.Strings.ExerciseLabel, getExerciseSec(), "ex"));
    menu.addItem(buildItem(Rez.Strings.RestLabel, getRestSec(), "rest"));
    menu.addItem(buildItem(Rez.Strings.RepsLabel, getReps(), "reps"));
    menu.addItem(new WatchUi.ToggleMenuItem("Sounds", null, "sounds", getSoundsEnabled(), {}));
    menu.addItem(new WatchUi.ToggleMenuItem("Record activity", null, "record", getRecordEnabled(), {}));
    menu.addItem(new WatchUi.MenuItem("Load preset", null, "load", {}));
    var loaded = getLoadedPresetName();
    if (loaded != null) {
        menu.addItem(new WatchUi.MenuItem("Save", loaded, "save_current", {}));
    }
    menu.addItem(new WatchUi.MenuItem("Save As", null, "save_as", {}));
    menu.addItem(new WatchUi.MenuItem("Rename preset", null, "rename", {}));
    menu.addItem(new WatchUi.MenuItem("Delete preset", null, "delete", {}));
    WatchUi.pushView(menu, new ConfigMenuDelegate(parent), WatchUi.SLIDE_LEFT);
}

function buildItem(labelRes as ResourceId, value as Number, id as String) as WatchUi.MenuItem {
    return new WatchUi.MenuItem(
        WatchUi.loadResource(labelRes) as String,
        value + "",
        id,
        {});
}

class ConfigMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize(parent as MainView) {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as String;

        if (id.equals("ex") || id.equals("rest") || id.equals("reps")) {
            openNumberPicker(id, item);
            return;
        }

        if (id.equals("sounds")) {
            var toggle = item as WatchUi.ToggleMenuItem;
            setSoundsEnabled(toggle.isEnabled());
            return;
        }

        if (id.equals("record")) {
            var toggle = item as WatchUi.ToggleMenuItem;
            setRecordEnabled(toggle.isEnabled());
            return;
        }

        if (id.equals("save_as")) {
            WatchUi.pushView(
                new WatchUi.TextPicker(""),
                new SavePresetDelegate(),
                WatchUi.SLIDE_LEFT);
            return;
        }

        if (id.equals("save_current")) {
            var loaded = getLoadedPresetName();
            if (loaded != null) {
                savePreset(loaded);
            }
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            return;
        }

        if (id.equals("load") || id.equals("delete") || id.equals("rename")) {
            showPresetListMenu(id);
            return;
        }
    }

    function onBack() as Void {
        WatchUi.requestUpdate();
        Menu2InputDelegate.onBack();
    }

    private function openNumberPicker(id as String, item as WatchUi.MenuItem) as Void {
        var title;
        var min;
        var max;
        var current;
        var key;

        if (id.equals("ex")) {
            title = "Exercise (s)";
            min = EXERCISE_MIN; max = EXERCISE_MAX;
            current = getExerciseSec(); key = KEY_EXERCISE;
        } else if (id.equals("rest")) {
            title = "Rest (s)";
            min = REST_MIN; max = REST_MAX;
            current = getRestSec(); key = KEY_REST;
        } else {
            title = "Reps";
            min = REPS_MIN; max = REPS_MAX;
            current = getReps(); key = KEY_REPS;
        }

        WatchUi.pushView(
            new NumberPickerView(title, min, max, current),
            new NumberPickerDelegate(key, item),
            WatchUi.SLIDE_LEFT);
    }
}

function showPresetListMenu(action as String) as Void {
    var presets = getPresets();
    var title;
    if (action.equals("delete")) { title = "Delete"; }
    else if (action.equals("rename")) { title = "Rename"; }
    else { title = "Load"; }

    var menu = new WatchUi.Menu2({:title => title});

    if (presets.size() == 0) {
        menu.addItem(new WatchUi.MenuItem("(none saved)", null, "_empty", {}));
    } else {
        for (var i = 0; i < presets.size(); i++) {
            var p = presets[i];
            var name = p["name"] as String;
            var subLabel = p["ex"] + "s/" + p["rest"] + "s x" + p["reps"];
            menu.addItem(new WatchUi.MenuItem(name, subLabel, name, {}));
        }
    }

    WatchUi.pushView(menu, new PresetListDelegate(action), WatchUi.SLIDE_LEFT);
}

class PresetListDelegate extends WatchUi.Menu2InputDelegate {
    private var _action as String;

    function initialize(action as String) {
        Menu2InputDelegate.initialize();
        _action = action;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as String;
        if (id.equals("_empty")) {
            return;
        }
        if (_action.equals("delete")) {
            deletePreset(id);
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        } else if (_action.equals("rename")) {
            WatchUi.pushView(
                new WatchUi.TextPicker(id),
                new RenamePresetDelegate(id),
                WatchUi.SLIDE_LEFT);
        } else {
            loadPreset(id);
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        }
    }
}

class RenamePresetDelegate extends WatchUi.TextPickerDelegate {
    private var _oldName as String;

    function initialize(oldName as String) {
        TextPickerDelegate.initialize();
        _oldName = oldName;
    }

    function onTextEntered(text as String, changed as Boolean) as Boolean {
        if (text != null && text.length() > 0) {
            renamePreset(_oldName, text);
        }
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    function onCancel() as Boolean {
        return true;
    }
}

class SavePresetDelegate extends WatchUi.TextPickerDelegate {
    function initialize() {
        TextPickerDelegate.initialize();
    }

    function onTextEntered(text as String, changed as Boolean) as Boolean {
        if (text != null && text.length() > 0) {
            savePreset(text);
        }
        return true;
    }

    function onCancel() as Boolean {
        return true;
    }
}
