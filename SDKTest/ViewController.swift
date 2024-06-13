//
//  ViewController.swift
//  SDKTest
//
//  Created by wangjun on 2019/11/12.
//  Copyright © 2019 wangjun. All rights reserved.
//

import UIKit

/*
 本Demo展示大部分设备协议功能，如要设置闹钟或者久坐等功能，请下载Keep Health APP来进行配合调试
 (This demo shows most of the device protocol functions.
 If you want to set the alarm clock or sedentary functions,
 please download the Keep Health APP for debugging.)
 */
class ViewController: UIViewController {
    let btProvider = ZHJBLEManagerProvider.shared
    let syncTimeProcessor = ZHJSyncTimeProcessor()
    let noticeProcessor = ZHJMessageNoticeProcessor()
    let sportModeProcessor = ZHJSportModeProcessor()
    let clearDeviceProcessor = ZHJClearDeviceProcessor()
    let sedentaryProcessor = ZHJSedentaryProcessor()
    let sportTargetProcessor = ZHJSportTargetProcessor()
    let HR_BP_BOProcessor = ZHJHR_BP_BOProcessor()
    let userInfoProcessor = ZHJUserInfoProcessor()
    let firmwareProcessor = ZHJFirmwareUpgradeProcessor()
    let batteryProcessor = ZHJBatteryProcessor()
    let alarmClockProcessor = ZHJAlarmClockProcessor()
    let deviceInfoProcessor = ZHJDeviceInfoProcessor()
    let enablePairProcessor = ZHJEnablePairProcessor()
    let stepAndSleepProcessor = ZHJStepAndSleepProcessor()
    let deviceConfigProcessor = ZHJDeviceConfigProcessor()
    let deviceClearProcessor = ZHJClearDeviceProcessor()
    let deviceControlProcessor = ZHJDeviceControlProcessor()
    let pairCodeProcessor = ZHJPairingCodeProcessor()
    let messageProcessor = ZHJMessageProcessor()
    let temperatureProcessor = ZHJTemperatureProcessor()
    var datasource: [DeviceFunction] = [DeviceFunction]()
    let datasourceCreator = DataSource()
    var sleepRecordModels: [ZHJSleep] = [ZHJSleep]()
    var stepRecordModels: [ZHJStep] = [ZHJStep]()
    var deviceConfig = ZHJDeviceConfig()
    var HRTimingDetect_t = ZHJHRTimingDetect_t()
    var calculateRMR = false
    var temperatureAutoMeasure = false
    var user = ZHJUserInfo()
    lazy var functionTableView : UITableView = {
        let table = UITableView.init(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH - kScaleHeight(150)), style: .plain)
        table.rowHeight = 70
        return table
    }()
    
    // 장치 찾기 버튼
    lazy var scanBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: 30, y: kScreenH - kScaleHeight(140), width: kScreenW - 60, height: 50))
        btn.setTitle("Scan", for: .normal)
        btn.titleLabel?.font = kSystemFont(16)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(.lightGray, for: .highlighted)
        btn.backgroundColor = kHexColor(0x42AAF0)
        btn.layer.cornerRadius = 25
        btn.layer.masksToBounds = true
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.addTarget(self, action: #selector(scan), for: .touchUpInside)
        return btn
    }()
    
    @objc func scan() {
        if btProvider.deviceState == .connected {
            btProvider.disconnectDevice { (p) in
                SVProgressHUD.showSuccess(withStatus: "Disconnected")
            }
        }
        else {
            let scanVC = ScanDeviceViewController()
            scanVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(scanVC, animated: true)
        }
        
    }

    func setupUI() {
        view.addSubview(functionTableView)
        view.addSubview(scanBtn)
        title = "Home"
    }
    

    func loadDatasource() {
        functionTableView.delegate = self
        functionTableView.dataSource = self
        datasource = datasourceCreator.loadDataSource()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDatasource()
        setupUI()
        /**개발자들이 비즈니스 로직을 구현하기 위해 SDK를 호출할 때,
         의 순서를 철저히 지켜주시기 바랍니다
         [Bluetooth Ready]-> [기기 검색]-> [연결된 기기]-> [데이터 쓰기 채널 검색]-> [기능 인터페이스]
         */
        // 장치가 연결됨
        kNotificationCenter.addObserver(self, selector: #selector(deviceConnected), name: .NOTIFY_DEVICE_DID_CONNECT, object: nil)
        // 장치 연결 끊김
        kNotificationCenter.addObserver(self, selector: #selector(deviceDisconnected), name: .NOTIFY_DEVICE_DID_DISCONNECT, object: nil)
        // 데이터 전송 시간 초과
        kNotificationCenter.addObserver(self, selector: #selector(timeout),name: .NOTIFY_BLE_DATA_TIMEOUT,object: nil)
        foundServerCharacteristics()
    }
    
    // 특정 장비에만 있는 기능, 없으면 상관하지 않음
    // 보정값 설정
    func setHR_BP_BOCalibration(){
        ZHJHR_BP_BOProcessor.shared.setHR_BP_BOCalibration(HR: 76, DBP: 64, SBP: 102, BO: 98) { (ERR) in
            
        }
    }
    
    // 특정 장비에만 있는 기능, 없으면 상관하지 않음
    // 교정 설정 읽기
    func readHR_BP_BOCalibration(){
        ZHJHR_BP_BOProcessor.shared.readHR_BP_BOCalibration { (HR, DBP, SBP, BO) in
            
        }
    }
    
    // 특정 장비에만 있는 기능, 없으면 상관하지 않음
    func receiveRealTimeHealthData() {
        ZHJRealTimeHealthDataProcessor.shared.realTimeHealthDataAlarmDidReceived { (alarms) in
            var  message = "接收到了健康数据报警\n"
            for alarm in alarms {
                switch alarm.type {
                
                case .lowHR:
                    message += "心率低：\(alarm.value)\n"
                case .highHR:
                    message += "心率高：\(alarm.value)\n"
                case .lowDBP:
                    message += "舒张压低：\(alarm.value)\n"
                case .highDBP:
                    message += "舒张压高：\(alarm.value)\n"
                case .lowSBP:
                    message += "收缩压低：\(alarm.value)\n"
                case .highSBP:
                    message += "收缩压高：\(alarm.value)\n"
                case .lowBO:
                    message += "血氧低：\(alarm.value)\n"
                case .highTEMP:
                    message += "体温高：\((Double(alarm.value)/100.0).truncate(places: 1))\n"
                @unknown default:
                    break
                }
            }
            ZHJShowMessage(self, message)
            Tools.writeToFile(with: message, withFileName: "HealthDataAlarm.log")
        }
    }
    
    // 특정 장비에만 있는 기능, 없으면 상관하지 않음
    func setHealthDataAlarm() {
        ZHJTemperatureProcessor.shared.setTemperatureAlarmLimit(maxTemperature: 3650, isOn: true) { (result) in
            
        }
        
        delay(by: 1.5) {
            let HRAlarm = ZHJHRAlarm_t()
            HRAlarm.alarmEnable = true
            HRAlarm.max = 75
            HRAlarm.min = 72
            
            let BPAlarm = ZHJBPAlarm_t()
            BPAlarm.alarmEnable = true
            BPAlarm.maxDBP = 70
            BPAlarm.minDBP = 60
            BPAlarm.maxSBP = 120
            BPAlarm.minSBP = 115
            
            let BOAlarm = ZHJBOAlarm_t()
            BOAlarm.alarmEnable = true
            BOAlarm.min = 98
            ZHJHR_BP_BOProcessor.shared.setHR_BP_BOAlarmLimit(HRAlarm: HRAlarm, BPAlarm: BPAlarm, BOAlarm: BOAlarm) { (result) in
                
            }
        }
    }
    
    func readHealthDataAlarm() {
        ZHJTemperatureProcessor.shared.readTemperatureAlarmSetting { (alarm) in
            
        }
        
        delay(by: 1.5) {
            ZHJHR_BP_BOProcessor.shared.readHR_BP_BOAlarmSetting { (HRAlarm, BPAlarm, BOAlarm) in
                
            }
        }
    }
    
    func readRealTimeHealthData() {
        ZHJRealTimeHealthDataProcessor.shared.readRealTimeHealthData { (HR, BP, BO, STEP, TEMP) in
            
        }
    }

    func syncUserInfo() {
        user.sex = 0
        user.height = 170
        user.weight = 600
        user.age = 25
        user.sex = 0
        self.userInfoProcessor.writeUserInfo(user) {[weak self] (result) in
            guard let `self` = self else { return }
            guard result == .correct else {
                return
            }
        }
    }
    
    // 자동 재연결(Auto reconnect)
    func autoReconnect() {
        btProvider.autoReconnect(success: { (p) in
            print("重连成功(Reconnect done)")
        }) { (p, err) in
            print("重连失败(Reconnect failed)")
        }
    }
    
}

extension ViewController {
    // 장치 읽기/ 쓰기 특성값 발견
    func foundServerCharacteristics() {
        ZHJBLEManagerProvider.shared.discoverReadCharacteristic { (characteristic) in }
        ZHJBLEManagerProvider.shared.discoverWriteCharacteristic {[weak self] (characteristic) in
            guard let `self` = self else { return }
            //(기능 파라미터 데이터는 읽기-쓰기 채널이 발견된 경우에만 읽고 설정할 수 있습니다.)
            delay(by: 0.5) {
                SVProgressHUD.dismiss()
                self.syncUserInfo()
                delay(by: 0.5) {
                    if self.btProvider.currentDevice?.name.contains("HULDEL") ?? false {
                        delay(by: 0.5) {
                            self.sendPairCode()
                        }
                    }
                }
            }
        }
    }
    
    @objc func deviceConnected(noti: Notification) {
        self.title = (btProvider.currentDevice?.name ?? "未知设备(Unknow)") + "已连接(connected)"
        scanBtn.setTitle("点击断开连接(Click to disconnect)", for: .normal)
        
    }
    
    @objc func deviceDisconnected(noti: Notification) {
        self.title = "Home"
        scanBtn.setTitle("搜索设备(Scan)", for: .normal)
    }
    
    @objc func timeout(noti: Notification) {
        //timeout
        //eg:
        let obj = noti.userInfo
        if let dict = obj as? [String: Any], let api = dict["api"] as? ZHJBleApiCMD{
            switch api {
            case .readBatteryPower:
                print("Read battery power timeout")
            default:
                break
            }
        }
    }
       
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "cell")
        let function = datasource[indexPath.row]
        cell.textLabel?.text = function.funcName
        //                    cell.selectionStyle = .none
        cell.accessoryType = .none
        cell.textLabel?.textColor = .gray
        cell.textLabel?.numberOfLines = 2
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard ZHJBLEManagerProvider.shared.deviceState == .connected else {
            SVProgressHUD.showError(withStatus: kLocalized("设备未连接(Device disconnected)"))
            return
        }
        let function = datasource[indexPath.row]
        switch function.functionType {
        case .currentStep:
            readCurrentStep()
            
        case .currentHR_BP_BO:
            readCurrentHeartrate()
            
        case .historyStepAndSleep:
            readHistoryStepAndSleep()
            
        case .historyHR_BP_BO:
            readHistoryHeartrate()
            
        case .historySportMode:
            readHistorySportMode()
            
        case .deviceInfo:
            readDeviceInfo()
            
        case .deviceConfig:
            readDeviceConfig()
            
        case .batteryPower:
            readBatteryPower()
            
        case .syncTime:
            syncTime()
            
        case .syncLanguage:
            syncLanguage()
            
        case .readAlarmClock:
            readAlarmClock()
            
        case .readSedentary:
            readSedentary()
            
        case .findDevice:
            findDevice()
            
        case .reset:
            resetDevice()
            
        case .trunWrist:
            trunWrist()
        //readRealTimeHealthData()
            
        case .heartAutoMeasure:
            break
            
        case .sendPairCode:
            sendPairCode()
            
        case .endPairCode:
            endPairCode()
            
        case .sendMessage:
            sendMessage()
            
        case .notice:
            break
            
        case .takePhoto:
            takePhoto()
            
        case .takePhotoCancel:
            takePhotoCancel()
        case .messageSwitch:
            messageSwitch()
        case .currentTemperature:
            readCurrentTemperature()
        case .historyTemperature:
            readHistoryTemperature()
        case .temperatureAutoMeasure:
            temperatureAutoMeasure(isOn: !self.temperatureAutoMeasure)
        case .RMRSwitch:
            
            self.setBodyInfo(user, calculateRMR: !self.calculateRMR)
        }
    }
    
}

