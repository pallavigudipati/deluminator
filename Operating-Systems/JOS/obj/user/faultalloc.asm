
obj/user/faultalloc:     file format elf32-i386


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
  80002c:	e8 d7 00 00 00       	call   800108 <libmain>
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
  800044:	c7 04 24 20 14 80 00 	movl   $0x801420,(%esp)
  80004b:	e8 23 02 00 00       	call   800273 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 9d 0d 00 00       	call   800e0c <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 4c 14 80 	movl   $0x80144c,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 2a 14 80 00 	movl   $0x80142a,(%esp)
  800092:	e8 e1 00 00 00       	call   800178 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 78 14 80 	movl   $0x801478,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 a6 07 00 00       	call   800859 <snprintf>
	cprintf("hello! %x\n", addr);
  8000b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000b7:	c7 04 24 3c 14 80 00 	movl   $0x80143c,(%esp)
  8000be:	e8 b0 01 00 00       	call   800273 <cprintf>
}
  8000c3:	83 c4 24             	add    $0x24,%esp
  8000c6:	5b                   	pop    %ebx
  8000c7:	5d                   	pop    %ebp
  8000c8:	c3                   	ret    

008000c9 <umain>:

void
umain(int argc, char **argv)
{
  8000c9:	55                   	push   %ebp
  8000ca:	89 e5                	mov    %esp,%ebp
  8000cc:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  8000cf:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  8000d6:	e8 99 0f 00 00       	call   801074 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000db:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  8000e2:	de 
  8000e3:	c7 04 24 47 14 80 00 	movl   $0x801447,(%esp)
  8000ea:	e8 84 01 00 00       	call   800273 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000ef:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  8000f6:	ca 
  8000f7:	c7 04 24 47 14 80 00 	movl   $0x801447,(%esp)
  8000fe:	e8 70 01 00 00       	call   800273 <cprintf>
}
  800103:	c9                   	leave  
  800104:	c3                   	ret    
  800105:	66 90                	xchg   %ax,%ax
  800107:	90                   	nop

00800108 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	83 ec 18             	sub    $0x18,%esp
  80010e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800111:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800114:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800117:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80011a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800121:	00 00 00 
	int envid;
	envid = sys_getenvid();
  800124:	e8 83 0c 00 00       	call   800dac <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800129:	25 ff 03 00 00       	and    $0x3ff,%eax
  80012e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800131:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800136:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80013b:	85 db                	test   %ebx,%ebx
  80013d:	7e 07                	jle    800146 <libmain+0x3e>
		binaryname = argv[0];
  80013f:	8b 06                	mov    (%esi),%eax
  800141:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800146:	89 74 24 04          	mov    %esi,0x4(%esp)
  80014a:	89 1c 24             	mov    %ebx,(%esp)
  80014d:	e8 77 ff ff ff       	call   8000c9 <umain>

	// exit gracefully
	exit();
  800152:	e8 0d 00 00 00       	call   800164 <exit>
}
  800157:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80015a:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80015d:	89 ec                	mov    %ebp,%esp
  80015f:	5d                   	pop    %ebp
  800160:	c3                   	ret    
  800161:	66 90                	xchg   %ax,%ax
  800163:	90                   	nop

00800164 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80016a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800171:	e8 d9 0b 00 00       	call   800d4f <sys_env_destroy>
}
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
  80017d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800180:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800183:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800189:	e8 1e 0c 00 00       	call   800dac <sys_getenvid>
  80018e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800191:	89 54 24 10          	mov    %edx,0x10(%esp)
  800195:	8b 55 08             	mov    0x8(%ebp),%edx
  800198:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80019c:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a4:	c7 04 24 a4 14 80 00 	movl   $0x8014a4,(%esp)
  8001ab:	e8 c3 00 00 00       	call   800273 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b7:	89 04 24             	mov    %eax,(%esp)
  8001ba:	e8 53 00 00 00       	call   800212 <vcprintf>
	cprintf("\n");
  8001bf:	c7 04 24 31 17 80 00 	movl   $0x801731,(%esp)
  8001c6:	e8 a8 00 00 00       	call   800273 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001cb:	cc                   	int3   
  8001cc:	eb fd                	jmp    8001cb <_panic+0x53>
  8001ce:	66 90                	xchg   %ax,%ax

008001d0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	53                   	push   %ebx
  8001d4:	83 ec 14             	sub    $0x14,%esp
  8001d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001da:	8b 03                	mov    (%ebx),%eax
  8001dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001df:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001e3:	83 c0 01             	add    $0x1,%eax
  8001e6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001e8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ed:	75 19                	jne    800208 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001ef:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001f6:	00 
  8001f7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001fa:	89 04 24             	mov    %eax,(%esp)
  8001fd:	e8 ee 0a 00 00       	call   800cf0 <sys_cputs>
		b->idx = 0;
  800202:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800208:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80020c:	83 c4 14             	add    $0x14,%esp
  80020f:	5b                   	pop    %ebx
  800210:	5d                   	pop    %ebp
  800211:	c3                   	ret    

00800212 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80021b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800222:	00 00 00 
	b.cnt = 0;
  800225:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80022c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80022f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800232:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800236:	8b 45 08             	mov    0x8(%ebp),%eax
  800239:	89 44 24 08          	mov    %eax,0x8(%esp)
  80023d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800243:	89 44 24 04          	mov    %eax,0x4(%esp)
  800247:	c7 04 24 d0 01 80 00 	movl   $0x8001d0,(%esp)
  80024e:	e8 af 01 00 00       	call   800402 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800253:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800259:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800263:	89 04 24             	mov    %eax,(%esp)
  800266:	e8 85 0a 00 00       	call   800cf0 <sys_cputs>

	return b.cnt;
}
  80026b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800271:	c9                   	leave  
  800272:	c3                   	ret    

00800273 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800279:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80027c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800280:	8b 45 08             	mov    0x8(%ebp),%eax
  800283:	89 04 24             	mov    %eax,(%esp)
  800286:	e8 87 ff ff ff       	call   800212 <vcprintf>
	va_end(ap);

	return cnt;
}
  80028b:	c9                   	leave  
  80028c:	c3                   	ret    
  80028d:	66 90                	xchg   %ax,%ax
  80028f:	90                   	nop

00800290 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	57                   	push   %edi
  800294:	56                   	push   %esi
  800295:	53                   	push   %ebx
  800296:	83 ec 4c             	sub    $0x4c,%esp
  800299:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80029c:	89 d7                	mov    %edx,%edi
  80029e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002a1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8002a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002a7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8002af:	39 d8                	cmp    %ebx,%eax
  8002b1:	72 17                	jb     8002ca <printnum+0x3a>
  8002b3:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8002b6:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  8002b9:	76 0f                	jbe    8002ca <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002bb:	8b 75 14             	mov    0x14(%ebp),%esi
  8002be:	83 ee 01             	sub    $0x1,%esi
  8002c1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002c4:	85 f6                	test   %esi,%esi
  8002c6:	7f 63                	jg     80032b <printnum+0x9b>
  8002c8:	eb 75                	jmp    80033f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ca:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8002cd:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8002d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d4:	83 e8 01             	sub    $0x1,%eax
  8002d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002db:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e2:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002e6:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002ed:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8002f0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002f7:	00 
  8002f8:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8002fb:	89 1c 24             	mov    %ebx,(%esp)
  8002fe:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800301:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800305:	e8 26 0e 00 00       	call   801130 <__udivdi3>
  80030a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80030d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800310:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800314:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800318:	89 04 24             	mov    %eax,(%esp)
  80031b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80031f:	89 fa                	mov    %edi,%edx
  800321:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800324:	e8 67 ff ff ff       	call   800290 <printnum>
  800329:	eb 14                	jmp    80033f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80032f:	8b 45 18             	mov    0x18(%ebp),%eax
  800332:	89 04 24             	mov    %eax,(%esp)
  800335:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800337:	83 ee 01             	sub    $0x1,%esi
  80033a:	75 ef                	jne    80032b <printnum+0x9b>
  80033c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80033f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800343:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800347:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80034a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80034e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800355:	00 
  800356:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800359:	89 1c 24             	mov    %ebx,(%esp)
  80035c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80035f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800363:	e8 18 0f 00 00       	call   801280 <__umoddi3>
  800368:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80036c:	0f be 80 c7 14 80 00 	movsbl 0x8014c7(%eax),%eax
  800373:	89 04 24             	mov    %eax,(%esp)
  800376:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800379:	ff d0                	call   *%eax
}
  80037b:	83 c4 4c             	add    $0x4c,%esp
  80037e:	5b                   	pop    %ebx
  80037f:	5e                   	pop    %esi
  800380:	5f                   	pop    %edi
  800381:	5d                   	pop    %ebp
  800382:	c3                   	ret    

