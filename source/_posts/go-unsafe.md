---
title: go-unsafe
author: Payne
tags:
  - go
categories:
  - - go
    - unsafe
abbrlink: 984068165
date: 2022-05-01 17:05:31
---

## Go标准库

Go标准库中的unsafe包非常简洁，如下所示

```go
// 用于获取一个表达式值的大小
func Sizeof(x ArbitraryType) uintptr

// 用于获取结构体中某字段段地址偏移量（相对于结构体变量的地址）
// Offsetof函数应用面较窄，仅用于结构体某字段的偏移值
func Offsetof(x ArbitraryType) uintptr

// Alignof用于获取一个表达式的内存补齐系数
func Alignof(x ArbitraryType) uintptr

// Add 将 len 添加到 ptr 并返回更新后的指针 Pointer(uintptr(ptr) + uintptr(len))。
// len 参数必须是整数类型或无类型常量。
// 一个常量 len 参数必须可以用一个 int 类型的值来表示；
// 如果它是一个无类型常量，它被赋予 int 类型。 Pointer 的有效使用规则仍然适用。
func Add(ptr Pointer, len IntegerType) Pointer


// 函数 Slice 返回一个切片，其底层数组从 ptr 开始，长度和容量为 len。 
// Slice(ptr, len) 等价于 ([len]ArbitraryType)(unsafe.Pointer(ptr))[:] ，
// 除了作为特殊情况，如果 ptr 为 nil 且 len 为零，Slice 返回 nil。 
// len 参数必须是整数类型或无类型常量。
// 一个常量 len 参数必须是非负的并且可以用一个int类型的值来表示；
// 如果它是一个无类型常量，它被赋予int类型。在运行时，
// 如果len为负数，或者ptr为nil且len不为零，则会发生运行时恐慌
func Slice(ptr *ArbitraryType, len IntegerType) []ArbitraryType
```

### 典型使用

怎么理解Go核心团队在尽力保证go类型安全的情况下，又提供了可以打破安全屏障的`unsafe.Pointer` 这一行为？

首先被广泛应用于Go标准库和Go 运行时的实现当中，reflect、sync、syscall、runtime都是unsafe包的重度用户。

#### reflect

ValueOf 和TypeOf函数是reflect包中用得最多的两个API，他们是进入运行时反射层、获取发射层信息的入口。这两个函数均将任意类型变量转化为一个`interface{}` 类型变量，再利用`unsafe.Pointer` 将这个变量绑定的内存区域重新解释为reflect.emptyInterface类型，以获得传入变量的类型和值类的信息

```go
// $GOROOT/src/reflect/values.go
// emptyInterface is the header for an interface{} value.
type emptyInterface struct {
	typ  *rtype
	word unsafe.Pointer
}


// unpackEface converts the empty interface i to a Value.
func unpackEface(i any) Value {
	e := (*emptyInterface)(unsafe.Pointer(&i))
	// NOTE: don't read e.word until we know whether it is really a pointer or not.
	t := e.typ
	if t == nil {
		return Value{}
	}
	f := flag(t.Kind())
	if ifaceIndir(t) {
		f |= flagIndir
	}
	return Value{t, e.word, f}
}

// $GOROOT/src/reflect/type.go
// If i is a nil interface value, TypeOf returns nil.
func TypeOf(i any) Type {
	eface := *(*emptyInterface)(unsafe.Pointer(&i))
	return toType(eface.typ)
}
```

#### sync

sync.Pool 是个并发安全的高性能临时对象缓冲池。Pool 为每个P分配了一个本地缓冲池，并通过下列函数为每个P分配啦一个本地的缓冲池，并通过如下函数实现快速定位P的本地缓冲池。

```go
func indexLocal(l unsafe.Pointer, i int) *poolLocal {
	lp := unsafe.Pointer(uintptr(l) + uintptr(i)*unsafe.Sizeof(poolLocal{}))
	return (*poolLocal)(lp)
}
// indexLocal函数的本地缓冲池快速定位时通过结合unsafe.Pointer包与uinptr的指针运算实现
```

标准库中的saycall包封装了与操作系统交互的系统调用接口，比如Statfs、Listen、Select

