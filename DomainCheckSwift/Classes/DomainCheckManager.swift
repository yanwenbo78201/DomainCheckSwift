// 域名检查 Pod，支持 Swift 与 Objective-C 调用。
//
// Swift 使用示例:
//   let config = DomainCheckConfig(checkDomainUrls: [...], startString: "...", middleString: "...", endString: "...")
//   DomainCheckManager.initialize(config: config)
//   DomainCheckManager.share.getHallCanUserDomain(success: { domain in ... }, failure: { ... })
//
// Objective-C 使用示例:
//   @import DomainCheckSwift;
//   DomainCheckConfig *config = [[DomainCheckConfig alloc] initWithCheckDomainUrls:@[...] startString:@"..." middleString:@"..." endString:@"..."];
//   [DomainCheckManager setupWithConfig:config];
//   [DomainCheckManager.share getHallCanUserDomainWithSuccess:^(NSString *domain) { ... } failure:^{ ... }];

import UIKit
import Network

// MARK: - 支持 Swift / Objective-C 的配置类（必须为 NSObject 子类才能在 OC 中使用）

/// 域名检查配置，使用前必须创建并传入。Swift 与 OC 均可使用。
@objcMembers
public class DomainCheckConfig: NSObject {
    @objc public let checkDomainUrls: [String]
    @objc public let startString: String
    @objc public let middleString: String
    @objc public let endString: String

    @objc public init(checkDomainUrls: [String], startString: String, middleString: String, endString: String) {
        self.checkDomainUrls = checkDomainUrls
        self.startString = startString
        self.middleString = middleString
        self.endString = endString
        super.init()
    }
}

// MARK: - 支持 Swift / Objective-C 的 Manager

/// 域名检查管理器，Swift 与 OC 均可使用。使用前必须先调用 setup(withConfig:) 或 initialize(config:)。
@objcMembers
public class DomainCheckManager: NSObject {
    /// 使用前必须先调用 setup(withConfig:) 或 initialize(config:)
    public static var share: DomainCheckManager!
    /// 初始化并设置配置，必须在使用 Manager 前调用一次。OC 中请使用 setupWithConfig: 避免与 +initialize 混淆。
    public static func initialize(config: DomainCheckConfig) {
        share = DomainCheckManager(config: config)
    }
    /// 配置入口，推荐在 OC 中使用此方法名
    @objc(setupWithConfig:)
    public static func setup(with config: DomainCheckConfig) {
        share = DomainCheckManager(config: config)
    }

    private let config: DomainCheckConfig
    private let networkMonitor = NWPathMonitor()
    private let networkQueue = DispatchQueue(label: "HallWifi.NetworkMonitor.Queue")

    private override init() {
        fatalError("请使用 DomainCheckManager.initialize(config:) 创建实例")
    }

    private init(config: DomainCheckConfig) {
        self.config = config
        super.init()
    }
    public var hallNetworkCanConnect: (() -> Void)?
    public var hallNetworkUnConnect: (() -> Void)?
    public var isNetworkAvailable: Bool {
        return networkMonitor.currentPath.status == .satisfied
    }
    
    private var ckeckNetworking = false

    public func startCheckNetwork() {
        guard !ckeckNetworking else { return }
        
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self?.hallNetworkCanConnect?()
                } else {
                    self?.hallNetworkUnConnect?()
                }
            }
        }
        
        networkMonitor.start(queue: networkQueue)
        ckeckNetworking = true
    }
    
    public func stopCheckNetwork() {
        guard ckeckNetworking else { return }
        
        networkMonitor.cancel()
        ckeckNetworking = false
    }

    public func getHallCanUserDomain(success: @escaping (_ domail: String) -> Void, failure: @escaping () -> Void) {
       
        var getDomainSuccess = false
        let domainSuccessGroup = DispatchGroup()
        for (_, domainUrl) in config.checkDomainUrls.enumerated() {
            domainSuccessGroup.enter()
            getDomailDescribeContent(domainUrl) { resultDomail in
                if getDomainSuccess == false && resultDomail.count > 0{
                    getDomainSuccess = true
                    success(resultDomail)
                }
                domainSuccessGroup.leave()
            } failure: {
                domainSuccessGroup.leave()
            }
        }
        domainSuccessGroup.notify(queue: .main) {
            if getDomainSuccess == false{
                failure()
            }
        }
    }
    
    func getDomailDescribeContent(_ describeUrl: String, success: @escaping (_ domailUrl: String) -> Void, failure: @escaping () -> Void) {
        let clientTime = Int64(Date().timeIntervalSince1970 * 1000)
        let urlString = describeUrl.contains("?") ? "\(describeUrl)&t=\(clientTime)" : "\(describeUrl)?t=\(clientTime)"
        guard let requestUrl = URL(string: urlString) else {
            DispatchQueue.main.async { failure() }
            return
        }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        request.timeoutInterval = 120.0

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                if error != nil || data == nil {
                    failure()
                    return
                }
                let contentString: String
                if let jsonObject = try? JSONSerialization.jsonObject(with: data!),
                   let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
                   let str = String(data: jsonData, encoding: .utf8) {
                    contentString = str
                } else {
                    contentString = String(data: data!, encoding: .utf8) ?? ""
                }
                guard contentString.count > 0 else {
                    failure()
                    return
                }
                let resultDomainl = self?.getDomailRequest(responseStr: contentString) ?? ""
                if resultDomainl.count > 0 {
                    success(resultDomainl)
                } else {
                    failure()
                }
            }
        }
        task.resume()
    }
    
    func getDomailRequest(responseStr: String) -> String {
        let startStr = config.startString
        let middleStr = config.middleString
        let endStr = config.endString

        guard let startRange = responseStr.range(of: startStr),
              let endRange = responseStr.range(of: endStr, range: startRange.upperBound..<responseStr.endIndex),
              startRange.lowerBound < endRange.upperBound else {
            return ""
        }

        let matchedStr = String(responseStr[startRange.upperBound..<endRange.lowerBound])
        guard matchedStr.contains(middleStr) else {
            return ""
        }
        let replacedStr = matchedStr.replacingOccurrences(of: middleStr, with: ".")
        return replacedStr
    }
    
    
      

}
