# TestFRISQ


1. Add features

StopWatch with the following features:
    - Start.
    - Stop.
    - Reset (When it's stopped).
    - Lap Tracking (When it's running).
    - Background mode: The app keeps the correct time when it's in the background mode or it is killed. This part is not fully tested, so it could have bugs. I didn't have time to save the laps tracking  in the background mode. That means that, If the app is killed, they don't appear.
    
    For the implementation of the timer, we have used a Dispatch Time Source. See: Timer.swift for more details. This class has unit tests.
    
2.  Extra features.

I've working a bit in the app architecture. I have use MVVM + Coordinator. For the coordinator part we use the Coordianting protocol (see file with that name).

The app have a App Coordinator (AppCoordinator) that manages the app navigation. We created in the AppDelegate and have a Navigation Controller and the factories (ViewModule Factory in this example) like properties. When we start the App Coordinator we create the first view coordinator (StopWatch Coordinator in this example ) and it starts it.

When a coordinador is started, it creates the top view module (view controller + view module) and push thew view controller. Whe it is stopped, it pop the view controller and set it to nil. A coodinator can have more than a view module so it can handle the navigation between (e.g. Profile).

For the purpose of creating modules, we use the View Module Factory.

I didn't have time to add Unit tests for the coordinators, view models and view module factories. Everyone defines a protocol with the type, for making easier to create unit tests. 



