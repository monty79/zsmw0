FUNCTION ZSMW0_PARAMS_DELETE.
*"--------------------------------------------------------------------
*"*"Локальный интерфейс:
*"  IMPORTING
*"     VALUE(RELID) LIKE  WWWPARAMS-RELID
*"     VALUE(OBJID) LIKE  WWWPARAMS-OBJID
*"     VALUE(NAME) TYPE  C
*"  EXCEPTIONS
*"      ENTRY_NOT_EXISTS
*"--------------------------------------------------------------------

  DELETE FROM WWWPARAMS WHERE RELID   = RELID
                          AND OBJID   = OBJID
                          AND NAME    = NAME.
  IF SY-SUBRC NE 0.
     RAISE ENTRY_NOT_EXISTS .
  ENDIF.
ENDFUNCTION.