extension ViewController {
    //(과거 단계 및 수면 데이터 읽기)
    func readHistoryStepAndSleep() {
        SVProgressHUD.show()
        sleepRecordModels.removeAll()
        stepRecordModels.removeAll()
        let stepAndSleepSemaphore = DispatchSemaphore(value: 0)
        let stepAndSleepQueue = DispatchQueue.init(label: "BRANCH_STEP_SLEEP")//定义队列
        for i in 0..<7{
            let date = DateClass.dateStringOffset(from: today, offset: -i)
            stepAndSleepQueue.async {
                print("开始计步睡眠任务(Read history record begin)\(i)")
                self.stepAndSleepProcessor.readStepAndSleepHistoryRecord(date: date, historyDataHandle: {[weak self] (stepModel, sleepModel) in
                    guard let `self` = self else { return }
                    //插入计步数据
                    self.stepRecordModels.append(stepModel)
                    self.sleepRecordModels.append(sleepModel)
                    //处理睡眠数据,无效的睡眠数据不处理
                    if sleepModel.details.count > 0 {
                        self.mergeSleepWithDB(sleeps: sleepModel.splitSleep())
                    }
                    print("完成计步睡眠任务(Read history record end)\(i)")
                    stepAndSleepSemaphore.signal()
                    if i == 6{
                        SVProgressHUD.dismiss()
                        var stepMessage = ""
                        for model in self.stepRecordModels {
                            stepMessage += "\n日期(Date)：\(model.dateTime)\n步数(Step)：\(model.step)\n距离(Distance)：\(model.distance)\n消耗卡路里(Calories)：\(model.calories)\n"
                        }
                        var sleepMessage = ""
                        for model in self.sleepRecordModels {
                            let totlaSleepDuration = model.awakeDuration + model.beginDuration + model.lightDuration + model.deepDuration + model.REMDuration
                            let durationStr = String(format:  " %02d " + "小时(H)" + " %02d " + "分钟(Min)", totlaSleepDuration/60, totlaSleepDuration%60)
                            sleepMessage += "\n日期(Date)：\(model.dateTime)\n清醒睡眠时长(Awake)\(model.awakeDuration)分钟(Min)\n入睡时长(Falling asleep)：\(model.beginDuration)分钟(Min)\n浅睡时长(Light sleep)：\(model.lightDuration)分钟(Min)\n深睡时长：\(model.deepDuration)分钟(Min)\nREM睡眠时长(REM)：\(model.REMDuration)分钟(Min)\n总睡眠时长(Total)：\(durationStr)\n"
                        }
                        ZHJShowMessage(self, stepMessage + "\n" + "\n" + sleepMessage)
                    }
                    }, historyDoneHandle: { (obj) in
                        SVProgressHUD.dismiss()
                        stepAndSleepSemaphore.signal()
                        print("完成计步睡眠任务(Read history record end)\(i)")
                        var stepMessage = ""
                        for model in self.stepRecordModels {
                            stepMessage += "\n日期(Date)：\(model.dateTime)\n步数(Step)：\(model.step)\n距离(Distance)：\(model.distance)\n消耗卡路里(Calories)：\(model.calories)\n"
                        }
                        var sleepMessage = ""
                        for model in self.sleepRecordModels {
                            let totlaSleepDuration = model.awakeDuration + model.beginDuration + model.lightDuration + model.deepDuration + model.REMDuration
                            let durationStr = String(format:  " %02d " + "小时(H)" + " %02d " + "分钟(Min)", totlaSleepDuration/60, totlaSleepDuration%60)
                            sleepMessage += "\n日期(Date)：\(model.dateTime)\n清醒睡眠时长(Awake)\(model.awakeDuration)分钟(Min)\n入睡时长(Falling asleep)：\(model.beginDuration)分钟(Min)\n浅睡时长(Light sleep)：\(model.lightDuration)分钟(Min)\n深睡时长：\(model.deepDuration)分钟(Min)\nREM睡眠时长(REM)：\(model.REMDuration)分钟(Min)\n总睡眠时长(Total)：\(durationStr)\n"
                        }
                        ZHJShowMessage(self, stepMessage + "\n" + "\n" + sleepMessage)
                })
                stepAndSleepSemaphore.wait()
            }
        }
    }
    
