*********************************************************************
REPORT zfm_visu_mandati.

*** Tables
TABLES: zsfprovve,
        zfm_liq_t,
        zfm_liq_r,
        zfm_mand_r,
        kblp,
        fmci. "mod EB170616

*** Type-pools
TYPE-POOLS:
slis.

*** Criteri di Selezione
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME.
  SELECT-OPTIONS: "Start MOD CA 09/07/2025 nuova select options per Corte Dei conti MEV 112
                  s_aa_pdc FOR zfm_liq_t-anno_mandato NO INTERVALS NO-EXTENSION DEFAULT sy-datum(4)
                           MODIF ID pdc,
                  "End MOD CA 09/07/2025 nuova select options per Corte Dei conti MEV 112
                  s_mndt   FOR zfm_liq_t-nr_mandato
                           MODIF ID mdm MATCHCODE OBJECT zh_mandato,
                  s_dt_mdt FOR zfm_liq_t-dt_mandato,
                  s_aa_mdt FOR zfm_liq_t-anno_mandato
                  "Start MOD CA 09/07/2025 aggiunta ID per nascondere in Corte Dei Conti MEV 112
                           MODIF ID mdt,
                  "End MOD CA 09/07/2025 aggiunta ID per nascondere in Corte Dei Conti MEV 112
                  s_aa_liq FOR zfm_liq_t-aa_liq, "insert EB250516
                  s_nr_liq FOR zfm_liq_t-n_liq,
                  s_nreint FOR zfm_liq_t-znum_reintegro,    "LS260318
                  s_gsa    FOR fmci-zzsf_gsa
                           NO INTERVALS MATCHCODE OBJECT zh_zzsf_gsa.
*>>>AG100516
  SELECTION-SCREEN: SKIP.
  SELECT-OPTIONS: s_fistl  FOR zfm_liq_r-fistl NO INTERVALS, "G4DK909753
                  s_fipex  FOR zfm_liq_r-fipex,
                  s_geber  FOR zfm_liq_r-geber,
                  s_fdatk  FOR kblp-fdatk NO-DISPLAY,
                  s_imp    FOR zfm_liq_r-impegno,
                  s_fin    FOR zfm_liq_r-z_conto_fin, "insert EB110516
*Start MOD BCSOFT 24/03/2025 aggiunta Select Options su data scadenza impegno
                  s_scad_i FOR kblp-fdatk,
*End MOD BCSOFT 24/03/2025 aggiunta Select Options su data scadenza impegno
                  s_stato  FOR zfm_liq_t-stato, "insert EB110516
*                  s_sta_m  FOR zfm_mand_r-STATO_MAND, "arosati 17.01.2025
                  s_ben    FOR zfm_liq_r-num_ben, "insert EB250516
                  s_altben FOR zfm_liq_r-codice_ben_alt, " insert EB090616
                  s_cpudt  FOR zfm_liq_t-cpudt_mod.
*<<<AG100516
  PARAMETERS: p_gdurc TYPE n LENGTH 3.
*Start AGu 15/10/2025
  SELECT-OPTIONS: s_cig FOR zsfprovve-zsfcig,
                  s_cup FOR zfm_liq_r-zsfcup.
*End AGu 15/10/2025
SELECTION-SCREEN: END OF BLOCK b1.

*>>>AG100517 Id.152 modifiche per cruscotto atto
SELECTION-SCREEN: BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_anno_p FOR zfm_liq_t-anno_prop   NO INTERVALS,
                  s_atto_p FOR zfm_liq_t-nr_proposta NO INTERVALS,
                  s_dir_p  FOR zfm_liq_t-dir_prop    NO INTERVALS,
                  s_tipo_p FOR zfm_liq_t-tipo_prop   NO INTERVALS.

  SELECTION-SCREEN: SKIP.
  SELECT-OPTIONS: s_anno_d FOR zfm_liq_t-zzanno_prov NO INTERVALS,
                  s_atto_d FOR zfm_liq_t-zznum_prov  NO INTERVALS,
                  s_dir_d  FOR zfm_liq_t-zzdir_provv NO INTERVALS,
                  s_tipo_d FOR zfm_liq_t-zztipo_prov NO INTERVALS,
*Start MOD BCSOFT aggiunta data provveddimento
                  s_data_p FOR zfm_liq_t-zzdata_provv NO INTERVALS.
*End MOD BCSOFT aggiunta data provvedimento
SELECTION-SCREEN: END OF BLOCK b2.
*<<<AG100517

*Start MOD BCSOFT 25/07/2024
SELECTION-SCREEN: BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-002.
  PARAMETERS: p_layout TYPE slis_vari.
SELECTION-SCREEN: END OF BLOCK b3.

SELECTION-SCREEN: BEGIN OF BLOCK b4 WITH FRAME.
  PARAMETERS: cb_cesp AS CHECKBOX,
*Start MOD CA 01/07/2025 checkbox informazioni aggiuntive MEV 121
              cb_info AS CHECKBOX MODIF ID inf.
*End MOD CA 01/07/2025 checkbox informazioni aggiuntive MEV 121
SELECTION-SCREEN: END OF BLOCK b4.
*End MOD BCSOFT 25/07/2024

*** Costanti
CONSTANTS:
   p_fikrs TYPE fikrs VALUE '1000'. "insert EB070616

*** Tabelle interne, variabili e varie
##NEEDED

*Start MOD BCSOFT 24/03/2024 nuovo type per aggiunta colonne per fondo
TYPES BEGIN OF ty_def.
INCLUDE STRUCTURE zfm_lista_info_mandati.
TYPES: copertura                   TYPE char35,
       asset(10),
*Start MOD CA 23/06/2025 aggiunta colonne al type della tabella di output dell'ALV per MEV 112
       num_doc_collegato           LIKE zsfprovve-num_doc_collegato,
       pos_doc_collegato           LIKE zsfprovve-pos_doc_collegato,
*§---> Start Paganof - 21.01.2026 10:39:02 - Mev 112 Macroaggregato
*       zzsf_categorie              LIKE fmci-zzsf_categorie,
       zzmacroaggr                 LIKE fmci-zzmacroaggr,
*§---> End Paganof - 21.01.2026 10:39:14
       descr_cap_usc(250),
       cap_ent                     LIKE zdash_acc-fipos,
       descr_cap_ent(250),
       perimetro_gsa(2),
       "Chiavi di Accesso ai Testi Standard dei Capitoli
       cap_usc_txt_key(70),
       cap_ent_txt_key(70),
       cig_cup(51),
       imp_quiet_prec              LIKE zfm_mand_r-imp_quiet,
       "Chiavi di Accesso ai Testi Standard degli Impegnu
       key_txt_imp                 LIKE vbdpa-tdname,
*End MOD CA 23/06/2025 aggiunta colonne al type della tabella di output dell'ALV per MEV 112
*Start MOD CA 04/07/2025 aggiunta colonne al type della tabella di output dell'ALV per MEV 121
       descrizione_mandato         LIKE zfm_mand_t-causale,
       descrizione_dg_prop_mandato LIKE zfm_strorg_edma-descr_str_e,
       data_provved                LIKE zsfprovve-data_provved,
       desc_provv                  LIKE zsfprovve-desc_provv,
       dg_prop_imp                 LIKE zsfprovve-dir_prop,
       descrizione_dg_prop_impegno LIKE zfm_strorg_edma-descr_str_e,
*End MOD CA 04/07/2025 aggiunta colonne al type della tabella di output dell'ALV per MEV 121
*§---> Start Paganof - 11.02.2026 - 2-2190730999
       annullo_singolo             TYPE zfm_liq_r-annullo_singolo,
*§---> End Paganof - 11.02.2026 16:43:35
       END OF ty_def.
*End MOD BCSOFT 24/03/2024 nuovo type per aggiunta colonne per fondo

DATA:
  w_lista     TYPE zfm_lista_info_mandati,
*Start MOD BCSOFT cambio i types  di riferimento per aggiunta colonne sul fondo
*  i_lista     TYPE STANDARD TABLE OF zfm_lista_info_mandati,
  i_lista     TYPE STANDARD TABLE OF ty_def,
*  i_lista_def TYPE STANDARD TABLE OF zfm_lista_info_mandati. "insert EB070616
  i_lista_def TYPE STANDARD TABLE OF ty_def.
*End MOD BCSOFT cambio i types  di riferimento per aggiunta colonne sul fondo

*** G4DK907706 - BEG
##NEEDED
DATA:
  tb_1251  TYPE STANDARD TABLE OF agr_1251,
  wa_1251  TYPE agr_1251,
  tb_users TYPE STANDARD TABLE OF agr_users,
  wa_users TYPE agr_users.
*** G4DK907706 - END

*§---> Start Paganof - 13.06.2025 Range di filtro
DATA: gr_dir_p TYPE RANGE OF zfm_liq_t-dir_prop,
      sr_dir_p LIKE LINE OF gr_dir_p,
      gr_dir_d TYPE RANGE OF zfm_liq_t-zzdir_provv,
      sr_dir_d LIKE LINE OF gr_dir_d.
*§---> End Paganof - 13.06.2025

*** G4DK908267 - BEG
SELECT-OPTIONS: z_dir_p FOR zfm_liq_t-dir_prop
                        NO INTERVALS NO-DISPLAY,
                z_dir_d FOR zfm_liq_t-zzdir_provv
                        NO INTERVALS NO-DISPLAY.
##NEEDED
DATA:
  flag_am TYPE char01,
  t_lista TYPE STANDARD TABLE OF zfm_lista_info_mandati.
*** G4DK908267 - END
*** G4DK909753 - BEG
SELECT-OPTIONS: z_fistl FOR zfm_liq_r-fistl
                        NO INTERVALS NO-DISPLAY.
*** G4DK909753 - END
##NEEDED
DATA:
  st_layout  TYPE slis_layout_alv,
  i_fieldcat TYPE slis_t_fieldcat_alv.
##NEEDED
DATA:
  lv_imp_liq  TYPE zimp_liq,
  lv_imp_net  TYPE zimp_net,
  lv_imp_rit  TYPE zimp_rit,
  bdcdata     LIKE bdcdata
               OCCURS 0 WITH HEADER LINE,
  dt_lim_durc TYPE lfa1-datadurc.
##NEEDED
FIELD-SYMBOLS:
*Start MOD BCSOFT cambio i types  di riferimento per aggiunta colonne sul fondo
*  <wa> TYPE zfm_lista_info_mandati.
  <wa> TYPE ty_def.
*End MOD BCSOFT cambio i types  di riferimento per aggiunta colonne sul fondo

DATA gv_no_data.

*Start MOD BCSOFT 26/07/2024
DATA: rs_variant LIKE disvariant,
      g_repid    LIKE sy-repid,
      gs_variant LIKE disvariant.
*End MOD BCSOFT 26/07/2024

*Start MOD CA 23/06/2025 dichiarazione type e tabelle matchcode Conto Finanziario per MEV 112
TYPES: BEGIN OF ty_f4_values.
         INCLUDE STRUCTURE zfm_s_elenco_pdc.
TYPES:   zzsfdatanno LIKE zrac_piano_conti-zzsfdatanno,
       END OF ty_f4_values.

DATA: gt_f4_values TYPE TABLE OF ty_f4_values,
      gt_f4_return TYPE TABLE OF ddshretval.
*End MOD CA 23/06/2025 dichiarazione ttype e abelle matchcode Conto Finanziario per MEV 112

*Start MOD BCSOFT 04/10/2024
TYPES BEGIN OF ty_temp.
INCLUDE STRUCTURE zfm_lista_info_mandati.
TYPES: name1             LIKE lfa1-name1,
       name2             LIKE lfa1-name2,
       name3             LIKE lfa1-name3,
       name4             LIKE lfa1-name4,
       durc              LIKE lfa1-durc,
*Start MOD CA 23/06/2025 aggiunta colonne al type per  MEV 112
       num_doc_collegato LIKE zsfprovve-num_doc_collegato,
       pos_doc_collegato LIKE zsfprovve-pos_doc_collegato,
       "Chiave di Accesso ai Testi Standard per Impegni
       key_txt_imp       LIKE vbdpa-tdname,
*End MOD CA 23/06/2025 aggiunta colonne al type per  MEV 112
*Start MOD CA 08/07/2025 aggiunta colonne al TYPE TEMP per MEV 121
       data_provved      LIKE zsfprovve-data_provved,
       desc_provv        LIKE zsfprovve-desc_provv,
       dg_prop_imp       LIKE zsfprovve-dir_prop,
*End MOD CA 08/07/2025 aggiunta colonne al TYPE TEMP MEV 121
*§---> Start Paganof - 11.02.2026 - 2-2190730999
       annullo_singolo   TYPE zfm_liq_r-annullo_singolo,
*§---> End Paganof - 11.02.2026 16:43:35

       END OF ty_temp.

TYPES: BEGIN OF ty_mand_temp.
         INCLUDE TYPE ty_temp.
TYPES:   stato_mand LIKE zfm_mand_r-stato_mand,
       END OF ty_mand_temp.

DATA: i_lista_temp TYPE STANDARD TABLE OF ty_temp,
      lt_mand_temp TYPE STANDARD TABLE OF ty_mand_temp.
*End MOD BCSOFT 04/10/2024

*Start MOD CA 25/06/2025 dichiarazioni globali per modifica Testi Stancard MEV 112
TYPES: BEGIN OF ts_stxl_raw,
         clustr TYPE stxl-clustr,
         clustd TYPE stxl-clustd,
       END OF ts_stxl_raw.

DATA: gt_stxl_raw TYPE STANDARD TABLE OF ts_stxl_raw,
      gs_stxl_raw TYPE ts_stxl_raw,
      gt_tline    TYPE STANDARD TABLE OF tline,
      gv_string   TYPE string.
*End MOD CA 25/06/2025 dichiarazioni globali per modifica Testi Stancard MEV 112

*** Initialization
INITIALIZATION.
  CLEAR: i_lista[].                                         "G4DK907706

*  IF sy-tcode EQ 'ZVISU_MAND_CDC'.
*    sy-title = 'Lista Liquidazioni/Mandati per Corte dei Conti'.
*  ENDIF.

*Start MOD CA 02/07/2025 gestione SELECTION-SCREEN OUTPUT aggiunta per MEV 121
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 EQ 'INF'.
      IF sy-tcode NE 'ZFM_VISU_MANDATI'.
        screen-active = 0.
        screen-invisible = 1.
      ENDIF.
    ELSEIF screen-group1 EQ 'MDT'.
*      IF sy-tcode EQ 'ZVISU_MAND_CDC'.
*        screen-active = 0.
*        screen-invisible = 1.
*      ENDIF.
    ELSEIF screen-group1 EQ 'PDC'.
      IF sy-tcode EQ 'ZFM_VISU_MANDATI'.
        screen-active = 0.
        screen-invisible = 1.
      ENDIF.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.
*End MOD CA 02/07/2025 gestione SELECTION-SCREEN OUTPUT aggiunta per MEV 121

*Start MOD CA 23/06/2025 aggiunta e gestione Matchcode per campo Conto Finanziario MEV 112
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_fin-low.
  PERFORM f_matchcode_conto.

  IF gt_f4_values IS NOT INITIAL.
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield    = 'Z_CONTO_FIN'
        dynpprog    = sy-cprog
        dynpnr      = sy-dynnr
        dynprofield = 'S_FIN'
        value_org   = 'S'
      TABLES
        value_tab   = gt_f4_values
        return_tab  = gt_f4_return.
  ENDIF.

  REFRESH gt_f4_values.

  IF gt_f4_return IS NOT INITIAL.
    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
      EXPORTING
        functioncode = '/00'.
  ENDIF.
*End MOD CA 23/06/2025 aggiunta e gestione Matchcode per campo Conto Finanziario MEV 112

*Start MOD BCSOFT 26/07/2024
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_layout.
  g_repid = sy-repid.

  rs_variant-report   = g_repid.
  rs_variant-username = sy-uname.
  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = rs_variant
      i_save     = 'A'
    IMPORTING
      es_variant = rs_variant
    EXCEPTIONS
      OTHERS     = 1.
  IF sy-subrc = 0.
    p_layout = rs_variant-variant.
  ENDIF.
*End MOD BCSOFT 26/07/2024

*** Start-of-selection
START-OF-SELECTION.
*§---> Start Paganof - 13.06.2025 popolo range di filtro
  IF s_dir_p[] IS NOT INITIAL.
    gr_dir_p = s_dir_p[].
  ENDIF.
  IF s_dir_d[] IS NOT INITIAL.
    gr_dir_d = s_dir_d[].
  ENDIF.

  IF gr_dir_p IS INITIAL
    AND gr_dir_d IS NOT INITIAL.
    gr_dir_p = gr_dir_d.
  ENDIF.
  IF gr_dir_d IS INITIAL
  AND gr_dir_p IS NOT INITIAL.
    gr_dir_d = gr_dir_p.
  ENDIF.
*§---> End Paganof - 13.06.2025

*Start MOD CA 09/07/2025 valorizzo il vecchio anno mandato col nuovo per MEV 112
*  IF sy-tcode EQ 'ZVISU_MAND_CDC' AND s_aa_pdc-low IS NOT INITIAL.
*    s_aa_mdt[] =  s_aa_pdc[].
*  ENDIF.
*End MOD CA 09/07/2025 valorizzo il vecchio anno mandato col nuovo per MEV 112

  CLEAR gv_no_data.

  PERFORM coni_vis.                                         "G4DK907706

  SELECT zfm_liq_r~aa_doc_fi,
         zfm_liq_r~aa_doc_par,
         zfm_liq_t~aa_liq,
         zfm_liq_t~anno_mandato,
         zfm_liq_r~anno_paregg_parz,
         zfm_liq_t~anno_prop,
         zfm_liq_t~automatica,
         zfm_liq_r~ben_alt,
