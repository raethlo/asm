;AUTOR : Roman Roštar
;Asemblery - zadanie 2

;Napíšte program (v JSI), ktorý umožní používate¾ovi zada dve èíselné hodnoty. 
;Program musí obsahova procedúru, ktorá tieto dve èísla vynásobí. Procedúra musí 
;ma dva vstupné argumenty odovzdávané cez zásobník, prièom k nim bude pristupova 
;štandardným spôsobom pomocou BP registra a výsledok vráti v akumulátore. V prípade, 
;že súèin je väèší než najväèší možný vstupný operand (vzh¾adom na poèet bitov), 
;procedúra sa po skonèení inštrukciou RET musí vráti na iné miesto, než z ktorého bola 
;zavolaná inštrukciou CALL (napr. za výpis nasledujúci po CALL). Potrebné hodnoty pre 
;zmenu návratovej adresy môžete zisti napríklad pomocou debugger-a. 
;Program musí obsahova vhodné výpisy, aby bolo možné demonštrova jeho funkènos. 
;Program musí umožòova opakované zadávanie èísiel. Navrhnite vhodnú ukonèovaciu podmienku

ZAS   SEGMENT stack        ;zasobnikovy SEGMENT
        dw      100 dup (?)     ;zasobnik 200B
dno     label   word        
ZAS   ends

data    SEGMENT                 ;datovy SEGMENT

        ;buffer na nacitavanie RETazca
        buffer  db      16               ;velkost buffer
        charcnt db      0               ;tu bude pocet nacitanych znakov
        bufdata db      16 DUP(0)        ;buffer
        num1  	DW  	  0
		    num2    DW      0
		    dlzka   DB      0
        
        NEWL EQU 13,10
        TAB  EQU 9
        NEWLINE  DB NEWL,'$'
		
    ;menu
		HLAVA	DB	'',NEWL	
				DB	'Druhe zadanie z predmetu Asemblery, autor Roman Rostar',NEWL
				DB 	TAB,'Menu: ', NEWL	   
				DB 	TAB,'1. Nasobenie dvoch cisel     ',NEWL
				DB	TAB,'(ESC, ENTER) Ukonci program ', NEWL, '$'
        
		MSG_RET		DB	    'Stlacte ENTER pre navrat do menu.',NEWL,'$'	
    MSG_NUM   DB      'Zadajte cislo: $'
    ;MSG_OK    DB      'Nasobenie ok, standard RET',NEWL,'$'    
		MSG_RES   DB      'Vysledok je:',NEWL, '$'
    
    MSG_ERR_OF    DB      'ERROR: Nastalo pretecenie registra',NEWL, '$'
    MSG_ERR_LOAD  DB      'ERROr: Zadany retazec nie je cislo',NEWL, '$'
    
    dec_length		db	0

data    ends

include makra.asm

code    SEGMENT
        assume  cs: code, ds: data, ss : ZAS
  ;------------------------------------- 
  WAIT_FOR proc
    waiting:
		PRINT MSG_RET
      mov AH, 8		; nacitanie znaku
			int 21H
			cmp AL, 13		;Porovnaj ci bol stlaceny enter
		loopne waiting
		ret
	endp
  ;------------------------------------- 
  
  ;------------------------------------- 
  ;procedura, predpoklada, ze  v bx je cislo, ktore sa bude prevadzat
  PREVOD proc				; prevod z bytov do dekadickeho cisla
		mov dec_length, 0	;dlzka decimalneho cisla = pocet cifier zatial 0
	DEC_DIVISION:
		xor dx, dx			;uvodny xor
		mov cx, 10
		
		mov ax, bx 		     ;do ax nacitame nase cislo
		div cx			       ;predelime desiatmi
		mov bx, ax		    ;do bx skopirujeme obsah ax, tj predelene cislo
		push dx			      ;do dx hodime cifru
		inc dec_length		;pridame jednu cifru
		cmp bx, 0			    ;skontrolujeme ci este mame cifry v bx
		jz DEC_PRINT
		jmp DEC_DIVISION
		
	DEC_PRINT:	    	 ;vypisanie dekadickeho cisla
		pop dx		       ;cifru vytiahneme z dx
		add dx, 30h      ;posun na zaciatok cisel
		mov ah, 02h			 ;funkcia na print cisla
		int 21h
		dec dec_length		; posun o cifru dalej
		cmp dec_length, 0
		jz  navrat ;uz sme vypisali cele cislo
		jmp DEC_PRINT
	navrat:
		ret	
	endp PREVOD
  ;------------------------------------- 
  
  ;------------------------------------- 
  ;procedura na nacitanie cisla - cislo odovzda v AX
  LOAD_NUM proc NEAR    
    ;nacita retazec do bufferu
    MOV AH, 0AH
    MOV DX, OFFSET buffer
    INT 21h
            
    XOR AX, AX                  ;premaze                  
    MOV SI, OFFSET bufdata      ;nacita sa adresa prveho znaku
    MOV CX, 10                  ;zaklad sustavy        
load_prevod:
    MOV BL, DS:[SI]             ;nacita byte z adresy v reg. SI
    INC SI                      ;posun na adresu dalsieho znaku
        
    ;ak znak nie je cislica, koniec a nastav carry
    CMP BL, '0'
    STC                
	  JB  load_ends
        
    CMP BL, '9'
    STC
    JA  load_ends
        
    ;prida cislicu k doposial spracovanim cifram cisla
    SUB BL, '0'                 ;znak -> cislo
    XOR BH, BH                  ;nuluje horny byte registra BX
    MUL CX                      ;DX:AX = AX * CX (t.j AX = AX * 10)  
    
    ADD AX, BX                  ;prida sa nova cifra
    JMP load_prevod        
load_ends:
        RET
LOAD_NUM endp
;------------------------------------- 

;-------------------------------------
;Procedura na vynasobenie dvoch cisel
;ocakava dve cisla ako argumenty
;navratova hodnota sa nachadza v ax
MULTIPLY proc
  ret        
MULTIPLY endp
;------------------------------------- 
       
  START:
    ;nacitanie programu
    MOV   AX, SEG DATA
		MOV   DS, AX
    MOV 	AX, SEG ZAS
    MOV 	SS, AX
    MOV   SP, OFFSET DNO
    
    PRINT HLAVA
work:
    CLC
    PRINT MSG_NUM
    call LOAD_NUM
    jc  err_load
    MOV num1, AX
    mov num1, BX
    call PREVOD
    call WAIT_FOR
    jmp final

err_load:
    PRINT MSG_ERR_LOAD
    CLC
    ;jmp work
    
final:
    mov AH, 4CH
		int 21H

  CODE ENDS
  END START