00800383 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800386:	83 fa 01             	cmp    $0x1,%edx
  800389:	7e 0e                	jle    800399 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80038b:	8b 10                	mov    (%eax),%edx
  80038d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800390:	89 08                	mov    %ecx,(%eax)
  800392:	8b 02                	mov    (%edx),%eax
  800394:	8b 52 04             	mov    0x4(%edx),%edx
  800397:	eb 22                	jmp    8003bb <getuint+0x38>
	else if (lflag)
  800399:	85 d2                	test   %edx,%edx
  80039b:	74 10                	je     8003ad <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80039d:	8b 10                	mov    (%eax),%edx
  80039f:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a2:	89 08                	mov    %ecx,(%eax)
  8003a4:	8b 02                	mov    (%edx),%eax
  8003a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ab:	eb 0e                	jmp    8003bb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003ad:	8b 10                	mov    (%eax),%edx
  8003af:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b2:	89 08                	mov    %ecx,(%eax)
  8003b4:	8b 02                	mov    (%edx),%eax
  8003b6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003c7:	8b 10                	mov    (%eax),%edx
  8003c9:	3b 50 04             	cmp    0x4(%eax),%edx
  8003cc:	73 0a                	jae    8003d8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003d1:	88 0a                	mov    %cl,(%edx)
  8003d3:	83 c2 01             	add    $0x1,%edx
  8003d6:	89 10                	mov    %edx,(%eax)
}
  8003d8:	5d                   	pop    %ebp
  8003d9:	c3                   	ret    

008003da <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003da:	55                   	push   %ebp
  8003db:	89 e5                	mov    %esp,%ebp
  8003dd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003e0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003e7:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f8:	89 04 24             	mov    %eax,(%esp)
  8003fb:	e8 02 00 00 00       	call   800402 <vprintfmt>
	va_end(ap);
}
  800400:	c9                   	leave  
  800401:	c3                   	ret    

00800402 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800402:	55                   	push   %ebp
  800403:	89 e5                	mov    %esp,%ebp
  800405:	57                   	push   %edi
  800406:	56                   	push   %esi
  800407:	53                   	push   %ebx
  800408:	83 ec 4c             	sub    $0x4c,%esp
  80040b:	8b 75 08             	mov    0x8(%ebp),%esi
  80040e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800411:	8b 7d 10             	mov    0x10(%ebp),%edi
  800414:	eb 11                	jmp    800427 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800416:	85 c0                	test   %eax,%eax
  800418:	0f 84 db 03 00 00    	je     8007f9 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  80041e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800422:	89 04 24             	mov    %eax,(%esp)
  800425:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800427:	0f b6 07             	movzbl (%edi),%eax
  80042a:	83 c7 01             	add    $0x1,%edi
  80042d:	83 f8 25             	cmp    $0x25,%eax
  800430:	75 e4                	jne    800416 <vprintfmt+0x14>
  800432:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800436:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80043d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800444:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80044b:	ba 00 00 00 00       	mov    $0x0,%edx
  800450:	eb 2b                	jmp    80047d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800452:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800455:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800459:	eb 22                	jmp    80047d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80045e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  800462:	eb 19                	jmp    80047d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800464:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800467:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80046e:	eb 0d                	jmp    80047d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800470:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800473:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800476:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047d:	0f b6 0f             	movzbl (%edi),%ecx
  800480:	8d 47 01             	lea    0x1(%edi),%eax
  800483:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800486:	0f b6 07             	movzbl (%edi),%eax
  800489:	83 e8 23             	sub    $0x23,%eax
  80048c:	3c 55                	cmp    $0x55,%al
  80048e:	0f 87 40 03 00 00    	ja     8007d4 <vprintfmt+0x3d2>
  800494:	0f b6 c0             	movzbl %al,%eax
  800497:	ff 24 85 80 15 80 00 	jmp    *0x801580(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80049e:	83 e9 30             	sub    $0x30,%ecx
  8004a1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  8004a4:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  8004a8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004ab:	83 f9 09             	cmp    $0x9,%ecx
  8004ae:	77 57                	ja     800507 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b0:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004b3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004b6:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004b9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004bc:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004bf:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8004c3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8004c6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004c9:	83 f9 09             	cmp    $0x9,%ecx
  8004cc:	76 eb                	jbe    8004b9 <vprintfmt+0xb7>
  8004ce:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004d1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004d4:	eb 34                	jmp    80050a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d9:	8d 48 04             	lea    0x4(%eax),%ecx
  8004dc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004df:	8b 00                	mov    (%eax),%eax
  8004e1:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004e7:	eb 21                	jmp    80050a <vprintfmt+0x108>

		case '.':
			if (width < 0)
  8004e9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ed:	0f 88 71 ff ff ff    	js     800464 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004f6:	eb 85                	jmp    80047d <vprintfmt+0x7b>
  8004f8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004fb:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800502:	e9 76 ff ff ff       	jmp    80047d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800507:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80050a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80050e:	0f 89 69 ff ff ff    	jns    80047d <vprintfmt+0x7b>
  800514:	e9 57 ff ff ff       	jmp    800470 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800519:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80051f:	e9 59 ff ff ff       	jmp    80047d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800524:	8b 45 14             	mov    0x14(%ebp),%eax
  800527:	8d 50 04             	lea    0x4(%eax),%edx
  80052a:	89 55 14             	mov    %edx,0x14(%ebp)
  80052d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800531:	8b 00                	mov    (%eax),%eax
  800533:	89 04 24             	mov    %eax,(%esp)
  800536:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800538:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80053b:	e9 e7 fe ff ff       	jmp    800427 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8d 50 04             	lea    0x4(%eax),%edx
  800546:	89 55 14             	mov    %edx,0x14(%ebp)
  800549:	8b 00                	mov    (%eax),%eax
  80054b:	89 c2                	mov    %eax,%edx
  80054d:	c1 fa 1f             	sar    $0x1f,%edx
  800550:	31 d0                	xor    %edx,%eax
  800552:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800554:	83 f8 08             	cmp    $0x8,%eax
  800557:	7f 0b                	jg     800564 <vprintfmt+0x162>
  800559:	8b 14 85 e0 16 80 00 	mov    0x8016e0(,%eax,4),%edx
  800560:	85 d2                	test   %edx,%edx
  800562:	75 20                	jne    800584 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800564:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800568:	c7 44 24 08 df 14 80 	movl   $0x8014df,0x8(%esp)
  80056f:	00 
  800570:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800574:	89 34 24             	mov    %esi,(%esp)
  800577:	e8 5e fe ff ff       	call   8003da <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80057f:	e9 a3 fe ff ff       	jmp    800427 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800584:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800588:	c7 44 24 08 e8 14 80 	movl   $0x8014e8,0x8(%esp)
  80058f:	00 
  800590:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800594:	89 34 24             	mov    %esi,(%esp)
  800597:	e8 3e fe ff ff       	call   8003da <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80059f:	e9 83 fe ff ff       	jmp    800427 <vprintfmt+0x25>
  8005a4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005a7:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8005aa:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8d 50 04             	lea    0x4(%eax),%edx
  8005b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005b8:	85 ff                	test   %edi,%edi
  8005ba:	b8 d8 14 80 00       	mov    $0x8014d8,%eax
  8005bf:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005c2:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  8005c6:	74 06                	je     8005ce <vprintfmt+0x1cc>
  8005c8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005cc:	7f 16                	jg     8005e4 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ce:	0f b6 17             	movzbl (%edi),%edx
  8005d1:	0f be c2             	movsbl %dl,%eax
  8005d4:	83 c7 01             	add    $0x1,%edi
  8005d7:	85 c0                	test   %eax,%eax
  8005d9:	0f 85 9f 00 00 00    	jne    80067e <vprintfmt+0x27c>
  8005df:	e9 8b 00 00 00       	jmp    80066f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005e8:	89 3c 24             	mov    %edi,(%esp)
  8005eb:	e8 c2 02 00 00       	call   8008b2 <strnlen>
  8005f0:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005f3:	29 c2                	sub    %eax,%edx
  8005f5:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005f8:	85 d2                	test   %edx,%edx
  8005fa:	7e d2                	jle    8005ce <vprintfmt+0x1cc>
					putch(padc, putdat);
  8005fc:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  800600:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800603:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800606:	89 d7                	mov    %edx,%edi
  800608:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80060f:	89 04 24             	mov    %eax,(%esp)
  800612:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800614:	83 ef 01             	sub    $0x1,%edi
  800617:	75 ef                	jne    800608 <vprintfmt+0x206>
  800619:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80061c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80061f:	eb ad                	jmp    8005ce <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800621:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800625:	74 20                	je     800647 <vprintfmt+0x245>
  800627:	0f be d2             	movsbl %dl,%edx
  80062a:	83 ea 20             	sub    $0x20,%edx
  80062d:	83 fa 5e             	cmp    $0x5e,%edx
  800630:	76 15                	jbe    800647 <vprintfmt+0x245>
					putch('?', putdat);
  800632:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800635:	89 54 24 04          	mov    %edx,0x4(%esp)
  800639:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800640:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800643:	ff d1                	call   *%ecx
  800645:	eb 0f                	jmp    800656 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800647:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80064a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80064e:	89 04 24             	mov    %eax,(%esp)
  800651:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800654:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800656:	83 eb 01             	sub    $0x1,%ebx
  800659:	0f b6 17             	movzbl (%edi),%edx
  80065c:	0f be c2             	movsbl %dl,%eax
  80065f:	83 c7 01             	add    $0x1,%edi
  800662:	85 c0                	test   %eax,%eax
  800664:	75 24                	jne    80068a <vprintfmt+0x288>
  800666:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800669:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80066c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800672:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800676:	0f 8e ab fd ff ff    	jle    800427 <vprintfmt+0x25>
  80067c:	eb 20                	jmp    80069e <vprintfmt+0x29c>
  80067e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800681:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800684:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800687:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80068a:	85 f6                	test   %esi,%esi
  80068c:	78 93                	js     800621 <vprintfmt+0x21f>
  80068e:	83 ee 01             	sub    $0x1,%esi
  800691:	79 8e                	jns    800621 <vprintfmt+0x21f>
  800693:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800696:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800699:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80069c:	eb d1                	jmp    80066f <vprintfmt+0x26d>
  80069e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006ac:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ae:	83 ef 01             	sub    $0x1,%edi
  8006b1:	75 ee                	jne    8006a1 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006b6:	e9 6c fd ff ff       	jmp    800427 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006bb:	83 fa 01             	cmp    $0x1,%edx
  8006be:	66 90                	xchg   %ax,%ax
  8006c0:	7e 16                	jle    8006d8 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  8006c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c5:	8d 50 08             	lea    0x8(%eax),%edx
  8006c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cb:	8b 10                	mov    (%eax),%edx
  8006cd:	8b 48 04             	mov    0x4(%eax),%ecx
  8006d0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006d3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006d6:	eb 32                	jmp    80070a <vprintfmt+0x308>
	else if (lflag)
  8006d8:	85 d2                	test   %edx,%edx
  8006da:	74 18                	je     8006f4 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  8006dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006df:	8d 50 04             	lea    0x4(%eax),%edx
  8006e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e5:	8b 00                	mov    (%eax),%eax
  8006e7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006ea:	89 c1                	mov    %eax,%ecx
  8006ec:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ef:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006f2:	eb 16                	jmp    80070a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  8006f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f7:	8d 50 04             	lea    0x4(%eax),%edx
  8006fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fd:	8b 00                	mov    (%eax),%eax
  8006ff:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800702:	89 c7                	mov    %eax,%edi
  800704:	c1 ff 1f             	sar    $0x1f,%edi
  800707:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80070a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80070d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800710:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800715:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800719:	79 7d                	jns    800798 <vprintfmt+0x396>
				putch('-', putdat);
  80071b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800726:	ff d6                	call   *%esi
				num = -(long long) num;
  800728:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80072b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80072e:	f7 d8                	neg    %eax
  800730:	83 d2 00             	adc    $0x0,%edx
  800733:	f7 da                	neg    %edx
			}
			base = 10;
  800735:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80073a:	eb 5c                	jmp    800798 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80073c:	8d 45 14             	lea    0x14(%ebp),%eax
  80073f:	e8 3f fc ff ff       	call   800383 <getuint>
			base = 10;
  800744:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800749:	eb 4d                	jmp    800798 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80074b:	8d 45 14             	lea    0x14(%ebp),%eax
  80074e:	e8 30 fc ff ff       	call   800383 <getuint>
			base = 8;
  800753:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800758:	eb 3e                	jmp    800798 <vprintfmt+0x396>

		// pointer
		case 'p':
			putch('0', putdat);
  80075a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80075e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800765:	ff d6                	call   *%esi
			putch('x', putdat);
  800767:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800772:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800774:	8b 45 14             	mov    0x14(%ebp),%eax
  800777:	8d 50 04             	lea    0x4(%eax),%edx
  80077a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80077d:	8b 00                	mov    (%eax),%eax
  80077f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800784:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800789:	eb 0d                	jmp    800798 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80078b:	8d 45 14             	lea    0x14(%ebp),%eax
  80078e:	e8 f0 fb ff ff       	call   800383 <getuint>
			base = 16;
  800793:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800798:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  80079c:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8007a0:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8007a3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8007a7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007ab:	89 04 24             	mov    %eax,(%esp)
  8007ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007b2:	89 da                	mov    %ebx,%edx
  8007b4:	89 f0                	mov    %esi,%eax
  8007b6:	e8 d5 fa ff ff       	call   800290 <printnum>
			break;
  8007bb:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8007be:	e9 64 fc ff ff       	jmp    800427 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c7:	89 0c 24             	mov    %ecx,(%esp)
  8007ca:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007cc:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007cf:	e9 53 fc ff ff       	jmp    800427 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007df:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e5:	0f 84 3c fc ff ff    	je     800427 <vprintfmt+0x25>
  8007eb:	83 ef 01             	sub    $0x1,%edi
  8007ee:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007f2:	75 f7                	jne    8007eb <vprintfmt+0x3e9>
  8007f4:	e9 2e fc ff ff       	jmp    800427 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8007f9:	83 c4 4c             	add    $0x4c,%esp
  8007fc:	5b                   	pop    %ebx
  8007fd:	5e                   	pop    %esi
  8007fe:	5f                   	pop    %edi
  8007ff:	5d                   	pop    %ebp
  800800:	c3                   	ret    

