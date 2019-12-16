

--zad1 
SELECT NR_INDEKSU, NAZWISKO, IMIONA, DATA_URODZENIA, ADRES, KIERUNEK, TRYB FROM STUDENCI WHERE KIERUNEK LIKE 'INFORMATYKA' 
AND TRYB LIKE 'NIESTACJONARNY' AND DATA_URODZENIA IN (SELECT MIN(DATA_URODZENIA) FROM STUDENCI);

--zad2 
select re.waga, ga.nazwa, k.id_lowiska, we.nazwisko, we.imie, trunc(re.czas) as "dzien" from 
REJESTRY re 
join GATUNKI ga on  re.id_gatunku = ga.id_gatunku
join LOWISKA k on re.id_lowiska = k.id_lowiska
join WEDKARZE we on re.id_wedkarza= we.id_wedkarza
where extract(month from czas)=5 and to_char(czas, 'D') in (6,7) and waga in
(select max(waga) from rejestry where extract(month from czas)=5 and to_char(czas, 'D') in (6,7))
group by re.waga, ga.nazwa, k.id_lowiska, we.nazwisko, we.imie, re.czas;


--zad 3
select kierunek, tryb, nr_indeksu, nazwisko, srednia from studenci
where stopien=1 and rok=2 and (kierunek,tryb,srednia) in
(select kierunek,tryb,min(srednia) from studenci
where stopien =1 and rok =2
group by kierunek, tryb)
order by 5;

--zad4
select kierunek, srednia, nazwisko, imiona, nr_indeksu, stopien, rok, tryb 
from studenci STUDENCI 
where ((kierunek, srednia) in( select kierunek, max(srednia) from studenci 
where imiona like '%a' group by kierunek) and imiona like '%a')
or 
 ((kierunek, srednia) in( select kierunek, max(srednia) from studenci 
where imiona like '%a' group by kierunek) and imiona not like '%a')
order by kierunek, srednia desc, tryb;

--zad5
select id_kierowcy, nazwisko, imie, adres ,count(nr_rejestr) as "liczba pojazdow" from 
POJAZDY po join KIEROWCY ki on (po.wlasciciel = ki.id_kierowcy)
where typ in('samochod osobowy', 'motocykl')
group by id_kierowcy, nazwisko, imie, adres
having (count(nr_rejestr)) in (select  max(count(nr_rejestr))from pojazdy where 
typ in ('samochod osobowy', 'motocykl') group by wlasciciel); 

--zad6 
select id_kierowcy, nazwisko, imie, adres ,count(nr_rejestr) as "L.poj", 
(select count(nr_rejestr) from POJAZDY po
WHERE typ like 'samochod osobowy' and po.wlasciciel=id_kierowcy) as "L.sam", 
(select count(nr_rejestr) from POJAZDY po 
WHERE typ like 'motocykl' and po.wlasciciel = id_kierowcy) as "L.mot" 
from POJAZDY po join KIEROWCY k on (po.wlasciciel = k.id_kierowcy) 
WHERE typ in('samochod osobowy', 'motocykl')
group by id_kierowcy, nazwisko, imie, adres
having (count(nr_rejestr)) in (select  max(count(nr_rejestr))from pojazdy where 
typ in ('samochod osobowy', 'motocykl') group by wlasciciel); 

--zad7 
select decode(GATUNKI.nazwa, null, 'brak polowu',GATUNKI.nazwa) as "Nazwa", 
czas as "Ostatni polow", 
trunc(sysdate- trunc(czas)) as "dni", nazwisko, 
LOWISKA.nazwa as "Nazwa lowiska"
from REJESTRY 
left join GATUNKI using (id_gatunku)
join WEDKARZE using (id_wedkarza)
join LOWISKA using (id_lowiska)
where czas in (select max(czas) from rejestry group by id_gatunku);

