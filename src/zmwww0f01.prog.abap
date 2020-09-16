*-------------------------------------------------------------------
***INCLUDE MWWW0F01 .
*-------------------------------------------------------------------

*&---------------------------------------------------------------------*
*&      Form  CHECK_EXISTENCE
*&---------------------------------------------------------------------*
form CHECK_EXISTENCE.
  data: LV_OBJID like WWWDATA-OBJID.

  if WWWDATA_NEW-OBJID is initial.
    message E004. " Укажите имя для объекта.
  endif.
  select single OBJID
    from WWWDATA
    into LV_OBJID
    where RELID = WWWDATA_NEW-RELID
      and OBJID = WWWDATA_NEW-OBJID.
  if SY-SUBRC = 0.                    "already exists
    message E001 with WWWDATA_NEW-OBJID. " Подлежащий созданию объект & уже существует.
  endif.
endform.                               " CHECK_EXISTENCE

*&---------------------------------------------------------------------*
*&      Form  SELECT_DATA
*&---------------------------------------------------------------------*
form SELECT_DATA.
  ranges: SO_OBJID for  WWWDATA_TAB-OBJID,
          SO_TEXT  for  WWWDATA_TAB-TEXT,
          SO_DEVCL for  TADIR-DEVCLASS.
  data:  L_OBJECT like TADIR-OBJECT,
         L_LINES  type SY-TABIX.
  import SO_OBJID SO_TEXT SO_DEVCL from memory id '%_RSWWWSHW_SEL'.
  get parameter id 'DVC' field SO_DEVCL-LOW.
  TADIR-DEVCLASS = SO_DEVCL-LOW.
  describe table WWWDATA_TAB lines L_LINES.
  if L_LINES is initial or SY-UCOMM = 'HRFR'.
    concatenate 'W3' GC_RELID into L_OBJECT.

    select * from WWWDATA as F
      inner join TADIR as P
      on F~OBJID = P~OBJ_NAME
      into corresponding fields of table WWWDATA_TAB
      where F~TEXT in SO_TEXT
        and F~SRTF2 = 0
        and F~RELID = GC_RELID
        and P~PGMID    = 'R3TR'
        and P~OBJECT   = L_OBJECT
        and P~DEVCLASS in SO_DEVCL
        and P~OBJ_NAME in SO_OBJID.
    sort WWWDATA_TAB by DEVCLASS OBJID ascending.
*--------------------------------------------------------------------*
*    Довыберем MIMETYPE для удобства
    data LT_PARAMS type standard table of WWWPARAMS.
    constants
    : LC_MIMETYPE type W3_NAME value 'mimetype'             "#EC NOTEXT
    , LC_EXT      type W3_NAME value 'fileextension'        "#EC NOTEXT
    , LC_SIZE      type W3_NAME value 'filesize'            "#EC NOTEXT
    .
    select OBJID VALUE NAME
      into corresponding fields of table LT_PARAMS
      from WWWPARAMS
      for all entries in WWWDATA_TAB
      where RELID = GC_RELID
        and OBJID = WWWDATA_TAB-OBJID
        and ( NAME = LC_MIMETYPE
            or NAME = LC_EXT
            or NAME = LC_SIZE
            ).
    sort LT_PARAMS by OBJID.
    field-symbols <FS_WWDATA> like line of WWWDATA_TAB.
    field-symbols <FS_PAR> like line of LT_PARAMS.
    loop at WWWDATA_TAB assigning <FS_WWDATA>.
      read table LT_PARAMS transporting no fields
        with key OBJID = <FS_WWDATA>-OBJID binary search.
      if SY-SUBRC <> 0.
        continue.
      endif.
      loop at LT_PARAMS assigning <FS_PAR> from SY-TABIX.
        if <FS_PAR>-OBJID <> <FS_WWDATA>-OBJID.
          exit. "loop.
        endif.
        case <FS_PAR>-NAME.
          when LC_MIMETYPE.
            <FS_WWDATA>-MIMETYPE = <FS_PAR>-VALUE.
          when LC_EXT.
            <FS_WWDATA>-FILEEXTENSION = <FS_PAR>-VALUE.
          when LC_SIZE.
            <FS_WWDATA>-FILESIZE = <FS_PAR>-VALUE.
        endcase.

      endloop.
    endloop.