*         zfm_liq_r~blart, "arosati 31.07.2024
*        zfm_liq_r~bldat,  "arosati 31.07.2024
*         zfm_liq_r~budat, "arosati 31.07.2024
         zfm_liq_r~bukrs,
         zfm_liq_r~bvtyp,
         zfm_liq_r~bvtyp_alt,
         zfm_liq_t~causale_liq,
         zfm_liq_r~caus_ben_alt,
         zfm_liq_r~codice_ben_alt,
         zfm_liq_r~iban_alt,                                "G4DK907648
         zfm_liq_t~cpudt_ins,
         zfm_liq_t~cpudt_mod,
         zfm_liq_t~cputm_ins,
         zfm_liq_t~cputm_mod,
         zfm_liq_t~data_es_pag,
         zfm_liq_r~data_quietanza,
         zfm_liq_r~nr_avviso_pagopa,                        "G4DK907648
         zfm_liq_r~codice_fiscale_ente,                     "G4DK907648
         zfm_liq_t~dir_prop,
         zfm_liq_t~disp_cas_cap,
         zfm_liq_r~doc_paregg_parz,
         zfm_liq_t~dt_invio_teso,
         zfm_liq_t~dt_liq,
         zfm_liq_t~dt_mandato,
         zfm_liq_t~dt_quiet,
         zfm_liq_t~fikrs,
         zfm_liq_r~fipex,
         zfm_liq_r~cdr AS fistl,                            "G4DK909753
         zfm_liq_r~geber,
         zfm_liq_r~impegno,
         zfm_liq_r~importo_r,
         zfm_liq_r~importo_r AS imp_liq, "Ins GM180324 - Più chiaro nel caso di piu righe
         zfm_liq_r~imp_net, "Ins GM180324 - Più chiaro nel caso di piu righe
         zfm_liq_r~imp_quiet,
         zfm_liq_r~imp_rit, "Ins GM180324 - Più chiaro nel caso di piu righe
         zfm_liq_t~mandato_copertura,
         zfm_liq_t~mandt,
         zfm_liq_t~mand_cope,
         zfm_liq_r~mod_pag,
         zfm_liq_r~mod_pag_alt,
         zfm_liq_t~nota_prop,
         zfm_liq_t~note_mndt,
         zfm_liq_t~nr_mandato,
         zfm_liq_t~nr_proposta,
         zfm_liq_r~numero_quietanza,
         zfm_liq_r~num_ben,
         zfm_liq_r~iban,                                    "G4DK907648
         zfm_liq_r~num_doc_fi,
         zfm_liq_r~num_doc_par,
         zfm_liq_t~n_liq,
         zfm_liq_r~n_riga_liq,
         zfm_liq_r~pareggio_parziale,
         zfm_liq_r~riga_imp,
         zfm_liq_r~riga_imp_per,
*§---> Start Paganof - 11.02.2026 - 2-2190730999
         zfm_liq_r~annullo_singolo,
*§---> End Paganof - 11.02.2026
         zfm_liq_t~stato,
         zfm_liq_t~testo_breve,
         zfm_liq_t~tipo_bollo,
         zfm_liq_t~tipo_imputaz,
         zfm_liq_t~tipo_liq,
         zfm_liq_t~tipo_prop,
         zfm_liq_t~tot_pag_cap,
         zfm_liq_t~usnam_ins,
         zfm_liq_t~usnam_mod,
*         zfm_liq_r~xblnr, "arosati 31.07.2024
         zfm_liq_t~zlivello_ter,
         zfm_liq_t~zlocalizzazione,
*§---> Begin - Valorizzazione CUP da liq_r - 19.02.24 - VR
         zfm_liq_r~zsfcup,
*§---> End - Valorizzazione CUP da liq_r - 19.02.24 - VR
         zfm_liq_t~zsfstlista,
         zfm_liq_t~zzanno_prov,
         zfm_liq_t~zzanno_prov_pror,
         zfm_liq_t~zzdir_provv,
         zfm_liq_t~zzdir_provv_pror,
         zfm_liq_r~zzimp_per,
         zfm_liq_t~zzi_idoc,
         zfm_liq_t~zznote_provv,
         zfm_liq_t~zznote_provv_pror,
         zfm_liq_t~zznum_prov,
         zfm_liq_t~zznum_prov_pror,
         zfm_liq_r~zzsfcod_siope,
         zfm_liq_t~zztipo_prov,
         zfm_liq_t~zztipo_prov_pror,
         zfm_liq_t~no_durc, "CC_na 17/04/2024
         zfm_liq_t~nr_mandato_sost, "arosati 29.07.2024
*Start ins GM281223
         fmci~ztipo_risorsa,
         fmci~zz_titolo,
         fmci~zzsf_missioni,
         fmci~zzsf_programmi,
         fmci~zzsf_gsa,
         fmci~zz_ambito_gsa,
         fmci~zzidric,
         fmci~zzcodue,
         zsfprovve~anno_gsa,
         zsfprovve~causale_gsa,
*§---> Begin - RL-VR-FM - TKT 2-2150131206, gestione layout - 16.07.24 - VR
         zsfprovve~zsfcig,
         zdash_liq~cod_rit,
         zfm_liq_r~num_pre,
*§---> Begin - RL-VR-FM - TKT 2-2150131206, gestione layout - 16.07.24 - VR
* arosati 19.07.2024 MEV 15 II parte   INI
         kblp~fdatk,
* arosati 19.07.2024 MEV 15 II parte   Fine
*End   ins GM281223
*Start MOD BCSOFT 25/07/2024
         zsfprovve~num_provved,
         zsfprovve~zzannpr,
         kblp~wtges,
         zsfprovve~z_coge,
         zsfprovve~z_conto_fin,
* arosati 31.07.2024  INI
         bkpf~xblnr,
         bkpf~blart,
         bkpf~budat,
         bkpf~bldat,
         bkpf~zzdata_scad_pagam_siope,
* arosati 31.07.2024  Fine
*End MOD BCSOFT 25/07/2024
*Start MOD BCSOFT 03/10/2024
         zdash_liq~zname AS desc_ben,
         lfa1~datadurc,
         lfa1~durc,
*End MOD BCSOFT 03/10/2024
*Start MOD BCSOFT 06/02/2025 aggiunta estrazione data provvedimento
         zfm_liq_t~zzdata_provv,
*End MOD BCSOFT 06/02/2025 aggiunta estrazione data provvedimento
*Start MOD CA 23/06/2025 estrazione NUM/POS_DOC_COLLEGATO per estrazione informazioni eventuale Accertamento collegato all'Impegno MEV 112
         zsfprovve~num_doc_collegato,
         zsfprovve~pos_doc_collegato,
*End MOD CA 23/06/2025 estrazione NUM/POS_DOC_COLLEGATO per estrazione informazioni eventuale Accertamento collegato all'Impegno MEV 112
*Start MOD CA 08/07/2025 estrazione campi MEV 121
         zsfprovve~data_provved,
         zsfprovve~desc_provv,
         zsfprovve~dir_prop AS dg_prop_imp
*End MOD CA 08/07/2025 estrazione campi MEV 121
    FROM zfm_liq_t
   INNER JOIN zfm_liq_r          ON  zfm_liq_t~n_liq  EQ zfm_liq_r~n_liq
                                 AND zfm_liq_t~aa_liq EQ zfm_liq_r~aa_liq
*§---> Begin - RL-VR-FM - TKT 2-2150131206, gestione layout - 16.07.24 - VR
*   INNER JOIN zdash_liq          ON  zdash_liq~n_liq      EQ zfm_liq_r~n_liq
   LEFT OUTER JOIN zdash_liq     ON  zdash_liq~n_liq      EQ zfm_liq_r~n_liq
                                 AND zdash_liq~aa_liq     EQ zfm_liq_r~aa_liq
                                 AND zdash_liq~n_riga_liq EQ zfm_liq_r~n_riga_liq
                                 AND zdash_liq~zid_token  EQ zfm_liq_t~zid_token
*§---> End - RL-VR-FM - TKT 2-2150131206, gestione layout - 16.07.24 - VR
   INNER JOIN kblp               ON  kblp~belnr       EQ zfm_liq_r~impegno
                                 AND kblp~blpos       EQ zfm_liq_r~riga_imp
*Start ins GM281223
*Start MOD BCSOFT 03/10/2024
   INNER JOIN lfa1               ON lfa1~lifnr        EQ kblp~lifnr
*End MOD BCSOFT 03/10/2024
   INNER JOIN fmci               ON  fmci~fikrs       EQ zfm_liq_t~fikrs
                                 AND fmci~gjahr       EQ zfm_liq_t~aa_liq
                                 AND fmci~fipex       EQ zfm_liq_r~fipex
    LEFT OUTER JOIN zsfprovve ON  kblp~belnr          EQ zsfprovve~numero_documento
                              AND kblp~blpos          EQ zsfprovve~numero_posizione
* arosati 30.07.2024 spostato la BKPF INI
     LEFT OUTER JOIN bkpf ON zfm_liq_r~bukrs EQ bkpf~bukrs
                AND zfm_liq_r~aa_doc_fi EQ bkpf~gjahr
                AND zfm_liq_r~num_doc_fi EQ bkpf~belnr

* arosati 30.07.2024 spostato la BKPF fine

*End   ins GM281223
*Start MOD BCSOFT 03/10/2024
*  INTO CORRESPONDING FIELDS OF TABLE @i_lista ##TOO_MANY_ITAB_FIELDS
  INTO CORRESPONDING FIELDS OF TABLE @i_lista_temp
*End MOD BCSOFT 03/10/2024
   WHERE zfm_liq_t~aa_liq         IN @s_aa_liq
     AND zfm_liq_t~n_liq          IN @s_nr_liq
     AND zfm_liq_t~anno_mandato   IN @s_aa_mdt
     AND zfm_liq_t~dt_mandato     IN @s_dt_mdt
     AND zfm_liq_t~nr_mandato     IN @s_mndt
*>>>AG100516
*     AND zfm_liq_r~fistl          IN @s_fistl
     AND zfm_liq_r~fipex          IN @s_fipex
     AND zfm_liq_r~geber          IN @s_geber
     AND zfm_liq_r~impegno        IN @s_imp
*<<<AG100516
     AND zfm_liq_r~z_conto_fin    IN @s_fin "Insert EB110516
     AND zfm_liq_t~stato          IN @s_stato "Insert EB110516
     AND zfm_liq_r~num_ben        IN @s_ben "insert EB250516
     AND zfm_liq_r~codice_ben_alt IN @s_altben "insert EB090616
     AND kblp~fdatk               IN @s_fdatk "insert EB170616
     AND zfm_liq_t~cpudt_mod      IN @s_cpudt               "AG101116
*>>>AG100517 Id.152 modifiche per cruscotto atto
     AND zfm_liq_t~anno_prop      IN @s_anno_p
     AND zfm_liq_t~nr_proposta    IN @s_atto_p
*     AND zfm_liq_t~dir_prop       IN @s_dir_p "G4DK909753
     AND zfm_liq_t~tipo_prop      IN @s_tipo_p
     AND zfm_liq_t~zzanno_prov    IN @s_anno_d
     AND zfm_liq_t~zznum_prov     IN @s_atto_d
     AND zfm_liq_t~zztipo_prov    IN @s_tipo_d
*** G4DK909753 - BEG
     AND ( zfm_liq_r~cdr          IN @z_fistl OR
         ( zfm_liq_t~dir_prop     IN @s_dir_p AND
         ( zfm_liq_t~zzdir_provv  IN @s_dir_d OR
           zfm_liq_t~zzdir_provv  EQ @space ) ) )
     AND zfm_liq_r~cdr IN @s_fistl
*** G4DK909753 - END
*      AND zfm_liq_t~znum_reintegro IN s_nreint.             "LS260318
     AND zfm_liq_t~num_r          IN @s_nreint             " arosati 06.11.2023
*Start ins GM281223
     AND fmci~zzsf_gsa            IN @s_gsa
*End   ins GM281223
     AND zfm_liq_r~riga_annullata EQ @space
*Start MOD BCSOFT 06/02/2025 aggiunta filtro su Data Provvedimento
     AND zfm_liq_t~zzdata_provv   IN @s_data_p
*Start MOD BCSOFT 06/02/2025 aggiunta filtro su Data Provvedimento
*Start MOD BCSOFT 24/03/2025 aggiunta filtro su Data Scadenza Impegno
     AND kblp~fdatk               IN @s_scad_i
*End MOD BCSOFT 24/03/2025 aggiunta filtro su Data Scadenza Impegno
*<<<AG100517 id.152
* Start Agu 15/10/2025
     AND zsfprovve~zsfcig         IN @s_cig
     AND zfm_liq_r~zsfcup         IN @s_cup.
* End Agu 15/10/2025
*Start ins GM260224
  SELECT zfm_mand_r~aa_doc_fi,
         zfm_mand_r~aa_doc_par,
         zfm_mand_r~aa_liq,
         zfm_mand_t~anno_mandato,
         zfm_mand_r~anno_paregg_parz,
         zfm_liq_t~anno_prop,
         zfm_mand_t~automatica,
         zfm_mand_r~ben_alt,
         zfm_mand_r~blart,
         zfm_mand_r~bldat,
         zfm_mand_r~budat,
         zfm_mand_r~bukrs,
         zfm_mand_r~bvtyp,
         zfm_mand_r~bvtyp_alt,
         zfm_mand_t~causale AS causale_liq,
         zfm_mand_r~caus_ben_alt,
         zfm_mand_r~codice_ben_alt,
         zfm_mand_t~cpudt_ins,
         zfm_mand_t~cpudt_mod,
         zfm_mand_t~cputm_ins,
         zfm_mand_t~cputm_mod,
         zfm_mand_t~data_es_pag,
         zfm_mand_r~data_quietanza,
         zfm_liq_t~dir_prop,
         zfm_mand_t~disp_cas_cap,
         zfm_mand_r~doc_paregg_parz,
         zfm_mand_t~dt_invio_teso,
         zfm_mand_r~dt_liq,
         zfm_mand_t~dt_mandato,
         zfm_mand_t~dt_quiet,
         zfm_mand_t~fikrs,
         zfm_mand_t~nr_mandato_sost, "arosati 29.07.2024
         zfm_mand_r~fipex,
         zfm_mand_r~cdr AS fistl,                           "G4DK909753
         zfm_mand_r~geber,
         zfm_mand_r~impegno,
         zfm_mand_r~importo_r,
         zfm_mand_r~importo_r AS imp_liq, "Ins GM180324 - Più chiaro nel caso di piu righe
         zfm_mand_r~imp_net, "Ins GM180324 - Più chiaro nel caso di piu righe
         zfm_mand_r~imp_quiet,
         zfm_mand_r~imp_rit, "Ins GM180324 - Più chiaro nel caso di piu righe
         zfm_mand_t~mandato_copertura,
         zfm_mand_t~mandt,
         zfm_mand_t~mand_cope,
         zfm_mand_r~mod_pag,
         zfm_mand_r~mod_pag_alt,
         zfm_liq_t~nota_prop,
         zfm_mand_t~note_mndt,
         zfm_mand_t~nr_mandato,
         zfm_liq_t~nr_proposta,
         zfm_mand_r~numero_quietanza,
         zfm_mand_r~num_ben,
         zfm_mand_r~num_doc_fi,
         zfm_mand_r~num_doc_par,
         zfm_mand_r~n_liq,
         zfm_mand_r~n_riga_liq,
         zfm_mand_r~pareggio_parziale,
         zfm_mand_r~riga_imp,
         zfm_mand_r~riga_imp_per,
         zfm_mand_t~stato,
         zfm_mand_t~testo_breve,
         zfm_mand_t~tipo_bollo,
         zfm_mand_t~tipo_imputaz,
         zfm_mand_r~tipo_liq,
         zfm_liq_t~tipo_prop,
         zfm_mand_t~tot_pag_cap,
         zfm_mand_t~usnam_ins,
         zfm_mand_t~usnam_mod,
         zfm_mand_r~xblnr,
         zfm_mand_t~zlivello_ter,
         zfm_mand_t~zlocalizzazione,
         zfm_mand_r~zsfcup,
         zfm_mand_t~zsfstlista,
         zfm_mand_t~zzanno_prov,
         zfm_liq_t~zzanno_prov_pror,
         zfm_mand_t~zzdir_provv,
         zfm_liq_t~zzdir_provv_pror,
         zfm_mand_r~zzimp_per,
         zfm_mand_t~zzi_idoc,
         zfm_liq_t~zznote_provv,
         zfm_liq_t~zznote_provv_pror,
         zfm_mand_t~zznum_prov,
         zfm_liq_t~zznum_prov_pror,
         zfm_mand_r~zzsfcod_siope,
         zfm_mand_t~zztipo_prov,
         zfm_liq_t~zztipo_prov_pror,
         zfm_liq_t~no_durc, "CC_na 17/04/2024
         fmci~ztipo_risorsa,
         fmci~zz_titolo,
         fmci~zzsf_missioni,
         fmci~zzsf_programmi,
         fmci~zzsf_gsa,
         fmci~zz_ambito_gsa,
         fmci~zzidric,
         fmci~zzcodue,
         zsfprovve~anno_gsa,
         zsfprovve~causale_gsa,
*§---> Begin - RL-VR-FM - TKT 2-2150131206, gestione layout - 16.07.24 - VR
         zsfprovve~zsfcig,
*Start MOD BCSOFT 29/07/2024
         zsfprovve~num_provved,
         zsfprovve~zzannpr,
         kblp~wtges,
         zfm_mand_t~causale,
         zsfprovve~z_coge,
         zsfprovve~z_conto_fin,
*End MOD BCSOFT 29/07/2024
*         zfm_liq_t~cod_rit,
         zfm_mand_r~num_pre,
*§---> Begin - RL-VR-FM - TKT 2-2150131206, gestione layout - 16.07.24 - VR
* arosati 19.07.2024 MEV 15 II parte   INI
         kblp~fdatk,
* arosati 19.07.2024 MEV 15 II parte   Fine
*Start MOD BCSOFT 03/10/2024
         lfa1~datadurc,
         lfa1~durc,
         lfa1~name1,
         lfa1~name2,
         lfa1~name3,
         lfa1~name4,
*End MOD BCSOFT 03/10/2024
*Start MOD BCSOFT 06/02/2025 aggiunta estrazione data provvedimento
         zfm_liq_t~zzdata_provv,
*End MOD BCSOFT 06/02/2025 aggiunta estrazione data provvedimento
*Start MOD CA 23/06/2025 estrazione NUM/POS_DOC_COLLEGATO per estrazione informazioni eventuale Accertamento collegato all'Impegno MEV 112
         zsfprovve~num_doc_collegato,
         zsfprovve~pos_doc_collegato,
*End MOD CA 23/06/2025 estrazione NUM/POS_DOC_COLLEGATO per estrazione informazioni eventuale Accertamento collegato all'Impegno MEV 112
*Start MOD CA 08/07/2025 estrazione campi MEV 121
         zsfprovve~data_provved,
         zsfprovve~desc_provv,
         zsfprovve~dir_prop AS dg_prop_imp
