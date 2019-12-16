-- 1.1
/* Na podstawie danych  zgromadzonych w tabeli POJAZDY wyswietl pojazdy nie bêd¹ce samochodami osobowymi 
zarejestrowane w Czêstochowie (pocz¹tek nr rejestracynego SC) a nazwa koloru skladaja sie od 7 do 9 liter

*/
SELECT * FROM pojazdy WHERE nr_rejestr LIKE 'SC%' and typ not LIKE 'SAM.OSOBOWY' and Length(kolor) between 7 and 9;


-- 1.2
/* Na podstawie danych zawartych w tabeli STUDENCI wyœwietl wszystkich studentów, którzy studiuj¹ na 2, 3 lub 5 roku a ich nazwisko koñczy siê na literê K.
*/
SELECT * FROM studenci WHERE rok in (2,3,5) and nazwisko like '%k';

-- 1.3
/* Na podstawie danych zawartych w tabeli pracownicy wyœwietl listê aktualnych pracowników pracuj¹cych na stanowisku
dyrektor, logistyk lub sprzedawca a ich sta¿ w firmie wynosi co najmniej 10 lat
*/
SELECT * FROM pracownicy WHERE data_zwol is NULL and Extract(Year from sysdate)-Extract(Year from data_zatr)>=10 and stanowisko IN ('DYREKTOR', 'LOGISTYK', 'SPRZEDAWCA');

-- 1.4
/* Na podstawie danych znajduj¹cych siê w tabeli KIWEROWCY wyœwietl kierowców, ktorych nazwiskach na drugiej pozycji znajduje sie litera A a na ostatniej K,
imiona skladaj¹ siê z 5, 7 lub 9 litera a identyfikator (id_kier) jest liczba nieparzyst¹.
*/
SELECT * FROM kierowcy WHERE nazwisko LIKE '_A%K' and Length(imie) in (5, 7, 9) and mod(id_kier,2)=1;

-- 1.5
/* Na podstawie danych zgromadzonych w tabeli LOWISKO wyœwietl wszystkie ³owiska typu zbiornik, które posiadaj¹ zarz¹dcê (id_okrêgu) a ich powierzchnia wynosi od 50 do 200 ha. 
*/

SELECT * FROM lowisko WHERE id_okregu is not NULL and typ LIKE 'zbiornik' and powierzchnia BETWEEN 50 and 200;


-- 2.1
/* Na podstawie danych zawartych w tabeli REJESTR wyswietl identyfikatory ryb (id_ryby), ktorych odnotowano polow 
na wodach gospodarowanych przez PZW Czestochowa (pierwsza litera identyfikatorow lowisk to C) zarowno w 2014 jak i w 2015 roku a 
ktorych polowu nie odnotowano w roku 2016.
*/
SELECT id_ryby FROM rejestr WHERE id_ryby is not null and id_lowiska LIKE 'C%' and EXTRACT(YEAR from dataczas)=2014
INTERSECT
SELECT id_ryby FROM rejestr WHERE id_ryby is not null and id_lowiska LIKE 'C%' and EXTRACT(YEAR from dataczas)=2015
MINUS
SELECT id_ryby FROM rejestr WHERE id_ryby is not null and id_lowiska LIKE 'C%' and EXTRACT(YEAR from dataczas)=2016;


--2.2
/* Na podstawie danych zawartych w tabeli STUDENCI wyswietl informacje odnosnie pozycji pierwszego wyst¹pienia litery A w imionach studentow. 
Dane uporz¹dkuj wedlug liczebnosci od najwiekszej do najmniejszej 
*/
SELECT DECODE(Instr(imiona,'A'), 0, 'Brak A', Instr(imiona,'A')) as "Pozycja A w imieniu", count(*) "Liczba wystapien" FROM studenci
GROUP BY Instr(imiona,'A') ORDER BY 2 DESC;

--2.3
/* Z tabeli POJAZDY wyswietl dane samochodów osobowych (numer rejestracyjny, marka, model, pojemnosc) wraz kolumna zaweiraj¹c¹ komentarz
w stosunku do wartoœci pojemnosci:
- do 1200 - Samochod malolitrazowy
- powyzej 1200 do 2000 - Samochod o sredniej pojemnosci silnika
- powyzej 2000 do 3000 - Samochod o duzej pojemnosci silnika
- powyzej 3000 - Samochod o bardzo duzej pojemnosci silnika
*/

SELECT nr_rejestr, marka, model, pojemnosc, 
CASE 
WHEN pojemnosc<=1200 THEN 'Samochod malolitrazowy'
WHEN pojemnosc>1200 and pojemnosc <2000 THEN 'Samochod o sredniej pojemnosci silnika'
WHEN pojemnosc>=2000 and pojemnosc <3000 THEN 'Samochod o duzej pojemnosci silnika'
ELSE 'Samochod o bardzo duzej pojemnosci silnika'
END Komentarz
FROM pojazdy WHERE typ LIKE 'SAM.OS%'; 


