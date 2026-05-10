import Toybox.Activity;
import Toybox.ActivityRecording;
import Toybox.Attention;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

enum {
    PHASE_EXERCISE,
    PHASE_REST,
    PHASE_DONE
}

class WorkoutView extends WatchUi.View {
    private var _timer as Timer.Timer?;
    private var _phase as Number = PHASE_EXERCISE;
    private var _remaining as Number = 0;
    private var _currentRep as Number = 1;
    private var _totalReps as Number = 1;
    private var _exerciseSec as Number = 30;
    private var _restSec as Number = 10;
    private var _paused as Boolean = false;
    private var _session as ActivityRecording.Session?;

    function initialize() {
        View.initialize();
        _exerciseSec = getExerciseSec();
        _restSec = getRestSec();
        _totalReps = getReps();
    }

    function onShow() as Void {
        if (_timer == null && _phase != PHASE_DONE && _remaining == 0 && _currentRep == 1) {
            startWorkout();
        }
    }

    function onHide() as Void {
        stopTimer();
        if (_session != null) {
            if (_session.isRecording()) {
                _session.stop();
            }
            _session.discard();
            _session = null;
        }
    }

    function startWorkout() as Void {
        _currentRep = 1;
        _paused = false;
        beginExercise();
        startTimer();
        startSession();
    }

    function startSession() as Void {
        if (_session != null || !getRecordEnabled()) {
            return;
        }
        _session = ActivityRecording.createSession({
            :name => "Intervals",
            :sport => Activity.SPORT_TRAINING,
            :subSport => Activity.SUB_SPORT_CARDIO_TRAINING
        });
        _session.start();
    }

    function startTimer() as Void {
        if (_timer == null) {
            _timer = new Timer.Timer();
            _timer.start(method(:onTick), 1000, true);
        }
    }

    function stopTimer() as Void {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
    }

    function isDone() as Boolean {
        return _phase == PHASE_DONE;
    }

    function skipPhase() as Void {
        if (_phase == PHASE_DONE) {
            return;
        }
        playEndSignal(_phase);
        advancePhase();
        WatchUi.requestUpdate();
    }

    function togglePause() as Void {
        if (_phase == PHASE_DONE) {
            return;
        }
        if (_paused) {
            _paused = false;
            startTimer();
            if (_session != null && !_session.isRecording()) {
                _session.start();
            }
        } else {
            _paused = true;
            stopTimer();
            if (_session != null && _session.isRecording()) {
                _session.stop();
            }
        }
        WatchUi.requestUpdate();
    }

    function beginExercise() as Void {
        _phase = PHASE_EXERCISE;
        _remaining = _exerciseSec;
    }

    function beginRest() as Void {
        _phase = PHASE_REST;
        _remaining = _restSec;
    }

    function finish() as Void {
        _phase = PHASE_DONE;
        stopTimer();
        if (_session != null) {
            if (_session.isRecording()) {
                _session.stop();
            }
            _session.save();
            _session = null;
        }
        if (getSoundsEnabled() && Attention has :playTone) {
            Attention.playTone(Attention.TONE_SUCCESS);
        }
    }

    function onTick() as Void {
        if (_phase == PHASE_DONE) {
            return;
        }

        _remaining -= 1;

        if (_phase == PHASE_REST && _remaining > 0 && _remaining <= 3) {
            playCountdownBeep();
        }

        if (_remaining <= 0) {
            playEndSignal(_phase);
            advancePhase();
        }

        WatchUi.requestUpdate();
    }

    function advancePhase() as Void {
        if (_phase == PHASE_EXERCISE) {
            if (_currentRep >= _totalReps) {
                finish();
            } else {
                beginRest();
            }
        } else if (_phase == PHASE_REST) {
            _currentRep += 1;
            beginExercise();
        }
    }

    function playEndSignal(endingPhase as Number) as Void {
        if (getSoundsEnabled() && Attention has :playTone) {
            var tone = (endingPhase == PHASE_EXERCISE)
                ? Attention.TONE_STOP
                : Attention.TONE_START;
            Attention.playTone(tone);
        }
        if (!(Attention has :vibrate)) {
            return;
        }
        var profile;
        if (endingPhase == PHASE_EXERCISE) {
            profile = [new Attention.VibeProfile(100, 1000)] as Array<Attention.VibeProfile>;
        } else {
            profile = [
                new Attention.VibeProfile(100, 250),
                new Attention.VibeProfile(0, 150),
                new Attention.VibeProfile(100, 250)
            ] as Array<Attention.VibeProfile>;
        }
        Attention.vibrate(profile);
    }

    function playCountdownBeep() as Void {
        if (getSoundsEnabled() && Attention has :playTone) {
            Attention.playTone(Attention.TONE_LOUD_BEEP);
        }
    }

    function getHeartRate() as Number? {
        var info = Activity.getActivityInfo();
        if (info != null && info.currentHeartRate != null) {
            return info.currentHeartRate;
        }
        return null;
    }

    function onUpdate(dc as Dc) as Void {
        var bg = Graphics.COLOR_BLACK;
        var fg = Graphics.COLOR_WHITE;
        if (_phase == PHASE_EXERCISE) {
            bg = Graphics.COLOR_DK_GREEN;
        } else if (_phase == PHASE_REST) {
            bg = Graphics.COLOR_DK_BLUE;
        }
        if (_paused) {
            bg = Graphics.COLOR_DK_GRAY;
        }

        dc.setColor(fg, bg);
        dc.clear();

        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;

        var phaseStr;
        if (_phase == PHASE_EXERCISE) {
            phaseStr = WatchUi.loadResource(Rez.Strings.ExercisePhase) as String;
        } else if (_phase == PHASE_REST) {
            phaseStr = WatchUi.loadResource(Rez.Strings.RestPhase) as String;
        } else {
            phaseStr = WatchUi.loadResource(Rez.Strings.DonePhase) as String;
        }
        if (_paused) {
            phaseStr = "PAUSED";
        }

        dc.drawText(cx, h * 0.15, Graphics.FONT_SMALL, phaseStr,
            Graphics.TEXT_JUSTIFY_CENTER);

        if (_phase != PHASE_DONE) {
            dc.drawText(cx, h * 0.50, Graphics.FONT_NUMBER_THAI_HOT,
                _remaining + "",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

            var hr = getHeartRate();
            var hrStr = (hr == null) ? "-- bpm" : hr + " bpm";
            dc.drawText(cx, h * 0.69, Graphics.FONT_MEDIUM, hrStr,
                Graphics.TEXT_JUSTIFY_CENTER);

            var repStr = _currentRep + " / " + _totalReps;
            dc.drawText(cx, h * 0.86, Graphics.FONT_XTINY, repStr,
                Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
}
