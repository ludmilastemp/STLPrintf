
;************************************************
;♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*
;                 MY STL PRINTF!!!
;♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*♥*
;************************************************

;************************************************
;               section libraryFunc
;________________________________________________
extern _GetStdHandle@4              ;kernel32.dll
extern _WriteConsoleA@20            ;kernel32.dll
;________________________________________________


;************************************************
;               section globalFunc
;________________________________________________
global _STLPrintf
;________________________________________________


;************************************************
;               section constants
;________________________________________________
BufferSize                      equ 50
BufferReserveBeforeOverflow     equ 15
BitMaskFirstBit                 equ 80000000h
NStdHandle                      equ -11
NewLine                         equ 10
PrintfSpecifier                 equ '%'

SpecifierLiteralPercentage      equ '%'
SpecifierSingleCharacter        equ 'c'
SpecifierCharacterString        equ 's'
SpecifierSignedInteger          equ 'd'
SpecifierByteRepresentation     equ 'b'
SpecifierOctalRepresentation    equ 'o'
SpecifierHexRepresentation      equ 'x'
;________________________________________________


;************************************************
;               section functions
;________________________________________________
section .text

;************************************************
; My STLPrintf
; Entry: stack with arguments
; Exit:  None
; Destr: EAX, EBX, ECX, EDX, ESI, EDI
;************************************************
_STLPrintf:

        push ebp

        ; Save ptr to the first argument to ebp
        mov  ebp, esp

        ; Skip ebp and return address
        add  ebp, 4 + 4

        ; Save pointer to format string
        mov ecx, [ebp]
        add ebp, 4

        ; Save counter in buffer to ebx
        xor ebx, ebx

        ; Number of warning 0
        mov [IncorrectSpec], ebx

.ProcessString:

        cmp ebx, BufferSize - BufferReserveBeforeOverflow
        call BufferOverflow

        ; Save specifier '%' to dh
        mov dh, PrintfSpecifier
        call PutsInBuffer

        call ProcessSpecifier

        ; Check if the format string has ended
        cmp byte [ecx], 0
        je .Exit

        jmp .ProcessString

.Exit:
        call PrintWarning
        call PutsInConsole

        pop ebp

        ret

;**********************************************
; Processing of specifiers STLPrintf
; Entry: EBX - counter in buffer
;        ECX - ptr to fmt string
;        EBP - ptr to arg in stack
; Exit:  None
; Destr: EAX, EBX, ECX, EDX, ESI, EDI, EBP
;**********************************************
ProcessSpecifier:

        ; Check that it is a specifier
        cmp byte [ecx], PrintfSpecifier
        jne .Exit

        inc ecx

        ; Save specifier to dl
        xor edx, edx
        mov dl, [ecx]
        inc ecx

        cmp dl, PrintfSpecifier
        je .LiteralPercentage

        sub dl, 'a'
        cmp dl, 0
        jb .IncorrectSpecifier

        cmp dl, 'z' - 'a'
        ja .IncorrectSpecifier

        jmp [JmpTable + edx * 4]

.LiteralPercentage:
        mov [ebx + buffer], dl
        inc ebx

        jmp .Exit

.SingleCharacter:
        mov dl, [ebp]
        add ebp, 4

        jmp .LiteralPercentage

.CharacterString:
        push ecx
        mov ecx, [ebp]
        add ebp, 4
        mov dh,  0

        call PutsInBuffer

        pop ecx

        jmp .Exit

.SignedInteger:
        mov esi, 10d

        call PrintDecimalNumber

        jmp .Exit

.ByteRepresentation:
        mov al,  1

        call PrintBinaryNumber

        jmp .Exit

.OctalRepresentation:
        mov al,  3

        call PrintBinaryNumber

        jmp .Exit

.HexRepresentation:
        mov al,  4

        call PrintBinaryNumber

        jmp .Exit

.IncorrectSpecifier:
        call IncorrectSpecifier

        jmp .Exit

.Exit:
        ret

; *********************************************
; Print binary number to buffer
; Entry: EBX - counter in buffer
;        EBP - ptr to arg in stack
;        AL  - number of bytes in symbol
; Exit:  None
; Destr: EAX, EBX, EDX, EBP
; **********************************************
PrintBinaryNumber:

        push ecx

        ; Save number to edx
        mov edx, [ebp]
        add ebp, 4

        ; Save bit mask to eax
        xor ecx, ecx
        mov cl, al
        mov eax, 1
        shl eax, cl
        dec eax

        xor edi, edi

.loopPushInStack:

        ; Save number and bit mask to esi
        mov esi, edx
        and esi, eax

        ; Save inverted number to edi
        shl edi, cl
        or  edi, esi

        shr edx, cl
        inc ch

        cmp edx, 0
        jne .loopPushInStack

.loopPrintInBuffer:

        ; Save symbol to esi
        mov esi, edi
        and esi, eax
        shr edi, cl

        call PutHexSymbolInBuffer

        dec ch
        cmp ch, 0
        jne .loopPrintInBuffer

        pop ecx

        ret

; *********************************************
; Print decimal number to buffer
; Entry: ESI - number system
;        EBX - counter in buffer
;        EBP - ptr to arg in stack
; Exit:  None
; Destr: EAX, EBX, EBP, EDX
; **********************************************
PrintDecimalNumber:

        push ecx

        ; Save number to eax
        mov eax, [ebp]
        add ebp, 4

        xor ecx, ecx
        xor edx, edx

        ; Check negative number
        mov edx, BitMaskFirstBit
        and edx, eax
        cmp edx, 0
        je .loopPushInStack

        mov edx, '-'
        mov [ebx + buffer], edx
        inc ebx
        neg eax

