
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 37 00 00 00       	call   800068 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	zero = 0;
  80003a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	b8 01 00 00 00       	mov    $0x1,%eax
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	89 c2                	mov    %eax,%edx
  800050:	c1 fa 1f             	sar    $0x1f,%edx
  800053:	f7 f9                	idiv   %ecx
  800055:	89 44 24 04          	mov    %eax,0x4(%esp)
  800059:	c7 04 24 c0 12 80 00 	movl   $0x8012c0,(%esp)
  800060:	e8 16 01 00 00       	call   80017b <cprintf>
}
  800065:	c9                   	leave  
  800066:	c3                   	ret    
  800067:	90                   	nop

00800068 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	83 ec 18             	sub    $0x18,%esp
  80006e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800071:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800074:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800077:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80007a:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800081:	00 00 00 
	int envid;
	envid = sys_getenvid();
  800084:	e8 33 0c 00 00       	call   800cbc <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800089:	25 ff 03 00 00       	and    $0x3ff,%eax
  80008e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800091:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800096:	a3 08 20 80 00       	mov    %eax,0x802008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009b:	85 db                	test   %ebx,%ebx
  80009d:	7e 07                	jle    8000a6 <libmain+0x3e>
		binaryname = argv[0];
  80009f:	8b 06                	mov    (%esi),%eax
  8000a1:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000aa:	89 1c 24             	mov    %ebx,(%esp)
  8000ad:	e8 82 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000b2:	e8 0d 00 00 00       	call   8000c4 <exit>
}
  8000b7:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000ba:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000bd:	89 ec                	mov    %ebp,%esp
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    
  8000c1:	66 90                	xchg   %ax,%ax
  8000c3:	90                   	nop

008000c4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000d1:	e8 89 0b 00 00       	call   800c5f <sys_env_destroy>
}
  8000d6:	c9                   	leave  
  8000d7:	c3                   	ret    

008000d8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 14             	sub    $0x14,%esp
  8000df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000e2:	8b 03                	mov    (%ebx),%eax
  8000e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000eb:	83 c0 01             	add    $0x1,%eax
  8000ee:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000f0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f5:	75 19                	jne    800110 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000f7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000fe:	00 
  8000ff:	8d 43 08             	lea    0x8(%ebx),%eax
  800102:	89 04 24             	mov    %eax,(%esp)
  800105:	e8 f6 0a 00 00       	call   800c00 <sys_cputs>
		b->idx = 0;
  80010a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800110:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800114:	83 c4 14             	add    $0x14,%esp
  800117:	5b                   	pop    %ebx
  800118:	5d                   	pop    %ebp
  800119:	c3                   	ret    

0080011a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800123:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80012a:	00 00 00 
	b.cnt = 0;
  80012d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800134:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800137:	8b 45 0c             	mov    0xc(%ebp),%eax
  80013a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80013e:	8b 45 08             	mov    0x8(%ebp),%eax
  800141:	89 44 24 08          	mov    %eax,0x8(%esp)
  800145:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014f:	c7 04 24 d8 00 80 00 	movl   $0x8000d8,(%esp)
  800156:	e8 b7 01 00 00       	call   800312 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80015b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800161:	89 44 24 04          	mov    %eax,0x4(%esp)
  800165:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80016b:	89 04 24             	mov    %eax,(%esp)
  80016e:	e8 8d 0a 00 00       	call   800c00 <sys_cputs>

	return b.cnt;
}
  800173:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800179:	c9                   	leave  
  80017a:	c3                   	ret    

0080017b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80017b:	55                   	push   %ebp
  80017c:	89 e5                	mov    %esp,%ebp
  80017e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800181:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800184:	89 44 24 04          	mov    %eax,0x4(%esp)
  800188:	8b 45 08             	mov    0x8(%ebp),%eax
  80018b:	89 04 24             	mov    %eax,(%esp)
  80018e:	e8 87 ff ff ff       	call   80011a <vcprintf>
	va_end(ap);

	return cnt;
}
  800193:	c9                   	leave  
  800194:	c3                   	ret    
  800195:	66 90                	xchg   %ax,%ax
  800197:	66 90                	xchg   %ax,%ax
  800199:	66 90                	xchg   %ax,%ax
  80019b:	66 90                	xchg   %ax,%ax
  80019d:	66 90                	xchg   %ax,%ax
  80019f:	90                   	nop

008001a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	57                   	push   %edi
  8001a4:	56                   	push   %esi
  8001a5:	53                   	push   %ebx
  8001a6:	83 ec 4c             	sub    $0x4c,%esp
  8001a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001ac:	89 d7                	mov    %edx,%edi
  8001ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001b1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8001b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001b7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8001bf:	39 d8                	cmp    %ebx,%eax
  8001c1:	72 17                	jb     8001da <printnum+0x3a>
  8001c3:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8001c6:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  8001c9:	76 0f                	jbe    8001da <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001cb:	8b 75 14             	mov    0x14(%ebp),%esi
  8001ce:	83 ee 01             	sub    $0x1,%esi
  8001d1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8001d4:	85 f6                	test   %esi,%esi
  8001d6:	7f 63                	jg     80023b <printnum+0x9b>
  8001d8:	eb 75                	jmp    80024f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001da:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8001dd:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8001e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e4:	83 e8 01             	sub    $0x1,%eax
  8001e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f2:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001f6:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001fd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800200:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800207:	00 
  800208:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80020b:	89 1c 24             	mov    %ebx,(%esp)
  80020e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800211:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800215:	e8 c6 0d 00 00       	call   800fe0 <__udivdi3>
  80021a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80021d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800220:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800224:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800228:	89 04 24             	mov    %eax,(%esp)
  80022b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80022f:	89 fa                	mov    %edi,%edx
  800231:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800234:	e8 67 ff ff ff       	call   8001a0 <printnum>
  800239:	eb 14                	jmp    80024f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80023b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80023f:	8b 45 18             	mov    0x18(%ebp),%eax
  800242:	89 04 24             	mov    %eax,(%esp)
  800245:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800247:	83 ee 01             	sub    $0x1,%esi
  80024a:	75 ef                	jne    80023b <printnum+0x9b>
  80024c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800253:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800257:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80025a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80025e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800265:	00 
  800266:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800269:	89 1c 24             	mov    %ebx,(%esp)
  80026c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80026f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800273:	e8 b8 0e 00 00       	call   801130 <__umoddi3>
  800278:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80027c:	0f be 80 d8 12 80 00 	movsbl 0x8012d8(%eax),%eax
  800283:	89 04 24             	mov    %eax,(%esp)
  800286:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800289:	ff d0                	call   *%eax
}
  80028b:	83 c4 4c             	add    $0x4c,%esp
  80028e:	5b                   	pop    %ebx
  80028f:	5e                   	pop    %esi
  800290:	5f                   	pop    %edi
  800291:	5d                   	pop    %ebp
  800292:	c3                   	ret    

00800293 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800296:	83 fa 01             	cmp    $0x1,%edx
  800299:	7e 0e                	jle    8002a9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80029b:	8b 10                	mov    (%eax),%edx
  80029d:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a0:	89 08                	mov    %ecx,(%eax)
  8002a2:	8b 02                	mov    (%edx),%eax
  8002a4:	8b 52 04             	mov    0x4(%edx),%edx
  8002a7:	eb 22                	jmp    8002cb <getuint+0x38>
	else if (lflag)
  8002a9:	85 d2                	test   %edx,%edx
  8002ab:	74 10                	je     8002bd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ad:	8b 10                	mov    (%eax),%edx
  8002af:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b2:	89 08                	mov    %ecx,(%eax)
  8002b4:	8b 02                	mov    (%edx),%eax
  8002b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002bb:	eb 0e                	jmp    8002cb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002bd:	8b 10                	mov    (%eax),%edx
  8002bf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c2:	89 08                	mov    %ecx,(%eax)
  8002c4:	8b 02                	mov    (%edx),%eax
  8002c6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    

008002cd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d7:	8b 10                	mov    (%eax),%edx
  8002d9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002dc:	73 0a                	jae    8002e8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e1:	88 0a                	mov    %cl,(%edx)
  8002e3:	83 c2 01             	add    $0x1,%edx
  8002e6:	89 10                	mov    %edx,(%eax)
}
  8002e8:	5d                   	pop    %ebp
  8002e9:	c3                   	ret    