*End MOD CA 08/07/2025 estrazione campi MEV 121
    FROM zfm_mand_t
   INNER JOIN zfm_mand_r         ON  zfm_mand_t~fikrs        EQ zfm_mand_r~fikrs
                                 AND zfm_mand_t~anno_mandato EQ zfm_mand_r~anno_mandato
                                 AND zfm_mand_t~nr_mandato   EQ zfm_mand_r~nr_mandato
   INNER JOIN zfm_liq_t          ON  zfm_mand_t~fikrs        EQ zfm_liq_t~fikrs
                                 AND zfm_mand_r~aa_liq       EQ zfm_liq_t~aa_liq
                                 AND zfm_mand_r~n_liq        EQ zfm_liq_t~n_liq
   INNER JOIN kblp               ON  kblp~belnr              EQ zfm_mand_r~impegno
                                 AND kblp~blpos              EQ zfm_mand_r~riga_imp
*Start MOD BCSOFT 03/10/2024
   INNER JOIN lfa1               ON lfa1~lifnr        EQ kblp~lifnr
*End MOD BCSOFT 03/10/2024
   INNER JOIN fmci               ON  fmci~fikrs              EQ zfm_mand_t~fikrs
                                 AND fmci~gjahr              EQ zfm_mand_r~aa_liq
                                 AND fmci~fipex              EQ zfm_mand_r~fipex
    LEFT OUTER JOIN zsfprovve    ON  kblp~belnr              EQ zsfprovve~numero_documento
                                 AND kblp~blpos              EQ zsfprovve~numero_posizione
*Start MOD BCSOFT 03/10/2024
*  APPENDING CORRESPONDING FIELDS OF TABLE @i_lista ##TOO_MANY_ITAB_FIELDS
   APPENDING CORRESPONDING FIELDS OF TABLE @i_lista_temp
*End MOD BCSOFT 03/10/2024
   WHERE zfm_mand_r~aa_liq         IN @s_aa_liq
     AND zfm_mand_r~n_liq          IN @s_nr_liq
     AND zfm_mand_t~anno_mandato   IN @s_aa_mdt
     AND zfm_mand_t~dt_mandato     IN @s_dt_mdt
     AND zfm_mand_t~nr_mandato     IN @s_mndt
*     AND zfm_mand_r~fistl          IN @s_fistl
     AND zfm_mand_r~fipex          IN @s_fipex
     AND zfm_mand_r~geber          IN @s_geber
     AND zfm_mand_r~impegno        IN @s_imp
     AND zfm_mand_r~z_conto_fin    IN @s_fin
     AND zfm_mand_t~stato          IN @s_stato
     AND zfm_mand_r~num_ben        IN @s_ben
     AND zfm_mand_r~codice_ben_alt IN @s_altben
     AND kblp~fdatk                IN @s_fdatk
     AND zfm_mand_t~cpudt_mod      IN @s_cpudt
     AND zfm_liq_t~anno_prop       IN @s_anno_p
     AND zfm_liq_t~nr_proposta     IN @s_atto_p
*     AND zfm_liq_t~dir_prop        IN @s_dir_p "G4DK909753
     AND zfm_liq_t~tipo_prop       IN @s_tipo_p
     AND zfm_mand_t~zzanno_prov    IN @s_anno_d
     AND zfm_mand_t~zznum_prov     IN @s_atto_d
     AND zfm_mand_t~zztipo_prov    IN @s_tipo_d
*** G4DK909753 - BEG
     AND ( zfm_mand_r~cdr         IN @z_fistl OR
          ( zfm_liq_t~dir_prop    IN @s_dir_p AND
           ( zfm_mand_t~zzdir_provv IN @s_dir_d OR
             zfm_mand_t~zzdir_provv EQ @space ) ) )
    AND zfm_mand_r~cdr IN @s_fistl
*** G4DK909753 - END
     AND zfm_liq_t~num_r           IN @s_nreint
     AND fmci~zzsf_gsa             IN @s_gsa
     AND zfm_mand_r~riga_annullata EQ @space
     AND zfm_mand_r~stato_mand     EQ '5'
*Start MOD BCSOFT 06/02/2025 aggiunta filtro su Data Provvedimento
     AND zfm_liq_t~zzdata_provv   IN @s_data_p
*Start MOD BCSOFT 06/02/2025 aggiunta filtro su Data Provvedimento
*Start MOD BCSOFT 24/03/2025 aggiunta filtro su Data Scadenza Impegno
     AND kblp~fdatk               IN @s_scad_i
*End MOD BCSOFT 24/03/2025 aggiunta filtro su Data Scadenza Impegno
*End   ins GM260224
* Start Agu 15/10/2025
     AND zsfprovve~zsfcig         IN @s_cig
     AND zfm_mand_r~zsfcup        IN @s_cup.
* End Agu 15/10/2025
*§---> Start Paganof - 12.06.2025 Fix Filtro
  IF i_lista_temp IS NOT INITIAL.
*Filtro Direzione Provvedimento
    IF gr_dir_d IS NOT INITIAL.
      DELETE i_lista_temp WHERE zzdir_provv NOT IN gr_dir_d.
    ENDIF.
*Filtro Direzione Proposta
    IF gr_dir_p IS NOT INITIAL.
      DELETE i_lista_temp WHERE dir_prop NOT IN gr_dir_p.
    ENDIF.
  ENDIF.
*§---> End Paganof - 12.06.2025

*Start MOD BCSOFT 03/10/2024
  IF i_lista_temp IS NOT INITIAL.
    LOOP AT i_lista_temp ASSIGNING FIELD-SYMBOL(<fs_temp01>).
      IF <fs_temp01>-durc IS INITIAL.
        CLEAR <fs_temp01>-datadurc.
      ENDIF.
      IF <fs_temp01>-desc_ben IS INITIAL.
        CONCATENATE <fs_temp01>-name1 <fs_temp01>-name2 <fs_temp01>-name3 <fs_temp01>-name4 INTO <fs_temp01>-desc_ben.
      ENDIF.
*Start MOD CA 0/07/2025 concatenazione campi per creazione chiave accesso ai Testi Standard per Impegni
      CONCATENATE sy-mandt <fs_temp01>-impegno '000' INTO <fs_temp01>-key_txt_imp.
*End MOD CA 0/07/2025 concatenazione campi per creazione chiave accesso ai Testi Standard per Impegni
    ENDLOOP.
  ENDIF.

*Start MOD CA 23/06/2025 sostituzione assegnazione con MOVE MEV 112
*  i_lista[] = i_lista_temp[].
  MOVE-CORRESPONDING i_lista_temp TO i_lista.
*End MOD CA 23/06/2025 sostituzione assegnazione con MOVE MEV 112

  IF i_lista IS NOT INITIAL.
    SELECT t~anno_mandato,
           t~nr_mandato,
           r~stato_mand,
           t~data_firma,
           t~dt_invio_teso,
           t~causale
    FROM zfm_mand_t AS t
    INNER JOIN zfm_mand_r AS r ON r~anno_mandato EQ t~anno_mandato
                              AND r~nr_mandato EQ t~nr_mandato
    INTO CORRESPONDING FIELDS OF TABLE @lt_mand_temp
    FOR ALL ENTRIES IN @i_lista
    WHERE t~anno_mandato = @i_lista-anno_mandato
      AND t~nr_mandato   = @i_lista-nr_mandato.

    IF sy-subrc IS INITIAL.
      SORT lt_mand_temp BY anno_mandato nr_mandato.
    ENDIF.
  ENDIF.
*End MOD BCSOFT 03/10/2024

*Start MOD CA 24/06/2025 estrazione Capitoli per eventuali Accertamenti collegati MEV 112
*  IF i_lista IS NOT INITIAL AND sy-tcode EQ 'ZVISU_MAND_CDC'.
*§---> Start Paganof - 21.01.2026 10:39:55 - Mev 112 Macroaggregato
*recupero il Macroaggregato
*    SELECT fikrs,
*           gjahr,
*           fipex,
*           zzmacroaggr
*      FROM fmci
*      INTO TABLE @DATA(lt_fmci_macro)
*      FOR ALL ENTRIES IN @i_lista
*      WHERE fikrs EQ '1000'
*      AND   gjahr IN @s_aa_pdc
*      AND   fipex = @i_lista-fipex.
*    IF sy-subrc EQ 0.
*      SORT lt_fmci_macro BY fikrs gjahr fipex.
*    ENDIF.
*§---> End Paganof - 21.01.2026 10:40:06

*    SELECT zanno_token,
*           zid_token,
*           belnr,
*           blpos,
*           zdash_acc~fipos,
*§---> Start Paganof - 21.01.2026 10:39:55 - Mev 112 Macroaggregato
*           fmci~zzsf_categorie
*           fmci~zzmacroaggr
*§---> End Paganof - 21.01.2026 10:40:06
*    FROM zdash_acc
*    INNER JOIN fmci ON fmci~fikrs EQ '1000'
*                   AND fmci~gjahr EQ zdash_acc~zanno_token
*                   AND fmci~fipex EQ zdash_acc~fipos
*    INTO TABLE @DATA(lt_acc_coll)
*    FOR ALL ENTRIES IN @i_lista
*    WHERE belnr EQ @i_lista-num_doc_collegato
*      AND blpos EQ @i_lista-pos_doc_collegato.

*    IF lt_acc_coll IS NOT INITIAL.
*§---> Start Paganof - 10.04.2026 2-2358986624 Sort
*      SORT lt_acc_coll BY zanno_token zid_token belnr blpos fipos.
*      SORT lt_acc_coll BY belnr blpos.
*§---> End Paganof - 10.04.2026
*    ENDIF.
*  ENDIF.
*End MOD CA 24/06/2025 estrazione Capitoli per eventuali Accertamenti collegati MEV 112

*Start MOD CA 24/06/2025 estrazione testi raw per impegni MEV 112/121
  IF i_lista IS NOT INITIAL AND ( cb_cesp IS NOT INITIAL OR cb_info IS NOT INITIAL ).
    SELECT tdname,
           clustr,
           clustd
      FROM stxl
    FOR ALL ENTRIES IN @i_lista
    WHERE relid    EQ 'TX'
      AND tdobject EQ 'FMRE_TEXT'
      AND tdspras  EQ @sy-langu
      AND tdid     EQ 'FMRE'
      AND tdname   EQ @i_lista-key_txt_imp
    INTO TABLE @DATA(lt_raw).

    IF sy-subrc IS INITIAL.
      SORT lt_raw BY tdname.
      DELETE ADJACENT DUPLICATES FROM lt_raw COMPARING tdname.
    ENDIF.
  ENDIF.
*End MOD CA 24/06/2025 estrazione testi raw per impegni MEV 112/121

*Start MOD CA 09/07/2025 estrazione Somma Imp Quiet per anno Precedente a parità di Beneficiario
*  IF i_lista IS NOT INITIAL AND sy-tcode EQ 'ZVISU_MAND_CDC'.
*    TYPES: BEGIN OF lty_aa_prec,
*             codice_ben_alt LIKE zfm_mand_r-codice_ben_alt,
*             imp_quiet_prec LIKE zfm_mand_r-imp_quiet,
*           END OF lty_aa_prec.

*    DATA: imp_quiet_prec LIKE zfm_mand_r-imp_quiet,
*          lv_aa_prec     LIKE zfm_mand_r-anno_mandato,
*          lt_aa_prec     TYPE STANDARD TABLE OF lty_aa_prec,
*          lwa_aa_prec    LIKE LINE OF lt_aa_prec.
*§---> Start Paganof - 21.01.2026 10:44:00 - Totale pagato da n - 1 a n
*    lv_aa_prec = s_aa_pdc-low - 1.
*    lv_aa_prec = s_aa_pdc-low.
*§---> End Paganof - 21.01.2026 10:44:00
*    SELECT codice_ben_alt,
*           fikrs,
*           anno_mandato,
*           nr_mandato,
*           n_riga_mand,
*           imp_quiet
*    FROM zfm_mand_r
*    FOR ALL ENTRIES IN @i_lista
*    WHERE anno_mandato   EQ @lv_aa_prec
*      AND codice_ben_alt EQ @i_lista-num_ben
*      AND stato_mand IN (1 ,4 ,7)
*    INTO TABLE @DATA(lt_app_prec).

*    SORT lt_app_prec BY codice_ben_alt.

*    LOOP AT lt_app_prec ASSIGNING FIELD-SYMBOL(<fs_app_prec>).
*      IF <fs_app_prec>-imp_quiet NE 0.
*        imp_quiet_prec = imp_quiet_prec + <fs_app_prec>-imp_quiet.
*      ENDIF.

*      AT END OF codice_ben_alt.
*        <fs_app_prec>-imp_quiet = imp_quiet_prec.
*        CLEAR imp_quiet_prec.

*        lwa_aa_prec-codice_ben_alt = <fs_app_prec>-codice_ben_alt.
*        lwa_aa_prec-imp_quiet_prec = <fs_app_prec>-imp_quiet.
*        APPEND lwa_aa_prec TO lt_aa_prec.
*        CLEAR lwa_aa_prec.
*      ENDAT.
*    ENDLOOP.

*    SORT lt_aa_prec BY codice_ben_alt.
*  ENDIF.
*End MOD CA 09/07/2025 estrazione Somma Imp Quiet per anno Precedente a parità di Beneficiario

*Start MOD CA 04/07/2025 estrazione DESCRIZIONE_DG_PROP_MANDATO per MEV 121
  IF i_lista IS NOT INITIAL AND sy-tcode EQ 'ZFM_VISU_MANDATI' AND cb_info IS NOT INITIAL.
    SELECT fikrs,
           id_sap,
           cod_str_cdr,
           descr_str_e
    FROM zfm_strorg_edma
    INTO TABLE @DATA(lt_dg_mand)
    FOR ALL ENTRIES IN @i_lista
    WHERE cod_str_cdr EQ @i_lista-dir_prop
      AND dt_inizio LE @sy-datum
      AND dt_fine   GE @sy-datum.

    IF lt_dg_mand IS NOT INITIAL.
      SORT lt_dg_mand BY fikrs id_sap cod_str_cdr descr_str_e.
    ENDIF.
  ENDIF.
*End MOD CA 04/07/2025 estrazione DESCRIZIONE_DG_PROP_MANDATO per MEV 121

*Start MOD CA 04/07/2025 estrazione DESCRIZIONE_DG_PROP_IMPEGNO per MEV 121
  IF i_lista IS NOT INITIAL AND sy-tcode EQ 'ZFM_VISU_MANDATI' AND cb_info IS NOT INITIAL.
    SELECT fikrs,
           id_sap,
           cod_str_cdr,
           descr_str_e
    FROM zfm_strorg_edma
    INTO TABLE @DATA(lt_dg_imp)
    FOR ALL ENTRIES IN @i_lista
    WHERE cod_str_cdr EQ @i_lista-dg_prop_imp
      AND dt_inizio LE @sy-datum
      AND dt_fine   GE @sy-datum.

    IF lt_dg_mand IS NOT INITIAL.
      SORT lt_dg_imp BY fikrs id_sap cod_str_cdr descr_str_e.
    ENDIF.
  ENDIF.
*End MOD CA 04/07/2025 estrazione DESCRIZIONE_DG_PROP_IMPEGNO per MEV 121

  IF i_lista[] IS NOT INITIAL.
    IF s_fistl[] IS NOT INITIAL.
      SELECT fikrs,
             gjahr,
             fipex,
             cod_str_cdr,
             dt_inizio,
             dt_fine
        FROM zfm_edma_cap
        INTO TABLE @DATA(lt_cdr)
         FOR ALL ENTRIES IN @i_lista
       WHERE fikrs       EQ @i_lista-fikrs
         AND gjahr       EQ @i_lista-aa_liq
         AND fipex       EQ @i_lista-fipex
         AND cod_str_cdr IN @s_fistl
         AND dt_fine     EQ '99991231'.
      IF sy-subrc IS INITIAL.
        DATA lv_index LIKE sy-tabix.

        LOOP AT i_lista ASSIGNING FIELD-SYMBOL(<fs_lista>).
          lv_index = sy-tabix.
          READ TABLE lt_cdr
          WITH KEY fikrs = <fs_lista>-fikrs
                   gjahr = <fs_lista>-aa_liq
                   fipex = <fs_lista>-fipex
          ASSIGNING FIELD-SYMBOL(<fs_cdr>).
          IF sy-subrc IS INITIAL.
            <fs_lista>-fistl = <fs_cdr>-cod_str_cdr.
          ELSE.
            DELETE i_lista INDEX lv_index.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.

  IF i_lista[] IS INITIAL. "Ins GM160224
*    ##NO_TEXT MESSAGE e000(zfm) WITH 'Nessun mandato estratto'.
    MESSAGE 'Nessun mandato estratto' TYPE 'S' DISPLAY LIKE 'E'.
    gv_no_data = 'X'.
*Start MOD CA 25/06/2025
    STOP.
*End MOD CA 25/06/2025
  ENDIF.

  IF p_gdurc IS NOT INITIAL.
    dt_lim_durc = sy-datum + p_gdurc.
  ENDIF.

* arosati 11.2023 ini
  ##NEEDED
  DATA:
    lt_stato_m TYPE STANDARD TABLE OF dd07v,
    stato_mand TYPE zstato_mand.
  CLEAR: lt_stato_m[].

  CALL FUNCTION 'DD_DOMVALUES_GET'
    EXPORTING
      domname   = 'ZSTATO_MAND'
      text      = 'X'
    TABLES
      dd07v_tab = lt_stato_m.
* arosati 11.2023 fine
* START INS EB070616

*Start MOD BCSOFT 06/02/2025 valorizzazione tabella lt_voce_conto dalle cespiti
  IF i_lista IS NOT INITIAL.
    SELECT zzsfdatanno,
           z_tipo_conto1,
           z_conto_fin,
           z_voce_conto
      FROM zrac_piano_conti
    INTO TABLE @DATA(lt_voceconto)
    FOR ALL ENTRIES IN @i_lista
     WHERE zrac_piano_conti~z_conto_fin EQ @i_lista-z_conto_fin
       AND zrac_piano_conti~zzsfdatanno LE @i_lista-aa_liq
       AND zrac_piano_conti~anno_fine   GE @i_lista-aa_liq.
    IF sy-subrc IS INITIAL.
      SORT lt_voceconto BY z_conto_fin.
    ENDIF.
  ENDIF.
*End MOD BCSOFT 06/02/2025 valorizzazione tabella lt_voce_conto dalle cespiti

*§---> Begin - RL-VR-FM - TKT 2-2169391581, testo esteso impegno - 19.09.24
  IF cb_cesp IS NOT INITIAL.
