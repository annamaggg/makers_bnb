TRUNCATE TABLE users, spaces, bookings RESTART IDENTITY;

INSERT INTO users (name, username, email, password)
VALUES ('Joel', 'joelio', 'joel@makers.com', 'password1'),
       ('Junaid', 'junio', 'junaid@makers.com', 'password2');
INSERT INTO spaces (name, available, description, price, user_id)
VALUES ('Paradise Beach', 'true', 'Seaside getaway', '120', '1'),
       ('Cityscapes', 'true', 'Bright lights and candlelit bars', '100', '2'),
       ('Countryside Lodge', 'false', 'Quiet, welcoming and cozy', '80', '2'),
       ('Seaside Spa', 'true', 'Great pampering escape', '150', '2');
INSERT INTO bookings (date_of_booking, approved, user_id, space_id)
VALUES ('2023-02-10', 'false', '2', '1'),
       ('2023-02-13', 'false', '1', '2');