008002ea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800301:	89 44 24 04          	mov    %eax,0x4(%esp)
  800305:	8b 45 08             	mov    0x8(%ebp),%eax
  800308:	89 04 24             	mov    %eax,(%esp)
  80030b:	e8 02 00 00 00       	call   800312 <vprintfmt>
	va_end(ap);
}
  800310:	c9                   	leave  
  800311:	c3                   	ret    

00800312 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	57                   	push   %edi
  800316:	56                   	push   %esi
  800317:	53                   	push   %ebx
  800318:	83 ec 4c             	sub    $0x4c,%esp
  80031b:	8b 75 08             	mov    0x8(%ebp),%esi
  80031e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800321:	8b 7d 10             	mov    0x10(%ebp),%edi
  800324:	eb 11                	jmp    800337 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800326:	85 c0                	test   %eax,%eax
  800328:	0f 84 db 03 00 00    	je     800709 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  80032e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800332:	89 04 24             	mov    %eax,(%esp)
  800335:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800337:	0f b6 07             	movzbl (%edi),%eax
  80033a:	83 c7 01             	add    $0x1,%edi
  80033d:	83 f8 25             	cmp    $0x25,%eax
  800340:	75 e4                	jne    800326 <vprintfmt+0x14>
  800342:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800346:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80034d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800354:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80035b:	ba 00 00 00 00       	mov    $0x0,%edx
  800360:	eb 2b                	jmp    80038d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800362:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800365:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800369:	eb 22                	jmp    80038d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80036e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  800372:	eb 19                	jmp    80038d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800374:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800377:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80037e:	eb 0d                	jmp    80038d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800380:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800383:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800386:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038d:	0f b6 0f             	movzbl (%edi),%ecx
  800390:	8d 47 01             	lea    0x1(%edi),%eax
  800393:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800396:	0f b6 07             	movzbl (%edi),%eax
  800399:	83 e8 23             	sub    $0x23,%eax
  80039c:	3c 55                	cmp    $0x55,%al
  80039e:	0f 87 40 03 00 00    	ja     8006e4 <vprintfmt+0x3d2>
  8003a4:	0f b6 c0             	movzbl %al,%eax
  8003a7:	ff 24 85 a0 13 80 00 	jmp    *0x8013a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ae:	83 e9 30             	sub    $0x30,%ecx
  8003b1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  8003b4:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  8003b8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003bb:	83 f9 09             	cmp    $0x9,%ecx
  8003be:	77 57                	ja     800417 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c0:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8003c3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003c6:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003cc:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003cf:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003d3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8003d6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003d9:	83 f9 09             	cmp    $0x9,%ecx
  8003dc:	76 eb                	jbe    8003c9 <vprintfmt+0xb7>
  8003de:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003e1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003e4:	eb 34                	jmp    80041a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e9:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ec:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ef:	8b 00                	mov    (%eax),%eax
  8003f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f7:	eb 21                	jmp    80041a <vprintfmt+0x108>

		case '.':
			if (width < 0)
  8003f9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003fd:	0f 88 71 ff ff ff    	js     800374 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800403:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800406:	eb 85                	jmp    80038d <vprintfmt+0x7b>
  800408:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80040b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800412:	e9 76 ff ff ff       	jmp    80038d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800417:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80041a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80041e:	0f 89 69 ff ff ff    	jns    80038d <vprintfmt+0x7b>
  800424:	e9 57 ff ff ff       	jmp    800380 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800429:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80042f:	e9 59 ff ff ff       	jmp    80038d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800434:	8b 45 14             	mov    0x14(%ebp),%eax
  800437:	8d 50 04             	lea    0x4(%eax),%edx
  80043a:	89 55 14             	mov    %edx,0x14(%ebp)
  80043d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800441:	8b 00                	mov    (%eax),%eax
  800443:	89 04 24             	mov    %eax,(%esp)
  800446:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800448:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80044b:	e9 e7 fe ff ff       	jmp    800337 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8d 50 04             	lea    0x4(%eax),%edx
  800456:	89 55 14             	mov    %edx,0x14(%ebp)
  800459:	8b 00                	mov    (%eax),%eax
  80045b:	89 c2                	mov    %eax,%edx
  80045d:	c1 fa 1f             	sar    $0x1f,%edx
  800460:	31 d0                	xor    %edx,%eax
  800462:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800464:	83 f8 08             	cmp    $0x8,%eax
  800467:	7f 0b                	jg     800474 <vprintfmt+0x162>
  800469:	8b 14 85 00 15 80 00 	mov    0x801500(,%eax,4),%edx
  800470:	85 d2                	test   %edx,%edx
  800472:	75 20                	jne    800494 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800474:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800478:	c7 44 24 08 f0 12 80 	movl   $0x8012f0,0x8(%esp)
  80047f:	00 
  800480:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800484:	89 34 24             	mov    %esi,(%esp)
  800487:	e8 5e fe ff ff       	call   8002ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80048f:	e9 a3 fe ff ff       	jmp    800337 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800494:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800498:	c7 44 24 08 f9 12 80 	movl   $0x8012f9,0x8(%esp)
  80049f:	00 
  8004a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a4:	89 34 24             	mov    %esi,(%esp)
  8004a7:	e8 3e fe ff ff       	call   8002ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ac:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004af:	e9 83 fe ff ff       	jmp    800337 <vprintfmt+0x25>
  8004b4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004b7:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8004ba:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c0:	8d 50 04             	lea    0x4(%eax),%edx
  8004c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004c8:	85 ff                	test   %edi,%edi
  8004ca:	b8 e9 12 80 00       	mov    $0x8012e9,%eax
  8004cf:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004d2:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  8004d6:	74 06                	je     8004de <vprintfmt+0x1cc>
  8004d8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004dc:	7f 16                	jg     8004f4 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004de:	0f b6 17             	movzbl (%edi),%edx
  8004e1:	0f be c2             	movsbl %dl,%eax
  8004e4:	83 c7 01             	add    $0x1,%edi
  8004e7:	85 c0                	test   %eax,%eax
  8004e9:	0f 85 9f 00 00 00    	jne    80058e <vprintfmt+0x27c>
  8004ef:	e9 8b 00 00 00       	jmp    80057f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004f8:	89 3c 24             	mov    %edi,(%esp)
  8004fb:	e8 c2 02 00 00       	call   8007c2 <strnlen>
  800500:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800503:	29 c2                	sub    %eax,%edx
  800505:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800508:	85 d2                	test   %edx,%edx
  80050a:	7e d2                	jle    8004de <vprintfmt+0x1cc>
					putch(padc, putdat);
  80050c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  800510:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800513:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800516:	89 d7                	mov    %edx,%edi
  800518:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80051f:	89 04 24             	mov    %eax,(%esp)
  800522:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800524:	83 ef 01             	sub    $0x1,%edi
  800527:	75 ef                	jne    800518 <vprintfmt+0x206>
  800529:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80052c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80052f:	eb ad                	jmp    8004de <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800531:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800535:	74 20                	je     800557 <vprintfmt+0x245>
  800537:	0f be d2             	movsbl %dl,%edx
  80053a:	83 ea 20             	sub    $0x20,%edx
  80053d:	83 fa 5e             	cmp    $0x5e,%edx
  800540:	76 15                	jbe    800557 <vprintfmt+0x245>
					putch('?', putdat);
  800542:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800545:	89 54 24 04          	mov    %edx,0x4(%esp)
  800549:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800550:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800553:	ff d1                	call   *%ecx
  800555:	eb 0f                	jmp    800566 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800557:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80055a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80055e:	89 04 24             	mov    %eax,(%esp)
  800561:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800564:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800566:	83 eb 01             	sub    $0x1,%ebx
  800569:	0f b6 17             	movzbl (%edi),%edx
  80056c:	0f be c2             	movsbl %dl,%eax
  80056f:	83 c7 01             	add    $0x1,%edi
  800572:	85 c0                	test   %eax,%eax
  800574:	75 24                	jne    80059a <vprintfmt+0x288>
  800576:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800579:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80057c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800582:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800586:	0f 8e ab fd ff ff    	jle    800337 <vprintfmt+0x25>
  80058c:	eb 20                	jmp    8005ae <vprintfmt+0x29c>
  80058e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800591:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800594:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800597:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059a:	85 f6                	test   %esi,%esi
  80059c:	78 93                	js     800531 <vprintfmt+0x21f>
  80059e:	83 ee 01             	sub    $0x1,%esi
  8005a1:	79 8e                	jns    800531 <vprintfmt+0x21f>
  8005a3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8005a6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005a9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005ac:	eb d1                	jmp    80057f <vprintfmt+0x26d>
  8005ae:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005bc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005be:	83 ef 01             	sub    $0x1,%edi
  8005c1:	75 ee                	jne    8005b1 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005c6:	e9 6c fd ff ff       	jmp    800337 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005cb:	83 fa 01             	cmp    $0x1,%edx
  8005ce:	66 90                	xchg   %ax,%ax
  8005d0:	7e 16                	jle    8005e8 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8d 50 08             	lea    0x8(%eax),%edx
  8005d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005db:	8b 10                	mov    (%eax),%edx
  8005dd:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005e3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005e6:	eb 32                	jmp    80061a <vprintfmt+0x308>
	else if (lflag)
  8005e8:	85 d2                	test   %edx,%edx
  8005ea:	74 18                	je     800604 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8d 50 04             	lea    0x4(%eax),%edx
  8005f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f5:	8b 00                	mov    (%eax),%eax
  8005f7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005fa:	89 c1                	mov    %eax,%ecx
  8005fc:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ff:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800602:	eb 16                	jmp    80061a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8d 50 04             	lea    0x4(%eax),%edx
  80060a:	89 55 14             	mov    %edx,0x14(%ebp)
  80060d:	8b 00                	mov    (%eax),%eax
  80060f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800612:	89 c7                	mov    %eax,%edi
  800614:	c1 ff 1f             	sar    $0x1f,%edi
  800617:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80061d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800620:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800625:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800629:	79 7d                	jns    8006a8 <vprintfmt+0x396>
				putch('-', putdat);
  80062b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800636:	ff d6                	call   *%esi
				num = -(long long) num;
  800638:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80063b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80063e:	f7 d8                	neg    %eax
  800640:	83 d2 00             	adc    $0x0,%edx
  800643:	f7 da                	neg    %edx
			}
			base = 10;
  800645:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80064a:	eb 5c                	jmp    8006a8 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80064c:	8d 45 14             	lea    0x14(%ebp),%eax
  80064f:	e8 3f fc ff ff       	call   800293 <getuint>
			base = 10;
  800654:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800659:	eb 4d                	jmp    8006a8 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80065b:	8d 45 14             	lea    0x14(%ebp),%eax
  80065e:	e8 30 fc ff ff       	call   800293 <getuint>
			base = 8;
  800663:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800668:	eb 3e                	jmp    8006a8 <vprintfmt+0x396>

		// pointer
		case 'p':
			putch('0', putdat);
  80066a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800675:	ff d6                	call   *%esi
			putch('x', putdat);
  800677:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800682:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8d 50 04             	lea    0x4(%eax),%edx
  80068a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80068d:	8b 00                	mov    (%eax),%eax
  80068f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800694:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800699:	eb 0d                	jmp    8006a8 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80069b:	8d 45 14             	lea    0x14(%ebp),%eax
  80069e:	e8 f0 fb ff ff       	call   800293 <getuint>
			base = 16;
  8006a3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a8:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  8006ac:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8006b0:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8006b3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8006b7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006bb:	89 04 24             	mov    %eax,(%esp)
  8006be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006c2:	89 da                	mov    %ebx,%edx
  8006c4:	89 f0                	mov    %esi,%eax
  8006c6:	e8 d5 fa ff ff       	call   8001a0 <printnum>
			break;
  8006cb:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006ce:	e9 64 fc ff ff       	jmp    800337 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d7:	89 0c 24             	mov    %ecx,(%esp)
  8006da:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006dc:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006df:	e9 53 fc ff ff       	jmp    800337 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006ef:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006f5:	0f 84 3c fc ff ff    	je     800337 <vprintfmt+0x25>
  8006fb:	83 ef 01             	sub    $0x1,%edi
  8006fe:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800702:	75 f7                	jne    8006fb <vprintfmt+0x3e9>
  800704:	e9 2e fc ff ff       	jmp    800337 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800709:	83 c4 4c             	add    $0x4c,%esp
  80070c:	5b                   	pop    %ebx
  80070d:	5e                   	pop    %esi
  80070e:	5f                   	pop    %edi
  80070f:	5d                   	pop    %ebp
  800710:	c3                   	ret    

