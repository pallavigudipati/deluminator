
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 93 00 00 00       	call   8000c4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003c:	e8 db 0c 00 00       	call   800d1c <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800043:	81 3d 04 20 80 00 7c 	cmpl   $0xeec0007c,0x802004
  80004a:	00 c0 ee 
  80004d:	75 34                	jne    800083 <umain+0x4f>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800059:	00 
  80005a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800061:	00 
  800062:	89 34 24             	mov    %esi,(%esp)
  800065:	e8 86 0f 00 00       	call   800ff0 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80006a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80006d:	89 54 24 08          	mov    %edx,0x8(%esp)
  800071:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800075:	c7 04 24 60 14 80 00 	movl   $0x801460,(%esp)
  80007c:	e8 56 01 00 00       	call   8001d7 <cprintf>
  800081:	eb cf                	jmp    800052 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800083:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800088:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800090:	c7 04 24 71 14 80 00 	movl   $0x801471,(%esp)
  800097:	e8 3b 01 00 00       	call   8001d7 <cprintf>
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80009c:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  8000a1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000a8:	00 
  8000a9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b0:	00 
  8000b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b8:	00 
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 a7 0f 00 00       	call   801068 <ipc_send>
  8000c1:	eb d9                	jmp    80009c <umain+0x68>
  8000c3:	90                   	nop

008000c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	83 ec 18             	sub    $0x18,%esp
  8000ca:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000cd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d3:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000d6:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000dd:	00 00 00 
	int envid;
	envid = sys_getenvid();
  8000e0:	e8 37 0c 00 00       	call   800d1c <sys_getenvid>
	thisenv = envs + ENVX(envid);
  8000e5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ea:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000ed:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f2:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f7:	85 db                	test   %ebx,%ebx
  8000f9:	7e 07                	jle    800102 <libmain+0x3e>
		binaryname = argv[0];
  8000fb:	8b 06                	mov    (%esi),%eax
  8000fd:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800102:	89 74 24 04          	mov    %esi,0x4(%esp)
  800106:	89 1c 24             	mov    %ebx,(%esp)
  800109:	e8 26 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80010e:	e8 0d 00 00 00       	call   800120 <exit>
}
  800113:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800116:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800119:	89 ec                	mov    %ebp,%esp
  80011b:	5d                   	pop    %ebp
  80011c:	c3                   	ret    
  80011d:	66 90                	xchg   %ax,%ax
  80011f:	90                   	nop

00800120 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800126:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80012d:	e8 8d 0b 00 00       	call   800cbf <sys_env_destroy>
}
  800132:	c9                   	leave  
  800133:	c3                   	ret    

00800134 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	53                   	push   %ebx
  800138:	83 ec 14             	sub    $0x14,%esp
  80013b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80013e:	8b 03                	mov    (%ebx),%eax
  800140:	8b 55 08             	mov    0x8(%ebp),%edx
  800143:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800147:	83 c0 01             	add    $0x1,%eax
  80014a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80014c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800151:	75 19                	jne    80016c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800153:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80015a:	00 
  80015b:	8d 43 08             	lea    0x8(%ebx),%eax
  80015e:	89 04 24             	mov    %eax,(%esp)
  800161:	e8 fa 0a 00 00       	call   800c60 <sys_cputs>
		b->idx = 0;
  800166:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80016c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800170:	83 c4 14             	add    $0x14,%esp
  800173:	5b                   	pop    %ebx
  800174:	5d                   	pop    %ebp
  800175:	c3                   	ret    

00800176 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800176:	55                   	push   %ebp
  800177:	89 e5                	mov    %esp,%ebp
  800179:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80017f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800186:	00 00 00 
	b.cnt = 0;
  800189:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800190:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800193:	8b 45 0c             	mov    0xc(%ebp),%eax
  800196:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80019a:	8b 45 08             	mov    0x8(%ebp),%eax
  80019d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001a1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ab:	c7 04 24 34 01 80 00 	movl   $0x800134,(%esp)
  8001b2:	e8 bb 01 00 00       	call   800372 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c7:	89 04 24             	mov    %eax,(%esp)
  8001ca:	e8 91 0a 00 00       	call   800c60 <sys_cputs>

	return b.cnt;
}
  8001cf:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d5:	c9                   	leave  
  8001d6:	c3                   	ret    

008001d7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001dd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e7:	89 04 24             	mov    %eax,(%esp)
  8001ea:	e8 87 ff ff ff       	call   800176 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ef:	c9                   	leave  
  8001f0:	c3                   	ret    
  8001f1:	66 90                	xchg   %ax,%ax
  8001f3:	66 90                	xchg   %ax,%ax
  8001f5:	66 90                	xchg   %ax,%ax
  8001f7:	66 90                	xchg   %ax,%ax
  8001f9:	66 90                	xchg   %ax,%ax
  8001fb:	66 90                	xchg   %ax,%ax
  8001fd:	66 90                	xchg   %ax,%ax
  8001ff:	90                   	nop

00800200 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	57                   	push   %edi
  800204:	56                   	push   %esi
  800205:	53                   	push   %ebx
  800206:	83 ec 4c             	sub    $0x4c,%esp
  800209:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80020c:	89 d7                	mov    %edx,%edi
  80020e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800211:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800214:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800217:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021a:	b8 00 00 00 00       	mov    $0x0,%eax
  80021f:	39 d8                	cmp    %ebx,%eax
  800221:	72 17                	jb     80023a <printnum+0x3a>
  800223:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800226:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  800229:	76 0f                	jbe    80023a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022b:	8b 75 14             	mov    0x14(%ebp),%esi
  80022e:	83 ee 01             	sub    $0x1,%esi
  800231:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800234:	85 f6                	test   %esi,%esi
  800236:	7f 63                	jg     80029b <printnum+0x9b>
  800238:	eb 75                	jmp    8002af <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023a:	8b 5d 18             	mov    0x18(%ebp),%ebx
  80023d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800241:	8b 45 14             	mov    0x14(%ebp),%eax
  800244:	83 e8 01             	sub    $0x1,%eax
  800247:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80024b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80024e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800252:	8b 44 24 08          	mov    0x8(%esp),%eax
  800256:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80025a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80025d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800260:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800267:	00 
  800268:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80026b:	89 1c 24             	mov    %ebx,(%esp)
  80026e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800271:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800275:	e8 f6 0e 00 00       	call   801170 <__udivdi3>
  80027a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80027d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800280:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800284:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800288:	89 04 24             	mov    %eax,(%esp)
  80028b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80028f:	89 fa                	mov    %edi,%edx
  800291:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800294:	e8 67 ff ff ff       	call   800200 <printnum>
  800299:	eb 14                	jmp    8002af <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80029f:	8b 45 18             	mov    0x18(%ebp),%eax
  8002a2:	89 04 24             	mov    %eax,(%esp)
  8002a5:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a7:	83 ee 01             	sub    $0x1,%esi
  8002aa:	75 ef                	jne    80029b <printnum+0x9b>
  8002ac:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002af:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002ba:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002be:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002c5:	00 
  8002c6:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8002c9:	89 1c 24             	mov    %ebx,(%esp)
  8002cc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002d3:	e8 e8 0f 00 00       	call   8012c0 <__umoddi3>
  8002d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002dc:	0f be 80 92 14 80 00 	movsbl 0x801492(%eax),%eax
  8002e3:	89 04 24             	mov    %eax,(%esp)
  8002e6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002e9:	ff d0                	call   *%eax
}
  8002eb:	83 c4 4c             	add    $0x4c,%esp
  8002ee:	5b                   	pop    %ebx
  8002ef:	5e                   	pop    %esi
  8002f0:	5f                   	pop    %edi
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f6:	83 fa 01             	cmp    $0x1,%edx
  8002f9:	7e 0e                	jle    800309 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002fb:	8b 10                	mov    (%eax),%edx
  8002fd:	8d 4a 08             	lea    0x8(%edx),%ecx
  800300:	89 08                	mov    %ecx,(%eax)
  800302:	8b 02                	mov    (%edx),%eax
  800304:	8b 52 04             	mov    0x4(%edx),%edx
  800307:	eb 22                	jmp    80032b <getuint+0x38>
	else if (lflag)
  800309:	85 d2                	test   %edx,%edx
  80030b:	74 10                	je     80031d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80030d:	8b 10                	mov    (%eax),%edx
  80030f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800312:	89 08                	mov    %ecx,(%eax)
  800314:	8b 02                	mov    (%edx),%eax
  800316:	ba 00 00 00 00       	mov    $0x0,%edx
  80031b:	eb 0e                	jmp    80032b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80031d:	8b 10                	mov    (%eax),%edx
  80031f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800322:	89 08                	mov    %ecx,(%eax)
  800324:	8b 02                	mov    (%edx),%eax
  800326:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032b:	5d                   	pop    %ebp
  80032c:	c3                   	ret    

