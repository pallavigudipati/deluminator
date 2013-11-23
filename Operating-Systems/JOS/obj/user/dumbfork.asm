
obj/user/dumbfork:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 2f 02 00 00       	call   800260 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 20             	sub    $0x20,%esp
  800048:	8b 75 08             	mov    0x8(%ebp),%esi
  80004b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80004e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800055:	00 
  800056:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80005a:	89 34 24             	mov    %esi,(%esp)
  80005d:	e8 0a 0f 00 00       	call   800f6c <sys_page_alloc>
  800062:	85 c0                	test   %eax,%eax
  800064:	79 20                	jns    800086 <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  800066:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80006a:	c7 44 24 08 c0 14 80 	movl   $0x8014c0,0x8(%esp)
  800071:	00 
  800072:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800079:	00 
  80007a:	c7 04 24 d3 14 80 00 	movl   $0x8014d3,(%esp)
  800081:	e8 4a 02 00 00       	call   8002d0 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800086:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80008d:	00 
  80008e:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800095:	00 
  800096:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80009d:	00 
  80009e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a2:	89 34 24             	mov    %esi,(%esp)
  8000a5:	e8 21 0f 00 00       	call   800fcb <sys_page_map>
  8000aa:	85 c0                	test   %eax,%eax
  8000ac:	79 20                	jns    8000ce <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b2:	c7 44 24 08 e3 14 80 	movl   $0x8014e3,0x8(%esp)
  8000b9:	00 
  8000ba:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000c1:	00 
  8000c2:	c7 04 24 d3 14 80 00 	movl   $0x8014d3,(%esp)
  8000c9:	e8 02 02 00 00       	call   8002d0 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000ce:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000d5:	00 
  8000d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000da:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000e1:	e8 6d 0b 00 00       	call   800c53 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000e6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000ed:	00 
  8000ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f5:	e8 2f 0f 00 00       	call   801029 <sys_page_unmap>
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 20                	jns    80011e <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800102:	c7 44 24 08 f4 14 80 	movl   $0x8014f4,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 d3 14 80 00 	movl   $0x8014d3,(%esp)
  800119:	e8 b2 01 00 00       	call   8002d0 <_panic>
}
  80011e:	83 c4 20             	add    $0x20,%esp
  800121:	5b                   	pop    %ebx
  800122:	5e                   	pop    %esi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <dumbfork>:

envid_t
dumbfork(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	83 ec 20             	sub    $0x20,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80012d:	be 07 00 00 00       	mov    $0x7,%esi
  800132:	89 f0                	mov    %esi,%eax
  800134:	cd 30                	int    $0x30
  800136:	89 c6                	mov    %eax,%esi
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  800138:	85 c0                	test   %eax,%eax
  80013a:	79 20                	jns    80015c <dumbfork+0x37>
		panic("sys_exofork: %e", envid);
  80013c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800140:	c7 44 24 08 07 15 80 	movl   $0x801507,0x8(%esp)
  800147:	00 
  800148:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  80014f:	00 
  800150:	c7 04 24 d3 14 80 00 	movl   $0x8014d3,(%esp)
  800157:	e8 74 01 00 00       	call   8002d0 <_panic>
	if (envid == 0) {
  80015c:	85 c0                	test   %eax,%eax
  80015e:	75 1c                	jne    80017c <dumbfork+0x57>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800160:	e8 a7 0d 00 00       	call   800f0c <sys_getenvid>
  800165:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800172:	a3 04 20 80 00       	mov    %eax,0x802004
  800177:	e9 82 00 00 00       	jmp    8001fe <dumbfork+0xd9>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80017c:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800183:	b8 08 20 80 00       	mov    $0x802008,%eax
  800188:	3d 00 00 80 00       	cmp    $0x800000,%eax
  80018d:	76 27                	jbe    8001b6 <dumbfork+0x91>
  80018f:	89 f3                	mov    %esi,%ebx
  800191:	ba 00 00 80 00       	mov    $0x800000,%edx
		duppage(envid, addr);
  800196:	89 54 24 04          	mov    %edx,0x4(%esp)
  80019a:	89 1c 24             	mov    %ebx,(%esp)
  80019d:	e8 9e fe ff ff       	call   800040 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  8001a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8001a5:	81 c2 00 10 00 00    	add    $0x1000,%edx
  8001ab:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8001ae:	81 fa 08 20 80 00    	cmp    $0x802008,%edx
  8001b4:	72 e0                	jb     800196 <dumbfork+0x71>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  8001b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001b9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8001be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c2:	89 34 24             	mov    %esi,(%esp)
  8001c5:	e8 76 fe ff ff       	call   800040 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001ca:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8001d1:	00 
  8001d2:	89 34 24             	mov    %esi,(%esp)
  8001d5:	e8 ad 0e 00 00       	call   801087 <sys_env_set_status>
  8001da:	85 c0                	test   %eax,%eax
  8001dc:	79 20                	jns    8001fe <dumbfork+0xd9>
		panic("sys_env_set_status: %e", r);
  8001de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e2:	c7 44 24 08 17 15 80 	movl   $0x801517,0x8(%esp)
  8001e9:	00 
  8001ea:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001f1:	00 
  8001f2:	c7 04 24 d3 14 80 00 	movl   $0x8014d3,(%esp)
  8001f9:	e8 d2 00 00 00       	call   8002d0 <_panic>

	return envid;
}
  8001fe:	89 f0                	mov    %esi,%eax
  800200:	83 c4 20             	add    $0x20,%esp
  800203:	5b                   	pop    %ebx
  800204:	5e                   	pop    %esi
  800205:	5d                   	pop    %ebp
  800206:	c3                   	ret    

00800207 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800207:	55                   	push   %ebp
  800208:	89 e5                	mov    %esp,%ebp
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	83 ec 10             	sub    $0x10,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  80020f:	e8 11 ff ff ff       	call   800125 <dumbfork>
  800214:	89 c6                	mov    %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800216:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021b:	eb 28                	jmp    800245 <umain+0x3e>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  80021d:	b8 35 15 80 00       	mov    $0x801535,%eax
  800222:	eb 05                	jmp    800229 <umain+0x22>
  800224:	b8 2e 15 80 00       	mov    $0x80152e,%eax
  800229:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800231:	c7 04 24 3b 15 80 00 	movl   $0x80153b,(%esp)
  800238:	e8 8e 01 00 00       	call   8003cb <cprintf>
		sys_yield();
  80023d:	e8 fa 0c 00 00       	call   800f3c <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800242:	83 c3 01             	add    $0x1,%ebx
  800245:	85 f6                	test   %esi,%esi
  800247:	75 09                	jne    800252 <umain+0x4b>
  800249:	83 fb 13             	cmp    $0x13,%ebx
  80024c:	7e cf                	jle    80021d <umain+0x16>
  80024e:	66 90                	xchg   %ax,%ax
  800250:	eb 05                	jmp    800257 <umain+0x50>
  800252:	83 fb 09             	cmp    $0x9,%ebx
  800255:	7e cd                	jle    800224 <umain+0x1d>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  800257:	83 c4 10             	add    $0x10,%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    
  80025e:	66 90                	xchg   %ax,%ax

00800260 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	83 ec 18             	sub    $0x18,%esp
  800266:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800269:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80026c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80026f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800272:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800279:	00 00 00 
	int envid;
	envid = sys_getenvid();
  80027c:	e8 8b 0c 00 00       	call   800f0c <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800281:	25 ff 03 00 00       	and    $0x3ff,%eax
  800286:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800289:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80028e:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800293:	85 db                	test   %ebx,%ebx
  800295:	7e 07                	jle    80029e <libmain+0x3e>
		binaryname = argv[0];
  800297:	8b 06                	mov    (%esi),%eax
  800299:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80029e:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002a2:	89 1c 24             	mov    %ebx,(%esp)
  8002a5:	e8 5d ff ff ff       	call   800207 <umain>

	// exit gracefully
	exit();
  8002aa:	e8 0d 00 00 00       	call   8002bc <exit>
}
  8002af:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8002b2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8002b5:	89 ec                	mov    %ebp,%esp
  8002b7:	5d                   	pop    %ebp
  8002b8:	c3                   	ret    
  8002b9:	66 90                	xchg   %ax,%ax
  8002bb:	90                   	nop

008002bc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8002c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002c9:	e8 e1 0b 00 00       	call   800eaf <sys_env_destroy>
}
  8002ce:	c9                   	leave  
  8002cf:	c3                   	ret    

008002d0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	56                   	push   %esi
  8002d4:	53                   	push   %ebx
  8002d5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002db:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8002e1:	e8 26 0c 00 00       	call   800f0c <sys_getenvid>
  8002e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002f4:	89 74 24 08          	mov    %esi,0x8(%esp)
  8002f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002fc:	c7 04 24 58 15 80 00 	movl   $0x801558,(%esp)
  800303:	e8 c3 00 00 00       	call   8003cb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800308:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80030c:	8b 45 10             	mov    0x10(%ebp),%eax
  80030f:	89 04 24             	mov    %eax,(%esp)
  800312:	e8 53 00 00 00       	call   80036a <vcprintf>
	cprintf("\n");
  800317:	c7 04 24 4b 15 80 00 	movl   $0x80154b,(%esp)
  80031e:	e8 a8 00 00 00       	call   8003cb <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800323:	cc                   	int3   
  800324:	eb fd                	jmp    800323 <_panic+0x53>
  800326:	66 90                	xchg   %ax,%ax

