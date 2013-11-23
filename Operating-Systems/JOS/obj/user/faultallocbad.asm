
obj/user/faultallocbad:     file format elf32-i386


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
  80002c:	e8 b3 00 00 00       	call   8000e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003b:	8b 45 08             	mov    0x8(%ebp),%eax
  80003e:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800040:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800044:	c7 04 24 00 14 80 00 	movl   $0x801400,(%esp)
  80004b:	e8 ff 01 00 00       	call   80024f <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 7d 0d 00 00       	call   800dec <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 20 14 80 	movl   $0x801420,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 0a 14 80 00 	movl   $0x80140a,(%esp)
  800092:	e8 bd 00 00 00       	call   800154 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 4c 14 80 	movl   $0x80144c,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 86 07 00 00       	call   800839 <snprintf>
}
  8000b3:	83 c4 24             	add    $0x24,%esp
  8000b6:	5b                   	pop    %ebx
  8000b7:	5d                   	pop    %ebp
  8000b8:	c3                   	ret    

008000b9 <umain>:

void
umain(int argc, char **argv)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  8000bf:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  8000c6:	e8 89 0f 00 00       	call   801054 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000cb:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000d2:	00 
  8000d3:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000da:	e8 f1 0b 00 00       	call   800cd0 <sys_cputs>
}
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    
  8000e1:	66 90                	xchg   %ax,%ax
  8000e3:	90                   	nop

008000e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 18             	sub    $0x18,%esp
  8000ea:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000ed:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f3:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000f6:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000fd:	00 00 00 
	int envid;
	envid = sys_getenvid();
  800100:	e8 87 0c 00 00       	call   800d8c <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800105:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800112:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800117:	85 db                	test   %ebx,%ebx
  800119:	7e 07                	jle    800122 <libmain+0x3e>
		binaryname = argv[0];
  80011b:	8b 06                	mov    (%esi),%eax
  80011d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800122:	89 74 24 04          	mov    %esi,0x4(%esp)
  800126:	89 1c 24             	mov    %ebx,(%esp)
  800129:	e8 8b ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  80012e:	e8 0d 00 00 00       	call   800140 <exit>
}
  800133:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800136:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800139:	89 ec                	mov    %ebp,%esp
  80013b:	5d                   	pop    %ebp
  80013c:	c3                   	ret    
  80013d:	66 90                	xchg   %ax,%ax
  80013f:	90                   	nop

00800140 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800146:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80014d:	e8 dd 0b 00 00       	call   800d2f <sys_env_destroy>
}
  800152:	c9                   	leave  
  800153:	c3                   	ret    

00800154 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
  800159:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80015c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800165:	e8 22 0c 00 00       	call   800d8c <sys_getenvid>
  80016a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80016d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800171:	8b 55 08             	mov    0x8(%ebp),%edx
  800174:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800178:	89 74 24 08          	mov    %esi,0x8(%esp)
  80017c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800180:	c7 04 24 78 14 80 00 	movl   $0x801478,(%esp)
  800187:	e8 c3 00 00 00       	call   80024f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80018c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800190:	8b 45 10             	mov    0x10(%ebp),%eax
  800193:	89 04 24             	mov    %eax,(%esp)
  800196:	e8 53 00 00 00       	call   8001ee <vcprintf>
	cprintf("\n");
  80019b:	c7 04 24 11 17 80 00 	movl   $0x801711,(%esp)
  8001a2:	e8 a8 00 00 00       	call   80024f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a7:	cc                   	int3   
  8001a8:	eb fd                	jmp    8001a7 <_panic+0x53>
  8001aa:	66 90                	xchg   %ax,%ax

008001ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	53                   	push   %ebx
  8001b0:	83 ec 14             	sub    $0x14,%esp
  8001b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b6:	8b 03                	mov    (%ebx),%eax
  8001b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001bf:	83 c0 01             	add    $0x1,%eax
  8001c2:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001c4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c9:	75 19                	jne    8001e4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001cb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001d2:	00 
  8001d3:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d6:	89 04 24             	mov    %eax,(%esp)
  8001d9:	e8 f2 0a 00 00       	call   800cd0 <sys_cputs>
		b->idx = 0;
  8001de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e8:	83 c4 14             	add    $0x14,%esp
  8001eb:	5b                   	pop    %ebx
  8001ec:	5d                   	pop    %ebp
  8001ed:	c3                   	ret    

008001ee <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001fe:	00 00 00 
	b.cnt = 0;
  800201:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800208:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80020b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800212:	8b 45 08             	mov    0x8(%ebp),%eax
  800215:	89 44 24 08          	mov    %eax,0x8(%esp)
  800219:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800223:	c7 04 24 ac 01 80 00 	movl   $0x8001ac,(%esp)
  80022a:	e8 b3 01 00 00       	call   8003e2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800235:	89 44 24 04          	mov    %eax,0x4(%esp)
  800239:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023f:	89 04 24             	mov    %eax,(%esp)
  800242:	e8 89 0a 00 00       	call   800cd0 <sys_cputs>

	return b.cnt;
}
  800247:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024d:	c9                   	leave  
  80024e:	c3                   	ret    

0080024f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800255:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800258:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025c:	8b 45 08             	mov    0x8(%ebp),%eax
  80025f:	89 04 24             	mov    %eax,(%esp)
  800262:	e8 87 ff ff ff       	call   8001ee <vcprintf>
	va_end(ap);

	return cnt;
}
  800267:	c9                   	leave  
  800268:	c3                   	ret    
  800269:	66 90                	xchg   %ax,%ax
  80026b:	66 90                	xchg   %ax,%ax
  80026d:	66 90                	xchg   %ax,%ax
  80026f:	90                   	nop

00800270 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 4c             	sub    $0x4c,%esp
  800279:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80027c:	89 d7                	mov    %edx,%edi
  80027e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800281:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800284:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800287:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80028a:	b8 00 00 00 00       	mov    $0x0,%eax
  80028f:	39 d8                	cmp    %ebx,%eax
  800291:	72 17                	jb     8002aa <printnum+0x3a>
  800293:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800296:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  800299:	76 0f                	jbe    8002aa <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029b:	8b 75 14             	mov    0x14(%ebp),%esi
  80029e:	83 ee 01             	sub    $0x1,%esi
  8002a1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002a4:	85 f6                	test   %esi,%esi
  8002a6:	7f 63                	jg     80030b <printnum+0x9b>
  8002a8:	eb 75                	jmp    80031f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002aa:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8002ad:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8002b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8002b4:	83 e8 01             	sub    $0x1,%eax
  8002b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002c2:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002c6:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002cd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8002d0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002d7:	00 
  8002d8:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8002db:	89 1c 24             	mov    %ebx,(%esp)
  8002de:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002e5:	e8 26 0e 00 00       	call   801110 <__udivdi3>
  8002ea:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002ed:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002f0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002f4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002f8:	89 04 24             	mov    %eax,(%esp)
  8002fb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ff:	89 fa                	mov    %edi,%edx
  800301:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800304:	e8 67 ff ff ff       	call   800270 <printnum>
  800309:	eb 14                	jmp    80031f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80030b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80030f:	8b 45 18             	mov    0x18(%ebp),%eax
  800312:	89 04 24             	mov    %eax,(%esp)
  800315:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800317:	83 ee 01             	sub    $0x1,%esi
  80031a:	75 ef                	jne    80030b <printnum+0x9b>
  80031c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800323:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800327:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80032a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80032e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800335:	00 
  800336:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800339:	89 1c 24             	mov    %ebx,(%esp)
  80033c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80033f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800343:	e8 18 0f 00 00       	call   801260 <__umoddi3>
  800348:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80034c:	0f be 80 9b 14 80 00 	movsbl 0x80149b(%eax),%eax
  800353:	89 04 24             	mov    %eax,(%esp)
  800356:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800359:	ff d0                	call   *%eax
}
  80035b:	83 c4 4c             	add    $0x4c,%esp
  80035e:	5b                   	pop    %ebx
  80035f:	5e                   	pop    %esi
  800360:	5f                   	pop    %edi
  800361:	5d                   	pop    %ebp
  800362:	c3                   	ret    

