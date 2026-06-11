// Verified functions with formal contracts

///|
pub fn validate_line_number(
  line : Int,
  total : Int,
) -> Bool where {
  proof_require: 0 <= total,
  proof_ensure: 1 <= line && line <= total,
} {
  line >= 1 && line <= total
}

///|
pub fn validate_range(
  start : Int,
  end : Int,
  total : Int,
) -> Bool where {
  proof_require: 0 <= total,
  proof_ensure: 1 <= start && start <= end && end <= total,
} {
  start >= 1 && start <= end && end <= total
}

///|
pub fn clamp_end(
  end : Int,
  total : Int,
) -> Int where {
  proof_require: 0 <= total,
  proof_ensure: 0 <= result && result <= total,
} {
  if end > total {
    total
  } else if end < 0 {
    0
  } else {
    end
  }
}

///|
pub fn safe_array_get(
  arr : Array[String],
  index : Int,
) -> String? where {
  proof_require: arr.length() >= 0,
} {
  if index >= 0 && index < arr.length() {
    Some(arr[index])
  } else {
    None
  }
}