*Start MOD CA 04/07/2025 aggiunta condizione per MEV 112
*    OR sy-tcode EQ 'ZVISU_MAND_CDC'.
*End MOD CA 04/07/2025 aggiunta condizione per MEV 112

*Start MOD BCSOFT 06/02/2025 valorizzazione tabella lt_voce_conto dalle cespiti
*    SELECT zzsfdatanno,
*           z_tipo_conto1,
*           z_conto_fin,
*           z_voce_conto
*      FROM zrac_piano_conti
*      INTO TABLE @DATA(lt_voceconto)
*       FOR ALL ENTRIES IN @i_lista
*     WHERE zrac_piano_conti~z_conto_fin EQ @i_lista-z_conto_fin
*       AND zrac_piano_conti~zzsfdatanno LE @i_lista-aa_liq
*       AND zrac_piano_conti~anno_fine   GE @i_lista-aa_liq.
*    IF sy-subrc IS INITIAL.
*      SORT lt_voceconto BY z_conto_fin.
*    ENDIF.
*End MOD BCSOFT 06/02/2025 valorizzazione tabella lt_voce_conto dalle cespiti
*§---> Start Paganof - 29.07.2025 15:56:09 - La select la deve fare sempre
*    IF i_lista IS NOT INITIAL.
*      SELECT belnr,
*             ktext
*        FROM kblk
*        INTO TABLE @DATA(lt_ktext)
*         FOR ALL ENTRIES IN @i_lista
*       WHERE kblk~belnr EQ @i_lista-impegno.
*      IF sy-subrc IS INITIAL.
*        SORT lt_ktext BY belnr.
*      ENDIF.
*    ENDIF.
*§---> End Paganof - 29.07.2025 15:56:48
  ENDIF.

*Start MOD BCSOFT 24/03/2025 estrazione di copertura fondo e asset fondo
  IF i_lista IS NOT INITIAL.
    SELECT fc~fikrs,
           fc~fincode,
           fc~type,
           fc~copertura,
           dd~ddtext
    FROM fmfincode AS fc
*Start MOD CA 23/07/2025 sostituzione Inner con Left Tkt 2-2266039667
*   INNER JOIN dd07v ON dd~domvalue_l EQ fc~rendicontazione
    LEFT OUTER JOIN dd07v AS dd ON dd~domvalue_l EQ fc~rendicontazione
                               AND dd~domname    EQ 'Z_RENDICONTAZIONE'
                               AND dd~ddlanguage EQ @sy-langu
*End MOD CA 23/07/2025 sostituzione Inner con Left Tkt 2-2266039667
    INTO TABLE @DATA(lt_fond)
    FOR ALL ENTRIES IN @i_lista
    WHERE fc~fikrs   EQ '1000'
      AND fc~fincode EQ @i_lista-geber.

    SORT lt_fond BY fincode.
  ENDIF.
*End MOD BCSOFT 24/03/2025 estrazione di copertura fondo e asset fondo

  FIELD-SYMBOLS: <fs_all>  TYPE zfm_lista_info_mandati,
                 <fs_line> TYPE tline.

  DATA: lv_string    TYPE string,
        lv_text_name LIKE vbdpa-tdname,
        lv_lenght    TYPE i.

  DATA: BEGIN OF lt_lines OCCURS 50.
          INCLUDE STRUCTURE tline.
  DATA: END OF lt_lines.

  CONSTANTS: c_par  TYPE char2 VALUE ',,'. " Sign for tabs
*§---> End - RL-VR-FM - TKT 2-2169391581, testo esteso impegno - 19.09.24
*§---> Start Paganof - 29.07.2025 15:53:48 - Testo Esteso Ogg.Imp.
  IF i_lista IS NOT INITIAL.
    SELECT belnr,
           ktext
      FROM kblk
      INTO TABLE @DATA(lt_ktext)
       FOR ALL ENTRIES IN @i_lista
     WHERE kblk~belnr EQ @i_lista-impegno.
    IF sy-subrc IS INITIAL.
      SORT lt_ktext BY belnr.
    ENDIF.
  ENDIF.
*§---> End Paganof - 29.07.2025 15:55:02

*§---> Start Paganof - 03.04.2026 - 2-2358986624 - Ragione sociale
  IF i_lista IS NOT INITIAL.
    SELECT partner,
           name_first,
           name_last,
           name_org1,
           name_org2,
           name_org3,
           name_org4,
           denominazione
      FROM but000
      INTO TABLE @DATA(lt_but000)
      FOR ALL ENTRIES IN @i_lista
      WHERE partner EQ @i_lista-num_ben.
    IF sy-subrc EQ 0.
      SORT lt_but000 BY partner.
    ENDIF.
  ENDIF.
*§---> End Paganof - 03.04.2026


  LOOP AT i_lista ASSIGNING <wa>.

*§---> Start Paganof - 03.04.2026 - 2-2358986624 - Ragione Sociale
    READ TABLE lt_but000 ASSIGNING FIELD-SYMBOL(<fs_txt_but000>)
                              WITH KEY partner = <wa>-num_ben BINARY SEARCH.
    IF sy-subrc EQ 0.
      IF <fs_txt_but000>-name_org1 IS NOT INITIAL.
        CONCATENATE <fs_txt_but000>-name_org1
                    <fs_txt_but000>-name_org2
                    <fs_txt_but000>-name_org3
                    <fs_txt_but000>-name_org4 INTO <wa>-desc_ben SEPARATED BY space.
        CONDENSE <wa>-desc_ben.
      ELSEIF <fs_txt_but000>-denominazione IS INITIAL.
        CONCATENATE <fs_txt_but000>-name_first
                    <fs_txt_but000>-name_last INTO <wa>-desc_ben SEPARATED BY space.
        CONDENSE <wa>-desc_ben.
      ELSE.
        <wa>-desc_ben = <fs_txt_but000>-denominazione.
      ENDIF.
    ENDIF.
*§---> End Paganof - 03.04.2026

*§---> Begin - RL-VR-FM - TKT 2-2169391581, testo esteso impegno - 19.09.24

*Start MOD BCSOFT valorizzazione campi Copertura fondo e asset fondo
    READ TABLE lt_fond ASSIGNING FIELD-SYMBOL(<fs_fond>) WITH KEY fincode = <wa>-geber BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      IF <fs_fond>-type(4) EQ 'V.O.' AND <fs_fond>-copertura NE 'D'.
        <wa>-asset = 'COMPETENZA'.
      ELSEIF <fs_fond>-type EQ 'UNIV_F' AND <fs_fond>-copertura NE 'D'.
        <wa>-asset = 'COMPETENZA'.
      ELSEIF <fs_fond>-type(3) EQ 'FPV'.
        <wa>-asset = 'FPV'.
      ELSEIF <fs_fond>-type EQ 'AVANZO'.
        <wa>-asset = 'AVANZO'.
      ELSEIF <fs_fond>-copertura EQ 'D'.
        <wa>-asset = 'DANC'.
        CONCATENATE <fs_fond>-copertura '-' 'DANC' INTO <wa>-copertura SEPARATED BY space.
        TRANSLATE <wa>-copertura TO UPPER CASE.
      ENDIF.

      IF <fs_fond>-copertura EQ 'L'.
        CONCATENATE <fs_fond>-copertura '-' 'Libera' INTO <wa>-copertura SEPARATED BY space.
        TRANSLATE <wa>-copertura TO UPPER CASE.
      ELSEIF <fs_fond>-copertura EQ 'V'.
        CONCATENATE <fs_fond>-copertura '-' 'Vincolata' INTO <wa>-copertura SEPARATED BY space.
        TRANSLATE <wa>-copertura TO UPPER CASE.
      ENDIF.
    ENDIF.
*End MOD BCSOFT valorizzazione campi Copertura fondo e asset fondo

*Start MOD BCSOFT 06/02/2025 valorizzazione campo descrizione a prescindere dalle cespiti
    READ TABLE lt_voceconto
    WITH KEY   z_conto_fin = <wa>-z_conto_fin
    ASSIGNING FIELD-SYMBOL(<fs_voce>)
    BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      <wa>-descrizione = <fs_voce>-z_voce_conto.
    ENDIF.
*End MOD BCSOFT 06/02/2025 valorizzazione campo descrizione a prescindere dalle cespiti

**Start MOD BCSOFT 29/07/2024
    IF cb_cesp IS NOT INITIAL
*Start MOD CA 22/07/2025 agiunta condizion per nuova checkbox MEV 121
    OR cb_info IS NOT INITIAL.
*End MOD CA 22/07/2025 agiunta condizion per nuova checkbox MEV 121
*Start MOD CA 04/07/2025 aggiunta condizione per MEV 112
*    OR sy-tcode EQ 'ZVISU_MAND_CDC'.
*End MOD CA 04/07/2025 aggiunta condizione per MEV 112.

*      SELECT z_voce_conto
*      FROM zrac_piano_conti
*      INTO <wa>-descrizione
*      WHERE zrac_piano_conti~z_conto_fin EQ <wa>-z_conto_fin AND
*            zrac_piano_conti~zzsfdatanno LE <wa>-fdatk AND
*            zrac_piano_conti~anno_fine GE <wa>-fdatk.
*      ENDSELECT.
*
*      SELECT ktext
*      FROM kblk
*      INTO <wa>-ktext
*      WHERE kblk~belnr EQ <wa>-impegno.
*      ENDSELECT.
*    ENDIF.
**End MOD BCSOFT 29/07/2024

*Start MOD BCSOFT 06/02/2025 valorizzazione campo descrizione a prescindere dalle cespiti
*      READ TABLE lt_voceconto
*      WITH KEY   z_conto_fin = <wa>-z_conto_fin
*      ASSIGNING FIELD-SYMBOL(<fs_voce>)
*      BINARY SEARCH.
*      IF sy-subrc IS INITIAL.
*        <wa>-descrizione = <fs_voce>-z_voce_conto.
*      ENDIF.
*End MOD BCSOFT 06/02/2025 valorizzazione campo descrizione a prescindere dalle cespiti
*§---> Start Paganof - 29.07.2025 15:59:52 - Da utilizare sempre e non solo per cb_cesp
*      READ TABLE lt_ktext
*      WITH KEY   belnr = <wa>-impegno
*      ASSIGNING FIELD-SYMBOL(<fs_ktext>)
*      BINARY SEARCH.
*      IF sy-subrc IS INITIAL.
*        <wa>-ktext = <fs_ktext>-ktext.
*      ENDIF.
*§---> End Paganof - 29.07.2025 16:00:32

*Start MOD CA 04/07/2025 commento READ_TEXT e sostituisco con READ da tabella valorizzata precedentemente per prestazioni MEV 112
*      CLEAR: lv_text_name, lt_lines[], lv_string.
*      CONCATENATE sy-mandt <wa>-impegno '000'
*             INTO lv_text_name.
*      CONDENSE lv_text_name.
*
*      CALL FUNCTION 'READ_TEXT'
*        EXPORTING
*          id                      = 'FMRE'
*          language                = sy-langu
*          name                    = lv_text_name
*          object                  = 'FMRE_TEXT'
*        TABLES
*          lines                   = lt_lines
*        EXCEPTIONS
*          id                      = 1
*          language                = 2
*          name                    = 3
*          not_found               = 4
*          object                  = 5
*          reference_check         = 6
*          wrong_access_to_archive = 7
*          OTHERS                  = 8.
*      IF sy-subrc <> 0.
*        CONTINUE.
*      ENDIF.
*
*      CLEAR lv_string.
*      LOOP AT lt_lines ASSIGNING <fs_line>.              "#EC CI_NESTED
*        CONCATENATE lv_string <fs_line>-tdline
*               INTO lv_string SEPARATED BY ' '.
*        lv_lenght = strlen( lv_string ).
*        IF lv_lenght GT 128.
*          EXIT.
*        ENDIF.
*      ENDLOOP.
*
**      APPEND lv_string TO lt_string.  "if needed in string table
*      SHIFT lv_string LEFT DELETING LEADING space.
*      REPLACE ALL OCCURRENCES OF c_par IN lv_string WITH ' '.
*      <wa>-ktext_esteso = lv_string.

      READ TABLE lt_raw ASSIGNING FIELD-SYMBOL(<fs_raw>) WITH KEY tdname = <wa>-key_txt_imp BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        REFRESH: gt_stxl_raw, gt_tline.

        CLEAR gs_stxl_raw.
        gs_stxl_raw-clustr = <fs_raw>-clustr.
        gs_stxl_raw-clustd = <fs_raw>-clustd.
        APPEND gs_stxl_raw TO gt_stxl_raw.

        IMPORT tline = gt_tline FROM INTERNAL TABLE gt_stxl_raw.

        CLEAR gv_string.

        LOOP AT gt_tline ASSIGNING FIELD-SYMBOL(<tline>). "#EC CI_NESTED
          CONCATENATE gv_string <tline>-tdline
                 INTO gv_string SEPARATED BY space.

*§---> Begin - 2-2356763407 con questa exit sulla lunghezza riesce a leggere solo le prime due righe del testo - 27.03.26 - VR
*          lv_lenght = strlen( gv_string ).
*          IF lv_lenght GT 128.
*            EXIT.
*          ENDIF.
*§---> End - 2-2356763407 - 27.03.26 - VR
        ENDLOOP.

        SHIFT gv_string LEFT DELETING LEADING space.
        REPLACE ALL OCCURRENCES OF c_par IN gv_string WITH ' '.

        <wa>-ktext_esteso = gv_string.
*§---> Start Paganof - 27.03.2026 Ktext_esteso dalla kblk
      ELSE.
        READ TABLE lt_ktext ASSIGNING FIELD-SYMBOL(<fs_ktext>) WITH KEY belnr = <wa>-impegno
                                                               BINARY SEARCH.
        IF sy-subrc IS INITIAL.
          <wa>-ktext_esteso = <fs_ktext>-ktext.
        ENDIF.
*§---> End Paganof - 27.03.2026

      ENDIF.
*End MOD CA 04/07/2025 commento READ_TEXT e sostituisco con READ da tabella valorizzata precedentemente per prestazioni MEV 112
    ENDIF.
*§---> End - RL-VR-FM - TKT 2-2169391581, testo esteso impegno - 19.09.24
*§---> Start Paganof - 29.07.2025 16:00:44 - recupero testo esteso OGG.IMP.
    READ TABLE lt_ktext
   WITH KEY   belnr = <wa>-impegno
   ASSIGNING <fs_ktext>
   BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      <wa>-ktext = <fs_ktext>-ktext.
    ENDIF.
*§---> End Paganof - 29.07.2025 16:00:49
*>>>AG110517 id.152 recpuero dati atto corretti
**Salva gli importi su variabili locali - AGIL 20170713 - Start
    CLEAR: lv_imp_liq, lv_imp_net, lv_imp_rit.
    lv_imp_liq = <wa>-imp_liq.
    lv_imp_net = <wa>-imp_net.
    lv_imp_rit = <wa>-imp_rit.
**Salva gli importi su variabili locali - AGIL 20170713 - End

**Ripassa al fs importi corretti che la select ha alterato - AGIL 20170713 - Start
    <wa>-imp_liq = lv_imp_liq.
    <wa>-imp_net = lv_imp_net.
    <wa>-imp_rit = lv_imp_rit.
**Ripassa al fs importi corretti che la select ha alterato - AGIL 20170713 - End
*<<<AG110517
*   start ins MF13052019
    IF <wa>-nr_mandato IS NOT INITIAL.
* arosati 11.2023 ini
      ##WARN_OK
*start MOD BCSOFT 04/10/2024
      READ TABLE lt_mand_temp ASSIGNING FIELD-SYMBOL(<fs_man_temp>) WITH KEY anno_mandato = <wa>-anno_mandato nr_mandato = <wa>-nr_mandato
*Start MOD BCSOFT 06/02/2025 uso Binary Seacrh pre prestazioni.
      BINARY SEARCH.
*End MOD BCSOFT 06/02/2025 uso Binary Seacrh pre prestazioni.
      IF sy-subrc IS INITIAL.
        <wa>-data_firma    = <fs_man_temp>-data_firma.
        <wa>-dt_invio_teso = <fs_man_temp>-dt_invio_teso.
        <wa>-causale       = <fs_man_temp>-causale.
        stato_mand         = <fs_man_temp>-stato_mand.
      ENDIF.
*      SELECT SINGLE stato_mand INTO @stato_mand         "#EC CI_NOORDER
*        FROM zfm_mand_r
*        WHERE anno_mandato = @<wa>-anno_mandato
*          AND nr_mandato   = @<wa>-nr_mandato.
*End MOD BCSOFT 04/10/2024
* Descrizione stato mandato
      ##NEEDED
      READ TABLE lt_stato_m ASSIGNING FIELD-SYMBOL(<stato_m>)
           WITH KEY domvalue_l = stato_mand.             "#EC CI_STDSEQ
      IF sy-subrc IS INITIAL.
        <wa>-descr_stato_m = <stato_m>-ddtext.
      ENDIF.
      CLEAR stato_mand.
      ##WARN_OK
*Start MOD BCSOFT 04/10/2024
*      SELECT SINGLE data_firma, dt_invio_teso,
**Start MOD BCSOFT 31/07/2024          "#EC CI_NOORDER
*                    causale
*             INTO ( @<wa>-data_firma, @<wa>-dt_invio_teso, @<wa>-causale )
**End MOD BCSOFT 31/07/20024
*             FROM zfm_mand_t
*             WHERE anno_mandato = @<wa>-anno_mandato
*               AND nr_mandato   = @<wa>-nr_mandato.
    ENDIF.
*End MOD BCSOFT 04/10/2024
* arosati 11.2023 fine
* arosati 29.07.2024 INI
*    IF <wa>-nr_mandato IS INITIAL.
*      SELECT nr_mandato_sost                         "#EC CI_SEL_NESTED
*          UP TO 1 ROWS FROM zfm_liq_t
*        INTO <wa>-nr_mandato_sost                       "#EC CI_CONV_OK
*        WHERE aa_liq EQ <wa>-aa_liq
*          AND n_liq EQ <wa>-n_liq
*          AND nr_mandato_sost NE space
*        ORDER BY PRIMARY KEY.
*      ENDSELECT.                                          "#EC CI_SUBRC
*    ELSE.
*      SELECT nr_mandato_sost                         "#EC CI_SEL_NESTED
*          UP TO 1 ROWS
*        FROM zfm_liq_t INTO <wa>-nr_mandato_sost        "#EC CI_CONV_OK
*        WHERE anno_mandato EQ <wa>-anno_mandato
*          AND nr_mandato EQ <wa>-nr_mandato
*          AND nr_mandato_sost NE space
*        ORDER BY PRIMARY KEY.
*      ENDSELECT.                                          "#EC CI_SUBRC
*    ENDIF.
*   end ins MF13052019
* arosati 29.07.2024 fine
*§---> Start Paganof - 21.01.2026 15:32:15 - Mev 112 Macroaggregato
    IF lt_fmci_macro IS NOT INITIAL.
      READ TABLE lt_fmci_macro ASSIGNING FIELD-SYMBOL(<fs_fmci_macro>) WITH KEY     fikrs = <wa>-fikrs
                                                                                    gjahr = <wa>-anno_mandato
                                                                                    fipex = <wa>-fipex BINARY SEARCH.
      IF sy-subrc EQ 0.
        <wa>-zzmacroaggr = <fs_fmci_macro>-zzmacroaggr.
      ENDIF.
    ENDIF.
