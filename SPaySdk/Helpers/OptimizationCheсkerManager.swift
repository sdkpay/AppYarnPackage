//
//  ProcessTimerManager.swift
//  SPaySdk
//
//  Created by Арсений on 31.03.2023.
//

import Darwin
import UIKit
import Dispatch

final class OptimizationCheсkerManager {
    private(set) var startTime: CFAbsoluteTime?
    private(set) var startTimeCPUCheking: UInt64?
    private(set) var networkDataSize: Int?
    private let networkMonitorManager = NetworkMonitorManager()
    
    func startTraking() {
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func checkSavedDataSize(object: Codable, clouser: (Int) -> ()) {
        let size = MemoryLayout.size(ofValue: object)
        clouser(size)
        SBLogger.logSavedData(size)
    }
    
    func checkNetworkDataSize(object: Data?) {
        guard let object else { return }
        let size = MemoryLayout.size(ofValue: object)
        networkDataSize = networkDataSize == nil ? size : networkDataSize! + size
        SBLogger.logNetworkDownloadingDataSize(networkDataSize ?? 0)
    }
    
    func startContectionTypeChecking() {
        networkMonitorManager.startMonitoring()
    }
    
    func stopContectionTypeChecking() {
        networkMonitorManager.stopMonitoring()
    }
    
    func startCheckingCPULoad() {
        startTimeCPUCheking = mach_absolute_time()
    }
    
    func stopCheckingCPULoad(clouser: (Double) -> () ) {
        let endTime = mach_absolute_time()
        guard let startTimeCPUCheking else { return }
        let elapsedTicks = endTime - startTimeCPUCheking
        var timebaseInfo = mach_timebase_info_data_t()
        mach_timebase_info(&timebaseInfo)
        let elapsedSeconds = Double(elapsedTicks) * Double(timebaseInfo.numer) / Double(timebaseInfo.denom) / Double(NSEC_PER_SEC)
        SBLogger.logStartSdkTime(elapsedSeconds)
    }
    
    func endTraking(_ classDescription: String, clouser: (String) -> ()) {
        let endTime = CFAbsoluteTimeGetCurrent()
        guard let startTime else { return }
        let launchTime = endTime - startTime
        clouser("\(launchTime)")
        SBLogger.logScreenDownloadTime(launchTime, screen: classDescription)
    }
    
    private func hostCPULoadInfo() -> host_cpu_load_info? {
        let HOST_CPU_LOAD_INFO_COUNT = MemoryLayout<host_cpu_load_info>.stride/MemoryLayout<integer_t>.stride
        var size = mach_msg_type_number_t(HOST_CPU_LOAD_INFO_COUNT)
        var cpuLoadInfo = host_cpu_load_info()
        
        let result = withUnsafeMutablePointer(to: &cpuLoadInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: HOST_CPU_LOAD_INFO_COUNT) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &size)
            }
        }
        if result != KERN_SUCCESS {
            print("Error  - \(#file): \(#function) - kern_result_t = \(result)")
            return nil
        }
        return cpuLoadInfo
    }
}
