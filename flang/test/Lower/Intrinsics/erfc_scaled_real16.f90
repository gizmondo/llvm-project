! REQUIRES: flang-supports-f128-math
! RUN: bbc -emit-fir %s -o - | FileCheck %s
! RUN: bbc --math-runtime=precise -emit-fir %s -o - | FileCheck %s
! RUN: %flang_fc1 -emit-fir %s -o - | FileCheck %s

! CHECK: fir.call @_FortranAErfcScaled16({{.*}}) {{.*}}: (f128) -> f128
  real(16) :: a, b
  b = qerfc_scaled(a)
end
