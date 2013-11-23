
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 10 12 00       	mov    $0x121000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 10 12 f0       	mov    $0xf0121000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 f0 00 00 00       	call   f010012e <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	83 ec 10             	sub    $0x10,%esp
f0100048:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010004b:	83 3d 80 be 22 f0 00 	cmpl   $0x0,0xf022be80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 be 22 f0    	mov    %esi,0xf022be80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 48 6c 00 00       	call   f0106cac <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 20 74 10 f0 	movl   $0xf0107420,(%esp)
f010007d:	e8 1c 46 00 00       	call   f010469e <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 dd 45 00 00       	call   f010466b <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 fd 86 10 f0 	movl   $0xf01086fd,(%esp)
f0100095:	e8 04 46 00 00       	call   f010469e <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 fa 0b 00 00       	call   f0100ca0 <monitor>
f01000a6:	eb f2                	jmp    f010009a <_panic+0x5a>

f01000a8 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01000a8:	55                   	push   %ebp
f01000a9:	89 e5                	mov    %esp,%ebp
f01000ab:	83 ec 18             	sub    $0x18,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01000ae:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000b8:	77 20                	ja     f01000da <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01000be:	c7 44 24 08 44 74 10 	movl   $0xf0107444,0x8(%esp)
f01000c5:	f0 
f01000c6:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
f01000cd:	00 
f01000ce:	c7 04 24 8b 74 10 f0 	movl   $0xf010748b,(%esp)
f01000d5:	e8 66 ff ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01000da:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01000df:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01000e2:	e8 c5 6b 00 00       	call   f0106cac <cpunum>
f01000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000eb:	c7 04 24 97 74 10 f0 	movl   $0xf0107497,(%esp)
f01000f2:	e8 a7 45 00 00       	call   f010469e <cprintf>

	lapic_init();
f01000f7:	e8 cb 6b 00 00       	call   f0106cc7 <lapic_init>
	env_init_percpu();
f01000fc:	e8 06 3d 00 00       	call   f0103e07 <env_init_percpu>
	trap_init_percpu();
f0100101:	e8 e7 45 00 00       	call   f01046ed <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100106:	e8 a1 6b 00 00       	call   f0106cac <cpunum>
f010010b:	6b d0 74             	imul   $0x74,%eax,%edx
f010010e:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100114:	b8 01 00 00 00       	mov    $0x1,%eax
f0100119:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010011d:	c7 04 24 a0 34 12 f0 	movl   $0xf01234a0,(%esp)
f0100124:	e8 34 6e 00 00       	call   f0106f5d <spin_lock>
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	
	lock_kernel();
	sched_yield();
f0100129:	e8 06 51 00 00       	call   f0105234 <sched_yield>

f010012e <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010012e:	55                   	push   %ebp
f010012f:	89 e5                	mov    %esp,%ebp
f0100131:	53                   	push   %ebx
f0100132:	83 ec 14             	sub    $0x14,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100135:	b8 08 d0 26 f0       	mov    $0xf026d008,%eax
f010013a:	2d 0a a7 22 f0       	sub    $0xf022a70a,%eax
f010013f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100143:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010014a:	00 
f010014b:	c7 04 24 0a a7 22 f0 	movl   $0xf022a70a,(%esp)
f0100152:	e8 ae 64 00 00       	call   f0106605 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100157:	e8 3b 05 00 00       	call   f0100697 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010015c:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100163:	00 
f0100164:	c7 04 24 ad 74 10 f0 	movl   $0xf01074ad,(%esp)
f010016b:	e8 2e 45 00 00       	call   f010469e <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100170:	e8 44 19 00 00       	call   f0101ab9 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100175:	e8 b7 3c 00 00       	call   f0103e31 <env_init>
	trap_init();
f010017a:	e8 3c 46 00 00       	call   f01047bb <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010017f:	90                   	nop
f0100180:	e8 3f 68 00 00       	call   f01069c4 <mp_init>
	lapic_init();
f0100185:	e8 3d 6b 00 00       	call   f0106cc7 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f010018a:	e8 3c 44 00 00       	call   f01045cb <pic_init>
f010018f:	c7 04 24 a0 34 12 f0 	movl   $0xf01234a0,(%esp)
f0100196:	e8 c2 6d 00 00       	call   f0106f5d <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010019b:	83 3d 88 be 22 f0 07 	cmpl   $0x7,0xf022be88
f01001a2:	77 24                	ja     f01001c8 <i386_init+0x9a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001a4:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f01001ab:	00 
f01001ac:	c7 44 24 08 68 74 10 	movl   $0xf0107468,0x8(%esp)
f01001b3:	f0 
f01001b4:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
f01001bb:	00 
f01001bc:	c7 04 24 8b 74 10 f0 	movl   $0xf010748b,(%esp)
f01001c3:	e8 78 fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001c8:	b8 da 68 10 f0       	mov    $0xf01068da,%eax
f01001cd:	2d 60 68 10 f0       	sub    $0xf0106860,%eax
f01001d2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001d6:	c7 44 24 04 60 68 10 	movl   $0xf0106860,0x4(%esp)
f01001dd:	f0 
f01001de:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f01001e5:	e8 79 64 00 00       	call   f0106663 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001ea:	6b 05 c4 c3 22 f0 74 	imul   $0x74,0xf022c3c4,%eax
f01001f1:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f01001f6:	3d 20 c0 22 f0       	cmp    $0xf022c020,%eax
f01001fb:	76 62                	jbe    f010025f <i386_init+0x131>
f01001fd:	bb 20 c0 22 f0       	mov    $0xf022c020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f0100202:	e8 a5 6a 00 00       	call   f0106cac <cpunum>
f0100207:	6b c0 74             	imul   $0x74,%eax,%eax
f010020a:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f010020f:	39 c3                	cmp    %eax,%ebx
f0100211:	74 39                	je     f010024c <i386_init+0x11e>

static void boot_aps(void);


void
i386_init(void)
f0100213:	89 d8                	mov    %ebx,%eax
f0100215:	2d 20 c0 22 f0       	sub    $0xf022c020,%eax
	for (c = cpus; c < cpus + ncpu; c++) {
		if (c == cpus + cpunum())  // We've started already.
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010021a:	c1 f8 02             	sar    $0x2,%eax
f010021d:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100223:	c1 e0 0f             	shl    $0xf,%eax
f0100226:	8d 80 00 50 23 f0    	lea    -0xfdcb000(%eax),%eax
f010022c:	a3 84 be 22 f0       	mov    %eax,0xf022be84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100231:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100238:	00 
f0100239:	0f b6 03             	movzbl (%ebx),%eax
f010023c:	89 04 24             	mov    %eax,(%esp)
f010023f:	e8 d3 6b 00 00       	call   f0106e17 <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100244:	8b 43 04             	mov    0x4(%ebx),%eax
f0100247:	83 f8 01             	cmp    $0x1,%eax
f010024a:	75 f8                	jne    f0100244 <i386_init+0x116>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010024c:	83 c3 74             	add    $0x74,%ebx
f010024f:	6b 05 c4 c3 22 f0 74 	imul   $0x74,0xf022c3c4,%eax
f0100256:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f010025b:	39 c3                	cmp    %eax,%ebx
f010025d:	72 a3                	jb     f0100202 <i386_init+0xd4>
	boot_aps();


#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010025f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100266:	00 
f0100267:	c7 44 24 04 a4 9a 00 	movl   $0x9aa4,0x4(%esp)
f010026e:	00 
f010026f:	c7 04 24 66 0c 22 f0 	movl   $0xf0220c66,(%esp)
f0100276:	e8 de 3d 00 00       	call   f0104059 <env_create>
	ENV_CREATE(user_stresssched, ENV_TYPE_USER);
	//	ENV_CREATE(user_primes, ENV_TYPE_USER);
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f010027b:	e8 b4 4f 00 00       	call   f0105234 <sched_yield>

f0100280 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100280:	55                   	push   %ebp
f0100281:	89 e5                	mov    %esp,%ebp
f0100283:	53                   	push   %ebx
f0100284:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100287:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010028a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010028d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100291:	8b 45 08             	mov    0x8(%ebp),%eax
f0100294:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100298:	c7 04 24 c8 74 10 f0 	movl   $0xf01074c8,(%esp)
f010029f:	e8 fa 43 00 00       	call   f010469e <cprintf>
	vcprintf(fmt, ap);
f01002a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01002a8:	8b 45 10             	mov    0x10(%ebp),%eax
f01002ab:	89 04 24             	mov    %eax,(%esp)
f01002ae:	e8 b8 43 00 00       	call   f010466b <vcprintf>
	cprintf("\n");
f01002b3:	c7 04 24 fd 86 10 f0 	movl   $0xf01086fd,(%esp)
f01002ba:	e8 df 43 00 00       	call   f010469e <cprintf>
	va_end(ap);
}
f01002bf:	83 c4 14             	add    $0x14,%esp
f01002c2:	5b                   	pop    %ebx
f01002c3:	5d                   	pop    %ebp
f01002c4:	c3                   	ret    
f01002c5:	66 90                	xchg   %ax,%ax
f01002c7:	66 90                	xchg   %ax,%ax
f01002c9:	66 90                	xchg   %ax,%ax
f01002cb:	66 90                	xchg   %ax,%ax
f01002cd:	66 90                	xchg   %ax,%ax
f01002cf:	90                   	nop

f01002d0 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01002d0:	55                   	push   %ebp
f01002d1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002d3:	ba 84 00 00 00       	mov    $0x84,%edx
f01002d8:	ec                   	in     (%dx),%al
f01002d9:	ec                   	in     (%dx),%al
f01002da:	ec                   	in     (%dx),%al
f01002db:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01002dc:	5d                   	pop    %ebp
f01002dd:	c3                   	ret    

f01002de <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002de:	55                   	push   %ebp
f01002df:	89 e5                	mov    %esp,%ebp
f01002e1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002e6:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002e7:	a8 01                	test   $0x1,%al
f01002e9:	74 08                	je     f01002f3 <serial_proc_data+0x15>
f01002eb:	b2 f8                	mov    $0xf8,%dl
f01002ed:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002ee:	0f b6 c0             	movzbl %al,%eax
f01002f1:	eb 05                	jmp    f01002f8 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01002f8:	5d                   	pop    %ebp
f01002f9:	c3                   	ret    

f01002fa <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002fa:	55                   	push   %ebp
f01002fb:	89 e5                	mov    %esp,%ebp
f01002fd:	53                   	push   %ebx
f01002fe:	83 ec 04             	sub    $0x4,%esp
f0100301:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100303:	eb 26                	jmp    f010032b <cons_intr+0x31>
		if (c == 0)
f0100305:	85 d2                	test   %edx,%edx
f0100307:	74 22                	je     f010032b <cons_intr+0x31>
			continue;
		cons.buf[cons.wpos++] = c;
f0100309:	a1 24 b2 22 f0       	mov    0xf022b224,%eax
f010030e:	88 90 20 b0 22 f0    	mov    %dl,-0xfdd4fe0(%eax)
f0100314:	8d 50 01             	lea    0x1(%eax),%edx
		if (cons.wpos == CONSBUFSIZE)
f0100317:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f010031d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100322:	0f 44 d0             	cmove  %eax,%edx
f0100325:	89 15 24 b2 22 f0    	mov    %edx,0xf022b224
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010032b:	ff d3                	call   *%ebx
f010032d:	89 c2                	mov    %eax,%edx
f010032f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100332:	75 d1                	jne    f0100305 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100334:	83 c4 04             	add    $0x4,%esp
f0100337:	5b                   	pop    %ebx
f0100338:	5d                   	pop    %ebp
f0100339:	c3                   	ret    

f010033a <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010033a:	55                   	push   %ebp
f010033b:	89 e5                	mov    %esp,%ebp
f010033d:	57                   	push   %edi
f010033e:	56                   	push   %esi
f010033f:	53                   	push   %ebx
f0100340:	83 ec 2c             	sub    $0x2c,%esp
f0100343:	89 c7                	mov    %eax,%edi
f0100345:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010034a:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010034b:	a8 20                	test   $0x20,%al
f010034d:	75 1b                	jne    f010036a <cons_putc+0x30>
f010034f:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100354:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f0100359:	e8 72 ff ff ff       	call   f01002d0 <delay>
f010035e:	89 f2                	mov    %esi,%edx
f0100360:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100361:	a8 20                	test   $0x20,%al
f0100363:	75 05                	jne    f010036a <cons_putc+0x30>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100365:	83 eb 01             	sub    $0x1,%ebx
f0100368:	75 ef                	jne    f0100359 <cons_putc+0x1f>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f010036a:	89 f8                	mov    %edi,%eax
f010036c:	25 ff 00 00 00       	and    $0xff,%eax
f0100371:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100374:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100379:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010037a:	b2 79                	mov    $0x79,%dl
f010037c:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010037d:	84 c0                	test   %al,%al
f010037f:	78 1b                	js     f010039c <cons_putc+0x62>
f0100381:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100386:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f010038b:	e8 40 ff ff ff       	call   f01002d0 <delay>
f0100390:	89 f2                	mov    %esi,%edx
f0100392:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100393:	84 c0                	test   %al,%al
f0100395:	78 05                	js     f010039c <cons_putc+0x62>
f0100397:	83 eb 01             	sub    $0x1,%ebx
f010039a:	75 ef                	jne    f010038b <cons_putc+0x51>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010039c:	ba 78 03 00 00       	mov    $0x378,%edx
f01003a1:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f01003a5:	ee                   	out    %al,(%dx)
f01003a6:	b2 7a                	mov    $0x7a,%dl
f01003a8:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003ad:	ee                   	out    %al,(%dx)
f01003ae:	b8 08 00 00 00       	mov    $0x8,%eax
f01003b3:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01003b4:	89 fa                	mov    %edi,%edx
f01003b6:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01003bc:	89 f8                	mov    %edi,%eax
f01003be:	80 cc 07             	or     $0x7,%ah
f01003c1:	85 d2                	test   %edx,%edx
f01003c3:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01003c6:	89 f8                	mov    %edi,%eax
f01003c8:	25 ff 00 00 00       	and    $0xff,%eax
f01003cd:	83 f8 09             	cmp    $0x9,%eax
f01003d0:	74 77                	je     f0100449 <cons_putc+0x10f>
f01003d2:	83 f8 09             	cmp    $0x9,%eax
f01003d5:	7f 0b                	jg     f01003e2 <cons_putc+0xa8>
f01003d7:	83 f8 08             	cmp    $0x8,%eax
f01003da:	0f 85 9d 00 00 00    	jne    f010047d <cons_putc+0x143>
f01003e0:	eb 10                	jmp    f01003f2 <cons_putc+0xb8>
f01003e2:	83 f8 0a             	cmp    $0xa,%eax
f01003e5:	74 3c                	je     f0100423 <cons_putc+0xe9>
f01003e7:	83 f8 0d             	cmp    $0xd,%eax
f01003ea:	0f 85 8d 00 00 00    	jne    f010047d <cons_putc+0x143>
f01003f0:	eb 39                	jmp    f010042b <cons_putc+0xf1>
	case '\b':
		if (crt_pos > 0) {
f01003f2:	0f b7 05 34 b2 22 f0 	movzwl 0xf022b234,%eax
f01003f9:	66 85 c0             	test   %ax,%ax
f01003fc:	0f 84 e5 00 00 00    	je     f01004e7 <cons_putc+0x1ad>
			crt_pos--;
f0100402:	83 e8 01             	sub    $0x1,%eax
f0100405:	66 a3 34 b2 22 f0    	mov    %ax,0xf022b234
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010040b:	0f b7 c0             	movzwl %ax,%eax
f010040e:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f0100414:	83 cf 20             	or     $0x20,%edi
f0100417:	8b 15 30 b2 22 f0    	mov    0xf022b230,%edx
f010041d:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100421:	eb 77                	jmp    f010049a <cons_putc+0x160>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100423:	66 83 05 34 b2 22 f0 	addw   $0x50,0xf022b234
f010042a:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010042b:	0f b7 05 34 b2 22 f0 	movzwl 0xf022b234,%eax
f0100432:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100438:	c1 e8 16             	shr    $0x16,%eax
f010043b:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010043e:	c1 e0 04             	shl    $0x4,%eax
f0100441:	66 a3 34 b2 22 f0    	mov    %ax,0xf022b234
f0100447:	eb 51                	jmp    f010049a <cons_putc+0x160>
		break;
	case '\t':
		cons_putc(' ');
f0100449:	b8 20 00 00 00       	mov    $0x20,%eax
f010044e:	e8 e7 fe ff ff       	call   f010033a <cons_putc>
		cons_putc(' ');
f0100453:	b8 20 00 00 00       	mov    $0x20,%eax
f0100458:	e8 dd fe ff ff       	call   f010033a <cons_putc>
		cons_putc(' ');
f010045d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100462:	e8 d3 fe ff ff       	call   f010033a <cons_putc>
		cons_putc(' ');
f0100467:	b8 20 00 00 00       	mov    $0x20,%eax
f010046c:	e8 c9 fe ff ff       	call   f010033a <cons_putc>
		cons_putc(' ');
f0100471:	b8 20 00 00 00       	mov    $0x20,%eax
f0100476:	e8 bf fe ff ff       	call   f010033a <cons_putc>
f010047b:	eb 1d                	jmp    f010049a <cons_putc+0x160>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010047d:	0f b7 05 34 b2 22 f0 	movzwl 0xf022b234,%eax
f0100484:	0f b7 c8             	movzwl %ax,%ecx
f0100487:	8b 15 30 b2 22 f0    	mov    0xf022b230,%edx
f010048d:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f0100491:	83 c0 01             	add    $0x1,%eax
f0100494:	66 a3 34 b2 22 f0    	mov    %ax,0xf022b234
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010049a:	66 81 3d 34 b2 22 f0 	cmpw   $0x7cf,0xf022b234
f01004a1:	cf 07 
f01004a3:	76 42                	jbe    f01004e7 <cons_putc+0x1ad>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004a5:	a1 30 b2 22 f0       	mov    0xf022b230,%eax
f01004aa:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01004b1:	00 
f01004b2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004b8:	89 54 24 04          	mov    %edx,0x4(%esp)
f01004bc:	89 04 24             	mov    %eax,(%esp)
f01004bf:	e8 9f 61 00 00       	call   f0106663 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004c4:	8b 15 30 b2 22 f0    	mov    0xf022b230,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004ca:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01004cf:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004d5:	83 c0 01             	add    $0x1,%eax
f01004d8:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01004dd:	75 f0                	jne    f01004cf <cons_putc+0x195>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004df:	66 83 2d 34 b2 22 f0 	subw   $0x50,0xf022b234
f01004e6:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004e7:	8b 0d 2c b2 22 f0    	mov    0xf022b22c,%ecx
f01004ed:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004f2:	89 ca                	mov    %ecx,%edx
f01004f4:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004f5:	0f b7 1d 34 b2 22 f0 	movzwl 0xf022b234,%ebx
f01004fc:	8d 71 01             	lea    0x1(%ecx),%esi
f01004ff:	89 d8                	mov    %ebx,%eax
f0100501:	66 c1 e8 08          	shr    $0x8,%ax
f0100505:	89 f2                	mov    %esi,%edx
f0100507:	ee                   	out    %al,(%dx)
f0100508:	b8 0f 00 00 00       	mov    $0xf,%eax
f010050d:	89 ca                	mov    %ecx,%edx
f010050f:	ee                   	out    %al,(%dx)
f0100510:	89 d8                	mov    %ebx,%eax
f0100512:	89 f2                	mov    %esi,%edx
f0100514:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100515:	83 c4 2c             	add    $0x2c,%esp
f0100518:	5b                   	pop    %ebx
f0100519:	5e                   	pop    %esi
f010051a:	5f                   	pop    %edi
f010051b:	5d                   	pop    %ebp
f010051c:	c3                   	ret    

f010051d <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010051d:	55                   	push   %ebp
f010051e:	89 e5                	mov    %esp,%ebp
f0100520:	53                   	push   %ebx
f0100521:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100524:	ba 64 00 00 00       	mov    $0x64,%edx
f0100529:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f010052a:	a8 01                	test   $0x1,%al
f010052c:	0f 84 e5 00 00 00    	je     f0100617 <kbd_proc_data+0xfa>
f0100532:	b2 60                	mov    $0x60,%dl
f0100534:	ec                   	in     (%dx),%al
f0100535:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100537:	3c e0                	cmp    $0xe0,%al
f0100539:	75 11                	jne    f010054c <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f010053b:	83 0d 28 b2 22 f0 40 	orl    $0x40,0xf022b228
		return 0;
f0100542:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100547:	e9 d0 00 00 00       	jmp    f010061c <kbd_proc_data+0xff>
	} else if (data & 0x80) {
f010054c:	84 c0                	test   %al,%al
f010054e:	79 37                	jns    f0100587 <kbd_proc_data+0x6a>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100550:	8b 0d 28 b2 22 f0    	mov    0xf022b228,%ecx
f0100556:	89 cb                	mov    %ecx,%ebx
f0100558:	83 e3 40             	and    $0x40,%ebx
f010055b:	83 e0 7f             	and    $0x7f,%eax
f010055e:	85 db                	test   %ebx,%ebx
f0100560:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100563:	0f b6 d2             	movzbl %dl,%edx
f0100566:	0f b6 82 20 75 10 f0 	movzbl -0xfef8ae0(%edx),%eax
f010056d:	83 c8 40             	or     $0x40,%eax
f0100570:	0f b6 c0             	movzbl %al,%eax
f0100573:	f7 d0                	not    %eax
f0100575:	21 c1                	and    %eax,%ecx
f0100577:	89 0d 28 b2 22 f0    	mov    %ecx,0xf022b228
		return 0;
f010057d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100582:	e9 95 00 00 00       	jmp    f010061c <kbd_proc_data+0xff>
	} else if (shift & E0ESC) {
f0100587:	8b 0d 28 b2 22 f0    	mov    0xf022b228,%ecx
f010058d:	f6 c1 40             	test   $0x40,%cl
f0100590:	74 0e                	je     f01005a0 <kbd_proc_data+0x83>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100592:	89 c2                	mov    %eax,%edx
f0100594:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f0100597:	83 e1 bf             	and    $0xffffffbf,%ecx
f010059a:	89 0d 28 b2 22 f0    	mov    %ecx,0xf022b228
	}

	shift |= shiftcode[data];
f01005a0:	0f b6 d2             	movzbl %dl,%edx
f01005a3:	0f b6 82 20 75 10 f0 	movzbl -0xfef8ae0(%edx),%eax
f01005aa:	0b 05 28 b2 22 f0    	or     0xf022b228,%eax
	shift ^= togglecode[data];
f01005b0:	0f b6 8a 20 76 10 f0 	movzbl -0xfef89e0(%edx),%ecx
f01005b7:	31 c8                	xor    %ecx,%eax
f01005b9:	a3 28 b2 22 f0       	mov    %eax,0xf022b228

	c = charcode[shift & (CTL | SHIFT)][data];
f01005be:	89 c1                	mov    %eax,%ecx
f01005c0:	83 e1 03             	and    $0x3,%ecx
f01005c3:	8b 0c 8d 20 77 10 f0 	mov    -0xfef88e0(,%ecx,4),%ecx
f01005ca:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01005ce:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01005d1:	a8 08                	test   $0x8,%al
f01005d3:	74 1b                	je     f01005f0 <kbd_proc_data+0xd3>
		if ('a' <= c && c <= 'z')
f01005d5:	89 da                	mov    %ebx,%edx
f01005d7:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01005da:	83 f9 19             	cmp    $0x19,%ecx
f01005dd:	77 05                	ja     f01005e4 <kbd_proc_data+0xc7>
			c += 'A' - 'a';
f01005df:	83 eb 20             	sub    $0x20,%ebx
f01005e2:	eb 0c                	jmp    f01005f0 <kbd_proc_data+0xd3>
		else if ('A' <= c && c <= 'Z')
f01005e4:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01005e7:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01005ea:	83 fa 19             	cmp    $0x19,%edx
f01005ed:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01005f0:	f7 d0                	not    %eax
f01005f2:	a8 06                	test   $0x6,%al
f01005f4:	75 26                	jne    f010061c <kbd_proc_data+0xff>
f01005f6:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01005fc:	75 1e                	jne    f010061c <kbd_proc_data+0xff>
		cprintf("Rebooting!\n");
f01005fe:	c7 04 24 e2 74 10 f0 	movl   $0xf01074e2,(%esp)
f0100605:	e8 94 40 00 00       	call   f010469e <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010060a:	ba 92 00 00 00       	mov    $0x92,%edx
f010060f:	b8 03 00 00 00       	mov    $0x3,%eax
f0100614:	ee                   	out    %al,(%dx)
f0100615:	eb 05                	jmp    f010061c <kbd_proc_data+0xff>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100617:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010061c:	89 d8                	mov    %ebx,%eax
f010061e:	83 c4 14             	add    $0x14,%esp
f0100621:	5b                   	pop    %ebx
f0100622:	5d                   	pop    %ebp
f0100623:	c3                   	ret    

f0100624 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100624:	80 3d 00 b0 22 f0 00 	cmpb   $0x0,0xf022b000
f010062b:	74 11                	je     f010063e <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010062d:	55                   	push   %ebp
f010062e:	89 e5                	mov    %esp,%ebp
f0100630:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100633:	b8 de 02 10 f0       	mov    $0xf01002de,%eax
f0100638:	e8 bd fc ff ff       	call   f01002fa <cons_intr>
}
f010063d:	c9                   	leave  
f010063e:	f3 c3                	repz ret 

f0100640 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100640:	55                   	push   %ebp
f0100641:	89 e5                	mov    %esp,%ebp
f0100643:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100646:	b8 1d 05 10 f0       	mov    $0xf010051d,%eax
f010064b:	e8 aa fc ff ff       	call   f01002fa <cons_intr>
}
f0100650:	c9                   	leave  
f0100651:	c3                   	ret    

f0100652 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100652:	55                   	push   %ebp
f0100653:	89 e5                	mov    %esp,%ebp
f0100655:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100658:	e8 c7 ff ff ff       	call   f0100624 <serial_intr>
	kbd_intr();
f010065d:	e8 de ff ff ff       	call   f0100640 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100662:	8b 15 20 b2 22 f0    	mov    0xf022b220,%edx
f0100668:	3b 15 24 b2 22 f0    	cmp    0xf022b224,%edx
f010066e:	74 20                	je     f0100690 <cons_getc+0x3e>
		c = cons.buf[cons.rpos++];
f0100670:	0f b6 82 20 b0 22 f0 	movzbl -0xfdd4fe0(%edx),%eax
f0100677:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f010067a:	81 fa 00 02 00 00    	cmp    $0x200,%edx
	serial_intr();
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
f0100680:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100685:	0f 44 d1             	cmove  %ecx,%edx
f0100688:	89 15 20 b2 22 f0    	mov    %edx,0xf022b220
f010068e:	eb 05                	jmp    f0100695 <cons_getc+0x43>
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f0100690:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100695:	c9                   	leave  
f0100696:	c3                   	ret    

f0100697 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100697:	55                   	push   %ebp
f0100698:	89 e5                	mov    %esp,%ebp
f010069a:	57                   	push   %edi
f010069b:	56                   	push   %esi
f010069c:	53                   	push   %ebx
f010069d:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01006a0:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01006a7:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006ae:	5a a5 
	if (*cp != 0xA55A) {
f01006b0:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01006b7:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006bb:	74 11                	je     f01006ce <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01006bd:	c7 05 2c b2 22 f0 b4 	movl   $0x3b4,0xf022b22c
f01006c4:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006c7:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f01006cc:	eb 16                	jmp    f01006e4 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006ce:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006d5:	c7 05 2c b2 22 f0 d4 	movl   $0x3d4,0xf022b22c
f01006dc:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006df:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006e4:	8b 0d 2c b2 22 f0    	mov    0xf022b22c,%ecx
f01006ea:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006ef:	89 ca                	mov    %ecx,%edx
f01006f1:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006f2:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006f5:	89 da                	mov    %ebx,%edx
f01006f7:	ec                   	in     (%dx),%al
f01006f8:	0f b6 f0             	movzbl %al,%esi
f01006fb:	c1 e6 08             	shl    $0x8,%esi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006fe:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100703:	89 ca                	mov    %ecx,%edx
f0100705:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100706:	89 da                	mov    %ebx,%edx
f0100708:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100709:	89 3d 30 b2 22 f0    	mov    %edi,0xf022b230

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f010070f:	0f b6 d8             	movzbl %al,%ebx
f0100712:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100714:	66 89 35 34 b2 22 f0 	mov    %si,0xf022b234

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f010071b:	e8 20 ff ff ff       	call   f0100640 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100720:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f0100727:	25 fd ff 00 00       	and    $0xfffd,%eax
f010072c:	89 04 24             	mov    %eax,(%esp)
f010072f:	e8 28 3e 00 00       	call   f010455c <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100734:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100739:	b8 00 00 00 00       	mov    $0x0,%eax
f010073e:	89 f2                	mov    %esi,%edx
f0100740:	ee                   	out    %al,(%dx)
f0100741:	b2 fb                	mov    $0xfb,%dl
f0100743:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100748:	ee                   	out    %al,(%dx)
f0100749:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f010074e:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100753:	89 da                	mov    %ebx,%edx
f0100755:	ee                   	out    %al,(%dx)
f0100756:	b2 f9                	mov    $0xf9,%dl
f0100758:	b8 00 00 00 00       	mov    $0x0,%eax
f010075d:	ee                   	out    %al,(%dx)
f010075e:	b2 fb                	mov    $0xfb,%dl
f0100760:	b8 03 00 00 00       	mov    $0x3,%eax
f0100765:	ee                   	out    %al,(%dx)
f0100766:	b2 fc                	mov    $0xfc,%dl
f0100768:	b8 00 00 00 00       	mov    $0x0,%eax
f010076d:	ee                   	out    %al,(%dx)
f010076e:	b2 f9                	mov    $0xf9,%dl
f0100770:	b8 01 00 00 00       	mov    $0x1,%eax
f0100775:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100776:	b2 fd                	mov    $0xfd,%dl
f0100778:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100779:	3c ff                	cmp    $0xff,%al
f010077b:	0f 95 c1             	setne  %cl
f010077e:	88 0d 00 b0 22 f0    	mov    %cl,0xf022b000
f0100784:	89 f2                	mov    %esi,%edx
f0100786:	ec                   	in     (%dx),%al
f0100787:	89 da                	mov    %ebx,%edx
f0100789:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010078a:	84 c9                	test   %cl,%cl
f010078c:	75 0c                	jne    f010079a <cons_init+0x103>
		cprintf("Serial port does not exist!\n");
f010078e:	c7 04 24 ee 74 10 f0 	movl   $0xf01074ee,(%esp)
f0100795:	e8 04 3f 00 00       	call   f010469e <cprintf>
}
f010079a:	83 c4 1c             	add    $0x1c,%esp
f010079d:	5b                   	pop    %ebx
f010079e:	5e                   	pop    %esi
f010079f:	5f                   	pop    %edi
f01007a0:	5d                   	pop    %ebp
f01007a1:	c3                   	ret    

f01007a2 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007a2:	55                   	push   %ebp
f01007a3:	89 e5                	mov    %esp,%ebp
f01007a5:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007a8:	8b 45 08             	mov    0x8(%ebp),%eax
f01007ab:	e8 8a fb ff ff       	call   f010033a <cons_putc>
}
f01007b0:	c9                   	leave  
f01007b1:	c3                   	ret    

f01007b2 <getchar>:

int
getchar(void)
{
f01007b2:	55                   	push   %ebp
f01007b3:	89 e5                	mov    %esp,%ebp
f01007b5:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007b8:	e8 95 fe ff ff       	call   f0100652 <cons_getc>
f01007bd:	85 c0                	test   %eax,%eax
f01007bf:	74 f7                	je     f01007b8 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007c1:	c9                   	leave  
f01007c2:	c3                   	ret    

f01007c3 <iscons>:

int
iscons(int fdnum)
{
f01007c3:	55                   	push   %ebp
f01007c4:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007c6:	b8 01 00 00 00       	mov    $0x1,%eax
f01007cb:	5d                   	pop    %ebp
f01007cc:	c3                   	ret    
f01007cd:	66 90                	xchg   %ax,%ax
f01007cf:	90                   	nop

f01007d0 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007d0:	55                   	push   %ebp
f01007d1:	89 e5                	mov    %esp,%ebp
f01007d3:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007d6:	c7 04 24 30 77 10 f0 	movl   $0xf0107730,(%esp)
f01007dd:	e8 bc 3e 00 00       	call   f010469e <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007e2:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01007e9:	00 
f01007ea:	c7 04 24 8c 78 10 f0 	movl   $0xf010788c,(%esp)
f01007f1:	e8 a8 3e 00 00       	call   f010469e <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007f6:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01007fd:	00 
f01007fe:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100805:	f0 
f0100806:	c7 04 24 b4 78 10 f0 	movl   $0xf01078b4,(%esp)
f010080d:	e8 8c 3e 00 00       	call   f010469e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100812:	c7 44 24 08 1f 74 10 	movl   $0x10741f,0x8(%esp)
f0100819:	00 
f010081a:	c7 44 24 04 1f 74 10 	movl   $0xf010741f,0x4(%esp)
f0100821:	f0 
f0100822:	c7 04 24 d8 78 10 f0 	movl   $0xf01078d8,(%esp)
f0100829:	e8 70 3e 00 00       	call   f010469e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010082e:	c7 44 24 08 0a a7 22 	movl   $0x22a70a,0x8(%esp)
f0100835:	00 
f0100836:	c7 44 24 04 0a a7 22 	movl   $0xf022a70a,0x4(%esp)
f010083d:	f0 
f010083e:	c7 04 24 fc 78 10 f0 	movl   $0xf01078fc,(%esp)
f0100845:	e8 54 3e 00 00       	call   f010469e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010084a:	c7 44 24 08 08 d0 26 	movl   $0x26d008,0x8(%esp)
f0100851:	00 
f0100852:	c7 44 24 04 08 d0 26 	movl   $0xf026d008,0x4(%esp)
f0100859:	f0 
f010085a:	c7 04 24 20 79 10 f0 	movl   $0xf0107920,(%esp)
f0100861:	e8 38 3e 00 00       	call   f010469e <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100866:	b8 07 d4 26 f0       	mov    $0xf026d407,%eax
f010086b:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100870:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100875:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010087b:	85 c0                	test   %eax,%eax
f010087d:	0f 48 c2             	cmovs  %edx,%eax
f0100880:	c1 f8 0a             	sar    $0xa,%eax
f0100883:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100887:	c7 04 24 44 79 10 f0 	movl   $0xf0107944,(%esp)
f010088e:	e8 0b 3e 00 00       	call   f010469e <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100893:	b8 00 00 00 00       	mov    $0x0,%eax
f0100898:	c9                   	leave  
f0100899:	c3                   	ret    

f010089a <mon_help>:
	return 0;
}

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010089a:	55                   	push   %ebp
f010089b:	89 e5                	mov    %esp,%ebp
f010089d:	56                   	push   %esi
f010089e:	53                   	push   %ebx
f010089f:	83 ec 10             	sub    $0x10,%esp
f01008a2:	bb 84 7a 10 f0       	mov    $0xf0107a84,%ebx
	dump_memory(start_va, end_va);
	return 0;
}

int
mon_help(int argc, char **argv, struct Trapframe *tf)
f01008a7:	be cc 7a 10 f0       	mov    $0xf0107acc,%esi
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01008ac:	8b 03                	mov    (%ebx),%eax
f01008ae:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008b2:	8b 43 fc             	mov    -0x4(%ebx),%eax
f01008b5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008b9:	c7 04 24 49 77 10 f0 	movl   $0xf0107749,(%esp)
f01008c0:	e8 d9 3d 00 00       	call   f010469e <cprintf>
f01008c5:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01008c8:	39 f3                	cmp    %esi,%ebx
f01008ca:	75 e0                	jne    f01008ac <mon_help+0x12>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01008cc:	b8 00 00 00 00       	mov    $0x0,%eax
f01008d1:	83 c4 10             	add    $0x10,%esp
f01008d4:	5b                   	pop    %ebx
f01008d5:	5e                   	pop    %esi
f01008d6:	5d                   	pop    %ebp
f01008d7:	c3                   	ret    

f01008d8 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008d8:	55                   	push   %ebp
f01008d9:	89 e5                	mov    %esp,%ebp
f01008db:	57                   	push   %edi
f01008dc:	56                   	push   %esi
f01008dd:	53                   	push   %ebx
f01008de:	83 ec 5c             	sub    $0x5c,%esp
	// Your code here.
	uint32_t eip, arg1, arg2, arg3, arg4, arg5;	
	cprintf("Stack backtrace:\n");
f01008e1:	c7 04 24 52 77 10 f0 	movl   $0xf0107752,(%esp)
f01008e8:	e8 b1 3d 00 00       	call   f010469e <cprintf>

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01008ed:	89 e8                	mov    %ebp,%eax
	uint32_t* ebp_address = (uint32_t*) read_ebp();
f01008ef:	89 c6                	mov    %eax,%esi
	int temp;
	int i = 0;
	while ((uint32_t)ebp_address != 0) {
f01008f1:	85 c0                	test   %eax,%eax
f01008f3:	0f 84 b2 00 00 00    	je     f01009ab <mon_backtrace+0xd3>
		struct Eipdebuginfo info;
		eip = *(ebp_address + 1);
f01008f9:	8b 5e 04             	mov    0x4(%esi),%ebx
		arg1 = *(ebp_address + 2);
f01008fc:	8b 46 08             	mov    0x8(%esi),%eax
f01008ff:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		arg2 = *(ebp_address + 3);
f0100902:	8b 46 0c             	mov    0xc(%esi),%eax
f0100905:	89 45 c0             	mov    %eax,-0x40(%ebp)
		arg3 = *(ebp_address + 4);
f0100908:	8b 46 10             	mov    0x10(%esi),%eax
f010090b:	89 45 bc             	mov    %eax,-0x44(%ebp)
		arg4 = *(ebp_address + 5);
f010090e:	8b 46 14             	mov    0x14(%esi),%eax
f0100911:	89 45 b8             	mov    %eax,-0x48(%ebp)
		arg5 = *(ebp_address + 6);
f0100914:	8b 7e 18             	mov    0x18(%esi),%edi
		temp = debuginfo_eip(eip, &info);
f0100917:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010091a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010091e:	89 1c 24             	mov    %ebx,(%esp)
f0100921:	e8 5c 51 00 00       	call   f0105a82 <debuginfo_eip>
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n",
f0100926:	89 7c 24 1c          	mov    %edi,0x1c(%esp)
f010092a:	8b 45 b8             	mov    -0x48(%ebp),%eax
f010092d:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100931:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0100934:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100938:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010093b:	89 44 24 10          	mov    %eax,0x10(%esp)
f010093f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100942:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100946:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010094a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010094e:	c7 04 24 70 79 10 f0 	movl   $0xf0107970,(%esp)
f0100955:	e8 44 3d 00 00       	call   f010469e <cprintf>
				(uint32_t)ebp_address, eip, arg1, arg2, arg3, arg4, arg5);
		cprintf("\t%s:%d: ", info.eip_file, info.eip_line);
f010095a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010095d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100961:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100964:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100968:	c7 04 24 64 77 10 f0 	movl   $0xf0107764,(%esp)
f010096f:	e8 2a 3d 00 00       	call   f010469e <cprintf>
		cprintf("%.*s", info.eip_fn_namelen, info.eip_fn_name);
f0100974:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100977:	89 44 24 08          	mov    %eax,0x8(%esp)
f010097b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010097e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100982:	c7 04 24 6d 77 10 f0 	movl   $0xf010776d,(%esp)
f0100989:	e8 10 3d 00 00       	call   f010469e <cprintf>
		cprintf("+%d\n", eip - info.eip_fn_addr);
f010098e:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f0100991:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100995:	c7 04 24 72 77 10 f0 	movl   $0xf0107772,(%esp)
f010099c:	e8 fd 3c 00 00       	call   f010469e <cprintf>
		
		ebp_address = (uint32_t*)(*ebp_address);
f01009a1:	8b 36                	mov    (%esi),%esi
	uint32_t eip, arg1, arg2, arg3, arg4, arg5;	
	cprintf("Stack backtrace:\n");
	uint32_t* ebp_address = (uint32_t*) read_ebp();
	int temp;
	int i = 0;
	while ((uint32_t)ebp_address != 0) {
f01009a3:	85 f6                	test   %esi,%esi
f01009a5:	0f 85 4e ff ff ff    	jne    f01008f9 <mon_backtrace+0x21>
		ebp_address = (uint32_t*)(*ebp_address);
		i++;
	}
	
	return 0;
}
f01009ab:	b8 00 00 00 00       	mov    $0x0,%eax
f01009b0:	83 c4 5c             	add    $0x5c,%esp
f01009b3:	5b                   	pop    %ebx
f01009b4:	5e                   	pop    %esi
f01009b5:	5f                   	pop    %edi
f01009b6:	5d                   	pop    %ebp
f01009b7:	c3                   	ret    

f01009b8 <mon_changeperm>:
	showmappings(start_va, end_va);
	return 0;
}

// Challenge!
int mon_changeperm(int argc, char** argv, struct Trapframe *tf) {
f01009b8:	55                   	push   %ebp
f01009b9:	89 e5                	mov    %esp,%ebp
f01009bb:	53                   	push   %ebx
f01009bc:	83 ec 14             	sub    $0x14,%esp
f01009bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if (argc != 3) {
f01009c2:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f01009c6:	74 0c                	je     f01009d4 <mon_changeperm+0x1c>
		cprintf("Invalid number of arguments\n");
f01009c8:	c7 04 24 77 77 10 f0 	movl   $0xf0107777,(%esp)
f01009cf:	e8 ca 3c 00 00       	call   f010469e <cprintf>
	}
	int va = strtol(argv[1], NULL, 0);
f01009d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01009db:	00 
f01009dc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01009e3:	00 
f01009e4:	8b 43 04             	mov    0x4(%ebx),%eax
f01009e7:	89 04 24             	mov    %eax,(%esp)
f01009ea:	e8 8d 5d 00 00       	call   f010677c <strtol>
	va = ROUNDUP(va, PGSIZE);
	int perm = 0;
	int set = 1;
	if (argv[2][0] == 'u') {
f01009ef:	8b 4b 08             	mov    0x8(%ebx),%ecx
f01009f2:	0f b6 11             	movzbl (%ecx),%edx
f01009f5:	80 fa 75             	cmp    $0x75,%dl
f01009f8:	74 35                	je     f0100a2f <mon_changeperm+0x77>
		perm = PTE_U;
		set = 1;
	} else if (argv[2][0] == 'p') {
f01009fa:	80 fa 70             	cmp    $0x70,%dl
f01009fd:	74 3c                	je     f0100a3b <mon_changeperm+0x83>
		perm = PTE_P;
		set = 1;
	} else if (argv[2][0] == 'w') {
f01009ff:	80 fa 77             	cmp    $0x77,%dl
f0100a02:	74 43                	je     f0100a47 <mon_changeperm+0x8f>
		perm = PTE_W;
		set = 1;
	} else if (argv[2][0] == 'n' && argv[2][1] == 'u') {
f0100a04:	80 fa 6e             	cmp    $0x6e,%dl
f0100a07:	75 13                	jne    f0100a1c <mon_changeperm+0x64>
f0100a09:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
f0100a0d:	80 fa 75             	cmp    $0x75,%dl
f0100a10:	74 41                	je     f0100a53 <mon_changeperm+0x9b>
		perm = ~PTE_U;
		set = 0;
	} else if (argv[2][0] == 'n' && argv[2][1] == 'w') {
f0100a12:	80 fa 77             	cmp    $0x77,%dl
f0100a15:	74 48                	je     f0100a5f <mon_changeperm+0xa7>
		perm = ~PTE_W;
		set = 0;
	} else if (argv[2][0] == 'n' && argv[2][1] == 'p') {
f0100a17:	80 fa 70             	cmp    $0x70,%dl
f0100a1a:	74 4f                	je     f0100a6b <mon_changeperm+0xb3>
		perm = ~PTE_P;
		set = 0;
	} else {
		cprintf("Invalid arguments\n");
f0100a1c:	c7 04 24 94 77 10 f0 	movl   $0xf0107794,(%esp)
f0100a23:	e8 76 3c 00 00       	call   f010469e <cprintf>
		return 1;
f0100a28:	b8 01 00 00 00       	mov    $0x1,%eax
f0100a2d:	eb 65                	jmp    f0100a94 <mon_changeperm+0xdc>
	va = ROUNDUP(va, PGSIZE);
	int perm = 0;
	int set = 1;
	if (argv[2][0] == 'u') {
		perm = PTE_U;
		set = 1;
f0100a2f:	b9 01 00 00 00       	mov    $0x1,%ecx
	int va = strtol(argv[1], NULL, 0);
	va = ROUNDUP(va, PGSIZE);
	int perm = 0;
	int set = 1;
	if (argv[2][0] == 'u') {
		perm = PTE_U;
f0100a34:	ba 04 00 00 00       	mov    $0x4,%edx
f0100a39:	eb 3a                	jmp    f0100a75 <mon_changeperm+0xbd>
		set = 1;
	} else if (argv[2][0] == 'p') {
		perm = PTE_P;
		set = 1;
f0100a3b:	b9 01 00 00 00       	mov    $0x1,%ecx
	int set = 1;
	if (argv[2][0] == 'u') {
		perm = PTE_U;
		set = 1;
	} else if (argv[2][0] == 'p') {
		perm = PTE_P;
f0100a40:	ba 01 00 00 00       	mov    $0x1,%edx
f0100a45:	eb 2e                	jmp    f0100a75 <mon_changeperm+0xbd>
		set = 1;
	} else if (argv[2][0] == 'w') {
		perm = PTE_W;
		set = 1;
f0100a47:	b9 01 00 00 00       	mov    $0x1,%ecx
		set = 1;
	} else if (argv[2][0] == 'p') {
		perm = PTE_P;
		set = 1;
	} else if (argv[2][0] == 'w') {
		perm = PTE_W;
f0100a4c:	ba 02 00 00 00       	mov    $0x2,%edx
f0100a51:	eb 22                	jmp    f0100a75 <mon_changeperm+0xbd>
		set = 1;
	} else if (argv[2][0] == 'n' && argv[2][1] == 'u') {
		perm = ~PTE_U;
		set = 0;
f0100a53:	b9 00 00 00 00       	mov    $0x0,%ecx
		set = 1;
	} else if (argv[2][0] == 'w') {
		perm = PTE_W;
		set = 1;
	} else if (argv[2][0] == 'n' && argv[2][1] == 'u') {
		perm = ~PTE_U;
f0100a58:	ba fb ff ff ff       	mov    $0xfffffffb,%edx
f0100a5d:	eb 16                	jmp    f0100a75 <mon_changeperm+0xbd>
		set = 0;
	} else if (argv[2][0] == 'n' && argv[2][1] == 'w') {
		perm = ~PTE_W;
		set = 0;
f0100a5f:	b9 00 00 00 00       	mov    $0x0,%ecx
		set = 1;
	} else if (argv[2][0] == 'n' && argv[2][1] == 'u') {
		perm = ~PTE_U;
		set = 0;
	} else if (argv[2][0] == 'n' && argv[2][1] == 'w') {
		perm = ~PTE_W;
f0100a64:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0100a69:	eb 0a                	jmp    f0100a75 <mon_changeperm+0xbd>
		set = 0;
	} else if (argv[2][0] == 'n' && argv[2][1] == 'p') {
		perm = ~PTE_P;
		set = 0;
f0100a6b:	b9 00 00 00 00       	mov    $0x0,%ecx
		set = 0;
	} else if (argv[2][0] == 'n' && argv[2][1] == 'w') {
		perm = ~PTE_W;
		set = 0;
	} else if (argv[2][0] == 'n' && argv[2][1] == 'p') {
		perm = ~PTE_P;
f0100a70:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
int mon_changeperm(int argc, char** argv, struct Trapframe *tf) {
	if (argc != 3) {
		cprintf("Invalid number of arguments\n");
	}
	int va = strtol(argv[1], NULL, 0);
	va = ROUNDUP(va, PGSIZE);
f0100a75:	05 ff 0f 00 00       	add    $0xfff,%eax
	} else {
		cprintf("Invalid arguments\n");
		return 1;
	}
	
	change_perm(va, perm, set);
f0100a7a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100a7e:	89 54 24 04          	mov    %edx,0x4(%esp)
int mon_changeperm(int argc, char** argv, struct Trapframe *tf) {
	if (argc != 3) {
		cprintf("Invalid number of arguments\n");
	}
	int va = strtol(argv[1], NULL, 0);
	va = ROUNDUP(va, PGSIZE);
f0100a82:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	} else {
		cprintf("Invalid arguments\n");
		return 1;
	}
	
	change_perm(va, perm, set);
f0100a87:	89 04 24             	mov    %eax,(%esp)
f0100a8a:	e8 10 0e 00 00       	call   f010189f <change_perm>
	return 0;
f0100a8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100a94:	83 c4 14             	add    $0x14,%esp
f0100a97:	5b                   	pop    %ebx
f0100a98:	5d                   	pop    %ebp
f0100a99:	c3                   	ret    

f0100a9a <mon_showmappings>:
};
#define NCOMMANDS (sizeof(commands)/sizeof(commands[0]))

/***** Implementations of basic kernel monitor commands *****/
// Challenge!
int mon_showmappings(int argc, char** argv, struct Trapframe *tf) {
f0100a9a:	55                   	push   %ebp
f0100a9b:	89 e5                	mov    %esp,%ebp
f0100a9d:	83 ec 18             	sub    $0x18,%esp
f0100aa0:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100aa3:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100aa6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int start_va, end_va;
	if (argc != 3) {
f0100aa9:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100aad:	74 13                	je     f0100ac2 <mon_showmappings+0x28>
		cprintf("Invalid number of arguments.\n");
f0100aaf:	c7 04 24 a7 77 10 f0 	movl   $0xf01077a7,(%esp)
f0100ab6:	e8 e3 3b 00 00       	call   f010469e <cprintf>
		return 1;
f0100abb:	b8 01 00 00 00       	mov    $0x1,%eax
f0100ac0:	eb 5f                	jmp    f0100b21 <mon_showmappings+0x87>
	}
	start_va = strtol(argv[1], NULL, 0);
f0100ac2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100ac9:	00 
f0100aca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100ad1:	00 
f0100ad2:	8b 43 04             	mov    0x4(%ebx),%eax
f0100ad5:	89 04 24             	mov    %eax,(%esp)
f0100ad8:	e8 9f 5c 00 00       	call   f010677c <strtol>
f0100add:	89 c6                	mov    %eax,%esi
	end_va = strtol(argv[2], NULL, 0);
f0100adf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100ae6:	00 
f0100ae7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100aee:	00 
f0100aef:	8b 43 08             	mov    0x8(%ebx),%eax
f0100af2:	89 04 24             	mov    %eax,(%esp)
f0100af5:	e8 82 5c 00 00       	call   f010677c <strtol>
	start_va = ROUNDUP(start_va, PGSIZE);
f0100afa:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
	end_va = ROUNDUP(end_va, PGSIZE);
f0100b00:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100b05:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	showmappings(start_va, end_va);
f0100b0a:	89 44 24 04          	mov    %eax,0x4(%esp)
		cprintf("Invalid number of arguments.\n");
		return 1;
	}
	start_va = strtol(argv[1], NULL, 0);
	end_va = strtol(argv[2], NULL, 0);
	start_va = ROUNDUP(start_va, PGSIZE);
f0100b0e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	end_va = ROUNDUP(end_va, PGSIZE);
	showmappings(start_va, end_va);
f0100b14:	89 34 24             	mov    %esi,(%esp)
f0100b17:	e8 81 0b 00 00       	call   f010169d <showmappings>
	return 0;
f0100b1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100b21:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100b24:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100b27:	89 ec                	mov    %ebp,%esp
f0100b29:	5d                   	pop    %ebp
f0100b2a:	c3                   	ret    

f0100b2b <mon_dump>:
	change_perm(va, perm, set);
	return 0;
}

// Challenge!
int mon_dump(int argc, char** argv, struct Trapframe *tf) {
f0100b2b:	55                   	push   %ebp
f0100b2c:	89 e5                	mov    %esp,%ebp
f0100b2e:	83 ec 28             	sub    $0x28,%esp
f0100b31:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0100b34:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0100b37:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0100b3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if (argc != 4) {
f0100b3d:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100b41:	74 16                	je     f0100b59 <mon_dump+0x2e>
		cprintf("Invalid number of arguments\n");
f0100b43:	c7 04 24 77 77 10 f0 	movl   $0xf0107777,(%esp)
f0100b4a:	e8 4f 3b 00 00       	call   f010469e <cprintf>
		return 1;
f0100b4f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100b54:	e9 3a 01 00 00       	jmp    f0100c93 <mon_dump+0x168>
	}
	int start_va = strtol(argv[1], NULL, 0);
f0100b59:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100b60:	00 
f0100b61:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100b68:	00 
f0100b69:	8b 43 04             	mov    0x4(%ebx),%eax
f0100b6c:	89 04 24             	mov    %eax,(%esp)
f0100b6f:	e8 08 5c 00 00       	call   f010677c <strtol>
f0100b74:	89 c7                	mov    %eax,%edi
	int end_va = strtol(argv[2], NULL, 0);
f0100b76:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100b7d:	00 
f0100b7e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100b85:	00 
f0100b86:	8b 43 08             	mov    0x8(%ebx),%eax
f0100b89:	89 04 24             	mov    %eax,(%esp)
f0100b8c:	e8 eb 5b 00 00       	call   f010677c <strtol>
	int i = 0;
	if (argv[3][0] == 'p') {
f0100b91:	8b 53 0c             	mov    0xc(%ebx),%edx
f0100b94:	0f b6 12             	movzbl (%edx),%edx
f0100b97:	80 fa 70             	cmp    $0x70,%dl
f0100b9a:	0f 85 b7 00 00 00    	jne    f0100c57 <mon_dump+0x12c>
		if (start_va > 0xffffffff - KERNBASE ||
f0100ba0:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
f0100ba5:	77 08                	ja     f0100baf <mon_dump+0x84>
f0100ba7:	81 ff ff ff ff 0f    	cmp    $0xfffffff,%edi
f0100bad:	76 16                	jbe    f0100bc5 <mon_dump+0x9a>
			end_va > 0xffffffff - KERNBASE) {
			cprintf("Invalid arguments\n");
f0100baf:	c7 04 24 94 77 10 f0 	movl   $0xf0107794,(%esp)
f0100bb6:	e8 e3 3a 00 00       	call   f010469e <cprintf>
			return 1;
f0100bbb:	b8 01 00 00 00       	mov    $0x1,%eax
f0100bc0:	e9 ce 00 00 00       	jmp    f0100c93 <mon_dump+0x168>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bc5:	8b 15 88 be 22 f0    	mov    0xf022be88,%edx
f0100bcb:	89 f9                	mov    %edi,%ecx
f0100bcd:	c1 e9 0c             	shr    $0xc,%ecx
f0100bd0:	39 d1                	cmp    %edx,%ecx
f0100bd2:	72 20                	jb     f0100bf4 <mon_dump+0xc9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bd4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0100bd8:	c7 44 24 08 68 74 10 	movl   $0xf0107468,0x8(%esp)
f0100bdf:	f0 
f0100be0:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
f0100be7:	00 
f0100be8:	c7 04 24 c5 77 10 f0 	movl   $0xf01077c5,(%esp)
f0100bef:	e8 4c f4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100bf4:	8d 9f 00 00 00 f0    	lea    -0x10000000(%edi),%ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bfa:	89 c1                	mov    %eax,%ecx
f0100bfc:	c1 e9 0c             	shr    $0xc,%ecx
f0100bff:	39 ca                	cmp    %ecx,%edx
f0100c01:	77 20                	ja     f0100c23 <mon_dump+0xf8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c03:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c07:	c7 44 24 08 68 74 10 	movl   $0xf0107468,0x8(%esp)
f0100c0e:	f0 
f0100c0f:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
f0100c16:	00 
f0100c17:	c7 04 24 c5 77 10 f0 	movl   $0xf01077c5,(%esp)
f0100c1e:	e8 1d f4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100c23:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
		}
		start_va = (int)KADDR(start_va);
		end_va = (int)KADDR(end_va);	
		for (i = start_va; i <= end_va; i += 4) {
f0100c29:	39 f3                	cmp    %esi,%ebx
f0100c2b:	7f 61                	jg     f0100c8e <mon_dump+0x163>
			cprintf("0x%x: 0x%x\n", i - KERNBASE, *((int*)i));
f0100c2d:	8b 03                	mov    (%ebx),%eax
f0100c2f:	89 44 24 08          	mov    %eax,0x8(%esp)
	change_perm(va, perm, set);
	return 0;
}

// Challenge!
int mon_dump(int argc, char** argv, struct Trapframe *tf) {
f0100c33:	8d 93 00 00 00 10    	lea    0x10000000(%ebx),%edx
			return 1;
		}
		start_va = (int)KADDR(start_va);
		end_va = (int)KADDR(end_va);	
		for (i = start_va; i <= end_va; i += 4) {
			cprintf("0x%x: 0x%x\n", i - KERNBASE, *((int*)i));
f0100c39:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100c3d:	c7 04 24 d4 77 10 f0 	movl   $0xf01077d4,(%esp)
f0100c44:	e8 55 3a 00 00       	call   f010469e <cprintf>
			cprintf("Invalid arguments\n");
			return 1;
		}
		start_va = (int)KADDR(start_va);
		end_va = (int)KADDR(end_va);	
		for (i = start_va; i <= end_va; i += 4) {
f0100c49:	83 c3 04             	add    $0x4,%ebx
f0100c4c:	39 de                	cmp    %ebx,%esi
f0100c4e:	7d dd                	jge    f0100c2d <mon_dump+0x102>
			cprintf("0x%x: 0x%x\n", i - KERNBASE, *((int*)i));
		}
		return 0;
f0100c50:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c55:	eb 3c                	jmp    f0100c93 <mon_dump+0x168>
	} else if (argv[3][0] != 'v') {
f0100c57:	80 fa 76             	cmp    $0x76,%dl
f0100c5a:	74 13                	je     f0100c6f <mon_dump+0x144>
		cprintf("Invalid arguments\n");
f0100c5c:	c7 04 24 94 77 10 f0 	movl   $0xf0107794,(%esp)
f0100c63:	e8 36 3a 00 00       	call   f010469e <cprintf>
		return -1;
f0100c68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c6d:	eb 24                	jmp    f0100c93 <mon_dump+0x168>
	}

	start_va = ROUNDUP(start_va, 4);
f0100c6f:	83 c7 03             	add    $0x3,%edi
	end_va = ROUNDUP(end_va, 4);
f0100c72:	83 c0 03             	add    $0x3,%eax
f0100c75:	83 e0 fc             	and    $0xfffffffc,%eax

	dump_memory(start_va, end_va);
f0100c78:	89 44 24 04          	mov    %eax,0x4(%esp)
	} else if (argv[3][0] != 'v') {
		cprintf("Invalid arguments\n");
		return -1;
	}

	start_va = ROUNDUP(start_va, 4);
f0100c7c:	83 e7 fc             	and    $0xfffffffc,%edi
	end_va = ROUNDUP(end_va, 4);

	dump_memory(start_va, end_va);
f0100c7f:	89 3c 24             	mov    %edi,(%esp)
f0100c82:	e8 4c 09 00 00       	call   f01015d3 <dump_memory>
	return 0;
f0100c87:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c8c:	eb 05                	jmp    f0100c93 <mon_dump+0x168>
		start_va = (int)KADDR(start_va);
		end_va = (int)KADDR(end_va);	
		for (i = start_va; i <= end_va; i += 4) {
			cprintf("0x%x: 0x%x\n", i - KERNBASE, *((int*)i));
		}
		return 0;
f0100c8e:	b8 00 00 00 00       	mov    $0x0,%eax
	start_va = ROUNDUP(start_va, 4);
	end_va = ROUNDUP(end_va, 4);

	dump_memory(start_va, end_va);
	return 0;
}
f0100c93:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0100c96:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0100c99:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0100c9c:	89 ec                	mov    %ebp,%esp
f0100c9e:	5d                   	pop    %ebp
f0100c9f:	c3                   	ret    

f0100ca0 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100ca0:	55                   	push   %ebp
f0100ca1:	89 e5                	mov    %esp,%ebp
f0100ca3:	57                   	push   %edi
f0100ca4:	56                   	push   %esi
f0100ca5:	53                   	push   %ebx
f0100ca6:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100ca9:	c7 04 24 a4 79 10 f0 	movl   $0xf01079a4,(%esp)
f0100cb0:	e8 e9 39 00 00       	call   f010469e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100cb5:	c7 04 24 c8 79 10 f0 	movl   $0xf01079c8,(%esp)
f0100cbc:	e8 dd 39 00 00       	call   f010469e <cprintf>

	if (tf != NULL)
f0100cc1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100cc5:	74 0b                	je     f0100cd2 <monitor+0x32>
		print_trapframe(tf);
f0100cc7:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cca:	89 04 24             	mov    %eax,(%esp)
f0100ccd:	e8 34 3c 00 00       	call   f0104906 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100cd2:	c7 04 24 e0 77 10 f0 	movl   $0xf01077e0,(%esp)
f0100cd9:	e8 52 56 00 00       	call   f0106330 <readline>
f0100cde:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f0100ce0:	85 c0                	test   %eax,%eax
f0100ce2:	74 ee                	je     f0100cd2 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100ce4:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100ceb:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100cf0:	eb 06                	jmp    f0100cf8 <monitor+0x58>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100cf2:	c6 06 00             	movb   $0x0,(%esi)
f0100cf5:	83 c6 01             	add    $0x1,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100cf8:	0f b6 06             	movzbl (%esi),%eax
f0100cfb:	84 c0                	test   %al,%al
f0100cfd:	74 6c                	je     f0100d6b <monitor+0xcb>
f0100cff:	0f be c0             	movsbl %al,%eax
f0100d02:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d06:	c7 04 24 e4 77 10 f0 	movl   $0xf01077e4,(%esp)
f0100d0d:	e8 93 58 00 00       	call   f01065a5 <strchr>
f0100d12:	85 c0                	test   %eax,%eax
f0100d14:	75 dc                	jne    f0100cf2 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100d16:	80 3e 00             	cmpb   $0x0,(%esi)
f0100d19:	74 50                	je     f0100d6b <monitor+0xcb>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100d1b:	83 fb 0f             	cmp    $0xf,%ebx
f0100d1e:	66 90                	xchg   %ax,%ax
f0100d20:	75 16                	jne    f0100d38 <monitor+0x98>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100d22:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100d29:	00 
f0100d2a:	c7 04 24 e9 77 10 f0 	movl   $0xf01077e9,(%esp)
f0100d31:	e8 68 39 00 00       	call   f010469e <cprintf>
f0100d36:	eb 9a                	jmp    f0100cd2 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100d38:	89 74 9d a8          	mov    %esi,-0x58(%ebp,%ebx,4)
f0100d3c:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100d3f:	0f b6 06             	movzbl (%esi),%eax
f0100d42:	84 c0                	test   %al,%al
f0100d44:	75 0c                	jne    f0100d52 <monitor+0xb2>
f0100d46:	eb b0                	jmp    f0100cf8 <monitor+0x58>
			buf++;
f0100d48:	83 c6 01             	add    $0x1,%esi
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100d4b:	0f b6 06             	movzbl (%esi),%eax
f0100d4e:	84 c0                	test   %al,%al
f0100d50:	74 a6                	je     f0100cf8 <monitor+0x58>
f0100d52:	0f be c0             	movsbl %al,%eax
f0100d55:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d59:	c7 04 24 e4 77 10 f0 	movl   $0xf01077e4,(%esp)
f0100d60:	e8 40 58 00 00       	call   f01065a5 <strchr>
f0100d65:	85 c0                	test   %eax,%eax
f0100d67:	74 df                	je     f0100d48 <monitor+0xa8>
f0100d69:	eb 8d                	jmp    f0100cf8 <monitor+0x58>
			buf++;
	}
	argv[argc] = 0;
f0100d6b:	c7 44 9d a8 00 00 00 	movl   $0x0,-0x58(%ebp,%ebx,4)
f0100d72:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100d73:	85 db                	test   %ebx,%ebx
f0100d75:	0f 84 57 ff ff ff    	je     f0100cd2 <monitor+0x32>
f0100d7b:	bf 80 7a 10 f0       	mov    $0xf0107a80,%edi
f0100d80:	be 00 00 00 00       	mov    $0x0,%esi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100d85:	8b 07                	mov    (%edi),%eax
f0100d87:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d8b:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100d8e:	89 04 24             	mov    %eax,(%esp)
f0100d91:	e8 8b 57 00 00       	call   f0106521 <strcmp>
f0100d96:	85 c0                	test   %eax,%eax
f0100d98:	75 24                	jne    f0100dbe <monitor+0x11e>
			return commands[i].func(argc, argv, tf);
f0100d9a:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100d9d:	8b 55 08             	mov    0x8(%ebp),%edx
f0100da0:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100da4:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100da7:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100dab:	89 1c 24             	mov    %ebx,(%esp)
f0100dae:	ff 14 85 88 7a 10 f0 	call   *-0xfef8578(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100db5:	85 c0                	test   %eax,%eax
f0100db7:	78 28                	js     f0100de1 <monitor+0x141>
f0100db9:	e9 14 ff ff ff       	jmp    f0100cd2 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100dbe:	83 c6 01             	add    $0x1,%esi
f0100dc1:	83 c7 0c             	add    $0xc,%edi
f0100dc4:	83 fe 06             	cmp    $0x6,%esi
f0100dc7:	75 bc                	jne    f0100d85 <monitor+0xe5>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100dc9:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100dcc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dd0:	c7 04 24 06 78 10 f0 	movl   $0xf0107806,(%esp)
f0100dd7:	e8 c2 38 00 00       	call   f010469e <cprintf>
f0100ddc:	e9 f1 fe ff ff       	jmp    f0100cd2 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100de1:	83 c4 5c             	add    $0x5c,%esp
f0100de4:	5b                   	pop    %ebx
f0100de5:	5e                   	pop    %esi
f0100de6:	5f                   	pop    %edi
f0100de7:	5d                   	pop    %ebp
f0100de8:	c3                   	ret    
f0100de9:	66 90                	xchg   %ax,%ax
f0100deb:	66 90                	xchg   %ax,%ax
f0100ded:	66 90                	xchg   %ax,%ax
f0100def:	90                   	nop

f0100df0 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100df0:	89 d1                	mov    %edx,%ecx
f0100df2:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100df5:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100df8:	a8 01                	test   $0x1,%al
f0100dfa:	74 5d                	je     f0100e59 <check_va2pa+0x69>
		return ~0;

	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100dfc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e01:	89 c1                	mov    %eax,%ecx
f0100e03:	c1 e9 0c             	shr    $0xc,%ecx
f0100e06:	3b 0d 88 be 22 f0    	cmp    0xf022be88,%ecx
f0100e0c:	72 26                	jb     f0100e34 <check_va2pa+0x44>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100e0e:	55                   	push   %ebp
f0100e0f:	89 e5                	mov    %esp,%ebp
f0100e11:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e14:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e18:	c7 44 24 08 68 74 10 	movl   $0xf0107468,0x8(%esp)
f0100e1f:	f0 
f0100e20:	c7 44 24 04 6a 04 00 	movl   $0x46a,0x4(%esp)
f0100e27:	00 
f0100e28:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0100e2f:	e8 0c f2 ff ff       	call   f0100040 <_panic>
	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;

	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P)) {
f0100e34:	c1 ea 0c             	shr    $0xc,%edx
f0100e37:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100e3d:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100e44:	89 c2                	mov    %eax,%edx
f0100e46:	83 e2 01             	and    $0x1,%edx
		return ~0;
	}
	return PTE_ADDR(p[PTX(va)]);
f0100e49:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100e4e:	85 d2                	test   %edx,%edx
f0100e50:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100e55:	0f 44 c2             	cmove  %edx,%eax
f0100e58:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100e59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P)) {
		return ~0;
	}
	return PTE_ADDR(p[PTX(va)]);
}
f0100e5e:	c3                   	ret    

f0100e5f <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100e5f:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100e61:	83 3d 40 b2 22 f0 00 	cmpl   $0x0,0xf022b240
f0100e68:	75 0f                	jne    f0100e79 <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100e6a:	b8 07 e0 26 f0       	mov    $0xf026e007,%eax
f0100e6f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100e74:	a3 40 b2 22 f0       	mov    %eax,0xf022b240
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	
	result = nextfree;
f0100e79:	a1 40 b2 22 f0       	mov    0xf022b240,%eax

	if (n > npages * PGSIZE) {
f0100e7e:	8b 0d 88 be 22 f0    	mov    0xf022be88,%ecx
f0100e84:	c1 e1 0c             	shl    $0xc,%ecx
f0100e87:	39 d1                	cmp    %edx,%ecx
f0100e89:	73 22                	jae    f0100ead <boot_alloc+0x4e>
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100e8b:	55                   	push   %ebp
f0100e8c:	89 e5                	mov    %esp,%ebp
f0100e8e:	83 ec 18             	sub    $0x18,%esp
	// LAB 2: Your code here.
	
	result = nextfree;

	if (n > npages * PGSIZE) {
		panic("Not enough memory.\n");
f0100e91:	c7 44 24 08 99 83 10 	movl   $0xf0108399,0x8(%esp)
f0100e98:	f0 
f0100e99:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
f0100ea0:	00 
f0100ea1:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0100ea8:	e8 93 f1 ff ff       	call   f0100040 <_panic>
	} else {
		if (!(n % PGSIZE)) {
f0100ead:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0100eb3:	75 09                	jne    f0100ebe <boot_alloc+0x5f>
			nextfree = nextfree + n;
f0100eb5:	01 c2                	add    %eax,%edx
f0100eb7:	89 15 40 b2 22 f0    	mov    %edx,0xf022b240
f0100ebd:	c3                   	ret    
		} else {
			nextfree = nextfree + ((n / PGSIZE) + 1) * PGSIZE;
f0100ebe:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ec4:	8d 94 10 00 10 00 00 	lea    0x1000(%eax,%edx,1),%edx
f0100ecb:	89 15 40 b2 22 f0    	mov    %edx,0xf022b240
		}
	}
	return (void*)result;
}
f0100ed1:	c3                   	ret    

f0100ed2 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100ed2:	55                   	push   %ebp
f0100ed3:	89 e5                	mov    %esp,%ebp
f0100ed5:	83 ec 18             	sub    $0x18,%esp
f0100ed8:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100edb:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100ede:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100ee0:	89 04 24             	mov    %eax,(%esp)
f0100ee3:	e8 48 36 00 00       	call   f0104530 <mc146818_read>
f0100ee8:	89 c6                	mov    %eax,%esi
f0100eea:	83 c3 01             	add    $0x1,%ebx
f0100eed:	89 1c 24             	mov    %ebx,(%esp)
f0100ef0:	e8 3b 36 00 00       	call   f0104530 <mc146818_read>
f0100ef5:	c1 e0 08             	shl    $0x8,%eax
f0100ef8:	09 f0                	or     %esi,%eax
}
f0100efa:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100efd:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100f00:	89 ec                	mov    %ebp,%esp
f0100f02:	5d                   	pop    %ebp
f0100f03:	c3                   	ret    

f0100f04 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100f04:	55                   	push   %ebp
f0100f05:	89 e5                	mov    %esp,%ebp
f0100f07:	57                   	push   %edi
f0100f08:	56                   	push   %esi
f0100f09:	53                   	push   %ebx
f0100f0a:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f0d:	84 c0                	test   %al,%al
f0100f0f:	0f 85 71 03 00 00    	jne    f0101286 <check_page_free_list+0x382>
f0100f15:	e9 7e 03 00 00       	jmp    f0101298 <check_page_free_list+0x394>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100f1a:	c7 44 24 08 c8 7a 10 	movl   $0xf0107ac8,0x8(%esp)
f0100f21:	f0 
f0100f22:	c7 44 24 04 8c 03 00 	movl   $0x38c,0x4(%esp)
f0100f29:	00 
f0100f2a:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0100f31:	e8 0a f1 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100f36:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100f39:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100f3c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100f3f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f42:	89 c2                	mov    %eax,%edx
f0100f44:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100f4a:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100f50:	0f 95 c2             	setne  %dl
f0100f53:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100f56:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100f5a:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100f5c:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f60:	8b 00                	mov    (%eax),%eax
f0100f62:	85 c0                	test   %eax,%eax
f0100f64:	75 dc                	jne    f0100f42 <check_page_free_list+0x3e>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100f66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f69:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100f6f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f72:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100f75:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100f77:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100f7a:	a3 44 b2 22 f0       	mov    %eax,0xf022b244
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100f7f:	89 c3                	mov    %eax,%ebx
f0100f81:	85 c0                	test   %eax,%eax
f0100f83:	74 6c                	je     f0100ff1 <check_page_free_list+0xed>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f85:	be 01 00 00 00       	mov    $0x1,%esi
f0100f8a:	89 d8                	mov    %ebx,%eax
f0100f8c:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0100f92:	c1 f8 03             	sar    $0x3,%eax
f0100f95:	c1 e0 0c             	shl    $0xc,%eax
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
f0100f98:	89 c2                	mov    %eax,%edx
f0100f9a:	c1 ea 16             	shr    $0x16,%edx
f0100f9d:	39 f2                	cmp    %esi,%edx
f0100f9f:	73 4a                	jae    f0100feb <check_page_free_list+0xe7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fa1:	89 c2                	mov    %eax,%edx
f0100fa3:	c1 ea 0c             	shr    $0xc,%edx
f0100fa6:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0100fac:	72 20                	jb     f0100fce <check_page_free_list+0xca>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fae:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fb2:	c7 44 24 08 68 74 10 	movl   $0xf0107468,0x8(%esp)
f0100fb9:	f0 
f0100fba:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
f0100fc1:	00 
f0100fc2:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f0100fc9:	e8 72 f0 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100fce:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100fd5:	00 
f0100fd6:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100fdd:	00 
	return (void *)(pa + KERNBASE);
f0100fde:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fe3:	89 04 24             	mov    %eax,(%esp)
f0100fe6:	e8 1a 56 00 00       	call   f0106605 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100feb:	8b 1b                	mov    (%ebx),%ebx
f0100fed:	85 db                	test   %ebx,%ebx
f0100fef:	75 99                	jne    f0100f8a <check_page_free_list+0x86>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100ff1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ff6:	e8 64 fe ff ff       	call   f0100e5f <boot_alloc>
f0100ffb:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ffe:	8b 15 44 b2 22 f0    	mov    0xf022b244,%edx
f0101004:	85 d2                	test   %edx,%edx
f0101006:	0f 84 2e 02 00 00    	je     f010123a <check_page_free_list+0x336>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010100c:	8b 3d 90 be 22 f0    	mov    0xf022be90,%edi
f0101012:	39 fa                	cmp    %edi,%edx
f0101014:	72 51                	jb     f0101067 <check_page_free_list+0x163>
		assert(pp < pages + npages);
f0101016:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f010101b:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010101e:	8d 04 c7             	lea    (%edi,%eax,8),%eax
f0101021:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101024:	39 c2                	cmp    %eax,%edx
f0101026:	73 68                	jae    f0101090 <check_page_free_list+0x18c>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101028:	89 7d d0             	mov    %edi,-0x30(%ebp)
f010102b:	89 d0                	mov    %edx,%eax
f010102d:	29 f8                	sub    %edi,%eax
f010102f:	a8 07                	test   $0x7,%al
f0101031:	0f 85 86 00 00 00    	jne    f01010bd <check_page_free_list+0x1b9>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101037:	c1 f8 03             	sar    $0x3,%eax
f010103a:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f010103d:	85 c0                	test   %eax,%eax
f010103f:	0f 84 a6 00 00 00    	je     f01010eb <check_page_free_list+0x1e7>
		assert(page2pa(pp) != IOPHYSMEM);
f0101045:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010104a:	0f 84 c6 00 00 00    	je     f0101116 <check_page_free_list+0x212>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0101050:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101055:	be 00 00 00 00       	mov    $0x0,%esi
f010105a:	89 7d c0             	mov    %edi,-0x40(%ebp)
f010105d:	e9 d8 00 00 00       	jmp    f010113a <check_page_free_list+0x236>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101062:	3b 55 c0             	cmp    -0x40(%ebp),%edx
f0101065:	73 24                	jae    f010108b <check_page_free_list+0x187>
f0101067:	c7 44 24 0c bb 83 10 	movl   $0xf01083bb,0xc(%esp)
f010106e:	f0 
f010106f:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101076:	f0 
f0101077:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f010107e:	00 
f010107f:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0101086:	e8 b5 ef ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f010108b:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f010108e:	72 24                	jb     f01010b4 <check_page_free_list+0x1b0>
f0101090:	c7 44 24 0c dc 83 10 	movl   $0xf01083dc,0xc(%esp)
f0101097:	f0 
f0101098:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010109f:	f0 
f01010a0:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f01010a7:	00 
f01010a8:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01010af:	e8 8c ef ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01010b4:	89 d0                	mov    %edx,%eax
f01010b6:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01010b9:	a8 07                	test   $0x7,%al
f01010bb:	74 24                	je     f01010e1 <check_page_free_list+0x1dd>
f01010bd:	c7 44 24 0c ec 7a 10 	movl   $0xf0107aec,0xc(%esp)
f01010c4:	f0 
f01010c5:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01010cc:	f0 
f01010cd:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
f01010d4:	00 
f01010d5:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01010dc:	e8 5f ef ff ff       	call   f0100040 <_panic>
f01010e1:	c1 f8 03             	sar    $0x3,%eax
f01010e4:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01010e7:	85 c0                	test   %eax,%eax
f01010e9:	75 24                	jne    f010110f <check_page_free_list+0x20b>
f01010eb:	c7 44 24 0c f0 83 10 	movl   $0xf01083f0,0xc(%esp)
f01010f2:	f0 
f01010f3:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01010fa:	f0 
f01010fb:	c7 44 24 04 ab 03 00 	movl   $0x3ab,0x4(%esp)
f0101102:	00 
f0101103:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f010110a:	e8 31 ef ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f010110f:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101114:	75 24                	jne    f010113a <check_page_free_list+0x236>
f0101116:	c7 44 24 0c 01 84 10 	movl   $0xf0108401,0xc(%esp)
f010111d:	f0 
f010111e:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101125:	f0 
f0101126:	c7 44 24 04 ac 03 00 	movl   $0x3ac,0x4(%esp)
f010112d:	00 
f010112e:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0101135:	e8 06 ef ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010113a:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f010113f:	75 24                	jne    f0101165 <check_page_free_list+0x261>
f0101141:	c7 44 24 0c 20 7b 10 	movl   $0xf0107b20,0xc(%esp)
f0101148:	f0 
f0101149:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101150:	f0 
f0101151:	c7 44 24 04 ad 03 00 	movl   $0x3ad,0x4(%esp)
f0101158:	00 
f0101159:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0101160:	e8 db ee ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101165:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010116a:	75 24                	jne    f0101190 <check_page_free_list+0x28c>
f010116c:	c7 44 24 0c 1a 84 10 	movl   $0xf010841a,0xc(%esp)
f0101173:	f0 
f0101174:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010117b:	f0 
f010117c:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f0101183:	00 
f0101184:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f010118b:	e8 b0 ee ff ff       	call   f0100040 <_panic>
f0101190:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101192:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101197:	0f 86 09 01 00 00    	jbe    f01012a6 <check_page_free_list+0x3a2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010119d:	89 c7                	mov    %eax,%edi
f010119f:	c1 ef 0c             	shr    $0xc,%edi
f01011a2:	89 7d cc             	mov    %edi,-0x34(%ebp)
f01011a5:	8b 7d c8             	mov    -0x38(%ebp),%edi
f01011a8:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f01011ab:	72 20                	jb     f01011cd <check_page_free_list+0x2c9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011b1:	c7 44 24 08 68 74 10 	movl   $0xf0107468,0x8(%esp)
f01011b8:	f0 
f01011b9:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
f01011c0:	00 
f01011c1:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f01011c8:	e8 73 ee ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01011cd:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f01011d3:	39 4d c4             	cmp    %ecx,-0x3c(%ebp)
f01011d6:	0f 86 da 00 00 00    	jbe    f01012b6 <check_page_free_list+0x3b2>
f01011dc:	c7 44 24 0c 44 7b 10 	movl   $0xf0107b44,0xc(%esp)
f01011e3:	f0 
f01011e4:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01011eb:	f0 
f01011ec:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f01011f3:	00 
f01011f4:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01011fb:	e8 40 ee ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101200:	c7 44 24 0c 34 84 10 	movl   $0xf0108434,0xc(%esp)
f0101207:	f0 
f0101208:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010120f:	f0 
f0101210:	c7 44 24 04 b1 03 00 	movl   $0x3b1,0x4(%esp)
f0101217:	00 
f0101218:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f010121f:	e8 1c ee ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0101224:	83 c6 01             	add    $0x1,%esi
f0101227:	eb 03                	jmp    f010122c <check_page_free_list+0x328>
		else
			++nfree_extmem;
f0101229:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010122c:	8b 12                	mov    (%edx),%edx
f010122e:	85 d2                	test   %edx,%edx
f0101230:	0f 85 2c fe ff ff    	jne    f0101062 <check_page_free_list+0x15e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0101236:	85 f6                	test   %esi,%esi
f0101238:	7f 24                	jg     f010125e <check_page_free_list+0x35a>
f010123a:	c7 44 24 0c 51 84 10 	movl   $0xf0108451,0xc(%esp)
f0101241:	f0 
f0101242:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101249:	f0 
f010124a:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f0101251:	00 
f0101252:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0101259:	e8 e2 ed ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f010125e:	85 db                	test   %ebx,%ebx
f0101260:	7f 74                	jg     f01012d6 <check_page_free_list+0x3d2>
f0101262:	c7 44 24 0c 63 84 10 	movl   $0xf0108463,0xc(%esp)
f0101269:	f0 
f010126a:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101271:	f0 
f0101272:	c7 44 24 04 ba 03 00 	movl   $0x3ba,0x4(%esp)
f0101279:	00 
f010127a:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0101281:	e8 ba ed ff ff       	call   f0100040 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0101286:	a1 44 b2 22 f0       	mov    0xf022b244,%eax
f010128b:	85 c0                	test   %eax,%eax
f010128d:	0f 85 a3 fc ff ff    	jne    f0100f36 <check_page_free_list+0x32>
f0101293:	e9 82 fc ff ff       	jmp    f0100f1a <check_page_free_list+0x16>
f0101298:	83 3d 44 b2 22 f0 00 	cmpl   $0x0,0xf022b244
f010129f:	75 25                	jne    f01012c6 <check_page_free_list+0x3c2>
f01012a1:	e9 74 fc ff ff       	jmp    f0100f1a <check_page_free_list+0x16>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f01012a6:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01012ab:	0f 85 73 ff ff ff    	jne    f0101224 <check_page_free_list+0x320>
f01012b1:	e9 4a ff ff ff       	jmp    f0101200 <check_page_free_list+0x2fc>
f01012b6:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01012bb:	0f 85 68 ff ff ff    	jne    f0101229 <check_page_free_list+0x325>
f01012c1:	e9 3a ff ff ff       	jmp    f0101200 <check_page_free_list+0x2fc>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01012c6:	8b 1d 44 b2 22 f0    	mov    0xf022b244,%ebx
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01012cc:	be 00 04 00 00       	mov    $0x400,%esi
f01012d1:	e9 b4 fc ff ff       	jmp    f0100f8a <check_page_free_list+0x86>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f01012d6:	83 c4 4c             	add    $0x4c,%esp
f01012d9:	5b                   	pop    %ebx
f01012da:	5e                   	pop    %esi
f01012db:	5f                   	pop    %edi
f01012dc:	5d                   	pop    %ebp
f01012dd:	c3                   	ret    

f01012de <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f01012de:	55                   	push   %ebp
f01012df:	89 e5                	mov    %esp,%ebp
f01012e1:	56                   	push   %esi
f01012e2:	53                   	push   %ebx
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;

	// 1)
	pages[0].pp_ref = 0;
f01012e3:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f01012e8:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// 2)
	page_free_list = NULL;
f01012ee:	c7 05 44 b2 22 f0 00 	movl   $0x0,0xf022b244
f01012f5:	00 00 00 
	for (i = 1; i < npages_basemem; ++i) {
f01012f8:	8b 35 3c b2 22 f0    	mov    0xf022b23c,%esi
f01012fe:	83 fe 01             	cmp    $0x1,%esi
f0101301:	76 43                	jbe    f0101346 <page_init+0x68>
f0101303:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101308:	b8 01 00 00 00       	mov    $0x1,%eax
		if (i * PGSIZE != MPENTRY_PADDR) {
f010130d:	89 c2                	mov    %eax,%edx
f010130f:	c1 e2 0c             	shl    $0xc,%edx
f0101312:	81 fa 00 70 00 00    	cmp    $0x7000,%edx
f0101318:	74 1f                	je     f0101339 <page_init+0x5b>
// After this is done, NEVER use boot_alloc again.  ONLY use the page
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
f010131a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx

	// 2)
	page_free_list = NULL;
	for (i = 1; i < npages_basemem; ++i) {
		if (i * PGSIZE != MPENTRY_PADDR) {
			pages[i].pp_ref = 0;
f0101321:	8b 0d 90 be 22 f0    	mov    0xf022be90,%ecx
f0101327:	66 c7 44 11 04 00 00 	movw   $0x0,0x4(%ecx,%edx,1)
			pages[i].pp_link = page_free_list;
f010132e:	89 1c c1             	mov    %ebx,(%ecx,%eax,8)
			page_free_list = &pages[i];
f0101331:	8b 1d 90 be 22 f0    	mov    0xf022be90,%ebx
f0101337:	01 d3                	add    %edx,%ebx
	// 1)
	pages[0].pp_ref = 0;

	// 2)
	page_free_list = NULL;
	for (i = 1; i < npages_basemem; ++i) {
f0101339:	83 c0 01             	add    $0x1,%eax
f010133c:	39 f0                	cmp    %esi,%eax
f010133e:	72 cd                	jb     f010130d <page_init+0x2f>
f0101340:	89 1d 44 b2 22 f0    	mov    %ebx,0xf022b244
	}

	// 3)
	int io_hole = (EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
	
	for (i = npages_basemem; i < npages_basemem + io_hole; ++i) {
f0101346:	8d 5e 60             	lea    0x60(%esi),%ebx
f0101349:	39 f3                	cmp    %esi,%ebx
f010134b:	76 20                	jbe    f010136d <page_init+0x8f>
		pages[i].pp_ref = 0;
f010134d:	8b 15 90 be 22 f0    	mov    0xf022be90,%edx
f0101353:	c1 e6 03             	shl    $0x3,%esi
// After this is done, NEVER use boot_alloc again.  ONLY use the page
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
f0101356:	8d 44 32 04          	lea    0x4(%edx,%esi,1),%eax
f010135a:	8d 94 32 04 03 00 00 	lea    0x304(%edx,%esi,1),%edx

	// 3)
	int io_hole = (EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
	
	for (i = npages_basemem; i < npages_basemem + io_hole; ++i) {
		pages[i].pp_ref = 0;
f0101361:	66 c7 00 00 00       	movw   $0x0,(%eax)
f0101366:	83 c0 08             	add    $0x8,%eax
	}

	// 3)
	int io_hole = (EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
	
	for (i = npages_basemem; i < npages_basemem + io_hole; ++i) {
f0101369:	39 d0                	cmp    %edx,%eax
f010136b:	75 f4                	jne    f0101361 <page_init+0x83>
		pages[i].pp_ref = 0;
	}

	struct PageInfo* temp = boot_alloc(0);
f010136d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101372:	e8 e8 fa ff ff       	call   f0100e5f <boot_alloc>
	int kern_hole = ((int)temp - (EXTPHYSMEM + KERNBASE)) / PGSIZE;
f0101377:	8d 90 00 00 f0 0f    	lea    0xff00000(%eax),%edx
f010137d:	c1 ea 0c             	shr    $0xc,%edx
	
	for (i = npages_basemem + io_hole; i < npages_basemem + io_hole
										+ kern_hole; ++i) {
f0101380:	01 da                	add    %ebx,%edx
	}

	struct PageInfo* temp = boot_alloc(0);
	int kern_hole = ((int)temp - (EXTPHYSMEM + KERNBASE)) / PGSIZE;
	
	for (i = npages_basemem + io_hole; i < npages_basemem + io_hole
f0101382:	39 da                	cmp    %ebx,%edx
f0101384:	76 13                	jbe    f0101399 <page_init+0xbb>
										+ kern_hole; ++i) {
		pages[i].pp_ref = 0;
f0101386:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f010138b:	66 c7 44 d8 04 00 00 	movw   $0x0,0x4(%eax,%ebx,8)

	struct PageInfo* temp = boot_alloc(0);
	int kern_hole = ((int)temp - (EXTPHYSMEM + KERNBASE)) / PGSIZE;
	
	for (i = npages_basemem + io_hole; i < npages_basemem + io_hole
										+ kern_hole; ++i) {
f0101392:	83 c3 01             	add    $0x1,%ebx
	}

	struct PageInfo* temp = boot_alloc(0);
	int kern_hole = ((int)temp - (EXTPHYSMEM + KERNBASE)) / PGSIZE;
	
	for (i = npages_basemem + io_hole; i < npages_basemem + io_hole
f0101395:	39 d3                	cmp    %edx,%ebx
f0101397:	75 f2                	jne    f010138b <page_init+0xad>
										+ kern_hole; ++i) {
		pages[i].pp_ref = 0;
	}

	for (i = npages_basemem + io_hole + kern_hole; i < npages; ++i) {
f0101399:	39 15 88 be 22 f0    	cmp    %edx,0xf022be88
f010139f:	76 39                	jbe    f01013da <page_init+0xfc>
f01013a1:	8b 1d 44 b2 22 f0    	mov    0xf022b244,%ebx
f01013a7:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
		pages[i].pp_ref = 0;
f01013ae:	8b 0d 90 be 22 f0    	mov    0xf022be90,%ecx
f01013b4:	66 c7 44 01 04 00 00 	movw   $0x0,0x4(%ecx,%eax,1)
		pages[i].pp_link = page_free_list;
f01013bb:	89 1c 01             	mov    %ebx,(%ecx,%eax,1)
		page_free_list = &pages[i];
f01013be:	8b 1d 90 be 22 f0    	mov    0xf022be90,%ebx
f01013c4:	01 c3                	add    %eax,%ebx
	for (i = npages_basemem + io_hole; i < npages_basemem + io_hole
										+ kern_hole; ++i) {
		pages[i].pp_ref = 0;
	}

	for (i = npages_basemem + io_hole + kern_hole; i < npages; ++i) {
f01013c6:	83 c2 01             	add    $0x1,%edx
f01013c9:	83 c0 08             	add    $0x8,%eax
f01013cc:	39 15 88 be 22 f0    	cmp    %edx,0xf022be88
f01013d2:	77 da                	ja     f01013ae <page_init+0xd0>
f01013d4:	89 1d 44 b2 22 f0    	mov    %ebx,0xf022b244
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f01013da:	5b                   	pop    %ebx
f01013db:	5e                   	pop    %esi
f01013dc:	5d                   	pop    %ebp
f01013dd:	c3                   	ret    

f01013de <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f01013de:	55                   	push   %ebp
f01013df:	89 e5                	mov    %esp,%ebp
f01013e1:	53                   	push   %ebx
f01013e2:	83 ec 14             	sub    $0x14,%esp
	if (!page_free_list) {
f01013e5:	8b 1d 44 b2 22 f0    	mov    0xf022b244,%ebx
f01013eb:	85 db                	test   %ebx,%ebx
f01013ed:	74 65                	je     f0101454 <page_alloc+0x76>
		return NULL;
	} else {
		struct PageInfo* ret_ = page_free_list;
		page_free_list = page_free_list->pp_link;
f01013ef:	8b 03                	mov    (%ebx),%eax
f01013f1:	a3 44 b2 22 f0       	mov    %eax,0xf022b244
		if (alloc_flags & ALLOC_ZERO) {
f01013f6:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01013fa:	74 58                	je     f0101454 <page_alloc+0x76>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01013fc:	89 d8                	mov    %ebx,%eax
f01013fe:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0101404:	c1 f8 03             	sar    $0x3,%eax
f0101407:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010140a:	89 c2                	mov    %eax,%edx
f010140c:	c1 ea 0c             	shr    $0xc,%edx
f010140f:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0101415:	72 20                	jb     f0101437 <page_alloc+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101417:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010141b:	c7 44 24 08 68 74 10 	movl   $0xf0107468,0x8(%esp)
f0101422:	f0 
f0101423:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
f010142a:	00 
f010142b:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f0101432:	e8 09 ec ff ff       	call   f0100040 <_panic>
			memset(page2kva(ret_), 0, PGSIZE);	
f0101437:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010143e:	00 
f010143f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101446:	00 
	return (void *)(pa + KERNBASE);
f0101447:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010144c:	89 04 24             	mov    %eax,(%esp)
f010144f:	e8 b1 51 00 00       	call   f0106605 <memset>
		}
		return ret_;
	}	

	return 0;
}
f0101454:	89 d8                	mov    %ebx,%eax
f0101456:	83 c4 14             	add    $0x14,%esp
f0101459:	5b                   	pop    %ebx
f010145a:	5d                   	pop    %ebp
f010145b:	c3                   	ret    

f010145c <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f010145c:	55                   	push   %ebp
f010145d:	89 e5                	mov    %esp,%ebp
f010145f:	8b 45 08             	mov    0x8(%ebp),%eax
	pp->pp_link = page_free_list;
f0101462:	8b 15 44 b2 22 f0    	mov    0xf022b244,%edx
f0101468:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
f010146a:	a3 44 b2 22 f0       	mov    %eax,0xf022b244
}
f010146f:	5d                   	pop    %ebp
f0101470:	c3                   	ret    

f0101471 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101471:	55                   	push   %ebp
f0101472:	89 e5                	mov    %esp,%ebp
f0101474:	83 ec 04             	sub    $0x4,%esp
f0101477:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0) {
f010147a:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f010147e:	83 ea 01             	sub    $0x1,%edx
f0101481:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101485:	66 85 d2             	test   %dx,%dx
f0101488:	75 08                	jne    f0101492 <page_decref+0x21>
		page_free(pp);
f010148a:	89 04 24             	mov    %eax,(%esp)
f010148d:	e8 ca ff ff ff       	call   f010145c <page_free>
	}
}
f0101492:	c9                   	leave  
f0101493:	c3                   	ret    

f0101494 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101494:	55                   	push   %ebp
f0101495:	89 e5                	mov    %esp,%ebp
f0101497:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f010149a:	e8 0d 58 00 00       	call   f0106cac <cpunum>
f010149f:	6b c0 74             	imul   $0x74,%eax,%eax
f01014a2:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f01014a9:	74 16                	je     f01014c1 <tlb_invalidate+0x2d>
f01014ab:	e8 fc 57 00 00       	call   f0106cac <cpunum>
f01014b0:	6b c0 74             	imul   $0x74,%eax,%eax
f01014b3:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01014b9:	8b 55 08             	mov    0x8(%ebp),%edx
f01014bc:	39 50 60             	cmp    %edx,0x60(%eax)
f01014bf:	75 06                	jne    f01014c7 <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01014c1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014c4:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01014c7:	c9                   	leave  
f01014c8:	c3                   	ret    

f01014c9 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01014c9:	55                   	push   %ebp
f01014ca:	89 e5                	mov    %esp,%ebp
f01014cc:	83 ec 28             	sub    $0x28,%esp
f01014cf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01014d2:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01014d5:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01014d8:	8b 7d 08             	mov    0x8(%ebp),%edi
f01014db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t* ptep;
	if (!(pgdir[PDX(va)] & PTE_P)) {
f01014de:	89 d8                	mov    %ebx,%eax
f01014e0:	c1 e8 16             	shr    $0x16,%eax
f01014e3:	8d 34 87             	lea    (%edi,%eax,4),%esi
f01014e6:	8b 06                	mov    (%esi),%eax
f01014e8:	a8 01                	test   $0x1,%al
f01014ea:	0f 85 86 00 00 00    	jne    f0101576 <pgdir_walk+0xad>
		if (!create) {
f01014f0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01014f4:	0f 84 c0 00 00 00    	je     f01015ba <pgdir_walk+0xf1>
			return NULL;
		} else {
			struct PageInfo* new_page = page_alloc(1);
f01014fa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101501:	e8 d8 fe ff ff       	call   f01013de <page_alloc>
			if (!new_page) {
f0101506:	85 c0                	test   %eax,%eax
f0101508:	0f 84 b3 00 00 00    	je     f01015c1 <pgdir_walk+0xf8>
				return NULL;
			} else {
				new_page->pp_ref++;
f010150e:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101513:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0101519:	c1 f8 03             	sar    $0x3,%eax
f010151c:	c1 e0 0c             	shl    $0xc,%eax
				physaddr_t new_pt_addr = (physaddr_t)page2pa(new_page);
				pgdir[PDX(va)] = (physaddr_t)new_pt_addr;

				// set the page table present bit
				pgdir[PDX(va)] = pgdir[PDX(va)] | PTE_P;
f010151f:	83 c8 01             	or     $0x1,%eax
f0101522:	89 06                	mov    %eax,(%esi)

				tlb_invalidate(pgdir, (void*)va);
f0101524:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101528:	89 3c 24             	mov    %edi,(%esp)
f010152b:	e8 64 ff ff ff       	call   f0101494 <tlb_invalidate>
				ptep = (pte_t *) KADDR(PTE_ADDR(pgdir[PDX(va)]))+PTX(va);
f0101530:	8b 06                	mov    (%esi),%eax
f0101532:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101537:	89 c2                	mov    %eax,%edx
f0101539:	c1 ea 0c             	shr    $0xc,%edx
f010153c:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0101542:	72 20                	jb     f0101564 <pgdir_walk+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101544:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101548:	c7 44 24 08 68 74 10 	movl   $0xf0107468,0x8(%esp)
f010154f:	f0 
f0101550:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
f0101557:	00 
f0101558:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f010155f:	e8 dc ea ff ff       	call   f0100040 <_panic>
f0101564:	c1 eb 0a             	shr    $0xa,%ebx
f0101567:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f010156d:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
				return (pte_t*) ptep;
f0101574:	eb 50                	jmp    f01015c6 <pgdir_walk+0xfd>
			}
		}
	} else {
		ptep = (pte_t *) KADDR(PTE_ADDR(pgdir[PDX(va)]))+PTX(va);
f0101576:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010157b:	89 c2                	mov    %eax,%edx
f010157d:	c1 ea 0c             	shr    $0xc,%edx
f0101580:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0101586:	72 20                	jb     f01015a8 <pgdir_walk+0xdf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101588:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010158c:	c7 44 24 08 68 74 10 	movl   $0xf0107468,0x8(%esp)
f0101593:	f0 
f0101594:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
f010159b:	00 
f010159c:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01015a3:	e8 98 ea ff ff       	call   f0100040 <_panic>
f01015a8:	c1 eb 0a             	shr    $0xa,%ebx
f01015ab:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f01015b1:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
		return (pte_t*) ptep;
f01015b8:	eb 0c                	jmp    f01015c6 <pgdir_walk+0xfd>
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	pte_t* ptep;
	if (!(pgdir[PDX(va)] & PTE_P)) {
		if (!create) {
			return NULL;
f01015ba:	b8 00 00 00 00       	mov    $0x0,%eax
f01015bf:	eb 05                	jmp    f01015c6 <pgdir_walk+0xfd>
		} else {
			struct PageInfo* new_page = page_alloc(1);
			if (!new_page) {
				return NULL;
f01015c1:	b8 00 00 00 00       	mov    $0x0,%eax
		ptep = (pte_t *) KADDR(PTE_ADDR(pgdir[PDX(va)]))+PTX(va);
		return (pte_t*) ptep;
	}
	
	return NULL;
}
f01015c6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01015c9:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01015cc:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01015cf:	89 ec                	mov    %ebp,%esp
f01015d1:	5d                   	pop    %ebp
f01015d2:	c3                   	ret    

f01015d3 <dump_memory>:
	*((uint32_t*)pte) = pa;
	tlb_invalidate(kern_pgdir, (void*) va);
}

// Challenge!
void dump_memory(uint32_t start_va, uint32_t end_va) {
f01015d3:	55                   	push   %ebp
f01015d4:	89 e5                	mov    %esp,%ebp
f01015d6:	57                   	push   %edi
f01015d7:	56                   	push   %esi
f01015d8:	53                   	push   %ebx
f01015d9:	83 ec 1c             	sub    $0x1c,%esp
f01015dc:	8b 45 08             	mov    0x8(%ebp),%eax
f01015df:	8b 75 0c             	mov    0xc(%ebp),%esi
	// use KADDR! entry has physical address.
	// add the offset in the page using mmu.h wala function. 
	// then dereference it . again add KADDR!
	// use the same while loop....ie, page by page
	int i;
	for(i = start_va; i <= end_va; i+= 4) {
f01015e2:	89 c3                	mov    %eax,%ebx
f01015e4:	39 f0                	cmp    %esi,%eax
f01015e6:	0f 87 a9 00 00 00    	ja     f0101695 <dump_memory+0xc2>
		uintptr_t pte = (uintptr_t)pgdir_walk(kern_pgdir, (void*)i, 0);
f01015ec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01015f3:	00 
f01015f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01015f8:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01015fd:	89 04 24             	mov    %eax,(%esp)
f0101600:	e8 c4 fe ff ff       	call   f01014c9 <pgdir_walk>
		if (!pte) {
f0101605:	85 c0                	test   %eax,%eax
f0101607:	75 1e                	jne    f0101627 <dump_memory+0x54>
			cprintf("0x%x: ", i);
f0101609:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010160d:	c7 04 24 74 84 10 f0 	movl   $0xf0108474,(%esp)
f0101614:	e8 85 30 00 00       	call   f010469e <cprintf>
			cprintf("Not mapped.\n");
f0101619:	c7 04 24 7b 84 10 f0 	movl   $0xf010847b,(%esp)
f0101620:	e8 79 30 00 00       	call   f010469e <cprintf>
			continue;
f0101625:	eb 63                	jmp    f010168a <dump_memory+0xb7>
		}
		uintptr_t page_entry = (uintptr_t)KADDR(PTE_ADDR(*((uint32_t*)pte)))
f0101627:	8b 38                	mov    (%eax),%edi
f0101629:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010162f:	89 f8                	mov    %edi,%eax
f0101631:	c1 e8 0c             	shr    $0xc,%eax
f0101634:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f010163a:	72 20                	jb     f010165c <dump_memory+0x89>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010163c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101640:	c7 44 24 08 68 74 10 	movl   $0xf0107468,0x8(%esp)
f0101647:	f0 
f0101648:	c7 44 24 04 f2 02 00 	movl   $0x2f2,0x4(%esp)
f010164f:	00 
f0101650:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0101657:	e8 e4 e9 ff ff       	call   f0100040 <_panic>
								+ PGOFF(i);
		cprintf("0x%x: ", i);
f010165c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101660:	c7 04 24 74 84 10 f0 	movl   $0xf0108474,(%esp)
f0101667:	e8 32 30 00 00       	call   f010469e <cprintf>
			cprintf("0x%x: ", i);
			cprintf("Not mapped.\n");
			continue;
		}
		uintptr_t page_entry = (uintptr_t)KADDR(PTE_ADDR(*((uint32_t*)pte)))
								+ PGOFF(i);
f010166c:	89 d8                	mov    %ebx,%eax
f010166e:	25 ff 0f 00 00       	and    $0xfff,%eax
		cprintf("0x%x: ", i);
		cprintf("0x%x\n", *((uint32_t*)page_entry));
f0101673:	8b 84 07 00 00 00 f0 	mov    -0x10000000(%edi,%eax,1),%eax
f010167a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010167e:	c7 04 24 bc 84 10 f0 	movl   $0xf01084bc,(%esp)
f0101685:	e8 14 30 00 00       	call   f010469e <cprintf>
	// use KADDR! entry has physical address.
	// add the offset in the page using mmu.h wala function. 
	// then dereference it . again add KADDR!
	// use the same while loop....ie, page by page
	int i;
	for(i = start_va; i <= end_va; i+= 4) {
f010168a:	83 c3 04             	add    $0x4,%ebx
f010168d:	39 de                	cmp    %ebx,%esi
f010168f:	0f 83 57 ff ff ff    	jae    f01015ec <dump_memory+0x19>
		uintptr_t page_entry = (uintptr_t)KADDR(PTE_ADDR(*((uint32_t*)pte)))
								+ PGOFF(i);
		cprintf("0x%x: ", i);
		cprintf("0x%x\n", *((uint32_t*)page_entry));
	}
}
f0101695:	83 c4 1c             	add    $0x1c,%esp
f0101698:	5b                   	pop    %ebx
f0101699:	5e                   	pop    %esi
f010169a:	5f                   	pop    %edi
f010169b:	5d                   	pop    %ebp
f010169c:	c3                   	ret    

f010169d <showmappings>:
		return;
	}
}

// Challenge!
void showmappings(uintptr_t start_va, uintptr_t end_va) {
f010169d:	55                   	push   %ebp
f010169e:	89 e5                	mov    %esp,%ebp
f01016a0:	57                   	push   %edi
f01016a1:	56                   	push   %esi
f01016a2:	53                   	push   %ebx
f01016a3:	83 ec 1c             	sub    $0x1c,%esp
f01016a6:	8b 75 08             	mov    0x8(%ebp),%esi
f01016a9:	8b 7d 0c             	mov    0xc(%ebp),%edi
	cprintf("%x %x\n", start_va, end_va);
f01016ac:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01016b0:	89 74 24 04          	mov    %esi,0x4(%esp)
f01016b4:	c7 04 24 88 84 10 f0 	movl   $0xf0108488,(%esp)
f01016bb:	e8 de 2f 00 00       	call   f010469e <cprintf>
	int i;
	for (i = start_va; i <= end_va; i += PGSIZE) {
f01016c0:	89 f3                	mov    %esi,%ebx
f01016c2:	39 fe                	cmp    %edi,%esi
f01016c4:	0f 87 c6 00 00 00    	ja     f0101790 <showmappings+0xf3>
		cprintf("%x:\n", i);
f01016ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01016ce:	c7 04 24 f9 84 10 f0 	movl   $0xf01084f9,(%esp)
f01016d5:	e8 c4 2f 00 00       	call   f010469e <cprintf>
		uintptr_t pte = (uintptr_t)pgdir_walk(kern_pgdir, (void*)i, 0);
f01016da:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01016e1:	00 
f01016e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01016e6:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01016eb:	89 04 24             	mov    %eax,(%esp)
f01016ee:	e8 d6 fd ff ff       	call   f01014c9 <pgdir_walk>
		if (!pte) {
f01016f3:	85 c0                	test   %eax,%eax
f01016f5:	75 0e                	jne    f0101705 <showmappings+0x68>
			cprintf("Page table not present.\n");
f01016f7:	c7 04 24 8f 84 10 f0 	movl   $0xf010848f,(%esp)
f01016fe:	e8 9b 2f 00 00       	call   f010469e <cprintf>
			continue;
f0101703:	eb 7d                	jmp    f0101782 <showmappings+0xe5>
		}
		uintptr_t pa = *((uint32_t*)pte);
f0101705:	8b 30                	mov    (%eax),%esi
		// Physical mapping
		cprintf("\t Physical mapping: 0x%x\n", PTE_ADDR(pa));
f0101707:	89 f0                	mov    %esi,%eax
f0101709:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010170e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101712:	c7 04 24 a8 84 10 f0 	movl   $0xf01084a8,(%esp)
f0101719:	e8 80 2f 00 00       	call   f010469e <cprintf>
		if (pa & PTE_P) {
f010171e:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0101724:	74 0c                	je     f0101732 <showmappings+0x95>
			cprintf("\t Present\n");
f0101726:	c7 04 24 c2 84 10 f0 	movl   $0xf01084c2,(%esp)
f010172d:	e8 6c 2f 00 00       	call   f010469e <cprintf>
		}	
		if (pa & PTE_W) {
f0101732:	f7 c6 02 00 00 00    	test   $0x2,%esi
f0101738:	74 0c                	je     f0101746 <showmappings+0xa9>
			cprintf("\t Writeable\n");
f010173a:	c7 04 24 cd 84 10 f0 	movl   $0xf01084cd,(%esp)
f0101741:	e8 58 2f 00 00       	call   f010469e <cprintf>
		}	
		if (pa & PTE_U) {
f0101746:	f7 c6 04 00 00 00    	test   $0x4,%esi
f010174c:	74 0c                	je     f010175a <showmappings+0xbd>
			cprintf("\t User\n");
f010174e:	c7 04 24 da 84 10 f0 	movl   $0xf01084da,(%esp)
f0101755:	e8 44 2f 00 00       	call   f010469e <cprintf>
		}	
		if (pa & PTE_A) {
f010175a:	f7 c6 20 00 00 00    	test   $0x20,%esi
f0101760:	74 0c                	je     f010176e <showmappings+0xd1>
			cprintf("\t Accessed\n");
f0101762:	c7 04 24 e2 84 10 f0 	movl   $0xf01084e2,(%esp)
f0101769:	e8 30 2f 00 00       	call   f010469e <cprintf>
		}	
		if (pa & PTE_D) {
f010176e:	f7 c6 40 00 00 00    	test   $0x40,%esi
f0101774:	74 0c                	je     f0101782 <showmappings+0xe5>
			cprintf("\t Dirty\n");
f0101776:	c7 04 24 ee 84 10 f0 	movl   $0xf01084ee,(%esp)
f010177d:	e8 1c 2f 00 00       	call   f010469e <cprintf>

// Challenge!
void showmappings(uintptr_t start_va, uintptr_t end_va) {
	cprintf("%x %x\n", start_va, end_va);
	int i;
	for (i = start_va; i <= end_va; i += PGSIZE) {
f0101782:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101788:	39 df                	cmp    %ebx,%edi
f010178a:	0f 83 3a ff ff ff    	jae    f01016ca <showmappings+0x2d>
		}	
		if (pa & PTE_D) {
			cprintf("\t Dirty\n");
		}
	}
}
f0101790:	83 c4 1c             	add    $0x1c,%esp
f0101793:	5b                   	pop    %ebx
f0101794:	5e                   	pop    %esi
f0101795:	5f                   	pop    %edi
f0101796:	5d                   	pop    %ebp
f0101797:	c3                   	ret    

f0101798 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101798:	55                   	push   %ebp
f0101799:	89 e5                	mov    %esp,%ebp
f010179b:	53                   	push   %ebx
f010179c:	83 ec 14             	sub    $0x14,%esp
f010179f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	uintptr_t pte_va = (uintptr_t)pgdir_walk(pgdir, va, 0);
f01017a2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01017a9:	00 
f01017aa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01017ad:	89 44 24 04          	mov    %eax,0x4(%esp)
f01017b1:	8b 45 08             	mov    0x8(%ebp),%eax
f01017b4:	89 04 24             	mov    %eax,(%esp)
f01017b7:	e8 0d fd ff ff       	call   f01014c9 <pgdir_walk>
	if (!pte_va) {
f01017bc:	85 c0                	test   %eax,%eax
f01017be:	74 49                	je     f0101809 <page_lookup+0x71>
		return NULL;
	}
	physaddr_t page_mapped = *((uint32_t*)pte_va);
f01017c0:	8b 10                	mov    (%eax),%edx
	page_mapped = PTE_ADDR(page_mapped);
f01017c2:	89 d1                	mov    %edx,%ecx
f01017c4:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx

	if ((!pte_va) || (!( *(uint32_t*)pte_va & PTE_P))) {
f01017ca:	f6 c2 01             	test   $0x1,%dl
f01017cd:	74 41                	je     f0101810 <page_lookup+0x78>
		return NULL;
	} else {
		if (pte_store) {
f01017cf:	85 db                	test   %ebx,%ebx
f01017d1:	74 02                	je     f01017d5 <page_lookup+0x3d>
			*(pte_store) = (pte_t *)pte_va;
f01017d3:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017d5:	89 c8                	mov    %ecx,%eax
f01017d7:	c1 e8 0c             	shr    $0xc,%eax
f01017da:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f01017e0:	72 1c                	jb     f01017fe <page_lookup+0x66>
		panic("pa2page called with invalid pa");
f01017e2:	c7 44 24 08 8c 7b 10 	movl   $0xf0107b8c,0x8(%esp)
f01017e9:	f0 
f01017ea:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01017f1:	00 
f01017f2:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f01017f9:	e8 42 e8 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01017fe:	8b 15 90 be 22 f0    	mov    0xf022be90,%edx
f0101804:	8d 04 c2             	lea    (%edx,%eax,8),%eax
		}
		return pa2page((physaddr_t)page_mapped);	
f0101807:	eb 0c                	jmp    f0101815 <page_lookup+0x7d>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	uintptr_t pte_va = (uintptr_t)pgdir_walk(pgdir, va, 0);
	if (!pte_va) {
		return NULL;
f0101809:	b8 00 00 00 00       	mov    $0x0,%eax
f010180e:	eb 05                	jmp    f0101815 <page_lookup+0x7d>
	}
	physaddr_t page_mapped = *((uint32_t*)pte_va);
	page_mapped = PTE_ADDR(page_mapped);

	if ((!pte_va) || (!( *(uint32_t*)pte_va & PTE_P))) {
		return NULL;
f0101810:	b8 00 00 00 00       	mov    $0x0,%eax
			*(pte_store) = (pte_t *)pte_va;
		}
		return pa2page((physaddr_t)page_mapped);	
	}
	return NULL;
}
f0101815:	83 c4 14             	add    $0x14,%esp
f0101818:	5b                   	pop    %ebx
f0101819:	5d                   	pop    %ebp
f010181a:	c3                   	ret    

f010181b <boot_map_region>:
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa,
				int perm)
{
	uint32_t num_pages = size / PGSIZE;
f010181b:	c1 e9 0c             	shr    $0xc,%ecx
	physaddr_t curr_pa = pa;
	
	physaddr_t final_pa;
	uintptr_t pte_va;
	
	for (i = 0; i < num_pages; ++i) {
f010181e:	85 c9                	test   %ecx,%ecx
f0101820:	74 7b                	je     f010189d <boot_map_region+0x82>
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa,
				int perm)
{
f0101822:	55                   	push   %ebp
f0101823:	89 e5                	mov    %esp,%ebp
f0101825:	57                   	push   %edi
f0101826:	56                   	push   %esi
f0101827:	53                   	push   %ebx
f0101828:	83 ec 2c             	sub    $0x2c,%esp
f010182b:	89 c6                	mov    %eax,%esi
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa,
f010182d:	89 4d d8             	mov    %ecx,-0x28(%ebp)
				int perm)
{
	uint32_t num_pages = size / PGSIZE;
	int i;
	uintptr_t curr_va = va;
f0101830:	89 d3                	mov    %edx,%ebx
	physaddr_t curr_pa = pa;
	
	physaddr_t final_pa;
	uintptr_t pte_va;
	
	for (i = 0; i < num_pages; ++i) {
f0101832:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa,
f0101839:	8b 45 08             	mov    0x8(%ebp),%eax
f010183c:	29 d0                	sub    %edx,%eax
f010183e:	89 45 dc             	mov    %eax,-0x24(%ebp)
	physaddr_t final_pa;
	uintptr_t pte_va;
	
	for (i = 0; i < num_pages; ++i) {
		pte_va = (uintptr_t)pgdir_walk(pgdir, (void*)curr_va, 1);
	    final_pa = PTE_ADDR(curr_pa) | (perm | PTE_P);
f0101841:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101844:	83 c9 01             	or     $0x1,%ecx
f0101847:	89 4d e0             	mov    %ecx,-0x20(%ebp)
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa,
f010184a:	8b 7d dc             	mov    -0x24(%ebp),%edi
f010184d:	01 df                	add    %ebx,%edi
	
	physaddr_t final_pa;
	uintptr_t pte_va;
	
	for (i = 0; i < num_pages; ++i) {
		pte_va = (uintptr_t)pgdir_walk(pgdir, (void*)curr_va, 1);
f010184f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101856:	00 
f0101857:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010185b:	89 34 24             	mov    %esi,(%esp)
f010185e:	e8 66 fc ff ff       	call   f01014c9 <pgdir_walk>
	    final_pa = PTE_ADDR(curr_pa) | (perm | PTE_P);
		pgdir[PDX(curr_va)] = pgdir[PDX(curr_va)] | (perm | PTE_P);
f0101863:	89 da                	mov    %ebx,%edx
f0101865:	c1 ea 16             	shr    $0x16,%edx
f0101868:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010186b:	09 0c 96             	or     %ecx,(%esi,%edx,4)
	physaddr_t final_pa;
	uintptr_t pte_va;
	
	for (i = 0; i < num_pages; ++i) {
		pte_va = (uintptr_t)pgdir_walk(pgdir, (void*)curr_va, 1);
	    final_pa = PTE_ADDR(curr_pa) | (perm | PTE_P);
f010186e:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0101874:	09 cf                	or     %ecx,%edi
f0101876:	89 38                	mov    %edi,(%eax)
		pgdir[PDX(curr_va)] = pgdir[PDX(curr_va)] | (perm | PTE_P);
		*((uint32_t*)pte_va) = final_pa;
   		tlb_invalidate(pgdir, (void*)curr_va);
f0101878:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010187c:	89 34 24             	mov    %esi,(%esp)
f010187f:	e8 10 fc ff ff       	call   f0101494 <tlb_invalidate>
		curr_pa += PGSIZE;
 		curr_va += PGSIZE;		
f0101884:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	physaddr_t curr_pa = pa;
	
	physaddr_t final_pa;
	uintptr_t pte_va;
	
	for (i = 0; i < num_pages; ++i) {
f010188a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
f010188e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101891:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0101894:	75 b4                	jne    f010184a <boot_map_region+0x2f>
		*((uint32_t*)pte_va) = final_pa;
   		tlb_invalidate(pgdir, (void*)curr_va);
		curr_pa += PGSIZE;
 		curr_va += PGSIZE;		
	}
}
f0101896:	83 c4 2c             	add    $0x2c,%esp
f0101899:	5b                   	pop    %ebx
f010189a:	5e                   	pop    %esi
f010189b:	5f                   	pop    %edi
f010189c:	5d                   	pop    %ebp
f010189d:	f3 c3                	repz ret 

f010189f <change_perm>:
		}
	}
}

// Challenge!
void change_perm(uintptr_t va, int perm, int set) {
f010189f:	55                   	push   %ebp
f01018a0:	89 e5                	mov    %esp,%ebp
f01018a2:	83 ec 28             	sub    $0x28,%esp
f01018a5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01018a8:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01018ab:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01018ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01018b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01018b4:	8b 75 10             	mov    0x10(%ebp),%esi
	uintptr_t pte = (uintptr_t)pgdir_walk(kern_pgdir, (void*)va, 0);
f01018b7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01018be:	00 
f01018bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01018c3:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01018c8:	89 04 24             	mov    %eax,(%esp)
f01018cb:	e8 f9 fb ff ff       	call   f01014c9 <pgdir_walk>
	if (!pte) {
f01018d0:	85 c0                	test   %eax,%eax
f01018d2:	75 1e                	jne    f01018f2 <change_perm+0x53>
		cprintf("0x%x:\n", va);
f01018d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01018d8:	c7 04 24 f7 84 10 f0 	movl   $0xf01084f7,(%esp)
f01018df:	e8 ba 2d 00 00       	call   f010469e <cprintf>
		cprintf("Page table not present.\n");
f01018e4:	c7 04 24 8f 84 10 f0 	movl   $0xf010848f,(%esp)
f01018eb:	e8 ae 2d 00 00       	call   f010469e <cprintf>
		return;
f01018f0:	eb 20                	jmp    f0101912 <change_perm+0x73>
	}
	uintptr_t pa = *((uint32_t*)pte);
f01018f2:	8b 10                	mov    (%eax),%edx
	if (set) {
		pa = pa | perm;
f01018f4:	89 d1                	mov    %edx,%ecx
f01018f6:	09 f9                	or     %edi,%ecx
f01018f8:	21 fa                	and    %edi,%edx
f01018fa:	85 f6                	test   %esi,%esi
f01018fc:	0f 45 d1             	cmovne %ecx,%edx
	} else {
		pa = pa & perm;
	}
	*((uint32_t*)pte) = pa;
f01018ff:	89 10                	mov    %edx,(%eax)
	tlb_invalidate(kern_pgdir, (void*) va);
f0101901:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101905:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f010190a:	89 04 24             	mov    %eax,(%esp)
f010190d:	e8 82 fb ff ff       	call   f0101494 <tlb_invalidate>
}
f0101912:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101915:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101918:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010191b:	89 ec                	mov    %ebp,%esp
f010191d:	5d                   	pop    %ebp
f010191e:	c3                   	ret    

f010191f <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010191f:	55                   	push   %ebp
f0101920:	89 e5                	mov    %esp,%ebp
f0101922:	83 ec 28             	sub    $0x28,%esp
f0101925:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101928:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010192b:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010192e:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101931:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	
	struct PageInfo* page = page_lookup(pgdir, va, 0);
f0101934:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010193b:	00 
f010193c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101940:	89 1c 24             	mov    %ebx,(%esp)
f0101943:	e8 50 fe ff ff       	call   f0101798 <page_lookup>
f0101948:	89 c7                	mov    %eax,%edi
	
	if (page) {
f010194a:	85 c0                	test   %eax,%eax
f010194c:	74 2e                	je     f010197c <page_remove+0x5d>
		uint32_t pte_v = (uint32_t)pgdir_walk(pgdir, va, 0);
f010194e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101955:	00 
f0101956:	89 74 24 04          	mov    %esi,0x4(%esp)
f010195a:	89 1c 24             	mov    %ebx,(%esp)
f010195d:	e8 67 fb ff ff       	call   f01014c9 <pgdir_walk>
		*((uint32_t*)pte_v) = 0;
f0101962:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		page_decref(page);
f0101968:	89 3c 24             	mov    %edi,(%esp)
f010196b:	e8 01 fb ff ff       	call   f0101471 <page_decref>
		tlb_invalidate(pgdir, va);
f0101970:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101974:	89 1c 24             	mov    %ebx,(%esp)
f0101977:	e8 18 fb ff ff       	call   f0101494 <tlb_invalidate>
	} else {
		return;
	}
}
f010197c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010197f:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101982:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101985:	89 ec                	mov    %ebp,%esp
f0101987:	5d                   	pop    %ebp
f0101988:	c3                   	ret    

f0101989 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101989:	55                   	push   %ebp
f010198a:	89 e5                	mov    %esp,%ebp
f010198c:	57                   	push   %edi
f010198d:	56                   	push   %esi
f010198e:	53                   	push   %ebx
f010198f:	83 ec 1c             	sub    $0x1c,%esp
f0101992:	8b 75 08             	mov    0x8(%ebp),%esi
f0101995:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101998:	8b 7d 10             	mov    0x10(%ebp),%edi
	struct PageInfo* prev_page = page_lookup(pgdir, va, 0);
f010199b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01019a2:	00 
f01019a3:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01019a7:	89 34 24             	mov    %esi,(%esp)
f01019aa:	e8 e9 fd ff ff       	call   f0101798 <page_lookup>

	if (prev_page) {
f01019af:	85 c0                	test   %eax,%eax
f01019b1:	74 18                	je     f01019cb <page_insert+0x42>
		page_remove(pgdir, va);
f01019b3:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01019b7:	89 34 24             	mov    %esi,(%esp)
f01019ba:	e8 60 ff ff ff       	call   f010191f <page_remove>
		tlb_invalidate(pgdir, va);
f01019bf:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01019c3:	89 34 24             	mov    %esi,(%esp)
f01019c6:	e8 c9 fa ff ff       	call   f0101494 <tlb_invalidate>
	}

	struct PageInfo* iter = page_free_list;
	if (page_free_list) {
f01019cb:	a1 44 b2 22 f0       	mov    0xf022b244,%eax
f01019d0:	85 c0                	test   %eax,%eax
f01019d2:	74 1b                	je     f01019ef <page_insert+0x66>
		iter = page_free_list;
		if (iter == pp) {
f01019d4:	39 d8                	cmp    %ebx,%eax
f01019d6:	75 09                	jne    f01019e1 <page_insert+0x58>
			if (page_free_list->pp_link) {
f01019d8:	8b 00                	mov    (%eax),%eax
				page_free_list = page_free_list->pp_link;
f01019da:	a3 44 b2 22 f0       	mov    %eax,0xf022b244
f01019df:	eb 0e                	jmp    f01019ef <page_insert+0x66>
			} else {
				page_free_list = NULL;
			}
		} else {
			while (iter) {
				if (iter->pp_link == pp) {
f01019e1:	39 18                	cmp    %ebx,(%eax)
f01019e3:	75 04                	jne    f01019e9 <page_insert+0x60>
					iter->pp_link = pp->pp_link;
f01019e5:	8b 13                	mov    (%ebx),%edx
f01019e7:	89 10                	mov    %edx,(%eax)
				}
				iter = iter->pp_link;	
f01019e9:	8b 00                	mov    (%eax),%eax
				page_free_list = page_free_list->pp_link;
			} else {
				page_free_list = NULL;
			}
		} else {
			while (iter) {
f01019eb:	85 c0                	test   %eax,%eax
f01019ed:	75 f2                	jne    f01019e1 <page_insert+0x58>
				}
				iter = iter->pp_link;	
			}
		}
	}
	uintptr_t pte_va = (uintptr_t)pgdir_walk(pgdir, va, 1);
f01019ef:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01019f6:	00 
f01019f7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01019fb:	89 34 24             	mov    %esi,(%esp)
f01019fe:	e8 c6 fa ff ff       	call   f01014c9 <pgdir_walk>

	if (!pte_va) {
f0101a03:	85 c0                	test   %eax,%eax
f0101a05:	74 36                	je     f0101a3d <page_insert+0xb4>
		return -E_NO_MEM;
	}
		
	pp->pp_ref++;
f0101a07:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101a0c:	2b 1d 90 be 22 f0    	sub    0xf022be90,%ebx
f0101a12:	c1 fb 03             	sar    $0x3,%ebx
	
	physaddr_t pte = page2pa(pp);
	pte = PTE_ADDR(pte);
f0101a15:	c1 e3 0c             	shl    $0xc,%ebx
	int full_perm = perm | PTE_P;
f0101a18:	8b 55 14             	mov    0x14(%ebp),%edx
f0101a1b:	83 ca 01             	or     $0x1,%edx
	
	pte = pte | full_perm;	
f0101a1e:	09 d3                	or     %edx,%ebx
f0101a20:	89 18                	mov    %ebx,(%eax)
	}
	if (full_perm & PTE_U) {
		pgdir[PDX(va)] = pgdir[PDX(va)] | PTE_U;	
	}
*/
	pgdir[PDX(va)] = pgdir[PDX(va)] | full_perm;
f0101a22:	89 f8                	mov    %edi,%eax
f0101a24:	c1 e8 16             	shr    $0x16,%eax
f0101a27:	09 14 86             	or     %edx,(%esi,%eax,4)
	tlb_invalidate(pgdir, va);
f0101a2a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101a2e:	89 34 24             	mov    %esi,(%esp)
f0101a31:	e8 5e fa ff ff       	call   f0101494 <tlb_invalidate>

	// cprintf("pmap.c / page_insert a success!\n");
	return 0;
f0101a36:	b8 00 00 00 00       	mov    $0x0,%eax
f0101a3b:	eb 05                	jmp    f0101a42 <page_insert+0xb9>
		}
	}
	uintptr_t pte_va = (uintptr_t)pgdir_walk(pgdir, va, 1);

	if (!pte_va) {
		return -E_NO_MEM;
f0101a3d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	pgdir[PDX(va)] = pgdir[PDX(va)] | full_perm;
	tlb_invalidate(pgdir, va);

	// cprintf("pmap.c / page_insert a success!\n");
	return 0;
}
f0101a42:	83 c4 1c             	add    $0x1c,%esp
f0101a45:	5b                   	pop    %ebx
f0101a46:	5e                   	pop    %esi
f0101a47:	5f                   	pop    %edi
f0101a48:	5d                   	pop    %ebp
f0101a49:	c3                   	ret    

f0101a4a <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101a4a:	55                   	push   %ebp
f0101a4b:	89 e5                	mov    %esp,%ebp
f0101a4d:	53                   	push   %ebx
f0101a4e:	83 ec 14             	sub    $0x14,%esp
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	size = ROUNDUP(size, PGSIZE);
f0101a51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101a54:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f0101a5a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	int perm = PTE_W | PTE_PCD | PTE_PWT;

	if (base + size > MMIOLIM) {
f0101a60:	8b 15 00 33 12 f0    	mov    0xf0123300,%edx
f0101a66:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f0101a69:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f0101a6e:	76 1c                	jbe    f0101a8c <mmio_map_region+0x42>
		panic("Exceeding MMIOLIM\n");
f0101a70:	c7 44 24 08 fe 84 10 	movl   $0xf01084fe,0x8(%esp)
f0101a77:	f0 
f0101a78:	c7 44 24 04 29 03 00 	movl   $0x329,0x4(%esp)
f0101a7f:	00 
f0101a80:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0101a87:	e8 b4 e5 ff ff       	call   f0100040 <_panic>
	}

	// cprintf("base: %x\n", base);

	boot_map_region(kern_pgdir, base, size, pa, perm);
f0101a8c:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f0101a93:	00 
f0101a94:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a97:	89 04 24             	mov    %eax,(%esp)
f0101a9a:	89 d9                	mov    %ebx,%ecx
f0101a9c:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101aa1:	e8 75 fd ff ff       	call   f010181b <boot_map_region>

	base = (uint32_t)base + size;
f0101aa6:	a1 00 33 12 f0       	mov    0xf0123300,%eax
f0101aab:	01 c3                	add    %eax,%ebx
f0101aad:	89 1d 00 33 12 f0    	mov    %ebx,0xf0123300
	return (void*)((uint32_t)base - size);
}
f0101ab3:	83 c4 14             	add    $0x14,%esp
f0101ab6:	5b                   	pop    %ebx
f0101ab7:	5d                   	pop    %ebp
f0101ab8:	c3                   	ret    

f0101ab9 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101ab9:	55                   	push   %ebp
f0101aba:	89 e5                	mov    %esp,%ebp
f0101abc:	57                   	push   %edi
f0101abd:	56                   	push   %esi
f0101abe:	53                   	push   %ebx
f0101abf:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101ac2:	b8 15 00 00 00       	mov    $0x15,%eax
f0101ac7:	e8 06 f4 ff ff       	call   f0100ed2 <nvram_read>
f0101acc:	c1 e0 0a             	shl    $0xa,%eax
f0101acf:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101ad5:	85 c0                	test   %eax,%eax
f0101ad7:	0f 48 c2             	cmovs  %edx,%eax
f0101ada:	c1 f8 0c             	sar    $0xc,%eax
f0101add:	a3 3c b2 22 f0       	mov    %eax,0xf022b23c
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101ae2:	b8 17 00 00 00       	mov    $0x17,%eax
f0101ae7:	e8 e6 f3 ff ff       	call   f0100ed2 <nvram_read>
f0101aec:	c1 e0 0a             	shl    $0xa,%eax
f0101aef:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101af5:	85 c0                	test   %eax,%eax
f0101af7:	0f 48 c2             	cmovs  %edx,%eax
f0101afa:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101afd:	85 c0                	test   %eax,%eax
f0101aff:	74 0e                	je     f0101b0f <mem_init+0x56>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101b01:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101b07:	89 15 88 be 22 f0    	mov    %edx,0xf022be88
f0101b0d:	eb 0c                	jmp    f0101b1b <mem_init+0x62>
	else
		npages = npages_basemem;
f0101b0f:	8b 15 3c b2 22 f0    	mov    0xf022b23c,%edx
f0101b15:	89 15 88 be 22 f0    	mov    %edx,0xf022be88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0101b1b:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101b1e:	c1 e8 0a             	shr    $0xa,%eax
f0101b21:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101b25:	a1 3c b2 22 f0       	mov    0xf022b23c,%eax
f0101b2a:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101b2d:	c1 e8 0a             	shr    $0xa,%eax
f0101b30:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0101b34:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f0101b39:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101b3c:	c1 e8 0a             	shr    $0xa,%eax
f0101b3f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101b43:	c7 04 24 ac 7b 10 f0 	movl   $0xf0107bac,(%esp)
f0101b4a:	e8 4f 2b 00 00       	call   f010469e <cprintf>
	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	
	// pde_t is a uint32_t -> memlayout.h
	
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101b4f:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101b54:	e8 06 f3 ff ff       	call   f0100e5f <boot_alloc>
f0101b59:	a3 8c be 22 f0       	mov    %eax,0xf022be8c
	memset(kern_pgdir, 0, PGSIZE);
f0101b5e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101b65:	00 
f0101b66:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101b6d:	00 
f0101b6e:	89 04 24             	mov    %eax,(%esp)
f0101b71:	e8 8f 4a 00 00       	call   f0106605 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101b76:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101b7b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101b80:	77 20                	ja     f0101ba2 <mem_init+0xe9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101b82:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101b86:	c7 44 24 08 44 74 10 	movl   $0xf0107444,0x8(%esp)
f0101b8d:	f0 
f0101b8e:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
f0101b95:	00 
f0101b96:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0101b9d:	e8 9e e4 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101ba2:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101ba8:	83 ca 05             	or     $0x5,%edx
f0101bab:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:

	int size = npages * sizeof(struct PageInfo);
f0101bb1:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f0101bb6:	c1 e0 03             	shl    $0x3,%eax
	pages = boot_alloc(size); 
f0101bb9:	e8 a1 f2 ff ff       	call   f0100e5f <boot_alloc>
f0101bbe:	a3 90 be 22 f0       	mov    %eax,0xf022be90
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	int size_env = NENV * sizeof(struct Env);
	envs = boot_alloc(size_env); 
f0101bc3:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101bc8:	e8 92 f2 ff ff       	call   f0100e5f <boot_alloc>
f0101bcd:	a3 4c b2 22 f0       	mov    %eax,0xf022b24c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101bd2:	e8 07 f7 ff ff       	call   f01012de <page_init>

	check_page_free_list(1);
f0101bd7:	b8 01 00 00 00       	mov    $0x1,%eax
f0101bdc:	e8 23 f3 ff ff       	call   f0100f04 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101be1:	83 3d 90 be 22 f0 00 	cmpl   $0x0,0xf022be90
f0101be8:	75 1c                	jne    f0101c06 <mem_init+0x14d>
		panic("'pages' is a null pointer!");
f0101bea:	c7 44 24 08 11 85 10 	movl   $0xf0108511,0x8(%esp)
f0101bf1:	f0 
f0101bf2:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f0101bf9:	00 
f0101bfa:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0101c01:	e8 3a e4 ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101c06:	a1 44 b2 22 f0       	mov    0xf022b244,%eax
f0101c0b:	85 c0                	test   %eax,%eax
f0101c0d:	74 10                	je     f0101c1f <mem_init+0x166>
f0101c0f:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f0101c14:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101c17:	8b 00                	mov    (%eax),%eax
f0101c19:	85 c0                	test   %eax,%eax
f0101c1b:	75 f7                	jne    f0101c14 <mem_init+0x15b>
f0101c1d:	eb 05                	jmp    f0101c24 <mem_init+0x16b>
f0101c1f:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101c24:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c2b:	e8 ae f7 ff ff       	call   f01013de <page_alloc>
f0101c30:	89 c7                	mov    %eax,%edi
f0101c32:	85 c0                	test   %eax,%eax
f0101c34:	75 24                	jne    f0101c5a <mem_init+0x1a1>
f0101c36:	c7 44 24 0c 2c 85 10 	movl   $0xf010852c,0xc(%esp)
f0101c3d:	f0 
f0101c3e:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101c45:	f0 
f0101c46:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f0101c4d:	00 
f0101c4e:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0101c55:	e8 e6 e3 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101c5a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c61:	e8 78 f7 ff ff       	call   f01013de <page_alloc>
f0101c66:	89 c6                	mov    %eax,%esi
f0101c68:	85 c0                	test   %eax,%eax
f0101c6a:	75 24                	jne    f0101c90 <mem_init+0x1d7>
f0101c6c:	c7 44 24 0c 42 85 10 	movl   $0xf0108542,0xc(%esp)
f0101c73:	f0 
f0101c74:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101c7b:	f0 
f0101c7c:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f0101c83:	00 
f0101c84:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0101c8b:	e8 b0 e3 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101c90:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c97:	e8 42 f7 ff ff       	call   f01013de <page_alloc>
f0101c9c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101c9f:	85 c0                	test   %eax,%eax
f0101ca1:	75 24                	jne    f0101cc7 <mem_init+0x20e>
f0101ca3:	c7 44 24 0c 58 85 10 	movl   $0xf0108558,0xc(%esp)
f0101caa:	f0 
f0101cab:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101cb2:	f0 
f0101cb3:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f0101cba:	00 
f0101cbb:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0101cc2:	e8 79 e3 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101cc7:	39 f7                	cmp    %esi,%edi
f0101cc9:	75 24                	jne    f0101cef <mem_init+0x236>
f0101ccb:	c7 44 24 0c 6e 85 10 	movl   $0xf010856e,0xc(%esp)
f0101cd2:	f0 
f0101cd3:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101cda:	f0 
f0101cdb:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f0101ce2:	00 
f0101ce3:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0101cea:	e8 51 e3 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101cef:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101cf2:	74 05                	je     f0101cf9 <mem_init+0x240>
f0101cf4:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101cf7:	75 24                	jne    f0101d1d <mem_init+0x264>
f0101cf9:	c7 44 24 0c e8 7b 10 	movl   $0xf0107be8,0xc(%esp)
f0101d00:	f0 
f0101d01:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101d08:	f0 
f0101d09:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f0101d10:	00 
f0101d11:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0101d18:	e8 23 e3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d1d:	8b 15 90 be 22 f0    	mov    0xf022be90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101d23:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f0101d28:	c1 e0 0c             	shl    $0xc,%eax
f0101d2b:	89 f9                	mov    %edi,%ecx
f0101d2d:	29 d1                	sub    %edx,%ecx
f0101d2f:	c1 f9 03             	sar    $0x3,%ecx
f0101d32:	c1 e1 0c             	shl    $0xc,%ecx
f0101d35:	39 c1                	cmp    %eax,%ecx
f0101d37:	72 24                	jb     f0101d5d <mem_init+0x2a4>
f0101d39:	c7 44 24 0c 80 85 10 	movl   $0xf0108580,0xc(%esp)
f0101d40:	f0 
f0101d41:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101d48:	f0 
f0101d49:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f0101d50:	00 
f0101d51:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0101d58:	e8 e3 e2 ff ff       	call   f0100040 <_panic>
f0101d5d:	89 f1                	mov    %esi,%ecx
f0101d5f:	29 d1                	sub    %edx,%ecx
f0101d61:	c1 f9 03             	sar    $0x3,%ecx
f0101d64:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101d67:	39 c8                	cmp    %ecx,%eax
f0101d69:	77 24                	ja     f0101d8f <mem_init+0x2d6>
f0101d6b:	c7 44 24 0c 9d 85 10 	movl   $0xf010859d,0xc(%esp)
f0101d72:	f0 
f0101d73:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101d7a:	f0 
f0101d7b:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f0101d82:	00 
f0101d83:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0101d8a:	e8 b1 e2 ff ff       	call   f0100040 <_panic>
f0101d8f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101d92:	29 d1                	sub    %edx,%ecx
f0101d94:	89 ca                	mov    %ecx,%edx
f0101d96:	c1 fa 03             	sar    $0x3,%edx
f0101d99:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101d9c:	39 d0                	cmp    %edx,%eax
f0101d9e:	77 24                	ja     f0101dc4 <mem_init+0x30b>
f0101da0:	c7 44 24 0c ba 85 10 	movl   $0xf01085ba,0xc(%esp)
f0101da7:	f0 
f0101da8:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101daf:	f0 
f0101db0:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f0101db7:	00 
f0101db8:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0101dbf:	e8 7c e2 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101dc4:	a1 44 b2 22 f0       	mov    0xf022b244,%eax
f0101dc9:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101dcc:	c7 05 44 b2 22 f0 00 	movl   $0x0,0xf022b244
f0101dd3:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101dd6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ddd:	e8 fc f5 ff ff       	call   f01013de <page_alloc>
f0101de2:	85 c0                	test   %eax,%eax
f0101de4:	74 24                	je     f0101e0a <mem_init+0x351>
f0101de6:	c7 44 24 0c d7 85 10 	movl   $0xf01085d7,0xc(%esp)
f0101ded:	f0 
f0101dee:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101df5:	f0 
f0101df6:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f0101dfd:	00 
f0101dfe:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0101e05:	e8 36 e2 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101e0a:	89 3c 24             	mov    %edi,(%esp)
f0101e0d:	e8 4a f6 ff ff       	call   f010145c <page_free>
	page_free(pp1);
f0101e12:	89 34 24             	mov    %esi,(%esp)
f0101e15:	e8 42 f6 ff ff       	call   f010145c <page_free>
	page_free(pp2);
f0101e1a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e1d:	89 04 24             	mov    %eax,(%esp)
f0101e20:	e8 37 f6 ff ff       	call   f010145c <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101e25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e2c:	e8 ad f5 ff ff       	call   f01013de <page_alloc>
f0101e31:	89 c6                	mov    %eax,%esi
f0101e33:	85 c0                	test   %eax,%eax
f0101e35:	75 24                	jne    f0101e5b <mem_init+0x3a2>
f0101e37:	c7 44 24 0c 2c 85 10 	movl   $0xf010852c,0xc(%esp)
f0101e3e:	f0 
f0101e3f:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101e46:	f0 
f0101e47:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f0101e4e:	00 
f0101e4f:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0101e56:	e8 e5 e1 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101e5b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e62:	e8 77 f5 ff ff       	call   f01013de <page_alloc>
f0101e67:	89 c7                	mov    %eax,%edi
f0101e69:	85 c0                	test   %eax,%eax
f0101e6b:	75 24                	jne    f0101e91 <mem_init+0x3d8>
f0101e6d:	c7 44 24 0c 42 85 10 	movl   $0xf0108542,0xc(%esp)
f0101e74:	f0 
f0101e75:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101e7c:	f0 
f0101e7d:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f0101e84:	00 
f0101e85:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0101e8c:	e8 af e1 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101e91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e98:	e8 41 f5 ff ff       	call   f01013de <page_alloc>
f0101e9d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101ea0:	85 c0                	test   %eax,%eax
f0101ea2:	75 24                	jne    f0101ec8 <mem_init+0x40f>
f0101ea4:	c7 44 24 0c 58 85 10 	movl   $0xf0108558,0xc(%esp)
f0101eab:	f0 
f0101eac:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101eb3:	f0 
f0101eb4:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f0101ebb:	00 
f0101ebc:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0101ec3:	e8 78 e1 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101ec8:	39 fe                	cmp    %edi,%esi
f0101eca:	75 24                	jne    f0101ef0 <mem_init+0x437>
f0101ecc:	c7 44 24 0c 6e 85 10 	movl   $0xf010856e,0xc(%esp)
f0101ed3:	f0 
f0101ed4:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101edb:	f0 
f0101edc:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f0101ee3:	00 
f0101ee4:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0101eeb:	e8 50 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101ef0:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101ef3:	74 05                	je     f0101efa <mem_init+0x441>
f0101ef5:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101ef8:	75 24                	jne    f0101f1e <mem_init+0x465>
f0101efa:	c7 44 24 0c e8 7b 10 	movl   $0xf0107be8,0xc(%esp)
f0101f01:	f0 
f0101f02:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101f09:	f0 
f0101f0a:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f0101f11:	00 
f0101f12:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0101f19:	e8 22 e1 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101f1e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f25:	e8 b4 f4 ff ff       	call   f01013de <page_alloc>
f0101f2a:	85 c0                	test   %eax,%eax
f0101f2c:	74 24                	je     f0101f52 <mem_init+0x499>
f0101f2e:	c7 44 24 0c d7 85 10 	movl   $0xf01085d7,0xc(%esp)
f0101f35:	f0 
f0101f36:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101f3d:	f0 
f0101f3e:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f0101f45:	00 
f0101f46:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0101f4d:	e8 ee e0 ff ff       	call   f0100040 <_panic>
f0101f52:	89 f0                	mov    %esi,%eax
f0101f54:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0101f5a:	c1 f8 03             	sar    $0x3,%eax
f0101f5d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f60:	89 c2                	mov    %eax,%edx
f0101f62:	c1 ea 0c             	shr    $0xc,%edx
f0101f65:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0101f6b:	72 20                	jb     f0101f8d <mem_init+0x4d4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f6d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101f71:	c7 44 24 08 68 74 10 	movl   $0xf0107468,0x8(%esp)
f0101f78:	f0 
f0101f79:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
f0101f80:	00 
f0101f81:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f0101f88:	e8 b3 e0 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101f8d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101f94:	00 
f0101f95:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101f9c:	00 
	return (void *)(pa + KERNBASE);
f0101f9d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101fa2:	89 04 24             	mov    %eax,(%esp)
f0101fa5:	e8 5b 46 00 00       	call   f0106605 <memset>
	page_free(pp0);
f0101faa:	89 34 24             	mov    %esi,(%esp)
f0101fad:	e8 aa f4 ff ff       	call   f010145c <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101fb2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101fb9:	e8 20 f4 ff ff       	call   f01013de <page_alloc>
f0101fbe:	85 c0                	test   %eax,%eax
f0101fc0:	75 24                	jne    f0101fe6 <mem_init+0x52d>
f0101fc2:	c7 44 24 0c e6 85 10 	movl   $0xf01085e6,0xc(%esp)
f0101fc9:	f0 
f0101fca:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101fd1:	f0 
f0101fd2:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f0101fd9:	00 
f0101fda:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0101fe1:	e8 5a e0 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101fe6:	39 c6                	cmp    %eax,%esi
f0101fe8:	74 24                	je     f010200e <mem_init+0x555>
f0101fea:	c7 44 24 0c 04 86 10 	movl   $0xf0108604,0xc(%esp)
f0101ff1:	f0 
f0101ff2:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101ff9:	f0 
f0101ffa:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f0102001:	00 
f0102002:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102009:	e8 32 e0 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010200e:	89 f2                	mov    %esi,%edx
f0102010:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0102016:	c1 fa 03             	sar    $0x3,%edx
f0102019:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010201c:	89 d0                	mov    %edx,%eax
f010201e:	c1 e8 0c             	shr    $0xc,%eax
f0102021:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0102027:	72 20                	jb     f0102049 <mem_init+0x590>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102029:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010202d:	c7 44 24 08 68 74 10 	movl   $0xf0107468,0x8(%esp)
f0102034:	f0 
f0102035:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
f010203c:	00 
f010203d:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f0102044:	e8 f7 df ff ff       	call   f0100040 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0102049:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0102050:	75 11                	jne    f0102063 <mem_init+0x5aa>
f0102052:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102058:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010205e:	80 38 00             	cmpb   $0x0,(%eax)
f0102061:	74 24                	je     f0102087 <mem_init+0x5ce>
f0102063:	c7 44 24 0c 14 86 10 	movl   $0xf0108614,0xc(%esp)
f010206a:	f0 
f010206b:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102072:	f0 
f0102073:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f010207a:	00 
f010207b:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102082:	e8 b9 df ff ff       	call   f0100040 <_panic>
f0102087:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f010208a:	39 d0                	cmp    %edx,%eax
f010208c:	75 d0                	jne    f010205e <mem_init+0x5a5>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f010208e:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102091:	89 15 44 b2 22 f0    	mov    %edx,0xf022b244

	// free the pages we took
	page_free(pp0);
f0102097:	89 34 24             	mov    %esi,(%esp)
f010209a:	e8 bd f3 ff ff       	call   f010145c <page_free>
	page_free(pp1);
f010209f:	89 3c 24             	mov    %edi,(%esp)
f01020a2:	e8 b5 f3 ff ff       	call   f010145c <page_free>
	page_free(pp2);
f01020a7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020aa:	89 04 24             	mov    %eax,(%esp)
f01020ad:	e8 aa f3 ff ff       	call   f010145c <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01020b2:	a1 44 b2 22 f0       	mov    0xf022b244,%eax
f01020b7:	85 c0                	test   %eax,%eax
f01020b9:	74 09                	je     f01020c4 <mem_init+0x60b>
		--nfree;
f01020bb:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01020be:	8b 00                	mov    (%eax),%eax
f01020c0:	85 c0                	test   %eax,%eax
f01020c2:	75 f7                	jne    f01020bb <mem_init+0x602>
		--nfree;
	assert(nfree == 0);
f01020c4:	85 db                	test   %ebx,%ebx
f01020c6:	74 24                	je     f01020ec <mem_init+0x633>
f01020c8:	c7 44 24 0c 1e 86 10 	movl   $0xf010861e,0xc(%esp)
f01020cf:	f0 
f01020d0:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01020d7:	f0 
f01020d8:	c7 44 24 04 06 04 00 	movl   $0x406,0x4(%esp)
f01020df:	00 
f01020e0:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01020e7:	e8 54 df ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01020ec:	c7 04 24 08 7c 10 f0 	movl   $0xf0107c08,(%esp)
f01020f3:	e8 a6 25 00 00       	call   f010469e <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01020f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01020ff:	e8 da f2 ff ff       	call   f01013de <page_alloc>
f0102104:	89 c6                	mov    %eax,%esi
f0102106:	85 c0                	test   %eax,%eax
f0102108:	75 24                	jne    f010212e <mem_init+0x675>
f010210a:	c7 44 24 0c 2c 85 10 	movl   $0xf010852c,0xc(%esp)
f0102111:	f0 
f0102112:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102119:	f0 
f010211a:	c7 44 24 04 80 04 00 	movl   $0x480,0x4(%esp)
f0102121:	00 
f0102122:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102129:	e8 12 df ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010212e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102135:	e8 a4 f2 ff ff       	call   f01013de <page_alloc>
f010213a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010213d:	85 c0                	test   %eax,%eax
f010213f:	75 24                	jne    f0102165 <mem_init+0x6ac>
f0102141:	c7 44 24 0c 42 85 10 	movl   $0xf0108542,0xc(%esp)
f0102148:	f0 
f0102149:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102150:	f0 
f0102151:	c7 44 24 04 81 04 00 	movl   $0x481,0x4(%esp)
f0102158:	00 
f0102159:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102160:	e8 db de ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102165:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010216c:	e8 6d f2 ff ff       	call   f01013de <page_alloc>
f0102171:	89 c3                	mov    %eax,%ebx
f0102173:	85 c0                	test   %eax,%eax
f0102175:	75 24                	jne    f010219b <mem_init+0x6e2>
f0102177:	c7 44 24 0c 58 85 10 	movl   $0xf0108558,0xc(%esp)
f010217e:	f0 
f010217f:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102186:	f0 
f0102187:	c7 44 24 04 82 04 00 	movl   $0x482,0x4(%esp)
f010218e:	00 
f010218f:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102196:	e8 a5 de ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010219b:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f010219e:	75 24                	jne    f01021c4 <mem_init+0x70b>
f01021a0:	c7 44 24 0c 6e 85 10 	movl   $0xf010856e,0xc(%esp)
f01021a7:	f0 
f01021a8:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01021af:	f0 
f01021b0:	c7 44 24 04 85 04 00 	movl   $0x485,0x4(%esp)
f01021b7:	00 
f01021b8:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01021bf:	e8 7c de ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01021c4:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01021c7:	74 04                	je     f01021cd <mem_init+0x714>
f01021c9:	39 c6                	cmp    %eax,%esi
f01021cb:	75 24                	jne    f01021f1 <mem_init+0x738>
f01021cd:	c7 44 24 0c e8 7b 10 	movl   $0xf0107be8,0xc(%esp)
f01021d4:	f0 
f01021d5:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01021dc:	f0 
f01021dd:	c7 44 24 04 86 04 00 	movl   $0x486,0x4(%esp)
f01021e4:	00 
f01021e5:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01021ec:	e8 4f de ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01021f1:	8b 3d 44 b2 22 f0    	mov    0xf022b244,%edi
f01021f7:	89 7d c8             	mov    %edi,-0x38(%ebp)
	page_free_list = 0;
f01021fa:	c7 05 44 b2 22 f0 00 	movl   $0x0,0xf022b244
f0102201:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102204:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010220b:	e8 ce f1 ff ff       	call   f01013de <page_alloc>
f0102210:	85 c0                	test   %eax,%eax
f0102212:	74 24                	je     f0102238 <mem_init+0x77f>
f0102214:	c7 44 24 0c d7 85 10 	movl   $0xf01085d7,0xc(%esp)
f010221b:	f0 
f010221c:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102223:	f0 
f0102224:	c7 44 24 04 8d 04 00 	movl   $0x48d,0x4(%esp)
f010222b:	00 
f010222c:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102233:	e8 08 de ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102238:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010223b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010223f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102246:	00 
f0102247:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f010224c:	89 04 24             	mov    %eax,(%esp)
f010224f:	e8 44 f5 ff ff       	call   f0101798 <page_lookup>
f0102254:	85 c0                	test   %eax,%eax
f0102256:	74 24                	je     f010227c <mem_init+0x7c3>
f0102258:	c7 44 24 0c 28 7c 10 	movl   $0xf0107c28,0xc(%esp)
f010225f:	f0 
f0102260:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102267:	f0 
f0102268:	c7 44 24 04 90 04 00 	movl   $0x490,0x4(%esp)
f010226f:	00 
f0102270:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102277:	e8 c4 dd ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010227c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102283:	00 
f0102284:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010228b:	00 
f010228c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010228f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102293:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102298:	89 04 24             	mov    %eax,(%esp)
f010229b:	e8 e9 f6 ff ff       	call   f0101989 <page_insert>
f01022a0:	85 c0                	test   %eax,%eax
f01022a2:	78 24                	js     f01022c8 <mem_init+0x80f>
f01022a4:	c7 44 24 0c 60 7c 10 	movl   $0xf0107c60,0xc(%esp)
f01022ab:	f0 
f01022ac:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01022b3:	f0 
f01022b4:	c7 44 24 04 93 04 00 	movl   $0x493,0x4(%esp)
f01022bb:	00 
f01022bc:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01022c3:	e8 78 dd ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table

	page_free(pp0);
f01022c8:	89 34 24             	mov    %esi,(%esp)
f01022cb:	e8 8c f1 ff ff       	call   f010145c <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01022d0:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01022d7:	00 
f01022d8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01022df:	00 
f01022e0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022e3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01022e7:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01022ec:	89 04 24             	mov    %eax,(%esp)
f01022ef:	e8 95 f6 ff ff       	call   f0101989 <page_insert>
f01022f4:	85 c0                	test   %eax,%eax
f01022f6:	74 24                	je     f010231c <mem_init+0x863>
f01022f8:	c7 44 24 0c 90 7c 10 	movl   $0xf0107c90,0xc(%esp)
f01022ff:	f0 
f0102300:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102307:	f0 
f0102308:	c7 44 24 04 98 04 00 	movl   $0x498,0x4(%esp)
f010230f:	00 
f0102310:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102317:	e8 24 dd ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010231c:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102322:	8b 15 90 be 22 f0    	mov    0xf022be90,%edx
f0102328:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010232b:	8b 17                	mov    (%edi),%edx
f010232d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102333:	89 f0                	mov    %esi,%eax
f0102335:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0102338:	c1 f8 03             	sar    $0x3,%eax
f010233b:	c1 e0 0c             	shl    $0xc,%eax
f010233e:	39 c2                	cmp    %eax,%edx
f0102340:	74 24                	je     f0102366 <mem_init+0x8ad>
f0102342:	c7 44 24 0c c0 7c 10 	movl   $0xf0107cc0,0xc(%esp)
f0102349:	f0 
f010234a:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102351:	f0 
f0102352:	c7 44 24 04 99 04 00 	movl   $0x499,0x4(%esp)
f0102359:	00 
f010235a:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102361:	e8 da dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102366:	ba 00 00 00 00       	mov    $0x0,%edx
f010236b:	89 f8                	mov    %edi,%eax
f010236d:	e8 7e ea ff ff       	call   f0100df0 <check_va2pa>
f0102372:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102375:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0102378:	c1 fa 03             	sar    $0x3,%edx
f010237b:	c1 e2 0c             	shl    $0xc,%edx
f010237e:	39 d0                	cmp    %edx,%eax
f0102380:	74 24                	je     f01023a6 <mem_init+0x8ed>
f0102382:	c7 44 24 0c e8 7c 10 	movl   $0xf0107ce8,0xc(%esp)
f0102389:	f0 
f010238a:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102391:	f0 
f0102392:	c7 44 24 04 9a 04 00 	movl   $0x49a,0x4(%esp)
f0102399:	00 
f010239a:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01023a1:	e8 9a dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01023a6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023a9:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01023ae:	74 24                	je     f01023d4 <mem_init+0x91b>
f01023b0:	c7 44 24 0c 29 86 10 	movl   $0xf0108629,0xc(%esp)
f01023b7:	f0 
f01023b8:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01023bf:	f0 
f01023c0:	c7 44 24 04 9b 04 00 	movl   $0x49b,0x4(%esp)
f01023c7:	00 
f01023c8:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01023cf:	e8 6c dc ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01023d4:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01023d9:	74 24                	je     f01023ff <mem_init+0x946>
f01023db:	c7 44 24 0c 3a 86 10 	movl   $0xf010863a,0xc(%esp)
f01023e2:	f0 
f01023e3:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01023ea:	f0 
f01023eb:	c7 44 24 04 9c 04 00 	movl   $0x49c,0x4(%esp)
f01023f2:	00 
f01023f3:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01023fa:	e8 41 dc ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01023ff:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102406:	00 
f0102407:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010240e:	00 
f010240f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102413:	89 3c 24             	mov    %edi,(%esp)
f0102416:	e8 6e f5 ff ff       	call   f0101989 <page_insert>
f010241b:	85 c0                	test   %eax,%eax
f010241d:	74 24                	je     f0102443 <mem_init+0x98a>
f010241f:	c7 44 24 0c 18 7d 10 	movl   $0xf0107d18,0xc(%esp)
f0102426:	f0 
f0102427:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010242e:	f0 
f010242f:	c7 44 24 04 9f 04 00 	movl   $0x49f,0x4(%esp)
f0102436:	00 
f0102437:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f010243e:	e8 fd db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102443:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102448:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f010244d:	e8 9e e9 ff ff       	call   f0100df0 <check_va2pa>
f0102452:	89 da                	mov    %ebx,%edx
f0102454:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f010245a:	c1 fa 03             	sar    $0x3,%edx
f010245d:	c1 e2 0c             	shl    $0xc,%edx
f0102460:	39 d0                	cmp    %edx,%eax
f0102462:	74 24                	je     f0102488 <mem_init+0x9cf>
f0102464:	c7 44 24 0c 54 7d 10 	movl   $0xf0107d54,0xc(%esp)
f010246b:	f0 
f010246c:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102473:	f0 
f0102474:	c7 44 24 04 a0 04 00 	movl   $0x4a0,0x4(%esp)
f010247b:	00 
f010247c:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102483:	e8 b8 db ff ff       	call   f0100040 <_panic>
	
	assert(pp2->pp_ref == 1);
f0102488:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010248d:	74 24                	je     f01024b3 <mem_init+0x9fa>
f010248f:	c7 44 24 0c 4b 86 10 	movl   $0xf010864b,0xc(%esp)
f0102496:	f0 
f0102497:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010249e:	f0 
f010249f:	c7 44 24 04 a2 04 00 	movl   $0x4a2,0x4(%esp)
f01024a6:	00 
f01024a7:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01024ae:	e8 8d db ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01024b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01024ba:	e8 1f ef ff ff       	call   f01013de <page_alloc>
f01024bf:	85 c0                	test   %eax,%eax
f01024c1:	74 24                	je     f01024e7 <mem_init+0xa2e>
f01024c3:	c7 44 24 0c d7 85 10 	movl   $0xf01085d7,0xc(%esp)
f01024ca:	f0 
f01024cb:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01024d2:	f0 
f01024d3:	c7 44 24 04 a5 04 00 	movl   $0x4a5,0x4(%esp)
f01024da:	00 
f01024db:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01024e2:	e8 59 db ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	//cprintf("!!!%u\n", pp2->pp_ref);
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01024e7:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01024ee:	00 
f01024ef:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01024f6:	00 
f01024f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01024fb:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102500:	89 04 24             	mov    %eax,(%esp)
f0102503:	e8 81 f4 ff ff       	call   f0101989 <page_insert>
f0102508:	85 c0                	test   %eax,%eax
f010250a:	74 24                	je     f0102530 <mem_init+0xa77>
f010250c:	c7 44 24 0c 18 7d 10 	movl   $0xf0107d18,0xc(%esp)
f0102513:	f0 
f0102514:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010251b:	f0 
f010251c:	c7 44 24 04 a9 04 00 	movl   $0x4a9,0x4(%esp)
f0102523:	00 
f0102524:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f010252b:	e8 10 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102530:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102535:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f010253a:	e8 b1 e8 ff ff       	call   f0100df0 <check_va2pa>
f010253f:	89 da                	mov    %ebx,%edx
f0102541:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0102547:	c1 fa 03             	sar    $0x3,%edx
f010254a:	c1 e2 0c             	shl    $0xc,%edx
f010254d:	39 d0                	cmp    %edx,%eax
f010254f:	74 24                	je     f0102575 <mem_init+0xabc>
f0102551:	c7 44 24 0c 54 7d 10 	movl   $0xf0107d54,0xc(%esp)
f0102558:	f0 
f0102559:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102560:	f0 
f0102561:	c7 44 24 04 aa 04 00 	movl   $0x4aa,0x4(%esp)
f0102568:	00 
f0102569:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102570:	e8 cb da ff ff       	call   f0100040 <_panic>
	//cprintf("!!!%u\n", pp2->pp_ref);
	assert(pp2->pp_ref == 1);
f0102575:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010257a:	74 24                	je     f01025a0 <mem_init+0xae7>
f010257c:	c7 44 24 0c 4b 86 10 	movl   $0xf010864b,0xc(%esp)
f0102583:	f0 
f0102584:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010258b:	f0 
f010258c:	c7 44 24 04 ac 04 00 	movl   $0x4ac,0x4(%esp)
f0102593:	00 
f0102594:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f010259b:	e8 a0 da ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01025a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01025a7:	e8 32 ee ff ff       	call   f01013de <page_alloc>
f01025ac:	85 c0                	test   %eax,%eax
f01025ae:	74 24                	je     f01025d4 <mem_init+0xb1b>
f01025b0:	c7 44 24 0c d7 85 10 	movl   $0xf01085d7,0xc(%esp)
f01025b7:	f0 
f01025b8:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01025bf:	f0 
f01025c0:	c7 44 24 04 b0 04 00 	movl   $0x4b0,0x4(%esp)
f01025c7:	00 
f01025c8:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01025cf:	e8 6c da ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01025d4:	8b 15 8c be 22 f0    	mov    0xf022be8c,%edx
f01025da:	8b 02                	mov    (%edx),%eax
f01025dc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01025e1:	89 c1                	mov    %eax,%ecx
f01025e3:	c1 e9 0c             	shr    $0xc,%ecx
f01025e6:	3b 0d 88 be 22 f0    	cmp    0xf022be88,%ecx
f01025ec:	72 20                	jb     f010260e <mem_init+0xb55>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01025f2:	c7 44 24 08 68 74 10 	movl   $0xf0107468,0x8(%esp)
f01025f9:	f0 
f01025fa:	c7 44 24 04 b3 04 00 	movl   $0x4b3,0x4(%esp)
f0102601:	00 
f0102602:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102609:	e8 32 da ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010260e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102613:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102616:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010261d:	00 
f010261e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102625:	00 
f0102626:	89 14 24             	mov    %edx,(%esp)
f0102629:	e8 9b ee ff ff       	call   f01014c9 <pgdir_walk>
f010262e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102631:	83 c2 04             	add    $0x4,%edx
f0102634:	39 d0                	cmp    %edx,%eax
f0102636:	74 24                	je     f010265c <mem_init+0xba3>
f0102638:	c7 44 24 0c 84 7d 10 	movl   $0xf0107d84,0xc(%esp)
f010263f:	f0 
f0102640:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102647:	f0 
f0102648:	c7 44 24 04 b4 04 00 	movl   $0x4b4,0x4(%esp)
f010264f:	00 
f0102650:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102657:	e8 e4 d9 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010265c:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0102663:	00 
f0102664:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010266b:	00 
f010266c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102670:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102675:	89 04 24             	mov    %eax,(%esp)
f0102678:	e8 0c f3 ff ff       	call   f0101989 <page_insert>
f010267d:	85 c0                	test   %eax,%eax
f010267f:	74 24                	je     f01026a5 <mem_init+0xbec>
f0102681:	c7 44 24 0c c4 7d 10 	movl   $0xf0107dc4,0xc(%esp)
f0102688:	f0 
f0102689:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102690:	f0 
f0102691:	c7 44 24 04 b7 04 00 	movl   $0x4b7,0x4(%esp)
f0102698:	00 
f0102699:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01026a0:	e8 9b d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01026a5:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f01026ab:	ba 00 10 00 00       	mov    $0x1000,%edx
f01026b0:	89 f8                	mov    %edi,%eax
f01026b2:	e8 39 e7 ff ff       	call   f0100df0 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01026b7:	89 da                	mov    %ebx,%edx
f01026b9:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f01026bf:	c1 fa 03             	sar    $0x3,%edx
f01026c2:	c1 e2 0c             	shl    $0xc,%edx
f01026c5:	39 d0                	cmp    %edx,%eax
f01026c7:	74 24                	je     f01026ed <mem_init+0xc34>
f01026c9:	c7 44 24 0c 54 7d 10 	movl   $0xf0107d54,0xc(%esp)
f01026d0:	f0 
f01026d1:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01026d8:	f0 
f01026d9:	c7 44 24 04 b8 04 00 	movl   $0x4b8,0x4(%esp)
f01026e0:	00 
f01026e1:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01026e8:	e8 53 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01026ed:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01026f2:	74 24                	je     f0102718 <mem_init+0xc5f>
f01026f4:	c7 44 24 0c 4b 86 10 	movl   $0xf010864b,0xc(%esp)
f01026fb:	f0 
f01026fc:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102703:	f0 
f0102704:	c7 44 24 04 b9 04 00 	movl   $0x4b9,0x4(%esp)
f010270b:	00 
f010270c:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102713:	e8 28 d9 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102718:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010271f:	00 
f0102720:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102727:	00 
f0102728:	89 3c 24             	mov    %edi,(%esp)
f010272b:	e8 99 ed ff ff       	call   f01014c9 <pgdir_walk>
f0102730:	f6 00 04             	testb  $0x4,(%eax)
f0102733:	75 24                	jne    f0102759 <mem_init+0xca0>
f0102735:	c7 44 24 0c 04 7e 10 	movl   $0xf0107e04,0xc(%esp)
f010273c:	f0 
f010273d:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102744:	f0 
f0102745:	c7 44 24 04 ba 04 00 	movl   $0x4ba,0x4(%esp)
f010274c:	00 
f010274d:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102754:	e8 e7 d8 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102759:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f010275e:	f6 00 04             	testb  $0x4,(%eax)
f0102761:	75 24                	jne    f0102787 <mem_init+0xcce>
f0102763:	c7 44 24 0c 5c 86 10 	movl   $0xf010865c,0xc(%esp)
f010276a:	f0 
f010276b:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102772:	f0 
f0102773:	c7 44 24 04 bb 04 00 	movl   $0x4bb,0x4(%esp)
f010277a:	00 
f010277b:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102782:	e8 b9 d8 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102787:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010278e:	00 
f010278f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102796:	00 
f0102797:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010279b:	89 04 24             	mov    %eax,(%esp)
f010279e:	e8 e6 f1 ff ff       	call   f0101989 <page_insert>
f01027a3:	85 c0                	test   %eax,%eax
f01027a5:	74 24                	je     f01027cb <mem_init+0xd12>
f01027a7:	c7 44 24 0c 18 7d 10 	movl   $0xf0107d18,0xc(%esp)
f01027ae:	f0 
f01027af:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01027b6:	f0 
f01027b7:	c7 44 24 04 be 04 00 	movl   $0x4be,0x4(%esp)
f01027be:	00 
f01027bf:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01027c6:	e8 75 d8 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01027cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01027d2:	00 
f01027d3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01027da:	00 
f01027db:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01027e0:	89 04 24             	mov    %eax,(%esp)
f01027e3:	e8 e1 ec ff ff       	call   f01014c9 <pgdir_walk>
f01027e8:	f6 00 02             	testb  $0x2,(%eax)
f01027eb:	75 24                	jne    f0102811 <mem_init+0xd58>
f01027ed:	c7 44 24 0c 38 7e 10 	movl   $0xf0107e38,0xc(%esp)
f01027f4:	f0 
f01027f5:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01027fc:	f0 
f01027fd:	c7 44 24 04 bf 04 00 	movl   $0x4bf,0x4(%esp)
f0102804:	00 
f0102805:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f010280c:	e8 2f d8 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102811:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102818:	00 
f0102819:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102820:	00 
f0102821:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102826:	89 04 24             	mov    %eax,(%esp)
f0102829:	e8 9b ec ff ff       	call   f01014c9 <pgdir_walk>
f010282e:	f6 00 04             	testb  $0x4,(%eax)
f0102831:	74 24                	je     f0102857 <mem_init+0xd9e>
f0102833:	c7 44 24 0c 6c 7e 10 	movl   $0xf0107e6c,0xc(%esp)
f010283a:	f0 
f010283b:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102842:	f0 
f0102843:	c7 44 24 04 c0 04 00 	movl   $0x4c0,0x4(%esp)
f010284a:	00 
f010284b:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102852:	e8 e9 d7 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102857:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010285e:	00 
f010285f:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102866:	00 
f0102867:	89 74 24 04          	mov    %esi,0x4(%esp)
f010286b:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102870:	89 04 24             	mov    %eax,(%esp)
f0102873:	e8 11 f1 ff ff       	call   f0101989 <page_insert>
f0102878:	85 c0                	test   %eax,%eax
f010287a:	78 24                	js     f01028a0 <mem_init+0xde7>
f010287c:	c7 44 24 0c a4 7e 10 	movl   $0xf0107ea4,0xc(%esp)
f0102883:	f0 
f0102884:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010288b:	f0 
f010288c:	c7 44 24 04 c3 04 00 	movl   $0x4c3,0x4(%esp)
f0102893:	00 
f0102894:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f010289b:	e8 a0 d7 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01028a0:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01028a7:	00 
f01028a8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01028af:	00 
f01028b0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01028b3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01028b7:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01028bc:	89 04 24             	mov    %eax,(%esp)
f01028bf:	e8 c5 f0 ff ff       	call   f0101989 <page_insert>
f01028c4:	85 c0                	test   %eax,%eax
f01028c6:	74 24                	je     f01028ec <mem_init+0xe33>
f01028c8:	c7 44 24 0c dc 7e 10 	movl   $0xf0107edc,0xc(%esp)
f01028cf:	f0 
f01028d0:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01028d7:	f0 
f01028d8:	c7 44 24 04 c6 04 00 	movl   $0x4c6,0x4(%esp)
f01028df:	00 
f01028e0:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01028e7:	e8 54 d7 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01028ec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01028f3:	00 
f01028f4:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01028fb:	00 
f01028fc:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102901:	89 04 24             	mov    %eax,(%esp)
f0102904:	e8 c0 eb ff ff       	call   f01014c9 <pgdir_walk>
f0102909:	f6 00 04             	testb  $0x4,(%eax)
f010290c:	74 24                	je     f0102932 <mem_init+0xe79>
f010290e:	c7 44 24 0c 6c 7e 10 	movl   $0xf0107e6c,0xc(%esp)
f0102915:	f0 
f0102916:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010291d:	f0 
f010291e:	c7 44 24 04 c7 04 00 	movl   $0x4c7,0x4(%esp)
f0102925:	00 
f0102926:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f010292d:	e8 0e d7 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102932:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f0102938:	ba 00 00 00 00       	mov    $0x0,%edx
f010293d:	89 f8                	mov    %edi,%eax
f010293f:	e8 ac e4 ff ff       	call   f0100df0 <check_va2pa>
f0102944:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102947:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010294a:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0102950:	c1 f8 03             	sar    $0x3,%eax
f0102953:	c1 e0 0c             	shl    $0xc,%eax
f0102956:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102959:	74 24                	je     f010297f <mem_init+0xec6>
f010295b:	c7 44 24 0c 18 7f 10 	movl   $0xf0107f18,0xc(%esp)
f0102962:	f0 
f0102963:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010296a:	f0 
f010296b:	c7 44 24 04 ca 04 00 	movl   $0x4ca,0x4(%esp)
f0102972:	00 
f0102973:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f010297a:	e8 c1 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010297f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102984:	89 f8                	mov    %edi,%eax
f0102986:	e8 65 e4 ff ff       	call   f0100df0 <check_va2pa>
f010298b:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010298e:	74 24                	je     f01029b4 <mem_init+0xefb>
f0102990:	c7 44 24 0c 44 7f 10 	movl   $0xf0107f44,0xc(%esp)
f0102997:	f0 
f0102998:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010299f:	f0 
f01029a0:	c7 44 24 04 cb 04 00 	movl   $0x4cb,0x4(%esp)
f01029a7:	00 
f01029a8:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01029af:	e8 8c d6 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01029b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01029b7:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f01029bc:	74 24                	je     f01029e2 <mem_init+0xf29>
f01029be:	c7 44 24 0c 72 86 10 	movl   $0xf0108672,0xc(%esp)
f01029c5:	f0 
f01029c6:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01029cd:	f0 
f01029ce:	c7 44 24 04 cd 04 00 	movl   $0x4cd,0x4(%esp)
f01029d5:	00 
f01029d6:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01029dd:	e8 5e d6 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01029e2:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01029e7:	74 24                	je     f0102a0d <mem_init+0xf54>
f01029e9:	c7 44 24 0c 83 86 10 	movl   $0xf0108683,0xc(%esp)
f01029f0:	f0 
f01029f1:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01029f8:	f0 
f01029f9:	c7 44 24 04 ce 04 00 	movl   $0x4ce,0x4(%esp)
f0102a00:	00 
f0102a01:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102a08:	e8 33 d6 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102a0d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a14:	e8 c5 e9 ff ff       	call   f01013de <page_alloc>
f0102a19:	85 c0                	test   %eax,%eax
f0102a1b:	74 04                	je     f0102a21 <mem_init+0xf68>
f0102a1d:	39 c3                	cmp    %eax,%ebx
f0102a1f:	74 24                	je     f0102a45 <mem_init+0xf8c>
f0102a21:	c7 44 24 0c 74 7f 10 	movl   $0xf0107f74,0xc(%esp)
f0102a28:	f0 
f0102a29:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102a30:	f0 
f0102a31:	c7 44 24 04 d1 04 00 	movl   $0x4d1,0x4(%esp)
f0102a38:	00 
f0102a39:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102a40:	e8 fb d5 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102a45:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102a4c:	00 
f0102a4d:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102a52:	89 04 24             	mov    %eax,(%esp)
f0102a55:	e8 c5 ee ff ff       	call   f010191f <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102a5a:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f0102a60:	ba 00 00 00 00       	mov    $0x0,%edx
f0102a65:	89 f8                	mov    %edi,%eax
f0102a67:	e8 84 e3 ff ff       	call   f0100df0 <check_va2pa>
f0102a6c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a6f:	74 24                	je     f0102a95 <mem_init+0xfdc>
f0102a71:	c7 44 24 0c 98 7f 10 	movl   $0xf0107f98,0xc(%esp)
f0102a78:	f0 
f0102a79:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102a80:	f0 
f0102a81:	c7 44 24 04 d5 04 00 	movl   $0x4d5,0x4(%esp)
f0102a88:	00 
f0102a89:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102a90:	e8 ab d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102a95:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102a9a:	89 f8                	mov    %edi,%eax
f0102a9c:	e8 4f e3 ff ff       	call   f0100df0 <check_va2pa>
f0102aa1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102aa4:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0102aaa:	c1 fa 03             	sar    $0x3,%edx
f0102aad:	c1 e2 0c             	shl    $0xc,%edx
f0102ab0:	39 d0                	cmp    %edx,%eax
f0102ab2:	74 24                	je     f0102ad8 <mem_init+0x101f>
f0102ab4:	c7 44 24 0c 44 7f 10 	movl   $0xf0107f44,0xc(%esp)
f0102abb:	f0 
f0102abc:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102ac3:	f0 
f0102ac4:	c7 44 24 04 d6 04 00 	movl   $0x4d6,0x4(%esp)
f0102acb:	00 
f0102acc:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102ad3:	e8 68 d5 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102ad8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102adb:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102ae0:	74 24                	je     f0102b06 <mem_init+0x104d>
f0102ae2:	c7 44 24 0c 29 86 10 	movl   $0xf0108629,0xc(%esp)
f0102ae9:	f0 
f0102aea:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102af1:	f0 
f0102af2:	c7 44 24 04 d7 04 00 	movl   $0x4d7,0x4(%esp)
f0102af9:	00 
f0102afa:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102b01:	e8 3a d5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102b06:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102b0b:	74 24                	je     f0102b31 <mem_init+0x1078>
f0102b0d:	c7 44 24 0c 83 86 10 	movl   $0xf0108683,0xc(%esp)
f0102b14:	f0 
f0102b15:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102b1c:	f0 
f0102b1d:	c7 44 24 04 d8 04 00 	movl   $0x4d8,0x4(%esp)
f0102b24:	00 
f0102b25:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102b2c:	e8 0f d5 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102b31:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102b38:	00 
f0102b39:	89 3c 24             	mov    %edi,(%esp)
f0102b3c:	e8 de ed ff ff       	call   f010191f <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102b41:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f0102b47:	ba 00 00 00 00       	mov    $0x0,%edx
f0102b4c:	89 f8                	mov    %edi,%eax
f0102b4e:	e8 9d e2 ff ff       	call   f0100df0 <check_va2pa>
f0102b53:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102b56:	74 24                	je     f0102b7c <mem_init+0x10c3>
f0102b58:	c7 44 24 0c 98 7f 10 	movl   $0xf0107f98,0xc(%esp)
f0102b5f:	f0 
f0102b60:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102b67:	f0 
f0102b68:	c7 44 24 04 dc 04 00 	movl   $0x4dc,0x4(%esp)
f0102b6f:	00 
f0102b70:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102b77:	e8 c4 d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102b7c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102b81:	89 f8                	mov    %edi,%eax
f0102b83:	e8 68 e2 ff ff       	call   f0100df0 <check_va2pa>
f0102b88:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102b8b:	74 24                	je     f0102bb1 <mem_init+0x10f8>
f0102b8d:	c7 44 24 0c bc 7f 10 	movl   $0xf0107fbc,0xc(%esp)
f0102b94:	f0 
f0102b95:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102b9c:	f0 
f0102b9d:	c7 44 24 04 dd 04 00 	movl   $0x4dd,0x4(%esp)
f0102ba4:	00 
f0102ba5:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102bac:	e8 8f d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102bb1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102bb4:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102bb9:	74 24                	je     f0102bdf <mem_init+0x1126>
f0102bbb:	c7 44 24 0c 94 86 10 	movl   $0xf0108694,0xc(%esp)
f0102bc2:	f0 
f0102bc3:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102bca:	f0 
f0102bcb:	c7 44 24 04 de 04 00 	movl   $0x4de,0x4(%esp)
f0102bd2:	00 
f0102bd3:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102bda:	e8 61 d4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102bdf:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102be4:	74 24                	je     f0102c0a <mem_init+0x1151>
f0102be6:	c7 44 24 0c 83 86 10 	movl   $0xf0108683,0xc(%esp)
f0102bed:	f0 
f0102bee:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102bf5:	f0 
f0102bf6:	c7 44 24 04 df 04 00 	movl   $0x4df,0x4(%esp)
f0102bfd:	00 
f0102bfe:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102c05:	e8 36 d4 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102c0a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c11:	e8 c8 e7 ff ff       	call   f01013de <page_alloc>
f0102c16:	85 c0                	test   %eax,%eax
f0102c18:	74 05                	je     f0102c1f <mem_init+0x1166>
f0102c1a:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0102c1d:	74 24                	je     f0102c43 <mem_init+0x118a>
f0102c1f:	c7 44 24 0c e4 7f 10 	movl   $0xf0107fe4,0xc(%esp)
f0102c26:	f0 
f0102c27:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102c2e:	f0 
f0102c2f:	c7 44 24 04 e2 04 00 	movl   $0x4e2,0x4(%esp)
f0102c36:	00 
f0102c37:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102c3e:	e8 fd d3 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102c43:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c4a:	e8 8f e7 ff ff       	call   f01013de <page_alloc>
f0102c4f:	85 c0                	test   %eax,%eax
f0102c51:	74 24                	je     f0102c77 <mem_init+0x11be>
f0102c53:	c7 44 24 0c d7 85 10 	movl   $0xf01085d7,0xc(%esp)
f0102c5a:	f0 
f0102c5b:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102c62:	f0 
f0102c63:	c7 44 24 04 e5 04 00 	movl   $0x4e5,0x4(%esp)
f0102c6a:	00 
f0102c6b:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102c72:	e8 c9 d3 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c77:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102c7c:	8b 08                	mov    (%eax),%ecx
f0102c7e:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102c84:	89 f2                	mov    %esi,%edx
f0102c86:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0102c8c:	c1 fa 03             	sar    $0x3,%edx
f0102c8f:	c1 e2 0c             	shl    $0xc,%edx
f0102c92:	39 d1                	cmp    %edx,%ecx
f0102c94:	74 24                	je     f0102cba <mem_init+0x1201>
f0102c96:	c7 44 24 0c c0 7c 10 	movl   $0xf0107cc0,0xc(%esp)
f0102c9d:	f0 
f0102c9e:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102ca5:	f0 
f0102ca6:	c7 44 24 04 e8 04 00 	movl   $0x4e8,0x4(%esp)
f0102cad:	00 
f0102cae:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102cb5:	e8 86 d3 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102cba:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102cc0:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102cc5:	74 24                	je     f0102ceb <mem_init+0x1232>
f0102cc7:	c7 44 24 0c 3a 86 10 	movl   $0xf010863a,0xc(%esp)
f0102cce:	f0 
f0102ccf:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102cd6:	f0 
f0102cd7:	c7 44 24 04 ea 04 00 	movl   $0x4ea,0x4(%esp)
f0102cde:	00 
f0102cdf:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102ce6:	e8 55 d3 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102ceb:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102cf1:	89 34 24             	mov    %esi,(%esp)
f0102cf4:	e8 63 e7 ff ff       	call   f010145c <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102cf9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102d00:	00 
f0102d01:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102d08:	00 
f0102d09:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102d0e:	89 04 24             	mov    %eax,(%esp)
f0102d11:	e8 b3 e7 ff ff       	call   f01014c9 <pgdir_walk>
f0102d16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102d19:	8b 15 8c be 22 f0    	mov    0xf022be8c,%edx
f0102d1f:	8b 4a 04             	mov    0x4(%edx),%ecx
f0102d22:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102d28:	89 4d cc             	mov    %ecx,-0x34(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d2b:	8b 0d 88 be 22 f0    	mov    0xf022be88,%ecx
f0102d31:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102d34:	c1 ef 0c             	shr    $0xc,%edi
f0102d37:	39 cf                	cmp    %ecx,%edi
f0102d39:	72 23                	jb     f0102d5e <mem_init+0x12a5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d3b:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102d3e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d42:	c7 44 24 08 68 74 10 	movl   $0xf0107468,0x8(%esp)
f0102d49:	f0 
f0102d4a:	c7 44 24 04 f1 04 00 	movl   $0x4f1,0x4(%esp)
f0102d51:	00 
f0102d52:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102d59:	e8 e2 d2 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102d5e:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102d61:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f0102d67:	39 f8                	cmp    %edi,%eax
f0102d69:	74 24                	je     f0102d8f <mem_init+0x12d6>
f0102d6b:	c7 44 24 0c a5 86 10 	movl   $0xf01086a5,0xc(%esp)
f0102d72:	f0 
f0102d73:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102d7a:	f0 
f0102d7b:	c7 44 24 04 f2 04 00 	movl   $0x4f2,0x4(%esp)
f0102d82:	00 
f0102d83:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102d8a:	e8 b1 d2 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102d8f:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
	pp0->pp_ref = 0;
f0102d96:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d9c:	89 f0                	mov    %esi,%eax
f0102d9e:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0102da4:	c1 f8 03             	sar    $0x3,%eax
f0102da7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102daa:	89 c2                	mov    %eax,%edx
f0102dac:	c1 ea 0c             	shr    $0xc,%edx
f0102daf:	39 d1                	cmp    %edx,%ecx
f0102db1:	77 20                	ja     f0102dd3 <mem_init+0x131a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102db3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102db7:	c7 44 24 08 68 74 10 	movl   $0xf0107468,0x8(%esp)
f0102dbe:	f0 
f0102dbf:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
f0102dc6:	00 
f0102dc7:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f0102dce:	e8 6d d2 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102dd3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102dda:	00 
f0102ddb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102de2:	00 
	return (void *)(pa + KERNBASE);
f0102de3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102de8:	89 04 24             	mov    %eax,(%esp)
f0102deb:	e8 15 38 00 00       	call   f0106605 <memset>
	page_free(pp0);
f0102df0:	89 34 24             	mov    %esi,(%esp)
f0102df3:	e8 64 e6 ff ff       	call   f010145c <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102df8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102dff:	00 
f0102e00:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102e07:	00 
f0102e08:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102e0d:	89 04 24             	mov    %eax,(%esp)
f0102e10:	e8 b4 e6 ff ff       	call   f01014c9 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102e15:	89 f2                	mov    %esi,%edx
f0102e17:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0102e1d:	c1 fa 03             	sar    $0x3,%edx
f0102e20:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e23:	89 d0                	mov    %edx,%eax
f0102e25:	c1 e8 0c             	shr    $0xc,%eax
f0102e28:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0102e2e:	72 20                	jb     f0102e50 <mem_init+0x1397>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e30:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102e34:	c7 44 24 08 68 74 10 	movl   $0xf0107468,0x8(%esp)
f0102e3b:	f0 
f0102e3c:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
f0102e43:	00 
f0102e44:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f0102e4b:	e8 f0 d1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102e50:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102e56:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102e59:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102e60:	75 11                	jne    f0102e73 <mem_init+0x13ba>
f0102e62:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102e68:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102e6e:	f6 00 01             	testb  $0x1,(%eax)
f0102e71:	74 24                	je     f0102e97 <mem_init+0x13de>
f0102e73:	c7 44 24 0c bd 86 10 	movl   $0xf01086bd,0xc(%esp)
f0102e7a:	f0 
f0102e7b:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102e82:	f0 
f0102e83:	c7 44 24 04 fc 04 00 	movl   $0x4fc,0x4(%esp)
f0102e8a:	00 
f0102e8b:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102e92:	e8 a9 d1 ff ff       	call   f0100040 <_panic>
f0102e97:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102e9a:	39 d0                	cmp    %edx,%eax
f0102e9c:	75 d0                	jne    f0102e6e <mem_init+0x13b5>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102e9e:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102ea3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102ea9:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102eaf:	8b 7d c8             	mov    -0x38(%ebp),%edi
f0102eb2:	89 3d 44 b2 22 f0    	mov    %edi,0xf022b244

	// free the pages we took
	page_free(pp0);
f0102eb8:	89 34 24             	mov    %esi,(%esp)
f0102ebb:	e8 9c e5 ff ff       	call   f010145c <page_free>
	page_free(pp1);
f0102ec0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102ec3:	89 04 24             	mov    %eax,(%esp)
f0102ec6:	e8 91 e5 ff ff       	call   f010145c <page_free>
	page_free(pp2);
f0102ecb:	89 1c 24             	mov    %ebx,(%esp)
f0102ece:	e8 89 e5 ff ff       	call   f010145c <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102ed3:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102eda:	00 
f0102edb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ee2:	e8 63 eb ff ff       	call   f0101a4a <mmio_map_region>
f0102ee7:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102ee9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102ef0:	00 
f0102ef1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ef8:	e8 4d eb ff ff       	call   f0101a4a <mmio_map_region>
f0102efd:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102eff:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102f05:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102f0a:	77 08                	ja     f0102f14 <mem_init+0x145b>
f0102f0c:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102f12:	77 24                	ja     f0102f38 <mem_init+0x147f>
f0102f14:	c7 44 24 0c 08 80 10 	movl   $0xf0108008,0xc(%esp)
f0102f1b:	f0 
f0102f1c:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102f23:	f0 
f0102f24:	c7 44 24 04 0c 05 00 	movl   $0x50c,0x4(%esp)
f0102f2b:	00 
f0102f2c:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102f33:	e8 08 d1 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102f38:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102f3e:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102f44:	77 08                	ja     f0102f4e <mem_init+0x1495>
f0102f46:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102f4c:	77 24                	ja     f0102f72 <mem_init+0x14b9>
f0102f4e:	c7 44 24 0c 30 80 10 	movl   $0xf0108030,0xc(%esp)
f0102f55:	f0 
f0102f56:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102f5d:	f0 
f0102f5e:	c7 44 24 04 0d 05 00 	movl   $0x50d,0x4(%esp)
f0102f65:	00 
f0102f66:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102f6d:	e8 ce d0 ff ff       	call   f0100040 <_panic>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102f72:	89 f2                	mov    %esi,%edx
f0102f74:	09 da                	or     %ebx,%edx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102f76:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102f7c:	74 24                	je     f0102fa2 <mem_init+0x14e9>
f0102f7e:	c7 44 24 0c 58 80 10 	movl   $0xf0108058,0xc(%esp)
f0102f85:	f0 
f0102f86:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102f8d:	f0 
f0102f8e:	c7 44 24 04 0f 05 00 	movl   $0x50f,0x4(%esp)
f0102f95:	00 
f0102f96:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102f9d:	e8 9e d0 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102fa2:	39 c6                	cmp    %eax,%esi
f0102fa4:	73 24                	jae    f0102fca <mem_init+0x1511>
f0102fa6:	c7 44 24 0c d4 86 10 	movl   $0xf01086d4,0xc(%esp)
f0102fad:	f0 
f0102fae:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102fb5:	f0 
f0102fb6:	c7 44 24 04 11 05 00 	movl   $0x511,0x4(%esp)
f0102fbd:	00 
f0102fbe:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102fc5:	e8 76 d0 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102fca:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f0102fd0:	89 da                	mov    %ebx,%edx
f0102fd2:	89 f8                	mov    %edi,%eax
f0102fd4:	e8 17 de ff ff       	call   f0100df0 <check_va2pa>
f0102fd9:	85 c0                	test   %eax,%eax
f0102fdb:	74 24                	je     f0103001 <mem_init+0x1548>
f0102fdd:	c7 44 24 0c 80 80 10 	movl   $0xf0108080,0xc(%esp)
f0102fe4:	f0 
f0102fe5:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102fec:	f0 
f0102fed:	c7 44 24 04 13 05 00 	movl   $0x513,0x4(%esp)
f0102ff4:	00 
f0102ff5:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0102ffc:	e8 3f d0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0103001:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
f0103007:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010300a:	89 f8                	mov    %edi,%eax
f010300c:	e8 df dd ff ff       	call   f0100df0 <check_va2pa>
f0103011:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103016:	74 24                	je     f010303c <mem_init+0x1583>
f0103018:	c7 44 24 0c a4 80 10 	movl   $0xf01080a4,0xc(%esp)
f010301f:	f0 
f0103020:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0103027:	f0 
f0103028:	c7 44 24 04 14 05 00 	movl   $0x514,0x4(%esp)
f010302f:	00 
f0103030:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0103037:	e8 04 d0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010303c:	89 f2                	mov    %esi,%edx
f010303e:	89 f8                	mov    %edi,%eax
f0103040:	e8 ab dd ff ff       	call   f0100df0 <check_va2pa>
f0103045:	85 c0                	test   %eax,%eax
f0103047:	74 24                	je     f010306d <mem_init+0x15b4>
f0103049:	c7 44 24 0c d4 80 10 	movl   $0xf01080d4,0xc(%esp)
f0103050:	f0 
f0103051:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0103058:	f0 
f0103059:	c7 44 24 04 15 05 00 	movl   $0x515,0x4(%esp)
f0103060:	00 
f0103061:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0103068:	e8 d3 cf ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010306d:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0103073:	89 f8                	mov    %edi,%eax
f0103075:	e8 76 dd ff ff       	call   f0100df0 <check_va2pa>
f010307a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010307d:	74 24                	je     f01030a3 <mem_init+0x15ea>
f010307f:	c7 44 24 0c f8 80 10 	movl   $0xf01080f8,0xc(%esp)
f0103086:	f0 
f0103087:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010308e:	f0 
f010308f:	c7 44 24 04 16 05 00 	movl   $0x516,0x4(%esp)
f0103096:	00 
f0103097:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f010309e:	e8 9d cf ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01030a3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01030aa:	00 
f01030ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01030af:	89 3c 24             	mov    %edi,(%esp)
f01030b2:	e8 12 e4 ff ff       	call   f01014c9 <pgdir_walk>
f01030b7:	f6 00 1a             	testb  $0x1a,(%eax)
f01030ba:	75 24                	jne    f01030e0 <mem_init+0x1627>
f01030bc:	c7 44 24 0c 24 81 10 	movl   $0xf0108124,0xc(%esp)
f01030c3:	f0 
f01030c4:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01030cb:	f0 
f01030cc:	c7 44 24 04 18 05 00 	movl   $0x518,0x4(%esp)
f01030d3:	00 
f01030d4:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01030db:	e8 60 cf ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01030e0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01030e7:	00 
f01030e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01030ec:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01030f1:	89 04 24             	mov    %eax,(%esp)
f01030f4:	e8 d0 e3 ff ff       	call   f01014c9 <pgdir_walk>
f01030f9:	f6 00 04             	testb  $0x4,(%eax)
f01030fc:	74 24                	je     f0103122 <mem_init+0x1669>
f01030fe:	c7 44 24 0c 68 81 10 	movl   $0xf0108168,0xc(%esp)
f0103105:	f0 
f0103106:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010310d:	f0 
f010310e:	c7 44 24 04 19 05 00 	movl   $0x519,0x4(%esp)
f0103115:	00 
f0103116:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f010311d:	e8 1e cf ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0103122:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103129:	00 
f010312a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010312e:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0103133:	89 04 24             	mov    %eax,(%esp)
f0103136:	e8 8e e3 ff ff       	call   f01014c9 <pgdir_walk>
f010313b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0103141:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103148:	00 
f0103149:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010314c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103150:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0103155:	89 04 24             	mov    %eax,(%esp)
f0103158:	e8 6c e3 ff ff       	call   f01014c9 <pgdir_walk>
f010315d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0103163:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010316a:	00 
f010316b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010316f:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0103174:	89 04 24             	mov    %eax,(%esp)
f0103177:	e8 4d e3 ff ff       	call   f01014c9 <pgdir_walk>
f010317c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0103182:	c7 04 24 e6 86 10 f0 	movl   $0xf01086e6,(%esp)
f0103189:	e8 10 15 00 00       	call   f010469e <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	
	uint32_t map_size = ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE);
f010318e:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f0103193:	8d 1c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ebx
f010319a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	boot_map_region(kern_pgdir, UPAGES, map_size, PADDR(pages),
f01031a0:	a1 90 be 22 f0       	mov    0xf022be90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031a5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031aa:	77 20                	ja     f01031cc <mem_init+0x1713>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01031b0:	c7 44 24 08 44 74 10 	movl   $0xf0107444,0x8(%esp)
f01031b7:	f0 
f01031b8:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
f01031bf:	00 
f01031c0:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01031c7:	e8 74 ce ff ff       	call   f0100040 <_panic>
f01031cc:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f01031d3:	00 
	return (physaddr_t)kva - KERNBASE;
f01031d4:	05 00 00 00 10       	add    $0x10000000,%eax
f01031d9:	89 04 24             	mov    %eax,(%esp)
f01031dc:	89 d9                	mov    %ebx,%ecx
f01031de:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01031e3:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01031e8:	e8 2e e6 ff ff       	call   f010181b <boot_map_region>
					PTE_U | PTE_P);

	
	boot_map_region(kern_pgdir, PADDR(pages), map_size, PADDR(pages),
f01031ed:	a1 90 be 22 f0       	mov    0xf022be90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031f2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031f7:	77 20                	ja     f0103219 <mem_init+0x1760>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01031fd:	c7 44 24 08 44 74 10 	movl   $0xf0107444,0x8(%esp)
f0103204:	f0 
f0103205:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
f010320c:	00 
f010320d:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0103214:	e8 27 ce ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103219:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010321f:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0103226:	00 
f0103227:	89 14 24             	mov    %edx,(%esp)
f010322a:	89 d9                	mov    %ebx,%ecx
f010322c:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0103231:	e8 e5 e5 ff ff       	call   f010181b <boot_map_region>
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	
	uint32_t map_size_env = ROUNDUP(NENV * sizeof(struct Env), PGSIZE);
	boot_map_region(kern_pgdir, UENVS, map_size_env, PADDR(envs),
f0103236:	a1 4c b2 22 f0       	mov    0xf022b24c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010323b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103240:	77 20                	ja     f0103262 <mem_init+0x17a9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103242:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103246:	c7 44 24 08 44 74 10 	movl   $0xf0107444,0x8(%esp)
f010324d:	f0 
f010324e:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
f0103255:	00 
f0103256:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f010325d:	e8 de cd ff ff       	call   f0100040 <_panic>
f0103262:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0103269:	00 
	return (physaddr_t)kva - KERNBASE;
f010326a:	05 00 00 00 10       	add    $0x10000000,%eax
f010326f:	89 04 24             	mov    %eax,(%esp)
f0103272:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0103277:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010327c:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0103281:	e8 95 e5 ff ff       	call   f010181b <boot_map_region>
					PTE_U | PTE_P);

	
	boot_map_region(kern_pgdir, PADDR(envs), map_size_env, PADDR(envs),
f0103286:	a1 4c b2 22 f0       	mov    0xf022b24c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010328b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103290:	77 20                	ja     f01032b2 <mem_init+0x17f9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103292:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103296:	c7 44 24 08 44 74 10 	movl   $0xf0107444,0x8(%esp)
f010329d:	f0 
f010329e:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
f01032a5:	00 
f01032a6:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01032ad:	e8 8e cd ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01032b2:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01032b8:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01032bf:	00 
f01032c0:	89 14 24             	mov    %edx,(%esp)
f01032c3:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f01032c8:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01032cd:	e8 49 e5 ff ff       	call   f010181b <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032d2:	b8 00 90 11 f0       	mov    $0xf0119000,%eax
f01032d7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032dc:	77 20                	ja     f01032fe <mem_init+0x1845>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032de:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01032e2:	c7 44 24 08 44 74 10 	movl   $0xf0107444,0x8(%esp)
f01032e9:	f0 
f01032ea:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
f01032f1:	00 
f01032f2:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01032f9:	e8 42 cd ff ff       	call   f0100040 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE,
f01032fe:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
f0103305:	00 
f0103306:	c7 04 24 00 90 11 00 	movl   $0x119000,(%esp)
f010330d:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0103312:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0103317:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f010331c:	e8 fa e4 ff ff       	call   f010181b <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103321:	b8 00 d0 22 f0       	mov    $0xf022d000,%eax
f0103326:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010332b:	0f 87 1b 08 00 00    	ja     f0103b4c <mem_init+0x2093>
f0103331:	eb 13                	jmp    f0103346 <mem_init+0x188d>
	//cprintf("current cpu: %d\n", cpunum());
	for (i = 0; i < NCPU; ++i) {
		//cprintf("cpu %d: %x\n", i, PADDR((void*)percpu_kstacks[i]));
		uint32_t kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE,
						PADDR((void*)percpu_kstacks[i]), PTE_W);
f0103333:	89 d8                	mov    %ebx,%eax
f0103335:	c1 e0 0f             	shl    $0xf,%eax
f0103338:	05 00 d0 22 f0       	add    $0xf022d000,%eax
f010333d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103342:	77 27                	ja     f010336b <mem_init+0x18b2>
f0103344:	eb 05                	jmp    f010334b <mem_init+0x1892>
f0103346:	b8 00 d0 22 f0       	mov    $0xf022d000,%eax
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010334b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010334f:	c7 44 24 08 44 74 10 	movl   $0xf0107444,0x8(%esp)
f0103356:	f0 
f0103357:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
f010335e:	00 
f010335f:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0103366:	e8 d5 cc ff ff       	call   f0100040 <_panic>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010336b:	89 da                	mov    %ebx,%edx
f010336d:	f7 da                	neg    %edx
f010336f:	c1 e2 10             	shl    $0x10,%edx
f0103372:	81 ea 00 80 00 10    	sub    $0x10008000,%edx
	//cprintf("boostack: %x\n", PADDR(bootstack));
	//cprintf("current cpu: %d\n", cpunum());
	for (i = 0; i < NCPU; ++i) {
		//cprintf("cpu %d: %x\n", i, PADDR((void*)percpu_kstacks[i]));
		uint32_t kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE,
f0103378:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f010337f:	00 
	return (physaddr_t)kva - KERNBASE;
f0103380:	05 00 00 00 10       	add    $0x10000000,%eax
f0103385:	89 04 24             	mov    %eax,(%esp)
f0103388:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010338d:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0103392:	e8 84 e4 ff ff       	call   f010181b <boot_map_region>
	
	// TODO check pmap.c and trap.c for conflicts
	int i = 0;
	//cprintf("boostack: %x\n", PADDR(bootstack));
	//cprintf("current cpu: %d\n", cpunum());
	for (i = 0; i < NCPU; ++i) {
f0103397:	83 c3 01             	add    $0x1,%ebx
f010339a:	83 fb 08             	cmp    $0x8,%ebx
f010339d:	75 94                	jne    f0103333 <mem_init+0x187a>
//<<<<<<< HEAD
	// Initialize the SMP-related parts of the memory map
	mem_init_mp();

//=======
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0,
f010339f:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01033a6:	00 
f01033a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01033ae:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f01033b3:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01033b8:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01033bd:	e8 59 e4 ff ff       	call   f010181b <boot_map_region>
					PTE_P | PTE_W);
	
	// 0 to kernbase is not mapped 
	int i;
	for (i = 0; i < PDX(KERNBASE); i+=PGSIZE) {
		kern_pgdir[i] = 0;
f01033c2:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01033c7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01033cd:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01033d3:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f01033d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01033db:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax

	for (i = 0; i < n; i += PGSIZE) {
f01033e2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01033e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01033ea:	75 30                	jne    f010341c <mem_init+0x1963>
	}

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01033ec:	8b 1d 4c b2 22 f0    	mov    0xf022b24c,%ebx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033f2:	89 de                	mov    %ebx,%esi
f01033f4:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01033f9:	89 f8                	mov    %edi,%eax
f01033fb:	e8 f0 d9 ff ff       	call   f0100df0 <check_va2pa>
f0103400:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0103406:	0f 86 94 00 00 00    	jbe    f01034a0 <mem_init+0x19e7>
f010340c:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0103411:	81 c6 00 00 40 21    	add    $0x21400000,%esi
f0103417:	e9 a4 00 00 00       	jmp    f01034c0 <mem_init+0x1a07>

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);

	for (i = 0; i < n; i += PGSIZE) {
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010341c:	8b 1d 90 be 22 f0    	mov    0xf022be90,%ebx
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0103422:	8d b3 00 00 00 10    	lea    0x10000000(%ebx),%esi
f0103428:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010342d:	89 f8                	mov    %edi,%eax
f010342f:	e8 bc d9 ff ff       	call   f0100df0 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103434:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f010343a:	77 20                	ja     f010345c <mem_init+0x19a3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010343c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103440:	c7 44 24 08 44 74 10 	movl   $0xf0107444,0x8(%esp)
f0103447:	f0 
f0103448:	c7 44 24 04 1f 04 00 	movl   $0x41f,0x4(%esp)
f010344f:	00 
f0103450:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0103457:	e8 e4 cb ff ff       	call   f0100040 <_panic>
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);

	for (i = 0; i < n; i += PGSIZE) {
f010345c:	ba 00 00 00 00       	mov    $0x0,%edx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0103461:	8d 0c 32             	lea    (%edx,%esi,1),%ecx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);

	for (i = 0; i < n; i += PGSIZE) {
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0103464:	39 c1                	cmp    %eax,%ecx
f0103466:	74 24                	je     f010348c <mem_init+0x19d3>
f0103468:	c7 44 24 0c 9c 81 10 	movl   $0xf010819c,0xc(%esp)
f010346f:	f0 
f0103470:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0103477:	f0 
f0103478:	c7 44 24 04 1f 04 00 	movl   $0x41f,0x4(%esp)
f010347f:	00 
f0103480:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0103487:	e8 b4 cb ff ff       	call   f0100040 <_panic>
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);

	for (i = 0; i < n; i += PGSIZE) {
f010348c:	8d 9a 00 10 00 00    	lea    0x1000(%edx),%ebx
f0103492:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0103495:	0f 87 ec 06 00 00    	ja     f0103b87 <mem_init+0x20ce>
f010349b:	e9 4c ff ff ff       	jmp    f01033ec <mem_init+0x1933>
f01034a0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01034a4:	c7 44 24 08 44 74 10 	movl   $0xf0107444,0x8(%esp)
f01034ab:	f0 
f01034ac:	c7 44 24 04 25 04 00 	movl   $0x425,0x4(%esp)
f01034b3:	00 
f01034b4:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01034bb:	e8 80 cb ff ff       	call   f0100040 <_panic>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01034c0:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
	}

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01034c3:	39 d0                	cmp    %edx,%eax
f01034c5:	74 24                	je     f01034eb <mem_init+0x1a32>
f01034c7:	c7 44 24 0c d0 81 10 	movl   $0xf01081d0,0xc(%esp)
f01034ce:	f0 
f01034cf:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01034d6:	f0 
f01034d7:	c7 44 24 04 25 04 00 	movl   $0x425,0x4(%esp)
f01034de:	00 
f01034df:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01034e6:	e8 55 cb ff ff       	call   f0100040 <_panic>
f01034eb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
	}

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01034f1:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f01034f7:	0f 85 7c 06 00 00    	jne    f0103b79 <mem_init+0x20c0>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE) {
f01034fd:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103500:	c1 e6 0c             	shl    $0xc,%esi
f0103503:	85 f6                	test   %esi,%esi
f0103505:	74 55                	je     f010355c <mem_init+0x1aa3>
f0103507:	bb 00 00 00 00       	mov    $0x0,%ebx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010350c:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE) {
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0103512:	89 f8                	mov    %edi,%eax
f0103514:	e8 d7 d8 ff ff       	call   f0100df0 <check_va2pa>
f0103519:	39 c3                	cmp    %eax,%ebx
f010351b:	74 24                	je     f0103541 <mem_init+0x1a88>
f010351d:	c7 44 24 0c 04 82 10 	movl   $0xf0108204,0xc(%esp)
f0103524:	f0 
f0103525:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010352c:	f0 
f010352d:	c7 44 24 04 29 04 00 	movl   $0x429,0x4(%esp)
f0103534:	00 
f0103535:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f010353c:	e8 ff ca ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE) {
f0103541:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103547:	39 de                	cmp    %ebx,%esi
f0103549:	77 c1                	ja     f010350c <mem_init+0x1a53>
f010354b:	be 00 00 ff ef       	mov    $0xefff0000,%esi
f0103550:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f0103557:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010355a:	eb 0f                	jmp    f010356b <mem_init+0x1ab2>
f010355c:	be 00 00 ff ef       	mov    $0xefff0000,%esi
f0103561:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f0103568:	89 7d d4             	mov    %edi,-0x2c(%ebp)
	// check kernel stack
//<<<<<<< HEAD
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE) {
f010356b:	bb 00 00 00 00       	mov    $0x0,%ebx
			//cprintf("!%x\n", check_va2pa(pgdir, base + KSTKGAP + i));
			//cprintf("!%x\n", PADDR(percpu_kstacks[n] + i));
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103570:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0103573:	c1 e7 0f             	shl    $0xf,%edi
f0103576:	81 c7 00 d0 22 f0    	add    $0xf022d000,%edi
	return (physaddr_t)kva - KERNBASE;
f010357c:	8d 97 00 00 00 10    	lea    0x10000000(%edi),%edx
f0103582:	89 55 d0             	mov    %edx,-0x30(%ebp)
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0103585:	8d 94 1e 00 80 00 00 	lea    0x8000(%esi,%ebx,1),%edx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE) {
			//cprintf("!%x\n", check_va2pa(pgdir, base + KSTKGAP + i));
			//cprintf("!%x\n", PADDR(percpu_kstacks[n] + i));
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010358c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010358f:	e8 5c d8 ff ff       	call   f0100df0 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103594:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f010359a:	77 20                	ja     f01035bc <mem_init+0x1b03>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010359c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01035a0:	c7 44 24 08 44 74 10 	movl   $0xf0107444,0x8(%esp)
f01035a7:	f0 
f01035a8:	c7 44 24 04 36 04 00 	movl   $0x436,0x4(%esp)
f01035af:	00 
f01035b0:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01035b7:	e8 84 ca ff ff       	call   f0100040 <_panic>
f01035bc:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01035bf:	01 da                	add    %ebx,%edx
f01035c1:	39 d0                	cmp    %edx,%eax
f01035c3:	74 24                	je     f01035e9 <mem_init+0x1b30>
f01035c5:	c7 44 24 0c 2c 82 10 	movl   $0xf010822c,0xc(%esp)
f01035cc:	f0 
f01035cd:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01035d4:	f0 
f01035d5:	c7 44 24 04 36 04 00 	movl   $0x436,0x4(%esp)
f01035dc:	00 
f01035dd:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01035e4:	e8 57 ca ff ff       	call   f0100040 <_panic>
	// check kernel stack
//<<<<<<< HEAD
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE) {
f01035e9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01035ef:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f01035f5:	75 8e                	jne    f0103585 <mem_init+0x1acc>
f01035f7:	66 bb 00 00          	mov    $0x0,%bx
f01035fb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01035fe:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
			//cprintf("!%x\n", PADDR(percpu_kstacks[n] + i));
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		}
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0103601:	89 f8                	mov    %edi,%eax
f0103603:	e8 e8 d7 ff ff       	call   f0100df0 <check_va2pa>
f0103608:	83 f8 ff             	cmp    $0xffffffff,%eax
f010360b:	74 24                	je     f0103631 <mem_init+0x1b78>
f010360d:	c7 44 24 0c 74 82 10 	movl   $0xf0108274,0xc(%esp)
f0103614:	f0 
f0103615:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010361c:	f0 
f010361d:	c7 44 24 04 39 04 00 	movl   $0x439,0x4(%esp)
f0103624:	00 
f0103625:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f010362c:	e8 0f ca ff ff       	call   f0100040 <_panic>
			//cprintf("!%x\n", check_va2pa(pgdir, base + KSTKGAP + i));
			//cprintf("!%x\n", PADDR(percpu_kstacks[n] + i));
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		}
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0103631:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103637:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f010363d:	75 bf                	jne    f01035fe <mem_init+0x1b45>


	// check kernel stack
//<<<<<<< HEAD
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f010363f:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
f0103643:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0103649:	83 7d cc 08          	cmpl   $0x8,-0x34(%ebp)
f010364d:	0f 85 18 ff ff ff    	jne    f010356b <mem_init+0x1ab2>
f0103653:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103656:	b8 00 00 00 00       	mov    $0x0,%eax
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
//>>>>>>> lab3
*/
	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010365b:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0103661:	83 fa 04             	cmp    $0x4,%edx
f0103664:	77 2e                	ja     f0103694 <mem_init+0x1bdb>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0103666:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f010366a:	0f 85 aa 00 00 00    	jne    f010371a <mem_init+0x1c61>
f0103670:	c7 44 24 0c ff 86 10 	movl   $0xf01086ff,0xc(%esp)
f0103677:	f0 
f0103678:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010367f:	f0 
f0103680:	c7 44 24 04 4e 04 00 	movl   $0x44e,0x4(%esp)
f0103687:	00 
f0103688:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f010368f:	e8 ac c9 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0103694:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0103699:	76 55                	jbe    f01036f0 <mem_init+0x1c37>
				assert(pgdir[i] & PTE_P);
f010369b:	8b 14 87             	mov    (%edi,%eax,4),%edx
f010369e:	f6 c2 01             	test   $0x1,%dl
f01036a1:	75 24                	jne    f01036c7 <mem_init+0x1c0e>
f01036a3:	c7 44 24 0c ff 86 10 	movl   $0xf01086ff,0xc(%esp)
f01036aa:	f0 
f01036ab:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01036b2:	f0 
f01036b3:	c7 44 24 04 52 04 00 	movl   $0x452,0x4(%esp)
f01036ba:	00 
f01036bb:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01036c2:	e8 79 c9 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f01036c7:	f6 c2 02             	test   $0x2,%dl
f01036ca:	75 4e                	jne    f010371a <mem_init+0x1c61>
f01036cc:	c7 44 24 0c 10 87 10 	movl   $0xf0108710,0xc(%esp)
f01036d3:	f0 
f01036d4:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01036db:	f0 
f01036dc:	c7 44 24 04 53 04 00 	movl   $0x453,0x4(%esp)
f01036e3:	00 
f01036e4:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01036eb:	e8 50 c9 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f01036f0:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01036f4:	74 24                	je     f010371a <mem_init+0x1c61>
f01036f6:	c7 44 24 0c 21 87 10 	movl   $0xf0108721,0xc(%esp)
f01036fd:	f0 
f01036fe:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0103705:	f0 
f0103706:	c7 44 24 04 55 04 00 	movl   $0x455,0x4(%esp)
f010370d:	00 
f010370e:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0103715:	e8 26 c9 ff ff       	call   f0100040 <_panic>
	}
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
//>>>>>>> lab3
*/
	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010371a:	83 c0 01             	add    $0x1,%eax
f010371d:	3d 00 04 00 00       	cmp    $0x400,%eax
f0103722:	0f 85 33 ff ff ff    	jne    f010365b <mem_init+0x1ba2>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0103728:	c7 04 24 98 82 10 f0 	movl   $0xf0108298,(%esp)
f010372f:	e8 6a 0f 00 00       	call   f010469e <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0103734:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103739:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010373e:	77 20                	ja     f0103760 <mem_init+0x1ca7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103740:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103744:	c7 44 24 08 44 74 10 	movl   $0xf0107444,0x8(%esp)
f010374b:	f0 
f010374c:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
f0103753:	00 
f0103754:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f010375b:	e8 e0 c8 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103760:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103765:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0103768:	b8 00 00 00 00       	mov    $0x0,%eax
f010376d:	e8 92 d7 ff ff       	call   f0100f04 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0103772:	0f 20 c0             	mov    %cr0,%eax
	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f0103775:	83 e0 f3             	and    $0xfffffff3,%eax
f0103778:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f010377d:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0103780:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103787:	e8 52 dc ff ff       	call   f01013de <page_alloc>
f010378c:	89 c3                	mov    %eax,%ebx
f010378e:	85 c0                	test   %eax,%eax
f0103790:	75 24                	jne    f01037b6 <mem_init+0x1cfd>
f0103792:	c7 44 24 0c 2c 85 10 	movl   $0xf010852c,0xc(%esp)
f0103799:	f0 
f010379a:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01037a1:	f0 
f01037a2:	c7 44 24 04 2e 05 00 	movl   $0x52e,0x4(%esp)
f01037a9:	00 
f01037aa:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01037b1:	e8 8a c8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01037b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01037bd:	e8 1c dc ff ff       	call   f01013de <page_alloc>
f01037c2:	89 c7                	mov    %eax,%edi
f01037c4:	85 c0                	test   %eax,%eax
f01037c6:	75 24                	jne    f01037ec <mem_init+0x1d33>
f01037c8:	c7 44 24 0c 42 85 10 	movl   $0xf0108542,0xc(%esp)
f01037cf:	f0 
f01037d0:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01037d7:	f0 
f01037d8:	c7 44 24 04 2f 05 00 	movl   $0x52f,0x4(%esp)
f01037df:	00 
f01037e0:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01037e7:	e8 54 c8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01037ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01037f3:	e8 e6 db ff ff       	call   f01013de <page_alloc>
f01037f8:	89 c6                	mov    %eax,%esi
f01037fa:	85 c0                	test   %eax,%eax
f01037fc:	75 24                	jne    f0103822 <mem_init+0x1d69>
f01037fe:	c7 44 24 0c 58 85 10 	movl   $0xf0108558,0xc(%esp)
f0103805:	f0 
f0103806:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010380d:	f0 
f010380e:	c7 44 24 04 30 05 00 	movl   $0x530,0x4(%esp)
f0103815:	00 
f0103816:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f010381d:	e8 1e c8 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0103822:	89 1c 24             	mov    %ebx,(%esp)
f0103825:	e8 32 dc ff ff       	call   f010145c <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010382a:	89 f8                	mov    %edi,%eax
f010382c:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0103832:	c1 f8 03             	sar    $0x3,%eax
f0103835:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103838:	89 c2                	mov    %eax,%edx
f010383a:	c1 ea 0c             	shr    $0xc,%edx
f010383d:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0103843:	72 20                	jb     f0103865 <mem_init+0x1dac>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103845:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103849:	c7 44 24 08 68 74 10 	movl   $0xf0107468,0x8(%esp)
f0103850:	f0 
f0103851:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
f0103858:	00 
f0103859:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f0103860:	e8 db c7 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0103865:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010386c:	00 
f010386d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0103874:	00 
	return (void *)(pa + KERNBASE);
f0103875:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010387a:	89 04 24             	mov    %eax,(%esp)
f010387d:	e8 83 2d 00 00       	call   f0106605 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103882:	89 f0                	mov    %esi,%eax
f0103884:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f010388a:	c1 f8 03             	sar    $0x3,%eax
f010388d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103890:	89 c2                	mov    %eax,%edx
f0103892:	c1 ea 0c             	shr    $0xc,%edx
f0103895:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f010389b:	72 20                	jb     f01038bd <mem_init+0x1e04>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010389d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01038a1:	c7 44 24 08 68 74 10 	movl   $0xf0107468,0x8(%esp)
f01038a8:	f0 
f01038a9:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
f01038b0:	00 
f01038b1:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f01038b8:	e8 83 c7 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01038bd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01038c4:	00 
f01038c5:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01038cc:	00 
	return (void *)(pa + KERNBASE);
f01038cd:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01038d2:	89 04 24             	mov    %eax,(%esp)
f01038d5:	e8 2b 2d 00 00       	call   f0106605 <memset>
	print_flag = 1;
f01038da:	c7 05 38 b2 22 f0 01 	movl   $0x1,0xf022b238
f01038e1:	00 00 00 
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01038e4:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01038eb:	00 
f01038ec:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01038f3:	00 
f01038f4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01038f8:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01038fd:	89 04 24             	mov    %eax,(%esp)
f0103900:	e8 84 e0 ff ff       	call   f0101989 <page_insert>
	assert(pp1->pp_ref == 1);
f0103905:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010390a:	74 24                	je     f0103930 <mem_init+0x1e77>
f010390c:	c7 44 24 0c 29 86 10 	movl   $0xf0108629,0xc(%esp)
f0103913:	f0 
f0103914:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010391b:	f0 
f010391c:	c7 44 24 04 36 05 00 	movl   $0x536,0x4(%esp)
f0103923:	00 
f0103924:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f010392b:	e8 10 c7 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103930:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103937:	01 01 01 
f010393a:	74 24                	je     f0103960 <mem_init+0x1ea7>
f010393c:	c7 44 24 0c b8 82 10 	movl   $0xf01082b8,0xc(%esp)
f0103943:	f0 
f0103944:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010394b:	f0 
f010394c:	c7 44 24 04 37 05 00 	movl   $0x537,0x4(%esp)
f0103953:	00 
f0103954:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f010395b:	e8 e0 c6 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0103960:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103967:	00 
f0103968:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010396f:	00 
f0103970:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103974:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0103979:	89 04 24             	mov    %eax,(%esp)
f010397c:	e8 08 e0 ff ff       	call   f0101989 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103981:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103988:	02 02 02 
f010398b:	74 24                	je     f01039b1 <mem_init+0x1ef8>
f010398d:	c7 44 24 0c dc 82 10 	movl   $0xf01082dc,0xc(%esp)
f0103994:	f0 
f0103995:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010399c:	f0 
f010399d:	c7 44 24 04 39 05 00 	movl   $0x539,0x4(%esp)
f01039a4:	00 
f01039a5:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01039ac:	e8 8f c6 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01039b1:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01039b6:	74 24                	je     f01039dc <mem_init+0x1f23>
f01039b8:	c7 44 24 0c 4b 86 10 	movl   $0xf010864b,0xc(%esp)
f01039bf:	f0 
f01039c0:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01039c7:	f0 
f01039c8:	c7 44 24 04 3a 05 00 	movl   $0x53a,0x4(%esp)
f01039cf:	00 
f01039d0:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f01039d7:	e8 64 c6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01039dc:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01039e1:	74 24                	je     f0103a07 <mem_init+0x1f4e>
f01039e3:	c7 44 24 0c 94 86 10 	movl   $0xf0108694,0xc(%esp)
f01039ea:	f0 
f01039eb:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01039f2:	f0 
f01039f3:	c7 44 24 04 3b 05 00 	movl   $0x53b,0x4(%esp)
f01039fa:	00 
f01039fb:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0103a02:	e8 39 c6 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103a07:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103a0e:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103a11:	89 f0                	mov    %esi,%eax
f0103a13:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0103a19:	c1 f8 03             	sar    $0x3,%eax
f0103a1c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103a1f:	89 c2                	mov    %eax,%edx
f0103a21:	c1 ea 0c             	shr    $0xc,%edx
f0103a24:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0103a2a:	72 20                	jb     f0103a4c <mem_init+0x1f93>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103a2c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a30:	c7 44 24 08 68 74 10 	movl   $0xf0107468,0x8(%esp)
f0103a37:	f0 
f0103a38:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
f0103a3f:	00 
f0103a40:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f0103a47:	e8 f4 c5 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103a4c:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103a53:	03 03 03 
f0103a56:	74 24                	je     f0103a7c <mem_init+0x1fc3>
f0103a58:	c7 44 24 0c 00 83 10 	movl   $0xf0108300,0xc(%esp)
f0103a5f:	f0 
f0103a60:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0103a67:	f0 
f0103a68:	c7 44 24 04 3d 05 00 	movl   $0x53d,0x4(%esp)
f0103a6f:	00 
f0103a70:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0103a77:	e8 c4 c5 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103a7c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103a83:	00 
f0103a84:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0103a89:	89 04 24             	mov    %eax,(%esp)
f0103a8c:	e8 8e de ff ff       	call   f010191f <page_remove>
	assert(pp2->pp_ref == 0);
f0103a91:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0103a96:	74 24                	je     f0103abc <mem_init+0x2003>
f0103a98:	c7 44 24 0c 83 86 10 	movl   $0xf0108683,0xc(%esp)
f0103a9f:	f0 
f0103aa0:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0103aa7:	f0 
f0103aa8:	c7 44 24 04 3f 05 00 	movl   $0x53f,0x4(%esp)
f0103aaf:	00 
f0103ab0:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0103ab7:	e8 84 c5 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103abc:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0103ac1:	8b 08                	mov    (%eax),%ecx
f0103ac3:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103ac9:	89 da                	mov    %ebx,%edx
f0103acb:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0103ad1:	c1 fa 03             	sar    $0x3,%edx
f0103ad4:	c1 e2 0c             	shl    $0xc,%edx
f0103ad7:	39 d1                	cmp    %edx,%ecx
f0103ad9:	74 24                	je     f0103aff <mem_init+0x2046>
f0103adb:	c7 44 24 0c c0 7c 10 	movl   $0xf0107cc0,0xc(%esp)
f0103ae2:	f0 
f0103ae3:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0103aea:	f0 
f0103aeb:	c7 44 24 04 42 05 00 	movl   $0x542,0x4(%esp)
f0103af2:	00 
f0103af3:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0103afa:	e8 41 c5 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103aff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103b05:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103b0a:	74 24                	je     f0103b30 <mem_init+0x2077>
f0103b0c:	c7 44 24 0c 3a 86 10 	movl   $0xf010863a,0xc(%esp)
f0103b13:	f0 
f0103b14:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0103b1b:	f0 
f0103b1c:	c7 44 24 04 44 05 00 	movl   $0x544,0x4(%esp)
f0103b23:	00 
f0103b24:	c7 04 24 8d 83 10 f0 	movl   $0xf010838d,(%esp)
f0103b2b:	e8 10 c5 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103b30:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0103b36:	89 1c 24             	mov    %ebx,(%esp)
f0103b39:	e8 1e d9 ff ff       	call   f010145c <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103b3e:	c7 04 24 2c 83 10 f0 	movl   $0xf010832c,(%esp)
f0103b45:	e8 54 0b 00 00       	call   f010469e <cprintf>
f0103b4a:	eb 4f                	jmp    f0103b9b <mem_init+0x20e2>
	//cprintf("boostack: %x\n", PADDR(bootstack));
	//cprintf("current cpu: %d\n", cpunum());
	for (i = 0; i < NCPU; ++i) {
		//cprintf("cpu %d: %x\n", i, PADDR((void*)percpu_kstacks[i]));
		uint32_t kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE,
f0103b4c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103b53:	00 
f0103b54:	c7 04 24 00 d0 22 00 	movl   $0x22d000,(%esp)
f0103b5b:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0103b60:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0103b65:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0103b6a:	e8 ac dc ff ff       	call   f010181b <boot_map_region>
	
	// TODO check pmap.c and trap.c for conflicts
	int i = 0;
	//cprintf("boostack: %x\n", PADDR(bootstack));
	//cprintf("current cpu: %d\n", cpunum());
	for (i = 0; i < NCPU; ++i) {
f0103b6f:	bb 01 00 00 00       	mov    $0x1,%ebx
f0103b74:	e9 ba f7 ff ff       	jmp    f0103333 <mem_init+0x187a>
	}

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0103b79:	89 da                	mov    %ebx,%edx
f0103b7b:	89 f8                	mov    %edi,%eax
f0103b7d:	e8 6e d2 ff ff       	call   f0100df0 <check_va2pa>
f0103b82:	e9 39 f9 ff ff       	jmp    f01034c0 <mem_init+0x1a07>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0103b87:	81 ea 00 f0 ff 10    	sub    $0x10fff000,%edx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);

	for (i = 0; i < n; i += PGSIZE) {
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0103b8d:	89 f8                	mov    %edi,%eax
f0103b8f:	e8 5c d2 ff ff       	call   f0100df0 <check_va2pa>
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);

	for (i = 0; i < n; i += PGSIZE) {
f0103b94:	89 da                	mov    %ebx,%edx
f0103b96:	e9 c6 f8 ff ff       	jmp    f0103461 <mem_init+0x19a8>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0103b9b:	83 c4 3c             	add    $0x3c,%esp
f0103b9e:	5b                   	pop    %ebx
f0103b9f:	5e                   	pop    %esi
f0103ba0:	5f                   	pop    %edi
f0103ba1:	5d                   	pop    %ebp
f0103ba2:	c3                   	ret    

f0103ba3 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0103ba3:	55                   	push   %ebp
f0103ba4:	89 e5                	mov    %esp,%ebp
f0103ba6:	57                   	push   %edi
f0103ba7:	56                   	push   %esi
f0103ba8:	53                   	push   %ebx
f0103ba9:	83 ec 2c             	sub    $0x2c,%esp
f0103bac:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103baf:	8b 45 0c             	mov    0xc(%ebp),%eax
	// LAB 3: Your code here.
	// cprintf("!!%x %x\n", (uintptr_t)va, ULIM);
	uintptr_t va_curr = (uintptr_t)va;
	
	//TODO >= or > ?
	if (va_curr + len >= ULIM) {
f0103bb2:	8b 55 10             	mov    0x10(%ebp),%edx
f0103bb5:	01 c2                	add    %eax,%edx
f0103bb7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103bba:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0103bc0:	77 13                	ja     f0103bd5 <user_mem_check+0x32>
f0103bc2:	89 c3                	mov    %eax,%ebx
						0);
		if (!pte) {
			user_mem_check_addr = va_curr;
			return -E_FAULT;
		}
		if ((*(uintptr_t*)pte & (perm | PTE_P)) != (perm | PTE_P)) {
f0103bc4:	8b 75 14             	mov    0x14(%ebp),%esi
f0103bc7:	83 ce 01             	or     $0x1,%esi
			user_mem_check_addr = ULIM;
		}
		return -E_FAULT;
	}

	for (;va_curr <= (uintptr_t)va + len;
f0103bca:	39 d0                	cmp    %edx,%eax
f0103bcc:	76 2b                	jbe    f0103bf9 <user_mem_check+0x56>
			user_mem_check_addr = va_curr;
			return -E_FAULT;
		}
	}

	return 0;
f0103bce:	b8 00 00 00 00       	mov    $0x0,%eax
f0103bd3:	eb 77                	jmp    f0103c4c <user_mem_check+0xa9>
	// cprintf("!!%x %x\n", (uintptr_t)va, ULIM);
	uintptr_t va_curr = (uintptr_t)va;
	
	//TODO >= or > ?
	if (va_curr + len >= ULIM) {
		if (va_curr >= ULIM) {
f0103bd5:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0103bda:	76 0c                	jbe    f0103be8 <user_mem_check+0x45>
			user_mem_check_addr = va_curr;
f0103bdc:	a3 48 b2 22 f0       	mov    %eax,0xf022b248
		} else {
			user_mem_check_addr = ULIM;
		}
		return -E_FAULT;
f0103be1:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103be6:	eb 64                	jmp    f0103c4c <user_mem_check+0xa9>
	//TODO >= or > ?
	if (va_curr + len >= ULIM) {
		if (va_curr >= ULIM) {
			user_mem_check_addr = va_curr;
		} else {
			user_mem_check_addr = ULIM;
f0103be8:	c7 05 48 b2 22 f0 00 	movl   $0xef800000,0xf022b248
f0103bef:	00 80 ef 
		}
		return -E_FAULT;
f0103bf2:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103bf7:	eb 53                	jmp    f0103c4c <user_mem_check+0xa9>
	}

	for (;va_curr <= (uintptr_t)va + len;
	     va_curr = ROUNDDOWN(va_curr + PGSIZE, PGSIZE)) {
		uintptr_t pte = (uintptr_t)pgdir_walk(env->env_pgdir, (void*)va_curr,
f0103bf9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103c00:	00 
f0103c01:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103c05:	8b 47 60             	mov    0x60(%edi),%eax
f0103c08:	89 04 24             	mov    %eax,(%esp)
f0103c0b:	e8 b9 d8 ff ff       	call   f01014c9 <pgdir_walk>
						0);
		if (!pte) {
f0103c10:	85 c0                	test   %eax,%eax
f0103c12:	75 0d                	jne    f0103c21 <user_mem_check+0x7e>
			user_mem_check_addr = va_curr;
f0103c14:	89 1d 48 b2 22 f0    	mov    %ebx,0xf022b248
			return -E_FAULT;
f0103c1a:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103c1f:	eb 2b                	jmp    f0103c4c <user_mem_check+0xa9>
		}
		if ((*(uintptr_t*)pte & (perm | PTE_P)) != (perm | PTE_P)) {
f0103c21:	8b 00                	mov    (%eax),%eax
f0103c23:	21 f0                	and    %esi,%eax
f0103c25:	39 c6                	cmp    %eax,%esi
f0103c27:	74 0d                	je     f0103c36 <user_mem_check+0x93>
			user_mem_check_addr = va_curr;
f0103c29:	89 1d 48 b2 22 f0    	mov    %ebx,0xf022b248
			return -E_FAULT;
f0103c2f:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103c34:	eb 16                	jmp    f0103c4c <user_mem_check+0xa9>
		}
		return -E_FAULT;
	}

	for (;va_curr <= (uintptr_t)va + len;
	     va_curr = ROUNDDOWN(va_curr + PGSIZE, PGSIZE)) {
f0103c36:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103c3c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
			user_mem_check_addr = ULIM;
		}
		return -E_FAULT;
	}

	for (;va_curr <= (uintptr_t)va + len;
f0103c42:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0103c45:	73 b2                	jae    f0103bf9 <user_mem_check+0x56>
			user_mem_check_addr = va_curr;
			return -E_FAULT;
		}
	}

	return 0;
f0103c47:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103c4c:	83 c4 2c             	add    $0x2c,%esp
f0103c4f:	5b                   	pop    %ebx
f0103c50:	5e                   	pop    %esi
f0103c51:	5f                   	pop    %edi
f0103c52:	5d                   	pop    %ebp
f0103c53:	c3                   	ret    

f0103c54 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0103c54:	55                   	push   %ebp
f0103c55:	89 e5                	mov    %esp,%ebp
f0103c57:	53                   	push   %ebx
f0103c58:	83 ec 14             	sub    $0x14,%esp
f0103c5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103c5e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c61:	83 c8 04             	or     $0x4,%eax
f0103c64:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c68:	8b 45 10             	mov    0x10(%ebp),%eax
f0103c6b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103c6f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c72:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c76:	89 1c 24             	mov    %ebx,(%esp)
f0103c79:	e8 25 ff ff ff       	call   f0103ba3 <user_mem_check>
f0103c7e:	85 c0                	test   %eax,%eax
f0103c80:	79 24                	jns    f0103ca6 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103c82:	a1 48 b2 22 f0       	mov    0xf022b248,%eax
f0103c87:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103c8b:	8b 43 48             	mov    0x48(%ebx),%eax
f0103c8e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c92:	c7 04 24 58 83 10 f0 	movl   $0xf0108358,(%esp)
f0103c99:	e8 00 0a 00 00       	call   f010469e <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103c9e:	89 1c 24             	mov    %ebx,(%esp)
f0103ca1:	e8 0b 07 00 00       	call   f01043b1 <env_destroy>
	}
}
f0103ca6:	83 c4 14             	add    $0x14,%esp
f0103ca9:	5b                   	pop    %ebx
f0103caa:	5d                   	pop    %ebp
f0103cab:	c3                   	ret    

f0103cac <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103cac:	55                   	push   %ebp
f0103cad:	89 e5                	mov    %esp,%ebp
f0103caf:	57                   	push   %edi
f0103cb0:	56                   	push   %esi
f0103cb1:	53                   	push   %ebx
f0103cb2:	83 ec 1c             	sub    $0x1c,%esp
f0103cb5:	89 c7                	mov    %eax,%edi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

	uint32_t va_start = ROUNDDOWN((uint32_t)va, PGSIZE);
f0103cb7:	89 d0                	mov    %edx,%eax
f0103cb9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	uint32_t va_end = ROUNDUP((uint32_t)(va + len), PGSIZE);
f0103cbe:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0103cc5:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	
	int i;
	for (i = va_start; i < va_end; i += PGSIZE) {
f0103ccb:	89 c3                	mov    %eax,%ebx
f0103ccd:	39 f0                	cmp    %esi,%eax
f0103ccf:	73 45                	jae    f0103d16 <region_alloc+0x6a>
		struct PageInfo* new_page =  page_alloc(0);
f0103cd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103cd8:	e8 01 d7 ff ff       	call   f01013de <page_alloc>
		int r = page_insert(e->env_pgdir, new_page, (void*)i, (PTE_U | PTE_W));
f0103cdd:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0103ce4:	00 
f0103ce5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103ce9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ced:	8b 47 60             	mov    0x60(%edi),%eax
f0103cf0:	89 04 24             	mov    %eax,(%esp)
f0103cf3:	e8 91 dc ff ff       	call   f0101989 <page_insert>
		if (r) {
f0103cf8:	85 c0                	test   %eax,%eax
f0103cfa:	74 10                	je     f0103d0c <region_alloc+0x60>
			cprintf("page_insert: %e\n", r);
f0103cfc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d00:	c7 04 24 2f 87 10 f0 	movl   $0xf010872f,(%esp)
f0103d07:	e8 92 09 00 00       	call   f010469e <cprintf>

	uint32_t va_start = ROUNDDOWN((uint32_t)va, PGSIZE);
	uint32_t va_end = ROUNDUP((uint32_t)(va + len), PGSIZE);
	
	int i;
	for (i = va_start; i < va_end; i += PGSIZE) {
f0103d0c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103d12:	39 de                	cmp    %ebx,%esi
f0103d14:	77 bb                	ja     f0103cd1 <region_alloc+0x25>
		int r = page_insert(e->env_pgdir, new_page, (void*)i, (PTE_U | PTE_W));
		if (r) {
			cprintf("page_insert: %e\n", r);
		}
	}
}
f0103d16:	83 c4 1c             	add    $0x1c,%esp
f0103d19:	5b                   	pop    %ebx
f0103d1a:	5e                   	pop    %esi
f0103d1b:	5f                   	pop    %edi
f0103d1c:	5d                   	pop    %ebp
f0103d1d:	c3                   	ret    

f0103d1e <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103d1e:	55                   	push   %ebp
f0103d1f:	89 e5                	mov    %esp,%ebp
f0103d21:	83 ec 18             	sub    $0x18,%esp
f0103d24:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0103d27:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0103d2a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d2d:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103d30:	85 c0                	test   %eax,%eax
f0103d32:	75 1d                	jne    f0103d51 <envid2env+0x33>
		*env_store = curenv;
f0103d34:	e8 73 2f 00 00       	call   f0106cac <cpunum>
f0103d39:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d3c:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103d42:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103d45:	89 02                	mov    %eax,(%edx)
		return 0;
f0103d47:	b8 00 00 00 00       	mov    $0x0,%eax
f0103d4c:	e9 ac 00 00 00       	jmp    f0103dfd <envid2env+0xdf>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103d51:	89 c3                	mov    %eax,%ebx
f0103d53:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103d59:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0103d5c:	03 1d 4c b2 22 f0    	add    0xf022b24c,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103d62:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103d66:	74 05                	je     f0103d6d <envid2env+0x4f>
f0103d68:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103d6b:	74 40                	je     f0103dad <envid2env+0x8f>
		*env_store = 0;
f0103d6d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103d70:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		if (e->env_status == ENV_FREE) {
f0103d76:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103d7a:	75 13                	jne    f0103d8f <envid2env+0x71>
			cprintf("status is free\n");
f0103d7c:	c7 04 24 40 87 10 f0 	movl   $0xf0108740,(%esp)
f0103d83:	e8 16 09 00 00       	call   f010469e <cprintf>
		} else {
			cprintf("envid mismatch: %d %d\n", e->env_id, envid);
		}
		return -E_BAD_ENV;
f0103d88:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103d8d:	eb 6e                	jmp    f0103dfd <envid2env+0xdf>
	if (e->env_status == ENV_FREE || e->env_id != envid) {
		*env_store = 0;
		if (e->env_status == ENV_FREE) {
			cprintf("status is free\n");
		} else {
			cprintf("envid mismatch: %d %d\n", e->env_id, envid);
f0103d8f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103d93:	8b 43 48             	mov    0x48(%ebx),%eax
f0103d96:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d9a:	c7 04 24 50 87 10 f0 	movl   $0xf0108750,(%esp)
f0103da1:	e8 f8 08 00 00       	call   f010469e <cprintf>
		}
		return -E_BAD_ENV;
f0103da6:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103dab:	eb 50                	jmp    f0103dfd <envid2env+0xdf>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103dad:	84 d2                	test   %dl,%dl
f0103daf:	74 42                	je     f0103df3 <envid2env+0xd5>
f0103db1:	e8 f6 2e 00 00       	call   f0106cac <cpunum>
f0103db6:	6b c0 74             	imul   $0x74,%eax,%eax
f0103db9:	39 98 28 c0 22 f0    	cmp    %ebx,-0xfdd3fd8(%eax)
f0103dbf:	74 32                	je     f0103df3 <envid2env+0xd5>
f0103dc1:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103dc4:	e8 e3 2e 00 00       	call   f0106cac <cpunum>
f0103dc9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dcc:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103dd2:	3b 70 48             	cmp    0x48(%eax),%esi
f0103dd5:	74 1c                	je     f0103df3 <envid2env+0xd5>
		cprintf("perm check failed\n");
f0103dd7:	c7 04 24 67 87 10 f0 	movl   $0xf0108767,(%esp)
f0103dde:	e8 bb 08 00 00       	call   f010469e <cprintf>
		*env_store = 0;
f0103de3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103de6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103dec:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103df1:	eb 0a                	jmp    f0103dfd <envid2env+0xdf>
	}

	*env_store = e;
f0103df3:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103df6:	89 1a                	mov    %ebx,(%edx)
	return 0;
f0103df8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103dfd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0103e00:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0103e03:	89 ec                	mov    %ebp,%esp
f0103e05:	5d                   	pop    %ebp
f0103e06:	c3                   	ret    

f0103e07 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103e07:	55                   	push   %ebp
f0103e08:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103e0a:	b8 20 33 12 f0       	mov    $0xf0123320,%eax
f0103e0f:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103e12:	b8 23 00 00 00       	mov    $0x23,%eax
f0103e17:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103e19:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103e1b:	b0 10                	mov    $0x10,%al
f0103e1d:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103e1f:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0103e21:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103e23:	ea 2a 3e 10 f0 08 00 	ljmp   $0x8,$0xf0103e2a
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103e2a:	b0 00                	mov    $0x0,%al
f0103e2c:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103e2f:	5d                   	pop    %ebp
f0103e30:	c3                   	ret    

f0103e31 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103e31:	55                   	push   %ebp
f0103e32:	89 e5                	mov    %esp,%ebp
f0103e34:	56                   	push   %esi
f0103e35:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	
	int i;
	for (i = NENV - 1; i >= 0; --i) {
		envs[i].env_status = ENV_FREE;
f0103e36:	8b 35 4c b2 22 f0    	mov    0xf022b24c,%esi
f0103e3c:	8b 0d 50 b2 22 f0    	mov    0xf022b250,%ecx
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f0103e42:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103e48:	ba 00 04 00 00       	mov    $0x400,%edx
	// Set up envs array
	// LAB 3: Your code here.
	
	int i;
	for (i = NENV - 1; i >= 0; --i) {
		envs[i].env_status = ENV_FREE;
f0103e4d:	89 c3                	mov    %eax,%ebx
f0103e4f:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_id = 0;
f0103e56:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0103e5d:	89 48 44             	mov    %ecx,0x44(%eax)
f0103e60:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[i];
f0103e63:	89 d9                	mov    %ebx,%ecx
{
	// Set up envs array
	// LAB 3: Your code here.
	
	int i;
	for (i = NENV - 1; i >= 0; --i) {
f0103e65:	83 ea 01             	sub    $0x1,%edx
f0103e68:	75 e3                	jne    f0103e4d <env_init+0x1c>
f0103e6a:	89 35 50 b2 22 f0    	mov    %esi,0xf022b250
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f0103e70:	e8 92 ff ff ff       	call   f0103e07 <env_init_percpu>
}
f0103e75:	5b                   	pop    %ebx
f0103e76:	5e                   	pop    %esi
f0103e77:	5d                   	pop    %ebp
f0103e78:	c3                   	ret    

f0103e79 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103e79:	55                   	push   %ebp
f0103e7a:	89 e5                	mov    %esp,%ebp
f0103e7c:	56                   	push   %esi
f0103e7d:	53                   	push   %ebx
f0103e7e:	83 ec 10             	sub    $0x10,%esp
	// cprintf("In env_alloc\n");
	int32_t generation;
	int r;
	struct Env *e;
	
	if (!(e = env_free_list))
f0103e81:	8b 1d 50 b2 22 f0    	mov    0xf022b250,%ebx
f0103e87:	85 db                	test   %ebx,%ebx
f0103e89:	0f 84 b7 01 00 00    	je     f0104046 <env_alloc+0x1cd>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO))) {
f0103e8f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103e96:	e8 43 d5 ff ff       	call   f01013de <page_alloc>
f0103e9b:	85 c0                	test   %eax,%eax
f0103e9d:	0f 84 aa 01 00 00    	je     f010404d <env_alloc+0x1d4>
f0103ea3:	89 c2                	mov    %eax,%edx
f0103ea5:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0103eab:	c1 fa 03             	sar    $0x3,%edx
f0103eae:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103eb1:	89 d1                	mov    %edx,%ecx
f0103eb3:	c1 e9 0c             	shr    $0xc,%ecx
f0103eb6:	3b 0d 88 be 22 f0    	cmp    0xf022be88,%ecx
f0103ebc:	72 20                	jb     f0103ede <env_alloc+0x65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103ebe:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103ec2:	c7 44 24 08 68 74 10 	movl   $0xf0107468,0x8(%esp)
f0103ec9:	f0 
f0103eca:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
f0103ed1:	00 
f0103ed2:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f0103ed9:	e8 62 c1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103ede:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103ee4:	89 53 60             	mov    %edx,0x60(%ebx)
	// LAB 3: Your code here.

	e->env_pgdir = page2kva(p);
	
	// Incrementing pp_ref TODO check!
	p->pp_ref++;
f0103ee7:	66 83 40 04 01       	addw   $0x1,0x4(%eax)

	// above UTOP
	// cprintf("in setup_vm before loop\n");
	for (i = UTOP; i != 0; i += PGSIZE) {
f0103eec:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
		// cprintf("%x\n",i);
		e->env_pgdir[PDX(i)] = kern_pgdir[PDX(i)];
f0103ef1:	89 c2                	mov    %eax,%edx
f0103ef3:	c1 ea 16             	shr    $0x16,%edx
f0103ef6:	8b 0d 8c be 22 f0    	mov    0xf022be8c,%ecx
f0103efc:	8b 34 91             	mov    (%ecx,%edx,4),%esi
f0103eff:	8b 4b 60             	mov    0x60(%ebx),%ecx
f0103f02:	89 34 91             	mov    %esi,(%ecx,%edx,4)
	// Incrementing pp_ref TODO check!
	p->pp_ref++;

	// above UTOP
	// cprintf("in setup_vm before loop\n");
	for (i = UTOP; i != 0; i += PGSIZE) {
f0103f05:	05 00 10 00 00       	add    $0x1000,%eax
f0103f0a:	75 e5                	jne    f0103ef1 <env_alloc+0x78>
		// cprintf("%x\n",i);
		e->env_pgdir[PDX(i)] = kern_pgdir[PDX(i)];
	}
	// cprintf("in setup_vm after loop\n");

	for (i = 0; i < UTOP; i += PGSIZE) {
f0103f0c:	ba 00 00 00 00       	mov    $0x0,%edx
		e->env_pgdir[PDX(i)] = 0; 
f0103f11:	c1 ea 16             	shr    $0x16,%edx
f0103f14:	8b 4b 60             	mov    0x60(%ebx),%ecx
f0103f17:	c7 04 91 00 00 00 00 	movl   $0x0,(%ecx,%edx,4)
		// cprintf("%x\n",i);
		e->env_pgdir[PDX(i)] = kern_pgdir[PDX(i)];
	}
	// cprintf("in setup_vm after loop\n");

	for (i = 0; i < UTOP; i += PGSIZE) {
f0103f1e:	05 00 10 00 00       	add    $0x1000,%eax
f0103f23:	89 c2                	mov    %eax,%edx
f0103f25:	3d 00 00 c0 ee       	cmp    $0xeec00000,%eax
f0103f2a:	75 e5                	jne    f0103f11 <env_alloc+0x98>
		e->env_pgdir[PDX(i)] = 0; 
	}

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103f2c:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103f2f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103f34:	77 20                	ja     f0103f56 <env_alloc+0xdd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103f36:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f3a:	c7 44 24 08 44 74 10 	movl   $0xf0107444,0x8(%esp)
f0103f41:	f0 
f0103f42:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
f0103f49:	00 
f0103f4a:	c7 04 24 7a 87 10 f0 	movl   $0xf010877a,(%esp)
f0103f51:	e8 ea c0 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103f56:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103f5c:	83 ca 05             	or     $0x5,%edx
f0103f5f:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103f65:	8b 43 48             	mov    0x48(%ebx),%eax
f0103f68:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103f6d:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103f72:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103f77:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103f7a:	89 da                	mov    %ebx,%edx
f0103f7c:	2b 15 4c b2 22 f0    	sub    0xf022b24c,%edx
f0103f82:	c1 fa 02             	sar    $0x2,%edx
f0103f85:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103f8b:	09 d0                	or     %edx,%eax
f0103f8d:	89 43 48             	mov    %eax,0x48(%ebx)

//	cprintf("In env_alloc: id %d\n", e->env_id);

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103f90:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f93:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103f96:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103f9d:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103fa4:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103fab:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103fb2:	00 
f0103fb3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103fba:	00 
f0103fbb:	89 1c 24             	mov    %ebx,(%esp)
f0103fbe:	e8 42 26 00 00       	call   f0106605 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103fc3:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103fc9:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103fcf:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103fd5:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103fdc:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	// cprintf("In env_alloc b4: %x\n", e->env_tf.tf_eflags);
	e->env_tf.tf_eflags = e->env_tf.tf_eflags | FL_IF;
f0103fe2:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// cprintf("In env_alloc after: %x\n", e->env_tf.tf_eflags);

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103fe9:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103ff0:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103ff4:	8b 43 44             	mov    0x44(%ebx),%eax
f0103ff7:	a3 50 b2 22 f0       	mov    %eax,0xf022b250
	*newenv_store = e;
f0103ffc:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fff:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0104001:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0104004:	e8 a3 2c 00 00       	call   f0106cac <cpunum>
f0104009:	6b d0 74             	imul   $0x74,%eax,%edx
f010400c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104011:	83 ba 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%edx)
f0104018:	74 11                	je     f010402b <env_alloc+0x1b2>
f010401a:	e8 8d 2c 00 00       	call   f0106cac <cpunum>
f010401f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104022:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104028:	8b 40 48             	mov    0x48(%eax),%eax
f010402b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010402f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104033:	c7 04 24 85 87 10 f0 	movl   $0xf0108785,(%esp)
f010403a:	e8 5f 06 00 00       	call   f010469e <cprintf>
	return 0;
f010403f:	b8 00 00 00 00       	mov    $0x0,%eax
f0104044:	eb 0c                	jmp    f0104052 <env_alloc+0x1d9>
	int32_t generation;
	int r;
	struct Env *e;
	
	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0104046:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010404b:	eb 05                	jmp    f0104052 <env_alloc+0x1d9>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO))) {
		return -E_NO_MEM;
f010404d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0104052:	83 c4 10             	add    $0x10,%esp
f0104055:	5b                   	pop    %ebx
f0104056:	5e                   	pop    %esi
f0104057:	5d                   	pop    %ebp
f0104058:	c3                   	ret    

f0104059 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0104059:	55                   	push   %ebp
f010405a:	89 e5                	mov    %esp,%ebp
f010405c:	57                   	push   %edi
f010405d:	56                   	push   %esi
f010405e:	53                   	push   %ebx
f010405f:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 3: Your code here.
	struct Env* env_new;
	int r = env_alloc(&env_new, 0);
f0104062:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0104069:	00 
f010406a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010406d:	89 04 24             	mov    %eax,(%esp)
f0104070:	e8 04 fe ff ff       	call   f0103e79 <env_alloc>
	if (r) {
f0104075:	85 c0                	test   %eax,%eax
f0104077:	74 15                	je     f010408e <env_create+0x35>
		cprintf("env_alloc: %e\n", r);
f0104079:	89 44 24 04          	mov    %eax,0x4(%esp)
f010407d:	c7 04 24 9a 87 10 f0 	movl   $0xf010879a,(%esp)
f0104084:	e8 15 06 00 00       	call   f010469e <cprintf>
f0104089:	e9 15 01 00 00       	jmp    f01041a3 <env_create+0x14a>
		return;
	}
	env_new->env_type = type;
f010408e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104091:	8b 45 10             	mov    0x10(%ebp),%eax
f0104094:	89 47 50             	mov    %eax,0x50(%edi)
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.

	struct Elf* elfhdr = (struct Elf*)binary;
	struct Proghdr* ph = (struct Proghdr*)((uint8_t*) elfhdr + elfhdr->e_phoff);
f0104097:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010409a:	03 5b 1c             	add    0x1c(%ebx),%ebx
	struct Proghdr* eph = ph + elfhdr->e_phnum;
f010409d:	8b 45 08             	mov    0x8(%ebp),%eax
f01040a0:	0f b7 70 2c          	movzwl 0x2c(%eax),%esi
f01040a4:	c1 e6 05             	shl    $0x5,%esi
f01040a7:	01 de                	add    %ebx,%esi

	lcr3(PADDR(e->env_pgdir));
f01040a9:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01040ac:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01040b1:	77 20                	ja     f01040d3 <env_create+0x7a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01040b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01040b7:	c7 44 24 08 44 74 10 	movl   $0xf0107444,0x8(%esp)
f01040be:	f0 
f01040bf:	c7 44 24 04 92 01 00 	movl   $0x192,0x4(%esp)
f01040c6:	00 
f01040c7:	c7 04 24 7a 87 10 f0 	movl   $0xf010877a,(%esp)
f01040ce:	e8 6d bf ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01040d3:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01040d8:	0f 22 d8             	mov    %eax,%cr3

	for (; ph < eph; ph++) {
f01040db:	39 f3                	cmp    %esi,%ebx
f01040dd:	73 76                	jae    f0104155 <env_create+0xfc>
		if (ph->p_type == ELF_PROG_LOAD) {
f01040df:	83 3b 01             	cmpl   $0x1,(%ebx)
f01040e2:	75 6a                	jne    f010414e <env_create+0xf5>
			region_alloc(e, (void*)ph->p_va, ph->p_memsz);
f01040e4:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01040e7:	8b 53 08             	mov    0x8(%ebx),%edx
f01040ea:	89 f8                	mov    %edi,%eax
f01040ec:	e8 bb fb ff ff       	call   f0103cac <region_alloc>
			memcpy((void*)ph->p_va, (void*)(binary + ph->p_offset),
f01040f1:	8b 43 10             	mov    0x10(%ebx),%eax
f01040f4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01040f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01040fb:	03 43 04             	add    0x4(%ebx),%eax
f01040fe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104102:	8b 43 08             	mov    0x8(%ebx),%eax
f0104105:	89 04 24             	mov    %eax,(%esp)
f0104108:	e8 cf 25 00 00       	call   f01066dc <memcpy>
					ph->p_filesz);
			if (ph->p_filesz <= ph->p_memsz) {
f010410d:	8b 43 10             	mov    0x10(%ebx),%eax
f0104110:	8b 53 14             	mov    0x14(%ebx),%edx
f0104113:	39 d0                	cmp    %edx,%eax
f0104115:	77 1b                	ja     f0104132 <env_create+0xd9>
				memset((void*)(ph->p_va + ph->p_filesz), 0,
f0104117:	29 c2                	sub    %eax,%edx
f0104119:	89 54 24 08          	mov    %edx,0x8(%esp)
f010411d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0104124:	00 
f0104125:	03 43 08             	add    0x8(%ebx),%eax
f0104128:	89 04 24             	mov    %eax,(%esp)
f010412b:	e8 d5 24 00 00       	call   f0106605 <memset>
f0104130:	eb 1c                	jmp    f010414e <env_create+0xf5>
						ph->p_memsz - ph->p_filesz);
			} else {
				panic("filesz greater than memsz\n");
f0104132:	c7 44 24 08 a9 87 10 	movl   $0xf01087a9,0x8(%esp)
f0104139:	f0 
f010413a:	c7 44 24 04 9d 01 00 	movl   $0x19d,0x4(%esp)
f0104141:	00 
f0104142:	c7 04 24 7a 87 10 f0 	movl   $0xf010877a,(%esp)
f0104149:	e8 f2 be ff ff       	call   f0100040 <_panic>
	struct Proghdr* ph = (struct Proghdr*)((uint8_t*) elfhdr + elfhdr->e_phoff);
	struct Proghdr* eph = ph + elfhdr->e_phnum;

	lcr3(PADDR(e->env_pgdir));

	for (; ph < eph; ph++) {
f010414e:	83 c3 20             	add    $0x20,%ebx
f0104151:	39 de                	cmp    %ebx,%esi
f0104153:	77 8a                	ja     f01040df <env_create+0x86>
			} else {
				panic("filesz greater than memsz\n");
			}
		}
	}
	e->env_tf.tf_eip = elfhdr->e_entry;
f0104155:	8b 55 08             	mov    0x8(%ebp),%edx
f0104158:	8b 42 18             	mov    0x18(%edx),%eax
f010415b:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	
	region_alloc(e, (void*)(USTACKTOP - PGSIZE), PGSIZE);
f010415e:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0104163:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0104168:	89 f8                	mov    %edi,%eax
f010416a:	e8 3d fb ff ff       	call   f0103cac <region_alloc>
	lcr3(PADDR(kern_pgdir));
f010416f:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104174:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104179:	77 20                	ja     f010419b <env_create+0x142>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010417b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010417f:	c7 44 24 08 44 74 10 	movl   $0xf0107444,0x8(%esp)
f0104186:	f0 
f0104187:	c7 44 24 04 a9 01 00 	movl   $0x1a9,0x4(%esp)
f010418e:	00 
f010418f:	c7 04 24 7a 87 10 f0 	movl   $0xf010877a,(%esp)
f0104196:	e8 a5 be ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010419b:	05 00 00 00 10       	add    $0x10000000,%eax
f01041a0:	0f 22 d8             	mov    %eax,%cr3
		cprintf("env_alloc: %e\n", r);
		return;
	}
	env_new->env_type = type;
	load_icode(env_new, binary, size);
}
f01041a3:	83 c4 2c             	add    $0x2c,%esp
f01041a6:	5b                   	pop    %ebx
f01041a7:	5e                   	pop    %esi
f01041a8:	5f                   	pop    %edi
f01041a9:	5d                   	pop    %ebp
f01041aa:	c3                   	ret    

f01041ab <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01041ab:	55                   	push   %ebp
f01041ac:	89 e5                	mov    %esp,%ebp
f01041ae:	57                   	push   %edi
f01041af:	56                   	push   %esi
f01041b0:	53                   	push   %ebx
f01041b1:	83 ec 2c             	sub    $0x2c,%esp
f01041b4:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01041b7:	e8 f0 2a 00 00       	call   f0106cac <cpunum>
f01041bc:	6b c0 74             	imul   $0x74,%eax,%eax
f01041bf:	39 b8 28 c0 22 f0    	cmp    %edi,-0xfdd3fd8(%eax)
f01041c5:	75 34                	jne    f01041fb <env_free+0x50>
		lcr3(PADDR(kern_pgdir));
f01041c7:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01041cc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01041d1:	77 20                	ja     f01041f3 <env_free+0x48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01041d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01041d7:	c7 44 24 08 44 74 10 	movl   $0xf0107444,0x8(%esp)
f01041de:	f0 
f01041df:	c7 44 24 04 cf 01 00 	movl   $0x1cf,0x4(%esp)
f01041e6:	00 
f01041e7:	c7 04 24 7a 87 10 f0 	movl   $0xf010877a,(%esp)
f01041ee:	e8 4d be ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01041f3:	05 00 00 00 10       	add    $0x10000000,%eax
f01041f8:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01041fb:	8b 5f 48             	mov    0x48(%edi),%ebx
f01041fe:	e8 a9 2a 00 00       	call   f0106cac <cpunum>
f0104203:	6b d0 74             	imul   $0x74,%eax,%edx
f0104206:	b8 00 00 00 00       	mov    $0x0,%eax
f010420b:	83 ba 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%edx)
f0104212:	74 11                	je     f0104225 <env_free+0x7a>
f0104214:	e8 93 2a 00 00       	call   f0106cac <cpunum>
f0104219:	6b c0 74             	imul   $0x74,%eax,%eax
f010421c:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104222:	8b 40 48             	mov    0x48(%eax),%eax
f0104225:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104229:	89 44 24 04          	mov    %eax,0x4(%esp)
f010422d:	c7 04 24 c4 87 10 f0 	movl   $0xf01087c4,(%esp)
f0104234:	e8 65 04 00 00       	call   f010469e <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0104239:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
f0104240:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104243:	c1 e0 02             	shl    $0x2,%eax
f0104246:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0104249:	8b 47 60             	mov    0x60(%edi),%eax
f010424c:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010424f:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0104252:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0104258:	0f 84 b7 00 00 00    	je     f0104315 <env_free+0x16a>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010425e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104264:	89 f0                	mov    %esi,%eax
f0104266:	c1 e8 0c             	shr    $0xc,%eax
f0104269:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010426c:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0104272:	72 20                	jb     f0104294 <env_free+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104274:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104278:	c7 44 24 08 68 74 10 	movl   $0xf0107468,0x8(%esp)
f010427f:	f0 
f0104280:	c7 44 24 04 de 01 00 	movl   $0x1de,0x4(%esp)
f0104287:	00 
f0104288:	c7 04 24 7a 87 10 f0 	movl   $0xf010877a,(%esp)
f010428f:	e8 ac bd ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0104294:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104297:	c1 e2 16             	shl    $0x16,%edx
f010429a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010429d:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01042a2:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01042a9:	01 
f01042aa:	74 17                	je     f01042c3 <env_free+0x118>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01042ac:	89 d8                	mov    %ebx,%eax
f01042ae:	c1 e0 0c             	shl    $0xc,%eax
f01042b1:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01042b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042b8:	8b 47 60             	mov    0x60(%edi),%eax
f01042bb:	89 04 24             	mov    %eax,(%esp)
f01042be:	e8 5c d6 ff ff       	call   f010191f <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01042c3:	83 c3 01             	add    $0x1,%ebx
f01042c6:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01042cc:	75 d4                	jne    f01042a2 <env_free+0xf7>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01042ce:	8b 47 60             	mov    0x60(%edi),%eax
f01042d1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01042d4:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01042db:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01042de:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f01042e4:	72 1c                	jb     f0104302 <env_free+0x157>
		panic("pa2page called with invalid pa");
f01042e6:	c7 44 24 08 8c 7b 10 	movl   $0xf0107b8c,0x8(%esp)
f01042ed:	f0 
f01042ee:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01042f5:	00 
f01042f6:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f01042fd:	e8 3e bd ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0104302:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f0104307:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010430a:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f010430d:	89 04 24             	mov    %eax,(%esp)
f0104310:	e8 5c d1 ff ff       	call   f0101471 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0104315:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0104319:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0104320:	0f 85 1a ff ff ff    	jne    f0104240 <env_free+0x95>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0104326:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104329:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010432e:	77 20                	ja     f0104350 <env_free+0x1a5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104330:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104334:	c7 44 24 08 44 74 10 	movl   $0xf0107444,0x8(%esp)
f010433b:	f0 
f010433c:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
f0104343:	00 
f0104344:	c7 04 24 7a 87 10 f0 	movl   $0xf010877a,(%esp)
f010434b:	e8 f0 bc ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0104350:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0104357:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010435c:	c1 e8 0c             	shr    $0xc,%eax
f010435f:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0104365:	72 1c                	jb     f0104383 <env_free+0x1d8>
		panic("pa2page called with invalid pa");
f0104367:	c7 44 24 08 8c 7b 10 	movl   $0xf0107b8c,0x8(%esp)
f010436e:	f0 
f010436f:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0104376:	00 
f0104377:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f010437e:	e8 bd bc ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0104383:	8b 15 90 be 22 f0    	mov    0xf022be90,%edx
f0104389:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f010438c:	89 04 24             	mov    %eax,(%esp)
f010438f:	e8 dd d0 ff ff       	call   f0101471 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0104394:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f010439b:	a1 50 b2 22 f0       	mov    0xf022b250,%eax
f01043a0:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01043a3:	89 3d 50 b2 22 f0    	mov    %edi,0xf022b250
}
f01043a9:	83 c4 2c             	add    $0x2c,%esp
f01043ac:	5b                   	pop    %ebx
f01043ad:	5e                   	pop    %esi
f01043ae:	5f                   	pop    %edi
f01043af:	5d                   	pop    %ebp
f01043b0:	c3                   	ret    

f01043b1 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01043b1:	55                   	push   %ebp
f01043b2:	89 e5                	mov    %esp,%ebp
f01043b4:	53                   	push   %ebx
f01043b5:	83 ec 14             	sub    $0x14,%esp
f01043b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01043bb:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01043bf:	75 19                	jne    f01043da <env_destroy+0x29>
f01043c1:	e8 e6 28 00 00       	call   f0106cac <cpunum>
f01043c6:	6b c0 74             	imul   $0x74,%eax,%eax
f01043c9:	39 98 28 c0 22 f0    	cmp    %ebx,-0xfdd3fd8(%eax)
f01043cf:	74 09                	je     f01043da <env_destroy+0x29>
		e->env_status = ENV_DYING;
f01043d1:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01043d8:	eb 2f                	jmp    f0104409 <env_destroy+0x58>
	}

	env_free(e);
f01043da:	89 1c 24             	mov    %ebx,(%esp)
f01043dd:	e8 c9 fd ff ff       	call   f01041ab <env_free>

	if (curenv == e) {
f01043e2:	e8 c5 28 00 00       	call   f0106cac <cpunum>
f01043e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01043ea:	39 98 28 c0 22 f0    	cmp    %ebx,-0xfdd3fd8(%eax)
f01043f0:	75 17                	jne    f0104409 <env_destroy+0x58>
		curenv = NULL;
f01043f2:	e8 b5 28 00 00       	call   f0106cac <cpunum>
f01043f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01043fa:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f0104401:	00 00 00 
		sched_yield();
f0104404:	e8 2b 0e 00 00       	call   f0105234 <sched_yield>
	}
}
f0104409:	83 c4 14             	add    $0x14,%esp
f010440c:	5b                   	pop    %ebx
f010440d:	5d                   	pop    %ebp
f010440e:	c3                   	ret    

f010440f <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010440f:	55                   	push   %ebp
f0104410:	89 e5                	mov    %esp,%ebp
f0104412:	53                   	push   %ebx
f0104413:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0104416:	e8 91 28 00 00       	call   f0106cac <cpunum>
f010441b:	6b c0 74             	imul   $0x74,%eax,%eax
f010441e:	8b 98 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%ebx
f0104424:	e8 83 28 00 00       	call   f0106cac <cpunum>
f0104429:	89 43 5c             	mov    %eax,0x5c(%ebx)
	
	__asm __volatile("movl %0,%%esp\n"
f010442c:	8b 65 08             	mov    0x8(%ebp),%esp
f010442f:	61                   	popa   
f0104430:	07                   	pop    %es
f0104431:	1f                   	pop    %ds
f0104432:	83 c4 08             	add    $0x8,%esp
f0104435:	cf                   	iret   
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /*skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");

	panic("iret failed");  /* mostly to placate the compiler */
f0104436:	c7 44 24 08 da 87 10 	movl   $0xf01087da,0x8(%esp)
f010443d:	f0 
f010443e:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
f0104445:	00 
f0104446:	c7 04 24 7a 87 10 f0 	movl   $0xf010877a,(%esp)
f010444d:	e8 ee bb ff ff       	call   f0100040 <_panic>

f0104452 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0104452:	55                   	push   %ebp
f0104453:	89 e5                	mov    %esp,%ebp
f0104455:	83 ec 18             	sub    $0x18,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	// Step 1:
	if (curenv != NULL) {
f0104458:	e8 4f 28 00 00       	call   f0106cac <cpunum>
f010445d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104460:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0104467:	74 29                	je     f0104492 <env_run+0x40>
		if (curenv->env_status == ENV_RUNNING) {
f0104469:	e8 3e 28 00 00       	call   f0106cac <cpunum>
f010446e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104471:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104477:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010447b:	75 15                	jne    f0104492 <env_run+0x40>
			curenv->env_status = ENV_RUNNABLE;
f010447d:	e8 2a 28 00 00       	call   f0106cac <cpunum>
f0104482:	6b c0 74             	imul   $0x74,%eax,%eax
f0104485:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010448b:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		}
	}
	curenv = e;
f0104492:	e8 15 28 00 00       	call   f0106cac <cpunum>
f0104497:	6b c0 74             	imul   $0x74,%eax,%eax
f010449a:	8b 55 08             	mov    0x8(%ebp),%edx
f010449d:	89 90 28 c0 22 f0    	mov    %edx,-0xfdd3fd8(%eax)
	curenv->env_status = ENV_RUNNING;
f01044a3:	e8 04 28 00 00       	call   f0106cac <cpunum>
f01044a8:	6b c0 74             	imul   $0x74,%eax,%eax
f01044ab:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01044b1:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f01044b8:	e8 ef 27 00 00       	call   f0106cac <cpunum>
f01044bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01044c0:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01044c6:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f01044ca:	e8 dd 27 00 00       	call   f0106cac <cpunum>
f01044cf:	6b c0 74             	imul   $0x74,%eax,%eax
f01044d2:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01044d8:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01044db:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01044e0:	77 20                	ja     f0104502 <env_run+0xb0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01044e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01044e6:	c7 44 24 08 44 74 10 	movl   $0xf0107444,0x8(%esp)
f01044ed:	f0 
f01044ee:	c7 44 24 04 4a 02 00 	movl   $0x24a,0x4(%esp)
f01044f5:	00 
f01044f6:	c7 04 24 7a 87 10 f0 	movl   $0xf010877a,(%esp)
f01044fd:	e8 3e bb ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104502:	05 00 00 00 10       	add    $0x10000000,%eax
f0104507:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010450a:	c7 04 24 a0 34 12 f0 	movl   $0xf01234a0,(%esp)
f0104511:	e8 0a 2b 00 00       	call   f0107020 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104516:	f3 90                	pause  
	unlock_kernel();

	// Step 2:
	env_pop_tf(&(curenv->env_tf));
f0104518:	e8 8f 27 00 00       	call   f0106cac <cpunum>
f010451d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104520:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104526:	89 04 24             	mov    %eax,(%esp)
f0104529:	e8 e1 fe ff ff       	call   f010440f <env_pop_tf>
f010452e:	66 90                	xchg   %ax,%ax

f0104530 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0104530:	55                   	push   %ebp
f0104531:	89 e5                	mov    %esp,%ebp
void
mc146818_write(unsigned reg, unsigned datum)
{
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0104533:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104537:	ba 70 00 00 00       	mov    $0x70,%edx
f010453c:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010453d:	b2 71                	mov    $0x71,%dl
f010453f:	ec                   	in     (%dx),%al

unsigned
mc146818_read(unsigned reg)
{
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0104540:	0f b6 c0             	movzbl %al,%eax
}
f0104543:	5d                   	pop    %ebp
f0104544:	c3                   	ret    

f0104545 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0104545:	55                   	push   %ebp
f0104546:	89 e5                	mov    %esp,%ebp
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0104548:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010454c:	ba 70 00 00 00       	mov    $0x70,%edx
f0104551:	ee                   	out    %al,(%dx)
f0104552:	0f b6 45 0c          	movzbl 0xc(%ebp),%eax
f0104556:	b2 71                	mov    $0x71,%dl
f0104558:	ee                   	out    %al,(%dx)
f0104559:	5d                   	pop    %ebp
f010455a:	c3                   	ret    
f010455b:	90                   	nop

f010455c <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f010455c:	55                   	push   %ebp
f010455d:	89 e5                	mov    %esp,%ebp
f010455f:	56                   	push   %esi
f0104560:	53                   	push   %ebx
f0104561:	83 ec 10             	sub    $0x10,%esp
f0104564:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0104567:	66 a3 a8 33 12 f0    	mov    %ax,0xf01233a8
	if (!didinit)
f010456d:	80 3d 54 b2 22 f0 00 	cmpb   $0x0,0xf022b254
f0104574:	74 4e                	je     f01045c4 <irq_setmask_8259A+0x68>
f0104576:	89 c6                	mov    %eax,%esi
f0104578:	ba 21 00 00 00       	mov    $0x21,%edx
f010457d:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f010457e:	66 c1 e8 08          	shr    $0x8,%ax
f0104582:	b2 a1                	mov    $0xa1,%dl
f0104584:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0104585:	c7 04 24 e6 87 10 f0 	movl   $0xf01087e6,(%esp)
f010458c:	e8 0d 01 00 00       	call   f010469e <cprintf>
	for (i = 0; i < 16; i++)
f0104591:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0104596:	0f b7 f6             	movzwl %si,%esi
f0104599:	f7 d6                	not    %esi
f010459b:	0f a3 de             	bt     %ebx,%esi
f010459e:	73 10                	jae    f01045b0 <irq_setmask_8259A+0x54>
			cprintf(" %d", i);
f01045a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01045a4:	c7 04 24 d7 8c 10 f0 	movl   $0xf0108cd7,(%esp)
f01045ab:	e8 ee 00 00 00       	call   f010469e <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f01045b0:	83 c3 01             	add    $0x1,%ebx
f01045b3:	83 fb 10             	cmp    $0x10,%ebx
f01045b6:	75 e3                	jne    f010459b <irq_setmask_8259A+0x3f>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f01045b8:	c7 04 24 fd 86 10 f0 	movl   $0xf01086fd,(%esp)
f01045bf:	e8 da 00 00 00       	call   f010469e <cprintf>
}
f01045c4:	83 c4 10             	add    $0x10,%esp
f01045c7:	5b                   	pop    %ebx
f01045c8:	5e                   	pop    %esi
f01045c9:	5d                   	pop    %ebp
f01045ca:	c3                   	ret    

f01045cb <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f01045cb:	c6 05 54 b2 22 f0 01 	movb   $0x1,0xf022b254
f01045d2:	ba 21 00 00 00       	mov    $0x21,%edx
f01045d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01045dc:	ee                   	out    %al,(%dx)
f01045dd:	b2 a1                	mov    $0xa1,%dl
f01045df:	ee                   	out    %al,(%dx)
f01045e0:	b2 20                	mov    $0x20,%dl
f01045e2:	b8 11 00 00 00       	mov    $0x11,%eax
f01045e7:	ee                   	out    %al,(%dx)
f01045e8:	b2 21                	mov    $0x21,%dl
f01045ea:	b8 20 00 00 00       	mov    $0x20,%eax
f01045ef:	ee                   	out    %al,(%dx)
f01045f0:	b8 04 00 00 00       	mov    $0x4,%eax
f01045f5:	ee                   	out    %al,(%dx)
f01045f6:	b8 03 00 00 00       	mov    $0x3,%eax
f01045fb:	ee                   	out    %al,(%dx)
f01045fc:	b2 a0                	mov    $0xa0,%dl
f01045fe:	b8 11 00 00 00       	mov    $0x11,%eax
f0104603:	ee                   	out    %al,(%dx)
f0104604:	b2 a1                	mov    $0xa1,%dl
f0104606:	b8 28 00 00 00       	mov    $0x28,%eax
f010460b:	ee                   	out    %al,(%dx)
f010460c:	b8 02 00 00 00       	mov    $0x2,%eax
f0104611:	ee                   	out    %al,(%dx)
f0104612:	b8 01 00 00 00       	mov    $0x1,%eax
f0104617:	ee                   	out    %al,(%dx)
f0104618:	b2 20                	mov    $0x20,%dl
f010461a:	b8 68 00 00 00       	mov    $0x68,%eax
f010461f:	ee                   	out    %al,(%dx)
f0104620:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104625:	ee                   	out    %al,(%dx)
f0104626:	b2 a0                	mov    $0xa0,%dl
f0104628:	b8 68 00 00 00       	mov    $0x68,%eax
f010462d:	ee                   	out    %al,(%dx)
f010462e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104633:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0104634:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f010463b:	66 83 f8 ff          	cmp    $0xffff,%ax
f010463f:	74 12                	je     f0104653 <pic_init+0x88>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0104641:	55                   	push   %ebp
f0104642:	89 e5                	mov    %esp,%ebp
f0104644:	83 ec 18             	sub    $0x18,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0104647:	0f b7 c0             	movzwl %ax,%eax
f010464a:	89 04 24             	mov    %eax,(%esp)
f010464d:	e8 0a ff ff ff       	call   f010455c <irq_setmask_8259A>
}
f0104652:	c9                   	leave  
f0104653:	f3 c3                	repz ret 
f0104655:	66 90                	xchg   %ax,%ax
f0104657:	90                   	nop

f0104658 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0104658:	55                   	push   %ebp
f0104659:	89 e5                	mov    %esp,%ebp
f010465b:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f010465e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104661:	89 04 24             	mov    %eax,(%esp)
f0104664:	e8 39 c1 ff ff       	call   f01007a2 <cputchar>
	*cnt++;
}
f0104669:	c9                   	leave  
f010466a:	c3                   	ret    

f010466b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010466b:	55                   	push   %ebp
f010466c:	89 e5                	mov    %esp,%ebp
f010466e:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0104671:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0104678:	8b 45 0c             	mov    0xc(%ebp),%eax
f010467b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010467f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104682:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104686:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104689:	89 44 24 04          	mov    %eax,0x4(%esp)
f010468d:	c7 04 24 58 46 10 f0 	movl   $0xf0104658,(%esp)
f0104694:	e8 09 18 00 00       	call   f0105ea2 <vprintfmt>
	return cnt;
}
f0104699:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010469c:	c9                   	leave  
f010469d:	c3                   	ret    

f010469e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010469e:	55                   	push   %ebp
f010469f:	89 e5                	mov    %esp,%ebp
f01046a1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01046a4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01046a7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01046ae:	89 04 24             	mov    %eax,(%esp)
f01046b1:	e8 b5 ff ff ff       	call   f010466b <vcprintf>
	va_end(ap);

	return cnt;
}
f01046b6:	c9                   	leave  
f01046b7:	c3                   	ret    
f01046b8:	66 90                	xchg   %ax,%ax
f01046ba:	66 90                	xchg   %ax,%ax
f01046bc:	66 90                	xchg   %ax,%ax
f01046be:	66 90                	xchg   %ax,%ax

f01046c0 <_paddr>:
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01046c0:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f01046c6:	77 1e                	ja     f01046e6 <_paddr+0x26>
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f01046c8:	55                   	push   %ebp
f01046c9:	89 e5                	mov    %esp,%ebp
f01046cb:	83 ec 18             	sub    $0x18,%esp
	if ((uint32_t)kva < KERNBASE)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01046ce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01046d2:	c7 44 24 08 44 74 10 	movl   $0xf0107444,0x8(%esp)
f01046d9:	f0 
f01046da:	89 54 24 04          	mov    %edx,0x4(%esp)
f01046de:	89 04 24             	mov    %eax,(%esp)
f01046e1:	e8 5a b9 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01046e6:	8d 81 00 00 00 10    	lea    0x10000000(%ecx),%eax
}
f01046ec:	c3                   	ret    

f01046ed <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01046ed:	55                   	push   %ebp
f01046ee:	89 e5                	mov    %esp,%ebp
f01046f0:	57                   	push   %edi
f01046f1:	56                   	push   %esi
f01046f2:	53                   	push   %ebx
f01046f3:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	
	int id = thiscpu->cpu_id;
f01046f6:	e8 b1 25 00 00       	call   f0106cac <cpunum>
f01046fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01046fe:	0f b6 80 20 c0 22 f0 	movzbl -0xfdd3fe0(%eax),%eax
f0104705:	88 45 e7             	mov    %al,-0x19(%ebp)
f0104708:	0f b6 d8             	movzbl %al,%ebx
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - id * (KSTKSIZE + KSTKGAP);
f010470b:	e8 9c 25 00 00       	call   f0106cac <cpunum>
f0104710:	6b c0 74             	imul   $0x74,%eax,%eax
f0104713:	89 da                	mov    %ebx,%edx
f0104715:	f7 da                	neg    %edx
f0104717:	c1 e2 10             	shl    $0x10,%edx
f010471a:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0104720:	89 90 30 c0 22 f0    	mov    %edx,-0xfdd3fd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0104726:	e8 81 25 00 00       	call   f0106cac <cpunum>
f010472b:	6b c0 74             	imul   $0x74,%eax,%eax
f010472e:	66 c7 80 34 c0 22 f0 	movw   $0x10,-0xfdd3fcc(%eax)
f0104735:	10 00 

	gdt[(GD_TSS0 >> 3) + id] = SEG16(STS_T32A, (uint32_t)(&(thiscpu->cpu_ts)),
f0104737:	83 c3 05             	add    $0x5,%ebx
f010473a:	e8 6d 25 00 00       	call   f0106cac <cpunum>
f010473f:	89 c7                	mov    %eax,%edi
f0104741:	e8 66 25 00 00       	call   f0106cac <cpunum>
f0104746:	89 c6                	mov    %eax,%esi
f0104748:	e8 5f 25 00 00       	call   f0106cac <cpunum>
f010474d:	66 c7 04 dd 40 33 12 	movw   $0x68,-0xfedccc0(,%ebx,8)
f0104754:	f0 68 00 
f0104757:	6b ff 74             	imul   $0x74,%edi,%edi
f010475a:	81 c7 2c c0 22 f0    	add    $0xf022c02c,%edi
f0104760:	66 89 3c dd 42 33 12 	mov    %di,-0xfedccbe(,%ebx,8)
f0104767:	f0 
f0104768:	6b d6 74             	imul   $0x74,%esi,%edx
f010476b:	81 c2 2c c0 22 f0    	add    $0xf022c02c,%edx
f0104771:	c1 ea 10             	shr    $0x10,%edx
f0104774:	88 14 dd 44 33 12 f0 	mov    %dl,-0xfedccbc(,%ebx,8)
f010477b:	c6 04 dd 46 33 12 f0 	movb   $0x40,-0xfedccba(,%ebx,8)
f0104782:	40 
f0104783:	6b c0 74             	imul   $0x74,%eax,%eax
f0104786:	05 2c c0 22 f0       	add    $0xf022c02c,%eax
f010478b:	c1 e8 18             	shr    $0x18,%eax
f010478e:	88 04 dd 47 33 12 f0 	mov    %al,-0xfedccb9(,%ebx,8)
									 sizeof(struct Taskstate), 0);
	gdt[(GD_TSS0 >> 3) + id].sd_s = 0;
f0104795:	c6 04 dd 45 33 12 f0 	movb   $0x89,-0xfedccbb(,%ebx,8)
f010479c:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(((GD_TSS0 >> 3) + id) << 3);
f010479d:	0f b6 75 e7          	movzbl -0x19(%ebp),%esi
f01047a1:	8d 34 f5 28 00 00 00 	lea    0x28(,%esi,8),%esi
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01047a8:	0f 00 de             	ltr    %si
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f01047ab:	b8 ac 33 12 f0       	mov    $0xf01233ac,%eax
f01047b0:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f01047b3:	83 c4 1c             	add    $0x1c,%esp
f01047b6:	5b                   	pop    %ebx
f01047b7:	5e                   	pop    %esi
f01047b8:	5f                   	pop    %edi
f01047b9:	5d                   	pop    %ebp
f01047ba:	c3                   	ret    

f01047bb <trap_init>:
{
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	int i;
	for (i = 0; i < 51; ++i) {
f01047bb:	b8 00 00 00 00       	mov    $0x0,%eax
		SETGATE(idt[i], 0, GD_KT, traps[i], 0);
f01047c0:	8b 14 85 b4 33 12 f0 	mov    -0xfedcc4c(,%eax,4),%edx
f01047c7:	66 89 14 c5 60 b2 22 	mov    %dx,-0xfdd4da0(,%eax,8)
f01047ce:	f0 
f01047cf:	66 c7 04 c5 62 b2 22 	movw   $0x8,-0xfdd4d9e(,%eax,8)
f01047d6:	f0 08 00 
f01047d9:	c6 04 c5 64 b2 22 f0 	movb   $0x0,-0xfdd4d9c(,%eax,8)
f01047e0:	00 
f01047e1:	c6 04 c5 65 b2 22 f0 	movb   $0x8e,-0xfdd4d9b(,%eax,8)
f01047e8:	8e 
f01047e9:	c1 ea 10             	shr    $0x10,%edx
f01047ec:	66 89 14 c5 66 b2 22 	mov    %dx,-0xfdd4d9a(,%eax,8)
f01047f3:	f0 
{
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	int i;
	for (i = 0; i < 51; ++i) {
f01047f4:	83 c0 01             	add    $0x1,%eax
f01047f7:	83 f8 33             	cmp    $0x33,%eax
f01047fa:	75 c4                	jne    f01047c0 <trap_init+0x5>
	return "(unknown trap)";
}

void
trap_init(void)
{
f01047fc:	55                   	push   %ebp
f01047fd:	89 e5                	mov    %esp,%ebp
f01047ff:	83 ec 08             	sub    $0x8,%esp
	// LAB 3: Your code here.
	int i;
	for (i = 0; i < 51; ++i) {
		SETGATE(idt[i], 0, GD_KT, traps[i], 0);
	}
	SETGATE(idt[T_BRKPT], 0, GD_KT, traps[T_BRKPT], 3);
f0104802:	a1 c0 33 12 f0       	mov    0xf01233c0,%eax
f0104807:	66 a3 78 b2 22 f0    	mov    %ax,0xf022b278
f010480d:	66 c7 05 7a b2 22 f0 	movw   $0x8,0xf022b27a
f0104814:	08 00 
f0104816:	c6 05 7c b2 22 f0 00 	movb   $0x0,0xf022b27c
f010481d:	c6 05 7d b2 22 f0 ee 	movb   $0xee,0xf022b27d
f0104824:	c1 e8 10             	shr    $0x10,%eax
f0104827:	66 a3 7e b2 22 f0    	mov    %ax,0xf022b27e
	SETGATE(idt[T_SYSCALL], 0, GD_KT, traps[T_SYSCALL], 3);
f010482d:	a1 74 34 12 f0       	mov    0xf0123474,%eax
f0104832:	66 a3 e0 b3 22 f0    	mov    %ax,0xf022b3e0
f0104838:	66 c7 05 e2 b3 22 f0 	movw   $0x8,0xf022b3e2
f010483f:	08 00 
f0104841:	c6 05 e4 b3 22 f0 00 	movb   $0x0,0xf022b3e4
f0104848:	c6 05 e5 b3 22 f0 ee 	movb   $0xee,0xf022b3e5
f010484f:	c1 e8 10             	shr    $0x10,%eax
f0104852:	66 a3 e6 b3 22 f0    	mov    %ax,0xf022b3e6
	
	// Per-CPU setup
	trap_init_percpu();
f0104858:	e8 90 fe ff ff       	call   f01046ed <trap_init_percpu>
}
f010485d:	c9                   	leave  
f010485e:	c3                   	ret    

f010485f <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f010485f:	55                   	push   %ebp
f0104860:	89 e5                	mov    %esp,%ebp
f0104862:	53                   	push   %ebx
f0104863:	83 ec 14             	sub    $0x14,%esp
f0104866:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0104869:	8b 03                	mov    (%ebx),%eax
f010486b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010486f:	c7 04 24 41 88 10 f0 	movl   $0xf0108841,(%esp)
f0104876:	e8 23 fe ff ff       	call   f010469e <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010487b:	8b 43 04             	mov    0x4(%ebx),%eax
f010487e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104882:	c7 04 24 50 88 10 f0 	movl   $0xf0108850,(%esp)
f0104889:	e8 10 fe ff ff       	call   f010469e <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010488e:	8b 43 08             	mov    0x8(%ebx),%eax
f0104891:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104895:	c7 04 24 5f 88 10 f0 	movl   $0xf010885f,(%esp)
f010489c:	e8 fd fd ff ff       	call   f010469e <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01048a1:	8b 43 0c             	mov    0xc(%ebx),%eax
f01048a4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048a8:	c7 04 24 6e 88 10 f0 	movl   $0xf010886e,(%esp)
f01048af:	e8 ea fd ff ff       	call   f010469e <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01048b4:	8b 43 10             	mov    0x10(%ebx),%eax
f01048b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048bb:	c7 04 24 7d 88 10 f0 	movl   $0xf010887d,(%esp)
f01048c2:	e8 d7 fd ff ff       	call   f010469e <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01048c7:	8b 43 14             	mov    0x14(%ebx),%eax
f01048ca:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048ce:	c7 04 24 8c 88 10 f0 	movl   $0xf010888c,(%esp)
f01048d5:	e8 c4 fd ff ff       	call   f010469e <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01048da:	8b 43 18             	mov    0x18(%ebx),%eax
f01048dd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048e1:	c7 04 24 9b 88 10 f0 	movl   $0xf010889b,(%esp)
f01048e8:	e8 b1 fd ff ff       	call   f010469e <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01048ed:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01048f0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048f4:	c7 04 24 aa 88 10 f0 	movl   $0xf01088aa,(%esp)
f01048fb:	e8 9e fd ff ff       	call   f010469e <cprintf>
}
f0104900:	83 c4 14             	add    $0x14,%esp
f0104903:	5b                   	pop    %ebx
f0104904:	5d                   	pop    %ebp
f0104905:	c3                   	ret    

f0104906 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0104906:	55                   	push   %ebp
f0104907:	89 e5                	mov    %esp,%ebp
f0104909:	56                   	push   %esi
f010490a:	53                   	push   %ebx
f010490b:	83 ec 10             	sub    $0x10,%esp
f010490e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104911:	e8 96 23 00 00       	call   f0106cac <cpunum>
f0104916:	89 44 24 08          	mov    %eax,0x8(%esp)
f010491a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010491e:	c7 04 24 0e 89 10 f0 	movl   $0xf010890e,(%esp)
f0104925:	e8 74 fd ff ff       	call   f010469e <cprintf>
	print_regs(&tf->tf_regs);
f010492a:	89 1c 24             	mov    %ebx,(%esp)
f010492d:	e8 2d ff ff ff       	call   f010485f <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104932:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104936:	89 44 24 04          	mov    %eax,0x4(%esp)
f010493a:	c7 04 24 2c 89 10 f0 	movl   $0xf010892c,(%esp)
f0104941:	e8 58 fd ff ff       	call   f010469e <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104946:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010494a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010494e:	c7 04 24 3f 89 10 f0 	movl   $0xf010893f,(%esp)
f0104955:	e8 44 fd ff ff       	call   f010469e <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010495a:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f010495d:	83 f8 13             	cmp    $0x13,%eax
f0104960:	77 09                	ja     f010496b <print_trapframe+0x65>
		return excnames[trapno];
f0104962:	8b 14 85 c0 8b 10 f0 	mov    -0xfef7440(,%eax,4),%edx
f0104969:	eb 1f                	jmp    f010498a <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f010496b:	83 f8 30             	cmp    $0x30,%eax
f010496e:	74 15                	je     f0104985 <print_trapframe+0x7f>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104970:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f0104973:	83 fa 0f             	cmp    $0xf,%edx
f0104976:	ba c5 88 10 f0       	mov    $0xf01088c5,%edx
f010497b:	b9 d8 88 10 f0       	mov    $0xf01088d8,%ecx
f0104980:	0f 47 d1             	cmova  %ecx,%edx
f0104983:	eb 05                	jmp    f010498a <print_trapframe+0x84>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0104985:	ba b9 88 10 f0       	mov    $0xf01088b9,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010498a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010498e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104992:	c7 04 24 52 89 10 f0 	movl   $0xf0108952,(%esp)
f0104999:	e8 00 fd ff ff       	call   f010469e <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010499e:	3b 1d 60 ba 22 f0    	cmp    0xf022ba60,%ebx
f01049a4:	75 19                	jne    f01049bf <print_trapframe+0xb9>
f01049a6:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01049aa:	75 13                	jne    f01049bf <print_trapframe+0xb9>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f01049ac:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01049af:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049b3:	c7 04 24 64 89 10 f0 	movl   $0xf0108964,(%esp)
f01049ba:	e8 df fc ff ff       	call   f010469e <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f01049bf:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01049c2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049c6:	c7 04 24 73 89 10 f0 	movl   $0xf0108973,(%esp)
f01049cd:	e8 cc fc ff ff       	call   f010469e <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01049d2:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01049d6:	75 51                	jne    f0104a29 <print_trapframe+0x123>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f01049d8:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f01049db:	89 c2                	mov    %eax,%edx
f01049dd:	83 e2 01             	and    $0x1,%edx
f01049e0:	ba e7 88 10 f0       	mov    $0xf01088e7,%edx
f01049e5:	b9 f2 88 10 f0       	mov    $0xf01088f2,%ecx
f01049ea:	0f 45 ca             	cmovne %edx,%ecx
f01049ed:	89 c2                	mov    %eax,%edx
f01049ef:	83 e2 02             	and    $0x2,%edx
f01049f2:	ba fe 88 10 f0       	mov    $0xf01088fe,%edx
f01049f7:	be 04 89 10 f0       	mov    $0xf0108904,%esi
f01049fc:	0f 44 d6             	cmove  %esi,%edx
f01049ff:	83 e0 04             	and    $0x4,%eax
f0104a02:	b8 09 89 10 f0       	mov    $0xf0108909,%eax
f0104a07:	be 5a 8a 10 f0       	mov    $0xf0108a5a,%esi
f0104a0c:	0f 44 c6             	cmove  %esi,%eax
f0104a0f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104a13:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104a17:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a1b:	c7 04 24 81 89 10 f0 	movl   $0xf0108981,(%esp)
f0104a22:	e8 77 fc ff ff       	call   f010469e <cprintf>
f0104a27:	eb 0c                	jmp    f0104a35 <print_trapframe+0x12f>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104a29:	c7 04 24 fd 86 10 f0 	movl   $0xf01086fd,(%esp)
f0104a30:	e8 69 fc ff ff       	call   f010469e <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104a35:	8b 43 30             	mov    0x30(%ebx),%eax
f0104a38:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a3c:	c7 04 24 90 89 10 f0 	movl   $0xf0108990,(%esp)
f0104a43:	e8 56 fc ff ff       	call   f010469e <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104a48:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104a4c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a50:	c7 04 24 9f 89 10 f0 	movl   $0xf010899f,(%esp)
f0104a57:	e8 42 fc ff ff       	call   f010469e <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104a5c:	8b 43 38             	mov    0x38(%ebx),%eax
f0104a5f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a63:	c7 04 24 b2 89 10 f0 	movl   $0xf01089b2,(%esp)
f0104a6a:	e8 2f fc ff ff       	call   f010469e <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104a6f:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104a73:	74 27                	je     f0104a9c <print_trapframe+0x196>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104a75:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104a78:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a7c:	c7 04 24 c1 89 10 f0 	movl   $0xf01089c1,(%esp)
f0104a83:	e8 16 fc ff ff       	call   f010469e <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104a88:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104a8c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a90:	c7 04 24 d0 89 10 f0 	movl   $0xf01089d0,(%esp)
f0104a97:	e8 02 fc ff ff       	call   f010469e <cprintf>
	}
}
f0104a9c:	83 c4 10             	add    $0x10,%esp
f0104a9f:	5b                   	pop    %ebx
f0104aa0:	5e                   	pop    %esi
f0104aa1:	5d                   	pop    %ebp
f0104aa2:	c3                   	ret    

f0104aa3 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104aa3:	55                   	push   %ebp
f0104aa4:	89 e5                	mov    %esp,%ebp
f0104aa6:	83 ec 28             	sub    $0x28,%esp
f0104aa9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104aac:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104aaf:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104ab2:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104ab5:	0f 20 d6             	mov    %cr2,%esi

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	if ((tf->tf_cs & 3) != 3) {
f0104ab8:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104abc:	83 e0 03             	and    $0x3,%eax
f0104abf:	66 83 f8 03          	cmp    $0x3,%ax
f0104ac3:	74 1c                	je     f0104ae1 <page_fault_handler+0x3e>
		panic("Page fault in kernel mode.\n");
f0104ac5:	c7 44 24 08 e3 89 10 	movl   $0xf01089e3,0x8(%esp)
f0104acc:	f0 
f0104acd:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
f0104ad4:	00 
f0104ad5:	c7 04 24 ff 89 10 f0 	movl   $0xf01089ff,(%esp)
f0104adc:	e8 5f b5 ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	// Destroy the environment that caused the fault.
	if (!curenv->env_pgfault_upcall) {
f0104ae1:	e8 c6 21 00 00       	call   f0106cac <cpunum>
f0104ae6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ae9:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104aef:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104af3:	75 4f                	jne    f0104b44 <page_fault_handler+0xa1>
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104af5:	8b 7b 30             	mov    0x30(%ebx),%edi
				curenv->env_id, fault_va, tf->tf_eip);
f0104af8:	e8 af 21 00 00       	call   f0106cac <cpunum>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	// Destroy the environment that caused the fault.
	if (!curenv->env_pgfault_upcall) {
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104afd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104b01:	89 74 24 08          	mov    %esi,0x8(%esp)
				curenv->env_id, fault_va, tf->tf_eip);
f0104b05:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b08:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	// Destroy the environment that caused the fault.
	if (!curenv->env_pgfault_upcall) {
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104b0e:	8b 40 48             	mov    0x48(%eax),%eax
f0104b11:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b15:	c7 04 24 fc 87 10 f0 	movl   $0xf01087fc,(%esp)
f0104b1c:	e8 7d fb ff ff       	call   f010469e <cprintf>
				curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
f0104b21:	89 1c 24             	mov    %ebx,(%esp)
f0104b24:	e8 dd fd ff ff       	call   f0104906 <print_trapframe>
		env_destroy(curenv);
f0104b29:	e8 7e 21 00 00       	call   f0106cac <cpunum>
f0104b2e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b31:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104b37:	89 04 24             	mov    %eax,(%esp)
f0104b3a:	e8 72 f8 ff ff       	call   f01043b1 <env_destroy>
f0104b3f:	e9 ab 01 00 00       	jmp    f0104cef <page_fault_handler+0x24c>
		return;
	}

	uint32_t* user_stack;

	if (tf->tf_esp >= UXSTACKTOP - PGSIZE && tf->tf_esp <= UXSTACKTOP - 1) {
f0104b44:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104b47:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
f0104b4d:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104b53:	0f 87 96 00 00 00    	ja     f0104bef <page_fault_handler+0x14c>
		if (tf->tf_esp - sizeof(struct UTrapframe) < UXSTACKTOP - PGSIZE) {
f0104b59:	83 e8 34             	sub    $0x34,%eax
f0104b5c:	3d ff ef bf ee       	cmp    $0xeebfefff,%eax
f0104b61:	77 0c                	ja     f0104b6f <page_fault_handler+0xcc>
			cprintf("Crossing User Stack boundaries.\n");
f0104b63:	c7 04 24 20 88 10 f0 	movl   $0xf0108820,(%esp)
f0104b6a:	e8 2f fb ff ff       	call   f010469e <cprintf>
		}
		tf->tf_esp = tf->tf_esp - 4;
f0104b6f:	83 6b 3c 04          	subl   $0x4,0x3c(%ebx)
		lcr3(PADDR(curenv->env_pgdir));
f0104b73:	e8 34 21 00 00       	call   f0106cac <cpunum>
f0104b78:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b7b:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104b81:	8b 48 60             	mov    0x60(%eax),%ecx
f0104b84:	ba 61 01 00 00       	mov    $0x161,%edx
f0104b89:	b8 ff 89 10 f0       	mov    $0xf01089ff,%eax
f0104b8e:	e8 2d fb ff ff       	call   f01046c0 <_paddr>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104b93:	0f 22 d8             	mov    %eax,%cr3
		*((uint32_t*)tf->tf_esp) = 0;
f0104b96:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104b99:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		lcr3(PADDR(kern_pgdir));
f0104b9f:	8b 0d 8c be 22 f0    	mov    0xf022be8c,%ecx
f0104ba5:	ba 63 01 00 00       	mov    $0x163,%edx
f0104baa:	b8 ff 89 10 f0       	mov    $0xf01089ff,%eax
f0104baf:	e8 0c fb ff ff       	call   f01046c0 <_paddr>
f0104bb4:	0f 22 d8             	mov    %eax,%cr3

		user_stack = (uint32_t*)tf->tf_esp;
f0104bb7:	8b 7b 3c             	mov    0x3c(%ebx),%edi
		tf->tf_esp = tf->tf_esp + 4;
f0104bba:	8d 47 04             	lea    0x4(%edi),%eax
f0104bbd:	89 43 3c             	mov    %eax,0x3c(%ebx)
	   	user_stack -= 13;	
f0104bc0:	83 ef 34             	sub    $0x34,%edi
		user_mem_assert(curenv, (void*)user_stack, 
f0104bc3:	e8 e4 20 00 00       	call   f0106cac <cpunum>
f0104bc8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f0104bcf:	00 
f0104bd0:	c7 44 24 08 38 00 00 	movl   $0x38,0x8(%esp)
f0104bd7:	00 
f0104bd8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104bdc:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bdf:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104be5:	89 04 24             	mov    %eax,(%esp)
f0104be8:	e8 67 f0 ff ff       	call   f0103c54 <user_mem_assert>
f0104bed:	eb 33                	jmp    f0104c22 <page_fault_handler+0x17f>
						sizeof(struct UTrapframe) + 4, PTE_U | PTE_P);
	} else {
		user_stack = (uint32_t*)(UXSTACKTOP);
	   	user_stack -= 13;	
		user_mem_assert(curenv, (void*)user_stack, sizeof(struct UTrapframe),
f0104bef:	e8 b8 20 00 00       	call   f0106cac <cpunum>
f0104bf4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f0104bfb:	00 
f0104bfc:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f0104c03:	00 
f0104c04:	c7 44 24 04 cc ff bf 	movl   $0xeebfffcc,0x4(%esp)
f0104c0b:	ee 
f0104c0c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c0f:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104c15:	89 04 24             	mov    %eax,(%esp)
f0104c18:	e8 37 f0 ff ff       	call   f0103c54 <user_mem_assert>
	   	user_stack -= 13;	
		user_mem_assert(curenv, (void*)user_stack, 
						sizeof(struct UTrapframe) + 4, PTE_U | PTE_P);
	} else {
		user_stack = (uint32_t*)(UXSTACKTOP);
	   	user_stack -= 13;	
f0104c1d:	bf cc ff bf ee       	mov    $0xeebfffcc,%edi
		user_mem_assert(curenv, (void*)user_stack, sizeof(struct UTrapframe),
						PTE_U | PTE_P);
	}
	
	uint32_t user_stack_start = (uint32_t)user_stack;
	lcr3(PADDR(curenv->env_pgdir));
f0104c22:	e8 85 20 00 00       	call   f0106cac <cpunum>
f0104c27:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c2a:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104c30:	8b 48 60             	mov    0x60(%eax),%ecx
f0104c33:	ba 72 01 00 00       	mov    $0x172,%edx
f0104c38:	b8 ff 89 10 f0       	mov    $0xf01089ff,%eax
f0104c3d:	e8 7e fa ff ff       	call   f01046c0 <_paddr>
f0104c42:	0f 22 d8             	mov    %eax,%cr3
	*((uint32_t*)user_stack) = fault_va;
f0104c45:	89 37                	mov    %esi,(%edi)
	user_stack++;
	*((uint32_t*)user_stack) = tf->tf_err;
f0104c47:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104c4a:	89 47 04             	mov    %eax,0x4(%edi)
	user_stack++;
	*((uint32_t*)user_stack) = tf->tf_regs.reg_edi;
f0104c4d:	8b 03                	mov    (%ebx),%eax
f0104c4f:	89 47 08             	mov    %eax,0x8(%edi)
	user_stack++;
	*((uint32_t*)user_stack) = tf->tf_regs.reg_esi;
f0104c52:	8b 43 04             	mov    0x4(%ebx),%eax
f0104c55:	89 47 0c             	mov    %eax,0xc(%edi)
	user_stack++;
	*((uint32_t*)user_stack) = tf->tf_regs.reg_ebp;
f0104c58:	8b 43 08             	mov    0x8(%ebx),%eax
f0104c5b:	89 47 10             	mov    %eax,0x10(%edi)
	user_stack++;
	*((uint32_t*)user_stack) = tf->tf_esp;
f0104c5e:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104c61:	89 47 14             	mov    %eax,0x14(%edi)
	user_stack++;
	*((uint32_t*)user_stack) = tf->tf_regs.reg_ebx;
f0104c64:	8b 43 10             	mov    0x10(%ebx),%eax
f0104c67:	89 47 18             	mov    %eax,0x18(%edi)
	user_stack++;
	*((uint32_t*)user_stack) = tf->tf_regs.reg_edx;
f0104c6a:	8b 43 14             	mov    0x14(%ebx),%eax
f0104c6d:	89 47 1c             	mov    %eax,0x1c(%edi)
	user_stack++;
	*((uint32_t*)user_stack) = tf->tf_regs.reg_ecx;
f0104c70:	8b 43 18             	mov    0x18(%ebx),%eax
f0104c73:	89 47 20             	mov    %eax,0x20(%edi)
	user_stack++;
	*((uint32_t*)user_stack) = tf->tf_regs.reg_eax;
f0104c76:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104c79:	89 47 24             	mov    %eax,0x24(%edi)
	user_stack++;
	*((uint32_t*)user_stack) = tf->tf_eip;
f0104c7c:	8b 43 30             	mov    0x30(%ebx),%eax
f0104c7f:	89 47 28             	mov    %eax,0x28(%edi)
	user_stack++;
	*((uint32_t*)user_stack) = tf->tf_eflags;
f0104c82:	8b 43 38             	mov    0x38(%ebx),%eax
f0104c85:	89 47 2c             	mov    %eax,0x2c(%edi)
	user_stack++;
	*((uint32_t*)user_stack) = tf->tf_esp;
f0104c88:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104c8b:	89 47 30             	mov    %eax,0x30(%edi)
	lcr3(PADDR(kern_pgdir));
f0104c8e:	8b 0d 8c be 22 f0    	mov    0xf022be8c,%ecx
f0104c94:	ba 8c 01 00 00       	mov    $0x18c,%edx
f0104c99:	b8 ff 89 10 f0       	mov    $0xf01089ff,%eax
f0104c9e:	e8 1d fa ff ff       	call   f01046c0 <_paddr>
f0104ca3:	0f 22 d8             	mov    %eax,%cr3

	curenv->env_tf.tf_eip = (uint32_t)(curenv->env_pgfault_upcall);
f0104ca6:	e8 01 20 00 00       	call   f0106cac <cpunum>
f0104cab:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cae:	8b 98 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%ebx
f0104cb4:	e8 f3 1f 00 00       	call   f0106cac <cpunum>
f0104cb9:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cbc:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104cc2:	8b 40 64             	mov    0x64(%eax),%eax
f0104cc5:	89 43 30             	mov    %eax,0x30(%ebx)
	curenv->env_tf.tf_esp = (uint32_t)(user_stack_start); 
f0104cc8:	e8 df 1f 00 00       	call   f0106cac <cpunum>
f0104ccd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cd0:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104cd6:	89 78 3c             	mov    %edi,0x3c(%eax)
	env_run(curenv);
f0104cd9:	e8 ce 1f 00 00       	call   f0106cac <cpunum>
f0104cde:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ce1:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104ce7:	89 04 24             	mov    %eax,(%esp)
f0104cea:	e8 63 f7 ff ff       	call   f0104452 <env_run>
}
f0104cef:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104cf2:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0104cf5:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0104cf8:	89 ec                	mov    %ebp,%esp
f0104cfa:	5d                   	pop    %ebp
f0104cfb:	c3                   	ret    

f0104cfc <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104cfc:	55                   	push   %ebp
f0104cfd:	89 e5                	mov    %esp,%ebp
f0104cff:	57                   	push   %edi
f0104d00:	56                   	push   %esi
f0104d01:	83 ec 20             	sub    $0x20,%esp
f0104d04:	8b 75 08             	mov    0x8(%ebp),%esi
	// cprintf("Entered trap\n");
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104d07:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104d08:	83 3d 80 be 22 f0 00 	cmpl   $0x0,0xf022be80
f0104d0f:	74 01                	je     f0104d12 <trap+0x16>
		asm volatile("hlt");
f0104d11:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104d12:	e8 95 1f 00 00       	call   f0106cac <cpunum>
f0104d17:	6b d0 74             	imul   $0x74,%eax,%edx
f0104d1a:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104d20:	b8 01 00 00 00       	mov    $0x1,%eax
f0104d25:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104d29:	83 f8 02             	cmp    $0x2,%eax
f0104d2c:	75 0c                	jne    f0104d3a <trap+0x3e>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104d2e:	c7 04 24 a0 34 12 f0 	movl   $0xf01234a0,(%esp)
f0104d35:	e8 23 22 00 00       	call   f0106f5d <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104d3a:	9c                   	pushf  
f0104d3b:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104d3c:	f6 c4 02             	test   $0x2,%ah
f0104d3f:	74 24                	je     f0104d65 <trap+0x69>
f0104d41:	c7 44 24 0c 0b 8a 10 	movl   $0xf0108a0b,0xc(%esp)
f0104d48:	f0 
f0104d49:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0104d50:	f0 
f0104d51:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
f0104d58:	00 
f0104d59:	c7 04 24 ff 89 10 f0 	movl   $0xf01089ff,(%esp)
f0104d60:	e8 db b2 ff ff       	call   f0100040 <_panic>
	if ((tf->tf_cs & 3) == 3) {
f0104d65:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104d69:	83 e0 03             	and    $0x3,%eax
f0104d6c:	66 83 f8 03          	cmp    $0x3,%ax
f0104d70:	0f 85 a7 00 00 00    	jne    f0104e1d <trap+0x121>
f0104d76:	c7 04 24 a0 34 12 f0 	movl   $0xf01234a0,(%esp)
f0104d7d:	e8 db 21 00 00       	call   f0106f5d <spin_lock>
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		int i;

		assert(curenv);
f0104d82:	e8 25 1f 00 00       	call   f0106cac <cpunum>
f0104d87:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d8a:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0104d91:	75 24                	jne    f0104db7 <trap+0xbb>
f0104d93:	c7 44 24 0c 24 8a 10 	movl   $0xf0108a24,0xc(%esp)
f0104d9a:	f0 
f0104d9b:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0104da2:	f0 
f0104da3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0104daa:	00 
f0104dab:	c7 04 24 ff 89 10 f0 	movl   $0xf01089ff,(%esp)
f0104db2:	e8 89 b2 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104db7:	e8 f0 1e 00 00       	call   f0106cac <cpunum>
f0104dbc:	6b c0 74             	imul   $0x74,%eax,%eax
f0104dbf:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104dc5:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104dc9:	75 2d                	jne    f0104df8 <trap+0xfc>
			env_free(curenv);
f0104dcb:	e8 dc 1e 00 00       	call   f0106cac <cpunum>
f0104dd0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104dd3:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104dd9:	89 04 24             	mov    %eax,(%esp)
f0104ddc:	e8 ca f3 ff ff       	call   f01041ab <env_free>
			curenv = NULL;
f0104de1:	e8 c6 1e 00 00       	call   f0106cac <cpunum>
f0104de6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104de9:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f0104df0:	00 00 00 
			sched_yield();
f0104df3:	e8 3c 04 00 00       	call   f0105234 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104df8:	e8 af 1e 00 00       	call   f0106cac <cpunum>
f0104dfd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e00:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104e06:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104e0b:	89 c7                	mov    %eax,%edi
f0104e0d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104e0f:	e8 98 1e 00 00       	call   f0106cac <cpunum>
f0104e14:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e17:	8b b0 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104e1d:	89 35 60 ba 22 f0    	mov    %esi,0xf022ba60
	// LAB 3: Your code here.

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104e23:	8b 46 28             	mov    0x28(%esi),%eax
f0104e26:	83 f8 27             	cmp    $0x27,%eax
f0104e29:	75 19                	jne    f0104e44 <trap+0x148>
		cprintf("Spurious interrupt on irq 7\n");
f0104e2b:	c7 04 24 2b 8a 10 f0 	movl   $0xf0108a2b,(%esp)
f0104e32:	e8 67 f8 ff ff       	call   f010469e <cprintf>
		print_trapframe(tf);
f0104e37:	89 34 24             	mov    %esi,(%esp)
f0104e3a:	e8 c7 fa ff ff       	call   f0104906 <print_trapframe>
f0104e3f:	e9 b1 00 00 00       	jmp    f0104ef5 <trap+0x1f9>

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f0104e44:	83 f8 20             	cmp    $0x20,%eax
f0104e47:	75 11                	jne    f0104e5a <trap+0x15e>
		lapic_eoi();
f0104e49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104e50:	e8 a4 1f 00 00       	call   f0106df9 <lapic_eoi>
		sched_yield();
f0104e55:	e8 da 03 00 00       	call   f0105234 <sched_yield>
	}

	int ret;
	if (tf->tf_trapno == T_PGFLT) {
f0104e5a:	83 f8 0e             	cmp    $0xe,%eax
f0104e5d:	75 0d                	jne    f0104e6c <trap+0x170>
		page_fault_handler(tf);
f0104e5f:	89 34 24             	mov    %esi,(%esp)
f0104e62:	e8 3c fc ff ff       	call   f0104aa3 <page_fault_handler>
f0104e67:	e9 89 00 00 00       	jmp    f0104ef5 <trap+0x1f9>
		return;
	} else if (tf->tf_trapno == T_BRKPT) {
f0104e6c:	83 f8 03             	cmp    $0x3,%eax
f0104e6f:	90                   	nop
f0104e70:	75 0a                	jne    f0104e7c <trap+0x180>
		monitor(tf);
f0104e72:	89 34 24             	mov    %esi,(%esp)
f0104e75:	e8 26 be ff ff       	call   f0100ca0 <monitor>
f0104e7a:	eb 79                	jmp    f0104ef5 <trap+0x1f9>
		return;
	} else if (tf->tf_trapno == T_SYSCALL) {
f0104e7c:	83 f8 30             	cmp    $0x30,%eax
f0104e7f:	90                   	nop
f0104e80:	75 32                	jne    f0104eb4 <trap+0x1b8>
		ret = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx,
f0104e82:	8b 46 04             	mov    0x4(%esi),%eax
f0104e85:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104e89:	8b 06                	mov    (%esi),%eax
f0104e8b:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104e8f:	8b 46 10             	mov    0x10(%esi),%eax
f0104e92:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104e96:	8b 46 18             	mov    0x18(%esi),%eax
f0104e99:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104e9d:	8b 46 14             	mov    0x14(%esi),%eax
f0104ea0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ea4:	8b 46 1c             	mov    0x1c(%esi),%eax
f0104ea7:	89 04 24             	mov    %eax,(%esp)
f0104eaa:	e8 51 04 00 00       	call   f0105300 <syscall>
					  tf->tf_regs.reg_ecx, tf->tf_regs.reg_ebx,
					  tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
		tf->tf_regs.reg_eax = ret;
f0104eaf:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104eb2:	eb 41                	jmp    f0104ef5 <trap+0x1f9>
		return;
	} 
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104eb4:	89 34 24             	mov    %esi,(%esp)
f0104eb7:	e8 4a fa ff ff       	call   f0104906 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104ebc:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104ec1:	75 1c                	jne    f0104edf <trap+0x1e3>
		panic("unhandled trap in kernel");
f0104ec3:	c7 44 24 08 48 8a 10 	movl   $0xf0108a48,0x8(%esp)
f0104eca:	f0 
f0104ecb:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
f0104ed2:	00 
f0104ed3:	c7 04 24 ff 89 10 f0 	movl   $0xf01089ff,(%esp)
f0104eda:	e8 61 b1 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104edf:	e8 c8 1d 00 00       	call   f0106cac <cpunum>
f0104ee4:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ee7:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104eed:	89 04 24             	mov    %eax,(%esp)
f0104ef0:	e8 bc f4 ff ff       	call   f01043b1 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING) {
f0104ef5:	e8 b2 1d 00 00       	call   f0106cac <cpunum>
f0104efa:	6b c0 74             	imul   $0x74,%eax,%eax
f0104efd:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0104f04:	74 2a                	je     f0104f30 <trap+0x234>
f0104f06:	e8 a1 1d 00 00       	call   f0106cac <cpunum>
f0104f0b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f0e:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104f14:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104f18:	75 16                	jne    f0104f30 <trap+0x234>
		env_run(curenv);
f0104f1a:	e8 8d 1d 00 00       	call   f0106cac <cpunum>
f0104f1f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f22:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104f28:	89 04 24             	mov    %eax,(%esp)
f0104f2b:	e8 22 f5 ff ff       	call   f0104452 <env_run>
	}
	else {
		sched_yield();
f0104f30:	e8 ff 02 00 00       	call   f0105234 <sched_yield>
f0104f35:	66 90                	xchg   %ax,%ax
f0104f37:	90                   	nop

f0104f38 <trap0>:
 * Lab 3: Your code here for generating entry points for the different traps.
 */

/*TODO check the error code popping */

	TRAPHANDLER_NOEC(trap0, T_DIVIDE);
f0104f38:	6a 00                	push   $0x0
f0104f3a:	6a 00                	push   $0x0
f0104f3c:	e9 fe 01 00 00       	jmp    f010513f <_alltraps>
f0104f41:	90                   	nop

f0104f42 <trap1>:
	TRAPHANDLER_NOEC(trap1, T_DEBUG);
f0104f42:	6a 00                	push   $0x0
f0104f44:	6a 01                	push   $0x1
f0104f46:	e9 f4 01 00 00       	jmp    f010513f <_alltraps>
f0104f4b:	90                   	nop

f0104f4c <trap2>:
	TRAPHANDLER_NOEC(trap2, T_NMI);
f0104f4c:	6a 00                	push   $0x0
f0104f4e:	6a 02                	push   $0x2
f0104f50:	e9 ea 01 00 00       	jmp    f010513f <_alltraps>
f0104f55:	90                   	nop

f0104f56 <trap3>:
	TRAPHANDLER_NOEC(trap3, T_BRKPT);
f0104f56:	6a 00                	push   $0x0
f0104f58:	6a 03                	push   $0x3
f0104f5a:	e9 e0 01 00 00       	jmp    f010513f <_alltraps>
f0104f5f:	90                   	nop

f0104f60 <trap4>:
	TRAPHANDLER_NOEC(trap4, T_OFLOW);
f0104f60:	6a 00                	push   $0x0
f0104f62:	6a 04                	push   $0x4
f0104f64:	e9 d6 01 00 00       	jmp    f010513f <_alltraps>
f0104f69:	90                   	nop

f0104f6a <trap5>:
	TRAPHANDLER_NOEC(trap5, T_BOUND);
f0104f6a:	6a 00                	push   $0x0
f0104f6c:	6a 05                	push   $0x5
f0104f6e:	e9 cc 01 00 00       	jmp    f010513f <_alltraps>
f0104f73:	90                   	nop

f0104f74 <trap6>:
	TRAPHANDLER_NOEC(trap6, T_ILLOP);
f0104f74:	6a 00                	push   $0x0
f0104f76:	6a 06                	push   $0x6
f0104f78:	e9 c2 01 00 00       	jmp    f010513f <_alltraps>
f0104f7d:	90                   	nop

f0104f7e <trap7>:
	TRAPHANDLER_NOEC(trap7, T_DEVICE);
f0104f7e:	6a 00                	push   $0x0
f0104f80:	6a 07                	push   $0x7
f0104f82:	e9 b8 01 00 00       	jmp    f010513f <_alltraps>
f0104f87:	90                   	nop

f0104f88 <trap8>:
	TRAPHANDLER_NOEC(trap8, T_DBLFLT);
f0104f88:	6a 00                	push   $0x0
f0104f8a:	6a 08                	push   $0x8
f0104f8c:	e9 ae 01 00 00       	jmp    f010513f <_alltraps>
f0104f91:	90                   	nop

f0104f92 <trap9>:
	TRAPHANDLER_NOEC(trap9, 9);
f0104f92:	6a 00                	push   $0x0
f0104f94:	6a 09                	push   $0x9
f0104f96:	e9 a4 01 00 00       	jmp    f010513f <_alltraps>
f0104f9b:	90                   	nop

f0104f9c <trap10>:
	TRAPHANDLER(trap10, T_TSS);
f0104f9c:	6a 0a                	push   $0xa
f0104f9e:	e9 9c 01 00 00       	jmp    f010513f <_alltraps>
f0104fa3:	90                   	nop

f0104fa4 <trap11>:
	TRAPHANDLER(trap11, T_SEGNP);
f0104fa4:	6a 0b                	push   $0xb
f0104fa6:	e9 94 01 00 00       	jmp    f010513f <_alltraps>
f0104fab:	90                   	nop

f0104fac <trap12>:
	TRAPHANDLER(trap12, T_STACK);
f0104fac:	6a 0c                	push   $0xc
f0104fae:	e9 8c 01 00 00       	jmp    f010513f <_alltraps>
f0104fb3:	90                   	nop

f0104fb4 <trap13>:
	TRAPHANDLER(trap13, T_GPFLT);
f0104fb4:	6a 0d                	push   $0xd
f0104fb6:	e9 84 01 00 00       	jmp    f010513f <_alltraps>
f0104fbb:	90                   	nop

f0104fbc <trap14>:
	TRAPHANDLER(trap14, T_PGFLT);
f0104fbc:	6a 0e                	push   $0xe
f0104fbe:	e9 7c 01 00 00       	jmp    f010513f <_alltraps>
f0104fc3:	90                   	nop

f0104fc4 <trap15>:
	TRAPHANDLER_NOEC(trap15, 15);
f0104fc4:	6a 00                	push   $0x0
f0104fc6:	6a 0f                	push   $0xf
f0104fc8:	e9 72 01 00 00       	jmp    f010513f <_alltraps>
f0104fcd:	90                   	nop

f0104fce <trap16>:
	TRAPHANDLER_NOEC(trap16, T_FPERR);
f0104fce:	6a 00                	push   $0x0
f0104fd0:	6a 10                	push   $0x10
f0104fd2:	e9 68 01 00 00       	jmp    f010513f <_alltraps>
f0104fd7:	90                   	nop

f0104fd8 <trap17>:
	TRAPHANDLER_NOEC(trap17, T_ALIGN);
f0104fd8:	6a 00                	push   $0x0
f0104fda:	6a 11                	push   $0x11
f0104fdc:	e9 5e 01 00 00       	jmp    f010513f <_alltraps>
f0104fe1:	90                   	nop

f0104fe2 <trap18>:
	TRAPHANDLER_NOEC(trap18, T_MCHK);
f0104fe2:	6a 00                	push   $0x0
f0104fe4:	6a 12                	push   $0x12
f0104fe6:	e9 54 01 00 00       	jmp    f010513f <_alltraps>
f0104feb:	90                   	nop

f0104fec <trap19>:
	TRAPHANDLER_NOEC(trap19, T_SIMDERR);
f0104fec:	6a 00                	push   $0x0
f0104fee:	6a 13                	push   $0x13
f0104ff0:	e9 4a 01 00 00       	jmp    f010513f <_alltraps>
f0104ff5:	90                   	nop

f0104ff6 <trap20>:
	TRAPHANDLER_NOEC(trap20, 20);
f0104ff6:	6a 00                	push   $0x0
f0104ff8:	6a 14                	push   $0x14
f0104ffa:	e9 40 01 00 00       	jmp    f010513f <_alltraps>
f0104fff:	90                   	nop

f0105000 <trap21>:
	TRAPHANDLER_NOEC(trap21, 21);
f0105000:	6a 00                	push   $0x0
f0105002:	6a 15                	push   $0x15
f0105004:	e9 36 01 00 00       	jmp    f010513f <_alltraps>
f0105009:	90                   	nop

f010500a <trap22>:
	TRAPHANDLER_NOEC(trap22, 22);
f010500a:	6a 00                	push   $0x0
f010500c:	6a 16                	push   $0x16
f010500e:	e9 2c 01 00 00       	jmp    f010513f <_alltraps>
f0105013:	90                   	nop

f0105014 <trap23>:
	TRAPHANDLER_NOEC(trap23, 23);
f0105014:	6a 00                	push   $0x0
f0105016:	6a 17                	push   $0x17
f0105018:	e9 22 01 00 00       	jmp    f010513f <_alltraps>
f010501d:	90                   	nop

f010501e <trap24>:
	TRAPHANDLER_NOEC(trap24, 24);
f010501e:	6a 00                	push   $0x0
f0105020:	6a 18                	push   $0x18
f0105022:	e9 18 01 00 00       	jmp    f010513f <_alltraps>
f0105027:	90                   	nop

f0105028 <trap25>:
	TRAPHANDLER_NOEC(trap25, 25);
f0105028:	6a 00                	push   $0x0
f010502a:	6a 19                	push   $0x19
f010502c:	e9 0e 01 00 00       	jmp    f010513f <_alltraps>
f0105031:	90                   	nop

f0105032 <trap26>:
	TRAPHANDLER_NOEC(trap26, 26);
f0105032:	6a 00                	push   $0x0
f0105034:	6a 1a                	push   $0x1a
f0105036:	e9 04 01 00 00       	jmp    f010513f <_alltraps>
f010503b:	90                   	nop

f010503c <trap27>:
	TRAPHANDLER_NOEC(trap27, 27);
f010503c:	6a 00                	push   $0x0
f010503e:	6a 1b                	push   $0x1b
f0105040:	e9 fa 00 00 00       	jmp    f010513f <_alltraps>
f0105045:	90                   	nop

f0105046 <trap28>:
	TRAPHANDLER_NOEC(trap28, 28);
f0105046:	6a 00                	push   $0x0
f0105048:	6a 1c                	push   $0x1c
f010504a:	e9 f0 00 00 00       	jmp    f010513f <_alltraps>
f010504f:	90                   	nop

f0105050 <trap29>:
	TRAPHANDLER_NOEC(trap29, 29);
f0105050:	6a 00                	push   $0x0
f0105052:	6a 1d                	push   $0x1d
f0105054:	e9 e6 00 00 00       	jmp    f010513f <_alltraps>
f0105059:	90                   	nop

f010505a <trap30>:
	TRAPHANDLER_NOEC(trap30, 30);
f010505a:	6a 00                	push   $0x0
f010505c:	6a 1e                	push   $0x1e
f010505e:	e9 dc 00 00 00       	jmp    f010513f <_alltraps>
f0105063:	90                   	nop

f0105064 <trap31>:
	TRAPHANDLER_NOEC(trap31, 31);
f0105064:	6a 00                	push   $0x0
f0105066:	6a 1f                	push   $0x1f
f0105068:	e9 d2 00 00 00       	jmp    f010513f <_alltraps>
f010506d:	90                   	nop

f010506e <trap32>:
	TRAPHANDLER_NOEC(trap32, IRQ_OFFSET + IRQ_TIMER);
f010506e:	6a 00                	push   $0x0
f0105070:	6a 20                	push   $0x20
f0105072:	e9 c8 00 00 00       	jmp    f010513f <_alltraps>
f0105077:	90                   	nop

f0105078 <trap33>:
	TRAPHANDLER_NOEC(trap33, IRQ_OFFSET + IRQ_KBD);
f0105078:	6a 00                	push   $0x0
f010507a:	6a 21                	push   $0x21
f010507c:	e9 be 00 00 00       	jmp    f010513f <_alltraps>
f0105081:	90                   	nop

f0105082 <trap34>:
	TRAPHANDLER_NOEC(trap34, 34);
f0105082:	6a 00                	push   $0x0
f0105084:	6a 22                	push   $0x22
f0105086:	e9 b4 00 00 00       	jmp    f010513f <_alltraps>
f010508b:	90                   	nop

f010508c <trap35>:
	TRAPHANDLER_NOEC(trap35, 35);
f010508c:	6a 00                	push   $0x0
f010508e:	6a 23                	push   $0x23
f0105090:	e9 aa 00 00 00       	jmp    f010513f <_alltraps>
f0105095:	90                   	nop

f0105096 <trap36>:
	TRAPHANDLER_NOEC(trap36, IRQ_OFFSET + IRQ_SERIAL);
f0105096:	6a 00                	push   $0x0
f0105098:	6a 24                	push   $0x24
f010509a:	e9 a0 00 00 00       	jmp    f010513f <_alltraps>
f010509f:	90                   	nop

f01050a0 <trap37>:
	TRAPHANDLER_NOEC(trap37, 37);
f01050a0:	6a 00                	push   $0x0
f01050a2:	6a 25                	push   $0x25
f01050a4:	e9 96 00 00 00       	jmp    f010513f <_alltraps>
f01050a9:	90                   	nop

f01050aa <trap38>:
	TRAPHANDLER_NOEC(trap38, 38);
f01050aa:	6a 00                	push   $0x0
f01050ac:	6a 26                	push   $0x26
f01050ae:	e9 8c 00 00 00       	jmp    f010513f <_alltraps>
f01050b3:	90                   	nop

f01050b4 <trap39>:
	TRAPHANDLER_NOEC(trap39, IRQ_OFFSET + IRQ_SPURIOUS);
f01050b4:	6a 00                	push   $0x0
f01050b6:	6a 27                	push   $0x27
f01050b8:	e9 82 00 00 00       	jmp    f010513f <_alltraps>
f01050bd:	90                   	nop

f01050be <trap40>:
	TRAPHANDLER_NOEC(trap40, 40);
f01050be:	6a 00                	push   $0x0
f01050c0:	6a 28                	push   $0x28
f01050c2:	e9 78 00 00 00       	jmp    f010513f <_alltraps>
f01050c7:	90                   	nop

f01050c8 <trap41>:
	TRAPHANDLER_NOEC(trap41, 41);
f01050c8:	6a 00                	push   $0x0
f01050ca:	6a 29                	push   $0x29
f01050cc:	e9 6e 00 00 00       	jmp    f010513f <_alltraps>
f01050d1:	90                   	nop

f01050d2 <trap42>:
	TRAPHANDLER_NOEC(trap42, 42);
f01050d2:	6a 00                	push   $0x0
f01050d4:	6a 2a                	push   $0x2a
f01050d6:	e9 64 00 00 00       	jmp    f010513f <_alltraps>
f01050db:	90                   	nop

f01050dc <trap43>:
	TRAPHANDLER_NOEC(trap43, 43);
f01050dc:	6a 00                	push   $0x0
f01050de:	6a 2b                	push   $0x2b
f01050e0:	e9 5a 00 00 00       	jmp    f010513f <_alltraps>
f01050e5:	90                   	nop

f01050e6 <trap44>:
	TRAPHANDLER_NOEC(trap44, 44);
f01050e6:	6a 00                	push   $0x0
f01050e8:	6a 2c                	push   $0x2c
f01050ea:	e9 50 00 00 00       	jmp    f010513f <_alltraps>
f01050ef:	90                   	nop

f01050f0 <trap45>:
	TRAPHANDLER_NOEC(trap45, 45);
f01050f0:	6a 00                	push   $0x0
f01050f2:	6a 2d                	push   $0x2d
f01050f4:	e9 46 00 00 00       	jmp    f010513f <_alltraps>
f01050f9:	90                   	nop

f01050fa <trap46>:
	TRAPHANDLER_NOEC(trap46, IRQ_OFFSET + IRQ_IDE);
f01050fa:	6a 00                	push   $0x0
f01050fc:	6a 2e                	push   $0x2e
f01050fe:	e9 3c 00 00 00       	jmp    f010513f <_alltraps>
f0105103:	90                   	nop

f0105104 <trap47>:
	TRAPHANDLER_NOEC(trap47, 47);
f0105104:	6a 00                	push   $0x0
f0105106:	6a 2f                	push   $0x2f
f0105108:	e9 32 00 00 00       	jmp    f010513f <_alltraps>
f010510d:	90                   	nop

f010510e <trap48>:
	TRAPHANDLER_NOEC(trap48, T_SYSCALL);
f010510e:	6a 00                	push   $0x0
f0105110:	6a 30                	push   $0x30
f0105112:	e9 28 00 00 00       	jmp    f010513f <_alltraps>
f0105117:	90                   	nop

f0105118 <trap49>:
	TRAPHANDLER_NOEC(trap49, 49);
f0105118:	6a 00                	push   $0x0
f010511a:	6a 31                	push   $0x31
f010511c:	e9 1e 00 00 00       	jmp    f010513f <_alltraps>
f0105121:	90                   	nop

f0105122 <trap50>:
	TRAPHANDLER_NOEC(trap50, 50);
f0105122:	6a 00                	push   $0x0
f0105124:	6a 32                	push   $0x32
f0105126:	e9 14 00 00 00       	jmp    f010513f <_alltraps>
f010512b:	90                   	nop

f010512c <trap51>:
	TRAPHANDLER_NOEC(trap51, IRQ_OFFSET + IRQ_ERROR);
f010512c:	6a 00                	push   $0x0
f010512e:	6a 33                	push   $0x33
f0105130:	e9 0a 00 00 00       	jmp    f010513f <_alltraps>
f0105135:	90                   	nop

f0105136 <trap52>:
	TRAPHANDLER_NOEC(trap52, 52);
f0105136:	6a 00                	push   $0x0
f0105138:	6a 34                	push   $0x34
f010513a:	e9 00 00 00 00       	jmp    f010513f <_alltraps>

f010513f <_alltraps>:
 * Lab 3: Your code here for _alltraps
 */

.globl _alltraps
_alltraps:
	pushl %ds
f010513f:	1e                   	push   %ds
	pushl %es
f0105140:	06                   	push   %es
	pushal
f0105141:	60                   	pusha  

	movw $GD_KD, %ax
f0105142:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax, %ds
f0105146:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0105148:	8e c0                	mov    %eax,%es
	pushl %esp
f010514a:	54                   	push   %esp
	call trap
f010514b:	e8 ac fb ff ff       	call   f0104cfc <trap>

f0105150 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0105150:	55                   	push   %ebp
f0105151:	89 e5                	mov    %esp,%ebp
f0105153:	83 ec 18             	sub    $0x18,%esp
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0105156:	8b 15 4c b2 22 f0    	mov    0xf022b24c,%edx
f010515c:	8b 42 54             	mov    0x54(%edx),%eax
f010515f:	83 e8 02             	sub    $0x2,%eax
f0105162:	83 f8 01             	cmp    $0x1,%eax
f0105165:	76 45                	jbe    f01051ac <sched_halt+0x5c>

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
f0105167:	81 c2 d0 00 00 00    	add    $0xd0,%edx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010516d:	b8 01 00 00 00       	mov    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0105172:	8b 0a                	mov    (%edx),%ecx
f0105174:	83 e9 02             	sub    $0x2,%ecx
f0105177:	83 f9 01             	cmp    $0x1,%ecx
f010517a:	76 0f                	jbe    f010518b <sched_halt+0x3b>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010517c:	83 c0 01             	add    $0x1,%eax
f010517f:	83 c2 7c             	add    $0x7c,%edx
f0105182:	3d 00 04 00 00       	cmp    $0x400,%eax
f0105187:	75 e9                	jne    f0105172 <sched_halt+0x22>
f0105189:	eb 07                	jmp    f0105192 <sched_halt+0x42>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
f010518b:	3d 00 04 00 00       	cmp    $0x400,%eax
f0105190:	75 1a                	jne    f01051ac <sched_halt+0x5c>
		cprintf("No runnable environments in the system!\n");
f0105192:	c7 04 24 10 8c 10 f0 	movl   $0xf0108c10,(%esp)
f0105199:	e8 00 f5 ff ff       	call   f010469e <cprintf>
		while (1)
			monitor(NULL);
f010519e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01051a5:	e8 f6 ba ff ff       	call   f0100ca0 <monitor>
f01051aa:	eb f2                	jmp    f010519e <sched_halt+0x4e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01051ac:	e8 fb 1a 00 00       	call   f0106cac <cpunum>
f01051b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01051b4:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f01051bb:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01051be:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01051c3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01051c8:	77 20                	ja     f01051ea <sched_halt+0x9a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01051ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01051ce:	c7 44 24 08 44 74 10 	movl   $0xf0107444,0x8(%esp)
f01051d5:	f0 
f01051d6:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01051dd:	00 
f01051de:	c7 04 24 39 8c 10 f0 	movl   $0xf0108c39,(%esp)
f01051e5:	e8 56 ae ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01051ea:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01051ef:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01051f2:	e8 b5 1a 00 00       	call   f0106cac <cpunum>
f01051f7:	6b d0 74             	imul   $0x74,%eax,%edx
f01051fa:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105200:	b8 02 00 00 00       	mov    $0x2,%eax
f0105205:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0105209:	c7 04 24 a0 34 12 f0 	movl   $0xf01234a0,(%esp)
f0105210:	e8 0b 1e 00 00       	call   f0107020 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0105215:	f3 90                	pause  
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0105217:	e8 90 1a 00 00       	call   f0106cac <cpunum>
f010521c:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f010521f:	8b 80 30 c0 22 f0    	mov    -0xfdd3fd0(%eax),%eax
f0105225:	bd 00 00 00 00       	mov    $0x0,%ebp
f010522a:	89 c4                	mov    %eax,%esp
f010522c:	6a 00                	push   $0x0
f010522e:	6a 00                	push   $0x0
f0105230:	fb                   	sti    
f0105231:	f4                   	hlt    
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0105232:	c9                   	leave  
f0105233:	c3                   	ret    

f0105234 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0105234:	55                   	push   %ebp
f0105235:	89 e5                	mov    %esp,%ebp
f0105237:	57                   	push   %edi
f0105238:	56                   	push   %esi
f0105239:	53                   	push   %ebx
f010523a:	83 ec 2c             	sub    $0x2c,%esp
f010523d:	bb 00 00 00 00       	mov    $0x0,%ebx

	
	int i;
	int cur_env = -1;
	
	for (i = 0; i < NENV; ++i) {
f0105242:	bf 00 00 00 00       	mov    $0x0,%edi
		if (envs + i == curenv) {
f0105247:	8b 35 4c b2 22 f0    	mov    0xf022b24c,%esi
f010524d:	01 de                	add    %ebx,%esi
f010524f:	e8 58 1a 00 00       	call   f0106cac <cpunum>
f0105254:	6b c0 74             	imul   $0x74,%eax,%eax
f0105257:	3b b0 28 c0 22 f0    	cmp    -0xfdd3fd8(%eax),%esi
f010525d:	74 13                	je     f0105272 <sched_yield+0x3e>

	
	int i;
	int cur_env = -1;
	
	for (i = 0; i < NENV; ++i) {
f010525f:	83 c7 01             	add    $0x1,%edi
f0105262:	83 c3 7c             	add    $0x7c,%ebx
f0105265:	81 ff 00 04 00 00    	cmp    $0x400,%edi
f010526b:	75 da                	jne    f0105247 <sched_yield+0x13>

	// LAB 4: Your code here.

	
	int i;
	int cur_env = -1;
f010526d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
	}
	
	int env;
	for (i = 0; i < NENV; ++i) {
		env = (cur_env + 1 + i) % NENV;
		if (envs[env].env_status == ENV_RUNNABLE) {
f0105272:	8b 1d 4c b2 22 f0    	mov    0xf022b24c,%ebx
		}
	}
	
	int env;
	for (i = 0; i < NENV; ++i) {
		env = (cur_env + 1 + i) % NENV;
f0105278:	8d 57 01             	lea    0x1(%edi),%edx
f010527b:	89 d0                	mov    %edx,%eax
f010527d:	c1 f8 1f             	sar    $0x1f,%eax
f0105280:	c1 e8 16             	shr    $0x16,%eax
f0105283:	01 c2                	add    %eax,%edx
f0105285:	89 d1                	mov    %edx,%ecx
f0105287:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f010528d:	29 c1                	sub    %eax,%ecx
		if (envs[env].env_status == ENV_RUNNABLE) {
f010528f:	6b c9 7c             	imul   $0x7c,%ecx,%ecx
f0105292:	01 d9                	add    %ebx,%ecx
f0105294:	83 79 54 02          	cmpl   $0x2,0x54(%ecx)
f0105298:	74 2a                	je     f01052c4 <sched_yield+0x90>

void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
f010529a:	8d 47 02             	lea    0x2(%edi),%eax
f010529d:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f01052a0:	8d b7 01 04 00 00    	lea    0x401(%edi),%esi
		}
	}
	
	int env;
	for (i = 0; i < NENV; ++i) {
		env = (cur_env + 1 + i) % NENV;
f01052a6:	89 c2                	mov    %eax,%edx
f01052a8:	c1 fa 1f             	sar    $0x1f,%edx
f01052ab:	c1 ea 16             	shr    $0x16,%edx
f01052ae:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
f01052b1:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f01052b7:	29 d1                	sub    %edx,%ecx
		if (envs[env].env_status == ENV_RUNNABLE) {
f01052b9:	6b c9 7c             	imul   $0x7c,%ecx,%ecx
f01052bc:	01 d9                	add    %ebx,%ecx
f01052be:	83 79 54 02          	cmpl   $0x2,0x54(%ecx)
f01052c2:	75 08                	jne    f01052cc <sched_yield+0x98>
			env_run(&(envs[env]));
f01052c4:	89 0c 24             	mov    %ecx,(%esp)
f01052c7:	e8 86 f1 ff ff       	call   f0104452 <env_run>
f01052cc:	83 c0 01             	add    $0x1,%eax
			break;
		}
	}
	
	int env;
	for (i = 0; i < NENV; ++i) {
f01052cf:	39 f0                	cmp    %esi,%eax
f01052d1:	75 d3                	jne    f01052a6 <sched_yield+0x72>
		if (envs[env].env_status == ENV_RUNNABLE) {
			env_run(&(envs[env]));
		}
	}

	if (cur_env != -1) {
f01052d3:	83 ff ff             	cmp    $0xffffffff,%edi
f01052d6:	74 14                	je     f01052ec <sched_yield+0xb8>
		if (envs[cur_env].env_status == ENV_RUNNING) {
f01052d8:	6b 45 e4 7c          	imul   $0x7c,-0x1c(%ebp),%eax
f01052dc:	01 c3                	add    %eax,%ebx
f01052de:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01052e2:	75 08                	jne    f01052ec <sched_yield+0xb8>
			// cprintf("%d\n", cur_env);
			env_run(&(envs[cur_env]));
f01052e4:	89 1c 24             	mov    %ebx,(%esp)
f01052e7:	e8 66 f1 ff ff       	call   f0104452 <env_run>
		}
	}

	// sched_halt never returns
	sched_halt();
f01052ec:	e8 5f fe ff ff       	call   f0105150 <sched_halt>
}
f01052f1:	83 c4 2c             	add    $0x2c,%esp
f01052f4:	5b                   	pop    %ebx
f01052f5:	5e                   	pop    %esi
f01052f6:	5f                   	pop    %edi
f01052f7:	5d                   	pop    %ebp
f01052f8:	c3                   	ret    
f01052f9:	66 90                	xchg   %ax,%ax
f01052fb:	66 90                	xchg   %ax,%ax
f01052fd:	66 90                	xchg   %ax,%ax
f01052ff:	90                   	nop

f0105300 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0105300:	55                   	push   %ebp
f0105301:	89 e5                	mov    %esp,%ebp
f0105303:	83 ec 38             	sub    $0x38,%esp
f0105306:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0105309:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010530c:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010530f:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int ret;
	switch (syscallno) {
f0105312:	83 f8 0c             	cmp    $0xc,%eax
f0105315:	0f 87 14 06 00 00    	ja     f010592f <syscall+0x62f>
f010531b:	ff 24 85 7c 8c 10 f0 	jmp    *-0xfef7384(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, (void*)s, len, 0);
f0105322:	e8 85 19 00 00       	call   f0106cac <cpunum>
f0105327:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010532e:	00 
f010532f:	8b 55 10             	mov    0x10(%ebp),%edx
f0105332:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105336:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105339:	89 54 24 04          	mov    %edx,0x4(%esp)
f010533d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105340:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0105346:	89 04 24             	mov    %eax,(%esp)
f0105349:	e8 06 e9 ff ff       	call   f0103c54 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f010534e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105351:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105355:	8b 55 10             	mov    0x10(%ebp),%edx
f0105358:	89 54 24 04          	mov    %edx,0x4(%esp)
f010535c:	c7 04 24 6d 77 10 f0 	movl   $0xf010776d,(%esp)
f0105363:	e8 36 f3 ff ff       	call   f010469e <cprintf>
	// LAB 3: Your code here.
	int ret;
	switch (syscallno) {
		case SYS_cputs: 
			sys_cputs((char*)a1, (size_t)a2);
			return 0;
f0105368:	bb 00 00 00 00       	mov    $0x0,%ebx
f010536d:	e9 c9 05 00 00       	jmp    f010593b <syscall+0x63b>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0105372:	e8 db b2 ff ff       	call   f0100652 <cons_getc>
f0105377:	89 c3                	mov    %eax,%ebx
		case SYS_cputs: 
			sys_cputs((char*)a1, (size_t)a2);
			return 0;
		case SYS_cgetc:
			ret = sys_cgetc();
			return ret;
f0105379:	e9 bd 05 00 00       	jmp    f010593b <syscall+0x63b>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f010537e:	66 90                	xchg   %ax,%ax
f0105380:	e8 27 19 00 00       	call   f0106cac <cpunum>
f0105385:	6b c0 74             	imul   $0x74,%eax,%eax
f0105388:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010538e:	8b 58 48             	mov    0x48(%eax),%ebx
		case SYS_cgetc:
			ret = sys_cgetc();
			return ret;
		case SYS_getenvid:
			ret = sys_getenvid();
			return ret;
f0105391:	e9 a5 05 00 00       	jmp    f010593b <syscall+0x63b>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0105396:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010539d:	00 
f010539e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01053a1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053a5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01053a8:	89 04 24             	mov    %eax,(%esp)
f01053ab:	e8 6e e9 ff ff       	call   f0103d1e <envid2env>
f01053b0:	89 c3                	mov    %eax,%ebx
f01053b2:	85 c0                	test   %eax,%eax
f01053b4:	0f 88 81 05 00 00    	js     f010593b <syscall+0x63b>
		return r;
	if (e == curenv)
f01053ba:	e8 ed 18 00 00       	call   f0106cac <cpunum>
f01053bf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01053c2:	6b c0 74             	imul   $0x74,%eax,%eax
f01053c5:	39 90 28 c0 22 f0    	cmp    %edx,-0xfdd3fd8(%eax)
f01053cb:	75 23                	jne    f01053f0 <syscall+0xf0>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01053cd:	e8 da 18 00 00       	call   f0106cac <cpunum>
f01053d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01053d5:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01053db:	8b 40 48             	mov    0x48(%eax),%eax
f01053de:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053e2:	c7 04 24 46 8c 10 f0 	movl   $0xf0108c46,(%esp)
f01053e9:	e8 b0 f2 ff ff       	call   f010469e <cprintf>
f01053ee:	eb 28                	jmp    f0105418 <syscall+0x118>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01053f0:	8b 5a 48             	mov    0x48(%edx),%ebx
f01053f3:	e8 b4 18 00 00       	call   f0106cac <cpunum>
f01053f8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01053fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01053ff:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0105405:	8b 40 48             	mov    0x48(%eax),%eax
f0105408:	89 44 24 04          	mov    %eax,0x4(%esp)
f010540c:	c7 04 24 61 8c 10 f0 	movl   $0xf0108c61,(%esp)
f0105413:	e8 86 f2 ff ff       	call   f010469e <cprintf>
	env_destroy(e);
f0105418:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010541b:	89 04 24             	mov    %eax,(%esp)
f010541e:	e8 8e ef ff ff       	call   f01043b1 <env_destroy>
	return 0;
f0105423:	bb 00 00 00 00       	mov    $0x0,%ebx
		case SYS_getenvid:
			ret = sys_getenvid();
			return ret;
		case SYS_env_destroy:
			ret = sys_env_destroy((envid_t)a1);
			return ret;
f0105428:	e9 0e 05 00 00       	jmp    f010593b <syscall+0x63b>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f010542d:	e8 02 fe ff ff       	call   f0105234 <sched_yield>
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env* new_env;
	int ret = env_alloc(&new_env, curenv->env_id);
f0105432:	e8 75 18 00 00       	call   f0106cac <cpunum>
f0105437:	6b c0 74             	imul   $0x74,%eax,%eax
f010543a:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0105440:	8b 40 48             	mov    0x48(%eax),%eax
f0105443:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105447:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010544a:	89 04 24             	mov    %eax,(%esp)
f010544d:	e8 27 ea ff ff       	call   f0103e79 <env_alloc>
f0105452:	89 c3                	mov    %eax,%ebx

	if (ret < 0) {
f0105454:	85 c0                	test   %eax,%eax
f0105456:	0f 88 df 04 00 00    	js     f010593b <syscall+0x63b>
		return ret;
	}

	new_env->env_status = ENV_NOT_RUNNABLE;
f010545c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010545f:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	new_env->env_tf = curenv->env_tf;
f0105466:	e8 41 18 00 00       	call   f0106cac <cpunum>
f010546b:	6b c0 74             	imul   $0x74,%eax,%eax
f010546e:	8b b0 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%esi
f0105474:	b9 11 00 00 00       	mov    $0x11,%ecx
f0105479:	89 df                	mov    %ebx,%edi
f010547b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	
	new_env->env_tf.tf_regs.reg_eax = 0;
f010547d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105480:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	
	return new_env->env_id;
f0105487:	8b 58 48             	mov    0x48(%eax),%ebx
		case SYS_yield:
			sys_yield();
			return 0;
		case SYS_exofork:
			ret = sys_exofork();
			return ret;
f010548a:	e9 ac 04 00 00       	jmp    f010593b <syscall+0x63b>
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) {
f010548f:	83 7d 10 04          	cmpl   $0x4,0x10(%ebp)
f0105493:	74 06                	je     f010549b <syscall+0x19b>
f0105495:	83 7d 10 02          	cmpl   $0x2,0x10(%ebp)
f0105499:	75 37                	jne    f01054d2 <syscall+0x1d2>
		return -E_INVAL;
	}

	struct Env* change_env;
	int ret = envid2env(envid, &change_env, 1);
f010549b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01054a2:	00 
f01054a3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01054a6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054aa:	8b 55 0c             	mov    0xc(%ebp),%edx
f01054ad:	89 14 24             	mov    %edx,(%esp)
f01054b0:	e8 69 e8 ff ff       	call   f0103d1e <envid2env>
f01054b5:	89 c3                	mov    %eax,%ebx
   	
	if (ret < 0) {
f01054b7:	85 c0                	test   %eax,%eax
f01054b9:	0f 88 7c 04 00 00    	js     f010593b <syscall+0x63b>
		return ret;
	}

	change_env->env_status = status;	
f01054bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01054c2:	8b 55 10             	mov    0x10(%ebp),%edx
f01054c5:	89 50 54             	mov    %edx,0x54(%eax)
	return 0;
f01054c8:	bb 00 00 00 00       	mov    $0x0,%ebx
f01054cd:	e9 69 04 00 00       	jmp    f010593b <syscall+0x63b>
	// envid's status.

	// LAB 4: Your code here.
	
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) {
		return -E_INVAL;
f01054d2:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		case SYS_exofork:
			ret = sys_exofork();
			return ret;
		case SYS_env_set_status:
			ret = sys_env_set_status(a1, a2);
			return ret;
f01054d7:	e9 5f 04 00 00       	jmp    f010593b <syscall+0x63b>
	//   allocated!

	// LAB 4: Your code here.
	
	struct Env*	env;
	int ret = envid2env(envid, &env, 1);
f01054dc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01054e3:	00 
f01054e4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01054e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054eb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01054ee:	89 04 24             	mov    %eax,(%esp)
f01054f1:	e8 28 e8 ff ff       	call   f0103d1e <envid2env>
f01054f6:	89 c3                	mov    %eax,%ebx
	if (ret < 0) {
f01054f8:	85 c0                	test   %eax,%eax
f01054fa:	0f 88 3b 04 00 00    	js     f010593b <syscall+0x63b>
		return ret;
	}

	if ((uint32_t)va >= UTOP || ((uint32_t)va % PGSIZE != 0)) {
f0105500:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105507:	77 6a                	ja     f0105573 <syscall+0x273>
f0105509:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0105510:	75 6b                	jne    f010557d <syscall+0x27d>
		return -E_INVAL;
	}

	if (((perm & PTE_SYSCALL) < (PTE_U | PTE_P)) ||
f0105512:	8b 45 14             	mov    0x14(%ebp),%eax
f0105515:	25 07 0e 00 00       	and    $0xe07,%eax
f010551a:	83 f8 04             	cmp    $0x4,%eax
f010551d:	7e 68                	jle    f0105587 <syscall+0x287>
		((perm | PTE_SYSCALL) > PTE_SYSCALL)) {
f010551f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105522:	0d 07 0e 00 00       	or     $0xe07,%eax

	if ((uint32_t)va >= UTOP || ((uint32_t)va % PGSIZE != 0)) {
		return -E_INVAL;
	}

	if (((perm & PTE_SYSCALL) < (PTE_U | PTE_P)) ||
f0105527:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f010552c:	7f 63                	jg     f0105591 <syscall+0x291>
		((perm | PTE_SYSCALL) > PTE_SYSCALL)) {
		return -E_INVAL;
	}
	
	struct PageInfo* new_page = page_alloc(1);
f010552e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0105535:	e8 a4 be ff ff       	call   f01013de <page_alloc>
f010553a:	89 c6                	mov    %eax,%esi
	if (!new_page) {
f010553c:	85 c0                	test   %eax,%eax
f010553e:	74 5b                	je     f010559b <syscall+0x29b>
		return -E_NO_MEM;
	}

	ret = page_insert(env->env_pgdir, new_page, va, perm);
f0105540:	8b 55 14             	mov    0x14(%ebp),%edx
f0105543:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105547:	8b 45 10             	mov    0x10(%ebp),%eax
f010554a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010554e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105552:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105555:	8b 40 60             	mov    0x60(%eax),%eax
f0105558:	89 04 24             	mov    %eax,(%esp)
f010555b:	e8 29 c4 ff ff       	call   f0101989 <page_insert>
f0105560:	89 c3                	mov    %eax,%ebx
	if (ret < 0) {
f0105562:	85 c0                	test   %eax,%eax
f0105564:	79 3f                	jns    f01055a5 <syscall+0x2a5>
		page_free(new_page);
f0105566:	89 34 24             	mov    %esi,(%esp)
f0105569:	e8 ee be ff ff       	call   f010145c <page_free>
f010556e:	e9 c8 03 00 00       	jmp    f010593b <syscall+0x63b>
	if (ret < 0) {
		return ret;
	}

	if ((uint32_t)va >= UTOP || ((uint32_t)va % PGSIZE != 0)) {
		return -E_INVAL;
f0105573:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105578:	e9 be 03 00 00       	jmp    f010593b <syscall+0x63b>
f010557d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105582:	e9 b4 03 00 00       	jmp    f010593b <syscall+0x63b>
	}

	if (((perm & PTE_SYSCALL) < (PTE_U | PTE_P)) ||
		((perm | PTE_SYSCALL) > PTE_SYSCALL)) {
		return -E_INVAL;
f0105587:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010558c:	e9 aa 03 00 00       	jmp    f010593b <syscall+0x63b>
f0105591:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105596:	e9 a0 03 00 00       	jmp    f010593b <syscall+0x63b>
	}
	
	struct PageInfo* new_page = page_alloc(1);
	if (!new_page) {
		return -E_NO_MEM;
f010559b:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f01055a0:	e9 96 03 00 00       	jmp    f010593b <syscall+0x63b>
	ret = page_insert(env->env_pgdir, new_page, va, perm);
	if (ret < 0) {
		page_free(new_page);
		return ret;
	}
	return 0;
f01055a5:	bb 00 00 00 00       	mov    $0x0,%ebx
		case SYS_env_set_status:
			ret = sys_env_set_status(a1, a2);
			return ret;
		case SYS_page_alloc:
			ret = sys_page_alloc(a1, (void*)a2, a3);
			return ret;
f01055aa:	e9 8c 03 00 00       	jmp    f010593b <syscall+0x63b>
	//   check the current permissions on the page.

	// LAB 4: Your code here.

	struct Env*	src_env;
	int ret = envid2env(srcenvid, &src_env, 1);
f01055af:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01055b6:	00 
f01055b7:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01055ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f01055be:	8b 55 0c             	mov    0xc(%ebp),%edx
f01055c1:	89 14 24             	mov    %edx,(%esp)
f01055c4:	e8 55 e7 ff ff       	call   f0103d1e <envid2env>
f01055c9:	89 c3                	mov    %eax,%ebx
	if (ret < 0) {
f01055cb:	85 c0                	test   %eax,%eax
f01055cd:	0f 88 68 03 00 00    	js     f010593b <syscall+0x63b>
		return ret;
	}

	struct Env*	dst_env;
	ret = envid2env(dstenvid, &dst_env, 1);
f01055d3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01055da:	00 
f01055db:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01055de:	89 44 24 04          	mov    %eax,0x4(%esp)
f01055e2:	8b 45 14             	mov    0x14(%ebp),%eax
f01055e5:	89 04 24             	mov    %eax,(%esp)
f01055e8:	e8 31 e7 ff ff       	call   f0103d1e <envid2env>
f01055ed:	89 c3                	mov    %eax,%ebx
	if (ret < 0) {
f01055ef:	85 c0                	test   %eax,%eax
f01055f1:	0f 88 44 03 00 00    	js     f010593b <syscall+0x63b>
		return ret;
	}
	
	if ((uint32_t)srcva >= UTOP || ((uint32_t)srcva % PGSIZE != 0)) {
f01055f7:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01055fe:	0f 87 a8 00 00 00    	ja     f01056ac <syscall+0x3ac>
f0105604:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010560b:	0f 85 a5 00 00 00    	jne    f01056b6 <syscall+0x3b6>
		return -E_INVAL;
	}
	
	if ((uint32_t)dstva >= UTOP || ((uint32_t)dstva % PGSIZE != 0)) {
f0105611:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0105618:	0f 87 a2 00 00 00    	ja     f01056c0 <syscall+0x3c0>
f010561e:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0105625:	0f 85 9f 00 00 00    	jne    f01056ca <syscall+0x3ca>
		return -E_INVAL;
	}
	
	uint32_t* pte_addr;
	struct PageInfo* page = page_lookup(src_env->env_pgdir, srcva,
			 							&pte_addr);
f010562b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010562e:	89 44 24 08          	mov    %eax,0x8(%esp)
	if ((uint32_t)dstva >= UTOP || ((uint32_t)dstva % PGSIZE != 0)) {
		return -E_INVAL;
	}
	
	uint32_t* pte_addr;
	struct PageInfo* page = page_lookup(src_env->env_pgdir, srcva,
f0105632:	8b 55 10             	mov    0x10(%ebp),%edx
f0105635:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105639:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010563c:	8b 40 60             	mov    0x60(%eax),%eax
f010563f:	89 04 24             	mov    %eax,(%esp)
f0105642:	e8 51 c1 ff ff       	call   f0101798 <page_lookup>
			 							&pte_addr);
	if (!page) {
f0105647:	85 c0                	test   %eax,%eax
f0105649:	0f 84 85 00 00 00    	je     f01056d4 <syscall+0x3d4>
		return -E_INVAL;
	}
	
	if ((!(perm & PTE_P) || !(perm & PTE_U)) ||
f010564f:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0105652:	83 e2 05             	and    $0x5,%edx
f0105655:	83 fa 05             	cmp    $0x5,%edx
f0105658:	0f 85 80 00 00 00    	jne    f01056de <syscall+0x3de>
		((perm | PTE_SYSCALL) > PTE_SYSCALL)) {
f010565e:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0105661:	81 ca 07 0e 00 00    	or     $0xe07,%edx
			 							&pte_addr);
	if (!page) {
		return -E_INVAL;
	}
	
	if ((!(perm & PTE_P) || !(perm & PTE_U)) ||
f0105667:	81 fa 07 0e 00 00    	cmp    $0xe07,%edx
f010566d:	7f 79                	jg     f01056e8 <syscall+0x3e8>
		((perm | PTE_SYSCALL) > PTE_SYSCALL)) {
		return -E_INVAL;
	}
	
	if ((perm & PTE_W) && !((*pte_addr) & PTE_W)) {
f010566f:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0105673:	74 08                	je     f010567d <syscall+0x37d>
f0105675:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105678:	f6 02 02             	testb  $0x2,(%edx)
f010567b:	74 75                	je     f01056f2 <syscall+0x3f2>
		return -E_INVAL;
	}

	ret = page_insert(dst_env->env_pgdir, page, dstva, perm);
f010567d:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0105680:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105684:	8b 55 18             	mov    0x18(%ebp),%edx
f0105687:	89 54 24 08          	mov    %edx,0x8(%esp)
f010568b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010568f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105692:	8b 40 60             	mov    0x60(%eax),%eax
f0105695:	89 04 24             	mov    %eax,(%esp)
f0105698:	e8 ec c2 ff ff       	call   f0101989 <page_insert>
f010569d:	85 c0                	test   %eax,%eax
f010569f:	bb 00 00 00 00       	mov    $0x0,%ebx
f01056a4:	0f 4e d8             	cmovle %eax,%ebx
f01056a7:	e9 8f 02 00 00       	jmp    f010593b <syscall+0x63b>
	if (ret < 0) {
		return ret;
	}
	
	if ((uint32_t)srcva >= UTOP || ((uint32_t)srcva % PGSIZE != 0)) {
		return -E_INVAL;
f01056ac:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01056b1:	e9 85 02 00 00       	jmp    f010593b <syscall+0x63b>
f01056b6:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01056bb:	e9 7b 02 00 00       	jmp    f010593b <syscall+0x63b>
	}
	
	if ((uint32_t)dstva >= UTOP || ((uint32_t)dstva % PGSIZE != 0)) {
		return -E_INVAL;
f01056c0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01056c5:	e9 71 02 00 00       	jmp    f010593b <syscall+0x63b>
f01056ca:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01056cf:	e9 67 02 00 00       	jmp    f010593b <syscall+0x63b>
	
	uint32_t* pte_addr;
	struct PageInfo* page = page_lookup(src_env->env_pgdir, srcva,
			 							&pte_addr);
	if (!page) {
		return -E_INVAL;
f01056d4:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01056d9:	e9 5d 02 00 00       	jmp    f010593b <syscall+0x63b>
	}
	
	if ((!(perm & PTE_P) || !(perm & PTE_U)) ||
		((perm | PTE_SYSCALL) > PTE_SYSCALL)) {
		return -E_INVAL;
f01056de:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01056e3:	e9 53 02 00 00       	jmp    f010593b <syscall+0x63b>
f01056e8:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01056ed:	e9 49 02 00 00       	jmp    f010593b <syscall+0x63b>
	}
	
	if ((perm & PTE_W) && !((*pte_addr) & PTE_W)) {
		return -E_INVAL;
f01056f2:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		case SYS_page_alloc:
			ret = sys_page_alloc(a1, (void*)a2, a3);
			return ret;
		case SYS_page_map:
			ret = sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
			return ret;
f01056f7:	e9 3f 02 00 00       	jmp    f010593b <syscall+0x63b>
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env*	env;
	int ret = envid2env(envid, &env, 1);
f01056fc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105703:	00 
f0105704:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105707:	89 44 24 04          	mov    %eax,0x4(%esp)
f010570b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010570e:	89 04 24             	mov    %eax,(%esp)
f0105711:	e8 08 e6 ff ff       	call   f0103d1e <envid2env>
f0105716:	89 c3                	mov    %eax,%ebx
	if (ret < 0) {
f0105718:	85 c0                	test   %eax,%eax
f010571a:	0f 88 1b 02 00 00    	js     f010593b <syscall+0x63b>
		return ret;
	}
	
	if ((uint32_t)va >= UTOP || ((uint32_t)va % PGSIZE != 0)) {
f0105720:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105727:	77 28                	ja     f0105751 <syscall+0x451>
f0105729:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0105730:	75 29                	jne    f010575b <syscall+0x45b>
		return -E_INVAL;
	}
	
	page_remove(env->env_pgdir, va);
f0105732:	8b 55 10             	mov    0x10(%ebp),%edx
f0105735:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105739:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010573c:	8b 40 60             	mov    0x60(%eax),%eax
f010573f:	89 04 24             	mov    %eax,(%esp)
f0105742:	e8 d8 c1 ff ff       	call   f010191f <page_remove>
	return 0;
f0105747:	bb 00 00 00 00       	mov    $0x0,%ebx
f010574c:	e9 ea 01 00 00       	jmp    f010593b <syscall+0x63b>
	if (ret < 0) {
		return ret;
	}
	
	if ((uint32_t)va >= UTOP || ((uint32_t)va % PGSIZE != 0)) {
		return -E_INVAL;
f0105751:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105756:	e9 e0 01 00 00       	jmp    f010593b <syscall+0x63b>
f010575b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		case SYS_page_map:
			ret = sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
			return ret;
		case SYS_page_unmap:
			ret = sys_page_unmap(a1, (void*)a2);
			return ret;
f0105760:	e9 d6 01 00 00       	jmp    f010593b <syscall+0x63b>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env*	env;
	int ret = envid2env(envid, &env, 1);
f0105765:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010576c:	00 
f010576d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105770:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105774:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105777:	89 04 24             	mov    %eax,(%esp)
f010577a:	e8 9f e5 ff ff       	call   f0103d1e <envid2env>
f010577f:	89 c3                	mov    %eax,%ebx
	if (ret < 0) {
f0105781:	85 c0                	test   %eax,%eax
f0105783:	0f 88 b2 01 00 00    	js     f010593b <syscall+0x63b>
		return ret;
	}
	
	env->env_pgfault_upcall = func;
f0105789:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010578c:	8b 55 10             	mov    0x10(%ebp),%edx
f010578f:	89 50 64             	mov    %edx,0x64(%eax)
	return 0;	
f0105792:	bb 00 00 00 00       	mov    $0x0,%ebx
		case SYS_page_unmap:
			ret = sys_page_unmap(a1, (void*)a2);
			return ret;
		case SYS_env_set_pgfault_upcall:
			ret = sys_env_set_pgfault_upcall(a1, (void*)a2);
			return ret;
f0105797:	e9 9f 01 00 00       	jmp    f010593b <syscall+0x63b>
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	struct Env*	rec_env;
	int ret = envid2env(envid, &rec_env, 0);
f010579c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01057a3:	00 
f01057a4:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01057a7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01057ab:	8b 45 0c             	mov    0xc(%ebp),%eax
f01057ae:	89 04 24             	mov    %eax,(%esp)
f01057b1:	e8 68 e5 ff ff       	call   f0103d1e <envid2env>
f01057b6:	89 c3                	mov    %eax,%ebx
	if (ret < 0) {
f01057b8:	85 c0                	test   %eax,%eax
f01057ba:	0f 88 7b 01 00 00    	js     f010593b <syscall+0x63b>
		return ret;
	}

	if (!rec_env->env_ipc_recving) {
f01057c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01057c3:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f01057c7:	0f 84 09 01 00 00    	je     f01058d6 <syscall+0x5d6>
		return -E_IPC_NOT_RECV;
	}

	rec_env->env_ipc_value = value;
f01057cd:	8b 55 10             	mov    0x10(%ebp),%edx
f01057d0:	89 50 70             	mov    %edx,0x70(%eax)
	rec_env->env_ipc_perm = 0;	
f01057d3:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
	
	uint32_t dstva = (uint32_t)rec_env->env_ipc_dstva;
f01057da:	8b 70 6c             	mov    0x6c(%eax),%esi
	if (dstva < UTOP && (uint32_t)srcva < UTOP) {
f01057dd:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f01057e4:	0f 87 b9 00 00 00    	ja     f01058a3 <syscall+0x5a3>
f01057ea:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f01057f0:	0f 87 ad 00 00 00    	ja     f01058a3 <syscall+0x5a3>
		if ((uint32_t)srcva % PGSIZE != 0) {
			return -E_INVAL;
f01057f6:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	rec_env->env_ipc_value = value;
	rec_env->env_ipc_perm = 0;	
	
	uint32_t dstva = (uint32_t)rec_env->env_ipc_dstva;
	if (dstva < UTOP && (uint32_t)srcva < UTOP) {
		if ((uint32_t)srcva % PGSIZE != 0) {
f01057fb:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0105802:	0f 85 33 01 00 00    	jne    f010593b <syscall+0x63b>
			return -E_INVAL;
		}
		
		if ((!(perm & PTE_P)) || (!(perm & PTE_U))
f0105808:	8b 45 18             	mov    0x18(%ebp),%eax
f010580b:	83 e0 05             	and    $0x5,%eax
f010580e:	83 f8 05             	cmp    $0x5,%eax
f0105811:	0f 85 24 01 00 00    	jne    f010593b <syscall+0x63b>
			 || ((perm | PTE_SYSCALL) > PTE_SYSCALL)) {
f0105817:	8b 45 18             	mov    0x18(%ebp),%eax
f010581a:	0d 07 0e 00 00       	or     $0xe07,%eax
f010581f:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f0105824:	0f 87 11 01 00 00    	ja     f010593b <syscall+0x63b>
			return -E_INVAL;
		}

		uint32_t* pte_addr;
		struct PageInfo* page = page_lookup(curenv->env_pgdir, srcva,
f010582a:	e8 7d 14 00 00       	call   f0106cac <cpunum>
											&pte_addr);
f010582f:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105832:	89 54 24 08          	mov    %edx,0x8(%esp)
			 || ((perm | PTE_SYSCALL) > PTE_SYSCALL)) {
			return -E_INVAL;
		}

		uint32_t* pte_addr;
		struct PageInfo* page = page_lookup(curenv->env_pgdir, srcva,
f0105836:	8b 55 14             	mov    0x14(%ebp),%edx
f0105839:	89 54 24 04          	mov    %edx,0x4(%esp)
f010583d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105840:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0105846:	8b 40 60             	mov    0x60(%eax),%eax
f0105849:	89 04 24             	mov    %eax,(%esp)
f010584c:	e8 47 bf ff ff       	call   f0101798 <page_lookup>
											&pte_addr);
		if (!page) {
f0105851:	85 c0                	test   %eax,%eax
f0105853:	74 44                	je     f0105899 <syscall+0x599>
			return -E_INVAL;
		}
		
		if ((perm & PTE_W) && !((*pte_addr) & PTE_W)) {
f0105855:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0105859:	74 0c                	je     f0105867 <syscall+0x567>
f010585b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010585e:	f6 02 02             	testb  $0x2,(%edx)
f0105861:	0f 84 d4 00 00 00    	je     f010593b <syscall+0x63b>
			return -E_INVAL;
		}
		
		ret = page_insert(rec_env->env_pgdir, page, (void*)dstva, perm);
f0105867:	8b 55 18             	mov    0x18(%ebp),%edx
f010586a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010586e:	89 74 24 08          	mov    %esi,0x8(%esp)
f0105872:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105876:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105879:	8b 40 60             	mov    0x60(%eax),%eax
f010587c:	89 04 24             	mov    %eax,(%esp)
f010587f:	e8 05 c1 ff ff       	call   f0101989 <page_insert>
f0105884:	89 c3                	mov    %eax,%ebx
		if (ret < 0) {
f0105886:	85 c0                	test   %eax,%eax
f0105888:	0f 88 ad 00 00 00    	js     f010593b <syscall+0x63b>
			return ret;
		}
		rec_env->env_ipc_perm = perm;	
f010588e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105891:	8b 55 18             	mov    0x18(%ebp),%edx
f0105894:	89 50 78             	mov    %edx,0x78(%eax)
f0105897:	eb 0a                	jmp    f01058a3 <syscall+0x5a3>

		uint32_t* pte_addr;
		struct PageInfo* page = page_lookup(curenv->env_pgdir, srcva,
											&pte_addr);
		if (!page) {
			return -E_INVAL;
f0105899:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010589e:	e9 98 00 00 00       	jmp    f010593b <syscall+0x63b>
			return ret;
		}
		rec_env->env_ipc_perm = perm;	
	}
	
	rec_env->env_ipc_recving = 0;
f01058a3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01058a6:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	rec_env->env_ipc_from = curenv->env_id;
f01058aa:	e8 fd 13 00 00       	call   f0106cac <cpunum>
f01058af:	6b c0 74             	imul   $0x74,%eax,%eax
f01058b2:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01058b8:	8b 40 48             	mov    0x48(%eax),%eax
f01058bb:	89 43 74             	mov    %eax,0x74(%ebx)
	rec_env->env_tf.tf_regs.reg_eax = 0;
f01058be:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01058c1:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	rec_env->env_status = ENV_RUNNABLE;
f01058c8:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	return 0;
f01058cf:	bb 00 00 00 00       	mov    $0x0,%ebx
f01058d4:	eb 65                	jmp    f010593b <syscall+0x63b>
	if (ret < 0) {
		return ret;
	}

	if (!rec_env->env_ipc_recving) {
		return -E_IPC_NOT_RECV;
f01058d6:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
		case SYS_env_set_pgfault_upcall:
			ret = sys_env_set_pgfault_upcall(a1, (void*)a2);
			return ret;
		case SYS_ipc_try_send:
			ret = sys_ipc_try_send(a1, a2, (void*)a3, a4);
			return ret;
f01058db:	eb 5e                	jmp    f010593b <syscall+0x63b>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ((uint32_t)dstva < UTOP && (uint32_t)dstva % PGSIZE != 0) {
f01058dd:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f01058e4:	77 09                	ja     f01058ef <syscall+0x5ef>
f01058e6:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f01058ed:	75 47                	jne    f0105936 <syscall+0x636>
		return -E_INVAL;
	}
	curenv->env_ipc_recving = 1;
f01058ef:	e8 b8 13 00 00       	call   f0106cac <cpunum>
f01058f4:	6b c0 74             	imul   $0x74,%eax,%eax
f01058f7:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01058fd:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f0105901:	e8 a6 13 00 00       	call   f0106cac <cpunum>
f0105906:	6b c0 74             	imul   $0x74,%eax,%eax
f0105909:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010590f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105912:	89 50 6c             	mov    %edx,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0105915:	e8 92 13 00 00       	call   f0106cac <cpunum>
f010591a:	6b c0 74             	imul   $0x74,%eax,%eax
f010591d:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0105923:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();
f010592a:	e8 05 f9 ff ff       	call   f0105234 <sched_yield>
			return ret;
		case SYS_ipc_recv:
			ret = sys_ipc_recv((void*)a1);
			return ret;
		default:
			return -E_INVAL;
f010592f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105934:	eb 05                	jmp    f010593b <syscall+0x63b>
		case SYS_ipc_try_send:
			ret = sys_ipc_try_send(a1, a2, (void*)a3, a4);
			return ret;
		case SYS_ipc_recv:
			ret = sys_ipc_recv((void*)a1);
			return ret;
f0105936:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		default:
			return -E_INVAL;
	}	
}
f010593b:	89 d8                	mov    %ebx,%eax
f010593d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0105940:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0105943:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0105946:	89 ec                	mov    %ebp,%esp
f0105948:	5d                   	pop    %ebp
f0105949:	c3                   	ret    
f010594a:	66 90                	xchg   %ax,%ax

f010594c <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010594c:	55                   	push   %ebp
f010594d:	89 e5                	mov    %esp,%ebp
f010594f:	57                   	push   %edi
f0105950:	56                   	push   %esi
f0105951:	53                   	push   %ebx
f0105952:	83 ec 14             	sub    $0x14,%esp
f0105955:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105958:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010595b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010595e:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0105961:	8b 1a                	mov    (%edx),%ebx
f0105963:	8b 01                	mov    (%ecx),%eax
f0105965:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0105968:	39 c3                	cmp    %eax,%ebx
f010596a:	0f 8f 9f 00 00 00    	jg     f0105a0f <stab_binsearch+0xc3>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0105970:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0105977:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010597a:	01 d8                	add    %ebx,%eax
f010597c:	89 c7                	mov    %eax,%edi
f010597e:	c1 ef 1f             	shr    $0x1f,%edi
f0105981:	01 c7                	add    %eax,%edi
f0105983:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105985:	39 df                	cmp    %ebx,%edi
f0105987:	0f 8c ce 00 00 00    	jl     f0105a5b <stab_binsearch+0x10f>
f010598d:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0105990:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0105993:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0105998:	39 f0                	cmp    %esi,%eax
f010599a:	0f 84 c0 00 00 00    	je     f0105a60 <stab_binsearch+0x114>
f01059a0:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01059a4:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01059a8:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f01059aa:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01059ad:	39 d8                	cmp    %ebx,%eax
f01059af:	0f 8c a6 00 00 00    	jl     f0105a5b <stab_binsearch+0x10f>
f01059b5:	0f b6 0a             	movzbl (%edx),%ecx
f01059b8:	83 ea 0c             	sub    $0xc,%edx
f01059bb:	39 f1                	cmp    %esi,%ecx
f01059bd:	75 eb                	jne    f01059aa <stab_binsearch+0x5e>
f01059bf:	e9 9e 00 00 00       	jmp    f0105a62 <stab_binsearch+0x116>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01059c4:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01059c7:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f01059c9:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01059cc:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01059d3:	eb 2b                	jmp    f0105a00 <stab_binsearch+0xb4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01059d5:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01059d8:	76 14                	jbe    f01059ee <stab_binsearch+0xa2>
			*region_right = m - 1;
f01059da:	83 e8 01             	sub    $0x1,%eax
f01059dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01059e0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01059e3:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01059e5:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01059ec:	eb 12                	jmp    f0105a00 <stab_binsearch+0xb4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01059ee:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01059f1:	89 02                	mov    %eax,(%edx)
			l = m;
			addr++;
f01059f3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01059f7:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01059f9:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0105a00:	3b 5d ec             	cmp    -0x14(%ebp),%ebx
f0105a03:	0f 8e 6e ff ff ff    	jle    f0105977 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105a09:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105a0d:	75 0f                	jne    f0105a1e <stab_binsearch+0xd2>
		*region_right = *region_left - 1;
f0105a0f:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105a12:	8b 02                	mov    (%edx),%eax
f0105a14:	83 e8 01             	sub    $0x1,%eax
f0105a17:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105a1a:	89 01                	mov    %eax,(%ecx)
f0105a1c:	eb 5c                	jmp    f0105a7a <stab_binsearch+0x12e>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105a1e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105a21:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105a23:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105a26:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105a28:	39 c8                	cmp    %ecx,%eax
f0105a2a:	7e 28                	jle    f0105a54 <stab_binsearch+0x108>
		     l > *region_left && stabs[l].n_type != type;
f0105a2c:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105a2f:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0105a32:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0105a37:	39 f2                	cmp    %esi,%edx
f0105a39:	74 19                	je     f0105a54 <stab_binsearch+0x108>
f0105a3b:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0105a3f:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0105a43:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105a46:	39 c8                	cmp    %ecx,%eax
f0105a48:	7e 0a                	jle    f0105a54 <stab_binsearch+0x108>
		     l > *region_left && stabs[l].n_type != type;
f0105a4a:	0f b6 1a             	movzbl (%edx),%ebx
f0105a4d:	83 ea 0c             	sub    $0xc,%edx
f0105a50:	39 f3                	cmp    %esi,%ebx
f0105a52:	75 ef                	jne    f0105a43 <stab_binsearch+0xf7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0105a54:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105a57:	89 02                	mov    %eax,(%edx)
f0105a59:	eb 1f                	jmp    f0105a7a <stab_binsearch+0x12e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0105a5b:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0105a5e:	eb a0                	jmp    f0105a00 <stab_binsearch+0xb4>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0105a60:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105a62:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105a65:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0105a68:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0105a6c:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105a6f:	0f 82 4f ff ff ff    	jb     f01059c4 <stab_binsearch+0x78>
f0105a75:	e9 5b ff ff ff       	jmp    f01059d5 <stab_binsearch+0x89>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0105a7a:	83 c4 14             	add    $0x14,%esp
f0105a7d:	5b                   	pop    %ebx
f0105a7e:	5e                   	pop    %esi
f0105a7f:	5f                   	pop    %edi
f0105a80:	5d                   	pop    %ebp
f0105a81:	c3                   	ret    

f0105a82 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105a82:	55                   	push   %ebp
f0105a83:	89 e5                	mov    %esp,%ebp
f0105a85:	57                   	push   %edi
f0105a86:	56                   	push   %esi
f0105a87:	53                   	push   %ebx
f0105a88:	83 ec 5c             	sub    $0x5c,%esp
f0105a8b:	8b 75 08             	mov    0x8(%ebp),%esi
f0105a8e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105a91:	c7 03 b0 8c 10 f0    	movl   $0xf0108cb0,(%ebx)
	info->eip_line = 0;
f0105a97:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0105a9e:	c7 43 08 b0 8c 10 f0 	movl   $0xf0108cb0,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0105aa5:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0105aac:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0105aaf:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105ab6:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0105abc:	77 4f                	ja     f0105b0d <debuginfo_eip+0x8b>
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		// TODO valid?
		user_mem_check(curenv, (void*)usd, sizeof(struct UserStabData), PTE_U);	
f0105abe:	e8 e9 11 00 00       	call   f0106cac <cpunum>
f0105ac3:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105aca:	00 
f0105acb:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0105ad2:	00 
f0105ad3:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0105ada:	00 
f0105adb:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ade:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0105ae4:	89 04 24             	mov    %eax,(%esp)
f0105ae7:	e8 b7 e0 ff ff       	call   f0103ba3 <user_mem_check>

		stabs = usd->stabs;
f0105aec:	a1 00 00 20 00       	mov    0x200000,%eax
f0105af1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0105af4:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0105af9:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0105aff:	89 55 bc             	mov    %edx,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f0105b02:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f0105b08:	89 4d c0             	mov    %ecx,-0x40(%ebp)
f0105b0b:	eb 1a                	jmp    f0105b27 <debuginfo_eip+0xa5>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0105b0d:	c7 45 c0 a0 86 11 f0 	movl   $0xf01186a0,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0105b14:	c7 45 bc 09 4d 11 f0 	movl   $0xf0114d09,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0105b1b:	b8 08 4d 11 f0       	mov    $0xf0114d08,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0105b20:	c7 45 c4 94 91 10 f0 	movl   $0xf0109194,-0x3c(%ebp)
		// user_mem_check(curenv, (void*)usd, sizeof(UserStabData), PTE_U);	

	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105b27:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0105b2a:	39 55 bc             	cmp    %edx,-0x44(%ebp)
f0105b2d:	0f 83 bf 01 00 00    	jae    f0105cf2 <debuginfo_eip+0x270>
f0105b33:	80 7a ff 00          	cmpb   $0x0,-0x1(%edx)
f0105b37:	0f 85 bc 01 00 00    	jne    f0105cf9 <debuginfo_eip+0x277>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105b3d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105b44:	2b 45 c4             	sub    -0x3c(%ebp),%eax
f0105b47:	c1 f8 02             	sar    $0x2,%eax
f0105b4a:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0105b50:	83 e8 01             	sub    $0x1,%eax
f0105b53:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105b56:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105b5a:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105b61:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105b64:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105b67:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105b6a:	e8 dd fd ff ff       	call   f010594c <stab_binsearch>
	if (lfile == 0)
f0105b6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b72:	85 c0                	test   %eax,%eax
f0105b74:	0f 84 86 01 00 00    	je     f0105d00 <debuginfo_eip+0x27e>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105b7a:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105b7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105b80:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105b83:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105b87:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0105b8e:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105b91:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105b94:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105b97:	e8 b0 fd ff ff       	call   f010594c <stab_binsearch>

	if (lfun <= rfun) {
f0105b9c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105b9f:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0105ba2:	39 c8                	cmp    %ecx,%eax
f0105ba4:	7f 32                	jg     f0105bd8 <debuginfo_eip+0x156>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105ba6:	8d 3c 40             	lea    (%eax,%eax,2),%edi
f0105ba9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0105bac:	8d 3c ba             	lea    (%edx,%edi,4),%edi
f0105baf:	8b 17                	mov    (%edi),%edx
f0105bb1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f0105bb4:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0105bb7:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0105bba:	39 55 b4             	cmp    %edx,-0x4c(%ebp)
f0105bbd:	73 09                	jae    f0105bc8 <debuginfo_eip+0x146>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105bbf:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0105bc2:	03 55 bc             	add    -0x44(%ebp),%edx
f0105bc5:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105bc8:	8b 57 08             	mov    0x8(%edi),%edx
f0105bcb:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0105bce:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0105bd0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0105bd3:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0105bd6:	eb 0f                	jmp    f0105be7 <debuginfo_eip+0x165>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105bd8:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0105bdb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105bde:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105be1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105be4:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105be7:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0105bee:	00 
f0105bef:	8b 43 08             	mov    0x8(%ebx),%eax
f0105bf2:	89 04 24             	mov    %eax,(%esp)
f0105bf5:	e8 e1 09 00 00       	call   f01065db <strfind>
f0105bfa:	2b 43 08             	sub    0x8(%ebx),%eax
f0105bfd:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &rline, &lline, N_SLINE, addr);
f0105c00:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105c04:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0105c0b:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
f0105c0e:	8d 55 d0             	lea    -0x30(%ebp),%edx
f0105c11:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105c14:	e8 33 fd ff ff       	call   f010594c <stab_binsearch>
	if (rline > lline) {
f0105c19:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105c1c:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0105c1f:	0f 8e e2 00 00 00    	jle    f0105d07 <debuginfo_eip+0x285>
		info->eip_line = stabs[lline].n_desc;
f0105c25:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105c28:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0105c2b:	0f b7 44 81 06       	movzwl 0x6(%ecx,%eax,4),%eax
f0105c30:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105c33:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105c36:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105c39:	39 fa                	cmp    %edi,%edx
f0105c3b:	7c 68                	jl     f0105ca5 <debuginfo_eip+0x223>
	       && stabs[lline].n_type != N_SOL
f0105c3d:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0105c40:	8d 34 81             	lea    (%ecx,%eax,4),%esi
f0105c43:	0f b6 46 04          	movzbl 0x4(%esi),%eax
f0105c47:	88 45 b4             	mov    %al,-0x4c(%ebp)
f0105c4a:	3c 84                	cmp    $0x84,%al
f0105c4c:	74 3f                	je     f0105c8d <debuginfo_eip+0x20b>
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0105c4e:	8d 4c 52 fd          	lea    -0x3(%edx,%edx,2),%ecx
f0105c52:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105c55:	8d 04 88             	lea    (%eax,%ecx,4),%eax
f0105c58:	89 45 b8             	mov    %eax,-0x48(%ebp)
f0105c5b:	0f b6 4d b4          	movzbl -0x4c(%ebp),%ecx
f0105c5f:	eb 1a                	jmp    f0105c7b <debuginfo_eip+0x1f9>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0105c61:	83 ea 01             	sub    $0x1,%edx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105c64:	39 fa                	cmp    %edi,%edx
f0105c66:	7c 3d                	jl     f0105ca5 <debuginfo_eip+0x223>
	       && stabs[lline].n_type != N_SOL
f0105c68:	89 c6                	mov    %eax,%esi
f0105c6a:	83 e8 0c             	sub    $0xc,%eax
f0105c6d:	0f b6 48 10          	movzbl 0x10(%eax),%ecx
f0105c71:	80 f9 84             	cmp    $0x84,%cl
f0105c74:	75 05                	jne    f0105c7b <debuginfo_eip+0x1f9>
f0105c76:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105c79:	eb 12                	jmp    f0105c8d <debuginfo_eip+0x20b>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105c7b:	80 f9 64             	cmp    $0x64,%cl
f0105c7e:	75 e1                	jne    f0105c61 <debuginfo_eip+0x1df>
f0105c80:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
f0105c84:	74 db                	je     f0105c61 <debuginfo_eip+0x1df>
f0105c86:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105c89:	39 d7                	cmp    %edx,%edi
f0105c8b:	7f 18                	jg     f0105ca5 <debuginfo_eip+0x223>
f0105c8d:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0105c90:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0105c93:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0105c96:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0105c99:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0105c9c:	39 d0                	cmp    %edx,%eax
f0105c9e:	73 05                	jae    f0105ca5 <debuginfo_eip+0x223>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105ca0:	03 45 bc             	add    -0x44(%ebp),%eax
f0105ca3:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105ca5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105ca8:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105cab:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105cb0:	39 f2                	cmp    %esi,%edx
f0105cb2:	7d 6d                	jge    f0105d21 <debuginfo_eip+0x29f>
		for (lline = lfun + 1;
f0105cb4:	8d 42 01             	lea    0x1(%edx),%eax
f0105cb7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105cba:	39 c6                	cmp    %eax,%esi
f0105cbc:	7e 50                	jle    f0105d0e <debuginfo_eip+0x28c>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105cbe:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105cc1:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0105cc4:	80 7c 81 04 a0       	cmpb   $0xa0,0x4(%ecx,%eax,4)
f0105cc9:	75 4a                	jne    f0105d15 <debuginfo_eip+0x293>
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0105ccb:	8d 42 02             	lea    0x2(%edx),%eax

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105cce:	8d 14 52             	lea    (%edx,%edx,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0105cd1:	8d 54 91 1c          	lea    0x1c(%ecx,%edx,4),%edx
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0105cd5:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105cd9:	39 f0                	cmp    %esi,%eax
f0105cdb:	74 3f                	je     f0105d1c <debuginfo_eip+0x29a>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105cdd:	0f b6 0a             	movzbl (%edx),%ecx
f0105ce0:	83 c0 01             	add    $0x1,%eax
f0105ce3:	83 c2 0c             	add    $0xc,%edx
f0105ce6:	80 f9 a0             	cmp    $0xa0,%cl
f0105ce9:	74 ea                	je     f0105cd5 <debuginfo_eip+0x253>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105ceb:	b8 00 00 00 00       	mov    $0x0,%eax
f0105cf0:	eb 2f                	jmp    f0105d21 <debuginfo_eip+0x29f>

	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0105cf2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105cf7:	eb 28                	jmp    f0105d21 <debuginfo_eip+0x29f>
f0105cf9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105cfe:	eb 21                	jmp    f0105d21 <debuginfo_eip+0x29f>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0105d00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105d05:	eb 1a                	jmp    f0105d21 <debuginfo_eip+0x29f>
	// Your code here.
	stab_binsearch(stabs, &rline, &lline, N_SLINE, addr);
	if (rline > lline) {
		info->eip_line = stabs[lline].n_desc;
	} else {
		return -1;
f0105d07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105d0c:	eb 13                	jmp    f0105d21 <debuginfo_eip+0x29f>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105d0e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d13:	eb 0c                	jmp    f0105d21 <debuginfo_eip+0x29f>
f0105d15:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d1a:	eb 05                	jmp    f0105d21 <debuginfo_eip+0x29f>
f0105d1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105d21:	83 c4 5c             	add    $0x5c,%esp
f0105d24:	5b                   	pop    %ebx
f0105d25:	5e                   	pop    %esi
f0105d26:	5f                   	pop    %edi
f0105d27:	5d                   	pop    %ebp
f0105d28:	c3                   	ret    
f0105d29:	66 90                	xchg   %ax,%ax
f0105d2b:	66 90                	xchg   %ax,%ax
f0105d2d:	66 90                	xchg   %ax,%ax
f0105d2f:	90                   	nop

f0105d30 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105d30:	55                   	push   %ebp
f0105d31:	89 e5                	mov    %esp,%ebp
f0105d33:	57                   	push   %edi
f0105d34:	56                   	push   %esi
f0105d35:	53                   	push   %ebx
f0105d36:	83 ec 4c             	sub    $0x4c,%esp
f0105d39:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105d3c:	89 d7                	mov    %edx,%edi
f0105d3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105d41:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0105d44:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105d47:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105d4a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d4f:	39 d8                	cmp    %ebx,%eax
f0105d51:	72 17                	jb     f0105d6a <printnum+0x3a>
f0105d53:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0105d56:	39 5d 10             	cmp    %ebx,0x10(%ebp)
f0105d59:	76 0f                	jbe    f0105d6a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105d5b:	8b 75 14             	mov    0x14(%ebp),%esi
f0105d5e:	83 ee 01             	sub    $0x1,%esi
f0105d61:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0105d64:	85 f6                	test   %esi,%esi
f0105d66:	7f 63                	jg     f0105dcb <printnum+0x9b>
f0105d68:	eb 75                	jmp    f0105ddf <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105d6a:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0105d6d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0105d71:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d74:	83 e8 01             	sub    $0x1,%eax
f0105d77:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105d7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105d7e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105d82:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105d86:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105d8a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105d8d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105d90:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105d97:	00 
f0105d98:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0105d9b:	89 1c 24             	mov    %ebx,(%esp)
f0105d9e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0105da1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105da5:	e8 96 13 00 00       	call   f0107140 <__udivdi3>
f0105daa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105dad:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105db0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105db4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105db8:	89 04 24             	mov    %eax,(%esp)
f0105dbb:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105dbf:	89 fa                	mov    %edi,%edx
f0105dc1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105dc4:	e8 67 ff ff ff       	call   f0105d30 <printnum>
f0105dc9:	eb 14                	jmp    f0105ddf <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105dcb:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105dcf:	8b 45 18             	mov    0x18(%ebp),%eax
f0105dd2:	89 04 24             	mov    %eax,(%esp)
f0105dd5:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105dd7:	83 ee 01             	sub    $0x1,%esi
f0105dda:	75 ef                	jne    f0105dcb <printnum+0x9b>
f0105ddc:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105ddf:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105de3:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105de7:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105dea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105dee:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105df5:	00 
f0105df6:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0105df9:	89 1c 24             	mov    %ebx,(%esp)
f0105dfc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0105dff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105e03:	e8 88 14 00 00       	call   f0107290 <__umoddi3>
f0105e08:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105e0c:	0f be 80 ba 8c 10 f0 	movsbl -0xfef7346(%eax),%eax
f0105e13:	89 04 24             	mov    %eax,(%esp)
f0105e16:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105e19:	ff d0                	call   *%eax
}
f0105e1b:	83 c4 4c             	add    $0x4c,%esp
f0105e1e:	5b                   	pop    %ebx
f0105e1f:	5e                   	pop    %esi
f0105e20:	5f                   	pop    %edi
f0105e21:	5d                   	pop    %ebp
f0105e22:	c3                   	ret    

f0105e23 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105e23:	55                   	push   %ebp
f0105e24:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105e26:	83 fa 01             	cmp    $0x1,%edx
f0105e29:	7e 0e                	jle    f0105e39 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105e2b:	8b 10                	mov    (%eax),%edx
f0105e2d:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105e30:	89 08                	mov    %ecx,(%eax)
f0105e32:	8b 02                	mov    (%edx),%eax
f0105e34:	8b 52 04             	mov    0x4(%edx),%edx
f0105e37:	eb 22                	jmp    f0105e5b <getuint+0x38>
	else if (lflag)
f0105e39:	85 d2                	test   %edx,%edx
f0105e3b:	74 10                	je     f0105e4d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105e3d:	8b 10                	mov    (%eax),%edx
f0105e3f:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105e42:	89 08                	mov    %ecx,(%eax)
f0105e44:	8b 02                	mov    (%edx),%eax
f0105e46:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e4b:	eb 0e                	jmp    f0105e5b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105e4d:	8b 10                	mov    (%eax),%edx
f0105e4f:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105e52:	89 08                	mov    %ecx,(%eax)
f0105e54:	8b 02                	mov    (%edx),%eax
f0105e56:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105e5b:	5d                   	pop    %ebp
f0105e5c:	c3                   	ret    

f0105e5d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105e5d:	55                   	push   %ebp
f0105e5e:	89 e5                	mov    %esp,%ebp
f0105e60:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105e63:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105e67:	8b 10                	mov    (%eax),%edx
f0105e69:	3b 50 04             	cmp    0x4(%eax),%edx
f0105e6c:	73 0a                	jae    f0105e78 <sprintputch+0x1b>
		*b->buf++ = ch;
f0105e6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105e71:	88 0a                	mov    %cl,(%edx)
f0105e73:	83 c2 01             	add    $0x1,%edx
f0105e76:	89 10                	mov    %edx,(%eax)
}
f0105e78:	5d                   	pop    %ebp
f0105e79:	c3                   	ret    

f0105e7a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105e7a:	55                   	push   %ebp
f0105e7b:	89 e5                	mov    %esp,%ebp
f0105e7d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0105e80:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105e83:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105e87:	8b 45 10             	mov    0x10(%ebp),%eax
f0105e8a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105e8e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105e91:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e95:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e98:	89 04 24             	mov    %eax,(%esp)
f0105e9b:	e8 02 00 00 00       	call   f0105ea2 <vprintfmt>
	va_end(ap);
}
f0105ea0:	c9                   	leave  
f0105ea1:	c3                   	ret    

f0105ea2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105ea2:	55                   	push   %ebp
f0105ea3:	89 e5                	mov    %esp,%ebp
f0105ea5:	57                   	push   %edi
f0105ea6:	56                   	push   %esi
f0105ea7:	53                   	push   %ebx
f0105ea8:	83 ec 4c             	sub    $0x4c,%esp
f0105eab:	8b 75 08             	mov    0x8(%ebp),%esi
f0105eae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105eb1:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105eb4:	eb 11                	jmp    f0105ec7 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105eb6:	85 c0                	test   %eax,%eax
f0105eb8:	0f 84 db 03 00 00    	je     f0106299 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
f0105ebe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105ec2:	89 04 24             	mov    %eax,(%esp)
f0105ec5:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105ec7:	0f b6 07             	movzbl (%edi),%eax
f0105eca:	83 c7 01             	add    $0x1,%edi
f0105ecd:	83 f8 25             	cmp    $0x25,%eax
f0105ed0:	75 e4                	jne    f0105eb6 <vprintfmt+0x14>
f0105ed2:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
f0105ed6:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f0105edd:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f0105ee4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0105eeb:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ef0:	eb 2b                	jmp    f0105f1d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105ef2:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105ef5:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
f0105ef9:	eb 22                	jmp    f0105f1d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105efb:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105efe:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
f0105f02:	eb 19                	jmp    f0105f1d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105f04:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0105f07:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0105f0e:	eb 0d                	jmp    f0105f1d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0105f10:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105f13:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105f16:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105f1d:	0f b6 0f             	movzbl (%edi),%ecx
f0105f20:	8d 47 01             	lea    0x1(%edi),%eax
f0105f23:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105f26:	0f b6 07             	movzbl (%edi),%eax
f0105f29:	83 e8 23             	sub    $0x23,%eax
f0105f2c:	3c 55                	cmp    $0x55,%al
f0105f2e:	0f 87 40 03 00 00    	ja     f0106274 <vprintfmt+0x3d2>
f0105f34:	0f b6 c0             	movzbl %al,%eax
f0105f37:	ff 24 85 80 8d 10 f0 	jmp    *-0xfef7280(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105f3e:	83 e9 30             	sub    $0x30,%ecx
f0105f41:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
f0105f44:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
f0105f48:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0105f4b:	83 f9 09             	cmp    $0x9,%ecx
f0105f4e:	77 57                	ja     f0105fa7 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105f50:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105f53:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0105f56:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105f59:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0105f5c:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0105f5f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0105f63:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f0105f66:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0105f69:	83 f9 09             	cmp    $0x9,%ecx
f0105f6c:	76 eb                	jbe    f0105f59 <vprintfmt+0xb7>
f0105f6e:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105f71:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105f74:	eb 34                	jmp    f0105faa <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105f76:	8b 45 14             	mov    0x14(%ebp),%eax
f0105f79:	8d 48 04             	lea    0x4(%eax),%ecx
f0105f7c:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105f7f:	8b 00                	mov    (%eax),%eax
f0105f81:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105f84:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105f87:	eb 21                	jmp    f0105faa <vprintfmt+0x108>

		case '.':
			if (width < 0)
f0105f89:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105f8d:	0f 88 71 ff ff ff    	js     f0105f04 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105f93:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105f96:	eb 85                	jmp    f0105f1d <vprintfmt+0x7b>
f0105f98:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105f9b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f0105fa2:	e9 76 ff ff ff       	jmp    f0105f1d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105fa7:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0105faa:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105fae:	0f 89 69 ff ff ff    	jns    f0105f1d <vprintfmt+0x7b>
f0105fb4:	e9 57 ff ff ff       	jmp    f0105f10 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105fb9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105fbc:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105fbf:	e9 59 ff ff ff       	jmp    f0105f1d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105fc4:	8b 45 14             	mov    0x14(%ebp),%eax
f0105fc7:	8d 50 04             	lea    0x4(%eax),%edx
f0105fca:	89 55 14             	mov    %edx,0x14(%ebp)
f0105fcd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105fd1:	8b 00                	mov    (%eax),%eax
f0105fd3:	89 04 24             	mov    %eax,(%esp)
f0105fd6:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105fd8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105fdb:	e9 e7 fe ff ff       	jmp    f0105ec7 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105fe0:	8b 45 14             	mov    0x14(%ebp),%eax
f0105fe3:	8d 50 04             	lea    0x4(%eax),%edx
f0105fe6:	89 55 14             	mov    %edx,0x14(%ebp)
f0105fe9:	8b 00                	mov    (%eax),%eax
f0105feb:	89 c2                	mov    %eax,%edx
f0105fed:	c1 fa 1f             	sar    $0x1f,%edx
f0105ff0:	31 d0                	xor    %edx,%eax
f0105ff2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105ff4:	83 f8 08             	cmp    $0x8,%eax
f0105ff7:	7f 0b                	jg     f0106004 <vprintfmt+0x162>
f0105ff9:	8b 14 85 e0 8e 10 f0 	mov    -0xfef7120(,%eax,4),%edx
f0106000:	85 d2                	test   %edx,%edx
f0106002:	75 20                	jne    f0106024 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
f0106004:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106008:	c7 44 24 08 d2 8c 10 	movl   $0xf0108cd2,0x8(%esp)
f010600f:	f0 
f0106010:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106014:	89 34 24             	mov    %esi,(%esp)
f0106017:	e8 5e fe ff ff       	call   f0105e7a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010601c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f010601f:	e9 a3 fe ff ff       	jmp    f0105ec7 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0106024:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106028:	c7 44 24 08 d9 83 10 	movl   $0xf01083d9,0x8(%esp)
f010602f:	f0 
f0106030:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106034:	89 34 24             	mov    %esi,(%esp)
f0106037:	e8 3e fe ff ff       	call   f0105e7a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010603c:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010603f:	e9 83 fe ff ff       	jmp    f0105ec7 <vprintfmt+0x25>
f0106044:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0106047:	8b 7d d8             	mov    -0x28(%ebp),%edi
f010604a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010604d:	8b 45 14             	mov    0x14(%ebp),%eax
f0106050:	8d 50 04             	lea    0x4(%eax),%edx
f0106053:	89 55 14             	mov    %edx,0x14(%ebp)
f0106056:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0106058:	85 ff                	test   %edi,%edi
f010605a:	b8 cb 8c 10 f0       	mov    $0xf0108ccb,%eax
f010605f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0106062:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
f0106066:	74 06                	je     f010606e <vprintfmt+0x1cc>
f0106068:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f010606c:	7f 16                	jg     f0106084 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010606e:	0f b6 17             	movzbl (%edi),%edx
f0106071:	0f be c2             	movsbl %dl,%eax
f0106074:	83 c7 01             	add    $0x1,%edi
f0106077:	85 c0                	test   %eax,%eax
f0106079:	0f 85 9f 00 00 00    	jne    f010611e <vprintfmt+0x27c>
f010607f:	e9 8b 00 00 00       	jmp    f010610f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0106084:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106088:	89 3c 24             	mov    %edi,(%esp)
f010608b:	e8 92 03 00 00       	call   f0106422 <strnlen>
f0106090:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0106093:	29 c2                	sub    %eax,%edx
f0106095:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0106098:	85 d2                	test   %edx,%edx
f010609a:	7e d2                	jle    f010606e <vprintfmt+0x1cc>
					putch(padc, putdat);
f010609c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
f01060a0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01060a3:	89 7d cc             	mov    %edi,-0x34(%ebp)
f01060a6:	89 d7                	mov    %edx,%edi
f01060a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01060ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01060af:	89 04 24             	mov    %eax,(%esp)
f01060b2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01060b4:	83 ef 01             	sub    $0x1,%edi
f01060b7:	75 ef                	jne    f01060a8 <vprintfmt+0x206>
f01060b9:	89 7d d8             	mov    %edi,-0x28(%ebp)
f01060bc:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01060bf:	eb ad                	jmp    f010606e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01060c1:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01060c5:	74 20                	je     f01060e7 <vprintfmt+0x245>
f01060c7:	0f be d2             	movsbl %dl,%edx
f01060ca:	83 ea 20             	sub    $0x20,%edx
f01060cd:	83 fa 5e             	cmp    $0x5e,%edx
f01060d0:	76 15                	jbe    f01060e7 <vprintfmt+0x245>
					putch('?', putdat);
f01060d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01060d5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01060d9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01060e0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01060e3:	ff d1                	call   *%ecx
f01060e5:	eb 0f                	jmp    f01060f6 <vprintfmt+0x254>
				else
					putch(ch, putdat);
f01060e7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01060ea:	89 54 24 04          	mov    %edx,0x4(%esp)
f01060ee:	89 04 24             	mov    %eax,(%esp)
f01060f1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01060f4:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01060f6:	83 eb 01             	sub    $0x1,%ebx
f01060f9:	0f b6 17             	movzbl (%edi),%edx
f01060fc:	0f be c2             	movsbl %dl,%eax
f01060ff:	83 c7 01             	add    $0x1,%edi
f0106102:	85 c0                	test   %eax,%eax
f0106104:	75 24                	jne    f010612a <vprintfmt+0x288>
f0106106:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0106109:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010610c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010610f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0106112:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0106116:	0f 8e ab fd ff ff    	jle    f0105ec7 <vprintfmt+0x25>
f010611c:	eb 20                	jmp    f010613e <vprintfmt+0x29c>
f010611e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0106121:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0106124:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0106127:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010612a:	85 f6                	test   %esi,%esi
f010612c:	78 93                	js     f01060c1 <vprintfmt+0x21f>
f010612e:	83 ee 01             	sub    $0x1,%esi
f0106131:	79 8e                	jns    f01060c1 <vprintfmt+0x21f>
f0106133:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0106136:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0106139:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010613c:	eb d1                	jmp    f010610f <vprintfmt+0x26d>
f010613e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0106141:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106145:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010614c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010614e:	83 ef 01             	sub    $0x1,%edi
f0106151:	75 ee                	jne    f0106141 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0106153:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0106156:	e9 6c fd ff ff       	jmp    f0105ec7 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010615b:	83 fa 01             	cmp    $0x1,%edx
f010615e:	66 90                	xchg   %ax,%ax
f0106160:	7e 16                	jle    f0106178 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
f0106162:	8b 45 14             	mov    0x14(%ebp),%eax
f0106165:	8d 50 08             	lea    0x8(%eax),%edx
f0106168:	89 55 14             	mov    %edx,0x14(%ebp)
f010616b:	8b 10                	mov    (%eax),%edx
f010616d:	8b 48 04             	mov    0x4(%eax),%ecx
f0106170:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0106173:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0106176:	eb 32                	jmp    f01061aa <vprintfmt+0x308>
	else if (lflag)
f0106178:	85 d2                	test   %edx,%edx
f010617a:	74 18                	je     f0106194 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
f010617c:	8b 45 14             	mov    0x14(%ebp),%eax
f010617f:	8d 50 04             	lea    0x4(%eax),%edx
f0106182:	89 55 14             	mov    %edx,0x14(%ebp)
f0106185:	8b 00                	mov    (%eax),%eax
f0106187:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010618a:	89 c1                	mov    %eax,%ecx
f010618c:	c1 f9 1f             	sar    $0x1f,%ecx
f010618f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0106192:	eb 16                	jmp    f01061aa <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
f0106194:	8b 45 14             	mov    0x14(%ebp),%eax
f0106197:	8d 50 04             	lea    0x4(%eax),%edx
f010619a:	89 55 14             	mov    %edx,0x14(%ebp)
f010619d:	8b 00                	mov    (%eax),%eax
f010619f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01061a2:	89 c7                	mov    %eax,%edi
f01061a4:	c1 ff 1f             	sar    $0x1f,%edi
f01061a7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01061aa:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01061ad:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01061b0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01061b5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01061b9:	79 7d                	jns    f0106238 <vprintfmt+0x396>
				putch('-', putdat);
f01061bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01061bf:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01061c6:	ff d6                	call   *%esi
				num = -(long long) num;
f01061c8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01061cb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01061ce:	f7 d8                	neg    %eax
f01061d0:	83 d2 00             	adc    $0x0,%edx
f01061d3:	f7 da                	neg    %edx
			}
			base = 10;
f01061d5:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01061da:	eb 5c                	jmp    f0106238 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01061dc:	8d 45 14             	lea    0x14(%ebp),%eax
f01061df:	e8 3f fc ff ff       	call   f0105e23 <getuint>
			base = 10;
f01061e4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01061e9:	eb 4d                	jmp    f0106238 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f01061eb:	8d 45 14             	lea    0x14(%ebp),%eax
f01061ee:	e8 30 fc ff ff       	call   f0105e23 <getuint>
			base = 8;
f01061f3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f01061f8:	eb 3e                	jmp    f0106238 <vprintfmt+0x396>

		// pointer
		case 'p':
			putch('0', putdat);
f01061fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01061fe:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0106205:	ff d6                	call   *%esi
			putch('x', putdat);
f0106207:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010620b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0106212:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0106214:	8b 45 14             	mov    0x14(%ebp),%eax
f0106217:	8d 50 04             	lea    0x4(%eax),%edx
f010621a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010621d:	8b 00                	mov    (%eax),%eax
f010621f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0106224:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0106229:	eb 0d                	jmp    f0106238 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010622b:	8d 45 14             	lea    0x14(%ebp),%eax
f010622e:	e8 f0 fb ff ff       	call   f0105e23 <getuint>
			base = 16;
f0106233:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0106238:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
f010623c:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0106240:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0106243:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106247:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010624b:	89 04 24             	mov    %eax,(%esp)
f010624e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106252:	89 da                	mov    %ebx,%edx
f0106254:	89 f0                	mov    %esi,%eax
f0106256:	e8 d5 fa ff ff       	call   f0105d30 <printnum>
			break;
f010625b:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010625e:	e9 64 fc ff ff       	jmp    f0105ec7 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0106263:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106267:	89 0c 24             	mov    %ecx,(%esp)
f010626a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010626c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010626f:	e9 53 fc ff ff       	jmp    f0105ec7 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0106274:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106278:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f010627f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0106281:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0106285:	0f 84 3c fc ff ff    	je     f0105ec7 <vprintfmt+0x25>
f010628b:	83 ef 01             	sub    $0x1,%edi
f010628e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0106292:	75 f7                	jne    f010628b <vprintfmt+0x3e9>
f0106294:	e9 2e fc ff ff       	jmp    f0105ec7 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f0106299:	83 c4 4c             	add    $0x4c,%esp
f010629c:	5b                   	pop    %ebx
f010629d:	5e                   	pop    %esi
f010629e:	5f                   	pop    %edi
f010629f:	5d                   	pop    %ebp
f01062a0:	c3                   	ret    

f01062a1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01062a1:	55                   	push   %ebp
f01062a2:	89 e5                	mov    %esp,%ebp
f01062a4:	83 ec 28             	sub    $0x28,%esp
f01062a7:	8b 45 08             	mov    0x8(%ebp),%eax
f01062aa:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01062ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01062b0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01062b4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01062b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01062be:	85 d2                	test   %edx,%edx
f01062c0:	7e 30                	jle    f01062f2 <vsnprintf+0x51>
f01062c2:	85 c0                	test   %eax,%eax
f01062c4:	74 2c                	je     f01062f2 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01062c6:	8b 45 14             	mov    0x14(%ebp),%eax
f01062c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01062cd:	8b 45 10             	mov    0x10(%ebp),%eax
f01062d0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01062d4:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01062d7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01062db:	c7 04 24 5d 5e 10 f0 	movl   $0xf0105e5d,(%esp)
f01062e2:	e8 bb fb ff ff       	call   f0105ea2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01062e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01062ea:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01062ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01062f0:	eb 05                	jmp    f01062f7 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01062f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01062f7:	c9                   	leave  
f01062f8:	c3                   	ret    

f01062f9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01062f9:	55                   	push   %ebp
f01062fa:	89 e5                	mov    %esp,%ebp
f01062fc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01062ff:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0106302:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106306:	8b 45 10             	mov    0x10(%ebp),%eax
f0106309:	89 44 24 08          	mov    %eax,0x8(%esp)
f010630d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106310:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106314:	8b 45 08             	mov    0x8(%ebp),%eax
f0106317:	89 04 24             	mov    %eax,(%esp)
f010631a:	e8 82 ff ff ff       	call   f01062a1 <vsnprintf>
	va_end(ap);

	return rc;
}
f010631f:	c9                   	leave  
f0106320:	c3                   	ret    
f0106321:	66 90                	xchg   %ax,%ax
f0106323:	66 90                	xchg   %ax,%ax
f0106325:	66 90                	xchg   %ax,%ax
f0106327:	66 90                	xchg   %ax,%ax
f0106329:	66 90                	xchg   %ax,%ax
f010632b:	66 90                	xchg   %ax,%ax
f010632d:	66 90                	xchg   %ax,%ax
f010632f:	90                   	nop

f0106330 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0106330:	55                   	push   %ebp
f0106331:	89 e5                	mov    %esp,%ebp
f0106333:	57                   	push   %edi
f0106334:	56                   	push   %esi
f0106335:	53                   	push   %ebx
f0106336:	83 ec 1c             	sub    $0x1c,%esp
f0106339:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010633c:	85 c0                	test   %eax,%eax
f010633e:	74 10                	je     f0106350 <readline+0x20>
		cprintf("%s", prompt);
f0106340:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106344:	c7 04 24 d9 83 10 f0 	movl   $0xf01083d9,(%esp)
f010634b:	e8 4e e3 ff ff       	call   f010469e <cprintf>

	i = 0;
	echoing = iscons(0);
f0106350:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0106357:	e8 67 a4 ff ff       	call   f01007c3 <iscons>
f010635c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010635e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0106363:	e8 4a a4 ff ff       	call   f01007b2 <getchar>
f0106368:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010636a:	85 c0                	test   %eax,%eax
f010636c:	79 17                	jns    f0106385 <readline+0x55>
			cprintf("read error: %e\n", c);
f010636e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106372:	c7 04 24 04 8f 10 f0 	movl   $0xf0108f04,(%esp)
f0106379:	e8 20 e3 ff ff       	call   f010469e <cprintf>
			return NULL;
f010637e:	b8 00 00 00 00       	mov    $0x0,%eax
f0106383:	eb 6d                	jmp    f01063f2 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0106385:	83 f8 7f             	cmp    $0x7f,%eax
f0106388:	74 05                	je     f010638f <readline+0x5f>
f010638a:	83 f8 08             	cmp    $0x8,%eax
f010638d:	75 19                	jne    f01063a8 <readline+0x78>
f010638f:	85 f6                	test   %esi,%esi
f0106391:	7e 15                	jle    f01063a8 <readline+0x78>
			if (echoing)
f0106393:	85 ff                	test   %edi,%edi
f0106395:	74 0c                	je     f01063a3 <readline+0x73>
				cputchar('\b');
f0106397:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010639e:	e8 ff a3 ff ff       	call   f01007a2 <cputchar>
			i--;
f01063a3:	83 ee 01             	sub    $0x1,%esi
f01063a6:	eb bb                	jmp    f0106363 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01063a8:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01063ae:	7f 1c                	jg     f01063cc <readline+0x9c>
f01063b0:	83 fb 1f             	cmp    $0x1f,%ebx
f01063b3:	7e 17                	jle    f01063cc <readline+0x9c>
			if (echoing)
f01063b5:	85 ff                	test   %edi,%edi
f01063b7:	74 08                	je     f01063c1 <readline+0x91>
				cputchar(c);
f01063b9:	89 1c 24             	mov    %ebx,(%esp)
f01063bc:	e8 e1 a3 ff ff       	call   f01007a2 <cputchar>
			buf[i++] = c;
f01063c1:	88 9e 80 ba 22 f0    	mov    %bl,-0xfdd4580(%esi)
f01063c7:	83 c6 01             	add    $0x1,%esi
f01063ca:	eb 97                	jmp    f0106363 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01063cc:	83 fb 0d             	cmp    $0xd,%ebx
f01063cf:	74 05                	je     f01063d6 <readline+0xa6>
f01063d1:	83 fb 0a             	cmp    $0xa,%ebx
f01063d4:	75 8d                	jne    f0106363 <readline+0x33>
			if (echoing)
f01063d6:	85 ff                	test   %edi,%edi
f01063d8:	74 0c                	je     f01063e6 <readline+0xb6>
				cputchar('\n');
f01063da:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01063e1:	e8 bc a3 ff ff       	call   f01007a2 <cputchar>
			buf[i] = 0;
f01063e6:	c6 86 80 ba 22 f0 00 	movb   $0x0,-0xfdd4580(%esi)
			return buf;
f01063ed:	b8 80 ba 22 f0       	mov    $0xf022ba80,%eax
		}
	}
}
f01063f2:	83 c4 1c             	add    $0x1c,%esp
f01063f5:	5b                   	pop    %ebx
f01063f6:	5e                   	pop    %esi
f01063f7:	5f                   	pop    %edi
f01063f8:	5d                   	pop    %ebp
f01063f9:	c3                   	ret    
f01063fa:	66 90                	xchg   %ax,%ax
f01063fc:	66 90                	xchg   %ax,%ax
f01063fe:	66 90                	xchg   %ax,%ax

f0106400 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0106400:	55                   	push   %ebp
f0106401:	89 e5                	mov    %esp,%ebp
f0106403:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0106406:	80 3a 00             	cmpb   $0x0,(%edx)
f0106409:	74 10                	je     f010641b <strlen+0x1b>
f010640b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0106410:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0106413:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0106417:	75 f7                	jne    f0106410 <strlen+0x10>
f0106419:	eb 05                	jmp    f0106420 <strlen+0x20>
f010641b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0106420:	5d                   	pop    %ebp
f0106421:	c3                   	ret    

f0106422 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0106422:	55                   	push   %ebp
f0106423:	89 e5                	mov    %esp,%ebp
f0106425:	53                   	push   %ebx
f0106426:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0106429:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010642c:	85 c9                	test   %ecx,%ecx
f010642e:	74 1c                	je     f010644c <strnlen+0x2a>
f0106430:	80 3b 00             	cmpb   $0x0,(%ebx)
f0106433:	74 1e                	je     f0106453 <strnlen+0x31>
f0106435:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f010643a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010643c:	39 ca                	cmp    %ecx,%edx
f010643e:	74 18                	je     f0106458 <strnlen+0x36>
f0106440:	83 c2 01             	add    $0x1,%edx
f0106443:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0106448:	75 f0                	jne    f010643a <strnlen+0x18>
f010644a:	eb 0c                	jmp    f0106458 <strnlen+0x36>
f010644c:	b8 00 00 00 00       	mov    $0x0,%eax
f0106451:	eb 05                	jmp    f0106458 <strnlen+0x36>
f0106453:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0106458:	5b                   	pop    %ebx
f0106459:	5d                   	pop    %ebp
f010645a:	c3                   	ret    

f010645b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010645b:	55                   	push   %ebp
f010645c:	89 e5                	mov    %esp,%ebp
f010645e:	53                   	push   %ebx
f010645f:	8b 45 08             	mov    0x8(%ebp),%eax
f0106462:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0106465:	89 c2                	mov    %eax,%edx
f0106467:	0f b6 19             	movzbl (%ecx),%ebx
f010646a:	88 1a                	mov    %bl,(%edx)
f010646c:	83 c2 01             	add    $0x1,%edx
f010646f:	83 c1 01             	add    $0x1,%ecx
f0106472:	84 db                	test   %bl,%bl
f0106474:	75 f1                	jne    f0106467 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0106476:	5b                   	pop    %ebx
f0106477:	5d                   	pop    %ebp
f0106478:	c3                   	ret    

f0106479 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0106479:	55                   	push   %ebp
f010647a:	89 e5                	mov    %esp,%ebp
f010647c:	53                   	push   %ebx
f010647d:	83 ec 08             	sub    $0x8,%esp
f0106480:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0106483:	89 1c 24             	mov    %ebx,(%esp)
f0106486:	e8 75 ff ff ff       	call   f0106400 <strlen>
	strcpy(dst + len, src);
f010648b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010648e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106492:	01 d8                	add    %ebx,%eax
f0106494:	89 04 24             	mov    %eax,(%esp)
f0106497:	e8 bf ff ff ff       	call   f010645b <strcpy>
	return dst;
}
f010649c:	89 d8                	mov    %ebx,%eax
f010649e:	83 c4 08             	add    $0x8,%esp
f01064a1:	5b                   	pop    %ebx
f01064a2:	5d                   	pop    %ebp
f01064a3:	c3                   	ret    

f01064a4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01064a4:	55                   	push   %ebp
f01064a5:	89 e5                	mov    %esp,%ebp
f01064a7:	56                   	push   %esi
f01064a8:	53                   	push   %ebx
f01064a9:	8b 75 08             	mov    0x8(%ebp),%esi
f01064ac:	8b 55 0c             	mov    0xc(%ebp),%edx
f01064af:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01064b2:	85 db                	test   %ebx,%ebx
f01064b4:	74 16                	je     f01064cc <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
f01064b6:	01 f3                	add    %esi,%ebx
f01064b8:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
f01064ba:	0f b6 02             	movzbl (%edx),%eax
f01064bd:	88 01                	mov    %al,(%ecx)
f01064bf:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01064c2:	80 3a 01             	cmpb   $0x1,(%edx)
f01064c5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01064c8:	39 d9                	cmp    %ebx,%ecx
f01064ca:	75 ee                	jne    f01064ba <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01064cc:	89 f0                	mov    %esi,%eax
f01064ce:	5b                   	pop    %ebx
f01064cf:	5e                   	pop    %esi
f01064d0:	5d                   	pop    %ebp
f01064d1:	c3                   	ret    

f01064d2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01064d2:	55                   	push   %ebp
f01064d3:	89 e5                	mov    %esp,%ebp
f01064d5:	57                   	push   %edi
f01064d6:	56                   	push   %esi
f01064d7:	53                   	push   %ebx
f01064d8:	8b 7d 08             	mov    0x8(%ebp),%edi
f01064db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01064de:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01064e1:	89 f8                	mov    %edi,%eax
f01064e3:	85 f6                	test   %esi,%esi
f01064e5:	74 33                	je     f010651a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
f01064e7:	83 fe 01             	cmp    $0x1,%esi
f01064ea:	74 25                	je     f0106511 <strlcpy+0x3f>
f01064ec:	0f b6 0b             	movzbl (%ebx),%ecx
f01064ef:	84 c9                	test   %cl,%cl
f01064f1:	74 22                	je     f0106515 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f01064f3:	83 ee 02             	sub    $0x2,%esi
f01064f6:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01064fb:	88 08                	mov    %cl,(%eax)
f01064fd:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0106500:	39 f2                	cmp    %esi,%edx
f0106502:	74 13                	je     f0106517 <strlcpy+0x45>
f0106504:	83 c2 01             	add    $0x1,%edx
f0106507:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010650b:	84 c9                	test   %cl,%cl
f010650d:	75 ec                	jne    f01064fb <strlcpy+0x29>
f010650f:	eb 06                	jmp    f0106517 <strlcpy+0x45>
f0106511:	89 f8                	mov    %edi,%eax
f0106513:	eb 02                	jmp    f0106517 <strlcpy+0x45>
f0106515:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0106517:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010651a:	29 f8                	sub    %edi,%eax
}
f010651c:	5b                   	pop    %ebx
f010651d:	5e                   	pop    %esi
f010651e:	5f                   	pop    %edi
f010651f:	5d                   	pop    %ebp
f0106520:	c3                   	ret    

f0106521 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0106521:	55                   	push   %ebp
f0106522:	89 e5                	mov    %esp,%ebp
f0106524:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106527:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010652a:	0f b6 01             	movzbl (%ecx),%eax
f010652d:	84 c0                	test   %al,%al
f010652f:	74 15                	je     f0106546 <strcmp+0x25>
f0106531:	3a 02                	cmp    (%edx),%al
f0106533:	75 11                	jne    f0106546 <strcmp+0x25>
		p++, q++;
f0106535:	83 c1 01             	add    $0x1,%ecx
f0106538:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010653b:	0f b6 01             	movzbl (%ecx),%eax
f010653e:	84 c0                	test   %al,%al
f0106540:	74 04                	je     f0106546 <strcmp+0x25>
f0106542:	3a 02                	cmp    (%edx),%al
f0106544:	74 ef                	je     f0106535 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0106546:	0f b6 c0             	movzbl %al,%eax
f0106549:	0f b6 12             	movzbl (%edx),%edx
f010654c:	29 d0                	sub    %edx,%eax
}
f010654e:	5d                   	pop    %ebp
f010654f:	c3                   	ret    

f0106550 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0106550:	55                   	push   %ebp
f0106551:	89 e5                	mov    %esp,%ebp
f0106553:	56                   	push   %esi
f0106554:	53                   	push   %ebx
f0106555:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0106558:	8b 55 0c             	mov    0xc(%ebp),%edx
f010655b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
f010655e:	85 f6                	test   %esi,%esi
f0106560:	74 29                	je     f010658b <strncmp+0x3b>
f0106562:	0f b6 03             	movzbl (%ebx),%eax
f0106565:	84 c0                	test   %al,%al
f0106567:	74 30                	je     f0106599 <strncmp+0x49>
f0106569:	3a 02                	cmp    (%edx),%al
f010656b:	75 2c                	jne    f0106599 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
f010656d:	8d 43 01             	lea    0x1(%ebx),%eax
f0106570:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
f0106572:	89 c3                	mov    %eax,%ebx
f0106574:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0106577:	39 f0                	cmp    %esi,%eax
f0106579:	74 17                	je     f0106592 <strncmp+0x42>
f010657b:	0f b6 08             	movzbl (%eax),%ecx
f010657e:	84 c9                	test   %cl,%cl
f0106580:	74 17                	je     f0106599 <strncmp+0x49>
f0106582:	83 c0 01             	add    $0x1,%eax
f0106585:	3a 0a                	cmp    (%edx),%cl
f0106587:	74 e9                	je     f0106572 <strncmp+0x22>
f0106589:	eb 0e                	jmp    f0106599 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
f010658b:	b8 00 00 00 00       	mov    $0x0,%eax
f0106590:	eb 0f                	jmp    f01065a1 <strncmp+0x51>
f0106592:	b8 00 00 00 00       	mov    $0x0,%eax
f0106597:	eb 08                	jmp    f01065a1 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0106599:	0f b6 03             	movzbl (%ebx),%eax
f010659c:	0f b6 12             	movzbl (%edx),%edx
f010659f:	29 d0                	sub    %edx,%eax
}
f01065a1:	5b                   	pop    %ebx
f01065a2:	5e                   	pop    %esi
f01065a3:	5d                   	pop    %ebp
f01065a4:	c3                   	ret    

f01065a5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01065a5:	55                   	push   %ebp
f01065a6:	89 e5                	mov    %esp,%ebp
f01065a8:	53                   	push   %ebx
f01065a9:	8b 45 08             	mov    0x8(%ebp),%eax
f01065ac:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
f01065af:	0f b6 18             	movzbl (%eax),%ebx
f01065b2:	84 db                	test   %bl,%bl
f01065b4:	74 1d                	je     f01065d3 <strchr+0x2e>
f01065b6:	89 d1                	mov    %edx,%ecx
		if (*s == c)
f01065b8:	38 d3                	cmp    %dl,%bl
f01065ba:	75 06                	jne    f01065c2 <strchr+0x1d>
f01065bc:	eb 1a                	jmp    f01065d8 <strchr+0x33>
f01065be:	38 ca                	cmp    %cl,%dl
f01065c0:	74 16                	je     f01065d8 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01065c2:	83 c0 01             	add    $0x1,%eax
f01065c5:	0f b6 10             	movzbl (%eax),%edx
f01065c8:	84 d2                	test   %dl,%dl
f01065ca:	75 f2                	jne    f01065be <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
f01065cc:	b8 00 00 00 00       	mov    $0x0,%eax
f01065d1:	eb 05                	jmp    f01065d8 <strchr+0x33>
f01065d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01065d8:	5b                   	pop    %ebx
f01065d9:	5d                   	pop    %ebp
f01065da:	c3                   	ret    

f01065db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01065db:	55                   	push   %ebp
f01065dc:	89 e5                	mov    %esp,%ebp
f01065de:	53                   	push   %ebx
f01065df:	8b 45 08             	mov    0x8(%ebp),%eax
f01065e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
f01065e5:	0f b6 18             	movzbl (%eax),%ebx
f01065e8:	84 db                	test   %bl,%bl
f01065ea:	74 16                	je     f0106602 <strfind+0x27>
f01065ec:	89 d1                	mov    %edx,%ecx
		if (*s == c)
f01065ee:	38 d3                	cmp    %dl,%bl
f01065f0:	75 06                	jne    f01065f8 <strfind+0x1d>
f01065f2:	eb 0e                	jmp    f0106602 <strfind+0x27>
f01065f4:	38 ca                	cmp    %cl,%dl
f01065f6:	74 0a                	je     f0106602 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01065f8:	83 c0 01             	add    $0x1,%eax
f01065fb:	0f b6 10             	movzbl (%eax),%edx
f01065fe:	84 d2                	test   %dl,%dl
f0106600:	75 f2                	jne    f01065f4 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
f0106602:	5b                   	pop    %ebx
f0106603:	5d                   	pop    %ebp
f0106604:	c3                   	ret    

f0106605 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0106605:	55                   	push   %ebp
f0106606:	89 e5                	mov    %esp,%ebp
f0106608:	83 ec 0c             	sub    $0xc,%esp
f010660b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010660e:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0106611:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0106614:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106617:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010661a:	85 c9                	test   %ecx,%ecx
f010661c:	74 36                	je     f0106654 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010661e:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0106624:	75 28                	jne    f010664e <memset+0x49>
f0106626:	f6 c1 03             	test   $0x3,%cl
f0106629:	75 23                	jne    f010664e <memset+0x49>
		c &= 0xFF;
f010662b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010662f:	89 d3                	mov    %edx,%ebx
f0106631:	c1 e3 08             	shl    $0x8,%ebx
f0106634:	89 d6                	mov    %edx,%esi
f0106636:	c1 e6 18             	shl    $0x18,%esi
f0106639:	89 d0                	mov    %edx,%eax
f010663b:	c1 e0 10             	shl    $0x10,%eax
f010663e:	09 f0                	or     %esi,%eax
f0106640:	09 c2                	or     %eax,%edx
f0106642:	89 d0                	mov    %edx,%eax
f0106644:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0106646:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0106649:	fc                   	cld    
f010664a:	f3 ab                	rep stos %eax,%es:(%edi)
f010664c:	eb 06                	jmp    f0106654 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010664e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106651:	fc                   	cld    
f0106652:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0106654:	89 f8                	mov    %edi,%eax
f0106656:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0106659:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010665c:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010665f:	89 ec                	mov    %ebp,%esp
f0106661:	5d                   	pop    %ebp
f0106662:	c3                   	ret    

f0106663 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0106663:	55                   	push   %ebp
f0106664:	89 e5                	mov    %esp,%ebp
f0106666:	83 ec 08             	sub    $0x8,%esp
f0106669:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010666c:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010666f:	8b 45 08             	mov    0x8(%ebp),%eax
f0106672:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106675:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0106678:	39 c6                	cmp    %eax,%esi
f010667a:	73 36                	jae    f01066b2 <memmove+0x4f>
f010667c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010667f:	39 d0                	cmp    %edx,%eax
f0106681:	73 2f                	jae    f01066b2 <memmove+0x4f>
		s += n;
		d += n;
f0106683:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0106686:	f6 c2 03             	test   $0x3,%dl
f0106689:	75 1b                	jne    f01066a6 <memmove+0x43>
f010668b:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0106691:	75 13                	jne    f01066a6 <memmove+0x43>
f0106693:	f6 c1 03             	test   $0x3,%cl
f0106696:	75 0e                	jne    f01066a6 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0106698:	83 ef 04             	sub    $0x4,%edi
f010669b:	8d 72 fc             	lea    -0x4(%edx),%esi
f010669e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01066a1:	fd                   	std    
f01066a2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01066a4:	eb 09                	jmp    f01066af <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01066a6:	83 ef 01             	sub    $0x1,%edi
f01066a9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01066ac:	fd                   	std    
f01066ad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01066af:	fc                   	cld    
f01066b0:	eb 20                	jmp    f01066d2 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01066b2:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01066b8:	75 13                	jne    f01066cd <memmove+0x6a>
f01066ba:	a8 03                	test   $0x3,%al
f01066bc:	75 0f                	jne    f01066cd <memmove+0x6a>
f01066be:	f6 c1 03             	test   $0x3,%cl
f01066c1:	75 0a                	jne    f01066cd <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01066c3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01066c6:	89 c7                	mov    %eax,%edi
f01066c8:	fc                   	cld    
f01066c9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01066cb:	eb 05                	jmp    f01066d2 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01066cd:	89 c7                	mov    %eax,%edi
f01066cf:	fc                   	cld    
f01066d0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01066d2:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01066d5:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01066d8:	89 ec                	mov    %ebp,%esp
f01066da:	5d                   	pop    %ebp
f01066db:	c3                   	ret    

f01066dc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01066dc:	55                   	push   %ebp
f01066dd:	89 e5                	mov    %esp,%ebp
f01066df:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01066e2:	8b 45 10             	mov    0x10(%ebp),%eax
f01066e5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01066e9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01066ec:	89 44 24 04          	mov    %eax,0x4(%esp)
f01066f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01066f3:	89 04 24             	mov    %eax,(%esp)
f01066f6:	e8 68 ff ff ff       	call   f0106663 <memmove>
}
f01066fb:	c9                   	leave  
f01066fc:	c3                   	ret    

f01066fd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01066fd:	55                   	push   %ebp
f01066fe:	89 e5                	mov    %esp,%ebp
f0106700:	57                   	push   %edi
f0106701:	56                   	push   %esi
f0106702:	53                   	push   %ebx
f0106703:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0106706:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106709:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010670c:	8d 78 ff             	lea    -0x1(%eax),%edi
f010670f:	85 c0                	test   %eax,%eax
f0106711:	74 36                	je     f0106749 <memcmp+0x4c>
		if (*s1 != *s2)
f0106713:	0f b6 03             	movzbl (%ebx),%eax
f0106716:	0f b6 0e             	movzbl (%esi),%ecx
f0106719:	38 c8                	cmp    %cl,%al
f010671b:	75 17                	jne    f0106734 <memcmp+0x37>
f010671d:	ba 00 00 00 00       	mov    $0x0,%edx
f0106722:	eb 1a                	jmp    f010673e <memcmp+0x41>
f0106724:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0106729:	83 c2 01             	add    $0x1,%edx
f010672c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0106730:	38 c8                	cmp    %cl,%al
f0106732:	74 0a                	je     f010673e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
f0106734:	0f b6 c0             	movzbl %al,%eax
f0106737:	0f b6 c9             	movzbl %cl,%ecx
f010673a:	29 c8                	sub    %ecx,%eax
f010673c:	eb 10                	jmp    f010674e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010673e:	39 fa                	cmp    %edi,%edx
f0106740:	75 e2                	jne    f0106724 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0106742:	b8 00 00 00 00       	mov    $0x0,%eax
f0106747:	eb 05                	jmp    f010674e <memcmp+0x51>
f0106749:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010674e:	5b                   	pop    %ebx
f010674f:	5e                   	pop    %esi
f0106750:	5f                   	pop    %edi
f0106751:	5d                   	pop    %ebp
f0106752:	c3                   	ret    

f0106753 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0106753:	55                   	push   %ebp
f0106754:	89 e5                	mov    %esp,%ebp
f0106756:	53                   	push   %ebx
f0106757:	8b 45 08             	mov    0x8(%ebp),%eax
f010675a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
f010675d:	89 c2                	mov    %eax,%edx
f010675f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0106762:	39 d0                	cmp    %edx,%eax
f0106764:	73 13                	jae    f0106779 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
f0106766:	89 d9                	mov    %ebx,%ecx
f0106768:	38 18                	cmp    %bl,(%eax)
f010676a:	75 06                	jne    f0106772 <memfind+0x1f>
f010676c:	eb 0b                	jmp    f0106779 <memfind+0x26>
f010676e:	38 08                	cmp    %cl,(%eax)
f0106770:	74 07                	je     f0106779 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0106772:	83 c0 01             	add    $0x1,%eax
f0106775:	39 d0                	cmp    %edx,%eax
f0106777:	75 f5                	jne    f010676e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0106779:	5b                   	pop    %ebx
f010677a:	5d                   	pop    %ebp
f010677b:	c3                   	ret    

f010677c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010677c:	55                   	push   %ebp
f010677d:	89 e5                	mov    %esp,%ebp
f010677f:	57                   	push   %edi
f0106780:	56                   	push   %esi
f0106781:	53                   	push   %ebx
f0106782:	83 ec 04             	sub    $0x4,%esp
f0106785:	8b 55 08             	mov    0x8(%ebp),%edx
f0106788:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010678b:	0f b6 02             	movzbl (%edx),%eax
f010678e:	3c 09                	cmp    $0x9,%al
f0106790:	74 04                	je     f0106796 <strtol+0x1a>
f0106792:	3c 20                	cmp    $0x20,%al
f0106794:	75 0e                	jne    f01067a4 <strtol+0x28>
		s++;
f0106796:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106799:	0f b6 02             	movzbl (%edx),%eax
f010679c:	3c 09                	cmp    $0x9,%al
f010679e:	74 f6                	je     f0106796 <strtol+0x1a>
f01067a0:	3c 20                	cmp    $0x20,%al
f01067a2:	74 f2                	je     f0106796 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f01067a4:	3c 2b                	cmp    $0x2b,%al
f01067a6:	75 0a                	jne    f01067b2 <strtol+0x36>
		s++;
f01067a8:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01067ab:	bf 00 00 00 00       	mov    $0x0,%edi
f01067b0:	eb 10                	jmp    f01067c2 <strtol+0x46>
f01067b2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01067b7:	3c 2d                	cmp    $0x2d,%al
f01067b9:	75 07                	jne    f01067c2 <strtol+0x46>
		s++, neg = 1;
f01067bb:	83 c2 01             	add    $0x1,%edx
f01067be:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01067c2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01067c8:	75 15                	jne    f01067df <strtol+0x63>
f01067ca:	80 3a 30             	cmpb   $0x30,(%edx)
f01067cd:	75 10                	jne    f01067df <strtol+0x63>
f01067cf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01067d3:	75 0a                	jne    f01067df <strtol+0x63>
		s += 2, base = 16;
f01067d5:	83 c2 02             	add    $0x2,%edx
f01067d8:	bb 10 00 00 00       	mov    $0x10,%ebx
f01067dd:	eb 10                	jmp    f01067ef <strtol+0x73>
	else if (base == 0 && s[0] == '0')
f01067df:	85 db                	test   %ebx,%ebx
f01067e1:	75 0c                	jne    f01067ef <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01067e3:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01067e5:	80 3a 30             	cmpb   $0x30,(%edx)
f01067e8:	75 05                	jne    f01067ef <strtol+0x73>
		s++, base = 8;
f01067ea:	83 c2 01             	add    $0x1,%edx
f01067ed:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f01067ef:	b8 00 00 00 00       	mov    $0x0,%eax
f01067f4:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01067f7:	0f b6 0a             	movzbl (%edx),%ecx
f01067fa:	8d 71 d0             	lea    -0x30(%ecx),%esi
f01067fd:	89 f3                	mov    %esi,%ebx
f01067ff:	80 fb 09             	cmp    $0x9,%bl
f0106802:	77 08                	ja     f010680c <strtol+0x90>
			dig = *s - '0';
f0106804:	0f be c9             	movsbl %cl,%ecx
f0106807:	83 e9 30             	sub    $0x30,%ecx
f010680a:	eb 22                	jmp    f010682e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
f010680c:	8d 71 9f             	lea    -0x61(%ecx),%esi
f010680f:	89 f3                	mov    %esi,%ebx
f0106811:	80 fb 19             	cmp    $0x19,%bl
f0106814:	77 08                	ja     f010681e <strtol+0xa2>
			dig = *s - 'a' + 10;
f0106816:	0f be c9             	movsbl %cl,%ecx
f0106819:	83 e9 57             	sub    $0x57,%ecx
f010681c:	eb 10                	jmp    f010682e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
f010681e:	8d 71 bf             	lea    -0x41(%ecx),%esi
f0106821:	89 f3                	mov    %esi,%ebx
f0106823:	80 fb 19             	cmp    $0x19,%bl
f0106826:	77 16                	ja     f010683e <strtol+0xc2>
			dig = *s - 'A' + 10;
f0106828:	0f be c9             	movsbl %cl,%ecx
f010682b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010682e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0106831:	7d 0f                	jge    f0106842 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
f0106833:	83 c2 01             	add    $0x1,%edx
f0106836:	0f af 45 f0          	imul   -0x10(%ebp),%eax
f010683a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f010683c:	eb b9                	jmp    f01067f7 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f010683e:	89 c1                	mov    %eax,%ecx
f0106840:	eb 02                	jmp    f0106844 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0106842:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0106844:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0106848:	74 05                	je     f010684f <strtol+0xd3>
		*endptr = (char *) s;
f010684a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010684d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f010684f:	89 ca                	mov    %ecx,%edx
f0106851:	f7 da                	neg    %edx
f0106853:	85 ff                	test   %edi,%edi
f0106855:	0f 45 c2             	cmovne %edx,%eax
}
f0106858:	83 c4 04             	add    $0x4,%esp
f010685b:	5b                   	pop    %ebx
f010685c:	5e                   	pop    %esi
f010685d:	5f                   	pop    %edi
f010685e:	5d                   	pop    %ebp
f010685f:	c3                   	ret    

f0106860 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0106860:	fa                   	cli    

	xorw    %ax, %ax
f0106861:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0106863:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106865:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106867:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0106869:	0f 01 16             	lgdtl  (%esi)
f010686c:	74 70                	je     f01068de <mpentry_end+0x4>
	movl    %cr0, %eax
f010686e:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0106871:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0106875:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0106878:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010687e:	08 00                	or     %al,(%eax)

f0106880 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0106880:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0106884:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106886:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106888:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010688a:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010688e:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0106890:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0106892:	b8 00 10 12 00       	mov    $0x121000,%eax
	movl    %eax, %cr3
f0106897:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010689a:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f010689d:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01068a2:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01068a5:	8b 25 84 be 22 f0    	mov    0xf022be84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01068ab:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01068b0:	b8 a8 00 10 f0       	mov    $0xf01000a8,%eax
	call    *%eax
f01068b5:	ff d0                	call   *%eax

f01068b7 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01068b7:	eb fe                	jmp    f01068b7 <spin>
f01068b9:	8d 76 00             	lea    0x0(%esi),%esi

f01068bc <gdt>:
	...
f01068c4:	ff                   	(bad)  
f01068c5:	ff 00                	incl   (%eax)
f01068c7:	00 00                	add    %al,(%eax)
f01068c9:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01068d0:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f01068d4 <gdtdesc>:
f01068d4:	17                   	pop    %ss
f01068d5:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01068da <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01068da:	90                   	nop
f01068db:	66 90                	xchg   %ax,%ax
f01068dd:	66 90                	xchg   %ax,%ax
f01068df:	90                   	nop

f01068e0 <sum>:
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01068e0:	85 d2                	test   %edx,%edx
f01068e2:	7e 1c                	jle    f0106900 <sum+0x20>
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f01068e4:	55                   	push   %ebp
f01068e5:	89 e5                	mov    %esp,%ebp
f01068e7:	53                   	push   %ebx
f01068e8:	89 c1                	mov    %eax,%ecx
#define MPIOAPIC  0x02  // One per I/O APIC
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
f01068ea:	8d 1c 10             	lea    (%eax,%edx,1),%ebx
{
	int i, sum;

	sum = 0;
f01068ed:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f01068f2:	0f b6 11             	movzbl (%ecx),%edx
f01068f5:	01 d0                	add    %edx,%eax
f01068f7:	83 c1 01             	add    $0x1,%ecx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01068fa:	39 d9                	cmp    %ebx,%ecx
f01068fc:	75 f4                	jne    f01068f2 <sum+0x12>
f01068fe:	eb 06                	jmp    f0106906 <sum+0x26>
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0106900:	b8 00 00 00 00       	mov    $0x0,%eax
f0106905:	c3                   	ret    
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0106906:	5b                   	pop    %ebx
f0106907:	5d                   	pop    %ebp
f0106908:	c3                   	ret    

f0106909 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106909:	55                   	push   %ebp
f010690a:	89 e5                	mov    %esp,%ebp
f010690c:	56                   	push   %esi
f010690d:	53                   	push   %ebx
f010690e:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106911:	8b 0d 88 be 22 f0    	mov    0xf022be88,%ecx
f0106917:	89 c3                	mov    %eax,%ebx
f0106919:	c1 eb 0c             	shr    $0xc,%ebx
f010691c:	39 cb                	cmp    %ecx,%ebx
f010691e:	72 20                	jb     f0106940 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106920:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106924:	c7 44 24 08 68 74 10 	movl   $0xf0107468,0x8(%esp)
f010692b:	f0 
f010692c:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0106933:	00 
f0106934:	c7 04 24 a1 90 10 f0 	movl   $0xf01090a1,(%esp)
f010693b:	e8 00 97 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106940:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0106946:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106949:	89 f0                	mov    %esi,%eax
f010694b:	c1 e8 0c             	shr    $0xc,%eax
f010694e:	39 c1                	cmp    %eax,%ecx
f0106950:	77 20                	ja     f0106972 <mpsearch1+0x69>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106952:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106956:	c7 44 24 08 68 74 10 	movl   $0xf0107468,0x8(%esp)
f010695d:	f0 
f010695e:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0106965:	00 
f0106966:	c7 04 24 a1 90 10 f0 	movl   $0xf01090a1,(%esp)
f010696d:	e8 ce 96 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106972:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0106978:	39 f3                	cmp    %esi,%ebx
f010697a:	73 3a                	jae    f01069b6 <mpsearch1+0xad>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010697c:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106983:	00 
f0106984:	c7 44 24 04 b1 90 10 	movl   $0xf01090b1,0x4(%esp)
f010698b:	f0 
f010698c:	89 1c 24             	mov    %ebx,(%esp)
f010698f:	e8 69 fd ff ff       	call   f01066fd <memcmp>
f0106994:	85 c0                	test   %eax,%eax
f0106996:	75 10                	jne    f01069a8 <mpsearch1+0x9f>
		    sum(mp, sizeof(*mp)) == 0)
f0106998:	ba 10 00 00 00       	mov    $0x10,%edx
f010699d:	89 d8                	mov    %ebx,%eax
f010699f:	e8 3c ff ff ff       	call   f01068e0 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01069a4:	84 c0                	test   %al,%al
f01069a6:	74 13                	je     f01069bb <mpsearch1+0xb2>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01069a8:	83 c3 10             	add    $0x10,%ebx
f01069ab:	39 f3                	cmp    %esi,%ebx
f01069ad:	72 cd                	jb     f010697c <mpsearch1+0x73>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01069af:	bb 00 00 00 00       	mov    $0x0,%ebx
f01069b4:	eb 05                	jmp    f01069bb <mpsearch1+0xb2>
f01069b6:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f01069bb:	89 d8                	mov    %ebx,%eax
f01069bd:	83 c4 10             	add    $0x10,%esp
f01069c0:	5b                   	pop    %ebx
f01069c1:	5e                   	pop    %esi
f01069c2:	5d                   	pop    %ebp
f01069c3:	c3                   	ret    

f01069c4 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01069c4:	55                   	push   %ebp
f01069c5:	89 e5                	mov    %esp,%ebp
f01069c7:	57                   	push   %edi
f01069c8:	56                   	push   %esi
f01069c9:	53                   	push   %ebx
f01069ca:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01069cd:	c7 05 c0 c3 22 f0 20 	movl   $0xf022c020,0xf022c3c0
f01069d4:	c0 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01069d7:	83 3d 88 be 22 f0 00 	cmpl   $0x0,0xf022be88
f01069de:	75 24                	jne    f0106a04 <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01069e0:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f01069e7:	00 
f01069e8:	c7 44 24 08 68 74 10 	movl   $0xf0107468,0x8(%esp)
f01069ef:	f0 
f01069f0:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f01069f7:	00 
f01069f8:	c7 04 24 a1 90 10 f0 	movl   $0xf01090a1,(%esp)
f01069ff:	e8 3c 96 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0106a04:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0106a0b:	85 c0                	test   %eax,%eax
f0106a0d:	74 16                	je     f0106a25 <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f0106a0f:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0106a12:	ba 00 04 00 00       	mov    $0x400,%edx
f0106a17:	e8 ed fe ff ff       	call   f0106909 <mpsearch1>
f0106a1c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106a1f:	85 c0                	test   %eax,%eax
f0106a21:	75 3c                	jne    f0106a5f <mp_init+0x9b>
f0106a23:	eb 20                	jmp    f0106a45 <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0106a25:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0106a2c:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0106a2f:	2d 00 04 00 00       	sub    $0x400,%eax
f0106a34:	ba 00 04 00 00       	mov    $0x400,%edx
f0106a39:	e8 cb fe ff ff       	call   f0106909 <mpsearch1>
f0106a3e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106a41:	85 c0                	test   %eax,%eax
f0106a43:	75 1a                	jne    f0106a5f <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0106a45:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106a4a:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0106a4f:	e8 b5 fe ff ff       	call   f0106909 <mpsearch1>
f0106a54:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0106a57:	85 c0                	test   %eax,%eax
f0106a59:	0f 84 2a 02 00 00    	je     f0106c89 <mp_init+0x2c5>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0106a5f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106a62:	8b 78 04             	mov    0x4(%eax),%edi
f0106a65:	85 ff                	test   %edi,%edi
f0106a67:	74 06                	je     f0106a6f <mp_init+0xab>
f0106a69:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0106a6d:	74 11                	je     f0106a80 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f0106a6f:	c7 04 24 14 8f 10 f0 	movl   $0xf0108f14,(%esp)
f0106a76:	e8 23 dc ff ff       	call   f010469e <cprintf>
f0106a7b:	e9 09 02 00 00       	jmp    f0106c89 <mp_init+0x2c5>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106a80:	89 f8                	mov    %edi,%eax
f0106a82:	c1 e8 0c             	shr    $0xc,%eax
f0106a85:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0106a8b:	72 20                	jb     f0106aad <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106a8d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106a91:	c7 44 24 08 68 74 10 	movl   $0xf0107468,0x8(%esp)
f0106a98:	f0 
f0106a99:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0106aa0:	00 
f0106aa1:	c7 04 24 a1 90 10 f0 	movl   $0xf01090a1,(%esp)
f0106aa8:	e8 93 95 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106aad:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106ab3:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106aba:	00 
f0106abb:	c7 44 24 04 b6 90 10 	movl   $0xf01090b6,0x4(%esp)
f0106ac2:	f0 
f0106ac3:	89 3c 24             	mov    %edi,(%esp)
f0106ac6:	e8 32 fc ff ff       	call   f01066fd <memcmp>
f0106acb:	85 c0                	test   %eax,%eax
f0106acd:	74 11                	je     f0106ae0 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106acf:	c7 04 24 44 8f 10 f0 	movl   $0xf0108f44,(%esp)
f0106ad6:	e8 c3 db ff ff       	call   f010469e <cprintf>
f0106adb:	e9 a9 01 00 00       	jmp    f0106c89 <mp_init+0x2c5>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0106ae0:	0f b7 5f 04          	movzwl 0x4(%edi),%ebx
f0106ae4:	0f b7 d3             	movzwl %bx,%edx
f0106ae7:	89 f8                	mov    %edi,%eax
f0106ae9:	e8 f2 fd ff ff       	call   f01068e0 <sum>
f0106aee:	84 c0                	test   %al,%al
f0106af0:	74 11                	je     f0106b03 <mp_init+0x13f>
		cprintf("SMP: Bad MP configuration checksum\n");
f0106af2:	c7 04 24 78 8f 10 f0 	movl   $0xf0108f78,(%esp)
f0106af9:	e8 a0 db ff ff       	call   f010469e <cprintf>
f0106afe:	e9 86 01 00 00       	jmp    f0106c89 <mp_init+0x2c5>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0106b03:	0f b6 47 06          	movzbl 0x6(%edi),%eax
f0106b07:	3c 04                	cmp    $0x4,%al
f0106b09:	74 1f                	je     f0106b2a <mp_init+0x166>
f0106b0b:	3c 01                	cmp    $0x1,%al
f0106b0d:	8d 76 00             	lea    0x0(%esi),%esi
f0106b10:	74 18                	je     f0106b2a <mp_init+0x166>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106b12:	0f b6 c0             	movzbl %al,%eax
f0106b15:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b19:	c7 04 24 9c 8f 10 f0 	movl   $0xf0108f9c,(%esp)
f0106b20:	e8 79 db ff ff       	call   f010469e <cprintf>
f0106b25:	e9 5f 01 00 00       	jmp    f0106c89 <mp_init+0x2c5>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f0106b2a:	0f b7 57 28          	movzwl 0x28(%edi),%edx
f0106b2e:	0f b7 db             	movzwl %bx,%ebx
f0106b31:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f0106b34:	e8 a7 fd ff ff       	call   f01068e0 <sum>
f0106b39:	3a 47 2a             	cmp    0x2a(%edi),%al
f0106b3c:	74 11                	je     f0106b4f <mp_init+0x18b>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106b3e:	c7 04 24 bc 8f 10 f0 	movl   $0xf0108fbc,(%esp)
f0106b45:	e8 54 db ff ff       	call   f010469e <cprintf>
f0106b4a:	e9 3a 01 00 00       	jmp    f0106c89 <mp_init+0x2c5>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0106b4f:	85 ff                	test   %edi,%edi
f0106b51:	0f 84 32 01 00 00    	je     f0106c89 <mp_init+0x2c5>
		return;
	ismp = 1;
f0106b57:	c7 05 00 c0 22 f0 01 	movl   $0x1,0xf022c000
f0106b5e:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0106b61:	8b 47 24             	mov    0x24(%edi),%eax
f0106b64:	a3 00 d0 26 f0       	mov    %eax,0xf026d000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106b69:	8d 77 2c             	lea    0x2c(%edi),%esi
f0106b6c:	66 83 7f 22 00       	cmpw   $0x0,0x22(%edi)
f0106b71:	0f 84 97 00 00 00    	je     f0106c0e <mp_init+0x24a>
f0106b77:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (*p) {
f0106b7c:	0f b6 06             	movzbl (%esi),%eax
f0106b7f:	84 c0                	test   %al,%al
f0106b81:	74 06                	je     f0106b89 <mp_init+0x1c5>
f0106b83:	3c 04                	cmp    $0x4,%al
f0106b85:	77 57                	ja     f0106bde <mp_init+0x21a>
f0106b87:	eb 50                	jmp    f0106bd9 <mp_init+0x215>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0106b89:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f0106b8d:	8d 76 00             	lea    0x0(%esi),%esi
f0106b90:	74 11                	je     f0106ba3 <mp_init+0x1df>
				bootcpu = &cpus[ncpu];
f0106b92:	6b 05 c4 c3 22 f0 74 	imul   $0x74,0xf022c3c4,%eax
f0106b99:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f0106b9e:	a3 c0 c3 22 f0       	mov    %eax,0xf022c3c0
			if (ncpu < NCPU) {
f0106ba3:	a1 c4 c3 22 f0       	mov    0xf022c3c4,%eax
f0106ba8:	83 f8 07             	cmp    $0x7,%eax
f0106bab:	7f 13                	jg     f0106bc0 <mp_init+0x1fc>
				cpus[ncpu].cpu_id = ncpu;
f0106bad:	6b d0 74             	imul   $0x74,%eax,%edx
f0106bb0:	88 82 20 c0 22 f0    	mov    %al,-0xfdd3fe0(%edx)
				ncpu++;
f0106bb6:	83 c0 01             	add    $0x1,%eax
f0106bb9:	a3 c4 c3 22 f0       	mov    %eax,0xf022c3c4
f0106bbe:	eb 14                	jmp    f0106bd4 <mp_init+0x210>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106bc0:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0106bc4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106bc8:	c7 04 24 ec 8f 10 f0 	movl   $0xf0108fec,(%esp)
f0106bcf:	e8 ca da ff ff       	call   f010469e <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106bd4:	83 c6 14             	add    $0x14,%esi
			continue;
f0106bd7:	eb 26                	jmp    f0106bff <mp_init+0x23b>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106bd9:	83 c6 08             	add    $0x8,%esi
			continue;
f0106bdc:	eb 21                	jmp    f0106bff <mp_init+0x23b>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106bde:	0f b6 c0             	movzbl %al,%eax
f0106be1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106be5:	c7 04 24 14 90 10 f0 	movl   $0xf0109014,(%esp)
f0106bec:	e8 ad da ff ff       	call   f010469e <cprintf>
			ismp = 0;
f0106bf1:	c7 05 00 c0 22 f0 00 	movl   $0x0,0xf022c000
f0106bf8:	00 00 00 
			i = conf->entry;
f0106bfb:	0f b7 5f 22          	movzwl 0x22(%edi),%ebx
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106bff:	83 c3 01             	add    $0x1,%ebx
f0106c02:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f0106c06:	39 d8                	cmp    %ebx,%eax
f0106c08:	0f 87 6e ff ff ff    	ja     f0106b7c <mp_init+0x1b8>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106c0e:	a1 c0 c3 22 f0       	mov    0xf022c3c0,%eax
f0106c13:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106c1a:	83 3d 00 c0 22 f0 00 	cmpl   $0x0,0xf022c000
f0106c21:	75 22                	jne    f0106c45 <mp_init+0x281>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106c23:	c7 05 c4 c3 22 f0 01 	movl   $0x1,0xf022c3c4
f0106c2a:	00 00 00 
		lapicaddr = 0;
f0106c2d:	c7 05 00 d0 26 f0 00 	movl   $0x0,0xf026d000
f0106c34:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106c37:	c7 04 24 34 90 10 f0 	movl   $0xf0109034,(%esp)
f0106c3e:	e8 5b da ff ff       	call   f010469e <cprintf>
f0106c43:	eb 44                	jmp    f0106c89 <mp_init+0x2c5>
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106c45:	8b 15 c4 c3 22 f0    	mov    0xf022c3c4,%edx
f0106c4b:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106c4f:	0f b6 00             	movzbl (%eax),%eax
f0106c52:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106c56:	c7 04 24 bb 90 10 f0 	movl   $0xf01090bb,(%esp)
f0106c5d:	e8 3c da ff ff       	call   f010469e <cprintf>

	if (mp->imcrp) {
f0106c62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106c65:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106c69:	74 1e                	je     f0106c89 <mp_init+0x2c5>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106c6b:	c7 04 24 60 90 10 f0 	movl   $0xf0109060,(%esp)
f0106c72:	e8 27 da ff ff       	call   f010469e <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106c77:	ba 22 00 00 00       	mov    $0x22,%edx
f0106c7c:	b8 70 00 00 00       	mov    $0x70,%eax
f0106c81:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106c82:	b2 23                	mov    $0x23,%dl
f0106c84:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0106c85:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106c88:	ee                   	out    %al,(%dx)
	}
}
f0106c89:	83 c4 2c             	add    $0x2c,%esp
f0106c8c:	5b                   	pop    %ebx
f0106c8d:	5e                   	pop    %esi
f0106c8e:	5f                   	pop    %edi
f0106c8f:	5d                   	pop    %ebp
f0106c90:	c3                   	ret    
f0106c91:	66 90                	xchg   %ax,%ax
f0106c93:	90                   	nop

f0106c94 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106c94:	55                   	push   %ebp
f0106c95:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106c97:	8b 0d 04 d0 26 f0    	mov    0xf026d004,%ecx
f0106c9d:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0106ca0:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106ca2:	a1 04 d0 26 f0       	mov    0xf026d004,%eax
f0106ca7:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106caa:	5d                   	pop    %ebp
f0106cab:	c3                   	ret    

f0106cac <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106cac:	55                   	push   %ebp
f0106cad:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106caf:	a1 04 d0 26 f0       	mov    0xf026d004,%eax
f0106cb4:	85 c0                	test   %eax,%eax
f0106cb6:	74 08                	je     f0106cc0 <cpunum+0x14>
		return lapic[ID] >> 24;
f0106cb8:	8b 40 20             	mov    0x20(%eax),%eax
f0106cbb:	c1 e8 18             	shr    $0x18,%eax
f0106cbe:	eb 05                	jmp    f0106cc5 <cpunum+0x19>
	return 0;
f0106cc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106cc5:	5d                   	pop    %ebp
f0106cc6:	c3                   	ret    

f0106cc7 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0106cc7:	a1 00 d0 26 f0       	mov    0xf026d000,%eax
f0106ccc:	85 c0                	test   %eax,%eax
f0106cce:	0f 84 23 01 00 00    	je     f0106df7 <lapic_init+0x130>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0106cd4:	55                   	push   %ebp
f0106cd5:	89 e5                	mov    %esp,%ebp
f0106cd7:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0106cda:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0106ce1:	00 
f0106ce2:	89 04 24             	mov    %eax,(%esp)
f0106ce5:	e8 60 ad ff ff       	call   f0101a4a <mmio_map_region>
f0106cea:	a3 04 d0 26 f0       	mov    %eax,0xf026d004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106cef:	ba 27 01 00 00       	mov    $0x127,%edx
f0106cf4:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106cf9:	e8 96 ff ff ff       	call   f0106c94 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0106cfe:	ba 0b 00 00 00       	mov    $0xb,%edx
f0106d03:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106d08:	e8 87 ff ff ff       	call   f0106c94 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106d0d:	ba 20 00 02 00       	mov    $0x20020,%edx
f0106d12:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106d17:	e8 78 ff ff ff       	call   f0106c94 <lapicw>
	lapicw(TICR, 10000000); 
f0106d1c:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106d21:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106d26:	e8 69 ff ff ff       	call   f0106c94 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0106d2b:	e8 7c ff ff ff       	call   f0106cac <cpunum>
f0106d30:	6b c0 74             	imul   $0x74,%eax,%eax
f0106d33:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f0106d38:	39 05 c0 c3 22 f0    	cmp    %eax,0xf022c3c0
f0106d3e:	74 0f                	je     f0106d4f <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f0106d40:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106d45:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106d4a:	e8 45 ff ff ff       	call   f0106c94 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0106d4f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106d54:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106d59:	e8 36 ff ff ff       	call   f0106c94 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106d5e:	a1 04 d0 26 f0       	mov    0xf026d004,%eax
f0106d63:	8b 40 30             	mov    0x30(%eax),%eax
f0106d66:	c1 e8 10             	shr    $0x10,%eax
f0106d69:	3c 03                	cmp    $0x3,%al
f0106d6b:	76 0f                	jbe    f0106d7c <lapic_init+0xb5>
		lapicw(PCINT, MASKED);
f0106d6d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106d72:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106d77:	e8 18 ff ff ff       	call   f0106c94 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106d7c:	ba 33 00 00 00       	mov    $0x33,%edx
f0106d81:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106d86:	e8 09 ff ff ff       	call   f0106c94 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0106d8b:	ba 00 00 00 00       	mov    $0x0,%edx
f0106d90:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106d95:	e8 fa fe ff ff       	call   f0106c94 <lapicw>
	lapicw(ESR, 0);
f0106d9a:	ba 00 00 00 00       	mov    $0x0,%edx
f0106d9f:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106da4:	e8 eb fe ff ff       	call   f0106c94 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0106da9:	ba 00 00 00 00       	mov    $0x0,%edx
f0106dae:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106db3:	e8 dc fe ff ff       	call   f0106c94 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0106db8:	ba 00 00 00 00       	mov    $0x0,%edx
f0106dbd:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106dc2:	e8 cd fe ff ff       	call   f0106c94 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106dc7:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106dcc:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106dd1:	e8 be fe ff ff       	call   f0106c94 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106dd6:	8b 15 04 d0 26 f0    	mov    0xf026d004,%edx
f0106ddc:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106de2:	f6 c4 10             	test   $0x10,%ah
f0106de5:	75 f5                	jne    f0106ddc <lapic_init+0x115>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0106de7:	ba 00 00 00 00       	mov    $0x0,%edx
f0106dec:	b8 20 00 00 00       	mov    $0x20,%eax
f0106df1:	e8 9e fe ff ff       	call   f0106c94 <lapicw>
}
f0106df6:	c9                   	leave  
f0106df7:	f3 c3                	repz ret 

f0106df9 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0106df9:	83 3d 04 d0 26 f0 00 	cmpl   $0x0,0xf026d004
f0106e00:	74 13                	je     f0106e15 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0106e02:	55                   	push   %ebp
f0106e03:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0106e05:	ba 00 00 00 00       	mov    $0x0,%edx
f0106e0a:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106e0f:	e8 80 fe ff ff       	call   f0106c94 <lapicw>
}
f0106e14:	5d                   	pop    %ebp
f0106e15:	f3 c3                	repz ret 

f0106e17 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106e17:	55                   	push   %ebp
f0106e18:	89 e5                	mov    %esp,%ebp
f0106e1a:	56                   	push   %esi
f0106e1b:	53                   	push   %ebx
f0106e1c:	83 ec 10             	sub    $0x10,%esp
f0106e1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0106e22:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106e25:	ba 70 00 00 00       	mov    $0x70,%edx
f0106e2a:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106e2f:	ee                   	out    %al,(%dx)
f0106e30:	b2 71                	mov    $0x71,%dl
f0106e32:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106e37:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106e38:	83 3d 88 be 22 f0 00 	cmpl   $0x0,0xf022be88
f0106e3f:	75 24                	jne    f0106e65 <lapic_startap+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106e41:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0106e48:	00 
f0106e49:	c7 44 24 08 68 74 10 	movl   $0xf0107468,0x8(%esp)
f0106e50:	f0 
f0106e51:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0106e58:	00 
f0106e59:	c7 04 24 d8 90 10 f0 	movl   $0xf01090d8,(%esp)
f0106e60:	e8 db 91 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106e65:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106e6c:	00 00 
	wrv[1] = addr >> 4;
f0106e6e:	89 f0                	mov    %esi,%eax
f0106e70:	c1 e8 04             	shr    $0x4,%eax
f0106e73:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106e79:	c1 e3 18             	shl    $0x18,%ebx
f0106e7c:	89 da                	mov    %ebx,%edx
f0106e7e:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106e83:	e8 0c fe ff ff       	call   f0106c94 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106e88:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106e8d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106e92:	e8 fd fd ff ff       	call   f0106c94 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106e97:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106e9c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106ea1:	e8 ee fd ff ff       	call   f0106c94 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106ea6:	c1 ee 0c             	shr    $0xc,%esi
f0106ea9:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106eaf:	89 da                	mov    %ebx,%edx
f0106eb1:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106eb6:	e8 d9 fd ff ff       	call   f0106c94 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106ebb:	89 f2                	mov    %esi,%edx
f0106ebd:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106ec2:	e8 cd fd ff ff       	call   f0106c94 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106ec7:	89 da                	mov    %ebx,%edx
f0106ec9:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106ece:	e8 c1 fd ff ff       	call   f0106c94 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106ed3:	89 f2                	mov    %esi,%edx
f0106ed5:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106eda:	e8 b5 fd ff ff       	call   f0106c94 <lapicw>
		microdelay(200);
	}
}
f0106edf:	83 c4 10             	add    $0x10,%esp
f0106ee2:	5b                   	pop    %ebx
f0106ee3:	5e                   	pop    %esi
f0106ee4:	5d                   	pop    %ebp
f0106ee5:	c3                   	ret    

f0106ee6 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106ee6:	55                   	push   %ebp
f0106ee7:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106ee9:	8b 55 08             	mov    0x8(%ebp),%edx
f0106eec:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106ef2:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106ef7:	e8 98 fd ff ff       	call   f0106c94 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106efc:	8b 15 04 d0 26 f0    	mov    0xf026d004,%edx
f0106f02:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106f08:	f6 c4 10             	test   $0x10,%ah
f0106f0b:	75 f5                	jne    f0106f02 <lapic_ipi+0x1c>
		;
}
f0106f0d:	5d                   	pop    %ebp
f0106f0e:	c3                   	ret    
f0106f0f:	90                   	nop

f0106f10 <holding>:

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106f10:	83 38 00             	cmpl   $0x0,(%eax)
f0106f13:	74 21                	je     f0106f36 <holding+0x26>
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f0106f15:	55                   	push   %ebp
f0106f16:	89 e5                	mov    %esp,%ebp
f0106f18:	53                   	push   %ebx
f0106f19:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f0106f1c:	8b 58 08             	mov    0x8(%eax),%ebx
f0106f1f:	e8 88 fd ff ff       	call   f0106cac <cpunum>
f0106f24:	6b c0 74             	imul   $0x74,%eax,%eax
f0106f27:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f0106f2c:	39 c3                	cmp    %eax,%ebx
f0106f2e:	0f 94 c0             	sete   %al
f0106f31:	0f b6 c0             	movzbl %al,%eax
f0106f34:	eb 06                	jmp    f0106f3c <holding+0x2c>
f0106f36:	b8 00 00 00 00       	mov    $0x0,%eax
f0106f3b:	c3                   	ret    
}
f0106f3c:	83 c4 04             	add    $0x4,%esp
f0106f3f:	5b                   	pop    %ebx
f0106f40:	5d                   	pop    %ebp
f0106f41:	c3                   	ret    

f0106f42 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106f42:	55                   	push   %ebp
f0106f43:	89 e5                	mov    %esp,%ebp
f0106f45:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106f48:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106f4e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106f51:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106f54:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106f5b:	5d                   	pop    %ebp
f0106f5c:	c3                   	ret    

f0106f5d <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106f5d:	55                   	push   %ebp
f0106f5e:	89 e5                	mov    %esp,%ebp
f0106f60:	53                   	push   %ebx
f0106f61:	83 ec 24             	sub    $0x24,%esp
f0106f64:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106f67:	89 d8                	mov    %ebx,%eax
f0106f69:	e8 a2 ff ff ff       	call   f0106f10 <holding>
f0106f6e:	85 c0                	test   %eax,%eax
f0106f70:	75 12                	jne    f0106f84 <spin_lock+0x27>
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106f72:	89 da                	mov    %ebx,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106f74:	b0 01                	mov    $0x1,%al
f0106f76:	f0 87 03             	lock xchg %eax,(%ebx)
f0106f79:	b9 01 00 00 00       	mov    $0x1,%ecx
f0106f7e:	85 c0                	test   %eax,%eax
f0106f80:	75 2e                	jne    f0106fb0 <spin_lock+0x53>
f0106f82:	eb 37                	jmp    f0106fbb <spin_lock+0x5e>
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106f84:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106f87:	e8 20 fd ff ff       	call   f0106cac <cpunum>
f0106f8c:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106f90:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106f94:	c7 44 24 08 e8 90 10 	movl   $0xf01090e8,0x8(%esp)
f0106f9b:	f0 
f0106f9c:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106fa3:	00 
f0106fa4:	c7 04 24 4c 91 10 f0 	movl   $0xf010914c,(%esp)
f0106fab:	e8 90 90 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106fb0:	f3 90                	pause  
f0106fb2:	89 c8                	mov    %ecx,%eax
f0106fb4:	f0 87 02             	lock xchg %eax,(%edx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106fb7:	85 c0                	test   %eax,%eax
f0106fb9:	75 f5                	jne    f0106fb0 <spin_lock+0x53>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106fbb:	e8 ec fc ff ff       	call   f0106cac <cpunum>
f0106fc0:	6b c0 74             	imul   $0x74,%eax,%eax
f0106fc3:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f0106fc8:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106fcb:	8d 4b 0c             	lea    0xc(%ebx),%ecx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0106fce:	89 e8                	mov    %ebp,%eax
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106fd0:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0106fd5:	77 34                	ja     f010700b <spin_lock+0xae>
f0106fd7:	eb 2b                	jmp    f0107004 <spin_lock+0xa7>
f0106fd9:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106fdf:	76 12                	jbe    f0106ff3 <spin_lock+0x96>
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106fe1:	8b 5a 04             	mov    0x4(%edx),%ebx
f0106fe4:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106fe7:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106fe9:	83 c0 01             	add    $0x1,%eax
f0106fec:	83 f8 0a             	cmp    $0xa,%eax
f0106fef:	75 e8                	jne    f0106fd9 <spin_lock+0x7c>
f0106ff1:	eb 27                	jmp    f010701a <spin_lock+0xbd>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106ff3:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106ffa:	83 c0 01             	add    $0x1,%eax
f0106ffd:	83 f8 09             	cmp    $0x9,%eax
f0107000:	7e f1                	jle    f0106ff3 <spin_lock+0x96>
f0107002:	eb 16                	jmp    f010701a <spin_lock+0xbd>
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0107004:	b8 00 00 00 00       	mov    $0x0,%eax
f0107009:	eb e8                	jmp    f0106ff3 <spin_lock+0x96>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f010700b:	8b 50 04             	mov    0x4(%eax),%edx
f010700e:	89 53 0c             	mov    %edx,0xc(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0107011:	8b 10                	mov    (%eax),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0107013:	b8 01 00 00 00       	mov    $0x1,%eax
f0107018:	eb bf                	jmp    f0106fd9 <spin_lock+0x7c>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f010701a:	83 c4 24             	add    $0x24,%esp
f010701d:	5b                   	pop    %ebx
f010701e:	5d                   	pop    %ebp
f010701f:	c3                   	ret    

f0107020 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0107020:	55                   	push   %ebp
f0107021:	89 e5                	mov    %esp,%ebp
f0107023:	83 ec 78             	sub    $0x78,%esp
f0107026:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0107029:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010702c:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010702f:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0107032:	89 d8                	mov    %ebx,%eax
f0107034:	e8 d7 fe ff ff       	call   f0106f10 <holding>
f0107039:	85 c0                	test   %eax,%eax
f010703b:	0f 85 d4 00 00 00    	jne    f0107115 <spin_unlock+0xf5>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0107041:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0107048:	00 
f0107049:	8d 43 0c             	lea    0xc(%ebx),%eax
f010704c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107050:	8d 45 c0             	lea    -0x40(%ebp),%eax
f0107053:	89 04 24             	mov    %eax,(%esp)
f0107056:	e8 08 f6 ff ff       	call   f0106663 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f010705b:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f010705e:	0f b6 30             	movzbl (%eax),%esi
f0107061:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0107064:	e8 43 fc ff ff       	call   f0106cac <cpunum>
f0107069:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010706d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0107071:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107075:	c7 04 24 14 91 10 f0 	movl   $0xf0109114,(%esp)
f010707c:	e8 1d d6 ff ff       	call   f010469e <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0107081:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0107084:	85 c0                	test   %eax,%eax
f0107086:	74 71                	je     f01070f9 <spin_unlock+0xd9>
f0107088:	8d 5d c0             	lea    -0x40(%ebp),%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f010708b:	8d 7d e4             	lea    -0x1c(%ebp),%edi
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010708e:	8d 75 a8             	lea    -0x58(%ebp),%esi
f0107091:	89 74 24 04          	mov    %esi,0x4(%esp)
f0107095:	89 04 24             	mov    %eax,(%esp)
f0107098:	e8 e5 e9 ff ff       	call   f0105a82 <debuginfo_eip>
f010709d:	85 c0                	test   %eax,%eax
f010709f:	78 39                	js     f01070da <spin_unlock+0xba>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f01070a1:	8b 03                	mov    (%ebx),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01070a3:	89 c2                	mov    %eax,%edx
f01070a5:	2b 55 b8             	sub    -0x48(%ebp),%edx
f01070a8:	89 54 24 18          	mov    %edx,0x18(%esp)
f01070ac:	8b 55 b0             	mov    -0x50(%ebp),%edx
f01070af:	89 54 24 14          	mov    %edx,0x14(%esp)
f01070b3:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f01070b6:	89 54 24 10          	mov    %edx,0x10(%esp)
f01070ba:	8b 55 ac             	mov    -0x54(%ebp),%edx
f01070bd:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01070c1:	8b 55 a8             	mov    -0x58(%ebp),%edx
f01070c4:	89 54 24 08          	mov    %edx,0x8(%esp)
f01070c8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01070cc:	c7 04 24 5c 91 10 f0 	movl   $0xf010915c,(%esp)
f01070d3:	e8 c6 d5 ff ff       	call   f010469e <cprintf>
f01070d8:	eb 12                	jmp    f01070ec <spin_unlock+0xcc>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f01070da:	8b 03                	mov    (%ebx),%eax
f01070dc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01070e0:	c7 04 24 73 91 10 f0 	movl   $0xf0109173,(%esp)
f01070e7:	e8 b2 d5 ff ff       	call   f010469e <cprintf>
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01070ec:	39 fb                	cmp    %edi,%ebx
f01070ee:	74 09                	je     f01070f9 <spin_unlock+0xd9>
f01070f0:	83 c3 04             	add    $0x4,%ebx
f01070f3:	8b 03                	mov    (%ebx),%eax
f01070f5:	85 c0                	test   %eax,%eax
f01070f7:	75 98                	jne    f0107091 <spin_unlock+0x71>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f01070f9:	c7 44 24 08 7b 91 10 	movl   $0xf010917b,0x8(%esp)
f0107100:	f0 
f0107101:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f0107108:	00 
f0107109:	c7 04 24 4c 91 10 f0 	movl   $0xf010914c,(%esp)
f0107110:	e8 2b 8f ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0107115:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f010711c:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0107123:	b8 00 00 00 00       	mov    $0x0,%eax
f0107128:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f010712b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010712e:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0107131:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0107134:	89 ec                	mov    %ebp,%esp
f0107136:	5d                   	pop    %ebp
f0107137:	c3                   	ret    
f0107138:	66 90                	xchg   %ax,%ax
f010713a:	66 90                	xchg   %ax,%ax
f010713c:	66 90                	xchg   %ax,%ax
f010713e:	66 90                	xchg   %ax,%ax

f0107140 <__udivdi3>:
f0107140:	83 ec 1c             	sub    $0x1c,%esp
f0107143:	8b 44 24 2c          	mov    0x2c(%esp),%eax
f0107147:	89 7c 24 14          	mov    %edi,0x14(%esp)
f010714b:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f010714f:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0107153:	8b 7c 24 20          	mov    0x20(%esp),%edi
f0107157:	8b 6c 24 24          	mov    0x24(%esp),%ebp
f010715b:	85 c0                	test   %eax,%eax
f010715d:	89 74 24 10          	mov    %esi,0x10(%esp)
f0107161:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0107165:	89 ea                	mov    %ebp,%edx
f0107167:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010716b:	75 33                	jne    f01071a0 <__udivdi3+0x60>
f010716d:	39 e9                	cmp    %ebp,%ecx
f010716f:	77 6f                	ja     f01071e0 <__udivdi3+0xa0>
f0107171:	85 c9                	test   %ecx,%ecx
f0107173:	89 ce                	mov    %ecx,%esi
f0107175:	75 0b                	jne    f0107182 <__udivdi3+0x42>
f0107177:	b8 01 00 00 00       	mov    $0x1,%eax
f010717c:	31 d2                	xor    %edx,%edx
f010717e:	f7 f1                	div    %ecx
f0107180:	89 c6                	mov    %eax,%esi
f0107182:	31 d2                	xor    %edx,%edx
f0107184:	89 e8                	mov    %ebp,%eax
f0107186:	f7 f6                	div    %esi
f0107188:	89 c5                	mov    %eax,%ebp
f010718a:	89 f8                	mov    %edi,%eax
f010718c:	f7 f6                	div    %esi
f010718e:	89 ea                	mov    %ebp,%edx
f0107190:	8b 74 24 10          	mov    0x10(%esp),%esi
f0107194:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0107198:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010719c:	83 c4 1c             	add    $0x1c,%esp
f010719f:	c3                   	ret    
f01071a0:	39 e8                	cmp    %ebp,%eax
f01071a2:	77 24                	ja     f01071c8 <__udivdi3+0x88>
f01071a4:	0f bd c8             	bsr    %eax,%ecx
f01071a7:	83 f1 1f             	xor    $0x1f,%ecx
f01071aa:	89 0c 24             	mov    %ecx,(%esp)
f01071ad:	75 49                	jne    f01071f8 <__udivdi3+0xb8>
f01071af:	8b 74 24 08          	mov    0x8(%esp),%esi
f01071b3:	39 74 24 04          	cmp    %esi,0x4(%esp)
f01071b7:	0f 86 ab 00 00 00    	jbe    f0107268 <__udivdi3+0x128>
f01071bd:	39 e8                	cmp    %ebp,%eax
f01071bf:	0f 82 a3 00 00 00    	jb     f0107268 <__udivdi3+0x128>
f01071c5:	8d 76 00             	lea    0x0(%esi),%esi
f01071c8:	31 d2                	xor    %edx,%edx
f01071ca:	31 c0                	xor    %eax,%eax
f01071cc:	8b 74 24 10          	mov    0x10(%esp),%esi
f01071d0:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01071d4:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01071d8:	83 c4 1c             	add    $0x1c,%esp
f01071db:	c3                   	ret    
f01071dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01071e0:	89 f8                	mov    %edi,%eax
f01071e2:	f7 f1                	div    %ecx
f01071e4:	31 d2                	xor    %edx,%edx
f01071e6:	8b 74 24 10          	mov    0x10(%esp),%esi
f01071ea:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01071ee:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01071f2:	83 c4 1c             	add    $0x1c,%esp
f01071f5:	c3                   	ret    
f01071f6:	66 90                	xchg   %ax,%ax
f01071f8:	0f b6 0c 24          	movzbl (%esp),%ecx
f01071fc:	89 c6                	mov    %eax,%esi
f01071fe:	b8 20 00 00 00       	mov    $0x20,%eax
f0107203:	8b 6c 24 04          	mov    0x4(%esp),%ebp
f0107207:	2b 04 24             	sub    (%esp),%eax
f010720a:	8b 7c 24 08          	mov    0x8(%esp),%edi
f010720e:	d3 e6                	shl    %cl,%esi
f0107210:	89 c1                	mov    %eax,%ecx
f0107212:	d3 ed                	shr    %cl,%ebp
f0107214:	0f b6 0c 24          	movzbl (%esp),%ecx
f0107218:	09 f5                	or     %esi,%ebp
f010721a:	8b 74 24 04          	mov    0x4(%esp),%esi
f010721e:	d3 e6                	shl    %cl,%esi
f0107220:	89 c1                	mov    %eax,%ecx
f0107222:	89 74 24 04          	mov    %esi,0x4(%esp)
f0107226:	89 d6                	mov    %edx,%esi
f0107228:	d3 ee                	shr    %cl,%esi
f010722a:	0f b6 0c 24          	movzbl (%esp),%ecx
f010722e:	d3 e2                	shl    %cl,%edx
f0107230:	89 c1                	mov    %eax,%ecx
f0107232:	d3 ef                	shr    %cl,%edi
f0107234:	09 d7                	or     %edx,%edi
f0107236:	89 f2                	mov    %esi,%edx
f0107238:	89 f8                	mov    %edi,%eax
f010723a:	f7 f5                	div    %ebp
f010723c:	89 d6                	mov    %edx,%esi
f010723e:	89 c7                	mov    %eax,%edi
f0107240:	f7 64 24 04          	mull   0x4(%esp)
f0107244:	39 d6                	cmp    %edx,%esi
f0107246:	72 30                	jb     f0107278 <__udivdi3+0x138>
f0107248:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f010724c:	0f b6 0c 24          	movzbl (%esp),%ecx
f0107250:	d3 e5                	shl    %cl,%ebp
f0107252:	39 c5                	cmp    %eax,%ebp
f0107254:	73 04                	jae    f010725a <__udivdi3+0x11a>
f0107256:	39 d6                	cmp    %edx,%esi
f0107258:	74 1e                	je     f0107278 <__udivdi3+0x138>
f010725a:	89 f8                	mov    %edi,%eax
f010725c:	31 d2                	xor    %edx,%edx
f010725e:	e9 69 ff ff ff       	jmp    f01071cc <__udivdi3+0x8c>
f0107263:	90                   	nop
f0107264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107268:	31 d2                	xor    %edx,%edx
f010726a:	b8 01 00 00 00       	mov    $0x1,%eax
f010726f:	e9 58 ff ff ff       	jmp    f01071cc <__udivdi3+0x8c>
f0107274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107278:	8d 47 ff             	lea    -0x1(%edi),%eax
f010727b:	31 d2                	xor    %edx,%edx
f010727d:	8b 74 24 10          	mov    0x10(%esp),%esi
f0107281:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0107285:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0107289:	83 c4 1c             	add    $0x1c,%esp
f010728c:	c3                   	ret    
f010728d:	66 90                	xchg   %ax,%ax
f010728f:	90                   	nop

f0107290 <__umoddi3>:
f0107290:	83 ec 2c             	sub    $0x2c,%esp
f0107293:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0107297:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010729b:	89 74 24 20          	mov    %esi,0x20(%esp)
f010729f:	8b 74 24 38          	mov    0x38(%esp),%esi
f01072a3:	89 7c 24 24          	mov    %edi,0x24(%esp)
f01072a7:	8b 7c 24 34          	mov    0x34(%esp),%edi
f01072ab:	85 c0                	test   %eax,%eax
f01072ad:	89 c2                	mov    %eax,%edx
f01072af:	89 6c 24 28          	mov    %ebp,0x28(%esp)
f01072b3:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
f01072b7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01072bb:	89 74 24 10          	mov    %esi,0x10(%esp)
f01072bf:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f01072c3:	89 7c 24 18          	mov    %edi,0x18(%esp)
f01072c7:	75 1f                	jne    f01072e8 <__umoddi3+0x58>
f01072c9:	39 fe                	cmp    %edi,%esi
f01072cb:	76 63                	jbe    f0107330 <__umoddi3+0xa0>
f01072cd:	89 c8                	mov    %ecx,%eax
f01072cf:	89 fa                	mov    %edi,%edx
f01072d1:	f7 f6                	div    %esi
f01072d3:	89 d0                	mov    %edx,%eax
f01072d5:	31 d2                	xor    %edx,%edx
f01072d7:	8b 74 24 20          	mov    0x20(%esp),%esi
f01072db:	8b 7c 24 24          	mov    0x24(%esp),%edi
f01072df:	8b 6c 24 28          	mov    0x28(%esp),%ebp
f01072e3:	83 c4 2c             	add    $0x2c,%esp
f01072e6:	c3                   	ret    
f01072e7:	90                   	nop
f01072e8:	39 f8                	cmp    %edi,%eax
f01072ea:	77 64                	ja     f0107350 <__umoddi3+0xc0>
f01072ec:	0f bd e8             	bsr    %eax,%ebp
f01072ef:	83 f5 1f             	xor    $0x1f,%ebp
f01072f2:	75 74                	jne    f0107368 <__umoddi3+0xd8>
f01072f4:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01072f8:	39 7c 24 10          	cmp    %edi,0x10(%esp)
f01072fc:	0f 87 0e 01 00 00    	ja     f0107410 <__umoddi3+0x180>
f0107302:	8b 7c 24 0c          	mov    0xc(%esp),%edi
f0107306:	29 f1                	sub    %esi,%ecx
f0107308:	19 c7                	sbb    %eax,%edi
f010730a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f010730e:	89 7c 24 18          	mov    %edi,0x18(%esp)
f0107312:	8b 44 24 14          	mov    0x14(%esp),%eax
f0107316:	8b 54 24 18          	mov    0x18(%esp),%edx
f010731a:	8b 74 24 20          	mov    0x20(%esp),%esi
f010731e:	8b 7c 24 24          	mov    0x24(%esp),%edi
f0107322:	8b 6c 24 28          	mov    0x28(%esp),%ebp
f0107326:	83 c4 2c             	add    $0x2c,%esp
f0107329:	c3                   	ret    
f010732a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0107330:	85 f6                	test   %esi,%esi
f0107332:	89 f5                	mov    %esi,%ebp
f0107334:	75 0b                	jne    f0107341 <__umoddi3+0xb1>
f0107336:	b8 01 00 00 00       	mov    $0x1,%eax
f010733b:	31 d2                	xor    %edx,%edx
f010733d:	f7 f6                	div    %esi
f010733f:	89 c5                	mov    %eax,%ebp
f0107341:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0107345:	31 d2                	xor    %edx,%edx
f0107347:	f7 f5                	div    %ebp
f0107349:	89 c8                	mov    %ecx,%eax
f010734b:	f7 f5                	div    %ebp
f010734d:	eb 84                	jmp    f01072d3 <__umoddi3+0x43>
f010734f:	90                   	nop
f0107350:	89 c8                	mov    %ecx,%eax
f0107352:	89 fa                	mov    %edi,%edx
f0107354:	8b 74 24 20          	mov    0x20(%esp),%esi
f0107358:	8b 7c 24 24          	mov    0x24(%esp),%edi
f010735c:	8b 6c 24 28          	mov    0x28(%esp),%ebp
f0107360:	83 c4 2c             	add    $0x2c,%esp
f0107363:	c3                   	ret    
f0107364:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107368:	8b 44 24 10          	mov    0x10(%esp),%eax
f010736c:	be 20 00 00 00       	mov    $0x20,%esi
f0107371:	89 e9                	mov    %ebp,%ecx
f0107373:	29 ee                	sub    %ebp,%esi
f0107375:	d3 e2                	shl    %cl,%edx
f0107377:	89 f1                	mov    %esi,%ecx
f0107379:	d3 e8                	shr    %cl,%eax
f010737b:	89 e9                	mov    %ebp,%ecx
f010737d:	09 d0                	or     %edx,%eax
f010737f:	89 fa                	mov    %edi,%edx
f0107381:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107385:	8b 44 24 10          	mov    0x10(%esp),%eax
f0107389:	d3 e0                	shl    %cl,%eax
f010738b:	89 f1                	mov    %esi,%ecx
f010738d:	89 44 24 10          	mov    %eax,0x10(%esp)
f0107391:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0107395:	d3 ea                	shr    %cl,%edx
f0107397:	89 e9                	mov    %ebp,%ecx
f0107399:	d3 e7                	shl    %cl,%edi
f010739b:	89 f1                	mov    %esi,%ecx
f010739d:	d3 e8                	shr    %cl,%eax
f010739f:	89 e9                	mov    %ebp,%ecx
f01073a1:	09 f8                	or     %edi,%eax
f01073a3:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f01073a7:	f7 74 24 0c          	divl   0xc(%esp)
f01073ab:	d3 e7                	shl    %cl,%edi
f01073ad:	89 7c 24 18          	mov    %edi,0x18(%esp)
f01073b1:	89 d7                	mov    %edx,%edi
f01073b3:	f7 64 24 10          	mull   0x10(%esp)
f01073b7:	39 d7                	cmp    %edx,%edi
f01073b9:	89 c1                	mov    %eax,%ecx
f01073bb:	89 54 24 14          	mov    %edx,0x14(%esp)
f01073bf:	72 3b                	jb     f01073fc <__umoddi3+0x16c>
f01073c1:	39 44 24 18          	cmp    %eax,0x18(%esp)
f01073c5:	72 31                	jb     f01073f8 <__umoddi3+0x168>
f01073c7:	8b 44 24 18          	mov    0x18(%esp),%eax
f01073cb:	29 c8                	sub    %ecx,%eax
f01073cd:	19 d7                	sbb    %edx,%edi
f01073cf:	89 e9                	mov    %ebp,%ecx
f01073d1:	89 fa                	mov    %edi,%edx
f01073d3:	d3 e8                	shr    %cl,%eax
f01073d5:	89 f1                	mov    %esi,%ecx
f01073d7:	d3 e2                	shl    %cl,%edx
f01073d9:	89 e9                	mov    %ebp,%ecx
f01073db:	09 d0                	or     %edx,%eax
f01073dd:	89 fa                	mov    %edi,%edx
f01073df:	d3 ea                	shr    %cl,%edx
f01073e1:	8b 74 24 20          	mov    0x20(%esp),%esi
f01073e5:	8b 7c 24 24          	mov    0x24(%esp),%edi
f01073e9:	8b 6c 24 28          	mov    0x28(%esp),%ebp
f01073ed:	83 c4 2c             	add    $0x2c,%esp
f01073f0:	c3                   	ret    
f01073f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01073f8:	39 d7                	cmp    %edx,%edi
f01073fa:	75 cb                	jne    f01073c7 <__umoddi3+0x137>
f01073fc:	8b 54 24 14          	mov    0x14(%esp),%edx
f0107400:	89 c1                	mov    %eax,%ecx
f0107402:	2b 4c 24 10          	sub    0x10(%esp),%ecx
f0107406:	1b 54 24 0c          	sbb    0xc(%esp),%edx
f010740a:	eb bb                	jmp    f01073c7 <__umoddi3+0x137>
f010740c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107410:	3b 44 24 18          	cmp    0x18(%esp),%eax
f0107414:	0f 82 e8 fe ff ff    	jb     f0107302 <__umoddi3+0x72>
f010741a:	e9 f3 fe ff ff       	jmp    f0107312 <__umoddi3+0x82>
