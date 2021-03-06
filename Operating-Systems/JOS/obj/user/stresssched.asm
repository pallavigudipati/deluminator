
obj/user/stresssched:     file format elf32-i386


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
  80002c:	e8 f7 00 00 00       	call   800128 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800048:	e8 7f 0d 00 00       	call   800dcc <sys_getenvid>
  80004d:	89 c6                	mov    %eax,%esi
	
	// Fork several environments
	for (i = 0; i < 20; i++)
  80004f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0) {
  800054:	e8 40 11 00 00       	call   801199 <fork>
  800059:	85 c0                	test   %eax,%eax
  80005b:	74 0a                	je     800067 <umain+0x27>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
	
	// Fork several environments
	for (i = 0; i < 20; i++)
  80005d:	83 c3 01             	add    $0x1,%ebx
  800060:	83 fb 14             	cmp    $0x14,%ebx
  800063:	75 ef                	jne    800054 <umain+0x14>
  800065:	eb 23                	jmp    80008a <umain+0x4a>
		if (fork() == 0) {
			break;
		}
	if (i == 20) {
  800067:	83 fb 14             	cmp    $0x14,%ebx
  80006a:	74 1e                	je     80008a <umain+0x4a>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006c:	89 f0                	mov    %esi,%eax
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800076:	81 c2 04 00 c0 ee    	add    $0xeec00004,%edx
  80007c:	8b 52 50             	mov    0x50(%edx),%edx
  80007f:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800084:	85 d2                	test   %edx,%edx
  800086:	74 24                	je     8000ac <umain+0x6c>
  800088:	eb 0b                	jmp    800095 <umain+0x55>
	for (i = 0; i < 20; i++)
		if (fork() == 0) {
			break;
		}
	if (i == 20) {
		sys_yield();
  80008a:	e8 6d 0d 00 00       	call   800dfc <sys_yield>
		return;
  80008f:	90                   	nop
  800090:	e9 8a 00 00 00       	jmp    80011f <umain+0xdf>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800095:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800098:	8d 90 04 00 c0 ee    	lea    -0x113ffffc(%eax),%edx
		asm volatile("pause");
  80009e:	f3 90                	pause  
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  8000a0:	8b 42 50             	mov    0x50(%edx),%eax
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	75 f7                	jne    80009e <umain+0x5e>
  8000a7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  8000ac:	e8 4b 0d 00 00       	call   800dfc <sys_yield>
  8000b1:	b8 10 27 00 00       	mov    $0x2710,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  8000b6:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8000bc:	83 c2 01             	add    $0x1,%edx
  8000bf:	89 15 04 20 80 00    	mov    %edx,0x802004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000c5:	83 e8 01             	sub    $0x1,%eax
  8000c8:	75 ec                	jne    8000b6 <umain+0x76>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000ca:	83 eb 01             	sub    $0x1,%ebx
  8000cd:	75 dd                	jne    8000ac <umain+0x6c>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000cf:	a1 04 20 80 00       	mov    0x802004,%eax
  8000d4:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000d9:	74 25                	je     800100 <umain+0xc0>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000db:	a1 04 20 80 00       	mov    0x802004,%eax
  8000e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000e4:	c7 44 24 08 80 17 80 	movl   $0x801780,0x8(%esp)
  8000eb:	00 
  8000ec:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000f3:	00 
  8000f4:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  8000fb:	e8 98 00 00 00       	call   800198 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  800100:	a1 08 20 80 00       	mov    0x802008,%eax
  800105:	8b 50 5c             	mov    0x5c(%eax),%edx
  800108:	8b 40 48             	mov    0x48(%eax),%eax
  80010b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80010f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800113:	c7 04 24 bb 17 80 00 	movl   $0x8017bb,(%esp)
  80011a:	e8 74 01 00 00       	call   800293 <cprintf>

}
  80011f:	83 c4 10             	add    $0x10,%esp
  800122:	5b                   	pop    %ebx
  800123:	5e                   	pop    %esi
  800124:	5d                   	pop    %ebp
  800125:	c3                   	ret    
  800126:	66 90                	xchg   %ax,%ax

00800128 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	83 ec 18             	sub    $0x18,%esp
  80012e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800131:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800134:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800137:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80013a:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800141:	00 00 00 
	int envid;
	envid = sys_getenvid();
  800144:	e8 83 0c 00 00       	call   800dcc <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800149:	25 ff 03 00 00       	and    $0x3ff,%eax
  80014e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800151:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800156:	a3 08 20 80 00       	mov    %eax,0x802008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80015b:	85 db                	test   %ebx,%ebx
  80015d:	7e 07                	jle    800166 <libmain+0x3e>
		binaryname = argv[0];
  80015f:	8b 06                	mov    (%esi),%eax
  800161:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800166:	89 74 24 04          	mov    %esi,0x4(%esp)
  80016a:	89 1c 24             	mov    %ebx,(%esp)
  80016d:	e8 ce fe ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  800172:	e8 0d 00 00 00       	call   800184 <exit>
}
  800177:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80017a:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80017d:	89 ec                	mov    %ebp,%esp
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    
  800181:	66 90                	xchg   %ax,%ax
  800183:	90                   	nop

00800184 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80018a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800191:	e8 d9 0b 00 00       	call   800d6f <sys_env_destroy>
}
  800196:	c9                   	leave  
  800197:	c3                   	ret    

00800198 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	56                   	push   %esi
  80019c:	53                   	push   %ebx
  80019d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001a0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001a3:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8001a9:	e8 1e 0c 00 00       	call   800dcc <sys_getenvid>
  8001ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001bc:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c4:	c7 04 24 e4 17 80 00 	movl   $0x8017e4,(%esp)
  8001cb:	e8 c3 00 00 00       	call   800293 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d7:	89 04 24             	mov    %eax,(%esp)
  8001da:	e8 53 00 00 00       	call   800232 <vcprintf>
	cprintf("\n");
  8001df:	c7 04 24 d7 17 80 00 	movl   $0x8017d7,(%esp)
  8001e6:	e8 a8 00 00 00       	call   800293 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001eb:	cc                   	int3   
  8001ec:	eb fd                	jmp    8001eb <_panic+0x53>
  8001ee:	66 90                	xchg   %ax,%ax

008001f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	53                   	push   %ebx
  8001f4:	83 ec 14             	sub    $0x14,%esp
  8001f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001fa:	8b 03                	mov    (%ebx),%eax
  8001fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ff:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800203:	83 c0 01             	add    $0x1,%eax
  800206:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800208:	3d ff 00 00 00       	cmp    $0xff,%eax
  80020d:	75 19                	jne    800228 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80020f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800216:	00 
  800217:	8d 43 08             	lea    0x8(%ebx),%eax
  80021a:	89 04 24             	mov    %eax,(%esp)
  80021d:	e8 ee 0a 00 00       	call   800d10 <sys_cputs>
		b->idx = 0;
  800222:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800228:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80022c:	83 c4 14             	add    $0x14,%esp
  80022f:	5b                   	pop    %ebx
  800230:	5d                   	pop    %ebp
  800231:	c3                   	ret    

00800232 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80023b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800242:	00 00 00 
	b.cnt = 0;
  800245:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80024c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80024f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800252:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800256:	8b 45 08             	mov    0x8(%ebp),%eax
  800259:	89 44 24 08          	mov    %eax,0x8(%esp)
  80025d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800263:	89 44 24 04          	mov    %eax,0x4(%esp)
  800267:	c7 04 24 f0 01 80 00 	movl   $0x8001f0,(%esp)
  80026e:	e8 af 01 00 00       	call   800422 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800273:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800279:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800283:	89 04 24             	mov    %eax,(%esp)
  800286:	e8 85 0a 00 00       	call   800d10 <sys_cputs>

	return b.cnt;
}
  80028b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800291:	c9                   	leave  
  800292:	c3                   	ret    

00800293 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800299:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80029c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a3:	89 04 24             	mov    %eax,(%esp)
  8002a6:	e8 87 ff ff ff       	call   800232 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002ab:	c9                   	leave  
  8002ac:	c3                   	ret    
  8002ad:	66 90                	xchg   %ax,%ax
  8002af:	90                   	nop

008002b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	57                   	push   %edi
  8002b4:	56                   	push   %esi
  8002b5:	53                   	push   %ebx
  8002b6:	83 ec 4c             	sub    $0x4c,%esp
  8002b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002bc:	89 d7                	mov    %edx,%edi
  8002be:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002c1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8002c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002c7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8002cf:	39 d8                	cmp    %ebx,%eax
  8002d1:	72 17                	jb     8002ea <printnum+0x3a>
  8002d3:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8002d6:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  8002d9:	76 0f                	jbe    8002ea <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002db:	8b 75 14             	mov    0x14(%ebp),%esi
  8002de:	83 ee 01             	sub    $0x1,%esi
  8002e1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002e4:	85 f6                	test   %esi,%esi
  8002e6:	7f 63                	jg     80034b <printnum+0x9b>
  8002e8:	eb 75                	jmp    80035f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ea:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8002ed:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8002f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f4:	83 e8 01             	sub    $0x1,%eax
  8002f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800302:	8b 44 24 08          	mov    0x8(%esp),%eax
  800306:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80030a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80030d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800310:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800317:	00 
  800318:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80031b:	89 1c 24             	mov    %ebx,(%esp)
  80031e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800321:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800325:	e8 66 11 00 00       	call   801490 <__udivdi3>
  80032a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80032d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800330:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800334:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800338:	89 04 24             	mov    %eax,(%esp)
  80033b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80033f:	89 fa                	mov    %edi,%edx
  800341:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800344:	e8 67 ff ff ff       	call   8002b0 <printnum>
  800349:	eb 14                	jmp    80035f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80034b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80034f:	8b 45 18             	mov    0x18(%ebp),%eax
  800352:	89 04 24             	mov    %eax,(%esp)
  800355:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800357:	83 ee 01             	sub    $0x1,%esi
  80035a:	75 ef                	jne    80034b <printnum+0x9b>
  80035c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80035f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800363:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800367:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80036a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80036e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800375:	00 
  800376:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800379:	89 1c 24             	mov    %ebx,(%esp)
  80037c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80037f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800383:	e8 58 12 00 00       	call   8015e0 <__umoddi3>
  800388:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80038c:	0f be 80 07 18 80 00 	movsbl 0x801807(%eax),%eax
  800393:	89 04 24             	mov    %eax,(%esp)
  800396:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800399:	ff d0                	call   *%eax
}
  80039b:	83 c4 4c             	add    $0x4c,%esp
  80039e:	5b                   	pop    %ebx
  80039f:	5e                   	pop    %esi
  8003a0:	5f                   	pop    %edi
  8003a1:	5d                   	pop    %ebp
  8003a2:	c3                   	ret    

