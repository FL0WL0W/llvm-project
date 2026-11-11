# RUN: llvm-mca -mtriple=powerpc-unknown-eabi -mcpu=e200z3 -iterations=1 -instruction-info %s | FileCheck %s --check-prefixes=ALL,Z3
# RUN: llvm-mca -mtriple=powerpc-unknown-eabi -mcpu=e200z4 -iterations=1 -instruction-info %s | FileCheck %s --check-prefixes=ALL,Z4
# RUN: llvm-mca -mtriple=powerpc-unknown-eabi -mcpu=e200z6 -iterations=1 -instruction-info %s | FileCheck %s --check-prefixes=ALL,Z6
# RUN: llvm-mca -mtriple=powerpc-unknown-eabi -mcpu=e200z7 -iterations=1 -instruction-info %s | FileCheck %s --check-prefixes=ALL,Z7

# Z3: Dispatch Width: 1
# Z4: Dispatch Width: 2
# Z6: Dispatch Width: 1
# Z7: Dispatch Width: 2

# Z3: 1 1 1.00 add 3, 4, 5
# Z4: 1 1 0.50 add 3, 4, 5
# Z6: 1 1 1.00 add 3, 4, 5
# Z7: 1 1 0.50 add 3, 4, 5
add 3, 4, 5
# Z3: 1 1 {{[0-9.]+}} * lwz 6, 0(7)
# Z4: 1 2 {{[0-9.]+}} * lwz 6, 0(7)
# Z6: 1 3 {{[0-9.]+}} * lwz 6, 0(7)
# Z7: 1 3 {{[0-9.]+}} * lwz 6, 0(7)
lwz 6, 0(7)
# Z3: 1 1 1.00 mullw 8, 9, 10
# Z4: 1 2 0.50 mullw 8, 9, 10
# Z6: 1 3 1.00 mullw 8, 9, 10
# Z7: 1 3 0.50 mullw 8, 9, 10
mullw 8, 9, 10
# Z3: 1 1 1.00 efsadd 11, 12, 13
# Z4: 1 2 0.50 efsadd 11, 12, 13
# Z6: 1 3 1.00 efsadd 11, 12, 13
# Z7: 1 4 0.50 efsadd 11, 12, 13
efsadd 11, 12, 13
# Z3: 1 16 16.00 divw 14, 15, 16
# Z4: 1 14 14.00 divw 14, 15, 16
# Z6: 1 16 16.00 divw 14, 15, 16
# Z7: 1 15 15.00 divw 14, 15, 16
divw 14, 15, 16
# Z3: 1 12 12.00 efsdiv 17, 18, 19
# Z4: 1 13 13.00 efsdiv 17, 18, 19
# Z6: 1 12 12.00 efsdiv 17, 18, 19
# Z7: 1 9 9.00 efsdiv 17, 18, 19
efsdiv 17, 18, 19
# Z3: 1 1 {{[0-9.]+}} U evfsadd 20, 21, 22
# Z4: 1 2 {{[0-9.]+}} U evfsadd 20, 21, 22
# Z6: 1 3 {{[0-9.]+}} U evfsadd 20, 21, 22
# Z7: 1 4 {{[0-9.]+}} U evfsadd 20, 21, 22
evfsadd 20, 21, 22
# ALL: 1 32 32.00 U evdivws 23, 24, 25
evdivws 23, 24, 25
