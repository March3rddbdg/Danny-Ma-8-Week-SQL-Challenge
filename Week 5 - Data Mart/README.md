![image](https://user-images.githubusercontent.com/109480769/223164134-75f533b8-aa64-4b4c-9e53-d99628e28c6f.png)

Information from: https://8weeksqlchallenge.com/case-study-5/


# Introduction

Data Mart is Danny’s latest venture and after running international operations for his online supermarket that specialises in fresh produce - Danny is asking for your support to analyse his sales performance.

In June 2020 - large scale supply changes were made at Data Mart. All Data Mart products now use sustainable packaging methods in every single step from the farm all the way to the customer.

Danny needs your help to quantify the impact of this change on the sales performance for Data Mart and it’s separate business areas.

The key business question he wants you to help him answer are the following:

What was the quantifiable impact of the changes introduced in June 2020?

Which platform, region, segment and customer types were the most impacted by this change?

What can we do about future introduction of similar sustainability updates to the business to minimise impact on sales?


# Table 1 - Weekly Sales

For this case study there is only a single table: data_mart.weekly_sales


# Column Dictionary

The columns are pretty self-explanatory based on the column names but here are some further details about the dataset:

Data Mart has international operations using a multi-region strategy

Data Mart has both, a retail and online platform in the form of a Shopify store front to serve their customers

Customer segment and customer_type data relates to personal age and demographics information that is shared with Data Mart

transactions is the count of unique purchases made through Data Mart and sales is the actual dollar amount of purchases

Each record in the dataset is related to a specific aggregated slice of the underlying sales data rolled up into a week_date value which represents the start of the sales week.