00800711 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	83 ec 28             	sub    $0x28,%esp
  800717:	8b 45 08             	mov    0x8(%ebp),%eax
  80071a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80071d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800720:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800724:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800727:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80072e:	85 d2                	test   %edx,%edx
  800730:	7e 30                	jle    800762 <vsnprintf+0x51>
  800732:	85 c0                	test   %eax,%eax
  800734:	74 2c                	je     800762 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800736:	8b 45 14             	mov    0x14(%ebp),%eax
  800739:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80073d:	8b 45 10             	mov    0x10(%ebp),%eax
  800740:	89 44 24 08          	mov    %eax,0x8(%esp)
  800744:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800747:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074b:	c7 04 24 cd 02 80 00 	movl   $0x8002cd,(%esp)
  800752:	e8 bb fb ff ff       	call   800312 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800757:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80075a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80075d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800760:	eb 05                	jmp    800767 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800762:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800767:	c9                   	leave  
  800768:	c3                   	ret    

00800769 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800769:	55                   	push   %ebp
  80076a:	89 e5                	mov    %esp,%ebp
  80076c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800772:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800776:	8b 45 10             	mov    0x10(%ebp),%eax
  800779:	89 44 24 08          	mov    %eax,0x8(%esp)
  80077d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800780:	89 44 24 04          	mov    %eax,0x4(%esp)
  800784:	8b 45 08             	mov    0x8(%ebp),%eax
  800787:	89 04 24             	mov    %eax,(%esp)
  80078a:	e8 82 ff ff ff       	call   800711 <vsnprintf>
	va_end(ap);

	return rc;
}
  80078f:	c9                   	leave  
  800790:	c3                   	ret    
  800791:	66 90                	xchg   %ax,%ax
  800793:	66 90                	xchg   %ax,%ax
  800795:	66 90                	xchg   %ax,%ax
  800797:	66 90                	xchg   %ax,%ax
  800799:	66 90                	xchg   %ax,%ax
  80079b:	66 90                	xchg   %ax,%ax
  80079d:	66 90                	xchg   %ax,%ax
  80079f:	90                   	nop

008007a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a6:	80 3a 00             	cmpb   $0x0,(%edx)
  8007a9:	74 10                	je     8007bb <strlen+0x1b>
  8007ab:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007b0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b7:	75 f7                	jne    8007b0 <strlen+0x10>
  8007b9:	eb 05                	jmp    8007c0 <strlen+0x20>
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	53                   	push   %ebx
  8007c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cc:	85 c9                	test   %ecx,%ecx
  8007ce:	74 1c                	je     8007ec <strnlen+0x2a>
  8007d0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007d3:	74 1e                	je     8007f3 <strnlen+0x31>
  8007d5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8007da:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007dc:	39 ca                	cmp    %ecx,%edx
  8007de:	74 18                	je     8007f8 <strnlen+0x36>
  8007e0:	83 c2 01             	add    $0x1,%edx
  8007e3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8007e8:	75 f0                	jne    8007da <strnlen+0x18>
  8007ea:	eb 0c                	jmp    8007f8 <strnlen+0x36>
  8007ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f1:	eb 05                	jmp    8007f8 <strnlen+0x36>
  8007f3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007f8:	5b                   	pop    %ebx
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800802:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800805:	89 c2                	mov    %eax,%edx
  800807:	0f b6 19             	movzbl (%ecx),%ebx
  80080a:	88 1a                	mov    %bl,(%edx)
  80080c:	83 c2 01             	add    $0x1,%edx
  80080f:	83 c1 01             	add    $0x1,%ecx
  800812:	84 db                	test   %bl,%bl
  800814:	75 f1                	jne    800807 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800816:	5b                   	pop    %ebx
  800817:	5d                   	pop    %ebp
  800818:	c3                   	ret    

