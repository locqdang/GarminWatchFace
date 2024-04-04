import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class myFirstWatchFaceApp extends Application.AppBase {
  function initialize() {
    AppBase.initialize();
  }

  // onStart() is called on application start up
  function onStart(state as Dictionary?) as Void {}

  // onStop() is called when your application is exiting
  function onStop(state as Dictionary?) as Void {}

  // Return the initial view of your application here
  //sdk 6.4
  // function getInitialView() as Array<Views or InputDelegates>? {
  //   return [new myFirstWatchFaceView()] as Array<Views or InputDelegates>;
  // }
  //sdk 7.1
  function getInitialView() as [Views] or [Views, InputDelegates] {
    return [new myFirstWatchFaceView()];
  }
}

function getApp() as myFirstWatchFaceApp {
  return Application.getApp() as myFirstWatchFaceApp;
}