008003a3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003a6:	83 fa 01             	cmp    $0x1,%edx
  8003a9:	7e 0e                	jle    8003b9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003ab:	8b 10                	mov    (%eax),%edx
  8003ad:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003b0:	89 08                	mov    %ecx,(%eax)
  8003b2:	8b 02                	mov    (%edx),%eax
  8003b4:	8b 52 04             	mov    0x4(%edx),%edx
  8003b7:	eb 22                	jmp    8003db <getuint+0x38>
	else if (lflag)
  8003b9:	85 d2                	test   %edx,%edx
  8003bb:	74 10                	je     8003cd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003bd:	8b 10                	mov    (%eax),%edx
  8003bf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c2:	89 08                	mov    %ecx,(%eax)
  8003c4:	8b 02                	mov    (%edx),%eax
  8003c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003cb:	eb 0e                	jmp    8003db <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003cd:	8b 10                	mov    (%eax),%edx
  8003cf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d2:	89 08                	mov    %ecx,(%eax)
  8003d4:	8b 02                	mov    (%edx),%eax
  8003d6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003db:	5d                   	pop    %ebp
  8003dc:	c3                   	ret    

008003dd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003dd:	55                   	push   %ebp
  8003de:	89 e5                	mov    %esp,%ebp
  8003e0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003e3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003e7:	8b 10                	mov    (%eax),%edx
  8003e9:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ec:	73 0a                	jae    8003f8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f1:	88 0a                	mov    %cl,(%edx)
  8003f3:	83 c2 01             	add    $0x1,%edx
  8003f6:	89 10                	mov    %edx,(%eax)
}
  8003f8:	5d                   	pop    %ebp
  8003f9:	c3                   	ret    

008003fa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003fa:	55                   	push   %ebp
  8003fb:	89 e5                	mov    %esp,%ebp
  8003fd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800400:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800403:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800407:	8b 45 10             	mov    0x10(%ebp),%eax
  80040a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80040e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800411:	89 44 24 04          	mov    %eax,0x4(%esp)
  800415:	8b 45 08             	mov    0x8(%ebp),%eax
  800418:	89 04 24             	mov    %eax,(%esp)
  80041b:	e8 02 00 00 00       	call   800422 <vprintfmt>
	va_end(ap);
}
  800420:	c9                   	leave  
  800421:	c3                   	ret    

00800422 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800422:	55                   	push   %ebp
  800423:	89 e5                	mov    %esp,%ebp
  800425:	57                   	push   %edi
  800426:	56                   	push   %esi
  800427:	53                   	push   %ebx
  800428:	83 ec 4c             	sub    $0x4c,%esp
  80042b:	8b 75 08             	mov    0x8(%ebp),%esi
  80042e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800431:	8b 7d 10             	mov    0x10(%ebp),%edi
  800434:	eb 11                	jmp    800447 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800436:	85 c0                	test   %eax,%eax
  800438:	0f 84 db 03 00 00    	je     800819 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  80043e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800442:	89 04 24             	mov    %eax,(%esp)
  800445:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800447:	0f b6 07             	movzbl (%edi),%eax
  80044a:	83 c7 01             	add    $0x1,%edi
  80044d:	83 f8 25             	cmp    $0x25,%eax
  800450:	75 e4                	jne    800436 <vprintfmt+0x14>
  800452:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800456:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80045d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800464:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80046b:	ba 00 00 00 00       	mov    $0x0,%edx
  800470:	eb 2b                	jmp    80049d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800472:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800475:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800479:	eb 22                	jmp    80049d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80047e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  800482:	eb 19                	jmp    80049d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800487:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80048e:	eb 0d                	jmp    80049d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800490:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800493:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800496:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	0f b6 0f             	movzbl (%edi),%ecx
  8004a0:	8d 47 01             	lea    0x1(%edi),%eax
  8004a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a6:	0f b6 07             	movzbl (%edi),%eax
  8004a9:	83 e8 23             	sub    $0x23,%eax
  8004ac:	3c 55                	cmp    $0x55,%al
  8004ae:	0f 87 40 03 00 00    	ja     8007f4 <vprintfmt+0x3d2>
  8004b4:	0f b6 c0             	movzbl %al,%eax
  8004b7:	ff 24 85 c0 18 80 00 	jmp    *0x8018c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004be:	83 e9 30             	sub    $0x30,%ecx
  8004c1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  8004c4:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  8004c8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004cb:	83 f9 09             	cmp    $0x9,%ecx
  8004ce:	77 57                	ja     800527 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d0:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004d3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004d6:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004dc:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004df:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8004e3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8004e6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004e9:	83 f9 09             	cmp    $0x9,%ecx
  8004ec:	76 eb                	jbe    8004d9 <vprintfmt+0xb7>
  8004ee:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004f1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004f4:	eb 34                	jmp    80052a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f9:	8d 48 04             	lea    0x4(%eax),%ecx
  8004fc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004ff:	8b 00                	mov    (%eax),%eax
  800501:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800504:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800507:	eb 21                	jmp    80052a <vprintfmt+0x108>

		case '.':
			if (width < 0)
  800509:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80050d:	0f 88 71 ff ff ff    	js     800484 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800513:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800516:	eb 85                	jmp    80049d <vprintfmt+0x7b>
  800518:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80051b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800522:	e9 76 ff ff ff       	jmp    80049d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800527:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80052a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80052e:	0f 89 69 ff ff ff    	jns    80049d <vprintfmt+0x7b>
  800534:	e9 57 ff ff ff       	jmp    800490 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800539:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80053f:	e9 59 ff ff ff       	jmp    80049d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800544:	8b 45 14             	mov    0x14(%ebp),%eax
  800547:	8d 50 04             	lea    0x4(%eax),%edx
  80054a:	89 55 14             	mov    %edx,0x14(%ebp)
  80054d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800551:	8b 00                	mov    (%eax),%eax
  800553:	89 04 24             	mov    %eax,(%esp)
  800556:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800558:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80055b:	e9 e7 fe ff ff       	jmp    800447 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8d 50 04             	lea    0x4(%eax),%edx
  800566:	89 55 14             	mov    %edx,0x14(%ebp)
  800569:	8b 00                	mov    (%eax),%eax
  80056b:	89 c2                	mov    %eax,%edx
  80056d:	c1 fa 1f             	sar    $0x1f,%edx
  800570:	31 d0                	xor    %edx,%eax
  800572:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800574:	83 f8 08             	cmp    $0x8,%eax
  800577:	7f 0b                	jg     800584 <vprintfmt+0x162>
  800579:	8b 14 85 20 1a 80 00 	mov    0x801a20(,%eax,4),%edx
  800580:	85 d2                	test   %edx,%edx
  800582:	75 20                	jne    8005a4 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800584:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800588:	c7 44 24 08 1f 18 80 	movl   $0x80181f,0x8(%esp)
  80058f:	00 
  800590:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800594:	89 34 24             	mov    %esi,(%esp)
  800597:	e8 5e fe ff ff       	call   8003fa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80059f:	e9 a3 fe ff ff       	jmp    800447 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8005a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005a8:	c7 44 24 08 28 18 80 	movl   $0x801828,0x8(%esp)
  8005af:	00 
  8005b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b4:	89 34 24             	mov    %esi,(%esp)
  8005b7:	e8 3e fe ff ff       	call   8003fa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bc:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005bf:	e9 83 fe ff ff       	jmp    800447 <vprintfmt+0x25>
  8005c4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005c7:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8005ca:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8d 50 04             	lea    0x4(%eax),%edx
  8005d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005d8:	85 ff                	test   %edi,%edi
  8005da:	b8 18 18 80 00       	mov    $0x801818,%eax
  8005df:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005e2:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  8005e6:	74 06                	je     8005ee <vprintfmt+0x1cc>
  8005e8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005ec:	7f 16                	jg     800604 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ee:	0f b6 17             	movzbl (%edi),%edx
  8005f1:	0f be c2             	movsbl %dl,%eax
  8005f4:	83 c7 01             	add    $0x1,%edi
  8005f7:	85 c0                	test   %eax,%eax
  8005f9:	0f 85 9f 00 00 00    	jne    80069e <vprintfmt+0x27c>
  8005ff:	e9 8b 00 00 00       	jmp    80068f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800604:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800608:	89 3c 24             	mov    %edi,(%esp)
  80060b:	e8 c2 02 00 00       	call   8008d2 <strnlen>
  800610:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800613:	29 c2                	sub    %eax,%edx
  800615:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800618:	85 d2                	test   %edx,%edx
  80061a:	7e d2                	jle    8005ee <vprintfmt+0x1cc>
					putch(padc, putdat);
  80061c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  800620:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800623:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800626:	89 d7                	mov    %edx,%edi
  800628:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80062f:	89 04 24             	mov    %eax,(%esp)
  800632:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800634:	83 ef 01             	sub    $0x1,%edi
  800637:	75 ef                	jne    800628 <vprintfmt+0x206>
  800639:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80063c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80063f:	eb ad                	jmp    8005ee <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800641:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800645:	74 20                	je     800667 <vprintfmt+0x245>
  800647:	0f be d2             	movsbl %dl,%edx
  80064a:	83 ea 20             	sub    $0x20,%edx
  80064d:	83 fa 5e             	cmp    $0x5e,%edx
  800650:	76 15                	jbe    800667 <vprintfmt+0x245>
					putch('?', putdat);
  800652:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800655:	89 54 24 04          	mov    %edx,0x4(%esp)
  800659:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800660:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800663:	ff d1                	call   *%ecx
  800665:	eb 0f                	jmp    800676 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800667:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80066a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80066e:	89 04 24             	mov    %eax,(%esp)
  800671:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800674:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800676:	83 eb 01             	sub    $0x1,%ebx
  800679:	0f b6 17             	movzbl (%edi),%edx
  80067c:	0f be c2             	movsbl %dl,%eax
  80067f:	83 c7 01             	add    $0x1,%edi
  800682:	85 c0                	test   %eax,%eax
  800684:	75 24                	jne    8006aa <vprintfmt+0x288>
  800686:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800689:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80068c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800692:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800696:	0f 8e ab fd ff ff    	jle    800447 <vprintfmt+0x25>
  80069c:	eb 20                	jmp    8006be <vprintfmt+0x29c>
  80069e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8006a1:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006a4:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8006a7:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006aa:	85 f6                	test   %esi,%esi
  8006ac:	78 93                	js     800641 <vprintfmt+0x21f>
  8006ae:	83 ee 01             	sub    $0x1,%esi
  8006b1:	79 8e                	jns    800641 <vprintfmt+0x21f>
  8006b3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8006b6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006b9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8006bc:	eb d1                	jmp    80068f <vprintfmt+0x26d>
  8006be:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006cc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ce:	83 ef 01             	sub    $0x1,%edi
  8006d1:	75 ee                	jne    8006c1 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006d6:	e9 6c fd ff ff       	jmp    800447 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006db:	83 fa 01             	cmp    $0x1,%edx
  8006de:	66 90                	xchg   %ax,%ax
  8006e0:	7e 16                	jle    8006f8 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  8006e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e5:	8d 50 08             	lea    0x8(%eax),%edx
  8006e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006eb:	8b 10                	mov    (%eax),%edx
  8006ed:	8b 48 04             	mov    0x4(%eax),%ecx
  8006f0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006f3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006f6:	eb 32                	jmp    80072a <vprintfmt+0x308>
	else if (lflag)
  8006f8:	85 d2                	test   %edx,%edx
  8006fa:	74 18                	je     800714 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  8006fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ff:	8d 50 04             	lea    0x4(%eax),%edx
  800702:	89 55 14             	mov    %edx,0x14(%ebp)
  800705:	8b 00                	mov    (%eax),%eax
  800707:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80070a:	89 c1                	mov    %eax,%ecx
  80070c:	c1 f9 1f             	sar    $0x1f,%ecx
  80070f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800712:	eb 16                	jmp    80072a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8d 50 04             	lea    0x4(%eax),%edx
  80071a:	89 55 14             	mov    %edx,0x14(%ebp)
  80071d:	8b 00                	mov    (%eax),%eax
  80071f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800722:	89 c7                	mov    %eax,%edi
  800724:	c1 ff 1f             	sar    $0x1f,%edi
  800727:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80072a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80072d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800730:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800735:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800739:	79 7d                	jns    8007b8 <vprintfmt+0x396>
				putch('-', putdat);
  80073b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800746:	ff d6                	call   *%esi
				num = -(long long) num;
  800748:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80074b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80074e:	f7 d8                	neg    %eax
  800750:	83 d2 00             	adc    $0x0,%edx
  800753:	f7 da                	neg    %edx
			}
			base = 10;
  800755:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80075a:	eb 5c                	jmp    8007b8 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80075c:	8d 45 14             	lea    0x14(%ebp),%eax
  80075f:	e8 3f fc ff ff       	call   8003a3 <getuint>
			base = 10;
  800764:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800769:	eb 4d                	jmp    8007b8 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80076b:	8d 45 14             	lea    0x14(%ebp),%eax
  80076e:	e8 30 fc ff ff       	call   8003a3 <getuint>
			base = 8;
  800773:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800778:	eb 3e                	jmp    8007b8 <vprintfmt+0x396>

		// pointer
		case 'p':
			putch('0', putdat);
  80077a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80077e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800785:	ff d6                	call   *%esi
			putch('x', putdat);
  800787:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800792:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800794:	8b 45 14             	mov    0x14(%ebp),%eax
  800797:	8d 50 04             	lea    0x4(%eax),%edx
  80079a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80079d:	8b 00                	mov    (%eax),%eax
  80079f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007a4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007a9:	eb 0d                	jmp    8007b8 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ae:	e8 f0 fb ff ff       	call   8003a3 <getuint>
			base = 16;
  8007b3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007b8:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  8007bc:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8007c0:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8007c3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8007c7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007cb:	89 04 24             	mov    %eax,(%esp)
  8007ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007d2:	89 da                	mov    %ebx,%edx
  8007d4:	89 f0                	mov    %esi,%eax
  8007d6:	e8 d5 fa ff ff       	call   8002b0 <printnum>
			break;
  8007db:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8007de:	e9 64 fc ff ff       	jmp    800447 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e7:	89 0c 24             	mov    %ecx,(%esp)
  8007ea:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ec:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ef:	e9 53 fc ff ff       	jmp    800447 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007ff:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800801:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800805:	0f 84 3c fc ff ff    	je     800447 <vprintfmt+0x25>
  80080b:	83 ef 01             	sub    $0x1,%edi
  80080e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800812:	75 f7                	jne    80080b <vprintfmt+0x3e9>
  800814:	e9 2e fc ff ff       	jmp    800447 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800819:	83 c4 4c             	add    $0x4c,%esp
  80081c:	5b                   	pop    %ebx
  80081d:	5e                   	pop    %esi
  80081e:	5f                   	pop    %edi
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	83 ec 28             	sub    $0x28,%esp
  800827:	8b 45 08             	mov    0x8(%ebp),%eax
  80082a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80082d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800830:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800834:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800837:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80083e:	85 d2                	test   %edx,%edx
  800840:	7e 30                	jle    800872 <vsnprintf+0x51>
  800842:	85 c0                	test   %eax,%eax
  800844:	74 2c                	je     800872 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800846:	8b 45 14             	mov    0x14(%ebp),%eax
  800849:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80084d:	8b 45 10             	mov    0x10(%ebp),%eax
  800850:	89 44 24 08          	mov    %eax,0x8(%esp)
  800854:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800857:	89 44 24 04          	mov    %eax,0x4(%esp)
  80085b:	c7 04 24 dd 03 80 00 	movl   $0x8003dd,(%esp)
  800862:	e8 bb fb ff ff       	call   800422 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800867:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80086a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80086d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800870:	eb 05                	jmp    800877 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800872:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800877:	c9                   	leave  
  800878:	c3                   	ret    

