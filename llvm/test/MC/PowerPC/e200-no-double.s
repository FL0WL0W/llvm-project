# RUN: not llvm-mc -triple=powerpc-unknown-eabi -mcpu=e200z3 %s 2>&1 | FileCheck %s
# RUN: not llvm-mc -triple=powerpc-unknown-eabi -mcpu=e200z4 %s 2>&1 | FileCheck %s
# RUN: not llvm-mc -triple=powerpc-unknown-eabi -mcpu=e200z6 %s 2>&1 | FileCheck %s
# RUN: not llvm-mc -triple=powerpc-unknown-eabi -mcpu=e200z7 %s 2>&1 | FileCheck %s
# RUN: llvm-mc -triple=powerpc-unknown-eabi -mcpu=e500 %s -o /dev/null

# CHECK: error: instruction use requires an option to be enabled
efdadd 3, 4, 5
# CHECK: error: instruction use requires an option to be enabled
efdcfs 3, 4
# CHECK: error: instruction use requires an option to be enabled
efscfd 3, 4
