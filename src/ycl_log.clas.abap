"! <p class="shorttext synchronized" lang="en">YLog Logger Class</p>
"!
"! @author FX
"! @version 0.1
"!
CLASS ycl_log DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CONSTANTS assert  TYPE ylog_dt_level VALUE -1 ##NO_TEXT.
    CONSTANTS error   TYPE ylog_dt_level VALUE 0 ##NO_TEXT.
    CONSTANTS warning TYPE ylog_dt_level VALUE 2 ##NO_TEXT.
    CONSTANTS info    TYPE ylog_dt_level VALUE 3 ##NO_TEXT.
    CONSTANTS debug   TYPE ylog_dt_level VALUE 9 ##NO_TEXT.

    "! <p class="shorttext synchronized" lang="en">Log a message to the system, according to level customizing</p>
    "!
    "! @parameter level | level of the log message (n.b. ASSERT will override all level configuration)
    "! @parameter world | world/family of the log message generator
    "! @parameter tag | class/module of the log message generator
    "! @parameter method | method/routine that generates the log message
    "! @parameter msg | log message
    "! @parameter object | additional variable to be logged into the clustered db - only considered if level is DEBUG
    CLASS-METHODS log
      IMPORTING
        !level  TYPE ylog_dt_level
        !world  TYPE ylog_dt_world OPTIONAL
        !tag    TYPE ylog_dt_tag
        !method TYPE ylog_dt_method
        !msg    TYPE string
        !object TYPE any OPTIONAL.

    CLASS-METHODS set_log_level
      IMPORTING
        !level TYPE i .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA level TYPE i .

    CLASS-METHODS is_loggable
      IMPORTING
        !level             TYPE ylog_dt_level
        !world             TYPE ylog_dt_world OPTIONAL
        !tag               TYPE ylog_dt_tag
      RETURNING
        VALUE(is_loggable) TYPE abap_bool.

    CLASS-METHODS output
      IMPORTING
        !tag    TYPE ylog_dt_tag
        !method TYPE ylog_dt_method
        !msg    TYPE string
        !level  TYPE ylog_dt_level .

    CLASS-METHODS write_db
      IMPORTING
        !level  TYPE ylog_dt_level
        !world  TYPE ylog_dt_world OPTIONAL
        !tag    TYPE ylog_dt_tag
        !method TYPE ylog_dt_method
        !msg    TYPE string
        !object TYPE any OPTIONAL .

    CLASS-METHODS dump_object
      IMPORTING
        !object     TYPE any
      RETURNING
        VALUE(guid) TYPE guid_32.
ENDCLASS.


CLASS ycl_log IMPLEMENTATION.

  METHOD log.
    DATA ls_log         TYPE ylog_log.
    DATA lv_timestamp   TYPE timestampl.
    DATA is_loggable    TYPE abap_bool.

    "--> if message is an ASSERT, enable log without checking the customizing.
    IF level <= ycl_log=>assert.
      is_loggable = abap_true.
    ELSE.
      IF world IS SUPPLIED.
        is_loggable = ycl_log=>is_loggable( level = level world = world tag = tag ).
      ELSE.
        is_loggable = ycl_log=>is_loggable( level = level tag = tag ).
      ENDIF.
    ENDIF.

    IF is_loggable = abap_false. RETURN. ENDIF.

    ycl_log=>output( tag = tag method = method msg = msg level = level ).

    "--> database log
    GET TIME STAMP FIELD lv_timestamp.

    ls_log-log_level = level.
    ls_log-log_ts = lv_timestamp.
    ls_log-log_date = sy-datlo.
    ls_log-log_time = sy-timlo.
    ls_log-log_user = sy-uname.
    ls_log-tag = tag.
    ls_log-method = method.
    ls_log-message = msg.

    IF world IS SUPPLIED. ls_log-world = world. ENDIF.

    "--> object export to cluster db
    IF object IS SUPPLIED AND level = ycl_log=>debug.
      ls_log-dump_id = ycl_log=>dump_object( object ).
    ENDIF.

    INSERT ylog_log FROM ls_log.
    COMMIT WORK.

  ENDMETHOD.

  METHOD is_loggable.
    DATA lv_level TYPE ylog_dt_level.

    is_loggable = abap_false. "--> default behaviour

    IF world IS SUPPLIED.

      "--> search by world and user
      SELECT SINGLE log_level INTO lv_level FROM ylog_config WHERE log_user = sy-uname AND world = world AND log_level >= level.
      IF sy-subrc IS INITIAL. is_loggable = abap_true. RETURN. ENDIF. "--> found. return true.

      "--> search by world
      SELECT SINGLE log_level INTO lv_level FROM ylog_config WHERE world = world AND log_level >= level.
      IF sy-subrc IS INITIAL. is_loggable = abap_true. RETURN. ENDIF. "--> found. return true.

    ELSE.

      "--> search by tag and user
      SELECT SINGLE log_level INTO lv_level FROM ylog_config WHERE log_user = sy-uname AND tag = tag AND log_level >= level.
      IF sy-subrc IS INITIAL. is_loggable = abap_true. RETURN. ENDIF. "--> found. return true.

      "--> search by tag
      SELECT SINGLE log_level INTO lv_level FROM ylog_config WHERE tag = tag AND log_level >= level.
      IF sy-subrc IS INITIAL. is_loggable = abap_true. RETURN. ENDIF. "--> found. return true.

    ENDIF.

    "--> global level
    SELECT SINGLE log_level INTO lv_level FROM ylog_config WHERE world = '' AND log_user = '' AND tag = '' AND log_level >= level.
    IF sy-subrc IS INITIAL. is_loggable = abap_true. ENDIF.

  ENDMETHOD.

  METHOD output.
    DATA lv_output  TYPE string.
    DATA lv_date    TYPE string.
    DATA lv_level   TYPE string.

    CASE level.
      WHEN ycl_log=>assert. lv_level = 'WTF!'.
      WHEN OTHERS. MOVE level TO lv_level.
    ENDCASE.

    CONCATENATE sy-datlo ':' sy-timlo '-' lv_level '-' tag '/' method '():' msg INTO lv_output.
*    lv_output = sy-datlo | ':' | sy-timlo | '-' | lv_level | '-' | tag | '/' | method | '():' | msg.
    WRITE: / lv_output.
  ENDMETHOD.

  METHOD set_log_level.
    ycl_log=>level = level.
  ENDMETHOD.

  METHOD dump_object.
    DATA lv_guid    TYPE guid_32.
    DATA lo_ex      TYPE REF TO cx_root.
    DATA lv_msg     TYPE string.

    TRY.
        lv_guid = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_uuid_error INTO lo_ex.
        ycl_log=>log( level = ycl_log=>assert world = 'YLOG' tag = 'YCL_LOG' method = 'DUMP_OBJECT' msg = lo_ex->get_text( ) ).
    ENDTRY.

    TRY.
        EXPORT object FROM object TO DATABASE indx(yl) ID lv_guid.
        guid = lv_guid.
      CATCH cx_root INTO lo_ex.
        ycl_log=>log( level = ycl_log=>assert world = 'YLOG' tag = 'YCL_LOG' method = 'DUMP_OBJECT' msg = lo_ex->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD write_db.

  ENDMETHOD.
ENDCLASS.
