CREATE TABLE States(
	id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL
);

CREATE TABLE City(
	id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	state_id INT REFERENCES States(id)
);

CREATE TABLE Users(
	id SERIAL PRIMARY KEY,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	birth_date TIMESTAMP NOT NULL,
	email VARCHAR(50) NOT NULL,
	state_id INT REFERENCES States(id),
	city_id INT REFERENCES City(id)
);

CREATE TYPE festival_status AS ENUM ('active', 'inactive', 'pending');
CREATE TABLE Festival(
	id SERIAL PRIMARY KEY,
	capacity INT,
	beginning_date TIMESTAMP NOT NULL,
	ending_date TIMESTAMP NOT NULL,
	name VARCHAR(50) NOT NULL,
	state_id INT REFERENCES States(id),
	city_id INT REFERENCES City(id),
	has_camp BOOLEAN NOT NULL DEFAULT FALSE,
	status festival_status NOT NULL DEFAULT 'pending'
);

CREATE TYPE stage_location AS ENUM ('main', 'forest', 'beach');
CREATE TABLE Stage(
	id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	capacity INT NOT NULL,
	is_covered BOOLEAN NOT NULL DEFAULT FALSE,
	location stage_location NOT NULL,
	festival_id INT REFERENCES Festival(id)
);

CREATE TYPE artist_genre AS ENUM ('hip-hop', 'pop', 'rock' , 'soul' , 'metal' , 'techno' , 'jazz' , 'alt' , 'country');
CREATE TYPE artist_group_type AS ENUM ('solo', 'duo', 'band' , 'DJ');
CREATE TABLE Artist(
	id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	genre artist_genre NOT NULL,
	num_members INT NOT NULL,
	is_active BOOLEAN NOT NULL DEFAULT TRUE,
	group_type artist_group_type NOT NULL,
	country_id INT REFERENCES States(id)
);

CREATE TABLE Performance(
	id SERIAL PRIMARY KEY,
	artist_id INT REFERENCES Artist(id),
	stage_id INT REFERENCES Stage(id),
	beginning TIMESTAMP NOT NULL,
	ex_guests INT NOT NULL,
	UNIQUE (artist_id, stage_id,beginning)
);

CREATE TABLE Orders(
	id SERIAL PRIMARY KEY,
	purchase_date TIMESTAMP NOT NULL,
	user_id INT REFERENCES Users(id)
);

CREATE TYPE ticket_type AS ENUM ('one-day' , 'full');
CREATE TYPE ticket_class AS ENUM ('VIP' , 'camp');
CREATE TABLE Ticket(
	id SERIAL PRIMARY KEY,
	festival_id INT REFERENCES Festival(id),
	user_id INT REFERENCES Users(id),
	order_id INT REFERENCES Orders(id),
	beginning_date TIMESTAMP NOT NULL,
	end_date TIMESTAMP NOT NULL,
	class ticket_class NOT NULL,
	price INT NOT NULL,
	type ticket_type NOT NULL DEFAULT 'full'
);

CREATE TYPE workshop_difficulty AS ENUM ('entry' , 'mid' , 'advanced');
CREATE TABLE Workshop(
	id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	festival_id INT REFERENCES Festival(id),
	difficulty workshop_difficulty NOT NULL,
	capacity INT NOT NULL,
	duration INT NOT NULL,
	date TIMESTAMP NOT NULL,
	requires_prior_knowledge BOOLEAN DEFAULT FALSE
);

CREATE TABLE Mentor(
	id SERIAL PRIMARY KEY,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	birth_date TIMESTAMP NOT NULL CHECK(birth_date <= NOW() - INTERVAL '18 years'),
	exp_years INT NOT NULL CHECK(exp_years > 2),
	expert_in VARCHAR(50) NOT NULL
);

CREATE TYPE application_status AS ENUM ('applied' , 'canceled' , 'done');
CREATE TABLE Application(
	id SERIAL PRIMARY KEY,
	user_id INT REFERENCES Users(id),
	workshop_id INT REFERENCES Workshop(id),
	application_date TIMESTAMP NOT NULL,
	status application_status NOT NULL DEFAULT 'applied'
);

CREATE TYPE personnel_role AS ENUM ('guard' , 'cleaner' , 'ticket staff' , 'manager' , 'first aid' , 'PR manager');
CREATE TABLE Personnel(
	id SERIAL PRIMARY KEY,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	birth_date TIMESTAMP NOT NULL,
	contact VARCHAR(20) NOT NULL,
	is_trained BOOLEAN NOT NULL,
	role personnel_role NOT NULL,
	festival_id INT REFERENCES Festival(id),

	CHECK (
        role <> 'guard'
        OR birth_date <= CURRENT_DATE - INTERVAL '21 years'
    )
);


CREATE TABLE MembershipCard(
	id SERIAL PRIMARY KEY,
	user_id INT REFERENCES Users(id),
	activated_at TIMESTAMP NOT NULL,
	is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE MentorWorkshopRel(
	mentor_id INT REFERENCES Mentor(id),
	workshop_id INT REFERENCES Workshop(id),
	PRIMARY KEY(mentor_id,workshop_id)
);

CREATE VIEW OrderCost AS
SELECT
    o.id,
    o.purchase_date,
    o.user_id,
    SUM(t.price) AS total_cost
FROM Orders o
LEFT JOIN Ticket t ON t.order_id = o.id
GROUP BY o.id;

CREATE VIEW EligibleForMembership AS
SELECT
    u.id AS user_id,
    u.first_name,
    u.last_name,
    COUNT(DISTINCT t.festival_id) AS festivals_attended,
    SUM(t.price) AS total_spent
FROM Users u
JOIN Ticket t ON t.user_id = u.id
GROUP BY u.id
HAVING 
    COUNT(DISTINCT t.festival_id) > 3
    AND SUM(t.price) > 600;

ALTER TABLE Festival
ADD CONSTRAINT festival_dates_valid
CHECK (ending_date > beginning_date);