00800801 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	83 ec 28             	sub    $0x28,%esp
  800807:	8b 45 08             	mov    0x8(%ebp),%eax
  80080a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800810:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800814:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800817:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80081e:	85 d2                	test   %edx,%edx
  800820:	7e 30                	jle    800852 <vsnprintf+0x51>
  800822:	85 c0                	test   %eax,%eax
  800824:	74 2c                	je     800852 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800826:	8b 45 14             	mov    0x14(%ebp),%eax
  800829:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80082d:	8b 45 10             	mov    0x10(%ebp),%eax
  800830:	89 44 24 08          	mov    %eax,0x8(%esp)
  800834:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800837:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083b:	c7 04 24 bd 03 80 00 	movl   $0x8003bd,(%esp)
  800842:	e8 bb fb ff ff       	call   800402 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800847:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80084a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80084d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800850:	eb 05                	jmp    800857 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800852:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800857:	c9                   	leave  
  800858:	c3                   	ret    

00800859 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80085f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800862:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800866:	8b 45 10             	mov    0x10(%ebp),%eax
  800869:	89 44 24 08          	mov    %eax,0x8(%esp)
  80086d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800870:	89 44 24 04          	mov    %eax,0x4(%esp)
  800874:	8b 45 08             	mov    0x8(%ebp),%eax
  800877:	89 04 24             	mov    %eax,(%esp)
  80087a:	e8 82 ff ff ff       	call   800801 <vsnprintf>
	va_end(ap);

	return rc;
}
  80087f:	c9                   	leave  
  800880:	c3                   	ret    
  800881:	66 90                	xchg   %ax,%ax
  800883:	66 90                	xchg   %ax,%ax
  800885:	66 90                	xchg   %ax,%ax
  800887:	66 90                	xchg   %ax,%ax
  800889:	66 90                	xchg   %ax,%ax
  80088b:	66 90                	xchg   %ax,%ax
  80088d:	66 90                	xchg   %ax,%ax
  80088f:	90                   	nop