00800879 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80087f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800882:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800886:	8b 45 10             	mov    0x10(%ebp),%eax
  800889:	89 44 24 08          	mov    %eax,0x8(%esp)
  80088d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800890:	89 44 24 04          	mov    %eax,0x4(%esp)
  800894:	8b 45 08             	mov    0x8(%ebp),%eax
  800897:	89 04 24             	mov    %eax,(%esp)
  80089a:	e8 82 ff ff ff       	call   800821 <vsnprintf>
	va_end(ap);

	return rc;
}
  80089f:	c9                   	leave  
  8008a0:	c3                   	ret    
  8008a1:	66 90                	xchg   %ax,%ax
  8008a3:	66 90                	xchg   %ax,%ax
  8008a5:	66 90                	xchg   %ax,%ax
  8008a7:	66 90                	xchg   %ax,%ax
  8008a9:	66 90                	xchg   %ax,%ax
  8008ab:	66 90                	xchg   %ax,%ax
  8008ad:	66 90                	xchg   %ax,%ax
  8008af:	90                   	nop

008008b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b6:	80 3a 00             	cmpb   $0x0,(%edx)
  8008b9:	74 10                	je     8008cb <strlen+0x1b>
  8008bb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008c0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c7:	75 f7                	jne    8008c0 <strlen+0x10>
  8008c9:	eb 05                	jmp    8008d0 <strlen+0x20>
  8008cb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	53                   	push   %ebx
  8008d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008dc:	85 c9                	test   %ecx,%ecx
  8008de:	74 1c                	je     8008fc <strnlen+0x2a>
  8008e0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008e3:	74 1e                	je     800903 <strnlen+0x31>
  8008e5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8008ea:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ec:	39 ca                	cmp    %ecx,%edx
  8008ee:	74 18                	je     800908 <strnlen+0x36>
  8008f0:	83 c2 01             	add    $0x1,%edx
  8008f3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008f8:	75 f0                	jne    8008ea <strnlen+0x18>
  8008fa:	eb 0c                	jmp    800908 <strnlen+0x36>
  8008fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800901:	eb 05                	jmp    800908 <strnlen+0x36>
  800903:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800908:	5b                   	pop    %ebx
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	53                   	push   %ebx
  80090f:	8b 45 08             	mov    0x8(%ebp),%eax
  800912:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800915:	89 c2                	mov    %eax,%edx
  800917:	0f b6 19             	movzbl (%ecx),%ebx
  80091a:	88 1a                	mov    %bl,(%edx)
  80091c:	83 c2 01             	add    $0x1,%edx
  80091f:	83 c1 01             	add    $0x1,%ecx
  800922:	84 db                	test   %bl,%bl
  800924:	75 f1                	jne    800917 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800926:	5b                   	pop    %ebx
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	53                   	push   %ebx
  80092d:	83 ec 08             	sub    $0x8,%esp
  800930:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800933:	89 1c 24             	mov    %ebx,(%esp)
  800936:	e8 75 ff ff ff       	call   8008b0 <strlen>
	strcpy(dst + len, src);
  80093b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800942:	01 d8                	add    %ebx,%eax
  800944:	89 04 24             	mov    %eax,(%esp)
  800947:	e8 bf ff ff ff       	call   80090b <strcpy>
	return dst;
}
  80094c:	89 d8                	mov    %ebx,%eax
  80094e:	83 c4 08             	add    $0x8,%esp
  800951:	5b                   	pop    %ebx
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	56                   	push   %esi
  800958:	53                   	push   %ebx
  800959:	8b 75 08             	mov    0x8(%ebp),%esi
  80095c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800962:	85 db                	test   %ebx,%ebx
  800964:	74 16                	je     80097c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800966:	01 f3                	add    %esi,%ebx
  800968:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80096a:	0f b6 02             	movzbl (%edx),%eax
  80096d:	88 01                	mov    %al,(%ecx)
  80096f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800972:	80 3a 01             	cmpb   $0x1,(%edx)
  800975:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800978:	39 d9                	cmp    %ebx,%ecx
  80097a:	75 ee                	jne    80096a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80097c:	89 f0                	mov    %esi,%eax
  80097e:	5b                   	pop    %ebx
  80097f:	5e                   	pop    %esi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	57                   	push   %edi
  800986:	56                   	push   %esi
  800987:	53                   	push   %ebx
  800988:	8b 7d 08             	mov    0x8(%ebp),%edi
  80098b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80098e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800991:	89 f8                	mov    %edi,%eax
  800993:	85 f6                	test   %esi,%esi
  800995:	74 33                	je     8009ca <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800997:	83 fe 01             	cmp    $0x1,%esi
  80099a:	74 25                	je     8009c1 <strlcpy+0x3f>
  80099c:	0f b6 0b             	movzbl (%ebx),%ecx
  80099f:	84 c9                	test   %cl,%cl
  8009a1:	74 22                	je     8009c5 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8009a3:	83 ee 02             	sub    $0x2,%esi
  8009a6:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009ab:	88 08                	mov    %cl,(%eax)
  8009ad:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009b0:	39 f2                	cmp    %esi,%edx
  8009b2:	74 13                	je     8009c7 <strlcpy+0x45>
  8009b4:	83 c2 01             	add    $0x1,%edx
  8009b7:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009bb:	84 c9                	test   %cl,%cl
  8009bd:	75 ec                	jne    8009ab <strlcpy+0x29>
  8009bf:	eb 06                	jmp    8009c7 <strlcpy+0x45>
  8009c1:	89 f8                	mov    %edi,%eax
  8009c3:	eb 02                	jmp    8009c7 <strlcpy+0x45>
  8009c5:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009c7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009ca:	29 f8                	sub    %edi,%eax
}
  8009cc:	5b                   	pop    %ebx
  8009cd:	5e                   	pop    %esi
  8009ce:	5f                   	pop    %edi
  8009cf:	5d                   	pop    %ebp
  8009d0:	c3                   	ret    

