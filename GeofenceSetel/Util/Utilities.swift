//
//  Utilities.swift
//  GeofenceSetel
//
//  Created by Zharif Hadi  on 06/01/2021.
//

import Foundation
import SystemConfiguration.CaptiveNetwork

class Utilities {
    
    static let sharedInstance = Utilities()
    
    func getWifiInfo() -> Array<WifiDetails> {
        guard let interfaceNames = CNCopySupportedInterfaces() as? [String] else { return [] }
        
        let wifiInfo:[WifiDetails] = interfaceNames.compactMap{ name in
            guard let info = CNCopyCurrentNetworkInfo(name as CFString) as? [String:AnyObject] else { return nil }
            guard let ssid = info[kCNNetworkInfoKeySSID as String] as? String else { return nil }
            return WifiDetails(interface: name, ssid: ssid)
        }
        return wifiInfo
    }
    
    func hasWifi() -> Bool {
        var isWifiAvailable = false
        if getWifiInfo().count > 0 {
            getWifiInfo().forEach({
                isWifiAvailable = $0.ssid == UserDefaults.standard.string(forKey: "SSID") ? true : false
            })
        }
        return isWifiAvailable
    }
}
