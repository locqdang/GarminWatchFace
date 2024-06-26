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
    View.onUpdate(dc); // Any dc.draw must be done after this line
    
    // Get the current time
    clockTime = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

    // set dc color with screensaver
    screenSaver(dc, true);
    dc.clear(); // this is supposed to avoid overlapping with default watch face

    // draw the watch face
    drawTopText(dc);
    drawBottomText(dc);
    drawHourMinute(dc);
    drawAmPm(dc);
    drawDate(dc);
    drawWeekDay(dc);
    drawWeather(dc);
    drawBattery(dc);
    drawOutterCircle(dc);

    // show the second and heart rate when awake
    if (isAwake) {
      drawSec(dc);
      drawHeartRate(dc);
    }
  }

  function drawOutterCircle(dc as Dc) as Void {
    dc.setPenWidth(2);
    dc.drawCircle(screenWidth / 2, screenHeight / 2, screenWidth / 2 - 1);
    dc.setPenWidth(1);
  }

  function screenSaver(dc as Dc, active as Boolean) {
    if (active == true) {
      var colors = [
        Graphics.COLOR_YELLOW,
        Graphics.COLOR_GREEN,
        Graphics.COLOR_BLUE,
        Graphics.COLOR_PINK,
        Graphics.COLOR_WHITE,
      ];

      // get random color
      Math.srand(
        clockTime.hour + clockTime.day + clockTime.month + clockTime.year
      ); // seed the random rumber
      var textColor = colors[((Math.rand() % 5) * clockTime.hour) % 5];

      // invert the color every 30 mins
      if (clockTime.min % 30 == 0) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(screenWidth / 2, screenHeight / 2, screenWidth / 2);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
      } else {
        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
      }
    }
  }

  function drawTopText(dc as Dc) as Void {
    dc.drawText(
      screenWidth / 2,
      screenHeight * 0.1,
      Graphics.FONT_SYSTEM_TINY,
      "breathe!",
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }

  function drawAmPm(dc as Dc) as Void {
    var amPm = clockTime.hour >= 12 ? "PM" : "AM";
    dc.drawText(
      screenWidth * 0.08,
      screenHeight * 0.54,
      Graphics.FONT_SYSTEM_TINY,
      amPm,
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }

  function drawBottomText(dc as Dc) as Void {
    dc.drawText(
      screenWidth * 0.5,
      screenHeight * 0.93,
      Graphics.FONT_SYSTEM_TINY,
      "smile!",
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }

  function drawHourMinute(dc as Dc) as Void {
    // set the the coords
    var HMx = screenWidth * 0.5;
    var HMy = screenHeight * 0.52;

    // set the 12-hour hour
    var hour = clockTime.hour > 12 ? clockTime.hour - 12 : clockTime.hour;
    if (hour == 0) {
      hour = 12;
    }

    // Buil HMstr
    var HMstr = Lang.format("$1$:$2$", [
      hour.format("%2d"),
      clockTime.min.format("%02d"),
    ]);

    // Draw heart rate
    dc.drawText(
      HMx,
      HMy,
      Graphics.FONT_NUMBER_THAI_HOT,
      HMstr,
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }

  function drawSec(dc as Dc) as Void {
    dc.drawText(
      screenWidth * 0.94,
      screenHeight * 0.52,
      Graphics.FONT_TINY,
      clockTime.sec.format("%02d"),
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }

  function drawDate(dc as Dc) as Void {
    //set the coords
    var datex = screenWidth * 0.5;
    var datey = screenHeight * 0.22;

    // Build datestr
    var dateStr =
      clockTime.day.format("%02d") +
      " " +
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
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }

  function drawWeekDay(dc as Dc) as Void {
    // set the coords
    var weekDayx = screenWidth * 0.5;
    var weekDayy = screenHeight * 0.34;

    // set weekDatstr
    var weekDaystr = [
      "DOMINGO",
      "LUNES",
      "MARTES",
      "MI\u00C9RCOLES", // MIERCOLES
      "JUEVES",
      "VIERNES",
      "S\u00C1BADO",    // SABADO
    ][clockTime.day_of_week - 1];

    // draw weekDay
    dc.drawText(
      weekDayx,
      weekDayy,
      Graphics.FONT_SMALL,
      weekDaystr,
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }

  function drawWeather(dc as Dc) as Void {
    // temperature
    // coords
    var tempx = screenWidth * 0.29;
    var tempy = screenHeight * 0.7;

    // get the weather info
    var weather = Weather.getCurrentConditions();
    var temperature = null;
    var feelsLike = null;

    // str
    var temperatureStr = "--";
    if (weather != null) {
      temperature = weather.temperature;
      feelsLike = weather.feelsLikeTemperature;
      if (feelsLike != null) {
        temperatureStr = feelsLike.format("%3d") + "\u00B0C";
      } else if (temperature != null) {
        temperatureStr = temperature.format("%3d") + "\u00B0C";
      }
    }
    // Draw temperature
    dc.drawText(
      tempx,
      tempy,
      Graphics.FONT_SMALL,
      temperatureStr,
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );

    // Precipitation chance
    // coords
    var precipx = screenWidth * 0.7;
    var precipy = tempy;

    // str
    var precipStr = "--";
    var precipitationChance = null;
    if (weather != null) {
      precipitationChance = weather.precipitationChance;
      if (precipitationChance != null) {
        precipStr = precipitationChance.format("%3d") + "%";
      }
    }

    // draw precip
    dc.drawText(
      precipx,
      precipy,
      Graphics.FONT_SMALL,
      precipStr,
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }

  function drawBattery(dc as Dc) as Void {
    var batteryLvl = System.getSystemStats().battery;
    if (batteryLvl < 20) {
      // Screensaving
      if (clockTime.min % 30 == 0) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
      } else {
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
      }
      dc.clear();
    }

    // set the coords and size
    var batx = screenWidth * 0.52;
    var baty = screenHeight * 0.8;
    var batIconWid = screenWidth * 0.1;
    var batIconHei = batIconWid * 0.57;

    var batTipx = batx + batIconWid;
    var batTipy = baty + (batIconHei * 2) / 6;

    var textx = batx - batIconWid;
    var texty = baty + batIconHei * 0.4;

    // Draw text
    dc.drawText(
      textx,
      texty,
      Graphics.FONT_TINY,
      batteryLvl.format("%3d") + "%",
      Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER
    );
    // draw battery
    dc.drawRoundedRectangle(batx, baty, batIconWid, batIconHei, 2);
    // draw battery tip
    dc.fillRectangle(batTipx, batTipy, batIconWid / 12, batIconHei / 3);
    // Fill the battery
    dc.fillRoundedRectangle(
      batx + 1.8,
      baty + 2,
      ((batIconWid * batteryLvl) / 100) * 0.85,
      batIconHei * 0.7,
      2
    );
  }

  function drawHeartRate(dc as Dc) as Void {
    var heartRateStr = "--";
    var activityInfo = Activity.getActivityInfo();
    if (activityInfo != null) {
      var heartRate = activityInfo.currentHeartRate;
      if (heartRate != null) {
        heartRateStr = heartRate.format("%3d");
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
    WatchUi.requestUpdate(); // testing to see if this fixed the exitSleep issue
  }
}
