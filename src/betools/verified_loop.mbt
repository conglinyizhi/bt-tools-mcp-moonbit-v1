// Verified loop examples

/// Find the index of first occurrence of a character in a string
/// Returns -1 if not found
pub fn find_char(
  s : String,
  target : Char,
) -> Int where {
  proof_ensure: result => result >= -1,
} {
  let bytes = s.to_bytes()
  for i = 0, found = -1; i < bytes.length(); {
    if bytes[i] == target.to_byte() && found == -1 {
      break found
    } else {
      continue i + 1, found
    }
  } nobreak {
    -1
  } where {
    proof_invariant: found >= -1,
    proof_invariant: found < bytes.length(),
    proof_invariant: found >= 0 => bytes[found] == target.to_byte(),
  }
}

/// Count occurrences of a character
pub fn count_char(
  s : String,
  target : Char,
) -> Int where {
  proof_ensure: result => result >= 0,
} {
  let bytes = s.to_bytes()
  for i = 0, count = 0; i < bytes.length(); {
    let new_count = if bytes[i] == target.to_byte() {
      count + 1
    } else {
      count
    }
    continue i + 1, new_count
  } nobreak {
    count
  } where {
    proof_invariant: count >= 0,
    proof_invariant: i <= bytes.length(),
  }
}

/// Sum of array elements (for non-negative arrays)
pub fn sum_nonneg(
  arr : Array[Int],
) -> Int where {
  proof_ensure: result => result >= 0,
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
