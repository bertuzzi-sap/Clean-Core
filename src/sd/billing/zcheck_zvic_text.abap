REPORT zcheck_zvic_text.

PARAMETERS: p_vbeln TYPE vbeln_vf OBLIGATORY.

START-OF-SELECTION.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id       = 'ZSUP'
      language = 'I'
      name     = p_vbeln
      object   = 'VBBK'
    EXCEPTIONS
      OTHERS   = 1.

  IF sy-subrc = 0.
    MESSAGE |Text ZSUP found for { p_vbeln }| TYPE 'S'.
  ELSE.
    MESSAGE |Text ZSUP NOT found for { p_vbeln }| TYPE 'W'.
  ENDIF.
