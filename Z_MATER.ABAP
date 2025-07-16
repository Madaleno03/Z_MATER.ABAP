*&---------------------------------------------------------------------*
*& Report Z_CADASTRO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_CADASTRO.

* DECLARANDO A TABELA QUE IREI USAR
TABLES: ZT0005.

* CRIANDO TABELA INTERNA
DATA: T_ITEM     TYPE TABLE OF ZT0005,
      T_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
      T_SORT     TYPE SLIS_T_SORTINFO_ALV,
      T_HEADER   TYPE SLIS_T_LISTHEADER.

* CRIANDO WORK AREA
DATA: W_ITEM     TYPE ZT0005,
      W_FIELDCAT TYPE SLIS_FIELDCAT_ALV,
      W_LAYOUT   TYPE SLIS_LAYOUT_ALV,
      W_SORT     TYPE SLIS_SORTINFO_ALV,
      W_HEADER   TYPE SLIS_LISTHEADER.

* CRIANDO VARIAVEL GLOBAL
DATA: GT_DADOS TYPE TABLE OF ZT0005,
      GS_DADOS TYPE ZT0005,
      GV_MATER TYPE ZT0005-MATER.


* INICIANDO A SELECAO DE DADOS
START-OF-SELECTION.
SELECT *
  FROM ZT0005
  INTO TABLE T_ITEM.
END-OF-SELECTION.

* CRIANDO ROTINA DE DADOS COM PERFOM
PERFORM F_LAYOUT.
PERFORM F_FIELDCAT.
PERFORM F_SORT.
PERFORM F_DISPLAY.
*&---------------------------------------------------------------------*
*& Form F_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_layout .

* CRIANDO DETALHES DO LAYOUT
  W_LAYOUT-ZEBRA = 'X'.
  W_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_FIELDCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_fieldcat .

* UTILIZANDO A FUNCAO PARA CRIAR O FIELCAT
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
   EXPORTING
     I_PROGRAM_NAME               = SY-REPID
     I_INTERNAL_TABNAME           = 'T_ITEM'
     I_STRUCTURE_NAME             = 'ZT0005'

    CHANGING
      ct_fieldcat                  = T_FIELDCAT
   EXCEPTIONS
     INCONSISTENT_INTERFACE       = 1
     PROGRAM_ERROR                = 2
     OTHERS                       = 3.

  IF sy-subrc <> 0.
     MESSAGE TEXT-001 TYPE 'I'. "Erro na definicao do FIELDCAT!
  ENDIF.

* HABILITANDO HOTSPOT NO CAMPO "MATER"
LOOP AT T_FIELDCAT INTO W_FIELDCAT.
  IF W_FIELDCAT-FIELDNAME = 'MATER'.
     W_FIELDCAT-HOTSPOT   = 'X'.
     MODIFY T_FIELDCAT FROM W_FIELDCAT.
     ENDIF.
      ENDLOOP.

* HABILITANDO HOTSPOT NO CAMPO BRGEW
LOOP AT T_FIELDCAT INTO W_FIELDCAT.
  IF W_FIELDCAT-FIELDNAME = 'BRGEW'.
    W_FIELDCAT-HOTSPOT    = 'X'.
    MODIFY T_FIELDCAT FROM W_FIELDCAT.
    ENDIF.
    ENDLOOP.

* HABILITANDO HOTSPOT NO CAMPO NTGEW
LOOP AT T_FIELDCAT INTO W_FIELDCAT.
  IF W_FIELDCAT-FIELDNAME = 'NTGEW'.
    W_FIELDCAT-HOTSPOT    = 'X'.
    MODIFY T_FIELDCAT FROM W_FIELDCAT.
    ENDIF.
    ENDLOOP.

* SOMANDO O CAMPO BRGEW E O CAMPO NTGEW
LOOP AT T_FIELDCAT INTO W_FIELDCAT.
  CASE W_FIELDCAT-FIELDNAME.
  WHEN 'BRGEW'. "PESO BRUTO
  W_FIELDCAT-DO_SUM = 'X'.
  WHEN 'NTGEW'. "PESO LIQUIDO
  W_FIELDCAT-DO_SUM = 'X'.
  ENDCASE.
  MODIFY T_FIELDCAT FROM W_FIELDCAT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_sort .

  CLEAR W_SORT.
  W_SORT-SPOS      = 1.
  W_SORT-TABNAME   = 'T_ITEM'.
  W_SORT-FIELDNAME = 'MATER'.
  W_SORT-UP        = 'X'.
  APPEND W_SORT TO T_SORT.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_HEADER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_header .

