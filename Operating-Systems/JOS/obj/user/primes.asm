
obj/user/primes:     file format elf32-i386


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
  80002c:	e8 1f 01 00 00       	call   800150 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003d:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800040:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800047:	00 
  800048:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004f:	00 
  800050:	89 34 24             	mov    %esi,(%esp)
  800053:	e8 b8 13 00 00       	call   801410 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80005a:	a1 04 20 80 00       	mov    0x802004,%eax
  80005f:	8b 40 5c             	mov    0x5c(%eax),%eax
  800062:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	c7 04 24 e0 18 80 00 	movl   $0x8018e0,(%esp)
  800071:	e8 45 02 00 00       	call   8002bb <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800076:	e8 4e 11 00 00       	call   8011c9 <fork>
  80007b:	89 c7                	mov    %eax,%edi
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 20                	jns    8000a1 <primeproc+0x6d>
		panic("fork: %e", id);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 ec 18 80 	movl   $0x8018ec,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 f5 18 80 00 	movl   $0x8018f5,(%esp)
  80009c:	e8 1f 01 00 00       	call   8001c0 <_panic>
	if (id == 0)
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	74 9b                	je     800040 <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  8000a5:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000af:	00 
  8000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b7:	00 
  8000b8:	89 34 24             	mov    %esi,(%esp)
  8000bb:	e8 50 13 00 00       	call   801410 <ipc_recv>
  8000c0:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000c2:	89 c2                	mov    %eax,%edx
  8000c4:	c1 fa 1f             	sar    $0x1f,%edx
  8000c7:	f7 fb                	idiv   %ebx
  8000c9:	85 d2                	test   %edx,%edx
  8000cb:	74 db                	je     8000a8 <primeproc+0x74>
			ipc_send(id, i, 0, 0);
  8000cd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d4:	00 
  8000d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000dc:	00 
  8000dd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000e1:	89 3c 24             	mov    %edi,(%esp)
  8000e4:	e8 9f 13 00 00       	call   801488 <ipc_send>
  8000e9:	eb bd                	jmp    8000a8 <primeproc+0x74>

008000eb <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000f3:	e8 d1 10 00 00       	call   8011c9 <fork>
  8000f8:	89 c6                	mov    %eax,%esi
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 20                	jns    80011e <umain+0x33>
		panic("fork: %e", id);
  8000fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800102:	c7 44 24 08 ec 18 80 	movl   $0x8018ec,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 f5 18 80 00 	movl   $0x8018f5,(%esp)
  800119:	e8 a2 00 00 00       	call   8001c0 <_panic>
	if (id == 0)
  80011e:	bb 02 00 00 00       	mov    $0x2,%ebx
  800123:	85 c0                	test   %eax,%eax
  800125:	75 05                	jne    80012c <umain+0x41>
		primeproc();
  800127:	e8 08 ff ff ff       	call   800034 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  80012c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800133:	00 
  800134:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80013b:	00 
  80013c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800140:	89 34 24             	mov    %esi,(%esp)
  800143:	e8 40 13 00 00       	call   801488 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  800148:	83 c3 01             	add    $0x1,%ebx
  80014b:	eb df                	jmp    80012c <umain+0x41>
  80014d:	66 90                	xchg   %ax,%ax
  80014f:	90                   	nop

00800150 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 18             	sub    $0x18,%esp
  800156:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800159:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80015c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80015f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800162:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800169:	00 00 00 
	int envid;
	envid = sys_getenvid();
  80016c:	e8 8b 0c 00 00       	call   800dfc <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800171:	25 ff 03 00 00       	and    $0x3ff,%eax
  800176:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800179:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80017e:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800183:	85 db                	test   %ebx,%ebx
  800185:	7e 07                	jle    80018e <libmain+0x3e>
		binaryname = argv[0];
  800187:	8b 06                	mov    (%esi),%eax
  800189:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80018e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800192:	89 1c 24             	mov    %ebx,(%esp)
  800195:	e8 51 ff ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  80019a:	e8 0d 00 00 00       	call   8001ac <exit>
}
  80019f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8001a2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8001a5:	89 ec                	mov    %ebp,%esp
  8001a7:	5d                   	pop    %ebp
  8001a8:	c3                   	ret    
  8001a9:	66 90                	xchg   %ax,%ax
  8001ab:	90                   	nop

008001ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8001b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001b9:	e8 e1 0b 00 00       	call   800d9f <sys_env_destroy>
}
  8001be:	c9                   	leave  
  8001bf:	c3                   	ret    

008001c0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	56                   	push   %esi
  8001c4:	53                   	push   %ebx
  8001c5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001c8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001cb:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8001d1:	e8 26 0c 00 00       	call   800dfc <sys_getenvid>
  8001d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001e4:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ec:	c7 04 24 10 19 80 00 	movl   $0x801910,(%esp)
  8001f3:	e8 c3 00 00 00       	call   8002bb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ff:	89 04 24             	mov    %eax,(%esp)
  800202:	e8 53 00 00 00       	call   80025a <vcprintf>
	cprintf("\n");
  800207:	c7 04 24 ff 1c 80 00 	movl   $0x801cff,(%esp)
  80020e:	e8 a8 00 00 00       	call   8002bb <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800213:	cc                   	int3   
  800214:	eb fd                	jmp    800213 <_panic+0x53>
  800216:	66 90                	xchg   %ax,%ax

00800218 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	53                   	push   %ebx
  80021c:	83 ec 14             	sub    $0x14,%esp
  80021f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800222:	8b 03                	mov    (%ebx),%eax
  800224:	8b 55 08             	mov    0x8(%ebp),%edx
  800227:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80022b:	83 c0 01             	add    $0x1,%eax
  80022e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800230:	3d ff 00 00 00       	cmp    $0xff,%eax
  800235:	75 19                	jne    800250 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800237:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80023e:	00 
  80023f:	8d 43 08             	lea    0x8(%ebx),%eax
  800242:	89 04 24             	mov    %eax,(%esp)
  800245:	e8 f6 0a 00 00       	call   800d40 <sys_cputs>
		b->idx = 0;
  80024a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800250:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800254:	83 c4 14             	add    $0x14,%esp
  800257:	5b                   	pop    %ebx
  800258:	5d                   	pop    %ebp
  800259:	c3                   	ret    

0080025a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80025a:	55                   	push   %ebp
  80025b:	89 e5                	mov    %esp,%ebp
  80025d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800263:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80026a:	00 00 00 
	b.cnt = 0;
  80026d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800274:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800277:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	89 44 24 08          	mov    %eax,0x8(%esp)
  800285:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80028b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028f:	c7 04 24 18 02 80 00 	movl   $0x800218,(%esp)
  800296:	e8 b7 01 00 00       	call   800452 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80029b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002ab:	89 04 24             	mov    %eax,(%esp)
  8002ae:	e8 8d 0a 00 00       	call   800d40 <sys_cputs>

	return b.cnt;
}
  8002b3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002b9:	c9                   	leave  
  8002ba:	c3                   	ret    

008002bb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cb:	89 04 24             	mov    %eax,(%esp)
  8002ce:	e8 87 ff ff ff       	call   80025a <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d3:	c9                   	leave  
  8002d4:	c3                   	ret    
  8002d5:	66 90                	xchg   %ax,%ax
  8002d7:	66 90                	xchg   %ax,%ax
  8002d9:	66 90                	xchg   %ax,%ax
  8002db:	66 90                	xchg   %ax,%ax
  8002dd:	66 90                	xchg   %ax,%ax
  8002df:	90                   	nop

008002e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
  8002e6:	83 ec 4c             	sub    $0x4c,%esp
  8002e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002ec:	89 d7                	mov    %edx,%edi
  8002ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002f1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8002f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8002ff:	39 d8                	cmp    %ebx,%eax
  800301:	72 17                	jb     80031a <printnum+0x3a>
  800303:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800306:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  800309:	76 0f                	jbe    80031a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80030b:	8b 75 14             	mov    0x14(%ebp),%esi
  80030e:	83 ee 01             	sub    $0x1,%esi
  800311:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800314:	85 f6                	test   %esi,%esi
  800316:	7f 63                	jg     80037b <printnum+0x9b>
  800318:	eb 75                	jmp    80038f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80031a:	8b 5d 18             	mov    0x18(%ebp),%ebx
  80031d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800321:	8b 45 14             	mov    0x14(%ebp),%eax
  800324:	83 e8 01             	sub    $0x1,%eax
  800327:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80032b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80032e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800332:	8b 44 24 08          	mov    0x8(%esp),%eax
  800336:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80033a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80033d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800340:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800347:	00 
  800348:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80034b:	89 1c 24             	mov    %ebx,(%esp)
  80034e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800351:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800355:	e8 96 12 00 00       	call   8015f0 <__udivdi3>
  80035a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80035d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800360:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800364:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800368:	89 04 24             	mov    %eax,(%esp)
  80036b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80036f:	89 fa                	mov    %edi,%edx
  800371:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800374:	e8 67 ff ff ff       	call   8002e0 <printnum>
  800379:	eb 14                	jmp    80038f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80037b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80037f:	8b 45 18             	mov    0x18(%ebp),%eax
  800382:	89 04 24             	mov    %eax,(%esp)
  800385:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800387:	83 ee 01             	sub    $0x1,%esi
  80038a:	75 ef                	jne    80037b <printnum+0x9b>
  80038c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80038f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800393:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800397:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80039a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80039e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003a5:	00 
  8003a6:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8003a9:	89 1c 24             	mov    %ebx,(%esp)
  8003ac:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8003af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003b3:	e8 88 13 00 00       	call   801740 <__umoddi3>
  8003b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003bc:	0f be 80 33 19 80 00 	movsbl 0x801933(%eax),%eax
  8003c3:	89 04 24             	mov    %eax,(%esp)
  8003c6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003c9:	ff d0                	call   *%eax
}
  8003cb:	83 c4 4c             	add    $0x4c,%esp
  8003ce:	5b                   	pop    %ebx
  8003cf:	5e                   	pop    %esi
  8003d0:	5f                   	pop    %edi
  8003d1:	5d                   	pop    %ebp
  8003d2:	c3                   	ret    

008003d3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d6:	83 fa 01             	cmp    $0x1,%edx
  8003d9:	7e 0e                	jle    8003e9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003db:	8b 10                	mov    (%eax),%edx
  8003dd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003e0:	89 08                	mov    %ecx,(%eax)
  8003e2:	8b 02                	mov    (%edx),%eax
  8003e4:	8b 52 04             	mov    0x4(%edx),%edx
  8003e7:	eb 22                	jmp    80040b <getuint+0x38>
	else if (lflag)
  8003e9:	85 d2                	test   %edx,%edx
  8003eb:	74 10                	je     8003fd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ed:	8b 10                	mov    (%eax),%edx
  8003ef:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f2:	89 08                	mov    %ecx,(%eax)
  8003f4:	8b 02                	mov    (%edx),%eax
  8003f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fb:	eb 0e                	jmp    80040b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003fd:	8b 10                	mov    (%eax),%edx
  8003ff:	8d 4a 04             	lea    0x4(%edx),%ecx
  800402:	89 08                	mov    %ecx,(%eax)
  800404:	8b 02                	mov    (%edx),%eax
  800406:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80040b:	5d                   	pop    %ebp
  80040c:	c3                   	ret    