00800819 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	53                   	push   %ebx
  80081d:	83 ec 08             	sub    $0x8,%esp
  800820:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800823:	89 1c 24             	mov    %ebx,(%esp)
  800826:	e8 75 ff ff ff       	call   8007a0 <strlen>
	strcpy(dst + len, src);
  80082b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800832:	01 d8                	add    %ebx,%eax
  800834:	89 04 24             	mov    %eax,(%esp)
  800837:	e8 bf ff ff ff       	call   8007fb <strcpy>
	return dst;
}
  80083c:	89 d8                	mov    %ebx,%eax
  80083e:	83 c4 08             	add    $0x8,%esp
  800841:	5b                   	pop    %ebx
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	56                   	push   %esi
  800848:	53                   	push   %ebx
  800849:	8b 75 08             	mov    0x8(%ebp),%esi
  80084c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800852:	85 db                	test   %ebx,%ebx
  800854:	74 16                	je     80086c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800856:	01 f3                	add    %esi,%ebx
  800858:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80085a:	0f b6 02             	movzbl (%edx),%eax
  80085d:	88 01                	mov    %al,(%ecx)
  80085f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800862:	80 3a 01             	cmpb   $0x1,(%edx)
  800865:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800868:	39 d9                	cmp    %ebx,%ecx
  80086a:	75 ee                	jne    80085a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80086c:	89 f0                	mov    %esi,%eax
  80086e:	5b                   	pop    %ebx
  80086f:	5e                   	pop    %esi
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	57                   	push   %edi
  800876:	56                   	push   %esi
  800877:	53                   	push   %ebx
  800878:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80087e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800881:	89 f8                	mov    %edi,%eax
  800883:	85 f6                	test   %esi,%esi
  800885:	74 33                	je     8008ba <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800887:	83 fe 01             	cmp    $0x1,%esi
  80088a:	74 25                	je     8008b1 <strlcpy+0x3f>
  80088c:	0f b6 0b             	movzbl (%ebx),%ecx
  80088f:	84 c9                	test   %cl,%cl
  800891:	74 22                	je     8008b5 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800893:	83 ee 02             	sub    $0x2,%esi
  800896:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089b:	88 08                	mov    %cl,(%eax)
  80089d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a0:	39 f2                	cmp    %esi,%edx
  8008a2:	74 13                	je     8008b7 <strlcpy+0x45>
  8008a4:	83 c2 01             	add    $0x1,%edx
  8008a7:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008ab:	84 c9                	test   %cl,%cl
  8008ad:	75 ec                	jne    80089b <strlcpy+0x29>
  8008af:	eb 06                	jmp    8008b7 <strlcpy+0x45>
  8008b1:	89 f8                	mov    %edi,%eax
  8008b3:	eb 02                	jmp    8008b7 <strlcpy+0x45>
  8008b5:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008b7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ba:	29 f8                	sub    %edi,%eax
}
  8008bc:	5b                   	pop    %ebx
  8008bd:	5e                   	pop    %esi
  8008be:	5f                   	pop    %edi
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ca:	0f b6 01             	movzbl (%ecx),%eax
  8008cd:	84 c0                	test   %al,%al
  8008cf:	74 15                	je     8008e6 <strcmp+0x25>
  8008d1:	3a 02                	cmp    (%edx),%al
  8008d3:	75 11                	jne    8008e6 <strcmp+0x25>
		p++, q++;
  8008d5:	83 c1 01             	add    $0x1,%ecx
  8008d8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008db:	0f b6 01             	movzbl (%ecx),%eax
  8008de:	84 c0                	test   %al,%al
  8008e0:	74 04                	je     8008e6 <strcmp+0x25>
  8008e2:	3a 02                	cmp    (%edx),%al
  8008e4:	74 ef                	je     8008d5 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e6:	0f b6 c0             	movzbl %al,%eax
  8008e9:	0f b6 12             	movzbl (%edx),%edx
  8008ec:	29 d0                	sub    %edx,%eax
}
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	56                   	push   %esi
  8008f4:	53                   	push   %ebx
  8008f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fb:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8008fe:	85 f6                	test   %esi,%esi
  800900:	74 29                	je     80092b <strncmp+0x3b>
  800902:	0f b6 03             	movzbl (%ebx),%eax
  800905:	84 c0                	test   %al,%al
  800907:	74 30                	je     800939 <strncmp+0x49>
  800909:	3a 02                	cmp    (%edx),%al
  80090b:	75 2c                	jne    800939 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  80090d:	8d 43 01             	lea    0x1(%ebx),%eax
  800910:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800912:	89 c3                	mov    %eax,%ebx
  800914:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800917:	39 f0                	cmp    %esi,%eax
  800919:	74 17                	je     800932 <strncmp+0x42>
  80091b:	0f b6 08             	movzbl (%eax),%ecx
  80091e:	84 c9                	test   %cl,%cl
  800920:	74 17                	je     800939 <strncmp+0x49>
  800922:	83 c0 01             	add    $0x1,%eax
  800925:	3a 0a                	cmp    (%edx),%cl
  800927:	74 e9                	je     800912 <strncmp+0x22>
  800929:	eb 0e                	jmp    800939 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80092b:	b8 00 00 00 00       	mov    $0x0,%eax
  800930:	eb 0f                	jmp    800941 <strncmp+0x51>
  800932:	b8 00 00 00 00       	mov    $0x0,%eax
  800937:	eb 08                	jmp    800941 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800939:	0f b6 03             	movzbl (%ebx),%eax
  80093c:	0f b6 12             	movzbl (%edx),%edx
  80093f:	29 d0                	sub    %edx,%eax
}
  800941:	5b                   	pop    %ebx
  800942:	5e                   	pop    %esi
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	53                   	push   %ebx
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  80094f:	0f b6 18             	movzbl (%eax),%ebx
  800952:	84 db                	test   %bl,%bl
  800954:	74 1d                	je     800973 <strchr+0x2e>
  800956:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800958:	38 d3                	cmp    %dl,%bl
  80095a:	75 06                	jne    800962 <strchr+0x1d>
  80095c:	eb 1a                	jmp    800978 <strchr+0x33>
  80095e:	38 ca                	cmp    %cl,%dl
  800960:	74 16                	je     800978 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800962:	83 c0 01             	add    $0x1,%eax
  800965:	0f b6 10             	movzbl (%eax),%edx
  800968:	84 d2                	test   %dl,%dl
  80096a:	75 f2                	jne    80095e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  80096c:	b8 00 00 00 00       	mov    $0x0,%eax
  800971:	eb 05                	jmp    800978 <strchr+0x33>
  800973:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800978:	5b                   	pop    %ebx
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	53                   	push   %ebx
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
  800982:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800985:	0f b6 18             	movzbl (%eax),%ebx
  800988:	84 db                	test   %bl,%bl
  80098a:	74 16                	je     8009a2 <strfind+0x27>
  80098c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  80098e:	38 d3                	cmp    %dl,%bl
  800990:	75 06                	jne    800998 <strfind+0x1d>
  800992:	eb 0e                	jmp    8009a2 <strfind+0x27>
  800994:	38 ca                	cmp    %cl,%dl
  800996:	74 0a                	je     8009a2 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800998:	83 c0 01             	add    $0x1,%eax
  80099b:	0f b6 10             	movzbl (%eax),%edx
  80099e:	84 d2                	test   %dl,%dl
  8009a0:	75 f2                	jne    800994 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  8009a2:	5b                   	pop    %ebx
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	83 ec 0c             	sub    $0xc,%esp
  8009ab:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8009ae:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8009b1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8009b4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009ba:	85 c9                	test   %ecx,%ecx
  8009bc:	74 36                	je     8009f4 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009be:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009c4:	75 28                	jne    8009ee <memset+0x49>
  8009c6:	f6 c1 03             	test   $0x3,%cl
  8009c9:	75 23                	jne    8009ee <memset+0x49>
		c &= 0xFF;
  8009cb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009cf:	89 d3                	mov    %edx,%ebx
  8009d1:	c1 e3 08             	shl    $0x8,%ebx
  8009d4:	89 d6                	mov    %edx,%esi
  8009d6:	c1 e6 18             	shl    $0x18,%esi
  8009d9:	89 d0                	mov    %edx,%eax
  8009db:	c1 e0 10             	shl    $0x10,%eax
  8009de:	09 f0                	or     %esi,%eax
  8009e0:	09 c2                	or     %eax,%edx
  8009e2:	89 d0                	mov    %edx,%eax
  8009e4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009e6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009e9:	fc                   	cld    
  8009ea:	f3 ab                	rep stos %eax,%es:(%edi)
  8009ec:	eb 06                	jmp    8009f4 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f1:	fc                   	cld    
  8009f2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009f4:	89 f8                	mov    %edi,%eax
  8009f6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8009f9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8009fc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8009ff:	89 ec                	mov    %ebp,%esp
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	83 ec 08             	sub    $0x8,%esp
  800a09:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a0c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a15:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a18:	39 c6                	cmp    %eax,%esi
  800a1a:	73 36                	jae    800a52 <memmove+0x4f>
  800a1c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a1f:	39 d0                	cmp    %edx,%eax
  800a21:	73 2f                	jae    800a52 <memmove+0x4f>
		s += n;
		d += n;
  800a23:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a26:	f6 c2 03             	test   $0x3,%dl
  800a29:	75 1b                	jne    800a46 <memmove+0x43>
  800a2b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a31:	75 13                	jne    800a46 <memmove+0x43>
  800a33:	f6 c1 03             	test   $0x3,%cl
  800a36:	75 0e                	jne    800a46 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a38:	83 ef 04             	sub    $0x4,%edi
  800a3b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a3e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a41:	fd                   	std    
  800a42:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a44:	eb 09                	jmp    800a4f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a46:	83 ef 01             	sub    $0x1,%edi
  800a49:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a4c:	fd                   	std    
  800a4d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a4f:	fc                   	cld    
  800a50:	eb 20                	jmp    800a72 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a52:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a58:	75 13                	jne    800a6d <memmove+0x6a>
  800a5a:	a8 03                	test   $0x3,%al
  800a5c:	75 0f                	jne    800a6d <memmove+0x6a>
  800a5e:	f6 c1 03             	test   $0x3,%cl
  800a61:	75 0a                	jne    800a6d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a63:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a66:	89 c7                	mov    %eax,%edi
  800a68:	fc                   	cld    
  800a69:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6b:	eb 05                	jmp    800a72 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a6d:	89 c7                	mov    %eax,%edi
  800a6f:	fc                   	cld    
  800a70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a72:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a75:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a78:	89 ec                	mov    %ebp,%esp
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a82:	8b 45 10             	mov    0x10(%ebp),%eax
  800a85:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a90:	8b 45 08             	mov    0x8(%ebp),%eax
  800a93:	89 04 24             	mov    %eax,(%esp)
  800a96:	e8 68 ff ff ff       	call   800a03 <memmove>
}
  800a9b:	c9                   	leave  
  800a9c:	c3                   	ret    