*--------------------------------------------------------------------*
  endif.
endform.                               " SELECT_DATA

*&---------------------------------------------------------------------*
*&      Form  MAINTAIN_MIMETYPES
*&---------------------------------------------------------------------*
form MAINTAIN_MIMETYPES.
  data: SELTAB like RSPARAMS occurs 0 with header line,
        L_MIME like MIMETYPES.
  move:
        'I1'        to SELTAB-SELNAME,
        'S'         to SELTAB-KIND.
  append SELTAB.
  select count(*) from MIMETYPES.
  if SY-DBCNT = 0.                    " no entries yet
    L_MIME-TYPE      = 'text/html'.                         "#EC NOTEXT
    L_MIME-EXTENSION = '*.htm, *.html'.
    insert into MIMETYPES values L_MIME. "#ZVUL_SCI_S_73_001 Это копия стандарта вообще!
    call function 'DB_COMMIT'.
  endif.
  call function 'RS_TABLE_LIST_CREATE'
    exporting
      TABLE_NAME = 'MIMETYPES'
      ACTION     = 'ANZE'
    tables
      SELTAB     = SELTAB.

endform.                               " MAINTAIN_MIMETYPES

*&---------------------------------------------------------------------*
*&      Form  LAUNCH_THE_SEARCH
*&---------------------------------------------------------------------*
form LAUNCH_THE_SEARCH.
  data BACK.      "r_back is space -> F3 pressed else r_back = N

*  submit RSWWWSHW " вместо этого он заинклужен как подэкран в 0100
*  submit ZSMW0_RSWWWSHW
*    via selection-screen with R_RELID = Gc_RELID
*      with R_TITLE = OBJECT_TYPE_NAME
*      and  return.

  import BACK from memory id GC_WEBRFC .
  if BACK = 'N'.
    clear BACK.
    export BACK to memory id GC_WEBRFC. "reset flag for next run
    OBJECT_LIST-TOP_LINE = 1.
    call screen 200.
  endif.
endform.                               " LAUNCH_THE_SEARCH

form USER_COMMAND_0200.
  SAVE_UCOMM = SY-UCOMM.
  clear SY-UCOMM.
  case SAVE_UCOMM.
    when SPACE.
      "nothing
    when 'HCRE'.                       "WWW Template anlegen
      if OBJECT_SELECTED is initial.
        WWWDATA_NEW-RELID = GC_RELID.
        call screen 300 starting at 20 4 ending at 85 8.
        SY-UCOMM = 'HRFR'.
        perform SELECT_DATA.
      endif.
    when 'HPRF'.                       " Preferences
      call function 'WWW_SETTINGS'.
    when 'HSRS'.
      call function 'WWW_SETTINGS_CLEAR'.
    when 'HMIM'.
      perform MAINTAIN_MIMETYPES.
    when 'HRFR'.
      perform SELECT_DATA.
    when 'ENDE'.                       "Beenden
      leave program.
    when 'BACK'.
      refresh WWWDATA_TAB.
      ONE_SCREEN_BACK.
    when others.
      if OBJECT_SELECTED <> 0.
        OBJECT_SELECTED = 0.
      else.
        message I006. "Выберите запись.
        set screen 200.
      endif.
  endcase.
endform.

