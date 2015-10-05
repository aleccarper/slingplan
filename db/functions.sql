/*
This is the functions.sql file used by Squirm-Rails. Define your Postgres stored
procedures in this file and they will be loaded at the end of any calls to the
db:schema:load Rake task.
*/
CREATE OR REPLACE FUNCTION vendor_locations_with_open_negotiations(_vendor_id integer)
RETURNS
  TABLE (
    location_id integer,
    negotiation_id integer
  )
AS $$
BEGIN
  RETURN QUERY SELECT l.id, n.id
  FROM locations AS l
  RIGHT JOIN vendor_rfps AS v ON l.id = v.location_id
  LEFT JOIN negotiations AS n ON v.id = n.id
    WHERE l.vendor_id = _vendor_id
    AND n.status = 'open';
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION location_events(_location_id integer)
RETURNS
  TABLE (
    event_id integer,
    location_id integer,
    vendor_rfp_id integer,
    service_rfp_id integer
  )
AS $$
BEGIN
  RETURN QUERY SELECT
    e.id AS event_id,
    l.id AS location_id,
    v.id AS vendor_rfp_id,
    s.id AS service_rfp_id
  FROM events AS e
    LEFT JOIN service_rfps AS s ON s.event_id = e.id
    RIGHT JOIN vendor_rfps AS v ON v.service_rfp_id = s.id
    LEFT JOIN locations AS l ON l.id = v.location_id
  WHERE l.id = _location_id;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION under_event_for_location(_event_id integer, _location_id integer)
RETURNS
  TABLE (
    vendor_rfp_id integer,
    negotiation_id integer
  )
AS $$
BEGIN
  RETURN QUERY SELECT
    n.id AS negotiation_id,
    v.id AS vendor_rfp_id
  FROM vendor_rfps AS v
  LEFT JOIN negotiations AS n ON n.vendor_rfp_id = v.id
  LEFT JOIN service_rfps AS s ON s.id = v.service_rfp_id
  LEFT JOIN events AS e ON e.id = s.event_id
  LEFT JOIN locations AS l ON l.id = v.location_id
    WHERE l.id = _location_id
    AND e.id = _event_id;
END;
$$ LANGUAGE plpgsql;