008009d1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009da:	0f b6 01             	movzbl (%ecx),%eax
  8009dd:	84 c0                	test   %al,%al
  8009df:	74 15                	je     8009f6 <strcmp+0x25>
  8009e1:	3a 02                	cmp    (%edx),%al
  8009e3:	75 11                	jne    8009f6 <strcmp+0x25>
		p++, q++;
  8009e5:	83 c1 01             	add    $0x1,%ecx
  8009e8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009eb:	0f b6 01             	movzbl (%ecx),%eax
  8009ee:	84 c0                	test   %al,%al
  8009f0:	74 04                	je     8009f6 <strcmp+0x25>
  8009f2:	3a 02                	cmp    (%edx),%al
  8009f4:	74 ef                	je     8009e5 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f6:	0f b6 c0             	movzbl %al,%eax
  8009f9:	0f b6 12             	movzbl (%edx),%edx
  8009fc:	29 d0                	sub    %edx,%eax
}
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	56                   	push   %esi
  800a04:	53                   	push   %ebx
  800a05:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a08:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800a0e:	85 f6                	test   %esi,%esi
  800a10:	74 29                	je     800a3b <strncmp+0x3b>
  800a12:	0f b6 03             	movzbl (%ebx),%eax
  800a15:	84 c0                	test   %al,%al
  800a17:	74 30                	je     800a49 <strncmp+0x49>
  800a19:	3a 02                	cmp    (%edx),%al
  800a1b:	75 2c                	jne    800a49 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  800a1d:	8d 43 01             	lea    0x1(%ebx),%eax
  800a20:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800a22:	89 c3                	mov    %eax,%ebx
  800a24:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a27:	39 f0                	cmp    %esi,%eax
  800a29:	74 17                	je     800a42 <strncmp+0x42>
  800a2b:	0f b6 08             	movzbl (%eax),%ecx
  800a2e:	84 c9                	test   %cl,%cl
  800a30:	74 17                	je     800a49 <strncmp+0x49>
  800a32:	83 c0 01             	add    $0x1,%eax
  800a35:	3a 0a                	cmp    (%edx),%cl
  800a37:	74 e9                	je     800a22 <strncmp+0x22>
  800a39:	eb 0e                	jmp    800a49 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a40:	eb 0f                	jmp    800a51 <strncmp+0x51>
  800a42:	b8 00 00 00 00       	mov    $0x0,%eax
  800a47:	eb 08                	jmp    800a51 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a49:	0f b6 03             	movzbl (%ebx),%eax
  800a4c:	0f b6 12             	movzbl (%edx),%edx
  800a4f:	29 d0                	sub    %edx,%eax
}
  800a51:	5b                   	pop    %ebx
  800a52:	5e                   	pop    %esi
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	53                   	push   %ebx
  800a59:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a5f:	0f b6 18             	movzbl (%eax),%ebx
  800a62:	84 db                	test   %bl,%bl
  800a64:	74 1d                	je     800a83 <strchr+0x2e>
  800a66:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a68:	38 d3                	cmp    %dl,%bl
  800a6a:	75 06                	jne    800a72 <strchr+0x1d>
  800a6c:	eb 1a                	jmp    800a88 <strchr+0x33>
  800a6e:	38 ca                	cmp    %cl,%dl
  800a70:	74 16                	je     800a88 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a72:	83 c0 01             	add    $0x1,%eax
  800a75:	0f b6 10             	movzbl (%eax),%edx
  800a78:	84 d2                	test   %dl,%dl
  800a7a:	75 f2                	jne    800a6e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800a7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a81:	eb 05                	jmp    800a88 <strchr+0x33>
  800a83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a88:	5b                   	pop    %ebx
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	53                   	push   %ebx
  800a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a92:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a95:	0f b6 18             	movzbl (%eax),%ebx
  800a98:	84 db                	test   %bl,%bl
  800a9a:	74 16                	je     800ab2 <strfind+0x27>
  800a9c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a9e:	38 d3                	cmp    %dl,%bl
  800aa0:	75 06                	jne    800aa8 <strfind+0x1d>
  800aa2:	eb 0e                	jmp    800ab2 <strfind+0x27>
  800aa4:	38 ca                	cmp    %cl,%dl
  800aa6:	74 0a                	je     800ab2 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aa8:	83 c0 01             	add    $0x1,%eax
  800aab:	0f b6 10             	movzbl (%eax),%edx
  800aae:	84 d2                	test   %dl,%dl
  800ab0:	75 f2                	jne    800aa4 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800ab2:	5b                   	pop    %ebx
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    

00800ab5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	83 ec 0c             	sub    $0xc,%esp
  800abb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800abe:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ac1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ac4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ac7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aca:	85 c9                	test   %ecx,%ecx
  800acc:	74 36                	je     800b04 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ace:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ad4:	75 28                	jne    800afe <memset+0x49>
  800ad6:	f6 c1 03             	test   $0x3,%cl
  800ad9:	75 23                	jne    800afe <memset+0x49>
		c &= 0xFF;
  800adb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800adf:	89 d3                	mov    %edx,%ebx
  800ae1:	c1 e3 08             	shl    $0x8,%ebx
  800ae4:	89 d6                	mov    %edx,%esi
  800ae6:	c1 e6 18             	shl    $0x18,%esi
  800ae9:	89 d0                	mov    %edx,%eax
  800aeb:	c1 e0 10             	shl    $0x10,%eax
  800aee:	09 f0                	or     %esi,%eax
  800af0:	09 c2                	or     %eax,%edx
  800af2:	89 d0                	mov    %edx,%eax
  800af4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800af6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800af9:	fc                   	cld    
  800afa:	f3 ab                	rep stos %eax,%es:(%edi)
  800afc:	eb 06                	jmp    800b04 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800afe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b01:	fc                   	cld    
  800b02:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b04:	89 f8                	mov    %edi,%eax
  800b06:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b09:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b0c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b0f:	89 ec                	mov    %ebp,%esp
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	83 ec 08             	sub    $0x8,%esp
  800b19:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b1c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b22:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b25:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b28:	39 c6                	cmp    %eax,%esi
  800b2a:	73 36                	jae    800b62 <memmove+0x4f>
  800b2c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b2f:	39 d0                	cmp    %edx,%eax
  800b31:	73 2f                	jae    800b62 <memmove+0x4f>
		s += n;
		d += n;
  800b33:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b36:	f6 c2 03             	test   $0x3,%dl
  800b39:	75 1b                	jne    800b56 <memmove+0x43>
  800b3b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b41:	75 13                	jne    800b56 <memmove+0x43>
  800b43:	f6 c1 03             	test   $0x3,%cl
  800b46:	75 0e                	jne    800b56 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b48:	83 ef 04             	sub    $0x4,%edi
  800b4b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b4e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b51:	fd                   	std    
  800b52:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b54:	eb 09                	jmp    800b5f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b56:	83 ef 01             	sub    $0x1,%edi
  800b59:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b5c:	fd                   	std    
  800b5d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b5f:	fc                   	cld    
  800b60:	eb 20                	jmp    800b82 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b62:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b68:	75 13                	jne    800b7d <memmove+0x6a>
  800b6a:	a8 03                	test   $0x3,%al
  800b6c:	75 0f                	jne    800b7d <memmove+0x6a>
  800b6e:	f6 c1 03             	test   $0x3,%cl
  800b71:	75 0a                	jne    800b7d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b73:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b76:	89 c7                	mov    %eax,%edi
  800b78:	fc                   	cld    
  800b79:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b7b:	eb 05                	jmp    800b82 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b7d:	89 c7                	mov    %eax,%edi
  800b7f:	fc                   	cld    
  800b80:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b82:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b85:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b88:	89 ec                	mov    %ebp,%esp
  800b8a:	5d                   	pop    %ebp
  800b8b:	c3                   	ret    

00800b8c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b92:	8b 45 10             	mov    0x10(%ebp),%eax
  800b95:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ba0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba3:	89 04 24             	mov    %eax,(%esp)
  800ba6:	e8 68 ff ff ff       	call   800b13 <memmove>
}
  800bab:	c9                   	leave  
  800bac:	c3                   	ret    