00800a9d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	57                   	push   %edi
  800aa1:	56                   	push   %esi
  800aa2:	53                   	push   %ebx
  800aa3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800aa6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa9:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aac:	8d 78 ff             	lea    -0x1(%eax),%edi
  800aaf:	85 c0                	test   %eax,%eax
  800ab1:	74 36                	je     800ae9 <memcmp+0x4c>
		if (*s1 != *s2)
  800ab3:	0f b6 03             	movzbl (%ebx),%eax
  800ab6:	0f b6 0e             	movzbl (%esi),%ecx
  800ab9:	38 c8                	cmp    %cl,%al
  800abb:	75 17                	jne    800ad4 <memcmp+0x37>
  800abd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac2:	eb 1a                	jmp    800ade <memcmp+0x41>
  800ac4:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800ac9:	83 c2 01             	add    $0x1,%edx
  800acc:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800ad0:	38 c8                	cmp    %cl,%al
  800ad2:	74 0a                	je     800ade <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800ad4:	0f b6 c0             	movzbl %al,%eax
  800ad7:	0f b6 c9             	movzbl %cl,%ecx
  800ada:	29 c8                	sub    %ecx,%eax
  800adc:	eb 10                	jmp    800aee <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ade:	39 fa                	cmp    %edi,%edx
  800ae0:	75 e2                	jne    800ac4 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ae2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae7:	eb 05                	jmp    800aee <memcmp+0x51>
  800ae9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	5f                   	pop    %edi
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	53                   	push   %ebx
  800af7:	8b 45 08             	mov    0x8(%ebp),%eax
  800afa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800afd:	89 c2                	mov    %eax,%edx
  800aff:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b02:	39 d0                	cmp    %edx,%eax
  800b04:	73 13                	jae    800b19 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b06:	89 d9                	mov    %ebx,%ecx
  800b08:	38 18                	cmp    %bl,(%eax)
  800b0a:	75 06                	jne    800b12 <memfind+0x1f>
  800b0c:	eb 0b                	jmp    800b19 <memfind+0x26>
  800b0e:	38 08                	cmp    %cl,(%eax)
  800b10:	74 07                	je     800b19 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b12:	83 c0 01             	add    $0x1,%eax
  800b15:	39 d0                	cmp    %edx,%eax
  800b17:	75 f5                	jne    800b0e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b19:	5b                   	pop    %ebx
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
  800b22:	83 ec 04             	sub    $0x4,%esp
  800b25:	8b 55 08             	mov    0x8(%ebp),%edx
  800b28:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2b:	0f b6 02             	movzbl (%edx),%eax
  800b2e:	3c 09                	cmp    $0x9,%al
  800b30:	74 04                	je     800b36 <strtol+0x1a>
  800b32:	3c 20                	cmp    $0x20,%al
  800b34:	75 0e                	jne    800b44 <strtol+0x28>
		s++;
  800b36:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b39:	0f b6 02             	movzbl (%edx),%eax
  800b3c:	3c 09                	cmp    $0x9,%al
  800b3e:	74 f6                	je     800b36 <strtol+0x1a>
  800b40:	3c 20                	cmp    $0x20,%al
  800b42:	74 f2                	je     800b36 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b44:	3c 2b                	cmp    $0x2b,%al
  800b46:	75 0a                	jne    800b52 <strtol+0x36>
		s++;
  800b48:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b4b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b50:	eb 10                	jmp    800b62 <strtol+0x46>
  800b52:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b57:	3c 2d                	cmp    $0x2d,%al
  800b59:	75 07                	jne    800b62 <strtol+0x46>
		s++, neg = 1;
  800b5b:	83 c2 01             	add    $0x1,%edx
  800b5e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b62:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b68:	75 15                	jne    800b7f <strtol+0x63>
  800b6a:	80 3a 30             	cmpb   $0x30,(%edx)
  800b6d:	75 10                	jne    800b7f <strtol+0x63>
  800b6f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b73:	75 0a                	jne    800b7f <strtol+0x63>
		s += 2, base = 16;
  800b75:	83 c2 02             	add    $0x2,%edx
  800b78:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b7d:	eb 10                	jmp    800b8f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800b7f:	85 db                	test   %ebx,%ebx
  800b81:	75 0c                	jne    800b8f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b83:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b85:	80 3a 30             	cmpb   $0x30,(%edx)
  800b88:	75 05                	jne    800b8f <strtol+0x73>
		s++, base = 8;
  800b8a:	83 c2 01             	add    $0x1,%edx
  800b8d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b94:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b97:	0f b6 0a             	movzbl (%edx),%ecx
  800b9a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b9d:	89 f3                	mov    %esi,%ebx
  800b9f:	80 fb 09             	cmp    $0x9,%bl
  800ba2:	77 08                	ja     800bac <strtol+0x90>
			dig = *s - '0';
  800ba4:	0f be c9             	movsbl %cl,%ecx
  800ba7:	83 e9 30             	sub    $0x30,%ecx
  800baa:	eb 22                	jmp    800bce <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800bac:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800baf:	89 f3                	mov    %esi,%ebx
  800bb1:	80 fb 19             	cmp    $0x19,%bl
  800bb4:	77 08                	ja     800bbe <strtol+0xa2>
			dig = *s - 'a' + 10;
  800bb6:	0f be c9             	movsbl %cl,%ecx
  800bb9:	83 e9 57             	sub    $0x57,%ecx
  800bbc:	eb 10                	jmp    800bce <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800bbe:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800bc1:	89 f3                	mov    %esi,%ebx
  800bc3:	80 fb 19             	cmp    $0x19,%bl
  800bc6:	77 16                	ja     800bde <strtol+0xc2>
			dig = *s - 'A' + 10;
  800bc8:	0f be c9             	movsbl %cl,%ecx
  800bcb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bce:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800bd1:	7d 0f                	jge    800be2 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800bd3:	83 c2 01             	add    $0x1,%edx
  800bd6:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800bda:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bdc:	eb b9                	jmp    800b97 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bde:	89 c1                	mov    %eax,%ecx
  800be0:	eb 02                	jmp    800be4 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800be2:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800be4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be8:	74 05                	je     800bef <strtol+0xd3>
		*endptr = (char *) s;
  800bea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bed:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bef:	89 ca                	mov    %ecx,%edx
  800bf1:	f7 da                	neg    %edx
  800bf3:	85 ff                	test   %edi,%edi
  800bf5:	0f 45 c2             	cmovne %edx,%eax
}
  800bf8:	83 c4 04             	add    $0x4,%esp
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	83 ec 0c             	sub    $0xc,%esp
  800c06:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c09:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c0c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c17:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1a:	89 c3                	mov    %eax,%ebx
  800c1c:	89 c7                	mov    %eax,%edi
  800c1e:	89 c6                	mov    %eax,%esi
  800c20:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c22:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c25:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c28:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c2b:	89 ec                	mov    %ebp,%esp
  800c2d:	5d                   	pop    %ebp
  800c2e:	c3                   	ret    

