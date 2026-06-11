# better-edit-tools-mcp-for-moonbit

MoonBit 版本的 better-edit-tools MCP 服务器，移植自 Go 版本。

## 项目结构

```
.
├── cmd/better-edit-tools/     # MCP 服务器入口
│   ├── main.mbt
│   └── moon.pkg
├── src/
│   ├── betools/              # 核心库
│   │   ├── lib.mbt           # 公开 API（供其他包导入）
│   │   ├── server.mbt        # MCP 服务器实现
│   │   └── moon.pkg
│   └── native/               # 原生 FFI 支持
│       ├── ffi.mbt
│       ├── stub.c
│       └── moon.pkg
├── moon.mod
└── README.md
```

## 作为独立 MCP 服务器

### 构建

```bash
moon build --target native
```

### 运行

```bash
./_build/native/debug/build/cmd/better-edit-tools/better-edit-tools.exe --lang zh
```

### 在 MCP 客户端中配置

```json
{
  "mcpServers": {
    "better-edit-tools": {
      "command": "/path/to/better-edit-tools.exe",
      "args": ["--lang", "zh"]
    }
  }
}
```

## 作为库使用

在 `moon.pkg` 中添加依赖：

```moonbit
import {
  "conglinyizhi/better_edit_tools_mcp/src/betools",
}
```

### API 示例

```moonbit
// 读取文件
match @betools.read("example.txt", start=1, end=10) {
  Ok(result) => println(result.content)
  Err(err) => println("Error: \{err}")
}

// 写入文件
match @betools.write("output.txt", "Hello, World!") {
  Ok(_) => println("Written successfully")
  Err(err) => println("Error: \{err}")
}

// 替换行范围
match @betools.replace("file.txt", start=5, end=10, "new content") {
  Ok(result) => println("Replaced \{result.removed} lines with \{result.added} lines")
  Err(err) => println("Error: \{err}")
}

// 插入内容
match @betools.insert("file.txt", after_line=3, "inserted line") {
  Ok(result) => println("Added \{result.added} lines")
  Err(err) => println("Error: \{err}")
}

// 删除行
match @betools.delete("file.txt", start=5, end=10) {
  Ok(result) => println("Removed \{result.removed} lines")
  Err(err) => println("Error: \{err}")
}

// 检测函数范围
match @betools.func_range("file.txt", line=42) {
  Ok(range) => println("Function at lines \{range.start}-\{range.end}")
  Err(err) => println("Error: \{err}")
}

// 检查括号配对
match @betools.balance("file.txt") {
  Ok(issues) => if issues.is_empty() { println("Balanced") }
  Err(err) => println("Error: \{err}")
}

// 检测标签范围
match @betools.tag_range("file.html", line=15) {
  Ok((start, end, tag)) => println("<\{tag}> at lines \{start}-\{end}")
  Err(err) => println("Error: \{err}")
}
```

### 公开 API

| 函数 | 签名 | 说明 |
|------|------|------|
| `read` | `(String, Int, Int?, Bool?) -> Result[ReadResult, EditError]` | 读取文件内容 |
| `write` | `(String, String, Bool?, Bool?) -> Result[WriteResult, EditError]` | 写入文件内容 |
| `replace` | `(String, Int, Int, String, Bool?, Bool?) -> Result[EditResult, EditError]` | 替换行范围 |
| `insert` | `(String, Int, String, Bool?, Bool?) -> Result[InsertResult, EditError]` | 插入内容 |
| `delete` | `(String, Int, Int?, Bool?, Bool?) -> Result[DeleteResult, EditError]` | 删除行 |
| `func_range` | `(String, Int) -> Result[RangeResult, EditError]` | 检测函数范围 |
| `balance` | `(String) -> Result[Array[String], EditError]` | 检查括号配对 |
| `tag_range` | `(String, Int) -> Result[(Int, Int, String), EditError]` | 检测标签范围 |

## MCP 工具列表

| 工具 | 说明 |
|------|------|
| `be-read` | 读取文件内容（带行号） |
| `be-write` | 写入文件内容 |
| `be-replace` | 替换指定行范围 |
| `be-insert` | 在指定行后插入内容 |
| `be-delete` | 删除指定行范围 |
| `be-batch` | 批量编辑操作 |
| `be-func-range` | 检测函数/花括号范围 |
| `be-balance` | 检查括号和引号配对 |
| `be-tag-range` | 检测 HTML/XML 标签范围 |
| `be-insert-chip` | 从 chip 缓存插入内容 |
| `be-trx-commit` | 提交事务快照 |
| `be-trx-rollback` | 回滚事务快照 |
| `be-trx-status` | 查看事务状态 |

## 致谢

- 原始 Go 版本：[conglinyizhi/better-edit-tools-mcp](https://github.com/conglinyizhi/better-edit-tools-mcp)
- MoonBit 实现参考：[conglinyizhi/coding_agent_other](https://github.com/conglinyizhi/coding_agent_other)