00800363 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800363:	55                   	push   %ebp
  800364:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800366:	83 fa 01             	cmp    $0x1,%edx
  800369:	7e 0e                	jle    800379 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80036b:	8b 10                	mov    (%eax),%edx
  80036d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800370:	89 08                	mov    %ecx,(%eax)
  800372:	8b 02                	mov    (%edx),%eax
  800374:	8b 52 04             	mov    0x4(%edx),%edx
  800377:	eb 22                	jmp    80039b <getuint+0x38>
	else if (lflag)
  800379:	85 d2                	test   %edx,%edx
  80037b:	74 10                	je     80038d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80037d:	8b 10                	mov    (%eax),%edx
  80037f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800382:	89 08                	mov    %ecx,(%eax)
  800384:	8b 02                	mov    (%edx),%eax
  800386:	ba 00 00 00 00       	mov    $0x0,%edx
  80038b:	eb 0e                	jmp    80039b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80038d:	8b 10                	mov    (%eax),%edx
  80038f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800392:	89 08                	mov    %ecx,(%eax)
  800394:	8b 02                	mov    (%edx),%eax
  800396:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80039b:	5d                   	pop    %ebp
  80039c:	c3                   	ret    

0080039d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80039d:	55                   	push   %ebp
  80039e:	89 e5                	mov    %esp,%ebp
  8003a0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003a3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003a7:	8b 10                	mov    (%eax),%edx
  8003a9:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ac:	73 0a                	jae    8003b8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b1:	88 0a                	mov    %cl,(%edx)
  8003b3:	83 c2 01             	add    $0x1,%edx
  8003b6:	89 10                	mov    %edx,(%eax)
}
  8003b8:	5d                   	pop    %ebp
  8003b9:	c3                   	ret    

008003ba <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ba:	55                   	push   %ebp
  8003bb:	89 e5                	mov    %esp,%ebp
  8003bd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003c0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d8:	89 04 24             	mov    %eax,(%esp)
  8003db:	e8 02 00 00 00       	call   8003e2 <vprintfmt>
	va_end(ap);
}
  8003e0:	c9                   	leave  
  8003e1:	c3                   	ret    

008003e2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003e2:	55                   	push   %ebp
  8003e3:	89 e5                	mov    %esp,%ebp
  8003e5:	57                   	push   %edi
  8003e6:	56                   	push   %esi
  8003e7:	53                   	push   %ebx
  8003e8:	83 ec 4c             	sub    $0x4c,%esp
  8003eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003f1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003f4:	eb 11                	jmp    800407 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003f6:	85 c0                	test   %eax,%eax
  8003f8:	0f 84 db 03 00 00    	je     8007d9 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  8003fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800402:	89 04 24             	mov    %eax,(%esp)
  800405:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800407:	0f b6 07             	movzbl (%edi),%eax
  80040a:	83 c7 01             	add    $0x1,%edi
  80040d:	83 f8 25             	cmp    $0x25,%eax
  800410:	75 e4                	jne    8003f6 <vprintfmt+0x14>
  800412:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800416:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80041d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800424:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80042b:	ba 00 00 00 00       	mov    $0x0,%edx
  800430:	eb 2b                	jmp    80045d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800435:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800439:	eb 22                	jmp    80045d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80043e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  800442:	eb 19                	jmp    80045d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800447:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80044e:	eb 0d                	jmp    80045d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800450:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800453:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800456:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045d:	0f b6 0f             	movzbl (%edi),%ecx
  800460:	8d 47 01             	lea    0x1(%edi),%eax
  800463:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800466:	0f b6 07             	movzbl (%edi),%eax
  800469:	83 e8 23             	sub    $0x23,%eax
  80046c:	3c 55                	cmp    $0x55,%al
  80046e:	0f 87 40 03 00 00    	ja     8007b4 <vprintfmt+0x3d2>
  800474:	0f b6 c0             	movzbl %al,%eax
  800477:	ff 24 85 60 15 80 00 	jmp    *0x801560(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80047e:	83 e9 30             	sub    $0x30,%ecx
  800481:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  800484:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  800488:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80048b:	83 f9 09             	cmp    $0x9,%ecx
  80048e:	77 57                	ja     8004e7 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800490:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800493:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800496:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800499:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80049c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80049f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8004a3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8004a6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004a9:	83 f9 09             	cmp    $0x9,%ecx
  8004ac:	76 eb                	jbe    800499 <vprintfmt+0xb7>
  8004ae:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004b1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004b4:	eb 34                	jmp    8004ea <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b9:	8d 48 04             	lea    0x4(%eax),%ecx
  8004bc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004bf:	8b 00                	mov    (%eax),%eax
  8004c1:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004c7:	eb 21                	jmp    8004ea <vprintfmt+0x108>

		case '.':
			if (width < 0)
  8004c9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004cd:	0f 88 71 ff ff ff    	js     800444 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004d6:	eb 85                	jmp    80045d <vprintfmt+0x7b>
  8004d8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004db:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8004e2:	e9 76 ff ff ff       	jmp    80045d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e7:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004ea:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ee:	0f 89 69 ff ff ff    	jns    80045d <vprintfmt+0x7b>
  8004f4:	e9 57 ff ff ff       	jmp    800450 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004f9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fc:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004ff:	e9 59 ff ff ff       	jmp    80045d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800504:	8b 45 14             	mov    0x14(%ebp),%eax
  800507:	8d 50 04             	lea    0x4(%eax),%edx
  80050a:	89 55 14             	mov    %edx,0x14(%ebp)
  80050d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800511:	8b 00                	mov    (%eax),%eax
  800513:	89 04 24             	mov    %eax,(%esp)
  800516:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800518:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80051b:	e9 e7 fe ff ff       	jmp    800407 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8d 50 04             	lea    0x4(%eax),%edx
  800526:	89 55 14             	mov    %edx,0x14(%ebp)
  800529:	8b 00                	mov    (%eax),%eax
  80052b:	89 c2                	mov    %eax,%edx
  80052d:	c1 fa 1f             	sar    $0x1f,%edx
  800530:	31 d0                	xor    %edx,%eax
  800532:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800534:	83 f8 08             	cmp    $0x8,%eax
  800537:	7f 0b                	jg     800544 <vprintfmt+0x162>
  800539:	8b 14 85 c0 16 80 00 	mov    0x8016c0(,%eax,4),%edx
  800540:	85 d2                	test   %edx,%edx
  800542:	75 20                	jne    800564 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800544:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800548:	c7 44 24 08 b3 14 80 	movl   $0x8014b3,0x8(%esp)
  80054f:	00 
  800550:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800554:	89 34 24             	mov    %esi,(%esp)
  800557:	e8 5e fe ff ff       	call   8003ba <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80055f:	e9 a3 fe ff ff       	jmp    800407 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800564:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800568:	c7 44 24 08 bc 14 80 	movl   $0x8014bc,0x8(%esp)
  80056f:	00 
  800570:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800574:	89 34 24             	mov    %esi,(%esp)
  800577:	e8 3e fe ff ff       	call   8003ba <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80057f:	e9 83 fe ff ff       	jmp    800407 <vprintfmt+0x25>
  800584:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800587:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80058a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8d 50 04             	lea    0x4(%eax),%edx
  800593:	89 55 14             	mov    %edx,0x14(%ebp)
  800596:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800598:	85 ff                	test   %edi,%edi
  80059a:	b8 ac 14 80 00       	mov    $0x8014ac,%eax
  80059f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005a2:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  8005a6:	74 06                	je     8005ae <vprintfmt+0x1cc>
  8005a8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005ac:	7f 16                	jg     8005c4 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ae:	0f b6 17             	movzbl (%edi),%edx
  8005b1:	0f be c2             	movsbl %dl,%eax
  8005b4:	83 c7 01             	add    $0x1,%edi
  8005b7:	85 c0                	test   %eax,%eax
  8005b9:	0f 85 9f 00 00 00    	jne    80065e <vprintfmt+0x27c>
  8005bf:	e9 8b 00 00 00       	jmp    80064f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005c8:	89 3c 24             	mov    %edi,(%esp)
  8005cb:	e8 c2 02 00 00       	call   800892 <strnlen>
  8005d0:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005d3:	29 c2                	sub    %eax,%edx
  8005d5:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005d8:	85 d2                	test   %edx,%edx
  8005da:	7e d2                	jle    8005ae <vprintfmt+0x1cc>
					putch(padc, putdat);
  8005dc:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  8005e0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8005e3:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005e6:	89 d7                	mov    %edx,%edi
  8005e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005ef:	89 04 24             	mov    %eax,(%esp)
  8005f2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f4:	83 ef 01             	sub    $0x1,%edi
  8005f7:	75 ef                	jne    8005e8 <vprintfmt+0x206>
  8005f9:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8005fc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005ff:	eb ad                	jmp    8005ae <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800601:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800605:	74 20                	je     800627 <vprintfmt+0x245>
  800607:	0f be d2             	movsbl %dl,%edx
  80060a:	83 ea 20             	sub    $0x20,%edx
  80060d:	83 fa 5e             	cmp    $0x5e,%edx
  800610:	76 15                	jbe    800627 <vprintfmt+0x245>
					putch('?', putdat);
  800612:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800615:	89 54 24 04          	mov    %edx,0x4(%esp)
  800619:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800620:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800623:	ff d1                	call   *%ecx
  800625:	eb 0f                	jmp    800636 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800627:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80062a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80062e:	89 04 24             	mov    %eax,(%esp)
  800631:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800634:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800636:	83 eb 01             	sub    $0x1,%ebx
  800639:	0f b6 17             	movzbl (%edi),%edx
  80063c:	0f be c2             	movsbl %dl,%eax
  80063f:	83 c7 01             	add    $0x1,%edi
  800642:	85 c0                	test   %eax,%eax
  800644:	75 24                	jne    80066a <vprintfmt+0x288>
  800646:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800649:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80064c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800652:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800656:	0f 8e ab fd ff ff    	jle    800407 <vprintfmt+0x25>
  80065c:	eb 20                	jmp    80067e <vprintfmt+0x29c>
  80065e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800661:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800664:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800667:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80066a:	85 f6                	test   %esi,%esi
  80066c:	78 93                	js     800601 <vprintfmt+0x21f>
  80066e:	83 ee 01             	sub    $0x1,%esi
  800671:	79 8e                	jns    800601 <vprintfmt+0x21f>
  800673:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800676:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800679:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80067c:	eb d1                	jmp    80064f <vprintfmt+0x26d>
  80067e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800681:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800685:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80068c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80068e:	83 ef 01             	sub    $0x1,%edi
  800691:	75 ee                	jne    800681 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800693:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800696:	e9 6c fd ff ff       	jmp    800407 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80069b:	83 fa 01             	cmp    $0x1,%edx
  80069e:	66 90                	xchg   %ax,%ax
  8006a0:	7e 16                	jle    8006b8 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8d 50 08             	lea    0x8(%eax),%edx
  8006a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ab:	8b 10                	mov    (%eax),%edx
  8006ad:	8b 48 04             	mov    0x4(%eax),%ecx
  8006b0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006b3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006b6:	eb 32                	jmp    8006ea <vprintfmt+0x308>
	else if (lflag)
  8006b8:	85 d2                	test   %edx,%edx
  8006ba:	74 18                	je     8006d4 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  8006bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bf:	8d 50 04             	lea    0x4(%eax),%edx
  8006c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c5:	8b 00                	mov    (%eax),%eax
  8006c7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006ca:	89 c1                	mov    %eax,%ecx
  8006cc:	c1 f9 1f             	sar    $0x1f,%ecx
  8006cf:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006d2:	eb 16                	jmp    8006ea <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8d 50 04             	lea    0x4(%eax),%edx
  8006da:	89 55 14             	mov    %edx,0x14(%ebp)
  8006dd:	8b 00                	mov    (%eax),%eax
  8006df:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006e2:	89 c7                	mov    %eax,%edi
  8006e4:	c1 ff 1f             	sar    $0x1f,%edi
  8006e7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006ea:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006ed:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006f0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006f5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006f9:	79 7d                	jns    800778 <vprintfmt+0x396>
				putch('-', putdat);
  8006fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ff:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800706:	ff d6                	call   *%esi
				num = -(long long) num;
  800708:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80070b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80070e:	f7 d8                	neg    %eax
  800710:	83 d2 00             	adc    $0x0,%edx
  800713:	f7 da                	neg    %edx
			}
			base = 10;
  800715:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80071a:	eb 5c                	jmp    800778 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80071c:	8d 45 14             	lea    0x14(%ebp),%eax
  80071f:	e8 3f fc ff ff       	call   800363 <getuint>
			base = 10;
  800724:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800729:	eb 4d                	jmp    800778 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80072b:	8d 45 14             	lea    0x14(%ebp),%eax
  80072e:	e8 30 fc ff ff       	call   800363 <getuint>
			base = 8;
  800733:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800738:	eb 3e                	jmp    800778 <vprintfmt+0x396>

		// pointer
		case 'p':
			putch('0', putdat);
  80073a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800745:	ff d6                	call   *%esi
			putch('x', putdat);
  800747:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800752:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800754:	8b 45 14             	mov    0x14(%ebp),%eax
  800757:	8d 50 04             	lea    0x4(%eax),%edx
  80075a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80075d:	8b 00                	mov    (%eax),%eax
  80075f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800764:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800769:	eb 0d                	jmp    800778 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80076b:	8d 45 14             	lea    0x14(%ebp),%eax
  80076e:	e8 f0 fb ff ff       	call   800363 <getuint>
			base = 16;
  800773:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800778:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  80077c:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800780:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800783:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800787:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80078b:	89 04 24             	mov    %eax,(%esp)
  80078e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800792:	89 da                	mov    %ebx,%edx
  800794:	89 f0                	mov    %esi,%eax
  800796:	e8 d5 fa ff ff       	call   800270 <printnum>
			break;
  80079b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80079e:	e9 64 fc ff ff       	jmp    800407 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a7:	89 0c 24             	mov    %ecx,(%esp)
  8007aa:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ac:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007af:	e9 53 fc ff ff       	jmp    800407 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007bf:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007c5:	0f 84 3c fc ff ff    	je     800407 <vprintfmt+0x25>
  8007cb:	83 ef 01             	sub    $0x1,%edi
  8007ce:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007d2:	75 f7                	jne    8007cb <vprintfmt+0x3e9>
  8007d4:	e9 2e fc ff ff       	jmp    800407 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8007d9:	83 c4 4c             	add    $0x4c,%esp
  8007dc:	5b                   	pop    %ebx
  8007dd:	5e                   	pop    %esi
  8007de:	5f                   	pop    %edi
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	83 ec 28             	sub    $0x28,%esp
  8007e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007f0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007f4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007fe:	85 d2                	test   %edx,%edx
  800800:	7e 30                	jle    800832 <vsnprintf+0x51>
  800802:	85 c0                	test   %eax,%eax
  800804:	74 2c                	je     800832 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800806:	8b 45 14             	mov    0x14(%ebp),%eax
  800809:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80080d:	8b 45 10             	mov    0x10(%ebp),%eax
  800810:	89 44 24 08          	mov    %eax,0x8(%esp)
  800814:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800817:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081b:	c7 04 24 9d 03 80 00 	movl   $0x80039d,(%esp)
  800822:	e8 bb fb ff ff       	call   8003e2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800827:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80082a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80082d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800830:	eb 05                	jmp    800837 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800832:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800837:	c9                   	leave  
  800838:	c3                   	ret    

