With

-- Gift clubs
gc_dat As (
  Select
    gc.gift_club_id_number As id_number
    , 'Gift Club' As type
    , gct.club_description As description
    , Case
        When gc.gift_club_code = 'LKM'
          Then 'Y' -- Kellogg Leadership Circle
        When gc.gift_club_code In ('028', 'AHR')
          Then NULL -- Rogers Society
        When gc.gift_club_code In ('NUL', 'INF')
          Then NULL -- NU Loyal, Infinity
        Else NULL -- Other leadership, e.g. NULC, Law, Feinberg, SESP, etc.
      End
      As ksm_flag
    , ksm_pkg.to_date2(gc.gift_club_start_date) As start_dt
    , ksm_pkg.to_date2(gc.gift_club_end_date) As stop_dt
    , gc.date_added
    , gc.date_modified
  From gift_clubs gc
  Inner Join gift_club_table gct
    On gct.club_code = gc.gift_club_code
  Where gct.club_status = 'A' -- Only currently active gift clubs
)

-- Activities data
, activities As (
  Select
    id_number
    , 'Activity' As type
    , activity_desc As description
    , ksm_activity As ksm_flag
    , start_dt
    , stop_dt
    , date_added
    , date_modified
  From v_nu_activities
)

-- Committee data
, cmtee As (
  Select
    id_number
    , 'Committee' As type
    , committee_desc As description
    , ksm_committee As ksm_flag
    , start_dt_calc
    , stop_dt_calc
    , date_added
    , date_modified
  From v_nu_committees
)

-- All event IDs
, event_ids As (
  Select
    id_number
    , 'Event' As type
    , event_name As description
    , ksm_event As ksm_flag
    , start_dt
    , stop_dt
    , NULL As date_added
    , NULL As date_modified
  From v_nu_event_participants
)

-- Unified engagement
, engage As (
  Select * From activities
  Union All
  Select * From cmtee
  Union All
  Select * From event_ids
  Union All
  Select * From gc_dat
)

Select
  ids.emplid
  , deg.degree_year
  , deg.dept_code
  , deg.dept_desc
  , engage.type
  , engage.description
  , engage.ksm_flag
  , engage.start_dt
  , engage.stop_dt
  , engage.date_added
  , engage.date_modified
From v_datamart_degrees deg
Inner Join v_datamart_ids ids
  On ids.catracks_id = deg.catracks_id
Inner Join engage
  On engage.id_number = deg.catracks_id
Where degree_year In ('2012', '2013', '2014', '2019')
  And deg.dept_code = '01KGS2Y' -- 2Y MBA
Order By
  deg.degree_year Asc
  , ids.emplid Asc
