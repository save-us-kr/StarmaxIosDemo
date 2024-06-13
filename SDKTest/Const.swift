//
//  Const.swift
//  SDKTest
//
//  Created by wangjun on 2020/2/20.
//  Copyright © 2020 wangjun. All rights reserved.
//

import Foundation
import UIKit
@_exported import TrusangBluetooth
// MARK:- 常用尺寸
let kScreenBounds = UIScreen.main.bounds
let kScreenScale = UIScreen.main.scale
let kScreenSize = kScreenBounds.size
let kScreenW = kScreenSize.width
let kScreenH = kScreenSize.height
// 导航栏按钮边距
let kNavBarItemMargin: CGFloat = kScreenW <= 375 ? 16 : 20

// MARK:- 常用全局单例
let kUserDefualt = UserDefaults.standard
let kNotificationCenter = NotificationCenter.default
//let keyWindow = UIApplication.shared.keyWindow!

func keywindows() -> UIWindow? {
    var window:UIWindow? = nil
    if #available(iOS 13.0, *) {
        for windowScene:UIWindowScene in ((UIApplication.shared.connectedScenes as?  Set<UIWindowScene>)!) {
            if windowScene.activationState == .foregroundActive {
                window = windowScene.windows.first
                break
            }
        }
        return window
    }else{
        return  UIApplication.shared.keyWindow
    }
}

// MARK: - APP&设备信息
let kAppInfoDict = Bundle.main.infoDictionary
let kAppCurrentVersion = kAppInfoDict!["CFBundleShortVersionString"]
let kAppBuildVersion = kAppInfoDict!["CFBundleVersion"]
let kDeviceIosVersion = UIDevice.current.systemVersion
let kDeviceIdentifierNumber = UIDevice.current.identifierForVendor
let kDeviceSystemName = UIDevice.current.systemName
let kDeviceModel = UIDevice.current.model
let kDeviceLocalizedModel = UIDevice.current.localizedModel
let isIPhone = (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone ? true : false)
let isIPad = (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad ? true : false)
let isIPhone4 = (max(kScreenW, kScreenH) < 568.0 ? true : false)
let isIPhone5 = (max(kScreenW, kScreenH) == 568.0 ? true : false)
let isIPhone6 = (max(kScreenW, kScreenH) == 667.0 ? true : false)
let isIPhone6P = (max(kScreenW, kScreenH) == 736.0 ? true : false)
let isIPhoneX = (kScreenH >= 812.0 ? true : false)
let kNavibarH: CGFloat = isiPhoneX() ? 88.0 : 64.0
let kTabbarH: CGFloat = isiPhoneX() ? 49.0 + 34.0 : 49.0
let kStatusbarH: CGFloat = isiPhoneX() ? 44.0 : 20.0
let iPhoneXBottomH: CGFloat = 34.0
let iPhoneXTopH: CGFloat = 24.0
let kIOS8 = (kDeviceIosVersion as NSString).doubleValue >= 8.0
let kIOS9 = (kDeviceIosVersion as NSString).doubleValue >= 9.0
let kIOS10 = (kDeviceIosVersion as NSString).doubleValue >= 10.0
let kIOS11 = (kDeviceIosVersion as NSString).doubleValue >= 11.0
let kIOS12 = (kDeviceIosVersion as NSString).doubleValue >= 12.0
let kDevice = UIDevice.current
var today = DateClass.todayString()
// MARK:- 等比例适配宏
func kScaleWidth(_ width: CGFloat) -> CGFloat {
    return width * kScreenW / 375;
}
func kScaleHeight(_ height: CGFloat) -> CGFloat {
    return  height * kScreenH / (isIPhoneX ? 812 : 667);
}