0080040d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80040d:	55                   	push   %ebp
  80040e:	89 e5                	mov    %esp,%ebp
  800410:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800413:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800417:	8b 10                	mov    (%eax),%edx
  800419:	3b 50 04             	cmp    0x4(%eax),%edx
  80041c:	73 0a                	jae    800428 <sprintputch+0x1b>
		*b->buf++ = ch;
  80041e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800421:	88 0a                	mov    %cl,(%edx)
  800423:	83 c2 01             	add    $0x1,%edx
  800426:	89 10                	mov    %edx,(%eax)
}
  800428:	5d                   	pop    %ebp
  800429:	c3                   	ret    

0080042a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800430:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800433:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800437:	8b 45 10             	mov    0x10(%ebp),%eax
  80043a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80043e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800441:	89 44 24 04          	mov    %eax,0x4(%esp)
  800445:	8b 45 08             	mov    0x8(%ebp),%eax
  800448:	89 04 24             	mov    %eax,(%esp)
  80044b:	e8 02 00 00 00       	call   800452 <vprintfmt>
	va_end(ap);
}
  800450:	c9                   	leave  
  800451:	c3                   	ret    

00800452 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800452:	55                   	push   %ebp
  800453:	89 e5                	mov    %esp,%ebp
  800455:	57                   	push   %edi
  800456:	56                   	push   %esi
  800457:	53                   	push   %ebx
  800458:	83 ec 4c             	sub    $0x4c,%esp
  80045b:	8b 75 08             	mov    0x8(%ebp),%esi
  80045e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800461:	8b 7d 10             	mov    0x10(%ebp),%edi
  800464:	eb 11                	jmp    800477 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800466:	85 c0                	test   %eax,%eax
  800468:	0f 84 db 03 00 00    	je     800849 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  80046e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800472:	89 04 24             	mov    %eax,(%esp)
  800475:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800477:	0f b6 07             	movzbl (%edi),%eax
  80047a:	83 c7 01             	add    $0x1,%edi
  80047d:	83 f8 25             	cmp    $0x25,%eax
  800480:	75 e4                	jne    800466 <vprintfmt+0x14>
  800482:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800486:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80048d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800494:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80049b:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a0:	eb 2b                	jmp    8004cd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a5:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  8004a9:	eb 22                	jmp    8004cd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004ae:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  8004b2:	eb 19                	jmp    8004cd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004b7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004be:	eb 0d                	jmp    8004cd <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c6:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cd:	0f b6 0f             	movzbl (%edi),%ecx
  8004d0:	8d 47 01             	lea    0x1(%edi),%eax
  8004d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d6:	0f b6 07             	movzbl (%edi),%eax
  8004d9:	83 e8 23             	sub    $0x23,%eax
  8004dc:	3c 55                	cmp    $0x55,%al
  8004de:	0f 87 40 03 00 00    	ja     800824 <vprintfmt+0x3d2>
  8004e4:	0f b6 c0             	movzbl %al,%eax
  8004e7:	ff 24 85 00 1a 80 00 	jmp    *0x801a00(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004ee:	83 e9 30             	sub    $0x30,%ecx
  8004f1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  8004f4:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  8004f8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004fb:	83 f9 09             	cmp    $0x9,%ecx
  8004fe:	77 57                	ja     800557 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800500:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800503:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800506:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800509:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80050c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80050f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800513:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800516:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800519:	83 f9 09             	cmp    $0x9,%ecx
  80051c:	76 eb                	jbe    800509 <vprintfmt+0xb7>
  80051e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800521:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800524:	eb 34                	jmp    80055a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800526:	8b 45 14             	mov    0x14(%ebp),%eax
  800529:	8d 48 04             	lea    0x4(%eax),%ecx
  80052c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80052f:	8b 00                	mov    (%eax),%eax
  800531:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800534:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800537:	eb 21                	jmp    80055a <vprintfmt+0x108>

		case '.':
			if (width < 0)
  800539:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80053d:	0f 88 71 ff ff ff    	js     8004b4 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800543:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800546:	eb 85                	jmp    8004cd <vprintfmt+0x7b>
  800548:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80054b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800552:	e9 76 ff ff ff       	jmp    8004cd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800557:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80055a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80055e:	0f 89 69 ff ff ff    	jns    8004cd <vprintfmt+0x7b>
  800564:	e9 57 ff ff ff       	jmp    8004c0 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800569:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80056f:	e9 59 ff ff ff       	jmp    8004cd <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 50 04             	lea    0x4(%eax),%edx
  80057a:	89 55 14             	mov    %edx,0x14(%ebp)
  80057d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800581:	8b 00                	mov    (%eax),%eax
  800583:	89 04 24             	mov    %eax,(%esp)
  800586:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800588:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80058b:	e9 e7 fe ff ff       	jmp    800477 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8d 50 04             	lea    0x4(%eax),%edx
  800596:	89 55 14             	mov    %edx,0x14(%ebp)
  800599:	8b 00                	mov    (%eax),%eax
  80059b:	89 c2                	mov    %eax,%edx
  80059d:	c1 fa 1f             	sar    $0x1f,%edx
  8005a0:	31 d0                	xor    %edx,%eax
  8005a2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005a4:	83 f8 08             	cmp    $0x8,%eax
  8005a7:	7f 0b                	jg     8005b4 <vprintfmt+0x162>
  8005a9:	8b 14 85 60 1b 80 00 	mov    0x801b60(,%eax,4),%edx
  8005b0:	85 d2                	test   %edx,%edx
  8005b2:	75 20                	jne    8005d4 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  8005b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005b8:	c7 44 24 08 4b 19 80 	movl   $0x80194b,0x8(%esp)
  8005bf:	00 
  8005c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c4:	89 34 24             	mov    %esi,(%esp)
  8005c7:	e8 5e fe ff ff       	call   80042a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cc:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005cf:	e9 a3 fe ff ff       	jmp    800477 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8005d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005d8:	c7 44 24 08 54 19 80 	movl   $0x801954,0x8(%esp)
  8005df:	00 
  8005e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e4:	89 34 24             	mov    %esi,(%esp)
  8005e7:	e8 3e fe ff ff       	call   80042a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ec:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005ef:	e9 83 fe ff ff       	jmp    800477 <vprintfmt+0x25>
  8005f4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005f7:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8005fa:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8d 50 04             	lea    0x4(%eax),%edx
  800603:	89 55 14             	mov    %edx,0x14(%ebp)
  800606:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800608:	85 ff                	test   %edi,%edi
  80060a:	b8 44 19 80 00       	mov    $0x801944,%eax
  80060f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800612:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  800616:	74 06                	je     80061e <vprintfmt+0x1cc>
  800618:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80061c:	7f 16                	jg     800634 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80061e:	0f b6 17             	movzbl (%edi),%edx
  800621:	0f be c2             	movsbl %dl,%eax
  800624:	83 c7 01             	add    $0x1,%edi
  800627:	85 c0                	test   %eax,%eax
  800629:	0f 85 9f 00 00 00    	jne    8006ce <vprintfmt+0x27c>
  80062f:	e9 8b 00 00 00       	jmp    8006bf <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800634:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800638:	89 3c 24             	mov    %edi,(%esp)
  80063b:	e8 c2 02 00 00       	call   800902 <strnlen>
  800640:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800643:	29 c2                	sub    %eax,%edx
  800645:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800648:	85 d2                	test   %edx,%edx
  80064a:	7e d2                	jle    80061e <vprintfmt+0x1cc>
					putch(padc, putdat);
  80064c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  800650:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800653:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800656:	89 d7                	mov    %edx,%edi
  800658:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80065f:	89 04 24             	mov    %eax,(%esp)
  800662:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800664:	83 ef 01             	sub    $0x1,%edi
  800667:	75 ef                	jne    800658 <vprintfmt+0x206>
  800669:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80066c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80066f:	eb ad                	jmp    80061e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800671:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800675:	74 20                	je     800697 <vprintfmt+0x245>
  800677:	0f be d2             	movsbl %dl,%edx
  80067a:	83 ea 20             	sub    $0x20,%edx
  80067d:	83 fa 5e             	cmp    $0x5e,%edx
  800680:	76 15                	jbe    800697 <vprintfmt+0x245>
					putch('?', putdat);
  800682:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800685:	89 54 24 04          	mov    %edx,0x4(%esp)
  800689:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800690:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800693:	ff d1                	call   *%ecx
  800695:	eb 0f                	jmp    8006a6 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800697:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80069a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80069e:	89 04 24             	mov    %eax,(%esp)
  8006a1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006a4:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006a6:	83 eb 01             	sub    $0x1,%ebx
  8006a9:	0f b6 17             	movzbl (%edi),%edx
  8006ac:	0f be c2             	movsbl %dl,%eax
  8006af:	83 c7 01             	add    $0x1,%edi
  8006b2:	85 c0                	test   %eax,%eax
  8006b4:	75 24                	jne    8006da <vprintfmt+0x288>
  8006b6:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8006b9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006bc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bf:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006c2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006c6:	0f 8e ab fd ff ff    	jle    800477 <vprintfmt+0x25>
  8006cc:	eb 20                	jmp    8006ee <vprintfmt+0x29c>
  8006ce:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8006d1:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006d4:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8006d7:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006da:	85 f6                	test   %esi,%esi
  8006dc:	78 93                	js     800671 <vprintfmt+0x21f>
  8006de:	83 ee 01             	sub    $0x1,%esi
  8006e1:	79 8e                	jns    800671 <vprintfmt+0x21f>
  8006e3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8006e6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006e9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8006ec:	eb d1                	jmp    8006bf <vprintfmt+0x26d>
  8006ee:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006fc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006fe:	83 ef 01             	sub    $0x1,%edi
  800701:	75 ee                	jne    8006f1 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800703:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800706:	e9 6c fd ff ff       	jmp    800477 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80070b:	83 fa 01             	cmp    $0x1,%edx
  80070e:	66 90                	xchg   %ax,%ax
  800710:	7e 16                	jle    800728 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  800712:	8b 45 14             	mov    0x14(%ebp),%eax
  800715:	8d 50 08             	lea    0x8(%eax),%edx
  800718:	89 55 14             	mov    %edx,0x14(%ebp)
  80071b:	8b 10                	mov    (%eax),%edx
  80071d:	8b 48 04             	mov    0x4(%eax),%ecx
  800720:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800723:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800726:	eb 32                	jmp    80075a <vprintfmt+0x308>
	else if (lflag)
  800728:	85 d2                	test   %edx,%edx
  80072a:	74 18                	je     800744 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8d 50 04             	lea    0x4(%eax),%edx
  800732:	89 55 14             	mov    %edx,0x14(%ebp)
  800735:	8b 00                	mov    (%eax),%eax
  800737:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80073a:	89 c1                	mov    %eax,%ecx
  80073c:	c1 f9 1f             	sar    $0x1f,%ecx
  80073f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800742:	eb 16                	jmp    80075a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  800744:	8b 45 14             	mov    0x14(%ebp),%eax
  800747:	8d 50 04             	lea    0x4(%eax),%edx
  80074a:	89 55 14             	mov    %edx,0x14(%ebp)
  80074d:	8b 00                	mov    (%eax),%eax
  80074f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800752:	89 c7                	mov    %eax,%edi
  800754:	c1 ff 1f             	sar    $0x1f,%edi
  800757:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80075a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80075d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800760:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800765:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800769:	79 7d                	jns    8007e8 <vprintfmt+0x396>
				putch('-', putdat);
  80076b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800776:	ff d6                	call   *%esi
				num = -(long long) num;
  800778:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80077b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80077e:	f7 d8                	neg    %eax
  800780:	83 d2 00             	adc    $0x0,%edx
  800783:	f7 da                	neg    %edx
			}
			base = 10;
  800785:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80078a:	eb 5c                	jmp    8007e8 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80078c:	8d 45 14             	lea    0x14(%ebp),%eax
  80078f:	e8 3f fc ff ff       	call   8003d3 <getuint>
			base = 10;
  800794:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800799:	eb 4d                	jmp    8007e8 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80079b:	8d 45 14             	lea    0x14(%ebp),%eax
  80079e:	e8 30 fc ff ff       	call   8003d3 <getuint>
			base = 8;
  8007a3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007a8:	eb 3e                	jmp    8007e8 <vprintfmt+0x396>

		// pointer
		case 'p':
			putch('0', putdat);
  8007aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ae:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007b5:	ff d6                	call   *%esi
			putch('x', putdat);
  8007b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007bb:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007c2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c7:	8d 50 04             	lea    0x4(%eax),%edx
  8007ca:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007cd:	8b 00                	mov    (%eax),%eax
  8007cf:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007d4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007d9:	eb 0d                	jmp    8007e8 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007db:	8d 45 14             	lea    0x14(%ebp),%eax
  8007de:	e8 f0 fb ff ff       	call   8003d3 <getuint>
			base = 16;
  8007e3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007e8:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  8007ec:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8007f0:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8007f3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8007f7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007fb:	89 04 24             	mov    %eax,(%esp)
  8007fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  800802:	89 da                	mov    %ebx,%edx
  800804:	89 f0                	mov    %esi,%eax
  800806:	e8 d5 fa ff ff       	call   8002e0 <printnum>
			break;
  80080b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80080e:	e9 64 fc ff ff       	jmp    800477 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800813:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800817:	89 0c 24             	mov    %ecx,(%esp)
  80081a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80081f:	e9 53 fc ff ff       	jmp    800477 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800824:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800828:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80082f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800831:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800835:	0f 84 3c fc ff ff    	je     800477 <vprintfmt+0x25>
  80083b:	83 ef 01             	sub    $0x1,%edi
  80083e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800842:	75 f7                	jne    80083b <vprintfmt+0x3e9>
  800844:	e9 2e fc ff ff       	jmp    800477 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800849:	83 c4 4c             	add    $0x4c,%esp
  80084c:	5b                   	pop    %ebx
  80084d:	5e                   	pop    %esi
  80084e:	5f                   	pop    %edi
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	83 ec 28             	sub    $0x28,%esp
  800857:	8b 45 08             	mov    0x8(%ebp),%eax
  80085a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80085d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800860:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800864:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800867:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80086e:	85 d2                	test   %edx,%edx
  800870:	7e 30                	jle    8008a2 <vsnprintf+0x51>
  800872:	85 c0                	test   %eax,%eax
  800874:	74 2c                	je     8008a2 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800876:	8b 45 14             	mov    0x14(%ebp),%eax
  800879:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80087d:	8b 45 10             	mov    0x10(%ebp),%eax
  800880:	89 44 24 08          	mov    %eax,0x8(%esp)
  800884:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800887:	89 44 24 04          	mov    %eax,0x4(%esp)
  80088b:	c7 04 24 0d 04 80 00 	movl   $0x80040d,(%esp)
  800892:	e8 bb fb ff ff       	call   800452 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800897:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80089a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80089d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a0:	eb 05                	jmp    8008a7 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008a7:	c9                   	leave  
  8008a8:	c3                   	ret    