00800c2f <sys_cgetc>:

int
sys_cgetc(void)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	83 ec 0c             	sub    $0xc,%esp
  800c35:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c38:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c3b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c43:	b8 01 00 00 00       	mov    $0x1,%eax
  800c48:	89 d1                	mov    %edx,%ecx
  800c4a:	89 d3                	mov    %edx,%ebx
  800c4c:	89 d7                	mov    %edx,%edi
  800c4e:	89 d6                	mov    %edx,%esi
  800c50:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c52:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c55:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c58:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c5b:	89 ec                	mov    %ebp,%esp
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    

00800c5f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	83 ec 38             	sub    $0x38,%esp
  800c65:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c68:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c6b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c73:	b8 03 00 00 00       	mov    $0x3,%eax
  800c78:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7b:	89 cb                	mov    %ecx,%ebx
  800c7d:	89 cf                	mov    %ecx,%edi
  800c7f:	89 ce                	mov    %ecx,%esi
  800c81:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c83:	85 c0                	test   %eax,%eax
  800c85:	7e 28                	jle    800caf <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c87:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c8b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c92:	00 
  800c93:	c7 44 24 08 24 15 80 	movl   $0x801524,0x8(%esp)
  800c9a:	00 
  800c9b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca2:	00 
  800ca3:	c7 04 24 41 15 80 00 	movl   $0x801541,(%esp)
  800caa:	e8 d5 02 00 00       	call   800f84 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800caf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cb2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cb5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cb8:	89 ec                	mov    %ebp,%esp
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	83 ec 0c             	sub    $0xc,%esp
  800cc2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cc5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cc8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccb:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd0:	b8 02 00 00 00       	mov    $0x2,%eax
  800cd5:	89 d1                	mov    %edx,%ecx
  800cd7:	89 d3                	mov    %edx,%ebx
  800cd9:	89 d7                	mov    %edx,%edi
  800cdb:	89 d6                	mov    %edx,%esi
  800cdd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cdf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ce2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ce5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ce8:	89 ec                	mov    %ebp,%esp
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <sys_yield>:

void
sys_yield(void)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	83 ec 0c             	sub    $0xc,%esp
  800cf2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cf5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cf8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800d00:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d05:	89 d1                	mov    %edx,%ecx
  800d07:	89 d3                	mov    %edx,%ebx
  800d09:	89 d7                	mov    %edx,%edi
  800d0b:	89 d6                	mov    %edx,%esi
  800d0d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d0f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d12:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d15:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d18:	89 ec                	mov    %ebp,%esp
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	83 ec 38             	sub    $0x38,%esp
  800d22:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d25:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d28:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2b:	be 00 00 00 00       	mov    $0x0,%esi
  800d30:	b8 04 00 00 00       	mov    $0x4,%eax
  800d35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d38:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3e:	89 f7                	mov    %esi,%edi
  800d40:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d42:	85 c0                	test   %eax,%eax
  800d44:	7e 28                	jle    800d6e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d46:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d4a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d51:	00 
  800d52:	c7 44 24 08 24 15 80 	movl   $0x801524,0x8(%esp)
  800d59:	00 
  800d5a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d61:	00 
  800d62:	c7 04 24 41 15 80 00 	movl   $0x801541,(%esp)
  800d69:	e8 16 02 00 00       	call   800f84 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d6e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d71:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d74:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d77:	89 ec                	mov    %ebp,%esp
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    

00800d7b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	83 ec 38             	sub    $0x38,%esp
  800d81:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d84:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d87:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8a:	b8 05 00 00 00       	mov    $0x5,%eax
  800d8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d92:	8b 55 08             	mov    0x8(%ebp),%edx
  800d95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d98:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d9b:	8b 75 18             	mov    0x18(%ebp),%esi
  800d9e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da0:	85 c0                	test   %eax,%eax
  800da2:	7e 28                	jle    800dcc <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800daf:	00 
  800db0:	c7 44 24 08 24 15 80 	movl   $0x801524,0x8(%esp)
  800db7:	00 
  800db8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dbf:	00 
  800dc0:	c7 04 24 41 15 80 00 	movl   $0x801541,(%esp)
  800dc7:	e8 b8 01 00 00       	call   800f84 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dcc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dcf:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dd2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dd5:	89 ec                	mov    %ebp,%esp
  800dd7:	5d                   	pop    %ebp
  800dd8:	c3                   	ret    

00800dd9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	83 ec 38             	sub    $0x38,%esp
  800ddf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800de2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800de5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ded:	b8 06 00 00 00       	mov    $0x6,%eax
  800df2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df5:	8b 55 08             	mov    0x8(%ebp),%edx
  800df8:	89 df                	mov    %ebx,%edi
  800dfa:	89 de                	mov    %ebx,%esi
  800dfc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dfe:	85 c0                	test   %eax,%eax
  800e00:	7e 28                	jle    800e2a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e02:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e06:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e0d:	00 
  800e0e:	c7 44 24 08 24 15 80 	movl   $0x801524,0x8(%esp)
  800e15:	00 
  800e16:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e1d:	00 
  800e1e:	c7 04 24 41 15 80 00 	movl   $0x801541,(%esp)
  800e25:	e8 5a 01 00 00       	call   800f84 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e2a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e2d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e30:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e33:	89 ec                	mov    %ebp,%esp
  800e35:	5d                   	pop    %ebp
  800e36:	c3                   	ret    

00800e37 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	83 ec 38             	sub    $0x38,%esp
  800e3d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e40:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e43:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e4b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e53:	8b 55 08             	mov    0x8(%ebp),%edx
  800e56:	89 df                	mov    %ebx,%edi
  800e58:	89 de                	mov    %ebx,%esi
  800e5a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e5c:	85 c0                	test   %eax,%eax
  800e5e:	7e 28                	jle    800e88 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e60:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e64:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e6b:	00 
  800e6c:	c7 44 24 08 24 15 80 	movl   $0x801524,0x8(%esp)
  800e73:	00 
  800e74:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e7b:	00 
  800e7c:	c7 04 24 41 15 80 00 	movl   $0x801541,(%esp)
  800e83:	e8 fc 00 00 00       	call   800f84 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e88:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e8b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e8e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e91:	89 ec                	mov    %ebp,%esp
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    