*§---> End Paganof - 21.01.2026 15:32:19
*Start MOD CA 25/06/2026 Valorizzazione Eventuale Capitolo/Categoria per Accertamento Collegato MEV 112
    IF lt_acc_coll IS NOT INITIAL.
      READ TABLE lt_acc_coll ASSIGNING FIELD-SYMBOL(<fs_acc_coll>) WITH KEY belnr = <wa>-num_doc_collegato blpos = <wa>-pos_doc_collegato BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        <wa>-cap_ent        = <fs_acc_coll>-fipos.
*§---> Start Paganof - 21.01.2026 10:40:57 - Macroaggregato
*        <wa>-zzsf_categorie = <fs_acc_coll>-zzsf_categorie.
        IF <wa>-zzmacroaggr IS INITIAL.
          <wa>-zzmacroaggr = <fs_acc_coll>-zzmacroaggr.
        ENDIF.
*§---> End Paganof - 21.01.2026 10:41:09
*§---> Start Paganof - 10.04.2026 2-2361010866 fix cap_ent
      ELSE.

        IF <wa>-geber CP 'VO-*'.
          <wa>-cap_ent = <wa>-geber+3.
        ENDIF.

*§---> End Paganof - 10.04.2026
      ENDIF.
*§---> Start Paganof - 10.04.2026 2-2361010866 fix cap_ent
    ELSE.
      IF <wa>-geber CP 'VO-*'.
        <wa>-cap_ent = <wa>-geber+3.
      ENDIF.
*§---> End Paganof - 10.04.2026
    ENDIF.
*End MOD CA 25/06/2025 Valorizzazione Eventuale Capitolo/Categoria  per Accertamento Collegato MEV 112

*Start MOD CA 25/06/2025 Valorizzazione chiave accesso ai testi Standard dei Capitoli MEV 112
*    IF sy-tcode EQ 'ZVISU_MAND_CDC'
*Start MOD CA 04/07/2025 aggiunta condizione per valorizzazione chiave accesso ai testi Standard dei Capitoli per MEV 121
      IF ( sy-tcode EQ 'ZFM_VISU_MANDATI' AND cb_info IS NOT INITIAL ).
*End MOD CA 04/07/2025 aggiunta condizione per valorizzazione chiave accesso ai testi Standard dei Capitoli per MEV 121
      CONCATENATE <wa>-fikrs <wa>-aa_liq <wa>-fipex INTO <wa>-cap_usc_txt_key.
    ENDIF.

*    IF sy-tcode EQ 'ZVISU_MAND_CDC'.
*      IF <wa>-cap_ent IS NOT INITIAL.
*        CONCATENATE <wa>-fikrs <wa>-aa_liq <wa>-cap_ent INTO <wa>-cap_ent_txt_key.
*      ENDIF.
*    ENDIF.
*End MOD CA 25/06/2025 Valorizzazione chiave accesso ai testi Standard dei Capitoli MEV 112

*Start MOD CA 03/07/2025 Valorizzazione nuova colonna CIG-CUP MEV 112
*    IF sy-tcode EQ 'ZVISU_MAND_CDC'.
*      CONCATENATE <wa>-zsfcig <wa>-zsfcup INTO <wa>-cig_cup SEPARATED BY '-'.
*    ENDIF.
*End MOD CA 03/07/2025 Valorizzazione nuova colonna CIG-CUP MEV 112

*Start MOD CA 09/07/2025 Valorizzazione nuova colonna Totale Pagato Anno - 1 MEV 112
*    IF sy-tcode EQ 'ZVISU_MAND_CDC' AND lt_aa_prec IS NOT INITIAL.
*      READ TABLE lt_aa_prec ASSIGNING FIELD-SYMBOL(<fs_lt_prec>) WITH KEY codice_ben_alt = <wa>-num_ben BINARY SEARCH.
*      IF sy-subrc IS INITIAL.
*        <wa>-imp_quiet_prec = <fs_lt_prec>-imp_quiet_prec.
*      ENDIF.
*    ENDIF.
*End MOD CA 09/07/2025 Valorizzazione nuova colonna Totale Pagato Anno - 1 MEV 112

*Start MOD CA 04/07/2025 Valorizzazione nuove colonne DESCRIZIONE MANDATO/DESCRIZIONE_DG_PROP_MANDATO/DESCRIZIONE_DG_PROP_IMPEGNO MEV 121
    IF sy-tcode EQ 'ZFM_VISU_MANDATI' AND cb_info IS NOT INITIAL.
      <wa>-descrizione_mandato = <wa>-causale_liq.

      IF lt_dg_mand IS NOT INITIAL.
        READ TABLE lt_dg_mand ASSIGNING FIELD-SYMBOL(<fs_dg_mand>) WITH KEY cod_str_cdr = <wa>-dir_prop BINARY SEARCH.
        IF sy-subrc IS INITIAL.
          <wa>-descrizione_dg_prop_mandato = <fs_dg_mand>-descr_str_e.
        ENDIF.
      ENDIF.

      IF lt_dg_imp IS NOT INITIAL.
        READ TABLE lt_dg_imp ASSIGNING FIELD-SYMBOL(<fs_dg_imp>) WITH KEY cod_str_cdr = <wa>-dg_prop_imp BINARY SEARCH.
        IF sy-subrc IS INITIAL.
          <wa>-descrizione_dg_prop_impegno = <fs_dg_imp>-descr_str_e.
        ENDIF.
      ENDIF.
    ENDIF.
*End MOD CA 04/07/2025 Valorizzazione nuova colonna DESCRIZIONE MANDATO/DESCRIZIONE_DG_PROP_MANDATO/DESCRIZIONE_DG_PROP_IMPEGNO MEV 121

    AUTHORITY-CHECK OBJECT 'F_FICA_FTR'
    ID 'FM_AUTHACT' FIELD '03'
    ID 'FM_FIKRS'   FIELD p_fikrs
    ID 'FM_FINCODE' FIELD <wa>-geber
    ID 'FM_FICTR'   FIELD <wa>-fistl
    ID 'FM_FIPOS'   FIELD <wa>-fipex
    ID 'FM_AUTHDAY' DUMMY.

    IF sy-subrc EQ 0.
* arosati 30.07-2024 tolgo x ottimizzazione      INI
*      " recupero importo del documento FI
*      SELECT dmbtr sgtxt                             "#EC CI_SEL_NESTED
*          UP TO 1 ROWS
*        FROM bseg INTO (<wa>-dmbtr, <wa>-sgtxt)
*        WHERE bukrs EQ <wa>-bukrs
*          AND gjahr EQ <wa>-aa_doc_fi
*          AND belnr EQ <wa>-num_doc_fi
*          AND koart EQ 'K'
*        ORDER BY PRIMARY KEY.
*      ENDSELECT.                                          "#EC CI_SUBRC
* arosati 30.07-2024 tolgo x ottimizzazione FINE
      " recupero riferimento del documento FI
* arosati 30.07-2024 sposto x ottimizzazione  INI
*      SELECT SINGLE xblnr blart budat bldat zzdata_scad_pagam_siope "#EC CI_SEL_NESTED
*             FROM bkpf
*             INTO (<wa>-xblnr, <wa>-blart, <wa>-budat, <wa>-bldat, <wa>-zzdata_scad_pagam_siope )"arosati 19.07.2024 mev 15 part ii
*             WHERE bukrs EQ <wa>-bukrs
*               AND gjahr EQ <wa>-aa_doc_fi
*               AND belnr EQ <wa>-num_doc_fi.              "#EC CI_SUBRC
**arosati 19.07.2024 mev 15 part ii ini
*      IF <wa>-num_pre IS INITIAL.
*        CLEAR    <wa>-zzdata_scad_pagam_siope .
*      ENDIF.
*arosati 19.07.2024 mev 15 part ii fine
* arosati 30.07-2024 sposto x ottimizzazione  INI
*

*Start MOD BCSOFT 03/10/2024
**AGIL - 20171215 - Start
**Recupera descrizione beneficiario
*      CALL FUNCTION 'Z_DESCRIZIONE_BENEFICIARIO'
*        EXPORTING
*          i_lifnr                    = <wa>-num_ben
*        IMPORTING
*          e_descrizione              = <wa>-desc_ben
*        EXCEPTIONS
*          beneficiario_non_esistente = 1
*          OTHERS                     = 2.
*      IF sy-subrc <> 0.
*        CLEAR <wa>-desc_ben.
*      ENDIF.
***AGIL - 20171215 - End

*      CLEAR <wa>-datadurc.
*      SELECT SINGLE datadurc INTO <wa>-datadurc
*        FROM lfa1
*       WHERE lifnr EQ <wa>-num_ben
*         AND durc = 'X'.
*End MOD BCSOFT 03/10/2024
      IF p_gdurc IS NOT INITIAL.
        IF  <wa>-datadurc IS NOT INITIAL
        AND <wa>-datadurc <= dt_lim_durc.
          APPEND <wa> TO i_lista_def.
        ENDIF.
      ELSE.
        APPEND <wa> TO i_lista_def.
      ENDIF.
    ENDIF.
  ENDLOOP.
*END INS EB070616

  PERFORM valorizza_descrizioni. "Ins GM281223

*§---> Begin - 2-2330488348 accorpare solo per CdC - 16.02.26 - VR
*  IF sy-tcode EQ 'ZVISU_MAND_CDC'.
*§---> Start Paganof - 29.01.2026 15:27:00 - MEV 112 accorpare dati
*    PERFORM f_accorpare_dati.
*§---> End Paganof - 29.01.2026 15:27:08
*  ENDIF.
*§---> End - 2-2330488348 accorpare solo per CdC - 16.02.26 - VR

*** End-of-selection
END-OF-SELECTION.

  CHECK gv_no_data IS INITIAL.

  CLEAR i_fieldcat[].

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_structure_name       = 'ZFM_LISTA_INFO_MANDATI'
    CHANGING
      ct_fieldcat            = i_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc IS INITIAL.
  ELSE.
  ENDIF.

  st_layout-zebra = 'X'.
  st_layout-colwidth_optimize = 'X'. "ins AGIL - 20171215

  PERFORM modify_fieldcat. "ins eb090616
  ##WRITE_OK
  CLEAR sy-binpt. "Ins GM290224 -> Altrimenti se si fa ZSX01 -> Click su beneficiario -> Click su hotspot liqui -> viene esposto come lista e non grid

*§---> Begin - Gestione layout globale - 14.03.24 - VR
  ##NEEDED
  DATA lv_save.
  CLEAR lv_save.

  "Check autorizzazione per layout globali
  CALL FUNCTION 'ZFM_AUTH_LAYOUT_FATTURE'
    IMPORTING
      e_save = lv_save.
*§---> End - Gestione layout globale - 14.03.24 - VR

*Start MOD BCSOFT 26/07/2024
  gs_variant-report   = sy-repid.
  gs_variant-username = sy-uname.
  gs_variant-variant  = p_layout.
*End MOD BCSOFT 26/07/2024

*  IF sy-tcode EQ 'ZVISU_MAND_CDC'.
*    sy-title = 'Lista Liquidazioni/Mandati per Corte dei Conti'.
*  ENDIF.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program            = sy-repid
      i_callback_user_command       = 'USER_COMMAND'
      i_callback_pf_status_set      = 'PF_STATUS'
      is_layout                     = st_layout
      it_fieldcat                   = i_fieldcat[]
*Start MOD BCSOFT 26/07/2024
      is_variant                    = gs_variant
*End MOD BCSOFT 26/07/2024
      ##NUMBER_OK i_html_height_top = 35
*§---> Begin - Gestione layout globale - 14.03.24 - VR
      i_save                        = lv_save
*§---> End - Gestione layout globale - 14.03.24 - VR
      i_grid_title                  = sy-title
    TABLES
      t_outtab                      = i_lista_def "mod EB070616
      ##FM_SUBRC_OK
    EXCEPTIONS
      program_error                 = 1
      OTHERS                        = 2.
  ##NEEDED
  IF sy-subrc <> 0. ENDIF.

*** G4DK907706 - BEG
*********************************************************************
FORM coni_vis.
  CLEAR: tb_1251[], tb_users[].
  SELECT * FROM agr_1251                              "#EC CI_SGLSELECT
           INTO CORRESPONDING FIELDS OF TABLE tb_1251
           WHERE agr_name LIKE 'ZFM:S4H_E_CDR%'
             AND object   EQ   'ZFM_CDR'
             AND field    EQ   'ZFM_CDR'
             AND deleted  EQ   ' '.
  SORT tb_1251 BY agr_name ASCENDING.

  SELECT * FROM agr_users                     "#EC CI_FAE_LINES_ENSURED
           FOR ALL ENTRIES IN @tb_1251[]
           WHERE agr_name EQ @tb_1251-agr_name
             AND from_dat LE @sy-datum
             AND to_dat   GE @sy-datum
             AND uname    EQ @sy-uname
            INTO CORRESPONDING FIELDS OF TABLE @tb_users.

  IF tb_users[] IS NOT INITIAL.
*** G4DK908267 - BEG
    CLEAR: z_dir_d[], z_dir_p[], flag_am,
           z_fistl[].                                       "G4DK909753
    LOOP AT tb_users INTO wa_users.
      READ TABLE tb_1251 INTO wa_1251
           WITH KEY agr_name = wa_users-agr_name.
      IF wa_1251-agr_name+14(2) EQ 'AM'.
        flag_am = 'X'.
*§---> Start Paganof - 11.02.2026 - ATC
        EXIT.                                           "#EC CI_NOORDER
*§---> End Paganof - 11.02.2026
      ELSE.
        z_dir_d-low    = wa_1251-agr_name+14.
        z_dir_d-high   = wa_1251-agr_name+14.
        z_dir_d-sign   = 'I'.
        z_dir_d-option = 'BT'.
        APPEND z_dir_d.

        z_dir_p-low    = wa_1251-agr_name+14.
        z_dir_p-high   = wa_1251-agr_name+14.
        z_dir_p-sign   = 'I'.
        z_dir_p-option = 'BT'.
        APPEND z_dir_p.
*** G4DK909753 - BEG
        z_fistl-low    = wa_1251-agr_name+14.
        z_fistl-high   = wa_1251-agr_name+14.
        z_fistl-sign   = 'I'.
        z_fistl-option = 'BT'.
        APPEND z_fistl.
*** G4DK909753 - END
      ENDIF.
    ENDLOOP.

    DATA: lv_index LIKE sy-tabix.

    IF flag_am IS INITIAL.
      LOOP AT s_dir_d ASSIGNING FIELD-SYMBOL(<fs_dird>).
        lv_index = sy-tabix.
        READ TABLE z_dir_d
             WITH KEY low = <fs_dird>-low
             TRANSPORTING NO FIELDS.
        IF sy-subrc IS NOT INITIAL.
          DELETE s_dir_d INDEX lv_index.
          CONTINUE.
        ENDIF.
      ENDLOOP.

      LOOP AT s_dir_p ASSIGNING FIELD-SYMBOL(<fs_dirp>).
        lv_index = sy-tabix.
        READ TABLE z_dir_p
             WITH KEY low = <fs_dirp>-low
             TRANSPORTING NO FIELDS.
        IF sy-subrc IS NOT INITIAL.
          DELETE s_dir_p INDEX lv_index.
          CONTINUE.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF s_dir_d[] IS INITIAL.
      s_dir_d[] = z_dir_d[].
    ENDIF.

    IF s_dir_p[] IS INITIAL.
      s_dir_p[] = z_dir_p[].
    ENDIF.
*** G4DK908267 - END
  ELSE.
    MESSAGE e000(db)
##NO_TEXT WITH 'Utente non autorizzato per Coni Visibilità'.
  ENDIF.
ENDFORM.
*** G4DK907706 - END

*Start ins GM281223
*********************************************************************
FORM valorizza_descrizioni.
  TYPES:
    BEGIN OF ty_misspro_range,
      gjahr TYPE gjahr,
      miss  TYPE zsf_missioni,
      prog  TYPE zsf_programmi,
    END OF ty_misspro_range,
    BEGIN OF ty_fistl_range,
      fistl TYPE fistl,
      data  TYPE d,
    END OF ty_fistl_range,
    BEGIN OF ty_titolo_range,
      gjahr TYPE gjahr,
      tit   TYPE z_titolo,
    END OF ty_titolo_range,
    BEGIN OF ty_ambgsa_range,
      gjahr TYPE gjahr,
      gsa   TYPE zsf_gsa,
      amb   TYPE zz_ambito_gsa,
    END OF ty_ambgsa_range.

  DATA:
    lt_fistl   TYPE STANDARD TABLE OF ty_fistl_range,
    ls_fistl   LIKE LINE OF  lt_fistl,
    lt_fipex   TYPE RANGE OF fm_fipex,
    ls_fipex   LIKE LINE OF  lt_fipex,
    lt_misspro TYPE STANDARD TABLE OF ty_misspro_range,
    ls_misspro LIKE LINE OF  lt_misspro,
    lt_idric   TYPE RANGE OF zzidric,
    ls_idric   LIKE LINE OF  lt_idric,
    lt_codue   TYPE RANGE OF zzcodue,
    ls_codue   LIKE LINE OF  lt_codue,
    lt_titolo  TYPE STANDARD TABLE OF ty_titolo_range,
    ls_titolo  LIKE LINE OF  lt_titolo,
    lt_risorsa TYPE RANGE OF fmci-ztipo_risorsa,
    ls_risorsa LIKE LINE OF lt_risorsa,
    lt_codgsa  TYPE RANGE OF fmci-zzsf_gsa,
    ls_codgsa  LIKE LINE OF lt_codgsa,
    lt_ambgsa  TYPE STANDARD TABLE OF ty_ambgsa_range,
    ls_ambgsa  LIKE LINE OF lt_ambgsa.

