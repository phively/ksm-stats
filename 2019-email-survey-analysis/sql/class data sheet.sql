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
    , program_group
  From survey
  Union
  Select
    id_number
    , report_name
    , record_status_code
    , first_ksm_year
    , first_masters_year
    , program
    , program_group
  From grads
)

-- Main query
Select
  ids.*
  , Case When survey.id_number Is Not Null Then 'survey' End
    As survey
  , Case When grads.id_number Is Not Null Then 'grads' End
    As grads
  , de.primary_job_title
  , de.primary_employer
  , de.primary_job_source
  , de.fld_of_work_desc
  , de.business_city
  , de.business_state
  , de.business_country_desc
  , de.business_date_modified
  , de.employment_date_modified
From ids
Left Join survey
  On survey.id_number = ids.id_number
Left Join grads
  On grads.id_number = ids.id_number
Left Join v_datamart_entities de
  On de.catracks_id = ids.id_number
