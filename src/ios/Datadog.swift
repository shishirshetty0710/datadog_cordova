//
//  Datadog.swift
//
//  Created by Shishir Shetty on 06/27/2024.
//

import Foundation
import UIKit
import DatadogCore
import DatadogCrashReporting
import DatadogRUM

@objc(Datadog) class DatadogCrash: CDVPlugin{
    
    var wkSessionId:String = " "
    var isInitialized:Bool = false
    
    @objc(Init:)func Init(command : CDVInvokedUrlCommand){
        if(!isInitialized){
            let clientToken = command.argument(at: 0) as! String
            let enviourment = command.argument(at: 1) as! String
            let appID = command.argument(at: 2) as! String
            let trackingConsentInt = command.argument(at: 3) as! Int
            var trackingConsent:TrackingConsent
            switch trackingConsentInt {
            case 0:
                trackingConsent = .notGranted
                break;
            case 1:
                trackingConsent = .granted
                break;
            default:
                trackingConsent = .pending
                break;
            }
            Datadog.initialize(
                    with: Datadog.Configuration(
                            clientToken: clientToken,
                            env: enviourment,
                            service: "mymsk"
                            ),
                    trackingConsent: trackingConsent
            )

            CrashReporting.enable()
            // Datadog.initialize(
            //     appContext: .init(),
            //     trackingConsent: trackingConsent,
            //     configuration: Datadog.Configuration
            //     .builderUsing(
            //         rumApplicationID: appID,
            //         clientToken: clientToken,
            //         environment: enviourment
            //     )
            //     .trackUIKitRUMViews()
            //     .enableCrashReporting(using: DDCrashReportingPlugin())
            //     .trackBackgroundEvents()
            //     .build()
            // )
            // Global.rum = RUMMonitor.initialize()
            // if self.wkSessionId != nil {
            //      if self.wkSessionId.compare(" ") != .orderedSame {
            //     Global.rum.addAttribute(forKey: "wk_UniqueIDForSession", value: wkSessionId)
            //     }
            // }

            RUM.enable(
                with: RUM.Configuration(
                applicationID: appID,
                uiKitViewsPredicate: DefaultUIKitRUMViewsPredicate(),
                uiKitActionsPredicate: DefaultUIKitRUMActionsPredicate(),
                urlSessionTracking: RUM.Configuration.URLSessionTracking(),
                trackBackgroundEvents: true
              )         
            )
           
            let result = CDVPluginResult.init(status: CDVCommandStatus_OK)
            self.commandDelegate.send(result, callbackId: command.callbackId)
        }else{
            let result = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs: "Already Initialized!")
            self.commandDelegate.send(result, callbackId: command.callbackId)
        }
    }
    @objc(setCustomFieldSessionId:)func setCustomFieldSessionId(command : CDVInvokedUrlCommand){
        
        wkSessionId = command.argument(at: 0) as! String
        if isInitialized {
            if self.wkSessionId.compare(" ") != .orderedSame {
                //Global.rum.removeAttribute(forKey: "wk_UniqueIDForSession")
            }
            //Global.rum.addAttribute(forKey: "wk_UniqueIDForSession", value: wkSessionId)
        }
        let result = CDVPluginResult.init(status: CDVCommandStatus_OK)
        self.commandDelegate.send(result, callbackId: command.callbackId)
    }
    @objc(getSessionId:)func getSessionId(command : CDVInvokedUrlCommand){
        let uuid = UUID().uuidString
        let result = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs: uuid)
        self.commandDelegate.send(result, callbackId: command.callbackId)
    }

    @objc(setTrackingConsent:)func setTrackingConsent(command : CDVInvokedUrlCommand){
        let trackingConsentInt = command.argument(at: 0) as! Int
        var trackingConsent:TrackingConsent
        switch trackingConsentInt {
        case 0:
            trackingConsent = .notGranted
            break;
        case 1:
            trackingConsent = .granted
            break;
        default:
            trackingConsent = .pending
            break;
        }
        Datadog.set(trackingConsent: trackingConsent)
        let result = CDVPluginResult.init(status: CDVCommandStatus_OK)
        self.commandDelegate.send(result, callbackId: command.callbackId)
    }

    @objc(throwCrash:)func throwCrash(command : CDVInvokedUrlCommand) {
        // Force a crash by accessing a nil pointer
        var array: [Int]? = nil
        print(array!.count) // Force unwrapping a nil optional
    }
}