    // 심박수, 혈압, 혈중 산소의 과거 데이터 읽기(개발자는 과거 데이터를 반복적으로 얻어야 함)
    func readHistoryHeartrate() {
        SVProgressHUD.show()
        var hrRecordModels: [ZHJHeartRate] = [ZHJHeartRate]()
        var bpRecordModels: [ZHJBloodPressure] = [ZHJBloodPressure]()
        var dataSyncDone = 0
        let HR_BP_BOSemaphore = DispatchSemaphore(value: 0)
        let HR_BP_BOQueue = DispatchQueue.init(label: "BRANCH_HR_BP_BO")//定义队列
        for i in 0..<7{
            let date = DateClass.dateStringOffset(from: today, offset: -i)
            HR_BP_BOQueue.async {
                if dataSyncDone == 1 {
                    return
                }
                print("开始心率血压血氧任务(Read history record begin)\(i)")
                self.HR_BP_BOProcessor.readHR_BP_BOHistoryRecord(date, historyDataHandle: {[weak self] (HRModel, BPModel, BOModel) in
                    guard let `self` = self else { return }
                    hrRecordModels.append(HRModel)
                    bpRecordModels.append(BPModel)
                    print("完成心率血压血氧任务(Read history record end)\(i)")
                    HR_BP_BOSemaphore.signal()
                    // 최대 7개의 데이터를 읽고 작업을 종료합니다
                    if i == 6{
                        SVProgressHUD.dismiss()
                        dataSyncDone = 1
                        var HRMessage = ""
                        for model in hrRecordModels {
                            HRMessage += "\n日期(Date)：\(model.dateTime)\n平均心率(AVG)：\(model.avg)\n最大心率(MAX)：\(model.max)\n最小心率(MIN)：\(model.min)\n"
                        }
                        var BPMessage = ""
                        for model in bpRecordModels {
                            //Demo取每日最后一次记录，用户可根据具体需求取需要的数值
                            let lastBP = model.details.last ?? ZHJBloodPressureDetail()
                            BPMessage += "\n日期(Date)：\(model.dateTime)\n舒张压(Diastolic pressure)：\(lastBP.DBP)\n收缩压(Systolic pressure)：\(lastBP.SBP)\n"
                        }
                        ZHJShowMessage(self, HRMessage + "\n" + BPMessage)
                    }
                    }, historyDoneHandle: { (obj) in
                        HR_BP_BOSemaphore.signal()
                        SVProgressHUD.dismiss()
                        dataSyncDone = 1
                        print("完成心率血压血氧任务(Read history record end)\(i)")
                        var HRMessage = ""
                        for model in hrRecordModels {
                            HRMessage += "\n日期(Date)：\(model.dateTime)\n平均心率(AVG)：\(model.avg)\n最大心率(MAX)：\(model.max)\n最小心率(MIN)：\(model.min)\n"
                        }
                        var BPMessage = ""
                        for model in bpRecordModels {
                            //Demo 일일 마지막 기록으로 사용자가 원하는 수치를 얻을 수 있습니다
                            let lastBP = model.details.last ?? ZHJBloodPressureDetail()
                            BPMessage += "\n日期(Date)：\(model.dateTime)\n舒张压(Diastolic pressure)：\(lastBP.DBP)\n收缩压(Systolic pressure)：\(lastBP.SBP)\n"
                        }
                        ZHJShowMessage(self, HRMessage + "\n" + BPMessage)
                })
                HR_BP_BOSemaphore.wait()
            }
        }
    }
    
 
    
