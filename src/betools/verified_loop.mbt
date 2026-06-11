// Verified loop examples

/// Count newlines in a string
pub fn count_newlines(
  s : String,
) -> Int where {
  proof_ensure: result >= 0,
} {
  for i = 0, count = 0; i < s.length(); {
    let new_count = if s[i] == '\n' {
      count + 1
    } else {
      count
    }
    continue i + 1, new_count
  } nobreak {
    count
  } where {
    proof_invariant: count >= 0,
    proof_invariant: i <= s.length(),
  }
}

/// Sum of array elements (for non-negative arrays)
pub fn sum_nonneg(
  arr : Array[Int],
) -> Int where {
  proof_ensure: result >= 0,
} {
  for i = 0, total = 0; i < arr.length(); {
    let val = if arr[i] >= 0 { arr[i] } else { 0 }
    continue i + 1, total + val
  } nobreak {
    total
  } where {
    proof_invariant: total >= 0,
    proof_invariant: i <= arr.length(),
  }
}

/// Find minimum value in array (returns 0 for empty array)
pub fn min_in_array(
  arr : Array[Int],
) -> Int where {
  proof_ensure: result >= 0,
} {
  if arr.length() == 0 {
    0
  } else {
    for i = 1, min_val = arr[0]; i < arr.length(); {
      let new_min = if arr[i] < min_val { arr[i] } else { min_val }
      continue i + 1, new_min
    } nobreak {
      min_val
    } where {
      proof_invariant: i <= arr.length(),
    }
  }
}
