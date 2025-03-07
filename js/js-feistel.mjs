const HASHING_CONST_32 = 2654435761;

function feistelRound(value, key) {
  return ((value * HASHING_CONST_32 + key) >>> 0)
}

export function feistelEncode(n, rounds = 3) {
  let left = (n >>> 16) & 0xFFFF;
  let right = n & 0xFFFF;
  for (let i = 0; i < rounds; i++) {
      [left, right] = [right, (left ^ feistelRound(right, i)) & 0xFFFF];
  }
  return ((left << 16) | right) >>> 0;
}

export function feistelDecode(x, rounds = 3) {
  let left = (x >>> 16) & 0xFFFF;
  let right = x & 0xFFFF;
  for (let i = rounds - 1; i >= 0; i--) {
      [left, right] = [(right ^ feistelRound(left, i)) & 0xFFFF, left];
  }
  return ((left << 16) | right) >>> 0;
}

// test
for (let i = 0; i <= 0xFFFFFFFF; i++) {
  const encoded = feistelEncode(i);
  const decoded = feistelDecode(encoded);
  // console.log(`Original: ${i}, Encoded: ${encoded}, Decoded: ${decoded}`);
  if (i !== decoded) {
    console.error(`Error: ${i} !== ${decoded}`);
  }
}
