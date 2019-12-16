

--zad 1

select  (extract(year from czas)||'/'||extract(month from czas)
||'/'||extract(day from czas)||' '||extract(hour from czas)||':'||
extract(minute from czas))
as "czas polowu", dlugosc, to_char('ponizej_sredniej') as "komentarz"
from rejestry
where dlugosc <58 
union
select  (extract(year from czas)||'/'||extract(month from czas)
||'/'||extract(day from czas)||' '||extract(hour from czas)||':'||
extract(minute from czas))
as "czas polowu", dlugosc, to_char('rowna_sredniej') as "komentarz"
from rejestry
where dlugosc =58 
union
select  (extract(year from czas)||'/'||extract(month from czas)
||'/'||extract(day from czas)||' '||extract(hour from czas)||':'||
extract(minute from czas))
as "czas polowu", dlugosc, to_char('powyzej_sredniej') as "komentarz"
from rejestry
where dlugosc >58 ;



--zad 2 
select  (extract(year from czas)||'/'||extract(month from czas)
||'/'||extract(day from czas)||' '||extract(hour from czas)||':'||
extract(minute from czas))
as "czas polowu", dlugosc,
      case 
      when (dlugosc is NULL) then 'brak polowu'
      when (dlugosc < 58) then 'ponizej sredniej'
      when (dlugosc = 58) then 'rowna sredniej'
      else 'powyzej sredniej'
      end komentarz
from rejestry join gatunki using (id_gatunku)
where nazwa like 'SANDACZ';


--zad 3 

select id_gatunku,nazwa 
from rejestry join gatunki using(id_gatunku)
group by id_gatunku,nazwa
having count(id_lowiska)>=1
minus
select id_gatunku,nazwa 
from rejestry join gatunki using( id_gatunku)
group by id_gatunku,nazwa
having count(id_lowiska) <=5;


--zad4

select id_kierowcy, nazwisko, imie, count(nr_rejestr) from pojazdy po join(
select id_kierowcy, nazwisko, imie from kierowcy join pojazdy on(wlasciciel=id_kierowcy) where (typ) like 'motocykl' 
group by id_kierowcy, nazwisko, imie having count(nr_rejestr) = 1
INTERSECT
select id_kierowcy, nazwisko, imie from kierowcy join pojazdy on(wlasciciel=id_kierowcy) where (typ) like 'samochod osobowy' 
group by id_kierowcy, nazwisko, imie having count(nr_rejestr) >=1
INTERSECT
select id_kierowcy, nazwisko, imie from kierowcy join pojazdy on(wlasciciel=id_kierowcy) where (typ) like 'samochod ciezarowy' 
group by id_kierowcy, nazwisko, imie having count(nr_rejestr) >=2
) ke on(po.wlasciciel=ke.id_kierowcy) group by id_kierowcy, nazwisko, imie;



--zad 5
 
SELECT G1.ID_GATUNKU, G1.NAZWA
FROM (
  SELECT GATUNKU.ID_GATUNKU, GATUNKU.NAZWA
  FROM Gatunki GATUNKU
  LEFT JOIN Rejestry REJESTRY ON GATUNKU.ID_GATUNKU = REJESTRY.ID_GATUNKU
  LEFT JOIN Lowiska LOWISKA ON REJESTRY.ID_LOWISKA = LOWISKA.ID_LOWISKA
  LEFT JOIN Wedkarze WEDKARZE ON REJESTRY.ID_WEDKARZA = WEDKARZE.ID_WEDKARZA
  WHERE LOWISKA.NAZWA LIKE 'Poraj'
  INTERSECT
  SELECT GATUNKU.ID_GATUNKU, GATUNKU.NAZWA
  FROM Gatunki GATUNKU
  LEFT JOIN Rejestry REJESTRY ON GATUNKU.ID_GATUNKU = REJESTRY.ID_GATUNKU
  LEFT JOIN Lowiska LOWISKA ON REJESTRY.ID_LOWISKA = LOWISKA.ID_LOWISKA
  LEFT JOIN Wedkarze WEDKARZE ON REJESTRY.ID_WEDKARZA = WEDKARZE.ID_WEDKARZA
  WHERE LOWISKA.NAZWA  LIKE  'Pilica'
  MINUS
  SELECT ID_GATUNKU, NAZWA 
  FROM Rejestry
  JOIN Gatunki USING(ID_GATUNKU)
  JOIN Wedkarze USING(ID_WEDKARZA)
  WHERE NAZWISKO LIKE 'Andrysiak'
) G1
JOIN Rejestry R ON (G1.ID_GATUNKU = R.ID_GATUNKU)
JOIN Lowiska L ON (R.ID_LOWISKA = L.ID_LOWISKA)
WHERE L.NAZWA IN ('Pilica', 'Poraj')
GROUP BY G1.ID_GATUNKU, G1.NAZWA
ORDER BY G1.ID_GATUNKU, G1.NAZWA;