00800839 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80083f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800842:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800846:	8b 45 10             	mov    0x10(%ebp),%eax
  800849:	89 44 24 08          	mov    %eax,0x8(%esp)
  80084d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800850:	89 44 24 04          	mov    %eax,0x4(%esp)
  800854:	8b 45 08             	mov    0x8(%ebp),%eax
  800857:	89 04 24             	mov    %eax,(%esp)
  80085a:	e8 82 ff ff ff       	call   8007e1 <vsnprintf>
	va_end(ap);

	return rc;
}
  80085f:	c9                   	leave  
  800860:	c3                   	ret    
  800861:	66 90                	xchg   %ax,%ax
  800863:	66 90                	xchg   %ax,%ax
  800865:	66 90                	xchg   %ax,%ax
  800867:	66 90                	xchg   %ax,%ax
  800869:	66 90                	xchg   %ax,%ax
  80086b:	66 90                	xchg   %ax,%ax
  80086d:	66 90                	xchg   %ax,%ax
  80086f:	90                   	nop

00800870 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800876:	80 3a 00             	cmpb   $0x0,(%edx)
  800879:	74 10                	je     80088b <strlen+0x1b>
  80087b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800880:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800883:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800887:	75 f7                	jne    800880 <strlen+0x10>
  800889:	eb 05                	jmp    800890 <strlen+0x20>
  80088b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    