    //MARK: - 온도의 과거 데이터 읽기 (developers should get historical data in a loop)
    func readHistoryTemperature() {
        SVProgressHUD.show()
        var temperatureModels: [ZHJTemperature] = [ZHJTemperature]()
        var dataSyncDone = 0
        let temperatureSemaphore = DispatchSemaphore(value: 0)
        let temperatureQueue = DispatchQueue.init(label: "BRANCH_TEMPERATURE")//定义队列
        for i in 0..<7{
            let date = DateClass.dateStringOffset(from: today, offset: -i)
            temperatureQueue.async {
                if dataSyncDone == 1 {
                    return
                }
                print("开始体温任务(Read history record begin)\(i)")
                self.temperatureProcessor.readTemperatureHistoryRecord(date, historyDataHandle: {[weak self] (temperatureModel) in
                    guard let `self` = self else { return }
                    temperatureModels.append(temperatureModel)
                    print("完成体温任务(Read history record end)\(i)")
                    temperatureSemaphore.signal()
                    // 최대 7개의 데이터를 읽고 작업을 종료합니다
                    if i == 6{
                        SVProgressHUD.dismiss()
                        dataSyncDone = 1
                        var message = ""
                        for model in temperatureModels {
                            message += "\n日期(Date)：\(model.dateTime)\n平均体温(AVG)：\((Double(model.avg)/100.0).truncate(places: 1))\n最高体温(MAX)：\((Double(model.max)/100.0).truncate(places: 1))\n最低体温(MIN)：\((Double(model.min)/100.0).truncate(places: 1))\n"
                        }
                        
                        ZHJShowMessage(self, message)
                    }
                    }, historyDoneHandle: { (obj) in
                        temperatureSemaphore.signal()
                        SVProgressHUD.dismiss()
                        dataSyncDone = 1
                        print("完成体温任务(Read history record end)\(i)")
                        var message = ""
                        for model in temperatureModels {
                            message += "\n日期(Date)：\(model.dateTime)\n平均体温(AVG)：\((Double(model.avg)/100.0).truncate(places: 1))\n最高体温(MAX)：\((Double(model.max)/100.0).truncate(places: 1))\n最低体温(MIN)：\((Double(model.min)/100.0).truncate(places: 1))\n"
                        }
                        
                        ZHJShowMessage(self, message)
                })
                temperatureSemaphore.wait()
            }
        }
    }
    
    //MARK: 운동 이력 데이터 읽기
    func readHistorySportMode() {
        SVProgressHUD.show()
        var sportRecordModels: [ZHJSportMode] = [ZHJSportMode]()
        var sportDataSyncDone = 0
        let sportSemaphore = DispatchSemaphore(value: 0)
        let sportQueue = DispatchQueue.init(label: "BRANCH_SPORT")//定义队列
        for i in 0..<5{
            sportQueue.async {
                if sportDataSyncDone == 1 {
                    return
                }
                self.sportModeProcessor.readSportModeHistoryRecord(sportModeHandle: { [weak self](sportModel) in
                    guard let `self` = self else { return }
                    if let model = sportModel {
                        sportRecordModels.append(model)
                    }
                    sportSemaphore.signal()
                    print("完成运动历史任务(Read history record end)\(i)")
                    }, historyDoneHandle: { (obj) in
                        sportDataSyncDone = 1
                        sportSemaphore.signal()
                        SVProgressHUD.dismiss()
                        print("完成获取运动模式数据(Read history record end)")
                        var message = ""
                        for model in sportRecordModels {
                            let durationStr = String(format:  " %02d 小时(H) %02d 分钟(Min) %02d 秒", model.duration/3600, (model.duration%3600)/60, (model.duration%3600)%60)
                            let paceStr = String(format:  "%02d\'" + "%02d\"", model.duration/60, (model.duration/60)%60)
                           // let heartRatesStr = model.heartRateArr.map{}
                            message += "\n日期时间(Date)：\(model.dateTime)\n运动类型(Exercise Mode)：\(model.getSportName())\n时长(Duration)：\(durationStr)\n距离(Distance)：\(model.distance)\n消耗卡路里(Calories)：\(model.calories)\n步数(Steps)：\(model.step)\n平均心率(Heart rate)：\(model.heartRate)\n配速(Pace)：\(paceStr)\n心率连续监测数据(Heart rate array)：\(model.heartRateArr.debugDescription)\n"
                        }
                        ZHJShowMessage(self, message)
                })
                sportSemaphore.wait()
            }
            
        }
        
        
    }
    
    //MARK: 현재 단계 읽기
    func readCurrentStep() {
        SVProgressHUD.show()
        stepAndSleepProcessor.readCurrentStep {[weak self] (stepModel) in
            guard let `self` = self else {return}
            SVProgressHUD.dismiss()
            ZHJShowMessage(self, "当前步数(Steps)：\(stepModel.step)\n当前距离(Distance)：\(stepModel.distance)\n消耗卡路里(Calories)：\(stepModel.calories)")
        }
    }
    
