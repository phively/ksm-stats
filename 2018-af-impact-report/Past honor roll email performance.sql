With

emails As (
-- Previous honor roll emails
Select *
from nu_bio_t_emmx_msgs
where email_from_name = 'Kellogg Annual Giving'
  and email_subject like '%Honor Roll%'
)

-- 6291 receipts
/*
Select mr.*
From nu_bio_t_emmx_msgs_rcpts mr
Inner Join emails On emails.msg_id = mr.msg_fk
*/

-- 20 bounces
/*
Select mb.*
From nu_bio_t_emmx_msgs_bounces mb
Inner Join emails On emails.msg_id = mb.msg_fk
*/

-- 6277 delivers
/*
Select md.*
From nu_bio_t_emmx_msgs_delivers md
Inner Join emails On emails.msg_id = md.msg_fk
*/

-- 2273 opened
/*
Select mo.*
From nu_bio_t_emmx_msgs_opens mo
Inner Join emails On emails.msg_id = mo.msg_fk
*/

-- 132 clicked
/*
Select mc.*
From nu_bio_t_emmx_msgs_clicks mc
Inner Join emails On emails.msg_id = mc.msg_fk
*/