00800bad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	57                   	push   %edi
  800bb1:	56                   	push   %esi
  800bb2:	53                   	push   %ebx
  800bb3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bb6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb9:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bbc:	8d 78 ff             	lea    -0x1(%eax),%edi
  800bbf:	85 c0                	test   %eax,%eax
  800bc1:	74 36                	je     800bf9 <memcmp+0x4c>
		if (*s1 != *s2)
  800bc3:	0f b6 03             	movzbl (%ebx),%eax
  800bc6:	0f b6 0e             	movzbl (%esi),%ecx
  800bc9:	38 c8                	cmp    %cl,%al
  800bcb:	75 17                	jne    800be4 <memcmp+0x37>
  800bcd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd2:	eb 1a                	jmp    800bee <memcmp+0x41>
  800bd4:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800bd9:	83 c2 01             	add    $0x1,%edx
  800bdc:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800be0:	38 c8                	cmp    %cl,%al
  800be2:	74 0a                	je     800bee <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800be4:	0f b6 c0             	movzbl %al,%eax
  800be7:	0f b6 c9             	movzbl %cl,%ecx
  800bea:	29 c8                	sub    %ecx,%eax
  800bec:	eb 10                	jmp    800bfe <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bee:	39 fa                	cmp    %edi,%edx
  800bf0:	75 e2                	jne    800bd4 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bf2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf7:	eb 05                	jmp    800bfe <memcmp+0x51>
  800bf9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	53                   	push   %ebx
  800c07:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800c0d:	89 c2                	mov    %eax,%edx
  800c0f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c12:	39 d0                	cmp    %edx,%eax
  800c14:	73 13                	jae    800c29 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c16:	89 d9                	mov    %ebx,%ecx
  800c18:	38 18                	cmp    %bl,(%eax)
  800c1a:	75 06                	jne    800c22 <memfind+0x1f>
  800c1c:	eb 0b                	jmp    800c29 <memfind+0x26>
  800c1e:	38 08                	cmp    %cl,(%eax)
  800c20:	74 07                	je     800c29 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c22:	83 c0 01             	add    $0x1,%eax
  800c25:	39 d0                	cmp    %edx,%eax
  800c27:	75 f5                	jne    800c1e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c29:	5b                   	pop    %ebx
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	57                   	push   %edi
  800c30:	56                   	push   %esi
  800c31:	53                   	push   %ebx
  800c32:	83 ec 04             	sub    $0x4,%esp
  800c35:	8b 55 08             	mov    0x8(%ebp),%edx
  800c38:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c3b:	0f b6 02             	movzbl (%edx),%eax
  800c3e:	3c 09                	cmp    $0x9,%al
  800c40:	74 04                	je     800c46 <strtol+0x1a>
  800c42:	3c 20                	cmp    $0x20,%al
  800c44:	75 0e                	jne    800c54 <strtol+0x28>
		s++;
  800c46:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c49:	0f b6 02             	movzbl (%edx),%eax
  800c4c:	3c 09                	cmp    $0x9,%al
  800c4e:	74 f6                	je     800c46 <strtol+0x1a>
  800c50:	3c 20                	cmp    $0x20,%al
  800c52:	74 f2                	je     800c46 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c54:	3c 2b                	cmp    $0x2b,%al
  800c56:	75 0a                	jne    800c62 <strtol+0x36>
		s++;
  800c58:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c5b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c60:	eb 10                	jmp    800c72 <strtol+0x46>
  800c62:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c67:	3c 2d                	cmp    $0x2d,%al
  800c69:	75 07                	jne    800c72 <strtol+0x46>
		s++, neg = 1;
  800c6b:	83 c2 01             	add    $0x1,%edx
  800c6e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c72:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c78:	75 15                	jne    800c8f <strtol+0x63>
  800c7a:	80 3a 30             	cmpb   $0x30,(%edx)
  800c7d:	75 10                	jne    800c8f <strtol+0x63>
  800c7f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c83:	75 0a                	jne    800c8f <strtol+0x63>
		s += 2, base = 16;
  800c85:	83 c2 02             	add    $0x2,%edx
  800c88:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c8d:	eb 10                	jmp    800c9f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800c8f:	85 db                	test   %ebx,%ebx
  800c91:	75 0c                	jne    800c9f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c93:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c95:	80 3a 30             	cmpb   $0x30,(%edx)
  800c98:	75 05                	jne    800c9f <strtol+0x73>
		s++, base = 8;
  800c9a:	83 c2 01             	add    $0x1,%edx
  800c9d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca4:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ca7:	0f b6 0a             	movzbl (%edx),%ecx
  800caa:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800cad:	89 f3                	mov    %esi,%ebx
  800caf:	80 fb 09             	cmp    $0x9,%bl
  800cb2:	77 08                	ja     800cbc <strtol+0x90>
			dig = *s - '0';
  800cb4:	0f be c9             	movsbl %cl,%ecx
  800cb7:	83 e9 30             	sub    $0x30,%ecx
  800cba:	eb 22                	jmp    800cde <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800cbc:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800cbf:	89 f3                	mov    %esi,%ebx
  800cc1:	80 fb 19             	cmp    $0x19,%bl
  800cc4:	77 08                	ja     800cce <strtol+0xa2>
			dig = *s - 'a' + 10;
  800cc6:	0f be c9             	movsbl %cl,%ecx
  800cc9:	83 e9 57             	sub    $0x57,%ecx
  800ccc:	eb 10                	jmp    800cde <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800cce:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800cd1:	89 f3                	mov    %esi,%ebx
  800cd3:	80 fb 19             	cmp    $0x19,%bl
  800cd6:	77 16                	ja     800cee <strtol+0xc2>
			dig = *s - 'A' + 10;
  800cd8:	0f be c9             	movsbl %cl,%ecx
  800cdb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cde:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800ce1:	7d 0f                	jge    800cf2 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800ce3:	83 c2 01             	add    $0x1,%edx
  800ce6:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800cea:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800cec:	eb b9                	jmp    800ca7 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800cee:	89 c1                	mov    %eax,%ecx
  800cf0:	eb 02                	jmp    800cf4 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cf2:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800cf4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cf8:	74 05                	je     800cff <strtol+0xd3>
		*endptr = (char *) s;
  800cfa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cfd:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800cff:	89 ca                	mov    %ecx,%edx
  800d01:	f7 da                	neg    %edx
  800d03:	85 ff                	test   %edi,%edi
  800d05:	0f 45 c2             	cmovne %edx,%eax
}
  800d08:	83 c4 04             	add    $0x4,%esp
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	83 ec 0c             	sub    $0xc,%esp
  800d16:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d19:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d1c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d27:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2a:	89 c3                	mov    %eax,%ebx
  800d2c:	89 c7                	mov    %eax,%edi
  800d2e:	89 c6                	mov    %eax,%esi
  800d30:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d32:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d35:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d38:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d3b:	89 ec                	mov    %ebp,%esp
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    

00800d3f <sys_cgetc>:

int
sys_cgetc(void)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	83 ec 0c             	sub    $0xc,%esp
  800d45:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d48:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d4b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d53:	b8 01 00 00 00       	mov    $0x1,%eax
  800d58:	89 d1                	mov    %edx,%ecx
  800d5a:	89 d3                	mov    %edx,%ebx
  800d5c:	89 d7                	mov    %edx,%edi
  800d5e:	89 d6                	mov    %edx,%esi
  800d60:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d62:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d65:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d68:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d6b:	89 ec                	mov    %ebp,%esp
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    

00800d6f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	83 ec 38             	sub    $0x38,%esp
  800d75:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d78:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d7b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d83:	b8 03 00 00 00       	mov    $0x3,%eax
  800d88:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8b:	89 cb                	mov    %ecx,%ebx
  800d8d:	89 cf                	mov    %ecx,%edi
  800d8f:	89 ce                	mov    %ecx,%esi
  800d91:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d93:	85 c0                	test   %eax,%eax
  800d95:	7e 28                	jle    800dbf <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d97:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d9b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800da2:	00 
  800da3:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  800daa:	00 
  800dab:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db2:	00 
  800db3:	c7 04 24 61 1a 80 00 	movl   $0x801a61,(%esp)
  800dba:	e8 d9 f3 ff ff       	call   800198 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dbf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dc2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dc5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dc8:	89 ec                	mov    %ebp,%esp
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	83 ec 0c             	sub    $0xc,%esp
  800dd2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dd5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dd8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddb:	ba 00 00 00 00       	mov    $0x0,%edx
  800de0:	b8 02 00 00 00       	mov    $0x2,%eax
  800de5:	89 d1                	mov    %edx,%ecx
  800de7:	89 d3                	mov    %edx,%ebx
  800de9:	89 d7                	mov    %edx,%edi
  800deb:	89 d6                	mov    %edx,%esi
  800ded:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800def:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800df2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800df5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800df8:	89 ec                	mov    %ebp,%esp
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <sys_yield>:

void
sys_yield(void)
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
  800e10:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e15:	89 d1                	mov    %edx,%ecx
  800e17:	89 d3                	mov    %edx,%ebx
  800e19:	89 d7                	mov    %edx,%edi
  800e1b:	89 d6                	mov    %edx,%esi
  800e1d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e1f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e22:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e25:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e28:	89 ec                	mov    %ebp,%esp
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	83 ec 38             	sub    $0x38,%esp
  800e32:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e35:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e38:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3b:	be 00 00 00 00       	mov    $0x0,%esi
  800e40:	b8 04 00 00 00       	mov    $0x4,%eax
  800e45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e48:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e4e:	89 f7                	mov    %esi,%edi
  800e50:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e52:	85 c0                	test   %eax,%eax
  800e54:	7e 28                	jle    800e7e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e56:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e5a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e61:	00 
  800e62:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  800e69:	00 
  800e6a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e71:	00 
  800e72:	c7 04 24 61 1a 80 00 	movl   $0x801a61,(%esp)
  800e79:	e8 1a f3 ff ff       	call   800198 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e7e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e81:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e84:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e87:	89 ec                	mov    %ebp,%esp
  800e89:	5d                   	pop    %ebp
  800e8a:	c3                   	ret    

00800e8b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	83 ec 38             	sub    $0x38,%esp
  800e91:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e94:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e97:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ea8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eab:	8b 75 18             	mov    0x18(%ebp),%esi
  800eae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eb0:	85 c0                	test   %eax,%eax
  800eb2:	7e 28                	jle    800edc <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ebf:	00 
  800ec0:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  800ec7:	00 
  800ec8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ecf:	00 
  800ed0:	c7 04 24 61 1a 80 00 	movl   $0x801a61,(%esp)
  800ed7:	e8 bc f2 ff ff       	call   800198 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800edc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800edf:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ee2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ee5:	89 ec                	mov    %ebp,%esp
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    

00800ee9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	83 ec 38             	sub    $0x38,%esp
  800eef:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ef2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ef5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efd:	b8 06 00 00 00       	mov    $0x6,%eax
  800f02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f05:	8b 55 08             	mov    0x8(%ebp),%edx
  800f08:	89 df                	mov    %ebx,%edi
  800f0a:	89 de                	mov    %ebx,%esi
  800f0c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f0e:	85 c0                	test   %eax,%eax
  800f10:	7e 28                	jle    800f3a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f12:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f16:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f1d:	00 
  800f1e:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  800f25:	00 
  800f26:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f2d:	00 
  800f2e:	c7 04 24 61 1a 80 00 	movl   $0x801a61,(%esp)
  800f35:	e8 5e f2 ff ff       	call   800198 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f3a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f3d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f40:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f43:	89 ec                	mov    %ebp,%esp
  800f45:	5d                   	pop    %ebp
  800f46:	c3                   	ret    

00800f47 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	83 ec 38             	sub    $0x38,%esp
  800f4d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f50:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f53:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f56:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f5b:	b8 08 00 00 00       	mov    $0x8,%eax
  800f60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f63:	8b 55 08             	mov    0x8(%ebp),%edx
  800f66:	89 df                	mov    %ebx,%edi
  800f68:	89 de                	mov    %ebx,%esi
  800f6a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	7e 28                	jle    800f98 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f70:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f74:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f7b:	00 
  800f7c:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  800f83:	00 
  800f84:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f8b:	00 
  800f8c:	c7 04 24 61 1a 80 00 	movl   $0x801a61,(%esp)
  800f93:	e8 00 f2 ff ff       	call   800198 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f98:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f9b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f9e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fa1:	89 ec                	mov    %ebp,%esp
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    

