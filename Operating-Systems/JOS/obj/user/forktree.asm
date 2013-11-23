
obj/user/forktree:     file format elf32-i386


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
  80002c:	e8 cb 00 00 00       	call   8000fc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003e:	e8 09 0d 00 00       	call   800d4c <sys_getenvid>
  800043:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800047:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004b:	c7 04 24 60 17 80 00 	movl   $0x801760,(%esp)
  800052:	e8 b8 01 00 00       	call   80020f <cprintf>

	forkchild(cur, '0');
  800057:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  80005e:	00 
  80005f:	89 1c 24             	mov    %ebx,(%esp)
  800062:	e8 16 00 00 00       	call   80007d <forkchild>
	forkchild(cur, '1');
  800067:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  80006e:	00 
  80006f:	89 1c 24             	mov    %ebx,(%esp)
  800072:	e8 06 00 00 00       	call   80007d <forkchild>
}
  800077:	83 c4 14             	add    $0x14,%esp
  80007a:	5b                   	pop    %ebx
  80007b:	5d                   	pop    %ebp
  80007c:	c3                   	ret    

0080007d <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80007d:	55                   	push   %ebp
  80007e:	89 e5                	mov    %esp,%ebp
  800080:	83 ec 38             	sub    $0x38,%esp
  800083:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800086:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800089:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80008c:	8b 75 0c             	mov    0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80008f:	89 1c 24             	mov    %ebx,(%esp)
  800092:	e8 99 07 00 00       	call   800830 <strlen>
  800097:	83 f8 02             	cmp    $0x2,%eax
  80009a:	7f 41                	jg     8000dd <forkchild+0x60>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80009c:	89 f0                	mov    %esi,%eax
  80009e:	0f be f0             	movsbl %al,%esi
  8000a1:	89 74 24 10          	mov    %esi,0x10(%esp)
  8000a5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000a9:	c7 44 24 08 71 17 80 	movl   $0x801771,0x8(%esp)
  8000b0:	00 
  8000b1:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000b8:	00 
  8000b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000bc:	89 04 24             	mov    %eax,(%esp)
  8000bf:	e8 35 07 00 00       	call   8007f9 <snprintf>
	if (fork() == 0) {
  8000c4:	e8 50 10 00 00       	call   801119 <fork>
  8000c9:	85 c0                	test   %eax,%eax
  8000cb:	75 10                	jne    8000dd <forkchild+0x60>
		forktree(nxt);
  8000cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000d0:	89 04 24             	mov    %eax,(%esp)
  8000d3:	e8 5c ff ff ff       	call   800034 <forktree>
		exit();
  8000d8:	e8 7b 00 00 00       	call   800158 <exit>
	}
}
  8000dd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000e0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000e3:	89 ec                	mov    %ebp,%esp
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 18             	sub    $0x18,%esp
	forktree("");
  8000ed:	c7 04 24 70 17 80 00 	movl   $0x801770,(%esp)
  8000f4:	e8 3b ff ff ff       	call   800034 <forktree>
}
  8000f9:	c9                   	leave  
  8000fa:	c3                   	ret    
  8000fb:	90                   	nop

008000fc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	83 ec 18             	sub    $0x18,%esp
  800102:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800105:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800108:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80010b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80010e:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800115:	00 00 00 
	int envid;
	envid = sys_getenvid();
  800118:	e8 2f 0c 00 00       	call   800d4c <sys_getenvid>
	thisenv = envs + ENVX(envid);
  80011d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800122:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800125:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80012a:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012f:	85 db                	test   %ebx,%ebx
  800131:	7e 07                	jle    80013a <libmain+0x3e>
		binaryname = argv[0];
  800133:	8b 06                	mov    (%esi),%eax
  800135:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80013a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80013e:	89 1c 24             	mov    %ebx,(%esp)
  800141:	e8 a1 ff ff ff       	call   8000e7 <umain>

	// exit gracefully
	exit();
  800146:	e8 0d 00 00 00       	call   800158 <exit>
}
  80014b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80014e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800151:	89 ec                	mov    %ebp,%esp
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    
  800155:	66 90                	xchg   %ax,%ax
  800157:	90                   	nop

00800158 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80015e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800165:	e8 85 0b 00 00       	call   800cef <sys_env_destroy>
}
  80016a:	c9                   	leave  
  80016b:	c3                   	ret    

0080016c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	53                   	push   %ebx
  800170:	83 ec 14             	sub    $0x14,%esp
  800173:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800176:	8b 03                	mov    (%ebx),%eax
  800178:	8b 55 08             	mov    0x8(%ebp),%edx
  80017b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80017f:	83 c0 01             	add    $0x1,%eax
  800182:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800184:	3d ff 00 00 00       	cmp    $0xff,%eax
  800189:	75 19                	jne    8001a4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80018b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800192:	00 
  800193:	8d 43 08             	lea    0x8(%ebx),%eax
  800196:	89 04 24             	mov    %eax,(%esp)
  800199:	e8 f2 0a 00 00       	call   800c90 <sys_cputs>
		b->idx = 0;
  80019e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001a4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a8:	83 c4 14             	add    $0x14,%esp
  8001ab:	5b                   	pop    %ebx
  8001ac:	5d                   	pop    %ebp
  8001ad:	c3                   	ret    

008001ae <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ae:	55                   	push   %ebp
  8001af:	89 e5                	mov    %esp,%ebp
  8001b1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001b7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001be:	00 00 00 
	b.cnt = 0;
  8001c1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e3:	c7 04 24 6c 01 80 00 	movl   $0x80016c,(%esp)
  8001ea:	e8 b3 01 00 00       	call   8003a2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ef:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ff:	89 04 24             	mov    %eax,(%esp)
  800202:	e8 89 0a 00 00       	call   800c90 <sys_cputs>

	return b.cnt;
}
  800207:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020d:	c9                   	leave  
  80020e:	c3                   	ret    

0080020f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800215:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800218:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021c:	8b 45 08             	mov    0x8(%ebp),%eax
  80021f:	89 04 24             	mov    %eax,(%esp)
  800222:	e8 87 ff ff ff       	call   8001ae <vcprintf>
	va_end(ap);

	return cnt;
}
  800227:	c9                   	leave  
  800228:	c3                   	ret    
  800229:	66 90                	xchg   %ax,%ax
  80022b:	66 90                	xchg   %ax,%ax
  80022d:	66 90                	xchg   %ax,%ax
  80022f:	90                   	nop

00800230 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	57                   	push   %edi
  800234:	56                   	push   %esi
  800235:	53                   	push   %ebx
  800236:	83 ec 4c             	sub    $0x4c,%esp
  800239:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80023c:	89 d7                	mov    %edx,%edi
  80023e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800241:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800244:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800247:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80024a:	b8 00 00 00 00       	mov    $0x0,%eax
  80024f:	39 d8                	cmp    %ebx,%eax
  800251:	72 17                	jb     80026a <printnum+0x3a>
  800253:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800256:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  800259:	76 0f                	jbe    80026a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80025b:	8b 75 14             	mov    0x14(%ebp),%esi
  80025e:	83 ee 01             	sub    $0x1,%esi
  800261:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800264:	85 f6                	test   %esi,%esi
  800266:	7f 63                	jg     8002cb <printnum+0x9b>
  800268:	eb 75                	jmp    8002df <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026a:	8b 5d 18             	mov    0x18(%ebp),%ebx
  80026d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800271:	8b 45 14             	mov    0x14(%ebp),%eax
  800274:	83 e8 01             	sub    $0x1,%eax
  800277:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80027b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80027e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800282:	8b 44 24 08          	mov    0x8(%esp),%eax
  800286:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80028a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80028d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800290:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800297:	00 
  800298:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80029b:	89 1c 24             	mov    %ebx,(%esp)
  80029e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002a5:	e8 c6 11 00 00       	call   801470 <__udivdi3>
  8002aa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002ad:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002b0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002b4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b8:	89 04 24             	mov    %eax,(%esp)
  8002bb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002bf:	89 fa                	mov    %edi,%edx
  8002c1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002c4:	e8 67 ff ff ff       	call   800230 <printnum>
  8002c9:	eb 14                	jmp    8002df <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002cb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002cf:	8b 45 18             	mov    0x18(%ebp),%eax
  8002d2:	89 04 24             	mov    %eax,(%esp)
  8002d5:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002d7:	83 ee 01             	sub    $0x1,%esi
  8002da:	75 ef                	jne    8002cb <printnum+0x9b>
  8002dc:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002df:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002ea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ee:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002f5:	00 
  8002f6:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8002f9:	89 1c 24             	mov    %ebx,(%esp)
  8002fc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800303:	e8 b8 12 00 00       	call   8015c0 <__umoddi3>
  800308:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80030c:	0f be 80 80 17 80 00 	movsbl 0x801780(%eax),%eax
  800313:	89 04 24             	mov    %eax,(%esp)
  800316:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800319:	ff d0                	call   *%eax
}
  80031b:	83 c4 4c             	add    $0x4c,%esp
  80031e:	5b                   	pop    %ebx
  80031f:	5e                   	pop    %esi
  800320:	5f                   	pop    %edi
  800321:	5d                   	pop    %ebp
  800322:	c3                   	ret    

00800323 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800326:	83 fa 01             	cmp    $0x1,%edx
  800329:	7e 0e                	jle    800339 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80032b:	8b 10                	mov    (%eax),%edx
  80032d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800330:	89 08                	mov    %ecx,(%eax)
  800332:	8b 02                	mov    (%edx),%eax
  800334:	8b 52 04             	mov    0x4(%edx),%edx
  800337:	eb 22                	jmp    80035b <getuint+0x38>
	else if (lflag)
  800339:	85 d2                	test   %edx,%edx
  80033b:	74 10                	je     80034d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80033d:	8b 10                	mov    (%eax),%edx
  80033f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800342:	89 08                	mov    %ecx,(%eax)
  800344:	8b 02                	mov    (%edx),%eax
  800346:	ba 00 00 00 00       	mov    $0x0,%edx
  80034b:	eb 0e                	jmp    80035b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80034d:	8b 10                	mov    (%eax),%edx
  80034f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800352:	89 08                	mov    %ecx,(%eax)
  800354:	8b 02                	mov    (%edx),%eax
  800356:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80035b:	5d                   	pop    %ebp
  80035c:	c3                   	ret    

