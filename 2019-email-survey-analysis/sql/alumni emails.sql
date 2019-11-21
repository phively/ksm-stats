-- KSM alumni email addresses
Select
  email.id_number
  , email_address
From email
Inner Join v_entity_ksm_degrees deg
  On deg.id_number = email.id_number