```go
// $GOROOT/src/syscall/zsyscall_linux_amd64.go
func Statfs(path string, buf *Statfs_t) (err error) {
	var _p0 *byte
	_p0, err = BytePtrFromString(path)
	if err != nil {
		return
	}
	_, _, e1 := Syscall(SYS_STATFS, uintptr(unsafe.Pointer(_p0)), uintptr(unsafe.Pointer(buf)), 0)
	if e1 != 0 {
		err = errnoErr(e1)
	}
	return
}

func Listen(s int, n int) (err error) {
	_, _, e1 := Syscall(SYS_LISTEN, uintptr(s), uintptr(n), 0)
	if e1 != 0 {
		err = errnoErr(e1)
	}
	return
}

func Select(nfd int, r *FdSet, w *FdSet, e *FdSet, timeout *Timeval) (n int, err error) {
	r0, _, e1 := Syscall6(SYS_SELECT, uintptr(nfd), uintptr(unsafe.Pointer(r)), uintptr(unsafe.Pointer(w)), uintptr(unsafe.Pointer(e)), uintptr(unsafe.Pointer(timeout)), 0)
	n = int(r0)
	if e1 != 0 {
		err = errnoErr(e1)
	}
	return
}
```

这类的高级调用的最终都会落到调用函数下面一系列的Syscall和RawSyscall函数上面。

```go
func Syscall(trap, a1, a2, a3 uintptr) (r1, r2 uintptr, err Errno)
func Syscall6(trap, a1, a2, a3, a4, a5, a6 uintptr) (r1, r2 uintptr, err Errno)
func RawSyscall(trap, a1, a2, a3 uintptr) (r1, r2 uintptr, err Errno)
func RawSyscall6(trap, a1, a2, a3, a4, a5, a6 uintptr) (r1, r2 uintptr, err Errno)
```

这些Saycall系列的函数接受的参数类型均为uintptr，这样当封装的系统调用的参数为指针类型时（比如上面Select的参数r、w、e等）。只能只能通过unsafe.uintptr值，就像上面Select函数实现中那样。因此，syscall包是unsafe重度使用者，它的实现离不开的unsafe.Pointer。

#### runtime包中的unsafe包的典型应用

runtime 包实现的goroutine调度和内存管理（包括GC）都有unsafe包的身影以goroutine的栈管理为例：

```go
// $GOROOT/src/runtime/stack.go
type stack struct {
	lo uintptr
	hi uintptr
}

// $GOROOT/src/runtime/runtime.go
func stackalloc(n uint32) stack {
	// Stackalloc must be called on scheduler stack, so that we
	// never try to grow the stack during the code that stackalloc runs.
	// Doing so would cause a deadlock (issue 1547).
	thisg := getg()
	if thisg != thisg.m.g0 {
		throw("stackalloc not on scheduler stack")
	}
	if n&(n-1) != 0 {
		throw("stack size not a power of 2")
	}
	if stackDebug >= 1 {
		print("stackalloc ", n, "\n")
	}

	if debug.efence != 0 || stackFromSystem != 0 {
		n = uint32(alignUp(uintptr(n), physPageSize))
		v := sysAlloc(uintptr(n), &memstats.stacks_sys)
		if v == nil {
			throw("out of memory (stackalloc)")
		}
		return stack{uintptr(v), uintptr(v) + uintptr(n)}
	}

	// Small stacks are allocated with a fixed-size free-list allocator.
	// If we need a stack of a bigger size, we fall back on allocating
	// a dedicated span.
	var v unsafe.Pointer
	if n < _FixedStack<<_NumStackOrders && n < _StackCacheSize {
		order := uint8(0)
		n2 := n
		for n2 > _FixedStack {
			order++
			n2 >>= 1
		}
		var x gclinkptr
		if stackNoCache != 0 || thisg.m.p == 0 || thisg.m.preemptoff != "" {
			// thisg.m.p == 0 can happen in the guts of exitsyscall
			// or procresize. Just get a stack from the global pool.
			// Also don't touch stackcache during gc
			// as it's flushed concurrently.
			lock(&stackpool[order].item.mu)
			x = stackpoolalloc(order)
			unlock(&stackpool[order].item.mu)
		} else {
			c := thisg.m.p.ptr().mcache
			x = c.stackcache[order].list
			if x.ptr() == nil {
				stackcacherefill(c, order)
				x = c.stackcache[order].list
			}
			c.stackcache[order].list = x.ptr().next
			c.stackcache[order].size -= uintptr(n)
		}
		v = unsafe.Pointer(x)
	} else {
		var s *mspan
		npage := uintptr(n) >> _PageShift
		log2npage := stacklog2(npage)

		// Try to get a stack from the large stack cache.
		lock(&stackLarge.lock)
		if !stackLarge.free[log2npage].isEmpty() {
			s = stackLarge.free[log2npage].first
			stackLarge.free[log2npage].remove(s)
		}
		unlock(&stackLarge.lock)

		lockWithRankMayAcquire(&mheap_.lock, lockRankMheap)

		if s == nil {
			// Allocate a new stack from the heap.
			s = mheap_.allocManual(npage, spanAllocStack)
			if s == nil {
				throw("out of memory")
			}
			osStackAlloc(s)
			s.elemsize = uintptr(n)
		}
		v = unsafe.Pointer(s.base())
	}

	if raceenabled {
		racemalloc(v, uintptr(n))
	}
	if msanenabled {
		msanmalloc(v, uintptr(n))
	}
	if asanenabled {
		asanunpoison(v, uintptr(n))
	}
	if stackDebug >= 1 {
		print("  allocated ", v, "\n")
	}
	return stack{uintptr(v), uintptr(v) + uintptr(n)}
}
```