0080035d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800363:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800367:	8b 10                	mov    (%eax),%edx
  800369:	3b 50 04             	cmp    0x4(%eax),%edx
  80036c:	73 0a                	jae    800378 <sprintputch+0x1b>
		*b->buf++ = ch;
  80036e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800371:	88 0a                	mov    %cl,(%edx)
  800373:	83 c2 01             	add    $0x1,%edx
  800376:	89 10                	mov    %edx,(%eax)
}
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800380:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800383:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800387:	8b 45 10             	mov    0x10(%ebp),%eax
  80038a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80038e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800391:	89 44 24 04          	mov    %eax,0x4(%esp)
  800395:	8b 45 08             	mov    0x8(%ebp),%eax
  800398:	89 04 24             	mov    %eax,(%esp)
  80039b:	e8 02 00 00 00       	call   8003a2 <vprintfmt>
	va_end(ap);
}
  8003a0:	c9                   	leave  
  8003a1:	c3                   	ret    

008003a2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003a2:	55                   	push   %ebp
  8003a3:	89 e5                	mov    %esp,%ebp
  8003a5:	57                   	push   %edi
  8003a6:	56                   	push   %esi
  8003a7:	53                   	push   %ebx
  8003a8:	83 ec 4c             	sub    $0x4c,%esp
  8003ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003b1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b4:	eb 11                	jmp    8003c7 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b6:	85 c0                	test   %eax,%eax
  8003b8:	0f 84 db 03 00 00    	je     800799 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  8003be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003c2:	89 04 24             	mov    %eax,(%esp)
  8003c5:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c7:	0f b6 07             	movzbl (%edi),%eax
  8003ca:	83 c7 01             	add    $0x1,%edi
  8003cd:	83 f8 25             	cmp    $0x25,%eax
  8003d0:	75 e4                	jne    8003b6 <vprintfmt+0x14>
  8003d2:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  8003d6:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8003dd:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8003e4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f0:	eb 2b                	jmp    80041d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f5:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  8003f9:	eb 22                	jmp    80041d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fb:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003fe:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  800402:	eb 19                	jmp    80041d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800407:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80040e:	eb 0d                	jmp    80041d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800410:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800413:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800416:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	0f b6 0f             	movzbl (%edi),%ecx
  800420:	8d 47 01             	lea    0x1(%edi),%eax
  800423:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800426:	0f b6 07             	movzbl (%edi),%eax
  800429:	83 e8 23             	sub    $0x23,%eax
  80042c:	3c 55                	cmp    $0x55,%al
  80042e:	0f 87 40 03 00 00    	ja     800774 <vprintfmt+0x3d2>
  800434:	0f b6 c0             	movzbl %al,%eax
  800437:	ff 24 85 40 18 80 00 	jmp    *0x801840(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80043e:	83 e9 30             	sub    $0x30,%ecx
  800441:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  800444:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  800448:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80044b:	83 f9 09             	cmp    $0x9,%ecx
  80044e:	77 57                	ja     8004a7 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800450:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800453:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800456:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800459:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80045c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80045f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800463:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800466:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800469:	83 f9 09             	cmp    $0x9,%ecx
  80046c:	76 eb                	jbe    800459 <vprintfmt+0xb7>
  80046e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800471:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800474:	eb 34                	jmp    8004aa <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800476:	8b 45 14             	mov    0x14(%ebp),%eax
  800479:	8d 48 04             	lea    0x4(%eax),%ecx
  80047c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80047f:	8b 00                	mov    (%eax),%eax
  800481:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800487:	eb 21                	jmp    8004aa <vprintfmt+0x108>

		case '.':
			if (width < 0)
  800489:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80048d:	0f 88 71 ff ff ff    	js     800404 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800493:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800496:	eb 85                	jmp    80041d <vprintfmt+0x7b>
  800498:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80049b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8004a2:	e9 76 ff ff ff       	jmp    80041d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a7:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004aa:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ae:	0f 89 69 ff ff ff    	jns    80041d <vprintfmt+0x7b>
  8004b4:	e9 57 ff ff ff       	jmp    800410 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004b9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bc:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004bf:	e9 59 ff ff ff       	jmp    80041d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c7:	8d 50 04             	lea    0x4(%eax),%edx
  8004ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d1:	8b 00                	mov    (%eax),%eax
  8004d3:	89 04 24             	mov    %eax,(%esp)
  8004d6:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004db:	e9 e7 fe ff ff       	jmp    8003c7 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e3:	8d 50 04             	lea    0x4(%eax),%edx
  8004e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e9:	8b 00                	mov    (%eax),%eax
  8004eb:	89 c2                	mov    %eax,%edx
  8004ed:	c1 fa 1f             	sar    $0x1f,%edx
  8004f0:	31 d0                	xor    %edx,%eax
  8004f2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f4:	83 f8 08             	cmp    $0x8,%eax
  8004f7:	7f 0b                	jg     800504 <vprintfmt+0x162>
  8004f9:	8b 14 85 a0 19 80 00 	mov    0x8019a0(,%eax,4),%edx
  800500:	85 d2                	test   %edx,%edx
  800502:	75 20                	jne    800524 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800504:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800508:	c7 44 24 08 98 17 80 	movl   $0x801798,0x8(%esp)
  80050f:	00 
  800510:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800514:	89 34 24             	mov    %esi,(%esp)
  800517:	e8 5e fe ff ff       	call   80037a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80051f:	e9 a3 fe ff ff       	jmp    8003c7 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800524:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800528:	c7 44 24 08 a1 17 80 	movl   $0x8017a1,0x8(%esp)
  80052f:	00 
  800530:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800534:	89 34 24             	mov    %esi,(%esp)
  800537:	e8 3e fe ff ff       	call   80037a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80053f:	e9 83 fe ff ff       	jmp    8003c7 <vprintfmt+0x25>
  800544:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800547:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80054a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 50 04             	lea    0x4(%eax),%edx
  800553:	89 55 14             	mov    %edx,0x14(%ebp)
  800556:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800558:	85 ff                	test   %edi,%edi
  80055a:	b8 91 17 80 00       	mov    $0x801791,%eax
  80055f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800562:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  800566:	74 06                	je     80056e <vprintfmt+0x1cc>
  800568:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80056c:	7f 16                	jg     800584 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056e:	0f b6 17             	movzbl (%edi),%edx
  800571:	0f be c2             	movsbl %dl,%eax
  800574:	83 c7 01             	add    $0x1,%edi
  800577:	85 c0                	test   %eax,%eax
  800579:	0f 85 9f 00 00 00    	jne    80061e <vprintfmt+0x27c>
  80057f:	e9 8b 00 00 00       	jmp    80060f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800584:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800588:	89 3c 24             	mov    %edi,(%esp)
  80058b:	e8 c2 02 00 00       	call   800852 <strnlen>
  800590:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800593:	29 c2                	sub    %eax,%edx
  800595:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800598:	85 d2                	test   %edx,%edx
  80059a:	7e d2                	jle    80056e <vprintfmt+0x1cc>
					putch(padc, putdat);
  80059c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  8005a0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8005a3:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005a6:	89 d7                	mov    %edx,%edi
  8005a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005af:	89 04 24             	mov    %eax,(%esp)
  8005b2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b4:	83 ef 01             	sub    $0x1,%edi
  8005b7:	75 ef                	jne    8005a8 <vprintfmt+0x206>
  8005b9:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8005bc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005bf:	eb ad                	jmp    80056e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005c1:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005c5:	74 20                	je     8005e7 <vprintfmt+0x245>
  8005c7:	0f be d2             	movsbl %dl,%edx
  8005ca:	83 ea 20             	sub    $0x20,%edx
  8005cd:	83 fa 5e             	cmp    $0x5e,%edx
  8005d0:	76 15                	jbe    8005e7 <vprintfmt+0x245>
					putch('?', putdat);
  8005d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005d9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005e0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005e3:	ff d1                	call   *%ecx
  8005e5:	eb 0f                	jmp    8005f6 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  8005e7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005ea:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005ee:	89 04 24             	mov    %eax,(%esp)
  8005f1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005f4:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f6:	83 eb 01             	sub    $0x1,%ebx
  8005f9:	0f b6 17             	movzbl (%edi),%edx
  8005fc:	0f be c2             	movsbl %dl,%eax
  8005ff:	83 c7 01             	add    $0x1,%edi
  800602:	85 c0                	test   %eax,%eax
  800604:	75 24                	jne    80062a <vprintfmt+0x288>
  800606:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800609:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80060c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800612:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800616:	0f 8e ab fd ff ff    	jle    8003c7 <vprintfmt+0x25>
  80061c:	eb 20                	jmp    80063e <vprintfmt+0x29c>
  80061e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800621:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800624:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800627:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80062a:	85 f6                	test   %esi,%esi
  80062c:	78 93                	js     8005c1 <vprintfmt+0x21f>
  80062e:	83 ee 01             	sub    $0x1,%esi
  800631:	79 8e                	jns    8005c1 <vprintfmt+0x21f>
  800633:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800636:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800639:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80063c:	eb d1                	jmp    80060f <vprintfmt+0x26d>
  80063e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800641:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800645:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80064c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80064e:	83 ef 01             	sub    $0x1,%edi
  800651:	75 ee                	jne    800641 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800653:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800656:	e9 6c fd ff ff       	jmp    8003c7 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80065b:	83 fa 01             	cmp    $0x1,%edx
  80065e:	66 90                	xchg   %ax,%ax
  800660:	7e 16                	jle    800678 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  800662:	8b 45 14             	mov    0x14(%ebp),%eax
  800665:	8d 50 08             	lea    0x8(%eax),%edx
  800668:	89 55 14             	mov    %edx,0x14(%ebp)
  80066b:	8b 10                	mov    (%eax),%edx
  80066d:	8b 48 04             	mov    0x4(%eax),%ecx
  800670:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800673:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800676:	eb 32                	jmp    8006aa <vprintfmt+0x308>
	else if (lflag)
  800678:	85 d2                	test   %edx,%edx
  80067a:	74 18                	je     800694 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8d 50 04             	lea    0x4(%eax),%edx
  800682:	89 55 14             	mov    %edx,0x14(%ebp)
  800685:	8b 00                	mov    (%eax),%eax
  800687:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80068a:	89 c1                	mov    %eax,%ecx
  80068c:	c1 f9 1f             	sar    $0x1f,%ecx
  80068f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800692:	eb 16                	jmp    8006aa <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 50 04             	lea    0x4(%eax),%edx
  80069a:	89 55 14             	mov    %edx,0x14(%ebp)
  80069d:	8b 00                	mov    (%eax),%eax
  80069f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006a2:	89 c7                	mov    %eax,%edi
  8006a4:	c1 ff 1f             	sar    $0x1f,%edi
  8006a7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006aa:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006ad:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006b0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006b5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006b9:	79 7d                	jns    800738 <vprintfmt+0x396>
				putch('-', putdat);
  8006bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bf:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006c6:	ff d6                	call   *%esi
				num = -(long long) num;
  8006c8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006cb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006ce:	f7 d8                	neg    %eax
  8006d0:	83 d2 00             	adc    $0x0,%edx
  8006d3:	f7 da                	neg    %edx
			}
			base = 10;
  8006d5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006da:	eb 5c                	jmp    800738 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006dc:	8d 45 14             	lea    0x14(%ebp),%eax
  8006df:	e8 3f fc ff ff       	call   800323 <getuint>
			base = 10;
  8006e4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006e9:	eb 4d                	jmp    800738 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ee:	e8 30 fc ff ff       	call   800323 <getuint>
			base = 8;
  8006f3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006f8:	eb 3e                	jmp    800738 <vprintfmt+0x396>

		// pointer
		case 'p':
			putch('0', putdat);
  8006fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006fe:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800705:	ff d6                	call   *%esi
			putch('x', putdat);
  800707:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800712:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8d 50 04             	lea    0x4(%eax),%edx
  80071a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80071d:	8b 00                	mov    (%eax),%eax
  80071f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800724:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800729:	eb 0d                	jmp    800738 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80072b:	8d 45 14             	lea    0x14(%ebp),%eax
  80072e:	e8 f0 fb ff ff       	call   800323 <getuint>
			base = 16;
  800733:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800738:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  80073c:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800740:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800743:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800747:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80074b:	89 04 24             	mov    %eax,(%esp)
  80074e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800752:	89 da                	mov    %ebx,%edx
  800754:	89 f0                	mov    %esi,%eax
  800756:	e8 d5 fa ff ff       	call   800230 <printnum>
			break;
  80075b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80075e:	e9 64 fc ff ff       	jmp    8003c7 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800763:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800767:	89 0c 24             	mov    %ecx,(%esp)
  80076a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80076f:	e9 53 fc ff ff       	jmp    8003c7 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800774:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800778:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80077f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800781:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800785:	0f 84 3c fc ff ff    	je     8003c7 <vprintfmt+0x25>
  80078b:	83 ef 01             	sub    $0x1,%edi
  80078e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800792:	75 f7                	jne    80078b <vprintfmt+0x3e9>
  800794:	e9 2e fc ff ff       	jmp    8003c7 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800799:	83 c4 4c             	add    $0x4c,%esp
  80079c:	5b                   	pop    %ebx
  80079d:	5e                   	pop    %esi
  80079e:	5f                   	pop    %edi
  80079f:	5d                   	pop    %ebp
  8007a0:	c3                   	ret    