0080032d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800333:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800337:	8b 10                	mov    (%eax),%edx
  800339:	3b 50 04             	cmp    0x4(%eax),%edx
  80033c:	73 0a                	jae    800348 <sprintputch+0x1b>
		*b->buf++ = ch;
  80033e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800341:	88 0a                	mov    %cl,(%edx)
  800343:	83 c2 01             	add    $0x1,%edx
  800346:	89 10                	mov    %edx,(%eax)
}
  800348:	5d                   	pop    %ebp
  800349:	c3                   	ret    

0080034a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
  80034d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800350:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800353:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800357:	8b 45 10             	mov    0x10(%ebp),%eax
  80035a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80035e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800361:	89 44 24 04          	mov    %eax,0x4(%esp)
  800365:	8b 45 08             	mov    0x8(%ebp),%eax
  800368:	89 04 24             	mov    %eax,(%esp)
  80036b:	e8 02 00 00 00       	call   800372 <vprintfmt>
	va_end(ap);
}
  800370:	c9                   	leave  
  800371:	c3                   	ret    

00800372 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	57                   	push   %edi
  800376:	56                   	push   %esi
  800377:	53                   	push   %ebx
  800378:	83 ec 4c             	sub    $0x4c,%esp
  80037b:	8b 75 08             	mov    0x8(%ebp),%esi
  80037e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800381:	8b 7d 10             	mov    0x10(%ebp),%edi
  800384:	eb 11                	jmp    800397 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800386:	85 c0                	test   %eax,%eax
  800388:	0f 84 db 03 00 00    	je     800769 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  80038e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800392:	89 04 24             	mov    %eax,(%esp)
  800395:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800397:	0f b6 07             	movzbl (%edi),%eax
  80039a:	83 c7 01             	add    $0x1,%edi
  80039d:	83 f8 25             	cmp    $0x25,%eax
  8003a0:	75 e4                	jne    800386 <vprintfmt+0x14>
  8003a2:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  8003a6:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8003ad:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8003b4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c0:	eb 2b                	jmp    8003ed <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c5:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  8003c9:	eb 22                	jmp    8003ed <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ce:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  8003d2:	eb 19                	jmp    8003ed <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003d7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003de:	eb 0d                	jmp    8003ed <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003e0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e6:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	0f b6 0f             	movzbl (%edi),%ecx
  8003f0:	8d 47 01             	lea    0x1(%edi),%eax
  8003f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f6:	0f b6 07             	movzbl (%edi),%eax
  8003f9:	83 e8 23             	sub    $0x23,%eax
  8003fc:	3c 55                	cmp    $0x55,%al
  8003fe:	0f 87 40 03 00 00    	ja     800744 <vprintfmt+0x3d2>
  800404:	0f b6 c0             	movzbl %al,%eax
  800407:	ff 24 85 60 15 80 00 	jmp    *0x801560(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80040e:	83 e9 30             	sub    $0x30,%ecx
  800411:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  800414:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  800418:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80041b:	83 f9 09             	cmp    $0x9,%ecx
  80041e:	77 57                	ja     800477 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800423:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800426:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800429:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80042c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80042f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800433:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800436:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800439:	83 f9 09             	cmp    $0x9,%ecx
  80043c:	76 eb                	jbe    800429 <vprintfmt+0xb7>
  80043e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800441:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800444:	eb 34                	jmp    80047a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800446:	8b 45 14             	mov    0x14(%ebp),%eax
  800449:	8d 48 04             	lea    0x4(%eax),%ecx
  80044c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80044f:	8b 00                	mov    (%eax),%eax
  800451:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800457:	eb 21                	jmp    80047a <vprintfmt+0x108>

		case '.':
			if (width < 0)
  800459:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80045d:	0f 88 71 ff ff ff    	js     8003d4 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800463:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800466:	eb 85                	jmp    8003ed <vprintfmt+0x7b>
  800468:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80046b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800472:	e9 76 ff ff ff       	jmp    8003ed <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800477:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80047a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80047e:	0f 89 69 ff ff ff    	jns    8003ed <vprintfmt+0x7b>
  800484:	e9 57 ff ff ff       	jmp    8003e0 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800489:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80048f:	e9 59 ff ff ff       	jmp    8003ed <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800494:	8b 45 14             	mov    0x14(%ebp),%eax
  800497:	8d 50 04             	lea    0x4(%eax),%edx
  80049a:	89 55 14             	mov    %edx,0x14(%ebp)
  80049d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a1:	8b 00                	mov    (%eax),%eax
  8004a3:	89 04 24             	mov    %eax,(%esp)
  8004a6:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004ab:	e9 e7 fe ff ff       	jmp    800397 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b3:	8d 50 04             	lea    0x4(%eax),%edx
  8004b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b9:	8b 00                	mov    (%eax),%eax
  8004bb:	89 c2                	mov    %eax,%edx
  8004bd:	c1 fa 1f             	sar    $0x1f,%edx
  8004c0:	31 d0                	xor    %edx,%eax
  8004c2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c4:	83 f8 08             	cmp    $0x8,%eax
  8004c7:	7f 0b                	jg     8004d4 <vprintfmt+0x162>
  8004c9:	8b 14 85 c0 16 80 00 	mov    0x8016c0(,%eax,4),%edx
  8004d0:	85 d2                	test   %edx,%edx
  8004d2:	75 20                	jne    8004f4 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  8004d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004d8:	c7 44 24 08 aa 14 80 	movl   $0x8014aa,0x8(%esp)
  8004df:	00 
  8004e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e4:	89 34 24             	mov    %esi,(%esp)
  8004e7:	e8 5e fe ff ff       	call   80034a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ec:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004ef:	e9 a3 fe ff ff       	jmp    800397 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8004f4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004f8:	c7 44 24 08 b3 14 80 	movl   $0x8014b3,0x8(%esp)
  8004ff:	00 
  800500:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800504:	89 34 24             	mov    %esi,(%esp)
  800507:	e8 3e fe ff ff       	call   80034a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80050f:	e9 83 fe ff ff       	jmp    800397 <vprintfmt+0x25>
  800514:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800517:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80051a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80051d:	8b 45 14             	mov    0x14(%ebp),%eax
  800520:	8d 50 04             	lea    0x4(%eax),%edx
  800523:	89 55 14             	mov    %edx,0x14(%ebp)
  800526:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800528:	85 ff                	test   %edi,%edi
  80052a:	b8 a3 14 80 00       	mov    $0x8014a3,%eax
  80052f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800532:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  800536:	74 06                	je     80053e <vprintfmt+0x1cc>
  800538:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80053c:	7f 16                	jg     800554 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053e:	0f b6 17             	movzbl (%edi),%edx
  800541:	0f be c2             	movsbl %dl,%eax
  800544:	83 c7 01             	add    $0x1,%edi
  800547:	85 c0                	test   %eax,%eax
  800549:	0f 85 9f 00 00 00    	jne    8005ee <vprintfmt+0x27c>
  80054f:	e9 8b 00 00 00       	jmp    8005df <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800554:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800558:	89 3c 24             	mov    %edi,(%esp)
  80055b:	e8 c2 02 00 00       	call   800822 <strnlen>
  800560:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800563:	29 c2                	sub    %eax,%edx
  800565:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800568:	85 d2                	test   %edx,%edx
  80056a:	7e d2                	jle    80053e <vprintfmt+0x1cc>
					putch(padc, putdat);
  80056c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  800570:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800573:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800576:	89 d7                	mov    %edx,%edi
  800578:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80057c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80057f:	89 04 24             	mov    %eax,(%esp)
  800582:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800584:	83 ef 01             	sub    $0x1,%edi
  800587:	75 ef                	jne    800578 <vprintfmt+0x206>
  800589:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80058c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80058f:	eb ad                	jmp    80053e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800591:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800595:	74 20                	je     8005b7 <vprintfmt+0x245>
  800597:	0f be d2             	movsbl %dl,%edx
  80059a:	83 ea 20             	sub    $0x20,%edx
  80059d:	83 fa 5e             	cmp    $0x5e,%edx
  8005a0:	76 15                	jbe    8005b7 <vprintfmt+0x245>
					putch('?', putdat);
  8005a2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005a5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005a9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005b0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005b3:	ff d1                	call   *%ecx
  8005b5:	eb 0f                	jmp    8005c6 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  8005b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005ba:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005be:	89 04 24             	mov    %eax,(%esp)
  8005c1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005c4:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c6:	83 eb 01             	sub    $0x1,%ebx
  8005c9:	0f b6 17             	movzbl (%edi),%edx
  8005cc:	0f be c2             	movsbl %dl,%eax
  8005cf:	83 c7 01             	add    $0x1,%edi
  8005d2:	85 c0                	test   %eax,%eax
  8005d4:	75 24                	jne    8005fa <vprintfmt+0x288>
  8005d6:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8005d9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005dc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005df:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005e2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e6:	0f 8e ab fd ff ff    	jle    800397 <vprintfmt+0x25>
  8005ec:	eb 20                	jmp    80060e <vprintfmt+0x29c>
  8005ee:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8005f1:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005f4:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8005f7:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005fa:	85 f6                	test   %esi,%esi
  8005fc:	78 93                	js     800591 <vprintfmt+0x21f>
  8005fe:	83 ee 01             	sub    $0x1,%esi
  800601:	79 8e                	jns    800591 <vprintfmt+0x21f>
  800603:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800606:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800609:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80060c:	eb d1                	jmp    8005df <vprintfmt+0x26d>
  80060e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800611:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800615:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80061c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80061e:	83 ef 01             	sub    $0x1,%edi
  800621:	75 ee                	jne    800611 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800623:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800626:	e9 6c fd ff ff       	jmp    800397 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80062b:	83 fa 01             	cmp    $0x1,%edx
  80062e:	66 90                	xchg   %ax,%ax
  800630:	7e 16                	jle    800648 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8d 50 08             	lea    0x8(%eax),%edx
  800638:	89 55 14             	mov    %edx,0x14(%ebp)
  80063b:	8b 10                	mov    (%eax),%edx
  80063d:	8b 48 04             	mov    0x4(%eax),%ecx
  800640:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800643:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800646:	eb 32                	jmp    80067a <vprintfmt+0x308>
	else if (lflag)
  800648:	85 d2                	test   %edx,%edx
  80064a:	74 18                	je     800664 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8d 50 04             	lea    0x4(%eax),%edx
  800652:	89 55 14             	mov    %edx,0x14(%ebp)
  800655:	8b 00                	mov    (%eax),%eax
  800657:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80065a:	89 c1                	mov    %eax,%ecx
  80065c:	c1 f9 1f             	sar    $0x1f,%ecx
  80065f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800662:	eb 16                	jmp    80067a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  800664:	8b 45 14             	mov    0x14(%ebp),%eax
  800667:	8d 50 04             	lea    0x4(%eax),%edx
  80066a:	89 55 14             	mov    %edx,0x14(%ebp)
  80066d:	8b 00                	mov    (%eax),%eax
  80066f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800672:	89 c7                	mov    %eax,%edi
  800674:	c1 ff 1f             	sar    $0x1f,%edi
  800677:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80067a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80067d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800680:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800685:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800689:	79 7d                	jns    800708 <vprintfmt+0x396>
				putch('-', putdat);
  80068b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800696:	ff d6                	call   *%esi
				num = -(long long) num;
  800698:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80069b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80069e:	f7 d8                	neg    %eax
  8006a0:	83 d2 00             	adc    $0x0,%edx
  8006a3:	f7 da                	neg    %edx
			}
			base = 10;
  8006a5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006aa:	eb 5c                	jmp    800708 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006ac:	8d 45 14             	lea    0x14(%ebp),%eax
  8006af:	e8 3f fc ff ff       	call   8002f3 <getuint>
			base = 10;
  8006b4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006b9:	eb 4d                	jmp    800708 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006be:	e8 30 fc ff ff       	call   8002f3 <getuint>
			base = 8;
  8006c3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006c8:	eb 3e                	jmp    800708 <vprintfmt+0x396>

		// pointer
		case 'p':
			putch('0', putdat);
  8006ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ce:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006d5:	ff d6                	call   *%esi
			putch('x', putdat);
  8006d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006db:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006e2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8d 50 04             	lea    0x4(%eax),%edx
  8006ea:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006ed:	8b 00                	mov    (%eax),%eax
  8006ef:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006f4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006f9:	eb 0d                	jmp    800708 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fe:	e8 f0 fb ff ff       	call   8002f3 <getuint>
			base = 16;
  800703:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800708:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  80070c:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800710:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800713:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800717:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80071b:	89 04 24             	mov    %eax,(%esp)
  80071e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800722:	89 da                	mov    %ebx,%edx
  800724:	89 f0                	mov    %esi,%eax
  800726:	e8 d5 fa ff ff       	call   800200 <printnum>
			break;
  80072b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80072e:	e9 64 fc ff ff       	jmp    800397 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800733:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800737:	89 0c 24             	mov    %ecx,(%esp)
  80073a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80073f:	e9 53 fc ff ff       	jmp    800397 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800744:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800748:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80074f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800751:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800755:	0f 84 3c fc ff ff    	je     800397 <vprintfmt+0x25>
  80075b:	83 ef 01             	sub    $0x1,%edi
  80075e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800762:	75 f7                	jne    80075b <vprintfmt+0x3e9>
  800764:	e9 2e fc ff ff       	jmp    800397 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800769:	83 c4 4c             	add    $0x4c,%esp
  80076c:	5b                   	pop    %ebx
  80076d:	5e                   	pop    %esi
  80076e:	5f                   	pop    %edi
  80076f:	5d                   	pop    %ebp
  800770:	c3                   	ret    