    //MARK: 현재 심박수 읽기
    func readCurrentHeartrate() {
        SVProgressHUD.show()
        HR_BP_BOProcessor.readCurrentHR_BP_BO { [weak self] (heartrateModel, bloodPressureModel, bloodOxygenModel) in
            guard let `self` = self else {return}
            SVProgressHUD.dismiss()
            ZHJShowMessage(self, "当前心率(Heart rate)：\(heartrateModel.HR)")
        }
    }
    
    //MARK: 현재 체온 판독
    func readCurrentTemperature() {
        SVProgressHUD.show()
        temperatureProcessor.readCurrentTemperature { [weak self] (temperature) in
            guard let `self` = self else {return}
            SVProgressHUD.dismiss()
            let vaildTemperature = temperature.wristTemperature > 0 ? (Double(temperature.wristTemperature)/100.0).truncate(places: 1) :  (Double(temperature.headTemperature)/100.0).truncate(places: 1)
            ZHJShowMessage(self, "当前体温(Temperature)：\(vaildTemperature)℃")
        }
    }
    
    //MARK: 기본 장치 정보 읽기
    func readDeviceInfo() {
        SVProgressHUD.show()
        deviceInfoProcessor.readDeviceInfo(deviceInfoHandle: {[weak self](device) in
            guard let `self` = self else { return }
            SVProgressHUD.dismiss()
            ZHJBLEManagerProvider.shared.currentDevice?.version = device.version
            ZHJBLEManagerProvider.shared.currentDevice?.mac = device.mac
            ZHJBLEManagerProvider.shared.currentDevice?.model = device.model
            ZHJShowMessage(self, "设备固件版本(Firmware version)：\(device.version)\n设备MAC地址(MAC address)：\(device.mac)\n设备型号(Device model)：\(device.model ?? "")")
        })
    }
    
    //MARK: 장치 구성 읽기
    func readDeviceConfig() {
        SVProgressHUD.show()
        deviceConfigProcessor.readDeviceConfig {[weak self] (config) in
            guard let `self` = self else { return }
            SVProgressHUD.dismiss()
            self.deviceConfig = config
            ZHJShowMessage(self, "设备语言(Language)：\(config.language.getLanguageName())\n设备单位(Uint)：\(config.unit == .metric ? "公制(Metric)" : "英制(Imperial)")\n设备时间制式(Time model)：\(config.timeMode == .hour12 ? "12小时制(AM/PM)" : "24小时制(24 Hour Clock)")\n设备消息通知开关(Social app message notification reminder Switch)：\(config.notice ? "开(ON)" : "关(OFF)")\n翻腕亮屏(Trun wrist)：\(config.trunWrist ? "开(ON)" : "关(OFF)")\n音乐控制开关(Music Control Swicth)：\(config.musicCtrl ? "开(ON)" : "关(OFF)")\n体温单位(Temperature Unit)：\(config.temperatureUnit == .celsius ? "摄氏度(Celsius)" : "华氏度(Fahrenheit)")")
        }
    }
    
    //MARK: 배터리 전원 읽기
    func readBatteryPower() {
        SVProgressHUD.show()
        batteryProcessor.readBatteryPower(batteryHandle: {[weak self] (power) in
            guard let `self` = self else { return }
            SVProgressHUD.dismiss()
            ZHJBLEManagerProvider.shared.currentDevice?.power = power
            ZHJShowMessage(self, "当前设备电量(Power)：\(power)%")
        })
    }
    
    //MARK: 동기화된 시간
    func syncTime() {
        SVProgressHUD.show()
        syncTimeProcessor.writeTime(ZHJSyncTime.init(Date())) {[weak self] (result) in
            guard let `self` = self else { return }
            SVProgressHUD.dismiss()
            guard result == .correct else {
                SVProgressHUD.showSuccess(withStatus: "同步失败(Synchronised failed)")
                return
            }
            SVProgressHUD.showSuccess(withStatus: "同步成功(Synchronised done)")
        }
    }
    
    //MARK: 동기화 언어
    func syncLanguage() {
        SVProgressHUD.show()
        deviceConfig.timeMode = Tools.is12HourFormat() ? .hour12 : .hour24
        deviceConfig.language = self.getLanguage()
        deviceConfig.temperatureUnit =  deviceConfig.temperatureUnit == .celsius ? .fahrenheit : .celsius
        deviceConfigProcessor.writeDeviceConfig(deviceConfig, setHandle: {[weak self] (result) in
            guard let `self` = self else { return }
            SVProgressHUD.dismiss()
            SVProgressHUD.showSuccess(withStatus: "同步成功(Synchronised done)")
        })
    }
    
    //MARK: 알람시계 읽기
    func readAlarmClock() {
        SVProgressHUD.show()
        alarmClockProcessor.readAlarmClock { [weak self](alarms) in
            //SVProgressHUD.dismiss()
            guard let `self` = self else { return }
            var message = ""
            for model in alarms {
                let time = String(format:  "%02d:%02d", model.hour, model.minute)
                let cycle = model.cycleString()
                message += "响铃时间(Ring time)：\(time)\n闹钟类型(Alarm Model)：\(model.typeString())\n闹钟重复周期(Repeat cycle)：\(cycle)\n闹钟开关(Switch)：\(model.isOpen ? "开(ON)" : "关(OFF)")"
            }
            ZHJShowMessage(self, message)
            SVProgressHUD.dismiss()
        }
    }
    
    //MARK: 좌식 읽기
    func readSedentary() {
        SVProgressHUD.show()
        sedentaryProcessor.readSedentary {[weak self](sedentary) in
            guard let `self` = self else { return }
            SVProgressHUD.dismiss()
            ZHJShowMessage(self, "开始时间(Begin time)：\(sedentary.beginTime):00\n结束时间(End time)：\(sedentary.endTime):00\n提醒间隔时间(Reminder interval)：\(sedentary.intervalsString())\n生效周期(Repeat cycle)：\(sedentary.cycleString())\n提醒开关(Switch)：\(sedentary.isOpen ? "开(ON)" : "关(OFF)")")
        }
    }
    