*Start MOD CA 25/06/2025 dichiarazioni per modifica Testi Stancard MEV 112
  TYPES: BEGIN OF ts_stxl_raw,
           clustr TYPE stxl-clustr,
           clustd TYPE stxl-clustd,
         END OF ts_stxl_raw.

  DATA: lt_stxl_raw TYPE STANDARD TABLE OF ts_stxl_raw,
        ls_stxl_raw TYPE ts_stxl_raw,
        lt_tline    TYPE STANDARD TABLE OF tline,
        lv_string   TYPE string.
*End MOD CA 25/06/2025 dichiarazioni per modifica Testi Stancard MEV 112

  " Tabelle per le transcodifiche
  " Centro di responsabilità
  TYPES:
    BEGIN OF ty_fistl,
      fictr     TYPE zzcod_str_cdr,
      beschr    TYPE  zdescr_str,
      dt_inizio TYPE  d,
      dt_fine   TYPE  d,
    END OF ty_fistl.
  DATA: lt_txt_fistl TYPE STANDARD TABLE OF ty_fistl.
  " Capitolo
  TYPES:
    BEGIN OF ty_fipex,
      gjahr TYPE gjahr,
      fipex TYPE fm_fipex,
      text1 TYPE fm_beschr0,
      text2 TYPE fm_beschr2,
      text3 TYPE fm_beschr3,
    END OF ty_fipex.
  DATA: lt_txt_fipex     TYPE STANDARD TABLE OF ty_fipex.

  " Missione/Programma
  TYPES:
    BEGIN OF ty_misspro,
      gjahr              TYPE gjahr,
      zzsf_missioni      TYPE zsf_missioni,
      zzsf_programmi     TYPE zsf_programmi,
      zzsf_txt_missioni  TYPE zsf_txt_missione,
      zzsf_txt_programmi TYPE zsf_txt_programma,
    END OF ty_misspro.
  DATA: lt_txt_misspro TYPE STANDARD TABLE OF ty_misspro.
  FIELD-SYMBOLS: <lfs_txt_misspro> LIKE LINE OF lt_txt_misspro.
  " Codice identificativo ricorrente
  TYPES:
    BEGIN OF ty_idric,
      gjahr       TYPE gjahr,
      zzidric     TYPE zzidric,
      zzdes_idric TYPE zzdes_idric,
    END OF ty_idric.
  DATA: lt_txt_idric TYPE STANDARD TABLE OF ty_idric.
  FIELD-SYMBOLS: <lfs_txt_idric> LIKE LINE OF lt_txt_idric.
  " Codice UE
  TYPES:
    BEGIN OF ty_codue,
      gjahr    TYPE gjahr,
      zzcodue  TYPE zzcodue,
      zzdes_ue TYPE zzdes_ue,
    END OF ty_codue.
  DATA: lt_txt_codue TYPE STANDARD TABLE OF ty_codue.
  FIELD-SYMBOLS: <lfs_txt_codue> LIKE LINE OF lt_txt_codue.
*Start ins GM211223
  " Titolo
  TYPES:
    BEGIN OF ty_titolo,
      gjahr     TYPE gjahr,
      zztitolo  TYPE z_titolo,
      zztitolot TYPE ztitolot,
    END OF ty_titolo.
  DATA: lt_txt_titolo TYPE STANDARD TABLE OF ty_titolo.
  TYPES:
    BEGIN OF ty_risorsa,
      ztipo_risorsa TYPE ztipo_risorsa,
      zdesc_tiporis TYPE zdesc_tiporis,
    END OF ty_risorsa.
  DATA: lt_txt_risorsa TYPE STANDARD TABLE OF ty_risorsa.
  TYPES:
    BEGIN OF ty_codgsa,
      zzsf_gsa    TYPE zsf_gsa,
      zzdes_idcap TYPE zzdes_idcap,
    END OF ty_codgsa.
  DATA: lt_txt_codgsa TYPE STANDARD TABLE OF ty_codgsa.
  TYPES:
    BEGIN OF ty_ambgsa,
      gjahr         TYPE gjahr,
      zzsf_gsa      TYPE zsf_gsa,
      zz_ambito_gsa TYPE zz_ambito_gsa,
      zzdes_ambgsa  TYPE zzdes_ambgsa,
    END OF ty_ambgsa.
  DATA: lt_txt_ambgsa TYPE STANDARD TABLE OF ty_ambgsa.

  ls_fipex-sign    = 'I'.
  ls_fipex-option  = 'EQ'.
  ls_idric-sign    = 'I'.
  ls_idric-option  = 'EQ'.
  ls_codue-sign    = 'I'.
  ls_codue-option  = 'EQ'.
  ls_risorsa(3)    = 'IEQ'.
  ls_codgsa(3)     = 'IEQ'.
  ls_ambgsa(3)     = 'IEQ'.

  LOOP AT i_lista_def ASSIGNING FIELD-SYMBOL(<lfs_lista_def>).
    ls_fipex-low  = <lfs_lista_def>-fipex.
    APPEND ls_fipex TO lt_fipex.
    ls_misspro-gjahr  = <lfs_lista_def>-aa_liq.
    ls_misspro-miss   = <lfs_lista_def>-zzsf_missioni.
    ls_misspro-prog   = <lfs_lista_def>-zzsf_programmi.
    APPEND ls_misspro TO lt_misspro.
    ls_idric-low  = <lfs_lista_def>-zzidric.
    APPEND ls_idric TO lt_idric.
    ls_codue-low  = <lfs_lista_def>-zzcodue.
    APPEND ls_codue TO lt_codue.
    ls_titolo-gjahr  = <lfs_lista_def>-aa_liq.
    ls_titolo-tit    = <lfs_lista_def>-zz_titolo.
    APPEND ls_titolo TO lt_titolo.
    ls_risorsa-low     = <lfs_lista_def>-ztipo_risorsa.
    IF ls_risorsa-low IS  NOT INITIAL.
      APPEND ls_risorsa TO lt_risorsa.
    ENDIF.
    ls_codgsa-low     = <lfs_lista_def>-zzsf_gsa.
    IF ls_codgsa-low IS  NOT INITIAL.
      APPEND ls_codgsa TO lt_codgsa.
    ENDIF.
    ls_ambgsa-gjahr  = <lfs_lista_def>-aa_liq.
    ls_ambgsa-gsa    = <lfs_lista_def>-zzsf_gsa.
    ls_ambgsa-amb    = <lfs_lista_def>-zz_ambito_gsa.
    IF ls_ambgsa-amb IS NOT INITIAL.
      APPEND ls_ambgsa TO lt_ambgsa.
    ENDIF.
    ls_fistl-fistl = <lfs_lista_def>-fistl.
    ls_fistl-data  = <lfs_lista_def>-budat.
    IF ls_fistl-fistl IS NOT INITIAL.
      APPEND ls_fistl TO lt_fistl.
    ENDIF.
  ENDLOOP.

  SORT lt_fistl.
  DELETE ADJACENT DUPLICATES FROM lt_fistl.
  SORT lt_fipex.
  DELETE ADJACENT DUPLICATES FROM lt_fipex.
  SORT lt_misspro.
  DELETE ADJACENT DUPLICATES FROM lt_misspro.
  SORT lt_idric.
  DELETE ADJACENT DUPLICATES FROM lt_idric.
  SORT lt_codue.
  DELETE ADJACENT DUPLICATES FROM lt_codue.
  SORT lt_titolo.
  DELETE ADJACENT DUPLICATES FROM lt_titolo.
  SORT lt_risorsa.
  DELETE ADJACENT DUPLICATES FROM lt_risorsa.
  SORT lt_codgsa.
  DELETE ADJACENT DUPLICATES FROM lt_codgsa.
  SORT lt_ambgsa.
  DELETE ADJACENT DUPLICATES FROM lt_ambgsa.

  " Transcodifica centro di responsabilità
  IF lt_fistl[] IS NOT INITIAL.
    SELECT cod_str_cdr AS fictr, descr_str_e AS beschr, dt_inizio, dt_fine
           FROM zfm_strorg_edma
           INTO CORRESPONDING FIELDS OF TABLE @lt_txt_fistl
           FOR ALL ENTRIES IN @lt_fistl
           WHERE cod_str_cdr  EQ @lt_fistl-fistl
             AND dt_inizio    LE @lt_fistl-data
             AND dt_fine      GE @lt_fistl-data.          "#EC CI_SUBRC
    IF sy-subrc EQ 0.
      SORT lt_txt_fistl.
    ENDIF.
    CLEAR: lt_fistl[].
  ENDIF.

  " Transcodifica capitolo
  IF lt_fipex[] IS NOT INITIAL.
    SELECT fipex, gjahr, text1, text2, text3
      FROM fmcit
      INTO CORRESPONDING FIELDS OF TABLE @lt_txt_fipex
      FOR ALL ENTRIES IN @lt_fipex
      WHERE spras EQ @sy-langu
        AND fikrs EQ @p_fikrs     "lp20160506  co_fikrs
        AND fipex EQ @lt_fipex-low.
    IF sy-subrc EQ 0.
      SORT lt_txt_fipex.
    ENDIF.
    CLEAR: lt_fipex[].
  ENDIF.

  " Transcodifica Missione/Programma
  IF lt_misspro[] IS NOT INITIAL.
    SELECT gjahr, zzsf_missioni, zzsf_programmi, zzsf_txt_missioni, zzsf_txt_programmi
      FROM zfm_miss_prog
      INTO CORRESPONDING FIELDS OF TABLE @lt_txt_misspro
      FOR ALL ENTRIES IN @lt_misspro
      WHERE gjahr          EQ @lt_misspro-gjahr
        AND zzsf_missioni  EQ @lt_misspro-miss
        AND zzsf_programmi EQ @lt_misspro-prog.
    IF sy-subrc EQ 0.
      SORT lt_txt_misspro.
    ENDIF.
    CLEAR: lt_misspro[].
  ENDIF.

  " Codice identificativo ricorrente
  IF lt_idric[] IS NOT INITIAL.
    SELECT gjahr, zzidric, fpart, zzdes_idric
      FROM zsericorrente
      INTO CORRESPONDING FIELDS OF TABLE @lt_txt_idric
      FOR ALL ENTRIES IN @lt_idric
      WHERE fikrs   EQ @p_fikrs     "lp20160506  co_fikrs
        AND fpart   EQ 'UP'
        AND zzidric EQ @lt_idric-low.
    IF sy-subrc EQ 0.
      SORT lt_txt_idric.
    ENDIF.
    CLEAR: lt_idric[].
  ENDIF.

  " Codice UE
  IF lt_codue[] IS NOT INITIAL.
    SELECT gjahr, zzcodue, fpart, zzdes_ue
      FROM zcod_ue
      INTO CORRESPONDING FIELDS OF TABLE @lt_txt_codue
      FOR ALL ENTRIES IN @lt_codue
      WHERE fikrs   EQ @p_fikrs      "lp20160506  co_fikrs
        AND fpart   EQ 'UP'
        AND zzcodue EQ @lt_codue-low.
    IF sy-subrc EQ 0.
      SORT lt_txt_codue.
    ENDIF.
    CLEAR: lt_codue[].
  ENDIF.

  " Transcodifica Titolo
  IF lt_titolo[] IS NOT INITIAL.
    SELECT gjahr, zztitolo, zztitolot
      FROM zfm_titolo
      INTO CORRESPONDING FIELDS OF TABLE @lt_txt_titolo
      FOR ALL ENTRIES IN @lt_titolo
      WHERE gjahr    EQ @lt_titolo-gjahr
        AND fpart    EQ 'UP'
        AND zztitolo EQ @lt_titolo-tit.
    IF sy-subrc EQ 0.
      SORT lt_txt_titolo.
    ENDIF.
    CLEAR: lt_titolo[].
  ENDIF.
  " Transcodifica Risorsa
  IF lt_risorsa[] IS NOT INITIAL.
    SELECT ztipo_risorsa, zdesc_tiporis
      FROM ztipo_risorse
      INTO CORRESPONDING FIELDS OF TABLE @lt_txt_risorsa
      WHERE fikrs         EQ @p_fikrs
        AND ztipo_risorsa IN @lt_risorsa
        AND fpart         EQ 'UP'
      ORDER BY PRIMARY KEY.
    CLEAR: lt_risorsa[].
  ENDIF.
  " Transcodifica CodiceGSA
  IF lt_codgsa[] IS NOT INITIAL.
    SELECT zzsf_gsa, zzdes_idcap
      FROM zflag_gsa
      INTO CORRESPONDING FIELDS OF TABLE @lt_txt_codgsa
      WHERE fikrs    EQ @p_fikrs
        AND zzsf_gsa IN @lt_codgsa
        AND fpart    EQ 'UP'
      ORDER BY PRIMARY KEY.
    CLEAR: lt_codgsa[].
  ENDIF.
  " Transcodifica Ambito GSA
  IF lt_ambgsa[] IS NOT INITIAL.
    SELECT gjahr, zz_ambito_gsa, zzsf_gsa, zzdes_ambgsa
      FROM zambitogsa
      INTO CORRESPONDING FIELDS OF TABLE @lt_txt_ambgsa
      FOR ALL ENTRIES IN @lt_ambgsa
      WHERE gjahr         EQ @lt_ambgsa-gjahr
        AND fikrs         EQ @p_fikrs
        AND zz_ambito_gsa EQ @lt_ambgsa-amb
        AND fpart         EQ 'UP'
        AND zzsf_gsa      EQ @lt_ambgsa-gsa.
    IF sy-subrc EQ 0.
      SORT lt_txt_ambgsa.
    ENDIF.
    CLEAR: lt_ambgsa[].
  ENDIF.

*Start MOD CA 25/06/2025 estrazione Testi Standard Capitolo Uscita MEV 112
*  IF sy-tcode EQ 'ZVISU_MAND_CDC'
*Start MOD CA 04/07/2025 aggiunta condizione per estrazione Testi Standard Capitolo Uscita  per MEV 121
     IF ( sy-tcode EQ 'ZFM_VISU_MANDATI' AND cb_info IS NOT INITIAL ).
*End MOD CA 04/07/2025 aggiunta condizione per estrazione Testi Standard Capitolo Uscita per MEV 121
    SELECT tdname,
         clustr,
         clustd ##SELECT_FAE_WITH_LOB[CLUSTD]
     FROM stxl
    FOR ALL ENTRIES IN @i_lista_def
     WHERE relid    EQ 'TX'
       AND tdobject EQ 'FMMD'
       AND tdname   EQ @i_lista_def-cap_usc_txt_key
       AND tdid     EQ 'FP01'
       AND tdspras  EQ @sy-langu
       INTO TABLE @DATA(lt_raw_usc).
    IF sy-subrc IS INITIAL.
      SORT lt_raw_usc BY tdname.
      DELETE ADJACENT DUPLICATES FROM lt_raw_usc COMPARING tdname.
    ENDIF.
  ENDIF.
*End MOD CA 25/06/2025 estrazione Testi Standard Capitolo uscita  MEV 112

*Start MOD CA 25/06/2025 estrazione Testi Standard Capitolo Uscita MEV 112
*  IF sy-tcode EQ 'ZVISU_MAND_CDC'.
*    SELECT tdname,
*           clustr,
*           clustd ##SELECT_FAE_WITH_LOB[CLUSTD]
*      FROM stxl
*    FOR ALL ENTRIES IN @i_lista_def
*     WHERE relid    EQ 'TX'
*       AND tdobject EQ 'FMMD'
*       AND tdname   EQ @i_lista_def-cap_ent_txt_key
*       AND tdid     EQ 'FP01'
*       AND tdspras  EQ @sy-langu
*      INTO TABLE @DATA(lt_raw_ent).
*    IF sy-subrc IS INITIAL.
*      SORT lt_raw_ent BY tdname.
*      DELETE ADJACENT DUPLICATES FROM lt_raw_ent COMPARING tdname.
*    ENDIF.
*  ENDIF.
*End MOD CA 25/06/2025 estrazione Testi Standard Capitolo uscita  MEV 112

  " Secondo loop: scrivo i campi delle transcodifiche secondo i concatenate richiesti
  LOOP AT i_lista_def ASSIGNING <lfs_lista_def>.
*    " Centro di responsabilità
*    LOOP AT lt_txt_fistl ASSIGNING <lfs_txt_fistl> WHERE fictr     EQ <lfs_lista_def>-fistl
*                                                     AND dt_inizio LE <lfs_lista_def>-budat
*                                                     AND dt_fine   GE <lfs_lista_def>-budat.
*      <lfs_lista_def>-fistl_txt = <lfs_txt_fistl>-beschr.
*      EXIT.
*    ENDLOOP.
*
*    " Capitolo
*    READ TABLE lt_txt_fipex ASSIGNING <lfs_txt_fipex> WITH KEY gjahr = <lfs_lista_def>-anno_documento
*                                                               fipex = <lfs_lista_def>-fipex
*                                                               BINARY SEARCH.
*    IF sy-subrc IS INITIAL.
*      CONCATENATE <lfs_txt_fipex>-text1 <lfs_txt_fipex>-text2 <lfs_txt_fipex>-text3
*                  INTO <lfs_lista_def>-fipex_txt SEPARATED BY space.
*      CONDENSE <lfs_lista_def>-fipex_txt.
*    ENDIF.

    " Missione/Programma
    READ TABLE lt_txt_misspro ASSIGNING <lfs_txt_misspro>
         WITH KEY gjahr          = <lfs_lista_def>-aa_liq
                  zzsf_missioni  = <lfs_lista_def>-zzsf_missioni
                  zzsf_programmi = <lfs_lista_def>-zzsf_programmi BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      <lfs_lista_def>-miss_txt = <lfs_txt_misspro>-zzsf_txt_missioni.
      <lfs_lista_def>-prog_txt = <lfs_txt_misspro>-zzsf_txt_programmi.
    ENDIF.

    " Codice identificativo ricorrente
    READ TABLE lt_txt_idric ASSIGNING <lfs_txt_idric>
         WITH KEY gjahr   = <lfs_lista_def>-aa_liq
                  zzidric = <lfs_lista_def>-zzidric BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      <lfs_lista_def>-zzidric_txt = <lfs_txt_idric>-zzdes_idric.
    ENDIF.

    " Codice UE
    READ TABLE lt_txt_codue ASSIGNING <lfs_txt_codue>
         WITH KEY gjahr   = <lfs_lista_def>-aa_liq
                  zzcodue = <lfs_lista_def>-zzcodue BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      <lfs_lista_def>-zzcodue_txt = <lfs_txt_codue>-zzdes_ue.
    ENDIF.

    " Titolo
    READ TABLE lt_txt_titolo ASSIGNING FIELD-SYMBOL(<lfs_txt_titolo>)
         WITH KEY gjahr    = <lfs_lista_def>-aa_liq
                  zztitolo = <lfs_lista_def>-zz_titolo BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      <lfs_lista_def>-titolo_txt = <lfs_txt_titolo>-zztitolot.
    ENDIF.
    " Risorsa
    READ TABLE lt_txt_risorsa ASSIGNING FIELD-SYMBOL(<lfs_txt_risorsa>)
         WITH KEY ztipo_risorsa = <lfs_lista_def>-ztipo_risorsa BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      <lfs_lista_def>-ztipo_risorsa_txt = <lfs_txt_risorsa>-zdesc_tiporis.
    ENDIF.
    " Codice GSA
    READ TABLE lt_txt_codgsa ASSIGNING FIELD-SYMBOL(<lfs_txt_codgsa>)
         WITH KEY zzsf_gsa = <lfs_lista_def>-zzsf_gsa BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      <lfs_lista_def>-zzsf_gsa_txt = <lfs_txt_codgsa>-zzdes_idcap.
    ENDIF.
    " Ambito GSA
    READ TABLE lt_txt_ambgsa ASSIGNING FIELD-SYMBOL(<lfs_txt_ambgsa>)
         WITH KEY gjahr          = <lfs_lista_def>-aa_liq
                  zzsf_gsa       = <lfs_lista_def>-zzsf_gsa
                  zz_ambito_gsa  = <lfs_lista_def>-zz_ambito_gsa BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      <lfs_lista_def>-zz_ambito_gsa_txt = <lfs_txt_ambgsa>-zzdes_ambgsa.
    ENDIF.