00800892 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	53                   	push   %ebx
  800896:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800899:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089c:	85 c9                	test   %ecx,%ecx
  80089e:	74 1c                	je     8008bc <strnlen+0x2a>
  8008a0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008a3:	74 1e                	je     8008c3 <strnlen+0x31>
  8008a5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8008aa:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ac:	39 ca                	cmp    %ecx,%edx
  8008ae:	74 18                	je     8008c8 <strnlen+0x36>
  8008b0:	83 c2 01             	add    $0x1,%edx
  8008b3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008b8:	75 f0                	jne    8008aa <strnlen+0x18>
  8008ba:	eb 0c                	jmp    8008c8 <strnlen+0x36>
  8008bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c1:	eb 05                	jmp    8008c8 <strnlen+0x36>
  8008c3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008c8:	5b                   	pop    %ebx
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	53                   	push   %ebx
  8008cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008d5:	89 c2                	mov    %eax,%edx
  8008d7:	0f b6 19             	movzbl (%ecx),%ebx
  8008da:	88 1a                	mov    %bl,(%edx)
  8008dc:	83 c2 01             	add    $0x1,%edx
  8008df:	83 c1 01             	add    $0x1,%ecx
  8008e2:	84 db                	test   %bl,%bl
  8008e4:	75 f1                	jne    8008d7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008e6:	5b                   	pop    %ebx
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	53                   	push   %ebx
  8008ed:	83 ec 08             	sub    $0x8,%esp
  8008f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008f3:	89 1c 24             	mov    %ebx,(%esp)
  8008f6:	e8 75 ff ff ff       	call   800870 <strlen>
	strcpy(dst + len, src);
  8008fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  800902:	01 d8                	add    %ebx,%eax
  800904:	89 04 24             	mov    %eax,(%esp)
  800907:	e8 bf ff ff ff       	call   8008cb <strcpy>
	return dst;
}
  80090c:	89 d8                	mov    %ebx,%eax
  80090e:	83 c4 08             	add    $0x8,%esp
  800911:	5b                   	pop    %ebx
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	56                   	push   %esi
  800918:	53                   	push   %ebx
  800919:	8b 75 08             	mov    0x8(%ebp),%esi
  80091c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800922:	85 db                	test   %ebx,%ebx
  800924:	74 16                	je     80093c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800926:	01 f3                	add    %esi,%ebx
  800928:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80092a:	0f b6 02             	movzbl (%edx),%eax
  80092d:	88 01                	mov    %al,(%ecx)
  80092f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800932:	80 3a 01             	cmpb   $0x1,(%edx)
  800935:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800938:	39 d9                	cmp    %ebx,%ecx
  80093a:	75 ee                	jne    80092a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80093c:	89 f0                	mov    %esi,%eax
  80093e:	5b                   	pop    %ebx
  80093f:	5e                   	pop    %esi
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	57                   	push   %edi
  800946:	56                   	push   %esi
  800947:	53                   	push   %ebx
  800948:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80094e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800951:	89 f8                	mov    %edi,%eax
  800953:	85 f6                	test   %esi,%esi
  800955:	74 33                	je     80098a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800957:	83 fe 01             	cmp    $0x1,%esi
  80095a:	74 25                	je     800981 <strlcpy+0x3f>
  80095c:	0f b6 0b             	movzbl (%ebx),%ecx
  80095f:	84 c9                	test   %cl,%cl
  800961:	74 22                	je     800985 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800963:	83 ee 02             	sub    $0x2,%esi
  800966:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80096b:	88 08                	mov    %cl,(%eax)
  80096d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800970:	39 f2                	cmp    %esi,%edx
  800972:	74 13                	je     800987 <strlcpy+0x45>
  800974:	83 c2 01             	add    $0x1,%edx
  800977:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80097b:	84 c9                	test   %cl,%cl
  80097d:	75 ec                	jne    80096b <strlcpy+0x29>
  80097f:	eb 06                	jmp    800987 <strlcpy+0x45>
  800981:	89 f8                	mov    %edi,%eax
  800983:	eb 02                	jmp    800987 <strlcpy+0x45>
  800985:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800987:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80098a:	29 f8                	sub    %edi,%eax
}
  80098c:	5b                   	pop    %ebx
  80098d:	5e                   	pop    %esi
  80098e:	5f                   	pop    %edi
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800997:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80099a:	0f b6 01             	movzbl (%ecx),%eax
  80099d:	84 c0                	test   %al,%al
  80099f:	74 15                	je     8009b6 <strcmp+0x25>
  8009a1:	3a 02                	cmp    (%edx),%al
  8009a3:	75 11                	jne    8009b6 <strcmp+0x25>
		p++, q++;
  8009a5:	83 c1 01             	add    $0x1,%ecx
  8009a8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009ab:	0f b6 01             	movzbl (%ecx),%eax
  8009ae:	84 c0                	test   %al,%al
  8009b0:	74 04                	je     8009b6 <strcmp+0x25>
  8009b2:	3a 02                	cmp    (%edx),%al
  8009b4:	74 ef                	je     8009a5 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b6:	0f b6 c0             	movzbl %al,%eax
  8009b9:	0f b6 12             	movzbl (%edx),%edx
  8009bc:	29 d0                	sub    %edx,%eax
}
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	56                   	push   %esi
  8009c4:	53                   	push   %ebx
  8009c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cb:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8009ce:	85 f6                	test   %esi,%esi
  8009d0:	74 29                	je     8009fb <strncmp+0x3b>
  8009d2:	0f b6 03             	movzbl (%ebx),%eax
  8009d5:	84 c0                	test   %al,%al
  8009d7:	74 30                	je     800a09 <strncmp+0x49>
  8009d9:	3a 02                	cmp    (%edx),%al
  8009db:	75 2c                	jne    800a09 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  8009dd:	8d 43 01             	lea    0x1(%ebx),%eax
  8009e0:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8009e2:	89 c3                	mov    %eax,%ebx
  8009e4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009e7:	39 f0                	cmp    %esi,%eax
  8009e9:	74 17                	je     800a02 <strncmp+0x42>
  8009eb:	0f b6 08             	movzbl (%eax),%ecx
  8009ee:	84 c9                	test   %cl,%cl
  8009f0:	74 17                	je     800a09 <strncmp+0x49>
  8009f2:	83 c0 01             	add    $0x1,%eax
  8009f5:	3a 0a                	cmp    (%edx),%cl
  8009f7:	74 e9                	je     8009e2 <strncmp+0x22>
  8009f9:	eb 0e                	jmp    800a09 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800a00:	eb 0f                	jmp    800a11 <strncmp+0x51>
  800a02:	b8 00 00 00 00       	mov    $0x0,%eax
  800a07:	eb 08                	jmp    800a11 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a09:	0f b6 03             	movzbl (%ebx),%eax
  800a0c:	0f b6 12             	movzbl (%edx),%edx
  800a0f:	29 d0                	sub    %edx,%eax
}
  800a11:	5b                   	pop    %ebx
  800a12:	5e                   	pop    %esi
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	53                   	push   %ebx
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a1f:	0f b6 18             	movzbl (%eax),%ebx
  800a22:	84 db                	test   %bl,%bl
  800a24:	74 1d                	je     800a43 <strchr+0x2e>
  800a26:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a28:	38 d3                	cmp    %dl,%bl
  800a2a:	75 06                	jne    800a32 <strchr+0x1d>
  800a2c:	eb 1a                	jmp    800a48 <strchr+0x33>
  800a2e:	38 ca                	cmp    %cl,%dl
  800a30:	74 16                	je     800a48 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a32:	83 c0 01             	add    $0x1,%eax
  800a35:	0f b6 10             	movzbl (%eax),%edx
  800a38:	84 d2                	test   %dl,%dl
  800a3a:	75 f2                	jne    800a2e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800a3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a41:	eb 05                	jmp    800a48 <strchr+0x33>
  800a43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a48:	5b                   	pop    %ebx
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	53                   	push   %ebx
  800a4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a52:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a55:	0f b6 18             	movzbl (%eax),%ebx
  800a58:	84 db                	test   %bl,%bl
  800a5a:	74 16                	je     800a72 <strfind+0x27>
  800a5c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a5e:	38 d3                	cmp    %dl,%bl
  800a60:	75 06                	jne    800a68 <strfind+0x1d>
  800a62:	eb 0e                	jmp    800a72 <strfind+0x27>
  800a64:	38 ca                	cmp    %cl,%dl
  800a66:	74 0a                	je     800a72 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a68:	83 c0 01             	add    $0x1,%eax
  800a6b:	0f b6 10             	movzbl (%eax),%edx
  800a6e:	84 d2                	test   %dl,%dl
  800a70:	75 f2                	jne    800a64 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800a72:	5b                   	pop    %ebx
  800a73:	5d                   	pop    %ebp
  800a74:	c3                   	ret    

00800a75 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	83 ec 0c             	sub    $0xc,%esp
  800a7b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a7e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a81:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a84:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a87:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a8a:	85 c9                	test   %ecx,%ecx
  800a8c:	74 36                	je     800ac4 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a8e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a94:	75 28                	jne    800abe <memset+0x49>
  800a96:	f6 c1 03             	test   $0x3,%cl
  800a99:	75 23                	jne    800abe <memset+0x49>
		c &= 0xFF;
  800a9b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a9f:	89 d3                	mov    %edx,%ebx
  800aa1:	c1 e3 08             	shl    $0x8,%ebx
  800aa4:	89 d6                	mov    %edx,%esi
  800aa6:	c1 e6 18             	shl    $0x18,%esi
  800aa9:	89 d0                	mov    %edx,%eax
  800aab:	c1 e0 10             	shl    $0x10,%eax
  800aae:	09 f0                	or     %esi,%eax
  800ab0:	09 c2                	or     %eax,%edx
  800ab2:	89 d0                	mov    %edx,%eax
  800ab4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ab6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ab9:	fc                   	cld    
  800aba:	f3 ab                	rep stos %eax,%es:(%edi)
  800abc:	eb 06                	jmp    800ac4 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800abe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac1:	fc                   	cld    
  800ac2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ac4:	89 f8                	mov    %edi,%eax
  800ac6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ac9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800acc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800acf:	89 ec                	mov    %ebp,%esp
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    