00800771 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
  800774:	83 ec 28             	sub    $0x28,%esp
  800777:	8b 45 08             	mov    0x8(%ebp),%eax
  80077a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800780:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800784:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800787:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80078e:	85 d2                	test   %edx,%edx
  800790:	7e 30                	jle    8007c2 <vsnprintf+0x51>
  800792:	85 c0                	test   %eax,%eax
  800794:	74 2c                	je     8007c2 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800796:	8b 45 14             	mov    0x14(%ebp),%eax
  800799:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80079d:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ab:	c7 04 24 2d 03 80 00 	movl   $0x80032d,(%esp)
  8007b2:	e8 bb fb ff ff       	call   800372 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ba:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007c0:	eb 05                	jmp    8007c7 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007c7:	c9                   	leave  
  8007c8:	c3                   	ret    

008007c9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007cf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e7:	89 04 24             	mov    %eax,(%esp)
  8007ea:	e8 82 ff ff ff       	call   800771 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ef:	c9                   	leave  
  8007f0:	c3                   	ret    
  8007f1:	66 90                	xchg   %ax,%ax
  8007f3:	66 90                	xchg   %ax,%ax
  8007f5:	66 90                	xchg   %ax,%ax
  8007f7:	66 90                	xchg   %ax,%ax
  8007f9:	66 90                	xchg   %ax,%ax
  8007fb:	66 90                	xchg   %ax,%ax
  8007fd:	66 90                	xchg   %ax,%ax
  8007ff:	90                   	nop

00800800 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800806:	80 3a 00             	cmpb   $0x0,(%edx)
  800809:	74 10                	je     80081b <strlen+0x1b>
  80080b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800810:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800813:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800817:	75 f7                	jne    800810 <strlen+0x10>
  800819:	eb 05                	jmp    800820 <strlen+0x20>
  80081b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	53                   	push   %ebx
  800826:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800829:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082c:	85 c9                	test   %ecx,%ecx
  80082e:	74 1c                	je     80084c <strnlen+0x2a>
  800830:	80 3b 00             	cmpb   $0x0,(%ebx)
  800833:	74 1e                	je     800853 <strnlen+0x31>
  800835:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80083a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083c:	39 ca                	cmp    %ecx,%edx
  80083e:	74 18                	je     800858 <strnlen+0x36>
  800840:	83 c2 01             	add    $0x1,%edx
  800843:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800848:	75 f0                	jne    80083a <strnlen+0x18>
  80084a:	eb 0c                	jmp    800858 <strnlen+0x36>
  80084c:	b8 00 00 00 00       	mov    $0x0,%eax
  800851:	eb 05                	jmp    800858 <strnlen+0x36>
  800853:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800858:	5b                   	pop    %ebx
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	53                   	push   %ebx
  80085f:	8b 45 08             	mov    0x8(%ebp),%eax
  800862:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800865:	89 c2                	mov    %eax,%edx
  800867:	0f b6 19             	movzbl (%ecx),%ebx
  80086a:	88 1a                	mov    %bl,(%edx)
  80086c:	83 c2 01             	add    $0x1,%edx
  80086f:	83 c1 01             	add    $0x1,%ecx
  800872:	84 db                	test   %bl,%bl
  800874:	75 f1                	jne    800867 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800876:	5b                   	pop    %ebx
  800877:	5d                   	pop    %ebp
  800878:	c3                   	ret    