--zad8
select decode(GATUNKI.nazwa, null, 'brak polowu',GATUNKI.nazwa) as "Nazwa", 
czas as "Ostatni polow", 
trunc(sysdate- trunc(czas)) as "dni", nazwisko, 
LOWISKA.nazwa as "Nazwa lowiska"
from REJESTRY 
full join GATUNKI using (id_gatunku)
left join WEDKARZE using (id_wedkarza)
left join LOWISKA using (id_lowiska)
where czas in (select max(czas) from rejestry group by id_gatunku)
or czas is null;

--zad9
select id_dzialu, nazwa, nazwisko, nr_akt, stanowisko, data_zatr, data_zwol 
from PRACOWNICY join DZIALY using(id_dzialu) where 
((id_dzialu, data_zatr)in(select id_dzialu, max(data_zatr) from PRACOWNICY
WHERE data_zwol is null or data_zwol>sysdate group by id_dzialu))
OR
((id_dzialu, data_zatr)in( select id_dzialu, min(data_zatr) from PRACOWNICY
WHERE data_zwol is null or data_zwol>sysdate group by id_dzialu))
order by id_dzialu;

--zad10

--zad11 
select extract(year from czas) as "rok",gatunki.nazwa,dlugosc, nazwisko, LOWISKA.nazwa as "Lowisko"  FROM rejestry 
join GATUNKI using(id_gatunku) 
join WEDKARZE using(id_wedkarza)
join LOWISKA using (id_lowiska)
WHERE ( dlugosc, gatunki.nazwa)in (select max(dlugosc), gatunki.nazwa  
from REJESTRY group by gatunki.nazwa, czas)
order by 1, 3 desc ;
 
--zad13 
select * from 
(
select id_okregu, id_lowiska, nazwa, sum(waga) wagaa, count(czas) ilo, count(id_gatunku)
from rejestry join lowiska using(id_lowiska)
where id_okregu like 'PZW%' group by id_okregu, id_lowiska, nazwa
) too
where wagaa >= all(select sum(waga) from rejestry join lowiska using(id_lowiska) 
where too.id_okregu = id_okregu group by id_lowiska);
 
--zad14
select tryb, stopien, kierunek, rok, count(nr_indeksu) as "liczba studentów"
from studenci 
group by rollup (tryb, stopien, kierunek, rok);

--zad15 
select tryb, stopien, kierunek, rok, decode(grouping_id(tryb, stopien, kierunek, rok), 1, 'Na danym roku w TSK', 3, 'Na danym kierunku w TS', 7, 'Na danym stopnia w T', 
15, 'W danym trybie', 'Ogolem studiuja') as opis, count(nr_indeksu) from studenci group by grouping sets((tryb, stopien, kierunek, rok), (tryb, stopien, kierunek), (tryb, stopien), (tryb), ());

--zad16 
select decode(grouping_id(typ,marka,id_kierowcy),7,'Podsumowanie',2,'po marce','inne'),nazwisko, id_kierowcy,
typ, marka, count(nr_rejestr) "Liczba pojazdow" 
from pojazdy join kierowcy on (wlasciciel=id_kierowcy)
group by grouping sets 
((typ,marka),(typ),(marka),(id_kierowcy,nazwisko),());

--zad 17 
select decode(grouping(lowiska.nazwa), 1, 'Wszystkie lowiska', lowiska.nazwa) as lowisko, decode(grouping(gatunki.nazwa), 1, 'Razem', gatunki.nazwa) as gatunek, 
count(id_gatunku) as liczebnosc, decode(sum(waga), null, 'ni ma',sum(waga)) as waga_sum, count(distinct(id_wedkarza)) as "Liczba roznych wedkarzy" 
from rejestry right join lowiska using(id_lowiska) join gatunki using(id_gatunku)
group by grouping sets((), (lowiska.nazwa), (gatunki.nazwa), (lowiska.nazwa, gatunki.nazwa)) ;