008007a1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
  8007a4:	83 ec 28             	sub    $0x28,%esp
  8007a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007aa:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007be:	85 d2                	test   %edx,%edx
  8007c0:	7e 30                	jle    8007f2 <vsnprintf+0x51>
  8007c2:	85 c0                	test   %eax,%eax
  8007c4:	74 2c                	je     8007f2 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007db:	c7 04 24 5d 03 80 00 	movl   $0x80035d,(%esp)
  8007e2:	e8 bb fb ff ff       	call   8003a2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ea:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f0:	eb 05                	jmp    8007f7 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007f7:	c9                   	leave  
  8007f8:	c3                   	ret    

008007f9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ff:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800802:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800806:	8b 45 10             	mov    0x10(%ebp),%eax
  800809:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800810:	89 44 24 04          	mov    %eax,0x4(%esp)
  800814:	8b 45 08             	mov    0x8(%ebp),%eax
  800817:	89 04 24             	mov    %eax,(%esp)
  80081a:	e8 82 ff ff ff       	call   8007a1 <vsnprintf>
	va_end(ap);

	return rc;
}
  80081f:	c9                   	leave  
  800820:	c3                   	ret    
  800821:	66 90                	xchg   %ax,%ax
  800823:	66 90                	xchg   %ax,%ax
  800825:	66 90                	xchg   %ax,%ax
  800827:	66 90                	xchg   %ax,%ax
  800829:	66 90                	xchg   %ax,%ax
  80082b:	66 90                	xchg   %ax,%ax
  80082d:	66 90                	xchg   %ax,%ax
  80082f:	90                   	nop

00800830 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800836:	80 3a 00             	cmpb   $0x0,(%edx)
  800839:	74 10                	je     80084b <strlen+0x1b>
  80083b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800840:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800843:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800847:	75 f7                	jne    800840 <strlen+0x10>
  800849:	eb 05                	jmp    800850 <strlen+0x20>
  80084b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	53                   	push   %ebx
  800856:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800859:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085c:	85 c9                	test   %ecx,%ecx
  80085e:	74 1c                	je     80087c <strnlen+0x2a>
  800860:	80 3b 00             	cmpb   $0x0,(%ebx)
  800863:	74 1e                	je     800883 <strnlen+0x31>
  800865:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80086a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80086c:	39 ca                	cmp    %ecx,%edx
  80086e:	74 18                	je     800888 <strnlen+0x36>
  800870:	83 c2 01             	add    $0x1,%edx
  800873:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800878:	75 f0                	jne    80086a <strnlen+0x18>
  80087a:	eb 0c                	jmp    800888 <strnlen+0x36>
  80087c:	b8 00 00 00 00       	mov    $0x0,%eax
  800881:	eb 05                	jmp    800888 <strnlen+0x36>
  800883:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800888:	5b                   	pop    %ebx
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	53                   	push   %ebx
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800895:	89 c2                	mov    %eax,%edx
  800897:	0f b6 19             	movzbl (%ecx),%ebx
  80089a:	88 1a                	mov    %bl,(%edx)
  80089c:	83 c2 01             	add    $0x1,%edx
  80089f:	83 c1 01             	add    $0x1,%ecx
  8008a2:	84 db                	test   %bl,%bl
  8008a4:	75 f1                	jne    800897 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008a6:	5b                   	pop    %ebx
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	53                   	push   %ebx
  8008ad:	83 ec 08             	sub    $0x8,%esp
  8008b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008b3:	89 1c 24             	mov    %ebx,(%esp)
  8008b6:	e8 75 ff ff ff       	call   800830 <strlen>
	strcpy(dst + len, src);
  8008bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008c2:	01 d8                	add    %ebx,%eax
  8008c4:	89 04 24             	mov    %eax,(%esp)
  8008c7:	e8 bf ff ff ff       	call   80088b <strcpy>
	return dst;
}
  8008cc:	89 d8                	mov    %ebx,%eax
  8008ce:	83 c4 08             	add    $0x8,%esp
  8008d1:	5b                   	pop    %ebx
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	56                   	push   %esi
  8008d8:	53                   	push   %ebx
  8008d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008df:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e2:	85 db                	test   %ebx,%ebx
  8008e4:	74 16                	je     8008fc <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e6:	01 f3                	add    %esi,%ebx
  8008e8:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8008ea:	0f b6 02             	movzbl (%edx),%eax
  8008ed:	88 01                	mov    %al,(%ecx)
  8008ef:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f2:	80 3a 01             	cmpb   $0x1,(%edx)
  8008f5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f8:	39 d9                	cmp    %ebx,%ecx
  8008fa:	75 ee                	jne    8008ea <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008fc:	89 f0                	mov    %esi,%eax
  8008fe:	5b                   	pop    %ebx
  8008ff:	5e                   	pop    %esi
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	57                   	push   %edi
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80090e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800911:	89 f8                	mov    %edi,%eax
  800913:	85 f6                	test   %esi,%esi
  800915:	74 33                	je     80094a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800917:	83 fe 01             	cmp    $0x1,%esi
  80091a:	74 25                	je     800941 <strlcpy+0x3f>
  80091c:	0f b6 0b             	movzbl (%ebx),%ecx
  80091f:	84 c9                	test   %cl,%cl
  800921:	74 22                	je     800945 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800923:	83 ee 02             	sub    $0x2,%esi
  800926:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80092b:	88 08                	mov    %cl,(%eax)
  80092d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800930:	39 f2                	cmp    %esi,%edx
  800932:	74 13                	je     800947 <strlcpy+0x45>
  800934:	83 c2 01             	add    $0x1,%edx
  800937:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80093b:	84 c9                	test   %cl,%cl
  80093d:	75 ec                	jne    80092b <strlcpy+0x29>
  80093f:	eb 06                	jmp    800947 <strlcpy+0x45>
  800941:	89 f8                	mov    %edi,%eax
  800943:	eb 02                	jmp    800947 <strlcpy+0x45>
  800945:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800947:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80094a:	29 f8                	sub    %edi,%eax
}
  80094c:	5b                   	pop    %ebx
  80094d:	5e                   	pop    %esi
  80094e:	5f                   	pop    %edi
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800957:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80095a:	0f b6 01             	movzbl (%ecx),%eax
  80095d:	84 c0                	test   %al,%al
  80095f:	74 15                	je     800976 <strcmp+0x25>
  800961:	3a 02                	cmp    (%edx),%al
  800963:	75 11                	jne    800976 <strcmp+0x25>
		p++, q++;
  800965:	83 c1 01             	add    $0x1,%ecx
  800968:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80096b:	0f b6 01             	movzbl (%ecx),%eax
  80096e:	84 c0                	test   %al,%al
  800970:	74 04                	je     800976 <strcmp+0x25>
  800972:	3a 02                	cmp    (%edx),%al
  800974:	74 ef                	je     800965 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800976:	0f b6 c0             	movzbl %al,%eax
  800979:	0f b6 12             	movzbl (%edx),%edx
  80097c:	29 d0                	sub    %edx,%eax
}
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	56                   	push   %esi
  800984:	53                   	push   %ebx
  800985:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800988:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  80098e:	85 f6                	test   %esi,%esi
  800990:	74 29                	je     8009bb <strncmp+0x3b>
  800992:	0f b6 03             	movzbl (%ebx),%eax
  800995:	84 c0                	test   %al,%al
  800997:	74 30                	je     8009c9 <strncmp+0x49>
  800999:	3a 02                	cmp    (%edx),%al
  80099b:	75 2c                	jne    8009c9 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  80099d:	8d 43 01             	lea    0x1(%ebx),%eax
  8009a0:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8009a2:	89 c3                	mov    %eax,%ebx
  8009a4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009a7:	39 f0                	cmp    %esi,%eax
  8009a9:	74 17                	je     8009c2 <strncmp+0x42>
  8009ab:	0f b6 08             	movzbl (%eax),%ecx
  8009ae:	84 c9                	test   %cl,%cl
  8009b0:	74 17                	je     8009c9 <strncmp+0x49>
  8009b2:	83 c0 01             	add    $0x1,%eax
  8009b5:	3a 0a                	cmp    (%edx),%cl
  8009b7:	74 e9                	je     8009a2 <strncmp+0x22>
  8009b9:	eb 0e                	jmp    8009c9 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c0:	eb 0f                	jmp    8009d1 <strncmp+0x51>
  8009c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c7:	eb 08                	jmp    8009d1 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c9:	0f b6 03             	movzbl (%ebx),%eax
  8009cc:	0f b6 12             	movzbl (%edx),%edx
  8009cf:	29 d0                	sub    %edx,%eax
}
  8009d1:	5b                   	pop    %ebx
  8009d2:	5e                   	pop    %esi
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	53                   	push   %ebx
  8009d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dc:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  8009df:	0f b6 18             	movzbl (%eax),%ebx
  8009e2:	84 db                	test   %bl,%bl
  8009e4:	74 1d                	je     800a03 <strchr+0x2e>
  8009e6:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  8009e8:	38 d3                	cmp    %dl,%bl
  8009ea:	75 06                	jne    8009f2 <strchr+0x1d>
  8009ec:	eb 1a                	jmp    800a08 <strchr+0x33>
  8009ee:	38 ca                	cmp    %cl,%dl
  8009f0:	74 16                	je     800a08 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009f2:	83 c0 01             	add    $0x1,%eax
  8009f5:	0f b6 10             	movzbl (%eax),%edx
  8009f8:	84 d2                	test   %dl,%dl
  8009fa:	75 f2                	jne    8009ee <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  8009fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800a01:	eb 05                	jmp    800a08 <strchr+0x33>
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a08:	5b                   	pop    %ebx
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	53                   	push   %ebx
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a15:	0f b6 18             	movzbl (%eax),%ebx
  800a18:	84 db                	test   %bl,%bl
  800a1a:	74 16                	je     800a32 <strfind+0x27>
  800a1c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a1e:	38 d3                	cmp    %dl,%bl
  800a20:	75 06                	jne    800a28 <strfind+0x1d>
  800a22:	eb 0e                	jmp    800a32 <strfind+0x27>
  800a24:	38 ca                	cmp    %cl,%dl
  800a26:	74 0a                	je     800a32 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a28:	83 c0 01             	add    $0x1,%eax
  800a2b:	0f b6 10             	movzbl (%eax),%edx
  800a2e:	84 d2                	test   %dl,%dl
  800a30:	75 f2                	jne    800a24 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800a32:	5b                   	pop    %ebx
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	83 ec 0c             	sub    $0xc,%esp
  800a3b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a3e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a41:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a44:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a47:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a4a:	85 c9                	test   %ecx,%ecx
  800a4c:	74 36                	je     800a84 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a4e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a54:	75 28                	jne    800a7e <memset+0x49>
  800a56:	f6 c1 03             	test   $0x3,%cl
  800a59:	75 23                	jne    800a7e <memset+0x49>
		c &= 0xFF;
  800a5b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a5f:	89 d3                	mov    %edx,%ebx
  800a61:	c1 e3 08             	shl    $0x8,%ebx
  800a64:	89 d6                	mov    %edx,%esi
  800a66:	c1 e6 18             	shl    $0x18,%esi
  800a69:	89 d0                	mov    %edx,%eax
  800a6b:	c1 e0 10             	shl    $0x10,%eax
  800a6e:	09 f0                	or     %esi,%eax
  800a70:	09 c2                	or     %eax,%edx
  800a72:	89 d0                	mov    %edx,%eax
  800a74:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a76:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a79:	fc                   	cld    
  800a7a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a7c:	eb 06                	jmp    800a84 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a81:	fc                   	cld    
  800a82:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a84:	89 f8                	mov    %edi,%eax
  800a86:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a89:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a8c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a8f:	89 ec                	mov    %ebp,%esp
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	83 ec 08             	sub    $0x8,%esp
  800a99:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a9c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aa8:	39 c6                	cmp    %eax,%esi
  800aaa:	73 36                	jae    800ae2 <memmove+0x4f>
  800aac:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aaf:	39 d0                	cmp    %edx,%eax
  800ab1:	73 2f                	jae    800ae2 <memmove+0x4f>
		s += n;
		d += n;
  800ab3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab6:	f6 c2 03             	test   $0x3,%dl
  800ab9:	75 1b                	jne    800ad6 <memmove+0x43>
  800abb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ac1:	75 13                	jne    800ad6 <memmove+0x43>
  800ac3:	f6 c1 03             	test   $0x3,%cl
  800ac6:	75 0e                	jne    800ad6 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ac8:	83 ef 04             	sub    $0x4,%edi
  800acb:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ace:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ad1:	fd                   	std    
  800ad2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad4:	eb 09                	jmp    800adf <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ad6:	83 ef 01             	sub    $0x1,%edi
  800ad9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800adc:	fd                   	std    
  800add:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800adf:	fc                   	cld    
  800ae0:	eb 20                	jmp    800b02 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ae8:	75 13                	jne    800afd <memmove+0x6a>
  800aea:	a8 03                	test   $0x3,%al
  800aec:	75 0f                	jne    800afd <memmove+0x6a>
  800aee:	f6 c1 03             	test   $0x3,%cl
  800af1:	75 0a                	jne    800afd <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800af3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800af6:	89 c7                	mov    %eax,%edi
  800af8:	fc                   	cld    
  800af9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800afb:	eb 05                	jmp    800b02 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800afd:	89 c7                	mov    %eax,%edi
  800aff:	fc                   	cld    
  800b00:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b02:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b05:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b08:	89 ec                	mov    %ebp,%esp
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b12:	8b 45 10             	mov    0x10(%ebp),%eax
  800b15:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b20:	8b 45 08             	mov    0x8(%ebp),%eax
  800b23:	89 04 24             	mov    %eax,(%esp)
  800b26:	e8 68 ff ff ff       	call   800a93 <memmove>
}
  800b2b:	c9                   	leave  
  800b2c:	c3                   	ret    