*Start MOD CA 23/06/2025 valorizzazione Perimetro GSA in base a Codice GSA MEV 112
*    IF sy-tcode EQ 'ZVISU_MAND_CDC'.
*      IF <lfs_lista_def>-zzsf_gsa EQ 3.
*        <lfs_lista_def>-perimetro_gsa = 'NO'.
*      ELSEIF <lfs_lista_def>-zzsf_gsa EQ 4.
*        <lfs_lista_def>-perimetro_gsa = 'SI'.
*      ENDIF.
*    ENDIF.
*End MOD CA 23/06/2025 valorizzazione Perimetro GSA in base a Codice GSA MEV 112

*Start MOD CA 25/06/2025 valorizzazione Testi Standard Capitolo uscita MEV 112
*    IF sy-tcode EQ 'ZVISU_MAND_CDC'
*Start MOD CA 04/07/2025 aggiunta condizione per valorizzazione Testi Standard Capitolo uscita per MEV 121
      IF ( sy-tcode EQ 'ZFM_VISU_MANDATI' AND cb_info IS NOT INITIAL ).
*End MOD CA 04/07/2025 aggiunta condizione per valorizzazione Testi Standard Capitolo uscitaper MEV 121
      READ TABLE lt_raw_usc ASSIGNING FIELD-SYMBOL(<fs_raw_usc>) WITH KEY tdname = <lfs_lista_def>-cap_usc_txt_key.
      IF sy-subrc IS INITIAL.
        REFRESH: lt_stxl_raw, lt_tline.

        CLEAR ls_stxl_raw.
        ls_stxl_raw-clustr = <fs_raw_usc>-clustr.
        ls_stxl_raw-clustd = <fs_raw_usc>-clustd.
        APPEND ls_stxl_raw TO lt_stxl_raw.

        IMPORT tline = lt_tline FROM INTERNAL TABLE lt_stxl_raw.

        CLEAR lv_string.

        LOOP AT lt_tline ASSIGNING FIELD-SYMBOL(<tline>). "#EC CI_NESTED
          CONCATENATE lv_string <tline>-tdline
                 INTO lv_string SEPARATED BY space.
        ENDLOOP.

        SHIFT lv_string LEFT DELETING LEADING space.

        <lfs_lista_def>-descr_cap_usc = lv_string.
      ENDIF.
    ENDIF.
*End MOD CA 25/06/2025 valorizzazione Testi Standard Capitolo uscita MEV 112

*Start MOD CA 25/06/2025 valorizzazione Testi Standard Capitolo entrata MEV 112
*    IF sy-tcode EQ 'ZVISU_MAND_CDC'.
*      READ TABLE lt_raw_ent ASSIGNING FIELD-SYMBOL(<fs_raw_ent>) WITH KEY tdname = <lfs_lista_def>-cap_ent_txt_key.
*      IF sy-subrc IS INITIAL.
*        REFRESH: lt_stxl_raw, lt_tline.

*        CLEAR ls_stxl_raw.
*        ls_stxl_raw-clustr = <fs_raw_ent>-clustr.
*        ls_stxl_raw-clustd = <fs_raw_ent>-clustd.
*        APPEND ls_stxl_raw TO lt_stxl_raw.

*       IMPORT tline = lt_tline FROM INTERNAL TABLE lt_stxl_raw.

*        CLEAR lv_string.

*        LOOP AT lt_tline ASSIGNING FIELD-SYMBOL(<tline2>). "#EC CI_NESTED
*          CONCATENATE lv_string <tline2>-tdline
*                 INTO lv_string SEPARATED BY space.
*        ENDLOOP.

*        SHIFT lv_string LEFT DELETING LEADING space.

*        <lfs_lista_def>-descr_cap_ent = lv_string.
*      ENDIF.
*    ENDIF.
*End MOD CA 25/06/2025 valorizzazione Testi Standard Capitolo entrata MEV 112
  ENDLOOP.
ENDFORM.
*End   ins GM281223

*********************************************************************
##CALLED
FORM user_command USING ucomm    TYPE sy-ucomm
                        selfield TYPE slis_selfield.

  READ TABLE i_lista_def INTO w_lista INDEX selfield-tabindex.
  CHECK sy-subrc = 0.

*  CASE ucomm.
*    WHEN '&IC1'.
*      CASE  selfield-fieldname.
*        WHEN 'N_LIQ'.
*          PERFORM visualizza.
*        WHEN 'NR_MANDATO'.
*          CHECK w_lista-nr_mandato IS NOT INITIAL.
*          PERFORM visualizza_mandato. "$$$
*        WHEN 'IMPEGNO'.
*          PERFORM visualizza_impegno.
*        WHEN 'NUM_DOC_FI'.
*          PERFORM visualizza_fattura.
*      ENDCASE.
*  ENDCASE.
ENDFORM.

*********************************************************************
##CALLED ##NEEDED
FORM pf_status USING alv_extab TYPE slis_t_extab.
  SET PF-STATUS 'PF_STATUS'.
ENDFORM.

*********************************************************************
FORM visualizza.

*§---> Begin - TKT 2-2164865139 - visualizza Liq da reintegro - 02.09.24 - VR
** Start ins LS260218
*  DATA lv_economo LIKE tvarvc-low.
*
*  SELECT low UP TO 1 ROWS
*    FROM tvarvc INTO lv_economo
*    WHERE name EQ 'Z_ECONOMO'
*    ORDER BY PRIMARY KEY.
*  ENDSELECT.                                              "#EC CI_SUBRC
*
*  SELECT SINGLE @abap_true INTO @DATA(lv_true)
*         FROM zfm_liq_t
*         WHERE aa_liq   EQ @w_lista-aa_liq
*           AND n_liq    EQ @w_lista-n_liq
*           AND tipo_liq EQ 'R'.                           "#EC CI_SUBRC
*
*  IF lv_true IS NOT INITIAL AND lv_economo EQ 'X'.
*
*    PERFORM bdc_dynpro USING 'ZFM_GESTIONE_LIQUIDAZIONI_R'
*                             '1100'.
*    PERFORM bdc_field  USING 'BDC_OKCODE'
*                             '=AVVIO'.
*    PERFORM bdc_field  USING 'P_AALIQ'
*                              w_lista-aa_liq.
*    PERFORM bdc_field  USING 'S_N_LIQ-LOW'
*                              w_lista-n_liq.
*
*    PERFORM bdc_transaction USING 'ZFM_VIS_LIQUI_R'.
*
*  ELSE.
* End   ins LS260218
*§---> End - TKT 2-2164865139 - visualizza Liq da reintegro - 02.09.24 - VR
  PERFORM bdc_dynpro      USING 'ZFM_GESTIONE_LIQUIDAZIONI' '1100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ENTER'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'P_N_LIQ'.
  PERFORM bdc_field       USING 'P_AALIQ'
                                 w_lista-aa_liq.
  PERFORM bdc_field       USING 'P_N_LIQ'
                                 w_lista-n_liq.
  PERFORM bdc_dynpro      USING 'ZFM_GESTIONE_LIQUIDAZIONI' '0100'.

  PERFORM bdc_transaction USING 'ZFM_VISUALIZZ_LIQUID'.
*§---> Begin - TKT 2-2164865139 - visualizza Liq da reintegro - 02.09.24 - VR
*  ENDIF.
*§---> End - TKT 2-2164865139 - visualizza Liq da reintegro - 02.09.24 - VR

ENDFORM.

*********************************************************************
##PERF_NO_TYPE
FORM bdc_transaction USING tcode.
  DATA ctumode LIKE ctu_params-dismode VALUE 'E'.

  CALL TRANSACTION tcode USING bdcdata                   "#EC CI_CALLTA
                         MODE  ctumode.

  CLEAR: bdcdata[].
ENDFORM.

*********************************************************************
##PERF_NO_TYPE
FORM bdc_dynpro USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM.

*********************************************************************
##PERF_NO_TYPE
FORM bdc_field USING fnam fval.
  CLEAR bdcdata.
  bdcdata-fnam = fnam.
  bdcdata-fval = fval.
  APPEND bdcdata.
ENDFORM.

*********************************************************************
FORM visualizza_fattura.
  SET PARAMETER ID 'BLN' FIELD w_lista-num_doc_fi.
  SET PARAMETER ID 'BUK' FIELD w_lista-bukrs.
  SET PARAMETER ID 'GJR' FIELD w_lista-aa_doc_fi.
  CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.         "#EC CI_CALLTA
ENDFORM.

*********************************************************************
FORM modify_fieldcat.
*Start MOD BCSOFT 24/03/2025 struttura appoggio per modifica fieldcat
  DATA ls_fieldcat LIKE LINE OF i_fieldcat.
*Start MOD BCSOFT 24/03/2025 struttura appoggio per modifica fieldcat

  FIELD-SYMBOLS: <fcat> LIKE LINE OF i_fieldcat.

  LOOP AT i_fieldcat ASSIGNING <fcat>.
    CASE <fcat>-fieldname.
      WHEN 'FIPEX'.
        <fcat>-seltext_l = <fcat>-seltext_m = <fcat>-seltext_s = 'Capitolo'.
      WHEN 'NUM_DOC_FI'.
*        <fcat>-hotspot = 'X'.
      WHEN 'N_LIQ'.
*        <fcat>-hotspot = 'X'.
      WHEN 'NR_MANDATO'.
*        <fcat>-hotspot = 'X'.
      WHEN 'NOTE_MNDT'.
        <fcat>-outputlen = '15'.
      WHEN 'TESTO_BREVE'.
        <fcat>-outputlen = '15'.
      WHEN 'CAUSALE_LIQ'.
        <fcat>-outputlen = '15'.
      WHEN 'NOTE_PROP'.
        <fcat>-outputlen = '15'.
      WHEN 'ZZNOTE_PROVV'.
        <fcat>-outputlen = '15'.
*Start MOD CA 04/07/2025 modifica label per MEV 121
        CLEAR: <fcat>-seltext_l, <fcat>-seltext_m, <fcat>-seltext_s.
        CLEAR  <fcat>-ref_tabname.
        <fcat>-reptext_ddic = 'Note Provvedimento Liquidazione'.
*End MOD CA 04/07/2025 modifica label per MEV 121
      WHEN 'ZNOTE_PROVV_PROR'.
        <fcat>-outputlen = '15'.
      WHEN 'ZZID_DOC'.
        <fcat>-outputlen = '15'.
      WHEN 'SGTXT'.
        <fcat>-outputlen = '15'.
      WHEN 'CAUS_BEN_ALT'.
        <fcat>-outputlen = '15'.
      WHEN 'IMPEGNO'.
*        <fcat>-hotspot = 'X'.
*>>>AG101116
      WHEN 'CPUDT_MOD'.
        <fcat>-seltext_l = <fcat>-seltext_m =
##NO_TEXT <fcat>-seltext_s = 'Data modifica'.           "#EC CI_CONV_OK
*<<<AG101116

*Start ins GM281223
        ##WHEN_DOUBLE_OK
      WHEN 'NOTE_MNDT'
        OR 'CAUSALE_LIQ'.
        <fcat>-outputlen = '40'.
        ##WHEN_DOUBLE_OK
      WHEN 'NOTA_PROP'
        OR 'ZZNOTE_PROVV'
        OR 'ZZNOTE_PROVV_PROR'
        OR 'ZTIPO_RISORSA_TXT'
        OR 'TITOLO_TXT'
        OR 'MISS_TXT'
        OR 'PROG_TXT'
        OR 'ZZIDRIC_TXT'
        OR 'ZZCODUE_TXT'
        OR 'ZZSF_GSA_TXT'
        OR 'ZZ_AMBITO_GSA_TXT'.
        <fcat>-outputlen = '25'.
*End   ins GM281223

*** G4DK907648 - BEG
      WHEN 'NR_AVVISO_PAGOPA'.
        ##NO_TEXT <fcat>-seltext_l = 'Nr.Avviso PAGOPA'.
        <fcat>-outputlen = '20'.
      WHEN 'CODICE_FISCALE_ENTE'.
        ##NO_TEXT <fcat>-seltext_l = 'Cod.Fisc.Ente'.
        <fcat>-outputlen = '20'.
      WHEN 'MOD_PAG'.
        ##NO_TEXT <fcat>-seltext_m = 'Mod.Pag.'.
        <fcat>-outputlen = '08'.
      WHEN 'MOD_PAG_ALT'.
        ##NO_TEXT <fcat>-seltext_m = 'Mod.Pag.Alt.'.
        <fcat>-outputlen = '12'.
      WHEN 'BVTYP'.
        ##NO_TEXT <fcat>-seltext_m = 'Tp.Banca'.
        <fcat>-outputlen = '08'.
      WHEN 'BVTYP_ALT'.
        ##NO_TEXT <fcat>-seltext_m = 'Tp.Banca Alt.'.
        <fcat>-outputlen = '12'.
      WHEN 'IBAN'.
        ##NO_TEXT <fcat>-seltext_l = 'IBAN Beneficiario'.
        <fcat>-outputlen = '35'.
      WHEN 'IBAN_ALT'.
        ##NO_TEXT <fcat>-seltext_l = 'IBAN Benefic.Alt.'.
        <fcat>-outputlen = '35'.
*Start MOD BCSOFT 31/07/2024
      WHEN 'CAUSALE'.
        <fcat>-seltext_l = <fcat>-seltext_m = 'Causale del mandato'.
        <fcat>-seltext_s = 'Caus'.
        <fcat>-reptext_ddic = 'Causale del mandato'.
      WHEN 'WTGES'.
        CLEAR: <fcat>-seltext_l, <fcat>-seltext_m, <fcat>-seltext_s.
        CLEAR  <fcat>-ref_tabname.
        <fcat>-reptext_ddic = 'Imp. Impegno'.
      WHEN 'ZZANNPR'.
        CLEAR: <fcat>-seltext_l, <fcat>-seltext_m, <fcat>-seltext_s.
        CLEAR  <fcat>-ref_tabname.
        <fcat>-reptext_ddic = 'Anno Atto Impegno'.
      WHEN 'NUM_PROVVED'.
        CLEAR: <fcat>-seltext_l, <fcat>-seltext_m, <fcat>-seltext_s.
        CLEAR  <fcat>-ref_tabname.
        <fcat>-reptext_ddic = 'Numero Atto Impegno'.
      WHEN 'KTEXT'.
        CLEAR: <fcat>-seltext_l, <fcat>-seltext_m, <fcat>-seltext_s.
        CLEAR  <fcat>-ref_tabname.
        <fcat>-reptext_ddic = 'Oggetto dell''impegno'.
      WHEN 'KTEXT_ESTESO'.
        CLEAR: <fcat>-seltext_l, <fcat>-seltext_m, <fcat>-seltext_s.
        CLEAR  <fcat>-ref_tabname.
*Start MOD CA 08/07/2025 modifica label e visibilità per MEV 121
*        <fcat>-reptext_ddic = 'Testo testata impegno'.
        <fcat>-reptext_ddic = 'Descrizione impegno'.
*End MOD CA 08/07/2025 modifica label e visibilità per MEV 121
      WHEN 'DESCRIZIONE'.
        CLEAR: <fcat>-seltext_l, <fcat>-seltext_m, <fcat>-seltext_s.
        CLEAR  <fcat>-ref_tabname.
        <fcat>-reptext_ddic = 'Descrizione PdC'.
*End MOD BCSOFT 31/07/2024
*Start MOD BCSOFT 06/2025 aggiunta gestione data provvedimento
      WHEN 'ZZDATA_PROVV'.
        CLEAR: <fcat>-seltext_l, <fcat>-seltext_m, <fcat>-seltext_s.
        CLEAR  <fcat>-ref_tabname.
        <fcat>-reptext_ddic = 'Data Provvedimento'.
*End MOD BCSOFT 06/2025 aggiunta gestione data provvedimento
    ENDCASE.
*** G4DK907648 - END
  ENDLOOP.

*Start MOD BCSOFT 24/03/2025 aggiunta colonna Asset/Copertura Fondo
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ASSET'.
  ls_fieldcat-seltext_l = 'ASSET Fondo'.
  ls_fieldcat-seltext_m = 'ASSET F.'.
  ls_fieldcat-seltext_s = 'ASSET'.
  ls_fieldcat-outputlen = '10'.
  APPEND ls_fieldcat TO i_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'COPERTURA'.
  ls_fieldcat-seltext_l = 'Fondo - Copertura'.
  ls_fieldcat-seltext_m = 'Fondo - Copertura'.
  ls_fieldcat-seltext_s = 'Fd.Cop.'.
  ls_fieldcat-outputlen = '13'.
  APPEND ls_fieldcat TO i_fieldcat.
  CLEAR ls_fieldcat.