00800ad3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	83 ec 08             	sub    $0x8,%esp
  800ad9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800adc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800adf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ae8:	39 c6                	cmp    %eax,%esi
  800aea:	73 36                	jae    800b22 <memmove+0x4f>
  800aec:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aef:	39 d0                	cmp    %edx,%eax
  800af1:	73 2f                	jae    800b22 <memmove+0x4f>
		s += n;
		d += n;
  800af3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af6:	f6 c2 03             	test   $0x3,%dl
  800af9:	75 1b                	jne    800b16 <memmove+0x43>
  800afb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b01:	75 13                	jne    800b16 <memmove+0x43>
  800b03:	f6 c1 03             	test   $0x3,%cl
  800b06:	75 0e                	jne    800b16 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b08:	83 ef 04             	sub    $0x4,%edi
  800b0b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b0e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b11:	fd                   	std    
  800b12:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b14:	eb 09                	jmp    800b1f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b16:	83 ef 01             	sub    $0x1,%edi
  800b19:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b1c:	fd                   	std    
  800b1d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b1f:	fc                   	cld    
  800b20:	eb 20                	jmp    800b42 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b22:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b28:	75 13                	jne    800b3d <memmove+0x6a>
  800b2a:	a8 03                	test   $0x3,%al
  800b2c:	75 0f                	jne    800b3d <memmove+0x6a>
  800b2e:	f6 c1 03             	test   $0x3,%cl
  800b31:	75 0a                	jne    800b3d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b33:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b36:	89 c7                	mov    %eax,%edi
  800b38:	fc                   	cld    
  800b39:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b3b:	eb 05                	jmp    800b42 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b3d:	89 c7                	mov    %eax,%edi
  800b3f:	fc                   	cld    
  800b40:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b42:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b45:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b48:	89 ec                	mov    %ebp,%esp
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b52:	8b 45 10             	mov    0x10(%ebp),%eax
  800b55:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b59:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b60:	8b 45 08             	mov    0x8(%ebp),%eax
  800b63:	89 04 24             	mov    %eax,(%esp)
  800b66:	e8 68 ff ff ff       	call   800ad3 <memmove>
}
  800b6b:	c9                   	leave  
  800b6c:	c3                   	ret    

00800b6d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	57                   	push   %edi
  800b71:	56                   	push   %esi
  800b72:	53                   	push   %ebx
  800b73:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b76:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b79:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b7c:	8d 78 ff             	lea    -0x1(%eax),%edi
  800b7f:	85 c0                	test   %eax,%eax
  800b81:	74 36                	je     800bb9 <memcmp+0x4c>
		if (*s1 != *s2)
  800b83:	0f b6 03             	movzbl (%ebx),%eax
  800b86:	0f b6 0e             	movzbl (%esi),%ecx
  800b89:	38 c8                	cmp    %cl,%al
  800b8b:	75 17                	jne    800ba4 <memcmp+0x37>
  800b8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b92:	eb 1a                	jmp    800bae <memcmp+0x41>
  800b94:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b99:	83 c2 01             	add    $0x1,%edx
  800b9c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800ba0:	38 c8                	cmp    %cl,%al
  800ba2:	74 0a                	je     800bae <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800ba4:	0f b6 c0             	movzbl %al,%eax
  800ba7:	0f b6 c9             	movzbl %cl,%ecx
  800baa:	29 c8                	sub    %ecx,%eax
  800bac:	eb 10                	jmp    800bbe <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bae:	39 fa                	cmp    %edi,%edx
  800bb0:	75 e2                	jne    800b94 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb7:	eb 05                	jmp    800bbe <memcmp+0x51>
  800bb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	53                   	push   %ebx
  800bc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800bcd:	89 c2                	mov    %eax,%edx
  800bcf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bd2:	39 d0                	cmp    %edx,%eax
  800bd4:	73 13                	jae    800be9 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd6:	89 d9                	mov    %ebx,%ecx
  800bd8:	38 18                	cmp    %bl,(%eax)
  800bda:	75 06                	jne    800be2 <memfind+0x1f>
  800bdc:	eb 0b                	jmp    800be9 <memfind+0x26>
  800bde:	38 08                	cmp    %cl,(%eax)
  800be0:	74 07                	je     800be9 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800be2:	83 c0 01             	add    $0x1,%eax
  800be5:	39 d0                	cmp    %edx,%eax
  800be7:	75 f5                	jne    800bde <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800be9:	5b                   	pop    %ebx
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	57                   	push   %edi
  800bf0:	56                   	push   %esi
  800bf1:	53                   	push   %ebx
  800bf2:	83 ec 04             	sub    $0x4,%esp
  800bf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bfb:	0f b6 02             	movzbl (%edx),%eax
  800bfe:	3c 09                	cmp    $0x9,%al
  800c00:	74 04                	je     800c06 <strtol+0x1a>
  800c02:	3c 20                	cmp    $0x20,%al
  800c04:	75 0e                	jne    800c14 <strtol+0x28>
		s++;
  800c06:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c09:	0f b6 02             	movzbl (%edx),%eax
  800c0c:	3c 09                	cmp    $0x9,%al
  800c0e:	74 f6                	je     800c06 <strtol+0x1a>
  800c10:	3c 20                	cmp    $0x20,%al
  800c12:	74 f2                	je     800c06 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c14:	3c 2b                	cmp    $0x2b,%al
  800c16:	75 0a                	jne    800c22 <strtol+0x36>
		s++;
  800c18:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c1b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c20:	eb 10                	jmp    800c32 <strtol+0x46>
  800c22:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c27:	3c 2d                	cmp    $0x2d,%al
  800c29:	75 07                	jne    800c32 <strtol+0x46>
		s++, neg = 1;
  800c2b:	83 c2 01             	add    $0x1,%edx
  800c2e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c32:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c38:	75 15                	jne    800c4f <strtol+0x63>
  800c3a:	80 3a 30             	cmpb   $0x30,(%edx)
  800c3d:	75 10                	jne    800c4f <strtol+0x63>
  800c3f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c43:	75 0a                	jne    800c4f <strtol+0x63>
		s += 2, base = 16;
  800c45:	83 c2 02             	add    $0x2,%edx
  800c48:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c4d:	eb 10                	jmp    800c5f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800c4f:	85 db                	test   %ebx,%ebx
  800c51:	75 0c                	jne    800c5f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c53:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c55:	80 3a 30             	cmpb   $0x30,(%edx)
  800c58:	75 05                	jne    800c5f <strtol+0x73>
		s++, base = 8;
  800c5a:	83 c2 01             	add    $0x1,%edx
  800c5d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c64:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c67:	0f b6 0a             	movzbl (%edx),%ecx
  800c6a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c6d:	89 f3                	mov    %esi,%ebx
  800c6f:	80 fb 09             	cmp    $0x9,%bl
  800c72:	77 08                	ja     800c7c <strtol+0x90>
			dig = *s - '0';
  800c74:	0f be c9             	movsbl %cl,%ecx
  800c77:	83 e9 30             	sub    $0x30,%ecx
  800c7a:	eb 22                	jmp    800c9e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800c7c:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c7f:	89 f3                	mov    %esi,%ebx
  800c81:	80 fb 19             	cmp    $0x19,%bl
  800c84:	77 08                	ja     800c8e <strtol+0xa2>
			dig = *s - 'a' + 10;
  800c86:	0f be c9             	movsbl %cl,%ecx
  800c89:	83 e9 57             	sub    $0x57,%ecx
  800c8c:	eb 10                	jmp    800c9e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800c8e:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c91:	89 f3                	mov    %esi,%ebx
  800c93:	80 fb 19             	cmp    $0x19,%bl
  800c96:	77 16                	ja     800cae <strtol+0xc2>
			dig = *s - 'A' + 10;
  800c98:	0f be c9             	movsbl %cl,%ecx
  800c9b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c9e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800ca1:	7d 0f                	jge    800cb2 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800ca3:	83 c2 01             	add    $0x1,%edx
  800ca6:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800caa:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800cac:	eb b9                	jmp    800c67 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800cae:	89 c1                	mov    %eax,%ecx
  800cb0:	eb 02                	jmp    800cb4 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cb2:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800cb4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cb8:	74 05                	je     800cbf <strtol+0xd3>
		*endptr = (char *) s;
  800cba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cbd:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800cbf:	89 ca                	mov    %ecx,%edx
  800cc1:	f7 da                	neg    %edx
  800cc3:	85 ff                	test   %edi,%edi
  800cc5:	0f 45 c2             	cmovne %edx,%eax
}
  800cc8:	83 c4 04             	add    $0x4,%esp
  800ccb:	5b                   	pop    %ebx
  800ccc:	5e                   	pop    %esi
  800ccd:	5f                   	pop    %edi
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	83 ec 0c             	sub    $0xc,%esp
  800cd6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cd9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cdc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cea:	89 c3                	mov    %eax,%ebx
  800cec:	89 c7                	mov    %eax,%edi
  800cee:	89 c6                	mov    %eax,%esi
  800cf0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cf2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cf5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cf8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cfb:	89 ec                	mov    %ebp,%esp
  800cfd:	5d                   	pop    %ebp
  800cfe:	c3                   	ret    