00800890 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800896:	80 3a 00             	cmpb   $0x0,(%edx)
  800899:	74 10                	je     8008ab <strlen+0x1b>
  80089b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008a0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008a7:	75 f7                	jne    8008a0 <strlen+0x10>
  8008a9:	eb 05                	jmp    8008b0 <strlen+0x20>
  8008ab:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	53                   	push   %ebx
  8008b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008bc:	85 c9                	test   %ecx,%ecx
  8008be:	74 1c                	je     8008dc <strnlen+0x2a>
  8008c0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008c3:	74 1e                	je     8008e3 <strnlen+0x31>
  8008c5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8008ca:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008cc:	39 ca                	cmp    %ecx,%edx
  8008ce:	74 18                	je     8008e8 <strnlen+0x36>
  8008d0:	83 c2 01             	add    $0x1,%edx
  8008d3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008d8:	75 f0                	jne    8008ca <strnlen+0x18>
  8008da:	eb 0c                	jmp    8008e8 <strnlen+0x36>
  8008dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e1:	eb 05                	jmp    8008e8 <strnlen+0x36>
  8008e3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008e8:	5b                   	pop    %ebx
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	53                   	push   %ebx
  8008ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f5:	89 c2                	mov    %eax,%edx
  8008f7:	0f b6 19             	movzbl (%ecx),%ebx
  8008fa:	88 1a                	mov    %bl,(%edx)
  8008fc:	83 c2 01             	add    $0x1,%edx
  8008ff:	83 c1 01             	add    $0x1,%ecx
  800902:	84 db                	test   %bl,%bl
  800904:	75 f1                	jne    8008f7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800906:	5b                   	pop    %ebx
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	53                   	push   %ebx
  80090d:	83 ec 08             	sub    $0x8,%esp
  800910:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800913:	89 1c 24             	mov    %ebx,(%esp)
  800916:	e8 75 ff ff ff       	call   800890 <strlen>
	strcpy(dst + len, src);
  80091b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800922:	01 d8                	add    %ebx,%eax
  800924:	89 04 24             	mov    %eax,(%esp)
  800927:	e8 bf ff ff ff       	call   8008eb <strcpy>
	return dst;
}
  80092c:	89 d8                	mov    %ebx,%eax
  80092e:	83 c4 08             	add    $0x8,%esp
  800931:	5b                   	pop    %ebx
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	56                   	push   %esi
  800938:	53                   	push   %ebx
  800939:	8b 75 08             	mov    0x8(%ebp),%esi
  80093c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800942:	85 db                	test   %ebx,%ebx
  800944:	74 16                	je     80095c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800946:	01 f3                	add    %esi,%ebx
  800948:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80094a:	0f b6 02             	movzbl (%edx),%eax
  80094d:	88 01                	mov    %al,(%ecx)
  80094f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800952:	80 3a 01             	cmpb   $0x1,(%edx)
  800955:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800958:	39 d9                	cmp    %ebx,%ecx
  80095a:	75 ee                	jne    80094a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80095c:	89 f0                	mov    %esi,%eax
  80095e:	5b                   	pop    %ebx
  80095f:	5e                   	pop    %esi
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	57                   	push   %edi
  800966:	56                   	push   %esi
  800967:	53                   	push   %ebx
  800968:	8b 7d 08             	mov    0x8(%ebp),%edi
  80096b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80096e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800971:	89 f8                	mov    %edi,%eax
  800973:	85 f6                	test   %esi,%esi
  800975:	74 33                	je     8009aa <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800977:	83 fe 01             	cmp    $0x1,%esi
  80097a:	74 25                	je     8009a1 <strlcpy+0x3f>
  80097c:	0f b6 0b             	movzbl (%ebx),%ecx
  80097f:	84 c9                	test   %cl,%cl
  800981:	74 22                	je     8009a5 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800983:	83 ee 02             	sub    $0x2,%esi
  800986:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80098b:	88 08                	mov    %cl,(%eax)
  80098d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800990:	39 f2                	cmp    %esi,%edx
  800992:	74 13                	je     8009a7 <strlcpy+0x45>
  800994:	83 c2 01             	add    $0x1,%edx
  800997:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80099b:	84 c9                	test   %cl,%cl
  80099d:	75 ec                	jne    80098b <strlcpy+0x29>
  80099f:	eb 06                	jmp    8009a7 <strlcpy+0x45>
  8009a1:	89 f8                	mov    %edi,%eax
  8009a3:	eb 02                	jmp    8009a7 <strlcpy+0x45>
  8009a5:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009a7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009aa:	29 f8                	sub    %edi,%eax
}
  8009ac:	5b                   	pop    %ebx
  8009ad:	5e                   	pop    %esi
  8009ae:	5f                   	pop    %edi
  8009af:	5d                   	pop    %ebp
  8009b0:	c3                   	ret    

008009b1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009ba:	0f b6 01             	movzbl (%ecx),%eax
  8009bd:	84 c0                	test   %al,%al
  8009bf:	74 15                	je     8009d6 <strcmp+0x25>
  8009c1:	3a 02                	cmp    (%edx),%al
  8009c3:	75 11                	jne    8009d6 <strcmp+0x25>
		p++, q++;
  8009c5:	83 c1 01             	add    $0x1,%ecx
  8009c8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009cb:	0f b6 01             	movzbl (%ecx),%eax
  8009ce:	84 c0                	test   %al,%al
  8009d0:	74 04                	je     8009d6 <strcmp+0x25>
  8009d2:	3a 02                	cmp    (%edx),%al
  8009d4:	74 ef                	je     8009c5 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d6:	0f b6 c0             	movzbl %al,%eax
  8009d9:	0f b6 12             	movzbl (%edx),%edx
  8009dc:	29 d0                	sub    %edx,%eax
}
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	56                   	push   %esi
  8009e4:	53                   	push   %ebx
  8009e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009eb:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8009ee:	85 f6                	test   %esi,%esi
  8009f0:	74 29                	je     800a1b <strncmp+0x3b>
  8009f2:	0f b6 03             	movzbl (%ebx),%eax
  8009f5:	84 c0                	test   %al,%al
  8009f7:	74 30                	je     800a29 <strncmp+0x49>
  8009f9:	3a 02                	cmp    (%edx),%al
  8009fb:	75 2c                	jne    800a29 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  8009fd:	8d 43 01             	lea    0x1(%ebx),%eax
  800a00:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800a02:	89 c3                	mov    %eax,%ebx
  800a04:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a07:	39 f0                	cmp    %esi,%eax
  800a09:	74 17                	je     800a22 <strncmp+0x42>
  800a0b:	0f b6 08             	movzbl (%eax),%ecx
  800a0e:	84 c9                	test   %cl,%cl
  800a10:	74 17                	je     800a29 <strncmp+0x49>
  800a12:	83 c0 01             	add    $0x1,%eax
  800a15:	3a 0a                	cmp    (%edx),%cl
  800a17:	74 e9                	je     800a02 <strncmp+0x22>
  800a19:	eb 0e                	jmp    800a29 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a20:	eb 0f                	jmp    800a31 <strncmp+0x51>
  800a22:	b8 00 00 00 00       	mov    $0x0,%eax
  800a27:	eb 08                	jmp    800a31 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a29:	0f b6 03             	movzbl (%ebx),%eax
  800a2c:	0f b6 12             	movzbl (%edx),%edx
  800a2f:	29 d0                	sub    %edx,%eax
}
  800a31:	5b                   	pop    %ebx
  800a32:	5e                   	pop    %esi
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	53                   	push   %ebx
  800a39:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a3f:	0f b6 18             	movzbl (%eax),%ebx
  800a42:	84 db                	test   %bl,%bl
  800a44:	74 1d                	je     800a63 <strchr+0x2e>
  800a46:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a48:	38 d3                	cmp    %dl,%bl
  800a4a:	75 06                	jne    800a52 <strchr+0x1d>
  800a4c:	eb 1a                	jmp    800a68 <strchr+0x33>
  800a4e:	38 ca                	cmp    %cl,%dl
  800a50:	74 16                	je     800a68 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a52:	83 c0 01             	add    $0x1,%eax
  800a55:	0f b6 10             	movzbl (%eax),%edx
  800a58:	84 d2                	test   %dl,%dl
  800a5a:	75 f2                	jne    800a4e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800a5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a61:	eb 05                	jmp    800a68 <strchr+0x33>
  800a63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a68:	5b                   	pop    %ebx
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	53                   	push   %ebx
  800a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a72:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a75:	0f b6 18             	movzbl (%eax),%ebx
  800a78:	84 db                	test   %bl,%bl
  800a7a:	74 16                	je     800a92 <strfind+0x27>
  800a7c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a7e:	38 d3                	cmp    %dl,%bl
  800a80:	75 06                	jne    800a88 <strfind+0x1d>
  800a82:	eb 0e                	jmp    800a92 <strfind+0x27>
  800a84:	38 ca                	cmp    %cl,%dl
  800a86:	74 0a                	je     800a92 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a88:	83 c0 01             	add    $0x1,%eax
  800a8b:	0f b6 10             	movzbl (%eax),%edx
  800a8e:	84 d2                	test   %dl,%dl
  800a90:	75 f2                	jne    800a84 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800a92:	5b                   	pop    %ebx
  800a93:	5d                   	pop    %ebp
  800a94:	c3                   	ret    