00800e95 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	83 ec 38             	sub    $0x38,%esp
  800e9b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e9e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ea1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea9:	b8 09 00 00 00       	mov    $0x9,%eax
  800eae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb4:	89 df                	mov    %ebx,%edi
  800eb6:	89 de                	mov    %ebx,%esi
  800eb8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eba:	85 c0                	test   %eax,%eax
  800ebc:	7e 28                	jle    800ee6 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ec9:	00 
  800eca:	c7 44 24 08 24 15 80 	movl   $0x801524,0x8(%esp)
  800ed1:	00 
  800ed2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed9:	00 
  800eda:	c7 04 24 41 15 80 00 	movl   $0x801541,(%esp)
  800ee1:	e8 9e 00 00 00       	call   800f84 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ee6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ee9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eec:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eef:	89 ec                	mov    %ebp,%esp
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    

00800ef3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	83 ec 0c             	sub    $0xc,%esp
  800ef9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800efc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eff:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f02:	be 00 00 00 00       	mov    $0x0,%esi
  800f07:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f12:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f15:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f18:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f1a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f1d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f20:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f23:	89 ec                	mov    %ebp,%esp
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    

00800f27 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800f36:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f3b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f40:	8b 55 08             	mov    0x8(%ebp),%edx
  800f43:	89 cb                	mov    %ecx,%ebx
  800f45:	89 cf                	mov    %ecx,%edi
  800f47:	89 ce                	mov    %ecx,%esi
  800f49:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f4b:	85 c0                	test   %eax,%eax
  800f4d:	7e 28                	jle    800f77 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f53:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f5a:	00 
  800f5b:	c7 44 24 08 24 15 80 	movl   $0x801524,0x8(%esp)
  800f62:	00 
  800f63:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f6a:	00 
  800f6b:	c7 04 24 41 15 80 00 	movl   $0x801541,(%esp)
  800f72:	e8 0d 00 00 00       	call   800f84 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f77:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f7a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f7d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f80:	89 ec                	mov    %ebp,%esp
  800f82:	5d                   	pop    %ebp
  800f83:	c3                   	ret    

00800f84 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	56                   	push   %esi
  800f88:	53                   	push   %ebx
  800f89:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800f8c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f8f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800f95:	e8 22 fd ff ff       	call   800cbc <sys_getenvid>
  800f9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f9d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800fa1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fa8:	89 74 24 08          	mov    %esi,0x8(%esp)
  800fac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fb0:	c7 04 24 50 15 80 00 	movl   $0x801550,(%esp)
  800fb7:	e8 bf f1 ff ff       	call   80017b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fbc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fc0:	8b 45 10             	mov    0x10(%ebp),%eax
  800fc3:	89 04 24             	mov    %eax,(%esp)
  800fc6:	e8 4f f1 ff ff       	call   80011a <vcprintf>
	cprintf("\n");
  800fcb:	c7 04 24 cc 12 80 00 	movl   $0x8012cc,(%esp)
  800fd2:	e8 a4 f1 ff ff       	call   80017b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fd7:	cc                   	int3   
  800fd8:	eb fd                	jmp    800fd7 <_panic+0x53>
  800fda:	66 90                	xchg   %ax,%ax
  800fdc:	66 90                	xchg   %ax,%ax
  800fde:	66 90                	xchg   %ax,%ax

00800fe0 <__udivdi3>:
  800fe0:	83 ec 1c             	sub    $0x1c,%esp
  800fe3:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800fe7:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800feb:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800fef:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800ff3:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800ff7:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	89 74 24 10          	mov    %esi,0x10(%esp)
  801001:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801005:	89 ea                	mov    %ebp,%edx
  801007:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80100b:	75 33                	jne    801040 <__udivdi3+0x60>
  80100d:	39 e9                	cmp    %ebp,%ecx
  80100f:	77 6f                	ja     801080 <__udivdi3+0xa0>
  801011:	85 c9                	test   %ecx,%ecx
  801013:	89 ce                	mov    %ecx,%esi
  801015:	75 0b                	jne    801022 <__udivdi3+0x42>
  801017:	b8 01 00 00 00       	mov    $0x1,%eax
  80101c:	31 d2                	xor    %edx,%edx
  80101e:	f7 f1                	div    %ecx
  801020:	89 c6                	mov    %eax,%esi
  801022:	31 d2                	xor    %edx,%edx
  801024:	89 e8                	mov    %ebp,%eax
  801026:	f7 f6                	div    %esi
  801028:	89 c5                	mov    %eax,%ebp
  80102a:	89 f8                	mov    %edi,%eax
  80102c:	f7 f6                	div    %esi
  80102e:	89 ea                	mov    %ebp,%edx
  801030:	8b 74 24 10          	mov    0x10(%esp),%esi
  801034:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801038:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80103c:	83 c4 1c             	add    $0x1c,%esp
  80103f:	c3                   	ret    
  801040:	39 e8                	cmp    %ebp,%eax
  801042:	77 24                	ja     801068 <__udivdi3+0x88>
  801044:	0f bd c8             	bsr    %eax,%ecx
  801047:	83 f1 1f             	xor    $0x1f,%ecx
  80104a:	89 0c 24             	mov    %ecx,(%esp)
  80104d:	75 49                	jne    801098 <__udivdi3+0xb8>
  80104f:	8b 74 24 08          	mov    0x8(%esp),%esi
  801053:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801057:	0f 86 ab 00 00 00    	jbe    801108 <__udivdi3+0x128>
  80105d:	39 e8                	cmp    %ebp,%eax
  80105f:	0f 82 a3 00 00 00    	jb     801108 <__udivdi3+0x128>
  801065:	8d 76 00             	lea    0x0(%esi),%esi
  801068:	31 d2                	xor    %edx,%edx
  80106a:	31 c0                	xor    %eax,%eax
  80106c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801070:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801074:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801078:	83 c4 1c             	add    $0x1c,%esp
  80107b:	c3                   	ret    
  80107c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801080:	89 f8                	mov    %edi,%eax
  801082:	f7 f1                	div    %ecx
  801084:	31 d2                	xor    %edx,%edx
  801086:	8b 74 24 10          	mov    0x10(%esp),%esi
  80108a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80108e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801092:	83 c4 1c             	add    $0x1c,%esp
  801095:	c3                   	ret    
  801096:	66 90                	xchg   %ax,%ax
  801098:	0f b6 0c 24          	movzbl (%esp),%ecx
  80109c:	89 c6                	mov    %eax,%esi
  80109e:	b8 20 00 00 00       	mov    $0x20,%eax
  8010a3:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  8010a7:	2b 04 24             	sub    (%esp),%eax
  8010aa:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8010ae:	d3 e6                	shl    %cl,%esi
  8010b0:	89 c1                	mov    %eax,%ecx
  8010b2:	d3 ed                	shr    %cl,%ebp
  8010b4:	0f b6 0c 24          	movzbl (%esp),%ecx
  8010b8:	09 f5                	or     %esi,%ebp
  8010ba:	8b 74 24 04          	mov    0x4(%esp),%esi
  8010be:	d3 e6                	shl    %cl,%esi
  8010c0:	89 c1                	mov    %eax,%ecx
  8010c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010c6:	89 d6                	mov    %edx,%esi
  8010c8:	d3 ee                	shr    %cl,%esi
  8010ca:	0f b6 0c 24          	movzbl (%esp),%ecx
  8010ce:	d3 e2                	shl    %cl,%edx
  8010d0:	89 c1                	mov    %eax,%ecx
  8010d2:	d3 ef                	shr    %cl,%edi
  8010d4:	09 d7                	or     %edx,%edi
  8010d6:	89 f2                	mov    %esi,%edx
  8010d8:	89 f8                	mov    %edi,%eax
  8010da:	f7 f5                	div    %ebp
  8010dc:	89 d6                	mov    %edx,%esi
  8010de:	89 c7                	mov    %eax,%edi
  8010e0:	f7 64 24 04          	mull   0x4(%esp)
  8010e4:	39 d6                	cmp    %edx,%esi
  8010e6:	72 30                	jb     801118 <__udivdi3+0x138>
  8010e8:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8010ec:	0f b6 0c 24          	movzbl (%esp),%ecx
  8010f0:	d3 e5                	shl    %cl,%ebp
  8010f2:	39 c5                	cmp    %eax,%ebp
  8010f4:	73 04                	jae    8010fa <__udivdi3+0x11a>
  8010f6:	39 d6                	cmp    %edx,%esi
  8010f8:	74 1e                	je     801118 <__udivdi3+0x138>
  8010fa:	89 f8                	mov    %edi,%eax
  8010fc:	31 d2                	xor    %edx,%edx
  8010fe:	e9 69 ff ff ff       	jmp    80106c <__udivdi3+0x8c>
  801103:	90                   	nop
  801104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801108:	31 d2                	xor    %edx,%edx
  80110a:	b8 01 00 00 00       	mov    $0x1,%eax
  80110f:	e9 58 ff ff ff       	jmp    80106c <__udivdi3+0x8c>
  801114:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801118:	8d 47 ff             	lea    -0x1(%edi),%eax
  80111b:	31 d2                	xor    %edx,%edx
  80111d:	8b 74 24 10          	mov    0x10(%esp),%esi
  801121:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801125:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801129:	83 c4 1c             	add    $0x1c,%esp
  80112c:	c3                   	ret    
  80112d:	66 90                	xchg   %ax,%ax
  80112f:	90                   	nop