00800879 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	53                   	push   %ebx
  80087d:	83 ec 08             	sub    $0x8,%esp
  800880:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800883:	89 1c 24             	mov    %ebx,(%esp)
  800886:	e8 75 ff ff ff       	call   800800 <strlen>
	strcpy(dst + len, src);
  80088b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800892:	01 d8                	add    %ebx,%eax
  800894:	89 04 24             	mov    %eax,(%esp)
  800897:	e8 bf ff ff ff       	call   80085b <strcpy>
	return dst;
}
  80089c:	89 d8                	mov    %ebx,%eax
  80089e:	83 c4 08             	add    $0x8,%esp
  8008a1:	5b                   	pop    %ebx
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	56                   	push   %esi
  8008a8:	53                   	push   %ebx
  8008a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008af:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b2:	85 db                	test   %ebx,%ebx
  8008b4:	74 16                	je     8008cc <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b6:	01 f3                	add    %esi,%ebx
  8008b8:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8008ba:	0f b6 02             	movzbl (%edx),%eax
  8008bd:	88 01                	mov    %al,(%ecx)
  8008bf:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008c2:	80 3a 01             	cmpb   $0x1,(%edx)
  8008c5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c8:	39 d9                	cmp    %ebx,%ecx
  8008ca:	75 ee                	jne    8008ba <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008cc:	89 f0                	mov    %esi,%eax
  8008ce:	5b                   	pop    %ebx
  8008cf:	5e                   	pop    %esi
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	57                   	push   %edi
  8008d6:	56                   	push   %esi
  8008d7:	53                   	push   %ebx
  8008d8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008de:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e1:	89 f8                	mov    %edi,%eax
  8008e3:	85 f6                	test   %esi,%esi
  8008e5:	74 33                	je     80091a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  8008e7:	83 fe 01             	cmp    $0x1,%esi
  8008ea:	74 25                	je     800911 <strlcpy+0x3f>
  8008ec:	0f b6 0b             	movzbl (%ebx),%ecx
  8008ef:	84 c9                	test   %cl,%cl
  8008f1:	74 22                	je     800915 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8008f3:	83 ee 02             	sub    $0x2,%esi
  8008f6:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008fb:	88 08                	mov    %cl,(%eax)
  8008fd:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800900:	39 f2                	cmp    %esi,%edx
  800902:	74 13                	je     800917 <strlcpy+0x45>
  800904:	83 c2 01             	add    $0x1,%edx
  800907:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80090b:	84 c9                	test   %cl,%cl
  80090d:	75 ec                	jne    8008fb <strlcpy+0x29>
  80090f:	eb 06                	jmp    800917 <strlcpy+0x45>
  800911:	89 f8                	mov    %edi,%eax
  800913:	eb 02                	jmp    800917 <strlcpy+0x45>
  800915:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800917:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80091a:	29 f8                	sub    %edi,%eax
}
  80091c:	5b                   	pop    %ebx
  80091d:	5e                   	pop    %esi
  80091e:	5f                   	pop    %edi
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800927:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80092a:	0f b6 01             	movzbl (%ecx),%eax
  80092d:	84 c0                	test   %al,%al
  80092f:	74 15                	je     800946 <strcmp+0x25>
  800931:	3a 02                	cmp    (%edx),%al
  800933:	75 11                	jne    800946 <strcmp+0x25>
		p++, q++;
  800935:	83 c1 01             	add    $0x1,%ecx
  800938:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80093b:	0f b6 01             	movzbl (%ecx),%eax
  80093e:	84 c0                	test   %al,%al
  800940:	74 04                	je     800946 <strcmp+0x25>
  800942:	3a 02                	cmp    (%edx),%al
  800944:	74 ef                	je     800935 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800946:	0f b6 c0             	movzbl %al,%eax
  800949:	0f b6 12             	movzbl (%edx),%edx
  80094c:	29 d0                	sub    %edx,%eax
}
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	56                   	push   %esi
  800954:	53                   	push   %ebx
  800955:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800958:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  80095e:	85 f6                	test   %esi,%esi
  800960:	74 29                	je     80098b <strncmp+0x3b>
  800962:	0f b6 03             	movzbl (%ebx),%eax
  800965:	84 c0                	test   %al,%al
  800967:	74 30                	je     800999 <strncmp+0x49>
  800969:	3a 02                	cmp    (%edx),%al
  80096b:	75 2c                	jne    800999 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  80096d:	8d 43 01             	lea    0x1(%ebx),%eax
  800970:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800972:	89 c3                	mov    %eax,%ebx
  800974:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800977:	39 f0                	cmp    %esi,%eax
  800979:	74 17                	je     800992 <strncmp+0x42>
  80097b:	0f b6 08             	movzbl (%eax),%ecx
  80097e:	84 c9                	test   %cl,%cl
  800980:	74 17                	je     800999 <strncmp+0x49>
  800982:	83 c0 01             	add    $0x1,%eax
  800985:	3a 0a                	cmp    (%edx),%cl
  800987:	74 e9                	je     800972 <strncmp+0x22>
  800989:	eb 0e                	jmp    800999 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80098b:	b8 00 00 00 00       	mov    $0x0,%eax
  800990:	eb 0f                	jmp    8009a1 <strncmp+0x51>
  800992:	b8 00 00 00 00       	mov    $0x0,%eax
  800997:	eb 08                	jmp    8009a1 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800999:	0f b6 03             	movzbl (%ebx),%eax
  80099c:	0f b6 12             	movzbl (%edx),%edx
  80099f:	29 d0                	sub    %edx,%eax
}
  8009a1:	5b                   	pop    %ebx
  8009a2:	5e                   	pop    %esi
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	53                   	push   %ebx
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ac:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  8009af:	0f b6 18             	movzbl (%eax),%ebx
  8009b2:	84 db                	test   %bl,%bl
  8009b4:	74 1d                	je     8009d3 <strchr+0x2e>
  8009b6:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  8009b8:	38 d3                	cmp    %dl,%bl
  8009ba:	75 06                	jne    8009c2 <strchr+0x1d>
  8009bc:	eb 1a                	jmp    8009d8 <strchr+0x33>
  8009be:	38 ca                	cmp    %cl,%dl
  8009c0:	74 16                	je     8009d8 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009c2:	83 c0 01             	add    $0x1,%eax
  8009c5:	0f b6 10             	movzbl (%eax),%edx
  8009c8:	84 d2                	test   %dl,%dl
  8009ca:	75 f2                	jne    8009be <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  8009cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d1:	eb 05                	jmp    8009d8 <strchr+0x33>
  8009d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d8:	5b                   	pop    %ebx
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	53                   	push   %ebx
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  8009e5:	0f b6 18             	movzbl (%eax),%ebx
  8009e8:	84 db                	test   %bl,%bl
  8009ea:	74 16                	je     800a02 <strfind+0x27>
  8009ec:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  8009ee:	38 d3                	cmp    %dl,%bl
  8009f0:	75 06                	jne    8009f8 <strfind+0x1d>
  8009f2:	eb 0e                	jmp    800a02 <strfind+0x27>
  8009f4:	38 ca                	cmp    %cl,%dl
  8009f6:	74 0a                	je     800a02 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009f8:	83 c0 01             	add    $0x1,%eax
  8009fb:	0f b6 10             	movzbl (%eax),%edx
  8009fe:	84 d2                	test   %dl,%dl
  800a00:	75 f2                	jne    8009f4 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800a02:	5b                   	pop    %ebx
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	83 ec 0c             	sub    $0xc,%esp
  800a0b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a0e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a11:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a14:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a17:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a1a:	85 c9                	test   %ecx,%ecx
  800a1c:	74 36                	je     800a54 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a1e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a24:	75 28                	jne    800a4e <memset+0x49>
  800a26:	f6 c1 03             	test   $0x3,%cl
  800a29:	75 23                	jne    800a4e <memset+0x49>
		c &= 0xFF;
  800a2b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a2f:	89 d3                	mov    %edx,%ebx
  800a31:	c1 e3 08             	shl    $0x8,%ebx
  800a34:	89 d6                	mov    %edx,%esi
  800a36:	c1 e6 18             	shl    $0x18,%esi
  800a39:	89 d0                	mov    %edx,%eax
  800a3b:	c1 e0 10             	shl    $0x10,%eax
  800a3e:	09 f0                	or     %esi,%eax
  800a40:	09 c2                	or     %eax,%edx
  800a42:	89 d0                	mov    %edx,%eax
  800a44:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a46:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a49:	fc                   	cld    
  800a4a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a4c:	eb 06                	jmp    800a54 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a51:	fc                   	cld    
  800a52:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a54:	89 f8                	mov    %edi,%eax
  800a56:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a59:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a5c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a5f:	89 ec                	mov    %ebp,%esp
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	83 ec 08             	sub    $0x8,%esp
  800a69:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a6c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a72:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a75:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a78:	39 c6                	cmp    %eax,%esi
  800a7a:	73 36                	jae    800ab2 <memmove+0x4f>
  800a7c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a7f:	39 d0                	cmp    %edx,%eax
  800a81:	73 2f                	jae    800ab2 <memmove+0x4f>
		s += n;
		d += n;
  800a83:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a86:	f6 c2 03             	test   $0x3,%dl
  800a89:	75 1b                	jne    800aa6 <memmove+0x43>
  800a8b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a91:	75 13                	jne    800aa6 <memmove+0x43>
  800a93:	f6 c1 03             	test   $0x3,%cl
  800a96:	75 0e                	jne    800aa6 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a98:	83 ef 04             	sub    $0x4,%edi
  800a9b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a9e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800aa1:	fd                   	std    
  800aa2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa4:	eb 09                	jmp    800aaf <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aa6:	83 ef 01             	sub    $0x1,%edi
  800aa9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aac:	fd                   	std    
  800aad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aaf:	fc                   	cld    
  800ab0:	eb 20                	jmp    800ad2 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ab8:	75 13                	jne    800acd <memmove+0x6a>
  800aba:	a8 03                	test   $0x3,%al
  800abc:	75 0f                	jne    800acd <memmove+0x6a>
  800abe:	f6 c1 03             	test   $0x3,%cl
  800ac1:	75 0a                	jne    800acd <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ac3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ac6:	89 c7                	mov    %eax,%edi
  800ac8:	fc                   	cld    
  800ac9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800acb:	eb 05                	jmp    800ad2 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800acd:	89 c7                	mov    %eax,%edi
  800acf:	fc                   	cld    
  800ad0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ad2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ad5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ad8:	89 ec                	mov    %ebp,%esp
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ae2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ae5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ae9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aec:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af0:	8b 45 08             	mov    0x8(%ebp),%eax
  800af3:	89 04 24             	mov    %eax,(%esp)
  800af6:	e8 68 ff ff ff       	call   800a63 <memmove>
}
  800afb:	c9                   	leave  
  800afc:	c3                   	ret    