--3.1
/* Na podstawie danych zawartych w tabelach REJESTR i LOWISKO wyswietl dane (szczegoly polowu oraz lowiska) dotyczace najdluzszego karpia (id_ryby 1) zlowionego w maju lub lipcu
*/
SELECT * FROM rejestr JOIN lowisko USING (id_lowiska) WHERE  id_ryby=1 and Extract(Month from dataczas) IN (5, 7) and
dlugosc = (SELECT max(dlugosc) FROM rejestr WHERE id_ryby=1 and Extract(Month from dataczas) IN (5, 7));


-- 3.2
/* Na podstawie danych zawartych w tabeli REJESTR wyswietl uporzadkowana liste zawieraj¹co informacje dotycz¹c¹ statystyk poszczegolnych lowisk
zarz¹dzanych przez PZW Czestochowa lub PZW Katowice (id_okregu rozpoczynajace sie C lub 0) za rok 2014
w zakresie lacznych i srednich wag zlowionych ryb (z dokladnoscia do grama), srednich z dlugosci (z dokladnoscia do 1 cm) 
liczby wszystkich polowow i liczby udanych polowow. 
*/
SELECT id_lowiska, sum(NVL(waga,0)) as "Laczna waga", Round(avg(NVL(waga,0)),3) as "Srednia waga", Round(avg(NVL(dlugosc,0))) as "Srednia dlugosc",
count(*) as "Liczba polowow", count(id_ryby) as "Liczba ryb"FROM rejestr 
WHERE (id_lowiska LIKE 'C%' or id_lowiska LIKE '0%') and Extract(YEAR from dataczas)=2014
GROUP BY id_lowiska ORDER BY 3 DESC;


--3.3
/* Na podstawie danych zawartych w tabelach REJESTR, LOWISKO i RYBA wyswietl liste gatunków,
których odnotowano przynajmniej 3 polowy na wodach zarz¹dzanych przez PZW Czestochowa oraz ktorych 
odnotowano przynajmniej jeden polow na wodach zarzadzanych przez PZW Katowice (zastosuj ANY,ALL,IN lub EXISTS).
*/

SELECT r.id_ryby, b.nazwa, count(*) FROM rejestr r JOIN lowisko l ON(r.id_lowiska=l.id_lowiska) JOIN ryba b ON(r.id_ryby=b.id_ryby)
WHERE id_okregu LIKE 'PZW Czestochowa' and r.id_ryby is not NULL
and r.id_ryby = ANY
(SELECT id_ryby FROM rejestr r JOIN lowisko l ON(r.id_lowiska=l.id_lowiska)
WHERE id_okregu LIKE 'PZW Katowice' and id_ryby is not NULL) 
GROUP BY r.id_ryby, b.nazwa HAVING count(*)>=3;


--4.1
/* Na podstawie danych zawartych w tabelach REJESTR i RYBA wyswietl wpisy dotyczace poszczegolnych wedkarzy w zakresie 
zlowionych przez nich najdluzszych (dlugosc) ryb z gatunków karp, leszcz i szczupak w miesiacach od maja do sierpnia.
Dane uporz¹dkuj kolejno wedlug identyfikatora wedkarza i dlugosci (niemalej¹co)
*/
select id_wedkarza, id_ryby, dlugosc, Round(dataczas) dzien, waga  from rejestr 
WHERE (id_wedkarza, id_ryby, dlugosc)
IN
(SELECT id_wedkarza, id_ryby, max(dlugosc) FROM rejestr JOIN ryba USING(id_ryby)
WHERE nazwa IN ('KARP', 'LESZCZ', 'SZCZUPAK') and Extract(Month from dataczas) between 5 and 8
GROUP BY  id_wedkarza, id_ryby)
and Extract(Month from dataczas) between 5 and 8
ORDER BY id_wedkarza, dlugosc DESC;

-- 4.2
/* W oparciu o dane zgromadzone w tabelach Rejestr, Ryba, Lowisko i Wedkarz wyswietl informacje o polowach (co, kiedy, gdzie i kto),
w ramach których zostay zlowione najciê¿sze ryby w danym roku.
*/

SELECT Extract(Year from dataczas) rok, Round(dataczas) data, waga, b.nazwa Gatunek, l.nazwa Lowisko, nazwisko
FROM rejestr r LEFT JOIN ryba b ON(r.id_ryby=b.id_ryby) JOIN lowisko l ON(r.id_lowiska=l.id_lowiska) JOIN wedkarz USING(id_wedkarza) 
WHERE (Extract(Year from dataczas), waga) IN
(SELECT Extract(Year from dataczas), max(waga) FROM rejestr
WHERE id_ryby is not NULL GROUP BY Extract(Year from dataczas))
ORDER BY 1,2;


-- 4.3

/* Na podstawie danych zawartych w tabelach PRACOWNICY i DZIALY wyswietl liste pracownikow, ktorzy otrzymuja najwieksza pensje 
 w poszczegolnych lokalizacjach firmy (siedziba) pod warunkiem, ¿e w danym miescie firma zatrudnia przynajmniej 4 pracownikow
*/