    //MARK: 재시작
    func resetDevice() {
        SVProgressHUD.show()
        deviceClearProcessor.resetDevice {[weak self] (result) in
            guard let `self` = self else { return }
            SVProgressHUD.dismiss()
            guard result == .correct else {
                SVProgressHUD.showError(withStatus: kLocalized("重置失败(Reset Failed)"))
                return
            }
            SVProgressHUD.showError(withStatus: kLocalized("重置成功(Reset done)"))
        }
    }
    
    //MARK: 장치 찾기
    func findDevice() {
        SVProgressHUD.show()
        deviceControlProcessor.findDevice { (result) in
            SVProgressHUD.showSuccess(withStatus: kLocalized("查找成功(Find done)"))
        }
    }
    
    //MARK: 사진 취소
    func takePhotoCancel() {
        SVProgressHUD.show()
        deviceControlProcessor.takePhotoCancel { (result) in
            SVProgressHUD.showSuccess(withStatus: "取消拍照(Cancel photo)")
        }
    }
    
    //MARK: 사진찍기
    func takePhoto() {
        SVProgressHUD.show()
        deviceControlProcessor.takePhoto { (result) in
            SVProgressHUD.showSuccess(withStatus: "拍照(Take photo)")
        }
    }
    
    //MARK: 손목틀기
    func trunWrist() {
        SVProgressHUD.show()
        let config = deviceConfig
        config.trunWrist = !config.trunWrist
        
        deviceConfigProcessor.writeDeviceConfig(config, setHandle: {[weak self] (result) in
            guard let `self` = self else { return }
            SVProgressHUD.dismiss()
            SVProgressHUD.showSuccess(withStatus: "翻腕亮屏已(Switch)\(self.deviceConfig.trunWrist ? "开(ON)" : "关(OFF)")")
            self.deviceConfig.trunWrist = config.trunWrist
        })
    }
    
    //MARK: 소셜 앱 메시지 알림 리마인드 마스터 스위치
    func messageSwitch() {
        SVProgressHUD.show()
        let config = deviceConfig
        config.notice = !config.notice
        deviceConfigProcessor.writeDeviceConfig(config, setHandle: {[weak self] (result) in
            guard let `self` = self else { return }
            SVProgressHUD.dismiss()
            SVProgressHUD.showSuccess(withStatus: "消息通知总开关已(Switch)\(self.deviceConfig.notice ? "开(ON)" : "关(OFF)")")
            self.deviceConfig.notice = config.notice
        })
    }
    
    
    //MARK: 심박수 자동 측정
    func heartAutoMeasure() {
        //SVProgressHUD.show()
        //暂写死15分钟
        HR_BP_BOProcessor.setAutoDetectHeartRate(interval: 15, isOn: true) {[weak self] (result) in
            //SVProgressHUD.dismiss()
            guard let `self` = self else { return }
            guard result == .correct else {
                SVProgressHUD.showError(withStatus: kLocalized("保存失败(Save failed)"))
                return
            }
        }
    }
    
    //MARK: 온도 자동 측정
    func temperatureAutoMeasure(isOn: Bool) {
        //SVProgressHUD.show()
        //暂写死15分钟
        temperatureProcessor.setAutoDetectTemperature(interval: 15, isOn: isOn) {[weak self] (result) in
            //SVProgressHUD.dismiss()
            guard let `self` = self else { return }
            guard result == .correct else {
                SVProgressHUD.showError(withStatus: kLocalized("保存失败(Save failed)"))
                return
            }
            self.temperatureAutoMeasure = isOn
            SVProgressHUD.showSuccess(withStatus: "自动测温已开启(temperature auto measure Switch)\(self.temperatureAutoMeasure ? "开(ON)" : "关(OFF)")）")
            
        }
    }
    
    //MARK: 계산을 위한 개인 신체 정보 설정 step history calories
    func setBodyInfo(_ user: ZHJUserInfo, calculateRMR: Bool) {
        ZHJBLEManagerProvider.shared.setBodyInfo(gender: user.sex, age: user.age, height: CGFloat(user.height), weight: CGFloat(user.weight/10), calculateRMR: calculateRMR)
        self.calculateRMR = calculateRMR
        SVProgressHUD.showSuccess(withStatus: "增加静息卡路里(RMR Switch)\(self.calculateRMR ? "开(ON)" : "关(OFF)")）")
    }

    
    
    //MARK: 페어링 코드를 전송합니다(Pairing Code는 SDK에서 자동으로 생성되어 개발자에게 반환됩니다). 개발자는 사용자가 입력한 페어링 코드가 올바른지 여부를 판단하게 됩니다. 개발자는 디바이스를 연결한 후 이 방법을 호출하여 연결의 유효성을 확인해야 합니다. 만약 확인에 실패하면 스스로 디바이스의 연결을 끊습니다
    func sendPairCode() {
        SVProgressHUD.show()
        let code = self.pairCodeProcessor.sendPairingCode { (result) in
            guard result == .correct else {
                SVProgressHUD.showError(withStatus: "配对码发送失败(Send failed)")
                return
            }
            SVProgressHUD.showSuccess(withStatus: "配对码发送成功(Send done)")
        }
        //ZHJShowMessage(self, "发送的配对码为(Code)：\(code)")
        ZHJShowInputMessage(self, "请输入手环上显示的配对码(Please enter the pairing code shown on the bracelet)", cancelText: "取消(Cancel)", keyboardType: .numberPad, confirmText: "确定(Done)") {[weak self] (result, textFiled) in
            guard let `self` = self else { return }
            guard result else {
                return
            }
            if let text = textFiled.text, text.count > 0 {
                if text == code {
                    SVProgressHUD.showSuccess(withStatus: "配对完成(Pair Done)")
                    delay(by: 1.0) {
                        self.endPairCode()
                    }
                    
                }
                else {
                    SVProgressHUD.showError(withStatus: "配对码错误(Pair code incorrect)")
                    self.btProvider.disconnectDevice { (p) in
                        //Pair code incorrect ，disconnect device
                        self.title = "Home"
                    }
                }
            }
            
        }
    }
    
    //MARK: 끝 쌍 코드 UI
    func endPairCode() {
        //SVProgressHUD.show()
        self.pairCodeProcessor.closePairingCodeUI(pairCodeError: true) { (result) in
            guard result == .correct else {
                SVProgressHUD.showError(withStatus: "配对码关闭失败(End failed)")
                return
            }
            //SVProgressHUD.showSuccess(withStatus: "配对码关闭成功(End done)")
        }
    }
    
