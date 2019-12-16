-- zad1

select nr_rejestr, marka, modell, wlasciciel,data_prod, nazwisko, imie
from pojazdy join kierowcy on (wlasciciel=id_kierowcy)
where Extract(year from data_prod)= 2018;

--zad 2
 
select nr_rejestr, marka, modell, wlasciciel,data_prod, 
nazwisko, imie, data_urodzenia, round(data_urodzenia-data_prod) as "dni",
round(months_between(data_urodzenia, data_prod)/12) as "lat" 
from pojazdy  join kierowcy on (wlasciciel=id_kierowcy) 
where data_prod < data_urodzenia order by 9 desc;

-- zad 3 

select nr_akt, nazwisko, pr.stanowisko, placa, placa_min, placa_max from 
pracownicy pr join stanowiska on((placa_max<placa)or(placa<placa_min));

--zad 4 

select trunc(czas) as dzien_polowu,nazwisko,imie,g.nazwa as "Gatunek",
l.nazwa as "Lowisko",waga,dlugosc 
from rejestry r 
join wedkarze w on(r.id_wedkarza = w.id_wedkarza)
join gatunki g on(r.id_gatunku = g.id_gatunku)
join lowiska l on(r.id_lowiska = l.id_lowiska) and waga is not null
order by 1;


--zad 5 

select trunc(czas) as dzien_polowu,nazwisko,imie,
decode (g.nazwa, null, 'brak polowu', g.nazwa) as "Gatunek",
l.nazwa as "Lowisko",waga,dlugosc 
from rejestry r 
join wedkarze w on(r.id_wedkarza = w.id_wedkarza)
left join gatunki g on(r.id_gatunku = g.id_gatunku)
join lowiska l on(r.id_lowiska = l.id_lowiska)
where extract(year from r.czas)like 2018
order by 1;


--zad 6 

select we.id_wedkarza, nazwisko, imie, id_licencji, id_okregu
from wedkarze we join licencje li on(we.id_wedkarza = li.id_wedkarza)
where rodzaj like 'podstawowa' and rok like '2019' and 
id_okregu like 'PZW%';


--zad7  

select li.id_wedkarza, nazwisko, id_okregu,id_licencji ,
od_dnia||'-'||rok as poczatek, do_dnia||'-'||rok as koniec from licencje li
join wedkarze we on(li.id_wedkarza = we.id_wedkarza) where 
to_date(do_dnia, 'DD-MM')-to_date(od_dnia, 'DD-MM') < 364;


--zad8 

select trunc(czas) as dzien_polowu,nazwisko,imie,
decode (g.nazwa, null, 'brak polowu', g.nazwa) as "Gatunek",
l.nazwa as "Lowisko",waga,dlugosc 
from rejestry r 
join wedkarze w on(r.id_wedkarza = w.id_wedkarza)
left join gatunki g on(r.id_gatunku = g.id_gatunku)
join lowiska l on(r.id_lowiska = l.id_lowiska)
where extract(year from r.czas)like 2018
order by 1;


--zad 9 

select P1.id_dzialu , P1.nr_akt, P1.nazwisko, P1.placa, P2.id_dzialu ,
P2.nr_akt, P2.nazwisko, P2.placa
from pracownicy P1
cross JOIN PRACOWNICY P2 
where P1.id_dzialu like '20' AND P2.id_dzialu like '30';


--zad10 

select p1.nr_akt, p1.nazwisko,p1.imiona,decode (p1.przelozony, null, 'brak', p1.przelozony) 
as "Przelozony", 
decode (p1.przelozony, null, ' ', p2.imiona||' '||p2.nazwisko)as "Szef"
from pracownicy p1
left join  pracownicy p2 on (p2.nr_akt = p1.przelozony);


--zad11

select rok, count(*)as "liczba studentow" from studenci where kierunek like 'INFORMATYKA'
group by rok order by rok;


--zad12

select tryb, kierunek, count(*) as"Liczba studentow" from studenci
group by tryb, kierunek
having count(*)>=100;


--zad13

select rok, stopien, gr_dziekan, count(nr_indeksu) as "Liczba_studentek" , avg(srednia) 
from studenci where
imiona like '%a' and kierunek like 'MATEMATYKA'
group by rok, stopien, gr_dziekan;


--zad14

select kierunek, rok, min(data_urodzenia) as najstarszy, max(data_urodzenia)
as najmlodszy,ceil(months_between(max(data_urodzenia),min(data_urodzenia))) 
as "liczba miesiecy" 
from studenci
where stopien like '1' and tryb like 'STACJONARNY'
group by kierunek,rok, tryb
having months_between(max(data_urodzenia),min(data_urodzenia)) >100
order by 5 desc;


--zad15 