// MARK:- 颜色方法
func kRGBA(_ r:CGFloat, _ g:CGFloat, _ b:CGFloat, _ a:CGFloat) -> UIColor {
    
    return UIColor (red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}
func kHexColor(_ hex: Int64) -> UIColor {
    return UIColor.hexColor(hex)
}
func kHexColor(_ hex: Int64, _ alpha: CGFloat) -> UIColor {
    return UIColor.hexColor(hex, alpha)
}
func kRandomColor() -> UIColor {
    return kRGBA(CGFloat(arc4random_uniform(256)), CGFloat(arc4random_uniform(256)), CGFloat(arc4random_uniform(256)), 1)
}


// MARK:- 常用颜色
let kTabBarColor = UIColor.white
let kTabTextNorColor = kHexColor(0xB8C9DC)
let kTabTextSelColor = kHexColor(0x323232)
let kNavBarBgColor = UIColor.white
let kNavBarItemTextColor = UIColor.hexColor(0x323232)
let kNavBarItemFont = UIFont.systemFont(ofSize: kScaleWidth(18.0))
let kClearColor = UIColor.clear
let headerColor = kHexColor(0x5ba5c1)
let kBackgroundColor = kRGBA(241, 245, 247, 1)
///厘米转英尺的换算量
let cm2ft = 0.0328084
///厘米转英寸的换算量
let in2cm = 2.54
///1千克(kg)=2.2046226磅(lb)
let kg2lb = 2.2046226
///1磅(lb)=0.4535924千克(kg)
let lb2kg = 0.4535924
///1千米(km)=0.6213712英里(mi)
let km2mi = 0.6213712

// MARK:-  常用字体
func kCustomFont(_ fontName: String, _ size: CGFloat) -> UIFont {
    let font = UIFont.init(name: fontName, size: kScaleWidth(size))
    return font!
}
func kSystemFont(_ size: CGFloat) -> UIFont {
    let font = UIFont.systemFont(ofSize: kScaleWidth(size))
    return font
}

/// 常用数字字体
func kDigitalFont(_ size: CGFloat) -> UIFont {
    let font = UIFont.init(name: "DIN Condensed", size: kScaleWidth(size))
    return font!
}

// MARK:- 自定义打印方法
func ZHJLog<T>(_ message : T, file : String = #file, funcName : String = #function, lineNum : Int = #line) {
    
    #if DEBUG
    
    let fileName = (file as NSString).lastPathComponent
    
    print("\(DateClass.todayIntegrateString()):\(fileName):[\(lineNum)]:\(message)")
    
    #endif
}

// MARK:- 国际化字符串
func kLocalized(_ key: String) -> String {
    return Bundle.main.localizedString(forKey: key, value: "", table: nil)
}

//是否为IPHONEX及以上机型
func isiPhoneX() ->Bool {
    let screenHeight = UIScreen.main.nativeBounds.size.height;
    if screenHeight == 2436 || screenHeight == 1792 || screenHeight == 2688 || screenHeight == 1624 {
        return true
    }
    return false
}


extension UIColor {
    
    static func hexColor(_ hexColor: Int64) -> UIColor {
        
        let red = ((CGFloat)((hexColor & 0xFF0000) >> 16))/255.0;
        let green = ((CGFloat)((hexColor & 0xFF00) >> 8))/255.0;
        let blue = ((CGFloat)(hexColor & 0xFF))/255.0;
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    static func hexColor(_ hexColor: Int64, _ alpha: CGFloat) -> UIColor {
        
        let red = ((CGFloat)((hexColor & 0xFF0000) >> 16))/255.0;
        let green = ((CGFloat)((hexColor & 0xFF00) >> 8))/255.0;
        let blue = ((CGFloat)(hexColor & 0xFF))/255.0;
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension Date {
    //    // MARK:- 年
    //    func year() -> Int {
    //        let calendar = NSCalendar.current
    //        let com = calendar.dateComponents([.year,.month,.day], from: self)
    //        return com.year!
    //    }
    //    // MARK:- 月
    //    func month() -> Int {
    //        let calendar = NSCalendar.current
    //        let com = calendar.dateComponents([.year,.month,.day], from: self)
    //        return com.month!
    //    }
    //    // MARK:- 日
    //    func day() -> Int {
    //        let calendar = NSCalendar.current
    //        let com = calendar.dateComponents([.year,.month,.day], from: self)
    //        return com.day!
    //    }
    //
    //    // MARK:- 时
    //    func hour() -> Int {
    //        let calendar = NSCalendar.current
    //        let com = calendar.dateComponents([.year,.month,.day, .hour], from: self)
    //        return com.hour!
    //    }
    //
    //    // MARK:- 分
    //    func minute() -> Int {
    //        let calendar = NSCalendar.current
    //        let com = calendar.dateComponents([.year,.month,.day, .hour, .minute], from: self)
    //        return com.minute!
    //    }
    //
    
    // MARK:- 星期几
    func weekDay() -> Int {
        let interval = Int(self.timeIntervalSince1970)
        let days = Int(interval/86400) // 24*60*60
        let weekday = ((days + 4)%7+7)%7
        return weekday == 0 ? 7 : weekday
    }
    // MARK:- 当月天数
    func countOfDaysInMonth() -> Int {
        let calendar = Calendar(identifier:Calendar.Identifier.gregorian)
        let range = (calendar as NSCalendar?)?.range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: self)
        return (range?.length)!
    }
    // MARK:- 当月第一天是星期几
    func firstWeekDay() -> Int {
        //1.Sun. 2.Mon. 3.Thes. 4.Wed. 5.Thur. 6.Fri. 7.Sat.
        let calendar = Calendar(identifier:Calendar.Identifier.gregorian)
        let firstWeekDay = (calendar as NSCalendar?)?.ordinality(of: NSCalendar.Unit.weekday, in: NSCalendar.Unit.weekOfMonth, for: self)
        return firstWeekDay! - 1
        
    }
    // MARK:- 是否是今天
    func isToday() -> Bool {
        let calendar = NSCalendar.current
        let com = calendar.dateComponents([.year,.month,.day], from: self)
        let comNow = calendar.dateComponents([.year,.month,.day], from: Date())
        return com.year == comNow.year && com.month == comNow.month && com.day == comNow.day
    }
    // MARK:- 是否是这个月
    func isThisMonth() -> Bool {
        let calendar = NSCalendar.current
        let com = calendar.dateComponents([.year,.month,.day], from: self)
        let comNow = calendar.dateComponents([.year,.month,.day], from: Date())
        return com.year == comNow.year && com.month == comNow.month
    }
    
    // MARK:- 距离2018-01-01的日,周,月统计量
    func getCounts(type: Int) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let startDate = formatter.date(from: "2018-01-01")
        
        var count: Int = 0
        
        if type == 0 {    //日
            let comps = Calendar.current.dateComponents([.day], from: startDate!, to: self)
            count = comps.day!
        }
        
        if type == 1 {    //周
            let comps = Calendar.current.dateComponents([.day], from: startDate!, to: self)
            count = comps.day!/7
        }
        
        if type == 2 {    //月
            let comps = Calendar.current.dateComponents([.month], from: startDate!, to: self)
            count = comps.month!
        }
        return count
    }
    
    // 本周开始日期（星期天）
    func startOfThisWeek() -> Date {
        let calendar = NSCalendar.current
        let commponets = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        let startOfWeek = calendar.date(from: commponets)
        return startOfWeek!
    }
    
    // 本月开始日期
    func startOfCurrentMonth() -> Date {
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        let startOfMonth = calendar.date(from: components)!
        return startOfMonth
    }
    
    /// 获取偏移月份的日期
    ///
    /// - Parameter offset: 偏移的月份
    func getDateFromCurrentMonth(offset: Int) -> Date? {
        let calendar = Calendar.current
        var coms = calendar.dateComponents([.year, .month, .day], from: self)
        coms.month = coms.month! - offset
        coms.day = 1
        return calendar.date(from: coms)
    }
    
    /// 获取这个月有多少天
    ///
    /// - Returns:
    func getMonthHowManyDay() -> Range<Int> {
        return Calendar.current.range(of: .day, in: .month, for: self)!
    }
    
    /// 获取这个月第一天的日期
    ///
    /// - Returns:
    func getMonthFirstDay() -> Date? {
        let calendar = Calendar.current
        var com = calendar.dateComponents([.year, .month,.day], from: self)
        com.day = 1
        return calendar.date(from: com)
    }
    
    /// 获取这个月最后一天的日期
    func getMonthEndDay(returnEndTime:Bool = false) -> Date {
        let calendar = NSCalendar.current
        var components = DateComponents()
        components.month = 1
        components.second = -1
        components.timeZone = TimeZone.current
        let endOfMonth = calendar.date(byAdding: components, to: startOfCurrentMonth())!
        return endOfMonth
    }
    
    /// 获取偏移天数的日期
    ///
    /// - Parameter offset: 偏移天数
    /// - Returns:
    func getDay(offset: Int) -> Date? {
        let calendar = Calendar.current
        var com = calendar.dateComponents([.year, .month,.day], from: self)
        com.day = com.day! + offset
        return calendar.date(from: com)
    }
    
    func date2String() -> String? {
        let dateformatter = DateFormatter.init()
        dateformatter.dateFormat = "yyyy-MM-dd"
        return dateformatter.string(from: self)
    }
    
    //该时间所在周的第一天日期（默认从周日开始算第一天，若从周一 则改变offset 为1）
    var startOfWeek: Date {
        let calendar = NSCalendar.current
        let components = calendar.dateComponents(
            Set<Calendar.Component>([.yearForWeekOfYear, .weekOfYear]), from: self)
        let date = calendar.date(from: components)!
        return date.getDay(offset: 0)!
    }
    
    //该时间所在周的最后一天日期（2017年12月23日 00:00:00）
    var endOfWeek: Date {
        let calendar = NSCalendar.current
        var components = DateComponents()
        components.day = 6
        return calendar.date(byAdding: components, to: self.startOfWeek)!
    }
    
    //    var startMonth: String {
    //
    //    }
}

class DateClass {
    // MARK:- 当前年月日字符串
    static func todayString() -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        return dateFormat.string(from: Date())
    }
    // MARK:- 当前年月日时分秒字符串
    static func todayIntegrateString() -> String {
        let dateFormat = DateFormatter()
        // 以中国为准
        let locale = Locale(identifier: "zh")
        dateFormat.locale = locale
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormat.string(from: Date())
    }
    // MARK:- 获取当前时间戳(秒)
    static func getNowTimeS() -> Int {
        let date = Date()
        let timeInterval:Int = Int(date.timeIntervalSince1970)
        return timeInterval
    }
    // MARK:- 获取当前时区的时间
    static func getCurrentTimeZone() -> Date {
        let date = Date()
        let zone = TimeZone.current
        let interval = zone.secondsFromGMT()
        let nowDate = date.addingTimeInterval(TimeInterval(interval))
        return nowDate
    }
    // MARK:- 获取0时区的开始时间（2018-5-13 16：00：00）
    static func getZeroTimeZone() -> Date {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        let todayDate = dateFormat.date(from: DateClass.todayString())
        return todayDate!
    }
    // MARK:- 获取获取当前时区的开始时间（2018-5-13 00：00：00）
    static func getCurrentInitTimeZone() -> Date {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        let zone = TimeZone.current
        dateFormat.timeZone = zone
        let interval = zone.secondsFromGMT()
        let todayDate = dateFormat.date(from: DateClass.todayString())
        return todayDate!.addingTimeInterval(TimeInterval(interval))
    }
    // MARK:- 将时间戳按指定格式时间输出 13569746264 -> 2018-05-06
    static func timestampToStr(_ timestamp: Int, formatStr: String) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let zone = TimeZone.current
        let dateFormat = DateFormatter()
        // 以中国为准
        //        let locale = Locale(identifier: "zh")
        let locale = Locale.current
        dateFormat.locale = locale
        dateFormat.dateFormat = formatStr
        dateFormat.timeZone = zone
        let str = dateFormat.string(from: date)
        return str
    }
    // MARK:- 将时间格式转换时间戳输出 2018-05-06 -> 13569746264
    static func timeStrToTimestamp(_ timeStr: String, formatStr: String) -> Int {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = formatStr
        let locale = Locale.init(identifier: "zh-CN")
        dateFormat.locale = locale
        let date = dateFormat.date(from: timeStr) ?? Date()
        let timestamp = Int(date.timeIntervalSince1970)
        return timestamp
    }
    // MARK:- 将制定格式时间转自定义格式时间 2018-05-06 -> 2018-05-06 00:00:00
    static func timeStrToTimeStr(_ timeStr: String, formatStr: String, toFormatStr: String) -> String {
        let timestamp = DateClass.timeStrToTimestamp(timeStr, formatStr: formatStr)
        return DateClass.timestampToStr(timestamp, formatStr: toFormatStr)
    }
    
    // MARK:- 获取当前时间按指定格式时间输出
    static func getCurrentTimeStr(formatStr: String) -> String {
        let date = Date()
        let zone = TimeZone.current
        let dateFormat = DateFormatter()
        // 以中国为准
        let locale = Locale.init(identifier: "zh-CN")
        dateFormat.locale = locale
        dateFormat.dateFormat = formatStr
        dateFormat.timeZone = zone
        let str = dateFormat.string(from: date)
        return str
    }
    
    // MARK:- 距离指定日期偏移天数的日期
    static func dateStringOffset(from: String, offset: Int) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        guard let fromDate = dateFormat.date(from: from) else {
            return from
        }
        
        var cmps = Calendar.current.dateComponents([.year, .month, .day], from: fromDate)
        cmps.day = cmps.day! + offset
        let resultDate = Calendar.current.date(from: cmps)
        return dateFormat.string(from: resultDate!)
    }
    
    // MARK:- 将指定格式时间字符串转成Date
    static func getTimeStrToDate(formatStr: String, timeStr: String) -> Date {
        let zone = TimeZone.current
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = formatStr
        dateFormat.timeZone = zone
        //默认中文地区的格式，其他地区可能会造成闪退
        let locale = Locale.init(identifier: "zh-CN")
        dateFormat.locale = locale
        return dateFormat.date(from: timeStr)!
    }
    
    static func getSpecialDays(dateStr: String, count: Int) -> [String] {
        var days = [String]()
        let dateformatter = DateFormatter.init()
        dateformatter.dateFormat = "yyyy-MM-dd"
        let date = dateformatter.date(from: dateStr)
        let calendar = Calendar.current
        
        for i in 0..<count {
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: date!)
            dateComponents.day = dateComponents.day! + i
            let newDate = calendar.date(from: dateComponents)
            let dateString = dateformatter.string(from: newDate!)
            days.append(dateString)
        }
        return days
    }
    
    //指定年月的开始日期
    static func startOfMonth(year: Int, month: Int) -> Date {
        let calendar = NSCalendar.current
        var startComps = DateComponents()
        startComps.day = 1
        startComps.month = month
        startComps.year = year
        let startDate = calendar.date(from: startComps)!
        return startDate
    }
    
    //指定年月的结束日期
    static func endOfMonth(year: Int, month: Int, returnEndTime:Bool = false) -> Date {
        let calendar = NSCalendar.current
        var components = DateComponents()
        components.month = 1
        if returnEndTime {
            components.second = -1
        } else {
            components.day = -1
        }
        
        let endOfYear = calendar.date(byAdding: components,
                                      to: startOfMonth(year: year, month:month))!
        return endOfYear
    }
}