00800afd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
  800b03:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b06:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b09:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b0c:	8d 78 ff             	lea    -0x1(%eax),%edi
  800b0f:	85 c0                	test   %eax,%eax
  800b11:	74 36                	je     800b49 <memcmp+0x4c>
		if (*s1 != *s2)
  800b13:	0f b6 03             	movzbl (%ebx),%eax
  800b16:	0f b6 0e             	movzbl (%esi),%ecx
  800b19:	38 c8                	cmp    %cl,%al
  800b1b:	75 17                	jne    800b34 <memcmp+0x37>
  800b1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b22:	eb 1a                	jmp    800b3e <memcmp+0x41>
  800b24:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b29:	83 c2 01             	add    $0x1,%edx
  800b2c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b30:	38 c8                	cmp    %cl,%al
  800b32:	74 0a                	je     800b3e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800b34:	0f b6 c0             	movzbl %al,%eax
  800b37:	0f b6 c9             	movzbl %cl,%ecx
  800b3a:	29 c8                	sub    %ecx,%eax
  800b3c:	eb 10                	jmp    800b4e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3e:	39 fa                	cmp    %edi,%edx
  800b40:	75 e2                	jne    800b24 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b42:	b8 00 00 00 00       	mov    $0x0,%eax
  800b47:	eb 05                	jmp    800b4e <memcmp+0x51>
  800b49:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b4e:	5b                   	pop    %ebx
  800b4f:	5e                   	pop    %esi
  800b50:	5f                   	pop    %edi
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    

00800b53 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	53                   	push   %ebx
  800b57:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800b5d:	89 c2                	mov    %eax,%edx
  800b5f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b62:	39 d0                	cmp    %edx,%eax
  800b64:	73 13                	jae    800b79 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b66:	89 d9                	mov    %ebx,%ecx
  800b68:	38 18                	cmp    %bl,(%eax)
  800b6a:	75 06                	jne    800b72 <memfind+0x1f>
  800b6c:	eb 0b                	jmp    800b79 <memfind+0x26>
  800b6e:	38 08                	cmp    %cl,(%eax)
  800b70:	74 07                	je     800b79 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b72:	83 c0 01             	add    $0x1,%eax
  800b75:	39 d0                	cmp    %edx,%eax
  800b77:	75 f5                	jne    800b6e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	83 ec 04             	sub    $0x4,%esp
  800b85:	8b 55 08             	mov    0x8(%ebp),%edx
  800b88:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b8b:	0f b6 02             	movzbl (%edx),%eax
  800b8e:	3c 09                	cmp    $0x9,%al
  800b90:	74 04                	je     800b96 <strtol+0x1a>
  800b92:	3c 20                	cmp    $0x20,%al
  800b94:	75 0e                	jne    800ba4 <strtol+0x28>
		s++;
  800b96:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b99:	0f b6 02             	movzbl (%edx),%eax
  800b9c:	3c 09                	cmp    $0x9,%al
  800b9e:	74 f6                	je     800b96 <strtol+0x1a>
  800ba0:	3c 20                	cmp    $0x20,%al
  800ba2:	74 f2                	je     800b96 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ba4:	3c 2b                	cmp    $0x2b,%al
  800ba6:	75 0a                	jne    800bb2 <strtol+0x36>
		s++;
  800ba8:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bab:	bf 00 00 00 00       	mov    $0x0,%edi
  800bb0:	eb 10                	jmp    800bc2 <strtol+0x46>
  800bb2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bb7:	3c 2d                	cmp    $0x2d,%al
  800bb9:	75 07                	jne    800bc2 <strtol+0x46>
		s++, neg = 1;
  800bbb:	83 c2 01             	add    $0x1,%edx
  800bbe:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bc8:	75 15                	jne    800bdf <strtol+0x63>
  800bca:	80 3a 30             	cmpb   $0x30,(%edx)
  800bcd:	75 10                	jne    800bdf <strtol+0x63>
  800bcf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bd3:	75 0a                	jne    800bdf <strtol+0x63>
		s += 2, base = 16;
  800bd5:	83 c2 02             	add    $0x2,%edx
  800bd8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bdd:	eb 10                	jmp    800bef <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800bdf:	85 db                	test   %ebx,%ebx
  800be1:	75 0c                	jne    800bef <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800be3:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800be5:	80 3a 30             	cmpb   $0x30,(%edx)
  800be8:	75 05                	jne    800bef <strtol+0x73>
		s++, base = 8;
  800bea:	83 c2 01             	add    $0x1,%edx
  800bed:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800bef:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf4:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bf7:	0f b6 0a             	movzbl (%edx),%ecx
  800bfa:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800bfd:	89 f3                	mov    %esi,%ebx
  800bff:	80 fb 09             	cmp    $0x9,%bl
  800c02:	77 08                	ja     800c0c <strtol+0x90>
			dig = *s - '0';
  800c04:	0f be c9             	movsbl %cl,%ecx
  800c07:	83 e9 30             	sub    $0x30,%ecx
  800c0a:	eb 22                	jmp    800c2e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800c0c:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c0f:	89 f3                	mov    %esi,%ebx
  800c11:	80 fb 19             	cmp    $0x19,%bl
  800c14:	77 08                	ja     800c1e <strtol+0xa2>
			dig = *s - 'a' + 10;
  800c16:	0f be c9             	movsbl %cl,%ecx
  800c19:	83 e9 57             	sub    $0x57,%ecx
  800c1c:	eb 10                	jmp    800c2e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800c1e:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c21:	89 f3                	mov    %esi,%ebx
  800c23:	80 fb 19             	cmp    $0x19,%bl
  800c26:	77 16                	ja     800c3e <strtol+0xc2>
			dig = *s - 'A' + 10;
  800c28:	0f be c9             	movsbl %cl,%ecx
  800c2b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c2e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800c31:	7d 0f                	jge    800c42 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800c33:	83 c2 01             	add    $0x1,%edx
  800c36:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800c3a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c3c:	eb b9                	jmp    800bf7 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c3e:	89 c1                	mov    %eax,%ecx
  800c40:	eb 02                	jmp    800c44 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c42:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c44:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c48:	74 05                	je     800c4f <strtol+0xd3>
		*endptr = (char *) s;
  800c4a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c4d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c4f:	89 ca                	mov    %ecx,%edx
  800c51:	f7 da                	neg    %edx
  800c53:	85 ff                	test   %edi,%edi
  800c55:	0f 45 c2             	cmovne %edx,%eax
}
  800c58:	83 c4 04             	add    $0x4,%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	83 ec 0c             	sub    $0xc,%esp
  800c66:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c69:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c6c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c77:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7a:	89 c3                	mov    %eax,%ebx
  800c7c:	89 c7                	mov    %eax,%edi
  800c7e:	89 c6                	mov    %eax,%esi
  800c80:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c82:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c85:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c88:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c8b:	89 ec                	mov    %ebp,%esp
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <sys_cgetc>:

int
sys_cgetc(void)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	83 ec 0c             	sub    $0xc,%esp
  800c95:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c98:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c9b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ca8:	89 d1                	mov    %edx,%ecx
  800caa:	89 d3                	mov    %edx,%ebx
  800cac:	89 d7                	mov    %edx,%edi
  800cae:	89 d6                	mov    %edx,%esi
  800cb0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cb2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cb5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cb8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cbb:	89 ec                	mov    %ebp,%esp
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	83 ec 38             	sub    $0x38,%esp
  800cc5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cc8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ccb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cce:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd3:	b8 03 00 00 00       	mov    $0x3,%eax
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	89 cb                	mov    %ecx,%ebx
  800cdd:	89 cf                	mov    %ecx,%edi
  800cdf:	89 ce                	mov    %ecx,%esi
  800ce1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 28                	jle    800d0f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ceb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cf2:	00 
  800cf3:	c7 44 24 08 e4 16 80 	movl   $0x8016e4,0x8(%esp)
  800cfa:	00 
  800cfb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d02:	00 
  800d03:	c7 04 24 01 17 80 00 	movl   $0x801701,(%esp)
  800d0a:	e8 09 04 00 00       	call   801118 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d0f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d12:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d15:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d18:	89 ec                	mov    %ebp,%esp
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	83 ec 0c             	sub    $0xc,%esp
  800d22:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d25:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d28:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d30:	b8 02 00 00 00       	mov    $0x2,%eax
  800d35:	89 d1                	mov    %edx,%ecx
  800d37:	89 d3                	mov    %edx,%ebx
  800d39:	89 d7                	mov    %edx,%edi
  800d3b:	89 d6                	mov    %edx,%esi
  800d3d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d3f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d42:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d45:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d48:	89 ec                	mov    %ebp,%esp
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_yield>:

