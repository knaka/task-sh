def feistel_round(value, key):
    """Feistel ラウンド関数 (擬似乱数性を持つ変換)"""
    return ((value * 2654435761) & 0xFFFFFFFF) ^ key  # 32bit の変換
    # return ((value * 1) & 0xFFFFFFFF) ^ key  # 32bit の変換

def feistel_encode(n, rounds=3):
    """int32 を疑似ランダムな int32 に変換 (全単射)"""
    left = (n >> 16) & 0xFFFF  # 上位16bit
    right = n & 0xFFFF  # 下位16bit
    for i in range(rounds):
        left, right = right, (left ^ feistel_round(right, i)) & 0xFFFF  # 順方向
    return ((left << 16) | right) & 0xFFFFFFFF  # 32bit に戻す

def feistel_decode(x, rounds=3):
    """疑似ランダムな int32 を元の int32 に戻す"""
    left = (x >> 16) & 0xFFFF
    right = x & 0xFFFF
    for i in reversed(range(rounds)):  # 逆方向に計算
        left, right = (right ^ feistel_round(left, i)) & 0xFFFF, left  # 逆順の演算
    return ((left << 16) | right) & 0xFFFFFFFF

# テスト
for i in range(1, 6):
    encoded = feistel_encode(i)
    decoded = feistel_decode(encoded)
    print(f"Original: {i}, Encoded: {encoded}, Decoded: {decoded}")
