# Browser Tools MCP 使用指南

Browser Tools MCP 是一个强大的浏览器自动化工具，允许 AI 工具与浏览器深度交互，实现网页审计、调试和监控功能。

## 简介

Browser Tools MCP 提供了一种简单而强大的方式来控制浏览器并与之交互。它支持多种功能，包括但不限于：
- 网页截图
- 控制台日志检查
- 网络日志分析
- 性能审计
- SEO 分析
- 可访问性审计
- 调试模式

## 安装和配置

### 前提条件

确保你的系统已安装 Node.js 和 npm。

### 安装步骤

1. 打开终端并运行以下命令来启动 Browser Tools Server：

```bash
npx @agentdeskai/browser-tools-server@latest
```

2. 在另一个终端窗口中，运行以下命令来启动 Browser Tools MCP：

```bash
npx @agentdeskai/browser-tools-mcp@latest
```

### IDE 配置

要在支持 MCP (Model Context Protocol) 的 IDE 中使用 Browser Tools MCP，需要添加以下配置：

```json
{
  "Browser Tools MCP": {
    "type": "stdio",
    "command": "npx",
    "args": [
      "@agentdeskai/browser-tools-mcp@latest"
    ],
    "disabled": false
  }
}
```

## 功能详解

### 1. 网页截图功能

使用截图功能可以捕获当前浏览器窗口的内容，并保存为图片文件。

### 2. 控制台日志检查

可以检查浏览器的控制台日志和错误信息，有助于调试前端问题。

### 3. 网络日志分析

查看网络请求和错误，帮助分析网页加载性能和网络问题。

### 4. 性能审计

运行性能审计以评估网页的加载速度和运行时性能。

### 5. SEO 分析

进行 SEO 审计，检查网页的搜索引擎优化情况。

### 6. 可访问性审计

运行可访问性审计以确保网页对所有用户都可访问。

### 7. 调试模式

使用调试模式来诊断和解决网页问题。

## 使用示例

### 网站体检报告生成

要生成网站的全面体检报告，可以按以下步骤操作：

1. 启动 Browser Tools Server 和 MCP
2. 导航到目标网站
3. 依次运行以下审计功能：
   - 性能审计
   - SEO 审计
   - 可访问性审计
   - 最佳实践审计
4. 检查控制台日志和网络日志
5. 保存截图作为视觉参考

### 自动化任务

Browser Tools MCP 可以用于创建各种自动化任务，例如：
- 定期截图监控网站外观
- 自动化测试和调试
- 网站性能监控

## 安全性

Browser Tools MCP 非常注重用户数据安全：
- 所有日志都存储在本地机器上
- 不会将任何数据发送到第三方服务或 API
- 所有操作都在本地浏览器环境中执行

## 故障排除

### 常见问题

1. **无法连接到服务器**
   - 确保 `browser-tools-server` 正在运行
   - 检查防火墙设置

2. **功能无法正常工作**
   - 确保使用的是最新版本
   - 检查浏览器兼容性

### 更新工具

要更新到最新版本，可以重新运行安装命令：

```bash
npx @agentdeskai/browser-tools-server@latest
npx @agentdeskai/browser-tools-mcp@latest
```

## 更多资源

- [GitHub 仓库](https://github.com/AgentDeskAI/browser-tools-mcp)
- 官方文档: https://browsertools.agentdesk.ai/

## 结论

Browser Tools MCP 是一个功能强大的工具，可以显著提高网页开发和测试的效率。通过与 AI 工具集成，它可以实现智能网页交互和自动化，为开发者和测试人员提供极大的便利。