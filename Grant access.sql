GRANT SELECT ON RUAPRF.TD_METRICS_DAYLY  to srv_p_tableau_gdwh;


delete from TD_METRICS_DAYLY where effective_date = '12.05.22'