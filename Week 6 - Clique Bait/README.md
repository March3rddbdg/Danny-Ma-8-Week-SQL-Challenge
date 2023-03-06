![image](https://user-images.githubusercontent.com/109480769/223216016-32907b23-0c97-4bdb-b95d-7d90e436a5be.png)

Information from: https://8weeksqlchallenge.com/case-study-6/


# Introduction:

Clique Bait is not like your regular online seafood store - the founder and CEO Danny, was also a part of a digital data analytics team and wanted to expand his knowledge into the seafood industry!

In this case study - you are required to support Danny’s vision and analyse his dataset and come up with creative solutions to calculate funnel fallout rates for the Clique Bait online store.


# Table 1 - users

Customers who visit the Clique Bait website are tagged via their cookie_id.


# Table 2 - events

Customer visits are logged in this events table at a cookie_id level and the event_type and page_id values can be used to join onto relevant satellite tables to obtain further information about each event.

The sequence_number is used to order the events within each visit.


# Table 3 - event_id

The event_identifier table shows the types of events which are captured by Clique Bait’s digital data systems.


# Table 4 - campaign_id

This table shows information for the 3 campaigns that Clique Bait has ran on their website so far in 2020.


# Table 5 - page_hierarchy

This table lists all of the pages on the Clique Bait website which are tagged and have data passing through from user interaction events.