00800328 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	53                   	push   %ebx
  80032c:	83 ec 14             	sub    $0x14,%esp
  80032f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800332:	8b 03                	mov    (%ebx),%eax
  800334:	8b 55 08             	mov    0x8(%ebp),%edx
  800337:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80033b:	83 c0 01             	add    $0x1,%eax
  80033e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800340:	3d ff 00 00 00       	cmp    $0xff,%eax
  800345:	75 19                	jne    800360 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800347:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80034e:	00 
  80034f:	8d 43 08             	lea    0x8(%ebx),%eax
  800352:	89 04 24             	mov    %eax,(%esp)
  800355:	e8 f6 0a 00 00       	call   800e50 <sys_cputs>
		b->idx = 0;
  80035a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800360:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800364:	83 c4 14             	add    $0x14,%esp
  800367:	5b                   	pop    %ebx
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800373:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80037a:	00 00 00 
	b.cnt = 0;
  80037d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800384:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800387:	8b 45 0c             	mov    0xc(%ebp),%eax
  80038a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80038e:	8b 45 08             	mov    0x8(%ebp),%eax
  800391:	89 44 24 08          	mov    %eax,0x8(%esp)
  800395:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80039b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039f:	c7 04 24 28 03 80 00 	movl   $0x800328,(%esp)
  8003a6:	e8 b7 01 00 00       	call   800562 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ab:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8003b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003bb:	89 04 24             	mov    %eax,(%esp)
  8003be:	e8 8d 0a 00 00       	call   800e50 <sys_cputs>

	return b.cnt;
}
  8003c3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003c9:	c9                   	leave  
  8003ca:	c3                   	ret    

008003cb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003d1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003db:	89 04 24             	mov    %eax,(%esp)
  8003de:	e8 87 ff ff ff       	call   80036a <vcprintf>
	va_end(ap);

	return cnt;
}
  8003e3:	c9                   	leave  
  8003e4:	c3                   	ret    
  8003e5:	66 90                	xchg   %ax,%ax
  8003e7:	66 90                	xchg   %ax,%ax
  8003e9:	66 90                	xchg   %ax,%ax
  8003eb:	66 90                	xchg   %ax,%ax
  8003ed:	66 90                	xchg   %ax,%ax
  8003ef:	90                   	nop

008003f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	57                   	push   %edi
  8003f4:	56                   	push   %esi
  8003f5:	53                   	push   %ebx
  8003f6:	83 ec 4c             	sub    $0x4c,%esp
  8003f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003fc:	89 d7                	mov    %edx,%edi
  8003fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800401:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800404:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800407:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80040a:	b8 00 00 00 00       	mov    $0x0,%eax
  80040f:	39 d8                	cmp    %ebx,%eax
  800411:	72 17                	jb     80042a <printnum+0x3a>
  800413:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800416:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  800419:	76 0f                	jbe    80042a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80041b:	8b 75 14             	mov    0x14(%ebp),%esi
  80041e:	83 ee 01             	sub    $0x1,%esi
  800421:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800424:	85 f6                	test   %esi,%esi
  800426:	7f 63                	jg     80048b <printnum+0x9b>
  800428:	eb 75                	jmp    80049f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042a:	8b 5d 18             	mov    0x18(%ebp),%ebx
  80042d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800431:	8b 45 14             	mov    0x14(%ebp),%eax
  800434:	83 e8 01             	sub    $0x1,%eax
  800437:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80043b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80043e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800442:	8b 44 24 08          	mov    0x8(%esp),%eax
  800446:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80044a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800450:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800457:	00 
  800458:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80045b:	89 1c 24             	mov    %ebx,(%esp)
  80045e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800461:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800465:	e8 76 0d 00 00       	call   8011e0 <__udivdi3>
  80046a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80046d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800470:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800474:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800478:	89 04 24             	mov    %eax,(%esp)
  80047b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80047f:	89 fa                	mov    %edi,%edx
  800481:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800484:	e8 67 ff ff ff       	call   8003f0 <printnum>
  800489:	eb 14                	jmp    80049f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80048b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80048f:	8b 45 18             	mov    0x18(%ebp),%eax
  800492:	89 04 24             	mov    %eax,(%esp)
  800495:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800497:	83 ee 01             	sub    $0x1,%esi
  80049a:	75 ef                	jne    80048b <printnum+0x9b>
  80049c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80049f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004a3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004aa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004ae:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004b5:	00 
  8004b6:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8004b9:	89 1c 24             	mov    %ebx,(%esp)
  8004bc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8004bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c3:	e8 68 0e 00 00       	call   801330 <__umoddi3>
  8004c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004cc:	0f be 80 7c 15 80 00 	movsbl 0x80157c(%eax),%eax
  8004d3:	89 04 24             	mov    %eax,(%esp)
  8004d6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004d9:	ff d0                	call   *%eax
}
  8004db:	83 c4 4c             	add    $0x4c,%esp
  8004de:	5b                   	pop    %ebx
  8004df:	5e                   	pop    %esi
  8004e0:	5f                   	pop    %edi
  8004e1:	5d                   	pop    %ebp
  8004e2:	c3                   	ret    

008004e3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004e3:	55                   	push   %ebp
  8004e4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004e6:	83 fa 01             	cmp    $0x1,%edx
  8004e9:	7e 0e                	jle    8004f9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004eb:	8b 10                	mov    (%eax),%edx
  8004ed:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004f0:	89 08                	mov    %ecx,(%eax)
  8004f2:	8b 02                	mov    (%edx),%eax
  8004f4:	8b 52 04             	mov    0x4(%edx),%edx
  8004f7:	eb 22                	jmp    80051b <getuint+0x38>
	else if (lflag)
  8004f9:	85 d2                	test   %edx,%edx
  8004fb:	74 10                	je     80050d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004fd:	8b 10                	mov    (%eax),%edx
  8004ff:	8d 4a 04             	lea    0x4(%edx),%ecx
  800502:	89 08                	mov    %ecx,(%eax)
  800504:	8b 02                	mov    (%edx),%eax
  800506:	ba 00 00 00 00       	mov    $0x0,%edx
  80050b:	eb 0e                	jmp    80051b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80050d:	8b 10                	mov    (%eax),%edx
  80050f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800512:	89 08                	mov    %ecx,(%eax)
  800514:	8b 02                	mov    (%edx),%eax
  800516:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80051b:	5d                   	pop    %ebp
  80051c:	c3                   	ret    

0080051d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80051d:	55                   	push   %ebp
  80051e:	89 e5                	mov    %esp,%ebp
  800520:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800523:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800527:	8b 10                	mov    (%eax),%edx
  800529:	3b 50 04             	cmp    0x4(%eax),%edx
  80052c:	73 0a                	jae    800538 <sprintputch+0x1b>
		*b->buf++ = ch;
  80052e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800531:	88 0a                	mov    %cl,(%edx)
  800533:	83 c2 01             	add    $0x1,%edx
  800536:	89 10                	mov    %edx,(%eax)
}
  800538:	5d                   	pop    %ebp
  800539:	c3                   	ret    

0080053a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80053a:	55                   	push   %ebp
  80053b:	89 e5                	mov    %esp,%ebp
  80053d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800540:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800543:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800547:	8b 45 10             	mov    0x10(%ebp),%eax
  80054a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80054e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800551:	89 44 24 04          	mov    %eax,0x4(%esp)
  800555:	8b 45 08             	mov    0x8(%ebp),%eax
  800558:	89 04 24             	mov    %eax,(%esp)
  80055b:	e8 02 00 00 00       	call   800562 <vprintfmt>
	va_end(ap);
}
  800560:	c9                   	leave  
  800561:	c3                   	ret    

