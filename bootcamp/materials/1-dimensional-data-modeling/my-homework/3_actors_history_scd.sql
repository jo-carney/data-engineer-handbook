create table actors_history_scd
(
    actor text,
    quality_class quality_class,
    is_active boolean,
    start_date INTEGER,
    end_date INTEGER,
    current_year INTEGER,
    PRIMARY KEY(actor, start_date)
);