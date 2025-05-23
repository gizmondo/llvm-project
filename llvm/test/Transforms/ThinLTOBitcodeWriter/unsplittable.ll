; RUN: opt -thinlto-bc -thin-link-bitcode-file=%t2 -thinlto-split-lto-unit -o %t %s
; RUN: llvm-dis -o - %t | FileCheck %s
; RUN: llvm-bcanalyzer -dump %t | FileCheck --check-prefix=BCA %s
; When not splitting the module, the thin link bitcode file should simply be a
; copy of the regular module.
; RUN: diff %t %t2


; Do it again, with preserved uselistorder
; RUN: opt --preserve-bc-uselistorder -thinlto-bc -thin-link-bitcode-file=%t2 -thinlto-split-lto-unit -o %t %s
; RUN: llvm-dis --preserve-ll-uselistorder -o - %t | FileCheck -check-prefixes=CHECK,USELISTORDER %s
; RUN: llvm-bcanalyzer -dump %t | FileCheck --check-prefix=BCA %s
; When not splitting the module, the thin link bitcode file should simply be a
; copy of the regular module.
; RUN: diff %t %t2


; BCA: <FULL_LTO_GLOBALVAL_SUMMARY_BLOCK
; BCA-NOT: <GLOBALVAL_SUMMARY_BLOCK

; CHECK: @llvm.global_ctors = appending global
@llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @f, ptr null }]

; CHECK: @g = internal global i8 42, !type !0
@g = internal global i8 42, !type !0

declare void @sink(ptr)

; CHECK: define internal void @f()
define internal void @f() {
  call void @sink(ptr @g)
  call void @sink(ptr @g)
  call void @sink(ptr @g)
  ret void
}

$h = comdat any
; CHECK: define void @h() comdat
define void @h() comdat {
  ret void
}

uselistorder ptr @g, { 2, 1, 0}
; USELISTORDER: uselistorder ptr @g, { 2, 1, 0 }

; CHECK: !llvm.module.flags = !{![[FLAG1:[0-9]+]], ![[FLAG2:[0-9]+]]}
; CHECK: ![[FLAG1]] = !{i32 1, !"EnableSplitLTOUnit", i32 1}
; CHECK: ![[FLAG2]] = !{i32 1, !"ThinLTO", i32 0}

!0 = !{i32 0, !"typeid"}