00800b2d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	57                   	push   %edi
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
  800b33:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b36:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b39:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3c:	8d 78 ff             	lea    -0x1(%eax),%edi
  800b3f:	85 c0                	test   %eax,%eax
  800b41:	74 36                	je     800b79 <memcmp+0x4c>
		if (*s1 != *s2)
  800b43:	0f b6 03             	movzbl (%ebx),%eax
  800b46:	0f b6 0e             	movzbl (%esi),%ecx
  800b49:	38 c8                	cmp    %cl,%al
  800b4b:	75 17                	jne    800b64 <memcmp+0x37>
  800b4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b52:	eb 1a                	jmp    800b6e <memcmp+0x41>
  800b54:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b59:	83 c2 01             	add    $0x1,%edx
  800b5c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b60:	38 c8                	cmp    %cl,%al
  800b62:	74 0a                	je     800b6e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800b64:	0f b6 c0             	movzbl %al,%eax
  800b67:	0f b6 c9             	movzbl %cl,%ecx
  800b6a:	29 c8                	sub    %ecx,%eax
  800b6c:	eb 10                	jmp    800b7e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b6e:	39 fa                	cmp    %edi,%edx
  800b70:	75 e2                	jne    800b54 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b72:	b8 00 00 00 00       	mov    $0x0,%eax
  800b77:	eb 05                	jmp    800b7e <memcmp+0x51>
  800b79:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	53                   	push   %ebx
  800b87:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800b8d:	89 c2                	mov    %eax,%edx
  800b8f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b92:	39 d0                	cmp    %edx,%eax
  800b94:	73 13                	jae    800ba9 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b96:	89 d9                	mov    %ebx,%ecx
  800b98:	38 18                	cmp    %bl,(%eax)
  800b9a:	75 06                	jne    800ba2 <memfind+0x1f>
  800b9c:	eb 0b                	jmp    800ba9 <memfind+0x26>
  800b9e:	38 08                	cmp    %cl,(%eax)
  800ba0:	74 07                	je     800ba9 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ba2:	83 c0 01             	add    $0x1,%eax
  800ba5:	39 d0                	cmp    %edx,%eax
  800ba7:	75 f5                	jne    800b9e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	53                   	push   %ebx
  800bb2:	83 ec 04             	sub    $0x4,%esp
  800bb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bbb:	0f b6 02             	movzbl (%edx),%eax
  800bbe:	3c 09                	cmp    $0x9,%al
  800bc0:	74 04                	je     800bc6 <strtol+0x1a>
  800bc2:	3c 20                	cmp    $0x20,%al
  800bc4:	75 0e                	jne    800bd4 <strtol+0x28>
		s++;
  800bc6:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bc9:	0f b6 02             	movzbl (%edx),%eax
  800bcc:	3c 09                	cmp    $0x9,%al
  800bce:	74 f6                	je     800bc6 <strtol+0x1a>
  800bd0:	3c 20                	cmp    $0x20,%al
  800bd2:	74 f2                	je     800bc6 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bd4:	3c 2b                	cmp    $0x2b,%al
  800bd6:	75 0a                	jne    800be2 <strtol+0x36>
		s++;
  800bd8:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bdb:	bf 00 00 00 00       	mov    $0x0,%edi
  800be0:	eb 10                	jmp    800bf2 <strtol+0x46>
  800be2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800be7:	3c 2d                	cmp    $0x2d,%al
  800be9:	75 07                	jne    800bf2 <strtol+0x46>
		s++, neg = 1;
  800beb:	83 c2 01             	add    $0x1,%edx
  800bee:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bf2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bf8:	75 15                	jne    800c0f <strtol+0x63>
  800bfa:	80 3a 30             	cmpb   $0x30,(%edx)
  800bfd:	75 10                	jne    800c0f <strtol+0x63>
  800bff:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c03:	75 0a                	jne    800c0f <strtol+0x63>
		s += 2, base = 16;
  800c05:	83 c2 02             	add    $0x2,%edx
  800c08:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c0d:	eb 10                	jmp    800c1f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800c0f:	85 db                	test   %ebx,%ebx
  800c11:	75 0c                	jne    800c1f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c13:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c15:	80 3a 30             	cmpb   $0x30,(%edx)
  800c18:	75 05                	jne    800c1f <strtol+0x73>
		s++, base = 8;
  800c1a:	83 c2 01             	add    $0x1,%edx
  800c1d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c24:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c27:	0f b6 0a             	movzbl (%edx),%ecx
  800c2a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c2d:	89 f3                	mov    %esi,%ebx
  800c2f:	80 fb 09             	cmp    $0x9,%bl
  800c32:	77 08                	ja     800c3c <strtol+0x90>
			dig = *s - '0';
  800c34:	0f be c9             	movsbl %cl,%ecx
  800c37:	83 e9 30             	sub    $0x30,%ecx
  800c3a:	eb 22                	jmp    800c5e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800c3c:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c3f:	89 f3                	mov    %esi,%ebx
  800c41:	80 fb 19             	cmp    $0x19,%bl
  800c44:	77 08                	ja     800c4e <strtol+0xa2>
			dig = *s - 'a' + 10;
  800c46:	0f be c9             	movsbl %cl,%ecx
  800c49:	83 e9 57             	sub    $0x57,%ecx
  800c4c:	eb 10                	jmp    800c5e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800c4e:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c51:	89 f3                	mov    %esi,%ebx
  800c53:	80 fb 19             	cmp    $0x19,%bl
  800c56:	77 16                	ja     800c6e <strtol+0xc2>
			dig = *s - 'A' + 10;
  800c58:	0f be c9             	movsbl %cl,%ecx
  800c5b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c5e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800c61:	7d 0f                	jge    800c72 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800c63:	83 c2 01             	add    $0x1,%edx
  800c66:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800c6a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c6c:	eb b9                	jmp    800c27 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c6e:	89 c1                	mov    %eax,%ecx
  800c70:	eb 02                	jmp    800c74 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c72:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c74:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c78:	74 05                	je     800c7f <strtol+0xd3>
		*endptr = (char *) s;
  800c7a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c7d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c7f:	89 ca                	mov    %ecx,%edx
  800c81:	f7 da                	neg    %edx
  800c83:	85 ff                	test   %edi,%edi
  800c85:	0f 45 c2             	cmovne %edx,%eax
}
  800c88:	83 c4 04             	add    $0x4,%esp
  800c8b:	5b                   	pop    %ebx
  800c8c:	5e                   	pop    %esi
  800c8d:	5f                   	pop    %edi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	83 ec 0c             	sub    $0xc,%esp
  800c96:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c99:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c9c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca7:	8b 55 08             	mov    0x8(%ebp),%edx
  800caa:	89 c3                	mov    %eax,%ebx
  800cac:	89 c7                	mov    %eax,%edi
  800cae:	89 c6                	mov    %eax,%esi
  800cb0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cb2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cb5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cb8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cbb:	89 ec                	mov    %ebp,%esp
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <sys_cgetc>:

int
sys_cgetc(void)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	83 ec 0c             	sub    $0xc,%esp
  800cc5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cc8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ccb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cce:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd3:	b8 01 00 00 00       	mov    $0x1,%eax
  800cd8:	89 d1                	mov    %edx,%ecx
  800cda:	89 d3                	mov    %edx,%ebx
  800cdc:	89 d7                	mov    %edx,%edi
  800cde:	89 d6                	mov    %edx,%esi
  800ce0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ce2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ce5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ce8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ceb:	89 ec                	mov    %ebp,%esp
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	83 ec 38             	sub    $0x38,%esp
  800cf5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cf8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cfb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d03:	b8 03 00 00 00       	mov    $0x3,%eax
  800d08:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0b:	89 cb                	mov    %ecx,%ebx
  800d0d:	89 cf                	mov    %ecx,%edi
  800d0f:	89 ce                	mov    %ecx,%esi
  800d11:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d13:	85 c0                	test   %eax,%eax
  800d15:	7e 28                	jle    800d3f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d17:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d1b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d22:	00 
  800d23:	c7 44 24 08 c4 19 80 	movl   $0x8019c4,0x8(%esp)
  800d2a:	00 
  800d2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d32:	00 
  800d33:	c7 04 24 e1 19 80 00 	movl   $0x8019e1,(%esp)
  800d3a:	e8 19 06 00 00       	call   801358 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d3f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d42:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d45:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d48:	89 ec                	mov    %ebp,%esp
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	83 ec 0c             	sub    $0xc,%esp
  800d52:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d55:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d58:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d60:	b8 02 00 00 00       	mov    $0x2,%eax
  800d65:	89 d1                	mov    %edx,%ecx
  800d67:	89 d3                	mov    %edx,%ebx
  800d69:	89 d7                	mov    %edx,%edi
  800d6b:	89 d6                	mov    %edx,%esi
  800d6d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d6f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d72:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d75:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d78:	89 ec                	mov    %ebp,%esp
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <sys_yield>:

void
sys_yield(void)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	83 ec 0c             	sub    $0xc,%esp
  800d82:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d85:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d88:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d90:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d95:	89 d1                	mov    %edx,%ecx
  800d97:	89 d3                	mov    %edx,%ebx
  800d99:	89 d7                	mov    %edx,%edi
  800d9b:	89 d6                	mov    %edx,%esi
  800d9d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d9f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800da2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800da5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800da8:	89 ec                	mov    %ebp,%esp
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    

00800dac <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	83 ec 38             	sub    $0x38,%esp
  800db2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800db5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800db8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbb:	be 00 00 00 00       	mov    $0x0,%esi
  800dc0:	b8 04 00 00 00       	mov    $0x4,%eax
  800dc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dce:	89 f7                	mov    %esi,%edi
  800dd0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd2:	85 c0                	test   %eax,%eax
  800dd4:	7e 28                	jle    800dfe <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dda:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800de1:	00 
  800de2:	c7 44 24 08 c4 19 80 	movl   $0x8019c4,0x8(%esp)
  800de9:	00 
  800dea:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df1:	00 
  800df2:	c7 04 24 e1 19 80 00 	movl   $0x8019e1,(%esp)
  800df9:	e8 5a 05 00 00       	call   801358 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dfe:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e01:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e04:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e07:	89 ec                	mov    %ebp,%esp
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    

00800e0b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	83 ec 38             	sub    $0x38,%esp
  800e11:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e14:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e17:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e22:	8b 55 08             	mov    0x8(%ebp),%edx
  800e25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e28:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e2b:	8b 75 18             	mov    0x18(%ebp),%esi
  800e2e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e30:	85 c0                	test   %eax,%eax
  800e32:	7e 28                	jle    800e5c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e34:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e38:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e3f:	00 
  800e40:	c7 44 24 08 c4 19 80 	movl   $0x8019c4,0x8(%esp)
  800e47:	00 
  800e48:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e4f:	00 
  800e50:	c7 04 24 e1 19 80 00 	movl   $0x8019e1,(%esp)
  800e57:	e8 fc 04 00 00       	call   801358 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e5c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e5f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e62:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e65:	89 ec                	mov    %ebp,%esp
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    

00800e69 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	83 ec 38             	sub    $0x38,%esp
  800e6f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e72:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e75:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e78:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7d:	b8 06 00 00 00       	mov    $0x6,%eax
  800e82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e85:	8b 55 08             	mov    0x8(%ebp),%edx
  800e88:	89 df                	mov    %ebx,%edi
  800e8a:	89 de                	mov    %ebx,%esi
  800e8c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e8e:	85 c0                	test   %eax,%eax
  800e90:	7e 28                	jle    800eba <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e92:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e96:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e9d:	00 
  800e9e:	c7 44 24 08 c4 19 80 	movl   $0x8019c4,0x8(%esp)
  800ea5:	00 
  800ea6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ead:	00 
  800eae:	c7 04 24 e1 19 80 00 	movl   $0x8019e1,(%esp)
  800eb5:	e8 9e 04 00 00       	call   801358 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800eba:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ebd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ec0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ec3:	89 ec                	mov    %ebp,%esp
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	83 ec 38             	sub    $0x38,%esp
  800ecd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ed0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ed3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800edb:	b8 08 00 00 00       	mov    $0x8,%eax
  800ee0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee6:	89 df                	mov    %ebx,%edi
  800ee8:	89 de                	mov    %ebx,%esi
  800eea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eec:	85 c0                	test   %eax,%eax
  800eee:	7e 28                	jle    800f18 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ef4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800efb:	00 
  800efc:	c7 44 24 08 c4 19 80 	movl   $0x8019c4,0x8(%esp)
  800f03:	00 
  800f04:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f0b:	00 
  800f0c:	c7 04 24 e1 19 80 00 	movl   $0x8019e1,(%esp)
  800f13:	e8 40 04 00 00       	call   801358 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f18:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f1b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f1e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f21:	89 ec                	mov    %ebp,%esp
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    

00800f25 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f25:	55                   	push   %ebp
  800f26:	89 e5                	mov    %esp,%ebp
  800f28:	83 ec 38             	sub    $0x38,%esp
  800f2b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f2e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f31:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f34:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f39:	b8 09 00 00 00       	mov    $0x9,%eax
  800f3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f41:	8b 55 08             	mov    0x8(%ebp),%edx
  800f44:	89 df                	mov    %ebx,%edi
  800f46:	89 de                	mov    %ebx,%esi
  800f48:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f4a:	85 c0                	test   %eax,%eax
  800f4c:	7e 28                	jle    800f76 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f52:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f59:	00 
  800f5a:	c7 44 24 08 c4 19 80 	movl   $0x8019c4,0x8(%esp)
  800f61:	00 
  800f62:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f69:	00 
  800f6a:	c7 04 24 e1 19 80 00 	movl   $0x8019e1,(%esp)
  800f71:	e8 e2 03 00 00       	call   801358 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f76:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f79:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f7c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f7f:	89 ec                	mov    %ebp,%esp
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    

00800f83 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	83 ec 0c             	sub    $0xc,%esp
  800f89:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f8c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f8f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f92:	be 00 00 00 00       	mov    $0x0,%esi
  800f97:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fa5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fa8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800faa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fad:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fb0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fb3:	89 ec                	mov    %ebp,%esp
  800fb5:	5d                   	pop    %ebp
  800fb6:	c3                   	ret    

00800fb7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	83 ec 38             	sub    $0x38,%esp
  800fbd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fc0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fc3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fcb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd3:	89 cb                	mov    %ecx,%ebx
  800fd5:	89 cf                	mov    %ecx,%edi
  800fd7:	89 ce                	mov    %ecx,%esi
  800fd9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	7e 28                	jle    801007 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fdf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fe3:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800fea:	00 
  800feb:	c7 44 24 08 c4 19 80 	movl   $0x8019c4,0x8(%esp)
  800ff2:	00 
  800ff3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ffa:	00 
  800ffb:	c7 04 24 e1 19 80 00 	movl   $0x8019e1,(%esp)
  801002:	e8 51 03 00 00       	call   801358 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801007:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80100a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80100d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801010:	89 ec                	mov    %ebp,%esp
  801012:	5d                   	pop    %ebp
  801013:	c3                   	ret    