00801130 <__umoddi3>:
  801130:	83 ec 2c             	sub    $0x2c,%esp
  801133:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801137:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80113b:	89 74 24 20          	mov    %esi,0x20(%esp)
  80113f:	8b 74 24 38          	mov    0x38(%esp),%esi
  801143:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801147:	8b 7c 24 34          	mov    0x34(%esp),%edi
  80114b:	85 c0                	test   %eax,%eax
  80114d:	89 c2                	mov    %eax,%edx
  80114f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801153:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801157:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80115b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80115f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801163:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801167:	75 1f                	jne    801188 <__umoddi3+0x58>
  801169:	39 fe                	cmp    %edi,%esi
  80116b:	76 63                	jbe    8011d0 <__umoddi3+0xa0>
  80116d:	89 c8                	mov    %ecx,%eax
  80116f:	89 fa                	mov    %edi,%edx
  801171:	f7 f6                	div    %esi
  801173:	89 d0                	mov    %edx,%eax
  801175:	31 d2                	xor    %edx,%edx
  801177:	8b 74 24 20          	mov    0x20(%esp),%esi
  80117b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80117f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801183:	83 c4 2c             	add    $0x2c,%esp
  801186:	c3                   	ret    
  801187:	90                   	nop
  801188:	39 f8                	cmp    %edi,%eax
  80118a:	77 64                	ja     8011f0 <__umoddi3+0xc0>
  80118c:	0f bd e8             	bsr    %eax,%ebp
  80118f:	83 f5 1f             	xor    $0x1f,%ebp
  801192:	75 74                	jne    801208 <__umoddi3+0xd8>
  801194:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801198:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  80119c:	0f 87 0e 01 00 00    	ja     8012b0 <__umoddi3+0x180>
  8011a2:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  8011a6:	29 f1                	sub    %esi,%ecx
  8011a8:	19 c7                	sbb    %eax,%edi
  8011aa:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8011ae:	89 7c 24 18          	mov    %edi,0x18(%esp)
  8011b2:	8b 44 24 14          	mov    0x14(%esp),%eax
  8011b6:	8b 54 24 18          	mov    0x18(%esp),%edx
  8011ba:	8b 74 24 20          	mov    0x20(%esp),%esi
  8011be:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8011c2:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8011c6:	83 c4 2c             	add    $0x2c,%esp
  8011c9:	c3                   	ret    
  8011ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011d0:	85 f6                	test   %esi,%esi
  8011d2:	89 f5                	mov    %esi,%ebp
  8011d4:	75 0b                	jne    8011e1 <__umoddi3+0xb1>
  8011d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8011db:	31 d2                	xor    %edx,%edx
  8011dd:	f7 f6                	div    %esi
  8011df:	89 c5                	mov    %eax,%ebp
  8011e1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8011e5:	31 d2                	xor    %edx,%edx
  8011e7:	f7 f5                	div    %ebp
  8011e9:	89 c8                	mov    %ecx,%eax
  8011eb:	f7 f5                	div    %ebp
  8011ed:	eb 84                	jmp    801173 <__umoddi3+0x43>
  8011ef:	90                   	nop
  8011f0:	89 c8                	mov    %ecx,%eax
  8011f2:	89 fa                	mov    %edi,%edx
  8011f4:	8b 74 24 20          	mov    0x20(%esp),%esi
  8011f8:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8011fc:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801200:	83 c4 2c             	add    $0x2c,%esp
  801203:	c3                   	ret    
  801204:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801208:	8b 44 24 10          	mov    0x10(%esp),%eax
  80120c:	be 20 00 00 00       	mov    $0x20,%esi
  801211:	89 e9                	mov    %ebp,%ecx
  801213:	29 ee                	sub    %ebp,%esi
  801215:	d3 e2                	shl    %cl,%edx
  801217:	89 f1                	mov    %esi,%ecx
  801219:	d3 e8                	shr    %cl,%eax
  80121b:	89 e9                	mov    %ebp,%ecx
  80121d:	09 d0                	or     %edx,%eax
  80121f:	89 fa                	mov    %edi,%edx
  801221:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801225:	8b 44 24 10          	mov    0x10(%esp),%eax
  801229:	d3 e0                	shl    %cl,%eax
  80122b:	89 f1                	mov    %esi,%ecx
  80122d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801231:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801235:	d3 ea                	shr    %cl,%edx
  801237:	89 e9                	mov    %ebp,%ecx
  801239:	d3 e7                	shl    %cl,%edi
  80123b:	89 f1                	mov    %esi,%ecx
  80123d:	d3 e8                	shr    %cl,%eax
  80123f:	89 e9                	mov    %ebp,%ecx
  801241:	09 f8                	or     %edi,%eax
  801243:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801247:	f7 74 24 0c          	divl   0xc(%esp)
  80124b:	d3 e7                	shl    %cl,%edi
  80124d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801251:	89 d7                	mov    %edx,%edi
  801253:	f7 64 24 10          	mull   0x10(%esp)
  801257:	39 d7                	cmp    %edx,%edi
  801259:	89 c1                	mov    %eax,%ecx
  80125b:	89 54 24 14          	mov    %edx,0x14(%esp)
  80125f:	72 3b                	jb     80129c <__umoddi3+0x16c>
  801261:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801265:	72 31                	jb     801298 <__umoddi3+0x168>
  801267:	8b 44 24 18          	mov    0x18(%esp),%eax
  80126b:	29 c8                	sub    %ecx,%eax
  80126d:	19 d7                	sbb    %edx,%edi
  80126f:	89 e9                	mov    %ebp,%ecx
  801271:	89 fa                	mov    %edi,%edx
  801273:	d3 e8                	shr    %cl,%eax
  801275:	89 f1                	mov    %esi,%ecx
  801277:	d3 e2                	shl    %cl,%edx
  801279:	89 e9                	mov    %ebp,%ecx
  80127b:	09 d0                	or     %edx,%eax
  80127d:	89 fa                	mov    %edi,%edx
  80127f:	d3 ea                	shr    %cl,%edx
  801281:	8b 74 24 20          	mov    0x20(%esp),%esi
  801285:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801289:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  80128d:	83 c4 2c             	add    $0x2c,%esp
  801290:	c3                   	ret    
  801291:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801298:	39 d7                	cmp    %edx,%edi
  80129a:	75 cb                	jne    801267 <__umoddi3+0x137>
  80129c:	8b 54 24 14          	mov    0x14(%esp),%edx
  8012a0:	89 c1                	mov    %eax,%ecx
  8012a2:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  8012a6:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  8012aa:	eb bb                	jmp    801267 <__umoddi3+0x137>
  8012ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012b0:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8012b4:	0f 82 e8 fe ff ff    	jb     8011a2 <__umoddi3+0x72>
  8012ba:	e9 f3 fe ff ff       	jmp    8011b2 <__umoddi3+0x82>