00800562 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800562:	55                   	push   %ebp
  800563:	89 e5                	mov    %esp,%ebp
  800565:	57                   	push   %edi
  800566:	56                   	push   %esi
  800567:	53                   	push   %ebx
  800568:	83 ec 4c             	sub    $0x4c,%esp
  80056b:	8b 75 08             	mov    0x8(%ebp),%esi
  80056e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800571:	8b 7d 10             	mov    0x10(%ebp),%edi
  800574:	eb 11                	jmp    800587 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800576:	85 c0                	test   %eax,%eax
  800578:	0f 84 db 03 00 00    	je     800959 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  80057e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800582:	89 04 24             	mov    %eax,(%esp)
  800585:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800587:	0f b6 07             	movzbl (%edi),%eax
  80058a:	83 c7 01             	add    $0x1,%edi
  80058d:	83 f8 25             	cmp    $0x25,%eax
  800590:	75 e4                	jne    800576 <vprintfmt+0x14>
  800592:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800596:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80059d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8005a4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8005b0:	eb 2b                	jmp    8005dd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b2:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005b5:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  8005b9:	eb 22                	jmp    8005dd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bb:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005be:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  8005c2:	eb 19                	jmp    8005dd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8005c7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005ce:	eb 0d                	jmp    8005dd <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8005d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d6:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005dd:	0f b6 0f             	movzbl (%edi),%ecx
  8005e0:	8d 47 01             	lea    0x1(%edi),%eax
  8005e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e6:	0f b6 07             	movzbl (%edi),%eax
  8005e9:	83 e8 23             	sub    $0x23,%eax
  8005ec:	3c 55                	cmp    $0x55,%al
  8005ee:	0f 87 40 03 00 00    	ja     800934 <vprintfmt+0x3d2>
  8005f4:	0f b6 c0             	movzbl %al,%eax
  8005f7:	ff 24 85 40 16 80 00 	jmp    *0x801640(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005fe:	83 e9 30             	sub    $0x30,%ecx
  800601:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  800604:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  800608:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80060b:	83 f9 09             	cmp    $0x9,%ecx
  80060e:	77 57                	ja     800667 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800610:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800613:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800616:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800619:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80061c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80061f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800623:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800626:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800629:	83 f9 09             	cmp    $0x9,%ecx
  80062c:	76 eb                	jbe    800619 <vprintfmt+0xb7>
  80062e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800631:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800634:	eb 34                	jmp    80066a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8d 48 04             	lea    0x4(%eax),%ecx
  80063c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80063f:	8b 00                	mov    (%eax),%eax
  800641:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800644:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800647:	eb 21                	jmp    80066a <vprintfmt+0x108>

		case '.':
			if (width < 0)
  800649:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80064d:	0f 88 71 ff ff ff    	js     8005c4 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800653:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800656:	eb 85                	jmp    8005dd <vprintfmt+0x7b>
  800658:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80065b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800662:	e9 76 ff ff ff       	jmp    8005dd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800667:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80066a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80066e:	0f 89 69 ff ff ff    	jns    8005dd <vprintfmt+0x7b>
  800674:	e9 57 ff ff ff       	jmp    8005d0 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800679:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80067f:	e9 59 ff ff ff       	jmp    8005dd <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8d 50 04             	lea    0x4(%eax),%edx
  80068a:	89 55 14             	mov    %edx,0x14(%ebp)
  80068d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800691:	8b 00                	mov    (%eax),%eax
  800693:	89 04 24             	mov    %eax,(%esp)
  800696:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800698:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80069b:	e9 e7 fe ff ff       	jmp    800587 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8d 50 04             	lea    0x4(%eax),%edx
  8006a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a9:	8b 00                	mov    (%eax),%eax
  8006ab:	89 c2                	mov    %eax,%edx
  8006ad:	c1 fa 1f             	sar    $0x1f,%edx
  8006b0:	31 d0                	xor    %edx,%eax
  8006b2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006b4:	83 f8 08             	cmp    $0x8,%eax
  8006b7:	7f 0b                	jg     8006c4 <vprintfmt+0x162>
  8006b9:	8b 14 85 a0 17 80 00 	mov    0x8017a0(,%eax,4),%edx
  8006c0:	85 d2                	test   %edx,%edx
  8006c2:	75 20                	jne    8006e4 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  8006c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006c8:	c7 44 24 08 94 15 80 	movl   $0x801594,0x8(%esp)
  8006cf:	00 
  8006d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d4:	89 34 24             	mov    %esi,(%esp)
  8006d7:	e8 5e fe ff ff       	call   80053a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006dc:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006df:	e9 a3 fe ff ff       	jmp    800587 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8006e4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006e8:	c7 44 24 08 9d 15 80 	movl   $0x80159d,0x8(%esp)
  8006ef:	00 
  8006f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f4:	89 34 24             	mov    %esi,(%esp)
  8006f7:	e8 3e fe ff ff       	call   80053a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fc:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006ff:	e9 83 fe ff ff       	jmp    800587 <vprintfmt+0x25>
  800704:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800707:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80070a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80070d:	8b 45 14             	mov    0x14(%ebp),%eax
  800710:	8d 50 04             	lea    0x4(%eax),%edx
  800713:	89 55 14             	mov    %edx,0x14(%ebp)
  800716:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800718:	85 ff                	test   %edi,%edi
  80071a:	b8 8d 15 80 00       	mov    $0x80158d,%eax
  80071f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800722:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  800726:	74 06                	je     80072e <vprintfmt+0x1cc>
  800728:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80072c:	7f 16                	jg     800744 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80072e:	0f b6 17             	movzbl (%edi),%edx
  800731:	0f be c2             	movsbl %dl,%eax
  800734:	83 c7 01             	add    $0x1,%edi
  800737:	85 c0                	test   %eax,%eax
  800739:	0f 85 9f 00 00 00    	jne    8007de <vprintfmt+0x27c>
  80073f:	e9 8b 00 00 00       	jmp    8007cf <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800744:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800748:	89 3c 24             	mov    %edi,(%esp)
  80074b:	e8 c2 02 00 00       	call   800a12 <strnlen>
  800750:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800753:	29 c2                	sub    %eax,%edx
  800755:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800758:	85 d2                	test   %edx,%edx
  80075a:	7e d2                	jle    80072e <vprintfmt+0x1cc>
					putch(padc, putdat);
  80075c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  800760:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800763:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800766:	89 d7                	mov    %edx,%edi
  800768:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80076f:	89 04 24             	mov    %eax,(%esp)
  800772:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800774:	83 ef 01             	sub    $0x1,%edi
  800777:	75 ef                	jne    800768 <vprintfmt+0x206>
  800779:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80077c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80077f:	eb ad                	jmp    80072e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800781:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800785:	74 20                	je     8007a7 <vprintfmt+0x245>
  800787:	0f be d2             	movsbl %dl,%edx
  80078a:	83 ea 20             	sub    $0x20,%edx
  80078d:	83 fa 5e             	cmp    $0x5e,%edx
  800790:	76 15                	jbe    8007a7 <vprintfmt+0x245>
					putch('?', putdat);
  800792:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800795:	89 54 24 04          	mov    %edx,0x4(%esp)
  800799:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007a0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8007a3:	ff d1                	call   *%ecx
  8007a5:	eb 0f                	jmp    8007b6 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  8007a7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007ae:	89 04 24             	mov    %eax,(%esp)
  8007b1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8007b4:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007b6:	83 eb 01             	sub    $0x1,%ebx
  8007b9:	0f b6 17             	movzbl (%edi),%edx
  8007bc:	0f be c2             	movsbl %dl,%eax
  8007bf:	83 c7 01             	add    $0x1,%edi
  8007c2:	85 c0                	test   %eax,%eax
  8007c4:	75 24                	jne    8007ea <vprintfmt+0x288>
  8007c6:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8007c9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8007cc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007cf:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007d2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007d6:	0f 8e ab fd ff ff    	jle    800587 <vprintfmt+0x25>
  8007dc:	eb 20                	jmp    8007fe <vprintfmt+0x29c>
  8007de:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8007e1:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8007e4:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8007e7:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007ea:	85 f6                	test   %esi,%esi
  8007ec:	78 93                	js     800781 <vprintfmt+0x21f>
  8007ee:	83 ee 01             	sub    $0x1,%esi
  8007f1:	79 8e                	jns    800781 <vprintfmt+0x21f>
  8007f3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8007f6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8007f9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8007fc:	eb d1                	jmp    8007cf <vprintfmt+0x26d>
  8007fe:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800801:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800805:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80080c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80080e:	83 ef 01             	sub    $0x1,%edi
  800811:	75 ee                	jne    800801 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800813:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800816:	e9 6c fd ff ff       	jmp    800587 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80081b:	83 fa 01             	cmp    $0x1,%edx
  80081e:	66 90                	xchg   %ax,%ax
  800820:	7e 16                	jle    800838 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  800822:	8b 45 14             	mov    0x14(%ebp),%eax
  800825:	8d 50 08             	lea    0x8(%eax),%edx
  800828:	89 55 14             	mov    %edx,0x14(%ebp)
  80082b:	8b 10                	mov    (%eax),%edx
  80082d:	8b 48 04             	mov    0x4(%eax),%ecx
  800830:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800833:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800836:	eb 32                	jmp    80086a <vprintfmt+0x308>
	else if (lflag)
  800838:	85 d2                	test   %edx,%edx
  80083a:	74 18                	je     800854 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  80083c:	8b 45 14             	mov    0x14(%ebp),%eax
  80083f:	8d 50 04             	lea    0x4(%eax),%edx
  800842:	89 55 14             	mov    %edx,0x14(%ebp)
  800845:	8b 00                	mov    (%eax),%eax
  800847:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80084a:	89 c1                	mov    %eax,%ecx
  80084c:	c1 f9 1f             	sar    $0x1f,%ecx
  80084f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800852:	eb 16                	jmp    80086a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  800854:	8b 45 14             	mov    0x14(%ebp),%eax
  800857:	8d 50 04             	lea    0x4(%eax),%edx
  80085a:	89 55 14             	mov    %edx,0x14(%ebp)
  80085d:	8b 00                	mov    (%eax),%eax
  80085f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800862:	89 c7                	mov    %eax,%edi
  800864:	c1 ff 1f             	sar    $0x1f,%edi
  800867:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80086a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80086d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800870:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800875:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800879:	79 7d                	jns    8008f8 <vprintfmt+0x396>
				putch('-', putdat);
  80087b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80087f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800886:	ff d6                	call   *%esi
				num = -(long long) num;
  800888:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80088b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80088e:	f7 d8                	neg    %eax
  800890:	83 d2 00             	adc    $0x0,%edx
  800893:	f7 da                	neg    %edx
			}
			base = 10;
  800895:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80089a:	eb 5c                	jmp    8008f8 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80089c:	8d 45 14             	lea    0x14(%ebp),%eax
  80089f:	e8 3f fc ff ff       	call   8004e3 <getuint>
			base = 10;
  8008a4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8008a9:	eb 4d                	jmp    8008f8 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8008ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ae:	e8 30 fc ff ff       	call   8004e3 <getuint>
			base = 8;
  8008b3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8008b8:	eb 3e                	jmp    8008f8 <vprintfmt+0x396>

		// pointer
		case 'p':
			putch('0', putdat);
  8008ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008be:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008c5:	ff d6                	call   *%esi
			putch('x', putdat);
  8008c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008cb:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008d2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d7:	8d 50 04             	lea    0x4(%eax),%edx
  8008da:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008dd:	8b 00                	mov    (%eax),%eax
  8008df:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008e4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8008e9:	eb 0d                	jmp    8008f8 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ee:	e8 f0 fb ff ff       	call   8004e3 <getuint>
			base = 16;
  8008f3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008f8:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  8008fc:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800900:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800903:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800907:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80090b:	89 04 24             	mov    %eax,(%esp)
  80090e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800912:	89 da                	mov    %ebx,%edx
  800914:	89 f0                	mov    %esi,%eax
  800916:	e8 d5 fa ff ff       	call   8003f0 <printnum>
			break;
  80091b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80091e:	e9 64 fc ff ff       	jmp    800587 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800923:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800927:	89 0c 24             	mov    %ecx,(%esp)
  80092a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80092c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80092f:	e9 53 fc ff ff       	jmp    800587 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800934:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800938:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80093f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800941:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800945:	0f 84 3c fc ff ff    	je     800587 <vprintfmt+0x25>
  80094b:	83 ef 01             	sub    $0x1,%edi
  80094e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800952:	75 f7                	jne    80094b <vprintfmt+0x3e9>
  800954:	e9 2e fc ff ff       	jmp    800587 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800959:	83 c4 4c             	add    $0x4c,%esp
  80095c:	5b                   	pop    %ebx
  80095d:	5e                   	pop    %esi
  80095e:	5f                   	pop    %edi
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	83 ec 28             	sub    $0x28,%esp
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80096d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800970:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800974:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800977:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80097e:	85 d2                	test   %edx,%edx
  800980:	7e 30                	jle    8009b2 <vsnprintf+0x51>
  800982:	85 c0                	test   %eax,%eax
  800984:	74 2c                	je     8009b2 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800986:	8b 45 14             	mov    0x14(%ebp),%eax
  800989:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80098d:	8b 45 10             	mov    0x10(%ebp),%eax
  800990:	89 44 24 08          	mov    %eax,0x8(%esp)
  800994:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800997:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099b:	c7 04 24 1d 05 80 00 	movl   $0x80051d,(%esp)
  8009a2:	e8 bb fb ff ff       	call   800562 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009aa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b0:	eb 05                	jmp    8009b7 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009b7:	c9                   	leave  
  8009b8:	c3                   	ret    

