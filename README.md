# 拉屎记录 App (PoopTracker)

一个用于记录每日拉屎次数和大小的iOS应用，支持日历视图和月度统计功能。

## 功能特性

- 📅 **日历视图**：在日历上直观显示每日拉屎记录
- ➕ **快速记录**：轻松添加拉屎记录（日期、时间、大小、备注）
- 📊 **月度统计**：查看月度统计数据
  - 总次数
  - 有记录天数
  - 平均每天次数
  - 记录率
  - 大小分布
  - 每日趋势图
- 💾 **数据持久化**：使用UserDefaults自动保存和加载数据
- ✏️ **编辑删除**：支持编辑和删除已有记录

## 技术栈

- **SwiftUI**：现代化的iOS UI框架
- **Swift 5.0+**：编程语言
- **iOS 17.0+**：最低系统要求

## 项目结构

```
PoopTracker/
├── PoopTrackerApp.swift      # 应用入口
├── ContentView.swift          # 主界面（TabView）
├── PoopRecord.swift          # 数据模型
├── DataManager.swift         # 数据管理器
├── CalendarView.swift        # 日历视图
├── RecordView.swift          # 记录界面
└── MonthlySummaryView.swift  # 月度统计视图
```

## 使用方法

### 在Xcode中打开项目

1. 打开Xcode
2. 选择 `File > Open`
3. 选择 `PoopTracker.xcodeproj`
4. 选择目标设备（iPhone模拟器或真机）
5. 点击运行按钮（⌘R）

### 使用应用

1. **查看日历**：在"日历"标签页查看每日记录
2. **添加记录**：
   - 在"记录"标签页快速添加
   - 或在日历视图中点击日期后点击"+"按钮
3. **查看统计**：在"统计"标签页查看月度总结

## 数据模型

### PoopRecord（单次记录）
- `id`: 唯一标识符
- `date`: 日期时间
- `size`: 大小（小/中/大）
- `notes`: 备注信息

### DailyRecord（每日汇总）
- `date`: 日期
- `records`: 该日的所有记录
- `totalCount`: 总次数
- `averageSize`: 平均大小

### MonthlyStats（月度统计）
- `month`: 月份
- `totalCount`: 总次数
- `daysWithPoop`: 有记录天数
- `totalDays`: 总天数
- `averagePerDay`: 平均每天次数
- `sizeDistribution`: 大小分布

## 注意事项

- 数据存储在UserDefaults中，卸载应用会清除数据
- 如需更安全的数据存储，可以考虑使用Core Data或SQLite
- 应用图标和启动画面需要单独配置

## 未来改进

- [ ] 添加数据导出功能
- [ ] 支持多设备同步（iCloud）
- [ ] 添加提醒功能
- [ ] 支持自定义大小选项
- [ ] 添加健康数据关联
- [ ] 支持暗黑模式优化

## 许可证

本项目仅供学习和个人使用。