form USER_COMMAND_0300.
  SAVE_UCOMM = SY-UCOMM.
  clear SY-UCOMM.

  case SAVE_UCOMM.
    when 'CRBK'.                       "Abbrechen
      ONE_SCREEN_BACK.
    when 'HIMP'.                       "Weiter
      call function 'ENQUEUE_E_WWW_HTML'
        exporting
          MODE_WWWDATA = 'E'
          RELID        = WWWDATA_NEW-RELID
          OBJID        = WWWDATA_NEW-OBJID
          SRTF2        = 0
        exceptions
          FOREIGN_LOCK = 1.
      if SY-SUBRC = 1.
        message I007 with WWWDATA_NEW-OBJID. "Объект & уже обрабатывается.
        clear SY-UCOMM.
        ONE_SCREEN_BACK.
      endif.
      data LS_WWWDATA_NEW type WWWDATATAB.
      LS_WWWDATA_NEW = WWWDATA_NEW.
      call function 'UPLOAD_WEB_OBJECT'
        exporting
          KEY = LS_WWWDATA_NEW.
      call function 'DEQUEUE_E_WWW_HTML'
        exporting
          MODE_WWWDATA = 'E'
          RELID        = WWWDATA_NEW-RELID
          OBJID        = WWWDATA_NEW-OBJID
          SRTF2        = 0.
      ONE_SCREEN_BACK.
  endcase.
endform.

form USER_COMMAND_0500.
  data LS_OBJDATA type WWWDATATAB.
  case SY-UCOMM.
    when 'CRBK'.                       "Abbrechen
      ONE_SCREEN_BACK.
    when 'HCPY'.                       "Weiter
      call function 'ENQUEUE_E_WWW_HTML'
        exporting
          MODE_WWWDATA = 'E'
          RELID        = WWWDATA_NEW-RELID
          OBJID        = WWWDATA_NEW-OBJID
          SRTF2        = 0
        exceptions
          FOREIGN_LOCK = 1.
      if SY-SUBRC = 1.
        message I007 with WWWDATA_NEW-OBJID.
        clear SY-UCOMM.
        ONE_SCREEN_BACK.
      endif.
      LS_OBJDATA = OBJDATA.
      data LS_WWWDATA_NEW type WWWDATATAB.
      LS_WWWDATA_NEW = WWWDATA_NEW.
      call function 'COPY_WEB_OBJECT'
        exporting
          NEWKEY = LS_WWWDATA_NEW
          OLDKEY = LS_OBJDATA.
      call function 'DEQUEUE_E_WWW_HTML'
        exporting
          MODE_WWWDATA = 'E'
          RELID        = WWWDATA_NEW-RELID
          OBJID        = WWWDATA_NEW-OBJID
          SRTF2        = 0.
      clear WWWDATA_NEW.
      ONE_SCREEN_BACK.
  endcase.
endform.

form OBJECT_LIST_COMMAND.
  data LS_OBJDATA type WWWDATATAB.
  data G_ANSWER type CHAR1.

  SAVE_UCOMM = SY-UCOMM.
  if not ( SEL_FIELD is initial ).
    OBJECT_SELECTED = 1.               " mind. ein Objekt selektiert
    read table WWWDATA_TAB
      into OBJDATA
      index OBJECT_LIST-CURRENT_LINE.
    if SY-SUBRC = 0 and SY-UCOMM ne SPACE.
      LS_OBJDATA = OBJDATA.
      if SAVE_UCOMM = 'HPAR'.
*        call function 'WWWPARAMS_MAINTAIN'
        call function 'ZSMW0_PARAMS_MAINTAIN'
          exporting
            KEY = LS_OBJDATA.
      else.
        if SAVE_UCOMM = 'HMOD' or
           SAVE_UCOMM = 'HDES' or
           SAVE_UCOMM = 'HDEL' or
           SAVE_UCOMM = 'HIMP'.
          call function 'ENQUEUE_E_WWW_HTML'
            exporting
              MODE_WWWDATA = 'E'
              RELID        = OBJDATA-RELID
              OBJID        = OBJDATA-OBJID
              SRTF2        = 0
            exceptions
              FOREIGN_LOCK = 1.
          if SY-SUBRC = 1.
            message I007 with OBJDATA-OBJID. "Объект & уже обрабатывается.
            clear SY-UCOMM.
            exit.
          endif.
        endif.
        case SAVE_UCOMM.
          when 'HCPY'.
            call screen 500 starting at 20 4 ending at 85 8.
          when 'HEXP'.                 "Exportieren
            call function 'DOWNLOAD_WEB_OBJECT'
              exporting
                KEY = LS_OBJDATA.

          when 'HMOD'.
            call function 'MODIFY_WEB_OBJECT'
              exporting
                KEY               = LS_OBJDATA
              exceptions
                CANCELED_BY_USER  = 2
                PROGRAM_NOT_FOUND = 3.
            if SY-SUBRC = 3.
              message I008. "Нет программы для обработки Web-объекта.
            endif.

          when 'HANZ'.