--zad6 

select EXTRACT (year from tab.czas) as "rok" , tab.id_wedkarza, tab.nazwisko, tab.id_okregu from 
(select rejestry.czas, rejestry.id_wedkarza, wedkarze.nazwisko, licencje.id_okregu 
from rejestry REJESTRY
LEFT JOIN Licencje LICENCJE ON REJESTRY.id_wedkarza = LICENCJE.id_wedkarza
LEFT JOIN Wedkarze WEDKARZE ON REJESTRY.id_wedkarza = WEDKARZE.id_wedkarza
LEFT JOIN Lowiska LOWISKA ON REJESTRY.id_lowiska = LOWISKA.id_lowiska
where EXTRACT (year from czas) not like EXTRACT (year from sysdate) )tab
join licencje L ON (tab.ID_WEDKARZA = L.ID_WEDKARZA)
join wedkarze W ON (tab.ID_WEDKARZA = W.ID_WEDKARZA)
join rejestry R ON (tab.ID_WEDKARZA = R.ID_WEDKARZA)
cross join lowiska K 
WHERE
extract(year from R.czas) = L.rok and tab.ID_OKREGU LIKE 'PZW%' AND r.waga is null
GROUP BY tab.czas , tab.id_wedkarza, tab.nazwisko, tab.id_okregu
ORDER BY tab.czas , tab.id_wedkarza, tab.nazwisko, tab.id_okregu;


--zad7 

select id_wedkarza, nazwisko, imie from rejestry join lowiska using(id_lowiska) join wedkarze using(id_wedkarza) where id_okregu like '%PZW Czestochowa%' group by id_wedkarza, nazwisko, imie having count(czas)>=5
intersect
select id_wedkarza, nazwisko, imie from rejestry join lowiska using(id_lowiska) join wedkarze using(id_wedkarza) where id_okregu not like '%PZW%' group by id_wedkarza, nazwisko, imie having count(czas)>=3
intersect
select id_wedkarza, nazwisko, imie from rejestry re left join gatunki ga on(re.id_gatunku = ga.id_gatunku) join lowiska lo using(id_lowiska) join wedkarze we using(id_wedkarza) where extract(Year from czas) = 2018 group by id_wedkarza, nazwisko, imie having count(nvl(ga.id_gatunku, 0))=0;


--zad8 

SELECT rok, max(suma) as "waga w kg ",'maksymalna laczna waga' as komentarz from(
SELECT extract(year from czas) rok, sum(waga) suma from rejestry group by extract(year from czas), id_wedkarza) group by rok
UNION
SELECT rok, round(avg(suma),2),'srednia z lacznych wag' komentarz from(
SELECT extract(year from czas) rok, sum(waga) suma from rejestry group by extract(year from czas), id_wedkarza) group by rok
order by 1;


--zad9 

select * from (
select rok, min(minimu) wag, 'najminejsza laczna waga' as kom, max(nazwisko) as nazwisko, max(imie)as imie from(
select extract(year from czas) rok, nvl(sum(waga), 0) minimu, nazwisko, imie from rejestry join wedkarze using(id_wedkarza) group by extract(year from czas), nazwisko, imie
) group by rok, nazwisko
union
select rok, max(maxi) wag, 'najwieksza laczna waga' as kom, max(nazwisko), max(imie) from
(
select extract(year from czas) rok, nvl(sum(waga), 0) maxi, nazwisko, imie from rejestry join wedkarze using(id_wedkarza) group by extract(year from czas), nazwisko, imie
) group by rok, nazwisko);


--zad10
 