008008a9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008af:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8008b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	89 04 24             	mov    %eax,(%esp)
  8008ca:	e8 82 ff ff ff       	call   800851 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008cf:	c9                   	leave  
  8008d0:	c3                   	ret    
  8008d1:	66 90                	xchg   %ax,%ax
  8008d3:	66 90                	xchg   %ax,%ax
  8008d5:	66 90                	xchg   %ax,%ax
  8008d7:	66 90                	xchg   %ax,%ax
  8008d9:	66 90                	xchg   %ax,%ax
  8008db:	66 90                	xchg   %ax,%ax
  8008dd:	66 90                	xchg   %ax,%ax
  8008df:	90                   	nop

008008e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e6:	80 3a 00             	cmpb   $0x0,(%edx)
  8008e9:	74 10                	je     8008fb <strlen+0x1b>
  8008eb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008f0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008f7:	75 f7                	jne    8008f0 <strlen+0x10>
  8008f9:	eb 05                	jmp    800900 <strlen+0x20>
  8008fb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	53                   	push   %ebx
  800906:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800909:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80090c:	85 c9                	test   %ecx,%ecx
  80090e:	74 1c                	je     80092c <strnlen+0x2a>
  800910:	80 3b 00             	cmpb   $0x0,(%ebx)
  800913:	74 1e                	je     800933 <strnlen+0x31>
  800915:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80091a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80091c:	39 ca                	cmp    %ecx,%edx
  80091e:	74 18                	je     800938 <strnlen+0x36>
  800920:	83 c2 01             	add    $0x1,%edx
  800923:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800928:	75 f0                	jne    80091a <strnlen+0x18>
  80092a:	eb 0c                	jmp    800938 <strnlen+0x36>
  80092c:	b8 00 00 00 00       	mov    $0x0,%eax
  800931:	eb 05                	jmp    800938 <strnlen+0x36>
  800933:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800938:	5b                   	pop    %ebx
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	53                   	push   %ebx
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800945:	89 c2                	mov    %eax,%edx
  800947:	0f b6 19             	movzbl (%ecx),%ebx
  80094a:	88 1a                	mov    %bl,(%edx)
  80094c:	83 c2 01             	add    $0x1,%edx
  80094f:	83 c1 01             	add    $0x1,%ecx
  800952:	84 db                	test   %bl,%bl
  800954:	75 f1                	jne    800947 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800956:	5b                   	pop    %ebx
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	53                   	push   %ebx
  80095d:	83 ec 08             	sub    $0x8,%esp
  800960:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800963:	89 1c 24             	mov    %ebx,(%esp)
  800966:	e8 75 ff ff ff       	call   8008e0 <strlen>
	strcpy(dst + len, src);
  80096b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800972:	01 d8                	add    %ebx,%eax
  800974:	89 04 24             	mov    %eax,(%esp)
  800977:	e8 bf ff ff ff       	call   80093b <strcpy>
	return dst;
}
  80097c:	89 d8                	mov    %ebx,%eax
  80097e:	83 c4 08             	add    $0x8,%esp
  800981:	5b                   	pop    %ebx
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	56                   	push   %esi
  800988:	53                   	push   %ebx
  800989:	8b 75 08             	mov    0x8(%ebp),%esi
  80098c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800992:	85 db                	test   %ebx,%ebx
  800994:	74 16                	je     8009ac <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800996:	01 f3                	add    %esi,%ebx
  800998:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80099a:	0f b6 02             	movzbl (%edx),%eax
  80099d:	88 01                	mov    %al,(%ecx)
  80099f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a2:	80 3a 01             	cmpb   $0x1,(%edx)
  8009a5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a8:	39 d9                	cmp    %ebx,%ecx
  8009aa:	75 ee                	jne    80099a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009ac:	89 f0                	mov    %esi,%eax
  8009ae:	5b                   	pop    %ebx
  8009af:	5e                   	pop    %esi
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	57                   	push   %edi
  8009b6:	56                   	push   %esi
  8009b7:	53                   	push   %ebx
  8009b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009be:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c1:	89 f8                	mov    %edi,%eax
  8009c3:	85 f6                	test   %esi,%esi
  8009c5:	74 33                	je     8009fa <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  8009c7:	83 fe 01             	cmp    $0x1,%esi
  8009ca:	74 25                	je     8009f1 <strlcpy+0x3f>
  8009cc:	0f b6 0b             	movzbl (%ebx),%ecx
  8009cf:	84 c9                	test   %cl,%cl
  8009d1:	74 22                	je     8009f5 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8009d3:	83 ee 02             	sub    $0x2,%esi
  8009d6:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009db:	88 08                	mov    %cl,(%eax)
  8009dd:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009e0:	39 f2                	cmp    %esi,%edx
  8009e2:	74 13                	je     8009f7 <strlcpy+0x45>
  8009e4:	83 c2 01             	add    $0x1,%edx
  8009e7:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009eb:	84 c9                	test   %cl,%cl
  8009ed:	75 ec                	jne    8009db <strlcpy+0x29>
  8009ef:	eb 06                	jmp    8009f7 <strlcpy+0x45>
  8009f1:	89 f8                	mov    %edi,%eax
  8009f3:	eb 02                	jmp    8009f7 <strlcpy+0x45>
  8009f5:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009f7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009fa:	29 f8                	sub    %edi,%eax
}
  8009fc:	5b                   	pop    %ebx
  8009fd:	5e                   	pop    %esi
  8009fe:	5f                   	pop    %edi
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a07:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a0a:	0f b6 01             	movzbl (%ecx),%eax
  800a0d:	84 c0                	test   %al,%al
  800a0f:	74 15                	je     800a26 <strcmp+0x25>
  800a11:	3a 02                	cmp    (%edx),%al
  800a13:	75 11                	jne    800a26 <strcmp+0x25>
		p++, q++;
  800a15:	83 c1 01             	add    $0x1,%ecx
  800a18:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a1b:	0f b6 01             	movzbl (%ecx),%eax
  800a1e:	84 c0                	test   %al,%al
  800a20:	74 04                	je     800a26 <strcmp+0x25>
  800a22:	3a 02                	cmp    (%edx),%al
  800a24:	74 ef                	je     800a15 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a26:	0f b6 c0             	movzbl %al,%eax
  800a29:	0f b6 12             	movzbl (%edx),%edx
  800a2c:	29 d0                	sub    %edx,%eax
}
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	56                   	push   %esi
  800a34:	53                   	push   %ebx
  800a35:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a38:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800a3e:	85 f6                	test   %esi,%esi
  800a40:	74 29                	je     800a6b <strncmp+0x3b>
  800a42:	0f b6 03             	movzbl (%ebx),%eax
  800a45:	84 c0                	test   %al,%al
  800a47:	74 30                	je     800a79 <strncmp+0x49>
  800a49:	3a 02                	cmp    (%edx),%al
  800a4b:	75 2c                	jne    800a79 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  800a4d:	8d 43 01             	lea    0x1(%ebx),%eax
  800a50:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800a52:	89 c3                	mov    %eax,%ebx
  800a54:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a57:	39 f0                	cmp    %esi,%eax
  800a59:	74 17                	je     800a72 <strncmp+0x42>
  800a5b:	0f b6 08             	movzbl (%eax),%ecx
  800a5e:	84 c9                	test   %cl,%cl
  800a60:	74 17                	je     800a79 <strncmp+0x49>
  800a62:	83 c0 01             	add    $0x1,%eax
  800a65:	3a 0a                	cmp    (%edx),%cl
  800a67:	74 e9                	je     800a52 <strncmp+0x22>
  800a69:	eb 0e                	jmp    800a79 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a70:	eb 0f                	jmp    800a81 <strncmp+0x51>
  800a72:	b8 00 00 00 00       	mov    $0x0,%eax
  800a77:	eb 08                	jmp    800a81 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a79:	0f b6 03             	movzbl (%ebx),%eax
  800a7c:	0f b6 12             	movzbl (%edx),%edx
  800a7f:	29 d0                	sub    %edx,%eax
}
  800a81:	5b                   	pop    %ebx
  800a82:	5e                   	pop    %esi
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	53                   	push   %ebx
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a8f:	0f b6 18             	movzbl (%eax),%ebx
  800a92:	84 db                	test   %bl,%bl
  800a94:	74 1d                	je     800ab3 <strchr+0x2e>
  800a96:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a98:	38 d3                	cmp    %dl,%bl
  800a9a:	75 06                	jne    800aa2 <strchr+0x1d>
  800a9c:	eb 1a                	jmp    800ab8 <strchr+0x33>
  800a9e:	38 ca                	cmp    %cl,%dl
  800aa0:	74 16                	je     800ab8 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aa2:	83 c0 01             	add    $0x1,%eax
  800aa5:	0f b6 10             	movzbl (%eax),%edx
  800aa8:	84 d2                	test   %dl,%dl
  800aaa:	75 f2                	jne    800a9e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800aac:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab1:	eb 05                	jmp    800ab8 <strchr+0x33>
  800ab3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	53                   	push   %ebx
  800abf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac2:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800ac5:	0f b6 18             	movzbl (%eax),%ebx
  800ac8:	84 db                	test   %bl,%bl
  800aca:	74 16                	je     800ae2 <strfind+0x27>
  800acc:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800ace:	38 d3                	cmp    %dl,%bl
  800ad0:	75 06                	jne    800ad8 <strfind+0x1d>
  800ad2:	eb 0e                	jmp    800ae2 <strfind+0x27>
  800ad4:	38 ca                	cmp    %cl,%dl
  800ad6:	74 0a                	je     800ae2 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ad8:	83 c0 01             	add    $0x1,%eax
  800adb:	0f b6 10             	movzbl (%eax),%edx
  800ade:	84 d2                	test   %dl,%dl
  800ae0:	75 f2                	jne    800ad4 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800ae2:	5b                   	pop    %ebx
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	83 ec 0c             	sub    $0xc,%esp
  800aeb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800aee:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800af1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800af4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800af7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800afa:	85 c9                	test   %ecx,%ecx
  800afc:	74 36                	je     800b34 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800afe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b04:	75 28                	jne    800b2e <memset+0x49>
  800b06:	f6 c1 03             	test   $0x3,%cl
  800b09:	75 23                	jne    800b2e <memset+0x49>
		c &= 0xFF;
  800b0b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b0f:	89 d3                	mov    %edx,%ebx
  800b11:	c1 e3 08             	shl    $0x8,%ebx
  800b14:	89 d6                	mov    %edx,%esi
  800b16:	c1 e6 18             	shl    $0x18,%esi
  800b19:	89 d0                	mov    %edx,%eax
  800b1b:	c1 e0 10             	shl    $0x10,%eax
  800b1e:	09 f0                	or     %esi,%eax
  800b20:	09 c2                	or     %eax,%edx
  800b22:	89 d0                	mov    %edx,%eax
  800b24:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b26:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b29:	fc                   	cld    
  800b2a:	f3 ab                	rep stos %eax,%es:(%edi)
  800b2c:	eb 06                	jmp    800b34 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b31:	fc                   	cld    
  800b32:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b34:	89 f8                	mov    %edi,%eax
  800b36:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b39:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b3c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b3f:	89 ec                	mov    %ebp,%esp
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	83 ec 08             	sub    $0x8,%esp
  800b49:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b4c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b52:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b55:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b58:	39 c6                	cmp    %eax,%esi
  800b5a:	73 36                	jae    800b92 <memmove+0x4f>
  800b5c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b5f:	39 d0                	cmp    %edx,%eax
  800b61:	73 2f                	jae    800b92 <memmove+0x4f>
		s += n;
		d += n;
  800b63:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b66:	f6 c2 03             	test   $0x3,%dl
  800b69:	75 1b                	jne    800b86 <memmove+0x43>
  800b6b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b71:	75 13                	jne    800b86 <memmove+0x43>
  800b73:	f6 c1 03             	test   $0x3,%cl
  800b76:	75 0e                	jne    800b86 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b78:	83 ef 04             	sub    $0x4,%edi
  800b7b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b7e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b81:	fd                   	std    
  800b82:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b84:	eb 09                	jmp    800b8f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b86:	83 ef 01             	sub    $0x1,%edi
  800b89:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b8c:	fd                   	std    
  800b8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b8f:	fc                   	cld    
  800b90:	eb 20                	jmp    800bb2 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b92:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b98:	75 13                	jne    800bad <memmove+0x6a>
  800b9a:	a8 03                	test   $0x3,%al
  800b9c:	75 0f                	jne    800bad <memmove+0x6a>
  800b9e:	f6 c1 03             	test   $0x3,%cl
  800ba1:	75 0a                	jne    800bad <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ba3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ba6:	89 c7                	mov    %eax,%edi
  800ba8:	fc                   	cld    
  800ba9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bab:	eb 05                	jmp    800bb2 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bad:	89 c7                	mov    %eax,%edi
  800baf:	fc                   	cld    
  800bb0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bb2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bb5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bb8:	89 ec                	mov    %ebp,%esp
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bc2:	8b 45 10             	mov    0x10(%ebp),%eax
  800bc5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bcc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd3:	89 04 24             	mov    %eax,(%esp)
  800bd6:	e8 68 ff ff ff       	call   800b43 <memmove>
}
  800bdb:	c9                   	leave  
  800bdc:	c3                   	ret    

