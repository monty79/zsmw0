function ZSMW0_SHOW_WEB_OBJECT.
*"----------------------------------------------------------------------
*"*"Локальный интерфейс:
*"  IMPORTING
*"     VALUE(KEY) LIKE  ZWWWDATATAB STRUCTURE  ZWWWDATATAB
*"  EXCEPTIONS
*"      PROGRAM_NOT_FOUND
*"      CANCELED_BY_USER
*"      UPLOAD_FAILED
*"----------------------------------------------------------------------
  data: L_TEMP_FILE   like W3FILE-NAME
                    value '~wwwtmp',
        L_FILENAME    like W3FILE-NAME,
        L_PROGRAM     like W3FILE-NAME,
        L_MIMETYPE    like W3MIMEAPPL-MTYPE,
        L_INDEX       like SY-TABIX,
        L_RC          like SY-SUBRC,
        L_TEXT(72)    type C,
        L_WINDOWS(16).

  call function 'WWWPARAMS_READ'
    exporting
      RELID = KEY-RELID
      OBJID = KEY-OBJID
      NAME  = C_MIMETYPE
    importing
      VALUE = L_MIMETYPE.

  perform GET_MIMETYPES
              using
                 L_MIMETYPE
                 L_PROGRAM
                 L_RC.

  if L_RC ne 0.
*      CONCATENATE TEXT-002 L_MIMETYPE INTO L_TEXT SEPARATED BY SPACE.
*      CALL FUNCTION 'POPUP_TO_INFORM'
*           EXPORTING
*                TITEL   = TEXT-001
*                TXT1    = L_TEXT
*                TXT2    = TEXT-003
*                TXT3    = TEXT-005.
*      EXIT.
  endif.
  data LV_KEY type WWWDATATAB.
  move-corresponding KEY to LV_KEY.
  call function 'DOWNLOAD_WEB_OBJECT'
    exporting
      KEY  = LV_KEY
    changing
      TEMP = L_TEMP_FILE.

  L_FILENAME = L_TEMP_FILE.
  call function 'WS_QUERY'
    exporting
*     FILENAME       = ' '
      QUERY  = 'WS'
*     WINID  = ' '
    importing
      RETURN = L_WINDOWS.

  shift L_TEMP_FILE right.
  L_TEMP_FILE(1) = '"'.
  concatenate L_TEMP_FILE '"' into L_TEMP_FILE.
  if L_PROGRAM is initial.
    data LV_STR type STRING.
    LV_STR = L_TEMP_FILE.
    call method CL_GUI_FRONTEND_SERVICES=>EXECUTE
      exporting
        DOCUMENT               = LV_STR
      exceptions
        CNTL_ERROR             = 1
        ERROR_NO_GUI           = 2
        BAD_PARAMETER          = 3
        FILE_NOT_FOUND         = 4
        PATH_NOT_FOUND         = 5
        FILE_EXTENSION_UNKNOWN = 6
        ERROR_EXECUTE_FAILED   = 7
        SYNCHRONOUS_FAILED     = 8
        NOT_SUPPORTED_BY_GUI   = 9
        others                 = 10.
    if SY-SUBRC eq 6. "FILE_EXTENSION_UNKNOWN
      raise PROGRAM_NOT_FOUND.
    endif.

  else.
    call function 'WS_EXECUTE'
      exporting
*       document           = ' '
*       CD                 = ' '
        COMMANDLINE        = L_TEMP_FILE
*       inform             = 'X'
        PROGRAM            = L_PROGRAM
*       STAT               = ' '
*       WINID              = ' '
*       OSMAC_SCRIPT       = ' '
*       OSMAC_CREATOR      = ' '
*       WIN16_EXT          = ' '
*       EXEC_RC            = ' '
*         importing
*       rbuff              = ' '
      exceptions
        FRONTEND_ERROR     = 1
        NO_BATCH           = 2
        PROG_NOT_FOUND     = 3
        ILLEGAL_OPTION     = 4
        GUI_REFUSE_EXECUTE = 5
        others             = 6.
    if SY-SUBRC eq 3.
      raise PROGRAM_NOT_FOUND.
    endif.
  endif.
endfunction.
