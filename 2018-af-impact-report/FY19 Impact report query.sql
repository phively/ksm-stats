With

emails As (
  Select *
  From nu_bio_t_emmx_msgs
  Where email_msg_name Like 'Impact Report%'
    And email_msg_name Not Like '%Test%Kari%'
)

-- Message links
, links As (
  Select
    ml.im_msg_links_id
    , ml.msg_fk
    , Case When lower(ml.email_link_url) Like '%impact%report%' Then 'Y' End
      As impact_report_click
    , Case When lower(ml.email_link_name) Like '%unsubscribe%' Then 'Y' End
      As unsubscribe_click
  From nu_bio_t_emmx_msgs_links ml
  Inner Join emails
    On emails.msg_id = ml.msg_fk
)

-- Recipients
, recipients As (
  Select Distinct
    rcpt.msg_fk
    , rcpt.im_msg_rcpt_id
    , rcpt.constituent_id
  From nu_bio_t_emmx_msgs_rcpts rcpt
  Inner Join emails On emails.msg_id = rcpt.msg_fk
)

-- Delivers
, delivers As (
  Select
    md.im_msg_recipient_id
    , md.msg_fk
    , md.im_date_timestamp As date_delivered
  From nu_bio_t_emmx_msgs_delivers md
  Inner Join emails
    On emails.msg_id = md.msg_fk
)

-- Opens
, opens As (
  Select
    mo.im_msg_recipient_id
    , mo.msg_fk
    , count(mo.im_date_timestamp)
      As opens
    , max(im_date_timestamp) keep(dense_rank First Order By im_date_timestamp Asc)
      As date_opened
    , max(msg_open_user_agent) keep(dense_rank First Order By im_date_timestamp Asc)
      As open_user_agent
  From nu_bio_t_emmx_msgs_opens mo
  Inner Join emails
    On emails.msg_id = mo.msg_fk
  Group By mo.im_msg_recipient_id
    , mo.msg_fk
)

-- Clickthroughs
, clicks As (
  Select
    mc.im_msg_recipient_id
    , mc.msg_fk
    , count(im_date_timestamp)
      As total_clicks
    -- Look at first click and user agent
    , max(im_date_timestamp) keep(dense_rank First Order By im_date_timestamp Asc)
      As date_clicked
    , max(msg_click_user_agent) keep(dense_rank First Order By im_date_timestamp Asc)
      As click_user_agent
    , count(impact_report_click)
      As impact_report_clicks
    , count(unsubscribe_click)
      As unsubscribe_clicks
  From nu_bio_t_emmx_msgs_clicks mc
  Inner Join emails
    On emails.msg_id = mc.msg_fk
  Inner Join links
    On links.im_msg_links_id = mc.msg_click_link_id
    And links.msg_fk = mc.msg_fk
  Group By mc.im_msg_recipient_id
    , mc.msg_fk
)

Select
  emails.msg_id
  , emails.email_msg_name
  , emails.email_subject
  , recipients.im_msg_rcpt_id
  , deg.id_number
  , deg.report_name
  , deg.degrees_concat
  , deg.first_ksm_year
  , deg.program_group
  , giving.af_cfy
  , giving.af_pfy1
  , giving.af_pfy2
  , giving.af_status
  , giving.af_status_fy_start
  , giving.af_giving_segment
  , giving.klc_current
  , giving.klc_lybunt
  , delivers.date_delivered
  , opens.opens
  , opens.date_opened
  , opens.open_user_agent
  , clicks.total_clicks
  , clicks.date_clicked
  , clicks.click_user_agent
  , clicks.impact_report_clicks
  , clicks.unsubscribe_clicks
From recipients
Inner Join emails
  On emails.msg_id = recipients.msg_fk
Inner Join v_entity_ksm_degrees deg
  On deg.id_number = recipients.constituent_id
Left Join v_ksm_giving_summary giving
  On giving.id_number = deg.id_number
Left Join delivers
  On delivers.im_msg_recipient_id = recipients.im_msg_rcpt_id
  And delivers.msg_fk = emails.msg_id
Left Join opens
  On opens.im_msg_recipient_id = recipients.im_msg_rcpt_id
  And opens.msg_fk = emails.msg_id
Left Join clicks
  On clicks.im_msg_recipient_id = recipients.im_msg_rcpt_id
  And clicks.msg_fk = emails.msg_id
  