00800a95 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	83 ec 0c             	sub    $0xc,%esp
  800a9b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a9e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800aa1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800aa4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aa7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aaa:	85 c9                	test   %ecx,%ecx
  800aac:	74 36                	je     800ae4 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aae:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ab4:	75 28                	jne    800ade <memset+0x49>
  800ab6:	f6 c1 03             	test   $0x3,%cl
  800ab9:	75 23                	jne    800ade <memset+0x49>
		c &= 0xFF;
  800abb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800abf:	89 d3                	mov    %edx,%ebx
  800ac1:	c1 e3 08             	shl    $0x8,%ebx
  800ac4:	89 d6                	mov    %edx,%esi
  800ac6:	c1 e6 18             	shl    $0x18,%esi
  800ac9:	89 d0                	mov    %edx,%eax
  800acb:	c1 e0 10             	shl    $0x10,%eax
  800ace:	09 f0                	or     %esi,%eax
  800ad0:	09 c2                	or     %eax,%edx
  800ad2:	89 d0                	mov    %edx,%eax
  800ad4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ad6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ad9:	fc                   	cld    
  800ada:	f3 ab                	rep stos %eax,%es:(%edi)
  800adc:	eb 06                	jmp    800ae4 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ade:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae1:	fc                   	cld    
  800ae2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ae4:	89 f8                	mov    %edi,%eax
  800ae6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ae9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800aec:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800aef:	89 ec                	mov    %ebp,%esp
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	83 ec 08             	sub    $0x8,%esp
  800af9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800afc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800aff:	8b 45 08             	mov    0x8(%ebp),%eax
  800b02:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b08:	39 c6                	cmp    %eax,%esi
  800b0a:	73 36                	jae    800b42 <memmove+0x4f>
  800b0c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b0f:	39 d0                	cmp    %edx,%eax
  800b11:	73 2f                	jae    800b42 <memmove+0x4f>
		s += n;
		d += n;
  800b13:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b16:	f6 c2 03             	test   $0x3,%dl
  800b19:	75 1b                	jne    800b36 <memmove+0x43>
  800b1b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b21:	75 13                	jne    800b36 <memmove+0x43>
  800b23:	f6 c1 03             	test   $0x3,%cl
  800b26:	75 0e                	jne    800b36 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b28:	83 ef 04             	sub    $0x4,%edi
  800b2b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b2e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b31:	fd                   	std    
  800b32:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b34:	eb 09                	jmp    800b3f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b36:	83 ef 01             	sub    $0x1,%edi
  800b39:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b3c:	fd                   	std    
  800b3d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b3f:	fc                   	cld    
  800b40:	eb 20                	jmp    800b62 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b42:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b48:	75 13                	jne    800b5d <memmove+0x6a>
  800b4a:	a8 03                	test   $0x3,%al
  800b4c:	75 0f                	jne    800b5d <memmove+0x6a>
  800b4e:	f6 c1 03             	test   $0x3,%cl
  800b51:	75 0a                	jne    800b5d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b53:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b56:	89 c7                	mov    %eax,%edi
  800b58:	fc                   	cld    
  800b59:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b5b:	eb 05                	jmp    800b62 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b5d:	89 c7                	mov    %eax,%edi
  800b5f:	fc                   	cld    
  800b60:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b62:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b65:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b68:	89 ec                	mov    %ebp,%esp
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b72:	8b 45 10             	mov    0x10(%ebp),%eax
  800b75:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b80:	8b 45 08             	mov    0x8(%ebp),%eax
  800b83:	89 04 24             	mov    %eax,(%esp)
  800b86:	e8 68 ff ff ff       	call   800af3 <memmove>
}
  800b8b:	c9                   	leave  
  800b8c:	c3                   	ret    

00800b8d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	57                   	push   %edi
  800b91:	56                   	push   %esi
  800b92:	53                   	push   %ebx
  800b93:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b96:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b99:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b9c:	8d 78 ff             	lea    -0x1(%eax),%edi
  800b9f:	85 c0                	test   %eax,%eax
  800ba1:	74 36                	je     800bd9 <memcmp+0x4c>
		if (*s1 != *s2)
  800ba3:	0f b6 03             	movzbl (%ebx),%eax
  800ba6:	0f b6 0e             	movzbl (%esi),%ecx
  800ba9:	38 c8                	cmp    %cl,%al
  800bab:	75 17                	jne    800bc4 <memcmp+0x37>
  800bad:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb2:	eb 1a                	jmp    800bce <memcmp+0x41>
  800bb4:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800bb9:	83 c2 01             	add    $0x1,%edx
  800bbc:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800bc0:	38 c8                	cmp    %cl,%al
  800bc2:	74 0a                	je     800bce <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800bc4:	0f b6 c0             	movzbl %al,%eax
  800bc7:	0f b6 c9             	movzbl %cl,%ecx
  800bca:	29 c8                	sub    %ecx,%eax
  800bcc:	eb 10                	jmp    800bde <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bce:	39 fa                	cmp    %edi,%edx
  800bd0:	75 e2                	jne    800bb4 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bd2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd7:	eb 05                	jmp    800bde <memcmp+0x51>
  800bd9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	53                   	push   %ebx
  800be7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800bed:	89 c2                	mov    %eax,%edx
  800bef:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bf2:	39 d0                	cmp    %edx,%eax
  800bf4:	73 13                	jae    800c09 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bf6:	89 d9                	mov    %ebx,%ecx
  800bf8:	38 18                	cmp    %bl,(%eax)
  800bfa:	75 06                	jne    800c02 <memfind+0x1f>
  800bfc:	eb 0b                	jmp    800c09 <memfind+0x26>
  800bfe:	38 08                	cmp    %cl,(%eax)
  800c00:	74 07                	je     800c09 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c02:	83 c0 01             	add    $0x1,%eax
  800c05:	39 d0                	cmp    %edx,%eax
  800c07:	75 f5                	jne    800bfe <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c09:	5b                   	pop    %ebx
  800c0a:	5d                   	pop    %ebp
  800c0b:	c3                   	ret    

00800c0c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	57                   	push   %edi
  800c10:	56                   	push   %esi
  800c11:	53                   	push   %ebx
  800c12:	83 ec 04             	sub    $0x4,%esp
  800c15:	8b 55 08             	mov    0x8(%ebp),%edx
  800c18:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c1b:	0f b6 02             	movzbl (%edx),%eax
  800c1e:	3c 09                	cmp    $0x9,%al
  800c20:	74 04                	je     800c26 <strtol+0x1a>
  800c22:	3c 20                	cmp    $0x20,%al
  800c24:	75 0e                	jne    800c34 <strtol+0x28>
		s++;
  800c26:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c29:	0f b6 02             	movzbl (%edx),%eax
  800c2c:	3c 09                	cmp    $0x9,%al
  800c2e:	74 f6                	je     800c26 <strtol+0x1a>
  800c30:	3c 20                	cmp    $0x20,%al
  800c32:	74 f2                	je     800c26 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c34:	3c 2b                	cmp    $0x2b,%al
  800c36:	75 0a                	jne    800c42 <strtol+0x36>
		s++;
  800c38:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c3b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c40:	eb 10                	jmp    800c52 <strtol+0x46>
  800c42:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c47:	3c 2d                	cmp    $0x2d,%al
  800c49:	75 07                	jne    800c52 <strtol+0x46>
		s++, neg = 1;
  800c4b:	83 c2 01             	add    $0x1,%edx
  800c4e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c52:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c58:	75 15                	jne    800c6f <strtol+0x63>
  800c5a:	80 3a 30             	cmpb   $0x30,(%edx)
  800c5d:	75 10                	jne    800c6f <strtol+0x63>
  800c5f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c63:	75 0a                	jne    800c6f <strtol+0x63>
		s += 2, base = 16;
  800c65:	83 c2 02             	add    $0x2,%edx
  800c68:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c6d:	eb 10                	jmp    800c7f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800c6f:	85 db                	test   %ebx,%ebx
  800c71:	75 0c                	jne    800c7f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c73:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c75:	80 3a 30             	cmpb   $0x30,(%edx)
  800c78:	75 05                	jne    800c7f <strtol+0x73>
		s++, base = 8;
  800c7a:	83 c2 01             	add    $0x1,%edx
  800c7d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c84:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c87:	0f b6 0a             	movzbl (%edx),%ecx
  800c8a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c8d:	89 f3                	mov    %esi,%ebx
  800c8f:	80 fb 09             	cmp    $0x9,%bl
  800c92:	77 08                	ja     800c9c <strtol+0x90>
			dig = *s - '0';
  800c94:	0f be c9             	movsbl %cl,%ecx
  800c97:	83 e9 30             	sub    $0x30,%ecx
  800c9a:	eb 22                	jmp    800cbe <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800c9c:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c9f:	89 f3                	mov    %esi,%ebx
  800ca1:	80 fb 19             	cmp    $0x19,%bl
  800ca4:	77 08                	ja     800cae <strtol+0xa2>
			dig = *s - 'a' + 10;
  800ca6:	0f be c9             	movsbl %cl,%ecx
  800ca9:	83 e9 57             	sub    $0x57,%ecx
  800cac:	eb 10                	jmp    800cbe <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800cae:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800cb1:	89 f3                	mov    %esi,%ebx
  800cb3:	80 fb 19             	cmp    $0x19,%bl
  800cb6:	77 16                	ja     800cce <strtol+0xc2>
			dig = *s - 'A' + 10;
  800cb8:	0f be c9             	movsbl %cl,%ecx
  800cbb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cbe:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800cc1:	7d 0f                	jge    800cd2 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800cc3:	83 c2 01             	add    $0x1,%edx
  800cc6:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800cca:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ccc:	eb b9                	jmp    800c87 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800cce:	89 c1                	mov    %eax,%ecx
  800cd0:	eb 02                	jmp    800cd4 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cd2:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800cd4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cd8:	74 05                	je     800cdf <strtol+0xd3>
		*endptr = (char *) s;
  800cda:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cdd:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800cdf:	89 ca                	mov    %ecx,%edx
  800ce1:	f7 da                	neg    %edx
  800ce3:	85 ff                	test   %edi,%edi
  800ce5:	0f 45 c2             	cmovne %edx,%eax
}
  800ce8:	83 c4 04             	add    $0x4,%esp
  800ceb:	5b                   	pop    %ebx
  800cec:	5e                   	pop    %esi
  800ced:	5f                   	pop    %edi
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	83 ec 0c             	sub    $0xc,%esp
  800cf6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cf9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cfc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cff:	b8 00 00 00 00       	mov    $0x0,%eax
  800d04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d07:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0a:	89 c3                	mov    %eax,%ebx
  800d0c:	89 c7                	mov    %eax,%edi
  800d0e:	89 c6                	mov    %eax,%esi
  800d10:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d12:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d15:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d18:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d1b:	89 ec                	mov    %ebp,%esp
  800d1d:	5d                   	pop    %ebp
  800d1e:	c3                   	ret    

