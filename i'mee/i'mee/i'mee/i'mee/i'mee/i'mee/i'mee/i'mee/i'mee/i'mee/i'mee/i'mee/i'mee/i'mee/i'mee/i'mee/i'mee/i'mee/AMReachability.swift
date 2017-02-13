/*
Copyright (c) 2014, Ashley Mills
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
*/

import SystemConfiguration
import Foundation

public enum AMReachabilityError: Error {
    case FailedToCreateWithAddress(sockaddr_in)
    case FailedToCreateWithHostname(String)
    case UnableToSetCallback
    case UnableToSetDispatchQueue
}

public let AMReachabilityChangedNotification = NSNotification.Name("AMReachabilityChangedNotification")

func callback(AMReachability:SCNetworkAMReachability, flags: SCNetworkAMReachabilityFlags, info: UnsafeMutableRawPointer?) {

    guard let info = info else { return }

    let AMReachability = Unmanaged<AMReachability>.fromOpaque(info).takeUnretainedValue()

    DispatchQueue.main.async {
        AMReachability.AMReachabilityChanged()
    }
}

public class AMReachability {

    public typealias NetworkReachable = (AMReachability) -> ()
    public typealias NetworkUnreachable = (AMReachability) -> ()

    public enum NetworkStatus: CustomStringConvertible {

        case notReachable, reachableViaWiFi, reachableViaWWAN

        public var description: String {
            switch self {
            case .reachableViaWWAN: return "Cellular"
            case .reachableViaWiFi: return "WiFi"
            case .notReachable: return "No Connection"
            }
        }
    }

    public var whenReachable: NetworkReachable?
    public var whenUnreachable: NetworkUnreachable?
    public var reachableOnWWAN: Bool

    // The notification center on which "AMReachability changed" events are being posted
    public var notificationCenter: NotificationCenter = NotificationCenter.default

    public var currentAMReachabilityString: String {
        return "\(currentAMReachabilityStatus)"
    }

    public var currentAMReachabilityStatus: NetworkStatus {
        guard isReachable else { return .notReachable }

        if isReachableViaWiFi {
            return .reachableViaWiFi
        }
        if isRunningOnDevice {
            return .reachableViaWWAN
        }

        return .notReachable
    }

    fileprivate var previousFlags: SCNetworkAMReachabilityFlags?

    fileprivate var isRunningOnDevice: Bool = {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            return false
        #else
            return true
        #endif
    }()

    fileprivate var notifierRunning = false
    fileprivate var AMReachabilityRef: SCNetworkAMReachability?

    fileprivate let AMReachabilitySerialQueue = DispatchQueue(label: "uk.co.ashleymills.AMReachability")

    required public init(AMReachabilityRef: SCNetworkAMReachability) {
        reachableOnWWAN = true
        self.AMReachabilityRef = AMReachabilityRef
    }

    public convenience init?(hostname: String) {

        guard let ref = SCNetworkAMReachabilityCreateWithName(nil, hostname) else { return nil }

        self.init(AMReachabilityRef: ref)
    }