select oplaty.rok, id_okregu, (sum(roczna_oplata_dod)) as "Lacznie zl", count(*)as "Liczba licencji",'Suma oplat z licencji dodatkowych rocznych' as "Komentarz" from licencje lii join oplaty using(id_okregu) where rodzaj in ('dodatkowa') and
(to_date(do_dnia||'-'||lii.rok, 'DD-MM-YYYY') - to_date(od_dnia||'-'||lii.rok, 'DD-MM-YYYY') + 1) >=365 and id_okregu like 'PZW%'
group by id_okregu, oplaty.rok
union
select oplaty.rok, id_okregu, (sum(roczna_oplata_pod)), count(*), 'Suma oplat z licencji podstawowa rocznych' from licencje lii join oplaty using(id_okregu) where rodzaj in ('dodatkowa') and
(to_date(do_dnia||'-'||lii.rok, 'DD-MM-YYYY') - to_date(od_dnia||'-'||lii.rok, 'DD-MM-YYYY') + 1) >=365 and id_okregu like 'PZW%'
group by id_okregu, oplaty.rok
union
select oplaty.rok, id_okregu, sum((to_date(do_dnia||'-'||lii.rok, 'DD-MM-YYYY') - to_date(od_dnia||'-'||lii.rok, 'DD-MM-YYYY') + 1)*dzienna_oplata), sum(to_date(do_dnia||'-'||lii.rok, 'DD-MM-YYYY') - to_date(od_dnia||'-'||lii.rok, 'DD-MM-YYYY')), 'Suma oplat z licencje okresowa' from licencje lii join oplaty using(id_okregu) where rodzaj in ('dodatkowa') and
(to_date(do_dnia||'-'||lii.rok, 'DD-MM-YYYY') - to_date(od_dnia||'-'||lii.rok, 'DD-MM-YYYY') + 1) <365
group by id_okregu, oplaty.rok; 


--zad11

select typ||' jednej marki najwiecej wyprodukowano w '||to_char(data_prod,'day')||' ('||marka||' sztuk '||count(nr_rejestr) ||')' informacja
FROM pojazdy p  GROUP BY typ, marka, to_char(data_prod,'day') 
HAVING count(nr_rejestr) = (select max(count(nr_rejestr))
FROM pojazdy where typ=p.typ group by typ, marka, to_char(data_prod,'day'))
UNION
select typ||' jednej marki najmniej wyprodukowano w '||to_char(data_prod,'day')||' ('||marka||' sztuk '||count(nr_rejestr) ||')'
FROM pojazdy p  GROUP BY typ, marka, to_char(data_prod,'day') 
HAVING count(nr_rejestr) = (select min(count(nr_rejestr))
FROM pojazdy where typ=p.typ group by typ, marka, to_char(data_prod,'day'));



--zad12

select id_wedkarza, nazwisko, 
(
case (select count(czas) from rejestry join lowiska using(id_lowiska) where we.id_wedkarza=id_wedkarza and id_okregu like 'PZW Czestochowa')
when 0 then 'NIE' 
else 'TAK'
end
) as  "PZW Czestochowa",
(select count(czas) from rejestry join lowiska using(id_lowiska) where we.id_wedkarza=id_wedkarza and id_okregu like 'PZW Czestochowa') as "L.polowow",
(
case (select count(czas) from rejestry join lowiska using(id_lowiska) where we.id_wedkarza=id_wedkarza and id_okregu like 'PZW Katowice')
when 0 then 'NIE' 
else 'TAK'
end
) as "PZW Katowice",
(select count(czas) from rejestry join lowiska using(id_lowiska) where we.id_wedkarza=id_wedkarza and id_okregu like 'PZW Katowice') as "L.polowow",
(
case (select count(czas) from rejestry join lowiska using(id_lowiska) where we.id_wedkarza=id_wedkarza and id_okregu like 'PZW Opole')
when 0 then 'NIE' 
else 'TAK'
end
) as "PZW Opole",
(select count(czas) from rejestry join lowiska using(id_lowiska) where we.id_wedkarza=id_wedkarza and id_okregu not like 'PZW Opole') as "L.polowow",
(
case (select count(czas) from rejestry join lowiska using(id_lowiska) where we.id_wedkarza=id_wedkarza and id_okregu not like 'PZW%')
when 0 then 'NIE' 
else 'TAK'
end
) as "Lowiska poza PZW",
(select count(czas) from rejestry join lowiska using(id_lowiska) where we.id_wedkarza=id_wedkarza and id_okregu not like 'PZW%') as "L.polowow"
from wedkarze we;

--zad13


select g1.nazwa as "Gatunek 1",g1.wymiar as "wymiar 1",
case
when g1.wymiar<g2.wymiar then 'mniejszy od'
when g1.wymiar>g2.wymiar then 'wiekszy od'
else 'rowny'
end Komentarz,
g2.nazwa as "Gatunek 2",
g2.wymiar as "wymiar 2", abs(g1.wymiar - g2.wymiar) roznica
from gatunki g1 cross join gatunki g2 where
g1.dpo is not null and g2.dpo is not null and abs(g1.wymiar-g2.wymiar)<=10;