CLEAR   T_HEADER.
REFRESH T_HEADER.

* CRIANDO VARIAIVEL LOCAL
  DATA: VL_DATA TYPE SY-DATUM,
        VL_HORA TYPE SY-UZEIT,
        VL_USER TYPE SY-UNAME.

* CHAMANDO AS VARIAIVEIS DECLARADAS
  VL_DATA = SY-DATUM.
  VL_HORA = SY-UZEIT.
  VL_USER = SY-UNAME.

  WRITE: SY-DATUM TO VL_DATA DD/MM/YY.
  WRITE: SY-UZEIT TO VL_HORA.
  WRITE: SY-UNAME TO VL_USER.

* CRIANDO O CABECALHO
  CLEAR W_HEADER.
  W_HEADER-TYP = 'H'.
  W_HEADER-INFO = 'Relatório de materiais.'.
  APPEND W_HEADER TO T_HEADER.

  CLEAR W_HEADER.
  W_HEADER-TYP  = 'S'.
  W_HEADER-INFO = VL_DATA.
  W_HEADER-KEY  = 'DATA: '.
  APPEND W_HEADER TO T_HEADER.

  CLEAR W_HEADER.
  W_HEADER-TYP  = 'S'.
  W_HEADER-INFO = VL_HORA.
  W_HEADER-KEY  = 'HORA: '.
  APPEND W_HEADER TO T_HEADER.

  CLEAR  W_HEADER.
  W_HEADER-TYP  = 'S'.
  W_HEADER-INFO = VL_USER.
  W_HEADER-KEY  = 'USER: '.
  APPEND W_HEADER TO T_HEADER.


* FUNCAO PARA EXIBIR O CABECALHO.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary       = T_HEADER
      I_LOGO                   = 'ENJOYSAP_LOGO'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_display .

* CRIANDO O RELATORIO ALV POR FUNCAO
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
   EXPORTING
     I_CALLBACK_PROGRAM                = SY-REPID
     I_CALLBACK_TOP_OF_PAGE            = 'F_HEADER'
     I_CALLBACK_USER_COMMAND           = 'F_USER_COMMAND'
     IS_LAYOUT                         = W_LAYOUT
     IT_FIELDCAT                       = T_FIELDCAT
     IT_SORT                           = T_SORT
     I_DEFAULT                         = 'X'
     I_SAVE                            = 'X'
    TABLES
      t_outtab                         = T_ITEM
   EXCEPTIONS
     PROGRAM_ERROR                     = 1
     OTHERS                            = 2.
  IF sy-subrc <> 0.
    MESSAGE TEXT-005  TYPE  'I'. "Erro ao exibir o relatorio!
  ENDIF.
  ENDFORM.

FORM F_USER_COMMAND USING R_UCOMM LIKE SY-UCOMM           "r_ucomm: guarda o comando de usuário (como '&IC1', que representa clique em hotspot
                          RS_SELFIELD TYPE SLIS_SELFIELD. "rs_selfield: contém dados da célula que foi clicada (nome do campo, valor, posição, etc.

 CASE R_UCOMM.
   WHEN '&IC1'.
     IF RS_SELFIELD-FIELDNAME = 'MATER'. "Verifica se o clique foi no campo MATER (ou seja, o hotspot estava na coluna "MATER").
       READ TABLE T_ITEM INTO W_ITEM INDEX RS_SELFIELD-TABINDEX." Busca na tabela interna T_ITEM a linha correspondente à linha clicada, com base no índice tabindex (linha do ALV que foi clicada), e coloca na work area W_ITEM.
       IF SY-SUBRC = 0.
         SET PARAMETER ID 'MAT' FIELD W_ITEM-MATER.
           CALL SCREEN 0100. "TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
       ENDIF.
       ENDIF.
       ENDCASE.

ENDFORM.