00800bdd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
  800be3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800be6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be9:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bec:	8d 78 ff             	lea    -0x1(%eax),%edi
  800bef:	85 c0                	test   %eax,%eax
  800bf1:	74 36                	je     800c29 <memcmp+0x4c>
		if (*s1 != *s2)
  800bf3:	0f b6 03             	movzbl (%ebx),%eax
  800bf6:	0f b6 0e             	movzbl (%esi),%ecx
  800bf9:	38 c8                	cmp    %cl,%al
  800bfb:	75 17                	jne    800c14 <memcmp+0x37>
  800bfd:	ba 00 00 00 00       	mov    $0x0,%edx
  800c02:	eb 1a                	jmp    800c1e <memcmp+0x41>
  800c04:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800c09:	83 c2 01             	add    $0x1,%edx
  800c0c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800c10:	38 c8                	cmp    %cl,%al
  800c12:	74 0a                	je     800c1e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800c14:	0f b6 c0             	movzbl %al,%eax
  800c17:	0f b6 c9             	movzbl %cl,%ecx
  800c1a:	29 c8                	sub    %ecx,%eax
  800c1c:	eb 10                	jmp    800c2e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c1e:	39 fa                	cmp    %edi,%edx
  800c20:	75 e2                	jne    800c04 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c22:	b8 00 00 00 00       	mov    $0x0,%eax
  800c27:	eb 05                	jmp    800c2e <memcmp+0x51>
  800c29:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	53                   	push   %ebx
  800c37:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800c3d:	89 c2                	mov    %eax,%edx
  800c3f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c42:	39 d0                	cmp    %edx,%eax
  800c44:	73 13                	jae    800c59 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c46:	89 d9                	mov    %ebx,%ecx
  800c48:	38 18                	cmp    %bl,(%eax)
  800c4a:	75 06                	jne    800c52 <memfind+0x1f>
  800c4c:	eb 0b                	jmp    800c59 <memfind+0x26>
  800c4e:	38 08                	cmp    %cl,(%eax)
  800c50:	74 07                	je     800c59 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c52:	83 c0 01             	add    $0x1,%eax
  800c55:	39 d0                	cmp    %edx,%eax
  800c57:	75 f5                	jne    800c4e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c59:	5b                   	pop    %ebx
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	57                   	push   %edi
  800c60:	56                   	push   %esi
  800c61:	53                   	push   %ebx
  800c62:	83 ec 04             	sub    $0x4,%esp
  800c65:	8b 55 08             	mov    0x8(%ebp),%edx
  800c68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c6b:	0f b6 02             	movzbl (%edx),%eax
  800c6e:	3c 09                	cmp    $0x9,%al
  800c70:	74 04                	je     800c76 <strtol+0x1a>
  800c72:	3c 20                	cmp    $0x20,%al
  800c74:	75 0e                	jne    800c84 <strtol+0x28>
		s++;
  800c76:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c79:	0f b6 02             	movzbl (%edx),%eax
  800c7c:	3c 09                	cmp    $0x9,%al
  800c7e:	74 f6                	je     800c76 <strtol+0x1a>
  800c80:	3c 20                	cmp    $0x20,%al
  800c82:	74 f2                	je     800c76 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c84:	3c 2b                	cmp    $0x2b,%al
  800c86:	75 0a                	jne    800c92 <strtol+0x36>
		s++;
  800c88:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c8b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c90:	eb 10                	jmp    800ca2 <strtol+0x46>
  800c92:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c97:	3c 2d                	cmp    $0x2d,%al
  800c99:	75 07                	jne    800ca2 <strtol+0x46>
		s++, neg = 1;
  800c9b:	83 c2 01             	add    $0x1,%edx
  800c9e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ca2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ca8:	75 15                	jne    800cbf <strtol+0x63>
  800caa:	80 3a 30             	cmpb   $0x30,(%edx)
  800cad:	75 10                	jne    800cbf <strtol+0x63>
  800caf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cb3:	75 0a                	jne    800cbf <strtol+0x63>
		s += 2, base = 16;
  800cb5:	83 c2 02             	add    $0x2,%edx
  800cb8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cbd:	eb 10                	jmp    800ccf <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800cbf:	85 db                	test   %ebx,%ebx
  800cc1:	75 0c                	jne    800ccf <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cc3:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cc5:	80 3a 30             	cmpb   $0x30,(%edx)
  800cc8:	75 05                	jne    800ccf <strtol+0x73>
		s++, base = 8;
  800cca:	83 c2 01             	add    $0x1,%edx
  800ccd:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800ccf:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd4:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cd7:	0f b6 0a             	movzbl (%edx),%ecx
  800cda:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800cdd:	89 f3                	mov    %esi,%ebx
  800cdf:	80 fb 09             	cmp    $0x9,%bl
  800ce2:	77 08                	ja     800cec <strtol+0x90>
			dig = *s - '0';
  800ce4:	0f be c9             	movsbl %cl,%ecx
  800ce7:	83 e9 30             	sub    $0x30,%ecx
  800cea:	eb 22                	jmp    800d0e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800cec:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800cef:	89 f3                	mov    %esi,%ebx
  800cf1:	80 fb 19             	cmp    $0x19,%bl
  800cf4:	77 08                	ja     800cfe <strtol+0xa2>
			dig = *s - 'a' + 10;
  800cf6:	0f be c9             	movsbl %cl,%ecx
  800cf9:	83 e9 57             	sub    $0x57,%ecx
  800cfc:	eb 10                	jmp    800d0e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800cfe:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800d01:	89 f3                	mov    %esi,%ebx
  800d03:	80 fb 19             	cmp    $0x19,%bl
  800d06:	77 16                	ja     800d1e <strtol+0xc2>
			dig = *s - 'A' + 10;
  800d08:	0f be c9             	movsbl %cl,%ecx
  800d0b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d0e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800d11:	7d 0f                	jge    800d22 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800d13:	83 c2 01             	add    $0x1,%edx
  800d16:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800d1a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d1c:	eb b9                	jmp    800cd7 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d1e:	89 c1                	mov    %eax,%ecx
  800d20:	eb 02                	jmp    800d24 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d22:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d24:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d28:	74 05                	je     800d2f <strtol+0xd3>
		*endptr = (char *) s;
  800d2a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d2d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d2f:	89 ca                	mov    %ecx,%edx
  800d31:	f7 da                	neg    %edx
  800d33:	85 ff                	test   %edi,%edi
  800d35:	0f 45 c2             	cmovne %edx,%eax
}
  800d38:	83 c4 04             	add    $0x4,%esp
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	83 ec 0c             	sub    $0xc,%esp
  800d46:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d49:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d4c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d57:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5a:	89 c3                	mov    %eax,%ebx
  800d5c:	89 c7                	mov    %eax,%edi
  800d5e:	89 c6                	mov    %eax,%esi
  800d60:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d62:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d65:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d68:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d6b:	89 ec                	mov    %ebp,%esp
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    

