import Toybox.Application.Storage;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class NumberFactory extends WatchUi.PickerFactory {
    private var _min as Number;
    private var _max as Number;

    function initialize(min as Number, max as Number) {
        PickerFactory.initialize();
        _min = min;
        _max = max;
    }

    function getSize() as Number {
        return _max - _min + 1;
    }

    function getValue(index as Number) as Object? {
        return _min + index;
    }

    function getIndex(value as Number) as Number {
        var idx = value - _min;
        if (idx < 0) { return 0; }
        if (idx >= getSize()) { return getSize() - 1; }
        return idx;
    }

    function getDrawable(index as Number, selected as Boolean) as WatchUi.Drawable? {
        return new WatchUi.Text({
            :text => getValue(index) + "",
            :font => Graphics.FONT_NUMBER_MEDIUM,
            :color => Graphics.COLOR_WHITE,
            :locX => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY => WatchUi.LAYOUT_VALIGN_CENTER
        });
    }
}

class NumberPickerView extends WatchUi.Picker {
    function initialize(title as String, min as Number, max as Number, current as Number) {
        var titleText = new WatchUi.Text({
            :text => title,
            :locX => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY => WatchUi.LAYOUT_VALIGN_TOP,
            :color => Graphics.COLOR_WHITE
        });
        var factory = new NumberFactory(min, max);
        Picker.initialize({
            :title => titleText,
            :pattern => [factory],
            :defaults => [factory.getIndex(current)]
        });
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        Picker.onUpdate(dc);
    }
}

class NumberPickerDelegate extends WatchUi.PickerDelegate {
    private var _key as String;
    private var _item as WatchUi.MenuItem;

    function initialize(key as String, item as WatchUi.MenuItem) {
        PickerDelegate.initialize();
        _key = key;
        _item = item;
    }

    function onCancel() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    function onAccept(values as Array) as Boolean {
        var v = values[0] as Number;
        Storage.setValue(_key, v);
        _item.setSubLabel(v + "");
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}
