select * from studenci;
//1.1 
select count(nazwisko) as "Liczba studentek 3r INF SS" from studenci where imiona like'%a' and tryb like 'STACJONARNY' and stopien like '1' and rok like '3' and kierunek like 'INFORMATYKA';
//1.2 
select count(upper(nazwisko)) as "Liczba Nowakowskich" from studenci where imiona  not like '%a' and nazwisko like 'Nowakowski';
//1.3
 select count(imiona) as "Liczba uczniów na litere M ",count(distinct(imiona)) as "Liczba roznych imion na M " from studenci where imiona like 'M%' and imiona not like '%a';
//1.4
select Concat((nazwisko), Concat(' ', imiona))as "Personalia studenta" from studenci where rok like '4' and stopien like '3' order by "Personalia studenta";
select nazwisko|| ' '|| imiona as "Personalia studenta" from studenci where rok like '4' and stopien like '3' order by "Personalia studenta";
//1.5 
select Lpad(Imiona, 3)as "3 litery imienia",Substr(nazwisko, -3, 3)as"3 ostatnie litery nazwiska", Imiona, nazwisko from studenci where specjalnosc is null;
//1.6
select Lpad(imiona, 1)||'.'||Lpad(nazwisko,1)||'.' as"Inicjaly",imiona, nazwisko,
length(nazwisko)+length(imiona) as "Liczba liter" from studenci where
length(imiona)+length(nazwisko) like 9
or length(imiona)+length(nazwisko) like 11
or length(imiona)+length(nazwisko) like 13;
//1.7
select Initcap(kierunek) from studenci where imiona not like'%a';
select Concat(Upper(Substr(kierunek,1,1)),
Lower(Substr(kierunek,2,Length(kierunek)-1)))
from studenci where imiona not like '%a';
//1.8 
select Substr(nazwisko, 3)as "nazwisko bez KO", Substr(imiona, 1,
length(imiona)-2) as"imie bez SZ", nazwisko||' '||imiona as "Personalia" 
from studenci where imiona like '%sz' and nazwisko like'Ko%';
//1.9 
select nazwisko, Instr(nazwisko, 'a') as "pozycja A w nazwisku", 
length(nazwisko)as"liczba liter" 
from studenci where 
length (nazwisko) like '6' or
length (nazwisko) like '7' or 
length (nazwisko) like '8' or
length (nazwisko) like '9' and rok like '2' and nazwisko like '%a%'order by 3 desc;
//1.10
select Replace(nazwisko, 'Ba', 'Start') as "nazwisko po zmianie",nazwisko, 
Concat(Trim (TRAILING 'a' from imiona),Replace(Substr(imiona,-1, 1), 'a','End')) 
as "imiona po zmianie",imiona from studenci where imiona like '%a' and nazwisko like 'Ba%';
//1.11
select lpad('***',3)||nazwisko||rpad('++++',4) as "Nazwisko" from studenci;
//2.1
select * from pojazdy where pojemnosc between '1000' and'2000' and nr_rejestr
not like 'SCZ______' and nr_rejestr like 'SC_______';
//2.2
select nr_rejestr,Substr(nr_rejestr, -4, 5) as "nienawidze baz ", marka, kolor from pojazdy where mod (Substr(nr_rejestr, -4, 5),3) 
not between 1 and 33 and marka like 'Ford' and kolor like '%metalik';
// 2.3
select * from pojazdy  where typ like 'motocykl' and nr_rejestr like '%6%6%' and kolor like '% %' and pojemnosc not between 250 and 500 ;
//2.4
select marka, modell, typ, pojemnosc, decode(pojemnosc,1000, 'maly pojazd',
2000, 'sredni pojazd', 3000, 'duzy pojazd')as "Komentarz"
from pojazdy where pojemnosc like '1000' or pojemnosc like '2000'
or pojemnosc like '3000' and typ not like 'samochod ciezarowy';
//2.5 
select nr_rejestr, modell, pojemnosc, decode(Substr(nr_rejestr, 0, 2), 
'OP', 'opolskie',
'DW', 'dolnoslaskie',
'KR', 'malopolskie', 
'SC','slaskie', 'Niezidentyfikowane')as "Wojewodztwo" from pojazdy 
where pojemnosc not between '1600' and '2200' and marka like 'Opel';
//3.1 
select 'Od ' ||(min(Distinct czas))|| ' do '|| 
(max(Distinct czas))|| ' odnotowano ' || count(*) || ' polowow, w tym udanych '||
count(id_gatunku)|| ' na wodach ' ||count(distinct(substr(id_lowiska, 1, 1)))
|| ' zarzadcow' as "Informacja zbiorcza "from rejestry;
//3.2 
select * from rejestry where id_lowiska like 
'C%' and id_gatunku in (1,3,9,10) and dlugosc 
between '40' and '60' and waga like round(waga,1);
//3.3
select count(*) as"liczba ryb", count (DISTINCT id_wedkarza) as"liczba lowcow",
count( DISTINCT id_lowiska) as"liczba lowisk", sum(waga) as "laczna waga", 
round(avg(waga),3) as "srednia waga", (round(avg(dlugosc),0)) as "srednia dlugosc" 
from rejestry where id_gatunku like '1';
//3.4 
select Substr(czas, 1, 9 ) as "dzien polowu ", id_gatunku,
decode(id_gatunku,'2', 'lin',
'4', 'amur',
'15', 'ploc', 
'17', 'okon','brak polowu') as" gatunek" from rejestry
where id_gatunku in (2, 4, 15, 17) or id_gatunku is null;


