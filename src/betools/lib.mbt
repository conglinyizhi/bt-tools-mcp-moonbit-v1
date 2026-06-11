// Public API for better-edit-tools library
// These functions can be used directly by other MoonBit packages

///|
pub struct ReadResult {
  file : String
  start : Int
  end : Int
  content : String
  line_count : Int
  brief : Bool
  viewed_code_id : String?
}

///|
pub struct WriteResult {
  ok : Bool
  file : String
  bytes : Int
  preview : Bool
  brief : Bool
}

///|
pub struct EditResult {
  ok : Bool
  file : String
  start : Int
  end : Int
  removed : Int
  added : Int
  preview : Bool
  brief : Bool
  event_id : String?
}

///|
pub struct InsertResult {
  ok : Bool
  file : String
  after_line : Int
  added : Int
  preview : Bool
  brief : Bool
  event_id : String?
}

///|
pub struct DeleteResult {
  ok : Bool
  file : String
  start : Int
  end : Int
  removed : Int
  preview : Bool
  brief : Bool
  event_id : String?
}

///|
pub struct RangeResult {
  start : Int
  end : Int
}

///|
pub enum EditError {
  ReadFailed(path~ : String)
  WriteFailed(path~ : String)
  InvalidRange(start~ : Int, end~ : Int)
  InvalidLine(line~ : Int)
  OldContentMismatch
} derive(Debug)

///|
pub fn read(
  file : String,
  start : Int,
  end? : Int = 0,
  brief? : Bool = false,
) -> Result[ReadResult, EditError] {
  let content = @native.read_file(file) catch {
    _ => return Err(EditError::ReadFailed(path=file))
  }
  let lines = split_lines_keep_empty(content)
  let total = file_total_lines(lines)
  
  if total == 0 {
    return Ok({
      file: file,
      start: 0,
      end: 0,
      content: "",
      line_count: 0,
      brief: brief,
      viewed_code_id: None,
    })
  }
  
  if start < 1 || start > total {
    return Err(EditError::InvalidLine(line=start))
  }
  
  let actual_end = if end <= 0 { Int::min(start + 20, total) } else { Int::min(end, total) }
  let rendered = if brief { "" } else { render_line_range(lines, start, actual_end) }
  
  Ok({
    file: file,
    start: start,
    end: actual_end,
    content: rendered,
    line_count: total,
    brief: brief,
    viewed_code_id: None,
  })
}

///|
pub fn write(
  file : String,
  content : String,
  preview? : Bool = false,
  brief? : Bool = false,
) -> Result[WriteResult, EditError] {
  if !preview {
    @native.write_file(file, content) catch {
      _ => return Err(EditError::WriteFailed(path=file))
    }
  }
  
  Ok({
    ok: true,
    file: file,
    bytes: content.length(),
    preview: preview,
    brief: brief,
  })
}

///|
pub fn replace(
  file : String,
  start : Int,
  end : Int,
  content : String,
  preview? : Bool = false,
  brief? : Bool = false,
) -> Result[EditResult, EditError] {
  let original = @native.read_file(file) catch {
    _ => return Err(EditError::ReadFailed(path=file))
  }
  let old_lines = split_lines_keep_empty(original)
  let total = file_total_lines(old_lines)
  
  if start < 1 || end < start || end > total + 1 {
    return Err(EditError::InvalidRange(start=start, end=end))
  }
  
  let new_lines = split_lines_keep_empty(content)
  let out : Array[String] = []
  for i in 0..<old_lines.length() {
    let line_no = i + 1
    if line_no == start {
      for new_line in new_lines {
        out.push(new_line)
      }
    }
    if line_no < start || line_no > end {
      out.push(old_lines[i])
    }
  }
  if start == old_lines.length() + 1 {
    for new_line in new_lines {
      out.push(new_line)
    }
  }
  
  if !preview {
    @native.write_file(file, join_lines(out)) catch {
      _ => return Err(EditError::WriteFailed(path=file))
    }
  }
  
  Ok({
    ok: true,
    file: file,
    start: start,
    end: end,
    removed: end - start + 1,
    added: file_total_lines(new_lines),
    preview: preview,
    brief: brief,
    event_id: None,
  })
}

///|
pub fn insert(
  file : String,
  after_line : Int,
  content : String,
  preview? : Bool = false,
  brief? : Bool = false,
) -> Result[InsertResult, EditError] {
  let original = @native.read_file(file) catch {
    _ => return Err(EditError::ReadFailed(path=file))
  }
  let old_lines = split_lines_keep_empty(original)
  
  if after_line < 0 || after_line > old_lines.length() {
    return Err(EditError::InvalidLine(line=after_line))
  }
  
  let insert_lines = split_lines_keep_empty(content)
  let out : Array[String] = []
  if after_line == 0 {
    for new_line in insert_lines {
      out.push(new_line)
    }
  }
  for i in 0..<old_lines.length() {
    out.push(old_lines[i])
    if i + 1 == after_line {
      for new_line in insert_lines {
        out.push(new_line)
      }
    }
  }
  
  if !preview {
    @native.write_file(file, join_lines(out)) catch {
      _ => return Err(EditError::WriteFailed(path=file))
    }
  }
  
  Ok({
    ok: true,
    file: file,
    after_line: after_line,
    added: file_total_lines(insert_lines),
    preview: preview,
    brief: brief,
    event_id: None,
  })
}

