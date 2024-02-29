import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Weather;

class myFirstWatchFaceView extends WatchUi.WatchFace {
  var screenWidth;
  var screenHeight;
  var clockTime;
  var batteryLvl;
  var temperature;
  var precipitationChance;
  var isAwake;
  function initialize() {
    WatchFace.initialize();
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    setLayout(Rez.Layouts.WatchFace(dc));
    screenWidth = dc.getWidth();
    screenHeight = dc.getHeight();
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {
    isAwake = true;
  }

  // Update the view
  function onUpdate(dc as Dc) as Void {
    // Get and show the date
    var dateSys = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    var dateString =
      dateSys.day.format("%02d") +
      " " +
      //dateSys.month.format("%02d") + "-" +
      [
        "Ene",
        "Feb",
        "Mar",
        "Abr",
        "May",
        "Jun",
        "Jul",
        "Ago",
        "Sep",
        "Oct",
        "Nov",
        "Dic",
      ][dateSys.month - 1] +
      " " +
      dateSys.year.format("%4d");
    var dateDisplay = View.findDrawableById("Date") as Text;
    dateDisplay.setText(dateString);

    // Get and show the current time
    clockTime = System.getClockTime();
    var timeString = Lang.format("$1$:$2$", [
      clockTime.hour,
      clockTime.min.format("%02d"),
    ]);
    var hourMinute = View.findDrawableById("HourMinute") as Text;
    hourMinute.setText(timeString);

    // Call the parent onUpdate function to redraw the layout

    // Get and show dat of the week
    var DayOfWeekElement = View.findDrawableById("DayOfWeek") as Text;
    DayOfWeekElement.setText(
      [
        "Domingo",
        "Lunes",
        "Martes",
        "Mi\u00e9rcoles",
        "Jueves",
        "Viernes",
        "S\u00E1bado",
      ][dateSys.day_of_week - 1]
    );

    // Weather
    temperature = Weather.getCurrentConditions().feelsLikeTemperature;
    var temperatureStr = temperature.format("%d") + " \u00B0C";
    var FeelsLikeElement = View.findDrawableById("FeelsLike") as Text;
    FeelsLikeElement.setText(temperatureStr);

    precipitationChance = Weather.getCurrentConditions().precipitationChance;
    var precipStr = precipitationChance.format("%d") + "%";
    var precipElement = View.findDrawableById("Precipitation") as Text;
    precipElement.setText(precipStr);

    View.onUpdate(dc); // Any dc.draw must be donw after this line

    // Draw a cicle around the watch
    dc.setPenWidth(2);
    dc.drawCircle(screenWidth / 2, screenHeight / 2, screenWidth / 2 - 1);
    dc.setPenWidth(1);

    // Get and show the battery
    batteryLvl = System.getSystemStats().battery;

    if (batteryLvl < 20) {
      // set pen color
      dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
      // draw battery
      drawBattery(dc);
    } else {
      // draw battery
      drawBattery(dc);
    }

    // show the second
    if (isAwake) {
      dc.drawText(
        screenWidth / 2,
        screenHeight * 0.65,
        Graphics.FONT_SMALL,
        clockTime.sec.format("%02d"),
        Graphics.TEXT_JUSTIFY_CENTER
      );
    }

    // Screen Saver
    //var screenSaverTimer = new Toybox.Timer.Timer();
    //screenSaverTimer.start()
    // if (clockTime.min == 59 && clockTime.sec == 59) {
    if (
      (clockTime.sec == 59 && isAwake) ||
      ((clockTime.hour == 1 ||
        clockTime.hour == 2 ||
        clockTime.hour == 3 ||
        clockTime.hour == 4 ||
        clockTime.hour == 5) &&
        clockTime.min == 5)
    ) {
      //if (clockTime.min == 59) {
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
      dc.fillCircle(screenWidth / 2, screenHeight / 2, screenWidth / 2);
    }
  }

  function drawBattery(dc as Dc) as Void {
    // set the coords
    var batx = screenWidth / 2;
    var baty = (screenHeight * 3.9) / 5;
    var batIconWid = screenWidth / 8;
    var batIconHei = batIconWid / 2;

    var batTipx = batx + batIconWid;
    var batTipy = baty + (batIconHei * 2) / 6;

    var textx = batx - batIconWid / 5;
    var texty = baty + batIconHei / 3 + 1;
    // Draw text
    dc.drawText(
      textx,
      texty,
      Graphics.FONT_TINY,
      batteryLvl.format("%d") + "%",
      Graphics.TEXT_JUSTIFY_VCENTER
    );
    // draw battery
    dc.drawRoundedRectangle(batx, baty, batIconWid, batIconHei, 2);
    // draw battery tip
    dc.fillRectangle(batTipx, batTipy, batIconWid / 12, batIconHei / 3);
    // Fill the battery
    dc.fillRoundedRectangle(
      batx,
      baty,
      (batIconWid * batteryLvl) / 100,
      batIconHei,
      2
    );
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {}

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() as Void {
    isAwake = true;
  }

  // Terminate any active timers and prepare for slow updates.
  function onEnterSleep() as Void {
    isAwake = false;
  }
}
