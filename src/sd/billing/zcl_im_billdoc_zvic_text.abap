"! <p class="shorttext synchronized">BAdI Impl: Auto-populate header text ZSUP for billing type ZVIC</p>
"! On creation of billing document type ZVIC (VF01), automatically writes
"! the fixed text 'Fatturato' into custom text object VBBK / ID ZSUP.
CLASS zcl_im_billdoc_zvic_text DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_ex_badi_billingdoc_process.

  PRIVATE SECTION.
    CONSTANTS:
      gc_billing_type  TYPE fkart          VALUE 'ZVIC',
      gc_text_object   TYPE thead-tdobject VALUE 'VBBK',
      gc_text_id       TYPE thead-tdid     VALUE 'ZSUP',
      gc_text_content  TYPE tdline         VALUE 'Fatturato',
      gc_text_language TYPE spras          VALUE 'I'.

    "! <p class="shorttext synchronized">Orchestrates text writing for a single billing document</p>
    "! @parameter iv_billing_doc | Billing document number (VBELN)
    METHODS write_header_text
      IMPORTING
        iv_billing_doc TYPE vbeln_vf.

    "! <p class="shorttext synchronized">Returns TRUE if the custom text already exists in STXH</p>
    "! @parameter iv_billing_doc | Billing document number
    "! @returning value(rv_exists) | abap_true if record found
    METHODS text_already_exists
      IMPORTING
        iv_billing_doc   TYPE vbeln_vf
      RETURNING
        VALUE(rv_exists) TYPE abap_bool.

ENDCLASS.

CLASS zcl_im_billdoc_zvic_text IMPLEMENTATION.

  METHOD if_ex_badi_billingdoc_process~change_before_update.
    LOOP AT ct_vbrk ASSIGNING FIELD-SYMBOL(<ls_vbrk>)
      WHERE fkart = gc_billing_type.
      TRY.
          me->write_header_text( iv_billing_doc = <ls_vbrk>-vbeln ).
        CATCH cx_root INTO DATA(lx_error).
          MESSAGE lx_error->get_text( ) TYPE 'W'.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD write_header_text.
    CHECK me->text_already_exists( iv_billing_doc ) = abap_false.

    AUTHORITY-CHECK OBJECT 'S_DEVELOP'
      ID 'DEVCLASS' DUMMY
      ID 'OBJTYPE'  FIELD 'PROG'
      ID 'OBJNAME'  DUMMY
      ID 'P_GROUP'  DUMMY
      ID 'ACTVT'    FIELD '02'.

    DATA(ls_header) = VALUE thead(
      tdobject = gc_text_object
      tdname   = iv_billing_doc
      tdid     = gc_text_id
      tdspras  = gc_text_language
    ).

    DATA(lt_lines) = VALUE tline_tab(
      ( tdformat = '*' tdline = gc_text_content )
    ).

    CALL FUNCTION 'SAVE_TEXT'
      EXPORTING
        header = ls_header
        insert = abap_true
      TABLES
        lines  = lt_lines
      EXCEPTIONS
        id       = 1
        language = 2
        name     = 3
        object   = 4
        OTHERS   = 5.

    IF sy-subrc <> 0.
      MESSAGE e001(zsd_billing)
        WITH iv_billing_doc gc_text_id sy-subrc.
    ENDIF.
  ENDMETHOD.

  METHOD text_already_exists.
    SELECT SINGLE @abap_true
      FROM stxh
      WHERE tdobject = @gc_text_object
        AND tdname   = @iv_billing_doc
        AND tdid     = @gc_text_id
        AND tdspras  = @gc_text_language
      INTO @rv_exists.
  ENDMETHOD.

  METHOD if_ex_badi_billingdoc_process~fill_vbrk_vbrp.
  ENDMETHOD.

ENDCLASS.