00800cff <sys_cgetc>:

int
sys_cgetc(void)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d08:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d0b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d13:	b8 01 00 00 00       	mov    $0x1,%eax
  800d18:	89 d1                	mov    %edx,%ecx
  800d1a:	89 d3                	mov    %edx,%ebx
  800d1c:	89 d7                	mov    %edx,%edi
  800d1e:	89 d6                	mov    %edx,%esi
  800d20:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d22:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d25:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d28:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d2b:	89 ec                	mov    %ebp,%esp
  800d2d:	5d                   	pop    %ebp
  800d2e:	c3                   	ret    

00800d2f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	83 ec 38             	sub    $0x38,%esp
  800d35:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d38:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d3b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d43:	b8 03 00 00 00       	mov    $0x3,%eax
  800d48:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4b:	89 cb                	mov    %ecx,%ebx
  800d4d:	89 cf                	mov    %ecx,%edi
  800d4f:	89 ce                	mov    %ecx,%esi
  800d51:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d53:	85 c0                	test   %eax,%eax
  800d55:	7e 28                	jle    800d7f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d57:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d62:	00 
  800d63:	c7 44 24 08 e4 16 80 	movl   $0x8016e4,0x8(%esp)
  800d6a:	00 
  800d6b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d72:	00 
  800d73:	c7 04 24 01 17 80 00 	movl   $0x801701,(%esp)
  800d7a:	e8 d5 f3 ff ff       	call   800154 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d7f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d82:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d85:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d88:	89 ec                	mov    %ebp,%esp
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	83 ec 0c             	sub    $0xc,%esp
  800d92:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d95:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d98:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800da0:	b8 02 00 00 00       	mov    $0x2,%eax
  800da5:	89 d1                	mov    %edx,%ecx
  800da7:	89 d3                	mov    %edx,%ebx
  800da9:	89 d7                	mov    %edx,%edi
  800dab:	89 d6                	mov    %edx,%esi
  800dad:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800daf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800db2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800db5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800db8:	89 ec                	mov    %ebp,%esp
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    

00800dbc <sys_yield>:

void
sys_yield(void)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	83 ec 0c             	sub    $0xc,%esp
  800dc2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dc5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dc8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcb:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dd5:	89 d1                	mov    %edx,%ecx
  800dd7:	89 d3                	mov    %edx,%ebx
  800dd9:	89 d7                	mov    %edx,%edi
  800ddb:	89 d6                	mov    %edx,%esi
  800ddd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ddf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800de5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800de8:	89 ec                	mov    %ebp,%esp
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    

00800dec <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	83 ec 38             	sub    $0x38,%esp
  800df2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800df5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800df8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfb:	be 00 00 00 00       	mov    $0x0,%esi
  800e00:	b8 04 00 00 00       	mov    $0x4,%eax
  800e05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e08:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0e:	89 f7                	mov    %esi,%edi
  800e10:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e12:	85 c0                	test   %eax,%eax
  800e14:	7e 28                	jle    800e3e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e16:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e21:	00 
  800e22:	c7 44 24 08 e4 16 80 	movl   $0x8016e4,0x8(%esp)
  800e29:	00 
  800e2a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e31:	00 
  800e32:	c7 04 24 01 17 80 00 	movl   $0x801701,(%esp)
  800e39:	e8 16 f3 ff ff       	call   800154 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e3e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e41:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e44:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e47:	89 ec                	mov    %ebp,%esp
  800e49:	5d                   	pop    %ebp
  800e4a:	c3                   	ret    

00800e4b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	83 ec 38             	sub    $0x38,%esp
  800e51:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e54:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e57:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e62:	8b 55 08             	mov    0x8(%ebp),%edx
  800e65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e68:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e6b:	8b 75 18             	mov    0x18(%ebp),%esi
  800e6e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e70:	85 c0                	test   %eax,%eax
  800e72:	7e 28                	jle    800e9c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e74:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e78:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e7f:	00 
  800e80:	c7 44 24 08 e4 16 80 	movl   $0x8016e4,0x8(%esp)
  800e87:	00 
  800e88:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e8f:	00 
  800e90:	c7 04 24 01 17 80 00 	movl   $0x801701,(%esp)
  800e97:	e8 b8 f2 ff ff       	call   800154 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e9c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e9f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ea5:	89 ec                	mov    %ebp,%esp
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	83 ec 38             	sub    $0x38,%esp
  800eaf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eb2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eb5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ebd:	b8 06 00 00 00       	mov    $0x6,%eax
  800ec2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec8:	89 df                	mov    %ebx,%edi
  800eca:	89 de                	mov    %ebx,%esi
  800ecc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ece:	85 c0                	test   %eax,%eax
  800ed0:	7e 28                	jle    800efa <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800edd:	00 
  800ede:	c7 44 24 08 e4 16 80 	movl   $0x8016e4,0x8(%esp)
  800ee5:	00 
  800ee6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eed:	00 
  800eee:	c7 04 24 01 17 80 00 	movl   $0x801701,(%esp)
  800ef5:	e8 5a f2 ff ff       	call   800154 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800efa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800efd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f00:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f03:	89 ec                	mov    %ebp,%esp
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	83 ec 38             	sub    $0x38,%esp
  800f0d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f10:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f13:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f1b:	b8 08 00 00 00       	mov    $0x8,%eax
  800f20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f23:	8b 55 08             	mov    0x8(%ebp),%edx
  800f26:	89 df                	mov    %ebx,%edi
  800f28:	89 de                	mov    %ebx,%esi
  800f2a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	7e 28                	jle    800f58 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f30:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f34:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f3b:	00 
  800f3c:	c7 44 24 08 e4 16 80 	movl   $0x8016e4,0x8(%esp)
  800f43:	00 
  800f44:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f4b:	00 
  800f4c:	c7 04 24 01 17 80 00 	movl   $0x801701,(%esp)
  800f53:	e8 fc f1 ff ff       	call   800154 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f58:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f5b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f5e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f61:	89 ec                	mov    %ebp,%esp
  800f63:	5d                   	pop    %ebp
  800f64:	c3                   	ret    

00800f65 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
  800f68:	83 ec 38             	sub    $0x38,%esp
  800f6b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f6e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f71:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f74:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f79:	b8 09 00 00 00       	mov    $0x9,%eax
  800f7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f81:	8b 55 08             	mov    0x8(%ebp),%edx
  800f84:	89 df                	mov    %ebx,%edi
  800f86:	89 de                	mov    %ebx,%esi
  800f88:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f8a:	85 c0                	test   %eax,%eax
  800f8c:	7e 28                	jle    800fb6 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f92:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f99:	00 
  800f9a:	c7 44 24 08 e4 16 80 	movl   $0x8016e4,0x8(%esp)
  800fa1:	00 
  800fa2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa9:	00 
  800faa:	c7 04 24 01 17 80 00 	movl   $0x801701,(%esp)
  800fb1:	e8 9e f1 ff ff       	call   800154 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fb6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fb9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fbc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fbf:	89 ec                	mov    %ebp,%esp
  800fc1:	5d                   	pop    %ebp
  800fc2:	c3                   	ret    

00800fc3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fc3:	55                   	push   %ebp
  800fc4:	89 e5                	mov    %esp,%ebp
  800fc6:	83 ec 0c             	sub    $0xc,%esp
  800fc9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fcc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fcf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd2:	be 00 00 00 00       	mov    $0x0,%esi
  800fd7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fe5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fe8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fea:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fed:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ff0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ff3:	89 ec                	mov    %ebp,%esp
  800ff5:	5d                   	pop    %ebp
  800ff6:	c3                   	ret    