008009b9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009bf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8009c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d7:	89 04 24             	mov    %eax,(%esp)
  8009da:	e8 82 ff ff ff       	call   800961 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009df:	c9                   	leave  
  8009e0:	c3                   	ret    
  8009e1:	66 90                	xchg   %ax,%ax
  8009e3:	66 90                	xchg   %ax,%ax
  8009e5:	66 90                	xchg   %ax,%ax
  8009e7:	66 90                	xchg   %ax,%ax
  8009e9:	66 90                	xchg   %ax,%ax
  8009eb:	66 90                	xchg   %ax,%ax
  8009ed:	66 90                	xchg   %ax,%ax
  8009ef:	90                   	nop

008009f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f6:	80 3a 00             	cmpb   $0x0,(%edx)
  8009f9:	74 10                	je     800a0b <strlen+0x1b>
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a00:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a03:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a07:	75 f7                	jne    800a00 <strlen+0x10>
  800a09:	eb 05                	jmp    800a10 <strlen+0x20>
  800a0b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	53                   	push   %ebx
  800a16:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a1c:	85 c9                	test   %ecx,%ecx
  800a1e:	74 1c                	je     800a3c <strnlen+0x2a>
  800a20:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a23:	74 1e                	je     800a43 <strnlen+0x31>
  800a25:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800a2a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a2c:	39 ca                	cmp    %ecx,%edx
  800a2e:	74 18                	je     800a48 <strnlen+0x36>
  800a30:	83 c2 01             	add    $0x1,%edx
  800a33:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800a38:	75 f0                	jne    800a2a <strnlen+0x18>
  800a3a:	eb 0c                	jmp    800a48 <strnlen+0x36>
  800a3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a41:	eb 05                	jmp    800a48 <strnlen+0x36>
  800a43:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a48:	5b                   	pop    %ebx
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	53                   	push   %ebx
  800a4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a55:	89 c2                	mov    %eax,%edx
  800a57:	0f b6 19             	movzbl (%ecx),%ebx
  800a5a:	88 1a                	mov    %bl,(%edx)
  800a5c:	83 c2 01             	add    $0x1,%edx
  800a5f:	83 c1 01             	add    $0x1,%ecx
  800a62:	84 db                	test   %bl,%bl
  800a64:	75 f1                	jne    800a57 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a66:	5b                   	pop    %ebx
  800a67:	5d                   	pop    %ebp
  800a68:	c3                   	ret    

00800a69 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	53                   	push   %ebx
  800a6d:	83 ec 08             	sub    $0x8,%esp
  800a70:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a73:	89 1c 24             	mov    %ebx,(%esp)
  800a76:	e8 75 ff ff ff       	call   8009f0 <strlen>
	strcpy(dst + len, src);
  800a7b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a82:	01 d8                	add    %ebx,%eax
  800a84:	89 04 24             	mov    %eax,(%esp)
  800a87:	e8 bf ff ff ff       	call   800a4b <strcpy>
	return dst;
}
  800a8c:	89 d8                	mov    %ebx,%eax
  800a8e:	83 c4 08             	add    $0x8,%esp
  800a91:	5b                   	pop    %ebx
  800a92:	5d                   	pop    %ebp
  800a93:	c3                   	ret    

00800a94 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	56                   	push   %esi
  800a98:	53                   	push   %ebx
  800a99:	8b 75 08             	mov    0x8(%ebp),%esi
  800a9c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa2:	85 db                	test   %ebx,%ebx
  800aa4:	74 16                	je     800abc <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800aa6:	01 f3                	add    %esi,%ebx
  800aa8:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800aaa:	0f b6 02             	movzbl (%edx),%eax
  800aad:	88 01                	mov    %al,(%ecx)
  800aaf:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ab2:	80 3a 01             	cmpb   $0x1,(%edx)
  800ab5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ab8:	39 d9                	cmp    %ebx,%ecx
  800aba:	75 ee                	jne    800aaa <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800abc:	89 f0                	mov    %esi,%eax
  800abe:	5b                   	pop    %ebx
  800abf:	5e                   	pop    %esi
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    

