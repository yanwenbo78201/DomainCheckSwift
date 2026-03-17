#
# Be sure to run `pod lib lint DomainCheckSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DomainCheckSwift'
  s.version          = '0.1.1'
  s.summary          = '域名检查库：从配置的 URL 拉取内容并解析出可用域名。OC 和 Swift 均可以使用，最低 iOS 15.0。'

  s.description      = <<-DESC
  OC 和 Swift 均可以使用。使用前必须创建 DomainCheckConfig 并调用 initialize(config:)（Swift）或 setupWithConfig:（OC）进行配置。依赖系统 URLSession，无第三方网络库。

  ## Swift 使用示例

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
          print("可用域名: \\(domain)")
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

  ## Objective-C 使用示例

  @import DomainCheckSwift;

  DomainCheckConfig *config = [[DomainCheckConfig alloc] initWithCheckDomainUrls:@[
      @"https://raw.githubusercontent.com/IFPLLIMIT/Kingfisher/refs/heads/master/README.md",
      @"https://pastebin.com/raw/M9Y6kLv3",
      @"https://hackmd.io/@IFPLLIMIT/HJWKWzbslx"
  ] startString:@"KINGFISHERSTART" middleString:@"LIMITED" endString:@"ENDRUPEE"];
  [DomainCheckManager setupWithConfig:config];

  [DomainCheckManager.share getHallCanUserDomainWithSuccess:^(NSString *domain) {
      NSLog(@"可用域名: %@", domain);
  } failure:^{
      NSLog(@"获取域名失败");
  }];
                       DESC

  s.homepage         = 'https://github.com/yanwenbo78201/DomainCheckSwift'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yanwenbo78201' => 'yanwenbo_78201@163.com' }
  s.source           = { :git => 'https://github.com/yanwenbo78201/DomainCheckSwift.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.swift_version    = '5.0'
  s.ios.deployment_target = '15.0'

  s.source_files = 'DomainCheckSwift/Classes/**/*'
  
  # s.resource_bundles = {
  #   'DomainCheckSwift' => ['DomainCheckSwift/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
