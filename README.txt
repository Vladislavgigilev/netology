aircraft.ktr - загрузка данных в две таблицы измерения dim_aircrafts, dim_airports
fact_flight.ktr - взяты таблицы flights, aircrafts_data, ticket_flights, tickets, airports_data, отфильтрованы по отстутствующим значениям,
распакованы json строки городов и аэропортов, обьеденены через stream lookup и залиты через bulk loader 
sql и sql itog.sql содержат одно и то же 