00800ac2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	57                   	push   %edi
  800ac6:	56                   	push   %esi
  800ac7:	53                   	push   %ebx
  800ac8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800acb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ace:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ad1:	89 f8                	mov    %edi,%eax
  800ad3:	85 f6                	test   %esi,%esi
  800ad5:	74 33                	je     800b0a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800ad7:	83 fe 01             	cmp    $0x1,%esi
  800ada:	74 25                	je     800b01 <strlcpy+0x3f>
  800adc:	0f b6 0b             	movzbl (%ebx),%ecx
  800adf:	84 c9                	test   %cl,%cl
  800ae1:	74 22                	je     800b05 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800ae3:	83 ee 02             	sub    $0x2,%esi
  800ae6:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800aeb:	88 08                	mov    %cl,(%eax)
  800aed:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800af0:	39 f2                	cmp    %esi,%edx
  800af2:	74 13                	je     800b07 <strlcpy+0x45>
  800af4:	83 c2 01             	add    $0x1,%edx
  800af7:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800afb:	84 c9                	test   %cl,%cl
  800afd:	75 ec                	jne    800aeb <strlcpy+0x29>
  800aff:	eb 06                	jmp    800b07 <strlcpy+0x45>
  800b01:	89 f8                	mov    %edi,%eax
  800b03:	eb 02                	jmp    800b07 <strlcpy+0x45>
  800b05:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b07:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b0a:	29 f8                	sub    %edi,%eax
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b17:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b1a:	0f b6 01             	movzbl (%ecx),%eax
  800b1d:	84 c0                	test   %al,%al
  800b1f:	74 15                	je     800b36 <strcmp+0x25>
  800b21:	3a 02                	cmp    (%edx),%al
  800b23:	75 11                	jne    800b36 <strcmp+0x25>
		p++, q++;
  800b25:	83 c1 01             	add    $0x1,%ecx
  800b28:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b2b:	0f b6 01             	movzbl (%ecx),%eax
  800b2e:	84 c0                	test   %al,%al
  800b30:	74 04                	je     800b36 <strcmp+0x25>
  800b32:	3a 02                	cmp    (%edx),%al
  800b34:	74 ef                	je     800b25 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b36:	0f b6 c0             	movzbl %al,%eax
  800b39:	0f b6 12             	movzbl (%edx),%edx
  800b3c:	29 d0                	sub    %edx,%eax
}
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
  800b45:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b48:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b4b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800b4e:	85 f6                	test   %esi,%esi
  800b50:	74 29                	je     800b7b <strncmp+0x3b>
  800b52:	0f b6 03             	movzbl (%ebx),%eax
  800b55:	84 c0                	test   %al,%al
  800b57:	74 30                	je     800b89 <strncmp+0x49>
  800b59:	3a 02                	cmp    (%edx),%al
  800b5b:	75 2c                	jne    800b89 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  800b5d:	8d 43 01             	lea    0x1(%ebx),%eax
  800b60:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800b62:	89 c3                	mov    %eax,%ebx
  800b64:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b67:	39 f0                	cmp    %esi,%eax
  800b69:	74 17                	je     800b82 <strncmp+0x42>
  800b6b:	0f b6 08             	movzbl (%eax),%ecx
  800b6e:	84 c9                	test   %cl,%cl
  800b70:	74 17                	je     800b89 <strncmp+0x49>
  800b72:	83 c0 01             	add    $0x1,%eax
  800b75:	3a 0a                	cmp    (%edx),%cl
  800b77:	74 e9                	je     800b62 <strncmp+0x22>
  800b79:	eb 0e                	jmp    800b89 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b80:	eb 0f                	jmp    800b91 <strncmp+0x51>
  800b82:	b8 00 00 00 00       	mov    $0x0,%eax
  800b87:	eb 08                	jmp    800b91 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b89:	0f b6 03             	movzbl (%ebx),%eax
  800b8c:	0f b6 12             	movzbl (%edx),%edx
  800b8f:	29 d0                	sub    %edx,%eax
}
  800b91:	5b                   	pop    %ebx
  800b92:	5e                   	pop    %esi
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	53                   	push   %ebx
  800b99:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800b9f:	0f b6 18             	movzbl (%eax),%ebx
  800ba2:	84 db                	test   %bl,%bl
  800ba4:	74 1d                	je     800bc3 <strchr+0x2e>
  800ba6:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800ba8:	38 d3                	cmp    %dl,%bl
  800baa:	75 06                	jne    800bb2 <strchr+0x1d>
  800bac:	eb 1a                	jmp    800bc8 <strchr+0x33>
  800bae:	38 ca                	cmp    %cl,%dl
  800bb0:	74 16                	je     800bc8 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bb2:	83 c0 01             	add    $0x1,%eax
  800bb5:	0f b6 10             	movzbl (%eax),%edx
  800bb8:	84 d2                	test   %dl,%dl
  800bba:	75 f2                	jne    800bae <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800bbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc1:	eb 05                	jmp    800bc8 <strchr+0x33>
  800bc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc8:	5b                   	pop    %ebx
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	53                   	push   %ebx
  800bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd2:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800bd5:	0f b6 18             	movzbl (%eax),%ebx
  800bd8:	84 db                	test   %bl,%bl
  800bda:	74 16                	je     800bf2 <strfind+0x27>
  800bdc:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800bde:	38 d3                	cmp    %dl,%bl
  800be0:	75 06                	jne    800be8 <strfind+0x1d>
  800be2:	eb 0e                	jmp    800bf2 <strfind+0x27>
  800be4:	38 ca                	cmp    %cl,%dl
  800be6:	74 0a                	je     800bf2 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800be8:	83 c0 01             	add    $0x1,%eax
  800beb:	0f b6 10             	movzbl (%eax),%edx
  800bee:	84 d2                	test   %dl,%dl
  800bf0:	75 f2                	jne    800be4 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800bf2:	5b                   	pop    %ebx
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	83 ec 0c             	sub    $0xc,%esp
  800bfb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bfe:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c01:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c04:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c07:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c0a:	85 c9                	test   %ecx,%ecx
  800c0c:	74 36                	je     800c44 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c0e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c14:	75 28                	jne    800c3e <memset+0x49>
  800c16:	f6 c1 03             	test   $0x3,%cl
  800c19:	75 23                	jne    800c3e <memset+0x49>
		c &= 0xFF;
  800c1b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c1f:	89 d3                	mov    %edx,%ebx
  800c21:	c1 e3 08             	shl    $0x8,%ebx
  800c24:	89 d6                	mov    %edx,%esi
  800c26:	c1 e6 18             	shl    $0x18,%esi
  800c29:	89 d0                	mov    %edx,%eax
  800c2b:	c1 e0 10             	shl    $0x10,%eax
  800c2e:	09 f0                	or     %esi,%eax
  800c30:	09 c2                	or     %eax,%edx
  800c32:	89 d0                	mov    %edx,%eax
  800c34:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c36:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c39:	fc                   	cld    
  800c3a:	f3 ab                	rep stos %eax,%es:(%edi)
  800c3c:	eb 06                	jmp    800c44 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c41:	fc                   	cld    
  800c42:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c44:	89 f8                	mov    %edi,%eax
  800c46:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c49:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c4c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c4f:	89 ec                	mov    %ebp,%esp
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    

00800c53 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	83 ec 08             	sub    $0x8,%esp
  800c59:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c5c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c62:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c65:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c68:	39 c6                	cmp    %eax,%esi
  800c6a:	73 36                	jae    800ca2 <memmove+0x4f>
  800c6c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c6f:	39 d0                	cmp    %edx,%eax
  800c71:	73 2f                	jae    800ca2 <memmove+0x4f>
		s += n;
		d += n;
  800c73:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c76:	f6 c2 03             	test   $0x3,%dl
  800c79:	75 1b                	jne    800c96 <memmove+0x43>
  800c7b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c81:	75 13                	jne    800c96 <memmove+0x43>
  800c83:	f6 c1 03             	test   $0x3,%cl
  800c86:	75 0e                	jne    800c96 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c88:	83 ef 04             	sub    $0x4,%edi
  800c8b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c8e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c91:	fd                   	std    
  800c92:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c94:	eb 09                	jmp    800c9f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c96:	83 ef 01             	sub    $0x1,%edi
  800c99:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c9c:	fd                   	std    
  800c9d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c9f:	fc                   	cld    
  800ca0:	eb 20                	jmp    800cc2 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ca2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ca8:	75 13                	jne    800cbd <memmove+0x6a>
  800caa:	a8 03                	test   $0x3,%al
  800cac:	75 0f                	jne    800cbd <memmove+0x6a>
  800cae:	f6 c1 03             	test   $0x3,%cl
  800cb1:	75 0a                	jne    800cbd <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cb3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cb6:	89 c7                	mov    %eax,%edi
  800cb8:	fc                   	cld    
  800cb9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cbb:	eb 05                	jmp    800cc2 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cbd:	89 c7                	mov    %eax,%edi
  800cbf:	fc                   	cld    
  800cc0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cc2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cc5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cc8:	89 ec                	mov    %ebp,%esp
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cd2:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cdc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ce0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce3:	89 04 24             	mov    %eax,(%esp)
  800ce6:	e8 68 ff ff ff       	call   800c53 <memmove>
}
  800ceb:	c9                   	leave  
  800cec:	c3                   	ret    

