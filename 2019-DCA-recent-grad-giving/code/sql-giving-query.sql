With

-- FT degreed alumni
deg As (
  Select
    id_number
    , report_name
    , degrees_concat
    , first_ksm_year
    , first_masters_year
    , program
  From v_entity_ksm_degrees
  Where
    -- Full-time only: 2Y, 1Y, MMM, JDMBA, Unknown
    program In ('FT-2Y', 'FT-1Y', 'FT-MMM', 'FT-JDMBA', 'FT')
)

-- Pull all full-time gifts
, giftdata As (
  Select
    gt.id_number
    , deg.first_masters_year
    , deg.program
    , gt.tx_gypm_ind
    , gt.transaction_type
    , gt.tx_number
    , gt.tx_sequence
    , gt.allocation_code
    , gt.alloc_short_name
    , gt.af_flag
    , gt.cru_flag
    , gt.recognition_credit
    , gt.date_of_record
    , gt.fiscal_year
  From v_ksm_giving_trans gt
  Inner Join deg
    On deg.id_number = gt.id_number
  Where
    -- Nonzero recognition
    gt.recognition_credit > 0
    -- Exclude matching gifts
    And gt.tx_gypm_ind <> 'M'
)

-- Aggregated data
, aggdat As (
  Select
    id_number
    , cal.curr_fy
    -- Recent giving
    , sum(Case When fiscal_year = cal.curr_fy Then recognition_credit Else 0 End) As giving_cfy
    , sum(Case When fiscal_year = cal.curr_fy - 1 Then recognition_credit Else 0 End) As giving_pfy1
    , sum(Case When fiscal_year = cal.curr_fy - 2 Then recognition_credit Else 0 End) As giving_pfy2
    , sum(Case When fiscal_year = cal.curr_fy - 3 Then recognition_credit Else 0 End) As giving_pfy3
    , sum(Case When fiscal_year = cal.curr_fy - 4 Then recognition_credit Else 0 End) As giving_pfy4
    , sum(Case When fiscal_year = cal.curr_fy - 5 Then recognition_credit Else 0 End) As giving_pfy5
    , sum(Case When fiscal_year = cal.curr_fy - 6 Then recognition_credit Else 0 End) As giving_pfy6
    -- Young alum giving
    , sum(Case When fiscal_year = first_masters_year Then recognition_credit Else 0 End) As giving_gradyr0
    , sum(Case When fiscal_year = first_masters_year + 1 Then recognition_credit Else 0 End) As giving_gradyr1
    , sum(Case When fiscal_year = first_masters_year + 2 Then recognition_credit Else 0 End) As giving_gradyr2
    , sum(Case When fiscal_year = first_masters_year + 3 Then recognition_credit Else 0 End) As giving_gradyr3
    , sum(Case When fiscal_year = first_masters_year + 4 Then recognition_credit Else 0 End) As giving_gradyr4
    , sum(Case When fiscal_year = first_masters_year + 5 Then recognition_credit Else 0 End) As giving_gradyr5
    -- First gift year
    , min(fiscal_year) keep(dense_rank First Order By fiscal_year Asc) As first_gift_year
  From giftdata
  Cross Join v_current_calendar cal
  Group By
    id_number
    , cal.curr_fy
)

-- Final query
Select
  deg.id_number
  , deg.report_name
  , deg.degrees_concat
  , deg.first_ksm_year
  , deg.first_masters_year
  , deg.program
  , aggdat.curr_fy
  , aggdat.giving_pfy1
  , aggdat.giving_pfy2
  , aggdat.giving_pfy3
  , aggdat.giving_pfy4
  , aggdat.giving_pfy5
  , aggdat.giving_pfy6
  , aggdat.giving_gradyr0
  , aggdat.giving_gradyr1
  , aggdat.giving_gradyr2
  , aggdat.giving_gradyr3
  , aggdat.giving_gradyr4
  , aggdat.giving_gradyr5
  , aggdat.first_gift_year
From deg
Left Join aggdat
  On aggdat.id_number = deg.id_number