## unsafe.Pointer 与 uintptr

作为Go类型安全层上的一个“后门”，unsafe包在带来强大的低级编程能力的同时，也极容易导致代码出现错误。而出现浙西错误的原因主要就是对unsafe.Pointer和uintptr的理解不到位。因此正确理解unsafe.Pointer和uintptr对于安全使用unsafe包非常有必要。

Go语言内存管理是基于垃圾回收的，垃圾回收会定期进行，如歌一块内存没有被任何对象引用，他就会被垃圾回收器回收掉，而对象引用是通过指针实现的。

unsafe.Pointer 和其他常规类型的指针一样，可以作为对象引用。如果一个对象仍然被某个unsafe.Pointer 变量引用着则该对象不会被回收（垃圾回收）。

**即使他存储的是某个对象的内存地址值，它也不会被算作该对象的被算作对该对象的引用**

**如果认为将对象地址存储在一个uintptr变量中，该对象就不会被垃圾回收器回收，那是对uintptr的最大误解**

## 安全使用

我们既需要unsafe.Pointer打破类型的安全屏障，又需要器能够被安全的使用。如下有几条安全法则

### `*T1` -> unsafe.Pointer -> `*T2` 

其本质就是内存重解释，将原本解释为T1的类型内存重新解释为T2类型。

> 这是unsafe.Pointer 突破Go类型安全的屏障的基本使用模式

注意：转换后类型T2, 对对其系数不能比转换前类型T1的对其系数**更严格**，即Alignof(T1) => Alignof(T2)

### unsafe.Pointer -> uintptr

将unsafe.Pointer 显示转换为uinptr，并且转换后的uintptr类型不会在转换回unsafe.Pointer 只用于打印输出，并不参与其他操作。

### 模拟指针运算

操作任意内存地址上的数据都离不开指针运算。Go常规语法不支持指针运算，但我们可以使用unsafe.Pointer的第三种安全使用模式来模拟指针运算，即在一个表达式中，将unsafe.Pointer转换为uintptr类型，使用uintptr类型的值进行算术运算后，再转换回unsafe.Pointer

经常用于访问结构体内字段或数组中的元素，也常用于实现对某内存对象的步进式检查

注意事项:

* 不要越界offset理论上可以是任意值，这就存在算术运算之后的地址超出原内存对象边界的可能。 经过转换后，p指向的地址已经超出原数组a的边界，访问这块内存区域是有风险的，尤其是当你尝试去修改它的时候。
* unsafe.Pointer -> uintptr -> unsafe.Pointer的转换要在一个表达式中

### 调用syscall.Syscall系列函数时指针类型到uintptr类型参数的转换

### 将reflect.Value.Pointer或reflect.Value.UnsafeAddr转换为指针

### reflect.SliceHeader和reflect.StringHeader必须通过`unsafe.Pointer -> uintptr`构建





## Tips:

使用unsfa包前，请牢记并理解unsafe.Pointer 的六条安全使用模式

如果使用了unsafe包，请使用`go vet` 等工具对代码进行unsafe包使用合规性检查