///|
pub fn delete(
  file : String,
  start : Int,
  end? : Int = 0,
  preview? : Bool = false,
  brief? : Bool = false,
) -> Result[DeleteResult, EditError] {
  let actual_end = if end <= 0 { start } else { end }
  let original = @native.read_file(file) catch {
    _ => return Err(EditError::ReadFailed(path=file))
  }
  let old_lines = split_lines_keep_empty(original)
  
  if start < 1 || actual_end < start || actual_end > old_lines.length() {
    return Err(EditError::InvalidRange(start=start, end=actual_end))
  }
  
  let out : Array[String] = []
  for i in 0..<old_lines.length() {
    let line_no = i + 1
    if line_no < start || line_no > actual_end {
      out.push(old_lines[i])
    }
  }
  
  if !preview {
    @native.write_file(file, join_lines(out)) catch {
      _ => return Err(EditError::WriteFailed(path=file))
    }
  }
  
  Ok({
    ok: true,
    file: file,
    start: start,
    end: actual_end,
    removed: actual_end - start + 1,
    preview: preview,
    brief: brief,
    event_id: None,
  })
}

///|
pub fn func_range(
  file : String,
  line : Int,
) -> Result[RangeResult, EditError] {
  let content = @native.read_file(file) catch {
    _ => return Err(EditError::ReadFailed(path=file))
  }
  let lines = split_lines_keep_empty(content)
  
  if line < 1 || line > lines.length() {
    return Err(EditError::InvalidLine(line=line))
  }
  
  let mut start = line
  while start > 1 && !lines[start - 1].contains("{") {
    start -= 1
  }
  if start > 1 && !lines[start - 1].contains("{") && lines[start - 2].contains("{") {
    start -= 1
  }
  
  let mut depth = 0
  let mut seen_open = false
  let mut end = line
  for i in start..<(lines.length() + 1) {
    let l = lines[i - 1]
    if l.contains("{") {
      seen_open = true
    }
    depth += brace_delta(l)
    end = i
    if seen_open && depth <= 0 {
      break
    }
  }
  if end == lines.length() && end > 1 && lines[end - 1] == "" {
    end -= 1
  }
  
  Ok({ start: start, end: end })
}

///|
pub fn balance(
  file : String,
) -> Result[Array[String], EditError] {
  let content = @native.read_file(file) catch {
    _ => return Err(EditError::ReadFailed(path=file))
  }
  
  let stack : Array[Char] = []
  let issues : Array[String] = []
  let mut in_single = false
  let mut in_double = false
  
  for ch in content {
    if ch == '"' && !in_single {
      in_double = !in_double
      continue
    }
    if ch == '\'' && !in_double {
      in_single = !in_single
      continue
    }
    if in_single || in_double {
      continue
    }
    if ch == '(' || ch == '[' || ch == '{' {
      stack.push(ch)
    } else if ch == ')' || ch == ']' || ch == '}' {
      if stack.is_empty() {
        issues.push("extra closing \{ch}")
      } else {
        let top = stack.pop().unwrap()
        if (top == '(' && ch != ')') || (top == '[' && ch != ']') || (top == '{' && ch != '}') {
          issues.push("mismatched pair \{top.to_string()} .. \{ch.to_string()}")
        }
      }
    }
  }
  
  if in_single {
    issues.push("unclosed single quote")
  }
  if in_double {
    issues.push("unclosed double quote")
  }
  for ch in stack {
    issues.push("unclosed \{ch}")
  }
  
  Ok(issues)
}

///|
pub fn tag_range(
  file : String,
  line : Int,
) -> Result[(Int, Int, String), EditError] {
  let content = @native.read_file(file) catch {
    _ => return Err(EditError::ReadFailed(path=file))
  }
  let lines = split_lines_keep_empty(content)
  
  if line < 1 || line > lines.length() {
    return Err(EditError::InvalidLine(line=line))
  }
  
  let mut start = line
  let mut tag_name : String? = None
  while start >= 1 {
    let l = lines[start - 1]
    let trimmed = l.trim()
    if trimmed.has_prefix("<") && !trimmed.has_prefix("</") {
      let body = trimmed[1:].to_owned()
      let mut name = ""
      for ch in body {
        if ch == ' ' || ch == '>' || ch == '/' {
          break
        }
        name += ch.to_string()
      }
      if name != "" {
        tag_name = Some(name)
        break
      }
    }
    start -= 1
  }
  
  if tag_name is None {
    return Err(EditError::InvalidLine(line=line))
  }
  
  let name = tag_name.unwrap()
  let close_pat = "</\{name}>"
  let mut end = start
  while end <= lines.length() {
    if lines[end - 1].contains(close_pat) {
      break
    }
    end += 1
  }
  if end > lines.length() {
    end = lines.length()
  }
  
  Ok((start, end, name))
}