*End MOD BCSOFT 24/03/2025 aggiunta colonne Asset/Copertura Fondo

*Start MOD CA 04/07/2025 aggiunta campi fieldcat per MEV 121
  IF sy-tcode EQ 'ZFM_VISU_MANDATI' AND cb_info IS NOT INITIAL.
    ls_fieldcat-fieldname = 'DESCRIZIONE_MANDATO'.
    ls_fieldcat-seltext_l = 'Descrizione Mandato'.
    ls_fieldcat-seltext_m = 'Descrizione Mandato'.
    ls_fieldcat-col_pos = 100.
    APPEND ls_fieldcat TO i_fieldcat.
    CLEAR ls_fieldcat.

    ls_fieldcat-fieldname = 'DESCRIZIONE_DG_PROP_MANDATO'.
    ls_fieldcat-seltext_l = 'Descrizione DG. Prop. Mandato'.
    ls_fieldcat-seltext_m = 'Descrizione DG. Prop. Mandato'.
    ls_fieldcat-col_pos = 100.
    APPEND ls_fieldcat TO i_fieldcat.
    CLEAR ls_fieldcat.

    ls_fieldcat-fieldname = 'DESCR_CAP_USC'.
    ls_fieldcat-seltext_l = 'Descrizione Capitolo'.
    ls_fieldcat-seltext_m = 'Descrizione Capitolo'.
    ls_fieldcat-col_pos = 100.
    ls_fieldcat-outputlen = 255.
    APPEND ls_fieldcat TO i_fieldcat.
    CLEAR ls_fieldcat.

    ls_fieldcat-fieldname = 'DATA_PROVVED'.
    ls_fieldcat-seltext_l = 'Data Provvedimento Impegno'.
    ls_fieldcat-col_pos = 100.
    APPEND ls_fieldcat TO i_fieldcat.
    CLEAR ls_fieldcat.

    ls_fieldcat-fieldname = 'DESC_PROVV'.
    ls_fieldcat-seltext_l = 'Oggetto Provvedimento Impegno'.
    ls_fieldcat-col_pos = 100.
    ls_fieldcat-outputlen = 255.
    APPEND ls_fieldcat TO i_fieldcat.
    CLEAR ls_fieldcat.

    ls_fieldcat-fieldname = 'DG_PROP_IMP'.
    ls_fieldcat-seltext_l = 'DG. Proposta Impegno'.
    ls_fieldcat-col_pos = 100.
    APPEND ls_fieldcat TO i_fieldcat.
    CLEAR ls_fieldcat.

    ls_fieldcat-fieldname = 'DESCRIZIONE_DG_PROP_IMPEGNO'.
    ls_fieldcat-seltext_l = 'Descrizione DG. Prop. Impegno'.
    ls_fieldcat-seltext_m = 'Descrizione DG. Prop. Impegno'.
    ls_fieldcat-col_pos = 100.
    APPEND ls_fieldcat TO i_fieldcat.
    CLEAR ls_fieldcat.
  ENDIF.
*End MOD CA 04/07/2025 aggiunta campi fieldcat per MEV 121

*Start MOD CA 20/06/2025 aggiunta campi fieldcat per MEV 112
*  IF sy-tcode EQ 'ZVISU_MAND_CDC'.
*    ls_fieldcat-fieldname = 'DESCR_CAP_USC'.
*    ls_fieldcat-seltext_l = 'Descrizione Capitolo di Spesa'.
*    ls_fieldcat-seltext_m = 'Descrizione Capitolo di Spesa'.
*    ls_fieldcat-col_pos = 100.
*    APPEND ls_fieldcat TO i_fieldcat.
*    CLEAR ls_fieldcat.

*    ls_fieldcat-fieldname = 'CAP_ENT'.
*    ls_fieldcat-seltext_l = 'Capitolo Entrata'.
*    ls_fieldcat-seltext_m = 'Capitolo Entrata'.
*    ls_fieldcat-outputlen = '16'.
*    ls_fieldcat-col_pos = 100.
*    APPEND ls_fieldcat TO i_fieldcat.
*    CLEAR ls_fieldcat.

*    ls_fieldcat-fieldname = 'DESCR_CAP_ENT'.
*    ls_fieldcat-seltext_l = 'Descrizione Capitolo di Entrata'.
*    ls_fieldcat-col_pos = 100.
*    APPEND ls_fieldcat TO i_fieldcat.
*    CLEAR ls_fieldcat.
*§---> Start Paganof - 21.01.2026 10:41:56 - Mev 112 Macroaggregato
*    ls_fieldcat-fieldname = 'ZZSF_CATEGORIE'.
*    ls_fieldcat-seltext_l = 'Categoria'.
*    ls_fieldcat-seltext_m = 'Categoria'.
*    ls_fieldcat-seltext_s = 'Categoria'.
*    ls_fieldcat-outputlen = '10'.
*    ls_fieldcat-col_pos = 100.
*    APPEND ls_fieldcat TO i_fieldcat.
*    CLEAR ls_fieldcat.

*    ls_fieldcat-fieldname = 'ZZMACROAGGR'.
*    ls_fieldcat-seltext_l = 'Macroaggregato'.
*    ls_fieldcat-seltext_m = 'Macroaggregato'.
*    ls_fieldcat-seltext_s = 'Macroaggregato'.
*    ls_fieldcat-outputlen = '15'.
*    ls_fieldcat-col_pos = 100.
*    APPEND ls_fieldcat TO i_fieldcat.
*    CLEAR ls_fieldcat.

*§---> End Paganof - 21.01.2026 10:42:06
*    ls_fieldcat-fieldname = 'CIG_CUP'.
*    ls_fieldcat-seltext_l = 'Codice CIG-CUP'.
*    ls_fieldcat-seltext_m = 'Codice CIG-CUP'.
*    ls_fieldcat-outputlen = '52'.
*    ls_fieldcat-col_pos = 100.
*    APPEND ls_fieldcat TO i_fieldcat.
*    CLEAR ls_fieldcat.

*    ls_fieldcat-fieldname = 'PERIMETRO_GSA'.
*    ls_fieldcat-seltext_l = 'Perimetro GSA'.
*    ls_fieldcat-seltext_m = 'Perimetro GSA'.
*    ls_fieldcat-outputlen = '14'.
*    ls_fieldcat-col_pos = 100.
*    APPEND ls_fieldcat TO i_fieldcat.
*    CLEAR ls_fieldcat.

*    ls_fieldcat-fieldname = 'IMP_QUIET_PREC'.
*    CONCATENATE 'Totale Pagato' lv_aa_prec INTO ls_fieldcat-seltext_l SEPARATED BY space.
*    ls_fieldcat-outputlen = '14'.
*    ls_fieldcat-col_pos = 100.
*    APPEND ls_fieldcat TO i_fieldcat.
*    CLEAR ls_fieldcat.


* ENDIF.

*§---> Start Paganof - 11.02.2026 - 2-2190730999
*  IF sy-tcode EQ 'ZFM_VISU_MANDATI' OR sy-tcode EQ 'ZVISU_MAND_CDC'.
*    ls_fieldcat-fieldname = 'ANNULLO_SINGOLO'.
*    ls_fieldcat-seltext_L = 'Annullo Manuale'.
*    ls_fieldcat-seltext_m = 'Annullo Manuale'.
*    ls_fieldcat-seltext_s = 'Annullo Manuale'.
*    ls_fieldcat-outputlen = '5'.
*    ls_fieldcat-col_pos = 100.
*    APPEND ls_fieldcat TO i_fieldcat.
*    CLEAR ls_fieldcat.
*  ENDIF.
*§---> End Paganof - 11.02.2026

*End MOD CA 20/06/2025 aggiunta campi fieldcat per MEV 112
ENDFORM.

*********************************************************************
FORM visualizza_impegno.
  DATA:
    lv_bltyp   TYPE kblk-bltyp,
    lt_bdcdata TYPE TABLE OF bdcdata,
    ls_bdcdata TYPE bdcdata.

  SELECT SINGLE bltyp
         FROM kblk INTO lv_bltyp
         WHERE belnr EQ w_lista-impegno.                  "#EC CI_SUBRC

  ls_bdcdata-program  = 'SAPMZSXIMP'.
  ls_bdcdata-dynpro   = '0100'.
  ls_bdcdata-dynbegin = 'X'.
  APPEND ls_bdcdata TO lt_bdcdata. CLEAR: ls_bdcdata.

  ls_bdcdata-fnam    = 'KBLD-BELNR'.
  ls_bdcdata-fval    = w_lista-impegno.
  APPEND ls_bdcdata TO lt_bdcdata. CLEAR: ls_bdcdata.

  ls_bdcdata-fnam    = 'BDC_OKCODE'.
  ls_bdcdata-fval    = '=VISU'.
  APPEND ls_bdcdata TO lt_bdcdata. CLEAR: ls_bdcdata.

  CASE lv_bltyp.
    WHEN '030'.
      ls_bdcdata-program  = 'SAPMZSXIMP'.
      ls_bdcdata-dynpro   = '0210'.
      ls_bdcdata-dynbegin = 'X'.
      APPEND ls_bdcdata TO lt_bdcdata. CLEAR: ls_bdcdata.
      CALL TRANSACTION 'ZSX01' USING lt_bdcdata MODE 'E'. "#EC CI_CALLTA
    WHEN '040'.
      ls_bdcdata-program  = 'SAPMZSXIMP'.
      ls_bdcdata-dynpro   = '0220'.
      ls_bdcdata-dynbegin = 'X'.
      APPEND ls_bdcdata TO lt_bdcdata. CLEAR: ls_bdcdata.
      CALL TRANSACTION 'ZSXIG' USING lt_bdcdata MODE 'E'. "#EC CI_CALLTA
  ENDCASE.
ENDFORM.

*********************************************************************
FORM visualizza_mandato.
  ##SUB_PAR
  SUBMIT zfm_mandato  WITH rb_crea  EQ ' '               "#EC CI_SUBMIT
                      WITH rb_modi  EQ ''
                      WITH rb_visu  EQ 'X'
                      WITH rb_vari  EQ ''
                      WITH rb_sost  EQ ''
                      WITH rb_stor  EQ ''
                      WITH rb_annu  EQ ''
                      WITH s_aa_mdt EQ w_lista-anno_mandato
                      WITH s_mndt   EQ w_lista-nr_mandato
                      AND RETURN.
ENDFORM.

*Start MOD CA 23/06/2025 form per recupero Matchcode dinamico campo Conto Finanziario MEV 112
FORM f_matchcode_conto .
  DATA: lv_conto_select TYPE z_conto_fin,
        lv_conto_fin    TYPE zrac_piano_conti-z_conto_fin.

  DATA: lr_fipex      TYPE RANGE OF fmci-fipex,
        ls_fipex      LIKE LINE OF lr_fipex,
        lr_conto_fin  TYPE RANGE OF zrac_piano_conti-z_conto_fin,
        ls_conto_fin  LIKE LINE OF lr_conto_fin,
        lt_dynpfields TYPE STANDARD TABLE OF dynpread.

  DATA: BEGIN OF lt_chars OCCURS 0,
          split TYPE c LENGTH 10,
        END OF lt_chars.

  REFRESH: lr_fipex,
           lt_dynpfields.

  IF s_fipex[] IS NOT INITIAL.
    lr_fipex = s_fipex[].
  ELSE.
    lt_dynpfields = VALUE #( ( fieldname = 'S_FIPEX-LOW' )
                             ( fieldname = 'S_FIPEX-HIGH' ) ).

    CALL FUNCTION 'DYNP_VALUES_READ'
      EXPORTING
        dyname     = sy-repid
        dynumb     = sy-dynnr
      TABLES
        dynpfields = lt_dynpfields.

    CLEAR ls_fipex.
    ls_fipex-sign   = 'I'.
    ls_fipex-option = 'EQ'.
    ls_fipex-low  = VALUE #( lt_dynpfields[ fieldname = 'S_FIPEX-LOW' ]-fieldvalue OPTIONAL ).
    ls_fipex-high = VALUE #( lt_dynpfields[ fieldname = 'S_FIPEX-HIGH' ]-fieldvalue OPTIONAL ).

    IF ls_fipex-high IS NOT INITIAL.
      ls_fipex-option = 'BT'.
    ENDIF.

    IF ls_fipex-low IS NOT INITIAL.
      APPEND ls_fipex TO lr_fipex.
      CLEAR ls_fipex.
    ENDIF.
  ENDIF.

  SELECT DISTINCT fikrs,
                  gjahr,
                  fipex,
                  zz_conto_fin
  FROM fmci
  INTO TABLE @DATA(lt_conto_fin)
  WHERE fikrs EQ '1000'
  AND gjahr   EQ @sy-datum(4)
  AND fipex   IN @lr_fipex.

  LOOP AT lt_conto_fin ASSIGNING FIELD-SYMBOL(<fs_conto_fin>).
    SPLIT <fs_conto_fin>-zz_conto_fin AT '.' INTO TABLE lt_chars.

    LOOP AT lt_chars.                              "#EC CI_LOOP_INTO_HL
      IF sy-tabix NE 1.
        CONCATENATE lv_conto_select '.' INTO lv_conto_select.
      ENDIF.

      IF lt_chars CO '0 '.                              "#EC CI_CONV_OK
        DO.                                              "#EC CI_NESTED
          CONCATENATE lv_conto_select '_' INTO lv_conto_select.
          SHIFT lt_chars BY 1 PLACES.                   "#EC CI_CONV_OK
          IF lt_chars(1) IS INITIAL.
            EXIT.
          ENDIF.
        ENDDO.
      ELSE.
        CONCATENATE lv_conto_select lt_chars INTO lv_conto_select. "#EC CI_CONV_OK
      ENDIF.

      CONDENSE lv_conto_select.
    ENDLOOP.

    CONCATENATE lv_conto_select(13) '*' INTO lv_conto_fin.
    ls_conto_fin-low = lv_conto_fin.
    ls_conto_fin-option = 'CP'.
    ls_conto_fin-sign   = 'I'.
    APPEND ls_conto_fin TO lr_conto_fin.
    CLEAR ls_conto_fin.

    CLEAR lv_conto_select.
  ENDLOOP.

  SELECT zzsfdatanno,
         z_conto_fin,
         z_voce_conto
  FROM zrac_piano_conti
  INTO CORRESPONDING FIELDS OF TABLE @gt_f4_values
  WHERE zzsfdatanno     LE @sy-datum(4)
    AND anno_fine       GE @sy-datum(4)
    AND z_conto_fin     IN @lr_conto_fin
    AND zfm_macro       EQ 'U'
    AND z_livelli_piano EQ 5.

  SORT gt_f4_values BY zzsfdatanno z_conto_fin z_voce_conto.
  DELETE ADJACENT DUPLICATES FROM gt_f4_values COMPARING zzsfdatanno z_conto_fin z_voce_conto.
ENDFORM.
*End MOD CA 23/06/2025 form per recupero Matchcode dinamico campo Conto Finanziario MEV 112

*§---> Start Paganof - 29.01.2026 15:27:00 - MEV 112 accorpare dati
FORM: f_accorpare_dati.

  DATA: ls_lista_deff_app TYPE ty_def,
*        lt_lista_acc      TYPE STANDARD TABLE OF ty_def,
        lt_lista_deff_app TYPE STANDARD TABLE OF ty_def.

  SORT i_lista_def BY nr_mandato.
  LOOP AT i_lista_def ASSIGNING FIELD-SYMBOL(<fs_lista_def>).

    READ TABLE lt_lista_deff_app ASSIGNING FIELD-SYMBOL(<fs_lista_deff_app>) WITH KEY  nr_mandato     = <fs_lista_def>-nr_mandato
                                                                                       zz_titolo      = <fs_lista_def>-zz_titolo
                                                                                       zzmacroaggr    = <fs_lista_def>-zzmacroaggr
                                                                                       impegno        = <fs_lista_def>-impegno
                                                                                       fipex          = <fs_lista_def>-fipex
                                                                                       zzsf_gsa       = <fs_lista_def>-zzsf_gsa
                                                                                       z_conto_fin    = <fs_lista_def>-z_conto_fin
                                                                                       num_ben        = <fs_lista_def>-num_ben
                                                                                       cig_cup        = <fs_lista_def>-cig_cup
                                                                                       dir_prop       = <fs_lista_def>-dir_prop
                                                                                       zzsf_missioni  = <fs_lista_def>-zzsf_missioni
                                                                                       zzsf_programmi = <fs_lista_def>-zzsf_programmi.




    IF sy-subrc EQ 0.

      <fs_lista_deff_app>-imp_liq           = <fs_lista_deff_app>-imp_liq           + <fs_lista_def>-imp_liq.
      <fs_lista_deff_app>-imp_net           = <fs_lista_deff_app>-imp_net           + <fs_lista_def>-imp_net.
      <fs_lista_deff_app>-imp_quiet         = <fs_lista_deff_app>-imp_quiet         + <fs_lista_def>-imp_quiet.
*-- LM023036 - Importo totale pagato è uguale su tutte le righe
*      <fs_lista_deff_app>-imp_quiet_prec    = <fs_lista_deff_app>-imp_quiet_prec         + <fs_lista_def>-imp_quiet_prec.
      <fs_lista_deff_app>-imp_rit           = <fs_lista_deff_app>-imp_rit           + <fs_lista_def>-imp_rit.
      <fs_lista_deff_app>-importo_r         = <fs_lista_deff_app>-importo_r         + <fs_lista_def>-importo_r.
      <fs_lista_deff_app>-tot_pag_cap       = <fs_lista_deff_app>-tot_pag_cap       + <fs_lista_def>-tot_pag_cap.
      <fs_lista_deff_app>-disp_cas_cap      = <fs_lista_deff_app>-disp_cas_cap      + <fs_lista_def>-disp_cas_cap.
      <fs_lista_deff_app>-pareggio_parziale = <fs_lista_deff_app>-pareggio_parziale + <fs_lista_def>-pareggio_parziale.
      <fs_lista_deff_app>-wtges             = <fs_lista_deff_app>-wtges             + <fs_lista_def>-wtges.


    ELSE.
      MOVE-CORRESPONDING <fs_lista_def> TO ls_lista_deff_app.
      APPEND ls_lista_deff_app TO lt_lista_deff_app.
      CLEAR ls_lista_deff_app.
    ENDIF.
  ENDLOOP.

  IF lt_lista_deff_app IS NOT INITIAL.
    i_lista_def = lt_lista_deff_app.
  ENDIF.

ENDFORM.
*§---> End Paganof - 29.01.2026 15:27:08