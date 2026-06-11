// Formal contracts for core functions

///|
#proof_pure
pub fn validated_line_index(line : Int, total : Int) -> Bool {
  line >= 1 && line <= total
}

///|
#proof_pure
pub fn validated_range(start : Int, end : Int, total : Int) -> Bool {
  start >= 1 && start <= end && end <= total
}

///|
#proof_pure
pub fn validated_insert_line(after : Int, total : Int) -> Bool {
  after >= 0 && after <= total
}

///|
#proof_pure
pub fn clamped_end(end : Int, total : Int) -> Int {
  if end > total {
    total
  } else {
    end
  }
}

///|
#proof_pure
pub fn line_count_after_replace(old_count : Int, new_count : Int, removed : Int) -> Int {
  old_count - removed + new_count
}

///|
#proof_pure
pub fn line_count_after_insert(old_count : Int, inserted : Int) -> Int {
  old_count + inserted
}

///|
#proof_pure
pub fn line_count_after_delete(old_count : Int, removed : Int) -> Int {
  old_count - removed
}

// Verified wrapper for file_total_lines
///|
pub fn safe_file_total_lines(lines : Array[String]) -> Int where {
  proof_ensure: result >= 0,
  proof_ensure: result <= lines.length(),
} {
  if lines.length() > 0 && lines[lines.length() - 1] == "" {
    lines.length() - 1
  } else {
    lines.length()
  }
}

// Verified wrapper for line validation
///|
pub fn check_line_in_range(line : Int, total : Int) -> Bool where {
  proof_require: total >= 0,
} {
  line >= 1 && line <= total
}

// Verified wrapper for range validation
///|
pub fn check_range_valid(start : Int, end : Int, total : Int) -> Bool where {
  proof_require: total >= 0,
} {
  start >= 1 && start <= end && end <= total
}

// Verified wrapper for insert line validation
///|
pub fn check_insert_valid(after : Int, total : Int) -> Bool where {
  proof_require: total >= 0,
} {
  after >= 0 && after <= total
}

// Safe array access with bounds checking
///|
pub fn safe_get_line(lines : Array[String], index : Int) -> String? where {
  proof_require: lines.length() >= 0,
} {
  if index >= 0 && index < lines.length() {
    Some(lines[index])
  } else {
    None
  }
}

// Calculate diff statistics
///|
pub fn calc_diff_stats(
  old_lines : Int,
  new_lines : Int,
) -> (Int, Int) where {
  proof_require: old_lines >= 0,
  proof_require: new_lines >= 0,
} {
  let removed = old_lines
  let added = new_lines
  (removed, added)
}

// Batch edit result validation
///|
pub fn validate_batch_result(
  files : Int,
  edits : Int,
) -> Bool where {
} {
  files >= 0 && edits >= 0
}

// Verified line count calculations
///|
pub fn safe_line_count(content : String) -> Int where {
  proof_ensure: result >= 0,
} {
  if content == "" {
    0
  } else {
    count_newlines_impl(content)
  }
}

fn count_newlines_impl(content : String) -> Int {
  let mut count = 1
  for i in 0..<content.length() {
    if content[i] == '\n' {
      count += 1
    }
  }
  count
}
