With

-- Survey email recipients
survey As (
  Select
    deg.*
  From v_entity_ksm_degrees deg
  Inner Join tbl_survey_fy19_sent sent
    On deg.id_number = sent.id_number
)

-- Graduates
, grads As (
  Select
    deg.*
  From v_entity_ksm_degrees deg
  Where
    -- FT13, 16, 18
    (deg.program = 'FT-2Y' And deg.first_masters_year = 2013)
    Or (deg.program = 'FT-2Y' And deg.first_masters_year = 2016)
    Or (deg.program = 'FT-2Y' And deg.first_masters_year = 2018)
    -- EMBA 16
    Or (deg.program In ('EMP-FL', 'EMP-IL', 'EMP-JAN') And deg.first_masters_year = 2016)
)

-- Combined IDs
, ids As (
  Select
    id_number
    , report_name
    , record_status_code
    , first_ksm_year
    , first_masters_year
    , program
  From survey
  Union
  Select
    id_number
    , report_name
    , record_status_code
    , first_ksm_year
    , first_masters_year
    , program
  From grads
)

-- Main query
Select
  ids.*
  , Case When survey.id_number Is Not Null Then 'survey' End
    As survey
  , Case When grads.id_number Is Not Null Then 'grads' End
    As grads
From ids
Left Join survey
  On survey.id_number = ids.id_number
Left Join grads
  On grads.id_number = ids.id_number