00800d6f <sys_cgetc>:

int
sys_cgetc(void)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	83 ec 0c             	sub    $0xc,%esp
  800d75:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d78:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d7b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d83:	b8 01 00 00 00       	mov    $0x1,%eax
  800d88:	89 d1                	mov    %edx,%ecx
  800d8a:	89 d3                	mov    %edx,%ebx
  800d8c:	89 d7                	mov    %edx,%edi
  800d8e:	89 d6                	mov    %edx,%esi
  800d90:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d92:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d95:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d98:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d9b:	89 ec                	mov    %ebp,%esp
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	83 ec 38             	sub    $0x38,%esp
  800da5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800da8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dab:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dae:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db3:	b8 03 00 00 00       	mov    $0x3,%eax
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	89 cb                	mov    %ecx,%ebx
  800dbd:	89 cf                	mov    %ecx,%edi
  800dbf:	89 ce                	mov    %ecx,%esi
  800dc1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	7e 28                	jle    800def <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dcb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800dd2:	00 
  800dd3:	c7 44 24 08 84 1b 80 	movl   $0x801b84,0x8(%esp)
  800dda:	00 
  800ddb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de2:	00 
  800de3:	c7 04 24 a1 1b 80 00 	movl   $0x801ba1,(%esp)
  800dea:	e8 d1 f3 ff ff       	call   8001c0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800def:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800df2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800df5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800df8:	89 ec                	mov    %ebp,%esp
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	83 ec 0c             	sub    $0xc,%esp
  800e02:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e05:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e08:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e10:	b8 02 00 00 00       	mov    $0x2,%eax
  800e15:	89 d1                	mov    %edx,%ecx
  800e17:	89 d3                	mov    %edx,%ebx
  800e19:	89 d7                	mov    %edx,%edi
  800e1b:	89 d6                	mov    %edx,%esi
  800e1d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e1f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e22:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e25:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e28:	89 ec                	mov    %ebp,%esp
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <sys_yield>:

void
sys_yield(void)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	83 ec 0c             	sub    $0xc,%esp
  800e32:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e35:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e38:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e40:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e45:	89 d1                	mov    %edx,%ecx
  800e47:	89 d3                	mov    %edx,%ebx
  800e49:	89 d7                	mov    %edx,%edi
  800e4b:	89 d6                	mov    %edx,%esi
  800e4d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e4f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e52:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e55:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e58:	89 ec                	mov    %ebp,%esp
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	83 ec 38             	sub    $0x38,%esp
  800e62:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e65:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e68:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6b:	be 00 00 00 00       	mov    $0x0,%esi
  800e70:	b8 04 00 00 00       	mov    $0x4,%eax
  800e75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e78:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e7e:	89 f7                	mov    %esi,%edi
  800e80:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e82:	85 c0                	test   %eax,%eax
  800e84:	7e 28                	jle    800eae <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e86:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e8a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e91:	00 
  800e92:	c7 44 24 08 84 1b 80 	movl   $0x801b84,0x8(%esp)
  800e99:	00 
  800e9a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea1:	00 
  800ea2:	c7 04 24 a1 1b 80 00 	movl   $0x801ba1,(%esp)
  800ea9:	e8 12 f3 ff ff       	call   8001c0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800eae:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eb1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eb4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eb7:	89 ec                	mov    %ebp,%esp
  800eb9:	5d                   	pop    %ebp
  800eba:	c3                   	ret    

00800ebb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
  800ebe:	83 ec 38             	sub    $0x38,%esp
  800ec1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ec4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ec7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eca:	b8 05 00 00 00       	mov    $0x5,%eax
  800ecf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ed8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800edb:	8b 75 18             	mov    0x18(%ebp),%esi
  800ede:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee0:	85 c0                	test   %eax,%eax
  800ee2:	7e 28                	jle    800f0c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800eef:	00 
  800ef0:	c7 44 24 08 84 1b 80 	movl   $0x801b84,0x8(%esp)
  800ef7:	00 
  800ef8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eff:	00 
  800f00:	c7 04 24 a1 1b 80 00 	movl   $0x801ba1,(%esp)
  800f07:	e8 b4 f2 ff ff       	call   8001c0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f0c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f0f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f12:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f15:	89 ec                	mov    %ebp,%esp
  800f17:	5d                   	pop    %ebp
  800f18:	c3                   	ret    

00800f19 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f19:	55                   	push   %ebp
  800f1a:	89 e5                	mov    %esp,%ebp
  800f1c:	83 ec 38             	sub    $0x38,%esp
  800f1f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f22:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f25:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f28:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f2d:	b8 06 00 00 00       	mov    $0x6,%eax
  800f32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f35:	8b 55 08             	mov    0x8(%ebp),%edx
  800f38:	89 df                	mov    %ebx,%edi
  800f3a:	89 de                	mov    %ebx,%esi
  800f3c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	7e 28                	jle    800f6a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f42:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f46:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f4d:	00 
  800f4e:	c7 44 24 08 84 1b 80 	movl   $0x801b84,0x8(%esp)
  800f55:	00 
  800f56:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f5d:	00 
  800f5e:	c7 04 24 a1 1b 80 00 	movl   $0x801ba1,(%esp)
  800f65:	e8 56 f2 ff ff       	call   8001c0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f6a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f6d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f70:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f73:	89 ec                	mov    %ebp,%esp
  800f75:	5d                   	pop    %ebp
  800f76:	c3                   	ret    

00800f77 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	83 ec 38             	sub    $0x38,%esp
  800f7d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f80:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f83:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f86:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f8b:	b8 08 00 00 00       	mov    $0x8,%eax
  800f90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f93:	8b 55 08             	mov    0x8(%ebp),%edx
  800f96:	89 df                	mov    %ebx,%edi
  800f98:	89 de                	mov    %ebx,%esi
  800f9a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	7e 28                	jle    800fc8 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fa0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fa4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800fab:	00 
  800fac:	c7 44 24 08 84 1b 80 	movl   $0x801b84,0x8(%esp)
  800fb3:	00 
  800fb4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fbb:	00 
  800fbc:	c7 04 24 a1 1b 80 00 	movl   $0x801ba1,(%esp)
  800fc3:	e8 f8 f1 ff ff       	call   8001c0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fc8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fcb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fce:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fd1:	89 ec                	mov    %ebp,%esp
  800fd3:	5d                   	pop    %ebp
  800fd4:	c3                   	ret    

00800fd5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	83 ec 38             	sub    $0x38,%esp
  800fdb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fde:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fe1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fe9:	b8 09 00 00 00       	mov    $0x9,%eax
  800fee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff4:	89 df                	mov    %ebx,%edi
  800ff6:	89 de                	mov    %ebx,%esi
  800ff8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ffa:	85 c0                	test   %eax,%eax
  800ffc:	7e 28                	jle    801026 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ffe:	89 44 24 10          	mov    %eax,0x10(%esp)
  801002:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801009:	00 
  80100a:	c7 44 24 08 84 1b 80 	movl   $0x801b84,0x8(%esp)
  801011:	00 
  801012:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801019:	00 
  80101a:	c7 04 24 a1 1b 80 00 	movl   $0x801ba1,(%esp)
  801021:	e8 9a f1 ff ff       	call   8001c0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801026:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801029:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80102c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80102f:	89 ec                	mov    %ebp,%esp
  801031:	5d                   	pop    %ebp
  801032:	c3                   	ret    

00801033 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	83 ec 0c             	sub    $0xc,%esp
  801039:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80103c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80103f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801042:	be 00 00 00 00       	mov    $0x0,%esi
  801047:	b8 0b 00 00 00       	mov    $0xb,%eax
  80104c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104f:	8b 55 08             	mov    0x8(%ebp),%edx
  801052:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801055:	8b 7d 14             	mov    0x14(%ebp),%edi
  801058:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80105a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80105d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801060:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801063:	89 ec                	mov    %ebp,%esp
  801065:	5d                   	pop    %ebp
  801066:	c3                   	ret    

00801067 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801067:	55                   	push   %ebp
  801068:	89 e5                	mov    %esp,%ebp
  80106a:	83 ec 38             	sub    $0x38,%esp
  80106d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801070:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801073:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801076:	b9 00 00 00 00       	mov    $0x0,%ecx
  80107b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801080:	8b 55 08             	mov    0x8(%ebp),%edx
  801083:	89 cb                	mov    %ecx,%ebx
  801085:	89 cf                	mov    %ecx,%edi
  801087:	89 ce                	mov    %ecx,%esi
  801089:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80108b:	85 c0                	test   %eax,%eax
  80108d:	7e 28                	jle    8010b7 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80108f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801093:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80109a:	00 
  80109b:	c7 44 24 08 84 1b 80 	movl   $0x801b84,0x8(%esp)
  8010a2:	00 
  8010a3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010aa:	00 
  8010ab:	c7 04 24 a1 1b 80 00 	movl   $0x801ba1,(%esp)
  8010b2:	e8 09 f1 ff ff       	call   8001c0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010b7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010ba:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010bd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010c0:	89 ec                	mov    %ebp,%esp
  8010c2:	5d                   	pop    %ebp
  8010c3:	c3                   	ret    

008010c4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	53                   	push   %ebx
  8010c8:	83 ec 24             	sub    $0x24,%esp
  8010cb:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
  8010ce:	8b 50 04             	mov    0x4(%eax),%edx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	addr = (void*)(ROUNDDOWN((uint32_t)addr, PGSIZE)); 
  8010d1:	8b 18                	mov    (%eax),%ebx
  8010d3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	int pte = uvpt[PGNUM((uint32_t)addr)];
  8010d9:	89 d8                	mov    %ebx,%eax
  8010db:	c1 e8 0c             	shr    $0xc,%eax
  8010de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!((pte & PTE_COW) && (err & FEC_WR))) {
  8010e5:	f6 c4 08             	test   $0x8,%ah
  8010e8:	74 05                	je     8010ef <pgfault+0x2b>
  8010ea:	f6 c2 02             	test   $0x2,%dl
  8010ed:	75 30                	jne    80111f <pgfault+0x5b>
		cprintf("pte: %x, error: %x\n", pte, err);
  8010ef:	89 54 24 08          	mov    %edx,0x8(%esp)
  8010f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f7:	c7 04 24 af 1b 80 00 	movl   $0x801baf,(%esp)
  8010fe:	e8 b8 f1 ff ff       	call   8002bb <cprintf>
		panic("Something wrong in lib/fork.c:pgfault\n");
  801103:	c7 44 24 08 00 1c 80 	movl   $0x801c00,0x8(%esp)
  80110a:	00 
  80110b:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  801112:	00 
  801113:	c7 04 24 c3 1b 80 00 	movl   $0x801bc3,(%esp)
  80111a:	e8 a1 f0 ff ff       	call   8001c0 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	
	int ret;
	ret = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
  80111f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801126:	00 
  801127:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80112e:	00 
  80112f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801136:	e8 21 fd ff ff       	call   800e5c <sys_page_alloc>
	if (ret < 0) {
  80113b:	85 c0                	test   %eax,%eax
  80113d:	79 20                	jns    80115f <pgfault+0x9b>
		panic("fork.c/pgfault page allocation %e\n", ret);
  80113f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801143:	c7 44 24 08 28 1c 80 	movl   $0x801c28,0x8(%esp)
  80114a:	00 
  80114b:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  801152:	00 
  801153:	c7 04 24 c3 1b 80 00 	movl   $0x801bc3,(%esp)
  80115a:	e8 61 f0 ff ff       	call   8001c0 <_panic>
	}
	
	memmove(PFTEMP, addr, PGSIZE);
  80115f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801166:	00 
  801167:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80116b:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801172:	e8 cc f9 ff ff       	call   800b43 <memmove>

	ret = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_U | PTE_P | PTE_W);
  801177:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80117e:	00 
  80117f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801183:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80118a:	00 
  80118b:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801192:	00 
  801193:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80119a:	e8 1c fd ff ff       	call   800ebb <sys_page_map>
	if (ret < 0) {
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	79 20                	jns    8011c3 <pgfault+0xff>
		panic("fork.c/pgfault page map %e\n", ret);
  8011a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011a7:	c7 44 24 08 ce 1b 80 	movl   $0x801bce,0x8(%esp)
  8011ae:	00 
  8011af:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  8011b6:	00 
  8011b7:	c7 04 24 c3 1b 80 00 	movl   $0x801bc3,(%esp)
  8011be:	e8 fd ef ff ff       	call   8001c0 <_panic>
	}

	// panic("pgfault not implemented");
}
  8011c3:	83 c4 24             	add    $0x24,%esp
  8011c6:	5b                   	pop    %ebx
  8011c7:	5d                   	pop    %ebp
  8011c8:	c3                   	ret    