00800fa5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fa5:	55                   	push   %ebp
  800fa6:	89 e5                	mov    %esp,%ebp
  800fa8:	83 ec 38             	sub    $0x38,%esp
  800fab:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fae:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fb1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb9:	b8 09 00 00 00       	mov    $0x9,%eax
  800fbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc4:	89 df                	mov    %ebx,%edi
  800fc6:	89 de                	mov    %ebx,%esi
  800fc8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	7e 28                	jle    800ff6 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fce:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800fd9:	00 
  800fda:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  800fe1:	00 
  800fe2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fe9:	00 
  800fea:	c7 04 24 61 1a 80 00 	movl   $0x801a61,(%esp)
  800ff1:	e8 a2 f1 ff ff       	call   800198 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ff6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ff9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ffc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fff:	89 ec                	mov    %ebp,%esp
  801001:	5d                   	pop    %ebp
  801002:	c3                   	ret    

00801003 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801003:	55                   	push   %ebp
  801004:	89 e5                	mov    %esp,%ebp
  801006:	83 ec 0c             	sub    $0xc,%esp
  801009:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80100c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80100f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801012:	be 00 00 00 00       	mov    $0x0,%esi
  801017:	b8 0b 00 00 00       	mov    $0xb,%eax
  80101c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80101f:	8b 55 08             	mov    0x8(%ebp),%edx
  801022:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801025:	8b 7d 14             	mov    0x14(%ebp),%edi
  801028:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80102a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80102d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801030:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801033:	89 ec                	mov    %ebp,%esp
  801035:	5d                   	pop    %ebp
  801036:	c3                   	ret    

00801037 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	83 ec 38             	sub    $0x38,%esp
  80103d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801040:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801043:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801046:	b9 00 00 00 00       	mov    $0x0,%ecx
  80104b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801050:	8b 55 08             	mov    0x8(%ebp),%edx
  801053:	89 cb                	mov    %ecx,%ebx
  801055:	89 cf                	mov    %ecx,%edi
  801057:	89 ce                	mov    %ecx,%esi
  801059:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80105b:	85 c0                	test   %eax,%eax
  80105d:	7e 28                	jle    801087 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80105f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801063:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80106a:	00 
  80106b:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  801072:	00 
  801073:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80107a:	00 
  80107b:	c7 04 24 61 1a 80 00 	movl   $0x801a61,(%esp)
  801082:	e8 11 f1 ff ff       	call   800198 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801087:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80108a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80108d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801090:	89 ec                	mov    %ebp,%esp
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    

00801094 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	53                   	push   %ebx
  801098:	83 ec 24             	sub    $0x24,%esp
  80109b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
  80109e:	8b 50 04             	mov    0x4(%eax),%edx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	addr = (void*)(ROUNDDOWN((uint32_t)addr, PGSIZE)); 
  8010a1:	8b 18                	mov    (%eax),%ebx
  8010a3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	int pte = uvpt[PGNUM((uint32_t)addr)];
  8010a9:	89 d8                	mov    %ebx,%eax
  8010ab:	c1 e8 0c             	shr    $0xc,%eax
  8010ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!((pte & PTE_COW) && (err & FEC_WR))) {
  8010b5:	f6 c4 08             	test   $0x8,%ah
  8010b8:	74 05                	je     8010bf <pgfault+0x2b>
  8010ba:	f6 c2 02             	test   $0x2,%dl
  8010bd:	75 30                	jne    8010ef <pgfault+0x5b>
		cprintf("pte: %x, error: %x\n", pte, err);
  8010bf:	89 54 24 08          	mov    %edx,0x8(%esp)
  8010c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c7:	c7 04 24 6f 1a 80 00 	movl   $0x801a6f,(%esp)
  8010ce:	e8 c0 f1 ff ff       	call   800293 <cprintf>
		panic("Something wrong in lib/fork.c:pgfault\n");
  8010d3:	c7 44 24 08 c0 1a 80 	movl   $0x801ac0,0x8(%esp)
  8010da:	00 
  8010db:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8010e2:	00 
  8010e3:	c7 04 24 83 1a 80 00 	movl   $0x801a83,(%esp)
  8010ea:	e8 a9 f0 ff ff       	call   800198 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	
	int ret;
	ret = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
  8010ef:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010f6:	00 
  8010f7:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010fe:	00 
  8010ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801106:	e8 21 fd ff ff       	call   800e2c <sys_page_alloc>
	if (ret < 0) {
  80110b:	85 c0                	test   %eax,%eax
  80110d:	79 20                	jns    80112f <pgfault+0x9b>
		panic("fork.c/pgfault page allocation %e\n", ret);
  80110f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801113:	c7 44 24 08 e8 1a 80 	movl   $0x801ae8,0x8(%esp)
  80111a:	00 
  80111b:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  801122:	00 
  801123:	c7 04 24 83 1a 80 00 	movl   $0x801a83,(%esp)
  80112a:	e8 69 f0 ff ff       	call   800198 <_panic>
	}
	
	memmove(PFTEMP, addr, PGSIZE);
  80112f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801136:	00 
  801137:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80113b:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801142:	e8 cc f9 ff ff       	call   800b13 <memmove>

	ret = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_U | PTE_P | PTE_W);
  801147:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80114e:	00 
  80114f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801153:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80115a:	00 
  80115b:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801162:	00 
  801163:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80116a:	e8 1c fd ff ff       	call   800e8b <sys_page_map>
	if (ret < 0) {
  80116f:	85 c0                	test   %eax,%eax
  801171:	79 20                	jns    801193 <pgfault+0xff>
		panic("fork.c/pgfault page map %e\n", ret);
  801173:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801177:	c7 44 24 08 8e 1a 80 	movl   $0x801a8e,0x8(%esp)
  80117e:	00 
  80117f:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  801186:	00 
  801187:	c7 04 24 83 1a 80 00 	movl   $0x801a83,(%esp)
  80118e:	e8 05 f0 ff ff       	call   800198 <_panic>
	}

	// panic("pgfault not implemented");
}
  801193:	83 c4 24             	add    $0x24,%esp
  801196:	5b                   	pop    %ebx
  801197:	5d                   	pop    %ebp
  801198:	c3                   	ret    

