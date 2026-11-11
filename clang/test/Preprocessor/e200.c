// RUN: %clang_cc1 -triple powerpc-unknown-eabi -target-cpu e200z3 -E -dM %s | FileCheck %s
// RUN: %clang_cc1 -triple powerpc-unknown-eabi -target-cpu e200z4 -E -dM %s | FileCheck %s
// RUN: %clang_cc1 -triple powerpc-unknown-eabi -target-cpu e200z6 -E -dM %s | FileCheck %s
// RUN: %clang_cc1 -triple powerpc-unknown-eabi -target-cpu e200z7 -E -dM %s | FileCheck %s
// RUN: %clang_cc1 -triple powerpc-unknown-eabi -target-cpu e200z6 -target-feature -spe -E -dM %s | FileCheck %s --check-prefix=NO-SPE
// RUN: %clang_cc1 -triple powerpc-unknown-eabi -target-cpu e200z6 -emit-llvm -o - %s | FileCheck %s --check-prefix=FEATURES
// RUN: %clang -target powerpc-unknown-eabi -mcpu=e200z6 -mtune=e200z7 -emit-llvm -S -o - %s | FileCheck %s --check-prefix=TUNE

// CHECK-NOT: #define __ALTIVEC__
// CHECK: #define __LDBL_MANT_DIG__ 53
// CHECK: #define __SPE__ 1
// CHECK: #define __powerpc__ 1
// CHECK-NOT: #define __powerpc64__
// NO-SPE-NOT: #define __SPE__
// FEATURES: "target-cpu"="e200z6"
// FEATURES-SAME: "target-features"="{{[^"]*}}+booke{{[^"]*}}+spe{{[^"]*}}+spe-single
// TUNE: "target-cpu"="e200z6"
// TUNE-SAME: "tune-cpu"="e200z7"
int cpu_features(void) { return sizeof(long double); }