void
sys_yield(void)
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
  800d60:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d65:	89 d1                	mov    %edx,%ecx
  800d67:	89 d3                	mov    %edx,%ebx
  800d69:	89 d7                	mov    %edx,%edi
  800d6b:	89 d6                	mov    %edx,%esi
  800d6d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d6f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d72:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d75:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d78:	89 ec                	mov    %ebp,%esp
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	83 ec 38             	sub    $0x38,%esp
  800d82:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d85:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d88:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8b:	be 00 00 00 00       	mov    $0x0,%esi
  800d90:	b8 04 00 00 00       	mov    $0x4,%eax
  800d95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d98:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9e:	89 f7                	mov    %esi,%edi
  800da0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da2:	85 c0                	test   %eax,%eax
  800da4:	7e 28                	jle    800dce <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800daa:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800db1:	00 
  800db2:	c7 44 24 08 e4 16 80 	movl   $0x8016e4,0x8(%esp)
  800db9:	00 
  800dba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc1:	00 
  800dc2:	c7 04 24 01 17 80 00 	movl   $0x801701,(%esp)
  800dc9:	e8 4a 03 00 00       	call   801118 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dce:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dd1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dd4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dd7:	89 ec                	mov    %ebp,%esp
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    

00800ddb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	83 ec 38             	sub    $0x38,%esp
  800de1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800de4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800de7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dea:	b8 05 00 00 00       	mov    $0x5,%eax
  800def:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df2:	8b 55 08             	mov    0x8(%ebp),%edx
  800df5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dfb:	8b 75 18             	mov    0x18(%ebp),%esi
  800dfe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e00:	85 c0                	test   %eax,%eax
  800e02:	7e 28                	jle    800e2c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e04:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e08:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e0f:	00 
  800e10:	c7 44 24 08 e4 16 80 	movl   $0x8016e4,0x8(%esp)
  800e17:	00 
  800e18:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e1f:	00 
  800e20:	c7 04 24 01 17 80 00 	movl   $0x801701,(%esp)
  800e27:	e8 ec 02 00 00       	call   801118 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e2c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e2f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e32:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e35:	89 ec                	mov    %ebp,%esp
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    

00800e39 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	83 ec 38             	sub    $0x38,%esp
  800e3f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e42:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e45:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e4d:	b8 06 00 00 00       	mov    $0x6,%eax
  800e52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e55:	8b 55 08             	mov    0x8(%ebp),%edx
  800e58:	89 df                	mov    %ebx,%edi
  800e5a:	89 de                	mov    %ebx,%esi
  800e5c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e5e:	85 c0                	test   %eax,%eax
  800e60:	7e 28                	jle    800e8a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e62:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e66:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e6d:	00 
  800e6e:	c7 44 24 08 e4 16 80 	movl   $0x8016e4,0x8(%esp)
  800e75:	00 
  800e76:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e7d:	00 
  800e7e:	c7 04 24 01 17 80 00 	movl   $0x801701,(%esp)
  800e85:	e8 8e 02 00 00       	call   801118 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e8a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e8d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e90:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e93:	89 ec                	mov    %ebp,%esp
  800e95:	5d                   	pop    %ebp
  800e96:	c3                   	ret    

00800e97 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	83 ec 38             	sub    $0x38,%esp
  800e9d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ea0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ea3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eab:	b8 08 00 00 00       	mov    $0x8,%eax
  800eb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb6:	89 df                	mov    %ebx,%edi
  800eb8:	89 de                	mov    %ebx,%esi
  800eba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ebc:	85 c0                	test   %eax,%eax
  800ebe:	7e 28                	jle    800ee8 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ecb:	00 
  800ecc:	c7 44 24 08 e4 16 80 	movl   $0x8016e4,0x8(%esp)
  800ed3:	00 
  800ed4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800edb:	00 
  800edc:	c7 04 24 01 17 80 00 	movl   $0x801701,(%esp)
  800ee3:	e8 30 02 00 00       	call   801118 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ee8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eeb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eee:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ef1:	89 ec                	mov    %ebp,%esp
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    

00800ef5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	83 ec 38             	sub    $0x38,%esp
  800efb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800efe:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f01:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f04:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f09:	b8 09 00 00 00       	mov    $0x9,%eax
  800f0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f11:	8b 55 08             	mov    0x8(%ebp),%edx
  800f14:	89 df                	mov    %ebx,%edi
  800f16:	89 de                	mov    %ebx,%esi
  800f18:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f1a:	85 c0                	test   %eax,%eax
  800f1c:	7e 28                	jle    800f46 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f22:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f29:	00 
  800f2a:	c7 44 24 08 e4 16 80 	movl   $0x8016e4,0x8(%esp)
  800f31:	00 
  800f32:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f39:	00 
  800f3a:	c7 04 24 01 17 80 00 	movl   $0x801701,(%esp)
  800f41:	e8 d2 01 00 00       	call   801118 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f46:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f49:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f4c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f4f:	89 ec                	mov    %ebp,%esp
  800f51:	5d                   	pop    %ebp
  800f52:	c3                   	ret    

00800f53 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	83 ec 0c             	sub    $0xc,%esp
  800f59:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f5c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f5f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f62:	be 00 00 00 00       	mov    $0x0,%esi
  800f67:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f75:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f78:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f7a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f7d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f80:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f83:	89 ec                	mov    %ebp,%esp
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    

00800f87 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	83 ec 38             	sub    $0x38,%esp
  800f8d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f90:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f93:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f96:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f9b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fa0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa3:	89 cb                	mov    %ecx,%ebx
  800fa5:	89 cf                	mov    %ecx,%edi
  800fa7:	89 ce                	mov    %ecx,%esi
  800fa9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fab:	85 c0                	test   %eax,%eax
  800fad:	7e 28                	jle    800fd7 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800faf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fb3:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800fba:	00 
  800fbb:	c7 44 24 08 e4 16 80 	movl   $0x8016e4,0x8(%esp)
  800fc2:	00 
  800fc3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fca:	00 
  800fcb:	c7 04 24 01 17 80 00 	movl   $0x801701,(%esp)
  800fd2:	e8 41 01 00 00       	call   801118 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fd7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fda:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fdd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fe0:	89 ec                	mov    %ebp,%esp
  800fe2:	5d                   	pop    %ebp
  800fe3:	c3                   	ret    
  800fe4:	66 90                	xchg   %ax,%ax
  800fe6:	66 90                	xchg   %ax,%ax
  800fe8:	66 90                	xchg   %ax,%ax
  800fea:	66 90                	xchg   %ax,%ax
  800fec:	66 90                	xchg   %ax,%ax
  800fee:	66 90                	xchg   %ax,%ax

00800ff0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	56                   	push   %esi
  800ff4:	53                   	push   %ebx
  800ff5:	83 ec 10             	sub    $0x10,%esp
  800ff8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ffb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ffe:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int ret;
	if (pg) {
  801001:	85 c0                	test   %eax,%eax
  801003:	74 0a                	je     80100f <ipc_recv+0x1f>
		ret = sys_ipc_recv(pg);
  801005:	89 04 24             	mov    %eax,(%esp)
  801008:	e8 7a ff ff ff       	call   800f87 <sys_ipc_recv>
  80100d:	eb 0c                	jmp    80101b <ipc_recv+0x2b>
	} else {
		ret = sys_ipc_recv((void*)(UTOP + 1));
  80100f:	c7 04 24 01 00 c0 ee 	movl   $0xeec00001,(%esp)
  801016:	e8 6c ff ff ff       	call   800f87 <sys_ipc_recv>
	}
	if (ret < 0) {
  80101b:	85 c0                	test   %eax,%eax
  80101d:	79 1e                	jns    80103d <ipc_recv+0x4d>
		if (!from_env_store) {
  80101f:	85 db                	test   %ebx,%ebx
  801021:	75 0a                	jne    80102d <ipc_recv+0x3d>
			*(from_env_store) = 0;
  801023:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80102a:	00 00 00 
		}
		if (!perm_store) {
  80102d:	85 f6                	test   %esi,%esi
  80102f:	75 30                	jne    801061 <ipc_recv+0x71>
			*(perm_store) = 0;
  801031:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  801038:	00 00 00 
  80103b:	eb 24                	jmp    801061 <ipc_recv+0x71>
		}
		return ret;
	}
	if (perm_store) {
  80103d:	85 f6                	test   %esi,%esi
  80103f:	74 0a                	je     80104b <ipc_recv+0x5b>
		*(perm_store) = thisenv->env_ipc_perm;
  801041:	a1 04 20 80 00       	mov    0x802004,%eax
  801046:	8b 40 78             	mov    0x78(%eax),%eax
  801049:	89 06                	mov    %eax,(%esi)
	}
	if (from_env_store) {
  80104b:	85 db                	test   %ebx,%ebx
  80104d:	74 0a                	je     801059 <ipc_recv+0x69>
		*(from_env_store) = thisenv->env_ipc_from;
  80104f:	a1 04 20 80 00       	mov    0x802004,%eax
  801054:	8b 40 74             	mov    0x74(%eax),%eax
  801057:	89 03                	mov    %eax,(%ebx)
	}
	return thisenv->env_ipc_value;
  801059:	a1 04 20 80 00       	mov    0x802004,%eax
  80105e:	8b 40 70             	mov    0x70(%eax),%eax
	// panic("ipc_recv not implemented");
	// return 0;
}
  801061:	83 c4 10             	add    $0x10,%esp
  801064:	5b                   	pop    %ebx
  801065:	5e                   	pop    %esi
  801066:	5d                   	pop    %ebp
  801067:	c3                   	ret    