select extract(year from czas) as "rok", to_char (czas,'day') as "dzien_tygodnia",
count(*) as "liczba polowow", count (id_gatunku) as "liczba udanych"
from rejestry 
where mod(extract(day from czas),2)=0
group by extract(year from czas), to_char(czas,'day') 
order by 3 desc,4 desc;


--zad 16 

select po.wlasciciel , kr.nazwisko, kr.imie, count(po.nr_rejestr) as "liczba pojazdow", 
count(distinct po.marka) as "liczba marek"
from pojazdy po join kierowcy kr on(po.wlasciciel = kr.id_kierowcy)
where typ like 'samochod ciezarowy'
group by po.wlasciciel,kr.nazwisko,kr.imie
having count(po.nr_rejestr)>=5 and count(po.nr_rejestr)<=15 and count(marka)>=1
order by 4 desc , 5;


--zad17

select id_dzialu, nazwa, round(avg(placa), 2) as "Srednia placa" 
from pracownicy left join dzialy using(id_dzialu)
where data_zwol is null or data_zwol>=sysdate
group by id_dzialu, nazwa
order by 3 desc;


--zad18

select * from pracownicy;
select distinct(regexp_substr(adres, '\D*[[:alpha:]]*$')), 
count(nr_akt), count(koszt_ubezpieczenia), 
sum(placa+nvl(dod_funkcyjny, 0)+(placa*(dod_staz/100)+nvl(koszt_ubezpieczenia, 0)))
from pracownicy full join dzialy using(id_dzialu) 
where data_zwol is null or data_zwol >sysdate 
group by (regexp_substr(adres, '\D*[[:alpha:]]*$'));


--zad19

select st.stanowisko, count(st.stanowisko),
round(avg(placa)) srednia,
min(placa) minimalna,
max(placa) 
from stanowiska st 
full join pracownicy pr on(st.stanowisko=pr.stanowisko)
where data_zwol is null or data_zwol >=sysdate
group by st.stanowisko
order by 2,3;


--zad20

select distinct decode(r.id_gatunku,null,'brak','1','KARP','2','LIN','3','LESZCZ','4','AMUR','5','WEGORZ','6','BRZANA','7','SWINKA','8','JAZ','9','SZCZUPAK','10','SANDACZ','11','SUM','12','KLEN','13','PSTRAG POTOKOWY','14','PSTRAG ZRODLANY','15','OKON','16','LIPIEN','17','PLOC','18','MIETUS','19','INNE','20','BOLEN','21','KARAS','22','JELEC','23','SIEJA') AS "ID_GATUNKU" ,
nvl(g.nazwa,'brak_polowu') as nazwa ,
count(*) as Sztuki,trunc(sum(nvl(r.waga,0)),3) as "laczna waga",
trunc(avg(nvl(r.waga,0)),3) as "srednia waga", trunc(avg(nvl(r.dlugosc,0)),1) as dlugosc
from rejestry r full join gatunki g on (r.id_gatunku = g.id_gatunku)
group by r.id_gatunku, g.nazwa
having count(*)>=1 
order by 3 desc;


--zad21 
select id_lowiska, nazwa, count(*)as "liczba polowow", count(id_gatunku) as "liczba ryb",
count(distinct id_wedkarza) as"liczba wedkarzy"
from rejestry join lowiska using (id_lowiska)
where czas between timestamp '2016-03-11 15:15:00' and timestamp '2016-03-11 15:15:00' + interval '2' year(1)+
interval'21 21:21:21' day(2) to second 
group by id_lowiska, nazwa
having count (id_gatunku)>=5 and count(*) - count(id_gatunku)>=2 ; 


--zad22

select li.rok, id_okregu, count(distinct(id_licencji)) as "liczba licencji",
count(distinct(id_wedkarza)) as "liczba wedkarzy" 
from okregi
full join oplaty using(id_okregu)
left join licencje li using (id_okregu)
group by id_okregu, li.rok
order by rok, id_okregu;


--zad23

select extract (year from czas) as "rok", ga.nazwa, (re.dlugosc), 
trunc(czas) as "kiedy", nazwisko, k.nazwa as "lowisko" from 
rejestry re join wedkarze using (id_wedkarza) 
join gatunki ga using (id_gatunku)
join lowiska k  using (id_lowiska)
order by czas;


--zad24 
select distinct(nazwa), rekord_waga, decode(max(waga), null, 'Brak polowu', max(waga)), 
decode(nvl(round((max(waga)/rekord_waga)*100, 2), 0),0, ' ', 
round((max(waga)/rekord_waga)*100, 2)) as procent from rejestry 
right join gatunki using(id_gatunku)
where (round(((waga)/rekord_waga)*100)>=25 or waga is null) 
and rekord_waga is not null group by (nazwa), rekord_waga;


