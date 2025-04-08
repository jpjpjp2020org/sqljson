--
-- PostgreSQL database dump
--

-- Dumped from database version 14.15 (Ubuntu 14.15-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.15 (Ubuntu 14.15-0ubuntu0.22.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: movies; Type: TABLE; Schema: public; Owner: framework_user
--

CREATE TABLE public.movies (
    movieid integer NOT NULL,
    title text,
    genres text
);


ALTER TABLE public.movies OWNER TO framework_user;

--
-- Name: ratings; Type: TABLE; Schema: public; Owner: framework_user
--

CREATE TABLE public.ratings (
    userid integer NOT NULL,
    movieid integer NOT NULL,
    rating numeric(2,1),
    "timestamp" bigint
);


ALTER TABLE public.ratings OWNER TO framework_user;

--
-- Name: movies movies_pkey; Type: CONSTRAINT; Schema: public; Owner: framework_user
--

ALTER TABLE ONLY public.movies
    ADD CONSTRAINT movies_pkey PRIMARY KEY (movieid);


--
-- Name: ratings ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: framework_user
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_pkey PRIMARY KEY (userid, movieid);


--
-- Name: ratings ratings_movieid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: framework_user
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_movieid_fkey FOREIGN KEY (movieid) REFERENCES public.movies(movieid);


--
-- PostgreSQL database dump complete
--

