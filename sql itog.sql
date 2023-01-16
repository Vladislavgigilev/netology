create schema dwh_2;

create table dim_calendar(
id serial4 not null,
"date" date not null,
CONSTRAINT dim_calendar_pkey PRIMARY KEY (id)
);
 insert into dim_calendar ("date")
select gs::date from generate_series('01-01-2000', '01-01-2023', interval '1 day') as gs

alter table dim_calendar add constraint date_unique unique("date")

create table dim_passengers(
passanger_id varchar(20) not null,
passenger_name text not null,
contact_data json,
CONSTRAINT dim_passengers_pkey PRIMARY KEY (passanger_id)
);
insert into dim_passengers 
select passenger_id, passenger_name, contact_data from bookings.tickets t 

create table dim_aircrafts(
	aircraft_code varchar(5) NOT NULL,
	model varchar(25) NOT NULL,
	"range" int4 NOT NULL,
	CONSTRAINT dim_aircrafts_model_key UNIQUE (model),
	constraint dim_aircrafts_pkey PRIMARY KEY (aircraft_code),
	constraint dim_aircrafts_range_check CHECK ((range > 0))
); 
insert into dim_aircrafts

select aircraft_code, model::json->'ru', "range"  from bookings.aircrafts_data ad

select * from dim_aircrafts da  

create table dim_airports(
	airport_code varchar(5) NOT NULL,
	airport_name varchar(100) NOT NULL,
	city varchar(100) NOT NULL,
	timezone varchar(100) NOT NULL,
	CONSTRAINT dim_airports_airport_name UNIQUE (airport_name),
	CONSTRAINT dim_airports_pkey PRIMARY KEY (airport_code)
);
insert into dim_airports 
select airport_code, airport_name::json->'ru', city::json->'ru', timezone  from bookings.airports_data ad 

CREATE TABLE dim_tariff (
	id serial4 NOT NULL,
	fare_conditions varchar(50) NOT NULL,
	CONSTRAINT dim_tariff_fare_conditions_key UNIQUE (fare_conditions),
	CONSTRAINT dim_tariff_pkey PRIMARY KEY (id)
);
insert into dim_tariff(fare_conditions) 
select distinct fare_conditions  from bookings.seats s 


Dim_Calendar - справочник дат
Dim_Passengers - справочник пассажиров
Dim_Aircrafts - справочник самолетов
Dim_Airports - справочник аэропортов
Dim_Tariff - справочник тарифов (Эконом/бизнес и тд)

drop table fact_flights 

create table fact_flights (
	passenger varchar(20) NOT NULL,
	date_dep timestamp NULL,
	date_arr timestamp NULL,
	diff_dep varchar(20) NULL,
	diff_arr varchar(20) NULL,
	model varchar(100) NOT NULL,
	airport_dep varchar(50) NOT NULL,
	airport_arr varchar(50) NOT NULL,
	fare_condition varchar(20) NOT NULL,
	amount numeric(10, 2) NOT null
	CONSTRAINT fact_flights_check CHECK ((date_arr > date_dep)),
	CONSTRAINT fact_flights_check1 CHECK (((airport_arr)::text <> (airport_dep)::text)),
	CONSTRAINT fact_flights_date_dep_check CHECK ((date_dep <= CURRENT_DATE)),
	CONSTRAINT fact_flights_airport_arr_fkey FOREIGN KEY (airport_arr) REFERENCES dwh_2.dim_airports(airport_name),
	CONSTRAINT fact_flights_airport_dep_fkey FOREIGN KEY (airport_dep) REFERENCES dwh_2.dim_airports(airport_name),
	CONSTRAINT fact_flights_fare_condition_fkey FOREIGN KEY (fare_condition) REFERENCES dwh_2.dim_tariff(fare_conditions),
	CONSTRAINT fact_flights_model_fkey FOREIGN KEY (model) REFERENCES dwh_2.dim_aircrafts(model),
	constraint fact_fights_pass FOREIGN KEY (passenger) references dwh_2.dim_passengers(passanger_id)
);