00800ced <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	57                   	push   %edi
  800cf1:	56                   	push   %esi
  800cf2:	53                   	push   %ebx
  800cf3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cf6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf9:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cfc:	8d 78 ff             	lea    -0x1(%eax),%edi
  800cff:	85 c0                	test   %eax,%eax
  800d01:	74 36                	je     800d39 <memcmp+0x4c>
		if (*s1 != *s2)
  800d03:	0f b6 03             	movzbl (%ebx),%eax
  800d06:	0f b6 0e             	movzbl (%esi),%ecx
  800d09:	38 c8                	cmp    %cl,%al
  800d0b:	75 17                	jne    800d24 <memcmp+0x37>
  800d0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d12:	eb 1a                	jmp    800d2e <memcmp+0x41>
  800d14:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800d19:	83 c2 01             	add    $0x1,%edx
  800d1c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800d20:	38 c8                	cmp    %cl,%al
  800d22:	74 0a                	je     800d2e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800d24:	0f b6 c0             	movzbl %al,%eax
  800d27:	0f b6 c9             	movzbl %cl,%ecx
  800d2a:	29 c8                	sub    %ecx,%eax
  800d2c:	eb 10                	jmp    800d3e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d2e:	39 fa                	cmp    %edi,%edx
  800d30:	75 e2                	jne    800d14 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d32:	b8 00 00 00 00       	mov    $0x0,%eax
  800d37:	eb 05                	jmp    800d3e <memcmp+0x51>
  800d39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	53                   	push   %ebx
  800d47:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800d4d:	89 c2                	mov    %eax,%edx
  800d4f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d52:	39 d0                	cmp    %edx,%eax
  800d54:	73 13                	jae    800d69 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d56:	89 d9                	mov    %ebx,%ecx
  800d58:	38 18                	cmp    %bl,(%eax)
  800d5a:	75 06                	jne    800d62 <memfind+0x1f>
  800d5c:	eb 0b                	jmp    800d69 <memfind+0x26>
  800d5e:	38 08                	cmp    %cl,(%eax)
  800d60:	74 07                	je     800d69 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d62:	83 c0 01             	add    $0x1,%eax
  800d65:	39 d0                	cmp    %edx,%eax
  800d67:	75 f5                	jne    800d5e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d69:	5b                   	pop    %ebx
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	57                   	push   %edi
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
  800d72:	83 ec 04             	sub    $0x4,%esp
  800d75:	8b 55 08             	mov    0x8(%ebp),%edx
  800d78:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d7b:	0f b6 02             	movzbl (%edx),%eax
  800d7e:	3c 09                	cmp    $0x9,%al
  800d80:	74 04                	je     800d86 <strtol+0x1a>
  800d82:	3c 20                	cmp    $0x20,%al
  800d84:	75 0e                	jne    800d94 <strtol+0x28>
		s++;
  800d86:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d89:	0f b6 02             	movzbl (%edx),%eax
  800d8c:	3c 09                	cmp    $0x9,%al
  800d8e:	74 f6                	je     800d86 <strtol+0x1a>
  800d90:	3c 20                	cmp    $0x20,%al
  800d92:	74 f2                	je     800d86 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d94:	3c 2b                	cmp    $0x2b,%al
  800d96:	75 0a                	jne    800da2 <strtol+0x36>
		s++;
  800d98:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d9b:	bf 00 00 00 00       	mov    $0x0,%edi
  800da0:	eb 10                	jmp    800db2 <strtol+0x46>
  800da2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800da7:	3c 2d                	cmp    $0x2d,%al
  800da9:	75 07                	jne    800db2 <strtol+0x46>
		s++, neg = 1;
  800dab:	83 c2 01             	add    $0x1,%edx
  800dae:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800db2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800db8:	75 15                	jne    800dcf <strtol+0x63>
  800dba:	80 3a 30             	cmpb   $0x30,(%edx)
  800dbd:	75 10                	jne    800dcf <strtol+0x63>
  800dbf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800dc3:	75 0a                	jne    800dcf <strtol+0x63>
		s += 2, base = 16;
  800dc5:	83 c2 02             	add    $0x2,%edx
  800dc8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800dcd:	eb 10                	jmp    800ddf <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800dcf:	85 db                	test   %ebx,%ebx
  800dd1:	75 0c                	jne    800ddf <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800dd3:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dd5:	80 3a 30             	cmpb   $0x30,(%edx)
  800dd8:	75 05                	jne    800ddf <strtol+0x73>
		s++, base = 8;
  800dda:	83 c2 01             	add    $0x1,%edx
  800ddd:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800ddf:	b8 00 00 00 00       	mov    $0x0,%eax
  800de4:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800de7:	0f b6 0a             	movzbl (%edx),%ecx
  800dea:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800ded:	89 f3                	mov    %esi,%ebx
  800def:	80 fb 09             	cmp    $0x9,%bl
  800df2:	77 08                	ja     800dfc <strtol+0x90>
			dig = *s - '0';
  800df4:	0f be c9             	movsbl %cl,%ecx
  800df7:	83 e9 30             	sub    $0x30,%ecx
  800dfa:	eb 22                	jmp    800e1e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800dfc:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800dff:	89 f3                	mov    %esi,%ebx
  800e01:	80 fb 19             	cmp    $0x19,%bl
  800e04:	77 08                	ja     800e0e <strtol+0xa2>
			dig = *s - 'a' + 10;
  800e06:	0f be c9             	movsbl %cl,%ecx
  800e09:	83 e9 57             	sub    $0x57,%ecx
  800e0c:	eb 10                	jmp    800e1e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800e0e:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800e11:	89 f3                	mov    %esi,%ebx
  800e13:	80 fb 19             	cmp    $0x19,%bl
  800e16:	77 16                	ja     800e2e <strtol+0xc2>
			dig = *s - 'A' + 10;
  800e18:	0f be c9             	movsbl %cl,%ecx
  800e1b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e1e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800e21:	7d 0f                	jge    800e32 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800e23:	83 c2 01             	add    $0x1,%edx
  800e26:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800e2a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800e2c:	eb b9                	jmp    800de7 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800e2e:	89 c1                	mov    %eax,%ecx
  800e30:	eb 02                	jmp    800e34 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e32:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800e34:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e38:	74 05                	je     800e3f <strtol+0xd3>
		*endptr = (char *) s;
  800e3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e3d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e3f:	89 ca                	mov    %ecx,%edx
  800e41:	f7 da                	neg    %edx
  800e43:	85 ff                	test   %edi,%edi
  800e45:	0f 45 c2             	cmovne %edx,%eax
}
  800e48:	83 c4 04             	add    $0x4,%esp
  800e4b:	5b                   	pop    %ebx
  800e4c:	5e                   	pop    %esi
  800e4d:	5f                   	pop    %edi
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	83 ec 0c             	sub    $0xc,%esp
  800e56:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e59:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e5c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e67:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6a:	89 c3                	mov    %eax,%ebx
  800e6c:	89 c7                	mov    %eax,%edi
  800e6e:	89 c6                	mov    %eax,%esi
  800e70:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e72:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e75:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e78:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e7b:	89 ec                	mov    %ebp,%esp
  800e7d:	5d                   	pop    %ebp
  800e7e:	c3                   	ret    

00800e7f <sys_cgetc>:

