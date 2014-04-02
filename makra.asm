  ;makro na vycistenie obrazovky aka clrscr
  CLRSCR  macro
	  mov AX,3
	  int 10H
  endm

  ;makro s parametrom na vypis retazca
  PRINT	macro TEXT
    mov ah,9
    mov dx,offset TEXT
    int 21h
  endm