*            call function 'SHOW_WEB_OBJECT'.
            call function 'ZSMW0_SHOW_WEB_OBJECT'
              exporting
                KEY               = OBJDATA " Здесь расширенная структ.
              exceptions
                CANCELED_BY_USER  = 2
                PROGRAM_NOT_FOUND = 3.
            if SY-SUBRC = 3.
              message I008. " Нет программы для обработки Web-объекта.
            endif.

          when 'HDES'.
            call screen 400
              starting at 20 4 ending at 85 8.

          when 'HDEL'.
            call function 'POPUP_TO_CONFIRM_WITH_VALUE'
              exporting
                OBJECTVALUE = OBJDATA-OBJID
                TEXT_AFTER  = TEXT-008
                TEXT_BEFORE = TEXT-007
                TITEL       = TEXT-009
              importing
                ANSWER      = G_ANSWER.

            if G_ANSWER = 'J'.
              call function 'DELETE_WEB_OBJECT'
                exporting
                  KEY = LS_OBJDATA.
            endif.
          when 'HIMP'.
            perform L_UPLOAD_WEB_TEMPLATE.
          when 'WB_VERSION'.
*            ITS_TRANSP = LS_OBJDATA.
*            append ITS_TRANSP.
        endcase.
        call function 'DEQUEUE_E_WWW_HTML'
          exporting
            MODE_WWWDATA = 'E'
            RELID        = OBJDATA-RELID
            OBJID        = OBJDATA-OBJID
            SRTF2        = 0.

        if SAVE_UCOMM = 'HMOD' or
           SAVE_UCOMM = 'HDES' or
           SAVE_UCOMM = 'HDEL' or
           SAVE_UCOMM = 'HIMP' or
           SAVE_UCOMM = 'HCPY'.
          SAVE_UCOMM = 'HRFR'.
        endif.
      endif.
    endif.
  endif.
  SY-UCOMM = SAVE_UCOMM.
endform.

form USER_COMMAND_0400.
  data LS_OBJDATA type WWWDATATAB.
  data SAVE_UCOMM type SYUCOMM.

  SAVE_UCOMM = SY-UCOMM.
  clear   SY-UCOMM.

  case SAVE_UCOMM.
    when 'CRBK'.                       "Abbrechen
      ONE_SCREEN_BACK.

    when 'HSAV'.                       "Ändern
      LS_OBJDATA = OBJDATA.
      call function 'MODIFY_WEB_OBJECT_DESCRIPTION'
        exporting
          KEY    = LS_OBJDATA
        exceptions
          others = 1.
      if SY-SUBRC = 0.
        ONE_SCREEN_BACK.
      endif.
  endcase.
endform.


*---------------------------------------------------------------------*
*       FORM L_UPLOAD_WEB_TEMPLATE                                    *
*---------------------------------------------------------------------*
form L_UPLOAD_WEB_TEMPLATE.
  data: L_ANSWER.
  call function 'POPUP_TO_CONFIRM_STEP'
    exporting
      TEXTLINE1 = TEXT-001
      TEXTLINE2 = TEXT-002
      TITEL     = TEXT-003
    importing
      ANSWER    = L_ANSWER.
  if L_ANSWER <> 'J'.
    exit.
  endif.
  data LS_OBJDATA type WWWDATATAB.
  LS_OBJDATA = OBJDATA.
  call function 'UPLOAD_WEB_OBJECT'
    exporting
      KEY = LS_OBJDATA.
endform.