008011c9 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8011c9:	55                   	push   %ebp
  8011ca:	89 e5                	mov    %esp,%ebp
  8011cc:	57                   	push   %edi
  8011cd:	56                   	push   %esi
  8011ce:	53                   	push   %ebx
  8011cf:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int ret = 0;
	extern unsigned char end[];
	void (*handler)(struct UTrapframe *utf) = pgfault;
	set_pgfault_handler(handler);
  8011d2:	c7 04 24 c4 10 80 00 	movl   $0x8010c4,(%esp)
  8011d9:	e8 5a 03 00 00       	call   801538 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8011de:	be 07 00 00 00       	mov    $0x7,%esi
  8011e3:	89 f0                	mov    %esi,%eax
  8011e5:	cd 30                	int    $0x30
  8011e7:	89 c6                	mov    %eax,%esi
  8011e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	
	envid_t new_env = sys_exofork();
	if (new_env < 0) {
  8011ec:	85 c0                	test   %eax,%eax
  8011ee:	0f 88 e7 01 00 00    	js     8013db <fork+0x212>
		return new_env;
	}

	if (new_env == 0) {
  8011f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011f9:	85 c0                	test   %eax,%eax
  8011fb:	75 1c                	jne    801219 <fork+0x50>
		thisenv = &envs[ENVX(sys_getenvid())];
  8011fd:	e8 fa fb ff ff       	call   800dfc <sys_getenvid>
  801202:	25 ff 03 00 00       	and    $0x3ff,%eax
  801207:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80120a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80120f:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  801214:	e9 c2 01 00 00       	jmp    8013db <fork+0x212>
	}
	uint32_t va;

	for (va =  0; va < UTOP - PGSIZE; va += PGSIZE) {
		if((uvpd[PDX(va)] & PTE_P) && (uvpd[PDX(va)] & PTE_U)) {
  801219:	89 d8                	mov    %ebx,%eax
  80121b:	c1 e8 16             	shr    $0x16,%eax
  80121e:	8b 14 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%edx
  801225:	f6 c2 01             	test   $0x1,%dl
  801228:	0f 84 bf 00 00 00    	je     8012ed <fork+0x124>
  80122e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801235:	a8 04                	test   $0x4,%al
  801237:	0f 84 b0 00 00 00    	je     8012ed <fork+0x124>
			if ((uvpt[PGNUM(va)] & PTE_P) &&
  80123d:	89 d8                	mov    %ebx,%eax
  80123f:	c1 e8 0c             	shr    $0xc,%eax
  801242:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801249:	f6 c2 01             	test   $0x1,%dl
  80124c:	0f 84 9b 00 00 00    	je     8012ed <fork+0x124>
					(uvpt[PGNUM(va)] & PTE_U)) {
  801252:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	}
	uint32_t va;

	for (va =  0; va < UTOP - PGSIZE; va += PGSIZE) {
		if((uvpd[PDX(va)] & PTE_P) && (uvpd[PDX(va)] & PTE_U)) {
			if ((uvpt[PGNUM(va)] & PTE_P) &&
  801259:	a8 04                	test   $0x4,%al
  80125b:	0f 84 8c 00 00 00    	je     8012ed <fork+0x124>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	int flag = 0;
	uint32_t addr = pn * PGSIZE;
  801261:	89 df                	mov    %ebx,%edi
  801263:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	// LAB 4: Your code here.
	r = PTE_U | PTE_P;
	int old_perm = uvpt[PGNUM(addr)];
  801269:	89 f8                	mov    %edi,%eax
  80126b:	c1 e8 0c             	shr    $0xc,%eax
  80126e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if ((old_perm & PTE_W) || (r & PTE_COW)) {
  801275:	a8 02                	test   $0x2,%al
  801277:	0f 85 fe 00 00 00    	jne    80137b <fork+0x1b2>
  80127d:	e9 29 01 00 00       	jmp    8013ab <fork+0x1e2>
	}


	int ret = sys_page_map(0, (void*)addr, envid, (void*)addr, r);
	if (ret < 0) {
		panic("fork.c/duppage in page_map %d %e\n", envid, ret);
  801282:	89 44 24 10          	mov    %eax,0x10(%esp)
  801286:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80128a:	c7 44 24 08 4c 1c 80 	movl   $0x801c4c,0x8(%esp)
  801291:	00 
  801292:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  801299:	00 
  80129a:	c7 04 24 c3 1b 80 00 	movl   $0x801bc3,(%esp)
  8012a1:	e8 1a ef ff ff       	call   8001c0 <_panic>
		return ret;
	}

	if (flag) {
		ret = sys_page_map(envid, (void*)addr, 0, (void*)addr, r);
  8012a6:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8012ad:	00 
  8012ae:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012b2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012b9:	00 
  8012ba:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012c1:	89 04 24             	mov    %eax,(%esp)
  8012c4:	e8 f2 fb ff ff       	call   800ebb <sys_page_map>
		if (ret < 0) {
  8012c9:	85 c0                	test   %eax,%eax
  8012cb:	79 20                	jns    8012ed <fork+0x124>
			panic("fork.c/duppage in page_map 2 %e\n", ret);
  8012cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012d1:	c7 44 24 08 70 1c 80 	movl   $0x801c70,0x8(%esp)
  8012d8:	00 
  8012d9:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  8012e0:	00 
  8012e1:	c7 04 24 c3 1b 80 00 	movl   $0x801bc3,(%esp)
  8012e8:	e8 d3 ee ff ff       	call   8001c0 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	uint32_t va;

	for (va =  0; va < UTOP - PGSIZE; va += PGSIZE) {
  8012ed:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8012f3:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8012f9:	0f 85 1a ff ff ff    	jne    801219 <fork+0x50>
				duppage(new_env, (va / PGSIZE));
			}	
		}
	}
	
	ret = sys_page_alloc(new_env, (void*)(UXSTACKTOP - PGSIZE),
  8012ff:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801306:	00 
  801307:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80130e:	ee 
  80130f:	89 34 24             	mov    %esi,(%esp)
  801312:	e8 45 fb ff ff       	call   800e5c <sys_page_alloc>
			  			 PTE_U | PTE_P | PTE_W);
	if (ret < 0) {
  801317:	85 c0                	test   %eax,%eax
  801319:	79 1c                	jns    801337 <fork+0x16e>
		panic("Not able to allocate exception stack for the child\n");
  80131b:	c7 44 24 08 94 1c 80 	movl   $0x801c94,0x8(%esp)
  801322:	00 
  801323:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
  80132a:	00 
  80132b:	c7 04 24 c3 1b 80 00 	movl   $0x801bc3,(%esp)
  801332:	e8 89 ee ff ff       	call   8001c0 <_panic>
	}

	sys_env_set_pgfault_upcall(new_env, thisenv->env_pgfault_upcall);
  801337:	a1 04 20 80 00       	mov    0x802004,%eax
  80133c:	8b 40 64             	mov    0x64(%eax),%eax
  80133f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801343:	89 34 24             	mov    %esi,(%esp)
  801346:	e8 8a fc ff ff       	call   800fd5 <sys_env_set_pgfault_upcall>
	
	ret = sys_env_set_status(new_env, ENV_RUNNABLE);
  80134b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801352:	00 
  801353:	89 34 24             	mov    %esi,(%esp)
  801356:	e8 1c fc ff ff       	call   800f77 <sys_env_set_status>
	if (ret < 0) {
  80135b:	85 c0                	test   %eax,%eax
  80135d:	79 7c                	jns    8013db <fork+0x212>
		panic("Not able to make child runnable.\n");
  80135f:	c7 44 24 08 c8 1c 80 	movl   $0x801cc8,0x8(%esp)
  801366:	00 
  801367:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  80136e:	00 
  80136f:	c7 04 24 c3 1b 80 00 	movl   $0x801bc3,(%esp)
  801376:	e8 45 ee ff ff       	call   8001c0 <_panic>
		r = r | PTE_COW;
		flag = 1;
	}


	int ret = sys_page_map(0, (void*)addr, envid, (void*)addr, r);
  80137b:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801382:	00 
  801383:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801387:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80138a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80138e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801392:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801399:	e8 1d fb ff ff       	call   800ebb <sys_page_map>
	if (ret < 0) {
  80139e:	85 c0                	test   %eax,%eax
  8013a0:	0f 89 00 ff ff ff    	jns    8012a6 <fork+0xdd>
  8013a6:	e9 d7 fe ff ff       	jmp    801282 <fork+0xb9>
		r = r | PTE_COW;
		flag = 1;
	}


	int ret = sys_page_map(0, (void*)addr, envid, (void*)addr, r);
  8013ab:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8013b2:	00 
  8013b3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013be:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013c9:	e8 ed fa ff ff       	call   800ebb <sys_page_map>
	if (ret < 0) {
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	0f 89 17 ff ff ff    	jns    8012ed <fork+0x124>
  8013d6:	e9 a7 fe ff ff       	jmp    801282 <fork+0xb9>
		panic("Not able to make child runnable.\n");
	}

	return new_env;
	// panic("fork not implemented");
}
  8013db:	89 f0                	mov    %esi,%eax
  8013dd:	83 c4 3c             	add    $0x3c,%esp
  8013e0:	5b                   	pop    %ebx
  8013e1:	5e                   	pop    %esi
  8013e2:	5f                   	pop    %edi
  8013e3:	5d                   	pop    %ebp
  8013e4:	c3                   	ret    

008013e5 <sfork>:

// Challenge!
int
sfork(void)
{
  8013e5:	55                   	push   %ebp
  8013e6:	89 e5                	mov    %esp,%ebp
  8013e8:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8013eb:	c7 44 24 08 ea 1b 80 	movl   $0x801bea,0x8(%esp)
  8013f2:	00 
  8013f3:	c7 44 24 04 a8 00 00 	movl   $0xa8,0x4(%esp)
  8013fa:	00 
  8013fb:	c7 04 24 c3 1b 80 00 	movl   $0x801bc3,(%esp)
  801402:	e8 b9 ed ff ff       	call   8001c0 <_panic>
  801407:	66 90                	xchg   %ax,%ax
  801409:	66 90                	xchg   %ax,%ax
  80140b:	66 90                	xchg   %ax,%ax
  80140d:	66 90                	xchg   %ax,%ax
  80140f:	90                   	nop

00801410 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801410:	55                   	push   %ebp
  801411:	89 e5                	mov    %esp,%ebp
  801413:	56                   	push   %esi
  801414:	53                   	push   %ebx
  801415:	83 ec 10             	sub    $0x10,%esp
  801418:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80141b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80141e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int ret;
	if (pg) {
  801421:	85 c0                	test   %eax,%eax
  801423:	74 0a                	je     80142f <ipc_recv+0x1f>
		ret = sys_ipc_recv(pg);
  801425:	89 04 24             	mov    %eax,(%esp)
  801428:	e8 3a fc ff ff       	call   801067 <sys_ipc_recv>
  80142d:	eb 0c                	jmp    80143b <ipc_recv+0x2b>
	} else {
		ret = sys_ipc_recv((void*)(UTOP + 1));
  80142f:	c7 04 24 01 00 c0 ee 	movl   $0xeec00001,(%esp)
  801436:	e8 2c fc ff ff       	call   801067 <sys_ipc_recv>
	}
	if (ret < 0) {
  80143b:	85 c0                	test   %eax,%eax
  80143d:	79 1e                	jns    80145d <ipc_recv+0x4d>
		if (!from_env_store) {
  80143f:	85 db                	test   %ebx,%ebx
  801441:	75 0a                	jne    80144d <ipc_recv+0x3d>
			*(from_env_store) = 0;
  801443:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80144a:	00 00 00 
		}
		if (!perm_store) {
  80144d:	85 f6                	test   %esi,%esi
  80144f:	75 30                	jne    801481 <ipc_recv+0x71>
			*(perm_store) = 0;
  801451:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  801458:	00 00 00 
  80145b:	eb 24                	jmp    801481 <ipc_recv+0x71>
		}
		return ret;
	}
	if (perm_store) {
  80145d:	85 f6                	test   %esi,%esi
  80145f:	74 0a                	je     80146b <ipc_recv+0x5b>
		*(perm_store) = thisenv->env_ipc_perm;
  801461:	a1 04 20 80 00       	mov    0x802004,%eax
  801466:	8b 40 78             	mov    0x78(%eax),%eax
  801469:	89 06                	mov    %eax,(%esi)
	}
	if (from_env_store) {
  80146b:	85 db                	test   %ebx,%ebx
  80146d:	74 0a                	je     801479 <ipc_recv+0x69>
		*(from_env_store) = thisenv->env_ipc_from;
  80146f:	a1 04 20 80 00       	mov    0x802004,%eax
  801474:	8b 40 74             	mov    0x74(%eax),%eax
  801477:	89 03                	mov    %eax,(%ebx)
	}
	return thisenv->env_ipc_value;
  801479:	a1 04 20 80 00       	mov    0x802004,%eax
  80147e:	8b 40 70             	mov    0x70(%eax),%eax
	// panic("ipc_recv not implemented");
	// return 0;
}
  801481:	83 c4 10             	add    $0x10,%esp
  801484:	5b                   	pop    %ebx
  801485:	5e                   	pop    %esi
  801486:	5d                   	pop    %ebp
  801487:	c3                   	ret    

00801488 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
  80148b:	57                   	push   %edi
  80148c:	56                   	push   %esi
  80148d:	53                   	push   %ebx
  80148e:	83 ec 1c             	sub    $0x1c,%esp
  801491:	8b 7d 08             	mov    0x8(%ebp),%edi
  801494:	8b 75 0c             	mov    0xc(%ebp),%esi
  801497:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  80149a:	85 db                	test   %ebx,%ebx
		pg = (void*)(UTOP + 1);
  80149c:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
  8014a1:	0f 44 d8             	cmove  %eax,%ebx
	}
	int ret;
	
	while (1) {
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8014a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014ab:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014b3:	89 3c 24             	mov    %edi,(%esp)
  8014b6:	e8 78 fb ff ff       	call   801033 <sys_ipc_try_send>
		if (!ret) {
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	74 28                	je     8014e7 <ipc_send+0x5f>
			break;
		}
		if (ret != -E_IPC_NOT_RECV) {
  8014bf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8014c2:	74 1c                	je     8014e0 <ipc_send+0x58>
			panic("FATAL:ipc_send failed\n");
  8014c4:	c7 44 24 08 ea 1c 80 	movl   $0x801cea,0x8(%esp)
  8014cb:	00 
  8014cc:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  8014d3:	00 
  8014d4:	c7 04 24 01 1d 80 00 	movl   $0x801d01,(%esp)
  8014db:	e8 e0 ec ff ff       	call   8001c0 <_panic>
		}
		sys_yield();
  8014e0:	e8 47 f9 ff ff       	call   800e2c <sys_yield>
	}
  8014e5:	eb bd                	jmp    8014a4 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  8014e7:	83 c4 1c             	add    $0x1c,%esp
  8014ea:	5b                   	pop    %ebx
  8014eb:	5e                   	pop    %esi
  8014ec:	5f                   	pop    %edi
  8014ed:	5d                   	pop    %ebp
  8014ee:	c3                   	ret    

008014ef <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8014ef:	55                   	push   %ebp
  8014f0:	89 e5                	mov    %esp,%ebp
  8014f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8014f5:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8014fa:	39 c8                	cmp    %ecx,%eax
  8014fc:	74 17                	je     801515 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8014fe:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801503:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801506:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80150c:	8b 52 50             	mov    0x50(%edx),%edx
  80150f:	39 ca                	cmp    %ecx,%edx
  801511:	75 14                	jne    801527 <ipc_find_env+0x38>
  801513:	eb 05                	jmp    80151a <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801515:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80151a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80151d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801522:	8b 40 40             	mov    0x40(%eax),%eax
  801525:	eb 0e                	jmp    801535 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801527:	83 c0 01             	add    $0x1,%eax
  80152a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80152f:	75 d2                	jne    801503 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801531:	66 b8 00 00          	mov    $0x0,%ax
}
  801535:	5d                   	pop    %ebp
  801536:	c3                   	ret    
  801537:	90                   	nop

00801538 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801538:	55                   	push   %ebp
  801539:	89 e5                	mov    %esp,%ebp
  80153b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80153e:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801545:	75 60                	jne    8015a7 <set_pgfault_handler+0x6f>
		// First time through!
		// LAB 4: Your code here.
		int ret =
  801547:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80154e:	00 
  80154f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801556:	ee 
  801557:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80155e:	e8 f9 f8 ff ff       	call   800e5c <sys_page_alloc>
			sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE),
							PTE_U | PTE_P | PTE_W);
		if (ret < 0) {
  801563:	85 c0                	test   %eax,%eax
  801565:	79 2c                	jns    801593 <set_pgfault_handler+0x5b>
			cprintf("%e\n", ret);
  801567:	89 44 24 04          	mov    %eax,0x4(%esp)
  80156b:	c7 04 24 e6 1b 80 00 	movl   $0x801be6,(%esp)
  801572:	e8 44 ed ff ff       	call   8002bb <cprintf>
			panic("Something wrong with allocation of user exception"
  801577:	c7 44 24 08 1c 1d 80 	movl   $0x801d1c,0x8(%esp)
  80157e:	00 
  80157f:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  801586:	00 
  801587:	c7 04 24 0b 1d 80 00 	movl   $0x801d0b,(%esp)
  80158e:	e8 2d ec ff ff       	call   8001c0 <_panic>
				  "stack\n");
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801593:	c7 44 24 04 b4 15 80 	movl   $0x8015b4,0x4(%esp)
  80159a:	00 
  80159b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015a2:	e8 2e fa ff ff       	call   800fd5 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8015a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015aa:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8015af:	c9                   	leave  
  8015b0:	c3                   	ret    
  8015b1:	66 90                	xchg   %ax,%ax
  8015b3:	90                   	nop

008015b4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8015b4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8015b5:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8015ba:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8015bc:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	popl %eax
  8015bf:	58                   	pop    %eax
	popl %eax
  8015c0:	58                   	pop    %eax
	
	addl $32, %esp
  8015c1:	83 c4 20             	add    $0x20,%esp
	movl (%esp), %eax
  8015c4:	8b 04 24             	mov    (%esp),%eax
	addl $8, %esp
  8015c7:	83 c4 08             	add    $0x8,%esp
	movl (%esp), %ebx
  8015ca:	8b 1c 24             	mov    (%esp),%ebx
	subl $4, %ebx
  8015cd:	83 eb 04             	sub    $0x4,%ebx

	movl %ebx, (%esp)
  8015d0:	89 1c 24             	mov    %ebx,(%esp)

	movl %eax, (%ebx)
  8015d3:	89 03                	mov    %eax,(%ebx)
	subl $40, %esp
  8015d5:	83 ec 28             	sub    $0x28,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	popl %edi
  8015d8:	5f                   	pop    %edi
	popl %esi
  8015d9:	5e                   	pop    %esi
	popl %ebp
  8015da:	5d                   	pop    %ebp
	addl $4, %esp
  8015db:	83 c4 04             	add    $0x4,%esp
	popl %ebx
  8015de:	5b                   	pop    %ebx
	popl %edx
  8015df:	5a                   	pop    %edx
	popl %ecx
  8015e0:	59                   	pop    %ecx
	popl %eax
  8015e1:	58                   	pop    %eax
	addl $4, %esp
  8015e2:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	popfl
  8015e5:	9d                   	popf   
	
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	movl (%esp), %esp
  8015e6:	8b 24 24             	mov    (%esp),%esp
	
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8015e9:	c3                   	ret    
  8015ea:	66 90                	xchg   %ax,%ax
  8015ec:	66 90                	xchg   %ax,%ax
  8015ee:	66 90                	xchg   %ax,%ax

008015f0 <__udivdi3>:
  8015f0:	83 ec 1c             	sub    $0x1c,%esp
  8015f3:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8015f7:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8015fb:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8015ff:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801603:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801607:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  80160b:	85 c0                	test   %eax,%eax
  80160d:	89 74 24 10          	mov    %esi,0x10(%esp)
  801611:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801615:	89 ea                	mov    %ebp,%edx
  801617:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80161b:	75 33                	jne    801650 <__udivdi3+0x60>
  80161d:	39 e9                	cmp    %ebp,%ecx
  80161f:	77 6f                	ja     801690 <__udivdi3+0xa0>
  801621:	85 c9                	test   %ecx,%ecx
  801623:	89 ce                	mov    %ecx,%esi
  801625:	75 0b                	jne    801632 <__udivdi3+0x42>
  801627:	b8 01 00 00 00       	mov    $0x1,%eax
  80162c:	31 d2                	xor    %edx,%edx
  80162e:	f7 f1                	div    %ecx
  801630:	89 c6                	mov    %eax,%esi
  801632:	31 d2                	xor    %edx,%edx
  801634:	89 e8                	mov    %ebp,%eax
  801636:	f7 f6                	div    %esi
  801638:	89 c5                	mov    %eax,%ebp
  80163a:	89 f8                	mov    %edi,%eax
  80163c:	f7 f6                	div    %esi
  80163e:	89 ea                	mov    %ebp,%edx
  801640:	8b 74 24 10          	mov    0x10(%esp),%esi
  801644:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801648:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80164c:	83 c4 1c             	add    $0x1c,%esp
  80164f:	c3                   	ret    
  801650:	39 e8                	cmp    %ebp,%eax
  801652:	77 24                	ja     801678 <__udivdi3+0x88>
  801654:	0f bd c8             	bsr    %eax,%ecx
  801657:	83 f1 1f             	xor    $0x1f,%ecx
  80165a:	89 0c 24             	mov    %ecx,(%esp)
  80165d:	75 49                	jne    8016a8 <__udivdi3+0xb8>
  80165f:	8b 74 24 08          	mov    0x8(%esp),%esi
  801663:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801667:	0f 86 ab 00 00 00    	jbe    801718 <__udivdi3+0x128>
  80166d:	39 e8                	cmp    %ebp,%eax
  80166f:	0f 82 a3 00 00 00    	jb     801718 <__udivdi3+0x128>
  801675:	8d 76 00             	lea    0x0(%esi),%esi
  801678:	31 d2                	xor    %edx,%edx
  80167a:	31 c0                	xor    %eax,%eax
  80167c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801680:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801684:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801688:	83 c4 1c             	add    $0x1c,%esp
  80168b:	c3                   	ret    
  80168c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801690:	89 f8                	mov    %edi,%eax
  801692:	f7 f1                	div    %ecx
  801694:	31 d2                	xor    %edx,%edx
  801696:	8b 74 24 10          	mov    0x10(%esp),%esi
  80169a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80169e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8016a2:	83 c4 1c             	add    $0x1c,%esp
  8016a5:	c3                   	ret    
  8016a6:	66 90                	xchg   %ax,%ax
  8016a8:	0f b6 0c 24          	movzbl (%esp),%ecx
  8016ac:	89 c6                	mov    %eax,%esi
  8016ae:	b8 20 00 00 00       	mov    $0x20,%eax
  8016b3:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  8016b7:	2b 04 24             	sub    (%esp),%eax
  8016ba:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8016be:	d3 e6                	shl    %cl,%esi
  8016c0:	89 c1                	mov    %eax,%ecx
  8016c2:	d3 ed                	shr    %cl,%ebp
  8016c4:	0f b6 0c 24          	movzbl (%esp),%ecx
  8016c8:	09 f5                	or     %esi,%ebp
  8016ca:	8b 74 24 04          	mov    0x4(%esp),%esi
  8016ce:	d3 e6                	shl    %cl,%esi
  8016d0:	89 c1                	mov    %eax,%ecx
  8016d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016d6:	89 d6                	mov    %edx,%esi
  8016d8:	d3 ee                	shr    %cl,%esi
  8016da:	0f b6 0c 24          	movzbl (%esp),%ecx
  8016de:	d3 e2                	shl    %cl,%edx
  8016e0:	89 c1                	mov    %eax,%ecx
  8016e2:	d3 ef                	shr    %cl,%edi
  8016e4:	09 d7                	or     %edx,%edi
  8016e6:	89 f2                	mov    %esi,%edx
  8016e8:	89 f8                	mov    %edi,%eax
  8016ea:	f7 f5                	div    %ebp
  8016ec:	89 d6                	mov    %edx,%esi
  8016ee:	89 c7                	mov    %eax,%edi
  8016f0:	f7 64 24 04          	mull   0x4(%esp)
  8016f4:	39 d6                	cmp    %edx,%esi
  8016f6:	72 30                	jb     801728 <__udivdi3+0x138>
  8016f8:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8016fc:	0f b6 0c 24          	movzbl (%esp),%ecx
  801700:	d3 e5                	shl    %cl,%ebp
  801702:	39 c5                	cmp    %eax,%ebp
  801704:	73 04                	jae    80170a <__udivdi3+0x11a>
  801706:	39 d6                	cmp    %edx,%esi
  801708:	74 1e                	je     801728 <__udivdi3+0x138>
  80170a:	89 f8                	mov    %edi,%eax
  80170c:	31 d2                	xor    %edx,%edx
  80170e:	e9 69 ff ff ff       	jmp    80167c <__udivdi3+0x8c>
  801713:	90                   	nop
  801714:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801718:	31 d2                	xor    %edx,%edx
  80171a:	b8 01 00 00 00       	mov    $0x1,%eax
  80171f:	e9 58 ff ff ff       	jmp    80167c <__udivdi3+0x8c>
  801724:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801728:	8d 47 ff             	lea    -0x1(%edi),%eax
  80172b:	31 d2                	xor    %edx,%edx
  80172d:	8b 74 24 10          	mov    0x10(%esp),%esi
  801731:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801735:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801739:	83 c4 1c             	add    $0x1c,%esp
  80173c:	c3                   	ret    
  80173d:	66 90                	xchg   %ax,%ax
  80173f:	90                   	nop

00801740 <__umoddi3>:
  801740:	83 ec 2c             	sub    $0x2c,%esp
  801743:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801747:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80174b:	89 74 24 20          	mov    %esi,0x20(%esp)
  80174f:	8b 74 24 38          	mov    0x38(%esp),%esi
  801753:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801757:	8b 7c 24 34          	mov    0x34(%esp),%edi
  80175b:	85 c0                	test   %eax,%eax
  80175d:	89 c2                	mov    %eax,%edx
  80175f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801763:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801767:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80176b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80176f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801773:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801777:	75 1f                	jne    801798 <__umoddi3+0x58>
  801779:	39 fe                	cmp    %edi,%esi
  80177b:	76 63                	jbe    8017e0 <__umoddi3+0xa0>
  80177d:	89 c8                	mov    %ecx,%eax
  80177f:	89 fa                	mov    %edi,%edx
  801781:	f7 f6                	div    %esi
  801783:	89 d0                	mov    %edx,%eax
  801785:	31 d2                	xor    %edx,%edx
  801787:	8b 74 24 20          	mov    0x20(%esp),%esi
  80178b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80178f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801793:	83 c4 2c             	add    $0x2c,%esp
  801796:	c3                   	ret    
  801797:	90                   	nop
  801798:	39 f8                	cmp    %edi,%eax
  80179a:	77 64                	ja     801800 <__umoddi3+0xc0>
  80179c:	0f bd e8             	bsr    %eax,%ebp
  80179f:	83 f5 1f             	xor    $0x1f,%ebp
  8017a2:	75 74                	jne    801818 <__umoddi3+0xd8>
  8017a4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8017a8:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  8017ac:	0f 87 0e 01 00 00    	ja     8018c0 <__umoddi3+0x180>
  8017b2:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  8017b6:	29 f1                	sub    %esi,%ecx
  8017b8:	19 c7                	sbb    %eax,%edi
  8017ba:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8017be:	89 7c 24 18          	mov    %edi,0x18(%esp)
  8017c2:	8b 44 24 14          	mov    0x14(%esp),%eax
  8017c6:	8b 54 24 18          	mov    0x18(%esp),%edx
  8017ca:	8b 74 24 20          	mov    0x20(%esp),%esi
  8017ce:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8017d2:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8017d6:	83 c4 2c             	add    $0x2c,%esp
  8017d9:	c3                   	ret    
  8017da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8017e0:	85 f6                	test   %esi,%esi
  8017e2:	89 f5                	mov    %esi,%ebp
  8017e4:	75 0b                	jne    8017f1 <__umoddi3+0xb1>
  8017e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8017eb:	31 d2                	xor    %edx,%edx
  8017ed:	f7 f6                	div    %esi
  8017ef:	89 c5                	mov    %eax,%ebp
  8017f1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8017f5:	31 d2                	xor    %edx,%edx
  8017f7:	f7 f5                	div    %ebp
  8017f9:	89 c8                	mov    %ecx,%eax
  8017fb:	f7 f5                	div    %ebp
  8017fd:	eb 84                	jmp    801783 <__umoddi3+0x43>
  8017ff:	90                   	nop
  801800:	89 c8                	mov    %ecx,%eax
  801802:	89 fa                	mov    %edi,%edx
  801804:	8b 74 24 20          	mov    0x20(%esp),%esi
  801808:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80180c:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801810:	83 c4 2c             	add    $0x2c,%esp
  801813:	c3                   	ret    
  801814:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801818:	8b 44 24 10          	mov    0x10(%esp),%eax
  80181c:	be 20 00 00 00       	mov    $0x20,%esi
  801821:	89 e9                	mov    %ebp,%ecx
  801823:	29 ee                	sub    %ebp,%esi
  801825:	d3 e2                	shl    %cl,%edx
  801827:	89 f1                	mov    %esi,%ecx
  801829:	d3 e8                	shr    %cl,%eax
  80182b:	89 e9                	mov    %ebp,%ecx
  80182d:	09 d0                	or     %edx,%eax
  80182f:	89 fa                	mov    %edi,%edx
  801831:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801835:	8b 44 24 10          	mov    0x10(%esp),%eax
  801839:	d3 e0                	shl    %cl,%eax
  80183b:	89 f1                	mov    %esi,%ecx
  80183d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801841:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801845:	d3 ea                	shr    %cl,%edx
  801847:	89 e9                	mov    %ebp,%ecx
  801849:	d3 e7                	shl    %cl,%edi
  80184b:	89 f1                	mov    %esi,%ecx
  80184d:	d3 e8                	shr    %cl,%eax
  80184f:	89 e9                	mov    %ebp,%ecx
  801851:	09 f8                	or     %edi,%eax
  801853:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801857:	f7 74 24 0c          	divl   0xc(%esp)
  80185b:	d3 e7                	shl    %cl,%edi
  80185d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801861:	89 d7                	mov    %edx,%edi
  801863:	f7 64 24 10          	mull   0x10(%esp)
  801867:	39 d7                	cmp    %edx,%edi
  801869:	89 c1                	mov    %eax,%ecx
  80186b:	89 54 24 14          	mov    %edx,0x14(%esp)
  80186f:	72 3b                	jb     8018ac <__umoddi3+0x16c>
  801871:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801875:	72 31                	jb     8018a8 <__umoddi3+0x168>
  801877:	8b 44 24 18          	mov    0x18(%esp),%eax
  80187b:	29 c8                	sub    %ecx,%eax
  80187d:	19 d7                	sbb    %edx,%edi
  80187f:	89 e9                	mov    %ebp,%ecx
  801881:	89 fa                	mov    %edi,%edx
  801883:	d3 e8                	shr    %cl,%eax
  801885:	89 f1                	mov    %esi,%ecx
  801887:	d3 e2                	shl    %cl,%edx
  801889:	89 e9                	mov    %ebp,%ecx
  80188b:	09 d0                	or     %edx,%eax
  80188d:	89 fa                	mov    %edi,%edx
  80188f:	d3 ea                	shr    %cl,%edx
  801891:	8b 74 24 20          	mov    0x20(%esp),%esi
  801895:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801899:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  80189d:	83 c4 2c             	add    $0x2c,%esp
  8018a0:	c3                   	ret    
  8018a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8018a8:	39 d7                	cmp    %edx,%edi
  8018aa:	75 cb                	jne    801877 <__umoddi3+0x137>
  8018ac:	8b 54 24 14          	mov    0x14(%esp),%edx
  8018b0:	89 c1                	mov    %eax,%ecx
  8018b2:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  8018b6:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  8018ba:	eb bb                	jmp    801877 <__umoddi3+0x137>
  8018bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8018c0:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8018c4:	0f 82 e8 fe ff ff    	jb     8017b2 <__umoddi3+0x72>
  8018ca:	e9 f3 fe ff ff       	jmp    8017c2 <__umoddi3+0x82>
