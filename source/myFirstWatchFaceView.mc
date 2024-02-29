import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Weather;
import Toybox.Activity;

class myFirstWatchFaceView extends WatchUi.WatchFace {
  var screenWidth;
  var screenHeight;
  var clockTime;
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
    View.onUpdate(dc); // Any dc.draw must be donw after this line
    // Get and show the current time
    clockTime = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

    screenSaver(dc, true);
    drawName(dc);
    drawSlogan(dc);
    drawHourMinute(dc);
    drawDate(dc);
    drawWeekDay(dc);
    drawWeather(dc);
    drawBattery(dc);

    // Draw a cicle around the watch
    dc.setPenWidth(2);
    dc.drawCircle(screenWidth / 2, screenHeight / 2, screenWidth / 2 - 1);
    dc.setPenWidth(1);

    // show the second
    if (isAwake) {
      drawSec(dc);
      drawHeartRate(dc);
    }
  }
  function screenSaver(dc as Dc, active as Boolean) {
    if (active == true) {
      var colors = [
        Graphics.COLOR_YELLOW,
        Graphics.COLOR_GREEN,
        Graphics.COLOR_BLUE,
        Graphics.COLOR_DK_GRAY,
        Graphics.COLOR_PURPLE,
        Graphics.COLOR_PINK,
        Graphics.COLOR_WHITE,
      ];
      var textColor = colors[clockTime.min % 7];

      if (clockTime.min % 20 == 0) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(screenWidth / 2, screenHeight / 2, screenWidth / 2);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
      } else {
        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
      }
    }
  }

  function drawName(dc as Dc) as Void {
    dc.drawText(
      screenWidth / 2,
      screenHeight * 0.03,
      Graphics.FONT_SYSTEM_TINY,
      "loqui\u00F1o",
      Graphics.TEXT_JUSTIFY_CENTER
    );
  }

  function drawSlogan(dc as Dc) as Void {
    dc.drawText(
      screenWidth / 2,
      screenHeight * 0.85,
      Graphics.FONT_SYSTEM_TINY,
      "smile!",
      Graphics.TEXT_JUSTIFY_CENTER
    );
  }

  function drawHourMinute(dc as Dc) as Void {
    // set the the coords
    var HMx = screenWidth / 2;
    var HMy = screenHeight * 0.3;

    // Buil HMstr
    var HMstr = Lang.format("$1$:$2$", [
      clockTime.hour.format("%d"),
      clockTime.min.format("%02d"),
    ]);

    dc.drawText(
      HMx,
      HMy,
      Graphics.FONT_NUMBER_THAI_HOT,
      HMstr,
      Graphics.TEXT_JUSTIFY_CENTER
    );
  }

  function drawSec(dc as Dc) as Void {
    dc.drawText(
      screenWidth * 0.94,
      screenHeight * 0.45,
      Graphics.FONT_TINY,
      clockTime.sec.format("%02d"),
      Graphics.TEXT_JUSTIFY_CENTER
    );
  }

  function drawDate(dc as Dc) as Void {
    //set the coords
    var datex = screenWidth / 2;
    var datey = screenHeight * 0.14;
    // Build datestr
    var dateStr =
      clockTime.day.format("%02d") +
      " " +
      //clockTime.month.format("%02d") + "-" +
      [
        "ENE",
        "FEB",
        "MAR",
        "ABR",
        "MAY",
        "JUN",
        "JUL",
        "AGO",
        "SEP",
        "OCT",
        "NOV",
        "DIC",
      ][clockTime.month - 1] +
      " " +
      clockTime.year.format("%4d");

    // Draw the date
    dc.drawText(
      datex,
      datey,
      Graphics.FONT_SMALL,
      dateStr,
      Graphics.TEXT_JUSTIFY_CENTER
    );
  }

  function drawWeekDay(dc as Dc) as Void {
    // set the coords
    var weekDayx = screenWidth / 2;
    var weekDayy = screenHeight * 0.26;

    // set weekDatstr
    var weekDaystr = [
      "DOMINGO",
      "LUNES",
      "MARTES",
      "MI\u00C9RCOLES",
      "JUEVES",
      "VIERNES",
      "S\u00C1BADO",
    ][clockTime.day_of_week - 1];

    // draw weekDay
    dc.drawText(
      weekDayx,
      weekDayy,
      Graphics.FONT_SMALL,
      weekDaystr,
      Graphics.TEXT_JUSTIFY_CENTER
    );
  }

  function drawWeather(dc as Dc) as Void {
    // temperature
    // coords
    var tempx = screenWidth * 0.3;
    var tempy = screenHeight * 0.65;

    // str
    var temperature = Weather.getCurrentConditions().feelsLikeTemperature;
    var temperatureStr = temperature.format("%d") + "\u00B0C";

    // Draw temperature
    dc.drawText(
      tempx,
      tempy,
      Graphics.FONT_SMALL,
      temperatureStr,
      Graphics.TEXT_JUSTIFY_CENTER
    );

    // Precipitation chance
    // coords
    var precipx = screenWidth * 0.7;
    var precipy = screenHeight * 0.65;

    // str
    var precipitationChance =
      Weather.getCurrentConditions().precipitationChance;
    var precipStr = precipitationChance.format("%d") + "%";

    // draw precip
    dc.drawText(
      precipx,
      precipy,
      Graphics.FONT_SMALL,
      precipStr,
      Graphics.TEXT_JUSTIFY_CENTER
    );
  }

  function drawBattery(dc as Dc) as Void {
    var batteryLvl = System.getSystemStats().battery;
    if (batteryLvl < 20) {
      // Screensaving
      if (clockTime.min % 20 == 0) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
      } else {
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
      }
      dc.clear();
    }

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

  function drawHeartRate(dc as Dc) as Void {
    var activityInfo = Activity.getActivityInfo();
    var heartRateStr = "--";
    if (activityInfo != null) {
      var heartRate = Activity.getActivityInfo().currentHeartRate;
      if (heartRate) {
        heartRateStr = heartRate.format("%d");
      }
    }

    // draw the heart rate
    var heartx = screenWidth * 0.5;
    var hearty = screenHeight * 0.65;
    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      heartx,
      hearty,
      Graphics.FONT_SMALL,
      heartRateStr,
      Graphics.TEXT_JUSTIFY_CENTER
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