SELECT siedziba, nazwisko, NVL(placa,0)+NVL(dod_funkcyjny,0)+NVL(prowizja,0) Pensja FROM pracownicy p JOIN dzialy d ON(p.id_dzialu=d.id_dzialu)
WHERE data_zwol is NULL and (siedziba, NVL(placa,0)+NVL(dod_funkcyjny,0)+NVL(prowizja,0)) = 
(SELECT siedziba, max(NVL(placa,0)+NVL(dod_funkcyjny,0)+NVL(prowizja,0)) FROM pracownicy JOIN dzialy USING(id_dzialu)
WHERE data_zwol is NULL and siedziba=d.siedziba
GROUP BY siedziba HAVING count(*)>=4)
ORDER BY 3 DESC;

-- 4.4

/* Na podstawie danych zgromadzonych w tabelach Rejestr i Lowisko wyswietl zestawienie zawierajace podsumowanie polowow na wodach zarzadzanych przez 
poszczegolne okregi PZW w ramach poszczegolnych lowisk w zakresie:
- liczby wszystkich polowow,
- liczby lowi¹cych wedkarzy,
- liczby zlowionych ryb,
- lacznej wagi ryb
Ponadto podsumowanie powinno zwierac zestawienia wedlug okregu oraz calosciowe.
*/

SELECT NVL(l.id_okregu, ' Wszystko ') Okreg, NVL(l.id_lowiska, ' ') Lowisko, count(*) as "Liczba polowow", count(distinct(id_wedkarza)) as "Liczba wedkarzy", count(id_ryby) as "Liczba zlowionych ryb", sum(NVL(waga,0)) as "Laczna waga"
FROM rejestr r JOIN lowisko l ON(r.id_lowiska=l.id_lowiska)
WHERE id_okregu LIKE 'PZW%'
GROUP BY GROUPING SETS((l.id_okregu, l.id_lowiska), (l.id_okregu), ())
ORDER BY 1,2;



--5.1
/* W oparciu o dane zawarte w tabelach Wedkarz, Lowisko i Rejestr wyswietl informacje o liczbie ryb zlowionych przez poszczegolnych wedkarzy
na wodach gospodarowanych przez poszczegolne podmioty prywatne (w zestawieniu nalezy uwzglêdniæ wszystkich wlascicieli, ktorzy nie nale¿¹ do PZW)
oraz na wodach ogolnodostepnych (bez wlasciciela). Dane uporzadkuj wedlug indentyfikatora wêdkarza (w przypadku braku )
*/

SELECT id_wedkarza, nazwisko, NVL(id_okregu,'Lowiska ogolnodostepne') Wlasciciel,
CASE NVL(id_okregu, 'Brak')
WHEN 'Brak' THEN
  (SELECT count(rr.id_ryby) FROM rejestr rr JOIN lowisko ll ON(rr.id_lowiska=ll.id_lowiska) 
  WHERE rr.id_wedkarza=w.id_wedkarza and ll.id_okregu is NULL)
ELSE 
  (SELECT count(rr.id_ryby) FROM rejestr rr JOIN lowisko ll ON(rr.id_lowiska=ll.id_lowiska) 
  WHERE rr.id_wedkarza=w.id_wedkarza and ll.id_okregu=l.id_okregu)
END as "Liczba ryb"
FROM wedkarz w CROSS JOIN lowisko l 
WHERE id_okregu not LIKE 'PZW%' or id_okregu is NULL
GROUP BY id_wedkarza, nazwisko, id_okregu ORDER BY 1;

-- 5.2
/* W oparciu o dane zgromadzone w tabelach Rejestr, Ryba i Wedkarz wyswietl liste gatunkow ryb (wraz z brakiem polowu) 
wraz z informacj¹ o lacznej wadze zlowionych ryb i liczbie wêdkarzy, którzy zlowili przynajmniej jedn¹ ryb¹ danego gatunku. Pondato lista 
powinna zawierac kolume prezentuj¹ca nazwiska wszystkich wedkarzy (plus ich identyfiaktory oraz laczne wagi), ktorzy zowili dany gatunek ryby 
*/

SELECT Gatunek, sum(waga) as "Laczna waga", count(id_wedkarza) as "Liczba lowcow", LISTAGG(nazwisko||'('||id_wedkarza||'-'||Waga||'kg)', ', ') WITHIN GROUP (ORDER BY nazwisko) as Wedkarze
FROM
(SELECT NVL(b.nazwa, 'Brak_polowu') Gatunek, r.id_wedkarza, nazwisko, count(*) Liczba, NVL(sum(waga),0) Waga
FROM rejestr r LEFT JOIN ryba b ON(r.id_ryby=b.id_ryby) JOIN wedkarz w ON(r.id_wedkarza=w.id_wedkarza)
GROUP BY NVL(b.nazwa, 'Brak_polowu'),  r.id_wedkarza, nazwisko)
GROUP BY Gatunek;


  