00801014 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	53                   	push   %ebx
  801018:	83 ec 24             	sub    $0x24,%esp
  80101b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
  80101e:	8b 50 04             	mov    0x4(%eax),%edx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	addr = (void*)(ROUNDDOWN((uint32_t)addr, PGSIZE)); 
  801021:	8b 18                	mov    (%eax),%ebx
  801023:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	int pte = uvpt[PGNUM((uint32_t)addr)];
  801029:	89 d8                	mov    %ebx,%eax
  80102b:	c1 e8 0c             	shr    $0xc,%eax
  80102e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!((pte & PTE_COW) && (err & FEC_WR))) {
  801035:	f6 c4 08             	test   $0x8,%ah
  801038:	74 05                	je     80103f <pgfault+0x2b>
  80103a:	f6 c2 02             	test   $0x2,%dl
  80103d:	75 30                	jne    80106f <pgfault+0x5b>
		cprintf("pte: %x, error: %x\n", pte, err);
  80103f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801043:	89 44 24 04          	mov    %eax,0x4(%esp)
  801047:	c7 04 24 ef 19 80 00 	movl   $0x8019ef,(%esp)
  80104e:	e8 bc f1 ff ff       	call   80020f <cprintf>
		panic("Something wrong in lib/fork.c:pgfault\n");
  801053:	c7 44 24 08 40 1a 80 	movl   $0x801a40,0x8(%esp)
  80105a:	00 
  80105b:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  801062:	00 
  801063:	c7 04 24 03 1a 80 00 	movl   $0x801a03,(%esp)
  80106a:	e8 e9 02 00 00       	call   801358 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	
	int ret;
	ret = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
  80106f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801076:	00 
  801077:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80107e:	00 
  80107f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801086:	e8 21 fd ff ff       	call   800dac <sys_page_alloc>
	if (ret < 0) {
  80108b:	85 c0                	test   %eax,%eax
  80108d:	79 20                	jns    8010af <pgfault+0x9b>
		panic("fork.c/pgfault page allocation %e\n", ret);
  80108f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801093:	c7 44 24 08 68 1a 80 	movl   $0x801a68,0x8(%esp)
  80109a:	00 
  80109b:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  8010a2:	00 
  8010a3:	c7 04 24 03 1a 80 00 	movl   $0x801a03,(%esp)
  8010aa:	e8 a9 02 00 00       	call   801358 <_panic>
	}
	
	memmove(PFTEMP, addr, PGSIZE);
  8010af:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8010b6:	00 
  8010b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010bb:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8010c2:	e8 cc f9 ff ff       	call   800a93 <memmove>

	ret = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_U | PTE_P | PTE_W);
  8010c7:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8010ce:	00 
  8010cf:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010da:	00 
  8010db:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010e2:	00 
  8010e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010ea:	e8 1c fd ff ff       	call   800e0b <sys_page_map>
	if (ret < 0) {
  8010ef:	85 c0                	test   %eax,%eax
  8010f1:	79 20                	jns    801113 <pgfault+0xff>
		panic("fork.c/pgfault page map %e\n", ret);
  8010f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010f7:	c7 44 24 08 0e 1a 80 	movl   $0x801a0e,0x8(%esp)
  8010fe:	00 
  8010ff:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  801106:	00 
  801107:	c7 04 24 03 1a 80 00 	movl   $0x801a03,(%esp)
  80110e:	e8 45 02 00 00       	call   801358 <_panic>
	}

	// panic("pgfault not implemented");
}
  801113:	83 c4 24             	add    $0x24,%esp
  801116:	5b                   	pop    %ebx
  801117:	5d                   	pop    %ebp
  801118:	c3                   	ret    

