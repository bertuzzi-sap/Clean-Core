"! <p class="shorttext synchronized">Unit Tests for ZCL_IM_BILLDOC_ZVIC_TEXT</p>
CLASS zcl_test_billdoc_zvic_text DEFINITION
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_im_billdoc_zvic_text.

    METHODS setup.
    METHODS text_not_created_for_non_zvic FOR TESTING.
    METHODS text_created_for_zvic         FOR TESTING.

ENDCLASS.

CLASS zcl_test_billdoc_zvic_text IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_im_billdoc_zvic_text( ).
  ENDMETHOD.

  METHOD text_not_created_for_non_zvic.
    DATA(lt_vbrk) = VALUE vbrk_tab( ( vbeln = '9000000001' fkart = 'F2' ) ).
    DATA(lt_vbrp) = VALUE vbrp_tab( ).
    TRY.
        mo_cut->if_ex_badi_billingdoc_process~change_before_update(
          CHANGING ct_vbrk = lt_vbrk
                   ct_vbrp = lt_vbrp ).
        cl_abap_unit_assert=>assert_subrc( exp = 0 ).
      CATCH cx_root INTO DATA(lx_err).
        cl_abap_unit_assert=>fail( lx_err->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD text_created_for_zvic.
    DATA(lt_vbrk) = VALUE vbrk_tab( ( vbeln = '9000000002' fkart = 'ZVIC' ) ).
    DATA(lt_vbrp) = VALUE vbrp_tab( ).
    TRY.
        mo_cut->if_ex_badi_billingdoc_process~change_before_update(
          CHANGING ct_vbrk = lt_vbrk
                   ct_vbrp = lt_vbrp ).
        cl_abap_unit_assert=>assert_subrc( exp = 0 ).
      CATCH cx_root INTO DATA(lx_err).
        cl_abap_unit_assert=>fail( lx_err->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
