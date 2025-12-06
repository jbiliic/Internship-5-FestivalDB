--1. Ispis svih radionica koje imaju razinu "napredna" i održavaju se na festivalima u 2025. godini.
SELECT w.*
FROM Workshop w
WHERE w.difficulty = 'advanced'
  AND EXTRACT(YEAR FROM w.date) = 2025;

--2. Ispis svih nastupa (izvođač, festival, pozornica, vrijeme početka) za koje je očekivani
--broj posjetitelja veći od 10 000.

SELECT a.name AS artist,
       f.name AS festival,
       s.name AS stage,
       p.beginning,
	   p.ex_guests
FROM Performance p
JOIN Artist a ON p.artist_id = a.id
JOIN Stage s ON p.stage_id = s.id
JOIN Festival f ON s.festival_id = f.id
WHERE p.ex_guests > 10000;


--3. Ispis svih festivala koji se održavaju tijekom 2025. godine.

SELECT *
FROM Festival
WHERE EXTRACT(YEAR FROM beginning_date) = 2025
   OR EXTRACT(YEAR FROM ending_date) = 2025;

--4. Ispis svih radionica koje imaju razinu „napredna”.
SELECT *
FROM Workshop
WHERE difficulty = 'advanced';

--5. Ispis svih radionica koje traju više od 4 sata.

SELECT *
FROM Workshop
WHERE duration > 4;

--6. Ispis svih radionica koje zahtijevaju prethodno znanje.

SELECT *
FROM Workshop
WHERE requires_prior_knowledge = TRUE;

--7. Ispis svih mentora koji imaju više od 10 godina iskustva.

SELECT *
FROM Mentor
WHERE exp_years > 10;

--8. Ispis svih mentora rođenih prije 1985. godine.

SELECT *
FROM Mentor
WHERE birth_date < '1985-01-01';

--9. Ispis svih posjetitelja koji žive u Splitu.

SELECT u.*
FROM Users u
JOIN City c ON u.city_id = c.id
WHERE c.name = 'Split';

--10. Ispis svih posjetitelja čiji email završava s „@gmail.com”.

SELECT *
FROM Users
WHERE email LIKE '%@gmail.com';

--11. Ispis svih posjetitelja mlađih od 25 godina.

SELECT DISTINCT u.*
FROM Users u
JOIN Ticket t ON t.user_id = u.id
WHERE u.birth_date > NOW() - INTERVAL '25 years';

--12. Ispis svih ulaznica koje su skuplje od 120 €.

SELECT *
FROM Ticket
WHERE price > 120;

--13. Ispis svih ulaznica tipa „VIP”.

SELECT *
FROM Ticket
WHERE class = 'VIP';

--14. Ispis svih festivalskih ulaznica koje vrijede za cijeli festival.

SELECT *
FROM Ticket
WHERE type = 'full';

--15. Ispis svih zaposlenika (osoblja) koji imaju potrebnu sigurnosnu obuku.

SELECT *
FROM Personnel
WHERE is_trained = TRUE;