00801199 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801199:	55                   	push   %ebp
  80119a:	89 e5                	mov    %esp,%ebp
  80119c:	57                   	push   %edi
  80119d:	56                   	push   %esi
  80119e:	53                   	push   %ebx
  80119f:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int ret = 0;
	extern unsigned char end[];
	void (*handler)(struct UTrapframe *utf) = pgfault;
	set_pgfault_handler(handler);
  8011a2:	c7 04 24 94 10 80 00 	movl   $0x801094,(%esp)
  8011a9:	e8 2a 02 00 00       	call   8013d8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8011ae:	be 07 00 00 00       	mov    $0x7,%esi
  8011b3:	89 f0                	mov    %esi,%eax
  8011b5:	cd 30                	int    $0x30
  8011b7:	89 c6                	mov    %eax,%esi
  8011b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	
	envid_t new_env = sys_exofork();
	if (new_env < 0) {
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	0f 88 e7 01 00 00    	js     8013ab <fork+0x212>
		return new_env;
	}

	if (new_env == 0) {
  8011c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	75 1c                	jne    8011e9 <fork+0x50>
		thisenv = &envs[ENVX(sys_getenvid())];
  8011cd:	e8 fa fb ff ff       	call   800dcc <sys_getenvid>
  8011d2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011d7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011da:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011df:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  8011e4:	e9 c2 01 00 00       	jmp    8013ab <fork+0x212>
	}
	uint32_t va;

	for (va =  0; va < UTOP - PGSIZE; va += PGSIZE) {
		if((uvpd[PDX(va)] & PTE_P) && (uvpd[PDX(va)] & PTE_U)) {
  8011e9:	89 d8                	mov    %ebx,%eax
  8011eb:	c1 e8 16             	shr    $0x16,%eax
  8011ee:	8b 14 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%edx
  8011f5:	f6 c2 01             	test   $0x1,%dl
  8011f8:	0f 84 bf 00 00 00    	je     8012bd <fork+0x124>
  8011fe:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801205:	a8 04                	test   $0x4,%al
  801207:	0f 84 b0 00 00 00    	je     8012bd <fork+0x124>
			if ((uvpt[PGNUM(va)] & PTE_P) &&
  80120d:	89 d8                	mov    %ebx,%eax
  80120f:	c1 e8 0c             	shr    $0xc,%eax
  801212:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801219:	f6 c2 01             	test   $0x1,%dl
  80121c:	0f 84 9b 00 00 00    	je     8012bd <fork+0x124>
					(uvpt[PGNUM(va)] & PTE_U)) {
  801222:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	}
	uint32_t va;

	for (va =  0; va < UTOP - PGSIZE; va += PGSIZE) {
		if((uvpd[PDX(va)] & PTE_P) && (uvpd[PDX(va)] & PTE_U)) {
			if ((uvpt[PGNUM(va)] & PTE_P) &&
  801229:	a8 04                	test   $0x4,%al
  80122b:	0f 84 8c 00 00 00    	je     8012bd <fork+0x124>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	int flag = 0;
	uint32_t addr = pn * PGSIZE;
  801231:	89 df                	mov    %ebx,%edi
  801233:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	// LAB 4: Your code here.
	r = PTE_U | PTE_P;
	int old_perm = uvpt[PGNUM(addr)];
  801239:	89 f8                	mov    %edi,%eax
  80123b:	c1 e8 0c             	shr    $0xc,%eax
  80123e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if ((old_perm & PTE_W) || (r & PTE_COW)) {
  801245:	a8 02                	test   $0x2,%al
  801247:	0f 85 fe 00 00 00    	jne    80134b <fork+0x1b2>
  80124d:	e9 29 01 00 00       	jmp    80137b <fork+0x1e2>
	}


	int ret = sys_page_map(0, (void*)addr, envid, (void*)addr, r);
	if (ret < 0) {
		panic("fork.c/duppage in page_map %d %e\n", envid, ret);
  801252:	89 44 24 10          	mov    %eax,0x10(%esp)
  801256:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80125a:	c7 44 24 08 0c 1b 80 	movl   $0x801b0c,0x8(%esp)
  801261:	00 
  801262:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  801269:	00 
  80126a:	c7 04 24 83 1a 80 00 	movl   $0x801a83,(%esp)
  801271:	e8 22 ef ff ff       	call   800198 <_panic>
		return ret;
	}

	if (flag) {
		ret = sys_page_map(envid, (void*)addr, 0, (void*)addr, r);
  801276:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80127d:	00 
  80127e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801282:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801289:	00 
  80128a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80128e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801291:	89 04 24             	mov    %eax,(%esp)
  801294:	e8 f2 fb ff ff       	call   800e8b <sys_page_map>
		if (ret < 0) {
  801299:	85 c0                	test   %eax,%eax
  80129b:	79 20                	jns    8012bd <fork+0x124>
			panic("fork.c/duppage in page_map 2 %e\n", ret);
  80129d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012a1:	c7 44 24 08 30 1b 80 	movl   $0x801b30,0x8(%esp)
  8012a8:	00 
  8012a9:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  8012b0:	00 
  8012b1:	c7 04 24 83 1a 80 00 	movl   $0x801a83,(%esp)
  8012b8:	e8 db ee ff ff       	call   800198 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	uint32_t va;

	for (va =  0; va < UTOP - PGSIZE; va += PGSIZE) {
  8012bd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8012c3:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8012c9:	0f 85 1a ff ff ff    	jne    8011e9 <fork+0x50>
				duppage(new_env, (va / PGSIZE));
			}	
		}
	}
	
	ret = sys_page_alloc(new_env, (void*)(UXSTACKTOP - PGSIZE),
  8012cf:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012d6:	00 
  8012d7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012de:	ee 
  8012df:	89 34 24             	mov    %esi,(%esp)
  8012e2:	e8 45 fb ff ff       	call   800e2c <sys_page_alloc>
			  			 PTE_U | PTE_P | PTE_W);
	if (ret < 0) {
  8012e7:	85 c0                	test   %eax,%eax
  8012e9:	79 1c                	jns    801307 <fork+0x16e>
		panic("Not able to allocate exception stack for the child\n");
  8012eb:	c7 44 24 08 54 1b 80 	movl   $0x801b54,0x8(%esp)
  8012f2:	00 
  8012f3:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
  8012fa:	00 
  8012fb:	c7 04 24 83 1a 80 00 	movl   $0x801a83,(%esp)
  801302:	e8 91 ee ff ff       	call   800198 <_panic>
	}

	sys_env_set_pgfault_upcall(new_env, thisenv->env_pgfault_upcall);
  801307:	a1 08 20 80 00       	mov    0x802008,%eax
  80130c:	8b 40 64             	mov    0x64(%eax),%eax
  80130f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801313:	89 34 24             	mov    %esi,(%esp)
  801316:	e8 8a fc ff ff       	call   800fa5 <sys_env_set_pgfault_upcall>
	
	ret = sys_env_set_status(new_env, ENV_RUNNABLE);
  80131b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801322:	00 
  801323:	89 34 24             	mov    %esi,(%esp)
  801326:	e8 1c fc ff ff       	call   800f47 <sys_env_set_status>
	if (ret < 0) {
  80132b:	85 c0                	test   %eax,%eax
  80132d:	79 7c                	jns    8013ab <fork+0x212>
		panic("Not able to make child runnable.\n");
  80132f:	c7 44 24 08 88 1b 80 	movl   $0x801b88,0x8(%esp)
  801336:	00 
  801337:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  80133e:	00 
  80133f:	c7 04 24 83 1a 80 00 	movl   $0x801a83,(%esp)
  801346:	e8 4d ee ff ff       	call   800198 <_panic>
		r = r | PTE_COW;
		flag = 1;
	}


	int ret = sys_page_map(0, (void*)addr, envid, (void*)addr, r);
  80134b:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801352:	00 
  801353:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801357:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80135a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80135e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801362:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801369:	e8 1d fb ff ff       	call   800e8b <sys_page_map>
	if (ret < 0) {
  80136e:	85 c0                	test   %eax,%eax
  801370:	0f 89 00 ff ff ff    	jns    801276 <fork+0xdd>
  801376:	e9 d7 fe ff ff       	jmp    801252 <fork+0xb9>
		r = r | PTE_COW;
		flag = 1;
	}


	int ret = sys_page_map(0, (void*)addr, envid, (void*)addr, r);
  80137b:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801382:	00 
  801383:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801387:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80138a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80138e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801392:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801399:	e8 ed fa ff ff       	call   800e8b <sys_page_map>
	if (ret < 0) {
  80139e:	85 c0                	test   %eax,%eax
  8013a0:	0f 89 17 ff ff ff    	jns    8012bd <fork+0x124>
  8013a6:	e9 a7 fe ff ff       	jmp    801252 <fork+0xb9>
		panic("Not able to make child runnable.\n");
	}

	return new_env;
	// panic("fork not implemented");
}
  8013ab:	89 f0                	mov    %esi,%eax
  8013ad:	83 c4 3c             	add    $0x3c,%esp
  8013b0:	5b                   	pop    %ebx
  8013b1:	5e                   	pop    %esi
  8013b2:	5f                   	pop    %edi
  8013b3:	5d                   	pop    %ebp
  8013b4:	c3                   	ret    

008013b5 <sfork>:

// Challenge!
int
sfork(void)
{
  8013b5:	55                   	push   %ebp
  8013b6:	89 e5                	mov    %esp,%ebp
  8013b8:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8013bb:	c7 44 24 08 aa 1a 80 	movl   $0x801aaa,0x8(%esp)
  8013c2:	00 
  8013c3:	c7 44 24 04 a8 00 00 	movl   $0xa8,0x4(%esp)
  8013ca:	00 
  8013cb:	c7 04 24 83 1a 80 00 	movl   $0x801a83,(%esp)
  8013d2:	e8 c1 ed ff ff       	call   800198 <_panic>
  8013d7:	90                   	nop

008013d8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8013de:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  8013e5:	75 60                	jne    801447 <set_pgfault_handler+0x6f>
		// First time through!
		// LAB 4: Your code here.
		int ret =
  8013e7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013ee:	00 
  8013ef:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013f6:	ee 
  8013f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013fe:	e8 29 fa ff ff       	call   800e2c <sys_page_alloc>
			sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE),
							PTE_U | PTE_P | PTE_W);
		if (ret < 0) {
  801403:	85 c0                	test   %eax,%eax
  801405:	79 2c                	jns    801433 <set_pgfault_handler+0x5b>
			cprintf("%e\n", ret);
  801407:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140b:	c7 04 24 a6 1a 80 00 	movl   $0x801aa6,(%esp)
  801412:	e8 7c ee ff ff       	call   800293 <cprintf>
			panic("Something wrong with allocation of user exception"
  801417:	c7 44 24 08 b8 1b 80 	movl   $0x801bb8,0x8(%esp)
  80141e:	00 
  80141f:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  801426:	00 
  801427:	c7 04 24 aa 1b 80 00 	movl   $0x801baa,(%esp)
  80142e:	e8 65 ed ff ff       	call   800198 <_panic>
				  "stack\n");
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801433:	c7 44 24 04 54 14 80 	movl   $0x801454,0x4(%esp)
  80143a:	00 
  80143b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801442:	e8 5e fb ff ff       	call   800fa5 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801447:	8b 45 08             	mov    0x8(%ebp),%eax
  80144a:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  80144f:	c9                   	leave  
  801450:	c3                   	ret    
  801451:	66 90                	xchg   %ax,%ax
  801453:	90                   	nop

00801454 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801454:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801455:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  80145a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80145c:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	popl %eax
  80145f:	58                   	pop    %eax
	popl %eax
  801460:	58                   	pop    %eax
	
	addl $32, %esp
  801461:	83 c4 20             	add    $0x20,%esp
	movl (%esp), %eax
  801464:	8b 04 24             	mov    (%esp),%eax
	addl $8, %esp
  801467:	83 c4 08             	add    $0x8,%esp
	movl (%esp), %ebx
  80146a:	8b 1c 24             	mov    (%esp),%ebx
	subl $4, %ebx
  80146d:	83 eb 04             	sub    $0x4,%ebx

	movl %ebx, (%esp)
  801470:	89 1c 24             	mov    %ebx,(%esp)

	movl %eax, (%ebx)
  801473:	89 03                	mov    %eax,(%ebx)
	subl $40, %esp
  801475:	83 ec 28             	sub    $0x28,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	popl %edi
  801478:	5f                   	pop    %edi
	popl %esi
  801479:	5e                   	pop    %esi
	popl %ebp
  80147a:	5d                   	pop    %ebp
	addl $4, %esp
  80147b:	83 c4 04             	add    $0x4,%esp
	popl %ebx
  80147e:	5b                   	pop    %ebx
	popl %edx
  80147f:	5a                   	pop    %edx
	popl %ecx
  801480:	59                   	pop    %ecx
	popl %eax
  801481:	58                   	pop    %eax
	addl $4, %esp
  801482:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	popfl
  801485:	9d                   	popf   
	
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	movl (%esp), %esp
  801486:	8b 24 24             	mov    (%esp),%esp
	
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801489:	c3                   	ret    
  80148a:	66 90                	xchg   %ax,%ax
  80148c:	66 90                	xchg   %ax,%ax
  80148e:	66 90                	xchg   %ax,%ax

00801490 <__udivdi3>:
  801490:	83 ec 1c             	sub    $0x1c,%esp
  801493:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801497:	89 7c 24 14          	mov    %edi,0x14(%esp)
  80149b:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80149f:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8014a3:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8014a7:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  8014ab:	85 c0                	test   %eax,%eax
  8014ad:	89 74 24 10          	mov    %esi,0x10(%esp)
  8014b1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8014b5:	89 ea                	mov    %ebp,%edx
  8014b7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014bb:	75 33                	jne    8014f0 <__udivdi3+0x60>
  8014bd:	39 e9                	cmp    %ebp,%ecx
  8014bf:	77 6f                	ja     801530 <__udivdi3+0xa0>
  8014c1:	85 c9                	test   %ecx,%ecx
  8014c3:	89 ce                	mov    %ecx,%esi
  8014c5:	75 0b                	jne    8014d2 <__udivdi3+0x42>
  8014c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8014cc:	31 d2                	xor    %edx,%edx
  8014ce:	f7 f1                	div    %ecx
  8014d0:	89 c6                	mov    %eax,%esi
  8014d2:	31 d2                	xor    %edx,%edx
  8014d4:	89 e8                	mov    %ebp,%eax
  8014d6:	f7 f6                	div    %esi
  8014d8:	89 c5                	mov    %eax,%ebp
  8014da:	89 f8                	mov    %edi,%eax
  8014dc:	f7 f6                	div    %esi
  8014de:	89 ea                	mov    %ebp,%edx
  8014e0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8014e4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8014e8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8014ec:	83 c4 1c             	add    $0x1c,%esp
  8014ef:	c3                   	ret    
  8014f0:	39 e8                	cmp    %ebp,%eax
  8014f2:	77 24                	ja     801518 <__udivdi3+0x88>
  8014f4:	0f bd c8             	bsr    %eax,%ecx
  8014f7:	83 f1 1f             	xor    $0x1f,%ecx
  8014fa:	89 0c 24             	mov    %ecx,(%esp)
  8014fd:	75 49                	jne    801548 <__udivdi3+0xb8>
  8014ff:	8b 74 24 08          	mov    0x8(%esp),%esi
  801503:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801507:	0f 86 ab 00 00 00    	jbe    8015b8 <__udivdi3+0x128>
  80150d:	39 e8                	cmp    %ebp,%eax
  80150f:	0f 82 a3 00 00 00    	jb     8015b8 <__udivdi3+0x128>
  801515:	8d 76 00             	lea    0x0(%esi),%esi
  801518:	31 d2                	xor    %edx,%edx
  80151a:	31 c0                	xor    %eax,%eax
  80151c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801520:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801524:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801528:	83 c4 1c             	add    $0x1c,%esp
  80152b:	c3                   	ret    
  80152c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801530:	89 f8                	mov    %edi,%eax
  801532:	f7 f1                	div    %ecx
  801534:	31 d2                	xor    %edx,%edx
  801536:	8b 74 24 10          	mov    0x10(%esp),%esi
  80153a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80153e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801542:	83 c4 1c             	add    $0x1c,%esp
  801545:	c3                   	ret    
  801546:	66 90                	xchg   %ax,%ax
  801548:	0f b6 0c 24          	movzbl (%esp),%ecx
  80154c:	89 c6                	mov    %eax,%esi
  80154e:	b8 20 00 00 00       	mov    $0x20,%eax
  801553:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801557:	2b 04 24             	sub    (%esp),%eax
  80155a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80155e:	d3 e6                	shl    %cl,%esi
  801560:	89 c1                	mov    %eax,%ecx
  801562:	d3 ed                	shr    %cl,%ebp
  801564:	0f b6 0c 24          	movzbl (%esp),%ecx
  801568:	09 f5                	or     %esi,%ebp
  80156a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80156e:	d3 e6                	shl    %cl,%esi
  801570:	89 c1                	mov    %eax,%ecx
  801572:	89 74 24 04          	mov    %esi,0x4(%esp)
  801576:	89 d6                	mov    %edx,%esi
  801578:	d3 ee                	shr    %cl,%esi
  80157a:	0f b6 0c 24          	movzbl (%esp),%ecx
  80157e:	d3 e2                	shl    %cl,%edx
  801580:	89 c1                	mov    %eax,%ecx
  801582:	d3 ef                	shr    %cl,%edi
  801584:	09 d7                	or     %edx,%edi
  801586:	89 f2                	mov    %esi,%edx
  801588:	89 f8                	mov    %edi,%eax
  80158a:	f7 f5                	div    %ebp
  80158c:	89 d6                	mov    %edx,%esi
  80158e:	89 c7                	mov    %eax,%edi
  801590:	f7 64 24 04          	mull   0x4(%esp)
  801594:	39 d6                	cmp    %edx,%esi
  801596:	72 30                	jb     8015c8 <__udivdi3+0x138>
  801598:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  80159c:	0f b6 0c 24          	movzbl (%esp),%ecx
  8015a0:	d3 e5                	shl    %cl,%ebp
  8015a2:	39 c5                	cmp    %eax,%ebp
  8015a4:	73 04                	jae    8015aa <__udivdi3+0x11a>
  8015a6:	39 d6                	cmp    %edx,%esi
  8015a8:	74 1e                	je     8015c8 <__udivdi3+0x138>
  8015aa:	89 f8                	mov    %edi,%eax
  8015ac:	31 d2                	xor    %edx,%edx
  8015ae:	e9 69 ff ff ff       	jmp    80151c <__udivdi3+0x8c>
  8015b3:	90                   	nop
  8015b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015b8:	31 d2                	xor    %edx,%edx
  8015ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8015bf:	e9 58 ff ff ff       	jmp    80151c <__udivdi3+0x8c>
  8015c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015c8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8015cb:	31 d2                	xor    %edx,%edx
  8015cd:	8b 74 24 10          	mov    0x10(%esp),%esi
  8015d1:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8015d5:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8015d9:	83 c4 1c             	add    $0x1c,%esp
  8015dc:	c3                   	ret    
  8015dd:	66 90                	xchg   %ax,%ax
  8015df:	90                   	nop

008015e0 <__umoddi3>:
  8015e0:	83 ec 2c             	sub    $0x2c,%esp
  8015e3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8015e7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8015eb:	89 74 24 20          	mov    %esi,0x20(%esp)
  8015ef:	8b 74 24 38          	mov    0x38(%esp),%esi
  8015f3:	89 7c 24 24          	mov    %edi,0x24(%esp)
  8015f7:	8b 7c 24 34          	mov    0x34(%esp),%edi
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	89 c2                	mov    %eax,%edx
  8015ff:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801603:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801607:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80160b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80160f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801613:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801617:	75 1f                	jne    801638 <__umoddi3+0x58>
  801619:	39 fe                	cmp    %edi,%esi
  80161b:	76 63                	jbe    801680 <__umoddi3+0xa0>
  80161d:	89 c8                	mov    %ecx,%eax
  80161f:	89 fa                	mov    %edi,%edx
  801621:	f7 f6                	div    %esi
  801623:	89 d0                	mov    %edx,%eax
  801625:	31 d2                	xor    %edx,%edx
  801627:	8b 74 24 20          	mov    0x20(%esp),%esi
  80162b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80162f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801633:	83 c4 2c             	add    $0x2c,%esp
  801636:	c3                   	ret    
  801637:	90                   	nop
  801638:	39 f8                	cmp    %edi,%eax
  80163a:	77 64                	ja     8016a0 <__umoddi3+0xc0>
  80163c:	0f bd e8             	bsr    %eax,%ebp
  80163f:	83 f5 1f             	xor    $0x1f,%ebp
  801642:	75 74                	jne    8016b8 <__umoddi3+0xd8>
  801644:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801648:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  80164c:	0f 87 0e 01 00 00    	ja     801760 <__umoddi3+0x180>
  801652:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801656:	29 f1                	sub    %esi,%ecx
  801658:	19 c7                	sbb    %eax,%edi
  80165a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80165e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801662:	8b 44 24 14          	mov    0x14(%esp),%eax
  801666:	8b 54 24 18          	mov    0x18(%esp),%edx
  80166a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80166e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801672:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801676:	83 c4 2c             	add    $0x2c,%esp
  801679:	c3                   	ret    
  80167a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801680:	85 f6                	test   %esi,%esi
  801682:	89 f5                	mov    %esi,%ebp
  801684:	75 0b                	jne    801691 <__umoddi3+0xb1>
  801686:	b8 01 00 00 00       	mov    $0x1,%eax
  80168b:	31 d2                	xor    %edx,%edx
  80168d:	f7 f6                	div    %esi
  80168f:	89 c5                	mov    %eax,%ebp
  801691:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801695:	31 d2                	xor    %edx,%edx
  801697:	f7 f5                	div    %ebp
  801699:	89 c8                	mov    %ecx,%eax
  80169b:	f7 f5                	div    %ebp
  80169d:	eb 84                	jmp    801623 <__umoddi3+0x43>
  80169f:	90                   	nop
  8016a0:	89 c8                	mov    %ecx,%eax
  8016a2:	89 fa                	mov    %edi,%edx
  8016a4:	8b 74 24 20          	mov    0x20(%esp),%esi
  8016a8:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8016ac:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8016b0:	83 c4 2c             	add    $0x2c,%esp
  8016b3:	c3                   	ret    
  8016b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016b8:	8b 44 24 10          	mov    0x10(%esp),%eax
  8016bc:	be 20 00 00 00       	mov    $0x20,%esi
  8016c1:	89 e9                	mov    %ebp,%ecx
  8016c3:	29 ee                	sub    %ebp,%esi
  8016c5:	d3 e2                	shl    %cl,%edx
  8016c7:	89 f1                	mov    %esi,%ecx
  8016c9:	d3 e8                	shr    %cl,%eax
  8016cb:	89 e9                	mov    %ebp,%ecx
  8016cd:	09 d0                	or     %edx,%eax
  8016cf:	89 fa                	mov    %edi,%edx
  8016d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016d5:	8b 44 24 10          	mov    0x10(%esp),%eax
  8016d9:	d3 e0                	shl    %cl,%eax
  8016db:	89 f1                	mov    %esi,%ecx
  8016dd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016e1:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8016e5:	d3 ea                	shr    %cl,%edx
  8016e7:	89 e9                	mov    %ebp,%ecx
  8016e9:	d3 e7                	shl    %cl,%edi
  8016eb:	89 f1                	mov    %esi,%ecx
  8016ed:	d3 e8                	shr    %cl,%eax
  8016ef:	89 e9                	mov    %ebp,%ecx
  8016f1:	09 f8                	or     %edi,%eax
  8016f3:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8016f7:	f7 74 24 0c          	divl   0xc(%esp)
  8016fb:	d3 e7                	shl    %cl,%edi
  8016fd:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801701:	89 d7                	mov    %edx,%edi
  801703:	f7 64 24 10          	mull   0x10(%esp)
  801707:	39 d7                	cmp    %edx,%edi
  801709:	89 c1                	mov    %eax,%ecx
  80170b:	89 54 24 14          	mov    %edx,0x14(%esp)
  80170f:	72 3b                	jb     80174c <__umoddi3+0x16c>
  801711:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801715:	72 31                	jb     801748 <__umoddi3+0x168>
  801717:	8b 44 24 18          	mov    0x18(%esp),%eax
  80171b:	29 c8                	sub    %ecx,%eax
  80171d:	19 d7                	sbb    %edx,%edi
  80171f:	89 e9                	mov    %ebp,%ecx
  801721:	89 fa                	mov    %edi,%edx
  801723:	d3 e8                	shr    %cl,%eax
  801725:	89 f1                	mov    %esi,%ecx
  801727:	d3 e2                	shl    %cl,%edx
  801729:	89 e9                	mov    %ebp,%ecx
  80172b:	09 d0                	or     %edx,%eax
  80172d:	89 fa                	mov    %edi,%edx
  80172f:	d3 ea                	shr    %cl,%edx
  801731:	8b 74 24 20          	mov    0x20(%esp),%esi
  801735:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801739:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  80173d:	83 c4 2c             	add    $0x2c,%esp
  801740:	c3                   	ret    
  801741:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801748:	39 d7                	cmp    %edx,%edi
  80174a:	75 cb                	jne    801717 <__umoddi3+0x137>
  80174c:	8b 54 24 14          	mov    0x14(%esp),%edx
  801750:	89 c1                	mov    %eax,%ecx
  801752:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801756:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  80175a:	eb bb                	jmp    801717 <__umoddi3+0x137>
  80175c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801760:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801764:	0f 82 e8 fe ff ff    	jb     801652 <__umoddi3+0x72>
  80176a:	e9 f3 fe ff ff       	jmp    801662 <__umoddi3+0x82>