    //MARK: 사용자 정의 메시지 보내기
    func sendMessage() {
        ZHJShowInputMessage(self, "请输入要发送的消息(Please input content)", cancelText: "取消(Cancel)", keyboardType: UIKeyboardType.default, confirmText: "确定(Done)") { (result, textFeild) in
            if result {
                SVProgressHUD.show()
                if let text = textFeild.text, text.count > 0 {
                    self.messageProcessor.sendMessage(message: text) { (result) in
                        guard result == .correct else {
                            SVProgressHUD.showError(withStatus: "发送失败(Send failed)")
                            print("message send error")
                            return
                        }
                        SVProgressHUD.showSuccess(withStatus: "发送成功(Send done)")
                    }
                }
                else {
                    //没有消息就发送一个震动
                    self.messageProcessor.sendVibrate()
                }
                
            }
        }
        
    }
    
    //현재 최대 두 개까지 저장된 심전 이력 데이터 읽기
    func readECGHistoryRecord() {
        var ecgDataSyncDone = 0
        let ecgSemaphore = DispatchSemaphore(value: 0)
        let ecgQueue = DispatchQueue.init(label: "BRANCH_ECG")//定义队列
        while ecgDataSyncDone == 0 {
            ecgQueue.async {
                ZHJECGProcessor.shared.readEcgHistoryRecord(ecgHandle: {(ecgModel) in
                    //insertECGModel
                    
                    ecgSemaphore.signal()
                }, historyDoneHandle: { (obj) in
                    ecgDataSyncDone = 1
                    ecgSemaphore.signal()
                })
            }
            ecgSemaphore.wait()
        }
    }
    
    //심전계측을 시작하다
    func ecgStart() {
        ZHJECGProcessor.shared.ecgStart { (result) in
            print(result)
        }
    }
    
    //심전계측 종료
    func ecgEnd() {
        ZHJECGProcessor.shared.ecgEnd { (result) in
            print(result)
        }
    }
    
    //심전치를 읽으면 여기서 심전치가 계속 돌아옵니다
    func readECGValue() {
        ZHJECGProcessor.shared.readECG { (ecgValue) in
            print("ECG值： \(ecgValue)")
        }
    }
    
    //심장 전기 상태 읽기
    func readECGState() {
        ZHJECGProcessor.shared.readECGState { (state) in
            print("ECG状态： \(state)")
        }
    }
    
    //심전계측 과정에서의 심박수를 읽습니다. 여기서 심박수는 계속 돌아갑니다.
    func readECGHeartRate() {
        ZHJECGProcessor.shared.readHeartRate { (heartRate) in
            print("ECG当前心率： \(heartRate)")
        }
    }
    
    //심전 보고서 읽기
    func readECGReport() {
        ZHJECGProcessor.shared.readECGReport { (reports) in
            print("心电报告： \(reports)")
        }
    }
    
}

extension ViewController {
    //장치에서 제공하는 수면 데이터와 데이터베이스에 존재하는 데이터를 결합합니다
    func mergeSleepWithDB(sleeps: [ZHJSleep]) {
        //昨天下半夜睡眠数据 Sleep data in the middle of the night yesterday
        var yesterdayModel = sleeps.first!
        //今天上半夜睡眠数据 Midnight sleep data today
        var todayModel = sleeps.last!
        //查->拆->合->更新
        let modelsA = sleepRecordModels.filter{$0.dateTime == yesterdayModel.dateTime}
        sleepRecordModels.removeAll{$0.dateTime == yesterdayModel.dateTime}
        // 替换时间点 Replacement time
        let replaceDateA = DateClass.getTimeStrToDate(formatStr: "yyyy-MM-dd HH:mm", timeStr: yesterdayModel.dateTime + " 00:00")
        if let model = modelsA.first {
            var details = model.details
            //过滤掉当天00：00以后的数据 Filter out data from 00:00 on the current day
            details = details.filter{DateClass.getTimeStrToDate(formatStr: "yyyy-MM-dd HH:mm", timeStr: $0.dateTime) < replaceDateA}
            //数据替换 Replacement
            details.append(contentsOf: yesterdayModel.details)
            model.details = details
            model.countingSleepTypeDuration()
            yesterdayModel = model
        }
        
        sleepRecordModels.append(yesterdayModel)
        
        let modelsB = sleepRecordModels.filter{$0.dateTime == todayModel.dateTime}
        sleepRecordModels.removeAll{$0.dateTime == todayModel.dateTime}
        // 替换时间点 Replacement time
        let replaceDateB = DateClass.getTimeStrToDate(formatStr: "yyyy-MM-dd HH:mm", timeStr: yesterdayModel.dateTime + " 23:59")
        if let model = modelsB.first {
            var details = model.details
            model.details.removeAll()
            //过滤掉当天23：59以前的数据 Filter out data before 23:59 of the day
            details = details.filter{DateClass.getTimeStrToDate(formatStr: "yyyy-MM-dd HH:mm", timeStr: $0.dateTime) > replaceDateB}
            //数据替换 Replacement
            model.details.append(contentsOf: todayModel.details)
            model.details.append(contentsOf: details)
            model.countingSleepTypeDuration()
            todayModel = model
        }
        sleepRecordModels.append(todayModel)
    }
    
    /// MARK:- 현재 언어 가져오기
    func getCurrentLanguage() -> String {
        return Locale.preferredLanguages.first!
    }
    
    func getLanguage() -> ZHJlLanguage {
        var configLanguage: ZHJlLanguage = .english
        let language = getCurrentLanguage()
        switch language[0..<language.count - 3] {
        case "en":
            configLanguage = .english
        case "zh-Hans":
            configLanguage = .chinese
        case "ru":
            configLanguage = .russian
        case "uk":
            configLanguage = .ukrainian
        case "fr":
            configLanguage = .french
        case "es":
            configLanguage = .spanish
        case "pt":
            configLanguage = .portuguese
        case "de":
            configLanguage = .german
        case "ja":
            configLanguage = .japan
        case "pl":
            configLanguage = .poland
        case "it":
            configLanguage = .italy
        case "ro":
            configLanguage = .romania
        default:
            configLanguage = .english
        }
        return configLanguage
    }
}

