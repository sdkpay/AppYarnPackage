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
    private var startTime: CFAbsoluteTime?
    private var startTimeCPUCheking: UInt64?
    private var networkDataSize: Int?
    
    func startTraking() {
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func checkSavedDataSize(object: Codable) {
        let size = MemoryLayout.size(ofValue: object)
        print("Amount of downloaded data is \(size)")
    }
    
    func checkNetworkDataSize(object: Date) {
        let size = MemoryLayout.size(ofValue: object)
        networkDataSize = networkDataSize == nil ? size : networkDataSize! + size
    }
    
    func stopNetworkDataChecking() {
        guard let networkDataSize else { return }
        print("Amount of network data is \(networkDataSize)")
    }
    
    func startCheckingCPULoad() {
        let startTimeCPUCheking = mach_absolute_time()
    }
    
    func stopCheckingCPULoad() {
        let endTime = mach_absolute_time()
        guard let startTimeCPUCheking else { return }
        let elapsedTicks = endTime - startTimeCPUCheking
        var timebaseInfo = mach_timebase_info_data_t()
        mach_timebase_info(&timebaseInfo)
        let elapsedSeconds = Double(elapsedTicks) * Double(timebaseInfo.numer) / Double(timebaseInfo.denom) / Double(NSEC_PER_SEC)
        print("Общее время запуска SDK = \(elapsedSeconds) секунд")
    }
    
    func endTraking(_ classDescription: String) {
        var endTime = CFAbsoluteTimeGetCurrent()
        guard let startTime else { return }
        let launchTime = endTime - startTime
        print("Общее время запуска экрана \(classDescription): \(launchTime) секунд")
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
