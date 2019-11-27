-- KSM alumni email addresses
Select
  email.id_number
  , email.email_address
  , email.email_status_code
  , tms_es.short_desc
  , email.status_change_date
  , email.date_modified
  , email.preferred_ind
From email
Inner Join v_entity_ksm_degrees deg
  On deg.id_number = email.id_number
Left Join tms_email_status tms_es
  On tms_es.email_status_code = email.email_status_code
