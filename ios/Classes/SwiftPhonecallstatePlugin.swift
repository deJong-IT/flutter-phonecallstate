import Flutter
import UIKit
import CallKit

@available(iOS 10.0,*)
public class SwiftPhonecallstatePlugin: NSObject, FlutterPlugin, CXCallObserverDelegate {
    
    var callObserver: CXCallObserver = CXCallObserver()
    var _channel: FlutterMethodChannel
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.plusdt.phonecallstate", binaryMessenger: registrar.messenger())
        let instance = SwiftPhonecallstatePlugin(channel:channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    init(channel:FlutterMethodChannel) {
        _channel = channel
        super.init()
        callObserver.setDelegate(self, queue: nil)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("iOS => call \(call.method)")
        
        switch (call.method) {
        case "phoneTest.PhoneIncoming":
            let seconds: Double = call.arguments as? Double ?? 1
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                [weak self] in
                self?._channel.invokeMethod("phone.incoming", arguments: nil)
            }            
            result(1)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasEnded == true {
            print("CXCallState :Disconnected")
            _channel.invokeMethod("phone.disconnected", arguments: nil)
        } else if call.isOutgoing == true && call.hasConnected == false {
            print("CXCallState :Dialing")
            _channel.invokeMethod("phone.dialing", arguments: nil)
        } else if call.isOutgoing == false && call.hasConnected == false && call.hasEnded == false {
            print("CXCallState :Incoming")
            _channel.invokeMethod("phone.incoming", arguments: nil)
        } else if call.hasConnected == true && call.hasEnded == false {
            print("CXCallState : Connected")
            _channel.invokeMethod("phone.connected", arguments: nil)
        }
    }
    
}