.loopPushInStack:

        ; Push symbols
        xor edx, edx
        div esi
        push edx

        inc ch
        cmp eax, 0
        jne .loopPushInStack

.loopPrintInBuffer:

        pop esi
        call PutHexSymbolInBuffer

        dec ch
        cmp ch, 0
        jne .loopPrintInBuffer

        pop ecx

        ret

; *********************************************
; Put hex symbol to buffer
; Entry: EBX - counter in buffer
;        ESI - number
; Exit:  None
; Destr: EBX, ESI
; **********************************************
PutHexSymbolInBuffer:

        mov esi, [esi + HexSymbols]
        mov [ebx + buffer], esi
        inc ebx

        ret

;**********************************************
; Process incorrect specifier
; Entry: ECX - ptr to fmt string
; Exit:  None
; Destr: EAX, EDX, EBP
;**********************************************
IncorrectSpecifier:

        add ebp, 4

        xor eax, eax
        mov al, [IncorrectSpec]
        inc al
        mov [IncorrectSpec], al

        add dl, 'a'
        mov [IncorrectSpec + eax], dl

        ret

;**********************************************
; Print warning message
; Entry: ECX - ptr to fmt string
; Exit:  None
; Destr: EAX, ECX, EDX, ESI
;**********************************************
PrintWarning:

        xor eax, eax
        xor edx, edx
        mov dl,  [IncorrectSpec]

        cmp dl, 0
        je .Exit

        mov esi, 1

.loop:
        push edx

        ; Print TextWarning
        xor dh, dh
        mov ecx, TextWarning
        call PutsInBuffer

        ; Print specifier
        mov dl, [IncorrectSpec + esi]
        mov [buffer + ebx], dl
        inc esi
        inc ebx

        pop edx

        dec dl
        cmp dl, 0
        jne .loop

        mov [buffer + ebx], byte NewLine
        mov [buffer + ebx + 1], byte NewLine
        add ebx, 2

.Exit:

        ret

; *********************************************
; Puts to buffer before specifier or '\0'
; Entry: EBX - counter in buffer
;        ECX - ptr to fmt string
;        DH  - specifier
; Exit:  DL - next symbol
; Destr: EAX, EBX, ECX, EDX, ESI, EDI
; **********************************************
PutsInBuffer:

        cmp ebx, BufferSize - BufferReserveBeforeOverflow
        call BufferOverflow

        ; Save next character in string to dl
        mov dl, [ecx]

        ; Check specifier and '\0'
        cmp dl, dh
        je .Exit
        cmp dl, 0
        je .Exit

        mov [ebx + buffer], dl

        inc ebx
        inc ecx

        jmp PutsInBuffer

.Exit:
        ret

;**********************************************
; Puts in buffer to console
; Entry: EBX - counter in buffer
; Exit:  None
; Destr: EAX, EBX, EDX, ESI, EDI
;**********************************************
PutsInConsole:

        push ecx

        ; HANDLE WINAPI GetStdHandle (
        ;   _In_ DWORD nStdHandle          (NStdHandle)
        ; );
        ; Save return value to eax

        push dword NStdHandle
        call _GetStdHandle@4

        ;
        ; BOOL WINAPI WriteConsole (
        ;   _In_             HANDLE  hConsoleOutput,         (eax)
        ;   _In_       const VOID    *lpBuffer,              (buffer)
        ;   _In_             DWORD   nNumberOfCharsToWrite,  (ebx)
        ;   _Out_opt_        LPDWORD lpNumberOfCharsWritten, (0)
        ;   _Reserved_       LPVOID  lpReserved              (0)
        ; );
        ;

        xor  edx, edx
        push edx
        push edx
        push ebx
        push buffer
        push eax
        call _WriteConsoleA@20

        xor ebx, ebx

        pop ecx

        ret

;**********************************************
; Buffer overflow
; Entry: EBX - counter in buffer
; Exit:  None
; Destr: EAX, EBX, ESI, EDI
;**********************************************
BufferOverflow:

        push edx

        call PutsInConsole

        pop edx

        ret

;________________________________________________


;************************************************
;               section data
;________________________________________________
section .data
HexSymbols      db "0123456789ABCDEF"
buffer          db BufferSize DUP 0
IncorrectSpec   db BufferSize DUP 0
TextWarning     db NewLine, "Warning: Incorrect specifier %", 0
;________________________________________________


;************************************************
;               section JmpTable
;________________________________________________
JmpTable:
        dd      'b' - 'a' DUP ProcessSpecifier.IncorrectSpecifier
        dd      ProcessSpecifier.ByteRepresentation      ;%b
        dd      ProcessSpecifier.SingleCharacter         ;%c
        dd      ProcessSpecifier.SignedInteger           ;%d
        dd      'o' - 'd' - 1 DUP ProcessSpecifier.IncorrectSpecifier
        dd      ProcessSpecifier.OctalRepresentation     ;%o
        dd      's' - 'o' - 1 DUP ProcessSpecifier.IncorrectSpecifier
        dd      ProcessSpecifier.CharacterString         ;%s
        dd      'x' - 's' - 1 DUP ProcessSpecifier.IncorrectSpecifier
        dd      ProcessSpecifier.HexRepresentation       ;%x
        dd      'z' - 'x' DUP ProcessSpecifier.IncorrectSpecifier
;________________________________________________