extension Date {
    //计算两个日期之间的日期差
    func daysBetweenDate(toDate: Date) -> Int {
        let beginDate = self.getMorningDate()
        let endDate = toDate.getMorningDate()
        let components = Calendar.current.dateComponents([.day], from: beginDate, to: endDate)
        return components.day ?? 0
    }
    //当前日期置为0点0分0秒
    func getMorningDate() -> Date{
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.year,.month,.day], from: self)
        return (calendar.date(from: components))!
    }
}


// MARK:- 显示消息提示框
func ZHJShowMessage(_ viewController: UIViewController, _ text: String) {
    let alertController = UIAlertController(title: kLocalized(text), message: nil, preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: kLocalized("OK"), style: .cancel, handler: nil)
    alertController.addAction(cancelAction)
    viewController.present(alertController, animated: true, completion: nil)
}

// MARK:- 自定义内容消息提示框
func ZHJShowMessage(_ viewController: UIViewController, _ contextText: String, cancelText: String, confirmText:String, handle: @escaping (Bool) -> ()) {
    let alertController = UIAlertController(title: kLocalized(contextText), message: nil, preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: kLocalized(cancelText), style: .cancel) { _ in
        handle(false)
    }
    let confirmAction = UIAlertAction(title: kLocalized(confirmText), style: .default) { _ in
        handle(true)
    }
    alertController.addAction(cancelAction)
    alertController.addAction(confirmAction)
    viewController.present(alertController, animated: true, completion: nil)
}