00800ff7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	83 ec 38             	sub    $0x38,%esp
  800ffd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801000:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801003:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801006:	b9 00 00 00 00       	mov    $0x0,%ecx
  80100b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801010:	8b 55 08             	mov    0x8(%ebp),%edx
  801013:	89 cb                	mov    %ecx,%ebx
  801015:	89 cf                	mov    %ecx,%edi
  801017:	89 ce                	mov    %ecx,%esi
  801019:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80101b:	85 c0                	test   %eax,%eax
  80101d:	7e 28                	jle    801047 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80101f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801023:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80102a:	00 
  80102b:	c7 44 24 08 e4 16 80 	movl   $0x8016e4,0x8(%esp)
  801032:	00 
  801033:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80103a:	00 
  80103b:	c7 04 24 01 17 80 00 	movl   $0x801701,(%esp)
  801042:	e8 0d f1 ff ff       	call   800154 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801047:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80104a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80104d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801050:	89 ec                	mov    %ebp,%esp
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    

00801054 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80105a:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801061:	75 60                	jne    8010c3 <set_pgfault_handler+0x6f>
		// First time through!
		// LAB 4: Your code here.
		int ret =
  801063:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80106a:	00 
  80106b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801072:	ee 
  801073:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80107a:	e8 6d fd ff ff       	call   800dec <sys_page_alloc>
			sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE),
							PTE_U | PTE_P | PTE_W);
		if (ret < 0) {
  80107f:	85 c0                	test   %eax,%eax
  801081:	79 2c                	jns    8010af <set_pgfault_handler+0x5b>
			cprintf("%e\n", ret);
  801083:	89 44 24 04          	mov    %eax,0x4(%esp)
  801087:	c7 04 24 0f 17 80 00 	movl   $0x80170f,(%esp)
  80108e:	e8 bc f1 ff ff       	call   80024f <cprintf>
			panic("Something wrong with allocation of user exception"
  801093:	c7 44 24 08 24 17 80 	movl   $0x801724,0x8(%esp)
  80109a:	00 
  80109b:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  8010a2:	00 
  8010a3:	c7 04 24 13 17 80 00 	movl   $0x801713,(%esp)
  8010aa:	e8 a5 f0 ff ff       	call   800154 <_panic>
				  "stack\n");
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8010af:	c7 44 24 04 d0 10 80 	movl   $0x8010d0,0x4(%esp)
  8010b6:	00 
  8010b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010be:	e8 a2 fe ff ff       	call   800f65 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8010c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c6:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8010cb:	c9                   	leave  
  8010cc:	c3                   	ret    
  8010cd:	66 90                	xchg   %ax,%ax
  8010cf:	90                   	nop

008010d0 <_pgfault_upcall>:
  8010d0:	54                   	push   %esp
  8010d1:	a1 08 20 80 00       	mov    0x802008,%eax
  8010d6:	ff d0                	call   *%eax
  8010d8:	83 c4 04             	add    $0x4,%esp
  8010db:	58                   	pop    %eax
  8010dc:	58                   	pop    %eax
  8010dd:	83 c4 20             	add    $0x20,%esp
  8010e0:	8b 04 24             	mov    (%esp),%eax
  8010e3:	83 c4 08             	add    $0x8,%esp
  8010e6:	8b 1c 24             	mov    (%esp),%ebx
  8010e9:	83 eb 04             	sub    $0x4,%ebx
  8010ec:	89 1c 24             	mov    %ebx,(%esp)
  8010ef:	89 03                	mov    %eax,(%ebx)
  8010f1:	83 ec 28             	sub    $0x28,%esp
  8010f4:	5f                   	pop    %edi
  8010f5:	5e                   	pop    %esi
  8010f6:	5d                   	pop    %ebp
  8010f7:	83 c4 04             	add    $0x4,%esp
  8010fa:	5b                   	pop    %ebx
  8010fb:	5a                   	pop    %edx
  8010fc:	59                   	pop    %ecx
  8010fd:	58                   	pop    %eax
  8010fe:	83 c4 04             	add    $0x4,%esp
  801101:	9d                   	popf   
  801102:	8b 24 24             	mov    (%esp),%esp
  801105:	c3                   	ret    
  801106:	66 90                	xchg   %ax,%ax
  801108:	66 90                	xchg   %ax,%ax
  80110a:	66 90                	xchg   %ax,%ax
  80110c:	66 90                	xchg   %ax,%ax
  80110e:	66 90                	xchg   %ax,%ax

00801110 <__udivdi3>:
  801110:	83 ec 1c             	sub    $0x1c,%esp
  801113:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801117:	89 7c 24 14          	mov    %edi,0x14(%esp)
  80111b:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80111f:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801123:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801127:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  80112b:	85 c0                	test   %eax,%eax
  80112d:	89 74 24 10          	mov    %esi,0x10(%esp)
  801131:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801135:	89 ea                	mov    %ebp,%edx
  801137:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80113b:	75 33                	jne    801170 <__udivdi3+0x60>
  80113d:	39 e9                	cmp    %ebp,%ecx
  80113f:	77 6f                	ja     8011b0 <__udivdi3+0xa0>
  801141:	85 c9                	test   %ecx,%ecx
  801143:	89 ce                	mov    %ecx,%esi
  801145:	75 0b                	jne    801152 <__udivdi3+0x42>
  801147:	b8 01 00 00 00       	mov    $0x1,%eax
  80114c:	31 d2                	xor    %edx,%edx
  80114e:	f7 f1                	div    %ecx
  801150:	89 c6                	mov    %eax,%esi
  801152:	31 d2                	xor    %edx,%edx
  801154:	89 e8                	mov    %ebp,%eax
  801156:	f7 f6                	div    %esi
  801158:	89 c5                	mov    %eax,%ebp
  80115a:	89 f8                	mov    %edi,%eax
  80115c:	f7 f6                	div    %esi
  80115e:	89 ea                	mov    %ebp,%edx
  801160:	8b 74 24 10          	mov    0x10(%esp),%esi
  801164:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801168:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80116c:	83 c4 1c             	add    $0x1c,%esp
  80116f:	c3                   	ret    
  801170:	39 e8                	cmp    %ebp,%eax
  801172:	77 24                	ja     801198 <__udivdi3+0x88>
  801174:	0f bd c8             	bsr    %eax,%ecx
  801177:	83 f1 1f             	xor    $0x1f,%ecx
  80117a:	89 0c 24             	mov    %ecx,(%esp)
  80117d:	75 49                	jne    8011c8 <__udivdi3+0xb8>
  80117f:	8b 74 24 08          	mov    0x8(%esp),%esi
  801183:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801187:	0f 86 ab 00 00 00    	jbe    801238 <__udivdi3+0x128>
  80118d:	39 e8                	cmp    %ebp,%eax
  80118f:	0f 82 a3 00 00 00    	jb     801238 <__udivdi3+0x128>
  801195:	8d 76 00             	lea    0x0(%esi),%esi
  801198:	31 d2                	xor    %edx,%edx
  80119a:	31 c0                	xor    %eax,%eax
  80119c:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011a0:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011a4:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011a8:	83 c4 1c             	add    $0x1c,%esp
  8011ab:	c3                   	ret    
  8011ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011b0:	89 f8                	mov    %edi,%eax
  8011b2:	f7 f1                	div    %ecx
  8011b4:	31 d2                	xor    %edx,%edx
  8011b6:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011ba:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011be:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011c2:	83 c4 1c             	add    $0x1c,%esp
  8011c5:	c3                   	ret    
  8011c6:	66 90                	xchg   %ax,%ax
  8011c8:	0f b6 0c 24          	movzbl (%esp),%ecx
  8011cc:	89 c6                	mov    %eax,%esi
  8011ce:	b8 20 00 00 00       	mov    $0x20,%eax
  8011d3:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  8011d7:	2b 04 24             	sub    (%esp),%eax
  8011da:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011de:	d3 e6                	shl    %cl,%esi
  8011e0:	89 c1                	mov    %eax,%ecx
  8011e2:	d3 ed                	shr    %cl,%ebp
  8011e4:	0f b6 0c 24          	movzbl (%esp),%ecx
  8011e8:	09 f5                	or     %esi,%ebp
  8011ea:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011ee:	d3 e6                	shl    %cl,%esi
  8011f0:	89 c1                	mov    %eax,%ecx
  8011f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011f6:	89 d6                	mov    %edx,%esi
  8011f8:	d3 ee                	shr    %cl,%esi
  8011fa:	0f b6 0c 24          	movzbl (%esp),%ecx
  8011fe:	d3 e2                	shl    %cl,%edx
  801200:	89 c1                	mov    %eax,%ecx
  801202:	d3 ef                	shr    %cl,%edi
  801204:	09 d7                	or     %edx,%edi
  801206:	89 f2                	mov    %esi,%edx
  801208:	89 f8                	mov    %edi,%eax
  80120a:	f7 f5                	div    %ebp
  80120c:	89 d6                	mov    %edx,%esi
  80120e:	89 c7                	mov    %eax,%edi
  801210:	f7 64 24 04          	mull   0x4(%esp)
  801214:	39 d6                	cmp    %edx,%esi
  801216:	72 30                	jb     801248 <__udivdi3+0x138>
  801218:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  80121c:	0f b6 0c 24          	movzbl (%esp),%ecx
  801220:	d3 e5                	shl    %cl,%ebp
  801222:	39 c5                	cmp    %eax,%ebp
  801224:	73 04                	jae    80122a <__udivdi3+0x11a>
  801226:	39 d6                	cmp    %edx,%esi
  801228:	74 1e                	je     801248 <__udivdi3+0x138>
  80122a:	89 f8                	mov    %edi,%eax
  80122c:	31 d2                	xor    %edx,%edx
  80122e:	e9 69 ff ff ff       	jmp    80119c <__udivdi3+0x8c>
  801233:	90                   	nop
  801234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801238:	31 d2                	xor    %edx,%edx
  80123a:	b8 01 00 00 00       	mov    $0x1,%eax
  80123f:	e9 58 ff ff ff       	jmp    80119c <__udivdi3+0x8c>
  801244:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801248:	8d 47 ff             	lea    -0x1(%edi),%eax
  80124b:	31 d2                	xor    %edx,%edx
  80124d:	8b 74 24 10          	mov    0x10(%esp),%esi
  801251:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801255:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801259:	83 c4 1c             	add    $0x1c,%esp
  80125c:	c3                   	ret    
  80125d:	66 90                	xchg   %ax,%ax
  80125f:	90                   	nop

00801260 <__umoddi3>:
  801260:	83 ec 2c             	sub    $0x2c,%esp
  801263:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801267:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80126b:	89 74 24 20          	mov    %esi,0x20(%esp)
  80126f:	8b 74 24 38          	mov    0x38(%esp),%esi
  801273:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801277:	8b 7c 24 34          	mov    0x34(%esp),%edi
  80127b:	85 c0                	test   %eax,%eax
  80127d:	89 c2                	mov    %eax,%edx
  80127f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801283:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801287:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80128b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80128f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801293:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801297:	75 1f                	jne    8012b8 <__umoddi3+0x58>
  801299:	39 fe                	cmp    %edi,%esi
  80129b:	76 63                	jbe    801300 <__umoddi3+0xa0>
  80129d:	89 c8                	mov    %ecx,%eax
  80129f:	89 fa                	mov    %edi,%edx
  8012a1:	f7 f6                	div    %esi
  8012a3:	89 d0                	mov    %edx,%eax
  8012a5:	31 d2                	xor    %edx,%edx
  8012a7:	8b 74 24 20          	mov    0x20(%esp),%esi
  8012ab:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8012af:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8012b3:	83 c4 2c             	add    $0x2c,%esp
  8012b6:	c3                   	ret    
  8012b7:	90                   	nop
  8012b8:	39 f8                	cmp    %edi,%eax
  8012ba:	77 64                	ja     801320 <__umoddi3+0xc0>
  8012bc:	0f bd e8             	bsr    %eax,%ebp
  8012bf:	83 f5 1f             	xor    $0x1f,%ebp
  8012c2:	75 74                	jne    801338 <__umoddi3+0xd8>
  8012c4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8012c8:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  8012cc:	0f 87 0e 01 00 00    	ja     8013e0 <__umoddi3+0x180>
  8012d2:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  8012d6:	29 f1                	sub    %esi,%ecx
  8012d8:	19 c7                	sbb    %eax,%edi
  8012da:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8012de:	89 7c 24 18          	mov    %edi,0x18(%esp)
  8012e2:	8b 44 24 14          	mov    0x14(%esp),%eax
  8012e6:	8b 54 24 18          	mov    0x18(%esp),%edx
  8012ea:	8b 74 24 20          	mov    0x20(%esp),%esi
  8012ee:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8012f2:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8012f6:	83 c4 2c             	add    $0x2c,%esp
  8012f9:	c3                   	ret    
  8012fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801300:	85 f6                	test   %esi,%esi
  801302:	89 f5                	mov    %esi,%ebp
  801304:	75 0b                	jne    801311 <__umoddi3+0xb1>
  801306:	b8 01 00 00 00       	mov    $0x1,%eax
  80130b:	31 d2                	xor    %edx,%edx
  80130d:	f7 f6                	div    %esi
  80130f:	89 c5                	mov    %eax,%ebp
  801311:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801315:	31 d2                	xor    %edx,%edx
  801317:	f7 f5                	div    %ebp
  801319:	89 c8                	mov    %ecx,%eax
  80131b:	f7 f5                	div    %ebp
  80131d:	eb 84                	jmp    8012a3 <__umoddi3+0x43>
  80131f:	90                   	nop
  801320:	89 c8                	mov    %ecx,%eax
  801322:	89 fa                	mov    %edi,%edx
  801324:	8b 74 24 20          	mov    0x20(%esp),%esi
  801328:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80132c:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801330:	83 c4 2c             	add    $0x2c,%esp
  801333:	c3                   	ret    
  801334:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801338:	8b 44 24 10          	mov    0x10(%esp),%eax
  80133c:	be 20 00 00 00       	mov    $0x20,%esi
  801341:	89 e9                	mov    %ebp,%ecx
  801343:	29 ee                	sub    %ebp,%esi
  801345:	d3 e2                	shl    %cl,%edx
  801347:	89 f1                	mov    %esi,%ecx
  801349:	d3 e8                	shr    %cl,%eax
  80134b:	89 e9                	mov    %ebp,%ecx
  80134d:	09 d0                	or     %edx,%eax
  80134f:	89 fa                	mov    %edi,%edx
  801351:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801355:	8b 44 24 10          	mov    0x10(%esp),%eax
  801359:	d3 e0                	shl    %cl,%eax
  80135b:	89 f1                	mov    %esi,%ecx
  80135d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801361:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801365:	d3 ea                	shr    %cl,%edx
  801367:	89 e9                	mov    %ebp,%ecx
  801369:	d3 e7                	shl    %cl,%edi
  80136b:	89 f1                	mov    %esi,%ecx
  80136d:	d3 e8                	shr    %cl,%eax
  80136f:	89 e9                	mov    %ebp,%ecx
  801371:	09 f8                	or     %edi,%eax
  801373:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801377:	f7 74 24 0c          	divl   0xc(%esp)
  80137b:	d3 e7                	shl    %cl,%edi
  80137d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801381:	89 d7                	mov    %edx,%edi
  801383:	f7 64 24 10          	mull   0x10(%esp)
  801387:	39 d7                	cmp    %edx,%edi
  801389:	89 c1                	mov    %eax,%ecx
  80138b:	89 54 24 14          	mov    %edx,0x14(%esp)
  80138f:	72 3b                	jb     8013cc <__umoddi3+0x16c>
  801391:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801395:	72 31                	jb     8013c8 <__umoddi3+0x168>
  801397:	8b 44 24 18          	mov    0x18(%esp),%eax
  80139b:	29 c8                	sub    %ecx,%eax
  80139d:	19 d7                	sbb    %edx,%edi
  80139f:	89 e9                	mov    %ebp,%ecx
  8013a1:	89 fa                	mov    %edi,%edx
  8013a3:	d3 e8                	shr    %cl,%eax
  8013a5:	89 f1                	mov    %esi,%ecx
  8013a7:	d3 e2                	shl    %cl,%edx
  8013a9:	89 e9                	mov    %ebp,%ecx
  8013ab:	09 d0                	or     %edx,%eax
  8013ad:	89 fa                	mov    %edi,%edx
  8013af:	d3 ea                	shr    %cl,%edx
  8013b1:	8b 74 24 20          	mov    0x20(%esp),%esi
  8013b5:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8013b9:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8013bd:	83 c4 2c             	add    $0x2c,%esp
  8013c0:	c3                   	ret    
  8013c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013c8:	39 d7                	cmp    %edx,%edi
  8013ca:	75 cb                	jne    801397 <__umoddi3+0x137>
  8013cc:	8b 54 24 14          	mov    0x14(%esp),%edx
  8013d0:	89 c1                	mov    %eax,%ecx
  8013d2:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  8013d6:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  8013da:	eb bb                	jmp    801397 <__umoddi3+0x137>
  8013dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013e0:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8013e4:	0f 82 e8 fe ff ff    	jb     8012d2 <__umoddi3+0x72>
  8013ea:	e9 f3 fe ff ff       	jmp    8012e2 <__umoddi3+0x82>
