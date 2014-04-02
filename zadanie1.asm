; Zadanie c.1
; Roman Roöt·r
;
; TEXT ZADANIA
;	NapÌöte program (v JSI), ktor˝ umoûnÌ pouûÌvatelovi pomocou menu nasleduj˙ce akcie: zadat meno s˙boru, vypÌsat obsah s˙boru, vypÌsat dlûku s˙boru
;	(v desiatkovej s˙stave, v bajtoch), vykonat pridelen˙ ˙lohu, ukoncit program. Program nacÌta volbu pouûÌvatela z kl·vesnice. Program sa musÌ ukoncit aj po stlacenÌ kl·vesu "ESCAPE".
;	V programe vhodne pouûite makro s parametrom, ako aj vhodnÈ volania OS (resp. BIOS) pre nacÌtanie znaku, nastavenie kurzora, v˝pis retazca, zmazanie obrazovky a pod. Na spracovanie pola
;	znakov musia byt vhodne pouûitÈ retazcovÈ inötrukcie. Pridelen· ˙loha musÌ byt realizovan· ako extern· proced˙ra (kompilovan· samostatne a prilinkovan· k v˝slednÈmu programu).
;	DefinÌcie makier musia byt v samostatnom s˙bore. Program musÌ korektne spracovat s˙bory s dlûkou aspon do 128 kB. Pri cÌtanÌ vyuûite pole vhodnej velkosti (buffer), pricom zo s˙boru do
;	pam‰te sa bude pres˙vat vûdy (aû na poslednÈ cÌtanie) cel· velkost pola. Oöetrite chybovÈ stavy.
;
; DOPLNKOVA ULOHA
; NaËÌtaù reùazec a vypÌsaù poËet jeho v˝skytov (ako podreùazca) v s˙bore.
;PREKLAD:         [cesta]\tasm /l/zi/c subor.asm
;LINKOVANIE:      [cesta]\tlink /l/i/v subor.obj
;POMOCNE PROGRAMY:[cesta]\thelp\help.exe, abshelp.exe
;                 [cesta]\tasm\thelp.com
;                 [cesta]\ng\ng.exe


ZAS   segment stack 'stack'												        ;zaciatok zasobnikoveho segmentu
      dw 64 dup(?)																	      ;definicia 64-och slov v pamati
ZAS   ENDS                                                ;koniec zasobnikoveho segmentu

DATA	SEGMENT
    ;zaciatok datoveho segmentu

    ;misc
    NEWL EQU 13,10
    TAB EQU 9
    NEWLINE   DB NEWL,'$'
    TESTFILE  DB 'ahoj.txt',0,'$'

    ;menu
    MENU  	  DB NEWL,'ASM Zadanie 1. -- Autor: Roman Rostar (c)',NEWL,'MENU :',NEWL
		    	    DB TAB,'1. Nacitat subor',NEWL
		    		  DB TAB,'2. Vypisat obsah suboru',NEWL
        		  DB TAB,'3. Zistit pocet vyskytov slova v subore',NEWL
        		  DB TAB,'4. Zmazat obrazovku a vypisat menu',NEWL,'$'
              DB TAB,'[ESC,ENTER pre vypnutie programu',NEWL,'$'
    UNKNWN    DB 'Neznamy prikaz',NEWL,'$'

    ;messages
    MSG_BACK  DB 'Stlacte ENTER pre navrat do menu',NEWL,'$'
    MSG_RETURN_ENTER		DB	NEWL,'Stlacte ENTER pre navrat do hlavneho menu.$'
    MSG_FILE_NAME DB  'Zadajte meno suboru',NEWL,'$'

    ;error messages
    ERROR     DB 'Error: Not yet implemented!',NEWL,'$'
    ERROR_FL  DB 'Nastala chyba pri otvarani suboru',NEWL,'$'
    ;
    ;File handle suboru
    HANDLE    DW 0
    FILENAME  DB 100 dup (?)
    FN_LEN    DB 0
    BUFFER    DB 100 dup (?)  
DATA ENDS

include makra.asm

CODE SEGMENT
ASSUME CS:CODE,DS:DATA,SS:ZAS  ;makro na vycistenie obrazovky aka clrscr

  WAIT_FOR proc
    waiting:
		PRINT MSG_RETURN_ENTER
      mov AH, 8		; nacitanie znaku
			int 21H
			cmp AL, 13		;Porovnaj ci bol stlaceny enter
		loopne waiting
		ret
	endp
  
  READNAME proc
    ;PRINT MSG_FILE_NAME
    lea BX, FILENAME
    reading:      
      mov AH, 1		; nacitanie znaku
			int 21H
			cmp AL, 13		;Porovnaj ci bol stlaceny enter
      jz  return    ;ak hej skoncili sme 
      mov [BX],AL   ;
      inc BX
      inc FN_LEN
      jmp reading
    return:
      mov AL,'$'
      mov [BX],AL
      ;PRINT FILE
      mov AH, FN_LEN  ;necham v AH dlzku mena
		  ret
  endp
    
  START:
    ;nacitanie programu
    MOV AX, SEG DATA
		MOV DS, AX
clear:
    CLRSCR   
vyp_menu:
    PRINT MENU
select:
		mov  ah,1
		int  21h
		cmp al,'1'			;nacitaj subor
		jz load_file
		cmp al, '2' 		;vypis subor
		jz output_file
		cmp al, '3'     ;pocet vyskytov v subore
		jz occur
    cmp al,'4'			;zmaz obrazovku,vypis menu
		jz clear
		cmp al, 27 ; esc na ukoncenie
		jz quit
		cmp al, 13 ;enter na ukoncenie
		jz quit
    PRINT NEWLINE
    PRINT UNKNWN  ;ak stlatcil nieco ine
    ;PRINT NEWL
    jmp select

load_file:
    PRINT NEWLINE
    call READNAME
    cmp AH,0
    jz  nenacitane
    mov AH, 3DH ; FCIA NA OTVORENIE SUBORU
    mov AL, 0   ; 0= READ-ONLY ACCESS
    mov DX, OFFSET FILENAME
    int 21H
    ;ak bola chyba tak ideme prec
    jc file_err   
    
    mov handle,ax ;nebola chyba
    PRINT handle
    jmp vyp_menu
     
nenacitane:
    PRINT NEWLINE
    PRINT ERROR
    call WAITING
    jmp vyp_menu
file_err:
    PRINT NEWLINE
    PRINT ERROR_FL
    call WAIT_FOR
    jmp vyp_menu

output_file:
    ;PRINT NEWLINE
    ;PRINT ERROR
    call READNAME
    call WAIT_FOR
    ; TODO
    ;   pozret ci je nacitany handle
    ;   vypisat podla toho error (najprv nacitajte subor) alebo ist dalej
    ;   potom cyklicky citat po 100 bajtoch cely subor
    jmp vyp_menu

occur:
    PRINT NEWLINE
    PRINT ERROR
    jmp vyp_menu

quit:
    ;ukoncenie programu
    mov ax,handle
    cmp ax, 0
    jz final
    mov bx, ax  ;nacitam filehandle
    mov ah, 3Eh ;fcia na zavretie handle
    int 21h
    PRINT TESTFILE
    PRINT NEWLINE
    PRINT FILENAME
final:
    mov AH, 4CH
		int 21H

  CODE ENDS
  END START