00801119 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	57                   	push   %edi
  80111d:	56                   	push   %esi
  80111e:	53                   	push   %ebx
  80111f:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int ret = 0;
	extern unsigned char end[];
	void (*handler)(struct UTrapframe *utf) = pgfault;
	set_pgfault_handler(handler);
  801122:	c7 04 24 14 10 80 00 	movl   $0x801014,(%esp)
  801129:	e8 82 02 00 00       	call   8013b0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80112e:	be 07 00 00 00       	mov    $0x7,%esi
  801133:	89 f0                	mov    %esi,%eax
  801135:	cd 30                	int    $0x30
  801137:	89 c6                	mov    %eax,%esi
  801139:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	
	envid_t new_env = sys_exofork();
	if (new_env < 0) {
  80113c:	85 c0                	test   %eax,%eax
  80113e:	0f 88 e7 01 00 00    	js     80132b <fork+0x212>
		return new_env;
	}

	if (new_env == 0) {
  801144:	bb 00 00 00 00       	mov    $0x0,%ebx
  801149:	85 c0                	test   %eax,%eax
  80114b:	75 1c                	jne    801169 <fork+0x50>
		thisenv = &envs[ENVX(sys_getenvid())];
  80114d:	e8 fa fb ff ff       	call   800d4c <sys_getenvid>
  801152:	25 ff 03 00 00       	and    $0x3ff,%eax
  801157:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80115a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80115f:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  801164:	e9 c2 01 00 00       	jmp    80132b <fork+0x212>
	}
	uint32_t va;

	for (va =  0; va < UTOP - PGSIZE; va += PGSIZE) {
		if((uvpd[PDX(va)] & PTE_P) && (uvpd[PDX(va)] & PTE_U)) {
  801169:	89 d8                	mov    %ebx,%eax
  80116b:	c1 e8 16             	shr    $0x16,%eax
  80116e:	8b 14 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%edx
  801175:	f6 c2 01             	test   $0x1,%dl
  801178:	0f 84 bf 00 00 00    	je     80123d <fork+0x124>
  80117e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801185:	a8 04                	test   $0x4,%al
  801187:	0f 84 b0 00 00 00    	je     80123d <fork+0x124>
			if ((uvpt[PGNUM(va)] & PTE_P) &&
  80118d:	89 d8                	mov    %ebx,%eax
  80118f:	c1 e8 0c             	shr    $0xc,%eax
  801192:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801199:	f6 c2 01             	test   $0x1,%dl
  80119c:	0f 84 9b 00 00 00    	je     80123d <fork+0x124>
					(uvpt[PGNUM(va)] & PTE_U)) {
  8011a2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	}
	uint32_t va;

	for (va =  0; va < UTOP - PGSIZE; va += PGSIZE) {
		if((uvpd[PDX(va)] & PTE_P) && (uvpd[PDX(va)] & PTE_U)) {
			if ((uvpt[PGNUM(va)] & PTE_P) &&
  8011a9:	a8 04                	test   $0x4,%al
  8011ab:	0f 84 8c 00 00 00    	je     80123d <fork+0x124>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	int flag = 0;
	uint32_t addr = pn * PGSIZE;
  8011b1:	89 df                	mov    %ebx,%edi
  8011b3:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	// LAB 4: Your code here.
	r = PTE_U | PTE_P;
	int old_perm = uvpt[PGNUM(addr)];
  8011b9:	89 f8                	mov    %edi,%eax
  8011bb:	c1 e8 0c             	shr    $0xc,%eax
  8011be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if ((old_perm & PTE_W) || (r & PTE_COW)) {
  8011c5:	a8 02                	test   $0x2,%al
  8011c7:	0f 85 fe 00 00 00    	jne    8012cb <fork+0x1b2>
  8011cd:	e9 29 01 00 00       	jmp    8012fb <fork+0x1e2>
	}


	int ret = sys_page_map(0, (void*)addr, envid, (void*)addr, r);
	if (ret < 0) {
		panic("fork.c/duppage in page_map %d %e\n", envid, ret);
  8011d2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011d6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011da:	c7 44 24 08 8c 1a 80 	movl   $0x801a8c,0x8(%esp)
  8011e1:	00 
  8011e2:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8011e9:	00 
  8011ea:	c7 04 24 03 1a 80 00 	movl   $0x801a03,(%esp)
  8011f1:	e8 62 01 00 00       	call   801358 <_panic>
		return ret;
	}

	if (flag) {
		ret = sys_page_map(envid, (void*)addr, 0, (void*)addr, r);
  8011f6:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8011fd:	00 
  8011fe:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801202:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801209:	00 
  80120a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80120e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801211:	89 04 24             	mov    %eax,(%esp)
  801214:	e8 f2 fb ff ff       	call   800e0b <sys_page_map>
		if (ret < 0) {
  801219:	85 c0                	test   %eax,%eax
  80121b:	79 20                	jns    80123d <fork+0x124>
			panic("fork.c/duppage in page_map 2 %e\n", ret);
  80121d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801221:	c7 44 24 08 b0 1a 80 	movl   $0x801ab0,0x8(%esp)
  801228:	00 
  801229:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  801230:	00 
  801231:	c7 04 24 03 1a 80 00 	movl   $0x801a03,(%esp)
  801238:	e8 1b 01 00 00       	call   801358 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	uint32_t va;

	for (va =  0; va < UTOP - PGSIZE; va += PGSIZE) {
  80123d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801243:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801249:	0f 85 1a ff ff ff    	jne    801169 <fork+0x50>
				duppage(new_env, (va / PGSIZE));
			}	
		}
	}
	
	ret = sys_page_alloc(new_env, (void*)(UXSTACKTOP - PGSIZE),
  80124f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801256:	00 
  801257:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80125e:	ee 
  80125f:	89 34 24             	mov    %esi,(%esp)
  801262:	e8 45 fb ff ff       	call   800dac <sys_page_alloc>
			  			 PTE_U | PTE_P | PTE_W);
	if (ret < 0) {
  801267:	85 c0                	test   %eax,%eax
  801269:	79 1c                	jns    801287 <fork+0x16e>
		panic("Not able to allocate exception stack for the child\n");
  80126b:	c7 44 24 08 d4 1a 80 	movl   $0x801ad4,0x8(%esp)
  801272:	00 
  801273:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
  80127a:	00 
  80127b:	c7 04 24 03 1a 80 00 	movl   $0x801a03,(%esp)
  801282:	e8 d1 00 00 00       	call   801358 <_panic>
	}

	sys_env_set_pgfault_upcall(new_env, thisenv->env_pgfault_upcall);
  801287:	a1 04 20 80 00       	mov    0x802004,%eax
  80128c:	8b 40 64             	mov    0x64(%eax),%eax
  80128f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801293:	89 34 24             	mov    %esi,(%esp)
  801296:	e8 8a fc ff ff       	call   800f25 <sys_env_set_pgfault_upcall>
	
	ret = sys_env_set_status(new_env, ENV_RUNNABLE);
  80129b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012a2:	00 
  8012a3:	89 34 24             	mov    %esi,(%esp)
  8012a6:	e8 1c fc ff ff       	call   800ec7 <sys_env_set_status>
	if (ret < 0) {
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	79 7c                	jns    80132b <fork+0x212>
		panic("Not able to make child runnable.\n");
  8012af:	c7 44 24 08 08 1b 80 	movl   $0x801b08,0x8(%esp)
  8012b6:	00 
  8012b7:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  8012be:	00 
  8012bf:	c7 04 24 03 1a 80 00 	movl   $0x801a03,(%esp)
  8012c6:	e8 8d 00 00 00       	call   801358 <_panic>
		r = r | PTE_COW;
		flag = 1;
	}


	int ret = sys_page_map(0, (void*)addr, envid, (void*)addr, r);
  8012cb:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8012d2:	00 
  8012d3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012de:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012e9:	e8 1d fb ff ff       	call   800e0b <sys_page_map>
	if (ret < 0) {
  8012ee:	85 c0                	test   %eax,%eax
  8012f0:	0f 89 00 ff ff ff    	jns    8011f6 <fork+0xdd>
  8012f6:	e9 d7 fe ff ff       	jmp    8011d2 <fork+0xb9>
		r = r | PTE_COW;
		flag = 1;
	}


	int ret = sys_page_map(0, (void*)addr, envid, (void*)addr, r);
  8012fb:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801302:	00 
  801303:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801307:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80130a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80130e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801312:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801319:	e8 ed fa ff ff       	call   800e0b <sys_page_map>
	if (ret < 0) {
  80131e:	85 c0                	test   %eax,%eax
  801320:	0f 89 17 ff ff ff    	jns    80123d <fork+0x124>
  801326:	e9 a7 fe ff ff       	jmp    8011d2 <fork+0xb9>
		panic("Not able to make child runnable.\n");
	}

	return new_env;
	// panic("fork not implemented");
}
  80132b:	89 f0                	mov    %esi,%eax
  80132d:	83 c4 3c             	add    $0x3c,%esp
  801330:	5b                   	pop    %ebx
  801331:	5e                   	pop    %esi
  801332:	5f                   	pop    %edi
  801333:	5d                   	pop    %ebp
  801334:	c3                   	ret    

00801335 <sfork>:

// Challenge!
int
sfork(void)
{
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80133b:	c7 44 24 08 2a 1a 80 	movl   $0x801a2a,0x8(%esp)
  801342:	00 
  801343:	c7 44 24 04 a8 00 00 	movl   $0xa8,0x4(%esp)
  80134a:	00 
  80134b:	c7 04 24 03 1a 80 00 	movl   $0x801a03,(%esp)
  801352:	e8 01 00 00 00       	call   801358 <_panic>
  801357:	90                   	nop

00801358 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801358:	55                   	push   %ebp
  801359:	89 e5                	mov    %esp,%ebp
  80135b:	56                   	push   %esi
  80135c:	53                   	push   %ebx
  80135d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801360:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801363:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801369:	e8 de f9 ff ff       	call   800d4c <sys_getenvid>
  80136e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801371:	89 54 24 10          	mov    %edx,0x10(%esp)
  801375:	8b 55 08             	mov    0x8(%ebp),%edx
  801378:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80137c:	89 74 24 08          	mov    %esi,0x8(%esp)
  801380:	89 44 24 04          	mov    %eax,0x4(%esp)
  801384:	c7 04 24 2c 1b 80 00 	movl   $0x801b2c,(%esp)
  80138b:	e8 7f ee ff ff       	call   80020f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801390:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801394:	8b 45 10             	mov    0x10(%ebp),%eax
  801397:	89 04 24             	mov    %eax,(%esp)
  80139a:	e8 0f ee ff ff       	call   8001ae <vcprintf>
	cprintf("\n");
  80139f:	c7 04 24 6f 17 80 00 	movl   $0x80176f,(%esp)
  8013a6:	e8 64 ee ff ff       	call   80020f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8013ab:	cc                   	int3   
  8013ac:	eb fd                	jmp    8013ab <_panic+0x53>
  8013ae:	66 90                	xchg   %ax,%ax

008013b0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
  8013b3:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8013b6:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8013bd:	75 60                	jne    80141f <set_pgfault_handler+0x6f>
		// First time through!
		// LAB 4: Your code here.
		int ret =
  8013bf:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013c6:	00 
  8013c7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013ce:	ee 
  8013cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013d6:	e8 d1 f9 ff ff       	call   800dac <sys_page_alloc>
			sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE),
							PTE_U | PTE_P | PTE_W);
		if (ret < 0) {
  8013db:	85 c0                	test   %eax,%eax
  8013dd:	79 2c                	jns    80140b <set_pgfault_handler+0x5b>
			cprintf("%e\n", ret);
  8013df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e3:	c7 04 24 26 1a 80 00 	movl   $0x801a26,(%esp)
  8013ea:	e8 20 ee ff ff       	call   80020f <cprintf>
			panic("Something wrong with allocation of user exception"
  8013ef:	c7 44 24 08 60 1b 80 	movl   $0x801b60,0x8(%esp)
  8013f6:	00 
  8013f7:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  8013fe:	00 
  8013ff:	c7 04 24 4f 1b 80 00 	movl   $0x801b4f,(%esp)
  801406:	e8 4d ff ff ff       	call   801358 <_panic>
				  "stack\n");
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80140b:	c7 44 24 04 2c 14 80 	movl   $0x80142c,0x4(%esp)
  801412:	00 
  801413:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80141a:	e8 06 fb ff ff       	call   800f25 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80141f:	8b 45 08             	mov    0x8(%ebp),%eax
  801422:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801427:	c9                   	leave  
  801428:	c3                   	ret    
  801429:	66 90                	xchg   %ax,%ax
  80142b:	90                   	nop

0080142c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80142c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80142d:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801432:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801434:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	popl %eax
  801437:	58                   	pop    %eax
	popl %eax
  801438:	58                   	pop    %eax
	
	addl $32, %esp
  801439:	83 c4 20             	add    $0x20,%esp
	movl (%esp), %eax
  80143c:	8b 04 24             	mov    (%esp),%eax
	addl $8, %esp
  80143f:	83 c4 08             	add    $0x8,%esp
	movl (%esp), %ebx
  801442:	8b 1c 24             	mov    (%esp),%ebx
	subl $4, %ebx
  801445:	83 eb 04             	sub    $0x4,%ebx

	movl %ebx, (%esp)
  801448:	89 1c 24             	mov    %ebx,(%esp)

	movl %eax, (%ebx)
  80144b:	89 03                	mov    %eax,(%ebx)
	subl $40, %esp
  80144d:	83 ec 28             	sub    $0x28,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	popl %edi
  801450:	5f                   	pop    %edi
	popl %esi
  801451:	5e                   	pop    %esi
	popl %ebp
  801452:	5d                   	pop    %ebp
	addl $4, %esp
  801453:	83 c4 04             	add    $0x4,%esp
	popl %ebx
  801456:	5b                   	pop    %ebx
	popl %edx
  801457:	5a                   	pop    %edx
	popl %ecx
  801458:	59                   	pop    %ecx
	popl %eax
  801459:	58                   	pop    %eax
	addl $4, %esp
  80145a:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	popfl
  80145d:	9d                   	popf   
	
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	movl (%esp), %esp
  80145e:	8b 24 24             	mov    (%esp),%esp
	
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801461:	c3                   	ret    
  801462:	66 90                	xchg   %ax,%ax
  801464:	66 90                	xchg   %ax,%ax
  801466:	66 90                	xchg   %ax,%ax
  801468:	66 90                	xchg   %ax,%ax
  80146a:	66 90                	xchg   %ax,%ax
  80146c:	66 90                	xchg   %ax,%ax
  80146e:	66 90                	xchg   %ax,%ax

00801470 <__udivdi3>:
  801470:	83 ec 1c             	sub    $0x1c,%esp
  801473:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801477:	89 7c 24 14          	mov    %edi,0x14(%esp)
  80147b:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80147f:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801483:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801487:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  80148b:	85 c0                	test   %eax,%eax
  80148d:	89 74 24 10          	mov    %esi,0x10(%esp)
  801491:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801495:	89 ea                	mov    %ebp,%edx
  801497:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80149b:	75 33                	jne    8014d0 <__udivdi3+0x60>
  80149d:	39 e9                	cmp    %ebp,%ecx
  80149f:	77 6f                	ja     801510 <__udivdi3+0xa0>
  8014a1:	85 c9                	test   %ecx,%ecx
  8014a3:	89 ce                	mov    %ecx,%esi
  8014a5:	75 0b                	jne    8014b2 <__udivdi3+0x42>
  8014a7:	b8 01 00 00 00       	mov    $0x1,%eax
  8014ac:	31 d2                	xor    %edx,%edx
  8014ae:	f7 f1                	div    %ecx
  8014b0:	89 c6                	mov    %eax,%esi
  8014b2:	31 d2                	xor    %edx,%edx
  8014b4:	89 e8                	mov    %ebp,%eax
  8014b6:	f7 f6                	div    %esi
  8014b8:	89 c5                	mov    %eax,%ebp
  8014ba:	89 f8                	mov    %edi,%eax
  8014bc:	f7 f6                	div    %esi
  8014be:	89 ea                	mov    %ebp,%edx
  8014c0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8014c4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8014c8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8014cc:	83 c4 1c             	add    $0x1c,%esp
  8014cf:	c3                   	ret    
  8014d0:	39 e8                	cmp    %ebp,%eax
  8014d2:	77 24                	ja     8014f8 <__udivdi3+0x88>
  8014d4:	0f bd c8             	bsr    %eax,%ecx
  8014d7:	83 f1 1f             	xor    $0x1f,%ecx
  8014da:	89 0c 24             	mov    %ecx,(%esp)
  8014dd:	75 49                	jne    801528 <__udivdi3+0xb8>
  8014df:	8b 74 24 08          	mov    0x8(%esp),%esi
  8014e3:	39 74 24 04          	cmp    %esi,0x4(%esp)
  8014e7:	0f 86 ab 00 00 00    	jbe    801598 <__udivdi3+0x128>
  8014ed:	39 e8                	cmp    %ebp,%eax
  8014ef:	0f 82 a3 00 00 00    	jb     801598 <__udivdi3+0x128>
  8014f5:	8d 76 00             	lea    0x0(%esi),%esi
  8014f8:	31 d2                	xor    %edx,%edx
  8014fa:	31 c0                	xor    %eax,%eax
  8014fc:	8b 74 24 10          	mov    0x10(%esp),%esi
  801500:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801504:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801508:	83 c4 1c             	add    $0x1c,%esp
  80150b:	c3                   	ret    
  80150c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801510:	89 f8                	mov    %edi,%eax
  801512:	f7 f1                	div    %ecx
  801514:	31 d2                	xor    %edx,%edx
  801516:	8b 74 24 10          	mov    0x10(%esp),%esi
  80151a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80151e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801522:	83 c4 1c             	add    $0x1c,%esp
  801525:	c3                   	ret    
  801526:	66 90                	xchg   %ax,%ax
  801528:	0f b6 0c 24          	movzbl (%esp),%ecx
  80152c:	89 c6                	mov    %eax,%esi
  80152e:	b8 20 00 00 00       	mov    $0x20,%eax
  801533:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801537:	2b 04 24             	sub    (%esp),%eax
  80153a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80153e:	d3 e6                	shl    %cl,%esi
  801540:	89 c1                	mov    %eax,%ecx
  801542:	d3 ed                	shr    %cl,%ebp
  801544:	0f b6 0c 24          	movzbl (%esp),%ecx
  801548:	09 f5                	or     %esi,%ebp
  80154a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80154e:	d3 e6                	shl    %cl,%esi
  801550:	89 c1                	mov    %eax,%ecx
  801552:	89 74 24 04          	mov    %esi,0x4(%esp)
  801556:	89 d6                	mov    %edx,%esi
  801558:	d3 ee                	shr    %cl,%esi
  80155a:	0f b6 0c 24          	movzbl (%esp),%ecx
  80155e:	d3 e2                	shl    %cl,%edx
  801560:	89 c1                	mov    %eax,%ecx
  801562:	d3 ef                	shr    %cl,%edi
  801564:	09 d7                	or     %edx,%edi
  801566:	89 f2                	mov    %esi,%edx
  801568:	89 f8                	mov    %edi,%eax
  80156a:	f7 f5                	div    %ebp
  80156c:	89 d6                	mov    %edx,%esi
  80156e:	89 c7                	mov    %eax,%edi
  801570:	f7 64 24 04          	mull   0x4(%esp)
  801574:	39 d6                	cmp    %edx,%esi
  801576:	72 30                	jb     8015a8 <__udivdi3+0x138>
  801578:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  80157c:	0f b6 0c 24          	movzbl (%esp),%ecx
  801580:	d3 e5                	shl    %cl,%ebp
  801582:	39 c5                	cmp    %eax,%ebp
  801584:	73 04                	jae    80158a <__udivdi3+0x11a>
  801586:	39 d6                	cmp    %edx,%esi
  801588:	74 1e                	je     8015a8 <__udivdi3+0x138>
  80158a:	89 f8                	mov    %edi,%eax
  80158c:	31 d2                	xor    %edx,%edx
  80158e:	e9 69 ff ff ff       	jmp    8014fc <__udivdi3+0x8c>
  801593:	90                   	nop
  801594:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801598:	31 d2                	xor    %edx,%edx
  80159a:	b8 01 00 00 00       	mov    $0x1,%eax
  80159f:	e9 58 ff ff ff       	jmp    8014fc <__udivdi3+0x8c>
  8015a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015a8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8015ab:	31 d2                	xor    %edx,%edx
  8015ad:	8b 74 24 10          	mov    0x10(%esp),%esi
  8015b1:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8015b5:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8015b9:	83 c4 1c             	add    $0x1c,%esp
  8015bc:	c3                   	ret    
  8015bd:	66 90                	xchg   %ax,%ax
  8015bf:	90                   	nop

008015c0 <__umoddi3>:
  8015c0:	83 ec 2c             	sub    $0x2c,%esp
  8015c3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8015c7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8015cb:	89 74 24 20          	mov    %esi,0x20(%esp)
  8015cf:	8b 74 24 38          	mov    0x38(%esp),%esi
  8015d3:	89 7c 24 24          	mov    %edi,0x24(%esp)
  8015d7:	8b 7c 24 34          	mov    0x34(%esp),%edi
  8015db:	85 c0                	test   %eax,%eax
  8015dd:	89 c2                	mov    %eax,%edx
  8015df:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  8015e3:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8015e7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015eb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8015ef:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8015f3:	89 7c 24 18          	mov    %edi,0x18(%esp)
  8015f7:	75 1f                	jne    801618 <__umoddi3+0x58>
  8015f9:	39 fe                	cmp    %edi,%esi
  8015fb:	76 63                	jbe    801660 <__umoddi3+0xa0>
  8015fd:	89 c8                	mov    %ecx,%eax
  8015ff:	89 fa                	mov    %edi,%edx
  801601:	f7 f6                	div    %esi
  801603:	89 d0                	mov    %edx,%eax
  801605:	31 d2                	xor    %edx,%edx
  801607:	8b 74 24 20          	mov    0x20(%esp),%esi
  80160b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80160f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801613:	83 c4 2c             	add    $0x2c,%esp
  801616:	c3                   	ret    
  801617:	90                   	nop
  801618:	39 f8                	cmp    %edi,%eax
  80161a:	77 64                	ja     801680 <__umoddi3+0xc0>
  80161c:	0f bd e8             	bsr    %eax,%ebp
  80161f:	83 f5 1f             	xor    $0x1f,%ebp
  801622:	75 74                	jne    801698 <__umoddi3+0xd8>
  801624:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801628:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  80162c:	0f 87 0e 01 00 00    	ja     801740 <__umoddi3+0x180>
  801632:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801636:	29 f1                	sub    %esi,%ecx
  801638:	19 c7                	sbb    %eax,%edi
  80163a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80163e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801642:	8b 44 24 14          	mov    0x14(%esp),%eax
  801646:	8b 54 24 18          	mov    0x18(%esp),%edx
  80164a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80164e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801652:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801656:	83 c4 2c             	add    $0x2c,%esp
  801659:	c3                   	ret    
  80165a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801660:	85 f6                	test   %esi,%esi
  801662:	89 f5                	mov    %esi,%ebp
  801664:	75 0b                	jne    801671 <__umoddi3+0xb1>
  801666:	b8 01 00 00 00       	mov    $0x1,%eax
  80166b:	31 d2                	xor    %edx,%edx
  80166d:	f7 f6                	div    %esi
  80166f:	89 c5                	mov    %eax,%ebp
  801671:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801675:	31 d2                	xor    %edx,%edx
  801677:	f7 f5                	div    %ebp
  801679:	89 c8                	mov    %ecx,%eax
  80167b:	f7 f5                	div    %ebp
  80167d:	eb 84                	jmp    801603 <__umoddi3+0x43>
  80167f:	90                   	nop
  801680:	89 c8                	mov    %ecx,%eax
  801682:	89 fa                	mov    %edi,%edx
  801684:	8b 74 24 20          	mov    0x20(%esp),%esi
  801688:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80168c:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801690:	83 c4 2c             	add    $0x2c,%esp
  801693:	c3                   	ret    
  801694:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801698:	8b 44 24 10          	mov    0x10(%esp),%eax
  80169c:	be 20 00 00 00       	mov    $0x20,%esi
  8016a1:	89 e9                	mov    %ebp,%ecx
  8016a3:	29 ee                	sub    %ebp,%esi
  8016a5:	d3 e2                	shl    %cl,%edx
  8016a7:	89 f1                	mov    %esi,%ecx
  8016a9:	d3 e8                	shr    %cl,%eax
  8016ab:	89 e9                	mov    %ebp,%ecx
  8016ad:	09 d0                	or     %edx,%eax
  8016af:	89 fa                	mov    %edi,%edx
  8016b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016b5:	8b 44 24 10          	mov    0x10(%esp),%eax
  8016b9:	d3 e0                	shl    %cl,%eax
  8016bb:	89 f1                	mov    %esi,%ecx
  8016bd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016c1:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8016c5:	d3 ea                	shr    %cl,%edx
  8016c7:	89 e9                	mov    %ebp,%ecx
  8016c9:	d3 e7                	shl    %cl,%edi
  8016cb:	89 f1                	mov    %esi,%ecx
  8016cd:	d3 e8                	shr    %cl,%eax
  8016cf:	89 e9                	mov    %ebp,%ecx
  8016d1:	09 f8                	or     %edi,%eax
  8016d3:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8016d7:	f7 74 24 0c          	divl   0xc(%esp)
  8016db:	d3 e7                	shl    %cl,%edi
  8016dd:	89 7c 24 18          	mov    %edi,0x18(%esp)
  8016e1:	89 d7                	mov    %edx,%edi
  8016e3:	f7 64 24 10          	mull   0x10(%esp)
  8016e7:	39 d7                	cmp    %edx,%edi
  8016e9:	89 c1                	mov    %eax,%ecx
  8016eb:	89 54 24 14          	mov    %edx,0x14(%esp)
  8016ef:	72 3b                	jb     80172c <__umoddi3+0x16c>
  8016f1:	39 44 24 18          	cmp    %eax,0x18(%esp)
  8016f5:	72 31                	jb     801728 <__umoddi3+0x168>
  8016f7:	8b 44 24 18          	mov    0x18(%esp),%eax
  8016fb:	29 c8                	sub    %ecx,%eax
  8016fd:	19 d7                	sbb    %edx,%edi
  8016ff:	89 e9                	mov    %ebp,%ecx
  801701:	89 fa                	mov    %edi,%edx
  801703:	d3 e8                	shr    %cl,%eax
  801705:	89 f1                	mov    %esi,%ecx
  801707:	d3 e2                	shl    %cl,%edx
  801709:	89 e9                	mov    %ebp,%ecx
  80170b:	09 d0                	or     %edx,%eax
  80170d:	89 fa                	mov    %edi,%edx
  80170f:	d3 ea                	shr    %cl,%edx
  801711:	8b 74 24 20          	mov    0x20(%esp),%esi
  801715:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801719:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  80171d:	83 c4 2c             	add    $0x2c,%esp
  801720:	c3                   	ret    
  801721:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801728:	39 d7                	cmp    %edx,%edi
  80172a:	75 cb                	jne    8016f7 <__umoddi3+0x137>
  80172c:	8b 54 24 14          	mov    0x14(%esp),%edx
  801730:	89 c1                	mov    %eax,%ecx
  801732:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801736:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  80173a:	eb bb                	jmp    8016f7 <__umoddi3+0x137>
  80173c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801740:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801744:	0f 82 e8 fe ff ff    	jb     801632 <__umoddi3+0x72>
  80174a:	e9 f3 fe ff ff       	jmp    801642 <__umoddi3+0x82>