// MARK:- 自定义内容输入框
func ZHJShowInputMessage(_ viewController: UIViewController, _ contextText: String, cancelText: String,keyboardType: UIKeyboardType, confirmText:String, handle: @escaping (Bool, UITextField) -> ()){
    let alertController = UIAlertController(title: kLocalized(contextText), message: nil, preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: kLocalized(cancelText), style: .cancel) { _ in
        handle(false, (alertController.textFields?.first)!)
    }
    let confirmAction = UIAlertAction(title: kLocalized(confirmText), style: .default) { _ in
        handle(true, (alertController.textFields?.first)!)
    }
    alertController.addTextField { (txtFiled) in
        txtFiled.keyboardType = keyboardType
    }
    alertController.addAction(cancelAction)
    alertController.addAction(confirmAction)
    viewController.present(alertController, animated: true, completion: nil)
}

// MARK:- 自定义内容消息提示框单个
func ZHJShowMessage(_ viewController: UIViewController, _ contextText: String, confirmText:String, handle: @escaping (Bool) -> ()) {
    let alertController = UIAlertController(title: kLocalized(contextText), message: nil, preferredStyle: .alert)
    
    let confirmAction = UIAlertAction(title: kLocalized(confirmText), style: .default) { _ in
        handle(true)
    }
    alertController.addAction(confirmAction)
    viewController.present(alertController, animated: true, completion: nil)
}