00800d1f <sys_cgetc>:

int
sys_cgetc(void)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	83 ec 0c             	sub    $0xc,%esp
  800d25:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d28:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d2b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d33:	b8 01 00 00 00       	mov    $0x1,%eax
  800d38:	89 d1                	mov    %edx,%ecx
  800d3a:	89 d3                	mov    %edx,%ebx
  800d3c:	89 d7                	mov    %edx,%edi
  800d3e:	89 d6                	mov    %edx,%esi
  800d40:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d42:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d45:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d48:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d4b:	89 ec                	mov    %ebp,%esp
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    

00800d4f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	83 ec 38             	sub    $0x38,%esp
  800d55:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d58:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d5b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d63:	b8 03 00 00 00       	mov    $0x3,%eax
  800d68:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6b:	89 cb                	mov    %ecx,%ebx
  800d6d:	89 cf                	mov    %ecx,%edi
  800d6f:	89 ce                	mov    %ecx,%esi
  800d71:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d73:	85 c0                	test   %eax,%eax
  800d75:	7e 28                	jle    800d9f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d77:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d7b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d82:	00 
  800d83:	c7 44 24 08 04 17 80 	movl   $0x801704,0x8(%esp)
  800d8a:	00 
  800d8b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d92:	00 
  800d93:	c7 04 24 21 17 80 00 	movl   $0x801721,(%esp)
  800d9a:	e8 d9 f3 ff ff       	call   800178 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d9f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800da2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800da5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800da8:	89 ec                	mov    %ebp,%esp
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    

00800dac <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	83 ec 0c             	sub    $0xc,%esp
  800db2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800db5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800db8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc0:	b8 02 00 00 00       	mov    $0x2,%eax
  800dc5:	89 d1                	mov    %edx,%ecx
  800dc7:	89 d3                	mov    %edx,%ebx
  800dc9:	89 d7                	mov    %edx,%edi
  800dcb:	89 d6                	mov    %edx,%esi
  800dcd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800dcf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dd2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dd5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dd8:	89 ec                	mov    %ebp,%esp
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    

00800ddc <sys_yield>:

void
sys_yield(void)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	83 ec 0c             	sub    $0xc,%esp
  800de2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800de5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800de8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800deb:	ba 00 00 00 00       	mov    $0x0,%edx
  800df0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800df5:	89 d1                	mov    %edx,%ecx
  800df7:	89 d3                	mov    %edx,%ebx
  800df9:	89 d7                	mov    %edx,%edi
  800dfb:	89 d6                	mov    %edx,%esi
  800dfd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dff:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e02:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e05:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e08:	89 ec                	mov    %ebp,%esp
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    

00800e0c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	83 ec 38             	sub    $0x38,%esp
  800e12:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e15:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e18:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1b:	be 00 00 00 00       	mov    $0x0,%esi
  800e20:	b8 04 00 00 00       	mov    $0x4,%eax
  800e25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e28:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e2e:	89 f7                	mov    %esi,%edi
  800e30:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e32:	85 c0                	test   %eax,%eax
  800e34:	7e 28                	jle    800e5e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e36:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e41:	00 
  800e42:	c7 44 24 08 04 17 80 	movl   $0x801704,0x8(%esp)
  800e49:	00 
  800e4a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e51:	00 
  800e52:	c7 04 24 21 17 80 00 	movl   $0x801721,(%esp)
  800e59:	e8 1a f3 ff ff       	call   800178 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e5e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e61:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e64:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e67:	89 ec                	mov    %ebp,%esp
  800e69:	5d                   	pop    %ebp
  800e6a:	c3                   	ret    

00800e6b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	83 ec 38             	sub    $0x38,%esp
  800e71:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e74:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e77:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e82:	8b 55 08             	mov    0x8(%ebp),%edx
  800e85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e88:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e8b:	8b 75 18             	mov    0x18(%ebp),%esi
  800e8e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e90:	85 c0                	test   %eax,%eax
  800e92:	7e 28                	jle    800ebc <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e94:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e98:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e9f:	00 
  800ea0:	c7 44 24 08 04 17 80 	movl   $0x801704,0x8(%esp)
  800ea7:	00 
  800ea8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eaf:	00 
  800eb0:	c7 04 24 21 17 80 00 	movl   $0x801721,(%esp)
  800eb7:	e8 bc f2 ff ff       	call   800178 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ebc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ebf:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ec2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ec5:	89 ec                	mov    %ebp,%esp
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    

00800ec9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
  800ecc:	83 ec 38             	sub    $0x38,%esp
  800ecf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ed2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ed5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800edd:	b8 06 00 00 00       	mov    $0x6,%eax
  800ee2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee8:	89 df                	mov    %ebx,%edi
  800eea:	89 de                	mov    %ebx,%esi
  800eec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eee:	85 c0                	test   %eax,%eax
  800ef0:	7e 28                	jle    800f1a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ef6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800efd:	00 
  800efe:	c7 44 24 08 04 17 80 	movl   $0x801704,0x8(%esp)
  800f05:	00 
  800f06:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f0d:	00 
  800f0e:	c7 04 24 21 17 80 00 	movl   $0x801721,(%esp)
  800f15:	e8 5e f2 ff ff       	call   800178 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f1a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f1d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f20:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f23:	89 ec                	mov    %ebp,%esp
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    

00800f27 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	83 ec 38             	sub    $0x38,%esp
  800f2d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f30:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f33:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f36:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f3b:	b8 08 00 00 00       	mov    $0x8,%eax
  800f40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f43:	8b 55 08             	mov    0x8(%ebp),%edx
  800f46:	89 df                	mov    %ebx,%edi
  800f48:	89 de                	mov    %ebx,%esi
  800f4a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f4c:	85 c0                	test   %eax,%eax
  800f4e:	7e 28                	jle    800f78 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f50:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f54:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f5b:	00 
  800f5c:	c7 44 24 08 04 17 80 	movl   $0x801704,0x8(%esp)
  800f63:	00 
  800f64:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f6b:	00 
  800f6c:	c7 04 24 21 17 80 00 	movl   $0x801721,(%esp)
  800f73:	e8 00 f2 ff ff       	call   800178 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f78:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f7b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f7e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f81:	89 ec                	mov    %ebp,%esp
  800f83:	5d                   	pop    %ebp
  800f84:	c3                   	ret    

00800f85 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f85:	55                   	push   %ebp
  800f86:	89 e5                	mov    %esp,%ebp
  800f88:	83 ec 38             	sub    $0x38,%esp
  800f8b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f8e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f91:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f94:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f99:	b8 09 00 00 00       	mov    $0x9,%eax
  800f9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa4:	89 df                	mov    %ebx,%edi
  800fa6:	89 de                	mov    %ebx,%esi
  800fa8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800faa:	85 c0                	test   %eax,%eax
  800fac:	7e 28                	jle    800fd6 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fae:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fb2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800fb9:	00 
  800fba:	c7 44 24 08 04 17 80 	movl   $0x801704,0x8(%esp)
  800fc1:	00 
  800fc2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fc9:	00 
  800fca:	c7 04 24 21 17 80 00 	movl   $0x801721,(%esp)
  800fd1:	e8 a2 f1 ff ff       	call   800178 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fd6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fd9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fdc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fdf:	89 ec                	mov    %ebp,%esp
  800fe1:	5d                   	pop    %ebp
  800fe2:	c3                   	ret    

00800fe3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	83 ec 0c             	sub    $0xc,%esp
  800fe9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fec:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fef:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff2:	be 00 00 00 00       	mov    $0x0,%esi
  800ff7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ffc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fff:	8b 55 08             	mov    0x8(%ebp),%edx
  801002:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801005:	8b 7d 14             	mov    0x14(%ebp),%edi
  801008:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80100a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80100d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801010:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801013:	89 ec                	mov    %ebp,%esp
  801015:	5d                   	pop    %ebp
  801016:	c3                   	ret    

