//
//  Counter.swift
//  CounterApp
//
//  Created by Michele Balistreri on 17/11/2020.
//

import Foundation
import Keycard

@objc(Counter)
class Counter: NSObject {
  
  private var count = 0
  
  @available(iOS 13.0, *)
  private(set) lazy var keycardController: KeycardController? = nil
  
  @objc
  func increment(_ resolve: RCTPromiseResolveBlock, rejecter _: RCTPromiseRejectBlock) -> Void {
    count += 1
    resolve(count)
  }
  
  
  @objc
  func decrement(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
    if (count == 0) {
      let error = NSError(domain: "", code: 200, userInfo: nil)
      reject("E_COUNT", "count cannot be negative", error)
    } else {
      count -= 1
      resolve(count)
    }
  }
  
  @objc
  func select() {
    if #available(iOS 13.0, *) {
      keycardController = KeycardController(onConnect: { [unowned self] channel in
        do {
          let cmdSet = KeycardCommandSet(cardChannel: channel)
          let info = try ApplicationInfo(cmdSet.select().checkOK().data)
          print(info)
          self.keycardController?.stop(alertMessage: "Success")
        } catch {
          print("Error: \(error)")
          self.keycardController?.stop(errorMessage: "Read error. Please try again.")
        }
        self.keycardController = nil
      }, onFailure: { [unowned self] error in
        print("Disconnected: \(error)")
        self.keycardController = nil
      })
      keycardController?.start(alertMessage: "Hold your iPhone near a Status Keycard.")
    } else {
      print("Unavailable")
    }
  }
  
  @objc
  func hasKeycardSDK(_ resolve: RCTPromiseResolveBlock, rejecter _: RCTPromiseRejectBlock) -> Void {
    if #available(iOS 13.0, *) {
      resolve(true)
    } else {
      resolve(false)
    }
  }
  
  @objc
  func hasNFC(_ resolve: RCTPromiseResolveBlock, rejecter _: RCTPromiseRejectBlock) -> Void {
    if #available(iOS 13.0, *) {
      resolve(KeycardController.isAvailable)
    } else {
      resolve(false)
    }
  }
  
  @objc
  static func requiresMainQueueSetup() -> Bool {
    return true
  }
}
