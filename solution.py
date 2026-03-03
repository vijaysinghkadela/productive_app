import urllib.request
import json
import ast

def solve(a, K):
    n = len(a)
    max_val = float('-inf')
    for i in range(n):
        for j in range(i, n):
            sub = a[i:j+1]
            val = sum(sub) - K ** len(set(sub))
            max_val = max(max_val, val)
    return max_val

test_cases = [
    ([1, 2, 1, 3], 2),
    ([1, 2, 3, 4], 0),
    ([1, 1, 1, 1], 1),
    ([23, 11, 29, 21, 1], 2),
    ([80, 89, 78, 64, 48, 61, 7], 1),
    ([76, 35], 0),
    ([51, 6], 3),
    ([99, 15, 66, 17, 34, 46, 51, 74], 5),
    ([793, 200, 311, 650, 484, 888, 305, 960, 694, 219, 8, 201, 899, 412, 608, 936, 186, 300, 935, 931, 38, 959, 211, 419, 755, 64, 896, 706, 396, 442, 693, 622, 597, 854, 401, 700, 680, 582, 375, 590, 847, 492, 351, 804, 765, 301, 959, 137, 725, 419, 2, 736, 883, 765, 773, 560, 151, 781, 792, 539, 477, 659, 210, 503, 332, 290, 308, 775, 439, 442, 222, 61, 712, 114, 224, 727, 486, 106, 922, 45, 987, 831, 237, 497, 729, 649, 397, 868, 590, 294, 300, 111, 951, 626, 689, 759, 93, 769, 7, 344, 497, 989, 281, 735, 31, 988, 148, 117, 381, 736, 437, 12, 116, 114, 577, 595, 354, 323, 754, 377, 403, 403, 834, 804, 1, 956, 10, 784, 185, 383, 1, 62, 531, 179, 946, 999, 994, 253, 590, 646, 529, 105, 304, 537, 269, 584, 84, 497, 618, 939, 420, 318, 211, 5, 874, 911, 133, 319, 649, 128, 408, 29, 5, 123, 43, 856, 984, 723, 674, 400, 934, 14, 306, 153, 747, 47, 994], 1)
]

tc_list = []
for a, K in test_cases:
    expected = solve(a, K)
    tc_list.append({
        "input": f"{len(a)} {K}\n{' '.join(map(str, a))}",
        "output": str(expected)
    })

code = """
def solve(a, K):
    n = len(a)
    max_val = float('-inf')
    for i in range(n):
        for j in range(i, n):
            sub = a[i:j+1]
            val = sum(sub) - K ** len(set(sub))
            max_val = max(max_val, val)
    return max_val

import sys
input = sys.stdin.read
data = input().split()
if data:
    n = int(data[0])
    K = int(data[1])
    a = list(map(int, data[2:n+2]))
    print(solve(a, K))
"""

output_dict = {
    "test_cases": tc_list,
    "code": code.strip()
}

with open("final_output.json", "w") as f:
    json.dump(output_dict, f, indent=2)

print("success")