00801068 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
  80106b:	57                   	push   %edi
  80106c:	56                   	push   %esi
  80106d:	53                   	push   %ebx
  80106e:	83 ec 1c             	sub    $0x1c,%esp
  801071:	8b 7d 08             	mov    0x8(%ebp),%edi
  801074:	8b 75 0c             	mov    0xc(%ebp),%esi
  801077:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  80107a:	85 db                	test   %ebx,%ebx
		pg = (void*)(UTOP + 1);
  80107c:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
  801081:	0f 44 d8             	cmove  %eax,%ebx
	}
	int ret;
	
	while (1) {
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  801084:	8b 45 14             	mov    0x14(%ebp),%eax
  801087:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80108b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80108f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801093:	89 3c 24             	mov    %edi,(%esp)
  801096:	e8 b8 fe ff ff       	call   800f53 <sys_ipc_try_send>
		if (!ret) {
  80109b:	85 c0                	test   %eax,%eax
  80109d:	74 28                	je     8010c7 <ipc_send+0x5f>
			break;
		}
		if (ret != -E_IPC_NOT_RECV) {
  80109f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8010a2:	74 1c                	je     8010c0 <ipc_send+0x58>
			panic("FATAL:ipc_send failed\n");
  8010a4:	c7 44 24 08 0f 17 80 	movl   $0x80170f,0x8(%esp)
  8010ab:	00 
  8010ac:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  8010b3:	00 
  8010b4:	c7 04 24 26 17 80 00 	movl   $0x801726,(%esp)
  8010bb:	e8 58 00 00 00       	call   801118 <_panic>
		}
		sys_yield();
  8010c0:	e8 87 fc ff ff       	call   800d4c <sys_yield>
	}
  8010c5:	eb bd                	jmp    801084 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  8010c7:	83 c4 1c             	add    $0x1c,%esp
  8010ca:	5b                   	pop    %ebx
  8010cb:	5e                   	pop    %esi
  8010cc:	5f                   	pop    %edi
  8010cd:	5d                   	pop    %ebp
  8010ce:	c3                   	ret    

008010cf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8010d5:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8010da:	39 c8                	cmp    %ecx,%eax
  8010dc:	74 17                	je     8010f5 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8010de:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8010e3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8010e6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8010ec:	8b 52 50             	mov    0x50(%edx),%edx
  8010ef:	39 ca                	cmp    %ecx,%edx
  8010f1:	75 14                	jne    801107 <ipc_find_env+0x38>
  8010f3:	eb 05                	jmp    8010fa <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8010f5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8010fa:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010fd:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801102:	8b 40 40             	mov    0x40(%eax),%eax
  801105:	eb 0e                	jmp    801115 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801107:	83 c0 01             	add    $0x1,%eax
  80110a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80110f:	75 d2                	jne    8010e3 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801111:	66 b8 00 00          	mov    $0x0,%ax
}
  801115:	5d                   	pop    %ebp
  801116:	c3                   	ret    
  801117:	90                   	nop

00801118 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801118:	55                   	push   %ebp
  801119:	89 e5                	mov    %esp,%ebp
  80111b:	56                   	push   %esi
  80111c:	53                   	push   %ebx
  80111d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801120:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801123:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801129:	e8 ee fb ff ff       	call   800d1c <sys_getenvid>
  80112e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801131:	89 54 24 10          	mov    %edx,0x10(%esp)
  801135:	8b 55 08             	mov    0x8(%ebp),%edx
  801138:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80113c:	89 74 24 08          	mov    %esi,0x8(%esp)
  801140:	89 44 24 04          	mov    %eax,0x4(%esp)
  801144:	c7 04 24 30 17 80 00 	movl   $0x801730,(%esp)
  80114b:	e8 87 f0 ff ff       	call   8001d7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801150:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801154:	8b 45 10             	mov    0x10(%ebp),%eax
  801157:	89 04 24             	mov    %eax,(%esp)
  80115a:	e8 17 f0 ff ff       	call   800176 <vcprintf>
	cprintf("\n");
  80115f:	c7 04 24 24 17 80 00 	movl   $0x801724,(%esp)
  801166:	e8 6c f0 ff ff       	call   8001d7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80116b:	cc                   	int3   
  80116c:	eb fd                	jmp    80116b <_panic+0x53>
  80116e:	66 90                	xchg   %ax,%ax

00801170 <__udivdi3>:
  801170:	83 ec 1c             	sub    $0x1c,%esp
  801173:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801177:	89 7c 24 14          	mov    %edi,0x14(%esp)
  80117b:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80117f:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801183:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801187:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  80118b:	85 c0                	test   %eax,%eax
  80118d:	89 74 24 10          	mov    %esi,0x10(%esp)
  801191:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801195:	89 ea                	mov    %ebp,%edx
  801197:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80119b:	75 33                	jne    8011d0 <__udivdi3+0x60>
  80119d:	39 e9                	cmp    %ebp,%ecx
  80119f:	77 6f                	ja     801210 <__udivdi3+0xa0>
  8011a1:	85 c9                	test   %ecx,%ecx
  8011a3:	89 ce                	mov    %ecx,%esi
  8011a5:	75 0b                	jne    8011b2 <__udivdi3+0x42>
  8011a7:	b8 01 00 00 00       	mov    $0x1,%eax
  8011ac:	31 d2                	xor    %edx,%edx
  8011ae:	f7 f1                	div    %ecx
  8011b0:	89 c6                	mov    %eax,%esi
  8011b2:	31 d2                	xor    %edx,%edx
  8011b4:	89 e8                	mov    %ebp,%eax
  8011b6:	f7 f6                	div    %esi
  8011b8:	89 c5                	mov    %eax,%ebp
  8011ba:	89 f8                	mov    %edi,%eax
  8011bc:	f7 f6                	div    %esi
  8011be:	89 ea                	mov    %ebp,%edx
  8011c0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011c4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011c8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011cc:	83 c4 1c             	add    $0x1c,%esp
  8011cf:	c3                   	ret    
  8011d0:	39 e8                	cmp    %ebp,%eax
  8011d2:	77 24                	ja     8011f8 <__udivdi3+0x88>
  8011d4:	0f bd c8             	bsr    %eax,%ecx
  8011d7:	83 f1 1f             	xor    $0x1f,%ecx
  8011da:	89 0c 24             	mov    %ecx,(%esp)
  8011dd:	75 49                	jne    801228 <__udivdi3+0xb8>
  8011df:	8b 74 24 08          	mov    0x8(%esp),%esi
  8011e3:	39 74 24 04          	cmp    %esi,0x4(%esp)
  8011e7:	0f 86 ab 00 00 00    	jbe    801298 <__udivdi3+0x128>
  8011ed:	39 e8                	cmp    %ebp,%eax
  8011ef:	0f 82 a3 00 00 00    	jb     801298 <__udivdi3+0x128>
  8011f5:	8d 76 00             	lea    0x0(%esi),%esi
  8011f8:	31 d2                	xor    %edx,%edx
  8011fa:	31 c0                	xor    %eax,%eax
  8011fc:	8b 74 24 10          	mov    0x10(%esp),%esi
  801200:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801204:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801208:	83 c4 1c             	add    $0x1c,%esp
  80120b:	c3                   	ret    
  80120c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801210:	89 f8                	mov    %edi,%eax
  801212:	f7 f1                	div    %ecx
  801214:	31 d2                	xor    %edx,%edx
  801216:	8b 74 24 10          	mov    0x10(%esp),%esi
  80121a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80121e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801222:	83 c4 1c             	add    $0x1c,%esp
  801225:	c3                   	ret    
  801226:	66 90                	xchg   %ax,%ax
  801228:	0f b6 0c 24          	movzbl (%esp),%ecx
  80122c:	89 c6                	mov    %eax,%esi
  80122e:	b8 20 00 00 00       	mov    $0x20,%eax
  801233:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801237:	2b 04 24             	sub    (%esp),%eax
  80123a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80123e:	d3 e6                	shl    %cl,%esi
  801240:	89 c1                	mov    %eax,%ecx
  801242:	d3 ed                	shr    %cl,%ebp
  801244:	0f b6 0c 24          	movzbl (%esp),%ecx
  801248:	09 f5                	or     %esi,%ebp
  80124a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80124e:	d3 e6                	shl    %cl,%esi
  801250:	89 c1                	mov    %eax,%ecx
  801252:	89 74 24 04          	mov    %esi,0x4(%esp)
  801256:	89 d6                	mov    %edx,%esi
  801258:	d3 ee                	shr    %cl,%esi
  80125a:	0f b6 0c 24          	movzbl (%esp),%ecx
  80125e:	d3 e2                	shl    %cl,%edx
  801260:	89 c1                	mov    %eax,%ecx
  801262:	d3 ef                	shr    %cl,%edi
  801264:	09 d7                	or     %edx,%edi
  801266:	89 f2                	mov    %esi,%edx
  801268:	89 f8                	mov    %edi,%eax
  80126a:	f7 f5                	div    %ebp
  80126c:	89 d6                	mov    %edx,%esi
  80126e:	89 c7                	mov    %eax,%edi
  801270:	f7 64 24 04          	mull   0x4(%esp)
  801274:	39 d6                	cmp    %edx,%esi
  801276:	72 30                	jb     8012a8 <__udivdi3+0x138>
  801278:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  80127c:	0f b6 0c 24          	movzbl (%esp),%ecx
  801280:	d3 e5                	shl    %cl,%ebp
  801282:	39 c5                	cmp    %eax,%ebp
  801284:	73 04                	jae    80128a <__udivdi3+0x11a>
  801286:	39 d6                	cmp    %edx,%esi
  801288:	74 1e                	je     8012a8 <__udivdi3+0x138>
  80128a:	89 f8                	mov    %edi,%eax
  80128c:	31 d2                	xor    %edx,%edx
  80128e:	e9 69 ff ff ff       	jmp    8011fc <__udivdi3+0x8c>
  801293:	90                   	nop
  801294:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801298:	31 d2                	xor    %edx,%edx
  80129a:	b8 01 00 00 00       	mov    $0x1,%eax
  80129f:	e9 58 ff ff ff       	jmp    8011fc <__udivdi3+0x8c>
  8012a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012a8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8012ab:	31 d2                	xor    %edx,%edx
  8012ad:	8b 74 24 10          	mov    0x10(%esp),%esi
  8012b1:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8012b5:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8012b9:	83 c4 1c             	add    $0x1c,%esp
  8012bc:	c3                   	ret    
  8012bd:	66 90                	xchg   %ax,%ax
  8012bf:	90                   	nop