00801017 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801017:	55                   	push   %ebp
  801018:	89 e5                	mov    %esp,%ebp
  80101a:	83 ec 38             	sub    $0x38,%esp
  80101d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801020:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801023:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801026:	b9 00 00 00 00       	mov    $0x0,%ecx
  80102b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801030:	8b 55 08             	mov    0x8(%ebp),%edx
  801033:	89 cb                	mov    %ecx,%ebx
  801035:	89 cf                	mov    %ecx,%edi
  801037:	89 ce                	mov    %ecx,%esi
  801039:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80103b:	85 c0                	test   %eax,%eax
  80103d:	7e 28                	jle    801067 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80103f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801043:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80104a:	00 
  80104b:	c7 44 24 08 04 17 80 	movl   $0x801704,0x8(%esp)
  801052:	00 
  801053:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80105a:	00 
  80105b:	c7 04 24 21 17 80 00 	movl   $0x801721,(%esp)
  801062:	e8 11 f1 ff ff       	call   800178 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801067:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80106a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80106d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801070:	89 ec                	mov    %ebp,%esp
  801072:	5d                   	pop    %ebp
  801073:	c3                   	ret    

00801074 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80107a:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801081:	75 60                	jne    8010e3 <set_pgfault_handler+0x6f>
		// First time through!
		// LAB 4: Your code here.
		int ret =
  801083:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80108a:	00 
  80108b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801092:	ee 
  801093:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80109a:	e8 6d fd ff ff       	call   800e0c <sys_page_alloc>
			sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE),
							PTE_U | PTE_P | PTE_W);
		if (ret < 0) {
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	79 2c                	jns    8010cf <set_pgfault_handler+0x5b>
			cprintf("%e\n", ret);
  8010a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010a7:	c7 04 24 2f 17 80 00 	movl   $0x80172f,(%esp)
  8010ae:	e8 c0 f1 ff ff       	call   800273 <cprintf>
			panic("Something wrong with allocation of user exception"
  8010b3:	c7 44 24 08 44 17 80 	movl   $0x801744,0x8(%esp)
  8010ba:	00 
  8010bb:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  8010c2:	00 
  8010c3:	c7 04 24 33 17 80 00 	movl   $0x801733,(%esp)
  8010ca:	e8 a9 f0 ff ff       	call   800178 <_panic>
				  "stack\n");
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8010cf:	c7 44 24 04 f0 10 80 	movl   $0x8010f0,0x4(%esp)
  8010d6:	00 
  8010d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010de:	e8 a2 fe ff ff       	call   800f85 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8010e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e6:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8010eb:	c9                   	leave  
  8010ec:	c3                   	ret    
  8010ed:	66 90                	xchg   %ax,%ax
  8010ef:	90                   	nop

008010f0 <_pgfault_upcall>:
  8010f0:	54                   	push   %esp
  8010f1:	a1 08 20 80 00       	mov    0x802008,%eax
  8010f6:	ff d0                	call   *%eax
  8010f8:	83 c4 04             	add    $0x4,%esp
  8010fb:	58                   	pop    %eax
  8010fc:	58                   	pop    %eax
  8010fd:	83 c4 20             	add    $0x20,%esp
  801100:	8b 04 24             	mov    (%esp),%eax
  801103:	83 c4 08             	add    $0x8,%esp
  801106:	8b 1c 24             	mov    (%esp),%ebx
  801109:	83 eb 04             	sub    $0x4,%ebx
  80110c:	89 1c 24             	mov    %ebx,(%esp)
  80110f:	89 03                	mov    %eax,(%ebx)
  801111:	83 ec 28             	sub    $0x28,%esp
  801114:	5f                   	pop    %edi
  801115:	5e                   	pop    %esi
  801116:	5d                   	pop    %ebp
  801117:	83 c4 04             	add    $0x4,%esp
  80111a:	5b                   	pop    %ebx
  80111b:	5a                   	pop    %edx
  80111c:	59                   	pop    %ecx
  80111d:	58                   	pop    %eax
  80111e:	83 c4 04             	add    $0x4,%esp
  801121:	9d                   	popf   
  801122:	8b 24 24             	mov    (%esp),%esp
  801125:	c3                   	ret    
  801126:	66 90                	xchg   %ax,%ax
  801128:	66 90                	xchg   %ax,%ax
  80112a:	66 90                	xchg   %ax,%ax
  80112c:	66 90                	xchg   %ax,%ax
  80112e:	66 90                	xchg   %ax,%ax

00801130 <__udivdi3>:
  801130:	83 ec 1c             	sub    $0x1c,%esp
  801133:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801137:	89 7c 24 14          	mov    %edi,0x14(%esp)
  80113b:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80113f:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801143:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801147:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  80114b:	85 c0                	test   %eax,%eax
  80114d:	89 74 24 10          	mov    %esi,0x10(%esp)
  801151:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801155:	89 ea                	mov    %ebp,%edx
  801157:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80115b:	75 33                	jne    801190 <__udivdi3+0x60>
  80115d:	39 e9                	cmp    %ebp,%ecx
  80115f:	77 6f                	ja     8011d0 <__udivdi3+0xa0>
  801161:	85 c9                	test   %ecx,%ecx
  801163:	89 ce                	mov    %ecx,%esi
  801165:	75 0b                	jne    801172 <__udivdi3+0x42>
  801167:	b8 01 00 00 00       	mov    $0x1,%eax
  80116c:	31 d2                	xor    %edx,%edx
  80116e:	f7 f1                	div    %ecx
  801170:	89 c6                	mov    %eax,%esi
  801172:	31 d2                	xor    %edx,%edx
  801174:	89 e8                	mov    %ebp,%eax
  801176:	f7 f6                	div    %esi
  801178:	89 c5                	mov    %eax,%ebp
  80117a:	89 f8                	mov    %edi,%eax
  80117c:	f7 f6                	div    %esi
  80117e:	89 ea                	mov    %ebp,%edx
  801180:	8b 74 24 10          	mov    0x10(%esp),%esi
  801184:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801188:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80118c:	83 c4 1c             	add    $0x1c,%esp
  80118f:	c3                   	ret    
  801190:	39 e8                	cmp    %ebp,%eax
  801192:	77 24                	ja     8011b8 <__udivdi3+0x88>
  801194:	0f bd c8             	bsr    %eax,%ecx
  801197:	83 f1 1f             	xor    $0x1f,%ecx
  80119a:	89 0c 24             	mov    %ecx,(%esp)
  80119d:	75 49                	jne    8011e8 <__udivdi3+0xb8>
  80119f:	8b 74 24 08          	mov    0x8(%esp),%esi
  8011a3:	39 74 24 04          	cmp    %esi,0x4(%esp)
  8011a7:	0f 86 ab 00 00 00    	jbe    801258 <__udivdi3+0x128>
  8011ad:	39 e8                	cmp    %ebp,%eax
  8011af:	0f 82 a3 00 00 00    	jb     801258 <__udivdi3+0x128>
  8011b5:	8d 76 00             	lea    0x0(%esi),%esi
  8011b8:	31 d2                	xor    %edx,%edx
  8011ba:	31 c0                	xor    %eax,%eax
  8011bc:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011c0:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011c4:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011c8:	83 c4 1c             	add    $0x1c,%esp
  8011cb:	c3                   	ret    
  8011cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011d0:	89 f8                	mov    %edi,%eax
  8011d2:	f7 f1                	div    %ecx
  8011d4:	31 d2                	xor    %edx,%edx
  8011d6:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011da:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011de:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011e2:	83 c4 1c             	add    $0x1c,%esp
  8011e5:	c3                   	ret    
  8011e6:	66 90                	xchg   %ax,%ax
  8011e8:	0f b6 0c 24          	movzbl (%esp),%ecx
  8011ec:	89 c6                	mov    %eax,%esi
  8011ee:	b8 20 00 00 00       	mov    $0x20,%eax
  8011f3:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  8011f7:	2b 04 24             	sub    (%esp),%eax
  8011fa:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011fe:	d3 e6                	shl    %cl,%esi
  801200:	89 c1                	mov    %eax,%ecx
  801202:	d3 ed                	shr    %cl,%ebp
  801204:	0f b6 0c 24          	movzbl (%esp),%ecx
  801208:	09 f5                	or     %esi,%ebp
  80120a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80120e:	d3 e6                	shl    %cl,%esi
  801210:	89 c1                	mov    %eax,%ecx
  801212:	89 74 24 04          	mov    %esi,0x4(%esp)
  801216:	89 d6                	mov    %edx,%esi
  801218:	d3 ee                	shr    %cl,%esi
  80121a:	0f b6 0c 24          	movzbl (%esp),%ecx
  80121e:	d3 e2                	shl    %cl,%edx
  801220:	89 c1                	mov    %eax,%ecx
  801222:	d3 ef                	shr    %cl,%edi
  801224:	09 d7                	or     %edx,%edi
  801226:	89 f2                	mov    %esi,%edx
  801228:	89 f8                	mov    %edi,%eax
  80122a:	f7 f5                	div    %ebp
  80122c:	89 d6                	mov    %edx,%esi
  80122e:	89 c7                	mov    %eax,%edi
  801230:	f7 64 24 04          	mull   0x4(%esp)
  801234:	39 d6                	cmp    %edx,%esi
  801236:	72 30                	jb     801268 <__udivdi3+0x138>
  801238:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  80123c:	0f b6 0c 24          	movzbl (%esp),%ecx
  801240:	d3 e5                	shl    %cl,%ebp
  801242:	39 c5                	cmp    %eax,%ebp
  801244:	73 04                	jae    80124a <__udivdi3+0x11a>
  801246:	39 d6                	cmp    %edx,%esi
  801248:	74 1e                	je     801268 <__udivdi3+0x138>
  80124a:	89 f8                	mov    %edi,%eax
  80124c:	31 d2                	xor    %edx,%edx
  80124e:	e9 69 ff ff ff       	jmp    8011bc <__udivdi3+0x8c>
  801253:	90                   	nop
  801254:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801258:	31 d2                	xor    %edx,%edx
  80125a:	b8 01 00 00 00       	mov    $0x1,%eax
  80125f:	e9 58 ff ff ff       	jmp    8011bc <__udivdi3+0x8c>
  801264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801268:	8d 47 ff             	lea    -0x1(%edi),%eax
  80126b:	31 d2                	xor    %edx,%edx
  80126d:	8b 74 24 10          	mov    0x10(%esp),%esi
  801271:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801275:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801279:	83 c4 1c             	add    $0x1c,%esp
  80127c:	c3                   	ret    
  80127d:	66 90                	xchg   %ax,%ax
  80127f:	90                   	nop

00801280 <__umoddi3>:
  801280:	83 ec 2c             	sub    $0x2c,%esp
  801283:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801287:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80128b:	89 74 24 20          	mov    %esi,0x20(%esp)
  80128f:	8b 74 24 38          	mov    0x38(%esp),%esi
  801293:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801297:	8b 7c 24 34          	mov    0x34(%esp),%edi
  80129b:	85 c0                	test   %eax,%eax
  80129d:	89 c2                	mov    %eax,%edx
  80129f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  8012a3:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8012a7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012ab:	89 74 24 10          	mov    %esi,0x10(%esp)
  8012af:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8012b3:	89 7c 24 18          	mov    %edi,0x18(%esp)
  8012b7:	75 1f                	jne    8012d8 <__umoddi3+0x58>
  8012b9:	39 fe                	cmp    %edi,%esi
  8012bb:	76 63                	jbe    801320 <__umoddi3+0xa0>
  8012bd:	89 c8                	mov    %ecx,%eax
  8012bf:	89 fa                	mov    %edi,%edx
  8012c1:	f7 f6                	div    %esi
  8012c3:	89 d0                	mov    %edx,%eax
  8012c5:	31 d2                	xor    %edx,%edx
  8012c7:	8b 74 24 20          	mov    0x20(%esp),%esi
  8012cb:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8012cf:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8012d3:	83 c4 2c             	add    $0x2c,%esp
  8012d6:	c3                   	ret    
  8012d7:	90                   	nop
  8012d8:	39 f8                	cmp    %edi,%eax
  8012da:	77 64                	ja     801340 <__umoddi3+0xc0>
  8012dc:	0f bd e8             	bsr    %eax,%ebp
  8012df:	83 f5 1f             	xor    $0x1f,%ebp
  8012e2:	75 74                	jne    801358 <__umoddi3+0xd8>
  8012e4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8012e8:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  8012ec:	0f 87 0e 01 00 00    	ja     801400 <__umoddi3+0x180>
  8012f2:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  8012f6:	29 f1                	sub    %esi,%ecx
  8012f8:	19 c7                	sbb    %eax,%edi
  8012fa:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8012fe:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801302:	8b 44 24 14          	mov    0x14(%esp),%eax
  801306:	8b 54 24 18          	mov    0x18(%esp),%edx
  80130a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80130e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801312:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801316:	83 c4 2c             	add    $0x2c,%esp
  801319:	c3                   	ret    
  80131a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801320:	85 f6                	test   %esi,%esi
  801322:	89 f5                	mov    %esi,%ebp
  801324:	75 0b                	jne    801331 <__umoddi3+0xb1>
  801326:	b8 01 00 00 00       	mov    $0x1,%eax
  80132b:	31 d2                	xor    %edx,%edx
  80132d:	f7 f6                	div    %esi
  80132f:	89 c5                	mov    %eax,%ebp
  801331:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801335:	31 d2                	xor    %edx,%edx
  801337:	f7 f5                	div    %ebp
  801339:	89 c8                	mov    %ecx,%eax
  80133b:	f7 f5                	div    %ebp
  80133d:	eb 84                	jmp    8012c3 <__umoddi3+0x43>
  80133f:	90                   	nop
  801340:	89 c8                	mov    %ecx,%eax
  801342:	89 fa                	mov    %edi,%edx
  801344:	8b 74 24 20          	mov    0x20(%esp),%esi
  801348:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80134c:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801350:	83 c4 2c             	add    $0x2c,%esp
  801353:	c3                   	ret    
  801354:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801358:	8b 44 24 10          	mov    0x10(%esp),%eax
  80135c:	be 20 00 00 00       	mov    $0x20,%esi
  801361:	89 e9                	mov    %ebp,%ecx
  801363:	29 ee                	sub    %ebp,%esi
  801365:	d3 e2                	shl    %cl,%edx
  801367:	89 f1                	mov    %esi,%ecx
  801369:	d3 e8                	shr    %cl,%eax
  80136b:	89 e9                	mov    %ebp,%ecx
  80136d:	09 d0                	or     %edx,%eax
  80136f:	89 fa                	mov    %edi,%edx
  801371:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801375:	8b 44 24 10          	mov    0x10(%esp),%eax
  801379:	d3 e0                	shl    %cl,%eax
  80137b:	89 f1                	mov    %esi,%ecx
  80137d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801381:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801385:	d3 ea                	shr    %cl,%edx
  801387:	89 e9                	mov    %ebp,%ecx
  801389:	d3 e7                	shl    %cl,%edi
  80138b:	89 f1                	mov    %esi,%ecx
  80138d:	d3 e8                	shr    %cl,%eax
  80138f:	89 e9                	mov    %ebp,%ecx
  801391:	09 f8                	or     %edi,%eax
  801393:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801397:	f7 74 24 0c          	divl   0xc(%esp)
  80139b:	d3 e7                	shl    %cl,%edi
  80139d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  8013a1:	89 d7                	mov    %edx,%edi
  8013a3:	f7 64 24 10          	mull   0x10(%esp)
  8013a7:	39 d7                	cmp    %edx,%edi
  8013a9:	89 c1                	mov    %eax,%ecx
  8013ab:	89 54 24 14          	mov    %edx,0x14(%esp)
  8013af:	72 3b                	jb     8013ec <__umoddi3+0x16c>
  8013b1:	39 44 24 18          	cmp    %eax,0x18(%esp)
  8013b5:	72 31                	jb     8013e8 <__umoddi3+0x168>
  8013b7:	8b 44 24 18          	mov    0x18(%esp),%eax
  8013bb:	29 c8                	sub    %ecx,%eax
  8013bd:	19 d7                	sbb    %edx,%edi
  8013bf:	89 e9                	mov    %ebp,%ecx
  8013c1:	89 fa                	mov    %edi,%edx
  8013c3:	d3 e8                	shr    %cl,%eax
  8013c5:	89 f1                	mov    %esi,%ecx
  8013c7:	d3 e2                	shl    %cl,%edx
  8013c9:	89 e9                	mov    %ebp,%ecx
  8013cb:	09 d0                	or     %edx,%eax
  8013cd:	89 fa                	mov    %edi,%edx
  8013cf:	d3 ea                	shr    %cl,%edx
  8013d1:	8b 74 24 20          	mov    0x20(%esp),%esi
  8013d5:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8013d9:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8013dd:	83 c4 2c             	add    $0x2c,%esp
  8013e0:	c3                   	ret    
  8013e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013e8:	39 d7                	cmp    %edx,%edi
  8013ea:	75 cb                	jne    8013b7 <__umoddi3+0x137>
  8013ec:	8b 54 24 14          	mov    0x14(%esp),%edx
  8013f0:	89 c1                	mov    %eax,%ecx
  8013f2:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  8013f6:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  8013fa:	eb bb                	jmp    8013b7 <__umoddi3+0x137>
  8013fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801400:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801404:	0f 82 e8 fe ff ff    	jb     8012f2 <__umoddi3+0x72>
  80140a:	e9 f3 fe ff ff       	jmp    801302 <__umoddi3+0x82>
