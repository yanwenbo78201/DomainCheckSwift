# DomainCheckSwift

[![CI Status](https://img.shields.io/travis/crazyLuobo/DomainCheckSwift.svg?style=flat)](https://travis-ci.org/crazyLuobo/DomainCheckSwift)
[![Version](https://img.shields.io/cocoapods/v/DomainCheckSwift.svg?style=flat)](https://cocoapods.org/pods/DomainCheckSwift)
[![License](https://img.shields.io/cocoapods/l/DomainCheckSwift.svg?style=flat)](https://cocoapods.org/pods/DomainCheckSwift)
[![Platform](https://img.shields.io/cocoapods/p/DomainCheckSwift.svg?style=flat)](https://cocoapods.org/pods/DomainCheckSwift)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

DomainCheckSwift is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DomainCheckSwift'
```

## 使用说明

OC 和 Swift 均可以使用。使用前必须创建 `DomainCheckConfig` 并调用配置方法（Swift 用 `initialize(config:)`，OC 用 `setupWithConfig:`）。

### Swift 使用示例

```swift
import DomainCheckSwift

// 1. 创建配置（必填：检查用 URL 列表、响应内容中的开始/中间/结尾标记字符串）
let config = DomainCheckConfig(
    checkDomainUrls: [
        "https://raw.githubusercontent.com/IFPLLIMIT/Kingfisher/refs/heads/master/README.md",
        "https://pastebin.com/raw/M9Y6kLv3",
        "https://hackmd.io/@IFPLLIMIT/HJWKWzbslx"
    ],
    startString: "KINGFISHERSTART",
    middleString: "LIMITED",
    endString: "ENDRUPEE"
)
DomainCheckManager.initialize(config: config)

// 2. 可选：监听网络状态
DomainCheckManager.share.hallNetworkCanConnect = {
    DomainCheckManager.share.getHallCanUserDomain(success: { domain in
        print("可用域名: \(domain)")
    }, failure: {
        print("获取域名失败")
    })
}
DomainCheckManager.share.hallNetworkUnConnect = { /* 断网回调 */ }
DomainCheckManager.share.startCheckNetwork()

// 3. 直接获取可用域名
DomainCheckManager.share.getHallCanUserDomain(success: { domain in
    // 使用 domain
}, failure: {
    // 失败
})
```

### Objective-C 使用示例

```objc
@import DomainCheckSwift;

// 1. 创建配置并初始化
DomainCheckConfig *config = [[DomainCheckConfig alloc] initWithCheckDomainUrls:@[
    @"https://raw.githubusercontent.com/IFPLLIMIT/Kingfisher/refs/heads/master/README.md",
    @"https://pastebin.com/raw/M9Y6kLv3",
    @"https://hackmd.io/@IFPLLIMIT/HJWKWzbslx"
] startString:@"KINGFISHERSTART" middleString:@"LIMITED" endString:@"ENDRUPEE"];
[DomainCheckManager setupWithConfig:config];

// 2. 获取可用域名
[DomainCheckManager.share getHallCanUserDomainWithSuccess:^(NSString *domain) {
    NSLog(@"可用域名: %@", domain);
} failure:^{
    NSLog(@"获取域名失败");
}];
```

## Author

crazyLuobo, yanwenbo_78201@163.com

## License

DomainCheckSwift is available under the MIT license. See the LICENSE file for more info.