extension ZHJSleep {
    //하루 종일의 수면 데이터는 00:00~11:00의 데이터와 21:00~23:59의 데이터로 구분됩니다
    func splitSleep() -> [ZHJSleep] {
        let kEndTime = " 11:00"
        let kBeginTime = " 21:00"
        // 前一天睡眠的下半夜结束时间节点,09:00可以自定义成其他时间，默认11点
        // End of the second night of the previous day's sleep time node, 09:00 can be customized to other times, the default is 9 o'clock
        let yesterdayEndTime = self.dateTime + kEndTime
        // 今天天睡眠的上半夜开始时间节点,21:00可以自定义成其他时间，默认21点
        // Today's midnight sleep start time node, 21:00 can be customized to other times, the default is 21:00
        let todayBeginTime = self.dateTime + kBeginTime
        
        //前一天后半夜的睡眠数据模型 Sleep data model of the previous day and the middle of the night
        let model1 = ZHJSleep()
        model1.details = self.details.filter{$0.dateTime.compare(yesterdayEndTime) == .orderedAscending
            || $0.dateTime.compare(yesterdayEndTime) == .orderedSame}
        model1.dateTime = self.dateTime
        model1.mid = self.mid
        model1.countingSleepTypeDuration()
        
        //今天前半夜的睡眠数据模型 Sleep data model in the middle of the night today
        let model2 = ZHJSleep()
        model2.details = self.details.filter{$0.dateTime.compare(todayBeginTime) == .orderedDescending
            || $0.dateTime.compare(todayBeginTime) == .orderedSame}
        model2.dateTime = DateClass.dateStringOffset(from: self.dateTime, offset: 1)
        model2.mid = self.mid
        model2.countingSleepTypeDuration()
        
        return [model1, model2]
    }
    
    //취침시간수
    func countingSleepTypeDuration() {
        self.beginDuration = self.details.filter{$0.type == 1}.reduce(0){$0 + $1.duration}
        self.lightDuration = self.details.filter{$0.type == 2}.reduce(0){$0 + $1.duration}
        self.deepDuration = self.details.filter{$0.type == 3}.reduce(0){$0 + $1.duration}
        self.awakeDuration = self.details.filter{$0.type == 4}.reduce(0){$0 + $1.duration}
        self.REMDuration = self.details.filter{$0.type == 5}.reduce(0){$0 + $1.duration}
    }
}

extension ZHJlLanguage {
    func getLanguageName() -> String {
        var name = ""
        switch self {
        case .english:
            name = "英语"
        case .chinese:
            name = "中文"
        case .russian:
            name = "俄语"
        case .ukrainian:
            name = "乌克兰语"
        case .french:
            name = "法语"
        case .spanish:
            name = "西班牙语"
        case .portuguese:
            name = "葡萄牙语"
        case .german:
            name = "德语"
        case .japan:
            name = "日语"
        case .poland:
            name = "波兰语"
        case .italy:
            name = "意大利语"
        case .romania:
            name = "罗马语"
        @unknown default:
            name = "未知"
        }
        return name
    }
}

extension ZHJSportMode {
    func getSportName() -> String {
        switch ZHJSportModeType(rawValue: sportType) {
        case .some(.walk):
            return kLocalized("步行")
        case .some(.run):
            return kLocalized("跑步")
        case .some(.ride):
            return kLocalized("骑行")
        case .some(.indoorRun):
            return kLocalized("室内跑步")
        case .some(.freeTrain):
            return kLocalized("自由训练")
        case .some(.football):
            return kLocalized("足球")
        case .some(.basketball):
            return kLocalized("篮球")
        case .some(.badminton):
            return kLocalized("羽毛球")
        case .some(.ropeSkip):
            return kLocalized("跳绳")
        case .some(.pushUps):
            return kLocalized("俯卧撑")
        case .some(.sitUps):
            return kLocalized("仰卧起坐")
        case .some(.climb):
            return kLocalized("登山")
        case .some(.tennis):
            return kLocalized("网球")
        default:
            return kLocalized("未知")
        }
    }
}

extension ZHJAlarmClock {
    func cycleString() -> String {
        var cycleString = ""
        if !cycle.contains(true) {
            cycleString = kLocalized("仅一次")
        }
        else if !cycle.contains(false) {
            cycleString = kLocalized("每天")
        }
        else {
            let weeks = SelectList.weeks
            for (index, weekIsOn) in cycle.enumerated() {
                cycleString += weekIsOn ? " " + weeks[index] : ""
            }
        }
        return cycleString
    }
    
    func typeString() -> String {
        let types_string = SelectList.alarmClockTypes
        return types_string[type.rawValue]
    }
}

struct SelectList {
    static let weeks = [kLocalized("周一"), kLocalized("周二"), kLocalized("周三"), kLocalized("周四"), kLocalized("周五"), kLocalized("周六"), kLocalized("周日")]
    static let alarmClockTypes = [kLocalized("默认"), kLocalized("喝水"), kLocalized("吃药"), kLocalized("吃饭"), kLocalized("运动"), kLocalized("睡觉"), kLocalized("起床"), kLocalized("约会"), kLocalized("聚会"), kLocalized("会议")]
}

extension ZHJSedentary {
    func cycleString() -> String {
        var cycleString = ""
        if !cycle.contains(true) {
            cycleString = kLocalized("仅一次")
        }
        else if !cycle.contains(false) {
            cycleString = kLocalized("每天")
        }
        else {
            let weeks = SelectList.weeks
            for (index, weekIsOn) in cycle.enumerated() {
                cycleString += weekIsOn ? " " + weeks[index] : ""
            }
        }
        return cycleString
    }
    
    func intervalsString() -> String {
        let interval = intervals * 5
        return interval == 0 ? kLocalized("自动检测") : (intervals * 5).description + " " + kLocalized("分钟")
    }
}

extension String {
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return String(self[(start ..< end)])
    }
}


extension Double {
    func numberAsPercentage() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.percentSymbol = "%"
//        formatter.maximumIntegerDigits = 0
        return formatter.string(from: NSNumber(value:self))!
    }

    ///소수점 반올림 후 어느 분
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    ///소수점까지 자른 다음 어느 분이
    func truncate(places: Int) -> Double {
        if self.isNaN || self.isInfinite{ return 0 }
        let divisor = pow(10.0, Double(places))
        return Double(Int(self * divisor)) / divisor
    }
}