    public convenience init?() {

        var zeroAddress = sockaddr()
        zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zeroAddress.sa_family = sa_family_t(AF_INET)

        guard let ref: SCNetworkAMReachability = withUnsafePointer(to: &zeroAddress, {
            SCNetworkAMReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else { return nil }

        self.init(AMReachabilityRef: ref)
    }

    deinit {
        stopNotifier()

        AMReachabilityRef = nil
        whenReachable = nil
        whenUnreachable = nil
    }
}

public extension AMReachability {

    // MARK: - *** Notifier methods ***
    func startNotifier() throws {

        guard let AMReachabilityRef = AMReachabilityRef, !notifierRunning else { return }

        var context = SCNetworkAMReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = UnsafeMutableRawPointer(Unmanaged<AMReachability>.passUnretained(self).toOpaque())
        if !SCNetworkAMReachabilitySetCallback(AMReachabilityRef, callback, &context) {
            stopNotifier()
            throw AMReachabilityError.UnableToSetCallback
        }

        if !SCNetworkAMReachabilitySetDispatchQueue(AMReachabilityRef, AMReachabilitySerialQueue) {
            stopNotifier()
            throw AMReachabilityError.UnableToSetDispatchQueue
        }

        // Perform an intial check
        AMReachabilitySerialQueue.async {
            self.AMReachabilityChanged()
        }

        notifierRunning = true
    }

    func stopNotifier() {
        defer { notifierRunning = false }
        guard let AMReachabilityRef = AMReachabilityRef else { return }

        SCNetworkAMReachabilitySetCallback(AMReachabilityRef, nil, nil)
        SCNetworkAMReachabilitySetDispatchQueue(AMReachabilityRef, nil)
    }

    // MARK: - *** Connection test methods ***
    var isReachable: Bool {

        guard isReachableFlagSet else { return false }

        if isConnectionRequiredAndTransientFlagSet {
            return false
        }

        if isRunningOnDevice {
            if isOnWWANFlagSet && !reachableOnWWAN {
                // We don't want to connect when on 3G.
                return false
            }
        }

        return true
    }

    var isReachableViaWWAN: Bool {
        // Check we're not on the simulator, we're REACHABLE and check we're on WWAN
        return isRunningOnDevice && isReachableFlagSet && isOnWWANFlagSet
    }

    var isReachableViaWiFi: Bool {

        // Check we're reachable
        guard isReachableFlagSet else { return false }

        // If reachable we're reachable, but not on an iOS device (i.e. simulator), we must be on WiFi
        guard isRunningOnDevice else { return true }

        // Check we're NOT on WWAN
        return !isOnWWANFlagSet
    }

    var description: String {

        let W = isRunningOnDevice ? (isOnWWANFlagSet ? "W" : "-") : "X"
        let R = isReachableFlagSet ? "R" : "-"
        let c = isConnectionRequiredFlagSet ? "c" : "-"
        let t = isTransientConnectionFlagSet ? "t" : "-"
        let i = isInterventionRequiredFlagSet ? "i" : "-"
        let C = isConnectionOnTrafficFlagSet ? "C" : "-"
        let D = isConnectionOnDemandFlagSet ? "D" : "-"
        let l = isLocalAddressFlagSet ? "l" : "-"
        let d = isDirectFlagSet ? "d" : "-"

        return "\(W)\(R) \(c)\(t)\(i)\(C)\(D)\(l)\(d)"
    }
}

fileprivate extension AMReachability {

    func AMReachabilityChanged() {

        let flags = AMReachabilityFlags

        guard previousFlags != flags else { return }

        let block = isReachable ? whenReachable : whenUnreachable
        block?(self)

        self.notificationCenter.post(name: AMReachabilityChangedNotification, object:self)

        previousFlags = flags
    }

    var isOnWWANFlagSet: Bool {
        #if os(iOS)
            return AMReachabilityFlags.contains(.isWWAN)
        #else
            return false
        #endif
    }
    var isReachableFlagSet: Bool {
        return AMReachabilityFlags.contains(.reachable)
    }
    var isConnectionRequiredFlagSet: Bool {
        return AMReachabilityFlags.contains(.connectionRequired)
    }
    var isInterventionRequiredFlagSet: Bool {
        return AMReachabilityFlags.contains(.interventionRequired)
    }
    var isConnectionOnTrafficFlagSet: Bool {
        return AMReachabilityFlags.contains(.connectionOnTraffic)
    }
    var isConnectionOnDemandFlagSet: Bool {
        return AMReachabilityFlags.contains(.connectionOnDemand)
    }
    var isConnectionOnTrafficOrDemandFlagSet: Bool {
        return !AMReachabilityFlags.intersection([.connectionOnTraffic, .connectionOnDemand]).isEmpty
    }
    var isTransientConnectionFlagSet: Bool {
        return AMReachabilityFlags.contains(.transientConnection)
    }
    var isLocalAddressFlagSet: Bool {
        return AMReachabilityFlags.contains(.isLocalAddress)
    }
    var isDirectFlagSet: Bool {
        return AMReachabilityFlags.contains(.isDirect)
    }
    var isConnectionRequiredAndTransientFlagSet: Bool {
        return AMReachabilityFlags.intersection([.connectionRequired, .transientConnection]) == [.connectionRequired, .transientConnection]
    }

    var AMReachabilityFlags: SCNetworkAMReachabilityFlags {

        guard let AMReachabilityRef = AMReachabilityRef else { return SCNetworkAMReachabilityFlags() }

        var flags = SCNetworkAMReachabilityFlags()
        let gotFlags = withUnsafeMutablePointer(to: &flags) {
            SCNetworkAMReachabilityGetFlags(AMReachabilityRef, UnsafeMutablePointer($0))
        }

        if gotFlags {
            return flags
        } else {
            return SCNetworkAMReachabilityFlags()
        }
    }
}
