# i_health - iOS 经期追踪应用

i_health 是一款专为 iOS 设计的经期追踪应用，采用 Flutter 框架开发，提供直观的界面和全面的经期管理功能。

## 功能特点

### 📅 日历功能
- 自定义日历视图，支持经期标记
- 经期日期选择和导航
- 经期天数高亮显示
- 下次经期预测
- 每日详细记录查看

### ✍️ 记录功能
- 全面的经期记录系统
- 日期选择器
- 经期流量强度选择
- 多重症状选择
- 心情记录
- 备注功能
- 记录保存功能

### 📊 数据分析
- 周期概览统计
- 周期趋势线图
- 症状频率柱状图
- 心情分布饼图

### ⚙️ 设置选项
- 个人信息设置
- 通知偏好设置
- 数据管理选项
- 关于页面

## 技术特点

- 🎯 专为 iOS 平台优化
- 🎨 采用 Cupertino 设计语言
- 💾 本地数据存储 (Hive)
- 🔔 本地通知系统
- 🔒 注重隐私保护

## 系统要求

- iOS 11.0 或更高版本
- iPhone 设备
- 仅支持竖屏模式

## 主要依赖

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_local_notifications: ^latest_version
  hive: ^latest_version
  hive_flutter: ^latest_version
  fl_chart: ^latest_version
  intl: ^latest_version
```

## 隐私说明

- 所有数据仅存储在本地设备
- 不收集用户个人信息
- 符合 iOS 隐私规范

## 开发环境设置

1. 确保已安装 Flutter SDK
2. 克隆项目：
   ```bash
   git clone https://your-repository-url/i_health.git
   ```
3. 安装依赖：
   ```bash
   flutter pub get
   ```
4. 运行应用：
   ```bash
   flutter run
   ```

## 项目结构

```
lib/
├── main.dart              # 应用入口
├── pages/                 # 页面文件
│   ├── calendar_page.dart # 日历页面
│   ├── log_page.dart     # 记录页面
│   ├── insights_page.dart # 分析页面
│   └── settings_page.dart # 设置页面
├── models/               # 数据模型
├── services/            # 服务层
└── widgets/            # 自定义组件
```

## 待办事项

- [ ] 云端数据同步
- [ ] 高级预测算法
- [ ] 更全面的症状追踪
- [ ] 数据导出/备份功能
- [ ] 增强通知系统

## 贡献指南

欢迎提交 Issue 和 Pull Request 来帮助改进项目。请确保遵循以下准则：

1. 遵循现有的代码风格
2. 添加适当的测试用例
3. 更新相关文档

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件