008012c0 <__umoddi3>:
  8012c0:	83 ec 2c             	sub    $0x2c,%esp
  8012c3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8012c7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8012cb:	89 74 24 20          	mov    %esi,0x20(%esp)
  8012cf:	8b 74 24 38          	mov    0x38(%esp),%esi
  8012d3:	89 7c 24 24          	mov    %edi,0x24(%esp)
  8012d7:	8b 7c 24 34          	mov    0x34(%esp),%edi
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	89 c2                	mov    %eax,%edx
  8012df:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  8012e3:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8012e7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012eb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8012ef:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8012f3:	89 7c 24 18          	mov    %edi,0x18(%esp)
  8012f7:	75 1f                	jne    801318 <__umoddi3+0x58>
  8012f9:	39 fe                	cmp    %edi,%esi
  8012fb:	76 63                	jbe    801360 <__umoddi3+0xa0>
  8012fd:	89 c8                	mov    %ecx,%eax
  8012ff:	89 fa                	mov    %edi,%edx
  801301:	f7 f6                	div    %esi
  801303:	89 d0                	mov    %edx,%eax
  801305:	31 d2                	xor    %edx,%edx
  801307:	8b 74 24 20          	mov    0x20(%esp),%esi
  80130b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80130f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801313:	83 c4 2c             	add    $0x2c,%esp
  801316:	c3                   	ret    
  801317:	90                   	nop
  801318:	39 f8                	cmp    %edi,%eax
  80131a:	77 64                	ja     801380 <__umoddi3+0xc0>
  80131c:	0f bd e8             	bsr    %eax,%ebp
  80131f:	83 f5 1f             	xor    $0x1f,%ebp
  801322:	75 74                	jne    801398 <__umoddi3+0xd8>
  801324:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801328:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  80132c:	0f 87 0e 01 00 00    	ja     801440 <__umoddi3+0x180>
  801332:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801336:	29 f1                	sub    %esi,%ecx
  801338:	19 c7                	sbb    %eax,%edi
  80133a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80133e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801342:	8b 44 24 14          	mov    0x14(%esp),%eax
  801346:	8b 54 24 18          	mov    0x18(%esp),%edx
  80134a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80134e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801352:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801356:	83 c4 2c             	add    $0x2c,%esp
  801359:	c3                   	ret    
  80135a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801360:	85 f6                	test   %esi,%esi
  801362:	89 f5                	mov    %esi,%ebp
  801364:	75 0b                	jne    801371 <__umoddi3+0xb1>
  801366:	b8 01 00 00 00       	mov    $0x1,%eax
  80136b:	31 d2                	xor    %edx,%edx
  80136d:	f7 f6                	div    %esi
  80136f:	89 c5                	mov    %eax,%ebp
  801371:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801375:	31 d2                	xor    %edx,%edx
  801377:	f7 f5                	div    %ebp
  801379:	89 c8                	mov    %ecx,%eax
  80137b:	f7 f5                	div    %ebp
  80137d:	eb 84                	jmp    801303 <__umoddi3+0x43>
  80137f:	90                   	nop
  801380:	89 c8                	mov    %ecx,%eax
  801382:	89 fa                	mov    %edi,%edx
  801384:	8b 74 24 20          	mov    0x20(%esp),%esi
  801388:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80138c:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801390:	83 c4 2c             	add    $0x2c,%esp
  801393:	c3                   	ret    
  801394:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801398:	8b 44 24 10          	mov    0x10(%esp),%eax
  80139c:	be 20 00 00 00       	mov    $0x20,%esi
  8013a1:	89 e9                	mov    %ebp,%ecx
  8013a3:	29 ee                	sub    %ebp,%esi
  8013a5:	d3 e2                	shl    %cl,%edx
  8013a7:	89 f1                	mov    %esi,%ecx
  8013a9:	d3 e8                	shr    %cl,%eax
  8013ab:	89 e9                	mov    %ebp,%ecx
  8013ad:	09 d0                	or     %edx,%eax
  8013af:	89 fa                	mov    %edi,%edx
  8013b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013b5:	8b 44 24 10          	mov    0x10(%esp),%eax
  8013b9:	d3 e0                	shl    %cl,%eax
  8013bb:	89 f1                	mov    %esi,%ecx
  8013bd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013c1:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8013c5:	d3 ea                	shr    %cl,%edx
  8013c7:	89 e9                	mov    %ebp,%ecx
  8013c9:	d3 e7                	shl    %cl,%edi
  8013cb:	89 f1                	mov    %esi,%ecx
  8013cd:	d3 e8                	shr    %cl,%eax
  8013cf:	89 e9                	mov    %ebp,%ecx
  8013d1:	09 f8                	or     %edi,%eax
  8013d3:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8013d7:	f7 74 24 0c          	divl   0xc(%esp)
  8013db:	d3 e7                	shl    %cl,%edi
  8013dd:	89 7c 24 18          	mov    %edi,0x18(%esp)
  8013e1:	89 d7                	mov    %edx,%edi
  8013e3:	f7 64 24 10          	mull   0x10(%esp)
  8013e7:	39 d7                	cmp    %edx,%edi
  8013e9:	89 c1                	mov    %eax,%ecx
  8013eb:	89 54 24 14          	mov    %edx,0x14(%esp)
  8013ef:	72 3b                	jb     80142c <__umoddi3+0x16c>
  8013f1:	39 44 24 18          	cmp    %eax,0x18(%esp)
  8013f5:	72 31                	jb     801428 <__umoddi3+0x168>
  8013f7:	8b 44 24 18          	mov    0x18(%esp),%eax
  8013fb:	29 c8                	sub    %ecx,%eax
  8013fd:	19 d7                	sbb    %edx,%edi
  8013ff:	89 e9                	mov    %ebp,%ecx
  801401:	89 fa                	mov    %edi,%edx
  801403:	d3 e8                	shr    %cl,%eax
  801405:	89 f1                	mov    %esi,%ecx
  801407:	d3 e2                	shl    %cl,%edx
  801409:	89 e9                	mov    %ebp,%ecx
  80140b:	09 d0                	or     %edx,%eax
  80140d:	89 fa                	mov    %edi,%edx
  80140f:	d3 ea                	shr    %cl,%edx
  801411:	8b 74 24 20          	mov    0x20(%esp),%esi
  801415:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801419:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  80141d:	83 c4 2c             	add    $0x2c,%esp
  801420:	c3                   	ret    
  801421:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801428:	39 d7                	cmp    %edx,%edi
  80142a:	75 cb                	jne    8013f7 <__umoddi3+0x137>
  80142c:	8b 54 24 14          	mov    0x14(%esp),%edx
  801430:	89 c1                	mov    %eax,%ecx
  801432:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801436:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  80143a:	eb bb                	jmp    8013f7 <__umoddi3+0x137>
  80143c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801440:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801444:	0f 82 e8 fe ff ff    	jb     801332 <__umoddi3+0x72>
  80144a:	e9 f3 fe ff ff       	jmp    801342 <__umoddi3+0x82>
