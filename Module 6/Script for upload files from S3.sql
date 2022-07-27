1 

copy orders_nocomp from 's3://b1gd1t1/redshiftdata/orders.manifest' iam_role 'arn:aws:iam::783779274876:role/RedShiftFullAccessS3-DE101' delimiter '|' manifest compupdate off;
copy lineitem_nocomp from 's3://b1gd1t1/redshiftdata/lineitem.manifest' iam_role 'arn:aws:iam::783779274876:role/RedShiftFullAccessS3-DE101' delimiter '|' manifest compupdate off;

2
copy orders_comp from 's3://b1gd1t1/redshiftdata/orders.manifest' iam_role 'arn:aws:iam::783779274876:role/RedShiftFullAccessS3-DE101' delimiter '|' manifest;
copy lineitem_comp from 's3://b1gd1t1/redshiftdata/lineitem.manifest' iam_role 'arn:aws:iam::783779274876:role/RedShiftFullAccessS3-DE101' delimiter '|' manifest;

3

copy orders from 's3://b1gd1t1/redshiftdata/orders.manifest' iam_role 'arn:aws:iam::783779274876:role/RedShiftFullAccessS3-DE101' delimiter '|' manifest;
copy lineitem from 's3://b1gd1t1/redshiftdata/lineitem.manifest' iam_role 'arn:aws:iam::783779274876:role/RedShiftFullAccessS3-DE101' delimiter '|' manifest;