int
sys_cgetc(void)
{
  800e7f:	55                   	push   %ebp
  800e80:	89 e5                	mov    %esp,%ebp
  800e82:	83 ec 0c             	sub    $0xc,%esp
  800e85:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e88:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e8b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e93:	b8 01 00 00 00       	mov    $0x1,%eax
  800e98:	89 d1                	mov    %edx,%ecx
  800e9a:	89 d3                	mov    %edx,%ebx
  800e9c:	89 d7                	mov    %edx,%edi
  800e9e:	89 d6                	mov    %edx,%esi
  800ea0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ea2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eab:	89 ec                	mov    %ebp,%esp
  800ead:	5d                   	pop    %ebp
  800eae:	c3                   	ret    

00800eaf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800eaf:	55                   	push   %ebp
  800eb0:	89 e5                	mov    %esp,%ebp
  800eb2:	83 ec 38             	sub    $0x38,%esp
  800eb5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eb8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ebb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ec3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ec8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecb:	89 cb                	mov    %ecx,%ebx
  800ecd:	89 cf                	mov    %ecx,%edi
  800ecf:	89 ce                	mov    %ecx,%esi
  800ed1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	7e 28                	jle    800eff <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800edb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ee2:	00 
  800ee3:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  800eea:	00 
  800eeb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef2:	00 
  800ef3:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  800efa:	e8 d1 f3 ff ff       	call   8002d0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800eff:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f02:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f05:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f08:	89 ec                	mov    %ebp,%esp
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	83 ec 0c             	sub    $0xc,%esp
  800f12:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f15:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f18:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f20:	b8 02 00 00 00       	mov    $0x2,%eax
  800f25:	89 d1                	mov    %edx,%ecx
  800f27:	89 d3                	mov    %edx,%ebx
  800f29:	89 d7                	mov    %edx,%edi
  800f2b:	89 d6                	mov    %edx,%esi
  800f2d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f2f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f32:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f35:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f38:	89 ec                	mov    %ebp,%esp
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    

00800f3c <sys_yield>:

void
sys_yield(void)
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	83 ec 0c             	sub    $0xc,%esp
  800f42:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f45:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f48:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f50:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f55:	89 d1                	mov    %edx,%ecx
  800f57:	89 d3                	mov    %edx,%ebx
  800f59:	89 d7                	mov    %edx,%edi
  800f5b:	89 d6                	mov    %edx,%esi
  800f5d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f5f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f62:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f65:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f68:	89 ec                	mov    %ebp,%esp
  800f6a:	5d                   	pop    %ebp
  800f6b:	c3                   	ret    

00800f6c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	83 ec 38             	sub    $0x38,%esp
  800f72:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f75:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f78:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7b:	be 00 00 00 00       	mov    $0x0,%esi
  800f80:	b8 04 00 00 00       	mov    $0x4,%eax
  800f85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f88:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f8e:	89 f7                	mov    %esi,%edi
  800f90:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f92:	85 c0                	test   %eax,%eax
  800f94:	7e 28                	jle    800fbe <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f96:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f9a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800fa1:	00 
  800fa2:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  800fa9:	00 
  800faa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fb1:	00 
  800fb2:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  800fb9:	e8 12 f3 ff ff       	call   8002d0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fbe:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fc1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fc4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fc7:	89 ec                	mov    %ebp,%esp
  800fc9:	5d                   	pop    %ebp
  800fca:	c3                   	ret    

00800fcb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fcb:	55                   	push   %ebp
  800fcc:	89 e5                	mov    %esp,%ebp
  800fce:	83 ec 38             	sub    $0x38,%esp
  800fd1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fd4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fd7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fda:	b8 05 00 00 00       	mov    $0x5,%eax
  800fdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fe8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800feb:	8b 75 18             	mov    0x18(%ebp),%esi
  800fee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ff0:	85 c0                	test   %eax,%eax
  800ff2:	7e 28                	jle    80101c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800fff:	00 
  801000:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  801007:	00 
  801008:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80100f:	00 
  801010:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  801017:	e8 b4 f2 ff ff       	call   8002d0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80101c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80101f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801022:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801025:	89 ec                	mov    %ebp,%esp
  801027:	5d                   	pop    %ebp
  801028:	c3                   	ret    

00801029 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801029:	55                   	push   %ebp
  80102a:	89 e5                	mov    %esp,%ebp
  80102c:	83 ec 38             	sub    $0x38,%esp
  80102f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801032:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801035:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801038:	bb 00 00 00 00       	mov    $0x0,%ebx
  80103d:	b8 06 00 00 00       	mov    $0x6,%eax
  801042:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801045:	8b 55 08             	mov    0x8(%ebp),%edx
  801048:	89 df                	mov    %ebx,%edi
  80104a:	89 de                	mov    %ebx,%esi
  80104c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80104e:	85 c0                	test   %eax,%eax
  801050:	7e 28                	jle    80107a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801052:	89 44 24 10          	mov    %eax,0x10(%esp)
  801056:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80105d:	00 
  80105e:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  801065:	00 
  801066:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80106d:	00 
  80106e:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  801075:	e8 56 f2 ff ff       	call   8002d0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80107a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80107d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801080:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801083:	89 ec                	mov    %ebp,%esp
  801085:	5d                   	pop    %ebp
  801086:	c3                   	ret    

00801087 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
  80108a:	83 ec 38             	sub    $0x38,%esp
  80108d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801090:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801093:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801096:	bb 00 00 00 00       	mov    $0x0,%ebx
  80109b:	b8 08 00 00 00       	mov    $0x8,%eax
  8010a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a6:	89 df                	mov    %ebx,%edi
  8010a8:	89 de                	mov    %ebx,%esi
  8010aa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010ac:	85 c0                	test   %eax,%eax
  8010ae:	7e 28                	jle    8010d8 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8010bb:	00 
  8010bc:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  8010c3:	00 
  8010c4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010cb:	00 
  8010cc:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  8010d3:	e8 f8 f1 ff ff       	call   8002d0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8010d8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010db:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010de:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010e1:	89 ec                	mov    %ebp,%esp
  8010e3:	5d                   	pop    %ebp
  8010e4:	c3                   	ret    

008010e5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
  8010e8:	83 ec 38             	sub    $0x38,%esp
  8010eb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010ee:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010f1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f9:	b8 09 00 00 00       	mov    $0x9,%eax
  8010fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801101:	8b 55 08             	mov    0x8(%ebp),%edx
  801104:	89 df                	mov    %ebx,%edi
  801106:	89 de                	mov    %ebx,%esi
  801108:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80110a:	85 c0                	test   %eax,%eax
  80110c:	7e 28                	jle    801136 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80110e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801112:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801119:	00 
  80111a:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  801121:	00 
  801122:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801129:	00 
  80112a:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  801131:	e8 9a f1 ff ff       	call   8002d0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801136:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801139:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80113c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80113f:	89 ec                	mov    %ebp,%esp
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    

00801143 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	83 ec 0c             	sub    $0xc,%esp
  801149:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80114c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80114f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801152:	be 00 00 00 00       	mov    $0x0,%esi
  801157:	b8 0b 00 00 00       	mov    $0xb,%eax
  80115c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80115f:	8b 55 08             	mov    0x8(%ebp),%edx
  801162:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801165:	8b 7d 14             	mov    0x14(%ebp),%edi
  801168:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80116a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80116d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801170:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801173:	89 ec                	mov    %ebp,%esp
  801175:	5d                   	pop    %ebp
  801176:	c3                   	ret    

00801177 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	83 ec 38             	sub    $0x38,%esp
  80117d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801180:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801183:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801186:	b9 00 00 00 00       	mov    $0x0,%ecx
  80118b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801190:	8b 55 08             	mov    0x8(%ebp),%edx
  801193:	89 cb                	mov    %ecx,%ebx
  801195:	89 cf                	mov    %ecx,%edi
  801197:	89 ce                	mov    %ecx,%esi
  801199:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80119b:	85 c0                	test   %eax,%eax
  80119d:	7e 28                	jle    8011c7 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80119f:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011a3:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  8011aa:	00 
  8011ab:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  8011b2:	00 
  8011b3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011ba:	00 
  8011bb:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  8011c2:	e8 09 f1 ff ff       	call   8002d0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8011c7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011ca:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011cd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011d0:	89 ec                	mov    %ebp,%esp
  8011d2:	5d                   	pop    %ebp
  8011d3:	c3                   	ret    
  8011d4:	66 90                	xchg   %ax,%ax
  8011d6:	66 90                	xchg   %ax,%ax
  8011d8:	66 90                	xchg   %ax,%ax
  8011da:	66 90                	xchg   %ax,%ax
  8011dc:	66 90                	xchg   %ax,%ax
  8011de:	66 90                	xchg   %ax,%ax

008011e0 <__udivdi3>:
  8011e0:	83 ec 1c             	sub    $0x1c,%esp
  8011e3:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8011e7:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8011eb:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8011ef:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8011f3:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8011f7:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	89 74 24 10          	mov    %esi,0x10(%esp)
  801201:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801205:	89 ea                	mov    %ebp,%edx
  801207:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80120b:	75 33                	jne    801240 <__udivdi3+0x60>
  80120d:	39 e9                	cmp    %ebp,%ecx
  80120f:	77 6f                	ja     801280 <__udivdi3+0xa0>
  801211:	85 c9                	test   %ecx,%ecx
  801213:	89 ce                	mov    %ecx,%esi
  801215:	75 0b                	jne    801222 <__udivdi3+0x42>
  801217:	b8 01 00 00 00       	mov    $0x1,%eax
  80121c:	31 d2                	xor    %edx,%edx
  80121e:	f7 f1                	div    %ecx
  801220:	89 c6                	mov    %eax,%esi
  801222:	31 d2                	xor    %edx,%edx
  801224:	89 e8                	mov    %ebp,%eax
  801226:	f7 f6                	div    %esi
  801228:	89 c5                	mov    %eax,%ebp
  80122a:	89 f8                	mov    %edi,%eax
  80122c:	f7 f6                	div    %esi
  80122e:	89 ea                	mov    %ebp,%edx
  801230:	8b 74 24 10          	mov    0x10(%esp),%esi
  801234:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801238:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80123c:	83 c4 1c             	add    $0x1c,%esp
  80123f:	c3                   	ret    
  801240:	39 e8                	cmp    %ebp,%eax
  801242:	77 24                	ja     801268 <__udivdi3+0x88>
  801244:	0f bd c8             	bsr    %eax,%ecx
  801247:	83 f1 1f             	xor    $0x1f,%ecx
  80124a:	89 0c 24             	mov    %ecx,(%esp)
  80124d:	75 49                	jne    801298 <__udivdi3+0xb8>
  80124f:	8b 74 24 08          	mov    0x8(%esp),%esi
  801253:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801257:	0f 86 ab 00 00 00    	jbe    801308 <__udivdi3+0x128>
  80125d:	39 e8                	cmp    %ebp,%eax
  80125f:	0f 82 a3 00 00 00    	jb     801308 <__udivdi3+0x128>
  801265:	8d 76 00             	lea    0x0(%esi),%esi
  801268:	31 d2                	xor    %edx,%edx
  80126a:	31 c0                	xor    %eax,%eax
  80126c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801270:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801274:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801278:	83 c4 1c             	add    $0x1c,%esp
  80127b:	c3                   	ret    
  80127c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801280:	89 f8                	mov    %edi,%eax
  801282:	f7 f1                	div    %ecx
  801284:	31 d2                	xor    %edx,%edx
  801286:	8b 74 24 10          	mov    0x10(%esp),%esi
  80128a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80128e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801292:	83 c4 1c             	add    $0x1c,%esp
  801295:	c3                   	ret    
  801296:	66 90                	xchg   %ax,%ax
  801298:	0f b6 0c 24          	movzbl (%esp),%ecx
  80129c:	89 c6                	mov    %eax,%esi
  80129e:	b8 20 00 00 00       	mov    $0x20,%eax
  8012a3:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  8012a7:	2b 04 24             	sub    (%esp),%eax
  8012aa:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8012ae:	d3 e6                	shl    %cl,%esi
  8012b0:	89 c1                	mov    %eax,%ecx
  8012b2:	d3 ed                	shr    %cl,%ebp
  8012b4:	0f b6 0c 24          	movzbl (%esp),%ecx
  8012b8:	09 f5                	or     %esi,%ebp
  8012ba:	8b 74 24 04          	mov    0x4(%esp),%esi
  8012be:	d3 e6                	shl    %cl,%esi
  8012c0:	89 c1                	mov    %eax,%ecx
  8012c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012c6:	89 d6                	mov    %edx,%esi
  8012c8:	d3 ee                	shr    %cl,%esi
  8012ca:	0f b6 0c 24          	movzbl (%esp),%ecx
  8012ce:	d3 e2                	shl    %cl,%edx
  8012d0:	89 c1                	mov    %eax,%ecx
  8012d2:	d3 ef                	shr    %cl,%edi
  8012d4:	09 d7                	or     %edx,%edi
  8012d6:	89 f2                	mov    %esi,%edx
  8012d8:	89 f8                	mov    %edi,%eax
  8012da:	f7 f5                	div    %ebp
  8012dc:	89 d6                	mov    %edx,%esi
  8012de:	89 c7                	mov    %eax,%edi
  8012e0:	f7 64 24 04          	mull   0x4(%esp)
  8012e4:	39 d6                	cmp    %edx,%esi
  8012e6:	72 30                	jb     801318 <__udivdi3+0x138>
  8012e8:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8012ec:	0f b6 0c 24          	movzbl (%esp),%ecx
  8012f0:	d3 e5                	shl    %cl,%ebp
  8012f2:	39 c5                	cmp    %eax,%ebp
  8012f4:	73 04                	jae    8012fa <__udivdi3+0x11a>
  8012f6:	39 d6                	cmp    %edx,%esi
  8012f8:	74 1e                	je     801318 <__udivdi3+0x138>
  8012fa:	89 f8                	mov    %edi,%eax
  8012fc:	31 d2                	xor    %edx,%edx
  8012fe:	e9 69 ff ff ff       	jmp    80126c <__udivdi3+0x8c>
  801303:	90                   	nop
  801304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801308:	31 d2                	xor    %edx,%edx
  80130a:	b8 01 00 00 00       	mov    $0x1,%eax
  80130f:	e9 58 ff ff ff       	jmp    80126c <__udivdi3+0x8c>
  801314:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801318:	8d 47 ff             	lea    -0x1(%edi),%eax
  80131b:	31 d2                	xor    %edx,%edx
  80131d:	8b 74 24 10          	mov    0x10(%esp),%esi
  801321:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801325:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801329:	83 c4 1c             	add    $0x1c,%esp
  80132c:	c3                   	ret    
  80132d:	66 90                	xchg   %ax,%ax
  80132f:	90                   	nop

00801330 <__umoddi3>:
  801330:	83 ec 2c             	sub    $0x2c,%esp
  801333:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801337:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80133b:	89 74 24 20          	mov    %esi,0x20(%esp)
  80133f:	8b 74 24 38          	mov    0x38(%esp),%esi
  801343:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801347:	8b 7c 24 34          	mov    0x34(%esp),%edi
  80134b:	85 c0                	test   %eax,%eax
  80134d:	89 c2                	mov    %eax,%edx
  80134f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801353:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801357:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80135b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80135f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801363:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801367:	75 1f                	jne    801388 <__umoddi3+0x58>
  801369:	39 fe                	cmp    %edi,%esi
  80136b:	76 63                	jbe    8013d0 <__umoddi3+0xa0>
  80136d:	89 c8                	mov    %ecx,%eax
  80136f:	89 fa                	mov    %edi,%edx
  801371:	f7 f6                	div    %esi
  801373:	89 d0                	mov    %edx,%eax
  801375:	31 d2                	xor    %edx,%edx
  801377:	8b 74 24 20          	mov    0x20(%esp),%esi
  80137b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80137f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801383:	83 c4 2c             	add    $0x2c,%esp
  801386:	c3                   	ret    
  801387:	90                   	nop
  801388:	39 f8                	cmp    %edi,%eax
  80138a:	77 64                	ja     8013f0 <__umoddi3+0xc0>
  80138c:	0f bd e8             	bsr    %eax,%ebp
  80138f:	83 f5 1f             	xor    $0x1f,%ebp
  801392:	75 74                	jne    801408 <__umoddi3+0xd8>
  801394:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801398:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  80139c:	0f 87 0e 01 00 00    	ja     8014b0 <__umoddi3+0x180>
  8013a2:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  8013a6:	29 f1                	sub    %esi,%ecx
  8013a8:	19 c7                	sbb    %eax,%edi
  8013aa:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8013ae:	89 7c 24 18          	mov    %edi,0x18(%esp)
  8013b2:	8b 44 24 14          	mov    0x14(%esp),%eax
  8013b6:	8b 54 24 18          	mov    0x18(%esp),%edx
  8013ba:	8b 74 24 20          	mov    0x20(%esp),%esi
  8013be:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8013c2:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8013c6:	83 c4 2c             	add    $0x2c,%esp
  8013c9:	c3                   	ret    
  8013ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013d0:	85 f6                	test   %esi,%esi
  8013d2:	89 f5                	mov    %esi,%ebp
  8013d4:	75 0b                	jne    8013e1 <__umoddi3+0xb1>
  8013d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013db:	31 d2                	xor    %edx,%edx
  8013dd:	f7 f6                	div    %esi
  8013df:	89 c5                	mov    %eax,%ebp
  8013e1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8013e5:	31 d2                	xor    %edx,%edx
  8013e7:	f7 f5                	div    %ebp
  8013e9:	89 c8                	mov    %ecx,%eax
  8013eb:	f7 f5                	div    %ebp
  8013ed:	eb 84                	jmp    801373 <__umoddi3+0x43>
  8013ef:	90                   	nop
  8013f0:	89 c8                	mov    %ecx,%eax
  8013f2:	89 fa                	mov    %edi,%edx
  8013f4:	8b 74 24 20          	mov    0x20(%esp),%esi
  8013f8:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8013fc:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801400:	83 c4 2c             	add    $0x2c,%esp
  801403:	c3                   	ret    
  801404:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801408:	8b 44 24 10          	mov    0x10(%esp),%eax
  80140c:	be 20 00 00 00       	mov    $0x20,%esi
  801411:	89 e9                	mov    %ebp,%ecx
  801413:	29 ee                	sub    %ebp,%esi
  801415:	d3 e2                	shl    %cl,%edx
  801417:	89 f1                	mov    %esi,%ecx
  801419:	d3 e8                	shr    %cl,%eax
  80141b:	89 e9                	mov    %ebp,%ecx
  80141d:	09 d0                	or     %edx,%eax
  80141f:	89 fa                	mov    %edi,%edx
  801421:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801425:	8b 44 24 10          	mov    0x10(%esp),%eax
  801429:	d3 e0                	shl    %cl,%eax
  80142b:	89 f1                	mov    %esi,%ecx
  80142d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801431:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801435:	d3 ea                	shr    %cl,%edx
  801437:	89 e9                	mov    %ebp,%ecx
  801439:	d3 e7                	shl    %cl,%edi
  80143b:	89 f1                	mov    %esi,%ecx
  80143d:	d3 e8                	shr    %cl,%eax
  80143f:	89 e9                	mov    %ebp,%ecx
  801441:	09 f8                	or     %edi,%eax
  801443:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801447:	f7 74 24 0c          	divl   0xc(%esp)
  80144b:	d3 e7                	shl    %cl,%edi
  80144d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801451:	89 d7                	mov    %edx,%edi
  801453:	f7 64 24 10          	mull   0x10(%esp)
  801457:	39 d7                	cmp    %edx,%edi
  801459:	89 c1                	mov    %eax,%ecx
  80145b:	89 54 24 14          	mov    %edx,0x14(%esp)
  80145f:	72 3b                	jb     80149c <__umoddi3+0x16c>
  801461:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801465:	72 31                	jb     801498 <__umoddi3+0x168>
  801467:	8b 44 24 18          	mov    0x18(%esp),%eax
  80146b:	29 c8                	sub    %ecx,%eax
  80146d:	19 d7                	sbb    %edx,%edi
  80146f:	89 e9                	mov    %ebp,%ecx
  801471:	89 fa                	mov    %edi,%edx
  801473:	d3 e8                	shr    %cl,%eax
  801475:	89 f1                	mov    %esi,%ecx
  801477:	d3 e2                	shl    %cl,%edx
  801479:	89 e9                	mov    %ebp,%ecx
  80147b:	09 d0                	or     %edx,%eax
  80147d:	89 fa                	mov    %edi,%edx
  80147f:	d3 ea                	shr    %cl,%edx
  801481:	8b 74 24 20          	mov    0x20(%esp),%esi
  801485:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801489:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  80148d:	83 c4 2c             	add    $0x2c,%esp
  801490:	c3                   	ret    
  801491:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801498:	39 d7                	cmp    %edx,%edi
  80149a:	75 cb                	jne    801467 <__umoddi3+0x137>
  80149c:	8b 54 24 14          	mov    0x14(%esp),%edx
  8014a0:	89 c1                	mov    %eax,%ecx
  8014a2:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  8014a6:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  8014aa:	eb bb                	jmp    801467 <__umoddi3+0x137>
  8014ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014b0:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8014b4:	0f 82 e8 fe ff ff    	jb     8013a2 <__umoddi3+0x72>
  8014ba:	e9 f3 fe ff ff       	jmp    8013b2 <__umoddi3+0x82>
