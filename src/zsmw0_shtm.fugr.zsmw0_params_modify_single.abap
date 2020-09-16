FUNCTION ZSMW0_PARAMS_MODIFY_SINGLE.
*"--------------------------------------------------------------------
*"*"Локальный интерфейс:
*"  IMPORTING
*"     VALUE(PARAMS) LIKE  WWWPARAMS STRUCTURE  WWWPARAMS
*"  EXCEPTIONS
*"      MODIFY_ERROR
*"--------------------------------------------------------------------
    WWWPARAMS = PARAMS.
    MODIFY WWWPARAMS.
    IF SY-SUBRC NE 0.
       RAISE MODIFY_ERROR.
    ENDIF.
ENDFUNCTION.
